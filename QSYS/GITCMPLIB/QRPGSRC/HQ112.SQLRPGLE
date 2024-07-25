      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HQ112     HACCP Question File maintenance - Change
     *  20 February 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
     *    02/20/12  LMC  6.40
     *      - Enh: Date created.
640a *    08/14/12  LMC  6.40a
     *      - Fix: Code lookup field $llook was getting wiped out, if
     *        f4 was used to lookup a table for another purpose.
     *        Moved the $llook for code validation to $cdlook field
640b *    10/26/12  LMC  6.40b
     *      - Fix: Changed the display file to HQ11201.
     *        Fix: Category was not being retrieved properly
650  *    04/04/13  LMC  6.50
     *      - Enh: Changed the display file to HQ11202.
650aA*    04/15/13  LMC  6.50a
     *      - Enh: Added new level REXI.
650bA*    06/28/13  LMC  6.50b
     *      - Fix: REXI logic had broken the freqeuency logic on RCVI.
650cA*    07/03/13  LMC  6.50c
     *      - Enh: New Display file - Allow freqeuency field to be
     *      changed after haccplog record exists.
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
740a *    05/19/20  LMC  7.40a
     *      - Recompile only - Databases changes.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

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
640bDF*hq112fm   cf   e             workstn
650 DF*hq11201   cf   e             workstn
650cDF*hq11202   cf   e             workstn
650cMFhq11203   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fhaccpqt   if   e           k disk
     Fhaccpq    uf a e           k disk
     F                                     rename(hirec:record)
     Fhaccpq1   if   e           k disk    prefix(q1_)
     F                                     rename(hirec:sequence)
     Fhaccpq2   uf   e           k disk    prefix(q2_)
     F                                     rename(hirec:pageseq)
     Fhaccpv1   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             20    dim(7) ctdata perrcd(1)
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
     D  $ppge#                44     48  0
     D  $ppgsq                49     50  0
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
     D  $litem                22     36
     D  $lcat                 19     28
     D  $latyp                19     19
     D  $lvalidate            20     20
     *
     D  $lcode                29     43
     D  $lseq#                44     48  0
     *
     D  $lgeneral             22     68
640bAD  $lcategory            19     68
     *
     D  $lfreq                19     19
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
     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D haccplog      e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

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
     D seqds           ds
     D  w1pgsq                 1      3  1
     D  wksqinsert             3      3  0
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
640aAD $cdlook         s                   like($llook)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D chkobjret       s              8
     D chkobjtype      s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D displayall      s               n
     D e               s              2  0
     D*enter           s              5  0
     D*error           s              1
     D*forever         s              1
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
     D validate        s              1
     D*warn            s              1
     D wkpgsq          s              2  0
     D*wksqinsert      s              1  0

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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
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
     C                   setoff                                       10
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
      * call validation maintenance if needed
      /free
        if validate = 'Y';
          exsr entervalues;
        endif;
      /end-free
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
     C*                  eval      enter = 0
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
     *  SUBROUTINE ENTERVALUES - Enter validation data
     *
     *    ENTERVALUES - For answer types that have validation entries
     *
     c     entervalues   begsr
     c                   eval      $lcmd  = ' '
     c                   eval      $lerm  = ' '
     c                   eval      $lmsg  = ' '
     c                   eval      $lwhse = hiwhse
     c                   eval      $llevl = hilevl
     c                   eval      $ltype = hitype
     c                   eval      $lcode = hicode
     c                   eval      $lseq# = hiseq#
     c                   call      'HV110'
     c                   parm                    $lparm
     c                   parm                    $lrtn
     c                   endsr
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
     C                   movea     desc          errmsg
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
     *   PIR2103  Invalid value entered.
     *
     C     zm2103        begsr
     C                   eval      #msgid = 'PIR2103'
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
     C                   if        $pcmd = '*ADD    '
     *
     *    Make sure level was entered.
     *
     C                   if        w1levl = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     c                   leavesr
     C                   endif
     *
     *    Make sure type was entered.
     *
     C                   if        w1type = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     c                   leavesr
     C                   endif
     *
     *    Validate type against HACCPQT
     *
     C                   if        w1type <> ' '  and *in41 = *on
     C*                            w1type <> savetype               or
     C*                            w1levl <> savelevl
     C                   eval      $ltype = w1type
     C                   eval      $llevl = w1levl
     C                   eval      $lwhse = $pwhse
     C                   eval      $lcmd = '*VERIFY '
     C                   call      'HB900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*PGMQ   '
     C                   eval      w1type = $ltype
     C                   eval      w1levl = $llevl
     C                   eval      w1typedesc = $ltypedesc
     c                   eval      *in41 = *off
     c                   if        w1typedesc = *blanks
     c                   eval      *in02 = *on
     c                   else
     c                   eval      *in03 = *on
     c                   endif
