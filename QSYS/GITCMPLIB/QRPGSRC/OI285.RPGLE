500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI285     Import FTP orders - Post
     *  26 February 1999
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    01/21/09  MLB  5.20
     *      - Created.
520aA*    01/22/09  CWM  5.20a
     *      - Added Stop Cross Reference File Create.
     *
530 A*    11/20/09  MLB  5.30
     *      - Enh: Revised OI2551PR to add format DETAIL 22 which
     *        will print item pack/size on exception report.
530aA*    12/07/09  MLB  5.30a
     *      - Enh: Revised tmpcub, tmpwgt to reference rsordc, rsordw
     *        to prevent field overflow errors on cube, wgt.
530bA*    04/07/10  MLB  5.30b
     *      - Fix: Change to divide ITSWGT by brk qty to calculate wgt
     *        for type 'S' item.
530cA*    11/04/10  MLB  5.30c
     *      - Enh: Revised program to override to outq instead of device.
     *        From: OVRPRTF FILE(OI2851PR) OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
     *        From: OVRPRTF FILE(OI285PR) OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
530dA*    10/05/10  RBD  5.30d
     *      - Eliminated use of PODTL1 file as we no longer need to
     *        capture the po seq for the CROSSDK file.  Eventually
     *        the CROSSDK file will be eliminated altogether.
     *        This is possible because cross dock PO detail records
     *        will now be marked as 'XD' records in field PDSPCL.
     *      - Revised subr ZZXDCK to replace code which updates and
     *        writes slot records to instead use new subr ZZCRXD
     *        to call DRISLOT with %CRTXDOCK for all XD items and
     *        use %ALLOCATE to put the qty into the slot.
     *
640 A*    05/16/11  MLB  6.40
     *      - Fix: Revised program to use RTEHED2 when checking for
     *        Open routes. If a route was deleted, then re-imported
     *        the program was not finding the Open RTEHED rcd.
     *      - Fix: Revised program to correct duplicate key error
     *        when writing out ORDHM rcd for existing order.
     *      - Fix: Revised program to correct duplicate key error
     *        when writing out ORDDM rcd for existing order.
640aA*    05/19/11  MLB  6.40a
     *      - Fix: Revised program to move clearing of fields NEWRTE
     *        and NEWRTC. Fields were being cleared before they could
     *        be used by routine ZZCKR1.  This was causing a route header
     *        to be left behind with zero orders attached.
640bA*    07/18/11  MLB  6.40b
     *      - Fix: Revised varianble SUBLIN to be 7,0 from 3,0. Orders
     *        greater than 999 lines causes RNQ0103 Variable too small
     *        to hold result error.
640cA*    10/06/11  MLB  6.40c
     *      - Enh: Revised program to set RHSHPD, position 8=5=Importing
     *        when RTEHED record is written to file. This is being done
     *        to prevent users from attempting to process route before
     *        all orders have been written out for the route.
     *
650 A*    04/21/13  MLB  6.50
     *      - Fix: Revised program to correct error handling when writing
     *        record to ORDDM and duplicate key error occurs. This
     *        happens the same order detail line appears in the order
     *        more than once for a new order on a new route.
     *
650aA*    05/22/13  RBD  6.50a
     *      - Reserved, revisions to come.
650bA*    12/27/13  DAS  6.50b
     *      - Revised to use CHKIUSE2 instead of setting RHSHPD.
     *      - No longer uses rhshpd for inuse flag.
     *      - Requires new CHKIUSE2 progam and new RTEINUSE file.
650cA*    02/11/13  DAS  6.50c
     *      - Revised *CLEAR to use newrte instead of newrtc.
650d *    06/23/14  RTR  6.50d
     *      - FIX: When updating an existing route, duplicate records
     *        were being written to RTESTP, and if merging routes
     *        OI300 was being called with the wrong route id. This
     *        left extra RTESTP records with a zero RTSSTP, which
     *        caused problems with stop sorting in Drag & Drop TB
     *        because it sorts by RTSSTP but displays RTSST5. Program
     *        will now check for existing RTESTP record before writing
     *        and on last OI300 call use last OHRTE instead if the new
     *        route ID retrieved. This also explains extra route ID
     *        numbers that never appear in RTEHED.
650eA*    07/28/14  MLB  6.50e
     *      - Fix: Revised program to prevent string error when OHWHS
     *        is zero.
700a *    08/21/16  RTR  7.00a
     *      - Fix: 6.50d mod logic worked for single route, but not
     *        for multiple routes in single import. Added to other
     *        OI300 call.
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Recompiled for RTESTP changes.
710bA*    01/05/18  DAS  7.10b
     *      - Enh: Initializing RTESTP field RTSSD.
     *
720 A*    05/16/18  MLB  7.20
     *      - Fix: Revised program to populate RTSSD with contents of
     *        RTSST5. Correction to 7.10a mod.
720a *    08/23/18  RTR  7.20a
     *      - Enh: For Aspen Canopy, change type R to blank.
750 A*    04/19/21  KDE  7.50
     *      - Enh:  Add logic to process Merge orders for Super Route
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers, Inc.
     *
CBIaA*    01/16/06  DAS  CBIa
     *      - Revised to create a fictitious department PRD in RTESUM
     *        using a specific range of item numbers (405000 - 492999)
     *      - Revised to not call UPDRTE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    06/23/06  MLB  PAK
     *      - Add file CUSTMISC to program.
     *        If customer found in file, load *SP into OHMISC.
     *      - If route number is blank, set OHTYPE=W for Will-Call.
PAKaA*    06/24/06  MLB  PAKa
     *      - Revised program to pass parm back to calling program,
     *        PI260CL that will call SPI260CL to perform p/o import
     *        when delivery type is 'ZPLF'.
PAKbA*    09/08/06  MLB  PAKb
     *      - Revised program to move data sent in OIMDSC field into
     *        Order Detail Misc 1 field in ORDDM file.
