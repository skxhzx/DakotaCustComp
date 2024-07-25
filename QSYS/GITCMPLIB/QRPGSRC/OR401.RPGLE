      /COPY *libl/qcopysrc,hspecs
750fAH dftactgrp(*NO) actgrp(*CALLER)
750fMH bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *  Multilingual Verision
     *  Every screen and message has a corresponding Spanish version.
     *  Any changes must be made to both languages.
     *  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR401   RF - Select New Change Slot Location - Display
     *  14 November 2013
     *  Lynn McMahon
     *  Created using OR681
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    11/14/13  LMC  6.50a
     *      - Created.
650bA*    02/17/14  LMC  6.50b
     *      - Fix - Init w1lcns field.
700aA*    08/11/15  RH   7.00a
     *      - Fix - Add F9 to change view, uses *IN86
     *      - Fix - Init LALCNS if slot has no license
700b *    11/15/16  GJA  7.00b
     *      - Rename screen OR41002
     *      - Screen name needed for SpeakEasy
750fA*    04/18/21  DAS  7.50f
     *     - Enh:  Revised to work with SelectPrime (WT6000)
     *     - Used 750f because that is what was used in OR400
     *     - Added optional pJsonStr parameter
     *     - Changed screen format to be usropn
     *     - Sending in commands *SPLIST and *SPENTRY
750gA*    12/06/21  MLB  7.50g
     *     - Enh: Base the file open on SelectPrime (WT6000)
750hA*    01/18/22  LMC  7.50h
     *     - Enh:  Correct spoken words to Select Slot from Task
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  76        Error indicator on write to SLTRPEX.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *

750fA*----------------------------------------------------------------
750fA*  Binding Directories
750fA*----------------------------------------------------------------
750fA
750fDH*bnddir('QC2LE':'QUSAPIBD':'BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
700aDF*or401fm   cf   e             workstn
700aMF*or40101   cf   e             workstn
750fAF*****
750fAF***** If format name changes, change it in *INZSR ***
750fAF*****
700bMFor40102   cf   e             workstn
750fAF                                     usropn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsfl1:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(d16sfl1:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec16:msgk)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(d16sflsp:recno)
     Fitmexcp   uf a e           k disk
     FLabel     uf a e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fpiruser   if   e           k disk
     Fslot2     uf   e           k disk
     F                                     rename(slrec:recordu)
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
     Ftask      if   e           k disk
     Fvslot2    if   e           k disk
     Fworkopt   uf a e           k disk
     Fsltrpex   o    e           k disk
     Fprexref   uf a e           k disk
750fAFbfcsktlog o    e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     D desc            s             40    dim(6) ctdata perrcd(1)
     D optlsp          s             75    dim(1) ctdata perrcd(1)
     D cmdlsp          s             79    dim(1) ctdata perrcd(1)
     D descsp          s             40    dim(6) ctdata perrcd(1)

750fA*----------------------------------------------------------------
750fA*  YAJL Header
750fA*----------------------------------------------------------------
750fA
750fA /copy qcopysrc,yajl_h
750fAd yajlerr         s            500    varying
750fAd docNode         s                   like(yajl_val)
750fAd node            s                   like(yajl_val)
750fAd yajlRtnStatus   s             10i 0
750fAd yajlLen         s             10i 0

750fAd stdNode         s                   like(yajl_val)
750fAd stdPointer      s               *   inz(%addr(stdBuffer))
750fAd stdBuffer       s           2048
750fAd stdLen          s             10i 0

750fAd inputNode       s                   like(yajl_val)
750fAd inputPointer    s               *   inz(%addr(inputBuffer))
750fAd inputBuffer     s           1024
750fAd inputLen        s             10i 0

750fAd bufArray        s           3072
750fAd bufArrayPtr     s               *   inz(%addr(bufArray))
750fAd bufArrayLen     s             10i 0

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100
     D  $whse                  1      3  0
     D  $whdp                  4      8
     D  $pitem                 9     23
     D  $newsl                24     35
     D  $disp                 36     47
     D  $lbl#                 48     51p 0
     D  $trn#                 52     55p 0
     D  $bat#                 56     59p 0
     D  $blkq                 60     62p 0
     D  $oblkq                63     65p 0
     D  $task                 66     71
     D  $prg                  72     81
     D  $actualslot           82     82
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  slwhse                 1      3  0 inz(0)
     D  slitem                 4     18
     D  slstat                19     20
     D  slpick                21     21
     D  slprty                22     22  0 inz(0)
     D  slexpd                23     30  0 inz(0)
     D  slentd                31     38  0 inz(0)
     D  slwhdp                39     43
     D  slstyp                44     44
     D  slaisl                45     47
     D  slpseq                48     52  0 inz(0)
     D  slrlvl                53     54  0 inz(0)
     D  slhand                55     56
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     D  ukitem                21     35
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('NONE')
     D @vewpg          c                   const('NONE')
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
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
     D  $pdisp                27     38
     *
     *----------------------------------------------------------------
     *  LT210 parameters
     *----------------------------------------------------------------

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
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
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
     D normPrepick     s               n
     D prepickLabel    s               n
     *----------------------------------------------------------------
     *  *REPLEN  -  Replenishment options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY)
     *    OPOQRP  -  Order qty replenishment (Y/N).
     *    OPRPEX  -  Allow replenishment on expired items.
     *               1=Allow, 2=Don't allow, 3=Warn
     *    OPRPFI  -  Allow replenishments out of FIFO order.
     *               1=Allow, 3=Warn
     *    OPLMTS  -  Limit Specific Slot replenishment program to
     *               to display only one overflow location at a
     *               time. (Y/N)
     *
     * Data structure
     *
     D opdata          ds
     D  oprplb                 1      8
     D  opoqrp                 9      9
     D  oprpex                10     10
     D  oprpfi                11     11
     D  oplmts                12     12
     D  optend               117    117
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0 inz(0)
     D  $cvd8o                39     46  0 inz(0)
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  RF Selection error messages(s).
     *
     D msg101          c                   const('Slot not available')
     D msg102          c                   const('for RF Selection. ')
     D msg103          c                   const('Expired:')
     D msg104          c                   const('Try new slot. ')
     *
     D msg201          c                   const('Slot has expired  ')
     D msg202          c                   const('product.')
     *
     D msg301          c                   const('Slot selected out')
     D msg302          c                   const('of FIFO order.')
     *
     D msg401          c                   const('Qty entered is    ')
     D msg402          c                   const('less than original')
     D msg403          c                   const('RF Select qty of  ')
     D msg404          c                   const('xxxxx             ')
     *
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdisp                16     27
     D                 ds
     D  $ec                    1      2p 0
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *
     *----------------------------------------------------------------
     *
     D                 ds
     D  wkyy                   3      4
     D  wkmm                   5      6
     D  wkdd                   7      8
     D  wkexpd                 1      8  0
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
750fAD #msgtext        s            100
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
    A*----------------------------------------------------------------
    A*  DRI parameters
    A*----------------------------------------------------------------
    A
    A /COPY *libl/qcopysrc,C#DRIPARMS
    A
    A*----------------------------------------------------------------
    A*  Data Formats
    A*----------------------------------------------------------------
    A
    A /COPY *libl/qcopysrc,C#ITEM
    A /COPY *libl/qcopysrc,C#SLOT
    A /COPY *libl/qcopysrc,C#SLOTDEF
    A /COPY *libl/qcopysrc,C#LICENSE
    AD saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     *  Variables
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D #frombasesldsp  s                   like($sldisp)
     D #fromithead     s             70
     D #fromslwhdp     s                   like($slwhdp)
     D #fromslstyp     s                   like($slstyp)
     D #fromsldisp     s                   like($sldisp)
     D #fromslaisl     s                   like($slaisl)
     D #fromslloc      s                   like($slloc)
     D #fromslpseq     s                   like($slpseq)
     D #fromslrlvl     s                   like($slrlvl)
     D #fromslhand     s                   like($slhand)
     D #fromslrsrv     s                   like($slrsrv)
     D #fromslentd     s                   like($slentd)
     D #fromslexpd     s                   like($slexpd)
     D #fromslslfd     s                   like($slslfd)
     D #fromslactv     s                   like($slactv)
     D #fromslbld      s                   like($slbld)
     D #fromslpick     s                   like($slpick)
     D #fromslitem     s                   like($slitem)
     D #fromslsdef     s                   like($slsdef)
     D #fromslpos      s                   like($sdpos)
     D #fromslvirt     s                   like($sfvirt)
     D #fromslstk1     s                   like($slstk1)
     D #fromslstk2     s                   like($slstk2)
     D #fromslstk3     s                   like($slstk2)
     D #fromslalc1     s                   like($slalc1)
     D #fromslalc2     s                   like($slalc2)
     D #fromslalc3     s                   like($slalc3)
     D #fromsltfr1     s                   like($sltfr1)
     D #fromsltfr2     s                   like($sltfr2)
     D #fromsltfr3     s                   like($sltfr3)
     D #fromslpck1     s                   like($slpck1)
     D #fromslpck2     s                   like($slpck2)
     D #fromslpck3     s                   like($slpck3)
     D #fromslrcv1     s                   like($slrcv1)
     D #fromslrcv2     s                   like($slrcv2)
     D #fromslrcv3     s                   like($slrcv3)
     D #fromslphy1     s                   like($slphy1)
     D #fromslphy2     s                   like($slphy2)
     D #fromslphy3     s                   like($slphy3)
     D #fromslavl1     s                   like($slavl1)
     D #fromslavl2     s                   like($slavl2)
     D #fromslavl3     s                   like($slavl3)
     D #fromToLcns     s                   like($saToLcns)
     D #fromToPos      s                   like($saToPos)
     D #fromOLcns      s                   like($saOLcns)
     D bot             s              1
     D cancel          s              1
     D chk4err         s               n
     D ckexpd          s                   like(today)
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
     D curlic#         s                   like($tlic#)
     D curtsk          s              6
     D curtyp          s              1
     D dsplyd          s              3  0
     D dspwin          s              4
     D e               s              3  0
     D enter           s              5  0
