     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  DQ101     Calculate daily totals.
     F*  22 June 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    06/22/01  DAS  4.15
     F*      - Created.
     F*
416 AF*    08/17/01  DAS  4.16
     F*      - Transfer In was updating wrong qty's for brkdwn
     F*
416aAF*    09/04/01  DAS  4.16a
     F*      - Revised to not change LBUTYP for linked SSB item.
     F*        LBUTYP should always match quantity bucket used for slot
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        CHAIN INDICATOR
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FItemQty   IP   E           K DISK
     FPirItem   IF   E           K DISK
     FLabel91   IF   E           K DISK
     FItemLnk1  IF   E           K DISK
     FSlot3     IF   E           K DISK
     FDlyQty    UF A E           K DISK
     FDlyQtyT   UF A E           K DISK
     FDlyQtyO   UF A E           K DISK

      *------------------------------------------------------------------
      * Constants ...
      *------------------------------------------------------------------
     D   Forever       C                   Const('1')

      *------------------------------------------------------------------
      * Misc defs ...
      *------------------------------------------------------------------
415aAD AlcD2           s              9  0
415aAD AlcD3           s              9  0
415aAD DlyQtyTFound    s              1
415aAD DlyQtyOFound    s              1
415aAD ItemQtyDate     s              8  0
415aAD ItemQtyTime     s              6  0
415aAD ItemType        s              5
415aAD KyWhse          s                   Like(ITWhse)
415aAD KyWhse2         s                   Like(ITWhse)
415aAD KyItem          s                   Like(ITItem)
415aAD KyItem2         s                   Like(ITItem)
415aAD LastTime        s              6  0
415aAD RunDate         s              8  0
415aAD RunTime         s              6  0
415aAD Today           s              8  0
415aAD StkD2           s              9  0
415aAD StkD3           s              9  0
415aAD UMQty2          s                   Like(ITUMQ2)
415aAD UMQty3          s                   Like(ITUMQ3)
415aAD WriteORec       s              1

      *----------------------------------------------------------------
      *  Called programs
      *----------------------------------------------------------------
     D @CVTDT          C                   CONST('CVTDTE')
     D @CLCDR          C                   CONST('CLCDUR')

      *----------------------------------------------------------------
      *  Called program parameters
      *----------------------------------------------------------------
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D  $CVDR1               133    140
     D  $CVVL1               141    145  0
     D  $CVDR2               146    153
     D  $CVVL2               154    158  0
     D  $CVDR3               159    166
     D  $CVVL3               167    171  0
     D  $CVDR4               172    179
     D  $CVVL4               180    184  0
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Main line

     C*  Grab date/time when ITEMQTY was read.

     C                   Time                    ItemQtyTime
     C                   If        ItemQtyTime < LastTime
     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      ItemQtyDate = $cvd8o
     C                   EndIf
     C                   Eval      LastTime = ItemQtyTime

     C*  Get item record.

     C     KeyIq         Chain     PirItem                            79
     C     *IN79         CabEQ     *On           Bottom

     C*  Items that are not type ' ' or 'B' should not have an ItemQty rec
     C*  But we will protect against it anyway.

     C                   If        ITType <> ' ' and ITType <> 'B'
     C                   Goto      Bottom
     C                   EndIf

     C*  Get unit of measure quantities.

     C                   If        ITUMQ2 > 0
     C                   Eval      UmQty2 = ITUMQ2
     C                   Else
     C                   Eval      UmQty2 = 1
     C                   EndIf

     C                   If        ITUMQ3 > 0
     C                   Eval      UmQty3 = ITUMQ3
     C                   Else
     C                   Eval      UmQty3 = 1
     C                   EndIf

     C*  If DLYQTYT record doesn't exist ...
     C*    Assume that no corresponding DLYQTY recs exist and skip calcs.

     C     DlyQtyTFound  CABEQ     *OFF          SkipCalcs

     C*  See if DLYQTY record from last run date exists for item.
     C*    If not, skip calculations.

     C     KeyDq         Chain     DLYQTY                             79
     C     *IN79         CABEQ     *ON           SkipCalcs

     C*  Calculate totals for item

     C                   Exsr      ClcDlyTtl


     C*  Calculate slot totals for item

     C                   Exsr      ClcSltTtl

     C*  Update existing DLYQTY record.

     C                   Exsr      Iq2D2

     C                   Exsr      Chk4Diff

     C*                  Eval      DqEDte = ItemQtyDate
     C*                  Eval      DqETim = ItemQtyTime

     C*                  If        D3Stk1 <> D2Stk1
     C*                            or D3Stk2 <> D2Stk2
     C*                            or D3Stk3 <> D2Stk3
     C*                            or D3Alc1 <> D2Alc1
     C*                            or D3Alc2 <> D2Alc2
     C*                            or D3Alc3 <> D2Alc3
     C*                  Eval      DqDFlg = 1
     C*                  Else
     C*                  Eval      DqDFlg = 0
     C*                  EndIf

     C                   Update    DqRec

     C*  Calcs are done. Now create new DLYQTY record for next time.

     C     SkipCalcs     Tag

     C                   Clear                   DqRec
     C                   Eval      DqWhse = IqWhse
     C                   Eval      DqItem = IqItem
     C                   Eval      DqRDte = RunDate
     C                   Eval      DqRTim = RunTime
     C                   Eval      DqSDte = ItemQtyDate
     C                   Eval      DqSTim = ItemQtyTime
     C                   Exsr      Iq2D1
     C                   Write     DqRec

     C*  Automatically loop around and get next ItemQty record.

     C     Bottom        Tag

     C*  Last Recod Processing

     CLR                 Exsr      WrapUp

     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR

     C*  Define key for DLYQTY file.

     C     KeyDq         KList
     C                   Kfld                    DTRDte
     C                   Kfld                    DTRTim
     C                   Kfld                    IQWhse
     C                   Kfld                    IQItem

     C*  Define item key from ItemQty fields.

     C     KeyIq         KList
     C                   Kfld                    IQWhse
     C                   Kfld                    IQItem

     C*  Define item key from ItemLnk fields.

     C     KeyIt         KList
     C                   Kfld                    ILWhse
     C                   Kfld                    ILItem

     C*  Define partial key for Label file.

     C     KeyLbP        KList
     C                   Kfld                    KyWhse
     C                   Kfld                    KyItem

     C*  Define label key for SetLL

     C     KeyLb         KList
     C                   Kfld                    KyWhse
     C                   Kfld                    KyItem
     C                   Kfld                    DQSDte
     C                   Kfld                    DQSTim

     C*  Define partial key for ItemLnk file.

     C     KeyIl1        KList
     C                   Kfld                    KyWhse2
     C                   Kfld                    KyItem2

     C*  Define partial key for DltQtyO file.

     C     KeyDO         KList
     C                   Kfld                    LBLbl#

