     F*----------------------------------------------------------------
     F*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  RH154     Undo closed route
     F*  31 August, 2004
     F*  Roxanne Harrison
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
416 AF*    08/31/04  RH   4.17
     F*      - Created using RH134
416aAF*      Program will reverse quantity picked to SLOT and ITEMQTY
     F*      Will force route as exported, create label and adjustment rec.
     F*
640 AF*    06/29/12  MLB  6.40
     F*      - Enh: Revised program to call LT001 with FIX for slot just
     F*      updated to get license(s) updated with qty's to match qty
     F*      returned to pick slot.
640aAF*    06/29/12  MLB  6.40a
     F*      - Enh: Revised to add client custom code support to program.
640bAF*    06/07/12  LMC  6.40b
     F*      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
     F*
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCP A*    06/29/12  MLB  CCP
     *      - Revise program to mark adjustment records as exported.
     *        Route was not exported, so qty's on Host are correct.
     *
     F*----------------------------------------------------------------
     F*  Notes
     F*
416aAF*   Program will reverse quantity picked to SLOT and ITEMQTY
     F*   Will force route as exported, create label and adjustment rec.
     F*   This program attempts to reverse a route that has already been
     F*   closed.
     F*   The program will go through the Label files looking
     F*   for records to reverse. The orders will not be reversed.
     F*
     F*   This program does not delete a route, it only sets it exported
     F*   status.  No new route id is needed.
     F*
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FRteHed    UF   E           K DISK
     FLabel13   UF A E           K DISK
     FSlot2     UF   E           K DISK
     FPirTran   UF   E           K DISK
     FOptions   IF   E           K DISK
     FPirItem   IF   E           K DISK
     FItemAdj   O    E             DISK

640aA*----------------------------------------------------------------
640aA*  Customer id
640aA*
CCP A /COPY QCOPYSRC,ID#capitol
640aA*
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*----------------------------------------------------------------

     D A30             S              1    DIM(30)
     D A50             S              1    DIM(50)
     D MSG             S             50    DIM(5) CTDATA PERRCD(1)

     D*----------------------------------------------------------------
     D*  Program parameters
     D*----------------------------------------------------------------

     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $PWHSE                19     21  0
     D  $PRTE                 22     26
     D  $PRTID                27     31

      *------------------------------------------------------------------
      * Constants ...
      *------------------------------------------------------------------
     D   Forever       C                   Const('1')

      *------------------------------------------------------------------
      * Misc defs ...
      *------------------------------------------------------------------

     D FlagOp          s              1    Inz(*Off)
     D KyWhse          s                   Like(LBWhse)
     D KyItem          s                   Like(LBItem)
     D KyTrn#          s                   Like(PTTrn#)
415aAD LastTrn#        s              7  0
415aAD LastTime        s              6  0
     D NewRtid         s                   Like(RHRtid)
     D RunDate         s              8  0
     D RunTime         s              6  0
     D SVQPck          s                   Like(LBQPck)
     D SVStat          s                   Like(LBStat)
     D TempA7          s              7
     D Today           s              8  0
640bAD wrtpcmd         s             10
640bAD wrtpwait        s              2  0
640bAD wrtpwhse        s              3  0
640bAD wrtptran#       s                   like(pttrn#)
640bAD wrtpfrmdate     s              8  0
640bAD wrtptodate      s              8  0
640bAd wrtpemp#        s                   like(ptemp#)

      *----------------------------------------------------------------
      *  Called programs
      *----------------------------------------------------------------
     D @CVTDT          C                   CONST('CVTDTE')
     D @CLCDR          C                   CONST('CLCDUR')
417c D @getsi          c                   const('GETSLOTITM')

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
     D*  *CLOSE   -  Transaction close options.
     D*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPEXCD  -  Exception labels picked - code.
     D*    OPNSCD  -  Not enough stock to close transaction - code.
     D*    OPDICD  -  Different item found in slot - code.
     D*
     D* Data structure
     D*
     D OPDATA          DS
     D  OPEXCD                 1      2
     D  OPNSCD                 3      4
     D  OPDICD                 5      6
     D  CLSEND               117    117

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *----------------------------------------------------------------

     D $MDT            DS
     D  ERRMSG                 1     50

     D*----------------------------------------------------------------
     D*  Message control
     D*----------------------------------------------------------------

     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)

     D*----------------------------------------------------------------
     D*  Program info data structure
     D*----------------------------------------------------------------

     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0

