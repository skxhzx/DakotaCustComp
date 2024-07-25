      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPD740DSA  Create *PLTPRTY in OPTIONS file
     *
     *  31 August 2020
     *  Dave Sommerville
     *
     *  Revisions
     *
740 A*   08/31/20  DAS  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     fwarehs    if   e           k disk
     Foptions   uf a e           k disk

740cA*----------------------------------------------------------------
740cA*  *PLTPRTY  -  Auto pallet build priorities
740cA*----------------------------------------------------------------
740cA*
740cA* Fields
740cA*
740cA*    opSplitItem  - No item splits
740cA*    opSplitStop  - No Stop splits
740cA*    opIdealCube  - Build to Ideal cube
740cA*    opMinPallets - Minimize pallets
740cA*    opSideWgt    - Balance weight side-to-side
740cA*    opZoneWgt    - Balance weight within Zone
740cA*    opZoneCube   - Balance cube within Zone
740cA*    opMinStops   - Minimize Stops on pallet
740cA*    opBulkhead   - Get to bulkhead
740cA*
740cA* Data structure
740cA*
740cAD opdata          ds
740cAD  opSplitItem            1      2  0
740cAD  opSplitStop            3      4  0
740cAD  opIdealCube            5      6  0
740cAD  opMinPallets           7      8  0
740cAD  opSideWgt              9     10  0
740cAD  opZoneWgt             11     12  0
740cAD  opZoneCube            13     14  0
740cAD  opMinStops            15     16  0
740cAD  opBulkhead            17     18  0
740cAD  optend               117    117

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

        *inlr=*on;

        // Loop thru Warehouses and add *PLTPRTY record

        setll (*loval) warehs;
        dow forever = forever;
          read warehs;
          if %eof(warehs);
            leave;
          endif;
          opwhse=whcode;
          opcode='*PLTPRTY';
          opSplitItem = 5;
          opSplitStop = 5;
          opIdealCube = 5;
          opMinPallets = 5;
          opSideWgt = 5;
          opZoneWgt = 5;
          opZoneCube = 5;
          opMinStops = 5;
          opBulkhead = 5;
          write oprec;
        enddo;

      /end-free
