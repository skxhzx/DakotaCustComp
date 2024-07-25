      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FI14300H     Receiving CW totals entry Header
     *  10 December 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    12/10/15  LMC  7.00
     *      - Created.
700b *    10/14/16  LMC  7.00b
     *      - Enh: Find the double quotes replace with \".
     *        Then gui will be able to process the json without error.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

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

700bAD pos             s              2  0
700bAd dblqte          s              1    inz('"')
700bAd rpldblqte       s              2    inz('\"')
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
700bA    // let's check for our double quotes and replace
700bA    // woitem
700bA    pos = %scan(dblqte: woitem);
700bA    dow pos > 0;
700bA       woitem = %replace(rpldblqte: woitem: pos: %len(dblqte)) ;
700bA       if (pos+%len(rpldblqte) > %len(woitem));
700bA          pos = 0;
700bA       else;
700bA          pos = %scan(dblqte: woitem: pos+%len(rpldblqte));
700bA       endif;
700bA    enddo;

         // Put together JSON string

         pOutStr = '{'
                +  '"woitem":"'  + %trim(woitem) + '"';

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

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

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
