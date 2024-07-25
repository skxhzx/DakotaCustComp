      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPD710LMA   QD to update ptdshiftday in pirtand where empno=0
     *  20 June 2017
     *  Lynn McMahon
     *
710a *    06/20/17  LMC  7.10a
     *      - Created
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ptdrec        E ds                  extname(pirtrand) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D  gCurrWhse      s              3  0
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3
     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d UpdShiftInfo    pr

     c     *entry        plist
     c                   parm                    pWhse
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        *inlr = *on;
        updShiftInfo();
      /end-free

     *----------------------------------------------------------------
     *  UpdShiftInfo   Update ptdshftday when emp = 0 and status = 4
     *----------------------------------------------------------------

     p UpdShiftInfo    b
     d UpdShiftInfo    pi

     *  Local Variables
     d closeDate       s               d
     d sundayDate      s               d

      /free

        gCurrWhse = %dec(pWhse:3:0);

        // Grab Closed records that don't have shift day date.

          SqlStmt = 'select * '
                  + 'from pirtrand '
                  + 'where ptdwhse = ' + %char(gCurrWhse) + ' '
                  +   'and ptdstat = (''4'') '
                  +   'and ptdempnum = 0 '
                  +   'and ptdshftday = 0 '
                  + 'order by ptdwhse, ptdempnum, ptdsts, ptdtran '
                  + 'for update of ptdshftday,ptdshftdow,ptdshftwk,ptdshftsun';

        exec sql prepare updshftsel from :SqlStmt;
        exec sql declare updshftcsr dynamic scroll cursor for updshftsel;
        exec sql open updshftcsr;

        dow forever = forever;

          exec sql fetch next from updshftcsr
                   into :ptdrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Initialize PIRTRAND record

          if ptdcts <> noStamp;
            closeDate = %date(ptdcts);
            ptdshftday = %dec(closeDate:*ymd);

            exec sql set :ptdshftWk = week(:closeDate),
                         :ptdshftdow = dayofweek(:closeDate);

            sundayDate = closeDate - %days(ptdshftdow-1);
            ptdshftsun = %dec(sundayDate:*ymd);

            exec sql update pirtrand set
                       ptdshftday = :ptdshftday,
                       ptdshftdow  = :ptdshftdow,
                       ptdshftwk = :ptdshftwk,
                       ptdshftsun = :ptdshftsun
                     where current of updshftcsr;

          endif;

        enddo;

        exec sql close updshftcsr;

        return;

      /end-free

     p UpdShiftInfo    e

