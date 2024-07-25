600aA /copy *libl/qcopysrc,hspecs
750aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RN246      License entry Customer Returns VIRTUAL SLOTS
     *  23 September, 1999
     *  Roxanne Harrison
     *    Created using RN146
     *  NOTES
     *    Program creates records in LABEL and LICENSE files, calls
     *    ADDSTDTRN to create PIRTRAN record.
     *
     *  SK112 - 1.02
     *
     *  Revisions
     *
222 A*    06/27/97  DAS
     *      - Set on indicator 85 to force SFLNXTCHG read for all records.
416 A*    11/28/01  RH
     *      - Add F12 to scrn, 0 supress qty, recompile format changedrds.
416aA*    05/23/02  RH   4.16a
     *      - Change W1LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
416bA*    06/10/02  RH   4.16b
     *      - FIX - Not calculating # of pallets correctly, could
     *        not return each only for a case/each item.
     *
417 A*    04/28/03  MLB  4.17
     *      - Revised ZZCHK1 to use *LEFTNOZ for call to ADJUST.
417bA*    06/25/03  RH   4.17b
     *      - Fix: Do not aloow entry of special characters in license
     *             entry field.
520aA*    02/26/08  RH   5.20a
     *      - Fix: Position cursor to license field if only one pallet
     *
600 A*    05/17/09  DAS  6.00   P#00045
     *      - Converted to ILE
     *
600aA*    05/17/09  DAS  6.00a
     *      - Added logic to create license
     *      - Added logic to update LICINFO
     *      - Added input parms
     *
610aA*    08/27/09  DAS  6.10a
     *      - Fix:  SSB wasn't being handled correctly everywhere.
     *
640aA*    07/18/12  LMC  6.40a
     *      - Enh:  Added incoming parms to create new LICINFO records.
640bA*    10/11/12  LMC  6.40b
     *      - Fix:  Don't make third call to drilicinfo if lncode(1) is
     *              blank. Items that are not date sensitive were getting
     *              an error.
650aA*    05/22/13  LMC  6.50a
     *      - Enh: RCVRTN transaction for MRC reporting.
650bA*    09/28/12  LMC  6.50b
     *      - Enh:  Added GS1/UCI Scanning                            .
650cA*    06/20/13  LMC  6.50c
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
650dA*    10/31/13  LMC  6.50d
     *      - Enh: Add incoming parm for the entered pti#
650eA*    04/03/14  RH   6.50e
     *      - Enh: Added additional checks for unique license.
     *      LICINFO and LICLOG records stay longer with new cleanup.
     *      Added 650g and 650l mods from PO236
650fA*    12/02/14  LMC  6.50f
     *      - Fix: Need to write batctl records when we return from
     *      the call to PIRBAT# retrieving the next batch# to be used.
700aA*    06/29/15  RH   7.00a
     *      - Enh: Revised to put RCV slot into label record like
     *      PO Receiving PO236 mod 600a.
700bA*    08/28/15  LMC  7.00b
     *      - Fix: UCI Returns need to update original uciinfo with
     *      the return transaction.
700cA*    11/18/15  LMC  7.00c
     *      - Fix: Session/Device error when license found in LICLOG.
700dA*    01/06/16  LMC  7.00d
     *      - Enh: Added logic to print receiving label like PO236.
     *        This only occurs if client has receiving option Use
     *        Generic License set to N. These labels replace the
     *        Normal license plate applied to the product.
700eA*    11/10/16  LMC  7.00e
     *      - Enh - Send parms for  Tie / High & Brand to RFMT.
700fA*    01/05/17  LMC  7.00f
     *      - Enh - Change command from RCVIN to RTNIN to allow
     *        returns slot to be RTNDOCK instead of RCVDOCK.
710aA*    05/02/17  LMC  7.10a
     *      - Fix - Need to check to make sure old LICINFO record
     *        doesn't exist. If it does, the program actually fails
     *        in the update process. And the new return never updates
     *        the return file. User can't putaway the license, due to
     *        the fact that the licinfo doesn't have the correct info
     *        for the new return.
710bA*    09/22/17  LMC  7.10b
     *      - Enh - the item licenses have a new format name.
     *        For returns we will send RETURNS in the format name.
     *      - Enh - get item pick slot to print on label.
710cA*    10/18/17  LMC  7.10c
     *      - Fix - Don't do licinfo edit if $lcns is sent in.
     *        This would be uci scanning, and we have already created
     *        the licinfo at this point.
720aA*    08/03/16  LMC  7.20a
     *      - Enh: UCI Tracking.
730aA*    11/15/19  NLK  7.30a (DAMCO change)
     *      - Enh - cont from 700f, $saAction should be
     *        returns action 'RTN' not 'RCV' in zzurcvSlot
     *
750aA*    06/11/21  LMC  7.50a
     *      - Enh - Adding new return pallet license process.
750bA*    07/02/21  LMC  7.50b
     *      - Enh - Need edit for making sure the subfile does not
     *        allow the same license.
760aA*    05/02/22  LMC  760a
     *     - The host system FRESHBYTE requires a lot code.
     *       They tell us the lot code is the po&line number
     *       On a call today 4/29/22 they said the lot# was
     *       8 positions, 6 for po with leading zeros and 2 for line
     *       I am assuming the 2 positions for line# should have a
     *       leading zero also. so po 00030001 300 is po line 1.
     *       We will pull the lot code from the license that was
     *       shipped from liclog if the original label was scanned
     *       for the return, and attach that lot coee to the license
     *       entered on the return.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
SFPaA*    02/22/18  DAS  SFPa
     *      - Force to use generic returns label.
     *----------------------------------------------------------------
     *  Custom changes - West Side Foods
WSTa *   06/13/14  LMC  WSTa
     *     - Load the earliest prod/pack date from the UCI scan to
     *     slot entered date
     *----------------------------------------------------------------
     *  Custom changes - Halsey
HSYa *   11/20/17  LMC  HSYa
     *     - Client will use generic license for returns.
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
750aA*----------------------------------------------------------------
750aA*  Binding Directories
750aA*----------------------------------------------------------------

750aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
700dDF*rn246fm   cf   e             workstn
700dMFrn24601   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
     FLicense   uf a e           k disk
     *           LIREC                             KRENAMERECORD2
     Fwarehs    if   e           k disk
600aDF*iritem   if   e           k disk
600aDF*temdsc   if   e           k disk
     Foptions   if   e           k disk
     FLabel     o  a e           k disk
650fAFbatctl    o    e           k disk
710bAFslot3     if   e           k disk
750aAFpltlcns   if a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
750bAD lcns            s             15    dim(500)
417bD*                   DESC    1   8 50
417bMD desc            s             50    dim(9) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
600aA /COPY *libl/qcopysrc,C#SLOT
600aA /COPY *libl/qcopysrc,C#LICINFO
600aA /COPY *libl/qcopysrc,C#LICENSE
600aA /COPY *libl/qcopysrc,C#ITEM
650bA /COPY *libl/qcopysrc,C#UCIINFO
600aAD savever#        s                   like($slver#)

WSTaA*----------------------------------------------------------------
WSTaA*  Customer id
WSTaA*----------------------------------------------------------------

SFPaAD/copy qcopysrc,id#sfp
WSTaAD/copy qcopysrc,id#westsid
HSYaAD/copy qcopysrc,id#halsey
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

600aA*  Extra parameters not part of data structure.

600aAD $pindt          s              8  0
600aAD $pfifo          s              8  0
417bA*----------------------------------------------------------------
417bA*  Name constants
417bA*
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
760aAD freshbyte       c                   const('FRESHBYTE')
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
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
650aAD @crtrcv         c                   const('CRTRCVTRN')
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
     *
     D  erqty1                 1      4p 0
     D  erqty2                 5      8p 0
     D  eruom                  9     13
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
700dA*  Receiving options.
700dAD  oplpgm                 1     10
700dAD  opplcn                23     23
     *----------------------------------------------------------------
     *  Program info data structure
     *
