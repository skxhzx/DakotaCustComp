500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  24 N. Washington Ave Suite 203
     *  Batavia, IL 60510
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH555   Batch Transaction Pick Label Printing
     *  03 September, 2012
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *
     *  Revisions
640aA*    09/03/12  JCJ  6.40 - Project 01086
     *      - Enh: Date Created
650aA*    02/11/12  RTR  6.50a
     *      - Enh: Increased transactions from 15 to 50
     *
700 A*    12/08/15  MLB  7.00
     *      - Enh: Revised pgm to add support for Zone Templates.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
XXXaA*    xx/xx/xx  xxx  xxxa
     *      - ENH: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flabel7    if   e           k disk
     Frtehed    if   e           K disk
     Fpltsum4   if   e           K disk
     Foptionz   if   e           k disk
     Fsktlbl    uf a e           k disk
     Fsktlbl32d if   e           k disk
700 AFtruckh    if   e           k disk
     Frtetrck   o  a e           k disk

     *----------------------------------------------------------------
     *  Pallet array
     *
650aDD**TranAry         s              7  0 dim(15)
650aAD TranAry         s              7  0 dim(50)

     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')

      *----------------------------------------------------------------
      *  *PICKLBL  -  Picking label options
      *----------------------------------------------------------------
      *
      * Fields
      *
      *    OPCLVL  -  Qty level for combined labels.
      *    OPCWRB  -  Print combined label warning before.
      *    OPCWRA  -  Print combined label warning after.
      *    OPUWRB  -  Print unit of measure warning before.
      *    OPUWRA  -  Print unit of measure warning after.
      *    OPTEXT  -  Text for last line of label.
      *    OPERR   -  Error label ratio.
      *    OPCWGT  -  Catch weight label ratio.
      *    OPLPGM  -  Picking label program.
      *    OPPDEV  -  Printer device.
      *    OPPFRM  -  Printer form.
      *
      * Data structure
      *
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobn2               265    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     D                 ds
     D Today                           d   Datfmt(*ISO) Inz
     D  TodayYear                     4    overlay(Today)
     D  TodayMonth                    2    overlay(Today:6)
     D  TodayDay                      2    overlay(Today:9)

     *----------------------------------------------------------------
     *  Work Variables
     *----------------------------------------------------------------

     D CurStamp        s               z
     D svdte1          s              8  0
     D svdte2          s              8  0
     D $pcwgt          s              7  2
     D $ptrn#          s              7  0
     D $plbl#          s              7  0
     D wtran           s              7  0
     D svtim1          s              6  0
     D svtim2          s              6  0
     D curtime         s              6  0
     D TManEmp#        s              5  0
     D $pqty           s              5  0
     D $whse           s              3  0
     D i               s              2  0
     D $pftruk         s             10
700 AD $ptmpl          s             10
     D $tpgm           s             10
     D svpgm1          s             10
     D svpgm2          s             10
     D $pfcmd          s              8
     D $pffmt          s              8
     D $cvcmd          s              8
     D @set            s              6
     D $pfrte          s              5
     D FirstPass       s              1
     D LabelType       s              1
     D $otype          s              1
     D ISO             s               d   Datfmt(*ISO) Inz

     *----------------------------------------------------------------
     * Constants
     *----------------------------------------------------------------
     D   Forever       C                   Const('1')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse Number.
     *      $PDEV   Printer device to use or *DEFAULT.
     *      $PFORM  Printer form to use or *DEFAULT.
     *
     *    Returned Parameters
     *      N/A
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $ptran1           7
     C                   parm                    $ptran2           7
     C                   parm                    $ptran3           7
     C                   parm                    $ptran4           7
     C                   parm                    $ptran5           7
     C                   parm                    $ptran6           7
     C                   parm                    $ptran7           7
     C                   parm                    $ptran8           7
     C                   parm                    $ptran9           7
     C                   parm                    $ptran10          7
     C                   parm                    $ptran11          7
     C                   parm                    $ptran12          7
     C                   parm                    $ptran13          7
     C                   parm                    $ptran14          7
     C                   parm                    $ptran15          7
