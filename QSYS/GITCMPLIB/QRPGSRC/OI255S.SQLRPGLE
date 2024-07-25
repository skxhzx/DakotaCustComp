      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OI255S    Stage - Import FTP orders - Post
     *  23 February 2011
     *  Retha Davis
     *  Cloned from Cheney's OI255
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
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
     *
640aA*    02/23/11  RBD  6.40a
     *      - Converted to ILE.
     *      - Revised to use staging file impsordd in place of
     *        impfordd and impsordh in place of impfordh.
     *
640bA*    03/06/11  DAS  6.40b
     *      - $PTYPE no longer used. Using OIHTYP instead.
     *        This means that multiple types can be mixed in a single
     *        batch.
     *      - Revised to treat Will Call and Single orders as
     *        individual routes.
     *      - Removed $PTRUK and $PRT* parameters.
     *      - Revised to call RH220 for Will Call orders.
640cA*    07/18/11  MLB  6.40c
     *      - Fix: Revised varianble SUBLIN to be 7,0 from 3,0. Orders
     *        greater than 999 lines causes RNQ0103 Variable too small
     *        to hold result error.
640dA*    04/16/12  MLB  6.40d
     *      - Enh: Revised program to add 2 new fields to file IMPSORDD.
     *        Added fields OIDSLT, OIDBLK to file for Outbound Only
     *        clients. Program will process these new fields only if
     *        field OPFEAT = '3'.
     *      - Added file ORDDS to program.
640eA*    04/23/12  MLB  6.40e
     *      - Enh: Revised program to extended stop number support to
     *        program. New field, OIHEST added to file IMPSORDH.
     *      - Added file, RTESTP to gpm.
640fA*    09/18/12  MLB  6.40f
     *      - Revised pgm to add cmd, XCMD when calling OI260.
     *        Mod provides support for *DFTNOAU cmd to only look for
     *        a default truck for the route else set truck to blanks.
700a *    08/04/15  RTR  7.00a
     *      - Enh: Added call to DH140 to check DOCROUTE for specific
     *        dock door assignments.
     *
710 A*    10/05/17  MLB  7.10
     *      - Enh: Revised tmpcub, tmpwgt to reference rsordc, rsordw
     *        to prevent field overflow errors on cube, wgt.
     *
     *----------------------------------------------------------------
     *
CBIaA*    01/16/06  DAS  CBIa
     *      - Revised to create a fictitious department PRD in RTESUM
     *        using a specific range of item numbers (405000 - 492999)
     *      - Revised to not call UPDRTE.
CBIbA*    10/15/12  MLB  CBIb  P#01092
     *      - Revised pgm to use gross ship wgt stored in PIRITEM in
     *        field ITRCVD instead of net ship wgt, ITSWGT.
     *
     *----------------------------------------------------------------
     A*  Client Custom Revisions
CBI1A*    12/20/12  JGD  CBI1
     *      - Revised to replace the hard coded items number range
     *      - 405 to 492 series comparison with the validation of
     *      - the value loaded in Piritem/Itactv field, if the value
     *      - found is "PR" the item is within series 405 to 492.
     *
     F*----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there is only one route for one
     *    warehouse OR only one order in the member.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  78        - EOF for IMPFORDD
     *  79        - EOF for IMPFORDH
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aDF*impfordh  uf   e           k disk
640aMFimpsordh  uf   e           k disk
640aDF*impfordd  uf   e           k disk
640aMFimpsordd  uf   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
416bAFslot1     uf a e           k disk
416bAFslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
     Frtesum    uf a e           k disk
416aAFordh4     if   e           k disk
     F                                     rename(ohrec:ohrec4)
416aAFordd1     uf   e           k disk
     F                                     rename(odrec:odrec1)
640dAFordds     uf a e           k disk
416aAFoptions   if   e           k disk
416bAFpodtl1    if   e           k disk
416aAFrtehed1   uf   e           k disk
     F                                     rename(rhrec:rhrec1)
     Frtehed    o  a e           k disk
416aMFordh      uf a e           k disk
416bAFcrossdk   o  a e           k disk
     Fordd      o  a e           k disk
