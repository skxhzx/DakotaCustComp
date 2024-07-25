      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  RMQTYMULT   ** Copy of RMQTY in PIRSQLPGM ***
      *  01 Mar 2017
      *  Kenneth Elder
      *
      *  Revisions:
      *
     *    03/01/17  KDE  7.10
     *      - Created.
710aA*    09/12/17  KDE  7.10a
     *      - Find issue with usage not calc correctly for non prod uom
720 A*    04/09/18  KDE  7.20
     *      - Enh:  Allow more Production quantity to be recorded than
     *        Bill of Material recorded, but DO NOT record negative
     *        waste.  This ends up reversing the extra quantity used
     *        by Production itself
     *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Fslot2     if   e           k disk
     Fslot3     if   e           k disk    prefix(s3_)
     f                                     rename(slrec:slrec3)
     Fitemprd1  if   e           k disk    prefix(r_)
     Fpiritem   if   e           k disk
     FpremWgt   if   e           k disk
     Fprddate1  if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

     d*copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
      *  12/20/02  DAS  4.16  Created
      *  07/12/08  DAS  6.00a
      *    - Added #curruser, #prog, #jobn
      *  03/02/11  MLB  6.40
      *    - Added #parms
      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
710 Ad Split           pr            50    dim(50)
710 AD  strToSplit                 1000    const
710 AD  delimiter                     3    const

650aA /copy qcopysrc,p.wrtsessl

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pItem          s             15
     D  pDisp          s             12
     D  pBegInv        s             13
     D  pEndNq         s              5p 0
     D  pEnd1Q         s              5p 0
     D  pEnd2Q         s              5p 0
     D  pEndPq         s              9p 4
     D  pEodWg         s              9p 3
     D  pUseNq         s              5p 0
     D  pUse1q         s              5p 0
     D  pUse2q         s              5p 0
     D  pUsePq         s              9p 4
     D  pErr           s             90

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     d rightStr        s           1024
     D wherelabel      s            300
     DreturnStatus     S             10I 0
     D Ok              c                   0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D len             s              3  0
     D SkipFirstRead   s               n
     D bfcoffset       s              3  0 inz(0)
     d currentdate     s              8
     d currentdttm     s             14
     D rc              s              3  0 inz(0)
     D LoadProduction  s               n
     D dbgflgExists    s               n
     D debug           s               n
     d pLine           s              3  0
700bAd pLine2          s              2
710 Ad splitAry        s           1000    dim(50)
     d wkError         s               n
     d wkRerr2         s             50
     d wrkIso          s               d   Inz(*sys)
     d wkEnd2          s              5  0
     d wkEnd1          s              5  0
     d wkEndN          s              5  0
     d wkPrd2          s              5  0
     d wkPrd1          s              5  0
     d wkPrdN          s              5  0
     d wipCount        s              5  0
     d TodayJul        s              5
     d jultoDay        s             12
     d numrecs         s              6  0
     d prdDte          s              8
     d remqty1         s              5  0
     d remqty2         s              5  0
     d remqtyn         s              5  0
     d TotalOH         s              5  0
     d TotalAdj        s              5  0
     d wkumq2          s              3  0
     d wkumq3          s              3  0
     d PrdWgt          s              9  4
     d pWstPq          s              9  4
     d pWstNq          s             13
     d pNrmSt          s             13
     d pNrmStb         s             13
     d pNrmStp         s             13
     d pNrmWip         s             13
     d pPrdWip         s              9  4
     d pQtyPrd         s              5  0
     d pprdapplied     s              9  4
     d pPrdExt         s              9  4
     d PrdBkd          s              1
     d PrdClr          s              1
     d wkstk1          s                   like(slstk1)
     d wkstk2          s                   like(slstk2)
     d wkstk3          s                   like(slstk3)
     d wipstk1         s                   like(slstk1)
     d wipstk2         s                   like(slstk2)
     d wipstk3         s                   like(slstk3)

     *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

     *  Division Prod Adjustment

     d divAdjust       ds
     d  PrdAdj                        9  4
     d   intAdjust                    5  0 overlay(PrdAdj)
     d   decAdjust                    4  0 overlay(PrdAdj:*next)

     *  Division Prod Ending Inv

     d divEnd          ds
     d  PrdEnd                        9  4
     d   intEnd                       5  0 overlay(PrdEnd)
     d   decEnd                       4  0 overlay(PrdEnd:*next)

     *  Division Days Prod Quantity

     d divPQty         ds
     d  PrdPQty                       9  4
     d   intPQty                      5  0 overlay(PrdPQty)
     d   decPQty                      4  0 overlay(PrdPQty:*next)

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D pwrkordr      E Ds                  Extname(pWrkordr)

