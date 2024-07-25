      /copy qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   P.O. Box 1957
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  UTYHT005    Update Pick Slot Qty from Retalix Onhand by Dept
     F*  30 September 2016
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*  79        - General purpose EOF indicator.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FPIRITEM1  IF   E           K DISK    rename(itrec : itrec1)
     FSLOT3     UF   E           K DISK    rename(slrec : slrec3)
     Fitemadj   if a E           K DISK
     FFFJITMBL0 IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*                   DESC    1  44 30
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D*  Redefined field varialbles
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
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
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
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
     C*----------------------------------------------------------------
     C*  Working variable(s)
     C*
     D newstk1         s              7s 0 inz(0)
     D newstk2         s              7s 0 inz(0)
     D newstk3         s              7s 0 inz(0)
     D totstk1         s              9s 0 inz(0)
     D totstk2         s              7s 0 inz(0)
     D totstk3         s              7s 0 inz(0)
     D wkTtlQty        s              7  0 inz
     D wkHostQty       s              7  0 inz
     D wkDiffQty       s              7  0 inz
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   Processing option.
     C*        *PICKONLY - Update pick slot stock quantity
     C*        *CRTHOSTADJ - Create ITEMADJ rcd for difference in BFC/Host
     C*                      qty.
     C*      $PWHS   Dakota warehouse to process.
     C*      $PCMPN  Host Company to process
     C*      $PDIVN  Host Division to process
     C*      $PDPTN  Host Department to process
     C*      $PWHSN  Host Warehouse to process
     C*      $PWHDP  Dakota department to process. *ALL or -dept-.
     C*      $PAISL  Dakota aisle to process. blank or -aisle-.
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD            15
     C                   PARM                    $PWHS             3
     C                   PARM                    $PCMPN            3
     C                   PARM                    $PDIVN            3
     C                   PARM                    $PDPTN            3
     C                   PARM                    $PWHSN            3
     C                   PARM                    $PWHDP            5
     C                   PARM                    $PAISL            3
     C*
     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   EXSR      ZZINZ2
     C*
     C*  Select which to process, Pick Slot Update or Create Adj to Host
     C*
     C                   SELECT
     C                   when      $pcmd = '*PICKONLY'
     C                   EXSR      zzpickonly
     C*
     C                   when      $pcmd = '*CRTHOSTADJ'
     C                   EXSR      zzcrthostadj
     C*
     C                   ENDSL
     C*
     C*  We are finished so get out
     C*
     C                   MOVE      *ON           *INLR
     C*----------------------------------------------------------------
     C*
     C*          Subroutines in Alphabetical Order
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine
     C*
     CSR   *INZSR        BEGSR
     CSR                 MOVE      $PWHS         $PWHSE            3 0
     C* Key definitions
     C*
     C* FS-WMS file keys
     C*
     C     itkey         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    $pwhdp
     C*
     CSR   *LIKE         DEFINE    SLWHSE        KYWHSE
     CSR   *LIKE         DEFINE    SLSTAT        KYSTAT
     CSR   *LIKE         DEFINE    SLPICK        KYPICK
     CSR   SLKEY         KLIST
     CSR                 KFLD                    itwhse
     CSR                 KFLD                    ititem
     CSR                 KFLD                    kystat
     CSR                 KFLD                    kypick
     C*
     C     SLKEY_all     KLIST
     C                   KFLD                    itwhse
     C                   KFLD                    ititem
     C                   KFLD                    kystat
     C*
     C* Retalix file keys
     C*
     CSR   *LIKE         DEFINE    FFJITMN       kyitmn
     CSR   KEYFJ         KLIST
     CSR                 KFLD                    $pcmpn
     CSR                 KFLD                    $pdivn
     CSR                 KFLD                    $pdptn
     CSR                 KFLD                    $pwhsn
     CSR                 KFLD                    kyitmn
     C*
     C*
     C*  Variables and constants.
     C*
     CSR                 MOVE      *OFF          FOREVR            1
     CSR                 MOVE      *BLANKS       WKITM10          10
     CSR                 MOVE      *BLANKS       WKIT15           15
     CSR                 MOVE      *BLANKS       DIRCTN            8
     CSR                 MOVE      *ZEROS        POS               3 0
     CSR                 MOVE      *ZEROS        LEN               3 0
     C*
     C*  Convert today's date into century format.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        TODAY             8 0
     C*
     CSR                 MOVE      #PROG         $LPRG
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZPICKONLY    Process Fixed items for Pick Slot Update
     C*
     C     zzpickonly    BEGSR
     C*
     C                   if        $pwhdp = '*ALL'
     C     $pwhse        setll     piritem1
     C                   else
     C     itkey         setll     piritem1
     C                   endif
     C*
     C                   dow       forevr = forevr
     C                   if        $pwhdp = '*ALL'
     C     $pwhse        reade     piritem1
     C                   else
     C     itkey         reade     piritem1
     C                   endif
     C                   select
     C                   when      %eof(piritem1)
     C                   leave
     C*
     C                   when           itstyp = 'F'
     C*       Include only Normal or type B=Breakdown items.
     C                             and (ittype = ' '
     C                               or ittype = 'B')
     C*
     C                   eval      totstk1 = 0
     C                   eval      totstk2 = 0
     C                   eval      totstk3 = 0
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     slkey         setll     slot3
     C*
     C                   dow       forevr = forevr
     C     slkey         reade (n) slot3
     C                   select
     C                   when      %eof(slot3)
     C                   leave
     C*
     C*        Skip aisles counted completely.
     C                   when          $paisl > ' '
     C                             and slwhdp = 'DRY'
     C                             and (slaisl = ' 50'
     C                               or slaisl = ' 51'
     C                               or slaisl = ' 52'
     C                               or slaisl = ' 53')
     C                   iter
     C*
     C                   other
     C*
     C*       Accumulate total quantity in overflow slots.
     C                   eval      totstk1 = totstk1 + slstk1
     C                   eval      totstk2 = totstk2 + slstk2
     C                   eval      totstk3 = totstk3 + slstk3
     C*
     C                   endsl
     C*
     C                   enddo
     C*
     C*       Retrieve Host quantity on-hand
     C                   move      '*RIGHT  '    DIRCTN
     C                   move      ITITEM        WKIT15
     C                   exsr      zzltrt
     C                   eval      kyitmn = wkitm10
     C     keyfj         chain     ffjitmbl0
     C                   select
     C                   when      %found(ffjitmbl0)
     C
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     slkey         setll     slot3
     C     slkey         reade     slot3
     C                   select
     C*
     C*        Skip aisles counted completely.
     C                   when      not %eof(slot3)
     C                             and $paisl > ' '
     C                             and slwhdp = 'DRY'
     C                             and (slaisl = ' 50'
     C                               or slaisl = ' 51'
     C                               or slaisl = ' 52'
     C                               or slaisl = ' 53')
     C                   iter
     C*
     C*       Update all other aisles' pick slots.
     C                   when      not %eof(slot3)
     C*
     C                   exsr      zzcalcpickqty
     C*
     C*       Change in qty, update stock qty in pick slot.
     C                   if        wkDiffQty <> 0
     C                   eval      slstk1 = newstk1
     C                   eval      slstk2 = newstk2
     C                   eval      slstk3 = newstk3
     C                   exsr      zzupd
     C                   endif
     C*
     C                   endsl
     C*
     C                   endsl
     C*
     C                   endsl
     C*
     C                   Enddo
     C*
     C                   Endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCRTHOSTADJ    Process Fixed items and Create Host Sync Qty Adj
     C*
     C     zzcrthostadj  BEGSR
     C*
     C                   if        $pwhdp = '*ALL'
     C     $pwhse        setll     piritem1
     C                   else
     C     itkey         setll     piritem1
     C                   endif
     C*
     C                   dow       forevr = forevr
     C                   if        $pwhdp = '*ALL'
     C     $pwhse        reade     piritem1
     C                   else
     C     itkey         reade     piritem1
     C                   endif
     C                   select
     C                   when      %eof(piritem1)
     C                   leave
     C*
     C                   when           itstyp = 'F'
     C*       Include only Normal or type B=Breakdown items.
     C                             and (ittype = ' '
     C                               or ittype = 'B')
     C*
     C                   eval      totstk1 = 0
     C                   eval      totstk2 = 0
     C                   eval      totstk3 = 0
     C                   eval      kystat = 'A '
     C     slkey_all     setll     slot3
     C*
     C                   dow       forevr = forevr
     C     slkey_all     reade (n) slot3
     C                   select
     C                   when      %eof(slot3)
     C                   leave
     C*
     C*        Select aisle(s) counted completely.
     C                   when          $paisl > ' '
     C                             and slwhdp =  'DRY'
     C                             and slaisl <> ' 50'
     C                             and slaisl <> ' 51'
     C                             and slaisl <> ' 52'
     C                             and slaisl <> ' 53'
     C                   iter
     C*
     C                   other
     C*
     C*       Accumulate total quantity in overflow slots.
     C                   eval      totstk1 = totstk1 + slstk1
     C                   eval      totstk2 = totstk2 + slstk2
     C                   eval      totstk3 = totstk3 + slstk3
     C*
     C                   endsl
     C*
     C                   enddo
     C*
     C*        Single aisle was counted completely.
     C                   if            $paisl > ' '
     C                             and totstk1 = 0
     C                             and totstk2 = 0
     C                             and totstk3 = 0
     C*        Get next item, if no overflow qty counted.
     C                   iter
     C                   endif
     C*
     C**********                                          other
     C*
     C*       Retrieve Host quantity on-hand
     C                   move      '*RIGHT  '    DIRCTN
     C                   move      ITITEM        WKIT15
     C                   exsr      zzltrt
     C                   eval      kyitmn = wkitm10
     C     keyfj         chain     ffjitmbl0
     C                   select
     C                   when      %found(ffjitmbl0)
     C
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     slkey         setll     slot3
     C     slkey         reade     slot3
     C                   select
     C                   when      %eof(slot3)
     C                   eval      sldisp = 'NOPCKSL'
     C                   endsl
     C*
     C                   exsr      zzCalcAdjQty
     C*
     C*       Change in qty, write out adj rcd to ITEMADJ.
     C                   if        wkDiffQty <> 0
     C                   exsr      zzwrt
     C                   endif
     C*
     C                   endsl
     C*
     C                   endsl
     C*
     C                   Enddo
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZcalcPickQty  Compute qty different to update into pick slot.
     C*
     C     zzcalcPickQty BEGSR
     C*
     C                   eval      newstk1 = 0
     C                   eval      newstk2 = 0
     C                   eval      newstk3 = 0
     C*
     *    Set Brkdwn 1 qty for conversion calcs below.
     C                   if        itumq2 <= 0
     C                             or ittype = 'S'
     C                   eval      itumq2 = 1
     C                   endif

     *    Set Brkdwn 2 qty for conversion calcs below.
     C                   if        itumq3 <= 0
     C                             or ittype = 'S'
     C                   eval      itumq3 = 1
     C                   endif
     *
     *    Convert Dakota On-hand qty's to lowest form.
     C                   eval      wkTtlQty = (totstk1 * itumq2 * itumq3)
     C                                      + (totstk2 * itumq3)
     C                                      +  totstk3
     *
     *    Convert Host On-hand qty's to lowest form.
     C                   eval      wkHostQty = (ffjqohh * itumq2 * itumq3)
     C                                      + (ffjqobc * itumq3)
     *
     *    Compute qty to be updated into pick slot.
     C                   eval      wkDiffQty = wkHostQty - wkTtlQty
     *
     *    Exit routine when BFC and Retalix qty difference is zero.
     C                   if        wkDiffQty = 0
     C                   leavesr
     C                   endif
     *
     *    Compute pick slot Stock Qty 1.
     C                   eval      newstk1 = wkDiffQty / itumq2
     *
     *    Compute pick slot Stock Qty 2.
     C                   eval      newstk2 = wkDiffQty - (newstk1 * itumq2)
     *
     *    Populate ITEMADJ fields for export to Retalix.
     C                   eval      iawhse = 004
     C                   eval      iaitem = ititem
     C                   eval      iadate = expdte
     C                   eval      iatime = exptim
     C                   eval      iaby   = 'BFCpgm'
     C                   eval      iawhdp = itwhdp
     C                   eval      iadisp = sldisp
     C                   eval      iaqty1 = newstk1
     C                   eval      iaqty2 = newstk2
     C                   eval      iaqty3 = newstk3
     *
     C                   if        itcwgt = 'Y'
     C                   eval      iacwta =  (iaqty1 * itswgt)
     C                                      + iaqty2 * (itswgt / itumq2)
     C                   else
     C                   eval      iacwta = 0
     C                   endif
     *
     C                   eval      iaudte = 0
     C                   eval      iautim = 0
     *
     C                   eval      iacode = 'F2'
     *
     C                   eval      iamemo = 'PkSlot Qty Computed'
     *
     C                   exsr      zzwrt
     *
     C                   Endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZcalcAdjQty  Compute qty different to write out to ITEMADJ file
     C*
     C     zzcalcAdjQty  BEGSR
     C*
     C                   eval      newstk1 = 0
     C                   eval      newstk2 = 0
     C                   eval      newstk3 = 0
     C*
     *    Set Brkdwn 1 qty for conversion calcs below.
     C                   if        itumq2 <= 0
     C                             or ittype = 'S'
     C                   eval      itumq2 = 1
     C                   endif

     *    Set Brkdwn 2 qty for conversion calcs below.
     C                   if        itumq3 <= 0
     C                             or ittype = 'S'
     C                   eval      itumq3 = 1
     C                   endif
     *
     *    Convert Dakota On-hand qty's to lowest form.
     C                   eval      wkTtlQty = (totstk1 * itumq2 * itumq3)
     C                                      + (totstk2 * itumq3)
     C                                      +  totstk3
     *
     *    Convert Host On-hand qty's to lowest form.
     C                   eval      wkHostQty = (ffjqohh * itumq2 * itumq3)
     C                                      + (ffjqobc * itumq3)
     *
     *    Compute qty to be updated into pick slot.
     C                   eval      wkDiffQty = wkHostQty - wkTtlQty
     *
     *    Exit routine when BFC and Retalix qty difference is zero.
     C                   if        wkDiffQty = 0
     C                   leavesr
     C                   endif
     *
     *    Positive Host Qty difference, convert to minus adjustment.
     C                   eval      wkDiffQty = wkDiffQty * -1
     *
     *    Compute Adjustment Qty 1.
     C                   eval      newstk1 = wkDiffQty / itumq2
     *
     *    Compute Adjustment Qty 2.
     C                   eval      newstk2 = wkDiffQty - (newstk1 * itumq2)
     *
     *    Populate ITEMADJ fields for export to Retalix.
     C                   eval      iawhse = 004
     C                   eval      iaitem = ititem
     C                   eval      iadate = expdte
     C                   eval      iatime = exptim
     C                   eval      iaby   = 'BFCpgm'
     C                   eval      iawhdp = itwhdp
     C                   eval      iadisp = sldisp
     C                   eval      iaqty1 = newstk1
     C                   eval      iaqty2 = newstk2
     C                   eval      iaqty3 = newstk3
     *
     C                   if        itcwgt = 'Y'
     C                   eval      iacwta =  (iaqty1 * itswgt)
     C                                      + iaqty2 * (itswgt / itumq2)
     C                   else
     C                   eval      iacwta = 0
     C                   endif
     *
     C                   eval      iaudte = 0
     C                   eval      iautim = 0
     *
     C                   select
     C                   when      iawhdp = 'DRY'
     C                   eval      iacode = 'C1'
     C                   other
     C                   eval      iacode = 'C8'
     C                   endsl
     C                   eval      iamemo = 'Startup Inventory'
     *
     C                   Endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*    Get import date/time.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        EXPDTE            8 0
     CSR                 TIME                    EXPTIM            6 0
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZLTRT   Make item number left/right justified.
     C*
     CSR   ZZLTRT        BEGSR
     CSR                 SELECT
     CSR   DIRCTN        WHENEQ    '*LEFT   '
     CSR                 MOVE      *BLANKS       WKIT15
     CSR                 EVAL      WKIT15 = %TRIM(WKITM10)
     C*
     CSR   DIRCTN        WHENEQ    '*RIGHT  '
     CSR                 MOVE      *BLANKS       WKITM10
     CSR                 EVALR     WKITM10 = %TRIMR(WKIT15)
     C*
     CSR                 ENDSL
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update Pick Slot with Qty Difference
     C*
     CSR   ZZUPD         BEGSR
     C*
     CSR                 update    slrec3
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZWRT    Write out ITEMADJ Rcds with Qty Difference to send to Retalix.
     C*
     C     ZZWRT         BEGSR
     C*
     C                   write     iarec
     C*
     C                   ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
