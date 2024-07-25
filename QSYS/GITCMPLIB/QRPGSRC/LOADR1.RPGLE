650cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  LOADR1  Loader Module - Route Status Summary
     *  May 24, 2006
     *  Jose Duque
     *
     *  Revisions:
     *
520 A*    07/14/08  RBD  5.20    P#00060
     *      - Enh: Added client custom code support to program.
     *
530 A*    11/12/09  RBD  5.30
     *      - Recompiled only, w1flag field size increased.
     *                                                             list
530aA*    02/10/10  RBD  5.30a
     *      - Recompiled only, fixed 'position to' text in dds.
530bA*    07/08/10  RH   5.30b
     *      - Fix: Display dock door assigned in truck builder.
     *
530cA*    07/16/10  RBD  5.30c
     *      - Fix: Use new key which includes route id for LDRDETL
     *        when closing route.  Before, all detail recs were
     *        being deleted for the route, not just that route id.
     *
640 A*    02/17/11  JGD  6.40
     *      - Enh: Change the starting reading statement of
     *      - Enh: "Ldrhdr" file to be able to read and process
     *      - Enh: a file holding different wharehouse numbers.
     *
640 A*    03/21/11  JGD  6.40
     *      Add 'LDRTRLE' file. Delete the corresponding record
     *      from this file every time a LDRTEQ record is deleted.
640bA*    06/19/12  RH   6.40b
     *      - Enh: Remove opt 3=TrlrEq, disabled trailer equip for
     *        all clients, will change to table driven in future.
     *
650aA*    04/05/13  RBD  6.50a
     *      - VIP is now using new pgm LOADR9V to scan multiple
     *        pallets before scanning Trailer Id.  When they do this,
     *        multiple pallets will have the same start and end times.
     *        When a route is closed the logic for updating LDRHDETL,
     *        the loader detail history file, was to chain to LDRHDETL
     *        using start date and time from LDRDETL, if it got a hit
     *        the history was updated, if not, it was added. In cases
     *        where there are multiple pallets with the same start
     *        date and time, only one of them was getting written to
     *        LDRHDETL. There are no circumstances I can think of
     *        where an LDRHDETL rec should be updated, they should
     *        always be added, so I'm removing the update, which will
     *        allow VIP's pallets with the same start date and times
     *        to be written to the history file.
     *
650bA*    01/17/14  RBD  6.50b
     *      - Enh: Added display of trailer number.
     *      - Renamed LOADR1FM to LOADR101.
     *
650cA*    09/17/14  RBD  6.50c
     *      - Converted to ILE.
     *      - Renamed LOADR101 to LOADR102.
     *      - When a trailer is assigned, look for parent or child routes
     *        (add-ons) that are associated with this route and update
     *        their trailer in loader header too. Keep in mind that only
     *        routes which are at printed status or higher will exist
     *        in the loader header file.
     *      - Added F9=Add-ons to call Merged Routes Maintenance.
     *
650dA*    01/20/15  RBD  6.50d
     *      - Recompiled, LDRDETL and LDRHDETL files changed.
     *
700aA*    01/22/16  RBD  7.00a
     *      - Fix: 640b rev was bypassing edits for flags and unloaded
     *        pallets though it was only meant to skip trailer eq check.
     *        Reinstated those edits.
     *
700bA*    02/09/16  RBD  7.00b
     *      - When closing a route to Loader that's part of an add-on/merge
     *        route require that all pallets for all associated routes be
     *        loaded also before closing, then update all routes with close
     *        date, time, etc so user doesn't have to do so individually.
     *
720aA*    04/23/18  RBD  7.20a
     *      - When route is closed to Loader update any associated runner
     *        records that are at status 'S' to status 'C'. Do this for the
     *        route plus its parent or children if any.
     *      - Added status 'S' to w1flag logic.
     *
740aA*    12/21/20  RBD  7.40a
     *      - Fix: Rev 720a didn't update runner file.
     *
750aA*    05/06/21  RBD  7.50a
     *      - Enh: Added CLIENTLOC parm to @GETCL pgm call.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI A*    07/14/08  RBD  CBI     P#00060
     *      - Coded #user exceptions logic as specific to Cheney.
     *
CBIaA*    07/14/08  RBD  CBIa    P#00060
     *      - Coded HACCP logic as specific to Cheney.
     *
CBIbA*    05/06/21  RBD  CBIb
     *      - Revised Cheney HACCP logic per Keith:
     *          - Disregard loader status.
     *          - Only check door numbers when whse Riviera.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    11/04/08  RBD  CLD
     *      - Disable trailer equipment requirements.  For the time
     *        being, City Line does not want to enter or track any
     *        trailer equipment.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JORaA*    09/21/10  RH   JORa
     *      - Disable trailer equipment requirements.  Add to
     *        City Line mod to not enter or track any
     *        trailer equipment.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
     *
RYLaA*    07/07/10  RH   RYLa
     *      - Disable trailer equipment requirements.  Add to
     *        City Line mod to not enter or track any
     *        trailer equipment.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view separately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650bD*LOADR1FMCF  E                    WORKSTN
650cDF*Loadr101  cf   e             workstn
650cMFLoadr102  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
     FLabel13   if   e           k disk
720aDF*runner6   if   e           k disk
720aMFrunner6   uf   e           k disk
     Fpiruser   if   e           k disk
     Fpiruser1  if   e           k disk
     F                                     rename(usrec:usrec1)
     Fordh1     if   e           k disk
     Frtehed    if   e           k disk
     Fpltsum1   if   e           k disk
     Fpirtran   if   e           k disk
     FLdrteq    uf   e           k disk
     FLdrhcom2  if   e           k disk
530bAFdocmtrx2  if   e           k disk
     Fworkopt   uf a e           k disk
     FLdrhdr    uf a e           k disk
     F                                     rename(lhrec:record)
650cAFLdrhdr3   uf   e           k disk    rename(lhrec:lhrec3) prefix(L_)
     FLdrhhdr   uf a e           k disk
     FLdrdetl   uf   e           k disk
650aD*LDRHDETLUF  E           K        DISK                      A
650aMFLdrhdetl  o  a e           k disk
     Fru376b    uf a e           k disk
640 AFLdrtrle1  uf   e           k disk
     FLdrexcp   o    e           k disk
650cAFttmerg    if   e           k disk
700bAFttmerg1   if   e           k disk
650cAFttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
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
     D optln           s             75    dim(2) ctdata perrcd(1)
700bDD*cmdln           s             79    dim(6) ctdata perrcd(1)
700bMD cmdln           s             79    dim(4) ctdata perrcd(1)
     D desc            s             60    dim(13) ctdata perrcd(1)
     *----------------------------------------------------------------
520 A*  Client ID's
     *
