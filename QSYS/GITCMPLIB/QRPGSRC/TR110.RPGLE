      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR110    TRAX - Options
     *  14 Dec 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    12/14/10  RBD  6.40
     *      - Created.
     *
640aA*     7/05/11  RBD  6.40a
     *      - Added options Icon Delivery and Double Click Icons.
     *      - Changed scrn format name to TR11002.
     *
640bA*    11/03/11  RBD  6.40b
     *      - Added options Pallets Enabled and Cradle Uploaded
     *        Enabled.
     *      - Changed scrn format name to TR11003.
     *      - Moved some options from screen1 to screen2 and from
     *        screen2 to screen1 to make room for more options.
     *
640cA*    12/12/11  RBD  6.40c
     *      - Added option Driver Assigned Before Download.
     *      - Added option Bulk Items Enabled.
     *      - Added option Display Empty Stops.
     *      - Changed scrn format name to TR11004.
     *
650aA*    07/08/13  RBD  6.50a
     *      - Added option Save After Scan.
     *      - Added option Save Delay.
     *      - Added option Sync Date and Time.
     *      - Added option GS1 Scanning.
     *      - Added option GS1 Unique.
     *      - Added option Left/Right Keys Enabled.
     *      - Added option Scan Beep Volume.
     *      - Changed scrn format name to TR11005.
     *
650bA*    09/17/13  RBD  6.50b
     *      - Changed scrn format name to TR11006.
     *      - Added screen3.
     *      - Added option Restart After Get Route.
     *      - Added option Restart Daily.
     *      - Added option Restart Daily Time.
     *      - Added option Reader Focus Position.
     *      - Added option Reader Focus Mode.
     *      - Added option Non Scan Reason Prompt.
     *      - Added option Filter by Department.
     *
650c *    10/21/13  GJA  6.50c
     *      - Changed scrn format name to TR11007.
     *
650dA*    03/11/14  RBD  6.50d
     *      - Changed scrn format name to TR11008.
     *      - Added screen4 for *TRAX2 options.
     *        Added screen5 for *TRAX1 options.
     *        Note: can't combine *TRAX, *TRAX1 and/or *TRAX2 options on the
     *        same screen because we lock the record when we retrieve it so
     *        that it can't be changed while being updated ... there are
     *        currently no logicals for OPTIONS so separating the different
     *        opcodes onto different screens seemed to be the best way to
     *        handle this.
     *      - Added option Email Receipt.
     *      - Added option Receipt Email From.
     *      - Added option Receipt Email Subject.
     *      - Added option Use System Suspend Battery Power Timeout.
     *      - Added option System Suspend Battery Power Timeout.
     *      - Added option Use System Suspend External Power Timeout.
     *      - Added option System Suspend External Power Timeout.
     *      - Added option Use Backlight Off Battery Power Timeout.
     *      - Added option Backlight Off Battery Power Timeout.
     *      - Added option Use Backlight Off External Power Timeout.
     *      - Added option Backlight Off External Power Timeout.
     *      - Added option Display Stop Flags Before Restart.
     *
710aA*    05/18/17  RBD  7.10a
     *      - Per SC changed days to keep Trax export data default
     *        from 7 to 30.
     *
710bA*    10/10/17  RBD  7.10b
     *      - Changed scrn format name to TR11009.
     *      - Added *TRAX2 options:
     *        OPTV12 - Default = N.  Y = create version 1.2 xml.
     *        OPTV20 - Default = N.  Y = create version 2.0 xml.
     *
710cA*    11/18/17  DAS  7.10c
     *      - Changed scrn format name to TR11010.
     *      - Added *TRAX2 option OPTDIR, IFS directory
     *
710dA*    11/30/17  RBD  7.10c
     *      - Changed scrn format name to TR11011.
     *      - Added *TRAX2 option OPTIU, IFS user.
     *