640eAFrtestp    o  a e           k disk
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
500dA /COPY QCOPYSRC,ID#CHENEY
500dA /COPY QCOPYSRC,ID#CHENEYO
500dA /COPY QCOPYSRC,ID#CHENEYR
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
640dA*----------------------------------------------------------------
640dA*  *FEATURE  -  PIR Feature options.
640dA*----------------------------------------------------------------
640dA*
640dA* Fields
640dA*
640dA*    OPFEAT  -  PIR Installed feature.
640dA*
640dA* Data structure
640dA*
640dAD opdataF         ds
640dAD  opfeat                 1      1
640dAD  optendF              117    117
416aA*----------------------------------------------------------------
416aA*  Re-definition field(s)
416aA*
416aAD                 ds
416aAD  oihmec                13     15
416aAD  oihmsc                 1     20
416aAD                 ds
416aAD  ohmemc                13     15
700aAD  ohmndr                13     14
416aAD  ohmisc                 1     20
CBIbAD                 ds
CBIbAD  itgwgt                 2      8  2
CBIbAD  itrcvd                 1      8  0
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
     *  Variables
     *
640aDD*$pwhse          s              3  0
     D count           s              3  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
640aAD error           s               n
     D excprt          s              1
     D excpr1          s              1
640aAD filnam          s             10
     D forevr          s              1
     D good1           s              1
     D good2           s              1
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(odstat)
     D kywhdp          s                   like(itwhdp)
     D len             s              1  0
     D linppg          s              3  0
     D lstrid          s                   like(oihrte)
     D lstrte          s                   like(oihrte)
640bAD lstType         s                   like(oihtyp)
     D lstwhs          s              3  0
640aAD mischdrupd      s              4    inz('*NO ')
640aAD miscupdate      s              4    inz('*NO ')
     D mrgitm          s              1
     D mrgord          s              1
     D mrgrte          s              1
     D neword          s                   like(ohord)
     D newrtc          s                   like(rhrte)
     D newrte          s                   like(rhrtid)
     D opened          s              1
     D opnorc          s                   like(ohord)
     D opnord          s                   like(ohord)
640aAD opnordhm        s              1    inz('0')
640aAD opnordm         s              1    inz('0')
     D opnrtc          s                   like(rhrte)
     D opnrte          s                   like(rhrtid)
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
     D skpwrt          s              1
640aAD stamp           s               z
640aAD stampUC         s               z
     D sublin          s              3  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
710 DD*tmpcub          s                   like(itcube)
710 MD tmpcub          s                   like(rsordc)
     D tmploc          s              3  0
710 DD*tmpwgt          s                   like(itswgt)
710 MD tmpwgt          s                   like(rsordw)
     D today           s              8  0
     D work3a          s              3
     D wkdoor          s              3a
     D wkdoor2         s              2a
     D wrgsts          s              1

640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

640aAc     *entry        plist
640aMc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640bDC**                 parm                    $ptype            1
640bDC**                 parm                    $ptruk           10
640bDC**                 parm                    $prt01            5
640bDC**                 parm                    $prt02            5
640bDC**                 parm                    $prt03            5
640bDC**                 parm                    $prt04            5
640bDC**                 parm                    $prt05            5
640bDC**                 parm                    $prt06            5
640bDC**                 parm                    $prt07            5
640bDC**                 parm                    $prt08            5
640bDC**                 parm                    $prt09            5
640bDC**                 parm                    $prt10            5
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     *----------------------------------------------------------------
     * Key definitions
     *
     * Download order detail file - Partial key
     *
     C     oidkey        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
640dA*
640dA* ORDDS  Order detail pick slot file - Full key
640dA*
640dAC     oskey         klist
640dAC                   kfld                    odwhse
640dAC                   kfld                    odord
640dAC                   kfld                    odseq
640dAC                   kfld                    oditem
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
416aMC                   kfld                    kyrtid
500dMC                   kfld                    kywhdp
     *----------------------------------------------------------------
     *
