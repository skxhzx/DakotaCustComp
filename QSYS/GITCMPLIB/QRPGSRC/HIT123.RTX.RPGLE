600 A /copy *libl/qcopysrc,hspecs
600 DH*OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HIT123    Reduce Pick Slot qty using H&S Orders - Invoicing
     *  21 March 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
417 A*  03/21/04  MLB  4.17
     *    - Created program to reduce pick slot quantity using H&S
     *      orders.
417aA*  04/14/04  MLB  4.17a
     *    - Changed program to use %ADJUSTORD instead of %ADJUST.
     *      This will allow the pick slot qty to go negative.
417bA*  04/14/04  MLB  4.17b
     *    - Changed program to process only orders that are being
     *      invoiced. This program will be called from OE04B2CL.
417bA*  04/26/04  MLB  4.17c
     *    - Changed program to load base slot for SSB items and
     *      send SSB item and pick qty in qty1 of item adj record.
     *
500 A*  02/04/05  MLB  5.00
     *    - Add Custom Client code support to program.
500aA*  05/13/04  MLB  500a
     *    - Enh: Revised program to retrieve base item for SSB
     *      when Alias item linked to SSB item.
500bA*  05/19/04  MLB  500b
     *    - Enh: Revised program to load SSB item for adjustment
     *      when Alias item linked to SSB item.
500cA*  04/11/05  MLB  500c
     *    - Fix: Revised program to not load pick qty into W1QT02
     *      when item type = 'B'.
500dA*  04/12/05  MLB  500d
     *    - Fix: Revised program to skip processing item# 999999.
     *
500eA*  04/28/05  DAS  500e
     *    - Enh: Added license tracking logic.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - 500e added from Jordano's code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews
     *
AFS A*  05/03/04  MLB  AFS
     *    - Changed program to skip all orders with memo code of
     *      DRS - Drop ship. * Client code support added *
     *    - * Client code support added *
AFS1A*   05/13/04  MLB  AFS1
     *     - Enh: Converted to permanent code. See 5.00a
AFS2A*   05/19/04  MLB  AFS2
     *     - Enh: Converted to permanent code. See 5.00b
AFS3A*   06/09/04  MLB  AFS3
     *     - Enh: Revised program to skip all orders with a 'D  ' in
     *       OHZUA3. These orders have been picked on Dakota previously.
     *       Added message to array DESC, sub 7.
     *    - * Client code support added *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
     *
BIR A*  02/05/05  MLB  BIR
     *    - Changed program to only process credit memos with adjust.
     *      code of 930.
BIR1A*  02/08/05  MLB  BIR1
     *    - Revised program to look for overflow slot when no pick slot(s)
     *      are found for an item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR1A*  11/03/04  MLB  JOR1
     *    - Revised program to add support for processing Breakdown items
     *      that are sold from different slot than the parent. These
     *      items will have a letter 'E' appended to item number.
     *    - Added files FIITMAL0, FJITMBL0 to program.
JOR2A*  04/11/05  MLB  JOR2
     *    - Revised program to only send adjustments for departments:
     *      DRY
     *      More to be added later.
JOR3A*  04/11/05  MLB  JOR3
     *    - Changed program to only process credit memos with adjust.
     *      code of 21.
JOR4A*  04/11/05  MLB  JOR4
     *    - Changed program to skip all orders with memo code of
     *      DS - Drop ship.
JOR5A*  04/11/05  MLB  JOR5
     *    - Revised program to look for overflow slot when no pick slot(s)
     *      are found for an item.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fit122fm   cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
500aAFpiritem3  if   e           k disk    rename(itrec:itrec3)
500aAF                                     prefix(i3)
     Fitemlnk   if   e           k disk
     Fslot3     if   e           k disk
     Fslotstat  if   e           k disk
     Funmesr    if   e           k disk
JOR1AFfiitmal0  if   e           k disk
JOR1AFfjitmbl0  if   e           k disk
417bAFOBPCKTL0  IF   E           K DISK
417bDF*ohordhl0  if   e           k disk
417bMFohordhl3  if   e           k disk
     Foiorddl0  if   e           k disk
     Fqsysprt   O    F  132        PRINTER OFLIND(*IN90)
500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*----------------------------------------------------------------
500 A
500 A /copy qcopysrc,id#andrews
500 A /copy qcopysrc,id#birite
500 A /copy qcopysrc,id#jordano

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
     D desc            s             50    dim(10) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)
410 AD slotds        e ds                  extname(slot)

500 A*----------------------------------------------------------------
500 A*  LT210 parameters
500 A*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     D slphy1          s                   like(slstk1)
     D slphy2          s                   like(slstk2)
     D slphy3          s                   like(slstk3)
     D slavl1          s                   like(slstk1)
     D slavl2          s                   like(slstk2)
     D slavl3          s                   like(slstk3)
     D sladj1          s                   like(slstk1)
     D sladj2          s                   like(slstk2)
     D sladj3          s                   like(slstk3)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D chgqt1          s                   like($saqty1)
     D chgqt2          s                   like($saqty2)
     D chgqt3          s                   like($saqty3)
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D savav1          s                   like($slavl1)
     D savav2          s                   like($slavl2)
     D savav3          s                   like($slavl3)
     D savst           s                   like($slstat)
     D sclear          s              1
     D ssbflg          s               n
     D usesc           s              1  0
     D warn            s               n
     D whse            s              3  0
     D w1qty1          s                   like($cqty1)
     D w1qty2          s                   like($cqty2)
     D w1qty3          s                   like($cqty3)
     D zmsflag         s               n

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
213 AD  $puser                39     48
     D  $pcmpn                49     51
     D  $pdivn                52     54
     D  $pdptn                55     57
     D  $pwhsn                58     60
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lcode                19     20
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  eridsg                 1      5
     D  ersdsg                 6     10
