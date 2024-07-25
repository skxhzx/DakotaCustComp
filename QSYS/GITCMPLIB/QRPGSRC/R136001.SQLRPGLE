      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR13600      PO Receiving - Retrieve Dakota Item from Scan.
     *  03 February 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    02/03/15  LMC  7.00
     *      - Created.
700aA*    10/13/15  LMC  7.00a
     *      - Changed foundonpo to alpha field so we can do more than
     *        just turn it on or off. Need to be able to handle same
     *        item on multiple po lines.
     *      - Added pirhold to save scanned UCI.
700bA*    02/03/16  LMC  7.00b
     *      - Check to see if PCM needs to be entered.
700cA*    02/17/16  LMC  7.00c
     *      - Added logic for UCI received items.
     *      - Added dri logic to determine if UCI received item.
     *      - Added dri logic to check for UCI existence.
     *      - Send back error message in json.
     *
700dA*    06/03/16  LMC  7.00d
     *      - Added a flag to the pirhold PODTLUCI record to be used
     *        in allowing the user to associate the scanned value
     *        with a Dakota item on the PO, and load to the UPC file.
700eA*    06/09/16  LMC  7.00e
     *      - Enhanced to identify branded item scanned.
     *        Will send back parent item for receiving, along with
     *        the branded item so it can be auto loaded on the entry
     *        screen.
700fA*    11/04/16  LMC  7.00f
     *      - Enh: UPC file has a database change. Recompile only.
710aA*    09/11/17  LMC  7.10a
     *      - Fix: Send normal PO# to pcm if receiving with a super po
710bA*    12/08/17  NLK  7.10b
     *      - Fix: Data Dec Err in R13600 stmt 17600 call cvtbar
     *        Dave believes pohdr failed, so blank field used.
     *        BFCGloBalF/GloBlank needs empty record.
720aA*    07/26/16  MR/LMC  7.20a   reserved
     *      - Open up parms in DRIUCIINFO for new file format
     *        change to UCIINFO.
730aA*    11/21/19  LMC 7.30a
     *      - Fix message text.
740 A*    06/05/20  KDE 7.40
     *      - Added LPN to properly get what items are on specific pallet
     *      - Add PODTLASN record to PIRHOLD to pass along po detail
     *        information from POASN to M13600 to auto populate
     *      - Add logic when DITEM|PO|SEQ|ITEM is sent from M13500H1
     *        to go directly to receiving.  It is only sent when single item
     *      - Add logic when DITEM|PO|SEQ|ITEM is sent from M13500H1
     *        to see if multiple date/lot exist.  If so we will redirect
     *        to I272xx to allow user to select correct ASN entry to receive
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pUci        Scanned Uci
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pSuper      Super PO flag
     *      pSess       Session
740 A*      pLpn        Pallet number
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpodtl1    if   e           k disk
     F                                     rename(pdrec:pdrec1)
     Fupc4      if   e           k disk
     F                                     rename(uprec:uprec4)
700aAFpirhold   uf a e           k disk    rename(horec:horec1)
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

     D parec         E Ds                  Extname(poasn)
     D phrec         E Ds                  Extname(pohdr)
     D pdrec         E Ds                  Extname(podtl)
     D pujrec        E Ds                  Extname(pospo3) prefix(sp_)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
700bA /copy qcopysrc,p.CHKPCM
700eA /copy qcopysrc,p.GETBRAND

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /COPY QCOPYSRC,ID#EASTLAN
      /COPY QCOPYSRC,ID#YHATA

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D puci            s            100    varying
     D pWhse           s              3p 0
     D pPo             s              9
     D pSuper          s              1
     D pSess           s             40
740 AD pLpn            s             75
     D  pOutStr        s           1024    varying

     D pItem           s             15
     D pItemseq        s              5  0
700bAD pPO#            s              9
     D pPOonSuper      s              9
     D pMessage        s             99

     D client          s             10
     D clientloc       s             10

     D upcctr          s              3  0
     D svupci          s             15
     D w1upcd          s             20
     D ItemList        s            225    varying
     D MultItem        s              1
     D noupc           s               n
