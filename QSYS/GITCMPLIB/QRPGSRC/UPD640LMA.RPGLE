      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPD640LMA  Initialize New UCI fields in ITEMFLD fiel
     *  16 October 2012
     *  Lynn McMahon
     *
     *
     *----------------------------------------------------------------
     *  Revisions
640 A*    10/16/12  LMC  6.40
     *      - Created.
640aA*    11/13/12  LMC  6.40a
     *      - Enh - Decision was made to auto load itemfld records if
     *      they don't already exist. Init new fields if record exist
     *      and the fields are blank.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
640aAFpiritem   if   e           k disk
640aDF*itemfld   up   e           k disk
640aMFitemfld   uf a e           k disk

     *----------------------------------------------------------------
640aA** Variables
640aAd forever         s              1    inz('1')
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
      /free
640aA    dow forever = forever;
640aA      read piritem;
640aA      if %eof(piritem);
640aA        leave;
640aA      endif;
640aA      chain (itwhse:ititem) itemfld;
640aA      if not %found(itemfld);
640aA        ifwhse = itwhse;
640aA        ifitem = ititem;
640aA        ifcat  = *blanks;
640aA        ifcaseovf = *blanks;
640aA        ifodrslot = *blanks;
640aA        ifucicde  = '1';
640aA        ifrcvmth  = '1';
640aA        ifsltmth  = '1';
640aA        ifbrdflg  = 'N';
640aA        write ifrec;
640aA      else;
             // Initialize new fields in ITEMFLD file
             if ifucicde = ' ';
               ifucicde = '1';
             endif;
             if ifrcvmth = ' ';
               ifrcvmth = '1';
             endif;
             if ifsltmth = ' ';
               ifsltmth = '1';
             endif;
             if ifbrdflg = ' ';
               ifbrdflg = 'N';
             endif;
             update ifrec;
640aA      endif;

640aA    enddo;

640aA    *inlr = *on;
      /end-free


