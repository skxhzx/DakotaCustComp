     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     Hoption(*srcstmt : *nodebugio)

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  RC200E    Putaway question - Was slot empty?
     *  16 February 2004
     *  Dave Sommerville
     *
     *  Revisions:
     *
417 A*    02/16/04  DAS 4.17
     *      - Created.
     *
417aA*    03/01/04  DAS 4.17a
     *      - Revised to set task base on program name.
     *
510aA*    03/14/07  DAS  5.10a
     *      - Added client code.
     *
     *----------------------------------------------------------------
     * Packers Custom Revisions
     *
PACaA*    03/14/07  DAS  PACa
     *      - Revised to write exception instead of adjusting slot.
     *
PACbA*    05/17/07  TJ   PACb
     *      - Modified to create exception record when answer to
     *        'Slot Phys Empty' = 'Y' and the slot is occupied.
     *        Change entry parm list.
     *
PACcA*    01/10/08  JCJ  PACc
     *      - Revised to write exception if slot status is <> 'Z'.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frc200efm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
416aAFitmexcp   o    e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)
     D slotds        e ds                  extname(slot)

510aA*----------------------------------------------------------------
510aA*  Client Data Structure
510aA*----------------------------------------------------------------

510aA /COPY QCOPYSRC,ID#PACKERS

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D refrsh          s               n
     D sclear          s              1
     D warn            s               n
     D zmsflag         s               n
     D flagerrors      s               n
     D forever         s               n
     D #basewhdp       s                   like($slwhdp)
     D #baseaisl       s                   like($slaisl)
     D #baseloc        s                   like($slloc)
     D #baserlvl       s                   like($slrlvl)

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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
     D  $pqty1                54     58  0
     D  $pqty2                59     61  0
     D  $pqty3                62     64  0
PACbAD  $pstat                65     66

     *----------------------------------------------------------------
     *  Date parameters
     *----------------------------------------------------------------

     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  eridsg                 1      5
     D  ersdsg                 6     10
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
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
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
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
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
     *
     C     dspscr        begsr
     C                   write     clrscr
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
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   exfmt     screen61                             50
 2X  C                   other
     C                   exfmt     screen1                              50
 2E  C                   endsl
 1E  C                   endif
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
     C                   move      '01 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil1
 2E  C                   endif
     C                   eval      refrsh = *off
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
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr01i
 2E  C                   endif
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     C                   move      *off          refrsh
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
510aA
510aA* Get client id.
510aA
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
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
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16ctl
 1X  C                   other
     C                   write     msgctl
 1E  C                   endsl
     C                   eval      msgk = *zeros
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16clr
 1X  C                   other
     C                   write     msgclr
 1E  C                   endsl
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16ctl
 2X  C                   other
     C                   write     msgctl
 2E  C                   endsl
     C                   eval      msgk = *zeros
 1E  C                   endif
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
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16rec
 2X  C                   other
     C                   write     msgrec
 2E  C                   endsl
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16rec
 1X  C                   other
     C                   write     msgrec
 1E  C                   endsl
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105s Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.

     C     zzchk1        begsr
     C                   eval      error = *off

     *   Verify option

PP  CC                   if        w1opt <> 'Y' and w1opt <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Option'
     C                   exsr      zm1001
 1E  C                   endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *      F10 - Exception.
     *
 1B  C                   if        *inkj
     C                   move      *on           cmdtkn
416aACSR                 Z-ADD     $PWHSE        EXWHSE
416aACSR                 MOVE      $PWHDP        EXWHDP
4164MCSR                 MOVE      $PITEM        EXITEM
416aACSR                 MOVE      $PDISP        EXFDIS
416aACSR                 MOVE      *BLANKS       EXTDIS
417aACSR                 select
417aACSR                 when      $pprg = 'IT252'
417aACSR                 MOVE      'TFREMP'      EXTASK
417aACSR                 when      $pprg = 'RTS110'
417aACSR                 MOVE      'RTSEMP'      EXTASK
417aACSR                 other
416uMCSR                 MOVE      'PUTEMP'      EXTASK
417aACSR                 endsl
416aACSR                 MOVE      'RC200E '     EXERID
416aACSR                 MOVE      '*CURCMD '    $CVCMD
416aACSR                 CALL      'CVTDTE'
416aACSR                 PARM                    $CVTDT
416aACSR                 Z-ADD     $CVD8O        EXGDTE
416aACSR                 TIME                    EXGTIM
416aACSR                 MOVE      #USER         EXGBY
416aACSR                 MOVE      '1 '          EXESTA
416aACSR                 WRITE     EXREC
     C                   eval      nxtscr = 'EOJ'
 1E  C                   endif
     *
     C     endcm1        endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1opt = ' '
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
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     *   Select first screen to display.
     *
     C                   move      *on           refrsh
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off

     *  If slot is not empty, then just get out.