700aDD*FoundonPO       s               n
700aMD FoundonPO       s              1
     D FoundonSupers   s               n
     D w1upc           s                   like(upupc)
700cAD chk4err         s               n

     D pokey           s             50
700bAD pcmcmd          s              8
700bAD pcmlvl          s              4
700bAD pcmsup          s              1
700bAD pcmtyp          s              3
700bAD pentpcm         s              1
700bAD pcmseq          s              5  0
700bAD pcmwhse         s              3s 0
700bAD pcmitm          s             15
700eAD pBrand          s              1
700eAD bCmd            s             10
700eAD bBrand          s             10
700eAD bBranditm       s             15
700eAD bBrandFlg       s              1
700eAD bParentitm      s             15
700eAD saveBranditm    s             15

740 Ad pos             s              5  0
740 Ad relpos          s              5  0
740 Ad prvpos          s              5  0
740 Ad ucipo           s             22
740 Ad uciseq          s              5  0
740 Ad uciitm          s             15
740 Ad asnpo           s             22
740 Ad asnseq          s              5  0
740 Ad asnitm          s             15
740 Ad asnupc          s             20
740 Ad asnmfgdte       s              8  0
740 Ad asnexpdte       s              8  0
740 Ad asnlot          s             30
740 Ad asnlpn          s             48
740 Ad lpncnt          s              2  0
740 Ad reccnt          s              5  0
740 Ad m134AsnCall     s               n
740 Ad AddUCI          s               n

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

700cA*----------------------------------------------------------------
700cA*  DRI parameters
700cA*----------------------------------------------------------------
700cA /COPY *libl/qcopysrc,C#DRIPARMS

700cA*----------------------------------------------------------------
700cA*  Data Formats
700cA*----------------------------------------------------------------
700cA /COPY *libl/qcopysrc,C#ITEM
700cA /COPY *libl/qcopysrc,C#UCIINFO
700cAD savever#        s                   like($itver#)

     *----------------------------------------------------------------
     *  PIRHOLD specs
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDUC
700cA /copy qcopysrc,C#PIRHLDUE
740 A /copy qcopysrc,C#PIRHLDAS
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

650bAD horec         E Ds                  Extname(pirhold)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pUci
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pSuper
     c                   parm                    pSess
740 Ac                   parm                    pLpn
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
740 A    AddUCI = *on;
740 A    // ASNFNC is called from M134xx.  It will pass in ASNFNC
740 A    // in the POUTSTR parm to know so it can just return M136xx or M158xx
740 A    // so ASNFNC will go straight from M134xx to either M136xx or
740 A    // M158xx when user scans valid ASN LPN and the LPN represents
740 A    // one single item with only one record in POASN
740 A    m134AsnCall = *off;
740 A    if pOutStr = 'ASNFNC';
740 A      m134AsnCall = *on;
740 A    endif;
740 A    pOutStr = ' ';
740 A    if %scan('DITEM': pUCI) >0 or %scan('DASN':pUCI)>0;
740 A      AddUCI = *off;
740 A      // If direct sequence on PO sent then retrieve information
740 A      // and generate PIRHOLD with that info below for M136xx
740 A      if %scan('DITEM':pUCI)>0;
740 A        exsr getDirectUPC;
740 A      else;
740 A        exsr getDirectASN;
740 A      endif;
740 A    else;
700dA      uciNotFound = ' ';
740 D      //if pUci <> *blanks;
740 M      if pUci <> *blanks or pLpn<>*blanks;
             exsr process;
700bA        if pitem <> ' ';
700bA          exsr chkforpcm;
700bA        else;
700bA          pentpcm = 'N';
700bA        endif;
           endif;
740 A    endif;
         // Put ASN data in new PODTLASN record in PIRHOLD file
         // Will be used by M13600I to auto populate data from ASN
740 A    if pLpn <> *blanks and upcctr=1 and $ifrcvmth <> '2';
740 A      // create pirhold record
740 A      phlpn = %trim(pLpn);
740 A      phupc = %trim(paupc);
740 A      phexpd= %dec(%subst(%editc(pamfgexp:'X'):3:6):6:0);
740 A      phmfgd= %dec(%subst(%editc(pamfgdt:'X'):3:6):6:0);
740 A      phlot = %trim(palot);
740 A      phwgt = pawgt;
740 A      phqtyr= paqty;
           phuom = pauom;
