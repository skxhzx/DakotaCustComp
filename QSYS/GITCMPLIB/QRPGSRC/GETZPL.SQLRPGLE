      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  GETZPL     Get ZPL code from label out file
     *  13 May 2021
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    05/13/21  DAS  7.50
     *      - Created.
     *
750aA*    06/01/21  DAS  7.50a
     *      - Added maximum return length
     *
750bA*    09/25/21  DAS  7.50b
     *      - Revised to try and create init records if they don't
     *        exist.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lorec         E ds                  extname(labelout) inz(*EXTDFT)
     D psrec         E ds                  extname(pltsum) inz(*EXTDFT)
     D threc         E ds                  extname(truckh) inz(*EXTDFT)

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
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
530aD ***opzdta          ds
530aMD opdta2          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
720bAD  opbatid              100    111
     D  optend               117    117

     *----------------------------------------------------------------
530aA*  *PICKLBA -  Label printing options for the standard pick,
530aA*              retail, and tote labels.
     *
530aA*     08/12/09  RBD  5.20  P#00219
530aA*       - Added record type *PICKLBA which holds printing info
530aA*         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opdta3          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117

     *----------------------------------------------------------------
     *  External program prototypes
     *----------------------------------------------------------------

     d ZPLCRTSF        pr                  extpgm('ZPLCRTSF')
     d  setId                         3    const

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetLabel        pr

     d GetLabelDta     pr

     d GetFormat       pr

     d GetBLTTEST      pr

     d ChkTran         pr

     d CrtTran         pr

     d CrtBLTTEST      pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *
     *      pCmd           *OPEN      - Start and return
     *                     *SHUTDOWN  - Turn on *INLR and get out
     *                     *GETTEST1  - Get TEST1 label
     *                     *GETTEST2  - Get TEST2 label
     *                     *GETLABEL  - Get Labels for sent seq's
750bA*                     *GETLABELR - Get Labels for sent seq's - Reprint
750bA*                     *GETFMT    - Get Trn format labels (e.g., PALLET)
750bA*                     *GETFMTR   - Get Trn format labels (e.g., PALLET) - Reprint
     *                     *CHKTRAN   - Check for transaction labels
     *                     *CRTTRAN   - Create labels for transaction
     *                     *GETINIT   - Get Init (BLI) and Stored Formats (BLF) recs
     *      pWhse          Warehouse
     *      pRtid          Route id
     *      pTrn           Transaction number
     *      pLbl           Label number
     *      pFmt           Label format (used with *GETFMT)
     *                     Contains Set for *GETINIT
     *      pFromSeq       From label seq
     *      pToSeq         To label seq
750aA*      pMaxRtnLen     Maximum return length for *GETLABEL
     *
     *    Returned Parameters
     *
     *      pRtnCode       *OK / *ERROR
     *      pRtnMsg
     *      pZPLString     ZPL string
     *
     *----------------------------------------------------------------

     d GETZPL          pr                  extpgm('GETZPL')
     d  pCmd                         10    const
     d  pWhse                         3  0 const
     d  pRtid                         5    const
     d  pTrn                          7  0 const
     d  pLbl                          7  0 const
750bAd  pFmt                          8    const
     d  pFromSeq                      3  0
     d  pToSeq                        3  0
750aAd  pMaxRtnLen                    5  0
     d  pRtnCode                     10
     d  pRtnMsg                      99    varying options(*varsize)
     d  pZPLString                64512    varying options(*varsize)

     d GETZPL          pi
     d  pCmd                         10    const
     d  pWhse                         3  0 const
     d  pRtid                         5    const
     d  pTrn                          7  0 const
     d  pLbl                          7  0 const
750bAd  pFmt                          8    const
     d  pFromSeq                      3  0
     d  pToSeq                        3  0
750aAd  pMaxRtnLen                    5  0
     d  pRtnCode                     10
     d  pRtnMsg                      99    varying options(*varsize)
     d  pZPLString                64512    varying options(*varsize)

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        // Initialize return parms

        pRtnCode = '*OK';
        pRtnMsg = '';
        pZPLString = '';

        // Keep track of how much space is left in return string

750aA   if pMaxRtnLen > 0;
750aA     spaceLeft = pMaxRtnlen;
750aA   else;
          spaceLeft = %size(pZPLString) - 2;