CBI A /COPY QCOPYSRC,Id#CHENEY
CLD A /COPY QCOPYSRC,Id#CITYLIN
RYLaA /COPY QCOPYSRC,Id#ROYAL
JORaA /COPY QCOPYSRC,Id#JORDANO
CBIbA /COPY QCOPYSRC,Id#CHENEYR
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  whcode                 1      3  0
     D  lhrte                  4      8
     D  lhrtid                 9     13
     D  lhstrd                14     21  0 inz(0)
     D  lhstrt                22     27  0 inz(0)
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @flags          c                   const('LOADFLCL')
     D @close          c                   const('LOADCLCL')
     D @chgpg          c                   const('*NONE')
     D @delpg          c                   const('*NONE')
     D @prtpg          c                   const('*NONE')
650cAD @addons         c                   const('TR870CL')
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
     D  $pdky                 19     68
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     D  $pwhse                19     21  0 inz(0)
     D  $prte                 22     26
     D  $prtid                27     31
     D  $pstrd                32     39  0
     D  $pstrt                40     45  0
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
     D  $ltruk                22     31
     D  $lrtid                22     26
     D  $ltrk2                32     41
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
     D                 ds
     D  hldtim                 1      6
     D  hh                     1      2
     D  mm                     3      4
     D  ss                     5      6
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
     *
     D                 ds
     D  dsmisc                 1     20
     D  dssdte                 1      8
     D  dsspcl                 9     11
     D  dsrpck                12     12
     D  dsdoor                13     14
     D  dsmeat                15     15
     D  dscode                16     16
     D  dsrvs                 19     19
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
     *----------------------------------------------------------------
     *  Variables
     *
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
     D curtim          s              6  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
650cAD getOut          s              1
     D goback          s              2  0
     D haccp           s              2
     D help            s              5  0
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D numemp          s              5  0
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D prvrti          s              5
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svstrd          s              8  0
     D tdiff           s              6  0
     D timein          s              6
     D top             s              1
650cAD updParent       s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
700bAd ParentChild     s              1
700bAd Sc1ParentRtid   s                   like(ttmpri)
700bAd Sc1ParentRte    s                   like(ttmprt)
700bAd w1rtid          s                   like(ttmpri)
700bAd kyrte1          s                   like(ttmpri)
700bAd kyrtid1         s                   like(ttmpri)
700bAd savlhstat       s                   like(lhstat)
700bAd savlhsup#       s                   like(lhsup#)
700bAd savlhclsd       s                   like(lhclsd)
700bAd savlhclst       s                   like(lhclst)
700bAd sav$prte        s                   like($prte)
700bAd sav$prtid       s                   like($prtid)
700bAd sav$pstrd       s                   like($pstrd)
700bAd sav$pstrt       s                   like($pstrt)
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
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
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
     C                   setoff                                       202123
     C                   setoff                                       33
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
     C                   when      view = 1
     C                   read      dspsfc                                 50
     C                   when      view = 2
     C                   read      vw2sfc                                 50
     C                   when      view = 3
     C                   read      vw3sfc                                 50
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
520 A*  Get Client ID
     *
520 AC                   call      @getcl
520 AC                   parm                    client           10
750aAC                   parm                    clientloc        10
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
     C                   write     vw2sfl                               79
     C                   write     vw3sfl                               79
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
     *     TEST FOR CMD5 - REFRESH SCREEN FROM THE TOP
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C     x             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw2sfl
     C                   endif
     C     x             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw3sfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     *
     *  Setting 'FKEY' to *LOVAL forces screen to be refreshed
     *  from the top as opposed to just the screen being displayed.
     *  This is the type of screen refresh needed by this appl.
     C                   move      *loval        fkey
     C                   exsr      pag01
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
     *  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inku
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
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD10 - Previous view
     *
     C                   if        *inkj
     C                   if        view = 1
     C                   eval      view = maxvw
     C                   else
     C                   eval      view = view - 1
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     C                   goto      cmd01e
     C                   endif
     *
650cA*  TEST FOR CMD09 - Link to 'Merged Routes Maintenance'.
650cA*
650cAC                   if        *inki
650cAC                   call      @addons
650cAC                   endif
     *
     *  TEST FOR CMD11 - Link to 'Closed Route Status Summary' scrn.
     *
     C                   if        *inkk
     C                   call      @close
     C                   endif
     *
     *  TEST FOR CMD13 - Link to 'Flags by Route Status Summary' scrn.
     *
     C                   if        *inkm
     C                   call      @flags
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
     C                   exsr      clrsch
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
     C                   write     vw2sfl
     C                   write     vw3sfl
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
     C                   eval      *in81 = *on
     C                   eval      *in82 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
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
     C                   exsr      zzupdt
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
     *>         FILEKY    SETGTRECORD
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
     C                   eval      $puky = wkokyu
     *
     *-----------------------------> <--------------------------------
     *  Verify if user has update authorization.
     *
     C                   call      'CHKLIST'
     C                   parm                    #prog
     C                   parm      ' '           @popt            20
     C                   parm                    #user
     C                   parm      ' '           @prtn             8
     *
     *  Not authorized to delete route
     *
     C                   if        @prtn = '*NO'
     *
CBI AC                   if        client = cheney  and
CBI AC                             #user <> 'JOSED'  and
CBI AC                             #user <> 'JOSED2'  and
CBI AC                             #user <> 'MARKE'  and
CBI AC                             #user <> 'KEITHS'  and
CBI AC                             #user <> 'TAML'  and
CBI AC                             #user <> 'RAYS'  and
CBI AC                             #user <> 'SYV'  and
CBI AC                             #user <> 'SYVO'
CBI AC                   eval      cancel = *on
CBI AC                   eval      error = *on
CBI AC                   movel     desc(12)      errmsg
CBI AC                   exsr      zm0105
CBI AC                   endif
     *
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
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   goto      optnse
     C                   endif
     *----------------------------------------------------------------
     *
     C                   eval      otaken = *on
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED.
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12.
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
     C                   eval      $pdky = wkokyu
     *
     *   Check if user wants to link to Pallet Loading screen
     *
     C                   if        wkoopt = '12'
     C     keyrs         chain(n)  record                             79
     C                   if        not *in79
     C                   if        lhstat = '5'
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   movel     desc(9)       errmsg
     C                   exsr      zm0105
     C                   goto      endns2
     C                   endif
     C                   endif
     *
     C                   eval      $door# = w1door
     C                   call      'LOADR3'
     C                   parm                    $pdky
     C                   parm                    $rtncd            8
     C                   parm                    $door#            3
     *
     C                   eval      lhstrd = svstrd
     C                   else
     C                   exsr      zzopt
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
     C     endns2        endsr
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
     *  REFRESH SCREEN FROM THE TOP
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
     *  READ SPECIFIED FLITCHES FILE
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
     C                   select
     C                   when      view = 1
     C                   readc     dspsfl                                 79
     C                   when      view = 2
     C                   readc     vw2sfl                                 79
     C                   when      view = 3
     C                   readc     vw3sfl                                 79
     C                   endsl
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
     C                   select
     C                   when      view = 1
     C                   z-add     recno         y
     C                   when      view = 2
     C                   z-add     recno         y
     C                   when      view = 3
     C                   z-add     recno         y
     C                   endsl
     *
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
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   z-add     reccnt        y
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
     C                   write     vw2sfl
     C                   write     vw3sfl
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
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
     C                   write     vw2sfc
     C                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
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
     C                   select
     C                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     *
