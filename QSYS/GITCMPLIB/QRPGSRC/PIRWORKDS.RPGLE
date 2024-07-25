      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TSTBAR    Test CVTBAR
     *  22 February 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
415 A*    02/22/01  DAS  4.15
     *      - Created
     *
520aA*    10/16/08  DAS  5.20a
     *      - Added vendor #.
     *
640aA*    10/01/12  LMC/DAS  6.40a
     *      - Converted to ILE.
     *      - Increase barcode entry field to 100 characters.
     *      - Change orignial *ALL logic to work with *ALLOLD.
     *      - Revised *ALL logic to work with new $cvtdata, $cvtdata2
     *
650aA*    01/23/14  RTR  6.50a
     *      - Added write to BFCDEBUG.
730aA*    10/19/15  RH   7.30a (add missed 650a mod)
730aA*    12/20/13  LMC      6.50a
     *      - Added a log file to assist in session errors on barcode
     *      scanning.
700aA*    09/19/16  LMC  7.00a
     *      - Display the weight fields the same way with *ALL command
     *        as we do with the *CWGTLBS command.
     *
700bA*    12/09/16  DAS  7.00b
     *      - Revised to reverse image field if date is invalid
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
730aAFtstbarpf  o  a e             disk
     Ftstbarfm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a11             s              1    dim(11)
     D a12             s              1    dim(12)
     D smp             s             50    dim(1) ctdata perrcd(1)
    AD tdsc            s             30    dim(19) ctdata perrcd(1)

640aA*----------------------------------------------------------------
640aA*  Convert Barcode Parms
640aA*----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D allflg          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
650aA*----------------------------------------------------------------
650aA*  Called Program Prototypes
650aA*
650aAD WrtDebug        pr                  extpgm('WRTDEBUG')
650aAD                               10    const
650aAD                               10    const
650aAD                             1024    const
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
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
     C                   select
     *
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      head1                                  50
     *
     C                   endsl
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
     C                   eval      redspl = *off
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
     C                   exsr      zzdft1
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
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
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
     *  Initialize subfile values
     *
     *                    Z-ADD1         RECNO
     *                    WRITEDETAIL1                79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
X12  C                   eval      *in85 = *on
     C                   write     detail1
     C                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  SFLADA   Add ALL Records to subfile
640aA*
640aAC     sflad1        begsr
     C                   clear                   w1code
     C                   clear                   w1dpos
     C                   clear                   w1pos
     C                   if        $bcssccsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(1)
     C                   movel     $bcsscc       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcgtinsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(2)
     C                   movel     $bcgtin       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bclotsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(3)
     C                   movel     $bclot        w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcproddsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(4)
     C                   movel     $bcprodd      w1val
700bA /free
700bA                    test(de) *ymd $bcprodd;
700bA                    if %error;
700bA                      *in23 = *on;
700bA                    endif;
700bA /end-free
     C                   exsr      sfladd
700bAC                   eval      *in23 = *off
     C                   endif
     C                   if        $bcpackdsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(5)
     C                   movel     $bcpackd      w1val
700bA /free
700bA                    test(de) *ymd $bcpackd;
700bA                    if %error;
700bA                      *in23 = *on;
700bA                    endif;
700bA /end-free
     C                   exsr      sfladd
700bAC                   eval      *in23 = *off
     C                   endif
     C                   if        $bcslbydsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(6)
     C                   movel     $bcslbyd      w1val
700bA /free
700bA                    test(de) *ymd $bcslbyd;
700bA                    if %error;
700bA                      *in23 = *on;
700bA                    endif;
700bA /end-free
     C                   exsr      sfladd
700bAC                   eval      *in23 = *off
     C                   endif
     C                   if        $bcexpdsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(7)
     C                   movel     $bcexpd       w1val
700bA /free
700bA                    test(de) *ymd $bcexpd;
700bA                    if %error;
700bA                      *in23 = *on;
700bA                    endif;
700bA /end-free
     C                   exsr      sfladd
700bAC                   eval      *in23 = *off
     C                   endif
     C                   if        $bcser#sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(8)
     C                   movel     $bcser#       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcpntlbsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(9)
700aAC                   move      $bcpntlb      $ednum
700aAC                   eval      $eddec = 3
700aAC                   call      'EDITNA'
700aAC                   parm                    $edcmd            8
700aAC                   parm                    $ednum           11 0
700aAC                   parm                    $eddec            2 0
700aAC                   parm                    $edalp           12
700aAC                   parm                    $edfps            2 0
700aAC                   eval      $cstr = *blanks
700aAC                   move      $edalp        $cstr
700aAC                   call      'ADJUST'
700aAC                   parm      '*LEFT   '    $ccmd             8
700aAC                   parm                    $cstr            30
700aAC                   eval      w1val = *blanks
700aAC                   movel     $cstr         w1val
700aDC*                  movel     $bcpntlb      w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcpntkgsent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(10)
700aAC                   move      $bcpntkg      $ednum
700aAC                   eval      $eddec = 3
700aAC                   call      'EDITNA'
700aAC                   parm                    $edcmd            8
700aAC                   parm                    $ednum           11 0
700aAC                   parm                    $eddec            2 0
700aAC                   parm                    $edalp           12
700aAC                   parm                    $edfps            2 0
700aAC                   eval      $cstr = *blanks
700aAC                   move      $edalp        $cstr
700aAC                   call      'ADJUST'
700aAC                   parm      '*LEFT   '    $ccmd             8
700aAC                   parm                    $cstr            30
700aAC                   eval      w1val = *blanks
700aAC                   movel     $cstr         w1val
700aDC*                  movel     $bcpntkg      w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai91sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(11)
     C                   movel     $bcai91       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai92sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(12)
     C                   movel     $bcai92       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai93sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(13)
     C                   movel     $bcai93       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai94sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(14)
     C                   movel     $bcai94       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai95sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(15)
     C                   movel     $bcai95       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai96sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(16)
     C                   movel     $bcai96       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai97sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(17)
     C                   movel     $bcai97       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai98sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(18)
     C                   movel     $bcai98       w1val
     C                   exsr      sfladd
     C                   endif
     C                   if        $bcai99sent
     C                   clear                   w1desc
     C                   clear                   w1val
     C                   eval      w1desc = tdsc(19)
     C                   movel     $bcai99       w1val
     C                   exsr      sfladd
     C                   endif

     C                   eval      w1desc = 'Return code: ' + $cbrtn
     C                   eval      w1val  = $cberm
     C                   exsr      sfladd

     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     **                   WRITEOPTREC
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     **                   WRITEPOSTNREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   if        reccnt > 12
     C                   eval      posrec = reccnt
     C                   endif
     C                   eval      recno = posrec
     C                   write     head1
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
730aAc                   eval      tstw1bar = w1bar
730aAc                   write     tstrec
     *
     *
     *   Verify command
     *
    D*SR         W1CMD     IFNE '*ALL'
