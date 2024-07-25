     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PS145     Pallet detail maintenance - Change
     *  07 Sep, 2007
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    09/07/07  LMC  5.10
     *      - Created
     *
520 A*    02/12/09  MLB  5.20
     *      - Fix: Revised program to clear Truck, Parent and Slot
     *        zone fields when compartment code is changed and
     *        pallet pieces (PSPCS) is zero.
     *
640 A*    09/23/11  MLB  6.40
     *      - Fix: Revised PS145FM display field sizes. No pgm changes.
     *      - DSPF renamed to PS14501 from PS145FM.
     *        Compile only.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  92        CHANGE MODE PROTECT COMPARTMENT1
     *  93        CHANGE MODE PROTECT COMPARTMENT2
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640 DF*ps145fm   cf   e             workstn
640 MFps14501   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpltsum2   uf a e           k disk    rename(psrec:record)
     Fwarehs    if   e           k disk
     Ftrkcomp   if   e           k disk
     Fpltsum5   if   e           k disk
     Fzoneh1    if   e           k disk
     Fpltmisc   uf a e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
      /COPY QCOPYSRC,ID#HARBOR
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(3) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
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
     D  $prte                 22     26
     D  $prtid                27     31
     D  $prow                 32     33  0
     D  $ptype                45     45
     D  $pgen                 46     46  0
     D  $ptruk                53     62
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
     *                                      19  19 $LCOMP
     D  $lcomp                22     22
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertruk                 1     10
     D  erdesc                11     30
     *
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     D pmvalue         ds
     d ld                      1      2
     d sd                      5      6
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $pprg1          s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D count           s              1  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D kycomp          s                   like(tpcode)
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svcom1          s                   like(w1com1)
     D svcom2          s                   like(w1com2)
     D svseq1          s                   like(w1seq1)
     D svseq2          s                   like(w1seq2)
     D ukrow           s                   like($prow)
     D ukwhse          s                   like($pwhse)
     D warn            s              1
     D wocom           s                   like(w1com1)
     D woseq           s                   like(w1seq1)
     D w1col           s              1  0
     D wotzone         s              6
     D woszone         s              6
     D pltmisccd       s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Change pallet detail
     *              *VIEW    - View pallet detail
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = '1'
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
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     c                   select
     c                   when      nxtscr = '01 ' and client = harbor
     C                   exfmt     screen1h                             50

     C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endsl
     *
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
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
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   eval      ovrrid = *off
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     C                   eval      $pprg = #prog
     C                   eval      $pprg1 = #prog
     C                   eval      $lprg = #prog
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
     C                   eval      #pgmq = #prog
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
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  TRUCK cannot be blank
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7982  Record changed by another user before update.
     *
     C     zm82          begsr
     C                   eval      #msgid = 'PIR7982'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0147  Unload sequence 0 is not valid
     *
     C     zm0147        begsr
     C                   eval      #msgid = 'PIR0147'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TM13201  Unload sequence already exists for compartment.
     *
     C     zm3201        begsr
     C                   eval      #msgid = 'TM13201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *    Make sure compartment was entered.
     *
     C                   if        w1com1 = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Compartment code.
     *
     C                   if        w1com1 <> *blanks
     C                   eval      kycomp = w1com1
     C     tpkey         chain     trkcomp                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
     C                   endif
     *
     *    Make sure compartment was entered.
     *
     C                   if        w1com2 = *blanks
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Compartment code.
     *
     C                   if        w1com2 <> *blanks
     C                   eval      kycomp = w1com2
     C     tpkey         chain     trkcomp                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
     C                   endif
     *
     *  Unload sequence can not be zero
     *
     C                   if        w1seq1 = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0147
     C                   endif

     C                   if        w1seq2 = 0
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0147
     C                   endif
     *
     *  Verify Unload sequence's entered for row aren't the same.
     *
     *    For SEQ# 1
     C                   if        w1seq1 = w1seq2  and
     C                             w1com1 = w1com2
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in27 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3201
     C                   endif
     *
     *  Verify Unload sequence for compartment doesn't exist.
     *
     *    For SEQ# 1
     C                   if        w1seq1 <> 0
     C                   if        w1seq1 > 50
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   eval      wocom = w1com1
     C                   eval      woseq = w1seq1
     *
     *   get zones for edit
     *
     c     znkey         chain     zoneh1
     c                   if        %found
     c                   eval      wotzone = zhzone
     c                   eval      woszone = zhzone
     c                   endif
     C     pseqky        setll     pltsum5
     C                   dow       forevr = forevr
     C     pseqky        reade     pltsum5                                79
     C                   if        *in79
     C                   leave
     C                   else
     C                   if        psrow = worow
     C                   iter
     C                   else
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3201
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     C                   endif
     *
     *
     *    For SEQ# 2
     C                   if        w1seq2 <> 0
     C                   if        w1seq2 > 50
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   eval      wocom = w1com2
     C                   eval      woseq = w1seq2
     C     pseqky        setll     pltsum5
     C                   dow       forevr = forevr
     C     pseqky        reade     pltsum5                                79
     C                   if        *in79
     C                   leave
     C                   else
     C                   if        psrow = worow
     C                   iter
     C                   else
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm3201
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     C                   endif
     *  harbor LD/SD edit must be 'Y' or 'N'
     c                   if        client = harbor
     c                   select
     c                   when      w1ld1 <> 'Y' and w1ld1 <> 'N'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1005
     c                   when      w1sd1 <> 'Y' and w1sd1 <> 'N'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1005
     c                   when      w1ld2 <> 'Y' and w1ld2 <> 'N'
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1005
     c                   when      w1sd2 <> 'Y' and w1sd2 <> 'N'
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1005
     c                   endsl
     c                   endif
     c

     *
     C                   if        $pcmd = '*CHANGE '
     *
     *  Check if record was changed since we read.
     *
     C                   eval      w1col = 1
     C     fileky        chain(n)  record                             79
     *
     *    Record not found.
     *
     C                   if        *in79
     C                   eval      pscomp = *blanks
     C                   eval      psunld = 0
     C                   endif
     *
     *    See if fields changed.
     *
     C                   if        ovrrid = *off
     C                   if        pscomp <> svcom1  or
     C                             psunld <> svseq1
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   exsr      zm82
     C                   goto      endck1
     C                   endif
     C                   endif
     C                   if        w1seq1 > 50
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     C                   if        w1seq2 > 50
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     C                   eval      w1col = 2
     C     fileky        chain(n)  record                             79
     *
     *    Record not found.
     *
     C                   if        *in79
     C                   eval      pscomp = *blanks
     C                   eval      psunld = 0
     C                   endif
     *
     *    See if fields changed.
     *
     C                   if        ovrrid = *off
     C                   if        pscomp <> svcom2  or
     C                             psunld <> svseq2
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   exsr      zm82
     C                   goto      endck1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Truck compartment 1
     *
     C                   when      row# = 10  and
     C                             col# = 28
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1com1
     C                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1com1 = $lcomp
     C                   endif
     *
     *     Truck compartment 2
     *
     C                   when      row# = 10  and
     C                             col# = 51
     C                   eval      *in05 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1com1
     C                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1com2 = $lcomp
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   goto      endcm1
     C                   endsl
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1com1 = *blanks
     C                   eval      w1cub1 = 0
     C                   eval      w1seq1 = 0
     C                   eval      w1com2 = *blanks
     C                   eval      w1cub2 = 0
     C                   eval      w1seq2 = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     *    Code to use to read two records and display as one.
     C                   eval      w1col = 1
     C     fileky        chain(n)  record                             79
     C                   if        not *in79
     C                   eval      w1com1 = pscomp
     C                   eval      w1cub1 = psmaxc
     C                   eval      w1ccb1 = pscube
     C                   eval      w1seq1 = psunld
      * protect compartment if pallet is not empty
     C                   if        pscube > 0
