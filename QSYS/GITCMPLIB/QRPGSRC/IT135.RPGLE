500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT135     Item slot information - View
     *  22 May, 1996
     *  Roxanne Harrison
     *  Dave Sommerville
     *
     *  Revisions:
     *
218 A*    02/05/97  RH   2.18
     *      - Use SLITEM instead of $PITEM to enable call from SL610.
     *
500 A*    03/29/05  DAS  5.00
     *      - Converted to ILE.
     *      - Revised to use DRI interfaces.
     *      - Added slot position to displays.
     *
600aA*    01/20/09  DAS  6.00a
     *      - Recompiled because of changes to C#SLOT.
     *
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
     *
     Fit135fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
500 DF*lot2     if   e           k disk
500 DF*iritem   if   e           k disk
     Factivity  if   e           k disk
     Fbldcode   if   e           k disk
     Fdesig     if   e           k disk
500 DF*temdef   if   e           k disk
500 DF*lotdef   if   e           k disk
     Fslotstat  if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)

500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#ITEM
500 A /COPY *libl/qcopysrc,C#ITEMQTY
500 A /COPY *libl/qcopysrc,C#SLOT
500 A /COPY *libl/qcopysrc,C#SLOTDEF
500 AD saveVer#        s                   like($slver#)
500 AD save$slot       s                   like($slot)

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
     D  $pitem                39     53
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtwh          c                   const('FRMTWH')
     D @fmtit          c                   const('FRMTIT')
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
     D  $lcode                19     20
     *
     D  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
     D  erslot                 1     12
     D  erstat                13     42
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
500 AD  #pgm             *proc
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
     D $cdesc          s             30
     D $cstr           s             40
     D $cwhse          s              3  0
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
500 AD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
500 AD drierr          s               n
     D e               s              2  0
     D enter           s              5  0
500 MD error           s               n
     D help            s              5  0
500 AD i               s              3  0
     D lock            s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D whdesc          s             30
     D whse            s              3  0
500 AD zmsflag         s               n
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
     C                   if        $pcmd = '*VIEW   '
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   eval      $pdisp = w1disp
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1disp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM71  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM72  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
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
     C                   select
     *
     *  When adding ....
     *
     C                   when      $pcmd = '*ADD    '
     *
     C                   endsl
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
     C                   goto      endcm1
     C                   endif
     *
     *      F9 - View slot quantities.
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   eval      whse = $pwhse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    $pwhdp
     C                   parm                    w1disp
     C                   endif
     *
     *
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
     *  ZZFIL0   Fill screen 1  heading fields.
     *
     C     zzfil0        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *
     *   Get warehouse description.
     *
     C                   eval      w1whse = *blanks
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   movel     $pwhse        $cwhse
     C                   eval      $cdesc = whdesc
     C                   eval      $cstr = *blanks
     C                   call      @fmtwh
     C                   parm                    $cwhse
     C                   parm                    $cdesc
     C                   parm                    $cstr
     C                   eval      w1whse = $cstr
     *
     *   Get SLOT record.
     *
500 A
500 AC                   exsr      clr$slot
500 AC                   eval      $slwhseu = *on
500 AC                   eval      $slwhse  = $pwhse
500 AC                   eval      $slwhdpu = *on
500 AC                   eval      $slwhdp  = $pwhdp
500 AC                   eval      $sldispu = *on
500 AC                   eval      $sldisp  = $pdisp
500 A
500 AC                   eval      $dricommand = '*SLOT'
500 AC                   eval      $drisubcmd  = '%GET'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      chk4err = *off
500 AC                   eval      zmsflag = *off
500 AC                   exsr      zzzdricop

