      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER380     Management report for a selection crew.
     *  April 06, 2000
     *  Hemant Kapadia
     *
     *  04/06/00  HNK  4.13
     *    Created
     *
     * Note: Replaces ER280
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *  07/24/09  GJA  5.30
     *    - Enh:  converted to RPGLE, cleaned up and revamped for
     *            suspended transactions
     *
530a *  06/09/10  GJA  5.30a
     *    - Enh:  added detail option to also run report by
     *            employee/zone and zone/employee
530b *  08/27/10  GJA  5.30b
     *    - Enh:  add client custom code
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions - Dairyland
     *
DRYa *  08/28/10  GJA  DRYa
     *    - Default job queue to be yes.
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions - Crumbley
     *
CPCa *  05/12/11  GJA  CPCa
     *    - Default time, date and crew
CPCb *  05/14/12  MLB  CPCb
     *    - Revised CPCa to change end time to 20:00 from 18:00.
     *      Default printer changed to OFFICE1 from WHSE1 in file
     *      REPORTE for ER381PR, ER382PR.
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Jordano
JORa *  05/23/11  RH   JORa
     *    - Enh: default time to 500 not 400
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Fischer
     *
FSHa *  06/02/10  GJA  FSHa
     *    - Change end time to be 6:00 am instead of 4:00 am
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
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer380fm   cf   e             workstn
     F                                     infds(infds)
     Foptione   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D*desc            s             60    dim(9) ctdata perrcd(1)
     D desc            s             60    dim(10) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D                 ds
     D  t#date                 1      6
     D  month                  1      2  0
     D  day                    3      4  0
     D  year                   5      6  0
530bA*----------------------------------------------------------------
530bA*  Customer id
530bA*
     D @getcl          c                   const('GETCLIENT')
530bA*
DRYaA /copy qcopysrc,id#dairyla
CPCaA /copy qcopysrc,id#cpc
JORaA /copy qcopysrc,id#jordano
FSHaA /copy qcopysrc,id#fischer
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
     D  $ltask                19     24
     *
     D  $lwhse                19     21  0
     D  $lcrew                22     27
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdate                 1      4p 0
     D  erday                  5     14
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
     D                 ds
     D  wrkhh                  1      2  0
     D  wrkmm                  3      4  0
     D  wrkss                  5      6  0
     D  wrktim                 1      6  0
     *----------------------------------------------------------------
     *  *USER   -  User Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N)
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Voice Module? (Y/N)
     *    OPZORD  -  Zone or Department. (Z/D)
     *    OPTBD   -  Tote/Box/Drop? (Y/N)
     *----------------------------------------------------------------
     D opdta           ds
     D  OPMAN                  1      1
     D  OPNXTE                 2      6  0
     D  OPVYN                  7      7
     D  OPZORD                 8      8
     D  OPTBD                  9      9
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D begjul          s              5  0
     D cmdtkn          s              1
     D dayolp          s              4
     D dtfrmt          s              1  0
     D e               s              2  0
     D endgrg          s              6
     D endjul          s              5  0
     D error           s              1
     D forevr          s              1
     D fromdt          s              8  0
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
     D gmwksv          s              2  0
     D gtdate          s              8  0
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
     D KYwhse          s              3  0
     D nxtscr          s              3
     D sclear          s              1
     D todt            s              8  0
     D usname          s             40
     D w@date          s               d
     D warn            s              1
     D work1a          s              1
     D work2           s              2
     D work4           s              4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PFMDT  From date (YYYYMMDD)
     *      $PENDT  End date (YYYYMMDD) - Calculated (To date + 1)
     *      $PWHSE  Warehouse code
     *      $PEMP#  Employee number
     *      $PJOBQ  Put on jobq (Y,N)
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *      $PZNDP  Zone or Department (Z,D)
     *      $PDETL  Zone or Department (Z,D)
     *      $PVYN   Voice (Y,N)
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pwhse            3
     C                   parm                    $pcrew            6
     C                   parm                    $pjobq            1
     C                   parm                    $prtn             8
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $ptodt            8
     C                   parm                    $pmrg             1
     C                   parm                    $pzord            1
     C                   parm                    $pvyn             1
     C                   parm                    $ptbd             1
     C                   parm                    $pfmtm            6
     C                   parm                    $ptotm            6