640aDc*                  if        $llook = *blanks
640aMc                   if        $cdlook = *blanks
     c                             and $lentry <> 'Y'
     c                   eval      *in42 = *on
     c                   eval      *in02 = *off
     c                   else
     c                   eval      *in42 = *off
     c                   endif
     c                   eval      displayall = *on
     c                   eval      savetype = w1type
     c                   eval      savelevl = w1levl

     c                   if        w1levl <> 'RCVI'
650bAc                             and w1levl <> 'REXI'
     c                   eval      *in43 = *on
     c                   else
     c                   eval      *in43 = *off
     c                   endif

650bDc*                  if        w1levl <> 'REXI'
650bDc*                  eval      *in43 = *on
650bDc*                  else
650bDc*                  eval      *in43 = *off
650bDc*                  endif

     c                   else
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm01
     c                   leavesr
     C                   endif
     C                   endif
     *
     *    Make sure code doesn't already exist.
     *    Only check here if w1pgsq is entered, otherwise a unique record
     *    will be created
     *
     c                   if        w1pgsq > 0
     C*                  eval      $plevl = w1levl
     C*                  eval      $ptype = w1type
     C*                  eval      $pcode = w1code
     C*                  eval      $ppge# = w1pge#
     C*                  eval      $ppgsq = w1pgsq
     C     pageseqky     chain     haccpq2                            79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm02
     C                   endif
     c                   endif
     C                   endif
     *
     *    Code must be entered if $cdlook is populated
     *
640aDC*                  if        $llook <> ' '  and
640aMC                   if        $cdlook <> ' '  and
     C                             w1code = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     c                   eval      errmsg = w1typedesc
     C                   exsr      zm03
     c                   leavesr
     c                   endif
     *
     *    Check code entry against validation program if it exist
     *
