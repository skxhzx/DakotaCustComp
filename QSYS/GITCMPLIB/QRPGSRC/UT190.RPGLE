     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UT190   Change Zone Details for Truck/Zone
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
510 A*    07/25/06  MLB  5.10
     *      - Created.
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
     Fut190fm   cf   e             workstn
     F                                     infds(infds)
     Foptionz   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D inf             s             80    dim(6) ctdata perrcd(1)
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
     D opzdta          ds
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
     *  Working variables
     *
     D valid           c                   const('0123456789 ')
     D pos             s              5  0   inz(0)
     D pos1            s              5  0   inz(0)
     D pos2            s              5  0   inz(0)
     D NbrQtyCmbL      s                   like(opclvl)
     D Nbrerr          s                   like(operr )
     D Nbrcwgt         s                   like(opcwgt)
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
     C                   exsr      zmcpmq
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
     C                   endif
     C                   endif
     C                   endif
     *
     *  Verify zone
     *
     C                   if        w1zone <> '*ALL'  and
     C                             w1truk <> '*ALL'
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $ltruk = w1truk
     C                   eval      $lzone = w1zone
     C                   call      'TM900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   endif
     C                   endif
     C                   endif
     *
     *    ** If left blank, field(s) will not be updated.
     *
     *    Validate characters entered for qty level for combined labels.
     C                   eval      pos  = %check (valid : w1qty )
     *    Invalid characters in qty level for combined labels.
     C                   If           pos  > 0
     C                   eval      error = *on
     C                   eval      *in04 = *on
     C                   eval      *in24 = *on
     C                   movel     inf(02)       errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     *  Verify combined label warning - before/after.
     *
     C                   if            w1clb <> ' '
     C                             and w1clb <> 'Y'
     C                             and w1clb <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   movel     inf(03)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   if            w1cla <> ' '
     C                             and w1cla <> 'Y'
     C                             and w1cla <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     inf(03)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify unit of measure warning - before/after.
     *
     C                   if            w1umb <> ' '
     C                             and w1umb <> 'Y'
     C                             and w1umb <> 'N'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   movel     inf(04)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   if            w1uma <> ' '
     C                             and w1uma <> 'Y'
     C                             and w1uma <> 'N'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   movel     inf(04)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *    Validate characters entered for discrepancy label ratio.
     *
     C                   eval      pos1 = %check (valid : w1dsl )
     *      Invalid characters found, flag field.
     C                   If           pos1 > 0
     C                   eval      error = *on
     C                   eval      *in09 = *on
     C                   eval      *in29 = *on
     C                   movel     inf(05)       errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     *    Validate characters entered for catchweight label ratio.
     *
     C                   eval      pos2 = %check (valid : w1cwl )
     *      Invalid characters found, flag field.
     C                   If           pos2 > 0
     C                   eval      error = *on
     C                   eval      *in13 = *on
     C                   eval      *in30 = *on
     C                   movel     inf(06)       errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     *    Convert characters entered into numeric fields.
     C                   eval      nbrqtycmbl = 0
     C                   eval      nbrerr     = 0
     C                   eval      nbrcwgt    = 0
     *
     C                   if        w1qty  > ' '
     C                             and pos = 0
     C                   eval      nbrqtycmbl = %dec(w1qty:3:0)
     C                   endif
     *
     C                   if        w1dsl > ' '
     C                             and pos = 0
     C                   eval      nbrerr = %dec(w1dsl:2:0)
     C                   endif
     *
     C                   if        w1cwl > ' '
     C                             and pos = 0
     C                   eval      nbrcwgt = %dec(w1cwl:2:0)
     C                   endif
     *
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
     C                   call      'TM900'
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
     *  ZZCHG    Change Zone Details for Trucks/Zones
     *
     C     zzchg         begsr
     *
     C                   eval      kyzcod = '*PICKLBL'
     *
     *      Update ALL trucks and ALL zones.
     C                   select
     C                   when      w1truk = '*ALL'  and
     C                             w1zone = '*ALL'
     C     keyzhw        setll     optionz
     *
     C                   dow       forevr = forevr
     C     keyzhw        reade     optionz                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        w1qty <> ' '
     C                   eval      opclvl = nbrqtycmbl
     C                   endif
     *
     C                   if        w1clb <> ' '
     C                   eval      opcwrb = w1clb
     C                   endif
     *
     C                   if        w1cla <> ' '
     C                   eval      opcwra = w1cla
     C                   endif
     *
     C                   if        w1umb <> ' '
     C                   eval      opuwrb = w1umb
     C                   endif
     *
     C                   if        w1uma <> ' '
     C                   eval      opuwra = w1uma
     C                   endif
     *
     C                   if        w1dsl <> ' '
     C                   eval      operr  = nbrerr
     C                   endif
     *
     C                   if        w1cwl <> ' '
     C                   eval      opcwgt = nbrcwgt
     C                   endif
     *
     C                   update    opzrec
     C                   enddo
     *
     *      Update ONE truck and ALL zones.
     C                   when      w1truk <> '*ALL'  and
     C                             w1zone = '*ALL'
     C     keyzht        setll     optionz
     *
     C                   dow       forevr = forevr
     C     keyzht        reade     optionz                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        w1qty <> ' '
     C                   eval      opclvl = nbrqtycmbl
     C                   endif
     *
     C                   if        w1clb <> ' '
     C                   eval      opcwrb = w1clb
     C                   endif
     *
     C                   if        w1cla <> ' '
     C                   eval      opcwra = w1cla
     C                   endif
     *
     C                   if        w1umb <> ' '
     C                   eval      opuwrb = w1umb
     C                   endif
     *
     C                   if        w1uma <> ' '
     C                   eval      opuwra = w1uma
     C                   endif
     *
     C                   if        w1dsl <> ' '
     C                   eval      operr  = nbrerr
     C                   endif
     *
     C                   if        w1cwl <> ' '
     C                   eval      opcwgt = nbrcwgt
     C                   endif
     *
     C                   update    opzrec
     C                   enddo
     *
     *      Update ONE truck and ONE zone.
     C                   when      w1truk <> '*ALL'  and
     C                             w1zone <> '*ALL'
     C     keyzhz        setll     optionz
     *
     C                   dow       forevr = forevr
     C     keyzhz        reade     optionz                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        w1qty <> ' '
     C                   eval      opclvl = nbrqtycmbl
     C                   endif
     *
     C                   if        w1clb <> ' '
     C                   eval      opcwrb = w1clb
     C                   endif
     *
     C                   if        w1cla <> ' '
     C                   eval      opcwra = w1cla
     C                   endif
     *
     C                   if        w1umb <> ' '
     C                   eval      opuwrb = w1umb
     C                   endif
     *
     C                   if        w1uma <> ' '
     C                   eval      opuwra = w1uma
     C                   endif
     *
     C                   if        w1dsl <> ' '
     C                   eval      operr  = nbrerr
     C                   endif
     *
     C                   if        w1cwl <> ' '
     C                   eval      opcwgt = nbrcwgt
     C                   endif
     *
     C                   update    opzrec
     C                   enddo
     *
     *      Update ALL trucks and ONE zone.
     C                   when      w1truk = '*ALL'  and
     C                             w1zone <> '*ALL'
     C     keyzhw        setll     optionz
     *
     C                   dow       forevr = forevr
     C     keyzhw        reade     optionz                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        opzzon <> w1zone
     C                   iter
     C                   endif
     *
     C                   if        w1qty <> ' '
     C                   eval      opclvl = nbrqtycmbl
     C                   endif
     *
     C                   if        w1clb <> ' '
     C                   eval      opcwrb = w1clb
     C                   endif
     *
     C                   if        w1cla <> ' '
     C                   eval      opcwra = w1cla
     C                   endif
     *
     C                   if        w1umb <> ' '
     C                   eval      opuwrb = w1umb
     C                   endif
     *
     C                   if        w1uma <> ' '
     C                   eval      opuwra = w1uma
     C                   endif
     *
     C                   if        w1dsl <> ' '
     C                   eval      operr  = nbrerr
     C                   endif
     *
     C                   if        w1cwl <> ' '
     C                   eval      opcwgt = nbrcwgt
     C                   endif
     *
     C                   update    opzrec
     C                   enddo
     *
     C                   endsl
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
     C                   eval      w1zone = *blanks
     C                   eval      w1qty  = *blanks
     C                   eval      w1clb  = *blanks
     C                   eval      w1cla  = *blanks
     C                   eval      w1umb  = *blanks
     C                   eval      w1uma  = *blanks
     C                   eval      w1dsl  = *blanks
     C                   eval      w1cwl  = *blanks
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
     C     keyzhz        klist
     C                   kfld                    kyzcod
     C                   kfld                    w1whse
     C                   kfld                    w1truk
     C                   kfld                    w1zone
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
Changing zone options for truck(s)
Only numbers or blanks allowed for qty level      02
Only blanks, Y or N allowed for combined warning  03
Only blanks, Y or N allowed for UofM warning      04
Only numbers or blanks allowed for discrepancy lbl05
Only numbers or blanks allowed for catchwgt lbl   06
