      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FM19600u     PO UCI Receiving - process uci or delete/complete
     *  22 February 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    02/22/16  LMC  7.00
     *      - Created.
700aA*    04/19/16  LMC  7.00a
     *      - Modified sql to check for different item to
     *      - Added logic for metric system changes.
700bA*    11/04/16  LMC  7.00b
     *      - Enh: UPC file has a database change. Recompile only.
710aA*    06/19/17  LMC  7.10a
     *      - Enh: M136002u was replaced with M136003u.
720aA*    08/08/16  LMC 7.20a - reserved
     *      - UCI Tracking.
730aA*    11/21/19  LMC 7.30a
     *      - Fix error message text
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pUci        Scanned Uci
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Purchase Order Seq#
     *      pPOItem     Item
     *      pDelete     Delete license
     *      pDone       Done   license
     *      pSess       Session
     *      plcns       License
     *      plotwarn    Lot Warning
     *      plotovr     Lot Override
     *      pDatewarn   Date Warning
     *      pDateovr    Date Override
     *      ppNDqtchkw  qtchk  Warning
     *      ppqtchkw    qtchk  Override
     *      ppNDqtchk1w qtchk1 Warning
     *      ppqtchk1w   qtchk1 override
     *      ppNDdtchkw  dtchk  warning
     *      ppdtchkw    dtchk  override
     *      ppNDdtchk2w dtchk2 warning
     *      ppdtchk2w   dtchk2 override
     *      ppNDdtchk3w dtchk3 warning
     *      ppdtchk3w   dtchk3 override
     *      ppNDdtchk4w dtchk4 warning
     *      ppdtchk4w   dtchk4 override
     *      ppNDwtchkw  wtchk  warning
     *      ppwtchkw    wtchk  override
     *      ppNDptichkw ptichk warning
     *      ppptichkw   ptichk override
     *      pentwgt     Entered Weight
     *      pentlbkg    Entered lbs/kg code
     *      pentlot     Entered Lot
     *      pentdeci    Entered Decifer code
     *      pentdate    Entered Date
     *
     *    Returned Parameters
     *      pmessage     Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpirhold   uf a e           k disk    rename(horec:horec1)
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

710aDD*M136002U        pr                  extpgm('M136002U')
710aMD M136003U        pr                  extpgm('M136003U')
     D  message                      99
     D  session                      40
     D  user                         10
     D  pgm                          20
     D  whse                          3p 0
     D  PO                            9
     D  seq#                          5p 0
     D  item                         15
     D  qty1                          5p 0
     D  qty2                          5p 0
     D  qty3                          5p 0
     D  #pal                          5p 0
     D  exmf                         10
     D  fifo                         10
     D  mfgdt                         6p 0
     D  wgt                           9p 2
     D  lbskilo                       1
     D  avg                           1
     D  pti                           4p 0
     D  lot                          30
     D  brand                        10
     D  qtchkw                        1
     D  NDqtchkw                      1
     D  qtchk1w                       1
     D  NDqtchk1w                     1
     D  dtchkw                        1
     D  NDdtchkw                      1
     D  dtchk2w                       1
     D  NDdtchk2w                     1
     D  dtchk3w                       1
     D  NDdtchk3w                     1
     D  dtchk4w                       1
     D  NDdtchk4w                     1
     D  wtchkw                        1
     D  NDwtchkw                      1
     D  ptichkw                       1
     D  NDptichkw                     1
     D  stat                          2
     D  osscode                       1
     D  ossprint                      1
     D  ossplatesX                    4p 0
     D  ossdev                       10
     D  decvalue                     15
     D  bypass                        1
     D  psrusr                        1
     D  lcns                         15
