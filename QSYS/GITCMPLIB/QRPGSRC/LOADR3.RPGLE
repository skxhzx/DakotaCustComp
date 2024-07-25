      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  LOADR3  Pallet Loading Screen - Loader Module
     *  May 24, 2006
     *  Jose Duque
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    07/18/08  RBD  5.20    P#00060
     *      - Enh: Added client custom code support to program.
     *
530 A*    06/28/10  JCJ  5.30
     *      - Fix: change program to use route id instead of route
     *        to get the 2 char piece of pallet id.
530bA*    07/08/10  RH   5.30b
     *      - Fix: Display dock door assigned in truck builder.
530cA*    07/14/10  RBD  5.30c
     *      - Fix: Change PARTKY for LDRDETL to include route id.
     *
650aA*    01/21/15  RBD  6.50a
     *      - Converted to ILE.
     *      - Changed screen format to LOADR301.
700aA*    07/28/16  TAB  7.00a
     *      - Changed screen format to LOADR302.
     *      - Added voice ID field
     *
700bA*    11/15/16  NLK  7.00b
     *      - LP130B needs to called due to read
     *        of Trans# vs License.
     *
750aA*    07/20/21  RBD  7.50a
     *      - Fix: check for merge pallet when counting flags
     *        by looking at corr trans number (which is label#)
     *        and if populated use that label# to check for flag
     *        in Runner file.
     *      - Added status 'S' to w1flag logic.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
CBI A*    07/18/08  RBD  CBI     P#00060
     *      - Coded "breakers" and exception truck zone/HACCP
     *        logic as specific to Cheney.
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
     *    CMD5 changed to chain and update each view seperately.
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
650aDF*Loadr3fm  cf   e             workstn
700aDF*Loadr301  cf   e             workstn
700aMFLoadr302  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
     FLabel13   if   e           k disk
750aAFLabel     if   e           k disk    rename(lbrec:lbrecX) prefix(l_)
     Frunner6   if   e           k disk
     Fpltsum1   if   e           k disk
     Fordh1     if   e           k disk
530bAFdocmtrx2  if   e           k disk
     Frtehed    if   e           k disk
     Fpirtran   if   e           k disk
     FLdrhdr    uf   e           k disk
     FLdrdetl   uf   e           k disk
     F                                     rename(lddrec:record)
     Fworkopt   uf a e           k disk
     FLdrdtlbk  if   e           k disk
700aAFpltsumu   if   e           k disk
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
     D cmdln           s             79    dim(6) ctdata perrcd(1)
     D desc            s             70    dim(9) ctdata perrcd(1)
     *----------------------------------------------------------------
520 A*  Client ID's
     *
CBI A /COPY QCOPYSRC,ID#CHENEY
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $krte                  4      8
     D  $krtid                 9     13
     D  $kstrd                14     21  0
     D  $kstrt                22     27  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukrte                  4      8
     D  ukplt#                 9     15  0
     *
     D                 ds
     D  dsfky2                 1     50
     D  dsuky2                 1     50
     D  whse                   1      3  0 inz(1)
     D  optrte                 4      8
     D  ldrtid                 9     13
     D  ldplid                14     20  0 inz(0)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @flags          c                   const('LOADFLCL')
     D @chgpg          c                   const('NONE')
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
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
     D  $pwhse                19     21  0 inz(0)
     D  $prte                 22     26
     D  $prtid                27     31
     D  $pltid                32     38  0
     D  $ptstd                39     44
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
416aAD  $lrtid                22     26
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
     D  stop#                  1      2  0
     D  stp1                   1      1  0
     D  stp2                   2      2  0
     *----------------------------------------------------------------
     D                 ds
     D  rte1                   1      5
     *
     *   Redefine DS
     *
     D  rte23                  2      3  0
530 AD  rte45                  4      5  0
     *
     *----------------------------------------------------------------
     D                 ds
     D  pltid                  1      7  0
     *
     *   Redefine DS
     *
     D  plt12                  1      2  0
     D  plt37                  3      7  0
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
     *
     *----------------------------------------------------------------
     *
     D                 ds
     D  hldtim                 1      6
     D  hh                     1      2
     D  mm                     3      4
     D  ss                     5      6
     *
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
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $trn#           s              7  0
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
     D goback          s              2  0
     D help            s              5  0
750aAD lblkey          s                   like(lblbl#)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D progm           s             10
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rte2            s              2
     D sclear          s              1
     D shwwin          s              1
     D stop            s              1
     D svrtid          s              5
     D tdiff           s              6  0
     D timein          s              6
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
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
     C                   parm                    $door#            3
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
     C                   setoff                                       202122
     C                   setoff                                       233132
     C                   setoff                                       339098
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
     *R         CLERR     CABEQ'1'       CMD01E
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
     *  TEST FOR CMD11 - Next view
     *
     C                   if        *inkk
     C                   if        view = maxvw
     C                   eval      view = 1
     C                   else
     C                   add       1             view
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     C                   goto      cmd01e
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
     C                   eval      *in02 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     *----------------------------------------------------------------
     C     ent01         begsr
     *
     *  Verify and save options
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  See if user is trying to position to a certain spot
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     error         cabeq     '1'           ent01e
     *
     C                   if        shwwin = '1'
     C                   eval      $dtlid = *blanks
     C                   if        rte2 = '75'  and
CBI AC                             client = cheney
     C                   eval      $dtlid = ldrtid
     C                   endif
     C                   call      'LOADR4'
     C                   parm                    $puky
     C                   parm                    $dtlid            5
     C                   parm                    $kstrd
     C                   parm                    $kstrt
     C                   parm                    $pprg
     C                   parm                    $rtncd
     *
     C                   seton                                        24
     C                   setoff                                       26
     *
     C                   if        $rtncd = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $rtncd = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $rtncd = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   eval      ptinp2 = *zeros
     C                   eval      ptinp3 = *zeros
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   goto      ent01e
     C                   endif
     *
     C                   if        repos = *on
     C                   eval      $pofky = dsfky2
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  If not positioning then execute the entered options
     *
     C                   exsr      optns
     *
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     *----------------------------------------------------------------
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
     C                   eval      dsuky2 = $pouky
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
     C                   eval      dsfky2 = $pofky
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
     *----------------------------------------------------------------
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Loading a pallet, display pallet entry screen
     *
     C                   if        wkoopt = ' 1'  or
     C                             wkoopt = '12'
     *
     C                   if        wkoopt = '12'
     *
     C                   eval      $rtncd = 'PLTOUT  '
     C                   endif
     *
     C                   eval      $dtlid = *blanks
     C                   if        rte2 = '75'  and
CBI AC                             client = cheney
     C                   eval      $dtlid = ldrtid
     C                   endif
     C                   eval      $prtid = ldrtid
     C                   call      'LOADR4'
     C                   parm                    $puky
     C                   parm                    $dtlid
     C                   parm                    $kstrd
     C                   parm                    $kstrt
     C                   parm                    $pprg
     C                   parm                    $rtncd
     C                   eval      $prtid = $krtid
     C                   goto      endop2
     C                   endif
     *
     *
     *   Viewing loaded pallet info, display pallet entry screen
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $dtlid = *blanks
     C                   if        rte2 = '75'  and
CBI AC                             client = cheney
     C                   eval      $dtlid = ldrtid
     C                   endif
     C                   eval      $rtncd = 'VIEW    '
     C                   eval      $puky = wkokyu
     C                   eval      $prtid = ldrtid
     C                   call      'LOADR4'
     C                   parm                    $puky
     C                   parm                    $dtlid
     C                   parm                    $kstrd
     C                   parm                    $kstrt
     C                   parm                    $pprg
     C                   parm                    $rtncd
     C                   endif
     *
     *
     *   Cleared/Unload pallet already closed to a trailer
     *
     C                   if        wkoopt = ' 6'
     *   Save pointer to first entry on screen in case of an ADD-ONS
     C                   eval      svrtid = $krtid
     C                   eval      $krtid = ldrtid
     C     fileky        chain     record                             78
     C                   if        not *in78
     C                   eval      ldstrd = *zeros
     C                   eval      ldstrt = *zeros
     C                   eval      ldendd = *zeros
     C                   eval      ldendt = *zeros
     *
     *   Check if pallet being unloaded is an entire outed pallet.
     C     fileky        chain     ldbrec                             78
     C                   if        not *in78
     C                   z-add     ldbcub        ldcube
     C                   eval      ldpcs = ldbpcs
     C                   endif
     C                   update    record
     C                   eval      $krtid = svrtid
     *
     *   Cleared date and time in Load Header file if
     *   this route is on 'Ended' status, but not closed yet.
     *
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     C                   if        lhendd <> *zeros  and
     C                             lhclsd = *zeros
     C                   eval      lhendd = *zeros
     C                   eval      lhendt = *zeros
     C                   eval      lhstat = '2'
     C                   update    lhrec
     C                   endif
     C                   endif
     C                   endif
     C                   goto      chkrtn
     C                   endif
     *
     *   View Transaction Info.
     *
     C                   if        wkoopt = '10'
     *
     C     ldrdky        chain     label13                            79
     C                   if        not *in79
     C                   eval      $pcmd = '*NOOPT  '
     C                   eval      $trn# = lbtrn#
700bD **                 call      'LP130'
700bAC                   call      'LP130B'
     C                   parm                    $pcmd
     C                   parm                    $trn#
     C                   endif
     C                   endif
     *
     *
     C                   exsr      zzopt
     *
     C     chkrtn        tag
     C                   if        $rtncd = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $rtncd = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $rtncd = '*PGMQ   '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
     C     endop2        endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     *----------------------------------------------------------------
     C     pag01         begsr
     *
     *  Next page
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  Previous page
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  Top
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
     *  Bottom
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
     *  Repositioning
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
     *----------------------------------------------------------------
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
     C                   eval      errmsg = *blanks
     *
     C                   dou       nomore = '1'
     C                   select
     C                   when      view = 1
     C                   readc     dspsfl                                 79
     C                   when      view = 2
     C                   readc     vw2sfl                                 79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - error if not found
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in20 = *on
     C                   eval      *in21 = *on
     C                   eval      *in02 = *off
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   goto      select
     C                   endif
     C                   endif
     *
     *
     *    Display error msg if current pallet is already loaded
     *    or is being used by another user.
     *
     C                   if        option = ' 1'  or
     C                             option = '12'
     *
     C                   if        option = '12'
     *  Verify if user has update authorization, they are same
     *  users with access to close routes (LOADR1).
     *
     C                   movel     'LOADR1'      progm
     *
     C                   call      'CHKLIST'
     C                   parm                    progm
     C                   parm      ' '           @popt            20
     C                   parm                    #user
     C                   parm      ' '           @prtn             8
     *
     C                   if        @prtn = '*NO'
     C                   eval      error = *on
     C                   eval      *in20 = *on
     C                   eval      *in21 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   movel     desc(9)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      select
     C                   endif
     C                   endif
     *-----------------------------***--------------------------------
     *
     C     hdrkey        chain(n)  ldrhdr                             79
     C                   if        not *in79
     C                   if        lhstrd = *zeros
     C                   eval      error = *on
     C                   eval      *in20 = *on
     C                   eval      *in21 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   movel     desc(7)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      select
     C                   endif
     C                   endif
     *-----------------------------***--------------------------------
     C                   if        ldendt <> *zeros
     C                   eval      error = *on
     C                   eval      *in20 = *on
     C                   eval      *in21 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   if        ldpcs <> *zeros
     C                   movea     desc(2)       errmsg
     C                   else
     C                   movea     desc(8)       errmsg
     C                   endif
     C                   exsr      zm0105
     C                   endif
     C                   goto      select
     C                   else
     C     fileky        chain     record                             7978
     * Check if record is in use
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in20 = *on
     C                   eval      *in21 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   movea     desc(4)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      select
     C                   else
     C                   unlock    ldrdetl
     C                   endif
     C                   endif
     C                   endif
     *
     *
     *    Display error msg if current pallet is already loaded
     *    or is being used by another user.
     *
     C                   if        option = ' 5'  and
     C                             ldendt = *zeros
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in20 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     C                   if        option = ' 6'
     C                   if        ldendt = *zeros
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in20 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      select
     C                   endif
     *
     C     hdrkey        chain(n)  ldrhdr                             79
     C                   if        not *in79  and
     C                             lhclsd <> *zeros
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in20 = *on
     C                   eval      *in02 = *off
     C                   if        errmsg = *blanks
     C                   movea     desc(5)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     C                   endif
     C     select        tag
     *----------------------------------------------------------------
     *  Save option
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
     *
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C     y             chain     dspsfl                             79
     C                   if        not *in79
     C                   seton                                        85
     C                   update    dspsfl
     C                   endif
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
     C     y             chain     dspsfl                             79
     C                   if        not *in79
     C                   seton                                        85
     C                   update    dspsfl
     C                   endif
     C                   endif
     C                   write     dspsfc
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
     C                   if        w1stat = 'Ended'  and
     C                             ldendt = *zeros  and
CBI AC                             client = cheney
     C                   exsr      zzvrfy
     C                   else
     C                   setoff                                       3132
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   when      view = 2
     C     1             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    vw2sfl
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
     C                   endsl
     C                   if        *in03 <> '1'  and
     C                             error <> '1'
     C                   eval      *in02 = *on
     C                   write     postnrec
     C                   endif
     *
     C                   if        error = '1'  and
     C                             *in02
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
     C                   select
     C                   when      view = 1
     C                   if        w1stat = 'Ended'  and
     C                             ldendt = *zeros  and
CBI AC                             client = cheney
     C                   exsr      zzvrfy
     C                   else
     C                   setoff                                       3132
     C                   endif
     C                   update    dspsfl
     *
     C                   when      view = 2
     C                   update    vw2sfl
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
     *  ZZFGET   Get record with unique key.
     *
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
     *    Code to use when we are not using a partial key.
     *
     C                   if        shwwin <> ' '
     C     partky        reade     record                                 79
     C                   if        *in79
     C     *loval        setll     record                                 79
     C                   eval      ldplid = $pltid
     C     keyrs         chain     record                             79
     C                   endif
     C                   eval      shwwin = *blanks
     C                   else
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade(n)  record                               7879
     C                   endif
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
     C     partky        reade     record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Pallet start load date
     *
     C                   if        ldstrd = 0
     C                   eval      w1strd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ldstrd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1strd = $cvd6o
     C                   endif
     *
     C                   eval      w1flag = *zeros
     *
     C                   eval      stopr1 = *blanks
     C                   eval      stopr2 = *blanks
     *
     C                   eval      stop# = ldstp1
     C                   if        ldstp1 >= 1  and
     C                             ldstp1 <= 9
     C                   move      stp2          stopr1
     C                   else
     C                   move      stop#         stopr1
     C                   endif
     *
     C                   eval      stop# = ldstp2
     C                   if        ldstp2 >= 1  and
     C                             ldstp2 <= 9
     C                   move      stp2          stopr2
     C                   else
     C                   move      stop#         stopr2
     C                   endif
     *
     C                   if        ldstp2 = *zeros
     C                   eval      stopr2 = 'SP'
     C                   endif
     *
     *
     C     ldrdky        setll     label13                                79
     C     ldrdky        reade     label13                                79
     C                   dow       not *in79
     *
700aAC     ldrdky        Chain     pltsumU                            78
700aAC                   If        Not *In78
700aAC                   Eval      W1UVID = PSUVID
700aAC                   Else
700aAC                   Clear                   W1UVID
700aAC                   EndIf

750aA /free
750aA   // Check for merge pallet, if yes, look for flag for it

750aA   lblkey = 0;
750aA   if lbctr# <> 0;
750aA     chain (lbctr#) label;
750aA     if %found(label);
750aA       lblkey = l_lblbl#;
750aA     endif;
750aA     else;
750aA       lblkey = lblbl#;
750aA   endif;

750aA /end-free

     C     runrky        chain     runner6                            78
     C                   if        not *in78  and
     C                             rustat <> 'C'  and
750aMC                             rustat <> 'D'  and
750aAC                             rustat <> 'S'
     C                   add       1             w1flag
     C                   endif
     *
     C     ldrdky        reade     label13                                79
     C                   enddo
     C                   if        w1flag > 0
     C                   seton                                        28
     C                   endif
     *
     *
     C                   eval      w1stat = *blanks
     *
     C     pltkey        setll     pltsum1
     C     pltkey        reade     pltsum1                                79
     *
     C                   dow       not *in79
     C                   if        psplid = ldplid
     C     pstrn#        chain     pirtran                            78
     C                   if        not *in78
     *   Find pallet picking status
     *
     C                   select
     C                   when      ptstat = '1'
     C                   eval      w1stat = 'Open   '
     *
     C                   when      ptstat = '2'
     C                   eval      w1stat = 'Started'
     *
     C                   when      ptstat = '3'
     C                   eval      w1stat = 'Ended  '
     *
     C                   when      ptstat = '4'
     C                   eval      w1stat = 'Closed '
     C                   endsl
     *
     C                   leave
     C                   endif
     C                   endif
     *
     C     pltkey        reade     pltsum1                                79
     C                   enddo
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
     *  The following routine compares pallet ended time
     *  against current time, if the difference >= 30
     *  minutes and <= 44 minutes, the dept id will be
     *  displayed in yellow. If the difference is 45
     *  minutes or greater the dept then will be displayed
     *  in red.
     *
     *
     C                   eval      timein = *blanks
     C                   setoff                                       3132
     *
     C     pltkey        setll     pltsum1
     C     pltkey        reade     pltsum1                                79
     *
     C                   dow       not *in79
     C                   if        psplid = ldplid
     *
     C     pstrn#        chain     pirtran                            78
     C                   if        not *in78  and
     C                             ptstat = '3'
     C                   move      ptetim        timein
     C                   leave
     C                   endif
     C                   endif
     *
     C     pltkey        reade     pltsum1                                79
     C                   enddo
     *
     C                   if        timein = *blanks
     C                   goto      endiff
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
     C                   setoff                                       32
     C                   endif
     *
     C                   if        tdiff >= 4400
     C                   seton                                        32
     C                   setoff                                       31
     C                   endif
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
     C                   setoff                                       1526
     C                   seton                                        25
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krte
     C                   kfld                    $krtid
     C                   kfld                    ldplid
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krte
     C                   kfld                    $krtid
     C                   kfld                    ldplid
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krte
530cAC                   kfld                    $krtid
     *
     *  Define partial key for file LDRDETL
     *  Key used in ZZFILL Rtn.
     C     keyrs         klist
     C                   kfld                    ldwhse
     C                   kfld                    ldrte
     C                   kfld                    $krtid
     C                   kfld                    ldplid
     *
     C     ldrdky        klist
     C                   kfld                    ldwhse
     C                   kfld                    ldrtid
     C                   kfld                    ldplid
     *
     C     runrky        klist
     C                   kfld                    ldwhse
750aDC**                 kfld                    lblbl#
750aMC                   kfld                    lblkey
     *
     C     hdrkey        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krte
     C                   kfld                    $krtid
     C                   kfld                    $kstrd
     C                   kfld                    $kstrt
     *
     C     pltkey        klist
     C                   kfld                    $kwhse
     C                   kfld                    ldrtid
     *
     C     rtkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
     C     ohkey         klist
     C                   kfld                    rhpbat
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
530bA*
530bA*     Partial key to get dock door.
530bAC     dckey         klist
530bAC                   kfld                    $kwhse
530bAC                   kfld                    $krtid
     *
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
     C                   eval      dsfky2 = $prtky
     C                   eval      optrte = $krte
     *
     *  Get loading door number
     C                   eval      optdor = *blanks
     C     rtkey         chain     rtehed                             79
     C                   if        not *in79
530bAC                   select
CBI AC                   when      client = cheney
     *
     C     ohkey         setll     ordh1
     C     ohkey         reade     ordh1                                  79
     C                   if        not *in79
     C                   eval      dsmisc = ohmisc
     C                   movel     dsdoor        optdor
     C                   endif
530bAC                   other
530bAC     dckey         setll     docmtrx2
530bAC     dckey         reade     docmtrx2                               78
530bAC                   if        not *in78
530bAC                   move      dmdoor        optdor
530bAC                   endif
530bAC                   endsl
     C                   endif
     *
     C                   seton                                        24
     C                   subst     $krte:2       rte2
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     ldwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = ldwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ldwhse
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
     C                   else
     C                   eval      $kwhse = ldwhse
     C                   eval      whcode = ldwhse
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
     C                   eval      $pofky = dsfky2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = ldwhse
     C                   eval      ukrte = $krte
     C                   eval      ukplt# = ldplid
     C                   eval      $pouky = dsuky2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     C                   select
     *
     *   Item entry screen
     *
     C                   when      wkoopt = ' 9'
     C                   eval      $luky = $puky
     C                   eval      $lrtn = *blanks
     C                   call      'RH393'
     C                   parm                    $lrtid
     C                   parm                    $lrtn
     *
     C                   endsl
     *
     C                   endsr
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
     C                   eval      *in23 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      ldwhse = ptinp1
     C                   eval      $kwhse = ldwhse
     C                   eval      ldrte = *blanks
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
     *----------------------------------------------------------------
     *  NOTE: PTINP2 Logic was modified to display loading
     *        pallet modification screen (Loadr4fm) as opposed
     *        to position cursor at the pallet # typed on the
     *        PTINP2 field.
     *
     C                   seton                                        25
     C                   setoff                                       03
     C                   eval      shwwin = *blanks
     *
     C                   if        ptinp2 = *zeros  and
     C                             ptinp3 = *zeros
     C                   setoff                                       25
     C                   seton                                        24
     C                   goto      endzps
     C                   endif
     *
     *  The last two numbers of the route # have been added to the
     *  pallet id label (only) to prevent loading a pallet into the
     *  wrong trailer since the actual pallet ids (in BFC files) have
     *  two zeros as first digits and the same pallet id numbers are
     *  used in all routes, one could load a pallet on any trailer
     *  without knowing that it belongs to a different route.
     *
     *  Verify pallet # entered.
     *
530 D***                  MOVE $KRTE     RTE1
530 MC                   eval      rte1 = $krtid
     *
     C                   if        not *in26
     C                   eval      pltid = ptinp2
     C                   eval      ptinp3 = ptinp2
     C                   else
     C                   eval      pltid = ptinp3
     C                   endif
     *
     *  Pallet is not part of route being loaded
     *
530 D***        RTE23     IFNE PLT12
530 MC                   if        rte45 <> plt12
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in24 = *off
     C                   eval      *in25 = *on
     C                   eval      *in26 = *on
     C                   eval      ptinp2 = *zeros
     C                   movel     desc(6)       errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   endif
     *
     C     hdrkey        chain(n)  ldrhdr                             79
     C                   if        not *in79
     C                   if        lhstrd = *zeros
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in24 = *off
     C                   eval      *in25 = *on
     C                   eval      *in26 = *on
     C                   eval      ptinp2 = *zeros
     C                   movel     desc(7)       errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   endif
     C                   endif
     *
     *  Zero out first two positions of scanned pallet id,
     *  the first two digits are zeros in orig  pallet id.
     *  That is how they are stored in the file.
     *
     C                   eval      plt12 = *zeros
     *
     C                   eval      $pltid = pltid
     C                   eval      ldplid = pltid
     *
     C     keyrs         chain(n)  ldrdetl                            79
     C                   if        *in79
     C                   eval      ldstrd = 0
     C                   eval      ldstrt = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   endif
     C                   endif
     *
     C                   if        ldendd <> *zeros
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      *in24 = *off
     C                   eval      *in25 = *on
     C                   eval      *in26 = *on
     C                   if        errmsg = *blanks
     C                   if        ldpcs <> *zeros
     C                   movea     desc(2)       errmsg
     C                   else
     C                   movea     desc(8)       errmsg
     C                   endif
     C                   exsr      zm0105
     C                   goto      endzps
     C                   endif
     C                   endif
     *
     C                   eval      $pwhse = $kwhse
     C                   eval      $prte = $krte
     C                   eval      $prtid = $krtid
     C                   eval      shwwin = *on
     C                   eval      ptinp2 = *zeros
     C                   goto      endzps
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *
     C                   if        *inks
     C                   if        $pocmd = '*TOP'
     C     *loval        setgt     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     *loval        setll     record
     C                   endif
     C                   endif
     C                   goto      endpo2
     C                   endif
     *
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     *
     C     endpo2        endsr
     *----------------------------------------------------------------
     *
     *  ZZVRFY   Verify if pallet being processed is a
     *           HACCP guide line subject.
     *
     C     zzvrfy        begsr
     *
     C                   if        ldtrkz = 'CLR'  or
     C                             ldtrkz = 'FRZ'  or
     C                             ldtrkz = 'PRD'
     *
     *           Skip CLR pallets found in cooler
     *           doors 23 to 28.
     *
     C                   if        $door# >= '23'  and
     C                             $door# <= '28'
     C                   setoff                                       3132
     C                   else
     C                   exsr      zzgdif
     C                   endif
     *
     C                   else
     C                   setoff                                       3132
     C                   endif
     *
     C     endvfy        endsr
     *----------------------------------------------------------------
     *  Compile time tables
     *
**  ZOPT - Valid options
     1 5 61012
**  OPTLN - Option display line
  1=Load Pallet  5=View loaded pallet  6=Unload pallet  10=TranInfo
  12=PltOut
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F10=View 2  F12=Cancel  F13=FlagScreen
F17=Top  F18=Bottom
F3=Exit  F4=Prompt  F5=Refresh  F10=View 1  F12=Cancel  F13=FlagScreen
F17=Top  F18=Bottom
**  DESC
Invalid pallet id
This pallet is already loaded
This pallet has not been loaded yet
Pallet record in use by another user
Pallet can't be unloaded, route is closed
Pallet does not belong to this route
This route has not been assigned to a loader yet
This pallet is already outed
Not authorized to use option (12=PltOut)
