     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT736SGC     FTP Export Item Hits/Avg Qty Picked SGC
     *  08 December 2016
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
SGC A*   12/08/16  MLB  SGC
     *     - Created.
SGCaA*   12/14/16  MLB  SGCa
     *     - Enh: Revised pgm load item cube. Compute total hits for
     *       cases and eaches separately. Compute total qty picked
     *       for cases and eaches separately. Load item designation
     *       into QEFLD1.
     *     - Enh: Revised pgm process velocity info for 5 week period
     *       of October 30 thru December 3rd.
     *       Updated velocity period to 5 weeks from 7 months.
     *     - Added file LABEL91 to pgm.
     *     - Added file SLOT2 to pgm.
SGCbA*   03/17/16  MLB  SGCb
     *     - Enh: Revised pgm to set velocity info for 5 week period
     *       of February 17 thru March 17. Per Josiah E. email.
SGCcA*   05/31/16  MLB  SGCc
     *     - Enh: Revised pgm to set velocity info for 5 week period
     *       of April 23 thru May 31. Per Josiah E. email.
     *
     *----------------------------------------------------------------
     *  Notes
     *
SGC A*     - This pgm has been created to extract item velocity, hits on
     *       pick slot for export to OptiSlot for new DRY whse expansion.
     *       This pgm will stay with SGC.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
CSPbA*  74        NRF on chain to VSLOT1
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
     Fpiritem1  if   e           k disk
     F                                     rename(itrec:itrec1)
IFC  Fpiritem3  if   e           k disk
IFC  F                                     rename(itrec:itrec3) prefix(i3_)
     Fdlyhits2  if   e           k disk
SGC AFitemdsc   if   e           k disk
     Fitemqty   if   e           k disk
     Fitemlnk   if   e           k disk
CCP AFkitcomp   if   e           k disk    usropn
SGCaAFlabel91   if   e           k disk
640aAFlicactive5if   e           k disk
SGCaAFslot2     if   e           k disk    rename(slrec : slrec2)
     Fslot3     if   e           k disk
CSPbAFvslot1    if   e           k disk
416 AFitemdef   if   e           k disk
416 AFslotdef   if   e           k disk
CWDaAFslotdgt   if   e           k disk    usropn
CWDaAFslotdgta  if   e           k disk    usropn
CCP D*EXPFQTY O   E           K        DISK                      A
CCP MFexpfitmsgcuf a e           k disk
640bAFexpflcns  uf a e           k disk
640dAFwarehs    if   e           k disk
640dAFit736pr   o    e             printer oflind(*in90)
640dAF                                     usropn
640aA
640aA*----------------------------------------------------------------
640aA*  DRI parameters
640aA*----------------------------------------------------------------
640aA
640aA /COPY *libl/qcopysrc,C#DRIPARMS
640aA
640aA*----------------------------------------------------------------
640aA*  Data Formats
640aA*----------------------------------------------------------------
640aA
640aA /COPY *libl/qcopysrc,C#ITEM
640aA /COPY *libl/qcopysrc,C#SLOT
640aA /COPY *libl/qcopysrc,C#LICENSE
640aA /COPY *libl/qcopysrc,C#LICINFO
640aA
500 A*----------------------------------------------------------------
500 A*  Client id's for custom mods.
500 A*----------------------------------------------------------------
500 AD/COPY QCOPYSRC,ID#DONSONS
BIR A /COPY QCOPYSRC,ID#BIRITE
ALN AD/COPY QCOPYSRC,ID#ALLEN
SVLaA /COPY QCOPYSRC,ID#SAVAL
CCP A /COPY QCOPYSRC,ID#CAPITOL
CSP A /COPY QCOPYSRC,ID#COASTAL
EI AA /COPY QCOPYSRC,ID#EI
GLP A /COPY QCOPYSRC,ID#GLP
CWD A /COPY QCOPYSRC,ID#CASHWA
GFS A /COPY QCOPYSRC,ID#GFS
JOR A /COPY QCOPYSRC,ID#JORDANO
AFS A /COPY QCOPYSRC,ID#ANDREWS
SGC A /COPY QCOPYSRC,ID#SGC
500 AD                 ds
500 AD  client                 1     10
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @itmfl          c                   const('GETITEMFLD')
DON A*----------------------------------------------------------------
DON A*  Working variables
DON A*
640aAD chk4err         s               n
640aAD error           s               n
640aAD zmsflag         s               n
640aAD savever#        s                   like($slver#)
640dAD SltQty          s              7  0 inz
640dAD LicQty          s              7  0 inz
640eAD nbrlicense      s              7  0 inz
GLPdAD repackalias     s              1    inz('0')
640eAD tryonce         s              1    inz('0')
640dAD wkqty           s                   like(slstk1)
DON AD                 ds
DON AD  aisle                  1      1
DON AD  loc                    2      3
DON AD  lvlhnd                 4      5
DON AD  donslt                 1      5
CCP AD                 ds
CCP AD  extqty                 1      7  0
CCP AD  whlcas                 8     14  0