710aAD  brditm                       15
     D  lotovr                        1
     D  dateovr                       1
     D  ucidone                       1

     D i14500          pr                  extpgm('I14500')
     D  pWhse                         3p 0
     D  pLcns                        15
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D phrec         E Ds                  Extname(pohdr)
     D uprec         E Ds                  Extname(upc2)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /COPY QCOPYSRC,ID#EASTLAN
      /COPY QCOPYSRC,ID#YHATA

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D puci            s            100
     D pWhse           s              3p 0
     D pPo             s              9
     D pPoseq          s              5p 0
     D pPoitem         s             15
     D pdelete         s              1
     D pdone           s              1
     D pSess           s             40
     D pLcns           s             15
     D pLotwarn        s              1
     D pLotovr         s              1
     D pDateWarn       s              1
     D pDateOvr        s              1
     D pqtchkw         s              1
     D pqtchk1w        s              1
     D pdtchkw         s              1
     D pdtchk2w        s              1
     D pdtchk3w        s              1
     D pdtchk4w        s              1
     D pwtchkw         s              1
     D pptichkw        s              1
     D pNDqtchkw       s              1
     D pNDqtchk1w      s              1
     D pNDdtchkw       s              1
     D pNDdtchk2w      s              1
     D pNDdtchk3w      s              1
     D pNDdtchk4w      s              1
     D pNDwtchkw       s              1
     D pNDptichkw      s              1
     d pentwgt         s              9p 2
     d pentlbkg        s              1
     d pentlot         s             30
     d pentdeci        s             15
     d pentdate        s             10
     D  pmessage       s             99


     D client          s             10
     D clientloc       s             10

     D noupc           s               n
     D w1upc1          s                   like(upupc)
     D chk4err         s               n

     D pokey           s             50
     D editexdt        s              6s 0
     D editmfdt        s              6s 0

     D save$barcode    s                   like($barcode)
     D save$barcode2   s                   like($barcode2)

     D firstEdate      s                   like($bcProdD)
     D firstMdate      s                   like($bcProdD)
     D firstLot        s                   like($bclot)

     D message         s             99
     D session         s             40
     D user            s             10
     D pgm             s             20
     D whse            s              3p 0
     D PO              s              9
     D seq#            s              5p 0
     D item            s             15
     D qty1            s              5p 0
     D qty2            s              5p 0
     D qty3            s              5p 0
     D #pal            s              5p 0
     D exmf            s             10
     D fifo            s             10
     D mfgdt           s              6p 0
     D wgt             s              9p 2
     D lbskilo         s              1
     D avg             s              1
     D pti             s              4p 0
     D lot             s             30
     D brand           s             10
     D qtchkw          s              1
     D NDqtchkw        s              1
     D qtchk1w         s              1
     D NDqtchk1w       s              1
     D dtchkw          s              1
     D NDdtchkw        s              1
     D dtchk2w         s              1
     D NDdtchk2w       s              1
     D dtchk3w         s              1
     D NDdtchk3w       s              1
     D dtchk4w         s              1
     D NDdtchk4w       s              1
     D wtchkw          s              1
     D NDwtchkw        s              1
     D ptichkw         s              1
     D NDptichkw       s              1
     D stat            s              2
     D ossplatesX      s              4p 0
     D decvalue        s             15
     D bypass          s              1
     D lcns            s             15
