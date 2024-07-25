500 A /copy *libl/qcopysrc,hspecs
500eA*----------------------------------------------------------------
500eA*  Multilingual Verision
500eA*  Every screen and message has a corresponding Spanish version.
500eA*  Any changes must be made to both languages.
500eA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd.  # 8-51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RN620  RF Customer returns with UCI
     *  08 August 2007
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    08/08/07  RH   5.10
     *      - Created
     *        Uses pop up window for expiration/manufacturer date
     *
510a *    08/28/07  HNK  5.10a
     *      - Revised to add sales org parameter for Alpha.
510b *    08/30/07  HNK  5.10b
     *      - Revised to use delivery nuber as customer order number
     *        for Alpha interface.
510c *    08/31/07  RH   5.10c
     *      - Fix: Set key kyord to order # for alpha.
     *      - Fix: Use CLCDUR2 for dates not GTOJ$ or JTOG$.
510d *    09/05/07  HNK  5.10d
     *      - Fix: Delivery # must be entered.
510e *    09/07/07  HNK  5.10e
     *      - Fix: Call CW133 instead of CE120.
510f *    09/10/07  HNK  5.10f
     *      - Fix: Add two parms to call RN622CL
510g *    09/19/07  HNK  5.10g
     *      - Fix: Default UOM to CS.
     *      - Enh: If route# is <=99 and $psls=2000 --- Packers
     *             If route# is >=100 and $psls=2100 --- Legrand
     *             Check qty returned cannot be > qty ordered.
510h *    09/20/07  MLB   5.10h
     *      - Fix: Revise pgm to load correct values into Delivery
     *        Number and Billing Document# when warehouse > 001.
510i *    09/27/07  MLB   5.10i
     *      - Enh: Revise pgm to verify that Invoice# has been
     *        entered by the user. Per Alex. 09/27/07.
510j *    10/09/07  MLB   5.10j
     *      - Fix: Revise pgm to change key field used on klist for
     *        test if order has been returned previously.
510k *    10/09/07  MLB   5.10k
     *      - Enh: Revise pgm to call IT230CL RF Item Info lookup instead
     *        of IT900 - Item Number lookup. Packer's only.
510l *    10/11/07  MLB   5.10l
     *      - Enh: Revised ZZCHK2 to use %EOF instead of %found when
     *        doing reade on ORRTN to see if item was previously rtn'd.
510m *    10/16/07  MLB   5.10m
     *      - Enh: Revised program to move write of ORRTN record as last
     *        write so export program will not pick up returns that are
     *         not completed.
510o *    10/16/07  MLB   5.10o
     *      - Enh: Revised program to clear fields used on screen 4,
     *        screen5. Fields weren't being cleared and pgm was picking
     *        up invalid data and adding to next return.
510p *    10/18/07  MLB   5.10p
     *      - Enh: Revised program to not allow mis-pick return code=65
     *        to be used with catchwgt items. It is not possible for a
     *        catchwgt item to be mispicked since the item numbers are
     *        verified at time of selection from the uci barcode.
510q *    10/19/07  MLB   5.10q
     *      - Enh: Revised ZZCHK1 to use %EOF instead of %found when
     *        doing reade on ORDH5 to see if order exists.
510r *    10/19/07  MLB   5.10r
     *      - Enh: Revised ZZCHK1 to add checks for Will-Call routes 99
     *        for Packer's and 199 LeGrand.
510s *    10/22/07  HNK   5.10s
     *      - Enh: Allow to return same item again.  Per call frm Carlos.
510t *    10/26/07  MLB/HNK  5.10t
     *      - Enh: Changed program to send %ADJUSTORD when adjusting
     *        physical item (mis-picked item) instead of $ADJUST.
510u *    11/05/07  HNK  5.10u
     *      - Enh: Don't check for expiration date for desposition
     *             code 2=Damaged.  Carlos email 11.05.07
510v *    11/06/07  RBD  5.10v
     *      - Fix: Parm $lcmd, passed to CW133, should be *DLTADJ
     *             rather than *DELADJ when qty < 0.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
     *
710aA*    02/21/17  LMC  7.10a
     *      - Enh: UPC file database change. Recompile only.
     *----------------------------------------------------------------
     *  Notes:
     *    Program only uses Manual putaway.
     *    Return whole order calls RN622CL to select and process returns
     *    for order.
     *    For return item, program creates label, license and pirtran rec.
     *    Updates or adds record to POMFR file.
     *    Creates label link record.
     *    For mispick, create adjustments if both items have pic slots,
     *    otherwise create exception record.
     *    Creates return records.
     *    For catch weight items, calls CE120 to update UCICW file
     *
     *    Alpha system needs sales organization number to distinguish
     *    Packers and Legrand. Therefore this program is being called
     *    from menu with a parameter $psls = 2000 for Packers and 2100
     *    for Legrand.  The program is conditioned with warehouse = 1
     *    so this change will not affect when we go live with SAP
     *    which uses warehouse 200. This program is called from two
     *    different menu options, one for Packers and the other for
     *    Legrand.
     *
     *    Revised to use delivery nuber as customer order number for
     *    Alpha interface.
     *
     *
     *
     *
     *----------------------------------------------------------------
     *  Custom Revisions
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frn620fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec1:msgk)
     Funmesr    if   e           k disk
     Fucicw     if   e           k disk
     Fpiritem   if   e           k disk
510g Forrtn     uf a e           k disk
     Forrtnm    o    e             disk
     Foptions   if   e           k disk
     Foptiond   if   e           k disk
     FLabel     uf a e           k disk
     FLabel1    if   e           k disk
     F                                     rename(lbrec:recorl)
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
     FLabelnk   o  a e           k disk
     FLicense   uf a e           k disk
     Fordh      if   e           k disk
     Fordh5     if   e           k disk
     F                                     rename(ohrec:o5rec)
     Fordd      if   e           k disk
     Fordhm3    if   e           k disk
     Fupc       if   e           k disk
     Fpiritem4  if   e           k disk
     F                                     rename(itrec:i4rec)
     Frdscode   if   e           k disk
     Frtncode   if   e           k disk
     Forrtn2    if   e           k disk
     F                                     rename(orrec:r2rec)
     Fitemmsc   if   e           k disk
     Fitmexcp   o    e           k disk
     Fpomfr1    uf a e           k disk
510g Frtehed    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
510pMD desc            s             50    dim(17) ctdata perrcd(1)
510pMD descsp          s             50    dim(17) ctdata perrcd(1)
510pDD*desc            s             50    dim(16) ctdata perrcd(1)
510pDD*descsp          s             50    dim(16) ctdata perrcd(1)
510iDD*desc            s             50    dim(15) ctdata perrcd(1)
510iDD*descsp          s             50    dim(15) ctdata perrcd(1)
510hDD*desc            s             50    dim(14) ctdata perrcd(1)
510hDD*descsp          s             50    dim(14) ctdata perrcd(1)
510g D*desc            s             50    dim(13) ctdata perrcd(1)
510g D*descsp          s             50    dim(13) ctdata perrcd(1)
     D hed             s             50    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
PCKeA*  SAP Returns Misc field File data structures
PCKeA*
PCKeA /copy qcopysrc,rmmsc1_pak
PCKeA /copy qcopysrc,rmmsc2_pak
PCKeA /copy qcopysrc,rmmsc3_pak
PCKeA /copy qcopysrc,rmmsc4_pak
PCKeA /copy qcopysrc,rmmsc5_pak

500d  /COPY *libl/qcopysrc,C#ITEM
500d  /COPY *libl/qcopysrc,C#SLOT
500d D savever#        s                   like($slver#)
500d D saveaisl        s                   like($slaisl)
500d D saveloc         s                   like($slloc)
500d D saverlvl        s                   like($slrlvl)
500d D savehand        s                   like($slhand)
500d D slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
510cA*------------------------------------------------------------------
510cA* CLCDUR2 parameters
510cA*------------------------------------------------------------------

     D $cdcmd          s              8

     D $cddatein       s              8  0
     D $cdtimein       s              6  0

     D $cdyears        s              3  0
     D $cdmonths       s              3  0
     D $cddays         s              3  0
     D $cdhours        s              3  0
     D $cdminutes      s              3  0
     D $cdseconds      s              3  0

     D $cddateOut      s              8  0
     D $cdtimeOut      s              6  0
     D rtndate         s                   like(orrdte)
     D rtntime         s                   like(orrtim)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $lord           s              7  0
     D $msgf           s             10
     D $wcode          s              2
     D $wcord          s              7
     D $wdcde          s              5
     D $winvf          s              1
     D $wlord          s              7
     D $wmput          s              1
     D $wpbat          s              7
     D $wrtn           s              8
     D $wusr           s             10
     D $wwhse          s              3
     D #msgid          s              7
     D #msgtp          s              7
     D #po             s             10
