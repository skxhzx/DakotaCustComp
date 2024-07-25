530aD *copy qcopysrc,hspecs
530aM /copy qcopysrc,hspecstrnc
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TE130     Multiple Transaction Display
     *  11 November, 2003
     *  Roxanne Harrison
     *
     *  Created usiong TK110  V4.17
     *   Not a normal 110 program, do not use OPTION.
     *   Only works with selection transactions and creates IDLE.
     *
     *  Revisions
417bA*    11/20/03  RH   4.17b
     *      - Fix - Revise ZZEND to end multi trns with status 3 not 4
417cA*    08/06/04  MLB  4.17c
     *      - Fix: Revised ZZEND to call new routine ZZENDI to close
     *        any open(inuse) Indirect tasks before closing current
     *        direct task.  Having Indirect tasks still open while
     *        closing the current task was causing the direct task
     *        to be updated with negative direct minutes.
417dA*    08/10/04  DAS  4.17d
     *      - Enh: Revised to only do F21 (ZZAVG) when status sent is
     *        an '*'. This prevents the need to duplicate this logic
     *        for the time being.
     *      - Initially, the only program calling TE130 this way is
     *        ADJTRAN2.
     *      - Change TE130FM to USROPN.
500aA*    01/25/05  RH   5.00a
     *      - Fix: 417c code was missed in 417 update.
     *
500bA*    09/10/05  MLB  5.00b
     *      - Enh: Revised program to not execute ZZENDI when status
     *        sent to program = '*'. Was causing recursive call error
     *        to ADJTRAN2.
     *
500cA*    11/28/05  DAS  5.00c
     *      - Added ability to suspend a transaction. An 'S' will be
     *        passed in. Transactions will be set to status of '8'.
     *
520aA*    04/06/09  RH   5.20a
     *      - Fix: Only start IDLE if multiple transactions exist to
     *        be ended.  Was creating IDLE in error on F21 when no
     *        multiple transactions existed.
520bA*    04/22/09  RH   5.20b
     *      - Fix: TDFINW filed was not large enough, causing decimal
     *        data error.  Add WFINW work field.
520cA*    12/08/08  GJA  5.20c
     *      - Converted to RPGLE.  Create PASSTRAN for suspended
     *        Added zone modification for TASKDET
520dA*    02/12/09  GJA  5.20d
     *      - ENH:  Change to exclude TOTE from zone modificiation
520eA*    07/24/09  GJA  5.20e
     *      - Fix:  allowing active to go negative
520fA*    07/24/09  GJA  5.20f
     *      - Fix:  change to get start time from passtran
530aA*    03/29/10  GJA  5.30a
     *      - Fix: Changed hspec /copy mbr to hspectrnc which has
     *        option truncate(*yes) instead of std /copy c/ *no
     *        This was needed because fields in TASKDET file were
     *        overflowing and causing MCH1210 Receiver value too
     *        small to hold result errors.  TASKDET file will need
     *        to have fields re-sized to hold larger values to
     *        eliminate need for this mod.
640aA*    07/11/11  JCJ  6.40a
     *      - Fix: Commented out a line of code in ZZAVG that was
     *        accumalating the MUTRN# field.  This field would
     *        overflow causing a "Receiver value to small error".
640bA*    02/20/12  MLB  6.40b
     *      - Fix: Revised program to only open file WORKOPT when
     *        program is NOT called in batch mode.
640cA*    06/07/12  LMC  6.40c
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
710aA*    01/30/17  LMC  7.10a
     *      - Fix: Eliminate the ability for an IDLE with 0 whse
     *        to be created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
417dMFte130fm   cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
640bAF                                     usropn
     Fmultran   uf   e           k disk
     F                                     rename(murec:record)
     Fmultran1  if   e           k disk
     F                                     rename(murec:murec1)
     Fpirtran   uf a e           k disk
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Ftaskdet   uf   e           k disk
     Ftask      if   e           k disk
