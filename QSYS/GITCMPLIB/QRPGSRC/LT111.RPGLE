     *----------------------------------------------------------------
     *  LT111   RF - Display Pick Slots with less than 5 cases.
     *
     *  September 17, 2010
     *  Jose G. Duque               (Created using: RC201)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
700aA*    09/17/10  JGD  7.00a
     *      - Created
     *
700bA*    09/14/16  JCJ  7.00b
     *      - Softcoded case quantity (caseqty).
     *
710aA*    03/26/17  JCJ  7.10a
     *      - Added code for Pate Dawson slot formats.
     *      - Added client code.
     *
730 A*    12/13/19  KDE  7.30
     *      - Added code to grab proper Warehouse.  Was hardcoding 001
     *      - Also added ability to pass in/out full display slot
     *----------------------------------------------------------------
     *  Notes
     *      11 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
CBI  *    12/01/10  CBI-JGD  (This change applies to OCALA only).
     *      Increase the locations selected qty criteria from"< 5" to
     *      "< 10" (per Gus).
     *
CBIa *    12/03/10  CBI-JGD  (This change applies to OCALA only).
     *      Select pick locations that have < 5 Cases if Fork Lift
     *      operator is night shift, if the operator is day shift then
     *      select pick locations that have < 10 Cases.
     *
CBIb *    10/17/11  CBI-JGD  (This change applies to OCALA only).
     *      Decrease the locations selected qty criteria for day
     *      fork lift operators from"< 10" to "< 5" (per Gus).
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
     FLt111fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     *
     Fslot2     if   e           k disk
     *
     Fslot3     if   e           k disk
     F                                     rename(slrec:slrec2)
     *
     Fitemdef   if   e           k disk
     *
     Fslotdef   if   e           k disk
     *
730 AFvslot1    if   e           k disk    rename(vsrec:vsrec1)
     Fvslot2    if   e           k disk
     *
CBIaAFpiruser   if   e           k disk
     *
     Fpickless5 uf a e           k disk
     F                                     rename(pckrec:record)
     Fworkopt   uf a e           k disk
     Foptions   if   e           k disk
     *
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
     D cmdln           s             79    dim(6) ctdata perrcd(1)
CBIaMD desc            s             60    dim(7) ctdata perrcd(1)

     *----------------------------------------------------------------
710aA*  Dakota Client IDs
     *
710aA /copy qcopysrc,id#cheney
710aA /copy qcopysrc,id#cheneyo
710aA /copy qcopysrc,id#cheneyr
710aA /copy qcopysrc,id#cheneyg
710aA /copy qcopysrc,id#cheneyp

     *----------------------------------------------------------------
710aA*  Customer id
     *
710aaD                 ds
710aAD  client                 1     10
710aAD  cliloc                11     20

     *----------------------------------------------------------------
     *  Called programs

     D @sltqty         c                   const('SLOTQTY')
     D @cvtqty         c                   const('CVTQTY')
710aAD @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
CHY A*  Slot redefinition
     *
CHY AD                 ds
CHY AD  w3disp                 1     12
CHY2MD  w3dsp1                 1      7
CHY2MD  w3dsp2                 8     12
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D  $prtky         ds
     D   $len50                1     50
     D   $kwhse                1      3  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  slwhse                 1      3  0
     D  slwhdp                 4      8
     D  sldisp                 9     20
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('*NONE')
     D @delpg          c                   const('*NONE')
     D @prtpg          c                   const('*NONE')
