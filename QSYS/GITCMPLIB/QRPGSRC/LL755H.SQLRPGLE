      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LL755H    cleanup LICLOGH and LICINFOH final removal from history
     *  20 January 2012   6.40
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *     - Remove records from LICLOGH if not in licactive file
     *     - check for both the license and orginal license - both
     *       must be gone before removing the LICLOGH record
     *     - check the date on the last record in liclogh for the
     *       license, that will ensure we keep all data until the
     *       last log record for the license is old enough to remove.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    01/20/12  LMC   6.40
     *      - Created
     *
640aA*    02/20/12  LMC   6.40a
     *      - Fix: Get out if opishs = 0, No need to process
640bA*    06/13/12  LMC   6.40b
     *      - Enh: If original license is blank, don't check the
     *        LICACTIVE license file
640cA*    06/14/12  LMC   6.40c
     *      - Enh: Added some additional logic to allow for better
     *        performance. Since we reuse deleted records, we are
     *        processing the current records first and since the
     *        program is set to only process for one hour, we are not
     *        getting far enough into the file to get some of the old
     *        data cleaned up. This change will cut down on the I/O
     *        being performed on the newest data.
640dA*    06/18/12  LMC   6.40d
     *      - Enh: Added some additional logic to deal with records
     *        with Blank LLLCNS and Blank LLOLCNS.
     *        Added the same kind of logic for *CC licenses.
640eA*    08/09/12  LMC   6.40e
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
     Flicinfoh2 uf   e           k disk    usropn
     Fliclogh   uf   e           k disk    usropn
640eAFpoasn1    uf   e           k disk    usropn
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

     D chkdays         s              5  0
     D chkwks          s              4  0
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

     *  Loop through LICLOGH records to determine if records should be
     *  removed

      /free

640aA  // If extended history is set to 0 get out
640aA    if opishs = 0;
640aA      return;
640aA    endif;

       // Loop through records to determine clenaup.

         setll ($pwhse) liclogh;
         dow forever = forever;
           reade(n) ($pwhse) liclogh;
           if %eof(liclogh);
             leave;
           endif;

640cA  // if the date of this record is beyound our cleanup date
640cA  // there is no reason to do any additional checking on this liclog
640cA  // this should reduce the I/O's required to determine if this license
640cA  // is even eligible to be cleaned up

640cA      if lladduc > $dtetme;
640cA        setgt (llwhse: lllcns) liclogh;
640cA        iter;
640cA      endif;

640dA  // special circumstances - blank lllcns & blank llolcns will
640dA  // cleanup based on lladduc of that record only.

640dA  if lllcns = ' ' and llolcns = ' ' and lladduc < $dtetme;
640dA    exsr cleanliclogspec;
640dA    iter;
640dA  endif;

640dA  // special circumstances - *CC lllcns & *CC llolcns will
640dA  // cleanup based on lladduc of that record only.

640dA  if lllcns = '*CC' and llolcns = '*CC' and lladduc < $dtetme;
640dA    exsr cleanliclogspec;
640dA    iter;
640dA  endif;

       // check for active license
       // check for looping license - if found in licactive and date is
       // less than or equal to the date in liclogh then it is still active
       // this log record should have never gotten to the history file

           chain (llWhse: lllcns) licactive;
           if %found(licactive) and laentd <= llentd;
             setgt (llwhse: lllcns) liclogh;
             iter;
           endif;

       // check for active orginal license
       // check for looping license - if found in licactive and date is
       // less than or equal to the date in liclogh then it is still active
       // this log record should have never gotten to the history file

640bA      if llolcns <> ' ';
             chain (llWhse: llolcns) licactive6;
             if %found(licactive6) and laentd <= llentd;
               setgt (llwhse: lllcns) liclogh;
               iter;
             endif;
640bA      endif;

       // get the last record for the license to determine last date

           setgt (llwhse: lllcns) liclogh;
           readpe(n) (llwhse: lllcns) liclogh;
           if %eof(liclogh);
             iter;
           endif;

       // check to see if date should be cleaned out of file
           if lladduc < $dtetme;
             exsr  cleanlicinfo;
640eA        exsr  cleanpoasn;
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
         if %open(liclogh);
           close liclogh;
         endif;
         if %open(licinfoh2);
           close licinfoh2;
         endif;
640eA    if %open(poasn1);
640eA      close poasn1;
640eA    endif;
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

640aA    if opishs = 0;
640aA      leavesr;
640aA    endif;
         first = *on;
         open liclogh;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Cleanlicinfo  cleanup licinfo
     *----------------------------------------------------------------

      /free
       begsr CleanLicInfo;

         if %open(licinfoh2);
         else;
           open licinfoh2;
         endif;

         setll (llwhse: lllcns) licinfoh2;
         dow forever = forever;
           reade  (llwhse: lllcns) licinfoh2;
           if %eof(licinfoh2);
             leave;
           endif;

       // history is on write to history files
           if history = *on;
             if %open(licinfoh2);
             else;
               open licinfoh2;
             endif;
             delete lnhrec;
           endif;

         enddo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Cleanliclog   cleanup liclogh
     *----------------------------------------------------------------

      /free
       begsr CleanLicLog;

         setll (llwhse: lllcns) liclogh;
         dow forever = forever;
           reade    (llwhse: lllcns) liclogh;
           if %eof(liclogh);
             setgt (llwhse: lllcns) liclogh;
             leave;
           endif;

       // history is on delete from history files
           if history = *on;
             delete llhrec;
             RunCount += 1;
           endif;

         enddo;
       endsr;
      /end-free

640dA*----------------------------------------------------------------
640dA*  CleanliclogSpec Cleanup liclog - special circumstance
640dA*----------------------------------------------------------------

640dA /free
640dA   begsr CleanLicLogSpec;

640dA    chain (llwhse: lllcns: lladduc) liclogh;
640dA    // history is on - delete from history files
640dA    if history = *on;
640dA      delete llhrec;
640dA      RunCount += 1;
640dA    endif;
640dA   endsr;
640dA /end-free

640eA*----------------------------------------------------------------
640eA*  Cleanpoasn    cleanup POASN
640eA*----------------------------------------------------------------

640eA /free
640eA  begsr CleanPOasn;

640eA    if %open(poasn1);
640eA    else;
640eA      open poasn1;
640eA    endif;

640eA    setll (llwhse: lllcns) poasn1;
640eA    dow forever = forever;
640eA      reade  (llwhse: lllcns) poasn1;
640eA      if %eof(poasn1);
640eA        leave;
640eA      endif;

640eA        // remove poasn
640eA        Delete parec;

640eA    enddo;
640eA  endsr;
640eA /end-free

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
         chkwks += opishs;
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
