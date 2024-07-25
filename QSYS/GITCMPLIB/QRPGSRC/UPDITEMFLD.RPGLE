      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDITEMFLD  Set category for Count for Halsey
     *  17 July, 2017
     *  Roxanne Harrison
     *
     *
     *----------------------------------------------------------------
     *  Revisions
640 A*    07/17/17  RH   7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
640aAFpiritem   if   e           k disk
640aDFitemfld   up   e           k disk

     *----------------------------------------------------------------
640aA** Variables
640aAd forever         s              1    inz('1')
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
      /free
640aA      chain (ifwhse:ifitem) piritem;
640aA      if not %found(piritem);
640aA        delete ifrec;
640aA      else;
             // Set category code for count to reactivate Dakota.
             if itflgd = 'Y';
             //  ifcat = 'DC';
             else;
640aA        //  ifcat = 'ND';
             endif;
             update ifrec;
640aA      endif;


      /end-free