640bA*----------------------------------------------------------------
640bA*  Prototypes
640bA*----------------------------------------------------------------
640bA
640bAD wrttran1        pr                  extpgm('WRTTRAN1')
640bA * Input
640bAD   ppcmd                        8
640bAD   ppwait                       2  0
640bAD   ppwhse                       3  0
640bAD   pptran#                      7  0
640bAD   ppfromdate                   8  0
640bAD   pptodate                     8  0
640bAD   ppemp#                       5  0
     C*----------------------------------------------------------------
     C*  Parameters
     C*----------------------------------------------------------------
     C*
     C*    Input Parameters
     C*      $PCMD   *UNDO    -  Undo route to reverse.
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key for everything by *ADD.
     C*
     C*    Returned Parameters
     C*      $MSGK   Message id sent to previous message queue.
     C*      $PRTN   *OK      - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....

     C     *Entry        PList
     C                   PARM                    $Parms

     C                   Eval      $PRtn = '*OK'

     C*----------------------------------------------------------------
     C*  Main line

     C*  Grab RteHed record.

     C     KeyRte        Chain     RteHed                             7978

     C*    Record not found.

     C                   If        *In79 = *On
     C                   Movea     Msg(1)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105
     C                   Goto      Bottom
     C                   Endif

     C*    Record is locked.

     C                   If        *In78 = *On
     C                   Movea     Msg(2)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105
     C                   Goto      Bottom
     C                   Endif

     C*    Route is not at Closed status.

     C                   If        RHStat <> '5'
     C                   Movea     Msg(3)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105
     C**                 UnLock    RteHed
     C                   Goto      Bottom
     C                   Endif


     C*  Undo Label records.

     C                   Exsr      UndoLabel

     C*  Update original route record.

     C                   Eval      RHStat = '6'
     C                   Eval      RHStsD = RunDate
     C                   Eval      RHStsT = RunTime
     C                   Eval      RHExpD = RunDate
     C                   Eval      RHExpT = RunTime
     C                   Update    RHRec


     C     Bottom        Tag

     C                   Eval      *INLR = *On

     C*----------------------------------------------------------------
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------

     C     *INZSR        BEGSR
640aA*
640aA* Get client id.
640aA*
640aAC                   call      'GETCLIENT'
640aAC                   parm                    client           10
640aAC                   parm                    clientloc        10

     C*  Define key for Options file.

     C     KeyOp         KList
     C                   KFld                    $PWhse
     C                   KFld                    OPCode

     C*  Define partial key for LABEL13/WORKLBL5 files.

     C     KeyRte        KList
     C                   KFld                    $PWhse
     C                   KFld                    $PRtId

     C*  Define key for SLOT2 file from LABEL fields.

     C     KeySl2        KList
     C                   KFld                    LBWhse
     C                   KFld                    LBWhdp
     C                   KFld                    LBDisp


     C*  Define key for PIRITEM file.

     C     KeyIt         KList
     C                   KFld                    KyWhse
     C                   KFld                    KyItem

     C*  Define key for PirTran file.

     C     KeyPt         KList
     C                   KFld                    KyTrn#


     C*  Get current date.

     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $Cvd8o

     C*  Capture Run date/time

     C                   Eval      RunDate = Today
     C                   Time                    RunTime
     C**                 Eval      LastTime = RUTime
416aAC                   Move      *On           Forevr            1

     C                   ENDSR

     C*----------------------------------------------------------------
     C*  GetCloseOpt  Get *CLOSE options.
     C*----------------------------------------------------------------

     C     GetCloseOpt   BegSr

     C                   If        FlagOp = *Off
     C                   Eval      FlagOp = *On

     C                   Eval      OPCode = '*CLOSE'
     C     KeyOp         Chain     Options                            78
     C                   If        *In78 = *On
     C                   Eval      OPExcd = 'X1'
     C                   EndIf

     C                   EndIf

     C                   Endsr

     C*----------------------------------------------------------------
     C*  GetItem  Get item record.
     C*----------------------------------------------------------------

     C     GetItem       BegSr

     C                   MOVE      KYITEM        #LITEM           15
     C                   MOVE      KYITEM        #BITEM

     C     KeyIt         Chain     PirItem                            78
     C     *IN78         IFEQ      *ON
     C                   MOVE      *BLANK        ITTYPE
     C                   Z-ADD     0             ITUMQ2
     C                   Z-ADD     0             ITUMQ3
     C                   ENDIF

     C                   MOVE      ITTYPE        #BITYP
     C                   MOVE      ITDESC        #BDESC
     C                   MOVE      ITPDSC        #BPDSC
     C*
     C*     If Contract, Alias or SSB item
     C*       Then get Base item.
     C*
     C     ITTYPE        IFEQ      'C'
     C     ITTYPE        OREQ      'A'
     C     ITTYPE        OREQ      'S'
     C                   CALL      'GETBASE'
     C                   PARM      ITWHSE        $GWHSE            3 0
     C                   PARM      ITITEM        $GITEM           15
     C                   PARM      ' '           #BITEM           15
     C                   PARM                    #BITYP            1
     C                   PARM                    #BDESC           30
     C                   PARM                    #BPDSC           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BSTYP            1
     C                   PARM                    #BUM              2
     C                   PARM                    #BUM2             2
     C                   PARM                    #BUMQ2            3 0
     C                   PARM                    #BUM3             2
     C                   PARM                    #BUMQ3            3 0
     C                   PARM      ' '           #BCITM           15
     C                   PARM                    #BCTYP            1
     C                   PARM                    #BCDSC           30
     C                   PARM                    #BCPDS           15
     C                   PARM                    #BCWDP            5
     C                   PARM                    #BCSTP            1
     C                   PARM                    #BCUM             2
     C                   PARM                    #BCUM2            2
     C                   PARM                    #BCUQ2            3 0
     C                   PARM                    #BCUM3            2
     C                   PARM                    #BCUQ3            3 0
     C                   PARM                    #BRTN             8
     C                   ENDIF