PAKcA*    09/18/06  MLB  PAKc
     *      - Change to mod PAKa. P/O import will only be done for
     *        orders coming from warehouses: 200, 300 or 310.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    01/04/09  MLB  HAL
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIR A*    11/17/10  MLB  BIR
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    10/05/10  RBD  CSP
     *      - Delete JIT slots whose status is 'Z'.
     *      - If imported item has a designation code of JIT, force
     *        oidspc and odspcl to be 'XD' so that it will be
     *        processed through the system as a cross dock item.
     *        Force aisle to be 'JIT'.
CSPaA*    03/11/11  MLB  CSPa
     *      - Revised program to scan import customer name field for
     *        a list of special characters and set them to blank if
     *        found. Per email from Stalio, Hemant dated 03/11/11.
     *      - Special char's were causing terminal errors in GUI
     *        Drag/Drop module.
CSPbA*    07/09/19  RH   CSPb
     *      - Process items with designation code 'PC' like JIT items
     *      - Create aisle 'PC' See CSP mod dated 10-05-10
     *      - Create subroutine to delete PC status 'Z' slots
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOF A*    09/11/15  MLB  SOF
     *      - Revised program to use imported item weight/cube for
     *        item# '9999999999' in computations when adding rcds
     *        to RTESUM.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    09/14/15  MLB  VIP
     *      - Revised program to use imported item weight/cube for
     *        item# '9999999999' in computations when adding rcds
     *        to RTESUM.
     *      - Added VIP to SOF mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR A*    11/22/13  MLB  JOR
     *      - Enh: Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *      - Added JOR to HAL mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    01/05/15  RTR  PFCa
     *      - Look up item category (ITEMFLD/IFCAT) and if 'FEE', move
     *        qty ordered to Original Order so that no labels print. A
     *        matching mod should be in RH155 to move qty back for the
     *        export to the host for invoicing.
PFCb *    07/05/18  RTR  PFCb
     *      - Force OMCBOX and OMCEXP to N for Presto.
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
     *  67        - Open of IMPFORDHM or ORDDHM failed.
     *  68        - Open of IMPFORDDM or ORDDM failed.
PFCaA*  71        - EOF for ITEMFLD
     *  78        - EOF for IMPFORDD4
     *  79        - EOF for IMPFORDH4
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfordh4 uf   e           k disk
     Fimpfordhm uf   e           k disk    usropn
     Fimpfordd4 uf   e           k disk
     Fimpforddm uf   e           k disk    usropn
     Fcustmisc  if   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
PFCaAFitemfld   if   e           k disk
530dDF*slot1     uf a e           k disk
530dDF*slot4     uf   e           k disk
530dDF*                                    rename(slrec:slrec4)
     Fslot11    uf   e           k disk
     F                                     rename(slrec:slrec11)
     Frtesum    uf a e           k disk
     Fordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
     Fordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
     Foptions   if   e           k disk
530dDF*podtl1    if   e           k disk
     Frtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
640cDF*rtehed2   if   e           k disk
650bDF*tehed2   uf   e           k disk
650bMFrtehed2   if   e           k disk
640 AF                                     rename(rhrec:rhrec2)
     Frtehed    o  a e           k disk
     Fordh      uf a e           k disk
     Fordhm     uf a e           k disk    usropn
     F*crossdk   o  a e           k disk
     Fcrossdk   uf a e           k disk
     Fordd      o  a e           k disk
     Forddm     uf a e           k disk    usropn
650dDF*rtestp    o  a e           k disk
650dMFrtestp    uf a e           k disk
     Foi285pr   o    e             printer oflind(*in91)
     F                                     usropn
     Foi2851pr  o    e             printer oflind(*in92)
     F                                     usropn

     *----------------------------------------------------------------
530dA*  DRI parameters
     *----------------------------------------------------------------
530dA /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
530dA*  Data Formats
     *----------------------------------------------------------------

530dA /COPY *libl/qcopysrc,C#ITEM
530dA /COPY *libl/qcopysrc,C#LICENSE
530dA /COPY *libl/qcopysrc,C#LICHIST
530dA /COPY *libl/qcopysrc,C#LICINFO
530dA /COPY *libl/qcopysrc,C#SLOT
530dA /COPY *libl/qcopysrc,C#XDOCK

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(6) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
PFCaAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
PFCaAD UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#CHENEY
      /COPY QCOPYSRC,ID#CHENEYO
      /COPY QCOPYSRC,ID#CHENEYR
      /COPY QCOPYSRC,ID#PACKERS
HAL   /copy qcopysrc,id#Halsey
BIR   /copy qcopysrc,id#BiRite
CSP A /COPY QCOPYSRC,Id#Coastal
SOF A /COPY QCOPYSRC,ID#Sofo
VIP A /COPY QCOPYSRC,ID#VIP
JOR A /COPY QCOPYSRC,Id#Jordano
PFCaA /COPY QCOPYSRC,ID#pfc
     *
