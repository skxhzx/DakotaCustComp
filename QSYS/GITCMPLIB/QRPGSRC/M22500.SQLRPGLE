      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M22500  Production BOM Primal Association
     *  08 Dec 2016
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    12/08/16  KDE  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Recs
     *----------------------------------------------------------------
     FpBom      if   e           k disk
     FItemprd   if   e           k disk
     FpirItem   if   e           k disk
     FpPrimal   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D isrec         E ds                  extname(itemPrdPs) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pAction        s              1
     D  pWhse          s              3  0
	    d  pItem          s             15
	    d  pLine          s              3  0
	    d  pRmITm         s             15
	    d  pprim          s             20
	    d  pSubPrim       s             20
	    d  pSeq           s              5  0
	    d  pApplyAll      s              1
	    d  pPrimaryP      s              1

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d recCnt          s              7  0
650aAD logText         s            100
     d addseq          s              4  0

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
	    c                   parm                    pItem
	    c                   parm                    pLine
	    c                   parm                    pRmItm
	    c                   parm                    pprim
	    c                   parm                    psubPrim
	    c                   parm                    pSeq
	    c                   parm                    pApplyAll
	    c                   parm                    pPrimaryP

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

            // get highest used sequence to start adds with
            exec sql select isseq into :addseq
                     from itemprdps
                          where iswhse = :pwhse and isitem=:pItem
                            and isline = :pline and isrmi=:pRmItm
                            order by isseq desc
                            fetch first row only;
         select;
         when pApplyAll = 'N';
            isseq = addseq + 1;
            isprimary = pPrimaryp;
            exec sql insert into ItemprdPs values(:isrec);
         other;
            // if user requests same Primal/Subprimal be applied to all
            // of BOM we will loop and add record for each BOM entry
            // under BOM
            setll (pwhse:pItem) pbom;
            reade (pwhse:pItem) pbom;
            dow not %eof(pBom);
               exec sql update itemprdps set iswhse=:iswhse
                          where iswhse = :pwhse and isitem=:pItem
                            and isline = :pline and isrmi=:bmrmi
                            and isPcde=:pPrim and issCde=:pSubPRim;
               // if not found try to add
               if sqlStt <> sqlSuccess;
                  addseq = addseq + 1;
                  isseq = addseq;
                  isprimary = pPrimaryp;
                  isrmi = bmrmi;
                  exec sql insert into ItemprdPs values(:isrec);
               endif;
               reade (pwhse:pItem) pbom;
            enddo;
         endsl;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pItem(' + %trim(pItem) + ') '
                    + 'Line(' + %char(pLine) + ') '
                    + 'RmItem(' + %Trim(pRmItm) + ') '
                    + 'PPrim(' + %trim(pPrim) + ') '
                    + 'PsubPrim(' + %trim(pSubPrim) + ') '
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

         // delete BOM line

         exec sql delete from ItemPrdPs
                  where iswhse = :pwhse
                    and isItem = :pItem
                    and isline = :pLine
                    and ispcde = :pPrim
                    and isscde = :pSubPRim;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'PItem(' + %trim(pItem) + ') '
                    + 'Line(' + %char(pLine) + ') '
                    + 'pRmItm(' + %trim(pRmItm) + ') '
                    + 'pPrim(' + %trim(pPrim) + ') '
                    + 'PSubPrim(' + %trim(pSubPrim) + ') '
                    + 'pSeq(' + %char(pSeq) + ') '
                    + 'Table(' + %trim(%char(pLine)) + ') '
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

        if pAction <> 'D';

         // Check to ensure Warehouse is sent
         If pWhse = *zeros;
           pMessage = 'Warehouse cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Check to Item Sent
         If pItem = *blanks;
           pMessage = 'Item cannot be blank';
           error = *on;
           leavesr;
         EndIf;

         // Check to Table/Line is sent
         If pLine = *zeros;
           pMessage = 'Production Table/Line cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure Primal is sent
         If pPrim = *blanks;
           pMessage = 'Primal cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure SubPrimal is sent
         If pSubPrim = *blanks;
           pMessage = 'SubPrimal cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Ensure same Primal and SubPrimal combination is not being
         // repeated for same item
         if pAction = 'A' or pAction = 'C';
            recCnt=0;
            exec sql select count(*) into :recCnt
                       from ItemPrdps
                      where iswhse=:pwhse and isitem=:pitem
                        and isline=:pline and ispcde=:pPrim
                        and isscde=:pSubPrim
                        and isrmi <> :prmitm;
            if sqlStt = '00000 and recCnt<>0';
               // found record indicates duplicate combination.
               // send back error
              pMessage = 'Primal/SubPrimal combination already defined' +
                         ' for this item';
              error = *on;
              leavesr;
            endif;
         endif;

         // Ensure only one particular priority exist for given FG
         // and Line/Table and Raw Material.  This query looks for
         // a record that already matches the priority for given fg,
         // line, rm and not the passed in primal and subprimal.  If
         // one exist this means a separate primal/subprimal already
         // uses this priority and must use another priority.
         if pAction <> 'D';
            recCnt=0;
            exec sql update ItemPRdPs as a set iswhse=iswhse
                      where a.iswhse=:pwhse and a.isitem=:pitem
                        and a.isline=:pline
                        and a.isrmi=:pRmItm
                        and (select count(*) from ITEMPRDPS as b
                        where a.iswhse=b.iswhse and a.isitem=
                        b.isitem and a.isline=b.isline and
                        a.isrmi=b.isrmi and
                        b.ispcde<>:pprim and b.isscde<>:psubprim and
                        b.isseq=:pseq)=1;
            if sqlStt = '00000 and recCnt<>0';
               // found record indicates duplicate priority
              pMessage = 'Priority can only be defined once ' +
                         'per Finished Good. Please key another priority';
              error = *on;
              leavesr;
            endif;
         endif;

         // Ensure only one Primal/Subprimal have PRimary checked
         if pAction <> 'D' and pPrimaryP='Y';
            recCnt=0;
            exec sql select count(*) into :recCnt
                         from ItemPrdps
                      where iswhse=:pwhse and isitem=:pitem
                        and isline=:pline and ispcde=:pPrim
                        and isscde<>:psubprim
                        and isrmi=:prmItm and isprimary='Y';
            if sqlStt = '00000' and recCnt<>0;
               // found record indicates more than one primary checked
              pMessage = 'Only one Primal/SubPrimal def... can be '
                         + 'checked as Primary for same Finished Good'
                         + ' and Raw Material';
              error = *on;
              leavesr;
            endif;
         endif;

         // Ensure different priority exists for multiple option
         // Finished Good
         if pAction <> 'D' and pAction <> 'A';
            recCnt=0;
            exec sql select count(*) into :recCnt
                        from ItemPrdps
                      where iswhse=:pwhse and isitem=:pitem
                        and isline=:pline and ispcde=:pPrim
                        and isscde<>:psubprim and isseq=:pSeq
                        and isrmi=:prmItm;
            if sqlStt = '00000' and recCnt<>0;
               // found record indicates duplicate priority
              pMessage = 'Primal already using' +
                         ' this priority.  Please key another priority';
              error = *on;
              leavesr;
            endif;
         endif;

        endif;  // endif for pAction <>'D'

         // Ensure that Primal/SubPrimal combination is not on an Active
         // Work Order.  If currently on active order do not allow any
         // changes
         exec sql update pWrkORdps as a set pswhse=pswhse
                  where a.pspcde=:pprim and a.psscde=:pSubPrim and
                        a.psWhse=:pWhse and a.psRmi=:pRmItm and
                        a.psItem=:pItem and
                        (select count(*) from pwrkordr as b
                         where b.wrwhse=a.pswhse and b.wrwo#=a.pswo# and
                               a.psRmi=b.writem and a.psitem=b.wrfgi and
                               b.wrstat not in('C','D')) > 0;
         if sqlstt = '00000' and recCnt<>0;
            pMessage = 'Primal/SubPrimal cannot be changed/deleted '
                       + 'while on active Work Order(s)';
            error = *on;
            leavesr;
         endif;

         // if alternate raw materials exist in ITEMPRDPSA for this
         // finished good and primal return error that user must
         // clean up first
         recCnt=0;
         exec sql select count(*) into :recCnt
                    from ItemPrdPsa
                  where iuwhse=:pWhse and iuitem=:pItem
                    and iupcde=:pPrim and iuscde=:pSubPrim
                    and iuRmi=:pRmitm;

         if sqlstt ='00000' and recCnt<>0;
            pMessage = 'Please remove any active Alternate raw materials'
                       + ' under Primal Maintenance';
            error = *on;
            leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

	        iswhse = pwhse;
         isline = pLine;
         ispcde = pPrim;
         isscde = pSubPRim;
         isseq  = pSeq;
         if isseq = *zeros;
            isseq = 1;
         endif;
         isprimary = pPrimaryp;
         isitem = pItem;
         isrmi = pRmItm;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

         exsr errorcheck;
         if error;
           leavesr;
         endif;

         // See if PPrimal record exists for item

         exsr GetRec;

         select;

           // Add

           when pAction = 'A';
         //  if found;
         //    pMessage = 'Primal and SubPrimal already exist for this ' +
         //               'Finished Good.  Click Back and modify existing';
         //    error = *on;
         //    leavesr;
         //  else;
               exsr AddRec;
         //  endif;

           // Change

           when pAction = 'U' or pAction = 'C';
             if found;
               exsr UpdRec;
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

         // Ensure that Size UOM on Primal definition is defined
         // for selected Bill of Material Raw Material item
         chain (pWhse:pRmITm) Itemprd;
         if not %found(Itemprd);
            ippuom = *blanks;
         endif;
         chain (pWhse:pRmITm) pirItem;
         if not %found(pirITem);
            itum1 = *blanks;
            itum2 = *blanks;
            itum3 = *blanks;
         endif;
         chain (pWhse:pLine:pPrim) pPrimal;
         if not %found(pPrimal);
            ppfacuom = *blanks;
         endif;
         if ppfacuom = *blanks;
            pMessage = 'Primal code must have Size UOM defined. ' +
                       'This UOM is used to determine qty required';
            error = *on;
            leavesr;
         else;
            // if primal has size uom then make sure it matches one
            // of the uom's defined on the raw material
            if ppTypFac <> 9999.99    // override Primal/SubPRimal
               and ppfacuom <> itum1 and ppfacuom <> itum2 and
               ppfacuom <> itum3 and ppfacuom <> ippuom;
               pMessage = 'The raw material must have one unit of ' +
                          'measure defined that matches associated Primal';
               error = *on;
               leavesr;
            endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :isrec
                  from ItemPrdPs
                  where iswhse = :pwhse
                    and isline = :pLine
                    and isitem = :pItem
                    and isrmi = :pRmitm
                    and ispcde = :pPrim
                    and isscde = :psubPrim;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         exec sql update itemprdps
                  set isseq = :isseq, isprimary=:pPrimaryp
                  where iswhse = :pwhse
                    and ispcde = :pPrim
                    and isscde = :psubPrim
                    and isrmi = :pRmitm
                    and isitem = :pItem
                    and isline = :pLine;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pItem(' + %trim(pItem) + ') '
                    + 'Line(' + %char(pLine) + ') '
                    + 'pRmitm(' + %trim(pRmitm) + ') '
                    + 'pPrim(' + %trim(pPrim) + ') '
                    + 'PSubPrim(' + %trim(pSubPrim) + ') '
                    + 'pSeq(' + %trim(%char(pSeq)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free