500eAD #slotitem       s                   like($ititem)
500eAD #slottype       s                   like($ittype)
     D @paisl          s              5  0
     D @pcmd           s             10
     D @pcube          s              9  3
     D @pdate          s              8  0
     D @pgrp1          s              1
     D @pgrp2          s              1
     D @pmsg           s              4
     D @ppcs           s              5  0
     D @ppo            s              9
     D @pqty1          s              5  0
     D @pqty2          s              5  0
     D @pqty3          s              5  0
     D @prte           s              5
     D @prtn           s              8
     D @pstyp          s              1
     D @pswgt          s              9  2
     D @ptask          s              6
     D @ptime          s              6  0
     D @ptype          s              8
     D @ptrn#          s              7  0
     D @puser          s             10
     D @pwhdp          s              5
     D @pwhse          s              3  0
     D cancel          s              1
     D chkitm          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D error1          s              1
     D exod            s              8  0
     D expd            s              8  0
     D flbflg          s              1
     D forever         s              1    inz('1')
     D forevr          s              1
     D G$DATE          s              6  0
     D G$DD            s              2  0
     D G$DW            s              1  0
     D G$JD            s              5  0
     D G$JYD           s              7  0
     D G$MM            s              2  0
     D G$MMWK          s              2  0
     D G$WK7           s              7  0
     D G$YY            s              2  0
     D G$YYWK          s              3  0
     D G$YYYY          s              4  0
     D good1           s              1
     D GMWKSV          s              2  0
     D HELP            s              5  0
     D J$DATE          s              6  0
     D J$DD            s              2  0
     D J$JD            s              5  0
     D J$MD            s              3  0
     D J$MM            s              2  0
     D J$TST           s              9  9
     D J$X             s              2  0
     D J$YD            s              7  0
     D J$YYWK          s              3  0
     D J$YYYY          s              4  0
     D KYCODE          s                   like(OPDCOD)
     D kydlvy          s                   like(orord)
     D kyord           s                   like(orord)
     D KYITEM          s                   like(ITITEM)
     D KYUCI           s                   like(UCINBR)
     D KYUPC           s                   like(UPUPC)
     D KYVMFG          s                   like(ITVIT#)
     D KYWHOL          s                   like(ORWHOL)
     D LCNFLG          s              1
     D MFDTJ           s              5  0
     D MFGD            s              8  0
     D MSGK            s              4  0
510hAD nbrinv#         s             12  0
     D NXTSCR          s              3
     D OCODE           s              8
     D OSLOT           s             12
     D PICKSL          s              1
510hAD pos             s              5  0   inz(0)
     D PSLOT           s             12
     D QUICK           s              1
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D rtntyp          s              1
     D SCLEAR          s              1
     D STOP            s              1
     D TODAY           s              8  0
     D UPCCTR          s              3  0
     D USESC           s              1  0
510hAD valid_inv       c                   const('0123456789 ')
     D WARN            s              1
     D wdwinuse        s              4    inz('*NO ')
510b D wkdlvy          s              9  0
     D WODCDE          s              5
     D woexpd          s              6  0
     D woiinv          s              1
     D WOINV#          s              9
     D WOINVF          s              1
     D WOLBL#          s              7  0
     D WOORD           s              7  0
     D WOREXQ          s              1
     D WORK1A          s              1
     D WORK2           s              2
     D WORK4           s              4
     D WOTRN#          s              7  0
     D WOULBL          s              1
     D wowhse          s             40
     D WSCITM          s             15
     D WSITEM          s             15
     D WSLORD          s                   like(LBORD)
     D WUITEM          s              1
     D W1SLOT          s             12
     D w1qty1          s              5  0
     D w1qty2          s              5  0
     D w1qty3          s              5  0
     D W2ITEM          s             15
     D w2ulbl          s              1
     D AJCODE          s              2
500d D zmsflag         s               n
     *----------------------------------------------------------------
     * Window Titles
     D Title01         c                   const('Enter Date')
     D Title02         c                   const('Mfg Date')
     D Title03         c                   const('Exp Date')
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
     D  $lwhse                19     21  0
     D  $litem                22     36
415bAD  $lusr                 37     46
415bAD  $ldev                 47     56
415bAD  $lform                57     66
     *
417a D  $lupc                 22     41
417a D  $litm1                42     56
     *
     D  $lcode                19     20
416bA*
416bAD  $ldcde                19     23
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *
413aAD  $lrpo                 22     30
413aAD  $lrseq                31     35  0
413aAD  $lritm                36     50
     *
     D  $llbl#                22     28  0
     D  $lpqty                29     33  0
     *
223 AD  $lpo                  37     45
223 AD  $lrq1                 46     50  0
223 AD  $lrq2                 51     55  0
223 AD  $lrq3                 56     60  0
223 AD  $lrpal                61     63  0
     *
510e D  $lwhseu               19     21  0
510e D  $litemu               22     36
510e D  $lcodeu               37     38
510e D  $ltypeu               39     39
510e D  w1qt01p               40     44  0
510e D  w1qt02p               45     47  0
510e D  w1qt03p               48     50  0
510e D  $pcwgt                51     59  2
510e D  $ldate                60     64p 0
510e D  $ltime                65     68p 0
     *
     *----------------------------------------------------------------
     *  Name constants
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                           JKLMNOPQRSTUVWXYZabc-
     D                                           defghijklmnopqrstuvw-
     D                                           xyz')
     *----------------------------------------------------------------
     *  Called programs
     *
     D*@addtr          c                   const('ADDSTDTRN')
     D @addtr          c                   const('ADJTRAN2')
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
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erdate                 1      6  0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500eAD #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
223 A* Data structure
223 A*
223 AD opdata          ds
223 AD  oplpgm                 1     10
223 AD  opupct                11     13  0
223 AD  oppdef                14     14  0
223 AD  oppbld                15     15  0
223 AD  oppact                16     16  0
223 AD  opfdef                17     17  0
223 AD  opfasl                18     18  0
223 AD  opfsid                19     19  0
223 AD  opflvl                20     20  0
223 AD  oppasl                21     21  0
223 AD  oppfrc                22     22
223 AD  opplcn                23     23
223 AD  opcum                 24     43
223 AD  opcdiv                44     52  2
223 AD  opcaut                53     53
223 AD  opcwrn                54     54
223 AD  opcrng                55     57  1
223 AD  opwum                 58     72
223 AD  opxdsc                73     73
223 AD  optend               117    117
415bA*----------------------------------------------------------------
415bA*  *PICK  -  Picking options
415bA*----------------------------------------------------------------
415bA*
415bA* Fields
415bA*
415bA*    OPNXTP  -  Next pallet number.
415bA*    OPBPCK  -  Bulk pick definition.
415bA*    OPPCUB  -  Maximum cube for PIR.
415bA*    OPFPAL  -  Pallets on fixed fork lift.
415bA*    OPFCUB  -  Maximum cube per fixed pallet.
415bA*    OPFSTP  -  Maximum stops per fixed pallet.
415bA*    OPINCL  -  Include PIR in fixed cube.
415bA*    OPSRCH  -  Number of previous pallets to search for space.
415bA*    OPFBLD  -  Fixed pallet building method.
415bA*                1 = By piece without concern for splitting stop.
415bA*                2 = By stop without splitting stop between plts.
415bA*    OPPBRK  -  Break pallets by aisle (Y,N).
415bA*    OPMPUT  -  Manual Put away (Y,N).
415bA*
415bA* Data structure
415bA*
415bAD opddta          ds
415bAD  opnxtp                 1      7  0 inz(0)
415bAD  oppcub                10     14  2 inz(0)
415bAD  opfpal                15     15  0 inz(0)
415bAD  opfcub                16     20  2 inz(0)
415bAD  opincl                22     22
415bAD  opsrch                23     24  0 inz(0)
415bAD  opfstp                25     26  0 inz(0)
415bAD  opfbld                27     27  0 inz(0)
415bAD  opbpck                28     30  0 inz(0)
415bAD  oppbrk                31     33
415bAD  opmput                34     34
415bAD  opdend               117    117
415bA*
416bA*----------------------------------------------------------------
416bA*  *RETURNS -  Customer Returns options
416bA*----------------------------------------------------------------
416bA*
416bA* Fields
416bA*
416bA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
416bA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
416bA*    OPRFLB  -  Force return label entry. (Y/N)
416cA*    OPREXQ  -  Export Quick returns.(Y/N)
416dA*    OPRULB  -  Use label for putaway.(Y/N)
416bA*
416bA* Data structure
416bA*
416bAD oprdta          ds
416bAD  oprqch                 1      1
416bAD  oprqec                 2      2
416bAD  oprflb                 3      3
416eAD  oprexq                 4      4
416fAD  oprulb                 5      5
416bAD  oprend               117    117
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
213 A*      $PCMD   *RETURN  - Customer return.
213 A*              *TFRRTN  - Transfer returns.
213 A*              *POSRTN  - POS returns.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pqck             1
510a C                   parm                    $psls             4
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
416i C     nxtscr        caseq     '04 '         sc4
CIBa C     nxtscr        caseq     '05 '         sc5
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn1sp                              50
500eAC                   other
     C                   exfmt     screen1                              50
500eAC                   endsl
     C                   endif
     *
212 AC                   if        nxtscr = '02 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn2sp                              50
500eAC                   other
     C                   exfmt     screen2                              50
500eAC                   endsl
     C                   endif
     *
212 AC                   if        nxtscr = '03 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn3sp                              50
500eAC                   other
     C                   exfmt     screen3                              50
500eAC                   endsl
     C                   endif
     *
     C                   if        nxtscr = '04 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn4sp                              50
500eAC                   other
     C                   exfmt     screen4                              50
500eAC                   endsl
     C                   endif
     *
     C                   if        nxtscr = '05 '
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   exfmt     scrn5sp                              50
500eAC                   other
     C                   exfmt     screen5                              50
500eAC                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       3031
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
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
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
     C                   exsr      zzfil2
     *
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C     end03i        endsr
     *----------------------------------------------------------------
416i *
416i *  Screen 04 initialization
416i *
416i C     scr04i        begsr
416i C                   move      '04 '         nxtscr
416i C                   if        refrsh = *on
416i C                   exsr      zzfil4
416i C                   endif
416i C                   eval      refrsh = *off
416i C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   move      '05 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil5
     C                   endif
     C                   eval      refrsh = *off
     C     end05i        endsr
     *
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
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
416d *
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
     C                   if        w1rord = 'Y'
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   else
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     *
     *
     C     endsc1        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C**                 move      'EOJ'         nxtscr
     C**                 goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      '01 '         nxtscr
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so onto the next screen.
     *
416B C                   eval      refrsh = *on
     *
     *  Display screen for mispick.
     C                   if        w2code = '25'
     C                   exsr      scr04i
     C                   else
     C                   if        woiinv = 'N'
     *  Update for no stock.
415aAC                   eval      $lcmd = '*CHANGE '
415aAC                   eval      $lwhse = w1whse
415aAC                   eval      $lrq1 = w2qt01
415aAC                   eval      $lrq2 = 0
415aAC                   eval      $lrq3 = 0
415aAC                   z-add     1             $lrpal
415bAC                   eval      $lord = woord
     C                   exsr      zznstk
     C                   exsr      scr02i
     *
     *  Display screen for license.
     C                   else
     C                   exsr      scr05i
     C                   endif
     C                   endif
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      '01 '         nxtscr
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      '01 '         nxtscr
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      '01 '         nxtscr
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      '01 '         nxtscr
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Everything went fine so onto the next screen.
     *
416B C                   eval      refrsh = *on
     C                   if        woiinv = 'N'
     *  Update for no stock.
415aAC                   eval      $lcmd = '*CHANGE '
415aAC                   eval      $lwhse = w1whse
415aAC                   eval      $lrq1 = w2qt01
415aAC                   eval      $lrq2 = 0
415aAC                   eval      $lrq3 = 0
415aAC                   z-add     1             $lrpal
415bAC                   eval      $lord = woord
     C                   exsr      zznstk
     C                   exsr      scr02i
     C                   else
     *  Display screen for license.
     C                   exsr      scr05i
     C                   endif
     C     endsc4        endsr
     *----------------------------------------------------------------
500a *
500a *  SC5  -  Screen 5
500a *
500a C     sc5           begsr
500a *
500a *  Test for F3 - Exit
500a *
500a C                   if        *inkc
500a C                   move      'EOJ'         nxtscr
500a C                   goto      endsc5
500a C                   endif
500a *
500a *  Test for F5 - Refresh
500a *
500a C                   if        *inke
500a C                   eval      refrsh = *on
500a C                   exsr      scr05i
500a C                   goto      endsc5
500a C                   endif
500a *
500a *  Test for F12 - Previous
500a *
500a C                   if        *inkl
500a C                   move      'EOJ'         nxtscr
500a C                   goto      endsc5
500a C                   endif
500a *
500a *
500a *  Test for other command keys BEFORE verification and update.
500a *
500a C                   move      '*BEFORE '    cmdchk
500a C                   exsr      zzcmd5
500a C     cmdtkn        cabeq     *on           endsc5
500a *
500a *  Some other key pressed.
500a *
500a *     Check input and write/update record.
500a *
500a C                   exsr      zzchk5
500a C     error         cabeq     *on           endsc5
500a C                   exsr      zzupd5
500a C     error         cabeq     *on           endsc5
500a *
500a *  Test for other command keys AFTER verification and update.
500a *
500a C                   move      '*AFTER  '    cmdchk
500a C                   exsr      zzcmd5
500a C     cmdtkn        cabeq     *on           endsc5
500a *
500a *  Everything went fine so onto the next screen.
500a *
500aAC                   eval      refrsh = *on
500aAC                   exsr      scr02i
500aAC                   goto      endsc5
500a *
500a C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
416m *
416mA*                                                                   DOC
510cA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
416mAC     gtoj$         begsr
416mAC                   move      g$date        g$date
416mA* SPLIT DATE INTO MONTH, DAY, YEAR FIELDS                           DOC
416mAC                   if        dtfrmt = 1
416mAC                   movel     g$date        g$yy
416mAC                   move      g$date        work4
416mAC                   movel     work4         g$mm
416mAC                   move      work4         g$dd
416mAC                   else
416mAC                   movel     g$date        g$mm
416mAC                   move      g$date        work4
416mAC                   movel     work4         g$dd
416mAC                   move      work4         g$yy
416mAC                   endif
416mA* CREATE 4 DIGIT YEAR                                               DOC
416mAC                   move      g$yy          g$yyyy
416mAC                   if        g$yy >= 60
416mAC                   movel     '19'          g$yyyy
416mAC                   else
416mAC                   movel     '20'          g$yyyy
416mAC                   endif
416mAC                   eval      g$jd = 0
416mAC                   eval      g$mmwk = g$mm - 3
416mAC                   eval      gmwksv = g$mmwk
416mAC                   if        g$mmwk < 0
416mAC                   add       12            g$mmwk
416mAC                   endif
416mAC                   if        gmwksv <> 0
416mAC     g$mmwk        mult(h)   30.6          g$jd
416mAC                   endif
416mAC                   add       g$dd          g$jd
416mAC     g$yyyy        sub       1900          g$yywk
416mAC                   if        g$yywk <> 0
416mAC                   if        gmwksv < 0
416mAC                   eval      g$yywk = g$yywk - 1
416mAC                   endif
416mAC                   endif
416mAC     g$yywk        mult      365.25        g$jyd
416mAC                   add       g$jyd         g$jd
416mAC     g$jd          div       7             g$wk7
416mAC                   mvr                     g$dw
416mAC                   endsr
     *----------------------------------------------------------------
416m *
416mA*                                                                   DOC
510cA* ************ DO NOT USE  -  USE CLCDUR2 INSTEAD **************
416mAC     jtog$         begsr
416mAC     j$jd          div       365.25        j$yywk
416mAC     j$jd          div       365.25        j$tst
416mAC                   if        j$tst = 0
416mAC                   eval      j$yywk = j$yywk - 1
416mAC                   endif
416mAC     j$yywk        mult      365.25        j$yd
416mAC                   eval      j$yd = j$jd - j$yd
416mAC                   if        j$yd > 306
416mAC                   add       1             j$yywk
416mAC                   endif
416mAC                   eval      j$x = 0
416mAC                   dou       j$yd <= j$md
416mAC                   add       1             j$x
416mAC     j$x           mult(h)   30.6          j$md
416mAC                   enddo
416mAC                   eval      j$x = j$x - 1
416mAC     j$x           mult(h)   30.6          j$md
416mAC                   eval      j$dd = j$yd - j$md
416mAC     j$x           add       3             j$mm
416mAC                   if        j$mm > 12
416mAC                   sub       12            j$mm
416mAC                   endif
416mAC     j$yywk        add       1900          j$yyyy
416mAC                   if        dtfrmt = 1
416mAC                   move      j$yyyy        work2
416mAC                   movel     j$mm          work4
416mAC                   move      j$dd          work4
416mAC                   movel     work2         j$date
416mAC                   move      work4         j$date
416mAC                   else
416mAC                   move      j$yyyy        work2
416mAC                   movel     j$mm          work4
416mAC                   move      j$dd          work4
416mAC                   move      work2         j$date
416mAC                   movel     work4         j$date
416mAC                   endif
416mAC                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   If        wdwinuse = '*YES'
     C                   write     msgctl1
     C                   Else
     C                   write     msgctl
     C                   Endif
     C                   eval      msgk = *zeros
     C****               write     msgclr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   If        wdwinuse = '*YES'
     C                   write     msgclr1
     C                   Else
     C                   write     msgclr
     C                   Endif
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   If        wdwinuse = '*YES'
     C                   write     msgctl1
     C                   Else
     C                   write     msgctl
     C                   Endif
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      $msgf = #msgsp
500eAC                   other
     C                   eval      $msgf = #msgf
500eAC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   If        wdwinuse = '*YES'
     C                   write     msgrec1
     C                   Else
     C                   write     msgrec
     C                   Endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *----------------------------------------------------------------
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   If        wdwinuse = '*YES'
     C                   write     msgrec1
     C                   Else
     C                   write     msgrec
     C                   Endif
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
500dA *    DRI0001  Local system caused error
     *----------------------------------------------------------------

500dAC     zm0001        begsr
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
500dAC                   endsr


     *
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0109  Value can not be less than 0.
     *
     C     zm0109        begsr
     C                   move      'PIR0109'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   move      'PIR0112'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
416b *----------------------------------------------------------------
416b *   PIR0203  Value can not be blank.
416b *
416b C     zm0203        begsr
416b C                   move      'PIR0203'     #msgid
416b C                   move      '*DIAG  '     #msgtp
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
416b *----------------------------------------------------------------
416b *   PIR0204  Can only enter one value.
416b *
416b C     zm0204        begsr
416b C                   move      'PIR0204'     #msgid
416b C                   move      '*DIAG  '     #msgtp
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
416b *----------------------------------------------------------------
416b *   PIR0205  Must enter one value.
416b *
416b C     zm0205        begsr
416b C                   move      'PIR0205'     #msgid
416b C                   move      '*DIAG  '     #msgtp
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
     *----------------------------------------------------------------
     *    PO20033  License # required.
     *
     C     zm033         begsr
     C                   eval      #msgid = 'PO20033'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20034  License already exists.
     *
     C     zm034         begsr
     C                   eval      #msgid = 'PO20034'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
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
     *   PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   move      'PIR1008'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   move      'PIR1009'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
416mA*----------------------------------------------------------------
416mA*    PIR1010  Date must be <OR= today's date.
416mA*
416mAC     zm1010        begsr
416mAC                   move      'PIR1010'     #msgid
416mAC                   move      '*DIAG  '     #msgtp
416mAC                   movea     errmsg        $md
416mAC                   exsr      zmpmsg
416mAC                   endsr
417dA*----------------------------------------------------------------
417dA*    PIR4002  Product expired.
417dA*
417dAC     zm4002        begsr
417dAC                   move      'PIR4002'     #msgid
417dAC                   move      '*DIAG  '     #msgtp
417dAC                   movea     errmsg        $md
417dAC                   exsr      zmpmsg
417dAC                   endsr
     *----------------------------------------------------------------
416j *    OR12201  Order previously returned.
     *
416j C     zm1201        begsr
416j C                   move      'OR12201'     #msgid
416j C                   move      '*DIAG  '     #msgtp
416j C                   movea     errmsg        $md
416j C                   exsr      zmpmsg
416j C                   endsr
     *----------------------------------------------------------------
416j *    OR12202  Mispick item cannot be ordered item.
     *
416j C     zm1202        begsr
416j C                   move      'OR12202'     #msgid
416j C                   move      '*DIAG  '     #msgtp
416j C                   movea     errmsg        $md
416j C                   exsr      zmpmsg
416j C                   endsr
     *----------------------------------------------------------------
500a *    OR12203  Disposition must impact inventory.
500a *
500a C     zm1203        begsr
500a C                   move      'OR12203'     #msgid
500a C                   move      '*DIAG  '     #msgtp
500a C                   movea     errmsg        $md
500a C                   exsr      zmpmsg
500a C                   endsr
     *----------------------------------------------------------------
416j *    OR12204  Item not on order.
     *
416j C     zm1204        begsr
416j C                   move      'OR12204'     #msgid
416j C                   move      '*DIAG  '     #msgtp
416j C                   movea     errmsg        $md
416j C                   exsr      zmpmsg
416j C                   endsr
     *----------------------------------------------------------------
     *    PO15021  P.O. number must be entered.
     *
     C     zm21          begsr
     C                   move      'PO15021'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
415cA*----------------------------------------------------------------
415cA*   PO20029  UPC not on file.
415cA*
415cAC     zm29          begsr
415cAC                   move      'PO20029'     #msgid
415cAC                   move      '*DIAG  '     #msgtp
415cAC                   movea     errmsg        $md(1)
415cAC                   exsr      zmpmsg
415cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      wsitem = *blanks
     C                   eval      kyord = *zeros
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
416bAC                   goto      endck1
     C                   else
     C                   eval      $fwhse = w1whse
     C                   movel     $lerm         $fdesc
     C                   call      'FRMTWH'
     C                   parm                    $fwhse            3 0
     C                   parm                    $fdesc           30
     C                   parm                    wowhse
     C                   endif
416b *
416b *   Get Return Options.
416b *
416bAC                   move      '0'           flbflg
416bAC                   eval      worexq = *blanks
416eAC                   move      '*RETURNS'    ocode
416b *
416bAC     opkey         chain     options                            79
416bAC                   if        not *in79
416bAC                   eval      oprdta = opdata
416bAC                   if        oprflb = 'Y'
416bAC                   move      '1'           flbflg
416bAC                   endif
416eAC                   move      oprexq        worexq
416bAC                   endif
     *
510d *  Verify Delivery #.
     *
510d C                   if        w1dlvy=*blanks
510d C                   eval      error = *on
510d C                   eval      *in22 = *on
510d C                   eval      *in02 = *on
510d C                   eval      errmsg = *blanks
510d C                   select
510d C                   when      e$lng = 'SP'
510d C                   eval      errmsg = descsp(4)
510d C                   other
510d C                   eval      errmsg = desc(4)
500d C                   endsl
510d C                   exsr      zm1001
510d C                   goto      endck1
510d C                   endif
     *
     *  Use Packers ORDHM1_PAK in PIRSAP/QCOPYSRC
     *  For SAP interface only.
510b C                   if        w1whse<>1
     C     ohmkey        chain     ordhm3
     C                   if        not %found(ordhm3)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
500e C                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(4)
500eAC                   other
     C                   eval      errmsg = desc(4)
500eAC                   endsl
     C                   exsr      zm1001
     C                   goto      endck1
     C                   else
     C                   eval      kyord = hmord
     C                   endif
510b C                   endif
     *
510b *  Verify Order #.
510b *  For Alpha interface only.
510b C                   if        w1whse = 1
510b C                   eval      kyord = %dec(w1dlvy:7:0)
510b C     oh5key        setll     ordh5
510g C                   dow       forevr = forevr
510b C     oh5key        reade     ordh5
510qDC*                  if        not %found(ordh5)
510qMC                   if        %eof(ordh5)
510b C                   eval      error = *on
510b C                   eval      *in22 = *on
510b C                   eval      *in02 = *on
510b C                   eval      errmsg = *blanks
510b C                   select
510b C                   when      e$lng = 'SP'
510b C                   eval      errmsg = descsp(4)
510b C                   other
510b C                   eval      errmsg = desc(4)
510b C                   endsl
510b C                   exsr      zm1001
510b C                   goto      endck1
510b C                   endif
510g C*
510g C     rhkey         chain     rtehed
510g C*
510g C                   if        %found(rtehed)
510g C                   select
510g C                   when      rhrte<='00099' and $psls='2000'
510rAC                             or  rhrte ='99   ' and $psls='2000'
510rAC                             and rhtype = 'W'
510g C                   eval      kyord = ohord
510g C                   leave
510g C*
510g C                   when      rhrte<='00099' and $psls='2100'
510rAC                             or  rhrte ='99   ' and $psls='2100'
510rAC                             and rhtype = 'W'
510g C                   iter
510g C*
510g C                   when      rhrte>='00100' and $psls='2100'
510rAC                             or  rhrte ='199  ' and $psls='2100'
510rAC                             and rhtype = 'W'
510g C                   eval      kyord = ohord
510g C                   leave
510g C*
510g C                   when      rhrte>='00100' and $psls='2000'
510rAC                             or  rhrte ='199  ' and $psls='2000'
510rAC                             and rhtype = 'W'
510g C                   iter
510g C                   endsl
510g C                   endif
510g C*
510g C****               eval      kyord = ohord
510g C                   enddo
510b C                   endif
510hA*
510hA*  Verify Invoice Number.
510i C                   if        w1invc = *blanks
510i C                   eval      error = *on
510i C                   eval      *in23 = *on
510i C                   eval      *in03 = *on
510i C                   eval      errmsg = *blanks
510i C                   select
510i C                   when      e$lng = 'SP'
510i C                   eval      errmsg = descsp(16)
510i C                   other
510i C                   eval      errmsg = desc(16)
500i C                   endsl
510i C                   exsr      zm1001
510i C                   goto      endck1
510i C                   endif
510hA*
510hA*    Validate characters entered for invoice number.
510hAC                   eval      pos  = %check (valid_inv : w1invc)
510hA*
510hA*    Invalid characters in invoice# fields.
510hAC                   If           pos  > 0
510hA*
510hAC                   eval      error = *on
510hA*      Invalid characters found, flag field.
510hAC                   eval      *in03 = *on
510hAC                   eval      *in23 = *on
510hA*
510hAC                   select
510hAC                   when      e$lng = 'SP'
510hAC                   eval      errmsg = descsp(15)
510hA*
510hAC                   other
510hAC                   eval      errmsg = desc(15)
510hAC                   endsl
510hA*
510hAC                   exsr      zm0105
510hA*
510hAC                   goto      endck1
510hAC                   Endif
510hA*
510hA*    Convert characters entered into numeric field.
510hAC                   eval      nbrinv# = 0
510hA*
510hAC                   if        w1invc > ' '
510hAC                             and pos = 0
510hAC                   eval      nbrinv# = %dec(w1invc:12:0)
510hAC                   endif
510hA*
     *
414 A*  Verify Return whole order Y/N.
     *
416iAC                   if        w1rord <> 'Y'  and
416iAC                             w1rord <> 'N'
416iAC                   move      *on           error
416iAC                   eval      *in24 = *on
416iAC                   eval      *in04 = *on
416iAC                   eval      errmsg = *blanks
500e C                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(10)
500eAC                   other
416iAC                   eval      errmsg = desc(10)
500eAC                   endsl
416iAC                   exsr      zm1001
416iAC                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
     C                   eval      wscitm = *blanks
     *
     *  Must enter one value Label, upc, item or UCI.
     *
01   C                   if        w2lbl# = 0  and
     C                             w2upc = *blanks  and
     C                             w2itmu = *blanks
     C                   move      *on           error
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(1)
500eAC                   other
     C                   eval      errmsg = desc(1)
500eAC                   endsl
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     C                   eval      *in25 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm0205
     C                   goto      endck2
     C                   endif
     *
     *  Error, more than one value entered.
     C                   if        w2itmu <> *blanks and
     C                             w2lbl# <> 0  or
     C                             w2itmu <> *blanks and
     C                             w2upc <> *blanks or
     C                             w2lbl# <> 0  and
     C                             w2upc <> *blanks
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     C                   eval      *in25 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0204
     C                   goto      endck2
     C                   endif
     *
     *  Verify label number, get item #
     *
     C                   if        w2lbl# <> 0
     C                   eval      wolbl# = 0
     C                   eval      wotrn# = 0
     C                   eval      woord = 0
     C                   z-add     w2lbl#        wolbl#
     C     wolbl#        chain     label                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(1)
500eAC                   other
     C                   eval      errmsg = desc(1)
500eAC                   endsl
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm1001
     C                   goto      endck2
     C                   else
     C                   move      lbitem        wsitem
     C                   z-add     lbord         wslord
     C                   z-add     lbtrn#        wotrn#
     C                   eval      kyord = lbord
     C     ohkey         chain     ordh                               78
     C                   if        not *in78
     C                   eval      woord = ohcord
     C                   movel     w1dlvy        woinv#
     C*                  movel     ohmisc        woinv#
     C                   endif
     C                   endif
     C                   endif
     *
     C                   select
     *  UPC entered
     C                   when      w2upc <> *blanks
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   movel     w2upc         $cbbar
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w2upc = $cbv2
     C                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
510aDC*                  eval      kyupc = $cstr
510aMC                   move      $cstr         kyupc
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
     C                   eval      upcctr = 0
     C     upckey        setll     upc
     C                   dow       forevr = forevr
     C     upckey        reade     upc                                    79
     *
     C                   if        *in79
     C                   leave
     C                   else
     C                   add       1             upcctr
     C                   endif
     *
     C                   enddo
     *
     **         UPCKEY    CHAINUPC                  79
     C                   if        upcctr = 0
     C                   move      *on           error
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm29
     C                   goto      endck2
     C                   endif
     *
     *   Multiple items exist for UPC
     C                   if        upcctr > 1
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   move      kyupc         $lupc
     C                   call      'UC920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   eval      upitem = $litm1
     *
     C                   endif
     *
     *
     C                   eval      wsitem = upitem
     *
     C                   endsl
     *
     *  Check if UCI or Item was entered.
     *  If pos 10=' ', item was entered.
     *
     C                   eval      wuitem = *off
     C                   if        w2itmu <> *blanks
     C                   eval      chkitm = *blanks
     C                   eval      chkitm = %subst(w2itmu:10:1)
     C                   if        chkitm = *blanks
     C                   eval      wuitem = *on
     C                   eval      wsitem = w2itmu
     C                   else
     C                   eval      wuitem = *off
     C                   endif
     C                   endif
     *
     *  Get item # from UCI
     *
     C                   if        wuitem = *off     and
     C                             w2itmu <> *blanks
     C                   move      w2itmu        kyuci
     C     keyuci        chain     ucicw
     C                   if        not %found(ucicw)
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(9)
500eAC                   other
     C                   eval      errmsg = desc(9)
500eAC                   endsl
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm1001
     C                   goto      endck2
     C                   else
     C                   eval      wsitem = uciitm
     C                   endif
     C                   endif
     *
     *  Get item # from other field entered.
     *
     C                   eval      w2item = *blanks
     C                   if        wsitem <> *blanks
     C                   movel     wsitem        w2item
     C                   endif
     *
     *  Verify item number.
     *
     C                   if        w2item <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w2item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endck2
     C                   endif
     C                   eval      kyitem = w2item
     C                   endif
     *
416 A*   Verify item is on order.
416  *
416 AC     ohkey         setll     ordd
416aAC                   move      *off          stop
416aAC                   move      *off          good1
416aAC                   dou       stop = *on
416aAC     ohkey         reade     ordd                                   79
416aAC                   if        *in79
416aAC                   move      *on           stop
416aAC                   else
416aAC                   if        w2item = oditem
416aAC                   move      *on           good1
416aAC                   leave
416 AC                   endif
416 AC                   endif
416 AC                   enddo
416  *
4166AC                   if        good1 = *off
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm1204
     C                   goto      endck2
     C                   endif
     *  Verify UOM code
xxx  C                   if        w2um <> 'CS'  and
     C                             w2um <> 'EA'
     C                   move      *on           error
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(8)
500eAC                   other
     C                   eval      errmsg = desc(8)
500eAC                   endsl
     C                   exsr      zm1001
     C                   endif
     *
510pA*  Check to see if item# is catchwgt and return code is mispick=65.
510pA*  Catchwgt items can't be mispicked.
510pAC                   if        itcwgt = 'Y'
510pAC                             and w2code = '65'
510pAC                   move      *on           error
510pAC                   eval      *in26 = *on
510pAC                   eval      *in06 = *on
510pAC                   eval      errmsg = *blanks
510pAC                   select
510pAC                   when      e$lng = 'SP'
510pAC                   eval      errmsg = descsp(17)
510pAC                   other
510pAC                   eval      errmsg = desc(17)
510pAC                   endsl
510pAC                   exsr      zm0105
510pAC                   endif
510pA*
     *
     *  Verify normal quantity.
     *
     C                   if        w2qt01 < 0
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(2)
500eAC                   other
     C                   movel     desc(2)       erfld
500eAC                   endsl
     C                   exsr      zm0109
     C                   endif
     *
     *  Quantity must be entered.
     *
     C                   if        w2qt01 = 0
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(2)
500eAC                   other
     C                   movel     desc(2)       erfld
500eAC                   endsl
     C                   exsr      zm0110
     C                   endif
     *
510g *  Quantity must be less than or equal to order qty
     *
510g C                   if        w2qt01 > odqor1
510g C                   move      *on           error
510g C                   eval      *in24 = *on
510g C                   eval      *in04 = *on
510g C                   eval      errmsg = *blanks
510g C                   select
510g C                   when      e$lng = 'SP'
510g C                   eval      errmsg = descsp(2)
510g C                   other
510g C                   movel     desc(2)       erfld
510g C                   endsl
510g C                   exsr      zm1001
510g C                   endif
     *
     *  Verify return code.
     *
     C                   eval      woinvf = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w2code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   move      'N'           woinvf
     C                   endif
     C                   endif
     *
     *  Verify disposition code.
     *  Value must be 1, 2 or 3
     C                   if        w2dcde <> '1'  and
     C                             w2dcde <> '2'  and
     C                             w2dcde <> '3'
     C                   move      *on           error
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg =  descsp(7)
500eAC                   other
     C                   eval      errmsg = desc(7)
500eAC                   endsl
     C                   exsr      zm1001
     C                   endif
     *
510g *  Make sure item is not already returned.
     *
510s C**   rnkeya        setll     orrtn
510s C**   rnkeya        reade(n)  orrtn
510lDC*                  if        %found(orrtn)
510sMC**                 if        not %eof(orrtn)
510s C**                 move      *on           error
510s C**                 eval      *in27 = *on
510s C**                 eval      *in07 = *on
510s C**                 eval      errmsg = *blanks
510s C**                 select
510s C**                 when      e$lng = 'SP'
510s C**                 eval      errmsg =  descsp(14)
510s C**                 other
510s C**                 eval      errmsg = desc(14)
510s C**                 endsl
510s C**                 exsr      zm1001
510s C**                 endif
     *
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     *
     *
     *  Verify return code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w3code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *
     C     error         cabeq     *on           endck3
     *
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
416i *  ZZCHK4   Screen 4 error checking.
     *
416i C     zzchk4        begsr
416i C                   move      *off          error
416i *
     *  Mispick item must be entered.
     *
     C                   if        w4citm = *blanks
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(11)
500eAC                   other
     C                   movel     desc(11)      erfld
500eAC                   endsl
     C                   exsr      zm0109
     C                   endif
     *  Mispick item must be different than ordered item.
     *
     C                   if        w4citm = wsitem
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(11)
500eAC                   other
     C                   eval      errmsg = desc(11)
500eAC                   endsl
     C                   exsr      zm1202
     C                   endif
     *
     *
     *  Verify mispick item.
     *
     C                   if        w4citm <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w4citm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endck4
     C                   endif
     C                   endif
     *
416m *  If mispick, get info for mispick item.
416m C                   if        w4citm <> *blanks
416m C                   move      w4citm        kyitem
416m C                   endif
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   move      *off          error
     *  License # must be entered.
     C                   if        w5lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm033
     C                   endif
     *  Left justify license.
     C                   eval      $cstr = *blanks
     C                   eval      $cstr = w5lcns
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd             8
     C                   parm                    $cstr            30
     C**                 parm                    $frtn
     C                   movel     $cstr         w5lcns
     *  Check for invalid characters.
     C                   eval      *in81 = *off
     C     valid         check     w5lcns                               81
     C                   if        *in81 = *on
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
     C                   movel     desc(3)       erfld
500eAC                   endsl
     C                   exsr      zm1001
     C                   endif
     *
     *  License # must be unique.
     *
     C                   if        w5lcns <> *blanks
     C     lckey         setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   endif
     C                   endif
     *
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 5
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Item.
     *
     C                   when      row# = 4
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w2item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w2item = $litem
     C                   endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     *     Return code.
     *
     C                   when      row# = 11
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lcode = w2code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w2code = $lcode
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *  Test for F9 - Done
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endif
     *
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Return code.
     *
     C                   when      row# = 05
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lcode = w3code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w3code = $lcode
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Corresponding item number.
     *
     C                   when      row# = 06
     C                   eval      *in15 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     *
     C                   eval      $litem = w4citm
510kDC*                  call      'IT900'
510kDC*                  parm                    $lparm
510kMC                   call      'IT230CL'
     C                   if        $lrtn = '*SELECT '
510kDC*                  eval      w4citm = $litem
     C                   endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm4
     C                   endif
     *
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm5
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     C     endcm5        endsr
500dA*----------------------------------------------------------------
500dA*  zzerrind    Set error indicators from DRI call.
500dA*----------------------------------------------------------------

500dAC     zzerrind      begsr

     C                   if        $sldispe = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $slstate = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $slprtye = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $sacodee = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
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

500dAC                   endsr

     *----------------------------------------------------------------
     *
     *  zzexcp Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record for item
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      exwhdp = itwhdp
     C                   eval      exstyp = itstyp
     C                   else
     C                   eval      exwhdp = *blanks
     C                   eval      exstyp = *blanks
     C                   endif
     *
      *
     *  Use DRI interface to get Slot item for ordered item
      *
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = exitem
     C                   exsr      zzsltitm
     *
     C                   eval      $scmd = '*FIRST'
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse            3 0
     C                   parm      $ititem       #sitem           15
    DC*                  parm      exitem        #sitem           15
     C                   parm                    woslot           12
     C                   parm                    $saisl            3
     C                   parm                    $sloc             3 0
     C                   parm                    $srlvl            2 0
     C                   parm                    $shand            2
     C                   parm                    $srtn             8
     C                   if        $srtn <> '*NONE   '
     C                   eval      extdis = woslot
     C                   else
     C                   eval      extdis = *blanks
     C                   endif
     C                   eval      exwhse = w1whse
650 A*
650 AC                   if        w2qt01 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     w2qt01        exqty
650 AC                   endif
650 A*
     C                   eval      exqty2 = 0
     C                   eval      exqty3 = 0
     C                   eval      extask = 'PUTRTN'
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      exgdte = $cvd8o
     C                   time                    exgtim
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     *
     C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     w1whse        parm      0             #whse             3 0
210 A*
223 AC                   exsr      zzlcns
     *
     C                   eval      woord = 0
     C                   eval      w1dlvy = *blanks
     C                   eval      w1invc = *blanks
     C                   eval      w1rord = 'N'
416FD*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get Unit of measure fields
     C***                exsr      zzuom
     *
     *   Initialize entry fields
     *
     C                   eval      w2itmu = *blanks
     C                   eval      w2upc = *blanks
     C                   eval      w2lbl# = 0
     C                   eval      w2qt01 = 0
510g C                   eval      w2um = 'CS'
510g C***                eval      w2um = *blanks
     C                   eval      w2dcde = *blanks
     C                   eval      w2code = *blanks
     **
510oAC                   eval      w4citm = ' '
510oAC                   eval      wwidte = 0
     **
     C                   endsr
     *----------------------------------------------------------------
     *
416b *  ZZFIL3   Fill screen 3 fields with info from file.
     *
416b C     zzfil3        begsr
     *
     C                   eval      w3code = *blanks
     *
     *
416b C                   endsr
     *----------------------------------------------------------------
416i *
416i *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w4citm = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w5lcns = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   move      *off          forevr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    kyitem
     *
     *  Define partial key for License file.
     C     lckey         klist
     C                   kfld                    w1whse
     C                   kfld                    w5lcns
     *
     *  Define key for License file.
     C     lckeyf        klist
     C                   kfld                    w1whse
     C                   kfld                    w5lcns
     C                   kfld                    pttrn#
     *
     C     ohkey         klist
     C                   kfld                    w1whse
     C                   kfld                    kyord
510X C*                  kfld                    lbord
     *
     C     oh5key        klist
     C                   kfld                    w1whse
     C                   kfld                    kyord
     *
     C     ohmkey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1dlvy
     *
     *  Define key for UCICW file.
     *
     C     keyuci        klist
     C                   kfld                    w1whse
     C                   kfld                    kyuci
     *
     *  Define key for UPC file.
     *
     C     upckey        klist
     C                   kfld                    w1whse
     C                   kfld                    kyupc
     *
416jA*
416jA*  Define key for ORRTN2 return whole order.
416jA*
416jAC     rtnkey        klist
416jAC                   kfld                    w1whse
416jAC                   kfld                    wslord
416jAC                   kfld                    kywhol
     *
     C     partk2        klist
     C**                 kfld                    $rord
     C                   kfld                    $pbat
     C                   kfld                    w1whse
223 A*
223 A*     OPTIONS
223 A*
223 AC     opkey         klist
223 AC                   kfld                    w1whse
223 AC                   kfld                    ocode
223 A*
415bA*
415bA*  Define key for OPTIOND.
415bA*
415bAC     opkey2        klist
415bAC                   kfld                    kycode
415bAC                   kfld                    itwhse
415bAC                   kfld                    itwhdp
415bAC                   move      '*PICK   '    kycode
416m *
416m *  Define key for ITEMMSC file.
416m *
416mAC     imkey         klist
416mAC                   kfld                    itwhse
416mAC                   kfld                    ititem
     *
510g *  Define key for RTEHED file.
     *
510g C     rhkey         klist
510g C                   kfld                    ohwhse
510g C                   kfld                    ohrte
     *
510g *  Define key for ORRTN file.
     *
510g C     rnkeya        klist
510g C                   kfld                    w1whse
510jDC*                  kfld                    wslord
510jMC                   kfld                    woord
510g C                   kfld                    wsitem
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
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *   Set flag if called from Quick Return .
     C                   if        $pqck = 'Y'
     C                   move      *on           quick
     C                   eval      rtntyp = 'Q'
     C                   eval      *in55 = *on
     C                   else
     C                   eval      quick = *off
     C                   eval      rtntyp = ' '
     C                   eval      *in55 = *off
     C                   endif
     *
     *   Initialize headings and return type.
     *
416cAC                   if        $pqck = 'N'
416CAC                   move      ' '           rtntyp
416cAC                   else
416CAC                   move      'Q'           rtntyp
416cAC                   endif
500eA*
500eA*   Get employee options.
500eA*
500eAC                   call      'GETUSER'
500eAC                   parm      #user         e$code           10
500eAC                   parm                    e$whse            3 0
500eAC                   parm                    e$emp#            5 0
500eAC                   parm                    e$fnam           15
500eAC                   parm                    e$init            1
500eAC                   parm                    e$lnam           20
500eAC                   parm                    e$whdp            5
500eAC                   parm                    e$styp            1
500eAC                   parm                    e$shft            6
500eAC                   parm                    e$crew            6
500eAC                   parm                    e$nhrs            3 1
500eAC                   parm                    e$rtn             8
500eAC                   parm                    e$bpu             1
500eAC                   parm                    e$lng             2
500eAC                   if        e$rtn <> '*OK'
500eAC                   eval      e$lng = 'EN'
500eAC                   endif
500eA*
     *
     *   Display first screen.
     *
     C                   move      *on           refrsh
     C                   eval      usesc = 1
416fD*
     C                   exsr      scr01i
     *
     C                   endsr
     *----------------------------------------------------------------
     *
223 A*  ZZLCNS   Get use generic license option
     *
223 AC     zzlcns        begsr
     *
223 A*   Get use generic license option.
223 AC                   move      '0'           lcnflg
223 AC                   move      '*RCVLBL '    ocode
     *
223 AC     opkey         chain     options                            79
223 AC                   if        not *in79
223 AC                   if        opplcn = 'Y'
223 AC                   move      '1'           lcnflg
223 AC                   endif
223 AC                   endif
     *
223 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZMPCK   Create Mispick adjustments and exception rec.
     *
     C     zzmpck        begsr
     *      If mispick, create exceptions for item and corresponding item
     *      if both items don't have pick slots.
     C                   eval      exfdis = *blanks
     *
1    C                   if        w4citm <> *blanks
     C                   eval      exitem = wsitem
     C                   eval      excitm = w4citm
     C                   eval      exerid = 'MISPICK'
     C                   exsr      zzpslt
     C                   if        picksl = *off
     C                   movel     '*ORDER'      exfdis
     C                   exsr      zzexcp
     C                   eval      kyitem = w4citm
     C                   eval      exitem = w4citm
510 DC*                  eval      excitm = $pitem
     C                   eval      excitm = wsitem
     C                   eval      exerid = 'MISPICK'
     C                   movel     '*PUT  '      exfdis
     C                   exsr      zzexcp
     C                   else
     *       Write adjustment for ordered item.
     C                   eval      ajcode = 'MO'
     C                   eval      kyitem = wsitem
     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     *       Write adjustment for physical item.
     C                   eval      kyitem = w4citm
     C                   eval      ajcode = 'MP'
     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
510tDC*                  eval      $drisubcmd  = '%ADJUST'
510tMC                   eval      $drisubcmd  = '%ADJUSTORD'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZNSTK   Update files to NOT return product to stock.
     *
     C     zznstk        begsr
     *
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rtndate = $cvd8o
     C                   time                    rtntime
     *
     *  Create label, license and pirtran rec.
415aAC                   call      'RN246L'
415aAC                   parm                    $lparm
415aAC                   parm                    $lord
415aAC                   if        $lrtn = '*CANCEL '
415aAC                   select
415aAC                   when      w2code <> '25 '
415aAC                   eval      nxtscr = '02 '
415aAC                   eval      refrsh = *on
415aAC                   goto      endnst
415aAC                   when      w2code = '25 '
415aAC                   eval      nxtscr = '04 '
415aAC                   eval      refrsh = *on
415aAC                   goto      endnst
500cAC                   endsl
500cAC                   endif
     C                   eval      $pbat = $lord
     *  Update POMFR file.
     C                   exsr      zzumfr
     *  If mispick, create exception and adjustments.
     C                   if        w4citm <> *blanks
     C                   exsr      zzmpck
     C                   endif
510e ** Call program for UCI
510e C**                 if        itcwgt = 'Y'
510e ** Get current label using batch #
510e C**   $pbat         setll     label1
510e C**                 move      *off          stop
510e C**                 dou       stop = *on
510e C**   $pbat         reade     label1                                 79
510e C**                 if        *in79
510e C**                 move      *on           stop
510e C**                 else
510e C**                 eval      $llbl# = lblbl#
510e C**                 endif
510e C**                 enddo
510e C**                 eval      $lcmd = '*RETURN '
510e C**                 eval      $lwhse = w1whse
     C***                eval      $llbl# = lblbl#
510e C**                 eval      $lpqty = lbqalc
510e C**                 call      'CE120'
510e C**                 parm                    $lparm
510e C**                 endif
     *
510e *  Call program for UCI
510e C                   if        itcwgt = 'Y'
510e *  Get current label using batch #
510e C     $pbat         setll     label1
510e C                   move      *off          stop
510e C                   dou       stop = *on
510e C     $pbat         reade     label1                                 79
510e C                   if        *in79
510e C                   move      *on           stop
510e C                   endif
510e C                   enddo
     *
510e C                   if        lbqalc>0
510e C                   eval      $lcmd = '*ADDADJ '
510e C                   endif
     *
510e C                   if        lbqalc<0
510vDC**                 eval      $lcmd = '*DELADJ '
510vMC                   eval      $lcmd = '*DLTADJ '
510e C                   endif
     *
510hDC*                  movel     w1invc        w1inv#           10
510hMC                   move      nbrinv#       w1inv#           10
510e C                   movel     w2dcde        wkdcde            5
510e C                   eval      $lprg  = #prog
510e C                   eval      $lwhseu = w1whse
510e C                   eval      $litemu = lbitem
510e C                   eval      $lcodeu = w2code
510e C                   eval      $ltypeu = 'R'
510e C                   eval      w1qt01p = lbqalc
510e C                   eval      w1qt02p = 0
510e C                   eval      w1qt03p = 0
510e C                   eval      $ldate  = rtndate
510e C                   eval      $ltime  = rtntime
510e C                   call      'CW133'
510e C                   parm                    $lparm
510e C                   parm                    $pbat
510e C                   parm                    w1dlvy
510e C                   parm                    w1inv#
510e C                   parm                    wkdcde
510e C                   endif
     *  Create return records.
510e C                   exsr      zzwrtn
     *
     *
     C     endnst        endsr
416  *----------------------------------------------------------------
416  *
416iA*  ZZORD    Process to return whole order.
416  *
416iAC     zzord         begsr
416  *
416 A*   Process all records for order number.
416 AC                   move      '0'           lcnflg
416 AC                   move      '*RCVLBL '    ocode
416  *
416 AC     ohkey         setll     ordd
416aAC                   move      *off          stop
416aAC                   dou       stop = *on
416aAC     ohkey         reade     ordd                                   79
416aAC                   if        *in79
416aAC                   move      *on           stop
416aAC                   else
4166AC                   eval      lllblo = wolbl#
416 AC                   endif
416 AC                   enddo
     *
416 AC                   endsr
     *
416lA*----------------------------------------------------------------
416lA*
416lA*  ZZPSLT   Get Put pick slot for mispick items
416lA*
416lAC     zzpslt        begsr
     *
416lAC                   move      *off          picksl
416lAC                   eval      oslot = *zeros
416lAC                   eval      pslot = *zeros
416lAC                   movel     '*FIRST'      $scmd
416lAC                   call      'GETPSLT'
416kAC                   parm                    $scmd             8
416kAC                   parm      w1whse        $swhse            3 0
416lMC**                 parm      exitem        #sitem
416lMC                   parm      w2item        #sitem           15
416lAC                   parm                    woslot           12
416lAC                   parm                    $saisl            3
416lAC                   parm                    $sloc             3 0
416lAC                   parm                    $srlvl            2 0
416lAC                   parm                    $shand            2
416lAC                   parm                    $srtn             8
416lAC                   if        $srtn <> '*NONE   '
416lAC                   move      woslot        oslot
     *
416lAC                   movel     '*FIRST'      $scmd
416lAC                   call      'GETPSLT'
416lAC                   parm                    $scmd
416lAC                   parm      w1whse        $swhse
416lMC****               parm      excitm        #sitem
416lMC                   parm      w4citm        #sitem
416lAC                   parm                    woslot
416lAC                   parm                    $saisl
416lAC                   parm                    $sloc
416lAC                   parm                    $srlvl
416lAC                   parm                    $shand
416lAC                   parm                    $srtn
416lAC                   if        $srtn <> '*NONE   '
416lAC                   move      woslot        pslot
     *
416lAC                   move      *on           picksl
416lAC                   endif
416lAC                   endif
416lAC                   endsr
     *
     *----------------------------------------------------------------
     *  zzsltitm    Get slot item (base item)
     *----------------------------------------------------------------

     C     zzsltitm      begsr


     *  Use DRI interface to get Slot item.

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSLOT'
     C                   eval      $drisys2upd = 'D'
    DC***                eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error  = *on
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     *
     C     enditm        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  ZZULCN   Create label, license, pirtran rec
     *
     C     zzulcn        begsr
     *
     C                   move      'R'           @PGRP1
     C*
     C*  Get batch number for labels.
     C*
     C                   call      'PIRBAT#'                                G
     C                   parm      *zeros        $pbat             7 0      G
     C*
     C*  Get transaction number.
     C*
     C                   call      'PIRTRN#'                                G
     C                   parm                    pttrn#            7 0      G
     C*  - Create label record for each quantity type.
     C*
     C*    Create label record for Normal qty.
     C                   clear                   lbrec
     C                   eval      lbwhse = w1whse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = 0
     C                   eval      lbrlvl = 0
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = 0
     C                   eval      lbstyp = itstyp
     C                   eval      lbqryf = 0
     C                   eval      lbdisp = *blanks
     C                   movel     '*MANUAL'     lbdsp2
     *      If mispick, create for mispicked item to be put away.
     C                   if        w4citm <> *blanks
     C                   eval      lbitem = w4citm
     C                   eval      lbord = woord
     C                   else
     C                   eval      lbitem = wsitem
     C                   eval      lbord = wslord
     C                   endif
     C                   eval      lbseq = 0
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = *blanks
     C                   eval      lbqalc = w2qt01
     C                   eval      lbqpck = w2qt01
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     C*        Create label record for Normal qty.
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = w2um
     C                   eval      lbucub = itcube
     C     lbucub        mult      w2qt01        lbcube
     C                   eval      lbuwgt = itswgt
     C     lbuwgt        mult      w2qt01        lbswgt
     C                   eval      lbtrn# = pttrn#
     C                   call      'PIRLBL#'                                G
     C                   parm                    lblbl#                     G
     C                   eval      lbgrp1 = @pgrp1
     C                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *    Create transaction record
     C                   eval      @pwhdp = itwhdp
     C                   eval      @pstyp = itstyp
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
xx   C                   parm      '*INTER'      @ptype
     C                   parm      pttrn#        @ptrn#
     C                   parm      'PUTRTN'      @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      itwhdp        @pwhdp
     C                   parm      itstyp        @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      1             @paisl
     C                   parm      1             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      'R'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      *zeros        @pdate
     C                   parm      *zeros        @ptime
     C                   parm      #user         @puser
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *    Create license record.
     C     lckeyf        chain     license                            79
     C                   eval      liwhse = w1whse
     C                   eval      lilcns = w5lcns
     C                   eval      litrn# = pttrn#
     C*     Record not found. Try adding record.
     C                   if        not%found
     C                   write     lirec
     C                   endif
     *
     C     endulc        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZULNK   Update for LABELNK FILE
     *
     C     zzulnk        begsr
     *
     *
     *      Write to label link file if Label # was entered.          .
     *
     *
     C                   if        wolbl# <> 0
     C     partk2        setll     label2
     C                   move      *off          stop
     C                   dou       stop = *on
     C     partk2        reade     label2                                 79
     C                   if        *in79
     C                   move      *on           stop
     C                   else
     C                   eval      lllblo = wolbl#
     C                   eval      lllbl# = lblbl#
     C                   eval      lltrn# = lbtrn#
     C                   eval      llqpck = lbqpck
     C                   eval      llucod = lbucod
     C                   write     llrec
     C                   endif
     C                   enddo
     C                   endif
     C     endlnk        endsr
     *----------------------------------------------------------------
     *
     *  ZZUMFR   Update for POMFR FILE
     *
     C     zzumfr        begsr
     *
     C                   if        wwidte <> 0
     *
     C     partk2        setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partk2        reade     label2                                 79
     C*
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = w1whse
     C                   eval      pmpo = *blanks
     C                   eval      pmseq = 0
416mD**                   MOVE $PITEM    PMITEM
     C                   if        w4citm <> *blanks
     C                   eval      pmitem = w4citm
     C                   else
     C                   eval      pmitem = w2item
     C                   endif
     C                   eval      pmexpd = expd
416mA**                   Z-ADD$REXPD    PMEXPD
     C                   if        wwidte <> 0 and
     C                             immflg = 'Y'
     C                   move      wwidte        $cvd6i
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      pmmfgd = $cvd8o
     C                   else
     C                   eval      pmmfgd = 0
     C                   endif
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   if        *in78  = *off
     C                   update    pmrec
     C                   else
     C                   write     pmrec
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   endif
     *
     C                   endsr
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
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C     itkey         chain     piritem                            75
     C                   if        *in75
     C                   eval      *in94 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
     C                   if        itflg1 = 'N'
     C                   eval      *in94 = *on
     C                   endif
     C                   if        itflg2 = 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
     C     itum1         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um = umshrt
     C                   else
     C                   eval      w2um = *blanks
     C                   endif
     *
     C                   if        not *in94
     C     itum2         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um = umshrt
     C                   else
     C                   eval      w2um = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C     itum3         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um = umshrt
     C                   else
     C                   eval      w2um = *blanks
     C                   endif
     C                   endif
415cA*
415cAC                   if        ittype = 'S'
415cAC                   eval      itum1 = itum2
415cAC                   eval      itum2 = itum3
415cAC                   eval      itum3 = *blanks
415cAC     itum1         chain     unmesr                             75
415cAC                   if        not *in75
415cAC                   eval      w2um = umshrt
415cAC                   else
415cAC                   eval      w2um = *blanks
415cAC                   endif
     *
415cAC     itum2         chain     unmesr                             75
415cAC                   if        not *in75
415cAC                   eval      w2um = umshrt
415cAC                   else
415cAC                   eval      w2um = *blanks
415cAC                   endif
     *
415cAC                   endif
     *
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   move      *off          error
     *
     *  Get customer order # using delivery #.
     *
     C**                 if        w1rord = 'Y'
     C**                 movel     w1dlvy        kydlvy
     C**   oh5key        setll     ordh5
     C**   oh5key        reade     ordh5
     C**   hmord         chain     ordh
     *
510b C                   if        w1whse <> 1
     C                   eval      kyord = hmord
     C     oh5key        chain     ordh
     C                   if        %found(ordh)
     C                   eval      woord = ohcord
     C                   eval      wslord = ohord
     C                   else
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   eval      errmsg = descsp(4)
500eAC                   other
     C                   eval      errmsg = desc(4)
500eAC                   endsl
     C                   exsr      zm1001
     C                   goto      endup1
     C                   endif
510b C                   endif
     *
510b *  Get customer order number
510b *  For Alpha interface only.
510b C                   if        w1whse = 1
     C                   eval      kyord = %dec(w1dlvy:7:0)
510b C     oh5key        setll     ordh5
510g C                   dow       forevr = forevr
510b C     oh5key        reade     ordh5
510g C*
510qDC*                  if        not %found(ordh5)
510qMC                   if        %eof(ordh5)
510b C                   eval      error = *on
510b C                   eval      *in22 = *on
510b C                   eval      *in02 = *on
510b C                   eval      errmsg = *blanks
510b C                   select
510b C                   when      e$lng = 'SP'
510b C                   eval      errmsg = descsp(4)
510b C                   other
510b C                   eval      errmsg = desc(4)
510b C                   endsl
510b C                   exsr      zm1001
510b C                   goto      endup1
510g C                   endif
     C*
510g C*
510g C     rhkey         chain     rtehed
510g C*
510g C                   if        %found(rtehed)
510g C                   select
510g C                   when      rhrte<='00099' and $psls='2000'
510rAC                             or  rhrte ='99   ' and $psls='2000'
510rAC                             and rhtype = 'W'
510g C                   eval      woord = ohcord
510g C                   eval      wslord = ohord
510g C                   eval      kyord = ohord
510g C                   leave
510g C*
510g C                   when      rhrte<='00099' and $psls='2100'
510rAC                             or  rhrte ='99   ' and $psls='2100'
510rAC                             and rhtype = 'W'
510g C                   iter
510g C                   iter
510g C*
510g C                   when      rhrte>='00100' and $psls='2100'
510rAC                             or  rhrte ='199  ' and $psls='2100'
510rAC                             and rhtype = 'W'
510g C                   eval      woord = ohcord
510g C                   eval      wslord = ohord
510g C                   eval      kyord = ohord
510g C                   leave
510g C*
510g C                   when      rhrte>='00100' and $psls='2000'
510rAC                             or  rhrte ='199  ' and $psls='2000'
510rAC                             and rhtype = 'W'
510g C                   iter
510g C                   endsl
510g C                   endif
510g C*
510g C                   enddo
     C*
510b C                   endif
     *
     *  Verify whole order was not previously returned.               turns)
     *
     C                   if        w1rord = 'Y'
     C                   move      'Y'           kywhol
     *
     C     rtnkey        setll     orrtn2
     C                   move      *off          stop
     C                   dou       stop = *on
     C     rtnkey        reade     orrtn2                                 79
     C                   if        *in79
     C                   move      *on           stop
     C                   else
     C                   move      *on           stop
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm1201
     C                   goto      endup1
     C                   endif
     C                   enddo
     *
     C                   endif
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   if        w2dcde = '1'  or
     C                             w2dcde = '2'
     C                   eval      woiinv = 'Y'
     C                   else
     C                   eval      woiinv = 'N'