720aA*    07/02/18  DAS  7.20a
     *      - Changed scrn format name to TR11012.
     *      - Added *TRAX2 option OPTOSIG
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 42   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640aDF*tr11001   cf   e             workstn
640bDF*tr11002   cf   e             workstn
640cDF*tr11003   cf   e             workstn
650aDF*tr11004   cf   e             workstn
650bDF*tr11005   cf   e             workstn
650cDF*tr11006   cf   e             workstn
650dDF*tr11007   cf   e             workstn
710bDF*tr11008   cf   e             workstn
710cDF*r11009   cf   e             workstn
710dDF*tr11010   cf   e             workstn
720aDF*r11011   cf   e             workstn
720aMFtr11012   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
650aDD*desc            s             50    dim(9) ctdata perrcd(1)
650bDD*desc            s             50    dim(11) ctdata perrcd(1)
650dDD*desc            s             50    dim(15) ctdata perrcd(1)
650dMD desc            s             50    dim(16) ctdata perrcd(1)
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
     *
     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *    OPTIDL  -  Icon delivery
     *    OPTDCI  -  Double click icons
     *    OPTPAL  -  Pallets enabled
     *    OPTCRA  -  Cradle upload enabled
     *    OPTDRV  -  Driver assigned before download
     *    OPTBUL  -  Bulk items enabled
     *    OPTEYS  -  Display empty stops
     *    OPTSAS  -  Save after scan
     *    OPTSDL  -  Save delay
     *    OPTSDT  -  Sync date and time
     *    OPTLRK  -  Left/right keys enabled
     *    OPTGSS  -  GS1 scanning
     *    OPTGSU  -  GS1 unique
     *    OPTSBV  -  Scan beep volume
     *    OPTRAG  -  Restart after get route.
     *    OPTRD   -  Restart daily.
     *    OPTRDT  -  Restart daily time.
     *    OPTRFP  -  Reader focus position.
     *    OPTRFM  -  Reader focus mode.
     *    OPTNSR  -  Non scan reason prompt.
     *    OPTFBD  -  Filter by department.
     *    OPTDSF  -  Display stop flags before restart.
     *
     * Data structure
     *
     D opdata          ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  optidl                77     77
     D  optdci                78     78
     D  optpal                79     79
     D  optcra                80     80
     D  optdrv                81     81
     D  optbul                82     82
     D  opteys                83     83
     D  optsas                84     84
     D  optsdl                85     86  0
     D  optsdt                87     87
     D  optlrk                88     88
     D  optgss                89     89
     D  optgsu                90     90
     D  optsbv                91     91  0
     D  optrag                92     92
     D  optrd                 93     93
     D  optrdt                94     97  0
     D  optrfp                98     98
     D  optrfm                99     99
     D  optnsr               100    100
     D  optfbd               101    101
     D  optdsf               102    102
     D  optend               117    117
     *----------------------------------------------------------------
     *  *TRAX1    -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTER   -  Email receipt.
     *    OPTREF  -  Receipt email from.
     *    OPTRES  -  Receipt email subject.
     *
     * Data structure
     *
     D opdta1          ds
     D  opter                  1      1
     D  optref                 2     61
     D  optres                62    116
     D  opten1               117    117
     *----------------------------------------------------------------
     *  *TRAX2  -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
710bA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710bA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710cA*    OPTDIR  -  IFS main directory
710dA*    OPTIU   -  IFS user
720aA*    OPTOSIG -  Create Customer Oder Signatures (Default = N)
     *
     * Data structure
     *
     D opdta2          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
710bAD  optv12                18     18
710bAD  optv20                19     19
710cAD  optdir                20     39
710dAD  optiu                 40     49
720aAD  optosig               50     50
     D  opten2               117    117
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
     D  erUser                 1     10
     D  erAction              11     40
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
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpflg          s              1
     D w3trdtAlpha     s              4
     D warn            s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Change record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
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
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
650bAC     nxtscr        caseq     '03 '         sc3
650dAC     nxtscr        caseq     '04 '         sc4
650dAC     nxtscr        caseq     '05 '         sc5
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
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
     C                   exfmt     screen1                              50
     C                   when      nxtscr = '02 '
     C                   exfmt     screen2                              50
650bAC                   when      nxtscr = '03 '
650bAC                   exfmt     screen3                              50
650dAC                   when      nxtscr = '04 '
650dAC                   exfmt     screen4                              50
650dAC                   when      nxtscr = '05 '
650dAC                   exfmt     screen5                              50
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
     C                   setoff                                       394041
     C                   setoff                                       424344
     C                   setoff                                       454647
     C                   setoff                                       4849
640aAC                   setoff                                       5152
640bAC                   setoff                                       5354
640cAC                   setoff                                       555657
650aAC                   setoff                                       606162
650aAC                   setoff                                       636465
650aAC                   setoff                                       66
650bAC                   setoff                                       676869
650bAC                   setoff                                       707172
650dMC                   setoff                                       737475
650dAC                   setoff                                       767780
650dAC                   setoff                                       818283
710bMC                   setoff                                       848586
710dMC                   setoff                                       878889
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
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
650bA*----------------------------------------------------------------
650bA*
650bA*  Screen 03 initialization
650bA*
650bAC     scr03i        begsr
     C                   eval      nxtscr = '03 '
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
650dA*
650dA*  Screen 04 initialization
650dA*
650dAC     scr04i        begsr
     C                   eval      nxtscr = '04 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft4
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget4
     C                   exsr      zzfil4
     C                   endif
     C     end04i        endsr
     *----------------------------------------------------------------
