      /COPY *libl/qcopysrc,hspecs
     H dftactgrp(*no)
      //----------------------------------------------------------------
      //
      //  OR641 Assign voice pallet id.
      //  28 August 2015
      //  Donnie Sanders
      //
      //  Revisions
      //
700   //    08/28/15  DLS  7.00a
      //      - Created
      //
700b  //    12/21/15  GJA  7.00b
      //      - Fix:  It was not getting record with PSFLAG set to blanks.
      //
700c  //    12/21/15  LMC  7.00c
      //      - Fix:  Add incoming parms
700c  //    07/26/16  GJA  7.00d
      //      - Fix:  Was not selecting overflow pallets, changed to gen 1
700e  //    08/09/16  MR   7.00e
      //      - Fix:  Change sql to get most current record from
      //              PLTSUMU.
700f  //    07/12/17  NLK  7.00f
      //      - Fix:  Don't allow RHstat=6 have an Exp Dt of zero
      //----------------------------------------------------------------

      //----------------------------------------------------------------
      //  Prototypes
      //----------------------------------------------------------------

      // AddVoiceID - add/update PLTSUMU record
     D AddVoiceID      pr
     D  pswhse                        3s 0
     D  psrtid                        5a
     D  psplid                        7  0
     D  voiceID                       4s 0

      // Check SQL State
     D CheckSQLState   pr             8a
     D                                5a   const

     D sqlCONTINUE     c                   const('CONTINUE')                    Continue Processing
     D sqlLEAVE        c                   const('LEAVE')                       Stop Proessing
     D sqlRtnState     s              8a   inz

      // GetNextVoicePalletID - Return next 4 digit voice pallet ID#
     D GetVoiceID      pr             4s 0
     D  pWarehouse                    3s 0
     D  pRouteID                      5a

      // RANDOM - Random Number Generator
     D Random          pr                  extpgm('RANDOM')
     D  maxValue                      7  0                                      Maximum value
     D  randomNumber                  7  0                                      Random number return

      //----------------------------------------------------------------
      //  Variables.
      //----------------------------------------------------------------

     D dsPLTSUM      e ds                  extname(PLTSUM)
     D maxValue        s              7  0 inz(9999)                            Maximum value
     D randomNumber    s              7  0 inz(0)                               Random number return
     D voiceID         s              4s 0 inz

      //----------------------------------------------------------------
      //  Parameters
      //
      //    Input Parameters
      //      None
      //
      //    Returned Parameters
      //      None
      //----------------------------------------------------------------

      //----------------------------------------------------------------
      //  Program Entry Point
      //----------------------------------------------------------------

     D OR641           pr                  extpgm('OR641')
700cAD  pwhse                         3  0
700cAD  prteid                        5a

     D OR641           pi
700cAD  pwhse                         3  0
700cAD  prteid                        5a

      //----------------------------------------------------------------
      //  Main line
      //----------------------------------------------------------------

      /Free
       // Initialize sqlRtnState
       sqlRtnState = sqlCONTINUE;

       // Declare & Open Cursor
       exec sql
         declare csrPLTSUM cursor for
           SELECT *
             FROM PLTSUM
            WHERE PSGEN = 1
700cA         AND PSWHSE = :PWHSE
700cA         AND PSRTID = :PRTEID
              AND PSTYPE = 'O'
              AND PSPCS > 0;