750aA   endif;

        // Perform command

        select;

          when pCmd = '*OPEN';

          when pCmd = '*SHUTDOWN';
            *inlr = *on;

          when pCmd = '*GETINIT';
            GetINIT();

          when pCmd = '*GETBLTTST';
            GetBLTTEST();

750bM     when pCmd = '*GETLABEL' or pCmd = '*GETLABELR';
            // If 'DATA' sent we know that some label formats are stored
            // in printer. Therefore, look for BLD recs instead of BLT recs.
            if pFmt = 'DATA';
              GetLabelDta();
            endif;
            // If we didn't get any BLD recs, then get the BLT recs.
            if %len(pZPLString) = 0;
              GetLabel();
            endif;

750bM     when pCmd = '*GETFMT' or pCmd = '*GETFMTR';
750bM       GetFormat();

          when pCmd = '*CHKTRAN';
            ChkTran();

          when pCmd = '*CRTTRAN';
            CrtTran();

        endsl;

        return;

      /end-free

     *----------------------------------------------------------------
     *  GetLabel     Get ZPL for labels
     *----------------------------------------------------------------

     p GetLabel        b
     d GetLabel        pi

     d  i              s              5  0
     d  reprintPos     s              5  0

      /free

        // Define SQL statement to select requested labels to print

        SqlStmt =
          'select lowhse, lortid, lolbl, lolblcnt, lopart, looutput '
        + 'from LABELOUT '
        + 'where lowhse = ' + %char(pWhse) + ' '
        +   'and lortid = ' + sq + %trim(prtid) + sq + ' '
        +   'and lolbl = ' + %char(plbl) + ' '
        +   'and lolblcnt >= ' + %char(pFromSeq) + ' '
        +   'and lolblcnt <= ' + %char(pToSeq) + ' '
        +   'and loset like ' + sq + 'BLT%' + sq + ' '
        + 'order by lowhse, lortid, lolbl, lolblcnt, lopart';

        exec sql prepare lblstmt from :SqlStmt;
        exec sql declare lblcsr cursor for lblstmt;
        exec sql open lblcsr;

        // Read LABELOUT records

        dow forever = forever;

          exec sql fetch next from lblcsr
                   into :lowhse, : lortid, :lolbl, :lolblcnt, :lopart,:looutput;

          // Catch error

          if sqlstt <> sqlSuccess and sqlstt <> sqlNoMoreData;
            pRtnCode = '*ERROR';
            pRtnMsg = 'Error getting print recs for '
                    + 'Label ' + %char(pLbl) + ', '
                    + 'From ' + %char(pFromSeq)
                    + 'To ' + %char(pToSeq) + ', '
                    + 'Code ' + sqlstt;
            leave;
          endif;

          // See if we didn't find any records

          if sqlstt = sqlNoMoreData and %len(pZPLString) = 0;
            pRtnCode = '*NORECS';
            pRtnMsg = 'No print recs for '
                    + 'Label ' + %char(pLbl) + ', '
                    + 'From ' + %char(pFromSeq)
                    + 'To ' + %char(pToSeq);
            leave;
          endif;

          // Get out if we didn't read a record

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Look for Reprint variable and replace accordingly

          reprintPos = %scan('<71>': looutput);
          if reprintPos > 0;
            if pCmd = '*GETLABELR';
              looutput = %replace('R': looutput: reprintPos: 4);
            else;
              looutput = %replace(' ': looutput: reprintPos: 4);
            endif;
          endif;

          // If not enough space left for record,
          // Send back what we have with *MORE
          // and change From Seq to rec seq we just read.
          // Calling program should call again for remainder.

          if %len(looutput) > spaceLeft;
            pRtnMsg = '*MORE';
            pFromSeq = lolblcnt;
            leave;
          endif;

          // Add record to return string

          pZplString += looutput;

          // Update space left

          spaceLeft -= %len(looutput);

          // If From/To are the same, we are done.

          if pFromSeq = pToSeq;
            leave;
          endif;

          // Otherwise, loop for net record

        enddo;

        exec sql close lblcsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetLabelDta    Get variable data for labels
     *----------------------------------------------------------------

     p GetLabelDta     b
     d GetLabelDta     pi

     d  i              s              5  0
     d  reprintPos     s              5  0

      /free

        // Define SQL statement to select requested labels to print

        SqlStmt =
          'select lowhse, lortid, lolbl, lolblcnt, lopart, looutput '
        + 'from LABELOUT '
        + 'where lowhse = ' + %char(pWhse) + ' '
        +   'and lortid = ' + sq + %trim(prtid) + sq + ' '
        +   'and lolbl = ' + %char(plbl) + ' '
        +   'and lolblcnt >= ' + %char(pFromSeq) + ' '
        +   'and lolblcnt <= ' + %char(pToSeq) + ' '
        +   'and loset like ' + sq + 'BLD%' + sq + ' '
        + 'order by lowhse, lortid, lolbl, lolblcnt, lopart';

        exec sql prepare dtastmt from :SqlStmt;
        exec sql declare dtacsr cursor for dtastmt;
        exec sql open dtacsr;

        // Read LABELOUT records

        dow forever = forever;

          exec sql fetch next from dtacsr
                   into :lowhse, : lortid, :lolbl, :lolblcnt, :lopart,:looutput;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Look for Reprint variable and replace accordingly

          reprintPos = %scan('<71>': looutput);
          if reprintPos > 0;
            if pCmd = '*GETLABELR';
              looutput = %replace('R': looutput: reprintPos: 4);
            else;
              looutput = %replace(' ': looutput: reprintPos: 4);
            endif;
          endif;

          // If not enough space left for record,
          // Send back what we have with *MORE
          // and change From Seq to rec seq we just read.
          // Calling program should call again for remainder.

          if %len(looutput) > spaceLeft;
            pRtnMsg = '*MORE';
            pFromSeq = lolblcnt;
            leave;
          endif;

          // Add record to return string

          pZplString += looutput;

          // Update space left

          spaceLeft -= %len(looutput);

          // If From/To are the same, we are done.

          if pFromSeq = pToSeq;
            leave;
          endif;

          // Otherwise, loop for net record

        enddo;

        exec sql close dtacsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetFormat    Get ZPL for format for transaction (e.g., PALLET)
     *----------------------------------------------------------------

     p GetFormat       b
     d GetFormat       pi

     d  reprintPos     s              5  0

      /free

       // Grab for all lofmt = 'PALLET' recs for tran

        // Define SQL statement to select requested format

        SqlStmt =
          'select lowhse, lortid, lolbl, lolblcnt, lopart, looutput '
        + 'from LABELOUT '
        + 'where lowhse = ' + %char(pWhse) + ' '
        +   'and lortid = ' + sq + %trim(prtid) + sq + ' '
        +   'and lotrn = ' + %char(pTrn) + ' '
        +   'and lofmt = ' + sq + %trim(pFmt) + sq + ' '
        + 'order by lowhse, lortid, lolbl, lolblcnt, lopart';

        exec sql prepare fmtstmt from :SqlStmt;
        exec sql declare fmtcsr cursor for fmtstmt;
        exec sql open fmtcsr;

        // Read LABELOUT records

        dow forever = forever;

          exec sql fetch next from fmtcsr
                   into :lowhse, : lortid, :lolbl, :lolblcnt, :lopart,:looutput;

          // Catch error

          if sqlstt <> sqlSuccess and sqlstt <> sqlNoMoreData;
            pRtnCode = '*ERROR';
            pRtnMsg = 'Error getting print recs for '
                    + 'Fmt ' + %trim(pFmt) + ', '
                    + 'Code ' + sqlstt;
            leave;
          endif;

          // See if we didn't find any records

          if sqlstt = sqlNoMoreData and %len(pZPLString) = 0;
            pRtnCode = '*NORECS';
            pRtnMsg = 'No print recs for '
                    + 'Fmt ' + %trim(pFmt);
            leave;
          endif;

          // Get out if we didn't read a record

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Look for Reprint variable and replace accordingly

          reprintPos = %scan('<71>': looutput);
          if reprintPos > 0;
            if pCmd = '*GETFMTR';
              looutput = %replace('REPRINT': looutput: reprintPos: 4);
            else;
              looutput = %replace('FIRSTTIME': looutput: reprintPos: 4);
            endif;
          endif;

          // If not enough space left for record,
          // Send back what we have with *MORE
          // and change From Seq to rec seq we just read.
          // Calling program should call again for remainder.

          if %len(looutput) > spaceLeft;
            pRtnMsg = '*MORE';
            pFromSeq = lolblcnt;
            leave;
          endif;

          // Add record to return string

          pZplString += looutput;

          // Update space left

          spaceLeft -= %len(looutput);

          // Otherwise, loop for net record

        enddo;

        exec sql close fmtcsr;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetInit         Get Init (BLI) and Stored Formats (BLF)
     *----------------------------------------------------------------

     p GetInit         b
     d GetInit         pi

     d  bliSet         s                   like(lofmt)
     d  blfSet         s                   like(lofmt)

      /free

        bliSet = 'BLI' + %subst(pFmt: 4: 3);
        blfSet = 'BLF' + %subst(pFmt: 4: 3);

        // Define SQL statement to select requested labels to print
        // IMPORTANT! BLI needs to come before BLF

        SqlStmt =
          'select looutput '
        + 'from LABELOUT '
        + 'where lowhse = 0 '
        +   'and lortid = ' + sq + sq + ' '
        +   'and (loset = ' + sq + bliSet + sq + ' '
        +    'or loset = ' + sq + blfSet + sq + ') '
        + 'order by lowhse, lortid, loset desc';

