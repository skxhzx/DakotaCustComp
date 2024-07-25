      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  ZPLCRTSP    Create Zebra stored format from BLT set to BLF
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

     D gSet            s              6

     *----------------------------------------------------------------
     *  External program prototypes
     *----------------------------------------------------------------

     d ZPLCleanUp      pr                  extpgm('ZPLCLEANUP')
     d  setid                         3    const

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
     * Parameters
     *
     *    Input Parameters
     *
     *      pSetId         Last 3 characters of set name (e.g., CB3)
     *                     First 3 characters are hardcoded to BLT
     *
     *    Returned Parameters
     *
     *      none
     *
     *----------------------------------------------------------------

     d ZPLCRTSF        pr                  extpgm('ZPLCRTSF')
     d  pSetId                        3    const

     d ZPLCRTSF        pi
     d  pSetId                        3    const


     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Make sure set id passed in

        monitor;
          gSet = 'BLT' + pSetId;
        on-error;
          dsply 'ZPLCRTSF (iii), iii is 3 set id';
          return;
        endmon;

        // Make sure ZPL is cleaned up

        ZPLCleanUp(pSetId);

        // Create LABELOUT record for INIT format

        CrtBLI();

        // Create LABELOUT stored format rec for PICK* formats

        CrtBLF();

        return;

      /end-free

     *----------------------------------------------------------------
     *  ChkExist    Check for existing BLI/BLF recs
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
     *  CrtBLF       Create BLF stored format recs
     *----------------------------------------------------------------

     p CrtBLF          b
     d CrtBLF          pi

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

      /free

        // Define SQL statement to select PICK* labels

        SqlStmt =
          'select lfdset, lfdfmt, lfdseq, lfdstr '
        + 'from LBLFMTD '
        + 'where lfdset like ' + sq + gSet + sq + ' '
        +   'and lfdfmt like ' + sq + 'PICK%' + sq + ' '
        + 'order by lfdset, lfdfmt, lfdseq';

        exec sql prepare blfstmt from :SqlStmt;
        exec sql declare blfcsr cursor for blfstmt;
        exec sql open blfcsr;

        // Read LBLFMTD records

        first = *on;
        lastSet = '';
        lastFmt = '';
        lastStr = '';

        dow forever = forever;

          exec sql fetch next from blfcsr
                   into :lfdset, :lfdfmt, :lfdseq, :lfdstr;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // When Format changes, reset flags

          if lfdfmt <> lastfmt;
            if lastFmt <> '' and not blfExists;
              WriteLABELOUT('BLF' + pSetId: lastFmt);
            endif;
            looutput = '^XA^DF' + %trim(lfdfmt) + '.ZPL^FS';
            blfExists = ChkExist('BLF' + pSetId: lfdfmt);
            lastfmt = lfdfmt;
          endif;

          // Skip rec if stored format already exists for label format

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
                lfdstr = %trim(%replace(fnStr: lfdstr: fdPos: fdfsLen));
              endif;

            endif;
          endif;

          // Add string to output

          if lfdstr <> '^XA';
            looutput += %trim(lfdstr);
          endif;

        enddo;

        if not blfExists;
          WriteLABELOUT('BLF' + pSetId: lastFmt);
        endif;

        exec sql close blfcsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtBLI       Create INIT record
     *----------------------------------------------------------------

     p CrtBLI          b
     d CrtBLI          pi

     d  bliExists      s               n

      /free

        // Define SQL statement to select INIT label

        SqlStmt =
          'select lfdset, lfdfmt, lfdseq, lfdstr '
        + 'from LBLFMTD '
        + 'where lfdset like ' + sq + gSet + sq + ' '
        +   'and lfdfmt = ' + sq + 'INIT' + sq + ' '
        + 'order by lfdset, lfdfmt, lfdseq';

        exec sql prepare blistmt from :SqlStmt;
        exec sql declare blicsr cursor for blistmt;
        exec sql open blicsr;

        // Read LBLFMTD records

        bliExists = ChkExist('BLI' + pSetId: 'INIT');
        if bliExists;
          return;
        endif;

        looutput = '';

        dow forever = forever;

          exec sql fetch next from blicsr
                   into :lfdset, :lfdfmt, :lfdseq, :lfdstr;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          looutput += %trim(lfdstr);

        enddo;

        if %len(looutput) > 0;
          WriteLABELOUT('BLI' + pSetId: 'INIT');
        endif;

        exec sql close blicsr;

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

