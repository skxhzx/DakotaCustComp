      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM010  Update SUM010 file
     *             Used by Drop Pick Analysis Report
     *
     *  21 Nov 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    11/21/19  KDE  7.30
     *      - Created.
740 A*    04/03/20  KDE  7.40
     *      - Change slot status to A from DP
     *
740aA*    05/07/20  KDE  7.40a
     *      - Change slot status to DP from A
     *
750 A*    08/20/21  KDE  7.50
     *      - Correct sql because missing item when only drop pick slot
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum010    uf a e           k disk
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

730hA*----------------------------------------------------------
730hA*  SQL record layouts referenced
730hA*----------------------------------------------------------

730hAD slrecdd       E Ds                  Extname(Slot) prefix(s_)

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

     d cmpItem         s             15
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
     d wktype          s              1
750 Ad wkpick          s              1

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pWhse          s              3p 0
     d  pWhdp          s              5
     d  pItem          s             15
     d  pstyp          s              1

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
     *      pItem       Item
     *      pStyp       Section Type
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
     c                   parm                    pItem
     c                   parm                    pStyp

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
     D sltcnt          s              5  0

      /free

        // Make sure Drop Pick slots exist before going further
        exec sql select count(*) into :sltcnt
740aM             from slot where sldesg='*DROP' and slstat='DP';
        if sqlstt <> '00000' or sltcnt=0;
          pErrmsg = 'No Drop Pick Slots Defined';
          return;
        endif;

        SqlStmt = 'select '
                +   'itwhse, '
                +   'itwhdp, ititem, itdesc, itstyp, itum1, itum2, '
                +   'itumq2, itum3, itumq3, ittype '
                + 'from piritem ';
750 A   // Where clause is set to pull all item that have no pick slot and
750 A   // available inventory, or a pick slot with a drop pick slot as well.
750 A   // The reason we pull items with a pick slot and drop pick slot is to
750 A   // present easily on this report so the user can cleanup.  You should
750 A   // not have both, but if a drop pick slot is created and then a pick
750 A   // slot it creates this issue.  We should also look at not allowing a
750 A   // pick slot to be created if a drop pick slot already exists.  It would
750 A   // need to be removed to proceed.
750 M   sqlWheres = 'where (itdesg=' + sq + sq + ' or itdesg=' + sq + '*DROP'
750 A           +   sq + ') and '
750 M           +   '(((select count(*) from slot where slwhse=itwhse'
                +   ' and slwhdp=itwhdp and slitem=ititem'
                +   ' and slpick=' + sq + 'Y' + sq + ')=0 or  '
750 A           +   '((select count(*) from slot where slwhse=itwhse'
750 A           +   ' and slwhdp=itwhdp and slitem=ititem'
750 A           +   ' and slpick=' + sq + 'Y' + sq + ')>0 and '
750 A           +   ' (select count(*) from slot as c where'
750 A           +   ' c.slwhse=itwhse and c.slwhdp=itwhdp and'
750 A           +   ' c.slitem=ititem and c.slpick=' + sq + 'N' + sq
750 A           +   ' and c.slstat=' + sq + 'DP' + sq
750 A           +   ' and (c.slstk1<>0 or c.slstk2<>0 or c.slstk3<>0))>0))) '
                +   'and ((select count(*) from slot as b where b.slwhse=itwhse'
                +   ' and b.slwhdp=itwhdp and b.slitem=ititem'
                +   ' and b.slpick=' + sq + 'N' + sq
                +   ' and b.slstat=' + sq + 'A' + sq
                +   ' and (b.slstk1<>0 or b.slstk2<>0 or b.slstk3<>0))>0'
