     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GS122     GS1 weight Entry - Change
     *  10 January 2020
     *  Lynn McMahon
     *  Created using CW112
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    01/10/20  LMC  7.40
     *      - Created.
740aA*    02/13/20  LMC  7.40a
     *      - Date Edit indicator was being setoff
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
740aDF*GS122FM   cf   e             workstn
740aMFGS12201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpiritem   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#UCIINFO
     D saveVer#        s                   like($uiver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(9) ctdata perrcd(1)
     D cmdln           s             79    dim(3)ctdata perrcd(1)
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
     D  $pwhse                19     20p 0
     D  $ppo                  21     29
     D  $pseq                 30     32p 0
     D  $pitem                33     47

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
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
     D  $lbld                 19     20
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPWRNCR -  Check CW variance during Rcv inividual entry(Y,N)
     *    OPICWR  -  Check CW count during Rcv individual entry (Y,N)
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
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D ck4err          s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D cweck           s              1
     D cwtck           s              1
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D extwg2          s                   like(exwgt)
     D extwg3          s                   like(exwgt)
     D exwgt           s              9  2
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hvskp           s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D IMkilolbs       s              1
     D IMUom           s              3
     D KiloLbs         s              1
     D lstseq          s              5  0
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D olywg2          s                   like(itswgt)
     D olywg3          s                   like(itswgt)
     D ovrrid          s              1
     D posrec          s              4  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svaddw          s              7  0
     D svcw#           s              7  0
     D svtcw           s              9  2
     D taddw           s              7  2
     D totrcv          s              3  0
     D twtck           s              1
     D uciexists       s               n
     D unexta          s             13
     D warn            s              1
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D wttcw           s              7  2
     D w1addw          s              7  0
     D wgt7            s              7
     D wgt8            s              8
     D zmflag          s               n
     D zmsflag         s               n

     D msg             s             99
     D sess            s             40
     D userid          s             10
     D dic             s             10
     D prog            s             10
     D loc             s             10
     D pp1             s            999
     D pp2             s            999
     D pp3             s            999
     D today           s              8  0
     D ckdt            s              8  0
     D mfgdt           s              6  0
     D expdt           s              6  0

     D PO              s              9
     D POSeq           s              5p 0
     D POItem          s             15
     D jobq            s              5
     D chrWhse         s              3
     D chrseq          s              5
     D session         s             40
     D poutstr         s           1024    varying
     D howmany         s              5  0
     D i               s              5  0
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const
     D m29600          pr                  extpgm('M29600')
     D  message                      99
     D  session                      40
     D  user                         10
     D  dict                         10
     D  pgm                          10
     D  objloc                       10
     D  parm1                       999
     D  parm2                       999
     D  parm3                       999
     D r33500          pr                  extpgm('R33500')
     D  sendwhse                      3
     D  pPo                           9
     D  pOutStr                    1024    varying
     D  pJobq                         5
     D  pItem                        15
     D  sendseq                       5
     D  session                      40

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *              *CHANGEP - Change during post from PT132.
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
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     *
     C                   exsr      zzinz2
     *
     C                   if        error = *on
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
     C                   eval      *inlr = *on
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
     C                   when      nxtscr = '03 '
     C                   exsr      sfldsp
     C                   read      head1                                  50
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
740aDC*                  setoff                                       212223
740aMC                   setoff                                       21  23
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *on
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
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   eval      ovrrid = *off
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     C     end03i        endsr
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
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     redspl        cabeq     *on           endsc2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F7 - kilograms/Pounds toggle
     *
     C                   if        *inkg
     C                   eval      cmdtkn = *on
     C                   if        KiloLbs = 'P'
     C                   eval      KiloLbs = 'K'
     C                   eval      W1KgLb  = 'Kgs'
     C                   else
     C                   eval      KiloLbs = 'P'
     C                   eval      W1KgLb  = 'Lbs'
     C                   endif
     C                   select

     C                   when      KiloLbs = 'K'
     C                   eval      cmdln1 = cmdln(2)

     C                   when      KiloLbs = 'P'
     C                   eval      cmdln1 = cmdln(1)

     C                   endsl
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     redspl        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc3        endsr
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
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   eval      *in85 = *on
     C                   write     detail1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   if        reccnt > 12
     C                   eval      posrec = reccnt
     C                   endif
     C                   eval      recno = posrec
     C                   write     head1
     C                   endsr
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
     C                   eval      $msgf = #msgf
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
     C                   write     clrscr
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
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
     *    ZMnnnn  Build and send message nnnn to this program
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13019  # of catch weights entered must = Quantity picked.
     *
     C     zm20          begsr
     C                   eval      #msgid = 'PT13020'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13020  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     *   CWTCK Flags are used to force F20 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     *
     C                   eval      $cbbar = w1wgt
     C                   call      'CVTBAR'
     C                   parm      '*CWGTLBS'    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm      *zeros        $cbcod            3 0
     C                   parm      *zeros        $cbdec            1 0
     C                   parm      *blanks       $cbdsc           30
     C                   parm      *zeros        $cbpos            3 0
     C                   parm      *zeros        $cbtyp            1 0
     C                   parm      *zeros        $cbv1            11 3
     C                   parm      *blanks       $cbv2            50
     C                   parm      *blanks       $cbrtn            8
     C                   parm      *blanks       $cberm           60
     C                   parm      0             $cbven           10 0
     C                   parm                    $cvtdata        256
     C                   parm                    $cvtdata2       256
     C                   parm      $pwhse        $cbwhse           3 0
     C                   parm      kilolbs       $cbsent           1
     *
     *    Weight converted successfully.
     C                   select
     C                   when      $cbrtn = '*OK'
     C     $cbv1         mult      100           w1addw
     *
     *    Error occured while converting weight.
     C                   other
     C                   eval      error = *on
     C                   eval      *in17 = *on
     C                   eval      *in37 = *on
     C                   movel     $cberm        errmsg
     C                   exsr      zm0105
     C                   goto      endck3
     C                   endsl
     *
     *   Verify date is entered.
     *
     C                   if        w1addw  > 0 and *in22=*off and datein = 0
     c                   eval      error = *on
     c                   eval      errmsg = 'Date is required'
     c                   exsr      zm0105
     C                   goto      endck3
     C                   endif
     *
     *     Verify date
     *
     C                   if        w1addw  > 0 and *in22=*off and datein <>0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      datein        $cvd6i
     c                   eval      $cvprg  = #prog
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     c                   goto      endck3
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zm9906
     c                   goto      endck3
     C                   else
     C                   endif
     C                   endif
     *
     *     convert for edits
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      datein        $cvd6i
     c                   eval      $cvprg  = #prog
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     c                   MOVE      $CVD8O        ckdt
     *
     *     edit mfg date
     c                   if        *in22 = *off and immflg = 'Y'
     c                   if        ckdt > today
     c                   eval      error = *on
     c                   eval      errmsg = 'Mfg Date greater than today.'
     c                   exsr      zm0105
     C                   goto      endck3
     c                   endif
     c                   endif
     *
     *     edit exp date
     c                   if        *in22 = *off and immflg = 'N'
     c                   if        ckdt < today
     c                   eval      error = *on
     c                   eval      errmsg = 'Exp Date is less than today.'
     c                   exsr      zm0105
     C                   goto      endck3
     c                   endif
     c                   endif
     C                   endif
     *
     *
     *   Verify catch weight add.
     *
     C                   if        w1addw <> *zero
     *
     C                   if        svaddw <> w1addw
     C                   eval      cwtck = *off
     C                   endif
     *
     C                   if        cwtck = '2'  and
     C                             ovrrid = *on
     C                   eval      cwtck = *on
     C                   endif
     *
     C                   if        cwtck <> '1'
     C                   eval      cwtck = *on
     *
     *     Verify catch weight is within range.
     *
     C                   if        w1addw < 0  or
     C                             w1addw > 9999999
     C                   eval      error = *on
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '9999999'     erto
     C                   exsr      zm0112
     C                   endif
     *
     *     Check individual CW if variance check = Y.
     *
     C                   if        opwrncr = 'Y'
     C                             and opicwr = 'Y'
     C     w1addw        div       100           taddw
     *
     C                   if        lvskp = *off  and
     C                             taddw < ilrng
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
     C                   eval      erlrng = ilrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = ihrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   exsr      zm19
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             taddw > ihrng
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = ilrng
     C                   endif
     C                   eval      erhrng = ihrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   exsr      zm19
     C                   endif
     *
     *
     C                   endif
     *
     C                   endif
     C                   endif
     *
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in19 = *off
     C                   eval      *in20 = *off
     C                   eval      *in39 = *off
     C                   eval      *in40 = *off
      /free
        // user has requested to delete this entry
        if w1wgtlbs = 0 and w1uci <> ' ';
          // format data for M29600 to process
          msg  = ' ';
          sess = #user + #jobn;
          userid = #user;
          dic    =  ' ';
          prog   = #prog;
          loc   = ' ';
          pp1 = 'MODE=D|UIWWHSE=' + %editC(%Dec($PWHSE:3:0):'X') +
                '|UIWPO=' + $PPO +
                '|UIWPOSEQ=' + %editC(%Dec($Pseq:5:0):'X') +
                '|UIWITEM=' + $pitem   +
                '|UIWUCI=' + w1uci;
          pp2   = ' ';
          pp3   = ' ';
          M29600(msg:sess:userid:dic:prog:loc:pp1:pp2:pp3);
          w1uci = ' ';
        endif;
      /end-free
     *
     *
     *      Verify right definition.
     *
     C                   eval      *in85 = *on
     C                   update    detail1
     C                   if        posrec = 0
     C                   if        *in38  or
     C                             *in39
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     *   Save screen fields.
     C                   eval      svaddw = w1addw
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 1.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     *      F10 - print  and close
     *
     C                   if        *inkj
     C                   eval      redspl = *off
     c                   eval      $prtn = '*EXIT   '
      /free
         pOutStr = ' ';
         // Convert numeric fields into character fields
         chrWhse = %editc($pwhse: 'X');
         PO      = %trim($ppo);
         POItem  = %trim($pItem);
         session = #user + #jobn;
         chrseq = %editc($pseq: 'X');

         r33500(chrWhse :
                 PO :
                 pOutStr :
                 jobq :
                 POItem :
                 chrseq  :
                 session);

      /end-free
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     C                   eval      w1addw = 0
     C                   eval      lstseq = 0
     *
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   eval      w1wgt = *blanks
     *
     *    Compute total qty received.
     C                   eval      wopo = $ppo
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   movel     itdesc        wodesc
     C                   else
     C                   eval      wodesc = *blanks
     C                   eval      itumq2 = *zeros
     C                   eval      itumq3 = *zeros
     C                   endif
     c
     *
     *    Convert weight for break-down 2 qty.
     C                   if        itumq2 > *zeros
     C     itswgt        div(h)    itumq2        olywg2
     C                   else
     C                   eval      olywg2 = *zeros
     C                   endif
     *
     *    Convert weight for break-down 3 qty.
     C                   if        itumq3 > *zeros
     C     itswgt        div(h)    itumq3        olywg3
     C                   else
     C                   eval      olywg3 = *zeros
     C                   endif
     *
     *
     *   If verify catch weight = yes,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     C                   if        opwrncr = 'Y'
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     *
     *
     *    Extend weight for break-down 2 qty.
     C                   if        olywg2 > *zeros
     C                   else
     C                   eval      extwg2 = *zeros
     C                   endif
     C                   add       extwg2        exwgt
     *
     *    Extend weight for break-down 3 qty.
     C                   if        olywg3 > *zeros
     C                   else
     C                   eval      extwg3 = *zeros
     C                   endif
     C                   add       extwg3        exwgt
     *
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
     C     imkey         chain     itemmsc                            79
     C                   if        not *in79
     c                   if        ITFLGD <> 'Y'
     c                   eval      *in22 = *on
     c                   eval      *in02 = *on
     c                   else
     c                   if        IMMFLG = 'Y'
     c                   eval      datetp = 'Mfg Date:'
     c                   else
     c                   eval      datetp = 'Exp Date:'
     c                   endif
     c                   endif
     *
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
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     itswgt        add       ihvar         ihrng
     *
     c                   else
     C     imkey         chain     itemmsc                            79
     C                   if        not *in79
     c                   if        ITFLGD <> 'Y'
     c                   eval      *in22 = *on
     c                   eval      *in02 = *on
     c                   else
     c                   if        IMMFLG = 'Y'
     c                   eval      datetp = 'Mfg Date:'
     c                   else
     c                   eval      datetp = 'Exp Date:'
     c                   endif
     c                   endif
     c                   endif
     C                   endif
     *
     C                   eval      w1addw = *zeros
     *
     C                   exsr      sflclr
     *
     *    Move decimal point 2 places to the right for display.
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   endif
     *
     *  Record locked.
     *
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt1
     C                   endif
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C                   exsr      zzget1
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *  Define full key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define full key for item file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Get current dates for edits.
     *
     c
     C                   eval      $cvcmd = '*CURCMD '
     c                   eval      $cvprg  = #prog
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Check for *CHANGEP
     *
     C                   if        $pcmd = '*CHANGEP'
     C                   eval      $pcmd = '*CHANGE '
     C                   eval      *in92 = *on
     C                   else
     C                   eval      *in92 = *off
     C                   endif
     *
     *   Get Item Maintenance options.
     *
      /free
        getimuom($pwhse: IMkilolbs: IMUom);
          select;
            when IMkilolbs = 'K';
              KiloLbs = 'K';
              W1KgLb  = IMUom;
              cmdln1 = cmdln(2);
            other;
              KiloLbs = 'P';
              W1KgLb  = 'Lbs';
              cmdln1 = cmdln(1);
          endsl;
      /end-free
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrncr = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicwr = 'N'
     C                   endif
     *   Initialize counter and total fields.
     C                   eval      wocw# = 0
     C                   eval      wotcw = 0
     C                   eval      lstseq = 0
     C                   eval      w1addw = *zeros
     C                   eval      cwtck = *off
     C                   eval      cweck = *off
     C                   eval      twtck = *off
     *
     *   Select first screen to display.
     *
     C                   exsr      scr03i
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
     *   Loop through subfile records and recaluclate.
     C                   if        reccnt > 0
     C                   eval      *in85 = *on
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in85 = *on
     C                   update    detail1
     *
     C     w1wgtlbs      div       100           wttcw
     C                   add       wttcw         wotcw
     C                   if        wttcw > 0
     C                   add       1             wocw#
     C                   endif
     C                   enddo
     C                   eval      *in85 = *off
     C                   endif
     *
     C                   endsr
     *
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Determine which screen to display next.
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
      /free
        if gs1mul = 0;
          howmany = 1;
        else;
          howmany = gs1mul;
        endif;
        for i = 1 TO howmany;
          if w1addw <> *zero;
            // format data for M29600 to process
            msg  = ' ';
            sess = #user + #jobn;
            userid = #user;
            dic    =  ' ';
            prog   = #prog;
            select;
              when immflg = 'Y';
                mfgdt  = datein;
              when itflgd = 'Y';
                expdt  = datein;
            endsl;
            loc   = ' ';
            wgt7 = %editC(%Dec(w1addw:7:0):'X');
            wgt8 = %subst(wgt7:1:5) + '.' + %subst(wgt7:6:2);
            pp1 = 'MODE=A|UIWWHSE=' + %editC(%Dec($PWHSE:3:0):'X') +
                  '|UIWPO=' + $PPO +
                  '|UIWPOSEQ=' + %editC(%Dec($Pseq:5:0):'X') +
                  '|UIWITEM=' + $pitem   +
                  '|UIWUCI=|UIWWGTLBS=' + wgt8 +
                  '|UIWEXPDT=' + %editC(%Dec(EXPDT:6:0):'X')           +
                  '|UIWMFGDT=' + %editC(%Dec(MFGDT:6:0):'X');
            pp2   = ' ';
            pp3   = ' ';
            M29600(msg:sess:userid:dic:prog:loc:pp1:pp2:pp3);
          endif;

          // if user is adding a detail record...
          //  - add it to subfile and return to entry screen
          if w1addw <> *zero;
            lstseq = lstseq + 1;
            w1seq = lstseq;
            if msg <> ' ';
              w1uci = msg;
              msg = ' ';
            endif;

            W1WGTLBS = w1addw;
            w1ent = w1wgt;
            *in85 = *on;
            exsr sfladd;
            if I = howmany;
              exsr zztotl;
              w1addw = 0;
              gs1mul = 0;
              w1wgt = ' ';
              *in17 = *on;
              redspl = *on;
              ovrrid = *off;
              leavesr;
            endif;
          endif;
        endfor;
      /end-free
     *
     *  Update detail first.
     *
     C                   exsr      zztotl
     C                   if        reccnt >= 0
     C     error         cabeq     *on           endup3
     C     error         cabeq     *on           endup3
     C                   endif
     *
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C                   endsl


     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      ck4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

     C                   when      ck4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0001s
     C                   when      zmflag
     C                   exsr      zm0001
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C                   endsl

     C                   eval      ck4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Catch weight
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
UCI Barcode
**  CMDLN - Command display line
F5=Refresh  F7=Kilograms  F12=Cancel  F20=Accept Warning  F10=Done
F5=Refresh  F7=Pounds  F12=Cancel  F20=Accept Warning  F10=Done
F5=Refresh  F12=Cancel  F20=Accept Warning  F10=Done
