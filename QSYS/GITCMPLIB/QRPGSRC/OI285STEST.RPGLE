     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OI285STEST    Test OI285S
     *  03 Mar 2011
     *  Retha Davis
     *
     *  Revisions:
     *
640aA*    03/03/11  RBD  6.40a
     *      - Created.
     *
     *----------------------------------------------------------------
     C                   eval      $pWhse3A = '001'
     C                   eval      $pBatId = '11072600013'
     C                   eval      $pReturn = ' '
     C                   eval      $pMessage = ' '
     *
     *  Route import
     C                   call      'OI285S'
     c                   parm                    $pWhse3A          3
     c                   parm                    $pBatId          11
     c                   parm                    $pReturn         10
     c                   parm                    $pMessage       200
     C                   eval      *inlr = '1'
