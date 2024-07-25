     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CW122     P/O Catch weight maint - Change
     *  11 April 2001
     *  Max Blacknik
     *  Created using CW112
     *  Changed to only use SC3
     *
     *  SK112 - 1.02
     *
     *----------------------------------------------------------------
     *  Revisions
     *
415 A*    04/11/01  MLB  4.15
     *      - Created.
416 A*    07/02/02  RH   4.16
     *      - Recompiled, ITEMMSC changed.
     *
417aA*    04/03/03  RH   4.17a
     *      -  ENH: Recompiled, ITEMMSC file changed.
417bA*    03/19/04  MLB  4.17b
     *      - Fix: Revise program to not allow catchwgts entered
     *        to exceed quantity received.
530 A*    05/13/10  JCJ  5.30
     *      - Fix: Revised ZZCHKT to only check for the individual
     *        catch weight flag.
     *      - Enh: Add new catch weight options.
650aA*    07/25/14  LMC  6.50a
     *      - Enh: Store detail weight scan/entry in the uciinfo file.
700aA*    04/30/15  LMC  7.00a
     *      - Fix: change to store the seq# from UISEQ to UISELCSEQ
     *        YHATA receives more than 99 cases on pallets, and the
     *        UISEQ field is only 2 positions, this is used as on
     *        temporary basis in order to update weights if needed
     *        with the temporary license nubmer. Once the License is
     *        entered, we remove this values in the UISELCSEQ field.
700bA*    03/22/16  LMC  7.00b
     *      - Enh: Adding logic for Metric.
     *      - Fix: When weight was zerored out on the subfile prior
     *        to writing to the file, we were still writing a zero
     *        weight record, conditioned the write if weight <> 0
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
650aDF*cw122fm   cf   e             workstn
700bDF*cw12201   cf   e             workstn
700bMFcw12202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     Fpocwtmp   uf a e           k disk
     F                                     rename(pcwrec:record2)
     Fwarehs    if   e           k disk
     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpiritem   if   e           k disk

700bA*----------------------------------------------------------------
700bA* Function prototypes.
700bA*----------------------------------------------------------------

700bA /copy qcopysrc,p.getimuom

650aA*----------------------------------------------------------------
650aA*  DRI parameters
650aA*----------------------------------------------------------------

650aA /COPY *libl/qcopysrc,C#DRIPARMS

650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------

650aA /COPY *libl/qcopysrc,C#UCIINFO
650aAD saveVer#        s                   like($uiver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
650aDD*desc            s             50    dim(8) ctdata perrcd(1)
650aMD desc            s             50    dim(9) ctdata perrcd(1)
700bAD cmdln           s             79    dim(3)ctdata perrcd(1)
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
     D  $pqyr1                48     50p 0
     D  $pqyr2                51     53p 0
     D  $pqyr3                54     56p 0
     D  $pcwte                57     59p 0
     D  $pcwtt                60     64p 2
     D  $pcwta                65     68p 2
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
530aD*****OPWRNC  -  Perform catch weight variance check (Y,N).
530aM*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
530aD*****OPICW   -  Individual catch weight entry (Y,N).
530aM*    OPICW   -  Check CW count during selection closing (N,M,C,B)
530aM*    OPWRNCR -  Check CW variance during Rcv inividual entry(Y,N)
530aM*    OPICWR  -  Check CW count during Rcv individual entry (Y,N)
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
530bAD  opuci                 36     36
530aAD  opwrncr               37     37
530aAD  opicwr                38     38
     D  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
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
650aAD $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
650aAD ck4err          s               n
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
700bAD IMkilolbs       s              1
700bAD IMUom           s              3
700bAD KiloLbs         s              1
     D lstseq          s                   like(pcwsq2)
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
     D totrcv          s                   like($pcwte)
     D twtck           s              1
650aAD uciexists       s               n
650aAD unexta          s             13
     D warn            s              1
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D wttcw           s              7  2
     D w1addw          s              7  0
