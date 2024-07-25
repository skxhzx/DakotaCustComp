      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKDESIGSP   Check for special meats designation code
     *  12 March 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    03/12/07  DAS  5.10
     *      - Created.
     *
640aA*    05/20/11  DAS  6.40
     *      - Revised to work with new 8-digit item numbers
     *
650 A*    06/09/14  MLB  6.50
     *      - Enh: Added client custom code support to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    06/09/14  MLB  CBI  P#01218
     *      - Revised pgm to exit when client is GWB. Temporary byass
     *        until this support is needed.
     *
CBIaA*    12/28/21  NLK  CBIa
     *      - REV: remove cheneygwb and user cbigwb (id#cheneyg n/a)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdesigsp   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a15             s              1    dim(15)

650 A*----------------------------------------------------------------
650 A*  Client ID
650 A*
650 AD @getcl          c                   const('GETCLIENT')
650 A*
CBI A /COPY QCOPYSRC,ID#CHENEY
CBIaD * /COPY QCOPYSRC,ID#CHENEYG

     *----------------------------------------------------------------
     *  Constants / Variables
     *----------------------------------------------------------------

     D numbers         c                   '0123456789'

     D i               s              3  0
     D pos             s              3  0
     D valuea          s              2
     D value           s              2  0

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $pdesig  -  Designation code
     *     $pitem   -  Item number
     *
     *  Output parameters
     *
     *     $pwhdp   -  Department
     *     $pdisp   -  Slot display
     *     $pchkdgt -  Check digit
     *     $prtn    -  *FOUND   -  Designation code found
     *                 *NOTFND  -  Not found
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdesig           5
     C                   parm                    $pitem           15
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     C                   parm                    $pchkdgt          3 0
     C                   parm                    $prtn             8

     C                   eval      $pwhdp = ' '
     C                   eval      $pdisp = ' '
     C                   eval      $pchkdgt = 0
     C                   eval      $prtn  = '*NOTFND'
CBI A*  Bypass special meat look-up at this time for GWB.
CBI AC                   if        client = Cheney
CBIaMC                             and clientloc = cbigwb
CBIaD *                       **   and clientloc = Cheneygwb
CBI AC                   return
CBI AC                   endif

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  See if designation code is for specialty meats.

     C     $pdesig       chain     desigsp
     C                   if        not %found
     C                   return
     C                   endif

     C                   eval      $pwhdp = dsswhd
     C                   eval      $pdisp = dssdsp
     C                   eval      $prtn  = '*FOUND'

     *  Calculate check digit if item sent.

     *    If item not sent, get out.

     C                   if        $pitem = ' '
     C                   return
     C                   endif

     *    If item not sent, get out.

     C                   if        $pitem = ' '
     C                   return
     C                   endif
640aA
640aA*    Item length must be 8.
640aA
640aAC                   if        %len(%trimr($pitem)) <> 8
640aAC                   return
640aAC                   endif

     C                   movea     $pitem        a15

     *    If item number not numeric, get out.

640aDC**   1             do        6             i
640aMC     1             do        8             i
     C                   eval      pos = %Scan(a15(i):numbers)
     C                   if        pos = 0
     C                   return
     C                   endif
     C                   enddo
640aA
640aA*    Calculate starting position
640aA
640aAC                   if        %subst($pitem:1:2) = '00'
640aAC                   eval      i = 3
640aAC                   else
640aAC                   eval      i = 1
640aAC                   endif

     *    Now calculate check digit.

640aDC**   1             do        5             i
640aMC     i             do        7             i
     C                   eval      valuea = a15(i) + a15(i+1)
     C                   eval      value = %dec(valuea:2:0)
     C                   eval      $pchkdgt = $pchkdgt + value
     C                   enddo

     C                   return
650 A*
650 A*----------------------------------------------------------------
650 A*
650 A*  *INZSR  Initialization subroutine
650 A*
650 AC     *inzsr        begsr
650 A*
650 A* Get client id.
650 A*
650 AC                   call      @getcl
650 AC                   parm                    client           10
650 AC                   parm                    clientloc        10
650 A*
650 AC                   endsr