500 DC**                 eval      slwhse = $pwhse
500 DC**   slkey         chain     slot2                              79
500 DC**                 if        *in79
500 DC**                 eval      slwhdp = *blanks
500 DC**                 eval      slstyp = *blanks
500 DC**                 eval      slpick = *blanks
500 DC**                 eval      slrsrv = *blanks
500 DC**                 eval      slstat = *blanks
500 DC**                 eval      slsdef = *blanks
500 DC**                 eval      sldesg = *blanks
500 DC**                 eval      slactv = *blanks
500 DC**                 eval      slbld = *blanks
500 DC**                 eval      slsdte = *zeros
500 DC**                 eval      slstim = *zeros
500 DC**                 eval      slentd = *zeros
500 DC**                 eval      slexpd = *zeros
500 DC**                 endif
500 A
500 A*   Slot position
500 A
500 AC                   eval      w1slp = 'Pos: '
600aMC                                   + %trim(%editc($saToPos:'3'))
500 A
     *   Department from slot file.
500 A
500 MC                   eval      w1whdp = $slwhdp
500 A
     *   Section from slot file.
500 A
     C                   select
500 MC                   when      $slstyp = 'F'
     C                   eval      w1sect = 'FIXED'
500 MC                   when      $slstyp = 'P'
     C                   eval      w1sect = 'PIR  '
     C                   other
     C                   eval      w1sect = *blanks
     C                   endsl
500 A
     *   Pick hole
500 A
     C                   select
500 MC                   when      $slpick = 'Y'
     C                   eval      w1pick = 'YES'
500 MC                   when      $slpick = 'N'
     C                   eval      w1pick = 'NO '
     C                   other
     C                   eval      w1pick = *blanks
     C                   endsl
500 A
     *   Reserved slot
500 A
     C                   select
500 MC                   when      $slrsrv = 'Y'
     C                   eval      w1rsrv = 'YES'
500 MC                   when      $slrsrv = 'N'
     C                   eval      w1rsrv = 'NO '
     C                   other
     C                   eval      w1rsrv = *blanks
     C                   endsl
500 A
     *   Slot date
500 A
500 MC                   if        $slsdte = 0
     C                   eval      w1ssdt = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
500 MC                   move      $slsdte       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1ssdt = $cvd6o
     C                   endif
500 A
     *   Slot time
500 A
500 MC                   eval      w1stim = $slstim
500 A
     *   Date item entered slot
500 A
500 MC                   if        $slentd = 0
     C                   eval      w1sdte = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
500 MC                   move      $slentd       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1sdte = $cvd6o
     C                   endif
500 A
     *   Expiration date
500 A
500 MC                   if        $slexpd = 0
     C                   eval      w1exdt = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
500 MC                   move      $slexpd       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1exdt = $cvd6o
     C                   endif
500 A
     *   Activity zone
500 A
500 MC     $slactv       chain     activity                           79
     C                   if        *in79
     C                   eval      acdesc = *blanks
     C                   endif
     C                   eval      w1desa = acdesc
500 MC                   eval      w1actv = $slactv
500 A
     *   Build code
500 A
500 MC     $slbld        chain     bldcode                            79
     C                   if        *in79
     C                   eval      bcdesc = *blanks
     C                   endif
     C                   eval      w1desb = bcdesc
500 MC                   eval      w1bld = $slbld
500 A
     *   Designation
500 A
500 MC     $sldesg       chain     desig                              79
     C                   if        *in79
     C                   eval      dsdesc = *blanks
     C                   endif
     C                   eval      w1desd = dsdesc
500 MC                   eval      w1desg = $sldesg
500 A
     *   Slot definition
