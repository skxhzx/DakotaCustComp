      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R19500     Build workfile for Slots with no Inventory Count
     *
     *  13 September 2016
     *  Lynn McMahon
     *
     *  Revisions
     *
700 A*    09/13/16  LMC  7.00
     *      - Created.
710aA*  03/23/17  LMC  7.10a
     *    - Enh: Database change to INVHSTD. Recompile only.
710bA*  12/22/17  LMC  7.10b
     *    - Enh: Database change to INVHSTD. Recompile only.
730aA*  08/20/19  LMC  7.30a
     *    - Enh: Added RTC to this program so it can handle both
     *      batch and Real time cycle counts.
750 A*  05/24/21  KDE  7.50
     *    - Enh: Added session id to both INVHSTDWK and RTCHSTDWK
     *      to prevent duplicates.  Only requires recompile
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Finvhstdwk uf a e           k disk
730aAFrtchstdwk uf a e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

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
     *  Time variables
     *----------------------------------------------------------------
     D frdatestamp     s               z
     D todatestamp     s               z
     D w1fdatwork      s              6  0
     D w1tdatwork      s              6  0
     D w1f             s              6
     D w1t             s              6
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D icdrec        E ds                  extname(invhstd) inz(*EXTDFT)
730aAD rtcdrec       E ds                  extname(rtchstd) inz(*EXTDFT)


     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pDict          s             10
     d  pPgm           s             10
     d  pWhse          s              3p 0
     d  pFromDate      s             10
     d  pToDate        s             10

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------


     d AddRecs         pr
730aAd AddRecsRTC      pr
     d DeleteRecs      pr
730aAd DeleteRecsRTC   pr

     d WriteRec        pr
730aAd WriteRecRTC     pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pFromDate   From Date
     *      pToDate     To Date
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pFromDate
     c                   parm                    pToDate

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';
         // setup date fields
         w1f = %subst(pfromdate:3:6);
         w1t = %subst(ptodate:3:6);
         w1fdatwork = %dec(w1f:6:0);
         w1tdatwork = %dec(w1t:6:0);
         frdatestamp = %timestamp(
              %char(%date(w1fdatwork:*YMD)) + '-' +
              '00.00.00' + '.000000');

         todatestamp = %timestamp(
              %char(%date(w1tdatwork:*YMD)) + '-' +
              '23.59.59' + '.999999');

730aA    if %subst(ppgm:1:4) = 'M213';
           // Delete existing records for session id

           DeleteRecs();

           // Add records

           AddRecs();

730aA    else;
730aA      // Delete existing records for session id

730aA      DeleteRecsRTC();

730aA      // Add records

730aA      AddRecsRTC();

730aA    endif;
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


      /free

        SqlStmt = 'select *'
                + 'from invhstd '
                + 'where '
                +   'icdslcnt = ' + sq + 'Y' + sq + ' '
                +   ' and icdsltts >= ' +  sq + %char(frdatestamp) + sq
                +   ' and icdsltts <= ' +  sq + %char(todatestamp) + sq
                +   ' order by icdsltts ';

        exec sql prepare invStmt from :SqlStmt;
        exec sql declare invCsr cursor for invStmt;
        exec sql open invCsr;

        dow forever = forever;

          exec sql fetch next from invCsr
                   into :icdrec;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;
        smsessid = pSessId;
        write icdrecwk;

        enddo;

        exec sql close invCsr;

      /end-free

     p AddRecs         e


730aA*----------------------------------------------------------------
730aA*  AddRecsRTC   Add records
730aA*----------------------------------------------------------------

730aAp AddRecsRTC      b
730aAd AddRecsRTC      pi

730aA*  Local Variables


730aA /free

730aA   SqlStmt = 'select *'
730aA           + 'from rtchstd '
730aA           + 'where '
730aA           +   'rtcdslcnt = ' + sq + 'Y' + sq + ' '
730aA           +   ' and rtcdsltts >= ' +  sq + %char(frdatestamp) + sq
730aA           +   ' and rtcdsltts <= ' +  sq + %char(todatestamp) + sq
730aA           +   ' order by rtcdsltts ';

730aA   exec sql prepare rtcStmt from :SqlStmt;
730aA   exec sql declare rtcCsr cursor for rtcStmt;
730aA   exec sql open rtcCsr;

730aA   dow forever = forever;

730aA     exec sql fetch next from rtcCsr
730aA              into :rtcdrec;

730aA     if sqlstt = sqlNoMoreData;
730aA       leave;
730aA     endif;
730aA   smsessid = pSessId;
730aA   write rtcdrecwk;

730aA   enddo;

730aA   exec sql close rtcCsr;

730aA /end-free

730aAp AddRecsRTC      e


     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from invhstdwk
                 where smsessid = :pSessId;

      /end-free

     p DeleteRecs      e

730aA*----------------------------------------------------------------
730aA*  DeleteRecsRTC    Delete records for session id
730aA*----------------------------------------------------------------

730aAp DeleteRecsRTC   b
730aAd DeleteRecsRTC   pi

730aA /free

730aA   exec sql delete from rtchstdwk
730aA            where smsessid = :pSessId;

730aA /end-free

730aAp DeleteRecsRTC   e