710aAD brditm          s             15
720aAD today           s              8  0
     D dateovr         s              1
     D lotovr          s              1
     D ucidone         s              1

     D pos             s              2  0
     D day             s              2
     D yr              s              2
     D wkdate          s              6


     D jsChar          s             10    varying
     D ans             s             30    varying
     D jsBeg           s              5p 0
     D jsEnd           s              5p 0
     D jsLen           s              5p 0
     D jsPos           s              5p 0
     D ansBeg          s              5p 0
     D ansEnd          s              5p 0
     D ansLen          s              5p 0
     D ansPos          s              5p 0
     D woBeg           s              5p 0
     D woEnd           s              5p 0
     D woLen           s              5p 0
     D woPos           s              5p 0
     D poutstr         s           1024    varying

     D newhodata       s                   like(hodata)
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
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#LICINFO
     D savever#        s                   like($itver#)

     *----------------------------------------------------------------
     *  PIRHOLD specs
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDUC
      /copy qcopysrc,C#PIRHLDUE
      /copy qcopysrc,C#PIRHLDPO
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D horec         E Ds                  Extname(pirhold)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pmessage
     c                   parm                    pUci
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOseq
     c                   parm                    ppoitem
     c                   parm                    pdelete
     c                   parm                    pdone
     c                   parm                    pSess
     c                   parm                    plcns
     c                   parm                    plotwarn
     c                   parm                    plotovr
     c                   parm                    pdatewarn
     c                   parm                    pdateovr
     c                   parm                    pNDqtchkw
     c                   parm                    pqtchkw
     c                   parm                    pNDqtchk1w
     c                   parm                    pqtchk1w
     c                   parm                    pNDdtchkw
     c                   parm                    pdtchkw
     c                   parm                    pNDdtchk2w
     c                   parm                    pdtchk2w
     c                   parm                    pNDdtchk3w
     c                   parm                    pdtchk3w
     c                   parm                    pNDdtchk4w
     c                   parm                    pdtchk4w
     c                   parm                    pNDwtchkw
     c                   parm                    pwtchkw
     c                   parm                    pNDptichkw
     c                   parm                    pptichkw
     c                   parm                    pentwgt
     c                   parm                    pentlbkg
     c                   parm                    pentlot
     c                   parm                    pentdeci
     c                   parm                    pentdate

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pmessage= ' ';
         select;
           when pUci <> *blanks;
             exsr process;
             if pmessage <> ' ';
               return;
             endif;
             // create pirhold record
             hotype = 'PODTLUCI';
             pokey = %trim(pPO);
             chain (psess: hotype: pokey) pirhold;
             if %found(pirhold);
               uciscanned = puci;
               hodata = pirhlducds;
               update horec1;
             else;
               exsr getcurrstamp;
               hoaddts = currstampsys;
               hoadduc = currstampuc;
               hosess = psess;
               hokey = pokey;
               uciscanned = puci;
               hodata = pirhlducds;
               write horec1;
             endif;
             // call m136002U to do all the additional edits
720aM        // call m136003U to do all the additional edits
             session = psess;
             whse = pwhse;
             po = ppo;
             seq# = pposeq;
             item = ppoitem;
             qty1 = 1;
             qty2 = 0;
             qty3 = 0;
             #pal = 1;
             if $bcpntlbSent;
               wgt = $bcpntlb;
               lbskilo = 'P';
               avg = 'N';
             else;
               if pentwgt > 0;
                 wgt = pentwgt;
                 lbskilo = pentlbkg;
                 avg = 'N';
               else;
                 wgt = 0;
                 lbskilo = ' ';
                 avg = 'N';
               endif;
             endif;
             pti = 0;
             lot = $bclot;
             bypass = 'U';
             lcns = plcns;
             lotovr = plotovr;
             dateovr = pdateovr;
             ucidone = pdone;
             qtchkw    = pqtchkw;
             NDqtchkw  = pNDqtchkw;
             qtchk1w   = pqtchk1w;
             NDqtchk1w = pNDqtchk1w;
             dtchkw    = pdtchkw;
             NDdtchkw  = pNDdtchkw;
             dtchk2w   = pdtchk2w;
             NDdtchk2w = pNDdtchk2w;
             dtchk3w   = pdtchk3w;
             NDdtchk3w = pNDdtchk3w;
             dtchk4w   = pdtchk4w;
             NDdtchk4w = pNDdtchk4w;
             wtchkw    = pwtchkw;
             NDwtchkw  = pNDwtchkw;
             ptichkw   = pptichkw;
             NDptichkw = pNDptichkw;
