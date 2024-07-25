    *****************************************************************
    * Set output for next screen
    *****************************************************************
     C     $SetNxtScr    begsr
    *    ==========    =====
      *
     C                   Select
     C                   When      nxtscr = '01 '
     C                   eval      w6stop    = 0
     C                   eval      w18stop   = 0
     C                   eval      OCurrScr  = 'OR400.01'
     C                   eval      ONxtPgm   = 'JSC01PR'
     C                   eval      OParm1    = %Char(W1WHSE)
     C                   eval      OParm2    = %Char(W1TRN#)
     C                   eval      OParm3    = W1EOD
      *
     C                   When      nxtscr = '02 '
     C                   eval      OCurrScr  = 'OR400.02'
     C                   eval      ONxtPgm   = 'JSC02PR'
     C                   eval      OParm1    = W2LBL#B
      *
     C                   When      nxtscr = '03 '
     C                   eval      OCurrScr  = 'OR400.03'
     C                   eval      ONxtPgm   = 'JSC03PR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = W3DISP
     C                   eval      OParm3    = W3SCAN
      *
     C*                  When      nxtscr = '03V '
     C*                  eval      OCurrScr  = 'OR400.03'
     C*                  eval      ONxtPgm   = 'JSC03VPR'
     C*                  eval      OParm1    = WOITEM
     C*                  eval      OParm2    = W3DISP
     C*                  eval      OParm3    = SLVFY
     C*                  eval      OParm4    = SLVFYVAL
      *
     C                   When      nxtscr = '04 '
     C                   eval      OCurrScr  = 'OR400.04'
     C                   eval      ONxtPgm   = 'JSC04PR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = W4UPCD
      *
     C                   When      nxtscr = '05 '
     C                   eval      OCurrScr  = 'OR400.05'
     C                   eval      ONxtPgm   = 'JSC05PR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = W5LCNS
      *
     C                   When      nxtscr = '06 '
     C                   eval      OCurrScr  = 'OR400.06'
     C                   eval      ONxtPgm   = 'JSC06PR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop > 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6CNT2 > 0
     C                   eval      OParm4    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm5    = W6UOM
     C                   eval      OParm6    = W6LBL#B
      *
     C                   When      nxtscr = '06A'
     C                   eval      OCurrScr  = 'OR400.06A'
     C                   eval      ONxtPgm   = 'JSC06APR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop > 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6ACNT2 > 0
     C                   eval      OParm4    = %Char(W6ACNT1) + ' of '
     C                                         + %Char(W6ACNT2)
     C                   Endif
     C                   eval      OParm5    = W6ALBL#B
      *
     C                   When      nxtscr = '06B'
     C                   eval      OCurrScr  = 'OR400.06B'
     C                   eval      ONxtPgm   = 'JSC06BPR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop > 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6CNT2 > 0
     C                   eval      OParm4    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm5    = W6UOM
     C                   eval      OParm6    = W6UPCD
      *
     C                   When      nxtscr = '06C'
     C                   If        w6stop    > 0
     C                   eval      OCurrScr  = 'OR400.06E'
     C                   Else
     C                   eval      OCurrScr  = 'OR400.06C'
     C                   Endif
     C                   eval      ONxtPgm   = 'JSC06CPR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop    > 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6CNT2 > 0
     C                   eval      OParm4    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm5    = W6UOM
     C                   eval      OParm6    = %Char(W6CNT1E)
      *
     C                   When      nxtscr = '06D'
     C                   eval      OCurrScr  = 'OR400.06D'
     C                   eval      ONxtPgm   = 'JSC06DPR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop    > 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6CNT2 > 0
     C                   eval      OParm4    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm5    = W6UOM
     C***                eval      OParm6    = W6UCI
      *
     C                   When      nxtscr = '06E'
     C                   eval      OCurrScr  = 'OR400.06EN'
     C                   eval      ONxtPgm   = 'JSC06EPR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop    > 0   or
     C                             w6stop    = 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6WGT2    > 0  or
     C                             W6WGT2    = 0
     C                   eval      OParm4    = %Char(W6WGT1) + ' of '
     C                                         + %Char(W6WGT2) + 'Lbs'
     C                   Endif
     C**                 eval      OParm5    = W6UOM
     C                   eval      OParm5    = W6UCI
      *
     C                   When      nxtscr = '06F'
     C                   eval      OCurrScr  = 'OR400.06F'
     C                   eval      ONxtPgm   = 'JSC06FPR'
     C                   eval      OParm1    = WOITEM
     C                   eval      OParm2    = SDISP
     C                   If        w6stop    > 0  or
     C                             w6stop    = 0
     C                   eval      OParm3    = 'Stop: ' +%Char(W6STOP)
     C                   Endif
     C                   If        W6WGT2 > 0   or
     C                             W6WGT2    = 0
     C                   eval      OParm4    = %Char(W6WGT1) + ' of '
     C                                         + %Char(W6WGT2) + 'Lbs'
     C                   Endif
     C**                 eval      OParm5    = W6UOM
     C                   eval      OParm5    = W6UCI
      *
     C                   When      nxtscr = '07 '
      *
     C                   Select
     C                   When      client = saval
     C                             and type = 'CHK'
     C                   eval      OCurrScr  = 'OR400.07B'
     C                   eval      ONxtPgm   = 'JSC07PR'
     C                   If        W6CNT2 > 0
     C                   eval      OParm1    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm2    = W7UM1
     C**                 eval      OParm3    = W7BLBL
      *
     C                   If        *In31 = *On
     C                   eval      OParm4    = 'S21-S14-S10'
     C                   Else
     C                   eval      OParm4    = 'S20-S14-S10'
     C                   Endif
      *
     C                   When      client = saval
     C                             and type = 'SKI'
     C                   eval      OCurrScr  = 'OR400.07C'
     C                   eval      ONxtPgm   = 'JSC07PR'
     C                   If        W6CNT2 > 0
     C                   eval      OParm1    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm2    = W7UM1
     C**                 eval      OParm3    = W7ILBL
      *
     C                   If        *In31 = *On
     C                   eval      OParm4    = 'S21-S10'
     C                   Else
     C                   eval      OParm4    = 'S20-S10'
     C                   Endif
      *
     C                   Other
      *
     C                   eval      OCurrScr  = 'OR400.07'
     C                   eval      ONxtPgm   = 'JSC07PR'
     C                   If        W6CNT2 > 0
     C                   eval      OParm1    = %Char(W6CNT1) + ' of '
     C                                         + %Char(W6CNT2)
     C                   Endif
     C                   eval      OParm2    = W7UM1
     C                   eval      OParm3    = W7CWGT
      *
     C                   Select
     C                   When      *In31 = *Off And *In64 = *On
     C                   eval      OParm4    = 'S06-S18-S14'
     C                   When      *In31 = *Off And *In64 = *Off
     C                   eval      OParm4    = 'S18-S14'
     C                   When      *In31 = *On  And *In64 = *On
     C                   eval      OParm4    = 'S06-S19-S14'
     C                   When      *In31 = *On  And *In64 = *Off
     C                   eval      OParm4    = 'S19-S14'
     C                   EndSl
      *
     C                   If        *In62 = *On
     C                   eval      OParm5    = 'S15-S10'
     C                   Else
     C                   eval      OParm5    = 'S10'
     C                   Endif
      *
     C                   EndSl
      *
     C                   When      nxtscr = '08 '
     C                   eval      OCurrScr  = 'OR400.08'
     C                   eval      ONxtPgm   = 'JSC08PR'
     C                   eval      OParm1    = %Char(W8TRN#)
     C                   eval      OParm2    = %Char(W8ENTER)
      *
     C                   When      nxtscr = '09 '
     C                   eval      OCurrScr  = 'OR400.09'
     C                   eval      ONxtPgm   = 'JSC09PR'
      *
     C                   When      nxtscr = '09A'
     C                   eval      OCurrScr  = 'OR400.09A'
     C                   eval      ONxtPgm   = 'JSC09APR'
      *
     C                   When      nxtscr = '10 '
     C                   eval      OCurrScr  = 'OR400.10'
     C                   eval      ONxtPgm   = 'JSC10PR'
     C                   eval      OParm1    = #USER
      *
     C                   When      nxtscr = '11 '
     C                   eval      OCurrScr  = 'OR400.11'
     C                   eval      ONxtPgm   = 'JSC11PR'
     C                   eval      OParm1    = AISLE
      *
     C                   When      nxtscr = '12 '
      *
     C                   Select
     C                   When      *In46 = *On
     C                   eval      OCurrScr  = 'OR400.12'
     C                   When      *In47 = *On
     C                   eval      OCurrScr  = 'OR400.12A'
     C                   When      *In48 = *On
     C                   eval      OCurrScr  = 'OR400.12B'
     C                   Endsl
      *
     C                   eval      ONxtPgm   = 'JSC12PR'
     C                   eval      OParm1    = WOITEM
      *
     C                   If        *In60 = *On
     C                   eval      OParm2    = 'Slot ' + SDISP
     C                   Else
     C*                  eval      OParm2    = 'Go To Location '
     C*                                        + %Char(LOCTN)
     C                   eval      OParm2    = 'Location: ' + %Char(LOCTN)
     C                   eval      OParm3    = 'Level    ' + SLEVEL
     C                   Endif
      *
     C                   If        *In46 = *On
     C                   eval      OParm4    = 'Scan Slot: ' + SSLOT
     C                   Endif
      *
     C                   If        *In47 = *On
     C                   eval      OParm5    = 'Scan Check Digit: '
     C                                         + %Char(CDGT)
     C                   Endif
      *
     C                   If        *In63 = *On
     C                   eval      OParm6    = 'S01-S17-S07-S08'
     C                   Else
     C                   eval      OParm6    = 'S01-S07-S08'
     C                   Endif
      *
     C                   If        *In49 = *On
     C                   eval      OParm7    = 'S04-S10-S12'
     C                   Else
     C                   eval      OParm7    = 'S04-S10-S11-S12'
     C                   Endif
      *
     C                   If        *In51 = *On
     C                   eval      OParm8    = 'Lic:' + SLCNS
     C                   Endif
      *
     C                   When      nxtscr = '12V '
      *
     C                   eval      OCurrScr  = 'OR400.12V'
     C                   eval      ONxtPgm   = 'JSC12VPR'
     C                   eval      OParm1    = WOITEM
      *
     C                   If        *In60 = *On
     C                   eval      OParm2    = 'Slot ' + SDISP
     C                   Else
     C                   eval      OParm2    = 'Location: ' + %Char(LOCTN)
     C                   eval      OParm3    = 'Level    ' + SLEVEL
     C                   Endif
      *
     C                   If        *In51 = *On
     C                   eval      OParm4    = 'Lic:' + SLCNS
     C                   Endif
      *
     C                   eval      OParm5    = SLVFY + SLVFYVAL
      *
     C                   If        *In63 = *On
     C                   eval      OParm6    = 'S01-S17-S07-S08'
     C                   Else
     C                   eval      OParm6    = 'S01-S07-S08'
     C                   Endif
      *
     C                   If        *In49 = *On
     C                   eval      OParm7    = 'S04-S10-S12'
     C                   Else
     C                   eval      OParm7    = 'S04-S10-S11-S12'
     C                   Endif
      *
     C                   When      nxtscr = '13 '
     C                   eval      OCurrScr  = 'OR400.13'
     C                   eval      ONxtPgm   = 'JSC13PR'
     C                   eval      OParm1    = SPND
      *
     C                   When      nxtscr = '14 '
     C                   eval      OCurrScr  = 'OR400.14'
     C                   eval      ONxtPgm   = 'JSC14PR'
      *
     C                   When      nxtscr = '15 '
     C                   eval      OCurrScr  = 'OR400.15'
     C                   eval      ONxtPgm   = 'JSC15PR'
     C                   eval      OParm1    = MTRN
      *
     C                   When      nxtscr = '16 '
     C                   eval      OCurrScr  = 'OR400.16'
     C                   eval      ONxtPgm   = 'JSC16PR'
     C                   eval      OParm1    = CSHRT
      *
     C                   When      nxtscr = '17 '
     C                   eval      OCurrScr  = 'OR400.17'
     C                   eval      ONxtPgm   = 'JSC17PR'
     C                   eval      OParm1    = W18OITEM
     C                   If        W17CNT2 > 0
     C                   eval      OParm2    = %Char(W17CNT1) + ' of '
     C                                         + %Char(W17CNT2)
     C                   Endif
     C                   eval      OParm3    = W7UM1
     C                   eval      OParm4    = W7CWGT
      *
     C                   If        *In31 = *On
     C                   eval      OParm5    = 'S06-S19'
     C                   Else
     C                   eval      OParm5    = 'S06-S18'
     C                   Endif
     C                   eval      OParm6    = 'S14'
      *
     C                   When      nxtscr = '18 '
     C                   eval      OCurrScr  = 'OR400.18'
     C                   eval      ONxtPgm   = 'JSC18PR'
     C                   eval      OParm1    = W18OITEM
      *
     C                   If        W18STOP   > 0
     C                   eval      OParm5    = 'Stop: '
     C                                         + %Char(W18STOP)
     C                   Endif
      *
     C                   If        W18CNT2 > 0
     C                   eval      OParm3    = %Char(W18CNT1) + ' of '
     C                                         + %Char(W18CNT2)
     C                   Endif
     C                   eval      OParm4    = W18LBL#B
      *
     C                   If        errmsg <> *Blanks
     C                   eval      OParm2    = errmsg
     C                   Endif
      *
     C                   When      nxtscr = '19 '
     C                   eval      OCurrScr  = 'OR400.19'
     C                   eval      ONxtPgm   = 'JSC19PR'
     C                   eval      OParm1    = W19LBL#B
      *
     C                   When      nxtscr = '20 '
     C                   eval      OCurrScr  = 'OR400.20'
     C                   eval      ONxtPgm   = 'JSC20PR'
     C                   eval      OParm1    = EUPC
      *
     C                   When      nxtscr = '21 '
     C                   eval      OCurrScr  = 'OR400.21'
     C                   eval      ONxtPgm   = 'JSC21PR'
     C                   eval      OParm1    = CDONE
      *
     C                   When      nxtscr = '22 '
     C                   eval      OCurrScr  = 'OR400.22'
     C                   eval      ONxtPgm   = 'JSC22PR'
     C                   eval      OParm1    = %Char(W22TRN)
     C                   eval      OParm2    = LEAVESUS
      *
     C                   Endsl

     C                   Endsr
    *                  =====
    *****************************************************************
    * Receive previous field values due to navigation
    *****************************************************************
     C     $RcvUIDDtl    begsr
    *    ==========    =====
      *
     C                   If        IUid = *Blanks
     C                   LeaveSr
     C                   Endif
      *
     *                  Get existing veriables-values
     C     IUid          Setll     JSCFLDF01
     C                   Dow       Not %Eof(JSCFLDF01)
     C     IUid          Reade     JSCFLDF01
     C                   If        %Eof(JSCFLDF01)
     C                   Leave
     C                   Endif
      *
     C                   Select
     C                   When      SCFLVAR  = '$SLSIGNRFIN'
     C                   MoveL     SCFLVAL       $slsignrfin
     C                   When      SCFLVAR  = '$SLSIGNRFOUT'
     C                   MoveL     SCFLVAL       $slsignrfout
     C                   When      SCFLVAR  = '$SLBEDAYOUT'
     C                   MoveL     SCFLVAL       $slbedayout
     C                   When      SCFLVAR  = '$SLASSIGNOUT'
     C                   MoveL     SCFLVAL       $slassignout
     C                   When      SCFLVAR  = '$SLPICKSOUT'
     C                   MoveL     SCFLVAL       $slpicksout
     C                   When      SCFLVAR  = '$SLVFYLBLOUT'
     C                   MoveL     SCFLVAL       $slvfylblout
     C                   When      SCFLVAR  = 'W2LBL#B'
     C                   MoveL     SCFLVAL       w2lbl#b
     C                   When      SCFLVAR  = 'W3SCAN'
     C                   MoveL     SCFLVAL       w3scan
     C                   When      SCFLVAR  = 'W3DISP'
     C                   MoveL     SCFLVAL       w3disp
     C                   When      SCFLVAR  = 'UFINFL'
     C                   MoveL     SCFLVAL       ufinfl
     C                   When      SCFLVAR  = '$HEADER'
     C                   MoveL     SCFLVAL       $header
     C                   When      SCFLVAR  = 'W2LBL'
     C                   MoveL     SCFLVAL       w2lbl
     C                   When      SCFLVAR  = 'FIRST6'
     C                   MoveL     SCFLVAL       first6
     C                   When      SCFLVAR  = 'LBUTYP'
     C                   MoveL     SCFLVAL       lbutyp
     C                   When      SCFLVAR  = 'W6CNT1'
     C                   MoveL     SCFLVAL       w6cnt1
     C                   When      SCFLVAR  = 'WHEREFROM'
     C                   MoveL     SCFLVAL       whereFrom
     C                   When      SCFLVAR  = 'FIRST2'
     C                   MoveL     SCFLVAL       first2
     C                   When      SCFLVAR  = 'AISLE'
     C                   MoveL     SCFLVAL       aisle
     C                   When      SCFLVAR  = 'LBORD'
     C                   MoveL     SCFLVAL       lbord
     C                   When      SCFLVAR  = 'OVRRID'
     C                   MoveL     SCFLVAL       ovrrid
     C                   When      SCFLVAR  = 'W6LBL'
     C                   MoveL     SCFLVAL       w6lbl
     C                   When      SCFLVAR  = 'FIRSTZONEPICK'
     C                   MoveL     SCFLVAL       firstzonepick
     C                   When      SCFLVAR  = 'ZONEPICKUP'
     C                   MoveL     SCFLVAL       zonepickup
     C                   When      SCFLVAR  = '$SLRESETUOUT'
     C                   MoveL     SCFLVAL       $slresetuout
     C                   When      SCFLVAR  = '$SLSKIPCWOUT'
     C                   MoveL     SCFLVAL       $slskipcwout
     C                   When      SCFLVAR  = '$SLVFYUPUOUT'
     C                   MoveL     SCFLVAL       $slvfyupuout
     C                   When      SCFLVAR  = '$SLVFYLICOUT'
     C                   MoveL     SCFLVAL       $slvfylicout
     C                   When      SCFLVAR  = '$SLPCKUCIOUT'
     C                   MoveL     SCFLVAL       $slpckuciout
     C                   When      SCFLVAR  = '$SLSCANCWOUT'
     C                   MoveL     SCFLVAL       $slscancwout
     C                   When      SCFLVAR  = '$SLCLOSEOUT'
     C                   MoveL     SCFLVAL       $slcloseout
     C                   When      SCFLVAR  = '$SLGETCWOUT'
     C                   MoveL     SCFLVAL       $slgetcwout
     C                   When      SCFLVAR  = '$SLCHK4UFOUT'
     C                   MoveL     SCFLVAL       $slchk4ufout
     C                   When      SCFLVAR  = '$SLSUSPNDOUT'
     C                   MoveL     SCFLVAL       $slsuspndout
     C                   When      SCFLVAR  = '$SLVFYSLTOUT'
     C                   MoveL     SCFLVAL       $slvfysltout
     C                   When      SCFLVAR  = '$SLCOMPL2OUT'
     C                   MoveL     SCFLVAL       $slcompl2out
     C                   When      SCFLVAR  = '$SLPICKCHOUT'
     C                   MoveL     SCFLVAL       $slpickchout
     C                   When      SCFLVAR  = '$SLPICKOUT'
     C                   MoveL     SCFLVAL       $slpickout
     C                   When      SCFLVAR  = '$SLRESETTOUT'
     C                   MoveL     SCFLVAL       $slresettout
     C                   When      SCFLVAR  = '$SLWEIGHTOUT'
     C                   MoveL     SCFLVAL       $slweightout
     C                   When      SCFLVAR  = 'FIRST18'
     C                   MoveL     SCFLVAL       first18
     C                   When      SCFLVAR  = 'FIRST19'
     C                   MoveL     SCFLVAL       first19
     C                   When      SCFLVAR  = 'W17CNT1'
     C                   MoveL     SCFLVAL       w17cnt1
     C                   When      SCFLVAR  = 'W18CNT2'
     C                   MoveL     SCFLVAL       w18cnt2
     C                   When      SCFLVAR  = 'W7CWGT'
     C                   MoveL     SCFLVAL       w7cwgt
     C                   When      SCFLVAR  = 'W18LBL'
     C                   MoveL     SCFLVAL       w18lbl
     C                   When      SCFLVAR  = 'WTCHK'
     C                   MoveL     SCFLVAL       wtchk
     C                   When      SCFLVAR  = 'WLUSERCHOICE'
     C                   MoveL     SCFLVAL       WLUserChoice
     C                   When      SCFLVAR  = 'W6ACNT1'
     C                   MoveL     SCFLVAL       w6acnt1
     C                   When      SCFLVAR  = 'FIRST6A'
     C                   MoveL     SCFLVAL       first6a
     C                   When      SCFLVAR  = 'W6STOP'
     C                   MoveL     SCFLVAL       w6stop
     C                   When      SCFLVAR  = 'W18STOP'
     C                   MoveL     SCFLVAL       w18stop
     C                   When      SCFLVAR  = 'KILOLBS'
     C                   MoveL     SCFLVAL       KiloLbs
     C                   When      SCFLVAR  = '$SLVFYLBLIN'
     C                   MoveL     SCFLVAL       $slvfylblin
     C                   When      SCFLVAR  = 'UMFLEXPICKFLAG'
     C                   MoveL     SCFLVAL       umFlexPickFlag
     C**                 When      SCFLVAR  = 'CMDTKN'
     C**                 MoveL     SCFLVAL       cmdtkn
     C                   When      SCFLVAR  = 'X'
     C                   MoveL     SCFLVAL       x
     C                   When      SCFLVAR  = 'I'
     C                   MoveL     SCFLVAL       i
     C                   When      SCFLVAR  = 'UPCYES'
     C                   MoveL     SCFLVAL       upcyes
     C                   When      SCFLVAR  = 'W18OITEM'
     C                   MoveL     SCFLVAL       w18oitem
     C**                 When      SCFLVAR  = '$SLWEIGHTIN'
     C**                 MoveL     SCFLVAL       $slweightin
     C                   When      SCFLVAR  = 'W17TRN#'
     C                   MoveL     SCFLVAL       w17trn#
     C                   When      SCFLVAR  = 'W17LBL#'
     C                   MoveL     SCFLVAL       w17lbl#
     C                   When      SCFLVAR  = '$HDRIPADDR'
     C                   MoveL     SCFLVAL       $hdripaddr
     C                   EndSl
     *
     C                   Enddo
      *
     C                   Endsr
    *                  =====
    *****************************************************************
    * Send Program parameter details to PF with Uid
    *****************************************************************
     C     $SndUIDDtl    begsr
    *    ==========    =====
      *
     C                   If        IUid = *Blanks
     C                   LeaveSr
     C                   Endif
      *
     C                   Clear                   UFndFlg1          1
     C                   Clear                   UFndFlg2          1
     C                   Clear                   UFndFlg3          1
     C                   Clear                   UFndFlg4          1
     C                   Clear                   UFndFlg5          1
     C                   Clear                   UFndFlg6          1
     C                   Clear                   UFndFlg7          1
     C                   Clear                   UFndFlg8          1
     C                   Clear                   UFndFlg9          1
     C                   Clear                   UFndFlg10         1
     C                   Clear                   UFndFlg11         1
     C                   Clear                   UFndFlg12         1
     C                   Clear                   UFndFlg13         1
     C                   Clear                   UFndFlg14         1
     C                   Clear                   UFndFlg15         1
     C                   Clear                   UFndFlg16         1
     C                   Clear                   UFndFlg17         1
     C                   Clear                   UFndFlg18         1
     C                   Clear                   UFndFlg19         1
     C                   Clear                   UFndFlg20         1
     C                   Clear                   UFndFlg21         1
     C                   Clear                   UFndFlg22         1
     C                   Clear                   UFndFlg23         1
     C                   Clear                   UFndFlg24         1
     C                   Clear                   UFndFlg25         1
     C                   Clear                   UFndFlg26         1
     C                   Clear                   UFndFlg27         1
     C                   Clear                   UFndFlg28         1
     C                   Clear                   UFndFlg29         1
     C                   Clear                   UFndFlg30         1
     C                   Clear                   UFndFlg31         1
     C                   Clear                   UFndFlg32         1
     C                   Clear                   UFndFlg33         1
     C                   Clear                   UFndFlg34         1
     C                   Clear                   UFndFlg35         1
     C                   Clear                   UFndFlg36         1
     C                   Clear                   UFndFlg37         1
     C                   Clear                   UFndFlg38         1
     C                   Clear                   UFndFlg39         1
     C                   Clear                   UFndFlg40         1
     C                   Clear                   UFndFlg41         1
     C                   Clear                   UFndFlg42         1
     C                   Clear                   UFndFlg43         1
     C                   Clear                   UFndFlg44         1
     C                   Clear                   UFndFlg45         1
     C                   Clear                   UFndFlg46         1
     C                   Clear                   UFndFlg47         1
     C                   Clear                   UFndFlg48         1
     C                   Clear                   UFndFlg49         1
     C                   Clear                   UFndFlg50         1
     C                   Clear                   UFndFlg51         1
     C                   Clear                   UFndFlg52         1
     C                   Clear                   UFndFlg53         1
     C                   Clear                   UFndFlg54         1
     C                   Clear                   UFndFlg55         1
     C                   Clear                   UFndFlg56         1
     C                   Clear                   UFndFlg57         1
     C                   Clear                   UFndFlg58         1
     C                   Clear                   UFndFlg59         1
     C                   Clear                   UFndFlg60         1
     C                   Clear                   UFndFlg61         1
     C                   Clear                   UFndFlg62         1
     C                   Clear                   UFndFlg63         1
     C                   Clear                   UFndFlg64         1
     *                  Update Existing veriables-values
     C     IUid          Setll     JSCFLDF01
     C                   Dow       Not %Eof(JSCFLDF01)
     C     IUid          Reade     JSCFLDF01
     C                   If        %Eof(JSCFLDF01)
     C                   Leave
     C                   Endif
      *
     C                   Clear                   UFndFlg           1
     C                   Eval      SCFLUSR  = IUserId
     C                   Eval      SCFLPGM  = TmpvarPgm
     C                   Eval      SCFLTIMS = %TimeStamp()
     C                   Select
     C                   When      SCFLVAR  = '$SLSIGNRFIN'
     C                             And $slsignrfin  <> *Blanks
     C                   Eval      SCFLVAL  = $slsignrfin
     C                   Eval      UFndFlg1 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = '$SLSIGNRFOUT'
     C                             And $slsignrfout <> *Blanks
     C                   Eval      SCFLVAL  = $slsignrfout
     C                   Eval      UFndFlg2 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = '$SLBEDAYOUT'
     C                             And $slbedayout  <> *Blanks
     C                   Eval      SCFLVAL  = $slbedayout
     C                   Eval      UFndFlg3 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = '$SLASSIGNOUT'
     C                             And $slassignout <> *Blanks
     C                   Eval      SCFLVAL  = $slassignout
     C                   Eval      UFndFlg4 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = '$SLPICKSOUT'
     C                             And $slpicksout  <> *Blanks
     C                   Eval      SCFLVAL  = $slpicksout
     C                   Eval      UFndFlg5 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = '$SLVFYLBLOUT'
     C                             And $slvfylblout <> *Blanks
     C                   Eval      SCFLVAL  = $slvfylblout
     C                   Eval      UFndFlg6 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = 'W2LBL#B'
     C                             And w2lbl#b  <> *Blanks
     C                   Eval      SCFLVAL  = w2lbl#b
     C                   Eval      UFndFlg7 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = 'W3SCAN'
     C                             And w3scan   <> *Blanks
     C                   Eval      SCFLVAL  = w3scan
     C                   Eval      UFndFlg8 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = 'W3DISP'
     C                             And w3disp   <> *Blanks
     C                   Eval      SCFLVAL  = w3disp
     C                   Eval      UFndFlg9 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = 'UFINFL'
     C                             And ufinfl   <> *Blanks
     C                   Eval      SCFLVAL  = ufinfl
     C                   Eval      UFndFlg10 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$HEADER'
     C                             And $header  <> *Blanks
     C                   Eval      SCFLVAL  = $header
     C                   Eval      UFndFlg11 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W2LBL'
     C                             And w2lbl    <> 0
     C                   Clear                   Tmplbl            7
     C                   Move      w2lbl         Tmplbl
     C                   MoveL     Tmplbl        SCFLVAL
     C                   Eval      UFndFlg12 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'FIRST6'
     C                             And first6   <> *Blanks
     C                   Eval      SCFLVAL  = first6
     C                   Eval      UFndFlg13 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'LBUTYP'
     C                             And lbutyp   <> *Blanks
     C                   Eval      SCFLVAL  = lbutyp
     C                   Eval      UFndFlg14 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W6CNT1'
     C***                          And w6cnt1   <> 0
     C                   Clear                   Tmp6cnt           5
     C                   Move      w6cnt1        Tmp6cnt
     C                   MoveL     Tmp6cnt       SCFLVAL
     C                   Eval      UFndFlg15 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'WHEREFROM'
     C                             And whereFrom <> *Blanks
     C                   Eval      SCFLVAL  = whereFrom
     C                   Eval      UFndFlg16 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'FIRST2'
     C                             And first2   <> *Blanks
     C                   Eval      SCFLVAL  = first2
     C                   Eval      UFndFlg17 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'AISLE'
     C                             And aisle    <> *Blanks
     C                   Eval      SCFLVAL  = aisle
     C                   Eval      UFndFlg18 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'LBORD'
     C                             And lbord    <> 0
     C                   Clear                   Tmplbo            7
     C                   Move      lbord         Tmplbo
     C                   MoveL     Tmplbo        SCFLVAL
     C                   Eval      UFndFlg19 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'OVRRID'
     C                             And ovrrid   <> *Blanks
     C                   Eval      SCFLVAL  = ovrrid
     C                   Eval      UFndFlg20 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W6LBL'
     C                             And w6lbl    <> 0
     C                   Clear                   Tmp6lbl           7
     C                   Move      w6lbl         Tmp6lbl
     C                   MoveL     Tmp6lbl       SCFLVAL
     C                   Eval      UFndFlg21 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'FIRSTZONEPICK'
     C                             And (firstzonepick = *On
     C                                  Or firstzonepick = *Off)
     C                   Eval      SCFLVAL  = firstzonepick
     C                   Eval      UFndFlg22 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'ZONEPICKUP'
     C                             And (zonepickup    = *On
     C                                  Or zonepickup = *Off)
     C                   Eval      SCFLVAL  = zonepickup
     C                   Eval      UFndFlg23 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLRESETUOUT'
     C                             And $slresetuout   <> *Blanks
     C                   Eval      SCFLVAL  = $slresetuout
     C                   Eval      UFndFlg24 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLSKIPCWOUT'
     C                             And $slskipcwout   <> *Blanks
     C                   Eval      SCFLVAL  = $slskipcwout
     C                   Eval      UFndFlg25 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLVFYUPUOUT'
     C                             And $slvfyupuout   <> *Blanks
     C                   Eval      SCFLVAL  = $slvfyupuout
     C                   Eval      UFndFlg26 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLVFYLICOUT'
     C                             And $slvfylicout   <> *Blanks
     C                   Eval      SCFLVAL  = $slvfylicout
     C                   Eval      UFndFlg27 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLPCKUCIOUT'
     C                             And $slpckuciout   <> *Blanks
     C                   Eval      SCFLVAL  = $slpckuciout
     C                   Eval      UFndFlg28 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLSCANCWOUT'
     C                             And $slscancwout   <> *Blanks
     C                   Eval      SCFLVAL  = $slscancwout
     C                   Eval      UFndFlg29 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLCLOSEOUT'
     C                             And $slcloseout    <> *Blanks
     C                   Eval      SCFLVAL  = $slcloseout
     C                   Eval      UFndFlg30 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLGETCWOUT'
     C                             And $slgetcwout    <> *Blanks
     C                   Eval      SCFLVAL  = $slgetcwout
     C                   Eval      UFndFlg31 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLCHK4UFOUT'
     C                             And $slchk4ufout   <> *Blanks
     C                   Eval      SCFLVAL  = $slchk4ufout
     C                   Eval      UFndFlg32 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLSUSPNDOUT'
     C                             And $slsuspndout   <> *Blanks
     C                   Eval      SCFLVAL  = $slsuspndout
     C                   Eval      UFndFlg33 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLVFYSLTOUT'
     C                             And $slvfysltout   <> *Blanks
     C                   Eval      SCFLVAL  = $slvfysltout
     C                   Eval      UFndFlg34 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLCOMPL2OUT'
     C                             And $slcompl2out   <> *Blanks
     C                   Eval      SCFLVAL  = $slcompl2out
     C                   Eval      UFndFlg35 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLPICKCHOUT'
     C                             And $slpickchout   <> *Blanks
     C                   Eval      SCFLVAL  = $slpickchout
     C                   Eval      UFndFlg36 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLPICKOUT'
     C                             And $slpickout     <> *Blanks
     C                   Eval      SCFLVAL  = $slpickout
     C                   Eval      UFndFlg37 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLRESETTOUT'
     C                             And $slresettout   <> *Blanks
     C                   Eval      SCFLVAL  = $slresettout
     C                   Eval      UFndFlg38 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLWEIGHTOUT'
     C                             And $slweightout   <> *Blanks
     C                   Eval      SCFLVAL  = $slweightout
     C                   Eval      UFndFlg39 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'FIRST18'
     C                             And first18  <> *Blanks
     C                   Eval      SCFLVAL  = first18
     C                   Eval      UFndFlg40 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'FIRST19'
     C                             And first19  <> *Blanks
     C                   Eval      SCFLVAL  = first19
     C                   Eval      UFndFlg41 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W17CNT1'
     C***                          And w17cnt1  <> 0
     C                   Clear                   Tmp17cnt          5
     C                   Move      w17cnt1       Tmp17cnt
     C                   MoveL     Tmp17cnt      SCFLVAL
     C                   Eval      UFndFlg42 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W18CNT2'
     C***                          And w18cnt2  <> 0
     C                   Clear                   Tmp18cnt          5
     C                   Move      w18cnt2       Tmp18cnt
     C                   MoveL     Tmp18cnt      SCFLVAL
     C                   Eval      UFndFlg43 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W7CWGT'
     C                             And w7cwgt   <> *Blanks
     C                   Eval      SCFLVAL  = w7cwgt
     C                   Eval      UFndFlg44 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W18LBL'
     C                             And w18lbl   <> 0
     C                   Clear                   Tmp18lbl          7
     C                   Move      w18lbl        Tmp18lbl
     C                   MoveL     Tmp18lbl      SCFLVAL
     C                   Eval      UFndFlg45 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'WTCHK'
     C                             And wtchk    <> *Blanks
     C                   Eval      SCFLVAL  = wtchk
     C                   Eval      UFndFlg46 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'WLUSERCHOICE'
     C                             And (WLUserChoice     = *On
     C                                  Or WLUserChoice  = *Off)
     C                   Eval      SCFLVAL  = WLUserChoice
     C                   Eval      UFndFlg47 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W6ACNT1'
     C***                          And w6acnt1  <> 0
     C                   Clear                   Tmp6acnt          5
     C                   Move      w6acnt1       Tmp6acnt
     C                   MoveL     Tmp6acnt      SCFLVAL
     C                   Eval      UFndFlg48 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'FIRST6A'
     C                             And first6a   <> *Blanks
     C                   Eval      SCFLVAL  = first6a
     C                   Eval      UFndFlg49 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W6STOP'
     C***                          And w6stop   <> 0
     C                   Clear                   Tmp6stp           5
     C                   Move      w6stop        Tmp6stp
     C                   MoveL     Tmp6stp       SCFLVAL
     C                   Eval      UFndFlg50 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W18STOP'
     C***                          And w18stop  <> 0
     C                   Clear                   Tmp18stp          5
     C                   Move      w18stop       Tmp18stp
     C                   MoveL     Tmp18stp      SCFLVAL
     C                   Eval      UFndFlg51 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'KILOLBS'
     C                             And KiloLbs   <> *Blanks
     C                   Eval      SCFLVAL  = KiloLbs
     C                   Eval      UFndFlg52 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$SLVFYLBLIN'
     C                             And $slvfylblin  <> *Blanks
     C                   Eval      SCFLVAL  = $slvfylblin
     C                   Eval      UFndFlg53 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = 'UMFLEXPICKFLAG'
     C                             And umFlexPickFlag <> *Blanks
     C                   Eval      SCFLVAL  = umFlexPickFlag
     C                   Eval      UFndFlg54 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C***                When      SCFLVAR  = 'CMDTKN'
     C***                          And cmdtkn       <> *Blanks
     C***                Eval      SCFLVAL  = cmdtkn
     C***                Eval      UFndFlg55 = 'Y'
     C***                Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = 'X'
     C***                          And x        <> 0
     C                   Clear                   Tmpx              7
     C                   Move      x             Tmpx
     C                   MoveL     Tmpx          SCFLVAL
     C                   Eval      UFndFlg56 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'I'
     C***                          And i        <> 0
     C                   Clear                   Tmpi              7
     C                   Move      i             Tmpi
     C                   MoveL     Tmpi          SCFLVAL
     C                   Eval      UFndFlg57 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'UPCYES'
     C                             And (upcyes        = *On
     C                                  Or upcyes     = *Off)
     C                   Eval      SCFLVAL  = upcyes
     C                   Eval      UFndFlg58 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W18OITEM'
     C                             And w18oitem  <> *Blanks
     C                   Eval      SCFLVAL  = w18oitem
     C                   Eval      UFndFlg60 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C**                 When      SCFLVAR  = '$SLWEIGHTIN'
     C**                           And $slweightin <> *Blanks
     C**                 Eval      SCFLVAL  = $slweightin
     C**                 Eval      UFndFlg61 = 'Y'
     C**                 Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W17TRN#'
     C                             And w17trn#  <> 0
     C                   Clear                   Tmptrn            7
     C                   Move      w17trn#       Tmptrn
     C                   MoveL     Tmptrn        SCFLVAL
     C                   Eval      UFndFlg62 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = 'W17LBL#'
     C                             And w17lbl#  <> 0
     C                   Clear                   Tmplbl17          7
     C                   Move      w17lbl#       Tmplbl17
     C                   MoveL     Tmplbl17      SCFLVAL
     C                   Eval      UFndFlg63 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
     C                   When      SCFLVAR  = '$HDRIPADDR'
     C                             And $hdripaddr <> *Blanks
     C                   Eval      SCFLVAL  = $hdripaddr
     C                   Eval      UFndFlg64 = 'Y'
     C                   Eval      UFndFlg   = 'Y'
      *
     C                   Endsl
      *
     C                   If        UFndFlg  = 'Y'
     C                   Update    JSCFLDFR
     C                   EndIf
      *
     C                   Enddo
      *
     *                  Write if veriable-values not found
     C                   Eval      SCFLUID = IUid
     C                   Eval      SCFLUSR  = IUserId
     C                   Eval      SCFLPGM = TmpvarPgm
     C                   Eval      SCFLTIMS = %TimeStamp()
      *
     C                   If        UFndFlg1 <> 'Y'
     C                             And $slsignrfin  <> *Blanks
     C                   Eval      SCFLVAR  = '$SLSIGNRFIN'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slsignrfin   SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg2 <> 'Y'
     C                             And $slsignrfout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLSIGNRFOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slsignrfout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg3 <> 'Y'
     C                             And $slbedayout  <> *Blanks
     C                   Eval      SCFLVAR  = '$SLBEDAYOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slbedayout   SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg4 <> 'Y'
     C                             And $slassignout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLASSIGNOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slassignout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg5 <> 'Y'
     C                             And $slpicksout  <> *Blanks
     C                   Eval      SCFLVAR  = '$SLPICKSOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slpicksout   SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg6 <> 'Y'
     C                             And $slvfylblout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLVFYLBLOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slvfylblout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg7 <> 'Y'
     C                             And w2lbl#b  <> *Blanks
     C                   Eval      SCFLVAR  = 'W2LBL#B'
     C                   Clear                   SCFLVAL
     C                   MoveL     w2lbl#b       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg8 <> 'Y'
     C                             And w3scan   <> *Blanks
     C                   Eval      SCFLVAR  = 'W3SCAN'
     C                   Clear                   SCFLVAL
     C                   MoveL     w3scan        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg9 <> 'Y'
     C                             And w3disp   <> *Blanks
     C                   Eval      SCFLVAR  = 'W3DISP'
     C                   Clear                   SCFLVAL
     C                   MoveL     w3disp        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg10 <> 'Y'
     C                             And ufinfl   <> *Blanks
     C                   Eval      SCFLVAR  = 'UFINFL'
     C                   Clear                   SCFLVAL
     C                   MoveL     ufinfl        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg11 <> 'Y'
     C                             And $header  <> *Blanks
     C                   Eval      SCFLVAR  = '$HEADER'
     C                   Clear                   SCFLVAL
     C                   MoveL     $header       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg12 <> 'Y'
     C                             And w2lbl    <> 0
     C                   Eval      SCFLVAR  = 'W2LBL'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmplbl            7
     C                   Move      w2lbl         Tmplbl
     C                   MoveL     Tmplbl        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg13 <> 'Y'
     C                             And first6   <> *Blanks
     C                   Eval      SCFLVAR  = 'FIRST6'
     C                   Clear                   SCFLVAL
     C                   MoveL     first6        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg14 <> 'Y'
     C                             And lbutyp   <> *Blanks
     C                   Eval      SCFLVAR  = 'LBUTYP'
     C                   Clear                   SCFLVAL
     C                   MoveL     lbutyp        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg15 <> 'Y'
     C                             And w6cnt1   <> 0
     C                   Eval      SCFLVAR  = 'W6CNT1'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp6Cnt           5
     C                   Move      w6cnt1        Tmp6Cnt
     C                   MoveL     Tmp6Cnt       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg16 <> 'Y'
     C                             And whereFrom <> *Blanks
     C                   Eval      SCFLVAR  = 'WHEREFROM'
     C                   Clear                   SCFLVAL
     C                   MoveL     whereFrom     SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg17 <> 'Y'
     C                             And first2    <> *Blanks
     C                   Eval      SCFLVAR  = 'FIRST2'
     C                   Clear                   SCFLVAL
     C                   MoveL     first2        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg18 <> 'Y'
     C                             And aisle     <> *Blanks
     C                   Eval      SCFLVAR  = 'AISLE'
     C                   Clear                   SCFLVAL
     C                   MoveL     aisle         SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg19 <> 'Y'
     C                             And lbord    <> 0
     C                   Eval      SCFLVAR  = 'LBORD'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmplbo            7
     C                   Move      lbord         Tmplbo
     C                   MoveL     Tmplbo        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg20 <> 'Y'
     C                             And ovrrid    <> *Blanks
     C                   Eval      SCFLVAR  = 'OVRRID'
     C                   Clear                   SCFLVAL
     C                   MoveL     ovrrid        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg21 <> 'Y'
     C                             And w6lbl    <> 0
     C                   Eval      SCFLVAR  = 'W6LBL'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp6lbl           7
     C                   Move      w6lbl         Tmp6lbl
     C                   MoveL     Tmp6lbl       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg22 <> 'Y'
     C                             And (firstzonepick = *On
     C                                  Or firstzonepick = *Off)
     C                   Eval      SCFLVAR  = 'FIRSTZONEPICK'
     C                   Clear                   SCFLVAL
     C                   MoveL     firstzonepick SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg23 <> 'Y'
     C                             And (zonepickup    = *On
     C                                  Or zonepickup = *Off)
     C                   Eval      SCFLVAR  = 'ZONEPICKUP'
     C                   Clear                   SCFLVAL
     C                   MoveL     zonepickup    SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg24 <> 'Y'
     C                             And $slresetuout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLRESETUOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slresetuout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg25 <> 'Y'
     C                             And $slskipcwout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLSKIPCWOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slskipcwout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg26 <> 'Y'
     C                             And $slvfyupuout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLVFYUPUOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slvfyupuout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg27 <> 'Y'
     C                             And $slvfylicout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLVFYLICOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slvfylicout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg28 <> 'Y'
     C                             And $slpckuciout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLPCKUCIOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slpckuciout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg29 <> 'Y'
     C                             And $slscancwout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLSCANCWOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slscancwout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg30 <> 'Y'
     C                             And $slcloseout  <> *Blanks
     C                   Eval      SCFLVAR  = '$SLCLOSEOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slcloseout   SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg31 <> 'Y'
     C                             And $slgetcwout  <> *Blanks
     C                   Eval      SCFLVAR  = '$SLGETCWOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slgetcwout   SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg32 <> 'Y'
     C                             And $slchk4ufout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLCHK4UFOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slchk4ufout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg33 <> 'Y'
     C                             And $slsuspndout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLSUSPNDOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slsuspndout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg34 <> 'Y'
     C                             And $slvfysltout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLVFYSLTOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slvfysltout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg35 <> 'Y'
     C                             And $slcompl2out <> *Blanks
     C                   Eval      SCFLVAR  = '$SLCOMPL2OUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slcompl2out  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg36 <> 'Y'
     C                             And $slpickchout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLPICKCHOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slpickchout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg37 <> 'Y'
     C                             And $slpickout   <> *Blanks
     C                   Eval      SCFLVAR  = '$SLPICKOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slpickout    SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg38 <> 'Y'
     C                             And $slresettout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLRESETTOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slresettout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg39 <> 'Y'
     C                             And $slweightout <> *Blanks
     C                   Eval      SCFLVAR  = '$SLWEIGHTOUT'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slweightout  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg40 <> 'Y'
     C                             And first18   <> *Blanks
     C                   Eval      SCFLVAR  = 'FIRST18'
     C                   Clear                   SCFLVAL
     C                   MoveL     first18       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg41 <> 'Y'
     C                             And first19   <> *Blanks
     C                   Eval      SCFLVAR  = 'FIRST19'
     C                   Clear                   SCFLVAL
     C                   MoveL     first19       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg42 <> 'Y'
     C                             And w17cnt1  <> 0
     C                   Eval      SCFLVAR  = 'W17CNT1'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp17Cnt          5
     C                   Move      w17cnt1       Tmp17Cnt
     C                   MoveL     Tmp17Cnt      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg43 <> 'Y'
     C                             And w18cnt2  <> 0
     C                   Eval      SCFLVAR  = 'W18CNT2'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp18Cnt          5
     C                   Move      w18cnt2       Tmp18Cnt
     C                   MoveL     Tmp18Cnt      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg44 <> 'Y'
     C                             And w7cwgt    <> *Blanks
     C                   Eval      SCFLVAR  = 'W7CWGT'
     C                   Clear                   SCFLVAL
     C                   MoveL     w7cwgt        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg45 <> 'Y'
     C                             And w18lbl   <> 0
     C                   Eval      SCFLVAR  = 'W18LBL'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp18lbl          7
     C                   Move      w18lbl        Tmp18lbl
     C                   MoveL     Tmp18lbl      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg46 <> 'Y'
     C                             And wtchk     <> *Blanks
     C                   Eval      SCFLVAR  = 'WTCHK'
     C                   Clear                   SCFLVAL
     C                   MoveL     wtchk         SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg47 <> 'Y'
     C                             And (WLUserChoice    = *On
     C                                  Or WLUserChoice = *Off)
     C                   Eval      SCFLVAR  = 'WLUSERCHOICE'
     C                   Clear                   SCFLVAL
     C                   MoveL     WLUserChoice  SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg48 <> 'Y'
     C                             And w6acnt1  <> 0
     C                   Eval      SCFLVAR  = 'W6ACNT1'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp6aCnt          5
     C                   Move      w6acnt1       Tmp6aCnt
     C                   MoveL     Tmp6aCnt      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg49 <> 'Y'
     C                             And first6a   <> *Blanks
     C                   Eval      SCFLVAR  = 'FIRST6A'
     C                   Clear                   SCFLVAL
     C                   MoveL     first6a       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg50 <> 'Y'
     C                             And w6stop   <> 0
     C                   Eval      SCFLVAR  = 'W6STOP'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp6stp           5
     C                   Move      w6stop        Tmp6stp
     C                   MoveL     Tmp6stp       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg51 <> 'Y'
     C                             And w18stop  <> 0
     C                   Eval      SCFLVAR  = 'W18STOP'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmp18stp          5
     C                   Move      w18stop       Tmp18stp
     C                   MoveL     Tmp18stp      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg52 <> 'Y'
     C                             And KiloLbs   <> *Blanks
     C                   Eval      SCFLVAR  = 'KILOLBS'
     C                   Clear                   SCFLVAL
     C                   MoveL     KiloLbs       SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg53 <> 'Y'
     C                             And $slvfylblin  <> *Blanks
     C                   Eval      SCFLVAR  = '$SLVFYLBLIN'
     C                   Clear                   SCFLVAL
     C                   MoveL     $slvfylblin   SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg54 <> 'Y'
     C                             And umFlexPickFlag <> *Blanks
     C                   Eval      SCFLVAR  = 'UMFLEXPICKFLAG'
     C                   Clear                   SCFLVAL
     C                   Eval      SCFLVAL  = umFlexPickFlag
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C***                If        UFndFlg55 <> 'Y'
     C***                          And cmdtkn       <> *Blanks
     C***                Eval      SCFLVAR  = 'CMDTKN'
     C***                Clear                   SCFLVAL
     C***                MoveL     cmdtkn        SCFLVAL
     C***                Write     JSCFLDFR
     C***                Endif
      *
     C                   If        UFndFlg56 <> 'Y'
     C                             And x        <> 0
     C                   Eval      SCFLVAR  = 'X'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmpx              7
     C                   Move      x             Tmpx
     C                   MoveL     Tmpx          SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg57 <> 'Y'
     C                             And i        <> 0
     C                   Eval      SCFLVAR  = 'I'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmpi              7
     C                   Move      i             Tmpi
     C                   MoveL     Tmpi          SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg58 <> 'Y'
     C                             And (upcyes        = *On
     C                                  Or upcyes     = *Off)
     C                   Eval      SCFLVAR  = 'UPCYES'
     C                   Clear                   SCFLVAL
     C                   MoveL     upcyes        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg60 <> 'Y'
     C                             And w18oitem  <> *Blanks
     C                   Eval      SCFLVAR  = 'W18OITEM'
     C                   Clear                   SCFLVAL
     C                   MoveL     w18oitem      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C**                 If        UFndFlg61 <> 'Y'
     C**                           And $slweightin <> *Blanks
     C**                 Eval      SCFLVAR  = '$SLWEIGHTIN'
     C**                 Clear                   SCFLVAL
     C**                 MoveL     $slweightin   SCFLVAL
     C**                 Write     JSCFLDFR
     C**                 Endif
      *
     C                   If        UFndFlg62 <> 'Y'
     C                             And w17trn#  <> 0
     C                   Eval      SCFLVAR  = 'W17TRN#'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmptrn            7
     C                   Move      w17trn#       Tmptrn
     C                   MoveL     Tmptrn        SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg63 <> 'Y'
     C                             And w17lbl#  <> 0
     C                   Eval      SCFLVAR  = 'W17LBL#'
     C                   Clear                   SCFLVAL
     C                   Clear                   Tmplbl17          7
     C                   Move      w17lbl#       Tmplbl17
     C                   MoveL     Tmplbl17      SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     C                   If        UFndFlg64 <> 'Y'
     C                             And $hdripaddr <> *Blanks
     C                   Eval      SCFLVAR  = '$HDRIPADDR'
     C                   Clear                   SCFLVAL
     C                   MoveL     $hdripaddr    SCFLVAL
     C                   Write     JSCFLDFR
     C                   Endif
      *
     *
     C                   Endsr
    *                  =====
