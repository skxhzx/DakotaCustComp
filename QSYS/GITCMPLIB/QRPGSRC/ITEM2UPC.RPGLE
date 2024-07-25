     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2003')
     Hoption(*srcstmt : *nodebugio)

     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved dfca
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ITEM2UPC Change Selection Method Item/UPC
     *  24 January 2018
     *  Mike Rooker
     *
     *  Revisions
     *
720aA*    05/10/18  LMC  7.20a
     *      - Enh: When checking breakdown, have to consider ssb logic
     *
720b *    05/22/18  LMC/GJA 7.20b
     *      - Fix: Added EOF SLOT11, program terminating incorrectly
     *
720c *    06/14/18  LMC/GJA 7.20c
     *      - Fix: update the ITEMFLD with the SSB items
     *      - Fix: changed pagecnt from 25 lines to 60 lines
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  03        Exit
     *  24 - 25   Field Position to
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fitem2upcfmcf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot11    if   e           k disk
     Fupc5      if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     F*itemfld   uf   e           k disk
     Fitemfld   uf   e           k disk
     FQSYSPRT   O    F  132        PRINTER
720aAFitemlnk1  if   e           k disk
720aAFpiritem1  if   e           k disk    prefix(ssb_) rename(itrec:itrec1)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D cmdchk          s              8
     D cmdtkn          s              1

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10

     D pagecnt         s              5s 0
     D nxtscr          s              3
     D refrsh          s              1
     D hldilm          s             15
     D tmpflg          s              1
     D sclear          s              1
     D error           s               n
     D error1          s               n
     D w4sel           s              1
     D msgk            s              4  0
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
     D  $pitpe               137    137
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
     D  $pxflg                37     37


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
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lsdef                22     23
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lcat                 19     28
     *
     D  $lum                  19     20
     *
     D  $lbc                  19     20
     *
     D  $lwhs1                19     21  0
     D  $litm1                22     36
     D  $lwhd1                37     41
     D  $lsty1                42     42
     D  $lst1                 43     44
     D  $lpal1                45     50
     D  $lovr1                51     53  2
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $lcnt                 42     44  0
     D  $lrepl                45     45
     D  $lulen                46     50  2
     D  $luwdt                51     55  2
     D  $lstyp                56     56
     *
     D  $lcmtype              19     22
     D  $lcmcode              23     23

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritem                 1     15
     D  ercode                16     25
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erval1                41     45
     D  erval2                46     50
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
     *  Variables
     *----------------------------------------------------------------

     D*curdef          s              3  0 inz(0)
720aAD forevr          s              1    inz(*on)
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      init
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
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


     C                   seton                                        lr
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
     C                   exfmt     screen1
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
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
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr01i
     C                   endif
     Csr                 goto      endsc1
     C                   endif
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  INIT    Initialization subrotine
     *
     C     init          begsr
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   eval      $pitpe = 'X'
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
     C                   move      #msgf         $msgf
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
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr

     c                   eval      *in24 = *off
     c                   eval      *in25 = *off
     c                   eval      *in98 = *off
     c                   eval      error = *off
     c                   exsr      zmcmsg
     * Validate Warehouse
     C     whsky         chain     warehs
     c                   if        not %found(warehs)
     c                   eval      error = *on
     c                   eval      *in24 = *on
     c                   eval      errmsg = 'Invalid Warehouse'
     c                   goto      err1
     c                   endif
     * Validate Aisle
     C     slotky        chain     slot11
     c                   if        not %found(slot11)
     c                   eval      error = *on
     c                   eval      errmsg = 'Invalid Aisle'
     c                   eval      *in25 = *on
     c                   goto      err1
     c                   endif
     *
     *
     c     err1          tag
     c                   if        error
     c                   exsr      zm0105
     c                   endif
     C     endck1        endsr


     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for slot file.

     C     slotky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1aisl

     *  Define key for itemfld file.

     C     Itmfky        klist
     C                   kfld                    w1whse
     C                   kfld                    ifitem

     *  Define key for upc file.

     C     upcky         klist
     C                   kfld                    w1whse
     C                   kfld                    upitem
     C                   kfld                    uputyp
     C                   kfld                    upuom

     *  Define key for item file

     C     itmky         klist
     C                   kfld                    w1whse
     C                   kfld                    ititem

     *  Define key for item file

     C     whsky         klist
     C                   kfld                    w1whse

     C                   eval      $lprg = #prog
     C                   eval      nxtscr = '01 '
     c                   eval      w4sel = '4'
     c                   eval      $pcmd = '*ADD'
     C                   endsr
     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr

     * Begin report
     C                   EXCEPT    HDR
     *
     C                   eval      pagecnt = 8
     C     slotky        setll     slot11
720bDC***                dou        %eof
720bMC                   dou        %eof(slot11)
     C     slotky        reade     slot11
