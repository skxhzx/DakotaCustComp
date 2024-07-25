      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FMTQTYUOM   Get quantity and uom and return
     *              jSon string with rolled up values
     *  09 Mar 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
650 A*    03/09/15  KDE  6.50
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
650aAFpiritem   if   e           k disk
     funmesr    if   e           k disk
     fitemprd   if   e           k disk

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
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

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D dbgflgExists    s               n
     D debug           s               n
     d item            s             15
     d negQty          s               n
     d newqtyn         s              5  0
     d newqty1         s              5  0
     d newqty2         s              5  0
     d newqtyp         s              9  4
     d perr            s             50
     d pEiv            s               n
     d space           s              1    inz(' ')
     d uomwrk          s              5
     d uomin           s              2
     d wrkPct          s              9  4
     d wrkbom          s              9  4
     d wrkuse          s              9  4
     d wrkwst          s              9  4

     *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pQty1       Quantity 1
     *      pQty2       Quantity 2
     *      pQty3       Quantity 3
     *      pPrdQ       Production Quantity
     *      pItem       Item number
     *
     *    Returned Parameters
     *      pOutStr     Json with rolled up values and yield
     *
     *----------------------------------------------------------------

     D fmtqtyuom       pr                  extpgm('FMTQTYUOM')
650aAD  pSessId                      40    varying
650aAD  pUser                        10    varying
650aAD  pPgm                         20    varying
     D  pwhse                         3  0 const
     D  pBivn                         5  0 const
     D  pBiv1                         5  0 const
     D  pBiv2                         5  0 const
     D  pBivp                         9  4 const
     D  pRpln                         5  0 const
     D  pRpl1                         5  0 const
     D  pRpl2                         5  0 const
     d  pRplp                         9  4 const
     D  pAdjn                         5  0 const
     D  pAdj1                         5  0 const
     D  pAdj2                         5  0 const
     d  pAdjp                         9  4 const
     D  pBmen                         5  0 const
     D  pBme1                         5  0 const
     D  pBme2                         5  0 const
     d  pBmep                         9  4 const
     D  pBomn                         5  0 const
     D  pBom1                         5  0 const
     D  pBom2                         5  0 const
     d  pBomp                         9  4 const
     D  pAusen                        5  0 const
     D  pAuse1                        5  0 const
     D  pAuse2                        5  0 const
     d  pAusep                        9  4 const
     D  pAwstn                        5  0 const
     D  pAwst1                        5  0 const
     D  pAwst2                        5  0 const
     d  pAwstp                        9  4 const
     D  pEivn                         5  0 const
     D  pEiv1                         5  0 const
     D  pEiv2                         5  0 const
     d  pEivp                         9  4 const
     D  pItem                        15    varying
     D  pOutStr                     512    varying

     D fmtqtyuom       pi
650aAD  pSessId                      40    varying
650aAD  pUser                        10    varying
650aAD  pPgm                         20    varying
     D  pwhse                         3  0 const
     D  pBivn                         5  0 const
     D  pBiv1                         5  0 const
     D  pBiv2                         5  0 const
     D  pBivp                         9  4 const
     D  pRpln                         5  0 const
     D  pRpl1                         5  0 const
     D  pRpl2                         5  0 const
     d  pRplp                         9  4 const
     D  pAdjn                         5  0 const
     D  pAdj1                         5  0 const
     D  pAdj2                         5  0 const
     d  pAdjp                         9  4 const
     D  pBmen                         5  0 const
     D  pBme1                         5  0 const
     D  pBme2                         5  0 const
     d  pBmep                         9  4 const
     D  pBomn                         5  0 const
     D  pBom1                         5  0 const
     D  pBom2                         5  0 const
     d  pBomp                         9  4 const
     D  pAusen                        5  0 const
     D  pAuse1                        5  0 const
     D  pAuse2                        5  0 const
     d  pAusep                        9  4 const
     D  pAwstn                        5  0 const
     D  pAwst1                        5  0 const
     D  pAwst2                        5  0 const
     d  pAwstp                        9  4 const
     D  pEivn                         5  0 const
     D  pEiv1                         5  0 const
     D  pEiv2                         5  0 const
     d  pEivp                         9  4 const
     D  pItem                        15    varying
     D  pOutStr                     512    varying

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

