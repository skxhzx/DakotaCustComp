     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TSTSLOTQTY   Test DRISLOT quantity interface
     *  26 December 2001
     *  Dave Sommerville
     *
     *  Revisions:
     *
416 A*    12/26/01  DAS  4.16
     *      - Created.
     *
416aA*    01/30/02  DAS  4.16a
     *      - Added "Dakota call" field.
     *      - Added "Send" fields
     *      - Added Status, Exp Date, Priority and Program fields.
     *
416bA*    03/13/02  DAS  4.16b
     *      - Removed line with %char. %char not valid until V4R4.
     *
416cA*    06/11/02  DAS  4.16c
     *      - Recompiled for new C#SLOT.
     *
600aA*    10/22/08  DAS  6.00a
     *      - Added new commands.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstslotqtycf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $prtn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D whse            s              3  0
     D w1subcmd        s                   like($drisubcmd)

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $lcode                19     20

     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $ldisp                27     38
     D  $litem                39     53

     D  $lwhse2               19     21  0
     D  $litem2               22     36
     D  $lxflg2               37     37

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

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
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

     *  Close interface

     C                   exsr      zzzclose

     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       13
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   exsr      scr01i
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     **                   MOVE 'EOJ'     NXTSCR
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      *blanks       #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        $drisys2upd = 'D'
     C                   eval      #msgid = 'DRI0001'
     C                   else
     C                   eval      #msgid = 'DRI0002'
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify adjustment type options.

     *    Note: This is check in this program because it is not a field
     *          that is stored in the file and thus is not sent to the
     *          interface program.

600aMC                   if        w1type < 0 or w1type > 20
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      $drireturn  = ' '
     C                   eval      $drimessage = 'Invalid adjustment type '
416bAC***                                      + '(' + %char(w1type) + ')'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Expand subcommand.

416aAC                   select
416aAC                   when      w1type = 1
416aAC                   eval      w1subcmd  = '*ADJUST'
416aAC                   when      w1type = 2
416aAC                   eval      w1subcmd  = '*STOCK'
416aAC                   when      w1type = 3
416aAC                   eval      w1subcmd  = '*RECEIVE'
416aAC                   when      w1type = 4
416aAC                   eval      w1subcmd  = '*ALLOCATE'
416aAC                   when      w1type = 5
416aAC                   eval      w1subcmd  = '*PICK'
416aAC                   when      w1type =  6
416aAC                   eval      w1subcmd  = '*TFROUT'
416aAC                   when      w1type =  7
416aAC                   eval      w1subcmd  = '*TFRIN'
416aAC                   when      w1type = 8
416aAC                   eval      w1subcmd  = '*ADJUSTORD'
416aAC                   when      w1type = 9
416aAC                   eval      w1subcmd  = '*ALC2PCK'
416aAC                   when      w1type = 10
416aAC                   eval      w1subcmd  = '*PCK2ALC'
416aAC                   when      w1type = 11
416aAC                   eval      w1subcmd  = '*CLSRCV'
416aAC                   when      w1type = 12
416aAC                   eval      w1subcmd  = '*CLSPICK'
416aAC                   when      w1type = 13
416aAC                   eval      w1subcmd  = '*CLSTFROUT'
416aAC                   when      w1type = 14
416aAC                   eval      w1subcmd  = '*CLSTFRIN'
600aAC                   when      w1type = 15
600aAC                   eval      w1subcmd  = '*RCVIN'
600aAC                   when      w1type = 16
600aAC                   eval      w1subcmd  = '*RCVOUT'
600aAC                   when      w1type = 17
600aAC                   eval      w1subcmd  = '*STGIN'
600aAC                   when      w1type = 18
600aAC                   eval      w1subcmd  = '*STGOUT'
600aAC                   when      w1type = 19
600aAC                   eval      w1subcmd  = '*USRIN'
600aAC                   when      w1type = 20
600aAC                   eval      w1subcmd  = '*USROUT'
416aMC                   endsl

     *  If wanting to simulate call from a Dakota program,
     *    then change the first character of subcommand to a '%'.

416aMC                   if        w1dkta = 'Y'
416aMC                   eval      %subst(w1subcmd:1:1) = '%'
416aMC                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off

     *  Test for F4 - Lookup

 1B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

 2B  C                   select

     *     Adjustment code.

416aMC                   when      row# = 7
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lcode = w1code
     C                   call      'AD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
 3E  C                   endif

     *     Warehouse

416aMC                   when      row# = 8
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
 3E  C                   endif

     *     Warehouse department

416aMC                   when      row# = 9
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
 3E  C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
 2X  C                   other
     C                   move      *on           error
     C                   exsr      zm9905
 2E  C                   endsl
goto Csr                 goto      endcm1
 1E  C                   endif
