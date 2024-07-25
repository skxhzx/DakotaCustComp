      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  HQ113     Haccp Question file maintenance - Copy
     *  16 April 2012
     *  Lynn McMahon
     *
     *
     *  Revisions
640  *    04/16/12  LMC  6.40
     *      - Created
740a *    05/19/20  LMC  7.40a
     *      - Recompile only - Databases changes.
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
     Fhq113fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Fhaccpq    uf a e           k disk
     F                                     rename(hirec:record)
     Fhaccpq1   if   e           k disk    prefix(q1_)
     F                                     rename(hirec:sequence)
     Fhaccpq2   if   e           k disk    prefix(q2_)
     F                                     rename(hirec:pageseq)
     Fhaccpv2   if a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(2) ctdata perrcd(1)
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
     D  $plevl                22     25
     D  $ptype                26     28
     D  $pcode                29     43
     D  $pseq#                51     55  0
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
     D  $llevl                22     25
     D  $ltype                26     28
     D  $ltypedesc            29     53
     D  $llook                54     63
     D  $lentry               64     64
     *
     D  $lactv                19     20
     *
     D  $lcat                 19     28
     *
     D  $litem                22     36
     *
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
     D  $cvd8o                39     46  0
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
     *  Variables
     *
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
     D even            s              3  1
     D evenwk          s              1  0
     D fielda          s             29
     D                                     varying
     D fieldb          s             29    inz('. . . . . . . . . . . . . . :')
     D fieldc          s             29    inz(' . . . . . . . . . . . . . . ')
     D forever         s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D nwpge#          s                   like(hipge#)
     D nwpgsq          s                   like(hipgsq)
     D pageseqcnt      s              2  0
     D pos             s              2  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svwhse          s                   like(hiwhse)
     D svlevl          s                   like(hilevl)
     D svtype          s                   like(hitype)
     D svcode          s                   like(hicode)
     D svseq#          s                   like(hiseq#)
     D svqstn          s                   like(hiqstn)
     D svatyp          s                   like(hiatyp)
     D svtabl          s                   like(hitabl)
     D svreqd          s                   like(hireqd)
     D svsamp          s                   like(hisamp)
     D svfreq          s                   like(hifreq)
     D svpge#          s                   like(hipge#)
     D svpgsq          s                   like(hipgsq)
     D svactive        s                   like(hiactive)
     D svadate         s                   like(hiadate)
     D svatime         s                   like(hiatime)
     D svaddjusr       s                   like(hiaddjusr)
     D svcdate         s                   like(hicdate)
     D svctime         s                   like(hictime)
     D svchgjusr       s                   like(hichgjusr)
     D svdsc1          s             40
     D svdsc2          s             40
     D svtypedesc      s                   like($ltypedesc)
     D warn            s              1
     D w1fitm          s             15
     D w1fwhs          s              3  0
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
     *   PIR0203  Code must be entered
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
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
     *   IT11301   Broken case item cannot be copied, if the full
     *             case item for it does not exist.
     *
     C     zm1301        begsr
     C                   eval      #msgid = 'IT11301'
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
     *     PIR7979  Record does not exist.
     *
     C     zm79          begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmPmsg
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
     *    Make sure level and type are valid.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1twhs
     C                   eval      $llevl = w1tlvl
     C                   eval      $ltype = w1ttyp
     C                   call      'HB900'
     C                   parm                    $lparm
      /free
        if $lrtn =  '*PGMQ   ';
          error = *on;
          *in22 = *on;
          *in02 = *on;
          errmsg = desc(2);
          exsr zm01;
        endif;
        // validate if $llook or $lentry are not blank
        if $llook <> ' '  and w1tcode = ' ';
          error = *on;
          *in23 = *on;
          *in03 = *on;
          errmsg = $ltypedesc;
          exsr zm03;
          leavesr;
        endif;
        // Check code entry against validation program if it exist
        if $llook <> ' '  and w1tcode <> ' ';
          exsr zzverify;
          if error = *on;
            leavesr;
          endif;
        endif;
        // Code must be entered if $lentry is populated
        if $lentry = 'Y' and w1tcode = ' ';
          error = *on;
          *in23 = *on;
          *in03 = *on;
          errmsg = $ltypedesc;
          exsr zm03;
          leavesr;
        endif;
        // page and page seq edits
        exsr zzmaxpage;
        if nwpgsq > 0;
          chain (w1twhs: w1tlvl: w1ttyp: w1tcode:
                 svpge#: svpgsq) haccpq2;
          // if found need to zero out the pgsq, and assign next number
          if %found(haccpq2);
            setgt (w1twhs: w1tlvl: w1ttyp: w1tcode: svpge#) haccpq2;
            readpe (w1twhs: w1tlvl: w1ttyp: w1tcode: svpge#) haccpq2;
            if %eof(haccpq2);
              nwpgsq = 1;
            else;
              nwpgsq = q2_hipgsq + 1;
            endif;
          endif;
        endif;
      /end-free
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
     *     Question Type.
     *
     C                   when      row# = 10
     C                   eval      $lcmd = '*SELECT '
     C                   eval      $lwhse = $pwhse
     C                   call      'HB900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1ttyp = $ltype
     C                   eval      w1tlvl = $llevl
     c                   if        w1ftyp <> w1ttyp or
     c                             w1tlvl <> w1ftyp
     c                   eval      w1tcode = ' '
     c                   endif
     c                   exsr      zzloadcode
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
     C                   eval      w1twhs = hiwhse
     C                   eval      w1tlvl = hilevl
     C                   eval      w1ttyp = hitype
     C                   eval      w1tcode = hicode
     C                   eval      w1fwhs = hiwhse
     C                   eval      w1flvl = hilevl
     C                   eval      w1ftyp = hitype
     C                   eval      w1fcode = hicode
     C                   eval      w1fqstn = hiqstn
     *
     *    Make sure level and type are valid.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1twhs
     C                   eval      $llevl = w1tlvl
     C                   eval      $ltype = w1ttyp
     C                   call      'HB900'
     C                   parm                    $lparm

     c                   exsr      zzloadcode
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
     *   Get record from main file.
      /free
       begsr zzget1;

         chain(e) ($pwhse: $plevl: $ptype: $pcode: $pseq#) record;
         // record locked.
         if %error;
           error = *on;
           $prtn = '*PGMQ   ';
           exsr zm74;
           leavesr;
         endif;
         // record found.
         if not %found;
           error = *on;
           $prtn = '*PGMQ   ';
           exsr zm73;
           leavesr;
         endif;
         // copy fields from From Question to To question.
         svwhse = hiwhse;
         svlevl = hilevl;
         svtype = hitype;
         svcode = hicode;
         svseq# = hiseq#;
         svqstn = hiqstn;
         svatyp = hiatyp;
         svfreq = hifreq;
         svtabl = hitabl;
         svreqd = hireqd;
         svsamp = hisamp;
         svpge# = hipge#;
         svpgsq = hipgsq;
         svactive = hiactive;
         svadate = hiadate;
         svatime = hiatime;
         svaddjusr = hiaddjusr;
         svcdate = hicdate;
         svctime = hictime;
         svchgjusr = hichgjusr;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for Warehouse file. (From warehouse)
     *
     C     whkey         klist
     C                   kfld                    $pwhse
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
     *   Get From Item.
     *
     C                   exsr      zzget1
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLOADCODE Load text field and code if needed
     *
     C     zzloadcode    begsr
     c                   if        $llook <> ' ' or
     c                             $lentry = 'Y'
     c                   eval      fielda = 'To ' + $ltypedesc
     C                   eval      pos = %scan('  ':fielda)
     c                   eval      even = pos/2
     c                   move      even          evenwk
     c                   if        evenwk = 0
     c                   eval      fielda = %replace(fieldc:fielda:
     c                             %scan('  ':fielda):0)
     c                   else
     c                   eval      fielda = %replace(fieldb:fielda:
     c                             %scan('  ':fielda):0)
     c                   endif
     c                   else
     c                   eval      fielda = ' '
     c                   eval      *in30 = *on
     c                   eval      w1tcode = ' '
     c                   endif
     c                   eval      codetext = fielda
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZMAXPAGE Edit for a maximum of 10 questions per page
     *
      /free
       begsr zzmaxpage;
         pageseqcnt = 0;
         setll (w1twhs: w1tlvl: w1ttyp: w1tcode: svpge#) haccpq2;
         dow forever = forever;
           reade(n) (w1twhs: w1tlvl: w1ttyp: w1tcode: svpge#) haccpq2;
           if %eof(haccpq2);
             leave;
           endif;
             pageseqcnt = pageseqcnt + 1;
         enddo;
         if pageseqcnt > 9;
           nwpge# = 0;
           nwpgsq = 0;
         else;
           nwpge# = svpge#;
           nwpgsq = svpgsq;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Add question record.
     *
      * load date/time values
     c                   eval      $cvdop = '*CURCMD '
     C                   call      @CVTDT
     C                   parm                    $CVTDT
     c                   eval      hiadate = $cvd8o
     C                   time                    hiatime
      /free
        hiwhse = w1twhs;
        hilevl = w1tlvl;
        hitype = w1ttyp;
        hicode = w1tcode;
        // get next sequence#
        setgt (hiwhse) haccpq1;
        readpe (hiwhse) haccpq1;
        if %eof(haccpq1);
          hiseq# = 1;
        else;
          hiseq# = q1_hiseq# + 1;
        endif;
        chain (hiwhse: hilevl: hitype: hicode: hiseq#) haccpq;
        if not %found(haccpq);
          hiqstn = svqstn;
          hiatyp = svatyp;
          hitabl = svtabl;
          hireqd = svreqd;
          hisamp = svsamp;
          // frequency field must be 1, on anything that is not RCVI
          if w1tlvl = 'RCVI';
            hifreq = svfreq;
          else;
            hifreq = '1';
          endif;
          hipge# = nwpge#;
          hipgsq = nwpgsq;
          hiactive = svactive;
          hiaddjusr = #user;
          hicdate = 0;
          hictime = 0;
          hichgjusr = ' ';
          write record;
          // now go copy all the validation answer records
          setll ($pwhse: $plevl: $ptype: $pcode: $pseq#) haccpv2;
          dow forever = forever;
            reade ($pwhse: $plevl: $ptype: $pcode: $pseq#) haccpv2;
            if %eof(haccpv2);
              leave;
            endif;
            hvwhse = hiwhse;
            hvlevl = hilevl;
            hvtype = hitype;
            hvcode = hicode;
            hvseq# = hiseq#;
            write hvrec;
          enddo;
        endif;
       /end-free
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZVERIFY Verify code entry
     *
     C     zzverify      begsr
     c                   eval      svtypedesc = $ltypedesc
     c                   select
     c                   when      w1ttyp = 'CAT'
     C                   eval      $lcat  = w1tcode
     c                   other
     C                   eval      $lwhse = w1twhs
     C                   eval      $litem = w1tcode
     c                   endsl
     C                   eval      $lcmd = '*VERIFY '
     C                   call      $llook
     C                   parm                    $lparm
     C                   if        $lrtn = '*OK     '
     c                   else
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     c                   eval      errmsg = svtypedesc
     C                   exsr      zm79
     c                   leavesr
     C                   endif
     C                   eval      error = *off
     c                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Question
Valid Type
