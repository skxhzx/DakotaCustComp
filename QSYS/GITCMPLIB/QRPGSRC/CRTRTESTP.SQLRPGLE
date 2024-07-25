      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CRTRTESTP   Create RTESTP records for route id
     *  21 November 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    11/21/08  DAS  5.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D getClient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  location                     10

500lA*----------------------------------------------------------------
500lA*  Customer id
500lA*----------------------------------------------------------------
500lA
500lA /copy qcopysrc,id#cashwa

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D cliLocation     s             10

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pCmd     *CREATE  -  Delete/Create recs for route id.
     *                *DELETE  -  Delete recs for route id.
     *      $pwhse    Warehouse
     *      $prtid    Route id
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *ENTRY        plist
     C                   parm                    $pCmd             8
     C                   parm                    $pwhsea           3
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
500lA
500lA   // Get client id
500lA
500lA   getClient(client : cliLocation);
500lA
500lA   // Executer appropriat routine

        select;
500lA
            when $pCmd = '*DELETE';
              exsr deleteRecs;

            when $pCmd = '*RANDOM';
              exsr randomStops;

            when client = caswa;
              exsr createCashWa;

        endsl;

        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Subroutines in Alphabetical Order
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  randomCashWa  Create records for a CashWa route id
     *----------------------------------------------------------------

      /free
       begsr randomCashWa;

         exsr deleteRecs;

         exec sql
             INSERT into rtestp (rtswhs, rtsrid, rtsstp, rtsst5)
             SELECT ohwhse, ohrte, ohstop,
                    (SELECT decimal(substring(hmmsc1,1,3),5,0)
                     FROM ORDHM
                     WHERE hmwhse=ohwhse and hmrtid=ohrte and hmord=ohord)
             FROM ordh
             WHERE ohwhse = :$pwhsea and ohrte = :$prtid
             GROUP BY ohwhse, ohrte, ohstop
         ;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  randomStops   Create records with random 3-digit stops
     *----------------------------------------------------------------

      /free
       begsr randomStops;

         exsr deleteRecs;

         exec sql
             INSERT into rtestp (rtswhs, rtsrid, rtsstp, rtsst5)
             SELECT ohwhse, ohrte, ohstop,
                    integer(100+(999-100)*rand())
             FROM ordh
             WHERE ohwhse = :$pwhsea and ohrte = :$prtid
             GROUP BY ohwhse, ohrte, ohstop
         ;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  deleteRecs   Delete records for route id
     *----------------------------------------------------------------

      /free
       begsr deleteRecs;

         exec sql
             delete from rtestp
             where ohwhse = :$pwhsea and ohrte = :$prtid;

       endsr;
      /end-free
