      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PIRWRKORD#  Get next work order number
     *  24 February 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*   02/24/07  DAS  5.10
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File specs
     *----------------------------------------------------------------

     Fpirwrkord#uf a e           k disk
     Fkitordh   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D kyord           s                   like(kohord)
     D next#           s              7  0

     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehose.
     *
     *    Returned Parameters
     *      $NXTNM  Next work transfer order number
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $nxtnm            7 0

     *  Get record with next number.  Create it if necessary.

     C     $pwhse        chain(e)  pirwrkord#
     C                   if        not %found
     C                   eval      nxowhs = $pwhse
     C                   eval      nxonum = 0
     C                   write     nxorec
     C     $pwhse        chain(e)  pirwrkord#
     C                   endif
     C                   eval      next# = nxonum

     *  File contains the next sequence number to use.  If it
     *  has already been used then keep adding 1 until we find one
     *  that hasn't been used (we will take the chance that all
     *  9999999 have not been used).

     C                   dow       forever = forever
     C                   if        next# = 0
     C                   eval      next# = 1
     C                   endif
     C                   eval      kyord = next#
     C     fileky        setll     kitordh                                50
     C                   if        not *in50
     C                   leave
     C                   endif
     C                   add       1             next#
     C                   enddo

     *  Return the unique sequence number.

     C                   eval      $nxtnm = next#

     *  Update the file with the next number to be used.

     C     next#         add       1             nxonum
     C                   update    nxorec
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for TORDH.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    kyord

     C                   endsr