740 A      hotype = 'PODTLASN';
740 A      pokey = %trim(pPO#) + %editc(paseq:'X') + %trim(paitem);
740 A      chain (psess: hotype: pokey) pirhold;
740 A      if %found(pirhold);
740 A        hodata = pirhldasds;
740 A        update horec1;
740 A      else;
740 A        exsr getcurrstamp;
740 A        hoaddts = currstampsys;
740 A        hoadduc = currstampuc;
740 A        hosess = psess;
740 A        hokey = pokey;
740 A        hodata = pirhldasds;
740 A        write horec1;
740 A      endif;
740 A    endif;
740 A    if puci<>*blanks and addUCI;
740 A      uciscanned = puci;
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
740 A    endif;
         // Put together JSON string

740 A   if m134AsnCall and upcctr=1;
740 A     // when being called from ASNFNC it returns only a string
740 A     // that indicates whether to call M136xx or M158xx.  ASNFNC
740 A     // is called to determine the proper path from M134xx.  It is
740 A     // also ONLY called when a scanned or entered LPN is present
740 A     // which indicates ASN processing
740 A     if pentpcm = 'Y';
740 A       pOutStr = 'M158xx';
740 A     else;
740 A       pOutStr = 'M136xx';
740 A     endif;
740 A   else;
740 A     if m134AsnCall;
740 A       // when reaching here multiple records exist for one specific
740 A       // po/seq/item.  Therefore we return flag saying we need to
740 A       // display I272xx for user to select from multiple dates/lots
740 A       pOutStr = 'I272xx';
            pOutStr = '{'
                   +  '"Item":"'  + %trimr(pitem) + '",'
                   +  '"Lpn":"'  + %trim(pLpn) + '",'
700bA              +  '"PO":"'  + %trimr(pPO#) + '",'
                   +  '"PGM":"I272xx"'
                   +  '}';
740 A     else;
            pOutStr = '{'
                   +  '"Item":"'  + %trimr(pitem) + '",'
                   +  '"ItemSeq":"'  + %char(pitemseq) + '",'
                   +  '"POonSuper":"'  + %trimr(pPOonSuper) + '",'
700bA              +  '"PO":"'  + %trimr(pPO#) + '",'
                   +  '"MItm":"'  + %trimr(Multitem) + '",'
                   +  '"ErrMsg":"'  + %trimr(Pmessage) + '",'
700bA              +  '"EntPCM":"'  + %trimr(pentpcm) + '",'
700eA              +  '"BrandItm":"'  + %trimr(savebrandItm) + '",'
                   +  '"ItmLst":"'  + %trimr(ItemList) + '"';

            // Close off the JSON string
            pOutStr += '}';
          endif;
740 A   endif;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *
740 A*----------------------------------------------------------------
740 A*
740 A*  getDirectUPC  -  Get UPC for one item LPN
740 A*
740 AC     getDirectUPC  begsr
     *
      /free
              // bust out po, sequence and item to get upc for scanned LPN.  This
              // represents one item on the LPN
              ucipo=*blanks;
              uciseq=0;
              uciitm=*blanks;
              pos = 0;
              relpos = 0;
              prvpos = 1;
              dow forever = forever;
                pos = %scan('|' : pUCI: prvpos);
                if pos >0;
                  relpos = relpos + 1;
                  select;
                    when relpos=1;
                      // end of string DIRECTITEM.  Nothing to do
                      prvpos = pos+1;
                    when relpos=2;
                      // End of PO
                      monitor;
                        ucipo = %subst(pUCI:prvpos:(pos)-(prvpos));
                      on-error;
                        ucipo=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=3;
                      // End of PO seq
                      monitor;
                        uciseq = %dec(%subst(pUCI:prvpos:(pos)-
                                         (prvpos)):5:0);
                      on-error;
                        uciseq=*zeros;
                      endmon;
                      prvpos = pos+1;
                    when relpos=4;
                      // End of po item
                      monitor;
                        uciitm = %subst(pUCI:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        uciitm=*blanks;
                      endmon;
                      leave;
                    other;
                      leave;
                  endsl;
                else;
                  leave;
                endif;
              enddo;
              exec sql select * into :parec
                    from poasn
                 where pawhse=:pWhse and papo=:uciPo and
                       paseq=:uciSeq and paitem=:uciItm and
                       palpn=:pLpn and palcns=' ';
              if sqlstt = sqlSuccess;
                upcctr = 1;
                pPO# = paPO;
                pItem = paItem;
                pLpn = paLpn;
                // only put upc in UCI field if one is not already
                // represented in PIRHOLD with session and PODTLUCI
                // key for po or super po.  If one exist this signifies
                // M135xx has added one for a new upc to be associated
                exec sql select count(*) into :reccnt
                            from pirhold
                       where hosess=:psess and hokey='PODTLUCI'
                             and hokey=:papo;
                if sqlstt <> sqlsuccess or reccnt =0;
                  exec sql select count(*) into :reccnt
                            from pirHold,pospo
                       where hosess=:psess and hokey='PODTLUCI'
                            and hokey=puspo and pupo=:papo
                            and puwhse=:pWhse;
                  if sqlstt <> sqlSuccess or reccnt=0;
                    pUci=paupc;
                  endif;
                endif;
                exsr chkforpcm;
              else;
                // set flags so we redirect to I272xx to select from
                // multiple asn entries (multiple date/lot)
                upcctr = 2;
                M134AsnCall = *on;
                pItem = uciItm;
                pPO# = uciPo;
                pLpn = pLpn;
                pUCI = *blanks;
              endif;
      /end-free
740 Ac                   endsr
740 A*----------------------------------------------------------------
740 A*
740 A*  getDirectASN  -  Get data for specific ASN entry for particular po/seq
740 A*
740 AC     getDirectASN  begsr
     *
      /free
              // bust out po, seq, item, upc, mfg date, exp date, lot and lpn.
              // This gets us to the unique asn entry with proper quantity
              // and dates/lots for specific po/seq when more than one date/lot exist
              asnpo=*blanks;
              asnseq=0;
              asnitm=*blanks;
              asnupc=*blanks;
              asnmfgdte=0;
              asnexpdte=0;
              asnlot=*blanks;
              asnlpn=*blanks;
              pos = 0;
              relpos = 0;
              prvpos = 6;
              dow forever = forever;
                pos = %scan('@' : pUCI: prvpos);
                if pos >0;
                  relpos = relpos + 1;
                  select;
                    when relpos=1;
                      // End of PO seq
                      monitor;
                        asnseq = %dec(%subst(pUCI:prvpos:(pos)-
                                         (prvpos)):5:0);
                      on-error;
                        asnseq=*zeros;
                      endmon;
                      prvpos = pos+1;
                    when relpos=2;
                      // End of po item
                      monitor;
                        asnitm = %subst(pUCI:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnitm=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=3;
                      // End of upc
                      monitor;
                        asnupc = %subst(pUCI:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnupc=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=4;
                      // End of Msg Date
                      monitor;
                        asnmfgdte = %dec(%subst(pUCI:prvpos:(pos)-
                                         (prvpos)):8:0);
                      on-error;
                        asnmfgdte=0;
                      endmon;
                      prvpos = pos+1;
                    when relpos=5;
                      // End of Exp Date
                      monitor;
                        asnexpdte = %dec(%subst(pUCI:prvpos:(pos)-
                                         (prvpos)):8:0);
                      on-error;
                        asnexpdte=0;
                      endmon;
                      prvpos = pos+1;
                    when relpos=6;
                      // End of lot
                      monitor;
                        asnlot = %subst(pUCI:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnlot=*blanks;
                      endmon;
                      prvpos = pos+1;
                      leave;
                    other;
                      leave;
                  endsl;
                else;
                  leave;
                endif;
              enddo;
              exec sql select * into :parec
                    from poasn
                 where pawhse=:pWhse and papo=:pPo and
                       paseq=:asnSeq and paitem=:asnItm and
                       palpn=:plpn and palcns=' ' and
                       paupc=:asnupc and pamfgdt=:asnmfgdte and
                       pamfgexp=:asnexpdte and palot=:asnlot;
              if sqlstt = sqlSuccess;
                upcctr = 1;
                pPO# = paPO;
                pLpn = paLpn;
                pItem = paItem;
                // only put upc in UCI field if one is not already
                // represented in PIRHOLD with session and PODTLUCI
                // key for po or super po.  If one exist this signifies
                // M135xx has added one for a new upc to be associated
                exec sql select count(*) into :reccnt
                            from pirhold
                       where hosess=:psess and hokey='PODTLUCI'
                             and hokey=:papo;
                if sqlstt <> sqlsuccess or reccnt =0;
                  exec sql select count(*) into :reccnt
                            from pirHold,pospo
                       where hosess=:psess and hotype='PODTLUCI'
                            and hokey=puspo and pupo=:papo
                            and puwhse=:pWhse;
                  if sqlstt <> sqlSuccess or reccnt=0;
                    pUci=paupc;
                  else;
                    pUci=*blanks;
                  endif;
                else;
                  pUci=*blanks;
                endif;
                exsr chkforpcm;
              else;
                upcctr = 2;
                pUCI = *blanks;
              endif;
      /end-free
740 Ac                   endsr

     *
     *----------------------------------------------------------------
     *
     *  Process  Process the Uci sent.
     *
     C     Process       begsr
     *

     c                   eval      $bcGtinSent = '0'
     c                   if        pUci  <> *blanks
      * retrieve vendor for regular po
      /free
        exec sql select * into :phrec
             from pohdr
             where phwhse = :pWhse
               and phpo   = :pPO;

710b     // Move Blanks if not found  (710b)
710b
710b      if Sqlstt <> sqlSuccess;
710b         phven = 0;
710b      endif;

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
     c                   endif
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
700cAc                   eval      ucidata1 = $cvtdata
700cAc                   eval      ucidata2  = $cvtdata2
      * Load UPC
     c                   if        $bcGtinSent
     c                   eval      w1upcd = $bcGtin
     c                   else
      ** Needed this because all barcodes are not gs1
     c                   eval      w1upcd = pUci
     c                   endif
     *
     *  UPC code not on file.
     *
     C                   if        w1upcd <> *blanks
     *
     *  Extract UPC code from entered string.
     *
     c                   if        w1upcd <> *blanks
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w1upcd
     c                   if        $bcGtinSent
     c                   eval      $cbbar = $bcGtin
     c                   endif
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
     C                   movel     $cbv2         $cstr
     C                   endif
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc
     *   Check if mulitple items exist for one UPC code.
     *   We only care if there are multiple items on the po being received
     *   Consider all po's if super po being received.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
     *
     c                   exsr      zzchkupc
     *
      * lets allow the user to add using UC112
     c
     C                   if        upcctr = 0
     c                   eval      multitem = 'N'
     C                   exsr      zm029
     C                   endif
     *   Multiple items exist for UPC
     C                   if        upcctr = 1
     c                   eval      multitem = 'N'
     c                   eval      pitem = svupci
700cA /free
700cA   // Is this item set for UCI Receiving
700cA   exsr clr$item;

700cA   $itWhse = pwhse;
700cA   $ititem = pitem;

700cA   $dricommand = '*ITEM';
700cA   $drisubcmd  = '%GETALL';
700cA   $drisys2upd = 'D';
700cA   chk4err = *on;
700cA   exsr zzzdricop;
700cA   if error = *on;
700cA     $ifrcvmth = '1';
700cA   endif;
700cA   // if uci receiving - need to check the uci scanned
740 D   //if $ifrcvmth = '2';
740 M   if $ifrcvmth = '2';
700cA     //check to make sure UCI barcode does not already exist
700cA     puci = %TrimL(puci);
700cA     exsr clr$uciinfo;

700cA     $uiWhse = pwhse;
700cA     $uiuci  = pUCI;
700cA     $uiitem = pitem;

700cA     $dricommand = '*UCIINFO';
700cA     $drisubcmd  = '%CHKACTV';
700cA     $drisys2upd = 'D';
700cA     chk4err = *on;
700cA     exsr zzzdricop;
700cA     if error;
700cA     endif;
700cA     // if return is *EXIST seton error
700cA     if $drireturn = '*EXIST';
700cA       error = *on;
700cA       pmessage = 'UCI already exist';
700cA     else;
700cA       // no error write extracted info to pirhold for later use
700cA    // create pirhold extracted data
700cA    hotype = 'PODTLUCIE';
700cA    pokey = %trim(pPO);
700cA    chain (psess: hotype: pokey) pirhold;
700cA    if %found(pirhold);
700cA      hodata = pirhldueds;
700cA      update horec1;
700cA    else;
700cA      exsr getcurrstamp;
700cA      hoaddts = currstampsys;
700cA      hoadduc = currstampuc;
700cA      hosess = psess;
700cA      hokey = pokey;
700cA      hodata = pirhldueds;
700cA      write horec1;
700cA    endif;
700cA
700cA     endif;
700cA   endif;
700cA /end-free
     C                   endif
     C                   if        upcctr > 1
     c                   eval      multitem = 'Y'
     C                   exsr      builditem
     C                   endif
     *
     *    If extract of UPC comes back invalid, treat UPC as if not
     *    on file.
     C                   other
     C                   exsr      zm029
     *    Log barcode conversion error.
     C                   exsr      zm0105
     C                   endsl
     c                   endif
      /free
        if noupc = *off;
          select;
            // single PO being processes.
            when pSuper = 'N' and upcctr = 1;
              setll (pwhse:ppo:svupci) podtl1;
              reade (pwhse:ppo:svupci) podtl1;
              if %eof(podtl1);
                exsr zm027;
              else;
                pitemseq = pdseq;
              endif;
            // Super PO being processed.
            when pSuper = 'Y' and upcctr = 1;
740 A         // if LPN sent then check POASN versus PODTL
740 A         if pLpn <> *blanks;
740 A           exec sql select pospo3.* into :pujrec
740 A                    from poasn, pospo3
740 A               where pawhse=puwhse and papo=pupo
740 A                      and paseq  = pdseq
740 A                      and paitem = pditem
740 A                      and pawhse = :pWhse
740 A                      and paitem = :svupci
740 A                      and puspo  = :pPO
740 A                      and palpn  = :pLpn
740 A                      and palcns = ' ';
740 A         else;
                exec sql select * into :pujrec
                         from pospo3
                         where puwhse = :pWhse
                           and pditem = :svupci
                           and puspo  = :pPO;
740 A         endif;
              If sqlstt = sqlSuccess;
                pitemseq = sp_pdseq;
700bA           pPO# = sp_pdpo;
                pPOonSuper = sp_pdpo;
740 A         else;
740 A           if sqlstt = '21000' and m134AsnCall;
740 A             upcctr=2;
740 A             pPO#=papo;
740 A           endif;
              endif;
          endsl;
        endif;
      /end-free
     C                   endif
     *
     C     endprocess    endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  CHKFORPCM   Check to see if PCM needs to be entered
700bA*
700bAC     chkforpcm     begsr
700bA /free
700bA    // now check to see if Header PCM needs to be entered
700bA    pcmwhse = pwhse;
700bA    pcmcmd = '*POHDR';
700bA    pcmlvl = 'RCVH';
700ba    pcmtyp = ' ';
700bA    pcmsup = 'N';
700bA    pcmseq = 0;
700bA    pcmitm = ' ';
710aA    if psuper = 'Y';
710aA      CHKPCM(pcmcmd: pcmwhse: pcmlvl: pcmtyp:
710aA             ppo#: pcmseq: pcmsup: pcmitm: pentpcm);
710aA    else;
700bA      CHKPCM(pcmcmd: pcmwhse: pcmlvl: pcmtyp:
700bA             ppo: pcmseq: pcmsup: pcmitm: pentpcm);
710aA    endif;
700bA    // if we return from checking header pcm with a N, check for detail
700bA    if pentpcm = 'N';
700bA      pcmwhse = pwhse;
700bA      pcmcmd = '*PODTL';
700bA      pcmlvl = 'RCVI';
700bA      pcmtyp = ' ';
700bA      pcmsup = 'N';
700bA      pcmseq = pitemseq;
700bA      pcmitm = pitem;
710aA      if psuper = 'Y';
710aA        CHKPCM(pcmcmd: pcmwhse: pcmlvl: pcmtyp:
710aA               ppo#: pcmseq: pcmsup: pcmitm: pentpcm);
710aA      else;
700bA        CHKPCM(pcmcmd: pcmwhse: pcmlvl: pcmtyp:
700bA               ppo: pcmseq: pcmsup: pcmitm: pentpcm);
710aA      endif;
700bA    endif;
700bA /end-free
700bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKUPC Check upc.
     *
     C     zzchkupc      begsr
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
      /free
        upcctr = 0;
        svupci = ' ';
        setll (pWhse:w1upc) upc4;
        dow not %eof(upc4);
          reade (pWhse:w1upc) upc4;
          if %eof(upc4);
            leave;
          endif;
700eA     // need to determine if this item is a branded item
700eA     bCmd = '*GET4BITM';
700eA     bBrand = ' ';
700eA     bParentItm = ' ';
700eA     bBrandItm = upitem;
700eA     bBrandFlg = ' ';
700eA     GetBranded(bCmd: pwhse: bparentItm: bBrand:
700eA                bBrandItm: bBrandFlg);
700eA     if bBrandFlg = 'Y';
700eA       upitem = bparentItm;
700eA       saveBrandItm = bBrandItm;
700eA     endif;
          if svupci <> upitem;
            // only increment counter if item is found on the po
            select;
              when psuper = 'N';
                FoundonPO = '0';
                exec sql select * into :pdrec
                         from podtl
                         where pdwhse = :pWhse
                           and pditem = :upitem
                           and pdpo   = :pPO;
700aM           If sqlstt = sqlSuccess;
                  FoundonPO = '1';
                endif;
700aA           If sqlstt = '21000';
700aA             FoundonPO = '2';
700aA           endif;

              when psuper = 'Y';
                FoundonPO = '0';
                FoundonSupers = '0';
740 A           // if LPN sent then check POASN versus PODTL
740 A           if pLpn <> *blanks;
740 A             exec sql select poasn.* into :parec
740 A                      from poasn, pospo3
740 A                 where pawhse=puwhse and papo=pupo
740 A                        and paseq  = pdseq
740 A                        and paitem = pditem
740 A                        and pawhse = :pWhse
740 A                        and paitem = :upitem
740 A                        and puspo  = :pPO
740 A                        and palpn  = :pLpn
740 A                        and palcns = ' ';
740 A           else;
                  exec sql select * into :pujrec
                           from pospo3
                           where puwhse = :pWhse
                             and pditem = :upitem
                             and puspo  = :pPO;
740 A           endif;
                If sqlstt = sqlSuccess;
                  FoundonPO = '1';
                endif;
                If sqlstt = '21000';
740 A             if pLpn<>*blanks;
740 A               exec sql select count(*) into :lpncnt from
740 A                       (select paitem,count(*) from poasn,pospo3 where
740 A                          pawhse=puwhse and papo=pupo
740 A                            and paseq  = pdseq
740 A                            and paitem = pditem and
740 A                          palpn=:pLpn and palcns=' '  and
740 A                          pawhse=:pWhse and paitem=:upitem
740 A                          and puspo=:pPO
740 A                          group by paitem) as derived;
740 A               if sqlStt=sqlSuccess and lpncnt=1;
740 A                 FoundonPO = '1';
740 A                 m134AsnCall=*on;
740 A               else;
740 A                 FoundonPO = '2';
740 A                 FoundonSupers = '1';
740 A               endif;
740 A             else;
700ad               //FoundonPO = '1';
700aM               FoundonPO = '2';
                    FoundonSupers = '1';
740 A             endif;
                endif;
            endsl;
            if FoundonPO = '1';
              upcctr = upcctr + 1;
              svupci = upitem;
            endif;
700aA       if FoundonPO = '2';
700aA         upcctr = upcctr + 2;
700aA         svupci = upitem;
700aA       endif;
            if FoundonSupers = '1';
              upcctr = upcctr + 1;
              svupci = upitem;
            endif;
          endif;
        enddo;
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
700dA   uciNotFound = 'Y';
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *    PO20027  Item not on PO.
     *
     C     zm027         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  BuildItem    Build ItemList field for return.
     *
     C     builditem     begsr
     *
     *    Multiple Items exist for UPC, select item.
     *    Load headings.
     C*                  eval      w6txt1 = hdr01
     C*                  eval      w6txt2 = 'Itm:'
     *    Process for one po
      /free
        itemlist = '&val_PDITEM=';
        setll (pWhse:w1upc) upc4;
        dow not %eof(upc4);
          reade (pWhse:w1upc) upc4;
          if %eof(upc4);
            itemlist = %trim(itemlist) + '&rls_PDITEM=LS';
            leave;
          endif;
          itemlist = %trim(itemlist) + ' ' + upitem;
        enddo;
      /end-free
     *
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
700cA*----------------------------------------------------------------
700cA*  clr$item  Clear $item data structure fields
700cA*----------------------------------------------------------------
700cA
700cAC     clr$item      begsr
700cAC                   eval      savever# = $itver#
700cAC                   clear                   $item
700cAC                   clear                   $item2
700cAC                   eval      $itver# = savever#
700cAC                   endsr


700cA*----------------------------------------------------------------
700cA*  clr$uciinfo  Clear $uciinfo data structure fields
700cA*----------------------------------------------------------------

700cAC     clr$uciinfo   begsr
700cAC                   eval      savever# = $uiver#
700cAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
700cAC                   eval      $uiver# = savever#
700cAC                   eval      $uiaddemp = 0
700cAC                   eval      $uiaddusr = #curruser
700cAC                   eval      $uiaddpgm  = #pgm
700cAC                   eval      $uiaddjob  = #job
700caC                   eval      $uiaddnbr = #jobnbr
700cAC                   endsr

700cA*----------------------------------------------------------------
700cA*  zzzdricop  Call DRICOP
700cA*----------------------------------------------------------------
700cA
700cAC     zzzdricop     begsr
700cAC                   eval      error = *off
700cA
700cAC                   select
700cAC                   when      $dricommand = '*ITEM'
700cAC                   eval      $dridata = $item
700cAC                   eval      $dridata2 = $item2
700cAC                   when      $dricommand = '*UCIINFO'
700cAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
700cAC                   endsl
700cA
700cAC                   if        $dricommand = '*ITEM'
720aAC                             or $dricommand = '*UCIINFO'
700cAC                   call(e)   'DRICOP'
700cAC                   parm                    $dricommand
700cAC                   parm                    $drisubcmd
700cAC                   parm                    $drisys2upd
700cAC                   parm      #pgm          $driprogram
700cAC                   parm      ' '           $drireturn
700cAC                   parm      ' '           $drimessage
700cAC                   parm                    $dridata
700cAC                   parm                    $dridata2
700cAC                   else
700cAC                   call(e)   'DRICOP'
700cAC                   parm                    $dricommand
700cAC                   parm                    $drisubcmd
700cAC                   parm                    $drisys2upd
700cAC                   parm      #pgm          $driprogram
700cAC                   parm      ' '           $drireturn
700cAC                   parm      ' '           $drimessage
700cAC                   parm                    $dridata
700cAC                   endif
700cA
700cAC                   select
700cA
700cAC                   when      chk4err and %error
700cAC                   eval      error = *on
700cA
700cAC                   when      chk4err and $drireturn <> '*OK'
700cAC                   eval      error = *on
700cA
700cAC                   endsl
700cA
700cAC                   select
700cAC                   when      $dricommand = '*ITEM'
700cAC                   eval      $item = $dridata
700cAC                   eval      $item2 = $dridata2
700cAC                   when      $dricommand = '*UCIINFO'
700cAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
700cAC                   endsl
700cA
700cAC                   eval      chk4err = *off
700cAC     enddricop     endsr
