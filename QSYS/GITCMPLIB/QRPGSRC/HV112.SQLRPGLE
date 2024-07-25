      /copy *libl/qcopysrc,hspecs
640aAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HV112     HACCP Question File validation maintenance - Change
     *  10 April 2012
     *  Lynn McMahon
     *
     *  Revisions
     *
640a *    08/14/12  LMC  6.40a
     *      - Fix: Validate to make sure value does not already exist
650aA*    04/04/13  LMC  6.50a
     *      - Fix: Need to protect w1t3vl unless adding. Conditioned
     *        the edit that checks if it already exist for adding only
     *      - renamed display file from HV112FM to HV11201.
720aA*    04/25/18  LMC  7.20a
     *      - Fix: On answer types 5,8 & 9. Only one range is allowed
640aA*----------------------------------------------------------------
640aA*  Binding Directories
640aA*----------------------------------------------------------------

640aAHbnddir('BFCBND')
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  41 - 50   Field conditioning (non display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aDF*hv112fm   cf   e             workstn
650aMFhv11201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fhaccpv1   if   e           k disk    rename(hvrec:seq) prefix(sq_)
     Fhaccpv2   uf a e           k disk
     F                                     rename(hvrec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             20    dim(8) ctdata perrcd(1)
     D msg             s             50    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
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
     D  $pseq#                44     48  0
     D  $pvsq#                49     53  0
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
     D  $litem                22     36
     D  $lcat                 19     28
     D  $latyp                19     19
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
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
     D                                     dim(128)
640aA*----------------------------------------------------------------
640aA*  File field data structure.
640aA*----------------------------------------------------------------

640aAD haccpv        e ds

640aA*----------------------------------------------------------------
640aA*  Standard variables and constants
640aA*----------------------------------------------------------------

640aA /copy qcopysrc,c#stdvar

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------

640aA /copy qcopysrc,c#stdsql

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
     *  Work field data structure
     *
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D answertype      s              1
     D chkobjret       s              8
     D chkobjtype      s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D displayall      s               n
     D e               s              2  0
640aDD*enter           s              5  0
640aDD*error           s              1
640aDD*forever         s              1
     D help            s              5  0
     D insert          s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D pageseqcnt      s              2  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D savetype        s              3
     D savelevl        s              4
     D sclear          s              1
640aDD*warn            s              1
     D wkpgsq          s              2  0

510bAD currtimestamp   s               z
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
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
     C                   parm                    w1qstn
     c                   parm                    answertype
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
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303435
     C                   setoff                                       98
650aAC                   setoff                                       33
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
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
650aAc                   eval      *in33 = *on
     C                   endif
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
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C     displayall    cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C                   endif
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *  Initialize special keys
     *
640aDC*                  eval      enter = 0
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
640aDC*                  movea     desc          errmsg
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
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0105  Generic message.
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C*                  if        $pcmd = '*ADD    '
     *
     *    Make sure level was entered.
     *
     C*                  if        w1levl = *blanks
     C*                  eval      error = *on
     C*                  eval      *in21 = *on
     C*                  exsr      zm01
     c*                  leavesr
     C*                  endif
     *
     *    Make sure type was entered.
     *
     C*                  if        w1type = *blanks
     C*                  eval      error = *on
     C*                  eval      *in21 = *on
     C*                  exsr      zm01
     c*                  leavesr
     C*                  endif
     *
     C*                  endif
     *
     *    Valid Answer must be entered
     *
     C                   if        w1t3vl = *blanks  and answertype = '3'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     c                   eval      errmsg = desc(2)
     C                   exsr      zm03
     C                   endif
     C                   if        w1t5vl = 0 and answertype = '5'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     c                   eval      errmsg = desc(2)
     C                   exsr      zm03
     C                   endif
     C                   if        w1valu = 0 and answertype = '8'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     c                   eval      errmsg = desc(2)
     C                   exsr      zm03
     C                   endif
     C                   if        w1valu = 0 and answertype = '9'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     c                   eval      errmsg = desc(2)
     C                   exsr      zm03
     C                   endif
640aA*
640aA*    Make sure value does not already exist
640aA*
640aAC                   if        w1t3vl <> *blanks  and answertype = '3'
650aAc                             and $pcmd = '*ADD'
640aA /free
640aA   exec sql select * into :haccpv
640aA            from haccpv
640aA            where hvwhse = :$pwhse
640aA            and hvlevl = :w1levl
640aA            and hvtype = :w1type
640aA            and hvcode = :w1code
640aA            and hvseq# = :w1seq#
640aA            and hvt3vl = :w1t3vl;
640aA /end-free
640aAc                   if        sqlstt = sqlsuccess
640aAC                   eval      error = *on
640aAC                   eval      *in23 = *on
640aAC                   eval      *in03 = *on
640aAc                   eval      errmsg = desc(2)
640aAC                   exsr      zm02
640aAC                   endif
640aAC                   endif
640aA
640aAC                   if        w1t5vl <> 0 and answertype = '5'
720aAc                             and $pcmd = '*ADD'
640aA /free
640aA   exec sql select * into :haccpv
640aA            from haccpv
640aA            where hvwhse = :$pwhse
640aA            and hvlevl = :w1levl
640aA            and hvtype = :w1type
640aA            and hvcode = :w1code
640aA            and hvseq# = :w1seq#
720aA            and hvactive = 1;
720aD            //and hvt5vl = :w1t5vl;
640aA /end-free
640aAc                   if        sqlstt = sqlsuccess
640aAC                   eval      error = *on
640aAC                   eval      *in24 = *on
640aAC                   eval      *in04 = *on
640aAc                   eval      errmsg = desc(2)
640aAC                   exsr      zm02
640aAC                   endif
640aAC                   endif
640aA
640aAC                   if        w1valu <> 0 and answertype = '8'
720aAc                             and $pcmd = '*ADD'
640aA /free
640aA   exec sql select * into :haccpv
640aA            from haccpv
640aA            where hvwhse = :$pwhse
640aA            and hvlevl = :w1levl
640aA            and hvtype = :w1type
640aA            and hvcode = :w1code
640aA            and hvseq# = :w1seq#
720aA            and hvactive = 1;
720aD            //and hvvalu = :w1valu;
640aA /end-free
640aAc                   if        sqlstt = sqlsuccess
640aAC                   eval      error = *on
640aAC                   eval      *in25 = *on
640aAC                   eval      *in05 = *on
640aAc                   eval      errmsg = desc(2)
640aAC                   exsr      zm02
640aAC                   endif
640aAC                   endif
640aA
640aAC                   if        w1valu <> 0 and answertype = '9'
720aAc                             and $pcmd = '*ADD'
640aA /free
640aA   exec sql select * into :haccpv
640aA            from haccpv
640aA            where hvwhse = :$pwhse
640aA            and hvlevl = :w1levl
640aA            and hvtype = :w1type
640aA            and hvcode = :w1code
640aA            and hvseq# = :w1seq#
720aA            and hvactive = 1;
720aD            //and hvvalu = :w1valu;
640aA /end-free
640aAc                   if        sqlstt = sqlsuccess
640aAC                   eval      error = *on
640aAC                   eval      *in25 = *on
640aAC                   eval      *in05 = *on
640aAc                   eval      errmsg = desc(2)
640aAC                   exsr      zm02
640aAC                   endif
640aAC                   endif
     *
     *    Valid Answer ranges
     *
     C                   if        w1t5rg <> 0 and w1t5vl >= w1t5rg
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in34 = *on
     C                   eval      *in04 = *on
     c                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     C                   if        w1valr <> 0 and w1valu >= w1valr
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in35 = *on
     C                   eval      *in05 = *on
     c                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *    description field is not used for ranges
     *
     C                   if        w1t5rg <> 0 and w1desc <> ' ' or
     C                             w1valr <> 0 and w1desc <> ' '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     c                   eval      errmsg = desc(8)
     C                   exsr      zm0105
     C                   endif
     *
     *    Warning fiels is for ranges only
     *
     C                   if        w1t5rg =  0 and w1warn <> ' ' and
     C                             w1valr =  0 and w1warn <> ' '
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     c                   eval      errmsg = desc(8)
     C                   exsr      zm0105
     C                   endif
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
     *
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
     C                   eval      w1type = $ptype
     C                   eval      w1levl = $plevl
     C                   eval      w1code = $pcode
     C                   eval      w1t3vl = *blanks
     C                   eval      w1seq# = $pseq#
     C                   eval      w1vsq# = $pvsq#
     C                   eval      w1t5vl = 0
     C                   eval      w1t5rg = 0
     C                   eval      w1valu = 0
     C                   eval      w1valr = 0
     C                   eval      w1desc = *blanks
     C                   eval      w1warn = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1type = hvtype
     C                   eval      w1levl = hvlevl
     C                   eval      w1code = hvcode
     C                   eval      w1t3vl = hvt3vl
     C                   eval      w1seq# = hvseq#
     C                   eval      w1vsq# = hvvsq#
     C                   eval      w1t5vl = hvt5vl
     C                   eval      w1t5rg = hvt5rg
     C                   eval      w1valu = hvvalu
     C                   eval      w1valr = hvvalr
     C                   eval      w1desc = hvdesc
     C                   eval      w1warn = hvwarn
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     *
     *   If viewing, release record.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $plevl
     C                   kfld                    $ptype
     C                   kfld                    $pcode
     C                   kfld                    $pseq#
     C                   kfld                    $pvsq#
     *
     *  Define partial key for main file.
     *
     C*    partky        klist
     *

     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
      /free
        // for add need next available validation sequence number
        if $pcmd = '*ADD    ';
          setgt ($pwhse: $pseq#) haccpv1;
          readpe ($pwhse: $pseq#) haccpv1;
          $pvsq# = sq_hvvsq# + 1;
        endif;
        // turn on indicators based on answer type
        select;
          when answertype = '3';
            *in13 = *on;
            *in14 = *off;
            *in15 = *off;
          when answertype = '5';
            *in14 = *on;
            *in13 = *off;
            *in15 = *off;
          when answertype = '8';
            *in15 = *on;
            *in13 = *off;
            *in14 = *off;
          when answertype = '9';
            *in15 = *on;
            *in13 = *off;
            *in14 = *off;
        endsl;
      /end-free
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *
     *
     *  if insert need to move seq# in file
     *
     *
     *  Move screen fields to record fields
     *
     C                   eval      hvwhse = $pwhse
     C                   eval      hvlevl = w1levl
     C                   eval      hvtype = w1type
     C                   eval      hvcode = w1code
     C                   eval      hvt3vl = w1t3vl
     C                   eval      hvseq# = w1seq#
     C                   eval      hvvsq# = w1vsq#
     C                   eval      hvt5vl = w1t5vl
     C                   eval      hvt5rg = w1t5rg
     C                   eval      hvvalu = w1valu
     C                   eval      hvvalr = w1valr
     C                   eval      hvdesc = w1desc
     C                   eval      hvwarn = w1warn
     C                   eval      hvactive = '1'
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
     *
     *   Move key values to parameters
     *
     c                   eval      $ptype = hvtype
     c                   eval      $plevl = hvlevl
     c                   eval      $pcode = hvcode
     c                   eval      $pseq# = hvseq#
     c                   eval      $pvsq# = hvvsq#
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Valid Question Type
Valid Answer
Range is invalid
Page seq# exist
Valid Answer Type
Answer Required
Validation Table
Entry Not Allowed
**
'H' not allowed at this time.
Only 'D' is allowed for an '@' code.
