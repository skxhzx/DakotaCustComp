      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LL755     cleanup LICLOG and LILCINFO move to history as needed
     *  19 January 2012    6.40
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *     - Remove records from LICLOG if not in licactive file
     *     - check for both the license and orginal license - both
     *       must be gone before removing the LICLOG record
     *     - check the date on the last record in liclog for the
     *       license, that will ensure we keep all data until the
     *       last log record for the license is old enough to remove.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    01/19/12  LMC   6.40
     *      - Created
640aA*    06/13/12  LMC   6.40a
     *      - Enh: If original license is blank, don't check the
     *        LICACTIVE license file
640bA*    06/14/12  LMC   6.40b
     *      - Enh: Added some additional logic to allow for better
     *        performance. Since we reuse deleted records, we are
     *        processing the current records first and since the
     *        program is set to only process for one hour, we are not
     *        getting far enough into the file to get some of the old
     *        data cleaned up. This change will cut down on the I/O
     *        being performed on the newest data.
640cA*    06/18/12  LMC   6.40c
     *      - Enh: Added some additional logic to deal with records
     *        with Blank LLLCNS and Blank LLOLCNS.
     *        Added the same kind of logic for *CC licenses.
640dA*    08/09/12  LMC   6.40d
     *      - Enh: Added logic for new POASN file.
740aA*    07/23/20  LMC   7.40a
     *      - Recompile only - poasn database change.
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flicactive if   e           k disk
     Flicactive6if   e           k disk    rename(larec:larec6)
     Flicinfo2  uf   e           k disk    usropn
     Flicinfoh  o  a e             disk    usropn
     Fliclog    uf   e           k disk    usropn
     Fliclogh   o  a e             disk    usropn