650aAC                   parm                    $ptran16          7
650aAC                   parm                    $ptran17          7
650aAC                   parm                    $ptran18          7
650aAC                   parm                    $ptran19          7
650aAC                   parm                    $ptran20          7
650aAC                   parm                    $ptran21          7
650aAC                   parm                    $ptran22          7
650aAC                   parm                    $ptran23          7
650aAC                   parm                    $ptran24          7
650aAC                   parm                    $ptran25          7
650aAC                   parm                    $ptran26          7
650aAC                   parm                    $ptran27          7
650aAC                   parm                    $ptran28          7
650aAC                   parm                    $ptran29          7
650aAC                   parm                    $ptran30          7
650aAC                   parm                    $ptran31          7
650aAC                   parm                    $ptran32          7
650aAC                   parm                    $ptran33          7
650aAC                   parm                    $ptran34          7
650aAC                   parm                    $ptran35          7
650aAC                   parm                    $ptran36          7
650aAC                   parm                    $ptran37          7
650aAC                   parm                    $ptran38          7
650aAC                   parm                    $ptran39          7
650aAC                   parm                    $ptran40          7
650aAC                   parm                    $ptran41          7
650aAC                   parm                    $ptran42          7
650aAC                   parm                    $ptran43          7
650aAC                   parm                    $ptran44          7
650aAC                   parm                    $ptran45          7
650aAC                   parm                    $ptran46          7
650aAC                   parm                    $ptran47          7
650aAC                   parm                    $ptran48          7
650aAC                   parm                    $ptran49          7
650aAC                   parm                    $ptran50          7
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pwhse            3

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   exsr      DltSktLbl
     C                   exsr      FillSktLbl
     C                   eval      LabelType = 'O'
     C                   exsr      DoPrintPfmt1
     C                   eval      LabelType = 'M'
     C                   exsr      DoPrintPfmt1
     C                   exsr      PrintSetSum
     C                   exsr      DltSktLbl
     C                   exsr      closepfmt
     C                   eval      $tpgm = 'RH555'
     C                   exsr      zzend
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  FillSktLbl   Fill SktLBL file.
     *----------------------------------------------------------------

     C     FillSktLbl    BegSr

650aDC**                 for       i = 1 to 15
650aAC                   for       i = 1 to 50

     C                   if        TranAry(i) <> *zeros

     C                   time                    curstamp
     C     TranAry(i)    setll     label7
     C                   dou       %eof(label7)
     C     TranAry(i)    reade     label7
     C                   if        not %eof(label7)
     C                   eval      slwemp# = TManEmp#
     C                   eval      slwwhse = lbwhse
     C                   eval      slwwhdp = lbwhdp
     C                   eval      slwitem = lbitem
     C                   eval      slwaisl = lbaisl
     C                   eval      slwloc  = lbloc
     C                   eval      slwrlvl = lbrlvl
     C                   eval      slwhand = lbhand
     C                   eval      slwpseq = lbpseq
     C                   eval      slwstyp = lbstyp
     C                   eval      slwlvl2 = lblvl2
     C                   eval      slwrte  = lbrte
     C                   eval      slwstop = lbstop
     C                   eval      slwtype = lbtype
     C                   eval      slwlbl# = lblbl#
     C                   eval      slwtrn# = lbtrn#
     C                   eval      slwstamp = curstamp
     C                   write     slwrec
     C                   endif

     C                   enddo

     C                   endif

     C                   endfor

     C                   endsr

     *----------------------------------------------------------------
     *  DoPrintPfmt1   all PFMT once for each transaction sent.
     *----------------------------------------------------------------

     C     DoPrintPfmt1  begsr

     C     keyslw2       setll     sktlbl32d
     C                   dou       %eof(sktlbl32d)
     C     keyslw2       reade     sktlbl32d
     C                   if        not %eof(sktlbl32d)

      *  Get print options

     C                   exsr      getprintopt

      *  Get client Route number.

     C     Keyrh2        Chain     rtehed
     C                   if        %found(rtehed)
     C                   eval      $pfrte = rhrte
     C                   eval      $pftruk = rhtruk
     C                   else
     C                   eval      $pfrte = *blanks
     C                   eval      $pftruk = *blanks
     C                   endif

      *  Call label printing program.

      *    Define label set.

      *      It is assumed that the standard label set is in the format
      *      'PFMTZBRccc', where 'ccc' is the client id (i.e., PFMTZBRCBI).
      *      The standard label set would be ZBRccc.
      *      The belt printer lable set will be BLTccc.

     C                   eval      @set = 'BLT' + %subst(oplpgm:8:3)

     *  Print Zone Description label once per batch

     C                   if        firstpass = 'Y'
     C                   eval      firstpass = 'N'
     C                   exsr      PrtZonDscLbl
     C                   endif

      *  Get print options

     C                   exsr      getprintopt

      *    Call PFMT to print requested label(s)

     C                   call      'PFMTCL'
     C                   parm      'BFCPRINT  '  $prtuser         10
     C                   parm      '*NOPWD    '  $prtpwd          10
     C                   parm      '*PICK'       $pfcmd
     C                   parm                    @set
     C                   parm                    $pffmt
     C                   parm                    pswhse
     C                   parm                    psrtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $pftruk
     C                   parm                    $pfrte
     C                   parm                    opzdta
     C                   parm      lbtrn#        $ptrn#
     C                   parm      lblbl#        $plbl#
     C                   parm      lbqpck        $pqty
     C                   parm                    $pcwgt

     C                   EndIf

     C                   EndDo

     C     endprintpfmt1 endsr

     *----------------------------------------------------------------
     *  GetPrintOpt  Get print options.
     *----------------------------------------------------------------

     C     GetPrintOpt   BegSr

      *  Get pallet summary information.

     C     lbtrn#        chain     pltsum4