GMMaAd prYield         pr            10
GMMaAd  fBomn                         5  0 const
GMMaAd  fBom1                         5  0 const
GMMaAd  fBom2                         5  0 const
GMMaAd  fBomp                         9  4 const
GMMaAd  fUsen                         5  0 const
GMMaAd  fUse1                         5  0 const
GMMaAd  fUse2                         5  0 const
GMMaAd  fUsep                         9  4 const
GMMaAd  fWstn                         5  0 const
GMMaAd  fWst1                         5  0 const
GMMaAd  fWst2                         5  0 const
GMMaAd  fWstp                         9  4 const

GMMaAd prdwnQty        pr
GMMaAd  fQtyn                         5  0 const
GMMaAd  fQty1                         5  0 const
GMMaAd  fQty2                         5  0 const
GMMaAd  fQtyp                         9  4 const

GMMaAd prRollup        pr            25
GMMaAd  fQtyn                         5  0 const
GMMaAd  fQty1                         5  0 const
GMMaAd  fQty2                         5  0 const
GMMaAd  fQtyp                         9  4 const
GMMaAd  fWhse                         3  0 const
GMMaAd  fItem                        15    varying

GMMaAd prupQty         pr
GMMaAd  fQtyn                         5  0 const
GMMaAd  fQty1                         5  0 const
GMMaAd  fQty2                         5  0 const
GMMaAd  fQtyp                         9  4 const

      /free

         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             debug = (bdfflag = 1);
           else;
             debug = *off;
           endif;
         endif;

          if debug;
            exsr wrtDebugParms;
          endif;

        // Create return json string wtih 0.0.0 version of inventories
        // totals and also calculate yield if data allows
        pEiv = *off;
        pOutStr = '{'
        + '"pBiv":"' +
          %trimr(prRollup (pBivn: pBiv1: pBiv2: pBivp: pWhse: pItem)) +
                  '",'
        + '"pRpl":"' +
          %trimr(prRollup (pRpln: pRpl1: pRpl2: pRplp: pWhse: pItem)) +
                  '",'
        + '"pAdj":"' +
           %trimr(prRollup (pAdjn: pAdj1: pAdj2: pAdjp: pWhse: pItem)) +
                  '",'
        + '"pBme":"' +
           %trimr(prRollup (pBmen: pBme1: pBme2: pBmep: pWhse: pItem)) +
                  '",'
        + '"pBom":"' +
           %trimr(prRollup (pBomn: pBom1: pBom2: pBomp: pWhse: pItem)) +
                  '",'
        + '"pAuse":"'  +
         %trimr(prRollup (pAusen: pAuse1: pAuse2: pAusep:pWhse: pItem)) +
                  '",'
        + '"pYield":"'  +
         %trimr(prYield (pBomn:  pBom1:  pBom2:  pBomp: +
                         pAUsen: pAuse1: pAuse2: pAusep: +
                         pAwstn: pAwst1: pAwst2: pAwstp))+ '",'
        + '"pAwst":"'  +
         %trimr(prRollup (pAwstn: pAwst1: pAwst2: pAwstp:pWhse: pItem)) +
                  '",';
        pEiv = *on;
        pOutStr = %trim(pOutStr) + '"pEiv":"'   +
           %trimr(prRollup (pEivn: pEiv1: pEiv2: pEivp: pWhse: pItem))
               + '"}';

        *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

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

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pWhse = ' + %char(pWhse)
                  + '&pBivn=' + %char(pBivn)
                  + '&pBiv1=' + %char(pBiv1)
                  + '&pBiv2=' + %char(pBiv2)
                  + '&pItem=' + %trim(pItem)
                  + '&pOutStr=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

