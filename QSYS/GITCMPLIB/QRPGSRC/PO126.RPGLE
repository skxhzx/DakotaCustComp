     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO126     PO Pallet Estimate - Display
     *  10 April, 2006
     *  Roxanne Harrison
     *
     *  SK110 - 1.01
     *
     *  NOTE:  Program uses LOAD ALL method for subfile.
     *
     *  Revisions
     *
416 A*    04/11/06  RH   5.00
     *      - Created using PO120, no option field
     *      - Left unused code for future use.
510aA*    05/08/06  HNK  5.10a
     *      - Fix: Divide only if putqty>0
510b  *    12/06/06  RH   5.10b
     *      - Enh: Remove BFCADR, no longer used.
510cA*    10/23/07  LMC  5.10c
     *      - Fix: Divide only if putqty>0  this code needed to be
     *        in two places, was only in one.
650a *    01/24/13  GJA  6.50a
     *      - Fix: Round up pallet.
700aA*    11/03/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERISPLAY)
     *  40        Condition heading for Super P/O.
     *  41        Condition heading for Super P/O window.
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpo126fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsfl1:recno)
     F                                     sfile(dspsfl2:recno)
     F                                     sfile(dspsfl3:recno)
     F                                     sfile(dspsfl4:recno4)
     F                                     sfile(dspsfl5:recno4)
     F                                     sfile(dspsfl6:recno4)
     F***                                  sfile(dspsfl7:recno4)
     F***                                  sfile(dspsfl8:recno4)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec4:msgk4)
     Fworkopt   uf a e           k disk
     Fitemdef   if   e           k disk
     Fitemdsc   if   e           k disk
     Fitemlnk   if   e           k disk
417a Fitemmsc   if   e           k disk
     Foptions   if   e           k disk
     Foptiond   if   e           k disk
     Fpiritem   if   e           k disk
     Fpodtl     if   e           k disk
     Fpodtl1    if   e           k disk
     F                                     rename(pdrec:record)
     Fpodtl2    if   e           k disk
     F                                     rename(pdrec:record2)
     Fpodtl3    if   e           k disk
     F                                     rename(pdjrec:ptouch)
     Fpohdr     uf   e           k disk
     Fporcv     uf a e           k disk
     Fpospo3    if   e           k disk
     Fpo120a    if   e           k disk    usropn
     Fpo120b    if   e           k disk    usropn
     Fpo120c    if   e           k disk    usropn
     F                                     infds(ocinf)
     Fpo120d    if   e           k disk    usropn
     F                                     infds(odinf)
     Fslot3     if   e           k disk
     Fupc       if   e           k disk
     Fwarehs    if   e           k disk
416FAFdeptdsg   if   e           k disk
417aAFpospo     if   e           k disk
417cAFitmexcp2  if   e           k disk
     F                                     rename(exrec:xrec2)
417aAFitmexcp   o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D a80             s              1    dim(80)
     D fkey            s             50    dim(2000)
     D ukey            s             50    dim(2000)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