700 AC                   if        not %found(pltsum4)
700 AC                   eval      pswhse = 0
700 AC                   eval      pstruk = ' '
700 AC                   endif

700 A* Get Zone Template Code if Template type is T=Truck
700 A*
700 AC     keyth         chain     truckh
700 AC                   if        %found(truckh)
700 AC                             and thtype = 'T'
700 AC                   eval      kytruk =  thztmp
700 AC                   else
700 AC                   eval      kytruk =  pstruk
700 AC                   endif
700 A*
      *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz
     C                   endif

      *    Set optionz device to portable printer being used.

     C                   eval      oppdev = $pdev
     C                   eval      oppfrm = $pform

     C     endgetprtopt  Endsr

     *----------------------------------------------------------------
     *  PrtZonDscLbl Print Zone Description Label
     *----------------------------------------------------------------

     C     PrtZonDscLbl  BegSr

      *    Call PFMT to print requested label(s)

     C                   call      'PFMTCL'
     C                   parm      'BFCPRINT  '  $prtuser         10
     C                   parm      '*NOPWD    '  $prtpwd          10
     C                   parm      '*ZONDSC'     $pfcmd
     C                   parm                    @set
     C                   parm                    $pffmt
     C                   parm                    pswhse
     C                   parm                    psrtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $pftruk
     C                   parm                    $pfrte
     C                   parm                    opzdta
     C                   parm      lbtrn#        $ptrn#
     C                   parm                    $plbl#
     C                   parm      lbqpck        $pqty
     C                   parm                    $pcwgt

     C                   EndSr

     *----------------------------------------------------------------
     *  PrintSetSum  Fill SktLBL file.
     *----------------------------------------------------------------

     C     PrintSetSum   BegSr

