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
     *  SUBQAVL     SQL Function to check available stock for
     *              susbstitute items and return a flag to
     *              disply whether item can be selected.
     *
     *  07 November 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    11/07/16  TAB  7.00
     *      - Created
700aA*    12/13/16  KDE  7.00a
     *      - Added code to handle all breakdowns
710 A*    01/16/17  KDE  7.10
     *      - Added code to change raw material item in itemprdps
     *        when item is substituted.  Also added Action code
     *        "P" to look for Primal definition and return prim
     *        value in json string
710aA*    05/24/17  KDE  7.10a
     *      - Change to 7.00a to not keep extending the rollups
     *        by the make quantity at each level
710bA*    05/30/17  KDE  7.10b
     *      - Fix issue in extending by production uom quantity
710cA*    11/02/17  KDE  7.10c
     *      - Fix issue extending quantities in UPDWORKODR
720 A*    01/21/18  KDE  7.20
     *      - Changes for WIP Work Orders
720aA*    12/17/18  KDE  7.20a
     *      - Increase quantity fields
720bA*    01/03/19  KDE  7.20b
     *      - Add command to return item tyoe for specific bill item
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
750aA*     01/11/22  KDE  7.50a
     *       - Fix: Use work fields to extend lowest units of measure
     *
     *----------------------------------------------------------
     * File Specs
     *----------------------------------------------------------
     * Work Order file  ----------------------------------------
     FPwrkord   if   e           k disk
     * Work Order Raw Material file  ---------------------------
     FPwrkordr  uf a e           k disk
     * Substitute RAW material file  ---------------------------
     FPbomsub   if   e           k disk
     * RAW Material summary file  ------------------------------
     FPrmsum    if   e           K Disk
     * Item Master file  ---------------------------------------
     FPiritem   if   e           K Disk
     * Slot file  ----------------------------------------------
     FSlot3     if   e           k disk
     * Production Item file ------------------------------------
     FItemprd   if   e           K Disk
     * Production Item Primal/SubPRimal Defintion---------------
     FItemprdPs if   e           K Disk
     * Production Item Primal/SubPRimal by Item ----------------
     FItemprdPa1if   e           K Disk    prefix(a_) rename(iurec:iurec1)
     * Production Work Order Primal/SubPrimal Definition--------
     FpWrkORdPS uf a e           K Disk
     * Production manufacturing line configuration file  -------
     fPlined    if   e           k disk
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

     D dbgflgExists    s               n
     D debug           s               n
     D Error           s               n
     D i               s              3  0
     D len             s              3  0
     D whse            s              3  0
     D itemdesc        S             40    Inz(' ')
     D itemColor       s             20
720bAd itmType         s              1
710 Ad I121xx          s              1    Inz(' ')
710 Ad primExist       s              1    Inz('N')
     d reccnt          s              7  0
710 Ad dynBomExist     s              1    Inz('N')
     D text            s            200    varying
     D FPos            S              2  0 Inz
     D Lpos            S              2  0 Inz

     D CaseQ_A         S              5    Inz
     D BrkD1_A         S              5    Inz
     D BrkD2_A         S              5    Inz
     D CaseQN          S              5  0 Inz
     D BrkD1N          S              5  0 Inz
     D BrkD2N          S              5  0 Inz
     D CurDmndI        S              9  0 Inz
720aMD CurDmndP        S             10  4 Inz
710 Ad imgMsg          s            100
     D WkODmndI        S              9  0 Inz
     D WkODmndP        S              9  4 Inz
     D WkOrdPnd        S              9  2 Inz
     D TotDmndI        S              9  0 Inz
720aMD TotDmndP        S             10  4 Inz
     D TotOnhdI        S              9  0 Inz
720aMD TotOnhdP        S             10  4 Inz
     D RemProdI        S              9  0 Inz
720aMD RemProdP        S             10  4 Inz
720aMD ItmPounds       S             10  4 Inz
750aAd wkqty2          s             10  4 inz
750aAd wkqty1          s             10  4 inz
     D pAvail          S              1    Inz
     D pErr            S             50    Inz
     D Reversal        S              1N   Inz
     D CurrDate        S              8  0