416jA
416jAC                   if        w1opt = 'N'
     C                   eval      nxtscr = 'EOJ'
416jAC                   goto      endup1
416jAC                   endif
PACaA
PACaA*  For Packers, create an exception instead of adjustments
PACaA*    (Code copied from ZZCMD F10)
PACaA
PACaAC                   if        Client = packers
PACbAC                             and W1OPT = 'Y'
PACcD ***                          and $PSTAT = 'A'
PACcMC                             and $PSTAT <> 'Z'
PACbAC                             and $PITEM <> *BLANKS
PACaAC                   Z-ADD     $PWHSE        EXWHSE
PACaAC                   MOVE      $PWHDP        EXWHDP
PACaAC                   MOVE      $PITEM        EXITEM
PACaAC                   MOVE      $PDISP        EXFDIS
PACaAC                   MOVE      *BLANKS       EXTDIS
PACaAC                   select
PACaAC                   when      $pprg = 'IT252'
PACaAC                   MOVE      'TFREMP'      EXTASK
PACaAC                   when      $pprg = 'RTS110'
PACaAC                   MOVE      'RTSEMP'      EXTASK
PACaAC                   other
PACaAC                   MOVE      'PUTEMP'      EXTASK
PACaAC                   endsl
PACaAC                   MOVE      'RC200E '     EXERID
PACaAC                   MOVE      '*CURCMD '    $CVCMD
PACaAC                   CALL      'CVTDTE'
PACaAC                   PARM                    $CVTDT
PACaAC                   Z-ADD     $CVD8O        EXGDTE
PACaAC                   TIME                    EXGTIM
PACaAC                   MOVE      #USER         EXGBY
PACaAC                   MOVE      '1 '          EXESTA
PACaAC                   WRITE     EXREC
PACAaC                   eval      nxtscr = 'EOJ'
PACAAC                   goto      endup1
PACaAC                   endif

     *  Get putaway slot information.
416jA
416jAC                   eval      savever# = $slver#
416jAC                   clear                   $slot
416jAC                   eval      $slver# = savever#
416jA
416jAC                   eval      $dricommand = '*SLOT'
416jAC                   eval      $drisubcmd  = '%GET'
416jA
416jAC                   eval      $slwhseu = *on
416jAC                   eval      $slwhse = $pwhse
416jAC                   eval      $slwhdpu = *on
416jAC                   eval      $slwhdp = $pwhdp
416jAC                   eval      $sldispu = *on
416jAC                   eval      $sldisp = $pdisp
416jAC                   eval      flagerrors = *on
416jAC                   exsr      zzzdricop
416jAC     error         cabeq     *on           endup1

     *  Get base slot information.
416jA
416jAC                   if        $sacdsp <> $sldisp
416jAC                   eval      $sldispu = *on
416jAC                   eval      $sldisp = $sacdsp
416jAC                   eval      flagerrors = *on
416jAC                   exsr      zzzdricop
416jAC     error         cabeq     *on           endup1
416jAC                   endif

416jAC                   eval      #basewhdp = $slwhdp
416jAC                   eval      #baseaisl = $slaisl
416jAC                   eval      #baseloc  = $slloc
416jAC                   eval      #baserlvl = $slrlvl

     *  Remove item from base slot.
416jA
416jAC                   exsr      zzzadjust

     *  Loop through slots associated with base slot.
