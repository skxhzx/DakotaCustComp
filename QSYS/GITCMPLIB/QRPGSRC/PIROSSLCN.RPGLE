500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PIROSSLCN   Get next Off Site Storage license
     *  23 April 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
     *    04/23/09  DAS  6.00
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flicactive if   e           k disk

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D $pWhse          s              3s 0
     D $pStgLoc        s              1
     D $pLcns          s             15

     D forever         s               n
     D next#           s              7  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse     Warehouse
     *      $pStgLoc   Outside storage location
     *
     *    Returned Parameters
     *      $plcns   License
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse
     C                   parm                    $pStgLoc
     C                   parm                    $pLcns

     *----------------------------------------------------------------
     * Key list
     *----------------------------------------------------------------

     C     lakey         klist
     C                   kfld                    $pWhse
     C                   kfld                    $pLcns

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

     C     *dtaara       define    pirosslcn     next#
     C     *lock         in        next#

     *  Data area contains the next sequence number to use.  If it
     *  has already been used then keep adding 1 until we find one
     *  that hasn't been used (we will take the chance that all
     *  9999999 have not been used).

     C                   dow       forever = forever

     C                   if        next# = 0 or next# = 9999999
     C                   eval      next# = 1
     C                   endif

     C                   eval      $plcns = 'OS' + $pStgLoc
     C                                    + %trim(%editc(next#:'X'))

     C     lakey         setll(e)  licactive
     C                   if        not %equal(licactive)
     C                   leave
     C                   endif

     C                   eval      next# += 1

     C                   enddo

     *  Update the data area with the next number to be used.

     C                   eval      next# += 1
     C                   out       next#
     C                   return