700aAd wkumq2          s                   like(itumq2)
700aAd wkumq3          s                   like(itumq3)
720 Ad wipitem         s              1
720 Ad wipitm3         s              3
     *----------------------------------------------------------
     *  The following variables were taken from program R13000
     *----------------------------------------------------------
720aMD Avl1            S             10  4
720aMD Avl2            S             10  4
720aMD Avl3            S             10  4

     *----------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  Parms coming in to program(SUBQAVL) from MRC
     *----------------------------------------------------------
     D  subqavl        pr                  extpgm('SUBQAVL')
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pFGItm                       15     varying
     D  pRMItm                       15     varying
     D  pAMItm                       15    varying
     D  pWrkOr                       13    varying
     D  pAction                       1    varying
     D  pOutStr                     200    varying

     D  subqavl        pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pWhse                         3p 0
     D  pFGItm                       15    varying
     D  pRMItm                       15    varying
     D  pAMItm                       15    varying
     D  pWrkOr                       13    varying
     D  pAction                       1    varying
     D  pOutStr                     200    varying
     *----------------------------------------------------------
     *  Parms coming in to program(SUBQAVL) from command line
     *----------------------------------------------------------
     D* subqavl        pr                  extpgm('SUBQAVL')
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pFGItm                       15
     D* pRMItm                       15
     D* pAMItm                       15
     D* pWrkOr                       13
     D* pAction                       1
     D* pOutStr                     200

     D* subqavl        pi
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pFGItm                       15
     D* pRMItm                       15
     D* pAMItm                       15
     D* pWrkOr                       13
     D* pAction                       1
     D* pOutStr                     200
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D airec         E ds                  extname(psubitmlog) inz(*EXTDFT)
     *----------------------------------------------------------
     *                  M A I N    L I N E                     *
     *----------------------------------------------------------

      /free

         *inlr = *on;
         #curruser = pUser;
         CurrDate = %Dec(%Date());
710 A    imgMsg = *blanks;


           Select;

             When pAction = 'C';
710 A          Exsr PrimalExist;
               ExSr GetWorkOrd;
               ExSR GetSubBOM;
               ExSr BldJson;
             When pAction = 'U';
               ExSr GetWorkOrd;
               ExSr WrtSubLog;
               Exsr RvsSubLog;
               ExSr UpdWorkOrd;
               ExSr BldJson2;
710 A        When pAction = 'P';
710 A          Exsr PrimalExist;
               ExSr BldJson;
720bA        When pAction = 'T';
720bA          Exsr getType;
720bA          ExSr BldJson;
             Other;
           EndSL;

          if debug;
            exsr wrtDebugParms;
          endif;

       //*----------------------------------------------------------
       //*  BldJson  Build JSON string
       //*----------------------------------------------------------
          BegSR BldJson;
          // Put together JSON string
          pOutStr = '{'
          //     +  '"ses":"'  + %trimr(pSessID) + '",'
          //     +  '"usr":"'  + %trimr(pUser) + '",'
          //     +  '"dic":"'  + %trimr(pDict) + '",'
          //     +  '"whs":"'  + %char(pWhse) + '",'
          //     +  '"fgi":"'  + %trimr(pFGItm) + '",'
          //     +  '"rmi":"'  + %trimr(pRMItm) + '",'
          //     +  '"ami":"'  + %trimr(pAMItm) + '",'
          //     +  '"wko":"'  + %trimr(pWrkOr) + '",'
                 +  '"I121xx":"'  + %trimr(I121xx) + '",'
                 +  '"imgMsg":"'  + %trimr(imgMsg) + '",'
                 +  '"dynbom":"'  + %trimr(dynBomExist) + '",'
                 +  '"prim":"'  + %trimr(primExist) + '",'
                 +  '"wipitm":"'  + %trimr(wipitem) + '",'
720bA           +  '"itmtyp":"'  + %trimr(itmtype) + '",'
                 +  '"avl":"'  + %trimr(pAvail) + '"';

          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
          EndSR;

       //*----------------------------------------------------------
       //*  BldJson2: Build JSON string
       //*----------------------------------------------------------
          BegSR BldJson2;
          // Put together JSON string
          pOutStr = '{'
                 +  '"pErr":"'  + %trimr(pErr) + '"';

          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
          EndSR;
       //*----------------------------------------------------------
       //*  UpdWorkOrd:Chain and get the the work order Raw Material
       //*             record to update and add.
       //*----------------------------------------------------------
          BegSr UpdWorkOrd;

          If Reversal;
             LeaveSR;
          EndIF;

          Eval pErr = '*OK';
          Chain (pWhse :pFGItm :pRMItm :pAMItm) pBOMSub;
          If %Found;
            Select;
              When SBPQUF = 'Y';
                Eval SBPRDQ = (SBPRDQ * WOMAKE);

              When SBPQUF <> 'Y';
