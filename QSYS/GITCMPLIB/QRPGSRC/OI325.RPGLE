      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI325     Import FTP orders Ver 6 - Post
     *  17 May 2013
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    05/17/13  RTR  6.50
     *      - Created from OI315.
650aA*    06/14/13  MLB  6.50a  Was 5.30d in OI285.
     *      - Eliminated use of PODTL1 file as we no longer need to
     *        capture the po seq for the CROSSDK file.  Eventually
     *        the CROSSDK file will be eliminated altogether.
     *        This is possible because cross dock PO detail records
     *        will now be marked as 'XD' records in field PDSPCL.
     *      - Revised subr ZZXDCK to replace code which updates and
     *        writes slot records to instead use new subr ZZCRXD
     *        to call DRISLOT with %CRTXDOCK for all XD items and
     *        use %ALLOCATE to put the qty into the slot.
     *      - All commented code related to this mod was deleted from
     *        the pgm.
650bA*    06/20/13  MLB  6.50b  (Was 6.40 in OI285)
     *      - Fix: Revised program to use RTEHED2 when checking for
     *        Open routes. If a route was deleted, then re-imported
     *        the program was not finding the Open RTEHED rcd.
     *      - Fix: Revised program to correct duplicate key error
     *        when writing out ORDHM rcd for existing order.
     *      - Fix: Revised program to correct duplicate key error
     *        when writing out ORDDM rcd for existing order.
650cA*    06/20/13  MLB  6.50c  (Was 6.40a in OI285)
     *      - Fix: Revised program to move clearing of fields NEWRTE
     *        and NEWRTC. Fields were being cleared before they could
     *        be used by routine ZZCKR1.  This was causing a route header
     *        to be left behind with zero orders attached.
650dA*    06/20/13  MLB  6.50d  (Was 6.40c in OI285)
     *      - Enh: Revised program to set RHSHPD, position 8=5=Importing
     *        when RTEHED record is written to file. This is being done
     *        to prevent users from attempting to process route before
     *        all orders have been written out for the route.
650eA*    06/26/13  MLB  6.50e
     *      - Fix: Revised routine ZZCKOR to set WRGSTAT = 1 in correct
     *        place.  Was turning on WRGSTS when no order rcds found and
     *        preventing order from being added to existing open route.
650fA*    06/26/13  MLB  6.50f
     *      - Fix: Revised program to call RESEQSTP for Open Route when
     *        Merge Route flag is on. Orders added to existing route were
     *        not be requenced and assigned and internal order number.
650gA*    06/26/13  MLB  6.50g
     *      - Fix: Corrected 2 problems with XDK - Cross Dock processing.
     *        DRI interface was turning on error when order detail item
     *        found in active XDK slot which caused item to bypass XDK
     *        slot allocation. Second error was that if the XDK item
     *        processing was successful, it wasn't setting GOOD2 = Y
     *        which allows item to be added to customer order.
     *
720 A*    05/16/18  MLB  7.20
     *      - Fix: Revised program to populate RTSSD with contents of
     *        RTSST5. Correction to 7.10a mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    05/23/10  MLB  GFS
     *      - Revised pgm to convert order qty in fields OIDQ1, OIDQ2
     *        and OIDQ3 from "pounds ordered" into quantity ordered
     *        before being imported into Dakota TruckBuilder.
GFSaA*    06/08/10  MLB  GFSa
     *      - Change to above mod, GFS.  Changed pgm to store original
     *        pounds ordered in field ODOITM in positions 11-15 so
     *        that original pounds ordered can be exported to Host.
GFSbA*    07/26/10  MLB  GFSb
     *      - Change to above mod, GFS.  Changed pgm to check item to
     *        see if sold by Case/Each. Convert Ordered Pounds into
     *        Ordered Cases and Eaches.
GFScA*    06/14/13  MLB  GFSc
     *      - Enhancement to mod, GFS.  Revised program to check if
     *        item sold with Brkdwn1 = LB. If yes, convert Ordered
     *        Pounds into Ordered Cases and Eaches.
GFSdA*    06/28/13  MLB  GFSd
     *      - Revised program to not allow imported orders to be merged
     *        unless the Host Division Code in OIHMSC in 16-17 matches
     *        Host Division Code OHMISC in 16-17 in ORDH.
GFSeA*    06/28/13  MLB  GFSe
     *      - Enhancement to mod, GFS.  Revised program to check if
     *        item sold with Brkdwn2 = LB. If yes, convert Ordered
     *        Pounds into Ordered Cases and Eaches and Pound Units.
GFSfA*    07/23/13  MLB  GFSf
     *      - Fix to mod, GFSe.  Revised program to correct calculation
     *        of ordered Brkdwn1 qty only if Minimum Order Qty > 1.
     *        Was incorrectly converting ordered lbs into wrong order
     *        quantity.
GFSgA*    07/24/13  MLB  GFSg
     *      - Fix to mod, GFSe.  Revised program to correct calculation
     *        of ordered Brkdwn1 qty only if Minimum Order Qty > 1.
     *        Was incorrectly converting ordered lbs into wrong order
     *        quantity.
GFShA*    08/03/13  MLB  GFSh
     *      - Revised program to see if Brkdown1, Brkdown 2 ordered
     *        qty can be up-converted.
     *      - Revised f-spec for impfordd8, impforddm to add write
     *        capability.
GFSiA*    08/05/13  MLB  GFSi
     *      - Revised pgm to only allow up-qty conversion for items where
     *        GFSIKUPCV = Y.
     *      - Added file ITEMEXT1 to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFPa *    08/02/19  RTR  SFPa
     *      - Added Seashore to Packers logic to not delete header or
     *        detail records.
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there is only one route for one
     *    warehouse OR only one order in the member.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  67        - Open of IMPFORDHM8 or ORDDHM failed.
     *  68        - Open of IMPFORDDM8 or ORDDM failed.
     *  78        - EOF for IMPFORDD8
     *  79        - EOF for IMPFORDH8
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfordh8 uf   e           k disk
     Fimpfordhm8uf   e           k disk    usropn
GFShDF*impfordd8 uf   e           k disk
GFShMFimpfordd8 uf a e           k disk
GFShDF*impforddm8uf   e           k disk    usropn
GFShMFimpforddm8uf a e           k disk    usropn
     Fcustmisc  if   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
GFSiAFitemext1  if   e           k disk    usropn
     Fslot11    uf   e           k disk
     F                                     rename(slrec:slrec11)
     Frtesum    uf a e           k disk
     Fordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
     Fordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
     Foptions   if   e           k disk
     Frtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
650dMFrtehed2   uf   e           k disk
650bAF                                     rename(rhrec:rhrec2)
     Frtehed    o  a e           k disk
     Fordh      uf a e           k disk
     Fordhm     uf a e           k disk    usropn
     Fcrossdk   uf a e           k disk
     Fordd      o  a e           k disk
     Forddm     uf a e           k disk    usropn
     Frtestp    o  a e           k disk
     Foi325pr   o    e             printer oflind(*in91)
     F                                     usropn
     Foi3251pr  o    e             printer oflind(*in92)
     F                                     usropn
650aA
650aA*----------------------------------------------------------------
650aA*  DRI parameters
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#DRIPARMS
650aA
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA
650aA /COPY *libl/qcopysrc,C#ITEM
650aA /COPY *libl/qcopysrc,C#LICENSE
650aA /COPY *libl/qcopysrc,C#LICHIST
650aA /COPY *libl/qcopysrc,C#LICINFO
650aA /COPY *libl/qcopysrc,C#SLOT
650aA /COPY *libl/qcopysrc,C#XDOCK
GFShA /COPY *libl/qcopysrc,orddm2_gfs
GFSiA /copy *libl/qcopysrc,ikmsc1_gfs
650aA
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(6) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#PACKERS
CSP   /copy qcopysrc,id#Coastal
GFS   /copy qcopysrc,id#GFS
SFPa  /copy qcopysrc,id#sfp
     *
     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  optend               117    117
     *----------------------------------------------------------------
     *  Re-definition field(s)
     *
     D                 ds
     D  oihmec                13     15
     D  oihmsc                 1     20
     D                 ds
     D  ohmemc                13     15
     D  ohmisc                 1     20
