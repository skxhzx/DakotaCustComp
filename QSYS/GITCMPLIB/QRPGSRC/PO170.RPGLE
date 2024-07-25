     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  PO170     HACCP Information - Change
     *  25 October 1999
     *  Max Blacknik
     *
     *  Revisions
416 A*    09/30/02  MLB  4.16
     *      - Enh: Added support to program for *VIEW option.
     *        Added file POHHDR to pgm.
416aA*    11/07/02  MLB  4.16a
     *      - Fix: Revised ZZGET1 to retrieve HACCP record when
     *        program is called in *VIEWPO, *VIEWITM modes.
     *
500aA*    04/17/05  RH   5.00a
     *      - Fix: Add code that was missed in 416 update.
     *
500bA*    10/24/05  JCJ  5.00b
500bA*      - 1 Only allow HACCP entry (option 11) if item category
500bA*          requires it.
500bA*      - 2 If HACCP detailed forced and receiving an item
500bA*          (option1) HACCP detail record must exist
500bA*      - 3 If HACCP header forced and receiving an item
500bA*          (option1) HACCP header record must exist
500bA*      - 4 Is HACCP entry allowed for PO
     *
500cA*    10/31/05  DAS  5.00c
     *      - Converted to ILE
     *      - Add Clam fields to POHACCP file.
510aA*    11/16/06  RAH  5.10a
     *      - Enable SuperPO to utilize this program.  In INZ routine,
     *        check PO's within and if one doesn't have HACCP info,
     *        use that PO.  On update, loop through and put same
     *        HACCP information for each PO that doesn't have any.
510bA*    12/08/06  RH   5.10b
     *      - Fix: Allow HACCP info as optional if no rec in ITEMCAT
     *      - Enh: Add client code.
520aA*    04/17/08  DAS  5.20a
     *      - Fix: Revised routine ZZGET1E to use POKEY instead of
     *        ITMKY to get POHACCP record. RE: POKEY uses a zero seq#
     *        and blank item to get the header HACCP record.
640aA*    08/09/12  JCJ  6.40a
     *      - Enh: Added client specific logic
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
BIRa *    07/16/10  HNK  BIRa
     *      - Enh: Compile program for screen change.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
BIRaMFpo17001   cf   e             workstn
BIRaD *po170fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Fpohdr     if   e           k disk
416 AFpohhdr    if   e           k disk
500bAFpodtl     if   e           k disk
     Fpohaccp   uf a e           k disk
     F                                     rename(harec:record)
     Fwarehs    if   e           k disk
510aaFpospo     if   e           k disk
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
510bAD @getcl          c                   const('GETCLIENT')
510bAD*
510bA /COPY QCOPYSRC,ID#CITYLIN
BIRaA /copy qcopysrc,id#birite
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
510aAD pos             s              9    dim(99)
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
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
416 A*
416 AD  $phedt                31     38  0
     D  $pheti                39     44  0
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
     D  $litem                22     36
     *
     D  $lldcn                19     20
     D  $lprda                19     23
     D  $lprdt                19     23
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
500bAD  eritem                 1     15
     *
500bAD  erpo                   1      9
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500bA*
500bA* Get Category return status message
500bA*
     D nfound          c                   const('*NOTFOUND*')
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
     D $pwhsa          s              3
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
500dAD $pcode          s             10
     D blkitm          s                   like($pitem)
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
500bAD savitm          s             15
500bAD savseq          s              4  0
     D sclear          s              1
     D seq0            s                   like($pseq)
     D warn            s              1
500dAD $phhdr          s              1
500dAD $phdtl          s              1
500dAD $phcat          s              1
500dAD $phacp          s              1
510aaD hcmd            s                   like($pcmd)
510aaD #pos            s              2  0
510aaD x               s              2  0
510aaD $superpo        s                   like($ppo)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PO      - Capture HACCP info at purchase order lvl
     *              *ITEM    - Capture HACCP info at item number lvl
416 A*              *VIEWPO  - View HACCP info at purchase order lvl
416 A*              *VIEWITM - View HACCP info at item number lvl
     *      $PPRG   Program to send messages back to.
     *
     *    Returned Parameters
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
     C                   exsr      zzinz1
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
510ad*                  return
510aaC                   eval      *inlr = *on
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
640aAC                   select
640aAC                   when      client = birite
640aAC                   exfmt     screen1bir                           50
640aAC                   other
     C                   exfmt     screen1                              50
