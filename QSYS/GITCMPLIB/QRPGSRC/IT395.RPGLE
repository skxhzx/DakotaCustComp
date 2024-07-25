     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   249 N. Washington Ave Suite 203
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IT395    Glazier Expiration Report
     F*  19 October 2011
     F*  Ginger Andrews
     F*
      *----------------------------------------------------------------
     *  Revisions:
620 A*    10/19/11  GJA  6.20
     *      - Created for Glazier Foods.
     *
650 A*    03/20/15  MLB  6.50
     *      - Enh: Revised program to be compatibile with v6.50
     *      - Revised pgm to load value from LNENTDATE instead of
     *        LNVALUE.
     *      - Revised pgm to load value from LNLOT instead of
     *        LNVALUE.
     *      - Revised pgm to load value from LNEXPDATE instead of
     *        LNVALUE.
     *      - Revised LCKEY to only use LAWHSE, LALCNS for rcd access.
     *
     F*----------------------------------------------------------------
     F* Revissions:
     F*
620 AF*  79        - General purpose EOF indicator.
     F*
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*  79        - General purpose EOF indicator.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     Flicactive2IF   E           K DISK
     Fitemmsc   IF   E           K DISK
     Fpiritem   IF   E           K DISK
     Fwarehs    if   e           k disk
     Flicinfo   if   e           k disk
     Fslot2     if   e           k disk
     Fslot3     if   e           k disk    rename(slrec:slrec3)
     Fit395pr   o    e             printer oflind(*in90)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
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
417rA*------------------------------------------------------------------
417rA* CLCDUR2 parameters
417rA*------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0

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
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     * Variables
GFCaAD buyer           s              3  0
GFCaAD expdate         s               d
GFCaAD seldate         s               d
     D first           s              1
GFCaAD mfgdate         s               d
GFCaAD rdate           s              8  0
GFCaAD entdat          s             20  0
GFCaAD expdat          s             20  0
GFCaAD chkexp          s              8  0
GFCaAD curexp          s              8  0
GFCaAD w1sell8         s              8  0
GFCaAD mfgdiff         s              3  0
     D today           s              8  0
     D todate          s               d
     D tosell          s               d
     D $plen           s              3  0
     D $pstr           s             60
     D kystat          s              2
     D kypick          s              1
     D kytype          s              1
     D kycode          s              8
     D nexpd           s              8  0
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PWHS   Warehouse to process.
     C*      $PEXP   Prior expired product
     C*      $NEXP   Expiration date
     C*      $TODAY  Processing date
     C*      $BUYER  Buyer selection
     C*      $PICK   Pick slot selection
     C*      $WHDP   Department selection
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $PEXP             1
     C                   PARM                    $NEXP             8
     C                   PARM                    $TODAY            8
     C                   PARM                    $buyer            3
     C                   PARM                    $pick             1
     C                   PARM                    $whdp             5
     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   read(n)   licactive2
     C                   if        %eof(licactive2)
     *  we are finished so get out
     C                   eval      *INLR = *on
     C                   return
     C                   else
     *  Report Heading
     C                   if        *in90  or
     C                             first = '1'
     C                   exsr      zrhead
     C                   eval      first = *off
     C                   endif
     *  Check for department selection
     C                   if        lawhdp = $whdp or $whdp = '*ALL '
     C     itkey         chain(n)  piritem
     C                   if        %found(piritem)
     C     itkey         chain(n)  itemmsc
     C                   if        %found(piritem)
     *  Check for buyer selection
     C                   if        buyer = *zeros or buyer = imbnbr
     C                   exsr      zzlicinfo
     C                   eval      rdate = *zeros
     *  Get Rotation date
     C                   select
     C                   when      itflgd = 'N'
     C                   eval      rdate =  laentd
     C                   eval      expdate = %date(rdate) + %days(imdday) +
     C                                                      %days(imuday)
     C                   eval      seldate = expdate - %days(imuday)
     C                   when      itflgd = 'Y' and immflg = 'N'
     C                   eval      kycode = '*DATEIN '
     C     lckey         chain     licinfo
     C                   if        %found(licinfo)
650 DC*                  movel     lnvalue       rdate
650 MC                   eval      rdate = lnentdate
     C                   else
     C                   eval      rdate =  laexpd
     C                   endif
     C                   if        rdate <> 0
     C                   eval      expdate = %date(rdate)
     C                   eval      seldate = %date(rdate) - %days(imuday)
     C                   endif
     C                   when      itflgd = 'Y' and immflg = 'Y'
     C                   eval      kycode = '*DATEIN '
     C     lckey         chain     licinfo
     C                   if        %found(licinfo)