415dD*
415dD*                                   P   1   30ERNPCK
415dD*                                   P   4   60ERAPCK
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Change slot quantity.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
417bA* Entry Parameters
417b *
417b C     *ENTRY        PLIST
417b C                   PARM                    JOBNB             6
417b C                   PARM                    QTIME             6
417b C                   PARM                    CLPGM             1
417b *
417b * Set Work Fields For Program Use
417b *
417b C     *LIKE         DEFINE    OBORTY        INORTY
417b C     *LIKE         DEFINE    OBORTY        XXORTY
417b C     *LIKE         DEFINE    OBJBNB        XPJBNB
417b C     *LIKE         DEFINE    OBTIME        XPTIME
417b *
417b C                   MOVE      JOBNB         XPJBNB
417b C                   MOVE      QTIME         XPTIME
417b *
417b * OBPCKTL0/PARTIAL KEY/COMPANY,ROUTES TO PROCESS FILE
417b C     PCKTKP        KLIST
417b C                   KFLD                    XXTYPE
417b *
417b * OHORDHL3/PARTIAL KEY/ORDER HEADER FILE
417bAC     ORDHKP        KLIST
417bAC                   KFLD                    OBCMPN
417bAC                   KFLD                    OBDIVN
417bAC                   KFLD                    OBDPTN
417bAC                   KFLD                    OBJBNB
417bAC                   KFLD                    OBTIME
417bAC                   KFLD                    INORTY
417bAC                   KFLD                    OBDTES
417bAC                   KFLD                    OBRTEN
417bA*
417bA* OIORDDL3/PARTIAL KEY/ORDER DETAIL FILE
417bAC     ORDDKP        KLIST
417bAC                   KFLD                    OHCMPN
417bAC                   KFLD                    OHDIVN
417bAC                   KFLD                    OHDPTN
417bAC                   KFLD                    INORTY
417bAC                   KFLD                    OHDTES
417bAC                   KFLD                    OHRTEN
417bAC                   KFLD                    OHSTPN
417bAC                   KFLD                    OHCUSN
417bAC                   KFLD                    OHMEMO
417bAC                   KFLD                    OHORNR
417bAC                   KFLD                    OHINVN
417b *
417b C                   eval      *in90 = *on
417b C                   time                    hmsmdy           12 0
417b C                   Move      hmsmdy        rdate             6 0
417b C                   movel     hmsmdy        rtime             6 0
417b **************************
417b * READ OBPCKTL0 CMP/DPT/DDT/RTE SELECTED
417b *
417b * SET TYPE FLAG ACCORDING TO CALLING CL PROGRAM
417bAC                   MOVE      *BLANK        XXTYPE            1
417bAC                   MOVE      *BLANK        XXORTY
417bAC                   MOVE      *BLANK        INORTY
417bA*
417bA*    NOTE: The INORTY field is needed because when the orders reach
417bA*          this point, the OHORTY and OIORTY fields have been
417bA*          updated with 'I'.
417bA*
417bAC                   Select
417bAC                   When      CLPGM = 'A'
417bAC                   Move      'A'           XXTYPE
417bAC                   Move      'A'           XXORTY
417bAC                   Move      'I'           INORTY
    *
417bAC                   When      CLPGM = 'P'
417bAC                   Move      'P'           XXTYPE
417bAC                   Move      'P'           XXORTY
417bAC                   Move      'I'           INORTY
    *
417bAC                   When      CLPGM = 'B'
417bAC                   Move      'B'           XXTYPE
417bAC                   Move      'B'           XXORTY
417bAC                   Move      'I'           INORTY
417bA*
417bA*   We don't want to process any Invoice reprints....
417bAC                   When      CLPGM = 'I'
417bAC                   Move      ' '           XXTYPE
417bAC                   Move      ' '           XXORTY
417bAC                   Move      ' '           INORTY
417bA*
417bAC                   Endsl
417bA*
417bA*
417bAC     PCKTKP        SETLL     OBPCKTL0
417bAC     *INLR         DOUEQ     *ON
417bAC     PCKTKP        READE     OBPCKTL0                               LR
417bA*
     C                   select
417bAC     *INLR         WHENEQ    *OFF
417bAC     OBJBNB        ANDEQ     XPJBNB
417bAC     OBTIME        ANDEQ     XPTIME
417bA*
     *
417bDC*    ohkey         setll     ohordhl0
417bMC     ordhkp        setll     ohordhl3
 1B  C                   Dow       Forever = Forever
417bDC*    ohkey         Reade     ohordhl0
417bMC     ordhkp        Reade     ohordhl3                               77
 1E  C                   Select
417bMC                   When      *in77 = *on
 2E  C                   Leave
