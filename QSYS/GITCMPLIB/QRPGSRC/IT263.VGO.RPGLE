     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  IT263     RF Will Call Transfer Returns
     *  31 May 2002
     *  Max Blacknik
     *
     *  Notes
     *       16 X 20 Screens for hand held scanners
     *
     *  Revisions
     *
402 A*    05/31/02  MLB  4.16
     *      - Created.
416aA*    07/19/02  MLB  4.16a
     *      - Fix: Changed size of AVAILQTY, CHECKQTY to 9,0 from 5,0.
416aA*    10/29/02  RH   4.16b
     *      - Fix: Save from slot expiration date in ZZUPD3 so it can be
     *        tested in ZZCHK4.  SVEXPD was being set after ZZCHK4.
     *      - Fix: Enable F20 for expiration date override, code allowed
     *        for F20 but did not set the value for OVRRID.
     *      - Fix: Update ITEMQTY with hold quantity, reduce from Will
     *        call slot and increase if to slot is not active. ZZUHLD
416mA*    09/25/02  RH   4.16c
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
     *
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
417bAF*    08/11/04  RH   4.17b
     F*      - Fix: Revised to call GETSLOTITM, if the item was an
     F*        alias item for a SSB item, GETBASE would return the SSB
     F*        item which is not a slot item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
VGO A*    07/22/02  MLB  VGO
     *      - Mod: Revised ZZCKNS to allow virtual pick slots to be
     *             created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  52        Display breakdown qty on screen 3.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fit263fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fitemdef   if   e           k disk
     Fitemmsc   if   e           k disk
     Foptiond   if   e           k disk
414cAFoptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpirtran3  if   e           k disk
     F                                     rename(ptrec:ptrec3)
     *
     Fslot1     if   e           k disk
     F                                     rename(slrec:record)
     Fslot2     uf a e           k disk
     F                                     rename(slrec:slrec2)
414cAFslot3     if   e           k disk
     F                                     rename(slrec:slrec3)
     Ftask      if   e           k disk
     Fvslot1    uf a e           k disk
     F                                     rename(vsrec:vsrec1)
     Fvslot2    uf a e           k disk
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fworkrtn   uf a e           k disk
     Fworkrtn1  if   e           k disk
     F                                     rename(wkrrec:wkrrec1)
     Flabel     o    e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(08)
     D hnd             s              2    dim(702)
     D ukey            s             50    dim(08)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
     D desc            s             50    dim(07) ctdata perrcd(01)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D   w1whse                1      3  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  slwhse                 1      3  0 inz(0)
     D  slwhdp                 4      8
     D  sldisp                 9     20
     D  slitem                21     35
     D  slaisl                36     38
     D  slloc                 39     41  0 inz(0)
     D  slrlvl                42     43  0 inz(0)
     D  slhand                44     45
     D                 ds
     D  dsukey                 1     50
     D   ukwhse                1      3  0 inz(0)
     D   ukwhdp                4      8
     D   ukdisp                9     20
     D   ukitem               21     35
     *
     *----------------------------------------------------------------
     *  Define working variables
     *
     D $MSGF           s             10
     D $WKOF           s                   like(WKOKYF)
     D $WKOU           s                   like(WKOKYU)
     D #MSGID          s              7
     D #MSGTP          s              7
     D #ODESC          s             30
     D #OITEM          s             15
     D #OPDSC          s             15
     D #OTYPE          s              1
     D #PGMQ           s             10
416aDD*availqty        s                   like(avail1)
416aMD availqty        s              9  0
     D BOT             s              1
     D brkdwn1         s              4    inz('*NO ')
     D brkdwn2         s              4    inz('*NO ')