417c C*     get slot item.
417cACSR                 call      @getsi
417cACSR                 parm      itwhse        $gwhse            3 0
417cACSR                 parm      ititem        $gitem           15
417cACSR                 parm      ' '           #sitem           15
417cACSR                 parm                    #sityp            1
417cACSR                 parm                    #sdesc           30
417cACSR                 parm                    #spdsc           15
417cACSR                 parm                    #srtn            10
417cACSR                 parm                    #smsg            60

     C                   ENDSR


     C*----------------------------------------------------------------
     C*  UndoLabel  Un-Allocate/Pick LABEL records.
     C*----------------------------------------------------------------

     C     UndoLabel     Begsr

     C*  Loop through WorkLbl records for route.

     C     KeyRte        SetLL     Label13
     C                   DoW       Forever = Forever
     C     KeyRte        Reade     Label13                                77

     C                   If        *In77 = *On
     C                   Leave
     C                   Endif

     C*     Only work with normal, bulk pick and merge records.

     C                   If        LBType <> 'O' and
     C                             LBType <> 'B' and
     C                             LBType <> 'M'
     C                   Iter
     C                   EndIf

     C*     Only update slot for Merge labels and unclosed OUT labels.

     C                   If        LBType = 'M' or LBAsl2 = 'OUT'
     C                   Goto      UpdLbl
     C                   EndIf

     C*    Get Item Info.

     C                   Eval      KyWhse = LBWhse
     C                   Eval      KyItem = LBItem
     C                   Exsr      GetItem

     C*     Get slot record.

     C     KeySl2        Chain     Slot2                              77
     C                   If        *In77 = *On
     C                   Goto      UpdLbl
     C                   EndIf
     C*  Skip if slot item is not the label item# to be updated
     C                   If        SLItem <> LBItem
     C                   Goto      UpdLbl
     C                   EndIf

     C*  Update slot record.

     C                   Select

     C*    Record alredy 'Closed'

     C                   When      LBStat = 'C'

     C*      Normal uom.

     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      SLStk1 = SLStk1 + LBQPck
     C                   Eval      $ACmd = '*STOCK'
     C                   Eval      $AQty1 = LBQPck
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 1 uom.

     C                   When      LBUTyp = '1'
     C                   Eval      SLStk2 = SLStk2 + LBQPck
     C                   Eval      $ACmd = '*STOCK'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = LBQPck
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 2 uom.

     C                   When      LBUTyp = '2'
     C                   Eval      SLStk3 = SLStk3 + LBQPck
     C                   Eval      $ACmd = '*STOCK'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = LBQPck
     C                   Exsr      UpdWhseQty

     C                   EndSl

     C*    Record not 'Closed', only picked.

     C                   Other

     C*      Normal uom.

     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      SLPck1 = SLPck1 - LBQPck
     C                   If        SLPck1 < 0
     C                   Eval      SLPck1 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = LBQPck
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 1 uom.

     C                   When      LBUTyp = '1'
     C                   Eval      SLPck2 = SLPck2 - LBQPck
     C                   If        SLPck2 < 0
     C                   Eval      SLPck2 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = LBQPck
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 2 uom.

     C                   When      LBUTyp = '1'
     C                   Eval      SLPck3 = SLPck3 - LBQPck
     C                   If        SLPck3 < 0
     C                   Eval      SLPck3 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = LBQPck
     C                   Exsr      UpdWhseQty

     C                   EndSl

     C                   EndSl

     C                   Update    SLRec