710aA        brditm = BrandedItm;
710ad        //M136002U(message :
710aM        M136003U(message :
                      session :
                      user :
                      pgm :
                      whse :
                      PO :
                      seq# :
                      item :
                      qty1 :
                      qty2 :
                      qty3 :
                      #pal :
                      exmf :
                      fifo :
                      mfgdt :
                      wgt :
                      lbskilo :
                      avg :
                      pti :
                      lot :
                      brand :
                      qtchkw  :
                      NDqtchkw :
                      qtchk1w  :
                      NDqtchk1w :
                      dtchkw  :
                      NDdtchkw :
                      dtchk2w  :
                      NDdtchk2w :
                      dtchk3w  :
                      NDdtchk3w :
                      dtchk4w  :
                      NDdtchk4w :
                      wtchkw  :
                      NDwtchkw :
                      ptichkw  :
                      NDptichkw :
                      stat :
                      osscode :
                      ossprint :
                      ossplatesX :
                      ossdev :
                      decvalue :
                      bypass :
                      psrusr :
                      lcns   :
710aA                 brditm :
                      lotovr :
                      dateovr :
                      ucidone );

             // send back warning for override
             pNDqtchkw  = NDqtchkw;
             pqtchkw  = qtchkw;
             pNDqtchk1w  = NDqtchk1w;
             qtchk1w  = qtchk1w;
             pNDdtchkw  = NDdtchkw;
             pdtchkw  = dtchkw;
             pNDdtchk2w  = NDdtchk2w;
             pdtchk2w  = dtchk2w;
             pNDdtchk3w  = NDdtchk3w;
             pdtchk3w  = dtchk3w;
             pNDdtchk4w  = NDdtchk4w;
             pdtchk4w  = dtchk4w;
             pNDwtchkw  = NDwtchkw;
             pwtchkw  = wtchkw;
             pNDptichkw  = NDptichkw;
             pptichkw  = ptichkw;
             pmessage = message;
             //pavg     = avg;
           when pdelete = 'Y';
             exsr deletelcns;
           when pdone = 'Y';
             exsr completelcns;
         endsl;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

720aA    $cvcmd = '*CURCMD';
720aA    cvtdte($cvtdt);
720aA    today = $cvd8o;
       endsr;

      /end-free

     *
     *----------------------------------------------------------------
     *
     *  Process  Process the Uci sent.
     *
     C     Process       begsr
     *

      * retrieve vendor for regular po
      /free
        $bcGtinSent = '0';
        exec sql select * into :phrec
             from pohdr
             where phwhse = :pWhse
               and phpo   = :pPO;

      /end-free
      * add the conversion of the uci barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = pUci
     c                   clear                   $barcode
     c                   clear                   $barcode2
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
     C                   parm      phven         $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
700aAC                   parm      pwhse         $cbwhse
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     c                   eval      ucidata1 = $cvtdata
     c                   eval      ucidata2  = $cvtdata2
      * Load UPC
     *
     *  Extract UPC code from entered string.
     *
     c                   if        $bcGtinSent
     c                   eval      $cbbar = $bcGtin
     c                   endif
     *
     C                   select
     C                   when      $cbrtn <> '*INVALID'
     C                             or client = eastland
     C                             or client = yhata
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   if        client = eastland
     C                             and $cbv2 = *blanks
     C                   movel     $cbbar        $cstr
     C                   else
     C                   movel     $bcgtin       $cstr
     C                   endif
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc1
     c
     *   check to see if the combo gtin/dakota item exist in upc file
     *
      /free
        exec sql select * into :uprec
             from upc2
             where upwhse = :pWhse
               and upupc  = :w1upc1
