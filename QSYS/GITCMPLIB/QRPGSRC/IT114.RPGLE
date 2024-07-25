     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  IT114     Item maintenance - Delete
     F*  01 October 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
DRI AF*    10/02/01  DAS  4.16
     F*      - Total rewrite. Changed to use DRI interface programs.
     *
416aA*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
     *
416bA*    06/11/03  DAS  4.16b
     *      - Recompiled because of change to C#ITEM.
     *      - Note, this program doesn't use the second data
     *        parameter, $item2, because the fields are not used.
     F*
     F*----------------------------------------------------------------

     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D MSG             S             50    DIM(1) CTDATA PERRCD(1)

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

      *----------------------------------------------------------------
      *  Data Formats
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D saveVer#        s                   like($itver#)

      *----------------------------------------------------------------
      *  Variables
      *----------------------------------------------------------------

     D error           s               n

     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D  $PITPE               137    137
     D*
     D*   Redefine key
     D*
     D  $PWHSE                19     21  0
     D  $PITEM                22     36
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERITEM                 1     15
     D  ERCODE                16     25
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   Not used
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains unique key for delete.
     C*
     C*    Returned Parameters
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*              *OK      - Record deleted successfully.
     C*                         Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PARMS
     C*----------------------------------------------------------------
     C*  Main line
     C*

     *  Open interface

     C                   eval      $dricommand = '*ITEM'
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

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = $pitem
     C                   eval      $dricommand = '*ITEM'

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

     C                   EXSR      ZZOK

     C     bottom        tag

     *  Close interface

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop

     C                   return

     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID            7
     CSR                 PARM                    #MSGTP            7
     CSR                 PARM                    #MSGDT
     CSR                 PARM      $PPRG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------

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
     C*----------------------------------------------------------------
     C*     PIR9803  Deleted record successfully.
     C*
     CSR   ZM9803        BEGSR
     CSR                 MOVE      'PIR9803'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $PMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     CSR   ZZOK          BEGSR
     CSR                 MOVE      *BLANKS       $MD
     CSR                 MOVEA     MSG(1)        $MD(1)
     CSR                 MOVEA     $PITEM        $MD(6)
     CSR                 EXSR      ZM9803
     CSR                 MOVE      '*OK     '    $PRTN
     CSR                 ENDSR

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
     C     $item         parm      $item         $dridata

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

     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Item
