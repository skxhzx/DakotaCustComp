520dA /COPY *libl/qcopysrc,hspecs
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR681   RF - Select New Bulk Pick Location - Display
     *  04 October 2002
     *  Max Blacknik
     *  Created using IT276
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    10/04/02  MLB  4.16
     *      - Created.
     *
417 A*    05/02/02  MLB  4.17
     *      - Enh: Revised program to allow bulk picks to be picked
     *        from multiple locations.
417aA*    05/02/03  MLB  4.17a
     *      - Enh: Added support to allow display of overflow locations
     *        to be limited to one at a time.
417bA*    07/07/03  MLB  4.17b
     *      - Fix: Revised program to correctly update label record when
     *        same location is chosen more than once.
     *
500 A*    06/07/06  JCJ  5.00
     *      - Added Multilingual logic.
530 A*    11/11/10  RH   5.30a
     *      - Fix: Revised SFLDSP to correct "when" statements for
     *        writing subfile control record.
610 A*    11/11/10  RH   6.10
     *      - Enh: Converted to ILE
610aA*    11/11/10  RH   6.10a
     *      - ENH: Changed to call LT210 for license tracking.
     *      - Use DRISLOT to get slot info and license.
640aA*    09/14/11  JCJ  6.40a
     *      - Fix: if slot changes for a pre-pick label the pre-pick
     *        cross reference label needs to be updated with the new
     *        slot and label information.
640bA*    06/06/12  LMC  6.40b
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650bA*    02/27/14  RH   6.50b
     *      - Fix: Revised to reduce original buik pick slot by bulk
     *        pick qty from new slot.
     *        Was removing total bulk qty from original pick slot when
     *        new bulk slot was selected.
     *      - Fix: Correct available qty updated in LABEL records.
     *      - Fix: Change SAVOPT, was not checking OPTCNT correctly.
700aA*    08/24/15  RH   7.00a
     *      - Fix: Revised to not display RCV, STG, OSS or USR slots
     *        like IT276 mod 600e
700bA*    10/09/15  RH   7.00b
     *      - Fix: Count save WRKOPT to limit # of options selected to
     *        one.  Pgm loads one page of records at a time and was
     *        allowing more than one rec selected after page donw.
     *
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
     *----------------------------------------------------------------
     *  File Specs
     *
     For681fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec16:msgk)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(d16sflsp:recno)
     Fitmexcp   uf a e           k disk
     FLabel     uf a e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpiruser   if   e           k disk
     Fslot2     uf   e           k disk
     F                                     rename(slrec:recordu)
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
     Ftask      if   e           k disk
     Fvslot2    if   e           k disk
     Fworkopt   uf a e           k disk
417 D*BATCTL  O   E           K        DISK
     Fsltrpex   o    e           k disk
640aAFprexref   uf a e           k disk
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
500 AD optlsp          s             75    dim(1) ctdata perrcd(1)
500 AD cmdlsp          s             79    dim(1) ctdata perrcd(1)
500 AD descsp          s             40    dim(6) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100
     D  $whse                  1      3  0
     D  $whdp                  4      8
610aDD* $item                  9     23
610aMD  $pitem                 9     23
     D  $newsl                24     35
     D  $disp                 36     47
417 D*                                      48  540$LBL#
417 MD  $lbl#                 48     51p 0
417 D*                                      55  610$TRN#
417 MD  $trn#                 52     55p 0
417 D*                                      62  680$BAT#
417 MD  $bat#                 56     59p 0
417 D*                                      69  730$BLKQ
417 MD  $blkq                 60     62p 0
417 AD  $oblkq                63     65p 0
417 D*                                      74  79 $TASK
417 MD  $task                 66     71
417 D*                                      80  89 $PRG
417 MD  $prg                  72     81
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
610aA*----------------------------------------------------------------
610aA*  LT210 parameters
610aA*----------------------------------------------------------------

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
610aAD  $tmsgid        s              4
640aAD normPrepick     s               n
640aAD prepickLabel    s               n
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
417aA*    OPLMTS  -  Limit Specific Slot replenishment program to
417aA*               to display only one overflow location at a
417aA*               time. (Y/N)
     *
     * Data structure
     *
     D opdata          ds
     D  oprplb                 1      8
     D  opoqrp                 9      9
     D  oprpex                10     10
     D  oprpfi                11     11
417aAD  oplmts                12     12
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
     *  Bulk picking error messages(s).
     *
     D msg101          c                   const('Slot not available')
     D msg102          c                   const('for bulk picking. ')
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
     D msg403          c                   const('Bulk Pick qty of  ')
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
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS
610aA
610aA*----------------------------------------------------------------
610aA*  Data Formats
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#ITEM
610aA /COPY *libl/qcopysrc,C#SLOT
610aA /COPY *libl/qcopysrc,C#SLOTDEF
610aAD saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
610  *  Variables
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
610 AD #frombasesldsp  s                   like($sldisp)
610aAD #fromithead     s             70
610 AD #fromslwhdp     s                   like($slwhdp)
610 AD #fromslstyp     s                   like($slstyp)
610 AD #fromsldisp     s                   like($sldisp)
610 AD #fromslaisl     s                   like($slaisl)
610 AD #fromslloc      s                   like($slloc)
610 AD #fromslpseq     s                   like($slpseq)
610 AD #fromslrlvl     s                   like($slrlvl)
610 AD #fromslhand     s                   like($slhand)
610 AD #fromslrsrv     s                   like($slrsrv)
610 AD #fromslentd     s                   like($slentd)
610 AD #fromslexpd     s                   like($slexpd)
610 AD #fromslslfd     s                   like($slslfd)
610 AD #fromslactv     s                   like($slactv)
610 AD #fromslbld      s                   like($slbld)
610 AD #fromslpick     s                   like($slpick)
610 AD #fromslitem     s                   like($slitem)
610 AD #fromslsdef     s                   like($slsdef)
610 AD #fromslpos      s                   like($sdpos)
610 AD #fromslvirt     s                   like($sfvirt)
610 AD #fromslstk1     s                   like($slstk1)
610 AD #fromslstk2     s                   like($slstk2)
610 AD #fromslstk3     s                   like($slstk2)
610 AD #fromslalc1     s                   like($slalc1)
610 AD #fromslalc2     s                   like($slalc2)
610 AD #fromslalc3     s                   like($slalc3)
610 AD #fromsltfr1     s                   like($sltfr1)
610 AD #fromsltfr2     s                   like($sltfr2)
610 AD #fromsltfr3     s                   like($sltfr3)
610 AD #fromslpck1     s                   like($slpck1)
610 AD #fromslpck2     s                   like($slpck2)
610 AD #fromslpck3     s                   like($slpck3)
610 AD #fromslrcv1     s                   like($slrcv1)
610 AD #fromslrcv2     s                   like($slrcv2)
610 AD #fromslrcv3     s                   like($slrcv3)
610 AD #fromslphy1     s                   like($slphy1)
610 AD #fromslphy2     s                   like($slphy2)
610 AD #fromslphy3     s                   like($slphy3)
610 AD #fromslavl1     s                   like($slavl1)
610 AD #fromslavl2     s                   like($slavl2)
610 AD #fromslavl3     s                   like($slavl3)
610aAD #fromToLcns     s                   like($saToLcns)
610aAD #fromToPos      s                   like($saToPos)
610aAD #fromOLcns      s                   like($saOLcns)
     D bot             s              1
     D cancel          s              1
