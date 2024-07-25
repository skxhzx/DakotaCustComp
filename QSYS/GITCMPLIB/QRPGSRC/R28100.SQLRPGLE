      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R28100     Build workfile for Inventory Adjustment Report - Item
     *
     *  19 January 2018
     *  Lynn McMahon
     *
     *  Revisions
     *
720 A*    01/19/18  LMC  7.20
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fworkadj   uf a e           k disk
     Fitemlnk1  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------
     D frdatestamp     s               z
     D todatestamp     s               z
     D w1fdatwork      s              6  0
     D w1tdatwork      s              6  0
     D w1f             s              6
     D w1t             s              6
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D iarec         E ds                  extname(itemadj) inz(*EXTDFT)


     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pDict          s             10
     d  pPgm           s             10
     d  pWhse          s              3p 0
     d  pItem          s             15

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------


     d AddRecs         pr
     d AddLinkRecs     pr
     d DeleteRecs      pr

     d WriteRec        pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pItem       Item
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pitem

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

         // Delete existing records for session id

         DeleteRecs();

         if pitem <> ' ';
           // Add records

           AddRecs();
           AddLinkRecs();

         endif;
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables


      /free

        SqlStmt = 'select *'
                + 'from itemadj '
                + 'where '
                +   ' and iaitem = ' +  sq + %trim(pitem) + sq;

        exec sql prepare invStmt from :SqlStmt;
        exec sql declare invCsr cursor for invStmt;
        exec sql open invCsr;

        dow forever = forever;

          exec sql fetch next from invCsr
                   into :iarec;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;
        iasess = pSessId;
        iabase = pitem;
        write iarecw;

        enddo;

        exec sql close invCsr;

      /end-free

     p AddRecs         e


     *----------------------------------------------------------------
     *  AddLinkRecs   Add Linked records
     *----------------------------------------------------------------

     p AddLinkRecs     b
     d AddLinkRecs     pi

     *  Local Variables


      /free

        // read itemlnk records
        setll (pwhse: pitem) itemlnk1;
        dow forever = forever;
          reade (pwhse: pitem) itemlnk1;
          if %eof(itemlnk1);
            leave;
          endif;

          SqlStmt = 'select *'
                  + 'from itemadj '
                  + 'where '
                  +   ' and iaitem = ' +  sq + %trim(ilitem) + sq;

          exec sql prepare invStmtw from :SqlStmt;
          exec sql declare invCsrw cursor for invStmtw;
          exec sql open invCsrw;

          dow forever = forever;

            exec sql fetch next from invCsrw
                     into :iarec;

            if sqlstt = sqlNoMoreData;
              leave;
            endif;
          iasess = pSessId;
          iabase = pitem;
          write iarecw;

          enddo;

          exec sql close invCsrw;
        enddo;

      /end-free

     p AddLinkRecs     e


     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from workadj
                 where iasess = :pSessId;

      /end-free

     p DeleteRecs      e

