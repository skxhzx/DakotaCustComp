      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETLBLTRN   Get transaction for a label record
     *  11 December 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*   12/11/13  DAS  6.50
     *     -Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     flabel     if   e           k disk

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $plbl#   - Label number
     *
     *  Output parameters
     *
     *     $ptrn#   - Transaction number
     *     $prtn    - *OK      -  Lable found
     *                *ERROR   -  Label not found
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $plbl#            7 0
     C                   parm                    $ptrn#            7 0
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         chain ($plbl#) label;

         if %found;
           $ptrn# = lbtrn#;
           $prtn = '*OK';
         else;
           $ptrn# = 0;
           $prtn  = '*ERROR';
         endif;

         return;
      /end-free