700aD          //and upitem = :ppoitem;
700aM          and upitem = :ppoitem
700aA          fetch first 1 rows only;

        If sqlstt = sqlSuccess
           or $bcai99Sent;
          // same item - passed edit
        else;
          // gtin and item don't match - no entry found in upc
          pmessage = 'Different Item';
          error = *on;
          leavesr;
        endif;

        // check to see if uci can be accepted
        exsr CheckUCI;
        if error;
          leavesr;
        endif;

          // now check for different lot from the first entry          nned
          // use the existing pirhold record to check for differences
          // first save the current scanned data
          // get the extracted data from pirhold
          pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
          exec sql select * into :horec
               from pirhold
               where hosess = :psess
                 and hotype = 'PODTL'
                 and hokey  = :pokey;

          If sqlstt = sqlSuccess;
            if plotovr = 'Y';
              plotwarn = ' ';
            else;
              plotwarn = ' ';
              plotovr = ' ';
              pirhldPOds = hodata;
              select;
                when $bcai99Sent and pentlot <> ' ';
                  // DIFFERENT LOT?
                  if pentlot <> savelotc;
                    pmessage = 'Warning: Mixed Lots';
                    plotwarn = 'Y';
                    leavesr;
                  endif;
                when $bcai99Sent;
                  pmessage = 'Please enter Lot';
                  leavesr;
                when not $bcai99Sent;
                  // DIFFERENT LOT?
                  if $bclot <> savelotc;
                    pmessage = 'Warning: Mixed Lots';
                    plotwarn = 'Y';
                    leavesr;
                  endif;
              endsl;
            endif;
            if pdateovr = 'Y';
              pdatewarn = ' ';
              // still need to convert again for sending to M136002u
              pirhldPOds = hodata;
              if savew1exdt >0 and savew1mfdt = 0;
                select;
                  when $bcslbydSent and $bcslbyd <> 0;
                    // sell by date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcSlByD);
                    cvtdte($cvtdt);
                    editexdt = $cvd6o;
                  when $bcexpdSent and $bcexpd <> 0;
                    // expiration date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcExpD);
                    cvtdte($cvtdt);
                    editexdt  = $cvd6o;
                  when pentdate <> ' ';
                    // need to convert this for expd date field
                    pos = %scan('/':pentdate);
                    if pos > 0;
                      day = %subst(pentdate:pos+1:2);
                      yr  = %subst(pentdate:pos+4:2);
                      pentdate = %replace(day:pentdate:pos:2);
                      pentdate = %replace(yr:pentdate:pos+2:4);
                      wkdate = %trim(pentdate);
                      if wkdate <> ' ';
                        editexdt = %dec(wkdate:6:0);
                      else;
                        editexdt = 0;
                      endif;
                    else;
                      editexdt  = 0;
                    endif;

                endsl;
                exmf= %trim(%editc(editexdt:'X'));
              endif;
              // manufacture date
              if savew1mfdt >0;
                select;
                  when $bcProdDSent and $bcProdD <> 0;
                    // production date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcProdD);
                    cvtdte($cvtdt);
                    editmfdt = $cvd6o;
                  when $bcPackDSent and $bcPackD <> 0;
                    // pack date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcPackD);
                    cvtdte($cvtdt);
                    editmfdt = $cvd6o;
                  when pentdate <> ' ';
                    // need to convert this for expd date field
                    pos = %scan('/':pentdate);
                    if pos > 0;
                      day = %subst(pentdate:pos+1:2);
                      yr  = %subst(pentdate:pos+4:2);
                      pentdate = %replace(day:pentdate:pos:2);
                      pentdate = %replace(yr:pentdate:pos+2:4);
                      wkdate = %trim(pentdate);
                      if wkdate <> ' ';
                        editmfdt = %dec(wkdate:6:0);
                      else;
                        editmfdt = 0;
                      endif;
                    else;
                      editmfdt  = 0;
                    endif;

                endsl;
                exmf= %trim(%editc(editmfdt:'X'));
              endif;
            else;
              pdatewarn = ' ';
              pdateovr = ' ';
              pirhldPOds = hodata;
              // DIFFERENT Dates?
              // determine what date if any were saved on first scan
              if savew1exdt >0;
                select;
                  when $bcslbydSent and $bcslbyd <> 0;
                    // sell by date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcSlByD);
                    cvtdte($cvtdt);
                    editexdt = $cvd6o;
                  when $bcexpdSent and $bcexpd <> 0;
                    // expiration date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcExpD);
                    cvtdte($cvtdt);
                    editexdt  = $cvd6o;
                  when pentdate <> ' ';
                    // need to convert this for expd date field
                    pos = %scan('/':pentdate);
                    if pos > 0;
                      day = %subst(pentdate:pos+1:2);
                      yr  = %subst(pentdate:pos+4:2);
                      pentdate = %replace(day:pentdate:pos:2);
                      pentdate = %replace(yr:pentdate:pos+2:4);
                      wkdate = %trim(pentdate);
                      if wkdate <> ' ';
                        editexdt = %dec(wkdate:6:0);
                      else;
                        editexdt = 0;
                      endif;
                    else;
                      editexdt  = 0;
                    endif;
                endsl;
                if savew1exdt <> editexdt
                   and editexdt > 0;
                  pmessage = 'Warning: Mixed Dates';
                  pdatewarn = 'Y';
                  leavesr;
                else;
                  exmf= %trim(%editc(editexdt:'X'));
                endif;
              endif;
              // manufacture date
              if savew1mfdt >0;
                select;
                  when $bcProdDSent and $bcProdD <> 0;
                    // production date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcProdD);
                    cvtdte($cvtdt);
                    editmfdt = $cvd6o;
                  when $bcPackDSent and $bcPackD <> 0;
                    // pack date in barcode
                    $cvcmd = '*YMDMDY';
                    $cvd6i = %char($bcPackD);
                    cvtdte($cvtdt);
                    editmfdt = $cvd6o;
                endsl;
                if savew1mfdt <> editmfdt
                   and editmfdt > 0;
                  pmessage = 'Warning: Mixed Dates';
                  pdatewarn = 'Y';
                  leavesr;
                else;
                  exmf= %trim(%editc(editmfdt:'X'));
                endif;
              endif;
            endif;
          else;
          endif;
          // no error write extracted info to pirhold for later use
          // create pirhold extracted data
          hotype = 'PODTLUCIE';
          pokey = %trim(pPO);
          chain (psess: hotype: pokey) pirhold;
          if %found(pirhold);
            hodata = pirhldueds;
            update horec1;
          else;
            exsr getcurrstamp;
            hoaddts = currstampsys;
            hoadduc = currstampuc;
            hosess = psess;
            hokey = pokey;
            hodata = pirhldueds;
            write horec1;
          endif;

      /end-free
     *
     *    If extract of UPC comes back invalid, treat UPC as if not
     *    on file.
     C                   other
     C                   exsr      zm029
     *    Log barcode conversion error.
     C                   exsr      zm0105
     C                   endsl
     *
     C     endprocess    endsr
     *----------------------------------------------------------------
     *
     *  CheckUCI - Check to make sure UCI can be accepted
     *
     C     CheckUCI      begsr
      /free
        //check to make sure UCI barcode does not already exist
        puci = %TrimL(puci);
        exsr clr$uciinfo;

        $uiWhse = pwhse;
        $uiuci  = pUCI;
        $uiitem = ppoitem;

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%CHKACTV';
        $drisys2upd = 'D';
        chk4err = *on;
        exsr zzzdricop;
        if error;
        endif;
        // if return is *EXIST seton error
        if $drireturn = '*EXIST';
          error = *on;
          pmessage = 'UCI already exist';
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  DeleteLcns - Delete the uci's and the license
     *
     C     DeleteLcns    begsr
      /free
        // make sure license is sent
        if plcns = ' ';
          pmessage = 'No license was sent';
          leavesr;
        endif;
        // continue with delete
        exsr zzupdCnl;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CompleteLcns - Complete the license
     *
     C     CompleteLcns  begsr
      /free
        // make sure license is sent
        if plcns = ' ';
          pmessage = 'No license was sent';
          leavesr;
        endif;
        // retrieve the original pirhold podtl record that was scanned
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem)
              + 'UCIHOLD';
        exec sql select * into :horec
             from pirhold
             where hosess = :psess
               and hotype = 'PODTL'
               and hokey  = :pokey;

        // if we don't find a record - we have a problem
        If sqlstt = sqlSuccess;
          pirhldPOds = hodata;
        endif;

        // once a warning has been issued no need to extract again
        if pwtchkw <> 'Y';
          // get the total qty and weight - reuse I14500 which is used
          // as a header in M19600/M20400 in gui
          // this will return json that will need to be broken apart
          pOutStr = '';
          whse = pWhse;
          lcns = plcns;

          i14500(Whse :
                 lcns :
                 pOutStr);

          // now break apart the json
          exsr ProcessJson;
          // need to update the podtl ucihold record
          $pgslcns = plcns;
          cwovr = ' ';
          wtchk = ' ';
          svdwgt = 0;
          newhodata =  pirhldPOds;
          exec sql update pirhold
                   set hodata  = :newhodata
            where hosess = :psess
              and hotype = 'PODTL'
              and hokey  = :pokey;
          If sqlstt = sqlSuccess;
          endif;
        endif;
        // call M136002u to do final edits. The pirhold record just updated
        // will be used in the M136002u edit update process.
        session = psess;
        whse = pwhse;
        po = ppo;
        seq# = pposeq;
        item = ppoitem;
        wtchkw    = pwtchkw;
        NDwtchkw  = pNDwtchkw;
        bypass = 'U';
        lcns = plcns;
        ucidone = pdone;