520cAFpasstran  uf a e           k disk
520cAFlabel90   if   E           K DISK
520cAFworklbl   if   E           K DISK
520cAFoptione   if   e           k disk
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
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kemp#                 1      5  0
     D  $kstat                 6      6
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  muemp#                 1      5  0 inz(0)
     D  mustat                 6      6
     D  mutrn#                 7     13  0 inz(0)
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
     D  $lcode                19     24
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
520cDD*@chgpg          c                   const('*NONE')
520cDD*@delpg          c                   const('*NONE')
520cDD*@prtpg          c                   const('*NONE')
520cMD @chgpg          c                   const('NONE')
520cMD @delpg          c                   const('NONE')
520cMD @prtpg          c                   const('NONE')
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
640cA*----------------------------------------------------------------
640cA*  Prototypes
640cA*----------------------------------------------------------------
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
520cA*----------------------------------------------------------------
     *  *USER  -  User options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N).
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Processing selection by voice (Y,N).
     *    OPZORD  -  Collect selection data by zone or department?
     *    OPTBD   -  Tote/Box/Drop?  (Y,N)
     *
     * Data structure
     *
     D opedta          ds
     D  opman                  1      1
     D  opnxte                 2      6  0
     D  opvyn                  7      7
     D  opzord                 8      8
     D  optbd                  9      9
     *----------------------------------------------------------------
     *  Variables
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D avgmin          s                   like(svtlen)
     D batch           s              1
     D bot             s              1
     D cancel          s              1
     D cktrn#          s              7  0
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D findte          s                   like(muedte)
     D fintim          s                   like(muetim)
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D ptinp1          s              4
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stdate          s                   like(musdte)
     D stop            s              1
     D strdte          s                   like(musdte)
     D strtim          s                   like(mustim)
     D sttime          s                   like(mustim)
     D svcrew          s                   like(ptcrew)
     D svedte          s                   like(muedte)
     D svetim          s                   like(muetim)
     D svshft          s                   like(ptshft)
     D svstyp          s                   like(ptstyp)
     D svtlen          s                   like(ptdmin)
     D svwhdp          s                   like(ptwhdp)
     D svwhse          s                   like(ptwhse)
     D t#task          s              6
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D top             s              1
     D trans#          s                   like(mutrn#)
     D trncnt          s              3  0
     D ttlmin          s              5  0
     D warn            s              1
640cAD wrtpcmd         s             10
640cAD wrtpwait        s              2  0
640cAD wrtpwhse        s              3  0
640cAD wrtptran#       s                   like(pttrn#)
640cAD wrtpfrmdate     s              8  0
640cAD wrtptodate      s              8  0
640cAd wrtpemp#        s                   like(ptemp#)
     D x               s              3  0
     D y               s              3  0
     D zzedte          s                   like(muedte)
     D zzetim          s                   like(muetim)
     D zzsdte          s                   like(musdte)
     D zzstim          s                   like(mustim)
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
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
417dAC                   if        batch = *off
     C                   exsr      zsclr
     C                   exsr      clrsch
417dAC                   endif
     *
     C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
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
     C                   if        error = '1'
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
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
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
     C                   read      dspsfc                                 50
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
417dD**                   EXSR ZMIMSG
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
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
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD21 - PREVIOUS
     *
     C                   if        *inkv
     C                   exsr      zzavg
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
520cAC                   if        @chgpg <> 'NONE'
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
520cAC                   endif
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
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
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
     C                   sub       10            row#
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
     *R         CLERR     CABEQ'1'       CMD01E
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
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
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
     C                   write     dspsfl
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
     C                   write     dspsfc
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
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     error         cabeq     '1'           ent01e
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
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
     C                   dou       stop = '1'
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
520cAC                   if        @delpg <> 'NONE'
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
520cAC                   endif
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
     C                   if        cancel = '0'
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
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
520cAC                   if        @chgpg <> 'NONE'
     C                   call      @chgpg
     C                   parm                    $parms
520cAC                   endif
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
520cAC                   if        @chgpg <> 'NONE'
     C                   call      @chgpg
     C                   parm                    $parms
520cAC                   endif
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
520cAC                   if        @prtpg <> 'NONE'
     C                   call      @prtpg
     C                   parm                    $parms
520cAC                   endif
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
     *R         CLERR     CABEQ'1'       PAG01E
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
     *R         CLERR     CABEQ'1'       PAG01E
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
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
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
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
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
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
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
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
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
     C                   dou       stop = '1'
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
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
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
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
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
     C                   dou       stop = '1'
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
     C                   if        top = '1'
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
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
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
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
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
     C                   if        recno < 11
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
     C                   write     dspsfl
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
     C                   write     dspsfc
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
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
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
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
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
     *  ZZAVG    Calculate Average for Multi transactions.
     *
     C     zzavg         begsr
     C                   eval      trncnt = 0
     C                   eval      ttlmin = 0
     C                   time                    fintim
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      findte = $cvd8o
     C     partky        setll     multran
     C                   dow       forevr = forevr
     C     partky        reade(n)  record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
