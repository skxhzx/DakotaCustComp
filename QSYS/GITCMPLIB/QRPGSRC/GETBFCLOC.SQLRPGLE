      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETBFCLOC    Get slloc for special BFC slot
     *  22 February 2011
     *  Dave Sommerville
     *
640 A*    02/22/11  DAS  6.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D slrec         E ds                  extname(slot) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D likeValue       s             12
     D maxLoc          s              3  0
     D minLoc          s              3  0
     D startLoc        s              3  0 inz(101)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     pWhdp  - Department
     *     pAisle - Aisle
     *     pDisp  - Beginning of display field for LIKE lookup.
     *
     *   Return Value:
     *     pLoc       -  Location
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pWhdp             5
     C                   parm                    pAisle            3
     C                   parm                    pDisp            12
     C                   parm                    pLoc              3 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        exsr getDispLocation;

        if pLoc < startLoc;
          exsr getNewLocation;
        endif;

       return;

      /end-free

     *----------------------------------------------------------------
     *  GetDispLocation   Get location for partial dislay
     *----------------------------------------------------------------

      /free
       begsr GetDispLocation;

         likeValue = %trim(pDisp) + '%%%%%%%%%%%%';

         exec sql select max(slloc) into :pLoc
                  from slot
                  where slwhse = :pWhse
                    and slwhdp = :pWhdp
                    and slaisl = :pAisle
                    and sldisp LIKE :likeValue;

         if sqlstt <> sqlSuccess;
           pLoc = 0;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetNewLocation   Get new location for aisle
     *----------------------------------------------------------------

      /free
       begsr GetNewLocation;

         exec sql select min(slloc), max(slloc) into :minLoc, :maxLoc
                  from slot
                  where slwhse = :pWhse
                    and slwhdp = :pWhdp
                    and slaisl = :pAisle
                    and slloc >= :startLoc;

         if sqlstt <> sqlSuccess;
           pLoc = startLoc;
           leavesr;
         endif;

         if minLoc > startLoc;
           pLoc = minLoc - 1;
         else;
           if maxLoc = 999;
             pLoc = maxLoc;
           else;
             pLoc = maxLoc + 1;
           endif;
         endif;

       endsr;
      /end-free
