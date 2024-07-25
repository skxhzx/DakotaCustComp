      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RTESUB     Route item substitution
     *  08 May 2014
     *  Dave Sommerville
     *
     *  NOTE:
     *      Based on RH182
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    05/08/14  DAS  6.50
     *      - Created
720aA*    07/17/18  LMC  7.20a
     *      - Changed $pseq and hld_$pseq
750 A*    05/12/21  KDE  7.50
     *      - Changed to support DD2
750aA*    06/16/21  KDE  7.50
     *      - Changed to support AutoSub
     *
760aA*    08/12/22  RBD  7.60a
     *      - Reserved.
     *
760bA*    09/15/22  KDE  7.60b
     *      - Change to call OR630ADB when updating PLTSUM to ensure
     *        all pallets are represented in PLTMISC so Truck Map includes
     *        all pallets.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fordh      if   e           k disk
     Fordd      uf a e           k disk
     F                                     rename(odrec:record)
     Frtehed    if   e           k disk
510 AFrtesum    uf a e           k disk
416dAFoptions   if   e           k disk
CBIbAFoptionz   if   e           k disk
520cAFslot2     if   e           k disk    prefix(s_)
510cMFpltsum2   uf a e           k disk
     Fpltstp1   uf a e           k disk
640 AFtruckh    if   e           k disk
640gAFpiritem   if   e           k disk
     Fworklbl   o    e           k disk
     Fworklbl8  if   e           k disk
     F                                     rename(lwrec:lwrec8)
640dMFlabel     if a e           k disk

     *----------------------------------------------------------------
510 A*  Table and array definitions
     *----------------------------------------------------------------

530 MD desc            s             50    DIM(7) CTDATA PERRCD(1)

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

CWD A /copy qcopysrc,id#cashwa
510bA /copy qcopysrc,id#citylin
FFC A /copy qcopysrc,id#fischer
FRF A /copy qcopysrc,id#FRF
GFCaA /copy qcopysrc,id#glazier
HKW A /copy qcopysrc,id#hkw
520bA /copy qcopysrc,id#ifd
JOR A /copy qcopysrc,id#jordano
KFSaA /copy qcopysrc,id#kfs
520dA /copy qcopysrc,id#palmer
SLBaA /copy qcopysrc,id#silberm

     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------

      /copy qcopysrc,p.driitem
      /copy qcopysrc,p.drislot
      /COPY *libl/qcopysrc,c#item
      /COPY *libl/qcopysrc,c#slot
     D savever#        s                   like($itver#)

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D forevr          s               n
     D forever         s               n
     D orddExists      s               n
     D rtebuilt        s               n
     D rteopen         s               n
     D rteprinted      s               n
510 AD SSBflag         s               n
     D blank15         s             15
     D rtnCode         s              8
     D rtnMessage      s             60

510 AD $pcmd           s              8
510 AD $pwhse          s              3  0
510 AD $prteid         s              5
510 AD $pord           s              7  0
720aDD*$pseq           s              3  0
720aMD $pseq           s              5  0
510 AD $pitem          s             15
640 AD $ptmpl          s             10
640 AD $ptruk          s             10
510 AD hld_$pitem      s             15
510 AD hld_$pord       s              7  0
720aDD*hld_$pseq       s              3  0
720aMD hld_$pseq       s              5  0
750 Ad tbEnhanced      s               n
750 Ad tbPalletType    s              1
750 Ad tbType          s              1
750 Ad oneChar         s              1
750 Ad Oplid           s              7  0
     D w1seq           s              5  0
510 AD w1oit           s             15
510 AD w1itm           s             15
     D w1qor1          s              5  0
     D w1qor2          s              5  0
     D w1qor3          s              4  0
     D w1row           s              2  0
     D w1col           s              1  0
     D w1dev           s             10
     D w1disp          s             12
     D pickqty1        s                   like(w1qor1)
     D pickqty2        s                   like(w1qor2)
     D pickqty3        s                   like(w1qor3)

     D kycode          s                   like(opzcod)
     D kygen           s                   like(psgen)
     D kysbsq          s                   like(pssbsq)
     D kytype          s                   like(pstype)
CWDbAD svor2           s                   like(odor2)
510 AD totqty          s              5  0
     D ttlcub          s              9  3
     D ttlwgt          s              9  2
     D ttlpcs          s              5  0
     D curdate         s              8  0
     D curtime         s              6  0
     D lasttime        s              6  0
640dAD sectioncode     s              2

     D #sentitem       s                   like($ititem)
     D #senttype       s                   like($ittype)
     D #sentdesc       s                   like($itdesc)
     D #sentpdsc       s                   like($itpdsc)
     D #sentwhdp       s                   like($itwhdp)
     D #sentstyp       s                   like($itstyp)
     D #sentdesg       s                   like($itdesg)
     D #sentum1        s                   like($itum1)
     D #sentflg1       s                   like($itflg1)
     D #sentum2        s                   like($itum2)
     D #sentumq2       s                   like($itumq2)
     D #sentflg2       s                   like($itflg2)
     D #sentum3        s                   like($itum3)
     D #sentumq3       s                   like($itumq3)
     D #sentcube       s                   like($itcube)
     D #sentswgt       s                   like($itswgt)
     D #sentmitem      s                   like($itmitem)

     D #slotitem       s                   like($ititem)
     D #slottype       s                   like($ittype)
     D #slotdesc       s                   like($itdesc)
     D #slotpdsc       s                   like($itpdsc)
     D #slotwhdp       s                   like($itwhdp)
     D #slotstyp       s                   like($itstyp)
     D #slotdesg       s                   like($itdesg)
     D #slotum1        s                   like($itum1)
     D #slotflg1       s                   like($itflg1)
     D #slotum2        s                   like($itum2)
     D #slotumq2       s                   like($itumq2)
     D #slotflg2       s                   like($itflg2)
     D #slotum3        s                   like($itum3)
     D #slotumq3       s                   like($itumq3)
     D #slotnrpk       s                   like($imnrpk)
     D #slotflgd       s                   like($itflgd)
     D #slotcube       s                   like($itcube)
     D #slotswgt       s                   like($itswgt)
     D #slotcwgt       s                   like($itcwgt)
     D #slotmitem      s                   like($itmitem)

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Convert Date fields.
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

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
520cA* OHMISC data structure
     *----------------------------------------------------------------

520cAD dsmisc          DS
520cAD  dssubf                10     10
GFCcA /copy qcopysrc,ohmisc_gfc

520cA*----------------------------------------------------------------
520cA*  *FEATURE  -  PIR Feature options.
520cA*----------------------------------------------------------------
520cA*
520cA* Fields
520cA*
520cA*    OPFEAT  -  PIR Installed feature.
520cA*
520cA* Data structure
520cA*
520cAD opfdta          DS
520cAD  opfeat                 1      1
520cAD  opfend               117    117