650aAD zmflag          s               n
650aAD zmsflag         s               n
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aAD ucilic#         pr                  extpgm('UCILIC#')
650aA * Input
650aAD   unext                       13  0 const
650aAD   uwhse                        3  0 const
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
     *
     **         NXTSCR    WHEQ '01 '
     *R                   EXFMTSCREEN1
     *
     *R         NXTSCR    WHEQ '02 '
     *R                   EXFMTSCREEN2
     *
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
     C                   setoff                                       212223
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
     *R         *LOVAL    SETLLRECORD
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC1
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
     *R         *LOVAL    SETLLRECORD
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*CANCEL '$PRTN
     *R                   GOTO ENDSC1
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
     *R         *LOVAL    SETLLRECORD
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC2
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
     *R         *LOVAL    SETLLRECORD
     *R         $PCMD     IFEQ '*ADD    '
     *R                   MOVE '01 '     NXTSCR
     *R                   ELSE
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   ENDIF
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
700bA*
700bA*  Test for F7 - kilograms/Pounds toggle
700ba*
700bAC                   if        *inkg
700bAC                   eval      cmdtkn = *on
700bAC                   if        KiloLbs = 'P'
700bAC                   eval      KiloLbs = 'K'
700bAC                   eval      W1KgLb  = 'Kgs'
700bAC                   else
700bAC                   eval      KiloLbs = 'P'
700bAC                   eval      W1KgLb  = 'Lbs'
700bAC                   endif
700bAC                   select

700bAC                   when      KiloLbs = 'K'
700bAC                   eval      cmdln1 = cmdln(2)

700bAC                   when      KiloLbs = 'P'
700bAC                   eval      cmdln1 = cmdln(1)

700bAC                   endsl
700bAC                   goto      endsc3
700bAC                   endif
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
650aA*----------------------------------------------------------------
650aA*  clr$uciinfo  Clear $uciinfo data structure fields
650aA*----------------------------------------------------------------

650aAC     clr$uciinfo   begsr
650aAC                   eval      savever# = $uiver#
650aAC                   clear                   $uciinfo
650aAC                   eval      $uiver# = savever#
650aAC                   eval      $uiaddemp = 0
650aAC                   eval      $uiaddusr = #user
650aAC                   eval      $uiaddpgm  = #prog
650aAC                   eval      $uiaddjob  = #job
650aAC                   eval      $uiaddnbr = #jobn
650aAC                   endsr

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
650aA*----------------------------------------------------------------
650aA*    DRI0001  Local system caused error
650aA*----------------------------------------------------------------

650aAC     zm0001        begsr
650aAC                   if        %subst($drimessage:1:2) = 'H:'
650aAC                   move      'DRI0002'     #msgid
650aAC                   eval      $drimessage = %subst($drimessage:3)
650aAC                   else
650aAC                   move      'DRI0001'     #msgid
650aAC                   endif
650aAC                   eval      #msgtp = '*DIAG'
650aAC                   eval      #msgdt = $drimessage + $drireturn
650aAC                                    + $dricommand + $drisubcmd
650aAC                   exsr      zmpmsg
650aAC                   endsr
650aA*----------------------------------------------------------------
650aA*    DRI0001s Local system caused error (send to different program)
650aA*----------------------------------------------------------------

650aAC     zm0001s       begsr
650aAC                   if        %subst($drimessage:1:2) = 'H:'
650aAC                   move      'DRI0002'     #msgid
650aAC                   eval      $drimessage = %subst($drimessage:3)
650aAC                   else
650aAC                   move      'DRI0001'     #msgid
650aAC                   endif
650aAC                   eval      #msgtp = '*DIAG'
650aAC                   eval      #msgdt = $drimessage + $drireturn
650aAC                                    + $dricommand + $drisubcmd
650aAC                   exsr      zmsmsg
650aAC                   eval      $pmsg = #msgk
650aAC                   endsr

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
700bAC                   parm      0             $cbven           10 0
700bAC                   parm                    $cvtdata        256
700bAC                   parm                    $cvtdata2       256
700bAC                   parm      $pwhse        $cbwhse           3 0
700bAC                   parm      kilolbs       $cbsent           1
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
530 D ***                if        opwrnc = 'Y'  and
530 D ***                          opicw = 'Y'
530 MC                   if        opwrncr = 'Y'
530 MC                             and opicwr = 'Y'
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
     *  ZZCHKT   Screen 3 error check totals
     *
     C     zzchkt        begsr
     *   CWECK, TWTCK Flags are used to force F20 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
530 D ***                if        opwrnc = 'Y'  and
530 MC                   if        opicwr = 'Y'
     *
     C                   if        svcw# <> wocw#
     C                   eval      cweck = *off
     C                   endif
     *
     C                   if        cweck = '2'  and
     C                             ovrrid = *on
     C                   eval      cweck = *on
     C                   endif
     *
     C                   if        cweck <> '1'
     C                   eval      cweck = *on
     *
     C                   if        wocw# <> totrcv
     C                   eval      posrec = 1
     C                   eval      error = *on
417bA*    Nbr catchwgts entered cannot exceed quantity received.
417bAC                   if        wocw# > totrcv
417bAC                   eval      cweck = *off
417bAC                   else
     C                   eval      cweck = '2'