640aDC*                  if        $llook <> ' '  and
640aMC                   if        $cdlook <> ' '  and
     c                             w1code <> ' '
     c                   exsr      zzverify
     c                   if        error = *on
     c                   leavesr
     c                   endif
     C                   endif
     *
     *    Code must be entered if $lentry is populated
     *
     C                   if        $lentry = 'Y'  and
     C                             w1code = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     c                   eval      errmsg = w1typedesc
     C                   exsr      zm03
     c                   leavesr
     c                   endif
     *
     *    validate Question Frequency
     *
     C                   if        w1freq <> ' '
     C                   eval      $lfreq = w1freq
     c                   eval      $lvalidate = ' '
     C                   eval      $lcmd = '*VERIFY '
     C                   call      'HF900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*PGMQ   '
     C                   eval      w1freq = $lfreq
     C*                  eval      validate = $lvalidate
     C                   else
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     c                   endif
     c                   endif
     c
     C                   if        w1freq =  ' '
     C                   eval      $lfreq = ' '
     c                   eval      $lvalidate = ' '
     C                   eval      $lcmd = '*SELECT '
     C                   call      'HF900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*PGMQ   '  and
     C                             $lrtn <> '*CANCEL '
     C                   eval      w1freq = $lfreq
     C*                  eval      validate = $lvalidate
     C                   else
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     c                   endif
     c                   endif
     *
     *    validate the answer type
     *
     C                   if        w1atyp <> ' '
     C                   eval      $latyp = w1atyp
     c                   eval      $lvalidate = ' '
     C                   eval      $lcmd = '*VERIFY '
     C                   call      'HC900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*PGMQ   '
     C                   eval      w1atyp = $latyp
     C                   eval      validate = $lvalidate
     C                   else
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     c                   endif
     c                   endif
     c
     C                   if        w1atyp =  ' '
     C                   eval      $latyp = ' '
     c                   eval      $lvalidate = ' '
     C                   eval      $lcmd = '*SELECT '
     C                   call      'HC900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*PGMQ   '  and
     C                             $lrtn <> '*CANCEL '
     C                   eval      w1atyp = $latyp
     C                   eval      validate = $lvalidate
     C                   else
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     c                   endif
     c                   endif

     *
     *    Answer type cannot be changed while validation values exist.
     c
      /free
        if $pcmd <> '*ADD    ';
          if hiatyp <> w1atyp;
            chain (hiwhse: hiseq#) haccpv1;
            if %found(haccpv1);
              error = *on;
              *in24 = *on;
              *in04 = *on;
              exsr zm2103;
            endif;
          endif;
        endif;
      /end-free
     *
     *    validate Answer Required field.
     *
     C                   if        w1reqd <> 'N' and w1reqd <> 'Y'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     c                   eval      errmsg = desc(6)
     C                   exsr      zm03
     C                   endif
     c
     *
     *    validate Sample Question field.
     *
     C                   if        w1samp <> 'N' and w1samp <> 'Y'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     c                   eval      errmsg = desc(6)
     C                   exsr      zm03
     C                   endif
     c
     *
     *    validate validation table.
     *    valid only on answer type 4
     *
     C                   if        w1tabl <> ' ' and w1atyp <> '4'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     c                   eval      errmsg = desc(7)
     C                   exsr      zm1001
     C                   endif
     c
     C                   if        w1tabl = ' ' and w1atyp = '4'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     c                   eval      errmsg = desc(7)
     C                   exsr      zm1001
     C                   endif
     c
     C                   if        w1tabl <> ' ' and w1atyp = '4'
     c                   call      'CHKOBJCL'
     c                   parm                    w1tabl
     c                   parm      '*PGM'        chkobjtype
     c                   parm      ' '           chkobjret
     c                   if        chkobjret = 'ERROR'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     c                   eval      errmsg = desc(7)
     C                   exsr      zm1001
     C                   endif
     C                   endif
     c
     *
     *
     *    if page number is entered, only 10 questions can be on page
     *       check for number of questions on page
     *
     c                   if        w1pge# > 0 and $pcmd = '*ADD'
     c                   exsr      zzmaxpage
     c                   endif

     *
     *    if page sequence number is entered
     *       make sure seq# doesn't already exist on the page
     *       if page seq# entered is diff from what's in the file
     *       user is moving the question, will need to resequence all
     *       questions above this sequence nubmer as long as it will
     *       not create more than 10 questions per page
     *
     c                   eval      insert = *off
     c*                  move      w1pgsq        wksqinsert
     c                   eval      wkpgsq = w1pgsq
     c                   select
     c                   when      w1pgsq > 0 and wksqinsert = 0
     c                             and $pcmd = '*ADD'
     c                             or
     c                             w1pgsq > 0 and wksqinsert = 0
     c                             and $pcmd <> '*ADD'
     c                             and w1pgsq <> hipgsq
     c     pageseqky     chain(n)  haccpq2
     c                   if        %found(haccpq2)
     c                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     c                   eval      errmsg = desc(4)
     C                   exsr      zm0105
     c                   endif
      * this is a same page insert
     c                   when      w1pgsq > 0 and wksqinsert > 0
     c                             and w1pge# = hipge#
     c                   eval      insert = *on
      * this is a move to a different page and insert
     c                   when      w1pgsq > 0 and wksqinsert > 0
     c                             and w1pge# <> hipge#
     c                   exsr      zzmaxpage
     c                   eval      insert = *on
     c                   endsl
     c

     *
     *    Question must be entered
     *
     C                   if        w1qstn = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     c                   eval      errmsg = desc(2)
     C                   exsr      zm03
     c                   else
      * once the user has gotten this far I no longer need this field on
     c                   eval      displayall = '0'
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
     C                   select
     *
     *     Question Type.
     *
     C                   when      row# = 08 and $pcmd = '*ADD'
     C*                  eval      *in01 = *on
640aAc                   eval      $cdlook = ' '
     C                   eval      $lcmd = '*SELECT '
     C                   eval      $lwhse = $pwhse
     C                   call      'HB900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1type = $ltype
     C                   eval      w1levl = $llevl
     C                   eval      w1typedesc = $ltypedesc
     c                   eval      displayall = *on
     c                   eval      *in41 = *off
     c                   eval      *in02 = *on
     c                   eval      *in03 = *on
     c                   if        $llook = *blanks
     c                             and $lentry <> 'Y'
     c                   eval      *in42 = *on
     c                   eval      *in02 = *off
     c                   else
640aAc                   eval      $cdlook = $llook
     c                   eval      *in42 = *off
     c                   endif
     C                   endif
     c                   if        w1levl <> 'RCVI'
650bAc                             and w1levl <> 'REXI'
     c                   eval      *in43 = *on
     c                   else
     c                   eval      *in43 = *off
     c                   endif
650bDc*                  if        w1levl <> 'REXI'
650bDc*                  eval      *in43 = *on
650bDc*                  else
650bDc*                  eval      *in43 = *off
650bDc*                  endif
     *
     *     Question Frequency
     *
     C                   when      row# = 11
     C*                  eval      *in01 = *on
     C                   eval      $lcmd = '*SELECT '
     C                   eval      $lfreq = ' '
     c                   eval      $lvalidate = ' '
     C                   call      'HF900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1freq = $lfreq
     C*                  eval      validate = $lvalidate
     c                   eval      *in10 = *on
     c                   endif
      *this is temporary for testing
     c*                  leavesr
     *
     *     Answer Type.
     *
     C                   when      row# = 12
     C*                  eval      *in01 = *on
     C                   eval      $lcmd = '*SELECT '
     C                   eval      $latyp = ' '
     c                   eval      $lvalidate = ' '
     C                   call      'HC900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1atyp = $latyp
     C                   eval      validate = $lvalidate
     c                   eval      *in04 = *on
     c                   endif
      *this is temporary for testing
     c*                  leavesr
     *
     *     Code if lookup is loaded in haccpqt
     *
640aDC*                  when      row# = 09  and $llook <> ' '
640aMC                   when      row# = 09  and $cdlook <> ' '
     C*                  eval      *in01 = *on
     C                   eval      $lcmd = '*SELECT '
     C*                  eval      $lgeneral = ' '
640aDC*                  call      $llook
640aMC                   call      $cdlook
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
640bAc                   if        $cdlook = 'IC900'
640bAc                   eval      w1code = $lcategory
640bAc                   else
     C                   eval      w1code = $lgeneral
640bAc                   endif
     c                   eval      *in04 = *on
     c                   endif
      *this is temporary for testing
     c*                  leavesr
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C*                  exsr      zm9905
     C                   endsl
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
     C                   eval      w1type = *blanks
     C                   eval      w1levl = *blanks
     C                   eval      w1code = *blanks
     C                   eval      w1qstn = *blanks
     C                   eval      w1freq = '1'
     C                   eval      w1atyp = *blanks
     C                   eval      w1reqd = *blanks
     C                   eval      w1samp = 'N'
     C                   eval      w1tabl = *blanks
     C                   eval      w1typedesc = *blanks
     c                   eval      *in41 = *on
     c                   eval      displayall = *off
     c                   eval      savetype = ' '
     c                   eval      savelevl = ' '
     c                   eval      w1pge# = 0
     c                   eval      w1pgsq = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1type = hitype
     C                   eval      w1levl = hilevl
     C                   eval      w1code = hicode
     C                   eval      w1qstn = hiqstn
     C                   eval      w1atyp = hiatyp
     C                   eval      w1freq = hifreq
     C                   eval      w1reqd = hireqd
     C                   eval      w1samp = hisamp
     C                   eval      w1tabl = hitabl
     C                   eval      w1pge# = hipge#
     C                   eval      w1pgsq = hipgsq
      * get some additional data based on the question type
     C                   eval      $ltype = w1type
     C                   eval      $llevl = w1levl
     C                   eval      $lwhse = $pwhse
     C                   eval      $lcmd = '*VERIFY '
     C                   call      'HB900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*PGMQ   '
     C                   eval      w1typedesc = $ltypedesc
     c                   if        w1typedesc = *blanks
     c                   eval      *in02 = *on
     c                   else
     c                   eval      *in03 = *on
     c                   endif
640aDc*                  if        $llook = *blanks
640aMc                   if        $cdlook = *blanks
     c                             and $lentry <> 'Y'
     c                   eval      *in42 = *on
     c                   eval      *in02 = *off
     c                   else
     c                   eval      *in42 = *off
     c                   endif
     c                   endif

     c                   if        w1levl <> 'RCVI'
650bAc                             and w1levl <> 'REXI'
     c                   eval      *in43 = *on
     c                   else
     c                   eval      *in43 = *off
     c                   endif
650bDc*                  if        w1levl <> 'REXI'
650bDc*                  eval      *in43 = *on
650bDc*                  else
650bDc*                  eval      *in43 = *off
650bDc*                  endif
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
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $plevl
     C                   kfld                    $ptype
     C                   kfld                    $pcode
     *
     C     typeky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1levl
     C                   kfld                    w1type
     *
     C     partkyseq     klist
     C                   kfld                    $pwhse
     *
     *
     *  Define key for page/seq limit
     *
     C     pageky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1levl
     C                   kfld                    w1type
     C                   kfld                    w1code
     C                   kfld                    w1pge#
     *
     *  Define key for page/seq check
     *
     C     pageseqky     klist
     C                   kfld                    $pwhse
     C                   kfld                    w1levl
     C                   kfld                    w1type
     C                   kfld                    w1code
     C                   kfld                    w1pge#
     C                   kfld                    wkpgsq
     *
     *
     *  Define key for page/seq insert
     *
     C     Seqinsert     klist
     C                   kfld                    $pwhse
     C                   kfld                    w1levl
     C                   kfld                    w1type
     C                   kfld                    w1code
     C                   kfld                    w1pge#

     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pcode = *blanks
     C                   endif
     C                   if        $pcmd <> '*ADD    '
      * if haccplog records exist record only page information can
      * be change.
      /free
        exec sql select * into :haccplog
                 from haccplog
                 where hlwhse = :$pwhse
                 and hlseq# = :$pseq#;
        if sqlstt = sqlNoData;
          *in92 = *off;
        else;
          *in92 = *on;
        endif;
      /end-free
     c                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZMAXPAGE Edit for a maximum of 10 questions per page
     *
     C     zzmaxpage     begsr
     c                   eval      pageseqcnt = 0
     c     pageky        setll     haccpq2
     c                   dow       forever = forever
     c     pageky        reade(n)  haccpq2
     c                   if        %eof(haccpq2)
     c                   leave
     c                   endif
     c                   eval      pageseqcnt = pageseqcnt + 1
     c                   enddo
     c                   if        pageseqcnt > 9
     c                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     c                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     c                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  if add mode need to get next page sequence number
     *
     C                   if        $pcmd = '*ADD    '
     c                             and w1pgsq = 0
     c     pageky        setgt     haccpq2
     c     pageky        readpe(n) haccpq2
     c                   if        %eof(haccpq2)
     c                   eval      w1pgsq = 1
     c                   else
     c                   eval      w1pgsq = q2_hipgsq + 1
     c                   endif
     c                   endif
     *
     *  if add mode need to get next sequence
     *
     C                   if        $pcmd = '*ADD    '
     c     partkyseq     setgt     haccpq1
     c     partkyseq     readpe    haccpq1
     c                   if        %eof(haccpq1)
     c                   eval      hiseq# = 1
     c                   else
     c                   eval      hiseq# = q1_hiseq# + 1
     c                   endif
     c                   endif
     *
     *  if insert need to move seq# in file
     *
     C                   if        Insert = *on
      * have to release the record being updated
     C     *loval        setll     record
     c*                  unlock    record
     c
     c     Seqinsert     setgt     haccpq2
     c                   dow       forever = forever
     c     Seqinsert     readpe    haccpq2
     c                   if        %eof(haccpq2) and wksqinsert > 0
     c                   eval      wksqinsert = 0
     c                   eval      w1pgsq = w1pgsq + 1
      * now get that needs to be updated again
     c                   exsr      zzget1
     c                   leave
     c                   endif
     c                   if        q2_hipgsq > w1pgsq
     c                   eval      q2_hipgsq = q2_hipgsq + 1
     c                   update    pageseq
     c                   else
     c                   eval      wksqinsert = 0
     c                   eval      w1pgsq = w1pgsq + 1
      * have to release the last record
     C     *loval        setll     haccpq2
      * now get the record that needs to be updated again
     c                   exsr      zzget1
     c                   leave
     c                   endif
     c                   enddo
     c                   endif
     *
     *  Move screen fields to record fields
     *
     C                   eval      hiwhse = $pwhse
     C                   eval      hilevl = w1levl
     C                   eval      hitype = w1type
     C                   eval      hicode = w1code
     C                   eval      hiqstn = w1qstn
     C                   eval      hiatyp = w1atyp
     C                   eval      hifreq = w1freq
     C                   eval      hitabl = w1tabl
     C                   eval      hireqd = w1reqd
     C                   eval      hisamp = w1samp
     c                   eval      hipge# = w1pge#
     c                   eval      hipgsq = w1pgsq
      * load date/time values
     C*                  MOVE      '*CURCMD '    $cvdop
     c                   eval      $cvdop = '*CURCMD '
     C                   call      @CVTDT
     C                   parm                    $CVTDT
     c                   if        $pcmd = '*ADD'
     c                   eval      hiactive = '1'
     c                   eval      hiadate = $cvd8o
     C*                  Z-ADD     $CVD8O        HIADATE
     c*                  eval      hiadate  = #jobdt
     C                   time                    hiatime
     c                   eval      hiaddjusr = #user
     c                   eval      hicdate  = 0
     c                   eval      hictime  = 0
     c                   eval      hichgjusr = ' '
     c                   else
     c                   eval      hicdate = $cvd8O
     c*                  eval      hicdate  = #jobdt
     C                   time                    hictime
     c                   eval      hichgjusr = #user
     c                   endif
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
     c                   eval      $ptype = hitype
     c                   eval      $plevl = hilevl
     c                   eval      $pcode = hicode
     c                   eval      $ppge# = hipge#
     c                   eval      $ppgsq = hipgsq
     c                   eval      $pseq# = hiseq#
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZVERIFY Verify code entry
     *
     C     zzverify      begsr
     c                   select
     c                   when      w1type = 'CAT'
     C                   eval      $lcat  = w1code
     c                   other
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = w1code
     c                   endsl
     C                   eval      $lcmd = '*VERIFY '
640aDC*                  call      $llook
640aMC                   call      $cdlook
     C                   parm                    $lparm
     C                   if        $lrtn = '*OK     '
     c                   else
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     c                   eval      errmsg = w1typedesc
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
Valid Question Type
Question
Page# is full
Page seq# exist
Valid Answer Type
Answer Required
Validation Table
**
'H' not allowed at this time.
Only 'D' is allowed for an '@' code.
