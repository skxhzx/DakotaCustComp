     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTLT210     Test program LT210
     *  12 December 2003
     *  Dave Sommerville
     *
     *  Revisions:
     *
417 A*    12/12/03  DAS  4.17
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstlt210fmcf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

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
417aAD sub3            s             10
     D warn            s              1
     D whse            s              3  0

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D  $pcmd          s              8
     D  $pprogram      s             10
     D  $ptype         s              3
     D  $phead         s             20
     D  $pwhse         s              3  0
     D  $pitem         s             15
     D  $pitemdsc      s             65
     D  $pwhdp         s              5
     D  $pslot         s             12
     D  $pslotpos      s              3  0
     D  $pempl#        s              5  0
     D  $ptran#        s              7  0
     D  $plic#         s             15
     D  $pqty1         s              5  0
     D  $pqty2         s              3  0
     D  $pqty3         s              3  0
     D  $ppartial      s               n
     D  $ppulled       s              3  0
     D  $preturn       s              8
     D  $perrmsg       s             60
     D  $pmsgid        s              4

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
 1B  C                   select
 1B  C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
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
     C                   if        w1cmd <> '*PUTAWY0'
     C                             and w1cmd <> '*PUTAWY1'
     C                             and w1cmd <> '*PUTAWY2'
     C                             and w1cmd <> '*PULL1'
     C                             and w1cmd <> '*PULL2'
416aAC                   move      *on           error
416aAC                   eval      *in21 = *on
416aAC                   eval      *in01 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   eval      errmsg = 'Invalid Command'
416aAC                   exsr      zm0105
416aAC                   endif
     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   eval      w1cmd  = '*PUTAWY1'
     C                   eval      w1type = 'PUT'
     C                   eval      w1head = 'Test'
     C                   eval      w1whse = 900
     C                   eval      w1item = 'DA101'
     C                   eval      w1itemdsc = 'DA101 - Item DA101'
     C                   eval      w1whdp = 'DRY'
     C                   eval      w1slot = 'DA-101-4'
     C                   eval      w1pos  = 3
     C                   eval      w1empl# = 10
     C                   eval      w1tran# = 1234
     C                   eval      w1lic#  = ' '
     C                   eval      w1qty1 = 50
     C                   eval      w1qty2 = 0
     C                   eval      w1qty3 = 0
     C                   eval      w1part = '0'
     C                   eval      w1pulled = 0
417 A
     C                   eval      w1rtn  = ' '
     C                   eval      w1errmsg  = ' '
     C                   eval      w1errid   = ' '

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

     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update record.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     C                   call      'LT210'
     C                   parm      w1cmd         $pcmd
     C                   parm                    $pprogram
     C                   parm      w1type        $ptype
     C                   parm      w1head        $phead
     C                   parm      w1whse        $pwhse
     C                   parm      w1item        $pitem
     C                   parm      w1itemdsc     $pitemdsc
     C                   parm      w1whdp        $pwhdp
     C                   parm      w1slot        $pslot
     C                   parm      w1pos         $pslotpos
     C                   parm      w1empl#       $pempl#
     C                   parm      w1tran#       $ptran#
     C                   parm      W1lic#        $plic#
     C                   parm      w1qty1        $pqty1
     C                   parm      w1qty2        $pqty2
     C                   parm      w1qty3        $pqty3
     C                   parm      w1part        $ppartial
     C     w1pulled      parm      w1pulled      $ppulled
     C     w1rtn         parm      ' '           $preturn
     C     w1errmsg      parm      ' '           $perrmsg
     C     w1errid       parm      ' '           $pmsgid

     C     endupd        endsr

     *----------------------------------------------------------------
     *  ZZZCLOSE   Close program.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   call      'LT210'
     C                   parm      '*CLOSE'      $pcmd
     C                   parm                    $pprogram
     C                   parm                    $ptype
     C                   parm                    $phead
     C                   parm                    $pwhse
     C                   parm                    $pitem
     C                   parm                    $pitemdsc
     C                   parm                    $pwhdp
     C                   parm                    $pslot
     C                   parm                    $pslotpos
     C                   parm                    $pempl#
     C                   parm                    $ptran#
     C                   parm                    $plic#
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
     C                   parm                    $ppartial
     C                   parm                    $ppulled
     C     w1rtn         parm                    $preturn
     C     w1errmsg      parm                    $perrmsg
     C     w1errid       parm                    $pmsgid

     C                   endsr
