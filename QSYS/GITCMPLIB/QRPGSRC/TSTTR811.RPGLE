     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTTR811     Test TR811
     *  08 January 2016
     *  Retha Davis
     *
     *  Revisions:
     *
530 A*    01/08/16  RBD  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     C                   eval      $whse = 1
     C                   eval      $rtid = '09150'
     C                   eval      $emp  = '00556'
     C                   eval      $fil  = ' '
     C                   eval      $rtn  = ' '
     C                   eval      $erm  = ' '
     *
     *  Create Trax xml file
     C                   call      'TR811'
     C                   parm                    $whse             3 0
     C                   parm                    $rtid             5
     C                   parm                    $emp              5
     C                   parm                    $fil             30
     C                   parm                    $rtn              8
     C                   parm                    $erm             60
     C                   eval      *inlr = '1'