417bAD PrdDay          ds            72
417bAD  urprjnq                       5p 0
417bAD  urprjb1                       5p 0
417bAD  urprjb2                       5p 0
417bAD  urprjpq                       9p 4
417bAD  uractnq                       5p 0
417bAD  uractb1                       5p 0
417bAD  uractb2                       5p 0
417bAD  uractpq                       9p 4
     d  urfgqty                       5p 0
     d  urscnwgt                      9p 3
     d  urtare                        9p 3
     d  urstat                        1

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse
     *      pItem        Raw Material Item
     *      pWstNq       Waste Normal Quantity
     *      pWstPq       Waste Production Breakdown
     *      pUseNq       Usage Normal Quantity
     *      pUse1q       Usage Breakdown 1 Qty
     *      pUse2q       Usage Breakdown 2 Qty
     *      pUsePq       Usage Production Breakdown
     *
     *    Returned Parameters
610aA*      pErr         Error String (*OK) if Ok
     *
     *----------------------------------------------------------------

     c     *entry        plist
650aAc                   parm                    pSessId          40
650aAc                   parm                    pUser            10
650aAc                   parm                    pPgm             20
     c                   parm                    pWhse
610aAc                   parm                    pItem
     c                   parm                    pDisp
     c                   parm                    pBegInv
     c                   parm                    pEndNq
     c                   parm                    pEnd1q
     c                   parm                    pEnd2q
     c                   parm                    pEndPq
     c                   parm                    pEodWg
     c                   parm                    pUseNq
     c                   parm                    pUse1q
     c                   parm                    pUse2q
     c                   parm                    pUsePq
     c                   parm                    pErr

      /free

700cA       // Set SQL default parms
700cA       exec sql
700cA         set Option Commit=*none, Dlyprp=*Yes,
700cA                    Closqlcsr = *ENDMOD;

          exsr init;
          exsr getSlot;
          *inlr = *on;

       //---------------------------------------------------------
       // chkForEnding - Check for non PRoduction Specific item
       //                If non prod specific put balance in Ending
       //                inventory instead of Waste
       //---------------------------------------------------------

          begsr chkForEnding;
710 A         clear splitAry;
710 A         // call procedure that splits normal waste quantity in breakdowns
710 A         splitARy = Split(pWstNq:'.');
710 A         rc = 1;
710 A         dow rc < 4;
710 A            if splitAry(rc) <> *blanks;
710 A               select;
710 A                  when rc = 1;
710 A                     pEndNq  = %Dec(%trim(splitAry(rc)):5:0);
710 A                  when rc = 2;
710 A                     pEnd1q  = %Dec(%trim(splitAry(rc)):5:0);
710 A                  when rc = 3;
710 A                     pEnd2q  = %Dec(%trim(splitAry(rc)):5:0);
710 A               endsl;
710 A            endif;
710 A            rc = rc + 1;
710 A         enddo;
710 A         pWstNq = '0';
710 A   //*    {Production Breakdown} -------------------------------
710 A         pendPq = pWstpq;
710 A         pWstpq = *zeros;
          endsr;

       //---------------------------------------------------------
       // getSlot - Get Item and Slot Information passed
       //---------------------------------------------------------

          begsr getSlot;

              chain (pWhse:pItem) piritem;
              if %found(piritem);
                 chain (pWhse:itwhdp:pDisp) slot2;
                 if %found(slot2);
                    pLine = slrlvl;
                    exsr getWip;
700 A       //      if (wipstk1<>0 or wipstk2<>0 or wipstk3<>0)
             //        and LoadProduction;
700 A        //        pEndNq = pEndNq + wipstk1;
700 A        //        pEnd1q = pEnd1q + wipstk2;
700 A        //        pEnd2q = pEnd2q + wipstk3;
700 A        //        pEndPq = pEndPq + pWstPq;
700 A        //     endif;
                    exsr sltCalc;
                    // in this version versus the MRC screen version (RMQTY) we always
                    // back unsed all in End Balance since this close process only
                    // records usage and waste.  It is only called for MultiDay lines
                    // when either the mfg quantity is met and it closes automatically
                    // or someone goes to the Work ORder screen and closes manually.
                    // Unlike the End of Day screen no person is deciding if the full
                    // remainder is waste or some is ending balance.