416jA
416jAC                   eval      $slaislu = *on
416jAC                   eval      $sllocu  = *on
416jAC                   eval      $slrlvlu = *on
416jAC                   eval      $slhandu = *on
416jA
416jAC                   dow       forever = forever
416jA
416jAC                   eval      $drisubcmd  = '%NXTSLOTI'
416jAC                   eval      flagerrors = *on
416jAC                   exsr      zzzdricop
416jAC                   if        error
416jAC                             or $drireturn = 'EOF'
416jAC                             or $slwhdp <> #basewhdp
416jAC                             or $slaisl <> #baseaisl
416jAC                             or $slloc  <> #baseloc
416jAC                             or $slrlvl <> #baserlvl
416jAC                   leave
416jAC                   endif
416jAC                   exsr      zzzadjust
416jAC                   enddo

     C                   eval      nxtscr = 'EOJ'

     C     endup1        endsr

     *----------------------------------------------------------------
     *  zzzadjust  Adjust out quantity in slot.
     *----------------------------------------------------------------

     C     zzzadjust     begsr
     C                   eval      error = *off
416jA
     *  If slot is Verified, get out.

     C                   if        $slstat = 'V'
     C                   goto      endadjust
     C                   endif
416jA
     *  If slot is Zero, then Zero Verify it.

     C                   if        $slstat = 'Z'
416jAC                   eval      $drisubcmd  = '%ZEROVFY'
416jAC                   exsr      zzzdricop
     C                   goto      endadjust
     C                   endif
416jA
     *  Initialize adjustment values.

416jAC                   eval      $saitemu = *on
416jAC                   eval      $saitem = $slitem
416jAC                   eval      $sacodeu = *on
416jAC                   eval      $sacode = 'ZZ'
416jAC                   eval      $sabyu   = *on
416jAC                   eval      $saby   = #USER
416jAC                   eval      $samemou = *on
416jAC                   eval      $samemo = 'Putaway Empty Slot (RC200E)'
416jAC                   eval      $saqtyu = *on
416jAC                   eval      $saqty1 = 0
416jAC                   eval      $saqty2 = 0
416jAC                   eval      $saqty3 = 0
416jA
     *  When slot is the putaway slot ...
416jA
     *    ... Only reduce qty by qty in slot before putaway.
416jA
416jAC                   select
416jAC                   when      $sldisp = $pdisp and $slitem = $pitem
416jA
416jAC                   if        $slavl1 > $pqty1
416jAC                   eval      $saqty1 = -($slavl1 - $pqty1)
416jAC                   endif
416jA
416jAC                   if        $slavl2 > $pqty2
416jAC                   eval      $saqty2 = -($slavl2 - $pqty2)
416jAC                   endif
416jA
416jAC                   if        $slavl3 > $pqty3
416jAC                   eval      $saqty3 = -($slavl3 - $pqty3)
416jAC                   endif

     *    ... Otherwise, reduce slot by current available quantity.

416jAC                   other
416jAC                   eval      $saqty1 = -($slavl1)
416jAC                   eval      $saqty2 = -($slavl2)
416jAC                   eval      $saqty3 = -($slavl3)

416jAC                   endsl

     *  Adjust slot if necessary (ignore errors)

416jAC                   if        $saqty1 <> 0
416jAC                             or $saqty2 <> 0
416jAC                             or $saqty3 <> 0
416jAC                   eval      flagerrors = *off
416jAC                   eval      $drisubcmd  = '%ADJUST'
416jAC                   exsr      zzzdricop
416jAC                   if        $slstat = 'Z'
416jAC                   eval      $drisubcmd  = '%ZEROVFY'
416jAC                   exsr      zzzdricop
416jAC                   endif
416jAC                   endif

     C     endadjust     endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *
     *  Note: When an error occurs *IN91 is set on to allow F3/F12.
     *        This allows an escape path for unexpected errors.
     *
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $slot

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   if        flagerrors
     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      *in91 = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      *in91 = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   endif

     C                   endsl
     C                   endif

     C                   eval      $slot = $dridata

     C                   eval      zmsflag = *off
     C                   eval      flagerrors = *off
     C     enddricop     endsr