414 AD @apics          c                   const('APICVTSLT ')
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
     D  pwhseb                19     21
     D  pitemb                22     36
     D  pslotb                37     48
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
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
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
700bA*----------------------------------------------------------------
700bA*  *REPLEN  -  Replenishment options.
700bA*----------------------------------------------------------------
700bA*
700bA* Fields
700bA*
700bA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
700bA*    OPOQRP  -  Order qty replenishment (Y/N).
700bA*    OPRPEX  -  Allow replenishment on expired items.
700bA*               1=Allow, 2=Don't allow, 3=Warn
700bA*    OPRPFI  -  Allow replenishments out of FIFO order.
700bA*               1=Allow, 3=Warn
700bA*    OPLMTS  -  Limit Specific Slot replenishment program to
700bA*               to display only one overflow location at a
700bA*               time. (Y/N)
700bA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
700bA*               letdown/transfer. (Y/N)
700bA*    OPBDRP  -  Check for Bulk Drops. (Y/N)
700bA*    OPRSRT  -  Sort Replenishment  (*DEMAND, *TOSLOT).
700bA*    OPSKPR  -  Skip if pick slot physical qty is greater than
700bA*               item replenishment level.
700bA*    OPJITW  -  During specific slot repl if this option = N don't
700bA*               bother checking for JIT's as the user does not want
700bA*               the JIT notification window.
700aA*    OPLQTY  -  Replenish pick slots that display less than X
700aA*               cases.
700bA*
700bA* Data structure
700bA*
700bAD opdta3          ds
700bAD  oprplb                 1      8
700bAD  opoqrp                 9      9
700bAD  oprpex                10     10
700bAD  oprpfi                11     11
700bAD  oplmts                12     12
700bAD  opcqty                13     13
700bAD  opbdrp                14     14
700bAD  oprsrt                15     24
700bAD  opskpr                25     25
700bAD  opjitw                26     26
700aAD  oplqty                27     28  0
700aAD  oplqtya               27     28
700bAD  opcend               117    117
414 A*----------------------------------------------------------------
414 A* Program variables.
414 A*----------------------------------------------------------------
     D $pwhse          s              3
417fAD $pitem          s             15
417fAD $lbtrn#         s              7  0
     D $pw3qty         s              7  0
     D $pslot          s              7
     D $rtncd          s              8
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D casqty          s              7  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              8
     D cnt8            s              5  0
     D comand          s              5  0
     D dept            s              5
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D first           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D ovrstkonhand    s              5  0
     D p               s              2  0
     D pagcmd          s              8
     D pckcpcy         s              6  0
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D recnt2          s              4  0
     D redspl          s              1
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D slot#           s             12
     D slt1            s              2
     D slt2            s              3
     D slt3            s              2
     D stop            s              1
     D svdisp          s             12
     D svsdef          s              2
     D svwhdp          s              5
     D svwhse          s              3  0
     D today           s              8  0
     D top             s              1
     D tpdisp          s             12
     D tpwhdp          s              5
     D tpwhse          s              3  0
     D view            s              1  0
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
     D yes             s              1
     D kycode          s                   like(opcode)
     D kywhse          s                   like(opwhse)
     D title           s             35
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
     D route           c                   const('Route ')
     D closed          c                   const('Closed')
     D Title1          c                   const('Display Pick Slots with < ')
     D Title2          c                   const('Cases')
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
     C     *entry        plist
     C                   parm                    $pslot
     C                   parm                    dept
     C                   parm                    dspls5            1
730 AC                   parm                    fulldisp         12
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
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
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
     C                   seton                                        lr
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------
     C     dspscr        begsr
     *----------------------------------------------------------------
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   else
     C                   eval      *in04 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     *----------->  WRITE     TITLE
     *
     C                   if        recnt2 = *zeros
     *    Not qualifying pick slot found.
     C                   movel     desc(6)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     *
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     excpscr
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010204
     C                   setoff                                       202122
     C                   setoff                                       2324
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     C                   exsr      zmcmsg
     *
     C                   if        nxtscr = '03 '
     C                   goto      endscr
     C                   endif
     *
     C                   select
     C                   when      view = 1
     C                   read      dspsfc                                 50
     *--> VIEW          WHENEQ    2
     *                  READ      VW2SFC                                 50
     *--> VIEW          WHENEQ    3
     *                  READ      VW3SFC                                 50
     C                   endsl
     *
     C     endscr        endsr
     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------
     C     scr01i        begsr
     *----------------------------------------------------------------
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     *
     C                   exsr      pag01
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------
     C     scr02i        begsr
     *----------------------------------------------------------------
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
     *  Screen 02 wrap-up
     *----------------------------------------------------------------
     C     scr02e        begsr
     *----------------------------------------------------------------
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
     *  SC1  -  Screen 1
     *----------------------------------------------------------------
     C     sc1           begsr
     *----------------------------------------------------------------
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *  SC2  -  Screen 2
     *----------------------------------------------------------------
     C     sc2           begsr
     *----------------------------------------------------------------
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Excpscr screen
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = '01 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
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
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C                   eval      nxtscr = '01 '
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
     C     *inzsr        begsr