710 A               if LoadProduction;
710 A                  exsr chkforEnding;
710 A               endif;
700bA               exsr zzupprd;
                    if pBeginv = '0' or pBeginv=' ' or
                       pBeginv='.0000';
                       pErr = 'Beginning Inventory Zero !!!';
                    endif;
                 else;
                    // error returned for slot error;
                    pErr = 'Slot not found.  Adjustment Aborted';
                 endif;
              else;
                 // error for item being invalid
                    pErr = 'Item invalid.  Adjustment Aborted';
              endif;

          endsr;

       //------------------------------------------------------------
       // getWip - Get WIP information for specific mfg line and item
       //------------------------------------------------------------

          begsr getWip;

             // if initial load of item/slot then set flag
             if %trim(pBegInv) = 'Y';
                LoadProduction = *on;
             else;
                LoadProduction = *off;
             endif;

             wipstk1=0;
             wipstk2=0;
             wipstk3=0;

             setll (pwhse:pitem:'PR') slot3;
             reade (pwhse:pitem:'PR') slot3;

             dow not %eof(slot3);
                if s3_slaisl = 'WIP';
                   wipstk1 = wipstk1 + s3_slstk1;
                   wipstk2 = wipstk2 + s3_slstk2;
                   wipstk3 = wipstk3 + s3_slstk3;
                endif;
                reade (pwhse:pitem:'PR') slot3;
             enddo;

             pNrmWip = %trim(%char(wipstk1));
             if wipstk3 <> 0;
                pNrmWip = %trim(%char(wipstk1)) + '.' +
                   %trim(%char(wipstk2)) + '.' + %trim(%char(wipstk3));
             else;
                if wipstk2 <> 0;
                   pNrmWip = %trim(%char(wipstk1)) + '.' +
                     %trim(%char(wipstk2));
                endif;
             endif;

          // see if general WIP exists for given production station
          exec sql select count(*) into :wipcount
                   from slot where slaisl='WIP'
                   and slhand<>' ' and slstat='PR' and
                   (slstk1<>0 or slstk2<>0 or slstk3<>0);
          endsr;

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             pErr = ' ';
             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  PrdQtyConv - Convert Production Quantity to Dakota Quantity
     *----------------------------------------------------------------

      /free
       begsr PrdQtyConv;

          wkEndn=0;
          wkEnd1=0;
          wkEnd2=0;
          wkPrdn=0;
          wkPrd1=0;
          wkPrd2=0;
          pWstPq=0;
          // This routine converts quantities from Normal Breakdowns in
          // Slot master to Production Quantity Breakdown when an item
          // has had at least one Suggestion processed for the day that
          // used the Production Quantity Breakdown

          //if r_ipPrdq <> 0 or pUsePq<>0 or pEndPq<>0;
          if PrdBkD = 'Y';
             // convert to lowest unit of measure per the
             // normal Dakota breakdowns
             select;
                when itumq3<>0 and itumq2<>0;
                   wkstk1 = slstk1;
                   wkstk2 = slstk2;
                   wkstk3 = slstk3;
                   exsr setNrmStk;
                   pNrmStb = pNrmSt;
                   eval(h) result = r_ipPrdq / (itumq3*itumq2);
                   if result <> 0;
                      // if production breakdown is zero and normal qtys
                      // are not zero for either ending inventory or
                      // usage then calculate what production brkd would be
                      if pEndPq=0 and (pEndNq<>0 or pEnd1q<>0 or pEnd2q<>0);
                         eval(h) pEndPq =((pEndNq * (itumq3*itumq2)) +
                                          (pEnd1q * itumq3) +
                                           pEnd2q) * result;
                      endif;
                      if pUsePq=0 and (pUseNq<>0 or pUse1q<>0 or pUse2q<>0);
                         eval(h) pUsePq =((pUseNq * (itumq3*itumq2)) +
                                          (pUse1q * itumq3) +
                                           pUse2q) * result;
                      endif;
                      // determine Current inventory balance as Prod Qty
                      eval(h) PrdWgt =((slstk1 * (itumq3*itumq2)) +
                                       (slstk2 * itumq3) +
                                        slstk3) * result;
                      // determine WIP Quantity as Prod Qty
                      eval(h) pPrdWip =((wipstk1 * (itumq3*itumq2)) +
                                       (wipstk2 * itumq3) +
                                        wipstk3) * result;
                      // determine prod qty for Waste from other variables
                      eval pWstPq = PrdWgt - pUsePq - pEndPq;
                      // determine ending inventory if prod qty bd sent
                      eval(h) PrdEnd =(pEndPq / result);
                      // if decimals exists then round to next full
                      // breakdown 2.  Production Quantity is always
                      // recorded at the lowest level of normal warehouse
                      // breakdown quantities.  If here this item must be
                      // defined with a breakdown 2, hence we will round
                      // to the next breakdown 2 qty.
                      select;
                         when prdend > 0;
                            wkEnd2 = wkEnd2 +  intEnd;
                         when prdend < 0;
                            wkEnd2 = wkEnd2 -  intEnd;
                         other;
                      endsl;
                      select;
                         when decEnd > 0;
                            wkEnd2 = wkEnd2 +  1;
                         when decEnd < 0;
                            wkEnd2 = wkEnd2 -  1;
                         other;
                      endsl;
                      // determine Waste Adjustments
                      eval(h) PrdPQty =(pUsePq / result);
                      // if decimals exists then round to next full
                      // breakdown 2.  Production Quantity is always
                      // recorded at the lowest level of normal warehouse
                      // breakdown quantities.  If here this item must be
                      // defined with a breakdown 2, hence we will round
                      // to the next breakdown 2 qty.
                      select;
                         when prdpqty > 0;
                            wkPrd2 = wkPrd2 +  intPQty;
                         when prdpQty < 0;
                            wkPrd2 = wkPrd2 -  intPQty;
                         other;
                      endsl;
                      if decend = 0;
                         select;
                            when decpQty > 0;
                               wkPrd2 = wkPrd2 +  1;
                            when decpQty < 0;
                               wkPrd2 = wkPrd2 -  1;
                            other;
                         endsl;
                      endif;
                   endif;
                   if pEndNq=0 and pEnd1q=0;
                      pEnd2q = wkEnd2;
                   endif;
                   if pUseNq=0 and pUse1q=0;
                      pUse2q = wkPrd2;
                   endif;
                   // get normal warehouse projected quantities
                      TotalOh =((slstk1 * (itumq3*itumq2)) +
                                (slstk2 * itumq3) +
                                 slstk3);
                      TotalAdj = wkEnd2 + wkPrd2;
                      exsr zzupqty;
                      wkstk1 = remqtyn;
                      wkstk2 = remqty1;
                      wkstk3 = remqty2;
                      eval(h) pWstPq =((wkstk1 * (itumq3*itumq2)) +
                                       (wkstk2 * itumq3) +
                                        wkstk3) * result;
                      exsr setNrmStk;
                      pWstNq = pNrmSt;
                      // if moves remaining to End Balance instead of
                      // waste when ending balance is zero
                      // only do on initial load.  This way if user changes
                      // their changes will be reflected
                      if (pEndNq =0 and pEnd1q = 0 and pEnd2q = 0)
                           and LoadProduction;
                         if (wkStk1<0 or wkstk2<0 or wkstk3<0 or pWstPq<0);
               //           pUseNq = pUseNq + wkstk1;
               //           pUse1q = pUse1q + wkstk2;
               //           pUse2q = pUse2q + wkstk3;
               //           pUsePq = pUsePq + pWstPq;
                            wkstk1=0;
                            wkstk2=0;
                            wkstk3=0;
                         else;
          //                pEndnq = wkStk1;
          //                pEnd1q = wkStk2;
          //                pEnd2q = wkStk3;
          //                pEndPq = pWstPq;
          //                pWstNq = '0';
          //                pWstPq = .0000;
                         endif;
                      endif;
                when itumq2<>0;
                   wkstk1 = slstk1;
                   wkstk2 = slstk2;
                   wkstk3 = slstk3;
                   exsr setNrmStk;
                   pNrmStb = pNrmSt;
                   eval(h) result = r_ipPrdq / itumq2;
                   if result <> 0;
                      // if production breakdown is zero and normal qtys
                      // are not zero for either ending inventory or
                      // usage then calculate what production brkd would be
                      if pEndPq=0 and (pEndNq<>0 or pEnd1q<>0);
                         eval(h) pEndPq =((pEndNq * itumq2) +
                                           pEnd1q) * result;
                      endif;
                      if pUsePq=0 and (pUseNq<>0 or pUse1q<>0);
                         eval(h) pUsePq =((pUseNq * itumq2) +
                                           pUse1q) * result;
                      endif;
                      // determine Current inventory balance as Prod Qty
                      eval(h) PrdWgt = ((slstk1 * itumq2) +
                                         slstk2) * result;
                      // determine WIP Quantity as Prod Qty
                      eval(h) pPrdWip =((wipstk1 * itumq2) +
                                        wipstk2) * result;
                      // determine prod qty for Waste from other variables
                      eval pWstPq = PrdWgt - pUsePq - pEndPq;
                      // determine ending inventory balance for prod brkd
                      eval(h) PrdEnd =(pEndPq / result);
                      // if decimals exists then round to next full
                      // breakdown 1.  Production Quantity is always
                      // recorded at the lowest level of normal warehouse
                      // breakdown quantities.  If here this item must be
                      // defined with a breakdown 1 and not a breakdown 2,
                      // hence we will round to the next breakdown 1 qty.
                      // determine new Prod Qty BrkDwn Balance after adj
                      select;
                         when prdend > 0;
                            wkEnd1 = wkEnd1 +  intEnd;
                         when prdend < 0;
                            wkEnd1 = wkEnd1 -  intEnd;
                         other;
                      endsl;
                      select;
                         when decEnd > 0;
                            wkEnd1 = wkEnd1 +  1;
                         when decEnd < 0;
                            wkEnd1 = wkEnd1 -  1;
                         other;
                      endsl;
                      // determine Waste Adjustments
                      eval(h) PrdPQty =(pUsePq / result);
                      // if decimals exists then round to next full
                      // breakdown 2.  Production Quantity is always
                      // recorded at the lowest level of normal warehouse
                      // breakdown quantities.  If here this item must be
                      // defined with a breakdown 2, hence we will round
                      // to the next breakdown 2 qty.
                      select;
                         when prdpqty > 0;
                            wkPrd1 = wkPrd1 +  intPQty;
                         when prdpQty < 0;
                            wkPrd1 = wkPrd1 -  intPQty;
                         other;
                      endsl;
                      if decend = 0;
                         select;
                            when decpQty > 0;
                               wkPrd1 = wkPrd1 +  1;
                            when decpQty < 0;
                               wkPrd1 = wkPrd1 -  1;
                            other;
                         endsl;
                      endif;
                   endif;
                   if pEndNq=0;
                      pEnd1q = wkEnd1;
                   endif;
                   if pUseNq=0;
                      pUse1q = wkPrd1;
                   endif;
                   // get normal warehouse projected quantities
                      TotalOh = ((slstk1 * itumq2) +
                                  slstk2);
                      TotalAdj = wkEnd1 + wkPrd1;
                      exsr zzupqty;
                      wkstk1 = remqtyn;
                      wkstk2 = remqty1;
                      wkstk3 = remqty2;
                      eval(h) pWstPq =((wkstk1 * itumq2) +
                                        wkstk2) * result;
                      exsr setNrmStk;
                      pWstNq = pNrmSt;
                      // if moves remaining to End Balance instead of
                      // waste when ending balance is zero
                      // only do on initial load.  This way if user changes
                      // their changes will be reflected
                      if (pEndNq=0 and pEnd1q = 0) and LoadProduction;
                         if (wkStk1<0 or wkstk2<0 or pWstPq<0);
                      //    pUseNq = pUseNq + wkstk1;
                      //    pUse1q = pUse1q + wkstk2;
                      //    pUsePq = pUsePq + pWstPq;
                            wkstk1=0;
                            wkstk2=0;
                         else;
            //              pEndnq = wkStk1;
            //              pEnd1q = wkStk2;
            //              pEndPq = pWstPq;
            //              pWstNq = '0';
            //              pWstPq = .0000;
                         endif;
                      endif;
                other;
                   if r_ipPrdq <>0;
                      wkstk1 = slstk1;
                      wkstk2 = slstk2;
                      wkstk3 = slstk3;
                      exsr setNrmStk;
                      pNrmStb = pNrmSt;
                      // if production breakdown is zero and normal qtys
                      // are not zero for either ending inventory or
                      // usage then calculate what production brkd would be
                      if pEndPq=0 and pEndNq<>0;
                         eval(h) pEndPq = pEndNq * r_ipPrdq;
                      endif;
                      if pUsePq=0 and pUseNq<>0;
                         eval(h) pUsePq = pUseNq * r_ipPrdq;
                      endif;
                      // determine Current inventory balance as Prod Qty
                      eval(h) PrdWgt = slstk1 * r_ipPrdq;
                      // determine WIP quantity as Prod Qty
                      eval(h) pPrdWip = wipstk1 * r_ipPrdq;
                      // determine unit count if prod qty adjustment sent
                      eval(h) PrdEnd =(pEndPq / r_ipPrdq);
                      // if decimals exists then round to next full case
                      // we are only here because no normal breakdowns
                      // are defined.  Therefore, if any of the Production
                      // quantity are used we must record full case because
                      // the warehouse quantities ONLY have the full case
                      // defined.  Production Breakdown is ALWAYS converted
                      // back to warehouse normal and breakdown quantities
                      select;
                         when prdend > 0;
                            wkEndN = wkEndN +  intEnd;
                         when prdend < 0;
                            wkEndN = wkEndN -  intEnd;
                         other;
                      endsl;
                      select;
                         when decEnd > 0;
                            wkEndN = wkEndN +  1;
                         when decEnd < 0;
                            wkEndN = wkEndN -  1;
                         other;
                      endsl;
                      // determine Waste Adjustments
                      eval(h) PrdPQty =(pUsePq / r_ipPrdq);
                      // if decimals exists then round to next full
                      // breakdown 2.  Production Quantity is always
                      // recorded at the lowest level of normal warehouse
                      // breakdown quantities.  If here this item must be
                      // defined with a breakdown 2, hence we will round
                      // to the next breakdown 2 qty.
                      select;
                         when prdpqty > 0;
                            wkPrdN = wkPrdN +  intPQty;
                         when prdpQty < 0;
                            wkPrdN = wkPrdN -  intPQty;
                         other;
                      endsl;
                      // it is preventing two rounds on the same transaction
                      // if decend is not zero that means ending balanace
                      // rounded to next highest case.  If decided to let it
                      // round will need to remove this decend=0 check
                      if decend = 0;
                         select;
                            when decpQty > 0;
                               wkPrdN = wkPrdN +  1;
                            when decpQty < 0;
                               wkPrdN = wkPrdN -  1;
                            other;
                         endsl;
                      endif;
                      pEndNq = wkEndN;
                      pUseNq = wkPrdN;
                   // get normal warehouse projected quantities
                      TotalOh = slstk1;
                      TotalAdj = wkEndN + wkPrdN;
                      exsr zzupqty;
                      wkstk1 = remqtyn;
                      wkstk2 = remqty1;
                      wkstk3 = remqty2;
                      eval(h) pWstPq = wkstk1 * r_ipPrdq;
                      exsr setNrmStk;
                      pWstNq = pNrmSt;
                      // if moves remaining to End Balance instead of
                      // waste when ending balance is zero
                      // only do on initial load.  This way if user changes
                      // their changes will be reflected
                      if pEndNq = 0 and LoadProduction;
                         if (wkStk1<0 or pWstPq<0);
              //            pUseNq = pUseNq + wkstk1;
              //            pUse1q = pUse1q + wkstk2;
              //            pUsePq = pUsePq + pWstPq;
                            wkstk1=0;
                         else;
              //            pEndNq = %dec(pWstNq:5:0);
              //            pEndPq = pWstPq;
              //            pWstNq = '0';
              //            pWstPq = .0000;
                         endif;
                      endif;
                   endif;
             endsl;
          endif;

          // set color to red if any quantities are below zero