411 AC*   Define Contract quantities

     C     *LIKE         DEFINE    IQSTK1        $QSTK1
     C     *LIKE         DEFINE    IQSTK2        $QSTK2
     C     *LIKE         DEFINE    IQSTK3        $QSTK3
     C     *LIKE         DEFINE    IQALC1        $QALC1
     C     *LIKE         DEFINE    IQALC2        $QALC2
     C     *LIKE         DEFINE    IQALC3        $QALC3
     C     *LIKE         DEFINE    IQHLD1        $QHLD1
     C     *LIKE         DEFINE    IQHLD2        $QHLD2
     C     *LIKE         DEFINE    IQHLD3        $QHLD3
     C     *LIKE         DEFINE    IQTRI1        $QTRI1
     C     *LIKE         DEFINE    IQTRI2        $QTRI2
     C     *LIKE         DEFINE    IQTRI3        $QTRI3
     C     *LIKE         DEFINE    IQTRO1        $QTRO1
     C     *LIKE         DEFINE    IQTRO2        $QTRO2
     C     *LIKE         DEFINE    IQTRO3        $QTRO3
     C     *LIKE         DEFINE    IQORD1        $QORD1

     C*  Get current date.

     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $Cvd8o

     C*  Set the ItemQty date to today.

     C                   Eval      ItemQtyDate = Today

     C*  Capture Run date/time

     C                   Eval      RunDate = Today
     C                   Time                    RunTime
     C                   Eval      LastTime = RunTime

     C*  Get last record from DLYQTYT file for item.

     C     *HiVal        SetGT     DlyQtyT
     C                   Readp     DlyQtyT                                79
     C                   If        *IN79 = *On
     C                   Move      *Off          DlyQtyTFound
     C                   Else
     C                   Move      *On           DlyQtyTFound
     C                   EndIf

     C                   ENDSR

     C*----------------------------------------------------------------
     C*
     C*  Chk4Diff  Check for quantity differences.
     C*
     C     Chk4Diff      BEGSR

     C*  Convert quantities to lowest breakdown 2 quantities.

     C                   Eval      StkD2 = (D2Stk1 * UmQty2 * UmQty3) +
     C                                     (D2Stk2 * UmQty3) +
     C                                      D2Stk3

     C                   Eval      AlcD2 = (D2Alc1 * UmQty2 * UmQty3) +
     C                                     (D2Alc2 * UmQty3) +
     C                                      D2Alc3

     C                   Eval      StkD3 = (D3Stk1 * UmQty2 * UmQty3) +
     C                                     (D3Stk2 * UmQty3) +
     C                                      D3Stk3

     C                   Eval      AlcD3 = (D3Alc1 * UmQty2 * UmQty3) +
     C                                     (D3Alc2 * UmQty3) +
     C                                      D3Alc3

     C*  Now compare quantities to see if there is a difference.

     C                   If        StkD2 <> StkD3 or AlcD2 <> AlcD3
     C                   Eval      DqDFlg = 1
     C                   Else
     C                   Eval      DqDFlg = 0
     C                   EndIf


     C                   ENDSR

     C*----------------------------------------------------------------
     C*
     C*  ClcDlyTtl  Calculate daily totals for item.
     C*
     C     ClcDlyTtl     BEGSR

     C*  Clear total fields

     C                   Clear                   DQAFLG
     C                   Clear                   DQIFLG
     C                   Clear                   DQQFLG
     C*
     C                   Clear                   DQAOC1
     C                   Clear                   DQAOC2
     C                   Clear                   DQAOC3
     C*
     C                   Clear                   DQAIC1
     C                   Clear                   DQAIC2
     C                   Clear                   DQAIC3
     C*
     C                   Clear                   DQRDO1
     C                   Clear                   DQRDO2
     C                   Clear                   DQRDO3
     C*
     C                   Clear                   DQRDC1
     C                   Clear                   DQRDC2
     C                   Clear                   DQRDC3
     C*
     C                   Clear                   DQRMO1
     C                   Clear                   DQRMO2
     C                   Clear                   DQRMO3
     C*
     C                   Clear                   DQRMC1
     C                   Clear                   DQRMC2
     C                   Clear                   DQRMC3
     C*
     C                   Clear                   DQNDO1
     C                   Clear                   DQNDO2
     C                   Clear                   DQNDO3
     C*
     C                   Clear                   DQNDC1
     C                   Clear                   DQNDC2
     C                   Clear                   DQNDC3
     C*
     C                   Clear                   DQNMO1
     C                   Clear                   DQNMO2
     C                   Clear                   DQNMO3
     C*
     C                   Clear                   DQNMC1
     C                   Clear                   DQNMC2
     C                   Clear                   DQNMC3
     C*
     C                   Clear                   DQPKO1
     C                   Clear                   DQPKO2
     C                   Clear                   DQPKO3
     C*
     C                   Clear                   DQPKC1
     C                   Clear                   DQPKC2
     C                   Clear                   DQPKC3
     C*
     C                   Clear                   DQPOO1
     C                   Clear                   DQPOO2
     C                   Clear                   DQPOO3
     C*
     C                   Clear                   DQPOC1
     C                   Clear                   DQPOC2
     C                   Clear                   DQPOC3
     C*
     C                   Clear                   DQTOO1
     C                   Clear                   DQTOO2
     C                   Clear                   DQTOO3
     C*
     C                   Clear                   DQTOC1
     C                   Clear                   DQTOC2
     C                   Clear                   DQTOC3
     C*
     C                   Clear                   DQTIO1
     C                   Clear                   DQTIO2
     C                   Clear                   DQTIO3
     C*
     C                   Clear                   DQTIC1
     C                   Clear                   DQTIC2
     C                   Clear                   DQTIC3
     C*
     C                   Clear                   DQLIO1
     C                   Clear                   DQLIO2
     C                   Clear                   DQLIO3
     C*
     C                   Clear                   DQLIC1
     C                   Clear                   DQLIC2
     C                   Clear                   DQLIC3
     C*
     C                   Clear                   DQLOO1
     C                   Clear                   DQLOO2
     C                   Clear                   DQLOO3
     C*
     C                   Clear                   DQLOC1
     C                   Clear                   DQLOC2
     C                   Clear                   DQLOC3
     C*
     C                   Clear                   DQIVC1
     C                   Clear                   DQIVC2
     C                   Clear                   DQIVC3
     C*
     C                   Clear                   DQOTO1
     C                   Clear                   DQOTO2
     C                   Clear                   DQOTO3
     C*
     C                   Clear                   DQOTC1
     C                   Clear                   DQOTC2
     C                   Clear                   DQOTC3

     C                   Clear                   DTRECA
     C                   Clear                   DTRECR
     C                   Clear                   DTRECN
     C                   Clear                   DTRECP
     C                   Clear                   DTRECT
     C                   Clear                   DTRECL
     C                   Clear                   DTRECI
     C                   Clear                   DTREC@
     C                   Clear                   DTTTLR

     C*  Initialize calculated totals

     C                   eval      D3STK1 = D1STK1
     C                   eval      D3STK2 = D1STK2
     C                   eval      D3STK3 = D1STK3

     C                   eval      D3ALC1 = D1ALC1
     C                   eval      D3ALC2 = D1ALC2
     C                   eval      D3ALC3 = D1ALC3

     C*  Read labels for Base item.

     C                   eval      ItemType = '*Base'
     C                   eval      KyWhse = ItWhse
     C                   eval      KyItem = ItItem
     C                   Exsr      ReadLbls

     C*  Now look for items linked to base item.

     C                   eval      KyWhse2 = ItWhse
     C                   eval      KyItem2 = ItItem
     C                   eval      ItemType = '*Link'
     C     KeyIl1        SetLL     ItemLnk1
     C                   DoW       Forever = Forever
     C     KeyIl1        Reade     ItemLnk1                               76
     C                   If        *IN76 = *On
     C                   Leave
     C                   EndIf

     C*    Get item record.

     C     KeyIt         Chain     PirItem                            79
     C                   If        *IN79 = *On
     C                   Iter
     C                   EndIf

     C*    Ignore Normal items.

     C                   If        ITType = ' '
     C                   Iter
     C                   EndIf

     C*    Ignore Contract items for now.

     C                   If        ITType = 'C'
     C                   Iter
     C                   EndIf

     C*    Read labels for linked item.

     C                   eval      KyWhse = ILWhse
     C                   eval      KyItem = ILItem
     C                   Exsr      ReadLbls

     C                   EndDo

     C     EndClc        ENDSR

     C*----------------------------------------------------------------
     C*
     C*  ClcSltTtl  Calculate slot totals for item.
     C*
     C     ClcSltTtl     BEGSR

     C*  Clear total fields

     C                   Clear                   D4Stk1
     C                   Clear                   D4Stk2
     C                   Clear                   D4Stk3
     C                   Clear                   D4Alc1
     C                   Clear                   D4Alc2
     C                   Clear                   D4Alc3
     C                   Clear                   D4Hld1
     C                   Clear                   D4Hld2
     C                   Clear                   D4Hld3
     C                   Clear                   D4TrI1
     C                   Clear                   D4TrI2
     C                   Clear                   D4TrI3
     C                   Clear                   D4TrO1
     C                   Clear                   D4TrO2
     C                   Clear                   D4TrO3
     C                   Clear                   D4Ord1