710aA*
710aA* Get client id.
710aA*
710aAC                   call      @getcl
710aAC                   parm                    client
710aAC                   parm                    cliloc

     *----------------------------------------------------------------
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
     C                   eval      cnt8 = *zeros
     C                   eval      pckcpcy = *zeros
     C                   eval      recnt2 = 0
     C                   write     dspsfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *  CLRSCH   Clear everything out of work file
     *----------------------------------------------------------------
     C     clrsch        begsr
     *----------------------------------------------------------------
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *  CMD01    Screen 1 command key routine
     *----------------------------------------------------------------
     C     cmd01         begsr
     *----------------------------------------------------------------
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   eval      dspls5 = *off
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   eval      dspls5 = *off
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH SCREEN FROM THE TOP
     *
     C                   if        *inke
     C                   exsr      clrsch
     C                   eval      cnt8 = *zeros
     C     1             do        7             x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   move      '    '        option
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     *
     *  Setting 'FKEY' to *LOVAL forces screen to be refreshed
     *  from the top as suppose to just the screen being displayed.
     *  This is the type of screen refresh needed by this appl.
     C                   move      *loval        fkey
     C                   eval      slwhse = tpwhse
     C                   eval      slwhdp = tpwhdp
     C                   eval      sldisp = tpdisp
     *
     C                   exsr      scr01i
     C                   goto      cmd01e
     C                   endif
     *
     *
     *  Test for F10 - Exception found by the fork lift operator
     *  when puting away a received item, AS/400 had slot listed as loaded.
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
     C
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       7             row#
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
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *  CMD02    Screen 2 command key routine
     *----------------------------------------------------------------
     C     cmd02         begsr
     *----------------------------------------------------------------
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
     *  DELADD   Add record to subfile for delete display
     *----------------------------------------------------------------
     C     deladd        begsr
     *----------------------------------------------------------------
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
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *  DELDSP   Display subfile of records marked for deletion
     *----------------------------------------------------------------
     C     deldsp        begsr
     *----------------------------------------------------------------
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
     *    VIEW          WHENEQ    2
     *                  WRITE     VW2SFC
     *    VIEW          WHENEQ    3
     *                  WRITE     VW3SFC
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *  ENT01    Screen 1 enter key routine
     *----------------------------------------------------------------
     C     ent01         begsr
     *----------------------------------------------------------------
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     C     ent01e        endsr
     *----------------------------------------------------------------
     *  ENT02    Screen 2 enter key routine
     *----------------------------------------------------------------
     C     ent02         begsr
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     C     fgtway        begsr
     *----------------------------------------------------------------
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
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *----------------------------------------------------------------
     C     fget          begsr
     *----------------------------------------------------------------
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
     *  FGETN    Get next record
     *----------------------------------------------------------------
     C     fgetn         begsr
     *----------------------------------------------------------------
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
     *  FGETP    Get previous record
     *----------------------------------------------------------------
     C     fgetp         begsr
     *----------------------------------------------------------------
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   if        *in78
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *  FPOS2    Position to record
     *----------------------------------------------------------------
     C     fpos2         begsr
     *----------------------------------------------------------------
     C                   eval      dsfkey = $pofky
     C     filuky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *  FPOS2U   Position to record using unique key
     *----------------------------------------------------------------
     C     fpos2u        begsr
     *----------------------------------------------------------------
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
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *----------------------------------------------------------------
     C     inzpar        begsr
     *----------------------------------------------------------------
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *  OPTNS    Perform options that user entered
     *----------------------------------------------------------------
     C     optns         begsr
     *----------------------------------------------------------------
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
     *
     *-----------------------------> <--------------------------------
     *
     C                   eval      otaken = *on
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
     *  OPTNS2   Execute individual options
     *----------------------------------------------------------------
     C     optns2        begsr
     *----------------------------------------------------------------
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     C                   eval      $pdky = wkokyu
     *
     *   Verify that selected pick slot loc has not been replenished.
     *
     C                   if        wkoopt = ' 1'
     C     keyvex        chain     slot2                              78
     C                   if        not *in78
     *
     *  Save key to record being processed.
     *
     C                   eval      svwhse = slwhse
     C                   eval      svwhdp = slwhdp
     C                   eval      svdisp = sldisp
     *
     *  Get current qty for pick slot being processed.
     *
     C                   exsr      zzgetq
     *
     *  Reset key back to pick slot record being processed.
     *
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svwhdp
     C                   eval      sldisp = svdisp
     *
     *  By pass this record if pick slot qty has been replenished.
     *                            PickSlot