417bAC                   endif
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     wocw#         ertcw#
     C                   eval      erqpck = totrcv
     C                   exsr      zm20
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
     C                   endif
     *
     *
     *
     *     Compare total catchweight to expected catchweight
     *
530 D ***                if        opwrnc = 'Y'
530 MC                   if        opwrncr = 'Y'
     *
     C                   if        svtcw <> wotcw
     C                   eval      twtck = *off
     C                   endif
     *
     C                   if        twtck = '2'  and
     C                             ovrrid = *on
     C                   eval      twtck = *on
     C                   endif
     *
     C                   if        twtck <> '1'
     C                   eval      twtck = *on
     *
     *
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      posrec = 1
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   exsr      zm19
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                   eval      posrec = 1
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   exsr      zm19
     C                   endif
     *
     C     error         cabeq     *on           enderr
     C                   endif
     *
     C                   endif
     C     enderr        tag
     *   Save screen fields.
     C                   eval      svcw# = wocw#
     C                   eval      svtcw = wotcw
     *
     C                   endsr
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
     *
     *     Build code.
     *
     C                   select
     *
     *
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
     C     $pqyr1        add       $pqyr2        wopqty
     C                   add       $pqyr3        wopqty
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
530 D ***                if        opwrnc = 'Y'
530 MC                   if        opwrncr = 'Y'
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
     *    Extend weight for case qty.
     C     $pqyr1        mult      itswgt        exwgt
     *
     *    Extend weight for break-down 2 qty.
     C                   if        $pqyr2 > *zeros
     C                   if        olywg2 > *zeros
     C     $pqyr2        mult      olywg2        extwg2
     C                   else
     C                   eval      extwg2 = *zeros
     C                   endif
     C                   add       extwg2        exwgt
     C                   endif
     *
     *    Extend weight for break-down 3 qty.
     C                   if        $pqyr3 > *zeros
     C                   if        olywg3 > *zeros
     C     $pqyr3        mult      olywg3        extwg3
     C                   else
     C                   eval      extwg3 = *zeros
     C                   endif
     C                   add       extwg3        exwgt
     C                   endif
     *
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
     C     imkey         chain     itemmsc                            79
     C                   if        not *in79
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
     C                   endif
     *
     C                   eval      w1addw = *zeros
     *
     C                   exsr      sflclr
     C     cwkeyp        setll     pocwtmp
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     cwkeyp        reade(n)  pocwtmp                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   add       pcwwgt        wotcw
     C                   add       1             wocw#
     C                   z-add     pcwsq2        w1seq
     *
     *    Move decimal point 2 places to the right for display.
     C                   move      pcwwgt        w1cwgt
650aA *this need to be loaded from uci if we are doing update
650aAC                   eval      w1ent = w1wgt
     C                   exsr      sfladd
     C                   eval      lstseq = pcwsq2
     C                   endif
     C                   enddo
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
     *R         FILEKY    CHAINRECORD              N7978
     *R                   ELSE
     *R         FILEKY    CHAINRECORD               7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     *R                   EXSR ZM74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     *R                   EXSR ZM73
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
     *R                   EXSR ZZGET1
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
     *  Define full key for detail file.
     *
     C     cwkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    pcwpo
     C                   kfld                    pcwseq
     C                   kfld                    pcwsq2
     *
     *  Define partial key for detail file.
     *
     C     cwkeyp        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
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
700bA*
700bA*   Get Item Maintenance options.
700bA*
700bA /free
700bA   getimuom($pwhse: IMkilolbs: IMUom);
700bA     select;
700bA       when IMkilolbs = 'K';
700bA         KiloLbs = 'K';
700bA         W1KgLb  = IMUom;
700bA         cmdln1 = cmdln(2);
700bA       other;
700bA         KiloLbs = 'P';
700bA         W1KgLb  = 'Lbs';
700bA         cmdln1 = cmdln(1);
700bA     endsl;
700bA /end-free
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
530 D ***                eval      opwrnc = 'N'
530 MC                   eval      opwrncr = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
530 D ***                eval      opicw = 'N'
530 MC                   eval      opicwr = 'N'
     C                   endif
     *
     *
     *    Define working variables.
     *
     *    Compute total qty received.
     C     $pqyr1        add       $pqyr2        totrcv
     C                   add       $pqyr3        totrcv
     *
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
     *R         $PCMD     IFEQ '*ADD    '
     *R                   MOVE *BLANKS   $PWHDP
     *R                   MOVE *BLANKS   $PAISL
     *R                   MOVE *BLANKS   $PSTYP
     *R                   EXSR SCR01I
     *R                   ELSE
     *R         $PSTYP    IFEQ 'P'
     *R                   EXSR SCR02I
     *R                   ELSE
     C                   exsr      scr03i
     *R                   ENDIF
     *R                   ENDIF
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
     C     w1cwgt        div       100           wttcw
     C                   add       wttcw         wotcw
     C                   if        wttcw > 0
     C                   add       1             wocw#
     C                   endif
     C                   enddo
     C                   eval      *in85 = *off
     C                   endif
     *
     C                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZUCIADD Add weight record to uciinfo.