AFS3A*
AFS3A*   Order was picked on Dakota. Qty already deducted from
AFS3A*   pick slot. Do not process.
AFS3A*
AFS3AC                   When      OHZUA3 =  'D  '
AFS3AC                             and client = Andrews
AFS3AC                   Eval      woitem = ' '
AFS3AC                   Eval      woitem = 'Inv#:' + %trim(%editc(ohinvn:'X'))
AFS3AC                   Eval      oilnoi = 0
AFS3AC                   Eval      oiqysa = 0
AFS3AC                   Eval      sldisp = ' '
AFS3AC                   Eval      Erdesc = desc(7)
AFS3AC                   Exsr      Print
AFS3AC                   Iter
     *
     *   Process Headers that are NOT credit memos and
     *   Invoice was printed and right warehouse.
     *
417bDC*                  When      OHCRIN <> 'Y' and
 2B  C****                         OHPKPR =  ' ' and
417bDC*                            OHINPR =  'Y' and
417bDC*                            OHWHSN =  $PWHSN
417bA*
417bAC     *in77         Wheneq    *OFF
417bAC     OHJBNB        ANDEQ     XPJBNB
417bAC     OHTIME        ANDEQ     XPTIME
417bDC*    OHCRIN        ANDNE     'Y'
417bAC     OHARCD        ANDNE     'D'
AFS DC*    OHMEMO        ANDNE     ' DS'
417bA*
AFS A*  Skip drop ship invoices.
AFS AC     Client        Ifeq      Andrews
AFS AC     OHMEMO        Andeq     ' DS'
JOR4AC     Client        Oreq      Jordanos
JOR4AC     OHMEMO        Andeq     ' DS'
AFS AC                   Iter
AFS AC                   Endif
     *
     *   Process order detail that are NOT credit memos and picklist was
     *   Printed and Invoice was printed.
     C     oikey         setll     oiorddl0
 1B  C                   dow       forever = forever
     C     oikey         reade     oiorddl0                               78
 1E  C                   Select
 2B  C                   When      *in78 = *on
 2E  C                   Leave
500dA*
500dA*   Skip processing on item# 999999.
500dAC                   When      oiitmn = '999999'
500dAC                   Iter
     *
     *   Process orders that are NOT credit memos and picklist was
     *   Printed and Invoice was printed and active line item.
     *
     C                   When      OICRIN <> 'Y' and
417bDC*                            OIPKPR =  'Y' and
417bDC*                            OIINPR =  'Y' and
     C                             OIARCD =  'A' and
     C                             OIQYSA >  0
417bA*
417bA*   Process credit memo's that are part of rebill processing.
417bAC                             or OICRIN = 'Y' and
417bAC                             OIARCD =  'A'   and
417bAC                             OICRDC =  '  3'
AFS AC                             and client = Andrews
BIR A*
BIR A*   Process credit memo's that are part of rebill processing.
BIR AC                             or OICRIN = 'Y' and
BIR AC                             OIARCD =  'A'   and
BIR AC                             Client = BiRite and
BIR AC                              OICRDC =  '930'
JOR3A*
JOR3A*   Process credit memo's that are part of rebill processing.
JOR3AC                             or OICRIN = 'Y' and
JOR3AC                             OIARCD =  'A'   and
JOR3AC                             Client = Jordanos and
JOR3AC                              OICRDC =  ' 21'
     *
     C                   move      *blanks       kyitem
JOR1A*
JOR1A*
JOR1AC                   if        Client = Jordanos
JOR1AC*
JOR1AC     fikey         chain     fiitmal0
JOR1AC                   if        not %found(fiitmal0)
JOR1AC                   eval      fipcki=1
JOR1AC                   endif
JOR1AC*
JOR1AC     fjkey         chain     fjitmbl0
JOR1AC                   if        not %found(fjitmbl0)
JOR1AC                   eval      fjbccd='N'
JOR1AC                   eval      fjsltn=*blanks
JOR1AC                   eval      fjslt2=*blanks
JOR1AC                   endif
JOR1A*
JOR1A*    Base item with breakdown sold from different slot.
JOR1AC                   if        fjbccd = 'Y' and fjarcd <> 'D'
JOR1AC                             and fipcki > 1 and fjslt2  > ' '
JOR1AC                             and fjsltn <> fjslt2
JOR1AC                             and oibccd = 'Y'
JOR1AC                   Eval      kyitem = %TRIM(oiitmn) + 'E'
JOR1A*
JOR1AC                   else
JOR1AC                   Eval      kyitem = %TRIM(oiitmn)
JOR1A*
JOR1AC                   endif
JOR1A*
JOR1A*    All other Clients.
JOR1AC                   else
JOR1A*
     C                   Eval      kyitem = %TRIM(oiitmn)
JOR1AC                   endif
JOR1A*
     C                   Movel (p) kyitem        woitem
500bAC                   move      *blanks       svitem           15
     *   Get Dakota item master. If not found in Dakota. Skip it.
     C                   exsr      zzgetit
     C                   if        Error = *on
     C                   Eval      Erdesc = desc(1)
     C                   Exsr      Print
     C                   Iter
     C                   Endif
JOR2 *   Skip all departments except DRY.
JOR2 C                   if        Client = Jordanos
JOR2 *
JOR2 C                   if        itwhdp <> 'DRY  '
JOR2 C                   Iter
JOR2 C                   Endif
JOR2 C                   Endif
JOR2 *
AFS A*   Save SSB item number & type.
AFS AC                   move      *blanks       svittype          1
AFS AC                   If        ittype = 'S'
AFS AC                   Move      ittype        svittype
AFS AC                   Endif
     *
     *   Get Alias Item Base item.
AFS A*   Get SSB Item Base item.
     C                   If        Ittype = 'A'