610aAD chk4err         s               n
     D ckexpd          s                   like(today)
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
610aAD curlic#         s                   like($tlic#)
     D curtrn          s                   like(pttrn#)
     D curtsk          s              6
     D curtyp          s              1
     D dsplyd          s              3  0
     D dspwin          s              4
     D e               s              3  0
     D enter           s              5  0
     D error           s              1
     D fintim          s                   like(ptetim)
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
     D kystat          s                   like(ptstat)
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
     D savtrn          s                   like(pttrn#)
     D sclear          s              1
     D stdate          s                   like(ptsdte)
     D stop            s              1
     D strtim          s                   like(ptstim)
     D sttime          s                   like(ptstim)
     D svtlen          s                   like(ptdmin)
     D svtrn#          s                   like(pttrn#)
     D t#task          s              6
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D top             s              1
     D tstdte          s                   like(today)
     D undobk          s              4
     D warn            s              1
     D woavl1          s              5  0
     D woslt           s             12
     D wotrn#          s                   like(pttrn#)
640bAD wrtpcmd         s             10
640bAD wrtpwait        s              2  0
640bAD wrtpwhse        s              3  0
640bAD wrtptran#       s                   like(pttrn#)
640bAD wrtpfrmdate     s              8  0
640bAD wrtptodate      s              8  0
640bAd wrtpemp#        s                   like(ptemp#)
     D w1crew          s                   like(uscrew)
     D w1emp#          s                   like(usemp#)
     D w1shft          s                   like(usshft)
     D w1styp          s                   like(usstyp)
     D x               s              3  0
     D y               s              3  0
610aAD zmsflag         s               n
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
640aAD preLabel        s              7  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
610aA /Copy qcopysrc,c#pgminfds
610a D**              sds
610a D**#prog            *proc
610a D**#job                 244    253
610a D**#user                254    263
610a D**#jobn                264    269
610a D**#jobdt               276    281  0
610a D**#jobtm               282    287  0
640bA*----------------------------------------------------------------
640bA*  Prototypes
640bA*----------------------------------------------------------------
640bA
640bAD wrttran1        pr                  extpgm('WRTTRAN1')
640bA * Input
640bAD   ppcmd                        8
640bAD   ppwait                       2  0
640bAD   ppwhse                       3  0
640bAD   pptran#                      7  0
640bAD   ppfromdate                   8  0
640bAD   pptodate                     8  0
640bAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $CMD    *UPDBULK - Update current bulk pick transaction.
417 M*              *CRTBLKL - Create new bulk pick label.
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $NEWSL           - New slot selected for bulk pick.
     *      $RTNCD  *OK      - New bulk pick slot selected
417 A*              *BALANCE - Bulk pick quantity still not fully picked.
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     *
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
     C                   return
     *
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
     C                   exsr      sfldsp
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   read      postnrsp                               50
500 AC                   read      scanresp                               50
500 AC                   other
     C                   read      postnrec                               50
     C                   read      scanrec                                50
500 AC                   endsl
     *
     C                   when      nxtscr = '02 '
     C                   exsr      deldsp
     *
     C                   when      nxtscr = '03 '
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 A*    Write out Window format.
500 AC                   write     wdwqtysp                             50
500 A*    Write out Data format inside window.
500 AC                   write     qtyrecsp                             50
500 AC                   read      qtyrecsp                               50
500 AC                   when      e$lng = 'EN'
     *    Write out Window format.
     C                   write     wdwqty                               50
     *    Write out Data format inside window.
     C                   write     qtyrec                               50
     C                   read      qtyrec                                 50
500 AC                   endsl
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   read      d16sfcsp                               50
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   read      d16sfc                                 50
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   read      dspsfcsp                               50
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   read      dspsfc                                 50
     C                   endsl
     C                   endsl
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
417 A*    If new transaction being processed, allow original bulk
417 A*    pick quantity to be released.
417 AC                   if        savtrn <> $trn#
417 AC                   eval      undobk = '*YES'
417 AC                   eval      savtrn = $trn#
417 AC                   endif
417 A*
     C                   eval      w1disp = *blanks
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     delrecsp
500 AC                   other
     C                   write     delrec
500 AC                   endsl
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     cmddelsp
500 AC                   other
     C                   write     cmddel
500 AC                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     *
     C                   eval      nxtscr = '03 '
     *
     C                   select
     *    Load Bulk Pick qty if not greater than available slot qty.
     C                   when      $blkq <= avail1
     C                   eval      w3bqty = $blkq
     *
     *    Available qty less than bulk, load available.
     C                   other
     C                   eval      w3bqty = avail1
     C                   endsl
417 AC                   eval      w3balq = $blkq
     C                   eval      woavl1 = avail1
     *
     *R                   MOVE '*REFRESH'PAGCMD
     *R                   EXSR PAG03
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
     C                   cas                     ent01
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
700bA*----------------------------------------------------------------
700bA*
700bA*  ChkCnt   Check option count, can't select > 1
700bA*
700bAC     chkcnt        begsr
700bAC     wkoprt        setll     workopt
700bAC     wkoprt        reade     workopt                              7979
700bAC                   if        not *in79
700bAC                   eval      optcnt = 1
700bAC                   endif
700bAC                   endsr
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
610aA*----------------------------------------------------------------
610aA*  clr$slot  Clear $slot data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$slot      begsr
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
500 AC                             e$lng = 'SP'
500 AC     x             chain     d16sflsp                           79
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC     x             chain     dspsflsp                           79
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   update    d16sflsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   update    d16sfl
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   update    dspsfl
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsflsp
500 AC                   other
     C                   write     dspsfl
500 AC                   endsl
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
500 AC                             e$lng = 'SP'
500 AC                   write     d16sfcsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   write     d16sfc
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     dspsfcsp
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  Verify and save options
     *
     C                   exsr      savopt
     *
     *    User tried to select more than one slot for bulk pick.
     *    Do not allow user to continue. 1=Select allowed on one
     *    slot only.
     C                   if        optcnt > 1
     C                   eval      error = *on
     C                   eval      *in21 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(4)
500 AC                   other
     C                   eval      errmsg = desc(4)
500 AC                   endsl
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
     *
     *  Check if slot was entered.
     *
     C                   if        w1disp <> *blanks
     C                   exsr      zzchk1
     C     error         cabeq     *on           ent01e
     C     redspl        cabeq     *on           ent01e
     *
     C                   eval      $puky = dsukey
610a * Use DRISLOT to get slot
610a C                   exsr      zzslot
610a * Pull license
610a C                   exsr      zzpull
610a C     error         cabeq     *on           ent01e
610a C     redspl        cabeq     *on           ent01e
     *
     C                   exsr      scr03i
     *
     C                   goto      ent01e
     C                   endif
     *
     *  If not positioning then execute the entered options.
     *
     C                   exsr      optns
     *
     *  If option was not taken, then return like F12-Cancel was entered.
     *
     *R         OTAKEN    IFEQ *OFF
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
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
     *  Verify and save options.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           ent03e
     *
     C                   select
     *    Process new location selected for Bulk Pick.
     C                   when      $cmd = '*UPDBULK'
     C                   exsr      zzblku
     *
417 A*    Select new location and create label record.
417 AC                   when      $cmd = '*CRTBLKL'
417 AC                   exsr      zzblkn
417 A*
     C                   endsl
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
     *   Select slot for Bulk Pick.
     *
     C                   when      wkoopt = ' 1'
     C                   eval      dsukey = $puky
     C                   exsr      zzslct
     *
     *   Change
     *
     C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @vewpg
     C                   parm                    $parms
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     *
     *   View slot quantities.
     *
     C                   when      wkoopt = ' 9'
     C                   call      'SL635'
     C                   parm                    itwhse
     C                   parm                    itwhdp
     C                   parm                    $pdisp
     *
     *    Log slot error in item exception file.
     *
     C                   when      wkoopt = ' X'
     C                   eval      kydisp = $pdisp
     C     slfiky        chain(n)  slot2                              79
     C                   if        *in79
     C                   eval      slstk1 = *zeros
     C                   endif
     *
     *    Write out exception record.
     C                   eval      exerid = 'WRGITM '
     C                   exsr      zzexcp
     *
     *    Write record to slot exception file.
     C                   if        slpick <> 'Y'
     C                   exsr      zzexsl
     C                   endif
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = %trimr(descsp(5)) + ' ' + sldisp
500 AC                   other
     C                   eval      errmsg = %trimr(desc(5)) + ' ' + sldisp
500 AC                   endsl
     C                   exsr      zm0105
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
417aAC                   eval      offlag = *off
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
417aA*
417aA*    Display is empty. Force flag on in case user pages back.
417aAC                   if        oplmts = 'Y'  and
417aAC                             offlag = *off
417aAC                   eval      offlag = *on
417aAC                   endif
417aA*
     C                   goto      endfwd
     C                   endif
     *
     *  Record read - Stop after number of good records read.
     *
     C                   add       1             p
     C                   exsr      sfladd
417aA*
417aA*    Display is configured to display 1 overflow slot at a time.
417aA*
417aAC                   if        oplmts = 'Y'  and
417aAC                             slpick = 'N'  and
417aAC                             offlag = *off
417aAC                   eval      offlag = *on
417aAC                   eval      stop = *on
417aAC                   eval      moreln = 'More...'
417aAC                   goto      endfwd
417aAC                   endif
417aA*
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
700aDC*                  select
417aA*
417aA*    Display is limited to one overflow location at a time.
700aDC*                  when      offlag = *on
700aMC                   if        offlag = *on
417aAC     dsplyd        add       1             goback
417aA*
700aAC                   else
700aAC                   select
     C                   when      #lline = '16'
     C     dsplyd        add       10            goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
700aAC                   endif
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
     *    User tried to select more than one slot for bulk pick.
     *    Do not allow user to continue. 1=Select allowed on one
     *    slot only.
     C                   if        optcnt > 1  and
     C                             error = *off
     C                   eval      error = *on
     C                   eval      *in21 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(4)
500 AC                   other
     C                   eval      errmsg = desc(4)
500 AC                   endsl
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
     *    User tried to select more than one slot for bulk pick.
     *    Do not allow user to continue. 1=Select allowed on one
     *    slot only.
     C                   if        optcnt > 1  and
     C                             error = *off
     C                   eval      error = *on
     C                   eval      *in21 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(4)
500 AC                   other
     C                   eval      errmsg = desc(4)
500 AC                   endsl
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
650bAC                   eval      optcnt = 0
     *
     *  Read only the Changed Options
     *
     C                   eval      nomore = *off
     C                   dou       nomore = *on
     C                   eval      *in85 = *off
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   readc     d16sflsp                               79
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   readc     d16sfl                                 79
500 A**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   readc     dspsflsp                               79
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   readc     dspsfl                                 79
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
650bA* Moved code to check OPTCNT here
650bA*    1=Select option allowed on one slot only.
650bAC                   if        option = ' 1'
700bDC*                  add       1             optcnt
700bMC                   exsr      chkcnt
700bMC                   if        optcnt >= 1
700bDC*                  if        optcnt > 1
650bAC                   eval      error = *on
650bAC                   eval      *in21 = *on
650bAC                   select
650bAC                   when      e$lng = 'SP'
650bAC                   eval      errmsg = descsp(4)
650bAC                   other
650bAC                   eval      errmsg = desc(4)
650bAC                   endsl
650bAC                   exsr      zm0105
650bAC                   endif
650bAC                   endif
650bA**
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
650bA* Fix OPTCNT process
650bAC**                 eval      optcnt = optcnt - 1
650bAC**                 if        optcnt < 0
650bAC**                 eval      optcnt = *zeros
650bAC**                 endif
650bA**
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
650bA* Fix OPTCNT process
650bAC**                 add       1             optcnt
650bAC**                 if        optcnt > 1
650bAC**                 eval      error = *on
650bAC**                 eval      *in21 = *on
650bAC**                 select
650bAC**                 when      e$lng = 'SP'
650bAC**                 eval      errmsg = descsp(4)
650bAC**                 other
650bAC**                 eval      errmsg = desc(4)
650bAC**                 endsl
650bAC**                 exsr      zm0105
650bAC**                 endif
650bA**
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
     C                   if        recno < 10
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     d16sflsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   write     d16sfl
500 A**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     dspsflsp
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   write     dspsfl
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     d16sfcsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   write     d16sfc
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     dspsfcsp
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl
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
     *R                   WRITEOPTREC
     C                   select
     C                   when      #lline = '16'
     C                   write     cmdrec16
     C                   other
     C                   write     cmdrec
     C                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     *R                   WRITEMORREC
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     postnrsp
500 AC                   other
     C                   write     postnrec
500 AC                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC     1             chain     d16sflsp                           79
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C     1             chain     d16sfl                             79
500 A**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC     1             chain     dspsflsp                           79
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C     1             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   update    d16sflsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   update    d16sfl
500 A**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     d16sfcsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   write     d16sfc
500 A**                   OTHER
530aDC**                 when      #lline = '16'  and
530aAC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     dspsfcsp
530aDC**                 when      #lline = '16'  and
530aAC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     scanresp
500 AC                   other
     C                   write     scanrec
500 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        dsplyd        x
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC     x             chain     d16sflsp                           79
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC     x             chain     dspsflsp                           79
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
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
500 AC                             e$lng = 'SP'
500 AC                   update    d16sflsp
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   update    d16sfl
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   update    dspsfl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     msgctl16
     C                   other
     C                   write     msgctl
     C                   endsl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   select
     C                   when      #lline = '16'
     C                   write     msgclr16
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      #lline = '16'
     C                   write     msgctl16
     C                   other
     C                   write     msgctl
     C                   endsl
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     msgrec16
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   select
     C                   when      #lline = '16'
     C                   write     msgrec16
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrall
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
610aA*----------------------------------------------------------------
    A*    DRI0001  Local system caused error
    A*----------------------------------------------------------------
    A
610aAC     zm0001        begsr
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

610aA*----------------------------------------------------------------
610aA*    DRI0001s Local system caused error (send to different program)
610aA*----------------------------------------------------------------
610aA
610aAC     zm0001s       begsr
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
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
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
610aA*----------------------------------------------------------------
610aA*      0105s
610aA*
610aAC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
610a C                   endsr
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(1)
500 AC                   other
     C                   eval      errmsg = desc(1)
500 AC                   endsl
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
     *  Same SLOT selected as slot Bulk Pick was created.
     *  Select new slot for Bulk Pick.
     *
     C                   if        w1disp = $disp
417 D*R                   MOVE *ON       ERROR
417 D*R                   MOVE *ON       *IN21
417 D*R                   MOVE *ON       *IN01
417 D*R                   MOVELDESC,6    ERRMSG    P
417 D*R                   EXSR ZM0105
417 D*R                   GOTO ENDCK1
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
     C                   select
     *    Replenishment with expired product not allowed. Display msg.
     C                   when      oprpex = '2'  and
     C                             svexpd < tstdte  and
     C                             svexpd > 0  or
     *
     *    Replenishment with expired product, warn user. Display msg.
     C                             oprpex = '3'  and
     C                             svexpd < tstdte  and
     C                             svexpd > 0
     *
     C                   eval      msgtyp = '*EXPIRED'
     C                   exsr      zzwarn
     C                   if        error = *on
     C                   goto      endck1
     C                   endif
     *
     C                   endsl
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
     C                   exsr      zzckrt
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
     C     slkey         chain(n)  slot2                              79
     *
     *      Not on file.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm04
     C                   goto      endck1
     C                   endif
     *
610aDC*                  if        slitem <> $item
610aMC                   if        slitem <> $pitem
     *     Look for a virtual slot for item.
     C                   exsr      zzvslt
     C                   if        fvslot <> *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   unlock    slot2
     C                   exsr      zm7101
     C                   endif
     C                   endif
     *
     *     Available qty must be greater than zero.
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
     C                   if        avail1 <= 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   unlock    slot2
     C                   exsr      zm0110
     C                   endif
     *
     C     endck1        endsr
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
     *  Quantity can not be greater than Bulk Pick qty.
     *
     C                   if        w3bqty > $blkq
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movel     descsp(3)     errmsg
500 AC                   other
     C                   movel     desc(3)       errmsg
500 AC                   endsl
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
     *  Quantity is less than original bulk pick qty.
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
700aDC*                  if        slstat = 'Z '  and
700aDC*                            slrsrv <> 'Y'
700aA*    Omit all non-active slots.
700aA*      and some special license tracking slots.
700aMC                   if        slstat <> 'A '
700aAC                             or %subst(sldisp:1:3) = 'RCV'
700aAC                             or %subst(sldisp:1:3) = 'STG'
700aAC                             or %subst(sldisp:1:3) = 'OSS'
700aAC                             or %subst(sldisp:1:3) = 'USR'
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
417aAC                   if        *in79
417aAC                   eval      offlag = *off
     C     *in79         cabeq     *on           endgtp
417aAC                   endif
417aA*
700aDC*                  if        slstat = 'Z '  and
700aDC*                            slrsrv <> 'Y'
700aA*    Omit all non-active slots.
700aA*      and some special license tracking slots.
700aMC                   if        slstat <> 'A '
700aAC                             or %subst(sldisp:1:3) = 'RCV'
700aAC                             or %subst(sldisp:1:3) = 'STG'
700aAC                             or %subst(sldisp:1:3) = 'OSS'
700aAC                             or %subst(sldisp:1:3) = 'USR'
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
     C                   parm                    stock1
     C                   parm                    stock2
     C                   parm                    stock3
     *
     C                   parm                    avail1
     C                   parm                    avail2
     C                   parm                    avail3
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
     C                   eval      cmdtkn = *off
417 D*R                   MOVE *ZEROS    CURTRN  70
417 MC                   eval      curtrn = *zeros
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   eval      msgtyp = *blanks
     C                   eval      rtvslt = '*NO '
417 AC                   eval      undobk = '*YES'
417 AC                   move      *loval        savtrn
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
610aMC                   kfld                    $pitem
610aDC*                  kfld                    $item
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
610aMC                   kfld                    $pitem
610aDC*                  kfld                    $item
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
610aMC                   kfld                    $pitem
610aDC*                  kfld                    $item
     C                   kfld                    keysta
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     *
     C     slky3b        klist
     C                   kfld                    $whse
610aDC*                  kfld                    $item
610aMC                   kfld                    $pitem
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
     *  Define key for PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    w1emp#
     C                   kfld                    kystat
     *
     *  Define key for PIRTRAN2 file.
     *
     C     ptke22        klist
     C                   kfld                    w1emp#
     C                   kfld                    stdate
     C                   kfld                    sttime
     *
     *  Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    w1emp#
     C                   kfld                    stdate
     *
     *  Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    wotrn#
     *
     *  Setup option and command display lines.
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      optln1 = optlsp(1)
500 AC                   eval      cmdln1 = cmdlsp(1)
500 AC                   other
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
500 AC                   endsl
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
500 A*
500 A*   Get employee options.
500 A*
500 AC                   call      'GETUSER'
500 AC                   parm      #user         e$code           10
500 AC                   parm                    e$whse            3 0
500 AC                   parm                    e$emp#            5 0
500 AC                   parm                    e$fnam           15
500 AC                   parm                    e$init            1
500 AC                   parm                    e$lnam           20
500 AC                   parm                    e$whdp            5
500 AC                   parm                    e$styp            1
500 AC                   parm                    e$shft            6
500 AC                   parm                    e$crew            6
500 AC                   parm                    e$nhrs            3 1
500 AC                   parm                    e$rtn             8
500 AC                   parm                    e$bpu             1
500 AC                   parm                    e$lng             2
500 AC                   if        e$rtn <> '*OK'
500 AC                   eval      e$lng = 'EN'
500 AC                   endif
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     C                   eval      recno = 1
     *
     C                   select
     C                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     d16sflsp                             79
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
     C                   write     d16sfl                               79
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   write     dspsflsp                             79
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   write     dspsfl                               79
     C                   endsl
     *
     *   Get replenishment options from file.
     *
     C                   eval      kycode = '*REPLEN '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      oprpex = '3'
     C                   eval      oprpfi = '3'
417aAC                   eval      oplmts = 'N'
     C                   endif
     *
     C                   eval      dspwin = '*NO '
417aAC                   eval      offlag = *off
     *
     *   Get item description.
     *
     C                   eval      w1item = *blanks
610aDC*    $item         cat       '-':1         w1item
610aMC     $pitem        cat       '-':1         w1item
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
     *  ZZBLKU   Update current transaction with new location.
     *
     C     zzblku        begsr
     *
     C                   eval      $rtncd = '*OK     '
     C                   eval      nxtscr = 'EOJ'
     *
     *  Send back new location selected.
     C                   eval      $newsl = w1disp
     *
     *  Remove quantity from Original Bulk Pick slot.
417 A*      Bulk qty not reduced in previous program. Release
417 A*      entire quantity.
650bDC*                  if        undobk = '*YES'  and
650bDC*                            $blkq = $oblkq
650bMC                   if        undobk = '*YES'
     C     slokey        chain     slot2                              79
     C                   if        not *in79
650bMC                   eval      slpck1 = slpck1 - w3bqty
650bDC*                  eval      slpck1 = slpck1 - $blkq
     C                   update    recordu
     C                   endif
417bA*
417bAC     $lbl#         chain     label                              79
417bAC                   if        not *in79
417bAC                   eval      lbqpck = *zeros
417bAC                   eval      lbcube = *zeros
417bAC                   eval      lbswgt = *zeros
417bAC                   update    lbrec
640aA
640aA*  Check if prepick label.
640aA
640aAC                   exsr      zzprechk
417bAC                   endif
417bA*
650bAC                   if        w1disp = $disp
417 AC                   eval      undobk = '*NO '
650bAC                   endif
417 AC                   endif
     *
     *  Update new location with Bulk Pick qty.
     C     slfkey        chain     slot2                              79
     C                   if        not *in79
     C                   add       w3bqty        slpck1
     C                   update    recordu
     C                   endif
     * Label
     *  Update label record with new qty and location.
417 AC                   select
417 A*    Original slot selected. Update label record with qty.
417 AC                   when      w1disp = $disp
417 A*
417 AC     $lbl#         chain     label                              79
417 AC                   if        not *in79
417 AC                   add       w3bqty        lbqpck
417 AC     lbucub        mult      lbqpck        lbcube
417 AC     lbuwgt        mult      lbqpck        lbswgt
417 AC                   update    lbrec
417 AC                   endif
417 A*
417 A*    New slot selected. Create new label record from original.
417 AC                   when      w1disp <> $disp
417 A*
     C     $lbl#         chain     label                              79
417 A*    Clear original label record values.
     C                   if        not *in79
417 A*      Recompute allocate qty to show qty remaining.
417 AC                   eval      lbqalc = lbqalc - w3bqty
417 A*      Bulk qty not reduced in previous program. Release
417 A*      entire quantity.
417 AC                   if        $blkq = $oblkq
417 AC                   eval      lbqpck = *zeros
417 AC                   eval      lbcube = *zeros
417 AC                   eval      lbswgt = *zeros
417 AC                   endif
417 AC                   update    lbrec
417 A*
417 A*    Add new label record with new location.
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   eval      lbdisp = sldisp
417 AC                   eval      lbqalc = w3bqty
650bDC*                  eval      lbqavl = avail1
650bMC                   eval      lbqavl = woavl1
     C                   eval      lbqpck = w3bqty
     C     lbucub        mult      w3bqty        lbcube
     C     lbuwgt        mult      w3bqty        lbswgt
417 D*R                   UPDATLBREC
417 A*
417 A*     - Get new label number.
417 AC                   call      'PIRLBL#'
417 AC                   parm                    lblbl#
417 AC                   eval      $lbl# = lblbl#
417 A*
417 AC                   eval      $cvcmd = '*CURCMD '
417 AC                   exsr      zzcvdt
417 AC                   eval      lbsdte = $cvd8o
417 AC                   time                    lbstim
417 A*
417 MC                   write     lbrec
640aAC                   if        prepickLabel
640aAC     preLabel      chain     prexref
640aAC                   if        %found(prexref)
640aAC                   eval      pxlbl# = lblbl#
640aAC                   update    pxrec
640aAC                   endif
640aAC                   endif
     C                   endif
417 AC                   endsl
417 A*
     *
417 A*    Check if entire quantity has been picked.
417 AC                   eval      $blkq = $blkq - w3bqty
417 AC                   select
417 AC                   when      $blkq = 0
417 AC                   eval      $rtncd = '*OK'
417 A*
417 AC                   when      $blkq > 0
417 AC                   eval      $rtncd = '*BALANCE'
417 AC                   endsl
417 A*
417 A*    Entire qty will be picked. Do not reduce allocation.
417 AC                   goto      endbku
417 A*
     C                   if        w3bqty <> $blkq
     C                   eval      qtychg = $blkq - w3bqty
     *
     *  Update warehouse allocated quantity.
     *
     C                   eval      $acmd = '*UNALLOC'
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     C                   eval      $aqty1 = qtychg
     C                   eval      $aqty2 = *zeros
     C                   eval      $aqty3 = *zeros
     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
     C                   parm                    $aprg            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm
     *
     *  Update trans with new quantity.
     *
     C                   select
     C                   when      qtychg < 0
     C                   eval      @pcmd = '*INCTTL '
     C                   eval      qtychg = -(qtychg)
     C                   when      qtychg > 0
     C                   eval      @pcmd = '*DECTTL '
     C                   endsl
     *
     C     qtychg        mult      lbucub        @pcube
     C     qtychg        mult      lbuwgt        @pswgt
     *
     C                   call      @adjtr
     C                   parm                    @pcmd             8
     C                   parm                    #job
     C                   parm      $trn#         @ptrn#            7 0
     C                   parm      $task         @ptask            6
     C                   parm      $whse         @pwhse            3 0
     C                   parm      $whdp         @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm      qtychg        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      lbrte         @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     C                   endif
     *
     C     endbku        endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZBLKN   Create new Bulk Pick Label.
417 A*
417 AC     zzblkn        begsr
417 A*
417 AC                   eval      nxtscr = 'EOJ'
417 A*
417 A*  Send back new location selected.
417 AC                   eval      $newsl = w1disp
417 A*
417 A*  Remove quantity from Original Bulk Pick slot.
650bDC*                  if        undobk = '*YES'  and
650bDC*                            $blkq = $oblkq
650bMC                   if        undobk = '*YES'
417 AC     slokey        chain     slot2                              79
417 AC                   if        not *in79
650bDC*                  eval      slpck1 = slpck1 - $blkq
650bMC                   eval      slpck1 = slpck1 - w3bqty
417 AC                   update    recordu
417 AC                   endif
417bA*
417bAC     $lbl#         chain     label                              79
417bAC                   if        not *in79
417bAC                   eval      lbqpck = *zeros
417bAC                   eval      lbcube = *zeros
417bAC                   eval      lbswgt = *zeros
417bAC                   update    lbrec
417bAC                   endif
417bA*
650bAC                   if        w1disp = $disp
417 AC                   eval      undobk = '*NO '
650bAC                   endif
417 AC                   endif
640aA
640aA*  Check if prepick label.
640aA
640aAC                   exsr      zzprechk
417 A*
417 A*  Update new location with Bulk Pick qty.
417 AC     slfkey        chain     slot2                              79
417 AC                   if        not *in79
417 AC                   add       w3bqty        slpck1
417 AC                   update    recordu
417 AC                   endif
417 A* Label
417 A*  Update label record with new qty and location.
417 AC                   select
417 A*    Original slot selected. Update label record with qty.
417 AC                   when      w1disp = $disp
417 A*
417 AC     $lbl#         chain     label                              79
417 AC                   if        not *in79
417 AC                   add       w3bqty        lbqpck
417 AC     lbucub        mult      lbqpck        lbcube
417 AC     lbuwgt        mult      lbqpck        lbswgt
417 AC                   update    lbrec
417 AC                   endif
417 A*
417 A*    New slot selected. Create new label record from original.
417 AC                   when      w1disp <> $disp
417 A*
417 AC     $lbl#         chain     label                              79
417 AC                   if        not *in79
417 A*      Recompute allocate qty to show qty remaining.
417 AC                   eval      lbqalc = lbqalc - w3bqty
417 AC                   update    lbrec
417 A*
417 AC                   eval      lbaisl = slaisl
417 AC                   eval      lbloc = slloc
417 AC                   eval      lbrlvl = slrlvl
417 AC                   eval      lbhand = slhand
417 AC                   eval      lbpseq = slpseq
417 AC                   eval      lbstyp = slstyp
417 AC                   eval      lbdisp = sldisp
650bDC*                  eval      lbqavl = avail1
650bMC                   eval      lbqavl = woavl1
417 AC                   eval      lbqalc = w3bqty
417 AC                   eval      lbqpck = w3bqty
417 AC     lbucub        mult      w3bqty        lbcube
417 AC     lbuwgt        mult      w3bqty        lbswgt
417 A*
417 A*     - Get new label number.
417 AC                   call      'PIRLBL#'
417 AC                   parm                    lblbl#
417 AC                   eval      $lbl# = lblbl#
417 A*
417 AC                   eval      $cvcmd = '*CURCMD '
417 AC                   exsr      zzcvdt
417 AC                   eval      lbsdte = $cvd8o
417 AC                   time                    lbstim
417 AC                   write     lbrec
417 A*
640aAC                   if        prepickLabel
640aAC     preLabel      chain     prexref
640aAC                   if        %found(prexref)
640aAC                   eval      pxlbl# = lblbl#
640aAC                   write     pxrec
640aAC                   endif
640aAC                   endif
417 AC                   endif
417 AC                   endsl
417 A*
417 A*    Check if entire quantity has been picked.
417 AC                   eval      $blkq = $blkq - w3bqty
417 AC                   select
417 AC                   when      $blkq = 0
417 AC                   eval      $rtncd = '*OK'
417 A*
417 AC                   when      $blkq > 0
417 AC                   eval      $rtncd = '*BALANCE'
417 AC                   endsl
417 A*
417 AC     endbkn        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKRT  Check if replenishment is pulled in FIFO order.
     *
     C     zzckrt        begsr
     *
     C                   eval      dspwin = '*NO '
     *
     C                   if        rtvslt = '*NO '
     C     slfiky        chain(n)  slot2                              79
     C                   endif
     C                   select
     *    Slot not found.
     C                   when      *in79
     C                   eval      error = *on
     *
     *    Slot found.
     C                   when      not *in79
     *
     C                   eval      kypick = 'N'
     C                   eval      keysta = slstat
     C                   eval      kyexpd = slexpd
     C                   eval      kyprty = slprty
     *
     C                   eval      ckexpd = slexpd
     *
     C     slky3a        setll     slot3
     C     slky3b        readpe    slot3                                  79
     C                   select
     *    No other slots found - slot ok for replenishment.
     C                   when      *in79
     C                   eval      slstk1 = *zeros
     C                   eval      slstk2 = *zeros
     C                   eval      slstk3 = *zeros
     C                   eval      slexpd = *zeros
     *
     *    Older product found, not expired. Display warning.
     C                   when      slstat = 'A '  and
     C                             slexpd < ckexpd  and
     C                             slexpd > *zeros  and
     C                             slexpd >= tstdte
     C                   eval      dspwin = '*YES'
     C                   endsl
     *
     C                   endsl
     *
     *    Retrieve slot to refresh info on slot selected for replen.
     C     slfiky        chain(n)  slot2                              79
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = *zeros
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptsdte < zzsdte
     C                   leave
     C                   endif
     *   Skip the task that just ended.
     C                   if        not *in79  and
     C                             pttrn# = svtrn#
     C                   iter
     C                   endif
     *
     *   Skip 'IDLE' task
     *
     C                   if        pttask = 'IDLE'
     C                   iter
     C                   endif
     *
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79
     C                   eval      tktype = ' '
     C                   endif
     *
     *   Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
     C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
     *R         PTETYP    ANDEQ'M'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     *   Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
     C                   if        not *in79  and
     C                             ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
     *R         PTETYP    ANDEQ'M'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     *   Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
     C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim  and
     C                             tktype = 'I'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     C                   enddo
     *
     *   Update the task that just ended.
     *
     C     svtrn#        chain     pirtran                            79
     C                   if        not *in79
     C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
     C                   else
     C                   eval      ptimin = ptimin - svtlen
     C                   endif
     C                   update    ptrec
640bAc                   exsr      zzwrttrand
     C                   endif
     C     endcu2        endsr
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
     *  ZZEND  End current task.
     *
     C     zzend         begsr
     *  No current task to end.
     C     curtrn        cabeq     0             endend
     *  End current task
     C                   eval      wotrn# = curtrn
     C     ptkey         chain     pirtran                            79
     C                   if        not *in79
     C                   if        curtyp = 'D'  and
     C                             curtsk <> 'IDLE  '
     C                   eval      ptstat = '3'
     C                   else
     C                   eval      ptstat = '4'
     C                   endif
     C                   eval      ptetyp = 'N'
     C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   update    ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endend
     C                   endif
640bAc                   exsr      zzwrttrand
     *
     C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   eval      svtrn# = pttrn#
     *  Past overnight. (PTEDTE > PTSDTE)
     C                   if        ptedte > ptsdte
     C                   eval      stdate = ptedte
     C                   else
     C                   eval      stdate = ptsdte
     C                   endif
     C                   eval      zzsdte = ptsdte
     C                   eval      zzedte = ptedte
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zzcku2
     C                   endif
     *
     C     endend        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record.
     C                   eval      exwhse = $whse
     *R                   MOVE $PWHDP    EXWHDP
     C                   eval      exwhdp = slwhdp
     C                   eval      exstyp = slstyp
610aDC*                  eval      exitem = $item
610aMC                   eval      exitem = $pitem
     C                   eval      exfdis = sldisp
     C                   eval      extdis = *blanks
650 A*
650 AC                   if        slstk1 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     slstk1        exqty
650 AC                   endif
650 A*
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
610aDC*                  eval      seitem = $item
610aMC                   eval      seitem = $pitem
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
     *  ZZIDLE   Create and Start an Idle task.
     *
     C     zzidle        begsr
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     C                   eval      ptstat = '2'
     C                   eval      pttask = 'IDLE  '
     C                   eval      t#task = 'IDLE  '
     C     tkkey         chain     task                               77
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   select
     C                   when      tktlvl = 'S'
     C                   eval      ptwhse = $whse
     C                   eval      ptwhdp = itwhdp
     C                   eval      ptstyp = itstyp
     C                   when      tktlvl = 'D'
     C                   eval      ptwhse = $whse
     C                   eval      ptwhdp = itwhdp
     C                   eval      ptstyp = *blanks
     C                   other
     C                   eval      ptwhse = $whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   endsl
     C                   eval      ptshft = w1shft
     C                   eval      ptcrew = w1crew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = *zeros
     C                   eval      ptswgt = *zeros
     C                   eval      ptpcs = *zeros
     C                   eval      ptaisl = *zeros
     C                   eval      ptqty1 = *zeros
     C                   eval      ptqty2 = *zeros
     C                   eval      ptqty3 = *zeros
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptedte = *zeros
     C                   eval      ptetim = *zeros
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = *zeros
     C                   eval      ptctim = *zeros
     C                   eval      ptdmin = *zeros
     C                   eval      ptimin = *zeros
     C                   eval      ptrtpo = *blanks
     C                   write     ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endidl
     C                   endif
640bAc                   exsr      zzwrttrand
     *
     C     endidl        endsr
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

640aA*----------------------------------------------------------------
640aA*  ZZPRECHK   Check if prepick label.
640aA*----------------------------------------------------------------
640aA
640aAC     zzprechk      begsr

     *  See if label record is a prepick label

     C     lblbl#        chain     prexref
     C                   if        %found(prexref)
     C                   eval      prepickLabel = *on
     C                   eval      preLabel = lblbl#
     C                   else
     C                   eval      preLabel = *zeros
     C                   eval      prepickLabel = *off
     C                   endif

     C                   endsr
     *
     *----------------------------------------------------------------
610a *
610a *  ZZPULL   Pull license
610a *
610a C     zzpull        begsr
610a *
610aAC                   eval      curlic# = #fromToLcns
610aA
610aA*    Call program that will (if necessary) ...
610aA*      - Prompt user to pull pallet.
610aA*      - Have user verify license being pulled.
610aA*      - Update license information.
610aA
610aAC                   exsr      zzzclr$lt210
610aAC                   eval      $tcmd  = '*PULDROP'
610aAC                   eval      $twhse = $whse
610aAC                   eval      $twhdp = #fromslwhdp
610aAC                   eval      $tslot = #fromsldisp
610aAC                   eval      $titem = #fromslitem
610aAC                   eval      $titemdsc = #fromithead
610aAC                   eval      $tlic# = #fromToLcns
610aAC                   exsr      zzzcall$lt210
610aDC**                 eval      curlic# = $tlic#
610aA
610aA
610aAC                   if        $treturn = '*CANCEL'
610aAC                   eval      redspl = *on
610aAC**                 eval      nxtscr = '01'
610aAC                   goto      endpul
610aAC                   endif
610aA
610aAC                   if        $treturn = '*NOTFND'
610aA
610aAC                   exsr      zzzclr$lt210
610aAC                   eval      $tcmd   = '*PULRTN'
610aAC                   eval      $twhse  = $pwhse
610aAC                   eval      $twhdp  = lbwhdp
610aAC                   eval      $tslot  = lbdisp
610aAC                   eval      $titem  = lbitem
610aAC                   eval      $titemdsc = itdesc
610aaC                   eval      $tlic# = #fromToLcns
610aAC                   exsr      zzzcall$lt210
610aA
610aAC***                eval      nxtscr = '01'
610aAC                   goto      endpul
610aAC                   endif
610a C     endpul        endsr
     *----------------------------------------------------------------
     *
     *  ZZSLCT   Select a slot for Bulk Pick.
     *
     C     zzslct        begsr
     *
     C                   eval      w1disp = ukdisp
     C                   exsr      zzchk1
     C                   if        error = *on
     C                   eval      w1disp = *blanks
     C                   goto      endslc
     C                   endif
    A
610a * Use DRISLOT to get slot
610a C                   exsr      zzslot
610a * Pull license
610aAC                   exsr      zzpull
610a C                   if        error = *on
610a C                   eval      w1disp = *blanks
610a C                   goto      endslc
610a C                   endif
610a C     redspl        cabeq     *on           endslc
     *
     C                   exsr      scr03i
     *
     C     endslc        endsr
     *
     *----------------------------------------------------------------
610a *
610a *  ZZSLOT   Use DRISLOT for slot
610a *
     C     zzslot        begsr
610a C                   eval      error = *off
610aA*  Use DRI interface to get slot information.
610aA
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = ukwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = ukwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ukdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      enddst
     C                   endif

     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
     C                   eval      #fromslrsrv = $slrsrv
     C                   eval      #fromslentd = $slentd
     C                   eval      #fromslexpd = $slexpd
     C                   eval      #fromslslfd = $slslfd
     C                   eval      #fromslactv = $slactv
     C                   eval      #fromslbld  = $slbld
     C                   eval      #fromslpick = $slpick
     C                   eval      #fromslitem = $slitem
     C                   eval      #fromslsdef = $slsdef
     C                   eval      #fromslvirt = $sfvirt
     C                   eval      #fromslstk1 = $slstk1
     C                   eval      #fromslstk2 = $slstk2
     C                   eval      #fromslstk3 = $slstk3
     C                   eval      #fromslalc1 = $slalc1
     C                   eval      #fromslalc2 = $slalc2
     C                   eval      #fromslalc3 = $slalc3
     C                   eval      #fromsltfr1 = $sltfr1
     C                   eval      #fromsltfr2 = $sltfr2
     C                   eval      #fromsltfr3 = $sltfr3
     C                   eval      #fromslpck1 = $slpck1
     C                   eval      #fromslpck2 = $slpck2
     C                   eval      #fromslpck3 = $slpck3
     C                   eval      #fromslrcv1 = $slrcv1
     C                   eval      #fromslrcv2 = $slrcv2
     C                   eval      #fromslrcv3 = $slrcv3
     C                   eval      #fromslphy1 = $slphy1
     C                   eval      #fromslphy2 = $slphy2
     C                   eval      #fromslphy3 = $slphy3
     C                   eval      #fromslavl1 = $slavl1
     C                   eval      #fromslavl2 = $slavl2
    AC                   eval      #fromslavl3 = $slavl3
    AC                   eval      #fromToLcns = $saToLcns
    AC                   eval      #fromToPos  = $saToPos
    AC                   eval      #fromOLcns = $saOLcns

     C                   eval      #frombasesldsp = $sacdsp
    A
610aAC     enddst        endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   eval      kystat = '2'
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1                               79
     C                   if        *in79
     C                   eval      found = *off
     C                   goto      endtsk
     C                   endif
     *
     C     ptke22        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptemp# <> w1emp#
     C                   eval      found = *off
     C                   leave
     C                   endif
     C                   if        ptstat <> '2'
     C                   iter
     C                   endif
     *   Found an active transaction
     C                   eval      curent = *on
     C                   eval      curtrn = pttrn#
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        not *in79
     C                   eval      curtsk = tkcode
     C                   eval      curtyp = tktype
     C                   endif
     C                   leave
     C                   enddo
     C     endtsk        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C                   eval      tmpbeg = dshh * 60
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        fintim < strtim
     C                   add       24            dshh
     C                   endif
     C                   eval      tmpend = dshh * 60
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = *zeros
     C                   endif
     *
     C     endtim        endsr
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
610aDC*    slitem        cabne     $item         nxtvs
610aMC     slitem        cabne     $pitem        nxtvs
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
     *   User must be warned when bulk pick qty different from
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
     C                   endsl
     C                   endsl
     *
     C                   leave
     *
     C                   endsl
     C                   enddo
     *
     C     endwrn        endsr
640bA*----------------------------------------------------------------*********
640bA*
640bA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640bA*
640bA /free
640bA   begsr zzwrttrand;
640bA     wrtpcmd = '*ONETRAN';
640bA     wrtpwait = 0;
640bA     wrtpwhse = ptwhse;
640bA     wrtptran# = pttrn#;
640bA     wrtpfrmdate = 0;
640bA     wrtptodate = 0;
640bA     wrtpemp# = 0;
640bA
640bA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640bA               wrtpfrmdate: wrtptodate: wrtpemp#);
640bA   endsr;
640bA /end-free
500 A*----------------------------------------------------------------
500 A*  ZZZCALL$LT210  -  Call LT210 program.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCALL$LT210 begsr

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
500jAC                   parm                    $tnorm1
500jAC                   parm                    $tnorm2
500jAC                   parm                    $tnorm3
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

610aA*----------------------------------------------------------------
610aA*  ZZZCLR$LT210  -  Clear LT210 parameters.
610aA*----------------------------------------------------------------
610aA
610aAC     ZZZCLR$LT210  begsr

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

610aAC                   endsr

610aA*----------------------------------------------------------------
610aA*  zzzdricop  Call DRICOP
610aA*----------------------------------------------------------------
610aA
610aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
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
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 9 X
**  OPTLN - Option display line
  1=Select  9=View Slot Quantities
**  CMDLN - Command display line
F3=Exit F5=Refresh F8=Lic inf F12=Cancel
**  DESC - Description
Available Quantity
Verify Zero
Qty greater than Bulk Pick qty.
1=Select can be used only once.
Slot error logged for slot:
Pick new slot. Bulk Pick using this slot.
**  OPTLSP - Option display line
  1=Select  9=View Slot Quantities
**  CMDLSP - Command display line
F3=Exit F5=Refresh F8=Lic inf F12=Cancel
**  DESCSP - Description
Available Quantity
Verify Zero
Qty greater than Bulk Pick qty.
1=Select can be used only once.
Slot error logged for slot:
Pick new slot. Bulk Pick using this slot.
