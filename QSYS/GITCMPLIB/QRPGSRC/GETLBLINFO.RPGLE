417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETLBLINFO  Get client label info - Pgm for GETLBLINFO function
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
730aA*    10/15/19  DAS  7.30a
     *      - Revised to use WORKLBLW
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC
     *
SGC A*    02/09/12  MLB  SGC
     *      - Revised pgm to retrieve item designation code. If ITDESG
     *        is ICR, then load flag IC*, else load blanks.
     *      - Added file PIRITEM to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar Supply Co.
     *
ASC A*    05/08/12  MLB  ASC
     *      - Revised pgm to retrieve item produce/poulty code from
     *        ITEMEXT1. If code found in list, load flag PP* else blanks.
     *      - Added file ITEMEXT1 to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's
     *
EOP A*    03/13/19  DAS  EOPa
     *      - Revised to get customer number. Re: They have multiple
     *        ORDH records with the same stop that will have
     *        different customer numbers in the ORDHM file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
     *
BADaA*    09/23/19  DAS  BADa
     *      - Revised to get customer name. Re: They have multiple
     *        ORDH records with the same stop that will have
     *        different customer names in the ORDH file.
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
730 A*   Discovered that infoTipOnly doesn't work as expected.
     *   If set to 'N', tip won't be displayed anywhere. If set
     *   to 'Y' tip will be displayed in tip box. Tip is never
     *   displayed on line.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

730aDF*orklbl   if   e           k disk    usropn
730aMFworklblw  if   e           k disk    usropn
     Forddm     if   e           k disk    usropn
SGC AFpiritem   if   e           k disk    usropn
ASC AFitemext1  if   e           k disk    usropn
EOPaAFordhm     if   e           k disk    usropn
BADaAFordh      if   e           k disk    usropn

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D getClient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientloc                    10

500lA*----------------------------------------------------------------
500lA*  Customer id
500lA*----------------------------------------------------------------
500lA
     d client          s             10
     d clientloc       s             10
500lA
500lA /copy qcopysrc,id#pirdemo
500lA /copy qcopysrc,id#cashwa
500lA /copy qcopysrc,id#cheney
SGC A /copy qcopysrc,id#sgc
ASC A /copy qcopysrc,id#agar
EOPaA /copy qcopysrc,id#eop
BADaA /copy qcopysrc,id#bad

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d error           s               n
     d infoTipDesc     s             30
     d infoValue       s             30
     d infoTipOnly     s              1
     d infoPercolate   s              1
     d itemLen         s              3  0
     d lastChar        s              1

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds
ASC AD/copy qcopysrc,ikmsc4_asc

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse       Warehouse
     *      $pRtid       Route id
     *      $pLbl#       Label number
     *      $pOrd        Order number
     *      $pSeq        Sequence number
     *      $pItem       Item
     *
     *    Returned Parameters
     *      $pInfo      -  client label info  (comma delimited string)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pLbl#            7 0
     C                   parm                    $pOrd             7 0
     C                   parm                    $pSeq             5 0
     C                   parm                    $pItem           15
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

           when client = cashwa;
             exsr zzcashwa;

SGC A      when client = sgc;
SGC A        exsr zzsgc;

ASC A      when client = Agar;
ASC A        exsr zzagar;

EOPaA      when client = Earls;
EOPaA        exsr zzearl;

BADaA      when client = BigApple;
BADaA        exsr zzbigapple;

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
500sA*  getworklbl  Get worklbl record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getworklbl;

         error = *off;

500sA    // Open worklbl file

730aM    if not %open(worklblw);
730aM      open(e) worklblw;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETLBLINFO):';
730aM        infoValue     = 'Error opening WORKLBLW';
             infoTipOnly   = 'Y';
             infoPercolate = ' ';
             exsr add2Info;
             leavesr;
           endif;
         endif;

500sA    // Get label record

