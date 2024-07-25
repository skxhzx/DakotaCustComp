417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CBIPROTO    Cheney prototype for returning result sets
     *  03 February 2011
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    03/02/11  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pType       Batch type
     *                  *ALL - Only used for Result Sets
     *      pRunType    I = Interactive, J = Jobq, S = Result Sets
     *
     *    Returned Parameters
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     D cbiproto        pr                  extpgm('CBIPROTO')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                     1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D cbiproto        pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                     1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)
     D lbrec         E ds                  extname(label) inz(*EXTDFT)
     D oelrec        E ds                  extname(expsordl) inz(*EXTDFT)
     D oehrec        E ds                  extname(expsordh) inz(*EXTDFT)
     D oedrec        E ds                  extname(expsordd) inz(*EXTDFT)
     D rhrec         E ds                  extname(rtehed) inz(*EXTDFT)
     D ohrec         E ds                  extname(ordh) inz(*EXTDFT)
     D odrec         E ds                  extname(ordd) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D batId           s             11
     D cmd             s           3000    varying
     D expRecIdA       s             11
     D recId           s             11p 0
     D rtnCode         s             10
     D rtnMessage      s            200
     D setsReturned    s               n
     D uRunType        s              1
     D uType           s             10
     D whse3A          s              3
     D whse3s          s              3s 0
     D wwMsgKey        s              4A

     *----------------------------------------------------------------
     *  Return parameter result set
     *----------------------------------------------------------------

     D pgmStatus       ds                  occurs(1)
     D  sReturn                      10
     D  sMessage                    200

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';

         // Translate input into upper case.

         uType = %xlate(xlower: xupper: pType);
         uRunType = %xlate(xlower: xupper: pRunType);

         // Convert warehouse to alpha and Signed

         whse3A = %trim(%char(pWhse));
         whse3S = pWhse;

         // Verify run type

         if uRunType <> 'S';
              pReturn  = '*INVLDRTYP';
              pMessage = 'Invalid run type sent (' + uRunType + '). '
                       + 'Valid types are S=Result Set ';
              return;
         endif;

         // Run program

         select;
           when uRunType = 'S';
             exsr runInteractiveSets;

             if not setsReturned;
               sReturn = pReturn;
               sMessage = pMessage;
               exec sql
                 set result sets with return to client
                     array :pgmStatus for 1 rows;
             endif;

         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         pReturn = 'U:' + #status;
         pMessage = 'U:'
                  + %trim(#pgm)
                  + '('
                  + %trim(%editc(#stmt:'Z'))
                  + ')-'
                  + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  runInteractiveSets  Run program interactively returning sets
     *----------------------------------------------------------------

      /free
       begsr runInteractiveSets;

         setsReturned = *off;

         // Get batch id for this export.

           monitor;
             GetRecId(whse3S: 'DKTEXPORT': RecId);
           on-error;
             pReturn  = '*ERRGETID';
             pMessage = 'Error calling GetRecId '
                      + 'from CBIPROTO ';
             leavesr;
           endmon;

         expRecIdA = %trim(%char(recId));

         // Create EXPSORDL records.

           if pType <> '*ORDH';
             exsr zzzWriteORDL;
             if pReturn <> '*OK';
               leavesr;
             endif;
           endif;

         // Create EXPSORDH records.

           if pType = '*ORDH' or pType = '*ALL';
             exsr zzzWriteORDH;
             if pReturn <> '*OK';
               leavesr;
             endif;
           endif;

         // Now mark all batch records that are Ready for export.

         sqlstmt = 'update stgbatch '
                 + 'set sbexpid=' + sq + expRecIdA + sq + ', '
                 +     'sbstatus=' + sq + 'P' + sq + ' '
                 + 'where sbstatus=' + sq + 'R' + sq  + ' '
                 +   'and sbtype like(' + sq + 'EXP%' + sq + ') ';

          exec sql prepare sel from :sqlstmt;
          exec sql execute sel;

          if sqlstt <> sqlSuccess;
            pReturn  = '*SQLERR1';
            pMessage = 'SQL Error occured in CBIPROTO - '
                     + 'SQLSTT ' + sqlstt;
            leavesr;
          endif;

         // Create result set for STGBATCH.

         exec sql
           declare setSTGBATCH cursor for
           select *
             from stgbatch
             where sbexpid = :expRecIdA;

         // Create result set for EXPSORDL.

         exec sql
           declare setEXPSORDL cursor for
           select *
             from expsordl
             where oelbatid in
                (select sbbatid from stgbatch
                  where sbexpid = :expRecIdA);

         // Create result set for EXPSORDH.

         exec sql
           declare setEXPSORDH cursor for
           select *
             from expsordh
             where oehbatid in
                (select sbbatid from stgbatch
                  where sbexpid = :expRecIdA);

         // Create result set for EXPSORDD.

         exec sql
           declare setEXPSORDD cursor for
           select *
             from expsordd
             where oedbatid in
                (select sbbatid from stgbatch
                  where sbexpid = :expRecIdA);

         // Open result set cursors

         exec sql open setSTGBATCH;
         exec sql open setEXPSORDL;
         exec sql open setEXPSORDH;
         exec sql open setEXPSORDD;

         // Return result sets

         setsReturned = *on;
         sReturn = pReturn;
         sMessage = pMessage;

         exec sql
           set result sets with return to client
               array :pgmStatus for 1 rows,
               cursor setSTGBATCH,
               cursor setEXPSORDH,
640aA          cursor setEXPSORDD,
               cursor setEXPSORDL;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  zzzWriteORDH   Write EXPSORDH records
640aA*----------------------------------------------------------------
640aA
      /free
       begsr zzzWriteORDH;

        for i = 1 to 2;

          exsr zzzGetBatIdEXPROUTE;
          if pReturn <> '*OK';
            leavesr;
          endif;

          if i = 1;
            SqlStmt = 'select * from ordh '
                    + 'where ohrte = ' + sq + '00001' + sq;
          else;
            SqlStmt = 'select * from ordh '
                    + 'where ohrte = ' + sq + '00002' + sq;
          endif;

          exec sql prepare stmtORDH from :SqlStmt;
          exec sql declare csrORDH cursor for stmtORDH;
          exec sql open csrORDH;

          dow forever = forever;

            exec sql fetch next from csrORDH
                     into :ohrec;

            if sqlstt <> sqlSuccess;
              leave;
            endif;

            exec sql select rhrte into :rhrte
                       from rtehed
                      where rhwhse = :ohwhse and rhrtid = :ohrte;

            if sqlstt <> sqlSuccess;
              rhrte = ' ';
            endif;

            oehwhs = ohwhse;
            oehbatid = batId;
            oehrte   = rhrte;
            oehord   = ohcord;
            oehstatus = 'R';
            oehtext = '';
            oehrteid = ohrte;
            oehordid = ohord;
            oehtyp   = ohtype;
            oehcus   = ohcust;
            oehcpo   = ohcpo;
            oehcnm   = ohcnam;
            oehca1   = ohcad1;
            oehca2   = ohcad2;
            oehcct   = ohccty;
            oehcst   = ohcst;
            oehczp   = ohczip;
            oehstp   = ohstop;
            oehtrk   = ohtruk;
            oehmsc   = ohmisc;

           exec sql insert into expsordh
                    (oehwhs, oehbatid, oehrte, oehord,
                     oehstatus, oehststs, oehstsuc, oehtext,
                     oehrteid, oehordid, oehtyp, oehcus, oehcpo, oehcnm,
                     oehca1, oehca2, oehcct, oehcst,oehczp, oehstp,
                     oehtrk, oehmsc, oehaddts, oehadduc)
                    values(:oehwhs, :oehbatid, :oehrte, :oehord, :oehstatus,
                           current_timestamp,
                           current_timestamp - current_timezone,
                           :oehtext, :oehrteid, :oehordid, :oehtyp, :oehcus,
                           :oehcpo, :oehcnm, :oehca1, :oehca2, :oehcct,
                           :oehcst, :oehczp, :oehstp, :oehtrk, :oehmsc,
                           current_timestamp,
                           current_timestamp - current_timezone);

            if sqlstt <> sqlSuccess;
              pReturn  = 'INSERTERR2';
              pMessage = 'Error inserting order id ' + %char(ohord) + ' '
                       + 'into EXPSORDH in CBIPROTO - '
                       + 'SQLSTT ' + sqlstt;
              leave;
            endif;

            exsr zzzWriteORDD;

          enddo;

          exec sql close csrORDH;

        endfor;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  zzzWriteORDD   Write EXPSORDD records
640aA*----------------------------------------------------------------
640aA
      /free
       begsr zzzWriteORDD;

          SqlStmt = 'select * from ordd '
                  + 'where odwhse=' + %char(ohwhse) + ' '
                  + 'and odord=' + %char(ohord);

          exec sql prepare stmtORDD from :SqlStmt;
          exec sql declare csrORDD cursor for stmtORDD;
          exec sql open csrORDD;

          dow forever = forever;

            exec sql fetch next from csrORDD
                     into :odrec;

            if sqlstt <> sqlSuccess;
              leave;
            endif;

            oedwhs = odwhse;
            oedbatid = batId;
            oedrte   = rhrte;
            oedord   = ohcord;
            oedseq   = odseq;
            oeditm   = oditem;
            oedstatus = 'R';
            oedtext = '';
            oedrteid = ohrte;
            oedordid = ohord;
            oedq1    = odqor1;
            oedq2    = odqor2;
            oedq3    = odqor3;
            oedwh2   = odwh2;
            oedor2   = odor2;
            oedoit   = odoitm;
            oedspc   = odspcl;
            oedqp1   = odqpk1;
            oedqp2   = odqpk2;
            oedqp3   = odqpk3;

           exec sql insert into expsordd
                    (oedwhs, oedbatid, oedrte, oedord,
                     oedseq, oeditm,
                     oedstatus, oedststs, oedstsuc, oedtext,
                     oedrteid, oedordid, oedq1, oedq2, oedq3, oedwh2,
                     oedor2, oedoit, oedspc, oedqp1, oedqp2, oedqp3,
                     oedaddts, oedadduc)
                    values(:oedwhs, :oedbatid, :oedrte, :oedord, :oedseq,
                           :oeditm,:oedstatus,
                           current_timestamp,
                           current_timestamp - current_timezone,
                           :oehtext, :oehrteid, :oehordid, :oedq1, :oedq2,
                           :oedq3, :oedwh2, :oedor2, :oedoit, :oedspc,
                           :oedqp1, :oedqp2, :oedqp3,
                           current_timestamp,
                           current_timestamp - current_timezone);

            if sqlstt <> sqlSuccess;
              pReturn  = 'INSERTERR3';
              pMessage = 'Error inserting order id ' + %char(ohord) + ' '
                       + 'seq ' + %char(odseq) + ' '
                       + 'item ' + %trim(oditem) + ' '
                       + 'into EXPSORDD in CBIPROTO - '
                       + 'SQLSTT ' + sqlstt;
              leave;
            endif;

          enddo;

          exec sql close csrORDD;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  zzzWriteORDL   Write EXPSORDL records
640aA*----------------------------------------------------------------
640aA
      /free
       begsr zzzWriteORDL;

        for i = 1 to 2;

          exsr zzzGetBatIdEXPSELTRAN;
          if pReturn <> '*OK';
            leavesr;
          endif;

          if i = 1;
            SqlStmt = 'select * from label '
                    + 'where lbtrn# = 2001 ';
          else;
            SqlStmt = 'select * from label '
                    + 'where lbtrn# = 2002 ';
          endif;

          exec sql prepare stmtORDL from :SqlStmt;
          exec sql declare csrORDL cursor for stmtORDL;
          exec sql open csrORDL;

          dow forever = forever;

            exec sql fetch next from csrORDL
                     into :lbrec;

            if sqlstt <> sqlSuccess;
              leave;
            endif;

            exec sql select rhrte into :rhrte
                       from rtehed
                      where rhwhse = :lbwhse and rhrtid = :lbrte;

            if sqlstt <> sqlSuccess;
              rhrte = ' ';
            endif;

            exec sql select ohcord into :ohcord
                       from ordh
                      where ohwhse = :lbwhse and ohord = :lbord;

            if sqlstt <> sqlSuccess;
              ohord = 0;
            endif;

            oelwhs = lbwhse;
            oelbatid = batId;
            oelrte = rhrte;
            oelord = ohord;
            oelseq = lbseq;
            oelitm = lbitem;
            oellbl = lblbl#;
            oelstatus = 'R';
            oeltext = '';
            oelrteid = lbrte;
            oelordid = lbord;
            select;
              when lbutyp = '2';
                oelqp3 = lbqpck;
              when lbutyp = '1';
                oelqp2 = lbqpck;
              other;
                oelqp1 = lbqpck;
            endsl;
            oeltyp   = lbtype;
            oeldsp   = lbdisp;
            oelpal   = lbpal#;
            oeltrn   = lbtrn#;
            oelumt   = lbutyp;
            oelalc   = lbqalc;
            oelbox   = 0;
            oelemp   = 0;

           exec sql insert into expsordl
                    (oelwhs, oelbatid, oelrte, oelord, oelseq, oelitm,
                     oellbl, oelstatus, oelststs, oelstsuc, oeltext,
                     oelrteid, oelordid, oelqp1, oelqp2, oelqp3, oeltyp,
                     oeldsp, oelpal, oeltrn, oelumt,oelalc, oelbox,
                     oelemp, oeladdts, oeladduc)
                    values(:oelwhs, :oelbatid, :oelrte, :oelord, :oelseq,
                           :oelitm, :oellbl, :oelstatus,
                           current_timestamp,
                           current_timestamp - current_timezone,
                           :oeltext, :oelrteid, :oelordid, :oelqp1, :oelqp2,
                           :oelqp3, :oeltyp, :oeldsp, :oelpal, :oeltrn,
                           :oelumt, :oelalc, :oelbox, :oelemp,
                           current_timestamp,
                           current_timestamp - current_timezone);

            if sqlstt <> sqlSuccess;
              pReturn  = 'INSERTERR1';
              pMessage = 'Error inserting label ' + %char(lblbl#) + ' '
                       + 'into EXPSORDL in CBIPROTO - '
                       + 'SQLSTT ' + sqlstt;
              leave;
            endif;

          enddo;

          exec sql close csrORDL;

        endfor;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  zzzGetBatIdEXPROUTE   Get batch id for EXPROUTE
640aA*----------------------------------------------------------------
640aA
      /free
       begsr zzzGetBatIdEXPROUTE;

        monitor;
          GetBatId(pWhse: 'EXPROUTE': 'R':
                   batId: rtnCode: rtnMessage);
        on-error;
          pReturn  = '*ERRGETBAT1';
          pMessage = 'Error calling GetBatId in CBIPROTO';
          leavesr;
        endmon;
        if rtnCode <> '*OK';
          pReturn  = '*ERRGETBAT2';
          pMessage = 'Error returned from GetBatId in CBIPROTO - '
                   + %trim(rtnCode) + ': ' + %trim(rtnMessage);
          leavesr;
        endif;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  zzzGetBatIdEXPSELTRAN  Get batch id for EXPSELTRAN
640aA*----------------------------------------------------------------
640aA
      /free
       begsr zzzGetBatIdEXPSELTRAN;

        monitor;
          GetBatId(pWhse: 'EXPSELTRAN': 'R':
                   batId: rtnCode: rtnMessage);
        on-error;
          pReturn  = '*ERRGETBAT3';
          pMessage = 'Error calling GetBatId in CBIPROTO';
          leavesr;
        endmon;
        if rtnCode <> '*OK';
          pReturn  = '*ERRGETBAT4';
          pMessage = 'Error returned from GetBatId in CBIPROTO - '
                   + %trim(rtnCode) + ': ' + %trim(rtnMessage);
          leavesr;
        endif;

       endsr;
      /end-free