CBIaMC                   if        $pqty1 >= casqty
     *    Slot is not longer less than 5 cases.
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0105
     C                   goto      endns2
     C                   endif
     C                   else
     *    Slot does not longer exist.
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   movel     desc(5)       errmsg
     C                   exsr      zm0105
     C                   goto      endns2
     C                   endif
     C                   endif
     *
     C                   exsr      zzopt
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
     *
     C     endns2        endsr
     *----------------------------------------------------------------
     *  PAG01    Screen 1 page routines
     *----------------------------------------------------------------
     C     pag01         begsr
     *----------------------------------------------------------------
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
     *  PAG02    Screen 2 page routines
     *----------------------------------------------------------------
     C     pag02         begsr
     *----------------------------------------------------------------
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
     *  PAG1FW   Let's see that next page of records
     *----------------------------------------------------------------
     C     pag1fw        begsr
     *----------------------------------------------------------------
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
CBI AC                   eval      cnt8 = *zeros
     *
     *  GET 4 RECORDS TO DISPLAY
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
     *  RECORD READ - STOP AFTER 4 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 4
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
     *  PAG1BK   Let's see the previous page
     *----------------------------------------------------------------
     C     pag1bk        begsr
     *----------------------------------------------------------------
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *--> DSPLYD        ADD       7             GOBACK            2 0
     C     dsplyd        add       4             goback
CBI AC                   eval      cnt8 = *zeros
     C                   if        bot = '1'
     C                   if        goback = 4
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
     *  PAG2FW   Let's see that next page of delete records
     *----------------------------------------------------------------
     C     pag2fw        begsr
     *----------------------------------------------------------------
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
     *  GET 4 RECORDS TO DISPLAY
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
     *  RECORD READ - STOP AFTER 7 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 4
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
     *  PAG2BK   Let's see the previous page of delete records
     *----------------------------------------------------------------
     C     pag2bk        begsr
     *----------------------------------------------------------------
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       4             goback
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
     *  ROLL01   Screen 1 roll up/down routine
     *----------------------------------------------------------------
     C     roll01        begsr
     *----------------------------------------------------------------
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     *                  EXSR      SAVOPT
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *  ROLL02   Screen 2 roll up/down routine
     *----------------------------------------------------------------
     C     roll02        begsr
     *----------------------------------------------------------------
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
     *  SAVOPT   Verify and save options that were entered
     *----------------------------------------------------------------
     C     savopt        begsr
     *----------------------------------------------------------------
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   select
     C                   when      view = 1
     C                   readc     dspsfl                                 79
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
     *  SFLADD   Add record to subfile
     *----------------------------------------------------------------
     C     sfladd        begsr
     *----------------------------------------------------------------
     C                   if        reccnt < 8
     C                   add       1             reccnt
     C                   add       1             recnt2
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
     C                   add       1             cnt8
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *  SFLCLR   Clear display subfile
     *----------------------------------------------------------------
     C     sflclr        begsr
     *----------------------------------------------------------------
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *  SFLDSP   Display subfile
     *----------------------------------------------------------------
     C     sfldsp        begsr
     *----------------------------------------------------------------
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
     C                   update    dspsfl
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
     C                   endsl
     C                   if        error <> '1'
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *  SFLOPT   Initialize options for subfile
     *----------------------------------------------------------------
     C     sflopt        begsr
     *----------------------------------------------------------------
     C     1             do        7             x
     C                   select
     C                   when      view = 1
     C     x             chain     dspsfl                             79
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
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *----------------------------------------------------------------
     C     zmcmsg        begsr
     *----------------------------------------------------------------
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *----------------------------------------------------------------
     C     zmdmsg        begsr
     *----------------------------------------------------------------
     C                   write     msgclr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *----------------------------------------------------------------
     C     zmimsg        begsr
     *----------------------------------------------------------------
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *----------------------------------------------------------------
     C     zmpmsg        begsr
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *----------------------------------------------------------------
     C     zmqmsg        begsr
     *----------------------------------------------------------------
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZSCLR   Clear screen
     *----------------------------------------------------------------
     C     zsclr         begsr
     *----------------------------------------------------------------
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *----------------------------------------------------------------
     C     zmsmsg        begsr
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     C     zm0001        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *----------------------------------------------------------------
     C     zm0101        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *----------------------------------------------------------------
     C     zm0102        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *----------------------------------------------------------------
     C     zm0103        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *----------------------------------------------------------------
     C     zm0104        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105  Display a message defined at the end of pgm
     *----------------------------------------------------------------
     C     zm0105        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *----------------------------------------------------------------
     C     zm0106        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *----------------------------------------------------------------
     C     zm0107        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *----------------------------------------------------------------
     C     zm0108        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------
     C     zm9905        begsr
     *----------------------------------------------------------------
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *  ZZCMD    Process non-standard function keys
     *----------------------------------------------------------------
     C     zzcmd         begsr
     *----------------------------------------------------------------
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
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
     *  ZZCHK3   Excpscr screen error checking.
     *
     C     zzchk3        begsr
     *
     *    Verify exception location
     *
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w3whse
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
     *  Whse department can't be blank.
     *
     C                   if        w3whdp = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
     *
     *
     *  Verify warehouse department.
     *
     C                   if        w3whdp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w3whse
     C                   eval      $lwhdp = w3whdp
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
     C                   endif
     *
     * Slot can't be blank.
     *
     C                   if        w3disp = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm0203
     C                   endif