750 A           +   ' or (select count(*) from slot as c where'
750 A           +   ' c.slwhse=itwhse and c.slwhdp=itwhdp and'
750 A           +   ' c.slitem=ititem and c.slpick=' + sq + 'N' + sq
750 A           +   ' and c.slstat=' + sq + 'DP' + sq
750 A           +   ' and (c.slstk1<>0 or c.slstk2<>0 or c.slstk3<>0))>0)';

        // Additional selections
        // Department
        if pwhdp <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and itwhdp=' + sq + %trim(pwhdp) +
                           sq;
        endif;

        // Item
        if pItem <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ititem=' + sq + pItem
                      + sq;
        endif;

        // Section
        //if pStyp <> *blanks;
        //   sqlWheres = %trim(sqlWheres) + ' and itstyp<=' + sq + pstyp
        //              + sq;
        //endif;

        sqlStmt = %trim(sqlStmt) + ' ' + %trim(sqlWheres);

        exec sql prepare itmStmt from :SqlStmt;
        exec sql declare itmCsr cursor for itmStmt;
        exec sql open itmCsr;

        dow forever = forever;

          exec sql fetch next from itmCsr
                   into :smwhse, :smwhdp, :smitem, :smdesc, :smstyp, :smum1,
                        :smum2, :smumq2, :smum3, :smumq3, :wktype;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // get Pick and Overflow slot information
          smcpck=*blanks;
          smcovf=*blanks;
          smcqty=*zeros;
          smbqty=*zeros;

          cmpItem=smitem;
          //  If Contract, Alias or SSB item
          //   Then get Base Slot item.
          //
          if wktype = 'A'  or
             wktype = 'C'  or
             wktype = 'S';
      /end-free
     c                   call      'GETSLOTITM'
     c                   parm      smwhse        $gwhse            3 0
     c                   parm      smitem        $gitem           15
     c                   parm      ' '           #sitem           15
     c                   parm                    #sityp            1
     c                   parm                    #sdesc           30
     c                   parm                    #spdsc           15
     c                   parm                    #srtn            10
     c                   parm                    #smsg            60
      /free
             cmpItem=#sitem;
             exec sql select count(*) into :sltcnt
                             from slot where slwhse=:itwhse
                         and slwhdp=:itwhdp
                         and slitem=:cmpItem
                         and slpick='Y';
             if sltCnt=0;
                // if parent has a pick slot then skip
                iter;
             endif;
          endif;

          // Get Slot pick and overflow information to put on print line
          sqlstmt = 'Select *' +
                    ' from slot where slwhse=' + %char(smwhse) +
                    ' and slitem = ' + sq + %trim(cmpItem) + sq +
                    ' and slstat <> ' + sq + 'Z' + sq +
                    ' order by slwhse,slitem,slrlvl,sldisp';
          exec sql prepare sltStmt from :SqlStmt;
          exec sql declare sltCsr cursor for sltStmt;
          exec sql open sltCsr;

          dow forever = forever;
             exec sql fetch next from sltCsr
                       into :slrecdd;
             if sqlstt <> sqlSuccess and sqlstt<>'22018';
                leave;
             endif;

             if s_sldesg = '*DROP';
                if %trim(smcpck)<>'';
                  smcpck = %trim(smcpck) + ', ' + %trim(s_sldisp);
                else;
                  smcpck = %trim(s_sldisp);
                endif;
             else;
                if %trim(smcovf)<>'';
                  smcovf = %trim(smcovf) + ', ' + %trim(s_sldisp);
                else;
750 A             wkpick=*blanks;
750 A             exec sql select slpick into :wkpick
750 A                           from slot
750 A              where slwhse=:smwhse and slwhdp=:smwhdp and slitem=:smitem
750 A                and slpick='Y' and slstat='A' fetch first row only;
750 A              if wkpick = 'Y';
750 A                smcovf = 'PICKSLOT, ' + %trim(s_sldisp);
750 A              else;
750 A                smcovf = %trim(s_sldisp);
750 A              endif;
                endif;
             endif;
          enddo;
          exec sql close sltCsr;

          smbasd=0;
          exec sql select count(*) into :smbasd
740aD               //from slot where sldesg='*DROP' and slstat='A '
740aM               from slot where sldesg='*DROP' and slstat='DP'
                     and slwhdp=:smwhdp and (select count(*) from
                     vslot where slwhse=vswhse and slwhdp=vswhdp
                     and sldisp=vsdisp)=0;

          smsessid = pSessid;
          smaddts = %timestamp();

          if ittype='S' or ittype='A';
             smitem=cmpItem;
          endif;

          write smrec;

        enddo;

        exec sql close itmCsr;

      /end-free


     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum010
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e
