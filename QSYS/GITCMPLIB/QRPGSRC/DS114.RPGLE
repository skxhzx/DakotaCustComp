     *----------------------------------------------------------------
     *
     *  DS114     Designation area maintenance - Delete
     *  20 February 1993
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*    01/11/02  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416 A*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
     *
     *----------------------------------------------------------------
0493
0493 *----------------------------------------------------------------
.    *  Table and array definitions
0493 *----------------------------------------------------------------
0493
     D msg             s             50    dim(1) ctdata perrcd(1)
0493

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DESIG
     D saveVer#        s                   like($dsver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n

0493 *----------------------------------------------------------------
.    *  Program parameters
0493 *----------------------------------------------------------------
0493
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pcode                19     23
0493
0493 *----------------------------------------------------------------
.    *  Data structure for error message parameters
0493 *----------------------------------------------------------------
0493
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
0493
0493 *----------------------------------------------------------------
.    *  Message control
0493 *----------------------------------------------------------------
0493
     D $msgf           s             10
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
0493
0493 *----------------------------------------------------------------
.    *  Program info data structure
0493 *----------------------------------------------------------------
0493
     D                sds
     D  #prog            *proc
.    D  #job                 244    253
.    D  #user                254    263
.    D  #jobn                264    269
.    D  #jobdt               276    281  0
.    D  #jobtm               282    287  0
0493
0493 *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
0493 *----------------------------------------------------------------
0493
0493 *----------------------------------------------------------------
     *  Let the show begin .....
0493 *----------------------------------------------------------------
0027
     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Open interface

     C                   eval      $dricommand = '*DESIG'
     C                   eval      $drisubcmd  = '%OPEN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      bottom
     C                   endif

     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               if        error
     C****               goto      bottom
     C****               endif

      *  Initialize interface parameters

     C                   eval      savever# = $dsver#
     C                   clear                   $desig
     C                   eval      $dsver# = savever#

     C                   eval      $dscodeu = *on
     C                   eval      $dscode  = $pcode
     C                   eval      $dricommand = '*DESIG'

      *  Verify delete in Dakota

     C                   eval      $drisubcmd  = '%VERIFYDEL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      bottom
     C                   endif

      *  Delete on host record.

     C                   eval      $drisubcmd  = '%DELETE'
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               if        error
     C****               goto      bottom
     C****               endif

      *  Delete in Dakota.

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      bottom
     C                   endif

     C                   exsr      zzok

     C     bottom        tag

     *  Close interface

     C                   eval      $dricommand = '*DESIG'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *----------------------------------------------------------------

     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001s Interface error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *----------------------------------------------------------------

     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *  ZZOK     Send back "successful" message.
     *----------------------------------------------------------------

     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     $pcode        $md(18)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $desig        parm      $desig        $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      $drireturn  = '****'
     C                   eval      $drimessage = 'Error occured on call to '
     C                                         + 'DRICOP'
     C                                         + '/' + %trim($drisubcmd)
     C                                         + ' from ' + #prog
     C                   exsr      zm0001s

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001s

     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
**
Designation area