750bA   // Set up to do a maximum of 2 passes
750bA   // If nothing is found on first pass,
750bA   //   Try creating init recs and do second pass.
750bA
750bA   for i = 1 to 2;
750bA
750bA     // If second time around, try creating init recs
750bA
750bA     if i = 2;
750bA       ZplCrtSF( %subst(pFmt: 4: 3));
750bA     endif;

          exec sql prepare intstmt from :SqlStmt;
          exec sql declare intcsr cursor for intstmt;
          exec sql open intcsr;

          // Read LABELOUT record

          dow forever = forever;

            exec sql fetch next from intcsr
                     into :looutput;

            if sqlstt <> sqlSuccess;
              leave;
            endif;

            // Add record to return string

            pZplString += looutput;

          enddo;

          exec sql close intcsr;

750bA     // If we found something, get out
750bA
750bA     if %len(pZplString) > 0;
750bA       leave;
750bA     endif;

750bA   endfor;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetBLTTEST      Get Belt Test label
     *----------------------------------------------------------------

     p GetBLTTEST      b
     d GetBLTTEST      pi

     d  fmt            s                   like(lofmt)
     d  first          s               n

      /free

        // Define SQL statement to select requested labels to print

        SqlStmt =
          'select lowhse, lortid, lolbl, lolblcnt, lopart, looutput '
        + 'from LABELOUT '
        + 'where lowhse = ' + %char(pWhse) + ' '
        +   'and lortid = ' + sq + sq + ' '
        +   'and lofmt = ' + sq + 'BLTTEST' + sq + ' '
        + 'order by lowhse, lortid, lolbl, lolblcnt, lopart';

        exec sql prepare tststmt from :SqlStmt;
        exec sql declare tstcsr cursor for tststmt;
        exec sql open tstcsr;

        // Read LABELOUT record

        first = *on;
        dow forever = forever;

          exec sql fetch next from tstcsr
                   into :lowhse, : lortid, :lolbl, :lolblcnt, :lopart,:looutput;

          // Catch error

          if sqlstt <> sqlSuccess and sqlstt <> sqlNoMoreData;
            pRtnCode = '*ERROR';
            pRtnMsg = 'Error ' + %trim(sqlstt) + ' getting print recs for '
                    + 'Test label';
            leave;
          endif;

          // See if we didn't find any records

          if sqlstt = sqlNoMoreData and %len(pZPLString) = 0;
            if first and pCmd = '*GETBLTTST';
              first = *off;
              CrtBLTTEST();
              exec sql close tstcsr;
              exec sql open tstcsr;
              iter;
            endif;
            pRtnCode = '*NORECS';
            pRtnMsg = 'No print recs for test label';
            leave;
          endif;

          // Add record to return string

          pZplString += looutput;

          // There should only be 1 record, so get out
          leave;

        enddo;

        exec sql close tstcsr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ChkTran      Check for transaction labels
     *----------------------------------------------------------------

     p ChkTran         b
     d ChkTran         pi

      /free

        exec sql select lowhse into :lowhse
                 from LABELOUT
                 where lowhse = :pWhse
                   and lortid = :prtid
                   and lotrn = :ptrn
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          pRtnCode = '*NORECS';
          pRtnMsg = 'No print recs for '
                  + 'transaction ' + %char(pTrn);
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtTran      Create labels for transaction
     *----------------------------------------------------------------

     p CrtTran         b
     d CrtTran         pi

     d  dta117         s            117

      /free

        // First make sure no labels exist for transaction

        ChkTran();
        if pRtnMsg = '';
          return;
        endif;

        pRtnCode = '*OK';
        pRtnMsg = '';

        dow forever = forever;

          // Get Route (PFMT assumes it will be sent in)

          exec sql select rhrte into :$prte
                   from RTEHED
                   where rhwhse = :pWhse
                    and rhrtid = :prtid
                   fetch first 1 rows only;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Get PLTSUM record in order to get truck
          // We are assuming if you are asking to create labels
          // the tran exists and it is a Selection tran

          exec sql select pscomp, pstzon, psgen, psszon, thztmp
                     into :pscomp, :pstzon, :psgen, :psszon, :thztmp
                   from PLTSUM
                   left outer join TRUCKH
                     on thwhse = pswhse and thtruk = pstruk
                   where pswhse = :pWhse
                    and pstrn# = :ptrn
                   fetch first 1 rows only;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Get Picking options

          exec sql select opzdta into :dta117
                   from OPTIONZ
                   where opzcod = '*PICKLBL'
                     and opzwhs = :pWhse
                     and opztrk = :thztmp
                     and opzzon = :psszon
                   fetch first 1 rows only;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          opdta2 = dta117;

          // Get Picking Label options

          exec sql select opzdta into :dta117
                   from OPTIONZ
                   where opzcod = '*PICKLBA'
                     and opzwhs = :pWhse
                     and opztrk = :thztmp
                     and opzzon = :psszon
                   fetch first 1 rows only;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          opdta3 = dta117;

          // Extract label set

          set = %subst(oplp1: 5: 6);

          // Create LABELOUT records

      /end-free
     C                   call      'PFMT'
     C                   parm      '*PRINT'      cmd               8
     C                   parm                    set               6
     C                   parm      ''            format            8
     C                   parm      pWhse         $pwhse            3 0
     C                   parm      pRtid         $prtid            5
     C                   parm      pscomp        $pcomp            1
     C                   parm      pstzon        $ptzon            6
     C                   parm      psgen         $pgen             1 0
     C                   parm      psszon        $pszon            6
     C                   parm      thztmp        $ptruk           10
     C                   parm                    $prte             5
     C                   parm                    opdta2
     C                   parm      0             $ptrn#            7 0
     C                   parm      0             $plbl#            7 0
     C                   parm      0             $pqty             5 0
     C                   parm      0             $pcwt             7 2