720aA*----------------------------------------------------------------
720aA* Function prototypes.
720aA*----------------------------------------------------------------
720aA /copy *libl/qcopysrc,p.getopint
720aA /copy *libl/qcopysrc,p.wrtlog
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
650bD*
650bDD**               ds
650bDD**rhiuse                 8      8  0
650bDD**rhshpd                 1      8  0
650bD*
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
CSPaAD spclchar        c                   const('`~!@$%^&*()=+-[{]}\|-
CSPaAD                                     <>/?')
CSPaA* *IMPORTANT* If any special chars are added to string SPCLCHAR,
CSPaA*             NbrSpclChar must be updated for number added.
CSPaAD NbrSpclChar     s              3  0 inz(24)
     *
     *----------------------------------------------------------------
     *  SAP Import Header/Detail Misc. File data structures
     *
      /copy qcopysrc,orddm1_pak
      /copy qcopysrc,orddm2_pak
      /copy qcopysrc,orddm3_pak
      /copy qcopysrc,orddm4_pak
      /copy qcopysrc,orddm5_pak
     *
      /copy qcopysrc,ordhm1_pak
      /copy qcopysrc,ordhm2_pak
      /copy qcopysrc,ordhm3_pak
      /copy qcopysrc,ordhm4_pak
      /copy qcopysrc,ordhm5_pak
     *
SOF A*----------------------------------------------------------------
SOF A*  Retalix Import Detail Misc. File data structure(s)
SOF A*
SOF A /copy qcopysrc,orddm1_rtx
SOF A*
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
530dAD ck4err          s               n
     D count           s              3  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
530dAD error           s               n
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D good1           s              1
     D good2           s              1
720aAD host            s             20a
     D impdte          s              8  0
     D imptim          s              6  0
     D import_po       s              4    inz('*NO ')
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
640 AD kyrhstat        s                   like(rhstat)
640 AD                                     inz('1')
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
530dAD savever#        s                   like($lnver#)
     D skpwrt          s              1
640 AD skpwrthdr       s              1    inz('0')
640 AD skpwrthdrm      s              1    inz('0')
640 AD skpwrtdtlm      s              1    inz('0')
CSPaAD s               s              3  0 inz(0)
CSPaAD start           s              3  0 inz(0)
640bDD*sublin          s              3  0
640bMD sublin          s              7  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
530aDD*tmpcub          s                   like(itcube)
530aMD tmpcub          s                   like(rsordc)
     D tmploc          s              3  0
530aDD*tmpwgt          s                   like(itswgt)
530aMD tmpwgt          s                   like(rsordw)
     D today           s              8  0
     D work3a          s              3
     D wrgsts          s              1
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
530dA*  Program info data structure
     *
530dAD                sds
530dAD  #prog            *proc
530dAD  #job                 244    253
530dAD  #user                254    263
530dAD  #jobn                264    269
530dAD  #jobdt               276    281  0
530dAD  #jobtm               282    287  0
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
     *      $PIMPPO Import purchase order(s) with delivery type='ZPLF'.
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
     C                   kfld                    oihord
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    oidwhs
     C                   kfld                    oiditm
     *
PFCaA* Item field file
PFCaA*
PFCaAC     ifkey         klist
PFCaAC                   kfld                    oidwhs
PFCaAC                   kfld                    oiditm
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
     C                   if        client <> cheney
     C                   exsr      updrte
     C                   endif
     *
     C                   read      impfordh4                              79
     *
     C                   if        *in79
     C                   eval      eofh = *on
520aA*
650dA*  NOTE: this is only at EOF.
520aA*  When route changes, resquence stops in RTESTP file.
520aAC                   if        lstrte <> '@@@@@'
650dA*
650dA*  If merging routes, last route id may be messed up.
650dAC                   if        opmrga = 'Y'
650dAC                   eval      lstrid = ohrte
650dAC                   endif
650dA*
520aAC                   exsr      reseqstp
520aAC                   endif
520aA*
640 A*  Merge order(s) into Open routes allowed.
640 A*  Check if any orders attached to new open route. If no, delete.
640 A*
640 AC                   if        opmrga = 'Y'  and
640 AC                             $ptype = ' '
640 AC                   exsr      zzckr1
640cA*
640cAC                   if        mrgrte = '1'
640cA*  Clear Inuse flag for Open route after updates.
640cAC                   exsr      zzclriuseopn
640cAC                   endif
640cA*
640 AC                   endif
640cA*
640cA*  Clear Inuse flag for New route after updates.
640cAC                   exsr      zzclriusenew
640 A*
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
CSPaA*
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                   exsr      stripspcl
CSPaAC                   endif
CSPaA*
720aA /free
720aA    if host = 'Aspen Canopy';
720aA      if oihtyp = 'R';
720aA        oihtyp = ' ';
720aA      endif;
720aA    endif;
720aA /end-free
720aA*
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
CSP A* Delete all status 'Z' JIT slots.
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP AC                   exsr      zzzdeljit
CSPbA* Delete all status 'Z' PC slots.
CSPbAC                   exsr      zzzdelpc
CSP AC                   endif
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
650eAC                   if        pos = 0
650eAC                   eval      pos = 1
650eAC                   endif
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
640cDC*                  eval      mrgrte = *off
640aDC*                  eval      newrte = *blanks
640aDC*                  eval      newrtc = *blanks
     *
     *  Merge order(s) into Open routes allowed.
     *  Check if Route still at Open status.
     *
     C                   if        opmrga = 'Y'  and
     C                             $ptype = ' '
     C                   exsr      zzckr1
640cA*
640cAC                   if        mrgrte = '1'
640cA*  Clear Inuse flag for Open route after updates.
640cAC                   exsr      zzclriuseopn
640cAC                   endif
640cA*
640cAC                   eval      mrgrte = *off
     C                   exsr      zzckrt
     C                   endif
520aA*
520aA*  When route changes, resequence stops in RTESTP file.
520aAC                   if        lstrte <> '@@@@@'
700aA*
700aA*  If merging routes, last route id may be messed up.
700aAC                   if        opmrga = 'Y'
700aAC                   eval      lstrid = ohrte
700aAC                   endif
700aA*
520aAC                   exsr      reseqstp
640cA*
640cA*  Clear Inuse flag for New route after updates.
640cAC                   exsr      zzclriusenew
640cA*
520aAC                   endif
     *
640aAC                   eval      newrte = *blanks
640aAC                   eval      newrtc = *blanks
     C                   exsr      fillrh
     C                   write     rhrec                                49
650bAC                   eval      $icmd = '*INUSE5'
650bAC                   eval      $irtid = rhrtid
650bAC                   exsr      zziuse
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
     *    Only update ORDHM if impfordhm was sent.
     C                   if        mischdrupd = '*YES'
     C                   exsr      fillhm
     C                   endif
     *
640 AC                   if        skpwrthdr = '0'
     C                   write     ohrec                                49
640 AC                   endif
520aA*
520aA*    Fill Route Extended Stop file
650dA /free
650dA   // first check for existing RTESTP record
650dA   chain (ohwhse: ohrte: ohord) rtestp;
650dA   if %found(rtestp);
650aA
650aA     // if exists and extended stop changed, update
650aA     if rtsst5 <> oihest;
650aA       rtsstp = 0;
650aA       rtsst5 = oihest;
650aA       update rtsrec;
650dA     else;
650aA       unlock rtestp;
650aA     endif;
650aA
650dA   else;
650dA     // wasn't found, so write record
650dA /end-free
520aAC                   exsr      fillxr
520aAC                   write (e) rtsrec
520aAC                   if        %error
520aAC                   endif
650dAC                   endif
     *
     *    Only add to ORDDM if impforddm was sent.
     C                   if        mischdrupd = '*YES'
     C                             and %found(impfordhm)
640 A*
640 AC                   if        skpwrthdrm = '0'
640 DC*                  write     hmrec
640 MC                   write (e) hmrec
     C                   if        %error
650 AC                   eval      *in49 = '1'
     C                   endif
640 AC                   endif
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
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
     C                   eval      excpr1 = *off
     C     oidkey        setll     impfordd4
     C                   dou       eofd = *on
     *
     C     oidkey        reade     impfordd4                              78
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
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      oiditm = %xlate(lower:UPPER:oiditm)
PFCaAC                   endsl
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      itdesc = *blanks
530 AC                   eval      itpdsc = *blanks
CSP AC                   eval      itdesg = *blanks
     C                   movel     '*****'       itdesc
     C                   else
     *
CSP A*       If this item has a designation code of JIT, populate
CSP A*       oidspc with 'XD' so that it will be updated and
CSP A*       treated as a cross dock item.
CSPbA*       Add or item has a designation code of PC.
CSP AC                   if        client = CoastalSunbelt
CSPbAC**                           and itdesg = 'JIT  '
CSPbAC                   if        itdesg = 'JIT  '
CSPbAC                             or itdesg = 'PC   '
CSP AC                   eval      oidspc = 'XD'
CSPbAC                   endif
CSP AC                   endif
     *
PFCaA*       For Presto, check if fee item and move qty to Orig Order
PFCaAC                   if        client = PrestoFoods
PFCaAC     ifkey         chain     itemfld
PFCaAC                   if        %found(itemfld)
PFCaAC                             and ifcat = 'FEE'
PFCaAC                   eval      OIDOR2 = OIDQ1
PFCaAC                   eval      OIDQ1 = 0
PFCaAC                   endif
PFCaAC                   endif
     *
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
640 AC                   if        skpwrtdtlm = '0'
650 DC*                  write     omrec
650 MC                   write (e) omrec
     C                   if        %error
650 AC                   eval      *in49 = '1'
     C                   endif
640 AC                   endif
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
530 A*
530 A*    Print exception report page headings.
530 AC                   if        itpdsc > ' '
530 A*
530 AC                   if        *in92
530 AC                   write     head11                               92
530 AC                   write     head21
530 AC                   write     head31
530 AC                   write     head41
530 AC                   endif
530 AC                   write     detail22                             92
530 AC                   add       1             grlin1
530 A*
530 AC                   endif                                                  Endif - itpdsc > ' '
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
     *
     C                   if        client = packers
     *
     *    Check if any orders need to be imported as purchase orders.
     C                   eval      $pimppo = import_po
     *
     C                   endif
     *
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
     * Open IMPFORDHM file.
     C                   if        opnimpordhm <> *on
     C                   open      impfordhm                            67
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
     C                   open      impforddm                            68
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
     *
     * CROSSDK  Cross Dock - Full key
     C     cdkey         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     * IMPFORDH4 Download order header file - Partial key
     C     oihkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptype
     *
     * IMPFORDHM  Download order header misc - full key
     C     oihmkey       klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
     *
     * IMPFORDDM  Download order detail misc - full key
     C     oimkey        klist
     C                   kfld                    oidwhs
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
640 A*
640 A* ORDH Order header file - Full key
640 A*
640 AC     opnohkey      klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    opnord
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
640cA*
640cA* RTEHED1 - Route header file - Full key
640cAC     rh14key       klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    opnrtc
640cAC                   kfld                    opnrte
640 A*
640 A* RTEHED2 - Route header file - Partial key
640 A*
640 AC     rh2akey       klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    kyrhstat
640 AC                   kfld                    $ptype
640 AC                   kfld                    oihrte
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
720aA /free
720aA     // Get Host ERP
720aA     optint.type = 'Interface   ';
720aA     optint.cat  = 'General Options     ';
720aA     optint.name = 'Host ERP System     ';
720aA     GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
720aA               optint.valn: optint.vala: optint.return);
720aA     if optint.return = '*OK';
720aA       host = optint.vala;
720aA     else;
720aA       host = '*NOT DEFINED';
720aA     endif;
720aA /end-free

     C                   endsr
     *----------------------------------------------------------------
