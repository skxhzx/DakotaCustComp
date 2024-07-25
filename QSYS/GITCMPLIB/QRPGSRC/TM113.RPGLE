      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. TM113FM WILL BE REPALCED WITH TM11301
     *----------------------------------------------------------------
     *
     *  TM113     Truck maintenance - Copy
     *  27 May 1997
     *  Roxanne Harrison
     *   - Created using IT113
     *
     *
     *  Revisions
     *
223 A*    07/03/97   HNK  2.23
     *         -ZONEH, ZONED and OPTIONZ files added.
     *         -ZZUPD1 subroutine changed to write records to ZONEH,
     *          ZONED1 and OPTIONZ1 files.
     *
520aA*    02/28/09  DAS  5.20a  P#00150
     *      - Recompiled because of change to ZONED
     *
530 A*    11/10/09   JCJ  5.30
     *      - Enh: Converted to ILE.
     *      - Enh: Recomplied for database change to TRUCKH
     *      - Enh: Can not copy Template to Truck
     *
640aA*    05/25/12   JCJ  6.40a
     *      - Enh: Add file TRUCKHM1.
     *
720aA*    10/14/18   DAS  7.20a
     *      -  Recompiled because of new ZONED fields
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530 D*tm113fm   cf   e             workstn
520 MFtm11301   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Ftruckh    uf a e           k disk
     F                                     rename(threc:record)
     Ftruckd    uf a e           k disk
223 AFzoneh     uf a e           k disk
223 AFzoned1    uf a e           k disk
223 AFoptionz1  uf a e           k disk
640aAFtruckhm1  uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(1) ctdata perrcd(1)
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
     D  $ptruk                22     31
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
     D  $lsdef                22     23
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
     *
     D  $lbc                  19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtwh          c                   const('FRMTWH')
     D @fmtit          c                   const('FRMTIT')
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
     D  eritem                 1     15
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
     D $cdesc          s             30
     D $cstr           s             40
     D $cwhse          s              3  0
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
     D eof             s              1
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svbat           s                   like(thbat)
     D svbulk          s                   like(thbulk)
     D svcol           s                   like(tdcol)
     D svcols          s                   like(thcols)
     D svcomp          s                   like(tdcomp)
     D svcube          s                   like(tdcube)
     D svdesc          s                   like(thdesc)
     D svpick          s                   like(tdpick)
     D svrow           s                   like(tdrow)
     D svrows          s                   like(throws)
     D svtruk          s                   like(thtruk)
530 AD ttmpl           s              1
     D warn            s              1
     D w1fdes          s             30
     D w1fwhs          s              3  0
     D w1tdes          s             30
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *COPY    - Copy record to new record
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
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       616263
     C                   setoff                                       646566
     C                   setoff                                       676869
     C                   setoff                                       70
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
     C                   exsr      zzdft1
     *
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so go home.
     *
     C                   eval      nxtscr = 'EOJ'
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
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
530 A*----------------------------------------------------------------
530 A*   PIR1019  Copying a template to a truck not allowed
530 A*
530 AC     zm1019        begsr
530 AC                   eval      #msgid = 'PIR1019'
530 AC                   eval      #msgtp = '*DIAG  '
530 AC                   movea     errmsg        $md
530 AC                   exsr      zmpmsg
530 AC                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11202   Item number cannot be blank.
     *
     C     zm1202        begsr
     C                   eval      #msgid = 'IT11202'
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1twhs
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
     *    Make sure truck was entered.
     *
     C                   if        w1ttrk = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     C                   endif
     *
     *    Make sure truck doesn't already exist.
     *
     C     tokey         chain(n)  record                             79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   exsr      zm02
     C                   endif
530 A*
530 A*    Can not copy Template to a Truck
530 A*
530 AC                   eval      ttmpl = %subst(w1ttrk:1:1)
530 AC                   if        w1type = 'Z'  and
530 AC                             ttmpl <> '*'
530 AC                   eval      error = *on
530 AC                   eval      *in22 = *on
530 AC                   exsr      zm1019
530 AC                   endif
     *
     C     endck1        endsr
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
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 9
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = 0
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1twhs = $lwhse
     C                   endif
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
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      w1fwhs = $pwhse
     C                   eval      w1fmwh = *blanks
     C                   eval      $cstr = *blanks
     C     whkey         chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   movel     $pwhse        $cwhse
     *
     C                   eval      $cdesc = whdesc
     C                   eval      $cstr = *blanks
     C                   call      @fmtwh
     C                   parm                    $cwhse
     C                   parm                    $cdesc
     C                   parm                    $cstr
     C                   eval      w1fmwh = $cstr
     *
     *   Truck description.
     *
     C                   eval      w1ftrk = thtruk
     C                   eval      w1fdes = thdesc
     *
     C                   eval      w1twhs = $pwhse
     C                   eval      w1ttrk = thtruk
     C                   eval      w1tdes = thdesc
530 AC                   eval      w1type = thtype
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fmkey         chain(n)  record                             7978
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
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     *
     *  Copy fields from 'FROM truck' to 'TO truck'.
     *
     C                   eval      svdesc = thdesc
     C                   eval      svrows = throws
     C                   eval      svcols = thcols
     C                   eval      svbulk = thbulk
     C                   eval      svbat = thbat
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for Truck Header file. (From Truck)
     *
     C     fmkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