650dA*
650dAD                 ds
650dAD  rhiuse                 8      8  0
650dAD  rhshpd                 1      8  0
GFScA*
GFScAD                 ds
GFScAD  itminq                 4      8  2 inz(0)
GFScAD  itrcvd                 1      8  0 inz(0)
GFScA*
     *----------------------------------------------------------------
     *  Constants
     *
     D exchdr          c                   const('- Exceptions')
     D sts01           c                   const('** Added to existing-
     D                                      Open Order. ')
     D sts02           c                   const('** New Order Added t-
     D                                     o Open Route.')
     D sts03           c                   const('** Upd''d on existin-
     D                                     g Open Order.')
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
GFS AD brk1wgt         s                   like(itswgt)
GFS AD brk2wgt         s                   like(itswgt)
GFScAD cases           s                   like(oidq1)
GFScAD eaches          s                   like(oidq1)
650aAD ck4err          s               n
     D count           s              3  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
650aAD error           s               n
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D good1           s              1
     D good2           s              1
SFPaAd hlddiv          s              5a
     D impdte          s              8  0
     D imptim          s              6  0
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
650bAD kyrhstat        s                   like(rhstat)
650bAD                                     inz('1')
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(odstat)
     D kywhdp          s                   like(itwhdp)
     D len             s              1  0
     D linppg          s              3  0
     D lstrid          s                   like(oihrte)
     D lstrte          s                   like(oihrte)
     D lstwhs          s              3  0
     D mischdrupd      s              4    inz('*NO ')
     D miscupdate      s              4    inz('*NO ')
     D mrgitm          s              1
     D mrgord          s              1
     D mrgrte          s              1
     D neword          s                   like(ohord)
     D newrtc          s                   like(rhrte)
     D newrte          s                   like(rhrtid)
GFScAD ordwgt          s              7  2 inz(0)
GFSaAD origqty         s              5
GFSbAD origwgt         s                   like(oidq1)
     D opened          s              1
     D opnorc          s                   like(ohord)
     D opnord          s                   like(ohord)
     D opnrtc          s                   like(rhrte)
     D opnrte          s                   like(rhrtid)
     D opnimpordhm     s              1    inz('0')
     D opnordhm        s              1    inz('0')
     D opnimporddm     s              1    inz('0')
     D opnorddm        s              1    inz('0')
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
650aAD savever#        s                   like($lnver#)
     D skpwrt          s              1
650bAD skpwrthdr       s              1    inz('0')
650bAD skpwrthdrm      s              1    inz('0')
650bAD skpwrtdtlm      s              1    inz('0')
     D sublin          s              7  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
     D tmpcub          s                   like(rsordc)
     D tmploc          s              3  0
     D tmpwgt          s                   like(rsordw)
     D today           s              8  0
GFSbAD wgtrem          s                   like(oidq1)
     D work3a          s              3
     D wrgsts          s              1
GFShAD lastorddet      S              5s 0 inz(0)
GFShAD newoidseq       S              5s 0 inz(0)
GFShAD ordcases        S              5s 0 inz(0)
GFShAD partcase        S              5s 0 inz(0)
GFShAD ordeaches       S              7s 0 inz(0)
GFShAD wrtcasercd      S              4a   inz('*NO ')
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
650aA
650aA*----------------------------------------------------------------
650aA*  Program info data structure
650aA*
650aAD                sds
650aAD  #prog            *proc
650aAD  #job                 244    253
650aAD  #user                254    263
650aAD  #jobn                264    269
650aAD  #jobdt               276    281  0
650aAD  #jobtm               282    287  0
650aA*
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PTYPE  Order types to process.
     *              ' ' - Normal
     *              'T' - Transfer
     *              'W' - Will Call
     *              'S' - Single
     *
     *    Returned Parameters
     *      $PWHS   Warehouse to process.
     *      $PTRUK  Truck code.
     *      $PRT01  Route id assigned to will call order.
     *      $PRT02  Route id assigned to will call order.
     *      $PRT03  Route id assigned to will call order.
     *      $PRT04  Route id assigned to will call order.
     *      $PRT05  Route id assigned to will call order.
     *      $PRT06  Route id assigned to will call order.
     *      $PRT07  Route id assigned to will call order.
     *      $PRT08  Route id assigned to will call order.
     *      $PRT09  Route id assigned to will call order.
     *      $PRT10  Route id assigned to will call order.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $ptype            1
     C                   parm                    $pwhs            15 5
     C                   parm                    $ptruk           10
     C                   parm                    $prt01            5
     C                   parm                    $prt02            5
     C                   parm                    $prt03            5
     C                   parm                    $prt04            5
     C                   parm                    $prt05            5
     C                   parm                    $prt06            5
     C                   parm                    $prt07            5
     C                   parm                    $prt08            5
     C                   parm                    $prt09            5
     C                   parm                    $prt10            5
     C                   parm                    $pimppo           4
     *----------------------------------------------------------------
     * Key definitions
     *
     * Download order detail file - Partial key
     *
     C     oidkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihdiv
     C                   kfld                    oihord
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    oidwhs
     C                   kfld                    oiditm
     *
     * Route summary file
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    kyrtid
     C                   kfld                    kywhdp
     *----------------------------------------------------------------
     * Main line
     *
     * Initialize route id's
     *
     C                   eval      $prt01 = *blanks
     C                   eval      $prt02 = *blanks
     C                   eval      $prt03 = *blanks
     C                   eval      $prt04 = *blanks
     C                   eval      $prt05 = *blanks
     C                   eval      $prt06 = *blanks
     C                   eval      $prt07 = *blanks
     C                   eval      $prt08 = *blanks
     C                   eval      $prt09 = *blanks
     C                   eval      $prt10 = *blanks
     C                   eval      rtcnt = 0
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *    Create heading for exceptions report.
     *
     C                   eval      $pstr = %trimr(rdsc(1)) + ' ' + exchdr
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1hdr1
     C                   eval      *in92 = *on
     C                   eval      prhdr1 = *off
     C                   eval      excprt = *off
     C                   eval      excpr1 = *off
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      grdlin = 0
     C                   eval      grord1 = *zeros
     C                   eval      grlin1 = *zeros
     C                   eval      preoh = 0
     C                   eval      preod = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     *
     * Whip through all the download header records
     *
     C                   eval      lstrte = '@@@@@'
     C                   eval      lstrid = '@@@@@'
     *
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C                   eval      lstwhs = -(1)
     *
     C                   dou       eofh = *on
     C                   exsr      updrte
     *
     C                   read      impfordh8                              79
     C                   if        *in79
     C                   eval      eofh = *on
     *
     *  When route changes, resquence stops in RTESTP file.
     C                   if        lstrte <> '@@@@@'
650fAC                   if        mrgrte = '1'
650fAC                   eval      $rrtid = opnrte
650fAC                   exsr      reseqstp
650fAC                   endif
650fAC                   eval      $rrtid = lstrid
     C                   exsr      reseqstp
     C                   endif
650bA*
650bA*  Merge order(s) into Open routes allowed.
650bA*  Check if any orders attached to new open route. If no, delete.
650bA*
650bAC                   if        opmrga = 'Y'  and
650bAC                             $ptype = ' '
650bAC                   exsr      zzckr1
650dA*
650dAC                   if        mrgrte = '1'
650dA*  Clear Inuse flag for Open route after updates.
650dAC                   exsr      zzclriuseopn
650dAC                   endif
650dA*
650bAC                   endif
650dA*
650dA*  Clear Inuse flag for New route after updates.
650dAC                   exsr      zzclriusenew
     *
     C                   goto      enddoh
     C                   endif
     *
     C                   if        client = packers
     *
     *      If route is blank, order sent is Will-Call order.
     C                   if        oihrte = ' '
     C                   eval      oihtyp = 'W'
     C                   endif
     *
     *      See if customer is in Customer Misc file.
     C     csmkey        chain     custmisc
     C                   if        %found(custmisc)
     C                   Eval      oihmsc = %Replace('*SP': oihmsc:7:3)
     C                   endif
     *
     C                   endif
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> oihwhs
     *
     C                   eval      whcode = oihwhs
     C                   eval      $pwhse = oihwhs
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     * Delete all status 'Z' XDK slots.
     *
     C                   exsr      zzzdelxdk
     *
     *    Retrieve General Pick options for warehouse.
     *    This applies to only Regular orders.
     *
     C                   select
     C                   when      $ptype = ' '
     C                   eval      opwhse = oihwhs
     C                   eval      opcode = '*GENPICK'
     C     opkey         chain     options                            7978
     C                   if        *in79
     C                   eval      opmrga = 'N'
     C                   endif
     *
     *    Force Allow Merge orders to Yes for 'S' orders.
     *
     C                   when      $ptype = 'S'
     C                   eval      opmrga = 'Y'
     *
     *    All other order types, force Allow Merge orders to No
     *
     C                   other
     C                   eval      opmrga = 'N'
     C                   endsl
     *
     C                   eval      $pwhs = whcode
     C                   move      oihwhs        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     C                   eval      lstwhs = oihwhs
     C                   eval      pflag = *off
     *    Get exceptions report override if any.
     C                   exsr      opnprt
     C                   endif
     *
     *    Print report heading if necessary.
     *
     C                   eval      prhdr1 = *off
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     *  Add record to route header file when route changes.
     *     or when processing 'S' orders.
     *
     C                   if        oihrte <> lstrte
     *
650dDC*                  eval      mrgrte = *off
650cDC*                  eval      newrte = *blanks
650cDC*                  eval      newrtc = *blanks
     *
     *  Merge order(s) into Open routes allowed.
     *  Check if Route still at Open status.
     *
     C                   if        opmrga = 'Y'  and
     C                             $ptype = ' '
     C                   exsr      zzckr1
650dA*
650dAC                   if        mrgrte = '1'
650dA*  Clear Inuse flag for Open route after updates.
650dAC                   exsr      zzclriuseopn
650dAC                   endif
650dA*
650dAC                   eval      mrgrte = *off
     C                   exsr      zzckrt
     C                   endif
     *
     *  When route changes, resquence stops in RTESTP file.
     C                   if        lstrte <> '@@@@@'
650fAC                   if        mrgrte = '1'
650fAC                   eval      $rrtid = opnrte
650fAC                   exsr      reseqstp
650fAC                   endif
650fAC                   eval      $rrtid = lstrid
     C                   exsr      reseqstp
650dA*
650dA*  Clear Inuse flag for New route after updates.
650dAC                   exsr      zzclriusenew
650dA*
     C                   endif
     *
650cAC                   eval      newrte = *blanks
650cAC                   eval      newrtc = *blanks
     C                   exsr      fillrh
     C                   write     rhrec                                49
     C                   eval      lstrte = oihrte
     C                   endif
     *
     *    Add record to order header file. If an error occurs, assume
     *    it was caused by a duplicate record.
     *
     C                   eval      hedmsg = *blanks
     *
     *    Route allows Add-on orders to be merged with existing Open orders.
     *    Check if order header still at Open status.
     *
     C                   eval      mrgord = *off
     C                   eval      wrgsts = *off
     C                   eval      opnord = *zeros
     C                   eval      opnorc = *zeros
     C                   if        mrgrte = *on
     C                   exsr      zzcko1
     C                   exsr      zzckor
     C                   endif
     *
     C                   exsr      filloh
     *
     *    Only update ORDHM if impfordhm8 was sent.
     C                   if        mischdrupd = '*YES'
     C                   exsr      fillhm
     C                   endif
     *
650bAC                   if        skpwrthdr = '0'
     C                   write     ohrec                                49
650bAC                   endif
     *
     *    Fill Route Extended Stop file
     C                   exsr      fillxr
     C                   write (e) rtsrec
     C                   if        %error
     C                   endif
     *
     *
     *    Only add to ORDDM if impforddm was sent.
     C                   if        mischdrupd = '*YES'
     C                             and %found(impfordhm8)
650bA*
650bAC                   if        skpwrthdrm = '0'
650bDC*                  write     hmrec
650bMC                   write (e) hmrec
     C                   if        %error
     C                   endif
650bAC                   endif
     C                   endif
     C                   if        *in49
     C                   eval      hedmsg = desc(1)
     C                   add       1             preoh
     C                   endif
     *
     *    Print order heading
     *
     C                   if        pflag = *off
     C                   write     head2
     C                   add       2             count
     C                   endif
     *
     C                   write     head3
     C                   add       2             count
     *
     C                   if        pflag = *off
     C                   write     head4
     C                   add       2             count
     C                   eval      pflag = *on
     C                   endif
     *
     *    Exception occurred, print on report.
     *
     C                   select
     C                   when      hedmsg > *blanks
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   endif
     C                   write     head31
     *    Set on flag that customer heading printed already.
     C                   eval      prhdr1 = *on
     *
     C                   endsl
     *
     *    Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
     C                   eval      subq11 = *zeros
     C                   eval      subq21 = *zeros
     C                   eval      subq31 = *zeros
GFShA*
GFShAC                   if        client = Getfresh
GFShAC                   exsr      zzupcvtqty
GFShAC                   endif
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
     C                   eval      excpr1 = *off
     C     oidkey        setll     impfordd8
     C                   dou       eofd = *on
     *
     C     oidkey        reade     impfordd8                              78
     C                   if        *in78
     C                   eval      eofd = *on
     C                   goto      enddod
     C                   endif
     C                   eval      detmsg = *blanks
     C                   eval      good1 = 'N'
     C                   eval      good2 = 'N'
     C                   eval      mrgitm = *off
     C                   eval      stsmsg = *blanks
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   movel     '*****'       itdesc
     C                   else
GFS A*
GFS AC                   select
GFS AC                   when      client = Getfresh
GFSiA*
GFSiAC                   exsr      zzgetik
GFS A*
GFS AC                   select
GFS AC                   when          itcwgt = 'Y'
GFS AC                             and itswgt > 0
GFS A*       Convert Ordered "pounds" into Ordered "quantity".
GFS AC                   exsr      zzcvtlbs2qty
GFScA*
GFScA*       Convert Brkdwn 1 Ordered "pounds" into Ordered "quantity".
GFScAC                   when          itum2 = 'LB'
GFScAC                             and itumq2 > 0
GFScAC                             and oidq2  > 0
GFScAC                             and itcwgt = 'N'
GFScAC                   exsr      zzcvtlbs2qty2
GFSeA*
GFSeA*       Convert Brkdwn 2 Ordered "pounds" into Ordered "quantity".
GFSeAC                   when          itum3 = 'LB'
GFSeAC                             and itumq3 > 0
GFSeAC                             and oidq3  > 0
GFSeAC                             and itcwgt = 'N'
GFSeAC                   exsr      zzcvtlbs2qty3
GFSeA*
GFS AC                   endsl
GFS A*
GFS AC                   endsl
GFS A*
     *       Check if breakdown qty is allowed using piritem file.
     *       Add rec if qty1, brk qty2 or brk qty3 has good qty.
     C                   exsr      zzbkdn
     *
     *       If qty1, brkdown qty2 or brkdown qty3 has good qty,
     *        add record to order detail file. If an error
     *        occurs, assume was caused by a duplicate record.
     *        Update route summary with detail information.
     *
     C                   if        good1 = 'Y'
     C                   exsr      zzxdck
     C                   if        good2 = 'Y'
     C                   exsr      fillod
     *
     *    Only update ORDDM if impforddm was sent.
     C                   if        miscupdate = '*YES'
     C                   exsr      fillom
     C                   endif
     *
     *    Record was updated in FILLOD.
     C                   if        skpwrt = *off
     C                   write     odrec                                49
     *
     *    Only add to ORDDM if impforddm was sent.
     C                   if        miscupdate = '*YES'
650bAC                   if        skpwrtdtlm = '0'
     C                   write     omrec
     C                   if        %error
     C                   endif
650bAC                   endif
     C                   endif
     C                   if        *in49
     C                   eval      detmsg = desc(1)
     C                   add       1             preod
     C                   endif
     C                   endif
     C                   exsr      updsum
     C                   endif
     C                   endif
     *
     C                   endif
     *
     *       Print order detail and update subtotals
     *
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
     *
     *       Print order detail item merge info line.
     *
     C                   if        mrgrte = *on  and
     C                             mrgitm = *on
     C                   exsr      zrhead
     C                   write     detail2
     C                   add       1             count
     C                   endif
     *
     C                   add       1             sublin
     C                   add       oidq1         subq1
     C                   add       oidq2         subq2
     C                   add       oidq3         subq3
     *
     *       Delete detail record from download file
     *
     *
     C                   if        client = packers
SFPaAC                             or client = seashore
     *       Leave order detail records for extracting p/o's.
     C                   else
     *
     C                   delete    oidrec
     C                   endif
     *
     *
     *       Exception occurred, print on report.
     C                   select
     C                   when      detmsg > *blanks
     *
     *    Turn on flag to indicate at least one exception printed.
     *    Print grand totals when complete.
     C                   eval      excprt = *on
     *    Turn on flag to indicate at least one exception printed.
     *    Print sub totals when complete.
     C                   eval      excpr1 = *on
     *
     C                   add       oidq1         subq11
     C                   add       oidq2         subq21
     C                   add       oidq3         subq31
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   eval      prhdr1 = *on
     C                   endif
     *
     *    Print exception report Customer info and headings.
     C                   if        prhdr1 = *off
     C                   write     head31                               92
     C                   eval      prhdr1 = *on
     C                   endif
     *
     *    Print exception report page headings.
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     *
     C                   write     detail1                              92
     C                   add       1             grlin1
     *
     *    Print exception report page headings.
     C                   if        itpdsc > ' '
     *
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     C                   write     detail22                             92
     C                   add       1             grlin1
     *
     C                   endif
     *
     C                   endsl
     *
     C     enddod        tag
     C                   enddo
     *
     *    Print order subtotals and update grand totals
     *
     C                   write     subttl
     C                   add       3             count
     C                   add       1             grdord
     C                   add       sublin        grdlin
     *
     *    Print Order exception subtotals.
     C                   if        excpr1 = *on
     C                   add       1             grord1
     C                   if        *in92
     C                   write     head11                               92
     C                   write     head21
     C                   write     head31
     C                   write     head41
     C                   endif
     C                   write     subttl1                              92
     C                   endif
     *
     *  Delete header record from download file
     *
     *
     C                   if        client = packers
SFPaAC                             or client = seashore
     *       Leave order header records for extracting p/o's.
     C                   else
     *
     C                   delete    oihrec
     C                   endif
     *
     *
     C     enddoh        tag
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
     *
     *    Remove NEW Order Header if no items attached.
     C                   if        mrgord = *on
     C                   exsr      zzcko1
     C                   endif
     *
     *    Remove NEW Route Header if no orders attached.
     C                   if        mrgrte = *on
     C                   exsr      zzckr1
     C                   endif
     *
     *    Print exception grand totals.
     C                   if        excprt = *on
     C                   if        *in92
     C                   write     head11                               92
     C                   endif
     C                   write     grndttl1
     C                   endif
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     * Open IMPFORDHM8 file.
     C                   if        opnimpordhm <> *on
     C                   open      impfordhm8                           67
     C                   if        *in67 = *off
     C                   eval      opnimpordhm = *on
     C                   eval      mischdrupd = '*YES'
     C                   else
     C                   eval      mischdrupd = '*NO '
     C                   endif
     C                   endif
     *
     * Open ORDHM file if import file was sent.
     C                   if            opnordhm <> *on
     C                             and mischdrupd ='*YES'
     C                   open      ordhm                                67
     C                   if        *in67 = *off
     C                   eval      opnordhm   = *on
     C                   eval      mischdrupd = '*YES'
     C                   else
     C                   eval      mischdrupd = '*NO '
     C                   endif
     C                   endif
     *
     * Open IMPFORDDM file.
     C                   if        opnimporddm <> *on
     C                   open      impforddm8                           68
     C                   if        *in68 = *off
     C                   eval      opnimporddm = *on
     C                   eval      miscupdate  = '*YES'
     C                   else
     C                   eval      miscupdate = '*NO '
     C                   endif
     C                   endif
     *
     * Open ORDDM file if import file was sent.
     C                   if            opnorddm <> *on
     C                             and miscupdate ='*YES'
     C                   open      orddm                                68
     C                   if        *in68 = *off
     C                   eval      opnorddm   = *on
     C                   eval      miscupdate = '*YES'
     C                   else
     C                   eval      miscupdate = '*NO '
     C                   endif
     C                   endif
     *
     * Open ORDDM file if import file was sent.
     C                   if        client = packers
     C                   if        not %open(custmisc)
     C                   open      custmisc
     C                   endif
     C                   endif
GFSiA*
GFSiA* Open ITEMEXT1 file.
GFSiAC                   if        client = getfresh
GFSiAC                   if        not %open(itemext1)
GFSiAC                   open      itemext1
GFSiAC                   endif
GFSiAC                   endif
     *
     * CROSSDK  Cross Dock - Full key
     C     cdkey         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     * IMPFORDH8 Download order header file - Partial key
     C     oihkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptype
     *
     * IMPFORDHM8  Download order header misc - full key
     C     oihmkey       klist
     C                   kfld                    oihwhs
     C                   kfld                    oihdiv
     C                   kfld                    oihord
     *
     * IMPFORDDM8  Download order detail misc - full key
     C     oimkey        klist
     C                   kfld                    oidwhs
     C                   kfld                    oiddiv
     C                   kfld                    oidord
     C                   kfld                    oidseq
     C                   kfld                    oiditm
     *
     * CUSTMISC   BFC Dakota Customer Master - Misc. - Full Key
     C     csmkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihcus
     *
     * ORDH Order header file - Partial key
     *
     C     ohkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
650bA*
650bA* ORDH Order header file - Full key
650bA*
650bAC     opnohkey      klist
650bAC                   kfld                    $pwhse
650bAC                   kfld                    opnord
     *
     * ORDH4 Order header file - Full key  (NEW Route)
     *
     C     oh3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    newrte
     *
     * ORDH4 Order header file - Full key  (Open Route)
     *
     C     oh5key        klist
     C                   kfld                    $pwhse
     C                   kfld                    opnrte
     C                   kfld                    oihord
     *
     * ORDHM Order header misc. file - Full key
     *
     C     *like         define    hmord         kyord
     C     hmkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyord
     *
     * ORDD Order detail file - Partial key
     *
     C     odkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
     *
     * ORDD1 Order detail file - Full key
     *
     C                   eval      kystat = 'O'
     C     od1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    opnord
     C                   kfld                    kystat
     C                   kfld                    oidseq
     C                   kfld                    oiditm
     C     od2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
     *
     * ORDDM  Order detail misc. file - Full key
     *
     C     omkey         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     * OPTIONS Options file - Full key
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     * PODTL1 PO DETAIL file
     *
     C     keypd1        klist
     C                   kfld                    $pwhse
     C                   kfld                    oidpo
     C                   kfld                    oiditm
     *
     * RTEHED1 - Route header file - Partial key
     *
     C     rh1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    oihrte
     *
     * RTEHED1 - Route header file - Full key
     C     rh2key        klist
     C                   kfld                    $pwhse
     C                   kfld                    newrtc
     C                   kfld                    newrte
     *
     * RTEHED1 - Route header file - Full key
     C     rh3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    lstrte
     C                   kfld                    lstrid
650dA*
650dA* RTEHED1 - Route header file - Full key
650dAC     rh14key       klist
650dAC                   kfld                    $pwhse
650dAC                   kfld                    opnrtc
650dAC                   kfld                    opnrte
650bA*
650bA* RTEHED2 - Route header file - Partial key
650bA*
650bAC     rh2akey       klist
650bAC                   kfld                    $pwhse
650bAC                   kfld                    kyrhstat
650bAC                   kfld                    $ptype
650bAC                   kfld                    oihrte
     *
     * SLOT1 file
     C     keysl1        klist
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   kfld                    kyaisl
     *
     * SLOT4 file
     C     keysl4        klist
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   kfld                    oiditm
     C                   kfld                    kydisp
     *
     * SLOT11 file
     C     keysl11       klist
     C                   kfld                    $pwhse
     C                   kfld                    kyaisl
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     C                   eval      mrgrte = *off
     C                   eval      mrgord = *off
     C                   eval      mrgitm = *off
     C                   eval      wrgsts = *off
     C                   eval      rcdlck = *off
     C                   eval      skpwrt = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*  clr$slot  Clear $slot data structure fields
650aA*----------------------------------------------------------------
650aA
650aAC     clr$slot      begsr
650aA*
650aAC                   eval      savever# = $slver#
650aAC                   clear                   $slot
650aAC                   clear                   $slot2
650aAC                   eval      $slver# = savever#
650aA*
650aAC                   endsr
650aA*
     *----------------------------------------------------------------
     *
     *  FILLOD  Fill order detail fields.
     *
     C     fillod        begsr
     C                   eval      skpwrt = *off
     *
     *    Route & order at Open status. Check if item already on order.
     *    If yes, then compute difference between import qty's and order
     *    qty's. Then update order with import qty.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgtod
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      not *in75  and
     C                             oiditm = oditem
     *
     *    Calculate change in quantity to update RTESUM file.
     C                   eval      difqy1 = oidq1 - odqor1
     C                   eval      difqy2 = oidq2 - oidq2
     C                   eval      difqy3 = oidq3 - oidq3
     *
     C                   eval      odqor1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
     C                   endif
     C                   update    odrec1
     *    Load print field for report.
     C                   move      odord         prtord
     C                   move      sts03         stsmsg
     C                   eval      mrgitm = *on
     C                   eval      skpwrt = *on
     C                   goto      endlod
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   odrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      odwhse = oidwhs
     *
     *    Open route found, Open order not found or at wrong status.
     *    Create order under current Open route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  or
     *
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *on
     C                   eval      odord = neword
     C                   move      sts02         stsmsg
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      odord = opnord
     C                   move      sts01         stsmsg
     *
     C                   other
     C                   eval      odord = ohord
     C                   endsl
     *    Load print field for report.
     C                   move      odord         prtord
     *
     C                   eval      odseq = oidseq
     C                   eval      oditem = oiditm
     C                   eval      odqor1 = oidq1
     C                   eval      difqy1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
     C                   eval      difqy2 = oidq2
     C                   else
     C                   eval      odqor2 = 0
     C                   eval      difqy2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
     C                   eval      difqy3 = oidq3
     C                   else
     C                   eval      odqor3 = 0
     C                   eval      difqy3 = 0
     C                   endif
     C                   eval      odwh2 = oidwh2
     C                   eval      odor2 = oidor2
     C                   eval      odoitm = oidoit
     C                   eval      odspcl = oidspc
     C                   eval      odstat = 'O'
     C                   eval      mrgitm = *on
     *
     C     endlod        tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOM  Fill order detail misc file fields.
     *
     C     filloM        begsr
650bAC                   eval      skpwrtdtlm = *off
     *
     C     oimkey        chain     impforddm8
     C                   if        not %found(impforddm8)
     C*                  clear                   oimrec
650bAC                   eval      oimwhs = 0
650bAC                   eval      oimdiv = ' '
650bAC                   eval      oimord = 0
     C                   eval      oimdsc = ' '
     C                   eval      oimpds = 'N'
     C                   eval      oimrds = 'N'
     C                   eval      oimbox = 'N'
     C                   eval      oimexp = 'N'
     C                   eval      oimms1 = ' '
     C                   eval      oimms2 = ' '
     C                   eval      oimms3 = ' '
     C                   eval      oimms4 = ' '
     C                   eval      oimms5 = ' '
650bAC                   eval      skpwrtdtlm = *on
650bAC                   goto      endlodm
     C                   endif
     *
     *    Route & order at Open status. Check if item already on order.
     *    If yes, then compute difference between import qty's and order
     *    qty's. Then update order with import qty.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgtom
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      %found(orddm) and
     C                             oiditm = oditem
     *
     C                   select
     C                   when      client = packers
     C                   eval      omodsc = ' '
     C                   other
     *
     C                   eval      omodsc = oimdsc
     C                   endsl
     *
     C                   eval      ompdsc = oimpds
     C                   eval      omrdsc = oimrds
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
     *
     C                   select
     C                   when      client = packers
     C                   eval      ommsc1 = oimdsc
     C                   other
     *
     C                   eval      ommsc1 = oimms1
     C                   endsl
     *
     C                   eval      ommsc2 = oimms2
     C                   eval      ommsc3 = oimms3
     C                   eval      ommsc4 = oimms4
     C                   eval      ommsc5 = oimms5
     C                   update    omrec
650bAC                   eval      skpwrtdtlm = '1'
     *
     C                   goto      endlodm
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   omrec
     *
     *  Move fields from download file to order detail misc file fields.
     *
     C                   eval      omwhse = oidwhs
     *
     *    Open route found, Open order not found or at wrong status.
     *    Create order under current Open route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  or
     *
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *on
     C                   eval      omord = neword
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      omord = opnord
     *
     C                   other
     C                   eval      omord = ohord
     C                   endsl
     *
     C                   eval      omseq  = oidseq
     C                   eval      omitem = oiditm
     C                   eval      omodsc = oimdsc
     C                   eval      ompdsc = oimpds
     C                   eval      omrdsc = oimrds
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
     C                   eval      ommsc1 = oimms1
     C                   eval      ommsc2 = oimms2
     C                   eval      ommsc3 = oimms3
     C                   eval      ommsc4 = oimms4
     C                   eval      ommsc5 = oimms5
     *
     C     endlodm       tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOH   Fill order header fields.
     *
     C     filloh        begsr
650bAC                   eval      skpwrthdr = '0'
650bA*
650bA*    Open route found, Open order found.
650bA*    Update existing order.
650bAC                   if        mrgrte = *on  and
650bAC                             mrgord = *on  and
650bAC                             wrgsts = *off
650bAC     opnohkey      chain     ordh
650bAC                   if        %found(ordh)
650bAC                   eval      ohcord = oihord
650bAC                   eval      ohcpo  = oihcpo
650bAC                   eval      ohcust = oihcus
650bAC                   eval      ohcnam = oihcnm
650bAC                   eval      ohcad1 = oihca1
650bAC                   eval      ohcad2 = oihca2
650bAC                   eval      ohccty = oihcct
650bAC                   eval      ohcst  = oihcst
650bAC                   eval      ohczip = oihczp
650bAC                   eval      ohtruk = $ptruk
650bAC                   eval      ohmisc = oihmsc
650bA*
650bA*    Open route found, Open order found.
650bA*    Update existing order.
650bAC                   update    ohrec
650bAC                   eval      skpwrthdr = '1'
650bA*    Load print field for report.
650bAC                   eval      prtrte = ohrte
650bA*
650bAC                   goto      endlodh
650bA*
650bAC                   endif
650bA*
650bAC                   endif
     *
     *  Initialize record
     *
     C                   clear                   ohrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      ohwhse = oihwhs
     C                   call      'PIRORD#'
     C                   parm      ohwhse        $owhse            3 0
     C     ohord         parm      0             $oord             7 0
     C                   eval      neword = ohord
     C                   eval      ohtype = oihtyp
     C                   eval      ohcord = oihord
     C                   eval      ohcpo = oihcpo
     C                   eval      ohcust = oihcus
     C                   eval      ohcnam = oihcnm
     C                   eval      ohcad1 = oihca1
     C                   eval      ohcad2 = oihca2
     C                   eval      ohccty = oihcct
     C                   eval      ohcst = oihcst
     C                   eval      ohczip = oihczp
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   select
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      ohrte = opnrte
     *
     C                   other
     C                   eval      ohrte = rhrtid
     C                   endsl
     *    Load print field for report.
     C                   eval      prtrte = ohrte
     *
     *      Set stops to zero. OI300 will compute a sequential
     *      stop number to be populated into this field.
     C                   eval      ohstop = 0
     *
     C                   eval      ohtruk = $ptruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
650bA*
650bAC     endlodh       tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLHM  Fill order header misc file fields.
     *
     C     fillHM        begsr
650bAC                   eval      skpwrthdrm = '0'

SFPaAc                   if        client = seashore
SFPaAc                   eval      hlddiv = oihdiv
SFPaAc                   eval      oihdiv = *blanks
SFPaAc                   endif
     *
     C     oihmkey       chain     impfordhm8
     C                   if        not %found(impfordhm8)
     C                   eval      ohmms1 = ' '
     C                   eval      ohmms2 = ' '
     C                   eval      ohmms3 = ' '
     C                   eval      ohmms4 = ' '
     C                   eval      ohmms5 = ' '
     C                   endif
     *
     C                   select
     *    Open route found, Open order found.
     *    Retrieve Open Order Header Misc. file
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      kyord = opnord
     *
     C                   other
     C                   eval      kyord = neword
     C                   endsl
     *
     C                   eval      rcdlck = *on
     C                   exsr      zzgethm
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      %found(ordhm)
     *
     C                   select
     *    Open route found, Open order found.
     *    Leave route ID untouched.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      hmrtid = opnrte
     C                   other
     C                   eval      hmrtid = rhrtid
     C                   endsl
     *
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc2 = ohmms2
     C                   eval      hmmsc3 = ohmms3
     C                   eval      hmmsc4 = ohmms4
     C                   eval      hmmsc5 = ohmms5
     C                   update    hmrec
650bAC                   eval      skpwrthdrm = '1'
     *
     C                   goto      endlodhm
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   hmrec
     *
     *  Move fields from download file to order detail misc file fields.
     *
     C                   eval      hmwhse = oihwhs
     C                   eval      hmord = neword
     C                   select
     *
     *    Open route found, Open order NOT found.
     *    Add Order to current Open Route.
     C                   when      mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off
     C                   eval      hmrtid = newrte
     *
     C                   other
     C                   eval      hmrtid = rhrtid
     C                   endsl
     *
     C                   eval      hmmsc1 = ohmms1
     C                   eval      hmmsc2 = ohmms2
     C                   eval      hmmsc3 = ohmms3
     C                   eval      hmmsc4 = ohmms4
     C                   eval      hmmsc5 = ohmms5
     *
     C     endlodhm      tag
     *
SFPaAc                   if        client = seashore
SFPaAc                   eval      oihdiv = hlddiv
SFPaAc                   eval      hlddiv = *blanks
SFPaAc                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLRH   Fill route header fields.
     *
     C     fillrh        begsr
     *
     *  Initialize record
     *
     C                   clear                   rhrec
     *
     *  Update fields.
     *
     C                   eval      rhwhse = oihwhs
     C                   call      'PIRRTE#'
     C                   parm      rhwhse        $rwhse            3 0
     C                   parm      ' '           rhrtid
     C                   eval      lstrid = rhrtid
     *
     C                   add       1             rtcnt
     C                   select
     C                   when      rtcnt = 1
     C                   eval      $prt01 = rhrtid
     C                   when      rtcnt = 2
     C                   eval      $prt02 = rhrtid
     C                   when      rtcnt = 3
     C                   eval      $prt03 = rhrtid
     C                   when      rtcnt = 4
     C                   eval      $prt04 = rhrtid
     C                   when      rtcnt = 5
     C                   eval      $prt05 = rhrtid
     C                   when      rtcnt = 6
     C                   eval      $prt06 = rhrtid
     C                   when      rtcnt = 7
     C                   eval      $prt07 = rhrtid
     C                   when      rtcnt = 8
     C                   eval      $prt08 = rhrtid
     C                   when      rtcnt = 9
     C                   eval      $prt09 = rhrtid
     C                   when      rtcnt = 10
     C                   eval      $prt10 = rhrtid
     C                   endsl
     C                   eval      newrte = rhrtid
     C                   if        $ptype = 'W'  and
     *
     C                             oihrte = *blanks
     C                   eval      rhrte = rhrtid
     C                   else
     C                   eval      rhrte = oihrte
     C                   endif
     C                   eval      newrtc = oihrte
     C                   eval      rhtype = oihtyp
     C                   if        $ptype = 'W'  and
     C                             oihtrk = *blanks
     *
     C                   eval      rhtruk = *blanks
     C                   movel     'WILLCALL'    rhtruk
     C                   else
     C                   eval      rhtruk = oihtrk
     C                   endif
     *
     C                   eval      $ptruk = rhtruk
     C                   eval      rhstat = *on
     C                   eval      rhstsd = impdte
     C                   eval      rhstst = imptim
     C                   eval      rhimpd = impdte
     C                   eval      rhimpt = imptim
     C                   eval      rhrptd = impdte
650dA*
650dA*      Set route Inuse flag to Importing.
650dAC                   eval      rhiuse = 5
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLXR   Fill Stop Xref File RTESTP
     *
     C     fillxr        begsr
     *
     *  Initialize record
     *
     c                   clear                   rtsRec
     *
     c                   eval      rtswhs = ohWhse
     c                   eval      rtsrid = ohRte
     c                   eval      rtsord = ohord
     c                   eval      rtsstp = 0
     c                   eval      rtsst5 = oihest
     c                   eval      rtsdrop = oihdrp
     c                   eval      rtsextd = oihdex
720 Dc*                  eval      rtssd = %char(oihest) + oihdrp
720 Mc                   eval      rtssd = %editc(oihest : 'X') + oihdrp
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RESEQSTP   Call pgm to Re-Sequence ORDH file
     *
     C     reseqstp      begsr
     *
     *  Resequence stops in ORDH to make them unique.
     *
     c                   call      'OI300'
     c                   parm                    rhwhse
650fDc*                  parm                    lstrid
650fMc                   parm                    $rrtid            5
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OI3251PR'    $lrpt            10
     C                   parm      lstwhs        $whse             3 0
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     oi3251pr
     C                   close     oi325pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI3251PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *        NOTE: Ending array positions for $DEV 39, $FORM 60 are one
     *              greater than standard code. This is due to the
     *              extra character in the printer file name.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(39)
     C                   movea     $form         a80(60)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *   Get device and form type for main report.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'OI325PR '    $lrpt
     C                   parm      lstwhs        $whse
     C                   parm      *blanks       $styp
     C                   parm      *blanks       $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI325PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(2)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *      Open printer file.
     *
     C                   open      oi3251pr
     C                   open      oi325pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDRTE   Update route with automatically assigned truck.
     *
     C     updrte        begsr
     *
     *  If first time throught, then get out.
     *
     C     lstrte        cabeq     '@@@@@'       endupr
     *
     *  Get route header record.
     *
     C     rh3key        chain     rtehed1                            73
     C                   if        *in73
     C                   goto      endupr
     C                   endif
     *
     *  If truck already defined, get out.
     *
     C                   if        rhtruk <> *blanks
     C                   unlock    rtehed1
     C                   goto      endupr
     C                   endif
     *
     *  Call program to automatically assign truck.
     *
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
     C                   parm      '*DFLT  '     $xcmd             8
     C                   if        $xrtn = '*OK'
     C                   update    rhrec1
     C                   else
     C                   unlock    rtehed1
     C                   endif
     *
     C     endupr        endsr
     *----------------------------------------------------------------
     *
     *  UPDSUM   Update route summary file with detail record.
     *
     C     updsum        begsr
     *
     *  Define work fields
     *
     *
     *  Try to get existing summary records for department.
     *
     C                   select
     *    Update route summary for Open route when Open Order
     *    found and at correct status.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off  and
     C                             mrgitm = *on  or
     *
     *    Update route summary for Open route when Open Order
     *    NOT found and at correct status.
     C                             mrgrte = *on  and
     C                             mrgord = *off  and
     C                             wrgsts = *off  and
     C                             mrgitm = *on
     C                   eval      kyrtid = opnrte
     *
     C                   other
     C                   eval      kyrtid = newrte
     C                   endsl
     *
     *     Determine department to use.
     *
     C                   eval      kywhdp = itwhdp
     *
     C     keyrs         chain     rtesum                             77
     *
     *     Record does not exist - Initialize fields.
     *
     C                   if        *in77
     C                   eval      rswhse = rhwhse
     C                   eval      rsrtid = kyrtid
     C                   eval      rswhdp = kywhdp
     C                   eval      rsordc = 0
     C                   eval      rsordw = 0
     C                   eval      rsordp = 0
     C                   eval      rspckc = 0
     C                   eval      rspckw = 0
     C                   eval      rspckp = 0
     C                   endif
     *
     *     Update department totals.
     *
     *     Get base item for alias item.
     C                   eval      #bityp = *blanks
     C                   if        ittype = 'A'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum1             2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     *
     C                   add       difqy1        rsordp
     C                   if        #bityp = 'S'  or
     C                             ittype = 'S'
     C                   if        itumq2 <= 0
     C                   eval      tmpcub = tmpcub * difqy1
     C                   eval      tmpwgt = tmpwgt * difqy1
     C                   else
     C     itcube        div(h)    itumq2        tmpcub
     C     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpcub = tmpcub * difqy1
     C                   eval      tmpwgt = tmpwgt * difqy1
     C                   endif
     C                   else
     C                   eval      tmpcub = itcube * difqy1
     C                   eval      tmpwgt = itswgt * difqy1
     C                   endif
     *
     C                   add       tmpcub        rsordc
     C*                  eval      tmpwgt = itswgt * difqy1
     C                   add       tmpwgt        rsordw
     *
     C                   add       difqy2        rsordp
     C                   if        difqy2 <> 0  and
     C                             itumq2 > 0
     C     itcube        div(h)    itumq2        tmpcub
     C                   eval      tmpcub = tmpcub * difqy2
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpwgt = tmpwgt * difqy2
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     C                   add       difqy3        rsordp
     C                   if        difqy3 <> 0  and
     C                             itumq3 > 0
     C     itcube        div(h)    itumq3        tmpcub
     C                   eval      tmpcub = tmpcub * difqy3
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq3        tmpwgt
     C                   eval      tmpwgt = tmpwgt * difqy3
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     *     Add/Update summary record.
     *
     C                   if        *in77
     C                   write     rsrec
     C                   else
     C                   update    rsrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     C                   if        oidq2 <> 0  and
     C                             itflg1 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        oidq3 <> 0  and
     C                             itflg2 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   if        oidq1 <> 0
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        oidq2 <> 0  and
     C                             itflg1 = 'Y'
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        oidq3 <> 0  and
     C                             itflg2 = 'Y'
     C                   eval      good1 = 'Y'
     C                   endif
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKRT  Check if route still at Open Status.
     *
     C     zzckrt        begsr
     *
     *    Position past last route, then read backward to get last route.
     *    If Regular route and status is Open, then allow orders to be
     *    merged to existing route.
     *
     *    NOTE: If we find the route that is being merged in,
     *          and the route is at Open status, we will leave the
     *          route header record locked till the merge is com-
     *          plete or we process a new route.  Leaving the record
     *          locked will prevent anyone from Allocating the route
     *          while we are importing new orders.
650dA*          The Inuse flag will now be set to 5=Importing while
650dA*          any orders are being updated or added to the route.
650dA*          Just before a new route is started, the Inuse flag will
650dA*          will be cleared.
     *
650bDC*    rh1key        setgt     rtehed1
650bMC     rh2akey       setgt     rtehed2
650bDC*    rh1key        readpe    rtehed1                                73
650bMC     rh2akey       readpe    rtehed2                                72
     C                   select
650bDC*                  when      not *in73  and
650bMC                   when      not *in72  and
     C                             rhtype = ' '  and
     C                             rhstat = '1'
650dAC                             and rhiuse = 0
     C                   eval      mrgrte = *on
     C                   eval      opnrte = rhrtid
     C                   eval      opnrtc = rhrte
650dAC                   eval      rhiuse = 5
650dAC                   update    rhrec2
     *
     C                   other
     C                   eval      mrgrte = *off
650dAC                   eval      opnrte = ' '
650dAC                   eval      opnrtc = ' '
650bDC*                  unlock    rtehed1
650bMC                   unlock    rtehed2
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKR1  Check if NEW route has any orders attached.
     *
     C     zzckr1        begsr
     *
     *    Check to see if any orders attached to NEW Route Header.
     *    If none found, then Delete NEW Route Header record.
     C     oh3key        setll     ordh4                                  77
     C                   if        not *in77
     C     rh2key        chain     rtehed1                            73
     C                   if        not *in73
     C                   delete    rhrec1
     C                   endif
     C                   endif
     *
     C                   endsr
650dA*
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZCLRIUSENEW  Clear Inuse flag for new route imported.
650dA*
650dAC     zzclriusenew  begsr
650dA*
650dA*      Clear Inuse flag for new route.
650dAC     rh2key        chain     rtehed1
650dAC                   if        %found(rtehed1)
650dAC                   eval      rhiuse = 0
650dAC                   update    rhrec1
650dAC                   endif
650dA*
650dAC                   endsr
650dA*
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZCLRIUSEOPN  Clear Inuse flag for Open route after updates.
650dA*
650dAC     zzclriuseopn  begsr
650dA*
650dA*      Clear Inuse flag for existing Open route.
650dAC     rh14key       chain     rtehed1
650dAC                   if        %found(rtehed1)
650dAC                   eval      rhiuse = 0
650dAC                   update    rhrec1
650dAC                   endif
650dA*
650dAC                   endsr
650dA*
     *----------------------------------------------------------------
     *
     *  ZZCKOR  Check if order header still at Open status.
     *
     C     zzckor        begsr
     *
     C     oh5key        setll     ordh4
     C                   dow       forevr = forevr
     C     oh5key        reade     ordh4
     C                   select
     C                   when      %eof(ordh4)
650eDC*                  eval      wrgsts = *on
     *
     C                   leave
     *
     *    In order to merge an order being imported, the following have
     *    to match: Must be the same type, existing order must be open,
     *    same customer.
     C                   when      not %eof(ordh4)
     C                             and oihtyp = ' '
     C                             and ohtype = ' '
     C                             and ohstat = 'O'
     C                             and client <> Packers
GFSdAC                             and client <> Getfresh
     *
     C                             or client = Packers
     C                             and not %eof(ordh4)
     C                             and oihtyp = ' '
     C                             and ohtype = ' '
     C                             and ohstat = 'O'
     C                             and %subst(oihmsc:17:4) =
     C                                 %subst(ohmisc:17:4)
GFSdA*
GFSdAC                             or client = Getfresh
GFSdAC                             and not %eof(ordh4)
GFSdAC                             and oihtyp = ' '
GFSdAC                             and ohtype = ' '
GFSdAC                             and ohstat = 'O'
GFSdAC                             and %subst(oihmsc:16:2) =
GFSdAC                                 %subst(ohmisc:16:2)
     C                   eval      mrgord = *on
     C                   eval      opnord = ohord
     C                   eval      opnorc = ohcord
     C                   leave
     *
     C                   other
650eAC                   eval      wrgsts = *on
650eDC*                  iter
650eMC                   leave
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKO1  Check if NEW order header has items attached.
     *
     C     zzcko1        begsr
     *
     *    Check to see if any Items attached to NEW Order Header.
     *    If none found, then Delete NEW Order Header record.
     C     odkey         setll     ordd1                                  75
     C                   if        not *in75
     C     ohkey         chain     ordh                               74
     C                   if        not *in74
     C                   delete    ohrec
     C                   endif
     C                   endif
     *
     C                   endsr
GFS A*
GFS A*----------------------------------------------------------------
GFS A*
GFS A*  ZZCVTLBS2QTY  Convert ordered pounds into quantity.
GFS A*                Items with ITCWGT = Y.
GFS A*
GFS AC     zzcvtlbs2qty  begsr
GFS A*
GFS AC**                 eval      detmsg = %editc(oidq1:'X')
GFS AC**                           + '/'
GFS AC**                           + %editc(oidq2:'X')
GFS AC**                           + '/'
GFS AC**                           + %editc(oidq3:'X')
GFS A*
GFS AC                   if        oidq1 > 0
GFSaA*       Store pounds ordered in position 11-15 of Original item#
GFSaAC                   eval      origqty = %editc(oidq1:'X')
GFSaAC                   eval      oidoit  = %replace(origqty:oidoit:11:5)
GFSbAC                   eval      origwgt = oidq1
GFSbA*
GFSbAC                   select
GFSbAC                   when      itumq2 = 0 and itflg1 = 'N'
GFS A*       Convert Cases ordered "pounds" into ordered "quantity".
GFS AC                   eval (h)  oidq1 = oidq1 / itswgt
GFS AC                   if        oidq1 = 0
GFS AC                   eval      oidq1 = 1
GFS AC                   endif
GFSbA*
GFSbA*       Customer ordered less than full case and splittable item.
GFSbAC                   when          oidq1 < itswgt
GFSbAC                             and itumq2 > 0 and itflg1 = 'Y'
GFSbA*
GFSbA*       Compute Brk 1 ship weight for splittable catchwgt item.
GFSbAC                   eval (h)  brk1wgt = itswgt / itumq2
GFSbA*
GFSbA*       Convert Eaches ordered "pounds" into ordered "quantity".
GFSbAC     origwgt       div       brk1wgt       oidq2
GFSbAC                   mvr                     wgtrem
GFSbAC                   if        oidq2 = 0
GFSbAC                             or wgtrem > 0
GFSbAC                   eval      oidq2 = oidq2 + 1
GFSbAC                   endif
GFSbAC                   eval      oidq1 = 0
GFSbA*
GFSbA*       Customer ordered more than full case and splittable item.
GFSbAC                   when          oidq1 >= itswgt
GFSbAC                             and itumq2 > 0 and itflg1 = 'Y'
GFSbA*
GFSbA*       Compute Brk 1 ship weight for splittable catchwgt item.
GFSbAC                   eval (h)  brk1wgt = itswgt / itumq2
GFSbA*
GFSbA*       Convert Cases ordered "pounds" into ordered "quantity".
GFSbAC                   eval      oidq1  = origwgt / itswgt
GFSbA*
GFSbA*       Update remaining wgt after Cases ordered "quantity" computed
GFSbAC                   eval      origwgt = origwgt - (oidq1 * itswgt)
GFSbA*
GFSbA*       Convert Eaches ordered "pounds" into ordered "quantity".
GFSbAC                   if           origwgt > 0
GFSbA*
GFSbAC     origwgt       div       brk1wgt       oidq2
GFSbAC                   mvr                     wgtrem
GFSbAC                   if        oidq2 = 0
GFSbAC                             or wgtrem > 0
GFSbAC                   eval      oidq2 = oidq2 + 1
GFSbAC                   endif
GFSbA*
GFSbAC                   endif
GFSbA*
GFSbAC                   endsl
GFSbA*
GFS AC                   endif
GFS A*
GFSbA*       Ordered "pounds" will always come in OIDQ1 field. per Rich S.
GFSbDC**                 if        oidq2 > 0 and itumq2 > 0
GFSbD*       Convert Brk 1 ordered "pounds" into ordered "quantity".
GFSbDC**                 eval (h)  brk1wgt = itswgt / itumq2
GFSbDC**                 eval (h)  oidq2 = oidq2 / brk1wgt
GFSbDC**                 if        oidq2 = 0
GFSbDC**                 eval      oidq2 = 1
GFSbDC**                 endif
GFSbDC**                 endif
GFS A*
GFS AC                   if        oidq3 > 0 and itumq2 > 0 and itumq3 > 0
GFS A*       Convert Brk 2 ordered "pounds" into ordered "quantity".
GFS AC                   eval (h)  brk1wgt = itswgt / itumq2
GFS AC                   eval (h)  brk2wgt = brk1wgt / itumq3
GFS AC                   eval (h)  oidq3 = oidq3 / brk2wgt
GFS AC                   if        oidq3 = 0
GFS AC                   eval      oidq3 = 1
GFS AC                   endif
GFS AC                   endif
GFS A*
GFS AC                   endsr
GFS A*
GFS A*----------------------------------------------------------------
GFS A*
GFS A*  ZZCVTLBS2QTY2  Convert ordered pounds into quantity.
GFS A*                 Items with ITCWGT = N and ITUM2 = LB
GFS A*
GFS AC     zzcvtlbs2qty2 begsr
GFScA*
GFScAC                   eval      cases  = 0
GFScAC                   eval      eaches = 0
GFScAC                   if        itminq <= 0
GFScAC                   eval      itminq = 1.00
GFScAC                   endif
GFScA*
GFScA*------------------------------------------------------------
GFScA*
GFScA*       Store pounds ordered in position 11-15 of Original item#
GFScAC                   eval      origqty = %editc(oidq2:'X')
GFScAC                   eval      oidoit  = %replace(origqty:oidoit:11:5)
GFScAC                   eval      origwgt = oidq2
GFScA*
GFScAC                   select
GFScA*-----------------------------------
GFScA*    Item ordered in Whole Pounds.
GFSiMC                   when        (oidpo = '0000000  '
GFSiMC                             or oidpo = '         ')
GFSiAC                             and gfsik1_ikupcvt = 'Y'
GFScA*
GFScA*       Convert Brkdwn 1 ordered "pounds" into ordered "quantity" Cases.
GFScAC                   eval      cases = oidq2 / itumq2
GFScAC                   eval      oidq1 = oidq1 + cases
GFScA*
GFScA*       Convert Cases ordered "pounds" into ordered "quantity" Brkdown 1.
GFScAC                   eval (h)  oidq2 = (oidq2 - (cases * itumq2))
GFScAC                                           / itminq
GFScA*        Prevent ordered qty ending up zero.
GFScAC                   if        oidq2 = 0
GFScAC****               eval      oidq2 = 1
GFScAC                   endif
GFScA*
GFScA*----------------------------------
GFScA*    Item ordered in Pounds/Ounces.
GFScAC                   when      oidpo > '0000000  '
GFSiAC                             and gfsik1_ikupcvt = 'Y'
GFScA*
GFScA*       Extract actual ordered "pounds/ounces" into working ship wgt field.
GFScAC                   eval      ordwgt = %dec(oidpo:7:2)
GFScA*       Set flag that item was ordered in Pounds/Ounces. Needed at export.
GFScAC                   eval      oidoit  = %replace('Y':oidoit:10:1)
GFScA*
GFScA*       Convert Brkdwn 1 ordered "pounds" into ordered "quantity" Cases.
GFScAC                   eval      cases = ordwgt / itumq2
GFScAC                   eval      oidq1 = oidq1 + cases
GFScA*
GFScA*       Convert Cases ordered "pounds" into ordered "quantity" Brkdown 1.
GFScAC                   eval (h)  oidq2 = (ordwgt - (cases * itumq2))
GFScAC                                           / itminq
GFScA*        Prevent ordered qty ending up zero.
GFScAC                   if        oidq2 = 0
GFScAC***                eval      oidq2 = 1
GFScAC                   endif
GFScA*
GFScAC                   endsl
GFScA*
GFScAC                   endsr
GFSeA*
GFSeA*----------------------------------------------------------------
GFSeA*
GFSeA*  ZZCVTLBS2QTY3  Convert ordered pounds into quantity.
GFSeA*                 Items with ITCWGT = N and ITUM3 = LB
GFSeA*
GFSeAC     zzcvtlbs2qty3 begsr
GFSeA*
GFSeAC                   eval      cases  = 0
GFSeAC                   eval      eaches = 0
GFSeAC                   if        itminq <= 0
GFSeAC                   eval      itminq = 1.00
GFSeAC                   endif
GFSeA*
GFSeA*------------------------------------------------------------
GFSeA*
GFSeA*       Store pounds ordered in position 11-15 of Original item#
GFSeAC                   eval      origqty = %editc(oidq3:'X')
GFSeAC                   eval      oidoit  = %replace(origqty:oidoit:11:5)
GFSeAC                   eval      origwgt = oidq3
GFSeA*
GFSeAC                   select
GFSeA*-----------------------------------
GFSeA*    Item ordered in Whole Pounds.
GFSiMC                   when        (oidpo = '0000000  '
GFSiMC                             or oidpo = '         ')
GFSiAC                             and gfsik1_ikupcvt = 'Y'
GFSeA*
GFSeA*       Convert Brkdwn 2 ordered "pounds" into ordered "quantity" Cases.
GFSeAC                   eval      cases = oidq3 / itumq3
GFSeAC                   eval      oidq1 = oidq1 + cases
GFSeA*
GFSgM*       Convert Eaches ordered "pounds" into remaining ordered "pounds".
GFSeAC                   eval (h)  oidq3 = (oidq3 - (cases * itumq3))
GFSgDC*                                          / itminq
GFSeA*
GFSgM*       Convert Brkdwn 2 ordered "pounds" into ordered "quantity" Brkdown 1.
GFSfAC                   if        itminq > 1
GFSgAC                             and oidq3 / itminq >= itumq2
GFSeAC                   eval      eaches = oidq3 / itminq
GFSeAC                   eval      oidq2 = oidq2 + eaches
GFSfAC                   endif
GFSeA*
GFSeA*       Convert Eaches ordered "pounds" into ordered "quantity" Brkdown 2.
GFSeAC                   eval (h)  oidq3 = (oidq3 - (eaches * itminq))
GFSeAC                                           / itminq
GFSeA*        Prevent ordered qty ending up zero.
GFSeAC                   if        oidq3 = 0
GFSeAC***                eval      oidq3 = 1
GFSeAC                   endif
GFSeA*
GFSeA*       Convert Brkdwn 1 ordered qty into ordered Cases.
GFSeAC                   if        oidq2 >= itumq2
GFSeAC                   eval      cases = oidq2 / itumq2
GFSeAC                   eval      oidq1 = oidq1 + cases
GFSeAC                   eval      oidq2 = oidq2 - (cases * itumq2)
GFSeAC                   endif
GFSeA*
GFSeA*----------------------------------
GFSeA*    Item ordered in Pounds/Ounces.
GFSeAC                   when      oidpo > '0000000  '
GFSiAC                             and gfsik1_ikupcvt = 'Y'
GFSeA*
GFSeA*       Extract actual ordered "pounds/ounces" into working ship wgt field.
GFSeAC                   eval      ordwgt = %dec(oidpo:7:2)
GFSeA*
GFSeA*       Convert Brkdwn 2 ordered "pounds" into ordered "quantity" Eaches.
GFSeAC                   eval      cases = ordwgt / itumq3
GFSeAC                   eval      oidq1 = oidq1 + cases
GFSeA*
GFSgM*       Convert Eaches ordered "pounds" into remaining ordered "pounds".
GFSeAC                   eval (h)  oidq3 = (ordwgt - (cases * itumq3))
GFSgDC*                                          / itminq
GFSeA*
GFSeA*       Convert Cases ordered "pounds" into ordered "quantity" Brkdown 1.
GFSfAC                   if        itminq > 1
GFSgAC                             and oidq3 / itminq >= itumq2
GFSeAC                   eval      eaches = oidq3 / itminq
GFSeAC                   eval      oidq2 = oidq2 + eaches
GFSeAC                   endif
GFSeA*
GFSeA*       Convert Eaches ordered "pounds" into ordered "quantity" Brkdown 2.
GFSeAC                   eval (h)  oidq3 = (oidq3 - (eaches * itminq))
GFSeAC                                           / itminq
GFSeA*        Prevent ordered qty ending up zero.
GFSeAC                   if        oidq3 = 0
GFSeAC***                eval      oidq3 = 1
GFSeAC                   endif
GFSeA*
GFSeA*       Convert Brkdwn 1 ordered qty into ordered Cases.
GFSeAC                   if        oidq2 >= itumq2
GFSeAC                   eval      cases = oidq2 / itumq2
GFSeAC                   eval      oidq1 = oidq1 + cases
GFSeAC                   eval      oidq2 = oidq2 - (cases * itumq2)
GFSeAC                   endif
GFSeA*
GFSeAC                   endsl
GFSeA*
GFSeAC                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZCRXD   Use DRISLOT with %CRTXDOCK to create new cross dock
650aA*           slot if one does not exist.  Then use %ALLOCATE to
650aA*           put the qty into the slot.
650aA*
650aAC     zzcrxd        begsr
650aA*
650aAC                   exsr      clr$slot
650aAC                   eval      $slwhseu = *on
650aAC                   eval      $slwhse  = oidwhs
650aAC                   eval      $slwhdpu = *on
650aAC                   eval      $slwhdp  = itwhdp
650aAC                   eval      $slitemu = *on
650aAC                   eval      $slitem  = oiditm
650aAC                   eval      $slaislu = *on
CSP AC                   if        client = CoastalSunbelt
CSP AC                   eval      $slaisl = 'JIT'
CSP AC                   else
650aAC                   eval      $slaisl  = 'XDK'
CSP AC                   endif
650aAC                   eval      $dricommand = '*SLOT'
650aAC                   eval      $drisubcmd = '%CRTXDOCK'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      ck4err = *on
650aAC                   exsr      zzzdricop
650gA*
650gA*      Cross dock slot on file for item. Turn off error.
650gAC                   if        $drireturn = 'XDKEXIST'
650gAC                   eval      error = '0'
650gAC                   endif
650gA*
650aAC                   if        error = *on
650aAC                   goto      endcrxd
650aAC                   endif
650aA*
650aA*  Use DRISLOT/%ALLOCATE to put the qty into the slot.
650aA*
650aAC                   eval      $dricommand = '*SLOT'
650aAC                   eval      $drisubcmd = '%ALLOCATE'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      $saitemu = *on
650aAC                   eval      $saitem  = $slitem
650aAC                   eval      $sldispu = *on
650aAC                   eval      $saqtyu = *on
650aAC                   eval      $saqty1 = oidq1
650aAC                   eval      $saqty2 = oidq2
650aAC                   eval      $saqty3 = oidq3
650aAC                   eval      ck4err = *on
650aAC                   exsr      zzzdricop
650aAC                   if        error = *on
650aAC                   goto      endcrxd
650aAC                   endif
650gA*
650gA*      XDK item processed successfully. Add to order.
650gAC                   eval      good2 = 'Y'
650aA*
650aAC     endcrxd       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETHM   Get order header misc. file rcd. (with/without) record lock.
     *
     C     zzgethm       begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     hmkey         chain(n)  ordhm
     *
     C                   when      rcdlck = *on
     C     hmkey         chain     ordhm
     *
     C                   endsl
     *
     *    Order header misc. record not found. Clear misc fields.
     C                   if        not %found(ordhm)
     C                   eval      hmmsc1 = ' '
     C                   eval      hmmsc2 = ' '
     C                   eval      hmmsc3 = ' '
     C                   eval      hmmsc4 = ' '
     C                   eval      hmmsc5 = ' '
     C                   endif
     *
     C                   endsr
GFSiA*
GFSiA*----------------------------------------------------------------
GFSiA*
GFSiA*  ZZGETIK   Get Item Master Misc. file rcd.
GFSiA*
GFSiAC     zzgetik       begsr
GFSiA*
GFSiAC     itkey         chain     itemext1
GFSiAC                   if        not %found(itemext1)
GFSiAC                   eval      ikmsc1 = ' '
GFSiAC                   eval      ikmsc2 = ' '
GFSiAC                   eval      ikmsc3 = ' '
GFSiAC                   eval      ikmsc4 = ' '
GFSiAC                   eval      ikmsc5 = ' '
GFSiAC                   endif
GFSiAC                   eval      gfsik1_base = ikmsc1
GFSiA*
GFSiAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGTOD  Get order detail record. (with/without) record lock.
     *
     C     zzgtod        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     od1key        chain(n)  ordd1                              75
     *
     C                   when      rcdlck = *on
     C     od1key        chain     ordd1                              75
     *
     C                   endsl
     *
     *    Order detail line item not found. Clear qty fields.
     C                   if        *in75
     C                   eval      odqor1 = *zeros
     C                   eval      odqor2 = *zeros
     C                   eval      odqor3 = *zeros
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTOM  Get order detail misc. file rcd. (with/without) record lock.
     *
     C     zzgtom        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     omkey         chain(n)  orddm
     *
     C                   when      rcdlck = *on
     C     omkey         chain     orddm
     *
     C                   endsl
     *
     *    Order detail line item not found. Clear misc fields.
     C                   if        not %found(orddm)
     C                   eval      omodsc = ' '
     C                   eval      ompdsc = 'N'
     C                   eval      ompdsc = 'N'
     C                   eval      omrdsc = 'N'
     C                   eval      omcbox = 'N'
     C                   eval      omcexp = 'N'
     C                   eval      ommsc1 = ' '
     C                   eval      ommsc2 = ' '
     C                   eval      ommsc3 = ' '
     C                   eval      ommsc4 = ' '
     C                   eval      ommsc5 = ' '
     C                   endif
     *
     C                   endsr
GFShA*
GFShA*----------------------------------------------------------------
GFShA*
GFShA*  ZZUPCVTQTY  Upconvert Order Qty.
GFShA*
GFShAC     zzupcvtqty    begsr
GFShA*
GFShA*      Find last order detail line number.
GFShAC     oidkey        setgt     impfordd8
GFShAC     oidkey        readpe    impfordd8
GFShAC                   if        not %eof(impfordd8)
GFShAC                   eval      newoidseq = oidseq
GFShAC                   else
GFShAC                   eval      newoidseq = 1
GFShAC                   endif
GFShAC                   eval      lastorddet = newoidseq
GFShA*
GFShA*      Look for items to be up-qty converted.
GFShAC                   eval      eofd = *off
GFShAC     oidkey        setll     impfordd8
GFShAC                   dou       eofd = *on
GFShAC     oidkey        reade     impfordd8
GFShAC                   if           %eof(impfordd8)
GFShAC                             or oidseq > lastorddet
GFShAC                   leave
GFShAC                   endif
GFShA*
GFShAC                   eval      wrtcasercd      = '*NO '
GFShAC                   eval      gfsdm2_omupcv   = 'N'
GFShAC                   eval      gfsdm2_omorditm = ' '
GFShAC                   eval      gfsdm2_omcvqty  = 0
GFShAC                   eval      gfsdm2_omorgq1  = 0
GFShAC                   eval      gfsdm2_omorgq2  = 0
GFShAC                   eval      gfsdm2_omorgq3  = 0
GFShA*
GFShAC     oimkey        chain     impforddm8
GFShA*      Host didn't send rcd, so initialize it.
GFShAC                   if        not %found(impforddm8)
GFShAC                   eval      oimwhs = oidwhs
GFShAC                   eval      oimdiv = oiddiv
GFShAC                   eval      oimord = oidord
GFShAC                   eval      oimseq = oidseq
GFShAC                   eval      oimitm = oiditm
GFShAC                   eval      oimdsc = ' '
GFShAC                   eval      oimpds = 'Y'
GFShAC                   eval      oimrds = 'Y'
GFShAC                   eval      oimbox = 'N'
GFShAC                   eval      oimexp = 'N'
GFShAC                   eval      oimms1 = ' '
GFShAC                   eval      gfsdm2_base    = ' '
GFShAC                   eval      gfsdm2_omupcv  = 'N'
GFShAC                   eval      gfsdm2_omcvqty = 0
GFShAC                   eval      gfsdm2_omorgq1 = 0
GFShAC                   eval      gfsdm2_omorgq2 = 0
GFShAC                   eval      gfsdm2_omorgq3 = 0
GFShAC                   eval      oimms2 = gfsdm2_base
GFShAC                   eval      oimms3 = ' '
GFShAC                   eval      oimms4 = ' '
GFShAC                   eval      oimms5 = ' '
GFShAC                   else
GFShA*
GFShA*      Record has already been up-converted. Read next rcd.
GFShAC                   if        %subst(oimms2:1:1) = 'Y'
GFShAC                   iter
GFShAC                   else
GFShA*
GFShAC                   eval      gfsdm2_base    = oimms2
GFShAC                   eval      gfsdm2_omupcv  = 'N'
GFShAC                   eval      gfsdm2_omorditm= ' '
GFShAC                   eval      gfsdm2_omcvqty = 0
GFShAC                   eval      gfsdm2_omorgq1  = 0
GFShAC                   eval      gfsdm2_omorgq2  = 0
GFShAC                   eval      gfsdm2_omorgq3  = 0
GFShAC                   eval      oimms2 = gfsdm2_base
GFShAC                   endif
GFShA*
GFShAC                   endif
GFShA*
GFShAC     itkey         chain     piritem
GFSiAC                   exsr      zzgetik
GFShAC                   select
GFShA*      If Item Master item isn't found, bypass qty conversion check.
GFShAC                   when      not %found(piritem)
GFShA*      Check next item on order.
GFShAC                   iter
GFShA*
GFShAC                   when         (itum2 = 'LB'
GFShAC                             and oidq2 > 0)
GFShAC                             or (itum3 = 'LB'
GFShAC                             and oidq3 > 0)
GFShA*      Lbs Splits items bypassed for this process.
GFShAC                   iter
GFShA*
GFShAC                   when          itumq2 > 0
GFShAC                             and oidq2 < itumq2
GFShAC                             and oidq2 > 0
GFShA*
GFShAC                             or  itumq3 > 0
GFShAC                             and oidq3 < itumq3
GFShAC                             and oidq3 > 0
GFShA*      Qty less than breakdown qty's.
GFShAC                   iter
GFShAC                   endsl
GFShA*
GFShA*      Begin Item Up-Qty Conversion process.
GFShA*
GFShAC                   select
GFShA*
GFShA*------------------------------------------------------
GFShA*        Breakdown 1 Order Qty greater than item breakdown qty.
GFShAC                   when          oidq2 >= itumq2
GFShAC                             and itumq2 > 0
GFShAC                             and itflg1 = 'Y'
GFSiAC                             and gfsik1_ikupcvt = 'Y'
GFShA*
GFShAC                   eval      ordcases  = oidq2 / itumq2
GFShAC                   eval      ordeaches = ordcases * itumq2
GFShAC                   eval      partcase  = oidq2 - ordeaches
GFShA*      Save original order qty.
GFShAC                   eval      gfsdm2_omorgq1  = oidq1
GFShAC                   eval      gfsdm2_omorgq2  = oidq2
GFShAC                   eval      gfsdm2_omorgq3  = oidq3
GFShA*
GFShA*      Eaches ordered converted to full cases.
GFShAC                   if        partcase = 0
GFShAC                   eval      oidq1  = ordcases
GFShAC                   eval      oidq2  = 0
GFShA*
GFShAC                   else
GFShA*      Eaches ordered converted to full cases w/eaches left over.
GFShAC                   eval      oidq1  = ordcases
GFShAC                   eval      oidq2  = partcase
GFShAC                   eval      wrtcasercd = '*NO '
GFShAC                   endif
GFShA*
GFShA*      Load conversion information.
GFShAC                   eval      gfsdm2_omupcv = 'Y'
GFShAC                   eval      gfsdm2_omorditm = oiditm
GFShAC                   eval      gfsdm2_omcvqty  = itumq2
GFShA*
GFShA*      Load conversion information to file field.
GFShAC                   eval      oimms2 = gfsdm2_base
GFShA*
GFShA*      Create Order Detail Misc. import record.
GFShAC                   if        not %found(impforddm8)
GFShAC                   write     oimrec
GFShAC                   else
GFShAC                   update    oimrec
GFShAC                   endif
GFShA*
GFShA*      Save orginal order line number.
GFShAC                   eval      oidor2 = oidseq
GFShAC                   update    oidrec
GFShA*
GFShA*------------------------------------------------------
GFShA*        Breakdown 2 Order Qty greater than item breakdown qty.
GFShAC                   when          oidq3 >= itumq3
GFShAC                             and itumq3 > 0
GFShAC                             and itflg2 = 'Y'
GFSiAC                             and gfsik1_ikupcvt = 'Y'
GFShA*
GFShAC                   eval      ordcases  = oidq3 / itumq3
GFShAC                   eval      ordeaches = ordcases * itumq3
GFShAC                   eval      partcase  = oidq3 - ordeaches
GFShA*      Save original order qty.
GFShAC                   eval      gfsdm2_omorgq1  = oidq1
GFShAC                   eval      gfsdm2_omorgq2  = oidq2
GFShAC                   eval      gfsdm2_omorgq3  = oidq3
GFShA*
GFShA*      Eaches ordered converted to full cases.
GFShAC                   if        partcase = 0
GFShAC                   eval      oidq1  = ordcases
GFShAC                   eval      oidq2  = 0
GFShAC                   eval      oidq3  = 0
GFShA*
GFShAC                   else
GFShA*      Eaches ordered converted to full cases w/eaches left over.
GFShAC                   eval      oidq1  = ordcases
GFShAC                   eval      oidq2  = 0
GFShAC                   eval      oidq3  = partcase
GFShAC                   eval      wrtcasercd = '*NO '
GFShAC                   endif
GFShA*
GFShA*      Load conversion information.
GFShAC                   eval      gfsdm2_omupcv = 'Y'
GFShAC                   eval      gfsdm2_omorditm = oiditm
GFShAC                   eval      gfsdm2_omcvqty  = itumq3
GFShA*
GFShA*      Load conversion information to file field.
GFShAC                   eval      oimms2 = gfsdm2_base
GFShA*
GFShA*      Create Order Detail Misc. import record.
GFShAC                   if        not %found(impforddm8)
GFShAC                   write     oimrec
GFShAC                   else
GFShAC                   update    oimrec
GFShAC                   endif
GFShA*
GFShA*      Save orginal order line number.
GFShAC                   eval      oidor2 = oidseq
GFShAC                   update    oidrec
GFShA*
GFShAC                   endsl
GFShA*
GFShAC                   enddo
GFShA*
GFShAC                   endsr
GFShA*
     *----------------------------------------------------------------
     *
     *  ZZXDCK  Attach cross dock item to PO detail line.
     *
     C     zzxdck        begsr
     *
     *    Retrieve Open item order detail line
     C                   if        mrgrte = *on  and
     C                             mrgord = *on
     C                   eval      rcdlck = *off
     C                   exsr      zzgtod
     C                   endif
     *
     *    If we find this item on an existing Open Order and the codes
     *    don't match or this is a cross dock item, force item to New
     *    Route, New Order.
     C                   if        mrgrte = *on  and
     C                             mrgord = *on  and
     C                             *in75  and
     C                             oidspc <> odspcl  or
     *
     C                             oidspc = 'XD'
     C                   eval      wrgsts = *on
     C                   endif
     *
     * Only work with cross dock items.
     C                   if        oidspc <> 'XD'
     C                   eval      good2 = 'Y'
     C                   goto      endxd
     C                   endif
650aA*
650aA* Create cross dock slot if it doesn't already exist.
650aA* Put allocated qty into slot.
650aAC                   exsr      zzcrxd
650aA*
     *
     C     endxd         endsr
     *----------------------------------------------------------------
     *
     *  ZZXDELXDK   Delete status 'Z' XDK slots
     *
     C     zzzDelXDK     begsr

     C                   eval      kyaisl = 'XDK'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
     *
     *      Delete matching record from Cross Dock file.
     C     cdkey         setll     crossdk
     C                   dow       forevr = forevr
     C     cdkey         reade     crossdk
     C                   if        %eof(crossdk)
     C                   leave
     C                   endif
     C
     C                   delete    cdrec
     C                   enddo
     *
     C                   endif
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   write     head2
     C                   add       2             count
     C                   write     head3
     C                   add       2             count
     C                   write     head4
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*  zzzdricop  Call DRICOP
650aA*----------------------------------------------------------------
650aA
650aAC     zzzdricop     begsr
650aAC                   eval      error = *off
650aA
650aAC                   select
650aAC                   when      $dricommand = '*SLOT'
650aAC                   eval      $dridata = $slot
650aAC                   eval      $dridata2 = $slot2
650aAC                   when      $dricommand = '*XDOCK'
650aAC                   eval      $dridata = $xdock
650aAC                   when      $dricommand = '*LICINFO'
650aAC                   eval      $dridata = $licinfo
650aAC                   when      $dricommand = '*LICHIST'
650aAC                   eval      $dridata = $lichist
650aAC                   when      $dricommand = '*LICENSE'
650aAC                   eval      $dridata = $license
650aAC                   eval      $dridata2 = $license2
650aAC                   when      $dricommand = '*ITEM'
650aAC                   eval      $dridata = $item
650aAC                   eval      $dridata2 = $item2
650aAC                   endsl
650aA
650aAC                   if        $dricommand = '*ITEM'
650aAC                             or $dricommand = '*SLOT'
650aAC                             or $dricommand = '*LICENSE'
650aAC                   call(e)   'DRICOP'
650aAC                   parm                    $dricommand
650aAC                   parm                    $drisubcmd
650aAC                   parm                    $drisys2upd
650aAC                   parm      #prog         $driprogram
650aAC                   parm      ' '           $drireturn
650aAC                   parm      ' '           $drimessage
650aAC                   parm                    $dridata
650aAC                   parm                    $dridata2
650aAC                   else
650aAC                   call(e)   'DRICOP'
650aAC                   parm                    $dricommand
650aAC                   parm                    $drisubcmd
650aAC                   parm                    $drisys2upd
650aAC                   parm      #prog         $driprogram
650aAC                   parm      ' '           $drireturn
650aAC                   parm      ' '           $drimessage
650aAC                   parm                    $dridata
650aAC                   endif
650aA
650aAC                   select
650aA
650aAC                   when      %error and ck4err = *on
650aAC                   eval      error = *on
650aA
650aAC                   when      $drireturn <> '*OK' and ck4err = *on
650aAC                   eval      error = *on
650aA
650aAC                   endsl
650aA
650aAC                   select
650aAC                   when      $dricommand = '*SLOT'
650aAC                   eval      $slot = $dridata
650aAC                   eval      $slot2 = $dridata2
650aAC                   when      $dricommand = '*XDOCK'
650aAC                   eval      $xdock = $dridata
650aAC                   when      $dricommand = '*LICINFO'
650aAC                   eval      $licinfo = $dridata
650aAC                   when      $dricommand = '*LICHIST'
650aAC                   eval      $lichist = $dridata
650aAC                   when      $dricommand = '*LICENSE'
650aAC                   eval      $license = $dridata
650aAC                   eval      $license2 = $dridata2
650aAC                   when      $dricommand = '*ITEM'
650aAC                   eval      $item = $dridata
650aAC                   eval      $item2 = $dridata2
650aAC                   endsl
650aA
650aAC     enddricop     endsr
650aA
650aA*----------------------------------------------------------------
650aA*     ZZZS2D - Copy slot fields into data structure fields.
650aA*
650aAC     zzzs2d        begsr
650aA*
650aAC                   eval      $slwhseu = *on
650aAC                   eval      $slwhse = slwhse
650aA*
650aAC                   eval      $slwhdpu = *on
650aAC                   eval      $slwhdp = slwhdp
650aA*
650aAC                   eval      $sldispu = *on
650aAC                   eval      $sldisp = sldisp
650aA*
650aAC                   eval      $slaislu = *on
650aAC                   eval      $slaisl = slaisl
650aA*
650aAC                   eval      $sllocu = *on
650aAC                   eval      $slloc = slloc
650aA*
650aAC                   eval      $slrlvlu = *on
650aAC                   eval      $slrlvl = slrlvl
650aA*
650aAC                   eval      $slhandu = *on
650aAC                   eval      $slhand = slhand
650aA*
650aAC                   eval      $slsideu = *off
650aAC                   eval      $slside = slside
650aA*
650aAC                   eval      $slstypu = *off
650aAC                   eval      $slstyp = slstyp
650aA*
650aAC                   eval      $slstatu = *off
650aAC                   eval      $slstat = slstat
650aA*
650aAC                   eval      $slsdteu = *off
650aAC                   eval      $slsdte = slsdte
650aA*
650aAC                   eval      $slstimu = *off
650aAC                   eval      $slstim = slstim
650aA*
650aAC                   eval      $slsdefu = *off
650aAC                   eval      $slsdef = slsdef
650aA*
650aAC                   eval      $sldesgu = *off
650aAC                   eval      $sldesg = sldesg
650aA*
650aAC                   eval      $slactvu = *off
650aAC                   eval      $slactv = slactv
650aA*
650aAC                   eval      $slbldu = *off
650aAC                   eval      $slbld = slbld
650aA*
650aAC                   eval      $slpicku = *off
650aAC                   eval      $slpick = slpick
650aA*
650aAC                   eval      $slpsequ = *off
650aAC                   eval      $slpseq = slpseq
650aA*
650aAC                   eval      $slprtyu = *off
650aAC                   eval      $slprty = slprty
650aA*
650aAC                   eval      $slentdu = *off
650aAC                   eval      $slentd = slentd
650aA*
650aAC                   eval      $slexpdu = *off
650aAC                   eval      $slexpd = slexpd
650aA*
650aAC                   eval      $slslfdu = *off
650aAC                   eval      $slslfd = slslfd
650aA*
650aAC                   eval      $slrsrvu = *off
650aAC                   eval      $slrsrv = slrsrv
650aA*
650aAC                   eval      $slitemu = *off
650aAC                   eval      $slitem = slitem
650aA*
650aAC                   eval      $slstk1 = slstk1
650aAC                   eval      $slstk2 = slstk2
650aAC                   eval      $slstk3 = slstk3
650aAC                   eval      $slalc1 = slalc1
650aAC                   eval      $slalc2 = slalc2
650aAC                   eval      $slalc3 = slalc3
650aAC                   eval      $sltfr1 = sltfr1
650aAC                   eval      $sltfr2 = sltfr2
650aAC                   eval      $sltfr3 = sltfr3
650aAC                   eval      $slpck1 = slpck1
650aAC                   eval      $slpck2 = slpck2
650aAC                   eval      $slpck3 = slpck3
650aAC                   eval      $slrcv1 = slrcv1
650aAC                   eval      $slrcv2 = slrcv2
650aAC                   eval      $slrcv3 = slrcv3
650aAC                   eval      $slphy1 = 0
650aAC                   eval      $slphy2 = 0
650aAC                   eval      $slphy3 = 0
650aAC                   eval      $slavl1 = 0
650aAC                   eval      $slavl2 = 0
650aAC                   eval      $slavl3 = 0
650aAC                   eval      $sladj1 = 0
650aAC                   eval      $sladj2 = 0
650aAC                   eval      $sladj3 = 0
650aA*
650aAC                   eval      $saitemu = *off
650aAC                   eval      $saitem = *blanks
650aA*
650aAC                   eval      $saqtyu = *off
650aAC                   eval      $saqty1 = 0
650aAC                   eval      $saqty2 = 0
650aAC                   eval      $saqty3 = 0
650aA*
650aAC                   eval      $saorgu = *off
650aAC                   eval      $saorg1 = 0
650aAC                   eval      $saorg2 = 0
650aAC                   eval      $saorg3 = 0
650aA*
650aAC                   eval      $sacwtau = *off
650aAC                   eval      $sacwta = 0
650aA*
650aAC                   eval      $sacodeu = *off
650aAC                   eval      $sacode = *blanks
650aA*
650aAC                   eval      $samemou = *off
650aAC                   eval      $samemo = *blanks
650aA*
650aAC                   eval      $sabyu = *off
650aAC                   eval      $saby = *blanks
650aA*
650aAC                   eval      $sadateu = *off
650aAC                   eval      $sadate = 0
650aA*
650aAC                   eval      $satimeu = *off
650aAC                   eval      $satime = 0
650aA*
650aAC                   eval      $saFrmVrfyu = *off
650aAC                   eval      $saFrmVrfy = *blanks
650aA*
650aAC                   eval      $satrn#u = *off
650aAC                   eval      $satrn# = 0
650aA*
650aAC                   eval      $saFrmLcnsu = *off
650aAC                   eval      $saFrmLcns = *blanks
650aA*
650aAC                   eval      $satasku = *off
650aAC                   eval      $satask = *blanks
650aA*
650aAC                   eval      $sacdspu = *off
650aAC                   eval      $sacdsp = *blanks
650aA*
650aAC                   endsr
650aA*
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*EXIST*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID X-DOCK PO*
*XDK SLOT ERROR*
*NO XDK REC CREATED*
**
Import FTP Orders
**   OVRPRTF statment
OVRPRTF FILE(OI3251PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI325PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
