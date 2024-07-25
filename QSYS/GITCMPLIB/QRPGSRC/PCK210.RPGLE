     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK210    Create test orders for warehouse 900
     *  17 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
404 A*    09/05/97  DAS  4.04
     *      - Added order type.
     *
405 A*    09/17/97  DAS  4.05
     *      - Added cross dock option.
     *
411 A*    06/13/99  DAS  4.05
     *      - Added test #10 for Alias, Contract and SSB items.
     *
416 A*    07/16/02  DAS  4.16
     *      - Added type 'S'.
     *      - Added FTP option.
     *
520aA*    01/28/09  DAS  5.20a
     *      - Defaulted jobq to Y.
     *
610aA*    12/16/10  DAS  6.10a
     *      - Defaulted first entry to 'Y'
     *
640aA*    07/21/11  DAS  6.40a
     *      - Added Batch Pick option
     *      - Reivsed to default to using FTP files.
     *
640bA*    07/29/11  DAS  6.40b
     *      - Change ftp option into an Import Method option.
     *
640cA*    09/07/12  DAS  6.40c
     *      - Added Pre Pick option
     *
700aA*    01/30/16  DAS  7.00a
     *      - Added AMP Pick option
     *
730aA*    11/14/19  DAS  7.30a
     *      - Added warehouse
     *
730bA*    12/01/19  DAS  7.30b
     *      - Default to Staging
     *
750 A*    04/19/21  KDE  7.50
     *      - Add order type Merge so we can generate Merge orders to
     *        work and test with Super Route.  First deployed at Chefs
     *
760aA*    04/14/22  DAS  7.60a
     *      - Changed format to 02
     *      - Add order type A=Adjustment
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
750 DF**pck210fm  cf   e             workstn
760aDF**k21001  cf   e             workstn
760aMFpck21002  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
404 D*                   DESC    1   1 60
405 D*                   DESC    1   2 60
416 D**                  DESC    1   3 60
640aD**                  DESC    1   4 60
640cD**                  DESC    1   5 60
700aD**                  DESC    1   6 60
700aMD desc            s             60    dim(7) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Data structure for Y/N options
     *
     D $pyn            ds
     D  w1yn1                  1      1
     D  w1yn2                  2      2
     D  w1yn3                  3      3
     D  w1yn4                  4      4
     D  w1yn5                  5      5
     D  w1yn6                  6      6
     D  w1yn7                  7      7
     D  w1yn8                  8      8
     D  w1yn9                  9      9
     D  w1yn10                10     10
     D  w1yn11                11     11
     D  w1yn12                12     12
     D  w1yn13                13     13
     D  w1yn14                14     14
     D  w1yn15                15     15
     D  w1yn16                16     16
     D  w1yn17                17     17
     D  w1yn18                18     18
     D  w1yn19                19     19
     D  w1yn20                20     20
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
404 A*              'W' - Will cal
405 A*      $PXDK   'Y' - Yes
405 A*              'N' - No
416 A*      $PFTP   'Y' - Yes
416 A*              'N' - No
640aA*      $PBPCK  'Y' - Yes
640aA*              'N' - No
640cA*      $PPPCK  'Y' - Yes
640cA*              'N' - No
700aA*      $PAPCK  'Y' - Yes
700aA*              'N' - No
700aA*      $PACOD  AMP Staging area code
730aA*      $PWHSEA Warehouse
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *JOBQ    - Run from jobq.
     *              *NORMAL  - Run normaly.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pyn
404 AC                   parm                    $ptype            1
405 AC                   parm                    $pxdk             1
416 AC                   parm                    $pftp             1
640aAC                   parm                    $pbpck            1
640cAC                   parm                    $pppck            1
700aAC                   parm                    $papck            1
700aAC                   parm                    $pacod            3
730aAC                   parm                    $pwhsea           3
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
730aA*
730aA*  Verify warehouse is from 900 - 905
730aA*
730aAC                   if        w1whse < 900 or w1whse > 905
730aAC                   eval      error = *on
730aAC                   eval      *in21 = *on
730aAC                   eval      *in01 = *on
730aAC                   eval      errmsg = 'Warehouse must be 900 - 905'
730aAC                   exsr      zm1001
730aAC                   endif
404 A*
404 A*  Verify order type
404 A*
404 AC                   if        w1type <> ' '  and
760aAC                             w1type <> 'A'  and
404 AC                             w1type <> 'W'  and
750 MC                             w1type <> 'S'  and
750 AC                             w1type <> 'M'
404 AC                   eval      error = *on
404 AC                   eval      *in22 = *on
404 AC                   eval      *in02 = *on
404 AC                   eval      errmsg = *blanks
404 AC                   movel     desc(2)       errmsg
404 AC                   exsr      zm1001
404 AC                   endif
405 A*
405 A*  Verify cross dock.
405 A*
405 AC                   if        w1xdk <> 'Y'  and
405 AC                             w1xdk <> 'N'
405 AC                   eval      error = *on
405 AC                   eval      *in24 = *on
405 AC                   eval      *in04 = *on
405 AC                   eval      errmsg = *blanks
405 AC                   movel     desc(3)       errmsg
405 AC                   exsr      zm1001
405 AC                   endif
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
640cA*
640cA*  Verify Pre Pick
640cA*
640cAC                   if        w1ppck <> 'Y'  and
640cAC                             w1ppck <> 'N'
640cAC                   eval      error = *on
640cAC                   eval      *in27 = *on
640cAC                   eval      *in07 = *on
640cAC                   eval      errmsg = *blanks
640cAC                   movel     desc(6)       errmsg
640cAC                   exsr      zm1001
640cAC                   endif
700aA*
700aA*  Verify AMP Pick
700aA*
700aAC                   if        w1apck <> 'Y'  and
700aAC                             w1apck <> 'N'
700aAC                   eval      error = *on
700aAC                   eval      *in28 = *on
700aAC                   eval      *in08 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     desc(7)       errmsg
700aAC                   exsr      zm1001
700aAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
520aMC                   eval      w1jobq = 'Y'
404 AC                   eval      w1type = ' '
405 AC                   eval      w1xdk = 'N'
730bMC                   eval      w1ftp = 'S'
640aAC                   eval      w1bpck = 'N'
640cAC                   eval      w1ppck = 'N'
700aAC                   eval      w1apck = 'N'
700aAC                   move      '   '         w1acod
610aAC                   eval      w1yn1 = 'Y'
730aAC                   eval      w1whse = 900
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
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
     C                   if        w1jobq = 'Y'
     C                   eval      $prtn = '*JOBQ   '
     C                   else
     C                   eval      $prtn = '*NORMAL '
     C                   endif
     *
404 AC                   eval      $ptype = w1type
405 AC                   eval      $pxdk = w1xdk
416 AC                   eval      $pftp = w1ftp
640aAC                   eval      $pbpck = w1bpck
640cAC                   eval      $pppck = w1ppck
700aAC                   eval      $papck = w1apck
700aAC                   eval      $pacod = w1acod
730aAC                   eval      $pwhsea = %editc(w1whse: 'X')
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
Order type
Cross dock
Import Method
Batch pick
Pre pick
AMP pick
