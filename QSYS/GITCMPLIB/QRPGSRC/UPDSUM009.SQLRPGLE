      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM009  Update SUM009 file
     *             Used by Real Time Inventory Variance Report
     *
     *  15 August 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    08/15/19  KDE  7.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum009    uf a e           k disk

     *----------------------------------------------------------------
     * SQL Record formats
     *----------------------------------------------------------------

     D rtclrec       E ds                  extname(rtchstl) inz(*EXTDFT)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

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

     d frmtnmCmd       s              8
     d inclIdle        s              1

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d holdwhdp        s                   like(rtclwhdp)
     d holdbase        s                   like(rtclbase)
     d holddisp        s                   like(rtcldisp)
     d holditem        s                   like(smitem)
     d groupStamp      s               z

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99    varying
     d  pSessId        s             40    varying
     d  pWhse          s              3p 0
     d  pUid           s              7p 0
     d  pSid           s              3p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
     d DeleteRecs      pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pErrMsg     Error Message
     *      pSessId     Session Id
     *      pWhse       Warehouse
     *      pUid        Count Id
     *      pSid        Count Short Id
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pUid
     c                   parm                    pSid

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add work records for Report Slots w/No Activity
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

     D wkITem          s             15

      /free

        SqlStmt = 'select * '
                + 'from rtchstl';
        sqlWheres = 'where '
                +   'rtclwhse=' + %char(pWhse) + ' and '
                +   'rtcluid=' + %char(puid);

        sqlStmt = %trim(sqlStmt) + ' ' + %trim(sqlWheres) +
                  ' order by rtclwhdp,rtclbase,rtcldisp,rtclwitm';

        exec sql prepare rptStmt from :SqlStmt;
        exec sql declare rptVar cursor for rptStmt;
        exec sql open rptVar;

        dow forever = forever;

          exec sql fetch next from rptVar
                   into :rtclrec;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

          smsessid = pSessid;
          smwhse=pwhse;
          smuid=puid;
          smsid=psid;
          smaddts = %timestamp();

          // Get Begin Inventory from first Log record,
          // sum remaining log records and calculate
          // difference for each quantity
          if rtclwhdp<>holdwhdp or rtclbase<>holdbase or
             rtcldisp<>holddisp or rtclwitm<>holditem;
             // first break will be first record.  In
             // this case we will just set everything
             // for next break
             if holdwhdp<>*blanks;
                smaqty1 = smbqty1 + smadj1;
                smaqty2 = smbqty2 + smadj2;
                smaqty3 = smbqty3 + smadj3;
                write smrec;
             endif;
             holdwhdp=rtclwhdp;
             holdbase=rtclbase;
             holddisp=rtcldisp;
             holditem=rtclwitm;
             smbqty1=rtclbqty1;
             smbqty2=rtclbqty2;
             smbqty3=rtclbqty3;
             smadj1=0;
             smadj2=0;
             smadj3=0;
             smcwgt=0;
          endif;

          smwhdp=rtclwhdp;
          smitem=rtclwitm;
          smbase=rtclbase;
          smdisp=rtcldisp;
          smpick=rtclpick;
          smaisl=rtclasl;
          smloc=rtclloc;
          smrlvl=rtcllvl;
          smhand=rtclhnd;
          smcadjc=rtcladj;
          smpage=rtclpage;
          smteam=rtcltmcod;
          smadj1=smadj1+rtcladj1;
          smadj2=smadj2+rtcladj2;
          smadj3=smadj3+rtcladj3;
          if rtcladj1<>0 or rtcladj2<>0 or rtcladj3<>0;
            // Only sum Catch Weight for adjustments.
            // This report is all about variances
            smcwgt=smcwgt+rtclwwgt;
          endif;

        enddo;

        // Write last Adjustment Record
        smaqty1 = smbqty1 + smadj1;
        smaqty2 = smbqty2 + smadj2;
        smaqty3 = smbqty3 + smadj3;
        write smrec;

        exec sql close rptVar;

      /end-free


     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum009
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 1440 MINUTES;

      /end-free

     p DeleteRecs      e