DON A*----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
640 A*----------------------------------------------------------------
640 A*  Working variables
640 A*
640 AD $pwhse          s              3  0
640 AD forevr          s              1
640 AD kyitem          s                   like(slitem)
640 AD kypick          s                   like(slpick)
640 AD kystat          s                   like(slstat)
640 AD opnkit          s              1
650aAD multicount      s              4  0
640 AD scount          s              1  0
640 AD today           s              8  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #pgm             *proc
     D  #prog            *proc
     D  #job                 244    253
     D  #jobn                244    253
     D  #user                254    263
     D  #curruser            254    263
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE   Warehouse
     *      $WHDP   Warehouse department or *ALL
     *      $SECTN  Section type (F,P,B)
     *      $PINCL  Include Contract items (Y,N)
     *      $PRFLG  Reduce Base item qty by corresponding Contract
     *              item qtys (Y,N)
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     C                   parm                    $pincl            1
     C                   parm                    $prflg            1
640dDC*                  move      $pwhs         $pwhse
SGC AC                   move      'N'           $pincl
SGC AC                   move      'N'           $prflg
     *----------------------------------------------------------------
     *  Main line
     *
     *  Set beginning limits on appropriate file.
     *
     C                   if        $pwhdp = '*ALL'
     C     keyitw        setll     piritem
     C                   else
     C     keyitd        setll     piritem1
     C                   endif
     *
     *  Loop through item records.
     *
     C                   dou       forevr <> forevr
     C                   if        $pwhdp = '*ALL'
     C     keyitw        reade     piritem                                77
     C                   else
     C     keyitd        reade     piritem1                               77
     C                   endif
     *
     *    Get out if EOF or Department doesn't match.
     *
     C                   if        *in77  or
     C                             $pwhdp <> '*ALL'  and
     C                             itwhdp <> $pwhdp
     C                   leave
     C                   endif
     *
     *    Accept or Reject based on section type.
     *
     C                   if        $pstyp = 'F'  and
     C                             itstyp <> 'F'  or
     C                             $pstyp = 'P'  and
     C                             itstyp <> 'P'
     C                   iter
     C                   endif
     *
     *    Accept or Reject based on item type.
     *
     C                   if        ittype = 'A'  and
GLPcMC                             (client <> coastl and
GLPcAC                              client <> greenleaf)  or
CSPcA*
     C                             ittype = 'C'  and
     C                             $pincl <> 'Y'
     C                   iter
     C                   endif
SGC A*
SGC A*    Retrieve extended item description.
SGC A*
     C     keyix         chain     itemdsc
     C                   if        not %found(itemdsc)
     C                   clear                   ixdsc1
     C                   clear                   ixdsc2
     C                   endif
     *
     *    Record accepted for Export.
     *
     C                   clear                   qerec
     C                   eval      qedate = %subst(expdate:5:2)
     C                                      + '/'
     C                                      + %subst(expdate:7:2)
     C                                      + '/'
     C                                      + %subst(expdate:1:4)
     C                   eval      qewhse = itwhse
     C                   eval      qeitem = ititem
     C                   eval      qewhdp = itwhdp
     C                   if        ixdsc1 = ' '
     C                   eval      qedesc = itdesc
     C                   else
     C                   eval      qedesc = ixdsc1
     C                   endif
     C                   eval      qepdsc = itpdsc
SGCaAC                   eval      qecube = itcube
     C                   eval      qeuwdt = ituwdt
     C                   eval      qeulen = itulen
     C                   eval      qeuhgt = ituhgt
     C                   if        itflg1 = 'Y'
     C                   eval      qeslun = 'case:each'
     C                   else
     C                   eval      qeslun = 'case'
     C                   endif
     C                   eval      qepkun = qeslun
SGCaDC*                  eval      qevlpd = '7 months'
SGCaMC                   eval      qevlpd = '5 weeks '
     C                   eval      qeswgt = itswgt
     C                   if            itflg1 = 'Y'
     C                             and itumq2 > 0
     C                   eval (h)  qeewgt = itswgt / itumq2
     C                   endif
     C                   eval      qeincs = itumq2
     C                   eval      qecsor = 'WxLxH:LxWxH'
     C                   eval      qemnpe = 1
