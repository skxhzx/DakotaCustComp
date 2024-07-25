      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PMINMAX Production Min/Max/Lot Qty Maintenance
     *  27 November 2017
     *  Mike Rooker
     *
     *  Revisions:
     *
     *    11/27/17  MR   7.10a
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     F*classtype if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D*cltrec        E ds                  extname(ctrec) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             10
     D  pObjLoc        s             10
     D  pSubCmd        s             10
	    d  pWhse          s              3  0
	    d  pItem          s             15
	    d  pMin           s              5  0
	    d  pMax           s              5  0
	    d  pLot           s              5  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  wItem          s             15
     d logtext         s            100
     d wqty            s              5  0
     d wlot            s              5  0
     d rem             s              5  0

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
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      pItem       Item Code
     *      pMin        Minimum Qty
     *      pMax        Maximum Qty
     *      pLot        Lot Qty
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
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
	    c                   parm                    pWhse
	    c                   parm                    pItem
	    c                   parm                    pMin
	    c                   parm                    pMax
	    c                   parm                    pLot

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;
       if not error;

         exsr GetRec;

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;
       endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

       // Nothing entered
       if    pmin = 0
             and pmax = 0
             and plot = 0;
           pMessage = 'Invalid values entered';
           error = *on;
       endif;

       // Min and Max Qty cannot be zero
       if    pmin = 0
             and pmax = 0;
           pMessage = 'Minimum Qty and Maximum Qty must be greater than '+
                      'zero';
           error = *on;
       endif;

       // Min must be less than Max Qty
       if   pmin > pmax;
           pMessage = 'Minimum Qty must be less than Maximum Qty';
           error = *on;
       endif;

       // Max must be greater than Min Qty
       if   pmax < pmin;
           pMessage = 'Maximum Qty must be greater than Minimum Qty';
           error = *on;
       endif;

       // At least 1 multiple of Lot Qty
       wqty = (pmax - pmin);
       ///rem = %rem(wqty:pmin);
       wlot = %div(wqty:pmin);
       //if rem > 0;
       //   wlot -= 1;
       //endif;
       //if plot > wlot;
       if wlot < 1;
           pMessage = 'Lot Qty is not in the parameters of Min/Max qty';
           error = *on;
       endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

        exec sql select ipitem into :witem
                  from itemprd
                  where ipwhse = :pWhse
                    and ipitem = :pItem;

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

         //exsr FillRec;

         exec sql update itemprd
                  set ipminqt = :pmin,
                  ipmaxqt = :pmax,
                  iplotqt = :plot
                  where ipwhse = :pwhse
                  and ipItem = :pitem;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'pWhse(' + %char(pWhse)   + ') '
                    + 'pItem(' + %trim(pItem) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

         if pMessage = '';
           // pMessage = 'Min/Max Values updated successfully';
         endif;

       endsr;
      /end-free
