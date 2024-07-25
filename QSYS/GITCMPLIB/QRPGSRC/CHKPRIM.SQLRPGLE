      *copy *libl/qcopysrc,hspecs
     Hcopyright('(c) Copyright BFC Software, Inc - 2016')
     H optimize(*NONE)
     H decedit(*JOBRUN)
     H truncnbr(*NO)
     H option(*srcstmt : *nodebugio)
     H Dftactgrp(*No)
     *----------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Rese
     *   BFC Software, Inc.
     *----------------------------------------------------------

     *----------------------------------------------------------
     *
     *  CHKPRIM     Check whether Primal and SubPrimal
     *              associations eixst
     *
     *  26 December 2016
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    12/26/16  KDE  7.00
     *      - Created
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
     *
     *----------------------------------------------------------
     * File Specs
     *----------------------------------------------------------
     * Bill of Material ----------------------------------------
     FpBom      if   e           k disk
     * Item PRimal/SubPrimal Assocaitions ----------------------
     FpWrkord   if   e           k disk
     * Work ORder Header  --------------------------------------
     FItemPRdPS if   e           k disk
     * Production Item Master Exensions ----------------------
     FItemPRd   if   e           k disk
     * BFC Debug flag file  ------------------------------------
     Fbfcdbgflg if   e           k disk    usropn
     * BFC Debug File  -----------------------------------------
     Fbfcdebug  o    e           k disk
     *----------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
     D*copy qcopysrc,c#pgminfds

     *----------------------------------------------------------
     * Begin C#PGMINFDS - Program information data structure
     *  12/20/02  DAS  4.16  Created
     *  07/12/08  DAS  6.00a
     *    - Added #curruser, #prog, #jobn
     *  03/02/11  MLB  6.40
     *    - Added #parms
     *----------------------------------------------------------

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

     *** End C#PGMINFDS ***

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D CurrDate        S              8  0
     D dbgflgExists    s               n
     D debug           s               n
     D pExist          s              1
     d woExist         s              1
     d pByp            s              1

     *----------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  Parms coming in to program(SUBQAVL) from MRC
     *----------------------------------------------------------
     D  chkprim        pr                  extpgm('CHKPRIM')
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pFGItm                       15     varying
     D  pRMItm                       15     varying
     D  pOutStr                     256    varying

     D  chkprim        pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pWhse                         3p 0
     D  pFGItm                       15    varying
     D  pRMItm                       15    varying
     D  pOutStr                     256    varying

     *----------------------------------------------------------
     *                  M A I N    L I N E                     *
     *----------------------------------------------------------

      /free

         *inlr = *on;
         #curruser = pUser;
         CurrDate = %Dec(%Date());

          exsr opnwrkords;
          exsr chkPrimsPrim;
          exsr chkBom;
          pOutStr = '{'
                 +  '"pItemTyp":"'  + ipmorp + '",'
                 +  '"pWoExist":"'  + woExist + '",'
                 +  '"pByP":"'  + pByp + '",'
                 +  '"pExist":"'  + %trimr(pExist) + '"';
          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';

          if debug;
            exsr wrtDebugParms;
          endif;

       //*----------------------------------------------------------
       //*  chkBom - If Primal/SubPrimal good check BOM
       //*----------------------------------------------------------
          BegSR chkBom;

             // if coming from Item Master make sure no BOM before
             // allowing delete as well as Primal/SubPrimal
             if %trim(%subst(pPgm:1:4))='M160';
                if pExist = 'N';
                   setll (pWhse:pFgItm) pBom;
                   reade (pWhse:pFgItm) pBom;
                   if not %eof(pBom);
                      pExist = 'B';
                   endif;
                endif;
             endif;

          Endsr;

       //*----------------------------------------------------------
       //*  chkPrimsPrim - Primal/SubPrimal exist?
       //*----------------------------------------------------------
          BegSR chkPrimsPrim;

             // if finished good missing in Production Item Master error
             chain (pWhse:pFgITm) itemprd;
             if not %found(itemPRd);
                // if finished good not found error
                pExist = 'N';
                leavesr;
             endif;

             Select;
               When pRmitm = 'B';
                  // if no raw material passed in see if at least one Primal
                  // and SubPrimal record exist for each BOM line
                  setll (pWhse:pFgItm) pBom;
                  reade (pWhse:pFgItm) pBom;
                  if %eof(pBom);
                     pExist = 'N';
                     leavesr;
                  else;
                     pExist = 'Y';
                  endif;

                  dow not %eof(pBom);
                     // if any BOM lines do not have associations then
                     // set flag as No and exit
                     if bmusep = 'Y';  // only check items that record waste
                     chain (pWhse:pFgITm:ipMFgno:bmRmi) ItemPrdPs;
                        if not %found(ItemPrdPs);
                           pExist = 'N';
                           leavesr;
                        endif;
                     endif;
                     reade (pWhse:pFgItm) pBom;
                  enddo;
               other;
                  // when raw material sent in make sure that one line
                  // is associated
                  pExist = 'Y';
                  chain (pWhse:pFgItm:ipMfgNo:pRmitm) itemPrdPs;
                  if not %found(itemPRdPs);
                     pExist = 'N';
                     leavesr;
                  endif;
               endsl;

          EndSR;

       //*----------------------------------------------------------
       //*  opnwrkords  -  Check to see if open Work Orders exist
        //*                 Also check to see if Raw Material is used
        //*                 by any BOM's as Waste items.  This qualifies
        //*                 the item to have the link on ITem Maintenance
        //*                 to associate possible By-Products to be
        //*                 presented during production as an alternate
        //*                 item to be produced during production process
       //*----------------------------------------------------------
          BegSR opnwrkords;

             exec sql update pWrkOrd set wowhse=:pWhse
                             where wowhse=:pWhse and
                                   woitem = :pFGitm
                                   and wostat<>'C' and wostat<>'D';
             if sqlStt = '00000';
                woExist = 'Y';
             else;
                woExist = 'N';
             endif;

             // statement belows compares raw material in bom file to
             // incoming parm named pfgitm.  The pfgitm could have
             // raw material or finished good in it.
             exec sql update pBom set bmwhse=bmwhse
                             where bmwhse=:pWhse and
                                   bmrmi = :pFgitm
                                   and bmtype='C';
             if sqlStt = '00000';
                pByp = 'Y';
             else;
                pByp = 'N';
             endif;

          Endsr;

       //*----------------------------------------------------------
       //*  *INZSR   Initialization subroutine
       //*----------------------------------------------------------

          begsr *INZSR;
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

       //*----------------------------------------------------------
       //*  wrtDebugParms  Write out debug parm record
       //*----------------------------------------------------------
         begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pSessID = ' + pSessID
                  + '&pUser=' + %trimr(pUser)
                  + '&pDict=' + %trimr(PDict)
                  + '&pPgm=' + %trimr(pPgm)
                  + '&pWhse =' + %char(pWhse)
                  + '&pFGItm =' + %trimr(pFGItm)
                  + '&pRMItm =' + %trimr(pRMItm)
                  + '&pOut=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
       //*----------------------------------------------------------
       //*  wrtDebugError  Write out debug error
       //*----------------------------------------------------------
         begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = ' ';

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