500dA*
500dA* Get client id.
500dA*
500dAC                   call      @getcl
500dAC                   parm                    client           10
500dAC                   parm                    cliloc           10
416dA*
416dA* Initialize route id's
416dA*
640bDC**                 eval      $prt01 = *blanks
640bDC**                 eval      $prt02 = *blanks
640bDC**                 eval      $prt03 = *blanks
640bDC**                 eval      $prt04 = *blanks
640bDC**                 eval      $prt05 = *blanks
640bDC**                 eval      $prt06 = *blanks
640bDC**                 eval      $prt07 = *blanks
640bDC**                 eval      $prt08 = *blanks
640bDC**                 eval      $prt09 = *blanks
640bDC**                 eval      $prt10 = *blanks
640bDC**                 eval      rtcnt = 0
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
640bAC                   eval      lstType = '@'
417aAC                   eval      lstrid = '@@@@@'
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
411 AC                   eval      lstwhs = -(1)
     *
640aAC     keysoh        setll     impsordh
     C                   dou       eofh = *on
CBIaAC                   if        client <> cheney
417aAC                   exsr      updrte
CBIaAC                   endif
     *
640aAC                   eval      error = *off
     *
640aDC**                 read      impfordh                               79
640aMC     keysoh        reade     impsordh                               79
     C                   if        *in79
     C                   eval      eofh = *on
640eA*
640eA*  When route changes, resquence stops in RTESTP file.
640eAC                   if        lstrte <> '@@@@@'
640eAC                   exsr      reseqstp
700aAC                   exsr      dockroute
640eAC                   endif
640eA*
     C                   goto      enddoh
     C                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        oihstatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
     *  Create warehouse heading if necessary.
     *
411 MC                   if        lstwhs <> oihwhs
     *
     C                   eval      whcode = oihwhs
416aAC                   eval      $pwhse = oihwhs
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
416aA*
416aA*    Retrieve General Pick options for warehouse.
416aA*    This applies to only Regular orders.
416aA*
416cAC                   select
640bDC**                 when      $ptype = ' '
640bMC                   when      oihtyp = ' '
416aAC                   eval      opwhse = oihwhs
416aAC                   eval      opcode = '*GENPICK'
416aAC     opkey         chain     options                            7978
416aAC                   if        *in79
416aAC                   eval      opmrga = 'N'
416aAC                   endif
416cA*
416cA*    Force Allow Merge orders to Yes for 'S' orders.
416cA*
640bDC**                 when      $ptype = 'S'
640bMC                   when      oihtyp = 'S'
416aAC                   eval      opmrga = 'Y'
416aA*
416aA*    All other order types, force Allow Merge orders to No
416aA*
416cMC                   other
416aAC                   eval      opmrga = 'N'
416cMC                   endsl
640dA*
640dAC                   eval      opcode = '*FEATURE'
640dAC     opkey         chain     options
640dAC                   if        not %found(options)
640dAC                   eval      opfeat = '2'
640dAC                   else
640dAC                   eval      opdataf = opdata
640dAC                   endif
     *
640aMC                   eval      $pwhse = whcode
     C                   move      oihwhs        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
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
640bAC                             or oihtyp = 'W'
640bAC                             or oihtyp = 'S'
640bAC                   if        lstType = 'W'
640bAC                   exsr      processWC
640bAC                   endif
416aAC                   eval      mrgrte = *off
416aAC                   eval      newrte = *blanks
416aAC                   eval      newrtc = *blanks
416aA*
416aA*  Merge order(s) into Open routes allowed.
416aA*  Check if Route still at Open status.
416aA*
416aAC                   if        opmrga = 'Y'  and
640bMC                             oihtyp = ' '
640bDC**                           $ptype = ' '
416aAC                   exsr      zzckr1
416aAC                   exsr      zzckrt
416aAC                   endif
416aA*
640eA*  When route changes, resquence stops in RTESTP file.
640eAC                   if        lstrte <> '@@@@@'
640eAC                   exsr      reseqstp
700aAC                   exsr      dockroute
640eAC                   endif
640eA*
     C                   exsr      fillrh
     C                   write     rhrec                                49
     C                   eval      lstrte = oihrte
