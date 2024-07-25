      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  OR625     Truck build - Assign pallet sections to items
     *  23 March 2000
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    07/01/02  MLB  4.16
     *      - Revised ASGNID to load current pallet section when
     *        section is overflowed.  Corrected cube calculation.
     *
500 A*    04/11/05  MLB  5.00
     *      - Enh: Revised program to write records to new file when
     *        quantity picked doesn't fit all in one section on pallet.
     *        Added file LABELPS.
500aA*    04/21/05  MLB  5.00a
     *      - Enh: Added "client" logic.
500bA*    04/28/05  MLB  5.00b
     *      - Revised routine ASSIGN to update label record with
     *        next pallet section if LBQPCK = 1.
530a *    04/13/10  GJA/JJ  5.30a
     *      - Revised routine to exclude bulk picks with no trans
640a *    05/09/12  GJA  6.40a
     *      - Enh:  Add LABEL13S to assign pallet zone by display
     *              instead of item number.
650aA*    02/17/14  JCJ  650a
     *      - Enh: Changed the section code from Alpha to Numeric in
     *        subroutine ZZBKDN.
700a *    04/11/16  RTR  700a
     *      - Fix: Changed divide to handle cube of zero.
710a *    06/07/17  LML  710a
     *      - Enh: We have added the ability to set the number
     *        of pallet sections at the zone.
     *        If the zone *PICK record has a qty in field opnbps
     *        this field overrides what is setup in *GENPICK opnrsc.
720a *    03/26/18  RTR  720a
     *      - Fix: problem with 710a when sections=0, was dividing by
     *        zero. Put safety check before dividing.
720b *    09/11/18  DAS  720b
     *      - Revised to use PSTYPE='P' for TruckBuilder Enhanced.
730aA*    09/19/19  MLB  7.30a
     *      - Fix: Changed divide to handle cube of zero in ZZBKDN.
750aA*    10/12/21  JCJ  7.50a
     *      - Revised to use Letters for Pallet ID & Numbers for
     *        Pallet sections.
     *        For clients that use both Pallet ID and Pallet sections
     *        it will look like 'A1' 'A2' 'B1' B2', Otherwise
     *        they will look like ' 1' ' 2' ' 3' ' 4'.
     *        These codes can be found in LABEL file (LBHND2).
     *        However if there is '*P' in the LBHND2 field the codes
     *        will be in the LABELPS file field LSSCID.
     *        Jake's is the only exception.  Jake's only uses
     *        Pallet ID and it is stored in the LBDSP2 field.
     *        Since they do not use BFC pick Labels and there was
     *        not sufficant time to change the PFILES interface.
750bA*    10/21/21  KDE  7.50b
     *      - Revised to exclude pltsum records with zero Transaction
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
CTY A*    04/02/04  DAS  CTY
     *      - Revised program to add option to assign section
     *        identifiers in sequential order.
     *        Ex: When 2 pallet sections are defined and 2 pallets
     *            are being picked at once, pallet 1 will have
     *            identifiers A and B and pallet 2 will have C and D.
     *      - Revised to only assign id's to generation 1 pallets.
CTYaA*    04/21/05  MLB  CTYa
     *      - Revised program to remove 10% pad added to pallet
     *        cube calculations.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    01/01/09  MLB  VIP
     *      - Revised program to assign stops to sections on the
     *        pallet. To do this, the pgm will read the PLTSTP1 file
     *        to accumulate total stops on pallet. Next, the pgm will
     *        divide the total stops by number of pallet sections.
     *        This will give us stops per pallet section to assign.
     *      - Added file PLTSTP1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas
     *
NCSaA*    06/24/11  JCJ  NCSa
     *      - Enh: Add A/B pallet indicator.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River
     *
FRFaA*    01/30/14  JCJ  FRFa
     *      - Enh: Add A/B pallet code.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee
     *
ELBaA*    02/29/14  JCJ  ELBa
     *      - Enh: Add A/B pallet code.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer
     *
FSHaA*    08/20/14  JCJ  FSHa
     *      - Revised program to remove 10% pad added to pallet
     *        cube calculations.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: US Foods
     *
USFoA*    12/22/20  KDE  USFo
     *      - Revised program to use different pallet section code
     *        when sections exceed 3
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jakes Foods
     *
JFF A*    05/22/18  MLB  JFF
     *      - Enh: Add A/B pallet code.
     *      - Added JFF to FRFa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco
     *
GRCaA*    11/05/18  JCJ  GRCa
     *      - Enh: Add A/B pallet indicator.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jakes Foods
     *
PFCaA*    10/14/21  JCJ  PFCa
     *      - Enh: Add A/B pallet code.
     *
     *----------------------------------------------------------------
     * Notes:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
VIP A*  76        EOF on read to PLTSTP1
     *  79        Chain indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   if   e           k disk    rename(psrec:psrec3)
NCSaAFpltsum4   if   e           k disk
NCSaAF                                     rename(psrec:psrec4)
NCSaAF                                     prefix(PS4)
VIP  Fpltstp1   if   e           k disk
640aDF*****Label13   uf   e           k disk    rename(lbrec:lbrec3)
640aMFLabel13s  uf   e           k disk    rename(lbrec:lbrec3)
FRFaAFlabel90   uf   e           k disk    rename(lbrec:lbrec9)
FRFaAF                                     prefix('A')
     Foptions   if   e           k disk