720 D     //if (pEndPq < 0 or pUsePq < 0 or pWstPq < 0
720 M     if (pEndPq < 0 or pUsePq < 0
720 M        or wkstk1<0 or wkstk2<0 or wkstk3<0);
720 D        //and pUsePq <> pPrdExt;
             PrdClr = 'R';
          else;
             PrdClr = 'G';
          endif;

720 A     // Zero Waste if it is negative.  Otherwise it will
720 A     // reverse production when it exceeds BOM value
720 A     if pWstpq < 0;
720 A        pWstpq=*zeros;
720 A     endif;

       endsr;

       //---------------------------------------------------------
       // getPrdNums - Return Production for the day associated to
       //              this Raw Material
       //---------------------------------------------------------

          begsr getPrdNums;

             pPrdExt = 0;
             pQtyPrd = 0;
             if pErr = ' ';
             // determine if production should be loaded
                // get raw material production information
                if itumq3 = 0;
                   wkumq3 = 1;
                else;
                   wkumq3 = itumq3;
                endif;
                if itumq2 = 0;
                   wkumq2 = 1;
                else;
                   wkumq2 = itumq2;
                endif;
                pNrmStb = ' ';
                pNrmStp = ' ';
                PrdWgt = 0;

                // build sql to retrieve daily production for selected
                // Raw Material for current days production

