      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PIRCADEC#   Get next Cadec number
     *  14 July 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
530 A*  11/10/09  MLB  5.30
     *    - Fix: Revised program to check if counter has reached
     *      99,998 then set counter back to one.
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
     *    $NXTNM  Next Cadec number
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            5 0
     C     *dtaara       define    pircadec      next#             5 0
     C     *lock         in        next#
     *
     C                   if        next# = 0
530 AC                             or next# >= 99998
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
