      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. UT110DSF WILL BE REPALCED WITH UT110DS1
     *----------------------------------------------------------------
     *
     *  UT110DS   Change label program for truck
     *  Dave Sommerville
     *
     *  Revisions
414aA*    05/17/00  RH    4.14
     *      - Add option to change the label program for a pick zone.
     *
500 A*    11/17/05  DAS   5.00
     *      - Converted to ILE
     *      - Added Form Type
     *      - Revised to only update field if entry field is not blank.
     *
510 A*    10/17/07  JCJ  5.10
     *      - Add edit to require truck tempalte entry only.
     *
520iA*    11/14/11  JCJ  6.40a
     *      - Enh: Add *PICKLBA.
     *
640aA*    11/14/11  JCJ  6.40a
     *      - Enh: Change field names to match new Keycod DS *PICKLBA.
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
510 D *ut110dsf  cf   e             workstn
510 MFut110ds1  cf   e             workstn
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
     *  *PICKLBL  -  Picking label options
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - Added field OPPDEV.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
300 A*    OPPDEV  -  Printer device.
300 A*    OPPFRM  -  Printer form.
     *
     * Data structure
     *
520iD *opzdta          ds
520iMD opzdta1         ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
300 AD  oppdev                65     74
300 AD  oppfrm                75     84
     D  optend               117    117
     *----------------------------------------------------------------
520iA*  *PICKLBA -  Label printing options for the standard pick,
520iA*              retail, and tote labels.
     *
520iA*     08/12/09  RBD  5.20  P#00219
520iA*       - Added record type *PICKLBA which holds printing info
520iA*         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opzdta          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117
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
     *  Variables
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
640aAC                   if        w1truk <> '*ALL'
510 AC     keyth         setll     truckh1
510 AC                   if        not %equal
510 AC                   eval      error = *on
510 AC                   eval      *in25 = *on
510 AC                   eval      *in05 = *on
510 AC                   movel     #error1       errmsg
510 AC                   eval      errmsg = %trim(w1truk) + ' ' + #error1
510 AC                   exsr      zm0105
510 AC                   endif
640aAC                   endif
     *
     *    Make sure program was entered
     *
500 A*    ** As of 5.00, the field is optional.
500 A*    ** If left blank,field will not be updated.
     *
500 DC**                 if        w1pgm = *blanks
500 DC**                 eval      error = *on
500 DC**                 eval      *in23 = *on
500 DC**                 eval      errmsg = *blanks
500 DC**                 movel     'Program'     errmsg
500 DC**                 exsr      zm03
500 DC**                 endif
     *
     *    Make sure device was entered
     *
500 A*    ** As of 5.00, the field is optional.
500 A*    ** If left blank,field will not be updated.
     *
500 DC**                 if        w1dev = *blanks
500 DC**                 eval      error = *on
500 DC**                 eval      *in24 = *on
500 DC**                 eval      errmsg = *blanks
500 DC**                 movel     'Device'      errmsg
500 DC**                 exsr      zm03
500 DC**                 endif
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
510 AC                   call      'TM950'
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
640aD ***                eval      kyzcod = '*PICKLBL'
640aMC                   eval      kyzcod = '*PICKLBA'
414aD*R         W1TRUK    IFEQ '*ALL'
414aD*R         KEYZHW    SETLLOPTIONZ
414aD*R                   ELSE
414aD*R         KEYZHT    SETLLOPTIONZ
414aD*R                   ENDIF
414aD*
414aD*R         FOREVR    DOWEQFOREVR
414aD*
414aD*R         W1TRUK    IFEQ '*ALL'
414aD*R         KEYZHW    READEOPTIONZ                  79
414aD*R                   ELSE
414aD*R         KEYZHT    READEOPTIONZ                  79
414aD*R                   ENDIF
414aD*R         *IN79     IFEQ *ON
414aD*R                   LEAVE
414aD*R                   ENDIF
414aD*R                   MOVE W1PGM     OPLPGM
414aD*R                   MOVE W1DEV     OPPDEV
414aD*R                   UPDATOPZREC
414aD*
414aD*R                   ENDDO
414a *
414aMC                   select
414aMC                   when      w1truk = '*ALL'  and
414aMC                             w1zone = '*ALL'
414aMC     keyzhw        setll     optionz
414a *
414  C                   dow       forevr = forevr
414aMC     keyzhw        reade     optionz                                79
414aMC                   if        *in79
414aMC                   leave
414aMC                   endif
500 AC                   if        w1pgm <> ' '
640aD ***                eval      oplpgm = w1pgm
640aMC                   eval      oplp1 = w1pgm
500 AC                   endif
500 AC                   if        w1dev <> ' '
640aD ***                eval      oppdev = w1dev
640aMC                   eval      opdv1 = w1dev
500 AC                   endif
500 AC                   if        w1form <> ' '
640aD ***                eval      oppfrm = w1form
640aMC                   eval      opfm1 = w1form
500 AC                   endif
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
500 AC                   if        w1pgm <> ' '
640aD ***                eval      oplpgm = w1pgm
640aMC                   eval      oplp1 = w1pgm
500 AC                   endif
500 AC                   if        w1dev <> ' '
640aD ***                eval      oppdev = w1dev
640aMC                   eval      opdv1 = w1dev
500 AC                   endif
500 AC                   if        w1form <> ' '
640aD ***                eval      oppfrm = w1form
640aMC                   eval      opfm1 = w1form
500 AC                   endif
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
500 AC                   if        w1pgm <> ' '
640aD ***                eval      oplpgm = w1pgm
640aMC                   eval      oplp1 = w1pgm
500 AC                   endif
500 AC                   if        w1dev <> ' '
640aD ***                eval      oppdev = w1dev
640aMC                   eval      opdv1 = w1dev
500 AC                   endif
500 AC                   if        w1form <> ' '
640aD ***                eval      oppfrm = w1form
640aMC                   eval      opfm1 = w1form
500 AC                   endif
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
500 AC                   if        w1pgm <> ' '
640aD ***                eval      oplpgm = w1pgm
640aMC                   eval      oplp1 = w1pgm
500 AC                   endif
500 AC                   if        w1dev <> ' '
640aD ***                eval      oppdev = w1dev
640aMC                   eval      opdv1 = w1dev
500 AC                   endif
500 AC                   if        w1form <> ' '
640aD ***                eval      oppfrm = w1form
640aMC                   eval      opfm1 = w1form
500 AC                   endif
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
     C                   eval      w1pgm = *blanks
414aAC                   eval      w1zone = *blanks
500 AC                   eval      w1dev  = *blanks
500 AC                   eval      w1form = *blanks
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
Changing label program for truck(s)