GMMaA*
GMMaA*----------------------------------------------------------------
GMMaA*  Subprocedures
GMMaA*  prYield - Calculate Yield for line
GMMaA*            calculations.
GMMa A*
GMMaAp prYield         b
GMMaAd  prYield        pi            10
     *
GMMaAd   fBomn                        5  0 const
GMMaAd   fBom1                        5  0 const
GMMaAd   fBom2                        5  0 const
     d   fBomp                        9  4 const
GMMaAd   fUsen                        5  0 const
GMMaAd   fUse1                        5  0 const
GMMaAd   fUse2                        5  0 const
     d   fUsep                        9  4 const
GMMaAd   fWstn                        5  0 const
GMMaAd   fWst1                        5  0 const
GMMaAd   fWst2                        5  0 const
     d   fWstp                        9  4 const
     *
     d  fYield         s             10    inz(' ')

      /free
            select;
               when itumq3<>0;
               // move all quantities to lowest uom per item master
                  wrkBom = (fBomn * itumq2 * itumq3) +
                           (fBom1 * itumq3) +
                            fBom2;
                  wrkUse = (fUsen * itumq2 * itumq3) +
                           (fUse1 * itumq3) +
                            fUse2;
                  wrkWst = (fWstn * itumq2 * itumq3) +
                           (fWst1 * itumq3) +
                            fWst2;
                 // determine prodcution uom equilavent
                 if (itumq3*itumq2) <> 0 and ipPrdq <> 0;
                    eval(h) result = ipPrdq / (itumq3*itumq2);
                    if pBomp <> 0;
                       wrkBom = fBomp;
                    else;
                       wrkBom = wrkBom * result;
                    endif;
                    if fUsep <> 0;
                       wrkUse = fUsep;
                    else;
                       wrkUse = wrkUse * result;
                    endif;
                    if fWstp <> 0;
                       wrkWst = fWstp;
                    else;
                       wrkWst = wrkWst * result;
                    endif;
                 endif;
              // calculate yield percent and place in return value
                 if (wrkuse + wrkwst) <> 0
                     and wrkBom <> 0;
                     WrkPct = (wrkBom/(wrkuse+wrkwst)*100);
                     fYield = %char(%abs(wrkPct));
                 else;
                    fYield = '0';
                 endif;
               when itumq2<>0;
               // move all quantities to lowest uom per item master
                  wrkBom = (fBomn * itumq2) +
                            fBom1;
                  wrkUse = (fUsen * itumq2) +
                            fUse1;
                  wrkWst = (fWstn * itumq2) +
                            fWst1;
                 // determine prodcution uom equilavent
                 if itumq2 <> 0 and ipPrdq <> 0;
                    eval(h) result = ipPrdq / itumq2;
                    if fBomp <> 0;
                       wrkBom = fBomp;
                    else;
                       wrkBom = wrkBom * result;
                    endif;
                    if fUsep <> 0;
                       wrkUse = fUsep;
                    else;
                       wrkUse = wrkUse * result;
                    endif;
                    if fWstp <> 0;
                       wrkWst = fWstp;
                    else;
                       wrkWst = wrkWst * result;
                    endif;
                 endif;
              // calculate yield percent and place in return value
                 if (wrkuse + wrkwst) <> 0
                     and wrkBom <> 0;
                     WrkPct = (wrkBom/(wrkuse+wrkwst)*100);
                     fYield = %char(%abs(wrkPct));
                 else;
                    fYield = '0';
                 endif;
               other;
               // move all quantities to lowest uom per item master
                  wrkBom = fBomn;
                  wrkUse = fUsen;
                  wrkWst = fWstn;
                 // determine prodcution uom equilavent
                 if ipPrdq <> 0;
                    if fBomp <> 0;
                       wrkBom = fBomp;
                    else;
                       wrkBom = wrkBom * ipprdq;
                    endif;
                    if fUsep <> 0;
                       wrkUse = fUsep;
                    else;
                       wrkUse = wrkUse * ipprdq;
                    endif;
                    if fWstp <> 0;
                       wrkWst = fWstp;
                    else;
                       wrkWst = wrkWst * ipprdq;
                    endif;
                 endif;
              // calculate yield percent and place in return value
                 if (wrkuse + wrkwst) <> 0
                     and wrkBom <> 0;
                     WrkPct = (wrkBom/(wrkuse+wrkwst)*100);
                     fYield = %char(%abs(wrkPct));
                 else;
                    fYield = '0';
                 endif;
            endsl;
            return fYield;
      /end-free
