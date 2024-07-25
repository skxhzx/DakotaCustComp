     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TSTSLOTNP    Test *NXT/*PRV subcommands for DRISLOT interface
     *  21 November 2011
     *  Dave Sommerville
     *
     *  Revisions:
     *
416 A*    11/21/01  DAS  4.16
     *      - Created.
     *
416aA*    02/01/02  DAS  4.16a
     *      - Recompiled for new C#SLOT. New fields not used in the pgm.
     *
416bA*    06/11/02  DAS  4.16b
     *      - Recompiled for new C#SLOT.
     *
510aA*    02/24/07  DAS  5.10a
     *      - Added 9=Get Repack.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstslotnp cf   e             workstn
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
     D sub1            s             10
     D sub2            s             10
     D warn            s              1
     D whse            s              3  0

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
 2B  C     nxtscr        caseq     '02 '         sc2
 2B  C     nxtscr        caseq     '03 '         sc2
 2B  C     nxtscr        caseq     '04 '         sc2
 2B  C     nxtscr        caseq     '05 '         sc2
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
 1B  C                   select
 1B  C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
 1B  C                   when      nxtscr = '02 '
     C                   exfmt     screen2                              50
 1B  C                   when      nxtscr = '03 '
     C                   exfmt     screen3                              50
 1B  C                   when      nxtscr = '04 '
     C                   exfmt     screen4                              50
 1B  C                   when      nxtscr = '05 '
     C                   exfmt     screen5                              50
 1E  C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
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
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil2
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil2
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil2
     C     end05i        endsr
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
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     **                   MOVE 'EOJ'     NXTSCR
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   exsr      scr02i
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   exsr      scr01i
goto C                   goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C     endsc2        endsr
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

     *  Verify type

     C                   if        %scan(w1type : '123456789') = 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      $drireturn  = ' '
     C                   eval      $drimessage = 'Invalid type '
     C                                         + '(' + w1type + ')'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
     C                   eval      error = *off

     *  Verify subcommand.

     C                   if        w2scmd <> '1' and w2scmd <> '2' or
     C                             w2scmd = '2' and w1type = '6'   or
     C                             w2scmd = '2' and w1type = '7'   or
     C                             w2scmd = '2' and w1type = '8'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      $drireturn  = ' '
     C                   eval      $drimessage = 'Invalid subcommand '
     C                                         + '(' + w1type + ')'
     C                   exsr      zm0105
     C                   goto      endck2
     C                   endif

     C     endck2        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
     C                   eval      w1type = '1'
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2        begsr

     C                   eval      w2scmd = '1'
     C                   eval      w2whse = 1
     C                   eval      w2whdp = ' '
     C                   eval      w2styp = ' '
     C                   eval      w2stat = 'A'
     C                   eval      w2pick = ' '
     C                   eval      w2item = ' '
     C                   eval      w2slot = ' '
     C                   eval      w2aisl = ' '
     C                   eval      w2loc  = 0
     C                   eval      w2rlvl = 0
     C                   eval      w2hand = ' '
     C                   eval      w2pseq = 0
     C                   eval      w2expd = 0
     C                   eval      w2entd = 0
     C                   eval      w2prty = 0
     C                   eval      w1rtn  = ' '

     C                   endsr

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
     *  ZZUPD1   Update record.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Display next screen.

     C                   select

     C                   when      w1type = '1'
     C                   eval      w2ctxt = '1=*NXTITEM, 2=*PRVITEM'
     C                   eval      sub1 = '*NXTITEM'
     C                   eval      sub2 = '*PRVITEM'
     C                   exsr      scr04i

     C                   when      w1type = '2'
     C                   eval      w2ctxt = '1=*NXTOVRF, 2=*PRVOVRF'
     C                   eval      sub1 = '*NXTOVRF'
     C                   eval      sub2 = '*PRVOVRF'
     C                   exsr      scr04i

     C                   when      w1type = '3'
     C                   eval      w2ctxt = '1=*NXTPICK, 2=*PRVPICK'
     C                   eval      sub1 = '*NXTPICK'
     C                   eval      sub2 = '*PRVPICK'
     C                   exsr      scr04i

     C                   when      w1type = '4'
     C                   eval      w2ctxt = '1=*NXTSLOT, 2=*PRVSLOT'
     C                   eval      sub1 = '*NXTSLOT'
     C                   eval      sub2 = '*PRVSLOT'
     C                   exsr      scr02i

     C                   when      w1type = '5'
     C                   eval      w2ctxt = '1=*NXTSLOTI, 2=*PRVSLOTI'
     C                   eval      sub1 = '*NXTSLOTI'
     C                   eval      sub2 = '*PRVSLOTI'
     C                   exsr      scr03i

     C                   when      w1type = '6'
     C                   eval      w2ctxt = '1=*GET'
     C                   eval      sub1 = '*GET'
     C                   eval      sub2 = ''
     C                   exsr      scr02i

     C                   when      w1type = '7'
     C                   eval      w2ctxt = '1=*GETI'
     C                   eval      sub1 = '*GETI'
     C                   eval      sub2 = ''
     C                   exsr      scr03i

     C                   when      w1type = '8'
     C                   eval      w2ctxt = '1=*GETXDOCK'
     C                   eval      sub1 = '*GETXDOCK'
     C                   eval      sub2 = ''
     C                   exsr      scr05i

     C                   when      w1type = '9'
     C                   eval      w2ctxt = '1=*GETREPACK'
     C                   eval      sub1 = '*GETREPACK'
     C                   eval      sub2 = ''
     C                   exsr      scr05i

     C                   endsl

     C     endupd        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update record.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   eval      error = *off

     *  Initialize interface fields.

     C                   exsr      fill$slot

     *  Dakota verification.

     C                   eval      $dricommand = '*SLOT'
     C                   if        w2scmd = '1'
     C                   eval      $drisubcmd  = sub1
     C                   else
     C                   eval      $drisubcmd  = sub2
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Move data structure fields into screen fields.

     C                   exsr      fill$screen

     C                   endsr

     *----------------------------------------------------------------
     *  fill$screen   Fill screen fields with data structure fields.
     *----------------------------------------------------------------

     C     fill$screen   begsr

     C                   eval      w2whse = $slwhse
     C                   eval      w2item = $slitem
     C                   eval      w2stat = $slstat
     C                   eval      w2pick = $slpick
     C                   eval      w2prty = $slprty
     C                   eval      w2expd = $slexpd
     C                   eval      w2entd = $slentd
     C                   eval      w2whdp = $slwhdp
     C                   eval      w2styp = $slstyp
     C                   eval      w2aisl = $slaisl
     C                   eval      w2loc  = $slloc
     C                   eval      w2pseq = $slpseq
     C                   eval      w2rlvl = $slrlvl
     C                   eval      w2hand = $slhand
     C                   eval      w2slot = $sldisp
     C                   eval      w1rtn  = $drireturn

     C                   endsr

     *----------------------------------------------------------------
     *  fill$slot     Fill $slot data structure fields.
     *----------------------------------------------------------------

     C     fill$slot     begsr

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     *  Move fields from screen to data structure.

     C                   select

     *    Screen 2

     C                   when      nxtscr = '02'

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = w2whse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = w2whdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp = w2slot

     *    Screen 3

     C                   when      nxtscr = '03'

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = w2whse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = w2whdp

     C                   eval      $slaislu = *on
     C                   eval      $slaisl = w2aisl

     C                   eval      $sllocu = *on
     C                   eval      $slloc  = w2loc

     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl = w2rlvl

     C                   eval      $slhandu = *on
     C                   eval      $slhand = w2hand

     *    Screen 4

     C                   when      nxtscr = '04'

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = w2whse

     C                   eval      $slitemu = *on
     C                   eval      $slitem = w2item

     C                   eval      $slstatu = *on
     C                   eval      $slstat = w2stat

     C                   eval      $slpicku = *on
     C                   eval      $slpick = w2pick

     C                   eval      $slprtyu = *on
     C                   eval      $slprty = w2prty

     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = w2expd

     C                   eval      $slentdu = *on
     C                   eval      $slentd = w2entd

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = w2whdp

     C                   eval      $slstypu = *on
     C                   eval      $slstyp = w2styp

     C                   eval      $slaislu = *on
     C                   eval      $slaisl = w2aisl

     C                   eval      $slpsequ = *on
     C                   eval      $slpseq = w2pseq

     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl = w2rlvl

     C                   eval      $slhandu = *on
     C                   eval      $slhand = w2hand

     *    Screen 5

     C                   when      nxtscr = '05'

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = w2whse

     C                   eval      $slitemu = *on
     C                   eval      $slitem = w2item

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  zzzclose     Close interface.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '*CLOSE'

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
     C                   parm      #prog         $driprogram
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

     C                   endsr

     *----------------------------------------------------------------
     *  zzzopen      Open interface.
     *----------------------------------------------------------------

     C     zzzopen       begsr

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '*OPEN'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C     endzzzopen    endsr
