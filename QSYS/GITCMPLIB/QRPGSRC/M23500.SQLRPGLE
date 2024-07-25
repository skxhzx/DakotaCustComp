      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M23500  Production Labor Cost Line Definition
     *  09 May 2017
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    05/09/17  TAB  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lcrec         E ds                  extname(plabcstlne) inz(*EXTDFT)
     D lclrec        E ds                  extname(plabcstlog) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pMessage       s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  dpCombo        s             20
     d  pAction        s              1
     d  pWhse          s              3  0
     d  pMfgL          s              4
     d  pDesc          s             40
     d  pEmpl          s              4  0
     d  pLabr          s              7  3
     d  pHour          s              4  2
     d  pBnft          s              6  4
     d  pOvrh          s              6  4
     d  pStatus        s              1
     d  pSun           s              1
     d  pMon           s              1
     d  pTue           s              1
     d  pWed           s              1
     d  pThu           s              1
     d  pFri           s              1
     d  pSat           s              1
     d  pSeqNo         s              5  1
     d  pCcntr         s             10
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     D Numberss        C                   ' 0123456789'
     d  LineNo         s              3  0
     d  LineAl         s              3
     d  $LcLine        s              4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D logText         s            100
     d pNxtSq          s                   like(lcseq)
     d DaysofWk        s              7    Inz

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d GetCurrStamp    pr

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z
     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      PBOM  fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     c                   parm                    pMessage
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    dpCombo
     c                   parm                    pAction
     c                   parm                    pWhse
     c                   parm                    pMfgL
     c                   parm                    pDesc
     c                   parm                    pEmpl
     c                   parm                    pLabr
     c                   parm                    pHour
     c                   parm                    pBnft
     c                   parm                    pOvrh
     c                   parm                    pStatus
     c                   parm                    pSun
     c                   parm                    pMon
     c                   parm                    pTue
     c                   parm                    pWed
     c                   parm                    pThu
     c                   parm                    pFri
     c                   parm                    pSat
     c                   parm                    pSeqNo
     c                   parm                    pCcntr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         // Set SQL default parms
         exec sql
           set Option Commit=*none, Dlyprp=*Yes,
                      Closqlcsr = *ENDMOD;

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pAction;
         wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);


         // Convert Labor line
           If pMfgL <> '*ALL' and
              pMfgL <> *Blanks;
             LineNo = %Dec(pMfgL:3:0);
             LineAl = %editC(LineNo:'X');
             Eval $LcLine = LineAl;
           Else;
             Eval $LcLine = pMfgL;
           EndIf;

         //  Validates entries and then update if no errors found
         exsr FldValid;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;

         /// First lets write a log record
         exsr AddLogRec;

         exec sql insert into plabcstlne values(:lcrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'pSeqNo(' + %char(pSeqNo) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         // delete Assigned UCI

         exec sql delete from Plabcstlne
                  where lcwhse = :pwhse
                    and lcline = :$LcLine
                    and lcseq  = :pSeqNo;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'pSeqNo(' + %char(pSeqNo) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update Record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         /// First lets write a log record
         exsr AddLogRec;

         exec sql update plabcstlne
                  Set LCDESC  = :pDesc,
                      LCEMPC  = :pEmpl,
                      LCSRTE  = :pLabr,
                      LCHRDY  = :pHour,
                      LCDYWK  = :DaysofWk,
                      LCBENRT = :pBnft,
                      LCOHPCT = :pOvrh,
                      LCSTAT  = :pStatus
                  where lcwhse = :pwhse
                    and lcline = :$LcLine
                    and lcseq  = :pSeqNo;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'pSeqNo(' + %char(pSeqNo) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ErrorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Check and covert line if needed
         If pMfgL = *blanks;
           pMessage = 'Labor Line must be selected';
           error = *on;
           leavesr;
         Else;
         EndIf;

         // Check that description was entered
         If pDesc = *blanks;
           pMessage = 'Line Description cannnot be blank';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure Warehouse is sent
         If pWhse = *zeros;
           pMessage = 'Warehouse cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Check Status
         If pStatus = *blanks;
           pMessage = 'Status must be Active/Inactive';
           error = *on;
           leavesr;
         EndIf;

         // Check to see if number of employees is not zero
         if pEmpl = 0 and pStatus = 'A';
           pMessage = 'You must enter at least 1 employee';
           error = *on;
           leavesr;
         EndIf;

         // Check to see that labor rate was entered
         If pStatus = 'A' and
            ((pLabr = 0) or (pLabr > 250.000));
            pMessage = 'Valid labor rate: Greater than 0/250.00 max';
            error = *on;
            leavesr;
         endif;

         // Check that Hours per day was entered
         If pStatus ='A' and
            ((pHour < .25) or (pHour > 12.00));
                pMessage = 'Valid labor hours: .25 min/12.00 max';
                error = *on;
                leavesr;
          endif;

         // Check Benefit rate
             If pStatus ='A' and
                ((pBnft < .0001) or (pBnft > 99.9999));
                pMessage = 'Valid Benefit Rate: .0001 min/99.9999 max';
                error = *on;
                leavesr;
             endif;

         // Check Overhead Rate
             If pStatus ='A' and
              ((pOvrh < .0001) or (pOvrh > 99.9999));
                pMessage = 'Valid Overhead Rate: .0001 min/99.9999 max';
                error = *on;
                leavesr;
             endif;

         // Check Days if record is active
             If pStatus = 'A' and
                pMon = 'N' and
                pTue = 'N' and
                pWed = 'N' and
                pThu = 'N' and
                pFri = 'N' and
                pSat = 'N' and
                pSun = 'N';
                pMessage = 'At least one day must be selected';
                error = *on;
                leavesr;
             EndIf;

          // get PLABCSTLNE record again
          exsr getRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         DaysofWk = pSun + pMon + pTue + pWed + pThu + pFri + pSat;
         LCDESC  = pDesc;
         LCEMPC  = pEmpl;
         LCSRTE  = pLabr;
         LCHRDY  = pHour;
         LCDYWK  = DaysofWk;
         LCBENRT = pBnft;
         LCOHPCT = pOvrh;
         LCSTAT  = pStatus;
         GetCurrStamp();
         LCLOCTS = CurrStamploc;
         LCSYSTS = CurrStampsys;
         LCUTCTS = CurrStampuc;
         LCJOB   = #Pgm;
         LCUSER  = pUser;
         LCJOBN  = #jobn;
         LCCNTR  = pCcntr;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  ChkChg   Check to see if copied record should be added to file
     *----------------------------------------------------------------

      /free
       begsr ChkChg;
         DaysofWk = pSun + pMon + pTue + pWed + pThu + pFri + pSat;

            If LCDYWK  = DaysofWk and
               LCDESC  = pDesc and
               LCSRTE  = pLabr and
               LCHRDY  = pHour and
               LCBENRT = pBnft and
               LCOHPCT = pOvrh;
               pMessage = 'This line description is currently active';
               error = *on;
               leavesr;
            Else;
               Eval pNxtSq = (pNxtSq + .1);
            EndIf;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  AddLogRec  Add log record to PLABCSTLOG file
     *----------------------------------------------------------------

      /free
       begsr AddLogRec;

         Select;

         When pAction = 'A' or
              pAction = 'C';
            LCLTYPE = 'Add';
         When pAction = 'U';
            LCLTYPE = 'Update';
         When pAction = 'D';
            LCLTYPE = 'Delete';
         Other;
         EndSL;

         LCLWHSE  = LCWHSE;
         LCLLINE  = LCLINE;
         LCLSEQ   = LCSEQ;
         LCLDESC  = LCDESC;
         LCLEMPC  = LCEMPC;
         LCLSRTE  = LCSRTE;
         LCLHRDY  = LCHRDY;
         LCLDYWK  = LCDYWK;
         LCLBENRT = LCBENRT;
         LCLOHPCT = LCOHPCT;
         LCLSTAT  = LCSTAT;
         LCLSYSTS = LCSYSTS;
         LCLLOCTS = LCLOCTS;
         LCLUTCTS = LCUTCTS;
         LCLJOB   = LCJOB;
         LCLUSER  = LCUSER;
         LCLJOBN  = LCJOBN;
         LCLCNTR  = LCCNTR;

         exec sql insert into plabcstlog values(:lclrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record in PLABCSTLOG : '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'pSeqNo(' + %char(pSeqNo) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;
         exsr GetRec;

         // Validate input

         if pAction <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         else;
            // put in code to prevent deletes if situation determined
         endif;


         select;

           // Add

           when pAction = 'A';
             if found;
               pMessage = 'Labor Cost Line exists';
               error = *on;
               leavesr;
             else;
               LCWHSE  = pWhse;
               LCLINE  = $LcLine;
               LCSEQ   = pNxtSq;
               exsr AddRec;
             endif;

           // Copy
           when pAction = 'C';
             If Found;
                exsr chkchg;
                 if error;
                   leavesr;
                 Else;
                   LCSEQ   = pNxtSq;
                   exsr AddRec;
                 endif;
             Else;
                LCWHSE  = pWhse;
                LCLINE  = $LcLine;
                LCSEQ   = pNxtSq;
                exsr AddRec;
             endif;

           // Update
           when pAction = 'U';
             if found;
               exsr UpdRec;
             endif;

           // Delete

           when pAction = 'D';
             if found;
               exsr DelRec;
             endif;

           other;
             pMessage = 'Invalid command sent: ' + pAction
                      + %trim(pAction)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :lcrec
                  from plabcstlne
                  where lcwhse = :pwhse
                    and lcline = :$LcLine
                    and lcseq  = :pSeqNo;

         if sqlstt = sqlSuccess;
           found = *on;
           eval pNxtSq = lcseq;
         else;
          exec sql select max(lcseq) into :pNxtSq
                   from plabcstlne
                   where lcwhse = :pwhse
                         and lcline = :$LcLine;
                If sqlstt <> sqlSuccess;
                    If $LcLine = '*ALL';
                      Eval pNxtSq = 5000;
                    Else;
                      Eval pNxtSq = 1;
                    EndIf;

                else;
                  Eval pNxtSq = (pNxtSq + 1);
                EndIf;
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
640jA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

