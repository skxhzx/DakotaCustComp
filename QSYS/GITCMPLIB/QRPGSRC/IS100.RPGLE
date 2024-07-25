600 A /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IS100     Inventory Cost Maintenance
     *  13 April 2017
     *  Kenneth Elder
     *
     *  Revisions:
     *
710 A*    04/13/17  KDE  7.10
     *      - Create
     *
720 A*    02/20/18  KDE  7.20
     *      - Recompiled with new Display file IS10001.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

720 DF**IS100FM   cf   e             workstn
720 MFIS10001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fitemcst   uf a e           k disk
     Fitemcstloguf a e           k disk
     fWarehs    if a e           k disk
     fpirItem   if a e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
700aAD cmdln           s             79    dim(3)ctdata perrcd(1)

700aA*----------------------------------------------------------------
700aA* Function prototypes.
700aA*----------------------------------------------------------------

700aA /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s               n
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D ssbflg          s               n
     D usesc           s              1  0
     D warn            s               n
     D whse            s              3  0
     D zmsflag         s               n

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
640jaD ucOffset        s              3  0

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
     D  $pitem                22     36
     D  $puser                37     46
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $lcode                19     20
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  eridsg                 1      5
     D  ersdsg                 6     10
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
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d GetCurrStamp    pr

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
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
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     *
     c                   eval      nxtscr = '01'
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     c                   eval      *inlr = *on
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
     C                   setoff                                       10
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
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
     C                   move      '01 '         nxtscr
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   eval      ovrrid = *off
     *
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1

     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroti
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
520b C                   eval      forevr = *off
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
510aA*
510aA* Get client id.
510aA*
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
     C                   move      *on           sclear
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
     *    PIR0105s Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr

520dA*  Issue warning if no cost is entered.  Allow zeros to be written if overridden
      /free
         if wopocost = *zeros and woavgcost=*zeros and wostdcost=*zeros
            and not ovrrid;
            error = *on;
            errmsg = 'No Cost have been entered.  Press F20 to force all zeros';
            exsr zm0105;
            leavesr;
         else;
            error = *off;
         endif;

         if *inku=*on and error=*off
            and ovrrid = *off;
            error = *on;
            errmsg = 'No errors exist to override.  F20 invalid at this time';
            exsr zm0105;
            leavesr;
         else;
            error = *off;
         endif;
      /end-free

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *      F20 - Accept Warning.
     *
 1B  C                   if        *inku and error=*on
     C                   move      *on           ovrrid
 1E  C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from Cost File
     *
      /free
         chain ($pWhse) Warehs;
         if not %found(Warehs);
            whdesc = *blanks;
         endif;
         chain ($pWhse:$pITem) pirITem;
         if not %found(pirITem);
            itdesc = *blanks;
         endif;
         wowhse = %char($pwhse) + ' - ' + %trim(whdesc);
         woitem = %trim($pitem) + ' - ' + %trim(itdesc);
         setll ($pwhse:$pitem) itemcst;
         if %found(itemcst);
            *in94 = *off;
            reade(n) ($pwhse:$pitem) itemcst;
            // since record found populate screen wtih current data
            wopocost = icpocost;
            woavgcost = icavgcost;
            wostdcost = icstdcost;
            wouser = icuser;
            if icorg = 'I';
               woorig = 'Import';
            else;
               woorig = 'Screen';
            endif;
            // build current timestamp
            wots = %subst(%editc(%subdt(iclocts:*months):'X'):9:2) + '/' +
                   %subst(%editc(%subdt(iclocts:*days):'X'):9:2) + '/' +
                   %char(%subdt(iclocts:*years)) + '  ' +
                   %subst(%editc(%subdt(iclocts:*hours):'X'):9:2) + ':' +
                   %subst(%editc(%subdt(iclocts:*minutes):'X'):9:2) + ':' +
                   %subst(%editc(%subdt(iclocts:*seconds):'X'):9:2);
         else;
            *in94 = *on;
            // build current timestamp
            wopocost = *zeros;
            woavgcost = *zeros;
            wostdcost = *zeros;
            wouser = icuser;
            woorig = 'Screen';
            wots = %subst(%editc(%subdt(%timestamp:*months):'X'):9:2) + '/' +
                   %subst(%editc(%subdt(%timestamp:*days):'X'):9:2) + '/' +
                   %char(%subdt(%timestamp:*years)) + '  ' +
                   %subst(%editc(%subdt(%timestamp:*hours):'X'):9:2) + ':' +
                   %subst(%editc(%subdt(%timestamp:*minutes):'X'):9:2) + ':' +
                   %subst(%editc(%subdt(%timestamp:*seconds):'X'):9:2);
         endif;
      /end-free
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
510bA*
     c                   exsr      zzget1
510bA*
     C                   endsr
700aA*----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      *off          error
      /free
           // add code for cost log when complete otherwise
           chain ($pWhse:$pitem) itemcst;
           if %found(itemcst);
              // only update if cost was changed
              if icpocost<>wopocost or icstdcost<>wostdcost
                 or icavgcost<>woavgcost;
                 icorg = 'S';
                 icpocost = wopocost;
                 icstdcost = wostdcost;
                 icavgcost = woavgcost;
                 GetCurrStamp();
640pA            iclocts = CurrStampLoc;
640pA            icsysts = CurrStampSys;
640pA            icucts  = CurrStampUC;
                 icjob = #job;
                 icuser = #user;
                 icjobnbr = #jobn;
                 exsr wrtCostLog;
                 update icrec;
              endif;
           else;
              icwhse = $pwhse;
              icitem = $pitem;
              icorg = 'S';
              icpocost = wopocost;
              icstdcost = wostdcost;
              icavgcost = woavgcost;
              GetCurrStamp();
640pA         iclocts = CurrStampLoc;
640pA         icsysts = CurrStampSys;
640pA         icucts  = CurrStampUC;
              icjob = #job;
              icuser = #user;
              icjobnbr = #jobn;
              exsr wrtCostLog;
              write icrec;
           endif;
      /end-free
     *
     C     endupd        endsr
700aA*----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     wrtCostLog    begsr
      /free
              iclwhse = $pwhse;
              iclitem = $pitem;
              iclorg = 'S';
              iclpocost = wopocost;
              iclstdcost = wostdcost;
              iclavgcost = woavgcost;
              GetCurrStamp();
640pA         icllocts = CurrStampLoc;
640pA         iclsysts = CurrStampSys;
640pA         iclucts  = CurrStampUC;
              icljob = #job;
              icluser = #user;
              icljobnbr = #jobn;
              write iclrec;
      /end-free
     C                   Endsr

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
640jA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**  CMDLN - Command display line 700a
F4=Prompt  F5=Refresh  F7=Kilogram  F9=Slot qty  F12=Cancel  F20=Accept Warning
F4=Prompt  F5=Refresh  F7=Pounds    F9=Slot qty  F12=Cancel  F20=Accept Warning
F4=Prompt  F5=Refresh  F9=Slot quantities  F12=Cancel F20=Accept Warning