710cA           if itumq2=0;
710cA              wkumq2=1;
710cA           else;
710cA              wkumq2=itumq2;
710cA           endif;
710cA           if itumq3=0;
710cA              wkumq3=1;
710cA           else;
710cA              wkumq3=itumq3;
710cA           endif;
710aA           // roll all quantities to lowest unit of measure
750aD           //sbqty2 = (sbqtyn*womake*wkumq2*wkumq3) +
750aM           wkqty2 = (sbqtyn*womake*wkumq2*wkumq3) +
710aA                    (sbqty1*womake*wkumq3) +
710aA                    (sbqty2*womake);
710cA           sbqty1=*zeros;
710cA           sbqtyn=*zeros;

750aM           DoW  wkumq3>0 and wkQTY2 >= wkUMQ3;
750aM             wkQty2 = (wkQty2 - wkUMQ3);
750aM             wkQTY1 = (wkQTY1 + 1);
710cM           EndDo;

750aM           DoW  wkumq2>0 and wkQTY1 >= wkUMQ2;
750aM             wkQTY1 = (wkQTY1 - wkUMQ2);
710cM             SBQTYN = (SBQTYN + 1);
710cM           EndDo;

750aA           sbQty1 = wkQty1;
750aA           sbQty2 = wkQty2;

              Other;
            EndSL;

             Chain (pWhse :pWrkOr :pRMItm :pFGItm) Pwrkordr;
               If %Found(PwrkOrdr);
                 Eval WRSTAT = 'D';
                 Update(e) wrrec;
                   If %error;
                      Eval pErr = 'Error updatig Orig RM WO';
                   Else;
                      Chain (pWhse :pWrkOr :pAMItm :pFGItm) Pwrkordr;
                        If %Found(Pwrkordr);
                          Eval WRITEM = pAMItm;
700aA          //         Eval WRQTYN = (WRQTYN + SBQTYN);
700aA          //         Eval WRQTY1 = (WRQTY1 + SBQTY1);
700aA          //         Eval WRQTY2 = (WRQTY2 + SBQTY2);
700aA          //         Eval WRPRDQ = (WRPRDQ + SBPRDQ);
700aA          //         Eval WRSCRF = (WRSCRF + SBSCRF);
                          Eval WRQTYN = SBQTYN;
                          Eval WRQTY1 = SBQTY1;
                          Eval WRQTY2 = SBQTY2;
                          Eval WRPRDQ = SBPRDQ;
                          Eval WRSCRF = SBSCRF;
                          Eval WRSTAT = 'O';
                          Update(e) wrrec;
710 A        // update PRimal/SubPRimal File with new raw material
710 A                   exsr UpdOrdPs;
                        Else;
                          Eval WRITEM = pAMItm;
                          Eval WRQTYN = SBQTYN;
                          Eval WRQTY1 = SBQTY1;
                          Eval WRQTY2 = SBQTY2;
                          Eval WRPRDQ = SBPRDQ;
                          Eval WRSCRF = SBSCRF;
                          Eval WRSTAT = 'O';
                          Write(e) wrrec;
710 A                     exsr UpdOrdPs;
                        EndIf;
                          If %Error;
                            Eval pErr = 'Error add/update RM WO';
                          Else;
                            Eval pErr = '*OK';
                        EndIf;
                   Endif;
               EndiF;
          EndiF;
          EndSr;
       //*----------------------------------------------------------
       //*  WrtSubLog: Write log record of subsitute being used
       //*             in file PSUBITMLOG.
       //*----------------------------------------------------------
          BegSr WrtSubLog;

            Chain (pWhse :pWrkOr :pRMItm :pFGItm) Pwrkordr;
            Eval SLWHSE = pWhse;
            Eval SLWO#  = pWrkOr;
            Eval SLFGI  = pFGItm;
            Eval SLRMI  = pRMItm;
            Eval SLAMI  = pAMItm;
            Eval SLCRDT = %Dec(%Date());
            Eval SLCRTM = %Dec(%Time());
            Eval SLUSER = pUser;
            Eval SLQTYN = WRQTYN;
            Eval SLQTY1 = WRQTY1;
            Eval SLQTY2 = WRQTY2;
            Eval SLPRDQ = WRPRDQ;
            Eval SLSCRF = WRSCRF;

            Exec SQL Insert into psubitmlog values(:airec);
          EndSr;