750fDD*error           s              1
750fMD error           s               n
     D forceb          s              1
     D forevr          s              1
     D found           s              1
     D frstky          s                   like($puky)
     D fvslot          s              1
     D goback          s              3  0
     D help            s              5  0
     D keysta          s                   like(slstat)
     D kycode          s                   like(opcode)
     D kydisp          s                   like(sldisp)
     D kyexpd          s                   like(slexpd)
     D kypick          s                   like(slpick)
     D kyprty          s                   like(slprty)
     D msgk            s              4  0
     D msgtyp          s              8
     D nomore          s              1
     D noslt           s              1
     D nxtscr          s              3
     D offlag          s              1
     D optcnt          s              3  0
     D optln1          s             75
     D otaken          s              1
     D p               s              3  0
     D pagcmd          s              8
     D qtychg          s              7  0
     D recno           s              7  0
     D redspl          s              1
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtvslt          s              4
     D sclear          s              1
     D stop            s              1
     D t#task          s              6
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D top             s              1
     D tstdte          s                   like(today)
     D undobk          s              4
     D warn            s              1
     D woavl1          s              5  0
     D woslt           s             12
     D w1crew          s                   like(uscrew)
     D w1emp#          s                   like(usemp#)
     D w1shft          s                   like(usshft)
     D w1styp          s                   like(usstyp)
     D x               s              3  0
     D y               s              3  0
     D zmsflag         s               n
     D preLabel        s              7  0
750fAD pCmd            s             10
750fAD usingScreen     s               n
750fAD displayScreen   s               n
750fAD prime           s               n
750fAD exfmtScreen     s               n
750fAD jType           s              1
750fAD alphaSLEXPD     s              8
750fAD alphaSLENTD     s              8
750fAd vary4000        s           4000    varying

750fAd  spApp          s             20
750fAd  spUser         s             10
750fAd  spWhereFrom    s             20
750fAd  spUid          s             32
750fAd  spWhouse       s              3
750fAd  spF1F24Flags   s             24
750fAd  spBtnFlags     s             10
750fAD  spBtnClick     s             10
750fAd  errmsg500      s            500    varying
750fAd  jsonStr        s           4096    varying
750fAd  pJsonStr       s           4096    varying

750fA*----------------------------------------------------------------
750fA*  Time variables
750fA*----------------------------------------------------------------
750fA
750fAD CurrStamploc    s               z
750fAD CurrStampsys    s               z
750fAD CurrStampuc     s               z
750fAD FromStamp       s               z
750fAD ToStamp         s               z
750fAD oldeststamp     s               z
750fAD ts              s               z
750fA
750fAD Duration        s              7  2
750fAD TtlMin          s              5  0
750fAD TtlMinSec       s              9  0
750fAD TtlSec          s              9  0
750fAD RemSec          s              3  0
750fA
750fAD bfcoffset       s              3  0 inz(0)
750fAD ucOffset        s              3  0

750fA*----------------------------------------------------------------
750fA*  Sub-procedure prototypes
750fA*----------------------------------------------------------------

750fAd CreateRtnError  pr

750fAd LoadJson        pr

750fAd $InzFuncKeys    pr

750fAd $InzPgmVar      pr

750fAd $SetNxtScr      pr

750fAd WriteVoiceLog   pr
750fAd  type                               const like(slgtyp)
750fAd  buffer                             const like(slgbuf)

750fAd GetCurrStamp    pr

750fAd UpperToLower    pr         65535A   varying
750fAd  value                     65535A   varying const

750fAd SetPgmField     pr
750fAd  key                          50A   varying const
750fAd  value                              like(yajl_val) const

750fA*----------------------------------------------------------------
750fA*  Called program prototypes
750fA*----------------------------------------------------------------
750fA
750fA /copy qcopysrc,p.bfcdteti
750fA
750fAD GetJType        pr                  extpgm('GETJTYPE')
750fAD   jobType                      1


     *----------------------------------------------------------------
     *  Program info data structure
     *
      /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $CMD    *CHGSLOT - Change slot for RF selection.
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $NEWSL           - New slot selected for RF Select.
     *      $RTNCD  *OK      - New RF Select slot selected
      *              *BALANCE - RF Select quantity still not fully picked.
     *              *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
750fAC                   parm                    pJsonStr
     *----------------------------------------------------------------
     *  Main line
     *
750fA /free
750fA   if prime;
750fA     errmsg = '';
750fA     recno = 1;
750fA     spF1F24Flags = '';
750fA     spBtnFlags = '';
750fA     slgbuf = '<Begin> cmd= ' + $cmd + ' ' +  pjsonstr;
750fA     WriteVoiceLog('Inf': slgbuf);
750fA
750fA     // See if we should shut down
750fA     // pCmd is initialized in *INZSR
750fA
750fA     if pJsonStr = '*SHUTDOWN';
750fA       *inlr = *on;
750fA       return;
750fA     endif;
750fA
750fA     // Load JSON string and get pointers to sections
750fA
750fA     LoadJson();
750fA     if error;
750fA       return;
750fA     endif;
750fA
750fA     // Get Std field
750fA
750fA     jsonGetFields(stdNode);
750fA
750fA   endif;
750fA /end-free

     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     c                   if        $newsl <> ' '
     c                   eval      *in86 = '1'
     c                   else
     c                   eval      *in86 = '0'
     c                   endif
     *
750fAC                   if        not prime
750fAC                             or $cmd = '*SPLIST'
     C                   exsr      zzinz2
750fAC                   endif
     *
750fA
750fA /free
750fA
750fA   // For Prime, initialize inputs.
750fA   // We need to do this after zzinz2 because coming in with
750fA   // OR400.01 will clear the w1trn# field that we are sending in.
750fA
750fA   if prime;
750fA     $InzPgmVar();
750fA     if error;
750fA       errmsg500 = %trim(errmsg);
750fA       CreateRtnError();
750fA       return;
750fA     endif;
750fA   endif;
750fA
750fA   // Set flag for dspscr
750fA
750fA   if not prime;
750fA     displayScreen = *on;
750fA   else;
750fA     if $cmd = '*SPLIST';
750fA       displayScreen = *on;
750fA     else;
750fA       displayScreen = *off;
750fA     endif;
750fA   endif;
750fA   exfmtScreen = *off;
750fA
750fA /end-free
     C                   dow       nxtscr <> 'EOJ'
750fA
750fAC                   if        displayScreen
     C                   exsr      dspscr
750fAC                   endif
750fA
750fAC                   eval      displayScreen = *on
750fA
750fAC*    For Prime, we want to get out if a screen was displayed.
750fA
750fAC                   if        prime and exfmtScreen
750fAC                   leave
750fAC                   endif

     C     nxtscr        caseq     '01 '         sc1
     C*    nxtscr        caseq     '02 '         sc2
     C*    nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *

