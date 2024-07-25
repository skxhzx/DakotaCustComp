      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  BX305     AMP Customer Order More Than 1 Stop Error
     *            calls from RH120A on Alloc/Build
     *
     *  01 Dec 2016
     *  Nancy Koelz
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
700  *  12/01/16  NLK  7.00
     *    - Created.  Control by AMP RtID
700  *  12/05/16  NLK  7.00
     *    - Re-Created.  Control using AMP RtID doesn't catch if CORD
     *      has 2 AMP rts.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Client Here
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fampxref12 if   e           k disk
     fampxref14 if   e           k disk    prefix(am_)
     F                                     rename(axrec:axrec14)
     fordh4     if   e           k disk    prefix(oh_)
     F                                     rename(ohrec:ohrec4)
     fordh9     if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
     *
     * client source entries go here.
      /COPY QCOPYSRC,ID#GLP
     *----------------------------------------------------------------
     * Working variables
     D forever         s              1
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d #pwhse          s              3  0
     d #pdrtid         s              5a
     d #pcord          s              7  0
     d hldcord         s              7  0
     d hldbxid         s              7  0
     d hldstop         s              2  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Warehouse
     *     -Rt Id from Delv Rt (find stop#s)
     *
     *    Returned Parameters
     *     -Cust Order at fault
     *
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     *
     *-------------------------------------Delv Rt coming in----------
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pdrtid           5
     C                   parm                    $pcord            7 0
      *
      *  AMP process allows clients to pick product earlier in the evening
      *  and place inside Tote/Boxes.  The issue for this pgm is to make
      *  sure each BOX only has 1 STOP#.  A Box can contain multiple cords
      *  for the same client, here we need to make sure ALL of these orders
      *  have same STOP # to avoid error.
     *----------------------------------
      *
      /free
         exsr init;
         // loop through ORDH with Delv ID for ea CORD
         // sort whse, rte, stop, cord
           setll (#pwhse:#pdrtid) ordh9;
           dow forever = forever and $pcord = 0;
             reade (#pwhse:#pdrtid) ordh9;
             if %eof(ordh9);
               leave;
             endif;
             hldstop = ohstop;
             hldbxid = 0;

         // loop with CORD to get BoxIDs
         // sort whse, cord, boxid
               setll (#pwhse:ohcord) AMPxRef14;
               dow forever = forever and $pcord = 0;
                 reade (#pwhse:ohcord) AMPxRef14;
                 if %eof(AMPxRef14);
                   leave;
                 endif;
                 if am_axaboxid = 0 or hldbxid = am_axaboxid;
                   iter;
                 endif;
                 hldbxid = am_axaboxid;
                 hldcord = ohcord;

         // loop through AMPxRef for EA box for multi CORD
                     setll (#pwhse:am_axaboxid) AMPxRef12;
                     dow forever = forever;
                       reade (#pwhse:am_axaboxid) AMPxRef12;
                       if %eof(AMPxRef12);
         // return to above loop but skip this box, grab next box
                         setgt (#pwhse:ohcord:am_axaboxid) AMPxRef14;
                         leave;
                       endif;

                       if hldcord <> axcord;
                         exsr doCheck;
                         if $pcord > 0;
                           leave;
                         endif;
                       endif;

                     enddo;

               enddo;

           enddo;

         *inlr = *on;

      /end-free

     * -------------------------------------------------------------------
     **  Initialize everything
     *--------------------------------------------------------------------

     C     Init          begsr
      /free
         #pwhse = $pwhse;
         #pdrtid = $pdrtid;
         $pcord = 0;
      /end-free
     C                   endsr

     * -------------------------------------------------------------------
     **  AMP Box has multi CORD, now check the Stop#s
     *--------------------------------------------------------------------

     C     doCheck       begsr
      /free
          // is other CORD same stop#

         setll (#pwhse:#pdrtid:axcord) ordh4;
         reade (#pwhse:#pdrtid:axcord) ordh4;
           if hldstop <> oh_ohstop;
             $pcord = axcord;
           endif;

      /end-free
     C                   endsr