710 A   //*----------------------------------------------------------
710 A   //*  UpdOrdPs: When doing substitution check to see if new
710 A   //*            item is associated to a Primal/SubPrimal. If
710 A   //*            not associated then clear Primal/SubPrimal
710 A   //*----------------------------------------------------------
          BegSr UpdOrdPs;

             // look for Alternate in ITEMPRDPSA first.  If
             // found update PWRKORDPS with alternate.
             // Otherwise look in ITEMPRDPS since it is most
             // likely primary being switched back to
             setll (pWhse:pFgitm:pRmitm) itemprdpa1;
             reade (pWhse:pFgitm:pRmitm) itemprdpa1;
             dow not %eof(itemprdpa1);
                if a_iuami = pAMItm;
                   exec sql update pwrkordps set psrmi=:pAMItm
                        where pswhse=:pWhse and pswo#=:pWrkor
                          and psitem=:pFGitm and psrmi=:pRMitm;
                   leavesr;
                endif;
                reade (pWhse:pFgitm:pRmitm) itemprdpa1;
             enddo;

             // if Primal/SubPRimal found for new raw material
             // add record
             setll (pWhse:pFGItm) itemprdps;
             reade (pWhse:pFGItm) itemprdps;

             dow not %eof(itemprdps);
                if isrmi = pAMItm;
                   exec sql update pwrkordps set psrmi=:pAMItm
                        where pswhse=:pWhse and pswo#=:pWrkor
                          and psitem=:pFGitm and psrmi=:pRMitm;
                   leavesr;
                endif;
                reade (pWhse:pFGItm) itemprdps;
             enddo;

710 A     endsr;

       //*----------------------------------------------------------
       //*  RvsSubLog: Reveral of last substitution, If user
       //*             has made a mistake or just wants to reverse.
       //*----------------------------------------------------------
          BegSr RvsSubLog;
          Eval pErr = ' ';
          Eval Reversal = *Off;
            Exec SQL Select * into :airec from psubitmlog
              Where SLWO#  = :pWrkOr and
                    SLFGI  = :pFGItm and
                    SLRMI  = :pAMItm and
                    SLAMI  = :pRMItm and
                    SLCRDT = :CurrDate;

           If sqlstt <> sqlSuccess;
             pErr = 'SQL Reversal unsuccesful';
             LeaveSR;
           Else;
             Chain (pWhse :pWrkOr :pAMItm :pFGItm) Pwrkordr;
               If %Found(pwrkordr);
                Select;
                  When WRSTAT = 'O';
                    Eval WRQTY1 = SLQTY1;
                    Eval WRQTY2 = SLQTY2;
                    Eval WRPRDQ = SLPRDQ;
                    Eval WRSCRF = SLSCRF;
                    Update WRREC;
                  When WRSTAT = 'D';
                    Eval WRSTAT = 'O';
                    Update(e) WRREC;
                      If %Error;
                        Eval pErr = 'WO Reversal unsucessful';
                      Else;
                        Eval pErr = '*OK';
710 A                   exsr UpdOrdPs;
                      EndIf;
                  Other;
                EndSL;
               EndIf;
             If pErr = '*OK';
             Chain (pWhse :pWrkOr :pRMItm :pFGItm) Pwrkordr;
               If %Found(pwrkordr);
                Delete(e) wrrec;
                  If %Error;
                    Eval pErr = 'WO Reverse Delete unsucessful';
                  Else;
                    Eval pErr = '*OK';
