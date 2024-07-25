     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETTPL2   Get truck pallet
     *  08 April 2004
     *  Dave Sommerville
     *
     *  ** Note **
     *
     *   This is a duplicate of GETTPLT, except that a parm was
     *   added to send back the pallet section indicator.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*   04/08/04  DAS  4.17
     *     -Created.
     *
500 A*   04/01/05  MLB  5.00
     *     -Enh: Revised program to receive new parms: $PCMD
     *      and $PQYPK. Program will send back $PQYPL.
     *
640aA*   08/23/11  JCJ  6.40a
     *     -Enh: Converted to RPGIV.
     *
750aA*   03/21/22  DAS  7.50a
     *     -Enh: Added merge transaction return parameter
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FLabel11   if   e           k disk
     Fpltsum4   if   e           k disk
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D count           s              1  0
     D forevr          s              1
     D kylbl#          s                   like(lblbl#)
     D lowplt          s              7  0
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
500 A*     $PCMD    - *FIRST - Get first truck pallet number
500 A*                *NEXT  - Get next truck pallet number
     *     $PLBL#   - Label number of merge item.
500 A*     $PQYPK   - Quantity picked.
     *
     *  Output parameters
     *
     *     $PTPLT   - Truck pallet number for merge item.
416 A*     $PMLBL   - Merge label number.
416 A*     $PMPID   - Merge label pallet ID.
     *     $PSPLT   - Split across multiple truck pallets (Y/N)
     *     $PLOW    - Truck pallet is low pallet for tran. (Y/N)
500 A*     $PQYPL   - Quantity merged onto pallet.
     *     $PRTN    - *OK      -  Truck pallet found
     *                *ERROR   -  Truck pallet not found
750aA*     $PMTRN   - Merge Trn#
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
500 AC                   parm                    $pcmd             8
     C                   parm                    $plbl#            7 0
     C                   parm                    $ptplt            7 0
416 AC                   parm                    $pmlbl            7 0
416 AC                   parm                    $pmpid            7 0
     C                   parm                    $psplt            1
     C                   parm                    $plow             1
417 AC                   parm                    $phnd2            2
500 AC                   parm                    $pqypk            5 0
500 AC                   parm                    $pqypl            5 0
     C                   parm                    $prtn             8
750aAC                   parm                    $pmtrn            7 0
     *----------------------------------------------------------------
     *  Main line
     *
     *    Initialize return parameters.
     *
     C                   eval      $ptplt = 0
     C                   eval      $psplt = 'N'
     C                   eval      $plow = 'N'
     C                   eval      $prtn = *blanks
     *
     *  Get corresponding truck (gen = 1) label.
     *
     C                   eval      count = 0
     C                   eval      kylbl# = $plbl#
500 AC                   if        $pcmd = '*FIRST  '
     C     keylb         setll     label11
500 AC                   endif
     C                   dow       forevr = forevr
     *
     *      Get corresponding label.
     *
     C     keylb         reade     label11                                79
     C                   if        *in79
     C                   select
     C                   when      count = 0
     C                   eval      $psplt = 'Y'
     C                   eval      $prtn = '*ERROR  '
     C                   when      count = 1
     C                   eval      $psplt = 'N'
     C                   other
     C                   eval      $psplt = 'Y'
     C                   endsl
     C                   leave
     C                   endif
     *
416 AC                   if        lbtype <> 'M'
416 AC                   iter
416 AC                   endif
     *
     *      If pallet is merge pallet, get next corresponding pallet.
     *
     C                   eval      dsplid = lbpal#
     C                   if        dsplgn <> 1
416aD**                   Z-ADDLBCTR#    KYLBL#
416aMC                   eval      kylbl# = lbpal#
     C     keylb         setll     label11
     C                   iter
     C                   endif
     *
     *      Otherwise, get actual truck pallet number.
     *
     C                   eval      lowplt = *hival
     C     keyps         setll     pltsum4
     C                   dow       forevr = forevr
     C     keyps         reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     C                   if        pspal# < lowplt
     C                   eval      lowplt = pspal#
     C                   endif
     *
     C                   if        psplid <> lbpal#
     C                   iter
     C                   endif
     *
     C                   eval      $ptplt = pspal#
416 AC                   eval      $pmlbl = lblbl#
750aAC                   if        %parms() >= 12
750aAC                   eval      $pmtrn = lbtrn#
750aAC                   endif
416 AC                   eval      $pmpid = lbpal#
417 AC                   eval      $phnd2 = lbhnd2
500 A*
500 A*    Send back quantity on this pallet.
500 AC                   eval      $pqypl = lbqpck
     C                   eval      $prtn = '*OK     '
     C                   enddo
     *
     C                   if        $ptplt > 0
     C                   add       1             count
     C                   if        $ptplt = lowplt
     C                   eval      $plow = 'Y'
     C                   else
     C                   eval      $plow = 'N'
     C                   endif
     C                   endif
500 A*
500 A*    Quantity being picked for this order is split
500 A*    between multiple merge pallets. Print selection
500 A*    labels for quantity being put on this merge pallet.
500 AC                   if        lbqpck <> $pqypk
500 AC                   eval      $psplt = 'Y'
500 AC                   leave
500 AC                   endif
     *
     C                   enddo
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define key for LABEL11 file.
     *
     C     keylb         klist
     C                   kfld                    kylbl#
     *
     *  Define key for PLTSUM4 file.
     *
     C     keyps         klist
     C                   kfld                    lbtrn#
     *
     C                   endsr