650dA*
650dA*  Screen 05 initialization
650dA*
650dAC     scr05i        begsr
     C                   eval      nxtscr = '05 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft5
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget5
     C                   exsr      zzfil5
     C                   endif
     C     end05i        endsr
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
650bD** Display screen 2.
650bDC**                 exsr      scr02i
650bM*  Display screen 3.
650bMC                   exsr      scr03i
     *
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
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
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
650dD** Everything went fine so get out of program.
650dD**
650dDC**                 eval      nxtscr = 'EOJ'
650dA*
650dA*  Display screen 4.
650dAC                   exsr      scr04i
     *
     C     endsc2        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  SC3  -  Screen 3
650bA*
650bAC     sc3           begsr
650bA*
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
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
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
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
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Display screen 2.
     C                   exsr      scr02i
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
650dA*
650dA*  SC4  -  Screen 4
650dA*
650dAC     sc4           begsr
650dA*
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr04i
     C                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Display screen 5.
     C                   exsr      scr05i
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
650dA*
650dA*  SC5  -  Screen 5
650dA*
650dAC     sc5           begsr
650dA*
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr05i
     C                   endif
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc5        endsr
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
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0148  User not authorized to use ...
     *
     C     ZM0148        BEGSR
     C                   MOVE      'PIR0148'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify driver field type.
     *
     C                   if            w1tdft <> 'A'
     C                             and w1tdft <> 'N'
     C                             and w1tdft <> 'B'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify route field type.
     *
     C                   if            w1trft <> 'A'
     C                             and w1trft <> 'N'
     C                             and w1trft <> 'B'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify order number field type.
     *
     C                   if            w1toft <> 'A'
     C                             and w1toft <> 'N'
     C                             and w1toft <> 'B'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify include item data base.
     *
     C                   if            w1tidb <> 'Y'
     C                             and w1tidb <> 'N'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify capitalize input.
     *
     C                   if            w1tcap <> 'Y'
     C                             and w1tcap <> 'N'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify double click delivery.
     *
     C                   if            w1tdbl <> 'Y'
     C                             and w1tdbl <> 'N'
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify entry key delivery.
     *
     C                   if            w1tekd <> 'Y'
     C                             and w1tekd <> 'N'
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify delivery after return.
     *
     C                   if            w1tdar <> 'Y'
     C                             and w1tdar <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify send data after stop.
     *
     C                   if            w1tsda <> 'Y'
     C                             and w1tsda <> 'N'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify breakdowns allowed.
     *
     C                   if            w1tbda <> 'Y'
     C                             and w1tbda <> 'N'
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify generic breakdown allowed.
     *
     C                   if            w1tgbd <> 'Y'
     C                             and w1tgbd <> 'N'
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify pre-trip questions.
     *
     C                   if            w1trtq <> 'Y'
     C                             and w1trtq <> 'N'
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify post-trip questions.
     *
     C                   if            w1totq <> 'Y'
     C                             and w1totq <> 'N'
     C                   eval      error = *on
     C                   eval      *in37 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify credit card enabled.
     *
     C                   if            w1tcce <> 'Y'
     C                             and w1tcce <> 'N'
     C                   eval      error = *on
     C                   eval      *in38 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify signature enabled.
     *
     C                   if            w1tsig <> 'Y'
     C                             and w1tsig <> 'N'
     C                   eval      error = *on
     C                   eval      *in39 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify catchweight required.
     *
     C                   if            w1tcwr <> 'Y'
     C                             and w1tcwr <> 'N'
     C                   eval      error = *on
     C                   eval      *in40 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify save log info.
     *
     C                   if            w1tsli <> 'Y'
     C                             and w1tsli <> 'N'
     C                   eval      error = *on
     C                   eval      *in41 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify print invoice.
     *
     C                   if            w1tpiv <> 'Y'
     C                             and w1tpiv <> 'N'
     C                   eval      error = *on
     C                   eval      *in42 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
640aA*  Verify Icon delivery.
640aA*
640aAC                   if            w1tidl <> 'Y'
640aAC                             and w1tidl <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in51 = *on
640aAC                   eval      errmsg = desc(3)
640aAC                   exsr      zm0105
640aAC                   endif
     *
640aA*  Verify Double click icons.
640aA*
640aAC                   if            w1tdci <> 'Y'
640aAC                             and w1tdci <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in52 = *on
640aAC                   eval      errmsg = desc(3)
640aAC                   exsr      zm0105
640aAC                   endif
     *
     *  Verify add return enabled.
     *
     C                   if            w1tare <> 'Y'
     C                             and w1tare <> 'N'
     C                   eval      error = *on
     C                   eval      *in49 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