530aAC                   parm                    $pdtl             1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zmcpmq
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
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
     *  Put out info message.
     C                   exsr      zm2102
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   exsr      zznxt1
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
530bA*
530bA* Get client id.
530bA*
530bAC                   call      @getcl
530bAC                   parm                    client           10
530bAC                   parm                    cliloc           10
     *
     C                   eval      gtdate = 0
     C                   eval      usname = *blanks
     C                   eval      forevr = *blanks
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *  Define key for OPTIONS file.
     C     keyop         klist
     C                   kfld                    opecod
     C                   kfld                    KYwhse
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
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *
     *    PIR9901  From date greater than To date.
     *
     C     zm9901        begsr
     C                   eval      #msgid = 'PIR9901'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0110  Number must be >0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ER27002  Records are being selected. (Info message)
     *
     C     zm2102        begsr
     C                   eval      #msgid = 'ER21002'
     C                   eval      #msgtp = '*INFO  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     C     gtoj$         begsr
     C                   eval      g$date = g$date
     * SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C                   if        dtfrmt = 1
     C                   movel     g$date        g$yy
     C                   move      g$date        work4
     C                   movel     work4         g$mm
     C                   move      work4         g$dd
     C                   else
     C                   movel     g$date        g$mm
     C                   move      g$date        work4
     C                   movel     work4         g$dd
     C                   move      work4         g$yy
     C                   endif
     * CREATE 4 DIGIT YEAR
     C                   move      g$yy          g$yyyy
     C                   if        g$yy >= 60
     C                   movel     '19'          g$yyyy
     C                   else
     C                   movel     '20'          g$yyyy
     C                   endif
     C                   eval      g$jd = 0
     C                   eval      g$mmwk = g$mm - 3
     C                   eval      gmwksv = g$mmwk
     C                   if        g$mmwk < 0
     C                   add       12            g$mmwk
     C                   endif
     C                   if        gmwksv <> 0
     C                   eval(h)   g$jd = g$mmwk * 30.6
     C                   endif
     C                   add       g$dd          g$jd
     C     g$yyyy        sub       1900          g$yywk
     C                   if        g$yywk <> 0
     C                   if        gmwksv < 0
     C                   eval      g$yywk = g$yywk - 1
     C                   endif
     C                   endif
     C                   eval      g$jyd = g$yywk * 365.25
     C                   add       g$jyd         g$jd
     C     g$jd          div       7             g$wk7
     C                   mvr                     g$dw
     * MAKE SUNDAY = 1ST DAY OF THE WEEK
     C                   if        g$dw <= 3
     C                   add       4             g$dw
     C                   else
     C                   eval      g$dw = g$dw - 3
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  JTOG$    Julian to Gregorian date conversion
     *
     C     jtog$         begsr
     C     j$jd          div       365.25        j$yywk
     C     j$jd          div       365.25        j$tst
     C                   if        j$tst = 0
     C                   eval      j$yywk = j$yywk - 1
     C                   endif
     C                   eval      j$yd = j$yywk * 365.25
     C                   eval      j$yd = j$jd - j$yd
     C                   if        j$yd > 306
     C                   add       1             j$yywk
     C                   endif
     C                   eval      j$x = 0
     C                   dou       j$yd <= j$md
     C                   add       1             j$x
     C     j$x           mult(h)   30.6          j$md
     C                   enddo
     C                   eval      j$x = j$x - 1
     C     j$x           mult(h)   30.6          j$md
     C     j$yd          sub       j$md          j$dd
     C     j$x           add       3             j$mm
     C                   if        j$mm > 12
     C                   eval      j$mm = j$mm - 12
     C                   endif
     C     j$yywk        add       1900          j$yyyy
     C                   if        dtfrmt = 1
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   movel     work2         j$date
     C                   move      work4         j$date
     C                   else
     C                   move      j$yyyy        work2
     C                   movel     j$mm          work4
     C                   move      j$dd          work4
     C                   move      work2         j$date
     C                   movel     work4         j$date
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify From Date.
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $cvmsg
    D*                    EXSR ZMQMSG
     C                   else
     C                   eval      w1fmdt = $cvd6o
     C                   endif
     *
     *  Verify To Date.
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cvmsg
     C                   else
     C                   eval      w1todt = $cvd6o
     C                   endif
     *
     *  Verify From date <= To date
     *
     C                   if        not *in21  and
     C                             not *in22
     *
     C                   if        w1fmdt = 0
     C                   eval      $pfmdt = *blanks
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $pfmdt
     C                   endif
     *
     C                   if        w1todt = 0
     C                   eval      $pendt = *blanks
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $pendt
     C                   endif
     *
     C                   if        w1fmdt <> 0  and
     C                             w1todt <> 0  and
     C                             $pfmdt > $pendt
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm9901
     C                   endif
     *
     C                   endif
     *
     *  Verify From Time.
     *
     C                   eval      wrktim = w1fmtm
     C                   if        w1fmtm < 0  or
     C                             w1fmtm > 2359  or
     C                             wrkhh > 23  or
     C                             wrkmm > 59  or
     C                             wrkss > 59
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel(p)  desc(7)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify To Time.
     *
     C                   eval      wrktim = w1totm
     C                   if        w1totm < 0  or
     C                             w1totm > 2359  or
     C                             wrkhh > 23  or
     C                             wrkmm > 59  or
     C                             wrkss > 59
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   movel(p)  desc(8)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify from/to time against dates entered.
     *
     C                   if        w1fmdt = w1todt  and
     C                             w1totm < w1fmtm
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel(p)  desc(9)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify merge option
     *
     C                   if        w1mrg <> 'Y'  and
     C                             w1mrg <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
