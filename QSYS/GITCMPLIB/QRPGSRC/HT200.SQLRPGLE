      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HT200     Populate DLYHIT file
     *  20 June 2017
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    06/20/17  DAS  7.10
     *      - Created.
     *
720aA*    03/28/18  DAS  7.20a
     *      - Revised to to write 'zero date' Item record (see notes)
     *
740aA*    09/22/20  DAS  7.40a
     *      - Revised GetStartEnd to handle a found zero date
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *   HTTYPE 'I' has been added to the DLYHIT file. This type will
     *   contain every item record currently in the system on the
     *   date this program is run. All numeric fields will be zero.
     *   The reason for these records are to be able to create a
     *   report that includes zero hits. This would not be necessary
     *   if MRC allowed assigning a selection criteria to the
     *   Left Outer Join statement.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fpirtran   if   e           k disk
     Fpirtrand5 if   e           k disk
     Flabel7    if   e           k disk
     Fwarehs    if   e           k disk
720aAFpiritem   if   e           k disk
     Fdlyhit1   uf a e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  Working variables
     *
     D client          s             10
     D clientloc       s             10
     D error           s               n
     D forever         s               n
     d gEndDay         s              6s 0
     d gStartDay       s              6s 0
     d gLbls1          s                   like(htlbls1)
     d gLbls2          s                   like(htlbls2)
     d gLbls3          s                   like(htlbls3)
     d gQty1           s                   like(htqty1)
     d gQty2           s                   like(htqty2)
     d gQty3           s                   like(htqty3)
     d gItem           s                   like(lbitem)
     d gWhse           s              3s 0

417bA*----------------------------------------------------------------
417bA*  *DLYHIT  -  Daily Slot Hit options
417bA*----------------------------------------------------------------
417bA*
417bA* Fields
417bA*
417bA*    OPHSTR  -  Slot Hit day start time
417bA*    OPHWKS  -  # of weeks history to keep
417bA*
417bA* Data structure
417bA*
417bAD opdata          ds
417bAD  ophstr                 1      6  0
417bAD  ophwks                 7      8  0
417bAD  opten2               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

720aAd CreateZeroRecs  pr

     d GetItem         pr

     d GetOptions      pr

     d GetStartEnd     pr

     d ProcessLabels   pr

     d ProcessTranD    pr

     d UpdateDLYHIT    pr

     d UpdateShftDay   pr

     d ZZDriCop        pr

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.getclien
     D/copy qcopysrc,p.dricop
     D upd710lma       pr                  extpgm('UPD710LMA')
     D  pWhse                         3

     * Main line

      /free
       *inlr = *on;

       GetClient(client: clientLoc);

       dow forever = forever;

         read warehs;
         if %eof(warehs);
           leave;
         endif;

         gWhse = whcode;

720aA    CreateZeroRecs();

         UpdateShftDay();

         GetOptions();

         GetStartEnd();

         If gStartDay > gEndDay;
           leave;
         endif;

         ProcessTranD();

       enddo;

      /end-free

     *----------------------------------------------------------------
     *  CreateZeroRecs  Create zero recs
     *----------------------------------------------------------------

     p CreateZeroRecs  b
     d CreateZeroRecs  pi

      /free

       // First delete all 'I' records

       setll (gWhse: 'I') dlyhit1;
       dow forever = forever;
         reade (gWhse: 'I') dlyhit1;
         if %eof(dlyhit1);
           leave;
         endif;
         delete dlyhit1;
       enddo;

       // Create 'I' record for every item.

       clear htrec;
       httype = 'I';
       htstamp = %timestamp();

       setll (gWhse) piritem;

       dow forever = forever;

         reade (gWhse) piritem;
         if %eof(piritem);
           leave;
         endif;

         htwhse = gWhse;
         htwhdp = itwhdp;
         htitem = ititem;
         htbaseitm = ititem;

         write(e) htrec;

       enddo;

      /end-free

     p CreateZeroRecs  e

     *----------------------------------------------------------------
     *  GetItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi

      /free

       savever# = $itver#;
       clear $item;
       clear $item2;
       $itver# = savever#;

       $itwhse   = lbwhse;
       $ititem   = lbitem;

       $dricommand = '*ITEM';
       $drisubcmd  = '%GETPARENT';
       $drisys2upd = 'D';

       ZZDricop();

       if error = *on;
         $itmitem = $ititem;
       endif;

      /end-free

     p GetItem         e

     *----------------------------------------------------------------
     *  GetOptions  Get options
     *----------------------------------------------------------------

     p GetOptions      b
     d GetOptions      pi

      /free

       chain (gWhse: '*DLYHIT') Options;
       if not %found;
         ophwks = 0;
       endif;

      /end-free

     p GetOptions      e

     *----------------------------------------------------------------
     *  GetStartEnd    Get start/end dates
     *----------------------------------------------------------------

     p GetStartEnd     b
     d GetStartEnd     pi

     * Local Variables

     d endDayDate      s               d
     d endDayDOW       s              1s 0
     d endDaySun       s               d
     d startDayDate    s               d
     d startDaySun     s               d

      /free

       // Calculate End date

       //   We use 2 days before today to ensure everything has been
       //   completed for that date.

       endDayDate = %date() - %days(2);
       gEndDay = %dec(endDayDate:*ymd);

       // Calculate Start date

       // If no records in the file
       // Then calculate based on number of weeks to keep.
       //      Always starting on a Sunday.
       // Otherwise, add 1 to last date in file.
       //      Because of how the End date is calculated, we assume
       //      we captured everything for a date that is in the file.

       setgt (gWhse) dlyhit1;
       readpe (gWhse) dlyhit1;