640 AC*  Update license records.
640 AC                   call(e)   'LT001'
640 AC                   parm      'FIX'         lpAction          3
640 AC                   parm      slwhse        lpWhse            3 0
640 AC                   parm      slwhdp        lpWhdp            5
640 AC                   parm      sldisp        lpDisp           12
640 AC                   parm      ' '           lpDummy           1

     C*  Update records.

     C     UpdLbl        Tag


     C                   Eval      SVStat = LBStat
     C                   Eval      SVQPck = LBQPck
     C                   Eval      LBStat = 'C'
     C                   Eval      LBSDte = RunDate
     C                   Eval      LBSTim = RunTime
     C                   Eval      LBQPck = 0
     C                   Eval      LBVrfy = 'U'
     C**                 Update    LBRec

     C                   Eval      KyTrn# = LBTrn#
     C                   Exsr      UpdTranRec

     C*  If label record was not for a closed OUT label.
     C*    Then loop and get next label record.

     C                   If        LBAsl2 <> 'OUT' or
     C                             SVStat <> 'C' or
     C                             SVQPck = 0
     C                   Iter
     C                   EndIf

     C*  Otherwise, create reverse adjustment.

     C                   Eval      IAWhse = $PWhse
     C                   If        ITType = 'A'
417cDC**                 Eval      IAItem = #BItem
417cMC                   Eval      IAItem = #SItem
     C                   Else
     C                   Eval      IAItem = LBItem
     C                   EndIf
     C                   Eval      IADate = RunDate
     C                   Eval      IATime = RunTime
     C                   Eval      IABy   = #User
     C                   Eval      IAWhdp = LBWhdp
     C                   Eval      IADisp = LBDisp
     C                   Eval      IACwta = 0
     C                   Eval      IAQty1 = 0
     C                   Eval      IAQty2 = 0
     C                   Eval      IAQty3 = 0
     C                   Eval      IAUDte = 0
     C                   Eval      IAUTim = 0

     C*    For SSB item, qty must be converted from Base qty type
     C*      into SSB qty type (ie. Brkdwn1 into Normal).

     C                   If        ITType = 'S'

     C                   Select
     C                   When      LBUTyp = '1'
     C                   Eval      IAQty1 = SVQPck * -1
     C                   When      LBUTyp = '2'
     C                   Eval      IAQty2 = SVQPck * -1
     C                   EndSl

     C                   Else

     C                   Select
     C                   When      LBUTyp = 'N'
     C                   Eval      IAQty1 = SVQPck * -1
     C                   When      LBUTyp = '1'
     C                   Eval      IAQty2 = SVQPck * -1
     C                   When      LBUTyp = '2'
     C                   Eval      IAQty3 = SVQPck * -1
     C                   EndSl

     C                   EndIf

     C                   MoveA     Msg(4)        A30
     C                   MoveA     LBRte         A30(16)
     C                   Move      LBLbl#        TempA7
     C                   MoveA     TempA7        A30(24)
     C                   MoveA     A30           IAMemo

     C                   Exsr      GetCloseOpt
     C                   Eval      IACode = OpExCd
CSP A
CSP AC                   if        client = CapitolCity
CSP AC*      Don't allow adjustment to be exported.
CSP AC                   eval      iaudte = RunDate
CSP AC                   eval      iautim = RunTime
CSP AC                   endif
CSP A
     C                   Write     IARec

     C*      Create label adjustment record.

     C                   Eval      LBCtr# = LBLbl#
     C                   Call      'PIRLBL#'
     C                   Parm                    LBLbl#
     C                   Eval      LBGrp1 = ' '
     C                   Eval      LBGrp2 = ' '
     C                   Eval      LBType = 'A'
     C                   Eval      LBStat = 'C'
     C                   Eval      LBSDTE = RunDate
     C                   Eval      LBSTIM = RunTime
     C                   Eval      LBRDTE = RunDate
     C                   Eval      LBQPck = SVQPck * -1
     C                   Write     LBRec

     C                   EndDo

     C                   EndSr

     C*----------------------------------------------------------------
     C*  UpdTranRec  Update transaction record.
     C*----------------------------------------------------------------

     C     UpdTranRec    BEGSR

     C                   If        KyTrn# = 0 or KyTrn# = LastTrn#
     C                   Goto      EndUpdTrn
     C                   EndIf

     C     KeyPt         Chain     PirTran                            77

     C                   If        *In77 = *Off


     C                   If        PTStat <> '4'
     C                   Eval      PTStat = '4'
     C                   Eval      PTCDte = RunDate
     C                   Eval      PTCTim = RunTime
     C                   EndIf
     C                   Update    PTRec
