      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  HQ245P    Item Adjustments From Host Picking for LIN slots
     *  26 Novermber 2018
     *  Mike Rooker
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
720 A*  11/26/18  MR   7.20
     *    - Created.
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fimpspckq  uf a e           k disk    usropn
     fkitcomp   if   e           k disk
     fkititem   if   e           k disk
     fpiritem   if   e           k disk
     fpiritem3  if   e           k disk    rename(itrec:itrec3)
     f                                     prefix(i3)
     fitemlnk   if   e           k disk
     fslot2     if   e           k disk    rename(slrec:slrec2)
     fslot4     if   e           k disk    rename(slrec:slrec4)
     fslot10    if   e           k disk    rename(slrec:slrec10)
     fvslot2    if   e           k disk
     fpckqadj   uf a e           k disk
     fitemadj   uf a e           k disk
     Foptions   if   e           k disk
     fhq245pr   o    e             printer oflind(*in90)
     F                                     usropn

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     d prAvailSlot     pr

     d prCreateSlot    pr

     d prFil$Adj       pr

     d prGetDktItm     pr             8

     d prGetSlot       pr

     d prGetSl2        pr

     d prGetWhse       pr             8

     d prLocateSlot    pr

     d prLodAdjHst     pr

     d prNonRepack     pr

     d prPrtItmErr     pr

     d prVfyAdjCde     pr             8

     d prVfyAdjQty     pr             8

     d prZzGetIl       pr

     d prZzInz2        pr

     d prZzUpd         pr

     d prZzzDriCop     pr

     D getRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     d a10             s              1    dim(10)
     d desc            s             40    dim(11) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PROD

     d savever#        s                   like($slver#)
     d slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     d slphy1          s                   like(slstk1)
     d slphy2          s                   like(slstk2)
     d slphy3          s                   like(slstk3)
     d slavl1          s                   like(slstk1)
     d slavl2          s                   like(slstk2)
     d slavl3          s                   like(slstk3)
     d sladj1          s                   like(slstk1)
     d sladj2          s                   like(slstk2)
     d sladj3          s                   like(slstk3)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     d $vcommand       s              8
     d $vdesc          s             30
     d $vmessage       s             60
     d $vmsgk          s              4
     d $vprg           s             10
     d $vreturn        s             10
     d $vwhdp          s                   like($slwhdp)
     d $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d aisle           s              3a
     d aliasflag       s               n
     d avail1          s              5  0 inz
     d avail2          s              3  0 inz
     d avail3          s              3  0 inz
     d checkmemo       s             30a   inz
     d checkorder      s             30a   inz
     d checkrte        s              7  0 inz
     d chkstk1         s                   like(slstk1)
     d Newqtyn         s              5  0
     d Newqty1         s              5  0
     d Newqty2         s              5  0
     d numToProduce    s              4  0
     d client          s             10    inz
     d custmemo        s             30a   inz
     d custorder       s              7  0 inz
     d DebugFlag       s               n   inz('0')
     d*error           s               n
     d*forever         s              1    inz('1')
     d hmsmdy          s             12  0 inz
     D host            s             20a
     D importError     s               n
     D ipqupdated      s               n
     D NoSlotXDK       s               n   inz('0')
     D odritemflag     s               n   inz('0')
     d orderfound      s              4    inz('*NO ')
     d rdate           s              6  0 inz
     D recidnum        s             11p 0
     d remAdjQty       s              7  0 inz
     d reduceQty1      s              7  0 inz
     d reduceQty2      s              7  0 inz
     d reduceQty3      s              7  0 inz
     d rtime           s              6  0 inz
     D savdsp          s                   like(ipqdsp)
     D savwhd          s                   like(ipqwhd)
     D savqp1          s                   like(ipqqp1)
     D savqp2          s                   like(ipqqp2)
     D savqp3          s                   like(ipqqp3)
     D stamp           s               z
     D stampUC         s               z
     d stock1          s              5  0 inz
     d stock2          s              3  0 inz
     d stock3          s              3  0 inz
     d svittype        s              1    inz
     d totAdjQty       s              7  0 inz
     d useAdjust       s               n
     d woDesc          s             55    inz
     d woWhse          s             55    inz
     d w1Code          s              2    inz
     d w1Cwtr          s              9  2 inz
     d w1Memo          s             30    inz
     *
     d wkAdjErr        s              8    inz
     d wkCrtXDKErr     s              8    inz
     d wkErDesc        s             40    inz
     d wkError         s               n
     d wkItmErr        s              8    inz
     d wkItType        s              1    inz
     d wkKeyItm        s             15    inz
     d wkLstSlt        s              4    inz('*NO ')
     d wkPrcErr        s              8    inz
     d wkPrtFlg        s               n
     d wkQtyAdj        s              7  0 inz
     d wkQtyAdj2       s              7  0 inz
     d wkQtyAdj3       s              7  0 inz
     d wkQtyErr        s              8    inz
     d wkQty1          s                   like($saqty1)
     d wkQty2          s                   like($saqty2)
     d wkQty3          s                   like($saqty3)
     d wkSavCmd        s                   like($gcmd)
     d wkSavItm        s             15    inz
     d wkSavSlt        s                   like($sldisp)
     d wkSndBfc        s              4    inz('*NO ')
     d wkTimStp        s               z   inz
     d wkTtlQty        s              7  0 inz
     d wkWhse          s              3  0 inz
     d wkWhsErr        s              8    inz
     d xdkflag         s              4    inz('*NO ')

     d $ccmd           s              8    inz
     d $cstr           s             30    inz
     d $gaisl          s              3    inz
     d $gcmd           s              8    inz
     d $gdesg          s              5    inz
     d $ghand          s              2    inz
     d $gitem          s             15    inz
     d $gloc           s              3  0 inz
     d $grlvl          s              2  0 inz
     d $grtn           s              8    inz
     d $gslot          s             12    inz
     d $gwhdp          s              5    inz
     d $gwhse          s              3  0 inz

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     d cstItmErr       c                   '#itError'
     d cstAdjErr       c                   '#adError'
     d cstQtyErr       c                   '#qtError'
     d cstWhsErr       c                   '#whError'

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     d
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     *
     *   Redefine key
     *
     d  $pwhdp                22     26
     d  $pdisp                27     38
     d  $puser                39     48

     *----------------------------------------------------------------
     *  Redefinition data structures
     *----------------------------------------------------------------

     d $aerm           ds
     d  xaerm                  1     60
     d  $amsg                  1      4
     *
     d $cerm           ds
     d  xcerm                  1     60
     d  $cmsg                  1      4

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------

     d @cvtdt          c                   const('CVTDTE')
     d @fmtit          c                   const('FRMTIT')
     D @getit          c                   const('GETITEMFLD')

     *----------------------------------------------------------------
     *  Called Program Parameters
     *----------------------------------------------------------------
      /copy *libl/qcopysrc,p.getopint
      /copy *libl/qcopysrc,p.wrtlog

     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
     *
     *   Redefine key
     *
     d  $lcode                19     20
     *
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     d $mdt            ds
     d  errmsg                 1     50
     *
     d  eritem                 1     15
     *
     d  eridsg                 1      5
     d  ersdsg                 6     10

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds
     d*               sds
     d* #prog            *proc
     d* #job                 244    253
     d* #user                254    263
     d* #jobn                264    269
     d* #jobdt               276    281  0
     d* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Externally Defined Data Structure
     *----------------------------------------------------------------

     d  dsWrkItm     e ds                  extname(piritem) prefix(ds)
     d  dsPirItm     e ds                  extname(piritem)
     D  sbrec        e ds                  extname(stgbatch) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pType          s             10
     D $pReturn        s             10
     D $pMessage       s            200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *      $pType  - Batch type
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pType
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *  Main line
     *
     c                   open      impspckq
     *
     * Whip through import records
     *
     c     keyipq        setll     impsPckq
     c                   dou       %eof(impsPckq)
     c     keyipq        reade     impsPckq
     *
     c                   eval      useAdjust=*on
     c                   eval      ipqupdated = *off
     c                   if        %eof(impsPckq)
     c                   leave
     c                   endif
     *
     c                   if        ipqstatus <> 'R'
     c                   iter
     c                   endif
     c                   if        ipqadj <> 'LN'
     c                   iter
     c                   endif
     *
     c                   exsr      updLinSlot
     *
     c                   enddo
     *
     c                   close     impspckq
     *
     * Write Exception Report Total
     *
     c                   if        wktote > 0
     c                   if        *in90 = *on
     c                   write     header
     c                   endif
     c                   write     total
     c                   endif
     * End Program
     C*                  exsr      zzzEnd
     *----------------------------------------------------------------
     *   Make slot adjustment to LIN slots
     *----------------------------------------------------------------
     C     updLINslot    begsr
     C                   eval      ipqtext = ' '
     c                   eval      savdsp = ipqdsp
     c                   eval      savwhd = ipqwhd
     c                   eval      savqp1 = ipqqp1
     c                   eval      savqp2 = ipqqp3
     c                   eval      savqp2 = ipqqp3
     C                   eval      xdkflag = '*NO'
     *
     c                   if        ipqWhs <> wkWhse
     c                   callp     prZzInz2
     *
     ** Get BFC Warehouse Desc
     *
     c                   eval      wkWhsErr = prGetWhse()
     *
     c                   eval      wkWhse = ipqWhs
     c                   endif

     C                   eval      orderfound = '*NO '
     *
     ** Write import record to history file.
     *
     c                   callp     prLodAdjHst
     *
     C                   if            ipqqp1 = 0
     C                             and ipqqp2 = 0
     C                             and ipqqp3 = 0
     *      Bypass processing items with no qty to adjust.
     C                   eval      ipqstatus = 'S'
     c                   eval      ipqtext = 'Skipped - No picked quantity'
     c                   exsr      updateIPQREC
     C*                  iter
     C                   goto      endupdLIN
     C                   endif

     *
     c                   if        host = 'NECS-ENTREE'
     c                             and ipqadj = 'MV'
     C                             and ipqqp1 < 0
     c                   eval      ipqstatus = 'S'
     C                   eval      ipqtext = 'Skipped - Returned item'
     c                   exsr      updateIPQREC
     c                   goto      endupdLIN
     c                   endif
     *
     ** Get Dakota Item Master
     *
     c                   eval      wkKeyItm = ipqItm
     *
     c                   eval      wkSavItm = *blanks
     *
     c                   eval      wkItmErr = prGetDktItm()

     c                   if        itdesg = 'NSTK*'
     c                   eval      ipqstatus = 'S'
     c                   eval      ipqtext = 'Skipped - Non-Stock Item'
     c                   exsr      updateIPQREC
     c                   goto      endupdLIN
     c                   endif

    A /free
    A    select;
    A      when ittype = 'A';
    A        aliasflag = *on;
    A      other;
    A        aliasflag = *off;
    A    endsl;
    A /end-free
     *
     ** Verify Adjustment Code
     *
     c                   eval      wkAdjErr = prVfyAdjCde()
     *
     ** Verify Adjustment Qtys
     *
     c                   eval      wkQtyErr = prVfyAdjQty()
     *
     c                   if        wkError = *on
     c                   callp     prPrtItmErr
     c                   eval      wkError = *off
     c                   eval      wkPrtFlg = *on
     c                   exsr      updateIPQREC
     c*                  iter
     c                   goto      endupdLIN
     c                   endIf
     *
     ** Save SSB Item Number & Type.
     *
     c                   eval      wkItType = *blank
     *
     c                   if        dsItType = 'S'
     c                             or dsItType = 'R'
     c                   eval      wkItType = dsItType
     c                   endif
     *
     ** Get Alias Item Base item.
     ** Get SSB Item Base item.
     *
     c                   if        dsItType = 'A'
     c                               or dsItType = 'S'
     c                   callp     prZzGetIl
     *
     c                   if        wkError = *on
     c                   eval      wkErDesc = desc(2)
     c                   callp     prPrtItmErr
     c                   exsr      updateIPQREC
     c*                  iter
     c                   goto      endupdLIN
     c                   endif
     *
     ** Load base item instead.
     *
     *      Only load Base item for Alias items.
     c                   if        dsItType = 'A'
     c                   eval      wkKeyItm = *blanks
     c                   eval      wkKeyItm = %TRIM(ilitm2)
     c                   endif
     c                   endif
     *
     ** If Alias item, get type for base item.
     *
     c                   if        dsItType = 'A'
     c     keyit3        chain     pirItem3
     c                   if        not %found(pirItem3)
     c                   eval      i3ItType = *blanks
     c                   endif
     *
     ** If base item for Alias is SSB, get Base item for SSB.
     *
     c                   if        i3ItType = 'S'
     c     keyil3        chain     itemLnk
     c                   if        not %found(itemLnk)
     c                   clear                   ilitm2
     c                   clear                   ilitm3
     c                   endif
     c                   endif
     *
     c                   endif
     *
     ** Get Pick Slot For Item.
     *
     c                   eval      $gcmd  = '*FIRST  '
     c                   eval      $gwhse = $pwhse
     c                   eval      wkCrtXDKErr = *blanks

     c                   select
     *
     c                   when      dsItType <> 'R'
     *
     *      In order to find pick slot, need base item#.
     C                   if           dsItType = 'A'
     C                             or dsItType = 'S'
     *
     C                   eval      $gitem = ilitm2
     C                   else
     c                   eval      $gitem = wkKeyItm
     C                   endif
     c                   eval      $gslot = *blanks
     *
     ** Process Slot Recvd in Import File
     *
     c                   if        ipqDsp <> *blanks
     *
     * Setup Valid Department
     *
     c                   if        ipqWhd = *blanks
     c                   eval      ipqWhd = dsItWhDp
     c                   endIf
     *
     * Verify that dept/slot sent contains item.
     C     keysl4        setll     slot4
     C                   if        not %equal(slot4)
     *
     * Item not found in base slot. Check virtual slots for item.
     C     keyvs2        setll     vslot2
     C                   dow       forever = forever
     C     keyvs2        reade     vslot2
     C                   if        %eof(vslot2)
     C                   leave
     C                   endif
     *
     C     keyvs4        setll     slot4
     *      Virtual slot found. Update import slot field to use.
     C                   if        %equal(slot4)
     C                   eval      ipqdsp = vsdisp
     C                   leave
     C                   endif
     *
     C                   enddo
     *  end to slot found in slot4 above using passed in slot
     C                   endif
     *
     * Load DRI Interface Fields
     *
     c                   eval      wkQty1 = ipqqp1 * -1
     c                   eval      wkQty2 = ipqqp2 * -1
     c                   eval      wkQty3 = ipqqp3 * -1

     *  write adjustment for transaction

     c                   callp     prZzUpd
     *
     c                   if        wkError = *on
     c                   eval      wkErDesc = desc(10)
     c                   callp     prPrtItmErr
     c                   exsr      updateIPQREC
     c*                  iter
     c                   goto      endupdLIN
     c                   endif
     *   else ipqdsp = blanks
     c                   else
     c                   callp     prNonRepack
     *   ipqdsp <> blanks
     c                   endif
     *
     c                   endsl

     c                   exsr      updateIPQREC
     c     endupdLIN     endsr
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr

     * Get client id.

     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   parm                    clientloc        10
     *
     *       Retrieve current user number from PIR User table.
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     c                   eval      *in90 = *on
     c                   time                    wkTimStp
     c                   time                    hmsmdy
     c                   Move      hmsmdy        rdate
     c                   movel     hmsmdy        rtime
     *
     c                   eval      $lprg = #prog

     *   Set warehouse defaults.

     c                   eval      w1Cwtr = *zeros
     c                   eval      $pwhdp = '*ALL '
     *
     * Retrieve current date/time for report printing.
     c                   eval      $cvcmd = '*CURMDY '
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     c                   eval      rdate = $cvd6o
     c                   time                    rtime
     *
     * Define partial key fpr IMPSPCKQ
     *
     c     keyipq        klist
     c                   kfld                    $pWhse
     c                   kfld                    $pBatId
     *
     * Define full key for SLOT2.
     *
     c     *like         define    slwhdp        kywhdp
     c     *like         define    sldisp        kydisp
     *
     c     keysl2        klist
     c                   kfld                    $pwhse
     c                   kfld                    kywhdp
     c                   kfld                    kydisp
     *
     c     keyvs2        klist
     c                   kfld                    ipqwhs
     c                   kfld                    ipqwhd
     c                   kfld                    ipqdsp
     *
     * Define full key for SLOT4.
     *
     c     keysl4        klist
     c                   kfld                    ipqwhs
     c                   kfld                    ipqwhd
     c                   kfld                    wkkeyitm
     c                   kfld                    ipqdsp
     *
     c     keysla        klist
     c                   kfld                    ipqwhs
     c                   kfld                    ipqitm
     *
     c     keyvs4        klist
     c                   kfld                    ipqwhs
     c                   kfld                    ipqwhd
     c                   kfld                    wkkeyitm
     c                   kfld                    vsdisp
     *
     * ITEMLINK Full file key
     *
     c     keyit         klist
     c                   kfld                    $pwhse
     c                   kfld                    wkKeyItm
     *
     * KITCOMP  Partial file key
     *
     c     keykc         klist
     c                   kfld                    $pwhse
     c                   kfld                    ipqItm
     *
     * Define key for PIRITEM3 file
     *
     c     keyit3        klist
     c                   kfld                    wkKeyItm
     c                   kfld                    itwhse
     *
     * ITEMLINK Full file key
     *
     c     keyil         klist
     c                   kfld                    $pwhse
     c                   kfld                    wkKeyItm
     *
     * ITEMLINK Full file key
     *
     c     keyil3        klist
     c                   kfld                    itwhse
     c                   kfld                    wkKeyItm
     *
     *   Get import item fields options.
     *
      /free
        $pWhse = %dec($pWhse3A: 3: 0);
        chain ($pWhse:'*HOST') options;
        if %found(options);
          host = opdata;
        else;
          host = '*NOT FOUND';
        endif;
      /end-free
     *
     *   Get option for debugging.
     *
      /free
        // Get debug flag
        optint.type = 'Interface   ';
        optint.cat  = 'Import Picked Qty   ';
        optint.name = 'Debug Flag          ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK'
         and optint.vala = 'Y';
          debugflag = *on;
        else;
          debugflag = *off;
        endif;

        // Log program start
        if debugflag;
          log.pgm = #pgm;
          log.type = 'Start    ';
          log.text = 'Import Host Picked Quantities for: ' + $pBatId;
          WrtLog(log.pgm: log.type: log.text);
        endif;
      /end-free

     *
     *   Get option for creating XDK when no slot found.
     *
      /free
        // Get No Slot XDK flag
        optint.type = 'Interface   ';
        optint.cat  = 'Import Picked Qty   ';
        optint.name = 'HQ245S No Slot XDK  ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK'
         and optint.vala = 'Y';
          NoSlotXDK = *on;
        else;
          NoSlotXDK = *off;
        endif;
      /end-free

     c                   endsr

     *----------------------------------------------------------------
     *  updateIPQREC   Update impspckq record
     *----------------------------------------------------------------

     c     updateIPQREC  begsr

     C                   if        ipqstatus = 'E'
     C                   eval      importError = *on
     C                   else
     C                   eval      ipqstatus = 'S'
     C                   endif
     C                   exsr      zzzGetStamps
     C                   eval      ipqststs = stamp
     C                   eval      ipqstsuc = stampuc
     c                   eval      ipqdsp = savdsp
     c                   eval      ipqwhd = savwhd
     c*                  eval      ipqqp1 = savqp1
     c*                  eval      ipqqp2 = savqp2
     c*                  eval      ipqqp3 = savqp3

     c                   if        ipqupdated = *off
     C                   update    ipqrec
     c                   eval      ipqupdated = *on
     c                   endif

     c                   endsr

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c*    zzzEnd        begsr
     c*                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp - current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr


      *----------------------------------------------------------------
      *  ZZUPQTY       Up quantity
      *----------------------------------------------------------------

     C     zzupqty       begsr

      /free
            // check for negative quantities
            *in49=*off;
            if newqtyn<0;
               *in49=*on;
               newqtyn = %abs(newqtyn);
            endif;
            if newqty1<0;
               *in49=*on;
               newqty1 = %abs(newqty1);
            endif;
            if newqty2<0;
               *in49=*on;
               newqty2 = %abs(newqty2);
            endif;
      /end-free

     C                   dow       itumq3 > 0 and +
     C                               newqty2 >= itumq3
     C                   eval      newqty2 -= itumq3
     C                   eval      newqty1 += 1
     C                   enddo

     C                   dow       itumq2 > 0 and +
     C                               newqty1 >= itumq2
     C                   eval      newqty1 -= itumq2
     c                   eval      newqtyn += 1
     C                   enddo

      /free
                         if *in49;
                            newqtyn = newqtyn * -1;
                            newqty1 = newqty1 * -1;
                            newqty2 = newqty2 * -1;
                         endif;
      /end-free

     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *            Compute Available Qty In From Slot.
     *
     p prAvailSlot     b
     d  prAvailSlot    pi
     *
     c
     c                   call      'SLOTQTY'
     c                   parm                    SLSTK1
     c                   parm                    SLSTK2
     c                   parm                    SLSTK3

     c                   parm                    SLALC1
     c                   parm                    SLALC2
     c                   parm                    SLALC3

     c                   parm                    SLTFR1
     c                   parm                    SLTFR2
     c                   parm                    SLTFR3

     c                   parm                    SLPCK1
     c                   parm                    SLPCK2
     c                   parm                    SLPCK3

     c                   parm                    SLRCV1
     c                   parm                    SLRCV2
     c                   parm                    SLRCV3

     c                   parm                    stock1
     c                   parm                    stock2
     c                   parm                    stock3

     c                   parm                    avail1
     c                   parm                    avail2
     c                   parm                    avail3

     c                   return

     p prAvailSlot     e
     *
     *----------------------------------------------------------------
     *
     *  prFil$Adj - Fill $slot data structure fields for adjustment.
     *
     p prFil$Adj       b
     d  prFil$Adj      pi

     *  Initialize data structure

     c                   eval      savever# = $slver#
     c                   clear                   $slot
     c                   clear                   $slot2
     c                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     c                   eval      $slwhseu = *on
     c                   eval      $slwhse  = ipqWhs

     c                   eval      $slwhdpu = *on
     c                   eval      $slwhdp  = ipqWhd

     c                   eval      $sldispu = *on
     c                   eval      $sldisp  = ipqDsp

     c                   eval      $saitemu = *on
     *
     *  Use SSB item when making item adjustment.
     *
     c                   eval      $saitem  = wkKeyItm
     *

     c                   eval      $saqtyu  = *on

     c                   eval      $saqty1  = wkQty1
     c                   eval      $saqty2  = wkQty2
     c                   eval      $saqty3  = wkQty3

     c                   eval      $sacwtau = *off
     c                   eval      $sacwta  = 0

     c                   eval      $sacodeu = *on
     c                   eval      $sacode  = ipqAdj

     c                   eval      $samemou = *on
     c                   eval      $samemo  = ipqMem

     c                   eval      $sabyu   = *on
     c                   eval      $saby    = #user
     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'ADJ'
     C                   eval      $saemp#U = *on
     C                   eval      $saemp#  = #emp#

     c                   return

     p prFil$Adj       e
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIT - Get Dakota Item Master Record
     *
     p prGetDktItm     b
     d  prGetDktItm    pi             8
     *
     d prItmErr        s              8    inz('#NoError')
     *
     *   Get Record From Item Master
     *
     c                   eval      wkError = *off
     c     keyIt         chain     pirItem
     c                   if        %found(pirItem)
     c                   eval      dsWrkItm = dsPirItm
     c                   else
     c                   eval      prItmErr = cstItmErr
     c                   eval      wkError = *on
     c                   eval      slDisp = ' '
     c                   endif
     *
     c                   return    prItmErr
     *
     p prGetDktItm     e
     *
     *------------------------------------------------------------------*
     *
     *    Get Pick Slot For Item.
     *
     p prGetSlot       b
     d  prGetSlot      pi
     *
     *
     c                   call      'GETPSLTMV'
     c                   parm                    $gcmd
     c                   parm                    $gwhse
     c                   parm      *blanks       $gwhdp
     c                   parm                    $gitem
     c                   parm                    $gslot
     c                   parm      *blanks       $gaisl
     c                   parm      *zeros        $gloc
     c                   parm      *zeros        $grlvl
     c                   parm      *blanks       $ghand
     c                   parm      *blanks       $grtn
     *
     c                   return
     *
     p prGetSlot       e
     *
     *----------------------------------------------------------------
     *
     *  PRGETSL2 - Get Actual Slot Record For Item.
     *
     p prGetSl2        b
     d  prGetSl2       pi

     c     keysl2        chain     slot2

     c                   return

     p prGetSl2        e
     *
     *----------------------------------------------------------------
     *
     *  PRCREATESLOT - Create LIN slot
     *
     p prCreateSlot    b
     d  prCreateSlot   pi

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     c                   clear                   $slot2
     c                   if        ipqWhd = *blanks
     c                   eval      ipqWhd = dsItWhDp
     c                   endIf
     C                   eval      $slver# = savever#
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = ipqwhd
     C                   eval      $slitemu = *on
