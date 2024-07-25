      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R30000     Return Slot Quantity and Available for Replen Rpt
     *
     *  14 August 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
720 A*    08/14/18  KDE  7.20
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fslot2     if   e           k disk
     Fslot4     if   e           k disk    rename(slrec:slrec4)
     f                                     prefix(s_)
     Fpiritem1  if   e           k disk
     Fslotstr   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d  pErrRtn        s             40
     d  rtnStk         s             30
     d  rtnAvl         s             30
     d  itemStk1       s              5  0
     d  itemStk2       s              5  0
     d  itemStk3       s              5  0
     d  itemAvl1       s              5  0
     d  itemAvl2       s              5  0
     d  itemAvl3       s              5  0
     d  slavl1         s              5  0
     d  slavl2         s              5  0
     d  slavl3         s              5  0
     d  stkqty         s              5  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pSessId        s             40
     d  pUser          s             10
     d  pWhse          s              3p 0
     d  pWhdp          s              5
     d  pfrmDisp       s             12
     d  ptoDisp        s             12
     d  pItem          s             15
     d  pOutStr        s            256    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d formatQty       pr             9
530aAd  wkQty                         5  0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pWhse       Warehouse
     *      pWhdp       Department
     *      pfrmDisp    From Display
     *      ptoDisp     To Display
     *      pItem       Item
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pWhse
     c                   parm                    pWhdp
     c                   parm                    pfrmDisp
     c                   parm                    ptoDisp
     c                   parm                    pitem
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrRtn = '';

         // Determine if Staging Replenishment

         if %trim(ptoDisp) = *blanks;
            // if Staging slot then tally quantities
            // for all staging slots including rpa slots
            // and return this value.  Ignore negatives.
            setll (pWhse:pWhdp:pItem) slot4;
            reade (pWhse:pWhdp:pItem) slot4;
            itemstk1=*zeros;
            itemstk2=*zeros;
            itemstk3=*zeros;
            itemavl1=*zeros;
            itemavl2=*zeros;
            itemavl3=*zeros;
            dow not %eof(slot4);
               if %trim(s_slstat) <> 'Z';
                  // make sure slot is in Store Zone
                  chain (pWhse:pWhdp:s_sldisp) slotstr;
                  if %found(slotstr);
                     itemstk1 = itemstk1 + s_slstk1;
                     itemstk2 = itemstk2 + s_slstk2;
                     itemstk3 = itemstk3 + s_slstk3;
                     itemavl1 = itemavl1 + (s_slstk1+s_slrcv1) -
                                (s_sltfr1+s_slpck1) - s_slalc1;
                     itemavl2 = itemavl2 + (s_slstk2+s_slrcv2) -
                                (s_sltfr2+s_slpck2) - s_slalc2;
                     itemavl3 = itemavl3 + (s_slstk3+s_slrcv3) -
                                (s_sltfr3+s_slpck3) - s_slalc3;
                  endif;
               endif;
               reade (pWhse:pWhdp:pItem) slot4;
            enddo;
            slstk1 = itemstk1;
            slstk2 = itemstk2;
            slstk3 = itemstk3;
            slavl1 = itemavl1;
            slavl2 = itemavl2;
            slavl3 = itemavl3;
         else;
            // Non Staging Replenishment simply returns
            // Stock Quantity and Available Quantity
            // of TO Slot
            setll (pWhse:pWhdp:ptoDisp) slot2;
            reade (pWhse:pWhdp:ptoDisp) slot2;
            if not %equal(slot2);
               slstk1=*zeros;
               slstk2=*zeros;
               slstk3=*zeros;
               slavl1=*zeros;
               slavl2=*zeros;
               slavl3=*zeros;
            else;
               slavl1 = (slstk1+slrcv1) -
                        (sltfr1+slpck1) - slalc1;
               slavl2 = (slstk2+slrcv2) -
                        (sltfr2+slpck2) - slalc2;
               slavl3 = (slstk3+slrcv3) -
                        (sltfr3+slpck3) - slalc3;
            endif;
         endif;

         // format slot quantity and available values
         rtnStk = formatQty(slstk1) + ' ' + itum1;
         if slstk3 <> *zeros;
         //   stkqty = slstk2;
         //   rtnStk = %trimr(rtnStk) + ' ' +
         //            formatQty(stkqty) + ' ' + itum2;
         //   stkqty = slstk3;
         //   rtnstk = %trimr(rtnStk) + ' ' +
         //            formatQty(stkqty) + ' ' + itum3;
         else;
            if slstk2 <> *zeros;
          //     stkqty = slstk2;
           //    rtnStk = %trimr(rtnStk) + ' ' +
            //            formatQty(stkqty) + ' ' + itum2;
            endif;
         endif;

         //  available quantities formatted
         rtnAvl = formatQty(slavl1) + ' ' + itum1;
         if slavl3 <> *zeros;
          //  stkqty = slavl2;
          //  rtnAvl = %trimr(rtnAvl) + ' ' +
          //           formatQty(stkqty) + ' ' + itum2;
           // stkqty = slavl3;
            //rtnstk = %trimr(rtnStk) + ' ' +
              //       formatQty(stkqty) + ' ' + itum3;
         else;
            if slAvl2 <> *zeros;
          //     stkqty = slavl2;
          //     rtnAvl = %trimr(rtnAvl) + ' ' +
          //              formatQty(stkqty) + ' ' + itum2;
            endif;
         endif;

         // Build Json String
          pOutStr = '{'
                 +  '"rtnStk":"'  + %trimr(rtnStk) + '",'
                 +  '"rtnAvl":"'  + %trimr(rtnAvl) + '"' +
                 '}';
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

          // get item record
          chain (pWhse:pWhdp:pItem) piritem1;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  formatQty   Right adjust Quantity to keep consisent on screen
     *----------------------------------------------------------------

     p formatQty       b
     d formatQty       pi             9
     d  wkQty                         5  0

     *  Local variables
     d  newQty         s              9

      /free

         // Right justify incoming Quantity

         evalr newQty = %trimr(%char(wkqty));

         // if positive quantity add additional space for positive sign
         // so it aligns with negatives since they have a - sign
         if wkqty>=0;
            evalr newQty = '  ' + %trimr(newQty);
         endif;

         return newQty;

      /end-free

     p formatQty       e
