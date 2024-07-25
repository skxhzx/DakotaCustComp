     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTTR845     Test TR845
     *  04 Oct 2011
     *  Retha Davis
     *
     *  Revisions:
     *
640 A*    10/04/11  RBD  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     C                   eval      $whse = 1
     C                   eval      $rtid = '09057'
     C                   eval      $rtn  = ' '
     C                   eval      $erm  = ' '
     *
     *  Update Trax files
     C                   call      'TR845'
     C                   parm                    $whse             3 0
     C                   parm                    $rtid             5
     C                   parm                    $rtn              8
     C                   parm                    $erm             60
     C                   eval      *inlr = '1'
