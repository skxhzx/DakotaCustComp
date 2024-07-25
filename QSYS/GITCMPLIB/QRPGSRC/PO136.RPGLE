500dA /copy *libl/qcopysrc,hspecs
500dA *----------------------------------------------------------------
500dA *  Multilingual Verision
500dA *  Every screen and message has a corresponding Spanish version.
500dA *  Any changes must be made to both languages.
500dA *  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PO136      License entry P.O. receiving
     *  10 June, 1997
     *  Roxanne Harrison
     *
     *  SK112 - 1.02
     *
     *  Revisions
     *
222 A*    06/27/97  DAS
     *      - Set on indicator 85 to force SFLNXTCHG read for all records.
     *
405 A*    09/17/97  DAS  4.05
     *      - Revised license plate entry screen to identify cross docks
     *        and protect the license plate field.
     *      - Revised to not check/add license plate for cross dock.
     *
415 A*    11/30/00  DAS  4.15
    A*      - Add code to write a record to PORCV as manual receiving
     *        is completed.  This marks detail sequence as touched.
     *
415aA*    03/10/01  DAS  4.15a
     *      - Revised to work with PO200 RF small screen receiving.
     *      - Created separate message subfile in order to put
     *        message on line 8 of small display screen. New records
     *        are MSGREC2, MSGCTL2 and MSGCLR2.
     *
415bA*    03/19/01  DAS  4.15b
     *      - Revised to use FRMTIT2 for small screen.
     *
415cA*    05/03/01  DAS  4.15c
     *      - Revised program to make sure duplicate license numbers
     *        have not been assigned.
     *
416 A*    03/01/02  DAS  4.16a
     *      - Revised to also check LBASL2 for 'XDK'.
     *
416aA*    05/23/02  RRH  4.16
     *      - Change W1LCNS, W2LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
     *      - PORCV file changed, initialize POREDT and PORETI.
     *
417 A*    04/28/03  MLB  4.17
     *      - Revised ZZCHK1,ZZCHK1 to use *LEFTNOZ for call to ADJUST.
417bA*    06/25/03  HNK  4.17b
     *      - Fix: Do not allow entry of special characters in license
     *             entry field.
417cA*    07/02/03  MLB  4.17c
     *      - Enh: Added support for lot/license plate tracking.
417dA*    07/02/03  MLB  4.17d
     *      - Enh: Revised program to receive lot code from PO132.
417eA*    11/13/03  MLB  4.17e
     *      - Enh: Revised $RPARM DS to add two new fields,
     *        $RFSLP and $RTSLP.
     *
500 A*    04/01/05  DAS  5.00
     *      - Replaced PIRITEM file with DRIITEM *GET.
     *      - Revised to call zzllp unconditionally.
     *      - Added new command *LICONLY. This command will only update
     *        the license files and return. It is used when license plates
     *        are not attached to pallets.
     *
500aA*    03/31/05  DAS  5.00a
     *      - Added command *STUFFIT. Similar to *LICONLY but also closes
     *        the label(s) and transaction(s).
     *      - Added logic for non-live departments. User will not be
     *        asked for license and label/transaction will be closed.
     *
500cA*    11/21/05  JCJ  5.00c
     *      - Revised to collect clam information.
     *
500dA*    06/07/06  JCJ  5.00
     *      - Added Multilingual logic.
     *
510bA*    10/12/06  RH   5.10b
     *      - Added by DAS on 9/1/09.
     *      - Enh: Capture date entered,type and date settings
     *        Replace MFDT with INDT for keyed in date.
     *
520aA*    04/17/09  RBD  5.20a
     *      - Added by DAS on 9/1/09.
     *      - Revised to collect 'SHUCKED' information.
     *
610aA*    09/01/09  DAS  6.10a
     *      - Revised for license tracking.
     *
640aA*    04/05/12  LMC  6.40a
     *      - Enh: Added New HACCP processing. - in process
640bA*    07/13/12  LMC  6.40b
     *      - Enh: Added Decipher code to incoming parms and write
     *        to Licinfo file.
640cA*    10/08/12  LMC  6.40c
     *      - Enh: Added UCI processing.
     *      - Enh: Write New LICINFO record.
     *      - Enh: Added LPN in order to update POASN file.
650aA*    03/22/13  LMC  6.50a
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file. Load HACCPXRF file data.
650bA*    05/17/13  LMC  6.50b
     *      - Enh: Added RCVPO transaction.
650cA*    06/19/13  LMC  6.50c
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
650dA*    07/15/13  LMC  6.50d
     *      - Enh: Added additional checks for unique license.
     *      LICINFO and LICLOG records stay longer with new cleanup.
     *      We need to check LICLOG before we allow the user to
     *      reuse a license number.
650eA*    10/28/13  LMC  6.50e
     *      - Fix: 650d code should only execute if there are no
     *        current errors. This code sets the error field off
     *        and was causing the potential for a blank license to
     *        be written to liclog and licinfo.
650fA*    09/06/13  LMC  6.50f
     *      - Enh: Pass License to clam print programs.
700aA*    11/23/15  LMC  7.00a
     *      - Enh: Pick slot receiving with uci receiving.
     *      - handled similar to cross dock.
700bA*    12/23/15  LMC  7.00b
     *      - Enh: Added the ability to load a special license for
     *        clients who want to print receiving labels, when
     *        Receiving option "Use Generic License" = 'N'
700dA*    04/07/16  LMC  7.00d
     *      - Fix: Mod 700a caused non pick slot receivine/uci to
     *        loose licinfo/ucinfo records
710aA*    05/02/17  LMC  7.10a
     *      - Fix - Need to check to make sure old LICINFO record
     *        doesn't exist.
710aA*    02/03/17  GJA  7.10b
     *      - Enh: Add Client support for client id
720aA*    05/15/18  LMC  7.20a
     *      - Enh: Only write PTI records to the uciinfo file if the
     *        item is setup for pti selection
     *
720bA*    10/12/18  LMC  7.20b
     *      - Enh: Additional receiving methods have been created.
     *        4,5 & 6. They all are standard receiving with an addon
     *        for printing labels (aka Box labeler).
     *
720cA*    08/08/16  LMC 7.20c
     *      - Enh: UCI Tracking.
720dA*    11/28/18  LMC  7.20d
     *      - Fix - Only check to make sure old LICINFO record
     *        doesn't exist if $pgslcns = ' '
740aA*    02/18/20  LMC  7.40a
     *      - Enh: Added logic to accomodate RF uci Receiving.
     *      - Anywhere PO200 was referenced also reference PO201.
740bA*    02/26/20  LMC  7.40b
     *      - Enh: Added logic to do additional license checks
     *        to ensure license is unique in zzchk2.
     *----------------------------------------------------------------
     *    Client Custom Revisions: Westside
     *
WSFa *    02/03/17  GJA  WSFa
     *      - Add check in ZZCHK1 to only allow 7 digit license
WSFbA*    09/27/20  MLB  WSFb
     *      - Add check in ZZCHK1 to only allow 8 digit license.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
700bDF*po136fm   cf   e             workstn
700bMFpo13601   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec2:msgk)
500dAF                                     sfile(detl1sp:recno)
500aDF**bel2    if   e           k disk
500aMFLabel2    uf   e           k disk
     F                                     rename(lbrec:record)
610aDF*icense   uf a e           k disk
610aMFlicense   if   e           k disk
     F                                     rename(lirec:record2)
610aAFLicense1  uf a e           k disk
     F                                     rename(lirec:lirec1)
     Fwarehs    if   e           k disk
500 DF**ritem   if   e           k disk
     Fitemdsc   if   e           k disk
     Foptions   if   e           k disk
415 AFporcv     o  a e           k disk
650aAfhaccpxrf  o  a e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416aMD lcns            s             15    dim(500)
416aD**                  LCNS      500  7 0
415cD**                  DESC    1   8 50
417bD*                   DESC    1   9 50
417bMD desc            s             50    dim(10) ctdata perrcd(1)
500dAD descsp          s             50    dim(10) ctdata perrcd(1)

650aAd $lparm1         s             48    dim(20)
650aAD $parms1         s             48    dim(20)
500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A /COPY *libl/qcopysrc,C#DRIPARMS

500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A /COPY *libl/qcopysrc,C#SLOT
500 A /COPY *libl/qcopysrc,C#XDOCK
500 A /COPY *libl/qcopysrc,C#LICINFO
610aD**COPY *libl/qcopysrc,C#LICHIST
610aA /COPY *libl/qcopysrc,C#LICENSE
500 A /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
500 AD savever#        s                   like($lnver#)

710bA*----------------------------------------------------------------
710bA*  Customer id
710bA*----------------------------------------------------------------
WSFaA /copy qcopysrc,Id#westsid
     *----------------------------------------------------------------
     *  Program parameters
     *
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
     D  $pitem                22     36
     D  $ppo                  37     45
     D  $prq1                 46     50  0
     D  $prq2                 51     55  0
     D  $prq3                 56     60  0
     D  $prpal                61     63  0
417cAD  $plott                64     64
417cAD  $plict                65     65

500 A*  Extra parameters not part of data structure.
500 A
510bDD*$pmfdt          s              8  0
510bMD $pindt          s              8  0
500 AD $pfifo          s              8  0

650aAD $p1parms1       ds
650aAD  $p1whse                1      3
650aAD  $p1po                  4     12
650aAD  $p1poseq              13     17
650aAD  $p1qstseq             18     22
650aAD  $p1uctime                      Z
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
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
     D  $lbld                 19     20
640aA*   for Haccp
640aAD  $llevel               22     25
640aAD  $llicense             26     40
640aAD  $lhpo                 41     49
640aAD  $lhseq                50     54  0
640aAD  $ltype                55     57
640aA*
417cA*
500 D **---------------------------------------------------------------
500 D ** LICHIST - License history (Input Data)
500 D **
500 DD**rparm          ds
500 DD**$rwhse                 1      3  0
500 DD**$rltrn                 4      7p 0
500 DD**$racfl                 8      9
500 DD**$rtrn#                10     13p 0
500 DD**$rlbl#                14     17p 0
500 DD**$rlcns                18     32
500 DD**$rfmlc                33     47
500 DD**$rorlc                48     62
500 DD**$rlqy1                63     66p 0
500 DD**$rlqy2                67     70p 0
500 DD**$rlqy3                71     74p 0
500 DD**$raqy1                75     78p 0
500 DD**$raqy2                79     82p 0
500 DD**$raqy3                83     86p 0
500 DD**$rfmcd                87     87
500 DD**$rfara                88    102
500 DD**$rfwhd               103    107
500 DD**$rfasl               108    110
500 DD**$rfloc               111    113  0
500 DD**$rflvl               114    115  0
500 DD**$rfhnd               116    117
500 DD**$rfslp               118    119p 0
500 DD**$rtocd               120    120
500 DD**$rtara               121    135
500 DD**$rtwhd               136    140
500 DD**$rtasl               141    143
500 DD**$rtloc               144    146  0
500 DD**$rtlvl               147    148  0
500 DD**$rthnd               149    150
500 DD**$rtslp               151    152p 0
500 DD**$rtord               153    156p 0
500 DD**$rtseq               157    159p 0
500 DD**$rexcd               160    167
500 DD**$radts               168    193
500 DD**$raemp               194    196p 0
500 DD**$rausr               197    206
500 DD**$rajob               207    216
500 DD**$rajbn               217    222
500 DD**$rcdts               223    248
500 DD**$rcemp               249    251p 0
500 DD**$rcusr               252    261
500 DD**$rcjob               262    271
500 DD**$rcjbn               272    277
500 D **Misc. work fields
500 DD**rdata          ds
500 DD**$rpo                   1      9
500 DD**$rseq                 10     12p 0
500 DD**$ritem                13     27
500 DD**$rlotc                28     57
500 DD**$rcwgt                58     62p 2
417dA*
     D rcv01           c                   const('Receiving')
     D rcv02           c                   const('Dock')
