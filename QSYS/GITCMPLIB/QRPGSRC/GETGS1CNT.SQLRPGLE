      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETGS1CNT    Get Qty and weight
     *  21 January 2020
     *  Lynn McMahon
     *
740 A*    01/21/20  LMC  7.40a
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D uiwrec        E ds                  extname(uciwork) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D likeValue       s             12
     D maxLoc          s              3  0
     D minLoc          s              3  0
     D startLoc        s              3  0 inz(101)
     D pwhse           s              3p 0
     D pposeq          s              5p 0

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
     *     pPO    - Purchase order
     *     pPOSeq - Po seq#
     *
     *   Return Value:
     *     pqty       -  total number of records not loaded
     *     pwgt       -  total weight of records not laoded
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    ppo               9
     C                   parm                    pposeq
     C                   parm                    pqty              4 0
     C                   parm                    pwgt              7 2

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        exsr GetQtyWgt;

       return;

      /end-free

     *----------------------------------------------------------------
     *  GetData        Get qty and wgt
     *----------------------------------------------------------------

      /free
       begsr GetQtyWgt;


        exec sql select count(*), sum(uiwwgtlbs)
                 into :pqty,
                      :pwgt
                  from uciwork
                  where uiwwhse= :pwhse
                    and uiwpo  = :ppo
                    and uiwposeq= :pposeq
                    and uiwload = ' ';

         if sqlstt <> sqlSuccess;
           pqty      = 0;
           pwgt      = 0;
         endif;

       endsr;
      /end-free