640dAFpoasn1    uf   e           k disk    usropn
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *****OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *****OPICW   -  Individual catch weight entry (Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optend               117    117
     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pRunall        s              1
     D $pRunCk5A       s              5
     D $pWhse          s              3p 0
     D $pWhse3A        s              3

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------

     D chkdays         s              4  0
     D chkwks          s              3  0
     D client          s             10
     D clientLoc       s             10
     D curdate         s               d
     D first           s               n
     D forever         s               n
     D history         s               n
     D RunCk           s              9  0
     D RunCount        s              9  0
     D TtlHrs          s              9  0
     D $cdttme         s               z
     D $dtetme         s               z
     D $ndttme         s               z
     D $sdttme         s               z

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pRunCk - Run Time check after this number of deleted liclog
     *      $pRunAll- BFC override to process all to end
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A
     c                   parm                    $pRunCk5A
     c                   parm                    $pRunall

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     c                   eval      runck  = %dec($prunck5A: 5: 0)

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Loop through LICLOG records to determine if records should be
     *  removed

      /free


       // Loop through records to determine clenaup.

         setll ($pwhse) liclog;
         dow forever = forever;
           reade(n) ($pwhse) liclog;
           if %eof(liclog);
             leave;
           endif;

640bA  // if the date of this record is beyound our cleanup date
640bA  // there is no reason to do any additional checking on this liclog
640bA  // this should reduce the I/O's required to determine if this license
640bA  // is even eligible to be cleaned up

640bA      if lladduc > $dtetme;
640bA        setgt (llwhse: lllcns) liclog;
640bA        iter;
640bA      endif;


640cA  // special circumstances - blank lllcns & blank llolcns will
640cA  // cleanup based on lladduc of that record only.

640cA  if lllcns = ' ' and llolcns = ' ' and lladduc < $dtetme;
640cA    exsr cleanliclogspec;
640cA    iter;
640cA  endif;

640cA  // special circumstances - *CC lllcns & *CC llolcns will
640cA  // cleanup based on lladduc of that record only.

640cA  if lllcns = '*CC' and llolcns = '*CC' and lladduc < $dtetme;
640cA    exsr cleanliclogspec;
640cA    iter;
640cA  endif;

       // check for active license

           chain (llWhse: lllcns) licactive;
           if %found(licactive);
             setgt (llwhse: lllcns) liclog;
             iter;
           endif;

       // check for active orginal license

640aA      if llolcns <> ' ';
             chain (llWhse: llolcns) licactive6;
             if %found(licactive6);
               setgt (llwhse: lllcns) liclog;
               iter;
             endif;
640aA      endif;

       // get the last record for the license to determine last date

           setgt (llwhse: lllcns) liclog;
           readpe(n) (llwhse: lllcns) liclog;
           if %eof(liclog);
             iter;
           endif;

       // check to see if date should be cleaned out of file
           if lladduc < $dtetme;
             exsr  cleanlicinfo;
640dA        exsr  cleanpoasn;
             exsr  cleanliclog;
           endif;

       // check to see if run time should be considered
       // If runcount exceeds runck and program has been running for an
       // hour let's stop processing, until next cleanup run
       // $prunall is an override which will allow BFC to run complete
       // This will allow an initial cleanup on client if BFC chooses

           if RunCount >= runck and $prunall = ' ';
             exsr zzzCalcRunTime;
             if ttlhrs >= 1;
               leave;
             else;
               RunCount = 0;
             endif;
           endif;

         enddo;
         if %open(liclog);
           close liclog;
         endif;
         if %open(licinfo2);
           close licinfo2;
         endif;
         if %open(liclogh);
           close liclogh;
         endif;
         if %open(licinfoh);
           close licinfoh;
         endif;
640dA    if %open(poasn1);
640dA      close poasn1;
640dA    endif;
         *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

         // get current date/time

         exsr zzzCalcRunTime;

         // Get client id

         getclient(client: clientLoc);

         // Get options

         exsr zzzGetoptions;

         first = *on;
         open liclog;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Cleanlicinfo  cleanup licinfo
     *----------------------------------------------------------------

      /free
       begsr CleanLicInfo;

         if %open(licinfo2);
         else;
           open licinfo2;
         endif;

         setll (llwhse: lllcns) licinfo2;
         dow forever = forever;
           reade  (llwhse: lllcns) licinfo2;
           if %eof(licinfo2);
             leave;
           endif;

       // history is on write to history files
           if history = *on;
             if %open(licinfoh);
             else;
               open licinfoh;
             endif;
             write lnhrec;
           endif;

       // remove licinfo
           Delete lnrec;

         enddo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Cleanliclog   cleanup liclog
     *----------------------------------------------------------------

      /free
       begsr CleanLicLog;

         setll (llwhse: lllcns) liclog;
         dow forever = forever;
           reade    (llwhse: lllcns) liclog;
           if %eof(liclog);
             setgt (llwhse: lllcns) liclog;
             leave;
           endif;

       // history is on write to history files
           if history = *on;
             if %open(liclogh);
             else;
               open liclogh;
             endif;
             write llhrec;
           endif;

       // remove liclog record
           delete llrec;
           RunCount += 1;
         enddo;
       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  CleanliclogSpec Cleanup liclog - special circumstance
640cA*----------------------------------------------------------------

640cA /free
640cA  begsr CleanLicLogSpec;

640cA    chain (llwhse: lllcns: lladduc) liclog;
640cA    // history is on write to history files
640cA    if history = *on;
640cA      if %open(liclogh);
640cA      else;
640cA        open liclogh;
640cA      endif;
640cA      write llhrec;
640cA    endif;

640cA    // remove liclog record
640cA    delete llrec;
640cA    RunCount += 1;
640cA  endsr;
640cA /end-free

640dA*----------------------------------------------------------------
640dA*  Cleanpoasn    cleanup POASN
640dA*----------------------------------------------------------------

640dA /free
640dA  begsr CleanPOasn;

640dA    if %open(poasn1);
640dA    else;
640dA      open poasn1;
640dA    endif;

640dA    setll (llwhse: lllcns) poasn1;
640dA    dow forever = forever;
640dA      reade  (llwhse: lllcns) poasn1;
640dA      if %eof(poasn1);
640dA        leave;
640dA      endif;

640dA  // history is on write don't remove poasn until history is deleted
640dA      if history = *on;
640dA      else;
640dA        // remove poasn
640dA        Delete parec;
640dA      endif;

640dA    enddo;
640dA  endsr;
640dA /end-free

     *----------------------------------------------------------------
     *  zzzCalcRunTime Calculate Run Time
     *----------------------------------------------------------------

      /free
       begsr zzzCalcRunTime;

         if $sdttme = $ndttme;
           $sdttme= %timestamp;
         else;
           $cdttme= %timestamp;
           ttlhrs = %diff($cdttme: $sdttme: *h);
         endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetoptions  Get options
     *----------------------------------------------------------------

      /free
       begsr zzzGetOptions;

         keyop.opwhse = 0;
         keyop.opcode = '*SYSTEM';

         chain %kds(keyop) options;
         if not %found();
           chkwks = 26;
           history = *off;
         else;
           chkwks = oprths;
           if        opishs > 0;
             history = *on;
           endif;
           if        chkwks < opcrhs;
             chkwks = opcrhs;
           endif;
           if        chkwks < oppohs;
             chkwks = oppohs;
           endif;
           if        chkwks < opiahs;
             chkwks = opiahs;
           endif;
           if        chkwks < opmshs;
             chkwks = opmshs;
           endif;
         endif;
         curdate = %date();
         chkdays = chkwks * 7;
         curdate = curdate - %days(chkdays);
         $dtetme= %timestamp(%char(curdate) +
                      '-00.00.00.000000');

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

      /free
       begsr zzzEnd;


       endsr;
      /end-free