500cAD Clams           c                   const('CLAMS     ')
520aAD Shucked         c                   const('SHUCKED   ')
417bA*----------------------------------------------------------------
417bA*  Name constants
417bA*
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @fmti2          c                   const('FRMTIT2')
500 DD**llptr          c                   const('UPDLLPTRK')
650bAD @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
415 D*                                       1   8 $CVDOP
415 D*                                       9  140$CVDD6
415 D*                                      15  220$CVDD8
415 AD  $cvcmd                 1      8
415 AD  $cvprg                 9     18
415 AD  $cvd6i                19     24
415 AD  $cvd8i                25     32
415 AD  $cvd6o                33     38  0
415 AD  $cvd8o                39     46  0
415 AD  $cvsto                47     64
415 AD  $cvrtn                65     72
415 AD  $cverm                73    132
415 AD  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500dAD #msgfsp         c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
500 A /COPY *libl/qcopysrc,C#PGMINFDS
500 DD**              sds
500 DD**#prog            *proc
500 DD**#job                 244    253
500 DD**#user                254    263
500 DD**#jobn                264    269
500 DD**#jobdt               276    281  0
500 DD**#jobtm               282    287  0
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aAD ha410           pr                  extpgm('HA410')
640aA * Input
640aAD   pparm                       80
650aAD   pparm1                      48    dim(20)
650cAD calcpti         pr                  extpgm('CALCPTI')
650cA * Input
650cAD   pGTIN                             like($lgtin)
650cAD   pLOT                              like(pplot)
650cAD   pPackDate                         like($pbcProdD)
650cAD   pPTI                              like(pppti)
650cAD ucilic#         pr                  extpgm('UCILIC#')
650cA * Input
650cAD   unext                       13  0 const
650cAD   uwhse                        3  0 const
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
WSFaA*  License variables
WSFaAD WSFlcns         ds
WSFaAD  WSF99I                 1      3
WSFbDD* WSF7lcns               1      7
WSFbMD  WSF8lcns               1      8
WSFbDD* WSF8lcns               8     15
WSFbMD  WSF9lcns               9     15
WSFaA*----------------------------------------------------------------
WSFaA*  Name constants
WSFaA*
WSFaAD WSFvalid        c                   const('0123456789')
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
650cAD $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
500 AD ck4err          s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
500 MD error           s               n
500 AD forever         s               n
     D gs1seqqty       s              5  0
     D help            s              5  0
650aAD hxwhse          s              3  0
650aAD hxpo            s              9
650aAD hxposeq         s              5  0
650aAD hxseq#          s              5  0
650aAD hxadduc         s               z
650aAD hxlcns          s             15
600dAD j               s              2  0
650cAD k               s                   like($lnrcvqty)
610aAD kytrn#          s                   like(lbtrn#)
     D l               s              3  0
500 AD licenseonly     s               n
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D posrec          s              4  0
650bAD poppcs          s                   like(@ppcs)
650cAd pplot           s             20
650cAd pppti           s              4  0
510b D rcvdday         s              3
510b D rcvmday         s              3
510b D rcvuday         s              3
650bAD rcvpocomplete   s               n
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sflrec          s              5  0
     D stop            s              1
500aAD stuffit         s               n
     D today           s              8  0
650cAD unexta          s             13
     D uxflag          s              1
     D warn            s              1
     D woblcn          s             15
     D x               s              5  0
650aAD xx              s              5  0
600aAD zmflag          s               n
500cAD $phdte          s              8  0
500cAD $phloc          s             20
500cAD $pcert          s             20
500cAD $pcode          s             10
500cAD $phhdr          s              1
500cAD $phdtl          s              1
500cAD $phcat          s              1
500cAD sav$pcmd        s              8
500cAD $plbl#          s              7  0
500cAD $plic#          s             15
500cAD $pqty           s              5  0
500cAD $pprt           s             10
500cAD $pform          s             10

500 AD currtimestamp   s               z

500 AD #rcvitem        s                   like($ititem)
500 AD #rcvtype        s                   like($ittype)
500 AD #rcvdesc        s                   like($itdesc)
500 AD #rcvpdsc        s                   like($itpdsc)
500 AD #rcvwhdp        s                   like($itwhdp)
500 AD #rcvstyp        s                   like($itstyp)
500 AD #rcvdesg        s                   like($itdesg)
500 AD #rcvum1         s                   like($itum1)
500 AD #rcvflg1        s                   like($itflg1)
500 AD #rcvum2         s                   like($itum2)
500 AD #rcvumq2        s                   like($itumq2)
500 AD #rcvflg2        s                   like($itflg2)
500 AD #rcvum3         s                   like($itum3)
500 AD #rcvumq3        s                   like($itumq3)
510bAD #rcvdday        s                   like($imdday)
510bAD #rcvmday        s                   like($immday)
510bAD #rcvmflg        s                   like($immflg)
510bAD #rcvuday        s                   like($imuday)
500 AD #rcvnrpk        s                   like($imnrpk)
500 AD #rcvflgd        s                   like($itflgd)
500 AD #rcvcube        s                   like($itcube)
500 AD #rcvswgt        s                   like($itswgt)
500 AD #rcvupc         s                   like($itupc)

500 AD #slotitem       s                   like($ititem)
500 AD #slottype       s                   like($ittype)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Update licnese #.
     *              *VIEW    - View only
500 A*              *LICONLY - Only update license files.
500aA*              *STUFFIT - Update license files, close lbls and trans
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
500 A*      $PUM1-3 Units of measure 1, 2, 3.
500 A*      $PORD   Order number for *RETURN.
500 A*      $PFLAG  License option flag.
500 A*      $PVEN   Vendor number for *RECEIVE.
500 A*      $PVNAM  Vendor name for *RECEIVE.
500 A*      $PEXPD  Expiration date.
500 A*      $PDEV   Printer device to use or *DEFAULT.
500 A*      $PFORM  Printer form to use or *DEFAULT.
417dA*      $PSEQ   P.O. Sequence number
417dA*      $PDWGT  Item catchweight
500 A*      $PAWT1  Average Item catchweight 1
500 A*      $PAWT2  Average Item catchweight 2
500 A*      $PAWT3  Average Item catchweight 3
417dA*      $PLOTC  Lot code
500 A*      $PMFDT  Mrg date
500 A*      $PFIFO  Fifo date
500 A*      $PUPC   UPC code
     *
     *    Returned Parameters
     *      $PUKY   Unchanged.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $pum1             5
     C                   parm                    $pum2             5
     C                   parm                    $pum3             5
     C                   parm                    $pord             7 0
500 AC                   parm                    $pflag            1
417dAC                   parm                    $pseq             5 0
500 AC                   parm                    $pven            11 0
500 AC                   parm                    $pvnam           40
500 AC                   parm                    $pvitm           15
500 AC                   parm                    $pexpd            8 0
500 AC                   parm                    $pdev            10
500 AC                   parm                    $pform           10
417dAC                   parm                    $pdwgt            9 2
500 AC                   parm                    $pawt1            7 2
500 AC                   parm                    $pawt2            7 2
500 AC                   parm                    $pawt3            7 2
417dAC                   parm                    $plotc           30
510bDC*                  parm                    $pmfdt
510bMC                   parm                    $pindt
500 AC                   parm                    $pfifo
500 AC                   parm                    $pupc            20
640bAC                   parm                    $pdecvalue       15
640bAC                   parm                    $pmfexpd          8 0
640bAC                   parm                    $pmfgdt           8 0
640fAC                   parm                    $plpn            50
640gAC                   parm                    $pgslcns         15
640gAC                   parm                    $pbrand          10
650aAC                   parm                    $parms1
650bAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $lgtin           14
650cAC                   parm                    $pbcProdD         6 0
650cAC                   parm                    $pbclot          20
650cAC                   parm                    $pw1pti           4 0
     *
500cAC     po172p        plist
500cAC                   parm                    $parms
500cAC                   parm                    $pseq
500cAC                   parm                    $phdte
500cAC                   parm                    $phloc
500cAC                   parm                    $pcert
500cAC                   parm                    $pprt
500cAC                   parm                    $pform
650fAC                   parm                    $saToLcns
     *
500cAC     tagfmtP       plist
500cAC                   parm                    $pcmd
500cAC                   parm                    $pwhse
500cAC                   parm                    $ppo
500cAC                   parm                    $pseq
500cAC                   parm                    $pitem
650fDC*                  parm                    $plic#
650fMC                   parm      $LNLCNS       $plic#
500cAC                   parm                    $pqty
500cAC                   parm                    $phdte
500cAC                   parm                    $phloc
500cAC                   parm                    $pcert
500cAC                   parm                    $plbl#
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
415aAC     nxtscr        caseq     '02 '         sc2
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
     C                   select
     *
     *R         NXTSCR    WHEQ '01 '
     *R                   EXFMTSCREEN1
     *
415aMC                   when      nxtscr = '02 '
500dAC                   select
500dAC                   when      e$lng = 'SP'
740bAc                   if        $pgslcns = ' '  and $pflag = *on or
740bAc                             error = *on
500dAC                   exfmt     scrn2sp
740bAc                   endif
500dAC                   other
740bAc                   if        $pgslcns = ' '  and $pflag = *on or
740bAc                             error = *on
415aMC                   exfmt     screen2
740bAc                   endif
500dAC                   endsl
     *
     *R         NXTSCR    WHEQ '03 '
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   read      head1sp                                50
500dAC                   other
640gAc                   if        $pgslcns = ' ' or
640gAc                             error = *on
     C                   read      head1                                  50
640gAc                   endif
500dAC                   endsl
     *
     C                   endsl
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
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     C     end03i        endsr
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     redspl        cabeq     *on           endsc2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
415aD**                   MOVE 'EOJ'     NXTSCR
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     redspl        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc3        endsr
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
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *  Initialize subfile values
     *
     *                    Z-ADD1         RECNO
     *                    WRITEDETAIL1                79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   write     detl1sp
500dAC                   other
     C                   write     detail1
500dAC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   write     head1sp                                50
500dAC                   other
     C                   write     head1
500dAC                   endsl
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     **                   WRITEOPTREC
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   write     cmdrecsp
500dAC                   other
     C                   write     cmdrec
500dAC                   endsl
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     **                   WRITEPOSTNREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = posrec
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   write     head1sp                                50
500dAC                   other
     C                   write     head1
500dAC                   endsl
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415aAC                   write     msgctl2
415aAC                   else
     C                   write     msgctl
415aAC                   endif
     C                   eval      msgk = *zeros
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415aAC                   write     msgctl2
415aAC                   else
     C                   write     msgclr
415aAC                   endif
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415aAC                   write     msgctl2
415aAC                   else
     C                   write     msgctl
415aAC                   endif
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
500 MC                   eval      #pgmq = #pgm
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      $msgf = #msgfsp
500dAC                   other
     C                   eval      $msgf = #msgf
500dAC                   endsl
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
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415aAC                   write     msgrec2
415aAC                   else
     C                   write     msgrec
415aAC                   endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415aAC                   write     msgrec2
415aAC                   else
     C                   write     msgrec
415aAC                   endif
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      $msgf = #msgfsp
500dAC                   other
     C                   eval      $msgf = #msgf
500dAC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*      0105s
500 A*
500 AC     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0113  Field 1 must be greater than or equal to field 2.
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
416aMC                   eval      lcns = *blanks
416aD**                   MOVE *ZEROS    LCNS
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   eval      error = *off
     *
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   readc     detl1sp                                79
500dAC                   other
     C                   readc     detail1                                79
500dAC                   endsl
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in13 = *off
     C                   eval      *in33 = *off
405 A*
405 A*  Only do checks for non-cross dock records.
405 A*
405 AC                   if        w1xdk <> 'Y'
     *
     *  License # must be entered.
     *
416aD**         W1LCNS    IFEQ 0
416a C                   if        w1lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   endif
     *
416aA*  Left justify license.
416aAC                   eval      $cstr = *blanks
416aAC                   move      w1lcns        $cstr
416aAC                   call      'ADJUST'
417 D*R                   PARM '*LEFT   '$CCMD   8
417 MC                   parm      '*LEFTNOZ'    $ccmd             8
416aAC                   parm                    $cstr            30
416aAC                   movel     $cstr         w1lcns
     *
