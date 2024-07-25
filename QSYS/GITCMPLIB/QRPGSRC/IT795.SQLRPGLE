      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT795     Adjustments - Daily CSV Export
     *  January 18, 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes
     *    - Pass return date in parm as 'CCYYMMDD'.
     *    - If parm is blank or invalid, will run for previous day.
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    01/18/18  RTR  7.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program parameters
     *
      /copy *libl/qcopysrc,p.getopint
      /copy *libl/qcopysrc,p.qcmdexc
      /copy *libl/qcopysrc,p.wrtlog

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *
     d cmdstr          s           3000a
     d cmdlen          s             15p 5
     d datework        s               d   datfmt(*iso)
     d ifspath         s            200a
     d debugflag       s               n

     *----------------------------------------------------------------
     *  Parameters
     *    Input Parameters
     *      $PDATE     Return Date. Current-1 if blank.
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('IT795')
     d   pDate                        8

     d main            pi
     d   pDate                        8

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free

        // If date not passed, use current minus 1 day
        if pDate = *blanks;
          datework = %date() - %days(1);
          pDate = %char(datework:*iso0);
        endif;

        // Build command to create export
        ifspath = %trim(ifspath) + 'Adj-' + pDate + '.csv';
        cmdstr = 'SQL2CSV SQLSTMT(' + sq
               + 'SELECT IAWHSE as whs,'
               + 'IAITEM as item,'
               + 'IADATE as adj_date,'
               + 'IATIME as adj_time,'
               + 'IABY   as adj_user,'
               + 'IAWHDP as item_dept,'
               + 'IADISP as slot_adjusted,'
               + 'IACWTA as weight_adjustment,'
               + 'IAQTY1 as normal_quantity,'
               + 'IAQTY2 as breakdown_1_quantity,'
               + 'IAQTY3 as breakdown_2_quantity,'
               + 'IACODE as adj_code,'
               + 'IAMEMO as memo,'
               + 'IAWHSE as whs2 '
               + 'FROM ITEMADJ '
               + 'WHERE IADATE=' + %trim(pDate)
               + ' AND SUBSTR(IACODE,1,1)<>"@"'
               + ' ORDER BY IADATE,IATIME' + sq
               + ') TOCSV(' + sq + %trim(ifspath) + sq + ') COLHDRS(*ANY)';
        cmdlen = %len(cmdstr);
        monitor;
          qcmdexc(cmdstr: cmdlen);
        on-error;
          log.pgm = #pgm;
          log.type = 'ERROR    ';
          log.text = 'Error running SQL2CSV for date: ' + pDate;
          WrtLog(log.pgm: log.type: log.text);
        endmon;

        // Build command to change authority
        cmdstr = 'CHGAUT OBJ(' + sq + %trim(ifspath) + sq
               + ') DTAAUT(*RWX) OBJAUT(*ALL) AUTL(BFCGRPPAN)';
        cmdlen = %len(cmdstr);
        monitor;
          qcmdexc(cmdstr: cmdlen);
        on-error;
          log.pgm = #pgm;
          log.type = 'ERROR    ';
          log.text = 'Error updating auth for: ' + ifspath;
          WrtLog(log.pgm: log.type: log.text);
        endmon;

        exsr zzEnd;
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

          // Get debug flag
          optint.type = 'Interface   ';
          optint.cat  = 'Export Adjustments  ';
          optint.name = 'Debug Flag          ';
          GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                    optint.valn: optint.vala: optint.return);
          if optint.return = '*OK'
           and optint.vala = 'Y';
            debugflag = *on;
          else;
            debugflag = *off;
          endif;

          // Log program start
          if debugflag;
            log.pgm = #pgm;
            log.type = 'Start    ';
            log.text = 'Adjustments Daily CSV Export for: ' + pDate;
            WrtLog(log.pgm: log.type: log.text);
          endif;

          // Get IFS path for export
          optint.type = 'Interface   ';
          optint.cat  = 'Export Adjustments  ';
          optint.name = 'IT795 CSV IFS Path  ';
          GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                    optint.valn: optint.vala: optint.return);
          if optint.return = '*OK';
            ifspath = optint.vala;
          else;
            ifspath = '/';
          endif;

        endsr; // *inzsr
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZEND   Program End
     *
      /free
        begsr zzEnd;

          // Log program end
          if debugflag;
            log.pgm = #pgm;
            log.type = 'End      ';
            log.text = 'Adjustments Daily CSV Export for: ' + pDate;
            WrtLog(log.pgm: log.type: log.text);
          endif;

        endsr; // zzEnd
      /end-free