417cA*
417cA*    Close any open(Inuse) Indirect tasks.
417cAC                   eval      trans# = mutrn#
710aAc                   eval      svwhse = muwhse
500bAC                   if        batch = *off
417cAC                   exsr      zzendi
500bAC                   endif
417cA*
640aD ***                add       mutrn#        cktrn#
     C                   add       1             trncnt
     C                   eval      zzsdte = musdte
     C                   eval      zzstim = mustim
     C                   eval      strtim = mustim
417bM*R                   EXSR ZZTIME
417bM*R                   ADD  TIMLEN    TTLMIN
     C                   iter
     C                   enddo
     *
417b C                   exsr      zztime
417b C                   add       timlen        ttlmin
     *
     C                   eval      zzedte = findte
     C                   eval      zzetim = fintim
417b C                   eval      svedte = findte
417b C                   eval      svetim = fintim
     *   Find overlapping task to adjust time.
417b C     mutrn#        chain(n)  pirtran                            77
     C                   eval      ptetim = fintim
     C                   eval      ptedte = findte
     C                   exsr      zzcku2
     *
     C                   if        trncnt <> 0
     C                   eval      ttlmin = ttlmin - svtlen
     C     ttlmin        div       trncnt        avgmin
     C                   endif
417b C                   eval      findte = svedte
417b C                   eval      fintim = svetim
     *
     C     partky        setll     multran
     C                   dow       forevr = forevr
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *  End transaction and update task detail.
     C                   eval      trans# = mutrn#
     *
417cA*    Close any open(Inuse) Indirect tasks.
500bAC                   if        batch = *off
417cAC                   exsr      zzendi
500bAC                   endif
417cA*
     C                   exsr      zzend
     C                   eval      mustat = '4'
     C                   eval      muedte = findte
     C                   eval      muetim = fintim
     C                   update    record
     C                   iter
     C                   enddo
417dAC                   if        batch = *off and
520aAC                             trncnt > 0
     C                   exsr      zzstrt
417dAC                   endif
     C     endavg        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task, caluclate adjust time,
     *           do not update task.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
417lMC     $kemp#        reade     pirtran2                               79
     **                   READ PIRTRAN2                 79
     C                   if        *in79  or
     C                             ptsdte < zzsdte
     C                   leave
     C                   endif
     *   Skip the multi transactions.
     C     pttrn#        chain     multran1                           76
     C                   if        not *in79  and
     C                             pttrn# = mutrn#
     C                   iter
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
     C                             ptetim <= zzetim
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
     C                             ptetim <= zzetim
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
     C                             ptstim >= zzstim
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     C                   enddo
     *
     C     endcu2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     C     endcm1        endsr
     *----------------------------------------------------------------
417aA*
417aA*  ZZEND    End task.
     *
     C     zzend         begsr
     *  End current task
     C     ptkey         chain     pirtran                            79
     C                   if        not *in79
     C                   eval      svwhse = ptwhse
     C                   eval      svwhdp = ptwhdp
     C                   eval      svstyp = ptstyp
     C                   eval      svshft = ptshft
     C                   eval      svcrew = ptcrew
417bD**                   MOVE '4'       PTSTAT
417b C                   eval      ptstat = '3'
     C                   eval      ptetyp = 'N'
     C                   eval      ptedte = findte
     C                   eval      ptetim = fintim
     C                   eval      ptdmin = avgmin
     C                   update    ptrec                                79
640cAc                   exsr      zzwrttrand
     C                   endif
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endend
     C                   endif
     *
     *            - End current task
     *            - Update TASKDET file.
     *            - Decrease active and increase finished.
     *
417b **                   MOVELPTTASK    T#TASK
520cACSR                 eval      wkwhdp = ptwhdp
520cAC*  Check for selection records
520cACSR                 IF        ptcat='SELECT'
520cAC                   eval      wdp = ptwhdp
520cAC                   eval      whs = ptwhse
520cAC     opkey         chain     optione
520cAC                   if        not %found(optione)
520cAC                   eval      wdp = *blanks
520cAC                   eval      whs = 0
520cAC     opkey         chain     optione
520cAC                   if        not %found(optione)
520cAC                   eval      opzord = ' '
520cAC                   endif
520cAC                   endif
520cAC                   IF        opzord= 'Z'
520cAC     LBKEY         CHAIN     LABEL90                            76
520cAC                   if        not *in76
520dAC                   if        lbucod <> 'TO'
520cAC     LBLBL#        CHAIN     worklbl                            77
520cAC                   if        not *in77
520cAC                   MOVEL     lwszon        wkwhdp
520cAC                   endif
520dAC                   endif
520cAC                   endif
520cAC                   endif
520cAC                   endif
     C     tdkey         chain     taskdet                            79
     C                   if        not *in79
     * decrease active cube
