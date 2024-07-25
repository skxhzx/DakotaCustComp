500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI255     Import FTP orders - Post
     *  26 February 1999
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
411 A*    03/14/99  DAS 4.11
     *      - Changed key of IMPFORDH file to include route. This will
     *        allow for multiple routes to be included in one FTP file.
     *      - Revised to print heading if warehouse changes.
     *
414 A*    05/11/00  DAS 4.14
     *      - Revised FILLRH for willcalls. If route is blank it will
     *        be set to the route id. If truck is blank it will be set
     *        to WILLCALL.
     *
414aA*    05/19/00  DAS  4.14a
     *      - Revised to send route id back to calling program.
     *
416 A*    10/05/01  MLB  4.16
     *      - Added exception print file to program.
416aA*    10/05/01  MLB  4.16a
     *      - Revised program to merge Add-on orders to
     *        Open Route.
     *      - Added files: OPTIONS,ORDD1,ORDH4,RTEHED1.
416bA*    10/11/01  MLB  4.16b
     *      - Added cross dock support to this program.
     *
416cA*    06/05/02  DAS  4.16c
     *      - Added 'S' order type.
     *
416dA*    06/13/02  DAS  4.16d
     *      - Revised to capture and send back up to 10 route id's.
     *
416eA*    06/20/02  MLB  4.16e
     *      - Use OIHTRK field instead of RHTRUK
     *
417 A*    07/15/03  MLB  4.17
     *      - Fix: Use OIHRTE field instead of RHRTE
     *
417aA*    05/03/04  DAS  4.17a
     *      - Enh: Created routine UPDRTE to automatically assign
     *        a truck code when the code is blank.
     *      - Revised main line to call UPDRTE for each order header.
     *
500aA*    07/26/05  RH   5.00a
     *      - Fix: Add code to get base if item type = A.
     *        Change to divide ITCUBE by brk qty to calculate cube for
     *        type 'S' item.
500bA*    08/15/05  MLB  5.00b
     *      - Enh: Revised program to NOT separate type 'S'=Single
     *        Selection orders during import processing.
500cA*    09/30/05  MLB  5.00c
     *      - Enh: Revised OPNPRT routine to process ovrprtf for prtf
     *        OI255PR to allow better user control of printed report.
     *        Added OVRPRTF cmd entry to array OVRPRT.
     *
500dA*    01/16/06  DAS  5.00d
     *     - Added support for client id's.
     *     - Revise to use KYWHDP RTESUM key instead of ITWHDP.
500eA*    02/24/06  MLB  5.00e
     *      - Enh: Converted program to ILE.
     *      - Enh: Converted Client copybooks to ID#xxxx from IL#xxxx.
     *      - Enh: Revised program to add new files, IMPFORDM. This file
     *        has optional Voice selection info and item description
     *        override. This file has 5 user fields that can be populated
     *        with any data required by client.
500fA*    03/21/06  MLB 5.00f
     *      - Enh: Revised routine FILLOM to clear fields from IMPFORDM
     *        when the record wasn't found.
     *
510 A*    06/09/06  MLB  5.10
     *     - Enh: Added files IMPFORDHM, ORDHM to program. This files
     *       are miscelleanous files. If they are used, there must be
     *       a record in the IMPFORDHM file for every record in the
     *       IMPFORDH file.
510dA*    09/27/07  MLB  5.10d
     *     - Fix: Revised FILLHM routine to add test for IMPFORDHM
     *       was found before attempting to write record to ORDHM.
     *
520aA*    03/27/08  DAS  5.20a
     *      - Enh: Revised to delete all XDK slots with a status of 'Z'
     *        at the beginning of the program. Re: The ZZXDCK routine
     *        treats this a slot not being found for the item, which
     *        could result in multiple 'XD' slots being created for
     *        an item, which messes up Receiving because it is
     *        assuming an item will only have 1 XDK slot.
520bA*    04/02/08  MLB  5.20b
     *      - Enh: Revised to delete all XDK slots from CROSSDK file
     *        when cross dock slot is deleted.
520cA*    09/29/08  JCJ  5.20c
     *      - Enh: Added $XCMD to parm list of OI260.
