      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OE142     Customer/Item Info Maintenance - change
     *  July 9, 2012
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 a*    07/09/12  GJA   6.40
     *      - Created.
640aA*    10/08/12  MLB   6.40  P#01088
     *      - Enh: Changed note expiration date to 8,0 from 6,0 in file
     *        CUSTNTS. Revised pgm to convert date to YYYYMMDD for file.
     *        Expiration date will be zero for unlimited or valid date.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
     Foe142fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fcustnts   uf a e           k disk
     F                                     rename(cnrec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             20    dim(6) ctdata perrcd(1)
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
     D  $pcust                22     32  0
     D  $pwhdp                33     37
     D  $pitem                38     52
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
640aDD* $cvdop                 1      8
640aDD* $cvdd6                 9     14  0
640aDD* $cvdd8                15     22  0
640aAD  $cvcmd                 1      8
640aAD  $cvprg                 9     18
640aAD  $cvd6i                19     24
640aAD  $cvd8i                25     32
640aAD  $cvd6o                33     38  0
640aAD  $cvd8o                39     46  0
640aAD  $cvsto                47     64
640aAD  $cvrtn                65     72
640aAD  $cverm                73    132
640aAD  $cvmsg                73     76
640aA*
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erval1                41     45
     D  erval2                46     50
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

     D whdept        e ds

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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D accept          s              1
     D chkobjret       s              8
     D chkobjtype      s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1

    AD currtimestamp   s               z
    A*----------------------------------------------------------------
    A*  Time variables
    A*----------------------------------------------------------------
    A
    AD CurrStamploc    s               z
    AD CurrStampsys    s               z
    AD CurrStampuc     s               z
    A
    AD bfcoffset       s              3  0 inz(0)
    A*----------------------------------------------------------------
    A* Function prototypes.
    A*----------------------------------------------------------------
    A
    A /copy qcopysrc,p.bfcdteti

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
     C                   setoff                                       0405
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
     *
     *  Screen 02 initialization
     *
     C     scr012        begsr
     C                   eval      nxtscr = '02 '
     C     end012        endsr
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
640aA*
640aA*    ZMQMSG  Add message record to subfile from program queue
640aA*
640aAC     zmqmsg        begsr
640aAC                   add       1             msgk
640aAC                   write     msgrec
640aAC                   endsr
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
     c                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     desc(3)       errmsg
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
     *   PIR2102  Invalid value for field 1 because of field 2 value.
     *
     C     zm2102        begsr
     C                   eval      #msgid = 'PIR2102'
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
     *    Make sure customer is entered.
     *
     c                   if        w1cust = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     c                   eval      errmsg = desc(3)
     C                   exsr      zm03
     C                   endif
     *
     c                   if        w1cust <> '*ALL'
     C                   monitor
     c                   eval      $pcust = %dec(w1cust:11:0)
     C                   on-error
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     c                   eval      errmsg = desc(3)
     C                   exsr      zm03
     C                   endmon
     C                   endif
     *
     *    Make sure Department is valid if entered
     *
      /free
        if w1whdp <> '*ALL ';
          if w1whdp <> ' ';
            exec sql select * into :whdept
                     from whdept
                     where wdwhse = :$pwhse
                     and wdcode = :w1whdp;
            if sqlstt = sqlNoData;
              error = *on;
              *in22 = *on;
              *in02 = *on;
              errmsg = desc(4);
              exsr zm1001;
            endif;
          endif;
        endif;
      /end-free
     *
     *    Make sure customer records doesn't already exist.
     *
     C                   monitor
     C                   eval      $pcust = %dec(w1cust:11:0)
     C                   on-error
     C                   eval      $pcust = 0
     C                   endmon
     *
     C                   eval      $pwhdp = w1whdp
     C                   eval      $pitem = w1item
640aDC*    fileky        chain     record                             79
640aMC     fileky        chain (n) record
640aDC*                  if        not *in79
640aMC                   if        %found(custnts)
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm02
     C                   endif
     *
     C                   endif
     *
     *    Make sure item number exist
     *
     C                   if        w1item = *blanks
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm01
     C                   endif
     *
     *    Make sure note is entered.
     *
     c                   if        w1note = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     c                   eval      errmsg = desc(5)
     C                   exsr      zm03
     C                   endif
     *
640aM*    Make sure date is entered is valid. Zero = unlimited
     *
     c                   if        w1expd = 0
640aAc                   eval      $cvd8o = 0
640aAc                   else
640aAC                   eval      $cvcmd = '*CMDMDY'
640aAC*                  eval      $cvd8i = %editc(w1expd: 'X')
640aAC                   eval      $cvd8i = %subst(%editc(w1expd: 'X'):5:4)
640aAC                             + %subst(%editc(w1expd: 'X'):1:4)
640aAC                   exsr      zzcvtdt
640aAc                   if        $cvrtn = '*PGMQ '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
640aDC*                  eval      errmsg = desc(6)
640aMC                   eval      #msgk = $cvmsg
640aDC*                  exsr      zm03
640aMC                   exsr      zmqmsg
     C                   endif
     *
640aAC                   endif
640aA*
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1cust = *blanks
     C                   eval      w1whdp = *blanks
     C                   eval      w1item = *blanks
     C                   eval      w1note = *blanks
640aDC*                  eval      w1expd = 999999
640aMC                   eval      w1expd = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   if        cncust = 0
     C                   eval      w1cust = '*ALL'
     C                   else
     C                   eval      w1cust = %char(cncust)
     C                   endif
     C                   eval      w1whdp = cnwhdp
     C                   eval      w1item = cnitem
     C                   eval      w1note = cnnote
640aA*
640aAC                   if        cnexpd = 0
     C                   eval      w1expd = cnexpd
640aA*
640aAC                   else
640aAC                   eval      $cvcmd = '*CMDMDY'
640aAC*                  eval      $cvd8i = %editc(cnexpd: 'X')
640aAC                   eval      w1expd = %dec(%subst(%editc(cnexpd: 'X'):5:4)
640aAC                             + %subst(%editc(cnexpd: 'X'):1:4):8:0)
640aAC*                  exsr      zzcvtdt
640aAC*                  eval      w1expd = $cvd6o
640aAC                   endif
640aA*
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
     C                   kfld                    $pcust
     C                   kfld                    $pwhdp
     C                   kfld                    $pitem
     C     fileky1       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pcust
     C                   kfld                    $pwhdp
640aAC                   eval      $cvprg = #prog
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
     C                   eval      $pcust = 0
     C                   endif
     C                   exsr      scr01i
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZCVTDT  Convert Date
640aA*
640aAC     zzcvtdt       begsr
640aA*
640aAC                   call      @cvtdt
640aAC                   parm                    $cvtdt
640aA*
640aAC                   endsr
640aA*
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      cnwhse = $pwhse
     C                   monitor
     C                   eval      cncust = %dec(w1cust:11:0)
     C                   on-error
     C                   eval      cncust = 0
     C                   endmon
     C                   eval      cnwhdp = w1whdp
     C                   eval      cnitem = w1item
     C                   eval      cnnote = w1note
640aDC*                  eval      cnexpd = w1expd
640aMC*                  eval      cnexpd = $cvd8o
640aAC                   eval      cnexpd = %dec(%subst(%editc(w1expd: 'X'):5:4)
640aAC                             + %subst(%editc(w1expd: 'X'):1:4):8:0)
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   time                    currtimestamp
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
     C                   eval      $pcust = cncust
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item Number
Description
Customer or *ALL
Department
Note
Date
**
'H' not allowed at this time.
Only 'D' is allowed for an '@' code.
