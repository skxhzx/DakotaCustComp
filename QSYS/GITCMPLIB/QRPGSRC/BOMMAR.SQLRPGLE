      *copy *libl/qcopysrc,hspecs
     Hcopyright('(c) Copyright BFC Software, Inc - 2016')
     H optimize(*NONE)
     H decedit(*JOBRUN)
     H truncnbr(*NO)
     H option(*srcstmt : *nodebugio)
     H Dftactgrp(*No)
     *----------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Rese
     *   BFC Software, Inc.
     *----------------------------------------------------------

     *----------------------------------------------------------
     *
     *  BOMMAR      SQL Function to check or delete Marinade
     *              BOM associated record from filr PBOMI
     *
     *  16 January 2017
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    01/16/17  TAB  7.10
     *      - Created
     *
     *----------------------------------------------------------
     * File Specs
     *----------------------------------------------------------
     * Production Item Master file------------------------------
     Fitemprd   if   e           k disk
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
     D text            s            200    varying
     D CurrDate        S              8  0
     D pErr            S             50    Inz
     D pSeq            S              6  0

     *----------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  Parms coming in to program(SUBQAVL) from MRC
     *----------------------------------------------------------
     D  bommar         pr                  extpgm('BOMMAR')
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pFGItm                       15     varying
     D  pAction                       1    varying
     D  pOutStr                     200    varying

     D  bommar         pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pWhse                         3p 0
     D  pFGItm                       15    varying
     D  pAction                       1    varying
     D  pOutStr                     200    varying
     *----------------------------------------------------------
     *  Parms coming in to program(BOMMAR) from command line
     *----------------------------------------------------------
     D* bommar         pr                  extpgm('BOMMAR')
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pFGItm                       15
     D* pAction                       1
     D* pOutStr                     200

     D* bommar         pi
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pFGItm                       15
     D* pAction                       1
     D* pOutStr                     200
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------
     Dpbomi          E DS                  ExtName(PBOMI)
     *----------------------------------------------------------
     *                  M A I N    L I N E                     *
     *----------------------------------------------------------

      /free

         *inlr = *on;
         #curruser = pUser;
         CurrDate = %Dec(%Date());

        // Set SQL default parms
          exec sql
            set Option Commit=*none, Dlyprp=*Yes,
                       Closqlcsr = *ENDMOD;

           Select;

             When pAction = 'L';
               ExSr ChkPrdItm;
               ExSr BldJson2;

             When pAction = 'C';
               ExSr GetBomMar;
               ExSr BldJson2;

             When pAction = 'D';
               ExSr DelPbomMar;
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
                  +  '"pErr":"'  + %trimr(pErr) + '",'
                  +  '"pSeq":"'  + %Char(pSeq) + '"';


          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
          EndSR;
       //*----------------------------------------------------------
       //*  DelPbomMar: Delete PBOMMAR record
       //*
       //*----------------------------------------------------------
          BegSr DelPbomMar;
                Eval pErr = ' ';
                Exec SQL Delete from PBOMI
                         Where BIWHSE = :pWhse and
                               BIFGI  = :pFgitm;
                Eval pErr = '*OK';
          EndSr;
       //*----------------------------------------------------------
       //*  GetBomMar: Get record from PBOMI file if exsist, send
       //*             back mode=U. If it does not exsist
       //*             send back mode=A.
       //*----------------------------------------------------------
          BegSr GetBomMar;
                Exec SQL Select * into :pbomi from PBOMI
                         Where BIWHSE = :pWhse and
                               BIFGI  = :pFgitm;

          Select;
            when sqlstt <> sqlSuccess;
                 pErr = 'A';
                 pSeq = 0;
            other;
                 pErr = 'U';
                 pSeq = 0;
          EndSL;

          EndSr;

       //*----------------------------------------------------------
       //*  ChkPrdItm; Check to see if item is a component
       //*
              // "L" means M151xx initially loading and deciding whether
              // to display Instruction button on not based on whether
              // Marinades exist.  In either case we send back nines to
              // prevent it from acting like button was pressed.  If "L"
              // sent and no marinades it will not send back "S" and
              // therefore will not show MArinade button to click.
       //*----------------------------------------------------------
          BegSr ChkPrdItm;
                Chain (pWhse: pFgItm) itemprd;
          Select;
            when %Found(itemprd);
                 If IPPRDFLG = 'C';
                   pErr = 'S';   // Show Instruction button
                   pSeq = 999999;
                 Else;
                   pErr = ' ';   // Hide Instruction button
                   pSeq = 999999;
                 EndIf;
          EndSL;

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
