500bA*----------------------------------------------------------------
500bA*  Multilingual Verision
500bA*  Every screen and message has a corresponding Spanish version.
500bA*  Any changes must be made to both languages.
500bA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR680     RF Select Bulk Picks
     *  03 October 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 40 Screens for hand held scanners
     *      16 X 20 Screens
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    10/03/02  MLB  4.16
     *      - Created.
     *
417 A*    05/02/02  MLB  4.17
     *      - Enh: Revised program to allow bulk picks to be picked
     *        from multiple locations.
     *      - Added one new file: SLOT2.
417aA*    08/11/04  RH   4.17a
     *      - Fix: Revised to call GETSLOTITM, if the item was an
     *        alias item for a SSB item, GETBASE would return the SSB
     *        item which is not a slot item.
500aA*    03/29/06  RH   5.00a
     *      - ENH: Changed F10=Done to F9=Done to use F10 for Short.
     *
500bA*    06/02/06  JCJ  5.00b
     *      - Added Multilingual logic.
610aA*    11/08/10  RH   6.10a
     *      - ENH: Changed to call LT210 for license tracking.
     *      - Use DRISLOT to get slot info and license.
     *
640aA*    01/27/12  LMC  6.40a
     *      - Fix: Pass slot item to OR681 in $pitem field.
640bA*    05/25/12  RH   6.40b
     *      - Enh: Change screen to use TRAX label.
     *        Rename format to OR68001, screen field W1lbl#b
640cA*    06/06/12  LMC  6.40c
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    07/01/13  LMC  6.50a
     *      - Enh: Added the auto loading of CW records for UCI/GS1
     *      This process will only execute if the UCI receiving method
     *      on the item is set to UCI Receiving.
650bA*    02/27/14  RH/MLB  6.50b
     *      - Fix: Revised program to retrieve original bulk pick label
     *      record prior to call to PT132PL to update warehouse allocated
     *      quantity. Pgm was passing orginal pick quantity causing
     *      PT132PL to compute incorrect value to update whse allocated
     *      qty.
710aA*    06/14/17  RH      7.10a
     *      - Enh: Add license to screen 3, rename format member.     l
     *        Moved code to ZZGETS from ZZUPD3 to get slot info       l
720aA*    08/12/16  LMC  7.20a
     *      - Enh: UCI Tracking.
720bA*    12/26/18  LMC  7.20b
     *      - Enh: Added ability to pass the transation number from
     *        OR400 via new file BULKWRK.
730aA*    10/07/19  LMC  7.30a
     *      - Fix: Display screen 1 if error and we came from OR400
730bA*    12/30/19  DAS  7.30b
     *      - Fix: Revised ZZUPD4 to check for F10 as well as F9.
     *        At some point SCREEN4 must have been changed to use F9,
     *        but SCRN4SP is still using F10, which Panos uses.
740aA*    02/03/20  LMC  7.40a
     *      - Enh: Seton LR when using f3 from Screen1 if called
     *        from or400.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
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
640xDF*r680fm   cf   e             workstn
710aDF*or68001   cf   e             workstn
710aMFor68002   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(d16sflsp:recno)
417 D*LABEL   IF  E           K        DISK
417 MFLabel     uf   e           k disk
     FLabel7    if   e           k disk
650aAFliclog1   if   e           k disk    usropn
     Foptions   if   e           k disk
650aAFordc      uf a e           k disk    usropn
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpirtran3  if   e           k disk
     F                                     rename(ptrec:ptrec3)
417 AFslot2     uf   e           k disk
     Ftask      if   e           k disk
720bAFbulkwrk   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
417 D*                   DESC    1   9 50
417 MD desc            s             50    dim(11) ctdata perrcd(1)
500bAD descsp          s             50    dim(11) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#ITEM
610aA /COPY *libl/qcopysrc,C#SLOT
610aA /COPY *libl/qcopysrc,C#SLOTDEF
650aA /COPY *libl/qcopysrc,C#LICINFO
650aA /COPY *libl/qcopysrc,C#UCIINFO
650aA /COPY *libl/qcopysrc,C#CWLOG
610aAD saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *
     * Data structure
     *
     D opdat2          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opmpck                14     14
     D  opten2               117    117
     *
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
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     D  $pwhse                19     21  0
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
     D  $tmsgid        s              4
610aAD**wkType         s              3    INZ('TFR')

     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
     D  $ltrn1                19     25  0
     *
     D  $lwhdp                22     26
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
640bAD @cvtbarsel      c                   const('CVTBARSEL')
     D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjtd          c                   const('ADJTSKDET')
     *
     *----------------------------------------------------------------
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
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
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
     D  ertrn#                 1      4p 0
     D                 ds
     D  $ec                    1      2p 0
     D                 ds
     D  slctyp                 1      8
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500bAD #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Variables
     D $msgf           s             10
     D #bitem          s                   like(ititem)
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s                   like(itdesc)
     D #odesg          s                   like(itdesg)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #owhdp          s                   like(itwhdp)
610aDD*#pgmq           s             10
     D #sitem          s                   like(ititem)
650aAD #scwgt          s                   like(itcwgt)
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

     D balqty          s                   like(lbqpck)
610aAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
610aAD curlic#         s                   like($tlic#)
     D curtrn          s              7  0
     D curtsk          s              6
     D curtyp          s              1
650aAD  CWcmd          s             10
650aAD  CWpgm          s             10
650aAD  CWrtn          s             10
650aAD  CWmsg          s             60
650aAD  CWdata         s            512
     D done            s              1
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D fintim          s                   like(ptetim)
     D forevr          s              1
     D found           s              1
     D help            s              5  0
     D itminf          s              1
     D kyrtpo          s                   like(ptrtpo)
     D kystat          s                   like(ptstat)
     D kytrn#          s                   like(pttrn#)
     D kywhse          s                   like(w1whse)
     D lstscr          s              3
     D msgk            s              4  0
650aAD Newseq          s              3  0
     D nxtscr          s              3
