    *****************************************************************
    * Set output for next screen
    *****************************************************************
     C     $SetNxtScr    begsr
    *    ==========    =====
      *
     C                   Select
      *
     C                   When      nxtscr = '03 '
     C                   eval      OCurrScr  = 'OR680.03'
     C                   eval      ONxtPgm   = 'JSC6803PR'
     C                   eval      OParm1    = W3ITEM
     C                   eval      OParm2    = 'From: ' + W3FMSL
     C                   eval      OParm3    = 'Lcn '   + W3LCNS
     C                   eval      OParm4    = 'Qty: '  + %Char(W3NQTY) + ' '
     C                                          + W3UMSR
     C                   eval      OParm6    = 'Scan: ' + W3SCAN
      *
     C                   When      nxtscr = '04 '
     C                   eval      OCurrScr  = 'OR680.04'
     C                   eval      ONxtPgm   = 'JSC6804PR'
      *
     C                   When      nxtscr = '05 '
     C                   eval      OCurrScr  = 'OR680.05'
     C                   eval      ONxtPgm   = 'JSC6805PR'
     C                   eval      OParm1    = W5ITEM
     C                   eval      OParm2    = 'Slot: ' + W5DISP
     C                   eval      OParm3    = 'Qty: '  + %Char(W5OQTY)
     C                   eval      OParm4    = W5UMSR
     C                   eval      OParm5    = 'Bal: '  + %Char(W5BALQ)
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
     C     IUid          Setll     JSC68FLD01
     C                   Dow       Not %Eof(JSC68FLD01)
     C     IUid          Reade     JSC68FLD01
     C                   If        %Eof(JSC68FLD01)
     C                   Leave
     C                   Endif
      *
     C                   Select
     C                   When      SCFLVAR  = 'LSTSCR'
     C                   MoveL     SCFLVAL       lstscr
     C                   When      SCFLVAR  = '#SITEM'
     C                   MoveL     SCFLVAL       #sitem
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
     C                   Clear                   UFndFlg2          2
     *                  Update Existing veriables-values
     C     IUid          Setll     JSC68FLD01
     C                   Dow       Not %Eof(JSC68FLD01)
     C     IUid          Reade     JSC68FLD01
     C                   If        %Eof(JSC68FLD01)
     C                   Leave
     C                   Endif
      *
     C                   Clear                   UFndFlg           1
     C                   Eval      SCFLUSR  = IUserId
     C                   Eval      SCFLPGM  = TmpvarPgm
     C                   Eval      SCFLTIMS = %TimeStamp()
     C                   Select
     C                   When      SCFLVAR  = 'LSTSCR'
     C                             And lstscr       <> *Blanks
     C                   Eval      SCFLVAL  = lstscr
     C                   Eval      UFndFlg1 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
     C                   When      SCFLVAR  = '#SITEM'
     C                             And #sitem       <> *Blanks
     C                   Eval      SCFLVAL  = #sitem
     C                   Eval      UFndFlg2 = 'Y'
     C                   Eval      UFndFlg  = 'Y'
      *
     C                   Endsl
      *
     C                   If        UFndFlg  = 'Y'
     C                   Update    JSC68FLDR
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
     C                             And lstscr       <> *Blanks
     C                   Eval      SCFLVAR  = 'LSTSCR'
     C                   Clear                   SCFLVAL
     C                   MoveL     lstscr        SCFLVAL
     C                   Write     JSC68FLDR
     C                   Endif
      *
     C                   If        UFndFlg2 <> 'Y'
     C                             And #sitem       <> *Blanks
     C                   Eval      SCFLVAR  = '#SITEM'
     C                   Clear                   SCFLVAL
     C                   MoveL     #sitem        SCFLVAL
     C                   Write     JSC68FLDR
     C                   Endif
     *
     C                   Endsr
    *                  =====