650aA*
650aAC     zzuciadd      begsr
650aA /free
650aA   exsr clr$uciinfo;
650aA   $uiWhse = $pwhse;
650aA   $uiItem = $pitem;
650aA   $uiuci = w1ent;
650aA   ucilic#($unext: $pwhse);
650aA   unexta = %editc($unext:'X');
650aA   $uiuciLcns = 'U:' + unexta;
650aA   $uiLcns = 'T' + $ppo + %editc($pseq:'X');
700aD   //$uiseq = w1seq;
700aM   $uiseq = 1;
700aA   $uiselcseq  = w1seq;
650aA   $uiSerial = ' ';
650aA   $uiwgtlbs = pcwwgt;
650aA   $uiWgtKgs = 0;
650aA   $uiSelTrn# = 0;
650aA   $uiSelLbl# = 0;
650aA   $uiSelOrd = 0;
650aA   $uiSelSeq = 0;
700aD   //$uiSelCSeq = 0;
650aA   $uiSelTrax = ' ';
650aA   $uiCrtBy = '6';

650aA   $dricommand = '*UCIINFO';
650aA   $drisubcmd  = '%ADD';
650aA   $drisys2upd = 'D';
650aA   ck4err = *on;
650aA   zmflag  = *off;
650aA   exsr zzzdricop;
650aA   if error = *on;
650aA     uciExists = *on;
650aA     error = *on;
650aA     errmsg= desc(9);
650aA     exsr zm02;
650aA     leavesr;
650aA   else;
650aA     UciExists = *off;
650aA     error = *off;
650aA   endif;
650aA /end-free
650aAC                   endsr
     *
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZUCIDEL Delete weight record from uciinfo.
650aA*
650aAC     zzucidel      begsr
650aA /free
650aA   exsr clr$uciinfo;
650aA   $uiWhse = $pwhse;
650aA   $uiuci = w1ent;
650aA   $uiLcns = 'T' + $ppo + %editc($pseq:'X');
700aD   //$uiseq = w1seq;
700aM   $uiseq = 1;
700aA   $uiselcseq = w1seq;

650aA   $dricommand = '*UCIINFO';
650aA   $drisubcmd  = '%DELETECW';
650aA   $drisys2upd = 'D';
650aA   ck4err = *on;
650aA   zmflag  = *off;
650aA   exsr zzzdricop;
650aA /end-free
650aAC                   endsr
     *
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZUCIUPD Update weight record - uciinfo.
650aA*
650aAC     zzuciupd      begsr
650aA /free
650aA   exsr clr$uciinfo;
650aA   $uiWhse = $pwhse;
650aA   $uiLcns = 'T' + $ppo + %editc($pseq:'X');
700aD   //$uiseq = w1seq;
700aM   $uiseq = 1;
700aA   $uiselcseq  = w1seq;
650aA   $uiwgtlbs = pcwwgt;

650aA   $dricommand = '*UCIINFO';
650aA   $drisubcmd  = '%UPDATECW';
650aA   $drisys2upd = 'D';
650aA   ck4err = *on;
650aA   zmflag  = *off;
650aA   exsr zzzdricop;
650aA /end-free
650aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     C                   if        reccnt > 0
     *
     *   Loop through changed subfile records and add/update file.
     *
     C                   eval      pcwwhs = $pwhse
     C                   eval      pcwpo = $ppo
     C                   eval      pcwseq = $pseq
     C                   eval      pcwitm = $pitem
     *
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     detail1                                77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Get detail record.
     *
     C                   move      w1seq         pcwsq2
     C     cwkey         chain     record2                            7978
     *
     *     Record locked. Tell user to try again.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Initialize record fields before trying to add or update.
     *
     *    This conversion is being done to move the implied decimal(2)
     *    for update back to the file.
     C     w1cwgt        div       100           pcwwgt
     *
     *     Record not found. Try adding record.
     *
     C                   if        *in79
700bAC                   if        pcwwgt <> 0
     C                   write     record2                              76
     C                   if        not *in76