640aAC                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
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
416 D*R         $PCMD     IFEQ '*VIEW   '
416 MC                   if        $pcmd = '*VIEWPO '  or
416 AC                             $pcmd = '*VIEWITM'
     C                   eval      *in90 = *on
     C                   endif
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     *R         $PCMD     IFEQ '*ADD    '
     C                   if        $pcmd = '*PO     '  or
     *R         $PCMD     OREQ '*CHANGE '
     C                             $pcmd = '*ITEM   '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     *
510aac                   if        #pos > 0
510aac                   do        #pos          x
510aac                   move      pos(x)        $ppo
510aac                   exsr      zzupd1
510aac                   enddo
510aac                   else
     C                   exsr      zzupd1
510aac                   endif
     C     error         cabeq     '1'           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
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
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
500bA*----------------------------------------------------------------
500bA*     PO12001  HACCP INFO NOT ALLOWED FOR ITEM
500bA*
500bAC     zm1201        begsr
500bAC                   eval      #msgid = 'PO12001'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   movea     errmsg        $md(1)
500bAC                   exsr      zmsmsg
500bAC                   eval      $pmsg = #msgk
500bAC                   endsr
500bA*----------------------------------------------------------------
500bA*     PO12002  HACCP INFO MUST BE ENTERED BEFORE RECEIVING ITEM
500bA*
500bAC     zm1202        begsr
500bAC                   eval      #msgid = 'PO12002'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   movea     errmsg        $md(1)
500bAC                   exsr      zmsmsg
500bAC                   eval      $pmsg = #msgk
500bAC                   endsr
500bA*----------------------------------------------------------------
500bA*     PO12003  HACCP HEADER INFO MUST BE ENTERED BEFORE RECEIVING
500bA*              ITEM
500bA*
500bAC     zm1203        begsr
500bAC                   eval      #msgid = 'PO12003'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   movea     errmsg        $md(1)
500bAC                   exsr      zmsmsg
500bAC                   eval      $pmsg = #msgk
500bAC                   endsr
     *----------------------------------------------------------------
     *     PO11003  HACCP HEADER INFO NOT ALLOWED
     *
500bAC     zm1103        begsr
500bAC                   eval      #msgid = 'PO11003'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   movea     errmsg        $md(1)
500bAC                   exsr      zmsmsg
500bAC                   eval      $pmsg = #msgk
500bAC                   endsr
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify product area.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprda = w1prda
     C                   call      'PA900'
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
     *  Verify product type.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprdt = w1prdt
     C                   call      'PY900'
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
     *
     *  Verify load condition.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lldcn = w1ldcn
     C                   call      'LC900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
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
     *     Product area.
     *
     C                   when      row# = 12
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   call      'PA900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1prda = $lprda
     C                   endif
     *
     *     Product type.
     *
     C                   when      row# = 13
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   call      'PY900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1prdt = $lprdt
     C                   endif
     *
     *     Load condition.
     *
     C                   when      row# = 19
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   call      'LC900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1ldcn = $lldcn
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1est# = haest#
     C                   eval      w1tksl = hatksl
     C                   eval      w1prda = haprda
     C                   eval      w1prdt = haprdt
     *
     C                   eval      w1rsrq = harsrq
     C                   eval      w1rsdl = harsdl
     *
     C                   eval      w1ttrr = hattrr
     C                   eval      w1ttmd = hattmd
     C                   eval      w1ttns = hattns
     *
     C                   eval      w1ptrt = haptrt
     C                   eval      w1ptrm = haptrm
     C                   eval      w1ptrb = haptrb
     *
     C                   eval      w1ptmt = haptmt
     C                   eval      w1ptmm = haptmm
     C                   eval      w1ptmb = haptmb
     *
     C                   eval      w1ptnt = haptnt
     C                   eval      w1ptnm = haptnm
     C                   eval      w1ptnb = haptnb
     *
     C                   eval      w1ldcn = haldcn
     C                   eval      w1insp = hainsp
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   select
     C                   when      $pcmd = '*PO     '  or
