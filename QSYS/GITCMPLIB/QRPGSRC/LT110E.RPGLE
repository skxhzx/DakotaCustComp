      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LT110E    Create Repack Priority replenishments - Phase 2
     *            Select and sort.
     *
     *  Jeffrey Jahnke
     *  07 March  2007
     *
     *  Revisions
     *
510 A*    03/07/07  JCJ  5.10 A
     *      - just call DRIPRTYRPL once for each parent linked to
     *        repack items.
     *
650aA*    04/03/13  KDE  6.50a
     *      - passed slot from Work Order to ensure the one and only
     *        one slot is replenished that was setup for this
     *        particular work order
     *
650bA*    05/13/13  KDE  6.50b
     *      - changed to create replenishment for sum of all normal
     *        and the two breakdown quantities.  Currently doing
     *        which one shows first
     *
650cA*    05/20/13  KDE  6.50c
     *      - changed consider new output quantities defined in
     *        KITITEM to determine replenishment quantity
     *
650dA*    06/07/13  KDE  6.50d
     *      - several changes allowinng on-demand to call on-demand
     *        repack items
     *
650eA*    08/25/14  KDE  6.50e
     *      - modify to work with LT110CL.  Rebuild of Priority
     *        Replenishment file
     *
700 A*    04/21/15  KDE  7.00
     *      - Enh: Modify to determine Average Sales demand for On
     *        Demand Repack Items.
     *
710 A*    09/01/17  KDE  7.10
     *      - Fix: Set INLR to always end
     *
740 A*    07/01/20  KDE  7.40
     *      - Enh: Modify to reduce need by available stock in RPK
     *        slot for Work Order Repacks
     *
740aA*    09/24/20  JCJ/KDE 740a
     *      - set outputqty to 1 if kiqty1 is 0.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fkitcomp1  if   e           k disk
650cAFkititem   if   e           k disk
     Fkitordh3  if   e           k disk
650dAFkitordd   if   e           k disk
     Fpiritem   if   e           k disk
700 Afslot12    if   e           k disk
     Fprplfil4  if   e           k disk

     D                 ds
650cDD* wopqndec               1      5  2
650cDD* dec                    4      5  0
650cMD  wopqndec               1     15  2
650cMD  dec                   14     15  0

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PRTYRPL
      /COPY *libl/qcopysrc,C#ITEM
