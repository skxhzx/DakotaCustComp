      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM012  Update SUM012 file
     *             Used by Empty Pick w/Overflow Qty
     *
     *  29 May 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*    05/29/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum012    uf a e           k disk
     fpiritem   if   e           k disk
     fslot3     if   e           k disk

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

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     d slrecpk       E Ds                  Extname(Slot) prefix(pk_)

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

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pWhse          s              3p 0
     d  pWhdp          s              5
     d  pFaisl         s              3
     d  pTaisl         s              3

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
     c                   parm                    pFaisl
     c                   parm                    pTaisl

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
        select;
          when %len(%trim(pfaisl))=1;
            pfaisl='  ' + %trim(pfaisl);
          when %len(%trim(pfaisl))=2;
            pfaisl=' ' + %trim(pfaisl);
          other;
            pfaisl=pfaisl;
        endsl;
        select;
          when %len(%trim(ptaisl))=1;
            ptaisl='  ' + %trim(ptaisl);
          when %len(%trim(ptaisl))=2;
            ptaisl=' ' + %trim(ptaisl);
          other;
            ptaisl=ptaisl;
        endsl;
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

      /free

        SqlStmt = 'select '
                +   'a.* '
                + 'from slot as a '
                + 'where a.slwhse=' + %char(pwhse) + ' and a.slpick=' + sq + 'Y'
                + sq + ' and a.slstk1=0 and a.slstk2=0 and a.slstk3=0 and '
                + 'a.slstat=' + sq + 'A' + sq + ' and a.slitem<>' + sq + ' '
                + sq + ' and (select count(*) from slot as b where '
                + 'a.slwhse=b.slwhse and a.slwhdp=b.slwhdp and '
                + 'a.slitem=b.slitem and b.slpick=' + sq + 'N' + sq
                + ' and b.slstat=' + sq + 'A' + sq
                + ' and b.sldesg <>' + sq + 'BFC' + sq + ' and (b.slstk1<>0 '
                + 'or b.slstk2<>0 or b.slstk3<>0))>0';

        // Additional selections
        // Department
        if pwhdp <> *blanks;
           sqlStmt = %trim(sqlStmt) + ' and a.slwhdp=' + sq + %trim(pwhdp) +
                           sq;
        endif;

        // From Aisle
        if pFaisl <> *blanks;
           sqlStmt = %trim(sqlStmt) + ' and a.slaisl>=' + sq + pFaisl
                      + sq;
        endif;

        // To Aisle
        if pTaisl <> *blanks;
           sqlStmt = %trim(sqlStmt) + ' and a.slaisl<=' + sq + pTaisl
                      + sq;
        endif;

        exec sql prepare sltStmt from :SqlStmt;
        exec sql declare sltCsr cursor for sltStmt;
        exec sql open sltCsr;

        dow forever = forever;

          exec sql fetch next from sltCsr
                   into :slrecpk;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // ensure item master record exist and fixed
          chain (pk_slwhse:pk_slitem) piritem;
          if not %found(piritem);
            iter;
          else;
            if itstyp<>'F';
              iter;
            endif;
          endif;

          // write Empty Pick Slot first
          smsessid=pSessid;
          smwhse=pk_slwhse;
          smwhdp=pk_slwhdp;
          smitem=pk_slitem;
          smdisp=pk_sldisp;
          smpick='Y';
          smdesc=itdesc;
          smstyp=itstyp;
          smstk1=pk_slstk1;
          smstk2=pk_slstk2;
          smstk3=pk_slstk3;
          if pk_slentd<>0;
            smentd=%subst(%editc(pk_slentd:'X'):5:2) + '/' +
                   %subst(%editc(pk_slentd:'X'):7:2) + '/' +
                   %subst(%editc(pk_slentd:'X'):3:2);
          else;
            smentd=*blanks;
          endif;
          if pk_slexpd<>0;
            smexpd=%subst(%editc(pk_slexpd:'X'):5:2) + '/' +
                   %subst(%editc(pk_slexpd:'X'):7:2) + '/' +
                   %subst(%editc(pk_slexpd:'X'):3:2);
          else;
            smexpd=*blanks;
          endif;
          smaddts=%timestamp();
          write smrec;

          // now loop through overflow slots writing them
          setll (pk_slwhse:pk_slitem:'A':'N') slot3;
          reade (pk_slwhse:pk_slitem:'A':'N') slot3;
          dow %equal(slot3) and not %eof(slot3);
            reade (pk_slwhse:pk_slitem:'A':'N') slot3;
            // write Empty Pick Slot first
            if (slstk1<>0 or slstk2<>0 or slstk3<>0) and sldesg<>'BFC';
              smsessid=pSessid;
              smwhse=slwhse;
              smwhdp=slwhdp;
              smitem=slitem;
              smdisp=sldisp;
              smpick=*blanks;
              smdesc=itdesc;
              smstyp=itstyp;
              smstk1=slstk1;
              smstk2=slstk2;
              smstk3=slstk3;
              if slentd<>0;
                smentd=%subst(%editc(slentd:'X'):5:2) + '/' +
                       %subst(%editc(slentd:'X'):7:2) + '/' +
                       %subst(%editc(slentd:'X'):3:2);
              else;
                smentd=*blanks;
              endif;
              if slexpd<>0;
                smexpd=%subst(%editc(slexpd:'X'):5:2) + '/' +
                       %subst(%editc(slexpd:'X'):7:2) + '/' +
                       %subst(%editc(slexpd:'X'):3:2);
              else;
                smexpd=*blanks;
              endif;
              smaddts=%timestamp();
              write smrec;
            endif;
          enddo;

        enddo;

      /end-free


     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum012
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e
