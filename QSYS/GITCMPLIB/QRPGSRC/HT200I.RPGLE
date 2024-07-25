      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HT200I    Populate DLYHIT file with 'I' records
     *  20 June 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*    03/28/18  DAS  7.20
     *      - Created.
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
     * File Specs
     *----------------------------------------------------------------

     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fdlyhit1   uf a e           k disk

     *----------------------------------------------------------------
     *  Working variables
     *
     D forever         s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CreateZeroRecs  pr

     * Main line

      /free
       *inlr = *on;

       dow forever = forever;

         read warehs;
         if %eof(warehs);
           leave;
         endif;

         CreateZeroRecs();

       enddo;

      /end-free

     *----------------------------------------------------------------
     *  CreateZeroRecs  Create zero recs
     *----------------------------------------------------------------

     p CreateZeroRecs  b
     d CreateZeroRecs  pi

      /free

       // First delete all 'I' records

       setll (whcode: 'I') dlyhit1;
       dow forever = forever;
         reade (whcode: 'I') dlyhit1;
         if %eof(dlyhit1);
           leave;
         endif;
         delete dlyhit1;
       enddo;

       // Create 'I' record for every item.

       clear htrec;
       httype = 'I';
       htstamp = %timestamp();

       setll (whcode) piritem;

       dow forever = forever;

         reade (whcode) piritem;
         if %eof(piritem);
           leave;
         endif;

         htwhse = whcode;
         htwhdp = itwhdp;
         htitem = ititem;
         htbaseitm = ititem;

         write(e) htrec;

       enddo;

      /end-free

     p CreateZeroRecs  e