640bAc                   exsr      zzwrttrand

     C                   EndIf

     C                   Eval      LastTrn# = KyTrn#

     C     EndUpdTrn     Endsr

     C*----------------------------------------------------------------
     C*  UpdWhseQty  Update warehouse quantity.
     C*----------------------------------------------------------------

     C     UpdWhseQty    BEGSR

     C*    When item is an Alias or SSB ...
     C*      Update Base item instead of label item.

     C                   If        ITType = 'A' or ITType = 'S'
417cDC**                 Eval      $AItem = #BItem
417cMC                   Eval      $AItem = #SItem
     C                   Else
     C                   Eval      $AItem = #LItem
     C                   EndIf

     C*    Call program to update warehouse quantity.

     C                   CALL      'ADJQTY'
     C                   PARM                    $ACMD             8
     C                   PARM      #Prog         $APRG            10
     C                   PARM      '*BATCH  '    $ATYPE            8
     C                   PARM      KyWhse        $AWHSE            3 0
     C                   PARM                    $AITEM           15
     C                   PARM                    $AQTY1            7 0
     C                   PARM                    $AQTY2            7 0
     C                   PARM                    $AQTY3            7 0
     C                   PARM                    $ARTQ1            7 0
     C                   PARM                    $ARTQ2            7 0
     C                   PARM                    $ARTQ3            7 0
     C                   PARM                    $ARTN             8
     C                   PARM                    $AERM            60

     C*    If item is a Contract item and restocking slot
     C*      Then we must restock and allocate base item.

     C                   If        ITType = 'C' and $ACmd = '*STOCK'

     C                   CALL      'ADJQTY'
     C                   PARM      '*STOCK  '    $ACMD             8
     C                   PARM      #Prog         $APRG            10
     C                   PARM      '*BATCH  '    $ATYPE            8
     C                   PARM      KyWhse        $AWHSE            3 0
417cDC**                 PARM      #BItem        $AITEM           15
417cMC                   PARM      #SItem        $AITEM           15
     C                   PARM                    $AQTY1            7 0
     C                   PARM                    $AQTY2            7 0
     C                   PARM                    $AQTY3            7 0
     C                   PARM                    $ARTQ1            7 0
     C                   PARM                    $ARTQ2            7 0
     C                   PARM                    $ARTQ3            7 0
     C                   PARM                    $ARTN             8
     C                   PARM                    $AERM

     C                   CALL      'ADJQTY'
     C                   PARM      '*ALLOC  '    $ACMD             8
     C                   PARM      #Prog         $APRG            10
     C                   PARM      '*BATCH  '    $ATYPE            8
     C                   PARM      KyWhse        $AWHSE            3 0
417cDC**                 PARM      #BItem        $AITEM           15
417cMC                   PARM      #SItem        $AITEM           15
     C                   PARM                    $AQTY1            7 0
     C                   PARM                    $AQTY2            7 0
     C                   PARM                    $AQTY3            7 0
     C                   PARM                    $ARTQ1            7 0
     C                   PARM                    $ARTQ2            7 0
     C                   PARM                    $ARTQ3            7 0
     C                   PARM                    $ARTN             8
     C                   PARM                    $AERM

     C                   EndIf

     C                   ENDSR
640bA*----------------------------------------------------------------*********
640bA*
640bA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640bA*
640bA /free
640bA   begsr zzwrttrand;
640bA     wrtpcmd = '*UNDOTRAN';
640bA     wrtpwait = 0;
640bA     wrtpwhse = ptwhse;
640bA     wrtptran# = pttrn#;
640bA     wrtpfrmdate = 0;
640bA     wrtptodate = 0;
640bA     wrtpemp# = 0;
640bA
640bA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640bA               wrtpfrmdate: wrtptodate: wrtpemp#);
640bA   endsr;
640bA /end-free

     C*----------------------------------------------------------------
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*    ZMSMSG  Send program message to a different program msgq
     C*----------------------------------------------------------------

     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSGP'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID            7
     CSR                 PARM                    #MSGTP            7
     CSR                 PARM                    #MSGDT
     CSR                 PARM      #PROG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR

     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*      0105
     C*----------------------------------------------------------------

     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $PMSG
     CSR                 MOVEL(P)  '*PGMQ'       $PRTN
     CSR                 ENDSR

     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
     O*----------------------------------------------------------------

**  MSG - Error Messages
Route xxxxx does not exist
Route xxxxx locked by another program
Route xxxxx is not at Built, Allocated or Picked Status
Out Lbl Undo R:99999 L:9999999
Route xxxxx reversed successfully