520 AC                             or pspcs > 0
     c                   eval      *in92 = *on
     C                   endif
      * Get additional Harbor information
     c                   if        client = harbor
     c                   exsr      zzgetpltmisc
     c                   endif
      * Set extra fields for HARBOR
     C                   eval      w1ld1 = 'N'
     c                   eval      w1sd1 = 'N'
     c                   if        ld = 'LD'
     c                   eval      w1ld1 = 'Y'
     c                   endif
     c                   if        sd = 'SD'
     c                   eval      w1sd1 = 'Y'
     c                   endif
     C                   else
     C                   eval      w1com1 = *blanks
     C                   eval      w1cub1 = 0
     C                   eval      w1ccb1 = 0
     C                   eval      w1seq1 = 0
     C                   eval      w1ld1  = 'N'
     C                   eval      w1sd1  = 'N'
     C                   eval      w1ld1  = 'N'
     C                   eval      w1sd1  = 'N'
     C                   endif
     C                   eval      w1col = 2
     C     fileky        chain(n)  record                             79
     C                   if        not *in79
     C                   eval      w1com2 = pscomp
     C                   eval      w1cub2 = psmaxc
     C                   eval      w1ccb2 = pscube
     C                   eval      w1seq2 = psunld
      * protect compartment if pallet is not empty
     C                   if        pscube > 0