710 A               exsr UpdOrdPs;
                  EndIf;
               EndIF;
             EndIF;

           EndIF;
             If pErr= '*OK';
               Eval Reversal = *On;
             EndIf;
          EndSr;
       //*----------------------------------------------------------
       //*  GetWorkOr: Chain and get the the work order to determine
       //*             how much we need to make.
       //*----------------------------------------------------------
          BegSr GetWorkOrd;
             Chain (pWhse :pWrkOr) Pwrkord;
               If %Found(PwrkOrd);
                 Chain (pWhse :pAMItm) Itemprd;
                   If %Found(Itemprd);
                     Chain (pWhse :pAMItm) Piritem;
                       If %Found(Piritem);
700aA                     wkumq2=itumq2;
700aA                     wkumq3=itumq3;
700aA                     if wkumq2=0;
700aA                        wkumq2=1;
700aA                     endif;
700aA                     if wkumq3=0;
700aA                        wkumq3=1;
700aA                     endif;
                          Select;
                           When IPPRDQ > 0;
                             ItmPounds = (ITSWGT / IPPRDQ);
                             ItmPounds = ItmPounds * ITSWGT;
                           When IPPRDQ = 0 and
700aD                 //        ITUMQ2 <> 0;
700aA                           (ITUMQ2 <> 0 or itumq3<>0);
700aA                        ItmPounds = (ITSWGT / (WKUMQ2*WKUMQ3));
                           Other;
                             ItmPounds = (ITSWGT);
                         EndSL;
                       EndIf;
                  EndiF;
               EndiF;
          EndSr;
       //*----------------------------------------------------------
       //*  GetSubBOM: Chain and get the substitute item also Chain
       //*             to the PRMSUM file to get additional info to
       //*             be used down the line for calculations.
       //*----------------------------------------------------------
          BegSR GetSubBOM;

          Chain (pWhse :pFGItm :pRMItm :pAMItm) pBOMSub;
          If %Found;

            Select;
              When SBPQUF = 'Y';
                Eval CurDmndP = (SBPRDQ * WOMAKE);

              When SBPQUF <> 'Y';
700aA           // Ensure weight is correct if normal breakdowns used
700aA           if (ITUMQ2 <> 0 or itumq3<>0);
700aA              ItmPounds = (ITSWGT / (WKUMQ2*WKUMQ3));
700aA           else;
700aA              ItmPounds = (ITSWGT);
700aA           Endif;
                Eval CaseQN = (SBQTYN * WOMAKE);
                Eval BrkD1N = (SBQTY1 * WOMAKE);
700aA           Eval BrkD2N = (SBQTY2 * WOMAKE);
700aD    //     Eval CurDmndI = ((CaseQN * ITUMQ2)+BrkD1N);
700aA           Eval CurDmndI = ((CaseQN * WKUMQ2 * WKUMQ3) +
700aA                            (BRKD1N * WKUMQ3) + BRKD2N);
              Other;
            EndSL;
            ExSR CurrDemand;

            Select;
              When SBPQUF = 'Y';
                  If RemProdP >= 0;
                     Eval pAvail = 'Y';
                  Else;
                     Eval pAvail = 'N';
                  EndIf;

              When SBPQUF <> 'Y';
                  If RemProdI >= 0;
                     Eval pAvail = 'Y';
                  Else;
                     Eval pAvail = 'N';
                  EndIf;
              Other;
            EndSL;

          EndIf;

          EndSR;
       //*----------------------------------------------------------
       //*  CurrDemand: Chain to PRMSUM to get current demand
       //*----------------------------------------------------------
          BegSr CurrDemand;
            Chain (pSessID :pWhse :pAMItm) Prmsum;
              If %Found(Prmsum);
                ExSR CvtBrkD;

                Select;
                  When SBPQUF = 'Y';
                    WkODmndP = ((WkOrdPnd) / (1+SBSCRF));

                  When SBPQUF <> 'Y';