730aD    //chain ($plbl#) worklbl;
730aM    chain ($pwhse: $plbl#) worklblw;

         if not %found;
           error = *on;
           infoTipDesc   = 'Err (GETLBLINFO):';
730aM      infoValue     = 'WORKLBLW not found';
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;
           leavesr;
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getorddm    Get orddm record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getorddm;

         error = *off;

500sA    // Open orddm file

         if not %open(orddm);
           open(e) orddm;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETLBLINFO):';
             infoValue     = 'Error opening ORDDM';
             infoTipOnly   = 'Y';
             infoPercolate = ' ';
             exsr add2Info;
             leavesr;
           endif;
         endif;

500sA    // Get orddm record

         chain ($pwhse: $pord: $pseq: $pitem) orddm;

         if not %found;
           error = *on;
           infoTipDesc   = 'Err (GETLBLINFO):';
           infoValue     = 'ORDDM not found';
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;
           leavesr;
         endif;

       endsr;
      /end-free

BADaA*----------------------------------------------------------------
BADaA*  getordh     Get ordh record
BADaA*----------------------------------------------------------------
BADaA
BADaA /free
BADaA  begsr getordh;

         error = *off;

         // Open ordh file

         if not %open(ordh);
           open(e) ordh;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETLBLINFO):';
             infoValue     = 'Error opening ORDH';
             infoTipOnly   = 'Y';
             infoPercolate = ' ';
             exsr add2Info;
             leavesr;
           endif;
         endif;

         // Get ordh record

         chain ($pwhse: $pord) ordh;

         if not %found;
           error = *on;
           infoTipDesc   = 'Err (GETLBLINFO):';
           infoValue     = 'ORDH not found';
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;
           leavesr;
         endif;

       endsr;
      /end-free

EOPaA*----------------------------------------------------------------
EOPaA*  getordhm    Get ordhm record
EOPaA*----------------------------------------------------------------
EOPaA
EOPaA /free
EOPaA  begsr getordhm;

         error = *off;

         // Open ordhm file

         if not %open(ordhm);
           open(e) ordhm;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETLBLINFO):';
             infoValue     = 'Error opening ORDHM';
             infoTipOnly   = 'Y';
             infoPercolate = ' ';
             exsr add2Info;
             leavesr;
           endif;
         endif;

         // Get ordhm record

         chain ($pwhse: $pord) ordhm;

         if not %found;
           error = *on;
           infoTipDesc   = 'Err (GETLBLINFO):';
           infoValue     = 'ORDHM not found';
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;
           leavesr;
         endif;

       endsr;
      /end-free

SGC A*----------------------------------------------------------------
SGC A*  getpiritem    Get piritem record
SGC A*----------------------------------------------------------------
SGC A
SGC A /free
SGC A  begsr getpiritem;
SGC A
SGC A    error = *off;
SGC A
SGC A    // Open piritem file
SGC A
SGC A    if not %open(piritem);
SGC A      open(e) piritem;
SGC A      if %error;
SGC A        error = *on;
SGC A        infoTipDesc   = 'Err (GETLBLINFO):';
SGC A        infoValue     = 'Error opening PIRITEM';
SGC A        infoTipOnly   = 'Y';
SGC A        infoPercolate = ' ';
SGC A        exsr add2Info;
SGC A        leavesr;
SGC A      endif;
SGC A    endif;
SGC A
SGC A    // Get piritem record
SGC A
SGC A    chain ($pwhse: $pitem) piritem;
SGC A
SGC A    if not %found(piritem);
SGC A      error = *on;
SGC A      itdesg = ' ';
SGC A      infoTipDesc   = 'Err (GETLBLINFO):';
SGC A      infoValue     = 'PIRITEM not found';
SGC A      infoTipOnly   = 'Y';
SGC A      infoPercolate = ' ';
SGC A      exsr add2Info;
SGC A      leavesr;
SGC A    endif;
SGC A
SGC A  endsr;
SGC A /end-free