650aAC**                 for       i = 1 to 15
650aDC                   for       i = 1 to 50

     C                   if        TranAry(i) <> *zeros

      *  Get pallet summary information.

     C     TranAry(i)    chain     pltsum4

      *  Get client Route number.

     C     Keyrh2        Chain     rtehed
     C                   if        %found(rtehed)
     C                   eval      $pfrte = rhrte
     C                   eval      $pftruk = rhtruk
     C                   else
     C                   eval      $pfrte = *blanks
     C                   eval      $pftruk = *blanks
     C                   endif

      *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz
     C                   endif

      *    Call PFMT to print requested label(s)

     C                   call      'PFMTCL'
     C                   parm      'BFCPRINT  '  $prtuser         10
     C                   parm      '*NOPWD    '  $prtpwd          10
     C                   parm      '*SETSUM'     $pfcmd
     C                   parm                    @set
     C                   parm                    $pffmt
     C                   parm                    pswhse
     C                   parm                    psrtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $pftruk
     C                   parm                    $pfrte
     C                   parm                    opzdta
     C                   parm      pstrn#        $ptrn#
     C                   parm                    $plbl#
     C                   parm                    $pqty
     C                   parm                    $pcwgt

     C                   endif

     C                   endfor

     C                   endsr

     *----------------------------------------------------------------
     *  DltSktLbl   Delete SktLBL file.
     *----------------------------------------------------------------

     C     DltSktLbl     BegSr

      * First, delete any existing records for employee.

     C     keyslw        setll     sktlbl
     C                   dow       forever = forever
     C     keyslw        reade     sktlbl
     C                   if        %eof
     C                   leave
     C                   endif
     C                   delete    slwrec
     C                   enddo
     C                   EndSr

     *----------------------------------------------------------------
     *  ClosePfmt    Send close command to PFMT
     *----------------------------------------------------------------

     C     ClosePfmt     BegSr

      *    Close PFMT request

     C                   call      'PFMTCL'
     C                   parm      'BFCPRINT  '  $prtuser         10
     C                   parm      '*NOPWD    '  $prtpwd          10
     C                   parm      '*CLOSE'      $pfcmd
     C                   parm                    @set
     C                   parm                    $pffmt
     C                   parm                    pswhse
     C                   parm                    psrtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    $pftruk
     C                   parm                    $pfrte
     C                   parm                    opzdta
     C                   parm                    $ptrn#
     C                   parm                    $plbl#
     C                   parm                    $pqty
     C                   parm                    $pcwgt

     C                   EndSr

     *----------------------------------------------------------------
     *  ZZSTRT  Start timer
     *----------------------------------------------------------------

     C     zzstrt        BegSr

     C     $otype        cabne     ' '           endzzs

     C                   eval      svpgm2 = $tpgm
     C                   move      today         svdte2
     C                   time                    svtim2

     C     endzzs        EndSr

     *----------------------------------------------------------------
     *  ZZEND   End timer
     *----------------------------------------------------------------

     C     zzend         begsr

     C     $otype        cabne     ' '           endzze

     C                   eval      rttwhs = $whse
     C                   eval      rttrid = rhrtid
     *
     C                   eval      rttpgm = svpgm2
     C                   eval      rttsdt = svdte2
     C                   eval      rttstm = svtim2
     *
     C                   eval      rttrdt = rttsdt
     C                   eval      rttedt = rttsdt
     C                   time                    rttetm
     *
     *      If start time is less than 5:00am
     *       Then subtract 1 from the day for report date.
     *
     C                   if        rttstm < 50000
     C                   subdur    1:*D          iso
     C                   move      iso           rttrdt
     C                   endif
     *
     C                   call      'CALCTIME'
     C                   parm      '*MINUTES'    $cvcmd
     C                   parm                    rttsdt
     C                   parm                    rttstm
     C                   parm                    rttedt
     C                   parm                    rttetm
     C                   parm      0             rttmin
     *
     C                   eval      rttjob = #job
     C                   eval      rttusr = #user
     C                   move      #jobn         rttjb#
     *
     C                   write     rttrec
     *
     C     endzze        endsr

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     C                   move      *year         TodayYear
     C                   move      *month        TodayMonth
     C                   move      *day          TodayDay

     C                   move      today         iso

     C                   move      $pwhse        $whse

     C                   eval      $tpgm = 'RH555'
     C                   exsr      zzstrt

     * Get client id.

     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10

     *  Define key for OPTIONZ file.

     C
     C     *like         define    opzcod        kycode
700 AC     *like         define    opztrk        kytruk
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
700 DC*                  kfld                    pstruk
700 MC                   kfld                    kytruk
     C                   kfld                    psszon
     C
      *  Define partial key for optionz file.
     C
     C     keyop2        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
     C                   kfld                    pstruk

     *  Define key for RTEHED file.

     C     Keyrh2        klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
