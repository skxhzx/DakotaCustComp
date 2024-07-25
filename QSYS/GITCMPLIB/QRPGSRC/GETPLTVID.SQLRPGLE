      /COPY *libl/qcopysrc,hspecs
     H dftactgrp(*no)
      //----------------------------------------------------------------
      //
      //  GETPLTVID - Return Pallet ID or Voice ID
      //  28 August 2015
      //  Donnie Sanders
      //
      //  Revisions
      //
700   //    08/28/15  DLS  7.00a
      //      - Created
      //
      //----------------------------------------------------------------

      //----------------------------------------------------------------
      //  Prototypes
      //----------------------------------------------------------------

      // Check SQL State
     D CheckSQLState   pr             8a
     D                                5a   const

     D sqlCONTINUE     c                   const('CONTINUE')                    Continue Processing
     D sqlLEAVE        c                   const('LEAVE')                       Stop Proessing
     D sqlRtnState     s              8a   inz

      //----------------------------------------------------------------
      //  Variables.
      //----------------------------------------------------------------
     d dsPLTSUMU     e ds                  extname(PLTSUMU)

      //----------------------------------------------------------------
      //  Parameters
      //
      //    Input Parameters
      //      $Command     *PALLETID - Return pallet id
      //                   *VOICEID  - Return voice id
      //      $IdPassedIn  Pallet or voice id to lookup
      //      $Whse        Warehouse
      //      $Rtid        Route ID
      //
      //    Returned Parameters
      //      $IdReturned   blank    - Pallet or voice id not found
      //
      //----------------------------------------------------------------

      //----------------------------------------------------------------
      //  Program Entry Point
      //----------------------------------------------------------------
     D GETPLTVID       pr                  extpgm('GETPLTVID')
     D  $Command                      9a
     D  $IdPassedIn                   7  0
     D  $Whse                         3  0
     D  $Rtid                         5a
     D  $IdReturned                   7  0

     D GETPLTVID       pi
     D  $Command                      9a
     D  $IdPassedIn                   7  0
     D  $Whse                         3  0
     D  $Rtid                         5a
     D  $IdReturned                   7  0

      //----------------------------------------------------------------
      //  Main line
      //----------------------------------------------------------------

      /Free
       // Initialize returned parameter
       clear $IdReturned;

       // Fetch latest record from PLTSUMU based on $Command parameter
       select;
         // Get record by Voice ID - return Pallet ID
         when $Command = '*PALLETID' and $IdPassedIn <= 9999;
           exec sql
               SELECT *
                 INTO :dsPLTSUMU
                 FROM PLTSUMU
                WHERE PSUVID  = :$IdPassedIn
                  AND PSUWHSE = :$Whse
                  AND PSURTID = :$Rtid
             ORDER BY PSUADDUC DESC
             fetch first 1 row only;

           if CheckSQLState(sqlstt) = sqlCONTINUE;
             $IdReturned = psuplid;
           endif;

         // Voice ID passed in is invalid if exceeds 4 digits
         when $Command = '*PALLETID' and $IdPassedIn > 9999;
           clear $IdReturned;

         // Get record by Pallet ID - return Voice ID
         when $Command = '*VOICEID';
           exec sql
               SELECT *
                 INTO :dsPLTSUMU
                 FROM PLTSUMU
                WHERE PSUPLID = :$IdPassedIn
                  AND PSUWHSE = :$Whse
                  AND PSURTID = :$Rtid
             ORDER BY PSUADDUC DESC
             fetch first 1 row only;

           if CheckSQLState(sqlstt) = sqlCONTINUE;
             $IdReturned = psuvid;
           endif;
       endsl;

       // End Of Program
       *inlr = *on;
       return;
      /End-Free

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