416b C                   movel     '*NOSTOCK'    $lpo
416b C                   eval      lcnflg = *off
416gMC                   eval      woulbl = 'N'
416b C                   endif
     C                   eval      w2ulbl = 'N'
     *
     C     itkey         chain     piritem                            75
     C                   if        %found  and
     C                             itflgd = 'Y'
     *
     *   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
     *
     C     imkey         chain     itemmsc                            79
     C                   if        %found  and
     C                             immflg = 'Y'
     C                   eval      wdwlabel = 'MFG DATE'
     C                   eval      *in87 = *off
     C                   eval      *in96 = *on
     C                   else
     C                   eval      immflg = 'N'
     C                   eval      wdwlabel = 'EXP DATE'
     C                   eval      *in87 = *on
     C                   endif
     *
     *  Prompt user for date.
     *
510b C                   If        itflgd = 'Y'
     C                   Exsr      zzwdwprompt
     C                   if        *inkc = *on
     C                             or *inkl = *on
     C                   eval      *inkc = *off
     C                   eval      *inkl = *off
     C                   eval      error = *on
     C                   goto      endup2
     C                   Endif
     C                   Endif
     *
     C                   Endif
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     * Return whole order
     C                   if        w1rord = 'Y'
     C                   move      w1whse        $wwhse
     C                   eval      $wrtn = *blanks
     C                   move      wslord        $wlord
     C                   move      'Y'           $wmput
     C                   move      w3code        $wcode
