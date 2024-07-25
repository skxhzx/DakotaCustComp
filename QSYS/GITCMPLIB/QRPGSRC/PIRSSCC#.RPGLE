      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PIRSSCC#   Get next ASN sscc-18 number
     *  14 January 2008
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/14/08  RBD  5.20  P#00003
     *      - Created for Harbor.
     *
520aA*    02/11/08  DAS  5.20  P#00003
     *      - Revised paramter size to 9.0 to match data area.
     *
     *----------------------------------------------------------------
     *
     *  Variables
     *
     D stop            s              1
     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    - None -
     *
     *    Returned Parameters
     *    $NXTNM15  Next sscc-18 number
     *
     *----------------------------------------------------------------
     * Main Line

     C     *entry        plist
520aMC                   parm                    $nxtnm            9 0
520aDC**                 parm                    $nxtnm15         15 5

     C     *dtaara       define    pirsscc       next#             9 0
     C     *lock         in        next#

     C                   if           next# = 0
     C                             or next# = 999999999
     C                   eval      next# = 1
     C                   endif

     *  Return the unique sequence number.

520aDC**                 eval      $nxtnm15 = next#
520aMC                   eval      $nxtnm = next#

     *  Update the data area with the next number to be used.

     C                   eval      next# = next# + 1
     C                   out       next#
     C                   return
