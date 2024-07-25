      *===================================================================
      *
      *  Name .......... C#LICENSE
      *  Description ... Dakota realtime interface layout for *LICENSE
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
600 A *   10/29/08  DAS  6.00
      *     - Created.
      *
600aA *   06/04/09  DAS  6.00a
      *     - Version 2 fields (Slot Fifo info)
      *
640aA *   05/31/11  DAS  6.40a
      *     - Version 3 fields (Slot Status)
      *         - $liItmChg - Used to identify an TFR w/ item change.
      *         - $liToStat, $liFrmStat
      *
650aA *   02/25/13  LMC  6.50a
      *     - Version 4 fields (Slot Designation)
      *         - $liToDesg, $liFrmDesg
      *
650bA *   11/19/14  KDE  6.50b
      *     - Version 5 fields (Production Module)
      *
710 A *   02/13/17  KDE  7.10
      *     - Version 6 fields (Production Module)
      *
710aA *   07/20/16  LMC  7.10a
      *     - Version 7 fields (UCI Tracking)
      *     - $LICENSE2 was maxed out, after the dri aged uci, so we
      *       moved $liRmUciE and $liRmUciu to the beginning of
      *       $LICENSE3.
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding indicator field.
      *       4) Create corresponding error indicator field.
      *
      *   - Each field should have a corresponding indicator field. This
      *     field is used to indicate if the field is being used (sent).
      *     The only exceptions are the warehouse and item fields, which
      *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
      *   - Most fields should have a corresponding error flag field. This
      *     field is used to indicate if the field caused an error or a
      *     warning. Values are 0 = No error/warning, 1 = Error and
      *     2 = Warning.
      *
      *===================================================================

     D $license        ds                  inz