700dD  //     AND PSFLAG = '0';
700bD  //     AND PSFLAG = ' ';

       exec sql
         open csrPLTSUM;


       // Process Result Set
       dou sqlRtnState <> sqlCONTINUE;
         clear dsPLTSUM;
         exec sql
           fetch next from csrPLTSUM into :dsPLTSUM;

         // Check SQL state
         sqlRtnState = CheckSQLState(sqlstt);
         if sqlRtnState <> sqlCONTINUE;
           iter;
         endif;

         // Get next 4 digit voice pallet id
         voiceID = GetVoiceID(PSWHSE :PSRTID);

         // Add/Update PLTSUMU record
         AddVoiceID(PSWHSE :PSRTID :PSPLID :voiceID);
       enddo;

       // End Of Program
       *inlr = *on;
       return;
      /End-Free



      //------------------------------------------------------------------
      // AddVoiceID - add/update PLTSUMU record
      //------------------------------------------------------------------
     P AddVoiceID      b

     D AddVoiceID      pi
     D  xWarehouse                    3s 0
     D  xRouteID                      5a
     D  xPalletID                     7  0
     D  xVoiceID                      4s 0

      *
      * Local variables
      *
     D recordCount     s              4s 0 inz

      /Free
       // Check if record exists in PLTSUMU
       exec sql
         SELECT count(*)
           INTO :recordCount
           FROM PLTSUMU
          WHERE PSUWHSE = :xWarehouse
            AND PSURTID = :xRouteID
            AND PSUPLID = :xPalletID;

       // Check SQL state
       if CheckSQLState(sqlstt) = sqlCONTINUE;
         if recordCount = 0;
           // Insert record
           exec sql
             INSERT INTO PLTSUMU
                  VALUES(:xWarehouse, :xRouteID, :xPalletID, :xVoiceID,
                         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP-CURRENT_TIMEZONE);
         else;
           // Update record
           exec sql
             UPDATE PLTSUMU
                SET PSUVID   = :xVoiceID,
                    PSUADDTS = CURRENT_TIMESTAMP,
                    PSUADDUC = CURRENT_TIMESTAMP-CURRENT_TIMEZONE
              WHERE PSUWHSE = :xWarehouse
                AND PSURTID = :xRouteID
                AND PSUPLID = :xPalletID;
         endif;
       endif;
      /End-Free
     P                 e

      //------------------------------------------------------------------
      // CheckSQLState - Evaluate SQLSTT and return CONTINUE or LEAVE
      //------------------------------------------------------------------
     P CheckSQLState   b

     D CheckSQLState   pi             8a
     D xSQLstt                        5a   const

      /Free

       // Check SQL state for EOF or ERRORS
       if xSQLstt = '00000';
         return sqlCONTINUE;
       else;
         return sqlLEAVE;
       endif;

      /End-Free
     P                 e

      //------------------------------------------------------------------
      // GetNextVoicePalletID - Return next 4 digit voice pallet ID#
      //------------------------------------------------------------------
     P GetVoiceID      b

     D GetVoiceID      pi             4s 0
     D xWarehouse                     3s 0
     D xRouteID                       5a

      *
      * Local variables
      *
     D dsPLTSUMU     e ds                  extname(PLTSUMU)
     D dsRTEHED      e ds                  extname('RTEHED')
     D exportDate      s               d   inz
     D recordCount     s             10i 0 inz
     D xVoiceID        s              4s 0 inz

      /Free
       dou sqlState <> sqlCONTINUE;
       // Get random number for voice pallet id
         clear randomNumber;
         Random(maxValue : randomNumber);

         // Verify random number is not zero
         if randomNumber = 0;
           randomNumber += 1;
         endif;

         xVoiceID = randomNumber;

         // Does random number exists in PLTSUMU?
         exec sql
             SELECT *
               INTO :dsPLTSUMU
               FROM PLTSUMU
              WHERE PSUVID = :xVoiceID
700eA         AND   PSUADDTS = (SELECT MAX(PSUADDTS)
700eA         FROM PLTSUMU WHERE PSUVID = :xVoiceID);
700eD    //ORDER BY PSUADDUC DESC
700eD    //fetch first 1 row only;

         // If random number exists then further validation needed
         if CheckSQLState(sqlstt) = sqlCONTINUE;
           // Get RTEHED to check status & export date
           exec sql
               SELECT *
                 INTO :dsRTEHED
                 FROM RTEHED
                WHERE RHWHSE = :PSUWHSE
                  AND RHRTID = :PSURTID
             fetch first 1 row only;

           // Check SQL state
           if CheckSQLState(sqlstt) = sqlCONTINUE;

700fA        // don't allow rhexpd 0, throws error in GetVoiceID
700fA        if rhstat = '6' and rhexpd = 0;
700fA          iter;
700fA        endif;

             // Check if Voice ID recently used(may still be on dock)
             if RHSTAT < '6'
             or (RHSTAT = '6' and
                 %diff(%date() :%date(RHEXPD:*ISO) :*DAYS) < 31 );
               // Try another random number
               iter;
             else;
               // RTEHED record found, but shouldn't be on dock
               leave;
             endif;
           else;
             // RTEHED record not found
             leave;
           endif;

         endif;
       enddo;

       return xVoiceID;
      /End-Free
     P                 e