530dA*  clr$slot  Clear $slot data structure fields
530dA*----------------------------------------------------------------
530dA
530dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

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
640 AC                   eval      skpwrtdtlm = *off
     *
     C     oimkey        chain     impforddm
     C                   if        not %found(impforddm)
     C*                  clear                   oimrec
640 AC                   eval      oimwhs = 0
640 AC                   eval      oimord = 0
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
640 AC                   eval      skpwrtdtlm = *on
SOF A*
SOF AC                   select
SOF AC                   when         client = Sofofoods
VIP AC                             or client = VIP
SOF AC                   eval      rtxdm1_omwhdp = ' '
SOF AC                   eval      rtxdm1_ompckm = 0
SOF AC                   eval      rtxdm1_omwtiw = 0
SOF AC                   eval      rtxdm1_omcbec = 0
SOF AC                   endsl
SOF A*
640 AC                   goto      endlodm
SOF A*
SOF AC                   else
SOF A*
SOF AC                   select
SOF A*    Move Misc 1 field into Client Specific Misc fld.
SOF AC                   when         client = Sofofoods
VIP AC                             or client = VIP
SOF AC                   eval      rtxdm1_base = oimms1
SOF AC                   endsl
SOF A*
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
PFCbAC                   if        client = prestofoods
PFCbAC                   eval      omcbox = 'N'
PFCbAC                   eval      omcexp = 'N'
PFCbAC                   else
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
PFCbAC                   endif
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
640 AC                   eval      skpwrtdtlm = '1'
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
PFCbAC                   if        client = prestofoods
PFCbAC                   eval      omcbox = 'N'
PFCbAC                   eval      omcexp = 'N'
PFCbAC                   else
     C                   eval      omcbox = oimbox
     C                   eval      omcexp = oimexp
