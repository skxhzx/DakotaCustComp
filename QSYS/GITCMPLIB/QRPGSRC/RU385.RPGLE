     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU385     Write records to RUNNER file.
     *  Randy Haselhorst
     *  17 October 2006
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    10/17/06  RAH  5.10
     *      - Created.
510aA*    05/23/07  MLB  5.10a
     *      - Enh: Revised program to update LABEL record LBQPCK
     *        zero when Runner option OPUPLR = Yes.
     *      - Add files LABEL, OPTIONS, PIRTRAN.
510bA*    05/23/07  MLB  5.10b
     *      - Fix: Revised program to only update RUOTRN instead of
     *        RUTRN#. RUTRN# is the Runner transaction number.
510cA*    05/29/07  MLB  5.10c
     *      - Fix: Revised program to create Runner entry when
     *        OPCRTM=Y.
510dA*    06/25/07  MLB  5.10d
     *      - Fix: Revised program to only create Runner entries
     *        for Merge labels when opmrgf=Y.
     *      - Revised pgm to receive label type from calling pgm.
510eA*    08/22/07  MLB  5.10e
     *      - Fix: Revised program to retrieve warehouse department
     *        from PIRITEM when processing $PTYPE=M Merge label.
     *        Value in LBWHDP is slot zone, not actual department.
640aA*    06/07/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
710aA*    06/05/17  TAB  7.10a
     *      - Enh: Added new runner type for Box Breaker / create
     *        runner record with type 'B' when breakdown qty is being
     *        shorted.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
510aAFLabel     uf   e           k disk
510aAFOptions   if   e           k disk
510eAFPiritem   if   e           k disk
510aAFPirtran   uf   e           k disk
710aAFitemfld   if   e           k disk
     Frunner    o    e             disk
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
510aA*
510aA*----------------------------------------------------------------
510aA*  *RUNNER  -  PIR Runner Flag Options
510aA*----------------------------------------------------------------
510aA*
510aA* Fields
510aA*
510aA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
510aA*    OPUPLR  -  Update Label with quantity shorted during manual
510aA*               flag entry (Y/N)
510aA*               NOTE: Any change to this field will cause OPUPLV
510aA*                     in the *VOICE options record to be updated.
510aA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
510aA*               & create Priority Replenishment if necessary.
510aA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
510aA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
510aA*               NOTE: Any change to this field will cause OPFCLR
510aA*                     in the *VOICE options record to be updated.
510aA*    OPRNRM  -  Send break message to user when new Runner
510aA*               task has been assigned. (Y/N)
510aA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
510aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
510aA*    OPRPCK  -  Print Runner pick list. (Y/N)
510aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
510aA*               printer, 2=Belt printer
510aA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
510aA*----------------------------------------------------------------
510aA* Data structure
510aA*
510aAD oprdta          ds
510aAD  opcrtm                 1      1
510aAD  opuplr                 2      2
510aAD  oprplf                 3      3
510aAD  opmrgf                 4      4
510aAD  opclrf                 5      5
510aAD  oprnrm                 6      6
510aAD  opclsf                 7      7
510aAD  opoutf                 8      8
510aAD  oprpck                 9      9
510aAD  oprlbl                10     10
510aAD  oprbdu                11     11
510aAD  optendr              117    117
510aA*
     *----------------------------------------------------------------
     *  Variables
     *
510aAD svqpck          s                   like(lbqpck)
510aAD svcube          s                   like(lbcube)
510aAD svswgt          s                   like(lbswgt)
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
710aAD UCISelect       s               n
510aA*
     *----------------------------------------------------------------
     *  Key fields
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
510dA*      $CMD    Command  - *ADD - Add runner entry
510dM*      RUWHSE  Warehouse
510dM*      RUWHDP  Warehouse department
510dM*      RULBL#  Label number
510dM*      RUOTRN  Original transaction number
510dM*      RUDISP  Pick slot for item
510dM*      $QALC   Quantity allocated
510dA*      $PTYPE  Label type
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     *  Mainline
     *
     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    ruwhse
     C                   parm                    ruwhdp
     C                   parm                    rulbl#
510bDC*                  parm                    rutrn#
510bMC                   parm                    ruotrn
     C                   parm                    rudisp
     C                   parm                    $qalc             5 0
510dAC                   parm                    $ptype            1
     *
