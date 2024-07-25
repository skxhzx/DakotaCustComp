      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FI10600H     Purchase Order Receiving License entry Header
     *  30 July 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    07/30/14  LMC  6.50
     *      - Created.
     *
700aA*    12/17/15  LMC  7.00a
     *      - Retrieve the number of pallets received/licensed.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

417cAFpirhold   if   e           k disk    rename(horec:holcn)
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n

     D pokey           s             50
     D psessid         s             40
     D pWhse           s              3  0
     D pPo             s              9
     D pPOSeq          s              5  0
     D pPoItem         s             15
     D  pOutStr        s           1024    varying

     D sumqty1         s              5p 0
     D sumqty2         s              5p 0
     D sumqty3         s              5p 0
     D keytype         s             10
     D worktiehi       s             25
     D splmsg          s             25
700aAD LicenseCnt      s              5p 0
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D horec         E Ds                  Extname(pirhold)
     *----------------------------------------------------------------
     * Data structure
      /copy qcopysrc,C#PIRHLDPO
      /copy qcopysrc,C#PIRHLLCN
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOseq      Purchase Order seq
     *      pPOItem     Purchase Order Item
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------
     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             debug = (bdfflag = 1);
           else;
             debug = *off;
           endif;
         endif;

         // build key field
         pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);

         exec sql select * into :horec
              from pirhold
              where hosess = :pSessId
                and hotype = 'PODTL'
                and hokey  = :pokey;

         If sqlstt = sqlSuccess;
           pirhldpods = hodata;
         endif;
         // we will retrieve all the plates to accumulate the qty per uom
         // retrieve all the pirhold POLCNS records
700aA    LicenseCnt = 0;
         eval keytype = 'POLCNS';
         setll (psessid: keytype) pirhold;
         dow not %eof(pirhold);
           reade (psessid: keytype) pirhold;
           if %eof(pirhold);
             leave;
           endif;
700aA      LicenseCnt = LicenseCnt + 1;
           pirhllcnds = hodata;
           select;
             when h1uom = w1um1;
               sumqty1 = sumqty1 + h1qty;
             when h1uom = w1um2;
               sumqty2 = sumqty2 + h1qty;
             when h1uom = w1um3;
               sumqty3 = sumqty3 + h1qty;
           endsl;
         enddo;

         // build tie hi
         worktiehi = 'Tie/High  ' + %char(wotie) + ' / ' + %char(wohi);
         splmsg = ' ';
         select;
           when xdockflg = 'Y';
             splmsg = 'Cross Dock';
           when directed = 'Y';
             splmsg = 'Directed Putaway';
           when PSRcvReq = 'Y' or
                psrusr = 'Y';
             splmsg = 'Pick Slot Receiving';
         endsl;
         // Put together JSON string

         pOutStr = '{'
                +  '"woitem":"'  + %trimr(woitem) + '",'
                +  '"wositm":"'  + %trimr(wositm) + '",'
                +  '"wolbl":"'  + %trimr(wolbl) + '",'
                +  '"wolbls":"'  + %trimr(wolbls) + '",'
                +  '"wodsc1":"'  + %trimr(wodsc1) + '",'
                +  '"wodsc2":"'  + %trimr(wodsc2) + '",'
                +  '"wopdsc":"'  + %trimr(wopdsc) + '",'
                +  '"wotie":"'  + %trimr(worktiehi) + '",'
                +  '"splmsg":"'  + %trimr(splmsg) + '",'
                +  '"w1qrc1":"'  + %char(w1qrc1) + '",'
                +  '"w1qrc2":"'  + %char(w1qrc2) + '",'
                +  '"w1qrc3":"'  + %char(w1qrc3) + '",'
                +  '"lcnrc1":"'  + %char(sumqty1) + '",'
                +  '"lcnrc2":"'  + %char(sumqty2) + '",'
                +  '"lcnrc3":"'  + %char(sumqty3) + '",'
700aA           +  '"pltrcv":"'  + %char(w1plts) + '",'
700aA           +  '"pltlcn":"'  + %char(licensecnt) + '",'
                +  '"w1um1":"'  + %trimr(w1um1) + '",'
                +  '"w1um2":"'  + %trimr(w1um2) + '",'
                +  '"w1um3":"'   + %trimr(W1um3) + '"';

         // Close off the JSON string
         pOutStr += '}';

         if debug;
           exsr wrtDebugParms;
         endif;

         //if debug and %error();
         //  exsr wrtDebugError;
         //endif;

         *inlr = *on;

      /end-free

650aA*----------------------------------------------------------------
650aA*  *INZSR   Initialization subroutine
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pSessId=' + %trimr(pSessId) + ','
                  + '&pWhse=' + %char(pWhse) + ','
                  + '&pPO=' + %trimr(pPO) + ','
                  + '&pPOItem=' + %trimr(pPOItem) + ','
                  + '&pOut=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = '&pSessId=' + %trimr(pSessId);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
