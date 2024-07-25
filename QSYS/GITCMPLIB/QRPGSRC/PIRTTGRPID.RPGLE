      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PIRTTGRPID   Get next Trax route group Id number.
     *  21 Nov 2014
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650aA*  11/21/14  RBD  6.50a
     *    - Created.
     *
     *----------------------------------------------------------------
     *
     *  Variables
     *
     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    - None -
     *
     *    Returned Parameters
     *    $NXTNM  Next Trax route group iD number
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            5 0
     *
     C     *dtaara       define    pirttgrpid    next#             5 0
     C     *lock         in        next#
     *
     C                   if        next# = 0
     C                             or next# >= 99998
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