CBIaA*   Client specific HACCP processing
     *
CBIaAC                   if        client = cheney
CBIaAC**CBIbD            if        w1stat = 'Started'
CBIaAC                   exsr      zzgdif
CBIaAC                   if        haccp = 'YR'
CBIaAC                   setoff                                       31
CBIaAC                   endif
CBIaAC**CBIbD            endif
CBIaAC                   endif
     *
     C                   update    dspsfl
     C                   setoff                                       3132
     C                   endif
     C                   when      view = 2
     C     1             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    vw2sfl
     C                   endif
     C                   when      view = 3
     C     1             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    vw3sfl
     C                   endif
     C                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = posrec
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
     C                   if        *in03 <> '1'  and
     C                             error <> '1'
     C                   eval      *in02 = *on
     C                   write     postnrec
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
     C                   select
     C                   when      view = 1
     C     x             chain     dspsfl                             79
     C                   when      view = 2
     C     x             chain     vw2sfl                             79
     C                   when      view = 3
     C     x             chain     vw3sfl                             79
     C                   endsl
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
     *
     C                   select
     C                   when      view = 1
     *
CBIbDC**                 if        w1stat = 'Started'
     *
CBIaA*  Client specific HACCP processing :
CBIaA*  Check pallets belonging to Depts which items are
CBIaA*  under HACCP guide lines (see ZZGDIF Rtn).
     *
CBIaAC                   if        client = cheney
CBIaAC                   exsr      zzgdif
CBIaAC                   if        haccp = 'YR'
CBIaAC                   setoff                                       31
CBIaAC                   endif
CBIaAC**CBIbD            endif
     *
     C                   else
     C                   setoff                                       3132
     C                   endif
     *
     C                   update    dspsfl
     C                   when      view = 2
     C                   update    vw2sfl
     C                   when      view = 3
     C                   update    vw3sfl
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *      0105  Display a message defined at the end of pgm
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
650cA*
650cA*  ZZADDONS  Update trailer for add-on routes.
650cA*
650cAC     zzAddOns      begsr

650cAC                   eval      updParent = *off
650cAC                   eval      getOut = *off
650cAC     rtkey         chain     ttmerg2
650cAC                   if        %found
650cAC                   eval      TTrtid = ttmpri
650cAC                   eval      updParent = *on
650cAC                   else
650cAC                   eval      TTrtid = lhrtid
650cAC                   endif
650cAC     TTkey         setll     ttmerg
650cAC                   dow       forevr = forevr
650cAC     TTkey         reade     ttmerg
650cAC                   if        %eof
650cAC                             or getOut = *on
650cAC                   leave
650cAC                   endif

650cAC                   eval      l_lhrtid3 = ttmcri
650cAC     updParentHdr  tag
650cAC     lhkey3        chain     ldrhdr3
650cAC                   if        %found

650cAC                   eval      l_lhtrlr = lhtrlr
650cAC                   eval      l_lhstat = '2'

650cA*  Move route starting loading date and time into Ldrhdr file.

700bDC**                 move      '*CURCMD '    $cvcmd
700bDC**                 call      @cvtdt
700bDC**                 parm                    $cvtdt
700bDC**                 eval      l_lhstrd = $cvd8o
700bMC                   eval      l_lhstrd = lhstrd
700bDC**                 time                    l_lhstrt
700bMC                   eval      l_lhstrt = lhstrt

650cA*  Get loader emp#

650cAC     #user         chain     piruser
650cAC                   if        %found
650cAC                   eval      l_lhemp# = usemp#
650cAC                   endif

650cAC                   update    lhrec3
650cAC                   endif
650cAC                   enddo

650cAC                   if        updParent = *on
650cAC                   eval      updParent = *off
650cAC                   eval      getOut = *on
650cAC                   eval      l_lhrtid3 = ttmpri
650cAC                   goto      updParentHdr
650cAC                   endif

650cAC                   endsr
     *----------------------------------------------------------------
700bA*
700bA*  ZZCHKMRG  Check for add-ons.
700bA*
700bAC     zzChkMrg      begsr
700bA
     *  Check to see if the route selected is part of a merge
     *
     C                   eval      ParentChild = *blanks
     C                   eval      ttrtid = lhrtid
     C     ttkey         chain     ttmerg
     C                   if        %found(ttmerg)
     C                   eval      ParentChild = 'P'
     C                   eval      Sc1ParentRtid = ttmpri
     C                   eval      Sc1ParentRte  = ttmprt
     C                   else
     C     ttkey         chain     ttmerg2
     C                   if        %found(ttmerg2)
     C                   eval      ParentChild = 'C'
     C                   eval      Sc1ParentRtid = ttmpri
     C                   eval      Sc1ParentRte  = ttmprt
     C                   endif
     C                   endif

     C                   endsr
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
     C                             col# >= 48
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
     *
     *  Test for F8 - Truck detail
     *
     C                   if        *inkh
     C                   eval      $pcmd = '*CHANGE '
     C                   call      'TM110A'
     C                   parm                    $prtky
     C                   parm                    $rtncd
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDOOR   Get loading door number.
     *
     *----------------------------------------------------------------
     C     zzdoor        begsr
     *
     C                   eval      dsdoor = *blanks
     C                   eval      $door# = *blanks
     C     rtkey         chain     rtehed                             78
     C                   if        not *in78
530bAC                   select
CBI AC                   when      client = cheney
     *
     C     ohkey         setll     ordh1
     C     ohkey         reade     ordh1                                  78
     C                   if        not *in78
     C                   eval      dsmisc = ohmisc
     C                   movel     dsdoor        $door#
     C                   endif
