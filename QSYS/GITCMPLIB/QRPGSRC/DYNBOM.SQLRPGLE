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
     *  DYNBOM      SQL Function to update work order detail
     *              file with Dynamic BOM seleted by user
     *
     *  08 December 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    12/08/16  TAB  7.00
     *      - Created
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
     *
     *----------------------------------------------------------
     * File Specs
     *----------------------------------------------------------
     * Work Order file  ----------------------------------------
     FPwrkord   if   e           k disk
     * Work Order Raw Material file  ---------------------------
     FPwrkordr  uf a e           k disk
     * Dynamic BOM Detail file  --------------------------------
     FPbomvers1 if   e           k disk
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
     D text            s            200    varying
     D CurrDate        S              8  0
     D pErr            S             50    Inz

     *----------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  Parms coming in to program(SUBQAVL) from MRC
     *----------------------------------------------------------
     D  dynbom         pr                  extpgm('DYNBOM')
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pFGItm                       15     varying
     D  pAltSq                        6p 0
     D  pWrkOr                       13    varying
     D  pAction                       1    varying
     D  pOutStr                     200    varying

     D  dynbom         pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pWhse                         3p 0
     D  pFGItm                       15    varying
     D  pAltSq                        6p 0
     D  pWrkOr                       13    varying
     D  pAction                       1    varying
     D  pOutStr                     200    varying
     *----------------------------------------------------------
     *  Parms coming in to program(SUBQAVL) from command line
     *----------------------------------------------------------
     D* dynbom         pr                  extpgm('DYNBOM')
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pFGItm                       15
     D* pAltSq                        6p 0
     D* pWrkOr                       13
     D* pAction                       1
     D* pOutStr                     200

     D* dynbom         pi
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pFGItm                       15
     D* pAtlSq                        6p 0
     D* pWrkOr                       13
     D* pAction                       1
     D* pOutStr                     200
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------
     *----------------------------------------------------------
     *                  M A I N    L I N E                     *
     *----------------------------------------------------------

      /free

         *inlr = *on;
         #curruser = pUser;
         CurrDate = %Dec(%Date());


           Select;

             When pAction = 'U';
               ExSr GetWorkOrd;
               ExSr UpdWorkOrd;
               ExSr BldJson2;
             Other;
           EndSL;

          if debug;
            exsr wrtDebugParms;
          endif;

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
       //*  UpdWorkOr: Chain and get the Dynamic BOM, then write new
       //*             records to work order detail file
       //*----------------------------------------------------------
          BegSr UpdWorkOrd;

          Eval pErr = ' ';
          SetLL (pWhse :pFGItm :pAltSq) pBOMvers1;

            DoU %Eof(pBOMVers1);
              ReadE (pWhse :pFGItm :pAltSq) pBOMvers1;
               If %Found;
                Eval WRWHSE = pWhse;
                Eval WRWO#  = pWrkOr;
                Eval WRFGI  = PXFGI;
                Eval WRITEM = PXRMI;
                Eval WRMFGNO = WOMFGNO;
                Eval WRQTYN = (pxQTYN * WOMAKE);
                Eval WRQTY1 = (pxQTY1 * WOMAKE);
                Eval WRQTY2 = (pxQTY2 * WOMAKE);
                Eval WRPRDQ = (pxPRDQ * WOMAKE);
                Eval WRSCRF = (pxSCRF);
                Eval WRSTAT = 'O';
                monitor;
                Write(e) wrrec;
                 on-error;
                   Eval pErr = 'Error creating DYN BOM';
                   LeaveSR;
                 endmon;
               EndIf;
            EndDo;
                   Eval pErr = '*OK';
          EndSr;
       //*----------------------------------------------------------
       //*  GetWorkOr: Chain and get the the work order to determine
       //*             how much we need to make. Then flag original
       //*             work order detail records with a  'D'
       //*----------------------------------------------------------
          BegSr GetWorkOrd;
             Chain (pWhse :pWrkOr) Pwrkord;
               If %Found(PwrkOrd);
700aD          //  Exec SQL Update Pwrkordr
700aD          //           Set WRSTAT = 'D'
700aD          //           Where WRWO# = :pWrkOr;
700aD              Exec SQL Delete from Pwrkordr
700aD                       Where WRWO# = :pWrkOr;
               EndiF;
          EndSr;

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
                  + '&pAltSq =' + %Char(pAltSq)
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
