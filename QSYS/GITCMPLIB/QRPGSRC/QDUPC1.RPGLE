      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDUPC1    Identify invalid upc codes in the upc file
     *  01 August 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    03/26/12  LMC  6.40
     *      - Created.
700aA*    11/04/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     Fupc       if   e           k disk
     Fupcaudit  o  a e           k disk    prefix(a_) rename(uprec:up1)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------



      /free
        dow not %eof(upc);
          read upc;
          If %eof(upc);
            leave;
          endif;
      /end-free
      * check for valid upc
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = upupc
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
      /free
          a_upwhse = upwhse;
          a_upupc  = upupc;
          a_UPITEM = UPITEM;
          a_UPUPC  = UPUPC;
          a_UPVEN  = UPVEN;
          a_UPVNAM = UPVNAM;
          a_UPVITM = UPVITM;
          a_UPBRAN = upbran;

          if $cbrtn = '*OK';
            // valid record

            a_UPVALID = 'Y';

          else;
            a_UPVALID = 'N';
          endif;
          write up1;
        enddo;

        *inlr = *on;
      /end-free