600aA /COPY *libl/qcopysrc,C#PGMINFDS
600aDD*               sds
600aDD* #prog            *proc
600aDD* #job                 244    253
600aDD* #user                254    263
600aDD* #jobn                264    269
600aDD* #jobdt               276    281  0
600aDD* #jobtm               282    287  0
750aA*----------------------------------------------------------------
750aA* Function prototypes.
750aA*----------------------------------------------------------------

750aA /copy qcopysrc,p.bfcdteti

650cA*----------------------------------------------------------------
650cA*  Prototypes
650cA*----------------------------------------------------------------
650cAD calcpti         pr                  extpgm('CALCPTI')
650cA * Input
650cAD   pGTIN                             like($lgtin)
650cAD   pLOT                              like(pplot)
650cAD   pPackDate                         like($lbcProdD)
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
750aA*----------------------------------------------------------------
750aA*  Time variables
750aA*----------------------------------------------------------------

750aAD CurrStamploc    s               z
750aAD CurrStampsys    s               z
750aAD CurrStampuc     s               z
750aAD FromStamp       s               z
750aAD ToStamp         s               z
750aAD oldeststamp     s               z
750aAD ts              s               z

750aAD Duration        s              7  2
750aAD TtlMin          s              5  0
750aAD TtlMinSec       s              9  0
750aAD TtlSec          s              9  0
750aAD RemSec          s              3  0

750aAD bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Variables
     *
700dAD $adisp          s             12
700dAD $apslt          s             12
700dAD $astyp          s              1
700dAD $pdev           s             10
700dAD $pform          s             10
700dAD $pven           s             11  0
700dAD $pvitm          s             15
700dAD lblpgm          s                   like(oplpgm)
650cAD $lgtin          s             14
650cAD $lbcProdD       s              6  0
650cAD $lbclot         s             20
     D $msgf           s             10
650dAD $pw1pti         s              4  0
650aAD $rtnord         s              9
650cAD $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
600aAD ck4err          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
650bAD gs1seqqty       s              5  0
     D forevr          s              1
     D help            s              5  0
650dAd k               s                   like($lnrcvqty)
700bAD lastucilcns     s             15
     D msgk            s              4  0
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
     D nxtscr          s              3
     D ocode           s              8
     D pctr            s              3  0
     D posrec          s              4  0
     D ptqty           s              6  0
650cAd pplot           s             20
650cAd pppti           s              4  0
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rpal            s              3  0
     D sclear          s              1
     D tmpflg          s              1
     D today           s              8  0
     D today6          s              6  0
     D totqty          s              6  0
     D t1qty           s              6  0
     D t2qty           s              6  0
     D t3qty           s              6  0
650cAD unexta          s             13
     D uxflag          s              1
     D warn            s              1
     D x               s              2  0
600aAD zmflag          s               n
600aAD zmsflag         s               n
WSTaAD client          s             10
760aAD client2         s             10
760aAD clientinit      s              3
760aAD clienthost      s             10

600aAD #rcvarea        s              6
600aAD #rcvitem        s                   like($ititem)
600aAD #rcvtype        s                   like($ittype)
600aAD #rcvdesc        s                   like($itdesc)
600aAD #rcvpdsc        s                   like($itpdsc)
600aAD #rcvwhdp        s                   like($itwhdp)
600aAD #rcvstyp        s                   like($itstyp)
600aAD #rcvdesg        s                   like($itdesg)
600aAD #rcvum1         s                   like($itum1)
600aAD #rcvflg1        s                   like($itflg1)
600aAD #rcvum2         s                   like($itum2)
600aAD #rcvumq2        s                   like($itumq2)
600aAD #rcvflg2        s                   like($itflg2)
600aAD #rcvum3         s                   like($itum3)
600aAD #rcvumq3        s                   like($itumq3)
600aAD #rcvdday        s                   like($imdday)
600aAD #rcvmday        s                   like($immday)
600aAD #rcvmflg        s                   like($immflg)
600aAD #rcvuday        s                   like($imuday)
600aAD #rcvnrpk        s                   like($imnrpk)
600aAD #rcvflgd        s                   like($itflgd)
600aAD #rcvcube        s                   like($itcube)
600aAD #rcvswgt        s                   like($itswgt)
600aAD #rcvupc         s                   like($itupc)

600aAD #slotitem       s                   like($ititem)
600aAD #slottype       s                   like($ittype)
600aAD #rcvcwgt        s                   like($itcwgt)

750aAD $rtnpltlcns     s             10
750aAD $hldpicklbl     s             10
750bAD blklcn          s             15
750bAD l               s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Update licnese #.
     *              *VIEW    - View only
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
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
223 D*                    PARM           $PUM1   5
223 D*                    PARM           $PUM2   5
223 D*                    PARM           $PUM3   5
     C                   parm                    $pord             7 0
600aAC                   parm                    $plbl#            7 0
600aAC                   parm                    $pcwgt            9 2
600aAC                   parm                    $pexpd            8 0
600aMC                   parm                    $pindt
600aAC                   parm                    $pfifo
640aAC                   parm                    $pdecvalue       15
640aAC                   parm                    $pmfexpd          8 0
640aAC                   parm                    $pmfgdt           8 0
650aAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $lcns            15
650bAC                   parm                    $plotc           30
650cAC                   parm                    $lgtin
650cAC                   parm                    $lbcProdD
650cAC                   parm                    $lbclot
650dAC                   parm                    $pw1pti
750aAC                   parm                    $rtnpltlcns
750aAC                   parm                    $hldpicklbl
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
     *R         NXTSCR    WHEQ '02 '
     *R                   EXFMTSCREEN2
     *
     *R         NXTSCR    WHEQ '03 '
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
650bAc                   if        $lcns = ' ' or
650bAc                             error = *on
     C                   read      head1                                  50
650bAc                   endif
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
     C                   eval      nxtscr = 'EOJ'
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
WSTaA*
WSTaA* Get client id.
WSTaA*
WSTaAC                   call      'GETCLIENT'
WSTaAC                   parm                    client
760aAC                   parm                    client2
760aAc                   parm                    clientinit
760aAc                   parm                    clienthost
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
     C                   write     detail1
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
     C                   write     head1
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
     C                   write     cmdrec
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
     C                   write     head1
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
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
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
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
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
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
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     C                   eval      $msgf = #msgf
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

600aA*----------------------------------------------------------------
600aA*    DRI0001  Local system caused error
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001        begsr
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

600aA*----------------------------------------------------------------
600aA*    DRI0001s Local system caused error (send to different program)
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001s       begsr
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
600aA*----------------------------------------------------------------
600aA*      0105s
600aA*
600aAC     zm0105s       begsr
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
     *    PO23601  Total qty must equal total qty received.
     *
     C     zm036         begsr
     C                   eval      #msgid = 'PO23601'
     C                   eval      #msgtp = '*DIAG  '
     **                   Z-ADDPTQTY     ERQTY1
     **                   Z-ADDTOTQTY    ERQTY2
     C                   movea     errmsg        $md(1)
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
650aAc                   exsr      zzrcvrtncheck
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   eval      error = *off
     C                   eval      totqty = 0
     C                   eval      t1qty = 0
     C                   eval      t2qty = 0
     C                   eval      t3qty = 0
     C                   eval      eruom = *blanks
     *
     *
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in13 = *off
     C                   eval      *in33 = *off
