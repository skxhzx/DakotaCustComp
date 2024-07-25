     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  XM150TST     Test XM150
     *  15 Apr 2011
     *  Retha Davis
     *
     *  Revisions:
     *
640 A*    04/15/11  RBD  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     C                   eval      $whse = 1
     C                   eval      $rtid = '02442'
     C                   eval      $fil  = ' '
     C                   eval      $rtn  = ' '
     C                   eval      $erm  = ' '
     *
     *  Create tote conveyor text file
     C                   call      'XM150'
     C                   parm                    $whse             3 0
     C                   parm                    $rtid             5
     C                   parm                    $fil             30
     C                   parm                    $rtn              8
     C                   parm                    $erm             60
     C                   eval      *inlr = '1'