710aMD  $liver#                       2s 0 Inz(7)

      * The following fields must always be sent. No error checking is done.

      * Employee number

     D  $liEmp#                       5  0

      * User id

     D  $liUser                      10

      * Calling program

     D  $liPgm                       10

      * Job name / number

     D  $liJob                       10
     D  $liJobn                       6

      * DRISLOT command

     D  $liDRISlot                   10

      * The following fields are only sent when needed by the subcommand.

      * Timestamp fields

     D  $liStampSys                    z
     D   $liStampSysE                 1
     D   $liStampSysU                  n
     D  $liStampUc                     z
     D   $liStampUcE                  1
     D   $liStampUcU                   n

      * License tran#

     D  $liLTrn                       7  0
     D   $liLTrnE                     1
     D   $liLTrnU                      n

      * Action code

     D  $liAction                     3
     D   $liActionE                   1
     D   $liActionU                    n

      * Transaction number

     D  $liTrn#                       7  0
     D   $liTrn#E                     1
     D   $liTrn#U                      n

      * Employee Transaction number

     D  $liETrn#                      7  0
     D   $liETrn#E                    1
     D   $liETrn#U                     n

      * Label number

     D  $liLbl#                       7  0
     D   $liLbl#E                     1
     D   $liLbl#U                      n

      * Action quantities

     D  $liAQty1                      7  0
     D   $liAQty1E                    1
     D   $liAQty1U                     n
     D  $liAQty2                      7  0
     D   $liAQty2E                    1
     D  $liAQty3                      7  0
     D   $liAQty3E                    1

      * Exception code

     D  $liExcd                       8
     D   $liExcdE                     1
     D   $liExcdU                      n

      * Original license plate

     D  $liOLcns                     15
     D   $liOLcnsE                    1
     D   $liOLcnsU                     n

      * To License plate

     D  $liToLcns                    15
     D   $liToLcnsE                   1
     D   $liToLcnsU                    n

      * To license plate - Old
      *   Note, these fields are for internal use within
      *   DRILICENSE. There is no reason to initialize
      *   them in the calling progarm because there is
      *   no old "To" license.

     D  $liToOldLcns                 15
     D   $liToOldLcnsE...
     D                                1
     D   $liToOldLcnsU...
     D                                 n

      * To License verified by user

     D  $liToVrfy                     1
     D   $liToVrfyE                   1
     D   $liToVrfyU                    n

      * To Resulting quantites

     D  $liToRQty1                    7  0
     D   $liToRQty1E                  1
     D   $liToRQty1U                   n
     D  $liToRQty2                    7  0
     D   $liToRQty2E                  1
     D  $liToRQty3                    7  0
     D   $liToRQty3E                  1

      * To Location code

     D  $liToCode                     1
     D   $liToCodeE                   1
     D   $liToCodeU                    n

      * To Location area

     D  $liToArea                    15
     D   $liToAreaE                   1
     D   $liToAreaU                    n

      * To Warehouse

     D  $liToWhse                     3  0
     D   $liToWhseE                   1
     D   $liToWhseU                    n

      * To Warehouse department

     D  $liToWhdp                     5
     D   $liToWhdpE                   1
     D   $liToWhdpU                    n

      * To Slot fields

     D  $liToDisp                    12
     D   $liToDispE                   1
     D   $liToDispU                    n
     D  $liToAisl                     3
     D   $liToAislE                   1
     D   $liToAislU                    n
     D  $liToLoc                      3  0
     D   $liToLocE                    1
     D   $liToLocU                     n
     D  $liToRlvl                     2  0
     D   $liToRlvlE                   1
     D   $liToRlvlU                    n
     D  $liToHand                     2
     D   $liToHandE                   1
     D   $liToHandU                    n

      * To Pallet position

     D  $liToPos                      3  0
     D   $liToPosE                    1
     D   $liToPosU                     n

      * To Base slot

     D  $liToBase                    12
     D   $liToBaseE                   1
     D   $liToBaseU                    n

      * To Item

     D  $liToItem                    15
     D   $liToItemE                   1
     D   $liToItemU                    n

      * To Item type

     D  $liToIType                    1
     D   $liToITypeE                  1
     D   $liToITypeU                   n

      * To Slot item

     D  $liToSItem                   15
     D   $liToSItemE                  1
     D   $liToSItemU                   n

      * To Slot item type

     D  $liToSIType                   1
     D   $liToSITypeE                 1
     D   $liToSITypeU                  n

      * To Slot priority

     D  $liToPrty                     1  0
     D   $liToPrtyE                   1
     D   $liToPrtyU                    n

      * To Entered date

     D  $liToEntD                     8  0
     D   $liToEntDE                   1
     D   $liToEntDU                    n

      * To Expiration date

     D  $liToExpD                     8  0
     D   $liToExpDE                   1
     D   $liToExpDU                    n

      * To Customer order number

     D  $liToOrd                      7  0
     D   $liToOrdE                    1
     D   $liToOrdU                     n

      * To Customer order seq number

     D  $liToSeq                      5  0
     D   $liToSeqE                    1
     D   $liToSeqU                     n

     D $license2       ds

      * From license plate - New

     D  $liFrmNewLcns                15
     D   $liFrmNewLcnsE...
     D                                1
     D   $liFrmNewLcnsU...
     D                                 n

      * From license plate - Old

     D  $liFrmOldLcns                15
     D   $liFrmOldLcnsE...
     D                                1
     D   $liFrmOldLcnsU...
     D                                 n

      * From License verified by user

     D  $liFrmVrfy                    1
     D   $liFrmVrfyE                  1
     D   $liFrmVrfyU                   n

      * From Resulting quantites

     D  $liFrmRQty1                   7  0
     D   $liFrmRQty1E                 1
     D   $liFrmRQty1U                  n
     D  $liFrmRQty2                   7  0
     D   $liFrmRQty2E                 1
     D  $liFrmRQty3                   7  0
     D   $liFrmRQty3E                 1

      * From Warehouse

     D  $liFrmWhse                    3  0
     D   $liFrmWhseE                  1
     D   $liFrmWhseU                   n

      * From Warehouse department

     D  $liFrmWhdp                    5
     D   $liFrmWhdpE                  1
     D   $liFrmWhdpU                   n

      * From Slot fields

     D  $liFrmDisp                   12
     D   $liFrmDispE                  1
     D   $liFrmDispU                   n
     D  $liFrmAisl                    3
     D   $liFrmAislE                  1
     D   $liFrmAislU                   n
     D  $liFrmLoc                     3  0
     D   $liFrmLocE                   1
     D   $liFrmLocU                    n
     D  $liFrmRlvl                    2  0
     D   $liFrmRlvlE                  1
     D   $liFrmRlvlU                   n
     D  $liFrmHand                    2
     D   $liFrmHandE                  1
     D   $liFrmHandU                   n

      * From Pallet position

     D  $liFrmPos                     3  0
     D   $liFrmPosE                   1
     D   $liFrmPosU                    n

      * From Base slot

     D  $liFrmBase                   12
     D   $liFrmBaseE                  1
     D   $liFrmBaseU                   n

      * From Item

     D  $liFrmItem                   15
     D   $liFrmItemE                  1
     D   $liFrmItemU                   n

      * From Item type

     D  $liFrmIType                   1
     D   $liFrmITypeE                 1
     D   $liFrmITypeU                  n

      * From Slot item

     D  $liFrmSItem                  15
     D   $liFrmSItemE                 1
     D   $liFrmSItemU                  n

      * From Slot item type

     D  $liFrmSIType                  1
     D  $liFrmSITypeE                 1
     D  $liFrmSITypeU                  n

      * Pulled license number

     D  $liPullLcns                  15
     D   $liPullLcnse                 1
     D   $liPullLcnsu                  n