520eAC                   if        ptcube <= tdactc
     C                   sub       ptcube        tdactc
520eAC                   else
520eAC                   eval      tdactc = *zeros
520eAC                   endif
     * decrease active shipping weight
520eAC                   if        ptswgt <= tdactw
     C                   sub       ptswgt        tdactw
520eAC                   else
520eAC                   eval      tdactw = *zeros
520eAC                   endif
     * decrease active pieces
520eAC                   if        ptpcs <= tdactp
     C                   eval      tdactp = tdactp - ptpcs
520eAC                   else
520eAC                   eval      tdactp = *zeros
520eAC                   endif
     * decrease active qty1
520eAC                   if        ptqty1 <= tdact1
     C                   eval      tdact1 = tdact1 - ptqty1
520eAC                   else
520eAC                   eval      tdact1 = *zeros
520eAC                   endif
     * decrease active qty2
520eAC                   if        ptqty2 <= tdact2
     C                   eval      tdact2 = tdact2 - ptqty2
520eAC                   else
520eAC                   eval      tdact2 = *zeros
520eAC                   endif
     * decrease active qty3
520eAC                   if        ptqty3 <= tdact3
     C                   eval      tdact3 = tdact3 - ptqty3
520eAC                   else
520eAC                   eval      tdact3 = *zeros
520eAC                   endif
     * decrease active jobs
520eAC                   if        tdactj >= 1
     C                   eval      tdactj = tdactj - 1
520eAC                   else
520eAC                   eval      tdactj = *zeros
520eAC                   endif
     * increase finished cube
     C     tdfinc        add       ptcube        tdfinc
520bAC                   z-add     0             wfinw             9 0
520bAC     tdfinw        add       ptswgt        wfinw
520bAC                   if        wfinw < 99999
     C     tdfinw        add       ptswgt        tdfinw
520bAC                   endif
     C     tdfinp        add       ptpcs         tdfinp
     C     tdfin1        add       ptqty1        tdfin1
     C     tdfin2        add       ptqty2        tdfin2
     C     tdfin3        add       ptqty3        tdfin3
     C                   add       1             tdfinj
     C                   update    tdrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endend
     C                   endif
     C                   endif
     *
     *
     C     endend        endsr
417cA*
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZENDI  End current Indirect task.
417cA*
417cAC     zzendi        begsr
417cA*
417cA*    Send currect Direct transaction number to ensure that this
417cA*    transaction doesn't get closed by mistake.
417cAC                   eval      @ptrn# = trans#
417cA*
417cAC                   call      @adjtr
417cAC                   parm      '*CLOSEI '    @pcmd             8
417cAC                   parm                    #job
417cAC                   parm                    @ptrn#            7 0
417cAC                   parm      *blanks       @ptask            6
417cAC                   parm      muwhse        @pwhse            3 0
417cAC                   parm      *blanks       @pwhdp            5
417cAC                   parm      *blanks       @pstyp            1
417cAC                   parm      0             @pcube            9 3
417cAC                   parm      0             @pswgt            9 2
417cAC                   parm      0             @ppcs             5 0
417cAC                   parm      0             @paisl            5 0
417cAC                   parm      0             @pqty1            5 0
417cAC                   parm      0             @pqty2            5 0
417cAC                   parm      0             @pqty3            5 0
417cAC                   parm      '0'           @prte             5
417cAC                   parm      ' '           @ppo              9
417cAC                   parm      ' '           @pgrp1            1
417cAC                   parm      ' '           @pgrp2            1
417cAC                   parm      ' '           @prtn             8
417cAC                   parm      ' '           @pmsg             4
417cA*
417cAC                   endsr
417cA*
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
417  **                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
417  C     partky        reade     record                                 79
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
417  *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
417  C     partky        readpe    record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Start date
     *
     C                   if        musdte = 0
     C                   eval      w1sdte = 0
     C                   else
     C                   eval      $cvcmd = '*YMDMDY '
     C                   move      musdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1sdte = $cvd6o
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    muemp#
     C                   kfld                    mustat
     C                   kfld                    mutrn#
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    muemp#
     C                   kfld                    mustat
     C                   kfld                    mutrn#
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kemp#
     C                   kfld                    $kstat
     *
     *  Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    trans#
     *
     *  Define PIRTRAN key
     *
     C     ptkey2        klist
     C                   kfld                    $kemp#
     C                   kfld                    zzsdte
     *
     *  Define key for TASKDET file.
     *
     C     tdkey         klist
     C                   kfld                    pttask
     C                   kfld                    ptwhse
     C                   kfld                    wkwhdp            5
     C                   kfld                    ptstyp
     C*