223 A*
223 A*  partial key for Zone Header file. (From Zone)
223 A*
223 AC     zhkey         klist
223 AC                   kfld                    $pwhse
223 AC                   kfld                    $ptruk
223 A*
223 A*  Define partial key for Zone Detail file. (From Zone)
223 A*
223 AC     zdkey         klist
223 AC                   kfld                    $pwhse
223 AC                   kfld                    $ptruk
223 A*
223 A*  partial key for OPTIONZ1 file. (From Zone)
223 A*
223 AC     opzkey        klist
223 AC                   kfld                    $pwhse
223 AC                   kfld                    $ptruk
     *
     *  Define key for Truck Header file. (To Truck)
     *
     C     tokey         klist
     C                   kfld                    w1twhs
     C                   kfld                    w1ttrk
     *
     *  Define key for Warehouse file. (From warehouse)
     *
     C     whkey         klist
     C                   kfld                    $pwhse
     *
     *
     *
     *  Define key for Truck detail file. (To Truck)
     *
     C     tdkey         klist
     C                   kfld                    w1twhs
     C                   kfld                    w1ttrk
     C                   kfld                    svrow
     C                   kfld                    svcol
     *
     *R         *LIKE     DEFN TDTRUK    SVTRUK
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      w1fmwh = *blanks
     C                   endif
     *
     *   Get From Truck.
     *
     C                   exsr      zzget1
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Add Truck Header record.
     *
     C                   eval      thwhse = w1twhs
     C                   eval      thtruk = w1ttrk
     C     tokey         chain     record                             79
     C                   if        *in79
     C                   eval      thdesc = svdesc
     C                   eval      throws = svrows
     C                   eval      thcols = svcols
     C                   eval      thbulk = svbulk
     C                   eval      thbat = svbat
530 AC                   select
530 AC                   when      ttmpl = '*'
530 AC                   eval      thtype = 'Z'
530 AC                   when      ttmpl <> '*'
530 AC                   eval      thtype = 'T'
530 AC                   endsl
     C                   write     record
     C                   endif
     *
     *  Add truck detail record.
530 A*  If not a Template.
     *
530 AC                   if        ttmpl <> '*'
     C     fmkey         setll     truckd                             79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     fmkey         reade     truckd                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      svrow = tdrow
     C                   eval      svcol = tdcol
     C                   eval      svcomp = tdcomp
     C                   eval      svcube = tdcube
     C                   eval      svpick = tdpick
     *R         TDKEY     CHAINTRUCKD1              78
     *R         *IN78     IFEQ *ON
     C                   eval      tdwhse = w1twhs
     C                   eval      tdtruk = w1ttrk
     C                   eval      tdrow = svrow
     C                   eval      tdcol = svcol
     C                   eval      tdcomp = svcomp
     C                   eval      tdcube = svcube
     C                   eval      tdpick = svpick
     C                   write     tdrec
     *R                   ENDIF
     C                   endif
     C                   enddo
530 AC                   endif
223 A*
223 A*  Add Zone Header record.
530 A*  only when copying a template to a template or
530 A*  when a truck to a template
223 A*
530 AC                   if        w1type = 'Z'
530 AC                             and ttmpl = '*'
530 AC                             or w1type = 'T'
530 AC                             and ttmpl = '*'
223 AC     fmkey         setll     zoneh                              77
223 AC                   move      *in77         eof
223 AC                   dow       eof = *off
223 AC     fmkey         reade(n)  zoneh                                  77
223 AC                   move      *in77         eof
223 AC                   if        not *in77
223 AC                   eval      zhwhse = w1twhs
223 AC                   eval      zhtruk = w1ttrk
223 AC                   write     zhrec                                79
223 AC                   endif
223 AC                   enddo
530 AC                   endif
223 A*
223 A*  Add Zone detail records.
530 A*  only when copying a template to a template or
530 A*  when a truck to a template
223 A*
530 AC                   if        w1type = 'Z'
530 AC                             and ttmpl = '*'
530 AC                             or w1type = 'Z'
530 AC                             and ttmpl = '*'
223 AC     zdkey         setll     zoned1                             77
223 AC                   move      *in77         eof
223 AC                   dow       eof = *off
223 AC     zdkey         reade(n)  zoned1                                 77
223 AC                   move      *in77         eof
223 AC                   if        not *in77
223 AC                   eval      zdwhse = w1twhs
223 AC                   eval      zdtruk = w1ttrk
223 AC                   write     zdrec                                79
223 AC                   endif
223 AC                   enddo
530 AC                   endif
223 A*
223 A*  Add OPTIONZ records.
223 A*
510 AC                   if        w1type = 'Z'
510 AC                             and ttmpl = '*'
510 AC                             or w1type = 'Z'
510 AC                             and ttmpl = '*'
223 AC     opzkey        setll     optionz1                           77
223 AC                   move      *in77         eof
223 AC                   dow       eof = *off
223 AC     opzkey        reade(n)  optionz1                               77
223 AC                   move      *in77         eof
223 AC                   if        not *in77
223 AC                   eval      opzwhs = w1twhs
223 AC                   eval      opztrk = w1ttrk
223 AC                   write     opzrec                               79
223 AC                   endif
223 AC                   enddo
530 AC                   endif
     *
     C     endup1        endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Truck
