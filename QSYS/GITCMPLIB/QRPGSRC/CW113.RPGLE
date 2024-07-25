     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CW113     Catch Weight Total - Verify
     *  05 August 1999
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *
412BA*    08/23/99  RH
     *      - Add LBL# to PARMS, key for ORDC1 changed.
     *      - Change to use LABEL file.
416 A*    07/02/02  RH   4.16
     *      - Recompiled, ITEMMSC changed.
416aA*    08/02/02  MLB  4.16a
     *      - Fix: Revised ZZCHKT to test LVSKP,HVSKP separately.
417aA*    04/03/03  RH   4.17a
     *      - ENH: Recompiled, ITEMMSC file changed.
510 A*    04/18/07  RBD  5.10
     *      - Enh: Added client custom code support to program.
530a *    04/27/10  GJA  5.30a     P#00243
     *      - Enh: Changed UCI to be option driven.  OPUCI
530b *    05/11/10  GJA  5.30b     P#00243
     *      - Fix: Changed UCI option position.
530c *    05/13/10  JCJ  5.30C
     *      - Enh: Add new catch weight option values.
530d *    06/18/10  JCJ  5.30d
     *      - Enh: Bypass edits if LBQPCK = 0.
530e *    06/21/10  JCJ  5.30e
     *      - Fix: If total catch weight count = 1 but the total
     *             catch weight = 0 flag as an error.
640aA*    11/13/12  JCJ  6.40a
     *      - Enh: Converted to RPGIV.
     *      - Enh: Added miising system options.
650aA*    09/26/13  ???  6.50a
     *      - Enh: Allow 1 catch weight for the total catch weight.
     *
710 A*    09/01/17  MLB  7.10  P# 2017066
     *      - Enh: Revised 6.50d mod. Added test for number of wgts
     *        to be equal zero. This will prevent someone from zeroing
     *        pick quantity, but not removing weights. Customer ends
     *        up getting billed, but received zero product.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBIaA*    10/06/03  RH   CBIa
     *      - ENH: Get OHMISC, if type E=Export, allow total CW entry.
CBIbA*    06/16/14  JCJ  CBIb
     *      - ENH: do not perform catch weight count check for Cheney
     *        GWB.
      *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
PAK A*    04/18/07  RBD  PAK  (removed  530a)
     *      - If catchweight has UCI label, bypass weight
     *        variance checks.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee- Leggett
     *
EBLaA*    06/19/07  DAS  EBLa
     *      - Revised program to not check total weight when option
     *        for individual weight entry is 'Y'
     *
EBLbA*    05/14/10  JCJ  EBLb
     *      - Removed EBLa change because new option valuse can be
     *        used to control this change.
     *      *** New system options for Catch Weights will need  ***
     *      *** to be put in place before this mod can be       ***
     *      *** activated.   (OP210)                            ***
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    05/06/10  MLB  DRY
     *      - Revised program to not check individual catchweights
     *        when command is *EDITCLS.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fordc1     if   e           k disk
     Fitemmsc   if   e           k disk
     Foptions   if   e           k disk
412BMFLabel     if   e           k disk
412BD*ABEL7  IF  E           K        DISK
PAK AFucicw9    if   e           k disk
CBIaAFORDH      if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
     D @getcl          c                   const('GETCLIENT')
510 A*
CBI A /copy qcopysrc,id#cheney
CBIbA /COPY QCOPYSRC,Id#cheneyg
CBIbA /COPY QCOPYSRC,Id#cheneyo
CBIbA /COPY QCOPYSRC,Id#cheneyr
PAK A /copy qcopysrc,id#packers
EBLaA /copy qcopysrc,id#ellenbe
DRY A /copy qcopysrc,id#dairyla
HKWaA /copy qcopysrc,id#hkw
CBIaA*----------------------------------------------------------------
CBIaAD                 ds
CBIaAD  dsmisc                 1     20
CBIaAD  dssdte                 1      8
CBIaAD  dsspcl                 9     11
CBIaAD  dsrpck                12     12
CBIaAD  dsdoor                13     14
CBIaAD  dsmeat                15     15
CBIaAD  dscode                16     16
CBIaA*
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
     D  $ptrn#                22     28  0
     D  $pitem                29     43
     D  $pseq#                44     48  0
