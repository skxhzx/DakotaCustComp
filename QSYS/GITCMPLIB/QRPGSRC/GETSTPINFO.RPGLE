417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETSTPINFO  Get client stop info - Pgm for GETSTPINFO function
     *  23 November 2008
     *  Dave Sommerville
     *
     *  This program is not used with DD2
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*    11/23/08  DAS  5.10
     *      - Created.
     *
530aA*    07/29/10  DAS  5.30a
     *      - Added custom flag for Andrews.
530bA*    09/16/10  MLB  5.30b
     *      - Added custom flag for Jordano's.
     *
640 A*    06/01/12  MLB  6.40
     *      - Added custom flag for Agar Supply.
     *
650 A*    06/26/13  MLB  6.50
     *      - Enh: Added custom flag for Get Fresh. Retrieve
     *        Stop/Drop display field from RTESTP and display as flag.
     *      - Added file RTESTP to pgm.
     *
700 A*    02/09/16  DAS/MLB  7.00
     *      - Enh: Added ZZUSFCORP for *SW flag processing.
     *
700aA*    02/09/16  MLB  7.00a
     *      - Fix: Commented out references to RTSSD field not in RTESTP
     *        layout at this time. Remove this mod at such time that
     *        GetFresh changes to RTESTP are added in.
     *
730aA*    03/13/18  JCJ  7.30a
     *      - Added custom flag for Earl's
     *
730b *    09/24/19  GJA  7.30b
     *      - Enh: Added custom flag for Big Apple Deli. Retrieve
     *        customer number from ORDHM
     *
730c *    10/03/19  KDE  7.30c
     *      - Enh: Remove single quotes from infoValue per Dave
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    The info string is a comma delimited string consisting of
     *    one or more values. This program (sql function) should
     *    only be called if the client has special info for
     *    item lines (labels). This is determined through program
     *    GETDDOPTS.
     *
     *    Each value consists of 4 fields. The first field is a
     *    description field to be use for the 'tip' box. The second
520 A*    field is the actual value. The third field identifies if
520 A*    the value should only be displayed in the 'tip' box. The
520 A*    fourth field identifies if the value should percolate up
520 A*    to the Stop level or Pallet level.
     *
     *    Example: Let's say that it is determined that 2 values need
     *             to be displayed for an item, 'VAL1' and VAL2'. The
     *             'VAL1' field should only be displayed in the tip
     *             box, while 'VAL2' is to be displayed in the tree
     *             and it should percolate up to the pallet level.
     *             Here is the info string that should be sent back:
     *
     *                  Value1:,VAL1,Y,,Value2:,VAL2,N,P
     *
730aA*   Discovered that DD does not like more than 1 flag sent.
     *   Also discovered that infoTipOnly doesn't work as expected.
     *   If set to 'N', tip won't be displayed anywhere. If set
     *   to 'Y' tip will be displayed on line and in tip box.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordh9     if   e           k disk    usropn
     Fordhm     if   e           k disk    usropn
650 AFrtestp    if   e           k disk    usropn

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D getClient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientloc                    10

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     d client          s             10
     d clientloc       s             10

      /copy qcopysrc,id#pirdemo
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#cashwa
530aA /copy qcopysrc,id#andrews
530bA /copy qcopysrc,id#jordano
640 A /copy qcopysrc,id#agar
650 A /copy qcopysrc,id#gfs
700 A /copy qcopysrc,id#usfcorp
730aA /copy qcopysrc,id#eop
730bA /copy qcopysrc,id#bad

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d error           s               n
     d infoTipDesc     s             30
     d infoValue       s             30
     d infoTipOnly     s              1
     d infoPercolate   s              1

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse       Warehouse
     *      $pRtid       Route id
     *      $pStop       Stop
     *
     *    Returned Parameters
     *      $pInfo      -  Client stop info (comma delimited string)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pStop            2 0
     C                   parm                    $pInfo          100

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         $pInfo = ' ';

         // Get client

         getClient(client : clientloc);

         // Set info based on Client

         select;

           when client = pirdemo;
             exsr zzpirdemo;

530aA      when client = andrews;
530aA        exsr zzandrews;

           when client = cashwa;
             exsr zzcashwa;

           when client = cheney;
             exsr zzcheney;

530bA      when client = jordanos;
530bA        exsr zzjordanos;

640 A      when client = Agar;
640 A        exsr zzagar;

650 A      when client = Getfresh;
650 A        exsr zzgetfresh;

730bA      when client = BigApple;
730bA        exsr zzbigapple;

700 A      when client = usfcorp;
700 A        exsr zzusfcorp;

730aA      when client = Earls;
730aA        exsr zzearl;

         endsl;

         *inlr = *on;
         return;
      /end-free

500sA*----------------------------------------------------------------
500sA*  add2Info     Add value to info string
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr add2Info;

