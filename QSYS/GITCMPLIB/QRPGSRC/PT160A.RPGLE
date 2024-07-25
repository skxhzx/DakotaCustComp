     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT160A    Close open customer return trans - Display
     *  09 November 1994
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/12/96  DAS  2.10
     *      - Took out PIRUSER file and corresponding code and replaced
     *        with call to GETWHSE.
     *
     *    02/29/96  DAS  2.10
     *      - Revised to work with transaction task code instead of
     *        type code.
     *
213 A*    05/24/96  DAS
     *      - Replaced LABEL8 file with PIRTRAN3 file.
     *      - Made more generic to handle all types of returns.
     *
412 A*    09/10/96  HNK
     *      - Trans Generated date and time added.
415aA*    02/07/01  RH
     *      - Change to not display IDLE transactions.
415bA*    04/20/01  RH
     *      - Revised to include records with stat='3'.
415cA*    04/20/01  RH    4.15c   (same as PT170A 414b)
     *      - Revised program to check status of let down transactions
     *        before allowing options 2 or 9 to proceed.
     *      - Revised the following routines: ENT02, ENT03, OPTNS2,
     *        SAVOPT, ZZINZ, ZZOPT.
     *      - Added new routine ZZCKST to check let down status.
     *      - Added new error msg routine: ZM9907.
     *      - Added status to screen.
     *
416 A*    10/16/01  MLB  4.16
     *      - Revised program so that manual receiving transaction
     *        returns an error.  Cannot close.
416aA*    10/19/01  MLB  4.16a
     *      - Revised ZZGTN, ZZGTP to leave routine when end of file
     *        has been reached.
416bA*    10/18/01  RH
     *      - FIX -  ZZFGTN was in endless loop if no records found.
416cA*    01/18/02  MLB  4.16c
     *      - Revised ZZFGTN to include file indicator in status
     *        check.
416dA*    10/22/02  RH   4.16d
     *      - Revised to display department.
     *
417 A*    04/30/04  MLB  4.17
     *      - Fix: Revised 4.16 mod to allow open return transactions
     *        to be viewed but not closed if manual putaway.
417aA*    04/30/04  MLB  4.17a
     *      - Fix: Revised program to run ZZMAN routine before allowing
     *        2=Change option on open returns.
510aA*    12/06/06  RH   5.10a
     *      - Enh: Remove BFCADR, no longer used.
     *
600aA*    06/10/09  DAS  6.00a   P#00045
     *      - Renamed format to PT160A01
     *      - Added license to subfile
     *      - Added 71=Lcns hist and 75=Lcns info
     *
640 A*    10/09/12  MLB  6.40
     *      - Enh: Removed opt# 2=Change and Close,9=Quick close from pgm
     *      - Removed entries from ZOPT, OPTLN arrays.
     *        All returns must be completed thru RC200.
650aA*    12/18/13  RH   6.50a
     *      - Enh: Replace Description with Customer order #
     *        Rename format to PT160A02
     *
720aA*    01/10/18  NLK  7.10a
     *      - Enh: Allow Option 2 to Change and Close Open Tran
     *        Watch for DISP RTNDOCK exists and if DISP
     *        having RTNDOCK should not allow or
     *        move over the qty to PickSlot
     *      - ZOPT & OPTLN arrays Option 2 was added, Cheney only
     *      - User Authority was added in OPTNS2
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    This is not a normall 110a type program.  Instead of option
     *    4 we are using option 9 with a command of *CLOSE. Also
     *    field $PTYPE was added to $PARMS.
     *
415cA*    * Important * Make sure that any new options added to this pro-
415cA*                  gram that allow changes to the let downs in any
415cA*                  way are preceeded with a call to subroutine
415cA*                  ZZCKST to verify that the transactions are still
415cA*                  at 'open' status.
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
600aD*T160AFMCF  E                    WORKSTN
650aD*T160A01CF  E                    WORKSTN
650aMFpt160a02  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
213 D*ABEL8  IF  E           K        DISK
213 D*           L8REC                             KRENAMERECORD
416 AFLabel90   if   e           k disk
213 MFpirtran3  if   e           k disk
     F                                     rename(ptrec:record)