416aAC                             $pcmd = '*VIEWPO '
     C     pokey         chain(n)  record                             7978
     *
     C                   when      $pcmd = '*ITEM   '  or
500aD *R                           $pcmd = '*VIEWPO '
500aMC                             $pcmd = '*VIEWITM'
     C     itmky         chain(n)  record                             7978
     *
     *    If an HACCP record is not found for the item, then
     *    check if a HACCP record is found for the PO and
     *    use its values.
     *
     C                   if        *in79
     C     pokey         chain(n)  record                             7978
     C                   endif
     C                   endsl
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C     *nokey        clear                   record
     *R                   MOVE *ON       ERROR
     *R                   MOVE '*PGMQ   '$PRTN
     *R                   EXSR ZM73
     *R                   GOTO ENDGT1
     C                   endif
500bA*
500bA*  If *ITEM option processing, check to see if P.O. HACCP detail
500bA*  is allowed for item selected.
500bA*
500bAC                   if        $pcmd = '*ITEM   '
500bAC                   exsr      zzget1b
500bAC                   goto      endgt1
500bAC                   endif
500bA*
500bA*  If *DTLCHK option processing for PO110A / PO110B check to see if
500bA*  user is allowed to enter HACCP Header information.
500bA*
500bAC                   if        $pcmd = '*DTLCHK '
500bAC                   if        $pprg = 'PO110A  ' or $pprg = 'PO110B  '
500bAC                   exsr      zzget1c
500bAC                   goto      endgt1
500bAC                   endif
500bAC                   endif
500bA*
500bA*  If *DTLCHK option processing, check 1st to see if HACCP
500bA*  Allowed, then check to see if HACCP detail forced / entered.
500bA*
500bAC                   if        $pcmd = '*DTLCHK '
500bAC                   exsr      zzget1d
500bAC                   if        errmsg = *blanks
500bA* HACCP header forced?
500bAC                   exsr      zzget1e
500bAC                   endif
500bAC                   endif
500bA*
500bAC     endgt1        endsr

