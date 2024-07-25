      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETDEV      Get device/form with popup window
     *  14 February 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
710 A*    02/14/17  DAS  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fgetdevfm  cf   e             workstn
     F                                     infds(info)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pdev    - Device
     *      $pform   - Form
     *
     *    Returned Parameters
     *      $pdev    - Device
     *      $pform   - Form
     *      $prtn    - Return (*OK, *CANCEL)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $prtn            10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         wpdev = $pdev;
         wpform = $pform;

         if wpdev = ' ';
           wpdev = '*JOB';
         endif;

         if wpform = ' ';
           wpform = '*STD';
         endif;

         exfmt windowp;

         if cfkey = F3 or cfkey = F12;

           $prtn = '*CANCEL';

         else;

           if wpdev = ' ';
             wpdev = '*JOB';
           endif;

           if wpform = ' ';
             wpform = '*STD';
           endif;

           $prtn = '*OK';
           $pdev = wpdev;
           $pform = wpform;

         endif;

         *inlr = *on;

         return;

      /end-free