710aAFoptionz   if   e           k disk
710aAFtruckh    if   e           k disk
500 AFLabelps   o    e             disk
500aA*
500aA*----------------------------------------------------------------
500aA*  Client id's for custom mods.
500aA*----------------------------------------------------------------
500aA*
CTYaA /COPY QCOPYSRC,ID#CITYLIN
VIP A /COPY QCOPYSRC,ID#VIP
FSHaA /COPY QCOPYSRC,ID#FISCHER
NCSaA /copy qcopysrc,id#nichola
FRFaA /copy qcopysrc,id#frf
ELBaA /copy qcopysrc,id#ellenbe
HMWaA /copy qcopysrc,id#hmwagne
GRCaA /copy qcopysrc,id#grc
JFF A /copy qcopysrc,id#jff
PFCaA /copy qcopysrc,id#pfc
     *----------------------------------------------------------------
     *  Customer id
500gA*
500gaD                 ds
500gAD  client                 1     10
500gAD  cliloc                11     20
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *  Pallet section id's.
     *
     D                 ds
750aMD  sctid1                 1      1
750aMD  sctid2                 2      2
750aMD  sctid3                 3      3
750aMD  sctid4                 4      4
750aMD  sctid5                 5      5
750aMD  sctid6                 6      6
750aMD  sctid7                 7      7
750aMD  sctid8                 8      8
750aMD  sctid9                 9      9
750aMD  scid                   1      9
     D                                     DIM(9)
     *----------------------------------------------------------------
     *  Pallet section build work fields.
     *
     D psctds          ds
     D  psct1                  1      9  3
     D  psct2                 10     18  3
     D  psct3                 19     27  3
     D  psct4                 28     36  3
     D  psct5                 37     45  3
     D  psct6                 46     54  3
     D  psct7                 55     63  3
     D  psct8                 64     72  3
     D  psct9                 73     81  3
     D  psct                   1     81  3
     D                                     DIM(9)
500aA*
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
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  optend               117    117
710aA*----------------------------------------------------------------
710aA*  *PICK  -  Picking options
710aA*
710aA*----------------------------------------------------------------
710aA*
710aA* Fields
710aA*
710aA*    OPNXTP  -  Next pallet number.
710aA*    OPBPCK  -  Bulk pick definition.
710aA*    OPPCUB  -  Maximum cube for PIR.
710aA*    OPFPAL  -  Pallets on fixed fork lift.
710aA*    OPFCUB  -  Maximum cube per fixed pallet.
710aA*    OPFSTP  -  Maximum stops per fixed pallet.
710aA*    OPINCL  -  Include PIR in fixed cube.
710aA*    OPSRCH  -  Number of previous pallets to search for space.
710aA*    OPFBLD  -  Fixed pallet building method.
710aA*                1 = By piece without concern for splitting stop.
710aA*                2 = By stop without splitting stop between plts.
710aA*    OPPBRK  -  Aisle to start new pallet.
710aA*    OPPBLD  -  Pallet building method.
710aA*                1 = By stop then slot location.
710aA*                2 = By slot location then stop.
710aA*    OPSELM  -  Selection method.
710aA*                1 = Single pass (By location).
710aA*                2 = Multiple pass (By stop).
710aA*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
710aA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
710aA*    OPNWPL  -  Start new pallet when aisle changes if build method
710aA*               is 2=Location.
710aA*    OPFORD  -  Maximun orders per pallet.
710aA*    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
710aA*    OPFTOT  -  Maximum totes per pallet.
710aA*    OPTECB  -  External tote cube.
710aA*    OPTICB  -  Internal tote cube.
710aA*    OPTSTP  -  Maximum stops per tote.
710aA*    OPTPCS  -  Maximum pieces per tote.
710aA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
710aA*    OPGCDE  -  USF Group Code (0-9).
710aA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
710aA*    OPSPAL  -  Merge pallet should only contain
710aA*               items for single truck pallet (Y=Yes, N=No).
710aA*    OPLBL   -  Label printing method.
710aA*                N = Normal
710aA*                S = Side by side
710aA*
710aA* Data structure
710aA*
710aAD opzdta          ds
710aAD  opnxtp                 1      7  0 inz(0)
710aAD  oppcub                10     14  2 inz(0)
710aAD  opfpal                15     15  0 inz(0)
710aAD  opfcub                16     20  2 inz(0)
710aAD  opincl                22     22
710aAD  opsrch                23     24  0 inz(0)
710aAD  opfstp                25     26  0 inz(0)
710aAD  opfbld                27     27  0 inz(0)
710aAD  opbpck                28     30  0 inz(0)
710aAD  oppbrk                31     33
710aAD  oppbld                34     34
710aAD  opselm                35     35
710aAD  opsplt                36     36
710aAD  opbmrg                37     37
710aAD  opnwpl                38     38
710aAD  opford                39     40  0 inz(0)
710aAD  opptyp                41     41
710aAD  opftot                42     43  0 inz(0)
710aAD  optecb                44     48  2 inz(0)
710aAD  opticb                49     53  2 inz(0)
710aAD  optstp                54     55  0 inz(0)
710aAD  optord                56     57  0 inz(0)
710aAD  optpcs                58     60  0 inz(0)
710aAD  opstop                61     61
710aA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
710aAD**opgcde                62     62
710aAD  oppkup                62     62
710aAD  opspal                63     63
710aAD  oplbl                 68     68
710aAD  opnbps                77     77  0 inz(0)
710aAD  opnbpsalpha           77     77
710aAD  opdend               117    117
     *----------------------------------------------------------------
     * Variable
     *----------------------------------------------------------------
     D tlstp           s              5  0
     D stpsct          s              5  0
