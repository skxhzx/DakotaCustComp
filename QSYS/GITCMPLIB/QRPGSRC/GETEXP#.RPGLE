     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETEXPF  Get next StanPack export file number
     *  22 February 2007
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*  02/22/07  MLB  5.10
     *    - Enh: Created.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program receives a command identifying the export
     *    process. The appropriate dtaara will be retrieved and
     *    the file counter incremented. The new file number will be
     *    passed back to the calling program for use in the export
     *    file name.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     *
     *----------------------------------------------------------------
     *  Variable/Constant definitions
     *
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PType  *ADJ      -  Adjustments
     *              *INVCNT   -  Inventory counts
     *              *ORD      -  Customer orders
     *              *PO       -  Purchase orders
     *              *RETURNS  -  Inventory counts
     *
     *    Returned Parameters
     *      $Pexpnbr    Remote File number.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $ptype            8
     C                   parm                    $pexpnbr          1
     *
     *----------------------------------------------------------------
     * Main line
     *
     C                   select
     C                   when      $ptype = '*ADJ'
     C                   exsr      getadjexpnbr
     *
     C                   when      $ptype = '*INVCNT'
     C                   exsr      getinvexpnbr
     *
     C                   when      $ptype = '*ORD'
     C                   exsr      getordexpnbr
     *
     C                   when      $ptype = '*PO'
     C                   exsr      getpoexpnbr
     *
     C                   when      $ptype = '*RETURNS'
     C                   exsr      getrtnexpnbr
     *
     C                   other
     C                   eval      $pexpnbr = '1'
     *
     C                   endsl
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine.
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  GetAdjExpNbr -  Get Adjustment Export file number.
     *
     C     GetAdjExpNbr  begsr
     *
     C     *dtaara       define    expfadj#      nextadj#          1 0
     C     *lock         in        nextadj#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             nextadj#
     *
     C                   eval      $pexpnbr = %editc(nextadj#:'X')
     *
     C                   out       nextadj#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  GetInvExpNbr -  Get Inventory Count Export file number.
     *
     C     GetInvExpNbr  begsr
     *
     C     *dtaara       define    expfinv#      nextinv#          1 0
     C     *lock         in        nextinv#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             nextinv#
     *
     C                   eval      $pexpnbr = %editc(nextinv#:'X')
     *
     C                   out       nextinv#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  GetOrdExpNbr -  Get Customer Orders Export file number.
     *
     C     GetOrdExpNbr  begsr
     *
     C     *dtaara       define    expford#      nextord#          1 0
     C     *lock         in        nextord#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             nextord#
     *
     C                   eval      $pexpnbr = %editc(nextord#:'X')
     *
     C                   out       nextord#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  GetPOExpNbr -  Get Purchase Order Export file number.
     *
     C     GetPOExpNbr   begsr
     *
     C     *dtaara       define    expfpo#       nextpo#           1 0
     C     *lock         in        nextpo#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             nextpo#
     *
     C                   eval      $pexpnbr = %editc(nextpo#:'X')
     *
     C                   out       nextpo#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  GetRtnExpNbr -  Get Customer Returns Export file number.
     *
     C     GetRtnExpNbr  begsr
     *
     C     *dtaara       define    expfrtn#      nextrtn#          1 0
     C     *lock         in        nextrtn#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             nextrtn#
     *
     C                   eval      $pexpnbr = %editc(nextrtn#:'X')
     *
     C                   out       nextrtn#
     *
     C                   endsr
     *
