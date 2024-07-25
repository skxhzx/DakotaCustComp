      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM007  Update SUM007 file
     *             Used by Multiple Letdown/Repl by Slot
     *
     *  26 June 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    06/26/19  KDE  7.30
     *      - Created.
730aA*    07/19/19  KDE  7.30a
     *      - Setup for Date range to go off Shift Date
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum007    uf a e           k disk
     fpirItem   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

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

     d frmtnmCmd       s              8
     d inclIdle        s              1

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pWhse          s              3p 0
     d  pWhdp          s              5
     d  pnumrplns      s              3  0
     d  pfrmAisl       s              3
     d  ptoAisl        s              3
     d  pfrmloc        s              3  0
     d  ptoloc         s              3  0
     d  pCrew          s              6
     d  pShft          s              6
     d  pTask          s              6
     d  pfrmDate       s              8  0
     d  ptoDate        s              8  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
     d DeleteRecs      pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pErrMsg     Error Message
     *      pSessId     Session Id
     *      pWhse       Warehouse
     *      pWhdp       Warehouse Dept
     *      pnumrplns   Min. number of replenishments
     *      pFrmAisl    From Aisle
     *      pToAisl     To Aisle
     *      pFrmLoc     From Location
     *      pToLoc      To Location
     *      pCrew       Crew
     *      pShft       Shift
     *      pTask       Task
     *      pFrmDate    From Date
     *      pToDate     To Date
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pWhdp
     c                   parm                    pnumrplns
     c                   parm                    pfrmAisl
     c                   parm                    ptoAisl
     c                   parm                    pfrmLoc
     c                   parm                    ptoLoc
     c                   parm                    pCrew
     c                   parm                    pShft
     c                   parm                    pTask
     c                   parm                    pfrmDate
     c                   parm                    pToDate

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add work records for Report Slots w/No Activity
        AddRecs();

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     D wkITem          s             15
     D wksdte          s              8  0
     d wkStyp          s              1
     d wkAisl          s              3
     d wkPick          s              1

      /free

        SqlStmt = 'select '
                +   'ptwhse, pttrn#, lbdsp2, lbdisp, lbqpck, lbucod, '
                +   'ptsdte, ptstim, ptedte, ptetim, pttask, ptdmin, ptemp#, '
                +   'lbitem '
                + 'from pirtran, label';
        sqlWheres = 'where '
                +   'ptwhse=lbwhse and pttrn#=lbtrn# and ptwhse='
                +   %char(pWhse) + ' and ptgrp1=' + sq + 'L' + sq
730aD      //   +   ' and lbqpck>0;
730aM           +   ' and lbqpck>0 and '
730aA           +   '(select ptdshftday from pirtrand where'
730aA           +   ' pttrn#=ptdtran and ptgdte=ptdgdte and'
730aA           +   ' ptgtim=ptdgtim and ptwhse=ptdwhse'
730aA           +   ' fetch first row only)>='
730aA           +   %subst(%char(pfrmDate):3:6) + ' and '
730aA           +   '(select ptdshftday from pirtrand where'
730aA           +   ' pttrn#=ptdtran and ptgdte=ptdgdte and'
730aA           +   ' ptgtim=ptdgtim and ptwhse=ptdwhse'
730aA           +   ' fetch first row only)<='
730aA           +   %subst(%char(ptoDate):3:6);

        // Additional selections
        // Department
        if pwhdp <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and lbwhdp=' + sq + %trim(pwhdp) +
                           sq;
        endif;

        // From Aisle
        if pfrmAisl <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and lbaisl>=' + sq + pfrmAisl
                      + sq;
        endif;

        // To Aisle
        if ptoAisl <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and lbaisl<=' + sq + ptoAisl
                      + sq;
        endif;

        // From Location
        if pfrmLoc <> *zeros;
           sqlWheres = %trim(sqlWheres) + ' and lbloc>=' + %char(pfrmloc);
        endif;

        if ptoLoc <> *zeros;
           sqlWheres = %trim(sqlWheres) + ' and lbloc<=' + %char(ptoloc);
        endif;

        // Crew
        if pCrew <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptcrew=' + sq + %trim(pCrew)
                      + sq;
        endif;

        // To Shift
        if pShft <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptshft=' + sq + %trim(pshft)
                      + sq;
        endif;

        // Task
        if pTask <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and pttask=' + sq + %trim(ptask)
                      + sq;
        endif;

730aD   // From Date
730aD   //if pfrmDate <> *zeros;
730aD   //   sqlWheres = %trim(sqlWheres) + ' and ptgdte>=' + %char(pfrmDate);
730aD   //endif;

730aD   //if ptoDate <> *zeros;
730aD   //   sqlWheres = %trim(sqlWheres) + ' and ptgdte<=' + %char(ptoDate);
730aD   //endif;

        sqlStmt = %trim(sqlStmt) + ' ' + %trim(sqlWheres);

        exec sql prepare trnStmt from :SqlStmt;
        exec sql declare trnCsr cursor for trnStmt;
        exec sql open trnCsr;

        dow forever = forever;

          exec sql fetch next from trnCsr
                   into :smwhse, :smtran, :smToSlot, :smfrmSlot, :smqpck,
                        :smucod, :smsdte, :smstim, :smedte, :smetim, :smtask,
                        :smdmin, :smemp#, :smitem;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

          smsessid = pSessid;
          smaddts = %timestamp();

          // get item description and pack description
          chain (smwhse:smitem) piritem;
          if %found(piritem);
             smdesc = itdesc;
             smpdsc = itpdsc;
          else;
             smdesc=*blanks;
             smpdsc=*blanks;
          endif;

          write smrec;

        enddo;

        exec sql close trnCsr;

        if pnumrplns>1;
        sqlStmt = 'select smtoslot ' +
                  'from sum007 where smsessid=' + sq + %trim(psessid) + sq +
                  ' group by smtoslot ' +
                  'having count(*) < ' + %char(pnumrplns);

        exec sql prepare trndelt from :SqlStmt;
        exec sql declare trndel cursor for trndelt;
        exec sql open trnDel;

        dow forever = forever;

          exec sql fetch next from trnDel
                   into :smToSlot;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

          exec sql delete from sum007 where smsessid=:psessid
                           and smtoslot=:smtoslot;

        enddo;

        exec sql close trnDel;
        endif;

      /end-free


     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum007
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e