500 A
500 AC                   exsr      clr$slotdef
500 AC                   eval      $sdwhse  = $slwhse
500 AC                   eval      $sdcode  = $slsdef
500 A
500 AC                   eval      $dricommand = '*SLOTDEF'
500 AC                   eval      $drisubcmd  = '%GET'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      chk4err = *on
500 AC                   eval      zmsflag = *off
500 AC                   exsr      zzzdricop
500 AC                   if        drierr
500 AC                   eval      error = *off
500 AC                   eval      $sdpos = 1
500 AC                   endif
500 DC**   sdkey         chain     slotdef                            79
500 DC**                 if        *in79
500 DC**                 eval      sddesc = *blanks
500 DC**                 endif
500 DC**                 eval      w1sdes = sddesc
500 DC**                 eval      w1sdef = slsdef
500 MC                   eval      w1sdes = $sddesc
500 MC                   eval      w1sdef = $slsdef
500 D**  Item tie/high
500 DC**   idkey         chain     itemdef                            79
500 DC**                 if        *in79
500 DC**                 eval      idtie = *zeros
500 DC**                 eval      idhigh = *zeros
500 DC**                 eval      idpref = *blanks
500 DC**                 endif
500 DC**                 eval      w1tie = idtie
500 DC**                 eval      w1high = idhigh
500 D**  Preferred tie/high
500 DC**                 select
500 DC**                 when      idpref = 'Y'
500 DC**                 eval      w1pfer = 'YES'
500 DC**                 other
500 DC**                 eval      w1pfer = 'NO '
500 DC**                 endsl
500 A
     *   Slot status
500 A
500 MC     $slstat       chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = *blanks
     C                   endif
     C                   eval      w1slds = ssdesc
500 AC                   eval      w1slst = $slstat
500 A
     *   Item description and pack description.
500 A
     C                   eval      w1item = *blanks
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $slwhse
500 AC                   eval      $ititem  = $slitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETALL'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      chk4err = *off
500 AC                   eval      zmsflag = *off
500 AC                   exsr      zzzdricop
500 DC**   itkey         chain     piritem                            79
500 DC**                 if        *in79
500 DC**                 eval      itdesc = *blanks
500 DC**                 eval      itpdsc = *blanks
500 DC**                 endif
500 MC                   eval      $iitem = $slitem
218 D*R                   MOVEL$PITEM    $IITEM
500 MC                   eval      $idesc = $itdesc
500 MC                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w1item
500 A
500 A*   Item tie/high
500 A
500 AC                   eval      w1tie  = 0
500 AC                   eval      w1high = 0
500 AC                   eval      w1pfer = 'NO '
500 AC     1             do        5             i
500 AC                   if        $idsdef(i) = $slsdef
500 AC                   eval      w1tie  = $idtie(i)
500 AC                   eval      w1high = $idhigh(i)
500 AC                   if        $idpref(i) = 'Y'
500 AC                   eval      w1pfer = 'YES'
500 AC                   endif
500 AC                   leave
500 AC                   endif
500 AC                   enddo
     *
     *   Initialize entry fields
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
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     *  Define key for slot file.
     *
     *
500 DC**   slkey         klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    $pwhdp
500 DC**                 kfld                    w1disp
     *
     *    Define  key for SLOTDEF file.
     *
500 DC**   sdkey         klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    slsdef
     *
     *  Define key for item file.
     *
500 DC**   itkey         klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    slitem
218 D*R                   KFLD           $PITEM
     *
500 DC**   idkey         klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    slitem
218 D*R                   KFLD           $PITEM
500 DC**                 kfld                    slsdef
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *
     C                   eval      w1disp = $pdisp
     *
     *   Select first screen to display.
     *
     C                   eval      lock = *off
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     C     endupd        endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$itemqty  Clear $itemqty data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$itemqty   begsr
     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slot  Clear $slot data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slotdef  Clear $slotdef data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdriclose   Close any open files or programs.
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*ITEMQTY'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600aAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $dridata = $itemqty
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600aAC                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
500 DC**                 if        zmsflag
500 DC**                 exsr      zm0105s
500 DC**                 else
500 DC**                 exsr      zm0105
500 DC**                 endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on
500 DC**                 if        zmsflag
500 DC**                 exsr      zm0001s
500 DC**                 else
500 DC**                 exsr      zm0001
     C***                exsr      zzerrind
500 DC**                 endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $itemqty = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
