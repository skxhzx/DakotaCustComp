     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TSTORD    Test DRIORI interface
     *  18 May 2002
     *  Dave Sommerville
     *
     *  Revisions:
     *
416 A*    05/18/02  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstord    cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ORDH
      /COPY *libl/qcopysrc,C#ORDD
     D savever#        s                   like($ohver#)

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
     D prefix          s              1
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
 2B  C     nxtscr        caseq     '03 '         sc3
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
     C                   exsr      zzfil3
     C     end03i        endsr
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
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   exsr      scr03i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   exsr      scr01i
goto C                   goto      endsc3
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C     endsc3        endsr
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

     C                   if        %scan(w1type : '12') = 0
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

     C                   if        w2scmd <> 1 and
     C                             w2scmd <> 2 and
     C                             w2scmd <> 3 and
     C                             w2scmd <> 4 and
     C                             w2scmd <> 11 and
     C                             w2scmd <> 12 and
     C                             w2scmd <> 14
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
     *  ZZCHK3   Screen 3 error checking.
     *----------------------------------------------------------------

     C     zzchk3        begsr
     C                   eval      error = *off

     *  Verify subcommand.

     C                   if        w3scmd <> 1 and
     C                             w3scmd <> 2 and
     C                             w3scmd <> 3 and
     C                             w3scmd <> 4
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      $drireturn  = ' '
     C                   eval      $drimessage = 'Invalid subcommand '
     C                                         + '(' + w1type + ')'
     C                   exsr      zm0105
     C                   goto      endck3
     C                   endif

     C     endck3        endsr

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
     *  ZZCMD3   User defined command keys for screen 3.
     *----------------------------------------------------------------

     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
     C     endcm3        endsr

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

     C                   eval      w2scmd = 1
     C                   eval      w2dkta = 'Y'
     C                   eval      S2whse = 'Y'
     C                   eval      w2whse = 1
     C                   eval      S2oid  = 'Y'
     C                   eval      w2oid  = 0
     C                   eval      S2rid  = 'Y'
     C                   eval      w2rid  = ' '
     C                   eval      S2type = 'Y'
     C                   eval      w2type = ' '
     C                   eval      S2cord = 'Y'
     C                   eval      w2cord = 0
     C                   eval      S2rte  = 'Y'
     C                   eval      w2rte  = ' '
     C                   eval      w2pgm  = ' '
     C                   eval      w2rtn  = ' '

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil3        begsr

     C                   eval      w3scmd = 1
     C                   eval      w3dkta = 'Y'
     C                   eval      S3whse = 'Y'
     C                   eval      w3whse = 1
     C                   eval      S3oid  = 'Y'
     C                   eval      w3oid  = 0
     C                   eval      S3seq  = 'Y'
     C                   eval      w3seq  = 0
     C                   eval      S3item = 'Y'
     C                   eval      w3item = ' '
     C                   eval      S3oqty = 'Y'
     C                   eval      w3oq1  = 0
     C                   eval      w3oq2  = 0
     C                   eval      w3oq3  = 0
     C                   eval      S3pqty = 'Y'
     C                   eval      w3pq1  = 0
     C                   eval      w3pq2  = 0
     C                   eval      w3pq3  = 0
     C                   eval      w3pgm  = ' '
     C                   eval      w3rtn  = ' '

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
     C                   exsr      scr02i

     C                   when      w1type = '2'
     C                   exsr      scr03i

     C                   endsl

     C     endupd        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update record.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   eval      error = *off

     *  Initialize interface fields.

     C                   exsr      fill$ordh

     *  Dakota verification.

     C                   eval      $dricommand = '*ORDHDR'

     C                   if        w2dkta = 'Y'
     C                   eval      prefix = '%'
     C                   else
     C                   eval      prefix = '*'
     C                   endif

     C                   select

     C                   when      w2scmd = 1
     C                   eval      $drisubcmd  = prefix + 'CRTRTE'

     C                   when      w2scmd = 2
     C                   eval      $drisubcmd  = prefix + 'ADDHDR'

     C                   when      w2scmd = 3
     C                   eval      $drisubcmd  = prefix + 'CHGHDR'

     C                   when      w2scmd = 4
     C                   eval      $drisubcmd  = prefix + 'DELORD'

     C                   when      w2scmd = 11
     C                   eval      $drisubcmd  = prefix + 'GETHDR'

     C                   when      w2scmd = 12
     C                   eval      $drisubcmd  = prefix + 'GETHDRWCO'

     C                   when      w2scmd = 14
     C                   eval      $drisubcmd  = prefix + 'DELRTE'

     C                   endsl

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Move data structure fields into screen fields.

     C                   exsr      fill$screen2

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD3   Update record.
     *----------------------------------------------------------------

     C     zzupd3        begsr
     C                   eval      error = *off

     *  Initialize interface fields.

     C                   exsr      fill$ordd

     *  Dakota verification.

     C                   eval      $dricommand = '*ORDDTL'

     C                   if        w3dkta = 'Y'
     C                   eval      prefix = '%'
     C                   else
     C                   eval      prefix = '*'
     C                   endif

     C                   select

     C                   when      w3scmd = 1
     C                   eval      $drisubcmd  = prefix + 'GETDTL'

     C                   when      w3scmd = 2
     C                   eval      $drisubcmd  = prefix + 'ADDDTL'

     C                   when      w3scmd = 3
     C                   eval      $drisubcmd  = prefix + 'CHGDTL'

     C                   when      w3scmd = 4
     C                   eval      $drisubcmd  = prefix + 'DELDTL'

     C                   endsl

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Move data structure fields into screen fields.

     C                   exsr      fill$screen3

     C                   endsr

     *----------------------------------------------------------------
     *  fill$screen2   Fill screen fields with data structure fields.
     *----------------------------------------------------------------

     C     fill$screen2  begsr

     C                   eval      w2whse = $ohwhse
     C                   eval      w2oid  = $ohoid
     C                   eval      w2rid  = $ohrid
     C                   eval      w2type = $ohtype
     C                   eval      w2cord = $ohcord
     C                   eval      w2rte  = $ohrte
     C                   eval      w2rtn  = $drireturn

     C                   endsr

     *----------------------------------------------------------------
     *  fill$screen3   Fill screen fields with data structure fields.
     *----------------------------------------------------------------

     C     fill$screen3  begsr

     C                   eval      w3whse = $odwhse
     C                   eval      w3oid  = $odoid
     C                   eval      w3seq  = $odseq
     C                   eval      w3item = $oditem
     C                   eval      w3oq1  = $odqor1
     C                   eval      w3oq2  = $odqor2
     C                   eval      w3oq3  = $odqor3
     C                   eval      w3pq1  = $odqpk1
     C                   eval      w3pq2  = $odqpk2
     C                   eval      w3pq3  = $odqpk3
     C                   eval      w3rtn  = $drireturn

     C                   endsr

     *----------------------------------------------------------------
     *  fill$ordh     Fill $ordh data structure fields.
     *----------------------------------------------------------------

     C     fill$ordh     begsr

     *  Initialize data structure

     C                   eval      savever# = $ohver#
     C                   clear                   $ordh
     C                   eval      $ohver# = savever#

     *  Move fields from screen to data structure.

     C                   if        s2whse = 'Y'
     C                   eval      $ohwhseu = *on
     C                   else
     C                   eval      $ohwhseu = *off
     C                   endif
     C                   eval      $ohwhse = w2whse

     C                   if        s2oid  = 'Y'
     C                   eval      $ohoidu  = *on
     C                   else
     C                   eval      $ohoidu  = *off
     C                   endif
     C                   eval      $ohoid  = w2oid

     C                   if        s2rid  = 'Y'
     C                   eval      $ohridu  = *on
     C                   else
     C                   eval      $ohridu  = *off
     C                   endif
     C                   eval      $ohrid  = w2rid

     C                   if        s2type = 'Y'
     C                   eval      $ohtypeu = *on
     C                   else
     C                   eval      $ohtypeu = *off
     C                   endif
     C                   eval      $ohtype = w2type

     C                   if        s2cord = 'Y'
     C                   eval      $ohcordu = *on
     C                   else
     C                   eval      $ohcordu = *off
     C                   endif
     C                   eval      $ohcord = w2cord

     C                   if        s2rte  = 'Y'
     C                   eval      $ohrteu  = *on
     C                   else
     C                   eval      $ohrteu  = *off
     C                   endif
     C                   eval      $ohrte  = w2rte

     C                   endsr

     *----------------------------------------------------------------
     *  fill$ordd     Fill $ordd data structure fields.
     *----------------------------------------------------------------

     C     fill$ordd     begsr

     *  Initialize data structure

     C                   eval      savever# = $odver#
     C                   clear                   $ordd
     C                   eval      $odver# = savever#

     *  Move fields from screen to data structure.

     C                   if        s3whse = 'Y'
     C                   eval      $odwhseu = *on
     C                   else
     C                   eval      $odwhseu = *off
     C                   endif
     C                   eval      $odwhse = w3whse

     C                   if        s3oid  = 'Y'
     C                   eval      $odoidu  = *on
     C                   else
     C                   eval      $odoidu  = *off
     C                   endif
     C                   eval      $odoid  = w3oid

     C                   if        s3seq  = 'Y'
     C                   eval      $odsequ  = *on
     C                   else
     C                   eval      $odsequ  = *off
     C                   endif
     C                   eval      $odseq  = w3seq

     C                   if        s3item = 'Y'
     C                   eval      $oditemu = *on
     C                   else
     C                   eval      $oditemu = *off
     C                   endif
     C                   eval      $oditem = w3item

     C                   if        s3oqty = 'Y'
     C                   eval      $odqor1u = *on
     C                   eval      $odqor2u = *on
     C                   eval      $odqor3u = *on
     C                   else
     C                   eval      $odqor1u = *off
     C                   eval      $odqor2u = *off
     C                   eval      $odqor3u = *off
     C                   endif
     C                   eval      $odqor1 = w3oq1
     C                   eval      $odqor2 = w3oq2
     C                   eval      $odqor3 = w3oq3

     C                   if        s3pqty = 'Y'
     C                   eval      $odqpk1u = *on
     C                   eval      $odqpk2u = *on
     C                   eval      $odqpk3u = *on
     C                   else
     C                   eval      $odqpk1u = *off
     C                   eval      $odqpk2u = *off
     C                   eval      $odqpk3u = *off
     C                   endif
     C                   eval      $odqpk1 = w3pq1
     C                   eval      $odqpk2 = w3pq2
     C                   eval      $odqpk3 = w3pq3

     C                   endsr

     *----------------------------------------------------------------
     *  zzzclose     Close interface.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   eval      $dricommand = '*ORDHDR'
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

     C                   if        $dricommand = '*ORDHDR'
     C                   eval      $dridata = $ordh
     C                   else
     C                   eval      $dridata = $ordd
     C                   endif

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   if        $dricommand = '*ORDHDR'
     C                   eval      $ordh = $dridata
     C                   else
     C                   eval      $ordd = $dridata
     C                   endif

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

     C                   select
     C                   when      nxtscr = '02'
     C                   eval      *in02 = $ohwhsee
     C                   eval      *in22 = $ohwhsee
     C                   eval      *in03 = $ohoide
     C                   eval      *in23 = $ohoide
     C                   eval      *in04 = $ohride
     C                   eval      *in24 = $ohride
     C                   eval      *in05 = $ohtypee
     C                   eval      *in25 = $ohtypee
     C                   eval      *in06 = $ohcorde
     C                   eval      *in26 = $ohcorde
     C                   eval      *in07 = $ohrtee
     C                   eval      *in27 = $ohrtee
     C                   other
     C                   eval      *in02 = $odwhsee
     C                   eval      *in22 = $odwhsee
     C                   eval      *in03 = $odoide
     C                   eval      *in23 = $odoide
     C                   eval      *in04 = $odseqe
     C                   eval      *in24 = $odseqe
     C                   eval      *in05 = $oditeme
     C                   eval      *in25 = $oditeme
     C                   eval      *in06 = $odqor1e
     C                   eval      *in26 = $odqor1e
     C                   eval      *in07 = $odqor2e
     C                   eval      *in27 = $odqor2e
     C                   eval      *in08 = $odqor3e
     C                   eval      *in28 = $odqor3e
     C                   eval      *in09 = $odqpk1e
     C                   eval      *in29 = $odqpk1e
     C                   eval      *in10 = $odqpk2e
     C                   eval      *in30 = $odqpk2e
     C                   eval      *in11 = $odqpk3e
     C                   eval      *in31 = $odqpk3e
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  zzzopen      Open interface.
     *----------------------------------------------------------------

     C     zzzopen       begsr

     C                   eval      $dricommand = '*ORDHDR'
     C                   eval      $drisubcmd  = '*OPEN'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C     endzzzopen    endsr
