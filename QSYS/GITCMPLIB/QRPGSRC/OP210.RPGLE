     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
530aA*                  WEBFACING REQUIREMENTS
530aA*
530aA* CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
530aA* RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
530aA*
530aA* I.E. OP210FM WILL BE REPALCED WITH OP21001
530aA*----------------------------------------------------------------
     *
     *  OP210     PIR options - System
     *  06 September 1997
     *  Dave Sommerville
     *
530aA*----------------------------------------------------------------
     *  Revisions
     *
405 A*    09/06/97  DAS  4.05
     *      - Created.
410 A*    09/29/98  RH   4.10
     *      - Add Perform catch weight check option and catch weight
     *        variance % fields.
411 A*    05/25/99  RH   4.11
     *      - Add Import item from host fields. SC2
     *      - Force OPITYP & OPMITM = Y to import from host.
412 A*    08/02/99  RH   4.12
     *      - Add Individual Catch Weight entry to SC1.
412 A*    08/25/99  MLB  4.12
     *      - Add allow multiple pick slot option. SC1 field (OPMPCK)
413aA*    09/22/99  MLB  4.13a
     *      - Add number of days to keep receiving logs.SC1 field(OPRCDY)
     *      - Add number of days to keep picking logs. SC1 field (OPPKDY)
413bA*    10/07/99  RH   4.13b
     *      - Get default for W1CITM.                                 DY)
     *
414aA*    04/21/00  MLB  4.14a
     *      - Added OPRTHS, OPCRHS, OPPOHS, OPIAHS and OPMSHS to
     *        *SYSTEM DS for number of weeks history to keep.
     *      - Added 5 new descriptions to array DESC.
     *      - Revised the following routines: ZZCHK1, ZZDFT1, ZZFIL1 and
     *        ZZUPD to support automated cleanup pgms.
416aA*    07/10/02  RH   4.16a
     *      - Added ORNSLT, ORXDCK, ORBNBR, ORBNAM, ORVNAM,
     *        ORBRND, ORLOT, ORLTRK.
     *      - ORNSLT, ORXDCK, ORLOT AND ORLTRK not added
     *        to screen, default values for now and add later.
510aA*    10/25/06  RH   5.10a
     *      - Added OPTBJQ Run truck builder on Job Que. (Y/N)
     *      - Added 1 new description to array DESC.
520aA*    10/11/07  LMC  5.20a P#00032
     *      - Added OPISHS to determine if additional history data is
     *        saved to LABELH,PIRTRANH,LICENSEH,LICINFOH
     *        Moved screen2 routines to Screen3, a new screen was
     *        required after screen1 for additional data now stored
     *        in the SYSTEM options record.
     *
530aA*    05/07/10  JCJ  5.30a
     *      - Changed OP210FM to OP21001.
     *      - Add new options W1ICWR, w1rncR
     *      - Added new option OPTRAX
640aA*    12/28/11  JCJ  6.40a
     *      - Changed OP21001 to OP21002.
650aA*    06/17/13  JCJ  6.50a
     *      - Changed OP21002 to OP21003.
     *      - Add new option W2slot
700a *    05/21/14  GJA  7.00a
     *      - Changed OP21003 to OP21004.
740a *    02/09/20  RTR  7.40a
     *      - Changed OP21004 to OP21005.
     *      - Add option W4LOT for IULOT/OPLOT.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