640cA*----------------------------------------------------------------
640cA*  *GENPICK -  General picking.
640cA*----------------------------------------------------------------
640cA*
640cA* Fields
640cA*
640cA*    OPERPT  -  Print exception (short) error report (Y,N).
640cA*    OPELBL  -  Print exception (short) labels (Y,N).
640cA*    OPRFWC  -  Using RF will call (Y,N).
640cA*    OPNRSC  -  Number of pallet sections (1-9).
640cA*    OPHPWC  -  Host pick Will Call (Y/N).
640cA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
640cA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
640cA*    OPEADJ  -  Close short labels without adjustment (Y,N).
640cA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
640cA*    OPGPK1  -  <Not Used / Available>
640cA*    OPGPK2  -  <Not Used / Available>
640cA*               task has been assigned. (Y/N)
640cA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
640cA*                 0=None. No replenishments are created.
640cA*                 1=Letdowns are created during Truck Builder
640cA*                   Pick/Print processing.
640cA*                 2=Priority Replenishments are created during
640cA*                   Truck Builder Pick/Print processing.
640cA*                 3=JIT Letdowns created when transaction is
640cA*                   checked out.
640cA*                 4=JIT Priority Replenishments created when
640cA*                   transaction is checked out.
640cA*    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
640cA*    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
640cA*    OPRFLC  -  RF Pick Verify item with license (Y/N)
640cA*    OPRFSL  -  RF Pick Verify slot (Y/N)
640cA*    OPRBN1  -  Round robin printing compatable (Y/N)
640cA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640cA*               1=Off
640cA*               2=By route
640cA*               3=By transaction
640cA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
640cA*
640cA* Data structure
640cA*
640cAD oppdta          ds
640cAD  operpt                 1      1
640cAD  opelbl                 2      2
640cAD  oprfwc                 3      3
640cAD  opnrsc                 4      4  0
640cAD  ophpwc                 5      5
640cAD  opmrga                 6      6
640cAD  opplsq                 7      7
640cAD  opeadj                 8      8
640cAD  opnopk                 9      9
640cAD  opgpk1                10     10
640cAD  opgpk2                11     11
640cAD  opjitr                12     12
640cAD  oppset                13     13
640cAD  oprfuc                14     14
640cAD  oprflc                15     15
640cAD  opusf1                16     16
640cAD  oprfsl                17     17
640cAD  oprbn1                18     18
640cAD  oprbn2                19     19
640cAD  opsubt                20     20
640cAD  oppend               117    117

CBIbAI*----------------------------------------------------------------
CBIbAI*  *PICKLBL  -  Picking label options
CBIbAI*----------------------------------------------------------------
     I*
     I* Fields
     I*
     I*    OPCLVL  -  Qty level for combined labels.
     I*    OPCWRB  -  Print combined label warning before.
     I*    OPCWRA  -  Print combined label warning after.
     I*    OPUWRB  -  Print unit of measure warning before.
     I*    OPUWRA  -  Print unit of measure warning after.
     I*    OPTEXT  -  Text for last line of label.
     I*    OPERR   -  Error label ratio.
     I*    OPCWGT  -  Catch weight label ratio.
     I*    OPLPGM  -  Picking label program.
     I*    OPPDEV  -  Printer device.
     I*    OPPFRM  -  Printer form.
     I*
     I* Data structure
     I*
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117

     *----------------------------------------------------------------
640fA*  *PICKLBA -  Label printing options for the standard pick,
     *              retail, and tote labels.
     *
     *     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBA which holds printing info
     *         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opzdta2         ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  optend2              117    117

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pWhse          s              3  0
     D  pOrd           s              7  0
     D  pOrgSeq        s              5  0
     D  pOrgItem       s             15
     D  pSubItem       s             15
     D  pSubSeq        s              5  0
     D  pSubQty1       s              5  0
     D  pSubQty2       s              5  0
     D  pSubQty3       s              4  0
     D  pSubSlot       s             12
     D  pSubPltId      s              7  0
     D  pSubDev        s             10

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getitmsb
750 A /copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      pOrd        Order number
     *      pOrgSeq     Original order detail seq#
     *      pOrgItem    Original Item
     *      pSubItem    Sub Item
     *      pSubSeq     Sub seq#
     *      pSubQty1    Sub Qty 1
     *      pSubQty2    Sub Qty 2
     *      pSubQty3    Sub Qty 3
     *      pSubSlot    Sub Slot
     *      pSubPltId   Sub Pallet Id
     *      pSubDev     Sub Printer Device
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pOrd
     C                   parm                    pOrgSeq
     C                   parm                    pOrgItem
     C                   parm                    pSubItem
     C                   parm                    pSubSeq
     C                   parm                    pSubQty1
     C                   parm                    pSubQty2
     C                   parm                    pSubQty3
     C                   parm                    pSubSlot
     C                   parm                    pSubPltId
     C                   parm                    pSubDev

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        // Convert fields to uppercase

        pOrgItem = %xlate(xlower: xupper: pOrgItem);
        pSubItem = %xlate(xlower: xupper: pSubItem);
        pSubSlot = %xlate(xlower: xupper: pSubSlot);
        pSubDev  = %xlate(xlower: xupper: pSubDev);

        // Get order detail
        exsr GetORDD;
        if error;
          return;
        endif;

        // Get order header
        exsr GetORDH;
        if error;
          return;
        endif;

        // Get substitute option

        exsr GetSubOpt;
        if error;
          return;
        endif;

        // Get route header
        exsr GetRTEHED;
        if error;
          return;
        endif;

        // Get sub item
        exsr GetSubItem;
        if error;
          return;
        endif;

        // Get section code of original pallet
        exsr GetSectionCode;

        // Call Check Routine

        $pcmd = '*SUB';
        $pwhse = pWhse;
        $pord = pOrd;
        $pseq = pOrgSeq;
        $pitem = pOrgItem;
        $prteid = rhrtid;
        hld_$pord = pOrd;
        hld_$pseq = pOrgSeq;
        hld_$pitem = pOrgItem;
        w1seq = pSubSeq;
        w1oit = pOrgItem;
        w1itm = pSubItem;
        w1qor1 = pSubQty1;
        w1qor2 = pSubQty2;
        w1qor3 = pSubQty3;
        w1dev = pSubDev;
        w1disp = pSubSlot;
CWDbA   svor2 = odor2;
        dsplid = pSubPltId;
        w1row  = dsplrw;
        w1col  = dsplcl;

        exsr zzchk1;
        if error;
          return;
        endif;

        // Call Update routine

510 M   if SSBflag  = *on;
          pickqty1 = 0;
          pickqty2 = w1qor1;
          pickqty3 = w1qor2;
        else;
          pickqty1 = w1qor1;
          pickqty2 = w1qor2;
          pickqty3 = w1qor3;
        endif;

        exsr zzupdadd;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

      /end-free
640gA*
640gA*  Define key for PIRITEM file.
640gA*
640gAC     itkey         klist
640gAC                   kfld                    $pwhse
650dDC*                  kfld                    #bitem
650dMC                   kfld                    w1itm

     *    OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640 D ***                kfld                    pstruk
640 MC                   kfld                    $ptmpl
     C                   kfld                    psszon
     C
     C     keyopz2       klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640 D ***                kfld                    pstruk
640 MC                   kfld                    $ptmpl

     *    PLTSUM2 file.

     C     keyps2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prteid
     C                   kfld                    kytype
     C                   kfld                    kygen
     C                   kfld                    w1row
     C                   kfld                    w1col

     *  PLTSTP2 file.
     *
     C     keypss1       klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     C                   kfld                    ohstop
     C                   kfld                    kysbsq

