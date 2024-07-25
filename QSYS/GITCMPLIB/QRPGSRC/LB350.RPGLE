      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB350   Text label - options
     *  28 December 2007
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    01/15/00  JCJ  520 A
     *      - Revised to produce 1 label spool file instead of several
     *
520dA*    10/20/09  JCJ  520dA
     *      - Soft coded label set.
     *
710 A*    10/18/17  MLB/JCJ  7.10
     *      - Enh: Revised pgm retrieve printer default using GETRPTS.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
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
     Flb350fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
520dAFlblfmtd   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(9) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

740bMD @prtpg          c                   const('BFCPRTLBL')
520dD *** @lblset         c                   const('ZBRCBI')
     D @plfmtt         c                   const('TEXT  ')

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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#cheneyo
      /COPY QCOPYSRC,id#cheneyr

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
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     D wkprtf          s             10
     D wkstyp          s              1
     D wkwhdp          s              5
520dAD @lblset         s              6
     D wkwhse          s              3  0
     D work1a          s              1
     D w1whse          s              3  0
     D forevr          s               n
     D lblcount        s              3  0
     D @plfmt          S              8
520 AD w1tst           s              3  0
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
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $line1           30
     C                   parm                    $line2           30
     C                   parm                    $line3           30
     C                   parm                    $qty              2 0
     C                   parm                    $dev             10
     C                   parm                    $form            10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
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
     *
     *   Initialize error indicators and fields
     *
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
     C     error         cabeq     '1'           endsc1
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
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
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
     *      0110 - Quantity Range
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
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
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
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
     *  Verify Quantity
     *
     C                   if        w1qty  <= *zeros or w1qty  > 99
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0110
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
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(8)       errmsg
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
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(9)       errmsg
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
     *     Prompt
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
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     *
     C                   eval      w1line1 = *blanks
     C                   eval      w1line2 = *blanks
     C                   eval      w1line3 = *blanks
     C                   eval      w1qty   = 1
     *
710 AC                   call      'GETRPT'
710 AC                   parm      '*DEVFORM'    $cmd              8
710 AC                   parm      'TEXT    '    $lrpt            10
710 AC                   parm      000           $rwhse            3 0
710 AC                   parm      ' '           $styp             1
710 AC                   parm      ' '           $whdp             5
710 AC                   parm      ' '           $desc            50
710 AC                   parm      ' '           $dev             10
710 AC                   parm      ' '           $form            10
710 A*
710 AC                   select
710 AC                   when      $dev > ' '
710 AC                   eval      w1dev  = $dev
710 AC                   eval      w1form = $form
710 AC                   other
710 A*
     C                   eval      w1dev = '*JOB    '
     C                   eval      w1form = '*STD    '
710 AC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      $pstr  = 'Text label - options'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr
     *
520dAC     *loval        setll     lblfmtd
520dAC                   dou       %eof(lblfmtd)
520dAC                   read      lblfmtd
520dAC                   if        not %eof(lblfmtd)
520dAC                   if        lfdfmt = @plfmtt
520dAC                   eval      @lblset = lfdset
520dAC                   leave
520dAC                   endif
520dAC                   endif
520dAC                   enddo
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
     C                   eval      lblcount = *zeros
520 AC                   if        w1qty > 1
520 AC                   eval      $pcmd = '*TEXT   '
520 AC                   eval      w1tst = w1qty - 1
520 AC                   endif
     *
     C                   dow       forevr = forevr
     *
     C                   call      @prtpg
     C                   parm                    $pcmd             8
     C                   parm      @lblset       $plset            6
     C                   parm      @plfmtt       $plfmt            8
     C                   parm      wkwhse        $pwhse            3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      *blanks       $pwhdp            5
     C                   parm      *blanks       $pdisp           12
     C                   parm      *blanks       $pdispa           1
     C                   parm      *blanks       $pdispb          11
     C                   parm      *blanks       $pchkd1           3
     C                   parm      *blanks       $pchkd2           3
     C                   parm      *blanks       $pchkd3           3
     C                   parm      *blanks       $plcn#           15
     C                   parm      *blanks       $plcn2           15
     C                   parm      *blanks       $pitm#           15
     C                   parm      *blanks       $brand           10
     C                   parm      *blanks       $ppdsc           15
     C                   parm      *blanks       $pdesc           30
     C                   parm      w1line1       $ptxt1           30
     C                   parm      w1line2       $ptxt2           30
     C                   parm      w1line3       $ptxt3           30
     C                   parm      *blanks       $ptrail           8
     C                   parm      *blanks       $psize            3
     C                   parm      w1dev         $pdev            10
     C                   parm      w1form        $pform           10
     *
     C                   eval      lblcount = lblcount + 1
     *
520 AC                   if        lblcount = w1tst
520 AC                   eval      $pcmd = *blanks
520 AC                   endif
     *
     C                   if        lblcount >= w1qty
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *---------------------------------------------------------------------****
     *
     *  COMPILE TIME TABLES
     *
**
Line 1
Line 2
Line 3
Quantity
Printer device
Form type
