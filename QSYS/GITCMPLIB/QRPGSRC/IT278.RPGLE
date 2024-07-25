      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *  Multilingual Verision
     *  Every screen and message has a corresponding Spanish version.
     *  Any changes must be made to both languages.
     *  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  IT278   RF- slot replenishments - VM   8 X 40
     *  26 February 2018
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720 A*    02/26/18  LMC  7.20
     *      - Created.
     *      - Copied from IT276
     *
720aA*    03/12/18  KDE  7.20a
     *      - Changed to force option 1 on scanned Pick Slot and act just
     *        as it would have had they keyed option 1 next to slot
     *      - Do not allow scan field when case and breakdown shown
     *
720bA*    05/17/18  KDE  7.20b
     *      - Changed to display pick slots when not found in Store Zone
730aA*    09/24/19  LMC  7.30a
     *      - Omit RWO slots.                                         ne
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  64        Reverse image breakdown text on SCANREC.
     *  76        Error indicator on write to SLTRPEX.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     F*t276fm   cf   e             workstn
     F*it27601   cf   e             workstn
     F*t27602   cf   e             workstn
     Fit278fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsfl2:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(d16sfl2:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(dspsflsp2:recno)
     F                                     sfile(d16sflsp:recno)
     F                                     sfile(d16sflsp2:recno)
     Fworkopt   uf a e           k disk
     Fitmexcp   uf a e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
     F*lot10    if   e           k disk    rename(slrec:slrec10)
     FLabel     uf a e           k disk
     Fbatctl    o    e           k disk
     Foptions   if   e           k disk
     Fsltrpex   uf a e           k disk    Prefix(x)
     Fworkusr3  uf a e           k disk
720aAFvSlot1    if a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     D cmdcw           s             79    dim(1) ctdata perrcd(1)
     *                   DESC    1   5 40
     D*desc            s             40    dim(6) ctdata perrcd(1)
     D desc            s             40    dim(7) ctdata perrcd(1)
     D optlsp          s             75    dim(1) ctdata perrcd(1)
     D cmdlsp          s             79    dim(1) ctdata perrcd(1)
     D*descsp          s             40    dim(6) ctdata perrcd(1)
     D descsp          s             40    dim(7) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
     D @getcl          c                   const('GETCLIENT')

      /COPY QCOPYSRC,ID#ROYAL
      /COPY QCOPYSRC,ID#CITYWHO
      /COPY QCOPYSRC,ID#SAVAL
      /COPY QCOPYSRC,ID#GLAZIER
      /COPY QCOPYSRC,ID#FRF
      /copy qcopysrc,id#citylin
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#coastal
      /copy qcopysrc,id#westsid
      /copy qcopysrc,ID#CHENEY

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#SLOTDEF
      /COPY *libl/qcopysrc,C#ZONED
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)

     D frm$Slot        ds                  likeds($slot)
     D frm$Slot2       ds                  likeds($slot2)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D* slwhse                 1      3  0 inz(0)
     D  slitem                 4     18
     D  sldisp                19     30
     D* slstat                19     20
     D* slpick                21     21
     D* slprty                22     22  0 inz(0)
     D* slexpd                23     30  0 inz(0)
     D* slentd                31     38  0 inz(0)
     D* slwhdp                39     43
     D* slstyp                44     44
     D* slaisl                45     47
     D* slpseq                48     52  0 inz(0)
     D* slrlvl                53     54  0 inz(0)
     D* slhand                55     56
     *
     D                 ds
     D  dsukey                 1     50
     D* ukwhse                 1      3  0 inz(0)
     D* ukwhdp                 4      8
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
     D @addt2          c                   const('ADDSTDTRN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     D @sltdt          c                   const('UPDSLTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
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
     *
     D  $llot                 37     37
     D  $lltrk                38     38
     *
     D  $lwhdp                22     26
     D  $ldisp                27     38
     D  $litm2                39     53
     *
     D  $ldsp2                54     65
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
     *  Replenishment error messages(s).
     *
     D msg101          c                   const('Slot no es dispon ')
     D msg102          c                   const('para reaprovisiona')
     D msg103          c                   const('Expiro :')
     D msg104          c                   const('Intente slot nuev ')
     *
     D msg201          c                   const('Slot tiene prdcto ')
     D msg202          c                   const('expirado.')
     *
     D msg301          c                   const('Slot seleccionado')
     D msg302          c                   const('en orden incrrcto')
     *
     D msg101e         c                   const('Slot not available')
     D msg102e         c                   const('para reaprovisiona')
     D msg103e         c                   const('Expired:')
     D msg104e         c                   const('Try a different slot')
     *
     D msg201e         c                   const('Slot has item     ')
     D msg202e         c                   const('expired. ')
     *
     D msg301e         c                   const('Slot selected in ')
     D msg302e         c                   const('incorrect order  ')
     *
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     D llp01           c                   const('Escanda licencia  ')
     D llp02           c                   const('Escn numero de lot')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     *                                      16  27 ERDISP
     D  erdisp                 1     12
     *
     D  erdmsg                 1     60
     D  erdrtn                61     70
     D  erdcmd                71     80
     D  erdsub                81     90
     D                 ds
     D  $ec                    1      2p 0
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     D  #curruser            358    367

     *----------------------------------------------------------------
     *  Tracking variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Variables
     *

     D #fromitwhse     s                   like($itwhse)
     D #fromititem     s                   like($ititem)
     D #fromittype     s                   like($ittype)
     D #fromitdesc     s                   like($itdesc)
     D #fromitpdsc     s                   like($itpdsc)
     D #fromithead     s             70
     D #fromitwhdp     s                   like($itwhdp)
     D #fromitstyp     s                   like($itstyp)
     D #fromitdesg     s                   like($itdesg)
     D #fromitum1      s                   like($itum1)
     D #fromitflg1     s                   like($itflg1)
     D #fromitum2      s                   like($itum2)
     D #fromitumq2     s                   like($itumq2)
     D #fromitflg2     s                   like($itflg2)
     D #fromitum3      s                   like($itum3)
     D #fromitumq3     s                   like($itumq3)
     D #fromitnrpk     s                   like($imnrpk)
     D #fromitflgd     s                   like($itflgd)
     D #fromitcube     s                   like($itcube)
     D #fromitswgt     s                   like($itswgt)
     D #fromitcwgt     s                   like($itcwgt)
     D #fromitmitem    s                   like($itmitem)
     D #fromitsdef     s                   like($idsdef)
     D #fromittie      s                   like($idtie)
     D #fromithigh     s                   like($idhigh)
     D #fromimltrk     s                   like($imltrk)

     D #homeitwhse     s                   like($itwhse)
     D #homeititem     s                   like($ititem)
     D #homeittype     s                   like($ittype)
     D #homeitdesc     s                   like($itdesc)
     D #homeitpdsc     s                   like($itpdsc)
     D #homeithead     s             70
     D #homeitwhdp     s                   like($itwhdp)
     D #homeitstyp     s                   like($itstyp)
     D #homeitdesg     s                   like($itdesg)
     D #homeitum1      s                   like($itum1)
     D #homeitflg1     s                   like($itflg1)
     D #homeitum2      s                   like($itum2)
     D #homeitumq2     s                   like($itumq2)
     D #homeitflg2     s                   like($itflg2)
     D #homeitum3      s                   like($itum3)
     D #homeitumq3     s                   like($itumq3)
     D #homeitnrpk     s                   like($imnrpk)
     D #homeitflgd     s                   like($itflgd)
     D #homeitcube     s                   like($itcube)
     D #homeitswgt     s                   like($itswgt)
     D #homeitcwgt     s                   like($itcwgt)
     D #homeitmitem    s                   like($itmitem)
     D #homeitsdef     s                   like($idsdef)
     D #homeittie      s                   like($idtie)
     D #homeithigh     s                   like($idhigh)
     D #homeimltrk     s                   like($imltrk)

     D #homeslwhse     s                   like($slwhse)
     D #homeslwhdp     s                   like($slwhdp)
     D #homesldisp     s                   like($sldisp)
     D #homeslitem     s                   like($slitem)
     D #homeslaisl     s                   like($slaisl)
     D #homeslloc      s                   like($slloc)
     D #homeslrlvl     s                   like($slrlvl)
     D #homeslhand     s                   like($slhand)

     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D a58             s             58
     D bot             s              1
     D cancel          s              1
     D chk4err         s               n
     D ckexpd          s                   like(today)
     D ckentd          s                   like(today)
     D ck4err          s              1
     D clear           s              5  0
     D comand          s              5  0
     D drierr          s              1
     D drizm           s              1
     D dsplyd          s              2  0
     D dspwin          s              4
     D e               s              2  0
     D eacube          s                   like($itcube)
     D easwgt          s                   like($itswgt)
     D enter           s              5  0
     D error           s               n
     D fmentd          s              8  0
     D fmexpd          s              8  0
     D forceb          s              1
     D forevr          s              1
     D found           s              1
720aAd foundSlot       s               n
     D frstky          s                   like($puky)
     D fvslot          s              1
     D goback          s              2  0
     D hasvs           s              1
     D help            s              5  0
     D hldvsl          s             12
     D i               s              2  0
     D keysta          s                   like($slstat)
     D kycode          s                   like(opcode)
     D kydisp          s                   like($sldisp)
     D kyexpd          s                   like($slexpd)
     D kyentd          s                   like($slentd)
     D kyitem          s                   like($ititem)
     D kypick          s                   like($slpick)
     D kyprty          s                   like($slprty)
     D msgk            s              4  0
     D msgtyp          s              8
     D nomore          s              1
     D noslt           s              1
     D nxtscr          s              3
     D offlag          s              1
     D optcnt          s              3  0
     D optln1          s             75
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D partial         s               n
     D recno           s              4  0
     D redspl          s              1
     D refrsh          s              1
     D repos           s              1
     D repqty          s                   like(lbqpck)
     D rltype          s                   like($ittype)
     D rolldn          s              5  0
     D rollup          s              5  0
     D rplqty          s                   like(lbqpck)
     D rtvslt          s              4
     D scannedSlot     s               n
     D sclear          s              1
     D stop            s              1
     D t#task          s              6
     D tempa2          s              2
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D top             s              1
     D topick          s              5  0
     D trndte          s              8  0
     D trntim          s              6  0
     D tstdte          s                   like(today)
     D view            s              1  0
     D warn            s              1
     D woavl1          s              5  0
     D worqty          s              5  0
     D woslt           s             12
     D w1ldspFull      s             15
     D w1ldspFullNone  s             15    inz('-------')
     D licLen          s              3  0
     D x               s              3  0
     D y               s              3  0
     D zmsflag         s               n
     D LT107_Repack    s               n
     D $newlp#         s                   like($tlic#)

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


     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Phrase Variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#phrasvar
     D  currFile       s             10
     D  currRoutine    s             20
     D  lastnxtscr     s              3
     D  stackCount     s              3  0
     D  aRoutine       s             20    dim(30)

     *----------------------------------------------------------------
     *  Phrases
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $iPrg    Calling program
     *      $iWhse   Warehouse
     *      $iWhdp   Warehouse department
     *      $iHome   Home slot from LT105.01
     *      $iItem   Item number
     *
     *    Returned Parameters
     *      frm$Slot   $slot for From slot
     *      frm$Slot2  $slot2 for From slot
     *      $iReturn   *Exit
     *                 *Cancel
     *                 *OK
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $iPrg            10
     C                   parm                    $iWhse            3 0
     C                   parm                    $iWhdp            5
     C                   parm                    $iHome           12
     C                   parm                    $iItem           15
     C                   parm                    $iReturn          8
      **

     *  if coming from LT107 and Repack Replenishment then user wants
     *  to override from slot.  Use the partial quantity vs. full slot
     c                   if        $iPrg = 'LT107R'
     c                   eval      $iPrg = 'LT107'
     c                   eval      topick = frm$slot.$slavl3
     c                   eval      frm$slot.$slavl3 = 0
     c                   eval      LT107_Repack = *on
     c                   else
     c                   eval      LT107_Repack = *off
     c                   endif
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      stackCount = 0
     C                   eval      currRoutine = 'main'
     C                   exsr      phpgmV1V2V3s
     C                   eval      *in97 = *on
     C                   eval      $iReturn = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   exsr      phpgmV1V2V3e
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Write tracking phrase of which screen is being displayed.
     *
     C                   exsr      phscrV1PgmV2
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   select
     C                   when      e$lng = 'SP' and #lline = '16'
     C                   read      po16nrsp                               50
     C                   read      sc16resp                               50
     C                   when      e$lng = 'SP'
     C                   read      postnrsp                               50
     C                   read      scanresp                               50
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   read      po16nrec                               50
     C                   read      sc16rec                                50
     C                   other
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     C                   endsl
     C                   endif
     *
     *   Write tracking phrase of what was pressed.
     *
     C                   exsr      phV2onV1
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
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'
     C                             and e$lng = 'SP'
     C                   read      d16sfcsp2                              50
     C                   when      #lline = '16'
     C                             and e$lng = 'EN'
     C                   read      d16sfc2                                50
     C                   when      #lline <> '16'
     C                             and e$lng = 'SP'
     C                   read      dspsfcsp2                              50
     C                   when      #lline <> '16'
     C                             and e$lng = 'EN'
     C                   read      dspsfc2                                50
     C                   endsl

     C                   other

     C                   select
     C                   when      #lline = '16'
     C                             and e$lng = 'SP'
     C                   read      d16sfcsp                               50
     C                   when      #lline = '16'
     C                             and e$lng = 'EN'
     C                   read      d16sfc                                 50
     C                   when      #lline <> '16'
     C                             and e$lng = 'SP'
     C                   read      dspsfcsp                               50
     C                   when      #lline <> '16'
     C                             and e$lng = 'EN'
     C                   read      dspsfc                                 50
     C                   endsl
     *
     C                   endsl

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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1

     C                   select
     C                   when      e$lng = 'SP' and #lline = '16'
     C                   write     d16sflsp                             79
     C                   write     d16sflsp2                            79
     C                   when      e$lng = 'SP'
     C                   write     dspsflsp                             79
     C                   write     dspsflsp2                            79
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   write     d16sfl                               79
     C                   write     d16sfl2                              79
     C                   other
     C                   write     dspsfl                               79
     C                   write     dspsfl2                              79
     C                   endsl
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ChkCnt   Check option count, can't select > 1
     *
     C     chkcnt        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   if        not *in79
     C                   eval      optcnt = 1
     C                   endif
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
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $iReturn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $iReturn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR F5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        dsplyd        x

     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp2                          79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl2                            79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp2                          79
     C                   when      #lline <> '16'
     C                   when      e$lng = 'EN'
     C     x             chain     dspsfl2                            79
     C                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp2
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl2
     C                   endsl
     C                   endif

     C                   other

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp                           79
     C                   when      #lline <> '16'
     C                   when      e$lng = 'EN'
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif

     C                   endsl

     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR F6 - ADD RECORD
     *
     C                   if        *inkf
     C                   eval      $pprg = #prog
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
     *  TEST FOR F8 - Display license plate info.
     *
     C                   if        *inkh
     C                   call      'LP120CL'
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F10 - Out. No more replenishment slots available.
     *
     C                   if        *inkj
     *    Write out exception record.
     C                   eval      exerid = 'SLOTOUT'
     C                   exsr      zzexcp
     C                   exsr      zzout
     C                   endif
     C*  Test for F11 - Call transfer program, bypass transaction.
     C*  Code is from F9 skip.
     C*
     C                   if        *inkk
     C* Call RF transfer.
     C                   eval      $lwhse = 0
     C                   eval      $lwhdp = ' '
     C                   eval      $litem = lbitem
     C                   eval      $ldisp = lbdisp
     C                   eval      $ldsp2 = ' '
     C                   call      'IT250'
     C                   PARM                    $lparm
     C                   endif
     C*
     *
     *  TEST FOR F17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F18 - REPOSITION TO BOTTOM OF DISPLAY
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
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     C                   endif
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
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
     *  CHECK IF SLOT WAS ENTERED.
     *
     C                   eval      fvslot = *off
     C                   eval      hldvsl = *blanks
     C                   eval      scannedSlot = *off
720aDC*                  if        w1disp <> *blanks
720aA *  always skip these checks when user scans slot
720aAC                   if        w1disp <> w1disp
     C                   eval      scannedSlot = *on
     C                   exsr      zzchk1
     C     error         cabeq     *on           ent01e
     C     redspl        cabeq     *on           ent01e
     C     cancel        cabeq     *on           ent01e
     C**                 eval      $iDisp = w1disp
     C**                 eval      $puky = dsukey
     *
     C                   exsr      zzstrt

     C                   eval      $iReturn = '*OK     '
     *
     C                   eval      nxtscr = 'EOJ'
     C                   goto      ent01e
     *
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     C     ent01e        endsr
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
     C*                  exsr      zzkeyf
     C                   endif
     C                   endsr
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
     C*                  exsr      zzkeyf
     C*                  exsr      zzkeyu
     C                   endif
     C                   endsr
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
     C*                  exsr      zzkeyf
     C*                  exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
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
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   move      $prtky        $puky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
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
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
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
     *   Return pick slot to LT105
     *
     C                   when      wkoopt = ' 1'
     C                   eval      dsukey = $puky
     c                   eval      $ihome = ukdisp
     c                   return
     C*                  exsr      zzslct
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
     C                   parm      #homeitwhse   $twhse
     C                   parm                    #homeitwhdp
     C                   parm                    $pdisp
     *
     *    Log slot error in item exception file.
     *
     C                   when      wkoopt = ' S'
     C                   eval      kydisp = $pdisp
     C                   eval      w1disp = $pdisp
     c                   exsr      zzgetfromsl
     *
     *    Write out exception record.
     C                   eval      exerid = 'STKPLT '
     C                   exsr      zzexcp
     *
     *    Write record to slot exception file.
     C                   if        slpick <> 'Y'
     C                   exsr      zzexsl
     C                   endif
     *
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = %trimr(descsp(5)) + ' ' + sldisp
     C                   other
     C                   eval      errmsg = %trimr(desc(5)) + ' ' + sldisp
     C                   endsl
     C                   exsr      zm0105
     *
     *
     *    Log slot error in item exception file.
     *
     C                   when      wkoopt = ' X'
     C                   eval      kydisp = $pdisp
     C                   eval      w1disp = $pdisp
     c                   exsr      zzgetfromsl
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = %trimr(descsp(5)) + ' ' + sldisp
     C                   other
     C                   eval      errmsg = %trimr(desc(5)) + ' ' + sldisp
     C                   endsl
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
     C                   eval      dsplyd = 0
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
     *
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      offlag = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
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
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C***                add       1             p
     C***                exsr      sfladd
     *
     *    Display is configured to display 1 overflow slot at a time.
     *
     C                   if        oplmts = 'Y'  and
     C                             slpick = 'N'  and
     C                             offlag = *off
     C                   eval      offlag = *on
     C                   eval      stop = *on
     C                   goto      endfwd
     C                   endif
     *
     C                   if        recno >= 3  and
     C                             #lline <> '16'  or
     C                             recno >= 8   and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   endif
     C                   endif
     C     endfwd        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *    Display is limited to one overflow location at a time.
     C                   if        offlag = *on
     C     dsplyd        add       1             goback
     C                   else
     C                   select
     C                   when      #lline = '16'
     C     dsplyd        add       10            goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     C                   endif
     C                   if        bot = '1'
     C                   if        goback = 3  and
     C                             #lline <> '16'  or
     C                             goback = 10  and
     C                             #lline = '16'
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   endif
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   if        dsplyd > 0
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   endif
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     c                   eval      optcnt = 0
720aAc                   eval      foundSlot = *off
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
720aDC*                  eval      *in85 = *off
720aAC                   eval      *in85 = *on

     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   readc     d16sflsp2                              79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   readc     d16sfl2                                79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   readc     dspsflsp2                              79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   readc     dspsfl2                                79
     C                   endsl

     C                   other

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   readc     d16sflsp                               79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   readc     d16sfl                                 79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   readc     dspsflsp                               79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   readc     dspsfl                                 79
     C                   endsl

     C                   endsl

     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
720aA*
720aA*  Set option one if slot matches w1disp
720aA*
720aAc                   if        sldisp = w1disp and w1disp<>*blanks
720aAc                   eval      option = ' 1'
720aAc                   eval      foundSlot = *on
720aAc                   else
720aA*  If not found check to see if the subfile slot is a virtual and
720aA*  the base matches the scanned slot.  If so mark as a one and move
720aA*  on
720aA /free
720aA          if w1disp<>*blanks;
720aA             chain ($iwhse:$iwhdp:sldisp) vSlot1;
720aA             if %found(vSlot1);
720aA                if w1disp = vspDis;
720aA                   option = ' 1';
720aA                   foundSlot = *on;
720aA                endif;
720aA             endif;
720aA          endif;
720aA /end-free
720aAc                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *    OR CLIENT/OPTION NOT ALLOWED.
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50 or
     C                             client <> cheney and
     C                             option = ' S'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C                   if        option = ' 1'
     C                   add       1             optcnt
     C*                  exsr      chkcnt
     C*                  if        optcnt >= 1
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
     C                   endif
     *
     *    Force SFLNXTCHG to be on each time.
     C                   eval      *in85 = *on


     *
     *    Pick slot not available for replenishment.
     *     If breakdown replenishment, allow pick slot to be used.
     *
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in85         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
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
720aA*
720aA*    Return error if scanned Pick Slot not found
720aA*    in subfile
720aA*
720aAC                   if        not foundSlot
720aAc                             and w1disp<>*blanks
720aAC                   eval      error = *on
720aAC                   eval      *in21 = *on
720aAC                   eval      *in85 = *on
720aAC                   eval      errmsg = 'Scanned Slot not valid'
720aAC                   exsr      zm0105
720aAC                   endif
720aAC                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        recno < 3  and
     C                             #lline <> '16'  or
     C*                            recno < 10  and
     C                             recno < 8   and
     C                             #lline = '16'
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
720aA*
720aA*   Force readc on all subfile records for this program.
720aA*   Will never have more than 3-5 pick slots
720aA*
720aAc                   eval      *in85 = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sflsp
     C                   write     d16sflsp2
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfl
     C                   write     d16sfl2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsflsp
     C                   write     dspsflsp2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfl
     C                   write     dspsfl2
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
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   write     d16sfcsp2
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc
     C                   write     d16sfc2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   write     dspsfcsp2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc
     C                   write     dspsfc2
     C                   endsl
     C                   eval      recno = 0
     C                   eval      w1disp = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   select
     C                   when      #lline = '16'
     C                   write     c16rec
     C                   other
     C                   write     cmdrec
     C                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   select
     C                   when      #lline = '16'
     C                   other
     C                   endsl
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   select
     C                   when      e$lng = 'SP' and #lline = '16'
     C                   write     po16nrsp
     C                   when      e$lng = 'SP'
     C                   write     postnrsp
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   write     po16nrec
     C                   other
     *
     *  IF CLIENT CHENEY, DISPLAY OPTION "S=Stuck Plt".
     *
     C                   if        client = cheney
     C                   seton                                        22
     C                   endif
     C                   write     postnrec
     C                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                             and dsplyd > 0
     *
     C                   if        dsplyd > 0
     C                   eval      *in81 = *on
     C                   else
     C                   eval      *in81 = *off
     C                   endif

     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     1             chain     d16sflsp2                          79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     1             chain     d16sfl2                            79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     1             chain     dspsflsp2                          79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     1             chain     dspsfl2                            79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp2
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl2
     C                   endsl
     C                   endif

     C                   other

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     1             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     1             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     1             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     1             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif

     C                   endsl

     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1

     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp2
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc2
     C                   endsl

     C                   other

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl

     C                   endsl
     *
     C                   select
     C                   when      e$lng = 'SP' and #lline = '16'
     C                   write     sc16resp
     C                   when      e$lng = 'SP'
     C                   write     scanresp
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   write     sc16rec
     C                   other
     C                   write     scanrec
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        dsplyd        x

     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp2                          79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl2                            79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp2                          79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     x             chain     dspsfl2                            79
     C                   endsl

     C                   other

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
     C                   endsl

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

720aAc*                  if        w1disp<>*blanks
720aAc                   eval      *in85 = *on
720aAc*                  endif
     C                   select
     C                   when      view = 2

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp2
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp2
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl2
     C                   endsl

     C                   other

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl

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
     C                   write     m16ctl
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
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
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
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   select
     C                   when      #lline = '16'
     C                   other
     C                   endsl
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
     C                   movel     descsp(1)     errmsg
     C                   other
     C                   eval      errmsg = desc(1)
     C                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR2007  Invalid slot, slot inactive.
     *
     C     zm2007        begsr
     C                   eval      #msgid = 'PIR2007'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr

     C                   if        *inki
     C                   eval      view += 1
     C                   if        view > 2
     C                   eval      view = 1
     C                   endif
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      rtvslt = '*NO '
     C                   eval      wwllp# = *blanks
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
     c                   if        #lline = '16'
     c                   eval      worow = 2
     c                   eval      wocol = 9
     c                   else
     c                   eval      worow = 1
     c                   eval      wocol = 29
     c                   endif
     C                   call      @apics
     C                   parm                    w1disp
     C*                  parm      1             worow
     C*                  parm      27            wocol
     C                   parm                    worow
     C                   parm                    wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck1
     C                   endif
     *
     *  Get scanned From slot.
     *
     C                   eval      rtvslt = '*YES'
     C                   exsr      zzgetfromsl
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm04
     C                   goto      endck1
     C                   endif
     *
     *  Verify that scanned/entered slot is not internal use slot.
     *
     C                   if        $sldesg = 'BFC'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm7101
     C                   goto      endck1
     C                   endif

     *  If slot was scanned,
     *  then get first fifo slot for item within the scanned slot.

     C                   if        scannedSlot
     C                   exsr      zzgetfromslv
     C                   if        fvslot <> *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endck1
     C                   endif
     C                   endif
     *
     C                   select
     *    Check only date sensitive items.
     C                   when      #fromitflgd = 'Y'  and
     C                             option = ' 1'  or
     *
     C                             #fromitflgd = 'Y'  and
     C                             option = '  '
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
     C                             frm$slot.$slexpd < tstdte  and
     C                             frm$slot.$slexpd > 0  or
     *
     *    Replenishment with expired product, warn user. Display msg.
     C                             oprpex = '3'  and
     C                             frm$slot.$slexpd < tstdte  and
     C                             frm$slot.$slexpd > 0
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

     **** Check only date sensitive items.
     *    Now, check all non-Low tracking items
     *      Check slot to see if taken out of FIFO date rotation.
     *    For Royal, check all items

     C                   when      client = cheney and
     C                             #fromitflgd = 'Y'

     C                             or client <> cheney
     C                   select

     C**                 when      #fromitflgd = 'Y'  and
     C                   when      #fromimltrk <> tLow and
     C                             option = ' 1'  and
     C                             oprpfi = '3'  and
     C                             error = *off  or
     *
     C**                           #fromitflgd = 'Y'  and
     C                             #fromimltrk <> tLow and
     C                             option = '  '  and
     C                             oprpfi = '3'  and
     C                             error = *off
     *
     C                             or client = royal
     C                             or client = FRF

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
     C                   endsl

     *
     *    Scanned slot not active. Not eligible for replenishment.
     C                   if        frm$slot.$slstat <> 'A '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm2007
     C                   goto      endck1
     C                   endif

           // Specific slot replenishments from the same slot not allowed.
      /free
       if (option = *blanks and $ihome = w1disp)
       or (option = '1' and $ihome = sldisp);
         cancel = *on;
         error  = *on;
         *in21  = *on;
         *in85  = *on;
         *in01  = *on;
         select;
         when e$lng = 'SP';
           errmsg = descsp(7);
         other;
           errmsg = desc(7);
         endsl;
         exsr zm0105;
       endif;
      /end-free

     *
     *     Slot not a replenishment slot for item.
     *     If breakdown replenishment, allow pick slot to be used.
     *
     C                   if        frm$slot.$slpick = 'Y'  and
     C                             #homeittype <> 'B'
     C                             and #homeittype <> ' '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   eval      *in01 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(3)     errmsg
     C                   other
     C                   eval      errmsg = desc(3)
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     *
     *     Available qty must be greater than zero.
     *
     C                   if        frm$slot.$slavl1 <= 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0110
     C                   endif

     *  Call program that will (if necessary) ...
     *    - Prompt user to pull pallet.
     *    - Have user verify license being pulled.
     *    - Update license information.
     *    - Do not prompt if slot change for repack item

     c                   if        not LT107_Repack
     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd   = '*PULDROP'
     C                   eval      $twhdp  = frm$slot.$slwhdp
     C                   eval      $tslot  = frm$slot.$sldisp
     C                   eval      $titem  = frm$slot.$slitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic# = frm$slot2.$saToLcns
     C                   exsr      zzzcall$lt210

     C                   select
     C                   when      $treturn = '*OK'
     C**                 eval      $pllp#  = $tlic#
     C                   If        frm$slot.$sldisp <> $tslot and
     C                             $tslot <> *blanks
     C                   Eval      frm$slot.$sldisp = $tslot
     C                   eval      $newlp# = $tlic#
     C                   Exsr      zzChgRpl
     C                   EndIf

     C                   when      $treturn = '*CANCEL'
     C                             or $treturn = '*SKIP'
     C                   eval      cancel = *on

     C                   when      $treturn = '*NOTFND'

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd   = '*PULRTN'
     C                   eval      $twhse  = frm$slot.$slwhse
     C                   eval      $twhdp  = frm$slot.$slwhdp
     C                   eval      $tslot  = frm$slot.$sldisp
     C                   eval      $titem  = frm$slot.$slitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic# = frm$slot2.$saToLcns
     C                   exsr      zzzcall$lt210

     C                   eval      cancel = *on

     C                   endsl
     c                   endif
     *
     C     endck1        endsr
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
     C***  filuky        chain     recordu                            79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
720aAc                   eval      *in80=*off
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
     C     *in79         cabeq     *on           endcase
     C**                 if        slstat = 'Z '  and
     C**                           slrsrv <> 'Y'  or
     *
     *    Omit all non-active slots.
     *      and some special license tracking slots.
     C                   if        slstat <> 'A '
     C                             or %subst(sldisp:1:3) = 'RCV'
     C                             or %subst(sldisp:1:3) = 'STG'
     C                             or %subst(sldisp:1:3) = 'OSS'
     C                             or %subst(sldisp:1:3) = 'USR'
     C                             or %subst(sldisp:1:3) = 'RTN'
730aAC                             or %subst(sldisp:1:3) = 'RWO'
     *
     C                   goto      try1
     C                   endif
     *
     *
     *    Omit all overflow slots.
     C                   if        slpick <> 'Y'
     *
     C                   goto      try1
     C                   endif
     *
     c     endcase       tag
      /free
        // now lets go get the pick slot for the breakdown item
        if *in79;
          clear $zoned;
          $zdwhseu = *on;
          $zdwhse  = $iwhse;
          $zdwhdpu = *on;
          $zdwhdp  = $iwhdp;
          $zdtsttruku = *on;
          $zdtsttruk = '!';
          $zdstrbpcku = *off;
          $zdstrbpck = ' ';
          $zdstrcpcku = *off;
          $zdstrcpck = ' ';
          $zdstrcitmu = *on;
          $zdstrcitm = $iitem;
          $zdstrbitmu = *off;
          $zdstrbitm = ' ';

          $dricommand = '*ZONED';
          $drisubcmd = '%STRZONE';
          $drisys2upd = 'D';
          exsr zzzdricop;
          if $drireturn = '*OK' and $zdstrbpck <> ' ';
            // load breakdown pick slot
            sldisp = $zdstrbpck;
            slitem = $zdstrbitm;
            exsr zzkeyf;
            exsr zzkeyU;
            P = P + 1;
            exsr sfladd;
          endif;
          if $drireturn = '*OK' and $zdstrcpck <> ' ';
            // load case pick slot
            sldisp = $zdstrcpck;
            slitem = $zdstrcitm;
            exsr zzkeyf;
            exsr zzkeyU;
            P = P + 1;
            exsr sfladd;
          else;
            clear $zoned;
            $zdwhseu = *on;
            $zdwhse  = $iwhse;
            $zdwhdpu = *on;
            $zdwhdp  = $iwhdp;
            $zdtsttruku = *on;
            $zdtsttruk = '!';
            $zdtsttruku = *on;
            $zdtsttruk = '!';
            $zdstrbpcku = *off;
            $zdstrbpck = ' ';
            $zdstrcitmu = *off;
            $zdstrcitm = ' ';
            $zdstrbitmu = *on;
            $zdstrbitm = slitem;

            $dricommand = '*ZONED';
            $drisubcmd = '%STRZONE';
            $drisys2upd = 'D';
            exsr zzzdricop;
            if $drireturn = '*OK' and $zdstrcpck <> ' ';
              // load breakdown pick slot
              sldisp = $zdstrcpck;
              slitem = $zdstrcitm;
              exsr zzkeyf;
              exsr zzkeyU;
              P = P + 1;
              exsr sfladd;
            endif;
          endif;
720bA     // If no picks were found in Store Staging Zone look in
720bA     // Warehouse
720bA     if p = 0;
720bA        setll ($iwhse:$iitem:'A':'Y') slot3;
720bA        reade ($iwhse:$iitem:'A':'Y') slot3;
720bA        dow not %eof(slot3);
720bA           // load breakdown pick slot
720bA           exsr zzkeyf;
720bA           exsr zzkeyU;
720bA           P = P + 1;
720bA           exsr sfladd;
720bA           reade ($iwhse:$iitem:'A':'Y') slot3;
720bA        enddo;
720bA     endif;

720aA     // hide scan slot field if Case and Breakdown shown
720aA     if p > 1;
720aA       *in80=*on;
720aA     endif;
          //return;
        endif;
      /end-free
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
     C**                 if        slstat = 'Z '  and
     C**                           slrsrv <> 'Y'  or
     *
     *    Omit all non-active slots.
     *      and some special license tracking slots.
     C                   if        slstat <> 'A '
     C                             or %subst(sldisp:1:3) = 'RCV'
     C                             or %subst(sldisp:1:3) = 'STG'
     C                             or %subst(sldisp:1:3) = 'OSS'
     C                             or %subst(sldisp:1:3) = 'USR'
     *
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
     C                   eval      w1disp = *blanks
     *   Change priority from negative to positive.
     *
     *   Default selection for first overflow
     *
     C                   if        client = glazier
     C                   if        slpick <> 'Y' and *in77 = *off
     C                   eval      w1disp = sldisp
     C                   eval      *in77  = *on
     C                   endif
     C                   endif
     *
     *   Expiration date
     *
     C*                  if        slexpd = 0
     C*                  else
     C*                  eval      $cvcmd = '*CMDMDY '
     C*                  move      slexpd        $cvd8i
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  endif
     *
     *   Entered date
     *
     C*                  if        slentd = 0
     C*                  else
     C*                  eval      $cvcmd = '*CMDMDY '
     C*                  move      slentd        $cvd8i
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  endif
     *
     *    Create a quantity string to print.
     *
     C*                  call      'SLOTQTY'
     C*                  parm                    slstk1
     C*                  parm                    slstk2
     C*                  parm                    slstk3
     *
     C*                  parm                    slalc1
     C*                  parm                    slalc2
     C*                  parm                    slalc3
     *
     C*                  parm                    sltfr1
     C*                  parm                    sltfr2
     C*                  parm                    sltfr3
     *
     C*                  parm                    slpck1
     C*                  parm                    slpck2
     C*                  parm                    slpck3
     *
     C*                  parm                    slrcv1
     C*                  parm                    slrcv2
     C*                  parm                    slrcv3
     *
     C*                  parm                    stock1            5 0
     C*                  parm                    stock2            3 0
     C*                  parm                    stock3            3 0
     *
     C*                  parm                    avail1            5 0
     C*                  parm                    avail2            3 0
     C*                  parm                    avail3            3 0
     *
     C*                  eval      $pcmd = '*QTY2STR'
     C*                  eval      $pqty1 = avail1
     C*                  eval      $pqty2 = avail2
     C*                  eval      $pqty3 = avail3
     C*                  eval      $pqstr = *blanks
     *
     C*                  call      'CVTQTY'
     C*                  parm                    $pcmd
     C*                  parm                    $pprg
     C*                  parm                    $pqty1            7 0
     C*                  parm                    $pqty2            7 0
     C*                  parm                    $pqty3            7 0
     C*                  parm                    $pum1             2
     C*                  parm                    $pum2             2
     C*                  parm                    $pum3             2
     C*                  parm                    $pqstr           10
     C*                  parm                    $pustr           17
     C*                  parm                    $prtn
     C*                  parm                    $perm
     *
     C*                  eval      w1qty = $pqstr

     *  Get license for slot

     C*                  exsr      clr$slot
     C*                  eval      $slwhseu = *on
     C*                  eval      $slwhse  = slwhse
     C*                  eval      $slwhdpu = *on
     C*                  eval      $slwhdp  = slwhdp
     C*                  eval      $sldispu = *on
     C*                  eval      $sldisp  = sldisp

     C*                  eval      $dricommand = '*SLOT'
     C*                  eval      $drisubcmd  = '%GET'
     C*                  eval      $drisys2upd = 'D'
     C*                  eval      chk4err = *on
     C*                  eval      zmsflag = *off
     C*                  exsr      zzzdricop
     C*                  if        drierr = *on
     C*                  else
     C*                  eval      w1ldspfull = $saToLcns
      /free
        //  licLen = %len(%trimr($saToLcns));
        //  select;
        //    when client = Cityline and #fromimltrk = thigh;
        //    other;
        //      if licLen > 3 and client = cityline
        //                    and #fromimltrk = tHigh or
        //         licLen > 3 and client = sgc
        //                    and #fromimltrk = tHigh or
        //         licLen > 3 and client = CoastalSunbelt
        //                    and #fromimltrk = tHigh or
        //         licLen > 3 and client = WestSide
        //                    and #fromimltrk = tHigh;
        //      else;
        //     endif;
        //  endsl;
      /end-free
     C
     C*                  endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETFROMIT   Get From slot item being replenished.
     *----------------------------------------------------------------

     C     zzgetfromit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #homeitwhse
     C                   if        #homeittype = 'B'
     C                   eval      $ititem  = #homeitmitem
     C                   else
     C                   eval      $ititem  = #homeititem
     C                   endif

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C*                  eval      zmsflag = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetfromit
     C                   endif

     C                   eval      #fromitwhse = $itwhse
     C                   eval      #fromititem = $ititem
     C                   eval      #fromittype = $ittype
     C                   eval      #fromitdesc = $itdesc
     C                   eval      #fromitpdsc = $itpdsc
     C                   eval      #fromitwhdp = $itwhdp
     C                   eval      #fromitstyp = $itstyp
     C                   eval      #fromitdesg = $itdesg
     C                   eval      #fromitum1  = $itum1
     C                   eval      #fromitflg1 = $itflg1
     C                   eval      #fromitum2  = $itum2
     C                   eval      #fromitumq2 = $itumq2
     C                   eval      #fromitflg2 = $itflg2
     C                   eval      #fromitum3  = $itum3
     C                   eval      #fromitumq3 = $itumq3
     C                   eval      #fromitnrpk = $imnrpk
     C                   eval      #fromitflgd = $itflgd
     C                   eval      #fromitcube = $itcube
     C                   eval      #fromitswgt = $itswgt
     C                   eval      #fromitcwgt = $itcwgt
     C                   eval      #fromitmitem = $itmitem
     C                   eval      #fromimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead

     C     endgetfromit  endsr

     *----------------------------------------------------------------
     *  ZZGETFROMSL   Get From slot.
     *----------------------------------------------------------------

     C     zzgetfromsl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $iWhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $iWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   goto      endgetfromsl
     C                   endif

     C                   eval      frm$slot = $slot
     C                   eval      frm$slot2 = $slot2

     C     endgetfromsl  endsr

     *----------------------------------------------------------------
     *  ZZGETFROMSLV  Get virtual From slot.
     *----------------------------------------------------------------

     C     zzgetfromslv  begsr
     C                   eval      fvslot = *off

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = #homeitwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #homeitwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #fromititem
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = 'A'
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = frm$slot.$slaisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = frm$slot.$slloc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = frm$slot.$slrlvl

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETITEMAV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   select
     C                   when      $drireturn = 'EOF'
     C                   eval      $drimessage = 'Virtual slot not found '
     C                                         + 'for item'
     C                   exsr      zm0001
     C                   goto      endgetfromslv
     C                   when      $drireturn <> '*OK'
     C                   exsr      zm0001
     C                   goto      endgetfromslv
     C                   endsl

     C                   eval      fvslot = *on
     C                   eval      w1disp = $sldisp

     C                   eval      frm$slot  = $slot
     C                   eval      frm$slot2 = $slot2

     C     endgetfromslv endsr

     *----------------------------------------------------------------
     *  ZZGETPICKIT   Get Pick slot (sent) item being replenished.
     *----------------------------------------------------------------

     C     zzgetpickit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $iWhse
     C                   eval      $ititem  = $iItem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgetpickit
     C                   endif

     C                   eval      #homeitwhse = $itwhse
     C                   eval      #homeititem = $ititem
     C                   eval      #homeittype = $ittype
     C                   eval      #homeitdesc = $itdesc
     C                   eval      #homeitpdsc = $itpdsc
     C                   eval      #homeitwhdp = $itwhdp
     C                   eval      #homeitstyp = $itstyp
     C                   eval      #homeitdesg = $itdesg
     C                   eval      #homeitum1  = $itum1
     C                   eval      #homeitflg1 = $itflg1
     C                   eval      #homeitum2  = $itum2
     C                   eval      #homeitumq2 = $itumq2
     C                   eval      #homeitflg2 = $itflg2
     C                   eval      #homeitum3  = $itum3
     C                   eval      #homeitumq3 = $itumq3
     C                   eval      #homeitnrpk = $imnrpk
     C                   eval      #homeitflgd = $itflgd
     C                   eval      #homeitcube = $itcube
     C                   eval      #homeitswgt = $itswgt
     C                   eval      #homeitcwgt = $itcwgt
     C                   eval      #homeitmitem = $itmitem
     C                   eval      #homeimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #homeititem
     C                   parm                    #homeitdesc
     C                   parm                    #homeitpdsc
     C                   parm      ' '           #homeithead

     C     endgetpickit  endsr

     *----------------------------------------------------------------
     *  ZZGETPICKSL   Get Pick slot.
     *----------------------------------------------------------------

     C     zzgetpicksl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $iWhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $iWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $iHome

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   goto      endgetpicksl
     C                   endif

     C                   eval      #homeslwhse = $slwhse
     C                   eval      #homeslwhdp = $slwhdp
     C                   eval      #homesldisp = $sldisp
     C                   eval      #homeslaisl = $slaisl
     C                   eval      #homeslloc  = $slloc
     C                   eval      #homeslrlvl = $slrlvl
     C                   eval      #homeslhand = $slhand

     C     endgetpicksl  endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      msgtyp = *blanks
     C                   eval      rtvslt = '*NO '
     *
     *  Define unique file key.
     *
     C*    filuky        klist
     C*                  kfld                    ukwhse
     C*                  kfld                    ukwhdp
     C*                  kfld                    ukdisp
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
     C                   kfld                    $iWhse
     C                   kfld                    kyitem
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
     C     slky3b        klist
     C                   kfld                    $iWhse
     C                   kfld                    $iItem
     C                   kfld                    keysta
     C                   kfld                    kypick
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    $iWhse
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
     C                   if        client = citywho
     C                   eval      cmdln1 = cmdcw(1)
     C                   Endif
     C                   endsl
     *
     *  Dummy read for compiler.
     *
     C                   if        0 = 1
     C                   read      sltrpex                                79
     C                   endif
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     C                   eval      currRoutine = 'zzinz2'
     C                   exsr      phpgmV1V2V3s
     C                   eval      view = 2
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
     C                   eval      kyitem = $iItem
     *
     *    Capture date/time user entered program to be used
     *    for starting transaction. This will more accurately
     *    reflect when the process started.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      trndte = $cvd8o
     C                   time                    trntim
     *
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
     C                   eval      lottrk = '*NO '
     C                   eval      lictrk = '*NO '
     *
     *   Get item description.
     *
     C                   eval      w1item = *blanks
     C                   eval      *in64 = *off
     C                   eval      scanhd = *blanks
     C                   eval      rplqty = *zeros
     C     $iItem        cat       '-':1         w1item
     C                   exsr      zzgetpickit
     C                   exsr      zzgetfromit
     *
     *    Get pick slot information
     C*                  exsr      zzgetpicksl
     *
     *    Breakdown item. Load base item into display.
     C                   if        #homeittype = 'B'
     C                   eval      scanhd = 'Brkdwn'
     C                   eval      *in64 = *on
     C                   eval      kyitem = #fromititem
     C                   eval      w1item = #fromititem
     C                   endif
     *
     C                   eval      w1item = %trim(w1item)
     C                                    + ' ' + #fromitdesc
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      today = $cvd8o
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   exsr      phpgmV1V2V3e
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKRT  Check if replenishment is pulled in FIFO order.
     *
     C     zzckrt        begsr
     *
     C                   eval      dspwin = '*NO '

     C                   exsr      clr$slot
     C                   eval      $slot = frm$slot
     C                   eval      $slot2 = frm$slot2
     C                   eval      $slwhseu = *on
     C                   eval      $slitemu = *on
     C                   eval      $slstatu = *on
     C                   eval      $slstypu = *on
     C                   eval      $slwhdpu = *on
     C                   eval      $sldispu = *on
     C                   eval      $slaislu = *on
     C                   eval      $slpsequ = *on
     C                   eval      $slrlvlu = *on
     C                   eval      $slhandu = *on
     C                   eval      $slprtyu = *on
     C                   eval      $slexpdu = *on
     C                   eval      $slentdu = *on

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CHKFIFO'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   If        $drireturn = 'NOTFIFO'
     C                   eval      dspwin = '*YES'
     C                   endif

     *

     C                   endsr
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
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record.
     C                   eval      exwhse = frm$slot.$slwhse
     *R                   MOVE $PWHDP    EXWHDP
     C                   eval      exwhdp = frm$slot.$slwhdp
     C                   eval      exstyp = frm$slot.$slstyp
     C                   eval      exitem = #homeititem
     C                   eval      extdis = $iHome
     *
     C                   if        frm$slot.$slstk1 > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   eval      exqty = frm$slot.$slstk1
     C                   endif
     *
     C                   eval      extask = 'REPL  '
     *    Update 'exception from slot' with virtual slot if it exists.
     C*                  if        fvslot = *on
     C*                  eval      exfdis = hldvsl
     C*                  else
     C                   eval      exfdis = frm$slot.$sldisp
     C*                  endif
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
     C                   eval      xsewhse = frm$slot.$slwhse
     C                   eval      xsewhdp = frm$slot.$slwhdp
     C                   eval      xsedisp = frm$slot.$sldisp
     C                   eval      xseitem = #homeititem
     *    Get todays date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      xseadte = $cvd8o
     C                   time                    xseatim
     C                   eval      xseaby = #user
     C                   write     serec                                76
     *
     C     endse         endsr
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
     C*                  clear                   ukwhdp
     C                   clear                   ukdisp
     C                   clear                   ukitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C*                  eval      ukwhse = slwhse
     C*                  eval      ukwhdp = slwhdp
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOUT    User flagged item as having no overflow product to
     *           replenish into pick slot.
     *
     C     zzout         begsr
     *
     *    Logic for SLOTOUT file moved to RU380.
     *    Change status of all Open Runner Flag entries to U=Out.
     C                   eval      $lcmd = '*CHG2OUT'
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $iWhse
     C                   eval      $lwhdp = $iWhdp
     C                   eval      $ldisp = $iHome
     C                   eval      $litm2 = $iItem
     *
     C                   call      'RU380'
     C                   parm                    $lparm
     *
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(6)     errmsg
     C                   other
     C                   eval      errmsg = desc(6)
     C                   endsl
     C                   exsr      zm0105
     *
     C     endout        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
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
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSLCT   Select a slot for replenishment.
     *
     C     zzslct        begsr
     *
     C                   eval      w1disp = ukdisp
     C                   exsr      zzchk1
     C     error         cabeq     *on           endslc
     C     cancel        cabeq     *on           endslc
     *
     *
     C                   exsr      zzstrt
     C                   eval      $iReturn = '*OK     '
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endslc        endsr
     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new transaction
     *
     C     zzstrt        begsr
     *
     C                   if        #homeittype = 'B'
     C                   eval      topick = 0
     C                   else
     * variable topick is set upon entry when user overrides repack
     * from slot.  We only move the quantity requested
     c                   if        not LT107_Repack
     C                   eval      topick = frm$slot.$slavl1
     c                   else
     c                   exsr      zzgetfromsl
     c                   goto      endstr
     c                   endif
     C                   endif
     *
     *  Set partial quantity flag.
     *
     *    These values were recalculated and sent back from
     *    the VFYTFOCHG command. If all of the original #FROM
     *    buckets were zero and the new Avail quantities are
     *    tero, then the entire quantity is being taken.
     *
     C                   if        frm$slot.$slalc1 > 0
     C                             or frm$slot.$slalc2 > 0
     C                             or frm$slot.$slalc3 > 0
     C                             or frm$slot.$slpck1 > 0
     C                             or frm$slot.$slpck2 > 0
     C                             or frm$slot.$slpck3 > 0
     c                             or LT107_Repack and
     c                                topick < frm$slot.$slavl1
     C                   eval      partial = *on
     C                   else
     C                   eval      partial = *off
     C                   endif

     *  License plate tracking item. Update to show in transit.
     *    - Only if not a Breakdown replenishment.

     C                   if        #homeittype <> 'B'

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PULTRAN'
     C                   eval      $tlic#    = frm$slot2.$saToLcns
     C                   eval      $tnewlic# = frm$slot2.$saToLcns
     C                   eval      $twhse    = $iwhse
     C                   eval      $titem    = #fromititem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tpartial = partial
     C                   eval      $tqty1    = topick
     C                   eval      $tqty2    = 0
     C                   eval      $tqty3    = 0
     C                   eval      $tnorm1   = topick
     C                   eval      $tnorm2   = 0
     C                   eval      $tnorm3   = 0
     C                   exsr      zzzcall$lt210

     C                   if        $treturn <> '*OK'
     C                   endif

     C                   endif
     *
     *     - Get new transaction number.
     *
     C                   call      'PIRTRN#'
     C                   parm                    curtrn#           7 0
     *
     *  Create label record.
     *
     C                   clear                   lbrec
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     *
     *  FROM Slot.
     *    - Only if not a Breakdown replenishment.
     *
     C                   if        #homeittype <> 'B'

     *  Update slot qty (Increase TFR qty)  **** Already got in ZZCHK1 ****
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = frm$slot.$slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = frm$slot.$slwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp = frm$slot.$sldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = frm$slot.$slitem
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem = #homeslitem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = topick
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   eval      $satrn#u = *on
     C                   eval      $satrn# = curtrn#
     C                   eval      $satasku = *on
     C                   if        #homeittype = 'B'
     C                   eval      $satask = 'REPLBK'
     C                   else
     C                   eval      $satask = 'REPL  '
     C                   endif

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RPL'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = $tinlic#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = $tslotpos
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'U'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'User'
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = $toutlic#
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = frm$slot2.$saOLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%TFR2USR'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   if        topick > 0
     C                   exsr      zzzdricop
     C                   endif

     C                   endif
     *
     *
     *
     *     - Get new batch number.
     *
     C                   call      'PIRBAT#'
     C                   parm                    batch#            7 0
     *
     *     - Create batch control record.
     *
     C                   eval      btbat# = batch#
     C                   eval      btwhse = slwhse
     C                   eval      bttype = '*REPLEN '
     C                   eval      btstat = *blanks
     C                   eval      btrte = *blanks
     C                   eval      btstrd = today
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
     *
     *  Create label record (initialized above)
     *
     C                   eval      lbwhse = frm$slot.$slwhse
     C                   eval      lbwhdp = frm$slot.$slwhdp
     C                   eval      lbaisl = frm$slot.$slaisl
     C                   eval      lbloc = frm$slot.$slloc
     C                   eval      lbrlvl = frm$slot.$slrlvl
     C                   eval      lbhand = frm$slot.$slhand
     C                   eval      lbdisp = frm$slot.$sldisp
     C                   eval      lbpseq = frm$slot.$slpseq
     C                   eval      lbstyp = frm$slot.$slstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbqavl = frm$slot.$slavl1
     *
     C                   eval      lbwhs2 = #homeslwhse
     C                   eval      lbwhd2 = #homeslwhdp
     C                   eval      lbasl2 = #homeslaisl
     C                   eval      lbloc2 = #homeslloc
     C                   eval      lblvl2 = #homeslrlvl
     C                   eval      lbhnd2 = #homeslhand
     C                   eval      lbdsp2 = #homesldisp
     *
     C                   eval      lbrte = *blanks
     C                   eval      lbitem = #homeititem
     C                   eval      lbpbat = batch#
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = #fromitum1
     *
     *  Quantity remaining field is used to contain break down
     *  quantity for broken case item.
     *
     C                   if        #homeittype = 'B'
     C                   eval      lbqrmn = topick * #fromitumq2
     C                   else
     C                   eval      lbqrmn = 0
     C                   endif
     C                   eval      lbqalc = topick
     C                   eval      lbqpck = topick
     *
     C                   if        #homeittype = 'B'  and
     C                             #fromitumq2 > 0
     C     #fromitcube   div       #fromitumq2   eacube
     C     #fromitswgt   div       #fromitumq2   easwgt
     C                   endif
     *
     C                   if        #homeittype = 'B'
     C                   eval      lbucub = eacube
     C                   else
     C                   eval      lbucub = #fromitcube
     C                   endif
     C     lbucub        mult      topick        lbcube
     C                   if        #homeittype = 'B'
     C                   eval      lbuwgt = easwgt
     C                   else
     C                   eval      lbuwgt = #fromitswgt
     C                   endif
     C     lbuwgt        mult      topick        lbswgt
     C                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
     C                   eval      lbgrp1 = 'L'
     C                   eval      lbgrp2 = ' '
     C                   eval      lbtype = 'R'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *  Create and start transaction.
     *
     C                   exsr      zztrncrtstart
     *
     *  Create workusr record
     *
     C                   exsr      zzwrtwrkusr
     *
     C     endstr        endsr

     *----------------------------------------------------------------
     *  ZZTRNCRTSTART  Create and Start transaction
     *----------------------------------------------------------------

     C     zztrncrtstart begsr

     C                   if        #homeittype = 'B'
     C                   eval      @ptask = 'REPLBK'
     C                   else
     C                   eval      @ptask = 'REPL  '
     C                   endif

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      lbwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      trndte        @pdate            8 0
     C                   parm      trntim        @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWARN   Display Error Message if slot has date/FIFO issues.
     *
     C     zzwarn        begsr
     C                   eval      wotxt1 = *blanks
     C                   eval      wotxt2 = *blanks
     C                   eval      wotxt3 = *blanks
     C                   eval      wotxt4 = *blanks
     C                   if        client = saval
     C                   eval      woyn = '(1/9)'
     C                   else
     C                   eval      woyn = '(Y/N)'
     C                   endif
     *
     *
     *    Load warning message into window text fields.
     C                   select
     C                   when      msgtyp = '*EXPIRED'
     *
     C                   eval      wkexpd = frm$slot.$slexpd
     C                   select
     *    User not allowed to select expired product.
     C                   when      oprpex = '2'
     *    Reply to message not allowed. (40=Off)
     C                   eval      *in40 = *off
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     msg101        wotxt1
     C                   movel     msg102        wotxt2
     C     msg103        cat       wkmm:1        wotxt3
     C                   other
     C                   movel     msg101e       wotxt1
     C                   movel     msg102e       wotxt2
     C     msg103e       cat       wkmm:1        wotxt3
     C                   endsl
     C     wotxt3        cat       '/':0         wotxt3
     C     wotxt3        cat       wkdd:0        wotxt3
     C     wotxt3        cat       '/':0         wotxt3
     C     wotxt3        cat       wkyy:0        wotxt3
     C     wotxt3        cat       '.':0         wotxt3
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     msg104        wotxt4
     C                   other
     C                   movel     msg104e       wotxt4
     C                   endsl
     *
     *    User must be warned when selecting expired product.
     C                   when      oprpex = '3'
     *    Reply to message allowed. (40=On)
     C                   eval      *in40 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     msg201        wotxt2
     C     msg202        cat       wkmm:1        wotxt3
     C                   other
     C                   movel     msg201e       wotxt2
     C     msg202e       cat       wkmm:1        wotxt3
     C                   endsl
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     msg301        wotxt2
     C                   movel     msg302        wotxt3
     C                   other
     C                   movel     msg301e       wotxt2
     C                   movel     msg302e       wotxt3
     C                   endsl
     *
     C                   endsl
     *
     C                   endsl
     *
     *    Display warning message to user.
     *
     C                   if        client = saval
     C                   eval      woyes = '9'
     C                   else
     C                   eval      woyes = 'N'
     C                   endif
     C                   dow       forevr = forevr
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     wdwmsgsp
     C                   other
     C                   exfmt     wdwmsg
     C                   endsl
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
     C                             or woyes = '1'
     C                   select
     C                   when      msgtyp = '*EXPIRED'
     C                   eval      exerid = 'SLTEXPD'
     C                   when      msgtyp = '*FIFO   '
     C                   eval      exerid = 'FIFOROT'
     C                   endsl
     *
     *    Write out exception record.
     C                   exsr      zzexcp
     *
     *    User chose to NOT to continue. Return to display.
     C                   when      woyes = 'N'
     C                             or woyes = '9'
     C                   eval      error = *on
     C                   eval      w1disp = *blanks
     C                   endsl
     *
     C                   leave
     *
     C                   endsl
     C                   enddo
     *
     C     endwrn        endsr

     *----------------------------------------------------------------
     *  ZZWRTWRKUSR   Write workusr record
     *----------------------------------------------------------------
     *
     C     zzwrtwrkusr   begsr

     C                   exsr      zzgetcurrstamp

     C                   eval      wurectype = 'RPL'
     C                   eval      wuscannbr = frm$slot2.$saToLcns
     C                   eval      wuscantype = 'P'
     C                   eval      wutrn#    = curtrn#
     C                   eval      wulbl#    = lblbl#
     C                   eval      wustat    = ' '
     C                   eval      wuwhse    = frm$slot.$slwhse

     C                   eval      wupulitem = frm$slot.$slitem
     C                   eval      wunewitem = #homeslitem

     C                   eval      wuremqty1 = topick
     C                   eval      wuremqty2 = 0
     C                   eval      wuremqty3 = 0

     C                   eval      wupullcns  = frm$slot2.$saToLcns
     C                   eval      wupulolcns = frm$slot2.$saOLcns
     C                   eval      wupulwhdp  = frm$slot.$slwhdp
     C                   eval      wupulbase  = frm$slot.$sacdsp
     C                   eval      wupuldisp  = frm$slot.$sldisp
     C                   eval      wupulaisl  = frm$slot.$slaisl
     C                   eval      wupulloc   = frm$slot.$slloc
     C                   eval      wupulrlvl  = frm$slot.$slrlvl
     C                   eval      wupulhand  = frm$slot.$slhand
     C                   eval      wupulcode  = 'S'
     C                   eval      wupularea  = 'Slot'
     C                   if        #homeittype = 'B'
     C                   eval      wupulpos   = 0
     C                   else
     C                   eval      wupulpos   = $tslotpos
     C                   endif
     C                   eval      wupulpseq  = frm$slot.$slpseq
     C                   eval      wupulside  = frm$slot.$slside
     C                   eval      wupulutype = lbutyp
     C                   if        #homeittype = 'B'
     C                   eval      wupulvfy   = ' '
     C                   else
     C                   eval      wupulvfy   = $saFrmEmpty
     C                   endif

     C                   if        #homeittype = 'B'
     C                   eval      wuusrlcns  = ' '
     C                   eval      wuusrwhdp  = ' '
     C                   eval      wuusrdisp  = ' '
     C                   else
     C                   eval      wuusrlcns  = $saToLcns
     C                   eval      wuusrwhdp  = $slwhdp
     C                   eval      wuusrdisp  = $sldisp
     C                   endif

     C                   eval      wupckwhdp  = #homeslwhdp
     C                   eval      wupckdisp  = #homesldisp
     C                   eval      wupckaisl  = ' '
     C                   eval      wupckloc   = 0
     C                   eval      wupckrlvl  = 0
     C                   eval      wupckhand  = ' '
     C                   eval      wupckcode  = 'S'
     C                   eval      wupckarea  = 'Slot'
     C                   eval      wupckpos   = 0
     C                   eval      wupckpseq  = 0
     C                   eval      wupckside  = 0
     C                   eval      wupckutype = ' '

     C                   eval      wurtnhome  = ' '
     C                   if        #homeittype = 'B'
     C                   eval      wurpltype  = 'B'
     C                   else
     C                   eval      wurpltype  = ' '
     C                   endif

     C                   eval      wuaddts  = currstampsys
     C                   eval      wuadduc  = currstampuc
     C                   eval      wuaddpgm = #pgm
     C                   eval      wuaddemp = e$emp#
     C                   eval      wuaddeusr = #curruser
     C                   eval      wuaddjusr = #user
     C                   eval      wuaddjob = #job
     C                   eval      wuaddnbr = #jobnbr

     C                   write     wurec

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
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
     C                   eval      $saemp# = e$emp#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slotdef  Clear $slotdef data structure fields
     *----------------------------------------------------------------

     C     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*ZONED'
     C                   eval      $dridata = $zoned
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
     C                   eval      drierr = *on
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
     C                   eval      drierr = *on
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
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*ZONED'
     C                   eval      $zoned = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzChgRpl     -  User changed replenishment in LT210
     *----------------------------------------------------------------

      /free
       begsr zzChgRpl;
         Exsr clr$slot;
         Eval $slwhseu = *on;
         Eval $slwhse  = frm$slot.$slwhse;
         Eval $slwhdpu = *on;
         Eval $slwhdp  = frm$slot.$slwhdp;
         Eval $sldispu = *on;
         Eval $sldisp  = frm$slot.$sldisp;
         Eval $dricommand = '*SLOT';
         Eval $drisubcmd  = '%GET';
         Eval $drisys2upd = 'D';
         Exsr zzzdricop;
         Eval frm$slot=$slot;
         Eval frm$slot2=$slot2;
       endsr;
      /end-free

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
     *  ZZZCALL$LT210  -  Call LT210 program.
     *----------------------------------------------------------------

     C     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'RPL'         $ttype
     C                   parm      'Replenish'   $thead
     C                   parm      $iWhse        $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm                    $templ#
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
     *----------------------------------------------------------------
     *  Phrase Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  pushRoutine  -  Add routine to stack
     *----------------------------------------------------------------

      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  popRoutine  -  Remove routine from stack
     *----------------------------------------------------------------

      /free
       begsr popRoutine;

         for i = 1 to stackCount-1;
           eval aRoutine(i) = aRoutine(i+1);
         endfor;

         aRoutine(stackCount) = ' ';
         stackCount -= 1;
         currRoutine = aRoutine(1);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phClearVars  - Clear phrase variables
     *----------------------------------------------------------------

      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  zzWrtPhrase  - Write logging phrase
     *----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

         pWhse = 0;
         pEmp# = e$emp#;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = ' ';
         pWhdp = ' ';
         pLocation = ' ';
         pTrn# = 0;
         pLcns = ' ';
         pLtrn = 0;

      /end-free
     C                   call      'WRTPHRASE'
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5
      /free

         if %error;
           eval error = error;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phV2onV1
     *----------------------------------------------------------------

      /free
       begsr phV2onV1;

         pPhraseId = V2onV1;

         exsr phClearVars;
         v1 = nxtscr;

         select;
           when status = rollup;
             v2 = 'PageDn';
           when status = rolldn;
             v2 = 'PageUp';
           when status = comand;
             select;
               when *inka;
                 v2 = 'F1';
               when *inkb;
                 v2 = 'F2';
               when *inkc;
                 v2 = 'F3';
               when *inkd;
                 v2 = 'F4';
               when *inke;
                 v2 = 'F5';
               when *inkf;
                 v2 = 'F6';
               when *inkg;
                 v2 = 'F7';
               when *inkh;
                 v2 = 'F8';
               when *inki;
                 v2 = 'F9';
               when *inkj;
                 v2 = 'F10';
               when *inkk;
                 v2 = 'F11';
               when *inkl;
                 v2 = 'F12';
               when *inkm;
                 v2 = 'F13';
               when *inkn;
                 v2 = 'F14';
               when *inkp;
                 v2 = 'F15';
               when *inkq;
                 v2 = 'F16';
               when *inkr;
                 v2 = 'F17';
               when *inks;
                 v2 = 'F18';
               when *inkt;
                 v2 = 'F19';
               when *inku;
                 v2 = 'F20';
               when *inkv;
                 v2 = 'F21';
               when *inkw;
                 v2 = 'F22';
               when *inkx;
                 v2 = 'F23';
               when *inky;
                 v2 = 'F24';
               other;
                 v2 = 'Unknown Command Key';
             endsl;
           other;
             v2 = 'ENTER';
         endsl;

         exsr phWrtPhrase;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phScrV1pgmV2
     *----------------------------------------------------------------

      /free
       begsr phScrV1pgmV2;

         pPhraseId = scrV1pgmV2;

         exsr phClearVars;

         v1 = nxtscr;
         select;
           when nxtscr <> lastnxtscr;
             v2 = 'displayed';
           when error = *on;
             v2 = 'redisplayed with error';
           when warn = *on;
             v2 = 'redisplayed with warning';
           other;
             v2 = 'redisplayed';
         endsl;
         lastnxtscr = nxtscr;

         exsr phWrtPhrase;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phPgmV1V2V3e
     *----------------------------------------------------------------

      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phPgmV1V2V3s
     *----------------------------------------------------------------

      /free
       begsr phPgmV1V2V3s;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'Start';

         exsr phWrtPhrase;

         exsr pushRoutine;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 9
**  OPTLN - Option display line
  1=Select  9=View Slot Quantities
**  CMDLN - Command display line
F11=Tfr  F3/F12=Exit
**  CMDCW - Command display line
F11=Tfr F5=Refresh F3/F12=Exit
**  DESC - Description
Available Quantity
Verify Zero
Pick slot not allowed for replenishment.
1=Select can be used only once.
Slot error logged for slot:
Item flagged as Out.
Replenish from same slot not allowed.
**  OPTLSP - Option display line
  1=Seleccionar  9=Ver cantidades de slot
**  CMDLSP - Command display line
F3/F12=Salir F5=Refrescar
**  DESCSP - Description
Cantidad Disponible
Verifique nada
No permite pick slot por reaprovisionamiento
Puede usar 1=Seleccionar solamente una vez
Archivo` error de slot:
Producto marcado como vacio
Reponer a partir misma ranura no permitido