500bA*-------------------------------------------------------------------
500bA*  ZZGET1b  Only allow HACCP entry if the item's category allows it
500bA*
500bAC     zzget1b       begsr
500bA*
500bAC                   eval      $pwhsa = *blanks
500bAC                   move      $pwhse        $pwhsa
500bA* Get HACCP flags
500bAC                   exsr      zzget6
500bA*
510bDC*                  if        $pcode = nfound or
510bDC*                            $phdtl = '1'
510bMC                   if        $phdtl = '1'
500bAC                   eval      error = *on
500bAC                   eval      $prtn = '*PGMQ   '
500bAC                   eval      errmsg = *blanks
500bAC                   eval      eritem = $pitem
500bAC                   exsr      zm1201
500bAC                   endif
500bA*
500bAC                   endsr
500bA*----------------------------------------------------------------
500bA*  ZZGET1c check HACCP flags for item's to see if header entry
500bA*          allowed.
500bA*
500bAC     zzget1c       begsr
500bA*
500bAC                   eval      errmsg = *blanks
500bAC                   eval      $pwhsa = *blanks
500bAC                   move      $pwhse        $pwhsa
500bAC                   eval      $prtn = '*PGMQ   '
500bA*
500bAC                   eval      savitm = $pitem
500bAC     phkey         setll     podtl
500bAC                   dou       *in99
500bAC     phkey         reade     podtl                                  99
500bAC                   if        not *in99
500bAC                   eval      $pitem = pditem
500bA* Get HACCP flags
500bAC                   exsr      zzget6
500bAC                   if        $phhdr = '2' or $phhdr = '3'
500bAC                   eval      $prtn = '*OK     '
500bAC                   leave
500bAC                   endif
500bAC                   endif
500bAC                   enddo
500bA*
500bAC                   if        $prtn = '*PGMQ   '
500bAC                   eval      errmsg = *blanks
500bAC                   eval      erpo = $ppo
500bAC                   exsr      zm1103
500bAC                   endif
500bA*
500bAC                   eval      $pitem = savitm
500bAC                   eval      error = *on
500bA*
500bAC                   endsr
500bA*----------------------------------------------------------------
500bA*  ZZGET1d - HACCP Receiving edits.
500bA*            1) HACCP detail not allowed, or optional, no error.
500bA*            2) HACCP detail forced, HACCP deatil exists, no error.
500bA*            3) HACCP detail forced, HACCP detail not found, error.
500bA*
500bAC     zzget1d       begsr
500bA*
500bAC                   eval      errmsg = *blanks
500bAC                   eval      $pwhsa = *blanks
500bAC                   move      $pwhse        $pwhsa
500bA*
500bA* Get HACCP flags
500bAC                   exsr      zzget6
500bA* 1)
500bAC                   if        $phdtl = '1' or $phdtl = '2'
500bAC                                          or $pcode = nfound
500bAC                   eval      $prtn = '*OK     '
500bAC                   endif
500bA* 3)
500bAC                   if        $phdtl = '3'
500bAC     itmky         chain     record                             7978
500bAC                   if        *in79
500bAC                   eval      $prtn = '*PGMQ   '
500bAC                   eval      errmsg = *blanks
500bAC                   eval      eritem = $pitem
500bAC                   exsr      zm1202
500bAC                   else
500bA* 2)
500bAC                   eval      $prtn = '*OK     '
500bAC                   endif
500bAC                   endif
500bAC                   eval      error = *on
500bA*
500bAC                   endsr
500bA*----------------------------------------------------------------
500bA*  ZZGET1e - Check HACCP header flag for all item's in po.  If
500bA*            header forced does the record exist.
500bA*
500bAC     zzget1e       begsr
500bA*
500bAC                   eval      errmsg = *blanks
500bAC                   eval      $pwhsa = *blanks
500bAC                   move      $pwhse        $pwhsa
500bAC                   eval      $prtn = '*OK     '
500bAC                   eval      savitm = $pitem
500bAC                   eval      savseq = $pseq
500bA*
500bAC     phkey         setll     podtl
500bAC                   dou       *in99
500bAC     phkey         reade     podtl                                  99
500bAC                   if        not *in99
500bAC                   eval      $pitem = pditem
500bAC                   eval      $pseq  = pdseq
500bA* Get HACCP flags
500bAC                   exsr      zzget6
500bAC                   if        $phhdr = '3'
520aDC**   itmky         chain     record                             7978
520aMC     pokey         chain     record                             7978
500bAC                   if        *in79
500bAC                   eval      $prtn = '*PGMQ   '
500bAC                   leave
500bAC                   endif
500bAC                   endif
500bAC                   endif
500bAC                   enddo
500bA*
500bAC                   if        $prtn = '*PGMQ   '
500bAC                   eval      errmsg = *blanks
500bAC                   eval      eritem = $pitem
500bAC                   exsr      zm1203
500bAC                   endif
500bA*
500bAC                   eval      $pitem = savitm
500bAC                   eval      $pseq = savseq
500bAC                   eval      error = *on
500bA*
500bAC                   endsr
500bA*----------------------------------------------------------------
500bA*  ZZGET6   Get item category for HACCP edits
500bA*
500bAC     zzget6        begsr
500bA*
500bAC                   call      'GETICAT'
500bAC                   parm                    $pwhsa
500bAC                   parm                    $pitem
500bAC                   parm                    $pcode
500bAC                   parm                    $phhdr
500bAC                   parm                    $phdtl
500bAC                   parm                    $phcat
500bA*
500bAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bA*
     *
     *  Define key for main file.
     *
     C     pokey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    seq0
     C                   kfld                    blkitm
     *
     *  Define key for main file.
     *
     C     itmky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Define key for PIRITEM file.
     *
     C     ittkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
416 A*
416 A*  Define key for POHDR file.
416 A*
416 AC     phhky         klist
416 AC                   kfld                    $pwhse
416 AC                   kfld                    $ppo
416 AC                   kfld                    $phedt
416 AC                   kfld                    $pheti
     *
     *  Define key for POSPO file.
     *
510aaC     spokey        klist
510aaC                   kfld                    $pwhse
510aaC                   kfld                    $superpo
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     C     zzinz1        begsr
     *
     C                   eval      forevr = *off
     *
     *   If SuperPO, check if any attached PO's are valid for HACCP
     *