640bAC                   eval      lstType = oihtyp
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
     C                   write     ohrec                                49
     C                   if        *in49
     C                   eval      hedmsg = desc(1)
     C                   add       1             preoh
     C                   endif
640eA*
640eA*    Fill Route Extended Stop file
640eAC                   exsr      fillxr
640eAC                   write (e) rtsrec
640eAC                   if        %error
640eAC                   endif
640eA*
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
640aDC**   oidkey        setll     impfordd
640aMC     keysod        setll     impsordd
     C                   dou       eofd = *on
     *
640aAC                   eval      error = *off
     *
640aDC**   oidkey        reade     impfordd                               78
640aMC     keysod        reade     impsordd                               78
     C                   if        *in78
     C                   eval      eofd = *on
     C                   goto      enddod
     C                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        oidstatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
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
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      itdesc = *blanks
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
640dA*
640dA*    Update picking info for Outbound Only client.
640dAC                   if        opfeat = '3'
640dAC                   exsr      fillos
640dAC                   endif
416aA*
416aA*    Record was updated in FILLOD.
416aAC                   if        skpwrt = *off
     C                   write     odrec                                49
640dA*
640dAC                   if        opfeat = '3'
640dAC                   write     osrec                                48
640dAC                   endif
640dA*
     C                   if        *in49
640aAC                   eval      error = *on
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
640aA*  DO NOT delete detail record from download file.
640aDC**                 delete    oidrec
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
416 A*
416 AC                   endsl
     *
640aAC                   eval      oidordid = ohord
640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      oidstatus = 'E'
640aAC                   eval      oidtext   = detmsg
640aAC                   eval      filnam    = 'IMPSORDD'
640aAC                   else
640aAC                   eval      oidstatus = 'S'
640aAC                   eval      oidtext = ' '
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      oidststs = stamp
640aAC                   eval      oidstsuc = stampuc
640aAC                   update    oidrec
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
640aA*  DO NOT delete header record from download file.
640aDC**                 delete    oihrec
     *
640aAC                   eval      oihrteid  = rhrtid
640aAC                   eval      oihordid  = ohord
640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      oihstatus = 'E'
640aAC                   eval      oihtext   = detmsg
640aAC                   eval      filnam    = 'IMPSORDH'
640aAC                   else
640aAC                   eval      oihstatus = 'S'
640aAC                   eval      oihtext = ' '
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      oihststs = stamp
640aAC                   eval      oihstsuc = stampuc
640aAC                   update    oihrec
     *
     C     enddoh        tag
     C                   enddo

640bAC                   if        lstType = 'W'
640bAC                   exsr      processWC
640bAC                   endif
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
     *
     *  We are finished so get out
     *
640aAC                   exsr      zzzEnd
640aDC**                 eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
416aA*
416aA*  *INZSR  Initialization subroutine
416aA*
416aAC     *inzsr        begsr
416bA*
640bD **IMPFORDH Download order header file - Partial key
640bDC**   oihkey        klist
640bDC**                 kfld                    $pwhse
640bDC**                 kfld                    $ptype
     *
640aA*  Define key for impsordh file.
640aA*
640aAC     keysoh        klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
     *
640aA*  Define key for impsordd file.
640aA*
640aAC     keysod        klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
640aAC                   kfld                    oihord
     *