510  C*                  move      w4dcde        $wdcde
     C                   move      '1    '       $wdcde
     C                   move      #user         $wusr
     C                   move      woord         $wcord
     C                   move      'N'           $winvf
510hDC*                  movel     w1invc        w1inv#           10
510hMC                   move      nbrinv#       w1inv#           10
     C                   call      'RN622CL'
     C                   parm                    $wwhse
     C                   parm                    $wrtn
     C                   parm                    $wlord
     C                   parm                    $wmput
     C                   parm                    $wcode
     C                   parm                    $wdcde
     C                   parm                    $wusr
     C                   parm                    $wcord
     C                   parm                    $winvf
510f C                   parm                    w1dlvy
510f C                   parm                    w1inv#
510f C                   parm                    $PSLS
     C                   if        $wrtn = '*CANCEL '
     C                   move      *off          refrsh
     C                   exsr      scr01i
     C                   goto      endup3
     C                   endif
     *
     C                   move      *on           refrsh
     C                   exsr      scr01i
     C                   goto      endup3
     C                   endif
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   move      *off          error
     *
     C     endup4        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 1.
     *
     C     zzupd5        begsr
     C                   move      *off          error
     *
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rtndate = $cvd8o
     C                   time                    rtntime
     *
     *  Create label, license and pirtran rec.
     C                   exsr      zzulcn
     *  Update POMFR file.
     C                   exsr      zzumfr
     *      Write to label link file if Label # was entered.          .
     C                   if        wolbl# <> 0
     C                   exsr      zzulnk
     C                   endif
     *      If mispick, create exception and adjustments.
     C                   if        w4citm <> *blanks
     C                   exsr      zzmpck
     C                   endif