AFS AC                             or Ittype = 'S'
     C                   exsr      zzgetil
     C                   if        Error = *on
     C                   Eval      Erdesc = desc(2)
     C                   Exsr      Print
     C                   Iter
     C                   Endif
     *
     *   Load base item instead.
     C                   move      *blanks       kyitem
     C                   Eval      kyitem = %TRIM(ilitm2)
     C                   Movel (p) kyitem        woitem
     C                   Endif
500aA*
500aA*   If Alias item, get type for base item.
500aAC     ittype        Ifeq      'A'
500aAC     keyit3        chain     piritem3                           76
500aAC     *in76         Ifeq      *ON
500aAC                   move      *blanks       i3ittype
500aAC                   Endif
500aA*
500aA*   If base item for Alias is SSB, get Base item for SSB.
500aAC     i3ittype      ifeq      'S'
500bAC                   Eval      svitem = kyitem
500aAC     keyil3        chain     Itemlnk                            71
500aAC     *in71         ifeq      *ON
500aAC                   clear                   ilitm2
500aAC                   clear                   ilitm3
500aAC                   Endif
500aAC                   Move      ilitm2        kyitem
500aAC                   Endif
500aAC*
500aAC                   Endif
     *
     *   Get pick slot for item.
     C                   exsr      zzgetsl
     C                   if        Error = *on
     C                   Eval      Erdesc = desc(3)
     C                   Exsr      Print
     C                   Iter
     C                   Endif
     *
     C                   Eval      $pwhdp = slwhdp
     C                   Eval      $pdisp = sldisp
     C                   Eval      $puser = #user
     *
     *   Load info from file for adjustment.

     C                   eval      W1qty1 = 0
     C                   eval      W1qty2 = 0
     C                   eval      W1qty3 = 0
     *
     C                   eval      W1qt01 = 0
     C                   eval      W1qt02 = 0
     C                   eval      W1qt03 = 0
     *
     C                   eval      Chgqt1 = 0
     C                   eval      Chgqt2 = 0
     C                   eval      Chgqt3 = 0
     C                   eval      W1cwtr = 0
     C                   eval      W1code = '  '
     C                   Move      *blanks       W1memo
     *
     C                   exsr      zzinz2
     *
     *   Broken case item. Load qty picked into chgqty2.
     C                   If        oibccd = 'Y'
500cAC                             and ittype <> 'B'
     C                   z-sub     oiqysa        W1qt02
     C                   Else
     C                   Z-sub     oiqysa        W1qt01
     C                   Endif
     *
     *   Catchweight item. Load wgt into field.
     C                   If        *in95 = *off
     C                   If        oiexcw = 0
     C                   z-add     1             oiexcw
     C                   Endif
     C                   If        oiexcw > 0
     C                   z-sub     oiexcw        w1cwtr
     C                   Endif
     C                   Else
     C                   Eval      w1cwtr = 0
     C                   Endif
     *
     C                   eval      w1code = 'MV'
     C
     C                   move      *blanks       W1memo
     C                   eval      w1memo = %trim(oicusn)
     C                                      + '/'
     C                                      + (%editc(oiornr:'X'))
     C                                      + '/'
     C                                      + (%editc(oilnoi:'X'))
     *
 2B  C                   Exsr      zzchk1
417bA*   Error will never be ON. Verify via DRI is skipped since
417bA*   we're using %adjustord option.
417bA*
     *   Not able to verify adjustment. Chg quantity to what is
     *   available and try again.
     C                   If        Error = *On
     *
     C                   If        oibccd = 'Y'
     *
AFS AC                   If        oiqysa > Slavl2
     *
AFS DC*    Slavl2        sub       oiqysa        W1qt02
AFS AC                   Z-Add     Slavl2        W1qt02
     C                   If        W1qt02 > 0
     C                   Z-sub     W1qt02        W1qt02
     C                   Endif
     *
AFS AC                   Endif
     *
     C                   Else
AFS AC                   If        oiqysa > Slavl1
AFS DC*    Slavl1        sub       oiqysa        W1qt01
AFS AC                   Z-Add     Slavl1        W1qt01
     C                   If        W1qt01 > 0
     C                   Z-sub     W1qt01        W1qt01
     C                   Endif
     *
AFS AC                   Endif
     *
     C                   Endif
     *
     *   2nd Try to verify adjustment.
     C                   Exsr      zzchk1
     *   Adjustment failed. Print exception.
     C                   If        Error = *On
     C                   Eval      Erdesc = desc(4)
     C                   Exsr      Print
     C                   Iter
     C                   Endif
     C                   Endif
     *
     C                   Exsr      zzupd
     C                   If        Error = *On
     C                   Eval      Erdesc = desc(5)
     C                   Exsr      Print
     C                   Endif
 2E  C                   endsl
 1E  C                   enddo
     *
 2E  C                   endsl
 1E  C                   enddo
     *
417bAC                   endsl
417bAC                   enddo
     *
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   move      *on           *inlr
     *
     *
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif
     *
 1B  C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
 1E  C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   move      '01 '         nxtscr
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
 1E  C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
 1E  C                   endif
     C                   eval      ovrrid = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
 2E  C                   endif
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc2
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500 A
500 A* Get client id.
500 A
500 AC                   call      'GETCLIENT'
500 AC                   parm                    client           10
500 A
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Fake open. Dspf never used.
     C                   If        1 = 0
     C                   open      IT122FM
     C                   Endif
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   If        *in97 = *on
417bAC                   If        1 = 0
     C                   write     msgctl