740aD  //if %eof(dlyhit1);
740aM  if %eof(dlyhit1) or htshftday = 0;
         exec sql set :endDayDOW = dayofweek(:endDayDate);
         endDaySun = endDayDate - %days(endDayDOW-1);
         startDaySun = endDaySun - %days(ophwks*7);
         gStartDay = %dec(startDaySun:*ymd);

       else;
         startDayDate = %date(htshftday:*ymd) + %days(1);
         gStartDay = %dec(startDayDate:*ymd);

       endif;

      /end-free

     p GetStartEnd     e

     *----------------------------------------------------------------
     *  ProcessLabels    Process the Label records for the transaction
     *----------------------------------------------------------------

     p ProcessLabels   b
     d ProcessLabels   pi

     * Local Variables

     d  lastItem       s                   like(lbitem)

      /free

       lastItem = '';
       gLbls1 = 0;
       gLbls2 = 0;
       gLbls3 = 0;
       gQty1  = 0;
       gQty2  = 0;
       gQty3  = 0;

       setll (ptdtran) label7;

       dow forever = forever;

         reade (ptdtran) label7;
         if %eof(label7);
           leave;
         endif;

         // Only want 'O' records, not 'M', 'B' or 'A'.

         if lbtype <> 'O';
           iter;
         endif;

         // When item changes ...

         if lbitem <> lastItem;

           if lastItem <> '';
             gItem = lastItem;
             UpdateDLYHIT();
           endif;

           GetItem();
           lastItem = lbitem;
           gLbls1 = 0;
           gLbls2 = 0;
           gLbls3 = 0;
           gQty1  = 0;
           gQty2  = 0;
           gQty3  = 0;

         endif;

         select;
           when lbutyp = 'N';
             gLbls1 += 1;
             gQty1  += lbqpck;
           when lbutyp = '1';
             gLbls2 += 1;
             gQty2  += lbqpck;
           when lbutyp = '2';
             gLbls3 += 1;
             gQty3  += lbqpck;
         endsl;

       enddo;

       if lastItem <> '';
         gItem = lastItem;
         UpdateDLYHIT();
       endif;

        return;

      /end-free

     p ProcessLabels   e

     *----------------------------------------------------------------
     *  ProcessTranD   Process PIRTRAND records
     *----------------------------------------------------------------

     p ProcessTranD    b
     d ProcessTranD    pi

      /free

       setll (gWhse: gStartDay) pirtrand5;

       dow forever = forever;

         reade (gWhse) pirtrand5;
         if %eof(pirtrand5);
           leave;
         endif;

         // We are done once we past the End day

         if ptdshftday > gEndDay;
           leave;
         endif;

         // Only work with closed transactions

         if ptdstat <> '4';
           iter;
         endif;

         // Ignore non-Selection, non-Replenishment and Bulk Pick transactions

         ptdtran = ptdtran;
         ptdtask = ptdtask;
         if ptdsel <> 1 and ptdbulk <> 1 and ptdrpl <> 1;
           iter;
         endif;

         // Now process the labels for the transaction

         ProcessLabels();

       enddo;

      /end-free

     p ProcessTranD    e

     *----------------------------------------------------------------
     *  UpdateDLYHIT   Update DLYHIT file
     *----------------------------------------------------------------

     p UpdateDLYHIT    b
     d UpdateDLYHIT    pi

     * Local Variables

     d hitType         s              1
     d willcall        s               n

      /free

       // Determine rec type (R=Replenishment, S=Selection)

       select;
         when ptdrpl = 1;
           hitType = 'R';
         when ptdsel = 1;
           hitType = 'S';
         other;
           hitType = 'X';
       endsl;

       // For Selection, see if tran is a Will Call

       if hitType = 'S';
         chain (ptdtran) pirtran;
         if %found(pirtran) and ptgrp2 = 'W';
           willcall = *on;
         else;
           willcall = *off;
         endif;
       endif;

       chain (gWhse: hitType: ptdshftday: $itwhdp: gItem) dlyhit1;

       // Record does not exist - Create

       if not %found(dlyhit1);

         clear htrec;
         htwhse = gWhse;
         httype = hitType;
         htwhdp = $itwhdp;
         htitem = $ititem;
         htbaseitm = $itmitem;
         htshftday = ptdshftday;
         htshftdow = ptdshftdow;
         htshftwk = ptdshftwk;
         htshftsun = ptdshftsun;

         select;

           when hitType = 'S';
             if Willcall;
               htwtrans = 1;
               htwlbls1 = gLbls1;
               htwlbls2 = gLbls2;
               htwlbls3 = gLbls3;
               htwlblst = gLbls1 + gLbls2 + gLbls3;
               htwqty1 = gQty1;
               htwqty2 = gQty2;
               htwqty3 = gQty3;
               htwqtyt = gQty1 + gQty2 + gQty3;
             else;
               httrans = 1;
               htlbls1 = gLbls1;
               htlbls2 = gLbls2;
               htlbls3 = gLbls3;
               htlblst = gLbls1 + gLbls2 + gLbls3;
               htqty1 = gQty1;
               htqty2 = gQty2;
               htqty3 = gQty3;
               htqtyt = gQty1 + gQty2 + gQty3;
             endif;

           when hitType = 'R';
             httrans = 1;
             htlbls1 = gLbls1;
             htlbls2 = gLbls2;
             htlbls3 = gLbls3;
             htlblst = gLbls1 + gLbls2 + gLbls3;
             htqty1 = gQty1;
             htqty2 = gQty2;
             htqty3 = gQty3;
             htqtyt = gQty1 + gQty2 + gQty3;
             htwtrans = 0;
             htwlbls1 = 0;
             htwlbls2 = 0;
             htwlbls3 = 0;
             htwlblst = 0;
             htwqty1 = 0;
             htwqty2 = 0;
             htwqty3 = 0;
             htwqtyt = 0;

           other;
             httrans = 0;
             htlbls1 = 0;
             htlbls2 = 0;
             htlbls3 = 0;
             htlblst = 0;
             htqty1 = 0;
             htqty2 = 0;
             htqty3 = 0;
             htqtyt = 0;
             htwtrans = 0;
             htwlbls1 = 0;
             htwlbls2 = 0;
             htwlbls3 = 0;
             htwlblst = 0;
             htwqty1 = 0;
             htwqty2 = 0;
             htwqty3 = 0;
             htwqtyt = 0;

         endsl;

         htstamp = %timestamp();
         write(e) htrec;

       // Record does exist - Update

       else;

         select;

           when hitType = 'S';
             if willcall;
               htwtrans += 1;
               htwlbls1 += gLbls1;
               htwlbls2 += gLbls2;
               htwlbls3 += gLbls3;
               htwlblst += gLbls1 + gLbls2 + gLbls3;
               htwqty1 += gQty1;
               htwqty2 += gQty2;
               htwqty3 += gQty3;
               htwqtyt += gQty1 + gQty2 + gQty3;
             else;
               httrans += 1;
               htlbls1 += gLbls1;
               htlbls2 += gLbls2;
               htlbls3 += gLbls3;
               htlblst += gLbls1 + gLbls2 + gLbls3;
               htqty1 += gQty1;
               htqty2 += gQty2;
               htqty3 += gQty3;
               htqtyt += gQty1 + gQty2 + gQty3;
             endif;

           when hitType = 'R';
             httrans += 1;
             htlbls1 += gLbls1;
             htlbls2 += gLbls2;
             htlbls3 += gLbls3;
             htlblst += gLbls1 + gLbls2 + gLbls3;
             htqty1 += gQty1;
             htqty2 += gQty2;
             htqty3 += gQty3;
               htqtyt += gQty1 + gQty2 + gQty3;

         endsl;

         htstamp = %timestamp();
         update(e) htrec;

       endif;

      /end-free

     p UpdateDLYHIT    e

     *----------------------------------------------------------------
     *  UpdateShftDay   Update missing PIRTRAND shift day
     *----------------------------------------------------------------

     p UpdateShftDay   b
     d UpdateShftDay   pi

     * Local Variables

     d alphaWhse       s              3

      /free

         alphaWhse = %editc(whcode:'X');
         upd710lma (alphaWhse);

      /end-free

     p UpdateShftDay   e

     *----------------------------------------------------------------
     *  ZZDriCop   Get item info.
     *----------------------------------------------------------------

     p ZZDriCop        b
     d ZZDriCop        pi

      /free

       error = *off;

       select;
         when $dricommand = '*ITEM';
           $dridata = $item;
           $dridata2 = $item2;
       endsl;

       driCop($dricommand: $drisubcmd: $drisys2upd: #prog:
                $drireturn: $drimessage: $dridata: $dridata2);

       select;
         when %error;
           error = *on;
         when $drireturn <> '*OK';
           error = *on;
       endsl;

       select;
         when $dricommand = '*ITEM';
           $item = $dridata;
           $item2 = $dridata2;
       endsl;

      /end-free

     p ZZDriCop        e

