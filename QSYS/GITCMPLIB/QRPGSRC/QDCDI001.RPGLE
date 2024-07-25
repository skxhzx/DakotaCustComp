     F*----------------------------------------------------------------
     F*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDCDI001   Q&D Undo closed route to update pick slot/whse qty.
     F*  17 January 2011
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
640 AF*    01/17/11  MLB  6.40
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: CDI
     F*
CDI AF*    01/17/11  MLB  CDI
     F*      - Revised pgm to skip all processing except undolabel.
     F*        needed pgm to only update slots / whse qty for route that
     F*        was closed with picked qty's instead of closing picks to
     F*        zero qty. Route was reset back to Picked status but with
     F*        LABEL rcds at the Picked status instead of Closed.
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*   This program attempts to reverse a route that has already been
     F*   allocated or picked. This program makes no assumption to whether
     F*   the route has been allocate, picked or a mixture of both.
     F*   The program will go through the WorkLbl and Label files looking
     F*   for records to reverse. After that, all order records will be
     F*   reversed.
     F*
     F*   This program does not delete a route, it only sets it back to
     F*   an open status. After that, the route can be deleted through the
     F*   Open routes display, if needed. This was done in order to prevent
     F*   routes from accidentally being deleted.
     F*
     F*   To prevent unpredictable results when the route is allocated and
     F*   picked a second time, this program will assign a new route id to
     F*   the route. The original route header record will be given a status
     F*   of '8', a new route header record will be created and all order
     F*   records will be updated with the new route id.
     F*
     F*   The picked quantity in the Label and WorkLbl files will be set
     F*   to zero to reflect that the record was closed to zero. The
     F*   original picked quantity will be saved in the RteUndo file. Also,
     F*   the LBVRFY file will be set to 'U' to flag that the record was
     F*   'Undone" by this program.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FRteHed    UF A E           K DISK
     FRteSum    UF A E           K DISK
416aAFRteCSum   UF A E           K DISK
     FLabel13   UF A E           K DISK
     FWorkLbl5  UF   E           K DISK
     FSlot2     UF   E           K DISK
     FOrdH3     UF   E           K DISK
417 aFOrdC      UF   E           K DISK
     FOrdD      UF   E           K DISK
417 aFOrdT      UF   E           K DISK
     FPirTran   UF   E           K DISK
     FBatCtl    UF   E           K DISK
500c FBulkDrp   UF   E           K DISK
     FOptions   IF   E           K DISK
     FPirItem   IF   E           K DISK
510  FRunner6   UF   E           K DISK    rename(rurec : rurec6)
     FItemAdj   O    E             DISK
     FRteUndo   O    E             DISK

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

510 AD currstamp       s               z
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

     C*----------------------------------------------------------------
     C*  Parameters
     C*----------------------------------------------------------------
     C*
     C*    Input Parameters
     C*      $PCMD   *UNDO    -  Undo route to open status.
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

CDI AC                   goto      #undolabel

     C     KeyRte        Chain     RteHed                             7978

     C*    Record not found.

     C                   If        *In79 = *On
     C                   Movea     Msg(1)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105
500bAC                   MOVEL(P)  '*PGMQ'       $PRTN
     C                   Goto      Bottom
     C                   Endif

     C*    Record is locked.

     C                   If        *In78 = *On
     C                   Movea     Msg(2)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105
500bAC                   MOVEL(P)  '*PGMQ'       $PRTN
     C                   Goto      Bottom
     C                   Endif

     C*    Route is not at Allocate, Built or Printed (Picked) status.

     C                   If        RHStat <> '2' and
     C                             RHStat <> '3' and
     C                             RHStat <> '4'
     C                   Movea     Msg(3)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105
500bAC                   MOVEL(P)  '*PGMQ'       $PRTN
     C                   UnLock    RteHed
     C                   Goto      Bottom
     C                   Endif

     C*  Get new route id.

     C                   Call      'PIRRTE#'
     C                   Parm      $PWhse        $RWHSE            3 0
     C                   Parm                    NewRtid

     C*  Undo WorkLbl records.

     C                   Exsr      UndoWorkLbl

     C*  Undo Label records.

CDI AC     #undolabel    tag
     C                   Exsr      UndoLabel
CDI AC                   goto      bottom

     C*  Undo Order records.

     C                   Exsr      UndoOrders

     C*  Update batch record.

     C     RHPBat        Chain     BTRec                              79
     C                   If        *In79 = *Off
     C                   Eval      BTStat = '9'
     C                   Eval      BTEndD = RunDate
     C                   Eval      BTEndT = RunTime
     C                   Update    BTRec
     C                   EndIf

     C*  Update original route record.

     C                   Eval      RHStat = '8'
     C                   Eval      RHStsD = RunDate
     C                   Eval      RHStsT = RunTime
     C                   Update    RHRec

     C*  Get original RteSum record.