710aD   //M136002U(message :
710aM   M136003U(message :
                 session :
                 user :
                 pgm :
                 whse :
                 PO :
                 seq# :
                 item :
                 qty1 :
                 qty2 :
                 qty3 :
                 #pal :
                 exmf :
                 fifo :
                 mfgdt :
                 wgt :
                 lbskilo :
                 avg :
                 pti :
                 lot :
                 brand :
                 qtchkw  :
                 NDqtchkw :
                 qtchk1w  :
                 NDqtchk1w :
                 dtchkw  :
                 NDdtchkw :
                 dtchk2w  :
                 NDdtchk2w :
                 dtchk3w  :
                 NDdtchk3w :
                 dtchk4w  :
                 NDdtchk4w :
                 wtchkw  :
                 NDwtchkw :
                 ptichkw  :
                 NDptichkw :
                 stat :
                 osscode :
                 ossprint :
                 ossplatesX :
                 ossdev :
                 decvalue :
                 bypass :
                 psrusr :
                 lcns   :
710aA            brditm :
                 lotovr :
                 dateovr :
                 ucidone );
        // Do we have errors or warnings
        if message <> ' ';
          pmessage = message;
          pNDwtchkw  = NDwtchkw;
          pwtchkw  = wtchkw;
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
      /free
        pMessage = $cberm;
        noupc = *on;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *    PO20029  UPC not on file.
     *
     C     zm029         begsr
      /free
