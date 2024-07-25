      *copy *libl/qcopysrc,hspecs
     Hcopyright('(c) Copyright BFC Software, Inc - 2016')
     H optimize(*NONE)
     H decedit(*JOBRUN)
     H truncnbr(*NO)
     H option(*srcstmt : *nodebugio)
     H Dftactgrp(*No)
      *----------------------------------------------------------
      *   Copyright (C) 2017 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  R25000      SQL Function call
      *  25 July 2017
      *  Thomas Bryant
      *
      *  Revisions:
      *
     *    07/25/17  TAB  7.10
     *      - Created
      *
      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
     D*copy qcopysrc,c#pgminfds

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
      *  Variables
      *----------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n
     D Error           s               n
     D i               s              3  0
     D len             s              3  0
     D whse            s              3  0
     D pUserid         S             10    Inz(' ')
     D Newnum          s              5p 0 Inz(99999)
     D pErr            S              3    Inz('   ')
     D text            s            200    varying

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------
     D dsUsrec       E Ds                  Extname(Piruser)
     D dsPcstl       E Ds                  Extname(Plabcstlne)
      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pUserN       User name
     *      pWhse        Warehouse hard wired to user
     *      pUsrNo       Employee number
     *      pHours       Normal Hours
     *      pCtype       Labor Cost Type ('A') or ('S')
     *      pOutStr      Return string with JSON data
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------
     D  r25000         pr                  extpgm('R25000')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pUserN                       40    varying
     D  pWhse                         3p 0
     D  pUSrNo                        5p 0
     D  pHours                        3p 1
     D  pCType                        1    varying
     D  pOutStr                     200    varying

     D  r25000         pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pUserN                       40    varying
     D  pWhse                         3p 0
     D  pUsrNo                        5p 0
     D  pHours                        3p 1
     D  pCType                        1    varying
     D  pOutStr                     200    varying

      /free

         *inlr = *on;
         #curruser = pUser;


          if debug;
            exsr wrtDebugParms;
          endif;

           exsr GetUser;
           exsr bldjson;
      /end-free
      *----------------------------------------------------------
      *  BldJson  Build JSON string
      *----------------------------------------------------------
      /free
          BegSR BldJson;
          // Put together JSON string
          pOutStr = '{'
                 +  '"scid":"'  + %trimr(pSessID) + '",'
                 +  '"scu":"'  + %trimr(pUser) + '",'
                 +  '"scd":"'  + %trimr(pDict) + '",'
                 +  '"pErr":"'  + %trimr(pErr) + '",'
                 +  '"ename":"'  + %trimr(pUserN) + '",'
                 +  '"usrid":"'  + %trimr(pUserid) + '",'
                 +  '"Eno":"'  + %char(pUsrno) + '",'
                 +  '"whse":"'  + %char(pWhse) + '",'
                 +  '"hour":"'  + %char(pHours) + '"';

          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
          EndSR;
      /end-free

      *----------------------------------------------------------
      *  GetUser  Check PIRUSER for employee number
      *----------------------------------------------------------
      /free
          BegSR GetUser;

        // get User record
          If pCType = 'A';
             Exec SQL
                Select * into :dsUsrec from piruser
                where uswhse = :pwhse and
                      usEMP# = :pUsrNo;

          if Sqlstt <> sqlSuccess;
             pErr = '*NF';
             pHours = 0;
             pUserid = ' ';
             pUserN  = ' ';
          else;
            Exec SQL
              Select * into :dspcstl from Plabcstlne
                where lcwhse = :pwhse and
                      LCEMP# = :pUsrNo;
              if Sqlstt <> sqlSuccess;
                pErr = '*OK';
                pUserN = %trimr(usfnam) + ' ' + %trimr(usinit) +
                         ' ' + %trimr(uslnam);
                pHours = USNHRS;
                pUserid = USCODE;
              else;
                pErr = '*DP';
                pHours = 0;
                pUserid = ' ';
                pUserN  = ' ';
              EndIf;
          EndIf;

          EndIf;
       // Now lets build a standard employee
          If pCType = 'S';

            DoU Sqlstt <> sqlSuccess;
            Exec SQL
              Select * into :dspcstl from Plabcstlne
                where lcwhse = :pwhse and
                      LCEMP# = :Newnum;
              if Sqlstt <> sqlSuccess;
                pErr = '*OK';
                pHours = 0;
                pUsrNo = Newnum;
                pUserid = 'STUSR' + %char(Newnum);
                pUserN = 'Standard User' + ' ' + %trimr(pUserid);
                Leave;
              Else;
                Newnum = (Newnum - 1);
              EndIf;
            EndDo;
          EndIf;
          EndSR;
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

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pSessID = ' + pSessID
                  + '&pUser=' + %trimr(pUser)
                  + '&pDict=' + %trimr(PDict)
                  + '&pPgm=' + %trimr(pPgm)
                  + '&pUserN=' + %trimr(pUserN)
                  + '&pWhse =' + %char(pWhse)
                  + '&pUsrNo =' + %char(pUsrNo)
                  + '&pHours =' + %char(pHours)
                  + '&pCtype =' + %trimr(pCtype)
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

      *----------------------------------------------------------
      *  wrtDebugError  Write out debug error
      *----------------------------------------------------------

      /free
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
