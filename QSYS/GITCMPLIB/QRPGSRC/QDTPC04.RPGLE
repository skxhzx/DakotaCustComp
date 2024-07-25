     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDTPC04   Q&D - Set slot status to Z for items moved to PIR
     *  28 March 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    03/28/17  LMC 7.10
     *      - Created
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpiritem7  if   e           k disk
     Fslot10    uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s              1
     D forevr          s              1
     D len             s              1  0
     D SectionType     s              1    inz('P')
     D Department      s              5    inz('DRY  ')
     D SlotStatus      s              2    inz('A ')
     D SlotPick        s              1    inz('Y')
     D SlotSection     s              1    inz('F')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     *
      /free
        setll (Sectiontype: Department) piritem7;
        dow forevr = forevr;
          reade (Sectiontype: Department) piritem7;
          if %eof(piritem7);
            leave;
          endif;
          // now need to find the fixed slot for this item and set the
          // status to zero if there is no stock.
          setll (itwhse: ititem: SlotStatus: SlotPick) slot10;
          dow forevr = forevr;
            reade (itwhse: ititem: SlotStatus: SlotPick) slot10;
            if %eof(slot10);
              leave;
            endif;
            if slstyp <> SlotSection;
              iter;
            endif;
            if slstk1 <> 0;
              iter;
            endif;
            if slstk2 <> 0;
              iter;
            endif;
            if slstk3 <> 0;
              iter;
            endif;
            slstat = 'Z ';
            update slrec;
          enddo;
        enddo;
        *inlr = *on;
      /end-free
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     C                   eval      error = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