650aAc                   exsr      zzuciadd
     C                   iter
     C                   endif
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
700bAC                   endif
     C                   endif
     *
     *     Record found. Try updating record.
     *
     C                   if        not *in79
     C                   if        w1cwgt = 0
     C                   delete    record2
650aAc                   exsr      zzucidel
     C                   else
     *
     C                   update    record2                              76
650aAc                   exsr      zzuciupd
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     C                   endif
     C                   endif
     *
     C                   enddo
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Determine which screen to display next.
     *
     *R         W1STYP    IFEQ 'P'
     *R                   EXSR SCR02I
     *R                   ELSE
     *R                   EXSR SCR03I
     *R                   ENDIF
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
     *  If user is adding a detail record ...
     *    - add it to subfile and return to entry screen
     *    - do not update files
     *
     C                   if        w1addw <> *zero
     C                   add       1             lstseq
     C                   z-add     lstseq        w1seq
     *
     C                   eval      w1cwgt = w1addw
650aAc                   eval      w1ent = w1wgt
     C                   eval      *in85 = *on
     C                   exsr      sfladd
     C                   exsr      zztotl
     C                   eval      w1addw = *zeros
     C                   eval      w1wgt = *blanks
     C                   eval      *in17 = *on
     C                   eval      redspl = *on
     C                   eval      ovrrid = *off
     C                   goto      endup3
     C                   endif
     *
     *  Update detail first.
     *
     C                   exsr      zztotl
     C                   if        reccnt >= 0
     C                   exsr      zzchkt
     C     error         cabeq     *on           endup3
     C                   exsr      zzusub
     C     error         cabeq     *on           endup3
     C                   endif
     *
     *
     * Load values to pass back.
     *
     *    Total catchweight entered.
     C                   eval      $pcwtt = wotcw
     *    Total number of catchweights entered.
     C                   z-add     wocw#         $pcwte
     *    Compute average catchweight entered.
     C                   if        wocw# > 0
     C     wotcw         div       wocw#         $pcwta
     C                   else
     C                   eval      $pcwta = *zeros
     C                   endif
     *
     C     endup3        endsr
     *
650aA*----------------------------------------------------------------
650aA*  zzzdricop  Call DRICOP
650aA*----------------------------------------------------------------

650aAC     zzzdricop     begsr
650aAC                   eval      error = *off

650aAC                   select
650aAC                   when      $dricommand = '*UCIINFO'
650aAC                   eval      $dridata = $uciinfo
650aAC                   endsl


650aAC                   if        $dricommand = '*ITEM'
650aAC                             or $dricommand = '*LICENSE'
650aAC                             or $dricommand = '*LICINFO'
650aAC                   call(e)   'DRICOP'
650aAC                   parm                    $dricommand
650aAC                   parm                    $drisubcmd
650aAC                   parm                    $drisys2upd
650aAC                   parm      #prog         $driprogram
650aAC                   parm      ' '           $drireturn
650aAC                   parm      ' '           $drimessage
650aAC                   parm                    $dridata
650aAC                   parm                    $dridata2

650aAC                   else
650aAC                   call(e)   'DRICOP'
650aAC                   parm                    $dricommand
650aAC                   parm                    $drisubcmd
650aAC                   parm                    $drisys2upd
650aAC                   parm      #prog         $driprogram
650aAC                   parm      ' '           $drireturn
650aAC                   parm      ' '           $drimessage
650aAC                   parm                    $dridata
650aAC                   endif

650aAC                   select

650aAC                   when      ck4err and %error
650aAC                   eval      error = *on
650aAC                   eval      errmsg    = 'Error occured on call to '
650aAC                                       + 'DRICOP'
650aAC                                       + '/' + %trim($drisubcmd)
650aAC                                       + ' from ' + #prog
650aAC                   exsr      zm0105

650aAC                   when      ck4err and $drireturn <> '*OK'
650aAC                   eval      error = *on
650aAC                   select
650aAC                   when      zmsflag
650aAC                   exsr      zm0001s
650aAC                   when      zmflag
650aAC                   exsr      zm0001
650aAC                   endsl

650aAC                   endsl

650aAC                   select
650aAC                   when      $dricommand = '*UCIINFO'
650aAC                   eval      $uciinfo = $dridata
650aAC                   endsl

650aAC                   eval      ck4err = *off
650aAC     enddricop     endsr
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
F5=Refresh  F7=Kilograms  F12=Cancel  F20=Accept Warning
F5=Refresh  F7=Pounds  F12=Cancel  F20=Accept Warning
F5=Refresh  F12=Cancel  F20=Accept Warning