700bA /end-free
700bAc                   move      pline         pline2
700bA /free
               SqlStmt='select urprjnq,urprjb1,urprjb2,urprjpq,' +
                            'uractnq,uractb1,uractb2,uractpq,' +
                            'urfgqty,urscnwgt,urtare,urstat ' +
                      'from pWrkOrdRu where  ' + %char(pWhse) +
                      ' =urwhse and urrmi=' + sq + pitem + sq +
                      ' and urstat <> ' + sq + 'D' + sq +
700bC                 ' and urstat <> ' + sq + 'C' + sq +
700bA                 ' and substring(urser,9,2)=' + sq +
700bA                 pLine2 + sq;

               exec sql Prepare Prdsl from :Sqlstmt;
               exec sql Declare ProdDy scroll cursor for Prdsl;
               exec sql Open ProdDy;
               exec sql Fetch first from ProdDy into :PrdDay;

               dow sqlstt = sqlsuccess;

                  pqtyprd = pqtyprd + urfgqty;
                  prdWgt = prdWgt + (urscnwgt - urtare);
                 if PrdBkd ='Y';  // accum by production brkd if any defined
700cA              if urprjpq <> 0;
                      pprdext = pprdext + (urprjpq - uractpq);
700cA              else;
700cA                 // get the Each PRoduction Breakdown Qty
700cA                 if itumq3 <> 0 or itumq2 <> 0;
700cA                    // if either breakdown used divide total case
700cA                    // Production UOM Qty by sum of brkdwn1 and 2
700cA                    // to get weight of each lowest breakdown qty
700cA                    urprjpq = r_ipprdq / (wkumq2 * wkumq3);
700cA                 else;
700cA                    // if neither brkdwn1 or 2 used then simply
700cA                    // use total raw material case quantity
700cA                    urprjpq = r_ipprdq;
700cA                 endif;
700cA                 // now we should convert the existing normal inventory
700cA                 // breakdowns to Production Qty breakdowns to keep
700cA                 // everything Production Qty on this side of the else
700cA                 pprdext = pprdext +
700cA                        (urprjpq*(urprjnq-uractnq)*(wkumq2*wkumq3)) +
700cA                        (urprjpq*(urprjb1-uractb1)*(wkumq3)) +
700cA                          urprjpq*(urprjb2-uractb2);
700cA              endif;
                 else;
                   // Calculate total production qty used
                   pprdext = pprdext + ((urprjnq-uractnq)*(wkumq2*wkumq3)) +
                             ((urprjb1-uractb1)*(wkumq3)) +
                               urprjb2-uractb2;
                 endif;
                 exec sql Fetch next from ProdDy into :PrdDay;

               enddo;
               exec sql Close ProdDy;

            if LoadProduction;
               // if usage is empty move production values in for calcs
               if pUseNq=0 and pUse1q=0 and pUse2q=0 and pUsePq=0;
                  select;
                     when prdBkd = 'Y';
                        pUsepq = pprdext;
                        if pUsepq < 0;
                           pUsepq = 0;
                        endif;
                     when itumq3<>0;
                           pUse2q = pprdext;
                           if pUse2q < 0;
                              pUse2q = 0;
                           endif;
                     when itumq2<>0;
                        pUse1q = pprdext;
                        if pUse1q < 0;
                           pUse1Q = 0;
                        endif;
                     other;
                        pUseNq = pprdext;
                        if pUseNq < 0;
                           pUseNq = 0;
                        endif;
                  endsl;
               endif;
             endif;

             if pEndNq=0 and pEnd1q=0 and pEnd2q=0 and pEndPq=0
                and pUseNq=0 and pUse1q=0 and pUse2q=0 and pUsePq=0;
         //     pEndNq=slstk1;
         //     pEnd1q=slstk2;
         //     pEnd2q=slstk3;
         //     pEndPq=0;
             endif;
          endif;

          //  If we are loading numbers then see if a End of Day Weight
          // exists to return
          if LoadProduction;
             chain (pWhse:pLine:pItem:pDisp) pRemWgt;
             pEodWg = rwremWgt;
          endif;

          endsr;

       //---------------------------------------------------------
       // SetNrmStk - Setup normal stock quantities to return with
       //             Production Quantity results
       //---------------------------------------------------------

          begsr SetNrmStk;

                pNrmSt = %trim(%char(wkstk1));
                if wkstk3 <>0;
                   pNrmSt = %trim(pNrmSt) + '.' + %trim(%char(wkstk2));
                   pNrmSt = %trim(pNrmSt) + '.' + %trim(%char(wkstk3));
                endif;
                if wkstk2 <> 0;
                   pNrmSt = %trim(pNrmSt) + '.' + %trim(%char(wkstk2));
                endif;

          endsr;

       //---------------------------------------------------------
       // SltCalc - Retrieve balances and calc totals
       //---------------------------------------------------------

          begsr SltCalc;

            remqty1 = 0;
            remqty2 = 0;
            remqtyn = 0;
            PrdBKD = 'N';

             // look for valid Production Date for Line
              chain (pwhse:pline:'O') prddate1;
              if %found(prddate1);
                if pdstat='O';
                   prddte = %char(pddate);
                else;
                   prddte = '*NONE';
                endif;
             else;
                   prddte = '*NONE';
             endif;

            // check to see if Work Order requirements
            // exist for finsihed goods that request Production
            // UOM Breakdown instead of Normal Warehouse Breakdowns

            exec sql
             select count(*)
             into :numrecs
             from pWrkordr
               where wrwhse = :pWhse and writem = :pitem
                 and wrprdq <> 0