417bAC                   eval      *in81 = *off
417bAC     valid         check     w1lcns                                 81
417bA*
417bA*  *IN81 = *ON - One of the positions did not have valid value
417bA*
417bAC                   if        *in81
417bAC                   eval      error = *on
417bAC                   eval      *in33 = *on
417bAC                   eval      *in13 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      errmsg = descsp(10)
500dAC                   other
417bAC                   eval      errmsg = desc(10)
500dAC                   endsl
417bAC                   exsr      zm1001
417bAC                   endif
WSFaA *
WSFaAC                   if        client = WestSide
WSFaAC                   eval      WSFlcns = w1lcns
WSFaAC                   if        WSF99I  <> '99I'
WSFbDC*    WSFvalid      check     WSF7lcns
WSFbMC     WSFvalid      check     WSF8lcns                               81
WSFbDC*                  if        *in81 or WSF8lcns<>*blanks
WSFbMC                   if        *in81 or WSF9lcns<>*blanks
WSFaAC                   eval      error = *on
WSFaAC                   eval      *in33 = *on
WSFaAC                   eval      *in13 = *on
WSFaAC                   eval      errmsg = desc(10)
WSFaAC                   exsr      zm1001
WSFaAC                   endif
WSFaAC                   endif
WSFaAC                   endif
     *
     *  License # must be unique.
     *
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   endif
650dA*
650dA*  Check LICLOG before accepting this license
650dA*
650eAc                   if        error = *off
650dAC                   exsr      clr$license
650dAC                   eval      $liToLcnsU = *on
650dAC                   eval      $liToLcns = w1lcns
650dAC                   eval      $liOLcnsU = *on
650dAC                   eval      $liOLcns = w1lcns
650dAC                   eval      $dricommand = '*LICENSE'
650dAC                   eval      $drisubcmd  = '%GETINFO'
650dAC                   eval      $drisys2upd = 'D'
650dAC                   eval      ck4err = *off
650dAC                   exsr      zzzdricop
650dAc* if we get an ok on the return this means it exist - don't use
650dAC                   if        $drireturn = '*OK'
650dAC                   eval      error = *on
650dAC                   eval      *in33 = *on
650dAC                   eval      *in13 = *on
650dAC                   exsr      zm034
650dAC                   endif
650dA
650eAC                   endif
720dAc                   if        $pgslcns = ' '
710aA*
710aA*  Check LICINFO before accepting this license
710aA*
710aAc                   if        error = *off
710aAC                   exsr      clr$licinfo
710aAC                   eval      $lnwhse  = $pwhse
710aAC                   eval      $lnlcns = w1lcns
710aAC                   eval      $dricommand = '*LICINFO'
710aAC                   eval      $drisubcmd  = '%GET'
710aAC                   eval      $drisys2upd = 'D'
710aAC                   eval      ck4err = *off
710aAC                   exsr      zzzdricop
710aAc* if it exist don't allow to use.
710aAC                   if        $drireturn = '*OK'
710aAC                   eval      error = *on
710aAC                   eval      *in33 = *on
710aAC                   eval      *in13 = *on
710aAC                   exsr      zm034
710aAC                   endif
710aA
710aAC                   endif
720dAc                   endif
415cA*
415cA*     Verify user hasn't scanned same license# multiple times.
415cA*
415cAC                   eval      l = 1
415cAC     w1lcns        lookup    lcns(1)                                80
415cAC                   select
415cAC                   when      *in80
415cA*
415cAC                   eval      error = *on
415cAC                   eval      *in33 = *on
415cAC                   eval      *in13 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      errmsg = descsp(9)
500dAC                   other
415cAC                   eval      errmsg = desc(9)
500dAC                   endsl
415cAC                   exsr      zm0105
415cA*
415cAC                   when      not *in80
415cA*
415cA*    License# not found.  Find next empty element.
415cAC                   eval      l = 1
416aD**         0000000   LOKUPLCNS,L                   80
416aAC                   eval      woblcn = *blanks
416aMC     woblcn        lookup    lcns(l)                                80
415cAC                   if        *in80
416aAC                   eval      lcns(l) = w1lcns
416aD**                   Z-ADDW1LCNS    LCNS,L
415cAC                   endif
415cA*
415cAC                   endsl
     *
405 AC                   endif
     *
222 AC                   eval      *in85 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   update    detl1sp
500dAC                   other
     C                   update    detail1
500dAC                   endsl
     C                   if        posrec = 0
     C                   if        *in33
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
415aA*    Started using this routine in 4.15a
     *
     C     zzchk2        begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
     *
     *   Update subfile record.
     *
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC     w2pctr        chain     detl1sp                            79
500dAC                   other
     C     w2pctr        chain     detail1                            79
500dAC                   endsl
416aD**                   Z-ADDW2LCNS    W1LCNS
416a C                   eval      w1lcns = w2lcns
     C                   eval      *in85 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   update    detl1sp
500dAC                   other
     C                   update    detail1
500dAC                   endsl
     *
     *  License # must be entered.
     *
416aD**         W2LCNS    IFEQ 0
416a C                   if        w2lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   goto      endck2
     C                   endif
     *
416aA*  Left justify license.
416aAC                   eval      $cstr = *blanks
416aAC                   move      w2lcns        $cstr
416aAC                   call      'ADJUST'
417 D*R                   PARM '*LEFT   '$CCMD   8
417 MC                   parm      '*LEFTNOZ'    $ccmd
416aAC                   parm                    $cstr
416aAC                   movel     $cstr         w2lcns
     *
417bAC                   eval      *in81 = *off
417bAC     valid         check     w2lcns                                 81
417bA*
417bA*  *IN81 = *ON - One of the positions did not have valid value
417bA*
417bAC                   if        *in81
417bAC                   eval      error = *on
417bAC                   eval      *in33 = *on
417bAC                   eval      *in13 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      errmsg = descsp(10)
500dAC                   other
417bAC                   eval      errmsg = desc(10)
500dAC                   endsl
417bAC                   exsr      zm1001
417bAC                   endif
     *
     *  License # must be unique.
     *
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   goto      endck2
     C                   endif
740bA*
740bA*  Check LICLOG before accepting this license
740bA*
740bAc                   if        error = *off
740bAC                   exsr      clr$license
740bAC                   eval      $liToLcnsU = *on
740bAC                   eval      $liToLcns = w1lcns
740bAC                   eval      $liOLcnsU = *on
740bAC                   eval      $liOLcns = w1lcns
740bAC                   eval      $dricommand = '*LICENSE'
740bAC                   eval      $drisubcmd  = '%GETINFO'
740bAC                   eval      $drisys2upd = 'D'
740bAC                   eval      ck4err = *off
740bAC                   exsr      zzzdricop
740bAc* if we get an ok on the return this means it exist - don't use
740bAC                   if        $drireturn = '*OK'
740bAC                   eval      error = *on
740bAC                   eval      *in33 = *on
740bAC                   eval      *in13 = *on
740bAC                   exsr      zm034
740bAC                   endif
740bA
740bAC                   endif
740bAc                   if        $pgslcns = ' '
740bA*
740bA*  Check LICINFO before accepting this license
740bA*
740bAc                   if        error = *off
740bAC                   exsr      clr$licinfo
740bAC                   eval      $lnwhse  = $pwhse
740bAC                   eval      $lnlcns = w1lcns
740bAC                   eval      $dricommand = '*LICINFO'
740bAC                   eval      $drisubcmd  = '%GET'
740bAC                   eval      $drisys2upd = 'D'
740bAC                   eval      ck4err = *off
740bAC                   exsr      zzzdricop
740bAc* if it exist don't allow to use.
740bAC                   if        $drireturn = '*OK'
740bAC                   eval      error = *on
740bAC                   eval      *in33 = *on
740bAC                   eval      *in13 = *on
740bAC                   exsr      zm034
740bAC                   endif
740bA
740bAC                   endif
740bAc                   endif
     *
     C     1             do        w2pal         x
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC     x             chain     detl1sp                            77
500dAC                   other
     C     x             chain     detail1                            77
500dAC                   endsl
     C                   if        *in77  or
     C                             x = w2pctr  or
     C                             w1xdk = 'Y'
     C                   iter
     C                   endif
     C                   if        w2lcns = w1lcns
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   goto      endck2
     C                   endif
     C                   enddo
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvpocheck
     *
     C     endck3        endsr
500aA
500aA*----------------------------------------------------------------
500aA*  ZZCLOSETRN   Close transaction
500aA*----------------------------------------------------------------
500aA
500aAC     zzclosetrn    begsr
610aDC**
610aDC** Updated slot.
610aDC**
610aDC**
610aDC**                 exsr      clr$slot
610aDC**                 eval      $slwhseu = *on
610aDC**                 eval      $slwhse  = lbwhse
610aDC**                 eval      $slwhdpu = *on
610aDC**                 eval      $slwhdp  = lbwhdp
610aDC**                 eval      $sldispu = *on
610aDC**                 eval      $sldisp  = lbdisp
610aDC**                 eval      $saitemu = *on
610aDC**                 eval      $saitem  = lbitem
610aDC**                 eval      $saqtyu = *on
610aDC**                 select
610aDC**                 when      lbutyp = 'N'
610aDC**                 eval      $saqty1 = lbqpck
610aDC**                 when      lbutyp = '1'
610aDC**                 eval      $saqty2 = lbqpck
610aDC**                 when      lbutyp = '2'
610aDC**                 eval      $saqty3 = lbqpck
610aDC**                 endsl
610aDC**                 eval      $saorgu = *on
610aDC**                 eval      $saorg1 = $saqty1
610aDC**                 eval      $saorg2 = $saqty2
610aDC**                 eval      $saorg3 = $saqty3
610aDC**                 eval      $satrn#u = *on
610aDC**                 eval      $satrn#  = lbtrn#
610aDC**
610aDC**                 eval      $dricommand = '*SLOT'
610aDC**                 eval      $drisubcmd  = '%CLSRCV'
610aDC**                 eval      $drisys2upd = 'D'
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzdricop
500aA
500aA*  Close transaction
500aA
500aAC                   call      'ADDSTDTRN'
500aAC                   parm      '*CLOSE  '    @pcmd             8
500aAC                   parm                    #job
500aAC                   parm      lbtrn#        @ptrn#            7 0
500aAC                   parm      'PUTEMP'      @ptask            6
500aAC                   parm      lbwhse        @pwhse            3 0
500aAC                   parm                    @pwhdp            5
500aAC                   parm                    @pstyp            1
500aAC                   parm      lbcube        @pcube            9 3
500aAC                   parm      lbswgt        @pswgt            9 2
500aAC                   parm      lbqpck        @ppcs             5 0
500aAC                   parm      1             @paisl            5 0
500aAC                   parm      1             @pqty1            5 0
500aAC                   parm      0             @pqty2            5 0
500aAC                   parm      0             @pqty3            5 0
500aAC                   parm      ' '           @prte             5
500aAC                   parm      $ppo          @ppo              9
500aAC                   parm      'P'           @pgrp1            1
500aAC                   parm      ' '           @pgrp2            1
500aAC                   parm      ' '           @prtn             8
500aAC                   parm      ' '           @pmsg             4
500aAC                   endsr
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
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
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
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
415aA*
415aA*  Test for F7 - Lookup
415aA*
415aAC                   if        *inkg
415aAC                   eval      cmdtkn = *on
415aAC                   if        w2pctr > 1
415aAC                   eval      w2pctr = w2pctr - 1
415aAC                   exsr      scr02i
415aAC                   endif
415aAC                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 1.
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
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Build code.
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
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
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     *
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Move PO
     *
     C                   eval      w1po = $ppo
     *
     *   Move qtys
     *
     C                   eval      w1qrc1 = $prq1
     C                   eval      w1qrc2 = $prq2
     C                   eval      w1qrc3 = $prq3
     C                   eval      w1um1 = $pum1
     C                   eval      w1um2 = $pum2
     C                   eval      w1um3 = $pum3
     *
     C                   exsr      sflclr
     C     partk2        setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
500aDC**   partk2        reade     label2                                 79
500aMC     partk2        reade(n)  label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   eval      w1qty = lbqalc
     C                   eval      w1tie = lbtie
     C                   eval      w1hi = lbhigh
     C                   eval      w1trn# = lbtrn#