PFCbAC                   endif
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
640 AC                   eval      skpwrthdr = '0'
640 A*
640 A*    Open route found, Open order found.
640 A*    Update existing order.
640 AC                   if        mrgrte = *on  and
640 AC                             mrgord = *on  and
640 AC                             wrgsts = *off
640 AC     opnohkey      chain     ordh
640 AC                   if        %found(ordh)
640 AC                   eval      ohcord = oihord
640 AC                   eval      ohcpo  = oihcpo
640 AC                   eval      ohcust = oihcus
640 AC                   eval      ohcnam = oihcnm
640 AC                   eval      ohcad1 = oihca1
640 AC                   eval      ohcad2 = oihca2
640 AC                   eval      ohccty = oihcct
640 AC                   eval      ohcst  = oihcst
640 AC                   eval      ohczip = oihczp
640 AC                   eval      ohtruk = $ptruk
640 AC                   eval      ohmisc = oihmsc
640 A*
640 A*    Open route found, Open order found.
640 A*    Update existing order.
640 AC                   update    ohrec
640 AC                   eval      skpwrthdr = '1'
640 A*    Load print field for report.
640 AC                   eval      prtrte = ohrte
640 A*
640 AC                   goto      endlodh
640 A*
640 AC                   endif
640 A*
640 AC                   endif
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
640 A*
640 AC     endlodh       tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLHM  Fill order header misc file fields.
     *
     C     fillHM        begsr
640 AC                   eval      skpwrthdrm = '0'
     *
     C     oihmkey       chain     impfordhm
     C                   if        not %found(impfordhm)
     C                   eval      ohmms1 = ' '
     C                   eval      ohmms2 = ' '
     C                   eval      ohmms3 = ' '
     C                   eval      ohmms4 = ' '
     C                   eval      ohmms5 = ' '
     C                   endif
     *
     C                   if        client = packers
     *
     *      This order needs to be imported as a purchase order.
     C                   if        %subst(ohmms1:23:4) = 'ZPLF'
     C                             and (oihwhs = 200 or oihwhs = 300 or
     C                                  oihwhs = 310)
     C                   eval      import_po = '*YES'
     C                   endif
     *
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
640 AC                   eval      skpwrthdrm = '1'
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
640cA*
640cA*      Set route Inuse flag to Importing.
650bA*      Revised to call CHKINUS2 after writing RTEHED record.
650bDC**                 eval      rhiuse = 5
     *
     C                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  FILLXR   Fill Stop Xref File RTESTP
520aA*
520aAC     fillxr        begsr
520aA*
520aA*  Initialize record
520aA*
520aAc                   clear                   rtsRec
520aA*
520aAc                   eval      rtswhs = ohWhse
520aAc                   eval      rtsrid = ohRte
520aAc                   eval      rtsord = ohord
520aAc                   eval      rtsstp = 0
520aAc                   eval      rtsst5 = oihest
720 Dc*                  eval      rtssd = %char(oihest)
720 Mc                   eval      rtssd = %editc(oihest : 'X')
520aA*
520aAc                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  RESEQSTP   Call pgm to Re-Sequence ORDH file
520aA*
520aAC     reseqstp      begsr
520aA*
520aA*  Resequence stops in ORDH to make them unique.
520aA*
520aAc                   call      'OI300'
520aAc                   parm                    rhwhse
520aAc                   parm                    lstrid
520aA*
520aAc                   endsr
520aA*
CSPaA*----------------------------------------------------------------
CSPaA*
CSPaA*  STRIPSPCL   Strip special characters from customer name.
CSPaA*
CSPaAC     stripspcl     begsr
CSPaA*
CSPaA*      Loop through list of special char's and remove them
CSPaA*      from customer name, OIHCNM. Special char's are causing
CSPaA*      terminal errors in GUI Drag/Drop module.
CSPaA*
CSPaAc                   do        NbrSpclChar   s
CSPaAC                   Eval      Start = %Scan(%subst(spclchar:s:1): oihcnm:1)
CSPaA*
CSPaAc                   if        start = 0
CSPaAc                   iter
CSPaAc                   endif
CSPaA*
CSPaAC                   eval      oihcnm = %replace(' ': oihcnm: start)
CSPaA*      Loop to find all occurenances of current special char and
CSPaA*      replace it.
CSPaAc                   dow           start > 0
CSPaAc                             and start < 40
CSPaAC                   eval      start = start + 1
CSPaAC                   eval      start =
CSPaAC                               %scan(%subst(spclchar:s:1): oihcnm: start)
CSPaAc                   if        start > 0
CSPaAC                   eval      oihcnm = %replace(' ': oihcnm: start)
CSPaAC                   endif
CSPaA*
CSPaAC                   enddo
CSPaA*
CSPaAC                   enddo
CSPaA*
CSPaAc                   endsr
CSPaA*
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
     C                   parm      'OI2851PR'    $lrpt            10
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
     C                   close     oi2851pr
     C                   close     oi285pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI2851PR) OUTQ(*DEV) DEV($dev)
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
     C                   parm      'OI285PR '    $lrpt
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
     *          OVRPRTF FILE(OI285PR) OUTQ(*DEV) DEV($dev)
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
     C                   open      oi2851pr
     C                   open      oi285pr
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
HAL AC                   if        client = Halsey
BIR AC                             or client = BiRite
JOR AC                             or client = Jordanos
HAL A*      No truck template assigned if default not found.
HAL AC                   eval      $xcmd = '*DFTNOAU'
HAL AC                   else
HAL AC                   eval      $xcmd = '*DFLT   '
HAL AC                   endif
HAL A*
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
HAL DC*                  parm      '*DFLT  '     $xcmd             8
HAL MC                   parm                    $xcmd             8
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
     C                   select
     C                   when      client = cheney
     C                   if        ititem >= '405000'  and
     C                             ititem <= '492999'
     C                   eval      kywhdp = 'PRD  '
     C                   else
     C                   eval      kywhdp = itwhdp
     C                   endif
SOF A*
SOF AC                   when         client = Sofofoods
VIP AC                             or client = VIP
SOF AC                   if        ititem = '9999999999'
SOF AC                             and rtxdm1_omwhdp > ' '
SOF AC                   eval      kywhdp = rtxdm1_omwhdp
SOF AC                   else
SOF AC                   eval      kywhdp = itwhdp
SOF AC                   endif
SOF A*
     C                   other
     C                   eval      kywhdp = itwhdp
     C                   endsl
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
530bAC                   eval      tmpwgt = tmpwgt * difqy1
     C                   else
     C     itcube        div(h)    itumq2        tmpcub
