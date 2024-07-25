      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  CRTBLFFMT   Create Zebra stored format BLF from BLT formats
     *  23 June 2021
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    06/23/21  DAS  7.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lfdrec        E ds                  extname(lblfmtd) inz(*EXTDFT)
     D lorec         E ds                  extname(labelout) inz(*EXTDFT)

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

     D spaceLeft       s              5  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ChkExist        pr              n
     d  set                                like(lfdset) const
     d  fmt                                like(lfdfmt) const

     d WriteLABELOUT   pr
     d  set                                like(lfdset) const
     d  fmt                                like(lfdfmt) const

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        CrtBLF();

        return;

      /end-free

     *----------------------------------------------------------------
     *  CrtBLF       Create BLF format
     *----------------------------------------------------------------

     p CrtBLF          b
     d CrtBLF          pi

     d  i              s              5  0
     d  fdPos          s              5  0
     d  fsPos          s              5  0
     d  fdfsLen        s              5  0
     d  xPos           s              5  0
     d  varStart       s              5  0
     d  varLen         s              5  0
     d  numStart       s              5  0
     d  numLen         s              5  0
     d  fldnum         s              5  0
     d  fnStr          s             10    varying
     d  lastStr        s           1000    varying
     d  lastSet        s                   like(lfdset)
     d  lastFmt        s                   like(lfdfmt)
     d  first          s               n
     d  blfExists      s               n
     d  bliExists      s               n
     d  initFlag       s               n
     d  labelFlag      s               n

      /free

        // Define SQL statement to select requested labels to print

        SqlStmt =
          'select lfdset, lfdfmt, lfdseq, lfdstr '
        + 'from LBLFMTD '
        + 'where lfdset like ' + sq + 'BLTCB3' + sq + ' '
        +   'and lfdfmt like ' + sq + 'PICK%' + sq + ' '
        + 'order by lfdset, lfdfmt, lfdseq';

        exec sql prepare bltstmt from :SqlStmt;
        exec sql declare bltcsr cursor for bltstmt;
        exec sql open bltcsr;

        // Read LBLFMTD records

        first = *on;
        lastSet = '';
        lastFmt = '';
        lastStr = '';

        dow forever = forever;

          exec sql fetch next from bltcsr
                   into :lfdset, :lfdfmt, :lfdseq, :lfdstr;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // When Set changes see if Init and Stored Format exists

          if lfdset <> lastSet;
            if lastSet <> '';
              if not blfExists;
                looutput += lastStr;
                WriteLABELOUT('BLF' + %subst(lastSet: 4: 3): lastFmt);
              endif;
            endif;
            bliExists = ChkExist('BLI' + %subst(lfdset: 4: 3): '');
            lastSet = lfdset;
            lastFmt = '';
          endif;

          // When Format changes, reset flags

          if lfdfmt <> lastfmt;
            if lastFmt <> '';
              if not blfExists;
                looutput += lastStr;
                WriteLABELOUT('BLF' + %subst(lfdset: 4: 3): lastFmt);
              endif;
            endif;
            blfExists = ChkExist('BLF' + %subst(lfdset: 4: 3): lfdfmt);
            initFlag = *on;
            labelFlag = *off;
            lastfmt = lfdfmt;
          endif;

          // See if we have moved from init recs to the label recs
          // If so, write BLI to LABELOUT if necessary

          if %subst(lfdstr: 1: 3) = '^PR';
            if not bliExists and first;
              if lastStr <> '^XA';
                looutput += lastStr;
              endif;
              lastStr = '';
              WriteLABELOUT('BLI' + %subst(lfdset: 4: 3): '');
              first = *off;
            endif;
            looutput = '^XA^DF' + %trim(lfdfmt) + '^FS';
            initFlag = *off;
            labelFlag = *on;
          endif;

          // Add last string to output

          looutput += lastStr;

          // Save ZPL string. We will write it after-the-fact

          lastStr = %trim(lfdstr);

          // Nothing else to do for an init rec

          if initFlag;
            iter;
          endif;

          // Nothing else to do if BLF already exists

          if blfExists;
            iter;
          endif;

          // Look for Dakota variable and replace with Zebra variable

          fdPos = %scan('^FD<': lfdstr);
          if fdPos > 0;
            fsPos = %scan('>^FS': lfdstr: fdPos);
            if fsPos > 0;

              // Calculate total length, including zebra commands

	       fdfsLen = fsPos - fdPos + 4;

              // Calculate variable length without zebra commands

              varStart = fdPos+3;
              varLen = fsPos-3;

              // Calcalculate variable number length

              numStart = fdPos + 4;

              xPos = %scan('X': lfdstr: fdPos);
              if xpos = 0;
  	           numLen = fsPos - numStart;
	       else;
                numlen = xPos - numStart;
              endif;

              // Extract variable number
              // If zero, set to 1000

	       if numLen <= 0;
	         fldNum = 1000;
	       else;
	         monitor;
	           fldNum = %dec(%subst(lfdstr: numStart: numLen): 3: 0);
	         on-error;
	           fldNum = 0;
	         endmon;
	       endif;

              // Replace Dakota variable with Zebra variable

              if fldNum > 0;
                fnStr = '^FN' + %char(fldNum) + '^FS';
                lastStr = %trim(%replace(fnStr: lfdstr: fdPos: fdfsLen));
              endif;

            endif;
          endif;

        enddo;

        if not blfExists;
          looutput += lastStr;
          WriteLABELOUT('BLF' + %subst(lastSet: 4: 3): lastFmt);
        endif;

        exec sql close bltcsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkBLF      Check for existing BLF recs
     *----------------------------------------------------------------

     p ChkExist        b
     d ChkExist        pi              n
     d  set                                like(lfdset) const
     d  fmt                                like(lfdfmt) const

      /free

        exec sql select lowhse into :lowhse
                 from LABELOUT
                 where lowhse = 0
                   and loset = :set
                   and lofmt = :fmt
                 fetch first 1 rows only;

        if sqlstt = sqlSuccess;
          return *on;
        else;
          return *off;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteLABELOUT   Write LABELOUT record
     *----------------------------------------------------------------

     p WriteLABELOUT   b
     d WriteLABELOUT   pi
     d  set                                like(lfdset) const
     d  fmt                                like(lfdfmt) const

      /free

          looutlen = %len(looutput);

          exec sql
            insert into
            labelout (lowhse, loset, lofmt,
                         LOADDTS, LOADDUSER,
                         LOADDJOB, LOADDJOBU, LOADDJOBN,
                         looutlen, looutput)
           values   (0, :set, :fmt,
                     CURRENT TIMESTAMP,
                     :#curruser, :#jobnbr, :#user, :#job,
                     :looutlen, :looutput );

          if sqlstt <> sqlSuccess;
          endif;

          looutput = '';

      /end-free

     p                 e

