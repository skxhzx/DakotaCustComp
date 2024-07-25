     H option(*NODEBUGIO)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WHLIST    Print Warehouse Listing
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  01/30/14  KDE  6.50
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fwarehs    if   e           k disk
     fwhprtf    o    e             printer oflind(*in90)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d forever         s              1    inz('1')
     D odritemflag     s               n   inz('0')
     d rdate           s              6  0 inz
     D rpslotfound     s               n   inz('0')
     D fndrpSlot       s               n   inz('0')
     D leaveNow        s               n   inz('0')
     d rtime           s              6  0 inz
     d $type           s              1    inz('R')
     d wkpick          s              1    inz('Y')
     d wkstat          s              2    inz('A')
     d hmsmdy          s             12  0 inz
     d pos             s              2  0 inz(0)
     d odrelem         s              2  0 inz(0)
     d odrnext         s              2  0 inz(0)
     d #pwhse          s              3p 0 inz(0)
     d inactive        S               n
     d normalPck       S               n
     d rppck           S               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Warehouse
     *     -Department
     *
     *    Returned Parameters
     *      -None -
     *
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     *
     *----------------------------------------------------------------     ****
      /free
         totwh = 0;
         write heading;
         write heading1;
         setll (*loval) warehs;
         read warehs;
         dow not %eof(warehs);
            write detail;
            totwh = totwh + 1;
            read warehs;
         enddo;
         write total;
         *inlr = *on;