416aA
416aA*      F8 - View whse quantities.
416aA
416aAC                   if        *inkh
416aAC                   move      *on           cmdtkn
416aAC                   z-add     w1whse        whse
416aAC                   call      'IT810'
416aAC                   parm                    whse
416aAC                   parm                    w1item
416aAC                   endif

     *      F9 - View slot quantities.

 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   z-add     w1whse        whse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    w1whdp
     C                   parm                    w1slot
 1E  C                   endif

     *      F10 - View slot info.

 1B  C                   if        *inkj
     C                   move      *on           cmdtkn
     C                   eval      $lcmd  = '*VIEW'
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $ldisp = w1slot
     C                   eval      $litem = w1item
     C                   call      'IT135'
     C                   parm                    $lparm
 1E  C                   endif

     *      F11 - View item info.

 1B  C                   if        *inkk
     C                   move      *on           cmdtkn
     C                   eval      $lcmd  = '*VIEW'
     C                   eval      $lwhse2 = w1whse
     C                   eval      $litem2 = w1item
     C                   eval      $lxflg2 = '0'
     C                   call      'IT112'
     C                   parm                    $lparm
 1E  C                   endif

     *      F13 - View priority replenishments

 1B  C                   if        *inkm
     C                   move      *on           cmdtkn
     C                   call      'PR110CL'
 1E  C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   eval      w1type = 1
     C                   eval      w1dkta = 'Y'
     C                   eval      w1code = ' '
     C                   eval      w1whse = 1
     C                   eval      w1whdp = ' '
     C                   eval      w1slot = ' '
     C                   eval      w1item = ' '
     C                   eval      w1stat = ' '
     C                   eval      w1qty1 = 0
     C                   eval      w1qty2 = 0
     C                   eval      w1qty3 = 0
     C                   eval      w1org1 = 0
     C                   eval      w1org2 = 0
     C                   eval      w1org3 = 0
     C                   eval      w1cwta = 0
     C                   eval      w1memo = ' '
     C                   eval      w1rtn  = ' '
     C                   eval      w1pgm  = #prog
     C                   eval      w1expd = 0
     C                   eval      w1prty = 0

     C                   eval      wscode = 'Y'
     C                   eval      wswhse = 'Y'
     C                   eval      wswhdp = 'Y'
     C                   eval      wsdisp = 'Y'
     C                   eval      wsitem = 'Y'
     C                   eval      wsstat = 'Y'
     C                   eval      wsqty  = 'Y'
     C                   eval      wsorg  = 'Y'
     C                   eval      wscwta = 'Y'
     C                   eval      wsmemo = 'Y'
     C                   eval      wsexpd = 'Y'
     C                   eval      wsprty = 'Y'

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr
     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *  Open interface

     C                   exsr      zzzopen
     C                   if        error
     C                   goto      endinz2
     C                   endif

     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   eval      error = *off

     *  Initialize interface fields.

     C                   exsr      fill$slotqty

     *  Set system we are calling from

     C                   if        w1dkta = 'Y'
     C                   eval      $drisys2upd = 'D'
     C                   else
     C                   eval      $drisys2upd = 'D'
     C                   endif

     *  Update Host.

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = w1subcmd
     C                   exsr      zzzdricop

     *  Move return code to output field.

     C                   eval      w1whse = $slwhse
     C                   eval      w1whdp = $slwhdp
     C                   eval      w1slot = $sldisp
     C                   eval      w1stat = $slstat
     C                   eval      w1expd = $slexpd
     C                   eval      w1prty = $slprty
     C                   eval      w1item = $slitem
     C                   eval      w1qty1 = $saqty1
     C                   eval      w1qty2 = $saqty2
     C                   eval      w1qty3 = $saqty3
     C                   eval      w1org1 = $saorg1
     C                   eval      w1org2 = $saorg2
     C                   eval      w1org3 = $saorg3
     C                   eval      w1rtn = $drireturn

     C     endupd        endsr

     *----------------------------------------------------------------
     *  fill$slotqty  Fill $slot data structure fields.
     *----------------------------------------------------------------

     C     fill$slotqty  begsr

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     *  Move fields from screen to data structure.

     C                   if        wswhse = 'Y'
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   endif

     C                   if        wswhdp = 'Y'
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1whdp
     C                   endif

     C                   if        wsdisp = 'Y'
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1slot
     C                   endif

     C                   if        wsstat = 'Y'
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = w1stat
     C                   endif

     C                   if        wsexpd = 'Y'
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = w1expd
     C                   endif

     C                   if        wsprty = 'Y'
     C                   eval      $slprtyu = *on
     C                   eval      $slprty  = w1prty
     C                   endif

     C                   if        wsitem = 'Y'
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1item
     C                   endif

     C                   if        wsqty  = 'Y'
     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = w1qty1
     C                   eval      $saqty2  = w1qty2
     C                   eval      $saqty3  = w1qty3
     C                   endif

     C                   if        wsorg  = 'Y'
     C                   eval      $saorgu  = *on
     C                   eval      $saorg1  = w1org1
     C                   eval      $saorg2  = w1org2
     C                   eval      $saorg3  = w1org3
     C                   endif

     C                   if        wscwta = 'Y'
     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = w1cwta
     C                   endif

     C                   if        wscode = 'Y'
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = w1code
     C                   endif

     C                   if        wsmemo = 'Y'
     C                   eval      $samemou = *on
     C                   eval      $samemo  = w1memo
     C                   endif

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user

     C                   endsr

     *----------------------------------------------------------------
     *  zzzclose     Close interface.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*CLOSE'
     C                   exsr      zzzdricop

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
     C                   parm      w1pgm         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $slot         parm      $slot         $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C                   exsr      zzzerrind

     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzzerrind     begsr

     C                   if        $sacodee = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $slwhsee = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $slwhdpe = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $sldispe = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $saiteme = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif

     C                   if        $saqty2e = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $saqty3e = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $saorg1e = '1'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif

     C                   if        $saorg2e = '1'
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   endif

     C                   if        $saorg3e = '1'
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   endif

     C                   if        $sacwtae = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   endif

     C                   if        $slprtye = '1'
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzzopen      Open interface.
     *----------------------------------------------------------------

     C     zzzopen       begsr

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OPEN'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C     endzzzopen    endsr