510 A*    RTESUM file

510 AC     keyrs         klist
510 AC                   kfld                    $pwhse
510 AC                   kfld                    $prteid
510 AC                   kfld                    #sentwhdp
640 A*
640 A*  Define key for TRUCKH file.
640 A*
640 AC     trkey         klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    $ptruk

     *    WORKLBL8 file.

     C     keylw8        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prteid
     C                   kfld                    w1oit

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetFeature  Get Feature
     *----------------------------------------------------------------

      /free
       begsr GetFeature;

         chain (pWhse: '*FEATURE') options;
         if not %found(options);
           opfeat = '2';
         else;
           opfdta = opdata;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSubItem     Get sub item info
     *----------------------------------------------------------------

      /free
       begsr GetSubItem;

         // Get info for item

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = pWhse;
         $ititem = pSubItem;
         $dridata = $item;
         $dridata2 = $item2;

         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn <> '*OK';
           error = *on;
           pMessage = 'Error: Sub item not found '
                    + '(' + %trimr(pSubItem) + ')';
           leavesr;
         endif;

         #sentitem = $ititem;
         #senttype = $ittype;
         #sentdesc = $itdesc;
         #sentpdsc = $itpdsc;
         #sentwhdp = $itwhdp;
         #sentstyp = $itstyp;
         #sentdesg = $itdesg;
         #sentcube = $itcube;
         #sentswgt = $itswgt;
         #sentum1  = $itum1;
         #sentflg1 = $itflg1;
         #sentum2  = $itum2;
         #sentumq2 = $itumq2;
         if #sentumq2 <= 0;
            #sentumq2 = 1;
         endif;
         #sentflg2 = $itflg2;
         #sentum3  = $itum3;
         #sentumq3 = $itumq3;
         if #sentumq3 <= 0;
           #sentumq3 = 1;
         endif;

         // Get corresponding "slot" item

         driItem('%GETSLOT': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         #slotitem = $ititem;
         #slottype = $ittype;
         #slotdesc = $itdesc;
         #slotpdsc = $itpdsc;
         #slotwhdp = $itwhdp;
         #slotstyp = $itstyp;
         #slotdesg = $itdesg;
         #slotum1  = $itum1;
         #slotflg1 = $itflg1;
         #slotum2  = $itum2;
         #slotumq2 = $itumq2;
         if #slotumq2 <= 0;
           #slotumq2 = 1;
         endif;
         #slotflg2 = $itflg2;
         #slotum3  = $itum3;
         #slotumq3 = $itumq3;
         if #slotumq3 <= 0;
           #slotumq3 = 1;
         endif;
         #slotnrpk = $imnrpk;
         #slotflgd = $itflgd;
         #slotcube = $itcube;
         #slotswgt = $itswgt;
         #slotcwgt = $itcwgt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetORDD     Get ORDD record
     *----------------------------------------------------------------

      /free
       begsr GetORDD;

         chain (pWhse: pOrd: pOrgSeq: pOrgItem) ordd;
         if not %found(ordd);
           error = *on;
           pMessage = 'Error: Order Detail not found '
                    + '(' + %char(pWhse) + '/' + %char(pOrd) + '/'
                    + '(' + %char(pOrgSeq) + '/' + %trim(pOrgItem) + ')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetORDDsub   Get sub ORDD record
     *----------------------------------------------------------------

      /free
       begsr GetORDDsub;

         orddExists = *off;

         chain (pWhse: pOrd: pSubSeq: pSubItem) ordd;
         if %found(ordd);
           orddExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetORDH     Get ORDH record
     *----------------------------------------------------------------

      /free
       begsr GetORDH;

         chain (pWhse: pOrd) ordh;
         if not %found(ordh);
           error = *on;
           pMessage = 'Error: Order not found '
                    + '(' + %char(pWhse) + '/' + %char(pOrd) + ')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSectionCode   Get section code if original item found on plt
     *----------------------------------------------------------------

      /free
       begsr GetSectionCode;

         sectioncode = '';

         // Route must be in printed state

         if not rteprinted;
           leavesr;
         endif;

         setll (pWhse: rhrtid: pOrgItem) worklbl8;

         dow forever = forever;
           reade (pWhse: rhrtid: pOrgItem) worklbl8;
           if not %found(worklbl8);
             leave;
           endif;

           if lword <> ohord;
             iter;
           endif;

           if lwgen = 1
            or (lwgen = 2 and lwctr# <> 0);
              if lbhnd2 = '*P';
                sectioncode = 'A';
              else;
                sectioncode = lbhnd2;
              endif;
              leave;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRTEHED   Get RTEHED record
     *----------------------------------------------------------------

      /free
       begsr GetRTEHED;

         chain (pWhse: ohrte) rtehed;
         if not %found(rtehed);
           error = *on;
           pMessage = 'Error: Route not found '
                    + '(' + %char(pWhse) + '/' + %trim(ohrte) + ')';
           leavesr;
         endif;

         // Only allow subs for Open, Built and Printed routes

         if rhstat > '4';
           error = *on;
           pMessage = 'Error: '
                    + 'Route not open/built/printed '
                    + '(' + rhstat + ')';
           leavesr;
         endif;

         rteopen    = *off;
         rtebuilt   = *off;
         rteprinted = *off;

         select;
           when rhstat = '4';
             rteprinted = *on;
           when rhstat = '3';
             rtebuilt = *on;
           when rhstat = '1';
             rteopen = *on;
         endsl;

750 A     // Determine if using TruckBUilder Enhanced
750 A
750 A      GetTBType(rhwhse: rhrtid: tbType);
750 A      if tbType = 'E';
750 A        tbEnhanced = *on;
750 A        tbPalletType = 'P';
750 A      else;
750 A        tbEnhanced = *off;
750 A        tbPalletType = 'O';
750 A      endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSubOpt   Get Subtitution option
     *----------------------------------------------------------------

      /free
       begsr GetSubOpt;

         // First do standard check

         getitemsub ('*CHKALLOW': pWhse: pOrgItem: ohcust:
                     blank15: rtnCode: rtnMessage);

         if rtnCode = '*ERROR';
           error = *on;
           pMessage = rtnMessage;
           leavesr;
         endif;

         // Then do custom checks

         if client = Glazier;
           gfcmsc_base = ohmisc;
         else;
           dsmisc = ohmisc;
         endif;

         if (client = glazier and gfcmsc_sub <> 'Y')
           or (client = palmer and dssubf <> 'Y')
           or (client = kellys and dssubf <> 'Y')
           or (client = ifd and dssubf <> 'Y');
             error = *on;
             pMessage = 'Sub not allowed by Host '
                      + '(' + %char(pWhse) + '/' + %char(pOrd) + ')';
             leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *    Taken from RH182. Unnecessary code removed.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

530 A*    Do not allow user to enter the original item and u/m qty
530 A*     as the sub item and u/m qty.

530 A*  Compare orig item & u/m to sub item & u/m, throw error if equal.
530 AC                   select
530 AC                   when      oditem = w1itm
530 AC                   if        odqor1 > 0 and w1qor1 > 0
530 AC                             or
530 AC                             odqor2 > 0 and w1qor2 > 0
530 AC                             or
530 AC                             odqor3 > 0 and w1qor3 > 0
530 AC                   eval      error = *on
530 AC                   eval      pMessage = 'Error: ' + desc(7)
530 AC                   leavesr
530 AC                   endif
530 AC                   endsl

640hA*    Verify item substitute against ITEMSUB file.
640hA
640hAC                   eval      $cmd1 = '*VERIFY   '
640hAC                   eval      $whs30 = $pwhse
640hAC                   call      'GETITEMSUB'
640hAC                   parm                    $cmd1            10
640hAC                   parm                    $whs30            3 0
640hAC                   parm                    hld_$pitem
640hAC                   parm                    ohcust
640hAC                   parm                    w1itm
640hAC                   parm                    $prtn             8
640hAC                   parm                    $perm            60
640hAC                   if        $prtn = '*ERROR'
640hAC                   eval      error = *on
530 AC                   eval      pMessage = 'Error: ' + $perm
530 AC                   leavesr
640hAC                   endif

     *    Verify item number

     C**       Already done.

     *    Get corresponding "slot" item for "sent" item.

     C**       Already done.

     *    Make sure code doesn't already exist.

     C                   exsr      GetORDDsub
     C                   if        orddExists
     C                   eval      error = *on
     C                   eval      pMessage = 'Error: Order detail '
     C                                      + 'already exists'
530 AC                   leavesr
     C                   endif

510 A*   Get SSB item, if one exists

510 AC                   eval      SSBflag = *off
640aMC                   if        #senttype = 'S'
510 AC                   eval      SSBflag = *on
510 AC                   endif

     *    Verify original item number (optional)

     C***** Not necessary for this program

     *  Verify normal qty ordered is within range - optional.

     C                   if        w1qor1 < 0  or
     C                             w1qor1 > 99999
     C                   eval      error = *on
     C                   eval      pMessage = 'Error: Normal quantity '
     C                                      + 'out of range (0 - 99999)'
530 AC                   leavesr
     C                   endif

     *  Verify breakdown 1 qty ordered is within range - optional.

     C                   if        w1qor2 < 0  or
     C                             w1qor2 > 99999
     C                   eval      error = *on
     C                   eval      pMessage = 'Error: BrkDwn 1 quantity '
     C                                      + 'out of range (0 - 99999)'
530 AC                   leavesr
     C                   endif

     *  Verify breakdown 2 qty ordered is within range - optional.

     C                   if        w1qor3 < 0  or
640iDC**                           w1qor3 > 99999
640iMC                             w1qor3 > 9999
     C                   eval      error = *on
     C                   eval      pMessage = 'Error: BrkDwn 2 quantity '
     C                                      + 'out of range (0 - 9999)'
530 AC                   leavesr
     C                   endif

510 A*  Verify that a quantity was entered.

510 AC                   eval      totqty = w1qor1 + w1qor2 + w1qor3
510 AC                   if        totqty <= 0
510 AC                   eval      error = *on
     C                   eval      pMessage = 'Error: No quantity entered'
530 AC                   leavesr
510 AC                   endif

510 A*  Verify that brkdwn 1 qty is allowed.

510 AC                   if        w1qor2 <> 0 and
510 AC                             #sentflg1 = 'N'
510 AC                   eval      error = *on
     C                   eval      pMessage = 'Error: ' + desc(1)
530 AC                   leavesr
510 AC                   endif

510 A*  Verify that brkdwn 2 qty is allowed.

510 AC                   if        w1qor3 <> 0 and
510 AC                             #sentflg2 = 'N'
510 AC                   eval      error = *on
     C                   eval      pMessage = 'Error: ' + desc(2)
530 AC                   leavesr
510 AC                   endif

510 A*  Verify that brkdwn 1 qty is 0 if SSB item.

510 AC                   if        w1qor2 <> 0 and
510 AC                             SSBflag = *on
510 AC                   eval      error = *on
     C                   eval      pMessage = 'Error: ' + desc(3)
530 AC                   leavesr
510 AC                   endif

510 A*  Verify that brkdwn 2 qty is 0 if SSB item.

510 AC                   if        w1qor3 <> 0 and
510 AC                             SSBflag = *on
510 AC                   eval      error = *on
     C                   eval      pMessage = 'Error: ' + desc(4)
530 AC                   leavesr
510 AC                   endif

JORb *  Default slot to item pick slot for Jordano's
JORbAC***    Defaulted when GUI screen displayed.

     *  Verify slot number (only when rte at Built or Printed status).

     C                   if        rtebuilt or rteprinted

     C                   exsr      clr$slot

     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #sentwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

      /free

         $dridata = $slot;
         $dridata2 = $slot2;

         driSlot('%GET': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $slot = $dridata;
         $slot2 = $dridata2;

      /end-free

520cA*  When client is Outbound Only, still need DRICOP to go and get
520cA*  slot fields, but ignore any error conditions it comes back with,
520cA*  as the slot file for Outbound Only has no item data, etc.
520cA*  See next logic which only verifies dept and section.
     C                   if        $drireturn <> '*OK'
520cAC                             and opfeat <> '3'
520cAC                   eval      error =  *on
     C                   eval      pMessage = 'Error: Slot not found'
     C                                      + '(' + %trimr(pSubSlot) + ')'
530 AC                   leavesr
     C                   endif
     C                   endif

520cA*  When client is Outbound Only, verify that the slot entered is
520cA*  in the same dept/section as the sub item.

520cAC                   if        (rtebuilt or rteprinted) and opfeat = '3'

      /free
         chain ($pwhse: #sentwhdp: w1disp) slot2;
      /end-free

520cAC***  keysl         chain     slot2
520cAC                   if        not %found(slot2)  or
520cAC                             %found(slot2) and #sentstyp <> s_slstyp
520cAC                   eval      error = *on
     C                   eval      pMessage = 'Error: ' + desc(5)
530 AC                   leavesr
520cAC                   endif
520cAC                   endif

     *  Verify row/col exists (only when rte at Built or Printed status).

     C                   if        rtebuilt or rteprinted
750 DC*                  eval      kytype = 'O'
750 MC                   eval      kytype = tbPalletType
     C                   eval      kygen  = 1

      /free
         chain(n) ($pwhse: $prteid: kytype: kygen: w1row: w1col) pltsum2;
      /end-free

     C***  keyps2        chain(n)  pltsum2
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      pMessage = 'Error: Pallet not found '
530 AC                                      + '(' + %char(pSubPltId) + ')'
530 AC                   leavesr
     C                   endif
     C                   endif

     *  Verify printer device (only when rte at Built or Printed status).

     C*** Not necessary. Relying on dropdown selection from GUI screen.

     C     endck1        endsr

     *----------------------------------------------------------------
     *  zzgetdatetime  Get current date & time
     *----------------------------------------------------------------

     C     zzgetdatetime begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPDADD   Add record.
     *----------------------------------------------------------------

     C     zzupdadd      begsr

     *  Update slot quantity - only for Built and Printed routes.
520cA*  Do not update slot quantity for Outbound Only clients.

     *  This is done first because this has the biggest potential to have
     *  an error. Therefore, if an error occurs we can just get out and
     *  display it to the user without anything else haveing been created.

520cDC**                 if        rtebuilt or rteprinted
520cMC                   if        (rtebuilt or rteprinted)
520cAC                             and opfeat <> '3'
     C                   exsr      zzzupdslot
     C     error         cabeq     *on           endupdadd
     C                   endif

     *  Create order detail record.

     C                   exsr      zzzcrtordd
     C     error         cabeq     *on           endupdadd

510 A*  If route is at Open status, update RTESUM with detail
     *  record, then we're done so get out.

     C                   if        rteopen
750aAC                   if        %trim(pPgm) <> 'OR610'
510 AC                   exsr      zzzcalcopen
510 AC                   exsr      zzzupdrtesum
750aAc                   endif
     C                   goto      endupdadd
     C                   endif

     *  Calculate pieces, cube and weight totals.

     C                   exsr      zzzcalcttl
510 AC                   exsr      zzzupdrtesum

     *  When route is at Printed status, create a picking transaction.
510cM*  Update PLTSUM totals.

     C                   if        rteprinted
     C                   exsr      zzzcrttran
510cMC                   exsr      zzzupdpltsum
760bAC                   exsr      zzzupdpltmsc
     C                   endif

510cD*  Update PLTSUM totals.

510cDC**                 exsr      zzzupdpltsum

     *  Create label record(s).

     C                   exsr      zzzcrtworklbl

510 A*  Update RTECSUM records.

510 AC                   exsr      zzzupdrtecsum

     *  We're finished !!

     C     endupdadd     endsr

     *----------------------------------------------------------------
510 A*  ZZZCALCOPEN    Calculate open route totals.
     *----------------------------------------------------------------

510 AC     zzzcalcopen   begsr

510 A*  Total pieces.

510 AC                   eval      ttlpcs = pickqty1 + pickqty2 + pickqty3

510 A*  Total cube

510 AC                   eval      ttlcub = (#sentcube * pickqty1)
510 AC                                    + ((#sentcube/#sentumq2) * pickqty2)
510 AC                                    + (((#sentcube/#sentumq2)/#sentumq3)
510 AC                                         * pickqty3)

510 A*  Total weight

510 AC                   eval      ttlwgt = (#sentswgt * pickqty1)
510 AC                                    + ((#sentswgt/#sentumq2) * pickqty2)
510 AC                                    + (((#sentswgt/#sentumq2)/#sentumq3)
510 AC                                         * pickqty3)

510 AC                   endsr

     *----------------------------------------------------------------
     *  ZZZCALCTTL     Calculate totals.
     *----------------------------------------------------------------

     C     zzzcalcttl    begsr

     *  Total pieces.

     C                   eval      ttlpcs = pickqty1 + pickqty2 + pickqty3

     *  Total cube

     C                   eval      ttlcub = (#slotcube * pickqty1)
     C                                    + ((#slotcube/#slotumq2) * pickqty2)
     C                                    + (((#slotcube/#slotumq2)/#slotumq3)
     C                                         * pickqty3)

     *  Total weight

     C                   eval      ttlwgt = (#slotswgt * pickqty1)
     C                                    + ((#slotswgt/#slotumq2) * pickqty2)
     C                                    + (((#slotswgt/#slotumq2)/#slotumq3)
     C                                         * pickqty3)

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTORDD   Create order detail record.
     *----------------------------------------------------------------

     C     zzzcrtordd    begsr

     C                   eval      odwhse = $pwhse
     C                   eval      odord  = $pord
     C                   eval      odseq  = w1seq
     C                   eval      oditem = w1itm
     C                   eval      odoitm = w1oit
     C                   eval      odqor1 = w1qor1
     C                   eval      odqor2 = w1qor2
     C                   eval      odqor3 = w1qor3
     C                   eval      odwh2  = 0
CWDaA*
CWDaAC                   if        client = Cashwa
GFCbAC                             or client = Glazier
KFSbAC                             or client = Kellys
HKW AC                             or client = Hearnkirkwood
CWDaA*  Set line number of item being subbed into corresponding order#
CWDaA*  for processing at export time.
CWDbAC                   if        svor2 > 0
CWDbAC                   eval      odor2 = svor2
CWDbAC                   else
CWDaAC                   eval      odor2 = $pseq
CWDbAC                   endif
CWDaAC                   else
650cDC*                  eval      odor2  = 0
650cMC                   eval      odor2  = $pseq
CWDaAC                   endif
FRFbA*
FRFbAC                   if        client = FRF
FRFbA*  Set line number of item being subbed into corresponding order#
FRFbA*  for processing at export time.
FRFbAC                   eval      odor2 = $pseq
FRFbAC                   endif
FRFbA*
     C                   eval      odspcl = ' '
     C                   eval      odqpk1 = 0
     C                   eval      odqpk2 = 0
     C                   eval      odqpk3 = 0

     C                   if        rteopen
     C                   eval      odstat = 'O'
     C                   else
     C                   eval      odstat = 'P'
     C                   endif

     C                   write(e)  record
     C                   if        %error
     C                   eval      error = *on
     C                   eval      pMessage = 'Error writing new '
     C                                      + 'Order Detail rec ('
     C                                      + %char(odseq) + '/'
     C                                      + %trimR(oditem) + ')'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTLABEL  Create label record from WORKLBL record.
     *----------------------------------------------------------------

     C     zzzcrtlabel   begsr

     C                   clear                   lbrec

     C                   eval      lbwhse = lwwhse
     C                   eval      lbwhdp = lwwhdp
     C                   eval      lbseq  = lwseq
     C                   eval      lbitem = lwitem
     C                   eval      lbpbat = lwpbat
     C                   eval      lbaisl = lwaisl
     C                   eval      lbloc  = lwloc
     C                   eval      lbrlvl = lwrlvl
     C                   eval      lbhand = lwhand
     C                   eval      lbpseq = lwpseq
     C                   eval      lbstyp = lwstyp
     C                   eval      lbqryf = lwqryf
     C                   eval      lbdisp = lwdisp
     C                   eval      lbrte  = lwrte
     C                   eval      lbstop = lwstop
     C                   eval      lbord  = lword
     C                   eval      lbutyp = lwutyp
     C                   eval      lbucod = lwucod
     C                   eval      lbucub = lwucub
     C                   eval      lbcube = lwcube
     C                   eval      lbuwgt = lwuwgt
     C                   eval      lbswgt = lwswgt
     C                   eval      lbqalc = lwqalc
     C                   eval      lbqpck = lwqpck
     C                   eval      lbgrp1 = lwgrp1
     C                   eval      lbgrp2 = lwgrp2
     C                   eval      lbtype = lwtype
     C                   eval      lblbl# = lwlbl#
     C                   eval      lbpal# = lwpal#
     C                   eval      lbtrn# = lwtrn#
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = lwsdte
     C                   eval      lbstim = lwstim
     C                   eval      lbrdte = lwrdte

640dAC                   if        rteprinted
640dAC                   if        sectioncode <> *blanks
640dAC                   eval      lbhnd2 = sectioncode
640dAC                   endif
640dAC                   endif

     C                   write     lbrec

640dAC                   eval      sectioncode = *blanks

     C     endcrtlabel   endsr

640bA*----------------------------------------------------------------
640bA*  ZZZORDP  Create unique piece# record.
640bA*----------------------------------------------------------------
640bA
640bAC     zzzcrtordp    begsr
640bA

650aAC                   call      'OR637S'
650aAC                   parm                    lbwhse
650aAC                   parm                    lbrte
650aAC                   parm                    lblbl#

650aDC**                 clear                   orprec

650aD***       Initialize piece record fields.

650aDC**                 eval      orpwhs = lbwhse
650aDC**                 eval      orprid = lbrte
650aDC**                 eval      orpord = lbord
650aDC**                 eval      orpsq# = lbseq
650aDC**                 eval      orpitm = lbitem
650aDC**                 eval      orplbl = lblbl#
650aDC**                 eval      orpseq = 0
650aDC**                 eval      orpwgt = 0
650aDC**                 eval      orpcnt = 1
650aDC**                 eval      orpttl = 1
650aDC**                 eval      orpscn = lbqpck

650aD***       Create piece record.

650aDC**                 dow       forever = forever
650aDC**                 call      'PIRCADEC#'
650aDC**                 parm                    orpup#
650aDC**                 write(e)  orprec
650aDC**                 if        %error
650aDC**                 iter
650aDC**                 endif
650aDC**                 leave
650aDC**                 enddo

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTTRAN   Create transaction
     *----------------------------------------------------------------

     C     zzzcrttran    begsr

640iA* If RH182 was called by runner program RU310, create and start
640iA* the transaction, else, just create it.

640iAC                   if        $pcmd = '*SUBRUN '
640iAC                   eval      @pcmd = '*CRTSTRT'
640iAC                   else
640iAC                   eval      @pcmd = '*CREATE'
640iAC                   endif

     C                   call      'ADJTRAN2'
640iDC**                 parm      '*CREATE'     @pcmd            10
640iMC                   parm                    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'FIXED'       @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      #sentwhdp     @pwhdp            5
     C                   parm      #sentstyp     @pstyp            1
     C                   parm      ttlcub        @pcube            9 3
     C                   parm      ttlwgt        @pswgt            9 2
     C                   parm      ttlpcs        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $prteid       @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      rhtype        @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      pUser         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCRTWORKLBL   Create WORKLBL record(s)
     *----------------------------------------------------------------

     C     zzzcrtworklbl begsr

640 AC                   eval      $ptruk = pstruk
640 A*
640 A* Get Zone Template Code if Template type is T=Truck
640 A*
640 AC     trkey         chain     truckh
640 AC                   if        %found(truckh) and thtype = 'T'
640 AC                   eval      $ptmpl =  thztmp
640 AC                   else
640 AC                   eval      $ptmpl =  $ptruk
640 AC                   endif
     C                   exsr      zzgetdatetime

     *  Create WORKLBL record for Normal quantity.

     C     pickqty1      cable     0             brk1label

     C                   clear                   lwrec

     C                   eval      lwwhse = ohwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = pstruk
SLBaAC                   endsl
     C                   eval      lwcomp = pscomp
     C                   eval      lwtzon = pstzon
     C                   eval      lwpzon = pspzon
     C                   eval      lwszon = psszon
     C                   eval      lwgen  = psgen
     C                   eval      lwwhdp = $slwhdp
     C                   eval      lwseq  = w1seq
     C                   eval      lwitem = w1itm
     C                   eval      lwpbat = ohpbat
     C                   eval      lwaisl = $slaisl
     C                   eval      lwloc  = $slloc
     C                   eval      lwrlvl = $slrlvl
     C                   eval      lwhand = $slhand
     C                   eval      lwpseq = $slpseq
     C                   eval      lwstyp = $slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = $sldisp
     C                   eval      lwrte  = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword  = ohord
530aAC                   if        #senttype = 'S'
530aAC                   eval      lwutyp = '1'
530aAC                   eval      lwucod = #sentum2
530aAC                   else
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = #slotum1
530aAC                   endif
     C                   eval      lwucub = #slotcube
     C                   eval      lwcube = lwucub * pickqty1
510 DC**                 eval      lwuwgt = $itswgt
510 AC                   eval      lwuwgt = #slotswgt
     C                   eval      lwswgt = lwuwgt * pickqty1
     C                   eval      lwqalc = pickqty1
     C                   if        rteprinted
     C                   eval      lwqpck = pickqty1
     C                   endif
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = rhtype
     C                   eval      lwtype = 'O'
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   eval      lwpal# = psplid
     C                   if        rteprinted
     C                   eval      lwtrn# = @ptrn#
     C                   eval      lwstat = 'X'
     C                   else
     C                   eval      lwstat = 'B'
     C                   endif
     C                   eval      lwsdte = curdate
     C                   eval      lwstim = curtime
     C                   eval      lwrdte = curdate
     C                   write     lwrec

     *  Create LABEL record for Normal quantity for Printed routes.

     C                   if        rteprinted
     C                   exsr      zzzcrtlabel
640bAC                   exsr      zzzcrtordp
     C                   exsr      zzzprtlabel
     C                   endif

     C     brk1label     tag

     *  Create WORKLBL record for Beakdown 1 quantity.

     C     pickqty2      cable     0             brk2label

     C                   clear                   lwrec

     C                   eval      lwwhse = ohwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = pstruk
SLBaAC                   endsl
     C                   eval      lwcomp = pscomp
     C                   eval      lwtzon = pstzon
     C                   eval      lwpzon = pspzon
     C                   eval      lwszon = psszon
     C                   eval      lwgen  = psgen
     C                   eval      lwwhdp = $slwhdp
     C                   eval      lwseq  = w1seq
     C                   eval      lwitem = w1itm
     C                   eval      lwpbat = ohpbat
     C                   eval      lwaisl = $slaisl
     C                   eval      lwloc  = $slloc
     C                   eval      lwrlvl = $slrlvl
     C                   eval      lwhand = $slhand
     C                   eval      lwpseq = $slpseq
     C                   eval      lwstyp = $slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = $sldisp
     C                   eval      lwrte  = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword  = ohord
     C                   eval      lwutyp = '1'
     C                   eval      lwucod = #slotum2
640gAC                   if        SSBflag = *on
640gAC     itkey         chain     piritem
640gAC                   if        %found(piritem)
640gAC                             and itumq2 <> 0
640gAC                   eval      lwucub = itcube/itumq2
640gAC                   eval      lwcube = lwucub * pickqty2
640gAC                   eval      lwuwgt = itswgt/itumq2
640gAC                   eval      lwswgt = lwuwgt * pickqty2
640gAC                   endif
640gAC                   else
     C                   eval      lwucub = #slotcube/#slotumq2
     C                   eval      lwcube = lwucub * pickqty2
510 DC**                 eval      lwuwgt = $itswgt/#slotumq2
510 AC                   eval      lwuwgt = #slotswgt/#slotumq2
     C                   eval      lwswgt = lwuwgt * pickqty2
640gAC                   endif
     C                   eval      lwqalc = pickqty2
     C                   if        rteprinted
     C                   eval      lwqpck = pickqty2
     C                   endif
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = rhtype
     C                   eval      lwtype = 'O'
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   eval      lwpal# = psplid
     C                   if        rteprinted
     C                   eval      lwtrn# = @ptrn#
     C                   eval      lwstat = 'X'
     C                   else
     C                   eval      lwstat = 'B'
     C                   endif
     C                   eval      lwsdte = curdate
     C                   eval      lwstim = curtime
     C                   eval      lwrdte = curdate
     C                   write     lwrec

     *  Create LABEL record for Normal quantity for Printed routes.

     C                   if        rteprinted
     C                   exsr      zzzcrtlabel
640bAC                   exsr      zzzcrtordp
     C                   exsr      zzzprtlabel
     C                   endif

     C     brk2label     tag

     *  Create WORKLBL record for Beakdown 2 quantity.

     C     pickqty3      cable     0             endcrtworklbl

     C                   clear                   lwrec

     C                   eval      lwwhse = ohwhse
SLBaAC                   select
SLBaAC                   when      client = silberman
SLBaAC                   eval      lwtruk = $ptmpl
SLBaAC                   other
     C                   eval      lwtruk = pstruk
SLBaAC                   endsl
     C                   eval      lwcomp = pscomp
     C                   eval      lwtzon = pstzon
     C                   eval      lwpzon = pspzon
     C                   eval      lwszon = psszon
     C                   eval      lwgen  = psgen
     C                   eval      lwwhdp = $slwhdp
     C                   eval      lwseq  = w1seq
     C                   eval      lwitem = w1itm
     C                   eval      lwpbat = ohpbat
     C                   eval      lwaisl = $slaisl
     C                   eval      lwloc  = $slloc
     C                   eval      lwrlvl = $slrlvl
     C                   eval      lwhand = $slhand
     C                   eval      lwpseq = $slpseq
     C                   eval      lwstyp = $slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = $sldisp
     C                   eval      lwrte  = ohrte
     C                   eval      lwstop = ohstop
     C                   eval      lword  = ohord
     C                   eval      lwutyp = '2'
     C                   eval      lwucod = #slotum3
640gAC                   if        SSBflag = *on
640gAC     itkey         chain     piritem
640gAC                   if        %found(piritem)
640gAC                             and itumq2 <> 0
640gAC                             and itumq3 <> 0
640gAC                   eval      lwucub = (itcube/itumq2)/itumq3
640gAC                   eval      lwcube = lwucub * pickqty3
640gAC                   eval      lwuwgt = (itswgt/itumq2)/itumq3
640gAC                   eval      lwswgt = lwuwgt * pickqty3
640gAC                   endif
640gAC                   else
     C                   eval      lwucub = (#slotcube/#slotumq2)/#slotumq3
     C                   eval      lwcube = lwucub * pickqty3
     C                   eval      lwuwgt = (#slotswgt/#slotumq2)/#slotumq3
     C                   eval      lwswgt = lwuwgt * pickqty3
640gAC                   endif
     C                   eval      lwqalc = pickqty3
     C                   if        rteprinted
     C                   eval      lwqpck = pickqty3
     C                   endif
     C                   eval      lwgrp1 = 'S'
     C                   eval      lwgrp2 = rhtype
     C                   eval      lwtype = 'O'
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   eval      lwpal# = psplid
     C                   if        rteprinted
     C                   eval      lwtrn# = @ptrn#
     C                   eval      lwstat = 'X'
     C                   else
     C                   eval      lwstat = 'B'
     C                   endif
     C                   eval      lwsdte = curdate
     C                   eval      lwstim = curtime
     C                   eval      lwrdte = curdate
     C                   write     lwrec

     *  Create LABEL record for Normal quantity for Printed routes.

     C                   if        rteprinted
     C                   exsr      zzzcrtlabel
640bAC                   exsr      zzzcrtordp
     C                   exsr      zzzprtlabel
     C                   endif

     C     endcrtworklbl endsr

     *----------------------------------------------------------------
     *  ZZZPRTLABEL  Print label(s)
     *----------------------------------------------------------------

     C     zzzprtlabel   begsr

640 AC                   eval      $ptruk = pstruk
640 A*
640 A* Get Zone Template Code if Template type is T=Truck
640 A*
640 AC     trkey         chain     truckh
640 AC                   if        %found(truckh) and thtype = 'T'
640 AC                   eval      $ptmpl =  thztmp
640 AC                   else
640 AC                   eval      $ptmpl =  $ptruk
640 AC                   endif

     *  Get picking options for zone.

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz
510 DC**                 if        %eof
510 MC                   if        not %found(optionz)
     C     keyopz2       setll     optionz
     C     keyopz2       reade     optionz
     C                   if        %eof
     C                   eval      opclvl = 999
     C                   eval      opcwrb = 'N'
     C                   eval      opcwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      optext = ' '
     C                   eval      operr  = 0
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = ' '
     C                   eval      oppdev = ' '
     C                   eval      oppfrm = ' '
     C                   endif
     C                   endif

     *  Set device to what user entered.

     C                   eval      oppdev = w1dev
     C                   eval      oppfrm = '*STD'

     *  Call picking label program to print label(s).

     C                   movel     oplpgm        @pgm              4
     C                   move      oplpgm        @set              6

JORaAC                   if        client <> jordanos
FRFaAC                             and client <> FRF
510bA
     C                   call      'PFMT'
     C                   parm      '*PRTLBL'     $pfcmd            8
     C                   parm                    @set
     C                   parm                    $pffmt            8
     C                   parm                    lbwhse
     C                   parm                    lbrte
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opzdta
CLDbAC                   parm                    lbtrn#
     C                   parm                    lblbl#
CLDbAC                   parm                    lbqpck
CLDbAC                   parm      0             $xcwt             7 2
510bA
510bAC                   endif

     C                   endsr

760bA*----------------------------------------------------------------
760bA*  ZZZUPDPLTMSC   Update PLTMISC
760bA*----------------------------------------------------------------

760bAC     zzzupdpltmsc  begsr
760bA
760bAc                   if        not tbenhanced
760bAc                   leavesr
760bAc                   endif
760bA
760bAc                   monitor
760bAc                   call      'OR630ADB'
760bAc                   parm                    $pWhse
760bAc                   parm                    $pRteId
760bAc                   on-error
760bAc                   endmon
760bAC                   endsr

     *----------------------------------------------------------------
     *  ZZZUPDPLTSUM   Update PLTSUM totals.
     *----------------------------------------------------------------

     C     zzzupdpltsum  begsr

     *  Get PLTSUM record.

     C     keyps2        chain     pltsum2
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      pMessage = 'Error pallet summary '
     C                                      + 'record not found'
     C                   goto      endupdpltsum
     C                   endif

     *  Update Stop, if necessary.

     C                   if        ohstop < psstp1  or
     C                             psstp1 = 0
     C                   eval      psstp1 = ohstop
     C                   endif
     C                   if        ohstop > psstp2  or
     C                             psstp2 = 0
     C                   eval      psstp2 = ohstop
     C                   endif

     *  Update Pieces, Cube, Weight.

     C                   eval      pspcs  = pspcs + ttlpcs
     C                   eval      psswgt = psswgt + ttlwgt
     C                   eval      pscube = pscube + ttlcub

510cA*  Update bulk pick label, psflag.
     *  ????????????????????????????????
     *  DS - Won't this wipeout a bulk pick???
     *  ????????????????????????????????

510cAC                   eval      pslbl# = 0
510cAC                   eval      psflag = '1'

     *  Update Transaction number under certain conditions.
     *  ????????????????????????????????
     *  DS - So we create a second record if the existing
     *       record already has a tran#????
     *  ????????????????????????????????

510cDC***                if        rteprinted and pstrn# = 0
510cMC                   if        pstrn# = 0
     C                   eval      pstrn# = @ptrn#
510cM*  Update PLTSUM record.
510cMC                   update(e) psrec
510cMC                   if        %error
510cMC                   endif
510cAC                   else

510cDC***                update(e) psrec
510cDC***                if        %error
510cDC***                endif

750 A /free
750 A           // if tbEnhanced get next pallet id number for dd2
750 A           if tbEnhanced;
750 A             evalr oneChar = %editc(psplid:'X');
750 A             if oneChar = '9';
750 A               // keep using 9 if we have reached 9
750 A             else;
750 A               psplid = psplid + 1;
750 A             endif;
750 A           endif;
750 A /end-free
510cAC                   eval      pstrn# = @ptrn#
510cAC                   eval      pspcs  = ttlpcs
510cAC                   eval      psswgt = ttlwgt
510cAC                   eval      pscube = ttlcub
510cAC                   write     psrec
750 A /free
750 A           // if tbEnhanced update O record to reflect sub quantities
750 A           if tbEnhanced;
750 A             evalr oneChar = %editc(psplid:'X');
750 A             Oplid = psplid - %dec(onechar:1:0);
750 A             exec sql update pltsum15 set pspcs=pspcs+:ttlpcs,
750 A                                 pscube=pscube+:ttlcub,
750 A                                 psswgt=psswgt+:ttlwgt
750 A                   where pswhse=:pswhse and psrtid=:psrtid
750 A                     and psplid=:Oplid and pstype='O';
750 A           endif;
750 A /end-free
510cAC                   endif

510cAC                   unlock    pltsum2

     *  Update/Add PLTSTP record.

     C                   eval      kysbsq = 0
     C     keypss1       chain     pltstp1

     *    Record found - Update.

     C                   if        %found
     C                   eval      psspcs = psspcs + ttlpcs
     C                   eval      psscub = psscub + ttlcub
     C                   eval      pssswt = pssswt + ttlwgt
     C                   update    pssrec
     C                   if        %error
     C                   endif

     *    Record not found - Add.

     C                   else
     C                   eval      psswhs = pswhse
     C                   eval      pssrid = psrtid
     C                   eval      pssrow = psrow
     C                   eval      psscol = pscol
     C                   eval      pssstp = ohstop
     C                   eval      pssbsq = 0
     C                   eval      psspcs = ttlpcs
     C                   eval      psscub = ttlcub
     C                   eval      pssswt = ttlwgt
     C                   eval      psspli = psplid
     C                   write     pssrec
     C                   if        %error
     C                   endif

     C                   endif

     C     endupdpltsum  endsr

     *----------------------------------------------------------------
510 A*  ZZZUPDRTECSUM   Update RTECSUM records.
     *----------------------------------------------------------------

510 AC     zzzupdrtecsum begsr

510 AC                   call      'OR626'
640eDC**                 parm      '*REBUILD'    $pcmd2            8
640eMC                   parm      '*SUBITEM'    $pcmd2            8
510 AC                   parm                    $pbat             7 0
650dMC                   parm      $pwhse        $gwhse            3 0
510 AC                   parm                    $potype           1
510 AC                   parm                    $prteid
510 AC                   parm                    $truck           10
640eAC                   parm      psplid        $pplid            7 0
640eAC                   parm      pstrn#        $ptrn             7 0
510 AC                   endsr

     *----------------------------------------------------------------
510 A*  ZZZUPDRTESUM   Update RTESUM records.
     *----------------------------------------------------------------

510 AC     zzzupdrtesum  begsr

510 A*  Get RTESUM record.

510 AC     keyrs         chain     rtesum
510 AC                   if        not %found

510 AC                   eval      rswhse = $pwhse
510 AC                   eval      rsrtid = $prteid
510 AC                   eval      rswhdp = #sentwhdp
510 AC                   eval      rsordc = 0
510 AC                   eval      rsordw = 0
510 AC                   eval      rsordp = 0
510 AC                   eval      rsordc = rsordc + ttlcub
510 AC                   eval      rsordw = rsordw + ttlwgt
510 AC                   eval      rsordp = rsordp + ttlpcs
510 AC                   eval      rspckc = 0
510 AC                   eval      rspckw = 0
510 AC                   eval      rspckp = 0
640eAC                   if        rteprinted
640eAC                   eval      rspckc = rspckc + ttlcub
640eAC                   eval      rspckw = rspckw + ttlwgt
640eAC                   eval      rspckp = rspckp + ttlpcs
640eAC                   endif
510 AC                   write     rsrec

510 AC                   else

510 AC                   eval      rsordc = rsordc + ttlcub
510 AC                   eval      rsordw = rsordw + ttlwgt
510 AC                   eval      rsordp = rsordp + ttlpcs
640eAC                   if        rteprinted
640eAC                   eval      rspckc = rspckc + ttlcub
640eAC                   eval      rspckw = rspckw + ttlwgt
640eAC                   eval      rspckp = rspckp + ttlpcs
640eAC                   endif
510 AC                   update    rsrec

510 AC                   endif

510 AC                   endsr

     *----------------------------------------------------------------
     *  ZZZUPDSLOT    Update slot quantity.
     *----------------------------------------------------------------

     C     zzzupdslot    begsr

     *  Note: All of the slot fields should contain the proper information
     *  because the slot was verified in ZZCHK1. Just make sure that all of
     *  the necessary field usage flags are set *on.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhdpu = *on

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1itm
     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = w1qor1
     C                   eval      $saqty2  = w1qor2
     C                   eval      $saqty3  = w1qor3

     *  Allocate the qty for a Built route.
     *  Pick the qty for a Printed route.

     C                   eval      $dricommand = '*SLOT'

     C                   if        rteprinted
     C                   eval      $drisubcmd  = '%PICK'
     C                   else
     C                   eval      $drisubcmd  = '%ALLOCATE'
     C                   endif

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
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C***                eval      errmsg    = 'Error occured on call to '
     C***                                    + 'DRICOP'
     C***                                    + '/' + %trim($drisubcmd)
     C***                                    + ' from ' + #pgm
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C***                exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C                   if        $dricommand = '*SLOT'
     C                             and $drireturn = 'EOF'
     C                   eval      $drimessage = 'Pick slot not found for item'
     C                   endif

520cA*  If Outbound Only, do not load SLOT $drimessage into msgrec subfile.
520cAC                   if        $dricommand = '*SLOT' and opfeat = '3'
520cAC                   else
     C***                exsr      zm0001
520cAC                   endif
     C*                  exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C     enddricop     endsr
     O*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*----------------------------------------------------------------
**
BrkDwn 1 Qty Ordered not allowed for this item.        1
Brkdwn 2 Qty Ordered not allowed for this item.        2
BrkDwn 1 Qty Ordered not allowed for SSB item.         3
Brkdwn 2 Qty Ordered not allowed for SSB item.         4
Slot dept/section is different from the item.          5
Original item not found in order detail file.          6             530
Cannot sub same item and same u/m as original.         7             530
