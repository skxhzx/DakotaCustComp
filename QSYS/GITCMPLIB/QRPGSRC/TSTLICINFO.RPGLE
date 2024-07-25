      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTLICINFO   Test DRILICINFO interface
     *  17 May 2004
     *  Dave Sommerville
     *
     *  Revisions:
     *
417 A*    05/17/04  DAS  4.17
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstlicinfocf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICINFO
     D savever#        s                   like($lnver#)

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

     D  $lcode                19     26

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

      /copy qcopysrc,c#pgminfds

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
     C                   eval      #pgmq = #pgm
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

     *  If wanting to simulate call from a Dakota program,
     *    then change the first character of subcommand to a '%'.

416aMC                   eval      w1subcmd = w1type
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

 2B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
 3B  C                   select

     *     Code.

 3X  C                   when      row# >= 12 and row# <=18
     C                   eval      $lcmd = '*LOOKUP '
     C                   call      'LNC900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   select
     C                   when      row# = 12
     C                   eval      w1code1 = $lcode
     C                   when      row# = 13
     C                   eval      w1code2 = $lcode
     C                   when      row# = 14
     C                   eval      w1code3 = $lcode
     C                   when      row# = 15
     C                   eval      w1code4 = $lcode
     C                   when      row# = 16
     C                   eval      w1code5 = $lcode
     C                   when      row# = 17
     C                   eval      w1code6 = $lcode
     C                   when      row# = 18
     C                   eval      w1code7 = $lcode
 4E  C                   endsl
 4E  C                   endif

 3X  C                   other

     *     Cursor not on a valid lookup field.

     C                   move      *on           error
     C                   exsr      zm9905
 3E  C                   endsl