SGCaAC                   eval      qefil1 = %replace(itdesg : qefil1:1:5)
     *
     *    Get corresponding base item.
     *
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   if        ittype <> ' '
650aAC                              and ittype <> 'R'
     C     keyil         chain     itemlnk                            78
     C                   if        *in78
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   endif
     C                   endif
     *
     *  Get pick slot for item (max of 1)
     *
     C                   exsr      getpck
     *
     *  Get item hits / total qty picked.
     *
     C                   exsr      gethits
     *
     *  Add export record
     *
     C                   write     qerec                                79
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
500 A*
500 A*  Get client id
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client
500 A*
     *
     *  Define key for PIRITEM file.
     *
     C     keyitw        klist
     C                   kfld                    $pwhse
     *
     *  Define key for PIRITEM1 file.
     *
     C     keyitd        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define key for DLYHITS2 file.
     *
     C     *like         define    htbegdte      kybegdte
     C     keyht2        klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     C                   kfld                    kybegdte
     C     keyht         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     *
     *  Define key for ITEMDSC file.
     *
     C     keyix         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
IFC A*
IFC A*  Define key for PIRITEM3 file.
IFC A*
IFC AC     keyit3        klist
IFC AC                   kfld                    kyitem
IFC AC                   kfld                    itwhse
GLPdA*
GLPdAC*    keyit3glp     klist
GLPdAC*                  kfld                    qebitm
GLPdAC*                  kfld                    $pwhse
     *
     *  Define key for ITEMQTY file.
     *
     C     keyiq         klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     *
     *  Define key for ITEMLNK file.
     *
     C     keyil         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