710 Ac                   eval      $slitem  = ipqitm
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = 'PR'
     C                   eval      $sldispu = *on
     c                   eval      $sldisp = 'LIN-101-1'
     c                   eval      $saToAreaU = *on
     c                   eval      $saToArea = 'Slot'
     c                   eval      $saToLcnsU = *on
     c                   eval      $saToLcns = '*PR'
710dAc                   eval      $slEntd = %uns(%char(%Date():*Iso0))
710dAc                   eval      $slExpd = 0
710dAc                   eval      $slExpDU = *off
     C                   eval      $drisubcmd  = '%CRTPROD'
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisys2upd = 'D'
     c                   callp     prZzzDriCop
     c                   if        $drireturn <> '*OK'
     C                             and $drireturn <> 'INSLOT'
     c                   eval      $pMessage = $driMessage
     c                   else
     c                   eval      ipqdsp = $sldisp
     c                   endif

     c                   return

     p prCreateSlot    e
     *
     *----------------------------------------------------------------
     *
     *   Get warehouse description.
     *
     p prGetWhse       b
     d  prGetWhse      pi             8
     *
     d prWhsErr        s              8    inz('#NoError')
     *
     c                   eval      wowhse = *blanks
     c                   eval      $cstr = *blanks
     *
     c                   call(e)   'VFYWHSE'
     c                   parm      '*VERIFY'     $vcommand
     c                   parm      '*NONE'       $vprg
     c                   parm      ipqwhs        $vwhse
     c                   parm      ' '           $vdesc
     c                   parm      ' '           $vreturn
     c                   parm      ' '           $vmessage
     c                   parm      ' '           $vmsgk
     *
     c                   select
     *
     c                   when      %error
     c                   eval      prWhsErr = cstWhsErr
     c                   eval      wkError = *on
     *
     c                   when      $vreturn <> '*OK'
     c                   eval      prWhsErr = cstWhsErr
     c                   eval      wkError = *on
     *
     c                   endsl
     *
     c                   move      $pwhse        $cstr
     *
     * Right / Left Adjust
     *
     c                   call      'ADJUST'
     c                   parm      '*LEFT   '    $ccmd
     c                   parm                    $cstr
     *
     c                   eval      wowhse = %trim($cstr) + '/'
     c                                    + %trim($pwhdp) + ' - '
     c                                    + %trim($vdesc)
     *
     c                   return    prWhsErr
     *
     p prGetWhse       e
     *
     *----------------------------------------------------------------
     *
     *    Locate Slot when one is not passed in with FTP data
     *
     p prLocateSlot    b
     d  prLocateSlot   pi
     *
     ** Create Adjustments for Item without slot passed in FTP import
     *
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
     C                   dow       ipqqp1 <> 0
     C                             or ipqqp2 <> 0
     C                             or ipqqp3 <> 0
     *
     c                   callp     prGetSlot
     *
     c                   Select
     *
     *     No pick slot found for item. Look for first overflow slot.
     *
     C                   When          ipqsof = 'Y'
     C                             and ($gslot = '*NONE*  '
     C                             and  $gcmd  = '*FIRST  '
     C                             and  itstyp = 'F')
     C                   eval      $gcmd  = 'FRSTOFLL'
     C                   Iter
     *
     ** No pick/overflow slot found for item, print error.
     *
     c                   when      $gslot = '*NONE*  '
     *
     c                   if        $Pcmd = '*OUTCHG'
     c                   eval      $Prtn = '*No Adj'
     c                   leave
     c                   endif
     c*                  eval      wkErDesc = desc(3)
     c*                  callp     prPrtItmErr
     C*                  eval      ipqstatus = 'E'
     C*                  eval      importError = *on
     c*                  eval      ipqtext = desc(3)
     c*                  if        ipqupdated = *off
     C*                  update    ipqrec
     c*                  eval      ipqupdated = *on
     c*                  endif
     c*                  leave
     c                   callp     prCreateSlot()
     c                   eval      $pcmd = 'FRSTOFLL'
     C                   iter
     *
     c                   endsl
     *
     c     slotskip      tag
     *
     ** Active Slot Found. Compute Available Qty.
     *
     c                   if        $gwhdp > ' '
     c                   eval      kyWhdp = $gwhdp
     c                   else
     c                   eval      kyWhdp = dsItWhDp
     c                   endif
     c                   eval      ipqwhd = kyWhdp
     *
     c                   eval      kyDisp = $gslot
     *
     c                   callp     prGetSl2
     *
     ** Slot not found. Shouldn't ever happen, but if it does....
     *
     c                   if        not %found(slot2)
     c                   eval      wkErDesc = desc(3)
     c                   callp     prPrtItmErr
     C                   eval      ipqstatus = 'E'
     C                   eval      importError = *on
     c                   eval      ipqtext = desc(3)
     c                   if        ipqupdated = *off
     C                   update    ipqrec
     c                   eval      ipqupdated = *on
     c                   endif
     c                   iter
     c                   endif
     *
     ** Check To See If This Is Last Slot Available For Item.
     *
     c                   eval      wkSavCmd  = $gcmd
     c                   eval      wkSavSlt = $gslot
     c                   eval      wkLstSlt = '*NO '
     *
     ** Check For More Available Slots.
     *
     c                   select
     *
     *  Has pick slots, get next available
     *
     c                   when      $gcmd = '*FIRST'
     c                                 or $gcmd = '*NEXT '
     c                   eval      $gcmd = '*MORPICK'
     *
     *  No Pick Slots, Get Next Available Overflow Slot.
     *
     c                   when      $gcmd = 'FRSTOFLL'
     c                                 or $gcmd = 'NEXTOFLL'
     c                   eval      $gcmd = 'MOROVFLL'
     *
     c                   endsl
     *
     c                   callp     prGetSlot
     *
     ** No More Slots Found. Adjust Remaining Qty From This Slot.
     *
     c                   if        $gslot = '*NONE*'
     c                   eval      wkLstSlt = '*YES'
     c                   endif
     *
     ** Restore previous values after lookup.
     *
     c                   eval      $gcmd   = wkSavCmd
     c                   eval      $gslot  = wkSavSlt
     c                   eval      ipqdsp  = wkSavSlt
     *
     ** Slot found. Compute available qty in slot.
     *
     c                   callp     prAvailSlot
     *
     ** If not a credit memo, check if more slots are available.
     *
     c                   if        avail1 = 0
     c                             and avail2 = 0
     c                             and avail3 = 0
     c                             and wkLstSlt = '*NO '
     *
     c                   select
     *
     *    Item has pick slots, find next available pick slot.
     *
     c                   when      $gcmd = '*FIRST'
     c                   eval      $gcmd = '*NEXT'
     *
     c                   Iter
     *
     *    Pick slot read has zero available qty, find next slot.
     *
     c                   when         $gcmd = '*NEXT'
     c                             or $gcmd = 'NEXTOFLL'
     c                   Iter
     *
     *    Item has no pick slots, find next available overflow slot.
     *
     c                   when      $gcmd = 'FRSTOFLL'
     c                   eval      $gcmd = 'NEXTOFLL'
     *
     c                   Iter
     *
     c                   endsl
     *
     c                   endif
     *
     *    Slot found with available qty. If broken case picked, convert cases
     *    to total eaches.
     *
     C                   eval      wkTtlQty = (avail1 * itumq2 * itumq3)
     C                                      + (avail2 * itumq3)
     C                                      +  avail3
     *
     *    Convert imported adjusted qty's to lowest form.
     C                   eval      totAdjQty = (ipqqp1 * itumq2 * itumq3)
     C                                      + (ipqqp2 * itumq3)
     C                                      +  ipqqp3
     *
     c     #start_adj    tag
     *
     c                   eval      $pwhdp = slwhdp
     *
     ** Load Info From File For Adjustment.
     *
     c                   eval      wkQty1 = 0
     c                   eval      wkQty2 = 0
     c                   eval      wkQty3 = 0
     *
     c                   eval      w1Cwtr = 0
     c                   eval      w1Code = '  '
     c                   eval      wkError = *off
     *
     *   Last slot available for item or qty available greater than
     *   qty picked or this is a credit memo.
     *
     c                   select
     *
     c                   when      wkLstSlt = '*YES'
     *
     c                             or totAdjQty <= wkTtlQty
     *
     c                             or totAdjQty < 0
     *
     *      Remainder zeroed because entire qty will be adjusted
     *      from the selected slot.
     C                   eval      remAdjQty = 0
     *
     C                   eval      wkQty3    = %rem(totAdjQty : itumq3)
     c                   eval      wkQty3    = wkQty3 * -1
     C                   eval      wkTtlQty  = %div(totAdjQty : itumq3)
     *
     C                   eval      wkQty2    = %rem(wkTtlQty : itumq2)
     c                   eval      wkQty2    = wkQty2 * -1
     C                   eval      wkTtlQty  = %div(wkTtlQty : itumq2)
     *
     C                   eval      wkQty1    = wkTtlQty
     c                   eval      wkQty1    = wkQty1 * -1
     *
     c                   eval      w1Cwtr = 0
     *
     *   Slot does not have sufficient qty to cover qty picked.
     *   Take all available from this slot.
     *
     c                   when      totAdjQty > wkTtlQty
     c
     C                   eval      remAdjQty = totAdjQty - wkTtlQty
     *
     C                   eval      wkQty3    = %rem(wkTtlQty : itumq3)
     c                   eval      wkQty3 = wkQty3 * -1
     C                   eval      wkTtlQty  = %div(wkTtlQty : itumq3)
     *
     C                   eval      wkQty2    = %rem(wkTtlQty : itumq2)
     c                   eval      wkQty2 = wkQty2 * -1
     C                   eval      wkTtlQty  = %div(wkTtlQty : itumq2)
     *
     C                   eval      wkQty1    = wkTtlQty
     c                   eval      wkQty1 = wkQty1 * -1
     *
     c                   eval      w1Cwtr = 0
     *
     c                   endsl
     *
     c                   eval      w1Code = ipqAdj
     *
     c                   eval      w1Memo = ipqmem
     *
     *   Send adjustment to be processed.
     *
     c                   callp     prZzUpd
     *
     c                   if        wkError = *On
     c                   eval      wkErDesc = desc(5)
     c                   callp     prPrtItmErr
     C                   eval      ipqstatus = 'E'
     C                   eval      importError = *on
     c                   eval      ipqtext = desc(5)
     c                   if        ipqupdated = *off
     C                   update    ipqrec
     c                   eval      ipqupdated = *on
     c                   endif
     *
     c                   select
     *
     *    Item has pick slots, find next available pick slot.
     *
     c                   when      $gcmd = '*FIRST'
     c                   eval      $gcmd = '*NEXT'
     *
     *    Item has no pick slots, find next available overflow slot.
     *
     c                   when      $gcmd = 'FRSTOFLL'
     c                   eval      $gcmd = 'NEXTOFLL'
     *
     c                   endsl
     *
     c                   Iter
     c                   Endif
     *
     *   Reduce pick qty by qty adjusted from slot.
     *
     c*                  eval      ipqqp1 = ipqqp1 - wkQtyAdj
     *
     C                   eval      ipqqp3    = %rem(remAdjqty : itumq3)
     C                   eval      remAdjQty = %div(remAdjQty : itumq3)
     *
     C                   eval      ipqqp2    = %rem(remAdjQty : itumq2)
     C                   eval      remAdjQty = %div(remAdjQty : itumq2)
     *
     C                   eval      ipqqp1    = remAdjQty
     *
     *
     *   Pick qty still remaining. Set cmd to look for next slot.
     *
     c                   If        ipqqp1 <> 0
     c                             or ipqqp2 <> 0
     c                             or ipqqp3 <> 0
     *
     c                   select
     *
     *    Item has pick slots, find next available pick slot.
     *
     c                   when      $gcmd = '*FIRST'
     c                   eval      $gcmd = '*NEXT'
     *
     *    Item has no pick slots, find next available overflow slot.
     *
     c                   when      $gcmd = 'FRSTOFLL'
     c                   eval      $gcmd = 'NEXTOFLL'
     c                   endsl
     c                   endif
     *   dow ipqqp1-3 <> 0
     c                   enddo
     p prLocateSlot    e
     *
     *----------------------------------------------------------------
     *
     *   Load Adjustment History Fields
     *
     p prLodAdjHst     b
     d  prLodAdjHst    pi
     *
     c                   eval      pqhwhs = ipqwhs
     c                   eval      pqhwhd = ipqwhd
     c                   eval      pqhdsp = ipqdsp
     c                   eval      pqhitm = ipqitm
     c                   eval      pqhqp1 = ipqqp1
     c                   eval      pqhqp2 = ipqqp2
     c                   eval      pqhqp3 = ipqqp3
     c                   eval      pqhadj = ipqadj
     c                   eval      pqhmem = ipqmem
     c                   eval      pqhsof = ipqsof
     c                   eval      pqhids = wkTimStp
     *
     c                   write     pqhrec
     *
     c                   return
     *
     p prLodAdjHst     e
     *
     *----------------------------------------------------------------
     *
     *    GETIT - Get Dakota Item Master Record
     *
     p prPrtItmErr     b
     d  prPrtItmErr    pi
     *
     ** Print Header Record
     *
     c                   if        wkPrtFlg = *off or
     c                               *in90 = *on
     c                   write     header
     c                   eval      wkPrtFlg = *on
     c                   eval      *in90 = *off
     c                   endif
     *
     ** Print Detail Record
     *
     c                   eval      wktote = wktote + 1
     *
     ** Setup Detail Line Error Desc
     *
     c                   select
     *
     c                   when      wkWhsErr = cstQtyErr
     c                   eval      wkrerr = desc(9)
     c                   write     detail
     *
     c                   when      wkAdjErr = cstAdjErr
     c                   eval      wkrerr = desc(7)
     c                   write     detail
     *
     c                   when      wkItmErr = cstItmErr
     c                   eval      wkrerr = desc(1)
     c                   write     detail
     *
     c                   when      wkQtyErr = cstQtyErr
     c                   eval      wkrerr = desc(8)
     c                   write     detail
     *
     c                   when      wkErDesc <> *blanks
     c                   eval      wkrerr = wkErDesc
     c                   write     detail
     c                   if        wkrerr2 <> *blanks
     c                   write     detail2
     c                   endIf
     *
     c                   endsl

     c                   eval      ipqStatus = 'E'
     c                   if        ipqText = ' '
     c                   eval      ipqText = wkrerr
     c                   else
     c                   eval      ipqText = %trimr(ipqText) + ' // '
     c                                     + wkrerr
     c                   endif
     c                   if        wkrerr2 <> ' '
     c                   eval      ipqText = %trimr(ipqText) + ' :: '
     c                                     + wkrerr2
     c                   endif
     *
     ** Clear Error Work Fields
     *
     c                   eval      wkAdjErr = *blanks
     c                   eval      wkItmErr = *blanks
     c                   eval      wkQtyErr = *blanks
     c                   eval      wkWhsErr = *blanks
     c                   eval      wkErDesc = *blanks
     c                   eval      wkrerr2  = *blanks
     *
     c                   return
     *
     p prPrtItmErr     e

     *
     *----------------------------------------------------------------
     *
     *            Verify Adjustment Code
     *
     p prVfyAdjCde     b
     d  prVfyAdjCde    pi             8
     *
     d prAdjErr        s              8    inz('#NoError')
     *
     *   Check Adj Code File Master File
     *
     c                   eval      $lcmd  = '*VERIFYB'
     c                   eval      $lCode = ipqAdj
     *
     c                   call      'AD900'
     c                   parm                    $lparm
     *
     c                   if        $lrtn = '*ERROR  '  or
     c                               $lrtn <> '*OK     '
     c                   eval      prAdjErr = cstAdjErr
     c                   eval      wkError = *on
     c                   endIf
     *
     c                   return    prAdjErr
     *
     p prVfyAdjCde     e
     *
     *----------------------------------------------------------------
     *
     *            Verify Adjustment Code
     *
     p prVfyAdjQty     b
     d  prVfyAdjQty    pi             8
     *
     d prQtyErr        s              8    inz('#NoError')
     *
     *   Check Quantities
     *
     c                   if        ipqqp1 = *zeros and
     c                             ipqqp2 = *zeros and
     c                             ipqqp3 = *zeros
     c                   eval      prQtyErr = cstQtyErr
     c                   eval      wkError = *on
     c                   endIf
     *
     c                   return    prQtyErr
     *
     p prVfyAdjQty     e
     *
     *----------------------------------------------------------------
     *
     *    Read KITCOMP and KITITEM for Repack information
     *
     p prNonRepack     b
     d  prNonRepack    pi
      /free
        odritemflag = *off;
        wkSavItm = ' ';
        wkitmErr = prGetDktItm();  //get master item info
        if wkError = *on;
           wkItmErr = ' ';
           wkErDesc = desc(11);
           callp prPrtItmErr();
