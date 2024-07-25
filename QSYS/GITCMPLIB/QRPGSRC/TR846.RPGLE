      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR846   Reformat xml timestamps and fix invalid scan id's.
     *
     *          Reformat xml timestamps.  When the xml is uploaded the
     *          timestamp is formatted 'ccyy-mm-ddThh:mm:ss'.  This
     *          pgm whips through the scan exceptions and reformats
     *          all dates with 'T' in pos 11 to the standard iSeries
     *          timestamp format.  Otherwise, gui and other pgms will
     *          crash and burn if they reference the xml timestamp.
     *
     *          Fix invalid scan id's.  If pos 6-10 of ttescn has
     *          anything non numeric it will cause the gui report
     *          to crash, ttescn is joined to orpup#.  So to avoid
     *          the problem this program will move bad scan id's
     *          to pos 50 of ttescn and replace pos 6-10 with 00000.
     *
     *          Note: This pgm gets called at the end of TRCMPRTE.
     *
     *  27 June 2017
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    06/27/17  RBD  7.10
     *      - Created.
     *
710aA*    07/19/17  RBD  7.10a
     *      - Added new field for intended stop.
     *      - If op flag = 'U' change it to 'I'.
     *
710bA*    08/25/17  RBD  7.10b
     *      - Added transaction number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     fttexcp    uf   e           k disk
710aAfordp      if   e           k disk
710aAflabel     if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

     D hld_ttets       s             26
     D hld_ttescn      s              5
     D scanLength      S              3P 0
     D updRec          s               n

     *----------------------------------------------------------------
     *  Date/time variables


     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Constants

     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *
     *    Returned Parameters
     *
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     * Main line

     C                   exsr      updTS

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     C                   endsr
     *-------------------------------------------------------------------------
     *  Loop through Trax scan exceptions file and reformat xml timestamps.
     *-------------------------------------------------------------------------

      /free
       begsr updTS;

         dou forevr <> forevr;

           read ttexcp;

           if %eof(ttexcp);
             leave;
           endif;

           updRec = '0';

           if %subst(ttets:11:1) = 'T';

             updRec = '1';
             hld_ttets = ttets;
             ttets = %subst(hld_ttets:1:10) +
                     '-' +
                     %subst(hld_ttets:12:2) +
                     '.' +
                     %subst(hld_ttets:15:2) +
                     '.' +
                     %subst(hld_ttets:18:2) +
                     '.000000';

           endif;

           %Len(ttescn) = 100;

           if   %subst(ttescn:6:1) < '0'
             or %subst(ttescn:6:1) > '9'
             or %subst(ttescn:7:1) < '0'
             or %subst(ttescn:7:1) > '9'
             or %subst(ttescn:8:1) < '0'
             or %subst(ttescn:8:1) > '9'
             or %subst(ttescn:9:1) < '0'
             or %subst(ttescn:9:1) > '9'
             or %subst(ttescn:10:1) < '0'
             or %subst(ttescn:10:1) > '9';

             updRec = '1';
             hld_ttescn = %subst(ttescn:6:5);
             %subst(ttescn:6:5) = '00000';
             %subst(ttescn:96:5) = hld_ttescn;

           endif;

710bD    //if ttesti = 0;
710bM      if ttesti = 0 or ttetrn = 0;
710aA        chain (%dec(ttewhs:3:0): tterid: %dec(%subst(ttescn:6:5):5:0))
710aA               ordp;
710aA        if %found;
710aA          chain orplbl label;
710aA          if %found;
710aA            updRec = '1';
710aA            ttesti = lbstop;
710bA            ttetrn = lbtrn#;
710aA          endif;
710aA        endif;
710aA      endif;

710aA        if tteopf = 'U';
710aA          updRec = '1';
710aA          tteopf = 'I';
710aA        endif;

           if updRec = '1';
             update tterec;
             hld_ttescn = *blanks;
           endif;

         enddo;

       endsr;
      /end-free
     *-------------------------------------------------------------------------
