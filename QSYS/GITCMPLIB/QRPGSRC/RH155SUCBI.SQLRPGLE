      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  RH155SUCBI  CBI - Group Queued UCI records to single batch
     *  26 December 2016
     *  Rod Roller
     *
     *     Needed because SAP can't handle large numbers of batches
     *     and SAP is retrieving once a day. DKTEXPORT will this
     *     program to assign batch ID and change status for all
     *     status Q records, making one big batch.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    12/26/16  RTR  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  File data structures
     *----------------------------------------------------------------
     d opirec        e ds                  extname(OPTIONINT) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Customer id
      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#cheneyo
      /copy qcopysrc,id#cheneyr
      /copy qcopysrc,id#cheneyp

     *----------------------------------------------------------------
     *  Working variables
     D batIdcbi        s             11
     D cntOrduRecs     s              9  0
     D count           s              9  0
     D error           s              1
     D haveBatId       s               n
     D OptUseOrdu      s              1a
     D $pwhse          s              3  0
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stampUC         s               z

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   pWhse                        3p 0 const
     d   pType                       10    const
     d   pStatus                      1    const
      * Output
     d   pBatId                      11
     d   pReturn                     10
     d   pMessage                   200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhsea           3

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        *inlr = *on;
        // Get batch id
        if OptUseOrdU = 'Y'
         and client = cheney;
          monitor;
            GetBatId($pWhse: 'EXPCBIUCI': 'W':
                     batIdCBI: rtnCode: rtnMessage);
          on-error;
            rtnCode = '*ERROR';
          endmon;
        endif;

        if rtnCode <> '*OK';
          return;
        endif;

        // Set all with status 'Q' and no batch ID to new one.
        exec sql update EXPSORDU
                    set OEUSTATUS = 'R',
                        OEUBATID  = :batIdCBI
                  where OEUSTATUS = 'Q'
                    and OEUWHS    = :$pWhse
                    and OEUBATID  = '       ';

        if sqlstt <> sqlsuccess;
          exec sql update stgbatch
            set sbstatus = 'E',
                sbtext   = ' ',
                sbststs  = current_timestamp,
                sbstsuc  = current_timestamp - current_timezone
            where sbwhse = :$pWhse
              and sbbatid = :batIdCBI;
        else;
          exec sql update stgbatch
            set sbstatus = 'R',
                sbtext   = ' ',
                sbststs  = current_timestamp,
                sbstsuc  = current_timestamp - current_timezone
            where sbwhse = :$pWhse
              and sbbatid = :batIdCBI;
        endif;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10

      /free
        monitor;
          $pwhse = %dec($pwhsea:3:0);
        on-error;
          $pwhse = 0;
        endmon;

        // Get Option to see if ORDU file is used.
        exec sql select substr(OPIVALA,1,1) into :OptUseOrdU
                   from OPTIONINT
                  where OPITYPE = 'EXPORD'
                    and OPICAT  = 'ORDER UCI'
                    and OPINAME = 'EXPORT UCI RECORD';

        if sqlstt <> sqlsuccess;
          OptUseOrdU = 'N';
          // record not found, insert defaults so record exists.
          OPITYPE = 'EXPORD';
          OPICAT  = 'ORDER UCI';
          OPINAME = 'EXPORT UCI RECORD';
          OPIVALT = 'A';
          OPIVALA = 'N';
          exec sql insert into OPTIONINT values(:opirec);
        else;
          // record found, but make sure y is uppercase.
          if OptUseOrdU = 'y';
            OptUseOrdU = 'Y';
          endif;
        endif;
      /end-free
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
       begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

       endsr;  // zzzGetStamps
      /end-free