GMMaAp prYield         e

GMMaA*
GMMaA*----------------------------------------------------------------
GMMaA*  Subprocedures
GMMaA*  prdwnQty  -  Roll quantities down to lowest uom to do
GMMaA*               calculations.
GMMa A*
GMMaAp prdwnQty        b
GMMaAd  prdwnQty       pi
     *
GMMaAd   fQtyn                        5  0 const
GMMaAd   fQty1                        5  0 const
GMMaAd   fQty2                        5  0 const
     d   fQtyp                        9  4 const
      /free
           select;
              when itumq3 > 0;
                 newqty2 = (fqtyn * itumq2 * itumq3) +
                           (fqty1 * itumq3) +
                            fqty2;
                 newqtyn = 0;
                 newqty1 = 0;
              when itumq2 > 0;
                 newqty1 = (fqtyn * itumq2) + fqty1;
                 newqtyn = 0;
                 newqty2 = 0;
              other;
                 newqtyn = fqtyn;
                 newqty1 = 0;
                 newqty2 = 0;
           endsl;
      /end-free
GMMaAp prdwnQty        e
GMMaA*
GMMaA*----------------------------------------------------------------
GMMaA*  Subprocedures
GMMaA*  prRollup  -  Rollup normal and breakdown qtys passed
GMMaA*               Return rolled up quantities concatenated
GMMa A*
GMMaAp prRollup        b
GMMaAd  prRollup       pi            25
     *
GMMaAd   fQtyn                        5  0 const
GMMaAd   fQty1                        5  0 const
GMMaAd   fQty2                        5  0 const
     d   fQtyp                        9  4 const