510cA*      Create manual runner entries.
510cAC                   if        opcrtm = 'Y'
510dAC                             and $ptype <> 'M'
510cA*
510dA*      or Create runner entries for Merge records.
510dAC                             or  opcrtm = 'Y'
510dAC                             and opmrgf = 'Y'
510dAC                             and $ptype = 'M'
510eA*
510eAC                   if            opcrtm = 'Y'
510eAC                             and opmrgf = 'Y'
510eAC                             and $ptype = 'M'
510eA*      Retrieve actual department from item master.
510eAC     rulbl#        chain (n) label
510eAC                   if        %found(label)
510eAC     itkey         chain     piritem
510eAC                   if        %found(piritem)
510eAC                   eval      ruwhdp = itwhdp
510eAC                   endif
510eAC                   endif
510eA*
510eAC                   endif
710aAC                   exsr      zzitemfld
510dA*
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
     c                   eval      rutype = 'N'
710aAC                   EndIf
510bDc*                  eval      ruotrn = rutrn#
     c                   eval      ruoqys = $qalc
     c                   eval      ruqyso = $qalc
     c                   eval      ruqyfd = *zeros
     c                   eval      rustat = 'O'
     c                   time                    ruodts
     c                   clear                   rurdts
     c                   clear                   rupdts
     c                   clear                   rucdts
     *
     C                   write     rurec
     *
510aA*      Update LABEL record
510aAC                   if        opuplr = 'Y'
510dAC                             and $ptype <> 'M'
510aAC                   exsr      zzupdate
510aAC                   endif
510cA*
510cAC                   endif
510cA*
     c                   eval      *inlr = *on
     C                   return
510aA*----------------------------------------------------------------
510aA*
510aA*          Subroutines in Alphabetical Order
510aA*
510aA*----------------------------------------------------------------
510aA*
510aA*  *INZSR  Initialization subroutine
510aA*
510aAC     *inzsr        begsr
510aA*
510aA* Get client id.
510aA*
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
510aA*
510aA*  Define keys
510aA*
510aA*  Define key for OPTIONS file.
510aA*
510aAC     opkey         klist
510aAC                   kfld                    ruwhse
510aAC                   kfld                    opcode
510eA*
510eA*  Define key for PIRITEM file.
510eA*
510eAC     itkey         klist
510eAC                   kfld                    lbwhse
510eAC                   kfld                    lbitem
510aA*
510aA*   Retrieve Runner options.
510aA*
510aAC                   eval      opcode = '*RUNNER '
510aAC     opkey         chain     options
510aAC                   if        not %found(options)
510aAC                   eval      opclrf = 'Y'
510aAC                   eval      opuplr = 'N'
510aAC                   else
510aAC                   movel     opdata        oprdta
510aAC                   endif
510aA*
510aAC                   endsr
510aA*
710aA*----------------------------------------------------------------
710aA*
710aA*  ZZITEMFLD Get item field infotmation for Box Breaker runner
710aA*
710aA*    Input:  KYWHSE, KYITEM
710aA*
710aAC     zzitemfld     begsr
710aAC                   Eval      UCISelect = *Off
710aAC     itkey         chain     itemfld

710aAC                   If        %Found(itemfld)
710aAC                   Select

710aAC                   When      IFSLTMTH = '2'
710aAC                   Eval      UCISelect = *On

710aAC                   Other
710aAC                   EndSl
710aAC                   EndIf

710aAC                   endsr
     *
510aA*----------------------------------------------------------------
510aA*
510aA*  ZZUPDATE  Update Label, Transaction records.
510aA*
510aAC     zzupdate      begsr
510aA*
510aAC     rulbl#        chain     label
510aAC                   if        %found(Label)
510aAC                   eval      svqpck = lbqpck
510aAC                   eval      lbqpck = 0
510aAC                   eval      svcube = lbcube
510aAC                   eval      lbcube = 0
510aAC                   eval      svswgt = lbswgt
510aAC                   eval      lbswgt = 0
510aAC                   update    lbrec
510aA*
510aAC     ruotrn        chain     pirtran
510aAC                   if        %found(Pirtran)
510aAC                   eval      ptpcs  = ptpcs  - svqpck
510aAC                   eval      ptcube = ptcube - svcube
510aAC                   eval      ptswgt = ptswgt - svswgt
510aAC                   update    ptrec
640aAc                   exsr      zzwrttrand
510aAC                   endif
510aA*
510aAC                   endif
510aA*
510aAC                   endsr
510aA*
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