710aA            and wrstat <> 'C' and wrstat<>'D';

             if numrecs <> 0;  // Production BreakDown exist
                chain (pWhse:pItem) itemprd1;
                if not %found(itemprd1);
                   r_ipprdq = 0;
                endif;
                PrdBKD = 'Y';
                exsr getPrdNums;
                exsr PrdQtyConv;
                pBegInv = %trimr(%char(PrdWgt)); // Current Weight
             else;
                exsr getPrdNums;
                // get Normal Warehouse Breakdowns
                // Build Current Inventory First
                select;
                   when itumq3<>0 and slstk3<>0;
                     pBegInv = %trim(%char(slstk1) +
                              '.' + %trimr(%char(slstk2)) +
                              '.' + %trimr(%char(slstk3)));
                   when itumq2<>0 and slstk2<>0;
                     pBegInv = %trimr(%char(slstk1) +
                              '.' + %trimr(%char(slstk2)));
                   other;
                     pBegInv = %trimr(%char(slstk1));
                endsl;

              // Calculate total existing quantity down to breakdown units
             if itumq3 = 0;
                wkumq3 = 1;
             else;
                wkumq3 = itumq3;
             endif;
             if itumq2 = 0;
                wkumq2 = 1;
             else;
                wkumq2 = itumq2;
             endif;

             TotalOh = (slstk1*wkumq2*wkumq3) + (slstk2*wkumq3) + slstk3;

             // Calculate total usage per production
             TotalAdj = ((pEndNq+pUseNq)*(wkumq2*wkumq3)) +
                        ((pEnd1q+pUse1q)*(wkumq3)) +
                          pEnd2q+pUse2q;

             // set color on Projected Quantity based on below zero or not
         //  if (TotalOh-TotalAdj) < 0;
         //     PrdClr = 'R';
         //  else;
                PrdClr = 'G';
         //  endif;

             // roll up the breakdowns
          if (totaloh-TotalAdj) = 0;
              pWstNq = '0';
             // leaves Ending balances alone
          else;
             exsr zzupqty;
             // Build Projected Iventory
                select;
                   when itumq3<>0 and remqty2<>0;
           //        if LoadProduction;       // balance in ending
           //           pEndNq = remqtyn;
           //           pEnd1q = remqty1;
           //           pEnd2q = remqty2;
           //           pWstNq = '0';
           //        else;                    // else in waste
                        pWstnq = %trimr(%char(remqtyn) +
                              '.' + %trimr(%char(remqty1)) +
                              '.' + %trimr(%char(remqty2)));
         //          endif;
                   when itumq2<>0 and remqty1<>0;
         //          if LoadProduction;      // balance in ending
         //             pEndNq = remqtyn;
         //             pEnd1q = remqty1;
         //             pEnd2q = 0;
         //             pWstNq = '0';
         //          else;                    // else in waste
                        pWstnq = %trimr(%char(remqtyn) +
                              '.' + %trimr(%char(remqty1)));
         //          endif;
                   other;
         //          if LoadProduction;        // balance in ending
         //             pEndNq = remqtyn;
         //             pEnd1q = 0;
         //             pEnd2q = 0;
         //             pWstNq = '0';
          //         else;                     // else in waste
                        pWstnq = %trimr(%char(remqtyn));
          //         endif;
                 endsl;
              endif;
           endif;

              // if requested usage exceeds production return error
              // We will not allow you to adjust more than production
              if r_ipprdq <> 0;
                 if pUsePq > pprdExt;