530bAC     itswgt        div(h)    itumq2        tmpwgt
     C                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
     C                   endif
SOF A*
     C                   else
SOF A*      All other item types.
SOF A*
SOF AC                   if          (client = SofoFoods
VIP AC                             or client = VIP)
SOF AC                             and  (ititem = '9999999999'
SOF AC                               and rtxdm1_omcbec > 0)
SOF AC                   eval      tmpcub = rtxdm1_omcbec * difqy1
SOF AC                   else
SOF A*
     C                   eval      tmpcub = itcube * difqy1
530bAC                   eval      tmpwgt = itswgt * difqy1
SOF AC                   endif
SOF A*
     C                   endif
     *
     C                   add       tmpcub        rsordc
SOF A*
SOF AC                   if          (client = SofoFoods
VIP AC                             or client = VIP)
SOF AC                             and (ititem = '9999999999'
SOF AC                              and rtxdm1_omwtiw > 0)
SOF AC                   eval      tmpwgt = rtxdm1_omwtiw * difqy1
VIP AC                   else
VIP A*
530bDC*                  eval      tmpwgt = itswgt * difqy1
SOF AC                   endif
SOF A*
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
640cA*          The Inuse flag will now be set to 5=Importing while
640cA*          any orders are being updated or added to the route.
640cA*          Just before a new route is started, the Inuse flag will
640cA*          will be cleared.
     *
650bAC                   eval      mrgrte = *off
650bAC                   eval      opnrte = ' '
650bAC                   eval      opnrtc = ' '

640 DC*    rh1key        setgt     rtehed1
640 MC     rh2akey       setgt     rtehed2
640 DC*    rh1key        readpe    rtehed1                                73
640 MC     rh2akey       readpe    rtehed2                                72
     C                   select
640 DC*                  when      not *in73  and
640 MC                   when      not *in72  and
     C                             rhtype = ' '  and
     C                             rhstat = '1'
650bDC**                           and rhiuse = 0
650bA
650bAC                   eval      $icmd = '*GETIUSE'
650bAC                   eval      $irtid = rhrtid
650bAC                   exsr      zziuse
650bA
650bAC                   if        $irtn =  '*OK'
     C                   eval      mrgrte = *on
     C                   eval      opnrte = rhrtid
     C                   eval      opnrtc = rhrte
650bDC**                 eval      rhiuse = 5
650bDC**                 update    rhrec2
650bAC                   eval      $icmd = '*INUSE5'
650bAC                   eval      $irtid = rhrtid
650bAC                   exsr      zziuse
650bAC                   endif
     *
650bDC**                 other
650bDC**                 eval      mrgrte = *off
650bDC**                 eval      opnrte = ' '
650bDC**                 eval      opnrtc = ' '
640 DC*                  unlock    rtehed1
650bDC**                 unlock    rtehed2
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
640cA*
640cA*----------------------------------------------------------------
640cA*
640cA*  ZZCLRIUSENEW  Clear Inuse flag for new route imported.
640cA*
640cAC     zzclriusenew  begsr
640cA*
640cA*      Clear Inuse flag for new route.
650bDC**   rh2key        chain     rtehed1
650bDC**                 if        %found(rtehed1)
650bDC**                 eval      rhiuse = 0
650bDC**                 update    rhrec1
650bDC**                 endif

650bAC                   eval      $icmd = '*CLEAR'
650cMC                   eval      $irtid = newrte
650bAC                   exsr      zziuse
640cA*
640cAC                   endsr
640cA*
640cA*----------------------------------------------------------------
640cA*
640cA*  ZZCLRIUSEOPN  Clear Inuse flag for Open route after updates.
640cA*
640cAC     zzclriuseopn  begsr
640cA*
640cA*      Clear Inuse flag for existing Open route.
650bDC**   rh14key       chain     rtehed1
650bDC**                 if        %found(rtehed1)
650bDC**                 eval      rhiuse = 0
650bDC**                 update    rhrec1
650bDC**                 endif

650bAC                   eval      $icmd = '*CLEAR'
650cMC                   eval      $irtid = opnrte
650bAC                   exsr      zziuse
640cA*
640cAC                   endsr
640cA*
     *----------------------------------------------------------------
     *
     *  ZZCKOR  Check if order header still at Open status.
     *
     C     zzckor        begsr
     *
     C     oh5key        setll     ordh4
     C                   dow       forevr = forevr
     C     oh5key        reade     ordh4                                  77
     C                   select
     C                   when      *in77
     *
     C                   leave
     *
     *    In order to merge an order being imported, the following have
     *    to match: Must be the same type, existing order must be open,
     *    same customer and for GFG ONLY: Memo codes must match.
     C                   when      not *in77  and
750 DC*                            oihtyp = ' '  and
750 MC                             (oihtyp = ' ' or oihtyp='M')  and
     C                             ohtype = ' '  and
     C                             ohstat = 'O'  and
     *    Next line is for GFG ONLY: Memo codes must match.
     C                             oihmec = ohmemc
     C                   eval      mrgord = *on
     C                   eval      opnord = ohord
     C                   eval      opnorc = ohcord
     C                   leave
     *
     C                   other
     C                   eval      wrgsts = *on
     C                   leave
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
     *
     *----------------------------------------------------------------
530dA*
530dA*  ZZCRXD   Use DRISLOT with %CRTXDOCK to create new cross dock
530dA*           slot if one does not exist.  Then use %ALLOCATE to
530dA*           put the qty into the slot.
530dA*
530dAC     zzcrxd        begsr
530dA*
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = oidwhs
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = oiditm
     C                   eval      $slaislu = *on
CSP AC                   if        client = CoastalSunbelt
CSPbAC                   if        itdesg = 'JIT  '
CSP AC                   eval      $slaisl = 'JIT'
CSPbAC                   else
CSPbAC                   eval      $slaisl = 'PC '
CSPbAC                   endif
CSP AC                   else
     C                   eval      $slaisl  = 'XDK'