415 AC                   eval      w1lbl# = lblbl#
415 AC                   eval      w1seq = lbseq
415 AC                   eval      w1um = lbucod
417cA*    Load hidden fields.
417cAC                   eval      w1utyp = lbutyp
417cAC                   eval      w1whdp = lbwhdp
417cAC                   eval      w1aisl = lbaisl
417cAC                   eval      w1loc = lbloc
417cAC                   eval      w1rlvl = lbrlvl
417cAC                   eval      w1hand = lbhand
417cA*
416aD**                   Z-ADD0         W1LCNS
416aAC                   eval      w1lcns = *blanks
640gAc                   if        $pgslcns <> ' '
640gAc                   eval      w1lcns = $pgslcns
640gAc                   endif
700bA * load license for clients with Use Generic License = 'N'
700bAc                   eval      *in92 = *off
700bAc                   if        licenseonly and w1lcns = ' '
700bAc                   eval      *in92 = *on
700bAc                   eval      w1lcns = 'R' + %editc(w1trn#:'X')
700bAc                   endif
700bAc
405 AC                   if        lbaisl = 'XDK'  or
416 AC                             lbasl2 = 'XDK'
405 AC                   eval      w1xdk = 'Y'
405 AC                   eval      *in90 = *on
405 AC                   else
405 AC                   eval      w1xdk = ' '
405 AC                   eval      *in90 = *off
405 AC                   endif
     C                   exsr      sfladd
     C                   endif
     C                   enddo
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
415aA*    Started using this routine in 4.15a
     *
     C     zzfil2        begsr
     *
     *   Get subfile record.
     *
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC     w2pctr        chain     detl1sp                            79
500dAC                   other
     C     w2pctr        chain     detail1                            79
500dAC                   endsl
     C                   eval      w2po = w1po
     *******              Z-ADDW1XXXX    W2LINE
     C                   eval      w2item = woitem
     C                   eval      w2qty = w1qty
     C                   eval      w2um = *blanks
     C                   call      'FRMTTIHI'
     C                   parm                    w1tie
     C                   parm                    w1hi
     C                   parm                    w2tihi
416aD**                   Z-ADDW1LCNS    W2LCNS
416a C                   eval      w2lcns = w1lcns
     C                   if        w1xdk = 'Y'
     C                   eval      w2xdk = 'XDK'
     C                   eval      *in90 = *on
     C                   else
     C                   move      '   '         w2xdk
     C                   eval      *in90 = *off
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr

      * get item category

500cAC                   call      'GETICAT'
500cAC                   parm                    $pwhse
500cAC                   parm                    $pitem
500cAC                   parm                    $pcode
500cAC                   parm                    $phhdr
500cAC                   parm                    $phdtl
500cAC                   parm                    $phcat

     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
500aA
500aA*----------------------------------------------------------------
500aA*  ZZGETSLOT  Get slot information
500aA*----------------------------------------------------------------
500aA
500aAC     zzgetslot     begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = lbwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = lbdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
710bA
     *  Get client id.
710bA
710bAC                   call      'GETCLIENT'
710bAC                   parm                    client           10
     *
     *  Define key for LICENSE file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
     *
     *  Define partial key for item LABEL file.
     *
     C     partk2        klist
     C                   kfld                    $pord
     C                   kfld                    $pwhse
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
610aA*
610aA*  Define key for LICENSE1 file.
610aA*
610aAC     lcnsky1       klist
610aAC                   kfld                    $pwhse
610aAC                   kfld                    kytrn#
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
415 A*
415 A*  Convert today's date into century format.
415 A*
415 AC                   eval      $cvcmd = '*CURCMD '
415 AC                   call      @cvtdt
415 AC                   parm                    $cvtdt
415 AC                   eval      today = $cvd8o
     *
500 MC                   eval      $lprg = #pgm
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
415cAC                   eval      l = *zeros
416aMC                   eval      lcns = *blanks
416aD**                   MOVE *ZEROS    LCNS
     *
     *   Set indicator for subfile change(SFLNXTCHG)
     C                   eval      *in85 = *on
500 A
500 A*   See if we only want to update License files.
500 A
500 AC                   eval      licenseonly = *off
500 AC                   if        $pcmd = '*LICONLY'
500 AC                   eval      $pcmd = '*CHANGE'
500 AC                   eval      licenseonly = *on
500 AC                   endif
500aA
500aA*   See if have stuffed the item into the pick slot.
500aA
500aAC                   eval      stuffit = *off
500aAC                   if        $pcmd = '*STUFFIT'
500aAC                   eval      $pcmd = '*CHANGE'
500aAC                   eval      stuffit = *on
500aAC                   eval      licenseonly = *on
500aAC                   endif
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Move PO
     *
     C                   eval      w1po = $ppo
     *
     *   Get item description.
     *
     C                   exsr      zzxopt
     *
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
500 DC**   itkey         chain     piritem                            79
500 DC**                 if        *in79
500 DC**                 eval      itdesc = *blanks
500 DC**                 eval      itpdsc = *blanks
500 DC**                 goto      enditm
500 DC**                 endif
500 A
500 A*  Use DRI interface to get item.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $pwhse
500 AC                   eval      $ititem  = $pitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETALL'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   clear                   #rcvitem
500 AC                   clear                   #rcvtype
500 AC                   clear                   #rcvdesc
500 AC                   clear                   #rcvpdsc
500 AC                   clear                   #rcvwhdp
500 AC                   clear                   #rcvstyp
500 AC                   clear                   #rcvdesg
500 AC                   clear                   #rcvum1
500 AC                   clear                   #rcvflg1
500 AC                   clear                   #rcvum2
500 AC                   clear                   #rcvumq2
500 AC                   clear                   #rcvflg2
500 AC                   clear                   #rcvum3
500 AC                   clear                   #rcvumq3
500 AC                   clear                   #rcvnrpk
510bAC                   clear                   #rcvmflg
510bAC                   clear                   #rcvdday
510bAC                   clear                   #rcvmday
510bAC                   clear                   #rcvuday
500 AC                   clear                   #rcvflgd
500 AC                   clear                   #rcvcube
500 AC                   clear                   #rcvswgt
500 AC                   clear                   #slotitem
500 AC                   clear                   #slottype
500 AC                   goto      enditm
500 AC                   endif
500 A
500 AC                   eval      #rcvitem = $ititem
500 AC                   eval      #rcvtype = $ittype
500 AC                   eval      #rcvdesc = $itdesc
500 AC                   eval      #rcvpdsc = $itpdsc
500 AC                   eval      #rcvwhdp = $itwhdp
500 AC                   eval      #rcvstyp = $itstyp
500 AC                   eval      #rcvdesg = $itdesg
500 AC                   eval      #rcvum1  = $itum1
500 AC                   eval      #rcvflg1 = $itflg1
500 AC                   eval      #rcvum2  = $itum2
500 AC                   eval      #rcvumq2 = $itumq2
500 AC                   eval      #rcvflg2 = $itflg2
500 AC                   eval      #rcvum3  = $itum3
500 AC                   eval      #rcvumq3 = $itumq3
500 AC                   eval      #rcvnrpk = $imnrpk
510bAC                   eval      #rcvmflg = $immflg
510bAC                   eval      #rcvdday = $imdday
510bAC                   eval      #rcvmday = $immday
510bAC                   eval      #rcvuday = $imuday
500 AC                   eval      #rcvflgd = $itflgd
500 AC                   eval      #rcvcube = $itcube
500 AC                   eval      #rcvswgt = $itswgt

     C                   if        uxflag = '0'
     C                   eval      $iitem = $pitem
500 MC                   eval      $idesc = $itdesc
500 MC                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
415bAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415bAC                   call      @fmti2
415bAC                   parm                    $iitem           15
415bAC                   parm                    $idesc           30
415bAC                   parm                    $ipdsc           15
415bAC                   parm                    $istr            70
415bAC                   else
     C                   call      @fmtit
     C                   parm                    $iitem
     C                   parm                    $idesc
     C                   parm                    $ipdsc
     C                   parm                    $istr
415bAC                   endif
     C                   movel     $istr         woitem
     C                   else
     C                   movel     $pitem        woitem
500 DC**   itkey         chain     itemdsc                            79
500 DC**                 if        not *in79
500 MC                   eval      wodsc1 = $ixdsc1
500 MC                   eval      wodsc2 = $ixdsc2
500 DC**                 endif
     C                   endif
500 A
500 A*  Use DRI interface to get Slot item.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $pwhse
500 AC                   eval      $ititem  = $pitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETSLOT'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   clear                   #slotitem
500 AC                   clear                   #slottype
500 AC                   endif
500 A
500 AC                   eval      #slotitem = $ititem
500 AC                   eval      #slottype = $ittype
     *
     C     enditm        tag
415 A*
415 A*    Get User's employee number to be written to PORCV file
415 A*    if any records are flagged as touched.
415 A*
415 AC                   call      'GETUSER'
415 AC                   parm      #user         $code            10
415 AC                   parm      0             $whse             3 0
415 AC                   parm      0             $emp#             5 0
415 AC                   parm      *blanks       $fnam            15
415 AC                   parm      *blanks       $init             1
415 AC                   parm      *blanks       $lnam            20
415 AC                   parm      *blanks       $whdp             5
415 AC                   parm      *blanks       $styp             1
415 AC                   parm      *blanks       $shft             6
415 AC                   parm      *blanks       $crew             6
415 AC                   parm      0             $nhrs             3 1
415 AC                   parm      *blanks       $rtn              8
500dAC                   parm                    E$BPU             1
500dAC                   parm                    E$LNG             2
500dAC                   if        $rtn <> '*OK'
500dAC                   eval      e$lng = 'EN'
500dAC                   endif
500 A
500 A*  If only updating license info, then post and get out.
500aA*   or item was stuffed.
500 A
700bDC*                  if        licenseonly
700bDC*                            or stuffit
700bMC                   if        stuffit
500 AC                   exsr      zzliconly
500 AC                   eval      nxtscr = 'EOJ'
500 AC                   goto      endinz
500 AC                   endif
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
415aA*
415aA*   If being called from PO200 RF small screen receiving
415aA*     Then use screen 2 for entry.
415aA*
415aAC                   if        $pprg = 'PO200'
740aAc                             or $pprg = 'PO201'
415aAC                   eval      w2pctr = 1
415aAC                   eval      w2pal = reccnt
415aAC                   exsr      scr02i
415aAC                   endif

     C     endinz        endsr
500 A
500 A*----------------------------------------------------------------
500 A*  ZZLICONLY  Only update license files
500 A*----------------------------------------------------------------
500 A
500 AC     zzliconly     begsr

     *  Loop through all label records created by RC160.

     C     partk2        setll     label2
     C                   dow       forever = forever
500aAC                   if        stuffit
     C     partk2        reade     label2
500aAC                   else
500aAC     partk2        reade(n)  label2
500aAC                   endif
     C                   if        %eof
     C                   leave
     C                   endif
610aA
610aA*    Get LICENSE record.
610aA
610aAC                   eval      kytrn# = lbtrn#
610aAC     lcnsky1       chain(en) license1
610aAC                   if        not %found(license1)
610aAC                   eval      lilcns = ' '
610aAC                   endif

     *    Fill in subfile fields (used in zzllp)

610aAC                   eval      w1lcns = lilcns
     C                   eval      w1qty = lbqalc
     C                   eval      w1tie = lbtie
     C                   eval      w1hi = lbhigh
     C                   eval      w1trn# = lbtrn#
     C                   eval      w1lbl# = lblbl#
     C                   eval      w1seq = lbseq
     C                   eval      w1um = lbucod

     C                   eval      w1utyp = lbutyp
     C                   eval      w1whdp = lbwhdp
     C                   eval      w1aisl = lbaisl
     C                   eval      w1loc = lbloc
     C                   eval      w1rlvl = lbrlvl
     C                   eval      w1hand = lbhand

     C                   if        lbaisl = 'XDK'  or
     C                             lbasl2 = 'XDK'
     C                   eval      w1xdk = 'Y'
     C                   else
     C                   eval      w1xdk = ' '
     C                   endif
610aDC**
610aDC**   Update license files.
610aDC**
610aDC**                 exsr      zzllp
610aA
610aA*    Update LICINFO.
610aA
610aAC*                  exsr      zzlicinfo
640hMC                   exsr      zzlicinfonew
650aA * new haccp cross ref added
650aA /free
650aA    hxlcns = $lnlcns;
650aA    for xx = 1 to 20;
650aA      $p1parms1 = $parms1(xx);
650aA        if $p1po <> ' ';
650aA          hxwhse =  %dec($p1whse:3:0);
650aA          hxPO = $p1po;
650aA          hxPOSeq = %dec($p1poseq:5:0);
650aA          hxseq# = %dec($p1qstseq:5:0);
650aA          hxadduc = $p1uctime;
650aA          write hxrec;
650aA        endif;
650aA    endfor;
650aA /end-free
640fA*    Update POASN
640fA
640fAC                   exsr      zzpoasn
610aA
610aA*    Add record to PORCV to mark as touched/received.
610aA
610aAC                   exsr      zzurcv
500aA
500aA*    For StuffIt, close label and transaction.
500aA
500aAC                   if        stuffit
500aAC                   eval      lbstat = 'C'
500aAC                   update    record
500aAC                   exsr      zzclosetrn
500aAC                   endif

     C                   enddo

     C                   endsr
417cA*
610aDC**---------------------------------------------------------------
610aDC**
610aDC** ZZLLP    Lot/license tracking item. Write out tracking info.
610aDC**
610aDC**   zzllp         begsr
610aDC**
610aDC** Add license to license history.
610aDC**
610aDC**                 exsr      clr$lichist
610aDC**                 eval      $lrlcnsu = *on
610aDC**                 eval      $lrlcns  = w1lcns
610aDC**                 eval      $lrtrn#u = *on
610aDC**                 eval      $lrtrn#  = w1trn#
610aDC**                 eval      $lrlbl#u = *on
610aDC**                 eval      $lrlbl#  = w1lbl#
500 AC**??????????       eval      $lrolic  = w1lcns
610aDC**                 select
610aDC**                 when      w1utyp = '1'
610aDC**                 eval      $lrlqy2u = *on
610aDC**                 eval      $lrlqy2  = w1qty
610aDC**                 when      w1utyp = '2'
610aDC**                 eval      $lrlqy3u = *on
610aDC**                 eval      $lrlqy3  = w1qty
610aDC**                 other
610aDC**                 eval      $lrlqy1u = *on
610aDC**                 eval      $lrlqy1  = w1qty
610aDC**                 endsl
610aDC**                 eval      $lrfcodu = *on
610aDC**                 eval      $lrfcod  = 'R'
610aDC**                 eval      $lrfarau = *on
610aDC**                 eval      $lrfara  = 'Receiving'
610aDC**                 eval      $lrfitmu = *on
610aDC**                 eval      $lrfitm  = #rcvitem
610aDC**                 eval      $lrfitypu = *on
610aDC**                 eval      $lrfityp = #rcvtype
610aDC**
610aDC**                 select
610aDC**
610aDC**                 when      stuffit
610aDC**                 exsr      zzgetslot
610aDC**                 eval      $lrtcodu = *on
610aDC**                 eval      $lrtcod  = 'S'
610aDC**                 eval      $lrtarau = *on
610aDC**                 eval      $lrtara  = 'Slot'
610aDC**                 eval      $lrtwhdu = *on
610aDC**                 eval      $lrtwhd  = $slwhdp
610aDC**                 eval      $lrtdspu = *on
610aDC**                 eval      $lrtdsp  = $sldisp
610aDC**                 eval      $lrtbaseu = *on
610aDC**                 eval      $lrtbase = $sacdsp
610aDC**                 eval      $lrtaslu = *on
610aDC**                 eval      $lrtasl  = $slaisl
610aDC**                 eval      $lrtlocu = *on
610aDC**                 eval      $lrtloc  = $slloc
610aDC**                 eval      $lrtlvlu = *on
610aDC**                 eval      $lrtlvl  = $slrlvl
610aDC**                 eval      $lrthndu = *on
610aDC**                 eval      $lrthnd  = $slhand
610aDC**                 eval      $lrtslpu = *on
610aDC**                 eval      $lrtslp  = 1
610aDC**                 eval      $lrtitmu = *on
610aDC**                 eval      $lrtitm  = #slotitem
610aDC**                 eval      $lrtitypu = *on
610aDC**                 eval      $lrtityp = #slottype
610aDC**
610aDC**                 other
610aDC**                 eval      $lrtcodu = *on
610aDC**                 eval      $lrtcod  = 'D'
610aDC**                 eval      $lrtarau = *on
610aDC**                 eval      $lrtara  = 'Dock'
610aDC**                 eval      $lrtitmu = *on
610aDC**                 eval      $lrtitm  = #slotitem
610aDC**                 eval      $lrtitypu = *on
610aDC**                 eval      $lrtityp = #slottype
610aDC**
610aDC**                 endsl
610aDC**
610aDC**    If only updating license info, then override some values.
610aDC**
610aDC**                 if        licenseonly
610aDC**                 eval      $lrlcns = '*PO'
610aDC**                 endif
610aDC**
610aDC**                 eval      $dricommand = '*LICHIST'
610aDC**                 eval      $drisubcmd  = '%ADDLIC'
610aDC**                 eval      $drisys2upd = 'D'
610aDC**                 exsr      zzzdricop
610aDC**                 if        error
610aDC**                 endif
610aDC**
610aDC**                 if        licenseonly
610aDC**                 eval      w1lcns = $lrlcns
610aDC**                 endif
610aA
610aA*----------------------------------------------------------------
610aA*  ZZLICINFO   Update licinfo
610aA*----------------------------------------------------------------
610aA
610aAC     zzlicinfo     begsr
500 A
500 A*  Write out standard license information.
500 A
500 AC                   exsr      clr$licinfo
500 A
610aDC**                 eval      $lnemp# = 0
610aDC**                 eval      $lnuser = #user
500 AC                   eval      $lnpgm  = #pgm
500 AC                   eval      $lnjob  = #job
500 AC                   eval      $lnjobnbr  = #jobnbr
500 A
500 AC                   eval      $lnwhse  = $pwhse
500 AC                   eval      $lntype  = 'P'
500 AC                   eval      $lnlcns  = w1lcns
500 A
500 AC                   eval      $lncodeu(1) = *on
500 AC                   eval      $lncode(1) = '*PO'
500 AC                   eval      $lncseq(1) = 1
500 AC                   eval      $lnvaltyp(1) = 'A'
500 AC                   eval      $lnvalchr(1) = $ppo
500 AC                   eval      $lnvalnum(1) = 0
500 A
500 AC                   eval      $lncodeu(2) = *on
500 AC                   eval      $lncode(2) = '*POSEQ'
500 AC                   eval      $lncseq(2) = 1
500 AC                   eval      $lnvaltyp(2) = 'N'
500 AC                   eval      $lnvalchr(2) = ' '
500 AC                   eval      $lnvalnum(2) = $pseq
500 A
500 AC                   eval      $lncodeu(3) = *on
500 AC                   eval      $lncode(3) = '*ITEM'
500 AC                   eval      $lncseq(3) = 1
500 AC                   eval      $lnvaltyp(3) = 'A'
500 AC                   eval      $lnvalchr(3) = $pitem
500 AC                   eval      $lnvalnum(3) = 0
500 A
610aDC**                 eval      $lncodeu(4) = *on
610aDC**                 eval      $lncode(4) = '*RCVJOB'
610aDC**                 eval      $lncseq(4) = 1
610aDC**                 eval      $lnvaltyp(4) = 'A'
610aDC**                 eval      $lnvalchr(4) = %trim(#user) + '/'
610aDC**                                        + %trim(#job) + '/'
610aDC**                                        + %trim(#jobnbr)
610aDC**                 eval      $lnvalnum(4) = 0
500 A
500 AC                   eval      $lncodeu(5) = *on
500 AC                   eval      $lncode(5) = '*RCVTRN#'
500 AC                   eval      $lncseq(5) = 1
500 AC                   eval      $lnvaltyp(5) = 'N'
500 AC                   eval      $lnvalchr(5) = ' '
500 AC                   eval      $lnvalnum(5) = w1trn#
500 A
610aDC**                 eval      $lncodeu(6) = *on
610aDC**                 eval      $lncode(6) = '*RCVTS'
610aDC**                 eval      $lncseq(6) = 1
610aDC**                 eval      $lnvaltyp(6) = 'A'
610aDC**                 time                    currtimestamp
610aDC**                 eval      $lnvalchr(6) = %char(currtimestamp)
610aDC**                 eval      $lnvalnum(6) = 0
500 A
500 AC                   eval      $lncodeu(7) = *on
500 AC                   eval      $lncode(7) = '*RCVLQTY'
500 AC                   eval      $lncseq(7) = 1
500 AC                   eval      $lnvaltyp(7) = 'N'
500 AC                   eval      $lnvalchr(7) = ' '
500 AC                   eval      $lnvalnum(7) = w1qty
500 A
500 AC                   eval      $dricommand = '*LICINFO'
500 AC                   eval      $drisubcmd  = '%ADD'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   endif
500 A
500 A*  Write out more standard and optional license information.
500 A
500 AC                   exsr      clr$licinfo
500 A
610aDC**                 eval      $lnemp# = 0
610aDC**                 eval      $lnuser = #user
500 AC                   eval      $lnpgm  = #pgm
500 AC                   eval      $lnjob  = #job
500 AC                   eval      $lnjobnbr  = #jobnbr
500 A
500 AC                   eval      $lnwhse  = $pwhse
500 AC                   eval      $lntype  = 'P'
500 AC                   eval      $lnlcns  = w1lcns
500 A
500 AC                   eval      $lncodeu(1) = *on
500 AC                   eval      $lncode(1) = '*RCVLBL#'
500 AC                   eval      $lncseq(1) = 1
500 AC                   eval      $lnvaltyp(1) = 'N'
500 AC                   eval      $lnvalchr(1) = ' '
500 AC                   eval      $lnvalnum(1) = w1lbl#
500 A
500 AC                   if        $pexpd > 0
500 AC                   eval      $lncodeu(2) = *on
500 AC                   eval      $lncode(2) = '*EXPDTE'
500 AC                   eval      $lncseq(2) = 1
500 AC                   eval      $lnvaltyp(2) = 'N'
500 AC                   eval      $lnvalchr(2) = ' '
500 AC                   eval      $lnvalnum(2) = $pexpd
500 AC                   endif
510bM
510bMC                   if        $pindt > 0
510bMC                   eval      $lncodeu(3) = *on
510bMC                   eval      $lncode(3) = '*DATEIN '
510bMC                   eval      $lncseq(3) = 1
510bMC                   eval      $lnvaltyp(3) = 'N'
510bMC                   eval      $lnvalchr(3) = ' '
510bMC                   eval      $lnvalnum(3) = $pindt
510bMC                   endif
500 A
510bDC*                  if        $pmfdt > 0
510bDC*                  eval      $lncodeu(3) = *on
510bDC*                  eval      $lncode(3) = '*MFGDTE'
510bDC*                  eval      $lncseq(3) = 1
510bDC*                  eval      $lnvaltyp(3) = 'N'
510bDC*                  eval      $lnvalchr(3) = ' '
510bDC*                  eval      $lnvalnum(3) = $pmfdt
510bDC*                  endif
500 A
500 AC                   if        $pfifo > 0
500 AC                   eval      $lncodeu(4) = *on
500 AC                   eval      $lncode(4) = '*FIFODTE'
500 AC                   eval      $lncseq(4) = 1
500 AC                   eval      $lnvaltyp(4) = 'N'
500 AC                   eval      $lnvalchr(4) = ' '
500 AC                   eval      $lnvalnum(4) = $pfifo
500 AC                   endif
500 A
500 AC                   if        $plotc <> ' '
500 AC                   eval      $lncodeu(5) = *on
500 AC                   eval      $lncode(5) = '*LOT'
500 AC                   eval      $lncseq(5) = 1
500 AC                   eval      $lnvaltyp(5) = 'A'
500 AC                   eval      $lnvalchr(5) = $plotc
500 AC                   eval      $lnvalnum(5) = 0
500 AC                   endif
500 A
500 AC                   if        w1utyp = 'N' and $pawt1 > 0
500 AC                             or w1utyp = '1' and $pawt2 > 0
500 AC                             or w1utyp = '2' and $pawt3 > 0
500 AC                   eval      $lncodeu(6) = *on
500 AC                   eval      $lncode(6) = '*AVGWGT'
500 AC                   eval      $lncseq(6) = 1
500 AC                   eval      $lnvaltyp(6) = 'N'
500 AC                   eval      $lnvalchr(6) = ' '
500 AC                   select
500 AC                   when      w1utyp = '1'
500 AC                   eval      $lnvalnum(6) = $pawt2
500 AC                   when      w1utyp = '2'
500 AC                   eval      $lnvalnum(6) = $pawt3
500 AC                   other
500 AC                   eval      $lnvalnum(6) = $pawt1
500 AC                   endsl
500 AC                   endif
500 A
500 AC                   eval      $dricommand = '*LICINFO'
500 AC                   eval      $drisubcmd  = '%ADD'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   endif
510bA
510bA*  Write out date type license information.
510bA
510bAC                   exsr      clr$licinfo
510bA
610aDC**                 eval      $lnemp# = 0
610aDC**                 eval      $lnuser = #user
510bAC                   eval      $lnpgm  = #pgm
510bAC                   eval      $lnjob  = #job
510bAC                   eval      $lnjobnbr  = #jobnbr
510bA
510bAC                   eval      $lnwhse  = $pwhse
510bAC                   eval      $lntype  = 'P'
510bAC                   eval      $lnlcns  = w1lcns
510bA
510bAC                   if        $pfifo > 0
510bAC                   eval      $lncodeu(1) = *on
510bAC                   eval      $lncode(1) = '*DATETYP'
510bAC                   eval      $lncseq(1) = 1
510bAC                   eval      $lnvaltyp(1) = 'A'
510bAC                   eval      $lnvalchr(1) = '*FIFODT'
510bAC                   eval      $lnvalnum(1) = 0
510bAC                   else
510bAC                   if        #rcvflgd = 'Y'
510bAC                   eval      $lncodeu(1) = *on
510bAC                   eval      $lncode(1) = '*DATETYP'
510bAC                   eval      $lncseq(1) = 1
510bAC                   eval      $lnvaltyp(1) = 'A'
510bAC                   eval      $lnvalnum(1) = 0
510bAC                   select
510bAC                   when      #rcvuday > 0 or
510bAC                             #rcvdday > 0
510bAC                   if        #rcvmflg = 'Y'
510bAC                   eval      $lnvalchr(1) = '*MFGDTE'
510bAC                   else
510bAC                   eval      $lnvalchr(1) = '*USEDTE'
510bAC                   endif
510bAC                   other
510bAC                   eval      $lnvalchr(1) = '*EXPDTE'
510bAC                   endsl
510bAC                   else
510bAC                   eval      $lncodeu(1) = *on
510bAC                   eval      $lncode(1) = '*DATETYP'
510bAC                   eval      $lncseq(1) = 1
510bAC                   eval      $lnvaltyp(1) = 'A'
510bAC                   eval      $lnvalchr(1) = '*ENTDTE'
510bAC                   eval      $lnvalnum(1) = 0
510bAC                   endif
510bA
510bAC                   move      #rcvuday      rcvuday
510bAC                   move      #rcvdday      rcvdday
510bAC                   move      #rcvmday      rcvmday
510bAC                   eval      $lncodeu(2) = *on
510bAC                   eval      $lncode(2) = '*DTESET1'
510bAC                   eval      $lncseq(2) = 1
510bAC                   eval      $lnvaltyp(2) = 'A'
510bAC                   eval      $lnvalchr(2) = '&DTEF='+(#rcvflgd) +
510bAC                             ' &MFGF='+(#rcvmflg)
510bAC                   eval      $lnvalnum(2) = 0
510bM
510bAC                   eval      $lncodeu(3) = *on
510bAC                   eval      $lncode(3) = '*DTESET2'
510bAC                   eval      $lncseq(3) = 1
510bAC                   eval      $lnvaltyp(3) = 'A'
510bAC                   eval      $lnvalchr(3) = '&MFGD='+(rcvmday) +
510bAC                             ' &USRD='+(rcvuday) +
510bAC                             ' &DSTD='+(rcvdday)
510bAC                   eval      $lnvalnum(3) = 0
510bAC                   endif
510b
640bAC                   if        $pdecvalue > ' '
640bAC                   eval      $lncodeu(4) = *on
640bAC                   eval      $lncode(4) = '*MFGDCOD'
640bAC                   eval      $lncseq(4) = 1
640bAC                   eval      $lnvaltyp(4) = 'A'
640bAC                   eval      $lnvalchr(4) = %trim($pdecvalue)
640bAC                   eval      $lnvalnum(4) = 0
640bAC                   endif

640bAC                   if        $pmfexpd > 0
640bAC                   eval      $lncodeu(5) = *on
640bAC                   eval      $lncode(5) = '*MFGEXP'
640bAC                   eval      $lncseq(5) = 1
640bAC                   eval      $lnvaltyp(5) = 'N'
640bAC                   eval      $lnvalchr(5) = ' '
640bAC                   eval      $lnvalnum(5) = $pmfexpd
640bAC                   endif

640bAC                   eval      $lncodeu(6) = *on
640bAC                   eval      $lncode(6) = '*MFGDTE'
640bAC                   eval      $lncseq(6) = 1
640bAC                   eval      $lnvaltyp(6) = 'N'
640bAC                   eval      $lnvalchr(6) = ' '
640bAC                   eval      $lnvalnum(6) = $pmfgdt

510bAC                   eval      $dricommand = '*LICINFO'
510bAC                   eval      $drisubcmd  = '%ADD'
510bAC                   eval      $drisys2upd = 'D'
510bAC                   eval      ck4err = *on
510bAC                   exsr      zzzdricop
510bAC                   if        error
510bAC                   endif
500 A
500cA*  Clam information.
520aA*  and Shucked information.

500cAC                   if        $pcode = Clams
520aAC                             or $pcode = Shucked
500cAC                   exsr      clr$licinfo

500cAC                   eval      $lnemp# = 0
500cAC                   eval      $lnuser = #user
500cAC                   eval      $lnpgm  = #pgm
500cAC                   eval      $lnjob  = #job
500cAC                   eval      $lnjobnbr  = #jobnbr

500cAC                   eval      $lnwhse  = $pwhse
500cAC                   eval      $lntype  = 'P'
500cAC                   eval      $lnlcns  = w1lcns

500cAC                   if        $phdte > *Zeros
500cAC                   eval      $lncodeu(1) = *on
500cAC                   eval      $lncode(1) = '*HRVDATE'
500cAC                   eval      $lncseq(1) = 1
500cAC                   eval      $lnvaltyp(1) = 'N'
500cAC                   eval      $lnvalchr(1) = ' '
500cAC                   eval      $lnvalnum(1) = $phdte
500cAC                   endif

500cAC                   if        $phloc <> *blanks
500cAC                   eval      $lncodeu(2) = *on
500cAC                   eval      $lncode(2) = '*HRVLOC'
500cAC                   eval      $lncseq(2) = 1
500cAC                   eval      $lnvaltyp(2) = 'A'
500cAC                   eval      $lnvalchr(2) = $phloc
500cAC                   eval      $lnvalnum(2) = *zeros
500cAC                   endif

500cAC                   if        $pcert <> *blanks
500cAC                   eval      $lncodeu(3) = *on
500cAC                   eval      $lncode(3) = '*HRVCERT'
500cAC                   eval      $lncseq(3) = 1
500cAC                   eval      $lnvaltyp(3) = 'A'
500cAC                   eval      $lnvalchr(3) = $pcert
500cAC                   eval      $lnvalnum(3) = *zeros
500cAC                   endif

500cAC                   eval      $dricommand = '*LICINFO'
500cAC                   eval      $drisubcmd  = '%ADD'
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      ck4err = *on
500cAC                   exsr      zzzdricop
500cAC                   if        error
500cAC                   endif
500cAC                   endif

     C                   endsr

640hA*----------------------------------------------------------------
640hA*  ZZLICINFONew Update New format of LICINFO
640hA*----------------------------------------------------------------
640hA
640hA /free
640hA   begsr zzlicinfonew;

640hA     // first I need to deal with the cross dock licinfo and uciinfo
640hA     if $pgslcns <> ' ' and w1xdk = 'Y';
640hA       exsr zzxdktemplcns;
640hA     endif;
700aA     // psr
700dD     //if $pgslcns <> ' ' and w1xdk <> 'Y';
700dM     if $pgslcns <> ' ' and w1xdk <> 'Y'
700dA        and $pgslcns <> w1lcns;
700aA       exsr zzpsrtemplcns;
700aA     endif;
640hA     // Write out standard license information
640hA     exsr clr$licinfo;
640hA     $lnwhse  = $pwhse;
640hA     $lnlcns  = w1lcns;
640hA     $lnseq = 1;

640hA     // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
640hA     // Need to get existing record so we don't overlay lnseqqty
640hA     if $pgslcns <> ' ';
640hA     $dricommand = '*LICINFO';
640hA     $drisubcmd  = '%GET';
640hA     $drisys2upd = 'D';
640hA     ck4err = *on;
640hA     exsr zzzdricop;
640hA     endif;
640hA     if error;
640hA       gs1seqqty = 0;
640hA     else;
640hA       gs1seqqty = $lnseqqty;
640hA     endif;

640hA     exsr clr$licinfo;
640hA     $lnwhse  = $pwhse;
640hA     $lnlcns  = w1lcns;
640hA
640hA     $lnseq = 1;
640hA     $lnpo = $ppo;
640hA     $lnposeq = $pseq;
650cD     //if $ifucicde = ' ' or $ifucicde = '1';
720bD     //if $ifrcvmth = ' ' or $ifrcvmth = '1';
720bM     if $ifrcvmth = ' ' or $ifrcvmth = '1' or
720bA        $ifrcvmth = '4' or $ifrcvmth = '5' or
720bA        $ifrcvmth = '6';
640hA       $lnseqqty = w1qty;
640hA     else;
640hA       $lnseqqty = gs1seqqty;
640hA     endif;
640hA     $lnitem = $pitem;
640hA     // LNRCVTYP notes
640hA     // 1 = Manual quantity (original method)
640hA     // 2 = Manual quantity with initial GS1 scan
640hA     // 3 = UCI using Mfg GS1 barcodes
640hA     // 4 = UCI using Internal GS1 barcodes (start with 99)
640hA     // 5 = ASN file

640hA     select;
640hA       when $plpn <> ' ';
640hA         $lnrcvtyp = '5';
640hA       when $ifucicde = ' ';
640hA         $lnrcvtyp = '1';
640hA       when $ifucicde = '1';
640hA         $lnrcvtyp = '1';
640hA       when $ifucicde = '2';
640hA         $lnrcvtyp = '3';
640hA       when $ifucicde = '3';
640hA         $lnrcvtyp = '4';
640hA       // don't know exactly what 2 will represent
640hA     endsl;
640hA     //$lnrcvtyp  = 'P';
640hA     $lnrcvtrn# = w1trn#;
640hA     $lnrcvlbl# = lblbl#;
640hA     $lnrcvqty = w1qty;

640hA     if $pindt > 0;
640hA       $lnentdate = $pindt;
640hA     endif;

640hA     if $pfifo > 0;
640hA       $lnenttype = '*FIFODT';
640hA     else;
640hA       if #rcvflgd = 'Y';
640hA         select;
640hA           when #rcvuday > 0 or
640hA                #rcvdday > 0;
640hA             if #rcvmflg = 'Y';
640hA               $lnenttype = '*MFGDTE';
640hA             else;
640hA               $lnenttype = '*USEDTE';
640hA             endif;
640hA           other;
640hA             $lnenttype = '*EXPDTE';
640hA         endsl;
640hA       else;
640hA         $lnenttype = '*ENTDTE';
640hA       endif;

640hA       $lndateflag = #rcvflgd;
640hA       $lnmfgflag = #rcvmflg;

640hA       $lnmfgdays = #rcvmday;
640hA       $lnusrdays = #rcvuday;
640hA       $lndstdays = #rcvdday;
640hA     endif;

640hA     $lnmfgdate = $pmfgdt;

640hA     if $pmfexpd > 0;
640hA       $lnmfgexp = $pmfexpd;
640hA     endif;

640hA     if $pfifo > 0;
640hA       $lnfifodate = $pfifo;
640hA     endif;

640hA     if $pexpd > 0;
640hA       $lnexpdate = $pexpd;
640hA     endif;

640hA     if $pdecvalue > ' ';
640hA       $lnmfgcode = $pdecvalue;
640hA     endif;

650cA     select;
650cA       when $pawt1 = $pdwgt;
650cA         $lnttllbs = $pdwgt * $lnrcvqty;
650cA       when $pawt2 = $pdwgt;
650cA         $lnttllbs = $pdwgt * $lnrcvqty;
650cA       when $pawt3 = $pdwgt;
650cA         $lnttllbs = $pdwgt * $lnrcvqty;
650cA       other;
650cA         $lnttllbs = $pdwgt;
650cA     endsl;
650cD     //$lnttllbs = $pdwgt;

640hA     if w1utyp = 'N' and $pawt1 > 0
640hA        or w1utyp = '1' and $pawt2 > 0
640hA        or w1utyp = '2' and $pawt3 > 0;
640hA       select;
640hA         when w1utyp = '1';
640hA           $lnavglbs = $pawt2;
640hA         when w1utyp = '2';
640hA           $lnavglbs = $pawt3;
640hA         other;
640hA           $lnavglbs = $pawt1;
640hA       endsl;
640hA     endif;

640hA     if $plotc <> ' ';
640hA       $lnlot = $plotc;
640hA     endif;

640hA     if $pbrand <> ' ';
640hA       $lnbrand = $pbrand;
640hA     endif;

640hA    // Clam and Shucked information.
640hA     if $pcode = Clams
640hA        or $pcode = Shucked;

640hA       if $phdte > 0;
640hA         $lnhrvdate = $phdte;
640hA       endif;

640hA       if $phloc <> ' ';
640hA         $lnhrvloc = $phloc;
640hA       endif;

640hA       if $pcert <> ' ';
640hA         $lnhrvcert = $pcert;
640hA       endif;
640hA     endif;

650cA       // calculate the PTI if adding.
650cA     if $pgslcns = ' ';
650cA       if $pbclot <> ' ' and $lgtin <> ' ';
650cA         pplot  = %subst($pbclot: 1 : 20);
650cA         if $pw1pti = 0;
650cA           calcpti ($lgtin: pplot: $pbcProdD: pppti);
650cA         else;
650cA           pppti = $pw1pti;
650cA         endif;
650cA         if pppti > 0
720aA            and $ifsltmth = '3';
650cA           $lnlotPTI4 = %editc(pppti:'X');
650cA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650cA           // create detail pti records in UCIINFO for use at selection
650cA           // when item is not UCI receiving method
650cA           k = 0;
650cA           if $ifrcvmth <> '2';
650cA             dou k = $lnrcvqty;
650cA               k = k + 1;
650cA               exsr clr$uciinfo;
650cA               $uiWhse = $pwhse;
650cA               $uiItem = $pitem;
650cA               $uiuci = %trim(%editc(pppti:'X'));
650cA               ucilic#($unext: $pwhse);
650cA               unexta = %editc($unext:'X');
650cA               $uiuciLcns = 'P:' + unexta;
650cA               $uiLcns = w1lcns;
650cA               $uiseq = 1;
650cA               $uiSerial = ' ';
650cA               // weight is calculated as average
650cA               if w1utyp = 'N' and $pawt1 > 0
650cA                 or w1utyp = '1' and $pawt2 > 0
650cA                 or w1utyp = '2' and $pawt3 > 0;
650cA                 select;
650cA                   when w1utyp = '1';
650cA                     $uiwgtlbs = $pawt2;
650cA                   when w1utyp = '2';
650cA                     $uiwgtlbs = $pawt3;
650cA                   other;
650cA                     $uiwgtlbs = $pawt1;
650cA                 endsl;
650cA               endif;
650cA               $uiSelTrn# = 0;
650cA               $uiSelLbl# = 0;
650cA               $uiSelOrd = 0;
650cA               $uiSelSeq = 0;
650cA               $uiSelCSeq = 0;
650cA               $uiSelTrax = ' ';
650cA               $uiCrtBy = '1';
720cA               $uiaUTyp  = 'N';
720cA               $uiaSlUTyp = 'N';
720cA               if $lgtin = *blanks;
720cA                  $uiaGtin = 0;
720cA               else;
720cA                  $uiaGtin  = %DEC($lgtin:14:0);
720cA               endif;
720cA               $uialot   = $pbclot;
720cA               $uiaexpD =  $pexpd;
720cA               $uiaEntD  = today;

650cA               $dricommand = '*UCIINFO';
650cA               $drisubcmd  = '%ADD';
650cA               $drisys2upd = 'D';
650cA               ck4err = *on;
650cA               zmflag  = *off;
650cA               exsr zzzdricop;
650cA             enddo;
650cA           endif;
650cA         endif;
650cA       endif;

650cA     endif;
640hA     $dricommand = '*LICINFO';
640hA     // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
640hA     if $pgslcns = ' ';
640hA       $drisubcmd  = '%ADDS';
640hA     else;
640hA       $drisubcmd  = '%CHANGES';
640hA     endif;
640hA     $drisys2upd = 'D';
640hA     ck4err = *on;
640hA     exsr zzzdricop;
640hA     if error;
640hA     endif;

640hA   endsr;
640hA /end-free
640fA*----------------------------------------------------------------
664fA*  ZZPOASN     Update poasn file
640fA*----------------------------------------------------------------
640fA
640fAC     zzpoasn       begsr
640fA * check to make sure programs exist or don't allow this command
640fAc                   eval      qcmd = 'CHKOBJ '
640fAc                                  + 'OBJ(GETASN) '
640fAc                                  + 'OBJTYPE(*PGM)'
640fAC                   call      'QCMDEXC'                            78
640fAC                   parm                    qcmd            256
640fAC                   parm      80            qlen             15 5
640fAc                   if        *in78 = *off
640fAc                   if        $plpn <> *blanks
640fAc                   eval      $ascmd = '*PUTLCNS'
640fAc                   call      'GETASN'
640fAc                   parm                    $ascmd            8
640fAc                   parm      ' '           $asrtn            8
640fAc                   parm      $pwhse        $aswhse           3 0
640fAc                   parm      $ppo          $aspo             9
640fAc                   parm      $plpn         $asLPN           50
640fAc                   parm      w1lcns        $aslcns          15
640fAc                   parm      $plotc        $aslot           20
640fAc                   parm      $pitem        $asitem          15
640fAc                   parm      $pseq         $asseq            5 0
640fAc                   parm      0             $asqty            8 0
640fAc                   parm      0             $asmfgdt          6 0
640fAc                   parm      0             $asexpdt          6 0
640fAc                   parm      0             $aswgt           11 3
640fAc                   endif
640fAc                   endif
640fAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVPOCHECK check for started RCVPO Transaction
650bA*
650bAC     zzrcvpocheck  begsr
650bA*
650bA*  See if RCVPO transaction is status 2 - start new if needed
650bA*
650bAC                   call      @crtrcv
650bAC                   parm      '*PO'         $lcmdr           10
650bAC                   parm      '*CHECK '     $lsubcmd         10
650bAC                   parm      $pwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      $itstyp       $litstyp          1
650bAC                   parm      $itwhdp       $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
650fA * this code was moved to be entered for each license
650fDC*                  Eval      $phdte = *Zeros
650fDC*                  Eval      $phloc = *Blanks
650fDC*                  Eval      $pcert = *Blanks
     *
650fDC*                  if        $pcode = Clams
650fDC*                            or $pcode = Shucked
650fDC*                  eval      sav$pcmd = $pcmd
650fDC*                  eval      $pcmd = '*ITEM'
650fDC*                  call      'PO172'       po172P
650fDC*                  eval      $pcmd = sav$pcmd
650fDC*                  if        $prtn = '*EXIT   ' or $prtn = '*CANCEL '
650fDC*                  eval      redspl = *on
650fDC*                  goto      endusub
650fDC*                  endif
650fDC*                  endif
     *
     *   Loop through changed subfile records and add/update file.
     *
     *
415aD**                   MOVE *OFF      *IN77
415aD**         *IN77     DOUEQ*ON
415aD**                   READCDETAIL1                  77
415aD**         *IN77     IFEQ *ON
415aD**                   LEAVE
415aD**                   ENDIF
     *
415aAC     1             do        reccnt        sflrec
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC     sflrec        chain     detl1sp                            77
500dAC                   other
415aAC     sflrec        chain     detail1                            77
500dAC                   endsl
     *
405 A*
405 A*     Ignore cross dock records.
405 A*
405 AC                   if        w1xdk = 'Y'
405 AC                   iter
405 AC                   endif
     *
     *     Get detail record.
     *
610aDC**   fileky        chain     record2                            7978
610aAC                   eval      kytrn# = w1trn#
610aMC     lcnsky1       chain     license1                           7978
     *
     *     Record locked. Tell user to try again.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   update    detl1sp
500dAC                   other
     C                   update    detail1
500dAC                   endsl
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      errmsg = descsp(4)
500dAC                   other
     C                   eval      errmsg = desc(4)
500dAC                   endsl
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
610aDC**
610aDC**   License tracking item. Write out tracking record.
610aDC**
610aDC**                 exsr      zzllp
650fA * this code was moved to be entered for each license
650fAC                   Eval      $phdte = *Zeros
650fAC                   Eval      $phloc = *Blanks
650fAC                   Eval      $pcert = *Blanks
     *
650fAC                   if        $pcode = Clams
650fAC                             or $pcode = Shucked
650faC                   eval      sav$pcmd = $pcmd
650fAC                   eval      $pcmd = '*ITEM'
650fAC                   call      'PO172'       po172P
650fAC                   eval      $pcmd = sav$pcmd
650fAC                   if        $prtn = '*EXIT   ' or $prtn = '*CANCEL '
650fAC                   eval      redspl = *on
650fAC                   goto      endusub
650faC                   endif
650faC                   endif
610aA*
610aA*     Update LICINFO
610aA*
640hDC*                  exsr      zzlicinfo
640hMC                   exsr      zzlicinfonew
650aA * new haccp cross ref added
650aA /free
650aA    hxlcns = $lnlcns;
650aA    for xx = 1 to 20;
650aA      $p1parms1 = $parms1(xx);
650aA        if $p1po <> ' ';
650aA          hxwhse =  %dec($p1whse:3:0);
650aA          hxPO = $p1po;
650aA          hxPOSeq = %dec($p1poseq:5:0);
650aA          hxseq# = %dec($p1qstseq:5:0);
650aA          hxadduc = $p1uctime;
650aA          write hxrec;
650aA        endif;
650aA    endfor;
650aA /end-free
610aA*
610aA*     Update license number
610aA*
610aAC                   exsr      clr$license
600dAC                   eval      $liToLcnsU = *on
600eAC                   eval      $liToLcns = w1lcns
600dAC                   eval      $liOLcnsU = *on
600eAC                   eval      $liOLcns = w1lcns
600dAC                   eval      $liFrmOldLcnsU = *on
600eAC                   eval      $liFrmOldLcns = lilcns
600rAC                   eval      $liActionU = *on
600rAC                   eval      $liAction = 'DPT'
600rAC                   eval      $liActionU = *on
600rAC                   eval      $liAction = 'DPT'
     C                   eval      $liLbl#U = *on
     C                   eval      $liLbl# = w1lbl#
     C                   eval      $liTrn#U = *on
     C                   eval      $liTrn# = w1trn#
600rAC                   eval      $liETrn#U = *on
600rAC                   eval      $liETrn# = 0

600dAC                   eval      $dricommand = '*LICENSE'
600dAC                   eval      $drisubcmd  = '%CHGDP'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      ck4err = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   endif

500cA* Print clam tags

500cAC                   if        $pcode = Clams
500cAC                                            and $pcode <> Clams
500cAC                   call      'TAGFMT'      tagfmtP
500cAC                   endIf
     *
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      liwhse = $pwhse
416a C                   eval      lilcns = w1lcns
     C                   eval      litrn# = w1trn#
415 A*
415 A*      Add record to PORCV to mark as touched/received.
415 A*
415 AC                   exsr      zzurcv
     *
     *     Record not found. Try adding record.
     *
     C                   if        *in79
610aDC**                 write     record2                              76
610aMC                   write     lirec1                               76
     C                   if        not *in76
417cA*
417cA*    License tracking item. Write out tracking record.
500 DC**                 if        $plict = 'Y'  or
500 DC**                           $plott = 'Y'
500 DC**                 exsr      zzllp
500 DC**                 endif
417cA*
     C                   iter
     C                   endif
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   update    detl1sp
500dAC                   other
     C                   update    detail1
500dAC                   endsl
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      errmsg = descsp(4)
500dAC                   other
     C                   eval      errmsg = desc(4)
500dAC                   endsl
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Record found. Try updating record.
     *
610aDC**                 update    record2                              76
610aMC                   update    lirec1                               76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   update    detl1sp
500dAC                   other
     C                   update    detail1
500dAC                   endsl
500dAC                   select
500dAC                   when      e$lng = 'SP'
500dAC                   eval      errmsg = descsp(4)
500dAC                   other
     C                   eval      errmsg = desc(4)
500dAC                   endsl
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
640aA *  Begin New Haccp Processing
      /free
        $lwhse = $pwhse;
        $lcmd = '*PODTL  ';
        $llevel = 'RCVL';
        $llicense = w1lcns;
        $lhpo = $ppo;
        $lhseq = $pseq;
        $ltype = ' ';
650aD   //ha410($lparm);
650aM   ha410($lparm:$lparm1);
      /end-free
640aA *  End New Haccp Processing
     C                   enddo
500cAC     endusub       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *
     *  Otherwise, update files and return.
     *
     *     Move screen fields to record fields.
     *
     *
     *  Update detail first.
     *
     C                   if        reccnt > 0
     C                   exsr      zzusub
     C     error         cabeq     *on           endup1
500cAC     redspl        cabeq     *on           endup1
     C                   endif
     *
     *
     *      Move key values to parameters
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
415aA*    Started using this routine in 4.15a
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *   If all of the license plates have not been entered
     *     then move on to the next one.
     *
     C                   if        w2pctr < w2pal
     C                   add       1             w2pctr
     C                   exsr      scr02i
     C                   goto      endup2
     C                   endif
     *
     *   Otherwise, update files.
     *
     C                   exsr      zzupd1
     *
     *   Now get out
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     *  If user is adding a detail record ...
     *    - add it to subfile and return to entry screen
     *    - do not update files
     *
     *R         W1ADDL    IFNE *BLANKS
     *R         W1ADDR    ORNE *BLANKS
     *R                   ADD  1         LSTSEQ
     *R                   Z-ADDLSTSEQ    W1SEQ
     *R                   MOVE W1ADDL    W1LEFT
     *R                   MOVE W1ADDR    W1RGHT
     *R                   MOVE *ON       *IN85
     *R                   EXSR SFLADD
     *R                   MOVE *BLANKS   W1ADDL
     *R                   MOVE *BLANKS   W1ADDR
     *R                   MOVE *ON       *IN17
     *R                   MOVE *ON       REDSPL
     *R                   GOTO ENDUP3
     *R                   ENDIF
     *
     *  Otherwise, update files and return.
     *
     *     Move screen fields to record fields.
     *
     *R                   CLEARRECORD
     *R                   Z-ADD$PWHSE    LHWHSE
     *R                   MOVE W1WHDP    LHWHDP
     *R                   CALL 'ADJUST'
     *R                   PARM '*RIGHT  '$TCMD
     *R                   PARM W1AISL    $TSTR
     *R                   MOVE $TSTR     LHAISL
     *R                   MOVE W1STYP    LHSTYP
     *R                   MOVE W1BLD     LHBLD
     *R                   Z-ADDW1SNUM    LHSNUM
     *R                   MOVE W1STRT    LHSTRT
     *
     *  Update detail first.
     *
     *R         RECCNT    IFGT 0
     *R                   EXSR ZZUSUB
     *R         ERROR     CABEQ*ON       ENDUP3
     *R                   ENDIF
     *
     *  Then header.
     *
     *      Add record
     *
     *R         $PCMD     IFEQ '*ADD    '
     *R                   WRITERECORD                 79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   EXSR ZM71
     *R                   GOTO ENDUP3
     *R                   END
     *R                   ELSE
     *
     *      -OR- Update record (it was read and locked in ZZGET2)
     *
     *R                   UPDATRECORD                 79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   EXSR ZM72
     *R                   GOTO ENDUP3
     *R                   END
     *R                   END
     *
     *      Move key values to parameters
     *
     C     endup3        endsr
415 A*---------------------------------------------------------------
415 A*
415 A*  ZZURCV   Update PORCV file.
415 A*
415 AC     zzurcv        begsr
415 A*
415 A*   Add record to PORCV.
415 A*
415 AC                   eval      porwhs = $pwhse
415 AC                   eval      porpo = $ppo
415 AC                   eval      porseq = w1seq
415 AC                   eval      pordte = today
415 AC                   time                    portim
415 AC                   eval      porusr = #user
415 AC                   eval      pordev = #job
415 AC                   eval      poremp = $emp#
415 AC                   eval      portrn = w1trn#
416aD**                   Z-ADDW1LCNS    PORLIC
416aAC                   eval      porlic = w1lcns
415 AC                   eval      porlbl = w1lbl#
415 AC                   eval      poract = 'R'
416aAC                   eval      poredt = 0
416aAC                   eval      poreti = 0
415 AC                   write     porrec                               49
415 AC                   endsr
     *
640hA*----------------------------------------------------------------
640hA*  ZZXDKTEMPLCNS Replace licinfo & uciinfo temp lcns with xdk license
640hA*----------------------------------------------------------------
640hA
640hA /free
640hA   begsr zzxdktemplcns;
640hA   // records that have a temporary license from gs1 scanning.
640hA   // will need to get the temp license record data, then replace the
640hA   // licinfo with the same data but real license.
640hA   // must loop to process all the licinfo seq#
640hA   // Let's handle the uciinfo file first
640hA      dou $drireturn = '*DONE';
640hA       exsr clr$uciinfo;
640hA
640hA       $uiWhse = $pwhse;
640hA       $uilcns = $pgslcns;
640hA
640hA       $dricommand = '*UCIINFO';
700aD       //$drisubcmd  = '%GETALL';
700aM       $drisubcmd  = '%GET1UCI';
640hA       $drisys2upd = 'D';
640hA       ck4err = *on;
640hA       zmflag  = *off;
640hA       exsr zzzdricop;
640hA       if error;
640hA       endif;
640hA       if $drireturn <> '*DONE';

720cA         // Lets add some more stuff for tracking
720cA         $uiaction = 'RPLXDK';
720cA         $uiaolcns = $uilcns;
720cA         // These fields need to be loaded after we retrieve the
720cA         // uci that will be deleted.
720cA         $uiver# = savever#;
720cA         $uiaddemp = $emp#;
720cA         $uiaddusr = #curruser;
720cA         $uiaddpgm  = #pgm;
720cA         $uiaddjob  = #job;
720cA         $uiaddnbr = #jobnbr;
640hA         // replace - which will add a new record
640hA         $uilcns = w1lcns;
720cA         $uialcns = w1lcns;

640hA         $dricommand = '*UCIINFO';
640hA         $drisubcmd  = '%REPLACE';
640hA         $drisys2upd = 'D';
640hA         ck4err = *on;
640hA         zmflag  = *off;
640hA         exsr zzzdricop;
640hA         if error;
640hA         endif;
640hA       // now delete the originals

640hA       $uilcns = $pgslcns;
720cA       $uialcns = $pgslcns;
720cA       // Lets add some more stuff for tracking
720cA       $uiaction = 'DLTTMPXDK';
720cA       $uiaolcns = $uilcns;
720cA       // These fields need to be loaded after we retrieve the
720cA       // uci that will be deleted.
720cA       $uiver# = savever#;
720cA       $uiaddemp = $emp#;
720cA       $uiaddusr = #curruser;
720cA       $uiaddpgm  = #pgm;
720cA       $uiaddjob  = #job;
720cA       $uiaddnbr = #jobnbr;

640hA       $dricommand = '*UCIINFO';
640hA       $drisubcmd  = '%DELETE1';
640hA       $drisys2upd = 'D';
640hA       ck4err = *on;
640hA       zmflag  = *off;
640hA       exsr zzzdricop;
640hA       if error;
640hA       endif;
640hA       endif;
640hA     enddo;

640hA   // Now let's handle the replacement of the licinfo records

640hA   for j = 1 to 99;
640hA   exsr clr$licinfo;

640hA   // Get the temp license record
640hA   $lnwhse  = $pwhse;
640hA   $lnlcns  = $pgsLcns;
640hA   $lnseq = j;

640hA   $dricommand = '*LICINFO';
640hA   $drisubcmd  = '%GET';
640hA   $drisys2upd = 'D';
640hA   ck4err = *on;
640hA   exsr zzzdricop;
640hA   if error;
640hA     leave;
640hA   endif;

640hA   // Replace with new license - this will actually write a new record
640hA   // With the data from the temporary record
640hA   $lnlcns  = w1lcns;

640hA   $dricommand = '*LICINFO';
640hA   $drisubcmd  = '%REPLACE';
640hA   $drisys2upd = 'D';
640hA   ck4err = *on;
640hA   exsr zzzdricop;
640hA   if error;
640hA   endif;

640hA   endfor;
640hA   // Now delete the temporary gs1/uci xdock
640hA   exsr clr$licinfo;
640hA   $lnwhse  = $pwhse;
640hA   $lnlcns  = $pgslcns;

640hA   $dricommand = '*LICINFO';
640hA   $drisubcmd  = '%DELETEALL';
640hA   $drisys2upd = 'D';
640hA   ck4err = *on;
640hA   exsr zzzdricop;
640hA   if error;
640hA   endif;

640hA   endsr;
640hA /end-free
700aA*----------------------------------------------------------------
700aA*  ZZPSRTEMPLCNS Replace licinfo & uciinfo temp lcns with *DP license
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA   begsr zzpsrtemplcns;
700aA   // records that have a temporary license from gs1 scanning.
700aA   // will need to get the temp license record data, then replace the
700aA   // licinfo with the same data but real license.
700aA   // must loop to process all the licinfo seq#
700aA   // Let's handle the uciinfo file first
700aA      dou $drireturn = '*DONE';
700aA       exsr clr$uciinfo;
700aA
700aA       $uiWhse = $pwhse;
700aA       $uilcns = $pgslcns;
700aA
700aA       $dricommand = '*UCIINFO';
700aA       //$drisubcmd  = '%GETALL';
700aM       $drisubcmd  = '%GET1UCI';
700aA       $drisys2upd = 'D';
700aA       ck4err = *on;
700aA       zmflag  = *off;
700aA       exsr zzzdricop;
700aA       if error;
700aA       endif;
700aA       if $drireturn <> '*DONE';

700aA         // replace - which will add a new record
700aA         $uilcns = w1lcns;
720cA         $uialcns = w1lcns;

700aA         $dricommand = '*UCIINFO';
700aA         $drisubcmd  = '%REPLACE';
700aA         $drisys2upd = 'D';
700aA         ck4err = *on;
700aA         zmflag  = *off;
700aA         exsr zzzdricop;
700aA         if error;
700aA         endif;
700aA       // now delete the originals

700aA       $uilcns = $pgslcns;
720cA       $uialcns = $pgslcns;

700aA       $dricommand = '*UCIINFO';
700aA       $drisubcmd  = '%DELETE1';
700aA       $drisys2upd = 'D';
700aA       ck4err = *on;
700aA       zmflag  = *off;
700aA       exsr zzzdricop;
700aA       if error;
700aA       endif;
700aA       endif;
700aA     enddo;

700aA   // Now let's handle the replacement of the licinfo records

700aA   for j = 1 to 99;
700aA   exsr clr$licinfo;

700aA   // Get the temp license record
700aA   $lnwhse  = $pwhse;
700aA   $lnlcns  = $pgsLcns;
700aA   $lnseq = j;

700aA   $dricommand = '*LICINFO';
700aA   $drisubcmd  = '%GET';
700aA   $drisys2upd = 'D';
700aA   ck4err = *on;
700aA   exsr zzzdricop;
700aA   if error;
700aA     leave;
700aA   endif;

700aA   // Replace with new license - this will actually write a new record
700aA   // With the data from the temporary record
700aA   $lnlcns  = w1lcns;

700aA   $dricommand = '*LICINFO';
700aA   $drisubcmd  = '%REPLACE';
700aA   $drisys2upd = 'D';
700aA   ck4err = *on;
700aA   exsr zzzdricop;
700aA   if error;
700aA   endif;

700aA   endfor;
700aA   // Now delete the temporary gs1/uci xdock
700aA   exsr clr$licinfo;
700aA   $lnwhse  = $pwhse;
700aA   $lnlcns  = $pgslcns;

700aA   $dricommand = '*LICINFO';
700aA   $drisubcmd  = '%DELETEALL';
700aA   $drisys2upd = 'D';
700aA   ck4err = *on;
700aA   exsr zzzdricop;
700aA   if error;
700aA   endif;

700aA   endsr;
700aA /end-free
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
     C                   endif
     *
     C                   endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
610aAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$license  Clear $license data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

610aDC**---------------------------------------------------------------
610aDC** clr$lichist  Clear $lichist data structure fields
610aDC**---------------------------------------------------------------
610aDC**
610aDC**   clr$lichist   begsr
610aDC**                 eval      savever# = $lrver#
610aDC**                 clear                   $lichist
610aDC**                 eval      $lrver# = savever#
610aDC**                 eval      $lremp# = $emp#
610aDC**                 eval      $lruser = #user
610aDC**                 eval      $lrpgm  = #pgm
610aDC**                 eval      $lrjob  = #job
610aDC**                 eval      $lrjobn = #jobnbr
610aDC**                 eval      $lrwhse = $pwhse
610aDC**                 eval      $lrwhseu = *on
610aDC**                 endsr

500 A*----------------------------------------------------------------
500 A*  clr$licinfo  Clear $licinfo data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
640hAC                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

610aDC**                 eval      $lnuser = #user
610aMC                   eval      $lnuser = #curruser
610aAC                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  clr$slot  Clear $slot data structure fields
500aA*----------------------------------------------------------------
500aA
500aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
610aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
610aAC                   eval      $saemp#U = *on
610aAC                   eval      $saemp# = $emp#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720cAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = $emp#
     C                   eval      $uiaddusr = #curruser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C*                  eval      $uiwhse = $pwhse
     C*                  eval      $uiTowhseu = *on
     C                   endsr
500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
610aAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
640hAC                   eval      $dridata2 = $licinfo2
610aDC**                 when      $dricommand = '*LICHIST'
610aDC**                 eval      $dridata = $lichist
610aAC                   when      $dricommand = '*LICENSE'
610aAC                   eval      $dridata = $license
610aAC                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720cAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
610aAC                             or $dricommand = '*SLOT'
610aAC                             or $dricommand = '*LICENSE'
640hAC                             or $dricommand = '*LICINFO'
720cAC                             or $dricommand = '*UCIINFO'
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

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #pgm
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C*                  exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C*                  exsr      zm0001
     C*                  exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
610aAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
640hAC                   eval      $licinfo2 = $dridata2
610aDC**                 when      $dricommand = '*LICHIST'
610aDC**                 eval      $lichist = $dridata
610aAC                   when      $dricommand = '*LICENSE'
610aAC                   eval      $license = $dridata
610aAC                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720cAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
** desc
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
Duplicate license numbers found
license number
** descsp
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
Duplicate license numbers found
license number
