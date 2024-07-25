640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETTRKTMPL   Get truck template
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
     Frtehed    if   e           k disk
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
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10

     C     rhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      $ptruk = *blanks
     C     rhkey         chain     rtehed
     C                   if        %found(rtehed)
     C                   eval      $ptruk = rhtruk
     C                   endif
