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
     *  FR14600      PO Receiving - Reload from Pirhold.
     *  11 March 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    03/11/15  LMC  7.00
     *      - Created.
     *
700aA*    04/13/16  DAS  7.00a
     *      - Revised %editc('Y') to %editw('00/00/00'). Re: Date field
     *        code being used in MRC screens needs the leading zero.
700bA*    06/09/16  LMC  7.00b
     *      - Branded Item changes.                                   d
740 A*    07/17/20  KDE  7.40
     *      - Always reload for ASN/LPN processing                    d
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOseq      Purchase Order seq
     *      pPOitem     Purchase Order item
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,C#PIRHLDPO

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D psession        s             40    varying
     D pWhse           s              3p 0
     D pPo             s              9
     D pposeq          s              5p 0
     D pPoitem         s             15
     D  pOutStr        s           1024    varying

     D pItem           s             15
     D pItemseq        s              5  0
     D pPOonSuper      s              9
     D pMessage        s             99
     D*reload          s              1
     D pokey           s             50
     D psr             s              1
     D keydate         s              6  0

     D client          s             10
     D clientloc       s             10

     d uhodata         s                   like(Hodata)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D horec         E Ds                  Extname(pirhold)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    psession
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOseq
     c                   parm                    pPOitem
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        //reload = ' ';
        // get pirhold record
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        exec sql select * into :horec
           from pirhold
           where hosess = :psession
             and hotype = 'PODTL'
             and hokey  = :pokey;
        If sqlstt = sqlSuccess;
          pirhldpods = hodata;
        else;
          W1QRC1 = 0;
          W1QRC2 = 0;
          W1QRC3 = 0;
          reload = 'N';
        endif;
740 A   if $pLpn <> *blanks;
740 A     reload = 'Y';
740 A   endif;
        if reload = 'Y';
          exsr process;
        endif;
         // Put together JSON string

         pOutStr = '{'
                +  '"GFN0501":"'  + %char(w1qrc1) + '",'
                +  '"GFN0503":"'  + %char(w1qrc2) + '",'
                +  '"GFN0504":"'  + %char(w1qrc3) + '",'
                +  '"GFA0111":"'  + %trimr(psr) + '",'
                +  '"GFA0112":"'  + %trimr(directed) + '",'
                +  '"GFN0502":"'  + %char(w1plts) + '",'
                +  '"GFN09201":"'  + %char(w1dwgt) + '",'
                +  '"GFN0401":"'  + %char(w1pti) + '",'
                +  '"GFA3001":"'  + %trimr(w1lotc) + '",'
                +  '"GFA1001":"'  + %trimr(w1brand) + '",'
                +  '"GFA0102":"'  + %trimr(w1avg) + '",'
                +  '"CALC21":"'  + %trimr(w1stat) + '",'
                +  '"CALC22":"'  + %trimr(osscode) + '",'
                +  '"CALC23":"'  + %trimr(ossprint) + '",'
                +  '"CALC26":"'  + %trimr(ossdev) + '",'
                +  '"CALC24":"'  + %char(ossplates) + '",'
700aD           //+  '"CALC11":"'  + %trim(%editc(keydate:'Y')) + '",'
700aM           +  '"CALC11":"'  + %trim(%editw(keydate:'0  /  /  ')) + '",'
                +  '"GFA0102":"'  + %trimr(w1avg) + '",'
                +  '"GFA0101":"'  + %trimr(kilolbs) + '",'
                +  '"GFA1501":"'  + %trimr($ldecvalue) + '",'
700bA           +  '"CALC30":"'  + %trimr(BrandedItm) + '",'
                +  '"ReLoad":"'  + %trimr(reload) + '"';

         // Close off the JSON string
         pOutStr += '}';

         // remove the reload field from the hold file.
         reload = 'N';
         uhodata = pirhldpods;
         pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
         exec sql update pirhold
                  set hodata  = :uhodata
           where hosess = :psession
             and hotype = 'PODTL'
             and hokey  = :pokey;
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
     *----------------------------------------------------------------
     *
     *  Process  Process the Uci sent.
     *
     C     Process       begsr
     *
      /free
        //reload = 'Y';
        if psrcvreq = 'Y' or psrusr = 'Y';
          psr = 'Y';
        else;
          psr = 'N';
        endif;
        if svexdt > 0;
          keydate = svexdt;
        endif;
        if svmfdt > 0;
          keydate = svmfdt;
        endif;
      /end-free

     *
     C     endprocess    endsr