650aAD  processstatus  s             10
     D recno           s              7  0
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D savtrn          s                   like(pttrn#)
     D savtsk          s                   like(pttask)
     D sclear          s              1
     D shrtqy          s              4
     D stdate          s                   like(ptsdte)
     D strtim          s                   like(ptstim)
     D sttime          s                   like(ptstim)
     D svdisp          s                   like(lbdisp)
     D svqpck          s                   like(lbqpck)
     D svtlen          s                   like(ptdmin)
     D svtrn#          s                   like(pttrn#)
     D t#task          s              6
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D topick          s                   like(lbqpck)
     D warn            s              1
     D wkgrp1          s                   like(ptgrp1)
     D wkgrp2          s                   like(ptgrp2)
     D wotrn#          s                   like(pttrn#)
640cAD wrtpcmd         s             10
640cAD wrtpwait        s              2  0
640cAD wrtpwhse        s              3  0
640cAD wrtptran#       s                   like(pttrn#)
640cAD wrtpfrmdate     s              8  0
640cAD wrtptodate      s              8  0
640cAd wrtpemp#        s                   like(ptemp#)
     D w1crew          s                   like(ptcrew)
     D w1emp#          s                   like(ptemp#)
640bAD w1lbl#          s              7  0
     D w1shft          s                   like(ptshft)
     D w1styp          s                   like(ptstyp)
     D w1task          s              6
610aAD zmsflag         s               n
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
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
640cA*----------------------------------------------------------------
640cA*  Prototypes
640cA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
640cA
640cAD wrttran1        pr                  extpgm('WRTTRAN1')
640cA * Input
640cAD   ppcmd                        8
640cAD   ppwait                       2  0
640cAD   ppwhse                       3  0
640cAD   pptran#                      7  0
640cAD   ppfromdate                   8  0
640cAD   pptodate                     8  0
640cAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
417 AC     nxtscr        caseq     '05 '         sc5
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
     C                   when      nxtscr = '01 '
720bAc                   if        blktrn = 0
730aAc                             or error = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn1sp                              50
500bAC                   other
     C                   exfmt     screen1                              50
500bAC                   endsl
720bAc                   endif
     *
     C                   when      nxtscr = '02 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     dspsfcsp                             50
500bAC                   other
     C                   exfmt     dspsfc                               50
500bAC                   endsl
     *
     C                   when      nxtscr = '03 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn3sp                              50
500bAC                   other
     C                   exfmt     screen3                              50
500bAC                   endsl
     *
     C                   when      nxtscr = '04 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn4sp                              50
500bAC                   other
     C                   exfmt     screen4                              50
500bAC                   endsl
417 A*
417 AC                   when      nxtscr = '05 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn5sp                              50
500bAC                   other
417 AC                   exfmt     screen5                              50
500bAC                   endsl
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
     C                   setoff                                       3334
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
     C                   eval      *in92 = *off
     C                   eval      slctyp = *blanks
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
417 AC                   eval      shrtqy = '*NO '
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzget4
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     *
     C     end04i        endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  Screen 05 initialization
417 A*
417 AC     scr05i        begsr
417 AC                   eval      nxtscr = '05 '
417 AC                   exsr      zzget5
417 AC                   exsr      zzfil5
417 AC                   eval      refrsh = *off
417 AC     end05i        endsr
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
     C                   eval      nxtscr = 'EOJ'
740aAC                   if        blktrn > 0
740aAC                   eval      *inlr = '1'
740aAc                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   eval      lstscr = nxtscr
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
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
     C                   eval      nxtscr = '01 '
     C                   exsr      scr01i
     C                   goto      endsc2
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
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '01 '
     C                   exsr      scr01i
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
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
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
     C                   eval      pttrn# = savtrn
     C                   eval      pttask = savtsk
     C                   exsr      zzabrt
     C                   select
720bA*    Return to calling program OR400
720bAC                   when      blktrn > 0
720bAC                   eval      nxtscr = 'EOJ'
720bAC                   eval      *inlr = '1'
     *    Return to select screen.
     C                   when      lstscr = '02 '
     C                   exsr      scr02i
     *
     *    Return to screen 1.
     C                   when      lstscr = '01 '
     C                   exsr      scr01i
     *
     C                   other
     C                   exsr      scr01i
     C                   endsl
     *
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
     C                   eval      refrsh = *off
     C                   eval      pttrn# = savtrn
     C                   eval      pttask = savtsk
     C                   exsr      zzabrt
     C                   select
720bA*    Return to calling program OR400
720bAC                   when      blktrn > 0
720bAC                   eval      nxtscr = 'EOJ'
720bAC                   eval      *inlr = '1'
     *    Return to select screen.
     C                   when      lstscr = '02 '
     C                   exsr      scr02i
     *
     *    Return to screen 1.
     C                   when      lstscr = '01 '
     C                   exsr      scr01i
     *
     C                   other
     C                   exsr      scr01i
     C                   endsl
     *
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
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C     redspl        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4  (Screen1A)
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     *
     C                   exsr      scr03i
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
     C                   exsr      scr03i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
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
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  SC5  -  Screen 5
417 A*
417 AC     sc5           begsr
417 A*
417 A*  Test for F3 - Exit
417 A*
417 AC                   if        *inkc
417 AC                   goto      endsc5
417 AC                   endif
417 A*
417 A*  Test for F5 - Refresh
417 A*
417 AC                   if        *inke
417 AC                   eval      refrsh = *on
417 AC                   exsr      scr05i
417 AC                   goto      endsc5
417 AC                   endif
417 A*
417 A*  Test for F12 - Previous
417 A*
417 AC                   if        *inkl
417 AC                   goto      endsc5
417 AC                   endif
417 A*
417 A*  Test for other command keys BEFORE verification and update.
417 A*
417 AC                   eval      cmdchk = '*BEFORE '
417 AC                   exsr      zzcmd5
417 AC     cmdtkn        cabeq     *on           endsc5
417 A*
417 A*  Some other key pressed.
417 A*
417 A*     Check input and write/update record.
417 A*
417 AC                   exsr      zzchk5
417 AC     error         cabeq     *on           endsc5
417 AC     redspl        cabeq     *on           endsc5
417 AC                   exsr      zzupd5
417 AC     error         cabeq     *on           endsc5
417 A*
417 A*  Test for other command keys AFTER verification and update.
417 A*
417 AC                   eval      cmdchk = '*AFTER  '
417 AC                   exsr      zzcmd5
417 AC     cmdtkn        cabeq     *on           endsc5
417 A*
417 AC     endsc5        endsr
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
650aA*---------------------------------------------------------------
650aA*
650aA*    AUTOLOADCW auto load catch weight from UCI info File
650aA*
650aA*---------------------------------------------------------------
650aA /free
650aA   begsr autoloadcw;
650aA     // now check to see if catch weights can be auto loaded
650aA     if #scwgt <> 'Y';
650aA       leavesr;
650aA     endif;
650aA     // get data from itemfld
650aA     exsr clr$item;

650aA     $itWhse = lbwhse;
650aA     $ititem = #sitem;

650aA     $dricommand = '*ITEM';
650aA     $drisubcmd  = '%GETALL';
650aA     $drisys2upd = 'D';
650aA     chk4err = *on;
650aA     exsr zzzdricop;
650aA     if error = *on;
650aA       $ifrcvmth = ' ';
650aA     endif;
650aA     if $ifrcvmth <> '2';
650aA       leavesr;
650aA     endif;

650aA     // if multiple license in overflow slot we can not auto load.
650aA     // so get out of here.
650aA     if $toutlic# = '*MULTIPLE';
650aA       leavesr;
650aA     endif;

650aA     exsr clr$licinfo;

650aA     $lnwhse  = lbwhse;
650aA     $lnlcns  = $toutlic#;
650aA     $lnseq = 1;

650aA     $dricommand = '*LICINFO';
650aA     $drisubcmd  = '%GET';
650aA     $drisys2upd = 'D';
650aA     chk4err = *on;
650aA     exsr zzzdricop;

650aA     if error = *on;
650aA       leavesr;
650aA     endif;

650aA     // first lets check the qty being pulled against the rcv qty
650aA     // on the license - if they are different we can't continue
650aA     if $lnrcvqty <> w3nqty;
650aA       leavesr;
650aA     endif;

650aA     // continue by checking to make sure license has had NO
650aA     // adjustments or selections.
650aA     if not %open(liclog1);
650aA       open liclog1;
650aA     endif;
650aA     setll (lbwhse: $toutlic#) liclog1;
650aA     dow not %eof(liclog1);
650aA       reade (lbwhse: $toutlic#) liclog1;
650aA       if %eof(liclog1);
650aA         leave;
650aA       else;
650aA         // is log for action ADJ or SEL
650aA         if llaction = 'ADJ';
650aA           close liclog1;
650aA           leavesr;
650aA         endif;
650aA         if llaction = 'SEL';
650aA           close liclog1;
650aA           leavesr;
650aA         endif;
650aA       endif;
650aA     enddo;

650aA     // if we get here then no adj or selection log records for license
650aA     // finally now go see if we have uci records for this license
650aA     // Check to make sure we have the same qty of UCI records
650aA     exsr clr$uciinfo;

650aA     $uiWhse = lbwhse;
650aA     $uilcns = $toutlic#;

650aA     $dricommand = '*UCIINFO';
650aA     $drisubcmd  = '%CNT4BLK';
650aA     $drisys2upd = 'D';
650aA     exsr zzzdricop;

650aA     // if return is *BULKQTY1 - NO UCI Were Found - so get out
650aA     if $drireturn   = '*BULKQTY1';
650aA       leavesr;
650aA     endif;

650aA     // if return is *BULKCNT  - pmessage holds the uci count
650aA     if $drireturn   = '*BULKCNT';
650aA       // count must be same as qty being pulled
650aA       if w3nqty <> %dec($drimessage:5:0);
650aA         leavesr;
650aA       endif;
650aA     endif;
650aA     // we have UCI's with catch weights that can be auto loaded to
650aA     // ORDC and UCIINFO file can be updated with the selection
650aA     // order/tran/label. CWLOG file is also loaded.

650aA     if not %open(ordc);
650aA       open ordc;
650aA     endif;
650aA     dou $drireturn = '*DONE';
650aA       exsr clr$uciinfo;

650aA       $uiWhse = lbwhse;
650aA       $uilcns = $toutlic#;

650aA       $dricommand = '*UCIINFO';
650aA       $drisubcmd  = '%GET4BLK';
650aA       $drisys2upd = 'D';
650aA       chk4err = *on;
650aA       exsr zzzdricop;
650aA       if $drireturn <> '*DONE';
650aA         exsr douciwgt;
650aA         // now post seq number and selection data into UCIINFO file
650aA         $uiseltrn# = lbtrn#;
650aA         $uisellbl# = lblbl#;
650aA         $uiselord  = lbord;
650aA         $uiselseq  = lbseq;
650aA         $uiselcseq = ocseq;

720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'SELBULK';
720aA         $uiaolcns = $uiaOlcns;
720aA         $uiaoseq = $uiaOseq;
720aA         $uiscan = ' ';
720aA         $uitran# = lbtrn#;
720aA         $uilbl# = lblbl#;

650aA         $dricommand = '*UCIINFO';
650aA         $drisubcmd  = '%SEL4BLK';
650aA         $drisys2upd = 'D';
650aA         chk4err = *on;
650aA         exsr zzzdricop;
650aA       endif;
650aA     enddo;
650aA     if %open(ordc);
650aA       close ordc;
650aA     endif;
650aA   endsr;
650aA /end-free
650aA*----------------------------------------------------------------
650aA*
650aA*  DoUCIwgt      Create catchweight record in ORDC.
650aA*
650aAC     DoUCIwgt      begsr
650aAC
650aAC     Ockey         SetGt     Ordc
650aAC     Ockey         ReadPe(n) Ordc

650aAC                   If        %eof(ordc)
650aAC                   Eval      Ocseq = 0
650aAC                   Endif
650aAC                   Eval      NewSeq = OcSeq + 1

650aAC                   Clear                   OcRec
650aAC     OcNkey        Chain     Ordc
650aAC                   If        not %found(ordc)
650aAC                   Eval      OcWhse = LbWhse
650aAC                   Eval      OcOrd  = LbOrd
650aAC                   Eval      OcSeq# = LbSeq
650aAC                   Eval      OcItem = LbItem
650aAC                   Eval      OcSeq  = NewSeq
650aAC                   Eval      Occwgt = $uiwgtlbs
650aAC                   Eval      OcTran = LbTrn#
650aAC                   Eval      OcLbl# = LbLbl#
650aAC                   Write     OcRec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processcwlog
650aAC                   Else
650aAC                   Eval      OcTran = LbTrn#
650aAC                   Eval      Occwgt = $uiwgtlbs
650aAC                   Update    OcRec
650aAc                   eval      processstatus = '*UPDATE'
650aAc                   exsr      processcwlog
650aAC                   Endif
650aAC
650aAC                   Endsr

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwscan = ' ';
650aA     $cwwgtlbs = occwgt;
650aA     $cwentflg = 4;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA     select;
650aA       when %error;
650aA         error = *on;
650aA       when cwrtn <> '*OK';
650aA         error = *on;
650aA     endsl;
650aA   endsr;
650aA /end-free
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
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      $msgf = #msgsp
500bAC                   other
     C                   eval      $msgf = #msgf
500bAC                   endsl
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
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   eval      $msgf = #msgsp
600dAC                   other
     C                   move      #msgf         $msgf
600dAC                   endsl
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

415bA*----------------------------------------------------------------
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
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20001  Invalid slot entered.(TO)
     *
     C     zm2001        begsr
     C                   eval      #msgid = 'RC20001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20002 Transaction is closed.
     *
     C     zm2002        begsr
     C                   eval      #msgid = 'RC20002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20008 License/Label already scanned in.
     *
     C     zm2008        begsr
     C                   eval      #msgid = 'RC20008'
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
     *   PIR0204  Enter only one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm0205        begsr
     C                   eval      #msgid = 'PIR0205'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      slctyp = *blanks
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *   Verify department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Enter only one, license, trans # or label #.
     *
     C                   if        w1trn# <> 0  and
640bDC**                           w1lbl# <> 0
640bMC                             w1lbl#b <> *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm0204
     C                   endif
     *
     *  Must enter one, license, transaction or label number.
     *
     C                   if        w1trn# = 0  and
640bDC**                           w1lbl# = 0
640bMC                             w1lbl#b = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm0205
     C                   endif
     *
     *  Verify transaction number.
     *
     C                   eval      wotrn# = *zeros
     C                   if        w1trn# <> 0  and
640bDC**                           w1lbl# = 0
640bMC                             w1lbl#b = *blanks
     C                   eval      slctyp = '*TRNNBR '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ltrn1 = w1trn#
     C                   exsr      zztrn#
     C                   if        error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   else
     C                   eval      wotrn# = w1trn#
     C                   endif
     C                   endif
     *
     *  Verify label number.
     *
     C                   if        w1trn# = 0  and
640bDC**                           w1lbl# <> 0
640bMC                             w1lbl#b <> *blanks
     C                   eval      slctyp = '*LBLNBR '
     *
     * grab label#
640bAC                   move      w1whse        $pwhseb
640bAC                   movel     w1lbl#b       $pbarcode
640bAC                   call      @cvtbarsel
640bAC                   parm                    $pwhseb           3
640bAC                   parm                    $pbarcode        15
640bAC                   parm                    $plbl#            7 0
640bAC                   parm                    $prtid            5
640bAC                   parm                    $punq#            5
640bAC                   parm                    $preturn          8
640bAC                   parm                    $perrmsg         60
640bAC                   if        $preturn = '*OK'
640bAC                   eval      w1lbl# = $plbl#
640bAC                   move      *blanks       w1lbl#b
640bAC                   move      $plbl#        w1lbl#b
640bAC                   else
640bAC                   eval      error = *on
640bAC                   eval      *in23 = *on
640bAC                   eval      *in03 = *on
640bAC                   select
640bAC                   when      e$lng = 'SP'
640bAC                   eval      errmsg = descsp(5)
640bAC                   other
640bAC                   eval      errmsg = desc(5)
640bAC                   endsl
640bAC                   exsr      zm0105
640bAC                   endif
640bA*
417 D*R         W1LBL#    CHAINLABEL                7877
417 MC     w1lbl#        chain(n)  label                              7877
     C                   select
     *
     *    Label not found.
     C                   when      *in78
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(5)
500bAC                   other
     C                   eval      errmsg = desc(5)
500bAC                   endsl
     C                   exsr      zm0105
     *
     *    Label record inuse.
     C                   when      *in77
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(7)
500bAC                   other
     C                   eval      errmsg = desc(7)
500bAC                   endsl
     C                   exsr      zm0105
     *
     *    Bulk pick in wrong department.
     C                   when      lbwhdp <> w1whdp
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      error = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(4)
500bAC                   other
     C                   eval      errmsg = desc(4)
500bAC                   endsl
     C                   exsr      zm0105
     *
     *    Label not a "Bulk Pick" label.
     C                   when      lbtype <> 'B'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = %trimr(descsp(2)) + ' ' + descsp(6)
500bAC                   other
     C                   eval      errmsg = %trimr(desc(2)) + ' ' + desc(6)
500bAC                   endsl
     C                   exsr      zm0105
     *
     *    Label not at "picked" status any longer.
     C                   when      lbstat <> 'P'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(8)
500bAC                   other
     C                   eval      errmsg = desc(8)
500bAC                   endsl
     C                   exsr      zm0105
     *
     *    Good Label number entered. Verify Transaction number.
     C                   other
     C                   eval      wotrn# = lbtrn#
     C                   endsl
     *
     C                   endif
     *
     *  Make sure that the transaction is open.
     *
     C                   if        wotrn# > 0
     C     ptkey         chain(n)  pirtran                            79
     *
     C                   select
     *    Transaction no longer at 'Open' status.
     C                   when      not *in79  and
     C                             ptstat <> '1'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = pttrn#
     C                   exsr      zm2002
     *
     *    Transaction not for right 'Department'.
     C                   when      not *in79  and
     C                             ptwhdp <> w1whdp
     C                   eval      error = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(4)
500bAC                   other
     C                   eval      errmsg = desc(4)
500bAC                   endsl
     C                   exsr      zm0105
     *
     *    Transaction not a 'Bulk Pick'.
     C                   when      not *in79  and
     C                             pttask <> 'BULKF '  and
     C                             pttask <> 'BULKP '  and
     C                             pttask <> 'BULKR '
     C                   eval      error = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = %trimr(descsp(1)) + ' ' + descsp(6)
500bAC                   other
     C                   eval      errmsg = %trimr(desc(1)) + ' ' + desc(6)
500bAC                   endsl
     C                   exsr      zm0105
     *
     C                   endsl
     *
     C                   select
     C                   when      error = *on
     C                   select
     C                   when      slctyp = '*LBLNBR '
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   when      slctyp = '*TRNNBR '
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endsl
     *
     *    Save transaction number for later processing.
     C                   when      error = *off
     C                   eval      savtrn = pttrn#
     C                   eval      savtsk = pttask
     C                   endsl
     *
     C                   endif
     *
     C     endck1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     C     endck2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     *
     C                   eval      error = *off
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w3scan
     C                   parm      6             worow
     C                   parm      7             wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck3
     C                   endif
     *
     *    Wrong slot scanned.
     C                   if        w3scan <> w3fmsl
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(9)
500bAC                   other
     C                   eval      errmsg = desc(9)
500bAC                   endsl
     C                   exsr      zm0105
     C                   endif
417 A*
417 A*    Bulk Pick qty cannot be less than zero.
417 A*
417 AC                   if        w3nqty <= 0
417 AC                   eval      error = *on
417 AC                   eval      *in26 = *on
417 AC                   eval      *in06 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(10)
500bAC                   other
417 AC                   eval      errmsg = desc(10)
500bAC                   endsl
417 AC                   exsr      zm0105
417 AC                   endif
417 A*
417 A*    Bulk Pick qty cannot be greater than Original Bulk qty.
417 A*
417 AC                   if        w3nqty > svqpck
417 AC                   eval      error = *on
417 AC                   eval      *in26 = *on
417 AC                   eval      *in06 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(11)
500bAC                   other
417 AC                   eval      errmsg = desc(11)
500bAC                   endsl
417 AC                   exsr      zm0105
417 AC                   endif
     *
     C     endck3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     *
     C     endck4        endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZCHK5   Screen 5 error checking.
417 A*
417 AC     zzchk5        begsr
417 AC                   eval      error = *off
417 A*
417 AC     endck5        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   select
     C                   when      cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   select
     C                   when      *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 3
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Warehouse department.
     *
     C                   when      row# = 4
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     *
     C                   goto      endcm1
     *
     *   New function key(s) go here.
     *R         *INxx     WHEQ *ON
     *
     C                   endsl
     *
     *-----------------------------------------------------
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   when      cmdchk = '*AFTER  '
     *
     C                   endsl
     *
     C     endcm1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   select
     C                   when      cmdchk = '*BEFORE '
     *
     *-----------------------------------------------------
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   when      cmdchk = '*AFTER  '
     *
     C                   endsl
     *
     C     endcm2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   select
     C                   when      cmdchk = '*BEFORE '
     *
     *  Test for F8 - List available slots.
     *
     C                   select
     C                   when      *inkh
417 AC                   eval      $lcmd = '*UPDBULK'
     C                   exsr      zzlist
     C                   eval      cmdtkn = *on
     C                   goto      endcm3
     C                   endsl
     *
     *-----------------------------------------------------
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   when      cmdchk = '*AFTER  '
     *
     C                   endsl
     *
     C     endcm3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   select
     C                   when      cmdchk = '*BEFORE '
     *
     *-----------------------------------------------------
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   when      cmdchk = '*AFTER  '
     *
     C                   endsl
     *
     C     endcm4        endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZCMD5   User defined command keys for screen 5.
417 A*
417 AC     zzcmd5        begsr
417 A*
417 A*  Command keys to check BEFORE verification and update.
417 A*
417 AC                   select
417 AC                   when      cmdchk = '*BEFORE '
417 A*
417 A*  Test for F8 - List available slots.
417 A*
417 AC                   select
417 AC                   when      *inkh
417 AC                   if        $lcmd <> '*UPDBULK'  and
417 AC                             $lcmd <> '*CRTBLKL'
417 AC                   eval      $lcmd = '*CRTBLKL'
417 AC                   endif
417 AC                   exsr      zzlist
417 AC                   eval      cmdtkn = *on
417 AC                   goto      endcm5
500aA*  Test for F10 - Short pick
500aAC                   when      *inkj
     *   Retrieve current task.
500a C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     C****               eval      lstscr = '03 '
     C                   exsr      scr04i
417 A*
417 AC                   endsl
417 A*
417 A*-----------------------------------------------------
417 A*
417 A*  Command keys to check AFTER verification and update.
417 A*
417 AC                   when      cmdchk = '*AFTER  '
417 A*
417 AC                   endsl
417 A*
417 AC     endcm5        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
720bAc** do we have a transaction in bulkwrk - if so it was sent
720bAc** from OR400
720bA /free
720bA  chain (w1emp#) bulkwrk;
720bA /end-free
720bAc                   if        %found(bulkwrk)
720bAc                   eval      w1trn# = blktrn
720bAc                   else
     C                   eval      w1trn# = *zeros
720bAc                   eval      blktrn = 0
720bAc                   endif
     C                   eval      w1lbl# = *zeros
640bAC                   eval      w1lbl#b = *blanks
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3fmsl = lbdisp
417 AC                   eval      svdisp = lbdisp
417 D*R                   Z-ADDLBQPCK    W3QTY
417 MC                   eval      w3nqty = lbqpck
417 AC                   eval      svqpck = lbqpck
     C                   eval      w3umsr = umshrt
710aAC                   eval      w3lcns = curlic#
     C                   eval      w3scan = *blanks
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     C                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZFIL5   Fill screen 5 fields with info from file.
417 A*
417 AC     zzfil5        begsr
417 A*
417 AC                   eval      w5item = w3item
417 AC                   eval      w5umsr = w3umsr
417 AC                   eval      w5disp = svdisp
417 AC                   eval      w5oqty = svqpck
417 AC                   eval      w5balq = balqty
417 A*
417 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get screen 3 info.
     *
     C     zzget3        begsr
     C                   eval      error = *off
710aA*  Get slot information
710aAC                   exsr      zzgets
710a
710aAC                   if        error = *on
710aAC                   goto      endzg3
710aAC                   endif
     *
     C     endzg3        endsr
     *
     *----------------------------------------------------------------
     *
     C     zzget4        begsr
     *
     C                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 AC     zzget5        begsr
417 A*
417 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      forevr = *off
     C                   eval      done = *off
     *
     *  Define save fields for different item types.
     *
     C                   eval      #otype = *blanks
     *
     *  Define partial key for LABEL7 file.
     *
     C     lbkey7        klist
     C                   kfld                    pttrn#
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *  Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    wotrn#
     *
     *    Define partial key for PIRTRAN3 file.
     *
     C                   eval      wkgrp1 = 'S'
     C                   eval      wkgrp2 = ' '
     C     ptkey3        klist
     C                   kfld                    w1whse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     *
     *    Define Full key for PIRTRAN3 file.
     *
     C     ptky3a        klist
     C                   kfld                    w1whse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     C                   kfld                    kyrtpo
     C                   kfld                    kytrn#
417 A*
417 A*  Define full key for SLOT2 file.
417 A*
417 AC     slkey         klist
417 AC                   kfld                    w1whse
417 AC                   kfld                    lbwhdp
417 AC                   kfld                    lbdisp
     *
     *  Define key for options file, System values.
     *
     C     optsky        klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C     tkkey         klist
     C                   kfld                    t#task
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
     *  Define key for PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    w1emp#
     C                   kfld                    kystat
650aA*
650aA*  Define key for ORDC file.
650aA*

650aAC     Ockey         KList
650aAC                   Kfld                    Lbwhse
650aAC                   Kfld                    Lbord
650aAC                   Kfld                    Lbseq
650aAC                   Kfld                    Lbitem
650aAC                   Kfld                    Lblbl#

650aAC     OcNkey        Klist
650aAC                   Kfld                    Lbwhse
650aAC                   Kfld                    Lbord
650aAC                   Kfld                    Lbseq
650aAC                   Kfld                    Lbitem
650aAC                   Kfld                    Lblbl#
650aAC                   Kfld                    NewSeq

     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
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
500bD **                 when      #lline = '16'
500bMC                   when      #lline = '16' and e$lng = 'SP'
500bAC                   write     d16sflsp                             79
500bAC                   when      #lline = '16' and e$lng = 'EN'
     C                   write     d16sfl                               79
500bD **                 other
500bAC                   when      #lline <> '16' and e$lng = 'SP'
500bAC                   write     dspsflsp                             79
500bAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   write     dspsfl                               79
     C                   endsl
     *
     *    - Get employee number, default dept and section.
     *
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm      ' '           #fnam            15
     C                   parm      ' '           #init             1
     C                   parm      ' '           #lnam            20
     C                   parm      ' '           #whdp             5
     C                   parm      ' '           #styp             1
     C                   parm      ' '           #shft             6
     C                   parm      ' '           #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm      ' '           #rtn              8
500bAC                   parm                    e$bpu             1
500bAC                   parm                    e$lng             2
500bAC                   if        #rtn <> '*OK'
500bAC                   eval      e$lng = 'EN'
500bAC                   endif
     *
     C                   eval      w1whse = #whse
     C                   eval      w1emp# = #emp#
     C                   eval      w1whdp = #whdp
     C                   eval      w1styp = #styp
     C                   eval      w1shft = #shft
     C                   eval      w1crew = #crew
     *
     C                   eval      itminf = *off
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
417 AC                   eval      shrtqy = '*NO '
     *
     C                   exsr      zzsopt
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
     *
     C                   eval      @ptask = pttask
     C                   eval      @pcube = lbcube
     C                   eval      @pswgt = lbswgt
     C                   call      @adjtr
     C                   parm      '*UNDO   '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *    Start an 'IDLE' task.
     C                   exsr      zzidle
     *
     C     endabr        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = 0
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
640cAc                   exsr      zzwrttrand
     C                   endif
     C     endcu2        endsr
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
640cAc                   exsr      zzwrttrand
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
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     C     itminf        cabeq     *on           #geti
     *
     *  LABEL7 file is a Join file with PIRITEM and hence, no need
     *  to chain to that file.
     *
     C                   eval      w3item = *blanks
     C                   eval      $iitem = lbitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w3item
     *
     *  Get item record.  Yes, the LABEL7 file contains item information,
     *    but it does not contain the item type field ITTYPE.
     *
     C     #geti         tag
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      ittype = *blanks
     C                   eval      itum1 = *blanks
     C                   eval      itum2 = *blanks
     C                   eval      itum3 = *blanks
     C                   endif
     *
     *  Save information about item being received (Item that was ordered)
     *
     C                   eval      #otype = ittype
     C                   eval      #oitem = lbitem
     C                   eval      #owhdp = itwhdp
     C                   eval      #odesc = itdesc
     C                   eval      #opdsc = itpdsc
     C                   eval      #bitem = lbitem
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     C                   eval      #odesg = itdesg
     C                   eval      #bitem = ititem
417aAC                   eval      #sitem = ititem
     C                   eval      #bstyp = itstyp
650aAC                   eval      #scwgt = itcwgt
     *
     *  If Contract, Alias or SSB Item
     *   Then verify Base item exists.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     *
     C                   call      'GETBASE'
     C                   parm      lbwhse        $gwhse            3 0
     C                   parm      lbitem        $gitem           15
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     *
     C                   endif
417aA*   Get slot item.
417aAC                   call      @getsi
417aAC                   parm      lbwhse        $gwhse
417aAC                   parm      lbitem        $gitem
417aAC                   parm      ' '           #sitem
417aAC                   parm                    #sityp            1
417aAC                   parm                    #sdesc           30
417aAC                   parm                    #spdsc           15
417aAC                   parm                    #srtn            10
417aAC                   parm                    #smsg            60
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETS   Get slot information.
     *
     C     zzgets        begsr
     C                   eval      error = *off
610aA*  Use DRI interface to get slot information.
610aA
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = lbwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = lbdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgts
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
    AC                   eval      curlic# = #fromToLcns
     *
     C     endgts        endsr
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
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = w1whdp
     C                   eval      ptstyp = w1styp
     C                   when      tktlvl = 'D'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = w1whdp
     C                   eval      ptstyp = *blanks
     C                   other
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   endsl
     C                   eval      ptshft = w1shft
     C                   eval      ptcrew = w1crew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
     C                   write     ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endidl
     C                   endif
640cAc                   exsr      zzwrttrand
     *
     C     endidl        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZLIST   Call to display new Bulk Pick Locations.
     *
     C     zzlist        begsr
     C                   eval      error = *off
     C                   eval      done = *off
     *
     *    Display list of slots item occupies.
     *
     C                   eval      $whse = w1whse
     C                   eval      $whdp = lbwhdp
610aDC*                  eval      $item = lbitem
640aDC*                  eval      $pitem = lbitem
640aMC                   eval      $pitem = #sitem
     C                   eval      $newsl = *blanks
417 D*R                   MOVE LBDISP    $DISP
     C                   eval      $lbl# = lblbl#
     C                   eval      $trn# = lbtrn#
     C                   eval      $bat# = lbpbat
417 A*
417 AC                   select
417 AC                   when      $lcmd = '*UPDBULK'
417 AC                   eval      $disp = svdisp
417 AC                   if        shrtqy = '*YES'
417 AC                   eval      $blkq = balqty
417 AC                   else
     C                   eval      $blkq = lbqpck
417 AC                   endif
417 AC                   eval      $oblkq = svqpck
417 A*
417 AC                   when      $lcmd = '*CRTBLKL'
417 AC                   eval      $disp = svdisp
417 AC                   eval      $blkq = balqty
417 AC                   eval      $oblkq = svqpck
417 A*
417 AC                   endsl
417 A*
     C                   eval      $task = pttask
     C                   eval      $prg = #prog
     *
417 D*R                   MOVE '*UPDBULK'$LCMD
     C                   call      'OR681'
     C                   parm                    $lcmd
     C                   parm                    $prtky
     C                   parm      *blanks       $lrtn
     *
     *    Clear lines from previous display. They are left over when
     *    working with 16 line displays, and screen 3 is only 8 lines.
     C                   write     clrscr
     *
     *    New slot selected for Bulk Pick - Proceed to confirm display.
     *
417 AC                   select
417 AC                   when      $lrtn = '*BALANCE'
417 AC                   eval      balqty = $blkq
417 AC                   eval      $lcmd = '*CRTBLKL'
417 AC                   exsr      scr05i
417 A*
417 D*R         $LRTN     IFEQ '*OK     '
417 MC                   when      $lrtn = '*OK     '
     C                   eval      kyrtpo = lbrte
     C                   eval      kytrn# = $trn#
     C     ptky3a        setll     pirtran3
     C     #list1        tag
     C     ptkey3        reade     pirtran3                               77
     *    - EOF
     C                   if        *in77
     C                   eval      done = *on
     C                   goto      endlst
     C                   endif
     *
     *    - Wrong transaction number.
     C                   if        pttrn# <> $trn#
     C                   goto      #list1
     C                   endif
     *
     *    - Transaction Not in inuse status.
     C                   if        ptstat <> '2'
     C                   goto      #list1
     C                   endif
     *
     *    - Different department.
     *
     C                   if        ptwhdp <> w1whdp
     C                   goto      #list1
     C                   endif
     *
     *    Found Bulk Pick rcd - Process it.
     C                   eval      svtrn# = pttrn#
     *
417 M*    - Get bulk pick record. Bulk pick may have multiple label rcds
     *      per transaction number.
     *
     C     lbkey7        setll     label7
417 AC     #list2        tag
     C     lbkey7        reade     label7                                 79
     C                   if        *in79
     C                   eval      done = *on
     C                   goto      endlst
     C                   endif
     *
     *    - Wrong New Bulk Pick slot.
     C                   if        lbdisp <> $newsl  and
     C                             $newsl > *blanks
417 D*R                   GOTO #LIST1
417 MC                   goto      #list2
     C                   endif
     *
     *   Retrieve current task.
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     *    Direct user to bulk pick confirmation screen.
     *
     C                   exsr      scr04i
     *
417 D*R                   ENDIF                           End $lrtn = *OK
417 MC                   endsl
     *
     C     endlst        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSOPT   Get use system options.
     *
     C     zzsopt        begsr
     *
     *
     *   Get System options.
     *
     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM '
     C     optsky        chain     options                            79
     C                   if        *in79
     C                   eval      opmpck = 'N'
     C                   else
     C                   eval      opdat2 = opdata
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new transaction
     *
     C     zzstrt        begsr
     *
     *     - Get label record. Put-Away has only one label record
     *       per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7                                 79
     C                   eval      @ptask = pttask
     C                   eval      @pcube = lbcube
     C                   eval      @pswgt = lbswgt
     C                   call      @adjtr
     C                   parm      '*START  '    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#
     C                   parm                    @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      lbwhdp        @pwhdp
     C                   parm      lbstyp        @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      ' '           @ppo
     C                   parm      'P'           @pgrp1
     *R                   PARM 'L'       @PGRP1  1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C     endstr        endsr
     *
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
     C                   eval      timlen = 0
     C                   endif
     *
     C     endtim        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZTRN#   Verify transaction number.
     *
     C     zztrn#        begsr
     *
     C                   call      'PT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *   Get current task.
     *
     C                   exsr      zztask
     C                   select
     C                   when      curtyp = 'D'
     *   End current task.
     C                   exsr      zzend
     C                   when      curtyp = 'I'
     *  End current task and any previous open tasks.
     C                   eval      found = *on
     C                   dow       found = *on
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C                   if        found = *off
     C                   leave
     C                   endif
     C                   exsr      zzend
     C                   enddo
     C                   endsl
     *
     *   Start Bulk Pick transaction.
     *
     C                   eval      pttrn# = savtrn
     C                   eval      pttask = savtsk
     C                   exsr      zzstrt
     C                   exsr      zzgeti
417 A*    Load hold fields.
417 AC                   eval      svqpck = lbqpck
417 AC                   eval      svdisp = lbdisp
     *
     C                   eval      lstscr = '01 '
     C                   exsr      scr03i
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
710a *  Code moved to ZZGETS and removed from below
710aAC                   exsr      zzgets
     C                   if        error = *on
     C                   goto      endup3
     C                   endif

610aA
610aA*    Call program that will (if necessary) ...
610aA*      - Prompt user to pull pallet.
610aA*      - Have user verify license being pulled.
610aA*      - Update license information.
610aA
610aAC                   exsr      zzzclr$lt210
610aAC                   eval      $tcmd  = '*PULDROP'
610aAC                   eval      $twhse = w1whse
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
610aAC**                 eval      nxtscr = '03'
610aAC**                 eval      nxtscr = '01'
610aAC                   goto      endup3
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
610aAC                   eval      nxtscr = '01'
610aAC                   goto      endup3
610aAC                   endif
417 A*
417 A*    Bulk Pick qty is being shorted. Force user to pull
417 A*    balance from different location(s) after taking this
417 A*    pallet
417 A*
417 AC                   if        w3nqty < svqpck
417 AC                   eval      shrtqy = '*YES'
417 AC                   endif
     *
417 AC                   select
417 A*    User shorted qty on bulk pick. Update transaction.
417 AC                   when      shrtqy = '*YES'
417 AC     lbqpck        sub       w3nqty        balqty
417 A*
417 AC     slkey         chain     slot2                              76
417 AC                   select
417 AC                   when      not *in76
417 A*
417 AC                   select
417 AC                   when      lbutyp = '1'
417 AC                   sub       lbqpck        slpck2
417 AC                   add       w3nqty        slpck2
417 AC                   when      lbutyp = '2'
417 AC                   sub       lbqpck        slpck3
417 AC                   add       w3nqty        slpck3
417 AC                   other
417 AC                   eval      slpck1 = slpck1 - lbqpck
417 AC                   add       w3nqty        slpck1
417 AC                   endsl
417 A*
417 AC                   update    slrec
417 AC                   endsl
417 A*
417 AC     lblbl#        chain     label                              78
417 AC                   select
417 AC                   when      not *in78
417 AC                   z-add     w3nqty        lbqpck
417 AC     w3nqty        mult      lbuwgt        lbswgt
417 AC     w3nqty        mult      lbucub        lbcube
417 AC                   update    lbrec
417 AC                   endsl
417 A*
417 AC                   eval      $lcmd = '*UPDBULK'
417 AC                   exsr      scr05i
417 A*
417 A*    User selected bulk pick with no changes. Proceed to dock.
417 AC                   other
417 A*
     *   Retrieve current task.
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     C                   eval      lstscr = '03 '
     C                   exsr      scr04i
417  *
417 AC                   endsl
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   eval      error = *off
     *
500aD*    F10=Done pressed. Product left at loading area.
500a *    F9=Done pressed. Product left at loading area.
     C                   select
500aD**         *INKJ     WHEQ *ON
500aMC                   when      *inki
730bAC                             or *inkj
650bA*    Retrieve original bulk pick label rcd for current qty's.
650bAC     lblbl#        chain (n) label
500aAC                   Call      'PT132PL'
500aAC                   Parm      '*BLKPICK'    $pcmd
500aAC                   Parm                    lblbl#
500aAC                   Parm                    lbqpck
650aAc                   exsr      autoloadcw
     C                   exsr      zzend
     *
     *   Start an 'IDLE' task, if no open task.
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     C                   if        curent = *off
     C                   eval      w1task = 'IDLE  '
     C                   exsr      zzidle
     C                   endif
     *
     *    Display select screen for next bulk pick.
720bAc                   if        blktrn > 0
720bAC                   eval      nxtscr = 'EOJ'
720bAC                   eval      *inlr = '1'
720bAC                   else
     C                   exsr      scr01i
720bAC                   endif
     C                   endsl
     *
     C     endup4        endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZUPD5   Update for screen 4.
417 A*
417 AC     zzupd5        begsr
417 AC                   eval      error = *off
500a *    F10=Short pressed. Not all product picked.
     C                   select
500aMC                   when      *inkj
     C                   endsl
417 A*
417 AC     endup5        endsr
     *
640cA*----------------------------------------------------------------*********
640cA*
640cA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640cA*
640cA /free
640cA   begsr zzwrttrand;
640cA     wrtpcmd = '*ONETRAN';
640cA     wrtpwait = 0;
640cA     wrtpwhse = ptwhse;
640cA     wrtptran# = pttrn#;
640cA     wrtpfrmdate = 0;
640cA     wrtptodate = 0;
640cA     wrtpemp# = 0;
640cA
640cA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640cA               wrtpfrmdate: wrtptodate: wrtpemp#);
640cA   endsr;
640cA /end-free
650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = #emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #pgm;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobnbr;
650aA
650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  clr$item  Clear $item data structure fields
650aA*----------------------------------------------------------------

650aAC     clr$item      begsr
650aAC                   eval      savever# = $itver#
650aAC                   clear                   $item
650aAC                   clear                   $item2
650aAC                   eval      $itver# = savever#
650aAC                   endsr

650aA*----------------------------------------------------------------
650aA*  clr$licinfo  Clear $licinfo data structure fields
650aA*----------------------------------------------------------------

650aAC     clr$licinfo   begsr
650aAC                   eval      savever# = $lnver#
650aAC                   clear                   $licinfo
650aAC                   clear                   $licinfo2
650aAC                   eval      $lnver# = savever#

650aAC                   eval      $lnuser = #curruser
650aAC                   eval      $lnemp# = #emp#
650aAC                   eval      $lnpgm  = #pgm
650aAC                   eval      $lnjob  = #job
650aAC                   eval      $lnjobnbr = #jobnbr

650aAC                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slot  Clear $slot data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600eAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600dAC                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  clr$uciinfo  Clear $uciinfo data structure fields
650aA*----------------------------------------------------------------

650aAC     clr$uciinfo   begsr
650aAC                   eval      savever# = $uiver#
650aAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
650aAC                   eval      $uiver# = savever#
650aAC                   eval      $uiaddemp = #emp#
650aAC                   eval      $uiaddusr = #curruser
650aAC                   eval      $uiaddpgm  = #pgm
650aAC                   eval      $uiaddjob  = #job
650aAC                   eval      $uiaddnbr = #jobnbr
650aAC                   endsr

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
     C                   parm      #emp#         $templ#
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

500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600eAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
650aAC                   when      $dricommand = '*LICINFO'
650aAC                   eval      $dridata = $licinfo
650aAC                   eval      $dridata2 = $licinfo2
650aAC                   when      $dricommand = '*UCIINFO'
650aAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600eAC                             or $dricommand = '*SLOT'
650aAC                             or $dricommand = '*LICINFO'
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
600eAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
650aAC                   when      $dricommand = '*LICINFO'
650aAC                   eval      $licinfo = $dridata
650aAC                   eval      $licinfo2 = $dridata2
650aAC                   when      $dricommand = '*UCIINFO'
650aAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500 A*----------------------------------------------------------------
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Transaction
Label
Verify Zero
Bulk pick for wrong dept.
Label# not found.
not a Bulk Pick.
Label# in use.
Label# not at picked status.
Wrong slot scanned.
Qty must be gt zero.
Qty exceeds bulk qty.
**
Transaccion
rotulo
Verificar con 0
Pick de bulto de dept. incorrecto.
#Rotulo no encontrado.
no es Pick de bulto.
se usa #de rotulo.
#rotulo no esta al estado de Pick.
Slot incorrecto escandido.
Qty must be gt zero.
Qty exceeds bulk qty.