730aD   //pMessage = 'UPC not found of PO';
730aM   pMessage = 'UPC not found on PO';
        noupc = *on;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = 0
     C                   eval      $uiaddusr = #curruser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDCnl Delete scanned records
     *
     C     zzupdCnl      begsr
     C                   eval      error = *off
     *   Remove any LICUCI records
      /free
        // Delete LICINFO Records
        exsr zzlicinfocan;

        exsr clr$uciinfo;

        // warehouse
        $uiWhse = pwhse;

        // License
        //if $pxd = ' ';
          $uiLcns = plcns;
        //else;
          //$uiLcns = templcns;
        //endif;

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%CANCEL';
        $drisys2upd = 'D';
        chk4err = *on;
        exsr zzzdricop;
        if error;
        endif;

      /end-free
     C     endupCnl      endsr
     *----------------------------------------------------------------
     *  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
     *----------------------------------------------------------------

      /free
        begsr zzlicinfocan;

          exsr clr$licinfo;

          $lnwhse  = pwhse;
          //if $pxd = ' ';
            $lnlcns  = plcns;
          //else;
            //$lnlcns  = templcns;
          //endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%DELETEALL';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;
          if error;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ProcessJSON   Process JSON string
     *----------------------------------------------------------------

      /free
       begsr ProcessJSON;

         if %len(poutstr) = 0;
           leavesr;
         endif;

           // Get the Qty

           jsPos = %scan('"Qty"': poutstr: 1);
           if jsPos = 0;
             // this would be a problem
             leavesr;
           endif;

           // Calculate beginning of qty

           jsBeg = jsPos + 7;

           // Get end of js code

           jsEnd = %scan('",': poutstr: jsBeg);
           if jsEnd = 0;
             leavesr;
           endif;

           // Calculate length of js code

           jsLen = jsEnd - jsBeg;

           // Get js

           jsChar = %subst(poutstr: jsBeg: jsLen);
           w1qrc1 = %DEC(jschar:5:0);

           // Get the Wgt

           jsPos = %scan('"Wgt"': poutstr: 1);
           if jsPos = 0;
             // this would be a problem
             leavesr;
           endif;

           // Calculate beginning of wgt

           jsBeg = jsPos + 7;

           // Get end of js code

           jsEnd = %scan('"}': poutstr: jsBeg);
           if jsEnd = 0;
             leavesr;
           endif;

           // Calculate length of js code

           jsLen = jsEnd - jsBeg;

           // Get js

           jsChar = %subst(poutstr: jsBeg: jsLen);
           W1dwgt = %DEC(jschar:7:2);
           W1twgt = %DEC(jschar:7:2);


       endsr;
      /end-free

