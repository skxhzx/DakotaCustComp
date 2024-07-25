      *copy *libl/qcopysrc,hspecs
     Hcopyright('(c) Copyright BFC Software, Inc - 2017')
     H optimize(*NONE)
     H decedit(*JOBRUN)
     H truncnbr(*NO)
     H option(*srcstmt : *nodebugio)
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22600  Production Marinade Edits and Updates  (Header)
     *  19 Dec 2016
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    12/19/16  TAB  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FPmarinh   UF A E           k disk
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
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D dbgflgExists    s               n
     D debug           s               n
     D Error           s               n
     D i               s              3  0
     D len             s              3  0
     D whse            s              3  0
     D text            s            200    varying
     D CurrDate        S              8  0
     D pErr            S             50    Inz
     D pAct            S              1    Inz
     D MarinSeq        S              6  0
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------
     *  Parms coming in to program(M22600) from MRC
     *----------------------------------------------------------
     D  m22600         pr                  extpgm('M22600')
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pMarNm                       45     varying
     D  pMarSq                        6p 0
     D  pMarBs                        8p 0
     D  pAction                       1    varying
     D  pOutStr                     200    varying

     D  m22600         pi
     D  pSessId                      40     varying
     D  pUser                        10     varying
     D  pDict                        10     varying
     D  pPgm                         10     varying
     D  pWhse                         3p 0
     D  pMarNm                       45     varying
     D  pMarSq                        6p 0
     D  pMarBs                        8p 0
     D  pAction                       1    varying
     D  pOutStr                     200    varying
     *----------------------------------------------------------
     *  Parms coming in to program(M22600) from command line
     *----------------------------------------------------------
     D* m22600         pr                  extpgm('M22600')
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pMarNm                       45
     D* pMarSq                        6p 0
     D* pMarBs                        8p 0
     D* pAction                       1
     D* pOutStr                     200

     D* m22600         pi
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pWhse                         3p 0
     D* pMarNm                       45
     D* pMarSq                        6p 0
     D* pMarBs                        8p 0
     D* pAction                       1
     D* pOutStr                     200
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------
     D mhrecx        E ds                  extname(pmarinh) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         #curruser = pUser;
         CurrDate = %Dec(%Date());

        // Set SQL default parms
          exec sql
            set Option Commit=*none, Dlyprp=*Yes,
                       Closqlcsr = *ENDMOD;

             Exsr FldValid;
             Exsr BldJson;

          if debug;
            exsr wrtDebugParms;
          endif;

         return;

       //*----------------------------------------------------------
       //*  BldJson  Build JSON string
       //*----------------------------------------------------------
          BegSR BldJson;
          // Put together JSON string
          pOutStr = '{'
                 +  '"pErr":"'  + %trimr(pErr) + '",'
                 +  '"pSeq":"'  + %Char(MHSEQ) + '",'
                 +  '"pAct":"'  + %trimr(pAction) + '"';

          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
          EndSR;
      /end-free
     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

        // Validate input

         If pAction <> 'D';
           ExSR errorcheck;
           If Error;
             LeaveSR;
           EndIf;
         EndIf;

        // Get Mext available sequence number from PMARINH
         Exsr GetRec;

         Select;

          // Add

           When pAction = 'A';
               Exsr AddRec;

          // Copy/Update

           When pAction = 'U' or pAction = 'C';
               exsr UpdRec;

          // Delete

           When pAction = 'D';
               exsr DelRec;

           Other;
             pErr = 'Invalid command sent: ' + pAction
                      + %trim(pAction)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  GetRec    Get last sequence number in PBOMVERH file
     *----------------------------------------------------------------

      /free
       begsr GetRec;

          SetLL (pWhse) pmarinh;
          ReadE (pWhse) pmarinh;
            DoU %Eof(pmarinh);
              If %Found(pmarinh);
                MarinSeq = MHSEQ;
              EndIF;
            ReadE (pWhse) pmarinh;
            EndDO;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;
       error = *off;
         Select;

          // Update Marinade Header.............
           When pAction = 'U';
             Chain (pWhse :pMarSq) pmarinh;
             If %Found(pmarinh);
               Eval MHMARN = pMarNm;
               Eval MHFBAS = pMarBs;
               Update(e) mhrec;
             EndIf;

           If %Error;
             pErr = 'Error Updating Marinade Header: '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'AltN(' + %trim(pMarNm) + ') '
                    + 'Base(' + %Char(pMarBs) + ') '
                    + 'Seq(' + %trim(%char(pMarSq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
          Else;
            pAct = pAction;
            pErr = '*OK';
           Endif;

           Other;
         EndSL;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;
         error = *off;

      // Add Marinade Header..........

          Eval MHWHSE = pWhse;
          Eval MHMARN = pMarNm;
          Eval MHSEQ = (MarinSeq + 1);
          Eval MHFBAS = pMarBs;
          Eval MHUSER = pUser;
          Eval MHCRDT = %Dec(%Date());
          Eval MHCRTM = %Dec(%Time());
          Write(e) mhrec;

          If %Error;
            pErr = 'Error Creating Mairnade Recipe: '
                   + 'Whse(' + %char(pWhse) + ') '
                   + 'AltN(' + %trim(pMarNm) + ') '
                   + 'Seq(' + %trim(%char(MarinSeq)) + ') '
                   + 'Pgm(' + %trim(#pgm) +')';
          Else;
            pAct = pAction;
            pErr = '*OK';
          Endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       Begsr DelRec;

         error = *off;

        // Delete Dynamic BOM Header.............

         Exec SQL Delete from pmarinh
                  where mhwhse = :pwhse
                    and mhseq  = :pMarSq;

         if sqlstt <> sqlSuccess;
           pErr = 'Error Deleting Marinade Header: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Nm(' + %trim(pMarNm) + ') '
                    + 'Seq(' + %trim(%char(pMarSq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
        // Delete Entire recipe records
         Exec SQL Delete from pmarind
                  where mdwhse = :pwhse
                    and mdseq  = :pMarSq;

         Exec SQL Delete from pmarini
                  where miwhse = :pwhse
                    and miseq  = :pMarSq;
           pAct = pAction;
           pErr = '*OK';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

           // Check to see if Marinade recipe name has been used.
         If pAction = 'A';
         exec sql select * into :mhrecx
                  from pmarinh
                  where mhwhse = :pwhse
                    and mhmarn = :pMarnm;

         if sqlstt = sqlSuccess;
           pErr = 'Marinade recipe is currently on file';
           error = *on;
           leavesr;
         Endif;
         EndIf;
           // Check to see if Marinade Name is blank.

         If pMarNm = ' ';
           pErr = 'Marinade recipe must have a name';
           error = *on;
           leavesr;
         EndIf;

         If pMarBs = 0;
           pErr = 'You must enter a recipe base';
           error = *on;
           leavesr;
         EndIf;

       endsr;
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
                  + '&pMarNm =' + %trimr(pMarNm)
                  + '&pMarSq =' + %Char(pMarSq)
                  + '&pMarBs =' + %Char(pMarBs)
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

