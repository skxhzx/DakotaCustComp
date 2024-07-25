      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RECALL#  Get next GUI Recall Report number
     *  25 September 2015
     *  Retha Davis
     *
     *  Revisions:
     *
700aA*    09/25/15  RBD  7.00a
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum004h   if   e           k disk

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D $pWhse          s              3  0
     D $pRecall#       s              7  0

     D forever         s               n
     D next#           s              7  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse     Warehouse
     *
     *    Returned Parameters
     *      $pRecall#  Next GUI Recall Report number
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse
     C                   parm                    $pRecall#

     *----------------------------------------------------------------
     * Key list
     *----------------------------------------------------------------

     C     sukey         klist
     C                   kfld                    $pWhse
     C                   kfld                    next#

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

     C     *dtaara       define    Recall#       next#
     C     *lock         in        next#

     *  Data area contains the next sequence number to use.  If it
     *  has already been used then keep adding 1 until we find one
     *  that hasn't been used (we will take the chance that all
     *  9999999 have not been used).

     C     sukey         setll(e)  sum004h
     C                   dow       forever = forever

     C                   if        next# = 0 or next# = 9999999
     C                   eval      next# = 1
     C                   endif

     C     sukey         reade     sum004h
     C                   if        %eof(sum004h)
     C                   leave
     C                   endif

     C                   eval      next# += 1

     C                   enddo

     *  Update return parm with GUI Recall Report number.

     C                   eval      $pRecall# = next#

     *  Update the data area with the next number to be used.

     C                   eval      next# += 1
     C                   out       next#
     C                   return