710aAD GotTruckH       s               n
     D hldstp          s              5  0
     D forevr          s              1
     D l2              s              3  0
     D n               s              3  0
     D offset          s              3  0
     D p               s              3  0
     D pcs             s              7  0
     D pltful          s              1
     D p2              s              3  0
     D qycrs2          s              7  0
     D qycurs          s              7  0
     D seqord          s              1
     D kytype          s                   like(pstype)
     D kycode          s                   like(opcode)
710aAD keycde          s                   like(opzcod)
     D l               s                   like(opnrsc)
710aAD NbrOfPalSec     s                   like(opnrsc)
     D sctcub          s                   like(pscube)
     D tstcub          s                   like(pscube)
VIP AD tststp          s                   like(pscube)
     D cubovr          s                   like(pscube)
VIP AD stpovr          s                   like(pscube)
     D newcub          s                   like(pscube)
     D cubavl          s                   like(pscube)
     D curtrn          s                   like(pstrn#)
NCSaAD i               s              2  0
FRFaAD j               s              2  0
NCSaAD palletcount     s              2  0
FRFaAD svplid          s                   like(psplid)
710aAD savepstzon      s                   like(pstzon)
FRFaAD prvtrn          s                   like(pstrn#)
720bAd tbEnhanced      s               n
720dAd tbPalletType    s              1
720bAd tbType          s              1
720bAd tbWhse          s              3  0
750aAd svhnd2          s              2

NCSaA*----------------------------------------------------------------
NCSaA*  Pallet array
NCSaA*
FRFaAD letterAry       s              1    dim(9)  ctdata perrcd(1)

NCSaAD palletAry       s             19    dim(9) DESCEND
NCSaAD
NCSaAD palletAryFld    ds
NCSaAD  palNum                        7s 0
NCSaAD  palId                         7s 0
NCSaMD  toStop                        2s 0
NCSaAD  fromStop                      2s 0
NCSaAD  letter                        1

FRFaAD palletAry2      s             30    dim(9) ASCEND
FRFaAD
FRFaAD palletAryFld2   ds
FRFaAD  palNum2                       7s 0
FRFaAD  palId2                        7s 0
FRFaMD  toStop2                       4s 0
FRFaAD  fromStop2                     4s 0
FRFaAD  letter2                       1
FRFaAD  transaction                   7s 0

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PTRUK  Truck
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     C                   parm                    $ptruk           10
     *----------------------------------------------------------------
     *  Main line
     *
CTY AC                   eval      curtrn = *loval
CTY A*
CTY A*  Hard code sequential order option.
CTY A*
CTY AC                   eval      seqord = 'Y'
     *
s1   C                   select
     *
     *    Number of pallet sections greater than 1,  assisgn pallet
     *    sections to items.
     *    With the ability to set the sections by zone. We will
     *    execute this code on opnrsc >=1
     *
710aMC                   when      opnrsc >= 1
     *
     *    Loop if no normal, merge or bulk label records exist for zone.
     *
720bMC                   eval      kytype = tbPalletType
     C     keyps3        setll     pltsum3
d1   C                   dow       forevr = forevr
     C     keyps3        reade     pltsum3                              7879
710aAc                   if        *in79 = *on
710aAc                   leave
710aAc                   endif
710aA*
710aA*    Get the TRUCKH record to identify the template
710aA*
710aA /free
710aA   if GotTruckh = *off;
710aA     chain (pswhse: pstruk) truckh;
710aA     if %found(truckh);
710aA       keycde = '*PICK';
710aA       GotTruckH = *on;
710aA     else;
710aA       NbrOfPalSec = 1;
710aA       thztmp = ' ';
710aA     endif;
710aA   endif;
710aA /end-free
710aA*
710aA*    Get the *PICK optionz Record for number of pallet sections  e.
710aA*
710aA /free
710aA   if savepstzon <> pstzon;
710aA     chain (keycde: pswhse: thztmp: pstzon) optionz;
710aA     if %found(optionz);
710aA       if opnbpsalpha  = ' ';
710aA         opnbps = 0;
710aA       endif;
710aA       if opnbps > 0;
710aA         NbrOfPalSec = opnbps;
710aA       else;
710aA         NbrOfPalSec = opnrsc;
710aA       endif;
710aA       l = NbrOfPalSec;
710aA       savepstzon = pstzon;
710aA     endif;
710aA   endif;
710aA /end-free
s2   C                   select
     *
     C                   when      *in78 = *on
     C                             or pspcs = 0
CTY AC                             or psgen > 1
530aAC                             or pstrn# = 0
750bDC*                            and psbcnt >= 1
750bDC*                            and not tbEnhanced
     C                   iter
NCSaA*
NCSaAC                   when      client = nicholas
710aMC                             and NbrOfPalSec = 1
NCSaAC                   exsr      snglepltsect2
FRFaA*
FRFaAC                   when      client = frf
710aMC                             and NbrOfPalSec >= 1

ELBaAC                             or client = ellenbee
710aMC                             and NbrOfPalSec >= 1

GRCaAC                             or client = greco
GRCaMC                             and NbrOfPalSec >= 1

JFF AC                             or client = jakes
JFF AC                             and NbrOfPalSec >= 1

PFC AC                             or client = presto
PFC AC                             and NbrOfPalSec >= 1

FRFaAC                   if        pstrn# = prvtrn
FRFaAC                   iter
FRFaAC                   else
FRFaAC                   exsr      loadpalletary
FRFaAC                   eval      prvtrn = pstrn#
FRFaAC                   endif
     *
710aAC                   when      NbrOfPalSec = 1
710aAC                   iter
     *
s2   C                   other
     *
CTY AC                   if        seqord = 'Y'  and
CTYaMC                             pstrn# = curtrn
710aMC                   eval      offset = NbrOfPalSec
CTY AC                   else
CTY AC                   eval      offset = 0
CTY AC                   eval      curtrn = pstrn#
CTY AC                   endif
     *
     C                   eval      psctds = *zeros
     C                   eval      pltful = *off
VIP A*
VIP A*    Find total number of stops on pallet.
VIP AC                   if        client = vip
VIP A*
VIP AC                   eval      tlstp = *zeros
VIP AC     keypss        setll     pltstp1
VIP AC                   dow       forevr = forevr
VIP AC     keypss        reade     pltstp1                                76
VIP AC                   if        *in76
VIP AC                   leave
VIP AC                   endif
VIP AC     tlstp         add       1             tlstp
VIP AC                   enddo
VIP A*
VIP A*    Compute stops per section for assignment.
720aAC                   if        NbrOfPalSec = 0
720aAC                   eval      NbrOfPalSec = 1
720aAC                   endif
710aDC*    tlstp         div       opnrsc        stpsct
710aMC     tlstp         div       NbrOfPalSec   stpsct
VIP AC                   if        stpsct <= 0
VIP AC                   eval      stpsct = 1
VIP AC                   endif
VIP AC                   move      *loval        hldstp
VIP A*
VIP AC                   endif
     *
     *    Calculate cube for each pallet section including
     *    a 10 % pad.
     *
CTYaA*    Don't add 10% pad to pallet cube.
CTYaAC                   if        client = cityln
FSHaAC                             or client = fischr
USFoAc                             or client = 'BFCKEN'
CTYaAC                   eval      newcub = pscube
CTYaAC                   else
     C     pscube        mult      1.1           newcub
CTYaAC                   endif
720aAC                   if        NbrOfPalSec = 0
720aAC                   eval      NbrOfPalSec = 1
720aAC                   endif
USFoA /free
USFoA                    if NbrOfPalSec > 3
USFoA                       and client = 'BFCKEN';
USFoA                    sctcub = psmaxc / (NbrOfPalSec-1);
USFoA /end-free
USFoAc                   else
710aMC     newcub        div(h)    NbrOfPalSec   sctcub
USFoAc                   endif
     *
640aMC     keylb3        setll     label13s
USFoAc                   if        client='BFCKEN'
USFoAc                              and nbrofpalsec>3
USFoAc                   eval      p=1
USFoQc                   endif
d2   C                   dow       forevr = forevr
640aMC     keylb3        reade     label13s                               77
s3   C                   select
     C                   when      *in77 = *on
     C                   leave
     *
     C                   when      lbqpck <= *zeros
     C                             or lbtype <> 'O'
     C                             and lbtype <> 'M'
     C                   iter
     *
     C                   other
     *
VIP AC                   if        client = vip
VIP A*
VIP AC                   exsr      asnstp
VIP A*
VIP AC                   else
VIP A*
     C                   exsr      asgnid
VIP A*
VIP AC                   endif
VIP A*
     C                   endsl
     C                   enddo
     *
     C                   endsl
     C                   enddo
     C                   endsl
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
500aA*
500aA* Get client id
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client
500aA*
720bMc*
720bMc*   Determine if using TruckBUilder Enhanced
720bMc*
720bA /free
720bA      tbWhse = $pwhse;
720bA      GetTBType(tbWhse: $prtid: tbType);
720bA      if tbType = 'E';
720bA        tbEnhanced = *on;
720bA        tbPalletType = 'P';
720bA      else;
720bA        tbEnhanced = *off;
720bA        tbPalletType = 'O';
720ba      endif;
720bA /end-free
     C                   eval      forevr = *off
     C                   eval      pltful = *off
     C                   eval      psctds = *zeros
     C                   eval      p = *zeros
     C                   eval      n = *zeros
CTY AC                   eval      p2 = *zeros
CTY AC                   eval      l2 = *zeros
CTY AC                   eval      offset = *zeros
500 AC                   eval      qycurs = *zeros
500 AC                   eval      qycrs2 = *zeros
500 AC                   eval      pcs = *zeros
     *
     *  Define partial key for LABEL13 file.
     *
     C     keylb3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     *
     C     keylb3b       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    palid2
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps4        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
NCSaA*
NCSaA*  Define partial key for PLTSUM4 file.
NCSaA*
NCSaAC     ps4key        klist
NCSaAC                   kfld                    pstrn#
VIP A*
VIP A*  Define partial key for PLTSTP1 file.
VIP A*
VIP AC     keypss        klist
VIP AC                   kfld                    $pwhse
VIP AC                   kfld                    $prtid
VIP AC                   kfld                    psplid
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    kycode

FRFaA*  Define key for LABEL90 file.

FRFaAC     keylbl90      klist
FRFaAC                   kfld                    $pwhse
FRFaAC                   kfld                    transaction

     *
     *  Define variables.
     *
     *
     *    Get general picking options from OPTIONS file.
     *
     C                   eval      kycode = '*GENPICK'
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      operpt = 'Y'
     C                   eval      opelbl = 'N'
     C                   eval      opnrsc = 1
     C                   endif
     C                   eval      l = opnrsc
     *
     *    Load default section id's into array if number of sections
     *    per pallet is greater than one.
710aA*    Load the default section in all cases.
     *
710aDC*                  if        opnrsc > 1
710aDC*                            or client = nicholas
710aDC*                            and opnrsc >= 1
     C     1             do        9             p
     C                   select
     C                   when      p = 1
750AMC                   eval      scid(p) = '1'
     *
     C                   when      p = 2
750AMC                   eval      scid(p) = '2'
     *
     C                   when      p = 3
750AMC                   eval      scid(p) = '3'
     *
     C                   when      p = 4
750AMC                   eval      scid(p) = '4'
     *
     C                   when      p = 5
750AMC                   eval      scid(p) = '5'
     *
     C                   when      p = 6
750AMC                   eval      scid(p) = '6'
     *
     C                   when      p = 7
750AMC                   eval      scid(p) = '7'
     *
     C                   when      p = 8
750AMC                   eval      scid(p) = '8'
     *
     C                   when      p = 9
750AMC                   eval      scid(p) = '9'
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ASGNT3  Assign pallet section when section count greater than 3
     *          This routine is called when sections overridden beyond 3 sectio
     *          and current section will overflow with next label
     *
USFoAC     asgngt3       begsr
      /free
                     if p<1;
                       p=1;
                     endif;
                     if p>nbrofpalsec;
                       p=nbrofpalsec;
                     endif;
                     select;
                       when (psct(p) + lbcube) > sctcub;
                         // When lbcube plus section is greater than section
                         // cube we and current section is empty we will force
                         // into that section and move to next section for
                         // next label
                         if psct(p) = *zeros;
                            psct(p) = lbcube;
                            lbhnd2 = scid(p);
                            exsr zzupd;
                            p = p + 1;
                            if p > NbrOfPalSec;
                              p = NbrOfPalSec;
                            endif;
                         else;
                          // if the current section already has something,
                          // we will force current label to next section
                          // since it is overflowing the current section
                            p = p + 1;
                            if p > NbrOfPalSec;
                              p = NbrOfPalSec;
                            endif;
                            psct(p) = psct(p) + lbcube;
                            lbhnd2 = scid(p);
                            exsr zzupd;
                         endif;
                       when (psct(p) + lbcube) = sctcub;
                          // when current label plus current section total
                          // equals section cube we should simply update
                          // to that section
                          psct(p) = lbcube;
                          lbhnd2 = scid(p);
                          exsr zzupd;
                          p = p + 1;
                          if p > NbrOfPalSec;
                            p = NbrOfPalSec;
                          endif;
                       other;
                         // otherwise, this means current section cube plus
                         // current label is less so we should simply update
                         // to current section
                         if (psct(p) + lbcube) < sctcub;
                            psct(p) = lbcube;
                            lbhnd2 = scid(p);
                            exsr zzupd;
                         endif;
                     endsl;
      /end-free
USFoAC                   endsr
     *----------------------------------------------------------------
     *
     *  ASGNID  Assign pallet section id
     *
     C     asgnid        begsr
USFoAc*  If US Foods and Pallet Sections greater than 6 call
USFoAc*  different logic to assign pallet section id
USFoAc                   if        client='BFCKEN'
USFoAc                              and NbrOfPalSec > 3
USFoAc                   exsr      AsgnGt3
USFoAc                   leavesr
USFoAc                   endif
     *
     C                   select
     *
     *    All sections on the pallet have been filled, assign
     *    the last position to all other items on this pallet.
     *
     C                   when      pltful = *on
HMWaAC                   select
HMWaAC                   when      client = frf
FRFaAC                   eval      lbhnd2 = %char(l2)
HMWaMC                   other
750aD *                  eval      lbhnd2 = scid(l2)
750aMC                   eval      lbhnd2 = %replace((scid(l2)
750aMC                             ):lbhnd2:2:1)
HMWaMC                   endsl
     C                   exsr      zzupd
     *
     C                   other
     *
     *    There is room on the pallet, assign section id to item.
     *
710aMC     NbrOfPalSec   add       offset        l2
CTY AC                   if        l2 > 9
CTY AC                   eval      l2 = 9
CTY AC                   endif
     *
     C                   eval      cubovr = *zeros
710aMC     1             do        NbrOfPalSec   p
     *
CTY AC     p             add       offset        p2
CTY AC                   if        p2 > 9
CTY AC                   eval      p2 = 9
CTY AC                   endif
     *
     C     psct(p)       add       lbcube        tstcub
     *
     C                   select
     *
     *    This section is full and not the last section on the pallet.
     *    Loop again and try next section.
     *
     C                   when      psct(p) = sctcub
710aMC                             and p < NbrOfPalSec
     C                   iter
     *
     *    This section has room for the item.
     *
     C                   when      tstcub <= sctcub
     C                   add       lbcube        psct(p)
FRFaD*
FRFaD*   Assign leter A/B section of a pallet
FRFaD*
HMWaAC                   select
HMWaAC                   when      client = frf
JFF A **                           or client = jakes
FRFaAC                   eval      lbhnd2 = %char(p2)
HMWaMC                   other
750aD *                  eval      lbhnd2 = scid(l2)
750aMC                   eval      lbhnd2 = %replace((scid(l2)
750aMC                             ):lbhnd2:2:1)
HMWaMC                   endsl
     C                   exsr      zzupd
     C                   leave
     *
     *    This section has overflowed,  calculate amount extra
     *    in the section and attempt to add to next section on
     *    pallet if one exists.  If no sections available then
     *    assign item to last section on pallet.
     *
     C                   when      tstcub > sctcub
     C     p             add       1             n
     *    Assign item to next section on pallet.
710aMC                   if        n <= NbrOfPalSec
500 A*    Compute cube available in current section of pallet.
500 AC     sctcub        sub       psct(p)       cubavl
500 A*
     C     psct(p)       add       lbcube        psct(p)
     C     psct(p)       sub       sctcub        cubovr
     C                   eval      psct(p) = psct(p) - cubovr
416 MC                   add       cubovr        psct(n)
500bA*    Single case being processed. See where it fits without
500bA*    treating pick as Split Case.
500bAC                   if        lbqpck = 1
500bA*    Compute qty that will fit in current section.
700aAC                   if        lbucub = 0
700aAC                   eval      qycurs = cubavl
700aAC                   else
500bAC     cubavl        div(h)    lbucub        qycurs
700aAC                   endif
500bA*    Case fits in current section.
500bAC                   if        qycurs >= 1
FRFaD*
FRFaD*   Assign leter A/B section of a pallet
FRFaD*
HMWaAC                   select
HMWaAC                   when      client = frf
JFF A **                           or client = jakes
FRFaAC                   eval      lbhnd2 = %char(p2)
HMWaMC                   other
750aD *                  eval      lbhnd2 = scid(l2)
750aMC                   eval      lbhnd2 = %replace((scid(l2)
750aMC                             ):lbhnd2:2:1)
HMWaMC                   endsl
500bAC                   else
500bA*    Add case to next section on pallet.
CTYcAC                   add       1             p2
500cAC                   if        p2 > 9
500cAC                   eval      p2 = 9
500cAC                   endif
FRFaD*
FRFaD*   Assign leter A/B section of a pallet
FRFaD*
HMWaAC                   select
HMWaAC                   when      client = frf
JFF A **                           or client = jakes
FRFaAC                   eval      lbhnd2 = %char(p2)
HMWaMC                   other
750aD *                  eval      lbhnd2 = scid(l2)
750aMC                   eval      lbhnd2 = %replace((scid(l2)
750aMC                             ):lbhnd2:2:1)
HMWaMC                   endsl
CTYcAC                   eval      p2 = p2 - 1
500cAC                   endif
500 A*    Assign flag to item so we know to look in pallet section file.
500cAC                   else
750aMC                   eval      svhnd2 = lbhnd2
500 AC                   eval      lbhnd2 = '*P'
500 A*    Breakdown qty picked to individual sections on pallet.
500 AC                   exsr      zzbkdn
500cAC                   endif
     C                   else
     *    Force item to last section on pallet.
FRFaD*
FRFaD*   Assign leter A/B section of a pallet
FRFaD*
HMWaAC                   select
HMWaAC                   when      client = frf
JFF A **                           or client = jakes
FRFaAC                   eval      lbhnd2 = %char(p2)
HMWaMC                   other
750aD *                  eval      lbhnd2 = scid(p2)
750aMC                   eval      lbhnd2 = %replace((scid(p2)
750aMC                             ):lbhnd2:2:1)
HMWaMC                   endsl
     C                   endif
     *
     C                   exsr      zzupd
     C                   leave
     *
     C                   endsl
     *
     C                   enddo
     C                   endsl
     *
     C                   endsr
VIP A*
VIP A*----------------------------------------------------------------
VIP A*
VIP A*  ASNSTP  Assign pallet section id by stop(s) per section.
VIP A*
VIP AC     asnstp        begsr
VIP A*
VIP AC                   select
VIP A*
VIP A*    All sections on the pallet have been filled, assign
VIP A*    the last position to all other items on this pallet.
VIP A*
VIP AC                   when      pltful = *on
VIP AC                   eval      lbhnd2 = scid(p)
VIP AC                   exsr      zzupd
VIP A*
VIP A*    Stop hasn't changed, assign item to current section.
VIP AC                   when      lbstop = hldstp
VIP AC                   eval      lbhnd2 = scid(p)
VIP AC                   exsr      zzupd
VIP A*
VIP AC                   other
VIP A*
VIP A*    There is room on the pallet, assign section id to item.
VIP A*
710aDc*    opnrsc        add       offset        l2
710aMC     NbrOfPalSec   add       offset        l2
VIP AC                   if        l2 > 9
VIP AC                   eval      l2 = 9
VIP AC                   endif
VIP A*
710aDC*    1             do        opnrsc        p
710aMC     1             do        NbrOfPalSec   p
VIP A*
VIP A*    Increment element to see if rooom for stop on pallet.
VIP AC                   if        lbstop <> hldstp
VIP AC     psct(p)       add       1             tststp
VIP AC                   endif
VIP A*
VIP AC                   select
VIP A*
VIP A*    This section is full and not the last section on the pallet.
VIP A*    Loop again and try next section.
VIP A*
VIP AC                   when      psct(p) = stpsct
710aMC                             and p < NbrOfPalSec
VIP AC                   iter
VIP A*
VIP A*    This section has room for the item.
VIP A*
VIP AC                   when      tststp <= stpsct
VIP A*
VIP AC                   if        lbstop <> hldstp
VIP AC                   add       1             psct(p)
VIP AC                   eval      hldstp = lbstop
VIP AC                   endif
VIP A*
VIP AC                   eval      lbhnd2 = scid(p)
VIP AC                   exsr      zzupd
VIP AC                   leave
VIP A*
VIP A*    This section has overflowed, attempt to add to next section
VIP A*    on pallet if one exists.  If no sections available then
VIP A*    assign item to last section on pallet.
VIP A*
VIP AC                   when      tststp > stpsct
VIP A*
VIP AC     p             add       1             n
VIP A*    Assign item to next section on pallet.
710aDC*                  if        n <= opnrsc
710aMC                   if        n <= NbrOfPalSec
VIP AC                   add       1             psct(n)
VIP AC                   eval      lbhnd2 = scid(n)
VIP A*
VIP AC                   else
710aMC                   eval      n = NbrOfPalSec
VIP A*    Force item to last section on pallet.
VIP AC                   eval      lbhnd2 = scid(n)
VIP AC                   eval      pltful = *on
VIP AC                   endif
VIP AC                   eval      p = n
VIP A*
VIP AC                   exsr      zzupd
VIP AC                   leave
VIP A*
VIP AC                   endsl
VIP A*
VIP AC                   enddo
VIP AC                   endsl
VIP A*
VIP AC                   endsr
VIP A*
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZBKDN   Breakdown qty picked into individual pallet sections.
500 A*
500 AC     zzbkdn        begsr
500 A*
500 A*    Compute qty that will fit in current section.
730aAC                   if        lbucub = 0
730aAC                   eval      qycurs = cubavl
730aAC                   else
500 AC     cubavl        div(h)    lbucub        qycurs
730aAC                   endif
500 A*
500 AC                   select
500 A*    If we can't fit at least one full unit in this section,
500 A*    Then put remaining units into next section.
500 AC                   when      qycurs <= 0
500 A*
500 A*    At least one full unit fits in this section.
500 AC                   when      qycurs >= 1
500 A*
500 AC     1             do        qycurs        pcs
500 A*
500 AC                   eval      lswhse = lbwhse
500 AC                   eval      lswhdp = lbwhdp
500 AC                   eval      lsitem = lbitem
500 AC                   eval      lslbl# = lblbl#
500 AC                   eval      lsctr# = lbctr#
500 AC                   eval      lstrn# = lbtrn#
500 AC                   eval      lsqpck = lbqpck
500 AC                   z-add     pcs           lscas#
HMWaAC                   select
HMWaAC                   when      client = frf
JFF AC                             or client = jakes
FRFaAC                   eval      lsscid = %char(p2)
HMWaMC                   other
750aD *                  eval      lsscid = scid(p2)
750aMC                   eval      lsscid = svhnd2
750aMC                   eval      lsscid = %replace((scid(p2)
750aMC                             ):svhnd2:2:1)
HMWaMC                   endsl
500 AC                   write     lsrec
500 A*
500 AC                   enddo
500 A*
500 AC                   endsl
500 A*
500 A*    Assign remaining qty to next section, if any remains.
500 AC                   eval      qycrs2 = lbqpck - qycurs
500 AC                   if        qycrs2 >= 1
500 A*      Advance pointer to next section Id.
500 AC                   add       1             p2
500 AC                   if        p2 > 9
500 AC                   eval      p2 = 9
500 AC                   endif
500 A*
500 AC     1             do        qycrs2        pcs
500 A*
500 AC                   eval      lswhse = lbwhse
500 AC                   eval      lswhdp = lbwhdp
500 AC                   eval      lsitem = lbitem
500 AC                   eval      lslbl# = lblbl#
500 AC                   eval      lsctr# = lbctr#
500 AC                   eval      lstrn# = lbtrn#
500 AC                   eval      lsqpck = lbqpck
500 A*      Include qty already assigned to previous section.
500 AC     qycurs        add       pcs           lscas#
HMWaAC                   select
HMWaAC                   when      client = frf
JFF AC                             or client = jakes
FRFaAC                   eval      lsscid = %char(p2)
HMWaMC                   other
750aD *                  eval      lsscid = scid(p2)
750aMC                   eval      lsscid = svhnd2
750aMC                   eval      lsscid = %replace((scid(p2)
750aMC                             ):svhnd2:2:1)
HMWaMC                   endsl
500 AC                   write     lsrec
500 A*
500 AC                   enddo
500 A*
500 AC                   endif
500 A*
500 AC                   endsr
500 A*
NCSaA*----------------------------------------------------------------
NCSaA*
NCSaA*  SNGLEPLTSECT2  Assign A/B as pallet section id code - New
NCSaA*
NCSaAC     snglepltsect2 begsr

     *  First, move pallets for transaction into an array

     C                   clear                   palletAry
     C                   eval      i = 0

     C     ps4key        setll     pltsum4
     C                   dow       forevr = forevr
     C     ps4key        reade     pltsum4

     C                   if        %eof(pltsum4) or i=9
     C                   leave
     C                   endif

     C                   if        PS4psrtid <> $prtid
     C                   iter
     C                   endif

     *    Move pallet info into array field data structure.

     C                   eval      fromStop = PS4psstp1
     C                   eval      toStop = PS4psstp2

     *      This will make the overflow pallets come before normal pallets
     *      in the case of a tie with the stop numbers.

     C                   if        PS4pspal# < 71
     C                   eval      palNum = PS4pspal# + 100
     C                   else
     C                   eval      palNum = PS4pspal#
     C                   endif
     C                   eval      palId = PS4psplid

     *    Move array field into the array.

     C                   eval      i += 1
     C                   eval      palletAry(i) = palletAryFld

     C                   enddo

     C                   eval      palletCount = i

     *  Next sort the array in descending order
     *    - We want the pallet with the highest stop to be 'A'

     C                   sorta     palletAry

     *  Now assign the letters to the pallets

     C                   for       i = 1 to palletCount
     C                   eval      palletAryFld = palletAry(i)
     C                   eval      letter = scid(i)
     C                   eval      palletAry(i) = palletAryFld
     C                   endfor

     *  Last of all, update the label records with the letter

640aMC     keylb3b       setll     label13s
     C                   dow       forevr = forevr
640aMC     keylb3b       reade     label13s

640aMC                   if        %eof(label13s)
     C                   leave
     C                   endif

     C                   if        lbqpck <= 0  or
     C                             lbtype <> 'O'  and
     C                             lbtype <> 'M'
     C                   iter
     C                   endif

     C                   for       i = 1 to palletCount
     C                   eval      palletAryFld = palletAry(i)
     C                   if        lbpal# = palId
     C                   eval      lbhnd2 = letter
     C                   endif
     C                   endfor

     C                   exsr      zzupd

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD   Update label record with pallet section id
     *
     C     zzupd         begsr
     *
     C                   update    lbrec3
     *
     C                   endsr

FRFaA*----------------------------------------------------------------
FRFaA*  LoadPalletAry  - Load arrar for sorting
FRFaA*

     C     LoadPalletAry begsr

     C                   eval      i = *zeros
     C                   clear                   palletAry2

     C     ps4key        setll     pltsum4
     C                   dou       %eof(pltsum4)
     C     ps4key        reade     pltsum4
     C                   if        not %eof(pltsum4)

     *    Move pallet info into array field data structure.

     C                   eval      fromStop2 = 100 - ps4psstp1
     C                   eval      toStop2 = 100 - ps4psstp2

     C                   eval      palNum2 = ps4pspal#

     C                   eval      palId2 = ps4psplid
     C                   eval      letter2 = *blanks
     C                   eval      transaction = ps4pstrn#

     *    Move array field into the array.

     C                   eval      i += 1
     C                   eval      palletAry2(i) = palletAryFld2

     C                   endif
     C                   enddo

     C                   exsr      SortPalletAry

     C                   endsr

FRFaA*----------------------------------------------------------------
FRFaA*  SortPalletAry  - Sort pallet array
FRFaA*

     C     sortPalletAry begsr

     C                   eval      palletCount = i
     C                   eval      j = 1

     *  Next sort the array in ascending order
     *    - We want the lowest pallet# to be 'A'

     C                   sorta     palletAry2

     *  Now assign the letters to the pallets

     C                   for       i = 1 to 9

     C                   if        palletAry2(i) <> *blanks

     C                   eval      palletAryFld2 = palletAry2(i)

     *  Single pallets get assigned the letter 'B'.
GRCaAC                   select
GRCaAC                   when      client = greco
     C                             and palletcount = 1
     C                   eval      letter2 = letterAry(j)

     C                   when      palletcount = 1
     C                   eval      letter2 = letterAry(2)

     C                   other
     C                   eval      letter2 = letterAry(j)
     C                   endsl

     C                   eval      j += 1
     C                   eval      palletAry2(i) = palletAryFld2
     C                   exsr      postpltletter

710aMC                   if        NbrOfPalSec > 1
     C                   exsr      postpltsectn
     C                   endif

     C                   endif

     C                   endfor

     C                   endsr

FRFaA*----------------------------------------------------------------
FRFaA*  postpltletter  - assgning A, B, C pallet code designation
FRFaA*

     C     postpltletter begsr

     C     keylbl90      setll     label90
     C                   dou       %eof(label90)
     C     keylbl90      reade     label90
     C                   if        not %eof(label90)

     C                   if        albpal# = palid2

750aAC                   select
750aAC                   when      client = jakes
750aDC                   eval      albdsp2 = letter2
750aDC                   eval      albhnd2 = *blanks
750aDC                   other
750aMC                   eval      albhnd2 = letter2
750aDC                   eval      albdsp2 = *blanks
750aAC                   endsl

     C                   update    lbrec9
     C                   endif

     C                   endif
     C                   enddo

     C                   endsr

FRFaA*----------------------------------------------------------------
FRFaA*  postpltsectn   - assgning pallet setion id
FRFaA*

     C     postpltsectn  begsr

     C     transaction   chain     pltsum4

     C                   eval      psctds = *zeros
     C                   eval      pltful = *off

     *    Calculate cube for each pallet section including
     *    a 10 % pad.

720aAC                   if        NbrOfPalSec = 0
720aAC                   eval      NbrOfPalSec = 1
720aAC                   endif
710aMC     ps4pscube     div(h)    NbrOfPalSec   sctcub

     C     keylb3b       setll     label13s
     C                   dou       %eof(label13s)
     C     keylb3b       reade     label13s
     C                   if        not %eof(label13s)

     C                   if        lbqpck <= *zeros
     C                             or lbtype <> 'O'
     C                             and lbtype <> 'M'
     C                   iter
     C                   endif
     C                   exsr      asgnid
     C                   endif

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
A
B
C
D
E
F
G
H
I