412 A*  63        FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530aD ***op210fm   cf   e             workstn
640aD ***1001   cf   e             workstn
650aD ***1002   cf   e             workstn
650aDF**op21003   cf   e             workstn
700aDF**op21004   cf   e             workstn
740aMFop21005   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
700aMD desc            s             30    dim(26) ctdata perrcd(1)
700aDD*desc            s             30    dim(25) ctdata perrcd(1)
650aDD*desc            s             30    dim(24) ctdata perrcd(1)
640aDD*desc            s             30    dim(21) ctdata perrcd(1)
520aMD*desc            s             30    dim(16) ctdata perrcd(1)
520aD*                   DESC    1  15 30
510aD*                   DESC    1  14 30
414aD*                   DESC    1   9 30
412 D*                   DESC    1   7 30
410 D*                   DESC    1   5 30
410 D*                   DESC    1   4 30
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
405 A*----------------------------------------------------------------
405 A*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
530aD*****OPWRNC  -  Perform catch weight variance check (Y,N).
530aM*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import Item fields (Y,N).
530aD*****OPICW   -  Individual catch weight entry (Y,N).
530aM*    OPICW   -  Check CW count during selection closing (N,M,C,B)
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
413aA*    OPRCDY  -  Number of days to keep receiving logs.
413aA*    OPMPCK  -  Number of days to keep picking logs.
414aA*    OPRTHS  -  Number of weeks - exported routes to keep.
414aA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
414aA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
414aA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
414aA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
510aA*    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
520aA*    OPISHS  -  Number of weeks to keep history file
530aA*    OPTRAX  -  Using TRAX module (Y/N).
640aA*    OPTAXR  -  Using TAXR module (Y/N).
640aA*    OPCHKR  -  Using CHKR module (Y/N).
640aA*    OPVOICE -  Using VOICE module (Y/N).
650aA*    OPSLOT  -  Print Slot barcode on Pick Label (Y/N).
700aA*    OPDSPL  -  Display last three of license plate (Y/N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
412 AD  opmpck                14     14
413aAD  oprcdy                15     15  0
413aAD  oppkdy                16     16  0
414aAD  oprths                17     19  0
414aAD  opcrhs                20     22  0
414aAD  oppohs                23     25  0
414aAD  opiahs                26     28  0
414aAD  opmshs                29     31  0
510aAD  optbjq                32     32
520aAD  opishs                33     35  0
530aAD  opishsa               33     35
530bAD  opuci                 36     36
530aAD  opwrncr               37     37
530aAD  opicwr                38     38
530aAD  optrax                39     39
640aAD  optaxr                40     40
640aAD  opchkr                41     41
640aAD  opvoice               42     42
650aAD  opslot                43     43
700aAD  opdspl                44     44
     D  optend               117    117
411 A*----------------------------------------------------------------
411 A*  *IMPITEM  -  Import Item options.
     *----------------------------------------------------------------
     *
     *    Y = Maintained by Host, imported to FSWMS
     * Fields
     *
     *    OPITYP  -  Item type
     *    OPDESC  -  Item description
     *    OPWHDP  -  Warehouse department
     *    OPSTYP  -  Section type
     *    OPWHDP  -  Default warehouse department
     *    OPDESG  -  Designation
     *    OPACTV  -  Activity
     *    OPBLD   -  Build code
     *    OPVEN#  -  Vendor number
     *    OPVIT#  -  Vendor item number
     *    OPPDSC  -  Pack description
     *    OPUM1   -  Normal unit of measure
     *    OPUM2   -  Breakdown 1 unit of measure
     *    OPUMQ2  -  Breakdown 1 UM quantity
     *    OPFLG1  -  Allow Breakdown 1 Sale
     *    OPUM3   -  Breakdown 2 unit of measure
     *    OPUMQ3  -  Breakdown 2 UM quantity
     *    OPFLG2  -  Allow Breakdown 2 Sale
     *    OPULEN  -  Unit length
     *    OPUWDT  -  Unit width
     *    OPUHGT  -  Unit height
     *    OPCUBE  -  Cube/Unit
     *    OPSWGT  -  Shipping weight
     *    OPCWGT  -  Catch weight
     *    OPREPL  -  Replenish level
     *    OPFLGD  -  Date sensitive
     *    OPFLGB  -  Allow bulk pick
     *    OPSLIF  -  Shelf life days
     *    OPNDAY  -  Notice days
     *    OPTIE   -  Mfr. Tie
     *    OPHIGH  -  Mfr. High
     *    OPMFLG  -  Manufacturing date
     *    OPDDAY  -  Distributor days
     *    OPUDAY  -  End user days
     *    OPMDAY  -  Mfr. shelf life days
     *    OPMITM  -  Master item number
     *    OPCITM  -  Contract Base item #
416a *    OPNSLT  -  Non-slotted item
416a *    OPXDCK  -  Crossdock item
416a *    OPBNBR  -  Buyer number
416a *    OPBNAM  -  Buyer name
416a *    OPVNAM  -  Vendor name
416a *    OPBRND  -  Brand
416a *    OPLOT   -  Lot code item
416a *    OPLTRK  -  Track by license
     *
     * Data structure
     *
411 D*PDATA      DS
     D  opityp                 1      1
     D  opdesc                 2      2
     D  opwhdp                 3      3
     D  opstyp                 4      4
     D  opdesg                 5      5
     D  opactv                 6      6
     D  opbld                  7      7
     D  opven#                 8      8
     D  opvit#                 9      9
     D  oppdsc                10     10
     D  opum1                 11     11
     D  opum2                 12     12
     D  opumq2                13     13
     D  opflg1                14     14
     D  opum3                 15     15
     D  opumq3                16     16
     D  opflg2                17     17
     D  opulen                18     18
     D  opuwdt                19     19
     D  opuhgt                20     20
     D  opcube                21     21
     D  opswgt                22     22
     D  opcwgt                23     23
     D  oprepl                24     24
     D  opflgd                25     25
     D  opflgb                26     26
     D  opslif                27     27
     D  opnday                28     28
     D  optie                 29     29
     D  ophigh                30     30
     D  opmflg                31     31
     D  opdday                32     32
     D  opuday                33     33
     D  opmday                34     34
     D  opmitm                35     35
     D  opcitm                36     36
416a D  opnslt                37     37
416a D  opxdck                38     38
416a D  opbnbr                39     39
416a D  opbnam                40     40
416a D  opvnam                41     41
416a D  opbrnd                42     42
416a D  oplot                 43     43
416a D  opltrk                44     44
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
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
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
     *----VARIABLES---------------------------------------------------
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
     D warn            s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
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
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
411 AC     nxtscr        caseq     '02 '         sc2
520aAC     nxtscr        caseq     '03 '         sc3
640aAC     nxtscr        caseq     '04 '         sc4
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
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
411 AC                   if        nxtscr = '02 '
411 AC                   exfmt     screen2                              50
411 AC                   endif
520aAC                   if        nxtscr = '03 '
520aAC                   exfmt     screen3                              50
520aAC                   endif
640aAC                   if        nxtscr = '04 '
640aAC                   exfmt     screen4                              50
640aAC                   endif
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
412 AC                   setoff                                         63
414aAC                   setoff                                         6465
414aAC                   setoff                                         6768
520aD*                    SETOF                       70
520aMC                   setoff                                       737072
640aAC                   setoff                                       747576
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
520aA*----------------------------------------------------------------
520aA*
520aA*  Screen 02 initialization
520aA*
520aAC     scr02i        begsr
520aAC                   eval      nxtscr = '02 '
520aA*
520aAC                   if        $pcmd = '*VIEW   '
520aAC                   eval      *in90 = *on
520aAC                   endif
520aA*
520aA*  Get field defaults if this is an add.
520aA*
520aAC                   if        $pcmd = '*ADD    '
520aAC                   exsr      zzdft2
520aAC                   else
520aA*
520aA*  Otherwise get existing record(s).
520aA*
520aAC                   eval      *in91 = *on
520aAC                   exsr      zzget2
520aAC                   exsr      zzfil2
520aAC                   endif
520aAC     end02i        endsr
411 A*----------------------------------------------------------------
411 A*
520aD*  Screen 02 initialization  - this has been renamed to scr03i
520aA*  Screen 03 initialization
411 A*
520aD*          SCR02I    BEGSR
520aAC     scr03i        begsr
520aD*                    MOVE '02 '     NXTSCR  3
520aAC                   eval      nxtscr = '03 '
411 A*
411 AC                   if        $pcmd = '*VIEW   '
411 AC                   eval      *in90 = *on
411 AC                   endif
411 A*
411 A*  Get field defaults if this is an add.
411 A*
411 AC                   if        $pcmd = '*ADD    '
520aD*                    EXSR ZZDFT2
520aAC                   exsr      zzdft3
411 AC                   else
411 A*
411 A*  Otherwise get existing record(s).
411 A*
411 AC                   eval      *in91 = *on
520aD*                    EXSR ZZGET2
520aD*                    EXSR ZZFIL2
520aAC                   exsr      zzget3
520aAC                   exsr      zzfil3
411 AC                   endif
520aD*          END02I    ENDSR
520aAC     end03i        endsr
640aA*----------------------------------------------------------------
640aA*  Screen 04 initialization
640aA*
640aAC     scr04i        begsr
640aAC                   eval      nxtscr = '04 '
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
640aAC     end04i        endsr
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
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     * This code was moved to sc2
411 A*  If OPIMPI Import Item Fields = Y, display screen 2.
411 A*
520aD*          OPIMPI    IFEQ 'Y'
411 AC                   exsr      scr02i
520aD*                    ELSE
     *
     *  Everything went fine so get out of program.
     *
520aD*                    MOVE 'EOJ'     NXTSCR
520aD*                    ENDIF
     C     endsc1        endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  SC2  -  Screen 2
520aA*
520aAC     sc2           begsr
520aA*
520aA*  Test for F3 - Exit
520aA*
520aAC                   if        *inkc
520aAC     *loval        setll     record
520aAC                   eval      nxtscr = 'EOJ'
520aAC                   eval      $prtn = '*EXIT   '
520aAC                   goto      endsc2
520aAC                   endif
520aA*
520aA*  Test for F5 - Refresh
520aA*
520aAC                   if        *inke
520aAC                   if        $pcmd <> '*VIEW   '
520aAC                   exsr      scr02i
520aAC                   endif
520aAC                   goto      endsc2
520aAC                   endif
520aA*
520aA*  Test for F12 - Previous
520aA*
520aAC                   if        *inkl
520aAC     *loval        setll     record
520aAC                   eval      nxtscr = 'EOJ'
520aAC                   eval      $prtn = '*CANCEL '
520aAC                   goto      endsc2
520aAC                   endif
520aA*
520aA*  Test for other command keys BEFORE verification and update.
520aA*
520aAC                   eval      cmdchk = '*BEFORE '
520aAC                   exsr      zzcmd2
520aAC     cmdtkn        cabeq     *on           endsc2
520aA*
520aA*  Some other key pressed.
520aA*
520aA*     Check input and write/update record.
520aA*
520aAC                   if        $pcmd = '*ADD    '  or
520aAC                             $pcmd = '*CHANGE '
520aAC                   exsr      zzchk2
520aAC     error         cabeq     '1'           endsc2
520aAC                   exsr      zzupd2
520aAC     error         cabeq     '1'           endsc2
520aAC                   endif
520aA*
520aA*  Test for other command keys AFTER verification and update.
520aA*
520aAC                   eval      cmdchk = '*AFTER  '
520aAC                   exsr      zzcmd2
520aAC     cmdtkn        cabeq     *on           endsc2
520aAC                   exsr      scr03i
520aAC     endsc2        endsr
411 A*----------------------------------------------------------------
411 A*
520aD*  SC2  -  Screen 2  this has been renamed
520aA*  SC3  -  Screen 3
411 A*
520aD*          SC2       BEGSR
520aAC     sc3           begsr
411 A*
411 A*  Test for F3 - Exit
411 A*
411 AC                   if        *inkc
411 AC     *loval        setll     record
411 AC                   eval      nxtscr = 'EOJ'
411 AC                   eval      $prtn = '*EXIT   '
520aD*                    GOTO ENDSC2
520aAC                   goto      endsc3
411 AC                   endif
411 A*
411 A*  Test for F5 - Refresh
411 A*
411 AC                   if        *inke
411 AC                   if        $pcmd <> '*VIEW   '
520aD*                    EXSR SCR02I
520aAC                   exsr      scr03i
411 AC                   endif
520aD*                    GOTO ENDSC2
520aAC                   goto      endsc3
411 AC                   endif
411 A*
411 A*  Test for F12 - Previous
411 A*
411 AC                   if        *inkl
411 AC     *loval        setll     record
411 AC                   eval      nxtscr = 'EOJ'
411 AC                   eval      $prtn = '*CANCEL '
520aD*                    GOTO ENDSC2
520aAC                   goto      endsc3
411 AC                   endif
411 A*
411 A*  Test for other command keys BEFORE verification and update.
411 A*
411 AC                   eval      cmdchk = '*BEFORE '
520aD*                    EXSR ZZCMD2
520aAC                   exsr      zzcmd3
520aD*          CMDTKN    CABEQ*ON       ENDSC2
520aAC     cmdtkn        cabeq     *on           endsc3
411 A*
411 A*  Some other key pressed.
411 A*
411 A*     Check input and write/update record.
411 A*
411 AC                   if        $pcmd = '*ADD    '  or
411 AC                             $pcmd = '*CHANGE '
520aAC                   exsr      zzchk3
520aAC     error         cabeq     '1'           endsc3
520aAC                   exsr      zzupd3
520aAC     error         cabeq     '1'           endsc3
411 AC                   endif
411 A*
411 A*  Test for other command keys AFTER verification and update.
411 A*
411 AC                   eval      cmdchk = '*AFTER  '
520aD*                    EXSR ZZCMD2
520aD*          CMDTKN    CABEQ*ON       ENDSC2
520aAC                   exsr      zzcmd3
519bAC     cmdtkn        cabeq     *on           endsc3
520aA*
520aA*  If OPIMPI Import Item Fields = Y, display screen 2.
520aA*
520aAC                   if        opimpi = 'Y'
640aAC                   exsr      scr04i
520aAC                   else
411 A*
411 A*  Everything went fine so get out of program.
411 A*
411 AC                   eval      nxtscr = 'EOJ'
520aAC                   endif
520aAC     endsc3        endsr
640aA*----------------------------------------------------------------
640aA*  SC4  -  Screen 4
640aA*
640aAC     sc4           begsr
     *
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
     C                   if        $pcmd = '*ADD    '
     C                             or $pcmd = '*CHANGE '
     C                   exsr      zzchk4
     C     error         cabeq     '1'           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     '1'           endsc4
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc4        endsr
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
    aC                   endsr
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
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
510a *  Verify Truck builder on Job Que option.
510a *
510a C                   if        w1tbjq <> 'Y'  and
510a C                             w1tbjq <> 'N'
510a C                   eval      error = *on
510a C                   eval      *in71 = *on
510a C                   eval      *in15 = *on
510a C                   eval      errmsg = *blanks
510a C                   movel     desc(15)      errmsg
510a C                   exsr      zm1005
510a C                   endif
     *
     *  Verify using EPM module option.
     *
     C                   if        w1epm <> 'Y'  and
     C                             w1epm <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify using RF module option.
     *
     C                   if        w1rf <> 'Y'  and
     C                             w1rf <> 'N'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1005
     C                   endif
530aA*
530aA*  Verify using TRAX module option.
530aA*
530aAC                   if        w1trax <> 'Y'
530aAC                             and w1trax <> 'N'
530aAC                   eval      error = *on
530aAC                   eval      *in73 = *on
530aAC                   eval      errmsg = *blanks
530aAC                   movel     desc(21)      errmsg
530aAC                   exsr      zm1005
530aAC                   endif
640aA*
640aA*  Verify using TAXRITE module option.
640aA*
640aAC                   if        w1taxr <> 'Y'
640aAC                             and w1taxr <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in74 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(22)      errmsg
640aAC                   exsr      zm1005
640aAC                   endif
640aA*
640aA*  Verify using CHECKRITE module option.
640aA*
640aAC                   if        w1chkr <> 'Y'
640aAC                             and w1chkr <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in75 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(23)      errmsg
640aAC                   exsr      zm1005
640aAC                   endif
640aA*
640aA*  Verify using VOICE module option.
640aA*
640aAC                   if        w1voice <> 'Y'
640aAC                             and w1voice <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in76 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(24)      errmsg
640aAC                   exsr      zm1005
640aAC                   endif
     *
     C     endck1        endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZCHK2   Screen 2 error checking.
520aA*
520aAC     zzchk2        begsr
520aAC                   eval      error = *off
     *
     *  Verify capture catch weights option.
     *
     C                   if        w2capc <> 'Y'  and
     C                             w2capc <> 'N'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1005
     C                   endif
412 A*
412 A*  Verify Individual catch weight entry option.
530aM*  Verify Check CW variance during selection option.
412 A*
530aMC                   if        w2icw <> 'N'  and
530aMC                             w2icw <> 'M'  and
530aAC                             w2icw <> 'C'  and
530aAC                             w2icw <> 'B'
412 AC                   eval      error = *on
412 AC                   eval      *in62 = *on
412 AC                   eval      *in12 = *on
412 AC                   eval      errmsg = *blanks
530aMC                   movel     desc(19)      errmsg
412 AC                   exsr      zm1005
412 AC                   endif
410 A*
410 A*  Verify perform catch weight variance check option.
530aM*  Verify CW variance during selection option.
410 A*
530aMC                   if        w2wrnc <> 'N'  and
530aMC                             w2wrnc <> 'M'  and
530aAC                             w2wrnc <> 'C'  and
530aAC                             w2wrnc <> 'B'
410 AC                   eval      error = *on
410 AC                   eval      *in25 = *on
410 AC                   eval      *in05 = *on
410 AC                   eval      errmsg = *blanks
530aMC                   movel     desc(20)      errmsg
410 AC                   exsr      zm1005
410 AC                   endif
530aA*
530aA*  Verify Check CW count during receiving option.
530aA*
530aAC                   if        w2icwr <> 'Y'  and
530aAC                             w2icwr <> 'N'
530aAC                   eval      error = *on
530aAC                   eval      *in80 = *on
530aAC                   eval      *in85 = *on
530aAC                   eval      errmsg = *blanks
530aAC                   movel     desc(17)      errmsg
530aAC                   exsr      zm1005
530aAC                   endif
     *
530aA*  Verify CW variance during receiving option.
530aA*
530aAC                   if        w2wrncr <> 'Y'  and
530aAC                             w2wrncr <> 'N'
530aAC                   eval      error = *on
530aAC                   eval      *in81 = *on
530aAC                   eval      *in86 = *on
530aAC                   eval      errmsg = *blanks
530aAC                   movel     desc(18)      errmsg
530aAC                   exsr      zm1005
530aAC                   endif
     *
     *  Verify print letdown labels option.
     *
     C                   if        w2letd <> 'Y'  and
     C                             w2letd <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1005
     C                   endif
411 A*
411 A*  Verify using import item fields.
411 A*
411 AC                   if        w2impi <> 'Y'  and
411 AC                             w2impi <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in61 = *on
411 AC                   eval      *in11 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(6)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
412 A*
412 A*  Verify allow multiple pick slots for fixed items.
412 A*
412 AC                   if        w2mpck <> 'Y'  and
412 AC                             w2mpck <> 'N'
412 AC                   eval      error = *on
412 AC                   eval      *in63 = *on
412 AC                   eval      *in07 = *on
412 AC                   eval      errmsg = *blanks
412 AC                   movel     desc(9)       errmsg
412 AC                   exsr      zm1005
412 AC                   endif
     *
650aA*  Verify print slot barcode on pick label question
     *
     C                   if        w2slot <> 'Y'
     C                             and w2slot <> 'N'
     C                   eval      error = *on
     C                   eval      *in77 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(25)      errmsg
     C                   exsr      zm1005
     C                   endif
700aA*
700aA*
700aA*  Verify only display last three of license plate
     *
     C                   if        w2dspl <> 'Y'
     C                             and w2dspl <> 'N'
     C                   eval      error = *on
     C                   eval      *in78 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(26)      errmsg
     C                   exsr      zm1005
     C                   endif
520aA*
520aAC     endck2        endsr
411 A*----------------------------------------------------------------
411 A*
520aD*  ZZCHK2   Screen 2 error checking. RENAMED
520aA*  ZZCHK3   Screen 3 error checking.
411 A*
520aAC     zzchk3        begsr
411 AC                   eval      error = *off
530aM*
530aM*    Verify nbr. weeks route history to keep.
530aM*
530aMC                   if        w3rths < 1  or
530aMC                             w3rths > 999
530aMC                   eval      error = *on
530aMC                   eval      *in66 = *on
530aMC                   eval      *in10 = *on
530aMC                   eval      errmsg = *blanks
530aMC                   eval      erfld = desc(10)
530aMC                   movel     '1'           erfrom
530aMC                   movel     '999'         erto
530aMC                   exsr      zm0112
530aMC                   endif
530aM*
530aM*    Verify nbr. weeks customer returns to keep.
530aM*
530aMC                   if        w3crhs < 1  or
530aMC                             w3crhs > 999
530aMC                   eval      error = *on
530aMC                   eval      *in67 = *on
530aMC                   eval      *in11 = *on
530aMC                   eval      errmsg = *blanks
530aMC                   eval      erfld = desc(11)
530aMC                   movel     '1'           erfrom
530aMC                   movel     '999'         erto
530aMC                   exsr      zm0112
530aMC                   endif
530aM*
530aM*    Verify nbr. weeks purchase order history to keep.
530aM*
530aMC                   if        w3pohs < 1  or
530aMC                             w3pohs > 999
530aMC                   eval      error = *on
530aMC                   eval      *in68 = *on
530aMC                   eval      *in12 = *on
530aMC                   eval      errmsg = *blanks
530aMC                   eval      erfld = desc(12)
530aMC                   movel     '1'           erfrom
530aMC                   movel     '999'         erto
530aMC                   exsr      zm0112
530aMC                   endif
530aM*
530aM*    Verify nbr. weeks inventory adjustments to keep.
530aM*
530aMC                   if        w3iahs < 1  or
530aMC                             w3iahs > 999
530aMC                   eval      error = *on
530aMC                   eval      *in69 = *on
530aMC                   eval      *in13 = *on
530aMC                   eval      errmsg = *blanks
530aMC                   eval      erfld = desc(13)
530aMC                   movel     '1'           erfrom
530aMC                   movel     '999'         erto
530aMC                   exsr      zm0112
530aMC                   endif
530aM*
530aM*    Verify nbr. weeks misc. transactions to keep.
530aM*
530aMC                   if        w3mshs < 1  or
530aMC                             w3mshs > 999
530aMC                   eval      error = *on
530aMC                   eval      *in70 = *on
530aMC                   eval      *in14 = *on
530aMC                   eval      errmsg = *blanks
530aMC                   eval      erfld = desc(14)
530aMC                   movel     '1'           erfrom
530aMC                   movel     '999'         erto
530aMC                   exsr      zm0112
530aMC                   endif
520aA*
520aA*    Verify nbr. weeks to keep history files
520aA*
520aAC                   if        w3ishs < 0  or
520aAC                             w3ishs > 999
520aAC                   eval      error = *on
520aAC                   eval      *in72 = *on
520aAC                   eval      *in16 = *on
520aAC                   eval      errmsg = *blanks
520aAC                   eval      erfld = desc(16)
520aAC                   movel     '0'           erfrom
520aAC                   movel     '999'         erto
520aAC                   exsr      zm0112
520aAC                   endif
520aA*
520aAC     endck3        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZCHK4   Screen 4 error checking.
640aA*
640aAC     zzchk4        begsr
     C                   eval      error = *off
     *
     *  Verify Import item type
     *
     C                   if        w4ityp <> 'Y'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify Import description.
     *
     C                   if        w4desc <> 'Y'  and
     C                             w4desc <> 'N'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(7)       errmsg
     C                   exsr      zm1005
     C                   endif
411 A*
411 A*  Verify import department.
411 A*
411 AC                   if        w4whdp <> 'Y'  and
411 AC                             w4whdp <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in28 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
410 A*
410 A*  Verify import section type.
410 A*
410 AC                   if        w4styp <> 'Y'  and
410 AC                             w4styp <> 'N'
410 AC                   eval      error = *on
410 AC                   eval      *in29 = *on
410 AC                   eval      errmsg = *blanks
410 AC                   movel     desc(7)       errmsg
410 AC                   exsr      zm1005
410 AC                   endif
411 A*
411 A*  Verify import designation.
411 A*
411 AC                   if        w4desg <> 'Y'  and
411 AC                             w4desg <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in30 = *on
410 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import activity.
411 A*
411 AC                   if        w4actv <> 'Y'  and
411 AC                             w4actv <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in31 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import build code.
411 A*
411 AC                   if        w4bld <> 'Y'  and
411 AC                             w4bld <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in32 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import vendor number
411 A*
411 AC                   if        w4ven# <> 'Y'  and
411 AC                             w4ven# <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in33 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import vendor item #
411 A*
411 AC                   if        w4vit# <> 'Y'  and
411 AC                             w4vit# <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in34 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import pack description
411 A*
411 AC                   if        w4pdsc <> 'Y'  and
411 AC                             w4pdsc <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in35 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import normal unit of measure
411 A*
411 AC                   if        w4um1 <> 'Y'  and
411 AC                             w4um1 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in36 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import breakdown 1 unit of measure
411 A*
411 AC                   if        w4um2 <> 'Y'  and
411 AC                             w4um2 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in37 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import breakdown 1 unit of measure qty.
411 A*
411 AC                   if        w4umq2 <> 'Y'  and
411 AC                             w4umq2 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in38 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import allow breakdown 1 sale.
411 A*
411 AC                   if        w4flg1 <> 'Y'  and
411 AC                             w4flg1 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in39 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import breakdown 2 unit of measure.
411 A*
411 AC                   if        w4um3 <> 'Y'  and
411 AC                             w4um3 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in40 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import breakdown 2 unit of measure qty.
411 A*
411 AC                   if        w4umq3 <> 'Y'  and
411 AC                             w4umq3 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in41 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import allow breakdown 2 sale.
411 A*
411 AC                   if        w4flg2 <> 'Y'  and
411 AC                             w4flg2 <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in42 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import unit length.
411 A*
411 AC                   if        w4ulen <> 'Y'  and
411 AC                             w4ulen <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in43 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import unit width.
411 A*
411 AC                   if        w4uwdt <> 'Y'  and
411 AC                             w4uwdt <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in44 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import unit height.
411 A*
411 AC                   if        w4uhgt <> 'Y'  and
411 AC                             w4uhgt <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in45 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import Cube/unit.
411 A*
411 AC                   if        w4cube <> 'Y'  and
411 AC                             w4cube <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in46 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import ship weight.
411 A*
411 AC                   if        w4swgt <> 'Y'  and
411 AC                             w4swgt <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in47 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import catch weight.
411 A*
411 AC                   if        w4cwgt <> 'Y'  and
411 AC                             w4cwgt <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in48 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import replenish level.
411 A*
411 AC                   if        w4repl <> 'Y'  and
411 AC                             w4repl <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in49 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import date sensitive.
411 A*
411 AC                   if        w4flgd <> 'Y'  and
411 AC                             w4flgd <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in50 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import allow bulk pick.
411 A*
411 AC                   if        w4flgb <> 'Y'  and
411 AC                             w4flgb <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in51 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import shelf life days.
411 A*
411 AC                   if        w4slif <> 'Y'  and
411 AC                             w4slif <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in52 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import notice days.
411 A*
411 AC                   if        w4nday <> 'Y'  and
411 AC                             w4nday <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in53 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import Mfg. Tie.
411 A*
411 AC                   if        w4tie <> 'Y'  and
411 AC                             w4tie <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in54 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import Mfg. High.
411 A*
411 AC                   if        w4high <> 'Y'  and
411 AC                             w4high <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in55 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import manufacturing date.
411 A*
411 AC                   if        w4mflg <> 'Y'  and
411 AC                             w4mflg <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in56 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import distributor days.
411 A*
411 AC                   if        w4dday <> 'Y'  and
411 AC                             w4dday <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in57 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import end user days.
411 A*
411 AC                   if        w4uday <> 'Y'  and
411 AC                             w4uday <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in58 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import manufacturer shelf life days.
411 A*
411 AC                   if        w4mday <> 'Y'  and
411 AC                             w4mday <> 'N'
411 AC                   eval      error = *on
411 AC                   eval      *in59 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 A*  Verify import master item number.
411 A*
411 AC                   if        w4mitm <> 'Y'
411 AC                   eval      error = *on
411 AC                   eval      *in60 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
411 A*
411 AC                   if        w4citm <> 'Y'
411 AC                   eval      error = *on
411 AC                   eval      *in61 = *on
411 AC                   eval      errmsg = *blanks
411 AC                   movel     desc(7)       errmsg
411 AC                   exsr      zm1005
411 AC                   endif
416 A*
416 AC                   if        w4bnbr <> 'Y'  and
416 AC                             w4bnbr <> 'N'
416 AC                   eval      error = *on
416 AC                   eval      *in62 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   movel     desc(7)       errmsg
416 AC                   exsr      zm1005
416 AC                   endif
416 A*
416 AC                   if        w4bnam <> 'Y'  and
416 AC                             w4bnam <> 'N'
416 AC                   eval      error = *on
416 AC                   eval      *in63 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   movel     desc(7)       errmsg
416 AC                   exsr      zm1005
416 AC                   endif
416 A*
416 AC                   if        w4vnam <> 'Y'  and
416 AC                             w4vnam <> 'N'
416 AC                   eval      error = *on
416 AC                   eval      *in64 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   movel     desc(7)       errmsg
416 AC                   exsr      zm1005
416 AC                   endif
416 A*
416 AC                   if        w4brnd <> 'Y'  and
416 AC                             w4brnd <> 'N'
416 AC                   eval      error = *on
416 AC                   eval      *in65 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   movel     desc(7)       errmsg
416 AC                   exsr      zm1005
416 AC                   endif
411 A*
640aAC     endck4        endsr
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
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZCMD2   User defined command keys for screen 2.
520aA*
520aAC     zzcmd2        begsr
520aA*
520aA*  Command keys to check BEFORE verification and update.
520aA*
520aAC                   if        cmdchk = '*BEFORE '
520aAC                   endif
520aA*
520aA*  Command keys to check AFTER verification and update.
520aA*
520aAC                   if        cmdchk = '*AFTER  '
520aAC                   endif
520aAC     endcm2        endsr
411 A*----------------------------------------------------------------
411 A*
520aD*  ZZCMD2   User defined command keys for screen 2. RENAMED
520aA*  ZZCMD3   User defined command keys for screen 2.
411 A*
520aD*          ZZCMD2    BEGSR
520aAC     zzcmd3        begsr
411 A*
411 A*  Command keys to check BEFORE verification and update.
411 A*
411 AC                   if        cmdchk = '*BEFORE '
411 AC                   endif
411 A*
411 A*  Command keys to check AFTER verification and update.
411 A*
411 AC                   if        cmdchk = '*AFTER  '
411 AC                   endif
520aD*          ENDCM2    ENDSR
520aAC     endcm3        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZCMD4   User defined command keys for screen 4.
640aA*
640aAC     zzcmd4        begsr
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
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
510aAC                   eval      optbjq = 'N'
     C                   eval      opepm = 'N'
     C                   eval      oprf = 'N'
530aAC                   eval      optrax = 'N'
640aAC                   eval      optaxr = 'N'
640aAC                   eval      opchkr = 'N'
640aAC                   eval      opvoice = 'N'
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZDFT2   Get default values for add.
520aA*
520aAC     zzdft2        begsr
     C                   eval      opcapc = 'Y'
410 AC                   eval      opicw = 'N'
410 AC                   eval      oprg1c = 0
410 AC                   eval      oprg2c = 0
412 AC                   eval      opwrnc = 'N'
530aAC                   eval      opicwr = 'N'
530aAC                   eval      opwrncr = 'N'
     C                   eval      opletd = 'Y'
411 AC                   eval      opimpi = 'N'
412 AC                   eval      opmpck = 'N'
650aAC                   eval      opslot = 'N'
700aAC                   eval      opdspl = 'N'
520aAC                   endsr
     *----------------------------------------------------------------
411 A*
520aD*  ZZDFT2   Get default values for add. this has been renamed
520aA*  ZZDFT3   Get default values for add.
411 A*
520aAC     zzdft3        begsr
413aAC                   eval      oprcdy = 0
413aAC                   eval      oppkdy = 0
414aAC                   eval      oprths = 1
414aAC                   eval      opcrhs = 1
414aAC                   eval      oppohs = 1
414aAC                   eval      opiahs = 1
414aAC                   eval      opmshs = 1
520aAC                   eval      opishs = 0
411 AC                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZDFT4   Get default values for add.
640aA*
640aAC     zzdft4        begsr
411 AC                   eval      opityp = 'Y'
411 AC                   eval      opdesc = 'N'
411 AC                   eval      opwhdp = 'N'
411 AC                   eval      opstyp = 'N'
411 AC                   eval      opdesg = 'N'
411 AC                   eval      opactv = 'N'
411 AC                   eval      opbld = 'N'
411 AC                   eval      opven# = 'N'
411 AC                   eval      opvit# = 'N'
411 AC                   eval      oppdsc = 'N'
411 AC                   eval      opum1 = 'N'
411 AC                   eval      opum2 = 'N'
411 AC                   eval      opumq2 = 'N'
411 AC                   eval      opflg1 = 'N'
411 AC                   eval      opum3 = 'N'
411 AC                   eval      opumq3 = 'N'
411 AC                   eval      opflg2 = 'N'
411 AC                   eval      opulen = 'N'
411 AC                   eval      opuwdt = 'N'
411 AC                   eval      opuhgt = 'N'
411 AC                   eval      opcube = 'N'
411 AC                   eval      opswgt = 'N'
411 AC                   eval      opcwgt = 'N'
411 AC                   eval      oprepl = 'N'
411 AC                   eval      opflgd = 'N'
411 AC                   eval      opflgb = 'N'
411 AC                   eval      opslif = 'N'
411 AC                   eval      opnday = 'N'
411 AC                   eval      optie = 'N'
411 AC                   eval      ophigh = 'N'
411 AC                   eval      opmflg = 'N'
411 AC                   eval      opdday = 'N'
411 AC                   eval      opuday = 'N'
411 AC                   eval      opmday = 'N'
411 AC                   eval      opmitm = 'Y'
413 AC                   eval      opcitm = 'N'
416aAC                   eval      opnslt = 'N'
416aAC                   eval      opxdck = 'N'
416aAC                   eval      opbnbr = 'N'
416aAC                   eval      opbnam = 'N'
416aAC                   eval      opvnam = 'N'
416aAC                   eval      opbrnd = 'N'
416aAC                   eval      oplot = 'N'
416aAC                   eval      opltrk = 'N'
411 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
510aAC                   eval      w1tbjq = optbjq
     C                   eval      w1epm = opepm
     C                   eval      w1rf = oprf
530aAC                   eval      w1trax = optrax
640aAC                   if        optaxr = *blanks
640aAC                   eval      w1taxr = 'N'
640aAC                   else
640aAC                   eval      w1taxr = optaxr
640aAC                   endif
640aAC                   if        opchkr = *blanks
640aAC                   eval      w1chkr = 'N'
640aAC                   else
640aAC                   eval      w1chkr = opchkr
640aAC                   endif
640aAC                   if        opvoice = *blanks
640aAC                   eval      w1voice = 'N'
640aAC                   else
640aAC                   eval      w1voice = opvoice
640aAC                   endif
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZFIL2   Fill screen 2 fields with info from file.
520aA*
520aAC     zzfil2        begsr
     C                   eval      w2capc = opcapc
412 AC                   eval      w2icw = opicw
410 AC                   eval      w2rg1c = oprg1c
410 AC                   eval      w2rg2c = oprg2c
410 AC                   eval      w2wrnc = opwrnc
530aAC                   eval      w2icwr = opicwr
530aAC                   eval      w2wrncr = opwrncr
     C                   eval      w2letd = opletd
411 AC                   eval      w2impi = opimpi
412 AC                   eval      w2mpck = opmpck
650aAC                   if        opslot = *blanks
650aAC                   eval      w2slot = 'N'
650aAC                   else
650aAC                   eval      w2slot = opslot
650aAC                   endif
700aAC                   if        opdspl = *blanks
700aAC                   eval      w2dspl = 'N'
700aAC                   else
700aAC                   eval      w2dspl = opdspl
700aAC                   endif
520aAC                   endsr
     *----------------------------------------------------------------
411 A*
520aD*  ZZFIL2   Fill screen 2 fields with info from file. RENAMED
520aA*  ZZFIL3   Fill screen 3 fields with info from file.
411 A*
520aAC     zzfil3        begsr
530aMC                   eval      w3rcdy = oprcdy
530aMC                   eval      w3pkdy = oppkdy
530aMC                   eval      w3rths = oprths
530aMC                   eval      w3crhs = opcrhs
530aMC                   eval      w3pohs = oppohs
530aMC                   eval      w3iahs = opiahs
530amC                   eval      w3mshs = opmshs
530amC                   if        opishsa = *blanks
530aMC                   eval      w3ishs = 0
530aMC                   else
530aMC                   eval      w3ishs = opishs
530aMC                   endif
411 AC                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZFIL4   Fill screen 4 fields with info from file.
640aA*
640aAC     zzfil4        begsr

411 AC                   eval      w4ityp = opityp
411 AC                   eval      w4desc = opdesc
411 AC                   eval      w4whdp = opwhdp
411 AC                   eval      w4styp = opstyp
411 AC                   eval      w4desg = opdesg
411 AC                   eval      w4actv = opactv
411 AC                   eval      w4bld = opbld
411 AC                   eval      w4ven# = opven#
411 AC                   eval      w4vit# = opvit#
411 AC                   eval      w4pdsc = oppdsc
411 AC                   eval      w4um1 = opum1
411 AC                   eval      w4um2 = opum2
411 AC                   eval      w4umq2 = opumq2
411 AC                   eval      w4flg1 = opflg1
411 AC                   eval      w4um3 = opum3
411 AC                   eval      w4umq3 = opumq3
411 AC                   eval      w4flg2 = opflg2
411 AC                   eval      w4ulen = opulen
411 AC                   eval      w4uwdt = opuwdt
411 AC                   eval      w4uhgt = opuhgt
411 AC                   eval      w4cube = opcube
411 AC                   eval      w4swgt = opswgt
411 AC                   eval      w4cwgt = opcwgt
411 AC                   eval      w4repl = oprepl
411 AC                   eval      w4flgd = opflgd
411 AC                   eval      w4flgb = opflgb
411 AC                   eval      w4slif = opslif
411 AC                   eval      w4nday = opnday
411 AC                   eval      w4tie = optie
411 AC                   eval      w4high = ophigh
411 AC                   eval      w4mflg = opmflg
411 AC                   eval      w4dday = opdday
411 AC                   eval      w4uday = opuday
411 AC                   eval      w4mday = opmday
411 AC                   eval      w4mitm = opmitm
413 AC                   eval      w4citm = opcitm
416aAC                   eval      w4bnbr = opbnbr
416aAC                   eval      w4bnam = opbnam
416aAC                   eval      w4vnam = opvnam
416aAC                   eval      w4brnd = opbrnd
740aAc                   eval      w4lot  = oplot
411 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*SYSTEM '
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
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZGET2   Get record(s) for screen 2.
520aA*
520aAC     zzget2        begsr
520aA*
520aAC                   eval      opwhse = 0
520aAC                   eval      opcode = '*SYSTEM '
520aA*
520aAC                   eval      tmpflg = *off
520aA*
520aAC     beggt2        tag
520aA*
520aA*   Get record from main file.
520aA*
520aAC                   if        $pcmd = '*VIEW   '
520aAC     fileky        chain(n)  record                             7978
520aAC                   else
520aAC     fileky        chain     record                             7978
520aAC                   endif
520aA*
520aA*  Record locked.
520aA*
520aAC                   if        *in78
520aAC                   eval      error = *on
520aAC                   eval      $prtn = '*PGMQ   '
520aAC                   exsr      zm74
520aAC                   goto      endgt2
520aAC                   endif
520aA*
520aA*  Record not found - Create it.
520aA*  Record would be created on screen1 - do not execute
520aA*
520aA*          *IN79     IFEQ *ON
520aA*          TMPFLG    IFEQ *OFF
520aA*                    MOVE *ON       TMPFLG
520aA*                    EXSR ZZDFT2
520aA*                    WRITERECORD
520aA*                    GOTO BEGGT2
520aA*                    ELSE
520aA*                    MOVE *ON       ERROR
520aA*                    MOVE '*PGMQ   '$PRTN
520aA*                    EXSR ZM73
520aA*                    GOTO ENDGT2
520aA*                    END
520aA*                    END
520aA*
520aAC     endgt2        endsr
411 A*----------------------------------------------------------------
411 A*
520aD*  ZZGET2   Get record(s) for screen 2. This has been renamed
520aA*  ZZGET3   Get record(s) for screen 3.
411 A*
520aD*          ZZGET2    BEGSR
520aAC     zzget3        begsr
411 A*
411 AC                   eval      opwhse = 0
411 AC                   eval      opcode = '*SYSTEM '
411 A*
411 AC                   eval      tmpflg = *off
411 A*
520aD*          BEGGT2    TAG
520aAC     beggt3        tag
411 A*
411 A*   Get record from main file.
411 A*
411 AC                   if        $pcmd = '*VIEW   '
411 AC     fileky        chain(n)  record                             7978
411 AC                   else
411 AC     fileky        chain     record                             7978
411 AC                   endif
411 A*
411 A*  Record locked.
411 A*
411 AC                   if        *in78
411 AC                   eval      error = *on
411 AC                   eval      $prtn = '*PGMQ   '
411 AC                   exsr      zm74
520aD*                    GOTO ENDGT2
520aAC                   goto      endgt3
411 AC                   endif
411 A*
411 A*  Record not found - Create it.
411 A*
411 AC                   if        *in79
411 AC                   if        tmpflg = *off
411 AC                   eval      tmpflg = *on
520aD*                    EXSR ZZDFT2
520aAC                   exsr      zzdft3
411 AC                   write     record
520aD*                    GOTO BEGGT2
520aAC                   goto      beggt3
411 AC                   else
411 AC                   eval      error = *on
411 AC                   eval      $prtn = '*PGMQ   '
411 AC                   exsr      zm73
520aD*                    GOTO ENDGT2
520aAC                   goto      endgt3
411 AC                   endif
411 AC                   endif
411 A*
520aD*          ENDGT2    ENDSR
520aAC     endgt3        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZGET4   Get record(s) for screen 4.
640aA*
640aAC     zzget4        begsr
411 A*
411 AC                   eval      opwhse = 0
411 AC                   eval      opcode = '*IMPITEM'
411 A*
411 AC                   eval      tmpflg = *off
411 A*
520aAC     beggt4        tag
411 A*
411 A*   Get record from main file.
411 A*
411 AC                   if        $pcmd = '*VIEW   '
411 AC     fileky        chain(n)  record                             7978
411 AC                   else
411 AC     fileky        chain     record                             7978
411 AC                   endif
411 A*
411 A*  Record locked.
411 A*
411 AC                   if        *in78
411 AC                   eval      error = *on
411 AC                   eval      $prtn = '*PGMQ   '
411 AC                   exsr      zm74
520aAC                   goto      endgt4
411 AC                   endif
411 A*
411 A*  Record not found - Create it.
411 A*
411 AC                   if        *in79
411 AC                   if        tmpflg = *off
411 AC                   eval      tmpflg = *on
520aAC                   exsr      zzdft4
411 AC                   write     record
520aAC                   goto      beggt4
411 AC                   else
411 AC                   eval      error = *on
411 AC                   eval      $prtn = '*PGMQ   '
411 AC                   exsr      zm73
520aAC                   goto      endgt4
411 AC                   endif
411 AC                   endif
411 A*
520aAC     endgt4        endsr
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
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
510aAC                   eval      optbjq = w1tbjq
     C                   eval      opepm = w1epm
     C                   eval      oprf = w1rf
530aAC                   eval      optrax = w1trax
640aAC                   eval      optaxr = w1taxr
640aAC                   eval      opchkr = w1chkr
640aAC                   eval      opvoice = w1voice
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
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZUPD2   Update record.
520aA*
520aAC     zzupd2        begsr
520aAC                   eval      error = *off
520aA*
520aA*  Move screen fields to record fields
520aA*
     C                   eval      opcapc = w2capc
412 AC                   eval      opicw = w2icw
410 AC                   eval      oprg1c = w2rg1c
410 AC                   eval      oprg2c = w2rg2c
410 AC                   eval      opwrnc = w2wrnc
530aAC                   eval      opicwr = w2icwr
530aAC                   eval      opwrncr = w2wrncr
     C                   eval      opletd = w2letd
411 AC                   eval      opimpi = w2impi
412 AC                   eval      opmpck = w2mpck
650aAC                   eval      opslot = w2slot
700aAC                   eval      opdspl = w2dspl
520aA*
520aA*   Update record (it was read and locked in ZZGET1)
520aA*
520aAC                   update    record                               79
520aAC                   if        *in79
520aAC                   eval      error = *on
520aAC                   exsr      zm72
520aAC                   goto      endup2
520aAC                   endif
520aA*
520aAC     endup2        endsr
520aA*
411 A*----------------------------------------------------------------
411 A*
520aA*  ZZUPD3   Update record.
411 A*
520aAC     zzupd3        begsr
411 AC                   eval      error = *off
411 A*
411 A*  Move screen fields to record fields
411 A*
530aMC                   eval      oprcdy = w3rcdy
530aMC                   eval      oppkdy = w3pkdy
530aMC                   eval      oprths = w3rths
530aMC                   eval      opcrhs = w3crhs
530aMC                   eval      oppohs = w3pohs
530aMC                   eval      opiahs = w3iahs
530aMC                   eval      opmshs = w3mshs
530aMC                   eval      opishs = w3ishs
411 A*
411 A*   Update record (it was read and locked in ZZGET2)
411 A*
411 AC                   update    record                               79
411 AC                   if        *in79
411 AC                   eval      error = *on
411 AC                   exsr      zm72
520aAC                   goto      endup3
411 AC                   endif
411 A*
520aAC     endup3        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZUPD4   Update record.
640aA*
640aAC     zzupd4        begsr
411 AC                   eval      error = *off
411 A*
411 A*  Move screen fields to record fields
411 A*
411 AC                   eval      opityp = w4ityp
411 AC                   eval      opdesc = w4desc
411 AC                   eval      opwhdp = w4whdp
411 AC                   eval      opstyp = w4styp
411 AC                   eval      opdesg = w4desg
411 AC                   eval      opactv = w4actv
411 AC                   eval      opbld = w4bld
411 AC                   eval      opven# = w4ven#
411 AC                   eval      opvit# = w4vit#
411 AC                   eval      oppdsc = w4pdsc
411 AC                   eval      opum1 = w4um1
411 AC                   eval      opum2 = w4um2
411 AC                   eval      opumq2 = w4umq2
411 AC                   eval      opflg1 = w4flg1
411 AC                   eval      opum3 = w4um3
411 AC                   eval      opumq3 = w4umq3
411 AC                   eval      opflg2 = w4flg2
411 AC                   eval      opulen = w4ulen
411 AC                   eval      opuwdt = w4uwdt
411 AC                   eval      opuhgt = w4uhgt
411 AC                   eval      opcube = w4cube
411 AC                   eval      opswgt = w4swgt
411 AC                   eval      opcwgt = w4cwgt
411 AC                   eval      oprepl = w4repl
411 AC                   eval      opflgd = w4flgd
411 AC                   eval      opflgb = w4flgb
411 AC                   eval      opslif = w4slif
411 AC                   eval      opnday = w4nday
411 AC                   eval      optie = w4tie
411 AC                   eval      ophigh = w4high
411 AC                   eval      opmflg = w4mflg
411 AC                   eval      opdday = w4dday
411 AC                   eval      opuday = w4uday
411 AC                   eval      opmday = w4mday
411 AC                   eval      opmitm = w4mitm
411 AC                   eval      opcitm = w4citm
416aAC                   eval      opbnbr = w4bnbr
416aAC                   eval      opbnam = w4bnam
416aAC                   eval      opvnam = w4vnam
416aAC                   eval      opbrnd = w4brnd
740aAc                   eval      oplot  = w4lot
411 A*
411 A*   Update record (it was read and locked in ZZGET2)
411 A*
411 AC                   update    record                               79
411 AC                   if        *in79
411 AC                   eval      error = *on
411 AC                   exsr      zm72
520aAC                   goto      endup4
411 AC                   endif
411 A*
640aAC     endup4        endsr
411 A*
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Using EPM Module
Using RF Module
Capture Catch Weights
Print Letdown Labels
Perform Catch Weight Check
Using Import Item Fields
Update Using Host Fields
Individual Catch Weight Entry
Allow multiple pick slots
Route history to keep
Customer returns to keep
Purchase orders to keep
Inventory adjustments to keep
Misc. transactions to keep
Run Truck builder on Job Que
History files to keep
CW Count during receiving
CW Variance during receiving
CW Count during selection
CW Variance during selection
Using TRAX module
Using TAXRITE module
Using CHECKRITE module
Using VOICE module
Prt Slot Barcode on Pick Label
Last three digits of license plate