414 A*
414 A*  Call API for slot.
414 A*
414 AC                   call      @apics
414 AC                   parm                    w3disp
414 AC                   parm      5             worow
414 AC                   parm      8             wocol
414 AC                   parm                    @artn             8
414 AC                   if        @artn = '*REDSPLY'
414 AC                   eval      redspl = *on
414 AC                   goto      endck3
414 AC                   endif
     *
     *  Verify slot.
     *
     C                   if        w3disp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w3whse
     C                   eval      $lwhdp = w3whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w3disp
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for Excpscr screen.
     *
     C     zzcmd3        begsr
     *
     *    Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *    Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *  ZZDOOR   Get loading door number.
     *----------------------------------------------------------------
     C     zzdoor        begsr
     *----------------------------------------------------------------
     *
     C                   eval      dsdoor = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZEXCP   Create a "Verify Zero Slot" exception record
     *----------------------------------------------------------------
     C     zzexcp        begsr
     *----------------------------------------------------------------
     *
     C                   eval      cnt8 = *zeros
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZFGET   Get record with unique key.
     *----------------------------------------------------------------
     C     zzfget        begsr
     *----------------------------------------------------------------
     *
     *    Code to use when file key and unique key are the same.
     *
     **         FILEKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     *--> FILUKY        CHAIN(N)  RECORD                             79
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZFGTN   Get next record
     *----------------------------------------------------------------
     C     zzfgtn        begsr
     *----------------------------------------------------------------
     C     try1          tag
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade(n)  record                                 79
     *
     C                   if        *in79 = *on
     *                  End Of File, exit process
     C                   goto      endgtn
     C                   endif
     *
     *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
     C                   if        slrsrv = 'V'
     *                  Virtual Slot, Do not Display
     C                   goto      try1
     C                   endif
     *
     C     filuky        chain     vslot2                             77
     C                   if        *in77 = *off
     *                  Virtual Slot, Do not Display
     C                   goto      try1
     C                   endif
     *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
     *
     *>   FILUKY        CHAIN     VSLEXCP                            76
     *>                 IF        *IN76 = *OFF  AND
     *>                           VXPDTE = *ZEROS
     *>                 GOTO      TRY1
     *>                 ENDIF
     *
     *  Save key of pick slot record being processed.
     *
     C                   eval      svwhse = slwhse
     C                   eval      svwhdp = slwhdp
     C                   eval      svdisp = sldisp
     *
     C                   eval      svsdef = slsdef

     C                   if        sldisp = 'CA-264-1'
     C                   eval      yes = 'Y'
     C                   endif

     *
     *  Get current qty for pick slot being processed.
     *
     C                   exsr      zzgetq
     *
     *  By pass this record if pick slot curr qty is >= 5.
     *                            PickSlot