510e **     Create return records.
510e C**                 exsr      zzwrtn
510e *  Call program for UCI
510e C**                 if        itcwgt = 'Y'
510e C**                 eval      $lcmd = '*RETURN '
510e C**                 eval      $lwhse = w1whse
510e C**                 eval      $llbl# = lblbl#
510e C**                 eval      $lpqty = lbqpck
510e C**                 call      'CE120'
510e C**                 parm                    $lparm
510e C**                 endif
     *
510e *  Call program for UCI
510e C                   if        itcwgt = 'Y'
     *
510e C                   if        lbqpck>0
510e C                   eval      $lcmd = '*ADDADJ '
510e C                   endif
     *
510e C                   if        lbqpck<0
510vDC**                 eval      $lcmd = '*DELADJ '
510vMC                   eval      $lcmd = '*DLTADJ '
510e C                   endif
     *
510hDC*                  movel     w1invc        w1inv#           10
510hMC                   move      nbrinv#       w1inv#           10
510e C                   movel     w2dcde        wkdcde            5
510e C                   eval      $lprg  = #prog
510e C                   eval      $lwhseu = w1whse
510e C                   eval      $litemu = lbitem
510e C                   eval      $lcodeu = w2code
510e C                   eval      $ltypeu = 'R'
510e C                   eval      w1qt01p = lbqalc
510e C                   eval      w1qt02p = 0
510e C                   eval      w1qt03p = 0
510e C                   eval      $ldate  = rtndate
510e C                   eval      $ltime  = rtntime
510e C                   call      'CW133'
510e C                   parm                    $lparm
510e C                   parm                    $pbat
510e C                   parm                    w1dlvy
510e C                   parm                    w1inv#
510e C                   parm                    wkdcde
510e C                   endif
     *  Create return records.
