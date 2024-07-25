      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB360   Trailer label - options
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
640aA*    11/23/11  JCJ  640aA
     *      - Enh: Added ability to select a trailer range.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
CBI A*  Client Custom Revisions: CBI
     *
CBI A*    11/29/11  JCJ  CBI A
     *      - Enh: Non display Trailer size.
     *
     *----------------------------------------------------------------
CLD A*  Client Custom Revisions: City Line
     *
CLD A*    12/23/11  RBD  CLD A
     *      - Enh: Non display Trailer size.
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
640aD ***lb360fm   cf   e             workstn
640aMFlb36001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fequip     if   e           k disk
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
     D @plfmtt         c                   const('TRAILER ')

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
      /COPY QCOPYSRC,id#cheney
CLD A /COPY QCOPYSRC,id#citylin

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
     D wkwhse          s              3  0
     D work1a          s              1
     D w1whse          s              3  0
     D forevr          s               n
     D lblcount        s              3  0
     D @plfmt          S              8
520 AD w1tst           s              3  0
520dAD @lblset         s              6
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
     C                   parm                    $trail            8
     C                   parm                    $size             3
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
     C                   move      *on           forevr
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
CBIaA*
CBIaAC                   if        client = cheney
CLDaAC                             or client = cityline
CBIaAC                   eval      *in51 = *on
CBIaAC                   endif
CBIaA*
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
     *      0110 - Starting number
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
     *  Verify From Trailer code
     *
     C                   eval      error = *on
     C     typkey        setll     equip
     C                   dow       forevr = forevr
     C     typkey        reade     equip
     C                   if        %eof(equip)
     C                   leave
     C                   endif
     C                   if        eqtype = 'TRAILR'
     C                   eval      error = *off
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   if        error = *on
     C                   eval      errmsg = *blanks
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm1001
     C                   endif
640aA*
640aA*  Verify To Trailer code
640aA*
640aAC                   eval      error = *on
640aAC     typkey2       setll     equip
640aAC                   dow       forevr = forevr
640aAC     typkey2       reade     equip
640aAC                   if        %eof(equip)
640aAC                   leave
640aAC                   endif
640aAC                   if        eqtype = 'TRAILR'
640aAC                   eval      error = *off
640aAC                   leave
640aAC                   endif
640aAC                   enddo
640aA*
640aAC                   if        error = *on
640aAC                   eval      errmsg = *blanks
640aAC                   eval      *in24 = *on
640aAC                   eval      *in04 = *on
640aAC                   eval      errmsg = desc(2)
640aAC                   exsr      zm1001
640aAC                   endif
     *
     *  Verify Quantity
     *
     C                   if        w1qty  <= *zeros or w1qty  > 99
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(3)
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
     C                   movel     desc(4)       errmsg
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
     C                   movel     desc(5)       errmsg
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
640aMC                   eval      w1trailf = *blanks
640aAC                   eval      w1trailt = *blanks
     C                   eval      w1qty   = 1
     *
CLDaAC                   select
CLDaAC                   when      client = cityline
CLDaAC                   eval      w1dev = 'ZEBRALBL'
CLDaAC                   other
     C                   eval      w1dev = '*JOB    '
CLDaAC                   endsl
     C                   eval      w1form = '*STD    '
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for EQUIP file.
     *
     C     typkey        klist
     C                   kfld                    wkwhse
640aD ***                kfld                    w1trail
640aMC                   kfld                    w1trailf
640aA*
640aAC     typkey2       klist
640aAC                   kfld                    wkwhse
640aAC                   kfld                    w1trailt
     *
     C                   eval      $pstr  = 'Trailer label - options'
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
520 AC                   eval      $pcmd = '*TRAILER'
640aD ***                eval      w1tst = w1qty - 1
640aMC                   eval      w1tst = w1qty
520 AC                   endif
     *
     *  Print Trailer range
     *
     C     typkey        setll     equip
     C                   dou       %eof(equip)
     C                   read      equip
     C                   if        not %eof(equip)

     C                   if        eqtype <> 'TRAILR'
     C                   iter
     C                   endif

     C                   eval      w1size = *blanks
     C                   eval      w1size = %subst(eqdesc:1:3)

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
     C                   parm      *blanks       $ptxt1           30
     C                   parm      *blanks       $ptxt2           30
     C                   parm      *blanks       $ptxt3           30
640aD ***                parm      w1trailf      $ptrail           8
640aMC                   parm      eqcode        $ptrail           8
     C                   parm      w1size        $psize            3
     C                   parm      w1dev         $pdev            10
     C                   parm      w1form        $pform           10

     C                   if        eqcode = w1trailt
     C     typkey        setll     equip
     C                   eval      lblcount = lblcount + 1

640aD ***                if        lblcount = w1tst
640aAC                   call      @prtpg
640aAC                   parm      *blanks       $pcmd             8
640aAC                   parm      @lblset       $plset            6
640aAC                   parm      *blanks       $plfmt            8
640aAC                   parm      wkwhse        $pwhse            3 0
640aAC                   parm      *blanks       $pwhsd           30
640aAC                   parm      *blanks       $pwhdp            5
640aAC                   parm      *blanks       $pdisp           12
640aAC                   parm      *blanks       $pdispa           1
640aAC                   parm      *blanks       $pdispb          11
640aAC                   parm      *blanks       $pchkd1           3
640aAC                   parm      *blanks       $pchkd2           3
640aAC                   parm      *blanks       $pchkd3           3
640aAC                   parm      *blanks       $plcn#           15
640aAC                   parm      *blanks       $plcn2           15
640aAC                   parm      *blanks       $pitm#           15
640aAC                   parm      *blanks       $brand           10
640aAC                   parm      *blanks       $ppdsc           15
640aAC                   parm      *blanks       $pdesc           30
640aAC                   parm      *blanks       $ptxt1           30
640aAC                   parm      *blanks       $ptxt2           30
640aAC                   parm      *blanks       $ptxt3           30
640aAC                   parm      eqcode        $ptrail           8
640aAC                   parm      w1size        $psize            3
640aAC                   parm      w1dev         $pdev            10
640aAC                   parm      w1form        $pform           10
     C                   endif

     C                   if        lblcount = w1qty
     C                   leave
     C                   endif
640aAC                   eval      $pcmd = '*TRAILER'
640aAC                   eval      $plfmt = @plfmtt
640aD ***                endif

     C                   endif
     C                   enddo
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Trailer code
Trailer code, code not found
Quantity
Printer device
Form type
