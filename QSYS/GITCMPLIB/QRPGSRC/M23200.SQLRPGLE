      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M23200  Production Primal/SubPRimal Alternate RM
     *  18 Jan 2017
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    01/18/17  KDE  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     FItemprd   if   e           k disk
     fpiritem   if   e           k disk
     fpPrimal   if   e           k disk
     fpbom      if   e           k disk
     fpBomSub   uf a e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D iurec         E ds                  extname(itemPrdPsa) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pAction        s              1
     D  pWhse          s              3  0
	    d  pprim          s             20
	    d  pSubPrim       s             20
	    d  pFGitm         s             15
	    d  pRmITm         s             15
	    d  pAmITm         s             15

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100
     d addseq          s              4  0
     d hldmorp         s              1
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
	    c                   parm                    pprim
	    c                   parm                    psubPrim
	    c                   parm                    pFgItm
	    c                   parm                    pRmItm
	    c                   parm                    pAmItm

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

         exec sql insert into ItemprdPsa values(:iurec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'PPrim(' + %trim(pPrim) + ') '
                    + 'PsubPrim(' + %trim(pSubPrim) + ') '
                    + 'FgItem(' + %Trim(pFgItm) + ') '
                    + 'RmItem(' + %Trim(pRmItm) + ') '
                    + 'AmItem(' + %Trim(pAmItm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // on success adding Primal/SubPrimal alternate
            // add record to pBomSub
            exsr updpBomSub;
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

         exec sql delete from ItemPrdPsa
                  where iuwhse = :pwhse
                    and iuItem = :pFgItm
                    and iuRmi = :pRmITm
                    and iuAmi = :pAmITm
                    and iupcde = :pPrim
                    and iuscde = :pSubPRim;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pPrim(' + %trim(pPrim) + ') '
                    + 'PSubPrim(' + %trim(pSubPrim) + ') '
                    + 'PFgItm(' + %trim(pFGitm) + ') '
                    + 'pRmItm(' + %trim(pRmItm) + ') '
                    + 'pAmItm(' + %trim(pAmItm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
            // when deleting alternate raw material for primal and
            // subprimal delete substitution if found
            exsr dltpBomSub;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  dltpBomSub  -  When deleting alternate raw materials for primal
     *                 and subprimal delete any substitution associated
     *----------------------------------------------------------------

      /free
       begsr dltpBomSub;

          // delete record for normal to alternate
          exec sql delete from pBomSub
                   where sbwhse=:pWhse and sbfgi=:pFgItm
                     and sbRmi=:pRmItm and sbAmi=:pAmitm;

          // delete reverse substitution record from alt to normal
          exec sql delete from pBomSub
                   where sbwhse=:pWhse and sbfgi=:pFgItm
                     and sbRmi=:pAmItm and sbAmi=:pRmitm;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ErrorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Ensure alternate item not same as primary raw material
         If pAMItm = pRMItm;
           pMessage = 'Substitue item cannot be the same '
                    + 'as Primary Raw material item';
           error = *on;
           leavesr;
         EndIf;

         // Check to ensure Warehouse is sent
         If pWhse = *zeros;
           pMessage = 'Warehouse cannot be empty';
           error = *on;
           leavesr;
         EndIf;

         // Check to Item Sent
         If pFgitm = *blanks;
           pMessage = 'Finished good item cannot be blank';
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

         // Check to ensure Alternate Raw Material is valid
         chain (pWhse:pAMitm) itemprd;
         If not %found(itemprd) or ipprdflg <> 'R';
           pMessage = 'Invalid Alternate Raw Material';
           error = *on;
           leavesr;
         EndIf;

         // ensure that alternate raw material includes a uom
         // that matches the uom used on the primal
         chain (pWhse:pFGitm) itemprd;  // get mfg line number
         if not %found(itemprd) or ipprdflg <>'F';
           pMessage = 'Finished Good is not setup as Production ' +
                      'Finished Good';
           error = *on;
           leavesr;
         else;
            chain (pWhse:ipmfgno:pprim) pPrimal;
            if not %found(pPrimal);
               pMessage = 'Primal not defined';
               error = *on;
               leavesr;
            else;
               chain (pWhse:pAMitm) itemprd;
               // I already know pAMitm exists from check above
               chain (pWhse:pAMitm) pirITem;
               if not %found(piritem) or (ppfacuom<>ippuom
                  and ppfacuom<>itum2 and ppfacuom<>itum3);
                  pMessage = 'No matching UOM between Primal ' +
                             'definition(' + %trim(ppfacuom) +
                             ') and alternate item(' +
                             %trim(pAMitm) + ')';
                  error = *on;
                  leavesr;
               endif;
            endif;
         endif;

         // make sure type matches between primary and alternate
         chain (pWhse:pAMitm) itemprd;
         hldmorp = ipmorp;
         chain (pWhse:pRMitm) itemprd;
         if hldmorp <> ipmorp;
            pMessage = 'Item type of either Meat or ' +
                       'Produce do not match between ' +
                       'Primary(' + %trim(pRMitm) + ') and ' +
                       'Alternate(' + %trim(pAMitm) + ')';
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

	        iuwhse = pwhse;
         iupcde = pPrim;
         iuscde = pSubPRim;
         iuitem = pFgitm;
         iurmi = pRmItm;
         iuami = pAmItm;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;

         // Validate input

         if pAction <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         else;
            // do not allow delete if active work orders exist
            // with this finished good and alternate raw material
            recCnt=0;
            exec sql select count(*) into :recCnt
                       from pWrkORdr
                     where wrwhse=:pWhse and wrfgi=:pFgItm
                       and writem=:pAmItm and wrstat<>'C'
                       and wrstat <>'D';
            if sqlstt = '00000' and recCnt<>0;
               pMessage = 'Alternate item and finished good item are' +
                          ' currently being used on active work order(s)';
               error = *on;
               leavesr;
            endif;
         endif;

         // See if PPrimal record exists for item

         exsr GetRec;

         select;

           // Add

           when pAction = 'A';
             if found;
               pMessage = 'Primal and SubPrimal already exist for this ' +
                          'Finished Good.  Click Back and modify existing';
               error = *on;
               leavesr;
             else;
               exsr AddRec;
             endif;

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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :iurec
                  from ItemPrdPsa
                  where iuwhse = :pwhse
                    and iupcde = :pPrim
                    and iuscde = :psubPrim
                    and iuitem = :pFgItm
                    and iurmi = :pRmitm
                    and iuami = :pAmitm;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updpBomSub  -  Add records to pBomSub when alternate items are
     *                 defined for a Primal/SubPrimal level
     *----------------------------------------------------------------

      /free
       begsr updpBomSub;

          // see if substitution item already exists
          chain (pWhse:pFgItm:pRmItm:pAmItm) pBomSub;

          if not %found(pBomSub);   // substitute not found
             // read BOM file and setup substitute item based on alternate
             setll (pWhse:pFgItm) pBom;
             reade (pWhse:pFgItm) pBom;

             dow not %eof(pBom);
                // get raw material being setup
                if bmRmi = pRmItm;
                   // generate normal raw material to alternate sub
                   sbwhse = bmwhse;
                   sbfgi = bmfgi;
                   sbrmi = bmrmi;
                   sbami = pamitm;
                   sbseq = bmseq;
                   sbqtyn = bmqtyn;
                   sbqty1 = bmqty1;
                   sbqty2 = bmqty2;
                   sbprdq = bmprdq;
                   sbscrf = bmscrf;
                   sbtype = bmtype;
                   sbbckf = bmbckf;
                   sbpquf = bmpquf;
                   sbeffd = bmeffd;
                   sbexpd = bmexpd;
                   sbwo# = *blanks;
                   write(e) sbrec;
                   if %error;
                   endif;
                   // generate alternate back to normal item sub
                   sbwhse = bmwhse;
                   sbfgi = bmfgi;
                   sbrmi = pamitm;
                   sbami = bmrmi;
                   sbseq = bmseq;
                   sbqtyn = bmqtyn;
                   sbqty1 = bmqty1;
                   sbqty2 = bmqty2;
                   sbprdq = bmprdq;
                   sbscrf = bmscrf;
                   sbtype = bmtype;
                   sbbckf = bmbckf;
                   sbpquf = bmpquf;
                   sbeffd = bmeffd;
                   sbexpd = bmexpd;
                   sbwo# = '*AUTO';
                   write(e) sbrec;
                   if %error;
                   endif;
                   leave;
                endif;
                reade (pWhse:pFgItm) pBom;
             enddo;
          endif;  // no pBomSub found

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         exec sql update itemprdpsa
                  set iuami = :pAmItm
                  where iuwhse = :pwhse
                    and iupcde = :pPrim
                    and iuscde = :psubPrim
                    and iurmi = :pRmitm
                    and iuitem = :pFgItm
                    and iuami = :pAmItm;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pPrim(' + %trim(pPrim) + ') '
                    + 'PSubPrim(' + %trim(pSubPrim) + ') '
                    + 'pFgItm(' + %trim(pFgItm) + ') '
                    + 'pRmitm(' + %trim(pRmitm) + ') '
                    + 'pAmitm(' + %trim(pAmitm) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free