goto C                   goto      endcm1
 2E  C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   eval      w1type = '*ADD'
     C                   eval      w1dkta = 'Y'
     C                   eval      w1whse = 1
     C                   eval      w1ltyp = 'P'
     C                   eval      w1lcns = ' '

     C                   eval      wscode1 = 'Y'
     C                   eval      w1code1 = ' '
     C                   eval      w1vtyp1 = ' '
     C                   eval      w1valc1 = ' '
     C                   eval      w1valn1 = 0

     C                   eval      wscode2 = 'N'
     C                   eval      w1code2 = ' '
     C                   eval      w1vtyp2 = ' '
     C                   eval      w1valc2 = ' '
     C                   eval      w1valn2 = 0

     C                   eval      wscode3 = 'N'
     C                   eval      w1code3 = ' '
     C                   eval      w1vtyp3 = ' '
     C                   eval      w1valc3 = ' '
     C                   eval      w1valn3 = 0

     C                   eval      wscode4 = 'N'
     C                   eval      w1code4 = ' '
     C                   eval      w1vtyp4 = ' '
     C                   eval      w1valc4 = ' '
     C                   eval      w1valn4 = 0

     C                   eval      wscode5 = 'N'
     C                   eval      w1code5 = ' '
     C                   eval      w1vtyp5 = ' '
     C                   eval      w1valc5 = ' '
     C                   eval      w1valn5 = 0

     C                   eval      wscode6 = 'N'
     C                   eval      w1code6 = ' '
     C                   eval      w1vtyp6 = ' '
     C                   eval      w1valc6 = ' '
     C                   eval      w1valn6 = 0

     C                   eval      wscode7 = 'N'
     C                   eval      w1code7 = ' '
     C                   eval      w1vtyp7 = ' '
     C                   eval      w1valc7 = ' '
     C                   eval      w1valn7 = 0

     C                   eval      w1rtn  = ' '
     C                   eval      w1msg  = ' '

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

     C                   exsr      clr$licinfo

     C                   eval      $lnemp# = 10
     C                   eval      $lnuser = #user
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   eval      $lnwhse = w1whse
     C                   eval      $lntype = w1ltyp
     C                   eval      $lnlcns = w1lcns

     C                   if        wscode1 = 'Y'
     C                   eval      $lncodeu(1) = *on
     C                   endif
     C                   eval      $lncode(1) = w1code1
     C                   eval      $lncseq(1) = w1cseq1
     C                   eval      $lnvaltyp(1) = w1vtyp1
     C                   eval      $lnvalchr(1) = w1valc1
     C                   eval      $lnvalnum(1) = w1valn1

     C                   if        wscode2 = 'Y'
     C                   eval      $lncodeu(2) = *on
     C                   endif
     C                   eval      $lncode(2) = w1code2
     C                   eval      $lncseq(2) = w1cseq2
     C                   eval      $lnvaltyp(2) = w1vtyp2
     C                   eval      $lnvalchr(2) = w1valc2
     C                   eval      $lnvalnum(2) = w1valn2

     C                   if        wscode3 = 'Y'
     C                   eval      $lncodeu(3) = *on
     C                   endif
     C                   eval      $lncode(3) = w1code3
     C                   eval      $lncseq(3) = w1cseq3
     C                   eval      $lnvaltyp(3) = w1vtyp3
     C                   eval      $lnvalchr(3) = w1valc3
     C                   eval      $lnvalnum(3) = w1valn3

     C                   if        wscode4 = 'Y'
     C                   eval      $lncodeu(4) = *on
     C                   endif
     C                   eval      $lncode(4) = w1code4
     C                   eval      $lncseq(4) = w1cseq4
     C                   eval      $lnvaltyp(4) = w1vtyp4
     C                   eval      $lnvalchr(4) = w1valc4
     C                   eval      $lnvalnum(4) = w1valn4

     C                   if        wscode5 = 'Y'
     C                   eval      $lncodeu(5) = *on
     C                   endif
     C                   eval      $lncode(5) = w1code5
     C                   eval      $lncseq(5) = w1cseq5
     C                   eval      $lnvaltyp(5) = w1vtyp5
     C                   eval      $lnvalchr(5) = w1valc5
     C                   eval      $lnvalnum(5) = w1valn5

     C                   if        wscode6 = 'Y'
     C                   eval      $lncodeu(6) = *on
     C                   endif
     C                   eval      $lncode(6) = w1code6
     C                   eval      $lncseq(6) = w1cseq6
     C                   eval      $lnvaltyp(6) = w1vtyp6
     C                   eval      $lnvalchr(6) = w1valc6
     C                   eval      $lnvalnum(6) = w1valn6

     C                   if        wscode7 = 'Y'
     C                   eval      $lncodeu(7) = *on
     C                   endif
     C                   eval      $lncode(7) = w1code7
     C                   eval      $lncseq(7) = w1cseq7
     C                   eval      $lnvaltyp(7) = w1vtyp7
     C                   eval      $lnvalchr(7) = w1valc7
     C                   eval      $lnvalnum(7) = w1valn7

     *  Set system we are calling from

     C                   if        w1dkta = 'Y'
     C                   eval      $drisys2upd = 'D'
     C                   else
     C                   eval      $drisys2upd = 'H'
     C                   endif

     *  Call interface.

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = w1subcmd
     C                   exsr      zzzdricop

     *  Move return code to output field.

     C                   eval      w1code1 = $lncode(1)
     C                   eval      w1cseq1 = $lncseq(1)
     C                   eval      w1vtyp1 = $lnvaltyp(1)
     C                   eval      w1valc1 = $lnvalchr(1)
     C                   eval      w1valn1 = $lnvalnum(1)

     C                   eval      w1code2 = $lncode(2)
     C                   eval      w1cseq2 = $lncseq(2)
     C                   eval      w1vtyp2 = $lnvaltyp(2)
     C                   eval      w1valc2 = $lnvalchr(2)
     C                   eval      w1valn2 = $lnvalnum(2)

     C                   eval      w1code3 = $lncode(3)
     C                   eval      w1cseq3 = $lncseq(3)
     C                   eval      w1vtyp3 = $lnvaltyp(3)
     C                   eval      w1valc3 = $lnvalchr(3)
     C                   eval      w1valn3 = $lnvalnum(3)

     C                   eval      w1code4 = $lncode(4)
     C                   eval      w1cseq4 = $lncseq(4)
     C                   eval      w1vtyp4 = $lnvaltyp(4)
     C                   eval      w1valc4 = $lnvalchr(4)
     C                   eval      w1valn4 = $lnvalnum(4)

     C                   eval      w1code5 = $lncode(5)
     C                   eval      w1cseq5 = $lncseq(5)
     C                   eval      w1vtyp5 = $lnvaltyp(5)
     C                   eval      w1valc5 = $lnvalchr(5)
     C                   eval      w1valn5 = $lnvalnum(5)

     C                   eval      w1code6 = $lncode(6)
     C                   eval      w1cseq6 = $lncseq(6)
     C                   eval      w1vtyp6 = $lnvaltyp(6)
     C                   eval      w1valc6 = $lnvalchr(6)
     C                   eval      w1valn6 = $lnvalnum(6)

     C                   eval      w1code7 = $lncode(7)
     C                   eval      w1cseq7 = $lncseq(7)
     C                   eval      w1vtyp7 = $lnvaltyp(7)
     C                   eval      w1valc7 = $lnvalchr(7)
     C                   eval      w1valn7 = $lnvalnum(7)

     C                   eval      w1rtn = $drireturn
     C                   eval      w1msg = $drimessage

     C     endupd        endsr

     *----------------------------------------------------------------
     *  clr$licinfo   Clear $licinfo data structure.
     *----------------------------------------------------------------

     C     clr$licinfo   begsr

     *  Initialize data structure

     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   endsr

     *----------------------------------------------------------------
     *  zzzclose     Close interface.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   eval      $dricommand = '*LICINFO'
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
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $licinfo      parm      $licinfo      $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
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

     C                   if        $lnwhsee = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $lntypee = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $lnlcnse = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $lncodee(1) = '1'
     C                   eval      *in31 = *on
     C                   endif

     C                   if        $lncodee(2) = '1'
     C                   eval      *in36 = *on
     C                   endif

     C                   if        $lncodee(3) = '1'
     C                   eval      *in41 = *on
     C                   endif

     C                   if        $lncodee(4) = '1'
     C                   eval      *in46 = *on
     C                   endif

     C                   if        $lncodee(5) = '1'
     C                   eval      *in51 = *on
     C                   endif

     C                   if        $lncodee(6) = '1'
     C                   eval      *in56 = *on
     C                   endif

     C                   if        $lncodee(7) = '1'
     C                   eval      *in61 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzzopen      Open interface.
     *----------------------------------------------------------------

     C     zzzopen       begsr

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%OPEN'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C     endzzzopen    endsr