750bA*
750bA*     Verify user hasn't scanned same license# multiple times.
750bA*
750bAC                   eval      l = 1
750bAC     w1lcns        lookup    lcns(1)                                80
750bAC                   select
750bAC                   when      *in80
750bA*
750bAC                   eval      error = *on
750bAC                   eval      *in33 = *on
750bAC                   eval      *in13 = *on
750bAC                   eval      errmsg = desc(9)
750bAC                   exsr      zm0105
750bAc                   eval      lcns = *blanks
750bA*
750bAC                   when      not *in80
750bA*
750bA*    License# not found.  Find next empty element.
750bAC                   eval      l = 1
750bAC                   eval      blklcn = *blanks
750bAC     blklcn        lookup    lcns(l)                                80
750bAC                   if        *in80
750baC                   eval      lcns(l) = w1lcns
750bAC                   endif
750bA*
750bAC                   endsl
     *
     *  License # must be entered.
     *
416aD**         W1LCNS    IFEQ 0
     *
700dA*  Only do checks if Use Generic option is 'Y'
700dAC                   if        opplcn = 'Y'
HSYaAc                             or opplcn = 'N' and client = Halsey
416a C                   if        w1lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   endif
     *
416 A*  Left justify license.
416 AC                   eval      $cstr = *blanks
416 AC                   move      w1lcns        $cstr
416 AC                   call      'ADJUST'
417 D*R                   PARM '*LEFT   '$CCMD   8
417 MC                   parm      '*LEFTNOZ'    $ccmd             8
416 AC                   parm                    $cstr            30
416 AC                   movel     $cstr         w1lcns
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
417bAC                   eval      errmsg = desc(9)
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
     C                   endif
     *
650eA*
650eA*  Check LICLOG before accepting this license
650eA*
650eAc                   if        error = *off
650eAC                   exsr      clr$license
650eAC                   eval      $liToLcnsU = *on
650eAC                   eval      $liToLcns = w1lcns
650eAC                   eval      $liOLcnsU = *on
650eAC                   eval      $liOLcns = w1lcns
650eAC                   eval      $dricommand = '*LICENSE'
650eAC                   eval      $drisubcmd  = '%GETINFO'
650eAC                   eval      $drisys2upd = 'D'
650eAC                   eval      ck4err = *off
650eAC                   exsr      zzzdricop
650eAc* if we get an ok on the return this means it exist - don't use
650eAC                   if        $drireturn = '*OK'
650eAC                   eval      error = *on
650eAC                   eval      *in33 = *on
650eAC                   eval      *in13 = *on
650eAC                   exsr      zm034
700cAc
700cAC                   if        posrec = 0
700cAC                   if        *in33
700cAC                   eval      posrec = recno
700cAC                   endif
700cAC                   endif
650eAC                   goto      endck1
650eAC                   endif
650eAC                   endif
700dAc                   endif
710aA*
710aA*  Check LICINFO before accepting this license
710aA*
710cDc*                  if        error = *off
710cMc                   if        error = *off and $lcns = ' '
710aAC                   exsr      clr$licinfo
710aAC                   eval      $lnwhse  = $pwhse
710aAC                   eval      $lnlcns = w1lcns
710aAC                   eval      $dricommand = '*LICINFO'
710aAC                   eval      $drisubcmd  = '%GET'
710aAC                   eval      $drisys2upd = 'D'
710aAC                   eval      ck4err = *off
710aAC                   exsr      zzzdricop
710aAc* if it exist don't allow to use
710aAC                   if        $drireturn = '*OK'
710aAC                   eval      error = *on
710aAC                   eval      *in33 = *on
710aAC                   eval      *in13 = *on
710aAC                   exsr      zm034
710aAc
710aAC                   if        posrec = 0
710aAC                   if        *in33
710aAC                   eval      posrec = recno
710aAC                   endif
710aAC                   endif
710aAC                   goto      endck1
710aAC                   endif
710aAC                   endif
     *
     *  Accumulate quantities entered.
     *
     C                   add       w1qty         totqty
     C                   if        w1umt = 'N'
     C                   add       w1qty         t1qty
     C                   else
     C                   if        w1umt = '1'
     C                   add       w1qty         t2qty
     C                   else
     C                   add       w1qty         t3qty
     C                   endif
     C                   endif
     *
222 AC                   eval      *in85 = *on
     C                   update    detail1
     C                   if        posrec = 0
     C                   if        *in33
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     *
     *  Quantities entered must equal total quantity.
     *
     C                   select
     *
     *  BREAK2 UOM
     C                   when      t3qty <> w1qrc3
     C                   eval      eruom = w1um3
     C                   eval      erqty1 = t3qty
     C                   eval      erqty2 = w1qrc3
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     *  BREAK1 UOM
     C                   when      t2qty <> w1qrc2
     C                   eval      eruom = w1um2
     C                   eval      erqty1 = t2qty
     C                   eval      erqty2 = w1qrc2
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     *
     *  NORMAL UOM
     C                   when      t1qty <> w1qrc1
     C                   eval      eruom = w1um1
     C                   eval      erqty1 = t1qty
     C                   eval      erqty2 = w1qrc1
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     *
     *  TOTAL  UOM
     C                   when      totqty <> ptqty
     C                   eval      eruom = *blanks
     C                   eval      erqty1 = totqty
     C                   eval      erqty2 = ptqty
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm036
     C                   endsl
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
     C     zzchk2        begsr
     C                   eval      error = *off
650aAc                   exsr      zzrcvrtncheck
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
650aAc                   exsr      zzrcvrtncheck
     *
     C     endck3        endsr
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
     C                   move      $ppo          w1ord
     *
     *   Move qtys
     *
     C                   eval      w1qrc1 = $prq1
     C                   eval      w1qrc2 = $prq2
     C                   eval      w1qrc3 = $prq3
416b C                   eval      need1 = $prq1
416b C                   eval      need2 = $prq2
416b C                   eval      need3 = $prq3
412  **  CHECK IF WE NEED TO SEND IN UM IN $PUM1....
223 D*R                   MOVE $PUM1     W1UM1
223 D*R                   MOVE $PUM2     W1UM2
223 D*R                   MOVE $PUM3     W1UM3
600aMC                   move      #rcvum1       w1um1
600aMC                   move      #rcvum2       w1um2
600aMC                   move      #rcvum3       w1um3
     C                   eval      rpal = $prpal
     *
     *   Increment # of Pallets if multiple units of measure received.
     *
     C                   eval      pctr = 0
     C                   if        w1qrc1 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        w1qrc2 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        w1qrc3 <> 0
     C                   add       1             pctr
     C                   endif
     C                   if        pctr > 0
     C                   eval      pctr = pctr - 1
     C                   add       pctr          rpal
     C                   endif
     *
     C                   exsr      sflclr
     *
     C     1             do        rpal          x
     C                   eval      w1qty = 0
     C                   eval      w1umt = *blanks
     C                   eval      w1uom = *blanks
416aD**                   Z-ADD0         W1LCNS
650bAC                   if        $lcns <> ' '
650bAc                   eval      w1lcns = $lcns
650bAc                   else
416a C                   eval      w1lcns = *blanks
650bAc                   endif
700dA /free
700dA   // protect license field if Use Generic License = 'N'
HSYaA   select;
HSYaA   when client = halsey;
HSYaA     *in70 = *off;
HSYaD   //if opplcn = 'N';
HSYaM   when opplcn = 'N';
700dA     *in70 = *on;
HSYaD   //else;
HSYaM   other;
700dA     *in70 = *off;
HSYaD   //endif;
HSYAM   endsl;
700dA /end-free
     *
     C                   select
     C                   when      need3 > 0
     C                   eval      w1qty = need3
     C                   eval      w1umt = '2'
416bD**                   ADD  1         RPAL
     C                   eval      need3 = 0
     *
     C                   when      need2 > 0
     C                   eval      w1qty = need2
     C                   eval      w1umt = *on
416bD**                   ADD  1         RPAL
     C                   eval      need2 = 0
     *
     C                   when      need1 > 0
     C                   eval      w1qty = need1
     C                   eval      w1umt = 'N'
