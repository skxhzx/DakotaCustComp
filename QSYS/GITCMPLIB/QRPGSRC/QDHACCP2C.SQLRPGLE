      /copy *libl/qcopysrc,hspecs
730 AH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDHACCP2C  - Load Question Type file Trax - HACCPQT
     *  30 December 2019
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
730 A*    12/30/19  LMC  7.30
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

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'CS1';
        hbdesc = 'Customer Begin Stop';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'CS2';
        hbdesc = 'Customer End Stop';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'DT1';
        hbdesc = 'Driver Trailer Insp OUT';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'DT2';
        hbdesc = 'Driver Trailer Insp IN';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'DV1';
        hbdesc = 'Driver Vehicle Insp OUT';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'DV2';
        hbdesc = 'Driver Vehicle Insp IN';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'RT1';
        hbdesc = 'Begin Route';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'RT2';
        hbdesc = 'End Route';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'ST1';
        hbdesc = 'Begin Stop';
        hblook = ' ';
        hbentry = ' ';
        exec sql insert into haccpqt values(:haccpqt);

        // write BFC Controlled question for TRAX
        hblevl = 'TRAX';
        hbtype = 'ST2';
        hbdesc = 'End Stop';
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


