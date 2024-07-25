      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PT860     Reset Transaction to Open Status
     *  November 20, 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    11/20/18  RTR  7.20
     *      - Created.
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
     Fpt860fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser1  if   e           k disk
     Fpiruser   if   e           k disk
     F                                     rename(usrec:record)
     Fpirtran   uf   e           k disk
     Ftranlog   o    e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(8) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Constants
     *
     D msg1            c                   const('Transaction # ')
     D msg3            c                   const(' was successfully-
     D                                      reset')
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
     D  $lemp#                19     23  0
     D  $lstat                24     24
     D  $ltrn                 19     25  0
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdate                 1      6  0
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
     *  Working variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
510aAD forever         s              1     inz('1')
     D msgk            s              4  0
     D msg2            s             21
     D msg4            s             44
     D nxtscr          s              3
     D sclear          s              1
     D stop            s              1
     D tran#           s              7
     D warn            s              1
     D whse            s              3  0
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
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
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *PIR     - Select only PIR items
     *              *FIXED   - Select only Fixed items
     *              *BOTH    - Select all items
     *      $PLNK   'Y'      - Linked item exists
     *              'N'      - No linked items.
     *
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
     C                   setoff                                       3031
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      stop = *off
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
     *>                   MOVE '*EXIT   '$PRTN
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
     *>                   MOVE '*CANCEL '$PRTN
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
     *
     *    PIR9901  Invalid date entered.
     *
     C     zm9901        begsr
     C                   eval      #msgid = 'PIR9901'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
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
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0204  Can only enter one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0205  Must enter at least one value.
     *
     C     zm0205        begsr
     C                   eval      #msgid = 'PIR0205'
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
     *    IT31201  Can't enter virtual slot, enter base.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IT31201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11222  Multiple transactions exist.
     *
     C     zm1222        begsr
     C                   eval      #msgid = 'TE11222'
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
     *  Check if screen input was no provided
     *
     C                   if        w1emp# = *zeros  and
     C                             w1trn# = *zeros
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0205
     C                   goto      endck1
     C                   endif
     *
     *  Check if screen input was no provided
     *
     C                   if        w1emp# <> *zeros  and
     C                             w1trn# <> *zeros
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0204
     C                   goto      endck1
     C                   endif
     *
     *  Verify transaction number.
     *
     C                   if        w1trn# <> 0
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ltrn = w1trn#
     C                   call      'PT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   goto      endck1
     C                   endif
     *
     *  Verify employee number
     *
     C                   if        w1emp# <> *zeros
     C     w1emp#        chain     piruser1                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
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
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *------------------> EMPTY
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      whse = 1
     *
     C     lblkey        klist
     C                   kfld                    whse
     C                   kfld                    w1trn#
     *
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
     C                   select
     C                   when      w1trn# <> *zeros
     *
     C     w1trn#        chain     pirtran                            79
     *
     C                   if        pttask <> 'FIXED '  and
     C                             pttask <> 'PIR   '
     C                   eval      error = *on
     C                   movel     desc(8)       errmsg
     C                   exsr      zm0105
     C                   eval      nxtscr = '01 '
     C                   goto      endnxt
     C                   endif
     *
     C                   if        ptstat = '1'
     C                   eval      error = *on
     C                   movel     desc(3)       errmsg
     C                   exsr      zm0105
     C                   eval      nxtscr = '01 '
     C                   goto      endnxt
     C                   endif
     *
     C                   if        ptstat = '3'
     C                   eval      error = *on
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0105
     C                   eval      nxtscr = '01 '
     C                   goto      endnxt
     C                   endif
     *
     C                   if        ptstat = '4'
     C                   eval      error = *on
     C                   movel     desc(5)       errmsg
     C                   exsr      zm0105
     C                   eval      nxtscr = '01 '
     C                   goto      endnxt
     C                   endif
     *
     C                   if        ptstat > '4'
510aA*     Check if Labels have been picked.
510aAC                   eval      whse = ptwhse
510aAC     lblkey        setll     label90
510aAC                   dow       forever = forever
510aAC     lblkey        reade     label90
510aAC                   select
510aAC                   when      %eof(label90)
510aA*     No labels have been picked, okay to re-open.
510aAC                   goto      okay2open
510aA*
510aAC                   when      lbvrfy = 'T'
510aAC                             or lbvrfy = 'I'
510aAC                             or lbvrfy = 'F'
510aAC                             or lbstat <> 'P'
510aA*     At least 1 or more labels have been picked,
510aA*     not okay to re-open.
510aAC                   leave
510aAC                   endsl
510aAC                   enddo
510aA*
     C                   eval      error = *on
     C                   movel     desc(6)       errmsg
     C                   exsr      zm0105
     C                   eval      nxtscr = '01 '
     C                   goto      endnxt
     C                   endif
510aA*
510aAC     okay2open     tag
     *
     *  Create and write, before update, log record.
     *
     C                   exsr      zzwlog
     *
     *  Update 'Pirtran' record.
     *
     C                   eval      ptstat = *on
     **                   Z-ADD*ZEROS    PTEMP#
     C                   eval      ptcrew = *blanks
     C                   eval      ptshft = *blanks
     C                   eval      ptsdte = *zeros
     C                   eval      ptstim = *zeros
     C                   eval      ptdmin = *zeros
     C                   eval      ptimin = *zeros
     C                   update    ptrec
640aAc                   exsr      zzwrttrand
     *
     C     w1trn#        chain     multran1                           79
     C                   if        not *in79
     C                   delete    murec
     C                   endif
     *
     C                   move      w1trn#        tran#
     C     msg1          cat       tran#         msg2
     C     msg2          cat       msg3          msg4
     C                   eval      error = *on
     C                   movel     msg4          errmsg
     C                   exsr      zm0105
     C                   eval      w1trn# = *zeros
     C                   eval      nxtscr = '01 '
     *
     C                   endsl
     *
     C     endnxt        endsr
     *----------------------------------------------------------------*********
     *  ZZWLOG   Write, before update, log record.
     *----------------------------------------------------------------
     *
     C     zzwlog        begsr
     *
     *   Load log record.
     *
     C                   clear                   trnrec
     *
     C                   eval      ttrn# = pttrn#
     C                   eval      tstat = ptstat
     C                   eval      temp# = ptemp#
     C                   eval      tcrew = ptcrew
     C                   eval      tshft = ptshft
     C                   eval      tsdte = ptsdte
     C                   eval      tstim = ptstim
     C                   movel     'PIRTRAN'     ttrnf
     *
     C     #user         chain     piruser                            79
     C                   if        not *in79
     C                   eval      tuser = usemp#
     C                   else
     C                   eval      tuser = *zeros
     C                   endif
     *
     C                   write     trnrec
     C                   endsr
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Employee number
Reset multiple transactions cancelled
This tran has not been assigned to anyone yet
This tran is in 'ENDED' status. Contact IT Dept.
This tran is in 'CLOSED' status. Contact IT Dept.
Contact IT Dept.
Transaction(s) successfully reset to Open status.
Transaction not a Selection Transaction.