417bAC                   endif
     C                   endif
     C                   eval      msgk = *zeros
     C                   If        *in97 = *on
417bAC                   If        1 = 0
     C                   write     msgclr
417bAC                   endif
     C                   endif
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0 and *in97 = *off
417bAC                   If        1 = 0
     C                   write     msgctl
417bAC                   Endif
     C                   eval      msgk = *zeros
 1E  C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   if        $msgf = 'DONTDO'
417bAC                   If        1 = 0
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
417bAC                   Endif
     C                   endif
 1B  C                   if        #msgid <> '*CLEAR ' and #msgid = 'dontdo'
     C                   add       1             msgk
417bAC                   If        1 = 0
     C                   write     msgrec
417bAC                   Endif
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   if        #msgid <> '*CLEAR ' and #msgid = 'dontdo'
417bAC                   If        1 = 0
     C                   write     clrscr
417bAC                   Endif
     C                   endif
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
417bAC                   If        1 = 0
     C                   write     msgrec
417bAC                   Endif
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
     C                   endif
     C                   if        $msgf = 'dontdo'
417bAC                   If        1 = 0
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
417bAC                   Endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105s Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

     *   PIR0009  Number can not be negative.
     *
     C     zm0009        begsr
     C                   move      'PIR0009'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm0201        begsr
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm0202        begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM10  Can't replace, quantity is pending.
     *
     C     zm10          begsr
     C                   move      'IT13210'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12216  Quantity can not be negative when replacing.
     *
     C     zm16          begsr
     C                   move      'IT12216'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12215  Slot does not contian item.
     *
     C     zm15          begsr
     C                   move      'IT12215'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT12217  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   move      'IT12217'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Adjustment not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   move      'IT12273'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12274  Adjustment not completed - Record locked.
     *
     C     zm74          begsr
     C                   move      'IT12274'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12275  Not enough warehouse available qty.
     *
     C     zm2275        begsr
     C                   move      'IT12275'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off


     *   Set working quantities.

 1B  C                   if        usesc = 1
     C                   z-add     w1qt01        w1qty1
     C                   z-add     w1qt02        w1qty2
     C                   z-add     w1qt03        w1qty3
 1E  C                   endif

     *
     *  Calculate change quantities.
     *
 1B  C                   select
     *
     *     Increasing/Decreasing quantity.
     *
 1X  C                   when      w1type = '1'
     C                   eval      chgqt1 = w1qty1
     C                   eval      chgqt2 = w1qty2
     C                   eval      chgqt3 = w1qty3
     *
     *     Replacing quantity.
     *
 1X  C                   other
     C                   eval      chgqt1 = w1qty1 - slstk1
     C                   eval      chgqt2 = w1qty2 - slstk2
     C                   eval      chgqt3 = w1qty3 - slstk3
 1E  C                   endsl

     *   Fill interface data structure fields.

417bDC*                  exsr      fill$adj

     *   Call interface to do verification.

417bDC*                  eval      $dricommand = '*SLOT'
417bDC*                  eval      $drisubcmd  = '%VERIFY'
417bDC*                  eval      $drisys2upd = 'D'
417bDC*                  exsr      zzzdricop

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   exsr      zzchk1
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
 1B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
 2B  C                   select
     *
     *     Return code.
     *
 2X  C                   when      row# = 20
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lcode = w1code
     C                   call      'AD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
 3E  C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
 2X  C                   other
     C                   move      *on           error
     C                   exsr      zm9905
 2E  C                   endsl
goto Csr                 goto      endcm1
 1E  C                   endif
     *
     *      F9 - View slot quantities.
     *
 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   z-add     $pwhse        whse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
 1E  C                   endif
     *
     *      F20 - Accept Warning.
     *
 1B  C                   if        *inku
     C                   move      *on           ovrrid
 1E  C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   exsr      zzcmd1
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     C                   if        $sacodee = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $saqty2e = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $saqty3e = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $sacwtae = '1'
     C                   eval      *in33 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr

     *      Convert available quantity to string.

     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = slavl1
     C                   eval      $cqty2 = slavl2
     C                   eval      $cqty3 = slavl3
     C                   move      *blanks       w1incq           10

     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   eval      w1incq = $cqstr

     *      Convert adjustable quantity to string.

     C                   eval      $cqty1 = sladj1
     C                   eval      $cqty2 = sladj2
     C                   eval      $cqty3 = sladj3

     C                   move      *blanks       w1excq           10
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      w1excq = $cqstr

     *  Get status description.

     C     slstat        chain     slotstat                           79
 1B  C                   if        *in79
     C                   eval      ssdesc = *blanks
     C                   movel     slstat        ssdesc
 1E  C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr

     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.

     C                   exsr      zzfil0
     C                   z-add     slavl1        savav1
     C                   z-add     slavl2        savav2
     C                   z-add     slavl3        savav3
     C                   move      slstat        savst

     *   Get Unit of measure fields

     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom

     *   Format item description.

     C                   movel     $ititem       $iitem
     C                   movel     $itdesc       $idesc
     C                   movel     $itpdsc       $ipdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      woitem = *blanks
     C                   movel     $istr         woitem

     *   Get SSB item, if one exists

     C                   move      *off          ssbflg
     C                   eval      wolbls = *blanks
     C                   eval      wositm = *blanks
 1B  C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8

 2B  C                   if        #brtn = '*FOUND  '
     C                   move      *on           ssbflg
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   movel     'SSB ('       wolbls
     C     wolbls        cat       w1um2:0       wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls

     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    #bitem
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    $istr
     C                   movel     $istr         wositm

 2E  C                   endif

 1E  C                   endif

     *   Expand slot seciton type.

 1B  C                   if        slstyp = 'P'
     C                   eval      wostyp = 'PIR  '
 1X  C                   else
     C                   eval      wostyp = 'Fixed'
 1E  C                   endif

     *   Initialize entry fields

     C                   eval      w1type = '1'
 1B  C                   if        $itcwgt <> 'Y'
     C                   eval      *in95 = *on
 1X  C                   else
     C                   eval      *in95 = *off
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w2qty = *blanks
     C                   exsr      zzfil1
     C                   endsr


     *----------------------------------------------------------------
     *
     *  ZZGETIT  Get Dakota item master.
     *
     C     zzgetit       begsr
     *
     *   Get record from main file.
     *
     C                   Eval      Error = *off
     C     Keyit         Chain     Piritem                            72
     C                   If        *in72 = *on
     C                   Eval      Error = *on