417eMD zopt4           s              2    dim(1) ctdata perrcd(1)
417eD*                   ZOPT4   2   2  2
417AD*                   ZOPT4   1   1  2
417eAD zopt6           s              2    dim(2) ctdata perrcd(2)
     D optln           s             75    dim(4) ctdata perrcd(1)
     D optlns          s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(9) ctdata perrcd(1)
     D ovr             s             80    dim(4) ctdata perrcd(1)
     D qry1            s             80    dim(5) ctdata perrcd(1)
     D qry2            s             80    dim(5) ctdata perrcd(1)
     D qry3            s             80    dim(6) ctdata perrcd(1)
     D qry4            s             80    dim(6) ctdata perrcd(1)
     D cls1            s             80    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $whsea                 1      3
     D  $kpo                   4     12
     D  $kspo                 13     21
     D  $spo                  47     50
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  pdwhse                 1      3  0 inz(0)
     D  pdpo                   4     12
     D  pdseq                 13     17  0 inz(0)
     D  pditem                18     32
     D  pdvitm                33     47
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
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117
     *
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
     D  $lpo                  22     30
     D  $lseq                 31     35  0
     D  $litem                36     50
     *
     D  $litm                 22     36
     D  $lxflg                37     37
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
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('PO122')
     D @delpg          c                   const('PO124')
     D @prtpg          c                   const('NONE')
     *----------------------------------------------------------------
     *  Window Titles.
     *
     D titl01          c                   const('Select Purchase Orde-
     D                                     r')
     D titl02          c                   const('Display Purchase Ord-
     D                                     er Totals')
     D titl03          c                   const('Position To Item Num-
     D                                     ber')
     D titl04          c                   const('Position To Manufact-
     D                                     urer Number')
     D titl05          c                   const('Select item for UPC -
     D                                                ')
     D hdr01           c                   const('Item Number')
     D hdr02           c                   const('Mfr Number')
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
     D  $pwhse                19     21  0
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
     D  $pvitm                51     65
417dA*----------------------------------------------------------------
417dA*  Redefinition data structures
417dA*
417dAD                 ds
417dAD  dsupc                  1     20
417dAD  dsfdis                 1     12
417dAD  dstdis                13     24
     *----------------------------------------------------------------
     D $cvtdt          ds
417a *                                       1   8 $CVDOP
417a *                                       9  140$CVDD6
417a *                                      15  220$CVDD8
417a D  $cvcmd                 1      8
417a D  $cvprg                 9     18
417a D  $cvd6i                19     24
417a D  $cvd8i                25     32
417a D  $cvd6o                33     38  0
417a D  $cvd8o                39     46  0
417a D  $cvsto                47     64
417a D  $cvrtn                65     72
417a D  $cverm                73    132
417a D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
416cA*
416cAD  erp2tp                 1      4
416cAD  erspo                  5     13
416cAD  erp2vl                14     28
416cA*
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Error Message(s)
     *
     D err01           c                   const('1=Select can only be-
     D                                      used once.')
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Query file INFDS data structure
     *
     D ocinf           ds
     D  totrcc               316    319b 0
     D odinf           ds
     D  totrcd               316    319b 0
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Variables
     *

     D $code           s             10
     D $crew           s              6
     D $emp#           s              5  0
     D $fnam           s             15
     D $init           s              1
     D $lmput          s              1
     D $lnam           s             20
     D $msgf           s             10
     D $nhrs           s             31
     D $shft           s              6
     D $styp           s              1
     D $swhse          s              3  0
     D $whdp           s              5
     D $whse           s              3  0
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D bsitem          s             15
     D bspick          s              1
     D bsstat          s              2
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D doex            s              1
     D done            s              1
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D first           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D full            s              1
     D goback          s              2  0
     D help            s              5  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kyerid          s                   like(exerid)
     D kyesta          s                   like(exesta)
     D kyitem          s                   like(exitem)
     D kytask          s                   like(extask)
     D maxvwo          s              1  0
     D msgk            s              4  0
     D msgk4           s              4  0
     D n               s              3  0
     D nomore          s              1
     D noupc           s              1
     D noxflg          s              1
     D nr              s              2  0
     D nrslct          s              3  0
     D nxtscr          s              3
     D ocode           s              8
     D open1           s              1
     D open2           s              1
     D optslt          s              1
     D otaken          s              1
     D ovrtyp          s              8
     D p               s              2  0
     D pagcmd          s              8
     D part            s              1
650aAD partplt         s              3  0
     D prcrec          s              2  0
     D putplt          s              3  0
650aDD*** putqty          s              3  0
650aMD putqty          s              6  0
     D prtupc          s              1
     D puttyp          s              1
     D recno           s              4  0
     D recno4          s              5  0
     D recv            s              1
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D savpo           s                   like(pdpo)
     D sclear          s              1
     D stop            s              1
     D svhi            s              2  0
     D svitem          s             15
     D svmput          s              1
     D svpo            s                   like(pdpo)
     D svp2po          s                   like(pdpo)
     D svp2vl          s                   like(pditem)
     D svtie           s              4  0
     D today           s              8  0
     D top             s              1
     D totplt          s              4  0
     D touch           s              1
     D tqyor1          s              7  0
     D tqyrc1          s              7  0
     D ttlrcd          s             11  0
     D upcctr          s              3  0
     D upcok           s              1
     D uxflag          s              1
     D v               s              2  0
     D view            s              8
     D viewo           s              1  0
     D warn            s              1
     D woitm#          s             15
     D woupc           s             20
     D wrkdte          s              6  0
     D w1upc           s                   like(upupc)
     D x               s              3  0
     D y               s              3  0
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
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
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
510b C*                  call      'BFCADR'
510b C*                  parm                    $rtn              8
510b C*                  if        $rtn = '*EXPIRED'
510b C*                  eval      nxtscr = 'EOJ'
510b C*                  eval      $rtncd = '*EXIT   '
510b C*                  else
     C                   exsr      zzinz2
510bDC*                  endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
     C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
     *
     *    If processing a Super P/O, update Super P/O status on exit.
     C                   if        $spo = '*YES'
     C                   exsr      zzuhdr
     C                   endif
     C                   seton                                        lr
     C                   endif
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       klki
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   select
     C                   when      nxtscr = '01 '
     C                   select
     *
     *    Single line display and NOT a Super P/O.
     C                   when      uxflag = *off  and
     C                             $spo = '*NO '
     *
     C                   select
     C                   when      view = '*POITEM '
     *
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     *
     C                   when      view = '*POMFR  '
     C                   exsr      sflds2
     C                   read      postnrc2                               50
     C                   read      scanrec2                               50
     C                   endsl
     *
     C                   other
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   exsr      sflds1
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     *
     C                   when      view = '*POMFR  '
     C                   exsr      sflds3
     C                   read      postnrc2                               50
     C                   read      scanrec2                               50
     C                   endsl
     *
     C                   endsl
     *
     C                   when      nxtscr = '02 '
     C                   exsr      deldsp
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     C                   when      uxflag = *off  and
     C                             $spo = '*NO '
     C                   select
     C                   when      view = '*POITEM '
     C                   read      dspsfc                                 50
     *
     C                   when      view = '*POMFR  '
     C                   read      dspsfc2                                50
     *
     C                   endsl
     *
     C                   other
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   read      dspsfc1                                50
     *
     C                   when      view = '*POMFR  '
     C                   read      dspsfc3                                50
     *
     C                   endsl
     C                   endsl
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
     *    Initialize total estimate pallet field.
500  C***                eval      totplt = 0
     *
     *    If this is a Super P/O, then condition heading on TITLE fmt.
     C                   if        $spo = '*YES'
     C                   eval      *in40 = *on
     C                   else
     C                   eval      *in40 = *off
     C                   endif
     *
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
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
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
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
     C                   exsr      zmims4
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     C                   write     dspsfl1                              79
     C                   write     dspsfl2                              79
     C                   write     dspsfl3                              79
     C                   eval      recno4 = 1
     C                   write     dspsfl4                              79
     C                   write     dspsfl5                              79
417k C***                write     dspsfl7                              79
417l C***                write     dspsfl8                              79
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD11 - Un-touched or ALL
     *
     C                   if        *inkk
     C                   if        noxflg = *on
     C                   eval      noxflg = *off
     C                   else
     C                   eval      noxflg = *on
     C                   endif
     C                   if        view = '*POITEM '
     C                   select
     C                   when      $spo = '*NO '
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(1)
     C                   else
     C                   eval      cmdln1 = cmdln(6)
     C                   endif
     C                   when      $spo = '*YES'
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(3)
     C                   else
     C                   eval      cmdln1 = cmdln(8)
     C                   endif
     C                   endsl
     C                   endif
     *
     C                   if        view = '*POMFR  '
     C                   select
     C                   when      $spo = '*NO '
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(2)
     C                   else
     C                   eval      cmdln1 = cmdln(7)
     C                   endif
     C                   when      $spo = '*YES'
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(4)
     C                   else
     C                   eval      cmdln1 = cmdln(9)
     C                   endif
     C                   endsl
     C                   endif
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   exsr      pag01
     C                   endif
     *
     *
     *  TEST FOR CMD9 - Change view.
     *
     C                   if        *inki
     *
     C                   select
     C                   when      view = '*POITEM '
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*POMFR  '
     C                   if        $spo = '*YES'
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     C                   endif
     *
     C                   eval      view = '*POMFR  '
     C                   select
     C                   when      $spo = '*NO '
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(2)
     C                   else
     C                   eval      cmdln1 = cmdln(7)
     C                   endif
     C                   when      $spo = '*YES'
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(4)
     C                   else
     C                   eval      cmdln1 = cmdln(9)
     C                   endif
     C                   endsl
     C                   eval      pagcmd = '*REFRESH'
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   exsr      pag01
     *
     C                   when      view = '*POMFR  '
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*POITEM '
     C                   if        $spo = '*YES'
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     C                   endif
     *
     C                   eval      view = '*POITEM '
     C                   select
     C                   when      $spo = '*NO '
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(1)
     C                   else
     C                   eval      cmdln1 = cmdln(6)
     C                   endif
     C                   when      $spo = '*YES'
     C                   if        noxflg = *off
     C                   eval      cmdln1 = cmdln(3)
     C                   else
     C                   eval      cmdln1 = cmdln(8)
     C                   endif
     C                   endsl
     C                   eval      pagcmd = '*REFRESH'
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   exsr      pag01
     *
     C                   endsl
     *
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C                   if        uxflag = *off  and
     C                             $spo = '*NO '
     C                   select
     C                   when      view = '*POITEM '
     *
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C                   enddo
     *
     C                   when      view = '*POMFR  '
     *
     C     1             do        10            x
     C     x             chain     dspsfl2                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl2
     C                   endif
     C                   enddo
     *
     C                   endsl
     *
     C                   else
     *
     C                   select
     C                   when      view = '*POITEM '
     *
     C     1             do        05            x
     C     x             chain     dspsfl1                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl1
     C                   endif
     C                   enddo
     *
     C                   when      view = '*POMFR  '
     *
     C     1             do        05            x
     C     x             chain     dspsfl3                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl3
     C                   endif
     C                   enddo
     *
     C                   endsl
     C                   endif
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     *on           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
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
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
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
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     *R                   SUB  10        ROW#
     C                   sub       prcrec        row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
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
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   eval      nr = prcrec
     C                   add       1             nr
     *R         RECNO     IFLT 11
     C                   if        recno < nr
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       DELADE
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
     C                   if        uxflag = '0'
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl
     C                   when      view = '*POMFR  '
     C                   write     dspsfl2
     C                   endsl
     C                   else
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl1
     C                   when      view = '*POMFR  '
     C                   write     dspsfl3
     C                   endsl
     C                   endif
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
     C                   if        uxflag = '0'
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc
     C                   when      view = '*POMFR  '
     C                   write     dspsfl2
     C                   endsl
     C                   else
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc1
     C                   when      view = '*POITEM '
     C                   write     dspsfc1
     C                   endsl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     *on           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     error         cabeq     *on           ent01e
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  CHECK IF UPC CODE WAS ENTERED.
     *
417bD*R         W1UPC     IFNE *BLANKS
417bMC                   if        w1upcd <> *blanks
     C                   exsr      zzchk1
     C     error         cabeq     *on           ent01e
417h C     optslt        cabeq     *off          ent01e
     C                   eval      $puky = dsukey
     C*                  exsr      zzchek
     C*    error         cabeq     *on           ent01e
     C*                  exsr      zzrcv
     *  Position to selected UPC code item.
     C                   eval      refrsh = *on
     C                   eval      repos = *on
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ *OFF
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
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
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
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
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
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
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
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
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C     fileky        setll     record
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C     filky2        setll     record2
     *
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C     filky3        setll     oqreca
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C     filky4        setll     oqrecb
     *
     C                   endsl
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
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
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
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
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
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     C                   else
     C                   exsr      zzopt
     C                   endif
     C                   endif
     C                   endif
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
     *R         CLERR     CABEQ*ON       PAG01E
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
     *R         CLERR     CABEQ*ON       PAG01E
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
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     C                   eval      savpo = *blanks
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     *R         P         IFGE 10
     C                   if        p >= prcrec
500  C***                eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
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
     C     top           cabeq     *on           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *R         DSPLYD    ADD  10        GOBACK  20
     C     dsplyd        add       prcrec        goback
     C                   if        bot = *on
     *R         GOBACK    IFEQ 10
     C                   if        goback = prcrec
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
     C                   dou       stop = *on
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
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     *R         P         IFGE 10
     C                   if        p >= prcrec
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
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *R         DSPLYD    ADD  10        GOBACK  20
     C     dsplyd        add       prcrec        goback
     C                   if        bot = *on
     C     wkoprt        setgt     workopt
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
     *  READ FILE
     *
     C                   dou       stop = *on
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
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
     C     endb2         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   eval      woyes = 'N'
     C                   dou       nomore = *on
     C                   eval      *in21 = *off
     C                   if        uxflag = '0'
     C                   select
     C                   when      view = '*POITEM '
     C                   readc     dspsfl                                 79
     C                   when      view = '*POMFR  '
     C                   readc     dspsfl2                                79
     C                   endsl
     C                   else
     C                   select
     C                   when      view = '*POITEM '
     C                   readc     dspsfl1                                79
     C                   when      view = '*POMFR  '
     C                   readc     dspsfl3                                79
     C                   endsl
     C                   endif
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
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
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
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
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     *
     *    Single line descriptions in use and not a Super P/O.
     C                   if        uxflag = *off  and
     C                             $spo = '*NO '
     *
500  C*                  if        recno < 11
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
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfl2
     *
     C                   endsl
500  C*                  endif
     C                   endif
     *
     *  Use extended description or this is a Super P/O.
     *
     C                   if        uxflag = *on
     C**                 if        recno < 6
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
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfl1
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfl3
     *
     C                   endsl
500  C**                 endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLAD4   Add record to Window subfile 4
     *
     C     sflad4        begsr
     *
     C                   eval      hseq = pdseq
     C                   eval      hitem = pditem
     C                   eval      hvitm = pdvitm
     C                   add       1             recno4
     C                   write     dspsfl4
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLAD5   Add record to Window subfile 5
     *
     C     sflad5        begsr
     *
     C                   add       1             recno4
     C                   write     dspsfl5
     *
     C                   endsr
417a *----------------------------------------------------------------
417a *
417a *  SFLAD6   Add record to Window subfile 6
417a *
417a C     sflad6        begsr
417a *
417a C                   add       1             recno4
417a C                   write     dspsfl6
417a *
417a C                   endsr
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
     C                   when      uxflag = *off  and
     C                             $spo = '*NO '
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfc2
     *
     C                   endsl
     *
     C                   other
     *
     C                   select
     C                   when      view = '*POITEM '
     C                   write     dspsfc1
     *
     C                   when      view = '*POMFR  '
     C                   write     dspsfc3
     *
     C                   endsl
     C                   endsl
     *
     C                   eval      recno = 0
     *    Initialize total estimate pallet field.
     C                   eval      totplt = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile , Item seq - Single line description.
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     C                   write     scanrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDS1   Display subfile 1 , Item Seq - Extended description.
     *
     C     sflds1        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     C                   write     scanrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflop1
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl1                            79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl1
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDS2   Display subfile 2 - Mfr# Seq - Single line desc.
     *
     C     sflds2        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrc2
     C                   write     scanrec2
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflop2
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
417nD*R         1         CHAINDSPSFL               79
417nMC     1             chain     dspsfl2                            79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl2
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDS3   Display subfile 3 , Mfr# Seq. Extended description
     *
     C     sflds3        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrc2
     C                   write     scanrec2
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflop3
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C     1             chain     dspsfl3                            79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl3
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc3
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        prcrec        x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOP1   Initialize options for subfile 1, extended description
     *
     C     sflop1        begsr
     C     1             do        05            x
     C     x             chain     dspsfl1                            79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl1
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOP2   Initialize options for subfile 2 - Single line Mfr seq.
     *
     C     sflop2        begsr
     C     1             do        prcrec        x
     C     x             chain     dspsfl2                            79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl2
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOP3   Initialize options for subfile 3, ext. desc. Mfr# Seq.
     *
     C     sflop3        begsr
     C     1             do        05            x
     C     x             chain     dspsfl3                            79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl3
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
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCMS4  Clear message record subfile in WINDOW4
     *
     C     zmcms4        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl4
     C                   eval      msgk4 = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpms4
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMDMS4  Display message record subfile in WINDOW4
     *
     C     zmdms4        begsr
     C                   write     msgclr4
     C                   eval      *in97 = *on
     C                   if        msgk4 > 0
     C                   write     msgctl4
     C                   eval      msgk4 = *zeros
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
     *    ZMIMS4  Initialization necessary for message subfile in WINDOW4
     *
     C     zmims4        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcms4
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMPMS4  Add message record to subfile in WINDOW4
     *
     C     zmpms4        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk4
     C                   write     msgrec4
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
     *    ZMQMS4  Add message record to subfile from pgm queue in WINDOW4
     *
     C     zmqms4        begsr
     C                   add       1             msgk4
     C                   write     msgrec4
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
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
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
416cA*----------------------------------------------------------------
416cA*    PO13236  Position to x not found on Super P/O.
416cA*
416cAC     zm3236        begsr
416cAC                   eval      #msgid = 'PO13236'
416cAC                   eval      #msgtp = '*DIAG  '
416cAC                   movea     errmsg        $md(1)
416cAC                   exsr      zmpmsg
416cAC                   endsr
     *----------------------------------------------------------------
     *    PO20027  Item not on PO.
     *
     C     zm027         begsr
     C                   eval      #msgid = 'PO20027'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20029  UPC not on file.
     *
     C     zm029         begsr
     C                   eval      #msgid = 'PO20029'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT12001  Item does not have a link record.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IT12001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT12212  Item does not have a Piritem record.
     *
     C     zm2212        begsr
     C                   eval      #msgid = 'IT12212'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT12002  Item does not have a pick slot.
     *
     C     zm1202        begsr
     C                   eval      #msgid = 'IT12002'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
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
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
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
     *
     C     z40105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpms4
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
     *    Error message for WINDOW4.
     C     z40108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpms4
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  TEST FOR CMD07 - Sub totals.
     *
     *
     *  TEST FOR CMD08 - Item Sub totals.
     *
     *
     *  TEST FOR CMD23 - More options
     *
     C                   if        *inkx
     C                   if        viewo = maxvwo
     C                   eval      viewo = 1
     C                   else
     C                   add       1             viewo
     C                   endif
     C                   eval      v = viewo * 2
     C                   eval      optln2 = optln(v)
     C                   eval      v = v - 1
     C                   eval      optln1 = optln(v)
     C                   if        $cmd = '*SPRECV'  and
     C                             v = 1
     C                   eval      optln1 = optlns(v)
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *  TEST FOR CMD24 - More Keys
     *
     C                   if        *inky
     C                   add       1             k
     C                   if        k > 2
     C                   eval      k = 1
     C                   endif
     *
     C                   select
     C                   when      k = 1
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C                   eval      cmdln1 = cmdln(3)
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C                   eval      cmdln1 = cmdln(4)
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C                   eval      cmdln1 = cmdln(1)
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C                   eval      cmdln1 = cmdln(2)
     C                   endsl
     C                   when      k = 2
     C                   eval      cmdln1 = cmdln(5)
     C                   endsl
     *
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     C                   eval      noupc = *off
     C                   eval      upcok = *off
     *
     *  UPC not entered.
     *
     C                   if        w1upcd = *blanks
     C                   eval      noupc = *on
     C                   eval      woupc = *blanks
     C                   endif
     *
     *  UPC code not on file.
     *
     C                   if        w1upcd <> *blanks
     *
     *  Extract UPC code from entered string.
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w1upcd
     *
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
     C                   select
417hM**         $CBRTN    WHEQ '*OK'
417hAC                   when      $cbrtn <> '*INVALID'
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
417bD*R                   MOVELW1UPC     $CSTR
     C                   movel     $cbv2         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
     *
417aD**         UPCKEY    CHAINUPC                  79
417aD**         *IN79     IFEQ *ON
417a C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   exsr      zm029
     C                   eval      noupc = *on
     C                   endif
     *   Multiple items exist for UPC
417m C                   if        upcctr = 1
417m C                   eval      upcok = *on
417m C                   endif
417a C                   if        upcctr > 1
417a C                   eval      ovrtyp = '*UPCSLCT'
417a C                   exsr      zzwdw
417a C                   endif
417bA*
417bA*    If extract of UPC comes back invalid, treat UPC as if not
417bA*    on file.
     C                   other
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   exsr      zm029
     *    Log barcode conversion error.
     C                   movel     $cberm        errmsg
     C                   exsr      zm0105
     C                   eval      noupc = *on
     C                   endsl
     *
     *   Verify Item exists on PO.
     *
     C                   if        noupc = *off
     C                   select
     *    Single P/O being processed.
     C                   when      $spo = '*NO '
     *
     C                   eval      woitm# = upitem
     C     podky1        setll     podtl1                             79
     C     podky1        reade     podtl1                                 79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
417m C                   eval      upcok = *off
     C                   exsr      zm027
417i C                   else
417i C                   eval      optslt = *on
417m C                   eval      upcok = *on
     C                   endif
     *
     *    Super P/O being processed.
     C                   when      $spo = '*YES'
     C                   eval      ptinp1 = upitem
     C                   eval      pditem = upitem
     C                   eval      ovrtyp = '*SLCTITM'
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     C                   select
     *    UPC not found on any P/O.
     C                   when      repos = *off
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
417m C                   eval      upcok = *off
     C                   exsr      zm027
416aA*    UPC found and selected for one p/o.
416aAC                   when      repos = *on
416aAC                   eval      pdseq = hseq
416aAC                   eval      pditem = hitem
416aAC                   eval      pdvitm = hvitm
417jAC                   eval      optslt = *on
417m C                   eval      upcok = *on
     C                   endsl
     *
     C                   endsl
     *
     *    Clear position to save fields when working with UPC.
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     *
     C                   endif
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHEK   Screen 1 EXTRA error checking.
     *
     C     zzchek        begsr
     *
     *   Do HACCP Checks
     *
     C                   if        wkoopt = ' 1'
     C                   eval      $pcmd = '*DTLCHK '
     C                   call      'PO170'
     C                   parm                    $parms
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   goto      endchk
     C                   endif
     C                   endif
     C     itkey2        chain     piritem                            79
     C                   if        *in79
     C                   eval      ittype = *blanks
     C                   eval      error = *on
     C                   exsr      zm2212
     C                   endif
     *  Item link record must exist.
     C                   if        ittype = 'A'  or
     C                             ittype = 'B'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     C     ilkey         chain     itemlnk                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm1201
     C                   endif
     C                   endif
     *  Fixed item - Pick slot must exist
     C                   if        itstyp = 'F'
     C                   select
     C                   when      ittype = ' '
     C                   eval      bsitem = $pitem
     C                   eval      bsstat = 'A '
     C                   eval      bspick = 'Y'
     C     slkey3        setll     slot3
     C                   dow       forevr = forevr
     C     slkey3        reade     slot3                                  79
     *
     C                   if        not *in79  and
     C                             slpick = 'Y'
     C                   goto      endchk
     C                   endif
     *
     C                   if        *in79
     *R                   MOVE *ON       ERROR
     *R                   EXSR ZM1202
     C                   goto      endchk
     C                   endif
     *
     C                   enddo
     *
     C                   when      ittype = 'A'  or
     C                             ittype = 'B'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   eval      bsitem = ilitm2
     C                   endif
     C                   eval      bsstat = 'A '
     C                   eval      bspick = 'Y'
     C     slkey3        setll     slot3
     C                   dow       forevr = forevr
     C     slkey3        reade     slot3                                  79
     *
     C                   if        not *in79  and
     C                             slpick = 'Y'
     C                   goto      endchk
     C                   endif
     *
     C                   if        *in79
     C                   goto      endchk
     C                   endif
     *
     C                   enddo
     *
     C                   endsl
     C                   endif
     C     endchk        endsr
     *----------------------------------------------------------------
     *
416fA*  ZZDESG   Check dept-designation file fro putaway method.
416fA*
     C     zzdesg        begsr
     C     itkey2        chain     piritem                            79
     C                   if        *in79
     C                   goto      enddsg
     C                   endif
     *
     C     ddkeyp        setll     deptdsg
     C                   eval      puttyp = *off
     C                   dow       forevr = forevr
     C     ddkeyp        reade     deptdsg                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        dddesg = itdesg
     C                   eval      puttyp = *on
     C                   leave
     C                   endif
     C                   enddo
416fAC     enddsg        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     filuky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
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
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C     partky        reade     record                                 79
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C     partky        reade     record2                                79
     *
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C     prtky2        reade     oqreca                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C     prtky2        reade     oqrecb                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   endsl
     *
     **   See if we only want untouched lines.
     C                   if        noxflg = *on  and
     C                             not *in79
     C     detlky        chain     podtl3                             84
     C     *in84         cabeq     *off          try1
     C                   endif
     *
     *
     C                   endsr
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
     C                   select
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     C     partky        readpe    record                                 79
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     C     partky        readpe    record2                                79
     *
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     C     prtky2        readpe    oqreca                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     C     prtky2        readpe    oqrecb                                 79
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     *
     C                   endsl
     *
     **   See if we only want untouched lines.
     C                   if        noxflg = *on  and
     C                             not *in79
     C     detlky        chain     podtl3                             84
     C     *in84         cabeq     *off          try2
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   select
     C                   when      view = '*POMFR  '
     C                   eval      womfr = pdvitm
     C                   endsl
     *
     C                   if        uxflag = '1'
     C     itkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
     C                   else
     C                   movel     ixdsc1        wodsc1
     C                   movel     ixdsc2        wodsc2
     C                   endif
     *  GET PACK DESCRIPTION
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      wodpt = itwhdp
     C                   eval      wopdsc = itpdsc
     C                   else
     C                   eval      wodpt = *blanks
     C                   eval      wopdsc = *blanks
     C                   endif
     *
     *    If no extended description found for the item,
     *    Load description from item.
     C                   if        not *in79  and
     C                             wodsc1 = *blanks  and
     C                             wodsc2 = *blanks
     C                   movel     itdesc        wodsc1
     C                   endif
     *
     *  GET TIE HI, PREFERRED OR Pick slot tie/hi OR 1ST RECORD.
     C                   exsr      zztihi
500  *    Calculate tie/hi qty and # of pallets needed.
500  C                   eval      putqty = 0
500  C                   eval      putplt = 0
500  C                   eval      putqty = wotie * wohi
510a C                   if        putqty > 0
650aDC**                 eval      putplt = pdqor1 / putqty
650aAC     pdqor1        div       putqty        putplt
650aAC                   mvr                     partplt
650aAC                   if        partplt > 0
650aAC                   add       1             putplt
650aAC                   endif
510a C                   else
510a C                   eval      putplt = 1
510a C                   endif
     C                   if        putplt < 1
     C                   eval      putplt = 1
     C                   endif
500  C                   eval      totplt = totplt + putplt
500  C                   eval      woplt = putplt
500  C                   eval      wotplt = totplt
     *
     *    When processing a Super P/O, load the individual P/O number
     *    in the subfile everytime the individual p/o changes.
     C                   if        $spo = '*YES'
     C                   if        savpo <> pdpo
     C                   eval      wopotx = 'PO:'
     C                   eval      wopo# = pdpo
     C                   eval      savpo = pdpo
     *
     C                   else
     C                   eval      wopotx = *blanks
     C                   eval      wopo# = *blanks
     C                   endif
     C                   endif
     *
     C                   else
     *
     *    Single line display.
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   movel     itdesc        wodsc
     C                   eval      wodpt = itwhdp
     C                   else
     C*                  eval      wodsc = *blanks
     C                   eval      wodpt = *blanks
     C                   endif
500  *
     *  GET TIE HI, PREFERRED OR Pick slot tie/hi OR 1ST RECORD.
     C                   exsr      zztihi
500  *    Calculate tie/hi qty and # of pallets needed.
500  C                   eval      putqty = 0
500  C                   eval      putplt = 0
500  C                   eval      putqty = wotie * wohi
510cAC                   if        putqty > 0
650aDC**                 eval      putplt = pdqor1 / putqty
650aAC     pdqor1        div       putqty        putplt
650aAC                   mvr                     partplt
650aAC                   if        partplt > 0
650aAC                   add       1             putplt
650aAC                   endif
510cAC                   else
510cAC                   eval      putplt = 1
510cAC                   endif
     C                   if        putplt < 1
     C                   eval      putplt = 1
     C                   endif
500  C                   eval      totplt = totplt + putplt
500  C                   eval      woplt = putplt
500  C                   eval      wotplt = totplt
     C                   endif
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     *
     C                   select
     *    Single line display.
     C                   when      uxflag = *off
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqor
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqor2
     C                   endsl
     *
     *    Extended line display.
     C                   when      uxflag = *on
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqor
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqor2
     C                   endsl
     C                   endsl
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqrc1
     C                   eval      $cqty2 = pdqrc2
     C                   eval      $cqty3 = pdqrc3
     C                   exsr      zzcvqy
     *
     C                   select
     *    Single line display.
     C                   when      uxflag = *off
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqrc
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqrc2
     C                   endsl
     *
     *    Extended line display.
     C                   when      uxflag = *on
     C                   select
     *    Item display.
     C                   when      view = '*POITEM '
     C                   movel     $cqstr        woqrc
     *    Mfr display.
     C                   when      view = '*POMFR  '
     C                   movel     $cqstr        woqrc2
     C                   endsl
     C                   endsl
     *
     **   See if line has been touched.  Flag accordingly.
     C     detlky        chain     podtl3                             84
     C                   if        *in84
     C                   eval      touch = *blanks
     C                   else
     C                   eval      touch = 'X'
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill window subfile with values to be converted.
     *
     C     zzfil4        begsr
     *
     C                   eval      wopo4 = pdpo
     *
     C                   select
     *    User selected P/O sub-totals.
     *
     *    User selected sub-totals - P/O changed - convert quantities.
     C                   when      ovrtyp = '*SUBTOTL'  and
     C                             svpo <> pdpo
     *
     C                   other
     *
     C     phkey         chain(n)  pohdr                              77
     C                   if        *in77
     C                   eval      phven = *zeros
     C                   endif
     *
     C                   eval      woven = phven
     *
     *   Convert quantity ordered to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqor1
     C                   eval      $cqty2 = pdqor2
     C                   eval      $cqty3 = pdqor3
     C                   exsr      zzcvqy
     C                   movel     $cqstr        woqor
     *
     *   Convert quantity received to string.
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = pdqrc1
     C                   eval      $cqty2 = pdqrc2
     C                   eval      $cqty3 = pdqrc3
     C                   exsr      zzcvqy
     C                   movel     $cqstr        woqrc
     *
     C                   endsl
     *
     C     endfl4        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill window subfile with values to be converted.
     *
     C     zzfil5        begsr
     *
     C                   eval      w5po = pdpo
     C                   eval      hseq = pdseq
     *
     C                   select
     *    When position to item is selected, item number is loaded on
     *    on first line of subfile record.
     C                   when      ovrtyp = '*POS2ITM'
     C                   eval      w5val1 = pditem
     C                   eval      w5val2 = pdvitm
     *
     *    When position to Mfr# is selected, Manufacturer is loaded on
     *    on first line of subfile record.
     C                   when      ovrtyp = '*POS2MFR'
     C                   eval      w5val1 = pdvitm
     C                   eval      w5val2 = pditem
     *
     C                   endsl
     *
     *    Extended item description in use.
     C                   if        uxflag = '1'
     C     itkey         chain     itemdsc                            79
     C                   if        *in79
     C                   eval      w5desc = *blanks
     C                   else
     C                   eval      w5desc = ixdsc1
     C                   endif
     C                   endif
     *
     *    Get pack description.
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   eval      w5pdsc = itpdsc
     C                   else
     C                   eval      w5pdsc = *blanks
     C                   endif
     *
     *    If no extended description found for the item,
     *    Load description from item.
     C                   if        not *in79  and
     C                             w5desc = *blanks
     C                   eval      w5desc = itdesc
     C                   endif
     *
     C     endfl5        endsr
     *----------------------------------------------------------------
417a *
417a *  ZZFIL6   Fill window subfile with values to be converted.
417a *
417a C     zzfil6        begsr
417a *
417a C                   eval      w6txt2 = 'Mfr:'
417a *
417a *    Extended item description in use.
417a C                   if        uxflag = '1'
417A C     i6key         chain     itemdsc                            79
417a C                   if        *in79
417a C                   eval      w6desc = *blanks
417a C                   else
417a C                   eval      w6desc = ixdsc1
417a C                   endif
417a C                   endif
417a *
417a *    Get pack description.
417A C     i6key         chain     piritem                            79
417a C                   if        not *in79
417a C                   eval      w6pdsc = itpdsc
417a C                   else
417a C                   eval      w6pdsc = *blanks
417a C                   endif
417a *
417a *    If no extended description found for the item,
417a *    Load description from item.
417a C                   if        not *in79
417A ***        W6DESC    ANDEQ*BLANKS
417a C                   eval      w6desc = itdesc
417a C                   endif
417a *
417a *    Get brand.
417A C     i6key         chain     itemmsc                            79
417a C                   if        not *in79
417a C                   eval      w6brnd = imbrnd
417a C                   else
417a C                   eval      w6brnd = *blanks
417a C                   endif
417a *
417a *    Get pick slot.
417a C                   eval      bsitem = pditem
417a C                   eval      bsstat = 'A '
417a C                   eval      bspick = 'Y'
417a C     slkey3        setll     slot3
417a C                   dow       forevr = forevr
417a C     slkey3        reade     slot3                                  79
417a *
417a C                   eval      w6pslt = *blanks
417a C                   if        not *in79  and
417a C                             slpick = 'Y'
417a C                   eval      w6pslt = sldisp
417a C                   endif
417a C                   leave
417a C                   enddo
     *
417a *
417a C     endfl6        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
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
     *  Define full key for PODTL3 file.
     *
     C     detlky        klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
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
     *     USERCODE
     *
     C     uskey         klist
     C                   kfld                    #user
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    pditem
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    pditem
     *
     C     filky2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    pdvitm
     *
     C     filky3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pdpo
     C                   kfld                    pditem
     *
     C     filky4        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pdpo
     C                   kfld                    pdvitm
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     *
     *  Define partial key for Super P/O file (if needed).
     *
     C     prtky2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     *
     C     prtky3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pditem
     *
     C     prtky4        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kspo
     C                   kfld                    pdvitm
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    pditem
     *
417A *  Define key for PIRITEM file.
417A *
417A C     i6key         klist
417A C                   kfld                    $kwhse
417A C                   kfld                    w6val1
     *
     *  Define key for PODTL file.
     *
     C     pdkey         klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
     C                   kfld                    pditem
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C     phky2         klist
     C                   kfld                    pdwhse
     C                   kfld                    svpo
     *
     C     itkey2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $pitem
     *
     C     slkey3        klist
     C                   kfld                    $kwhse
     C                   kfld                    bsitem
     C                   kfld                    bsstat
     C                   kfld                    bspick
     *
     *  Define key for OPTIOND.
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    itwhdp
     C                   eval      kycode = '*PICK   '
     *
     *
     *  Define key for UPC file.
     *
     C     upckey        klist
     C                   kfld                    $kwhse
     C                   kfld                    w1upc
     *
417c *  Define key for ITMEXCP2 file
     *
417c C     ix2key        klist
417c C                   kfld                    $kwhse
417c C                   kfld                    kyitem
417c C                   kfld                    kytask
417c C                   kfld                    kyerid
417c C                   kfld                    kyesta
     *
     *  Define key for PODTL1 file.
     *
     C     podky1        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kpo
     C                   kfld                    woitm#
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    ocode
     *
     *  Define partial key for item tie/high definition file.
     *
     C     partk2        klist
     C                   kfld                    $kwhse
     C                   kfld                    pditem
     *
     *  ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    pditem
     *
 16fAC     ddkeyp        klist
416fAC                   kfld                    $kwhse
416fAC                   kfld                    itwhdp
     *
     *  Setup option and command display lines.
     *
     C                   eval      viewo = 1
     C                   eval      maxvwo = 2
     C                   eval      optln1 = optln(1)
     C                   eval      optln2 = optln(2)
     C                   if        $cmd = '*SPRECV'
     C                   eval      optln1 = optlns(1)
     C                   endif
     C                   select
     C                   when      $spo = '*NO '
     C                   eval      cmdln1 = cmdln(1)
     C                   when      $spo = '*YES'
     C                   eval      cmdln1 = cmdln(3)
     C                   endsl
     C                   eval      view = '*POITEM '
     *
     C                   eval      forevr = *off
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Initialize working variables.
     *
     C                   eval      savpo = *blanks
     C                   eval      ttlrcd = *zeros
     C                   eval      nrslct = *zeros
     C                   eval      n = *zeros
     C                   eval      k = *zeros
     C                   eval      tqyor1 = *zeros
     C                   eval      tqyrc1 = *zeros
     C                   eval      k = 1
     C                   eval      recno4 = *zeros
     C                   eval      optslt = *off
     C                   eval      open1 = *off
     C                   eval      open2 = *off
     C                   eval      first = *off
416FAC                   eval      svmput = *blanks
     C                   eval      noxflg = *off
     *
     *   Get warehouse description.
     *
     C     $kwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
417a *
417a *  Convert today's date into century format.
417a *
417a C                   eval      $cvcmd = '*CURCMD '
417a C                   call      @cvtdt
417a C                   parm                    $cvtdt
417a C                   eval      today = $cvd8o
     *
     *   Load P/O for display.
     *
     C                   eval      ovrtyp = *blanks
     C                   select
     C                   when      $spo = '*YES'
     C                   eval      wopo = $kspo
     *
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*POITEM '
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     *
     C                   other
     C                   eval      wopo = $kpo
     C                   endsl
     *
     C                   exsr      zzxopt
     C                   exsr      zztrcv
     C                   exsr      clrsch
     C                   exsr      scr01i
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   eval      $code = #user
     C                   eval      $whse = *zeros
     C                   eval      $emp# = *zeros
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = *blanks
     C                   eval      $rtn = *blanks
     C                   call      'GETUSER'
     C                   parm                    $code
     C                   parm                    $whse
     C                   parm                    $emp#
     C                   parm                    $fnam
     C                   parm                    $init
     C                   parm                    $lnam
     C                   parm                    $whdp
     C                   parm                    $styp
     C                   parm                    $shft
     C                   parm                    $crew
     C                   parm                    $nhrs
     C                   parm                    $rtn              8
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCVQY   Convert quantity to string or string to quantity.
     *
     C     zzcvqy        begsr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     *   Work with tie/high
     *
     C                   if        wkoopt = ' 8'
     C                   eval      $swhse = pdwhse
     C                   call      'IT141'
     C                   parm                    $swhse
     C                   parm                    $pitem
     C                   endif
     *
     *   Transactions.
     *
     C                   if        wkoopt = ' 9'
     C                   exsr      zzputo
     C                   eval      $lmput = opmput
     C                   eval      $luky = $puky
     C                   eval      $lrtn = *blanks
     C                   call      'PO140'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   parm                    $lmput
     C                   exsr      zztrcv
     C                   endif
     *
     *   Receive item
     *
     C                   if        wkoopt = ' 1'
     C                   exsr      zzchek
     C     error         cabeq     *on           endopt
     *
     C                   select
     *    No positioning used. Check if item/Mfr# on multiple p/o's.
     *    If found on multiple p/o's, display pop-up window.
     *    Note: This is ONLY for Super P/O's.
     C                   when      svp2po = *blanks  and
     C                             svp2vl = *blanks  and
     C                             $spo = '*YES'  or
     *
     *    Position to used, but different P/O selected.
     C                             svp2po > *blanks  and
     C                             svp2po <> $ppo  or
     *
     *    Position to used, but different Item selected.
     C                             svp2vl > *blanks  and
     C                             svp2vl <> $pitem
     *
     *    Super P/O being processed.
     C                   eval      ptinp1 = $pitem
     C                   eval      pditem = $pitem
     C                   eval      ovrtyp = '*SLCTITM'
     *
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     C                   eval      w1mfr = *blanks
     C                   select
     *    New P/O selected. Go to Receiving.
     C                   when      repos = *on
     C                   eval      $ppo = wopo4
     C                   eval      $pseq = hseq
     C                   eval      $pitem = hitem
     C                   eval      $pvitm = hvitm
     C                   exsr      zzrcv
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     C                   eval      repos = *off
     C                   endsl
     *
     *    User used Position to and has selected same item.
     C                   when      svp2po = $ppo  and
     C                             svp2vl = $pitem  or
     *
     *    User processing Single P/O.
     C                             $spo = '*NO '
     *
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     *
     C                   exsr      zzrcv
     C                   endsl
     C                   endif
     *
     *   Quick Receive item
     *
     C                   if        wkoopt = ' 7'
     C                   exsr      zzchek
     C     error         cabeq     *on           endopt
     *
     C                   select
     *    No positioning used. Check if item/Mfr# on multiple p/o's.
     *    If found on multiple p/o's, display pop-up window.
     *    Note: This is ONLY for Super P/O's.
     C                   when      svp2po = *blanks  and
     C                             svp2vl = *blanks  and
     C                             $spo = '*YES'  or
     *
     *    Position to used, but different P/O selected.
     C                             svp2po > *blanks  and
     C                             svp2po <> $ppo  or
     *
     *    Position to used, but different Item selected.
     C                             svp2vl > *blanks  and
     C                             svp2vl <> $pitem
     *
     *    Super P/O being processed.
     C                   select
     C                   when      view = '*POITEM '  or
     C                             view = '*POMFR  '
     C                   eval      ptinp1 = $pitem
     C                   eval      pditem = $pitem
     C                   eval      ovrtyp = '*SLCTITM'
     C                   endsl
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     C                   eval      w1mfr = *blanks
     C                   select
     *    New P/O selected. Go to Receiving.
     C                   when      repos = *on
     C                   eval      $ppo = wopo4
     C                   eval      $pseq = hseq
     C                   eval      $pitem = hitem
     C                   eval      $pvitm = hvitm
     C                   exsr      zzrcv
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     C                   eval      repos = *off
     C                   endsl
     *
     *    User used Position to and has selected same item.
     C                   when      svp2po = $ppo  and
     C                             svp2vl = $pitem  or
     *
     *    User processing Single P/O.
     C                             $spo = '*NO '
     *
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     *
     C                   exsr      zzrcv
     C                   endsl
     C                   endif
     *
     *   Enter HACCP information.
     *
     C                   if        wkoopt = '11'
     C                   eval      $pcmd = '*ITEM   '
     C                   call      'PO170'
     C                   parm                    $parms
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *   Work with slots
     *
     C                   if        wkoopt = '12'
     C                   eval      $lwhse = $kwhse
     C                   eval      $litm = pditem
     C                   call      'IT130'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   endif
     *
     *   Display Directed Putaway Receiving log.
     *
     C                   if        wkoopt = '99'
     C                   eval      $lwhse = $kwhse
     C                   eval      $lpo = $kpo
     C                   eval      $litem = pditem
     C                   call      'PO135'
     C                   parm                    $lparm
     C                   parm                    $lrtn
     C                   endif
     *
     *   Display PORCV entries.
     *
     C                   if        wkoopt = '13'
     C                   eval      $luky = $puky
     C                   eval      $lrtn = *blanks
     C                   call      'PO138'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   endif
417 A*
417 A*   Maintain Receiving Exceptions.
417 A*
417 AC                   if        wkoopt = '14'
417 AC                   eval      $lcmd = '*CHANGE '
417 AC                   eval      $luky = $puky
417 AC                   eval      $lrtn = *blanks
417 AC                   call      'PO240'
417 AC                   parm                    $lparm
417 AC                   parm                    $lrtn
417 AC                   endif
     *
     *     Mark as touched/checked
     *
     C                   if        wkoopt = ' X'
     *
     *    Once answered yes process others in subfile without
     *    promptiong each time...
     *
     C                   if        woyes = 'N'
     C                   exfmt     verify
     C                   endif
     C                   if        woyes = 'Y'
     **
     **  Get key to
     *   Read PORCV.  If not found then add...
     C                   eval      dsukey = $puky
     C     detlky        setll     porcv
     C     detlky        reade     porcv                                  55
     C                   if        *in55
     C                   eval      porwhs = pdwhse
     C                   eval      porpo = pdpo
     C                   eval      porseq = pdseq
     C     #jobdt        mult      10000.01      wrkdte
     C     20000000      add       wrkdte        pordte
     C                   eval      portim = #jobtm
     C                   eval      porusr = #user
     C                   eval      poremp = $emp#
     C                   eval      portrn = 0
416eD**                   Z-ADD0         PORLIC
416e C                   eval      porlic = *blanks
     C                   eval      porlbl = 0
     C                   eval      poract = 'X'
416eAC                   eval      poredt = 0
416eAC                   eval      poreti = 0
     C                   write     porrec
416bAC                   else
416bA*    Release lock if record found.
416bAC                   unlock    porcv
     C                   endif
     C                   endif
     C                   endif
     *
     C     endopt        endsr
     *----------------------------------------------------------------
     *
     *  ZZOPN    Process file OPEN.
     *
     C     zzopn         begsr
     *
     *   Process file Open for P/O by item view.
     C                   select
     C                   when      ovrtyp = '*POITEM '
     *
     C                   open      po120a
     C                   eval      open1 = *on
     *
     *   Process file Open for P/O by Mfr view.
     C                   when      ovrtyp = '*POMFR  '
     *
     C                   open      po120b
     C                   eval      open1 = *on
     *
     *   Process file Open for Position To P/O by item view.
     C                   when      ovrtyp = '*POS2ITM'  or
     C                             ovrtyp = '*SLCTITM'
     *
     C                   open      po120c
     C                   eval      open2 = *on
     *
     *   Process file Open for Position To P/O by Mfr view.
     C                   when      ovrtyp = '*POS2MFR'  or
     C                             ovrtyp = '*SLCTMFR'
     *
     C                   open      po120d
     C                   eval      open2 = *on
     *
     C                   endsl
     *
     C     endopn        endsr
     *----------------------------------------------------------------
     *
     *  ZZOVR    Process file overrides.
     *
     C     zzovr         begsr
     *
     *   Process file override for P/O by item view.
     C                   select
     C                   when      ovrtyp = '*POITEM '
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(1)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd            256
     C                   parm      80            qlen             15 5
     *
     C                   if        open1 = *on
     C                   close     po120a                               78
     C                   close     po120b                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(PO120A) TOFILE(POSPO) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(1)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *   Process file override for P/O by Mfr view.
     C                   when      ovrtyp = '*POMFR  '
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(1)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   if        open1 = *on
     C                   close     po120a                               78
     C                   close     po120b                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(PO120B) TOFILE(POSPO) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(2)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *   Process file override for Position To P/O by item view.
     C                   when      ovrtyp = '*POS2ITM'  or
     C                             ovrtyp = '*SLCTITM'
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(2)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   if        open2 = *on
     C                   close     po120c                               78
     C                   close     po120d                               78
     C                   endif
     *
     *      Override database file.
     *          OVRDBF FILE(PO120C) TOFILE(POSPO2) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(3)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *   Process file override for Position To P/O by Mfr view.
     C                   when      ovrtyp = '*POS2MFR'  or
     C                             ovrtyp = '*SLCTMFR'
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(2)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   if        open2 = *on
     C                   close     po120c                               78
     C                   close     po120d                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(PO120D) TOFILE(POSPO2) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(4)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   endsl
     *
     C     endovr        endsr
     *  --------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to item or Mfr#
     C                   select
     *  Position to Item with a Single P/O.
     C                   when      ptinp1 <> *blanks  and
     C                             view = '*POITEM '  and
     C                             $spo = '*NO '
     C                   eval      pdseq = *loval
     C                   eval      pditem = ptinp1
     C                   eval      ptinp1 = *blanks
     C                   eval      repos = *on
     *
     *  Position to mfr# with a Single P/O.
     C                   when      w1mfr <> *blanks  and
     C                             view = '*POMFR  '  and
     C                             $spo = '*NO '
     C                   eval      pdvitm = w1mfr
     C                   eval      w1mfr = *blanks
     C                   eval      repos = *on
     *
     *    With a Super P/O.
     *
     *    Position to Item - Display Pop-up Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POITEM '  and
     C                             ptinp1 <> *blanks  and
     C                             ptinp2 = *blanks
     C                   eval      pditem = ptinp1
     C                   eval      ovrtyp = '*POS2ITM'
     C                   exsr      zzwdw
     C                   eval      ptinp1 = *blanks
     *
     *    Position to Mfr# - Display Pop-up Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POMFR  '  and
     C                             w1mfr <> *blanks  and
     C                             ptinp2 = *blanks
     C                   eval      pdvitm = w1mfr
     C                   eval      ovrtyp = '*POS2MFR'
     C                   exsr      zzwdw
     C                   eval      w1mfr = *blanks
     *
     *    Position to P/O and/or Item - No Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POITEM '  and
     C                             ptinp1 <> *blanks  and
     C                             ptinp2 <> *blanks  or
     *
     C                             $spo = '*YES'  and
     C                             view = '*POITEM '  and
     C                             ptinp1 = *blanks  and
     C                             ptinp2 <> *blanks
     C                   eval      pdseq = *loval
     C                   eval      pditem = ptinp1
     C                   eval      ptinp1 = *blanks
     C                   eval      pdpo = ptinp2
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     *
     *    Position to Mfr# with a Super P/O - No Window.
     C                   when      $spo = '*YES'  and
     C                             view = '*POMFR  '  and
     C                             w1mfr <> *blanks  and
     C                             ptinp2 <> *blanks  or
     *
     C                             $spo = '*YES'  and
     C                             view = '*POMFR  '  and
     C                             ptinp1 = *blanks  and
     C                             ptinp2 <> *blanks
     C                   eval      pdvitm = w1mfr
     C                   eval      w1mfr = *blanks
     C                   eval      pdpo = ptinp2
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     *
     C                   endsl
     C     endzps        endsr
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
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     *
     *    Single P/O in Item sequence.
     C                   when      view = '*POITEM '  and
     C                             $spo = '*NO '
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     *
     *    Single P/O in Mfr. sequence.
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*NO '
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record2
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record2
     C                   endif
     C                   endif
     *
     *    Super P/O in Item sequence.
     C                   when      view = '*POITEM '  and
     C                             $spo = '*YES'
     *
     C                   if        $pocmd = '*TOP'
     C     prtky2        setll     oqreca
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     prtky2        setgt     oqreca
     C                   endif
     C                   endif
     *
     *    Super P/O in Mfr. sequence.
     C                   when      view = '*POMFR  '  and
     C                             $spo = '*YES'
     *
     C                   if        $pocmd = '*TOP'
     C     prtky2        setll     oqrecb
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     prtky2        setgt     oqrecb
     C                   endif
     C                   endif
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPUTO   Get Put away option.
     *             Directed or Manual put away
     *
     C     zzputo        begsr
     *
     C     itkey2        chain     piritem                            79
     C                   if        not *in79
     C                   eval      kycode = '*PICK   '
     C     opkey2        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTIHI   Get Tie/hi
     *
     C     zztihi        begsr
     *  GET TIE HI, PREFERRED OR Pick slot tie/hi OR 1ST RECORD.
     C                   eval      done = *off
     C                   eval      wotie = 0
     C                   eval      wohi = 0
     C                   eval      svtie = 0
     C                   eval      svhi = 0
     C     partk2        setll     itemdef
     C                   dou       done = *on
     C     partk2        reade     idrec                                  79
     C                   if        *in79
     C                   eval      done = *on
     C                   else
     C                   if        svtie = 0  and
     C                             svhi = 0
     C                   eval      svtie = idtie
     C                   eval      svhi = idhigh
     C                   endif
     C                   if        idpref = 'Y'
     C                   eval      wotie = idtie
     C                   eval      wohi = idhigh
     C                   eval      done = *on
     C                   endif
     C                   endif
     C                   enddo
500  *    Get tie/hi for pick slot.
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      bsitem = pditem
     C                   eval      bsstat = 'A '
     C                   eval      bspick = 'Y'
     C     slkey3        setll     slot3
     C     slkey3        reade     slot3                                  79
     C                   if        not *in79  and
     C                             slpick = 'Y'
     C                   eval      wotie = idtie
     C                   eval      wohi = idhigh
     C                   endif
     C                   endif
     *
500  *    If no tie/hi for pick slot and no prefered, use tie hi we found.
     C                   if        wotie = 0  and
     C                             wohi = 0
     C                   eval      wotie = svtie
     C                   eval      wohi = svhi
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZQRY    Process OPNQRYF.
     *
     C     zzqry         begsr
     *
     *    Run OPNQRYF to select records for Super P/O by P/O. by Item.
     C                   select
     C                   when      ovrtyp = '*POITEM '
     *
     *    Load QRYSLT selection values.
     C                   movea     qry1(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     a80           qry1(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry1(1)
     C     qcmd          cat       qry1(2):0     qcmd
     C     qcmd          cat       qry1(3):1     qcmd
     C     qcmd          cat       qry1(4):1     qcmd
     C     qcmd          cat       qry1(5):1     qcmd
     *
     C                   when      ovrtyp = '*POMFR  '
     *
     *    Load QRYSLT selection values.
     C                   movea     qry2(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     a80           qry2(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry2(1)
     C     qcmd          cat       qry2(2):0     qcmd
     C     qcmd          cat       qry2(3):1     qcmd
     C     qcmd          cat       qry2(4):1     qcmd
     C     qcmd          cat       qry2(5):1     qcmd
     *
     *    Run OPNQRYF to Position to Item(s) on Super P/O.
     C                   when      ovrtyp = '*POS2ITM'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry3(6)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     ptinp1        a80(54)
     C                   movea     a80           qry3(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry3(1)
     C     qcmd          cat       qry3(2):0     qcmd
     C     qcmd          cat       qry3(3):1     qcmd
     C     qcmd          cat       qry3(4):1     qcmd
     C     qcmd          cat       qry3(5):1     qcmd
     *
     *    Run OPNQRYF to Position to Mfr#(s) on Super P/O.
     C                   when      ovrtyp = '*POS2MFR'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry4(6)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     w1mfr         a80(54)
     C                   movea     a80           qry4(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry4(1)
     C     qcmd          cat       qry4(2):0     qcmd
     C     qcmd          cat       qry4(3):1     qcmd
     C     qcmd          cat       qry4(4):1     qcmd
     C     qcmd          cat       qry4(5):1     qcmd
     *
     *    Run OPNQRYF to select item from Super P/O.
     C                   when      ovrtyp = '*SLCTITM'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry3(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     ptinp1        a80(54)
     C                   movea     a80           qry3(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry3(1)
     C     qcmd          cat       qry3(2):0     qcmd
     C     qcmd          cat       qry3(3):1     qcmd
     C     qcmd          cat       qry3(4):1     qcmd
     C     qcmd          cat       qry3(5):1     qcmd
     *
     C                   when      ovrtyp = '*SLCTMFR'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry4(2)       a80
     C                   movea     $whsea        a80(10)
     C                   movea     $kspo         a80(28)
     C                   movea     w1mfr         a80(54)
     C                   movea     a80           qry4(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry4(1)
     C     qcmd          cat       qry4(2):0     qcmd
     C     qcmd          cat       qry4(3):1     qcmd
     C     qcmd          cat       qry4(4):1     qcmd
     C     qcmd          cat       qry4(5):1     qcmd
     *
     C                   endsl
     *
     *    Process OPNQRYF to select records.
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      256           qlen
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCV    Receive item
     *
     C     zzrcv         begsr
     *
     C                   exsr      zzputo
     C                   if        $cmd = '*SPRECV '
     C                   eval      opmput = 'N'
     C                   endif
     *
     C                   if        wkoopt = ' 7'
     C                   eval      $lcmd = '*QUICK  '
     C                   else
     C                   eval      $lcmd = '*CHANGE '
     C                   endif
     *
     C                   eval      $luky = $puky
417m C                   eval      $lupc = *blanks
417m C                   if        upcok = *on
     C                   eval      $lupc = w1upc
417m C                   else
417m C                   eval      $lupc = *blanks
417m C                   endif
     C                   eval      w1upc = *blanks
417bAC                   eval      w1upcd = *blanks
     C                   eval      $lrsqt = 0
     *
416fAC                   eval      svmput = opmput
416fD**         OPMPUT    IFEQ 'N'
     *
416fA*  Note: For every item check the DEPTDSG file for designation
416fA*        code.  If the item's desig code is in the file, then
416fA*        use opposite putaway method than the default for the
416fA*        department (OPMPUT).
416fA*
416fA*        PUTTYP=*ON - Desig code found in file. Use opp. method.
416fA*        PUTTYP=*OFF - DSesig code not found.
     *
     *
416fAC                   exsr      zzdesg
     *
     *   Do not execute for desig code for special receiving.
     C                   if        $cmd <> '*SPRECV '
416fAC                   if        puttyp = *on  and
416fAC                             opmput = 'N'
416fAC                   eval      svmput = 'Y'
416fAC                   endif
     *
416fAC                   if        puttyp = *on  and
416fAC                             opmput = 'Y'
416fAC                   eval      svmput = 'N'
416fAC                   endif
     C                   endif
     *
     C                   if        $cmd = '*SPRECV '
     C                   eval      $lcmd = '*CHANGES'
     C                   endif
416fMC                   if        svmput = 'N'
     C                   call      'PO132'
     C                   parm                    $lparm
     C                   parm                    $lupc            20
     C                   parm                    $lrsqt            7 0
     *R                   ADD  $LRSQT    WOSRC
     C                   exsr      zztrcv
     C                   else
     C                   call      'PO232'
     C                   parm                    $lparm
     C                   parm                    $lupc
     C                   parm                    $lrsqt
     *R                   ADD  $LRSQT    WOSRC
     C                   exsr      zztrcv
     C                   endif
     C                   if        $lrtn = '*OK     '
     *    Recalculate session total received.
     *
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTRCV   Calculate total qty received for PO
     *
     C     zztrcv        begsr
     *
     C                   select
     C                   when      $spo = '*NO '
     *
     C                   z-add     0             wosrc            15 0
     C     partky        setll     record
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   add       pdqrc1        wosrc
     C                   add       pdqrc2        wosrc
     C                   add       pdqrc3        wosrc
     C                   endif
     C                   enddo
     *
     *    Process Super P/O. Accumulate receiving totals.
     C                   when      $spo = '*YES'  and
     C                             view = '*POITEM '
     *
     C                   eval      wosrc = *zeros
     C     prtky2        setll     oqreca
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     prtky2        reade     oqreca                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     C                   add       pdqrc1        wosrc
     C                   add       pdqrc2        wosrc
     C                   add       pdqrc3        wosrc
     C                   endif
     C                   enddo
     *
     *    Process Super P/O. Accumulate receiving totals.
     C                   when      $spo = '*YES'  and
     C                             view = '*POMFR  '
     *
     C                   eval      wosrc = *zeros
     C     prtky2        setll     po120b
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     prtky2        reade     po120b                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        not *in79
     C     pdkey         chain     podtl                              77
     C                   endif
     C                   add       pdqrc1        wosrc
     C                   add       pdqrc2        wosrc
     C                   add       pdqrc3        wosrc
     C                   endif
     C                   enddo
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR   Update Super P/O status upon exit.
     *
     C     zzuhdr        begsr
     *
     C                   eval      full = *on
     C                   eval      part = *off
     C                   eval      recv = *off
     C     prtky2        setll     pujrec
     C                   dow       forevr = forevr
     C     prtky2        reade     pujrec                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     C                   if        not *in79
     C                   if        pdqrc1 < pdqor1
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc2 < pdqor2
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc3 < pdqor3
     C                   eval      part = *on
     C                   eval      full = *off
     C                   endif
     *
     C                   if        pdqrc1 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc2 > 0
     C                   eval      recv = *on
     C                   endif
     *
     C                   if        pdqrc3 > 0
     C                   eval      recv = *on
     C                   endif
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   if        recv = *off
     C                   eval      full = *off
     C                   eval      part = *off
     C                   endif
     *
     *    Update Super P/O header with new status.
     C     prtky2        chain     pohdr                              79
     C                   if        not *in79
     C                   select
     *    Super P/O partially received.
     C                   when      part = *on
     C                   eval      phstat = *on
     *
     *    Super P/O Fully received.
     C                   when      full = *on
     C                   eval      phstat = '2'
     *
     *    Super P/O still Open.
     C                   when      part = *off  and
     C                             full = *off
     C                   eval      phstat = *off
     C                   endsl
     C                   update    phrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWDW    Build Pop-Up window for selection of item/Mfr.
     *
     C     zzwdw         begsr
     *
     C                   eval      svp2po = *blanks
     C                   eval      svp2vl = *blanks
     C                   eval      option = *blanks
417oAC                   eval      *in21 = *off
     *
     C                   select
     C                   when      ovrtyp = '*POS2ITM'  or
     C                             ovrtyp = '*POS2MFR'  or
     C                             ovrtyp = '*SLCTITM'  or
     C                             ovrtyp = '*SLCTMFR'
     *    Condition heading in window.
     C                   eval      *in41 = *on
     *    Process file override.
     C                   exsr      zzovr
     *    Process OPNQRYF.
     C                   exsr      zzqry
     *    Open file for processing.
     C                   exsr      zzopn
     C                   endsl
     *
     ********************************************************************
     *
     C                   eval      recno4 = *zeros
417b C                   eval      repos = *off
     *
     C                   select
     *    User chose to Select one Item.
     C                   when      ovrtyp = '*SLCTITM'
     *
     *    Find out if item on more than one P/O.
     *    If the item is on only ONE P/O, then position to the P/O
     *    and item.
     C                   eval      n = 1
     C                   eval      ttlrcd = *zeros
     C     prtky3        setll     oqrecc
     C     1             do        2             n
     C     prtky3        reade     oqrecc                                 79
     C                   select
     C                   when      *in79  and
     C                             n = 1
     C                   leave
     *
     *    Item found on more than one P/O.
     C                   when      n = 2
     C                   if        *in79
     C                   eval      ttlrcd = 1
     C                   else
     C                   eval      ttlrcd = n
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   select
     *    Item NOT found on any P/O. Don't reposition the screen.
     C                   when      ttlrcd < 1
     C                   eval      repos = *off
     *
     *    Item on only ONE P/O. Position to the item.
     C                   when      ttlrcd = 1
     C                   eval      wopo4 = pdpo
     C                   eval      hseq = pdseq
     C                   eval      hitem = pditem
     C                   eval      hvitm = pdvitm
     C                   eval      $kpo = pdpo
     C                   eval      svp2po = pdpo
     C                   eval      svp2vl = ptinp1
     C                   eval      repos = *on
     *
     *    Item on more than ONE P/O. Display select window.
     C                   when      ttlrcd > 1
     *
     C                   eval      w4titl = titl01
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc4
     C                   eval      *in01 = *on
     C                   eval      slctxt = 'Item:'
     C                   eval      slcval = ptinp1
     *
     *    Fill subfile.
     C     prtky3        setll     oqrecc
     C                   dow       forevr = forevr
     C     prtky3        reade     oqrecc                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     C                   exsr      zzfil4
     C                   exsr      sflad4
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is loaded, Display it to the user.
     C                   exsr      zzwdw2
     *
     C                   endsl
     *
     ********************************************************************
     *
     *    User chose to Select one Mfr#.
     C                   when      ovrtyp = '*SLCTMFR'
     *
     *    Find out if Mfr# on more than one P/O.
     *    If the Mfr# is on only ONE P/O, then position to the P/O
     *    and Mfr#.
     C                   eval      n = 1
     C                   eval      ttlrcd = *zeros
     C     prtky4        setll     oqrecd
     C     1             do        2             n
     C     prtky4        reade     oqrecd                                 79
     C                   select
     C                   when      *in79  and
     C                             n = 1
     C                   leave
     *
     *    Item found on more than one P/O.
     C                   when      n = 2
     C                   if        *in79
     C                   eval      ttlrcd = 1
     C                   else
     C                   eval      ttlrcd = n
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   select
     *    Mfr# NOT found on any P/O. Don't reposition the screen.
     C                   when      ttlrcd < 1
     C                   eval      repos = *off
     *
     *    Mfr# on only ONE P/O. Position to the Mfr#.
     C                   when      ttlrcd = 1
     C                   eval      wopo4 = pdpo
     C                   eval      hseq = pdseq
     C                   eval      hitem = pditem
     C                   eval      hvitm = pdvitm
     C                   eval      $kpo = pdpo
     C                   eval      svp2po = pdpo
     C                   eval      svp2vl = w1mfr
     C                   eval      repos = *on
     *
     *    Mfr# on more than ONE P/O. Display select window.
     C                   when      ttlrcd > 1
     *
     C                   eval      w4titl = titl01
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc4
     C                   eval      *in01 = *on
     C                   eval      slctxt = 'Mfr :'
     C                   eval      slcval = w1mfr
     *
     *    Fill subfile.
     C     prtky4        setll     oqrecd
     C                   dow       forevr = forevr
     C     prtky4        reade     oqrecd                                 79
     C                   select
     C                   when      *in79
     C                   leave
     C                   other
     *
     C                   exsr      zzfil4
     C                   exsr      sflad4
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is built, Display it to the user.
     C                   exsr      zzwdw2
     *
     C                   endsl
     *
     ********************************************************************
     *
     *    User chose to Position to Item.
     C                   when      ovrtyp = '*POS2ITM'
416dA*
416dA*    Find out if item on more than one P/O.
416dA*    If the item is on only ONE P/O, then position to the P/O
416dA*    and item and do not display pop-up window.
416dAC                   eval      n = 1
416dAC                   eval      ttlrcd = *zeros
416dAC     prtky3        setll     oqrecc
416dAC     1             do        2             n
416dAC     prtky3        reade     oqrecc                                 79
416dAC                   select
416dAC                   when      *in79  and
416dAC                             n = 1
416dAC                   leave
416dA*
416dA*    Item found on more than one P/O.
416dAC                   when      n = 2
416dAC                   if        *in79
416dAC                   eval      ttlrcd = 1
416dAC                   else
416dAC                   eval      ttlrcd = n
416dAC                   endif
416dAC                   endsl
416dAC                   enddo
416dA*
416dAC                   select
416dA*    Item on only ONE P/O. Position to the item. No Window.
416dAC                   when      ttlrcd = 1
416dAC                   eval      wopo4 = pdpo
416dAC                   eval      hseq = pdseq
416dAC                   eval      hitem = pditem
416dAC                   eval      hvitm = pdvitm
416dAC                   eval      $kpo = pdpo
416dAC                   eval      svp2po = pdpo
416dAC                   eval      svp2vl = ptinp1
416dAC                   eval      repos = *on
416dA*
416dA*    Item on more than ONE P/O or item not found. Display window.
416dAC                   when      ttlrcd > 1  or
416dAC                             ttlrcd < 1
     *
     C                   eval      w4titl = titl03
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc5
     C                   eval      *in01 = *on
     *    Load headings.
     C                   eval      w5txt1 = hdr01
     C                   eval      w5txt2 = 'Mfr:'
     *
     *    Fill subfile.
     C     prtky3        setll     oqrecc
     C                   dow       forevr = forevr
     C     prtky2        reade     oqrecc                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     C                   exsr      zzfil5
     C                   exsr      sflad5
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is loaded, Display it to the user.
416cAC                   select
416cA*    When 2 or more records are loaded in subfile. Display window.
416cAC                   when      recno4 >= 2
     C                   exsr      zzwdw4
416cA*
416cA*    Only one item loaded. Position to that p/o/item in main sfl.
416cAC                   when      recno4 = 1
416cAC                   eval      wopo4 = pdpo
416cAC                   eval      hseq = pdseq
416cAC                   eval      hitem = pditem
416cAC                   eval      hvitm = pdvitm
416cAC                   eval      $kpo = pdpo
416cAC                   eval      svp2po = pdpo
416cAC                   eval      svp2vl = ptinp1
416cAC                   eval      repos = *on
416cA*
416cA*    No items loaded. Send error message.
416cAC                   when      recno4 <= 0
416caC                   eval      erp2tp = 'item'
416cAC                   eval      erspo = $kspo
416cAC                   eval      erp2vl = ptinp1
416cAC                   exsr      zm3236
416cA*
416cAC                   endsl
416dA*
416dAC                   endsl
     *
     ********************************************************************
     *
     *    User chose to Position to Mfr#.
     C                   when      ovrtyp = '*POS2MFR'
416dA*
416dA*    Find out if Mfr# on more than one P/O.
416dA*    If the Mfr# is on only ONE P/O, then position to the P/O
416dA*    and Mfr#.
416dAC                   eval      n = 1
416dAC                   eval      ttlrcd = *zeros
416dAC     prtky4        setll     oqrecd
416dAC     1             do        2             n
416dAC     prtky4        reade     oqrecd                                 79
416dAC                   select
416dAC                   when      *in79  and
416dAC                             n = 1
416dAC                   leave
416dA*
416dA*    Item found on more than one P/O.
416dAC                   when      n = 2
416dAC                   if        *in79
416dAC                   eval      ttlrcd = 1
416dAC                   else
416dAC                   eval      ttlrcd = n
416dAC                   endif
416dAC                   endsl
416dAC                   enddo
416dA*
416dAC                   select
416dA*    Mfr# on only ONE P/O. Position to the Mfr#.
416dAC                   when      ttlrcd = 1
416dAC                   eval      wopo4 = pdpo
416dAC                   eval      hseq = pdseq
416dAC                   eval      hitem = pditem
416dAC                   eval      hvitm = pdvitm
416dAC                   eval      $kpo = pdpo
416dAC                   eval      svp2po = pdpo
416dAC                   eval      svp2vl = w1mfr
416dAC                   eval      repos = *on
416dA*
416dA*    Mfr# on more than ONE P/O or not found. Display window.
416dAC                   when      ttlrcd > 1  or
416dAC                             ttlrcd < 1
     *
     C                   eval      w4titl = titl04
     C                   write     window4
     *    Clear subfile.
     C                   eval      *in01 = *off
     C                   write     dspsfc5
     C                   eval      *in01 = *on
     *    Load headings.
     C                   eval      w5txt1 = hdr02
     C                   eval      w5txt2 = 'Itm:'
     *
     *    Fill subfile.
     C     prtky4        setll     oqrecd
     C                   dow       forevr = forevr
     C     prtky2        reade     oqrecd                                 79
     C                   select
     C                   when      *in79
     C                   leave
     C                   other
     *
     C                   exsr      zzfil5
     C                   exsr      sflad5
     C                   endsl
     C                   enddo
     *
     *    Now that subfile is built, Display it to the user.
416cAC                   select
416cA*    When 2 or more records are loaded in subfile. Display window.
416cAC                   when      recno4 >= 2
     C                   exsr      zzwdw4
416cA*
416cA*    Only one item loaded. Position to that p/o/item in main sfl.
416cAC                   when      recno4 = 1
416cAC                   eval      wopo4 = pdpo
416cAC                   eval      hseq = pdseq
416cAC                   eval      hitem = pditem
416cAC                   eval      hvitm = pdvitm
416cAC                   eval      $kpo = pdpo
416cAC                   eval      svp2po = pdpo
416cAC                   eval      svp2vl = ptinp1
416cAC                   eval      repos = *on
416cA*
416cA*    No items loaded. Send error message.
416cAC                   when      recno4 <= 0
416caC                   eval      erp2tp = 'mfg#'
416cAC                   eval      erspo = $kspo
416cAC                   eval      erp2vl = w1mfr
416cAC                   exsr      zm3236
416cA*
416cAC                   endsl
416dA*
416dAC                   endsl
     *
     ********************************************************************
     *
     *    User chose to see sub-total by p/o.
417k *    Super PO.
     C                   when      ovrtyp = '*SUBTOTL'  and
417kAC                             $spo = '*YES'
     *
417k ********************************************************************
417k *
417k *    User chose to see item subtotal p/o, qty recvd <> ordered.
417k *    Normal PO.
417k C                   when      ovrtyp = '*SUBITTL'  and
417kAC                             $spo = '*NO'
417k *
417l ********************************************************************
417l *
417l *    User chose to see item subtotal p/o, qty recvd <> ordered.
417l *    Super PO.
417l C                   when      ovrtyp = '*SUBITTL'  and
417lAC                             $spo = '*YES'
417l *
417a ********************************************************************
417a *
417a *    Multiple Items exist for UPC, select item.
417a C                   when      ovrtyp = '*UPCSLCT'
417aA*
417a *
417a C                   eval      w4titl = titl05
417a C                   write     window4
417a *    Clear subfile.
417a C                   eval      *in01 = *off
417a C                   write     dspsfc6
417a C                   eval      *in01 = *on
417a *    Load headings.
417a C                   eval      w6txt1 = hdr01
417a C                   eval      w6txt2 = 'Itm:'
417aA*    Process for one po
417aAC                   if        $spo = '*NO'
417aAC     upckey        setll     upc
417a C                   dow       forevr = forevr
417aAC     upckey        reade     upc                                    79
417aAC                   if        *in79
417aAC                   leave
417aAC                   endif
417a *
417a C                   eval      woitm# = upitem
417a C     podky1        setll     podtl1                             78
417a C                   dow       forevr = forevr
     C     podky1        reade     podtl1                                 78
     C                   if        *in78
417a *
417a C                   eval      w6po = *blanks
417a C                   eval      hseq = 0
417a C                   eval      pditem = woitm#
417a C                   eval      w6val1 = woitm#
417a C                   eval      w6val2 = *blanks
     C                   leave
     C                   else
417a *
417a C                   eval      w6po = pdpo
417a C                   eval      hseq = pdseq
417a C                   eval      w6val1 = pditem
417a C                   eval      w6val2 = pdvitm
     C                   leave
     C                   endif
     *
417a C                   enddo
417a C                   exsr      zzfil6
417a C                   exsr      sflad6
417AAC                   enddo
417a *
417a *    Now that subfile is built, Display it to the user.
417a C                   exsr      zzwdw6
417AAC                   endif
417a *
417aA*    Process for SUPER po
417aAC                   if        $spo = '*YES'
417aAC     upckey        setll     upc
417a C                   dow       forevr = forevr
417aAC     upckey        reade     upc                                    79
417aAC                   if        *in79
417aAC                   leave
417aAC                   endif
417a C                   eval      woitm# = upitem
417a C                   eval      prtupc = *off
417a *    Get regular PO#
417a C     prtky2        setll     pospo                              77
417a C                   dow       forevr = forevr
     C     prtky2        reade     pospo                                  77
     C                   if        *in77
417aAC                   leave
417aAC                   else
417a C                   eval      $kpo = pupo
417aAC                   endif
417a *
417a C     podky1        setll     podtl1                             78
417a C                   dow       forevr = forevr
     C     podky1        reade     podtl1                                 78
     C                   if        *in78
417a *
417a C                   eval      w6po = *blanks
417a C                   eval      hseq = 0
417a C                   eval      pditem = woitm#
417a C                   eval      w6val1 = woitm#
417a C                   eval      w6val2 = *blanks
     C                   leave
     C                   else
417a *
417a C                   eval      w6po = pdpo
417a C                   eval      hseq = pdseq
417a C                   eval      w6val1 = pditem
417a C                   eval      w6val2 = pdvitm
     C                   leave
     C                   endif
     *
417a C                   enddo
417a C                   if        not *in78
417a C                   exsr      zzfil6
417a C                   exsr      sflad6
417a C                   eval      prtupc = *on
417AAC                   endif
417a C                   enddo
417a C                   if        prtupc = *off
417a C                   exsr      zzfil6
417a C                   exsr      sflad6
417a C                   eval      prtupc = *on
417AAC                   endif
417AAC                   enddo
417a *
417a *    Now that subfile is built, Display it to the user.
417a C                   exsr      zzwdw6
417AAC                   endif
     *
     C                   endsl
     ********************************************************************
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDW2   Display Pop-Up window for selection of item/Mfr.
     *
     C     zzwdw2        begsr
     *
     C                   if        recno4 = *zeros
     C                   write     blank4
     C                   eval      *in56 = *on
     C                   else
     C                   eval      *in56 = *off
     C                   endif
     *
     C                   eval      *in57 = *on
     C                   dow       forevr = forevr
     *
     *   Overlay screen with error messages
     C                   exsr      zmdms4
     *
     C                   exfmt     dspsfc4
     *
     *   Initialize error subfile
     C                   exsr      zmcms4
     *
     C                   select
     *    F12=Cancel selected.
     C                   when      *inkl
     C                   eval      *inkl = *off
     C                   leave
     *
     *    F5=Refresh selected.
     C                   when      *inke
     C                   exsr      clrsch
     C     1             do        05            x
     C     x             chain     dspsfl4                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl4
     C                   endif
     C                   enddo
     *
     C                   other
     *
     *    Process subfile.
     C                   exsr      zzwdw3
     *
     *    User selected record from list.
     C                   if        optslt = *on  and
     C                             error = *off
     C                   leave
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWDW3   Process subfile looking for selection.
     *
     C     zzwdw3        begsr
     *
     *    Read ONLY the changed options.
     C                   eval      error = *off
     C                   eval      nrslct = *zeros
     C                   eval      optslt = *off
     C                   dow       forevr = forevr
     C                   readc     dspsfl4                                79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     *    Display error if option is not valid.
     C                   if        option <> *blanks
     C                   eval      *in21 = *on
     C                   update    dspsfl4
     *
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found.
     C     option        lookup    zopt4                                  50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      z40108
     C                   endif
     *
     *    Count number of entries when Option=1
     C                   if        option = ' 1'
     C                   add       1             nrslct
     C                   eval      pdpo = wopo4
     C                   eval      $kpo = wopo4
     C                   eval      svp2po = wopo4
     C                   eval      svp2vl = slcval
     *    If number selected greater than 1, Then display message.
     C                   select
     C                   when      nrslct = 1
     C                   eval      optslt = *on
     C                   eval      repos = *on
     C                   when      nrslct >= 2
     C                   eval      error = *on
     C                   eval      errmsg = err01
     C                   exsr      z40105
     C                   eval      optslt = *off
     C                   eval      repos = *off
     C                   endsl
     C                   endif
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDW4   Display Pop-Up window for Position to item/Mfr.
     *
     C     zzwdw4        begsr
     *
     C                   if        recno4 = *zeros
     C                   write     blank5
     C                   eval      *in56 = *on
     C                   else
     C                   eval      *in56 = *off
     C                   endif
     *
     C                   eval      *in57 = *on
     C                   dow       forevr = forevr
     *
     *   Overlay screen with error messages
     C                   exsr      zmdms4
     *
     C                   exfmt     dspsfc5
     *
     *   Initialize error subfile
     C                   exsr      zmcms4
     *
     C                   select
     *    F12=Cancel selected.
     C                   when      *inkl
     C                   eval      *inkl = *off
     C                   leave
     *
     *    F5=Refresh selected.
     C                   when      *inke
     C                   exsr      clrsch
     C     1             do        05            x
     C     x             chain     dspsfl5                            79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl5
     C                   endif
     C                   enddo
     *
     C                   other
     *
     *    Process subfile.
     C                   exsr      zzwdw5
     *
     *    User selected record from list.
     C                   if        optslt = *on  and
     C                             error = *off
     C                   leave
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWDW5   Process subfile5 looking for selection.
     *
     C     zzwdw5        begsr
     *
     *    Read ONLY the changed options.
     C                   eval      error = *off
     C                   eval      nrslct = *zeros
     C                   eval      optslt = *off
     C                   dow       forevr = forevr
     C                   readc     dspsfl5                                79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     *    Display error if option is not valid.
     C                   if        option <> *blanks
     C                   eval      *in21 = *on
     C                   update    dspsfl5
     *
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found.
     C     option        lookup    zopt4                                  50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      z40108
     C                   endif
     *
     *    Count number of entries when Option=1
     C                   if        option = ' 1'
     C                   add       1             nrslct
     C                   eval      pdpo = w5po
     C                   eval      $kpo = w5po
     C                   eval      svp2po = w5po
     C                   eval      pdseq = hseq
     C                   select
     C                   when      ovrtyp = '*POS2ITM'
     C                   eval      pditem = w5val1
     C                   eval      svp2vl = w5val1
     C                   eval      pdvitm = w5val2
     C                   when      ovrtyp = '*POS2MFR'
     C                   eval      pdvitm = w5val1
     C                   eval      pditem = w5val2
     C                   eval      svp2vl = w5val2
     C                   endsl
     *    If number selected greater than 1, Then display message.
     C                   select
     C                   when      nrslct = 1
     C                   eval      optslt = *on
     C                   eval      repos = *on
     C                   when      nrslct >= 2
     C                   eval      error = *on
     C                   eval      errmsg = err01
     C                   exsr      z40105
     C                   eval      optslt = *off
     C                   eval      repos = *off
     C                   endsl
     C                   endif
     C                   endif
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
417a *----------------------------------------------------------------
417a *
417a *  ZZWDW6   Display Pop-Up window for UPC multiple items.
417a *
417a C     zzwdw6        begsr
417a *
417a C                   if        recno4 = *zeros
417a C                   write     blank5
417a C                   eval      *in56 = *on
417a C                   else
417a C                   eval      *in56 = *off
417a C                   endif
417a *
417a C                   eval      *in57 = *on
417a C                   dow       forevr = forevr
417a ***        REFRSH    CABEQ*ON       JMP1
417a *
417a *   Overlay screen with error messages
417a C                   exsr      zmdms4
417a *
417a C                   exfmt     dspsfc6
417a *
417a *   Initialize error subfile
417a C                   exsr      zmcms4
417a *
417a C                   select
417a *    F12=Cancel selected.
417a C                   when      *inkl
417a C                   eval      *inkl = *off
417a C                   leave
417a *
417a *    F5=Refresh selected.
417a C                   when      *inke  or
417a C                             refrsh = *on
417a C                   eval      refrsh = *off
417a C                   exsr      clrsch
417a C     1             do        05            x
417a C     x             chain     dspsfl6                            79
417a C                   if        not *in79
417a C                   eval      option = '  '
417a C                   update    dspsfl6
417a C                   endif
417a C                   enddo
417a *
417a C                   other
417a *
417a *    Process subfile.
417f C                   exsr      zzwdwx
417a C                   exsr      zzwdw7
417a *
417a *    User selected record from list.
417a C                   if        optslt = *on  and
417a C                             error = *off
417a C                   leave
417a C                   endif
417a *
417f *    User did NOT select record from list.
417f C                   if        optslt = *off  and
417f C                             error = *off
417f C                   leave
417f C                   endif
417f *
417a C                   endsl
417a C                   if        refrsh = *on
417a C                   eval      refrsh = *off
417a C                   exsr      clrsch
417a C     1             do        05            x
417a C     x             chain     dspsfl6                            79
417a C                   if        not *in79
417a C                   eval      option = '  '
417a C                   update    dspsfl6
417a C                   endif
417a C                   enddo
417a C                   iter
417a C                   endif
417a C                   enddo
417a *
417a C                   endsr
     *----------------------------------------------------------------
417a *
417a *  ZZWDW7   Process subfile6 looking for selection 1.
417a *
417a C     zzwdw7        begsr
417a *
417a *    Read ONLY the changed options.
417a C                   eval      error = *off
417a C                   eval      nrslct = *zeros
417a C                   eval      optslt = *off
417a C                   dow       forevr = forevr
417a C                   readc     dspsfl6                                79
417a C                   select
417a C                   when      *in79
417a C                   leave
417a *
417a C                   other
417a *
417a *    Display error if option is not valid.
417a C                   if        option <> *blanks
417a C                   eval      *in21 = *on
417a C                   update    dspsfl6
417a *
417a C                   movea     option        a2
417a C                   if        a2(2) = ' '
417a C                   eval      a2(2) = a2(1)
417a C                   eval      a2(1) = ' '
417a C                   movea     a2            option
417a C                   endif
417a *
417a *    Look up option in profile - Error if not found.
417eD*R         OPTION    LOKUPZOPT4                    50
417eMC     option        lookup    zopt6                                  50
417a C                   if        not *in50
417a C                   eval      error = *on
417a C                   eval      errmsg = *blanks
417a C                   exsr      z40108
417a C                   endif
417a *
417a *    Count number of entries when Option=1
417a C                   if        option = ' 1'
417a C                   add       1             nrslct
417a C                   eval      pdpo = w6po
417g C                   if        w6po <> *blanks
417a C                   eval      $kpo = w6po
417g C                   endif
417a C                   eval      svp2po = w6po
417a C                   eval      upitem = w6val1
417a C                   eval      pditem = w6val1
417a C                   eval      pdseq = hseq
417a C                   eval      pdvitm = w6val2
417a *    If number selected greater than 1, Then display message.
417a C                   select
417a C                   when      nrslct = 1
417h C                   eval      noupc = *off
417a C                   eval      optslt = *on
417a C                   eval      repos = *on
417a C                   when      nrslct >= 2
417a C                   eval      error = *on
417a C                   eval      errmsg = err01
417a C                   exsr      z40105
417a C                   eval      optslt = *off
417a C                   eval      repos = *off
417a C                   endsl
417a C                   endif
417a *
417a *
417a C                   endif
417a *
417a C                   endsl
417a C                   enddo
417a *
417a C                   endsr
417f *----------------------------------------------------------------
417f *
417f *  ZZWDWX   Process subfile6 looking for selection X
417f *
417f C     zzwdwx        begsr
417h C                   eval      noupc = *on
417f *
417f *    Read ONLY the changed options.
417f C                   eval      error = *off
417f C                   eval      nrslct = *zeros
417f C                   eval      optslt = *off
417f C                   dow       forevr = forevr
417f C                   readc     dspsfl6                                79
417f C                   select
417f C                   when      *in79
417f C                   leave
417f *
417f C                   other
417f *
417f *    Display error if option is not valid.
417f C                   if        option <> *blanks
417f C                   eval      *in21 = *on
417f C                   update    dspsfl6
417f *
417f C                   movea     option        a2
417f C                   if        a2(2) = ' '
417f C                   eval      a2(2) = a2(1)
417f C                   eval      a2(1) = ' '
417f C                   movea     a2            option
417f C                   endif
417f *
417f *    Look up option in profile - Error if not found.
417eD*R         OPTION    LOKUPZOPT4                    50
417fMC     option        lookup    zopt6                                  50
417f C                   if        not *in50
417f C                   eval      error = *on
417f C                   eval      errmsg = *blanks
417f C                   exsr      z40108
417f C                   endif
417f *
417f *    Process exceptions Option=X
417f C                   if        option = ' X'
417fAC                   eval      kyitem = w6val1
417faC                   eval      kytask = 'RCV'
417fAC                   eval      kyerid = 'RDUPUPC'
417fAC                   eval      kyesta = '1 '
417f C     ix2key        setll     itmexcp2
417f C                   dow       forevr = forevr
417f C     ix2key        reade     itmexcp2                               79
     *
417f C                   if        *in79
417f C                   eval      doex = *on
417f C                   leave
417f C                   else
417f C                   eval      doex = *off
417f C                   leave
417f C                   endif
     *
417f C                   enddo
     *
417f C                   if        doex = *on
417fAC                   eval      pditem = w6val1
417f C     itkey         chain     piritem                            79
417f C                   if        not *in79
417fAC                   eval      exwhdp = itwhdp
417fAC                   eval      exstyp = itstyp
417fAC                   else
417fAC                   eval      exwhdp = *blanks
417fAC                   eval      exstyp = *blanks
417fAC                   endif
417f **                   ADD  1         NRSLCT
417fAC                   eval      exwhse = $kwhse
417fAC                   eval      exitem = w6val1
417fAC                   eval      exfdis = *blanks
417fAC                   eval      extdis = *blanks
417fAC                   eval      exgdte = today
417fAC                   time                    exgtim
417fMC                   eval      exqty = 0
417faC                   eval      extask = 'RCV'
417fAC                   eval      exgby = #user
417fAC                   eval      exerid = 'RDUPUPC'
417fAC                   eval      exesta = '1 '
417fAC                   eval      dsupc = w1upc
417fAC                   eval      exfdis = dsfdis
417fAC                   eval      extdis = dstdis
417fAC                   write     exrec
417f C                   endif
417g **                   MOVE *ON       REFRSH
417g **                   MOVE *OFF      *IN21
417g **                   LEAVE
417f C                   endif
417f *
417f C                   endif
417f *
417f C                   endsl
417f C                   enddo
417f *
417f C                   endsr
417f *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      prcrec = 10
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   eval      prcrec = 5
     C                   endif
     C                   endif
     *
     *   If processing a Super P/O, Force display to be displayed
     *   in 2-line mode.
     C                   if        $spo = '*YES'  and
     C                             uxflag = '0'
     C                   eval      uxflag = *on
     C                   eval      prcrec = 5
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options

**  ZOPT4 - Valid options for WINDOW4
 1
**  ZOPT6 - Valid options for DSPSFL6
 1 X
**  OPTLN - Option display line




**  OPTLNS - Option line 1 for *SPRECV

**  CMDLN - Command display line
F3=Exit  F5=Refresh  F9=PO/Mfr Code  F24=More keys
F3=Exit  F5=Refresh  F9=PO/Item      F24=More keys
F3=Exit  F5=Ref  F9=PO/Mfr Code      F24=More keys
F3=Exit  F5=Ref  F9=PO/Item          F24=More keys
F12=Cancel  F24=More keys
F3=Exit  F5=Refresh  F9=PO/Mfr Code  F24=More keys
F3=Exit  F5=Refresh  F9=PO/Item      F24=More keys
F3=Exit  F5=Ref  F9=PO/Mfr Code      F24=More keys
F3=Exit  F5=Ref  F9=PO/Item          F24=More keys
**   OVRDBF statements
OVRDBF FILE(PO120A) TOFILE(POSPO) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120B) TOFILE(POSPO) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120C) TOFILE(POSPO2) SHARE(*YES) LVLCHK(*NO)
OVRDBF FILE(PO120D) TOFILE(POSPO2) SHARE(*YES) LVLCHK(*NO)
**   OPNQRYF statements for PO120A - whse/spo/po/item seq.
OPNQRYF FILE((POSPO) (PODTL)) FORMAT(PO120A) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789"')
KEYFLD((1/PUWHSE) (1/PUSPO) (1/PUPO) (2/PDITEM))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO *EQ))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO) SEQONLY(*NO)
**   OPNQRYF statements for PO120B - whse/spo/po/vitm seq.
OPNQRYF FILE((POSPO) (PODTL)) FORMAT(PO120B) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789"')
KEYFLD((1/PUWHSE) (1/PUSPO) (1/PUPO) (2/PDVITM))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO) SEQONLY(*NO)
**   OPNQRYF statements for PO120C - whse/spo/item/po seq.
OPNQRYF FILE((POSPO2) (PODTL)) FORMAT(PO120C) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDITEM = "123456789012345"')
KEYFLD((1/PUWHSE) (1/PUSPO) (2/PDITEM) (1/PUPO))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO)
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDITEM >="123456789012345"')
**   OPNQRYF statements for PO120D - whse/spo/vitm/po seq.
OPNQRYF FILE((POSPO2) (PODTL)) FORMAT(PO120D) QRYSLT('
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDVITM  ="123456789012345"')
KEYFLD((1/PUWHSE) (1/PUSPO) (2/PDVITM) (1/PUPO))
JFLD((1/PUWHSE 2/PDWHSE *EQ) (1/PUPO 2/PDPO))
OPTIMIZE(*FIRSTIO) JDFTVAL(*NO)
PUWHSE = 999 *AND PUSPO = "123456789" *AND PDVITM >="123456789012345"')
**   CLOF statement.
CLOF POSPO
CLOF POSPO2