411 AC*   Get totals for corresponding Contract items.

     C                   CALL      'UT813'
     C                   PARM                    IQWHSE
     C                   PARM                    IQITEM
     C                   PARM                    $QSTK1
     C                   PARM                    $QSTK2
     C                   PARM                    $QSTK3
     C                   PARM                    $QALC1
     C                   PARM                    $QALC2
     C                   PARM                    $QALC3
     C                   PARM                    $QHLD1
     C                   PARM                    $QHLD2
     C                   PARM                    $QHLD3
     C                   PARM                    $QTRI1
     C                   PARM                    $QTRI2
     C                   PARM                    $QTRI3
     C                   PARM                    $QTRO1
     C                   PARM                    $QTRO2
     C                   PARM                    $QTRO3
     C                   PARM                    $QORD1
     C                   PARM                    $QRTN             8

     C*  Loop through slots for item and update quantities.

     C     KeyIq         SETLL     Slot3
     C                   DoW       Forever = Forever
     C     KeyIq         READE     Slot3                                  78
     C                   If        *In78 = *On
     C                   Leave
     C                   Endif

     C*    Skip verified and zeroed slots.

     C                   If        SLStat = 'V' or SLStat = 'Z'
     C                   Iter
     C                   EndIf

     C*    Update stock quantities.

     C                   Eval      D4Stk1 = D4Stk1+SLStk1+SLRcv1-SLTfr1
     C                   Eval      D4Stk2 = D4Stk2+SLStk2+SLRcv2-SLTfr2
     C                   Eval      D4Stk3 = D4Stk3+SLStk3+SLRcv3-SLTfr3
     C*
     C*    Update allocated quantities.
     C*
     C                   Eval      D4Alc1 = D4Alc1+SLAlc1+SLPck1
     C                   Eval      D4Alc2 = D4Alc2+SLAlc2+SLPck2
     C                   Eval      D4Alc3 = D4Alc3+SLAlc3+SLPck3
     C*
     C*    Update hold quantities.
     C*
     C                   If        SLStat <> 'A'
     C                   Eval      D4Hld1 = D4Hld1+SLStk1+SLRcv1
     C                   Eval      D4Hld2 = D4Hld2+SLStk2+SLRcv2
     C                   Eval      D4Hld3 = D4Hld3+SLStk3+SLRcv3
     C                   EndIf
     C*
     CSR                 EndDo
     C*