750fA /free
750fA    if prime;
750fA      if errmsg <> '';
750fA       errmsg500 = %trim(errmsg);
750fA       CreateRtnError();
750fA      endif;
750fA      $SetNxtScr();
750fA    endif;
750fA
750fA     if prime;
750fA       slgbuf = '<End> '
750fA              + 'error=' + error + ' '
750fA              + 'nxtscr=' + %trimr(nxtscr)
750fA              +  %trim(pJsonStr);
750fA       WriteVoiceLog ('Inf': slgbuf);
750fA     endif;
750fA
750fA /end-free

     C                   return
     *
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
750fAC                   eval      exfmtScreen = *off
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     *R                   WRITETITLE
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   select
     C                   when      nxtscr = '01 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exsr      sfldsp
     C                   select
     C                   when      e$lng = 'SP'
     C                   read      postnrsp                               50
     C                   read      scanresp                               50
     C                   other
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     C                   endsl
750fAC                   endif
     *
     C                   when      nxtscr = '02 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exsr      deldsp
750fAC                   endif
     *
     C                   when      nxtscr = '03 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   select
     C                   when      e$lng = 'SP'
     *    Write out Window format.
     C                   write     wdwqtysp                             50
     *    Write out Data format inside window.
     C                   write     qtyrecsp                             50
     C                   read      qtyrecsp                               50
     C                   when      e$lng = 'EN'
     *    Write out Window format.
     C                   write     wdwqty                               50
     *    Write out Data format inside window.
     C                   write     qtyrec                               50
     C                   read      qtyrec                                 50
     C                   endsl
750fAC                   endif
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       0323
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      redspl = *off
     C                   eval      e = *zeros
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
750fAC                   if        usingScreen
     C                   select
     C                   when      nxtscr = '01 '
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   read      d16sfcsp                               50
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              read      d16sfc                                 50
     C   86              read      d16sfc1                                50
     **                   OTHER
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   read      dspsfcsp                               50
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              read      dspsfc                                 50
     C   86              read      dspsfc1                                50
     C                   endsl
     C                   endsl
750fAC                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     *
     *
     C                   eval      w1disp = *blanks
650bAC                   eval      w1lcns = *blanks
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
750fAC                   if        usingScreen
     C                   write     clr0306
750fAC                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     *
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     delrecsp
     C                   other
     C                   write     delrec
     C                   endsl
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     cmddelsp
     C                   other
     C                   write     cmddel
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     *
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     *
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     C                   if        cancel = *off
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = frstky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 wrap-up
     *
     C     scr03e        begsr
     *
     C                   eval      *in90 = *off
     C                   if        cancel = *on
     C                   eval      w1disp = *blanks
650bAC                   eval      w1lcns = *blanks
     C                   eval      nxtscr = '01 '
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endif
     *
     C                   endsr
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
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C     *INki         caseq     *off          ent01
     C**                 cas                     ent01
     C                   endcs
     *
     C     endsc1        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     C                   exsr      cmd03
     C     cmdtkn        cabeq     *on           endsc3
     *
     C                   exsr      ent03
     *
     C     endsc3        endsr
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
750fA /free
750fA
750fA   // Open screen if running interactively
750fA
750fA   GetJType (usingScreen);
750gD   //if jType = '1';
750gM   if usingScreen = '1';
750fA     open or40102;
750fA   endif;
750fA
750fA   // See if called with SelectPrime
750fA
750fA   if not usingScreen and %parms >= 4;
750fA     prime = *on;
750fA     slgbuf = '<*Inzsr> cmd= ' + $cmd + ' ' +  pjsonstr;
750fA     WriteVoiceLog('Inf': slgbuf);
750fA   else;
750fA     prime = *off;
750fA   endif;
750fA /end-free

     *
     *  Initialize special keys
     *
     C                   eval      enter = *zeros
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   eval      optcnt = *zeros
     C                   endsr
     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = 0
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $whse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = w1emp#
     C                   endsr

     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for F12 - Cancel
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  Execute command keys that don't need the options verified.
     *
     *     Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        dsplyd        x
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86x             chain     d16sfl                             79
     C   86x             chain     d16sfl1                            79
     **                   OTHER
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86x             chain     dspsfl                             79
     C   86x             chain     dspsfl1                            79
     C                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              update    d16sfl
     C   86              update    d16sfl1
     **                   OTHER
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              update    dspsfl
     C   86              update    dspsfl1
     C                   endsl
     C                   endif
     C                   enddo
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Verify and save any options that were entered.
     *
     C                   exsr      savopt
     C     error         cabeq     *on           cmd01e
     *
     *  Execute command keys that did need the options verified
     *
     *  Test for F6 - Add record
     *
     C                   if        *inkf
     C                   eval      $pprg = #prog
     C                   eval      ukwhse = itwhse
     C                   eval      ukwhdp = itwhdp
     C                   eval      ukdisp = *blanks
     C                   eval      ukitem = ititem
     C                   eval      $puky = dsukey
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*EXIT   '  and
     C                             $prtn <> '*CANCEL '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for F8 - Display license plate info.
     *
     C                   if        *inkh
     C                   call      'LP120CL'
     C                   goto      cmd01e
     C                   endif