530bAC                   other
530bAC     dckey         setll     docmtrx2
530bAC     dckey         reade     docmtrx2                               78
530bAC                   if        not *in78
530bAC                   movel     dmdoor        $door#
530bAC                   move      dmdoor        dsdoor
530bAC                   endif
530bAC                   endsl
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Create an exception record as part of the
     *           'Unloading Trailer', Change Trailer, Change Loader.
     *
     *----------------------------------------------------------------
     C     zzexcp        begsr
     *
     C                   clear                   lerec
     C                   eval      lewhse = lhwhse
     C                   eval      lertid = lhrtid
     C                   eval      lerte = lhrte
     C                   eval      letrlr = lhtrlr
     C                   eval      lestrd = lhstrd
     C                   eval      lestrt = lhstrt
     C                   eval      leemp# = lhemp#
     C                   eval      leendd = lhendd
     C                   eval      leendt = lhendt
     C                   eval      lesdte = $cvd8o
     C                   time                    lestim
     C                   eval      lestat = lhstat
     C                   eval      lecom1 = $pcom1
     C                   eval      lecom2 = $pcom2
     C                   eval      lereas = $prcde
     C                   write     lerec
     *
     *
     C     endupr        endsr
     *----------------------------------------------------------------
     *  ZZFGET   Get record with unique key.
     *----------------------------------------------------------------
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain(n)  record                             79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade(n)  record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe(n) record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Status description
     *
     C                   eval      w1stat = *blanks
     C                   eval      w2sup = *blanks
     C                   eval      option = *blanks
     *
     C                   select
     *
     *   Route loading status
     *
     C                   when      lhstat = '1'
     C                   movel     'Open   '     w1stat
     *
     C                   when      lhstat = '2'
     C                   movel     'Started'     w1stat
     *
     C                   when      lhstat = '3'
     C                   movel     'Ended  '     w1stat
     *
     C                   when      lhstat = '4'  or
     C                             lhstat = '5'
     C                   if        lhstat = '4'
     C                   movel     'Closed '     w1stat
     C                   else
     C                   eval      w1stat = 'Unloaded'
     C                   endif
     C     lhsup#        chain     piruser1                           78
     C                   if        not *in78
     C                   eval      w2sup = uscode
     C                   else
     C                   movel     'NOTFND'      w2sup
     C                   endif
     *
     C                   endsl
     *
     *   Route/Truck start load date
     *
     C                   if        lhstrd = 0
     C                   eval      w1strd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      lhstrd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1strd = $cvd6o
     C                   eval      w2strd = $cvd6o
     C                   endif
     *
650bAC                   movel     lhstrt        w1strt
     *
     *   Route/Truck end load date
     *
     C                   if        lhendd = 0
     C                   eval      w2endd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      lhendd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2endd = $cvd6o
     C                   endif
     *
     *   Route/Truck close load date
     *
     C                   if        lhclsd = 0
     C                   eval      w1clsd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      lhclsd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1clsd = $cvd6o
     C                   endif
     *
650bAC                   movel     lhclst        w1clst
     *
     *   Check for route flags, keep count to display later.
     *   It starts reading the detail file instead of the
     *   header file to make sure all route IDs have been
     *   processed (in the case of Breakers).
     *
     C                   eval      w1flag = *zeros
     *
     C                   eval      prvrti = *blanks
     C     ldrhky        setll     ldrdetl
     C     ldrhky        reade(n)  lddrec                                 79
     C                   dow       not *in79
     *
     C                   if        ldrtid = prvrti
     C                   goto      readtl
     C                   endif
     *
     *   Get labels # within this Route Id to chain Runner6 below
     C     ldrdky        setll     label13
     C     ldrdky        reade     label13                                78
     C                   dow       not *in78
     *
     *----------------------------------------------------------------
     *   The logic below looks thru the runner file to find active
     *   flags including out's.
     *
     C     runrky        setll     runner6
     C     runrky        reade     runner6                                77
     C                   dow       not *in77
     C                   if        rustat <> 'C'  and
720aMC                             rustat <> 'D'  and
720aAC                             rustat <> 'S'
     C                   add       1             w1flag
     C                   endif
     C     runrky        reade     runner6                                77
     C                   enddo
720aAC                   unlock    runner6
     *----------------------------------------------------------------
     C     ldrdky        reade     label13                                78
     C                   enddo
     *
     C                   eval      prvrti = ldrtid
     *
     C     readtl        tag
     C     ldrhky        reade(n)  lddrec                                 79
     C                   enddo
     *
     C                   if        w1flag > *zeros
     C                   seton                                        23
     C                   endif
     *
     *   Get loading time
     *
     C                   eval      w2lodt = *zeros
     *
     C                   if        lhendd <> *zeros  and
     C                             lhendt <> *zeros
     C                   move      lhstrt        $stime
     C                   move      lhendt        $etime
     *
     C                   call      'GETDIFF'
     C                   parm                    $stime            6
     C                   parm                    $etime            6
     C                   parm                    $diff             6
     *
     C                   move      $diff         w2lodt
     C                   endif
     *
     *  Get loading door number
     *
     C                   eval      w1door = *blanks
     C                   eval      lhdor# = *blanks
     C                   exsr      zzdoor
530bAC                   select
CBI AC                   when      client = cheney
     C                   movel     dsdoor        w1door
     C                   movel     dsdoor        lhdor#
530bAC                   other
530b C                   eval      w1door = $door#
530b C                   eval      lhdor# = $door#
530bAC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGDIF     Get difference between the time a CLR, FRZ or
     *             PRD pallet was ended to display warning msgs
     *             in the event the time diff found is over the
     *             HACCP guide lines.
     *----------------------------------------------------------------
     C     zzgdif        begsr
     *
     *  This routine compares pallet ended time
     *  against current time, if the difference >= 30
     *  minutes and <= 44 minutes, the dept id will be
     *  displayed in yellow. If the difference is 45
     *  minutes or greater the dept then will be displayed
     *  in red.
     *
     *
     C                   eval      timein = *blanks
     C                   eval      haccp = *blanks
     C                   setoff                                       3132
     *
     C     rtkey         setll     pltsum1
     C     rtkey         reade     pltsum1                                79
     *
     C                   dow       not *in79
     C                   if        pstzon = 'CLR'  or
     C                             pstzon = 'FRZ'  or
     C                             pstzon = 'PRD'
     *
     C                   if        pspzon <> *blanks
     C                   goto      read
     C                   endif
     *
CBIbAC                   if        clientloc = CheneyRiviera
     C                   if        w1door <> *blanks  and
     C                             w1door >= '23'  and
     C                             w1door <= '28'
     C                   goto      read
     C                   endif