416bD**                   ADD  1         RPAL
     C                   eval      need1 = 0
     *
     C                   when      pctr > 0
     C                   if        q3lft <> 0
     C                   eval      w1qty = q3lft
     C                   eval      q3lft = 0
     C                   eval      w1umt = '2'
     C                   eval      pctr = pctr - 1
     C                   else
     C                   if        q2lft <> 0
     C                   eval      w1qty = q2lft
     C                   eval      q2lft = 0
     C                   eval      w1umt = *on
     C                   eval      pctr = pctr - 1
     C                   else
     C                   eval      w1umt = 'N'
     C                   eval      pctr = 0
     C                   eval      rpal = rpal - 1
     C                   endif
     C                   endif
     *
     C                   other
     C                   eval      w1umt = 'N'
     C                   endsl
     *
412 D*R         NEED1     IFEQ 0
    D*R         NEED2     ANDEQ0
    D*R         NEED3     ANDEQ0
412 D*R                   MOVE *BLANKS   SAVDSP
412 D*R                   ENDIF
     *
     C                   select
     C                   when      w1umt = '1'
     C                   eval      w1uom = w1um2
     *
     C                   when      w1umt = '2'
     C                   eval      w1uom = w1um3
     *
     C                   other
     C                   eval      w1uom = w1um1
     C                   endsl
     *
520a C                   if        rpal = 1
520a C                   eval      *in13 = *on
520a C                   else
520a C                   eval      *in13 = *off
520a C                   endif
     C                   exsr      sfladd
     C                   enddo
     *
     ********
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
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
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
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
600aD **
600aD ** Define key for PIRITEM file.
600aD **
600aDC**   itkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    $pitem
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Initialize quantity left.
     *
     C                   eval      q1lft = $prq1
     C                   eval      q2lft = $prq2
     C                   eval      q3lft = $prq3
     *
     *  Initialize variables.
     *
     C                   eval      need1 = 0
     C                   eval      need2 = 0
     C                   eval      need3 = 0
     C                   eval      pctr = 0
     *
     *   Set indicator for subfile change(SFLNXTCHG)
     C                   eval      *in85 = *on
     *
     *   Get total quantity
     C                   eval      ptqty = $prq1
     C                   add       $prq2         ptqty
     C                   add       $prq3         ptqty
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
     C                   move      $ppo          w1ord
     *
     *   Get item description.
     *
     C                   exsr      zzxopt
     *
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
600aDC**   itkey         chain     piritem                            79
600aDC**                 if        *in79
600aDC**                 eval      itdesc = *blanks
600aDC**                 eval      itpdsc = *blanks
600aDC**                 goto      enditm
600aDC**                 endif
600aA
600aA*  Use DRI interface to get item.
600aA
600aAC                   exsr      clr$item
600aAC                   eval      $itwhse  = $pwhse
600aAC                   eval      $ititem  = $pitem
600aA
600aAC                   eval      $dricommand = '*ITEM'
600aAC                   eval      $drisubcmd  = '%GETALL'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      ck4err = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   clear                   #rcvitem
600aAC                   clear                   #rcvtype
600aAC                   clear                   #rcvdesc
600aAC                   clear                   #rcvpdsc
600aAC                   clear                   #rcvwhdp
600aAC                   clear                   #rcvstyp
600aAC                   clear                   #rcvdesg
600aAC                   clear                   #rcvum1
600aAC                   clear                   #rcvflg1
600aAC                   clear                   #rcvum2
600aAC                   clear                   #rcvumq2
600aAC                   clear                   #rcvflg2
600aAC                   clear                   #rcvum3
600aAC                   clear                   #rcvumq3
600aAC                   clear                   #rcvnrpk
600aAC                   clear                   #rcvmflg
600aAC                   clear                   #rcvdday
600aAC                   clear                   #rcvmday
600aAC                   clear                   #rcvuday
600aAC                   clear                   #rcvflgd
600aAC                   clear                   #rcvcube
600aAC                   clear                   #rcvswgt
600aAC                   clear                   #slotitem
600aAC                   clear                   #slottype
600aAC                   clear                   #rcvcwgt
600aAC                   goto      enditm
600aAC                   endif
600aA
600aAC                   eval      #rcvitem = $ititem
600aAC                   eval      #rcvtype = $ittype
600aAC                   eval      #rcvdesc = $itdesc
600aAC                   eval      #rcvpdsc = $itpdsc
600aAC                   eval      #rcvwhdp = $itwhdp
600aAC                   eval      #rcvstyp = $itstyp
600aAC                   eval      #rcvdesg = $itdesg
600aAC                   eval      #rcvum1  = $itum1
600aAC                   eval      #rcvflg1 = $itflg1
600aAC                   eval      #rcvum2  = $itum2
600aAC                   eval      #rcvumq2 = $itumq2
600aAC                   eval      #rcvflg2 = $itflg2
600aAC                   eval      #rcvum3  = $itum3
600aAC                   eval      #rcvumq3 = $itumq3
600aAC                   eval      #rcvnrpk = $imnrpk
600aAC                   eval      #rcvmflg = $immflg
600aAC                   eval      #rcvdday = $imdday
600aAC                   eval      #rcvmday = $immday
600aAC                   eval      #rcvuday = $imuday
600aAC                   eval      #rcvflgd = $itflgd
600aAC                   eval      #rcvcube = $itcube
600aAC                   eval      #rcvswgt = $itswgt
600aAC                   eval      #rcvcwgt = $itcwgt

     C                   if        uxflag = '0'
     C                   eval      $iitem = $pitem
600aMC                   eval      $idesc = #rcvdesc
600aMC                   eval      $ipdsc = #rcvpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     C                   else
     C                   movel     $pitem        woitem
600aDC**   itkey         chain     itemdsc                            79
600aDC**                 if        not *in79
     C                   eval      wodsc1 = $ixdsc1
     C                   eval      wodsc2 = $ixdsc2
600aDC**                 endif
     C                   endif
     *
     C     enditm        tag
700dA*
700dA*  Get receiving options.
700dA*
      /free
700dA   //wkwhse = $pwhse;
700dA   ocode = '*RCVLBL ';
        chain ($pwhse: ocode) options;
        if not %found(options);
700dA     error = *on;
700dA     $prtn = '*NOOPT  ';
700dA     leavesr;
700dA   endif;
SFPaA
SFPaA   // For Seashore, force generic label for Returns
SFPaA
SFPaA   if client = sfp;
SFPaA     opplcn = 'Y';
SFPaA   endif;
SFPaA
      /end-free
600aA*
600aA*    Get User's employee number to be written to PORCV file
600aA*    if any records are flagged as touched.
600aA*
600aAC                   call      'GETUSER'
600aAC                   parm      #curruser     $code            10
600aAC                   parm      0             $whse             3 0
600aAC                   parm      0             $emp#             5 0
600aAC                   parm      *blanks       $fnam            15
600aAC                   parm      *blanks       $init             1
600aAC                   parm      *blanks       $lnam            20
600aAC                   parm      *blanks       $whdp             5
600aAC                   parm      *blanks       $styp             1
600aAC                   parm      *blanks       $shft             6
600aAC                   parm      *blanks       $crew             6
600aAC                   parm      0             $nhrs             3 1
600aAC                   parm      *blanks       $rtn              8
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZLICINFO   Update licinfo
600aA*----------------------------------------------------------------
600aA
600aAC     zzlicinfo     begsr

     *  Write out standard license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = w1lcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*ITEM'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = $pitem
     C                   eval      $lnvalnum(1) = 0


     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*RCVTRN#'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = pttrn#


     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*RCVLQTY'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = w1qty

     C*                  if        $plotc <> ' '
     C*                  eval      $lncodeu(4) = *on
     C*                  eval      $lncode(4) = '*LOT'
     C*                  eval      $lncseq(4) = 1
     C*                  eval      $lnvaltyp(4) = 'A'
     C*                  eval      $lnvalchr(4) = $plotc
     C*                  eval      $lnvalnum(4) = 0
     C*                  endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Write out more standard and optional license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = w1lcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVLBL#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = lblbl#

     C                   if        $pexpd > 0
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pexpd
     C                   endif

     C                   if        $pindt > 0
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     c                   eval      $lnvalnum(3) = $pindt
     C                   endif

     C                   if        $pfifo > 0
     C                   eval      $lncodeu(4) = *on
     C                   eval      $lncode(4) = '*FIFODTE'
     C                   eval      $lncseq(4) = 1
     C                   eval      $lnvaltyp(4) = 'N'
     C                   eval      $lnvalchr(4) = ' '
     C                   eval      $lnvalnum(4) = $pfifo
     C                   endif

     C*                  eval      $lncodeu(5) = *on
     C*                  eval      $lncode(5) = '*AVGWGT'
     C*                  eval      $lncseq(5) = 1
     C*                  eval      $lnvaltyp(5) = 'N'
     C*                  eval      $lnvalchr(5) = ' '
     C*                  eval      $lnvalnum(5) = $pcwgt

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