520cAC*  Define full key for label file.
520cAC*
520cAC     LBKEY         KLIST
520cAC                   KFLD                    PTWHSE
520cAC                   KFLD                    PTTRN#
     *
     *  Define key for TASK file.
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     *  Define PASSTRAN key
     *
     C     pskey         klist
     C                   kfld                    ptemp#
     C                   kfld                    pttrn#
520bA*  Define full key for option file.
520bA*
520bAC     opkey         klist
520bAC                   kfld                    cod               8
520bAC                   kfld                    whs               3 0
520bAC                   kfld                    wdp               5
520bA*
520bAC                   movel     '*USER'       cod
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      forevr = *off
500bAC                   eval      batch = *off
417dA*
417dA*   If an '*' is sent in, just close and return.
500cA*   If an 'S' is sent in, just suspend and return.
417dA*   Otherwise, do it interactivly by displaying the screen.
417dA*
500cAC                   select
500cD**         $KSTAT    IFEQ '*'
500cMC                   when      $kstat = '*'
417dAC                   eval      batch = *on
417dAC                   eval      $kstat = *on
417dAC                   exsr      zzavg
417dAC                   eval      nxtscr = 'EOJ'
417dAC                   eval      $rtncd = '*EXIT   '
500cAC                   when      $kstat = 'S'
500cAC                   eval      batch = *on
500cAC                   eval      $kstat = *on
500cAC                   exsr      zzsus
500cAC                   eval      nxtscr = 'EOJ'
500cAC                   eval      $rtncd = '*EXIT   '
500cD**                   ELSE
500cMC                   other
417dAC                   open      te130fm
640bA*
640bAC                   if        not %open(workopt)
640bAC                   open      workopt
640bAC                   endif
640bA*
417dAC                   eval      recno = 1
417dAC                   write     dspsfl                               79
417dDC                   exsr      zmimsg
     C                   exsr      clrsch
     C                   exsr      scr01i
500cD**                   ENDIF
500cMC                   endsl
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp1 <> *blanks
     C                   move      ptinp1        muemp#
     C                   eval      ptinp1 = *blanks
     C                   eval      repos = *on
     C                   endif
     *
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
417  *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
417  C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
417a *  ZZSTRT  Start a new task.
     *
     C     zzstrt        begsr
710aA
710aA /free
710aA   if svwhse = 0;
710aA     leavesr;
710aA   endif;
710aA /end-free
     *
     *  Enter key -
     *
     *  Task code entered (Only manual tasks are allowed)
     *  Create IDLE task.
     *
     *            - Start new task
     *            - Create a new transaction record.
     *
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
     C                   eval      ptwhse = svwhse
     C                   eval      ptwhdp = svwhdp
     C                   eval      ptstyp = svstyp
     C                   when      tktlvl = 'D'
     C                   eval      ptwhse = svwhse
     C                   eval      ptwhdp = svwhdp
     C                   eval      ptstyp = *blanks
     C                   other
     C                   eval      ptwhse = svwhse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   endsl
     C                   eval      ptshft = svshft
     C                   eval      ptcrew = svcrew
     C                   eval      ptemp# = $kemp#
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
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     C                   write     ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endstr
     C                   endif
640cAc                   exsr      zzwrttrand
     *
     *            - Start new task
     *            - Update TASKDET file.
     *            - Decrease pending and increase active.
     *