CBIaMC                   if        $pqty1 >= casqty
     *
     *  Reset key back to pick slot record being processed.
     *
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svwhdp
     C                   eval      sldisp = svdisp
     *
     C                   goto      try1
     C                   endif
     C                   eval      w1curq = $pqstr
     *
     *  Get current over stock qty for pick slot being processed.
     *
     C                   exsr      zzgetq2
     *
     *  Reset key back to pick slot record being processed.
     *
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svwhdp
     C                   eval      sldisp = svdisp
     *
     C                   eval      slsdef = svsdef
     *
     *  By pass this record if overstock slot curr qty is zero.
     *                            Over Stock Qty
     C                   if        ovrstkonhand = *zeros
     C                   goto      try1
     C                   endif
     *
     *
     *
     *  Tracking # of records dispalyed.
     C                   if        cnt8 = 7
     C                   seton                                            79
     C                   eval      cnt8 = *zeros
     C                   endif
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *  ZZFGTP   Get previous record
     *----------------------------------------------------------------
     C     zzfgtp        begsr
     *----------------------------------------------------------------
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe(n) record                                 79
CBI A*
CBI A*  Top of file
CBI AC                   if        *in79 = *on
CBI AC                   seton                                            78
CBI AC                   goto      endgtp
CBI AC                   endif
     *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
     C                   if        slrsrv = 'V'
     *                  Virtual Slot, Do not Display
     C                   goto      try2
     C                   endif
     *
     *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
     C     filuky        chain     vslot2                             77
     C                   if        *in77 = *off
     *                  Virtual Slot, Do not Display
     C                   goto      try2
     C                   endif
     *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
     *
     *>   FILUKY        CHAIN     VSLEXCP                            76
     *>                 IF        *IN76 = *OFF  AND
     *>                           VXPDTE = *ZEROS
     *>                 GOTO      TRY2
     *>                 ENDIF
     *
     *  Save key of pick slot record being processed.
     *
     C                   eval      svwhse = slwhse
     C                   eval      svwhdp = slwhdp
     C                   eval      svdisp = sldisp
     *
     C                   eval      svsdef = slsdef
     *
     *  Get current qty for pick slot being processed.
     *
     C                   exsr      zzgetq
     *
     *  By pass this record if pick slot curr qty is >= 5.
     *                            PickSlot
CBIaMC                   if        $pqty1 >= casqty
     *
     *  Reset key back to pick slot record being processed.
     *
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svwhdp
     C                   eval      sldisp = svdisp
     *
     C                   goto      try2
     C                   endif
     *
     *  Get current over stock qty for pick slot being processed.
     *
     C                   exsr      zzgetq2
     *
     *  Reset key back to pick slot record being processed.
     *
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svwhdp
     C                   eval      sldisp = svdisp
     *
     C                   eval      slsdef = svsdef
     *
     *  By pass this record if overstock slot curr qty is zero.
     *                            Over Stock Qty
     C                   if        ovrstkonhand = *zeros
     C                   goto      try2
     C                   endif
     *
     *
CBI AC                   if        cnt8 = 8
     C                   seton                                            78
     C                   eval      cnt8 = *zeros
     C                   else
     C                   add       1             cnt8
     C                   setoff                                       78
     C                   endif
     *
