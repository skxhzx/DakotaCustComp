      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CRTVPICK  Create virtual slot
     *  19 April 2005
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    04/19/05  DAS  5.00
     *      - Created.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
650 A*    11/08/13  RH/DAS 6.50
     *      - Was missing from current libraries.
     *      - Used in PO132 and PO137 for Jordano's only.
     *
     *----------------------------------------------------------------

500dA*----------------------------------------------------------------
500dA*  DRI parameters
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#DRIPARMS
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#SLOT
500dAD saveVer#        s                   like($slver#)
414 A
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D chk4err         s               n
     D e               s              2  0
     D error           s               n
     D msgk            s              4  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   Calling program
     *      $PWHSE  Warehouse
     *      $PWHDP  Department
     *      $PSLOT  Base slot
     *      $PITEM  Item number
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pslot           12
     C                   parm                    $pitem           15
     C                   parm                    $prtn            10
     C                   parm                    $perm            60

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
414 A
500dAC                   exsr      clr$slot
416fAC                   eval      $slwhseu = *on
416fAC                   eval      $slwhse  = $pwhse
416fAC                   eval      $slwhdpu = *on
416fAC                   eval      $slwhdp  = $pwhdp
416fAC                   eval      $sldispu = *on
416fAC                   eval      $sldisp  = $pslot
416fAC                   eval      $slitemu = *on
416fAC                   eval      $slitem  = $pitem
416fAC                   eval      $dricommand = '*SLOT'
416fAC                   eval      $drisubcmd = '%CRTVPICK'
     C                   eval      $drisys2upd = 'D'
416fAC                   eval      chk4err = *on
416fAC                   exsr      zzzdricop

416fAC                   eval      $prtn = $drireturn
416fAC                   eval      $perm = $drimessage

     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *---------------------------------------------------------------
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
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
     C                   eval      $perm = #msgk
     C                   eval      $prtn = $drireturn
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105s Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $perm = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------
500dA*                     DRI SUBROUTINES
500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------

500dA*----------------------------------------------------------------
500dA*  clr$slot  Clear $slot data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdriclose   Close any open files or programs.
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdricop  Call DRICOP
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $slot

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C***                exsr      zm0105s

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C***                exsr      zm0001s

     C                   endsl

     C                   eval      $slot = $dridata

     C     enddricop     endsr