416aA* ORDH Order header file - Partial key
416aA*
416aAC     ohkey         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    neword
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
416aA*
416aA*  Variables and constants.
416aA*
640aAC                   eval      error  = *off
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
640dA*
640dA*----------------------------------------------------------------
640dA*
640dA*  FILLOS  Fill order detail pick slot fields.
640dA*
640dAC     filloS        begsr
640dA*
640dA*    Route & order at Open status. Check if item already on order.
640dA*    If yes, then compute difference between import qty's and order
640dA*    qty's. Then update order with import qty.
640dAC                   select
640dAC                   when      mrgrte = *on  and
640dAC                             mrgord = *on  and
640dAC                             wrgsts = *off
640dA*
640dAC                   exsr      zzgtos
640dA*
640dAC                   select
640dAC                   when          %found(ordds)
640dAC                             and oiditm = oditem
640dA*
640dAC                   eval      osdisp = oidslt
640dAC                   eval      osbulk = oidblk
640dAC                   update    osrec
640dA*
640dAC                   goto      endlods
640dAC                   endsl
640dA*
640dAC                   endsl
640dA*
640dA*  Initialize record
640dA*
640dAC                   clear                   osrec
640dA*
640dA*  Move fields from download file to purchase order header fields
640dA*
640dAC                   eval      oswhse = oidwhs
640dA*
640dA*    Open route found, Open order not found or at wrong status.
640dA*    Create order under current Open route.
640dAC                   select
640dAC                   when      mrgrte = *on  and
640dAC                             mrgord = *off  and
640dAC                             wrgsts = *off  or
640dA*
640dAC                             mrgrte = *on  and
640dAC                             mrgord = *off  and
640dAC                             wrgsts = *on
640dAC                   eval      osord = neword
640dA*
640dA*    Open route found, Open order found.
640dA*    Add item to current Open order.
640dAC                   when      mrgrte = *on  and
640dAC                             mrgord = *on  and
640dAC                             wrgsts = *off
640dAC                   eval      osord = opnord
640dA*
640dAC                   other
640dAC                   eval      osord = ohord
640dAC                   endsl
640dA*
640dAC                   eval      osseq  = oidseq
640dAC                   eval      ositem = oiditm
640dAC                   eval      osdisp = oidslt
640dAC                   eval      osbulk = oidblk
640dA*
640dAC     endlods       tag
640dA*
640dAC                   endsr
640dA*
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
640eA*
640eA*      Set stops to zero. OI300 will compute a sequential
640eA*      stop number to be populated into this field.
640eAC                   if        oihest > 0
640eAC                   eval      ohstop = 0
640eAC                   else
640eA*
     C                   eval      ohstop = oihstp
640eaC                   endif
640eA*
     **                   MOVE OIHTRK    OHTRUK
640bDC**                 eval      ohtruk = $ptruk
640bMC                   eval      ohtruk = rhtruk
     C                   eval      ohmisc = oihmsc
     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = impdte
     C                   eval      ohstim = imptim
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
417aAC                   eval      lstrid = rhrtid
416dD**                   MOVE RHRTID    $PRTID
640bDC**                 add       1             rtcnt
640bDC**                 select
640bDC**                 when      rtcnt = 1
640bDC**                 eval      $prt01 = rhrtid
640bDC**                 when      rtcnt = 2
640bDC**                 eval      $prt02 = rhrtid
640bDC**                 when      rtcnt = 3
640bDC**                 eval      $prt03 = rhrtid
640bDC**                 when      rtcnt = 4
640bDC**                 eval      $prt04 = rhrtid
640bDC**                 when      rtcnt = 5
640bDC**                 eval      $prt05 = rhrtid
640bDC**                 when      rtcnt = 6
640bDC**                 eval      $prt06 = rhrtid
640bDC**                 when      rtcnt = 7
640bDC**                 eval      $prt07 = rhrtid
640bDC**                 when      rtcnt = 8
640bDC**                 eval      $prt08 = rhrtid
640bDC**                 when      rtcnt = 9
640bDC**                 eval      $prt09 = rhrtid
640bDC**                 when      rtcnt = 10
640bDC**                 eval      $prt10 = rhrtid
640bDC**                 endsl
416aAC                   eval      newrte = rhrtid
640bDC**                 if        $ptype = 'W'  and
640bMC                   if        oihtyp = 'W'  and
417 D*R         RHRTE     ANDEQ*BLANKS
417 MC                             oihrte = *blanks
414 AC                   eval      rhrte = rhrtid
414 AC                   else
     C                   eval      rhrte = oihrte
414 AC                   endif
416aAC                   eval      newrtc = oihrte
     C                   eval      rhtype = oihtyp
640bDC**                 if        $ptype = 'W'  and
640bMC                   if        oihtyp = 'W'  and
416eMC                             oihtrk = *blanks
416eD**         RHTRUK    ANDEQ*BLANKS
414 AC                   eval      rhtruk = *blanks
414 AC                   movel     'WILLCALL'    rhtruk
414 AC                   else
     C                   eval      rhtruk = oihtrk
