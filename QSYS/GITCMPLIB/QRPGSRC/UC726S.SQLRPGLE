      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  UC726S    Staging Export UPC Codes
     *  28 August 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
650 A*    08/28/14  RTR  6.50
     *      - Created from PT751S.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fexpsupc   uf a e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *
     D upcrec        e ds                  extname(upc) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Working variables
     *
     D batId           s             11a
     D batStat         s              1a
     D batText         s            200a
     D cnt             s             10i 0
     D haveBatId       s               n
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stamploval      s               z
     D stampUC         s               z

     D dsWhse          ds
     D  batWhse                1      3  0
     D  batWhsea               1      3a

     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Prototypes
     *
     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Parameters
     *
     D $pWhse          s              3p 0
     D $pWhse3A        s              3

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        exsr ProcRecs;

        if haveBatId;
          exsr zzzEnd;
        endif;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
      /free
       begsr *inzsr;

         batWhse = %dec($pWhse3a:3:0);
         haveBatId = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ProcRecs       Process Records
     *----------------------------------------------------------------
      /free
       begsr ProcRecs;

        exec sql
          declare recs cursor for
            select upwhse, upitem, upupc from upc
             where upwhse = :batwhse;

        exec sql open recs;
        if sqlstt <> sqlSuccess;
          leavesr;
        endif;

        dow forever = forever;

          exec sql fetch next from recs
                   into :upwhse,:upitem,:upupc;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // If first time, get batch id. If error, get out.
          if not haveBatId;
            exsr zzzGetBatId;
            if batId = *blanks;
              leave;
            endif;
            haveBatId = *on;
            exsr zzzGetStamps;
          endif;

          // Write staging record
          ucwhse = batwhse;
          ucbatid = batId;
          ucstatus = 'R';
          uctext = 'Ready for export';
          ucitem = upitem;
          uccode = upupc;
          ucaddts = stamp;
          ucadduc = stampUC;
          write ucrec;

        enddo;

        exec sql close recs;

       endsr;   // ProcRecs
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        monitor;
          GetBatId(batWhse: 'EXPUPC': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
       begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp - current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

        stamploval = *loval;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------
      /free
       begsr zzzEnd;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :batWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        //$pReturn = '*ERROR';
        //$pMessage = 'Unable to update batch record.';
        endif;

       endsr;   // zzzEnd
      /end-free