700aA      ipqstatus = 'E';
700aA      importError = *on;
700aA      ipqtext = desc(11);
700aA      if ipqupdated = *off;
700aA        update ipqrec;
700aA        ipqupdated = *on;
700aA      endif;
           return;
        endif;
650bA   callp prLocateSlot();
      /end-free
     p prNonRepack     e
     *
     *----------------------------------------------------------------
     *
     *  PRZZGETIL - Get Dakota Item Link Record
     *
     p prZzGetIl       b
     d  prZzGetIl      pi
     *
     ** Get Record From Main File.
     *
     c                   eval      wkError = *off
     *
     c     keyil         chain     itemLnk
     c                   if        not %found(itemLnk)
     c                   eval      wkError = *on
     c                   eval      ilitm2  = ' '
     c                   eval      ilitm3  = ' '
     c                   endif
     *
     c                   return
     *
     p prZzGetIl       e
     *
     *----------------------------------------------------------------
     *
     *  PRZZINZ2 - Program Initialization. Called From Main Line
     *
     p prZzInz2        b
     d  prZzInz2       pi
     *
     C                   if        %open(hq245pr)
     *
     * Write Exception Report Total
     *
     c                   if        wktote > 0
     c                   if        *in90 = *on
     c                   write     header
     c                   endif
     c                   write     total
     c                   endif
     *
     C                   close     hq245pr
     C                   endif
     C                   eval      wktote = 0
     *
     *      Retrieve report device override.
     C                   if        not %open(hq245pr)
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'HQ245PR'     $lrpt            10
     C                   parm      ipqwhs        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm      ' '           $dev             10
     C                   parm      ' '           $form            10
     *
     C                   if        $dev = ' '
     C                   eval      $dev = '*JOB'
     C                   endif
     C                   if        $form = ' '
     C                   eval      $form = '*STD'
     C                   endif
     *
     C                   eval      qcmd = 'OVRPRTF '
     C                                  + 'FILE(HQ245PR) '
     C                                  + 'OUTQ(' + %trim($dev) + ') '
     C                                  + 'FORMTYPE(' + %trim($form) + ') '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     *  Open printer file

     c                   eval      *in90 = *on
     C                   open(e)   hq245pr
     C                   if        %error
     C                   endif
     *
     C                   endif
     *
     c                   eval      wkError = *off
     c                   eval      $prtn = *blanks
     c                   eval      $perm = *blanks
     c                   eval      wkErDesc = *blanks
     c                   Move      *Blanks       Wodesc
     *
     c                   return
     *
     p prZzInz2        e
     *
     *----------------------------------------------------------------
     *
     *  PRZZUPD - Update Record
     *
     p prZzUpd         b
     d  prZzUpd        pi
     *
     c                   eval      wkError = *off

     *   Fill interface data structure fields.

     c                   callp     prFil$Adj
      *   if Repack ODR then mark with action of ODR
     c*                  if        ipqadj='R1'
     c*                  eval      $saactionu=*on
     c*                  eval      $saaction='ODR'
     c*                  endif

     *   Call interface to do update.

     c                   eval      $dricommand = '*SLOT'
     c                   if        useAdjust
     c                   eval      $drisubcmd  = '%ADJUST'
     c                   else
     c                   eval      $drisubcmd  = '%ADJUSTORD'
     c                   endif
     c                   eval      $drisys2upd = 'D'
     *
     c                   callp     prZzzDriCop
     *
     c                   return
     *
     p prZzUpd         e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     p prZzzDriCop     b
     d  prZzzDriCop    pi
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2

     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
     c                   eval      $dridata2 = $pprod2
     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                             or $dricommand = '*PROD'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   eval      $pprod2 = $dridata2
     c                   endsl

     c                   return

     p prZzzDriCop     e

     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Item Not Found In Dakota. Not Adjusted.
Alias Link Rcd Missing. Not Adjusted.
Slot Not Found. Not Adjusted.
Item Verify Failed. Not Adjusted.
Item Adjustment Not Posted.
DRI Interface Error. Slot Not Found.
Adj Code Not Found, Not Adjusted.
Quantity is Zero, Not Adjusted.
Warehouse Not Found, Not Adjusted.
DRI Interface Error.
Parent for JIT Rpk missing.Not Adjusted.
