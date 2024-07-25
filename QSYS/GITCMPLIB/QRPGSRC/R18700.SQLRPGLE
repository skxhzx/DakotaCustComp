      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R18700     Build workfile for Slots with no Selection
     *
     *  28 April 2016
     *  Lynn McMahon
     *
     *  Revisions
     *
700 A*    04/28/16  LMC  7.00
     *      - Created.
     *
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

     Fdlyhitswk uf a e           k disk

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
     *  Variables
     *----------------------------------------------------------------

     D htrec         E ds                  extname(dlyhits) inz(*EXTDFT)


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
     d  pFromDate      s             10
     d  pToDate        s             10

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------


     d AddRecs         pr
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
     *      pFromDate   From Date
     *      pToDate     To Date
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
     c                   parm                    pFromDate
     c                   parm                    pToDate

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

         // Delete existing records for session id

         DeleteRecs();

         // Add records

         AddRecs();

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
                + 'from dlyhits '
                + 'where '
                +   'htwhse = ' + %char(pWhse) + ' '
                +   'and htbegdte >= ' + pFromDate + ' '
                +   'and htbegdte <= ' + pToDate
                +   'order by htwhse, htbegdte ';

        exec sql prepare hitStmt from :SqlStmt;
        exec sql declare hitCsr cursor for hitStmt;
        exec sql open hitCsr;

        dow forever = forever;

          exec sql fetch next from hitCsr
                   into :htrec;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;
        smsessid = pSessId;
        write htrecwk;

        enddo;

        exec sql close rteCsr;

      /end-free

     p AddRecs         e


     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from dlyhitswk
                 where smsessid = :pSessId;

      /end-free

     p DeleteRecs      e