416 AC     KeyRte        Setll     RteSum
416 AC     FOREVR        Doweq     Forevr
416 DC*    KeyRte        Chain     RteSum                             79
416 MC     KeyRte        ReadE     RteSum                                 79

416 AC                   If        *In79 = *On
416 AC                   Leave
416 AC                   Endif

     C*    Create out new RteSum record.

     C                   If        *In79 = *Off
     C                   Eval      RSRtid = NewRtid
     C                   Write     RSRec
     C                   Endif
416 AC                   Enddo
416aA
416aAC*  Get original RteCSum records.
416aA
416aAC     KeyRte        Setll     RteCSum
416aAC     FOREVR        Doweq     Forevr
416aAC     KeyRte        ReadE     RteCSum                                79
416aA
416aAC*    Create new RteCSum record.
416aA
416aAC                   Select
416aAC     *IN79         WhenEq    *On
416aAC                   Leave
416aAC*
416aAC                   Other
416aAC                   Eval      RCRtid = NewRtid
416aAC                   Eval      RCPckc = 0
416aAC                   Eval      RCPckw = 0
416aAC                   Eval      RCPckp = 0
416aAC                   Write     RCRec
416aAC                   Endsl
416aAC                   Enddo

     C*  Create new route record.

     C                   Eval      RHRtid = NewRtid
     C                   Eval      RHStat = '1'
     C                   Eval      RHStsD = RunDate
     C                   Eval      RHStsT = RunTime
     C                   Eval      RHBldD = 0
     C                   Eval      RHBldT = 0
     C                   Eval      RHPrtD = 0
     C                   Eval      RHPrtT = 0
     C                   Eval      RHPBat = 0
417a C                   Eval      RHShpd = 0
417a C                   Eval      RHShpt = 0
     C                   Write     RHRec


     C                   Movea     Msg(5)        A50
     C                   Movea     $PRte         A50(7)
     C                   Movea     A50           ErrMsg
     C                   Exsr      ZM0105

     C     Bottom        Tag

     C                   Eval      *INLR = *On

     C*----------------------------------------------------------------
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------

     C     *INZSR        BEGSR

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

     C*  Define key for SLOT2 file from WORKLBL fields.

     C     KeySl2W       KList
     C                   KFld                    LWWhse
     C                   KFld                    LWWhdp
     C                   KFld                    LWDisp

     C*  Define key for PIRITEM file.

     C     KeyIt         KList
     C                   KFld                    KyWhse
     C                   KFld                    KyItem

     C*  Define key for PirTran file.

     C     KeyPt         KList
     C                   KFld                    KyTrn#

     C*  Define key for OrdD file.

     C     KeyOd         KList
     C                   KFld                    OHWhse
     C                   KFld                    OHOrd

510 AC*  Define key for RUNNER6 file.

510 AC     Keyru         KList
510 AC                   KFld                    LBWhse
510 AC                   KFld                    LBLbl#

     C*  Get current date.

     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $Cvd8o
510 AC                   time                    currstamp

     C*  Capture Run date/time

     C                   Eval      RunDate = Today
     C                   Time                    RunTime
     C                   Eval      LastTime = RUTime
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
     C*  LogIt   Log record that was changed.
     C*----------------------------------------------------------------

     C     LogIt         BegSr

     C                   Eval      RUWhse = $PWhse
     C                   Eval      RURtid = $PRtid
     C                   Eval      RUNewR = NewRtid
     C                   Time                    RUTime
     C                   If        RUTime < LastTime
     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $cvd8o
     C                   EndIf
     C                   Eval      RUDate = Today
     C                   Eval      LastTime = RUTime

     C                   Select

     C                   When      RUFile = 'L'
     C                   Eval      RUNum = LBLbl#
     C                   Eval      RUQPck = LBQPck
     C                   Eval      RUStat = LBStat
     C                   Eval      RUSDte = LBSDte
     C                   Eval      RUSTim = LBSTim

     C                   When      RUFile = 'T'
     C                   Eval      RUNum = PTTrn#
     C                   Eval      RUQPck = 0
     C                   Eval      RUStat = PTStat
     C                   Eval      RUSDte = PTCDte
     C                   Eval      RUSTim = PTCTim

     C                   When      RUFile = 'W'
     C                   Eval      RUNum = LWLbl#
     C                   Eval      RUQPck = LWQPck
     C                   Eval      RUStat = LWStat
     C                   Eval      RUSDte = LWSDte
     C                   Eval      RUSTim = LWSTim

     C                   EndSl

     C                   Write     RURec

     C                   Endsr