CBI AC     endgtp        endsr
     *----------------------------------------------------------------
     *  ZZFILL   Fill display line.
     *----------------------------------------------------------------
     C     zzfill        begsr
     *----------------------------------------------------------------
     *
     *   Clear screen fields.
     *
     C                   eval      w1slot = *blanks
     *-------------->   MOVE      *BLANKS       W1CURQ
     C                   eval      w1tihi = *zeros
     C                   eval      w1onhd = *zeros
     *                  MOVE      *BLANKS       OPTION
     *
     *  First record displayed.
     *
     C                   if        first = *on
     C                   eval      tpwhse = slwhse
     C                   eval      tpwhdp = slwhdp
     C                   eval      tpdisp = sldisp
     C                   eval      first = *off
     C                   endif
     *
     *  Load screen
     *                            PickSlot
     C                   eval      w1slot = sldisp
     *                            CurrQty
     *--------------->  EVAL      W1CURQ = $PQSTR
     *
     *
     C     sltdef        chain     slotdef                            77
     C                   if        *in77 = *off
     C     defkey        chain     itemdef                            77
     C                   if        *in77 = *off
     *                            T/HQty
     C                   eval      w1tihi   = idtie * idhigh * sdpos
     C                   endif
     C                   endif
     *                            OvrStkQty
     C                   eval      w1onhd = ovrstkonhand
     *
     *
     *
     C     endfil        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill Excpscr screen fields with info from file.
     *
     C     zzfil3        begsr
     *                       load whse, dept and blank loc input field
     C                   eval      w3whse = slwhse
     C                   eval      w3whdp = slwhdp
     C                   eval      w3disp = *blanks
     C                   endsr
     *----------------------------------------------------------------
     * ZZGETQ  Find current qty in Pick Slot being processed.
     *----------------------------------------------------------------
     C     zzgetq        begsr
     *----------------------------------------------------------------
     *
     C                   call      @sltqty
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

     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0

     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0


     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
     *
     C                   call      @cvtqty
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
     C                   endsr
     *----------------------------------------------------------------
     * ZZGETQ2 Find current qty in Pick Slot being processed.
     *----------------------------------------------------------------
     C     zzgetq2       begsr
     *----------------------------------------------------------------
     *
     *  Get available over stock qty.
     *
     C                   eval      ovrstkonhand = *zeros
     C     slt3ky        setll     slot3
     C     slt3ky        reade     slot3                                  76
     C                   dow       not *in76
     C                   if        slpick = 'N' and
     C                             slstat <> 'QU'
     C                   exsr      zzgetq
     *                            OvrStkQty
     C                   eval      ovrstkonhand = ovrstkonhand + $pqty1
     C                   endif
     C     slt3ky        reade     slot3                                  76
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------
     C     zzinz         begsr
     *----------------------------------------------------------------
     C                   eval      forevr = *on
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    tpwhse
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     *
     *  Define key for file ITEMDEF
     C     defkey        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   kfld                    slsdef
     *
     *  Define key for file SLOTDEF
     C     sltdef        klist
     C                   kfld                    slwhse
     C                   kfld                    slsdef
     *
     *  Define partial key for file SLOT3.
     *  Key used in ZZFILL Rtn.
     *
     C     slt3ky        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     *
     *  Define key for VSLEXCP file.
     *
     C     keyvex        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    w1slot
700bA*
700bA*    Define key for OPTIONS file.
700bA*
700bAC     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     *
     *  Setup option and command display lines.
     *
     C                   eval      view = 1
     C                   eval      maxvw = 2
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   eval      first = *on
CBIaA*
CBIaA*  Verify User ID.
CBIaA*
CBIaAC     #user         chain     piruser                            79
CBIaAC                   if        *in79
CBIaAC                   eval      error = *on
CBIaAC                   movel     desc(7)       errmsg
CBIaAC                   exsr      zm0105
CBIaAC                   goto      endzzi
CBIaAC                   endif
700bA*
700bA* Get quantity limit
700bA*
700bAC                   eval      kywhse = uswhse
700bAC                   eval      kycode = '*REPLEN '
700bAC     opkey         chain     options
700bA*  opkey
700bA*    Record not found. Set defaults
700bA*
700bAC                   if        not %found(options)
700bAC                   eval      oplqty = 0
700bAC                   eval      title = title1  +
700bAC                                     '00'    +
700bAC                                     title2
700bA*
700bA*    Record found. Load file data structure.
700bAC                   else
700bAC                   eval      opdta3 = opdata
700bAC                   eval      casqty = oplqty
700bAC                   eval      title = title1  +
700bAC                                     oplqtya +
700bAC                                     ' '     +
700bAC                                     title2
700bA*
700bAC                   endif
CBIaA*
CBIaMC     endzzi        endsr
     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------
     C     zzinz2        begsr
     *----------------------------------------------------------------
     C                   eval      dsfkey = $prtky