ASC A*----------------------------------------------------------------
ASC A*  getitemext    Get itemext1 record
ASC A*----------------------------------------------------------------
ASC A
ASC A /free
ASC A  begsr getitemext;
ASC A
ASC A    error = *off;
ASC A
ASC A    // Open itemext1 file
ASC A
ASC A    if not %open(itemext1);
ASC A      open(e) itemext1;
ASC A      if %error;
ASC A        error = *on;
ASC A        infoTipDesc   = 'Err (GETLBLINFO):';
ASC A        infoValue     = 'Error opening ITEMEXT1';
ASC A        infoTipOnly   = 'Y';
ASC A        infoPercolate = ' ';
ASC A        exsr add2Info;
ASC A        leavesr;
ASC A      endif;
ASC A    endif;
ASC A
ASC A    // Get itemext1 record
ASC A
ASC A    chain ($pwhse: $pitem) itemext1;
ASC A
ASC A    if not %found(itemext1);
ASC A      error = *on;
ASC A      ikmsc1 = ' ';
ASC A      ikmsc2 = ' ';
ASC A      ikmsc3 = ' ';
ASC A      ikmsc4 = ' ';
ASC A      ikmsc5 = ' ';
ASC A      select;
ASC A      when client = Agar;
ASC A        eval ikmsc4_asc = ' ';
ASC A      endsl;
ASC A      infoTipDesc   = 'Err (GETLBLINFO):';
SGC A      infoValue     = 'ITEMEXT1 not found';
SGC A      infoTipOnly   = 'Y';
SGC A      infoPercolate = ' ';
ASC A      exsr add2Info;
ASC A      leavesr;
ASC A    else;
ASC A      select;
ASC A      when client = Agar;
ASC A        eval ikmsc4_asc = ikmsc4;
ASC A      endsl;
ASC A    endif;
ASC A
ASC A  endsr;
ASC A /end-free

BADaA*----------------------------------------------------------------
BADaA*  zzbigapple   Get client info for Big Apple Deli
BADaA*----------------------------------------------------------------
BADaA
BADaA /free
BADaA  begsr zzbigapple;

         error = *off;

         exsr getordh;
         if error;
           $pInfo = '';
           ohcnam = '??';
           error = *off;
         endif;

         infoTipDesc   = 'Cust:';
         infoValue     = ohcnam;
         infoTipOnly   = 'N';
         infoPercolate = ' ';
         exsr add2Info;

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

EOPaA*----------------------------------------------------------------
EOPaA*  zzearl       Get client info for Earl's
EOPaA*----------------------------------------------------------------
EOPaA
EOPaA /free
EOPaA  begsr zzearl;

         error = *off;

         exsr getordhm;
         if error;
           $pInfo = '';
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

SGC A*----------------------------------------------------------------
SGC A*  zzsgc     Get client info for Springfield Grocery
SGC A*----------------------------------------------------------------
SGC A
SGC A /free
SGC A  begsr zzsgc;
SGC A
SGC A    error = *off;
SGC A
SGC A    exsr getpiritem;
SGC A    if error;
SGC A      $pinfo = ' ';
SGC A      error = *off;
SGC A    endif;
SGC A
SGC A    if itdesg = 'ICR' ;
SGC A
SGC A      infoTipDesc   = 'IceCrm:';
SGC A      infoValue     = 'IC*';
SGC A      infoTipOnly   = 'Y';
SGC A      infoPercolate = 'P';
SGC A      exsr add2Info;
SGC A
SGC A    else;
SGC A
SGC A      infoTipDesc   = ' ';
SGC A      infoValue     = ' ';
SGC A      infoTipOnly   = 'N';
SGC A      infoPercolate = 'P';
SGC A      exsr add2Info;
SGC A
SGC A    endif;
SGC A
SGC A  endsr;
SGC A /end-free