640aA*  Write out Mfg standard and optional license information.

640aAC                   exsr      clr$licinfo
640aA
640aAC                   eval      $lnpgm  = #pgm
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr  = #jobnbr

640aAC                   eval      $lnwhse  = $pwhse
640aAC                   eval      $lntype  = 'P'
640aAC                   eval      $lnlcns  = w1lcns

640aAC                   if        $pdecvalue > ' '
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*MFGDCOD'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $lnvaltyp(1) = 'A'
640aAC                   eval      $lnvalchr(1) = %trim($pdecvalue)
640aAC                   eval      $lnvalnum(1) = 0

640aAC                   if        $pmfexpd > 0
640aAC                   eval      $lncodeu(2) = *on
640aAC                   eval      $lncode(2) = '*MFGEXP'
640aAC                   eval      $lncseq(2) = 1
640aAC                   eval      $lnvaltyp(2) = 'N'
640aAC                   eval      $lnvalchr(2) = ' '
640aAC                   eval      $lnvalnum(2) = $pmfexpd
640aAC                   endif

640aAC                   eval      $lncodeu(3) = *on
640aAC                   eval      $lncode(3) = '*MFGDTE'
640aAC                   eval      $lncseq(3) = 1
640aAC                   eval      $lnvaltyp(3) = 'N'
640aAC                   eval      $lnvalchr(3) = ' '
640aAC                   eval      $lnvalnum(3) = $pmfgdt
     c                   else
640aAC                   if        $pmfexpd > 0
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*MFGEXP'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $lnvaltyp(1) = 'N'
640aAC                   eval      $lnvalchr(1) = ' '
640aAC                   eval      $lnvalnum(1) = $pmfexpd
640aAC                   endif

640bAC                   if        $pmfgdt  > 0
640aAC                   eval      $lncodeu(2) = *on
640aAC                   eval      $lncode(2) = '*MFGDTE'
640aAC                   eval      $lncseq(2) = 1
640aAC                   eval      $lnvaltyp(2) = 'N'
640aAC                   eval      $lnvalchr(2) = ' '
640aAC                   eval      $lnvalnum(2) = $pmfgdt
640bAC                   endif
640aAC                   endif

640bAc                   if        $lncode(1)  = ' '
640bAc                   else
640aAC                   eval      $dricommand = '*LICINFO'
640aAC                   eval      $drisubcmd  = '%ADD'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      ck4err = *on
640aAC                   exsr      zzzdricop
640bAc                   endif
640aAC                   if        error
640aAC                   endif
417bAC                   endsr
650bA
650bA*----------------------------------------------------------------
650bA*  ZZLICINFONEW   Update licinfo  - new file format
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zzlicinfonew;
650bA     // first I need to deal with the no stockck licinfo and uciinfo
650bA     if $lcns <> ' ';
650bA       if $ppo = '*NOSTOCK';
650bA         exsr zznstemplcns;
700bA       else;
700bA         exsr zzreturnUCI;
650bA       endif;
650bA     endif;

760aA     // need to determine if wee have a lot number to send
760aA     if clienthost = freshbyte and $plbl# > 0;
760aA       exsr clr$license;
760aA       $lilbl#U = *on;
760aA       $lilbl#  = $plbl#;
760aA       $dricommand = '*LICENSE';
760aA       $drisubcmd  = '%GETLABEL';
760aA       $drisys2upd = 'D';
760aA       ck4err = *off;
760aA       exsr zzzdricop;
760aA       if $drireturn = '*OK';
760aA         // now go get the lot field for this license
760aA         if $liolcns  <> ' ';
760aA           exsr clr$licinfo;
760aA           $lnwhse  = $pwhse;
760aA           $lnlcns  = $liolcns;
760aA           $lnseq = 1;
760aA           $dricommand = '*LICINFO';
760aA           $drisubcmd  = '%GET';
760aA           $drisys2upd = 'D';
760aA           ck4err = *on;
760aA           exsr zzzdricop;
760aA           if $lnlot <> ' ';
760aA           $plotc  = $lnlot;
760aA           endif;
760aA         endif;
760aA       endif;
760aA     endif;

650bA     // Write out standard license information
650bA     exsr clr$licinfo;
650bA     $lnwhse  = $pwhse;
650bA     $lnlcns  = w1lcns;
650bA     $lnseq = 1;

650bA     // $LCNS    SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
650bA     // Need to get existing record so we don't overlay lnseqqty
650bA     select;
650bA       when $lcns <> ' ';
650bA         $dricommand = '*LICINFO';
650bA         $drisubcmd  = '%GET';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         exsr zzzdricop;
650bA         if error;
650bA           gs1seqqty = 0;
650bA         else;
650bA           gs1seqqty = $lnseqqty;
650bA         endif;
650bA         if $ifucicde = ' ' or $ifucicde = '1';
650bA           $lnseqqty = w1qty;
650bA         else;
650bA           $lnseqqty = gs1seqqty;
650bA         endif;
650bA         $lnrcvtrn# = pttrn#;
650bA         $lnrcvlbl# = lblbl#;
650bA         $lnrcvqty = w1qty;
650bA         $lnttllbs = $pcwgt;
650bA         $lnavglbs = $pcwgt / $lnrcvqty;
650bA       other;

650bA         exsr clr$licinfo;
650bA         $lnwhse  = $pwhse;
650bA         $lnlcns  = w1lcns;
650bA
650bA         $lnseq = 1;

650bA         $lnpo = ' ';
650bA         $lnposeq = 0;
650bA         // going to need to decide if I always use the w1qty.
650bA         if $ifucicde = ' ' or $ifucicde = '1';
650bA           $lnseqqty = w1qty;
650bA         else;
650bA           $lnseqqty = gs1seqqty;
650bA         endif;
650bA         $lnitem = $pitem;
650bA         // LNRCVTYP notes
650bA         // 1 = Manual quantity (original method)
650bA         // 2 = Manual quantity with initial GS1 scan
650bA         // 3 = UCI using Mfg GS1 barcodes
650bA         // 4 = UCI using Internal GS1 barcodes (start with 99)
650bA         // 5 = ASN file

650bA         select;
650bD           //when $plpn <> ' ';
650bD             //$lnrcvtyp = '5';
650bA           when $ifucicde = ' ';
650bA             $lnrcvtyp = '1';
650bA           when $ifucicde = '1';
650bA             $lnrcvtyp = '1';
650bA           when $ifucicde = '2';
650bA             $lnrcvtyp = '3';
650bA           when $ifucicde = '3';
650bA             $lnrcvtyp = '4';
650bA           // don't know exactly what 2 will represent
650bA         endsl;
650bA         $lnrcvtrn# = pttrn#;
650bA         $lnrcvlbl# = lblbl#;
650bA         $lnrcvqty = w1qty;

650bA         if $pindt > 0;
650bA           $lnentdate = $pindt;
650bA         else;
650bA           $lnentdate = 0;
650bA         endif;

