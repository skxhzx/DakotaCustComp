     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT739     FTP Export item quantities w/Sign - Post
     *  11 December 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  This program should be identical to IT735 except that it uses
     *  the EXPFQTY2 file that is overridden in IT739CL.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*   12/11/09  MLB  5.30
     *     - Created.
     *       Client custom code support included.
     *
     *----------------------------------------------------------------
530 A*  Client Custom Revisitons:  Crumbley Paper & Foodservice
530 A*   11/09/11  RH   CPCa
     *     - Revised program to convert cases into total eaches
     *       on hand for item that are defined Case/Each from same item
     *       # and brkdwn 1 UoM > blanks and Brkdwn 1 Qty > 0 and
     *       Allow entry flag 1 = Y.  Dakota WMS neeeds to send back
     *       to Dynamics GP, the total qty on hand in Eaches (like IT736)
CPCbA*   06/08/12  RH   CPCb
     *     - Revised program to get base slot for virutal slot
     *     - Add VSLOT1 to program.
     *----------------------------------------------------------------
     *  Indicator usage
     *
CPCbA*  74        NRF on chain to VSLOT1
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
     Fitemqty   if   e           k disk
     Fitemlnk   if   e           k disk
     Fslot3     if   e           k disk
     Fitemdef   if   e           k disk
     Fslotdef   if   e           k disk