700aD    //         WkODmndI = ((CaseQN * ITUMQ2) + BrkD1N);
700aA               WkODmndI = ((CaseQN * WKUMQ2 * WKUMQ3) +
700aA                            (BRKD1N * WKUMQ3) + BRKD2N);
                  Other;
                EndSL;

                TotDmndI = (CurDmndI+WkODmndI);
                TotDmndP = ((CurDmndP+WkODmndP) * (1+SBSCRF));
              Else;
                TotDmndI = (CurDmndI);
                TotDmndP = ((CurDmndP) * (1+SBSCRF));
              EndIf;
       //*    {Get current available inventory}  -------------------
              ExSR accumInv;
              RemProdI = (TotOnhdI-TotDmndI);
              RemProdP = (TotOnhdP-TotDmndP);
          EndSr;
       //*----------------------------------------------------------
       //*  CvtBrkD: Convert Breakdo from character to numeric
       //*----------------------------------------------------------
          BegSr CvtBrkD;
       //*    {Inventory breakdown}  -------------------------------
              FPos = %Scan('.' :SMREQQ);
              CaseQ_A = %SubSt(SMREQQ :1:FPos-1);
              CaseQN  = %Dec(CaseQ_A:5:0);
              LPos = %Scan('.' :SMREQQ :Fpos+1);
                If Lpos = 0;
                   Eval Lpos = FPos+1;
                   BrkD1_A = %SubSt(SMREQQ :LPos:5);
                   BrkD1N  = %Dec(BrkD1_A:5:0);
                EndIf;
       //*    {Production Breakdown} -------------------------------
              WkOrdPnd = %Dec(SMREQP:9:2);
          EndSr;
       //*----------------------------------------------------------
       //*   accumInv  Accumulate Inventory totals for Raw Material-
       //*----------------------------------------------------------

       Begsr accumInv;

         // get Production line inventory aisle
          SetLL (pwhse) Plined;
          ReadE (pwhse) Plined;
          if not %equal(Plined);
             inRcvAisl = 'LIN';
          endif;

         // get available inventory
          Avl1=0;
          Avl2=0;
          Avl3=0;
          SetLL (pWhse:pAMItm) Slot3;
          ReadE (pWhse:pAMItm) Slot3;
          DoW Not %Eof(slot3);
             If slstat = 'A ' or slaisl = inRcvAisl;
                exsr avail;  // add to available stock from warehouse
                Avl1 += avail1;
                Avl2 += avail2;
                Avl3 += avail3;
             endif;
             ReadE (pWhse:pAMItm) Slot3;
          EndDo;

          // kde - 120716 - Only a patch to get past Sofo Demo
          // we must revisit.......
700aD     // if ipprdq <> *zeros;
700aA     if ipprdq <> *zeros and SBPQUF = 'Y';
710bD        // TotOnhdI = Avl1;
710bA        TotOnhdP = Avl1 * ipPrdq;
          else;
700aD    //  TotOnhdI = ((Avl1 * ITUMQ2) + Avl2);
700aA        TotOnhdI = ((Avl1 * WKUMQ2 * WKUMQ3) +
700aA                    (Avl2 * WKUMQ3) + AVL3);
          endif;
710bD     // TotOnhdP = (TotOnhdI * ItmPounds);

       endsr;
      /end-free

