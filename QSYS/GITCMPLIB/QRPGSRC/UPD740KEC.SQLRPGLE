      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPD740KEC Ensure you Zone Maintenance Options for defined
     *
     *  27 August 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*   08/27/20  KDE  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program should be ran to populate new options used in
     *   Zone Maintenance and General Picking Options
     *
     *----------------------------------------------------------------
     fwarehs    if   e           k disk
     Foptions   uf a e           k disk

     *----------------------------------------------------------------
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *    OPLGHT  -  Truck Build Full/Light code
730aA*    OPTBTYPE - TruckBuilder Type (S=Standard, E-Enhanced/Advanced, B=Both)
730aA*    OPTBCOL - TruckBuilder Columns (N=Std 2 columns, Y=3+ Columns)
740 A*    OPPLTBL - TruckBuilder Pallet Build Method (1=Std  2=Some Automation  3=More item ops)
740 A*    OPPLTYPS -TruckBuilder Pallet Types used
     *
     * Data structure
     *
     D opdata          ds
     D  opfeat                 1      1
640aAD  oplght                 2      4
730aAD  optbtype               5      5
730aAD  optbcol                6      6
740 AD  oppltbl                7      7
740 AD  oppltyps             107    116
     D  optend               117    117
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,p.excustma

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d wkaudflg        s              1
     d wkaudexpd       s              8  0
     d wkspflg         s              1
     d wkaudr          s            500    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

        *inlr=*on;

        // Loop thru Warehouse file and make sure *FEATURE record
        // exist for each with defaults

        setll (*loval) warehs;
        dow forever = forever;
          read warehs;
          if %eof(warehs);
            leave;
          endif;
          chain (whcode:'*FEATURE') options;
          if %found(options);
            if oppltbl=*blanks;
              oppltbl='1';      //set as standard
            endif;
            if oppltyps=*blanks;
              oppltyps='POTSB';
            endif;
            update oprec;
          else;
            // initialize if not found
            opwhse=whcode;
            opcode='*FEATURE';
            opfeat='1';
            oplght=*blanks;
            optbtype='B';
            OPTBCOL='N';
            OPPLTBL='1';
            oppltyps='POTSB';
            write oprec;
          endif;
        enddo;

      /end-free
