      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM002   Update SUM002 file
     *  29 September 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650 A*    09/29/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum002    o    e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D rtehed        E ds                  extname(rtehed) inz(*EXTDFT)
     D ordh          E ds                  extname(ordh) inz(*EXTDFT)
     D ordd          E ds                  extname(ordd) inz(*EXTDFT)
     D piritem       E ds                  extname(piritem) inz(*EXTDFT)
     D worklbl       E ds                  extname(worklbl) inz(*EXTDFT)
     D label         E ds                  extname(label) inz(*EXTDFT)
     D pirtran       E ds                  extname(pirtran) inz(*EXTDFT)

     d first           s               n

     d groupStamp      s               z

     d recType         s              3
     d pcs1            s              5p 0
     d pcs2            s              5p 0
     d pcs3            s              5p 0

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pPgm           s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
     d DeleteRecs      pr
     d RteOpen         pr
     d RteBuilt        pr
     d RtePrinted      pr
     d WriteRec        pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pWhse       Warehouse
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pWhse

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add records

         AddRecs();

         return;

      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

      /free

        recType = 'SEL';

        SqlStmt = 'select '
                +   'rhrtid, rhrte, rhtype, rhstat '
                + 'from rtehed '
                + 'where '
                +   'rhwhse = ' + %char(pWhse) + ' '
                +   'and rhstat in (1,2,3,4) ';

        exec sql prepare rteStmt from :SqlStmt;
        exec sql declare rteCsr cursor for rteStmt;
        exec sql open rteCsr;

        dow forever = forever;

          exec sql fetch next from rteCsr
                   into :rhrtid, :rhrte, :rhtype, :rhstat;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          select;
            when rhstat = '1';
              RteOpen();
            when rhstat = '2';
              RteOpen();
            when rhstat = '3';
              RteBuilt();
            when rhstat = '4';
              RtePrinted();
          endsl;

        enddo;

        exec sql close rteCsr;

      /end-free

     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum002
                 where smsessid = :pSessId;

      /end-free

     p DeleteRecs      e

650bA*----------------------------------------------------------------
650bA*  RteOpen    Open route
650bA*----------------------------------------------------------------
650bA
650bAp RteOpen         b
     d RteOpen         pi

      /free

        SqlStmt = 'select '
                +   'itwhdp, sum(odqor1), sum(odqor2), sum(odqor3) '
                + 'from ordh '
                + 'left outer join ordd on odwhse=ohwhse and odord=ohord '
                + 'left outer join piritem on itwhse=odwhse and ititem=oditem '
                + 'where '
                +   'ohwhse= ' + %char(pWhse) + ' '
                +   'and ohrte=' + sq + %trimr(rhrtid) + sq + ' '
                + 'group by itwhdp '
                + 'order by itwhdp ';

        exec sql prepare opnStmt from :SqlStmt;
        exec sql declare opnCsr cursor for opnStmt;
        exec sql open opnCsr;

        dow forever = forever;

          exec sql fetch next from opnCsr
                   into :itwhdp, :pcs1, :pcs2, :pcs3;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          smwhdp = itwhdp;
          smpcsopn = pcs1 + pcs2 + pcs3;
          smpcsttl = pcs1 + pcs2 + pcs3;

          writeRec();

        enddo;

        exec sql close opnCsr;

      /end-free

     p RteOpen         e

650bA*----------------------------------------------------------------
650bA*  RteBuilt   Built route
650bA*----------------------------------------------------------------
650bA
650bAp RteBuilt        b
     d RteBuilt        pi

      /free

        SqlStmt = 'select '
                +   'lwwhdp, lwszon, sum(lwqalc) '
                + 'from worklbl '
                + 'where '
                +   'lwwhse= ' + %char(pWhse) + ' '
                +   'and lwrte=' + sq + %trimr(rhrtid) + sq + ' '
                +   'and lwtype in (''O'',''B'') '
                + 'group by lwwhdp, lwszon '
                + 'order by lwwhdp, lwszon ';

        exec sql prepare bltStmt from :SqlStmt;
        exec sql declare bltCsr cursor for bltStmt;
        exec sql open bltCsr;

        dow forever = forever;

          exec sql fetch next from bltCsr
                   into :lwwhdp, :lwszon, :pcs1;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          smwhdp = lwwhdp;
          smzone = lwszon;
          smpcsblt = pcs1;
          smpcsttl = pcs1;

          writeRec();

        enddo;

        exec sql close bltCsr;

      /end-free

     p RteBuilt        e