416aDD*checkqty        s                   like(avail1)
416aMD checkqty        s              9  0
     D CANCEL          s              1
     D CHGQT1          s                   like(SLSTK1)
     D CHGQT2          s                   like(SLSTK2)
     D CHGQT3          s                   like(SLSTK3)
     D CLEAR           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D cmdln1          s             79
     D curent          s              1    inz(*off)
     D curtrn          s                   like(lbtrn#)
     D                                     inz(*zeros)
     D curtsk          s                   like(tkcode)
     D                                     inz(*blanks)
     D curtyp          s                   like(tktype)
     D                                     inz(*blanks)
     D DSPLYD          s              2  0
     D dteofl          s              1    inz(*off)
     D E               s              2  0
     D ENTER           s              5  0
     D eof             s              1    inz(*off)
     D errflg          s              1    inz(*off)
     D error           s              1    inz(*off)
     D exist           s              1    inz(*off)
     D fintim          s                   like(PTSTIM)
     D flaghs          s              1    inz(*off)
     D fmdisp          s                   like(lbdisp)
     D fmitem          s                   like(lbitem)
     D fmpick          s                   like(slpick)
     D forevr          s              1    inz(*on)
     D found           s              1    inz(*off)
     D FORCEB          s              1
     D FRSTKY          s                   like($PUKY)
     D GOBACK          s              2  0
     D HELP            s              5  0
     D ITDTYP          s                   like($LTYP)
     D i               s              5  0 inz(*zeros)
     D j               s              5  0 inz(*zeros)
     D k               s              5  0 inz(*zeros)
     D kyaisl          s                   like(slaisl)
     D                                     inz('WIL')
     D kycode          s                   like(opcode)
     D kydisp          s                   like(sldisp)
     D kyitem          s                   like(slitem)
     D kystat          s                   like(slstat)
     D                                     inz('WC')
     D kystat1         s                   like(ptstat)
     D kywhdp          s                   like(slwhdp)
     D kytrn#          s                   like(pttrn#)
     D kywhse          s                   like(opwhse)
     D K3PICK          s                   like(SLPICK)
     D K3STAT          s                   like(SLSTAT)
     D MAXVAL          s              3  0
     D MORELN          s              7
     D MSGK            s              4  0
     D NBRPCK          s              5  0 inz(*zeros)
     D newvs           s              1    inz(*off)
     D NEWQT1          s                   like(SLSTK1)
     D NEWQT2          s                   like(SLSTK2)
     D NEWQT3          s                   like(SLSTK3)
     D NOMORE          s              1
     D nwstat          s                   like(SLpick)
     D NXTSCR          s              3
     D OTAKEN          s              1
     D P               s              2  0
     D PAGCMD          s              8
     D OVRRID          s              1    inz(*off)
     D PHACTV          s                   like(SLACTV)
     D PHAISL          s                   like(SLAISL)
     D PHBLD           s                   like(SLBLD)
     D PHDESG          s                   like(SLDESG)
     D PHDISP          s                   like(SLDISP)
     D PHHAND          s                   like(SLHAND)
     D PHLOC           s                   like(SLLOC)
     D PHPSEQ          s                   like(SLPSEQ)
     D PHRLVL          s                   like(SLRLVL)
     D PHSDEF          s                   like(SLSDEF)
     D PHSIDE          s                   like(SLSIDE)
     D PHSLFD          s                   like(SLSLFD)
     D PHSTYP          s                   like(SLSTYP)
     D PHWHDP          s                   like(SLWHDP)
416c D PHSTAT          s                   like(SLSTAT)
     D PHWHSE          s                   like(SLWHSE)
     D RECNO           s              4  0
     D redspl          s              1
     D REFRSH          s              1
     D REPOS           s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D rtnto           s              3
     D SCLEAR          s              1
     D SLDTYP          s                   like($LTYP)
     D slotfnd         s              4    inz('*NO ')
     D stdate          s                   like(ptsdte)
     D strtim          s                   like(PTSTIM)
     D sttime          s                   like(ptstim)
     D STOP            s              1
     D stop1           s              1    inz(*off)
     D svavl1          s                   like(avail1)
     D                                     inz(0)
     D svavl2          s                   like(avail2)
     D                                     inz(0)
     D svavl3          s                   like(avail3)
     D                                     inz(0)
     D svactv          s                   like(SLACTV)
     D svbld           s                   like(SLBLD)
     D sventd          s                   like(SLENTD)
     D svexpd          s                   like(slexpd)
     D                                     inz(0)
     D svitem          s                   like(slitem)
     D                                     inz(*blanks)
     D svpick          s                   like(slpick)
     D SVPRTY          s                   like(SLPRTY)
     D svslfd          s                   like(slslfd)
     D                                     inz(0)
     D svtask          s                   like(pttask)
     D svtlen          s                   like(ptdmin)
     D svtrn#          s                   like(pttrn#)
     D syssts          s              5  0
     D timlen          s                   like(PTDMIN)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D top             s              1
     D today           s              8  0 inz(*zeros)
     D todisp          s                   like(sldisp)
     D toitem          s                   like(slitem)
     D topick          s                   like(slpick)
     D totpcs          s              5  0 inz(0)
     D t#task          s                   like(tkcode)
     D updslot         s                   like(sldisp)
     D vrtslt          s              4    inz('*NO ')
     D vsdisp          s                   like(sldisp)
     D $VAISL          s                   like(slaisl)
     D $VLOC           s                   like(slloc)
     D $VPICK          s                   like(slpick)
     D $VPSEQ          s                   like(slpseq)
     D $VRLVL          s                   like(slrlvl)
     D $VSTYP          s                   like(slstyp)
     D $VWHDP          s                   like(slwhdp)
     D $VWHSE          s                   like(slwhse)
     D WARN            s              1    inz(*off)
     D wkgrp1          s                   like(ptgrp1)
     D                                     inz('L')
     D wkgrp2          s                   like(ptgrp2)
     D                                     inz(' ')
     D wkrtpo          s                   like(ptrtpo)
     D                                     inz('0')
     D worow           s              3  0
     D wocol           s              3  0
     D wotrn#          s                   like(pttrn#)
     D X               s              3  0
     D Y               s              3  0
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
     *----------------------------------------------------------------
     *  Error message(s)
     *
     Derr01            c                   'Invalid warehouse'
     Derr02            c                   'Invalid department'
     *
     Derr03            c                   'Wrong slot scanned'
     Derr030           c                   '                     '
     Derr031           c                   'Qty ('
     Derr032           c                   ') greater  '
     Derr033           c                   'than available qty   '
     Derr034           c                   '('
     Derr035           c                   ').'
     Derr036           c                   ' Change      transfer qty. '
     Derr04            c                   'Qty must be gt zero. '
     Derr05            c                   'Qty must be entered. '
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *
     *----------------------------------------------------------------
     *  Redefinition data structure
     *
     D                 ds
     D  option                 1      2
     D  opt2                   2      2
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
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
414cA*----------------------------------------------------------------
414cA*  *SYSTEM  -  System options.
414cA*----------------------------------------------------------------
414cA*
414cA* Fields
414cA*
414cA*    OPEPM   -  Using EPM module (Y,N).
414cA*    OPRF    -  Using RF module (Y,N).
414cA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
414cA*    OPLETD  -  Print letdown labels (Y,N).
414cA*    OPWRNC  -  Perform catch weight variance check (Y,N).
414cA*    OPRG1C  -  Catch weight low variance percentage.
414cA*    OPRG2C  -  Catch weight high variance percentage.
414cA*    OPIMPI  -  Import item fields from host.(Y,N).
414cA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
414cA*
414cA* Data structure
414cA*
414cAD opdat2          ds
414cAD  opepm                  1      1
414cAD  oprf                   2      2
414cAD  opcapc                 3      3
414cAD  opletd                 4      4
414cAD  opwrnc                 5      5
414cAD  oprg1c                 6      8  1
414cAD  oprg2c                 9     11  1
414cAD  opimpi                12     12
414cAD  opmpck                14     14
414cAD  opten2               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     D @apics          c                   const('APICVTSLT ')
     D @cvtdt          c                   const('CVTDTE')
417b D @getsi          c                   const('GETSLOTITM')
     D @chgpg          c                   const('@NONE')
     D @delpg          c                   const('@NONE')
     D @vewpg          c                   const('@NONE')
     D @fmtit          c                   const('FRMTIT2')
     D @prtpg          c                   const('@NONE')
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
     D  $paisl                54     56
     D  $ploc                 57     59  0 inz(0)
     D  $prlvl                60     61  0 inz(0)
     D  $phand                62     63
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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $ldsg                 19     23
     D  $ltyp                 24     24
     *
     *----------------------------------------------------------------
     *  Date Conversion parameters
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
414cA*
     D  erqty                  1     10
     D  eritem                11     25
     D  erfrom                26     37
     D  erto                  38     49
414cA*
     D  erdisp                 1     12
     *
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     D  ernpck                 1      3p 0
     D  erapck                 4      6p 0
     *
     D  eritdp                 1      5
     D  erslds                 6     17
     D  ersldp                18     22
     D  eritsc                23     23
     D  erslsc                24     24
     *
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
     *      *None
     *
     *    Returned Parameters
     *      *None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     *
     C                   exsr      zzinz2
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2B  C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '99 '         sc99
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = '1'
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C*                  write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   select
 1B  C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  *
 1B  C                   when      nxtscr = '02 '
     C                   exsr      sfldsp
     *
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   read      d16sfc                                 50
 1X  C                   other
     C**                 read      dspsfc                                 50
 1E  C                   endsl
     C                   eval      syssts = status
 1E  *
 1B  C                   when      nxtscr = '03 '
     C                   exfmt     screen3                              50
 1E  *
 1B  C                   when      nxtscr = '04 '
     C                   exfmt     screen4                              50
 1E  *
 1B  C                   when      nxtscr = '99 '
     C                   exfmt     screen99                             50
 1E  *
 1E  C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       202122
     C                   setoff                                       232425
     C                   setoff                                       26
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
     C                   exsr      zzfil1
     *    Position cursor on department field.
     C                   eval      *in02   = *on
     C                   eval      refrsh = *off
     C     end01i        endsr

     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C                   eval      fkey = *loval
     C                   eval      ukey = *loval
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      w3qty1 = 0
     C                   eval      w3qty2 = 0
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     *
     C                   move      '04 '         nxtscr
     *
     C     try4          tag
     C                   if        refrsh = *on
     C     wkkey1        setll     workrtn1
     C                   endif
     C                   exsr      zzget4
     *
     *    End of file.  Check if more returns left to process.
     C                   if        %eof
     C     wkkey1        setll     workrtn1
     C                   if        %equal
     C                   eval      refrsh = *on
     C                   goto      try4
     C                   endif
     *
     *    Last of Transfer Returns has been completed. Return to the beginning.
     C                   exsr      scr01i
     C                   goto      end04i
     C                   endif
     *
     C                   eval      w4scan = *blanks
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     *
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     *
     *    Abort current transaction.
     C                   exsr      zzabrt
     C                   exsr      scr01i
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  Screen 99 initialization
     *
     C     scr99i        begsr
     C                   eval      nxtscr = '99 '
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil99
 1E  C                   endif
     C                   eval      refrsh = *off
     C     end99i        endsr
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
     C                   eval      nxtscr = 'EOJ'
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
goto Csr                 goto      endsc1
 1E  C                   endif
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

     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
 1B  C     syssts        caseq     rollup        roll02
     C     syssts        caseq     rolldn        roll02
     C     syssts        caseq     comand        cmd02
     C                   cas                     ent02
 1E  C                   endcs
     C     endsc2        endsr

     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   exsr      zzclrwk
     C                   exsr      clrsch
     C                   eval      option = *blanks
     C                   eval      nxtscr = '02 '
     C**                 exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   exsr      zzclrwk
     C                   exsr      clrsch
     C                   eval      option = *blanks
     C                   eval      nxtscr = '02 '
     C**                 exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
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
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   exsr      zzabrt
     C                   exsr      zzclrwk
     C                   exsr      clrsch
     C                   eval      option = *blanks
     C                   exsr      scr01i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   exsr      zzabrt
     C                   exsr      zzclrwk
     C                   exsr      clrsch
     C                   eval      option = *blanks
     C                   exsr      scr01i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     C     redspl        cabeq     *on           endsc4
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

     *----------------------------------------------------------------
     *
     *  SC99  -  Screen 99 Display Error routine
     *
     C     sc99          begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
goto Csr                 goto      ends99
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr99i
goto Csr                 goto      ends99
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr99i
goto Csr                 goto      ends99
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd99
     C     cmdtkn        cabeq     *on           ends99
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk99
     C     error         cabeq     *on           ends99
     C                   exsr      zzupd99
     C     error         cabeq     *on           ends99
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd99
     C     cmdtkn        cabeq     *on           ends99
     *
     C     ends99        endsr

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
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt
 1B  C                   dow       not %eof
     C                   delete    wkorec
     C     wkoprt        reade     workopt
 1E  C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD 3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      cancel = *on
     C                   exsr      zzclrwk
     C                   exsr      zzabrt
     C                   exsr      scr02e
goto Csr                 goto      cmd02e
 1E  C                   endif
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke = *on
     C                   exsr      clrsch
219 AC
     C     1             do        10            x
     C     x             chain     d16sfl
     C                   if        %found
     C                   eval      option = '  '
     C                   update    d16sfl
     C                   endif
     C                   enddo
219 A*
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR CMD 12 - PREVIOUS
     *
 1B  C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      zzclrwk
     C                   exsr      zzabrt
     C                   exsr      scr02e
goto Csr                 goto      cmd02e
 1E  C                   endif
     *
     C     cmd02e        endsr

     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
 1B  C                   if        recno < 8
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
 2B  C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
 2E  C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfil3
     C                   eval      option = wkoopt
     C**                 write     dspsfl
 1E  C                   endif
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
     C**                 write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent02e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
 1B  C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag02
goto Csr                 goto      ent02e
 1E  C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  ENT03    Screen 3 enter key routine
     *
     C     ent03         begsr
     *
     *  Save first delete key.
     *
     C                   move      $puky         frstky
     *
     *  Process the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           stop
 1B  C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
 2B  C                   if        *in79
     C                   move      '1'           stop
 2X  C                   else
     *
 3B  C                   if        wkoopt = ' 1'
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
 4B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           error
     C                   move      '1'           cancel
     C                   move      '1'           stop
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 4X  C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
 5B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           error
     C                   move      '1'           cancel
     C                   move      '1'           stop
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 5X  C                   else
     *
     *     Delete canceled
     *
 6B  C                   if        $prtn = '*CANCEL '
     C                   move      '1'           cancel
     C                   move      '1'           stop
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 4B  C                   if        cancel = '0'
     C                   delete    wkorec
 4X  C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
 4E  C                   endif
 3E  C                   endif
     *
 2E  C                   endif
 1E  C                   enddo
     C                   exsr      scr02e
     C     ent03e        endsr
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
 1B  C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
 1E  C                   endcs
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
 1B  C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
 1B  C                   if        %eof
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
 1B  C                   if        %eof
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
 1E  C                   endif
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
     C                   eval      $lprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   move      '0'           otaken
     *
     *     Do ALL 1=Select First (Option 1) Write selections into work file.
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           stop
     C     wkoprt        reade     workopt                                79
 1B  C                   dow       not *in79  and
     C                             wkoopt = ' 1'
     C                   eval      $puky  = wkokyu
     C                   eval      refrsh = *on
     *
     C                   exsr      scr03i
     C                   eval      error = *off
     *
     C                   dow       forevr = forevr
     C                   exsr      dspscr
     C                   exsr      sc3
     *
     *    User canceled item selections. Clear options work file.
     *    Re-display item list.
     C                   select
     C                   when      *inkl or *inkc
     C                   exsr      clrsch
     C                   eval      option = *blanks
     C                   exsr      scr02i
     C                   leave
     *
     *    When F5=Refresh selected.
     C                   when      *inke
     C                   iter
     *
     C                   other
     *
     *    Error(s) occured during entry. Redisplay the screen.
     C                   if        error = *on
     C                   eval      stop1 = *off
     C                   dow       stop1 = *off
     C                   exsr      dspscr
     C                   exsr      sc99
     C                   enddo
     C                   iter
     C                   endif
     *
     C                   eval      otaken = *on
     C                   leave
     C                   endsl
     C                   enddo
     *
     *    User canceled item selections. Re-display item list.
     C                   if        *inkl or *inkc
     C                   eval      otaken = *off
     C                   leave
     C                   endif
     *
     C                   delete    wkorec
     *
     C     wkoprt        reade     workopt                                79
 1E  C                   enddo
     *
     *    Item(s) selected for return.  Load first item in sequence.
     C                   if        otaken = *on
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   endif
     *
     *  Then do the other options in the order they were entered.
     *     Stop when no more options or user enters Cmd12
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           cancel
     C                   move      '0'           stop
 1B  C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
 2B  C                   if        *in79
     C                   move      '1'           stop
 2X  C                   else
 3B  C                   if        wkoopt <> '  '
     C                   move      '1'           otaken
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   move      '1'           refrsh
 4B  C                   if        error = '0'
     C                   delete    wkorec
 4E  C                   endif
 4B  C                   if        cancel = '1'
     C                   move      '1'           stop
 5B  C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
 5E  C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag02
     C                   move      '0'           refrsh
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   enddo
 1B  C                   if        refrsh = '1'
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag02
     C                   move      '0'           refrsh
 1E  C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
 1B  C                   select
     *
     *   Change
     *
 1X  C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   View
     *
 1X  C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @vewpg
     C                   parm                    $parms
     *
     *   Print
     *
 1X  C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     *
     *   View slot quantities.
     *
 1X  C                   when      wkoopt = ' 9'
     C                   call      'SL810'
     C                   parm                    itwhse
     C                   parm                    itwhdp
     C                   parm                    $pdisp
     *
 1X  C                   other
     C                   exsr      zzopt
 1E  C                   endsl
     *
 1B  C                   if        $prtn = '*CANCEL '
     C                   move      '1'           cancel
 1X  C                   else
 2B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           cancel
     C                   move      '1'           error
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 2X  C                   else
 3B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           cancel
     C                   move      '1'           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
 1B  C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
 1X  C                   else
     *
     *  PREVIOUS PAGE
     *
 2B  C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
 2X  C                   else
     *
     *  TOP
     *
 3B  C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   eval      top    = *off
     C                   eval      bot    = *off
     C                   eval      forceb = *off
     C                   exsr      pag2fw
 3X  C                   else
     *
     *  BOTTOM
     *
 4B  C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot    = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag2bk
 4X  C                   else
     *
     *  REFRESH SCREEN
     *
 5B  C                   if        pagcmd  = '*REFRESH'
 6B  C                   if        fkey(1) = *loval
     C                   eval      $pocmd  = '*TOP    '
 6X  C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
 6E  C                   endif
     C                   exsr      fgtway
     C                   eval      bot = *off
     C                   exsr      pag2fw
 5X  C                   else
     *
     *  REPOSITIONING
     *
 6B  C                   if        pagcmd = '*REPOS  '
     C                   eval      bot    = *off
     C                   eval      forceb = *off
     C                   exsr      pag2fw
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG03    Screen 3 page routines
     *
     C     pag03         begsr
     *
     *  NEXT PAGE
     *
 1B  C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag3fw
 1X  C                   else
     *
     *  PREVIOUS PAGE
     *
 2B  C                   if        pagcmd = '*PREV   '
     C                   exsr      pag3bk
 2X  C                   else
     *
     *  TOP
     *
 3B  C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   eval      top    = *off
     C                   eval      bot    = *off
     C                   eval      forceb = *off
     C                   exsr      pag3fw
 3X  C                   else
     *
     *  BOTTOM
     *
 4B  C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot    = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag3bk
 4X  C                   else
     *
     *  REFRESH SCREEN
     *
 5B  C                   if        pagcmd  = '*REFRESH'
 6B  C                   if        fkey(1) = *loval
     C                   eval      $pocmd  = '*TOP    '
 6X  C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
 6E  C                   endif
     C                   exsr      fgtway
     C                   eval      bot = *off
     C                   exsr      pag3fw
 5X  C                   else
     *
     *  REPOSITIONING
     *
 6B  C                   if        pagcmd = '*REPOS  '
     C                   eval      bot    = *off
     C                   eval      forceb = *off
     C                   exsr      pag3fw
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   eval      pagcmd = *blanks
     C     pag03e        endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   eval      fkey = *loval
     C                   eval      ukey = *loval
     C                   eval      bot  = *off
     C                   eval      top  = *off
     C                   eval      stop = *off
     C                   eval      p    = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
 1B  C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot  = *on
     C                   eval      moreln = 'Bottom '
goto Csr                 goto      endfwd
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
 2B  C                   if        p >= 6  and
     C                             #lline <> '16'  or
     C                             p >= 8   and
     C                             #lline = '16'
     C                   eval      stop = *on
 3B  C                   if        forceb = *on
     C                   eval      bot    = *on
     C                   eval      moreln = 'Bottom '
 3X  C                   else
     C                   eval      moreln = 'More...'
 3E  C                   endif
 2E  C                   endif
     C     endfwd        tag
 1E  C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG3FW   Let's see that next page of records
     *
     C     pag3fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf3
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   eval      fkey = *loval
     C                   eval      ukey = *loval
     C                   eval      bot  = *off
     C                   eval      top  = *off
     C                   eval      stop = *off
     C                   eval      p    = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
 1B  C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot  = *on
     C                   eval      moreln = 'Bottom '
goto Csr                 goto      endfwd3
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
 2B  C                   if        p >= 6  and
     C                             #lline <> '16'  or
     C                             p >= 8   and
     C                             #lline = '16'
     C                   eval      stop = *on
 3B  C                   if        forceb = *on
     C                   eval      bot    = *on
     C                   eval      moreln = 'Bottom '
 3X  C                   else
     C                   eval      moreln = 'More...'
 3E  C                   endif
 2E  C                   endif
     C     endfwd3       tag
 1E  C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf3         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
 1B  C                   select
 1X  C                   when      #lline <> '16'
     C                   eval      goback = dsplyd + 6
 1X  C                   other
     C                   eval      goback = dsplyd + 14
 1E  C                   endsl
 1B  C                   if        bot = '1'
 2B  C                   if        goback = 6  and
     C                             #lline <> '16'  or
     C                             goback = 14  and
     C                             #lline = '16'
     C                   move      '1'           forceb
 2E  C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
 1E  C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ SPECIFIED FLITCHES FILE
     *
 1B  C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top  = *on
goto Csr                 goto      endbk
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
 2B  C                   if        p >= goback
     C                   eval      stop = *on
 2E  C                   endif
     C     endbk         tag
 1E  C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
 1B  C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
 1E  C                   endif
     C                   exsr      pag2fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG3BK   Let's see the previous page
     *
     C     pag3bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb3
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
 1B  C                   select
 1X  C                   when      #lline <> '16'
     C                   eval      goback = dsplyd + 6
 1X  C                   other
     C                   eval      goback = dsplyd + 8
 1E  C                   endsl
 1B  C                   if        bot = '1'
 2B  C                   if        goback = 6  and
     C                             #lline <> '16'  or
     C                             goback = 8   and
     C                             #lline = '16'
     C                   move      '1'           forceb
 2E  C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
 1E  C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ SPECIFIED FLITCHES FILE
     *
 1B  C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top  = *on
goto Csr                 goto      endbk3
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
 2B  C                   if        p >= goback
     C                   eval      stop = *on
 2E  C                   endif
     C     endbk3        tag
 1E  C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
 1B  C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
 1E  C                   endif
     C                   exsr      pag3fw
     C     endb3         endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
 1B  C                   if        syssts = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
goto Csr                 goto      rol02e
 1E  C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
 1B  C                   if        syssts = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
goto Csr                 goto      rol02e
 1E  C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL03   Screen 3 roll up/down routine
     *
     C     roll03        begsr
     *
     *  TEST FOR ROLLUP
     *
 1B  C                   if        syssts = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol03e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag03
goto Csr                 goto      rol03e
 1E  C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
 1B  C                   if        syssts = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol03e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag03
goto Csr                 goto      rol03e
 1E  C                   endif
     C     rol03e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
 1B  C                   dou       nomore = *on
     C                   eval      *in21 = *off
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   readc     d16sfl
 2X  C                   other
     C**                 readc     dspsfl                                 79
 2E  C                   endsl
 2B  C                   if        %eof
     C                   eval      nomore = *on
goto Csr                 goto      enddo1
 2E  C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
 2B  C                   if        option <> *blanks
     C                   movea     option        a2
 3B  C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
 3E  C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
 3B  C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
 3E  C                   endif
 2E  C                   endif
     *
     *  SAVE OPTION
     *
     C                   eval      y = recno
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
 2B  C                   if        not *in79
 3B  C                   if        option = *blanks
     C                   delete    wkorec
 3X  C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
 3E  C                   endif
 2X  C                   else
 3B  C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
 3E  C                   endif
 2E  C                   endif
     C     enddo1        tag
 1E  C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
 1B  C                   if        recno < 7  and
     C                             #lline <> '16'  or
     C                             recno < 8  and
     C                             #lline = '16'
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      $pofky  = dsfkey
     C                   eval      $pouky  = dsfkey
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfil2
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     d16sfl
 2X  C                   other
     C**                 write     dspsfl
 2E  C                   endsl
 1E  C                   endif
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
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     d16sfc
 1X  C                   other
     C**                 write     dspsfc
 1E  C                   endsl
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
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
     *R                   WRITEPOSTNREC
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
 1B  C                   if        error <> *on
 2B  C                   select
 2X  C                   when      #lline = '16'
     C     1             chain     d16sfl
 2X  C                   other
     C**   1             chain     dspsfl
 2E  C                   endsl
 2B  C                   if        not %eof
     C                   eval      *in20 = *on
 3B  C                   select
 3X  C                   when      #lline = '16'
     C                   update    d16sfl
 3X  C                   other
     C**                 update    dspsfl
 3E  C                   endsl
 2E  C                   endif
 1E  C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     d16sfc
 1X  C                   other
     C**                 write     dspsfc
 1E  C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
 1B  C                   if        #lline = '16'
     C                   z-add     8             maxval
 1X  C                   else
     C                   eval      maxval = 6
 1E  C                   endif
 1B  C     1             do        maxval        x
 2B  C                   select
 2X  C                   when      #lline = '16'
     C     x             chain     d16sfl
 2X  C                   other
     C**   x             chain     dspsfl
 2E  C                   endsl
 2B  C                   if        not %eof
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt
 3B  C                   if        %found
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
 3X  C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
 3E  C                   endif
 3B  C                   select
 3X  C                   when      #lline = '16'
     C                   update    d16sfl
 3X  C                   other
     C**                 update    dspsfl
 3E  C                   endsl
 2E  C                   endif
 1E  C                   enddo
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
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
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
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
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   move      'PIR0101'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   move      'PIR0102'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   move      'PIR0103'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   move      'PIR0104'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   move      'PIR0106'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   move      'PIR0107'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   move      'PIR0108'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
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
     *     ZM07  Warning - No record exists in Tie/High def. file.
     *
     C     zm07          begsr
     C                   move      'IT13207'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      erdisp = sldisp
     C                   eval      eritem = slitem
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
     *     IT15201  Transfer completed successfully.
     *
     C     zm1521        begsr
     C                   move      'IT15201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     IT25202  WARNING:
     *              Date Sensitive item exists in to slot with dif dte
     *
     C     zm2522        begsr
     C                   move      'IT25202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15203  To slot contains a different item.
     *
     C     zm1523        begsr
     C                   move      'IT15203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   move      'IT15204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     IT25206  # of pick slots exceeds # allowed.
     *
     C     zm5206        begsr
     C                   move      'IT25206'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      ernpck = nbrpck
     C                   eval      erapck = imnrpk
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    IT27004  Slot designation not same as item.
     *
     C     zm7004        begsr
     C                   move      'IT27004'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     *
     C                   eval      error = *off
     *
     *    Verify warehouse.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel(p)  err01         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel(p)  err01         errmsg
     C                   exsr      zm0105
 2E  C                   endif
 1E  C                   endif
     *
     *    Verify department.
     *
     C                   if        w1whdp <> '*ALL '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel(p)  err02         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel(p)  err02         errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
 1E  C                   endif
     *
     C     endck1        endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     *    Re-compute available qty as it may have changed.
     *
     C     sl2key        chain(n)  slot2                              79
 1B  C                   select
 1X  C                   when      %found
     *
     C                   exsr      zzavail
     *
     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     C                   exsr      zzcvst
     C                   eval      w3aval =  $pqstr
 2E  C                   endsl
     *
     C                   eval      availqty = avail1
     C                   eval      checkqty = w3qty1
     *
     *    Convert case qty to lowest common denominator.
     C                   if        brkdwn1  = '*YES'
     C                   eval      availqty = (availqty * itumq2) +
     C                             avail2
     C                   eval      checkqty = (checkqty * itumq2) +
     C                             w3qty2
     C                   endif
     *
     *    Convert break down qty 2 to lowest common denominator.
     C                   if        brkdwn2   = '*YES'
     C                   eval      availqty  = (availqty * itumq3) +
     C                             avail3
     C                   eval      checkqty  = (checkqty * itumq3) +
     C                             w3qty3
     C                   endif
     *
     C                   select
     *
     *    Transfer quantity not entered.
     C                   when      w3qty1 = 0 and w3qty2 = 0 and w3qty3 = 0
     *
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   if        brkdwn1 = '*YES'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     *
     C                   eval      errmsg = err05
     C                   exsr      zm0105
     *
     *    Transfer quantity must be greater than zero.
     C                   when      w3qty1 < 0 or w3qty2 < 0 or w3qty3 < 0
     *
     C                   if        w3qty1 < 0
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w3qty2 < 0
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w3qty3 < 0
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     *
     C                   eval      errmsg = err04
     C                   exsr      zm0105
     *
     *    Transfer quantity exceeds total available quantity in slot.
 1B  C                   when      checkqty > availqty
     *
     C                   move      *on           error
     *
     C                   if        w3qty1 > 0
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w3qty2 > 0
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w3qty3 > 0
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     C                   eval      errmsg = *blanks
     C                   eval      w9txt01 = err030 + err031 +
     C                                       %editc(checkqty:'Z') +
     C                                       err032 + err033 + err034 +
     C                                       %editc(availqty:'Z') + err035 +
     C                                       err036
     C                   eval      rtnto = '03 '
     C                   exsr      scr99i
     C                   goto      endck3
     *
     C                   endsl
     *
     C     endck3        endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   move      *off          error
     C                   move      *off          errflg
     *
     *  "To Slot" can't be blank.
     *
 1B  C                   if        w4scan = *blanks
     C                   eval      error  = *on
     C                   eval      *in24  = *on
     C                   eval      *in04  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm0105
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w4scan
     C                   parm      10            worow
     C                   parm      03            wocol
     C                   parm                    @artn             8
 1B  C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
goto Csr                 goto      endck4
 1E  C                   endif

     *------------------------------------------------------------
     *
     *  Retrieve "From Slot" information.
     *
     C                   eval      kywhdp = wkrwhd
     C                   eval      fmdisp = wkrdsp
     C     fmkey         chain(n)  slot2
     C                   select
 1B  C                   when      not %found
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(7)
     C                   exsr      zm0105
goto Csr                 goto      endck4
     *
 1B  C                   when      %found
     C                   eval      fmpick = slpick
     C                   eval      svitem = slitem
 1E  C                   endsl
     *
     *------------------------------------------------------------
     *
     *
     *  Verify "To Slot" number.
     *
     C                   eval      todisp = w4scan
     C     tokey         chain(n)  slot2
 1B  C                   if        not %found
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
goto Csr                 goto      endck4
 1E  C                   endif
     *
 1B  C                   if        %found
     C                   eval      topick = slpick
 1E  C                   endif
     *
     *  Verify "To Slot" has the same dept as the item.
     *
 1B  C                   if        slwhdp <> itwhdp
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *  Verify "To Slot" has the same section as the item.
     *
 1B  C                   if        slstyp <> itstyp
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   if        itstyp = 'P'
     C                   eval      errmsg = desc(5)
     C                   else
     C                   eval      errmsg = desc(4)
     C                   endif
     C                   exsr      zm0105
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *    Retrieve hard/soft slot designation code.
     *
     C                   eval      sldtyp = *blanks
 1B  C                   if        sldesg > *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ldsg = sldesg
     *
     C                   call      'DS900'
     C                   parm                    $lparm
     *
 2B  C                   select
 2X  C                   when      $lrtn  = '*OK     '
     C                   eval      sldtyp = $ltyp
     *
 2X  C                   when      $lrtn  = '*ERROR  '
     C                   eval      error  = *on
     C                   eval      *in24  = *on
     C                   eval      *in04  = *on
     C                   eval      errmsg = $lerm
     C                   exsr      zm0105
     *
 2X  C                   when      $lrtn  = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in24  = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 2E  C                   endsl
 1E  C                   endif
     *
     *    If designation is valid and item designation doesn't match
     *    slot designation, flag error and prevent user from proceeding.
     *
 1B  C                   if        error = *off  and
     C                             itdtyp = 'H'  and
     C                             sldtyp <> 'H'  or
     *
     C                             error = *off  and
     C                             itdtyp <> 'H'  and
     C                             sldtyp = 'H'  or
     *
     C                             error = *off  and
     C                             itdtyp = 'H'  and
     C                             sldtyp = 'H'  and
     C                             sldesg <> itdesg
     *
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
 2B  C                   if        itdesg > *blanks
     C                   eval      eritdp = itdesg
 2X  C                   else
     C                   eval      eritdp = '*NONE'
 2E  C                   endif
     C                   eval      erslds = sldisp
 2B  C                   if        sldesg > *blanks
     C                   eval      ersldp = sldesg
 2X  C                   else
     C                   eval      ersldp = '*NONE'
 2E  C                   endif
     C                   exsr      zm7004
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *   Check if item exists in reg. or v-slot.
     *
     C                   exsr      zzcksl
     *
 1B  C                   if        exist = *on
     *   Item is date sensitive and exists with different date.
     *   display warning message.
 2B  C                   if        ovrrid = *off
 3B  C                   if        itflgd = 'Y'  and
     C                             slexpd <> svexpd
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm2522
goto Csr                 goto      endck4
 3E  C                   endif
 2E  C                   endif
     *
     C                   eval      w4scan = sldisp
 1X  C                   else
 2B  C                   if        opmput = 'Y'
     C                   exsr      zzckns
 3B  C                   if        error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w4scan        errmsg
     C                   exsr      zm1524
goto Csr                 goto      endck4
 3E  C                   else
     C                   eval      todisp = w4scan
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     *
     *   From and To slot cannot be same.
     *
 1B  C                   if        w4scan = fmdisp
     C                   eval      error  = *on
     C                   eval      *in24  = *on
     C                   eval      *in04  = *on
     C                   eval      errmsg = desc(6)
     C                   exsr      zm0105
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *   For directed put away,
     *   To slot cannot have a different item.
     *
 1B  C                   if        opmput = 'N'
 2B  C                   if        slitem <> *blanks  and
     C                             slitem <> svitem
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm1523
goto Csr                 goto      endck4
 2E  C                   endif
 1E  C                   endif
     *
     *   Verify record exists in itemdef (tie/high) file.
     *   If no record is found, display warning message.
     *
 1B  C                   if        ovrrid = *off
     C     idkey         chain     itemdef
 2B  C                   if        not %found
     C**                 eval      error = *on
     C**                 eval      warn = *on
     C**                 eval      errmsg = *blanks
     C**                 exsr      zm07
 2E  C                   endif
 1E  C                   endif
     *
     *   For fixed items only,
     *   Check for multiple pick slots.
     *   Check only if From or To slot is a pick slot.
     *
 1B  C                   if        fmpick = 'Y'  or
     C                             topick = 'Y'
     *
 2B  C                   if        itstyp = 'F'
     *
     *   Count # of pick slots.
     C                   exsr      chkpck
     *
     *   Check if status will change for TO slot.
     *
 3B  C                   if        newvs = *off
     C     tokey         chain(n)  slot2
 4B  C                   if        not %found
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm73
goto Csr                 goto      endck4
 4E  C                   endif
 3E  C                   endif
 3B  C                   if        slstat = 'V'  and
     C                             slpick = 'Y'  or
     C                             slstat = 'Z'  and
     C                             slpick = 'Y'
     C                   add       1             nbrpck
 3E  C                   endif
     *
     *   Check if status of FROM slot will be Z.
 3B  C                   if        nwstat = 'Z'  and
     C                             svpick = 'Y'
     C                   eval      nbrpck = nbrpck - 1
 3E  C                   endif
     *
 3B  C                   if        opmpck = 'N'  and
     C                             imnrpk > 1
     C                   eval      imnrpk = 1
 3E  C                   endif
     *
     *   Error if new # of pick slots is > number allowed.
     *
 3B  C                   if        nbrpck > imnrpk
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm5206
 3E  C                   endif
     *
 2E  C                   endif
     *
 1E  C                   endif
     *
     *
     *  If error has occured then skip the rest of the checks.
     *
     C     error         cabeq     *on           endck4
     *
     *  Get "From Slot" record and lock it this time.
     *
     C     fmkey         chain     slot2                              7978
     *
     *    Record locked.
     *
 1B  C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm74
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *    Record not found.
     *
 1B  C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm73
goto Csr                 goto      endck4
 1E  C                   endif
     *
     *    See if quanities or status has changed
     *
     *     Decrease quantity from the "FROM SLOT".
     *
     C                   eval      chgqt1 = wkrqy1
     C                   eval      chgqt2 = wkrqy2
     C**                 eval      chgqt3 = wkrqy3
     C     slstk1        sub       wkrqy1        newqt1
     C     slstk2        sub       wkrqy2        newqt2
     C**   slstk3        sub       wkrqy3        newqt3
     *
     *  New available quantities can not be negative.
     *
     C                   eval      $pqty1 = $pqty1 - chgqt1
     C                   eval      $pqty2 = $pqty2 - chgqt2
     C                   eval      $pqty3 = $pqty3 - chgqt3
 1B  C                   if        $pqty1 < 0  or
     C                             $pqty2 < 0  or
     C                             $pqty3 < 0
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   unlock    slot2
     C                   exsr      zm16
 1E  C                   endif
     *
     C**   endck2        tag
 1B  C                   if        error = *on
     C**                 move      odisp         w4scan
 1E  C                   endif
     *
     *------------------------------------------------------------
     *    Retrieve item information.
     *
     C                   eval      kyitem = wkritm
     C                   exsr      zzgtit
     *
     C     endck4        endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK99  Screen 99 error checking.
     *
     C     zzchk99       begsr
     *
     C                   eval      error = *off
     *
     C     endck99       endsr

     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *
     *  ZZCMD2   Process non-standard function keys
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCMD3   Process non-standard function keys
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCMD4   Process non-standard function keys
     *
     C     zzcmd4        begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     C*
     C*      F20 - Accept Warning.
     C*
 1B  C                   if        *inku = *on
     C                   eval      ovrrid = *on
     C                   endif
     C*
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD99  User defined command keys for screen 99.
     *
     C     zzcmd99       begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm99       endsr

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
     C     filuky        chain     slot2
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
     C     partky        reade     record
     C                   select
     C                   when      %eof
     *
 1B  C                   when      slstat <> 'WC' or
 1B  C                             slitem = *blanks
goto Csr                 goto      try1
 1E  C                   endsl
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
     C     partky        readpe    record
     C                   select
     C                   when      %eof
     *
 1B  C                   when      slstat <> 'WC' or
 1B  C                             slitem = *blanks
goto Csr                 goto      try2
 1E  C                   endsl
     *
     C     endgtp        endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill display line with values that need
     *           to be converted.
     *
     C     zzfil2        begsr
     *
     C                   eval      kyitem = slitem
     C     itkey         chain     piritem
     C                   select
     C                   when      not %found
     *
     C                   when      %found
     *
     C     imkey         chain     itemmsc
     C                   if        not %found
     C                   eval      imnrpk = 1
     C                   endif
     *
     C                   select
     C                   when      ittype = 'A' or ittype = 'C' or ittype = 'S'
     C                   CALL      'GETBASE'
     C                   PARM      w1whse        $gwhse            3 0
     C                   PARM      slitem        $GITEM           15
     C                   PARM      ' '           #BITEM           15
     C                   PARM                    #BITYP            1
     C                   PARM                    #BDESC           30
     C                   PARM                    #BPDSC           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BSTYP            1
     C                   PARM                    #BUM              2
     C                   PARM                    #BUM2             2
     C                   PARM                    #BUMQ2            3 0
     C                   PARM                    #BUM3             2
     C                   PARM                    #BUMQ3            3 0
     C                   PARM      ' '           #BCITM           15
     C                   PARM                    #BCTYP            1
     C                   PARM                    #BCDSC           30
     C                   PARM                    #BCPDS           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BCSTP            1
     C                   PARM                    #BCUM             2
     C                   PARM                    #BCUM2            2
     C                   PARM                    #BCUQ2            3 0
     C                   PARM                    #BCUM3            2
     C                   PARM                    #BCUQ3            3 0
     C                   PARM                    #BRTN             8
     C                   eval      fmitem = #bitem
     C                   other
     C                   eval      fmitem = slitem
     C                   endsl
417bA*    Get slot item for all items.
417bAC                   call      @getsi
417bAC                   PARM      w1whse        $gwhse
417bAC                   PARM      slitem        $GITEM
417bAC                   PARM      ' '           #SITEM           15
417bAC                   PARM                    #SITYP            1
417bAC                   PARM                    #SDESC           30
417bAC                   PARM                    #SPDSC           15
417bAC                   PARM                    #SRTN            10
417bAC                   PARM                    #SMSG            60
417bAC                   eval      fmitem = #sitem
     C                   endsl
     *
     C                   eval      w2txt = %trimr(slitem) + '/' + %trimr(itdesc)
     C                             + ' ' + itpdsc
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill display line with values that need
     *           to be converted.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3item = $pitem
     *
     C                   eval      kyitem = $pitem
     C     itkey         chain     piritem
     C                   select
     C                   when      not %found
     *
     C                   when      %found
     *
     C     imkey         chain     itemmsc
     C                   if        not %found
     C                   eval      imnrpk = 1
     C                   endif
     *
     C                   select
     C                   when      ittype = 'A' or ittype = 'C' or ittype = 'S'
     C                   CALL      'GETBASE'
     C                   PARM      w1whse        $gwhse            3 0
     C                   PARM      w3item        $GITEM           15
     C                   PARM      ' '           #BITEM           15
     C                   PARM                    #BITYP            1
     C                   PARM                    #BDESC           30
     C                   PARM                    #BPDSC           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BSTYP            1
     C                   PARM                    #BUM              2
     C                   PARM                    #BUM2             2
     C                   PARM                    #BUMQ2            3 0
     C                   PARM                    #BUM3             2
     C                   PARM                    #BUMQ3            3 0
     C                   PARM      ' '           #BCITM           15
     C                   PARM                    #BCTYP            1
     C                   PARM                    #BCDSC           30
     C                   PARM                    #BCPDS           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BCSTP            1
     C                   PARM                    #BCUM             2
     C                   PARM                    #BCUM2            2
     C                   PARM                    #BCUQ2            3 0
     C                   PARM                    #BCUM3            2
     C                   PARM                    #BCUQ3            3 0
     C                   PARM                    #BRTN             8
     C                   eval      fmitem = #bitem
     C                   other
     C                   eval      fmitem = $pitem
     C                   endsl
417bA*    Get slot item for all items.
417bAC                   call      @getsi
417bAC                   PARM      w1whse        $gwhse
417bAC                   PARM      w3item        $GITEM
417bAC                   PARM      ' '           #SITEM           15
417bAC                   PARM                    #SITYP            1
417bAC                   PARM                    #SDESC           30
417bAC                   PARM                    #SPDSC           15
417bAC                   PARM                    #SRTN            10
417bAC                   PARM                    #SMSG            60
417bAC                   eval      fmitem = #sitem
     C                   endsl
     C                   eval      w3desc = itdesc
     C                   eval      w3pdsc = itpdsc
     C                   eval      w3whdp = itwhdp
     C                   eval      w3um1  = itum1
     C                   select
     C                   when      itflg1 = 'Y'
     C                   eval      w3um2 = itum2
     C                   eval      *in52   = *on
     C                   eval      brkdwn1 = '*YES'
     *
     C                   other
     C                   eval      itum2   = *blanks
     C                   eval      *in52   = *off
     C                   eval      brkdwn1 = '*NO '
     *
     C                   endsl
     *
     C                   select
     C                   when      itflg2  = 'Y' and itumq3 > 0
     C                   eval      w3um3   = itum3
     C                   eval      *in53   = *on
     C                   eval      brkdwn2 = '*YES'
     *
     C                   other
     C                   eval      itum3   = *blanks
     C                   eval      *in53   = *off
     C                   eval      brkdwn2 = '*NO '
     C                   endsl
     *
     *    Retrieve available qty in will call area slot.
     *
     C                   eval      updslot = $pdisp
     C     sl2key        chain(n)  slot2                              79
 1B  C                   select
 1X  C                   when      %found
     C                   exsr      zzavail
     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     C                   exsr      zzcvst
     C                   eval      w3aval =  $pqstr
 2E  C                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill display line with values that need
     *           to be converted.
     *
     C     zzfil4        begsr
     *
     C                   eval      w4item = wkritm
     *
     C                   eval      kyitem = wkritm
     C     itkey         chain     piritem
     C                   select
     C                   when      not %found
     *
     C                   when      %found
     *
     C     imkey         chain     itemmsc
     C                   if        not %found
     C                   eval      imnrpk = 1
     C                   endif
     *
     C                   select
     C                   when      ittype = 'A' or ittype = 'C' or ittype = 'S'
     C                   CALL      'GETBASE'
     C                   PARM      w1whse        $gwhse            3 0
     C                   PARM      w4item        $GITEM           15
     C                   PARM      ' '           #BITEM           15
     C                   PARM                    #BITYP            1
     C                   PARM                    #BDESC           30
     C                   PARM                    #BPDSC           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BSTYP            1
     C                   PARM                    #BUM              2
     C                   PARM                    #BUM2             2
     C                   PARM                    #BUMQ2            3 0
     C                   PARM                    #BUM3             2
     C                   PARM                    #BUMQ3            3 0
     C                   PARM      ' '           #BCITM           15
     C                   PARM                    #BCTYP            1
     C                   PARM                    #BCDSC           30
     C                   PARM                    #BCPDS           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BCSTP            1
     C                   PARM                    #BCUM             2
     C                   PARM                    #BCUM2            2
     C                   PARM                    #BCUQ2            3 0
     C                   PARM                    #BCUM3            2
     C                   PARM                    #BCUQ3            3 0
     C                   PARM                    #BRTN             8
     C                   eval      fmitem = #bitem
     C                   other
     C                   eval      fmitem = w4item
     C                   endsl
417bA*    Get slot item for all items.
417bAC                   call      @getsi
417bAC                   PARM      w1whse        $gwhse
417bAC                   PARM      w4item        $GITEM
417bAC                   PARM      ' '           #SITEM           15
417bAC                   PARM                    #SITYP            1
417bAC                   PARM                    #SDESC           30
417bAC                   PARM                    #SPDSC           15
417bAC                   PARM                    #SRTN            10
417bAC                   PARM                    #SMSG            60
417bAC                   eval      fmitem = #sitem
     C                   endsl
     *
     C                   select
     C                   when      itflg1 = 'Y' and itumq2 > 0
     C                   eval      brkdwn1 = '*YES'
     *
     C                   other
     C                   eval      brkdwn1 = '*NO '
     *
     C                   endsl
     *
     C                   select
     C                   when      itflg2  = 'Y' and itumq3 > 0
     C                   eval      brkdwn2 = '*YES'
     *
     C                   other
     C                   eval      brkdwn2 = '*NO '
     C                   endsl
     C                   eval      w4desc = itdesc
     C                   eval      w4pdsc = itpdsc
     C                   eval      w4whdp = itwhdp
     C                   eval      w4disp = wkrds2
     *
     *    Convert return quantities into string for display.
     *
     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = wkrqy1
     C                   eval      $pqty2 = wkrqy2
     C                   eval      $pqty3 = wkrqy3
     C                   eval      $pqstr = *blanks
     C                   exsr      zzcvst
     C                   eval      w4rqty =  $pqstr
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET4   Get next record will call return record
     *
     C     zzget4        begsr
     *
     C     wkkey1        reade     workrtn1
     C                   select
     C                   when      %eof
     *
     C                   other
     *
     C                   endsl
     *
     C     endgt4        endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL99  Fill screen 99 fields with info from file.
     *
     C     zzfil99       begsr
     *
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
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
     C                   kfld                    slwhdp
     C                   kfld                    slaisl
     C                   kfld                    slloc
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    kyaisl
     *
     *    Define key for ITEMDEF file.
     *
     C     idkey         klist
     C                   kfld                    w1whse
     C                   kfld                    slitem
     C                   kfld                    slsdef
     *
     *    Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    w1whse
     C                   kfld                    kyitem
     *
     *  Define partial key for OPTIOND file.
     *
     C     keyopd        klist
     C                   kfld                    kycode
     C                   kfld                    w1whse
     C                   kfld                    kywhdp
     *
     *  Define key for options file, System values.
     *
     C     optsky        klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define key for item file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    kyitem
     *
     *    Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    SVTRN#
     *
     *    Define key for PIRTRAN1 file.
     *
     C     PTKEY1        KLIST
     C                   KFLD                    #emp#
     C                   KFLD                    KYSTAT1
     *
     *    Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        KLIST
     C                   KFLD                    #EMP#
     C                   KFLD                    STDATE
     *
     C     ptke22        klist
     C                   kfld                    #EMP#
     C                   kfld                    STDATE
     C                   kfld                    STTIME
     *
     *    Define partial key for PIRTRAN3 file.
     *
     C     PTKEY3        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    WKGRP1
     C                   KFLD                    WKGRP2
     *
     *    Define Full key for PIRTRAN3 file.
     *
     C     PTKY3A        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    WKGRP1
     C                   KFLD                    WKGRP2
     C                   KFLD                    WKRTPO
     C                   KFLD                    KYTRN#
405 A*
405 A*    Define key for SLOT1 file.
405 A*
405 AC     keysl1        klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    kyaisl
     *
     *    Define Full key for SLOT2 file.
     *
     C     sl2key        klist
     C                   kfld                    w1whse
     C                   kfld                    $pwhdp
     C                   kfld                    updslot
     C     sl2aky        klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    $kslot
     C     fmkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    fmdisp
405 A*
     C     tokey         klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    todisp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keys3         klist
     C                   kfld                    w1whse
     C                   kfld                    kyitem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     *    Define key for SLOT4 file.
     *
     C     keysl4        klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    slitem
     C                   kfld                    kydisp
     *
     C     ckkey         klist
     C                   kfld                    w1whse
     C                   kfld                    kywhdp
     C                   kfld                    $vdisp
     *
     C     vskey         klist
     C                   kfld                    w1whse
     C                   kfld                    kywhdp
     C                   kfld                    vsdisp
     *
     *    Define key for TASK file.
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     *
     *  Define key for warehouse department.
     *
     C     wdkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     *
     *  Define key for WORKRTN file. - Full
     *
     C     wkkey         klist
     C                   kfld                    #user
     C                   kfld                    wkrdsp
     *
     *  Define key for WORKRTN1 file. - Partial
     *
     C     wkkey1        klist
     C                   kfld                    #user
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   move      cmdln(1)      cmdln1
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
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     *    **** force to process 16 lines always.....
     C                   eval      #lline = '16'
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     d16sfl                               79
 1X  C                   other
     C**                 write     dspsfl                               79
 1E  C                   endsl
     *
     *    Get User's employee number.
     *
     C                   call      'GETUSER'
     C                   parm      #user         #code            10
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm      *blanks       #fnam            15
     C                   parm      *blanks       #init             1
     C                   parm      *blanks       #lnam            20
     C                   parm      *blanks       #whdp             5
     C                   parm      *blanks       #styp             1
     C                   parm      *blanks       #shft             6
     C                   parm      *blanks       #crew             6
     C                   parm      0.0           #nhrs             3 1
     C                   parm      *blanks       #rtn              8
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
 1B  C     1             do        27            i
 2B  C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
 2E  C                   enddo
 1E  C                   enddo
     *
     C                   eval      $lprg = #prog
     C                   eval      w1whse = #whse
     C                   eval      w1whdp = #whdp
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr

     *---------------------------------------------------------------
     *
     *  CHKPCK  Retrieve number of pick slots for item and accumulate
     *          number of pick slots assigned to item.
     *
     C     chkpck        begsr
     C     itkey         chain     itemmsc
 1B  C                   if        not %found
     C                   eval      imnrpk = 1
 1E  C                   endif
     *
     *    Accumulate number of pick slots assigned to item.
     *
     C                   move      'A '          k3stat
     C                   move      'Y'           k3pick
     C     keys3         setll     slot3
     C                   eval      nbrpck = *zeros
     C                   move      *off          eof
 1B  C                   dow       eof = *off
     C     keys3         reade     slot3                                  79
     C                   move      *in79         eof
 2B  C                   if        not *in79
     C                   add       1             nbrpck
 2E  C                   endif
 1E  C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
     *
     C                   move      *off          error
     C                   eval      @pcmd = '*ABORT  '
     *
     C                   call      @adjtr
     C                   parm                    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      pttask        @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      *blanks       @pwhdp            5
     C                   parm      *blanks       @pstyp            1
     C                   parm      0.000         @pcube            9 3
     C                   parm      0.00          @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *    Start an 'IDLE' task.
     *
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
 3B  C                   if        curent = *off
     C                   exsr      zzidle
 3E  C                   endif
     *
     C     endabr        endsr

     *----------------------------------------------------------------
     *
     *  ZZADJQY  Adjust breakdown quantities.
     *
     C     zzadjqy       begsr
     *
     *    Make sure breakdown qty's are not greater than
     *    quantity in the unit of measure.
     *
     C                   dow       slstk3 >= itumq3 and itumq3 <> 0
     C                   eval      slstk3 = slstk3 - itumq3
     C                   eval      slstk2 = slstk2 + 1
     C                   enddo
     *
     C                   dow       slstk2 >= itumq2 and itumq2 <> 0
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      slstk1 = slstk1 + 1
     C                   enddo
     *
     *    Make sure breakdown qty's are not less than zero
     *    in the unit of measure.
     *
     C                   dow       slstk2 < 0 and itumq2 <> 0
     C                   eval      slstk2 = slstk2 + itumq2
     C                   eval      slstk1 = slstk1 - 1
     C                   enddo
     *
     C                   dow       slstk3 < 0 and itumq3 <> 0
     C                   eval      slstk3 = slstk3 + itumq3
     C                   eval      slstk2 = slstk2 - 1
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZADRTN  Add Will Call Transfer return to work file for user.
     *
     C     zzadrtn       begsr
     *
     C                   clear                   wkrrec
     C                   eval      wkrwhd = $pwhdp
     C                   eval      wkrusr = #user
     C                   eval      wkritm = $pitem
     C                   eval      wkrwhs = w1whse
     C                   eval      wkrwhd = $pwhdp
     *
     *      Load From Slot information.
     C                   eval      wkrasl = $paisl
     C                   eval      wkrloc = $ploc
     C                   eval      wkrlvl = $prlvl
     C                   eval      wkrhnd = $phand
     C                   eval      wkrdsp = $pdisp
     *
     *      Load To Slot information.
     *        Note:  The To slot info being loaded is only the items'
     *               home slot or first overflow slot if no pick slot
     *               is found.
     *               The To Slot info is being used to sequence the
     *               returns for the warehouse worker.
     C                   eval      wkral2 = slaisl
     C                   eval      wkrlc2 = slloc
     C                   eval      wkrlv2 = slrlvl
     C                   eval      wkrhn2 = slhand
     C                   eval      wkrds2 = sldisp
     *
     *      Load Return Quantities.
     C                   eval      wkrqy1 = w3qty1
     C                   eval      wkrum1 = w3um1
     C                   eval      wkrqy2 = w3qty2
     C                   eval      wkrum2 = w3um2
     C**                 eval      wkrqy3 = w3qty3
     C**                 eval      wkrum3 = w3um3
     C*
     C                   write     wkrrec
     C*
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZAVAIL  Compute available qty in slot.
     *
     C     zzavail       begsr
     *
     C                   call      'SLOTQTY'
     C                   PARM                    slstk1
     C                   PARM                    slstk2
     C                   PARM                    slstk3
     C*
     C                   PARM                    slalc1
     C                   PARM                    slalc2
     C                   PARM                    slalc3
     C*
     C                   PARM                    sltfr1
     C                   PARM                    sltfr2
     C                   PARM                    sltfr3
     C*
     C                   parm                    slpck1
     C                   PARM                    slpck2
     C                   PARM                    slpck3
     C*
     C                   PARM                    slrcv1
     C                   PARM                    slrcv2
     C                   PARM                    slrcv3
     C*
     C                   PARM      0             stock1            5 0
     C                   PARM      0             stock2            3 0
     C                   PARM      0             stock3            3 0
     C*
     C                   PARM      0             avail1            5 0
     C                   PARM      0             avail2            3 0
     C                   PARM      0             avail3            3 0
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCKNS   Use reg slot or get new Vslot.
     *
     C     zzckns        begsr
     C                   move      *on           error
     C                   move      *off          newvs
     C     tokey         chain(n)  slot2
 1B  C                   if        %found
 2B  C                   if        slitem = *blanks
     C                   move      *off          error
goto Csr                 goto      endckn
 2X  C                   else
     *   IF WE WANT VIRTUAL PICK SLOTS, COMMENT OUT THE NEXT IF.
     *   Get out if physical slot is a pick slot so we
     *   do not create virtual pick slot.
 3B  C                   if        slpick = 'Y'
VGO DC**                 eval      error = *on
VGO DC**                 goto      endckn
 3E  C                   endif
     *   Get out if physical slot already uses both
     *   positions of handstack field.
     C                   movea     slhand        a2
 3B  C                   if        a2(1) <> ' '
goto Csr                 goto      endckn
 3E  C                   endif
     *   Set handstack flag for later use.
 3B  C                   if        slhand <> ' '
     C                   move      *on           flaghs
 3X  C                   else
     C                   move      *off          flaghs
 3E  C                   endif
     * SAVE PHYSICAL SLOT FIELDS
     C                   eval      phwhse = slwhse
     C                   eval      phwhdp = slwhdp
416c C                   eval      phstat = slstat
     C                   eval      phaisl = slaisl
     C                   eval      phloc  = slloc
     C                   eval      phrlvl = slrlvl
     C                   eval      phhand = slhand
     C                   eval      phside = slside
     C                   eval      phstyp = slstyp
     C                   eval      phdisp = sldisp
     C                   eval      phsdef = slsdef
     C                   eval      phdesg = sldesg
     C                   eval      phpseq = slpseq
     C                   eval      phactv = slactv
     C                   eval      phbld  = slbld
     C                   eval      phslfd = slslfd
     *
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k      = 0
     C                   eval      $vwhse = slwhse
     C                   eval      $vwhdp = slwhdp
     C                   eval      $vaisl = slaisl
     C                   eval      $vloc  = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   eval      $vstyp = slstyp
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      $vpick = slpick
     *** Loop & increment handstack to find new v-slot to create.
 3B  C                   dow       k <= 702
     C                   add       1             k
     *     If physical slot had handstack then limit hs we can use.
 4B  C                   if        flaghs = *on
     C                   movea     hnd(k)        a2n
 5B  C                   if        a2n(1) <> a2(2)
 3I  C                   iter
 5E  C                   endif
 4E  C                   endif
     C                   eval      $vhand = hnd(k)
     C                   call      'FRMTVS'
     C                   parm                    phdisp
     C                   parm                    flaghs
     C                   parm                    $vhand            2
     C                   parm                    $vdisp           12
     *
     C     ckkey         chain(n)  slot2
 4B  C                   if        not %found
     C                   move      *on           newvs
     C                   move      *off          error
     C                   eval      w4scan = $vdisp
 3L  C                   leave
 4X  C                   else
 3I  C                   iter
 4E  C                   endif
 3E  C                   enddo
 2E  C                   endif
 1E  C                   endif
     *
     C     endckn        endsr
     *----------------------------------------------------------------
     *
     *
     *  ZZCKSL   Check if item exists in reg or V slot
     *
     C     zzcksl        begsr
     C                   move      *off          exist
 1B  C                   if        slitem = svitem
     C                   move      *on           exist
goto Csr                 goto      endcks
 1X  C                   else
 2B  C                   if        opmput = 'Y'
     C     tokey         setll     vslot2
     C     nxt1          tag
     C     tokey         reade(n)  vslot2                                 78
 3B  C                   if        not *in78
     C     vskey         chain(n)  slot2                              79
 4B  C                   if        not *in79  and
     C                             slitem = svitem
     C                   move      *on           exist
goto Csr                 goto      endcks
 4X  C                   else
goto Csr                 goto      nxt1
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     *
     C     endcks        endsr

     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
 1B  C                   dow       forevr = forevr
     C                   read      pirtran2
 2B  C                   if        %eof   or
     C                             ptsdte < zzsdte
 1L  C                   leave
 2E  C                   endif
     *    Skip the task that just ended.
 2B  C                   if        not %eof   and
     C                             pttrn# = svtrn#
 1I  C                   iter
 2E  C                   endif
     *    Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *    Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *    Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
 2B  C                   if        not %eof   and
     C                             ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim
     C                   z-add     ptstim        strtim
     C                   z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *    Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
 2B  C                   if        not %eof   and
     C                             ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim
     C                   z-add     ptstim        strtim
     C                   z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *    Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
 2B  C                   if        not %eof   and
     C                             ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim
     C                   z-add     ptstim        strtim
     C                   z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
 1E  C                   enddo
     *
     *    Update the task that just ended.
     *
     C     svtrn#        chain     pirtran
 1B  C                   if        not %eof
 2B  C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
 2X  C                   else
     C                   eval      ptimin = ptimin - svtlen
 2E  C                   endif
     *
     *    Update transaction time only if difference found.
     *    Otherwise, release lock on record.
 2B  C                   if        svtlen <> *zeros
     C                   update    ptrec
 2X  C                   else
     C                   unlock    pirtran
 2E  C                   endif
 1E  C                   endif
     C     endcu2        endsr

     *----------------------------------------------------------------
     *
     *  ZZCLRWK  Clear Will Call Transfer returns work file.
     *
     C     zzclrwk       begsr
     *
     C     #user         setll     workrtn
     C                   dow       forevr = forevr
     C     #user         reade     workrtn
     C                   select
     C                   when      %eof
     C                   leave
     C                   other
     C                   delete    wkrrec
     C                   endsl
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCVTDT  Convert date to selected format.
     *
     C     zzcvtdt       begsr
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCVST   Convert quantities into string for display.
     *
     C     zzcvst        begsr
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZEND  End current task.
     *
     C     zzend         begsr
     *    No current task to end.
     C     curtrn        cabeq     0             endend
     *    End current task
     C                   eval      wotrn# = curtrn
     C     wotrn#        chain     pirtran                            79
 1B  C                   if        not *in79
 2B  C                   if        curtyp = 'D'  and
     C                             curtsk <> 'IDLE  '
     C                   eval      ptstat = '3'
 2X  C                   else
     C                   eval      ptstat = '4'
 2E  C                   endif
     C                   eval      ptetyp = 'N'
 1E  C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   update    ptrec                                79
 1B  C                   if        *in79
     C                   eval      error = *on
     C*                  exsr      zm72
goto Csr                 goto      endend
 1E  C                   endif
     *
 1B  C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *    Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
 1E  C                   endif
     *
     C     endend        endsr

     *----------------------------------------------------------------
     *
     *  ZZGTBS   Retrieve base slot for virtual slot
     *
     C     zzgtbs        begsr
     *
     C     sl2aky        chain     vslot1                             79
 1B  C                   if        %found
     C                   eval      vrtslt = '*YES'
 1X  C                   else
     C                   eval      vrtslt = '*NO '
 2E  C                   endif
     *
     C     endgtb        endsr

     *----------------------------------------------------------------
     *
     *  ZZGTIT   Get item description info
     *
     C     zzgtit        begsr
     *
     C     itkey         chain     piritem
     C                   select
     C                   when      not %found
     *
     C                   when      %found
     *
     C     imkey         chain     itemmsc
     C                   if        not %found
     C                   eval      imnrpk = 1
     C                   endif
     C                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGTPSLT  Get pick slot for item.
     *
     C     zzgtpslt      begsr
     *
     C                   call      'GETPSLT'
     C                   parm                    $kcmd             8
     C                   parm      w1whse        $kwhse            3 0
     C                   parm      fmitem        $kitem           15
     C                   parm                    $kslot           12
     C                   parm      *blanks       $kaisl            3
     C                   parm      *zeros        $kloc             3 0
     C                   parm      *zeros        $krlvl            2 0
     C                   parm      *blanks       $khand            2
     C                   parm      *blanks       $krtn             8
     *
     C                   endsr

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
 1B  C                   select
 1X  C                   when      tktlvl = 'S'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = itwhdp
     C                   eval      ptstyp = itstyp
     *
 1X  C                   when      tktlvl = 'D'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = itwhdp
     C                   eval      ptstyp = *blanks
     *
 1X  C                   other
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
 1E  C                   endsl
     C                   eval      ptshft = #shft
     C                   eval      ptcrew = #crew
     C                   eval      ptemp# = #emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptrdte = $cvd8o
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
     C                   write     ptrec
 1B  C                   if        %error
     C                   eval      error = *on
     C**                 exsr      zm71
goto Csr                 goto      endidl
 1E  C                   endif
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
     C                   endsr
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
     *R                   Z-ADD0         PTINP1
     *R                   MOVE *ON       REPOS
     *R                   END
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP   '
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
 1B  C                   when      $pocmd = '*TOP   '
     C                   if        w1whdp = '*ALL '
     C     w1whse        setll     whdept
     C                   else
     C     partky        setll     record
     C                   endif
     *
 2B  C                   when      $pocmd = '*BOTTOM'
     C     partky        setgt     record
 2E  C                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZSLOT   Routine to find available pick slot.
     *
     C     zzslot        begsr
     *
     C                   exsr      zzgtpslt
     *
     C                   select
     C                   when      $krtn = '*NONE   '
     C                   eval      slotfnd = '*NO '
     *
     *    Pick slot found. Check for available quantity.
     C                   when      $krtn = '*OKPICK ' or $krtn = '*OKOVRF'
     C     sl2aky        chain(n)  slot2
     C                   eval      slotfnd = '*YES'
     C                   eval      vrtslt  = '*NO '
     *
     *    Retrieve base slot for virtual pick slot. Base slot will be
     *    used for display and validation.  All updates will be done
     *    to virtual slot.
     C                   if        slrsrv = 'V'
     C***                exsr      zzgtbs
     C                   eval      updslot = $kslot
     C                   else
     C                   eval      updslot = $kslot
     C                   endif
     C                   endsl
     *
     C     endslo        endsr

     *----------------------------------------------------------------
     *
     *  ZZTFEND  End Transfer Will Call task.
     *
     C     zztfend       begsr
     *
     *    End current task
     C     curtrn        chain     pirtran
 1B  C                   if        %found and pttask = 'TFRWIL'
     C                   eval      ptpcs  = ptpcs + totpcs
     C                   eval      ptstat = '4'
     C                   eval      svtask = pttask
     C                   eval      svtrn# = pttrn#
     C                   eval      ptetyp = 'N'
 1E  C                   endif
     *
     *    Update Task Detail with total pieces picked.
     C                   call      @adjtd
     C                   parm      '*INCACT '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *    Update Task Detail. Moving active qty's to closed qty's.
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   update    ptrec
 1B  C                   if        %error
     C                   eval      error = *on
     C**                 exsr      zm72
goto Csr                 goto      endtfe
 1E  C                   endif
     *
 1B  C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *    Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
 1E  C                   endif
     *
     C     endtfe        endsr

     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   move      '2'           kystat1
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1
 1B  C                   if        %eof
     C                   move      *off          found
goto Csr                 goto      endtsk
 1E  C                   endif
     *
     C     ptke22        setll     pirtran2
 1B  C                   dow       forevr = forevr
     C                   read      pirtran2
 2B  C                   if        %eof   or
     C                             ptemp# <> #emp#
     C                   move      *off          found
 1L  C                   leave
 2E  C                   endif
 2B  C                   if        ptstat <> '2'
 1I  C                   iter
 2E  C                   endif
     *    Found an active transaction
     C                   move      *on           curent
     C                   eval      curtrn = pttrn#
     C                   move      pttask        t#task
     C     tkkey         chain     task
 2B  C                   if        %found
     C                   move      tkcode        curtsk
     C                   move      tktype        curtyp
 2E  C                   endif
 1L  C                   leave
 1E  C                   enddo
     C     endtsk        endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
     *
     *    Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *    Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     C     dshh          mult      60            tmpbeg
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *    Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     *
     *    If the ending time is < starting time, than
     *    we have gone past the midnight.
     *
 1B  C                   if        fintim < strtim
     C                   add       24            dshh
 1E  C                   endif
     C     dshh          mult      60            tmpend
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
 1B  C                   if        timlen < 0
     C                   eval      timlen = 0
 1E  C                   endif
     *
     C     endtim        endsr

     *----------------------------------------------------------------
     *
     *  ZZUHLD  Update held quantities.
     *
     C     zzuhld        begsr
     *
     C                   eval      $acmd = '*HOLD   '
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse  = slwhse
     C                   eval      $aitem  = slitem
     C*                  eval      $aqty1  = w4qty1
     C*                  eval      $aqty2  = w4qty2
     C*                  eval      $aqty3  = w4qty3
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
 1B  C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
 1E  C                   endif
     C     endhld        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     C                   eval      error = *off
     *
     *    Clear work file of any old entries for this user.
     *
     C                   exsr      zzclrwk
     *
     *   Get system options.
     *
     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM '
     C     optsky        chain     options
 1B  C                   if        not %found
     C                   eval      opmpck = 'N'
 1X  C                   else
     C                   eval      opdat2 = opdata
 1E  C                   endif
     C                   eval      nbrpck = *zeros
     *
     *   Get department Options.
     *
     C                   eval      kywhdp = w1whdp
     C                   eval      kycode = '*PICK   '
     C     keyopd        chain     optiond
 1B  C                   if        not %found
     C                   eval      opmput = 'N'
 1E  C                   endif
     *
     *    Start loop for user to begin will call item returns.
     *
     *    Get current task.
     *
     C                   eval      curtrn = *zeros
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     *    Now end current task.
 1B  C                   if        curent = *on
     C                   exsr      zzend
 1E  C                   endif
     *
     *    Create new transaction record for this batch.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     *
     C                   eval      @ptask = 'TFRRTN'
     C                   eval      curtsk = 'TFRRTN'
     C                   eval      @pcube = *zeros
     C                   eval      @pswgt = *zeros
     C                   call      @addtr
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#
     C                   parm                    @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      #whdp         @pwhdp
     C                   parm      #styp         @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm      0             @ppcs
     C                   parm      1             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      *blanks       @ppo
     C                   parm      'L'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   exsr      scr02i
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     *
     *    Save 'from' slot expiration date.
     C                   z-add     slexpd        svexpd
     *    Look for first pick slot for item to be returned.
     C                   eval      slotfnd = '*NO '
     C                   eval      $kcmd  = '*FRSTFRS'
     C                   eval      $kslot = *blanks
     *
     C                   exsr      zzslot
     *
     *    Write item return info into work file.f
     C                   exsr      zzadrtn
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   move      *off          error
     *
     *    Update totals.
     *
     C                   eval      totpcs = totpcs + wkrqy1 + wkrqy2 + wkrqy3
     *
     *    Reduce From Slot stock qty with Transfer Qty.
     *
     C                   eval      kywhdp = wkrwhd
     C     fmkey         chain     slot2
     C                   select
     C                   when      %found
     *
     *     Save FIFO information from "From" slot
     *
     C                   eval      svprty = slprty
     C                   z-add     slexpd        svexpd
     C                   z-add     slentd        sventd
     C                   z-add     slslfd        svslfd
     C                   move      slactv        svactv
     C                   move      slbld         svbld
     *
     *    Note: Stock quantity could go negative if a receiving
     *          transaction has not been closed yet so let it be.
     *
     C                   select
     C                   when      wkrqy1 > 0
     C                   eval      slstk1 = slstk1 - wkrqy1
     C                   endsl
     C                   select
     C                   when      wkrqy2 > 0
     C                   eval      slstk2 = slstk2 - wkrqy2
     C                   endsl
     C                   select
     C                   when      wkrqy3 > 0
     C                   eval      slstk3 = slstk3 - wkrqy3
     C                   endsl
     *
     *   Check if break down qty's need to be adjusted.
     C                   if        brkdwn1 = '*YES' or brkdwn2 = '*YES'
     C                   exsr      zzadjqy
     C                   endif
     *
     C                   exsr      zzavail
     *
     *   Check if status needs to be changed
     *
     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnews            2
     C                   parm                    $crtn             8
     *
 1B  C                   if        $crtn = '*CHANGED'  and
     C                             pttask <> 'REPLTF'  or
     *
     C                             $crtn = '*CHANGED'  and
     C                             pttask = 'REPLTF'  and
     C                             lbdisp <> lbdsp2
     *
     C                   eval      slstat = $cnews
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      slsdte = $cvd8o
     C                   time                    slstim
 1E  C                   endif
     *
     C                   update    slrec2
     C                   endsl
     *    Update ITEMQTY held quantities.
 1B  C                   if        slstat <> 'A'
     C                   z-sub     wkrqy1        $aqty1
     C                   z-sub     wkrqy2        $aqty2
     C                   z-sub     wkrqy3        $aqty3
     C                   exsr      zzuhld
     C                   endif
     *
     *    Create label records for case Will Call transfer return.
     *
 1B  C                   select
 1X  C                   when      wkrqy1 <> 0
     *
     C                   eval      lbwhse = itwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = 0
     C                   eval      lbitem = wkritm
     C                   eval      toitem = wkritm
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = sldisp
     C                   eval      lbqavl = avail1
     *
     *    Retrieve To Slot information.
     *
     C     tokey         chain     slot2
     *
     *    Retrieve tie/high for From slot.
     *
     C     idkey         chain     itemdef
     C                   select
     C                   when      not %found
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros
     *
     C                   when      %found
     C                   eval      lbtie  = idtie
     C                   eval      lbhigh = idhigh
     *
     C                   endsl
     *
     *    Update Label record with To Slot info.
     *
     C                   eval      lbwhs2 = slwhse
     C                   eval      lbwhd2 = slwhdp
     C                   eval      lbasl2 = slaisl
     C                   eval      lbloc2 = slloc
     C                   eval      lblvl2 = slrlvl
     C                   eval      lbhnd2 = slhand
     C                   eval      lbdsp2 = sldisp
     C                   eval      lbrte  = *blanks
     C                   eval      lbstop = *zeros
     C                   eval      lbord  = *zeros
     C                   eval      lbspcl = 'WC'
     C                   eval      lbpo   = *blanks
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = wkrum1
     C                   eval      lbucub = itcube
     C                   eval      lbcube = itcube * wkrqy1
     C                   eval      lbuwgt = itswgt
     C                   eval      lbswgt = itswgt * wkrqy1
     C                   eval      lbqalc = wkrqy1
     C                   eval      lbqrmn = *zeros
     C                   eval      lbqpck = wkrqy1
 2B  C                   if        slitem = toitem
     C                   eval      lbgrp1 = '1'
 2X  C                   else
     C                   eval      lbgrp1 = '2'
 2E  C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbprty = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      lbsdte = $cvd8o
     C                   time                    lbstim
     C                   eval      lbrdte = $cvd8o
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
     C                   eval      lbgrp2 = 'B'
     C                   write     lbrec
     *
 1E  C                   endsl
     *
     *--------------------------------------------------------------------
     *
     *    Create transfer record for breakdown 1 qty.
     *
 1B  C                   select
 1X  C                   when      wkrqy2 <> 0
     C                   eval      kywhdp = wkrwhd
     C     fmkey         chain     slot2
     C                   exsr      zzavail
     *
     C                   eval      lbwhse = itwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = 0
     C                   eval      lbitem = slitem
     C                   eval      toitem = slitem
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = sldisp
     C                   eval      lbqavl = avail1
     *
     *    Retrieve To Slot record info for label record.
     C                   eval      kywhdp = w4whdp
     C                   eval      todisp = w4scan
     C     tokey         chain(n)  slot2
     *
     *    Retrieve tie/high for From slot.
     *
     C     idkey         chain     itemdef
     C                   select
     C                   when      not %found
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros
     *
     C                   when      %found
     C                   eval      lbtie  = idtie
     C                   eval      lbhigh = idhigh
     *
     C                   endsl
     *
     *    Update Label record with To Slot info.
     *
     C                   eval      lbwhs2 = slwhse
     C                   eval      lbwhd2 = slwhdp
     C                   eval      lbasl2 = slaisl
     C                   eval      lbloc2 = slloc
     C                   eval      lblvl2 = slrlvl
     C                   eval      lbhnd2 = slhand
     C                   eval      lbdsp2 = sldisp
     C                   eval      lbrte  = *blanks
     C                   eval      lbstop = *zeros
     C                   eval      lbord  = *zeros
     C                   eval      lbspcl = 'WC'
     C                   eval      lbpo   = *blanks
     C                   eval      lbutyp = '1'
     C                   eval      lbucod = wkrum2
     C                   if        itumq2 > 0
     C                   eval      lbucub = itcube / itumq2
     C                   else
     C                   eval      lbucub = itcube
     C                   endif
     C                   eval      lbcube = lbucub * wkrqy2
     C                   if        itumq2 > 0
     C                   eval      lbuwgt = itswgt / itumq2
     C                   else
     C                   eval      lbuwgt = itswgt
     C                   endif
     C                   eval      lbswgt = lbuwgt * wkrqy2
     C                   eval      lbqalc = wkrqy2
     C                   eval      lbqrmn = *zeros
     C                   eval      lbqpck = wkrqy2
     C                   eval      lbgrp1 = '1'
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbprty = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      lbsdte = $cvd8o
     C                   time                    lbstim
     C                   eval      lbrdte = $cvd8o
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
     C                   eval      lbgrp2 = 'B'
     C                   write     lbrec
     *
 1E  C                   endsl
     *
     *--------------------------------------------------------------------
     *
     *    Create transfer record for breakdown 2 qty.
     *
 1B  C                   select
 1X  C                   when      wkrqy3 <> 0
     C                   eval      kywhdp = wkrwhd
     C     fmkey         chain     slot2
     C                   exsr      zzavail
     *
     C                   eval      lbwhse = itwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = 0
     C                   eval      lbitem = slitem
     C                   eval      toitem = slitem
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = sldisp
     C                   eval      lbqavl = avail1
     *
     *    Retrieve To Slot record info for label record.
     C                   eval      kywhdp = w4whdp
     C                   eval      todisp = w4scan
     C     tokey         chain(n)  slot2
     *
     *    Retrieve tie/high for From slot.
     *
     C     idkey         chain     itemdef
     C                   select
     C                   when      not %found
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros
     *
     C                   when      %found
     C                   eval      lbtie  = idtie
     C                   eval      lbhigh = idhigh
     *
     C                   endsl
     *
     *    Update Label record with To Slot info.
     *
     C                   eval      lbwhs2 = slwhse
     C                   eval      lbwhd2 = slwhdp
     C                   eval      lbasl2 = slaisl
     C                   eval      lbloc2 = slloc
     C                   eval      lblvl2 = slrlvl
     C                   eval      lbhnd2 = slhand
     C                   eval      lbdsp2 = sldisp
     C                   eval      lbrte  = *blanks
     C                   eval      lbstop = *zeros
     C                   eval      lbord  = *zeros
     C                   eval      lbspcl = 'WC'
     C                   eval      lbpo   = *blanks
     C                   eval      lbutyp = '2'
     C                   eval      lbucod = wkrum3
     C                   if        itumq3 > 0
     C                   eval      lbucub = itcube / itumq3
     C                   else
     C                   eval      lbucub = itcube
     C                   endif
     C                   eval      lbcube = lbucub * wkrqy3
     C                   if        itumq3 > 0
     C                   eval      lbuwgt = itswgt / itumq3
     C                   else
     C                   eval      lbuwgt = itswgt
     C                   endif
     C                   eval      lbswgt = lbuwgt * wkrqy3
     C                   eval      lbqalc = wkrqy3
     C                   eval      lbqrmn = *zeros
     C                   eval      lbqpck = wkrqy3
     C                   eval      lbgrp1 = '1'
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbprty = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      lbsdte = $cvd8o
     C                   time                    lbstim
     C                   eval      lbrdte = $cvd8o
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
     C                   eval      lbgrp2 = 'B'
     C                   write     lbrec
     *
 1E  C                   endsl
     *--------------------------------------------------------------------
     *
     *    Update "To Slot" Quantities.
     *
     C     tokey         chain     slot2
     C                   select
     *
     *    Update Transfer Will Call slot stock quantities.
     C                   when      not %found
     *
     C                   clear                   slrec2
     *
     *    Update "To Slot" stock quantities.
     C                   eval      slstk1 = slstk1 + wkrqy1
     *
 4B  C                   if        wkrqy2 <> 0
     C                   eval      slstk2 = slstk2 + wkrqy2
 4E  C                   endif
     *
 4B  C                   if        wkrqy3 <> 0
     C                   eval      slstk3 = slstk3 + wkrqy3
 4E  C                   endif
     C                   eval      slstat = 'V '
     *
 1B  C                   if        slstat = 'Z '  or
     C                             slstat = 'V '
     C                   eval      slstat = 'A '
     C                   eval      slentd = sventd
     C                   eval      slexpd = svexpd
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   eval      slprty = svprty
 1E  C                   endif
     C                   eval      slitem = svitem
     *
     *     Don't allow zero entered date.
     *
 1B  C                   if        slentd = 0
     C                   eval      slentd = sventd
 1E  C                   endif
     *
     *     Make sure "To" slot stays in correct FIFO order.
     *
 1B  C                   if        svprty < slprty  or
     C                             svprty = slprty  and
     C                             svexpd < slexpd  or
     C                             svprty = slprty  and
     C                             sventd < slentd
     C                   eval      slprty = svprty
 1E  C                   endif
     *
     *      Calculate available quantity
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
     *
     *      Make sure breakdown qty's are not greater than
     *        quantity in the unit of measure.
     *
     C                   exsr      zzadjqy
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
 1B  C                   if        newvs  = *on
     C                   eval      slwhse = $vwhse
     C                   eval      slwhdp = $vwhdp
416c C                   if        phstat <> 'Z ' and
416c C                             phstat <> 'V '
416c C                   eval      slstat = phstat
416c C                   else
     C                   eval      slstat = 'A '
416c C                   endif
     C                   eval      slaisl = $vaisl
     C                   eval      slloc  = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   eval      slstyp = $vstyp
     C                   eval      sldisp = $vdisp
     C                   eval      slsdef = phsdef
     C                   eval      sldesg = phdesg
     C                   eval      slactv = svactv
     C                   eval      slbld  = svbld
     C                   eval      slpick = $vpick
     C                   eval      slpseq = $vpseq
     C                   eval      slslfd = 0
     C                   eval      slrsrv = 'V'
     C                   eval      slentd = sventd
     C                   eval      slexpd = svexpd
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   eval      slprty = svprty
     *
     C                   write     slrec2
     *
 2B  C                   if        %error
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   exsr      zm72
goto Csr                 goto      endup4
 2E  C                   endif
     *
     *  create vslot record.
     *
     C                   eval      vswhse = $vwhse
     C                   move      $vwhdp        vswhdp
     C                   move      $vaisl        vsaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   move      phdisp        vspdis
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      vscdte = $cvd8o
     C                   time                    vsctim
     C                   add       1             vsctim
     *
     C                   write     vsrec
     *
 2B  C                   if        %error
     C                   eval      $prtn = '*PGMQ   '
     C                   move      *on           error
     C                   exsr      zm72
goto Csr                 goto      endup4
 2E  C                   endif
 2E  C                   endif
     *
     *--------------------------------------------------------------------
     C                   when      %found
     *
     *    Update "To Slot" stock quantities.
     C                   add       wkrqy1        slstk1
     *
 4B  C                   if        wkrqy2 > 0
     C                   add       wkrqy2        slstk2
 4E  C                   endif
     *
 4B  C                   if        wkrqy3 > 0
     C                   add       wkrqy3        slstk3
 4E  C                   endif
     *
     *    Adjust breakdown quantities be less than qty multiplier.
     C                   if        brkdwn1 = '*YES' or brkdwn2 = '*YES'
     C                   exsr      zzadjqy
     C                   endif
     *
     C                   update    slrec2
     *
     C                   endsl
     *    Update ITEMQTY held quantities.
 1B  C                   if        slstat <> 'A'
     C                   z-add     wkrqy1        $aqty1
     C                   z-add     wkrqy2        $aqty2
     C                   z-add     wkrqy3        $aqty3
     C                   exsr      zzuhld
     C                   endif
     *
     *    Remove record from work file.
     *
     C     wkkey         chain     workrtn
     C                   if        %found
     C                   delete    wkrrec
     C                   endif
     *
     *    Go to screen 4 to return item to slot.
     *
     C                   exsr      scr04i
     *
     C     endup4        endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD9   Update for screen 9.
     *
     C     zzupd9        begsr
     C                   move      *off          error
     *
     *    Retrieve current task / transaction.
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     *    End current transaction and update total time.
     C                   if        curent = *on
     C                   exsr      zztfend
     C                   endif
     *
     *    Start Idle transaction while waiting for user to start new batch.
     C                   exsr      zzidle
     *
     C     endup9        endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD99  Update for screen 99.
     *
     C     zzupd99       begsr
     C                   move      *off          error
     C                   select
     C                   when      rtnto = '01 '
     C                   eval      stop1 = *on
     C                   exsr      scr01i
     *
     C                   when      rtnto = '02 '
     C                   eval      stop1 = *on
     C                   exsr      scr02i
     *
     C                   when      rtnto = '03 '
     C                   eval      stop1 = *on
     C                   exsr      scr03i
     *
     C                   when      rtnto = '04 '
     C                   eval      stop1 = *on
     C                   exsr      scr04i
     *
     C                   endsl
     *
     C     endup99       endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1
**  OPTLN - Option display line
 1=Select
**  CMDLN - Command display line
F12=Cancel  PgUp/Dn
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
**
Slot not scanned
Slot not found
Slot in wrong dept
Not a Fixed slot
Not a PIR slot
From/To slot the same
From slot not found.
