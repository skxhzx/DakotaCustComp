      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTTAGFMT    Test Print Clam Tag labels
     *  26 December 2005
     *  Jeffrey Jahnke
     *
     *  Revisions:
     *
500 A*    12/26/05  JCJ  5.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftsttagfmtfcf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

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

     D $phdte          s              8  0
     D $plbl#          s              7  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D clear           s              5  0
     D comand          s              5  0
     D enter           s              5  0
     D help            s              5  0
     D $pseq           s              5  0
     D $pqty           s              5  0
     D msgk            s              4  0
     D whse            s              3  0
     D $pwhse          s              3  0
     D e               s              2  0
     D $itdesc         s             30
     D $phloc          s             20
     D $pcert          s             20
     D $pitem          s             15
     D $plic           s             15
     D $msgf           s             10
     D #pgmq           s             10
     D $pprt           s             10
     D $pform          s             10
     D $ppo            s              9
     D $prtn           s              8
     D $pcmd           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D nxtscr          s              3
     D ovrrid          s              1
     D sclear          s              1
     D warn            s              1
     D cmdtkn          s              1
     D error           s               n

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
     *  Parameters
     *----------------------------------------------------------------

     C     tagfmtP       plist
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $ppo
     C                   parm                    $pseq
     C                   parm                    $pitem
     C                   parm                    $itdesc
     C                   parm                    $plic
     C                   parm                    $pqty
     C                   parm                    $phdte
     C                   parm                    $phloc
     C                   parm                    $pcert
     C                   parm                    $plbl#
     C                   parm                    $pprt
     C                   parm                    $pform

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
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
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
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc1
     C                   endif
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
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
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
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
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
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
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

     C                   eval      w1cmd  = *blanks
     C                   eval      w1whse = *zeros
     C                   eval      w1po   = *blanks
     C                   eval      w1seq  = *zeros
     C                   eval      w1item = *blanks
     C                   eval      w1desc = '123456 Item Desc'
     C                   eval      w1lic  = *blanks
     C                   eval      w1qty  = 5
     C                   eval      w1hdte = 20051220
     C                   eval      w1hloc = 'LOC123'
     C                   eval      w1cert = 'CERT#123'
     C                   eval      w1lbl# = *Zeros
     C                   eval      w1prt  = '*JOB'
     C                   eval      w1form = '*STD'

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

     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   eval      error = *off

     C                   eval      $pcmd  = w1cmd
     C                   eval      $pwhse = w1whse
     C                   eval      $ppo   = w1po
     C                   eval      $pseq  = w1seq
     C                   eval      $pitem = w1item
     C                   eval      $itdesc= w1desc
     C                   eval      $plic  = w1lic
     C                   eval      $pqty  = w1qty
     C                   eval      $phdte = w1hdte
     C                   eval      $phloc = w1hloc
     C                   eval      $pcert = w1cert
     C                   eval      $plbl# = w1lbl#
     C                   eval      $pprt  = w1prt
     C                   eval      $pform = w1form

     C                   call      'TAGFMT'      tagfmtP

     C     endupd        endsr