414 AC                   endif
414 D**                   MOVE OIHTRK    $PTRUK
640bDC**                 eval      $ptruk = rhtruk
     C                   eval      rhstat = *on
     C                   eval      rhstsd = impdte
     C                   eval      rhstst = imptim
     C                   eval      rhimpd = impdte
     C                   eval      rhimpt = imptim
     C                   eval      rhrptd = impdte
     *
     C                   endsr
640eA*
640eA*----------------------------------------------------------------
640eA*
640eA*  FILLXR   Fill Stop Xref File RTESTP
640eA*
640eAC     fillxr        begsr
640eA*
640eA*  Initialize record
640eA*
640eAc                   clear                   rtsRec
640eA*
640eAc                   eval      rtswhs = ohWhse
640eAc                   eval      rtsrid = ohRte
640eAc                   eval      rtsord = ohord
640eAc                   eval      rtsstp = 0
640eAc                   eval      rtsst5 = oihest
640eA*
640eAc                   endsr
640eA*
640eA*----------------------------------------------------------------
640eA*
640eA*  RESEQSTP   Call pgm to Re-Sequence ORDH file
640eA*
640eAC     reseqstp      begsr
640eA*
640eA*  Resequence stops in ORDH to make them unique.
640eA*
640eAc                   call      'OI300'
640eAc                   parm                    rhwhse
640eAc                   parm                    lstrid
640eA*
640eAc                   endsr
640eA*
700aA*----------------------------------------------------------------
700aA*
700aA*  DOCKROUTE  Call pgm to assign dock doors for route
700aA*
700aAC     dockroute     begsr
700aA*
700aAc                   call      'DH140'
700aAc                   parm                    rhwhse
700aAc                   parm                    lstrid
700aAc                   parm                    lstrte
700aAc                   parm                    wkdoor
700aA*
700aA /free
700aA   if wkdoor <> *blanks;
700aA     wkdoor2 = %subst(wkdoor:2:2);
700aA     exec sql update ordh
700aA                 set ohmisc = substr(ohmisc,1,12) || :wkdoor2
700aA                            || substr(ohmisc,15,6)
700aA               where ohrte = :lstrid;
700aA   endif;
700aA /end-free
700aAc                   endsr
700aA*
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
640bA*----------------------------------------------------------------
640bA*  ProcessWC   Call program to process Will Call
640bA*----------------------------------------------------------------
640bA*
640bAC     processWC     begsr

     C                   call      'RH220'
     C                   parm      rhwhse        $xWhse           15 5
     C                   parm      rhtruk        $xTruk           10
     C                   parm      '0'           $xJTyp            1
     C                   parm      #pgm          $xPrg            10
     C                   parm      rhrtid        $xRtId            5
     C                   parm      ' '           $xRtn             8

     C                   endsr
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
     C                   call      'OI260'
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   parm                    rhtruk
     C                   parm                    $xrtn             8
640fAC                   parm                    $xcmd             8
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
CBI1DC*>                 if        ititem >= '405000'  and
CBI1DC*>                           ititem <= '492999'
CBI1AC                   if        itactv = 'PR'
CBIaAC                   eval      kywhdp = 'PRD  '
CBIaAC                   else
CBIaAC                   eval      kywhdp = itwhdp
CBIaAC                   endif
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
500aAC     tmpcub        mult      difqy1        tmpcub
500aAC                   else
500aAC     itcube        div(h)    itumq2        tmpcub
500aAC     tmpcub        mult      difqy1        tmpcub
500aAC                   endif
500aAC                   else
416aMC     itcube        mult      difqy1        tmpcub
500aAC                   endif
500aA*
     C                   add       tmpcub        rsordc
416aD*R         ITSWGT    MULT ODQOR1    TMPWGT
CBIbA*
CBIbAC                   if        client = Cheney
CBIbAC                   if        itgwgt > 0
CBIbAC     itgwgt        mult      difqy1        tmpwgt
CBIbAC                   else
CBIbAC     itswgt        mult      difqy1        tmpwgt
CBIbAC                   endif
CBIbAC                   else
CBIbA*
416aMC     itswgt        mult      difqy1        tmpwgt
CBIbAC                   endif
CBIbA*
     C                   add       tmpwgt        rsordw
     *