700 A*
700 A*  Define key for TRUCKH file.
700 A*
700 AC     keyth         klist
700 AC                   kfld                    pswhse
700 AC                   kfld                    pstruk

     *  Define partial key for SKTLBL file.

     C     keyslw        klist
     C                   kfld                    TmanEmp#

     *  Define partial key for SKTLBL file.

     C     keyslw2       klist
     C                   kfld                    TmanEmp#
     C                   kfld                    LabelType

     C                   eval      wtran = %dec($ptran1:7:0)
     C                   eval      TranAry(1) = wtran

     C                   eval      wtran = %dec($ptran2:7:0)
     C                   eval      TranAry(2) = wtran

     C                   eval      wtran = %dec($ptran3:7:0)
     C                   eval      TranAry(3) = wtran

     C                   eval      wtran = %dec($ptran4:7:0)
     C                   eval      TranAry(4) = wtran

     C                   eval      wtran = %dec($ptran5:7:0)
     C                   eval      TranAry(5) = wtran

     C                   eval      wtran = %dec($ptran6:7:0)
     C                   eval      TranAry(6) = wtran

     C                   eval      wtran = %dec($ptran7:7:0)
     C                   eval      TranAry(7) = wtran

     C                   eval      wtran = %dec($ptran8:7:0)
     C                   eval      TranAry(8) = wtran

     C                   eval      wtran = %dec($ptran9:7:0)
     C                   eval      TranAry(9) = wtran

     C                   eval      wtran = %dec($ptran10:7:0)
     C                   eval      TranAry(10) = wtran

     C                   eval      wtran = %dec($ptran11:7:0)
     C                   eval      TranAry(11) = wtran

     C                   eval      wtran = %dec($ptran12:7:0)
     C                   eval      TranAry(12) = wtran

     C                   eval      wtran = %dec($ptran13:7:0)
     C                   eval      TranAry(13) = wtran

     C                   eval      wtran = %dec($ptran14:7:0)
     C                   eval      TranAry(14) = wtran

     C                   eval      wtran = %dec($ptran15:7:0)
     C                   eval      TranAry(15) = wtran

650aAC                   eval      wtran = %dec($ptran16:7:0)
650aAC                   eval      TranAry(16) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran17:7:0)
650aAC                   eval      TranAry(17) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran18:7:0)
650aAC                   eval      TranAry(18) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran19:7:0)
650aAC                   eval      TranAry(19) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran20:7:0)
650aAC                   eval      TranAry(20) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran21:7:0)
650aAC                   eval      TranAry(21) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran22:7:0)
650aAC                   eval      TranAry(22) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran23:7:0)
650aAC                   eval      TranAry(23) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran24:7:0)
650aAC                   eval      TranAry(24) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran25:7:0)
650aAC                   eval      TranAry(25) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran26:7:0)
650aAC                   eval      TranAry(26) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran27:7:0)
650aAC                   eval      TranAry(27) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran28:7:0)
650aAC                   eval      TranAry(28) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran29:7:0)
650aAC                   eval      TranAry(29) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran30:7:0)
650aAC                   eval      TranAry(30) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran31:7:0)
650aAC                   eval      TranAry(31) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran32:7:0)
650aAC                   eval      TranAry(32) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran33:7:0)
650aAC                   eval      TranAry(33) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran34:7:0)
650aAC                   eval      TranAry(34) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran35:7:0)
650aAC                   eval      TranAry(35) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran36:7:0)
650aAC                   eval      TranAry(36) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran37:7:0)
650aAC                   eval      TranAry(37) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran38:7:0)
650aAC                   eval      TranAry(38) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran39:7:0)
650aAC                   eval      TranAry(39) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran40:7:0)
650aAC                   eval      TranAry(40) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran41:7:0)
650aAC                   eval      TranAry(41) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran42:7:0)
650aAC                   eval      TranAry(42) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran43:7:0)
650aAC                   eval      TranAry(43) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran44:7:0)
650aAC                   eval      TranAry(44) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran45:7:0)
650aAC                   eval      TranAry(45) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran46:7:0)
650aAC                   eval      TranAry(46) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran47:7:0)
650aAC                   eval      TranAry(47) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran48:7:0)
650aAC                   eval      TranAry(48) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran49:7:0)
650aAC                   eval      TranAry(49) = wtran
650aA
650aAC                   eval      wtran = %dec($ptran50:7:0)
650aAC                   eval      TranAry(50) = wtran
650aA
     C                   eval      TManEmp# = %dec(#jobn2:5:0)
     C                   eval      TManEmp# = TManEmp# * -1

     C                   eval      FirstPass = 'Y'

     C                   endsr
     *---------------------------------------------------------------------****
     *
     *  COMPILE TIME TABLES
     *