213 AFpirtran   if   e           k disk
     F                                     rename(ptrec:recordu)
210 D*IRUSER IF  E           K        DISK
600aAFLicense1  if   e           k disk
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
720aD*OPTLN           S             75 ** DIM(1) CTDATA PERRCD(1)
720aMD optln           s             75    dim(2) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
210eD*                   TCOD    1   9  2   TDSC   30
210eMD tcod            s              6    dim(10) ctdata perrcd(1)
210eMD tdsc            s             30    dim(10) alt(tcod)
     D hed             s             50    dim(3) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
213 D*                                       1  50 DSUKEY
213 D*I            0                         1   30L8WHSE
213 D*                                       4   8 L8RTE
213 D*                                       9  17 L8PO
213 D*I            0                        18  240L8TRN#
213 MD  ptwhse                 1      3  0 inz(0)
213 MD  ptgrp1                 4      4
213 MD  ptgrp2                 5      5
213 MD  ptrtpo                 6     14
213 MD  pttrn#                15     21  0 inz(0)
213 AD                 ds
213 AD  dsukey                 1     50
213 AD  ukwhse                 1      3  0 inz(0)
213 AD  ukrte                  4      8
213 AD  ukpo                   9     17
213 AD  uktrn#                18     24  0 inz(0)
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
     *