411 AC*  Update allocated quantities with Contract quantities.
     C*
     C*    - Add Contract stock in order to reserve the Contract
     C*      quantity. This allocation is normally done during
     C*      receiving.
     C*
     C                   Eval      D4Alc1 = D4Alc1+$QStk1
     C                   Eval      D4Alc2 = D4Alc2+$QStk2
     C                   Eval      D4Alc3 = D4Alc3+$QStk3
     C*
     C*    - Subrtract Contract allocated because picking allocates
     C*      the quantity from the Contract item's warehouse quantity
     C*      but Base item's slot quantities.
     C*
     C                   Eval      D4Alc1 = D4Alc1-$QAlc1
     C                   Eval      D4Alc2 = D4Alc2-$QAlc2
     C                   Eval      D4Alc3 = D4Alc3-$QAlc3

     C*  Flag difference.

     C                   If        D4Stk1 <> IQStk1
     C                             or D4Stk2 <> IQStk2
     C                             or D4Stk3 <> IQStk3
     C                             or D4Hld1 <> IQHld1
     C                             or D4Hld2 <> IQHld2
     C                             or D4Hld3 <> IQHld3
     C                             or D4TrI1 <> IQTrI1
     C                             or D4TrI2 <> IQTrI2
     C                             or D4TrI3 <> IQTrI3
     C                             or D4TrO1 <> IQTrO1
     C                             or D4TrO2 <> IQTrO2
     C                             or D4TrO3 <> IQTrO3
     C                             or D4Alc1 <> IQAlc1
     C                             or D4Alc2 <> IQAlc2
     C                             or D4Alc3 <> IQAlc3
     C                             or D4Ord1 <> IQOrd1
     C                   Eval      DqSFlg = 1
     C                   Else
     C                   Eval      DqSFlg = 0
     C                   EndIf

     C     EndClcSlt     ENDSR

     C*----------------------------------------------------------------
     C*
     C*  Iq2D1      Move ITEMQTY field into DLYQTY "start" fields.
     C*
     C     Iq2D1         BEGSR

     C                   eval      D1STK1 = IQSTK1
     C                   eval      D1STK2 = IQSTK2
     C                   eval      D1STK3 = IQSTK3

     C                   eval      D1ALC1 = IQALC1
     C                   eval      D1ALC2 = IQALC2
     C                   eval      D1ALC3 = IQALC3

     C                   eval      D1HLD1 = IQHLD1
     C                   eval      D1HLD2 = IQHLD2
     C                   eval      D1HLD3 = IQHLD3

     C                   eval      D1TRI1 = IQTRI1
     C                   eval      D1TRI2 = IQTRI2
     C                   eval      D1TRI3 = IQTRI3

     C                   eval      D1TRO1 = IQTRO1
     C                   eval      D1TRO2 = IQTRO2
     C                   eval      D1TRO3 = IQTRO3

     C                   eval      D1ORD1 = IQORD1

     C                   ENDSR

     C*----------------------------------------------------------------
     C*
     C*  Iq2D2      Move ITEMQTY field into DLYQTY "end" fields.
     C*
     C     Iq2D2         BEGSR

     C                   eval      D2STK1 = IQSTK1
     C                   eval      D2STK2 = IQSTK2
     C                   eval      D2STK3 = IQSTK3

     C                   eval      D2ALC1 = IQALC1
     C                   eval      D2ALC2 = IQALC2
     C                   eval      D2ALC3 = IQALC3

     C                   eval      D2HLD1 = IQHLD1
     C                   eval      D2HLD2 = IQHLD2
     C                   eval      D2HLD3 = IQHLD3

     C                   eval      D2TRI1 = IQTRI1
     C                   eval      D2TRI2 = IQTRI2
     C                   eval      D2TRI3 = IQTRI3

     C                   eval      D2TRO1 = IQTRO1
     C                   eval      D2TRO2 = IQTRO2
     C                   eval      D2TRO3 = IQTRO3

     C                   eval      D2ORD1 = IQORD1

     C                   ENDSR

     C*----------------------------------------------------------------
     C*
     C*  ReadLbls   Read labels for item.
     C*
     C     ReadLbls      BEGSR

     C*  Whip through label records for item and calculate totals.

     C     KeyLb         SetLL     Label91
     C                   DoW       Forever = Forever
     C     KeyLbP        Reade     Label91                                77

     C                   If        *In77 = *On
     C                   Leave
     C                   Endif

     C*    Leave if we go past ItemQty date.

     C                   If        LbSDte > ItemQtyDate
     C                   Leave
     C                   Endif

     C*    Leave if we go past ItemQty time.

     C                   If        LbSDte = ItemQtyDate
     C                             and LbSTim > ItemQtyTime
     C                   Leave
     C                   Endif

