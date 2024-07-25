      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*  UI340  UCI RF  Inventory entry - Stuff it
     *  31 March, 2007
     *  Jeffrey Jahnke
     *
     *  Notes:
     *       Created using UI330
     *       8 X 20 Screens for hand held scanners
     *
     * Revisions:
510aA*    05/15/07  JCJ  5.10aA
     *      - Enh: Add field UCIVAL to UCICW.  Update slot to
     *             active if product is found in slot.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fui340fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   if   e           k disk
510aMFslot2     uf   e           k disk
     Flicense   if   e           k disk
     Fucicw     uf a e           k disk
     Fuistuffit if a e           K disk
     Fuimisc    uf a e           k disk
    A*----------------------------------------------------------------
    A*  Customer id
    A*
    AD @getcl          c                   const('GETCLIENT')
    A
    A /COPY QCOPYSRC,ID#PACKERS
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D uci             s             10    dim(500)
     D desc            s             20    dim(9) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $litem                27     41
     D  $ldisp                42     53
     *
     *   Redefine key
     *
     D  $litem2               22     36
     D  $lucin                37     51
     D  $lsq2                 52     56  0
     D  $luci                 57     66
     D  $lcode                67     68
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     D  $mtype                81     88
     *
     D  $mwhse                19     20p 0
     D  $mpo                  21     29
     D  $mseq                 30     32P 0
     D  $mitem                33     47
     D  $mqyr1                48     50P 0
     D  $mqyr2                51     53P 0
     D  $mqyr3                54     56P 0
     D  $mcwte                57     59P 0
     D  $mcwtt                60     64P 2
     D  $mcwta                65     68P 2

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @cwght          c                   const('CW132')
     D @apics          c                   const('APICVTSLT')

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

     *----------------------------------------------------------------
     *  Slot definition
     *
     D                 ds
     D  w1disp                 1     12
     D  w1dsp1                 1      7
     D  w1dsp2                 8     12

     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
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
     D  #pgm             *proc
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
     *  variables
     *

     D $prcvd          S              8  0
     D $pexpd          S              8  0
     D $portrn         S              7  0
     D help            s              5  0
     D enter           s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D e$emp#          s              5  0
     D clear           s              5  0
     D comand          s              5  0
     D msgk            s              4  0
     D e$nhrs          s              3  1
     D e$whse          s              3  0
     D kywhse          s              3  0
     D wkwhse          s              3  0
     D w1whse          s              3  0
     D l               s              3  0
     D x               s              3  0
     D e               s              2  0
     D $plotc          s             30
     D e$lnam          s             20
     D e$fnam          s             15
     D e$code          s             10
     D $msgf           s             10
     D client          s             10
     D #pgmq           s             10
     D #pgmq2          s             10
     D blkuci          s             10
     D e$rtn           s              8
     D cmdchk          s              8
     D wkcode          s              8
     D @artn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D e$shft          s              6
     D e$crew          s              6
     D e$whdp          s              5
     D #msgk           s              4
     D nxtscr          s              3
     D e$lng           s              2
     D redspl          s              1
     D refrsh          s              1
     D sclear          s              1
     D e$init          s              1
     D e$styp          s              1
     D e$bpu           s              1
     D warn            s              1
     D cmdtkn          s              1
     D $ltype          s              1
     D error           s               n
     D forever         s               n
     *----------------------------------------------------------------
     I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
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
     D  optend               117    117
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

     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       929398
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C                   eval      e = *zeros
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
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      *in20 = *off
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
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
     C                   eval      nxtscr = 'EOJ'
     C                   exsr      zzremove
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      zzremove
     C                   exsr      scr01i
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
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client
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
     C                   parm      $pprg         #pgmq2
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
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
     *   PIR0204  Enter only one value.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm05          begsr
     C                   eval      #msgid = 'PIR0205'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV21307  UCI already entered.
     *
     C     zm1307        begsr
     C                   eval      #msgid = 'IV21307'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *   PIR0203   Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     ERRMSG        $MD(1)
     C                   exsr      ZMPMSG
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Whse department can't be blank.
     *
     C                   if        w1whdp = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      ZM0203
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   if        w1whdp = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = $lerm
     C                   exsr      ZM0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   move      $LMSG         #MSGK
     C                   exsr      ZMQMSG
     C                   endif
     C                   endif
     C                   endif
     *
     * Slot can't be blank.
     *
     C                   if        w1disp = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      ZM0203
     C                   endif
     *
     * Call API for slot.
     *
