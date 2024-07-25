      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDHACCP2A  - Load Question Type file receiving types - HACCPQT
     *  27 March 2012
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
640 A*    03/27/12  LMC  6.40
     *      - Created.
650aA*    04/15/13  LMC  6.50a
     *      - Enh - Added new level type REXI
650bA*    07/01/13  LMC  6.50b
     *      - Enh - Change the verbage on the Vendor Type Questions
650cA*    09/11/13  LMC  6.50c
     *      - Fix - Correct spelling.
740aA*    04/17/20  LMC  7.40a
     *      - Enh:  Add new Po Verification Level
740bA*    06/08/20  LMC  7.40b
     *      - Enh:  Add new Po follow-up process
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

     D haccpqt       e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $pwhse          s              3

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse   - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        hbwhse = %dec($pwhse:3:0);
        hbseq# = 0;
        hbuctl = 'N';
        hbwkhst = 106;

        // write BFC Controlled question for po detail receiving
        hblevl = 'RCVI';
        hbtype = 'ALL';
        hbdesc = 'All Po Items';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving
        hblevl = 'RCVI';
        hbtype = 'CAT';
        hbdesc = 'Category';
        hblook = 'IC900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving
        hblevl = 'RCVI';
        hbtype = 'ITM';
        hbdesc = 'Item';
        hblook = 'IT900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving
        hblevl = 'RCVI';
        hbtype = 'DPT';
        hbdesc = 'Department';
        hblook = 'WD900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving license
        hblevl = 'RCVL';
        hbtype = 'ALL';
        hbdesc = 'All Po Licenses';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving license
        hblevl = 'RCVL';
        hbtype = 'CAT';
        hbdesc = 'Category';
        hblook = 'IC900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving license
        hblevl = 'RCVL';
        hbtype = 'ITM';
        hbdesc = 'Item';
        hblook = 'IT900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving license
        hblevl = 'RCVL';
        hbtype = 'DPT';
        hbdesc = 'Department';
        hblook = 'WD900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po header receiving
        hblevl = 'RCVH';
        hbtype = 'ALL';
        hbdesc = 'All Purchase Orders';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po header receiving
        hblevl = 'RCVH';
        hbtype = 'VEN';
650bD   //hbdesc = 'Vendor Receipts';
650bM   hbdesc = 'Vendor#';
        hblook = ' ';
        hbentry = 'Y';
        exec sql insert into haccpqt values(:haccpqt);

650aA   // write BFC Controlled question for po detail exceptions
650aA   hblevl = 'REXI';
650aA   hbtype = 'ALL';
650aA   hbdesc = 'All Po Item Exceptions';
650aA   hblook = ' ';
650aA   hbentry = ' ';
650aA   exec sql insert into haccpqt values(:haccpqt);

650aA   // write BFC Controlled question for po detail exceptions
650aA   hblevl = 'REXI';
650aA   hbtype = 'CAT';
650cD   //hbdesc = 'Categoryn Exceptions';
650cM   hbdesc = 'Category';
650aA   hblook = 'IC900';
650aA   hbentry = ' ';
650aA   exec sql insert into haccpqt values(:haccpqt);

650aA   // write BFC Controlled question for po detail exceptions
650aA   hblevl = 'REXI';
650aA   hbtype = 'ITM';
650aA   hbdesc = 'Item';
650aA   hblook = 'IT900';
650aA   hbentry = ' ';
650aA   exec sql insert into haccpqt values(:haccpqt);

650aA   // write BFC Controlled question for po detail exceptions
650aA   hblevl = 'REXI';
650aA   hbtype = 'DPT';
650aA   hbdesc = 'Department';
650aA   hblook = 'WD900';
650aA   hbentry = ' ';
650aA   exec sql insert into haccpqt values(:haccpqt);

740aA   // write BFC Controlled question for po detail receiving
740aA   hblevl = 'RCVV';
740aA   hbtype = 'ALL';
740aA   hbdesc = 'All Po Verification';
740aA   hblook = ' ';
740aA   hbentry = ' ';
740aA   exec sql insert into haccpqt values(:haccpqt);

740bA   // write BFC Controlled question for po follow-up
740bA   hblevl = 'RCVF';
740bA   hbtype = 'ALL';
740bA   hbdesc = 'All Po Follow-up';
740bA   hblook = ' ';
740bA   hbentry = ' ';
740bA   exec sql insert into haccpqt values(:haccpqt);

        *inlr = *on;

      /end-free
     C*----------------------------------------------------------------
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

       endsr;
      /end-free