720aAC                   parm      'O'           $pOutType         1
750fAC                   parm                    $pRtnCode        10
750fAC                   parm                    $pRtnMsg         99
      /free

          leave;
        enddo;

        // See if there was an error creating records

        if $pRtnCode <> '';
          pRtnCode = $pRtnCode;
          pRtnMsg = 'No print recs - ' + %trim($pRtnMsg);
          return;
        endif;

        // Now check to see labels were created

        ChkTran();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtBLTTEST   Create BLTTEST label
     *----------------------------------------------------------------

     p CrtBLTTEST      b
     d CrtBLTTEST      pi

      /free
        // Get label set from LBLFMTD
        // This assumes there is only one defined BLTTEST label in the file

        exec sql
          select lfdset into :set
            from lblfmtd
           where lfdfmt = 'BLTTEST'
           fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          return;
        endif;
      /end-free

     C                   call      'PFMT'
     C                   parm      '*BLTTEST'    cmd               8
     C                   parm                    set               6
     C                   parm      ''            format            8
     C                   parm      pWhse         $pwhse            3 0
     C                   parm      pRtid         $prtid            5
     C                   parm      ''            $pcomp            1
     C                   parm      ''            $ptzon            6
     C                   parm      0             $pgen             1 0
     C                   parm      ''            $pszon            6
     C                   parm      ''            $ptruk           10
     C                   parm      ''            $prte             5
     C                   parm                    opdta2
     C                   parm      0             $ptrn#            7 0
     C                   parm      0             $plbl#            7 0
     C                   parm      0             $pqty             5 0
     C                   parm      0             $pcwt             7 2
720aAC                   parm      'O'           $pOutType         1
750fAC                   parm                    $pRtnCode        10
750fAC                   parm                    $pRtnMsg         99

     p                 e