IFC AC     keyil3        klist
IFC AC                   kfld                    itwhse
IFC AC                   kfld                    kyitem
CCP A*
CCP A*  Define key for EXPFQTY file.
CCP A*
CCP AC     kyqeb         klist
CCP AC                   kfld                    $pwhse
640bAC     keyla5        klist
640bAC                   kfld                    slwhse
640bAC                   kfld                    slwhdp
640bAC                   kfld                    sldisp
640bAC                   kfld                    slitem
CCP A*
CCP A*  Define key for KITCOMP file.
CCP A*
CCP AC     keykc         klist
CCP AC                   kfld                    $pwhse
CCP AC                   kfld                    ititem
SGCaA*
SGCaA*  Define full key for SLOT2 file.
SGCaA*
SGCaAC     keysl2        klist
SGCaAC                   kfld                    itwhse
SGCaAC                   kfld                    lbwhdp
SGCaAC                   kfld                    lbdisp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
640bAC     keysl3p       klist
640bAC                   kfld                    itwhse
640bAC                   kfld                    kyitem
CSPbA*
CSPbA*  Define full key for VSLOT1 file.
CSPbA*
CSPbAC     keyvs1        klist
CSPbAC                   kfld                    itwhse
CSPbAC                   kfld                    slwhdp
CSPbAC                   kfld                    sldisp
416 A*
416 A*  Define key for SLOTDEF file.
416 A*
416 AC     keysd         klist
416 AC                   kfld                    slwhse
416 AC                   kfld                    slsdef
CWDaA*
CWDaA*  Define key for SLOTDGT/SLOTDGTA files.
CWDaA*
CWDaAC     keyscd        klist
CWDaAC                   kfld                    slwhse
CWDaAC                   kfld                    slwhdp
CWDaAC                   kfld                    sldisp
416 A*
416 A*  Define key for ITEMDEF file.
416 A*
416 AC     keyid         klist
416 AC                   kfld                    slwhse
416 AC                   kfld                    slitem
416 AC                   kfld                    slsdef
640dA*
640dA*   Get warehouse description.
640dA*
640daC                   move      $pwhs         $pwhse
640dAC     $pwhse        chain     warehs
640dAC                   if        not %found(warehs)
640dAC                   eval      whdesc = ' '
640dAC                   endif
640dAC                   eval      $pstr = %editc($pwhse:'X')
640dAC                             + ' - '
640daC                             + whdesc
640dAC                   eval      $plen = 60
640dA*
640dA*   Center warehouse description.
640dA*
640dAC                   call      'CENTER'
640dAC                   parm                    $pstr            60
640dAC                   parm                    $plen             3 0
640dAC                   eval      hedln2 = $pstr
640dA*
640dA*  Retrieve today's date.
640dA*
640dAc                   eval      $cvcmd = '*CURMDY '
640dAc                   call      @cvtdt
640dAc                   parm                    $cvtdt
640dAc                   eval      rdate = $cvd6o
640dAC                   time                    rtime
640dA*
640dA*  Retrieve today's date in YYYYMMDD format for export file.
640dA*
SGC Ac                   eval      $cvcmd = '*CURCMD '
SGC Ac                   call      @cvtdt
SGC Ac                   parm                    $cvtdt
SGC Ac                   move      $cvd8o        expdate           8
640aA*
640aA*   Get default values for the user.
640aA*
640aAC                   call      'GETUSER'
640aAC                   parm                    #curruser
640aAC                   parm      0             #whse             3 0
640aAC                   parm      0             #emp#             5 0
640aAC                   parm                    #fnam            15
640aAC                   parm                    #init             1
640aAC                   parm                    #lnam            20
640aAC                   parm                    #whdp             5
640aAC                   parm                    #styp             1
640aAC                   parm                    #shft             6
640aAC                   parm                    #crew             6
640aAC                   parm      0             #nhrs             3 1
640aAC                   parm                    #rtn              8
CWDaA*
CWDaAC                   if        client = Cashwa
CWDaA*
CWDaAC                   if        not %open(slotdgt)
CWDaAC                   open      slotdgt
CWDaAC                   endif
CWDaA*
CWDaAC                   if        not %open(slotdgta)
CWDaAC                   open      slotdgta
CWDaAC                   endif
CWDaA*
CWDaAC                   endif
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
CCP A*
CCP AC                   eval      opnkit = *off
CCP AC                   if        client = capcty
GLPdAC                             or client = Greenleaf
CCP A*
CCP AC                   if        opnkit = '0'
CCP AC                   open      kitcomp
CCP AC                   eval      opnkit = *on
CCP AC                   endif
CCP A*
CCP AC                   endif
CCP A*
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPCK  Get pick slots for item (max of 3)
     *
     C     getpck        begsr
     C                   eval      scount = 0
     *
     *  If Contract or SSB item
     *   Then use Base item to look for slots
     *   Otherwise use record item
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'S'  or
CSPcA*
650 DC*                            (client = coastl  and
650 MC                             (client = coastl  or
GLPcAC                             client = Greenleaf)  and
CSPcAC                             ittype = 'A'
CSPcA*
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   endif
CSPdA*
IFCaA*   If Alias item, get type for base item.
IFCa C                   if        client = andrews
IFCa C                             or client = birite
IFCa C                             or client = jordanos
IFCa C                   if        ittype = 'A'
IFCa C     keyit3        chain     piritem3                           76
IFCa C                   if        *in76
IFCa C                   eval      i3_ittype = *blanks
IFCa C                   endif
IFCa C                   endif
IFCaA*   If base item for Alias is SSB, get base item for SSB.
IFCa C                   if        i3_ittype = 'S'
IFCa C     keyil3        chain     itemlnk                            78
IFCa C                   if        *in78
IFCa C                   clear                   ilitm2
IFCa C                   clear                   ilitm3
IFCa C                   else
IFCa C                   eval      kyitem = ilitm2
IFCa C                   endif
IFCa C                   endif
     *
IFCa1C                   endif
     *
     *   Loop through picking slots for base item.
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     C                   dou       forevr <> forevr
     C     keysl3        reade     slot3                                  77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Ignore slot if past expiration date.
     *
     C                   if        slexpd <> 0  and
     C                             slexpd < today
     C                   iter
     C                   endif
610 A*
610 A*     Ignore Internal Use Only slots with designation = BFC.
610 AC                   if        sldesg = 'BFC'
610 AC                   iter
610 AC                   endif
     *
     *     Add to item's slots
     *
     C                   add       1             scount
     C                   select
     C                   when      scount = 1
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = Greenleaf
CWDbAC                             or client = Cashwa
SGC AC                             or client = SGC
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
     C                   eval      qedisp = sldisp
     C                   leave
     C                   endsl
     *
     C                   enddo
BIR A*
BIR AC                   if        client = birite  or
ALN AC                             client = allen  or
CSP AC                             client = coastl
GLP AC                             or client = greenleaf
SGC AC                             or client = SGC
BIR A*
BIR A*    Look for overflow slots when no pick slot(s) found.
BIR AC                   if        scount = 0
BIR AC                   eval      kystat = 'A '
BIR AC                   eval      kypick = 'N'
BIR AC     keysl3        setll     slot3
BIR AC                   dou       forevr <> forevr
BIR AC     keysl3        reade     slot3                                  77
BIR AC                   if        *in77
BIR AC                   leave
BIR AC                   endif
610 A*
610 A*     Ignore Internal Use Only slots with designation = BFC.
610 AC                   if        sldesg = 'BFC'
610 AC                   iter
610 AC                   endif
BIR A*
BIR A*     Add to item's slots
BIR A*
BIR AC                   add       1             scount
BIR AC                   select
BIR AC                   when      scount = 1
CSPbA*
CSPbAC                   if        client = coastl
GLPbAC                             or client = greenleaf
CWDbAC                             or client = Cashwa
SGC AC                             or client = SGC
CSPbA*     Retrieve base slot to send to Host.
CSPbAC                   if        slrsrv = 'V'
CSPbAC     keyvs1        chain     vslot1                             74
CSPbAC                   if        not *in74
CSPbAC                   eval      sldisp = vspdis
CSPbAC                   endif
CSPbAC                   endif
CSPbAC                   endif
CSPbA*
BIR AC                   eval      qedisp = sldisp
BIR AC                   leave
BIR AC                   endsl
BIR A*
BIR AC                   enddo
BIR AC                   endif
BIR AC                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETHITS  Get Item hits and total qty picked.
     *
     C     gethits       begsr
     *
     *   Loop through Daily Hits file for item.
     *
SGCaDC*                  eval      kybegdte = 20160501
SGCbDC*                  eval      kybegdte = 20161030
SGCcDC*                  eval      kybegdte = 20170217
SGCcMC                   eval      kybegdte = 20170423
SGCaDC*    keyht2        setll     dlyhits2
SGCaMC     keyht2        setll     label91
     C                   dou       forevr <> forevr
SGCaDC*    keyht         reade     dlyhits2
SGCaMC     keyht         reade     label91
SGCaDC*                  if        %eof(dlyhits2)
SGCaMC                   if        %eof(label91)
SGCaDC*                            or htbegdte > 20161130
SGCbDC*                            or lbsdte   > 20161203
SGCcDC*                            or lbsdte   > 20170317
SGCcMC                             or lbsdte   > 20170531
     C                   leave
     C                   endif
SGCaA*
SGCaA*       Process only Label Type O=Order records.
SGCaAC                   if        lbtype <> 'O'
SGCaAC                   iter
SGCaAC                   endif
     *
SGCaA*      Verify picking location is actual pick slot.
SGCaAC     keysl2        chain     slot2
SGCaAC                   if        not %found(slot2)
SGCaAC                             or slpick <> 'Y'
SGCaAC                   iter
SGCaAC                   endif
     *
SGCaAC                   select
SGCaA*       Total movement for Cases.
SGCaAC                   when          lbtype = 'O'
SGCaAC                             and lbutyp = 'N'
SGCaDC*                  eval      qeunmv = qeunmv + htqty
SGCaMC                   eval      qeunmv = qeunmv + lbqpck
SGCaDC*                  eval      qehits = qehits + hthits
SGCaMC                   eval      qehits = qehits + 1
SGCaA*
SGCaA*       Total movement for Eaches.
SGCaAC                   when          lbtype = 'O'
SGCaAC                             and lbutyp = '1'
SGCaAC                   eval      qeeamv = qeeamv + lbqpck
SGCaAC                   eval      qeeaht = qeeaht + 1
SGCaA*
SGCaAC                   endsl
     *
     C                   enddo
     *
     C                   endsr
640bA*
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZEXPLCNS  Export active license info / lot codes to Host.
640bA*
640bAC     zzexplcns     begsr
640bA*
640bAC     keysl3p       setll     slot3
640bAC                   dou       forevr <> forevr
640bAC     keysl3p       reade     slot3
640bAC                   if        %eof(slot3)
640bAC                   leave
640bAC                   endif
640bA*
640bA*      Ignore slots at Zero status.
640bAC                   if        slstat = 'Z '
640bAC                   iter
640bAC                   endif
640bA*
640dAC                   eval      tllic1 = 0
640dAC                   eval      tllic2 = 0
640dAC                   eval      tllic3 = 0
640dAC                   eval      nbrlicense = 0
640dAC                   eval      tryonce    = '0'
640dA*
640bAC     keyla5        setll     licactive5
640bAC                   dou       forevr <> forevr
640bAC     keyla5        reade     licactive5
640bAC                   if        %eof(licactive5)
640eA*
640eAC                   select
640eAC                   when          nbrlicense = 0
640eAC                             and tryonce = '0'
640eA*      Try to fix missing license plate.
640eAC                   call(e)   'LT001'
640eAC                   parm      'FIX'         lpAction          3
640eAC                   parm      slwhse        lpWhse            3 0
640eAC                   parm      slwhdp        lpWhdp            5
640eAC                   parm      sldisp        lpDisp           12
640eAC                   parm      ' '           lpDummy           1
640eA*      Re-position pointer and attempt to re-read license file.
640eAC     keyla5        setll     licactive5
640eAC                   eval      tryonce = '1'
640eAC                   iter
640eA*
640eAC                   other
640dA
640dA*      Print exception report if slot and license qty's don't match.
640dAC                   eval      SltQty = (slstk1 * itumq2 * itumq3)
640dAC                                      + (slstk2 * itumq3)
640dAC                                      +  slstk3
640dAC                   eval      LicQty = (tllic1 * itumq2 * itumq3)
640dAC                                      + (tllic2 * itumq3)
640dAC                                      +  tllic3
640dAC                   if        SltQty <> LicQty
640dAC                   eval      ermsg1 = 'Slot/Lic qty mismatch'
640dAC                   exsr      zzprterr
640dAC                   endif
640dA*
640eAC                   endsl
640eA*
640bAC                   leave
640bAC                   endif
640eA
640eA*  Count number of active licenses.
640eAC                   eval      nbrlicense = nbrlicense + 1
640bA
640bA*  Get receiving information  - PO & Seq & Lot Code
640bA
640bAC                   exsr      clr$licinfo
640bA
640bAC                   eval      $lnemp#   = 0
640bAC                   eval      $lnuser   = #user
640bAC                   eval      $lnpgm    = #prog
640bAC                   eval      $lnjob    = #job
640bAC                   eval      $lnjobnbr = #jobn
640bA
640bAC                   eval      $lnwhse  = itwhse
640bAC                   eval      $lntype  = 'P'
640bAC                   eval      $lnlcns  = laOLcns
640bA
640bA*     PO number
640bA
640bAC                   eval      $lncodeu(1) = *on
640bAC                   eval      $lncode(1)  = '*PO'
640bAC                   eval      $lncseq(1)  = 1
640bA
640bA*     PO Seq number
640bA
640bAC                   eval      $lncodeu(2) = *on
640bAC                   eval      $lncode(2)  = '*POSEQ'
640bAC                   eval      $lncseq(2)  = 1
640bA
640bA*     Lot Code
640bA
640bAC                   eval      $lncodeu(3) = *on
640bAC                   eval      $lncode(3)  = '*LOT'
640bAC                   eval      $lncseq(3)  = 1
640bA
640bAC                   eval      $dricommand = '*LICINFO'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err     = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                   endif
640bA
640bA*  Now process the return information and load export file fields.
640bA
640bAC                   eval      elawhs = itwhse
640bAC                   eval      elawhd = slwhdp
640bAC                   eval      elastp = slstyp
640bAC                   eval      elaasl = slaisl
640bAC                   eval      elaloc = slloc
640bAC                   eval      elalvl = slrlvl
640bAC                   eval      elahnd = slhand
640bAC                   eval      eladsp = sldisp
640bAC                   eval      elaitm = slitem
640bAC                   evalr     elaqt1 = %trimr(%editc(laQty1:'L'))
640bAC                   evalr     elaqt2 = %trimr(%editc(laQty2:'L'))
640bAC                   evalr     elaqt3 = %trimr(%editc(laQty3:'L'))
640dA*
640dAC                   eval      tllic1 = tllic1 + laQty1
640dAC                   eval      tllic2 = tllic2 + laQty2
640dAC                   eval      tllic3 = tllic3 + laQty3
640dA*
640bAC                   eval      elalcn = lalcns
640bAC                   eval      elaolc = laOLcns
640cAC                   eval      elaent = laentd
640cAC                   eval      elaexp = laexpd
640bA
640bA*     PO number
640bA
640bAC                   if        $lncodee(1) = $driok
640bAC                             and $lnvalchr(1) <> ' '
640bAC                   eval      elapo = %trim($lnvalchr(1))
640bAC                   else
640bAC                   if        %subst($liOLcns:1:3) = '*RT'
640bAC                   eval      elapo = '<return>'
640bAC                   else
640bAC                   eval      elapo = ' '
640bAC                   endif
640bAC                   endif
640bA
640bA*     PO Seq number
640bA
640bAC                   if        $lncodee(2) = $driok
640bAC                             and $lnvalnum(2) <> 0
640bAC                   eval      elapos = $lnvalnum(2)
640bAC                   else
640bAC                   eval      elapos = 0
640bAC                   endif
640bA
640bA*     Lot Code
640bA
EI  A*
EI  AC                   if        client = EI
EI  AC                   eval      elalot = %trim(elapo) +
EI  AC                                      %trim(%editc(elapos:'X'))
EI  AC                   else
EI  A*
640bAC                   if        $lncodee(3) = $driok
640bAC                             and $lnvalchr(3) <> ' '
640bAC                   eval      elalot = $lnvalchr(3)
640bAC                   else
640bAC                   eval      elalot = ' '
640bAC                   endif
EI  AC                   endif
EI  A*
640bA*
640bAC                   eval      eladsg = sldesg
640bAC                   eval      elapck = slpick
640fAC                   eval      elasts = slstat
640bA*
640bAC                   write (e) elarec
640bA*
640bAC                   enddo
640bA*
640bAC                   enddo
640bA*
640bAC     endexplcns    endsr
640dA*
640dA*----------------------------------------------------------------
640dA*
640dA*  ZZPRTERR  Print exception report when slot/license qty's don't match.
640dA*
640dAC     zzprterr      begsr
640dA*
640dAC                   if        not %open(it736pr)
640dAC                   exsr      zzprtovr
640dAC                   open      it736pr
640dAC                   eval      *in90 = '1'
640dAC                   endif
640dA*
640dAC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   eval      *in90 = '0'
640dAC                   endif
640dA*
640dA*   Convert Quantity into Master/Case/Each as needed.
640dAC                   select
640dAC                   when          itflg2 = 'Y'
640dAC                             and itumq3 > 0
640dA*      Item sold as master/case/each only.
640dAC                   eval      slstk1 = SltQty / (itumq2 * itumq3)
640dAC                   eval      wkqty  = SltQty - (slstk1*(itumq2 * itumq3))
640dAC                   eval      slstk2 = wkqty / itumq3
640dAC                   eval      slstk3 = wkqty - (slstk2 * itumq3)
640dA*
640dA*
640dAC                   when          itflg1 = 'Y'
640dAC                             and itumq2 > 0
640dA*      Item sold as case/each only.
640dAC                   eval      slstk1 = SltQty / itumq2
640dAC                   eval      slstk2 = SltQty - (slstk1 * itumq2)
640dAC*
640dAC                   other
640dA*      Item sold as case only.
640dAC                   eval      slstk1 = SltQty
640dAC                   eval      slstk2 = 0
640dAC                   eval      slstk3 = 0
640dAC                   endsl
640dA*
640dAC                   write     detail1                              90
640dA*
640dAC                   eval      tllic1 = 0
640dAC                   eval      tllic2 = 0
640dAC                   eval      tllic3 = 0
640dA*
640dAC     keyla5        setll     licactive5
640dAC                   dou       forevr <> forevr
640dAC     keyla5        reade     licactive5
640bAC                   if        %eof(licactive5)
640dA
640dA*      Print exception license totals.
640dAC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   eval      *in90 = '0'
640dAC                   endif
640dA*
640dAC                   write     total1                               90
640dA*
640dAC                   leave
640dAC                   endif
640dA*
640dAC                   eval      tllic1 = tllic1 + laQty1
640dAC                   eval      tllic2 = tllic2 + laQty2
640dAC                   eval      tllic3 = tllic3 + laQty3
640dA*
600dA*   Convert license qty to lowest form.
640dAC                   eval      LicQty = (laqty1 * itumq2 * itumq3)
640dAC                                      + (laqty2 * itumq3)
640dAC                                      +  laqty3
640dA*
640dA*   Convert Quantity into Master/Case/Each as needed.
640dAC                   select
640dAC                   when          itflg2 = 'Y'
640dAC                             and itumq3 > 0
640dA*      Item sold as master/case/each only.
640dAC                   eval      laqty1 = LicQty / (itumq2 * itumq3)
640dAC                   eval      wkqty  = LicQty - (laqty1*(itumq2 * itumq3))
640dAC                   eval      laqty2 = wkqty / itumq3
640dAC                   eval      laqty3 = wkqty - (laqty2 * itumq3)
640dA*
640dA*
640dAC                   when          itflg1 = 'Y'
640dAC                             and itumq2 > 0
640dA*      Item sold as case/each only.
640dAC                   eval      laqty1 = LicQty / itumq2
640dAC                   eval      laqty2 = LicQty - (laqty1 * itumq2)
640dAC*
640dAC                   other
640dA*      Item sold as case only.
640dAC                   eval      laqty1 = LicQty
640dAC                   eval      laqty2 = 0
640dAC                   eval      laqty3 = 0
640dAC                   endsl
640dA*
640dAC                   if        *in90 = '1'
640dAC                   write     head1
640dAC                   write     columns
640dAC                   write     detail1
640dAC                   eval      *in90 = '0'
640dAC                   endif
640dA*
640dAC                   write     detail2                              90
640dA*
640dAC                   enddo
640dA*
640dAC     endprterr     endsr
640dA*
640dA*----------------------------------------------------------------
640dA*
640dA*  ZZPRTOVR  Process printer file override
640dA*
640dAC     zzprtovr      begsr
640dA*
640dAC                   call      'GETRPT'
640dAC                   parm      '*DEVFORM'    $cmd              8
640dAC                   parm      'IT736PRSGC'  $lrpt            10
640dAC                   parm      $pwhse        $whse             3 0
640dAC                   parm      ' '           $styp             1
640dAC                   parm      ' '           $whdp             5
640dAC                   parm                    $desc            50
640dAC                   parm                    $dev             10
640dAC                   parm                    $form            10
640dA*
640dAC                   if        $dev = ' '
640dAC                   eval      $dev = '*JOB'
640dAC                   endif
640dA*
640dAC                   if        $form = ' '
640dAC                   eval      $form = '*STD'
640dAC                   endif
640dA*
640dA*      Override printer file.
640dA*
640dA*          OVRPRTF FILE(OR630PR) OUTQ(*DEV) DEV($dev)
640dA*                  FORMTYPE($form)
640dA*
640dAC                   eval      qcmd = 'OVRPRTF FILE(IT736PRSGC) '
640dAC                             + 'OUTQ('
640dAC                             + $DEV
640dAC                             + ') '
640dAC                             + 'FORMTYPE('
640dAC                             + $form
640dAC                             + ')'
640dA*
640dAC                   call      'QCMDEXC'
640dAC                   parm                    qcmd             80
640dAC                   parm      80            qlen             15 5
640dA*
640dAC     endprtovr     endsr
640bA*
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------
640aA*                     DRI Subroutines
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------
640aA
640aA*----------------------------------------------------------------
640aA*  clr$item  Clear $item data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$item      begsr
640aAC                   eval      savever# = $itver#
640aAC                   clear                   $item
640aAC                   clear                   $item2
640aAC                   eval      $itver# = savever#
640aAC                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  clr$license  Clear $license data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$license   begsr
640aAC                   eval      savever# = $liver#
640aAC                   clear                   $license
640aAC                   eval      $liver# = savever#
640aAC                   eval      $liemp# = 0
640aAC                   eval      $liuser = #curruser
640aAC                   eval      $lipgm  = #pgm
640aAC                   eval      $lijob  = #job
640aAC                   eval      $lijobn = #jobnbr
640aAC                   eval      $liTowhse = $pwhse
640aAC                   eval      $liTowhseu = *on
640aAC                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  clr$licinfo  Clear $licinfo data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$licinfo   begsr
640aAC                   eval      savever# = $lnver#
640aAC                   clear                   $licinfo
640aAC                   eval      $lnver# = savever#
640aA
640aAC                   eval      $lnuser = #user
640aAC                   eval      $lnpgm  = #prog
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr = #jobn
640aA
640aAC                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  clr$slot  Clear $slot data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$slot      begsr
640aAC                   eval      savever# = $slver#
640aAC                   clear                   $slot
640aAC                   clear                   $slot2
640aAC                   eval      $slver# = savever#
640aAC                   eval      $saemp#U = *on
640aAC                   eval      $saemp# = #emp#
640aAC                   endsr
640aA
640aA
640aA*----------------------------------------------------------------
640aA*  zzzdricop  Call DRICOP
640aA*----------------------------------------------------------------
640aA
640aAC     zzzdricop     begsr
640aAC                   eval      error = *off
640aA
640aAC                   select
640aAC                   when      $dricommand = '*SLOT'
640aAC                   eval      $dridata  = $slot
640aAC                   eval      $dridata2 = $slot2
640aAC                   when      $dricommand = '*ITEM'
640aAC                   eval      $dridata  = $item
640aAC                   eval      $dridata2 = $item2
640aAC                   when      $dricommand = '*LICENSE'
640aAC                   eval      $dridata  = $license
640aAC                   eval      $dridata2 = $license2
640aAC                   when      $dricommand = '*LICINFO'
640aAC                   eval      $dridata = $licinfo
640aAC                   endsl
640aA
640aAC                   select
640aA
640aAC                   when         $dricommand = '*ITEM'
640aAC                             or $dricommand = '*SLOT'
640aAC                             or $dricommand = '*LICENSE'
640aAC                   call(e)   'DRICOP'
640aAC                   parm                    $dricommand
640aAC                   parm                    $drisubcmd
640aAC                   parm                    $drisys2upd
640aAC                   parm      #prog         $driprogram
640aAC                   parm      ' '           $drireturn
640aAC                   parm      ' '           $drimessage
640aAC                   parm                    $dridata
640aAC                   parm                    $dridata2
640aA
640aAC                   other
640aAC                   call(e)   'DRICOP'
640aAC                   parm                    $dricommand
640aAC                   parm                    $drisubcmd
640aAC                   parm                    $drisys2upd
640aAC                   parm      #prog         $driprogram
640aAC                   parm      ' '           $drireturn
640aAC                   parm      ' '           $drimessage
640aAC                   parm                    $dridata
640aA
640aAC                   endsl
640aA
640aAC                   select
640aA
640aAC                   when      %error
640aAC                   eval      error = *on
640aAC*                  eval      errmsg    = 'Error occured on call to '
640aAC*                                      + 'DRICOP'
640aAC*                                      + '/' + %trim($drisubcmd)
640aAC*                                      + ' from ' + #prog
640aAC*                  if        zmsflag
640aAC*                  exsr      zm0105s
640aAC*                  else
640aAC*                  exsr      zm0105
640aAC*                  endif
640aA
640aAC                   when      $drireturn <> '*OK'
640aAC                   eval      error = *on
640aAC*                  if        zmsflag
640aAC*                  exsr      zm0001s
640aAC*                  else
640aAC*                  exsr      zm0001
640aAC*                  exsr      zzerrind
640aAC*                  endif
640aA
640aAC                   endsl
640aA
640aAC                   select
640aAC                   when      $dricommand = '*SLOT'
640aAC                   eval      $slot  = $dridata
640aAC                   eval      $slot2 = $dridata2
640aAC                   when      $dricommand = '*ITEM'
640aAC                   eval      $item  = $dridata
640aAC                   eval      $item2 = $dridata2
640aAC                   when      $dricommand = '*LICENSE'
640aAC                   eval      $license  = $dridata
640aAC                   eval      $license2 = $dridata2
640aAC                   when      $dricommand = '*LICINFO'
640aAC                   eval      $licinfo = $dridata
640aAC                   endsl
640aA
640aAC                   eval      zmsflag = *off
640aAC     enddricop     endsr
