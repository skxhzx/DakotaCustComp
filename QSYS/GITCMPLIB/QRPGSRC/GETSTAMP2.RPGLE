     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETSTAMP    Get stamping unit for a transaction
     *  26 June, 2009
     *  Jeffrey Jahnke
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
520 A*   06/26/09  JCJ  5.20
     *     - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fckrdata2  if   e           k disk
     Fckrstmp   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D $pwhse          s              3  0
     D $prtid          s              5

     *----------------------------------------------------------------
     *  Input parameters
     *
     *     $ptrn#   - Transaction number
     *
     *  Output parameters
     *
     *     $pstamp  - Stamping unit
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $ptrn#            7 0
     C                   parm                    $pstamp          16

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *    Initialize return parameters.

     C                   eval      $pstamp = *blanks
     C                   eval      $prect  = 'H'

     *   Chain to Taxrdata2 file.

     C     keyck2        chain     ckrdata2                           79

     C                   if        *in79 = *off
     C                   eval      $pstamp = ckstamp
     c                   else
     C     kystmp        chain     ckrstmp
     C                   if        %found(ckrstmp)
     C                   eval      $pstamp = tsstamp
     C                   endif
     C                   endif

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr

     *  Define key for PLTSUM2 file.

     C     keyck2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $ptrn#
     C                   kfld                    $prect            1

     *  Define key for CKRSTMP file.

     C     kystmp        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#

     C                   endsr
