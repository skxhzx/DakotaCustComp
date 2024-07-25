     H Option(*Nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SL112     Slot maintenance - Change
     *  08 August 1994
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    10/15/01  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
416aA*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
416bA*    02/14/02  DAS  4.16b
     *      - Revised call to FRMTSL to use $VWHSE instead of $PWHSE
416cA*    06/11/02  DAS  4.16c
     *      - Recompiled because of change to C#SLOT.
     *
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *
650aA*    11/11/14  LMC  6.50a
     *      - Enh: Added a call to chkusage - If chkusage returns
     *        $upieces > 0, then we have qty that could be an open
     *        directed putaway. We will protect the item# so it can
     *        not be changed if this is true.
650bA*    02/13/14  LMC  6.50b
     *      - Fix: Mod 650a should only execute the chkusage if the
     *        item is in a department that is doing directed put away.
740aA*    09/17/20  RH   7.40a
     *      - Fix: Change whse parm calling PIRPCK, got decimal data
     *        error, fixed error message from call to PIRPCK
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
     *  File Specs
     *
     Fsl112fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
216 AFitemdef   if   e           k disk
650bAFoptiond   if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
650bAD kycode          s                   like(opdcod)
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D whse            s              3  0

650aAD $uDiffItem      s              1
650aAD $uCube          s              9  3
650aAD $uDisp          s             12
650aAD $uItem          s             15
650aAD $uPieces        s              5  0
650aAD $uRecs          s              3  0
650aAD $uRsrv          s              1
650aAD $uWhdp          s              5
650aAD $uWhse          s              3  0
650aAD $uEntDte        s              8  0
650aAD $uExpDte        s              8  0
650aAD $uDiffEntd      s              1
650aAD $uDiffExpd      s              1

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
     D  $pwhdp                22     26
     D  $paisl                27     29
     D  $ploc                 30     32  0
     D  $prlvl                33     34  0
     D  $phand                35     36
     D  $pdisp                37     48
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
413 AD  $lwhs2                19     21  0
413 AD  $lwhdp                22     26
413 AD  $ldisp                27     38
413 AD  $litm2                39     53
     *
     D  $lwhse                19     21  0
     D  $lsdef                22     23
     D  $litem                22     36
     *
     D  $lstat                19     20
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lbld                 19     20
650bA*----------------------------------------------------------------
650bA*  *PICK  -  Picking options
650bA*----------------------------------------------------------------
650bA*
650bA* Fields
650bA*
650bA*    OPNXTP  -  Next pallet number.
650bA*    OPBPCK  -  Bulk pick definition.
650bA*    OPPCUB  -  Maximum cube for PIR.
650bA*    OPFPAL  -  Pallets on fixed fork lift.
650bA*    OPFCUB  -  Maximum cube per fixed pallet.
650bA*    OPFSTP  -  Maximum stops per fixed pallet.
650bA*    OPINCL  -  Include PIR in fixed cube.
650bA*    OPSRCH  -  Number of previous pallets to search for space.
650bA*    OPFBLD  -  Fixed pallet building method.
650bA*                1 = By piece without concern for splitting stop.
650bA*                2 = By stop without splitting stop between plts.
650bA*    OPPBRK  -  Break pallets by aisle (Y,N).
650bA*    OPMPUT  -  Manual Put away (Y,N).
650bA*
650bA* Data structure
650bA*
650bAD opddta          ds
650bAD  opnxtp                 1      7  0 inz(0)
650bAD  oppcub                10     14  2 inz(0)
650bAD  opfpal                15     15  0 inz(0)
650bAD  opfcub                16     20  2 inz(0)
650bAD  opincl                22     22
650bAD  opsrch                23     24  0 inz(0)
650bAD  opfstp                25     26  0 inz(0)
650bAD  opfbld                27     27  0 inz(0)
650bAD  opbpck                28     30  0 inz(0)
650bAD  oppbrk                31     33
650bAD  opmput                34     34
650bAD  opdend               117    117
     *
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
     D  eritem                 1     15
     *
     D  erdisp                 1     12
     *
     D  ersdpt                13     17
     D  erstyp                18     18
     D  ersdsg                19     23
     *
     D  eridpt                24     28
     D  erityp                29     29
     D  eridsg                30     34
     *
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D $MSGF           s             10
     D MSGK            s              4  0
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
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
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
407 A*              *COPY    - Copy record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
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
     *R                   SETOF                     363738
     C                   setoff                                       3738
     C                   setoff                                       3940
     **                   SETOF                     9298
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
     *
 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
 1E  C                   endif
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
 2B  C                   if        $pcmd <> '*COPY   '
     C                   eval      *in91 = *on
 2E  C                   endif
     C                   exsr      zzget1
     C                   exsr      zzfil1
 1E  C                   endif
     C                   eval      ovrrid = *off
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
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '  or
     C                             $pcmd = '*COPY   '
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
     C                   move      'EOJ'         nxtscr
     C     endsc1        endsr

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Initialize special keys

     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125

     *  Initialize message handling

     C                   exsr      zmimsg

     *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  chkUsage   Check slot usage
650aA*----------------------------------------------------------------
650aAC     chkUsage      begsr

650aAC                   call      'CHKUSAGE'
650aAC                   parm      $slwhse       $uWhse
650aAC                   parm      $slwhdp       $uWhdp
650aAC                   parm      $sldisp       $uDisp
650aAC                   parm      $slrsrv       $uRsrv
650aAC                   parm      $slitem       $uItem
650aAC                   parm                    $uEntDte
650aAC                   parm                    $uExpDte
650aAC                   parm      0             $uPieces
650aAC                   parm      0             $uRecs
650aAC                   parm      ' '           $uDiffItem
650aAC                   parm      ' '           $uDiffEntd
650aAC                   parm      ' '           $uDiffExpd
650aAC                   endsr

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     C                   endsr

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

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
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

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
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     ZM07  Warning - No record exists in Tie/High def. file.
     *----------------------------------------------------------------

     C     zm07          begsr
     C                   move      'IT13207'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      erdisp = $sldisp
     C                   eval      eritem = $slitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   move      *off          error

     *  Fill interface data structure fields.

     C                   exsr      zzfill$slot

     *  Verify in Dakota.

 1B  C                   if        $pcmd = '*ADD' or
 1B  C                             $pcmd = '*COPY'
 1B  C                   eval      $drisubcmd = '%VERIFYADD'
 1B  C                   else
 1B  C                   eval      $drisubcmd = '%VERIFYCHG'
 1B  C                   endif

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm                    $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   if        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C                   exsr      zzseterrind
     C                   goto      endck1
     C                   endif

     *  Verify on Host.

     C****               call      'DRICOP'
     C****               parm      '*SLOT'       $dricommand
     C****               parm                    $drisubcmd
     C****               parm      'H'           $drisys2upd
     C****               parm      #prog         $driprogram
     C****               parm                    $drireturn
     C****               parm                    $drimessage
     C**** $slot         parm      $slot         $dridata

     C****               if        $drireturn <> '*OK'
     C****               eval      error = *on
     C****               exsr      zm0001
     C****               exsr      zzseterrind
     C****               goto      endck1
     C****               endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
 2B  C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Slot type.
     *
 3B  C                   select
 3X  C                   when      row# = 14
     C                   eval      *in08 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   eval      $lsdef = w1sdef
     C                   call      'SD900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1sdef = $lsdef
 4E  C                   endif
     *
     *     Status.
     *
 3X  C                   when      row# = 15
     C                   eval      *in09 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lstat = w1stat
     C                   call      'SS900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1stat = $lstat
 4E  C                   endif
     *
     *     Designation area.
     *
 3X  C                   when      row# = 16
     C                   eval      *in10 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $ldesg = w1desg
     C                   call      'DS900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1desg = $ldesg
 4E  C                   endif
     *
     *     Activity zone.
     *
 3X  C                   when      row# = 17
     C                   eval      *in11 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lactv = w1actv
     C                   call      'AC900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1actv = $lactv
 4E  C                   endif
     *
     *     Build code.
     *
 3X  C                   when      row# = 18
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lbld = w1bld
     C                   call      'BC900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1bld = $lbld
 4E  C                   endif
     *
     *     Item.
     *
 3X  C                   when      row# = 21  and
     C                             not *in92
     C                   eval      *in15 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litem
 4E  C                   endif
     *
 3X  C                   other
     *
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
 3E  C                   endsl
 2E  C                   endif
     *
     *  Test for F7 - Change item.
     *
 2B  C                   if        *inkg
     C                   move      *on           cmdtkn
     C                   eval      $slot = save$slot
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhs2 = $slwhse
     C                   eval      $lwhdp = $slwhdp
     C                   eval      $ldisp = $sldisp
     C                   eval      $litm2 = $slitem
     C                   call      'SL252'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*OK     '
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   exsr      scr01i
 3E  C                   endif
 3B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 3E  C                   endif
 2E  C                   endif
     *
     *  Test for F9 - Create display and picking sequence.
     *
 2B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Picking sequence.
     *
 3B  C                   select
 3X  C                   when      row# = 12
     C                   eval      *in07 = *on
 4B  C                   if        w1styp = 'F'
     C                   eval      w1pseq = w1loc
 4X  C                   else
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm      w1aisl        $cstr
     C                   move      $cstr         $paisl
     C                   call      'PIRPCK'
     C                   parm      ' '           $lcmd
     C                   parm                    $lprg
740aDC*                  parm                    $pwhse
740aAC                   parm      $pwhse        $vwhse
     C                   parm                    $pwhdp
     C                   parm                    $paisl
     C                   parm                    w1loc
     C                   parm                    w1rlvl
     C                   parm      0             w1pseq
     C                   parm                    $lrtn
     C                   parm                    $lerm
740aAC                   if        $lrtn = '*PGMQ   '
740aAC                   move      *on           error
740aAC                   eval      #msgk = $lmsg
740aAC                   exsr      zmqmsg
740aAC                   endif
 4E  C                   endif
     *
     *     Display.
     *
 3X  C                   when      row# = 13
     C                   eval      *in06 = *on
     C                   call      'FRMTSL'
416bDC**                 parm                    $pwhse
416bMC                   parm      $pwhse        $vwhse
     C                   parm                    $pwhdp
     C                   parm                    w1aisl
     C                   parm                    w1loc
     C                   parm                    w1rlvl
     C                   parm                    w1hand
     C                   parm                    w1styp
     C                   parm                    w1pseq
     C                   parm                    w1disp
     *
 3X  C                   other
     *
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
 3E  C                   endsl
 2E  C                   endif
     *
     *      F20 - Accept Warning.
     *
 2B  C                   if        *inku
     C                   eval      ovrrid = *on
 2E  C                   endif
     *
     *      F21 - Item Tie/High Maintenance.
     *
 2B  C                   if        *inkv
     C                   eval      cmdtkn = *on
     C                   z-add     $pwhse        whse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    w1item
 2E  C                   endif
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      *in92 = *off
     C                   eval      *in36 = *off
     C                   eval      w1aisl = *blanks
     C                   eval      w1loc = *zeros
     C                   eval      w1rlvl = *zeros
     C                   eval      w1hand = *blanks
     C                   eval      w1styp = 'P'
     C                   eval      w1disp = *blanks
     C                   eval      w1pseq = *zeros
     C                   eval      w1sdef = *blanks
     C                   eval      w1stat = *blanks
     C                   eval      w1desg = *blanks
     C                   eval      w1actv = *blanks
     C                   eval      w1bld = *blanks
     C                   eval      w1pick = 'Y'
     C                   eval      w1rsrv = 'N'
     C                   eval      w1item = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr

     *  Restore record information.

     C                   eval      $slot = save$slot

     *  Initialize screen fields and indicators.

     C                   eval      *in92 = *off
     C                   eval      w1aisl = $slaisl
     C                   eval      w1loc = $slloc
     C                   eval      w1rlvl = $slrlvl
     C                   eval      w1hand = $slhand
     C                   eval      w1styp = $slstyp
     C                   eval      w1disp = $sldisp
     C                   eval      w1pseq = $slpseq
     C                   eval      w1sdef = $slsdef
     C                   eval      w1stat = $slstat
     C                   eval      w1desg = $sldesg
     C                   eval      w1actv = $slactv
     C                   eval      w1bld = $slbld
     C                   eval      w1pick = $slpick
     C                   eval      w1rsrv = $slrsrv
     C                   eval      w1item = $slitem
     *
     *   If virtual slot, protect field so it can't be changed.
     *
 1B  C                   if        $slrsrv = 'V'
     C                   eval      *in36 = *on
 1X  C                   else
     C                   eval      *in36 = *off
 1E  C                   endif
     *
     *   Set fields for copy only.
     *
 1B  C                   if        $pcmd = '*COPY   '
     C                   eval      w1disp = *blanks
     C                   eval      w1item = *blanks
 1E  C                   endif
     *
     *   Item number can't be changed if a qty exists for it.
     *
 1B  C                   if        $pcmd <> '*COPY   '
 2B  C                   if        $slstk1 <> 0  or
     C                             $slstk2 <> 0  or
     C                             $slstk3 <> 0  or
     C                             $slalc1 <> 0  or
     C                             $slalc2 <> 0  or
     C                             $slalc3 <> 0  or
     C                             $sltfr1 <> 0  or
     C                             $sltfr2 <> 0  or
     C                             $sltfr3 <> 0  or
     C                             $slpck1 <> 0  or
     C                             $slpck2 <> 0  or
     C                             $slpck3 <> 0  or
     C                             $slrcv1 <> 0  or
     C                             $slrcv2 <> 0  or
     C                             $slrcv3 <> 0
     C                   eval      *in92 = *on
 2E  C                   endif
650aA /free
650aA   // use chkusage as a double check - item can't be removed if
650aA   // an open directed putaway exist
650bD   //if  not *in92;
650bM   if not *in92 and opmput = 'N';
650aA     exsr chkusage;
650aA     if $upieces > 0;
650aA       *in92 = *on;
650aA     endif;
650aA   endif;
650aA /end-free
 1E  C                   endif
     C                   endsr

      *----------------------------------------------------------------
      *  zzfill$slot  Fill $slot data structure fields.
      *----------------------------------------------------------------

     C     zzfill$slot   begsr

      *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

      *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = w1aisl

     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = w1loc

     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = w1rlvl

     C                   eval      $slhandu = *on
     C                   eval      $slhand  = w1hand

     C                   eval      $slstypu = *on
     C                   eval      $slstyp  = w1styp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $slpsequ = *on
     C                   eval      $slpseq  = w1pseq

     C                   eval      $slsdefu = *on
     C                   eval      $slsdef  = w1sdef

     C                   eval      $slstatu = *on
     C                   eval      $slstat  = w1stat

     C                   eval      $sldesgu = *on
     C                   eval      $sldesg  = w1desg

     C                   eval      $slactvu = *on
     C                   eval      $slactv  = w1actv

     C                   eval      $slbldu  = *on
     C                   eval      $slbld   = w1bld

     C                   eval      $slpicku = *on
     C                   eval      $slpick  = w1pick

     C                   eval      $slrsrvu = *on
     C                   eval      $slrsrv  = w1rsrv

     C                   eval      $slitemu = *on
     C                   eval      $slitem  = w1item

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr

     *  Initialize interface parameters.

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = $paisl

     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = $ploc

     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = $prlvl

     C                   eval      $slhandu = *on
     C                   eval      $slhand  = $phand

     *  Get slot record.

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm      '%GETI'       $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   if        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001s
     C                   eval      $prtn = '*PGMQ'
     C                   goto      endgt1
     C                   endif

     *  Save record information.

     C                   eval      save$slot = $slot

     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *   Get warehouse description.

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl

     C                   eval      $cstr = *blanks
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     C                   eval      whdesc = $vdesc

     *   Get warehouse department description.

     C                   call(e)   'VFYWHDP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      $pwhdp        $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl
650bA*
650bA*   Get department Options.
650bA*
650bA /free
650bA   kycode = '*PICK   ';
650bA   chain (kycode: $pwhse: $pwhdp) optiond;
650bA   if not %found(optiond);
650bA     opmput = 'N';
650bA   endif;
650bA /end-free

     C                   eval      wdcode = $pwhdp
     C                   eval      wddesc = $vdesc

     *   Select first screen to display.

 1B  C                   if        $pcmd = '*ADD    '
     C                   eval      $paisl = *blanks
     C                   eval      $ploc = *zeros
     C                   eval      $prlvl = *zeros
     C                   eval      $phand = *blanks
 1E  C                   endif
     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------
     *  zzseterrind  Set error indicators.
     *----------------------------------------------------------------

     C     zzseterrind   begsr

      *  Move fields from record to data structure.

     C                   if        $slaisle = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $slloce  = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $slrlvle = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $slhande = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $slstype = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $sldispe = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $slpseqe = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif

     C                   if        $slsdefe = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $slstate = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $sldesge = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $slactve = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif

     C                   if        $slblde  = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   endif

     C                   if        $slpicke = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   endif

     C                   if        $slrsrve = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   endif

     C                   if        $sliteme = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr

     *  Update Host.

 1B  C                   if        $pcmd = '*ADD' or
 1B  C                             $pcmd = '*COPY'
 1B  C                   eval      $drisubcmd = '%ADD'
 1B  C                   else
 1B  C                   eval      $drisubcmd = '%CHANGE'
 1B  C                   endif

     C****               call      'DRICOP'
     C****               parm      '*SLOT'       $dricommand
     C****               parm                    $drisubcmd
     C****               parm      'H'           $drisys2upd
     C****               parm      #prog         $driprogram
     C****               parm                    $drireturn
     C****               parm                    $drimessage
     C**** $slot         parm      $slot         $dridata

     C****               if        $drireturn <> '*OK'
     C****               eval      error = *on
     C****               exsr      zm0001
     C****               exsr      zzseterrind
     C****               goto      endupd
     C****               endif

     *  Update Dakota.

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm                    $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   if        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C                   exsr      zzseterrind
     C                   goto      endupd
     C                   endif

     *   Move key values to parameters

     C                   eval      $paisl = $slaisl
     C                   eval      $ploc = $slloc
     C                   eval      $prlvl = $slrlvl
     C                   eval      $phand = $slhand
     C     endupd        endsr
