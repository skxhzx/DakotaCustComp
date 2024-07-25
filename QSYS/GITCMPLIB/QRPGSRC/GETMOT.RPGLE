      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETMOTL   Get method of transportation - Chef's whse only
     *  16 May 2014
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
650aA*    05/16/14  JCJ  6.50a
     *      - Date Created.
     *
710aA*    04/26/17  JCJ  7.10a
     *      - Added new lot label logic.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ff4211mot  if   e           k disk

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $motcd   -  Method of transportation category code
     *
     *  Output parameters
     *
     *     $motdsc  -  Mothod of transportation description
     *     $prtflag -  Print Cruise ship label (Y,N).
     *     $RTN     -  Status code
     *                 *OK    - Valid code
     *                 *ERROR - Invalid code
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $motcd            3
     C                   parm                    $motdsc          30
     C                   parm                    $prtflag          1
     C                   parm                    $rtn              8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        chain ($motcd) f4211mot;
        if %found(f4211mot);
          $motdsc = descr00001;
          select;
            when printlbl = 'N';
              $prtflag = printlbl;
            when $motcd = 'LC1';
              $prtflag = 'L';
            other;
              $prtflag = 'C';
          endsl;
          $rtn = '*OK     ';
        else;
          $motdsc = *blanks;
          $prtflag = *blanks;
          $rtn = '*ERROR  ';
        endif;

        *inlr = *on;
        return;

      /end-free