510e C                   exsr      zzwrtn
     *
     *
     C     endup5        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZWRTN   Write Return record.
     *
     C     zzwrtn        begsr
416b C                   clear                   orrec
416b C                   eval      orwhse = w1whse
416bAC                   eval      ortrn# = wotrn#
415bMC                   eval      orord = woord
     C                   if        woiinv = 'N'
415bMC                   eval      oroord = 0
415bMC                   else
415bMC                   eval      oroord = wslord
415bMC                   endif
415bD*R                   Z-ADD0         ORORD
416b C                   eval      oritem = wsitem
416b C                   eval      orqty1 = w2qt01
416b C                   eval      orqty2 = 0
416b C                   eval      orqty3 = 0
415bD*R                   Z-ADD0         ORCWTR
     C                   eval      orrdte = rtndate
     C                   eval      orrtim = rtntime
416fMC                   eval      orrusr = #user
     C                   move      rtntyp        ortype
     C                   eval      orpbat = $pbat
     C                   eval      orcitm = w4citm
     C                   eval      orrcod = w2code
     C                   eval      ordcod = w2dcde
     C                   eval      oriinv = woiinv
     C                   eval      orolb# = wolbl#
510hDC*                  move      w1invc        orinv#
510hMC                   move      w1dlvy        orinv#
     C                   eval      orrmem = *blanks
     C                   eval      orslot = *blanks
     C*                  move      w1slot        orslot
