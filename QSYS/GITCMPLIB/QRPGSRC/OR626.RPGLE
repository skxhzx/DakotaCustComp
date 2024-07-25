      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  OR626     Truck build - Accumulate totals by compartment.
     *  16 February 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    02/16/02  MLB  4.16
     *      - Created.
     *
500 A*    04/21/05  MLB  5.00
     *      - Fix: Revise ZZCALC to update dock door department
     *        if different from dock door dept in file.
     *
640 A*    05/01/12  RBD  6.40
     *      - Converted to ILE.
     *      - Fix: Added new command *SUBITEM for updating RTECSUM
     *        at pallet and transaction level for substitute items.
     *        Before this fix, sub items were causing RTECSUM to be
     *        updated multiple times for the same pallet/tran because
     *        the logic wasn't written to handle there being more than
     *        1 transaction per pallet in PLTSUM, which is the case
     *        for subbed items.
750 A*    07/14/21  KDE  7.50
     *      - Enh:  Changes to support DD2 and overriding Dock Door
     *        loading method
     *
     *----------------------------------------------------------------
     * Notes:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   if   e           k disk
     F                                     rename(psrec:psrec3)
640 AFpltsum12  if   e           k disk
640 AF                                     rename(psrec:psrec12)
     Fworklbl6  if   e           k disk
     F                                     rename(lwrec:lwrec6)
     Frtecsum   uf a e           k disk
     Ftrkcomp   if   e           k disk
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D forevr          s              1
     D kytype          s                   like(pstype)
     D svcomp          s                   like(pscomp)
750 Ad tbEnhanced      s               n
750 Ad tbPalletType    s              1
750 Ad tbType          s              1

750 A*----------------------------------------------------------------
750 A*  Called Programs Prototypes
750 A*----------------------------------------------------------------
750 Ad/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD2  *ALOCBLD - Allocate and build
     *              *PCKPRNT - Pick and print
     *              *REBUILD - Rebuild
640 A*              *SUBITEM - Subbed item, pallet & tran passed in.
     *              *ALL     - Do all phases without pausing after build.
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PTRUK  Truck
640 A*      $PPLID  Pallet id
640 A*      $PTRN   Transaction
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd2            8
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10
     C                   parm                    $pplid            7 0
     C                   parm                    $ptrn             7 0
     *----------------------------------------------------------------
     *  Main line
     *
     C                   select
     C                   when      $pcmd2 = '*REBUILD'  or
     C                             $pcmd2 = '*ALL    '
     C                   exsr      clrtot
     C                   endsl
     *
640 AC                   select
640 AC                   when      $pcmd2 = '*SUBITEM'
640 AC                   exsr      subItemUpd
640 AC                   goto      endSubItem
640 AC                   endsl
     *
     *    Loop if no normal, merge or bulk label records exist for zone.
     *
     C                   move      *loval        svcomp
750 DC*                  eval      kytype = 'O'
750 MC                   eval      kytype = tbPalletType
     C     keyps3        setll     pltsum3
     C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                              7879
     C                   select
     C                   when      *in79
     C                   leave                                                  Exit loop
     *
     C                   when      *in78  or
     C                             pspcs = 0  or
     C                             psgen > 1
     C                   iter
     *
     C                   other
     *
     *    Get new compartment master everytime compartment changes.
     *
     C                   if        pscomp <> svcomp
     C     keytp         chain     trkcomp                            76
     C                   if        *in76
     C                   eval      tpdesc = *blanks
     C                   eval      tpdrdp = *blanks
     C                   endif
     *
     C                   eval      svcomp = pscomp
     C                   endif
     *
     *    Read label detail to accumulate total in each compartment.
     *
     C     keylw6        setll     worklbl6
     C                   dow       forevr = forevr
     C     keylw6        reade     worklbl6                               77
     C                   select
     C                   when      *in77
     C                   leave                                                  Exit loop
     *
     C                   when      lwqalc <= *zeros  or
     C                             lwtype <> 'O'  and
     C                             lwtype <> 'M'
     C                   iter                                                   Next item
     *
     C                   other
     *
     C                   exsr      zzcalc
     C                   endsl
     C                   enddo
     *
     C                   endsl
     C                   enddo
     *
