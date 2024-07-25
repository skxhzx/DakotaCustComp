     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR810TST    Test TR810
     *  04 Jan 2012
     *  Retha Davis
     *
     *  Revisions:
     *
640 A*    01/04/12  RBD  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $prtid            5
     *
     C                   eval      $whse = $pwhse
     *
     *  Create Trax xml file
     C                   call      'TR810'
     C                   parm                    $whse             3 0
     C                   parm                    $prtid            5
     C                   parm      *blanks       $emp              5
     C                   parm      *blanks       $fil             30
     C                   parm      *blanks       $rtn              8
     C                   parm      *blanks       $erm             60
     C                   eval      *inlr = '1'
