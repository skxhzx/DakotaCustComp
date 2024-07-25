     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL212     Slot maintenance - Change
     *  11 August 1994
     *  Dave Sommerville             THIS PGM WAS COPIED FROM PIR650
     *                               TO ADD PIRMODSCBI VER. MODS.
     *                               INCLUDING THE LATEST MOD (SLOTYPE).
     *                               JGD - 9/28/15 (To Find the Changes
     *                               Look for Mods GT date above).
     *
     *  Revisions
     *
416 A*    10/16/01  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416aA*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
     *
416bA*    06/11/02  DAS  4.16b
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
     *----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
CBI AF*    04/17/09  CBI-JGD
     F*      - Add logic to allow authorized users only to have
     F*        access to function key F1=Tie/High maint.
     A*
CBIa A*    08/03/10  CBI-JGD
     A*      Do not allow the creation of more than one pick slot
     A*      for a given item.
     A*
CBIb A*    09/17/10  CBI-JGD
     A*      Activate Pick Slot verification only if Pick Slot check
     A*      field has been changed.
     A*
CBIc A*    11/17/10  CBI-JGD
     A*      Revise Pick Slot maintenance editing routine (CBIb above).
     F*

CBId  *    08/28/13  CBI-JGD
     F*      - Maintain new file TIHIGHSND, keeps track of daily
     F*        item allocation change, in the case of Bari is Prod
     F*        new item slotting (Menu: Pirinv/Opt # 12/Opt # 2).
     F*        This app will produce the initial item allocation
     F*        data (Tihighsnd) to be later processed by scheduled
     F*        jobs EXPSTIHIGH which create the export file EXPSTIHIGH
     F*        retrieved by SAP/PI to update SAP item location info.
CBI0a*    09/26/17  NLK  Upgrade to 7.1
     *      - Enh: Wrap the CBI code to allow back to DEV
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    This program is only used for modifying a slot.  The logic
     *    for adding a slot has been taken out. Use SL110CL.
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
     *  File Specs
     *
     Fsl212fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
650bAFoptiond   if   e           k disk
CBIaAFslot3     if   e           k disk
CBIdAFtihighsnd uf a e           k disk
CBIdAFlocslog   o    e           k disk
CBI0a*
CBI0aD @getcl          c                   const('GETCLIENT')
CBI0a*
CBI0a /COPY QCOPYSRC,ID#CHENEY
CBIaA*----------------------------------------------------------------
CBIaA*  Table and array definitions
CBIaA*----------------------------------------------------------------

CBIaMD desc            s             50    dim(2) ctdata perrcd(1)

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
CBIdAD hlditem         s             15
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
     D  $pdisp                27     38
413 AD  $pitem                39     53
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
     *
216 AD  $lwhs                 19     21  0
216 AD  $litm                 22     36
CBId D*-------------------------------------------
CBId D*  Called programs
CBId D*
CBIdAD @cvtdt          c                   const('CVTDTE')
CBId  *----------------------------------------------------------------
CBIdAD $cvtdt          ds
CBIdAD  $cvcmd                 1      8
CBIdAD  $cvprg                 9     18
CBIdAD  $cvd6i                19     24
CBIdAD  $cvd8i                25     32
CBIdAD  $cvd6o                33     38  0
CBIdAD  $cvd8o                39     46  0
CBIdAD  $cvsto                47     64
CBIdAD  $cvrtn                65     72
CBIdAD  $cverm                73    132
CBIdAD  $cvmsg                73     76
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
     C                   eval      *in91 = *on
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
     C                   move      'EOJ'         nxtscr
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
CBI0a*
CBI0a* Get client id.
CBI0a*
CBI0aC                   call      @getcl
CBI0aC                   parm                    client           10
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

CBIaAC     pckey         Klist
CBIaAC                   Kfld                    $pwhse
CBIaAC                   Kfld                    w1item
CBIdA *
CBIdA *  Define key for TIHIGHSND file.
CBIdA *
CBIdAC     tisndkey      klist
CBIdAC                   kfld                    $pwhse
CBIdAC                   kfld                    w1item
CBIdAC*
     *
     *   Call user added initialization routine.
     *
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
     C                   write     msgctl
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
     C                   write     msgrec
 1E  C                   endif
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
     C                   move      *on           sclear
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
CBI A*----------------------------------------------------------------
CBI A*    PIR0105  Generic error.
CBI A*----------------------------------------------------------------
CBI A
CBI AC     zm0105        begsr
CBI AC                   eval      #msgid = 'PIR0105'
CBI AC                   eval      #msgtp = '*DIAG'
CBI AC                   eval      #msgdt = errmsg
CBI AC                   exsr      zmpmsg
CBI AC                   endsr

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

CBIaA*  Verify if the item being processed has a pick slot already
      *
CBI0AC                   if        client = cheney
CBIcDC*>                 if        $slpick <> w1pick
CBIaAC                   if        w1item <> *blanks and
CBIaAC                             w1pick = 'Y'
CBIaAC                   exsr      zzvfypckslot
CBIaAC                   if        error = *on
CBIaAC                   goto      endck1
CBIaAC                   endif
CBIaAC                   endif
CBI0AC                   endif
CBIcDC*>                 endif
      *
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
 3X  C                   when      row# = 12
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
 3X  C                   when      row# = 13
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
 3X  C                   when      row# = 14
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
 3X  C                   when      row# = 15
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
 3X  C                   when      row# = 16
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
 3X  C                   when      row# = 19  and
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
     C                   eval      $pcmd = '*CHANGE '
     C                   call      'SL252'
     C                   parm                    $parms
 3B  C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   exsr      scr01i
 3E  C                   endif
 3B  C                   if        $prtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 3E  C                   endif
 2E  C                   endif
     *
     *      F9 - View slot quantities.
     *
 2B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   eval      $slot = save$slot
     C                   eval      whse = $slwhse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    $slwhdp
     C                   parm                    $sldisp
 2E  C                   endif
     *
     *      F20 - Accept Warning.
     *
 2B  C                   if        *inku
     C                   move      *on           ovrrid
 2E  C                   endif
     *
     *      F21 - Item Tie/High Maintenance.
     *
 2B  C                   if        *inkv
     C                   move      *on           cmdtkn
     C*
     C*  Verify if user has update authorization.
     C*
CBI0AC                   if        client = cheney
CBI AC                   Call      'CHKLIST'
CBI AC                   Parm                    #Prog
CBI AC                   Parm      ' '           #Opt             20
CBI AC                   Parm                    #User
CBI AC                   Parm      ' '           @Prtn             8
     C*
CBI AC     @Prtn         Ifeq      '*NO'
CBI AC                   Move      '1'           Error
CBI AC                   Movel     Desc(1)       Errmsg
CBI AC                   Exsr      Zm0105
CBI AC                   Goto      Endcm1
CBI AC                   Endif
CBI0AC                   Endif
     C                   eval      whse = $pwhse
     C                   eval      $lwhs = $pwhse
     C                   eval      $litm = w1item
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
CBIdA *----------------------------------------------------------------
CBIdA *  zzcvdt  Convert date to proper format.
CBIdA *----------------------------------------------------------------
CBIdA *
CBIdAC     zzcvdt        begsr
CBIdAC*
CBIdAC*    Convert date into proper format.
CBIdAC*
CBIdAC                   call      @cvtdt
CBIdAC                   parm                    $cvtdt
CBIdAC*
CBIdAC     endcvd        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
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

     C                   eval      w1disp = $sldisp
     C                   eval      w1styp = $slstyp
     C                   eval      w1sdef = $slsdef
     C                   eval      w1stat = $slstat
     C                   eval      w1desg = $sldesg
     C                   eval      w1actv = $slactv
     C                   eval      w1bld = $slbld
     C                   eval      w1pick = $slpick
     C                   eval      w1rsrv = $slrsrv
     C                   eval      w1item = $slitem
      *
CBIdAC                   eval      hlditem = w1item
     *
     *   If status is 'TI', protect field so it can't be changed.
     *
 1B  C                   if        $slstat = 'TI'
     C                   eval      *in95 = *on
 1X  C                   else
     C                   eval      *in95 = *off
 1E  C                   endif
     *
     *   If virtual slot, protect field so it can't be changed.
     *
 1B  C                   if        $slrsrv = 'V'
     C                   eval      *in36 = *on
 1X  C                   else
     C                   eval      *in36 = *off
 1E  C                   endif
     *
     *   Item number can't be changed if a qty exists for it.
     *
 1B  C                   if        $slstk1 <> 0  or
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
 1X  C                   else
     C                   eval      *in92 = *off
 1E  C                   endif
650aA /free
650aA   // use chkusage as a double check - item can't be removed if
650aA   // an open directed putaway exist
650bD   //if not *in92;
650bM   if not *in92 and opmput = 'N';
650aA     exsr chkusage;
650aA     if $upieces > 0;
650aA       *in92 = *on;
650aA     endif;
650aA   endif;
650aA /end-free
510 A*
510 A*   Create field showing individual slot fields.
510 A*
     C                   eval      woslot = $slaisl + '/'
     C                                    + %char($slloc) + '/'
     C                                    + %char($slrlvl) + '/'
     C                                    + $slhand
     C                   endsr

      *----------------------------------------------------------------
      *  zzfill$slot  Fill $slot data structure fields.
      *----------------------------------------------------------------

     C     zzfill$slot   begsr

      *  Initialize data structure

     C                   eval      $slot = save$slot

      *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on

     C                   eval      $slwhdpu = *on

     C                   eval      $slaislu = *on

     C                   eval      $sllocu  = *on

     C                   eval      $slrlvlu = *on

     C                   eval      $slhandu = *on

     C                   eval      $sldispu = *on

     C                   eval      $slpsequ = *on

     C                   eval      $slstypu = *on
     C                   eval      $slstyp  = w1styp

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

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     *  Get slot record.

     C                   call      'DRICOP'
     C                   parm      '*SLOT'       $dricommand
     C                   parm      '%GET'        $drisubcmd
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

     C                   exsr      scr01i
     C                   endsr
CBIdA *----------------------------------------------------------------
CBIdA *  zzlog  Log the info of the item allocation being done
CBIdA *----------------------------------------------------------------

CBIdAC     zzlog         begsr
CBIdAC*
CBIdAC                   clear                   locrec
CBIdAC                   z-add     $pwhse        locwhs
CBIdAC                   move      $pwhdp        locdpt
CBIdAC                   if        w1item = *blanks
CBIdAC                   move      hlditem       locitm
CBIdMC                   move      w1disp        locfrm
CBIdAC                   move      'Discontinued'locto
CBIdAC                   else
CBIdDC                   move      w1item        locitm
CBIdMC                   move      *blanks       locfrm
CBIdAC                   move      $pdisp        locto
CBIdAC                   endif
CBIdAC*    Get todays date.
CBIdAC                   move      '*CURCMD '    $cvcmd
CBIdAC                   exsr      zzcvdt
CBIdAC                   z-add     $cvd8o        locdte
CBIdAC                   time                    loctim
CBIdAC                   move      #user         locusr
CBIdAC                   z-add     *zeros        locemp
CBIdAC*
CBIdAC                   write     locrec
CBIdAC*
CBIdAC     endlog        endsr

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
     C                   move      *off          error

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
CBIdA *----------------------------------------------------------------
CBIdA * Execute "Tihighsnd" logic below.
CBIdA *

CBI0AC                   if        client = cheney
CBIdAC     tisndkey      chain     Tihighsnd                          78
CBIdAC                   eval      snwhse = $pwhse
CBIdAC                   if        w1item = *blanks
CBIdAC                   eval      snitem = hlditem
CBIdAC                   else
CBIdAC                   eval      snitem = w1item
CBIdAC                   endif
CBIdAC                   eval      sntie  = *zeros
CBIdAC                   eval      snhigh = *zeros
CBIdMC                   eval      snsdef = w1sdef
CBIdAC                   eval      snsend = 'N'
CBIdAC                   if        *in78 = *off
CBIdAC                   update    sndrec
CBIdAC                   else
CBIdAC                   write     sndrec
CBIdAC                   endif
CBIdA * Log item allocation.
CBIdAC                   exsr      zzlog
CBI0AC                   endif

     C     endupd        endsr

CBiaA*----------------------------------------------------------------
CBIaA*  ZZVFYPCKSLOT verify if item has already a pick slot
CBIaA*----------------------------------------------------------------
CBIaA
CBIaAC     zzvfypckslot  begsr
CBIaA
CBIaA*  Find Pick Slot.
CBIaA
CBIaAC     pckey         chain     slot3
CBIaAC                   if        %found and
CBIcMC                             slpick = 'Y' and
CBIcAC                             sldisp <> w1disp
CBIaAC                   eval      error  = *on
CBIaAC                   eval      *in13  = *on
CBIaAC                   eval      *in33  = *on
CBIaAC                   eval      errmsg = desc(2)
CBIaAC                   exsr      zm0105
CBIaAC                   endif
CBIaA
CBIaAC                   endsr

** DESC **
Not authorized to use F-Key function F21.
This item has a pick slot already