640bA*  Verify Pallets enabled.
640bA*
640bAC                   if            w1pale <> 'Y'
640bAC                             and w1pale <> 'N'
640bAC                   eval      error = *on
640bAC                   eval      *in53 = *on
640bAC                   eval      errmsg = desc(3)
640bAC                   exsr      zm0105
640bAC                   endif
     *
640bA*  Verify Double click icons.
640bA*
640bAC                   if            w1crae <> 'Y'
640bAC                             and w1crae <> 'N'
640bAC                   eval      error = *on
640bAC                   eval      *in54 = *on
640bAC                   eval      errmsg = desc(3)
640bAC                   exsr      zm0105
640bAC                   endif
     *
640cA*  Verify Driver assigned before download.
640cA*
640cAC                   if            w1tdrv <> 'Y'
640cAC                             and w1tdrv <> 'N'
640cAC                   eval      error = *on
640cAC                   eval      *in55 = *on
640cAC                   eval      errmsg = desc(3)
640cAC                   exsr      zm0105
640cAC                   endif
     *
640cA*  Verify Bulk items enabled.
640cA*
640cAC                   if            w1tbul <> 'Y'
640cAC                             and w1tbul <> 'N'
640cAC                   eval      error = *on
640cAC                   eval      *in56 = *on
640cAC                   eval      errmsg = desc(3)
640cAC                   exsr      zm0105
640cAC                   endif
     *
640cA*  Verify Display empty stops.
640cA*
640cAC                   if            w1teys <> 'Y'
640cAC                             and w1teys <> 'N'
640cAC                   eval      error = *on
640cAC                   eval      *in57 = *on
640cAC                   eval      errmsg = desc(3)
640cAC                   exsr      zm0105
640cAC                   endif
     *
650aA*  Verify Save after scan.
650aA*
650aAC                   if            w1tsas <> 'Y'
650aAC                             and w1tsas <> 'N'
650aAC                   eval      error = *on
650aAC                   eval      *in60 = *on
650aAC                   eval      errmsg = desc(3)
650aAC                   exsr      zm0105
650aAC                   endif
     *
650aA*  Verify Save delay.
650aA*
650aAC                   if            w1tsdl > 60
650aAC                             or  (w1tsdl <> 0 and w1tsdl < 10)
650aAC                   eval      error = *on
650aAC                   eval      *in61 = *on
650aAC                   eval      errmsg = desc(10)
650aAC                   exsr      zm0105
650aAC                   endif
     *
650aA*  Verify Sync date and time.
650aA*
650aAC                   if            w1tsdt <> 'Y'
650aAC                             and w1tsdt <> 'N'
650aAC                   eval      error = *on
650aAC                   eval      *in62 = *on
650aAC                   eval      errmsg = desc(3)
650aAC                   exsr      zm0105
650aAC                   endif
     *
650aA*  Verify GS1 scanning.
650aA*
650aAC                   if            w1tgss <> 'Y'
650aAC                             and w1tgss <> 'N'
650aAC                   eval      error = *on
650aAC                   eval      *in63 = *on
650aAC                   eval      errmsg = desc(3)
650aAC                   exsr      zm0105
650aAC                   endif
     *
650aA*  Verify GS1 unique.
650aA*
650aAC                   if            w1tgsu <> 'Y'
650aAC                             and w1tgsu <> 'N'
650aAC                   eval      error = *on
650aAC                   eval      *in64 = *on
650aAC                   eval      errmsg = desc(3)
650aAC                   exsr      zm0105
650aAC                   endif
     *
650aA*  Verify Left/right keys enabled.
650aA*
650aAC                   if            w1tlrk <> 'Y'
650aAC                             and w1tlrk <> 'N'
650aAC                   eval      error = *on
650aAC                   eval      *in65 = *on
650aAC                   eval      errmsg = desc(3)
650aAC                   exsr      zm0105
650aAC                   endif
     *
650aA*  Verify Scan beep volume.
650aA*
650aAC                   if            w1tsbv <> 1
650aAC                             and w1tsbv <> 2
650aAC                             and w1tsbv <> 3
650aAC                   eval      error = *on
650aAC                   eval      *in66 = *on
650aAC                   eval      errmsg = desc(11)
650aAC                   exsr      zm0105
650aAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *  Verify handheld save days.
     *
     C                   if            w2tsvd < 1
     C                             or  w2tsvd > 31
     C                   eval      error = *on
     C                   eval      *in43 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify environment runtime.
     *
     C                   if            w2tert <> 'PROD'
     C                             and w2tert <> 'TEST'
     C                             and w2tert <> 'DEV '
     C                   eval      error = *on
     C                   eval      *in44 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify environment device.
     *
     C                   if            w2tedv <> 'MC75      '
     C                   eval      error = *on
     C                   eval      *in45 = *on
     C                   eval      errmsg = desc(6)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify environment OS.
     *
     C                   if            w2teos <> 'WM6       '
     C                   eval      error = *on
     C                   eval      *in46 = *on
     C                   eval      errmsg = desc(7)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify environment screen width.
     *
     C                   if            w2tesw <> 480
     C                   eval      error = *on
     C                   eval      *in47 = *on
     C                   eval      errmsg = desc(8)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify environment screen height.
     *
     C                   if            w2tesh <> 640
     C                   eval      error = *on
     C                   eval      *in48 = *on
     C                   eval      errmsg = desc(9)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Number of days to keep.
     *
     C                   if        w2thst < 1
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '1'           erfrom
     C                   movel     '999'         erto
     C                   exsr      zm0112
     C                   endif
     *
     C     endck2        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCHK3   Screen 3 error checking.