500x C*----------------------------------------------------------------
500c C*  RmvBulk  Remove Bulk Drop records for Bulk pick labels.
500c C*----------------------------------------------------------------

500c C     RmvBulk       BegSr
500c C     Lblbl#        Chain     BDRec                              79
500c C                   If        *In79 = *Off
500c C                   Delete    BDRec
500c C                   EndIf

500c C                   Endsr

510  C*----------------------------------------------------------------
510  C*  RmvRunner  Remove Runner Flag entries.
510  C*----------------------------------------------------------------

510  C     RmvRunner     BegSr
510  C     keyru         setll     Runner6
510  C                   dow       Forever = Forever
510  C     keyru         reade     Runner6
510  C                   select
510  C                   when      %eof(runner6)
510  C                   leave

510  C                   Other
510  C                   Eval      rustat = 'D'
510  C                   Eval      rucdts = currstamp
510  C                   Update    RuRec6
510  C                   Endsl

510  C                   Enddo

510  C                   Endsr
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

     C                   When      LWUTyp = '1'
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
500aMC                   Eval      SLPck2 = SLPck2 - LBQPck
500aDC*                  Eval      SLPck2 = SLPck2 - LWQPck
     C                   If        SLPck2 < 0
     C                   Eval      SLPck2 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = LBQPck
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 2 uom.

500aMC                   When      LBUTyp = '2'
500aDC*                  When      LWUTyp = '1'
500aMC                   Eval      SLPck3 = SLPck3 - LBQPck
500aDC*                  Eval      SLPck3 = SLPck3 - LWQPck
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

     C*  Update records.

     C     UpdLbl        Tag

     C                   Eval      RUFile = 'L'
     C                   Exsr      LogIt

     C                   Eval      SVStat = LBStat
     C                   Eval      SVQPck = LBQPck
     C                   Eval      LBStat = 'C'
     C                   Eval      LBSDte = RunDate
     C                   Eval      LBSTim = RunTime
     C                   Eval      LBQPck = 0
     C                   Eval      LBVrfy = 'U'
     C                   Update    LBRec

500c C*  Remove Bulk Drop Records.
500c C                   If        LBType = 'B'
500c C                   Exsr      RmvBulk
500c C                   Endif

510  C*  Remove Runner Flag records.
510  C                   Exsr      RmvRunner

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
     C*  UndoOrders   Undo order records.
     C*----------------------------------------------------------------

     C     UndoOrders    Begsr

     C*  Loop through order header records for route.

     C     KeyRte        SetLL     OrdH3
     C                   DoW       Forever = Forever
     C     KeyRte        Reade     OrdH3                                  77

     C                   If        *In77 = *On
     C                   Leave
     C                   Endif

     C*    Loop through order detail records for order.

     C     KeyOd         SetLL     OrdD
     C                   DoW       Forever = Forever
     C     KeyOd         Reade     OrdD                                   76

     C                   If        *In76 = *On
     C                   Leave
     C                   Endif

     C*      Update detail record.

     C                   Eval      ODStat = 'O'
     C                   Eval      ODQPk1 = 0
     C                   Eval      ODQPk2 = 0
     C                   Eval      ODQPk3 = 0

     C                   Update    ODRec

     C                   EndDo
