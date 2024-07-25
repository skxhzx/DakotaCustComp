     H option(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU355     Runner Pick Labels on Belt Printer - Print
     *  01 December 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    12/01/05  MLB  5.00
     *      - Created.
     *      - Client custom logic included.
     *
500aA*    12/27/05  JCJ  5.00a
     *      - Enh: added new parms $pdev & $pform
     *      - Enh: added new command parms *PRTBELT, *RPRTBLT
     *
640aA*    09/07/11  JCJ  6.40a
     *      - Enh:  Added client code.
     *
640bA*    09/28/11  JCJ  6.40b
     *      - Enh:  Added get client code.
     *
640cA*    01/07/13  RBD  6.40c
     *      - Fix: Added *SHORTM command to send to PFMT if rutype=U,
     *        otherwise still send *SHORT. If rutype=U that means
     *        multiple runners have picked shorts for this item,
     *        otherwise there will only be 1 runner record.  In PFMT
     *        we need to know that so we can determine what the next
     *        Trax#s on the runner pick labels should be. Before this
     *        fix to RU310, RU355, and PFMT, we were reprinting Trax#s
     *        on runner pick labels that had already been used because
     *        we were starting at the beginning, rather than where we
     *        left off.
     *
     *----------------------------------------------------------------
     *  Cityline custom revisions:
     *
CTLaA*    09/28/11  JCJ  CTLa
     *      - Enh: revised to use formated label for Zebra Z4M-300dpi
CTLbA*    09/25/13  JCJ  CTLb
     *      - Enh: revised to use correct set label name.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fru355a    ip   e           k disk
     Fpirtran   if   e           k disk
     Foptionz   if   e           k disk
     Fpltsum4   if   e           k disk
     Frtehed    if   e           k disk
640aAFtruckh    if   e           k disk
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D pcs             s              5  0 dim(3)
     *----------------------------------------------------------------
     *  Customer id
     *
CtlaA /copy qcopysrc,id#citylin
     *
640baD                 ds
640bAD  client                 1     10
640bAD  cliloc                11     20
640bAD @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#EQUIPT
     D saveVer#        s                   like($etver#)

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
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
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     *----------------------------------------------------------------
     * Working variables
500aAD $pdev           s             10
500aAD $pform          s             10
     D error           s              1    inz('0')
640aAD $ptmpl          s             10
     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------
      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PRINT   - Print Runner Pick Labels
     *              *REPRINT - Re-Print Runner Pick Labels
500aA*              *PRTBELT - Print
500aA*              *RPRTBLT - Re-Print
     *      $PWHSE  Warehouse number
     *      $PTRN#  Transaction number assigned to runner task
     *      $PDEV   Printer device
     *      $PFORM  Form type
     *
     *    Returned Parameters
     *      $PRTN   *NOBELT  - No Belt Printer assigned to user.
     *                         No Runner Flag labels printed.
     *
     *----------------------------------------------------------------
     *
     C     *ENTRY        PLIST
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptrn#            7 0
500aAC                   parm                    $pdev
500aAC                   parm                    $pform
     C                   parm                    $prtn             8
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Get Customer Route number.
     C     rhkey         chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      rhrte  = ' '
     C                   eval      rhtruk = ' '
     C                   endif
     *
     *  Retrieve Pick Zone info from Original Transaction.
     C                   exsr      getprintopt
     *
     *  Print Runner labels on Belt Printer.
     C                   exsr      printlabels
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
640bA*
640bA* Get client id.
640bA*
640bAC                   call      @getcl
640bAC                   parm                    client
640bAC                   parm                    cliloc
     *
640bD ***                call      'GETCLIENT'
640bD ***                parm      *blanks       Client           10
     C
     *  Define key for OPTIONZ file.
     C
     C     *LIKE         define    OPZCOD        KYCODE
     C     KEYOPZ        KLIST
     C                   KFLD                    KYCODE
     C                   KFLD                    PSWHSE
640aD *                  KFLD                    PSTRUK
640aMC                   kfld                    $ptmpl
     C                   KFLD                    PSSZON
     C
     *  Define partial key for OPTIONZ file.
     C
     C     KEYOP2        KLIST
     C                   KFLD                    KYCODE
     C                   KFLD                    PSWHSE
640aD *                  KFLD                    PSTRUK
640aMC                   kfld                    $ptmpl
     *
     *   Full RTEHED key
     C     rhkey         klist
     C                   kfld                    ruwhse
     C                   kfld                    lbrte
640aA*
640aA*  Define key for TRUCKH file.
640aA*
640aAC     trkey         klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    pstruk
     *
     C     $ptrn#        chain     pirtran
     C                   if        not %found(pirtran)
     C                   eval      ptemp# = 0
     C                   endif
     *
     *   Retrieve belt printer checked out to user.
     *
500aAC                   if        $pcmd = '*PRTBELT' or
500aAC                             $pcmd = '*RPRTBLT'
     C                   exsr      clr$equipt
     C                   eval      $etwhseu = *on
     C                   eval      $etwhse  = $pwhse
     C                   eval      $etemp#u = *on
     C                   eval      $etemp#  = ptemp#
     C                   eval      $etcodeu = *on
     C                   eval      $etcode  = 'BLTPRT'

     C                   eval      $dricommand = '*EQUIPT'
     C                   eval      $drisubcmd  = '%GETCHKOUT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   eval      $etcode = '*JOB      '
     C                   eval      $prtn   = '*NOBELT '
     C                   eval      *inlr   = *on
     C                   endif
     *
500aAC                   endif
500aA*
     C                   endsr
     *
     *---------------------------------------------------------------
     *
     *  GetPrintOpt  Get print options.
     *
     C     GetPrintOpt   BegSr

     *  Get pallet summary information.

     C     ruotrn        chain     pltsum4
     C                   if        not %found(pltsum4)
     C                   GoTo      endgetprtopt
     C                   endif
640aA*
640aA* Get Zone Template Code if Template type is T=Truck
640aA*
640aAC     trkey         chain     truckh
640aAC                   if        %found(truckh) and thtype = 'T'
640aAC                   eval      $ptmpl =  thztmp
640aAC                   else
640aAC                   eval      $ptmpl =  pstruk
640aAC                   endif

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C     keyop2        setll     optionz
     C     keyop2        reade     optionz
     C                   if        %eof(optionz)
     C                   GoTo      endgetprtopt
     C                   endif
     C                   endif
     *
     *    Set OPTIONZ device to portable printer being used.
     *
500aAC                   select
500aAC                   When      $pcmd = '*PRTBELT' or
500aAC                             $pcmd = '*RPRTBLT'
     C                   eval      oppdev = $etcode
     C                   eval      oppfrm = '*STD'
500aAC                   other
500aAC                   eval      oppdev = $pdev
500aAC                   eval      oppfrm = $pform
500aAC                   endsl

     C     endgetprtopt  Endsr
     *
     *---------------------------------------------------------------
     *
     *  PrintLabels   Print Runner Flag labels
     *
     C     PrintLabels   BegSr
     *
     *     Define label set.
     *
     *      It is assumed that the standard label set is in the format
     *      'PFMTZBRccc', where 'ccc' is the client id (i.e., PFMTZBRCBI).
     *      The standard label set would be ZBRccc.
     *      The belt printer lable set will be BLTccc.

     C                   select
500aAC                   When      $pcmd = '*PRTBELT' or
500aAC                             $pcmd = '*RPRTBLT'
     C                   eval      @set = 'BLT' + %subst(oplpgm:8:3)
CTLaAC                   when      client = Cityline
CTLbMC                   eval      @set = 'ZBRCT2'
CTLbDC**                 eval      @set = 'ZBRCT3'
500aAC                   other
500aAC                   eval      @set = 'ZBR' + %subst(oplpgm:8:3)
500aAC                   endsl

     C*     Call PFMT to print requested label(s)

640cAC                   if        rutype = 'U'
640cAC                   eval      $pfcmd = '*SHORTM '
640cAC                   else
640cAC                   eval      $pfcmd = '*SHORT  '
640cAC                   endif

     C                   call      'PFMT'
640cDC**                 parm      '*SHORT  '    $pfcmd            8
640cMC                   parm                    $pfcmd            8
     C                   parm                    @set              6
     C                   parm                    $pffmt            8
     C                   parm                    pswhse
     C                   parm                    psrtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm      rhtruk        $pftruk          10
     C                   parm      rhrte         $pfrte            5
     C                   parm                    opzdta
     C                   parm      ruotrn        $ptrn#            7 0
     C                   parm      rulbl#        $plbl#            7 0
     C                   parm      ruqyso        $pqty             5 0
     C                   parm      0.00          $pcwgt            7 2
     C
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$equipt  Clear $equipt data structure fields
     *
     C     clr$equipt    begsr
     C                   eval      savever# = $etver#
     C                   clear                   $equipt
     C                   eval      $etver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*EQUIPT'
     C                   eval      $dridata = $equipt
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*EQUIPT'
     C                   eval      $equipt = $dridata
     C                   endsl

     C     enddricop     endsr
     C
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