650bA*
650bAC     zzchk3        begsr
     C                   eval      error = *off
     *
     *  Verify restart after get route.
     *
     C                   if            w3trag <> 'Y'
     C                             and w3trag <> 'N'
     C                             and w3trag <> 'P'
     C                   eval      error = *on
     C                   eval      *in67 = *on
     C                   eval      errmsg = desc(15)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify restart daily.
     *
     C                   if            w3trd  <> 'Y'
     C                             and w3trd  <> 'N'
     C                   eval      error = *on
     C                   eval      *in68 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify restart daily time.
     *
     C                   move      w3trdt        w3trdtAlpha
     C                   if        %subst(w3trdtAlpha:1:2) < '00'
     C                             or  %subst(w3trdtAlpha:1:2) > '23'
     C                             or  %subst(w3trdtAlpha:3:2) <> '00'
     C                             and %subst(w3trdtAlpha:3:2) <> '15'
     C                             and %subst(w3trdtAlpha:3:2) <> '30'
     C                             and %subst(w3trdtAlpha:3:2) <> '45'
     C                   eval      error = *on
     C                   eval      *in69 = *on
     C                   eval      errmsg = desc(12)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify reader focus position.
     *
     C                   if            w3trfp  <> 'N'
     C                             and w3trfp  <> 'F'
     C                   eval      error = *on
     C                   eval      *in70 = *on
     C                   eval      errmsg = desc(13)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify reader focus mode.
     *
     C                   if            w3trfm  <> 'A'
     C                             and w3trfm  <> 'F'
     C                   eval      error = *on
     C                   eval      *in71 = *on
     C                   eval      errmsg = desc(14)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify non scan reason prompt.
     *
     C                   if            w3tnsr  <> 'Y'
     C                             and w3tnsr  <> 'N'
     C                   eval      error = *on
     C                   eval      *in72 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify filter by department.
     *
     C                   if            w3tfbd  <> 'Y'
     C                             and w3tfbd  <> 'N'
     C                   eval      error = *on
     C                   eval      *in73 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
650dA*  Verify filter by department.
650dA*
650dAC                   if            w3tdsf  <> 'Y'
650dAC                             and w3tdsf  <> 'N'
650dAC                   eval      error = *on
650dAC                   eval      *in75 = *on
650dAC                   eval      errmsg = desc(3)
650dAC                   exsr      zm0105
650dAC                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZCHK4   Screen 4 error checking.
650dA*
650dAC     zzchk4        begsr
     C                   eval      error = *off
     *
     *  Verify System Suspend Battery Power Timeout
     *
     C                   if            w4tsbu = 'Y'
     C                             and w4tsb  = 0
     C                   eval      error = *on
     C                   eval      *in76 = *on
     C                   eval      errmsg = desc(16)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Use System Suspend Battery Power Timeout
     *
     C                   if            w4tsbu <> 'Y'
     C                             and w4tsbu <> 'N'
     C                   eval      error = *on
     C                   eval      *in77 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify System Suspend External Power Timeout
     *
     C                   if            w4tseu = 'Y'
     C                             and w4tse  = 0
     C                   eval      error = *on
     C                   eval      *in80 = *on
     C                   eval      errmsg = desc(16)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Use System Suspend External Power Timeout
     *
     C                   if            w4tseu <> 'Y'
     C                             and w4tseu <> 'N'
     C                   eval      error = *on
     C                   eval      *in81 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Backlight Off Battery Power Timeout
     *
     C                   if            w4tbbu = 'Y'
     C                             and w4tbb  = 0
     C                   eval      error = *on
     C                   eval      *in82 = *on
     C                   eval      errmsg = desc(16)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Use Backlight Off Battery Power Timeout
     *
     C                   if            w4tbbu <> 'Y'
     C                             and w4tbbu <> 'N'
     C                   eval      error = *on
     C                   eval      *in83 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Backlight Off External Power Timeout
     *
     C                   if            w4tbeu = 'Y'
     C                             and w4tbe  = 0
     C                   eval      error = *on
     C                   eval      *in84 = *on
     C                   eval      errmsg = desc(16)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Use Backlight Off External Power Timeout
     *
     C                   if            w4tbeu <> 'Y'
     C                             and w4tbeu <> 'N'
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
710bA*  Verify Create version 1.2
710bA*
710bAC                   if            w4tv12 <> 'Y'
710bAC                             and w4tv12 <> 'N'
710bAC                   eval      error = *on
710bAC                   eval      *in86 = *on
710bAC                   eval      errmsg = desc(3)
710bAC                   exsr      zm0105
710bAC                   endif
     *
