      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PT640AC    PT640 Auto Close
     *  17 March 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
710 A*   03/17/17  DAS  7.10
     *     - Created.
     *
710aA*   03/23/17  DAS  7.10a
     *     - Fix: Revised to set $lcmd before each call.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fpirtran4  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.pt132

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D forever         s               n
     D stat4flag       s               n

     *----------------------------------------------------------------
     *  Data structure for PT132
     *----------------------------------------------------------------

     D $lparms         ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     D  $lmput                89     89
650mAD  $llbl#                90     96  0
650mAD  $lqpck                97    101  0
650mAD  $lwarn               102    102

     *   Redefine key

     D  $lwhse                19     21  0
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Input parameters
     *
     *      $pwhse     -  Warehouse
     *      $prtid     -  Route Id
     *      $ptype     -  Route type
     *
     *  Output parameters
     *
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptype            1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         getclient(client: clientLoc);

         if client = cheney;
           exsr CheneyClosePallets;
         endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CheneyClosePallets - Auto close Pallets
     *----------------------------------------------------------------

      /free
       begsr CheneyClosePallets;

         // See if any transactions have been closed.

         stat4flag = *off;
         setll ($pwhse: $ptype: $prtid) pirtran4;

         dow forever = forever;

           reade(e) ($pwhse: $ptype: $prtid) pirtran4;

           if %eof(pirtran4);
             leave;
           endif;

           if ptgrp1 <> 'S';
             iter;
           endif;

           if ptstat = '4';
             stat4Flag = *on;
             leave;
           endif;

         enddo;

         // If nothing has been closed, don't auto close anything.

         if not stat4flag;
           leavesr;
         endif;

         // Call PT132 for each transaction to close pallet labels.

710aD    //$lcmd  = '*CLOSEC1';
         $lwhse = $pwhse;
         $lrte  = $prtid;
         $lprg  = #pgm;

         setll ($pwhse: $ptype: $prtid) pirtran4;

         dow forever = forever;

           reade(e) ($pwhse: $ptype: $prtid) pirtran4;

           if %eof(pirtran4);
             leave;
           endif;

           if ptgrp1 <> 'S';
             iter;
           endif;

           if ptstat = '4';
             iter;
           endif;

710aA      $lcmd  = '*CLOSEC1';
           $ltrn# = pttrn#;
           pt132($lparms);

         enddo;

       endsr;
      /end-free
