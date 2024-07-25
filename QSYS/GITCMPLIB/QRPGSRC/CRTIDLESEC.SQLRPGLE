      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  CRTIDLESEC  Create Idle seconds
     *  18 May 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    06/15/10  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ptdrecidl     E ds                  extname(pirtrand) prefix(idl_)
     D ptdrecdir     E ds                  extname(pirtrand) prefix(dir_)

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

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  dsplyMsg       s             32
     D  gWhse          s              3  0
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d Look4Direct     pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse            15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        gWhse = pWhse;

        // Read status 3/4 IDLE records
        // that don't have a corresponding tran#

        SqlStmt = 'select * '
                + 'from pirtrand '
                + 'where ptdwhse = ' + %char(gWhse) + ' '
                +   'and ptdtask = ' + sq + 'IDLE' + sq + ' '
                +   'and ptdstat in (3,4) '
                +   'and ptdcortran = 0 '
                + 'for update of ptdcortran';

        exec sql prepare idlsel from :SqlStmt;
        exec sql declare idlcsr cursor for idlsel;
        exec sql open idlcsr;

        dow forever = forever;

          exec sql fetch next from idlcsr
                   into :ptdrecidl;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          look4Direct();

          exec sql update pirtrand
                   set ptdcortran = :dir_ptdtran
                   where current of idlcsr;

          if sqlstt <> sqlSuccess;
            //dsplyMsg = 'Err updating IDLE (' + %char(idl_ptdtran) + ')';
            //dsply dsplyMsg;
          endif;

        enddo;

        exec sql close idlcsr;

        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Look4Direct    Look for direct record that comes befoe Idle
     *----------------------------------------------------------------

     p Look4Direct     b
     d Look4Direct     pi

     D hours           s              5p 0

      /free

        exec sql select *  into :ptdrecdir
                 from pirtrand
                 where ptdwhse = :idl_ptdwhse
                   and ptdempnum = :idl_ptdempnum
                   and ptddiri = 1
                   and ptdstat in (3, 4)
                   and ptdeuc <= :idl_ptdsuc
                 order by ptdeuc desc,
                          ptdtran desc
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          dir_ptdtran = -1;
          return;
        endif;

        select;
          when dir_ptdsuc = noStamp;
            hours = 0;
          when idl_ptdsuc = noStamp;
            hours = 0;
          when dir_ptdsuc > idl_ptdsuc;
            hours = 0;
          other;
            monitor;
              hours = %diff(idl_ptdsuc: dir_ptdsuc: *HOURS);
            on-error;
              hours = 0;
            endmon;
        endsl;

        if hours >= 8;
          dir_ptdtran = -1;
          return;
        endif;

        dir_ptdidlesec += idl_ptdsec;

        exec sql update pirtrand
                 set ptdidlesec = :dir_ptdidlesec
                 where ptdwhse = :dir_ptdwhse
                   and ptdadduc = :dir_ptdadduc
                   and ptdtran = :dir_ptdtran;

        if sqlstt <> sqlSuccess;
          //dsplyMsg = 'Err updating DIR (' + %char(dir_ptdtran) + ')';
          //dsply dsplyMsg;
        endif;

        return;

      /end-free

     p Look4Direct     e
