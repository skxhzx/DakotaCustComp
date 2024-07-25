     H/copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI275     Import FTP orders w/Pick Slot - Post
     *  07 September 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    09/07/05  MLB 5.00
     *      - Created.
500aA*    11/18/05  MLB 5.00a
     *      - Enh: Added support for new order type, *SAROUTE. Import
     *        customer orders w/Host generated labels.
     *      - Added files IMPFORDL, ORDL.
500bA*    01/04/06  MLB 5.00b
     *      - Fix: Renamed file ORDL to ORDLBL. Conflict with existing
     *        file. Recompiled program.
500cA*    02/11/06  MLB 5.00c
     *      - Enh: Revised program to add new files, IMPFORDM. This file
     *        has optional Voice selection info and item description
     *        override. This file has 5 user fields that can be populated
     *        with any data required by client.
500dA*    03/21/06  MLB 5.00d
     *      - Enh: Revised routine FILLOM to clear fields from IMPFORDM
     *        when the record wasn't found.
     *
500eA*    04/26/06  DAS 5.00e
     *      - Enh: Added 'Items with zero quantity' to exceptions.
     *
510 A*    06/06/07  MLB  5.10
     *      - Fix: Revised program to prevent duplicate key error when
     *        writing to ORDM file.
510aA*    12/16/07  MLB  5.10a
     *      - Fix: Revised program to incease size of field SUBLIN to
     *        7,0 from 3,0.
520aA*    01/26/08  DAS  5.20a  P#00006
     *     - Enh: Added files IMPFORDHM, ORDHM to program. This files
     *       are miscelleanous files. If they are used, there must be
     *       a record in the IMPFORDHM file for every record in the
     *       IMPFORDH file.
520 A*    09/29/08  JCJ  5.20
     *      - Enh: Added $XCMD to parm list of OI260.
520bA*    10/23/08  MLB  5.20b
     *      - Enh: Added client custom code support to program.
     *
530 A*    11/20/09  MLB  5.30
     *      - Enh: Revised OI2551PR to add format DETAIL 22 which
     *        will print item pack/size on exception report.
530aA*    12/07/09  MLB  5.30a
     *      - Enh: Revised tmpcub, tmpwgt to reference rsordc, rsordw
     *        to prevent field overflow errors on cube, wgt.
530bA*    04/07/10  MLB  5.30b
     *      - Fix: Add code to get base if item type = A.
     *        Change to divide ITCUBE by brk qty to calculate cube for
     *        type 'S' item.
530cA*    04/07/10  MLB  5.30c
     *      - Fix: Change to divide ITSWGT by brk qty to calculate wgt
     *        for type 'S' item.
530dA*    11/04/10  MLB  5.30d
     *      - Enh: Revised program to override to outq instead of device.
     *        From: OVRPRTF FILE(OI2751PR) OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
640aA*    10/26/09  MLB  6.40a  (originally 5.30 missed in update)
     *      - Fix: Revised program to prevent string error when OHWHS
     *        is zero.
     *
740 A*    01/21/20  KDE  7.40
     *      - Enh: Added Wave logic.  First implemented at US Foods
     *
740a *    03/24/20  RTR  Hold for change coming from Williams.
     *
750 A*    03/02/22  MLB  7.50
     *      - Enh: Revised program to add RTESTP file to program to be
     *        populated as ORDH records are written out. RTESTP needs
     *        to be populated for DD2 processing. Found at City Line.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ettline Foods
     *
ETT A*    10/23/08  MLB ETT
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
     *
GMMa *    10/03/16  RTR  GMMa
     *      - Changed for FEEDER route 68 to check for existing open 68
     *        and if found, skip additional attempts to import it.
     *        This is being done to handle problem with NDS sending
     *        multiple times.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foodservice
     *
IFD A*    11/12/08  MLB  IFD
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *      - Added client to ETT mod.
     *
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
500cA*  68        - Open of IMPFORDM or ORDDM failed.
     *  71        - NRF on chain to ORDDS
     *  78        - EOF for IMPFORDD3
     *  79        - EOF for IMPFORDH3
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfordh3 uf   e           k disk
520aAFimpfordhm uf   e           k disk    usropn
     Fimpfordd3 uf   e           k disk
500aAFimpfordl  uf   e           k disk    usropn
500cAFimpfordm  uf   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fslot1     uf a e           k disk
     Fslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
     Frtesum    uf a e           k disk
     Fordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
     Fordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
     Foptions   if   e           k disk
     Fpodtl1    if   e           k disk
     Frtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
     Frtehed    o  a e           k disk
     Fordh      uf a e           k disk
520aAFordhm     uf a e           k disk    usropn
     Fcrossdk   o  a e           k disk
     Fordd      o  a e           k disk
     Fordds     uf a e           k disk
500cAForddm     uf a e           k disk    usropn
750 AFrtestp    uf a e           k disk
500bMFordlbl    uf a e           k disk    usropn
     Foi275pr   o    e             printer oflind(*in91)
     Foi2751pr  o    e             printer oflind(*in92)
     F                                     usropn
740 Aftbfmtoifs if   e           k disk
740 Aftbwaveh   uf a e           k disk
740 Aftbwaved   uf a e           k disk
740 AFbfcdebug  o    e           k disk
520aA*----------------------------------------------------------------
520aA*  Customer id
520aA*
USF A /copy qcopysrc,id#usfcrp
USF A /copy qcopysrc,id#usfasys
USF A /copy qcopysrc,id#usfpsys
ETT A /copy qcopysrc,id#ettline
IFD A /copy qcopysrc,id#ifd
GMMaA /copy qcopysrc,id#gmm
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *                   DESC    1   3 20
500eDD**esc            s             20    dim(6) ctdata perrcd(1)
500eMD desc            s             20    dim(7) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
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
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
740 Ad autoWave        s               n
740 AD bfcjobq         s             10
740 Ad branchid        s              2
740 AD cmdjobq         s           3000    varying
     D count           s              3  0
700aAD currdate        s              8s 0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
740 Ad divcd           s              3
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
     D excprt          s              1
     D excpr1          s              1
700aAD feeder          s              6s 0
     D forevr          s              1
     D good1           s              1
     D good2           s              1
     D impdte          s              8  0
     D imptim          s              6  0
740 Ad impmbr          s             10
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(odstat)
     D len             s              1  0
     D linppg          s              3  0
     D lstrid          s                   like(oihrte)
     D lstrte          s                   like(oihrte)
     D lstwhs          s              3  0
