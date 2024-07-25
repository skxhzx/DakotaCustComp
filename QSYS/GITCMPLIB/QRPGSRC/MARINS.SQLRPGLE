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
     *  MARINS      SQL Function to check to determine how to
     *              handle marinade instructions.........
     *
     *  03 Januaryr 2017
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    01/03/17  TAB  7.00
     *      - Created
     *
     *----------------------------------------------------------
     * File Specs
     *----------------------------------------------------------
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
     D  marins         pr                  extpgm('MARINS')
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pdFgi                        15
     D  pOutStr                     200    varying

     D  marins         pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pWhse                         3p 0
     D  pdFgi                        15
     D  pOutStr                     200    varying
     *----------------------------------------------------------
     *  Parms coming in to program(MARINS) from command line
     *----------------------------------------------------------
     D* marins         pr                  extpgm('MARINS')
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pdFgi                        15
     D* pOutStr                     200

     D* dynbom         pi
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pdFgi                        15
     D* pOutStr                     200
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------
     D birec         E ds                  extname(pbomi) inz(*EXTDFT)
     *----------------------------------------------------------
     *                  M A I N    L I N E                     *
     *----------------------------------------------------------

      /free

         *inlr = *on;
         #curruser = pUser;
         CurrDate = %Dec(%Date());

               ExSr ChkInstr;
               ExSr BldJson2;

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
       //*  ChkInstr: Check to see if instruction record already
       //*            exists. If so send back '*UPD'
       //*----------------------------------------------------------
          BegSr ChkInstr;

          exec sql select * into :birec
                  from pbomi
                  where biwhse = :pwhse
                    and bifgi  = :pdfgi;

          if sqlstt = sqlSuccess;
                   Eval pErr = '*UPD';
          else;
                   Eval pErr = '*ADD';
          Endif;

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
                  + '&pdFgi  =' + %trim(pdFgi)
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
