      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDHACCP3  Load Question Frequency File - HACCPQF
     *  09 May 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    05/09/12  LMC  6.40
     *      - Created.
740aA*    05/29/20  LMC  7.40
     *      - Added new field HFCODE
     *      - Added new types
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D haccpqf       e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

      /free

        // write type 1
        hftype = '1';
        hfdesc = 'Once Per Item';
740aA   hfcode = 'R';
        exec sql insert into haccpqf values(:haccpqf);

        // write type 2
        hftype = '2';
        hfdesc = 'Once Per PO';
740aA   hfcode = 'R';
        exec sql insert into haccpqf values(:haccpqf);

        // write type 3
        hftype = '3';
        hfdesc = 'Once Per Session';
740aA   hfcode = 'R';
        exec sql insert into haccpqf values(:haccpqf);

        // write type 4
        hftype = '4';
        hfdesc = 'Everytime';
740aA   hfcode = 'A';
        exec sql insert into haccpqf values(:haccpqf);

740aA   // write type 5
740aA   hftype = '5';
740aA   hfdesc = 'Once a Day';
740aA   hfcode = 'U';
740aA   exec sql insert into haccpqf values(:haccpqf);

740aA   // write type 6
740aA   hftype = '6';
740aA   hfdesc = 'Once a Day - One at a time';
740aA   hfcode = 'U';
740aA   exec sql insert into haccpqf values(:haccpqf);

        *inlr = *on;
      /end-free
