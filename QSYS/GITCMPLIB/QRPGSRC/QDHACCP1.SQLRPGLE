      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDHACCP1  Load Answer Type file - HACCPAT
     *  26 March 2012
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
640 A*    03/26/12  LMC  6.40
     *      - Created.
650aA*    06/25/13  LMC  6.50a
     *      - Enh: Changed wording on table validation Type 4
650bA*    09/23/13  LMC  6.50b
     *      - Enh: Changed wording on type 5 & 8 remove value
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

     D haccpat       e ds

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
        hctype = '1';
        hcdesc = '30 Characters - No Validation ';
        hcdtyp = 'A';
        hcsize = 30;
        hcdecm = ' ';
        hcval  = 'N';
        exec sql insert into haccpat values(:haccpat);

        // write type 2
        hctype = '2';
        hcdesc = 'Y/N Only                      ';
        hcdtyp = 'A';
        hcsize =  1;
        hcdecm = ' ';
        hcval  = ' ';
        exec sql insert into haccpat values(:haccpat);

        // write type 3
        hctype = '3';
        hcdesc = '30 Characters - Validation    ';
        hcdtyp = 'A';
        hcsize = 30;
        hcdecm = ' ';
        hcval  = 'Y';
        exec sql insert into haccpat values(:haccpat);

        // write type 4
        hctype = '4';
650aD   //hcdesc = '20 Characters-Table Validation';
650aM   hcdesc = '20 Char. Dakota Table Validation';
        hcdtyp = 'A';
        hcsize = 20;
        hcdecm = ' ';
        hcval  = ' ';
        exec sql insert into haccpat values(:haccpat);

        // write type 5
        hctype = '5';
650bD   //hcdesc = 'Num 9.2-Validation Value/Range';
650bM   hcdesc = 'Num 9.2-Validation Range';
        hcdtyp = 'S';
        hcsize =  9;
        hcdecm = '2';
        hcval  = 'Y';
        exec sql insert into haccpat values(:haccpat);

        // write type 6
        hctype = '6';
        hcdesc = 'Numeric 9.2 - No Validation   ';
        hcdtyp = 'S';
        hcsize =  9;
        hcdecm = '2';
        hcval  = 'N';
        exec sql insert into haccpat values(:haccpat);

        // write type 7
        hctype = '7';
        hcdesc = 'Date Field                    ';
        hcdtyp = 'S';
        hcsize =  6;
        hcdecm = '0';
        hcval  = 'N';
        exec sql insert into haccpat values(:haccpat);

        // write type 8
        hctype = '8';
650bD   //hcdesc = 'Num 15-Validation Value/Range ';
650bM   hcdesc = 'Num 15-Validation Range ';
        hcdtyp = 'S';
        hcsize = 15;
        hcdecm = '0';
        hcval  = 'Y';
        exec sql insert into haccpat values(:haccpat);

        // write type 9 - this is not currently needed
        //hctype = '9';
        //hcdesc = 'Numeric 15.0-Validation Ranges';
        //hcdtyp = 'S';
        //hcsize = 15;
        //hcdecm = '0';
        //hcval  = 'Y';
        //exec sql insert into haccpat values(:haccpat);

        *inlr = *on;