710bA*  Verify Create version 2.0
710bA*
710bAC                   if            w4tv20 <> 'Y'
710bAC                             and w4tv20 <> 'N'
710bAC                   eval      error = *on
710bAC                   eval      *in87 = *on
710bAC                   eval      errmsg = desc(3)
710bAC                   exsr      zm0105
710bAC                   endif

710cA*  Verify IFS Directory
710cA
710cAC                   if        w4tdir = ''
710cAC                   eval      error = *on
710cAC                   eval      *in88 = *on
710cAC                   eval      errmsg = 'IFS Directory must be entered'
710cAC                   exsr      zm0105
710cAC                   endif
     *
710dA*  Verify IFS User
710dA
710dAC                   if        w4tiu = ''
710dAC                   eval      error = *on
710dAC                   eval      *in89 = *on
710dAC                   eval      errmsg = 'IFS User must be entered'
710dAC                   exsr      zm0105
710dAC                   endif
     *
720aA*  Verify Create customer order signature file
720aA*
720aAC                   if            w4tosig <> 'Y'
720aAC                             and w4tosig <> 'N'
720aAC                   eval      error = *on
720aAC                   eval      *in21 = *on
720aAC                   eval      errmsg = 'Cust Ord Sig must be '
720aAC                                    + 'Y or N'
720aAC                   exsr      zm0105
720aAC                   endif
     *
     C     endck4        endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZCHK5   Screen 5 error checking.
650dA*
650dAC     zzchk5        begsr
     C                   eval      error = *off
     *
     *  Verify Email receipt.
     *
     C                   if            w5ter <> 'Y'
     C                             and w5ter <> 'N'
     C                   eval      error = *on
     C                   eval      *in74 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
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
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCMD3   User defined command keys for screen 3.
650bA*
650bAC     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZCMD4   User defined command keys for screen 4.
650dA*
650dAC     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZCMD5   User defined command keys for screen 5.
650dA*
650dAC     zzcmd5        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
640aAC                   eval      optidl = 'Y'
640aAC                   eval      optdci = 'N'
     C                   eval      optare = 'Y'
640bAC                   eval      optpal = 'Y'
640bAC                   eval      optcra = 'N'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     C                   eval      optsvd = 5
     C                   eval      optert = 'DEV '
     C                   eval      optedv = 'MC75      '
     C                   eval      opteos = 'WM6       '
     C                   eval      optesw = 480
     C                   eval      optesh = 640
710aDC**                 eval      opthst = 7
710aMC                   eval      opthst = 30
     C                   eval      optwsp = 0
     *
     C                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZDFT3   Get default values for add.
650bA*
650bAC     zzdft3        begsr
     *
     C                   eval      optrag = 'N'
     C                   eval      optrd  = 'N'
     C                   eval      optrdt = 0
     *
     C                   endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZDFT4   Get default values for add.
650dA*
650dAC     zzdft4        begsr
     *
     C                   eval      opdta2= *blanks
     *
     C                   eval      optsbu= 'Y'
     C                   eval      optsb = 5
     C                   eval      optseu= 'Y'
     C                   eval      optse = 30
     C                   eval      optbbu= 'Y'
     C                   eval      optbb = 60
     C                   eval      optbeu= 'Y'
     C                   eval      optbe = 5
710bAC                   eval      optv12 = 'N'
710bAC                   eval      optv20 = 'N'
710cAC                   eval      optdir = 'BFCTrax'
710dAC                   eval      optiu = 'BFCTRAX'
720aAC                   eval      optosig = 'N'
     *
     C                   eval      opdata= opdta2
     *
     C                   endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZDFT5   Get default values for add.
