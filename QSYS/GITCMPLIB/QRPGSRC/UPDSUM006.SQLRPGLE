      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM006  Update SUM006 file
     *             Used by Slots with no Activity Report
     *
     *  24 June 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    06/24/19  KDE  7.30
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

     Fsum006    uf a e           k disk
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

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pWhse          s              3p 0
     d  pWhdp          s              5
     d  pLabDte        s              8  0
     d  pSltType       s              1
     d  pItmType       s              1
     d  pAisle         s              3
     d  pEmptyOnly     s              1  0

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
     *      pLabDte     Label Status Date
     *      pSltType    Slot Type
     *      pItmType    Item Type
     *      pAisle      Sot Aisle
     *      pEmptyOnly  Empty Slots only
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
     c                   parm                    plabDte
     c                   parm                    pSltType
     c                   parm                    pItmType
     c                   parm                    pAisle
     c                   parm                    pEmptyOnly

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
                +   'slwhse, slwhdp, sldisp, slitem, slpick, slstyp, slaisl, '
                +   '(select max(lbsdte) from label '
                +     'where lbwhse=slwhse and lbwhdp=slwhdp '
                +       'and lbdisp=sldisp) '
                + 'from Slot '
                + 'where '
                +   'slstat <> ' + sq + 'Z' + sq + ' '
                +   'and slstat <> ' + sq + 'V' + sq + ' '
                +   'and slwhse=' + %editc(pwhse:'P') + ' '
                +   'and not exists(select * from label where '
                +   'lbwhse=slwhse and lbwhdp=slwhdp and lbdisp=sldisp '
                +   'and lbsdte >= ' + %editc(pLabDte:'X') + ')';

        exec sql prepare sltStmt from :SqlStmt;
        exec sql declare sltCsr cursor for sltStmt;
        exec sql open sltCsr;

        dow forever = forever;

          smwhse=0;
          smwhdp=*blanks;
          smdisp=*blanks;
          wkItem=*blanks;
          wkSdte=*zeros;

          exec sql fetch next from sltCsr
                   into :smwhse, :smwhdp, :smdisp, :wkItem, :wkpick, :wkstyp,
                        :wkAisl, :wksdte :NullInds;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

          // trap no label date error and place zero in date field
          if NullInds(1) = NullValue;
            wksdte=0;
          endif;

          smsessid = pSessid;
          smaddts = %timestamp();
          smsdte = wksdte;

          // get Item Description
          chain (smwhse:wkItem) piritem;
          if %found(pirItem);
            // if item found and Empty Only sent then skip
            if pEmptyOnly = 1;
              iter;
            endif;
            smItmDesc = %trim(wkitem) + ' : ' + %trim(itDesc);
          else;
            smItmDesc = *blanks;
          endif;

          // Include by Aisle if selected
          if pAisle <> *blanks;
            select;
              when %len(%trim(pAisle)) = 1;
                 if ('  ' + %trim(pAisle)) <> wkAisl;
                   iter;
                 endif;
              when %len(%trim(pAisle)) = 2;
                 if (' ' + %trim(pAisle)) <> wkAisl;
                   iter;
                 endif;
              when %len(%trim(pAisle)) = 3;
                 if %trim(pAisle) <> wkAisl;
                   iter;
                 endif;
            endsl;
          endif;

          // Exclude by Item Type if selected
          if pItmType='P' and wkstyp<>'P';
            iter;
          endif;
          if pItmType='F' and wkstyp<>'F';
            iter;
          endif;

          // Exclude by Slot Type if selected
          if pSltType='P' and wkpick<>'Y';
            iter;
          endif;
          if pSltType='O' and wkpick='Y';
            iter;
          endif;

          // Include only Dept Selected if passed
          if pWhdp<>*blanks and pWhdp<>smWhdp;
            iter;
          endif;

          write smrec;

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

        exec sql delete from sum006
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e
