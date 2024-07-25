      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. UT230MBF WILL BE REPALCED WITH UT230MB1
     *----------------------------------------------------------------
     *
     *  UT230MB   Change BULK cube for pick zone/truck
     *  Max Blacknik
     *
     *  Revisions
416 A*    08/06/02  MLB  4.16
     *      - Created.
     *
510 A*    10/16/07  JCJ  5.10
     *      - Add edit to require truck tempalte entry only.
     *
     *----------------------------------------------------------------
     *  Notes
     *       The format for this program needs to be compiled with
     *       DFRWRT=*NO so that status messages can be displayed.
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT LOG NUMBER)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
510 D *ut230mbf  cf   e             workstn
510 MFut230mb1  cf   e             workstn
     F                                     infds(infds)
     Foptionz   uf   e           k disk
510 AFtruckh1   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D inf             s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
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
414aAD  $lzone                32     37
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
416 A*     06/20/01  MLB  4.16
     *       - Added new option for field OPPBLD for
     *         record *PICK.
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
213 D*I            0                         8   90OPBPCK
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     *I            0                        21  210OPFSTP
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 D*                                      31  31 OPPBRK
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
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
     D  ercnt                  1      3p 0
     *
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
510 AD #error1         c                   const('must be a truck template')
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
     *  Work Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D cmdchk          s              8
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D forevr          s              1
     D kyzcod          s              8
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   exsr      zmcpmq
     C                   exsr      zzinz2
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
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
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
    MC                   exsr      zmcpmq
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
     *  Get existing record.
     *
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get existing record.
     *
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   exsr      zzfil3
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
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zznxt1
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     *R         *INKC     IFEQ *ON
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC2
     *R                   END
     *
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
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
     *
     *  Test for other command keys AFTER verification and update.
     *
     *R                   MOVE '*AFTER  'CMDCHK
     *R                   EXSR ZZCMD2
     *R         CMDTKN    CABEQ*ON       ENDSC2
     *
     *  Everything went fine so get out of program.
     *
     *R                   MOVE 'EOJ'     NXTSCR
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     *R         *INKC     IFEQ *ON
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC3
     *R                   END
     *
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
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
     *
     *  Test for other command keys AFTER verification and update.
     *
     *R                   MOVE '*AFTER  'CMDCHK
     *R                   EXSR ZZCMD3
     *R         CMDTKN    CABEQ*ON       ENDSC3
     *
     *  Everything went fine so get out of program.
     *
     *R                   MOVE 'EOJ'     NXTSCR
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
     *  Initialize message handling
     *
    D*                    EXSR ZMIMSG
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL22201  Slots cannot be deleted.
     *
     C     zm2201        begsr
     C                   eval      #msgid = 'SL22201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL22202  Slots deleted.
     *
     C     zm2202        begsr
     C                   eval      #msgid = 'SL22202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL22203  Checking for active slots (Info msg)
     *
     C     zm2203        begsr
     C                   eval      #msgid = 'SL22203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL22204  Deleting records (Info msg)
     *
     C     zm2204        begsr
     C                   eval      #msgid = 'SL22204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   CPF9897  Informational message
     *
     C     zm9897        begsr
     C                   eval      #msgid = 'CPF9897'
     C                   eval      #msgtp = '*DIAG  '
     **                   MOVEAERR128    $MD
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Code must be entered for create.
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0201'
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
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
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
    D**                   EXSR ZMQMSG
     C                   endif
     C                   endif
     *
     *  Verify truck
     *
     C                   if        w1truk <> '*ALL'
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $ltruk = w1truk
     C                   call      'TM900'
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
     **                   EXSR ZMQMSG
     C                   endif
     C                   endif
     C                   endif
