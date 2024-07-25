      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  MJKVRTPCK   MJ Kellner pick slots that allow virtuals.
     *  20 February 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
520 A*  02/20/08  DAS  5.20  P#00014
     *    - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhdp  Warehouse department
     *      $pDisp  Slot display
     *
     *    Returned Parameters
     *      $pAllow     Y = Virtual slots allowed.
     *                  N = Virtual slots not allowed.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pWhdp            5
     C                   parm                    $pDisp           12
     C                   parm                    $pAllow           1

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      $pAllow = 'N'

     C                   if        $pWhdp='DRY' and $pDisp='K0120'
     C                             or $pWhdp='DRY' and $pDisp='K0130'
     C                             or $pWhdp='DRY' and $pDisp='K0140'
     C                             or $pWhdp='DRY' and $pDisp='K0150'
     C                             or $pWhdp='DRY' and $pDisp='K0160'
     C                             or $pWhdp='DRY' and $pDisp='KFLR'
     C                             or $pWhdp='REF' and $pDisp='I1210'
     C                             or $pWhdp='REF' and $pDisp='J01FLR'
     C                             or $pWhdp='REF' and $pDisp='MFLR'
     C                             or $pWhdp='FRZ' and $pDisp='S0110'
     C                             or $pWhdp='FRZ' and $pDisp='S0120'
     C                             or $pWhdp='FRZ' and $pDisp='S0130'
     C                             or $pWhdp='FRZ' and $pDisp='S0140'
     C                             or $pWhdp='FRZ' and $pDisp='S0150'
     C                             or $pWhdp='FRZ' and $pDisp='S0160'
     C                             or $pWhdp='FRZ' and $pDisp='N40'
     C                             or $pWhdp='FRZ' and $pDisp='SFLR'
     C                   eval      $pAllow = 'Y'
     C                   endif

     C                   eval      *inlr = *on