417 AC                   Eval      Sldisp = ' '
     *
     C                   Endif
     *
     C                   Endsr

     *----------------------------------------------------------------
     *
     *  ZZGETIL  Get Dakota item Link Record.
     *
     C     zzgetil       begsr
     *
     *   Get record from main file.
     *
     C                   Eval      Error = *off
     C     Keyil         Chain     Itemlnk                            74
     C                   If        *in74 = *on
     C                   Eval      Error = *on
     *
     C                   Endif
     *
     C                   Endsr

     *----------------------------------------------------------------
     *
     *  ZZGETSL  Get pick slot for item.
     *
     C     zzgetsl       begsr
     *
     *   Get record from main file.
     *
     C                   Eval      Error = *off
BIR1A*
BIR1AC                   if        Client = Birite
JOR5AC                             or Client = Jordanos
BIR1AC                   eval      kystat = 'A '
BIR1AC                   eval      kypick = 'Y'
BIR1AC                   endif
BIR1A*
     C     Keysl         setll     slot3
     C     Keysl         reade     slot3                                  73
BIR1A*
BIR1A*      No pick slot found. Look for active overflow slot.
BIR1AC                   If        Client = Birite
JOR5AC                             or Client = Jordanos
BIR1AC                   If        *in73  = *on
BIR1AC                   eval      kypick = 'N'
BIR1AC     Keysl         setll     slot3
BIR1AC     Keysl         reade     slot3                                  73
BIR1AC                   Endif
BIR1AC                   Endif
BIR1A*
     C                   If        *in73 = *on
     C                   Eval      Error = *on
     C                   Eval      sldisp= ' '
     C                   Eval      slstk1= 0
     C                   Eval      slstk2= 0
     *
     C                   Endif
     *
     C                   Endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   exsr      fill$adj

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     *
 1B  C                   if        error
     C*                  eval      errmsg = desc(1)
     C                   eval      errmsg = desc(6)
     C                   eval      $prtn = '*PGMQ   '
     C*                  exsr      zm7973
goto C                   goto      endgt1
goto C                   else
 1E  C                   exsr      zzzds2slot
 1E  C                   endif
     *
     *  Slot does not contain an item.
     *
 1B  C                   if        slitem = *blanks
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C*                  exsr      zm15
goto C                   goto      endgt1
 1E  C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C                   exsr      zzget1
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog

     *   Set warehouse defaults.

     C                   Move      *On           Forever           1
     C                   Move      *zeros        W1cwtr            9 2
     C                   eval      $pcmd  = '*CHANGE '
     C                   eval      $pwhse = 1
     C                   eval      $pwhdp = '*ALL '
     C                   eval      $pcmpn = '  1'
     C                   eval      $pdivn = '  1'
     C                   eval      $pdptn = '  1'
     C                   eval      $pwhsn = '  1'
JOR1 *
JOR1 * FIITMAL0 - Full Key. Item Master file
JOR1AC     fikey         KLIST
JOR1AC                   KFLD                    oicmpn
JOR1AC                   KFLD                    oiitmn
JOR1 * FJITMBL0 - Full Key. Item Balance file
JOR1AC     fjkey         KLIST
JOR1AC                   KFLD                    oicmpn
JOR1AC                   KFLD                    oidivn
JOR1AC                   KFLD                    oidptn
JOR1AC                   KFLD                    oiwhsn
JOR1AC                   KFLD                    oiitmn
     *
     C     *like         define    slitem        kyitem
     C     *like         define    slstat        kystat
     C     *like         define    slpick        kypick
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
500aAC*
500aAC*  Define key for PIRITEM3 file.
500aAC*
500aAC     keyit3        klist
500aAC                   kfld                    kyitem
500aAC                   kfld                    itwhse
     *
     C     keyil         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
500aA*
500aAC     keyil3        klist
500aAC                   kfld                    itwhse
500aAC                   kfld                    kyitem
     *
     C     ohkey         klist
     C                   kfld                    $pcmpn
     C                   kfld                    $pdivn
     C                   kfld                    $pdptn
     *
     C     oikey         klist
     C                   kfld                    ohcmpn
     C                   kfld                    ohdivn
     C                   kfld                    ohdptn
     C                   kfld                    ohcusn
     C                   kfld                    ohornr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr

     C                   eval      *in97 = *on
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   Move      *Blanks       Erdesc           40
     C                   Move      *Blanks       Wodesc           55
     C                   Move      *Blanks       W1memo           30

     *   Get warehouse description.

     C                   eval      wowhse = *blanks
     C                   eval      $cstr = *blanks

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     *
     *   Put warehouse and department together.
     *
     C                   eval      wowhse = %trim($cstr) + '/'
     C                                    + %trim($pwhdp) + ' - '
     C                                    + %trim($vdesc)
