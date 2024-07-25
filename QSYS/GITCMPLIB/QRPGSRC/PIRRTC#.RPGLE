      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PIRRTC#     Get next RTC Count Id
     *  28 May 2019
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions:
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
     *    $NXTNM  Next Count Id
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            7 0
     C     *dtaara       define    pirrtc        next#             7 0
     C     *lock         in        next#
     *
     C                   if        next# = 0
     C                             or next# >= 9999998
     C                   eval      next# = 1
     C                   endif
     *
     *  Return the unique sequence number.
     *
     C                   eval      $nxtnm = next#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             next#
     C                   out       next#
     C                   return