ASC A*----------------------------------------------------------------
ASC A*  zzagar     Get client info for Agar Supply Co.
ASC A*----------------------------------------------------------------
ASC A
ASC A /free
ASC A  begsr zzagar;
ASC A
ASC A    error = *off;
ASC A
ASC A    exsr getitemext;
ASC A    if error;
ASC A      $pinfo = ' ';
ASC A      error = *off;
ASC A    endif;
ASC A
ASC A  // Check for Produce codes.
ASC A    if     ascik4_prodh >= '0402020001'
ASC A       and ascik4_prodh <= '0402020005'
ASC A
ASC A       or  ascik4_prodh =  '0402020007'
ASC A       or  ascik4_prodh =  '0402020009'
ASC A
ASC A       or  ascik4_prodh >= '0402020011'
ASC A       and ascik4_prodh <= '0402020013'
ASC A
ASC A       or  ascik4_prodh =  '0402020015'
ASC A       or  ascik4_prodh =  '0402020017'
ASC A       or  ascik4_prodh =  '0402020018'
ASC A       or  ascik4_prodh =  '0402020019'
ASC A       or  ascik4_prodh =  '0402020021'
ASC A
ASC A       or  ascik4_prodh >= '0402020023'
ASC A       and ascik4_prodh <= '0402020025'
ASC A
ASC A       or  ascik4_prodh =  '0402020029'
ASC A
ASC A       or  ascik4_prodh >= '0402020030'
ASC A       and ascik4_prodh <= '0402020040'
ASC A
ASC A       or  ascik4_prodh =  '0402020042'
ASC A       or  ascik4_prodh =  '0402020044'
ASC A
ASC A       or  ascik4_prodh >= '0402020046'
ASC A       and ascik4_prodh <= '0402020055'
ASC A
ASC A  // Check for Poultry codes.
ASC A       or  ascik4_prodh =  '0807013180'
ASC A       or  ascik4_prodh =  '0807013181'
ASC A
ASC A       or  ascik4_prodh >= '0807070700'
ASC A       and ascik4_prodh <= '0807070705'
ASC A
ASC A       or  ascik4_prodh =  '0807070707'
ASC A       or  ascik4_prodh =  '0807070708'
ASC A       or  ascik4_prodh =  '0807070711'
ASC A       or  ascik4_prodh =  '0807070714'
ASC A       or  ascik4_prodh =  '0807070715'
ASC A       or  ascik4_prodh =  '0807070720'
ASC A       or  ascik4_prodh =  '0807070721'
ASC A
ASC A       or  ascik4_prodh >= '0807070725'
ASC A       and ascik4_prodh <= '0807070727'
ASC A
ASC A       or  ascik4_prodh >= '0807070740'
ASC A       and ascik4_prodh <= '0807070742'
ASC A
ASC A       or  ascik4_prodh =  '0807072731'
ASC A       or  ascik4_prodh =  '0807072745'
ASC A       or  ascik4_prodh =  '0807072746';
ASC A
c C A      infoTipDesc   = 'ProdCkn:';
ASC A      infoValue     = 'PP*';
ASC A      infoTipOnly   = 'Y';
ASC A      infoPercolate = 'P';
ASC A      exsr add2Info;
ASC A
ASC A    else;
ASC A
ASC A      infoTipDesc   = ' ';
ASC A      infoValue     = ' ';
ASC A      infoTipOnly   = 'N';
ASC A      infoPercolate = 'P';
ASC A      exsr add2Info;
ASC A
ASC A    endif;
ASC A
ASC A  endsr;
ASC A /end-free

500sA*----------------------------------------------------------------
500sA*  zzpirdemo    Get client info for PIRDEMO
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr zzpirdemo;

         error = *off;

         itemLen = %len(%trimr($pItem));
         lastChar = %subst($pItem: itemLen: 1);
         if lastChar = '0'
            or lastChar = '2'
            or lastChar = '4'
            or lastChar = '6'
            or lastChar = '8';
           leavesr;
         endif;

500sA    exsr getworklbl;
500sA    if error;
500sA      leavesr;
500sA    endif;

500sA    exsr getorddm;
500sA    if error;
500sA      $pinfo = ' ';
500sA      error = *off;
500sA    endif;

         if %rem($pord+$pseq : 2) = 0;

           infoTipDesc   = 'OddEven:';
           infoValue     = 'IE';
           infoTipOnly   = 'N';
           infoPercolate = 'P';
           exsr add2Info;

           infoTipDesc   = 'Custom1:';
           infoValue     = 'SQ' + %trim(%char($pseq));
           infoTipOnly   = 'Y';
           infoPercolate = 'S';
           exsr add2Info;

           infoTipDesc   = 'Custom2:';
           infoValue     = 'i' + %trim(lwitem);
           infoTipOnly   = 'Y';
           infoPercolate = ' ';
           exsr add2Info;

         else;

           infoTipDesc   = 'OddEven:';
           infoValue     = 'IO';
           infoTipOnly   = 'N';
           infoPercolate = 'P';
           exsr add2Info;

         endif;

       endsr;
      /end-free