720 D         //       pErr = 'Usage cannot be more than recorded Production';
                 endif;
              else;
                 if ((pUseNq)*(wkumq2*wkumq3)) +
                    ((pUse1q)*(wkumq3)) +
                      pUse2q > pprdExt;
720 D         //     pErr = 'Usage cannot be more than recorded Production';
                 endif;
              endif;

720 A       // If normal waste quantity less than zero then zero
720 A       if %scan('-':pWstNq:1) <> 0;
720 A          pWstNq = '0';
720 A       endif;

          endsr;

      /end-free
     *----------------------------------------------------------------
     *  ZZUPQTY       Up quantity
     *----------------------------------------------------------------

     C     zzupqty       begsr

      /free
                         select;
                            when itumq3 > 0;
                               remqty2 = TotalOh - TotalAdj;
                            when itumq2 > 0;
                               remqty1 = TotalOh - TotalAdj;
                            other;
                               remqtyn = TotalOh - TotalAdj;
                         endsl;
      /end-free

     C                   dow       itumq3 > 0 and +
     C                               remqty2 >= itumq3
     C                   eval      remqty2 -= itumq3
     C                   eval      remqty1 += 1
     C                   enddo

     C                   dow       itumq2 > 0 and +
     C                               remqty1 >= itumq2
     C                   eval      remqty1 -= itumq2
     c                   eval      remqtyn += 1
     C                   enddo

     C                   endsr
