640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETITEMEXT   Get item extension information
     *  31 December 2018
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
720 A*    12/31/18  JCJ  7.20
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fitemext1  if   e           k disk
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse
     *      $pitem  Item
     *
     *    Returned Parameters
     *      $msc1   User Field 1
     *      $msc2   User Field 2
     *      $msc3   User Field 3
     *      $msc4   User Field 4
     *      $msc5   User Field 5
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $msc1            40
     C                   parm                    $msc2            40
     C                   parm                    $msc3            40
     C                   parm                    $msc4            40
     C                   parm                    $msc5            40

     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      $msc1 = ' '
     C                   eval      $msc2 = ' '
     C                   eval      $msc3 = ' '
     C                   eval      $msc4 = ' '
     C                   eval      $msc5 = ' '

     C     itkey         chain     itemext1
     C                   if        %found(itemext1)
     C                   eval      $msc1 = ikmsc1
     C                   eval      $msc2 = ikmsc2
     C                   eval      $msc3 = ikmsc3
     C                   eval      $msc4 = ikmsc4
     C                   eval      $msc5 = ikmsc5
     C                   endif