730cA    // Ensure no single quotes exist
730cA    infoValue = %xlate('''':' ':infoValue);

         if $pInfo <> ' ';
           $pInfo = %trimr($pInfo) + ',';
         endif;

         $pInfo = %trimr($pInfo)
               + %trimr(infoTipDesc) + ','
               + %trimr(infoValue) + ','
               + %trimr(infoTipOnly) + ','
               + %trimr(infoPercolate);

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getordh9    Get ORDH9 record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getordh9;

         error = *off;

500sA    // Open ordh9 file

         if not %open(ordh9);
           open(e) ordh9;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETSTPINFO):';
             infoValue     = 'Error opening OFDH9';
             infoTipOnly   = 'Y';
             infoPercolate = ' ';
             exsr add2Info;
             leavesr;
           endif;
         endif;

500sA    // Get ordhm record

         setll ($pwhse: $prtid: $pstop) ordh9;
         reade ($pwhse: $prtid: $pstop) ordh9;

         if %eof(ordh9);
           error = *on;
           infoTipDesc   = 'Err (GETSTPINFO):';
           infoValue     = 'ORDH9 not found';
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;
           leavesr;
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getordhm    Get ordhm record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getordhm;

         error = *off;

500sA    // Open ordhm file

         if not %open(ordhm);
           open(e) ordhm;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETSTPINFO):';
             infoValue     = 'Error opening ORDHM';
             infoTipOnly   = 'Y';
             infoPercolate = ' ';
             exsr add2Info;
             leavesr;
           endif;
         endif;

500sA    // Get ordhm record

         chain (ohwhse: ohord) ordhm;

         if not %found;
           error = *on;
           infoTipDesc   = 'Err (GETSTPINFO):';
           infoValue     = 'ORDHM not found';
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;
           leavesr;
         endif;

       endsr;
      /end-free

650 A*----------------------------------------------------------------
650 A*  getrtestp    Get RTESTP record
650 A*----------------------------------------------------------------
650 A
      /free
650 A  begsr getrtestp;

650 A    error = *off;

650 A    // Open rtestp file

650 A    if not %open(rtestp);
650 A      open(e) rtestp;
650 A      if %error;
650 A        error = *on;
650 A        infoTipDesc   = 'Err (GETSTPINFO):';
650 A        infoValue     = 'Error opening RTESTP';
650 A        infoTipOnly   = 'Y';
650 A        infoPercolate = ' ';
650 A        exsr add2Info;
650 A        leavesr;
650 A      endif;
650 A    endif;

650 A    // Get rtestp record

650 A    setll ($pwhse: $prtid: ohord) rtestp;
650 A    reade ($pwhse: $prtid: ohord) rtestp;

650 A    if %eof(rtestp);
650 A      error = *on;
700aD      //rtssd         = ' ';
650 A      infoTipDesc   = 'Err (GETSTPINFO):';
650 A      infoValue     = 'RTESTP not found';
650 A      infoTipOnly   = 'Y';
650 A      infoPercolate = ' ';
650 A      exsr add2Info;
650 A      leavesr;
650 A    endif;

650 A  endsr;
650 A /end-free

530aA*----------------------------------------------------------------
530aA*  zzandrews   Get client info for Andrews
530aA*----------------------------------------------------------------
530aA
530aA /free
530aA  begsr zzandrews;

         error = *off;

         exsr getordh9;
         if error;
           leavesr;
         endif;

         if %subst(ohmisc: 13: 3) > ' ';
           infoTipDesc   = 'hsMemo:';
           infoValue     = %subst(ohmisc: 13: 3);
           infoTipOnly   = 'Y';
           infoPercolate = 'P';
           exsr add2Info;
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  zzcashwa     Get client info for CASHWA
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr zzcashwa;

         error = *off;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  zzcheney    Get client info for Cheney
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr zzcheney;

         error = *off;

500sA    exsr getordh9;
500sA    if error;
500sA      $pInfo = ' ';
500sA      error = *off;
500sA    endif;

500sA    if %scan('*SP': ohmisc) > 0;

           infoTipDesc   = 'spType:';
           infoValue     = %subst(ohmisc: 16: 1);
           infoTipOnly   = 'N';
           infoPercolate = 'P';
           exsr add2Info;

         endif;

       endsr;
      /end-free

530bA*----------------------------------------------------------------
530bA*  zzjordanos   Get client info for Jordano's Foodservice
530bA*----------------------------------------------------------------
530bA
530bA /free
530bA  begsr zzjordanos;

530bA    error = *off;

530bA    exsr getordh9;
530bA    if error;
530bA      leavesr;
530bA    endif;

530bA    if %subst(ohmisc: 13: 3) > ' ';
530bA      infoTipDesc   = 'idsMemo:';
530bA      infoValue     = %subst(ohmisc: 13: 3);
530bA      infoTipOnly   = 'Y';
530bA      infoPercolate = 'P';
530bA      exsr add2Info;
530bA    endif;

530bA  endsr;
530bA /end-free

730bA*----------------------------------------------------------------
730bA*  zzbigapple    Get Stop/Drop display field for big apple deli
730bA*----------------------------------------------------------------
    A
      /free
    A  begsr zzbigapple;
730b
730ba    error = *off;
730b
730bA    exsr getordh9;
730bA    if error;
730bA      leavesr;
730bA    endif;
730b
730bA    exsr getordhm;
730bA    if error;
730bA      $pInfo = ' ';
730bA      hmmsc1 = '';
730bA      error = *off;
730bA    endif;
730b
730b     infoTipDesc   = 'Host Cust Num:';
730b     infoValue     = %subst(hmmsc1: 1: 10);
730b     if infoValue = '';
730b       infoValue = '????';
730b     endif;
730b     infoTipOnly   = 'Y';
730b     infoPercolate = ' ';
730b     exsr add2Info;
730b
730bA  endsr;
730bA /end-free
640 A*----------------------------------------------------------------
640 A*  zzagar    Get client info for Agar Supply
640 A*----------------------------------------------------------------
640 A
      /free
640 A  begsr zzagar;

640 a    error = *off;

640 A    exsr getordh9;
640 A    if error;
640 A      $pInfo = ' ';
640 A      error = *off;
640 A    endif;

640 A    if %scan('#SP': ohmisc) > 0;

640 A      infoTipDesc   = 'spType:';
640 A      infoValue     = %subst(ohmisc: 1:3);
640 A      infoTipOnly   = 'N';
640 A      infoPercolate = 'P';
640 A      exsr add2Info;

640 a    endif;

640 A  endsr;
640 A /end-free

650 A*----------------------------------------------------------------
650 A*  zzgetfresh    Get Stop/Drop display field for Get Fresh Sales
650 A*----------------------------------------------------------------
650 A
      /free
650 A  begsr zzgetfresh;

650 a    error = *off;

650 A    exsr getordh9;
650 A    if error;
650 A      $pInfo = ' ';
650 A      error = *off;
650 A    endif;

650 A    if %scan('*DP': ohmisc) > 0;
650 A    exsr getrtestp;
650 A    if error;
650 A      $pInfo = ' ';
650 A      error = *off;
650 A    endif;

650 A      infoTipDesc   = 'D:';
700aD      //infoValue     = rtssd;
650 A      infoTipOnly   = 'N';
650 A      infoPercolate = 'P';
650 A      exsr add2Info;

650 a    endif;

650 A  endsr;
650 A /end-free

700 A*----------------------------------------------------------------
700 A*  zzusfcorp   Get client info for USF
700 A*----------------------------------------------------------------
700 A
      /free
700 A  begsr zzusfcorp;

700 A    error = *off;

700 A    exsr getordh9;
700 A    if error;
700 A      $pInfo = ' ';
700 A      error = *off;
700 A    endif;

700 A    if %scan('*SW': ohmisc) > 0;

700 A      infoTipDesc   = 'Custom:';
700 A      infoValue     = 'W';
700 A      infoTipOnly   = 'N';
700 A      infoPercolate = 'P';
700 A      exsr add2Info;

700 A    endif;

700 A  endsr;
700 A /end-free

730aA*----------------------------------------------------------------
730aA*  zzearl       Get client info for Earl's
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr zzearl;

         error = *off;

         exsr getordh9;
         if error;
           leavesr;
         endif;

         exsr getordhm;
         if error;
           $pInfo = ' ';
           hmmsc1 = '';
           error = *off;
         endif;

         infoTipDesc   = 'Host Cust Num:';
         infoValue     = %subst(hmmsc1: 1: 10);
         if infoValue = '';
           infoValue = '????';
         endif;
         infoTipOnly   = 'Y';
         infoPercolate = ' ';
         exsr add2Info;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  zzpirdemo    Get client info for PIRDEMO
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr zzpirdemo;

         error = *off;

         if $pStop = 1;
           leavesr;
         endif;

500sA    exsr getordh9;
500sA    if error;
500sA      leavesr;
500sA    endif;

500sA    exsr getordhm;
500sA    if error;
500sA      $pInfo = ' ';
500sA      error = *off;
500sA    endif;

         if %rem(ohord : 2) = 0;

           infoTipDesc   = 'OddEven:';
           infoValue     = 'OE';
           infoTipOnly   = 'N';
           infoPercolate = 'P';
           exsr add2Info;

           infoTipDesc   = 'Custom:';
           infoValue     = 'O' + %trim(%char(ohord));
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;

         else;

           infoTipDesc   = 'OddEven:';
           infoValue     = 'OO';
           infoTipOnly   = 'N';
           infoPercolate = 'P';
           exsr add2Info;

         endif;

       endsr;
      /end-free