650dA*
650dAC     zzdft5        begsr
     *
     C                   eval      opdta1= *blanks
     *
     C                   eval      opter= 'N'
     *
     C                   eval      opdata= opdta1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1tsli = optsli
     C                   eval      w1tcwr = optcwr
     C                   eval      w1toft = optoft
     C                   eval      w1tdft = optdft
     C                   eval      w1trft = optrft
     C                   eval      w1tcap = optcap
     C                   eval      w1tdbl = optdbl
     C                   eval      w1tekd = optekd
     C                   eval      w1tdar = optdar
     C                   eval      w1tidb = optidb
     C                   eval      w1tbda = optbda
     C                   eval      w1tgbd = optgbd
     C                   eval      w1trtq = optrtq
     C                   eval      w1totq = optotq
     C                   eval      w1tcce = optcce
     C                   eval      w1tsig = optsig
     C                   eval      w1tpiv = optpiv
     C                   eval      w1tsda = optsda
640aAC                   eval      w1tidl = optidl
640aAC                   eval      w1tdci = optdci
     C                   eval      w1tare = optare
640bAC                   eval      w1pale = optpal
640bAC                   eval      w1crae = optcra
640cAC                   eval      w1tdrv = optdrv
640cAC                   eval      w1tbul = optbul
640cAC                   eval      w1teys = opteys
650aAC                   eval      w1tsas = optsas
650aAC                   eval      w1tsdl = optsdl
650aAC                   eval      w1tsdt = optsdt
650aAC                   eval      w1tgss = optgss
650aAC                   eval      w1tgsu = optgsu
650aAC                   eval      w1tlrk = optlrk
650aAC                   eval      w1tsbv = optsbv
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *  The screen 2 fields were added after some clients already
     *  had Trax ... so if optert = *blanks, set the screen 2
     *  fields to their default values.
     *
     C                   if        optert = *blanks
     C                   exsr      zzdft2
     C                   endif
     *
     C                   eval      w2tsvd = optsvd
     C                   eval      w2tert = optert
     C                   eval      w2tedv = optedv
     C                   eval      w2teos = opteos
     C                   eval      w2tesw = optesw
     C                   eval      w2tesh = optesh
     C                   eval      w2thst = opthst
     C                   eval      w2twsp = optwsp
     C                   eval      w2twsi = optwsi
     *
     C                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZFIL3   Fill screen 3 fields with info from file.
650bA*
650bAC     zzfil3        begsr
650bA*
     C                   eval      w3trag = optrag
     C                   eval      w3trd  = optrd
     C                   eval      w3trdt = optrdt
     C                   eval      w3trfp = optrfp
     C                   eval      w3trfm = optrfm
     C                   eval      w3tnsr = optnsr
     C                   eval      w3tfbd = optfbd
650dAC                   eval      w3tdsf = optdsf
     *
     C                   endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZFIL4   Fill screen 4 fields with info from file.
650dA*
650dAC     zzfil4        begsr
650dA*
     C                   eval      w4tsb  = optsb
     C                   eval      w4tsbu = optsbu
     C                   eval      w4tse  = optse
     C                   eval      w4tseu = optseu
     C                   eval      w4tbb  = optbb
     C                   eval      w4tbbu = optbbu
     C                   eval      w4tbe  = optbe
     C                   eval      w4tbeu = optbeu
710bAC                   eval      w4tv12 = optv12
710bAC                   eval      w4tv20 = optv20
710cAC                   eval      w4tdir = optdir
710dAC                   eval      w4tiu  = optiu
720aAC                   eval      w4tosig = optosig
     *
     C                   endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZFIL5   Fill screen 5 fields with info from file.
650dA*
650dAC     zzfil5        begsr
650dA*
     C                   eval      w5ter  = opter
     C                   eval      w5tref = optref
     C                   eval      w5tres = optres
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*TRAX   '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt1        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft1
     C                   write     record
     C                   goto      beggt1
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*TRAX   '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt2        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft2
     C                   write     record
     C                   goto      beggt2
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C                   endif
     *
     C     endgt2        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZGET3   Get record(s) for screen 3.
650bA*
650bAC     zzget3        begsr
650bA*
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*TRAX   '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt3        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt3
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft3
     C                   write     record
     C                   goto      beggt3
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt3
     C                   endif
     C                   endif
     *
     C     endgt3        endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZGET4   Get record(s) for screen 4.
650dA*
650dAC     zzget4        begsr
650dA*
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*TRAX2  '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt4        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt4
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft4
     C                   write     record
     C                   goto      beggt4
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt4
     C                   endif
     C                   endif
     *
650dAC                   eval      opdta2 = opdata
     *
     C     endgt4        endsr
     *----------------------------------------------------------------
650dA*
650dA*  ZZGET5   Get record(s) for screen 5.
650dA*
650dAC     zzget5        begsr
650dA*
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*TRAX1  '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt5        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt5
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft5
     C                   write     record
     C                   goto      beggt5
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt5
     C                   endif
     C                   endif
     *