700aA*
700aA*  Test for F9 - Change view  (*86 to change view)
700aA*
700aAC                   if        *inki
700aAC                   if        *in86 = '1'
700aAC                   eval      *in86 = '0'
700aAC                   else
700aAC                   eval      *in86 = '1'
700aAC                   endif
700aAC                   eval      pagcmd = '*REFRESH'
700aAC                   exsr      pag01
700aAC                   goto      cmd01e
700aAC                   endif
     *
     *  Test for F10 - Mmove record that cursor is on to top.
     *
     C                   if        *inkj
     C                   move      *zeros        row#
     C                   eval      row = rowin
     C                   move      *zeros        col#
     C                   eval      col = colin
     *
     *     Make sure cursor is on one of the displayed record.
     *
     C                   select
     C                   when      #lline = '16'
     C                   sub       10            row#
     C                   other
     C                   sub       3             row#
     C                   endsl
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     Reposition record that cursor is on to the top.
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for F17 - Reposition to Top of Display
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for F18 - Reposition to Bottom of Display.
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     *
     C     cmd01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  Test for F12 - Cancel
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     *
     C     cmd02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  CMD03    Screen 3 command key routine
     *
     C     cmd03         begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F3 - Exit
     *
     C                   select
     C                   when      *inkc
     C                   eval      cmdtkn = *on
     C                   eval      cancel = *on
     C                   exsr      clrsch
     C                   exsr      scr03e
     *
     *  Test for F12 - Cancel
     *
     C                   when      *inkl
     C                   eval      cmdtkn = *on
     C                   eval      cancel = *on
     C                   exsr      clrsch
     C                   exsr      scr03e
     *
     *  Test for F5 - Refresh
     *
     C                   when      *inke
     C                   eval      cmdtkn = *on
     C                   exsr      scr03i
     *
     C                   endsl
     *
     C     cmd03e        endsr
     *
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     dspsflsp
     C                   other
     C                   write     dspsfl
     C                   write     dspsfl1
     C                   endsl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              write     d16sfc
     C   86              write     d16sfc1
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              write     dspsfc
     C   86              write     dspsfc1
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr

      /free
         if not prime;
      /end-free

     *
     *  Verify and save options
     *
     C                   exsr      savopt
     *
     *    User tried to select more than one slot for RF Select.
     *    Do not allow user to continue. 1=Select allowed on one
     *    slot only.
     C                   if        optcnt > 1
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(4)
     C                   other
     C                   eval      errmsg = desc(4)
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     C     error         cabeq     *on           ent01e
     *
     *  See if user is trying to position to a certain spot
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif

      /free
         endif;
      /end-free

     *
     *  Check if slot was entered.
     *
     C                   if        w1disp <> *blanks
     C                   exsr      zzchk1
     C     error         cabeq     *on           ent01e
     C     redspl        cabeq     *on           ent01e
     *
     C                   eval      $puky = dsukey
     *
     c                   eval      $newsl = w1disp
     c                   eval      $actualslot = 'N'
     c                   eval      $rtncd = '*OK'
     C                   eval      nxtscr = 'EOJ'
     C                   goto      ent01e
     C                   endif

     C                   if        w1lcns <> *blanks
     C                   exsr      zzchk1L
     C     error         cabeq     *on           ent01e
     C     redspl        cabeq     *on           ent01e
     *
     C                   eval      $puky = dsukey
     *
     c*                  eval      $newsl = w1disp
     c                   eval      $actualslot = 'Y'
     c                   eval      $rtncd = '*OK'
     C                   eval      nxtscr = 'EOJ'
     C                   goto      ent01e
     C                   endif

      /free
         if not prime;
      /end-free

     *
     *  If not positioning then execute the entered options.
     *
     C                   exsr      optns

      /free
         endif;
      /end-free

     *
     *  If option was not taken, then return like F12-Cancel was entered.
     *
     c                   eval      $newsl = $pdisp
     c                   eval      $actualslot = 'Y'
     c                   eval      $rtncd = '*OK'
     c                   MOVE      'EOJ'         nxtscr
     C     ent01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = *off
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ENT03    Screen 3 enter key routine
     *
     C     ent03         begsr
     *
     *
     C     ent03e        endsr
     *
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
700aAC                   exsr      zzkeyi
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   move      $prtky        $puky
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     Do All Deletes First (Option 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  Then do the Other Options in the order they were entered.
     *     Stop when no more options or user presses F12=Cancel
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = *on  or
     C                             cancel = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = *off
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = *on
     C                   eval      stop = *on
     C                   if        error = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = *on
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     C                   select
     *
     *   Select slot for RF Select.
     *
     C                   when      wkoopt = ' 1'
     C                   eval      dsukey = $puky
     *
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
750fA /free
750fA   // For Prime, we will be creating a JSON array
750fA   // Therefore, we start the array here and end
750fA   // it at the end of the this subroutine.
750fA
750fA      yajl_genOpen(*off);
750fA      yajl_beginObj();
750fA        yajl_beginArray('list');
750fA /end-free
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = *zeros
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
750fA /free
750fA   // For Prime, wrap up the JSON array.
750fA
750fA        yajl_endArray();
750fA      yajl_endObj();
750fA
750fA   // The array will look like the following:
750fA   //    {"list":[{"key":"val", "key":"val"},{"key":"val", "key":"val"},... ]}
750fA   // However, $SetNxtScr only needs the following:
750fA   //    [{"key":"val", "key":"val"},{"key":"val", "key":"val"},... ]
750fA   // Therefore, we remove the excess characters
750fA
750fA      yajlLen = YAJL_copyBuf(0: bufArrayPtr: %len(bufArray): bufArrayLen);
750fA      bufArray = %subst(bufArray: 9: bufArrayLen-9);
750fA      bufArrayLen = %len(%trim(bufArray));
750fA
750fA   // Do some YAJL cleanup
750fA
750fA      yajl_genClose();
750fA /end-free
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  If we are at the bottom then do nothing.
     *
     C     bot           cabeq     *on           endf
     *
     *  Initialize variables for lookup.
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      offlag = *off
     C                   eval      p = *zeros
     *
     *  Get x Number of records to display.
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  Out of records - Inform user and set flag.
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     *
     *    Display is empty. Force flag on in case user pages back.
     C                   if        oplmts = 'Y'  and
     C                             offlag = *off
     C                   eval      offlag = *on
     C                   endif
     *
     C                   goto      endfwd
     C                   endif
     *
     *  Record read - Stop after number of good records read.
     *
     C                   add       1             p
     C                   exsr      sfladd
     *
     *    Display is configured to display 1 overflow slot at a time.
     *
     C                   if        oplmts = 'Y'  and
     C                             slpick = 'N'  and
     C                             offlag = *off
     C                   eval      offlag = *on
     C                   eval      stop = *on
     C                   eval      moreln = 'More...'
     C                   goto      endfwd
     C                   endif
     *
     C                   if        p >= 3  and
     C                             #lline <> '16'  or
     C                             p >= 10  and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif

750fA /free
750fA
750fA    // For Prime, read all records, create list to send back.
750fA
750fA    if prime;
750fA      stop = *off;
750fA    endif;
750fA
750fA /end-free

     C     endfwd        tag
     C                   enddo
     *
     *  Save number of records that have been displayed.
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off

     *
     C     endf          endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  If we are at the top then do nothing.
     *
     C     top           cabeq     *on           endb
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards.
     *
     C                   select
     *
     *    Display is limited to one overflow location at a time.
     C                   when      offlag = *on
     C     dsplyd        add       1             goback
     *
     C                   when      #lline = '16'
     C     dsplyd        add       10            goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     C                   if        bot = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             goback = 10  or
     C                             #lline <> '16'  and
     C                             goback = 3
     C                   eval      forceb = *on
     C                   endsl
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup.
     *
     C                   eval      p = *zeros
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file.
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  Hit top of file.
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  Record read - Stop after reading 'GoBack' number of good records.
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * If the top was reached then position pointer to top of file.
     *
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     *
     C     endb          endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  If we are at the Bottom then do nothing
     *
     C     bot           cabeq     *on           endf2
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = *zeros
     *
     *  Get x number of records to display
     *
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  Record read - Stop after x good records read.
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 3  and
     C                             #lline <> '16'  or
     C                             p >= 10  and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  Save number of records that have been displayed.
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     *
     C     endf2         endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     *on           endb2
     C                   eval      forceb = *off
     *
     *  Caclulate how many records to go backwards
     *
     C                   select
     C                   when      #lline = '16'
     C     dsplyd        add       10            goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     *
     C                   if        bot = *on
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = *zeros
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read Specified flitches file
     *
     C                   dou       stop = *on
     C     wkoprt        readpe    workopt                                79
     *
     *  Hit Top of File
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = *on
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     *
     C     endb2         endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG3FW   Let's see that next page of records
     *
     C     pag3fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     *on           endf3
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = *zeros
     *
     *  Get next x records to display.
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw3
     C                   endif
     *
     *  Record read - Stop after x good records read.
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 3  and
     C                             #lline <> '16'  or
     C                             p >= 10  and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfw3        tag
     C                   enddo
     *
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     *
     C     endf3         endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG3BK   Let's see the previous page of records
     *
     C     pag3bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     *on           endb3
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   select
     C                   when      #lline = '16'
     C     dsplyd        add       10            dsplyd
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     *
     C                   if        bot = *on
     C                   if        goback = 3  and
     C                             #lline <> '16'  or
     C                             p = 10  and
     C                             #lline = '16'
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = *zeros
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  Hit Top of File
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk3
     C                   endif
     *
     *  Record read - Stop after reading 'GoBack' number of records read.
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk3        tag
     C                   enddo
     *
     * If the top was reached then position pointer to Top of File
     *
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag3fw
     *
     C     endb3         endsr
     *
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  Test for Rollup
     *
     C                   select
     C                   when      status = rollup
     C                   exsr      savopt
     *
     *    User tried to select more than one slot for RF Select.
     *    Do not allow user to continue. 1=Select allowed on one
     *    slot only.
     C                   if        optcnt > 1  and
     C                             error = *off
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(4)
     C                   other
     C                   eval      errmsg = desc(4)
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     C     error         cabeq     *on           rol01e
     *
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     *
     *  Test for RollDown
     *
     C                   when      status = rolldn
     C                   exsr      savopt
     *
     *    User tried to select more than one slot for RF Select.
     *    Do not allow user to continue. 1=Select allowed on one
     *    slot only.
     C                   if        optcnt > 1  and
     C                             error = *off
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(4)
     C                   other
     C                   eval      errmsg = desc(4)
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     C     error         cabeq     *on           rol01e
     *
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     *
     C                   endsl
     *
     C     rol01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  Test for RollUp
     *
     C                   select
     C                   when      status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     *
     *  Test for RollDown
     *
     C                   when      status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     *
     C                   endsl
     *
     C     rol02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  Read only the Changed Options
     *
     C                   eval      nomore = *off
750fAC                   if        not usingScreen
750fAC                   leavesr
750fAC                   endif
     C                   dou       nomore = *on
     C                   eval      *in85 = *off
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   readc     d16sflsp                               79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              readc     d16sfl                                 79
     C   86              readc     d16sfl1                                79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   readc     dspsflsp                               79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              readc     dspsfl                                 79
     C   86              readc     dspsfl1                                79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display Error if option is not valid
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found.
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
     C                   endif
     *
     *  Save Option
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     *
     *    User removed selection from slot. Reduce option count.
     *    Select option only allowed on one slot.
     C                   if        wkoopt = ' 1'
     C                   eval      optcnt = optcnt - 1
     C                   if        optcnt < 0
     C                   eval      optcnt = *zeros
     C                   endif
     C                   endif
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     *
     *    Force SFLNXTCHG flag for select entries. This forces
     *    OPTCNT to be checked everytime.  Ensures only 1 slot selected.
     C                   if        option = ' 1'
     C                   eval      *in85 = *on
     C                   endif
     C                   move      *in85         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     *
     *    1=Select option allowed on one slot only.
     C                   if        option = ' 1'
     C                   add       1             optcnt
     C                   if        optcnt > 1
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(4)
     C                   other
     C                   eval      errmsg = desc(4)
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     *    Force SFLNXTCHG to be on each time.
     C                   eval      *in85 = *on
     C                   endif
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in85         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
750fDC**                 if        recno < 10
750fMC                   if        recno < 10 or prime
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
750fAC                   if        usingScreen
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
750fAC                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              write     d16sfl
     C   86              write     d16sfl1
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              write     dspsfl
     C   86              write     dspsfl1
     C                   endsl
750fAC                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              write     d16sfc
     C   86              write     d16sfc1
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              write     dspsfc
     C   86              write     dspsfc1
     C                   endsl
750fAC                   endif
     C                   eval      recno = *zeros
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'
     C                   write     cmdrec16
     C                   other
     C                   write     cmdrec
     C                   endsl
750fAC                   endif
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     *R                   WRITEMORREC
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
750fAC                   if        usingScreen
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     postnrsp
     C                   other
     C                   write     postnrec
     C                   endsl
750fAC                   endif
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     1             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N861             chain     d16sfl                             79
     C   861             chain     d16sfl1                            79
     **                   OTHER
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     1             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N861             chain     dspsfl                             79
     C   861             chain     dspsfl1                            79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              update    d16sfl
     C   86              update    d16sfl1
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              update    dspsfl
     C   86              update    dspsfl1
     C                   endsl
     C                   endif
     C                   endif
750fAC                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              write     d16sfc
     C   86              write     d16sfc1
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              write     dspsfc
     C   86              write     dspsfc1
     C                   endsl
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     scanresp
     C                   other
     C                   write     scanrec
     C                   endsl
750fAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
750fAC                   if        usingScreen
750fAC                   leavesr
750fAC                   endif
     C     1             do        dsplyd        x
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86x             chain     d16sfl                             79
     C   86x             chain     d16sfl1                            79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86x             chain     dspsfl                             79
     C   86x             chain     dspsfl1                            79
     C                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in85 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   eval      *in85 = *off
     C                   endif
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              update    d16sfl
     C   86              update    d16sfl1
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              update    dspsfl
     C   86              update    dspsfl1
     C                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'
     C                   write     msgctl16
     C                   other
     C                   write     msgctl
     C                   endsl
750fAC                   endif
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'
     C                   write     msgclr16
     C                   other
     C                   write     msgclr
     C                   endsl
750fAC                   endif
     C                   eval      *in97 = *on
     C                   if        msgk > 0
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'
     C                   write     msgctl16
     C                   other
     C                   write     msgctl
     C                   endsl
750fAC                   endif
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
750fAC                   select
750fAC                   when      usingScreen
     C                   select
     C                   when      #lline = '16'
     C                   write     msgrec16
     C                   other
     C                   write     msgrec
     C                   endsl
750fAC                   other
750fAC                   call      'GETMSG2'
750fAC                   parm                    #msgk
750fAC                   parm                    #pgmq
750fAC                   parm                    #msgtext
750fAC                   eval      errmsg = #msgtext
750fAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
750fAC                   if        usingScreen
     C                   select
     C                   when      #lline = '16'
     C                   write     msgrec16
     C                   other
     C                   write     msgrec
     C                   endsl
750fAC                   endif
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
750fAC                   if        usingScreen
     C                   write     clrall
750fAC                   endif
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *----------------------------------------------------------------
     *      0105s
     *
     C     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1disp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT27101  SLOT
     *
     C     zm7101        begsr
     C                   eval      #msgid = 'IT27101'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM0110   Quantity must be greater than 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = descsp(1)
     C                   other
     C                   eval      errmsg = desc(1)
     C                   endsl
     C                   movea     errmsg        $md(1)
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
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      rtvslt = '*NO '
     *
     C                   eval      noslt = *off
     *
     *  SLOT not entered.
     *
     C                   if        w1disp = *blanks
     C                   eval      noslt = *on
     C                   eval      woslt = *blanks
     C                   goto      endck1
     C                   endif
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w1disp
     C                   parm      1             worow
     C                   parm      27            wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck1
     C                   endif
     *
     C                   select
     *    Check only date sensitive items.
     C                   when      itflgd = 'Y'  and
     C                             option = ' 1'  or
     *
     C                             itflgd = 'Y'  and
     C                             option = '  '
     *
     C                   eval      rtvslt = '*YES'
     C                   eval      kydisp = w1disp
     C     slfiky        chain(n)  slot2                              79
     C                   if        *in79
     C                   eval      slexpd = *zeros
     C                   endif
     *
     C                   eval      svexpd = slexpd
     *
     *    Retrieve current date in yyyymmdd format.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      tstdte = $cvd8o
     *
     *    Check slot selected for expired product.
     C                   endsl
     *
     C                   select
     *    Check only date sensitive items.
     *      Check slot to see if taken out of FIFO date rotation.
     C                   when      itflgd = 'Y'  and
     C                             option = ' 1'  and
     C                             oprpfi = '3'  and
     C                             error = *off  or
     *
     C                             itflgd = 'Y'  and
     C                             option = '  '  and
     C                             oprpfi = '3'  and
     C                             error = *off
     *
     C                   eval      kydisp = w1disp
     C                   select
     C                   when      dspwin = '*YES'
     C                   eval      msgtyp = '*FIFO   '
     C                   exsr      zzwarn
     C                   if        error = *on
     C                   goto      endck1
     C                   endif
     *
     C                   endsl
     *
     C                   endsl
     *
     *    Get slot record.
     *

     *
     C     endck1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK1L  Screen 1 error checking for license scan
     *
     C     zzchk1L       begsr
     C                   eval      error = *off
     C                   eval      rtvslt = '*NO '
     *
     C                   eval      noslt = *off
     *
     *  LICENSE not entered.
     *
     C                   if        w1lcns = *blanks
     C                   eval      noslt = *on
     C                   eval      woslt = *blanks
     C                   goto      endck1l
     C                   endif
     *
     *  Get slot for license scanned
     *
     c                   exsr      zzlicense
     *
     C     endck1l       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      *in23 = *off
     C                   eval      *in03 = *off
     *
     *  Quantity can not be greater than available.
     *
     C                   if        w3bqty > woavl1
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0110
     C                   endif
     *
     *  Quantity can not be greater than RF Select qty.
     *
     C                   if        w3bqty > $blkq
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(3)     errmsg
     C                   other
     C                   movel     desc(3)       errmsg
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     *
     *  Quantity can not be less than 0.
     *
     C                   if        w3bqty < 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   move      'XXXXX'       errmsg
     C                   exsr      zm0110
     C                   endif
     *
     *  Quantity is less than original RF Select qty.
     *
     C                   if        w3bqty < $blkq  and
     C                             w3bqty > 0
     *
     C                   eval      msgtyp = '*BLKQTY1'
     C                   exsr      zzwarn
     C                   if        error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   goto      endck3
     C                   endif
     C                   endif
     *
     C     endck3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *R         FILUKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain     recordu                            79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
     C     *in79         cabeq     *on           endgtn
     C                   if        slstat = 'Z '  and
     C                             slrsrv <> 'Y'
     C                   goto      try1
     C                   endif
     C                   if        sldesg = 'BFC'
     C                   goto      try1
     C                   endif
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe    record                                 79
     C                   if        *in79
     C                   eval      offlag = *off
     C     *in79         cabeq     *on           endgtp
     C                   endif
     *
     C                   if        slstat = 'Z '  and
     C                             slrsrv <> 'Y'
     C                   goto      try2
     C                   endif
     *
     C     endgtp        endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Change priority from negative to positive.
     *
     C                   eval      w1prty = -(slprty)
     *
     *   Expiration date
     *
     C                   eval      svexpd = slexpd
     C                   if        slexpd = 0
     C                   eval      w1expd = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
     C                   endif
     *
     *   Entered date
     *
     C                   if        slentd = 0
     C                   eval      w1entd = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slentd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entd = $cvd6o
     C                   endif
     *
     *    Create a quantity string to print.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1qty = $pqstr
     c                   exsr      zzlicense
*
750fA /free
750fA
750fA    // For Prime, add to JSON array
750fA
750fA    if prime and sldisp <> '';
750fA      yajl_beginObj();
750fA        yajl_addChar('sldisp': %trim(sldisp));
750fA        yajl_addChar('w1qty': %trim(w1qty));
750fA        yajl_addChar('slstat': %trim(slstat));
750fA        yajl_addChar('slpick': %trim(slpick));
750fA        if slexpd = 0;
750fA          yajl_addChar('w1expd': '');
750fA      else;
750fA          yajl_addChar('w1expd': %trim(%char(%date(slexpd:*iso):*mdy/)));
750fA        endif;
750fA        if slentd = 0;
750fA          yajl_addChar('w1entd': '');
750fA      else;
750fA          yajl_addChar('w1entd': %trim(%char(%date(slentd:*iso):*mdy/)));
750fA        endif;
750fA        yajl_addChar('slprty': %char(slprty));
750fA        yajl_addChar('lalcns': %trim(lalcns));
750fA      yajl_endObj();
750fA    endif;
750fA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
     C                   eval      cmdtkn = *off
     C*                  eval      curtrn = *zeros
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   eval      msgtyp = *blanks
     C                   eval      rtvslt = '*NO '
     C                   eval      undobk = '*YES'
     C*                  move      *loval        savtrn
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukwhdp
     C                   kfld                    ukdisp
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   kfld                    slstat
     C                   kfld                    slpick
     C                   kfld                    slprty
     C                   kfld                    slexpd
     C                   kfld                    slentd
     C                   kfld                    slwhdp
     C                   kfld                    slstyp
     C                   kfld                    slaisl
     C                   kfld                    slpseq
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $whse
     C                   kfld                    $pitem
     *
     *  Define key for ITMEXCP file.
     *
     C     exkey         klist
     C                   kfld                    exwhse
     C                   kfld                    exwhdp
     C                   kfld                    exstyp
     C                   kfld                    exitem
     C                   kfld                    exgdte
     C                   kfld                    exgtim
     *
     *  Define key for item file.
     *
     C     itkey         klist
     C                   kfld                    $whse
     C                   kfld                    $pitem
     *
     *  Define key for SLOT file.
     *
     C     slkey         klist
     C                   kfld                    $whse
     C                   kfld                    itwhdp
     C                   kfld                    w1disp
     *
     *  Define key for SLOT2 file. (Original Bulk slot)
     *
     C     slokey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $whdp
     C                   kfld                    $disp
     *
     *  Define key for SLOT2 file. (New Bulk slot)
     *
     C     slfkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $whdp
     C                   kfld                    w1disp
     *
     *  Define key for SLOT2 file.
     *
     C     slvkey        klist
     C                   kfld                    $whse
     C                   kfld                    itwhdp
     C                   kfld                    vsdisp
     *
     *  Define key for SLOT2 file.
     C     slfiky        klist
     C                   kfld                    $whse
     C                   kfld                    itwhdp
     C                   kfld                    kydisp
     *
     *  Define key for SLOT3 file.
     C     slky3a        klist
     C                   kfld                    $whse
     C                   kfld                    $pitem
     C                   kfld                    keysta
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     *
     C     slky3b        klist
     C                   kfld                    $whse
     C                   kfld                    $pitem
     C                   kfld                    keysta
     C                   kfld                    kypick
     *
     C     uskey         klist
     C                   kfld                    #user
     *
     C     uskey         chain     piruser                            79
     C                   if        not *in79
     C                   eval      w1emp# = usemp#
     C                   eval      w1styp = usstyp
     C                   eval      w1shft = usshft
     C                   eval      w1crew = uscrew
     C                   else
     C                   eval      w1emp# = *zeros
     C                   eval      w1styp = *blanks
     C                   eval      w1shft = *blanks
     C                   eval      w1crew = *blanks
     C                   endif
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    $whse
     C                   kfld                    kycode
     *
     *  Setup option and command display lines.
     *
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      optln1 = optlsp(1)
     C                   eval      cmdln1 = cmdlsp(1)
     C                   other
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     C                   endsl
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     *
     *   Get employee options.
     *
     C                   call      'GETUSER'
     C                   parm      #user         e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        e$rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     *   Get screen size being used.
     *
750fAC                   if        usingScreen
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
750fAC                   endif
     *
     C                   eval      recno = 1
     *
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sflsp                             79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C  N86              write     d16sfl                               79
     C   86              write     d16sfl1                              79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsflsp                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C  N86              write     dspsfl                               79
     C   86              write     dspsfl1                              79
     C                   endsl
     *
     *   Get replenishment options from file.
     *
     C                   eval      kycode = '*REPLEN '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      oprpex = '3'
     C                   eval      oprpfi = '3'
     C                   eval      oplmts = 'N'
     C                   endif
     *
     C                   eval      dspwin = '*NO '
     C                   eval      offlag = *off
     *
     *   Get item description.
     *
     C                   eval      w1item = *blanks
     C     $pitem        cat       '-':1         w1item
     C     itkey         chain     piritem                            79
     C                   select
     C                   when      not *in79
     C     w1item        cat       itdesc:1      w1item
     *
     C                   endsl
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      today = $cvd8o
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *
     *----------------------------------------------------------------
     *
     *  ZZCVDT  Convert date to proper format.
     *
     C     zzcvdt        begsr
     *
     *    Convert date into proper format.
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C     endcvd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record.
     C                   eval      exwhse = $whse
     C                   eval      exwhdp = slwhdp
     C                   eval      exstyp = slstyp
     C                   eval      exitem = $pitem
     C                   eval      exfdis = sldisp
     C                   eval      extdis = *blanks
     *
     C                   if        slstk1 > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   z-add     slstk1        exqty
     C                   endif
     *
     C                   eval      extask = $task
     *    Get todays date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      exgdte = $cvd8o
     C                   time                    exgtim
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C     exkey         setll     itmexcp                                79
     *
     *    Loop to generate unique timestamp for item exception.
     C                   dow       *in79
     C                   add       1             exgtim
     C     exkey         setll     itmexcp                                79
     C                   enddo
     *
     C                   write     exrec
     *
     C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZEXSL Write slot exception record to file.
     *
     C     zzexsl        begsr
     *
     *    Write a slot exception record. This will prevent slot
     *    from being selected for another letdown transaction.
     *
     C                   eval      sewhse = $whse
     C                   eval      sewhdp = slwhdp
     C                   eval      sedisp = sldisp
     C                   eval      seitem = $pitem
     *    Get todays date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      seadte = $cvd8o
     C                   time                    seatim
     C                   eval      seaby = #user
     C                   write     serec                                76
     *
     C     endse         endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
     C                   clear                   slwhse
     C                   clear                   slitem
     C                   clear                   slstat
     C                   clear                   slpick
     C                   clear                   slprty
     C                   clear                   slexpd
     C                   clear                   slentd
     C                   clear                   slwhdp
     C                   clear                   slstyp
     C                   clear                   slaisl
     C                   clear                   slpseq
     C                   clear                   slrlvl
     C                   clear                   slhand
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhdp
     C                   clear                   ukdisp
     C                   clear                   ukitem
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = slwhse
     C                   eval      ukwhdp = slwhdp
     C                   eval      ukdisp = sldisp
     C                   eval      ukitem = slitem
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     *R         PTINP1    IFNE 0
     *R                   Z-ADDPTINP1    ODDLIN
     *R                   MOVE *ZEROS    PTINP1
     *R                   MOVE *ON       REPOS
     *R                   ENDIF
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   ENDIF
     *R                   ENDIF
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     *
     C                   endsr

     *
     *----------------------------------------------------------------
     *
     *  ZZLICENSE   USE DRILICENSE for license
     *
     C     zzlicense     begsr
     C                   eval      error = *off
     *  Use DRI interface to get license information.

700aAc                   eval      lalcns = *blanks
     C                   exsr      clr$license
     c                   if        w1lcns <> ' '
     C                   eval      $liTolcnsU = *on
     C                   eval      $liTolcns = w1lcns
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop

     C                   if        error = *on
     c                             or $drireturn <> '*OK'
     c                             or $liTodisp = '*NONE'
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endlic
     C                   endif

     c                   eval      $newsl = $litodisp
     c                   else
     C                   eval      $liToWhdpU = *on
     C                   eval      $liToWhdp = slwhdp
     C                   eval      $liToDispU = *on
     C                   eval      $liToDisp = sldisp
     C                   eval      $liToDispU = *on
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETSLTLIC'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop

     C                   if        error = *on
     c                             or $drireturn <> '*OK'
     c                             or $liToLcns = '*NONE'
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endlic
     C                   endif

     c                   eval      lalcns = $litolcns
     c                   endif
     C     endlic        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZVSLT   Check if replenish is from a virtual slot.
     *
     C     zzvslt        begsr
     *
     *  Try to find virtual slot for physical slot scanned.
     *
     C                   eval      fvslot = *off
     C     slkey         setll     vslot2
     C     nxtvs         tag
     C     slkey         reade     vslot2                                 78
     C     *in78         cabeq     *on           endvsl
     C     slvkey        chain     slot2                              79
     C     *in79         cabeq     *on           nxtvs
     C*    slitem        cabne     $item         nxtvs
     C     slitem        cabne     $pitem        nxtvs
     C                   eval      fvslot = *on
     C                   eval      w1disp = sldisp
     *
     C     endvsl        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWARN   Display Error Message if slot has date/FIFO issues.
     *
     C     zzwarn        begsr
     C                   eval      wotxt1 = *blanks
     C                   eval      wotxt2 = *blanks
     C                   eval      wotxt3 = *blanks
     C                   eval      wotxt4 = *blanks
     *
     *    Load warning message into window text fields.
     C                   select
     C                   when      msgtyp = '*EXPIRED'
     *
     C                   eval      wkexpd = slexpd
     C                   select
     *    User not allowed to select expired product.
     C                   when      oprpex = '2'
     *    Reply to message not allowed. (40=Off)
     C                   eval      *in40 = *off
     C                   movel     msg101        wotxt1
     C                   movel     msg102        wotxt2
     C     msg103        cat       wkmm:1        wotxt3
     C     wotxt3        cat       '/':0         wotxt3
     C     wotxt3        cat       wkdd:0        wotxt3
     C     wotxt3        cat       '/':0         wotxt3
     C     wotxt3        cat       wkyy:0        wotxt3
     C     wotxt3        cat       '.':0         wotxt3
     C                   movel     msg104        wotxt4
     *
     *    User must be warned when selecting expired product.
     C                   when      oprpex = '3'
     *    Reply to message allowed. (40=On)
     C                   eval      *in40 = *on
     C                   movel     msg201        wotxt2
     C     msg202        cat       wkmm:1        wotxt3
     C     wotxt3        cat       '/':0         wotxt3
     C     wotxt3        cat       wkdd:0        wotxt3
     C     wotxt3        cat       '/':0         wotxt3
     C     wotxt3        cat       wkyy:0        wotxt3
     C     wotxt3        cat       '.':0         wotxt3
     *
     C                   endsl
     *
     C                   when      msgtyp = '*FIFO   '
     *
     C                   select
     *
     *   User must be warned when selecting product out of FIFO rotation.
     C                   when      oprpfi = '3'
     *    Reply to message allowed. (40=On)
     C                   eval      *in40 = *on
     C                   movel     msg301        wotxt2
     C                   movel     msg302        wotxt3
     *
     C                   endsl
     *
     C                   when      msgtyp = '*BLKQTY1'
     *
     *   User must be warned when RF Select qty different from
     *   original bulk pick qty.
     *    Reply to message allowed. (40=On)
     C                   eval      *in40 = *on
     C                   movel     msg401        wotxt1
     C                   movel     msg402        wotxt2
     C                   movel     msg403        wotxt3
     C                   movel     $blkq         wotxt4
     *
     C                   endsl
     *
     *    Display warning message to user.
     *
     C                   eval      woyes = 'N'
     C                   dow       forevr = forevr
     C                   exfmt     wdwmsg
     C                   select
     *    F3/F12 selected - Cancel selection.
     C                   when      *inkc  or
     C                             *inkl
     C                   eval      w1disp = *blanks
650bAC                   eval      w1lcns = *blanks
     C                   eval      error = *on
     C                   leave
     *
     *    Reply to warning is active.
     C                   when      *in40
     *
     C                   select
     *    User chose to continue and override warning. Log exception.
     C                   when      woyes = 'Y'
     C                   select
     C                   when      msgtyp = '*EXPIRED'
     C                   eval      exerid = 'SLTEXPD'
     C                   when      msgtyp = '*FIFO   '
     C                   eval      exerid = 'FIFOROT'
     C                   endsl
     *
     *    Write out exception record.
     C                   select
     C                   when      msgtyp = '*EXPIRED'  or
     C                             msgtyp = '*FIFO   '
     C                   exsr      zzexcp
     C                   endsl
     *
     *    User chose to NOT to continue. Return to display.
     C                   when      woyes = 'N'
     C                   eval      error = *on
     C                   select
     C                   when      msgtyp = '*EXPIRED'  or
     C                             msgtyp = '*FIFO   '
     C                   eval      w1disp = *blanks
650bAC                   eval      w1lcns = *blanks
     C                   endsl
     C                   endsl
     *
     C                   leave
     *
     C                   endsl
     C                   enddo
     *
     C     endwrn        endsr
     *----------------------------------------------------------------
     *  ZZZCALL$LT210  -  Call LT210 program.
     *----------------------------------------------------------------

     C     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'TFR'         $ttype
     C                   parm      'Transfer'    $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      w1emp#        $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
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

     *----------------------------------------------------------------
     *  ZZZCLR$LT210  -  Clear LT210 parameters.
     *----------------------------------------------------------------

     C     ZZZCLR$LT210  begsr

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
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
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

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
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

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  CreateRtnError    Create return JSON error string
     *----------------------------------------------------------------

     p CreateRtnError  b
     d CreateRtnError  pi

      /free


         yajl_genOpen(*Off);

           yajl_beginObj();

             // Grab Std section that was sent in and added it

             yajl_addPreformattedPtr('Std': stdPointer: stdLen);

             // Add Output section

             yajl_beginObj('Output');
               yajl_addchar('errmsg': errmsg500);
               yajl_addchar('spoken': errmsg500);
             yajl_endObj();

         yajl_endObj();

           pJsonStr = YAJL_copyBufStr();

         yajl_genClose();

DAM      slgbuf = '<Error> ' + pjsonstr;
DAM      WriteVoiceLog('Err': slgbuf);


      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  $InzFuncKeys   Initialize function keys for SelectPrime
750fA*----------------------------------------------------------------
750fA
750fAp $InzFuncKeys    b
     d $InzFuncKeys    pi

      /free

         *inka = *off;
         *inkb = *off;
         *inkc = *off;
         *inkd = *off;
         *inke = *off;
         *inkf = *off;
         *inkg = *off;
         *inkh = *off;
         *inki = *off;
         *inkj = *off;
         *inkk = *off;
         *inkl = *off;
         *inkm = *off;
         *inkn = *off;
         *inkp = *off;
         *inkq = *off;
         *inkr = *off;
         *inks = *off;
         *inkt = *off;
         *inku = *off;
         *inkv = *off;
         *inkw = *off;
         *inkx = *off;
         *inky = *off;

         // Ignore incoming function keys when requesting a list
         // Reason: The keys are actually for OR400 to call this program.

         if $cmd = '*SPLIST';
           return;
         endif;

         select;

           when spBtnClick = 'S01'
             or %subst(spF1F24Flags: 1: 1) = '1';
               *inka = *on;

           when spBtnClick = 'S02'
             or %subst(spF1F24Flags: 2: 1) = '1';
               *inkb = *on;

           when spBtnClick = 'S03'
             or %subst(spF1F24Flags: 3: 1) = '1';
               *inkc = *on;

           when spBtnClick = 'S04'
             or %subst(spF1F24Flags: 4: 1) = '1';
               *inkd = *on;

           when spBtnClick = 'S05'
             or %subst(spF1F24Flags: 5: 1) = '1';
               *inke = *on;

           when spBtnClick = 'S06'
             or %subst(spF1F24Flags: 6: 1) = '1';
               *inkf = *on;

           when spBtnClick = 'S07'
             or %subst(spF1F24Flags: 7: 1) = '1';
               *inkg = *on;

           when spBtnClick = 'S08'
             or %subst(spF1F24Flags: 8: 1) = '1';
               *inkh = *on;

           when spBtnClick = 'S09'
             or %subst(spF1F24Flags: 9: 1) = '1';
               *inki = *on;

           when spBtnClick = 'S10'
             or %subst(spF1F24Flags: 10: 1) = '1';
               *inkj = *on;

           when spBtnClick = 'S11'
             or %subst(spF1F24Flags: 11: 1) = '1';
               *inkk = *on;

           when spBtnClick = 'S12'
             or %subst(spF1F24Flags: 12: 1) = '1';
               *inkl = *on;

           when spBtnClick = 'S13'
             or %subst(spF1F24Flags: 13: 1) = '1';
               *inkm = *on;

           when spBtnClick = 'S14'
             or %subst(spF1F24Flags: 14: 1) = '1';
               *inkn = *on;

           when spBtnClick = 'S15'
             or %subst(spF1F24Flags: 15: 1) = '1';
               *inkp = *on;

           when spBtnClick = 'S16'
             or %subst(spF1F24Flags: 16: 1) = '1';
               *inkq = *on;

           when spBtnClick = 'S17'
             or %subst(spF1F24Flags: 17: 1) = '1';
               *inkr = *on;

           when spBtnClick = 'S18'
             or %subst(spF1F24Flags: 18: 1) = '1';
               *inks = *on;

           when spBtnClick = 'S19'
             or %subst(spF1F24Flags: 19: 1) = '1';
               *inkt = *on;

           when spBtnClick = 'S20'
             or %subst(spF1F24Flags: 20: 1) = '1';
               *inku = *on;

           when spBtnClick = 'S21'
             or %subst(spF1F24Flags: 21: 1) = '1';
               *inkv = *on;

           when spBtnClick = 'S22'
             or %subst(spF1F24Flags: 22: 1) = '1';
               *inkw = *on;

           when spBtnClick = 'S23'
             or %subst(spF1F24Flags: 23: 1) = '1';
               *inkx = *on;

           when spBtnClick = 'S24'
             or %subst(spF1F24Flags: 24: 1) = '1';
               *inky = *on;

         endsl;

      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  $InzPgmVar     Initialize program variables for SelectPrime
750fA*----------------------------------------------------------------
750fA
750fAp $InzPgmVar      b
     d $InzPgmVar      pi

      /free

         errmsg = '';
         errmsg500 = '';

         // Extract Input fields

         jsonGetFields(inputNode);

         // Set function keys

         $InzFuncKeys();

         // Set screen fields

         nxtscr = '01 ';

      /end-free

     p                 e

750fA*****************************************************************
750fA* Set output for next screen
750fA*****************************************************************
750fAp $SetNxtScr      b
     d $SetNxtScr      pi

     d  i              s              3  0

      /free
       spF1F24Flags = '000000000000000000000000';
       spbtnFlags = '0000000000';


       // Initialize JSON buffer

       yajl_genOpen(*Off);

       // Begin main JSON object

       yajl_beginObj();         // Begin JSON string

       // Grab Std section that was sent in and added it

       yajl_addPreformattedPtr('Std': stdPointer: stdLen);

       // Begin Ouput section

       yajl_beginObj('Output');

       // Put error message at beginning

       yajl_addchar('errmsg': %trim(errmsg));

       // Now add screen output

       Select;

       When nxtscr = '01 ';
         yajl_addchar('nxtscr': 'OR401.' + %trim(nxtscr));
         yajl_addchar('w1item': %trim(w1item));
         yajlRtnStatus = yajl_addPreformattedPtr('listary':
                                                  bufArrayPtr: bufArrayLen);
750hD    //yajl_addchar('spoken': 'select task');
750hM    yajl_addchar('spoken': 'select slot');

       Endsl;

       %subst(spF1F24Flags: 3: 1) = '1';
       %subst(spF1F24Flags: 5: 1) = '1';
       %subst(spF1F24Flags: 8: 1) = '1';
       %subst(spF1F24Flags: 9: 1) = '1';
       %subst(spF1F24Flags:12: 1) = '1';

       // Add function key display
       yajl_addchar('f1f24flags': spf1f24flags);
       yajl_addchar('BtnFlags': spBtnFlags);

       yajl_endObj();                 // End Output section
       yajl_endObj();                 // End entire JSON string
       pJsonStr = YAJL_copyBufStr();  // Copy JSON string into parameter
       yajl_genClose();               // Close and cleanup JSON processing

      /END-FREE
     p                 e


750fA*----------------------------------------------------------------
750fA*  WriteVoiceLog    Write record to voice log BFCSKTLOG
750fA*----------------------------------------------------------------
750fA
750fAp WriteVoiceLog   b
     d WriteVoiceLog   pi
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

      /free

       GetCurrStamp();

       slgTyp = type;

       //slgbuf = spWhereFrom
       //       + '        '
       //       + '- ' + #pgm + %trim(buffer);
       slgbuf = %trim(buffer);

       slgts     = currstamploc;
       slgucs    = currstampuc;
       slguser   = #user;
       slgjob    = #job;
       slgjobnbr = #jobn;

       slgsk2 = 0;
       SlgIP  = #job;
       SlgPortL = 0;
       SlgPortC = 0;
       slgid  = spUid;
       write slgrec;

      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  GetCurrStamp  Get current timestamps
750fA*----------------------------------------------------------------
750fA
750fAp GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p                 e

     *----------------------------------------------------------------
     * UpperToLower   Convert uppercase to lowercase
     *----------------------------------------------------------------

     p UpperToLower    b
     d UpperToLower    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(uppercase: lowercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * SetPgmField      Set program field
     *----------------------------------------------------------------

     p SetPgmField     b
     d SetPgmField     pi
     d  key                          50A   varying const
     d  val                                like(yajl_val) const

     d lowkey          s             50A   varying

      /free

        // Force keys to lowercase to eliminate case errors

        lowkey = UpperToLower(key);

         // Move value into screen field

         monitor;

           select;

             // Standard Fields

             when lowkey = 'app';
               spApp = yajl_get_string(val);

             when lowkey = 'user';
               spUser = yajl_get_string(val);

             when lowkey = 'uid';
               spUid = yajl_get_string(val);

             when lowkey = 'wherefrom';
               spWhereFrom = yajl_get_string(val);

             when lowkey = 'whouse';
               spWhouse = yajl_get_string(val);

             // Input screen fields

             when lowkey = 'f1f24flags';
               spF1F24Flags = yajl_get_string(val);

             when lowkey = 'btnflags';
               spBtnFlags = yajl_get_string(val);

             when lowkey = 'w1disp';
               w1disp = yajl_get_string(val);

           endsl;

         on-error;

           error = *on;
           errmsg = 'Error extracting field ' + %trim(key);
           return;

         endmon;

      /end-free
     p                 e

750fA*----------------------------------------------------------------
750fA*  LoadJson   Load JSON into memory
750fA*----------------------------------------------------------------
750fA
750fAp LoadJson        b
     d LoadJson        pi

      /free

        // Load JSON string into memory and get pointer to root node/object

        docNode = yajl_string_load_tree( pJsonStr : yajlerr );
        if yajlerr <> '';
          error = *on;
          errmsg500 = 'Error loading JSON string - ' + yajlerr;
          CreateRtnError();
          return;
        endif;

        // Get pointer to Std section

        stdNode = yajl_object_find(docNode: 'Std');
        if stdNode = *null;
          error = *on;
          errmsg500 = 'Error loading Std section';
          CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;


        stdLen = YAJL_stringify(stdNode: stdPointer: %len(stdBuffer));

        // Get pointer to Input section

        inputNode = yajl_object_find(docNode: 'Input');
        if inputNode = *null;
          error = *on;
          errmsg500 = 'Error loading Input section';
          CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;

        inputLen = YAJL_stringify(inputNode: inputPointer: %len(inputBuffer));

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JSON Subprocedures
     *----------------------------------------------------------------

      /copy qcopysrc,$jsonstr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1
**  OPTLN - Option display line
  1=Select
**  CMDLN - Command display line
F3=Exit F5=Refresh F8=Lic inf F9=View F12=Cancel
**  DESC - Description
Available Quantity
Verify Zero
Qty greater than RF Select qty.
1=Select can be used only once.
Slot error logged for slot:
Pick new slot. Bulk Pick using this slot.
**  OPTLSP - Option display line
  1=Select  9=View Slot Quantities
**  CMDLSP - Command display line
F3=Exit F5=Refresh F8=Lic inf F9=View F12=Cancel
**  DESCSP - Description
Available Quantity
Verify Zero
Qty greater than RF Select qty.
1=Select can be used only once.
Slot error logged for slot:
Pick new slot. Bulk Pick using this slot.
