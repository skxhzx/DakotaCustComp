      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  UPDDEM110  Increment dates in pertinent demo files by 1 month.
     *  10 February 2014
     *  Retha Davis
     *
     *  Revisions
     *
650aA*    02/10/14  RBD  6.50a
     *      - Created (with alot of help from Dave).
     *
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
     *
750a *    02/18/21  RBD  7.50a
     *      - Added update of export date in POHDTL.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None

     *----------------------------------------------------------------
     *  Standard SQL variables and constants

      /copy qcopysrc,c#stdsql
     D sqlstmt2        s           2000a   inz(' ')

     *----------------------------------------------------------------
     *  Variables

     D sq              c                   Const('''')

     D forever         s               n   inz(*ON)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes

     d UpdCYMD         pr
     d  file                         10    const
     d  field                        10    const

     d UpdTS           pr
     d  file                         10    const
     d  field                        26    const

     d UpdYMD          pr
     d  file                         10    const
     d  field                        10    const

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line

      /free

         // Update YYMMDD dates

            updYMD('PIRTRAND': 'ptdshftday');
            updYMD('PIRTRAND': 'ptdshftsun');

            updYMD('POHDR': 'phdate');

            updYMD('POHHDR': 'phhdte');


         // Update CCYYMMDD dates

            updCYMD('DLYHITR': 'hrbegdte');
            updCYMD('DLYHITR': 'hrenddte');

            updCYMD('DLYHITS': 'htbegdte');
            updCYMD('DLYHITS': 'htenddte');

            updCYMD('LICACTIVE': 'laentd');
            updCYMD('LICACTIVE': 'laexpd');

            updCYMD('LICINFO': 'lnentdate');
            updCYMD('LICINFO': 'lnmfgdate');
            updCYMD('LICINFO': 'lnmfgexp');
            updCYMD('LICINFO': 'lnfifodate');
            updCYMD('LICINFO': 'lnexpdate');
            updCYMD('LICINFO': 'lnhrvdate');

            updCYMD('LICLOG': 'llentd');
            updCYMD('LICLOG': 'llexpd');

            updCYMD('PIRTRAN': 'ptgdte');
            updCYMD('PIRTRAN': 'ptsdte');
            updCYMD('PIRTRAN': 'ptedte');
            updCYMD('PIRTRAN': 'ptcdte');
            updCYMD('PIRTRAN': 'ptrdte');

            updCYMD('PIRTRAND': 'ptdgdte');

            updCYMD('PIRTRCK': 'trrcdt');

            updCYMD('POHDR': 'phudte');

            updCYMD('POHHDR': 'phhudt');
            updCYMD('POHHDR': 'phhedt');

750aA       updCYMD('POHDTL': 'phdedt');

            updCYMD('RTEHED': 'rhrptd');
            updCYMD('RTEHED': 'rhimpd');
            updCYMD('RTEHED': 'rhstsd');
            updCYMD('RTEHED': 'rhbldd');
            updCYMD('RTEHED': 'rhprtd');
            updCYMD('RTEHED': 'rhexpd');
            updCYMD('RTEHED': 'rhshpd');

            updCYMD('SLOT': 'slsdte');
            updCYMD('SLOT': 'slentd');
            updCYMD('SLOT': 'slexpd');
            updCYMD('SLOT': 'slslfd');


         // Update TS dates

            updTS('DLYHITR': 'hrstamp');

            updTS('DLYHITS': 'htstamp');

            updTS('HACCPLOG': 'hladdts');

            updTS('LICACTIVE': 'lachgts');
            updTS('LICACTIVE': 'lachguc');

            updTS('LICINFO': 'lnaddts');
            updTS('LICINFO': 'lnadduc');
            updTS('LICINFO': 'lnchgts');
            updTS('LICINFO': 'lnchguc');

            updTS('LICLOG': 'lladdts');
            updTS('LICLOG': 'lladduc');
            updTS('LICLOG': 'llexpts');
            updTS('LICLOG': 'llexpuc');

            updTS('PIRTRAND': 'ptdgts');
            updTS('PIRTRAND': 'ptdguc');
            updTS('PIRTRAND': 'ptdsts');
            updTS('PIRTRAND': 'ptdsuc');
            updTS('PIRTRAND': 'ptdets');
            updTS('PIRTRAND': 'ptdeuc');
            updTS('PIRTRAND': 'ptdcts');
            updTS('PIRTRAND': 'ptdcuc');
            updTS('PIRTRAND': 'ptdaddts');
            updTS('PIRTRAND': 'ptdadduc');
            updTS('PIRTRAND': 'ptdchgts');
            updTS('PIRTRAND': 'ptdchguc');

            *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  UpdCYMD   Update ccyymmdd dates

     p UpdCYMD         b
     d UpdCYMD         pi
     d  file                         10    const
     d  field                        10    const

     *  Local Variables

     D oldDate         s              8s 0
     D newDate         s               d

      /free

        // Grab records

        SqlStmt = 'select ' + %trim(field) + ' '
                + 'from ' + %trim(file) + ' '
                + 'where ' + %trim(field) + ' <> 0 '
                + 'for update of ' + %trim(field);

        exec sql prepare updcymdsel from :SqlStmt;
        exec sql declare updcymdcsr dynamic scroll cursor for updcymdsel;
        exec sql open updcymdcsr;

        dow forever = forever;

          exec sql fetch next from updcymdcsr
                   into :oldDate;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Increment month

          monitor;
            newDate = %date(oldDate) + %months(1);
          on-error;
            iter;
          endmon;

          if %trim(field) <> 'laexpd' and %trim(field) <> 'slexpd';
            if newDate > %date;
              iter;
            endif;
          endif;

          SqlStmt2 = 'update ' + %trim(file) + ' set '
                   + %trim(field) + '=' + %char(newDate:*iso0) + ' '
                   + 'where current of updcymdcsr';

          exec sql execute immediate :sqlstmt2;

          if sqlstt <> sqlSuccess;
          endif;

        enddo;

        exec sql close updcymdcsr;

        return;

      /end-free

     p UpdCYMD         e

     *----------------------------------------------------------------
     *  UpdTS   Update timestamp dates

     p UpdTS           b
     d UpdTS           pi
     d  file                         10    const
     d  field                        26    const

     *  Local Variables

     D oldDate         s               z
     D newDate         s             26

      /free

        // Grab records

        SqlStmt = 'select ' + %trim(field) + ' '
                + 'from ' + %trim(file) + ' '
                + 'where ' + %trim(field) + ' <> '
                + sq + '0001-01-01-00.00.00.000000' + sq
                + ' '
                + 'for update of ' + %trim(field);

        exec sql prepare updtssel from :SqlStmt;
        exec sql declare updtscsr dynamic scroll cursor for updtssel;
        exec sql open updtscsr;

        dow forever = forever;

          exec sql fetch next from updtscsr
                   into :oldDate;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Increment month

          monitor;
            oldDate = oldDate + %months(1);
          on-error;
            iter;
          endmon;

          if oldDate > %timestamp;
            iter;
          endif;

          monitor;
            newDate = %char(oldDate);
          on-error;
            iter;
          endmon;

          SqlStmt2 = 'update ' + %trim(file) + ' set '
                   + %trim(field) + '=' + sq + %trim(newDate) + sq + ' '
                   + 'where current of updtscsr';

          exec sql execute immediate :sqlstmt2;

          if sqlstt <> sqlSuccess;
          endif;

        enddo;

        exec sql close updtscsr;

        return;

      /end-free

     p UpdTS           e

     *----------------------------------------------------------------
     *  UpdYMD   Update yymmdd dates

     p UpdYMD          b
     d UpdYMD          pi
     d  file                         10    const
     d  field                        10    const

     *  Local Variables

     D oldDate         s              6s 0
     D newDate         s               d

      /free

        // Grab records

        SqlStmt = 'select ' + %trim(field) + ' '
                + 'from ' + %trim(file) + ' '
                + 'where ' + %trim(field) + ' <> 0 '
                + 'for update of ' + %trim(field);

        exec sql prepare updymdsel from :SqlStmt;
        exec sql declare updymdcsr dynamic scroll cursor for updymdsel;
        exec sql open updymdcsr;

        dow forever = forever;

          exec sql fetch next from updymdcsr
                   into :oldDate;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Increment month

          monitor;
            newDate = %date(oldDate:*ymd);
          on-error;
            iter;
          endmon;

          monitor;
            newDate = newDate + %months(1);
          on-error;
            iter;
          endmon;

          if newDate > %date;
            iter;
          endif;

          SqlStmt2 = 'update ' + %trim(file) + ' set '
                   + %trim(field) + '=' + %char(newDate:*ymd0) + ' '
                   + 'where current of updymdcsr';

          exec sql execute immediate :sqlstmt2;

          if sqlstt <> sqlSuccess;
          endif;

        enddo;

        exec sql close updymdcsr;

        return;

      /end-free

     p UpdYMD          e

