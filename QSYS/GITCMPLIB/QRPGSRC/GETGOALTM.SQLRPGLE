      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETGOALTM    GetPick goal times
     *  22 March 2011
     *  Jeffrey Jahnke
     *
640 A*    03/22/11  JCJ  6.40a
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lbrec         E ds                  extname(label) inz(*EXTDFT)

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
     *     pTran  - Transaction Number
     *
     *   Return Value:
     *     pGoalTime  -  Pick Goal Time
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pTran             7 0
     C                   parm                    pGoalTime         7 3

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        exsr getGoalTimes;

       return;

      /end-free

     *----------------------------------------------------------------
     *  GetGoalTimes   Get pick Goal Times
     *----------------------------------------------------------------

      /free
       begsr GetGoalTimes;


         exec sql select round((dec(1.650,7,3)
                    + (sum(lbqpck) * 0.105)
                    + (count(distinct lbdisp) * 0.124)
                    + (count(distinct lbaisl) * 1.230)
                    + 0.5),0) into :pGoaltime
                  from label
                  where lbtrn# = :pTran;

         if sqlstt <> sqlSuccess;
           pGoaltime = 0;
         endif;

       endsr;
      /end-free
