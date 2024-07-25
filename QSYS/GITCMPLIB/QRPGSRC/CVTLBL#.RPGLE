     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
      *
      *  CV810     Convert label/seq to combined or split
      *  Retha Davis
      *  23 April, 2007
      *
      *  Revisions
      *
      *    04/23/07  RBD  5.10
      *      - Created
      *
      *----------------------------------------------------------------
      *  File Specs
      *
      *----------------------------------------------------------------
      *  Program parameters
      *
     D $pcmd           s              8
     D $plbl#          s              7  0
     D $pseq#          s              3  0
     D $pcombo         s             10  0
      *----------------------------------------------------------------
      *
      *    Input Parameters
      *      $pcmd   *COMBINE - combine label and seq into a combo field
      *              *SPLIT   - split combo field into label and seq
      *      $plbl#           - label
      *      $pseq#           - sequence
      *      $pcombo          - combined label/sequence
      *
      *    Returned Parameters
      *      $plbl#           - label
      *      $pseq#           - sequence
      *      $pcombo          - combined label/sequence
      *----------------------------------------------------------------
      *  Let the show begin .....
      *
     C     *entry        plist
     C                   parm                    $pcmd
     C                   parm                    $plbl#
     C                   parm                    $pseq#
     C                   parm                    $pcombo
      *----------------------------------------------------------------
      *  Main line

     C                   select
     C                   when      $pcmd = '*COMBINE'
     C                   movel     $plbl#        $pcombo
     C                   move      $pseq#        $pcombo

     C                   when      $pcmd = '*SPLIT  '
     C                   movel     $pcombo       $plbl#
     C                   move      $pcombo       $pseq#

     C                   endsl

     C                   eval      *inlr = *on
      *----------------------------------------------------------------