500 A*
500 A*   Get default values for the user.
500 A*
500 AC                   call      'GETUSER'
500 AC                   parm                    #user
500 AC                   parm      0             #whse             3 0
500 AC                   parm      0             #emp#             5 0
500 AC                   parm                    #fnam            15
500 AC                   parm                    #init             1
500 AC                   parm                    #lnam            20
500 AC                   parm                    #whdp             5
500 AC                   parm                    #styp             1
500 AC                   parm                    #shft             6
500 AC                   parm                    #crew             6
500 AC                   parm      0             #nhrs             3 1
500 AC                   parm                    #rtn              8

     *
     *   Select first screen to display.
     *
     C                   eval      usesc = 1
 1B  C                   if        usesc = 1
     C                   exsr      scr01i
     C                   endif
 1B  C                   if        usesc = 9
     C                   exsr      dspscr
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRINT - Print Exception report
     *
     C     Print         begsr
     C                   If        *in90 = *on
     C                   except    Hdr
     C                   eval      *in90 = *off
     C                   endif
     C*
     C                   except    Detail
     C*
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure
     *
     C                   exsr      fill$item
     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

 1B  C                   if        error
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
goto C                   goto      enduom
 1X  C                   else
 2B  C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in92 = *on
 2E  C                   endif
 2B  C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
     C                   eval      *in93 = *on
 2E  C                   endif
 1E  C                   endif
     *
     C     $itum1        chain     unmesr                             75
 1B  C                   if        not *in75
     C                   eval      w1um1 = umshrt
 1X  C                   else
     C                   eval      w1um1 = *blanks
 1E  C                   endif
     *
 1B  C                   if        not *in92
     C     $itum2        chain     unmesr                             75
 2B  C                   if        not *in75
     C                   eval      w1um2 = umshrt
 2X  C                   else
     C                   eval      w1um2 = *blanks
 2E  C                   endif
 1E  C                   endif
     *
 1B  C                   if        not *in93
     C     $itum3        chain     unmesr                             75
 2B  C                   if        not *in75
     C                   eval      w1um3 = umshrt
 2X  C                   else
     C                   eval      w1um3 = *blanks
 2E  C                   endif
 1E  C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      *off          error

     *   Fill interface data structure fields.

     C                   exsr      fill$adj

     *   Call interface to do update.

     C                   eval      $dricommand = '*SLOT'
417aDC*                  eval      $drisubcmd  = '%ADJUST'
417aMC                   eval      $drisubcmd  = '%ADJUSTORD'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
500eA
500eA*   Adjust license.
500eA
500eAC                   exsr      zzzclr$lt210
500eAC                   eval      $tcmd  = '*ADJUST'
500eAC                   eval      $twhse = $slwhse
500eAC                   eval      $twhdp = $slwhdp
500eAC                   eval      $tslot = $sldisp
500eAC                   eval      $titem = slitem
500eAC                   eval      $tqty1 = chgqt1
500eAC                   eval      $tqty2 = chgqt2
500eAC                   eval      $tqty3 = chgqt3
500eAC                   exsr      zzzcall$lt210

     C     endupd        endsr

     *----------------------------------------------------------------
     *  fill$adj   Fill $slot data structure fields for adjustment.
     *----------------------------------------------------------------

     C     fill$adj      begsr

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     C                   eval      $saitemu = *on
AFS DC*                  eval      $saitem  = slitem
417cA
417cA *    Use SSB item when making item adjustment.
417cAC                   If        svittype = 'S'
417cAC                   move      *blanks       $saitem
417cAC                   eval      $saitem  = %trim(oiitmn)
417cAC                   Else
500bA *
500bA *    Use SSB item when making item adjustment for Alias item.
500bAC                   If        svitem   > ' '
500bAC                   eval      $saitem  = svitem
500bAC                   else
AFS MC                   eval      $saitem  = kyitem
500bAC                   endif
417cAC                   Endif

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = chgqt1
     C                   eval      $saqty2  = chgqt2
     C                   eval      $saqty3  = chgqt3

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = w1cwtr

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = w1code

     C                   eval      $samemou = *on
     C                   eval      $samemo  = w1memo

417 AC                   eval      $sabyu   = *on
417 AC                   eval      $saby    = $puser

     C                   endsr

     *----------------------------------------------------------------
     *  fill$item  Fill $item data structure fields
     *----------------------------------------------------------------

     C     fill$item     begsr

     *  Initialize data structure

     C                   eval      savever# = $itver#
     C                   clear                   $item
416dAC                   clear                   $item2
     C                   eval      $itver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = slitem

     C                   endsr

     *----------------------------------------------------------------
     *  fill$slot  Fill $slot data structure fields
     *----------------------------------------------------------------

     C     fill$slot     begsr

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416dAC                   eval      $dridata2 = $item2
     C                   endsl

416dAC                   select

