     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  EQ522     Equipment Work Order Detail - Change
     *  02 July, 2003
     *  Roxanne Harrison
     *
     *  Revisions
     *
416 A*    07/02/03  RH   4.17
     *      - Created.      Using DH122
417aA*    02/18/04  RH   4.17a
     *      - Change PRTKY for EQUIPA1 file to include I/O field.
     *        Was reading other (I/O) work order for trans # & not marking
     *        completed work order as complete.
     *        Trans can have one work order for I and one for O.
     *      - Remove RESET for screen1, this resets the values to
     *        the what they were at the end of *INZSR.  Was resetting
     *        key $pwrk#, not sure why this was originally used.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  41        CONDITION DISPLAY OF DOCK DOOR OVERFLOW INFO
     *  42        CONDITION DISPLAY OF DOOR SKIP REASON INFO
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Feq522fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fequipr    uf a e           k disk
     F                                     rename(errec:record)
     Fequipa1   uf   e           k disk
     Fequipw    uf   e           k disk
     Fpiruser1  if   e           k disk
     Foptions   if   e           k disk
     Fwarehs    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
     D desc            s             20    dim(2) ctdata perrcd(1)
     D dmxsts          s             30    dim(4) ctdata perrcd(1)


     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
     D  $ptrn#                22     28  0
     D  $pio                  29     29
     D  $pseq#                30     34  0
     D  $pwrk#                35     41  0
     D* $pemp                 33     37  0
     D* $psdte                38     45  0
     D* $pstim                46     51  0
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $ldoor                27     29  0
     *
     D  $lhdte                22     29  0
     D  $lhtim                30     35  0
     *
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D drasn           s              4    inz('    ')
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D fillscreen      s              3
     D forevr          s               n
     D help            s              5  0
     D                                     inz(*hival)
     D msgk            s              4  0
     D nxtscr          s              3
     D rem             s              3  0 inz(0)
     D result          s              3  0 inz(0)
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D CurrStamp       s               z

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     *
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

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

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
 1E  C                   endif

 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     DSPSCR        BEGSR
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif
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
     C                   ENDSR

     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     SCR01I        BEGSR
     *
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   exsr      zzgetq
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
     *
     C     end01i        ENDSR

     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------
     *
     C     SC1           BEGSR
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
goto C                   goto      endsc1
 1E  C                   endif
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
 1E  C                   endif
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
     *
     C     endsc1        ENDSR

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *INZSR        BEGSR
     C*
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '0'           *IN91
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        TODAY             8 0
     C*
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
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *
     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------
     *
     C     ZMCMSG        BEGSR
     *
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     ZMDMSG        BEGSR
     *
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     ZMIMSG        BEGSR
     *
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

     C     ZMPMSG        BEGSR
     *
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

     C     ZMQMSG        BEGSR
     *
     C                   add       1             msgk
     C                   write     msgrec
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     ZSCLR         BEGSR
     *
     C                   write     clrscr
     C                   eval      sclear = *on
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     ZMSMSG        BEGSR
     *
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf  = *blanks
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *----------------------------------------------------------------

     C     ZM01          BEGSR
     *
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *----------------------------------------------------------------

     C     ZM02          BEGSR
     *
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *----------------------------------------------------------------

     C     ZM71          BEGSR
     *
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *----------------------------------------------------------------

     C     ZM72          BEGSR
     *
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *----------------------------------------------------------------

     C     zm73          BEGSR
     *
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *----------------------------------------------------------------

     C     ZM74          BEGSR
     *
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     ZM1001        BEGSR
     *
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     ZM9905        BEGSR
     *
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     ZZCHK1        BEGSR
     *
     C                   eval      error = *off

     *  When adding ....

     C                   if        $pcmd = '*ADD    '

     *    Make sure emp# was entered.

     C                   if        w1emp# = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   movel     desc(1)       erfld
     C                   exsr      zm01
     C                   goto      endck1
     C                   endif
     *
     *  verify employee number
     C     w1emp#        chain     piruser1                           79
     C                   if        *in79 = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif

     *
     *  verify Check Complete Y/N
     C                   if        w1cmpl <> 'Y' and w1cmpl <> 'N'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     *
     *
     C                   endif
     *
     C     endck1        ENDSR

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     ZZCMD1        BEGSR
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
 2B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
 3B  C                   select
     *
     *
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
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm1        ENDSR

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     ZZDFT1        BEGSR
     *
     C                   eval      w1emp# = *zeros
     C                   eval      w1memo = *blanks
     C                   eval      w1cmpl = 'N'
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     ZZFIL1        BEGSR
     *
     C                   eval      w1emp# = eremp#
     C                   eval      w1memo = ermemo
     C                   eval      w1cmpl = ercmpl