520 AC                             or pspcs > 0
     c                   eval      *in93 = *on
     C                   endif
      * Get additional Harbor information
     c                   if        client = harbor
     c                   exsr      zzgetpltmisc
     c                   endif
      * Set extra fields for HARBOR
     C                   eval      w1ld2 = 'N'
     c                   eval      w1sd2 = 'N'
     c                   if        ld = 'LD'
     c                   eval      w1ld2 = 'Y'
     c                   endif
     c                   if        sd = 'SD'
     c                   eval      w1sd2 = 'Y'
     c                   endif
     C                   else
     C                   eval      w1com2 = *blanks
     C                   eval      w1cub2 = 0
     C                   eval      w1ccb2 = 0
     C                   eval      w1seq2 = 0
     C                   eval      w1ld1  = 'N'
     C                   eval      w1sd1  = 'N'
     C                   endif
     C                   eval      svcom1 = w1com1
     C                   eval      svseq1 = w1seq1
     C                   eval      svcom2 = w1com2
     C                   eval      svseq2 = w1seq2
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     c                   kfld                    $prtid
     c                   kfld                    $ptype
     c                   kfld                    $pgen
     C                   kfld                    $prow
     C                   kfld                    w1col
     *
     *  Define partial key for main file.
     *
     *  Define key for pltsum5 file.
     *
     C     pseqky        klist
     C                   kfld                    $pwhse
     c                   kfld                    $prtid
     C                   kfld                    wocom
     C                   kfld                    wotzone
     c                   kfld                    $pgen
     C                   kfld                    woszone
     c                   kfld                    $ptype
     C                   kfld                    woseq
     *
     *  Define key for TRKCOMP file.
     *
     C     tpkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kycomp
     *
     *  Define key for ZONEH1 file.
     *
     C     znkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    wocom

     *
     *  Define key for PLTMISC file.
     *
     C     PMkey         klist
     C                   kfld                    $pwhse
     c                   kfld                    $prtid
     C                   kfld                    psplid
     c                   kfld                    pltmisccd
     C                   eval      forevr = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   eval      wotruk = $ptruk
     C                   eval      worow = $prow
     *
     *   Select first screen to display.
     *
     *
     C                   eval      worow = $prow
     *
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGETPLTMISC Retrieve record
     *
     C     zzgetpltmisc  begsr
     c                   eval      pltmisccd = 'HARBORLDSD'
     c     pmkey         chain(n)  pltmisc
     c                   If        not %found
     c                   eval      pmvalue = *blanks
     c                   endif
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDPLTMISC Update pltmisc record
     *
     C     zzupdpltmisc  begsr
     c                   eval      pltmisccd = 'HARBORLDSD'
     c     pmkey         chain     pltmisc
      * update
     c                   If        %found
     C                   time                    pmchgts
     c                   eval      pmchgusr = #user
     c                   eval      pmchgjob = #job
     c                   eval      pmchgnbr = #jobn
     c                   Select
     c                   When      count = 1
     c                   If        w1ld1 = 'Y'
     c                   eval      ld = 'LD'
     c                   else
     c                   eval      ld = '  '
     c                   endif
     c                   If        w1sd1 = 'Y'
     c                   eval      sd = 'SD'
     c                   else
     c                   eval      sd = '  '
     c                   endif
     c
     c                   When      count = 2
     c                   If        w1ld2 = 'Y'
     c                   eval      ld = 'LD'
     c                   else
     c                   eval      ld = '  '
     c                   endif
     c                   If        w1sd2 = 'Y'
     c                   eval      sd = 'SD'
     c                   else
     c                   eval      sd = '  '
     c                   endif
     c                   endsl
     c                   update    pmrec
     c                   endif
      * add a record
     c                   if        not %found
      * only write if ld or sd is a Y
     c                   select
     c                   when      count = 1 and w1ld1 = 'N' and w1sd1 = 'N'
     c                   goto      endupdpltmisc
     c                   when      count = 2 and w1ld2 = 'N' and w1sd2 = 'N'
     c                   goto      endupdpltmisc
     c                   endsl
     c                   eval      pmwhse   = $pwhse
     c                   eval      pmrtid   = $prtid
     c                   eval      pmplid   = psplid
     c                   eval      pmcode   = pltmisccd
     c                   eval      pmseq    = 1
     C                   time                    pmaddts
     c                   eval      pmaddusr = #user
     c                   eval      pmaddjob = #job
     c                   eval      pmaddnbr = #jobn
     c                   eval      pmchgts  = pmaddts
     c                   eval      pmchgusr = #user
     c                   eval      pmchgjob = #job
     c                   eval      pmchgnbr = #jobn
     c                   Select
     C                   When      count = 1
     c                   If        w1ld1 = 'Y'
     c                   eval      ld = 'LD'
     c                   else
     c                   eval      ld = '  '
     c                   endif
     c                   If        w1sd1 = 'Y'
     c                   eval      sd = 'SD'
     c                   else
     c                   eval      sd = '  '
     c                   endif
     c
     c                   When      count = 2
     c                   If        w1ld2 = 'Y'
     c                   eval      ld = 'LD'
     c                   else
     c                   eval      ld = '  '
     c                   endif
     c                   If        w1sd2 = 'Y'
     c                   eval      sd = 'SD'
     c                   else
     c                   eval      sd = '  '
     c                   endif
     c                   endsl
     c                   write     pmrec
     c                   endif
     c     endupdpltmisc endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C     1             do        2             count
     *
     C                   if        $pcmd = '*CHANGE '
     C                   eval      w1col = count
     C     fileky        chain     record                             79
     C                   if        w1col = 1
     C                   eval      pscomp = w1com1
     C                   eval      psunld = w1seq1
     C                   eval      PSPAL# = w1seq1
     C                   else
     C                   eval      pscomp = w1com2
     C                   eval      psunld = w1seq2
     C                   eval      PSPAL# = w1seq2
     C                   endif
520 A*
520 A*      Clear Truck, Parent and Slot zones when pallet position
520 A*      is empty
520 AC                   if        pspcs = 0
520 AC                   eval      pstzon = ' '
520 AC                   eval      pspzon = ' '
520 AC                   eval      psszon = ' '
520 AC                   endif
520 A*
     C                   endif
     *
     *   get zones for update
     *
520 A*   Code disabled below since it is not needed. If pallet
520 A*   has product on it, compartment cannot be changed. If
520 A*   pallet is empty, fields are cleared above.
520 Dc*                  eval      wocom = pscomp
520 Dc*    znkey         chain     zoneh1
520 Dc*                  if        %found
520 Dc*                  eval      pstzon = zhzone
520 DC*                  eval      psszon = zhzone
520 Dc*                  eval      pspzon = zhpzon
520 Dc*                  endif
     *
     *   Update record
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup1
     C                   endif
     *
     * Update PLTMISC for HARBOR
     c                   if        client = harbor
     c                   exsr      zzupdpltmisc
     c                   endif

     C                   enddo
     *
     *   Move key values to parameters
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Compartment
Unload sequence can not exceed 50.

