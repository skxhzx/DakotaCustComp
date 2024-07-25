     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR320TEST    Test TR320
     *  31 Aug 2011
     *  Retha Davis
     *
     *  Revisions:
     *
640 A*    08/31/11  RBD  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     C                   eval      $cmd  = ' '
     C                   eval      $whse = 1
     C                   eval      $rte  = '*ALL '
     C                   eval      $dev  = ' '
     C                   eval      $form = ' '
     *
     C                   call      'TR320'
     C                   parm                    $cmd              8
     C                   parm                    $whse             3 0
     C                   parm                    $rte              5
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      *inlr = '1'