520cAC                   eval      wkwhdp=PTWHDP
520cAC*  Check for selection records
520cAC                   IF        ptcat='SELECT'
520cAC     LBKEY         CHAIN     LABEL90                            76
520cAC                   if        not *in76
520cAC     LBLBL#        CHAIN     worklbl                            77
520cAC                   if        not *in77
520cAC                   MOVEL     LWSZON        wkwhdp
520cAC                   endif
520cAC                   endif
520cAC                   endif
     C     tdkey         chain     taskdet                            79
     C                   if        not *in79
    D**         TKTYPE    IFEQ 'D'
     C     tdpndc        sub       ptcube        tdpndc
     C     tdpndw        sub       ptswgt        tdpndw
     C                   eval      tdpndp = tdpndp - ptpcs
     C                   eval      tdpnd1 = tdpnd1 - ptqty1
     C                   eval      tdpnd2 = tdpnd2 - ptqty2
     C                   eval      tdpnd3 = tdpnd3 - ptqty3
     C                   eval      tdpndj = tdpndj - 1
    AC                   if        tdpndc < 0
    AC                   eval      tdpndc = 0
    AC                   endif
    AC                   if        tdpndw < 0
    AC                   eval      tdpndw = 0
    AC                   endif
    AC                   if        tdpndp < 0
    AC                   eval      tdpndp = 0
    AC                   endif
    AC                   if        tdpnd1 < 0
    AC                   eval      tdpnd1 = 0
    AC                   endif
    AC                   if        tdpnd2 < 0
    AC                   eval      tdpnd2 = 0
    AC                   endif
    AC                   if        tdpnd3 < 0
    AC                   eval      tdpnd3 = 0
    AC                   endif
     C                   if        tdpndj < 0
     C                   eval      tdpndj = 0
     C                   endif
     C     tdactc        add       ptcube        tdactc
     C     tdactw        add       ptswgt        tdactw
     C     tdactp        add       ptpcs         tdactp
     C     tdact1        add       ptqty1        tdact1
     C     tdact2        add       ptqty2        tdact2
     C     tdact3        add       ptqty3        tdact3
     C                   add       1             tdactj
     C                   update    tdrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endstr
     C                   endif
     C                   endif
     *
     *
417a C     endstr        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZSUS    Suspend transaction(s)
500cA*
500cAC     zzsus         begsr
     *
     *   Suspend transaction and delete MULTRAN record.
     *
     C     partky        setll     multran
     C                   dow       forevr = forevr
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      trans# = mutrn#
     C                   exsr      zzsus2
     C                   delete    record
     C                   iter
     C                   enddo
     *
     C     endsus        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZSUS2   Suspend single transaction
500cA*
500cAC     zzsus2        begsr
     *  End current task
     C     ptkey         chain     pirtran                            79
     C                   if        not *in79
     C                   eval      ptstat = '8'
     *  Check for exsiting pass records
520cAC                   z-add     ptstim        strtim
520cAC                   time                    fintim
520cAC                   eval      $cvcmd = '*CURCMD '
520cAC                   call      @cvtdt
520cAC                   parm                    $cvtdt
520cAC                   eval      findte = $cvd8o
520cAC                   exsr      zztime
520bAC*  Check for selection records
520bAC                   IF        ptcat='SELECT'
520bAC                   eval      wdp = ptwhdp
520bAC                   eval      whs = ptwhse
520bAC     opkey         chain     optione
520bAC                   if        not %found(optione)
520bAC                   eval      wdp = *blanks
520bAC                   eval      whs = 0
520bAC     opkey         chain     optione
520aAC                   if        not %found(optione)
520bAC                   eval      opzord = ' '
520bAC                   endif
520bAC                   endif
520bAC                   IF        optbd = 'Y'
520cAC     pskey         chain     passtran                           78
520cAC                   if        not *in78 and pasedte=0
520fAC                   z-add     passtim       strtim
520fAC                   exsr      zztime
520cAC                   eval      pasedte = findte
520cAC                   eval      pasetim = fintim
520cAC                   eval      pasdmin = timlen
520cAC                   update    pasrec
520cAC                   else
     *  Move data to PASSTRAN to capture end time on suspend
520cAC                   eval      pastrn# = pttrn#
520cAC                   eval      paswhse = ptwhse
520cAC                   eval      passhft = ptshft
520cAC                   eval      pasemp# = ptemp#
520cAC                   eval      pascrew = ptcrew
520cAC                   eval      paspcs  = ptpcs
520cAC                   eval      passdte = ptsdte
520cAC                   eval      passtim = ptstim
520cAC                   eval      pasedte = findte
520cAC                   eval      pasetim = fintim
520cAC                   eval      pasetyp = ptetyp
520cAC                   eval      pasdmin = timlen
520cAC                   write     pasrec
520cAC                   endif
520cAC                   endif
520cAC                   endif
520cAC                   if        ptedte = 0 and ptetim = 0
520cAC                   eval      ptedte = findte
520cAC                   eval      ptetim = fintim
     C                   endif
     C                   update    ptrec                                79
640cAc                   exsr      zzwrttrand
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Calculate time.
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F12=Cancel  F21=End transactions
