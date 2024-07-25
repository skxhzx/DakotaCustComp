      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETADBPLT5  Get ADB Pallet Number
     *  09 April 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
710 A*    04/09/18  KDE  7.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     d true            c                   *on
     d false           c                   *off

     *----------------------------------------------------------
     *  Input Parms
     *----------------------------------------------------------

     D  pPallet#       s              5  0
     D  pReturn        s             10
     D  palletnum      s              5  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pPallet#    0 comes in
     *
     *    Returned Parameters
     *      pPallet#    Next Pallet Number
     *      pReturn     Either *OK, *DTAISSUE
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pPallet#
     C                   parm                    pReturn

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        pReturn = '*OK';

        monitor;
      /end-free
     C     *dtaara       define    PIRADBPLT5    palletnum
     C     *lock         in        palletnum
      /free
        on-error;
           // returns error if data area cannot be locked
           pPallet#=0;
           pReturn='*DTAERROR';
           return;
        endmon;

        pPallet# = palletnum;
        if palletnum < 99999;
           palletnum += 1;
        else;
           // once reaches 99999 go back to zero
           palletnum = 0;
        endif;

        monitor;
      /end-free
     C                   out       palletnum
      /free
        on-error;
           // returns error if data area cannot be updated
           pReturn='*DTAERROR';
        endmon;

        return;

      /end-free