530aA*
530aA*  Verify detail
530aA*
530aAC                   if        w1dtl <> '1'  and
530aAC                             w1dtl <> '2'  and
530aAC                             w1dtl <> 'N'
530aAC                   eval      error = *on
530aAC                   eval      *in25 = *on
530aAC                   eval      *in05 = *on
530aAC                   eval      errmsg = *blanks
530aAC                   movel     desc(10)      errmsg
530aAC                   exsr      zm1001
530aAC                   endif
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
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
     *
     *  Verify Crew Code
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lcrew = w1crew
     C                   call      'CR900'
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
     C                   endif
     C                   endif
     *
     *  Verify detail report option
     *
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
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
     C                   select
     *
     *     Warehouse code.
     *
     C                   when      row# = 8
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Crew code.
     *
     C                   when      row# = 10
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lcrew = w1crew
     C                   call      'CR900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1crew = $lcrew
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
JORbAC                   select
JORbAC                   when      client = jordanos
JORbAC                   eval      w1fmtm = 1500
JORbAC                   eval      w1totm = 0500
JORbAC                   eval      w1crew = *blanks
CPCaDC*                  if        client = cpc
CPCaMC                   when      client = cpc
CPCaAC                   eval      w1fmtm = 0600
CPCbDC*                  eval      w1totm = 1800
CPCbMC                   eval      w1totm = 2000
CPCaAC                   eval      w1crew = 'CREW1'
CPCaDC*                  else
FSHbAC                   when      client = fischerfoods
FSHbAC                   eval      w1fmtm = 1500
FSHbAC                   eval      w1totm = 0600
JORbAC                   other
CPCaA*
     C                   eval      w1fmtm = 1500
     C                   eval      w1totm = 0400
     C                   eval      w1crew = *blanks
CPCaDC*                  endif
JORbAC                   endsl
CPCaA*
     C                   move      'N'           w1mrg
530aAC                   move      'N'           w1dtl
DRYaAC                   if        client = dairyland
DRYaAC                   eval      w1jobq = 'Y'
DRYaAC                   else
     C                   eval      w1jobq = 'N'