414 AC                   call      @APICS
414 AC                   parm                    W1DISP
414 AC                   parm      5             worow
414 AC                   parm      8             wocol
414 AC                   parm                    @artn
414 AC                   if        @ARTN = '*REDSPLY'
414 AC                   eval      redspl = *on
414 AC                   eval      error  = *on
414 AC                   goto      ENDCK1
414 AC                   endif
     *
     * Verify slot.
     *
     C                   if        w1disp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1disp
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = $lerm
     C                   exsr      ZM0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   move      $lmsg         #MSGK
     C                   exsr      ZMQMSG
     C                   endif
     C                   endif
     C                   endif
     *
     * get item in slot.
     *
     C                   if        w1disp <> *blanks and
     C                             error  =  *off
     C     slotky        chain     slot2
     C                   if        not %found(slot2)
     C                   eval      slitem = *blanks
     C                   endif
     C                   endif
     *
     * Verify license
     *
     C                   if        w1lcn <> *blanks
     C     lcnkey        chain     license
     C                   if        not %found(license)
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      ZM0105
     C                   endif
     C                   endif
     *
     C                   if        error = *off
     C     slotky        chain     uistuffit
      ***                if        %found(uistuffit)
      ***                eval      error = *on
      ***                eval      *in23 = *on
      ***                eval      *in03 = *on
      ***                eval      errmsg = desc(7)
      ***                exsr      ZM0105
      ***                endif
     C                   endif
     *
     C                   eval      uci = *blanks
     *
     C     endck1        endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *  Must enter UCI.
     C                   if        w2uci = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm05
     C                   goto      endck2
     C                   else
     C     ucikey        chain     ucicw
     C                   if        %found(ucicw) and ucists = 'Y'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(9)
     C                   exsr      ZM0105
     C                   goto      endck2
     C                   endif
     C                   endif
     *
     *  Validate UCI
     *
     C                   if        not %found(ucicw)
     C                   eval      error = *on
     C                   eval      errmsg = desc(8)
     C                   exsr      ZM0105
     C                   goto      endck2
     C                   endif
     *
     *  Check if UCI has already been scanned.
     C                   eval      l = 1
     C     w2uci         lookup    uci(1)                                 80
     C                   select
     C                   when      *in80
     *
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm1307
     *
     C                   when      not *in80
     *
     *    UCI not found.  Find next empty element.
     C                   eval      l = 1
     C                   eval      blkuci = *blanks
     C     blkuci        lookup    uci(l)                                 80
     C                   if        *in80
     C                   eval      uci(l) = w2uci
     * write uimisc
     C                   eval      umwhse = w1whse
     C                   eval      umuci# = w2uci
     C                   eval      umitem = uciitm
     C                   eval      umdisp = w1disp
     C                   eval      umlcn# = w1lcn
     C                   eval      umdept = slwhdp
     C                   eval      umsitm = slitem
     C                   write     uimsc

510aAC                   if        slstat = 'V' or
510aAC                             slstat = 'Z'
510aAC                   eval      slstat = 'A '
510aAC                   eval      slitem = uciitm
510aAC                   update    slrec
510aAC                   endif

     C                   endif
     *
     C                   endsl
     *
     C     endck2        endsr

     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 4.
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
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   goto      endcm1
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
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
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F14 - No more UCI.
     *
     C                   if        *inkn
     C                   eval      cmdtkn = *on
     C                   eval      usuwhs = w1whse
     C                   eval      uswhdp = w1whdp
     C                   eval      usuitm = slitem
     C                   eval      usudsp = w1disp
     C                   eval      usucnt = w2count
     C                   eval      usstk1 = slstk1
     C                   eval      usstk2 = slstk2
     C                   eval      usstk3 = slstk3
     C                   eval      usuadj = 'N'
     C                   eval      usueby = #user
     C                   write     uistuf
     *
     C                   exsr      scr01i
     *
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '

     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
      ***                eval      w1whdp = *blanks
     C                   eval      w1disp = *blanks
     C                   eval      w1lcn  = *blanks
     C                   eval      w2count = *zeros
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 4 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w2uci = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

     *     UCICW   file
     C     ucikey        klist
     C                   kfld                    w1whse
     C                   kfld                    w2uci
     *
     *     OPTIONS file
     C     opkeys        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *     LICENSE file
     C     lcnkey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1lcn
     *
     *     LABEL90 file
     C     lblkey        klist
     C                   kfld                    w1whse
     C                   kfld                    litrn#
     *
     *     SLOT2   file
     C     slotky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1disp
     *     Uimisc  file
     C     msckey        klist
     C                   kfld                    w1whse
     C                   kfld                    uci(x)
     *
      *  Convert today's date into century format.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   z-add     $cvd8o        curdte            8 0
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get employee options.
     *
     C                   call      'GETUSER'
     C                   parm      #user         e$code
     C                   parm                    e$whse
     C                   parm                    e$emp#
     C                   parm                    e$fnam
     C                   parm                    e$init
     C                   parm                    e$lnam
     C                   parm                    e$whdp
     C                   parm                    e$styp
     C                   parm                    e$shft
     C                   parm                    e$crew
     C                   parm                    e$nhrs
     C                   parm                    e$rtn
     C                   parm                    e$bpu
     C                   parm                    e$lng
     C                   if        e$rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     C                   eval      w1whse = e$whse
     C                   eval      wkwhse = e$whse
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     *   Get options
     C                   exsr      zzoptn
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPTN   Get options
     *
     C     zzoptn        begsr
     *
     *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options
     C                   if        not %found(options)
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   endif
     C*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZremove  Remove previous entered uimisc records
     *
     C     zzremove      begsr

     C                   eval      l = 1
     C                   eval      blkuci = *blanks
     C     blkuci        lookup    uci(l)                                 80
     C                   if        *in80

     C                   do        l             x
     C     msckey        chain     uimisc
     C                   if        %found(uimisc)
     C                   delete    uimsc
     C                   endif
     C                   enddo
     C                   endif

     C     endrmv        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C     ucikey        chain     ucicw
     C                   if        %found(ucicw)
     C                   eval      w2count = w2count + 1
     C                   eval      ucists = 'Y'
510aAC                   eval      ucival = 'Y'
     C                   if        w1lcn <> *blanks
     C                   eval      ucilcn = w1lcn
     C                   endif
     C                   update    ucirec
     C                   endif
     *
     * re-display screen2 for next UCI
     C                   exsr      scr02i
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Dept
Slot
License not valid.
Lcn not assigned to slot item.
Item
Weight
Slot already counted
UCI not on file
UCI already counted
