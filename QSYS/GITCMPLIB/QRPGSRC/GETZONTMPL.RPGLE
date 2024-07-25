640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETZONTMPL   Get zone template
     *  07 April 2012
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
640 A*    04/07/12  JCJ  6.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
530 AFtruckh    if   e           k disk
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse
     *      $prtid  Route ID
     *
     *    Returned Parameters
     *      $ptruk  Truck
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10
     C                   parm                    $ptmpl           10
     *
     *  Define key for TRUCKH file.
     *
     C     trkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     C     trkey         chain     truckh
     C                   if        %found(truckh) and thtype = 'T'
     C                   eval      $ptmpl =  thztmp
     C                   else
     C                   eval      $ptmpl =  $ptruk
     C                   endif
