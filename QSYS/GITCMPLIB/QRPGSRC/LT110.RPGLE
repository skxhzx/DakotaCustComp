     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LT110     Create Priority replenishments - Options
     *  Max Blacknik
     *  11 February 2000
     *
     *----------------------------------------------------------------
     *
     *  Revisions:
     *
500 A*    10/18/04  DAS  5.00
     *      - Converted to ILE.
     *      - Added commands *RPLLVL and *AVGnnn.
640aA*    12/16/11  RH   6.40a
     *      - Renamed CVTNUM to CVTNUMB
640bA*    02/13/12  MLB  6.40b
     *      - Enh: Revised pgm to set Send to Jobq = Y=Yes from N=No.
     *
700 A*    06/03/16  MLB  7.00
     *      - Enh: Added client custom pgm support.
     *
720 A*    09/27/18  KDE  7.20
     *      - Enh: Added option to select specific replen type
     *
750 A*    02/17/21  KDE  7.50
     *      - Enh: Added Drop Pick as replen option
     *
     *----------------------------------------------------------------
     *  City line Custom
CLDa *    11/18/04  HNK  CLDa
     *      - Add Client data structure and default replenishment
     *        basis to '*RPLLVL'
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    06/03/16  MLB  DRY
     *      - Revised program to force Place On Jobq = Y and it cannot
     *        be overridden.  Only user id, BFCxxxxxxx can change dft.
     *      - Per Kelly R. email dated 06.03.2016.
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
720 DF**Lt110fm   cf   e             workstn
750 DF**Lt11001   cf   e             workstn
750 MFLt11002   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   if   e           k disk
700 A*----------------------------------------------------------------
700 A*  Customer id
700 A*
700 AD @getcl          c                   const('GETCLIENT')
700 A*
CLDa  /copy qcopysrc,id#citylin
DRY A /copy qcopysrc,id#Dairyla
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
500 DD*desc            s             60    dim(6) ctdata perrcd(1)
500 MD desc            s             60    dim(7) ctdata perrcd(1)
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
     D  $lwhdp                22     26
     *----------------------------------------------------------------
     *  *REPLEN  -  Replenishment options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY)
     *
     * Data structure
     *
     D opdata          ds
     D  oprplb                 1      8
     D  optend               117    117
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
     D wkwhse          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PWHSE  - Warehouse number
     *      $PWHDP  - Warehouse department or *ALL
     *      $PRPLB  - Replenishment basis (*AVGQTY, *ORDQTY)
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *      $PJOBQ  - Jobq
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $whdp             5
     C                   parm                    $rplb             8
     C                   parm                    $prtn             8
     C                   parm                    $jobq             1
720 AC                   parm                    $rtype            1
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
720 MC                   setoff                                       3031
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
700 A*
700 A* Get client id.
700 A*
700 AC                   call      @getcl
700 AC                   parm                    client           10
700 AC                   parm                    clientloc        10
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
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   if        w1whdp <> '*ALL '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
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
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
     *  Verify replenishment basis.
     *
500 DC**                 if        w1rplb <> '*AVGQTY'  and
500 MC                   if        %subst(w1rplb:1:4) <> '*AVG' and
500 AC                             w1rplb <> '*RPLLVL' and
     C                             w1rplb <> '*ORDQTY'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   exsr      zm1001
500 AC                   goto      endck1
     C                   endif
     *
     *  Verify replenishment type
     *
720 AC                   if        w1rtype<>'N' and w1rtype<>'F' and
720 AC                             w1rtype<>'B' and w1rtype<>'R' and
720 AC                             w1rtype<>'S' and w1rtype<>'A' and
720 AC                             w1rtype<>'D'
720 AC                   eval      error = *on
720 AC                   eval      *in31 = *on
720 AC                   eval      *in09 = *on
720 AC                   eval      errmsg = *blanks
720 AC                   eval      errmsg='Replenishment Type invalid'
720 AC                   exsr      zm1001
720 AC                   goto      endck1
720 AC                   endif
500 A
500 A*  If *AVGnnn sent, verify that nnn is numeric.
500 A
500 AC                   if        %subst(w1rplb:1:4) = '*AVG'
500 AC                             and w1rplb <> '*AVGQTY'
500 A
500 AC                   eval      $cvstr =  %subst(w1rplb:5:3)
640aDC*                  call      'CVTNUM'
640aMC                   call      'CVTNUMB'
500 AC                   parm      '*STR2NUM'    $cvcmd            8
500 AC                   parm                    $cvstr           30
500 AC                   parm      0             $cvnum           15 5
500 AC                   parm      0             $cvdec            1 0
500 AC                   parm                    $cvrtn            8
500 A
500 AC                   if        $cvrtn = '*ERROR'
500 AC                   eval      error = *on
500 AC                   eval      *in23 = *on
500 AC                   eval      *in03 = *on
500 AC                   eval      errmsg = *blanks
500 AC                   movel     desc(7)       errmsg
500 AC                   exsr      zm1001
500 AC                   goto      endck1
500 AC                   endif
500 A
500 AC                   endif
     *
     *  Verify jobq option
     *
     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
DRY AC                   if        client = Dairyland
DRY A*      Force Jobq=Y for all users except BFCxxxxxxx.
DRY AC                   if        %subst(#user:1:3) <> 'BFC'
DRY AC                   eval      w1jobq = 'Y'
DRY AC                   endif
DRY AC                   endif
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
     *     Warehouse.
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
     *     Warehouse department.
     *
     C                   when      row# = 10
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
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
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     *
     C                   eval      w1whdp = '*ALL '
     *
     *    Retrieve replenishment basis from OPTIONS file.
     *
     C                   eval      opwhse = w1whse
     C                   eval      opcode = '*REPLEN '
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      w1rplb = '*AVGQTY '
     C                   else
     C                   eval      w1rplb = oprplb
     C                   endif
CLDa *
CLDa C                   if        client = cityline
CLDa C                   eval      w1rplb = '*RPLLVL'
CLDa C                   endif
     *
640bDC*                  eval      w1jobq = 'N'
640bMC                   eval      w1jobq = 'Y'
720 AC                   eval      w1rtype = 'A'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *    Define key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     C                   move      w1whse        $whse
     C                   eval      $whdp = w1whdp
     C                   eval      $rplb = w1rplb
     C                   eval      $jobq = w1jobq
720 AC                   eval      $rtype = w1rtype
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Section type
Print option
Job queue option
Printer device
Form type
Replenishment basis
Percent