417a C                   eval      wOwrk# = $pwrk#
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     ZZGET1        BEGSR
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain(n)  record                             7978
     C                   endif
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
     *  Note: For this program, this is ok if rcd not found.
     *        Means that dock door has not been assigned yet.
     *
     C                   if        *in79
     C     *nokey        clear                   record
     C*                  eval      error = *on
     C*                  eval      $prtn = '*PGMQ   '
     C*                  exsr      zm73
     C*                  goto      endgt2
     C                   endif
     *
     C     endgt2        ENDSR

     *----------------------------------------------------------------
     *  ZZGETQ   Get Question for screen 1.
     *----------------------------------------------------------------

     C     ZZGETQ        BEGSR
     *
     * get question and answer
     C     keyea         chain(n)  equipa1                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   eval      w1qstn = *blanks
     C                   eval      w1ansr = *blanks
     C                   else
     C                   eval      w1qstn = eaqstn
     C                   eval      w1ansr = eaansr
     C                   endif
     *
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     ZZINZ         BEGSR
     *
     *  Define key for main file partial
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#
     C                   kfld                    $pio
     C                   kfld                    $pseq#
     *
     *
     *  Define key for EQUIPA1 file - Full key.
     *
     C     keyea         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#
     C                   kfld                    $pio
     C                   kfld                    $pseq#
     *
     *
     *  Define key for EQUIPA1 file - Partial key.
     *
     C     prtky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#
417a C                   kfld                    $pio
     *
     C     wkkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwrk#
     *
     C                   eval      forevr = *on
     C                   eval      $lprg = #prog
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     ZZINZ2        BEGSR
     *
417a C**                 reset                   screen1
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   exsr      scr01i
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCVTDT  Convert date.
     *----------------------------------------------------------------

     C     ZZCVTDT       BEGSR
     *
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C*                  eval      dmadte = $cvd8o
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     ZZUPD         BEGSR
     *
     C                   eval      error = *off
     *
     *
     *    write repair
416aAC                   time                    currstamp
     C                   eval      erwhse = $pwhse
     C                   eval      ertrn# = $ptrn#
     C                   eval      erio = $pio
     C                   eval      erseq# = $pseq#
     C                   eval      eremp# = w1emp#
     C                   eval      erwrk# = $pwrk#
     C                   eval      ermemo = w1memo
     C                   eval      ercmpl = w1cmpl
     C                   if        w1cmpl = 'Y'
     C                   eval      erstat = '4'
     C                   else
     C                   eval      erstat = '2'
     C                   endif
     C                   eval      ersdte = currstamp
     C                   write     record
     *
     *    If repair is complete, set status to 4 for records in EQUIPR
     *    for the trans/IO/seq#. Will close any "started" work.
     C                   if        w1cmpl = 'Y'
     C     fileky        setll     record
     C     nxtr          tag
     C     fileky        reade     record                                 79
     C                   if        *in79 = *off
     C                   if        erstat<'4'
     C                   eval      erstat = '4'
     C                   update    record
     C                   endif
     C                   goto      nxtr
     C                   endif
     *    Set status to 4 for Equipa file (question/answer)
     C     keyea         chain     equipa1                            79
     C                   if        *in79 = *off
     C                   eval      eastat = '4'
     C                   eval      easdts = currstamp
     C                   update    earec
     C                   endif
     *    Write complete date for EQUIPW  (work order)
     *    if no open records exists for work order in EQUIPA
     C                   move      *off          opnflg            1
     C                   eval      opnflg = *off
     C     prtky         setll     equipa1
     C     nxta          tag
     C     prtky         reade     equipa1                                79
     C                   if        *in79 = *off
417a C**                 if        eastat<>'4' and eaexcp='1'
417aMC                   if        eastat='1' and eaexcp='1'
     C                   eval      opnflg = *on
     C                   else
     C                   goto      nxta
     C                   endif
     C                   endif
     C                   if        opnflg = *off
     C     wkkey         chain     equipw                             79
     C                   if        *in79 = *off
     C                   eval      ewcdte = today
     C                   update    ewrec
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C     endupd        ENDSR

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
Employee #
Complete, must be Y/N
** Dock matrix status
Open
Assigned
Skipped
Inactive