412B D  $plbl#                49     55  0
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
530cD*****OPWRNC  -  Perform catch weight variance check (Y,N).
530cM*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
530cD*****OPICW   -  Individual catch weight entry (Y,N).
530cM*    OPICW   -  Check CW count during selection closing (N,M,C,B)
640aA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
640aA*    OPRCDY  -  Number of days to keep receiving logs.
640aA*    OPMPCK  -  Number of days to keep picking logs.
640aA*    OPRTHS  -  Number of weeks - exported routes to keep.
640aA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
640aA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
640aA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
640aA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
640aA*    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
640aA*    OPISHS  -  Number of weeks to keep history file
530aA*    OPUCI   -  Use UCI processing (Y,N)
640aA*    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
640aA*    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
640aA*    OPTRAX  -  Using TRAX module (Y,N).
640aA*    OPTAXR  -  Using TAXR module (Y/N).
640aA*    OPCHKR  -  Using CHKR module (Y/N).
640aA*    OPVOICE -  Using VOICE module (Y/N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
640aAD  opmpck                14     14
640aAD  oprcdy                15     15  0
640aAD  oppkdy                16     16  0
640aAD  oprths                17     19  0
640aAD  opcrhs                20     22  0
640aAD  oppohs                23     25  0
640aAD  opiahs                26     28  0
640aAD  opmshs                29     31  0
640aAD  optbjq                32     32
640aAD  opishs                33     35  0
530bMD  opuci                 36     36
640aAD  opwrncr               37     37
640aAD  opicwr                38     38
640aAD  optrax                39     39
640aAD  optaxr                40     40
640aAD  opchkr                41     41
640aAD  opvoice               42     42
     D  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     * Work Variables
     *
     D exwgt           s              9  2
     D hirng           s              9  2
     D hivar           s              9  2
     D wotcw           s              9  2
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D lwrng           s              9  2
     D lwvar           s              9  2
     D today           s              8  0
     D wocw#           s              7  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D forevr          s              1
     D hvskp           s              1
     D icwflg          s              1
     D lvskp           s              1
     D rncflg          s              1
     D stop            s              1
     D uciflg          s              1
     D error           s              1
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
DRY M*      $PCMD   *EDITCLS - Edit batch - Transaction close in progress
     *              *EDIT    - Edit batch.
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
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     * Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     *
     * Calculate variance range.
     C                   exsr      zzcalc
     *
     * Whip through all the CW records.
     C                   exsr      zztotl
     *
     * Check for errors.
     C                   exsr      zzchkt
     *
     *  We are finished so get out
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
     *
     * Key definitions
     *
     *
     *  Define full key for detail file.
     *
     C     cwkey         klist
     C                   kfld                    $pwhse
412BMC                   kfld                    oclbl#
     C                   kfld                    ocseq
     *
     *  Define partial key for detail file.
     *
     C     cwkeyp        klist
     C                   kfld                    $pwhse
412BMC                   kfld                    $plbl#
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
412BD*  Define full key for LABEL7 file.
412BD*
412BD*R         LBKEY     KLIST
412BD*R                   KFLD           $PTRN#
412BD*R                   KFLD           $PITEM
412BD*R                   KFLD           $PSEQ#
     *
412BA*  Define full key for LABEL file.
412BA*
412BAC     lbkey         klist
412BAC                   kfld                    $plbl#
     *
     *  Define full key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
CBIaA*
CBIaA*  Define key for ORDH file.
CBIaA*
CBIaAC     ohkey         klist
CBIaAC                   kfld                    lbwhse
CBIaAC                   kfld                    lbord
     *
PAK A*  Define key for UCICW9 file.
PAK A*
PAK AC     uckey         klist
PAK AC                   kfld                    $pwhse
PAK AC                   kfld                    $ptrn#
PAK AC                   kfld                    $plbl#
     *
     C                   eval      $lprg = #prog
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
     C                   eval      $lprg = #prog
     C                   exsr      zzinz2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC   Calculate total expected catch weight and ranges
     *
     C     zzcalc        begsr
     C                   eval      error = *off
404 A*
410 A*   If verify catch weight = yes,
410 A*     Calculate total expected catch weight,
410 A*     Calculate low/high ranges.
530cD***        OPWRNC    IFEQ 'Y'
530cMC                   if        rncflg = 'Y'
410 AC                   eval      lwvar = 0
410 AC                   eval      hivar = 0
410 AC                   eval      lwrng = 0
410 AC                   eval      hirng = 0
410 AC                   eval      exwgt = 0
412 AC                   eval      ilvar = 0
412 AC                   eval      ihvar = 0
412 AC                   eval      ilrng = 0
412 AC                   eval      ihrng = 0
410 AC     lbqpck        mult      lbuwgt        exwgt
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
     C     imkey         chain     itemmsc                            79
     C                   if        not *in79
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     C                   if        prg1c = 0
410 AC     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
410 AC     oprg2c        div       100           prg2c
     C                   endif
410 A*
412 D*          OPRG1C    IFGT 0
412 MC                   if        prg1c > 0
410 AC     exwgt         mult      prg1c         lwvar
412 AC                   eval      ilvar = lbuwgt * prg1c
410 AC                   endif
410 AC                   eval      lwrng = exwgt - lwvar
412 AC                   eval      ilrng = lbuwgt - ilvar
412 D*          OPRG2C    IFGT 0
412 MC                   if        prg2c > 0
410 AC     exwgt         mult      prg2c         hivar
412 AC                   eval      ihvar = lbuwgt * prg2c
410 AC                   endif
410 AC     exwgt         add       hivar         hirng
412 AC     lbuwgt        add       ihvar         ihrng
410 A*
410 AC                   endif
     *
410 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Error check totals
     *
     C     zzchkt        begsr
     C                   eval      error = *off
     *
530dAC                   if        lbqpck = 0
710 AC                             and wocw# = 0
530dDC                   goto      endckt
530dAC                   endif
     *
     *     Check # of entrys >0 if OPCAPC (capture cw at closing) = Y
     *
     C                   if        opcapc = 'Y'
     C                             and wocw# <= 0
530eAC                             or wocw# = 1
530eAC                             and wotcw = 0
410 AC                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
410 AC                   endif
     *
650aAC                   if        opcapc = 'Y'
650aAC     imkey         chain     itemmsc
650aAC                   if        not %found(itemmsc)
650aAC                   eval      imwrnc = 'Y'
650aAC                   endif
650aAC                   endif
     *
650aAC                   select
     *
650aA*     Allow 1 total weight for cw total
     *
650aAC                   when      opcapc = 'Y'
650aAC                             and imwrnc = 'Y'
650aAC                             and wocw# = 1
650aAC                             and wotcw > 0
650aAC                   other
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
530cMC                   if        icwflg = 'Y'
     C                   if        wocw# <> lbqpck
CBIbAC                             and clientloc <> cbigwb
410 AC                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
410 AC                   endif
410 AC                   endif
     *
650aAC                   endsl
530cD***
530cD***   For Ellenbee, skip if entering individual weights.
530cD***
530cD***        CLIENT    IFEQ ELLENB
530cD***        OPICW     ANDEQ'Y'
530cD***                  GOTO ENDCKT
530cd***                  ENDIF
     *
PAK A*     Set UCI flag ... if flag is on, bypass variance check
PAK AC                   exsr      zzflg
     *
410 A*     Compare total catchweight to expected catchweight
410 A*
530cMC                   if        rncflg = 'Y'  and
PAK AC                             uciflg = *off
     *
412 AC                   select
412 AC                   when      lvskp = *off
412 AC                   if        wotcw < lwrng
410 AC                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
410 AC                   endif
416aAC                   endsl
416aA*
416aAC                   select
412 AC                   when      hvskp = *off
412 AC                   if        wotcw > hirng
410 AC                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
410 AC                   endif
     *
412 AC                   endsl
     *
410 AC                   endif
     *
EBLaMC     endckt        endsr
     *----------------------------------------------------------------
     *
530aM*  ZZFLG    Set UCI flag ... check options
PAK A*  ZZFLG    Set UCI flag ... if client is Packers and the
PAK A*           catchweight has a UCI label rec, turn on UCI flag
     *
PAK AC     zzflg         begsr
     *
PAK AC                   eval      uciflg = *off
530aD*****      CLIENT    IFEQ PACKER
530aAC                   if        opuci = 'Y'
PAK AC     uckey         chain     ucicw9                             79
PAK AC                   if        not *in79  and
PAK AC                             ucilbl <> *zeros
PAK AC                   eval      uciflg = *on
PAK AC                   endif
530aAC                   endif
     *
PAK AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
     C                   endif
     *
530cAC                   select
530 A* no individual CW count
530cAC                   when      opicw = 'N'
530cAC                   eval      icwflg = 'N'
530 A* individual CW count during manual entry
530cAC                   when      opicw = 'M'
530cAC                             and $pcmd <> '*EDITCLS'
530cAC                   eval      icwflg = 'Y'
530 A* individual CW count during closing step
530cAC                   when      opicw = 'C'
530cAC                             and $pcmd = '*EDITCLS'
530cAC                   eval      icwflg = 'Y'
530 A* perform individual CW count
530cAC                   when      opicw = 'B'
530cAC                   eval      icwflg = 'Y'
530cAC                   other
530cAC                   eval      icwflg = 'N'
530cAC                   endsl
530 A**
530 A** determine if individual variance catch weight check is done
530 A**
530cAC                   select
530 A* no individual CW variance check
530cAC                   when      opwrnc = 'N'
530cAC                   eval      rncflg = 'N'
530 A* do individual CW variance check during manual entry
530cAC                   when      opwrnc = 'M'  and
530cAC                             $pcmd <> '*EDITCLS'
530cAC                   eval      rncflg = 'Y'
530 A* do individual CW variance check during closing step
530cAC                   when      opwrnc = 'C'  and
530cAC                             $pcmd = '*EDITCLS'
530cAC                   eval      rncflg = 'Y'
530 A* perform individual CW variance check
530cAC                   when      opwrnc = 'B'
530cAC                   eval      rncflg = 'Y'
530cAC                   other
530cAC                   eval      rncflg = 'N'
530cAC                   endsl
530cA*
412BD*R         LBKEY     CHAINLABEL7               79
412BMC     lbkey         chain     label                              79
     C                   if        *in79
     C                   eval      lbqpck = 0
     C                   eval      lbuwgt = 0
     C                   endif
CBIaA*
CBIaA*   If order is type 'E', set system options to allow total cw.
CBIaAC                   if        client = Cheney
CBIaAC     ohkey         chain     ordh
CBIaAC                   if        %found(ordh)
CBIaAC                   eval      dsmisc = ohmisc
CBIaAC                   if        dscode = 'E'
CBIaAC                   eval      opicw = 'N'
CBIaAC                   endif
CBIaAC                   endif
CBIaAC                   endif
     *
     *   Initialize counter and total fields.
     C                   eval      wocw# = 0
     C                   eval      wotcw = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTOTL   Recalculate total cw and entered cw.
     *
     C     zztotl        begsr
     C                   eval      error = *off
     C                   eval      wotcw = 0
     C                   eval      wocw# = 0
     *
     *   Loop through CW records and recaluclate.
     *
     C     cwkeyp        setll     ordc1
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     cwkeyp        reade     ordc1                                  79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   add       occwgt        wotcw
     C                   add       1             wocw#
     C                   endif
     C                   enddo
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