GMMaAd   fWhse                        3  0 const
GMMaAd   fItem                       15    varying
     *
     d  fRollQty       s             25    inz(' ')
      /free
         pErr = ' ';
         newqtyn = fQtyn;
         newqty1 = fQty1;
         newqty2 = fQty2;
         newqtyp = fQtyp;

         // get item master record for passed in item
            chain (fWhse:fItem) piritem;
            if not %found(piritem);
               pErr = 'No Item Master Found';
            else;
               // get production Item Master
               chain (fWhse:fItem) itemprd;
               if not %found(itemprd);
                  ipprdq = 0;
            endif;
            // if Ending Inventory then calculate based on
            // previous values
            // up passed in quantities
            if pEiv;
               newqtyn = pBivn+pRpln+pAusen+pAwstn+pAdjn;
               newqty1 = pBiv1+pRpl1+pAuse1+pAwst1+pAdj1;
               newqty2 = pBiv2+pRpl2+pAuse2+pAwst2+pAdj2;
               newqtyp = pBivp+pRplp+pAusep+pAwstp+pAdjp;
            endif;

            prdwnQty(newqtyn: newqty1: newqty2: newqtyp);
            prupQty(newqtyn: newqty1: newqty2: newqtyp);

            // build quantity string
            if newQtyn <> 0 or newQty1 <> 0 or newQty2 <> 0;

               select;
               when itumq3 > 0;
                 // determine prodcution uom equilavent
                  if (itumq3*itumq2) <> 0 and ipPrdq <> 0;
                     eval(h) result = ipPrdq / (itumq3*itumq2);
                     eval(h) newqtyp =((newqtyn * (itumq3*itumq2)) +
                                      (newqty1 * itumq3) +
                                       newqty2) * result;
                  else;
                     eval newqtyp = 0;
                  endif;
                  fRollqty = %char(newqtyn);
                  fRollqty = %trim(fRollQty) + '.' + %char(newqty1);
                  fRollQty = %trim(fRollQty) + '.' + %char(newqty2);
               when itumq2 > 0;
                 // determine prodcution uom equilavent
                  if itumq2 <> 0 and ipPrdq <> 0;
                     eval(h) result = ipPrdq / itumq2;
                     eval(h) newqtyp =((newqtyn * itumq2) +
                                        newqty1) * result;
                  else;
                     eval newqtyp = 0;
                  endif;
                  fRollQty = %char(newqtyn);
                  fRollQty = %trim(fRollQty) + '.' + %char(newqty1);
               other;
                  if ipPrdq <> 0;
                     newqtyp = newqtyn * ipPrdq;
                  else;
                     newqtyp = 0;
                  endif;
                  fRollQty = %char(newqtyn);
              endsl;
            else;
               fRollQty = '0';
            endif;

            // if production item with production UOM include in desc
            if ipPrdq <> 0 and newqtyp<>0;
               if newqtyp <>0;
                  fRollQty = %trim(fRollQty) + '  ( ' + %char(newqtyp) +
                            ' )';
               else;
                  fRollQty = %trim(fRollQty) + '  ( ' + %char(fqtyp) +
                            ' )';
               endif;
            endif;

        endif;
        //pFirst = *off;
GMMaA                    return fRollQty;  // return rolled quantities
      /end-free
GMMaAp prRollup        e
GMMaA*
GMMaA*----------------------------------------------------------------
GMMaA*  Subprocedures
GMMaA*  prupQty  -  Roll quantities up the UOM structure
GMMa A*
GMMaAp prupQty         b
GMMaAd  prupQty        pi
     *
GMMaAd   fQtyn                        5  0 const
GMMaAd   fQty1                        5  0 const
GMMaAd   fQty2                        5  0 const
     d   fQtyp                        9  4 const

     c                   eval      newqtyn = fqtyn
     c                   eval      newqty1 = fqty1
     c                   eval      newqty2 = fqty2
     c                   eval      newqtyp = fqtyp

     c                   if        newqty2 < 0
     c                   eval      newqty2 = newqty2 * -1
     c                   eval      negQty = *on
     c                   else
     c                   eval      negQty = *off
     c                   endif

     C                   dow       itumq3 > 0 and +
     C                               newqty2 >= itumq3
     C                   eval      newqty2 -= itumq3
     C                   eval      newqty1 += 1
     C                   enddo
      *
      *  if original qty2 came in negative make both numbers
      *  coming out negative.  Everything is driven to lowest
      *  unit of measure before getting here so everything
      *  started in qty2 if anything were there
      *
     c                   if        negQty
     c                   eval      newqty2 = newqty2 * - 1
     c                   eval      newqty1 = newqty1 * - 1
     c                   endif

     c                   if        newqty1 < 0
     c                   eval      newqty1 = newqty1 * -1
     c                   eval      negQty = *on
     c                   else
     c                   eval      negQty = *off
     c                   endif

     C                   dow       itumq2 > 0 and +
     C                               newqty1 >= itumq2
     C                   eval      newqty1 -= itumq2
     c                   eval      newqtyn += 1
     C                   enddo
      *
      *  if qty1 was negative make both numbers
      *  coming out negative.
      *
     c                   if        negQty
     c                   eval      newqty1 = newqty1 * - 1
     c                   eval      newqtyn = newqtyn * - 1
     c                   endif
GMMaAp prupQty         e