640aMC                   if        w1cmd <> '*ALLOLD'  and
640aAC                             w1cmd <> '*ALL'  and
     C                             w1cmd <> '*FIRST'  and
     C                             w1cmd <> '*NEXT'  and
     C                             w1cmd <> '*CWGTLBS'  and
     C                             w1cmd <> '*EXPDT'  and
     C                             w1cmd <> '*PKGDT'  and
     C                             w1cmd <> '*PRODDT'  and
     C                             w1cmd <> '*SCC-14'  and
     C                             w1cmd <> '*SELLBY'  and
     C                             w1cmd <> '*SSCC-18'  and
     C                             w1cmd <> '*UPC'
     *
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w1cmd         errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
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
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   exsr      sflclr
     C                   eval      posrec = 1
     C                   clear                   w1code
     C                   clear                   w1dpos
     C                   clear                   w1desc
     C                   clear                   w1pos
     C                   clear                   w1val
520aAC                   clear                   w1ven#
     C                   exsr      sfladd
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   eval      w1bar = smp(1)
     C                   eval      w1cmd = '*ALL    '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   if        w1cmd <> '*NEXT'
     C                   exsr      sflclr
     C                   endif
640aD*SR         W1CMD     IFEQ '*ALL'
640aMC                   if        w1cmd = '*ALLOLD'
     C                   eval      allflg = *on
     C                   eval      $cbcmd = '*FIRST  '
     C                   else
     C                   eval      $cbcmd = w1cmd
     C                   endif
640aAC                   if        w1cmd = '*ALL'
640aAC                   eval      $cbcmd = w1cmd
640aAC                   endif
     C                   eval      $cbbar = w1bar
520aAC                   eval      $cbven = w1ven#
     *
650aA /free
650aA    WrtDebug(#prog: '*DEBUG': w1bar);
650aA /end-free
650aA*
     C                   dow       forevr = forevr
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
520aAC                   parm                    $cbven           10 0
640aAC                   parm                    $cvtdata
640aAC                   parm                    $cvtdata2
     *
730aAC                   eval      w1bar = $cbbar
640aAC                   eval      $barcode = $cvtdata
640aAC                   eval      $barcode2 = $cvtdata2

     C                   eval      w1code = $cbcod
     C                   eval      w1dpos = $cbdec
     C                   eval      w1desc = $cbdsc
     C                   eval      w1pos = $cbpos
     C                   select
     C                   when      $cbrtn = '*OK'
     C                   if        $cbtyp = 2
     C                   movel     $cbv2         w1val
     C                   else
     C                   move      $cbv1         $ednum
     C                   eval      $eddec = 3
     C                   call      'EDITNA'
     C                   parm                    $edcmd            8
     C                   parm                    $ednum           11 0
     C                   parm                    $eddec            2 0
     C                   parm                    $edalp           12
     C                   parm                    $edfps            2 0
     C                   eval      $cstr = *blanks
     C                   move      $edalp        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   eval      w1val = *blanks
     C                   movel     $cstr         w1val
     C                   endif
     *
     C                   other
     C                   movel     $cberm        w1val
     C                   endsl
     *
     C                   if        w1cmd = '*ALL    '
     C                   exsr      sflad1
     C                   else
     C                   exsr      sfladd
     C                   endif
     *
    D*SR         W1CMD     IFEQ '*ALL'
    MC                   if        w1cmd = '*ALLOLD'  and
     C                             $cbrtn = '*OK'
     C                   eval      $cbcmd = '*NEXT   '
     C                   iter
     C                   endif
     *
     C                   leave
     C                   enddo
     *
     C     endup1        endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
019007430841500532020011851599032121552020004344
**
Serial Ship Container Cd(SSCC)
Global Trade Item Number(GTIN)
Batch/Lot Number
Production Date (YYMMDD)
Packaging Date (YYMMDD)
Sell By Date (YYMMDD)
Expiration Date (YYMMDD)
Serial Number
Net Weight, Pounds
Net Weight, Kilograms
Internal Company Code AI91
Internal Company Code AI92
Internal Company Code AI93
Internal Company Code AI94
Internal Company Code AI95
Internal Company Code AI96
Internal Company Code AI97
Internal Company Code AI98
Internal Company Code AI99