740 A /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($prver#)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#STDVAR

     *----------------------------------------------------------------
     *  Work Variables
     *----------------------------------------------------------------

700 Ad avgpct          s              5  2
650cDD*prqtyn          s              7  0
650cAD prqtyn          s             15  2
700 AD prqtynodr       s             15  2
650cAD outputqty       s              5  0
740 DD*$saqty1         s              5  0
740 DD*$saqty2         s              5  0
740 DD*$saqty3         s              5  0
650daD*wopqn           s              3  0
     D pwhse           s              3  0
     D pccitm          s             15
     D $prplb          s              8
     D $prtn           s              8
     D $pwhdp          s              5
     D $pwhsa          s              3
     D $pslt           s             12
     D #ititem         s                   like($ititem)
     D #kohqty         s                   like(kohqty)
     D #kidisp         s                   like(kidisp)
     D chk4err         s               n
     D #ittype         s                   like($ittype)
     D #itwhdp         s                   like($itwhdp)
     D ck4err          s               n
700 Ad woReplen        s               n
     D goodrecord      s              1
     D FirstPass       s              1
700 Ad kycode          s              8
     D drierr          s               n
     D zmsflag         s               n

     D $parentititem   s                   like($ititem)
     D #parentitwhse   s                   like($itwhse)
     D #parentititem   s                   like($ititem)
     D #parentittype   s                   like($ittype)
     D #parentitdesc   s                   like($itdesc)
     D #parentitpdsc   s                   like($itpdsc)
     D #parentithead   s             70
     D #parentitwhdp   s                   like($itwhdp)
     D #parentitstyp   s                   like($itstyp)
     D #parentitdesg   s                   like($itdesg)
     D #parentitum1    s                   like($itum1)
     D #parentitflg1   s                   like($itflg1)
     D #parentitum2    s                   like($itum2)
     D #parentitumq2   s                   like($itumq2)
     D #parentitflg2   s                   like($itflg2)
     D #parentitum3    s                   like($itum3)
     D #parentitumq3   s                   like($itumq3)
     D #parentitnrpk   s                   like($imnrpk)
     D #parentitflgd   s                   like($itflgd)
     D #parentitcube   s                   like($itcube)
     D #parentitswgt   s                   like($itswgt)
     D #parentitcwgt   s                   like($itcwgt)
     D #parentitmitem  s                   like($itmitem)
     D #parentitsdef   s                   like($idsdef)
     D #parentittie    s                   like($idtie)
     D #parentithigh   s                   like($idhigh)
700 A
700 A*----------------------------------------------------------------
700 A*  *Repack  -  Repack options.
700 A*----------------------------------------------------------------
700 A*
700 A* Fields
700 A*
700 A*    OPPADJ  -  Repack Parent Adjustment code
700 A*    OPWADJ  -  Repack Waste Adjustment Code
700 A*    OPRADJ  -  Repack Item Adjustment Code
700 A*    OPRASL  -  Repack Work Order Aisle
700 A*    OPARPL  -  Generate On Demand Replenishments based AVGQTY
700 A*
700 A* Data structure
700 A*
700 AD opdata          ds
700 AD  oppadj                 1      2
700 AD  opwadj                 3      4
700 AD  opradj                 5      6
700 AD  oprasl                 7      9
700 AD  oparpl                10     10
700 AD  optend               117    117

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhsea  -  Warehouse
     *      $pwhdp   -  Department code or *ALL
     *      $prplb   -  Based on value
     *                  *ORDQTY - Ordered quantity (ITEMORD file)
     *                  *AVGQTY - Average sales (ITEMAVG file)
     *                  *AVGnnn - *AVGQTY plus nnn percent.
     *                  *RPLLVL - Item replenishment level.
     *
     *    Returned Parameters
     *      $prtn    -  Return code (not used)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhsa
     C                   parm                    $pwhdp
     C                   parm                    $prplb
     C                   parm                    $parentititem
650aAc                   parm                    $pslt
     C                   parm                    $prtn

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   exsr      zzinz

     C     kycomp1       setll     kitcomp1
     C                   dou       %eof(kitcomp1)

     C                   select
     C                   when      $parentititem = *blanks
     C     kycomp        reade     kitcomp1
     C                   when      $parentititem <> *blanks
     C     kycomp2       reade     kitcomp1
     C                   endsl

650dAc                   if        not %eof(kitcomp1)

650dAc                   if        kcdisp<>' '
650dAc                              and kcdisp<>$pslt
650eAc                              and $pslt <> '*LT110CL'
650dAc                   iter
650dAc                   endif

650dAc                   if        kcdisp=' '
650dAc                              and %subst($pslt:1:3)<>'RPK'
650eAc                              and $pslt <> '*LT110CL'
650dAc                   iter
650dAc                   endif

     * repack Y/N
     C                   exsr      zzgetrepackit

     C                   if        goodrecord = *on

      * Finished finding all repack items for a parent
      * Create rpl for previous repack
      * Get parent UOM for new repack

     C                   if        kccitm <> pccitm
700 Ac                   eval      woReplen = *on
     C                   exsr      createrpl
700 Ac                   eval      woReplen = *off
700 Ac                   eval      prqtyn = prqtynodr
700 AC                   exsr      createrpl
700 AC                   eval      prqtynodr = *zeros
700 AC                   eval      prqtyn = *zeros
700 Ac                   eval      #kidisp = *blanks
700 AC                   eval      pccitm = kccitm
     C                   exsr      zzgetparentit
     C                   eval      firstpass = 'N'
     C                   endif
     * add up repack qty
     C                   exsr      accumrplqty

     C                   endif
     C                   endif
     C                   enddo

     *  LR stuff - Finish by sorting the created replenishments.

     *  add up repack qty
     C                   if        firstpass = 'Y'
     C                   if        prqtyn = *zeros
     C                             and prqtynodr = *zeros
     C                   exsr      accumrplqty
     C                   endif
     C                   endif

740 Ac                   exsr      getRepack
700 Ac                   if        prqtyn <> *zeros
     C                   exsr      createrpl
700 Ac                   endif

700 Ac                   if        prqtynodr <> *zeros
700 Ac                   eval      prqtyn = prqtynodr
700 Ac                   eval      woReplen = *off
700 AC                   exsr      createrpl
700 Ac                   endif
     C                   exsr      sortrpl
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *            SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  accumrplqty   accumulate repack order quantity
     *----------------------------------------------------------------

     C     accumrplqty   begsr

700 A*  if being called from Replenishment CL LT110CL and the
700 A*  Avg Sales Repack Replenishment flag not Yes then skip
700 Ac                   if        $pslt = '*LT110CL' and oparpl<>'Y'
700 Ac                   goto      skiprec
700 Ac                   endif
700 Ac                   eval      outputqty = 1
650cA*  code to capture new output quantity for repack items
650cA*  only allow entry into quantity 1 for now per Dave
650cA*  used later in CREATERPL routine to request replenishment
650cA*  qty where requested amount is divided by output qty
650cAC     kyordh        chain     kititem
650cAc                   if        not %error
650cAc                   if        %found
740aAc                   if        kiqty1 = 0
740aAc                   eval      outputqty = 1
740aAc                   else
650cAc                   eval      outputqty=kiqty1
740aAc                   endif
700 Ac                   if        kidisp <> *blanks
700 Ac                   if        kidisp <> #kidisp
700 Ac                              and #kidisp <> *blanks
700 Ac                   goto      skiprec
700 Ac                   endif
700 Ac*  verify on demand slot is good
700 A /free
700 A                    chain (#parentitwhse:kidisp:#parentitwhdp) slot12;
700 A /end-free
700 Ac                   if        not %found(slot12) or slstat <> 'RP'
700 Ac                   goto      skiprec
700 Ac                   endif
700 Ac*
700 Ac                   eval      #kidisp = kidisp
700 Ac                   endif
650cAc                   endif
650cAc                   endif
650cA*  rollup quantity requirement to lowest level for work order
650cA*  only.  On-Demand jobs will handle replenishments from Repack
650cA*  base slot..Check parent item
700 DC*    keyrpl        chain     kititem
700 Ac                   if        kirptp = '1'
650cA
700 Ac                   eval      #kohqty = 0
     C     kyordh        setll     kitordh3
     C                   dou       %eof(kitordh3)
     C     kyordh        reade     kitordh3
     C                   if        not %eof(kitordh3)
650dAc                              and kohsta <> '4'

650cA /free
650dA    #kohqty = kohqty;
650dA    setll (kohwhs:kohord:kohitm) kitordd;
650dA    reade (kohwhs:kohord:kohitm) kitordd;
650dA    dow not %eof;
650dA       #kohqty = #kohqty - kohqty;
650dA       reade (kohwhs:kohord:kohitm) kitordd;
650dA    enddo;
650dA    if #kohqty < 0;
650dA       #kohqty = 0;
650dA    endif;
650cA /end-free
700 A*
700 A*  get Average Sales if they exist for item
700 A*  but only if no work order was found for
700 A*  this repack.  Otherwise you can doulbe demand
700 A*
700 A /free
700 A           if #kohqty = 0;
700 A              eval savever# = $prver#;
700 A              clear $prtyrpl;
700 A              eval $prver# = savever#;
700 A              $prqtyn = 0;
700 A              $prwhse  = kiwhse;
700 A              $pritem  = kiitem;
700 A              $dricommand = '*PRTYRPL';  // cal getqtyneeded in DRIPRTY
700 A              $drisubcmd = '*AVGPRD';
700 A              $drisys2upd = 'D';
700 A              exsr zzzDriCop;
700 A              // Average Sales
700 A              #kohqty = #kohqty + $prqtyn;
700 A           endif;

650cA    select;
650cA       when #parentitumq3<>0;
650cA          wopqndec = (kcqty1 * #parentitumq2
650cA                        * #parentitumq3) +
650cA                     (kcqty2 * #parentitumq3) +
650cA                      kcqty3;
740aA          monitor;
650cA          wopqndec = (wopqndec / outputqty);
740aA          on-error;
740aA          endmon;
650cA          prqtyn = prqtyn + (#kohqty*wopqndec);

650cA       when #parentitumq2<>0;
650cA          wopqndec = (kcqty1 * #parentitumq2) +
650cA                      kcqty2;
740aA          monitor;
650cA          wopqndec = (wopqndec / outputqty);
740aA          on-error;
740aA          endmon;
650cA          prqtyn = prqtyn + (#kohqty*wopqndec);

650cA       other;
740aA          monitor;
650cA          wopqndec = (kcqty1 / outputqty);
740aA          on-error;
740aA          wopqndec = kcqty1;
740aA          endmon;
650cA          prqtyn = prqtyn + (#kohqty*wopqndec);

650cA    endsl;
      /end-free
650cMC*                  select
650cMC*                  when      kcqty1 > *zeros
650cMC*                  eval      prqtyn = prqtyn + (kohqty * kcqty1)

650cMC*                  when      kcqty2 > *zeros
650cMC*                  eval(h)   wopqndec= (kohqty * kcqty2)
650cMC*                                      / #parentitumq2
650cMC*                  eval      wopqn = wopqndec
650cMC*                  if        dec >= 01
650cMC*                  eval      wopqn   = wopqn + 1
650cMC*                  endif
650cMC*                  eval      prqtyn = prqtyn + wopqn

650cMC*                  when      kcqty3 > *zeros
650cMC*                  eval(h)   wopqndec= (kohqty * kcqty3)
650cMC*                                      / (#parentitumq2
650cMC*                                          * #parentitumq3)
650cMC*                  eval      wopqn = wopqndec
650cMC*                  if        dec >= 01
650cMC*                  eval      wopqn   = wopqn + 1
650cMC*                  endif
650cMC*                  eval      prqtyn = prqtyn + wopqn
650cMC*                  endsl

     C                   endif
     C                   enddo
700 A /free
700 A                    else;
700 A     // Accumulate On Demand Repacks for Replenishment
700 A     // if Repack setting is Yes (OPARPL)
700 A                    if %found(kititem) and kidisp<>*blanks
700 A                        and oparpl = 'Y' and $pslt='*LT110CL';
700 A                       exsr accumODR;
700 A                    endif;
700 A /end-free
     C                   endif

     C     skiprec       endsr

     *----------------------------------------------------------------
     *  accumodr   accumulate repack demand from average sales
     *----------------------------------------------------------------

     C     accumodr      begsr
700 A*
700 A*  get Average Sales for On Demand Repack Item from command
700 A*  *AVGPRD from DRIPRTYRPL.  Using command created for
700 A*  Production that simply determines Average Sales and returns
700 A*  without any other action. This routine is simply called to
700 A*  accumulate Parent totals across all repacks tied to this
700 A*  parent to make the total replen required
700 A*
700 A /free
700 A              eval savever# = $prver#;
700 A              clear $prtyrpl;
700 A              eval $prver# = savever#;
700 A              $prqtyn = 0;
700 A              $prwhse  = kiwhse;
700 A              $pritem  = kiitem;
700 A              $dricommand = '*PRTYRPL';  // cal getqtyneeded in DRIPRTY
700 A              $drisubcmd = '*AVGPRD';
700 A              $drisys2upd = 'D';
700 A              exsr zzzDriCop;
700 A              // Average Sales
700 A              #kohqty = $prqtyn;

700 A    select;
700 A       when #parentitumq3<>0;
700 A          wopqndec = (kcqty1 * #parentitumq2
700 A                        * #parentitumq3) +
700 A                     (kcqty2 * #parentitumq3) +
700 A                      kcqty3;
700 A          wopqndec = (wopqndec / outputqty);
700 A          prqtynodr = prqtynodr + (#kohqty*wopqndec);

700 A       when #parentitumq2<>0;
700 A          wopqndec = (kcqty1 * #parentitumq2) +
700 A                      kcqty2;
700 A          wopqndec = (wopqndec / outputqty);
700 A          prqtynodr = prqtynodr + (#kohqty*wopqndec);

700 A       other;
700 A          wopqndec = (kcqty1 / outputqty);
700 A          prqtynodr = prqtynodr + (#kohqty*wopqndec);

700 A    endsl;
700 A /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  createrpl
     *----------------------------------------------------------------

     C     createrpl     begsr

650cA*  up accumulated quantities before creating replenishment

650cA /free
650cA    select;
650cA       when #parentitumq3<>0;
650cA          $saqty1 = 0;
650cA          $saqty2 = 0;
650cA          $saqty3 = prqtyn;
650cA
650cA       when #parentitumq2<>0;
650cA          $saqty1 = 0;
650cA          $saqty3 = 0;
650cA          $saqty2 = prqtyn;
650cA
650cA          other;
650cA          $saqty1 = prqtyn;
650cA          $saqty2 = 0;
650cA          $saqty3 = 0;
650cA    endsl;
650cA
650cA /end-free

650cAc                   exsr      zzUpqty

650cAc                   select
650cAc                   when      $saqty1 <> 0
650cAc                   eval      prqtyn = $saqty1
650cAc                   if        $saqty2<>0 or $saqty3<>0
650cAc                   eval      prqtyn = prqtyn + 1
650cAc                   endif

650cAc                   when      $saqty2<>0 or $saqty3<>0
650cAc                   eval      prqtyn = 1

650cAc                   other
650cAc                   eval      prqtyn = 0

650cAc                   endsl

     C                   exsr      clr$prtyrpl

650cDC*                  if        prqtyn <> *zeros
650cAC                   if        prqtyn > *zeros

     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = kcwhse

     C                   eval      $pritemu = *on
     C                   eval      $pritem  = pccitm

650eAc                   if        $pwhdp = '*ALL'
650eAC                   eval      $prwhdpu = *on
650eAC                   eval      $prwhdp  = #parentitwhdp
650eAc                   else
     C                   eval      $prwhdpu = *on
     C                   eval      $prwhdp  = $pwhdp
650eAc                   endif

650aAc                   if        $pslt   <> ' '
650eAc                              and $pslt <> '*LT110CL'
650aMC                   eval      $prslotu = *on
650aMC                   eval      $prslot = $pslt
650aAc                   else
650aMC                   eval      $prslot = ' '
650aAC                   eval      $prslotu = *off
650aAc                   endif
700 Ac*  pass on demand slot when doing replenishment for on demand
700 Ac                   if        not woReplen
700 AC                   eval      $prslotu = *on
700 AC                   eval      $prslot = #kidisp
700 Ac                   endif
650aDC*                  eval      $prslot  = *blanks

     C                   eval      $prqtynu = *on
     C                   eval      $prqtyn  = prqtyn

     *   Note, DRIPRTYRPL will determine if slot is filled to needed qty.

     C                   eval      $dricommand = '*PRTYRPL'
700 Ac                   if        $pslt = '*LT110CL'
700 Ac*  send different command to trap that it is coming from LT110CL.  These r
700 Ac*  be deleted each time priority replenishments are generated
700 AC                   eval      $drisubcmd  = '*CRTRPLPH3'
700 Ac                   else
     C                   eval      $drisubcmd  = '*CRTRPLPH2'
700 Ac                   endif

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
650dAc                   if        $drimessage =
650dAc                              'No full cases available'
650dAc                   endif
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzgetrepackit  Get repack item
     *----------------------------------------------------------------

     C     zzgetrepackit begsr

     *  get item

     C                   exsr      clr$item
     C                   eval      $itwhse  = kcwhse
650dAC                   eval      $ittypeu = *on
650dAC                   eval      $ittype  = 'R'
650dAC                   eval      $itwhdpu = *on
650dAC                   eval      $itwhdp  = $pwhdp
650dAC                   eval      $ititem  = kcitem

     C                   eval      goodrecord = *on

     C                   eval      $dricommand = '*ITEM'
650dMC*                  eval      $drisubcmd  = '%GETALL'
650dAC                   eval      $drisubcmd  = '%GETPARENT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   clear                   #ititem
     C                   clear                   #ittype
     C                   clear                   #itwhdp
     C                   goto      enditm
     C                   endif

     C                   eval      #ititem = $ititem
     C                   eval      #ittype = $ittype
     C                   eval      #itwhdp = $itwhdp

     C                   select
     C                   when      $pwhdp = '*ALL'
     C                   eval      goodrecord = *on
     C                   when      $pwhdp <> #itwhdp
     C                   eval      goodrecord = *off
     C                   endsl

     C                   if        #ittype <> 'R'
     C                   eval      goodrecord = *off
     C                   endif

     C     enditm        endsr

     *----------------------------------------------------------------
     *  ZZGETPARENTIT   Get Parent item
     *----------------------------------------------------------------

     C     zzgetparentit begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = kcwhse
650dAC                   eval      $ittypeu = *on
650dAC                   eval      $ittype  = ' '
650dAC                   eval      $itwhdpu = *on
650dAC                   eval      $itwhdp  = $pwhdp
650dAC                   eval      $ititem  = kccitm

     C                   eval      $dricommand = '*ITEM'
650dMC*                  eval      $drisubcmd  = '%GETALL'
650dAC                   eval      $drisubcmd  = '%GETPARENT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetparenti
     C                   endif

     C                   eval      #parentitwhse = $itwhse
     C                   eval      #parentititem = $ititem
     C                   eval      #parentittype = $ittype
     C                   eval      #parentitdesc = $itdesc
     C                   eval      #parentitpdsc = $itpdsc
     C                   eval      #parentitwhdp = $itwhdp
     C                   eval      #parentitstyp = $itstyp
     C                   eval      #parentitdesg = $itdesg
     C                   eval      #parentitum1  = $itum1
     C                   eval      #parentitflg1 = $itflg1
     C                   eval      #parentitum2  = $itum2
     C                   eval      #parentitumq2 = $itumq2
     C                   eval      #parentitflg2 = $itflg2
     C                   eval      #parentitum3  = $itum3
     C                   eval      #parentitumq3 = $itumq3
     C                   eval      #parentitnrpk = $imnrpk
     C                   eval      #parentitflgd = $itflgd
     C                   eval      #parentitcube = $itcube
     C                   eval      #parentitswgt = $itswgt
     C                   eval      #parentitcwgt = $itcwgt
     C                   eval      #parentitmitem = $itmitem
     C                   eval      #parentitsdef = ' '
     C                   eval      #parentittie  = 0
     C                   eval      #parentithigh = 0

     C     endgetparenti endsr

     *----------------------------------------------------------------
     *  sortrpl  Sort (sequence) replenishments
     *----------------------------------------------------------------

     C     sortrpl       begsr

     C                   exsr      clr$prtyrpl
     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = pwhse

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '*SEQPRTRPL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$prtyrpl  Clear $prtyrpl data structure fields
     *----------------------------------------------------------------

     C     clr$prtyrpl   begsr
     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM   '
     C                   eval      $dridata = $item
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl
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
     C                   when      $dricommand = '*ITEM   '
     C                   eval      $item    = $dridata
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzinz
     *----------------------------------------------------------------

     C     zzinz         begsr

710 Ac                   eval      *inlr=*on
     C                   move      $pwhsa        pwhse
     C                   eval      firstpass = 'Y'
700 A*
700 A*    Retrieve FS-WMS replenishment Repack options
700 A*
700 AC                   eval      kycode = '*REPACK '
700 AC     keyop         chain     options                            79
700 AC                   select
700 AC                   when      *in79
700 AC                   eval      oparpl = 'N'
700 AC                   endsl

     * retrieve first repack item

     C                   eval      goodrecord = *off
     C                   select
     C                   when      $parentititem = *blanks
     C     kycomp        setll     kitcomp1
     C                   when      $parentititem <> *blanks
     C     kycomp2       setll     kitcomp1
     C                   endsl

     C                   dou       %eof(kitcomp1)

     C                   select
     C                   when      $parentititem = *blanks
     C     kycomp        reade     kitcomp1
     C                   when      $parentititem <> *blanks
     C     kycomp2       reade     kitcomp1
     C                   endsl

     C                   if        not %eof(kitcomp1)
     C                   exsr      zzgetrepackit
     C                   if        goodrecord = *on
     C                   eval      pccitm = kccitm
     C                   exsr      zzgetparentit
     C                   leave
     C                   endif
     C                   endif
     C                   enddo

     C                   if        goodrecord = *off
     C                   return
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *  *inzsr
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    pwhse
     C                   kfld                    kycode

     C     kycomp        klist
     C                   kfld                    pwhse

     C     kycomp1       klist
     C                   kfld                    kcwhse
     C                   kfld                    kccitm
     C                   kfld                    kcitem

     C     kycomp2       klist
     C                   kfld                    pwhse
     C                   kfld                    $parentititem

     C     kyordh        klist
     C                   kfld                    kcwhse
     C                   kfld                    kcitem

     C     keyrpl        klist
     C                   kfld                    pwhse
     C                   kfld                    kccitm

     C                   endsr
650cA*----------------------------------------------------------------
650cA*  ZZUPQTY       Up quantity
650cA*----------------------------------------------------------------
650cA
650cAC     zzupqty       begsr


650cAC                   dow       #parentitumq3 > 0 and +
650cAC                               $saqty3 >= #parentitumq3
650cAC                   eval      $saqty3 -= #parentitumq3
650cAC                   eval      $saqty2 += 1
650cAC                   enddo
650cA
650cAC                   dow       #parentitumq2 > 0 and +
650cAC                               $saqty2 >= #parentitumq2
650cAC                   eval      $saqty2 -= #parentitumq2
650cAC                   eval      $saqty1 += 1
650cAC                   enddo
650cA
650cAC                   endsr
740 A*----------------------------------------------------------------
740 A*  getRepack  Get RPK slot for Work Order Repack
740 A*----------------------------------------------------------------
740 A
740 AC     getRepack     begsr
740 A
740 AC                   eval      savever# = $slver#
740 AC                   clear                   $slot
740 AC                   eval      $slver# = savever#
740 A
740 AC                   eval      $slwhseu = *on
740 AC                   eval      $slwhse  = kcwhse
740 A
740 AC                   eval      $slwhdpu = *on
740 AC                   eval      $slwhdp  = $itwhdp
740 A
740 AC                   eval      $slitemu = *on
740 AC                   eval      $slitem  = kccitm

740 AC                   eval      $sldispu = *on
740 AC                   eval      $sldisp  = *blanks
740 A
740 AC                   call(e)   'DRISLOT'
740 AC                   parm      '*GETREPACK'  $drisubcmd
740 AC                   parm      'LT110E'      $driprogram
740 AC                   parm      ' '           $drireturn
740 AC                   parm      ' '           $drimessage
740 AC     $slot         parm      $slot         $dridata
740 A
740 A /free
740 A    select;
740 A       when #parentitumq3<>0;
740 A
740 A     // substract available stock in Repack slot from demand
740 A          prqtyn = prqtyn - (($slavl1 * #parentitumq2
740 A                    *#parentitumq3) + ($slavl2 * #parentitumq3) +
740 A                     $slavl3);
740 A
740 A       when #parentitumq2<>0;
740 A
740 A     // substract available stock in Repack slot from demand
740 A          prqtyn = prqtyn - (($slavl1 * #parentitumq2)+$slavl2);
740 A
740 A       other;
740 A
740 A     // substract available stock in Repack slot from demand
740 A          prqtyn = prqtyn - $slavl1;
740 A
740 A    endsl;
740 A
740 A    if prqtyn<0;
740 A       prqtyn=0;
740 A    endif;
740 A
740 A
740 A /end-free
740 A
740 AC     endgetRepack  endsr
