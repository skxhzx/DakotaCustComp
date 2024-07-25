      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDHACCP2B  - Load Question Type file Outbound types - HACCPQT
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
        hblevl = 'SHPD';
        hbtype = 'CAT';
        hbdesc = 'Category Shipments';
        hblook = 'IC900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving
        hblevl = 'SHPD';
        hbtype = 'ITM';
        hbdesc = 'Item Shipments';
        hblook = 'IT900';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving
        hblevl = 'SHPH';
        hbtype = 'ALL';
        hbdesc = 'All Shipments';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for po detail receiving
        hblevl = 'SHPH';
        hbtype = 'CST';
        hbdesc = 'Customer Shipments';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

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