416aDC**   If item is linked SSB, then change the label's UOM accordingly.

416aDC**                 If        ItemType = '*Link'
416aDC**                           and ITType = 'S'
416aDC**                           and LBType <> 'O'
416aDC**                           and LBType <> 'B'
416aDC**                 Select
416aDC**                 When      LBUTyp = 'N'
416aDC**                 eval      LBUTyp = '1'
416aDC**                 When      LBUTyp = '1'
416aDC**                 eval      LBUTyp = '2'
416aDC**                 EndSl
416aDC**                 EndIf

     C*    If item is linked Breakdown, then only use replenishment records.

     C                   If        ItemType = '*Link'
     C                             and ITType = 'B'
     C                             and LBType <> 'R'
     C                   Iter
     C                   EndIf

     C*    See if corrsponding record exists in Open file.

     C                   eval      DlyQtyOFound = *Off
     C     KeyDO         SetGT     DlyQtyO
     C                   DoW       Forever = Forever
     C     KeyDO         Readpe    DlyQtyO                                76

     C                   If        *In76 = *On
     C                   Leave
     C                   Endif

     C                   If        DOUFlg = 0
     C                   eval      DlyQtyOFound = *On
     C                   eval      DOUFlg = 1
     C                   Update    DORec
     C                   Leave
     C                   Endif

     C                   EndDo

     C*    Initialize flag for writing DlyQtyO record.

     C                   eval      WriteORec = *Off

     C                   Select

     C*    Warehouse quantity recaclulated using UT812

     C                   When      LBType = 'Q'
     C                   Eval      DQAFlg = 1
     C                   Eval      DQQFlg = 1

     C*    Adjustment - Out - Closed (All adjustments assumed to be closed)

     C                   When      LBType = 'A'
     C                             and LBQPck < 0

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecA = DTRecA + 1
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQAOC1 = DQAOC1 - LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQAOC2 = DQAOC2 - LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQAOC3 = DQAOC3 - LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Adjustment - In - Closed (All adjustments assumed to be closed)

     C                   When      LBType = 'A'
     C                             and LBQPck >= 0

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecA = DTRecA + 1
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQAIC1 = DQAIC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQAIC2 = DQAIC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQAIC3 = DQAIC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Received - Direct - Open

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'P'
     C                             and LBDsp2 <> '*MANUAL'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecR = DTRecR + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQRDO1 = DQRDO1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQRDO2 = DQRDO2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQRDO3 = DQRDO3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Received - Direct - Closed

     C*      Note: If record previously recorded when it was opened
     C*               then don't record it now.

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'P'
     C                             and LBDsp2 <> '*MANUAL'
     C                             and LBStat = 'C'

     C                   If        DlyQtyOFound = *Off
     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecR = DTRecR + 1
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQRDC1 = DQRDC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQRDC2 = DQRDC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQRDC3 = DQRDC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl
     C                   EndIf

     C*    Received - Manual - Open

     C*       Note: Qty not added to stock because it hasn't been closed.

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'P'
     C                             and LBDsp2 = '*MANUAL'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecR = DTRecR + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQRMO1 = DQRMO1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQRMO2 = DQRMO2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQRMO3 = DQRMO3 + LBQPck
     C                   Endsl

     C*    Received - Manual - Closed

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'P'
     C                             and LBDsp2 = '*MANUAL'
     C                             and LBStat = 'C'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecR = DTRecR + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQRMC1 = DQRMC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQRMC2 = DQRMC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQRMC3 = DQRMC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Returned - Direct - Open

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'R'
     C                             and LBDsp2 <> '*MANUAL'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecN = DTRecN + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQNDO1 = DQNDO1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQNDO2 = DQNDO2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQNDO3 = DQNDO3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Returned - Direct - Closed

     C*      Note: If record previously recorded when it was opened
     C*               then don't record it now.

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'R'
     C                             and LBDsp2 <> '*MANUAL'
     C                             and LBStat = 'C'

     C                   If        DlyQtyOFound = *Off
     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecN = DTRecN + 1
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQNDC1 = DQNDC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQNDC2 = DQNDC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk3 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQNDC3 = DQNDC3 + LBQPck
     C                   Eval      D3Stk2 = D3Stk3 + LBQPck
     C                   Endsl
     C                   EndIf

     C*    Returned - Manual - Open

     C*       Note: Qty not added to stock because it hasn't been closed.

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'R'
     C                             and LBDsp2 = '*MANUAL'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecN = DTRecN + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQNMO1 = DQNMO1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQNMO2 = DQNMO2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQNMO3 = DQNMO3 + LBQPck
     C                   Endsl

     C*    Returned - Manual - Closed

     C                   When      LBType = 'P'
     C                             and LBGrp1 = 'R'
     C                             and LBDsp2 = '*MANUAL'
     C                             and LBStat = 'C'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecN = DTRecN + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQNMC1 = DQNMC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQNMC2 = DQNMC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Add       LBQPck        DQNMC3
     C                   Eval      DQNMC3 = DQNMC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Picked - Open - Non-OUT

     C                   When      LBType = 'O'
     C                             and LBStat <> 'C'
     C                             and LBAsl2 <> 'OUT'
     C                             or LBType = 'B'
     C                             and LBStat <> 'C'
     C                             and LBAsl2 <> 'OUT'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecP = DTRecP + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQPKO1 = DQPKO1 + LBQPck
     C                   Eval      D3Alc1 = D3Alc1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQPKO2 = DQPKO2 + LBQPck
     C                   Eval      D3Alc2 = D3Alc2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQPKO3 = DQPKO3 + LBQPck
     C                   Eval      D3Alc3 = D3Alc3 + LBQPck
     C                   Endsl

     C*    Picked - Open - OUT (Doesn't effect allocated)

     C                   When      LBType = 'O'
     C                             and LBStat <> 'C'
     C                             and LBAsl2 =  'OUT'
     C                             or LBType = 'B'
     C                             and LBStat <> 'C'
     C                             and LBAsl2 =  'OUT'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecP = DTRecP + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQPOO1 = DQPOO1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQPOO2 = DQPOO2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQPOO3 = DQPOO3 + LBQPck
     C                   Endsl

     C*    Picked - Closed - Non-OUT

     C*      Note: If record previously recorded when it was opened
     C*               then reduce previous allocation now.

     C                   When      LBType = 'O'
     C                             and LBStat = 'C'
     C                             and LBAsl2 <> 'OUT'
     C                             or LBType = 'B'
     C                             and LBStat = 'C'
     C                             and LBAsl2 <> 'OUT'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecP = DTRecP + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQPKC1 = DQPKC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 - LBQPck
     C                   If        DlyQtyOFound = *On
     C                   Eval      D3Alc1 = D3Alc1 - DOQAlc
     C                   EndIf
     C                   When      LBUTyp = '1'
     C                   Eval      DQPKC2 = DQPKC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 - LBQPck
     C                   If        DlyQtyOFound = *On
     C                   Eval      D3Alc2 = D3Alc2 - DOQAlc
     C                   EndIf
     C                   When      LBUTyp = '2'
     C                   Eval      DQPKC3 = DQPKC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 - LBQPck
     C                   If        DlyQtyOFound = *On
     C                   Eval      D3Alc3 = D3Alc3 - DOQAlc
     C                   EndIf
     C                   Endsl

     C*    Picked - Closed - OUT (doesn't effect allocated)

     C                   When      LBType = 'O'
     C                             and LBStat = 'C'
     C                             and LBAsl2 =  'OUT'
     C                             or LBType = 'B'
     C                             and LBStat = 'C'
     C                             and LBAsl2 =  'OUT'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecP = DTRecP + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQPOC1 = DQPOC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 - LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQPOC2 = DQPOC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 - LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQPOC3 = DQPOC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 - LBQPck
     C                   Endsl

     C*    Picked - Merge - Open (Ignore)

     C                   When      LBType = 'M'
     C                             and LBStat <> 'C'
     C                   Eval      DTRecP = DTRecP + 1

     C*    Picked - Merge - Closed (Ignore)

     C                   When      LBType = 'M'
     C                             and LBStat = 'C'
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecP = DTRecP + 1
     C                   EndIf

     C*    Transfered - Out - Open

     C*       Note: Qty not added to stock because it hasn't been closed.

     C                   When      LBType = 'T'
     C                             and LBGrp2 = 'A'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecT = DTRecT + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQTOO1 = DQTOO1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQTOO2 = DQTOO2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQTOO3 = DQTOO3 + LBQPck
     C                   Endsl

     C*    Transfered - Out - Closed

     C                   When      LBType = 'T'
     C                             and LBGrp2 = 'A'
     C                             and LBStat = 'C'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecT = DTRecT + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQTOC1 = DQTOC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 - LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQTOC2 = DQTOC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 - LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQTOC3 = DQTOC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 - LBQPck
     C                   Endsl

     C*    Transfered - In - Open

     C*       Note: Qty not added to stock because it hasn't been closed.

     C                   When      LBType = 'T'
     C                             and LBGrp2 = 'B'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecT = DTRecT + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQTIO1 = DQTIO1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQTIO2 = DQTIO2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQTIO3 = DQTIO3 + LBQPck
     C                   Endsl

     C*    Transfered - In - Closed

     C                   When      LBType = 'T'
     C                             and LBGrp2 = 'B'
     C                             and LBStat = 'C'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecT = DTRecT + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQTIC1 = DQTIC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQTIC2 = DQTIC2 + LBQPck
416 DC**                 Eval      D3Stk1 = D3Stk1 + LBQPck
416 MC                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQTIC3 = DQTIC3 + LBQPck
416 DC**                 Eval      D3Stk1 = D3Stk1 + LBQPck
416 MC                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   Endsl

     C*    Repl/Letdn - In/Out - Open

     C*       Note: Brkdn *Base items increase stk qty using LBQRMN qty.
     C*             Brkdn *Link items increase alc qty using LBQPCK qty.
     C*             Everything else is a wash so Qty's aren't affected.

     C                   When      LBType = 'R'
     C                             and LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRecL = DTRecL + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Select
     C                   When      ITType = 'B' and ItemType = '*Link'
     C                   Eval      DQLOO1 = DQLOO1 + LBQPck
     C                   Eval      D3Alc1 = D3Alc1 + LBQPck
     C                   When      ITType = 'B' and ItemType = '*Base'
     C                   Eval      DQLIO1 = DQLIO1 + LBQRmn
     C                   Eval      D3Stk1 = D3Stk1 + LBQRmn
     C                   Other
     C                   Eval      DQLOO1 = DQLOO1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 - LBQPck
     C                   Eval      DQLIO1 = DQLIO1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C                   EndSl
     C                   When      LBUTyp = '1'
     C                   Select
     C                   When      ITType = 'B' and ItemType = '*Link'
     C                   Eval      DQLOO2 = DQLOO2 + LBQPck
     C                   Eval      D3Alc2 = D3Alc2 + LBQPck
     C                   When      ITType = 'B' and ItemType = '*Base'
     C                   Eval      DQLIO2 = DQLIO2 + LBQRmn
     C                   Eval      D3Stk2 = D3Stk2 + LBQRmn
     C                   Other
     C                   Eval      DQLOO2 = DQLOO2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 - LBQPck
     C                   Eval      DQLIO2 = DQLIO2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C                   EndSl
     C                   When      LBUTyp = '2'
     C                   Select
     C                   When      ITType = 'B' and ItemType = '*Link'
     C                   Eval      DQLOO3 = DQLOO3 + LBQPck
     C                   Eval      D3Alc3 = D3Alc3 + LBQPck
     C                   When      ITType = 'B' and ItemType = '*Base'
     C                   Eval      DQLIO3 = DQLIO3 + LBQRmn
     C                   Eval      D3Stk3 = D3Stk3 + LBQRmn
     C                   Other
     C                   Eval      DQLOO3 = DQLOO3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 - LBQPck
     C                   Eval      DQLIO3 = DQLIO3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C                   EndSl
     C                   Endsl

     C*    Repl/Letdn - In/Out - Closed

     C*       Note: Brkdn *Base items increase stk qty using LBQRMN qty.
     C*             Brkdn *Link items reduce stk qty using LBQPCK qty.
     C*             Everything else is a wash so Qty's aren't affected.

     C*      Note: If record previously recorded when it was opened
     C*               then reduce previous allocation now.

     C                   When      LBType = 'R'
     C                             and LBStat = 'C'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRecL = DTRecL + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Select
     C                   When      ITType = 'B' and ItemType = '*Link'
     C                   Eval      DQLOC1 = DQLOC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 - LBQPck
     C                   If        DlyQtyOFound = *On
     C                   Eval      D3Alc1 = D3Alc1 - DOQAlc
     C                   EndIf
     C                   When      ITType = 'B' and ItemType = '*Base'
     C                   Eval      DQLIC1 = DQLIC1 + LBQRmn
     C                   Eval      D3Stk1 = D3Stk1 + LBQRmn
     C                   Other
     C                   Eval      DQLOC1 = DQLOC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 - LBQPck
     C                   Eval      DQLIC1 = DQLIC1 + LBQPck
     C                   Eval      D3Stk1 = D3Stk1 + LBQPck
     C**                 If        DlyQtyOFound = *On
     C**                 Eval      D3Alc1 = D3Alc1 - DOQAlc
     C**                 EndIf
     C                   EndSl
     C                   When      LBUTyp = '1'
     C                   Select
     C                   When      ITType = 'B' and ItemType = '*Link'
     C                   Eval      DQLOC2 = DQLOC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 - LBQPck
     C                   If        DlyQtyOFound = *On
     C                   Eval      D3Alc2 = D3Alc2 - DOQAlc
     C                   EndIf
     C                   When      ITType = 'B' and ItemType = '*Base'
     C                   Eval      DQLIC2 = DQLIC2 + LBQRmn
     C                   Eval      D3Stk2 = D3Stk2 + LBQRmn
     C                   Other
     C                   Eval      DQLOC2 = DQLOC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 - LBQPck
     C                   Eval      DQLIC2 = DQLIC2 + LBQPck
     C                   Eval      D3Stk2 = D3Stk2 + LBQPck
     C***                If        DlyQtyOFound = *On
     C***                Eval      D3Alc2 = D3Alc2 - DOQAlc
     C***                EndIf
     C                   EndSl
     C                   When      LBUTyp = '2'
     C                   Select
     C                   When      ITType = 'B' and ItemType = '*Link'
     C                   Eval      DQLOC3 = DQLOC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 - LBQPck
     C                   If        DlyQtyOFound = *On
     C                   Eval      D3Alc3 = D3Alc3 - DOQAlc
     C                   EndIf
     C                   When      ITType = 'B' and ItemType = '*Base'
     C                   Eval      DQLIC3 = DQLIC3 + LBQRmn
     C                   Eval      D3Stk3 = D3Stk3 + LBQRmn
     C                   Other
     C                   Eval      DQLOC3 = DQLOC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 - LBQPck
     C                   Eval      DQLIC3 = DQLIC3 + LBQPck
     C                   Eval      D3Stk3 = D3Stk3 + LBQPck
     C***                If        DlyQtyOFound = *On
     C***                Eval      D3Alc3 = D3Alc3 - DOQAlc
     C***                EndIf
     C                   EndSl
     C                   Endsl

     C*    Inventory - Closed (Inventory is always assumed closed)

     C*       Note: Resets ItemQty Quantities.

     C                   When      LBType = 'I'

     C                   Eval      DQAFlg = 1
     C                   Eval      DQIFlg = 1
     C                   Eval      DTRecI = DTRecI + 1
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQIVC1 = DQIVC1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQIVC2 = DQIVC2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQIVC3 = DQIVC3 + LBQPck
     C                   Endsl

     C*    Other - Open

     C*       Note: Don't know how these would effect ItemQty quantities.

     C                   When      LBStat <> 'C'

     C                   Eval      DQAFlg = 1
     C                   Eval      DTRec@ = DTRec@ + 1
     C                   eval      WriteORec = *On
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQOTO1 = DQOTO1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQOTO2 = DQOTO2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQOTO3 = DQOTO3 + LBQPck
     C                   Endsl

     C*    Other - Closed

     C*       Note: Don't know how these would effect ItemQty quantities.

     C                   When      LBStat = 'C'

     C                   Eval      DQAFlg = 1
     C                   If        DlyQtyOFound = *Off
     C                   Eval      DTRec@ = DTRec@ + 1
     C                   EndIf
     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      DQOTC1 = DQOTC1 + LBQPck
     C                   When      LBUTyp = '1'
     C                   Eval      DQOTC2 = DQOTC2 + LBQPck
     C                   When      LBUTyp = '2'
     C                   Eval      DQOTC3 = DQOTC3 + LBQPck
     C                   Endsl

     C                   EndSl

     C*    See if we should write DlyQtyO record.

     C                   If        WriteORec = *On
     C                   Eval      DORDte = DQRDte
     C                   Eval      DORTim = DQRTim
     C                   Eval      DOLbl# = LBLbl#
     C                   Eval      DOQAlc = LBQAlc
     C                   Eval      DOQRmn = LBQRmn
     C                   Eval      DOQPck = LBQPck
     C                   Eval      DOUFlg = 0
     C                   Write     DORec
     C                   EndIf

     C                   EndDo

     C                   ENDSR

     C*----------------------------------------------------------------
     C*
     C*  WrapUp     Last record wrap up.
     C*
     C*   Note: When dealing with dates and times, it is assumed that
     C*         this program started and ended within the same day.
     C*
     C     WrapUp        BEGSR

     C*  Update existing DLYQTYT record if one was found.

     C                   If        DlyQtyTFound = *On
     C                   Eval      DtSDte = RunDate
     C                   Eval      DtSTim = RunTime
     C                   Time                    DtETim
     C                   If        DtETim >= DtSTim
     C                   Eval      DtEDte = DtSDte
     C                   Else
     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      DtEDte = $cvd8o
     C                   EndIf
     C                   Eval      DtTtlR = DtRecA
     C                                    + DtRecR
     C                                    + DtRecN
     C                                    + DtRecP
     C                                    + DtRecT
     C                                    + DtRecL
     C                                    + DtRecI
     C                                    + DtRec@
     C                   Update    DTRec
     C                   EndIf

     C*  Create new DLYQTYT record for run date/time.

     C                   Clear                   DtRec
     C                   Eval      DtRDte = RunDate
     C                   Eval      DtRTim = RunTime
     C                   Write     DTRec

     C                   ENDSR