414aA*
414aA*  Verify zone
414aA*
414aAC                   if        w1zone <> '*ALL'  and
414aAC                             w1truk <> '*ALL'
414aAC                   eval      $lcmd = '*VERIFY '
414aAC                   eval      $lwhse = w1whse
414aAC                   eval      $ltruk = w1truk
414aAC                   eval      $lzone = w1zone
414aAC                   call      'TM900'
414aAC                   parm                    $lparm
414aAC                   if        $lrtn = '*ERROR  '
414aAC                   eval      error = *on
414aAC                   eval      *in25 = *on
414aAC                   eval      *in05 = *on
414aAC                   movel     $lerm         errmsg
414aAC                   exsr      zm0105
414aAC                   else
414aAC                   if        $lrtn = '*PGMQ   '
414aAC                   eval      error = *on
414aAC                   eval      *in25 = *on
414aAC                   eval      *in05 = *on
414aAC                   eval      #msgk = $lmsg
414aA**                   EXSR ZMQMSG
414aAC                   endif
414aAC                   endif
414aAC                   endif
510 A*
510 A*    Truck must be a Truck Template
510 A*
510 AC     keyth         setll     truckh1
510 AC                   if        not %equal
510 AC                   eval      error = *on
510 AC                   eval      *in25 = *on
510 AC                   eval      *in05 = *on
510 AC                   movel     #error1       errmsg
510 AC                   eval      errmsg = %trim(w1truk) + ' ' + #error1
510 AC                   exsr      zm0105
510 AC                   endif
     *
     *    Make sure program was entered
     *
     C                   if        w1bcub <= 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      errmsg = *blanks
     C                   movel     'Program'     errmsg
     C                   exsr      zm03
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
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
     *     Warehouse department.
     *
     C                   select
     C                   when      row# = 08
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Truck.
     *
     C                   when      row# = 9
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $ltruk = w1truk
510 D ***                call      'TM900'
510  C                   call      'TM950'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1truk = $ltruk
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
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
     *  Test for F10 - continue
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   eval      nxtscr = '03 '
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
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F22 - continue
     *
     C                   if        *inkw
     *
     *  Put out info message.
     C                   eval      $md = *blanks
     C                   movea     inf(1)        $md
     C                   exsr      zm9897
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zzchg
     C                   eval      cmdtkn = *on
     C                   eval      nxtscr = '01 '
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *  ZZCHG    Change trucks
     *
     C     zzchg         begsr
     *
     C                   eval      kyzcod = '*PICK   '
414aMC                   select
414aMC                   when      w1truk = '*ALL'  and
414aMC                             w1zone = '*ALL'
     *
414aMC     keyzhw        setll     optionz
414a *
414  C                   dow       forevr = forevr
414aMC     keyzhw        reade     optionz                                79
414aMC                   if        *in79
414aMC                   leave
414aMC                   endif
414aMC                   eval      opbpck = w1bcub
414aMC                   update    opzrec
414a C                   enddo
     *
414aMC                   when      w1truk <> '*ALL'  and
414aMC                             w1zone = '*ALL'
414aMC     keyzht        setll     optionz
414a *
414  C                   dow       forevr = forevr
414aMC     keyzht        reade     optionz                                79
414aMC                   if        *in79
414aMC                   leave
414aMC                   endif
414aMC                   eval      opbpck = w1bcub
414aMC                   update    opzrec
414aMC                   enddo
     *
414aMC                   when      w1truk <> '*ALL'  and
414aMC                             w1zone <> '*ALL'
414aMC     keyzhz        setll     optionz
414a *
414  C                   dow       forevr = forevr
414aMC     keyzhz        reade     optionz                                79
414aMC                   if        *in79
414aMC                   leave
414aMC                   endif
414aMC                   eval      opbpck = w1bcub
414aMC                   update    opzrec
414aMC                   enddo
     *
414aMC                   when      w1truk = '*ALL'  and
414aMC                             w1zone <> '*ALL'
414aMC     keyzhw        setll     optionz
414a *
414  C                   dow       forevr = forevr
414aMC     keyzhw        reade     optionz                                79
414aMC                   if        *in79
414aMC                   leave
414aMC                   endif
414aMC                   if        opzzon <> w1zone
414aMC                   iter
414aMC                   endif
414aMC                   eval      opbpck = w1bcub
414aMC                   update    opzrec
414aMC                   enddo
     *
414aMC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     C                   eval      w1truk = *blanks
     C                   eval      w1bcub = 0
414aAC                   eval      w1zone = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     *
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *on
     *
     *  Define partial key for OPTIONZ file
     *
     C     keyzhw        klist
     C                   kfld                    kyzcod
     C                   kfld                    w1whse
     *
     C     keyzht        klist
     C                   kfld                    kyzcod
     C                   kfld                    w1whse
     C                   kfld                    w1truk
     *
414aAC     keyzhz        klist
414aAC                   kfld                    kyzcod
414aAC                   kfld                    w1whse
414aAC                   kfld                    w1truk
414aAC                   kfld                    w1zone
510 A*
510 AC     keyth         klist
510 AC                   kfld                    w1whse
510 AC                   kfld                    w1truk
     *
     C                   eval      #pgmq = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     *
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     C                   exsr      scr02i
     *
     C     endnx1        endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT2   What to do next when screen 2 input is ok.
     *
     C     zznxt2        begsr
     *
     C     endnx2        endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT3   What to do next when screen 3 input is ok.
     *
     C     zznxt3        begsr
     *
     C     endnx3        endsr
     *
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Changing Bulk Cube limit for truck(s)