510mAC*
510mAC*  Write moved to very end to prevent returns from being picked up
510mAC*  before they are complete.
510mDC*                  write     orrec

      *  Write orrtnm, record.

     c                   eval      rmwhse = orwhse
     c                   eval      rmord  = orord
PCKeAc                   eval      rmitem = oritem
PCKeAc                   eval      rmrdte = orrdte
PCKeAc                   eval      rmrtim = orrtim
PCKeAc                   eval      rmpbat = orpbat
PCKeAc                   eval      rmtrn# = ortrn#
PCKeAc                   eval      rmrcod = orrcod
PCKeAc                   eval      rmdcod = ordcod
PCKeAc                   eval      rmudte = *zeros
PCKeAc                   eval      rmutim = *zeros
510hAc                   if        orwhse = 1
510hDC*                  eval      pakrm1_delv = w1invc
510hMC                   move      nbrinv#       pakrm1_delv
PCKeAc**                 eval      pakrm1_bdoc = w1bil#
510hDc*                  if        orwhse = 1
510aAc                   eval      pakrm1_vkorg = $psls
510hAc                   else
510hAc                   eval      pakrm1_delv = w1dlvy
510hAC                   move      nbrinv#       pakrm1_bdoc
510a c                   endif
PCKeAc                   eval      rmmsc1 = pakrm1_base
PCKeAc                   eval      rmmsc2 = *blanks
PCKeAc                   eval      rmmsc3 = *blanks
PCKeAc                   eval      rmmsc4 = *blanks
PCKeAc                   eval      rmmsc5 = *blanks