650 DC*                  movel     lnvalue       rdate
650 MC                   eval      rdate = lnentdate
     C                   else
     C                   eval      rdate =  laexpd
     C                   endif
     C                   eval      expdate = %date(rdate) + %days(immday)
     C                   eval      seldate = %date(rdate) + %days(immday)
     C                                                     - %days(imuday)
     C                   endsl
     C                   eval      expdys  = *zeros
     C                   eval      seldys  = *zeros
     C                   eval      w1selld = *zeros
     *  Get quantity
     C                   exsr      zzqty
     *  Get sellby days and expiration days
     C                   if        rdate <> 0
     C                   exsr      zzdte
     C                   endif
     *  Check if sell by date is within range
     C                   if        w1sell8 <= nexpd and $pexp = 'Y' or
     C                             w1sell8 <= nexpd and $pexp = 'N' and
     C                             w1sell8 > today
     C                   eval      sldisp = *blanks
     *  if overflow get pick slot, set slot type
     C                   eval      slpick = *blank
     C                   eval      picktyp = *blank
     C     slkey         chain     slot2
     C                   if        %found(slot2)
     C                   if        slpick <> 'Y'
     C     slkey3        chain     slot3
     C                   if        %found(slot3)
     C                   eval      picktyp = 'RSV'
     C                   endif
     C                   else
     C                   eval      picktyp = 'PCK'
     C                   eval      sldisp = *blanks
     C                   endif
     C                   endif
     *  Get lot code
     C                   if        $pick = 'B' or
     C                             $pick = 'P' and slpick='Y' or
     C                             $pick = 'O' and slpick = 'N'
     *  Get lot code
     C                   if        curexp <= chkexp
     C                   write     detail1
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C*
     C*----------------------------------------------------------------
     C*
     C*          Subroutines in Alphabetical Order
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine
     C*
     C     *INZSR        BEGSR
     C*
     C     itkey         klist
     C                   kfld                    lawhse
     C                   kfld                    laitem
     C*
     C     slkey         klist
     C                   kfld                    lawhse
     C                   kfld                    lawhdp
     C                   kfld                    ladisp
     C*
     C     slkey3        klist
     C                   kfld                    lawhse
     C                   kfld                    laitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C*
     C     lckey         klist
     C                   kfld                    lawhse
650 DC*                  kfld                    kytype
     C                   kfld                    lalcns
650 DC*                  kfld                    kycode
     C*
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   eval      todate  = %date(today)
     C*
     C                   MOVE      #PROG         $LPRG
     C*
     C                   MOVE      $nexp         chkexp
     C*
     C                   time                    time
     C                   eval      first = *on
     C                   eval      kystat = 'A'
     C                   eval      kypick = 'Y'
     C                   move      $buyer        buyer
     C                   move      $nexp         nexpd
     C                   ENDSR
     *----------------------------------------------------------------
     *  ZRHEAD  Print header line
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     lawhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   write     head1
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZQTY   Convert qty to string
     *
     C*
     C     ZZQTY         BEGSR
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = laqty1
     C                   eval      $pqty2 = laqty2
     C                   eval      $pqty3 = laqty3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm
     *
     C                   eval      qtavl = $pqstr
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZDTE   Create date information
     *
     C     zzdte         begsr
     *
     *    Format date for rotation
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rdate         $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
     *
     *    Format date for expiration
     *
     C     expdate       subdur    todate        expdys:*d
     C     seldate       subdur    todate        seldys:*d
     *
     C                   eval      $cvd8i = %char(seldate:*iso0)
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1selld
     C                   move      $cvd8i        curexp
     *
     C                   eval      $cvd8i = %char(expdate:*iso0)
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        w1rdta
     C                   endsr
     *----------------------------------------------------------------
     *  ZZLICINFO  Get LICINFO information
     *
     C     zzlicinfo     begsr
     *
     *    Capture LOT info
     *
     C                   eval      kytype = 'P'
     C                   eval      kycode = '*LOT    '
     C     lckey         chain     licinfo
     C                   if        %found(licinfo)
650 DC*                  eval      w1lot = lnvalue
650 MC                   eval      w1lot = lnlot
     C                   else
     C                   eval      w1lot = *blanks
     C                   endif
     *
     C                   eval      kycode = '*DATETYP'
     C     lckey         chain     licinfo
     C                   if        %found(licinfo)
     C                   select
     C                   when      itflgd = 'N' and laentd = 0
     C                   eval      entdat = %dec(lnaddts)
     C                   movel     entdat        laentd
     C                   when      itflgd = 'Y' and laentd = 0
     C                   eval      entdat = %dec(lnaddts)
     C                   movel     entdat        laentd
     C                   endsl
     *
     C                   if        itflgd = 'Y' and laexpd = 0
     C                   eval      kycode = '*EXPDTE '
     C     lckey         chain     licinfo
     C                   if        %found(licinfo)
650 DC*                  movel     lnvalue       laexpd
650 MC                   eval      laexpd = lnexpdate
     C                   else
     C                   eval      expdate = %date(laentd) + %days(imdday) +
     C                                                      %days(imuday)
     C                   eval      laexpd = %dec(expdate)
     C                   endif
     C                   endif
     C                   else
     C                   if        laentd = 0
     C                   eval      entdat = %dec(lachgts)
     C
     C                   movel     entdat        laentd
     C                   endif
     C                   if        laexpd = 0 and laentd <> 0 and itflgd = 'Y'
     C                   eval      expdate = %date(laentd) + %days(imdday) +
     C                                                      %days(imuday)
     C                   eval      laexpd = %dec(expdate)
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  Compile Time Tables
     *
