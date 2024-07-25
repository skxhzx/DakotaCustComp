      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPD700LMA   QD to renumber rows in TRUCKD
     *  12 August 2015
     *  Lynn McMahon
     *
700a *    08/12/15  LMC  7.00a
     *      - Created
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Ftruckd    if   e           k disk    prefix(a_) rename(tdrec:td1)
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D tdrec         E ds                  extname(truckd) inz(*EXTDFT)

     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     d forever         s               n
     D lastRow         s                   like(tdrow)
     D newRow          s                   like(a_tdrow)
     d savtruck        s                   like(a_tdtruk)
     D sq              c                   Const('''')
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        dow forever = forever;
          read truckd;
          if %eof(truckd);
            *inlr = *on;
            leave;
          endif;

          if a_tdtruk <> savtruck;
            exsr RenumberRows;
            savtruck = a_tdtruk;
            setgt (a_tdwhse: a_tdtruk) truckd;
          endif;
        enddo;
      /end-free
     *----------------------------------------------------------------
     *  RenumberRows   Renumber rows
     *----------------------------------------------------------------

     C     RenumberRows  begsr
      /free
         error = *off;

          SqlStmt = 'select * '
                  + 'from truckd '
                  + 'where tdwhse = ' + %char(a_tdwhse) + ' '
                 + 'and tdtruk=' + sq + %trimr(a_tdtruk) + sq
                  + 'order by tdwhse, tdtruk, tdrow, tdcol '
                  + 'for update of tdrow';

        exec sql prepare renumSel from :SqlStmt;
        exec sql declare renumCsr dynamic scroll cursor for renumSel;
        exec sql open renumCsr;

        newRow = 0;
        lastRow = 0;

        dow forever = forever;

          exec sql fetch next from renumCsr
                   into :tdrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if tdrow <> lastRow;
            newRow += 1;
            lastRow = tdrow;
          endif;

          exec sql update truckd set
                     tdrow = :newRow
                   where current of renumCsr;

        enddo;

        exec sql close renumCsr;

      /end-free
     C                   endsr