CPCbAFvslot1    if   e           k disk
     Fexpfqty2  o  a e           k disk
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
      /copy qcopysrc,id#cpc
     *
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D forevr          s              1
     D kyitem          s                   like(slitem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D scount          s              1  0
     D today           s              8  0
cpcaAD wkqty           s                   like(iqstk1)
     D wkstk1          s                   like(iqstk1)
     D wkstk2          s                   like(iqstk2)
     D wkstk3          s                   like(iqstk3)
     *
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
     C                   move      $pwhs         $pwhse
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
     C                   if        ittype = 'A'  or
     C                             ittype = 'C'  and
     C                             $pincl <> 'Y'
     C                   iter
     C                   endif
     *    Skip type'S' items, qty will be included with parent item.
     *
     C**                 if        client = cccccccccc  and
     C**                           ittype = 'S'
     C**                 iter
     C**                 endif
     *
     *    Record accepted for Export.
     *
     C                   clear                   qerec
     C                   eval      qewhse = itwhse
     C                   eval      qeitem = ititem
     C                   eval      qewhdp = itwhdp
     C                   eval      qetype = ittype
     C                   eval      qecube = itcube
     C                   eval      wkstk1 = 0
     C                   eval      wkstk2 = 0
     C                   eval      wkstk3 = 0
     *
     *    Get corresponding base item.
     *
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   if        ittype <> ' '
     C     keyil         chain     itemlnk                            78
     C                   if        *in78
     C                   clear                   ilitm2
     C                   clear                   ilitm3
     C                   endif
     C                   endif
     C                   eval      qebitm = ilitm2
     C                   eval      qecitm = ilitm3
     *
     *  Get item stock quantity.
     *
     C                   exsr      getqty
     *
     *  Get pick slots for item (max of 3)
     *
     C                   exsr      getpck
     *
     *  Add export record
     *
     C                   eval      qedate = today
     C                   time                    qetime
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
     *
     *  Get client id
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    clientloc        10
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
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
CPCb *  Define full key for VSLOT1 file.
CPCb *
CPCb C     keyvs1        klist
CPCb C                   kfld                    itwhse
CPCb C                   kfld                    slwhdp
CPCb C                   kfld                    sldisp
     *
     *  Define key for SLOTDEF file.
     *
     C     keysd         klist
     C                   kfld                    slwhse
     C                   kfld                    slsdef
     *
     *  Define key for ITEMDEF file.
     *
     C     keyid         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   kfld                    slsdef
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
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
     C                             ittype = 'S'
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   endif
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
     C                   endif
     *
CPCb *
CPCbAC                   if        client = CPC
   b *     Get base slot for virutal to send to host.
CPCbAC                   if        slrsrv = 'V'
CPCb C     keyvs1        chain     vslot1                             74
CPCb C                   if        *in77 = '0'
CPCb C                   eval      sldisp = vspdis
CPCb C                   endif
CPCb C                   endif
CPCb C                   endif
CPCb *
     *     Get slot definition information.
     *
     C     keysd         chain     slotdef                            77
     C                   if        *in77
     C                   clear                   sdpal
     C                   clear                   sdpos
     C                   endif
     *
     *     Get item tie/high information.
     *
     C     keyid         chain     itemdef                            77
     C                   if        *in77
     C                   clear                   idtie
     C                   clear                   idhigh
     C                   endif
     *
     *     Add to item's slots
     *
     C                   add       1             scount
     C                   select
     C                   when      scount = 1
     C                   eval      qedsp1 = sldisp
     C                   eval      qesdf1 = slsdef
     C                   eval      qeti1 = idtie
     C                   eval      qehi1 = idhigh
     C                   eval      qepos1 = sdpos
     C                   eval      qepal1 = sdpal
     C                   when      scount = 2
     C                   eval      qedsp2 = sldisp
     C                   eval      qesdf2 = slsdef
     C                   eval      qeti2 = idtie
     C                   eval      qehi2 = idhigh
     C                   eval      qepos2 = sdpos
     C                   eval      qepal2 = sdpal
     C                   when      scount = 3
     C                   eval      qedsp3 = sldisp
     C                   eval      qesdf3 = slsdef
     C                   eval      qeti3 = idtie
     C                   eval      qehi3 = idhigh
     C                   eval      qepos3 = sdpos
     C                   eval      qepal3 = sdpal
     C                   leave
     C                   endsl
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETQTY  Get quantity for item
     *
     C     getqty        begsr
     *
     *  If SSB item
     *   Then get qty for Base item
     *   Otherwise use record item and check for existance of SSB item.
     *
     C                   if        ittype = 'S'
     C                   eval      kyitem = ilitm2
     C                   else
     C                   eval      kyitem = ititem
     C                   call      'CHKSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm                    $gexst            1
     C                   endif
     *
     *  Get stock quantity for item.
     *
     C     keyiq         chain     itemqty                            79
     C     *in79         cabeq     *on           endqty
     *
     C                   select
     *
     *      Same Slot Breakdown item uses the bkdn 1 & 2
     *      of the Base item's quantities.
     *
     C                   when      ittype = 'S'
     C                   eval      qestk1 = '  ' + %editc(iqstk2:'L' )
     C                   eval      wkstk1 = iqstk2
     C                   eval      qestk2 = %editc(iqstk3:'L')
     C                   eval      wkstk2 = iqstk3
     C                   eval      wkstk3 = 0
     C                   eval      qestk3 = %editc(wkstk3:'L')
     *
     *     For cccccccccc, send type 'S' item quantity with parent item.
     C**                 when      client = cccccccccc
     C**                           and $gexst = 'Y'
     C**                 eval      qestk1 = %editc(iqstk1:'L')
     C**                 eval      wkstk1 = iqstk1
     C**                 eval      qestk2 = %editc(iqstk2:'L')
     C**                 eval      wkstk2 = iqstk2
     C**                 eval      wkstk3 = 0
     C**                 eval      qestk3 = %editc(wkstk3:'L')
     *
     *      If an item has a Same Slot Breakdown item
     *       then use only the Normal quantity.
     *
     C                   when      $gexst = 'Y'
     C                   eval      qestk1 = %editc(iqstk1:'L')
     C                   eval      wkstk1 = iqstk1
     C                   eval      wkstk2 = 0
     C                   eval      qestk2 = %editc(wkstk2:'L')
     C                   eval      wkstk3 = 0
     C                   eval      qestk3 = %editc(wkstk3:'L')
     *
     *      Otherwise take quantities as they are.
     *
     C                   other
CPCa *
CPCa C                   if        client = CPC
CPC A*      Convert into Total Eaches and load into OEDQ1.
CPCa C                   if        itum2 > ' ' and
CPCa C                             itumq2 > 0  and
CPCa C                             itflg1 = 'Y'
CPCa C                   eval      wkqty = iqstk1 * itumq2
CPCa C                   eval      qestk1 = %editc(iqstk2 + wkqty:'L')
CPCa C                   else
CPCa C                   eval      qestk1 = %editc(iqstk1:'L')
CPCa C                   endif
CPCa C                   eval      qestk2 = *blanks
CPCa C                   else
     C                   eval      qestk1 = %editc(iqstk1:'L')
     C                   eval      wkstk1 = iqstk1
     C                   eval      qestk2 = %editc(iqstk2:'L')
     C                   eval      wkstk2 = iqstk2
     C                   eval      qestk3 = %editc(iqstk3:'L')
     C                   eval      wkstk3 = iqstk3
CPCa C                   endif
     *
     C                   endsl
     *
     *  Reduce qty by corresponding Contract qty's if that
     *    is what the user wants.
     *
     C                   if        $pincl = 'Y'  and
     C                             $prflg = 'Y'
     *
     C                   call      'GETCON'
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm                    $gcnt             3 0
     C                   parm                    $gqty1            5 0
     C                   parm                    $gqty2            5 0
     C                   parm                    $gqty3            5 0
     *
     C                   if        $gcnt > 0
     C                   eval      qerflg = 'Y'
     *
     C                   if        wkstk1 > $gqty1
     C                   eval      wkstk1 = wkstk1 - $gqty1
     C                   eval      qestk1 = %editc(wkstk1:'L')
     C                   else
     C                   eval      wkstk1 = 0
     C                   eval      qestk1 = %editc(wkstk1:'L')
     C                   endif
     *
     C                   if        wkstk2 > $gqty2
     C                   eval      wkstk2 = wkstk2 - $gqty2
     C                   eval      qestk2 = %editc(wkstk2:'L')
     C                   else
     C                   eval      wkstk2 = 0
     C                   eval      qestk2 = %editc(wkstk2:'L')
     C                   endif
     *
     C                   if        wkstk3 > $gqty3
     C                   eval      wkstk3 = wkstk3 - $gqty3
     C                   eval      qestk3 = %editc(wkstk3:'L')
     C                   else
     C                   eval      wkstk3 = 0
     C                   eval      qestk3 = %editc(wkstk3:'L')
     C                   endif
     *
     C                   endif
     *
     C                   endif
     *
     C     endqty        endsr