417 A
417 AC*    Loop through order catchwgt records for order.
417 A
417 AC     KeyOd         SetLL     OrdC
417 AC                   DoW       Forever = Forever
417 AC     KeyOd         Reade     OrdC                                   76
417 A
417 AC                   If        *In76 = *On
417 AC                   Leave
417 AC                   Endif
417 A
417 AC*      Delete all catchweight entries.
417 A
417 AC                   Delete    OCRec
417 A
417 AC                   EndDo
417 A
417 AC*    Loop through order transaction records for order.
417 A
417 AC     KeyOd         SetLL     OrdT
417 AC                   DoW       Forever = Forever
417 AC     KeyOd         Reade     OrdT                                   76
417 A
417 AC                   If        *In76 = *On
417 AC                   Leave
417 AC                   Endif
417 A
417 AC*      Delete all order transaction entries.
417 A
417 AC                   Delete    OTRec
417 A
417 AC                   EndDo

     C*    Update header record.

     C                   Eval      OHStat = 'O'
     C                   Eval      OHSDte = RunDate
     C                   Eval      OHSTim = RunTime
     C                   Eval      OHPBat = 0
     C                   Eval      OHRte  = NewRtid
     C                   Update    OHRec

     C                   EndDo

     C                   EndSr

     C*----------------------------------------------------------------
     C*  UndoWorkLbl  Un-Allocate/Pick WORKLBL records.
     C*----------------------------------------------------------------

     C     UndoWorkLbl   Begsr

     C*  Loop through WorkLbl records for route.

     C     KeyRte        SetLL     WorkLbl5
     C                   DoW       Forever = Forever
     C     KeyRte        Reade     WorkLbl5                               77

     C                   If        *In77 = *On
     C                   Leave
     C                   Endif

     C*     Ignore labels that have already been processed.

     C                   If        LWStat = 'X'
     C                   Iter
     C                   EndIf

     C*     Only work with normal, bulk pick and merge records.

     C                   If        LWType <> 'O' and
     C                             LWType <> 'B' and
     C                             LWType <> 'M'
     C                   Iter
     C                   EndIf

     C*     Only update slot for Merge and Out labels.

     C                   If        LWType = 'M' or
     C                             LWAsl2 = 'OUT'
     C                   Goto      UpdLblW
     C                   EndIf

     C*    Get Item Info.

     C                   Eval      KyWhse = LWWhse
     C                   Eval      KyItem = LWItem
     C                   Exsr      GetItem

     C*     Get slot record.

     C     KeySl2W       Chain     Slot2                              77
     C                   If        *In77 = *On
     C                   Goto      UpdLblW
     C                   EndIf

     C*  Update slot record.

     C                   Select

     C*    Record alredy 'Picked'

     C                   When      LWStat = 'P'

     C*      Normal uom.

     C                   Select
     C                   When      LWUTyp = 'N'
     C                   Eval      SLPck1 = SLPck1 - LWQPck
     C                   If        SLPck1 < 0
     C                   Eval      SLPck1 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = LWQPck
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 1 uom.

     C                   When      LWUTyp = '1'
     C                   Eval      SLPck2 = SLPck2 - LWQPck
     C                   If        SLPck2 < 0
     C                   Eval      SLPck2 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = LWQPck
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 2 uom.

     C                   When      LWUTyp = '2'
     C                   Eval      SLPck3 = SLPck3 - LWQPck
     C                   If        SLPck3 < 0
     C                   Eval      SLPck3 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = LWQPck
     C                   Exsr      UpdWhseQty

     C                   EndSl

     C*    Record not 'Picked', only allocated.

     C                   Other

     C*      Normal uom.

     C                   Select
     C                   When      LWUTyp = 'N'
     C                   Eval      SLAlc1 = SLAlc1 - LWQAlc
     C                   If        SLAlc1 < 0
     C                   Eval      SLAlc1 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = LWQAlc
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 1 uom.

     C                   When      LWUTyp = '1'
     C                   Eval      SLAlc2 = SLAlc2 - LWQAlc
     C                   If        SLAlc2 < 0
     C                   Eval      SLAlc2 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = LWQAlc
     C                   Eval      $AQty3 = 0
     C                   Exsr      UpdWhseQty

     C*      Breakdown 2 uom.

     C                   When      LWUTyp = '1'
     C                   Eval      SLAlc3 = SLAlc3 - LWQAlc
     C                   If        SLAlc3 < 0
     C                   Eval      SLAlc3 = 0
     C                   Endif
     C                   Eval      $ACmd = '*UNALLOC'
     C                   Eval      $AQty1 = 0
     C                   Eval      $AQty2 = 0
     C                   Eval      $AQty3 = LWQAlc
     C                   Exsr      UpdWhseQty

     C                   EndSl

     C                   EndSl

     C                   Update    SLRec

     C*  Update records.

     C     UpdLblW       Tag

     C                   Eval      RUFile = 'W'
     C                   Exsr      LogIt

     C                   Eval      LWStat = 'X'
     C                   Eval      LWSDte = RunDate
     C                   Eval      LWSTim = RunTime
     C                   Eval      LWQPck = 0
     C                   Eval      LWVrfy = 'U'
     C                   Update    LWRec

     C                   Eval      KyTrn# = LWTrn#
     C                   Exsr      UpdTranRec

     C                   EndDo

     C                   Endsr

     C*----------------------------------------------------------------
     C*  UpdTranRec  Update transaction record.
     C*----------------------------------------------------------------

     C     UpdTranRec    BEGSR

     C                   If        KyTrn# = 0 or KyTrn# = LastTrn#
     C                   Goto      EndUpdTrn
     C                   EndIf

     C     KeyPt         Chain     PirTran                            77

     C                   If        *In77 = *Off

     C                   Eval      RUFile = 'T'
     C                   Exsr      LogIt

     C                   If        PTStat <> '4'
     C                   Eval      PTStat = '4'
     C                   Eval      PTCDte = RunDate
     C                   Eval      PTCTim = RunTime
     C                   EndIf
     C                   Update    PTRec

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
500bDC*                  MOVEL(P)  '*PGMQ'       $PRTN
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