CBIbAC                   endif
     *
     C     pstrn#        chain     pirtran                            78
     C                   if        not *in78  and
     C                             ptstat = '3'
     C                   move      ptetim        timein
     C                   endif
     C                   endif
     *
     C                   if        timein = *blanks
     C                   goto      read
     C                   endif
     *
     *
     C                   eval      hh = %subst(timein:1:2)
     C                   eval      mm = %subst(timein:3:2)
     C                   eval      ss = %subst(timein:5:2)
     C                   eval      $tstim = hldtim
     *
     C                   time                    curtim
     C                   move      curtim        timein
     *
     C                   eval      hh = %subst(timein:1:2)
     C                   eval      mm = %subst(timein:3:2)
     C                   eval      ss = %subst(timein:5:2)
     C                   eval      $tetim = hldtim
     *
     C                   call      'GETDIFF'
     C                   parm                    $tstim            6
     C                   parm                    $tetim            6
     C                   parm                    $tdiff            6
     *
     C                   move      $tdiff        tdiff
     *
     C                   if        tdiff >= 3000  and
     C                             tdiff <= 4400
     C                   seton                                        31
     C                   if        haccp = *blank
     C                   move      'Y'           haccp
     C                   endif
     C                   if        haccp = ' R'
     C                   eval      haccp = 'YR'
     C                   endif
     C                   endif
     *
     C                   if        tdiff >= 4400
     C                   seton                                        32
     C                   if        haccp = *blank
     C                   move      'R'           haccp
     C                   endif
     C                   if        haccp = ' Y'
     C                   eval      haccp = 'YR'
     C                   endif
     C                   endif
     *
     C     read          tag
     C                   eval      timein = *blanks
     C     rtkey         reade     pltsum1                                79
     C                   enddo
     *
     C                   if        not *in33
     C                   if        *in31  or
     C                             *in32
     C                   seton                                        33
     C                   endif
     C                   endif
     *
     C     endiff        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    lhwhse
     C                   kfld                    lhrte
     C                   kfld                    lhrtid
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    lhwhse
     C                   kfld                    lhrte
     C                   kfld                    lhrtid
     C                   kfld                    lhstrd
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     *
     *  Define partial key for file LDRHDR.
     *  Key used in ZZFILL Rtn.
     *
     C     keyrs         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    $prtid
     C                   kfld                    $pstrd
     C                   kfld                    $pstrt
     *
     C     keyrs2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     *
530cAC     keyld         klist
530cAC                   kfld                    $pwhse
530cAC                   kfld                    $prte
530cAC                   kfld                    $prtid
     *
     C     ldrhky        klist
     C                   kfld                    lhwhse
     C                   kfld                    lhrte
     *
     C     ldrdky        klist
     C                   kfld                    lhwhse
     C                   kfld                    ldrtid
     *
     C     runrky        klist
     C                   kfld                    lhwhse
     C                   kfld                    lblbl#
     *
     C     dtlhky        klist
     C                   kfld                    ldwhse
     C                   kfld                    ldrte
     C                   kfld                    lhrtid
     C                   kfld                    ldstrd
     C                   kfld                    ldstrt
     *
     C     rtkey         klist
     C                   kfld                    lhwhse
     C                   kfld                    lhrtid
     *
     C     ohkey         klist
     C                   kfld                    rhpbat
     C                   kfld                    lhwhse
     C                   kfld                    lhrtid
530bA*
530bA*     Partial key to get dock door.
530bAC     dckey         klist
530bAC                   kfld                    lhwhse
530bAC                   kfld                    lhrtid
     *
650cA*  Trax add-on routes key.
650cAC     TTkey         klist
650cAC                   kfld                    lhwhse
650cAC                   kfld                    TTrtid            5
     *
700bA*  Trax add-on routes key.
700bAC     TTkey1        klist
700bAC                   kfld                    lhwhse
700bAC                   kfld                    ttmcri            5
     *
700bAC     ttmkey1       KLIST
700bAC                   KFLD                    $pwhse
700bAC                   KFLD                    kyrte1
700bAC                   KFLD                    kyrtid1
     *
650cA*  Loader header key.
650cAC     lhkey3        klist
650cAC                   kfld                    lhwhse
650cAC                   kfld                    l_lhrtid3         5
     *
     *  Setup option and command display lines.
     *
     C                   eval      view = 1
     C                   eval      maxvw = 2
     C                   eval      optln1 = optln(1)
     C                   eval      optln2 = optln(2)
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     C                   eval      dsfkey = $prtky
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     lhwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $pwhse = #whse
     C                   eval      whcode = lhwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = lhwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = lhwhse
     C                   eval      whcode = lhwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
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
     *  ZZHIST   Update Header and Detail history files
     *
     *----------------------------------------------------------------
     C     zzhist        begsr
     *
     C     keyrs         chain     lhhrec                             79
     *
     *                    Update Header History
     C                   eval      lhhwhs = lhwhse
     C                   eval      lhhrti = lhrtid
     C                   eval      lhhrte = lhrte
     C                   eval      lhhtrl = lhtrlr
     C                   eval      lhhstd = lhstrd
     C                   eval      lhhstt = lhstrt
     C                   eval      lhhemp = lhemp#
     C                   eval      lhhend = lhendd
     C                   eval      lhhent = lhendt
     C                   eval      lhhsta = lhstat
     C                   eval      lhhcld = lhclsd
     C                   eval      lhhclt = lhclst
     C                   eval      lhhsup = lhsup#
     *
     *  Move in door number
     *
     C                   eval      lhhdor = *blanks
     C                   eval      lhhdor = lhdor#
     *
     C                   if        not *in79
     C                   update    lhhrec                               76
     C                   else
     C                   write     lhhrec                               76
     C                   endif
     *
     *                    The file being updated below
     *                    is used by RU372CL/RU376B in
     *                    the creation of 'Route Loading
     *                    Analisys' report.
     *
     C     fileky        chain     ru376b                             78
     C                   if        *in78
     C                   eval      ruwhse = lhwhse
     C                   eval      rurte = lhrte
     C                   eval      rurtid = lhrtid
     C                   eval      rustrd = lhstrd
     C                   eval      rustrt = lhstrt
     C                   write     rurec2
     C                   endif
     *
     *
     *          Update Detail History
530cD**         KEYRS2    SETLLLDDREC
530cD**         KEYRS2    READELDDREC                   79
530cMC     keyld         setll     lddrec
530cMC     keyld         reade     lddrec                                 79
     C                   dow       not *in79
     *
650aD**         DTLHKY    CHAINLDHREC               78
     *
     *          Do not write detail record being processed
     *          to history detail when unloading trailer and
     *          that detail record was not loaded.
     *
     C                   if        wkoopt = ' 6'  and
     C                             ldendd = *zeros
     C                   goto      bypas1
     C                   endif
     *
     C                   eval      ldhwhs = ldwhse
     C                   eval      ldhrte = ldrte
     C                   eval      ldhpli = ldplid
     C                   eval      ldhtrk = ldtrkz
     C                   eval      ldhrti = ldrtid
     C                   eval      ldhlds = ldldsq
     C                   eval      ldhcub = ldcube
     C                   eval      ldhpcs = ldpcs
     C                   eval      ldhst1 = ldstp1
     C                   eval      ldhst2 = ldstp2
     C                   eval      ldhemp = ldemp#
     C                   eval      ldhstd = ldstrd
     C                   eval      ldhstt = ldstrt
     C                   eval      ldhend = ldendd
     C                   eval      ldhent = ldendt
     *
     *
650aD**         *IN78     IFEQ *OFF                       Updating
650aD**                   UPDATLDHREC                 77  detailHist
650aD**                   ELSE                            file:
     C                   write     ldhrec                               77
650aD**                   ENDIF
     *
     *
     C     bypas1        tag
     *
     *          If Unloading Trailer
     C                   if        wkoopt = ' 6'
     C                   eval      ldstrd = *zeros
     C                   eval      ldstrt = *zeros
     C                   eval      ldendd = *zeros
     C                   eval      ldendt = *zeros
     C                   eval      ldemp# = *zeros
     C                   update    lddrec
     C                   endif
     *
     C                   if        wkoopt <> ' 6'  and
     C                             not *in77
     C                   delete    lddrec
     C                   endif
     *
     *