CSP AC                   endif
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTXDOCK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endcrxd
     C                   endif
     *
     *  Use DRISLOT/%ALLOCATE to put the qty into the slot.
     *
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%ALLOCATE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $slitem
     C                   eval      $sldispu = *on
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = oidq1
     C                   eval      $saqty2 = oidq2
     C                   eval      $saqty3 = oidq3
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endcrxd
     C                   endif
     *
     C     endcrxd       endsr
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
530dA*
530dA* Create cross dock slot if it doesn't already exist.
530dA* Put allocated qty into slot.
530dAC                   exsr      zzcrxd
530dA*
530dD* Loop through P.O. detail records looking for item.
530dDC**   keypd1        setll     podtl1
530dDC**                 dow       forevr = forevr
530dDC**   keypd1        reade     podtl1                                 79
530dD* Error if none found.
530dDC**                 if        *in79
530dDC**                 eval      pdseq = 0
530dDC**                 eval      pdpo = oidpo
530dDC**                 endif
530dD* If cross dock slot record exists, update
530dDC**                 movel     'XDK'         kydisp
530dDC**   keysl4        setll     slot4
530dDC**                 dow       forevr = forevr
530dDC**                 read      slot4                                  79
530dDC**                 if        not *in79  and
530dDC**                           slstat = 'XD'  and
530dDC**                           slwhse = $pwhse  and
530dDC**                           slwhdp = itwhdp  and
530dDC**                           slitem = oiditm  and
530dDC**                           slaisl = 'XDK'
530dD* Pre-allocate product in case receiving is done before picking.
530dDC**                 add       oidq1         slalc1
530dDC**                 if        itflg1 = 'Y'
530dDC**                 add       oidq2         slalc2
530dDC**                 endif
530dDC**                 if        itflg2 = 'Y'
530dDC**                 add       oidq3         slalc3
530dDC**                 endif
530dDC**                 update    slrec4
530dDC**                 goto      addxdk
530dDC**                 else
530dDC**                 unlock    slot4
530dDC**                 leave
530dDC**                 endif
530dDC**                 enddo
530dD* Create cross dock slot record.
530dDC**                 eval      tmploc = 1
530dDC**                 eval      kyaisl = 'XDK'
530dDC**   keysl1        setll     slot1
530dDC**                 dow       forevr = forevr
530dDC**   keysl1        reade(n)  slot1                                  79
530dDC**                 if        *in79  or
530dDC**                           slloc > tmploc
530dDC**                 leave
530dDC**                 endif
530dDC**   slloc         add       1             tmploc
530dDC**                 enddo
     *
530dDC**                 clear                   slrec
530dDC**                 eval      slwhse = oidwhs
530dDC**                 eval      slwhdp = itwhdp
530dDC**                 eval      slaisl = 'XDK'
530dDC**                 eval      slloc = tmploc
530dDC**                 eval      slrlvl = 1
530dDC**                 eval      slhand = *blanks
530dDC**                 eval      slstyp = 'X'
530dDC**                 eval      slpseq = tmploc
530dDC**                 eval      slitem = oiditm
     *
530dDC**                 eval      slstat = oidspc
530dDC**                 eval      slsdte = today
530dDC**                 time                    slstim
530dDC**                 eval      slpick = 'N'
530dDC**                 eval      slrsrv = 'N'
530dD* Format display slot.
530dDC**                 call      'FRMTSL'
530dDC**                 parm                    slwhse
530dDC**                 parm                    slwhdp
530dDC**                 parm                    slaisl
530dDC**                 parm                    slloc
530dDC**                 parm                    slrlvl
530dDC**                 parm                    slhand
530dDC**                 parm                    slstyp
530dDC**                 parm                    slpseq
530dDC**                 parm                    sldisp
530dD* Pre-allocate product in case receiving is done before picking.
530dDC**                 eval      slalc1 = oidq1
530dDC**                 if        itflg1 = 'Y'
530dDC**                 z-add     oidq2         slalc2
530dDC**                 endif
530dDC**                 if        itflg2 = 'Y'
530dDC**                 z-add     oidq3         slalc3
530dDC**                 endif
530dD* Add record
530dDC**   slloc         div       2             dummy
530dDC**                 mvr                     slside
530dDC**                 if        slside < 0
530dDC**                 eval      slside = -(slside)
530dDC**                 endif
530dDC**                 write     slrec                                77
530dD* Error if slot not created.
530dDC**                 if        *in77
530dDC**                 eval      detmsg = desc(5)
530dDC**                 add       1             badpo
530dDC**                 leave
530dDC**                 endif
530dD* Create cross dock record.
530dDC**   addxdk        tag
530dDC**                 eval      cdwhse = slwhse
530dDC**                 eval      cdwhdp = slwhdp
530dDC**                 eval      cdslot = sldisp
530dDC**                 eval      cdord = ohord
530dDC**                 eval      cdorsq = oidseq
530dDC**                 eval      cdort# = 0
530dDC**                 eval      cdorl# = 0
530dDC**                 eval      cdpo = pdpo
530dDC**                 eval      cdposq = pdseq
530dDC**                 eval      cdpot# = 0
530dDC**                 eval      cdpol# = 0
530dDC**                 write     cdrec                                79
530dDC**                 if        *in79
530dDC**                 eval      detmsg = desc(6)
530dDC**                 add       1             badpo
530dDC**                 else
     C                   eval      good2 = 'Y'
530dDC**                 endif
530dDC**                 leave
530dDC**                 enddo
     *
     C     endxd         endsr
     *----------------------------------------------------------------
CSP A*
CSP A*  ZZXDELJIT   Delete status 'Z' JIT slots
CSP A*
CSP AC     zzzDelJIT     begsr
CSP A
     C                   eval      kyaisl = 'JIT'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
     C                   endif
     C                   enddo

     C                   endsr