720bDC***                if         %eof
720bMC                   if         %eof(slot11)
     C                   leave
     C                   endif
     *
     c                   eval      error1= *off
     *
     *  Skip slot if no pick slot
     c                   if        slpick <> 'Y'
     c                   iter
     c                   endif
     *  Skip slot if no item assigned
     c                   if        slitem = *blanks
     c                   iter
     c                   endif
     c
     c                   eval      ititem = slitem
     c     itmky         chain     piritem
     c                   if        %found(piritem)
     c                   eval      upitem = ititem
     c                   eval      upuom = itum1
     *  Check Normal UOM
     c*                  if        itum1 <> *blanks
     c                   eval      upuom = itum1
     c                   eval      uputyp = 'N'
     c     upcky         chain     upc5
     c                   if        not %found(upc5)
     C                   EXCEPT    DTL
     c                   eval      pagecnt = pagecnt + 1
720cDc***                if        pagecnt >= 25
720cMc                   if        pagecnt >= 60
     c                   EXCEPT    HDR
     C                   eval      pagecnt = 8
     c                   endif
     C                   eval      error = *on
     C                   eval      error1 = *on
     c                   iter
     c                   endif
     c*                  endif
     *  Check Breakdown1 UOM
720aA /free
720aA   ssb_ititem = ' ';
720aA   ssb_ittype = ' ';
720aA   ssb_itum2 = ' ';
720aA   select;
720aA     when itum2 <> ' ' and itflg1 = 'Y';
720aA /end-free
     c*                  if        itum2 <> *blanks
     c                   eval      upuom = itum2
     c                   eval      uputyp = '1'
     c     upcky         chain     upc5
     c                   if        not %found(upc5)
     c                             and itflg1 = 'Y'
     C                   EXCEPT    DTL
     c                   eval      pagecnt = pagecnt + 1
720cDc***                if        pagecnt >= 25
720cMc                   if        pagecnt >= 60
     c                   EXCEPT    HDR
     C                   eval      pagecnt = 8
     c                   endif
     C                   eval      error = *on
     C                   eval      error1 = *on
     c                   endif
     c*                  endif
720aA /free
720aA     when itum2 <> ' ' and itflg1 <> 'Y';
720aA       // do we have an ssb item for this base item
720aA       setll (itwhse: ititem) itemlnk1;
720aA       dow forevr = forevr;
720aA         reade (itwhse: ititem) itemlnk1;
720aA         if %eof(itemlnk1);
720aA           leave;
720aA         endif;
720aA         // found one is it an ssb Item?
720aA         chain (itwhse: itwhdp: ilitem) piritem1;
720aA         if %found(piritem1);
720aA           if ssb_ittype = 'S';
720aA             upuom = ssb_itum2;
720aA             uputyp = '1';
720aA             chain (w1whse: ssb_ititem: uputyp: upuom) upc5;
720aA             if not %found(upc5);
720aA               EXCEPT DTL;
720aA               pagecnt = pagecnt + 1;
720cD            // if pagecnt >= 25;
720cM               if pagecnt >= 60;
720aA                 EXCEPT HDR;
720aA                 pagecnt = 8;
720aA               endif;
720aA               error = *on;
720aA               error1 = *on;
720aA             endif;
720aA           endif;
720aA         endif;
720aA       enddo;
720aA   endsl;
720aA /end-free
     *  Check Breakdown2 UOM
     c*                  if        itum2 <> *blanks
     c                   eval      upuom = itum3
     c                   eval      uputyp = '2'
     c     upcky         chain     upc5
     c                   if        not %found(upc5)
     c                             and itflg2 = 'Y'
     C                   EXCEPT    DTL
720cDc***                if        pagecnt >= 25
720cMc                   if        pagecnt >= 60
     c                   EXCEPT    HDR
     C                   eval      pagecnt = 8
     c                   endif
     c                   eval      pagecnt = pagecnt + 1
     C                   eval      error = *on
     C                   eval      error1 = *on
     c                   endif
     c*                  endif
     *  Error
     c                   if        error1
     c                   iter
     c                   endif
     *  If good, update selection method
     C                   eval      ifitem = slitem
     C     itmfky        chain     itemfld
     C                   if        %found(itemfld)
     C                   eval      ifsltmth = '4'
     C                   update    ifrec
720cAC                   eval      ifitem = ssb_ititem
720cAC     itmfky        chain     itemfld
720cAC                   if        %found(itemfld)
720cAC                   eval      ifsltmth = '4'
720cAC                   update    ifrec
720cAC                   endif
     c*                  leave
     C                   endif
     *
     C                   endif
     *
     C                   enddo

     c                   if        error
     c                   eval      errMsg = 'UPCs have not been collected'
     c                   exsr      zm0105
     c                   endif
     *
     c                   eval      w1aisl = *blanks
     c                   eval      *in25 = *on
     *
     C     endup1        endsr

     ***************************************************************
     * QSYSPRT - PRINT OUT                                         *
     ***************************************************************
     OQSYSPRT   E            HDR               4
     O                                           10 'Item'
     O                                           36 'Pick Slot'
     O                                           49 'UOM'
     O                                           70 'Error'
     O          E            HDR         1  1
     O                                           15 '---------------'
     O                                           36 '----------'
     O                                           49 '---'
     O                                           77 '--------------------'
     O          E            DTL         1
     O                       SLITEM              15
     O                       SLDISP              39
     O                       UPUOM               49
     O                                           75 'UPC does not exist'