650bA         if $pfifo > 0;
650bA           $lnenttype = '*FIFODT';
650bA         else;
650bA           if #rcvflgd = 'Y';
650bA             select;
650bA               when #rcvuday > 0 or
650bA                    #rcvdday > 0;
650bA                 if #rcvmflg = 'Y';
650bA                   $lnenttype = '*MFGDTE';
650bA                 else;
650bA                   $lnenttype = '*USEDTE';
650bA                 endif;
650bA               other;
650bA                 $lnenttype = '*EXPDTE';
650bA             endsl;
650bA           else;
650bA             $lnenttype = '*ENTDTE';
650bA           endif;

650bA           $lndateflag = #rcvflgd;
650bA           $lnmfgflag = #rcvmflg;

650bA           $lnmfgdays = #rcvmday;
650bA           $lnusrdays = #rcvuday;
650bA           $lndstdays = #rcvdday;
650bA         endif;

650bA         $lnmfgdate = $pmfgdt;

650bA         if $pmfexpd > 0;
650bA           $lnmfgexp = $pmfexpd;
650bA         else;
650bA           $lnmfgexp = 0;
650bA         endif;

650bA         if $pfifo > 0;
650bA           $lnfifodate = $pfifo;
650bA         else;
650bA           $lnfifodate = 0;
650bA         endif;

650bA         if $pexpd > 0;
650bA           $lnexpdate = $pexpd;
650bA         else;
650bA           $lnexpdate = 0;
650bA         endif;

650bA         if $pdecvalue > ' ';
650bA           $lnmfgcode = $pdecvalue;
650bA         endif;

650bA         $lnttllbs = $pcwgt;
650bA         $lnavglbs = $pcwgt / $lnrcvqty;

650bA        if $plotc <> ' ';
650bA           $lnlot = $plotc;
650bA         endif;

650bA           //if $pbrand <> ' ';
650bA             //$lnbrand = $pbrand;
650bA           //endif;

650bA          // Clam and Shucked information.
650bA           //if $pcode = Clams
650bA              //or $pcode = Shucked;

650bA         $lnhrvdate = 0;
650bA             //if $phdte > 0;
650bA               //$lnhrvdate = $phdte;
650bA             //endif;

650bA             //if $phloc <> ' ';
650bA               //$lnhrvloc = $phloc;
650bA             //endif;

650bA             //if $pcert <> ' ';
650bA               //$lnhrvcert = $pcert;
650bA             //endif;
650bA     endsl;

650cA       // calculate the PTI.
650dA       if $lnlot <> ' ' and $lgtin <> ' ';
650cA         pplot  = %subst($lbclot: 1 : 20);
650dA         if $pw1pti = 0;
650cA           calcpti ($lgtin: pplot: $lbcProdD: pppti);
650dA         else;
650dA           pppti = $pw1pti;
650dA         endif;
650cA         if pppti > 0;
650cA           $lnlotPTI4 = %editc(pppti:'X');
650cA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);

650cA           // create detail pti records in UCIINFO for use at selection
650cA           // when item is not UCI receiving method
650cA           k = 0;
650dD           //if $ifrcvmth <> '2';
650dM           if $ifrcvmth <> '2' and $ppo <> '*NOSTOCK';
650cA             dou k = $lnrcvqty;
650cA               k = k + 1;
650cA               exsr clr$uciinfo;
650cA               $uiWhse = $pwhse;
650cA               $uiItem = $pitem;
650cA               $uiuci = %trim(%editc(pppti:'X'));
650cA               ucilic#($unext: $pwhse);
650cA               unexta = %editc($unext:'X');
650cA               $uiuciLcns = 'P:' + unexta;
650cA               $uiLcns = $lnlcns;
650cA               $uiseq = 1;
650cA               $uiSerial = ' ';
650cA               // weight is calculated as average
650cA               $uiwgtlbs = $lnavglbs;
650cA               $uiSelTrn# = 0;
650cA               $uiSelLbl# = 0;
650cA               $uiSelOrd = 0;
650cA               $uiSelSeq = 0;
650cA               $uiSelCSeq = 0;
650cA               $uiSelTrax = ' ';
650cA               $uiCrtBy = '2';
720aA               if w1umt = *blanks;
720aA                  w1umt = 'N';
720aA               endif;
720aA               $uiaUTyp  = w1umt;
720aA               $uiaSlUTyp = w1umt;
720aA               if $lgtin = *blanks;
720aA                  $uiaGtin = 0;
720aA               else;
720aA                  $uiaGtin  = %DEC($lgtin:14:0);
720aA               endif;
720aA               $uiaLot   = $lnlot;
720aA               $uiaExpD  = $lnexpdate;
720aA               $uiaEntD  = today;

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

650bA     $dricommand = '*LICINFO';
650bA     // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
650bA     if $lcns = ' ';
650bA       $drisubcmd  = '%ADDS';
650bA     else;
650bA       $drisubcmd  = '%CHANGES';
650bA     endif;
650bA     $drisys2upd = 'D';
650bA     ck4err = *on;
650bA     exsr zzzdricop;
650bA     if error;
650bA     endif;

650bA   endsr;
650bA /end-free
750aA*----------------------------------------------------------------
750aA*
750aA*  ZZPLTLCNS     Return pallet license process
750aA*
750aAC     zzpltlcns     begsr
750aA /free
750aA   if $rtnpltlcns = ' ';
750aA     leavesr;
750aA   endif;
750aA     rnlwhse = $pwhse;
750aA     rnlpltlcns = $rtnpltlcns;
750aA     rnllcns = w1lcns;
750aA     rnlplbl = ' ';
750aA     rnltype = 'L';
750aA     rnlput  = ' ';
750aA     exsr getcurrstamp;
750aA     rnladdts  = currstampsys;
750aA     rnladduc  = currstampuc;
750aA     rnlputts  = *loval;
750aA     rnlputuc  = *loval;
750aA     write rnlrec;
750aA /end-free
750aAC                   endsr
750aA*----------------------------------------------------------------
750aA*  getcurrstamp  Get current timestamps
750aA*----------------------------------------------------------------
750aA
750aAC     getcurrstamp  begsr

750aMC                   callp     getmicrotime(currstampuc:currstampsys)
750aAC     currstampsys  adddur    bfcoffset:*H  currstamploc

750aAC                   endsr

650aA*----------------------------------------------------------------
650aA*
650aA*  ZZRCVRTNCHECK check for started RCVRTN Transaction
650aA*
650aAC     zzrcvrtncheck begsr
650aA*
650aA*  See if RCVRTN transaction is status 2 - start new if needed
650aA*
650aAc                   move      w1ord         $rtnord
650aAC                   call      @crtrcv
650aAC                   parm      '*RETURN'     $lcmdr           10
650aAC                   parm      '*CHECK '     $lsubcmd         10
650aAC                   parm      $itwhse       @lwhse            3 0
650aAC                   parm      0             $lpcs             5 0
650aAC                   parm      0             $lpallets         5 0
650aAC                   parm                    $lsavetrn         7 0
650aAC                   parm                    $rtnord           9
650aAC                   parm      $itstyp       $litstyp          1
650aAC                   parm      $itwhdp       $litwhdp          5
650aAC                   parm                    $lrtnr           10
650aAC                   endsr
600aA*---------------------------------------------------------------
600aA*
600aA*  zzurcvSlot   Put license into RCV slot
600aA*
600aAC     zzurcvSlot    begsr

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
610aDC**                 when      w1umt = 'N' and #rcvtype <> 'S'
610aMC                   when      w1umt = 'N'
     C                   eval      $saqty1 = w1qty
     C                   when      w1umt = '1'
610aDC**                           or w1umt = 'N' and #rcvtype = 'S'
     C                   eval      $saqty2 = w1qty
     C                   when      w1umt = '2'
610aDC**                           or w1umt = '1' and #rcvtype = 'S'
     C                   eval      $saqty3 = w1qty
     C                   endsl

     C                   eval      $saActionU = *on
