650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK220    Create random test orders for warehouse 900
     *  29 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
404 A*    09/05/97  DAS  4.04
     *      - Added order type.
     *
416 A*    07/16/02  DAS  4.16
     *      - Added type 'S'.
     *      - Added FTP option.
     *
520aA*    01/28/09  DAS  5.20a
     *      - Defaulted jobq to Y.
     *
640aA*    07/21/11  DAS  6.40a
     *      - Added Batch Pick option
     *      - Default FTP to 'Y'
     *
640bA*    07/29/11  DAS  6.40b
     *      - Change ftp option into an Import Method option.
     *
650aA*    10/28/13  DAS  6.50a
     *      - Converted to ILE
     *      - Added warehouse option
     *
700aA*    01/30/16  DAS  7.00a
     *      - Added AMP Pick option
     *
710aA*    06/05/17  DAS  7.10a
     *      - F4 line for truck changed to 4.
     *      - Change AMP default to 'N'.
     *
730bA*    12/02/19  DAS  7.30b
     *      - Default to Staging
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
     Fpck220fm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Ftruckd    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
404 D*                   DESC    1   2 60
416 D**                  DESC    1   3 60
640aD**                  DESC    1   4 60
700aDD*desc            s             60    dim(5) ctdata perrcd(1)
700aMD desc            s             60    dim(6) ctdata perrcd(1)
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
     D  $ltruk                22     31
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
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
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D forevr          s              1
     D kywhse          s              3  0
     D msgk            s              4  0
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
404 A*      $PTYPE  ' ' - Normal
404 A*              'W' - Normal
416 A*      $PFTP   'Y' - Yes
416 A*              'N' - No
640aA*      $PBPCK  'Y' - Yes
640aA*              'N' - No
700aA*      $PAPCK  'Y' - Yes
700aA*              'N' - No
700aA*      $PACOD  AMP Staging area code
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *JOBQ    - Run from jobq.
     *              *NORMAL  - Run normaly.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prte             5
     C                   parm                    $ptruk           10
     C                   parm                    $pitm1           15 5
     C                   parm                    $pitm2           15 5
     C                   parm                    $ppcs1           15 5
     C                   parm                    $ppcs2           15 5
     C                   parm                    $pdry            15 5
     C                   parm                    $pref            15 5
     C                   parm                    $pfrz            15 5
     C                   parm                    $plbl             1
404 AC                   parm                    $ptype            1
416 AC                   parm                    $pftp             1
640aAC                   parm                    $pbpck            1
650aAC                   parm                    $pwhsea           3
700aAC                   parm                    $papck            1
700aAC                   parm                    $pacod            3
     C                   parm                    $prtn             8
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
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
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
650aAC                   eval      kywhse = w1whse
     *
     *  Verify truck code
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = kywhse
     C                   eval      $ltruk = w1truk
     C                   call      'TM900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
404 A*
404 A*  Verify order type
404 A*
404 AC                   if        w1type <> ' '  and
404 AC                             w1type <> 'W'  and
416 AC                             w1type <> 'S'
404 AC                   eval      error = *on
404 AC                   eval      *in24 = *on
404 AC                   eval      *in04 = *on
404 AC                   eval      errmsg = *blanks
404 AC                   movel     desc(3)       errmsg
404 AC                   exsr      zm1001
404 AC                   endif
416 A*
416 A*  Verify FTP
416 A*
640bD**         W1FTP     IFNE 'Y'
640bD**         W1FTP     ANDNE'N'
640bMC                   if        w1ftp <> 'F'  and
640bMC                             w1ftp <> 'S'
416 AC                   eval      error = *on
416 AC                   eval      *in25 = *on
416 AC                   eval      *in05 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   movel     desc(4)       errmsg
416 AC                   exsr      zm1001
416 AC                   endif
640aA*
640aA*  Verify Batch Pick
640aA*
640aAC                   if        w1bpck <> 'Y'  and
640aAC                             w1bpck <> 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in26 = *on
640aAC                   eval      *in06 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(5)       errmsg
640aAC                   exsr      zm1001
640aAC                   endif
700aA*
700aA*  Verify Batch Pick
700aA*
700aAC                   if        w1apck <> 'Y'  and
700aAC                             w1apck <> 'N'
700aAC                   eval      error = *on
700aAC                   eval      *in26 = *on
700aAC                   eval      *in06 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     desc(6)       errmsg
700aAC                   exsr      zm1001
700aAC                   endif
     *
     *  Verify WORKLBL option.
     *
     C                   if        w1lbl <> 'Y'  and
     C                             w1lbl <> 'N'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
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
650aAC                   eval      kywhse = w1whse
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
     *     Truck
     *
650aDC**                 when      row# = 6
710aDC**                 when      row# = 5
710aMC                   when      row# = 4
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = kywhse
     C                   eval      $ltruk = w1truk
     C                   call      'TM900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1truk = $ltruk
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
     *
     *  Test for F9 - Calculate cube from truck.
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     *
     C                   eval      w1dry = 0
     C                   eval      w1ref = 0
     C                   eval      w1frz = 0
     C     keytd         setll     truckd
     C                   dow       forevr = forevr
     C     keytd         reade     truckd                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   select
     C                   when      tdcomp = 'D'
     C                   add       tdcube        w1dry
     C                   when      tdcomp = 'R'
     C                   add       tdcube        w1ref
     C                   when      tdcomp = 'F'
     C                   add       tdcube        w1frz
     C                   endsl
     C                   enddo
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1rte = *blanks
     C                   eval      w1truk = *blanks
404 AC                   eval      w1type = ' '
730bMC                   eval      w1ftp = 'S'
640aAC                   eval      w1bpck = 'N'
710aMC                   eval      w1apck = 'N'
700aAC                   eval      w1acod = ''
     C                   eval      w1itm1 = 0
     C                   eval      w1itm2 = 0
     C                   eval      w1pcs1 = 0
     C                   eval      w1pcs2 = 0
     C                   eval      w1dry = 0
     C                   eval      w1ref = 0
     C                   eval      w1frz = 0
     C                   eval      w1lbl = 'N'
520aMC                   eval      w1jobq = 'Y'
650aAC                   eval      w1whse = 900
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Initialize variables
     *
     C                   eval      forevr = *on
     C                   eval      error = *off
     *
     *   Define keys
     *
     C     keytd         klist
     C                   kfld                    kywhse
     C                   kfld                    w1truk
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      kywhse = 900
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
650aAC                   eval      $pwhsea = %editc(w1whse: 'X')
     C                   eval      $prte = w1rte
     C                   eval      $ptruk = w1truk
404 AC                   eval      $ptype = w1type
416 AC                   eval      $pftp = w1ftp
640aAC                   eval      $pbpck = w1bpck
700aAC                   eval      $papck = w1apck
700aAC                   eval      $pacod = w1acod
     C                   eval      $pitm1 = w1itm1
     C                   eval      $pitm2 = w1itm2
     C                   eval      $ppcs1 = w1pcs1
     C                   eval      $ppcs2 = w1pcs2
     C                   eval      $pdry = w1dry
     C                   eval      $pref = w1ref
     C                   eval      $pfrz = w1frz
     C                   eval      $plbl = w1lbl
     *
     C                   if        w1jobq = 'Y'
     C                   eval      $prtn = '*JOBQ   '
     C                   else
     C                   eval      $prtn = '*NORMAL '
     C                   endif
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Job queue option
Populate WORKLBL file
Order type
FTP
Batch pick
AMP pick
