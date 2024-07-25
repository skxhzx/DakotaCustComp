     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PIRWAVE#    Get next Wave number
     *  20 January 2020
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    - None -
     *
     *    Returned Parameters
     *    $NXTNM  Next Wave number (0000000 is not used)
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            7 0
     C     *dtaara       define    pirwave#      next#             7 0
     C     *lock         in        next#
     *
     *  Return the unique sequence number.
     *
     c                   if        next# = *zeros
     c                   eval      next#=1
     c                   endif
     c                   eval      $nxtnm=next#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             next#
     C                   out       next#
     C                   return