530cD**         KEYRS2    READELDDREC                   79
530cMC     keyld         reade     lddrec                                 79
     C                   enddo
     *
     C                   if        wkoopt <> ' 6'  and
     C                             not *in76
     C                   delete    record
     C                   endif
     *
720aA*  When route is closed to Loader look for runner records with
720aA*  status 'S' and change them to status 'C'. By doing this in zzhist
720aA*  you will get the route, plus its parent or children if any.
720aA
720aA /free

720aA  setll ($pwhse: $prtid) label13;

720aA  dou forevr <> forevr;

720aA    reade ($pwhse: $prtid) label13;
720aA    if %eof(label13);
720aA      leave;
720aA    endif;

720aA    chain (lbwhse: lblbl#) runner6;

720aA    if %found(runner6) and rustat = 'S';
720aA      rustat = 'C';
740aA      update rurec;
720aA    endif;

720aA  enddo;

720aA  unlock runner6;

720aA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZOPT    Process non-standard options.
     *           Note: Error handling is done in routine OPTNS2.
     *
     *----------------------------------------------------------------
     C     zzopt         begsr
     *
     C                   eval      $ptlr# = *blanks
     C                   eval      $pemp# = *blanks
     C                   eval      $perm = *blanks
     C                   eval      $prtn = *blanks
     *
     *   Verify if user is trying to use a disabled entry (unloaded)
     *
     C     keyrs         chain     record                             79
     C                   if        not *in79
     *
     C                   if        lhstat = '5'  and
     C                             wkoopt <> ' 5'
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(9)
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   endif
     C                   endif
     *
     *
     C                   select
     *
     *   Route being closed by supervisor.
     *
     C                   when      wkoopt = ' 1'
     *
     *  Verify if user has update authorization.
     *
     C                   call      'CHKLIST'
     C                   parm                    #prog
     C                   parm      ' '           @popt
     C                   parm                    #user
     C                   parm      ' '           @prtn
     *
     C                   if        @prtn = '*NO'
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(10)
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   endif
     *
     C     keyrs         chain     record                             79
     C                   if        not *in79
     *
     C                   if        lhstat = '4'
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(3)
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   endif
     *
640b * Add code to force skip of equipment check for all clients
640bAC*** 700aD          goto      skpeq
700aDC**   fileky        chain     ldrteq                             79
     *
700bAC                   exsr      zzoptClose
     *
700bAC                   if        error = *on
700bAC                   goto      endopt
700bAC                   endif
     *
700bA* Check to see if this route is part of an add-on and if so,
700bA* edit the associated routes
700bAC                   exsr      zzChkMrg
700bAC                   if        ParentChild <> *blanks
700bAC                   if        Sc1ParentRtid <> lhrtid
700bAC                   eval      kyrte1 = Sc1ParentRte
700bAC                   eval      kyrtid1 = Sc1ParentRtid
700bAC     ttmkey1       setll     record
700bAC                   reade     record
700bAC                   if        not %eof
700bAC                   exsr      zzoptClose
700bAC                   if        error = *on
700bAC                   goto      endopt
700bAC                   endif
700bAC                   endif
700bAC                   endif
700bAC                   eval      ttrtid = Sc1ParentRtid
700bAC     TTkey         setll     ttmerg
700bAC                   dow       forevr = forevr
700bAC     TTkey         reade     ttmerg
700bAC                   if        %eof
700bAC                   leave
700bAC                   endif
700bAC                   if        ttmcri = $prtid
700bAC                   iter
700bAC                   endif
700bAC                   eval      kyrte1  = ttmcrt
700bAC                   eval      kyrtid1 = ttmcri
700bAC     ttmkey1       setll     record
700bAC                   reade     record
700bAC                   if        not %eof
700bAC                   exsr      zzoptClose
700bAC                   if        error = *on
700bAC                   goto      endopt
700bAC                   endif
700bAC                   endif
700bAC                   enddo
700bAC                   endif
     *
640b * Tag to skip equipment check for all clients
640bAC***700aD    skpeq         tag
     C                   eval      $prtn = '*OK     '
     C                   goto      update
     C                   endif
     *
     *   User wants to Change Loader/Trailer.
     *
     C                   when      wkoopt = ' 2'
     C     keyrs         chain     record                             79
     C                   if        not *in79
     C                   if        lhemp# = *zeros
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(2)
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   else
     C                   eval      $ptlr# = lhtrlr
     C                   move      lhemp#        $pemp#
     C                   eval      $paorc = 'C'
     C                   endif
     C                   endif
     *
     *   User wants to View a route Loader/Trailer info (Opt/5)
     *   or wants to load trailer/equipment screen info (Opt/3).
     *   or wants to load comments screen info          (Opt/16).
     *   or wants to view comments screen info          (Opt/17).
     *
     C                   when      wkoopt = ' 5'  or
640bD**         WKOOPT    OREQ ' 3'                       LoadTrlrEqui
     C                             wkoopt = '16'  or
     C                             wkoopt = '17'
     C     keyrs         chain(n)  record                             79
     C                   if        not *in79
     *
     * Set an error message if route has not been assigned to
     * to a loader.
     *
     C                   if        lhemp# = *zeros
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(2)
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     *
     C                   else
     *
     * Route has been assigned to a loader
     *
     C                   eval      $ptlr# = lhtrlr
     C                   move      lhemp#        $pemp#
     C                   eval      $paorc = ' '
     *
     * Set process for viewing if that is the case
     *
     C                   if        wkoopt = ' 5'  or
     C                             wkoopt = '17'
     C                   eval      $paorc = 'V'
     *
     * If View Comments, check if there is any comment for
     * this route. If not set an error message.
     *
     C                   if        wkoopt = '17'
     C     fileky        chain(n)  lchrec                             79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(13)
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   endif
     C                   endif
     *
     C                   endif
     C                   endif
     C                   endif
     *
     *   User wants to unload the trailer.
     *
     C                   when      wkoopt = ' 6'
     C     keyrs         chain(n)  record                             79
     C                   if        not *in79
     C                   if        lhemp# = *zeros
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm = desc(8)
     *
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   endif
     C                   eval      $ptlr# = lhtrlr
     C                   move      lhemp#        $pemp#
     C                   eval      $paorc = 'U'
     C                   endif
     *
     *   User wants to assign route to Loader/Trailer (1st time).
     *
     C                   when      wkoopt = ' 7'
     C     keyrs         chain(n)  record                             79
     C                   if        not *in79
     C                   if        lhemp# > *zeros
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   if        lhstat = '4'
     C                   eval      $perm = desc(5)
     C                   else
     C                   eval      $perm = desc(1)
     C                   endif
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endopt
     C                   else
     C                   eval      $paorc = 'A'
     C                   endif
     C                   endif
     *
     C                   endsl
     *
     *
     C                   eval      $pcom1 = *blanks
     C                   eval      $pcom1 = *blanks
     C                   eval      $prcde = *blanks
     C                   move      lhstrd        $strdt
     C                   move      lhstrt        $strti
     *
     C                   if        wkoopt = ' 3'
640b * Add code to disable equipment check for all clients
640bD*                    CALL 'LOADR12'                  Load trailer
640bD*                    PARM           LHWHSE           equip info
640bD*                    PARM           LHRTE
640bD*                    PARM           LHRTID
640bD*                    PARM           $STRDT  8
640bD*                    PARM           $STRTI  6
640bD*                    PARM           $PTLR#  8
640bD*                    PARM           $PEMP#  5
640bD*                    PARM           $PPRG
640bD*                    PARM           $PAORC  1
640bD*                    PARM           $PCOM1 35
640bD*                    PARM           $PCOM2 35
640bD*                    PARM           $PRCDE  2
640bD*                    PARM           $PRTN
640bD*                    GOTO ENDOPT
     C                   endif
     *
     C                   if        wkoopt = '16'  or
     C                             wkoopt = '17'
     C                   call      'LOADR17'
     C                   parm                    lhwhse
     C                   parm                    lhrte
     C                   parm                    lhrtid
     C                   parm                    $strdt            8
     C                   parm                    $strti            6
     C                   parm                    $ptlr#            8
     C                   parm                    $pemp#            5
     C                   parm                    $pprg
     C                   parm                    $paorc            1
     C                   parm                    $prcde            2
     C                   parm                    $prtn
     C                   goto      endopt
     C                   endif
     *
     C                   call      'LOADR2'
     C                   parm                    lhwhse
     C                   parm                    lhrte
     C                   parm                    lhrtid
     C                   parm                    $strdt
     C                   parm                    $strti
     C                   parm                    $ptlr#
     C                   parm                    $pemp#
     C                   parm                    $pprg
     C                   parm                    $paorc
     C                   parm                    $pcom1           35
     C                   parm                    $pcom2           35
     C                   parm                    $prcde
     C                   parm                    $prtn
     *
     C     update        tag
     *
     *   If no view mode, or closing route, update Loader
     *   files.
     *
     C                   if        $prtn = '*OK     '  and
     C                             $paorc <> 'V'
     C                   exsr      zzupdt
     C                   endif
     *
     C     endopt        endsr
700bA*----------------------------------------------------------------
700bA*  ZZOPTCLOSE  Before allowing a route to be closed to the Loader
700bA*              the route selected plus any add-ons must pass the
700bA*              following edits.  Some of this code was moved from
700bA*              subr ZZOPT into this routine for better readability
700bA*              now that this code has to be executed multiple times
700bA*              if the route being closed is part of an add-on.
700bA*
700bA*----------------------------------------------------------------
700bAC     zzoptClose    begsr
700bA*
     *   Get labels within this route id to chain Runner6 and count
     *   active flags including outs
     C                   eval      w1flag = *zeros
     C     rtkey         setll     label13
     C     rtkey         reade     label13                                78
     C                   dow       not *in78
     C     runrky        setll     runner6
     C     runrky        reade     runner6                                77
     C                   dow       not *in77
     C                   if        rustat <> 'C'  and
720aMC                             rustat <> 'D'  and
720aAC                             rustat <> 'S'
     C                   add       1             w1flag
     C                   endif
     C     runrky        reade     runner6                                77
     C                   enddo
720aAC                   unlock    runner6
     C     rtkey         reade     label13                                78
     C                   enddo
     C                   if        w1flag > *zeros
     C                   seton                                        23
     C                   endif
     *
     C                   if        lhstat <> '3'  or
     C                             w1flag > *zeros  or
     C                             *in79  and
CLD AC                             client <> cityln  and
RYLaAC                             client <> royal  and
JORaAC                             client <> jordanos
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   if        w1flag > *zeros
     C                   eval      $perm = desc(7)
     C                   endif
     C                   if        lhstat = '1'
     C                   eval      $perm = desc(6)
     C                   endif
     C                   if        lhstat = '2'
     C                   eval      $perm = desc(4)
     C                   endif
     C                   if        *in79  and
     C                             $perm = *blanks  and
CLD AC                             client <> cityln  and
RYLaAC                             client <> royal  and
JORaAC                             client <> jordanos
     C                   eval      $perm = desc(11)
     C                   endif
     C     recno         chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in21 = *on
     C                   update    dspsfl
     C                   write     dspsfc
     C                   endif
     C                   goto      endoptClose
     C                   endif
     *
     C     endoptClose   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      lhwhse = ptinp1
     C                   eval      $kwhse = lhwhse
     C                   eval      lhrte = *blanks
     C                   eval      lhrtid = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to code
     *
     C                   setoff                                       03
     C                   if        ptinp2 <> *blanks
     C                   eval      $prte = ptinp2
     C     keyrs2        chain(n)  record                             79
     C                   if        *in79
     C                   eval      lhstrd = 0
     C                   eval      lhstrt = 0
     C                   eval      lhrte = *blanks
     C                   eval      lhrtid = *blanks
     C                   else
     C                   eval      $pwhse = lhwhse
     C                   eval      $prte = lhrte
     C                   eval      $prtid = lhrtid
     C                   eval      $pstrd = lhstrd
     C                   eval      svstrd = lhstrd
     C                   endif
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     C                   seton                                        03
     C                   endif
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     *----------------------------------------------------------------
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
640 D*--->      *LOVAL    SETLLRECORD
640 MC     $kwhse        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     *hival        setgt     record
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDT   Update routine
     *
     *----------------------------------------------------------------
     C     zzupdt        begsr
     *
     C     keyrs         chain     record                             79
     C                   if        not *in79
     C                   movel     $pemp#        numemp
     *
     * Get current date in century format
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     *
     C                   select
     *
     *  Route being closed or deleted by supervisor.
     *
     C                   when      wkoopt = ' 1'  or
     C                             wkoopt = ' 4'
     *
     C                   if        wkoopt = ' 1'
     C                   eval      lhstat = '4'
     C                   else
     C                   eval      lhstat = '6'
     C                   endif
     *
     C                   eval      lhclsd = $cvd8o
     C                   time                    lhclst
     *
     C                   if        lhstrd = *zeros
     C                   eval      lhstrd = $cvd8o
     C                   time                    lhstrt
     C                   endif
     *
     C     #user         chain     piruser                            78
     C                   if        not *in78
     C                   eval      lhsup# = usemp#
     C                   else
     C                   eval      lhsup# = *zeros
     C                   endif
     C                   exsr      zzhist
     *
700bA*  If closing an add-on route run zzhist for all associated routes
700bAC                   if        wkoopt = ' 1' and
700bAC                             ParentChild <> *blanks
700bAC                   eval      sav$prte  = $prte
700bAC                   eval      sav$prtid = $prtid
700bAC                   eval      sav$pstrd = $pstrd
700bAC                   eval      sav$pstrt = $pstrt
700bAC                   eval      savlhstat = lhstat
700bAC                   eval      savlhsup# = lhsup#
700bAC                   eval      savlhclsd = lhclsd
700bAC                   eval      savlhclst = lhclst
     *
700bAC                   if        Sc1ParentRtid <> sav$prtid
700bAC                   eval      kyrte1 = Sc1ParentRte
700bAC                   eval      kyrtid1 = Sc1ParentRtid
700bAC     ttmkey1       setll     record
700bAC                   reade     record
700bAC                   if        not %eof
700bAC                   eval      ttrtid = Sc1ParentRtid
700bAC     ttkey         chain(n)  ldrhdr3
700bAC                   if        %found
700bAC                   eval      $prte  = Sc1ParentRte
700bAC                   eval      $prtid = Sc1ParentRtid
700bAC                   eval      $pstrd = l_lhstrd
700bAC                   eval      $pstrt = l_lhstrt
700bAC                   eval      lhstat = savlhstat
700bAC                   eval      lhsup# = savlhsup#
700bAC                   eval      lhclsd = savlhclsd
700bAC                   eval      lhclst = savlhclst
700bAC                   exsr      zzhist
700bAC                   endif
700bAC                   endif
700bAC                   endif
700bAC                   eval      ttrtid = Sc1ParentRtid
700bAC     TTkey         setll     ttmerg
700bAC                   dow       forevr = forevr
700bAC     TTkey         reade     ttmerg
700bAC                   if        %eof
700bAC                   leave
700bAC                   endif
700bAC                   if        ttmcri = sav$prtid
700bAC                   iter
700bAC                   endif
700bAC                   eval      kyrte1  = ttmcrt
700bAC                   eval      kyrtid1 = ttmcri
700bAC     ttmkey1       setll     record
700bAC                   reade     record
700bAC                   if        not %eof
700bAC     ttkey1        chain(n)  ldrhdr3
700bAC                   if        %found
700bAC                   eval      $prte  = l_lhrte
700bAC                   eval      $prtid = l_lhrtid
700bAC                   eval      $pstrd = l_lhstrd
700bAC                   eval      $pstrt = l_lhstrt
700bAC                   eval      lhstat = savlhstat
700bAC                   eval      lhsup# = savlhsup#
700bAC                   eval      lhclsd = savlhclsd
700bAC                   eval      lhclst = savlhclst
700bAC                   exsr      zzhist
700bAC                   endif
700bAC                   endif
700bAC                   enddo
700bA* You're done with the associated routes, now go back and reload
700bA* the route the user selected
700bAC                   eval      $prte  = sav$prte
700bAC                   eval      $prtid = sav$prtid
700bAC                   eval      $pstrd = sav$pstrd
700bAC                   eval      $pstrt = sav$pstrt
700bAC     keyrs         chain     record                             79
700bAC                   endif
     *
     *
     *  Trailer is being changed, write current trailer
     *  info into an exception file and update Ldrhdr
     *  file with new info.
     *
     C                   when      wkoopt = ' 2'
     C                   if        $ptlr# <> lhtrlr  or
     C                             numemp <> lhemp#
     C                   exsr      zzexcp
     *
     *
     C                   eval      lhtrlr = $ptlr#
     C                   movel     $pemp#        lhemp#
     C                   eval      lhendd = *zeros
     C                   eval      lhendt = *zeros
     C                   update    record
     *
650cA*  Look for parent or child routes in TTMERG that are associated
650cA*  with this route and update their trailer too.  Only routes
650cA*  which are at printed status or higher will exist in LDRHDR.
650cAC                   exsr      zzAddOns
650cA*
     *
     C                   endif
     *
     *
     *  Unload Trailer: Load current date and time into
     *  Ldrhdr record holding information pertaining to
     *  trailer being unloaded.
     *
     C                   when      wkoopt = ' 6'
     C                   eval      lhclsd = $cvd8o
     C                   time                    lhclst
     C     #user         chain     piruser                            78
     C                   if        not *in78
     C                   eval      lhsup# = usemp#
     C                   else
     C                   eval      lhsup# = *zeros
     C                   endif
     *
     C                   eval      lhstat = '5'
     *                                                    record
     *
     C                   exsr      zzexcp
     *
     C                   exsr      zzhist
     *                                                    & DetlHist
     *
     C     fileky        chain     ldrteq                             78
     C                   if        not *in78
     C                   delete    ltrec
     C                   endif
     *
640 AC     fileky        chain     ldrtrle1                           78
640 AC                   if        not *in78
640 AC                   delete    eqrec
640 AC                   endif
     *
     C                   delete    record
     *
     C                   eval      lhtrlr = *blanks
     C                   eval      lhstrd = *zeros
     C                   eval      lhstrt = *zeros
     C                   eval      lhemp# = *zeros
     C                   eval      lhendd = *zeros
     C                   eval      lhendt = *zeros
     C                   eval      lhclsd = *zeros
     C                   eval      lhclst = *zeros
     C                   eval      lhsup# = *zeros
     *
     C                   eval      lhstat = *on
     *
     C                   write     record
     *
     *
     *
     *  Load current date and time into Ldrhdr file if
     *  assigning route to loader (1st time).
     *
     C                   when      wkoopt = ' 7'
     C                   eval      lhtrlr = $ptlr#
     C                   movel     $pemp#        lhemp#
     C                   eval      lhstrd = $cvd8o
     C                   time                    lhstrt
     C                   eval      lhstat = '2'
     C                   update    record
     *
650cA*  Look for parent or child routes in TTMERG that are associated
650cA*  with this route and update their trailer too.  Only routes
650cA*  which are at printed status or higher will exist in LDRHDR.
650cAC                   exsr      zzAddOns
     *
     C                   endsl
     *
     C                   endif
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
     1 2 4 5 6 7121617
**  OPTLN - Option display line
  1=Close rte  2=Chg lodr/trlr  5=View rte  6=Unload Trailer
  7=Assign route  12=Rte load dtl 16=Comment  17=View Comm
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F9=Add-ons  F10=View 2  F11=Closed Rts
F12=Cancel  F13=FlagScrn  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F9=Add-ons  F10=View 2  F11=Closed Rts
F12=Cancel  F13=FlagScrn  F17=Top  F18=Bottom  F20=Move to top
**  DESC - Message
This route is already assigned to a loader
This route has not been assigned to a loader yet
This route is already closed
Route can not be closed, loading has not ended
Route can not be assigned, it is loaded and closed
Route can not be closed, it is at OPEN stage
Route can not be closed, due to pending flags
Route is at OPEN stage, nothing has been loaded
DISABLED route entry. Unloaded trailer.
Not authorized to use option (1=Close rte)
Route can't be closed, missing trailer equip info
User is not authorized to delete route
No comments were found for this route
