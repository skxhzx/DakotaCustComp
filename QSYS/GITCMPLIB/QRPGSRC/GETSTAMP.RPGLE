     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETSTAMP    Get stamping unit for a transaction
     *  05 August, 2006
     *  Hemant Kapadia
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
510 A*   08/05/06  HNK  5.10
     *     - Created.
     *
510aA*   12/17/06  JCJ  5.10a
     *     - Enh: Added warehouse and route id to parm list.
     *
510bA*   03/19/07  JCJ  5.10b
     *     - Enh: Added file taxrstmp.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftaxrdata2 if   e           k disk
510bAFtaxrstmp  if   e           k disk

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
510aAC                   parm                    $pwhse
510aAC                   parm                    $prtid
     C                   parm                    $ptrn#            7 0
     C                   parm                    $pstamp          16

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *    Initialize return parameters.

     C                   eval      $pstamp = *blanks
     C                   eval      $prect  = 'H'

     *   Chain to Taxrdata2 file.

     C     keytx2        chain     taxrdata2                          79

     C                   if        *in79 = *off
     C                   eval      $pstamp = txstamp
510bAc                   else
510bAC     kystmp        chain     taxrstmp
510bAC                   if        %found(taxrstmp)
510bAC                   eval      $pstamp = tsstamp
510bAC                   endif
     C                   endif

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr

     *  Define key for PLTSUM2 file.

     C     keytx2        klist
510aAC                   kfld                    $pwhse
510aAC                   kfld                    $prtid
     C                   kfld                    $ptrn#
     C                   kfld                    $prect            1

510bA*  Define key for TAXRSTMP file.

510bAC     kystmp        klist
510bAC                   kfld                    $pwhse
510bAC                   kfld                    $ptrn#

     C                   endsr