520aAD mischdrupd      s              4    inz('*NO ')
500cAD miscupdate      s              4    inz('*NO ')
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
740 Ad pdesc           s             30
740 Ad phost           s              1
740 Ad predp           s              1
740 Ad piiuf           s              1
740 Ad peiuf           s              1
740 Ad probn           s              1
740 Ad plbls           s              1
520aAD opnimpordhm     s              1    inz('0')
520aAD opnordhm        s              1    inz('0')
500aAD opnimpordl      s              1    inz('0')
500aAD opnordl         s              1    inz('0')
500cAD opnimpordm      s              1    inz('0')
500cAD opnordm         s              1    inz('0')
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
740 AD sbmCmd          s           3000    varying
740 AD sbmJob          s             10A
740 AD sbmUser         s             10A
740 AD sbmJobNbr       s              6A
740 AD sq              c                   Const('''')
     D skpwrt          s              1
510aDD*sublin          s              3  0
510aMD sublin          s              7  0
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
740 Ad wave#           s              7  0
740 Ad waveid          s             15
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
740 A*----------------------------------------------------------------
740 A*  External Program Calls
740 A*----------------------------------------------------------------
     *
740 AD getbranch       pr                  extpgm('GETBRANCH')
740 AD  $ubid                         2
740 AD  $ubdesc                      30
740 AD  $ubhost                       1
740 AD  $ubredp                       1
740 AD  $ubiiuf                       1
740 AD  $ubeiuf                       1
740 AD  $ubrobn                       1
740 Ad  $ublbls                       1
740 Ad  $ubdiv                        3
     *
740 AD pirwave#        pr                  extpgm('PIRWAVE#')
740 AD  $wave                         7  0

740 A*----------------------------------------------------------------
740 A*  Program info data structure
740 A*----------------------------------------------------------------
740 A
740 AD/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

740 A /copy qcopysrc,p.qcmdexc
740 A /copy qcopysrc,p.wrtrtelg

740 AD QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
740 AD   MsgInfo                  32766A   options(*varsize)
740 AD   MsgInfoLen                  10I 0 const
740 AD   Format                       8A   const
740 AD   StackEntry                  10A   const
740 AD   StackCount                  10I 0 const
740 AD   MsgType                     10A   const
740 AD   MsgKey                       4A   const
740 AD   WaitTime                    10I 0 const
740 AD   MsgAction                   10A   const
740 AD   ErrorCode                32766A   options(*varsize)

740 A*----------------------------------------------------------------
740 A*  Sub-procedure prototypes
740 A*----------------------------------------------------------------

740 AD SubmitJob       PR            10I 0
740 AD   peName                      10A   const varying
740 AD   peJobQ                      10A   const varying
740 AD   peCmd                     3000A   const varying
740 AD   peSbmName                   10A   options(*nopass)
740 AD   peSbmUser                   10A   options(*nopass)
740 AD   peSbmNbr                     6A   options(*nopass)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PTYPE  Order types to process.
     *              ' ' - Normal
500aA*              'A' - Normal w/Host generated labels
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
740 Ac                   parm                    $mbr             10
740 A /free
740 A                    if %parms >= 13;
740 A                       impmbr=$mbr;
740 A                    else;
740 A                       impmbr=*blanks;
740 A                    endif;
740 A /end-free
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
     * Route summary file
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    kyrtid
     C                   kfld                    itwhdp
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
GMMaA**** For Menu Maker, check for previously processed Feeder routes
GMMaA /free
GMMaA    if client = MenuMaker;
GMMaA      feeder = 0;
GMMaA      currdate = %dec(%char(%date():*iso0):8:0);
GMMaA      exec sql select count(*) into :feeder
GMMaA                 from RTEHED
GMMaA                where RHRTE = '68'
GMMaA                  and RHTRUK = 'FEEDER'
GMMaA                  and RHIMPD = :currdate
GMMaA                  and RHSTAT in('1','2','3','4','5','6');
GMMaA    endif;
GMMaA /end-free
     *
     C                   dou       eofh = *on
     C                   exsr      updrte
     *
     C                   read      impfordh3                              79
     C                   if        *in79
     C                   eval      eofh = *on
500aA*
500aA*    If processing Routes w/Host created labels, process Route
500aA*    just imported and create Labels for last route.
500aAC                   if        $ptype = 'A'
500aAC                             and lstrte <> ' '
500aAC                   exsr      Crtlabels
500aAC                   endif
500aA*
     C                   goto      enddoh
     C                   endif
     *
GMMaA**** For Menu Maker, check if Feeder, skip if already exists
GMMaAc                   if        client = MenuMaker
GMMaAc                             and oihrte = '68   '
GMMaAc                             and oihtrk = 'FEEDER'
GMMaAc                             and feeder > 0
GMMaAc                   goto      enddoh
GMMaAc                   endif
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
740 A*
740 A*    Check for Auto Wave Processing.  If first header has Auto
740 A*    in first 4 of address 2 this batch will be handled as Wave
740 A*
740 A /free
740 A        if lstrte='@@@@@';
740 A          if %subst(oihca2:1:4)='AUTO';
740 A             exsr wrtWaveHdr;
740 A             autowave=*on;
740 A          else;
740 A             autowave=*off;
740 A          endif;
740 A        endif;
740 A /end-free
     *
     *    Retrieve General Pick options for warehouse.
     *    This applies to only Regular orders.
     *
     C                   select
     C                   when      $ptype = ' '
740 Ac                             or oihtyp='V'
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
640aAC                   if        pos = 0
640aAC                   eval      pos = 1
640aAC                   endif
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
     *  Print report heading if necessary.
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
     C                   if        oihrte <> lstrte  or
     C                             $ptype = 'S'
500aA*
500aA*    If processing Routes w/Host created labels, process Route
500aA*    just imported and create Labels.
500aAC                   if        $ptype = 'A'
500aAC                             and lstrte <> ' '
500aAC                   exsr      Crtlabels
500aAC                   endif
500aA*
     C                   eval      mrgrte = *off
     C                   eval      newrte = *blanks
     C                   eval      newrtc = *blanks
     *
     *  Merge order(s) into Open routes allowed.
     *  Check if Route still at Open status.
     *
     C                   if        opmrga = 'Y'  and
     C                             $ptype = ' '
     C                   exsr      zzckr1
     C                   exsr      zzckrt
     C                   endif
     *
     C                   exsr      fillrh
     C                   write     rhrec                                49
     C                   eval      lstrte = oihrte
     C                   endif
     *
     *  Add record to order header file. If an error occurs, assume
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
520aA*
520aA*    Only update ORDHM if impfordhm was sent.
520aAC                   if        mischdrupd = '*YES'
520aAC                   exsr      fillhm
520aAC                   endif
520aA*
     C                   write     ohrec                                49
750 A*
750 A*    Fill Route Extended Stop file
750 A /free
750 A   // first check for existing RTESTP record
750 A   chain (ohwhse: ohrte: ohord) rtestp;
750 A   if %found(rtestp);
750 A
750 A     // if exists and extended stop changed, update
750 A     if rtsst5 <> oihstp;
750 A       rtsstp = ohstop;
750 A       rtsst5 = ohstop;
750 A       rtssd  = '000' + %editc(ohstop : 'X');
750 A       update rtsrec;
750 A     else;
750 A       unlock rtestp;
750 A     endif;
750 A
750 A   else;
750 A     // wasn't found, so write record
750 A /end-free
750 AC                   exsr      fillxr
750 AC                   write (e) rtsrec
750 AC                   if        %error
750 AC                   endif
750 AC                   endif
520aA*
520aA*    Only add to ORDDM if impfordm was sent.
520aAC                   if        mischdrupd = '*YES'
520aAC                             and %found(impfordhm)
520aAC                   write     hmrec
520aAC                   if        %error
520aAC                   endif
520aAC                   endif
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
     C     oidkey        setll     impfordd3
     C                   dou       eofd = *on
     *
     C     oidkey        reade     impfordd3                              78
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
530 AC                   eval      itpdsc = *blanks
     C                   movel     '*****'       itdesc
     C                   else
     *       Check if breakdown qty is allowed using piritem file.
     *       Add rec if qty1, brk qty2 or brk qty3 has good qty.
     C                   exsr      zzbkdn
     *
     *       If qty1, brkdown qty2 or brkdown qty3 has good qty,
     *        add record to order detail file. If an error
     *        occurs, assume was caused by a duplicate record.
     *        Update route summary with detail information.
     *
500eAC                   if        good1 <> 'Y'
500eAC                   eval      detmsg = desc(7)
500eAC                   add       1             zroqty
500eAC                   endif
500eAC*
     C                   if        good1 = 'Y'
     C                   exsr      zzxdck
     C                   if        good2 = 'Y'
     C                   exsr      fillod
     C                   exsr      fillos
500cA*
500cA*    Only update ORDDM if impfordm was sent.
500cAC                   if        miscupdate = '*YES'
500cAC                   exsr      fillom
500cAC                   endif
     *
     *    Record was updated in FILLOD.
     C                   if        skpwrt = *off
     C                   write     odrec                                49
     C                   write     osrec                                48
500cA*
500cA*    Only add to ORDDM if impfordm was sent.
500cAC                   if        miscupdate = '*YES'
510 DC*                  write     omrec
510 MC                   write (e) omrec
500cAC                   if        %error
500cAC                   endif
500cAC                   endif
     C                   if        *in49
     C                   eval      detmsg = desc(1)
     C                   add       1             preod
     C                   endif
     C                   endif
     C                   exsr      updsum
     C                   endif
500aA*
500aA*    Fill Customer Order Label fields.
500aAC                   if        $ptype = 'A'
500aAC     oilkey        setll     impfordl
500aAC     oilkey        reade     impfordl
500aAC                   dow       not %eof(impfordl)
500bMC                   exsr      fillal
500bMC                   write     alrec
500aAC                   if        %error
500aAC                   endif
500aAC     oilkey        reade     impfordl
500aAC                   enddo
500aAC                   endif
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
     C                   delete    oidrec
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
530 AC                   endif
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
     C                   delete    oihrec
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
740 A*
740 A*  If Wave was processed we should sumit job to auto advance the routes
740 A*
740 A /free
740 A          if autoWave;
740 A            exsr submitWave;
740 A          endif;
740 A /end-free
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
520bA*
520bA* Get client id.
520bA*
520bAC                   call      'GETCLIENT'
520bAC                   parm                    client           10
520bAC                   parm                    clientloc        10
500aA*
500aA* Open IMPFORDL file when otype = 'A'.
500aAC                   if        $ptype = 'A'
500aAC                             and opnimpordl <> *on
500aAC                   open      impfordL
500aAC                   eval      opnimpordl = *on
500aAC                   endif
500aA*
500bM* Open ORDLBL file when otype = 'A'.
500aAC                   if        $ptype = 'A'
500aAC                             and opnordl <> *on
500bMC                   open      ordlbl
500aAC                   eval      opnordl = *on
500aAC                   endif
520aA*
520aA* Open IMPFORDHM file.
520aAC                   if        opnimpordhm <> *on
520aAC                   open      impfordhm                            67
520aAC                   if        *in67 = *off
520aAC                   eval      opnimpordhm = *on
520aAC                   eval      mischdrupd = '*YES'
520aAC                   else
520aAC                   eval      mischdrupd = '*NO '
520aAC                   endif
520aAC                   endif
520aA*
520aA* Open ORDHM file if import file was sent.
520aAC                   if        opnordhm <> *on
520aAC                             and mischdrupd ='*YES'
520aAC                   open      ordhm                                67
520aAC                   if        *in67 = *off
520aAC                   eval      opnordhm   = *on
520aAC                   eval      mischdrupd = '*YES'
520aAC                   else
520aAC                   eval      mischdrupd = '*NO '
520aAC                   endif
520aAC                   endif
500cA*
500cA* Open IMPFORDM file.
500cAC                   if        opnimpordm <> *on
500cAC                   open      impfordm                             68
500cAC                   if        *in68 = *off
500cAC                   eval      opnimpordm = *on
500cAC                   eval      miscupdate = '*YES'
500cAC                   else
500cAC                   eval      miscupdate = '*NO '
500cAC                   endif
500cAC                   endif
500cA*
500cM* Open ORDDM file if import file was sent.
500cAC                   if            opnordm <> *on
500cAC                             and miscupdate ='*YES'
500cMC                   open      orddm                                68
500cAC                   if        *in68 = *off
500cAC                   eval      opnordm    = *on
500cAC                   eval      miscupdate = '*YES'
500cAC                   else
500cAC                   eval      miscupdate = '*NO '
500cAC                   endif
500cAC                   endif
     *
     * IMPFORDH3 Download order header file - Partial key
     C     oihkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptype
500aA*
500aA* IMPFORDL  Download order Label file - full key
500aaC     oilkey        klist
500aAC                   kfld                    oidwhs
500aAC                   kfld                    oidord
500aAC                   kfld                    oidseq
500aAC                   kfld                    oiditm
520aA*
520aA* IMPFORDHM  Download order header misc - full key
520aaC     oihmkey       klist
520aAC                   kfld                    oihwhs
520aAC                   kfld                    oihord
500cA*
500cA* IMPFORDM  Download order detail misc - full key
500caC     oimkey        klist
500cAC                   kfld                    oidwhs
500cAC                   kfld                    oidord
500cAC                   kfld                    oidseq
500cAC                   kfld                    oiditm
     *
     * ORDH Order header file - Partial key
     *
     C     ohkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    neword
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
520aA*
520aA* ORDHM Order header misc. file - Full key
520aA*
520aAC     *like         define    hmord         kyord
520aAC     hmkey         klist
520aAC                   kfld                    $pwhse
520aAC                   kfld                    kyord
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
     * ORDDS  Order detail pick slot file - Full key
     *
     C                   eval      kystat = 'O'
     C     oskey         klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
500cA*
500cA* ORDDM  Order detail misc. file - Full key
500cA*
500cAC     omkey         klist
500cAC                   kfld                    odwhse
500cAC                   kfld                    odord
500cAC                   kfld                    odseq
500cAC                   kfld                    oditem
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
740 A*----------------------------------------------------------------
740 A*  chkjobq     Check to make sure jobq exists
740 A*----------------------------------------------------------------
740 A
740 A /free
740 A  begsr chkjobq;
740 A
740 A    // check for jobq
740 A    cmdjobq = 'CHKOBJ ' +
740 A    'OBJ('+ bfcjobq +') ' +
740 A    'OBJTYPE(*JOBQ)';
740 A
740 A    monitor;
740 A      qcmdexc(%trim(cmdjobq): %len(%trim(cmdjobq)));
740 A    on-error *all;
740 A      bfcjobq = 'BFCJOBQ';
740 A    endmon;
740 A  endsr;
740 A /end-free
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
740 Ac                   if        autoWave
740 Ac                   eval      oihtyp = 'V'
740 Ac                   endif
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
500aA*
500aA*----------------------------------------------------------------
500aA*
500bM*  FILLAL  Fill order label fields.
500aA*
500bMC     fillal        begsr
500aA*
500aA*  Initialize record
500aA*
500bMC                   clear                   alrec
500aA*
500aA*  Move fields from download file to order label fields
500aA*
500bMC                   eval      alwhse = oilwhs
500bMC                   eval      alrte  = newrte
500bMC                   eval      alord  = neword
500bMC                   eval      alseq  = oilseq
500bMC                   eval      alitem = oilitm
500bMC                   eval      alhtr# = oilhtr
500bMC                   eval      alpsq# = oilpsq
500bMC                   eval      alpal# = oilplt
500bMC                   eval      aldisp = oildsp
500bMC                   eval      alaisl = oilasl
500bMC                   eval      alloc  = oilloc
500bMC                   eval      alrlvl = oillvl
500bMC                   eval      alhand = oilhnd
500bMC                   eval      alqpk1 = oilqy1
500aAC                   if        itflg1 = 'Y'
500bMC                   eval      alqpk2 = oilqy2
500aAC                   else
500bMC                   eval      alqpk2 = 0
500aAC                   endif
500aAC                   if        itflg2 = 'Y'
500bMC                   eval      alqpk3 = oilqy3
500aAC                   else
500bMC                   eval      alqpk3 = 0
500aAC                   endif
500bMC                   eval      alcomp = oilcmp
500bMC                   eval      alrow  = oilrow
500bMC                   eval      alcol  = oilcol
500bMC                   eval      allseq = oillsq
500bMC                   eval      alhtrn = oilhtn
500bMC                   eval      alhfl1 = oilhf1
500bMC                   eval      alhfl2 = oilhf2
500bMC                   eval      alhfl3 = oilhf3
500bMC                   eval      alhfl4 = oilhf4
500bMC                   eval      alhfl5 = oilhf5
500aA*
500aAC                   endsr
500aA*
500cA*----------------------------------------------------------------
500cA*
500cA*  FILLOM  Fill order detail misc file fields.
500cA*
500cAC     filloM        begsr
500cA*
500cAC     oimkey        chain     impfordm
500cAC                   if        not %found(impfordm)
500dDC*                  clear                   oimrec
500dAC                   eval      oimdsc = ' '
500dAC                   eval      oimpds = 'N'
500dAC                   eval      oimrds = 'N'
500dAC                   eval      oimbox = 'N'
500dAC                   eval      oimexp = 'N'
500dAC                   eval      oimms1 = ' '
500dAC                   eval      oimms2 = ' '
500dAC                   eval      oimms3 = ' '
500dAC                   eval      oimms4 = ' '
500dAC                   eval      oimms5 = ' '
500cAC                   endif
500cA*
500cA*    Route & order at Open status. Check if item already on order.
500cA*    If yes, then compute difference between import qty's and order
500cA*    qty's. Then update order with import qty.
500cAC                   select
500cAC                   when      mrgrte = *on  and
500cAC                             mrgord = *on  and
500cAC                             wrgsts = *off
500cA*
500cAC                   eval      rcdlck = *on
500cAC                   exsr      zzgtom
500cAC                   eval      rcdlck = *off
500cA*
500cAC                   select
500cAC                   when      %found(orddm) and
500cAC                             oiditm = oditem
500cA*
500cAC                   eval      omodsc = oimdsc
500cAC                   eval      ompdsc = oimpds
500cAC                   eval      omrdsc = oimrds
500cAC                   eval      omcbox = oimbox
500cAC                   eval      omcexp = oimexp
500cAC                   eval      ommsc1 = oimms1
500cAC                   eval      ommsc2 = oimms2
500cAC                   eval      ommsc3 = oimms3
500cAC                   eval      ommsc4 = oimms4
500cAC                   eval      ommsc5 = oimms5
500cAC                   update    omrec
500cA*
500cAC                   goto      endlodm
500cAC                   endsl
500cA*
500cAC                   endsl
500cA*
500cA*  Initialize record
500cA*
500cAC                   clear                   omrec
500cA*
500cA*  Move fields from download file to order detail misc file fields.
500cA*
500cAC                   eval      omwhse = oidwhs
500cA*
500cA*    Open route found, Open order not found or at wrong status.
500cA*    Create order under current Open route.
500cAC                   select
500cAC                   when      mrgrte = *on  and
500cAC                             mrgord = *off  and
500cAC                             wrgsts = *off  or
500cA*
500cAC                             mrgrte = *on  and
500cAC                             mrgord = *off  and
500cAC                             wrgsts = *on
500cAC                   eval      omord = neword
500cA*
500cA*    Open route found, Open order found.
500cA*    Add item to current Open order.
500cAC                   when      mrgrte = *on  and
500cAC                             mrgord = *on  and
500cAC                             wrgsts = *off
500cAC                   eval      omord = opnord
500cA*
500cAC                   other
500cAC                   eval      omord = ohord
500cAC                   endsl
500cA*
500cAC                   eval      omseq  = oidseq
500cAC                   eval      omitem = oiditm
500cAC                   eval      omodsc = oimdsc
500cAC                   eval      ompdsc = oimpds
500cAC                   eval      omrdsc = oimrds
500cAC                   eval      omcbox = oimbox
500cAC                   eval      omcexp = oimexp
500cAC                   eval      ommsc1 = oimms1
500cAC                   eval      ommsc2 = oimms2
500cAC                   eval      ommsc3 = oimms3
500cAC                   eval      ommsc4 = oimms4
500cAC                   eval      ommsc5 = oimms5
500cA*
500cAC     endlodm       tag
500cA*
500cAC                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOS  Fill order detail pick slot fields.
     *
     C     filloS        begsr
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
     C                   exsr      zzgtos
     C                   eval      rcdlck = *off
     *
     C                   select
     C                   when      not *in71  and
     C                             oiditm = oditem
     *
     C                   eval      osdisp = oidslt
     C                   eval      osbulk = oidblk
     C                   update    osrec
     *
     C                   goto      endlods
     C                   endsl
     *
     C                   endsl
     *
     *  Initialize record
     *
     C                   clear                   osrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      oswhse = oidwhs
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
     C                   eval      osord = neword
     *
     *    Open route found, Open order found.
     *    Add item to current Open order.
     C                   when      mrgrte = *on  and
     C                             mrgord = *on  and
     C                             wrgsts = *off
     C                   eval      osord = opnord
     *
     C                   other
     C                   eval      osord = ohord
     C                   endsl
     *
     C                   eval      osseq  = oidseq
     C                   eval      ositem = oiditm
     C                   eval      osdisp = oidslt
     C                   eval      osbulk = oidblk
     *
     C     endlods       tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOH   Fill order header fields.
     *
     C     filloh        begsr
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
     C                   eval      ohstop = oihstp
     *
     C                   eval      ohtruk = $ptruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  FILLHM  Fill order header misc file fields.
520aA*
520aAC     fillHM        begsr
520aA*
520aAC     oihmkey       chain     impfordhm
520aAC                   if        not %found(impfordhm)
520aAC                   eval      ohmms1 = ' '
520aAC                   eval      ohmms2 = ' '
520aAC                   eval      ohmms3 = ' '
520aAC                   eval      ohmms4 = ' '
520aAC                   eval      ohmms5 = ' '
520aAC                   endif
520aA*
520aAC                   select
520aA*    Open route found, Open order found.
520aA*    Retrieve Open Order Header Misc. file
520aAC                   when      mrgrte = *on  and
520aAC                             mrgord = *on  and
520aAC                             wrgsts = *off
520aAC                   eval      kyord = opnord
520aA*
520aAC                   other
520aAC                   eval      kyord = neword
520aAC                   endsl
520aA*
520aAC                   eval      rcdlck = *on
520aAC                   exsr      zzgethm
520aAC                   eval      rcdlck = *off
520aA*
520aAC                   select
520aAC                   when      %found(ordhm)
520aA*
520aAC                   select
520aA*    Open route found, Open order found.
520aA*    Leave route ID untouched.
520aAC                   when      mrgrte = *on  and
520aAC                             mrgord = *on  and
520aAC                             wrgsts = *off
520aA*
520aA*    Open route found, Open order NOT found.
520aA*    Add Order to current Open Route.
520aAC                   when      mrgrte = *on  and
520aAC                             mrgord = *off  and
520aAC                             wrgsts = *off
520aAC                   eval      hmrtid = opnrte
520aAC                   other
520aAC                   eval      hmrtid = rhrtid
520aAC                   endsl
520aA*
520aAC                   eval      hmmsc1 = ohmms1
520aAC                   eval      hmmsc2 = ohmms2
520aAC                   eval      hmmsc3 = ohmms3
520aAC                   eval      hmmsc4 = ohmms4
520aAC                   eval      hmmsc5 = ohmms5
520aAC                   update    hmrec
520aA*
520aAC                   goto      endlodhm
520aA*
520aAC                   endsl
520aA*
520aA*  Initialize record
520aA*
520aAC                   clear                   hmrec
520aA*
520aA*  Move fields from download file to order detail misc file fields.
520aA*
520aAC                   eval      hmwhse = oihwhs
520aAC                   eval      hmord = neword
520aAC                   select
520aA*
520aA*    Open route found, Open order NOT found.
520aA*    Add Order to current Open Route.
520aAC                   when      mrgrte = *on  and
520aAC                             mrgord = *off  and
520aAC                             wrgsts = *off
520aAC                   eval      hmrtid = newrte
520aA*
520aAC                   other
520aAC                   eval      hmrtid = rhrtid
520aAC                   endsl
520aA*
520aAC                   eval      hmmsc1 = ohmms1
520aAC                   eval      hmmsc2 = ohmms2
520aAC                   eval      hmmsc3 = ohmms3
520aAC                   eval      hmmsc4 = ohmms4
520aAC                   eval      hmmsc5 = ohmms5
520aA*
520aAC     endlodhm      tag
520aA*
520aAC                   endsr
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
     *
     C                   if        $ptype = 'W'  and
     C                             oihrte = *blanks
     *
     C                   eval      rhrte = rhrtid
     C                   else
     C                   eval      rhrte = oihrte
     C                   endif
     C                   eval      newrtc = oihrte
740 Ac                   if        autoWave
740 Ac                   eval      oihtyp='V'
740 Ac                   endif
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
740 A /free
740 A      // Add Wave Detail if this is Wave Import
740 A      if autoWave;
740 A         exsr wrtWaveDtl;
740 A      endif;
740 A /end-free
     *
     C                   endsr
750 A*
750 A*----------------------------------------------------------------
750 A*
750 A*  FILLXR   Fill Stop Xref File RTESTP
750 A*
750 AC     fillxr        begsr
750 A*
750 A*  Initialize record
750 A*
750 Ac                   clear                   rtsRec
750 A*
750 Ac                   eval      rtswhs = ohWhse
750 Ac                   eval      rtsrid = ohRte
750 Ac                   eval      rtsord = ohord
750 Ac                   eval      rtsstp = ohstop
750 Ac                   eval      rtsst5 = ohstop
750 Ac                   eval      rtssd = '000' + %editc(ohstop : 'X')
750 A*
750 Ac                   endsr
750 A*
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
     C                   parm      'OI2751PR'    $lrpt            10
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
     C                   close     oi2751pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI2751PR) OUTQ(*DEV) DEV($dev)
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
     *      Open printer file.
     *
     C                   open      oi2751pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr

740 A*----------------------------------------------------------------
740 A*  SubmitWave   Submit Wave Processing
740 A*----------------------------------------------------------------
740 A
740 A /free
740 A  begsr SubmitWave;
740 A
740 A    // Determine jobq to use
740 A
740 A    bfcjobq = 'BFCWAVE';
740 A    exsr chkjobq;
740 A
740 A    // Build call string
740 A
740 A    sbmCmd = 'CALL  '
740 A           +   'PGM(TBW600) '
740 A           +   'PARM('
740 A           +      sq + %editc($pWhse:'X') + sq + ' '
740 A           +      sq + waveId + sq + ' '
740 A           +   ')';
740 A
740 A    if SubmitJob(#pgm: bfcjobq:
740 A                 sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;
740 A
740 A      bdtype = 'ERROR';
740 A      bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
740 A      exsr WrtDebug;
           // Send message to QSYSOPR if this fails
740 A      return;
740 A
740 A    endif;
740 A
740 A    // Update Wave files with Submit information
740 A    chain ($pwhse:waveid) tbwaveh;
740 A    if %found(tbwaveh);
740 A       twhsbmjob=sbmjob;
740 A       twhsbmuser=sbmUser;
740 A       twhsbmjobn=sbmJobnbr;
740 A       update twhrec;
740 A    endif;
740 A    setll (*loval) tbwaveh;
740 A
740 A    setll ($pwhse:waveid) tbwaved;
740 A    dow forevr=forevr;
740 A      reade ($pWhse:waveid) tbwaved;
740 A      if not %equal(tbwaved) or %eof(tbwaved);
740 A        leave;
740 A      endif;
740 A      twdsbmjob=sbmjob;
740 A      twdsbmuser=sbmUser;
740 A      twdsbmjobn=sbmJobnbr;
740 A      update twdrec;
740 A    enddo;
740 A    setll (*loval) tbwaved;
740 A
740 A  endsr;
740 A /end-free
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
ETT AC                   if        client = Ettline
IFD AC                             or client = IFD
ETT A*      No truck template assigned if default not found.
ETT AC                   eval      $xcmd = '*DFTNOAU'
ETT AC                   else
ETT AC                   eval      $xcmd = '*DFLT   '
ETT AC                   endif
ETT A*
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
ETT DC*                  parm      '*DFLT   '    $xcmd             8
ETT MC                   parm                    $xcmd             8
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
     C     keyrs         chain     rtesum                             77
     *
     *     Record does not exist - Initialize fields.
     *
     C                   if        *in77
     C                   eval      rswhse = rhwhse
     *R                   MOVE RHRTID    RSRTID
     C                   eval      rsrtid = kyrtid
     C                   eval      rswhdp = itwhdp
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
530bA*     Get base item for alias item.
530bAC                   eval      #bityp = *blanks
530bAC                   if        ittype = 'A'
530bAC                   call      'GETBASE'
530bAC                   parm      itwhse        $gwhse            3 0
530bAC                   parm      ititem        $gitem           15
530bAC                   parm      ' '           #bitem           15
530bAC                   parm                    #bityp            1
530bAC                   parm                    #bdesc           30
530bAC                   parm                    #bpdsc           15
530bAC                   parm                    #bwhdp            5
530bAC                   parm                    #bstyp            1
530bAC                   parm                    #bum1             2
530bAC                   parm                    #bum2             2
530bAC                   parm                    #bumq2            3 0
530bAC                   parm                    #bum3             2
530bAC                   parm                    #bumq3            3 0
530bAC                   parm      ' '           #bcitm           15
530bAC                   parm                    #bctyp            1
530bAC                   parm                    #bcdsc           30
530bAC                   parm                    #bcpds           15
530bAC                   parm                    #bcwdp            5
530bAC                   parm                    #bcstp            1
530bAC                   parm                    #bcum1            2
530bAC                   parm                    #bcum2            2
530bAC                   parm                    #bcuq2            3 0
530bAC                   parm                    #bcum3            2
530bAC                   parm                    #bcuq3            3 0
530bAC                   parm                    #brtn             8
530bAC                   endif
530bA*
     *R                   ADD  ODQOR1    RSORDP
     C                   add       difqy1        rsordp
     *R         ITCUBE    MULT ODQOR1    TMPCUB
530bAC                   if        #bityp = 'S'  or
530bAC                             ittype = 'S'
530bAC                   if        itumq2 <= 0
530bAC                   eval      tmpcub = tmpcub * difqy1
530cAC                   eval      tmpwgt = tmpwgt * difqy1
530bAC                   else
530bAC     itcube        div(h)    itumq2        tmpcub
530cAC     itswgt        div(h)    itumq2        tmpwgt
530bAC                   eval      tmpcub = tmpcub * difqy1
530cAC                   eval      tmpwgt = tmpwgt * difqy1
530bAC                   endif
530bAC                   else
     C                   eval      tmpcub = itcube * difqy1
530cAC                   eval      tmpwgt = itswgt * difqy1
530bAC                   endif
530bA*
     C                   add       tmpcub        rsordc
     *R         ITSWGT    MULT ODQOR1    TMPWGT
530cDC*                  eval      tmpwgt = itswgt * difqy1
     C                   add       tmpwgt        rsordw
     *
     *R                   ADD  ODQOR2    RSORDP
     C                   add       difqy2        rsordp
     *R         ODQOR2    IFNE 0
     C                   if        difqy2 <> 0  and
     C                             itumq2 > 0
     C     itcube        div(h)    itumq2        tmpcub
     *R         TMPCUB    MULT ODQOR2    TMPCUB
     C                   eval      tmpcub = tmpcub * difqy2
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq2        tmpwgt
     *R         TMPWGT    MULT ODQOR2    TMPWGT
     C                   eval      tmpwgt = tmpwgt * difqy2
     C                   add       tmpwgt        rsordw
     C                   endif
     *
     *R                   ADD  ODQOR3    RSORDP
     C                   add       difqy3        rsordp
     *R         ODQOR3    IFNE 0
     C                   if        difqy3 <> 0  and
     C                             itumq3 > 0
     C     itcube        div(h)    itumq3        tmpcub
     *R         TMPCUB    MULT ODQOR3    TMPCUB
     C                   eval      tmpcub = tmpcub * difqy3
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq3        tmpwgt
     *R         TMPWGT    MULT ODQOR3    TMPWGT
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
740 A*----------------------------------------------------------------
740 A*
740 A*  wrtWaveDtl  Write Wave Detail
740 A*
740 AC     wrtWaveDtl    begsr
740 A /free
740 A       twdwhs=$pWhse;
740 A       twdid=waveid;
740 A       twdrtid=rhrtid;
740 A       twdrte=rhrte;
740 A       twdsts='I';          // Imported
740 A       twdsbmjob=*blanks;
740 A       twdsbmuser=*blanks;
740 A       twdsbmjobn=*blanks;
740 A       write twdrec;
740 A
740 A /end-free
740 AC                   endsr
740 A*----------------------------------------------------------------
740 A*
740 A*  wrtWaveHdr  Write Wave Header
740 A*
740 AC     wrtWaveHdr    begsr
740 A /free
740 A       branchid=*blanks;
740 A       divcd=*blanks;
740 A       wave#=*zeros;
740 A       waveid=*blanks;
740 A       pirwave#(wave#);
740 A       twhid='W';
740 A       if client = usfcrp;
740 A         getbranch(branchid:pdesc:
740 A                   phost:predp:
740 A                   piiuf:peiuf:
740 A                   probn:plbls:
740 A                   divcd);
740 A         if divcd=*blanks;
740 A            divcd=branchid;
740 A         endif;
740 A         twhid = %trim(twhid) + %trim(divcd) + %editc(wave#:'X');
740 A       else;
740 A         twhid = %trim(twhid) + %editc(wave#:'X');
740 A       endif;
740 A
740 A       twhwhs = $pWhse;
740 A       twhaddts=%timestamp();
740 A       twhsbmjob=*blanks;
740 A       twhsbmuser=*blanks;
740 A       twhsbmjobn=*blanks;
740 A
740 A       // chain for record with import member to retrieve ifs file
740 A       // name used in Wave Header
740 A       chain ($pwhse:impmbr) tbfmtoifs;
740 A       if %found(tbfmtoifs);
740 A         twhifn = twfifn;
740 A       endif;
740 A
740 A       dow forevr=forevr;
740 A         chain ($pWhse:twhid) tbwaveh;
740 A         if not %found(tbwaveh);
740 A           leave;
740 A         else;
740 A           pirwave#(wave#);
740 A           if client = usfcrp;
740 A             twhid = 'W' + %trim(divcd) + %editc(wave#:'X');
740 A           else;
740 A             twhid = 'W' + %editc(wave#:'X');
740 A           endif;
740 A         endif;
740 A       enddo;
740 A       waveid=twhid;
740 A       write twhrec;
740 A
740 A /end-free
740 AC                   endsr
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
     *
     C     rh1key        setgt     rtehed1
     C     rh1key        readpe    rtehed1                                73
     C                   select
     C                   when      not *in73  and
740 DC*                            rhtype = ' '  and
740 MC                             (rhtype = ' ' or rhtype='V') and
     C                             rhstat = '1'
     C                   eval      mrgrte = *on
     C                   eval      opnrte = rhrtid
     C                   eval      opnrtc = rhrte
     *
     C                   other
     C                   eval      mrgrte = *off
     C                   unlock    rtehed1
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
     *    same customer.
     C                   when      not *in77  and
740 DC*                            oihtyp = ' '  and
740 DC*                            ohtype = ' '  and
740 MC                             (oihtyp = ' ' or oihtyp='V')  and
740 MC                             (ohtype = ' ' or ohtype='V') and
     C                             ohstat = 'O'
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
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZGETHM   Get order header misc. file rcd. (with/without) record lock.
520aA*
520aAC     zzgethm       begsr
520aA*
520aAC                   select
520aAC                   when      rcdlck = *off
520aAC     hmkey         chain(n)  ordhm
520aA*
520aAC                   when      rcdlck = *on
520aAC     hmkey         chain     ordhm
520aA*
520aAC                   endsl
520aA*
520aA*    Order header misc. record not found. Clear misc fields.
520aAC                   if        not %found(ordhm)
520aAC                   eval      hmmsc1 = ' '
520aAC                   eval      hmmsc2 = ' '
520aAC                   eval      hmmsc3 = ' '
520aAC                   eval      hmmsc4 = ' '
520aAC                   eval      hmmsc5 = ' '
520aAC                   endif
520aA*
520aAC                   endsr
520aA*
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
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZGTOS  Get order detail misc. file rcd. (with/without) record lock.
500cA*
500cAC     zzgtom        begsr
500cA*
500cAC                   select
500cAC                   when      rcdlck = *off
500cAC     omkey         chain(n)  orddm
500cA*
500cAC                   when      rcdlck = *on
500cAC     omkey         chain     orddm
500cA*
500cAC                   endsl
500cA*
500cA*    Order detail line item not found. Clear misc fields.
500cAC                   if        not %found(orddm)
500cAC                   eval      omodsc = ' '
500cAC                   eval      ompdsc = 'N'
500cAC                   eval      ompdsc = 'N'
500cAC                   eval      omrdsc = 'N'
500cAC                   eval      omcbox = 'N'
500cAC                   eval      omcexp = 'N'
500cAC                   eval      ommsc1 = ' '
500cAC                   eval      ommsc2 = ' '
500cAC                   eval      ommsc3 = ' '
500cAC                   eval      ommsc4 = ' '
500cAC                   eval      ommsc5 = ' '
500cAC                   endif
500cA*
500cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTOS  Get order detail pick slot record. (with/without) record lock.
     *
     C     zzgtos        begsr
     *
     C                   select
     C                   when      rcdlck = *off
     C     oskey         chain(n)  ordds                              71
     *
     C                   when      rcdlck = *on
     C     oskey         chain     ordds                              71
     *
     C                   endsl
     *
     *    Order detail line item not found. Clear qty fields.
     C                   if        *in71 = *on
     C                   eval      osdisp = *blanks
     C                   eval      osbulk = 'N'
     C                   endif
     *
     C                   endsr
500aA*
500aA*----------------------------------------------------------------
500aA*
500aA*  CRTLABELS Create Dakota Label records from Host generated labels
500aA*
500aAC     crtlabels     begsr
500aA*
500aAC                   call      'RH225'
500aAC                   parm      oilwhs        $pwhse            3 0
500aAC                   parm      $ptype        $Ptype            1
500aAC                   parm      lstrid        $prtid            5
500aAC                   parm      *blanks       $prtn             8
500aA*
500aAC                   endsr
500aA*
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
     * Loop through P.O. detail records looking for item.
     C     keypd1        setll     podtl1
     C                   dow       forevr = forevr
     C     keypd1        reade     podtl1                                 79
     * Error if none found.
     C                   if        *in79
     C                   eval      pdseq = 0
     C                   eval      pdpo = oidpo
     *R                   MOVE DESC,4    DETMSG
     *R                   ADD  1         BADPO
     *R                   LEAVE
     C                   endif
     * If cross dock slot record exists, update
     C                   movel     'XDK'         kydisp
     C     keysl4        setll     slot4
     C                   dow       forevr = forevr
     C                   read      slot4                                  79
     C                   if        not *in79  and
     C                             slstat = 'XD'  and
     C                             slwhse = $pwhse  and
     C                             slwhdp = itwhdp  and
     C                             slitem = oiditm  and
     C                             slaisl = 'XDK'
     * Pre-allocate product in case receiving is done before picking.
     C                   add       oidq1         slalc1
     C                   if        itflg1 = 'Y'
     C                   add       oidq2         slalc2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   add       oidq3         slalc3
     C                   endif
     C                   update    slrec4
     C                   goto      addxdk
     C                   else
     C                   unlock    slot4
     C                   leave
     C                   endif
     C                   enddo
     * Create cross dock slot record.
     C                   eval      tmploc = 1
     C                   eval      kyaisl = 'XDK'
     C     keysl1        setll     slot1
     C                   dow       forevr = forevr
     C     keysl1        reade(n)  slot1                                  79
     C                   if        *in79  or
     C                             slloc > tmploc
     C                   leave
     C                   endif
     C     slloc         add       1             tmploc
     C                   enddo
     *
     C                   clear                   slrec
     C                   eval      slwhse = oidwhs
     C                   eval      slwhdp = itwhdp
     C                   eval      slaisl = 'XDK'
     C                   eval      slloc = tmploc
     C                   eval      slrlvl = 1
     C                   eval      slhand = *blanks
     C                   eval      slstyp = 'X'
     C                   eval      slpseq = tmploc
     C                   eval      slitem = oiditm
     *                    MOVE 'A '      SLSTAT
     C                   eval      slstat = oidspc
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     * Format display slot.
     C                   call      'FRMTSL'
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C                   parm                    slhand
     C                   parm                    slstyp
     C                   parm                    slpseq
     C                   parm                    sldisp
     * Pre-allocate product in case receiving is done before picking.
     C                   eval      slalc1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   z-add     oidq2         slalc2
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     oidq3         slalc3
     C                   endif
     * Add record
     C     slloc         div       2             dummy
     C                   mvr                     slside
     C                   if        slside < 0
     C                   eval      slside = -(slside)
     C                   endif
     C                   write     slrec                                77
     * Error if slot not created.
     C                   if        *in77
     C                   eval      detmsg = desc(5)
     C                   add       1             badpo
     C                   leave
     C                   endif
     * Create cross dock record.
     C     addxdk        tag
     C                   eval      cdwhse = slwhse
     C                   eval      cdwhdp = slwhdp
     C                   eval      cdslot = sldisp
     C                   eval      cdord = ohord
     C                   eval      cdorsq = oidseq
     C                   eval      cdort# = 0
     C                   eval      cdorl# = 0
     C                   eval      cdpo = pdpo
     C                   eval      cdposq = pdseq
     C                   eval      cdpot# = 0
     C                   eval      cdpol# = 0
     C                   write     cdrec                                79
     C                   if        *in79
     C                   eval      detmsg = desc(6)
     C                   add       1             badpo
     C                   else
     C                   eval      good2 = 'Y'
     C                   endif
     C                   leave
     C                   enddo
     *
     C     endxd         endsr
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
740 A
740 A*----------------------------------------------------------------
740 A*  wrtDebug       Write out debug record
740 A*----------------------------------------------------------------
740 A
740 A /free
740 A  begsr wrtDebug;
740 A
740 A    bdaddts = %timestamp();
740 A    bdaddpgm = #pgm;
740 A    bdaddcusr = #curruser;
740 A    bdaddjusr = #user;
740 A    bdaddjob = #job;
740 A    bdaddnbr = #jobnbr;
740 A
740 A    write(e) bdrec;
740 A
740 A  endsr;
740 A /end-free
740 A
740 A*----------------------------------------------------------------
740 A*  SubmitJob   Submit job to job queue
740 A*
740 A*     peName    = name of job to submit
740 A*     peJobQ    = Queue to submit to
740 A*     peCmd     = Command to submit
740 A*     peSbmName = name returned by the submit job command
740 A*     peSbmUser = user returned by the submit job command
740 A*     peSbmNbr  = job number returned by the submit job command
740 A*
740 A*  Returns 0 if successful, or -1 if it failed
740 A*----------------------------------------------------------------
740 AP SubmitJob       B                   export
740 AD SubmitJob       PI            10I 0
740 AD   peName                      10A   const varying
740 AD   peJobQ                      10A   const varying
740 AD   peCmd                     3000A   const varying
740 AD   peSbmName                   10A   options(*nopass)
740 AD   peSbmUser                   10A   options(*nopass)
740 AD   peSbmNbr                     6A   options(*nopass)
740 A
740 A*  Local Variables
740 A
740 AD cmd             s           3000    varying
740 A
740 AD dsM1            DS
740 AD  dsM1_BytRtn                  10I 0
740 AD  dsM1_BytAvl                  10I 0
740 AD  dsM1_MsgSev                  10I 0
740 AD  dsM1_MsgID                    7A
740 AD  dsM1_MsgType                  2A
740 AD  dsM1_MsgKey                   4A
740 AD  dsM1_Reserv1                  7A
740 AD  dsM1_CCSID_st                10I 0
740 AD  dsM1_CCSID                   10I 0
740 AD  dsM1_DtaLen                  10I 0
740 AD  dsM1_DtaAvl                  10I 0
740 AD  dsM1_Dta                    256A
740 A
740 AD dsEC            DS
740 AD  dsECBytesP             1      4I 0 INZ(%size(dsEC))
740 AD  dsECBytesA             5      8I 0 INZ(0)
740 AD  dsECMsgID              9     15
740 AD  dsECReserv            16     16
740 AD  dsECMsgDta            17    256
740 A
740 AD wwMsgKey        S              4A
740 AD wwJobNo         S             26A
740 A
740 A /free
740 A
740 A    // Submit job
740 A
740 A    cmd = 'SBMJOB CMD(' + peCmd + ') ' +
740 A          'JOBQ(' + peJobQ +') ' +
740 A          'JOB(' + peName+ ')';
740 A
740 A    monitor;
740 A      qcmdexc(%trim(cmd): %len(%trim(cmd)));
740 A    on-error *all;
740 A      return -1;
740 A    endmon;
740 A
740 A    // Look for a success message
740 A
740 A    wwMsgKey = *ALLx'00';
740 A    dou dsECBytesA>0 or dsM1_MsgID='CPC1221';
740 A      QMHRCVPM(dsM1: %size(dsM1): 'RCVM0100':
740 A               '*': 0: '*PRV': wwMsgKey: 0: '*SAME':
740 A               dsEC);
740 A      wwMsgKey = dsM1_MsgKey;
740 A    enddo;
740 A
740 A    if dsECBytesA>0;
740 A      return -1;
740 A    endif;
740 A
740 A    // Grab the job info from the response
740 A
740 A    if dsM1_DtaAvl >= 26;
740 A      wwJobNo = %subst(dsM1_Dta:1:26);
740 A    else;
740 A      wwJobNo = *blanks;
740 A    endif;
740 A
740 A    if %parms >= 4;
740 A      peSbmName = %subst(wwJobNo:1:10);
740 A    endif;
740 A
740 A    if %parms >= 5;
740 A      peSbmUser = %subst(wwJobNo:11:10);
740 A    endif;
740 A
740 A    if %parms >= 6;
740 A      peSbmNbr = %subst(wwJobNo:21:6);
740 A    endif;
740 A
740 A    return 0;
740 A
740 A /end-free
740 A
740 AP                 E
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
*NO QUANTITY*
**
Import FTP Orders
**   OVRPRTF statment
OVRPRTF FILE(OI2751PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