CSPbA*----------------------------------------------------------------
CSPbA*
CSPbA*  ZZXDELPC    Delete status 'Z' PC slots
CSPbA*
CSPbAC     zzzDelPC      begsr
CSPbA
CSPbAC                   eval      kyaisl = 'PC '
CSPbAC     keysl11       setll     slot11
CSPbAC                   dow       forevr = forevr
CSPbAC     keysl11       reade     slot11
CSPbAC                   if        %eof
CSPbAC                   leave
CSPbAC                   endif
CSPbAC                   if        slstat = 'Z'
CSPbAC                   delete    slrec11
CSPbAC                   endif
CSPbAC                   enddo
CSPbA
CSPbAC                   endsr
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
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZIUSE   Set Inuse flag for route before proceeding.
650bA*
650bAC     zziuse        begsr

     C                   call      'CHKIUSE2'
     C                   parm                    $icmd             8
     C                   parm      $pwhse        $iwhse            3 0
     C                   parm                    $irtid            5
     C                   parm      #prog         $ipgm            20
     C                   parm      ''            $iuser           10
     C                   parm      ''            $isessid         40
     C                   parm                    $irtn             8
     C                   parm                    $itext10         10
     C                   parm                    $itext30         30
     C                   parm                    $iucmd            8
     C                   parm                    $iupgm           20
     C                   parm                    $iuuser          10
     C                   parm                    $iuSessId        40
     C                   parm                    $iuJobName       10
     C                   parm                    $iuJobNbr         6
     C                   parm                    $iuJobUser       10
     C                   parm                    $iuStamp         26

     C                   endsr
     *----------------------------------------------------------------
530dA*  zzzdricop  Call DRICOP
530dA*----------------------------------------------------------------
530dA
530dAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
530dA*     ZZZS2D - Copy slot fields into data structure fields.
530dA*
530dAC     zzzs2d        begsr
530dA*
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = slwhse
     *
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = slwhdp
     *
     C                   eval      $sldispu = *on
     C                   eval      $sldisp = sldisp
     *
     C                   eval      $slaislu = *on
     C                   eval      $slaisl = slaisl
     *
     C                   eval      $sllocu = *on
     C                   eval      $slloc = slloc
     *
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl = slrlvl
     *
     C                   eval      $slhandu = *on
     C                   eval      $slhand = slhand
     *
     C                   eval      $slsideu = *off
     C                   eval      $slside = slside
     *
     C                   eval      $slstypu = *off
     C                   eval      $slstyp = slstyp
     *
     C                   eval      $slstatu = *off
     C                   eval      $slstat = slstat
     *
     C                   eval      $slsdteu = *off
     C                   eval      $slsdte = slsdte
     *
     C                   eval      $slstimu = *off
     C                   eval      $slstim = slstim
     *
     C                   eval      $slsdefu = *off
     C                   eval      $slsdef = slsdef
     *
     C                   eval      $sldesgu = *off
     C                   eval      $sldesg = sldesg
     *
     C                   eval      $slactvu = *off
     C                   eval      $slactv = slactv
     *
     C                   eval      $slbldu = *off
     C                   eval      $slbld = slbld
     *
     C                   eval      $slpicku = *off
     C                   eval      $slpick = slpick
     *
     C                   eval      $slpsequ = *off
     C                   eval      $slpseq = slpseq
     *
     C                   eval      $slprtyu = *off
     C                   eval      $slprty = slprty
     *
     C                   eval      $slentdu = *off
     C                   eval      $slentd = slentd
     *
     C                   eval      $slexpdu = *off
     C                   eval      $slexpd = slexpd
     *
     C                   eval      $slslfdu = *off
     C                   eval      $slslfd = slslfd
     *
     C                   eval      $slrsrvu = *off
     C                   eval      $slrsrv = slrsrv
     *
     C                   eval      $slitemu = *off
     C                   eval      $slitem = slitem
     *
     C                   eval      $slstk1 = slstk1
     C                   eval      $slstk2 = slstk2
     C                   eval      $slstk3 = slstk3
     C                   eval      $slalc1 = slalc1
     C                   eval      $slalc2 = slalc2
     C                   eval      $slalc3 = slalc3
     C                   eval      $sltfr1 = sltfr1
     C                   eval      $sltfr2 = sltfr2
     C                   eval      $sltfr3 = sltfr3
     C                   eval      $slpck1 = slpck1
     C                   eval      $slpck2 = slpck2
     C                   eval      $slpck3 = slpck3
     C                   eval      $slrcv1 = slrcv1
     C                   eval      $slrcv2 = slrcv2
     C                   eval      $slrcv3 = slrcv3
     C                   eval      $slphy1 = 0
     C                   eval      $slphy2 = 0
     C                   eval      $slphy3 = 0
     C                   eval      $slavl1 = 0
     C                   eval      $slavl2 = 0
     C                   eval      $slavl3 = 0
     C                   eval      $sladj1 = 0
     C                   eval      $sladj2 = 0
     C                   eval      $sladj3 = 0
     *
     C                   eval      $saitemu = *off
     C                   eval      $saitem = *blanks
     *
     C                   eval      $saqtyu = *off
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     *
     C                   eval      $saorgu = *off
     C                   eval      $saorg1 = 0
     C                   eval      $saorg2 = 0
     C                   eval      $saorg3 = 0
     *
     C                   eval      $sacwtau = *off
     C                   eval      $sacwta = 0
     *
     C                   eval      $sacodeu = *off
     C                   eval      $sacode = *blanks
     *
     C                   eval      $samemou = *off
     C                   eval      $samemo = *blanks
     *
     C                   eval      $sabyu = *off
     C                   eval      $saby = *blanks
     *
     C                   eval      $sadateu = *off
     C                   eval      $sadate = 0
     *
     C                   eval      $satimeu = *off
     C                   eval      $satime = 0
     *
     C                   eval      $saFrmVrfyu = *off
     C                   eval      $saFrmVrfy = *blanks
     *
     C                   eval      $satrn#u = *off
     C                   eval      $satrn# = 0
     *
     C                   eval      $saFrmLcnsu = *off
     C                   eval      $saFrmLcns = *blanks
     *
     C                   eval      $satasku = *off
     C                   eval      $satask = *blanks
     *
     C                   eval      $sacdspu = *off
     C                   eval      $sacdsp = *blanks
     *
     C                   endsr
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
OVRPRTF FILE(OI2851PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI285PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