600aA
600aA * Version 2 fields
600aA
      * Fifo slot information

      *   First FIFO License info

     D  $liFirstFifoEntD...
     D                                8  0
     D  $liFirstFifoExpD...
     D                                8  0
     D  $liFirstFifoPrty...
     D                                1  0

      *   First non-expired FIFO License info

     D  $liFirstNEFifoEntD...
     D                                8  0
     D  $liFirstNEFifoExpD...
     D                                8  0
     D  $liFirstNEFifoPrty...
     D                                1  0

      *   Last FIFO License info

     D  $liLastFifoEntD...
     D                                8  0
     D  $liLastFifoExpD...
     D                                8  0
     D  $liLastFifoPrty...
     D                                1  0
640aA
640aA * Version 3 fields
640aA
      * To/From Statu codes

     D  $liItmChg                     1
     D   $liItmChgE                   1
     D   $liItmChgU                    n

     D  $liToStat                     2
     D   $liToStatE                   1
     D   $liToStatU                    n

     D  $liFrmStat                    2
     D   $liFrmStatE                  1
     D   $liFrmStatU                   n
650aA
650aA * Version 4 fields
650aA
      * To/From Designamtion Codes

     D  $liToDesg                     5
     D   $liToDesgE                   1
     D   $liToDesgU                    n

     D  $liFrmDesg                    5
     D   $liFrmDesgE                  1
     D   $liFrmDesgU                   n
650bA
650bA * Version 5 fields
650bA
      * Production Module Additions

      * Mfg Line Number

     D  $liMfgLne                     3  0
     D   $liMfgLnee                   1
     D   $liMfgLneu                    n

      * GS1 Data

     D  $liGs1                       50
     D   $liGs1e                      1
     D   $liGs1u                       n

      * Serial Number

     D  $liSer#                      20
     D   $liSer#e                     1
     D   $liSer#u                      n

      * Prod. Secondary Item Number

     D  $liPrdSItm                   15
     D   $liPrdSItme                  1
     D   $liPrdSItmu                   n

      * Prod. Catch Weight/Scanned Weight

     D  $liPrdWgt                     9s 3
     D   $liPrdWgte                   1
     D   $liPrdWgtu                    n

      * Prod. Tare Weight

     D  $liTareWgt                    9s 3
     D   $liTareWgte                  1
     D   $liTareWgtu                   n

      * Prod. Customer Number

     D  $liPrdCust                   11  0
     D   $liPrdCuste                  1
     D   $liPrdCustu                   n

      * Prod. Station ID

     D  $liPrdSta                     2
     D   $liPrdStae                   1
     D   $liPrdStau                    n

      * Prod. UOM

     D  $liPrdUom                     2
     D   $liPrdUome                   1
     D   $liPrdUomu                    n

      * Prod. Work Order

     D  $liPrdWO                     13
     D   $liPrdWoe                    1
     D   $liPrdWou                     n
710 A
710 A * Version 6 fields
710 A
      * Raw MAterial Dry Age UCI
     D  $liRmUci                    100

710aAD $license3       ds

     D   $liRmUciE                    1
     D   $liRmUciu                     n
710aA
710aA * Version 7
710aA
      * UCI Tracking Additions
      *---------------------
      * UCI Tracking Time Stamp for Partial Movement

     D  $liUCIts                       Z
     D   $liUCItse                    1
     D   $liUCItsu                     n

      * UCI Tracking for type of adjustment scanning

     D  $liUCItype                    2
     D   $liUCItypee                  1
     D   $liUCItypeu                   n