416dAC                   when      $dricommand = '*ITEM'
416dAC                   call(e)   'DRICOP'
416dAC                   parm                    $dricommand
416dAC                   parm                    $drisubcmd
416dAC                   parm                    $drisys2upd
416dAC                   parm      #prog         $driprogram
416dAC                   parm      ' '           $drireturn
416dAC                   parm      ' '           $drimessage
416dAC                   parm                    $dridata
416dAC                   parm                    $dridata2
416dA
416dAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416dA
416dAC                   endsl

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
417bDC**                 exsr      zm0105s
     C                   else
417bDC**                 exsr      zm0105
     C                   endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
417bDC**                 exsr      zm0001s
     C                   else
417bDC**                 exsr      zm0001
     C                   exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416dAC                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzzds2slot  Move slot ds fields into std slot fields.
     *----------------------------------------------------------------

     C     zzzds2slot    begsr

     C                   eval      slwhse = $slwhse
     C                   eval      slwhdp = $slwhdp
     C                   eval      sldisp = $sldisp
     C                   eval      slaisl = $slaisl
     C                   eval      slloc  = $slloc
     C                   eval      slrlvl = $slrlvl
     C                   eval      slhand = $slhand
     C                   eval      slside = $slside
     C                   eval      slstyp = $slstyp
     C                   eval      slstat = $slstat
     C                   eval      slsdte = $slsdte
     C                   eval      slstim = $slstim
     C                   eval      slsdef = $slsdef
     C                   eval      sldesg = $sldesg
     C                   eval      slactv = $slactv
     C                   eval      slbld  = $slbld
     C                   eval      slpick = $slpick
     C                   eval      slpseq = $slpseq
     C                   eval      slprty = $slprty
     C                   eval      slentd = $slentd
     C                   eval      slexpd = $slexpd
     C                   eval      slslfd = $slslfd
     C                   eval      slrsrv = $slrsrv
     C                   eval      slitem = $slitem
     C                   eval      slstk1 = $slstk1
     C                   eval      slstk2 = $slstk2
     C                   eval      slstk3 = $slstk3
     C                   eval      slalc1 = $slalc1
     C                   eval      slalc2 = $slalc2
     C                   eval      slalc3 = $slalc3
     C                   eval      sltfr1 = $sltfr1
     C                   eval      sltfr2 = $sltfr2
     C                   eval      sltfr3 = $sltfr3
     C                   eval      slpck1 = $slpck1
     C                   eval      slpck2 = $slpck2
     C                   eval      slpck3 = $slpck3
     C                   eval      slrcv1 = $slrcv1
     C                   eval      slrcv2 = $slrcv2
     C                   eval      slrcv3 = $slrcv3
     C                   eval      slphy1 = $slphy1
     C                   eval      slphy2 = $slphy2
     C                   eval      slphy3 = $slphy3
     C                   eval      slavl1 = $slavl1
     C                   eval      slavl2 = $slavl2
     C                   eval      slavl3 = $slavl3
     C                   eval      sladj1 = $sladj1
     C                   eval      sladj2 = $sladj2
     C                   eval      sladj3 = $sladj3

     C     endds2item    endsr
     *
     ***********************************************************
     *          *****  OUTPUT *****                            *
     ***********************************************************
     OQSYSPRT   E            HDR            1  2
     O                                            6 'HIT123'
     O                                           76 'Pick Slot Update Exception'
     O                                           89 's - Invoicing'
     O                                          127 'Page'
     O                       PAGE               132
     O          E            HDR            1
     O                       RDATE         Y      8
     O                       RTIME               18 '  :  :  '
     O                       WODESC              81
     O          E            HDR            1
     O                                           12 'Warehouse : '
     O                       $PWHSE        4     15
     O          E            HDR            1
     O                                          132 ' '
     O          E            HDR            0
     O                                            6 '______'
     O                                           18 '___________'
     O                                           30 '________'
     O                                           51 '___________________'
     O                                           69 '________'
     O                                           79 '________'
     O                                           89 '________'
     O                                           99 '________'
     O                                          107 '_____'
     O                                          121 '________'
     O                                          132 '________'
     O          E            HDR            1
     O                                            6 'Item /'
     O                                           17 'Pack/Size'
     O                                           48 'Item Description'
     O                                           63 'Order#'
     O                                           69 'Line#'
     O                                           76 'PckQty'
     O                                           89 'Slot'
     O                                          105 'Error Message'
     O          E            DETAIL      1  1
     O                       WOITEM              55
     O                       OHORNR        4     63
     O                       OILNOI        4     69
     O                       OIQYSA        L     76
     O                       SLDISP              89
     O                       ERDESC             132

500eA*----------------------------------------------------------------
500eA*----------------------------------------------------------------
500eA*  License Plate Tracking Routines
500eA*----------------------------------------------------------------
500eA*----------------------------------------------------------------

500eA*----------------------------------------------------------------
500eA*  ZZZCLR$LT210  -  Clear LT210 parameters.
500eA*----------------------------------------------------------------
500eA
500eAC     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

500eA*----------------------------------------------------------------
500eA*  ZZZCALL$LT210  -  Call LT210 program.
500eA*----------------------------------------------------------------
500eA
500eAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'ADJ'         $ttype
     C                   parm      'Adjustment'  $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      #emp#         $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

     C                   endsr

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Item not found in Dakota. Not adjusted.
Alias link rcd missing. Not adjusted.
Pick slot not found. Not adjusted.
Item verify failed. Not adjusted.
Item adjustment not posted.
DRI interface error. Slot not found.
Order picked on BFC. Order skipped. No Update.