730 DC*                  eval      $kwhse = 1
730 AC                   eval      $kwhse = kywhse
     C                   move      $pwhse        tpwhse
     C                   eval      cmdchk = *blanks
     C                   eval      cmdtkn = *blanks
     C                   eval      dspls5 = *on
     *
     C                   read      pickless5                              77
     C                   if        *in77 = *off
     C                   eval      dept = slwhdp
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   else
     C                   eval      error = *on
     C                   endif
     C     endinz        endsr
     *----------------------------------------------------------------
     *
     *  Excpscr screen initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C     end03i        endsr
     *----------------------------------------------------------------
     *  ZZKEYF   Create key for file being used
     *----------------------------------------------------------------
     C     zzkeyf        begsr
     *----------------------------------------------------------------
     C                   eval      $pofky = dsfkey
     C                   endsr
     *
     *----------------------------------------------------------------
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *----------------------------------------------------------------
     C     zzkeyu        begsr
     *----------------------------------------------------------------
     C                   eval      $pouky = dsukey
     C                   endsr
     *
     *----------------------------------------------------------------
     *  ZZOPT    Process non-standard options.
     *           Note: Error handling is done in routine OPTNS2.
     *----------------------------------------------------------------
     C     zzopt         begsr
     *----------------------------------------------------------------
     *
     C                   eval      $perm = *blanks
     C                   eval      $prtn = *blanks
     *
     C                   select
     *
     *   Selected Over Stock.
     *
710aAC                   when           client = cheney
710aAC                             and (cliloc = cbigo
710aAC                             or   cliloc = cbigr
710aAC                             or   cliloc = cbist)
710aAC                             and  wkoopt = ' 1'
710aAC                   eval      slt1 = %subst(w1slot:1:2)
710aAC                   eval      slt2 = %subst(w1slot:4:2)
710aAC                   eval      slt3 = %subst(w1slot:7:2)
710aAC                   eval      $pslot = *blanks
710aAC                   cat       slt1:0        $pslot
710aAC                   cat       slt2:0        $pslot
710aAC                   cat       slt3:0        $pslot
710aAC                   eval      nxtscr = 'EOJ'
730 Ac                   eval      fulldisp=*blanks
     *
     C                   when      wkoopt = ' 1'
     C                   eval      slt1 = %subst(w1slot:1:2)
     C                   eval      slt2 = %subst(w1slot:4:3)
     C                   eval      slt3 = %subst(w1slot:8:2)
     C                   eval      $pslot = *blanks
     C                   cat       slt1:0        $pslot
     C                   cat       slt2:0        $pslot
     C                   cat       slt3:0        $pslot
     C                   eval      nxtscr = 'EOJ'
730 Ac                   eval      fulldisp=w1slot
     *
     *   Over Stock location found to have an unlisted pallet,
     *   write a "verify zero" exception record.
     *
     C                   when      wkoopt = ' X'
     C                   eval      slot# = w1slot
     C                   eval      dept = slwhdp
730 Ac                   eval      fulldisp=*blanks
     C                   exsr      zzexcp
     *
     C                   endsl
730 A /free
730 A      // When not Cheney check to see if full slot displayed is
730 A      // is virtual and return base if it is
730 A      if client <> cheney;
730 A        chain (slwhse:slwhdp:w1slot) vslot1;
730 A        if %found(vslot1);
730 A          fulldisp=w1slot;
730 A        endif;
730 A      else;
730 A        fulldisp=*blanks;
730 A      endif;
730 A /end-free
     *
     C     endopt        endsr
     *----------------------------------------------------------------
     *  ZZPOS    Position to a different record.
     *----------------------------------------------------------------
     C     zzpos         begsr
     *----------------------------------------------------------------
     *
     *  See if user is trying to position to code
     *
     C                   setoff                                       03
     C     filuky        chain(n)  record                             79
     C                   if        not *in79
     C                   endif
     C                   eval      repos = *on
     C                   seton                                        03
     C     endzps        endsr
     *----------------------------------------------------------------
     *  ZZPOS2   Position to record
     *----------------------------------------------------------------
     C     zzpos2        begsr
     *----------------------------------------------------------------
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
     C     filuky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     filuky        setgt     record
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for Excpscr screen.
     *
     C     zzupd3        begsr
     C                   eval      slot# = w3disp
     C                   eval      dept = w3whdp
     C                   exsr      zzexcp
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
     1
**  CMDLN - Command display line
F3/F12=Exit  F5=Refresh
**  DESC - Message
Item being processed is not slotted
Dept
Slot
Slot has been replenished, not loger < 5 cases
Slot does not longer exist
Not pick slot to replenish found
User Id not found in PIRUSER.