720aA*----------------------------------------------------------------
720aA* Error message(s)
720aAD err01           c                   const('You are not authorized -
720aAD                                     to use this option.')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @chgpg          c                   const('PT132')
     D @delpg          c                   const('PT132')
     D @prtpg          c                   const('*NONE')
     D @cvtdt          c                   const('CVTDTE')
720aAD @getcl          c                   const('GETCLIENT')
720aAD @autpg          c                   const('CHKLIST')
     *----------------------------------------------------------------
     *
412 AD $cvtdt          ds
412 AD  $cvcmd                 1      8
412 AD  $cvprg                 9     18
412 AD  $cvd6i                19     24
412 AD  $cvd8i                25     32
412 AD  $cvd6o                33     38  0
412 AD  $cvd8o                39     46  0
412 AD  $cvsto                47     64
412 AD  $cvrtn                65     72
412 AD  $cverm                73    132
412 AD  $cvmsg                73     76
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
     D  $ptype                81     88
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
415cA*
415cAD  eropt                  1     20
415cAD  erstat                21     40
415cAD  ertype                41     50
     *
720aAD  errit1                 1     15
720aAD  errtyp                16     16
720aAD  errit2                17     31
     D                 ds
     D  $ec                    1      2p 0
415cA*
     *----------------------------------------------------------------
     *  Variables
     *
     D typdsc          c                   const('Return   ')
     D #oitem          s             15
     D #otype          s              1
720aAD #sitem          s             15
720aAD pgmopt          s             20
720a *----------------------------------------------------------------
720a *  Customer id
720a *----------------------------------------------------------------
720a  /copy qcopysrc,id#cheney
720a
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
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
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $ktrn#          s                   like(pttrn#)
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D kygrp1          s                   like(ptgrp1)
     D kygrp2          s                   like(ptgrp2)
     D kyrtpo          s                   like(ptrtpo)
     D kytrn#          s                   like(pttrn#)
     D kywhse          s                   like(ptwhse)
     D lsttrn          s              7  0
     D manerr          s              1
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D stserr          s              1
     D t               s              2  0
     D top             s              1
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
213 A*      $RTYPE  *NORMAL  - Customer return.
213 A*              *TRANSFR - Transfer returns.
213 A*              *POS     - POS returns.
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
213 AC                   parm                    $rtype            8
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
     *     USERCODE
     *
     C     uskey         klist
     C                   kfld                    #user
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
510a *                    CALL 'BFCADR'
510a *                    PARM           $RTN    8
510a *          $RTN      IFEQ '*EXPIRED'
510a *                    MOVE 'EOJ'     NXTSCR
510a *                    MOVE '*EXIT   '$RTNCD
510a *                    ELSE
     C                   exsr      zzinz2
510aD*                    END
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
     C                   exsr      zmimsg
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
     C                   if        recno < 11
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
     C                   if        wkoopt = ' 9'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*CLOSE  '
     C                   eval      $puky = wkokyu
415cA*
415cA*    Verify that let down is still at "open" status.
415cA*
415cAC                   eval      dsukey = $puky
415cAC                   exsr      zzckst
415cAC                   if        stserr = *on
415cAC                   delete    wkorec
415cAC                   iter
415cAC                   endif
415cA*
416 A*    Verify that transaction is not a manual putaway tran.
416 A*
416 AC                   eval      dsukey = $puky
416 AC                   exsr      zzman
416 AC                   if        manerr = *on
416 AC                   delete    wkorec
416 AC                   iter
416 AC                   endif
416 A*
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
415cA*
415cA*    If ERROR flag is on due to one or more let downs no
415cA*    longer at 'open' status, set on CANCEL.
415cA*
415cAC                   if        error = *on
415cAC                   eval      cancel = error
415cAC                   endif
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
213 D*                    MOVE *BLANKS   $POFKY
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
213 D*                    MOVE *BLANKS   $POFKY
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
213 D*                    MOVE *BLANKS   $POFKY
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
     C                   eval      $ptype = '*INTER  '
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO all quick closes first (Option 9)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 9'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 9'
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
720aAC                   select
     *
     *   Change
     *
720aMC                   when      wkoopt = ' 2'
720aA*     Check if user is authorized to use this option.
720aAC                   if        client = cheney
720aAC                   call      @autpg
720aAC                   parm                    #prog
720aAC                   parm      '2'           pgmopt
720aAC                   parm                    #user
720aAC                   parm                    $rtncd
720aAC                   if        $rtncd = '*NO'
720aAC                   eval      error = '1'
720aAC                   eval      errmsg = err01
720aAC                   exsr      zm0105
720aAC                   endif
720aAC                   endif
720aAC                   if        error <> '1'
720aAC                   if        #otype = 'A'  or
720aAC                             #otype = 'C'
720aAC                   eval      error = *on
720aAC                   eval      *in21 = *on
720aAC                   eval      errmsg = *blanks
720aAC                   exsr      zm1301
720aAC                   else
720aAC                   eval      $pcmd = '*CHANGE '
720aAC                   call      @chgpg
720aAC                   parm                    $parms
720aAC                   endif
720aAC                   endif

720aAC                   if        $prtn <> '*EXIT'
720aAC                             and $prtn <> '*CANCEL'
415cA*
415cA*    Verify that let down is still at "open" status.
415cA*
415cAC                   eval      *in21 = *off
415cAC                   eval      dsukey = $puky
415cAC                   exsr      zzckst
415cAC                   if        stserr = *on
415cAC                   goto      opts2e
415cAC                   endif
415cA*
417aAC                   exsr      zzman
417aAC                   if        manerr = *on
417aAC                   goto      opts2e
417aAC                   endif
417aA*
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
720aAC                   endif


     *   View
     *
720aMC                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms

     *
     *   Print
     *
720aMC                   when      wkoopt = ' 6'

416 A*    Verify that transaction is not a manual putaway tran.
720aA*       IF more than just viewing (Opt 5, 71, 75)
416 A*
416 AC                   eval      dsukey = $puky
416 AC                   exsr      zzman
416 AC                   if        manerr = *on
416 AC                   goto      opts2e
416 AC                   endif

     C                   eval      $pcmd = '*PRINT  '
     **              ** CALL      @PRTPG
     **              ** PARM                    $PARMS

720aAC                   other
     C                   exsr      zzopt
720aAC                   endsl

     *
415cAC     opts2e        tag
415cA*
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
     C                   else
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
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
     C     dsplyd        add       10            goback
     C                   if        bot = *on
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
     *
     C                   if        wkoopt = ' 9'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
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
     C     dsplyd        add       10            goback
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
     C                   if        wkoopt = ' 9'
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
     C                   dou       nomore = *on
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
415cA*
415cA*    Verify that let down is still at "open" status.
415cA*
415cAC                   select
415cAC                   when      option = ' 2'  or
415cAC                             option = ' 9'
415cAC                   eval      dsukey = ukey(y)
415cAC                   exsr      zzckst
415cAC                   endsl
415cA*
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
720a *----------------------------------------------------------------
720a *      1301  Can't adjust item type.
720a *
720aAC     zm1301        begsr
720aAC                   eval      #msgid = 'IT13001'
720aAC                   eval      #msgtp = '*DIAG  '
720aAC                   eval      errmsg = *blanks
720aAC                   eval      errit1 = #oitem
720aAC                   eval      errtyp = #otype
720aAC                   eval      errit2 = #sitem
720aAC                   movea     errmsg        $md(1)
720aAC                   exsr      zmpmsg
720aAC                   endsr
416 A*----------------------------------------------------------------
416 A*   PT13033  Cannot close manual putaway trans.
416 A*
416 AC     zm3033        begsr
416 AC                   eval      #msgid = 'PT13033'
416 AC                   eval      #msgtp = '*DIAG  '
416 AC                   movea     errmsg        $md(1)
416 AC                   exsr      zmpmsg
416 AC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
415cA*----------------------------------------------------------------
415cA*   PIR9907  &1 no longer at status of &2.
415cA*
415cAC     zm9907        begsr
415cAC                   eval      #msgid = 'PIR9907'
415cAC                   eval      #msgtp = '*DIAG  '
415cAC                   movea     errmsg        $md(1)
415cAC                   exsr      zmpmsg
415cAC                   endsr
415cA*----------------------------------------------------------------
415cA*
415cA*  ZZCKST   Check status of let down before proceeding.
415cA*
415cAC     zzckst        begsr
415cA*
415cAC                   eval      stserr = *off
415cAC                   eval      $ktrn# = uktrn#
415cA*
415cAC     ckstky        chain     pirtran                            79
415cA*
415cA*    If *IN79 - off - Return is no longer at correct status.
415cA*    Halt user from proceeding.
415cA*
415cAC                   select
415cAC                   when      *in79  or
415cAC                             not *in79  and
415cAC                             ptstat <> '1'
415cAC                   eval      stserr = *on
415cAC                   eval      error = *on
415cAC                   eval      *in21 = *on
415cAC                   movel(p)  uktrn#        eropt
415cAC                   eval      erstat = 'Open    '
415cAC                   eval      ertype = typdsc
415cAC                   exsr      zm9907
415cAC                   endsl
415cA*
415cAC                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZMAN    Manual transaction cannot be closed.
416 A*
416 AC     zzman         begsr
416 A*
416 AC                   eval      manerr = *off
416 A*
416 AC     lbkey         setll     label90
416 AC     lbkey         reade     label90                                79
416 A*
416 AC                   if        not *in79  and
720aA*  until OLD are cleaned up, remove *MANUAL
720aAC                             lbdsp2 = '*MANUAL '
416 AC                   eval      manerr = *on
416 AC                   eval      error = *on
416 AC                   exsr      zm3033
416 AC                   endif
416 A*
416 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
     C                   if        row# = 4  and
     C                             col# >= 38
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *  Test for F9 - Display all warehouses
     *
     C                   if        *inki
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*F9     '
     C                   goto      endcm1
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *          FILUKY    CHAINRECORD               79
     *                    Z-ADD0         LSTTRN
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
416aAC                   if        *in79
416aAC                   goto      endgtn
416aAC                   endif
415aAC                   if        not *in79
416bMC                   if        pttask = 'IDLE'
416bD**         PTTASK    ANDEQ'IDLE'
415aAC                   goto      try1
415aAC                   endif
     *    Only display open and ended transactions.
415bAC                   if        ptstat <> '1'  and
415bAC                             ptstat <> '3'  and
416cAC                             not *in79
415bAC                   goto      try1
415bAC                   endif
416bAC                   endif
     *
213 D*          *IN79     IFEQ *OFF
213 D*          L8TRN#    IFEQ LSTTRN
213 D*          P8TASK    ORNE 'PUTRTN'
210eD*          P8TYPE    ORNE 'RN'
213 D*                    GOTO TRY1
213 D*                    ENDIF
213 D*                    ENDIF
213 D*                    Z-ADDL8TRN#    LSTTRN
     *
416aAC     endgtn        tag
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
     C     partky        readpe    record                                 79
416aAC                   if        *in79
416aAC                   goto      endgtp
416aAC                   endif
415aAC                   if        not *in79  and
415aAC                             pttask = 'IDLE'
415aAC                   goto      try2
415aAC                   endif
415bAC                   if        not *in79  and
415bAC                             ptstat <> '1'  and
415bAC                             ptstat <> '3'
415bAC                   goto      try2
415bAC                   endif
     *
213 D*          *IN79     IFEQ *OFF
213 D*          L8TRN#    IFEQ LSTTRN
213 D*          P8TASK    ORNE 'PUTRTN'
210eD*          P8TYPE    ORNE 'RN'
213 D*                    GOTO TRY2
213 D*                    ENDIF
213 D*                    ENDIF
213 D*                    Z-ADDL8TRN#    LSTTRN
     *
416aAC     endgtp        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     C                   eval      t = 1
210eD*          P8TYPE    LOKUPTCOD,T                   50
213 MC     pttask        lookup    tcod(t)                                50
     C                   if        t = 0
415cD*R                   MOVE TDSC,1    W1TYPE
415CMC                   movel     tdsc(1)       w1type
     C                   else
415cD*R                   MOVE TDSC,T    W1TYPE
415cMC                   movel     tdsc(t)       w1type
     C                   endif
650aA*
650aA*  Get Customer order #
650aAC     lbkey         setll     label90
650aAC     lbkey         reade     label90                                79
650aA*
650AAC                   eval      w1type = *blanks
650aAC                   if        not *in79
650aMC                   movel     lbord         w1type
650aMC                   endif
650aA*
416dAC                   eval      w1dept = ptwhdp
415cAC                   eval      w1stat = *blanks
415cAC                   if        ptstat = '1'
415cAC                   eval      w1stat = 'OPEN '
415cAC                   endif
415cAC                   if        ptstat = '3'
415cAC                   eval      w1stat = 'ENDED'
415cAC                   endif
412 AC                   eval      $cvcmd = '*CMDMDY '
412 AC                   move      ptgdte        $cvd8i
412 AC                   call      @cvtdt
412 AC                   parm                    $cvtdt
412 AC                   eval      w1gdte = $cvd6o
412 AC                   eval      w1gtim = ptgtim
600aA*
600aA*  Get license #
600aAC     likey         chain     license1                           79
600aAC                   if        *in79
600aAC                   eval      w1lcns = *blanks
600aAC                   else
600aAC                   eval      w1lcns = lilcns
600aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
720a *
720a *  Get client id.
720a *
720aAC                   call      @getcl
720aAC                   parm                    client           10
     *
     *
415cAC                   eval      stserr = *off
416 AC                   eval      manerr = *off
213 D*          *LIKE     DEFN L8RTE     KYRTE
213 D*          *LIKE     DEFN L8PO      KYPO
213 D*                    MOVE *BLANKS   KYRTE
213 D*                    MOVE *BLANKS   KYPO
213 AC                   eval      kyrtpo = *blanks
     *
     *  Define unique file key.
     *
213 D*          FILUKY    KLIST
213 D*                    KFLD           L8WHSE
213 D*                    KFLD           KYRTE
213 D*                    KFLD           KYPO
213 D*                    KFLD           L8TRN#
213 MC     filuky        klist
213 MC                   kfld                    uktrn#
     *
     *  Define full key for main file.
     *
213 D*          FILEKY    KLIST
213 D*                    KFLD           L8WHSE
213 D*                    KFLD           KYRTE
213 D*                    KFLD           KYPO
213 D*                    KFLD           L8TRN#
213 MC     fileky        klist
213 MC                   kfld                    ptwhse
213 MC                   kfld                    ptgrp1
213 MC                   kfld                    ptgrp2
213 MC                   kfld                    ptrtpo
213 MC                   kfld                    pttrn#
415cA*
414cA*    Define full key for main file to check let down status.
415cA*
415cAC     ckstky        klist
415cAC                   kfld                    $ktrn#
     *
     *  Define partial key for main file (if needed).
     *
213 D*          PARTKY    KLIST
213 D*                    KFLD           L8WHSE
213 D*                    KFLD           KYRTE
213 D*                    KFLD           KYPO
213 MC     partky        klist
213 MC                   kfld                    kywhse
213 MC                   kfld                    kygrp1
213 MC                   kfld                    kygrp2
213 MC                   kfld                    kyrtpo
     *
213 D*          PARTK2    KLIST
213 D*                    KFLD           L8WHSE
213 MC     partk2        klist
213 MC                   kfld                    kywhse
416 AC     lbkey         klist
416 AC                   kfld                    ukwhse
416 AC                   kfld                    uktrn#
600aA*
600aA*    Define key for license file.
600aA*
600aAC     likey         klist
600aAC                   kfld                    ukwhse
600aAC                   kfld                    uktrn#
     *
     *  Setup option and command display lines.
     *
720aAC                   if        client = cheney
720aAC                   eval      optln1 = optln(2)
720aAC                   else
     C                   eval      optln1 = optln(1)
720aAC                   endif
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
     *   Open closing program.
     *
     C                   eval      $pcmd = '*OPEN   '
     C                   eval      $puky = dsukey
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   Get warehouse for user.
     *
210 D*R         USKEY     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *OFF
210 D*R                   Z-ADDUSWHSE    L8WHSE
210 D*R                   ELSE
210 D*R                   Z-ADD1         L8WHSE
210 D*R                   ENDIF
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
213 MC     ptwhse        parm      0             #whse             3 0
213 D*          L8WHSE    PARM 0         #WHSE   30
213 AC                   eval      kywhse = ptwhse
210 A*
     *
     *   Verify warehouse and get description.
     *
213 D*                    Z-ADDL8WHSE    WHCODE
213 D*                    MOVE *BLANKS   WHDESC
213 MC                   eval      wowhse = *blanks
     C                   eval      $lcmd = '*VERIFY '
213 D*                    Z-ADDL8WHSE    $LWHSE
213 MC                   eval      $lwhse = ptwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
213 AC                   eval      wowhse = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
213 D*                    Z-ADDL8WHSE    WHCODE
213 D*                    MOVEL$LERM     WHDESC
213 AC                   eval      $fwhse = ptwhse
213 AC                   movel     $lerm         $fdesc
213 AC                   call      'FRMTWH'
213 AC                   parm                    $fwhse            3 0
213 AC                   parm                    $fdesc           30
213 AC                   parm                    wowhse
     C                   endif
213 A*
213 A*   Initialize headings and return type.
213 A*
213 AC                   select
213 AC                   when      $rtype = '*NORMAL '
213 AC                   eval      ptgrp1 = 'R'
213 AC                   eval      kygrp1 = 'R'
213 AC                   eval      ptgrp2 = ' '
213 AC                   eval      kygrp2 = ' '
213 AC     'PT160A.'     cat       '01':0        w1scrn
213 AC                   eval      wohead = hed(1)
213 AC                   when      $rtype = '*TRANSFR'
213 AC                   eval      ptgrp1 = 'R'
213 AC                   eval      kygrp1 = 'R'
213 AC                   eval      ptgrp2 = 'T'
213 AC                   eval      kygrp2 = 'T'
213 AC     'PT165A.'     cat       '01':0        w1scrn
213 AC                   eval      wohead = hed(2)
213 AC                   when      $rtype = '*POS    '
213 AC                   eval      ptgrp1 = 'R'
213 AC                   eval      kygrp1 = 'R'
213 AC                   eval      ptgrp2 = 'P'
213 AC                   eval      kygrp2 = 'P'
213 AC     'PT167A.'     cat       '01':0        w1scrn
213 AC                   eval      wohead = hed(3)
213 AC                   endsl
213 A*
213 A*   Center screen heading.
213 A*
213 AC                   eval      $cstr = *blanks
213 AC                   call      'CENTER'
213 AC                   parm      wohead        $cstr            60
213 AC                   parm      50            $clen             3 0
213 AC                   movel     $cstr         wohead
213 A*
213 A*   Display first screen.
213 A*
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   eval      lsttrn = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
213 A*----------------------------------------------------------------
213 A*
213 A*  ZZKEYI   Initialize keys for files being used.
213 A*           Note: You must clear individual field when using
213 A*                 partial keys or one of the fields is numeric.
213 A*
213 AC     zzkeyi        begsr
213 A*
213 A*   Initialize file key (DSFKEY)
213 A*
213 AC                   clear                   ptwhse
213 AC                   clear                   ptgrp1
213 AC                   clear                   ptgrp2
213 AC                   clear                   ptrtpo
213 AC                   clear                   pttrn#
213 A*
213 A*   Initialize unique key (DSUKEY)
213 A*
213 AC                   clear                   ukwhse
213 AC                   clear                   ukrte
213 AC                   clear                   ukpo
213 AC                   clear                   uktrn#
213 A*
213 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
213 AC                   eval      ukwhse = ptwhse
213 AC                   eval      ukrte = *blanks
213 AC                   eval      ukpo = *blanks
213 AC                   eval      uktrn# = pttrn#
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
600aA*
600aA*   71 - View license history
600aA*
600aAC                   if        wkoopt = '71'
600aAC                   eval      dsukey = $puky
600aaC                   call      'LT320'
600aAC                   parm      '*VIEW   '    $lpcmd            8
600aAC                   parm      ptwhse        $lwhs2            3 0
600aAC                   parm      ' '           $lwhdp            5
600aAC                   parm      ' '           $ldisp           12
600aAC                   parm      ' '           $litem           15
600aAC                   parm      w1lcns        $lplic           15
600aAC                   parm      0             $lemp#            5 0
600aAC                   parm      ' '           $ldev            10
600aAC                   parm      ' '           $lform           10
600aAC                   endif
600aA*
600aA*   75 - View license info
600aA*
600aAC                   if        wkoopt = '75'
600aAC                   eval      dsukey = $puky
600aaC                   call      'LP130'
600aAC                   parm      '*NOOPT  '    $lpcmd
600aAC                   parm      w1lcns        $lplic
600aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *      Verify warehouse entry.
     *
     C                   if        ptinp1 <> 0
213 D*                    Z-ADDPTINP1    WHCODE
213 D*                    MOVE *BLANKS   WHDESC
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
213 AC                   eval      wowhse = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
213 D*                    Z-ADDPTINP1    L8WHSE
213 MC                   eval      ptwhse = ptinp1
213 AC                   eval      kywhse = ptinp1
213 AC                   eval      ptgrp1 = kygrp1
213 AC                   eval      ptgrp2 = kygrp2
213 AC                   eval      ptrtpo = kyrtpo
213 D*                    Z-ADD0         L8TRN#
213 MC                   eval      pttrn# = 0
213 D*                    Z-ADDPTINP1    WHCODE
213 D*                    MOVEL$LERM     WHDESC
213 AC                   eval      $fwhse = ptwhse
213 AC                   movel     $lerm         $fdesc
213 AC                   call      'FRMTWH'
213 AC                   parm                    $fwhse
213 AC                   parm                    $fdesc
213 AC                   parm                    wowhse
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   eval      lsttrn = 0
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to transaction number.
     *
     C                   if        ptinp2 <> 0
213 AC                   eval      ptwhse = kywhse
213 AC                   eval      ptgrp1 = kygrp1
213 AC                   eval      ptgrp2 = kygrp2
213 AC                   eval      ptrtpo = kyrtpo
213 D*                    Z-ADDPTINP2    L8TRN#
213 AC                   eval      pttrn# = ptinp2
     C                   eval      ptinp2 = 0
     C                   eval      repos = *on
     C                   eval      lsttrn = 0
     C                   endif
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
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   eval      lsttrn = 0
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   eval      lsttrn = 0
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 57175
**  OPTLN - Option display line
                  5=View  71=Lcns hist  75=Lcns info
  2=Change/Close  5=View  71=Lcns hist  75=Lcns info
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F12=Cancel
**
      * Not on File *
BULKF Bulk Pick - Full Pallet
BULKP Bulk Pick - Partial Pallet
BULKR Bulk Pick with Replenishment
FIXED Floor Pick
PIR   PIR Pick
PUTEMPReceiving
PUTMOVReceiving
PUTRTNCustomer Return
REPL  Replenishment
**  HED
Close Open Customer Return Transactions
Close Open Transfer Return Transactions
Close Open POS Return Transactions