700bA*----------------------------------------------------------------
700bA*  ZZUPPRD       Up Production Quantities
700bA*----------------------------------------------------------------
700bA
700bAC     zzupprd       begsr
700bA
700bA
700bAC                   dow       itumq3 > 0 and +
700bAC                               pUse2q >= itumq3
700bAC                   eval      pUse2q -= itumq3
700bAC                   eval      pUse1q += 1
700bAC                   enddo
700bA
700bAC                   dow       itumq2 > 0 and +
700bAC                               pUse1q >= itumq2
700bAC                   eval      pUse1q -= itumq2
700bAc                   eval      pUsenq += 1
700bAC                   enddo
700bA
700bAC                   endsr

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pItem = ' + pItem
                  + '&pUser=' + %trimr(pUser)
                  + '&pDisp=' + %trimr(pDisp)
                  + '&pWstPq =' + %trimr(%char(pWstPq))
                  + '&pOut=' + %trimr(pErr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
710 A *
710 A *  Procedure Split..............
710 A *
710 A *  Split Procedure that work like SPLIT in javascript.  It expects an inpu
710 A *  string up to 1000 characters long, a delimiter 3 character long, and pa
710 A *  back an array with 50 elements 50 character each.  The delmiter could
710 A *  be increased if need be and the code (%len) takes care of it.  You coul
710 A *  also change the array size and element count.  If you do you should cha
710 A *  split and returnarray here and you procedure definition in main program
710 A *  as well as the array defined in the main program that receives the retu
710 A *  from this procedure.  When you return simply loop through array looking
710 A *  non blanks and do what you need to given your data.
710 A *
710 AP split           b
710 AD split           pi            50    dim(50)
710 AD  data                       1000    const
710 AD  delimiter                     3    const
710 A
710 AD returnArray     s             50    dim(50)
710 A
710 AD startPos        s             10i 0
710 AD foundPos        s             10i 0
710 AD increment       s             10i 0
710 AD index           s              5i 0 inz(1)
710 A /free
710 A  if data <> *blanks;
710 A     increment = %len(%trim(delimiter));
710 A     startPos = 1;
710 A     dou foundPos = %len(data) + 1;
710 A        foundPos = %scan(%trim(delimiter):data:startPos);
710 A        if foundPos = 0;
710 A           foundPos = %len(data) + 1;
710 A        endif;
710 A        returnArray(index) = %subst(data:startPos:foundPos - startPos);
710 A        index += 1;
710 A        startPos = foundPos + increment;
710 A     enddo;
710 A  endif;
710 A
710 A  return returnArray;
710 A /end-free
710 AP split           e