720bA /free
720bA   //*----------------------------------------------------------
720bA   //*   getType  --  Get item type for specific BOM entry
720bA   //*----------------------------------------------------------
720bA
720bA  Begsr getType;
720bA      itmtype='R';
720bA      exec sql select ipprdflg into :itmtype
720bA           from itemprd
720bA                where ipitem = :prmitm
720bA                   fetch first row only;
720bA  endsr;
720bA /end-free
720bA
     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     *----------------------------------------------------------------
     C     avail         begsr
     *
     *  Call program to calculate availabe slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0

     *  Call program to get open Directed Putaway quantity.

     C                   call      'CHKOPNDP'
     C                   parm      slwhse        dWhse             3 0
     C                   parm      slwhdp        dWhdp             5
     C                   parm      sldisp        dDisp            12
     C                   parm      slitem        dItem            15
     C                   parm                    dTotal            3 0
     C                   parm                    dItmTtl           3 0
     C                   parm                    dQty1             5 0
     C                   parm                    dQty2             5 0
     C                   parm                    dQty3             5 0

     C                   eval      avail1 += dQty1
     C                   eval      avail2 += dQty2
     C                   eval      avail3 += dQty3

     *  Set negative quantities to zero

     C                   if        avail1 < 0
     C                   eval      avail1 = 0
     C                   endif
     C                   if        avail2 < 0
     C                   eval      avail2 = 0
     C                   endif
     C                   if        avail3 < 0
     C                   eval      avail3 = 0
     C                   endif
     C                   endsr

      /free
       //*----------------------------------------------------------
       //*   PrimalExist - Check to see if Primal definition exist
       //*----------------------------------------------------------

       Begsr PrimalExist;

          // check to see if primal exist.  If so return json value
          // to prevent user from adding any substitutions through
          // the substitution screen.  In this case they would need
          // to add alternates under the BOM/Primal maintenance.
          // Also send code back that says whether this raw material
          // is only on a dynamic bom.  If so do not allow Substitution

          recCnt = 0;
          exec sql select count(*) into :recCnt
                   from itemprdps
                   where iswhse=:pWhse and isitem=:pFgItm
                     and isRmi=:pRmItm;
          if sqlstt='00000' and recCnt <> 0;
             recCnt = 0;
             exec sql select count(*) into :recCnt
                       from pBomSub
                       where sbwhse=:pWhse and sbfgi=:pFgItm
                         and sbRmi=:pRmItm;
             if sqlStt <> '00000' or recCnt = 0;
                primExist = 'S';
              imgMsg = 'Substitution must be defined using Primal ' +
                       'Maintenance when Primal exist';
             else;
                primExist = 'Y';
             endif;
             leavesr;
          else;
             imgMsg = *blanks;
             primExist = 'N';
          endif;

          // return value if raw material/finished good combination
          // are only found on Dynamic BOM.  We do not allow Substitution
          // in that case
          recCnt = 0;
          exec sql select count(*) into :recCnt
                     from pBomVers
                    where pxwhse=:pWhse and pxfgi=:pFgItm
                      and pxRmi=:pRmItm;
          if sqlstt = '00000' and recCnt <>0;
             recCnt =0;
             exec sql select count(*) into :recCnt
                      from pBom
                       where bmwhse=:pWhse and bmfgi=:pFgItm
                         and bmRmi=:pRmItm;
             if sqlstt = '00000' and recCnt <> 0;
                dynBomExist = 'N';
                imgMsg = *blanks;
             else;
                recCnt = 0;
                exec sql select count(*) into :recCnt
                        from pBomSub
                          where sbwhse=:pWhse and sbfgi=:pFgItm
                            and sbRmi=:pRmItm;
                if sqlstt = '00000' and recCnt <>0;
                   dynBomExist = 'N';
                   imgMsg = *blanks;
                else;
                   imgMsg = 'Substitution not allowed if raw material ' +
                            'Dynamic BOM only';
                   dynBomExist = 'Y';
                endif;
             endif;
          else;
             dynBomExist = 'N';
             imgMsg = *blanks;
          endif;
          setll *loval pBomSub;

          // make sure Work Orders exist for passed in warehouse and raw
          // material where the status is not closed, deleted, released
          // or working before taking user from I121xx to I122xx.  I122xx
          // does not show anything from released forward since we do not
          // allow changes at that point.  The reasons are that replenishments
          // were generated and could have been processed and work orders
          // could have been started.
          recCnt = 0;
          exec sql select count(*) into :recCnt
                   from pwrkordr as d
                   where d.wrwhse=:pWhse and d.writem=:pFgitm
                     and not d.wrstat in('C','R','D','W') and
                     (select count(*) from pwrkord as o
                     where o.wowhse=d.wrwhse and o.wowo#=d.wrwo#
                       and not o.wostat in('C','R','D','W'))<>0;
          if sqlstt<>'00000' or recCnt = 0;
             i121xx = 'S';
             imgMsg = 'Item cannot be manipulated since all Work Orders ' +
                      'have advanced beyond Planning';
          endif;

720 A     // Return value as "Y" for Yes if Work Order Item begins with WIP
720 A     // These items should not allow substitutions
730aA     chain (pWhse:pRmitm) itemprd;
730aD     //if %len(pRmItm) >= 3;
730aD        //if %subst(pRMItm:1:3) = 'WIP';
730aA        if ipPrdFlg='C';
720 A       //    wipitem='Y';
720 A        else;
720 A          wipitem='N';
720 A        endif;
730aD     //else;
730aD     //   wipitem='N';
730aD     //endif;

       Endsr;
      /end-free

       //*----------------------------------------------------------
       //*  *INZSR   Initialization subroutine
       //*----------------------------------------------------------
      /free
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
                  + '&pAMItm =' + %trimr(pAMItm)
                  + '&pWrkOr =' + %trimr(pWrkOr)
                  + '&pAction=' + %trimr(pAction)
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