DRYaAC                   endif
     *   Get Report Title
     C                   call      'GETRPTE'
     C                   parm      '*DESC  '     $cmd              8
     C                   parm      'ER382PR'     $lrpt            10

     C                   parm      0             $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      rptttl = $desc
     *
     *   Center report title.
     *
     C                   movel     rptttl        $pstr
     C                   eval      $plen = 50
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *   Get Device and Form
     C                   call      'GETRPTE'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'ER381PR'     $lrpt
     C                   parm      0             $whse             3 0
     C                   parm      ' '           $styp
     C                   parm      ' '           $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   eval      w1dev = $dev
     C                   eval      w1form = $form
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C     *MDY          move      $cvd6o        w@date
     C                   eval      w@date -= %Days(1)
     C     *MDY          move      w@date        w1fmdt
     C                   move      $cvd6o        w1todt
CPCaA*
CPCaAC                   if        client = cpc
CPCaAC                   eval      w1todt = w1fmdt
CPCaAC                   endif
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      #pgmq = #prog
     C                   eval      $cvprg = #prog
     C                   eval      $lprg = #prog
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
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     C                   exsr      zzvoic
     *
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1fmdt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        fromdt
     C                   move      $cvd8o        $pfmdt
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1todt        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        todt
     C                   move      $cvd8o        $ptodt
     C                   move      '000000'      $pfmtm
     C                   movel     w1fmtm        $pfmtm
     C                   move      '000000'      $ptotm
     C                   movel     w1totm        $ptotm
     **                   MOVE $CVD8O    $PTODT
     *
     C                   if        w1fmtm = 0 and w1totm = 0
     C                   call      'GETSHFT'
     C                   parm      w1whse        $pwhs2            3 0
     C                   parm      w1crew        $pcrew
     C                   parm                    $pdesc           30
     C                   parm                    $pshft            6
     C                   parm                    $pshtd           30
     C                   parm                    $pstim            6 0
     C                   parm                    $petim            6 0
     C                   parm                    $prtn
     C                   if        $prtn = '*OK     '
     C                   move      $pstim        $pfmtm
     C                   move      $petim        $ptotm
     *    Time criteria overlaps two days. Use overlap selection.
     C                   if        $petim < $pstim  and
     C                             $petim > *zeros
     C                   eval      dayolp = '*YES'
     C                   else
     C                   eval      dayolp = '*NO '
     C                   endif
     C                   endif
     *
     *  Calculate "To date" + 1
     C                   if        dayolp = '*YES'
     C                   move      w1todt        g$date
     C                   eval      dtfrmt = 2
     C                   exsr      gtoj$
     C                   eval      begjul = g$jd
     C     begjul        add       1             endjul
     C                   eval      j$jd = endjul
     C                   exsr      jtog$
     C                   eval      month = j$mm
     C                   eval      day = j$dd
     C                   move      j$yyyy        year
     C                   eval      endgrg = t#date
     C                   eval      $cvcmd = '*MDYCMD '
     C                   eval      $cvd6i = endgrg
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        todt
     C                   move      $cvd8o        $pendt
     C                   else
     C                   eval      $pendt = $ptodt
     C                   endif
     C                   endif
     C                   move      w1whse        $pwhse
     C                   eval      $pcrew = w1crew
     C                   eval      $pjobq = w1jobq
     C                   eval      $pdev = w1dev
     C                   eval      $pform = w1form
     C                   eval      $prtn = '*OK     '
     *
     C                   eval      $pmrg = w1mrg
     C                   eval      $pdtl = w1dtl
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZVOIC  Find out if client is using voice
     *
     C     zzvoic        begsr
     *
     C                   Z-ADD     0             KYwhse
     C                   eval      opecod = '*USER   '
     C     keyop         chain     optione                            77
     C                   if        not *in77
     C                   eval      opdta = opedta
     C                   eval      $pvyn = opvyn
     C                   eval      $pzord = opzord
     C                   eval      $ptbd = optbd
     C                   else
     C                   eval      $pvyn = 'N'
     C                   eval      $pzord = 'D'
     C                   eval      $ptbd = 'N'
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Job queue option
Printer device
Form type
Crew code
Detail report
Include merge pieces
From time invalid.
To time invalid.
End time less than start time.
Zone Detail option
