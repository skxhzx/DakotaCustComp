     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

      *----------------------------------------------------------------
      *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *----------------------------------------------------------------
      *
      *  DRICRTCMD   Dakota realtime interface program - Create commands
      *  01 October 2001
      *  Dave Sommerville
      *
      *  Revisions
      *
416 A *    10/01/01  DAS  4.16
      *      - Created.
      *
416aA *    10/12/01  DAS  4.16a
      *      - Added *ITEMADJ and *SLOT.
      *
416bA *    10/31/01  DAS  4.16a
      *      - Added *PRTYRPL.
      *
416cA *    11/07/01  DAS  4.16c
      *      - Added *SLOTDEF.
      *      - Changed *POIMP to *PO.
      *
416dA *    12/20/01  DAS  4.16d
      *      - Added *ITEMQTY.
      *
416eA *    01/10/02  DAS  4.16e
      *      - Added *DEPT and *DESIG.
      *
416fA *    02/09/02  DAS  4.16f
      *      - Added *XDOCK.
      *
416gA *    05/30/02  DAS  4.16g
      *      - Added *ORD.
      *
640aA *    04/12/12  DAS  6.40a
      *      - Added *ZONEH.
      *
640bA *    04/26/12  DAS  6.40b
      *      - Added *TRUCKD.
      *
640cA *    05/05/12  DAS  6.40c
      *      - Added *ZONED .
      *
640dA *    10/02/12  DAS  6.40d
      *      - Added *UCIINFO, *LICINFO, *LICENSE, *REDP
      *
650aA *    11/19/13  DAS  6.50a
      *      - Added *ORDC
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Notes
      *
      *    This program creates all missing Dakota commands.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  File Specs
      *----------------------------------------------------------------

     Fdrifile   o    e           k disk

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------

     C                   eval      dricmd = '*ITEM'
     C                   eval      dripg1 = 'DRIITEM'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Item Maintenance'
     C                   write     drirec                               79

416aAC                   eval      dricmd = '*ITEMADJ'
     C                   eval      dripg1 = 'DRIITEMADJ'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Item Adjustments'
     C                   write     drirec                               79

     C                   eval      dricmd = '*PO'
     C                   eval      dripg1 = 'DRIPO'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Purchase Order Maintenance'
     C                   write     drirec                               79

416aAC                   eval      dricmd = '*SLOT'
     C                   eval      dripg1 = 'DRISLOT'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Slot Maintenance'
     C                   write     drirec                               79

416bAC                   eval      dricmd = '*PRTYRPL'
     C                   eval      dripg1 = 'DRIPRTYRPL'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Priority Replenishments'
     C                   write     drirec                               79

416cAC                   eval      dricmd = '*SLOTDEF'
     C                   eval      dripg1 = 'DRISLOTDEF'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Slot Def Maintenance'
     C                   write     drirec                               79

416dAC                   eval      dricmd = '*ITEMQTY'
     C                   eval      dripg1 = 'DRIITEMQTY'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Item Warehouse Quantity'
     C                   write     drirec                               79

416eAC                   eval      dricmd = '*DEPT'
     C                   eval      dripg1 = 'DRIDEPT'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Department Maintenance'
     C                   write     drirec                               79

416eAC                   eval      dricmd = '*DESIG'
     C                   eval      dripg1 = 'DRIDESIG'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Designation Maintenance'
     C                   write     drirec                               79

416fAC                   eval      dricmd = '*XDOCK'
     C                   eval      dripg1 = ' '
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Crossdocking'
     C                   write     drirec                               79

416gAC                   eval      dricmd = '*ORD'
     C                   eval      dripg1 = 'DRIORD'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Order Maintenance'
     C                   write     drirec                               79

640aAC                   eval      dricmd = '*ZONEH'
     C                   eval      dripg1 = 'DRIZONEH'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Zone Header Maintenance'
     C                   write     drirec                               79

640bAC                   eval      dricmd = '*TRUCKD'
     C                   eval      dripg1 = 'DRITRUCKD'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Truck Detail Maintenance'
     C                   write     drirec                               79

640cAC                   eval      dricmd = '*ZONED'
     C                   eval      dripg1 = 'DRIZONED'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Zone Detail Maintenance'
     C                   write     drirec                               79

640dAC                   eval      dricmd = '*LICINFO'
     C                   eval      dripg1 = 'DRILICINFO'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'License Information'
     C                   write     drirec                               79

640dAC                   eval      dricmd = '*UCIINFO'
     C                   eval      dripg1 = 'DRIUCIINFO'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'UCI Informaiton'
     C                   write     drirec                               79

640dAC                   eval      dricmd = '*LICENSE'
     C                   eval      dripg1 = 'DRILICENSE'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'License Tracking'
     C                   write     drirec                               79

640dAC                   eval      dricmd = '*REDP'
     C                   eval      dripg1 = 'DRIREDP'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Red Prairie'
     C                   write     drirec                               79

650aAC                   eval      dricmd = '*ORDC'
     C                   eval      dripg1 = 'DRIORDC'
     C                   eval      dripg2 = ' '
     C                   eval      dridsc = 'Selection Catchweights'
     C                   write     drirec                               79

     C                   eval      *inlr = *on
     C                   Return
