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
     *  BX300     AMP Customer Order Reduce Qty Report
     *            ProducePro sends flag 'R' into OR630
     *
     *  11 July 2016
     *  Nancy Koelz
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
700 A*  07/11/16  NLK  7.00
     *    - Created.
700aA*  08/10/16  NLK  7.00a
     *    - Added Route to the Report coming from RH120A
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fampxref1  if   e           k disk
     fampbox    if   e           k disk
     forddm     if   e           k disk
     fordh      if   e           k disk
     fordd2     if   e           k disk
     flabel90   if   e           k disk
     fitemdsc   if   e           k disk
     fbx300pr   o    e             printer oflind(*in90)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     D @getcl          c                   const('GETCLIENT')
     *
     * client source entries go here.
      /COPY QCOPYSRC,ID#GLP
      /COPY QCOPYSRC,ORDDM1_AMP
     *----------------------------------------------------------------
     * Working variables
     D forever         s              1
     D hmsmdy          s             12  0
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d #pwhse          s              3  0
     d stat            s              1a
     d #pordLO         s              7  0
     d #pordHI         s              7  0
     d route           s              5a

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Warehouse
700 A*     -Order# range
700 A*     -Route from Delv Rt
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
     *-------------------------------------Delv Rt coming in----------
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pordLO           7 0
     C                   parm                    $pordHI           7 0
     C                   parm                    $prhrte           5
      *
      *  Original Design before ProducePro created a FLAG of 'R' to Reduce Qty
      *  use parms delv rtid to read ORDH4-get OHCORD 'dow'
      *  use CORD to read ORDD-get all items 'dow'
      *  using CORD+items read ampxref to see if AMP item
      *  If AMP-using CORD+items read LABEL to get Qty Picked
      *     check if there is a 2nd record with this item with same CORD but diff AMP rtid
      *  Total up AMP Picked per item vs Delv Rt Order Qty and if AMP > DelvRt *PRINT
      *  If *PRINT then read AMPBOX and get Box #
     *----------------------------------
      *  NOW   read ORDDM to get ALL items with a flag
      *        go to PRINT and read AMPxRef and AMPBOX and ordh
      *
      /free
         exsr init;
         // loop through ORDDM for all 'R'
           setll (#pwhse:#pordLO) ORDDM;
           dow forever = forever;
             reade (#pwhse) ORDDM;
             if not %eof(orddm) and omord <= #pordHI;
               orddm1_amp = ommsc1;
                 else;
               leave;
             endif;
             if client = greenleaf and ampdm4_ampfl = 'R';
               exsr doPrint;
             endif;
           enddo;

         *inlr = *on;

      /end-free

     * -------------------------------------------------------------------
     **  Initialize everything
     *--------------------------------------------------------------------

     C     Init          begsr
     C                   eval      #pwhse = $pwhse
     C                   eval      #pordLO = $pordLO
     C                   eval      #pordHI = $pordHI
700aAC                   eval      route = $prhrte
     C                   eval      *in90 = *off
     C                   time                    hmsmdy
     C                   Move      hmsmdy        rdate
     C                   movel     hmsmdy        rtime
     C                   write     header
     C                   write     headtl
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    clientloc        10
     C                   endsr

     * -------------------------------------------------------------------
     **  Print Detail line
     *--------------------------------------------------------------------

     C     doPrint       begsr
      /free
          // if 'R' Flag to Reduce AMP Qty; Grab Box Info & Print
          if *in90 = *on;
             write header;
             write headtl;
             *in90 = *off;
          endif;

         setll (#pwhse:omord) ORDH;
         reade (#pwhse:omord) ORDH;

           setll (ohwhse:ohcord:omitem) ampxref1;
           dow forever = forever;
             reade (ohwhse:ohcord:omitem) ampxref1;
             if not %eof(AMPXREF1);
               setll (axwhse:axaboxid) ampbox;
               reade (axwhse:axaboxid) ampbox;
               setll (axwhse:axatrn#:axalbl#) label90;
               reade (axwhse:axatrn#:axalbl#) label90;
               setll (axwhse:axitem) itemdsc;
               reade (axwhse:axitem) itemdsc;
               ixdesc = ixdsc1;
          // using delv rt get qty ordered
               stat = 'O';
               setll (axwhse:ohord:stat:axitem) ordd2;
               reade (axwhse:ohord:stat:axitem) ordd2;
                if %eof(ordd2);
                stat = 'P';
                setll (axwhse:ohord:stat:axitem) ordd2;
                reade (axwhse:ohord:stat:axitem) ordd2;
                endif;
             else;
               leave;
             endif;

             write detail;
               ixdesc = *blanks;

           enddo;

      /end-free
     C                   endsr