520dA*    01/27/09  CWM 5.20d
     *      - Enh: Remove GETSTOP Enhancement
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
     *        From: OVRPRTF FILE(OI2551PR OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
     *        From: OVRPRTF FILE(OI255PR OUTQ(*DEV) DEV(XXXXXXXXXX)
     *              FORMTYPE(XXXXXXXXXX)
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
     *    - Fix: Revised varianble SUBLIN to be 7,0 from 3,0. Orders
     *      greater than 999 lines causes RNQ0103 Variable too small
     *      to hold result error.
640cA*    10/07/12  MLB  6.40c  P#01088
     *    - Enh: Revised program to retrieve customer specific notes and
     *      load them into the ORDDM file in OMMSC5 to later printing
     *      and sending to Dakota Voice selection.
     *    - If customer# is all 9's, then note applies to all customers
     *      if note expiration date isn't hasn't expired or date is zero.
     *    - Revised program to make file ORDDM opened under program
     *      control instead of user control.
     *    - Added file, CUSTNTS to program.
650aA*    01/31/13  RBD  6.50a
     *    - Enh: If Trax user, call OI128 to write Trax Stop Flags
     *      if any are imported.
650bA*    02/18/13  RBD  6.50b
     *    - Fix: Use whse 0 for chain to options with *SYSTEM.
650cA*    07/28/14  MLB  6.50c
     *      - Fix: Revised program to prevent string error when OHWHS
     *        is zero.
     *
750 A*    03/02/22  MLB  7.50
     *      - Enh: Revised program to add RTESTP file to program to be
     *        populated as ORDH records are written out. RTESTP needs
     *        to be populated for DD2 processing. Found at City Line.
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
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    06/30/08  JCJ  CTWa
     *      - Revised to blank RHTRUK after the call to OI260.
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
     *  Client Custom Revisions: Andrews Foodservice
     *
ADW A*    07/26/10  MLB  ADW
     *      - Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJK A*    08/06/08  MLB  MJK
     *      - Added MJK to mod VIP listed below.
     *      - Revised program to use imported item weight/cube for
     *        item# '9999999999' in computations when adding rcds
     *        to RTESUM.
MJKaA*    07/08/10  MLB  MJKa
     *      - Revised program to check Host Company/Division/Location
     *        when merging routes to ensure that orders from different
     *        division/locations are not combined together.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/14/07  MLB  VIP
     *      - Revised program to use imported item weight/cube for
     *        item# '9999999999' in computations when adding rcds
     *        to RTESUM.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR A*    11/22/13  MLB  JOR
     *      - Enh: Revised pgm to send new cmd, *DFTNOAU - Assign default
     *        truck, no auto assign truck template.
     *      - Added JOR to ADW mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC Foodservice
     *
TPC A*    01/31/17  MLB  TPC
     *      - Enh: Revised pgm to update PODTL file, field PDSPCL = XD
     *        when updating CROSDK file. TPC's interfaces were not able
     *        to be updated to send XD in p/o detail file for cross dock
     *        purchase orders. Pgm, PI265 will be modified with similar
     *        changes to flag PODTL when p/o and item are found in
     *        CROSDK file.
     *      - File PODTL1 changed to update/full procedural from input/
     *        full procedural.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLDa *    11/15/18  RTR  CLDa
     *      - Enh: Changed to blank truck sent from host per Steve.
     *        This will allow truck to auto-select.
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
510 A*  67        - Open of IMPFORDHM or ORDDHM failed.
500eA*  68        - Open of IMPFORDM or ORDDM failed.
     *  78        - EOF for IMPFORDD
     *  79        - EOF for IMPFORDH
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfordh  uf   e           k disk
510 AFimpfordhm uf   e           k disk    usropn
     Fimpfordd  uf   e           k disk
500eAFimpfordm  uf   e           k disk    usropn
640cAFcustnts   if   e           k disk
PAK AFcustmisc  if   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
416bAFslot1     uf a e           k disk
416bAFslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
520aAFslot11    uf   e           k disk
520aAF                                     rename(slrec:slrec11)
     Frtesum    uf a e           k disk
416aAFordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
416aAFordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
416aAFoptions   if   e           k disk
TPC DF*podtl1    if   e           k disk
TPC MFpodtl1    uf   e           k disk
416aAFrtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
640 AFrtehed2   if   e           k disk
640 AF                                     rename(rhrec:rhrec2)
     Frtehed    o  a e           k disk
416aD*ORDH    O   E           K        DISK                      A
416aMFordh      uf a e           k disk
510 AFordhm     uf a e           k disk    usropn
520bDF*crossdk   o  a e           k disk
520bMFcrossdk   uf a e           k disk
     Fordd      o  a e           k disk
640cMF*orddm     uf a e           k disk    usropn
640cMForddm     uf a e           k disk
750 AFrtestp    uf a e           k disk
500cD*OI255PR O   E             91     PRINTER
500cMFoi255pr   o    e             printer oflind(*in91)
     F                                     usropn
416 AFoi2551pr  o    e             printer oflind(*in92)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
416bD*                   DESC    1   3 20
416bMD desc            s             20    dim(6) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
416 AD a80             s              1    dim(80)
500cD*                   OVRPRT  1   1 80
500cMD ovrprt          s             80    dim(2) ctdata perrcd(1)
500dA*----------------------------------------------------------------
500dA*  Customer id
500dA*
     D @getcl          c                   const('GETCLIENT')
500dA*
500eM /COPY QCOPYSRC,ID#CHENEY
500eM /COPY QCOPYSRC,ID#CHENEYO
500eM /COPY QCOPYSRC,ID#CHENEYR
CTWaA /COPY QCOPYSRC,ID#CITYWHO
PAK A /COPY QCOPYSRC,ID#PACKERS
ADW   /copy qcopysrc,id#Andrews
VIP A /COPY QCOPYSRC,ID#VIP
MJK A /COPY QCOPYSRC,ID#MJKELLN
JOR A /COPY QCOPYSRC,ID#JORDANO
CLDaA /copy qcopysrc,id#citylin
TPC A /COPY QCOPYSRC,ID#TPC
500dA*
416aA*----------------------------------------------------------------
416aA*  *GENPICK -  General picking options.
416aA*----------------------------------------------------------------
416aA*
416aA* Fields
416aA*
416aA*    OPERPT  -  Print exception (short) error report (Y,N).
416aA*    OPELBL  -  Print exception (short) labels (Y,N)
416aA*    OPRFWC  -  Using RF will call (Y,N).
416aA*    OPNRSC  -  Number of pallet sections (1-9).
416aA*    OPHPWC  -  Host pick Will Call (Y/N).
416aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
416aA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
416aA*
416aA* Data structure
416aA*
416aAD opdata          ds
416aAD  operpt                 1      1
416aAD  opelbl                 2      2
416aAD  oprfwc                 3      3
416aAD  opnrsc                 4      4  0
416aAD  ophpwc                 5      5
416aAD  opmrga                 6      6
416aAD  opplsq                 7      7
416aAD  optend               117    117
650aA*----------------------------------------------------------------
650aA*  *SYSTEM  -  System options.
650aA*----------------------------------------------------------------
650aA*
650aA* Fields
650aA*
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *    OPTAXR  -  Using TAXR module (Y/N).
     *    OPCHKR  -  Using CHKR module (Y/N).
     *    OPVOICE -  Using VOICE module (Y/N).
     *
     * Data structure
     *
     D opdat1          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optaxr                40     40
     D  opchkr                41     41
     D  opvoice               42     42
     D  opten1               117    117
416aA*----------------------------------------------------------------
416aA*  Re-definition field(s)
416aA*
416aAD                 ds
MJKaAD  ihcmpn                 1      3
MJKaAD  ihdivn                 4      6
MJKaAD  ihdptn                 7      9
MJKaAD  ihwhsn                10     12
416aAD  oihmec                13     15
416aAD  oihmsc                 1     20
416aAD                 ds
MJKaAD  ohcmpn                 1      3
MJKaAD  ohdivn                 4      6
MJKaAD  ohdptn                 7      9
MJKaAD  ohwhsn                10     12
416aAD  ohmemc                13     15
416aAD  ohmisc                 1     20
416 A*----------------------------------------------------------------
416 A*  Constants
416 A*
     D exchdr          c                   const('- Exceptions')
     D sts01           c                   const('** Added to existing-
     D                                      Open Order. ')
     D sts02           c                   const('** New Order Added t-
     D                                     o Open Route.')
     D sts03           c                   const('** Upd''d on existin-
     D                                     g Open Order.')
PAKbA*
PAKbA*----------------------------------------------------------------
PAKbA*  SAP Import Header/Detail Misc. File data structures
PAKbA*
PAKbA /copy qcopysrc,orddm1_pak
PAKbA /copy qcopysrc,orddm2_pak
PAKbA /copy qcopysrc,orddm3_pak
PAKbA /copy qcopysrc,orddm4_pak
PAKbA /copy qcopysrc,orddm5_pak
PAKbA*
PAKbA /copy qcopysrc,ordhm1_pak
PAKbA /copy qcopysrc,ordhm2_pak
PAKbA /copy qcopysrc,ordhm3_pak
PAKbA /copy qcopysrc,ordhm4_pak
PAKbA /copy qcopysrc,ordhm5_pak
PAKbA*
VIP A*----------------------------------------------------------------
VIP A*  VIP Import Detail Misc. File data structure(s)
VIP A*
VIP A /copy qcopysrc,orddm1_vip
VIP A*
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
640cAD addcustnote     s              4    inz('*NO ')
     D count           s              3  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D good1           s              1
     D good2           s              1
     D impdte          s              8  0
     D imptim          s              6  0
PAKaAD import_po       s              4    inz('*NO ')
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
510 AD mischdrupd      s              4    inz('*NO ')
500eAD miscupdate      s              4    inz('*NO ')
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
510 AD opnimpordhm     s              1    inz('0')
510 AD opnordhm        s              1    inz('0')
500eAD opnimpordm      s              1    inz('0')
500eAD opnordm         s              1    inz('0')
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
     D skpwrt          s              1
640 AD skpwrthdr       s              1    inz('0')
640 AD skpwrthdrm      s              1    inz('0')
640 AD skpwrtdtlm      s              1    inz('0')
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
     *  Parameters
     *
     *    Input Parameters
     *      $PTYPE  Order types to process.
     *              ' ' - Normal
     *              'T' - Transfer
     *              'W' - Will Call
416 A*              'S' - Single
     *
     *    Returned Parameters
     *      $PWHS   Warehouse to process.
     *      $PTRUK  Truck code.
416dD*****  $PRTID  Route id assigned to will call order.
416dA*      $PRT01  Route id assigned to will call order.
416dA*      $PRT02  Route id assigned to will call order.
416dA*      $PRT03  Route id assigned to will call order.
416dA*      $PRT04  Route id assigned to will call order.
416dA*      $PRT05  Route id assigned to will call order.
416dA*      $PRT06  Route id assigned to will call order.
416dA*      $PRT07  Route id assigned to will call order.
416dA*      $PRT08  Route id assigned to will call order.
416dA*      $PRT09  Route id assigned to will call order.
416dA*      $PRT10  Route id assigned to will call order.
PAKaA*      $PIMPPO Import purchase order(s) with delivery type='ZPLF'.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $ptype            1
     C                   parm                    $pwhs            15 5
     C                   parm                    $ptruk           10
416dD**                   PARM           $PRTID  5
416dAC                   parm                    $prt01            5
416dAC                   parm                    $prt02            5
416dAC                   parm                    $prt03            5
416dAC                   parm                    $prt04            5
416dAC                   parm                    $prt05            5
416dAC                   parm                    $prt06            5
416dAC                   parm                    $prt07            5
416dAC                   parm                    $prt08            5
416dAC                   parm                    $prt09            5
416dAC                   parm                    $prt10            5
PAKaAC                   parm                    $pimppo           4
     *----------------------------------------------------------------
     * Key definitions
     *
     * Download order detail file - Partial key
     *
     C     oidkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
640cA*
640cA* item notes file - full key
640cA*
640cAC     *like         define    ohcust        kycust
640cAC     cnkey         klist
640cAC                   kfld                    oihwhs
640cAC                   kfld                    kycust
640cAC                   kfld                    itwhdp
640cAC                   kfld                    oiditm
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
416aD*                    KFLD           RHRTID
416aMC                   kfld                    kyrtid
500dD**                   KFLD           ITWHDP
500dMC                   kfld                    kywhdp
     *----------------------------------------------------------------
     * Main line
416dA*
416dA* Initialize route id's
416dA*
416dAC                   eval      $prt01 = *blanks
416dAC                   eval      $prt02 = *blanks
416dAC                   eval      $prt03 = *blanks
416dAC                   eval      $prt04 = *blanks
416dAC                   eval      $prt05 = *blanks
416dAC                   eval      $prt06 = *blanks
416dAC                   eval      $prt07 = *blanks
416dAC                   eval      $prt08 = *blanks
416dAC                   eval      $prt09 = *blanks
416dAC                   eval      $prt10 = *blanks
416dAC                   eval      rtcnt = 0
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
416 A*
416 A*    Create heading for exceptions report.
416 A*
416 AC                   eval      $pstr = %trimr(rdsc(1)) + ' ' + exchdr
416 AC                   call      'CENTER'
416 AC                   parm                    $pstr
416 AC                   parm                    $plen
416 AC                   movel     $pstr         w1hdr1
416 AC                   eval      *in92 = *on
416 AC                   eval      prhdr1 = *off
416 AC                   eval      excprt = *off
416 AC                   eval      excpr1 = *off
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      grdlin = 0
416 AC                   eval      grord1 = *zeros
416 AC                   eval      grlin1 = *zeros
     C                   eval      preoh = 0
     C                   eval      preod = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     *
     * Whip through all the download header records
     *
     C                   eval      lstrte = '@@@@@'
417aAC                   eval      lstrid = '@@@@@'
411 D*                    MOVE *OFF      WFLAG   1
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
411 AC                   eval      lstwhs = -(1)
     *
     C                   dou       eofh = *on
CBIaAC                   if        client <> cheney
417aAC                   exsr      updrte
CBIaAC                   endif
     *
     C                   read      impfordh                               79
     C                   if        *in79
     C                   eval      eofh = *on
640 A*
640 A*  Merge order(s) into Open routes allowed.
640 A*  Check if any orders attached to new open route. If no, delete.
640 A*
640 AC                   if        opmrga = 'Y'  and
640 AC                             $ptype = ' '
640 AC                   exsr      zzckr1
640 AC                   endif
640 A*
     C                   goto      enddoh
     C                   endif
PAK A*
PAK AC                   if        client = packers
PAK A*
PAK A*      If route is blank, order sent is Will-Call order.
PAK AC                   if        oihrte = ' '
PAK AC                   eval      oihtyp = 'W'
PAK AC                   endif
PAK A*
PAK A*      See if customer is in Customer Misc file.
PAK AC     csmkey        chain     custmisc
PAK AC                   if        %found(custmisc)
PAK AC                   Eval      oihmsc = %Replace('*SP': oihmsc:7:3)
PAK AC                   endif
PAK A*
PAK AC                   endif
     *
     *  Create warehouse heading if necessary.
     *
411 D*          WFLAG     IFEQ *OFF
411 MC                   if        lstwhs <> oihwhs
     *
     C                   eval      whcode = oihwhs
416aAC                   eval      $pwhse = oihwhs
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
520aA*
520aA* Delete all status 'Z' XDK slots.
520aA*
520aAC                   exsr      zzzdelxdk
650aA*
650aA*   Get *SYSTEM options from options file.
650aA*
650bDC**                 eval      opwhse = oihwhs
650bMC                   eval      opwhse = 0
650aAC                   eval      opcode = '*SYSTEM'
650aAC     opkey         chain     options
650aAC                   if        not %found
650aAC                   eval      optrax = 'N'
650aAC                   else
650aAC                   eval      opdat1 = opdata
650aAC                   endif
416aA*
416aA*    Retrieve General Pick options for warehouse.
416aA*    This applies to only Regular orders.
416aA*
416cAC                   select
416cMC                   when      $ptype = ' '
416aAC                   eval      opwhse = oihwhs
416aAC                   eval      opcode = '*GENPICK'
416aAC     opkey         chain     options                            7978
416aAC                   if        *in79
416aAC                   eval      opmrga = 'N'
416aAC                   endif
416cA*
416cA*    Force Allow Merge orders to Yes for 'S' orders.
416cA*
416cMC                   when      $ptype = 'S'
416aAC                   eval      opmrga = 'Y'
416aA*
416aA*    All other order types, force Allow Merge orders to No
416aA*
416cMC                   other
416aAC                   eval      opmrga = 'N'
416cMC                   endsl
     *
     C                   eval      $pwhs = whcode
     C                   move      oihwhs        work3a
     C     ' 0'          check     work3a        pos
650cAC                   if        pos = 0
650cAC                   eval      pos = 1
650cAC                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
411 D*                    MOVE *OFF      WFLAG
411 AC                   eval      lstwhs = oihwhs
411 AC                   eval      pflag = *off
416 A*    Get exceptions report override if any.
416 AC                   exsr      opnprt
     C                   endif
     *
     *  Print report heading if necessary.
     *
416 AC                   eval      prhdr1 = *off
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     *  Add record to route header file when route changes.
416cA*     or when processing 'S' orders.
     *
     C                   if        oihrte <> lstrte
500bD*          $PTYPE    OREQ 'S'
416aAC                   eval      mrgrte = *off
640aDC*                  eval      newrte = *blanks
640aDC*                  eval      newrtc = *blanks
416aA*
416aA*  Merge order(s) into Open routes allowed.
416aA*  Check if Route still at Open status.
416aA*
416aAC                   if        opmrga = 'Y'  and
416aAC                             $ptype = ' '
416aAC                   exsr      zzckr1
416aAC                   exsr      zzckrt
416aAC                   endif
416aA*
640aAC                   eval      newrte = *blanks
640aAC                   eval      newrtc = *blanks
     C                   exsr      fillrh
     C                   write     rhrec                                49
     C                   eval      lstrte = oihrte
     C                   endif
     *
     *  Add record to order header file. If an error occurs, assume
     *    it was caused by a duplicate record.
     *
     C                   eval      hedmsg = *blanks
416aA*
416aA*    Route allows Add-on orders to be merged with existing Open orders.
416aA*    Check if order header still at Open status.
416aA*
416aAC                   eval      mrgord = *off
416aAC                   eval      wrgsts = *off
416aAC                   eval      opnord = *zeros
416aAC                   eval      opnorc = *zeros
416aAC                   if        mrgrte = *on
416aAC                   exsr      zzcko1
416aAC                   exsr      zzckor
416aAC                   endif
416aA*
     C                   exsr      filloh
510 A*
510 A*    Only update ORDHM if impfordhm was sent.
510 AC                   if        mischdrupd = '*YES'
510 AC                   exsr      fillhm
510 AC                   endif
510 A*
640 AC                   if        skpwrthdr = '0'
     C                   write     ohrec                                49

650aAC                   if        optrax = 'Y'
650aAC                   call      'OI128'
650aAC                   parm                    ohwhse
650aAC                   parm                    rhrte
650aAC                   parm                    ohrte
650aAC                   parm                    ohstop
650aAC                   parm                    ohcord
650aAC                   parm                    ohord
650aAC                   parm                    lincnt            2 0
650aAC                   endif

640 AC                   endif
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
510 A*
510 A*    Only add to ORDDM if impfordm was sent.
510 AC                   if        mischdrupd = '*YES'
510dAC                             and %found(impfordhm)
640 A*
640 AC                   if        skpwrthdrm = '0'
640 AC*
640 DC*                  write     hmrec
640 MC                   write (e) hmrec
510 AC                   if        %error
510 AC                   endif
640 AC                   endif
640 A*
510 AC                   endif
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
416 A*
416 A*    Exception occurred, print on report.
416 A*
416 AC                   select
416 AC                   when      hedmsg > *blanks
416 A*
416 A*    Print exception report page headings.
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   endif
416 AC                   write     head31
416 A*    Set on flag that customer heading printed already.
416 AC                   eval      prhdr1 = *on
416 A*
416 AC                   endsl
     *
     *    Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
416 AC                   eval      subq11 = *zeros
416 AC                   eval      subq21 = *zeros
416 AC                   eval      subq31 = *zeros
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
416 AC                   eval      excpr1 = *off
     C     oidkey        setll     impfordd
     C                   dou       eofd = *on
     *
     C     oidkey        reade     impfordd                               78
     C                   if        *in78
     C                   eval      eofd = *on
     C                   goto      enddod
     C                   endif
     C                   eval      detmsg = *blanks
     C                   eval      good1 = 'N'
416bAC                   eval      good2 = 'N'
416aAC                   eval      mrgitm = *off
416aAC                   eval      stsmsg = *blanks
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
     C                   if        good1 = 'Y'
416bAC                   exsr      zzxdck
416bAC                   if        good2 = 'Y'
     C                   exsr      fillod
640cA*
640cA*    Check for customer item notes on file.
640cAC                   exsr      zzgetcn
500eA*
500eA*    Only update ORDDM if impfordm was sent.
500eAC                   if        miscupdate = '*YES'
640cA*
640cAC                             or  miscupdate  = '*NO '
640cAC                             and addcustnote = '*YES'
640cA*
500eAC                   exsr      fillom
500eAC                   endif
416aA*
416aA*    Record was updated in FILLOD.
416aAC                   if        skpwrt = *off
     C                   write     odrec                                49
500eA*
500eA*    Only add to ORDDM if impfordm was sent.
500eAC                   if        miscupdate = '*YES'
640cA*
640cAC                             or  miscupdate  = '*NO '
640cAC                             and addcustnote = '*YES'
640cA*
640 AC                   if        skpwrtdtlm = '0'
500eAC                   write     omrec
500eAC                   if        %error
500eAC                   endif
640 AC                   endif
640cA*
640cAC                   else
640cA*
640cAC                   if        miscupdate = '*NO '
640cAC                             and addcustnote = '*YES'
640cAC                   endif
640cA*
500eAC                   endif
     C                   if        *in49
     C                   eval      detmsg = desc(1)
     C                   add       1             preod
     C                   endif
416aAC                   endif
     C                   exsr      updsum
416bAC                   endif
     C                   endif
     *
     C                   endif
     *
     *       Print order detail and update subtotals
     *
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
416aA*
416aA*       Print order detail item merge info line.
416aA*
416aAC                   if        mrgrte = *on  and
416aAC                             mrgitm = *on
416aAC                   exsr      zrhead
416aAC                   write     detail2
416aAC                   add       1             count
416aAC                   endif
416aA*
     C                   add       1             sublin
     C                   add       oidq1         subq1
     C                   add       oidq2         subq2
     C                   add       oidq3         subq3
     *
     *       Delete detail record from download file
     *
PAKaA*
PAKaAC                   if        client = packers
PAKaA*       Leave order detail records for extracting p/o's.
PAKaAC                   else
PAKaA*
     C                   delete    oidrec
PAKaAC                   endif
PAKaA*
416 A*
416 A*       Exception occurred, print on report.
416 AC                   select
416 AC                   when      detmsg > *blanks
416 A*
416 A*    Turn on flag to indicate at least one exception printed.
416 A*    Print grand totals when complete.
416 AC                   eval      excprt = *on
416 A*    Turn on flag to indicate at least one exception printed.
416 A*    Print sub totals when complete.
416 AC                   eval      excpr1 = *on
416 A*
416 AC                   add       oidq1         subq11
416 AC                   add       oidq2         subq21
416 AC                   add       oidq3         subq31
416 A*
416 A*    Print exception report page headings.
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   write     head31
416 AC                   write     head41
416 AC                   eval      prhdr1 = *on
416 AC                   endif
416 A*
416 A*    Print exception report Customer info and headings.
416 AC                   if        prhdr1 = *off
416 AC                   write     head31                               92
416 AC                   eval      prhdr1 = *on
416 AC                   endif
416 A*
416 A*    Print exception report page headings.
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   write     head31
416 AC                   write     head41
416 AC                   endif
416 A*
416 AC                   write     detail1                              92
416 AC                   add       1             grlin1
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
416 A*
416 AC                   endsl
     *
     C     enddod        tag
     C                   enddo
     *
     *    Print order subtotals and update grand totals
     **                   EXSR ZRHEAD
     C                   write     subttl
     C                   add       3             count
     C                   add       1             grdord
     C                   add       sublin        grdlin
416 A*
416 A*    Print Order exception subtotals.
416 AC                   if        excpr1 = *on
416 AC                   add       1             grord1
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   write     head21
416 AC                   write     head31
416 AC                   write     head41
416 AC                   endif
416 AC                   write     subttl1                              92
416 AC                   endif
     *
     *  Delete header record from download file
     *
PAKaA*
PAKaAC                   if        client = packers
PAKaA*       Leave order header records for extracting p/o's.
PAKaAC                   else
PAKaA*
     C                   delete    oihrec
PAKaAC                   endif
PAKaA*
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
416aA*
416aA*    Remove NEW Order Header if no items attached.
416aAC                   if        mrgord = *on
416aAC                   exsr      zzcko1
416aAC                   endif
416aA*
416aA*    Remove NEW Route Header if no orders attached.
416aAC                   if        mrgrte = *on
416aAC                   exsr      zzckr1
416aAC                   endif
416 A*
416 A*    Print exception grand totals.
416 AC                   if        excprt = *on
416 AC                   if        *in92
416 AC                   write     head11                               92
416 AC                   endif
416 AC                   write     grndttl1
416 AC                   endif
416 A*
PAKaA*
PAKaAC                   if        client = packers
PAKaA*
PAKaA*    Check if any orders need to be imported as purchase orders.
PAKaAC                   eval      $pimppo = import_po
PAKaA*
PAKaAC                   endif
PAKaA*
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
416aA*
416aA*  *INZSR  Initialization subroutine
416aA*
416aAC     *inzsr        begsr
500dA*
500dA* Get client id.
500dA*
500dAC                   call      @getcl
500dAC                   parm                    client           10
500dAC                   parm                    cliloc           10
510 A*
510 A* Open IMPFORDHM file.
510 AC                   if        opnimpordhm <> *on
510 AC                   open      impfordhm                            67
510 AC                   if        *in67 = *off
510 AC                   eval      opnimpordhm = *on
510 AC                   eval      mischdrupd = '*YES'
510 AC                   else
510 AC                   eval      mischdrupd = '*NO '
510 AC                   endif
510 AC                   endif
510 A*
510 A* Open ORDHM file if import file was sent.
510 AC                   if            opnordhm <> *on
510 AC                             and mischdrupd ='*YES'
510 AC                   open      ordhm                                67
510 AC                   if        *in67 = *off
510 AC                   eval      opnordhm   = *on
510 AC                   eval      mischdrupd = '*YES'
510 AC                   else
510 AC                   eval      mischdrupd = '*NO '
510 AC                   endif
510 AC                   endif
500eA*
500eA* Open IMPFORDM file.
500eAC                   if        opnimpordm <> *on
500eAC                   open      impfordm                             68
500eAC                   if        *in68 = *off
500eAC                   eval      opnimpordm = *on
500eAC                   eval      miscupdate = '*YES'
500eAC                   else
500eAC                   eval      miscupdate = '*NO '
500eAC                   endif
500eAC                   endif
500eA*
500eM* Open ORDDM file if import file was sent.
640cDC*                  if            opnordm <> *on
640cDC*                            and miscupdate ='*YES'
640cDC*                  open      orddm                                68
640cDC*                  if        *in68 = *off
640cDC*                  eval      opnordm    = *on
640cDC*                  eval      miscupdate = '*YES'
640cDC*                  else
640cDC*                  eval      miscupdate = '*NO '
640cDC*                  endif
640cDC*                  endif
PAK A*
PAK A* Open ORDDM file if import file was sent.
PAK AC                   if        client = packers
PAK AC                   if        not %open(custmisc)
PAK AC                   open      custmisc
PAK AC                   endif
PAK AC                   endif
520bA*
520bA* CROSSDK  Cross Dock - Full key
520bAC     cdkey         klist
520bAC                   kfld                    slwhse
520bAC                   kfld                    slwhdp
520bAC                   kfld                    sldisp
416bA*
416bA* IMPFORDH Download order header file - Partial key
416bAC     oihkey        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    $ptype
510 A*
510 A* IMPFORDHM  Download order header misc - full key
510 aC     oihmkey       klist
510 AC                   kfld                    oihwhs
510 AC                   kfld                    oihord
500eA*
500eA* IMPFORDM  Download order detail misc - full key
500eaC     oimkey        klist
500eAC                   kfld                    oidwhs
500eAC                   kfld                    oidord
500eAC                   kfld                    oidseq
500eAC                   kfld                    oiditm
PAK A*
PAK A* CUSTMISC   BFC Dakota Customer Master - Misc. - Full Key
PAK AC     csmkey        klist
PAK AC                   kfld                    oihwhs
PAK AC                   kfld                    oihcus
416aA*
416aA* ORDH Order header file - Partial key
416aA*
416aAC     ohkey         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
640 A*
640 A* ORDH Order header file - Full key
640 A*
640 AC     opnohkey      klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    opnord
416aA*
416aA* ORDH4 Order header file - Full key  (NEW Route)
416aA*
416aAC     oh3key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    newrte
416aA*
416aA* ORDH4 Order header file - Full key  (Open Route)
416aA*
416aAC     oh5key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    opnrte
416aAC                   kfld                    oihord
510 A*
510 A* ORDHM Order header misc. file - Full key
510 A*
510 AC     *like         define    hmord         kyord
510 AC     hmkey         klist
510 AC                   kfld                    $pwhse
510 AC                   kfld                    kyord
416aA*
416aA* ORDD Order detail file - Partial key
416aA*
416aAC     odkey         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
416aA*
416aA* ORDD1 Order detail file - Full key
416aA*
416aAC                   eval      kystat = 'O'
416aAC     od1key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    opnord
416aAC                   kfld                    kystat
416aAC                   kfld                    oidseq
416aAC                   kfld                    oiditm
416aAC     od2key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
500eA*
500eA* ORDDM  Order detail misc. file - Full key
500eA*
500eAC     omkey         klist
500eAC                   kfld                    odwhse
500eAC                   kfld                    odord
500eAC                   kfld                    odseq
500eAC                   kfld                    oditem
416aA*
416aA* OPTIONS Options file - Full key
416aA*
416aAC     opkey         klist
416aAC                   kfld                    opwhse
416aAC                   kfld                    opcode
416bA*
416bA* PODTL1 PO DETAIL file
416bA*
416bAC     keypd1        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    oidpo
416bAC                   kfld                    oiditm
416aA*
416aA* RTEHED1 - Route header file - Partial key
416aA*
416aAC     rh1key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    oihrte
416aA*
416aA* RTEHED1 - Route header file - Full key
416aAC     rh2key        klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    newrtc
416aAC                   kfld                    newrte
417aA*
417aA* RTEHED1 - Route header file - Full key
417aAC     rh3key        klist
417aAC                   kfld                    $pwhse
417aAC                   kfld                    lstrte
417aAC                   kfld                    lstrid
640 A*
640 A* RTEHED2 - Route header file - Partial key
640 A*
640 AC     rh2akey       klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    kyrhstat
640 AC                   kfld                    $ptype
640 AC                   kfld                    oihrte
416bA*
416bA* SLOT1 file
416bAC     keysl1        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    itwhdp
416bAC                   kfld                    kyaisl
416bA*
416bA* SLOT4 file
416bAC     keysl4        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    itwhdp
416bAC                   kfld                    oiditm
416bAC                   kfld                    kydisp
520aA*
520aA* SLOT11 file
520aAC     keysl11       klist
520aAC                   kfld                    $pwhse
520aAC                   kfld                    kyaisl
416aA*
416aA*  Variables and constants.
416aA*
416aAC                   eval      forevr = *off
416aAC                   eval      mrgrte = *off
416aAC                   eval      mrgord = *off
416aAC                   eval      mrgitm = *off
416aAC                   eval      wrgsts = *off
416aAC                   eval      rcdlck = *off
416aAC                   eval      skpwrt = *off
416aA*
416bA*  Convert today's date into century format.
416bA*
416bAC                   eval      $cvcmd = '*CURCMD '
416bAC                   call      @cvtdt
416bAC                   parm                    $cvtdt
416bAC                   eval      today = $cvd8o
416bA*
416aAC                   endsr
416aA*----------------------------------------------------------------
     *
     *  FILLOD  Fill order detail fields.
     *
     C     fillod        begsr
416aAC                   eval      skpwrt = *off
416aA*
416aA*    Route & order at Open status. Check if item already on order.
416aA*    If yes, then compute difference between import qty's and order
416aA*    qty's. Then update order with import qty.
416aAC                   select
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *on  and
416aAC                             wrgsts = *off
416aA*
416aAC                   eval      rcdlck = *on
416aAC                   exsr      zzgtod
416aAC                   eval      rcdlck = *off
416aA*
416aAC                   select
416aAC                   when      not *in75  and
416aAC                             oiditm = oditem
416aA*
416aA*    Calculate change in quantity to update RTESUM file.
416aAC                   eval      difqy1 = oidq1 - odqor1
416aAC                   eval      difqy2 = oidq2 - oidq2
416aAC                   eval      difqy3 = oidq3 - oidq3
416aA*
416aAC                   eval      odqor1 = oidq1
416aAC                   if        itflg1 = 'Y'
416aAC                   eval      odqor2 = oidq2
416aAC                   endif
416aAC                   if        itflg2 = 'Y'
416aAC                   eval      odqor3 = oidq3
416aAC                   endif
416aAC                   update    odrec1
416aA*    Load print field for report.
416aAC                   move      odord         prtord
416aAC                   move      sts03         stsmsg
416aAC                   eval      mrgitm = *on
416aAC                   eval      skpwrt = *on
416aAC                   goto      endlod
416aAC                   endsl
416aA*
416aAC                   endsl
     *
     *  Initialize record
     *
     C                   clear                   odrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      odwhse = oidwhs
416aA*
416aA*    Open route found, Open order not found or at wrong status.
416aA*    Create order under current Open route.
416aAC                   select
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *off  or
416aA*
416aAC                             mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *on
416aAC                   eval      odord = neword
416aAC                   move      sts02         stsmsg
416aA*
416aA*    Open route found, Open order found.
416aA*    Add item to current Open order.
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *on  and
416aAC                             wrgsts = *off
416aAC                   eval      odord = opnord
416aAC                   move      sts01         stsmsg
416aA*
416aAC                   other
     C                   eval      odord = ohord
416aAC                   endsl
416aA*    Load print field for report.
416aAC                   move      odord         prtord
416aA*
     C                   eval      odseq = oidseq
     C                   eval      oditem = oiditm
     C                   eval      odqor1 = oidq1
416aAC                   eval      difqy1 = oidq1
     C                   if        itflg1 = 'Y'
     C                   eval      odqor2 = oidq2
416aAC                   eval      difqy2 = oidq2
     C                   else
     C                   eval      odqor2 = 0
416aAC                   eval      difqy2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      odqor3 = oidq3
416aAC                   eval      difqy3 = oidq3
     C                   else
     C                   eval      odqor3 = 0
416aAC                   eval      difqy3 = 0
     C                   endif
     C                   eval      odwh2 = oidwh2
     C                   eval      odor2 = oidor2
     C                   eval      odoitm = oidoit
     C                   eval      odspcl = oidspc
     C                   eval      odstat = 'O'
416aAC                   eval      mrgitm = *on
416aA*
416aAC     endlod        tag
     *
     C                   endsr
500eA*----------------------------------------------------------------
500eA*
500eA*  FILLOM  Fill order detail misc file fields.
500eA*
500eAC     filloM        begsr
640 AC                   eval      skpwrtdtlm = *off
640cA*
640cAC     miscupdate    cabeq     '*NO '        #filom1
500eA*
500eAC     oimkey        chain     impfordm
500eAC                   if        not %found(impfordm)
500fDC*                  clear                   oimrec
640 AC                   eval      oimwhs = 0
640 AC                   eval      oimord = 0
500fAC                   eval      oimdsc = ' '
500fAC                   eval      oimpds = 'N'
500fAC                   eval      oimrds = 'N'
500fAC                   eval      oimbox = 'N'
500fAC                   eval      oimexp = 'N'
500fAC                   eval      oimms1 = ' '
500fAC                   eval      oimms2 = ' '
500fAC                   eval      oimms3 = ' '
500fAC                   eval      oimms4 = ' '
500fAC                   eval      oimms5 = ' '
VIP A*
VIP AC                   select
VIP AC                   when      client = VIP
MJK AC                             or client = MJKellner
VIP AC                   eval      vipdm1_omwhdp = ' '
VIP AC                   eval      vipdm1_ompckm = 0
VIP AC                   eval      vipdm1_omwtiw = 0
VIP AC                   eval      vipdm1_omcbec = 0
VIP AC                   endsl
640 AC                   eval      skpwrtdtlm = *on
640 AC                   goto      endlodm
VIP A*
VIP AC                   else
VIP A*
VIP AC                   select
VIP A*    Move Misc 1 field into Client Specific Misc fld.
VIP AC                   when      client = VIP
MJK AC                             or client = MJKellner
VIP AC                   eval      vipdm1_base = oimms1
VIP AC                   endsl
VIP A*
500eAC                   endif
640cA*
640cAC     #filom1       tag
640cA*      Clear import file fields since they were not sent.
640cAC                   if        miscupdate = '*NO '
640cAC                   eval      oimwhs = 0
640cAC                   eval      oimord = 0
640cAC                   eval      oimdsc = ' '
640cAC                   eval      oimpds = 'N'
640cAC                   eval      oimrds = 'N'
640cAC                   eval      oimbox = 'N'
640cAC                   eval      oimexp = 'N'
640cAC                   eval      oimms1 = ' '
640cAC                   eval      oimms2 = ' '
640cAC                   eval      oimms3 = ' '
640cAC                   eval      oimms4 = ' '
640cAC                   eval      oimms5 = ' '
640cAC                   endif
500eA*
500eA*    Route & order at Open status. Check if item already on order.
500eA*    If yes, then compute difference between import qty's and order
500eA*    qty's. Then update order with import qty.
500eAC                   select
500eAC                   when      mrgrte = *on  and
500eAC                             mrgord = *on  and
500eAC                             wrgsts = *off
500eA*
500eAC                   eval      rcdlck = *on
500eAC                   exsr      zzgtom
500eAC                   eval      rcdlck = *off
500eA*
500eAC                   select
500eAC                   when      %found(orddm) and
500eAC                             oiditm = oditem
500eA*
PAKbAC                   select
PAKbAC                   when      client = packers
PAKbAC                   eval      omodsc = ' '
PAKbAC                   other
PAKbA*
500eAC                   eval      omodsc = oimdsc
PAKbAC                   endsl
PAKbA*
500eAC                   eval      ompdsc = oimpds
500eAC                   eval      omrdsc = oimrds
500eAC                   eval      omcbox = oimbox
500eAC                   eval      omcexp = oimexp
PAKbA*
PAKbAC                   select
PAKbAC                   when      client = packers
PAKbAC                   eval      ommsc1 = oimdsc
PAKbAC                   other
PAKbA*
500eAC                   eval      ommsc1 = oimms1
PAKbAC                   endsl
PAKbA*
500eAC                   eval      ommsc2 = oimms2
500eAC                   eval      ommsc3 = oimms3
500eAC                   eval      ommsc4 = oimms4
640cA*
640cAC                   if        addcustnote = '*YES'
640cAC                   eval      ommsc5 = cnnote
640cAC                   else
640cA*
500eAC                   eval      ommsc5 = oimms5
640cAC                   endif
640cA*
500eAC                   update    omrec
640 AC                   eval      skpwrtdtlm = '1'
500eA*
500eAC                   goto      endlodm
500eAC                   endsl
500eA*
500eAC                   endsl
500eA*
500eA*  Initialize record
500eA*
500eAC                   clear                   omrec
500eA*
500eA*  Move fields from download file to order detail misc file fields.
500eA*
500eAC                   eval      omwhse = oidwhs
500eA*
500eA*    Open route found, Open order not found or at wrong status.
500eA*    Create order under current Open route.
500eAC                   select
500eAC                   when      mrgrte = *on  and
500eAC                             mrgord = *off  and
500eAC                             wrgsts = *off  or
500eA*
500eAC                             mrgrte = *on  and
500eAC                             mrgord = *off  and
500eAC                             wrgsts = *on
500eAC                   eval      omord = neword
500eA*
500eA*    Open route found, Open order found.
500eA*    Add item to current Open order.
500eAC                   when      mrgrte = *on  and
500eAC                             mrgord = *on  and
500eAC                             wrgsts = *off
500eAC                   eval      omord = opnord
500eA*
500eAC                   other
500eAC                   eval      omord = ohord
500eAC                   endsl
500eA*
500eAC                   eval      omseq  = oidseq
500eAC                   eval      omitem = oiditm
500eAC                   eval      omodsc = oimdsc
500eAC                   eval      ompdsc = oimpds
500eAC                   eval      omrdsc = oimrds
500eAC                   eval      omcbox = oimbox
500eAC                   eval      omcexp = oimexp
500eAC                   eval      ommsc1 = oimms1
500eAC                   eval      ommsc2 = oimms2
500eAC                   eval      ommsc3 = oimms3
500eAC                   eval      ommsc4 = oimms4
640cA*
640cAC                   if        addcustnote = '*YES'
640cAC                   eval      ommsc5 = cnnote
640cAC                   else
640cA*
500eAC                   eval      ommsc5 = oimms5
640cAC                   endif
640cA*
500eA*
500eAC     endlodm       tag
500eA*
500eAC                   endsr
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
640 AC                   eval      ohstop = oihstp
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
416aAC                   eval      neword = ohord
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
416aA*
416aA*    Open route found, Open order NOT found.
416aA*    Add Order to current Open Route.
416aAC                   select
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *off
416aAC                   eval      ohrte = opnrte
416aA*
416aAC                   other
     C                   eval      ohrte = rhrtid
416aAC                   endsl
416aA*    Load print field for report.
416aAC                   eval      prtrte = ohrte
     C                   eval      ohstop = oihstp
     **                   MOVE OIHTRK    OHTRUK
     C                   eval      ohtruk = $ptruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
640 A*
640 AC     endlodh       tag
     *
     C                   endsr
510 A*----------------------------------------------------------------
510 A*
510 A*  FILLHM  Fill order header misc file fields.
510 A*
510 AC     fillHM        begsr
640 AC                   eval      skpwrthdrm = '0'
510 A*
510 AC     oihmkey       chain     impfordhm
510 AC                   if        not %found(impfordhm)
510 AC                   eval      ohmms1 = ' '
510 AC                   eval      ohmms2 = ' '
510 AC                   eval      ohmms3 = ' '
510 AC                   eval      ohmms4 = ' '
510 AC                   eval      ohmms5 = ' '
510 AC                   endif
510 A*
PAKaAC                   if        client = packers
PAKaA*
PAKaA*      This order needs to be imported as a purchase order.
PAKaAC                   if        %subst(ohmms1:23:4) = 'ZPLF'
PAKcAC                             and (oihwhs = 200 or oihwhs = 300 or
PAKcAC                                  oihwhs = 310)
PAKaAC                   eval      import_po = '*YES'
PAKaAC                   endif
PAKaA*
PAKaAC                   endif
PAKaA*
510 AC                   select
510 A*    Open route found, Open order found.
510 A*    Retrieve Open Order Header Misc. file
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *on  and
510 AC                             wrgsts = *off
510 AC                   eval      kyord = opnord
510 A*
510 AC                   other
510 AC                   eval      kyord = neword
510 AC                   endsl
510 A*
510 AC                   eval      rcdlck = *on
510 AC                   exsr      zzgethm
510 AC                   eval      rcdlck = *off
510 A*
510 AC                   select
510 AC                   when      %found(ordhm)
510 A*
510 AC                   select
510 A*    Open route found, Open order found.
510 A*    Leave route ID untouched.
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *on  and
510 AC                             wrgsts = *off
510 A*
510 A*    Open route found, Open order NOT found.
510 A*    Add Order to current Open Route.
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *off  and
510 AC                             wrgsts = *off
510 AC                   eval      hmrtid = opnrte
510 AC                   other
510 AC                   eval      hmrtid = rhrtid
510 AC                   endsl
510 A*
510 AC                   eval      hmmsc1 = ohmms1
510 AC                   eval      hmmsc2 = ohmms2
510 AC                   eval      hmmsc3 = ohmms3
510 AC                   eval      hmmsc4 = ohmms4
510 AC                   eval      hmmsc5 = ohmms5
510 AC                   update    hmrec
640 AC                   eval      skpwrthdrm = '1'
510 A*
510 AC                   goto      endlodhm
510 A*
510 AC                   endsl
510 A*
510 A*  Initialize record
510 A*
510 AC                   clear                   hmrec
510 A*
510 A*  Move fields from download file to order detail misc file fields.
510 A*
510 AC                   eval      hmwhse = oihwhs
510 AC                   eval      hmord = neword
510 AC                   select
510 A*
510 A*    Open route found, Open order NOT found.
510 A*    Add Order to current Open Route.
510 AC                   when      mrgrte = *on  and
510 AC                             mrgord = *off  and
510 AC                             wrgsts = *off
510 AC                   eval      hmrtid = newrte
510 A*
510 AC                   other
510 AC                   eval      hmrtid = rhrtid
510 AC                   endsl
510 A*
510 AC                   eval      hmmsc1 = ohmms1
510 AC                   eval      hmmsc2 = ohmms2
510 AC                   eval      hmmsc3 = ohmms3
510 AC                   eval      hmmsc4 = ohmms4
510 AC                   eval      hmmsc5 = ohmms5
510 A*
510 AC     endlodhm      tag
510 A*
510 AC                   endsr
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
417aAC                   eval      lstrid = rhrtid
416dD**                   MOVE RHRTID    $PRTID
416dAC                   add       1             rtcnt
416dAC                   select
416dAC                   when      rtcnt = 1
416dAC                   eval      $prt01 = rhrtid
416dAC                   when      rtcnt = 2
416dAC                   eval      $prt02 = rhrtid
416dAC                   when      rtcnt = 3
416dAC                   eval      $prt03 = rhrtid
416dAC                   when      rtcnt = 4
416dAC                   eval      $prt04 = rhrtid
416dAC                   when      rtcnt = 5
416dAC                   eval      $prt05 = rhrtid
416dAC                   when      rtcnt = 6
416dAC                   eval      $prt06 = rhrtid
416dAC                   when      rtcnt = 7
416dAC                   eval      $prt07 = rhrtid
416dAC                   when      rtcnt = 8
416dAC                   eval      $prt08 = rhrtid
416dAC                   when      rtcnt = 9
416dAC                   eval      $prt09 = rhrtid
416dAC                   when      rtcnt = 10
416dAC                   eval      $prt10 = rhrtid
416dAC                   endsl
416aAC                   eval      newrte = rhrtid
414 AC                   if        $ptype = 'W'  and
417 D*R         RHRTE     ANDEQ*BLANKS
417 MC                             oihrte = *blanks
414 AC                   eval      rhrte = rhrtid
414 AC                   else
     C                   eval      rhrte = oihrte
414 AC                   endif
416aAC                   eval      newrtc = oihrte
     C                   eval      rhtype = oihtyp
414 AC                   if        $ptype = 'W'  and
416eMC                             oihtrk = *blanks
416eD**         RHTRUK    ANDEQ*BLANKS
414 AC                   eval      rhtruk = *blanks
414 AC                   movel     'WILLCALL'    rhtruk
414 AC                   else
     C                   eval      rhtruk = oihtrk
414 AC                   endif
CLDaAC                   if        client = CityLine
CLDaAC                             and rhtruk <> 'WILLCALL'
CLDaAC                   eval      rhtruk = *blanks
CLDaAC                   endif
414 D**                   MOVE OIHTRK    $PTRUK
414 MC                   eval      $ptruk = rhtruk
     C                   eval      rhstat = *on
     C                   eval      rhstsd = impdte
     C                   eval      rhstst = imptim
     C                   eval      rhimpd = impdte
     C                   eval      rhimpt = imptim
     C                   eval      rhrptd = impdte
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
416 A*----------------------------------------------------------------
416 A*
416 A*  OPNPRT  Open printer file.
416 A*
416 AC     opnprt        begsr
416 A*
416 A*   Get device and form type for department.
416 A*
416 AC                   call      'GETRPT'
416 AC                   parm      '*DEVFORM'    $cmd              8
416 AC                   parm      'OI2551PR'    $lrpt            10
416 AC                   parm      lstwhs        $whse             3 0
416 AC                   parm      *blanks       $styp             1
416 AC                   parm      *blanks       $whdp             5
416 AC                   parm                    $desc            50
416 AC                   parm                    $dev             10
416 AC                   parm                    $form            10
416 AC                   if        $dev = *blanks
416 AC                   movel     '*JOB'        $dev
416 AC                   endif
416 AC                   if        $form = *blanks
416 AC                   movel     '*STD'        $form
416 AC                   endif
416 A*
416 A*   Open printer file for department.
416 A*
416 AC                   if        opened <> *on
416 A*
416 A*      If printer already open then close it.
416 A*
416 AC                   if        opened = *on
416 AC                   close     oi2551pr
500cAC                   close     oi255pr
416 AC                   endif
416 A*
416 A*      Override printer file.
416 A*
416 A*          OVRPRTF FILE(OI2551PR) OUTQ(*DEV) DEV($dev)
416 A*                  FORMTYPE($form)
416 A*        NOTE: Ending array positions for $DEV 39, $FORM 60 are one
416 A*              greater than standard code. This is due to the
416 A*              extra character in the printer file name.
416 A*
416 AC                   movea     ovrprt(1)     a80
416 AC                   movea     $dev          a80(39)
416 AC                   movea     $form         a80(60)
416 AC                   movea     a80           qcmd
416 A*
416 AC                   call      'QCMDEXC'
416 AC                   parm                    qcmd             80
416 AC                   parm      80            qlen             15 5
500cA*
500cA*   Get device and form type for main report.
500cA*
500cAC                   call      'GETRPT'
500cAC                   parm      '*DEVFORM'    $cmd
500cAC                   parm      'OI255PR '    $lrpt
500cAC                   parm      lstwhs        $whse
500cAC                   parm      *blanks       $styp
500cAC                   parm      *blanks       $whdp
500cAC                   parm                    $desc
500cAC                   parm                    $dev
500cAC                   parm                    $form
500cAC                   if        $dev = *blanks
500cAC                   movel     '*JOB'        $dev
500cAC                   endif
500cAC                   if        $form = *blanks
500cAC                   movel     '*STD'        $form
500cAC                   endif
500cA*
500cA*      Override printer file.
500cA*
500cA*          OVRPRTF FILE(OI255PR) OUTQ(*DEV) DEV($dev)
500cA*                  FORMTYPE($form)
500cA*
500cAC                   movea     ovrprt(2)     a80
500cAC                   movea     $dev          a80(38)
500cAC                   movea     $form         a80(59)
500cAC                   movea     a80           qcmd
500cA*
500cAC                   call      'QCMDEXC'
500cAC                   parm                    qcmd
500cAC                   parm      80            qlen
416 A*
416 A*      Open printer file.
416 A*
416 AC                   open      oi2551pr
500cAC                   open      oi255pr
416 AC                   eval      opened = *on
416 A*
416 AC                   endif
416 A*
416 AC                   endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  UPDRTE   Update route with automatically assigned truck.
417aA*
417aAC     updrte        begsr
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
ADW AC                   if        client = Andrews
JOR AC                             or client = Jordanos
ADW A*      No truck template assigned if default not found.
ADW AC                   eval      $xcmd = '*DFTNOAU'
ADW AC                   else
ADW AC                   eval      $xcmd = '*DFLT   '
ADW AC                   endif
ADW A*
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
ADW DC*                  parm      '*DFLT  '     $xcmd             8
ADW MC                   parm                    $xcmd             8
     C                   if        $xrtn = '*OK'
CTWaAC                   if        client = citywholesale
CTWaAC                   eval      rhtruk = *blanks
CTWaAC                   endif
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
416aAC                   select
416aA*    Update route summary for Open route when Open Order
416aA*    found and at correct status.
416aAC                   when      mrgrte = *on  and
416aAC                             mrgord = *on  and
416aAC                             wrgsts = *off  and
416aAC                             mrgitm = *on  or
416aA*
416aA*    Update route summary for Open route when Open Order
416aA*    NOT found and at correct status.
416aAC                             mrgrte = *on  and
416aAC                             mrgord = *off  and
416aAC                             wrgsts = *off  and
416aAC                             mrgitm = *on
416aAC                   eval      kyrtid = opnrte
416aA*
416aAC                   other
416aAC                   eval      kyrtid = newrte
416aAC                   endsl
500dA*
500dA*     Determine department to use.
500dA*
500dAC                   select
CBIaAC                   when      client = cheney
CBIaAC                   if        ititem >= '405000'  and
CBIaAC                             ititem <= '492999'
CBIaAC                   eval      kywhdp = 'PRD  '
CBIaAC                   else
CBIaAC                   eval      kywhdp = itwhdp
CBIaAC                   endif
VIP A*
VIP AC                   when      client = VIP
MJK AC                             or client = MJKellner
VIP AC                   if        ititem = '9999999999'
VIP AC                             and vipdm1_omwhdp > ' '
VIP AC                   eval      kywhdp = vipdm1_omwhdp
VIP AC                   else
VIP AC                   eval      kywhdp = itwhdp
VIP AC                   endif
VIP A*
500dAC                   other
500dAC                   eval      kywhdp = itwhdp
500dAC                   endsl
416aA*
     C     keyrs         chain     rtesum                             77
     *
     *     Record does not exist - Initialize fields.
     *
     C                   if        *in77
     C                   eval      rswhse = rhwhse
416aD*R                   MOVE RHRTID    RSRTID
416aMC                   eval      rsrtid = kyrtid
500dD**                   MOVE ITWHDP    RSWHDP
500dMC                   eval      rswhdp = kywhdp
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
500aA*     Get base item for alias item.
500aAC                   eval      #bityp = *blanks
500aAC                   if        ittype = 'A'
500aAC                   call      'GETBASE'
500aAC                   parm      itwhse        $gwhse            3 0
500aAC                   parm      ititem        $gitem           15
500aAC                   parm      ' '           #bitem           15
500aAC                   parm                    #bityp            1
500aAC                   parm                    #bdesc           30
500aAC                   parm                    #bpdsc           15
500aAC                   parm                    #bwhdp            5
500aAC                   parm                    #bstyp            1
500aAC                   parm                    #bum1             2
500aAC                   parm                    #bum2             2
500aAC                   parm                    #bumq2            3 0
500aAC                   parm                    #bum3             2
500aAC                   parm                    #bumq3            3 0
500aAC                   parm      ' '           #bcitm           15
500aAC                   parm                    #bctyp            1
500aAC                   parm                    #bcdsc           30
500aAC                   parm                    #bcpds           15
500aAC                   parm                    #bcwdp            5
500aAC                   parm                    #bcstp            1
500aAC                   parm                    #bcum1            2
500aAC                   parm                    #bcum2            2
500aAC                   parm                    #bcuq2            3 0
500aAC                   parm                    #bcum3            2
500aAC                   parm                    #bcuq3            3 0
500aAC                   parm                    #brtn             8
500aAC                   endif
500aA*
416aD*R                   ADD  ODQOR1    RSORDP
416aMC                   add       difqy1        rsordp
416aD*R         ITCUBE    MULT ODQOR1    TMPCUB
500aAC                   if        #bityp = 'S'  or
500aAC                             ittype = 'S'
500aAC                   if        itumq2 <= 0
500aAC                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
500aAC                   else
500aAC     itcube        div(h)    itumq2        tmpcub
530bAC     itswgt        div(h)    itumq2        tmpwgt
500aAC                   eval      tmpcub = tmpcub * difqy1
530bAC                   eval      tmpwgt = tmpwgt * difqy1
500aAC                   endif
VIP A*
500aAC                   else
VIP A*      All other item types.
VIP A*
VIP AC                   if        client = VIP
VIP AC                             and ititem = '9999999999'
VIP AC                             and vipdm1_omcbec > 0
MJK AC                             or client = MJKellner
MJK AC                             and ititem = '9999999999'
MJK AC                             and vipdm1_omcbec > 0
VIP MC                   eval      tmpcub = vipdm1_omcbec * difqy1
VIP AC                   else
VIP A*
416aMC                   eval      tmpcub = itcube * difqy1
530bAC                   eval      tmpwgt = itswgt * difqy1
VIP AC                   endif
VIP A*
500aAC                   endif
500aA*
     C                   add       tmpcub        rsordc
416aD*R         ITSWGT    MULT ODQOR1    TMPWGT
VIP A*
VIP AC                   if        client = VIP
VIP AC                             and ititem = '9999999999'
VIP AC                             and vipdm1_omwtiw > 0
MJK AC                             or client = MJKellner
MJK AC                             and ititem = '9999999999'
MJK AC                             and vipdm1_omwtiw > 0
VIP MC                   eval      tmpcub = vipdm1_omwtiw * difqy1
VIP AC                   else
VIP A*
530bDC*                  eval      tmpwgt = itswgt * difqy1
VIP AC                   endif
VIP A*
     C                   add       tmpwgt        rsordw
     *
416aD*R                   ADD  ODQOR2    RSORDP
416aMC                   add       difqy2        rsordp
416aD*R         ODQOR2    IFNE 0
416aMC                   if        difqy2 <> 0  and
     C                             itumq2 > 0
     C     itcube        div(h)    itumq2        tmpcub
416aD*R         TMPCUB    MULT ODQOR2    TMPCUB
416aMC                   eval      tmpcub = tmpcub * difqy2
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq2        tmpwgt
416aD*R         TMPWGT    MULT ODQOR2    TMPWGT
416aMC                   eval      tmpwgt = tmpwgt * difqy2
     C                   add       tmpwgt        rsordw
     C                   endif
     *
416aD*R                   ADD  ODQOR3    RSORDP
416aMC                   add       difqy3        rsordp
416aD*R         ODQOR3    IFNE 0
416aMC                   if        difqy3 <> 0  and
     C                             itumq3 > 0
     C     itcube        div(h)    itumq3        tmpcub
416aD*R         TMPCUB    MULT ODQOR3    TMPCUB
416aMC                   eval      tmpcub = tmpcub * difqy3
     C                   add       tmpcub        rsordc
     C     itswgt        div(h)    itumq3        tmpwgt
416aD*R         TMPWGT    MULT ODQOR3    TMPWGT
416aMC                   eval      tmpwgt = tmpwgt * difqy3
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
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCKRT  Check if route still at Open Status.
416aA*
416aAC     zzckrt        begsr
416aA*
416aA*    Position past last route, then read backward to get last route.
416aA*    If Regular route and status is Open, then allow orders to be
416aA*    merged to existing route.
416aA*
416aA*    NOTE: If we find the route that is being merged in,
416aA*          and the route is at Open status, we will leave the
416aA*          route header record locked till the merge is com-
416aA*          plete or we process a new route.  Leaving the record
416aA*          locked will prevent anyone from Allocating the route
416aA*          while we are importing new orders.
416aA*
640 DC*    rh1key        setgt     rtehed1
640 MC     rh2akey       setgt     rtehed2
640 DC*    rh1key        readpe    rtehed1                                73
640 MC     rh2akey       readpe    rtehed2                                72
416aAC                   select
640 DC*                  when      not *in73  and
640 MC                   when      not *in72  and
416aAC                             rhtype = ' '  and
416aAC                             rhstat = '1'
416aAC                   eval      mrgrte = *on
416aAC                   eval      opnrte = rhrtid
416aAC                   eval      opnrtc = rhrte
416aA*
416aAC                   other
416aAC                   eval      mrgrte = *off
640 DC*                  unlock    rtehed1
416aA*
416aAC                   endsl
416aA*
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCKR1  Check if NEW route has any orders attached.
416aA*
416aAC     zzckr1        begsr
416aA*
416aA*    Check to see if any orders attached to NEW Route Header.
416aA*    If none found, then Delete NEW Route Header record.
416aAC     oh3key        setll     ordh4                                  77
416aAC                   if        not *in77
416aAC     rh2key        chain     rtehed1                            73
416aAC                   if        not *in73
416aAC                   delete    rhrec1
416aAC                   endif
416aAC                   endif
416aA*
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCKOR  Check if order header still at Open status.
416aA*
416aAC     zzckor        begsr
416aA*
416aAC     oh5key        setll     ordh4
416aAC                   dow       forevr = forevr
416aAC     oh5key        reade     ordh4                                  77
416aAC                   select
416aAC                   when      *in77
416aA*
416aAC                   leave
416aA*
416aA*    In order to merge an order being imported, the following have
416aA*    to match: Must be the same type, existing order must be open,
416aA*    same customer and for GFG ONLY: Memo codes must match.
416aAC                   when      not *in77  and
416aAC                             oihtyp = ' '  and
416aAC                             ohtype = ' '  and
MJKaMC                             ohstat = 'O'
MJKaDC*                            ohstat = 'O'  and
416aA*    Next line is for GFG ONLY: Memo codes must match.
MJKaA*
MJKaAC                             or client = MJKellner
MJKaAC                             and not *in77  and
MJKaAC                             oihtyp = ' '  and
MJKaAC                             ohtype = ' '  and
MJKaAC                             ohstat = 'O' and
MJKaAC                             ihcmpn = ohcmpn and
MJKaAC                             ihdivn = ohdivn and
MJKaAC                             ihdptn = ohdptn and
MJKaAC                             ihwhsn = ohwhsn and
416aAC                             oihmec = ohmemc
MJKaA*
416aAC                   eval      mrgord = *on
416aAC                   eval      opnord = ohord
416aAC                   eval      opnorc = ohcord
416aAC                   leave
416aA*
416aAC                   other
416aAC                   eval      wrgsts = *on
416aAC                   leave
416aA*
416aAC                   endsl
416aAC                   enddo
416aA*
416aAC                   endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCKO1  Check if NEW order header has items attached.
416aA*
416aAC     zzcko1        begsr
416aA*
416aA*    Check to see if any Items attached to NEW Order Header.
416aA*    If none found, then Delete NEW Order Header record.
416aAC     odkey         setll     ordd1                                  75
416aAC                   if        not *in75
416aAC     ohkey         chain     ordh                               74
416aAC                   if        not *in74
416aAC                   delete    ohrec
416aAC                   endif
416aAC                   endif
416aA*
416aAC                   endsr
640cA*
640cA*----------------------------------------------------------------
640cA*
640cA*  ZZGETCN   Get customer notes record.
640cA*
640cAC     zzgetcn       begsr
640cA*
640cAC                   eval      addcustnote = ' '
640cAC                   eval      kycust = oihcus
640cAC     cnkey         chain     custnts
640cAC                   select
640cAC                   when      not %found(custnts)
640cA*
640cA*       Check for all customer note.
640cAC                   eval      kycust = 0
640cAC     cnkey         chain     custnts
640cAC                   select
640cAC                   when      not %found(custnts)
640cAC                   eval      addcustnote = '*NO '
640cAC                   eval      cnnote = ' '
640cAC                   eval      cnexpd = 0
640cAC                   endsl
640cAC                   endsl
640cA*
640cAC                   select
640cAC                   when          %found(custnts)
640cAC                             and addcustnote = ' '
640cAC                             and impdte <= cnexpd
640cAC                             and cnexpd > 0
640cA*
640cA*      or customer note with no expiration date.
640cAC                             or  %found(custnts)
640cAC                             and addcustnote = ' '
640cAC                             and cnexpd = 0
640cAC                   eval      addcustnote = '*YES'
640cAC                   endsl
640cA*
640cAC     endgetcn      endsr
510 A*
510 A*----------------------------------------------------------------
510 A*
510 A*  ZZGETHM   Get order header misc. file rcd. (with/without) record lock.
510 A*
510 AC     zzgethm       begsr
510 A*
510 AC                   select
510 AC                   when      rcdlck = *off
510 AC     hmkey         chain(n)  ordhm
510 A*
510 AC                   when      rcdlck = *on
510 AC     hmkey         chain     ordhm
510 A*
510 AC                   endsl
510 A*
510 A*    Order header misc. record not found. Clear misc fields.
510 AC                   if        not %found(ordhm)
510 AC                   eval      hmmsc1 = ' '
510 AC                   eval      hmmsc2 = ' '
510 AC                   eval      hmmsc3 = ' '
510 AC                   eval      hmmsc4 = ' '
510 AC                   eval      hmmsc5 = ' '
510 AC                   endif
510 A*
510 AC                   endsr
510 A*
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZGTOD  Get order detail record. (with/without) record lock.
416aA*
416aAC     zzgtod        begsr
416aA*
416aAC                   select
416aAC                   when      rcdlck = *off
416aAC     od1key        chain(n)  ordd1                              75
416aA*
416aAC                   when      rcdlck = *on
416aAC     od1key        chain     ordd1                              75
416aA*
416aAC                   endsl
416aA*
416aA*    Order detail line item not found. Clear qty fields.
416aAC                   if        *in75
416aAC                   eval      odqor1 = *zeros
416aAC                   eval      odqor2 = *zeros
416aAC                   eval      odqor3 = *zeros
416aAC                   endif
416aA*
416aAC                   endsr
500eA*----------------------------------------------------------------
500eA*
500eA*  ZZGTOM  Get order detail misc. file rcd. (with/without) record lock.
500eA*
500eAC     zzgtom        begsr
500eA*
500eAC                   select
500eAC                   when      rcdlck = *off
500eAC     omkey         chain(n)  orddm
500eA*
500eAC                   when      rcdlck = *on
500eAC     omkey         chain     orddm
500eA*
500eAC                   endsl
500eA*
500eA*    Order detail line item not found. Clear misc fields.
500eAC                   if        not %found(orddm)
500eAC                   eval      omodsc = ' '
500eAC                   eval      ompdsc = 'N'
500eAC                   eval      ompdsc = 'N'
500eAC                   eval      omrdsc = 'N'
500eAC                   eval      omcbox = 'N'
500eAC                   eval      omcexp = 'N'
500eAC                   eval      ommsc1 = ' '
500eAC                   eval      ommsc2 = ' '
500eAC                   eval      ommsc3 = ' '
500eAC                   eval      ommsc4 = ' '
500eAC                   eval      ommsc5 = ' '
500eAC                   endif
500eA*
500eAC                   endsr
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZXDCK  Attach cross dock item to PO detail line.
416bA*
416bAC     zzxdck        begsr
416aA*
416aA*    Retrieve Open item order detail line
416aAC                   if        mrgrte = *on  and
416aAC                             mrgord = *on
416aAC                   eval      rcdlck = *off
416aAC                   exsr      zzgtod
416aAC                   endif
416aA*
416aA*    If we find this item on an existing Open Order and the codes
416aA*    don't match or this is a cross dock item, force item to New
416aA*    Route, New Order.
416aAC                   if        mrgrte = *on  and
416aAC                             mrgord = *on  and
416aAC                             *in75  and
416aAC                             oidspc <> odspcl  or
416aA*
416aAC                             oidspc = 'XD'
416aAC                   eval      wrgsts = *on
416aAC                   endif
416aA*
416bA* Only work with cross dock items.
416bAC                   if        oidspc <> 'XD'
416bAC                   eval      good2 = 'Y'
416bAC                   goto      endxd
416bAC                   endif
416bA* Loop through P.O. detail records looking for item.
416bAC     keypd1        setll     podtl1
416bAC                   dow       forevr = forevr
TPC DC*    keypd1        reade     podtl1                                 79
TPC MC     keypd1        reade     podtl1
416bA* Error if none found.
TPC DC*                  if        *in79
TPC MC                   if        %eof(podtl1)
416bAC                   eval      pdseq = 0
416bAC                   eval      pdpo = oidpo
416bD*R                   MOVE DESC,4    DETMSG
416bD*R                   ADD  1         BADPO
416bD*R                   LEAVE
416bAC                   endif
416bA* If cross dock slot record exists, update
416bAC                   movel     'XDK'         kydisp
416bAC     keysl4        setll     slot4
416bAC                   dow       forevr = forevr
416bAC                   read      slot4                                  79
416bAC                   if        not *in79  and
416bMC                             slstat = 'XD'  and
416bAC                             slwhse = $pwhse  and
416bAC                             slwhdp = itwhdp  and
416bAC                             slitem = oiditm  and
416bAC                             slaisl = 'XDK'
416bA* Pre-allocate product in case receiving is done before picking.
416bAC                   add       oidq1         slalc1
416bAC                   if        itflg1 = 'Y'
416bAC                   add       oidq2         slalc2
416bAC                   endif
416bAC                   if        itflg2 = 'Y'
416bAC                   add       oidq3         slalc3
416bAC                   endif
416bAC                   update    slrec4
416bAC                   goto      addxdk
416bAC                   else
416bAC                   unlock    slot4
416bAC                   leave
416bAC                   endif
416bAC                   enddo
416bA* Create cross dock slot record.
416bAC                   eval      tmploc = 1
416bAC                   eval      kyaisl = 'XDK'
416bAC     keysl1        setll     slot1
416bAC                   dow       forevr = forevr
416bAC     keysl1        reade(n)  slot1                                  79
416bAC                   if        *in79  or
416bAC                             slloc > tmploc
416bAC                   leave
416bAC                   endif
416bAC     slloc         add       1             tmploc
416bAC                   enddo
416bA*
416bAC                   clear                   slrec
416bAC                   eval      slwhse = oidwhs
416bAC                   eval      slwhdp = itwhdp
416bAC                   eval      slaisl = 'XDK'
416bAC                   eval      slloc = tmploc
416bAC                   eval      slrlvl = 1
416bAC                   eval      slhand = *blanks
416bAC                   eval      slstyp = 'X'
416bAC                   eval      slpseq = tmploc
416bAC                   eval      slitem = oiditm
406 D*                    MOVE 'A '      SLSTAT
416bAC                   eval      slstat = oidspc
416bAC                   eval      slsdte = today
416bAC                   time                    slstim
416bAC                   eval      slpick = 'N'
416bAC                   eval      slrsrv = 'N'
416bA* Format display slot.
416bAC                   call      'FRMTSL'
416bAC                   parm                    slwhse
416bAC                   parm                    slwhdp
416bAC                   parm                    slaisl
416bAC                   parm                    slloc
416bAC                   parm                    slrlvl
416bAC                   parm                    slhand
416bAC                   parm                    slstyp
416bAC                   parm                    slpseq
416bAC                   parm                    sldisp
416bA* Pre-allocate product in case receiving is done before picking.
416bAC                   eval      slalc1 = oidq1
416bAC                   if        itflg1 = 'Y'
416bAC                   z-add     oidq2         slalc2
416bAC                   endif
416bAC                   if        itflg2 = 'Y'
416bAC                   z-add     oidq3         slalc3
416bAC                   endif
416bA* Add record
416bAC     slloc         div       2             dummy
416bAC                   mvr                     slside
416bAC                   if        slside < 0
416bAC                   eval      slside = -(slside)
416bAC                   endif
416bAC                   write     slrec                                77
416bA* Error if slot not created.
416bAC                   if        *in77
404 AC                   eval      detmsg = desc(5)
416bAC                   add       1             badpo
416bAC                   leave
416bAC                   endif
416bA* Create cross dock record.
416bAC     addxdk        tag
416bAC                   eval      cdwhse = slwhse
416bAC                   eval      cdwhdp = slwhdp
416bAC                   eval      cdslot = sldisp
416bAC                   eval      cdord = ohord
416bAC                   eval      cdorsq = oidseq
416bAC                   eval      cdort# = 0
416bAC                   eval      cdorl# = 0
416bAC                   eval      cdpo = pdpo
416bAC                   eval      cdposq = pdseq
416bAC                   eval      cdpot# = 0
416bAC                   eval      cdpol# = 0
416bAC                   write     cdrec                                79
416bAC                   if        *in79
416bAC                   eval      detmsg = desc(6)
416bAC                   add       1             badpo
416bAC                   else
416bAC                   eval      good2 = 'Y'
TPC A*
TPC AC                   if        client = TPC
TPC AC                   if        not %eof(podtl1)
TPC AC                   eval      pdspcl = 'XD'
TPC AC                   update    pdrec
TPC AC                   endif
TPC AC                   endif
TPC A*
416bAC                   endif
416bAC                   leave
416bAC                   enddo
416bA*
TPC AC                   unlock    podtl1
TPC A*
416bAC     endxd         endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZXDELXDK   Delete status 'Z' XDK slots
520aA*
520aAC     zzzDelXDK     begsr

     C                   eval      kyaisl = 'XDK'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
520bA*
520bA*      Delete matching record from Cross Dock file.
520bAC     cdkey         setll     crossdk
520bAC                   dow       forevr = forevr
520bAC     cdkey         reade     crossdk
520bAC                   if        %eof(crossdk)
520bAC                   leave
520bAC                   endif
520bAC
520bAC                   delete    cdrec
520bAC                   enddo
520bA*
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
OVRPRTF FILE(OI2551PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI255PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