PCKeAc                   write     rmrec
510mA
510mMC                   write     orrec
510mA
     C     endwrt        endsr
     *----------------------------------------------------------------
     *
     *  ZZWDWCK1   Window 1 edit check
     *
     C     zzwdwck1      Begsr
     C                   move      *off          error1
     *
     *  Date must be entered.
     *
     C                   If        wwidte = 0
     C                   move      *on           error1
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(13)    errmsg
500eAC                   other
     C                   movel     desc(13)      errmsg
500eAC                   endsl
     C                   exsr      zm1008
     C                   Endif
     *
     *  Verify date (For Manufacturer and expiration dates)
     *
     C                   If        wwidte <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      wwidte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error1 = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     C     error1        cabeq     *on           endckw
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error1 = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $cvmsg
     C                   z-add     wwidte        erdate
     C                   exsr      zm9906
     C     error1        cabeq     *on           endckw
     C                   endif
     C                   eval      wwidte = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   move      $cvd8o        mfgd
     C                   endif
     C                   endif
     *
     *  Verify manufacturing date.
     *
     C                   select
     C                   when      immflg = 'Y'
     C                   if        mfgd > today
     C                   move      *on           error1
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1010
     C                   endif
     *
     C     error1        cabeq     *on           endckw
     *
     *  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
     *
510cA
510cAC                   call      'CLCDUR2'
510cAC                   parm      '*ADD'        $cdcmd
510cAC                   parm      expd          $cddatein
510cAC                   parm      0             $cdtimein
510cAC                   parm      0             $cdyears
510cAC                   parm      0             $cdmonths
510cAC                   parm      immday        $cddays
510cAC                   parm      0             $cdhours
510cAC                   parm      0             $cdminutes
510cAC                   parm      0             $cdseconds
510cAC                   parm      0             $cddateout
510cAC                   parm      0             $cdtimeout
510cA
510cAC                   call      'CLCDUR2'
510cAC                   parm      '*SUB'        $cdcmd
510cAC                   parm      $cddateout    $cddatein
510cAC                   parm      0             $cdtimein
510cAC                   parm      0             $cdyears
510cAC                   parm      0             $cdmonths
510cAC                   parm      imuday        $cddays
510cAC                   parm      0             $cdhours
510cAC                   parm      0             $cdminutes
510cAC                   parm      0             $cdseconds
510cAC     expd          parm      0             $cddateout
510cAC                   parm      0             $cdtimeout
510cA
510cAC                   eval      $cvcmd = '*CMDMDY '
510cAC                   move      expd          $cvd8i
510cAC                   call      @cvtdt
510cAC                   parm                    $cvtdt
510cAC                   move      $cvd6o        woexpd

510dDC***************    move      wwidte        g$date
     C*                  eval      dtfrmt = 2
     C*                  exsr      gtoj$
     C*                  eval      mfdtj = g$jd
     *
     C*                  eval      j$jd = mfdtj + immday
     C*                  eval      j$jd = j$jd - imuday
     C*                  exsr      jtog$
     C*                  move      j$date        $cvd6o
     C*                  eval      woexpd = $cvd6o
     *
     C*                  eval      $cvcmd = '*MDYCMD '
     C*                  move      woexpd        $cvd6i
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  move      $cvd8o        expd
     *******************
     *  Verify Expiration date is not already expired.                 days)
510u C                   if        expd <= today and w2dcde<>'2'
     C                   eval      expd = 0
     C                   move      *on           error1
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm4002
     C                   endif
     *
     C                   when      immflg <> 'Y'
     *  Verify expiration date (not mfg dated)
     *
510u C                   if        expd <= today and w2dcde<>'2'
     C                   move      *on           error1
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1009
     C     error1        cabeq     *on           endckw
     C                   endif
     *
     C                   endsl
     *
     *
     C     endckw        Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDWPROMPT   Window Prompt for date.
     *
     C     zzwdwprompt   begsr
     *
     C                   eval      error1   = *off
     C                   eval      cancel   = *off
     C                   eval      wdwinuse = '*YES'
     C                   eval      wdwtitle = title01
     C                   if        immflg = 'Y'
     C                   eval      wdwlabel = title02
     C                   else
     C                   eval      wdwlabel = title03
     C                   endif
     *
     C                   eval      wwidte = *zeros
     *
     *
     *    Write window definition record
     C                   write     window1
     *
     C                   Dow       Forever = Forever
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     C                   exfmt     wdwfmt1
     *
     C                   setoff                                       0304
     C                   setoff                                       2324
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     *   F3 or F12 selected by user.
     C                   when      *inkc = *on
     C                             or *inkl = *on
     C                   eval      cancel = *on
     C                   leave
     *
     *   F5 Refresh selected by user.
     C                   when      *inke = *on
     C                   eval      wwidte = *zeros
     *
     C**                 eval      wwidte  = svidte
     *
     *   Enter key pressed. Validate entries.
     C                   Other
     *
     C                   exsr      zzwdwck1
     *
     *   If no errors, proceed with report generation.
     C                   If        Error1 = *off
     C                   leave
     C                   Endif
     *
     C                   Endsl
     C                   Enddo
     *
     C                   eval      wdwinuse = '*NO '
     *
     C     endwdwpmt     endsr
     *
     *----------------------------------------------------------------
500d *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

500d C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416cAC                   eval      $dridata2 = $item2
     C                   endsl

416cAC                   select

416cAC                   when      $dricommand = '*ITEM'
416cAC                   call(e)   'DRICOP'
416cAC                   parm                    $dricommand
416cAC                   parm                    $drisubcmd
416cAC                   parm                    $drisys2upd
416cAC                   parm      #prog         $driprogram
416cAC                   parm      ' '           $drireturn
416cAC                   parm      ' '           $drimessage
416cAC                   parm                    $dridata
416cAC                   parm                    $dridata2
416cA
416cAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416cA
416cAC                   endsl

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
500d C*                  if        zmsflag
500d C*                  exsr      zm0105s
500d C*                  else
     C                   exsr      zm0105
500d C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C                   exsr      zm0001
     C                   exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416cAC                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

500d *----------------------------------------------------------------
500d *  fill$adj   Fill $slot data structure fields for adjustment.
500d *----------------------------------------------------------------
500d
500d C     fill$adj      begsr
500d
500d *  Initialize data structure
500d
500d C                   eval      savever# = $slver#
500d C                   clear                   $slot
500d C                   eval      $slver# = savever#
500d
500d *  Move fields from record to data structure.
500d
500d C                   eval      $slwhseu = *on
500d C                   eval      $slwhse  = w1whse
500d
500d C                   eval      $slwhdpu = *on
500dAC     itkey         chain     piritem                            79
500dAC                   if        not *in79
500dAC                   eval      $slwhdp = itwhdp
500dAC                   else
500dAC                   eval      $slwhdp = *blanks
500dAC                   endif
500d C**                 eval      $slwhdp  = $pwhdp
500d
500d C                   eval      $sldispu = *on
500bAC                   if        ajcode = 'MO'
500d C                   eval      $sldisp  = oslot
500bAC                   else
500b C                   eval      $sldisp  = pslot
500bAC                   endif
500d
500d C                   eval      $saitemu = *on
500eAC                   if        ajcode = 'MO'
500eDC*                  eval      $saitem  = kyitem
500eMC**                 eval      $saitem  = exitem
500eMC                   eval      $saitem  = w2item
500eAC                   else
500eAC**                 eval      $saitem  = excitm
500eAC                   eval      $saitem  = w4citm
500eAC                   endif
500d
500d C                   eval      $saqtyu  = *on
500bAC                   if        ajcode = 'MO'
500d C                   eval      $saqty1  = w2qt01
500d C****               eval      $saqty2  = w1qt02
500d C*                  eval      $saqty3  = w1qt03
500bAC                   else
500bDC                   eval      $saqty1  = w2qt01 * -1
500bDC****               eval      $saqty2  = w1qt02 * -1
500bDC****               eval      $saqty3  = w1qt03 * -1
500bAC                   endif
500d
500d C                   eval      $sacwtau = *on
500d C                   eval      $sacwta  = 0
500d
500d C                   eval      $sacodeu = *on
500d C                   eval      $sacode  = ajcode
500d
500d C                   eval      $samemou = *on
500d C                   eval      $samemo  = ' '
500d
500d C                   eval      $sabyu   = *on
500d C                   eval      $saby    = 'RTN'
500d
500d C                   endsr
500d
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Order Number
Quantity Returned
License #
Delivery #
Catch weight
Label #
Stock code
Unit of measure
UCI #
Return whole order
Coresponding item
Customer #
Date
Item - Already rtn'd
Only numbers allowed
Invoice #
65 not allow w/CWgt
**
Order Number
Quantity Returned
License #
Delivery #
Catch weight
Label #
Stock code
Unit of measure
UCI #
Return whole order
Coresponding item
Customer #
Fecha
Item - Already rtn'd
Only numbers allowed
Invoice #
65 not allow w/CWgt
**  HED
Customer Returns
Transfer Returns
POS Returns
Quick Returns Putaway