510aac                   if        $pprg = 'PO110A  ' or $pprg = 'PO110B  '
510aac                   eval      $superpo = $ppo
510aac                   eval      hcmd = $pcmd
510aac                   eval      $pcmd = '*DTLCHK   '
510aac                   eval      #pos = 0
510aac     spokey        setll     pospo
510aac     spokey        reade     pospo
510aac                   dou       %eof
510aac                   eval      $ppo = pupo
510aac                   exsr      zzget1c
510aac                   if        $prtn = '*OK     '
510aac                   eval      #pos = #pos + 1
510aac                   move      $ppo          pos(#pos)
510aac                   endif
510aac     spokey        reade     pospo
510aac                   enddo
510aac                   eval      $pcmd = hcmd
510aac                   if        #pos > 0
510aac                   eval      #pos = #pos + 1
510aac                   move      $superpo      pos(#pos)
510aac                   if        $pcmd = '*PO      '
510aac                   eval      $ppo = $superpo
510aac                   else
510aac                   eval      $ppo = pos(1)
510aac                   endif
510aac                   eval      error = *off
510aac                   else
510aac                   eval      $ppo = $superpo
510aac                   eval      error = *off
510aac                   endif
510aac                   endif
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Get vendor name.
     *
416 AC                   select
416 AC                   when      $pcmd = '*PO     '  or
416 AC                             $pcmd = '*ITEM   '
     C     phkey         chain     pohdr                              79
     C                   if        *in79
     C                   eval      phvnam = *blanks
     C                   endif
416 A*
416 AC                   when      $pcmd = '*VIEWPO '
416 AC     phhky         chain     pohhdr                             79
416 AC                   if        *in79
416 AC                   eval      phhvna = *blanks
416 AC                   endif
416 AC                   endsl
     *
     *   Get item description to display.
     *
     C                   select
     C                   when      $pcmd = '*PO     '  or
416 AC                             $pcmd = '*VIEWPO '
     C                   eval      w1item = 'N/A'
     C                   eval      wodesc = *blanks
416 A*
416 AC                   if        $pcmd = '*VIEWPO '
416 AC                   eval      phvnam = phhvna
416 AC                   endif
     *
     C                   when      $pcmd = '*ITEM   '  or
416 AC                             $pcmd = '*VIEWITM'
     C                   eval      w1item = $pitem
     C     ittkey        chain     piritem                            75
     C                   if        *in75
     C                   eval      wodesc = *blanks
     C                   else
     C                   eval      wodesc = %trimr(itpdsc) + ' ' + itdesc
     C                   endif
     C                   endsl
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Get record from main file.
     *
     C                   select
     C                   when      $pcmd = '*PO     '
     C     pokey         chain     record                             7978
     *
     C                   when      $pcmd = '*ITEM   '
     C     itmky         chain     record                             7978
     C                   endsl
     *
     *  Move screen fields to record fields
     *
     C                   eval      hawhse = $pwhse
     C                   eval      hapo = $ppo
     C                   eval      haseq = $pseq
     C                   eval      haitem = $pitem
     *
     C                   eval      haest# = w1est#
     C                   eval      hatksl = w1tksl
     C                   eval      haprda = w1prda
     C                   eval      haprdt = w1prdt
     *
     C                   eval      harsrq = w1rsrq
     C                   eval      harsdl = w1rsdl
     *
     C                   eval      hattrr = w1ttrr
     C                   eval      hattmd = w1ttmd
     C                   eval      hattns = w1ttns
     *
     C                   eval      haptrt = w1ptrt
     C                   eval      haptrm = w1ptrm
     C                   eval      haptrb = w1ptrb
     *
     C                   eval      haptmt = w1ptmt
     C                   eval      haptmm = w1ptmm
     C                   eval      haptmb = w1ptmb
     *
     C                   eval      haptnt = w1ptnt
     C                   eval      haptnm = w1ptnm
     C                   eval      haptnb = w1ptnb
     *
     C                   eval      haldcn = w1ldcn
     C                   eval      hainsp = w1insp
     *
     *   Add record
     *
     C                   if        *in79
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     *
     C                   else
     *
     *   -OR- Update record
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
     *R                   Z-ADDPDSEQ     $PSEQ
     *R                   MOVE PDITEM    $PITEM
     C     endupd        endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