730aD *                  eval      $saAction = 'RCV'
730aMC                   eval      $saAction = 'RTN'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = w1lcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = w1lcns
WSTaAC                   if        $pfifo > 0
WSTaAC                   eval      $slentdu = *on
WSTaAC                   eval      $slentd = $pfifo
WSTaAC                   endif

     C                   eval      $dricommand = '*SLOT'
700fDC*                  eval      $drisubcmd  = '%RCVIN'
700fMC                   eval      $drisubcmd  = '%RTNIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvslot
     C                   endif

     C     endurcvslot   endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
     C                   eval      @pgrp1 = 'R'
     *
     *
     *  Get batch number for labels.
     *
     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat             7 0
650fA*
650fA*     - Create batch control record.
650fA*
650fAC                   eval      btbat# = $pbat
650fAC                   eval      btwhse = $pwhse
650fAC                   eval      bttype = '*RTN    '
650fAC                   eval      btstat = ' '
650fAC                   eval      btrte = ' '
650fAC                   eval      $cvcmd = '*CURCMD '
650fAC                   call      @cvtdt
650fAC                   parm                    $cvtdt
650fAC                   eval      btstrd = $cvd8o
650fAC                   time                    btstrt
650fAC                   eval      btstrb = #user
650fAC                   write     btrec
     *
     *   Loop through changed subfile records and add/update file.
     *
     *
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     detail1                                77
     C                   if        *in77
     C                   leave
     C                   endif
600aA*
600aA*     Ignore subfile records without a qty.
600aA*
600aAC                   if        w1qty <= 0
600aAC                   iter
600aAC                   endif
     *
     *        Get transaction number.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