640 AC     endSubItem    tag
     *
     * Close up shop and return home.
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define partial key for WORKLBL6 file.
     *
     C     keylw6        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     *
640 A*  Define key for PLTSUM12 file.
640 A*
640 AC     keyps12       klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    $prtid
640 AC                   kfld                    $ptrn
640 AC                   kfld                    $pplid
     *
     *  Define full key for RTECSUM file.
     *
     C     keyrc         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    pscomp
     *
     *  Define partial key for RTECSUM file.
     *
     C     keyrc1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define full key for TRKCOMP file.
     *
     C     keytp         klist
     C                   kfld                    $pwhse
     C                   kfld                    pscomp
     *
     *  Define variables.
     *
     C                   eval      forevr = *on
750 Ac*
750 Ac*   Determine if using TruckBUilder Enhanced
750 Ac*
750 A /free
750 A      GetTBType($pwhse: $prtid: tbType);
750 A      if tbType = 'E';
750 A        tbEnhanced = *on;
750 A        tbPalletType = 'P';
750 A      else;
750 A        tbEnhanced = *off;
750 A        tbPalletType = 'O';
750 A      endif;
750 A /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRTOT  Clear compartment totals on truck rebuild.
     *
     C     clrtot        begsr
     *
     C     keyrc1        setll     rtecsum
     C                   dow       forevr = forevr
     C     keyrc1        reade     rtecsum                                79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     C                   eval      rcdrdp = *blanks
     C                   eval      rcpckc = *zeros
     C                   eval      rcpckw = *zeros
     C                   eval      rcpckp = *zeros
     C                   update    rcrec
     C                   endsl
     C                   enddo
     *
     C                   endsr
640 A*----------------------------------------------------------------
640 A*
640 A*  subItemUpd  Subbed Items :
640 A*              Update compartment summary for the subbed item's
640 A*              specific pallet and transaction.
640 A*
640 AC     subItemUpd    begsr

     C     keyps12       chain     pltsum12

     C                   if        not %found
     C                             or pspcs = 0
     C                             or psgen > 1
     C                   goto      endSubItemUpd
     C                   endif

     *    Get compartment master.
     *
     C     keytp         chain     trkcomp
     C                   if        not %found
     C                   eval      tpdesc = *blanks
     C                   eval      tpdrdp = *blanks
     C                   endif
     *
     *    Read label detail to accumulate total in each compartment.
     *
     C     keylw6        setll     worklbl6
     C                   dow       forevr = forevr
     C     keylw6        reade     worklbl6
     C                   select
     C                   when      %eof
     C                   leave                                                  Exit loop
     *
     C                   when      lwtrn# <> $ptrn or
     C                             lwqalc <= *zeros or
     C                             lwtype <> 'O'  and
     C                             lwtype <> 'M'
     C                   iter                                                   Next item
     *
     C                   other
     *
     C                   exsr      zzcalc
     C                   endsl
     C                   enddo

     C     endSubItemUpd endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC  Accumulate pick totals by compartment.
     *
     C     zzcalc        begsr
     *
     C     keyrc         chain     rtecsum                            76
     C                   select
     C                   when      *in76
     C                   eval      rcwhse = $pwhse
     C                   eval      rcrtid = $prtid
     C                   eval      rccomp = pscomp
     C                   eval      rcdrdp = tpdrdp
     C                   eval      rcpckw = lwswgt
     C                   eval      rcpckp = lwqalc
     C                   eval      rcpckc = lwcube
750 Ac                   if        rcdrdp = *blanks
750 Ac                   eval      rcdrdp = lwwhdp
750 Ac                   endif
     *
     C                   write     rcrec
     *
     C                   when      not *in76
     *
     C                   if        rcdrdp = *blanks  or
500 AC                             tpdrdp <> rcdrdp
     C                   eval      rcdrdp = tpdrdp
750 Ac                   if        rcdrdp = *blanks
750 Ac                   eval      rcdrdp = lwwhdp
750 Ac                   endif
     C                   endif
     *
     C                   add       lwswgt        rcpckw
     C                   add       lwqalc        rcpckp
     C                   add       lwcube        rcpckc
     *
     C                   update    rcrec
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
