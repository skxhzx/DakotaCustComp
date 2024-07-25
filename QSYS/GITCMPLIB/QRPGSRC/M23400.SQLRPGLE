      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M23400  Production Dry Age Assignment
     *  12 Feb 2017
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    02/12/17  KDE  7.10
     *      - Created.
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FProdlog   if   e           k disk    rename(plrec:plreci)
     f                                     prefix(i_)
     fpWrkORd   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D plrec         E ds                  extname(prodlog) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pAction        s              1
     D  pWhse          s              3  0
	    d  pWO            s             13
	    d  pRmUci         s             50

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     d addseq          s              4  0
     d hldflcns        s             15
     d hldtlcns        s             15
     d hlddisp         s             12
     d hldrmitm        s             15
     d hldprddte       s              8  0
     d hldweght        s              9  3
     d hldcustwo       s             20
     d recCnt          s              7  0

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

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
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pAction
     C                   parm                    pWhse
	    c                   parm                    pWO
	    c                   parm                    pRmUci

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
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

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

         exec sql insert into Prodlog values(:plrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'PWo(' + %Trim(pWO) + ') '
                    + 'PRmUci(' + %Trim(pRmUci) + ') '
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

         exec sql delete from Prodlog
                  where plwhse = :pwhse
                    and plbfcwo = :pWO
                    and plgs1 = :pRmUci
                    and plAction = 'AUC';

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pWO(' + %trim(pWO) + ') '
                    + 'pRmUci(' + %trim(pRmUci) + ') '
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

         // Ensure By-PRoduct and Primary are not same raw material
         If pWO = *blanks;
           pMessage = 'Work Order must be passed';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure Warehouse is sent
         If pWhse = *zeros;
           pMessage = 'Warehouse cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Ensure UCI is sent
         If pRmUci = *blanks;
           pMessage = 'UCI to assign must be keyed';
           error = *on;
           leavesr;
         EndIf;

         // If UCI already assign return error
         if found;
           pMessage = 'UCI already assigned to Work Order';
           error = *on;
           leavesr;
         EndIf;

         // if UCI not assigned, but not in this area throw error
         chain (pWhse:pWo) pWrkord;
         if not %found(pWrkord);
            pMessage = 'Work Order either invalid or closed';
            error = *on;
            leavesr;
         endif;

         // get raw material prodlog replenishment entry and save
         // values as well as checking that it is at line/table
         exec sql select * into :plrec
                  from PRodlog
                    where plwhse=:pWhse and plGS1=:pRmUci
                      and plAction='RPL' order by pldtetim desc
                      fetch first row only;
          if sqlStt = sqlSuccess;
             hldrmitm = plitem;
             hldflcns = plflcns;
             hldtlcns = pltlcns;
             hlddisp = pldisp;
             hldweght = plweght;
             hldcustwo = plcustwo;
             if womfgno <> plLine;
                pMessage = 'UCI not replenished to this line/table';
                error = *on;
                leavesr;
             endif;
          else;
               pMessage = 'UCI not replenished to this line/table';
               error = *on;
               leavesr;
          endif;

         // Make Sure we are not adding more UCIS than Work ORder
         // calls for.  If so return error and do not allow addition
         exec sql select * into :recCnt
                  from PRodlog
                    where plwhse=:pWhse and plGS1=:pRmUCi
                      and plAction='AUC';
          if sqlStt = sqlSuccess;
             // if current UCIS assigned plus one is more than Work ORder
             // prevent user from adding more before deleting something
             if (recCnt + 1) > woMake;
                pMessage = 'You are trying to assign more UCIS to this' +
                           'Work Order than Make Quantity';
                error = *on;
                leavesr;
             endif;
          endif;

          // get PRodlog record again for either Add, Update or Delete
          exsr getRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        plwhse = pwhse;
         plbfcWo = pWO;
         plGs1 = pRmUci;
         plitem = hldrmitm;
         plAction = 'AUC';
         plflcns = hldflcns;
         pltlcns = hldtlcns;
         plline = womfgno;
         pldisp = hlddisp;
         plqtyn = 1;
         plqty1 = 0;
         plqty2 = 0;
         plweght = hldweght;
         pltare=0;
         plpgm = #pgm;
         pluser = pUser;
         pljob = #job;
         pllsts = *blanks;
         plcts = %timestamp;
         pldtetim = %subst(%char(plcts):1:4) +
                    %subst(%char(plcts):6:2) +
                    %subst(%char(plcts):9:2) +
                    %subst(%char(plcts):12:2) +
                    %subst(%char(plcts):15:2) +
                    %subst(%char(plcts):18:2);
         plbfcwo = pwo;
         plcustwo = hldcustwo;
         pltrn# = 0;
         pllbl# = 0;
         plfgitm = woitem;
         plprddte = %uns(%char(%Date():*Iso0));

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
               pMessage = 'UCI already exists.';
               error = *on;
               leavesr;
             else;
               exsr AddRec;
             endif;

           // Change

           when pAction = 'U' or pAction = 'C';
             if found;
               pMessage = 'UCI already exists.';
               error = *on;
               leavesr;
             else;
               exsr AddRec;
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

         exec sql select * into :plrec
                  from Prodlog
                  where plwhse = :pwhse
                    and plgs1 = :pRmUci
                    and plAction = 'AUC';

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free