600aA
600aAC                   call      'PIRLBL#'
600aAC                   parm                    newlbl#           7 0
600aA
600aA*  Create license
700dA*  Build license when Use Generic License = 'N'
700dAc                   if        opplcn = 'N'  and w1lcns = ' '
HSYaAc                             and client <> Halsey
700dAc                   eval      w1lcns = 'R' + %editc(pttrn#:'X')
700dAc                   endif
600aA
600aAC                   exsr      zzurcvSlot
600aA
     ***********************************************
     *
     *    - Create transaction record.
     *    - Create label record for each quantity type.
     *
     C                   eval      tmpflg = *off
     *
     *
600aDC**                 if        w1qty > 0
     *
     *        Create label record for Normal qty.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
600aMC                   eval      lbwhdp = #rcvwhdp
700aDC*                  eval      lbaisl = *blanks
700aDC*                  eval      lbloc = 0
700aDC*                  eval      lbrlvl = 0
700aDC*                  eval      lbhand = *blanks
     C                   eval      lbpseq = 0
600aMC                   eval      lbstyp = #rcvstyp
     C                   eval      lbqryf = 0
700aDC*                  eval      lbdisp = *blanks
700aAC                   eval      lbaisl = $slaisl
700aAC                   eval      lbloc = $slloc
700aAC                   eval      lbrlvl = $slrlvl
700aAC                   eval      lbhand = $slhand
700aAC                   eval      lbstyp = $slstyp
700aAC                   eval      lbdisp = $sldisp
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = $pitem
     C                   eval      lbseq = 0
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = $ppo
     C                   eval      lbord = $pord
     C                   eval      lbqalc = w1qty
     C                   eval      lbqpck = w1qty
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *        Create label record for Normal qty.
610aDC**                 if        w1umt = 'N'
610aMC                   if        w1umt = 'N' and #rcvtype <> 'S'
     C                   eval      lbutyp = 'N'
600aMC                   eval      lbucod = #rcvum1
600aMC                   eval      lbucub = #rcvcube
     C     lbucub        mult      w1qty         lbcube
600aMC                   eval      lbuwgt = #rcvswgt
     C     lbuwgt        mult      w1qty         lbswgt
     C                   endif
     *
     *        Create label record for breakdown 1 qty.
     *
610aDC**                 if        w1umt = '1'
610aMC                   if        w1umt = '1' and #rcvtype <> 'S'
610aMC                             or w1umt = 'N' and #rcvtype = 'S'
610aDC**                 eval      lbutyp = *on
610aMC                   eval      lbutyp = w1umt
600aMC                   eval      lbucod = #rcvum2
600aMC                   if        #rcvumq2 <> 0
600aMC     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbucub        mult      w1qty         lbcube
600aMC     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbuwgt        mult      w1qty         lbswgt
     C                   endif
     C                   endif
     *
     *        Create label record for breakdown 2 qty.
     *
610aDC**                 if        w1umt = '2'
610aMC                   if        w1umt = '2' and #rcvtype <> 'S'
610aMC                             or w1umt = '1' and #rcvtype = 'S'
610aDC**                 eval      lbutyp = '2'
610aMC                   eval      lbutyp = w1umt
600aMC                   eval      lbucod = #rcvum3
600aMC                   if        #rcvumq2 <> 0  and
600aMC                             #rcvumq3 <> 0
600aMC     #rcvcube      div(h)    #rcvumq2      lbucub
600aMC     lbcube        div(h)    #rcvumq3      lbucub
     C     lbucub        mult      w1qty         lbcube
600aMC     #rcvswgt      div(h)    #rcvumq2      lbuwgt
600aMC     lbswgt        div(h)    #rcvumq3      lbuwgt
     C     lbuwgt        mult      w1qty         lbswgt
     C                   endif
     C                   endif
     *
     C                   eval      lbtrn# = pttrn#
600aAC                   eval      lblbl# = newlbl#
600aDC**                 call      'PIRLBL#'
600aDC**                 parm                    lblbl#
213 AC                   eval      lbgrp1 = @pgrp1
213 AC                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
700dA*  Use Generic License = 'N'
700dA*         Print label.
700dA*
700dAC                   if        opplcn = 'N'
HSYaAc                             and client <> Halsey
700dAC                   eval      $acmd = '*LABEL  '
700dAC                   eval      $atie = 0
700dAC                   eval      $ahigh = 0
700dAC                   eval      $aqty = w1qty
700dAC                   eval      $apslt = *blanks
700dAC                   eval      $adisp = *blanks
700dAC                   eval      $astyp = *blanks
700dAC                   eval      $aum = lbucod
700dAC                   if        $pexpd = 0
700dAC                   eval      $aexpd = 0
700dAC                   else
700dAC                   eval      $cvcmd = '*CMDMDY '
700dAC                   move      $pexpd        $cvd8i
700dAC                   call      @cvtdt
700dAC                   parm                    $cvtdt
700dAC                   eval      $aexpd = $cvd6o
700dAC                   endif
     *
700dA /free
700dA   // parse out the program name and label set name
700dA   if %subst(oplpgm:1:4) = 'RFMT';
700dA     lblset = %subst(oplpgm: 5 : 6);
700dA     lblpgm = %subst(oplpgm: 1 : 4);
710bA  // Get pick slot to be printed on the item license.
710bA  setll ($pwhse: $pitem: 'A': 'Y') slot3;
710bA  reade ($pwhse: $pitem: 'A': 'Y') slot3;
710bA  if not %eof(slot3);
710bA   $apslt = sldisp;
710bA  else;
710bA   $apslt = ' ';
710bA  endif;
700dA /end-free
700dAC                   call      lblpgm
700dAC                   parm                    $acmd             8
700dAC                   parm                    lblset            6
710bDC*                  parm      ' '           $plfmt            8
710bMC                   parm      'RTNMAN'      $plfmt            8
700dAC                   parm                    pttrn#
700dAC                   parm      $pwhse        $pwhs             3 0
700dAC                   parm                    #rcvwhdp
700dAC                   parm                    $astyp
700dAC                   parm                    $adisp
700dAC                   parm                    $apslt
700dAC                   parm                    $aqty             5 0
700dAC                   parm                    $aum              2
700dAC                   parm                    $atie             4 0
700dAC                   parm                    $ahigh            2 0
700dAC                   parm                    $pitem
700dAC                   parm                    #rcvdesc
700dAC                   parm                    #rcvpdsc
700dAC                   parm                    #rcvupc
700dAC                   parm                    $pven
700dAC                   parm                    $pvitm
700dAC                   parm                    $ppo
700dAC                   parm                    today6
700dAC                   parm                    $aexpd            6 0
700dAC                   parm                    $pdev
700dAC                   parm                    $pform
700eAC                   parm                    ossplate         15
700eAC                   parm                    bBrand           10
700dA /free
700dA   else;
700dA /end-free
700dAC                   call      oplpgm
700dAC                   parm                    $acmd             8
700dAC                   parm                    pttrn#
700dAC                   parm      $pwhse        $pwhs             3 0
700dAC                   parm                    #rcvwhdp
700dAC                   parm                    $astyp
700dAC                   parm                    $adisp
700dAC                   parm                    $apslt
700dAC                   parm                    $aqty             5 0
700dAC                   parm                    $aum              2
700dAC                   parm                    $atie             4 0
700dAC                   parm                    $ahigh            2 0
700dAC                   parm                    $pitem
700dAC                   parm                    #rcvdesc
700dAC                   parm                    #rcvpdsc
700dAC                   parm                    #rcvupc
700dAC                   parm                    $pven
700dAC                   parm                    $pvitm
700dAC                   parm                    $ppo
700dAC                   parm                    today6
700dAC                   parm                    $aexpd            6 0
700dAC                   parm                    $pdev
700dAC                   parm                    $pform
700dA /free
700dA   endif;
700dA /end-free
700dAC                   endif
     *
     *        Create transaction record.
     *
600aMC                   eval      @pwhdp = #rcvwhdp
600aMC                   eval      @pstyp = #rcvstyp
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTRTN'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
600aMC                   parm      #rcvwhdp      @pwhdp            5
600aMC                   parm      #rcvstyp      @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $ppo          @ppo              9
     C                   parm      'R'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
600aA
600aA*    Update licinfo.
600aA
650bDC*                  exsr      zzlicinfo
650bMC                   exsr      zzlicinfonew
750aAc                   exsr      zzpltlcns
     *
     *  Create license record.
     *
     C     fileky        chain     license                            7978
     *
     C                   eval      liwhse = $pwhse
416aD**                   Z-ADDW1LCNS    LILCNS
416a C                   eval      lilcns = w1lcns
     C                   eval      litrn# = pttrn#
     *     Record not found. Try adding record.
     *
     C                   if        *in79
     C                   write     lirec                                76
     C                   if        not *in76
     C                   iter
     C                   endif
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
409 AC                   endif
600aDC**                 endif
     *
     C                   enddo
     *
     *
     *
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      liwhse = $pwhse
416aD**                   Z-ADDW1LCNS    LILCNS
416a C                   eval      lilcns = w1lcns
     C                   eval      litrn# = pttrn#
     *
     *
412 AC                   eval      $prtn = '*OK     '
412 AC                   eval      $pord = $pbat
     C                   endsr
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
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *      Move key values to parameters
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     *
     C     endup3        endsr
     *
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

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$license  Clear $license data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$license   begsr
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

600aA*----------------------------------------------------------------
600aA*  clr$licinfo  Clear $licinfo data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
650bAC                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr
650bA*----------------------------------------------------------------
650bA*  clr$uciinfo  Clear $uciinfo data structure fields
650bA*----------------------------------------------------------------

650bAC     clr$uciinfo   begsr
650bAC                   eval      savever# = $uiver#
650bAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
650bAC                   eval      $uiver# = savever#
650bAC                   eval      $uiaddemp = $emp#
650bAC                   eval      $uiaddusr = #curruser
650bAC                   eval      $uiaddpgm  = #pgm
650bAC                   eval      $uiaddjob  = #job
650bAC                   eval      $uiaddnbr = #jobnbr
650bAC                   endsr

650bA*----------------------------------------------------------------
650bA*  ZZNSTEMPLCNS Process NO stock temporary license
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zznstemplcns;
650bA   // records that have a NS temporary license from gs1 scanning.
650bA   // These records are used to update the orginal uci that is returned
650bA   // Let's handle the uciinfo file first
650bA     dou $drireturn = '*DONE';
650bA       exsr clr$uciinfo;
650bA
650bA       $uiWhse = $pwhse;
650bA       $uilcns = $lcns;
650bA
650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%GET1UCI  ';
650bA       $drisys2upd = 'D';
650bA       ck4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA       if $drireturn <> '*DONE';

650bA         // Now get the original uci from selection to update with
650bA         // the return transaction number
650bA
650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%GET2RTN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;

720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'RTNORG';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;
720aA         $uirtntrn#  = pttrn#;
650bA         $uirtntrn#  = pttrn#;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%RETURN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA         // now delete the originals

650bA         $uilcns = $lcns;
720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'DLTNOSTK';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%DELETE1';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA       endif;
650bA     enddo;

650bA   endsr;
650bA /end-free

700bA*----------------------------------------------------------------
700bA*  ZZRETURNUCI  Process to update orginal uci with return trn#
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA   begsr zzreturnUCI;
700bA   // These records are used to update the orginal uci that is returned
700bA   // Let's handle each uciinfo
700bA     lastucilcns = ' ';
700bA     dou $drireturn = '*DONE';
700bA       exsr clr$uciinfo;
700bA
700bA       $uiWhse = $pwhse;
700bA       $uilcns = $lcns;
700bA       $uiucilcns  = lastucilcns;
700bA
700bA       $dricommand = '*UCIINFO';
700bA       $drisubcmd  = '%GET1RTN  ';
700bA       $drisys2upd = 'D';
700bA       ck4err = *on;
700bA       zmflag  = *off;
700bA       exsr zzzdricop;
700bA       if error;
700bA       endif;
700bA       if $drireturn <> '*DONE';
700bA         lastucilcns = $uiucilcns;

700bA         // Now get the original uci from selection to update with
700bA         // the return transaction number
700bA
700bA         $dricommand = '*UCIINFO';
700bA         $drisubcmd  = '%GET2RTN';
700bA         $drisys2upd = 'D';
700bA         ck4err = *on;
700bA         zmflag  = *off;
700bA         exsr zzzdricop;
700bA         if error;
700bA         endif;

720aA         if $DRIRETURN = '*NOPRVSEL ';
720aA         else;
720aA           // Lets add some more stuff for tracking
720aA           $uiaction = 'RTNORG';
720aA           $uiaolcns = $uilcns;
720aA           $uiaddpgm  = #pgm;
700bA           $uirtntrn#  = pttrn#;

700bA           $dricommand = '*UCIINFO';
700bA           $drisubcmd  = '%RETURN';
700bA           $drisys2upd = 'D';
700bA           ck4err = *on;
700bA           zmflag  = *off;
700bA           exsr zzzdricop;
700bA           if error;
700bA           endif;
720aA         endif;
700bA       endif;
700bA     enddo;

700bA   endsr;
700bA /end-free

600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
650bAC                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
650bAC                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
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
600aAC                   eval      errmsg    = 'Error occured on call to '
600aAC                                       + 'DRICOP'
600aAC                                       + '/' + %trim($drisubcmd)
600aAC                                       + ' from ' + #pgm
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0105s
600aAC                   when      zmflag
600aAC                   exsr      zm0105
600aAC                   endsl

417yMC                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0001s
600aAC                   when      zmflag
600aAC                   exsr      zm0001
     C*                  exsr      zzerrind
600aAC                   endsl

     C                   endsl

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
650bAC                   eval      $licinfo2 = $dridata2
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $license = $dridata
600aAC                   eval      $license2 = $dridata2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

600aAC                   eval      zmflag = *off
600aAC                   eval      zmsflag = *off
417yAC                   eval      ck4err = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
license number