650bA*----------------------------------------------------------------
650bA*  RtePrinted    Printed route
650bA*----------------------------------------------------------------
650bA
650bAp RtePrinted      b
     d RtePrinted      pi

      /free

        // Select Open transactions

        SqlStmt = 'select '
                +   'lbwhdp, lwszon, ptstat, sum(lwqpck) '
                + 'from label '
                + 'left outer join pirtran on ptwhse=lbwhse and pttrn#=lbtrn# '
                + 'left outer join worklbl on lwwhse=lbwhse and lwlbl#=lblbl# '
                + 'where '
                +   'lbwhse= ' + %char(pWhse) + ' '
                +   'and lbrte=' + sq + %trimr(rhrtid) + sq + ' '
                +   'and lbtype in (''O'',''B'') '
                +   'and ptstat=''1'' '
                + 'group by lbwhdp, lwszon, ptstat ';

        // Union to Started transactions (only labels not picked through voice)

        SqlStmt = %trimr(sqlstmt) + ' '
                + 'UNION ALL';

        SqlStmt = %trimr(sqlstmt) + ' '
                + 'select '
                +   'lbwhdp, lwszon, ptstat, sum(lwqpck) '
                + 'from label '
                + 'left outer join pirtran on ptwhse=lbwhse and pttrn#=lbtrn# '
                + 'left outer join worklbl on lwwhse=lbwhse and lwlbl#=lblbl# '
                + 'where '
                +   'lbwhse= ' + %char(pWhse) + ' '
                +   'and lbrte=' + sq + %trimr(rhrtid) + sq + ' '
                +   'and lbtype in (''O'',''B'') '
                +   'and ptstat=''2'' '
                +   'and (select count(*) from labeldo '
                +        'where lbolbl#=lblbl#) = 0 '
                + 'group by lbwhdp, lwszon, ptstat ';

        SqlStmt = %trimr(sqlstmt) + ' '
                + 'order by lbwhdp, lwszon, ptstat ';

        exec sql prepare prtStmt from :SqlStmt;
        exec sql declare prtCsr cursor for prtStmt;
        exec sql open prtCsr;

        // Write out records for unique dept/zone combinations

        first = *on;

        dow forever = forever;

          exec sql fetch next from prtCsr
                   into :lwwhdp, :lwszon, :ptstat, :pcs1;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if first;
            first = *off;
            smwhdp = lwwhdp;
            smzone = lwszon;
            smpcspnd = 0;
            smpcsstr = 0;
            smpcsttl = 0;
          endif;

          if lwwhdp <> smwhdp or lwszon <> smzone;
            WriteRec();
            smwhdp = lwwhdp;
            smzone = lwszon;
            smpcspnd = 0;
            smpcsstr = 0;
            smpcsttl = 0;
          endif;

          if ptstat = '1';
            smpcspnd = pcs1;
          else;
            smpcsstr = pcs1;
          endif;

          smpcsttl = pcs1;

        enddo;

        if not first;
          WriteRec();
        endif;

        exec sql close prtCsr;

      /end-free

     p RtePrinted      e

     *----------------------------------------------------------------
     *  WriteRec     Write record
     *----------------------------------------------------------------

     p WriteRec        b
     d WriteRec        pi

      /free

        smsessid  = pSessId;
        smtype    = recType;
        smwhse    = pWhse;
        smrtid    = rhrtid;
        smrte     = rhrte;
        smrtetype = rhtype;
        smrtestat = rhstat;
        smrteseq  = 0;

        write(e) smrec;

        clear smrec;

      /end-free

     p WriteRec        e
