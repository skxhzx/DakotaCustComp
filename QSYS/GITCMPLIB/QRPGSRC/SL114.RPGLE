     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL114     Slot maintenance - Delete
     *  10 August 1994
     *  Dave Sommerville
     *
     *  SK114 - 1.00
     *
     *  Revisions
     *
416 A*    10/15/01  DAS  4.16
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
416bA*    06/11/02  DAS  4.16b
     *      - Recompiled because of change to C#SLOT.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D msg             s             50    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $paisl                27     29
     D  $ploc                 30     32  0
     D  $prlvl                33     34  0
     D  $phand                35     36

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
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
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      *  Initialize interface parameters

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = $paisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = $ploc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = $prlvl
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = $phand

      *  Get slot information (need slot display)

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm      '%GETI'       $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   if        $drireturn <> '*OK'
     C                   exsr      zm0001s
     C                   eval      $prtn = '*PGMQ'
     C                   goto      bottom
     C                   endif

      *  Verify delete in Dakota

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm      '%VERIFYDEL'  $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   if        $drireturn <> '*OK'
     C                   exsr      zm0001s
     C                   eval      $prtn = '*PGMQ'
     C                   goto      bottom
     C                   endif

      *  Delete host record.

     C****               call      'DRICOP'
     C****               parm      '*SLOT'       $dricommand
     C****               parm      '*DELETE'     $drisubcmd
     C****               parm      'H'           $drisys2upd
     C****               parm      #prog         $driprogram
     C****               parm                    $drireturn
     C****               parm                    $drimessage
     C**** $slot         parm      $slot         $dridata

     C****               if        $drireturn <> '*OK'
     C****               exsr      zm0001s
     C****               eval      $prtn = '*PGMQ'
     C****               goto      bottom
     C****               endif

      *  Delete in Dakota.

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm      '%DELETE'     $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   if        $drireturn <> '*OK'
     C                   exsr      zm0001s
     C                   eval      $prtn = '*PGMQ'
     C                   goto      bottom
     C                   endif

     C                   EXSR      zzok

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
     C                   endif
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
     *    DRI0001s Local system caused error (send to different program)
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
     C                   movea     $sldisp       $md(6)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr

     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------

**
Slot