416aD*R                   ADD  ODQOR2    RSORDP
416aMC                   add       difqy2        rsordp
416aD*R         ODQOR2    IFNE 0
416aMC                   if        difqy2 <> 0  and
     C                             itumq2 > 0
     C     itcube        div(h)    itumq2        tmpcub
416aD*R         TMPCUB    MULT ODQOR2    TMPCUB
416aMC     tmpcub        mult      difqy2        tmpcub
     C                   add       tmpcub        rsordc
CBIbA*
CBIbAC                   if        client = Cheney
CBIbAC                   if        itgwgt > 0
CBIbAC     itgwgt        div(h)    itumq2        tmpwgt
CBIbAC                   else
CBIbAC     itswgt        div(h)    itumq2        tmpwgt
CBIbAC                   endif
CBIbAC                   else
CBIbA*
     C     itswgt        div(h)    itumq2        tmpwgt
CBIbAC                   endif
CBIbA*
416aD*R         TMPWGT    MULT ODQOR2    TMPWGT
416aMC     tmpwgt        mult      difqy2        tmpwgt
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
416aMC     tmpcub        mult      difqy3        tmpcub
     C                   add       tmpcub        rsordc
CBIbA*
CBIbAC                   if        client = Cheney
CBIbAC                   if        itgwgt > 0
CBIbAC     itgwgt        div(h)    itumq3        tmpwgt
CBIbAC                   else
CBIbAC     itswgt        div(h)    itumq3        tmpwgt
CBIbAC                   endif
CBIbAC                   else
CBIbA*
     C     itswgt        div(h)    itumq3        tmpwgt
CBIbAC                   endif
CBIbA*
416aD*R         TMPWGT    MULT ODQOR3    TMPWGT
416aMC     tmpwgt        mult      difqy3        tmpwgt
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
640aAC                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        oidq3 <> 0  and
     C                             itflg2 <> 'Y'
640aAC                   eval      error = *on
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
416aAC     rh1key        setgt     rtehed1
416aAC     rh1key        readpe    rtehed1                                73
416aAC                   select
416aAC                   when      not *in73  and
416aAC                             rhtype = ' '  and
416aAC                             rhstat = '1'
416aAC                   eval      mrgrte = *on
416aAC                   eval      opnrte = rhrtid
416aAC                   eval      opnrtc = rhrte
416aA*
416aAC                   other
416aAC                   eval      mrgrte = *off
416aAC                   unlock    rtehed1
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
416aAC                             ohstat = 'O'  and
416aA*    Next line is for GFG ONLY: Memo codes must match.
416aAC                             oihmec = ohmemc
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
640dA*
640dA*----------------------------------------------------------------
640dA*
640dA*  ZZGTOS  Get order detail pick slot record. (with/without) record lock.
640dA*
640dAC     zzgtos        begsr
640dA*
640dAC     oskey         chain     ordds
640dA*    Order detail line item not found. Clear qty fields.
640dAC                   if        not %found(ordds)
640dAC                   eval      osdisp = *blanks
640dAC                   eval      osbulk = 'N'
640dAC                   endif
640dA*
640dAC                   endsr
640dA*
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
416bAC     keypd1        reade     podtl1                                 79
416bA* Error if none found.
416bAC                   if        *in79
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
640aAC                   eval      error = *on
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
640aAC                   eval      error = *on
416bAC                   eval      detmsg = desc(6)
416bAC                   add       1             badpo
416bAC                   else
416bAC                   eval      good2 = 'Y'
416bAC                   endif
416bAC                   leave
416bAC                   enddo
416bA*
416bAC     endxd         endsr
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
640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See '
                    + %trimr(filnam)
                    + ' file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
          filnam   = *blanks;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- oi255s/zzzend';
          leavesr;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- oi255s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr

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
OVRPRTF FILE(OI2551PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI255PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