650dAC                   eval      opdta1 = opdata
     *
     C     endgt5        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get and verify warehouse description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg = $pprg
     C                   eval      $lwhse = $pwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '  or
     C                             $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      $prtn = $lrtn
     C                   eval      $perm = $lerm
     C                   goto      endin2
     C                   else
     C                   eval      whcode = $pwhse
     C                   movel     $lerm         whdesc
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record with screen1 fields.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      optsli = w1tsli
     C                   eval      optcwr = w1tcwr
     C                   eval      optoft = w1toft
     C                   eval      optdft = w1tdft
     C                   eval      optrft = w1trft
     C                   eval      optcap = w1tcap
     C                   eval      optdbl = w1tdbl
     C                   eval      optekd = w1tekd
     C                   eval      optdar = w1tdar
     C                   eval      optidb = w1tidb
     C                   eval      optbda = w1tbda
     C                   eval      optgbd = w1tgbd
     C                   eval      optrtq = w1trtq
     C                   eval      optotq = w1totq
     C                   eval      optcce = w1tcce
     C                   eval      optsig = w1tsig
     C                   eval      optpiv = w1tpiv
     C                   eval      optsda = w1tsda
640aAC                   eval      optidl = w1tidl
640aAC                   eval      optdci = w1tdci
     C                   eval      optare = w1tare
640bAC                   eval      optpal = w1pale
640bAC                   eval      optcra = w1crae
640cAC                   eval      optdrv = w1tdrv
640cAC                   eval      optbul = w1tbul
640cAC                   eval      opteys = w1teys
650aAC                   eval      optsas = w1tsas
650aAC                   eval      optsdl = w1tsdl
650aAC                   eval      optsdt = w1tsdt
650aAC                   eval      optgss = w1tgss
650aAC                   eval      optgsu = w1tgsu
650aAC                   eval      optlrk = w1tlrk
650aAC                   eval      optsbv = w1tsbv
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record with screen2 fields.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      optsvd = w2tsvd
     C                   eval      optert = w2tert
     C                   eval      optedv = w2tedv
     C                   eval      opteos = w2teos
     C                   eval      optesw = w2tesw
     C                   eval      optesh = w2tesh
     C                   eval      opthst = w2thst
     C                   eval      optwsp = w2twsp
     C                   eval      optwsi = w2twsi
     *
     *   Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup2
     C                   endif
     *
     C     endup2        endsr
     *
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZUPD3   Update record with screen3 fields.
650bA*
650bAC     zzupd3        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      optrag = w3trag
     C                   eval      optrd  = w3trd
     C                   eval      optrdt = w3trdt
     C                   eval      optrfp = w3trfp
     C                   eval      optrfm = w3trfm
     C                   eval      optnsr = w3tnsr
     C                   eval      optfbd = w3tfbd
650dAC                   eval      optdsf = w3tdsf
     *
     *   Update record (it was read and locked in ZZGET3)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     *
     C     endup3        endsr
     *
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZUPD4   Update record with screen4 fields.
650dA*
650dAC     zzupd4        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      optsb  = w4tsb
     C                   eval      optsbu = w4tsbu
     C                   eval      optse  = w4tse
     C                   eval      optseu = w4tseu
     C                   eval      optbb  = w4tbb
     C                   eval      optbbu = w4tbbu
     C                   eval      optbe  = w4tbe
     C                   eval      optbeu = w4tbeu
710bAC                   eval      optv12 = w4tv12
710bAC                   eval      optv20 = w4tv20
710cAC                   eval      optdir = w4tdir
710dAC                   eval      optiu  = w4tiu
720aAC                   eval      optosig = w4tosig
     *
     C                   eval      opdata = opdta2
     *
     *   Update record (it was read and locked in ZZGET4)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup4
     C                   endif
     *
     C     endup4        endsr
     *
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZUPD5   Update record with screen5 fields.
650dA*
650dAC     zzupd5        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      opter  = w5ter
     C                   eval      optref = w5tref
     C                   eval      optres = w5tres
     *
     C                   eval      opdata = opdta1
     *
     *   Update record (it was read and locked in ZZGET5)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup5
     C                   endif
     *
     C     endup5        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Days to keep Trax export data
Valid entries are A, N, or B
Please enter Y or N
Valid range is 1 - 31
Valid entries are PROD, TEST, or DEV
Valid entry: MC75
Valid entry: WM6
Valid entry: 480
Valid entry: 640
Valid entries are 0 or 10-60
Valid entries are 1, 2, or 3
0000-2345 in 15 min increments: 00,15,30,45
Must be N=Near or F=Far
Must be A=Auto or F=Fixed
Must be Y=Yes, N=No, or P=Prompt
Timeout must be entered when Use = Y
