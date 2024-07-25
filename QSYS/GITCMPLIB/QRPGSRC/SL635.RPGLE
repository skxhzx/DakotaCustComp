650aA /copy *libl/qcopysrc,hspecs
500aA*----------------------------------------------------------------
500aA*  Multilingual Verision
500aA*  Every screen and message has a corresponding Spanish version.
500aA*  Any changes must be made to both languages.
500aA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL635     View slot quantities RF Mini screen
     *  12 February, 1997
     *  Roxanne Harrison
     *
     *  Notes:
     *       Created using SL810 full screen
     *       Move breakdown qty's display to sc3.
     *       8 X 20 Screens for hand held scanners
     *  Revisions
     *
413 A*    09/26/99  DAS 4.13
     *      - Revised ZZFIL1 to get SSB item if one exists.
     *      - Revised screen3 to display 'SSB' for an SSB item.
500 A*    04/13/06  RH  5.00
     *      - Enh: Added F10 to write exception if qty off.
     *
500aA*    06/04/06  JCJ  5.00
     *      - Added Multilingual logic.
     *
650aA*    11/11/14  LMC  6.50a
     *      - Enh: Added W2INFO field to dispaly open putaway msg.
     *        Changed to use new display file SL63501.
     *        Check label12 file for open putaway for slot.
     *        Converted to RPGLE.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aD*SL635FM CF  E                    WORKSTN
650aMFsl63501   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     *AREHS  IF  E           K        DISK
     Fslot2     if   e           k disk
     Fpiritem   if   e           k disk
     Funmesr    if   e           k disk
     Fitmexcp   o    e           k disk
650aAFLabel12   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
650aAD info            s             15    dim(1) ctdata perrcd(1)
650aAD infosp          s             15    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
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
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
500  *----------------------------------------------------------------
500  *  Called programs
     D @cvtdt          c                   const('CVTDTE')
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
     D #msgsp          c                   const('PIRMSGFSP ')
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
650aA*----------------------------------------------------------------
650aA*  Variables
650aA*
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D ssbflg          s              1
     D today           s              8  0
     D warn            s              1
     D w1grp1          s              1
     D w1grp2          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse code.
     *      $PWHDP  Department.
     *      $PDISP  Slot.
     *
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
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
500aAC                   select
500aAC                   when      e$lng = 'SP'
500aAC                   exfmt     scrn1sp                              50
500aAC                   other
     C                   exfmt     screen1                              50
500aAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500aAC                   select
500aAC                   when      e$lng = 'SP'
500aAC                   exfmt     scrn2sp                              50
500aAC                   other
     C                   exfmt     screen2                              50
500aAC                   endsl
     C                   endif
     C                   if        nxtscr = '03 '
500aAC                   select
500aAC                   when      e$lng = 'SP'
500aAC                   exfmt     scrn3sp                              50
500aAC                   other
     C                   exfmt     screen3                              50
500aAC                   endsl
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
     C                   exsr      zzdft1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get existing record(s).
     *
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     *  Get existing record(s).
     *
     C                   exsr      zzfil3
     C     end03i        endsr
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
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   exsr      scr01i
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     C                   exsr      scr01i
     C     endsc3        endsr
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
500aAC                   select
500aAC                   when      e$lng = 'SP'
500aAC                   eval      $msgf = #msgsp
500aAC                   other
     C                   eval      $msgf = #msgf
500aAC                   endsl
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
500aAC                   select
500aAC                   when      e$lng = 'SP'
500aAC                   eval      $msgf = #msgsp
500aAC                   other
     C                   eval      $msgf = #msgf
500aAC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq2           10
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12210  Can't lock item record.
     *
     C     zm10          begsr
     C                   eval      #msgid = 'IT12210'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Item does not exist.
     *
     C     zm73i         begsr
     C                   eval      #msgid = 'IT12273'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md(1) = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
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
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
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
     *  Verify slot number.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1disp
     C                   eval      $ldesg = *blanks
     C                   eval      $lstat = *blanks
     C                   eval      $lsdef = *blanks
     C                   eval      $lactv = *blanks
     C                   call      'SL900'
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
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C     endck3        endsr
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
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 8
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Department.
     *
     C                   when      row# = 9
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
     *
     *     Slot.
     *
     C                   when      row# = 10
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*GENERAL'
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1disp
     C                   eval      $ldesg = *blanks
     C                   eval      $lstat = *blanks
     C                   eval      $lsdef = *blanks
     C                   eval      $lactv = *blanks
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1disp = $ldisp
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F9 - View breakdown quantities.
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   exsr      scr03i
     C                   endif
500  *
500  *  Test for F10 - Qty exception.
500  *
500  C                   if        *inkj
500  C                   exsr      zzexcp
500  C                   exsr      zzdft1
500  C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
500  *
500  *  Test for F10 - Qty exception.
500  *
500  C                   if        *inkj
500  C                   exsr      zzexcp
500  C                   exsr      zzdft1
500  C                   endif
     *
     C     endcm3        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZCVDT  Convert date to proper format.
500 A*
500 AC     zzcvdt        begsr
500 A*
500 A*    Convert date into proper format.
500 A*
500 AC                   call      @cvtdt
500 AC                   parm                    $cvtdt
500 AC     endcvd        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   if        $pdisp = *blanks
     C                   eval      w1disp = *blanks
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
500  *
500  *  ZZEXCP Write item exception record to file.
500  *
500  C     zzexcp        begsr
500  *
500  *    Write an item exception record, and delete replenishment
500  *    record.
500  C                   eval      exwhse = slwhse
500  C                   eval      exwhdp = slwhdp
500  C                   eval      exstyp = slstyp
500  C                   eval      exitem = slitem
500  C                   eval      exfdis = sldisp
500 AC                   eval      extdis = *blanks
500  C                   eval      extask = 'VERIFY'
500  C                   eval      exerid = 'QTYEXC '
500 A*    Get todays date.
500 AC                   eval      $cvcmd = '*CURCMD '
500 AC                   exsr      zzcvdt
500 AC                   eval      today = $cvd8o
500  C                   eval      exgdte = today
500  C                   time                    exgtim
500  C                   eval      exgby = #user
500  C                   eval      exesta = '1 '
500  C                   write     exrec
500  *
500  C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get warehouse description.
     *
     *R         W1WHSE    CHAINWAREHS               79
     *R         *IN79     IFEQ *ON
     *R                   MOVELDESC,1    WHDESC
     *R                   ENDIF
     *
     *   Initialize quanitities.
     *
     C                   clear                   slstk1
     C                   clear                   slstk2
     C                   clear                   slstk3
     C                   clear                   slalc1
     C                   clear                   slalc2
     C                   clear                   slalc3
     C                   clear                   slpck1
     C                   clear                   slpck2
     C                   clear                   slpck3
     C                   clear                   sltfr1
     C                   clear                   sltfr2
     C                   clear                   sltfr3
     C                   clear                   slrcv1
     C                   clear                   slrcv2
     C                   clear                   slrcv3
     *
     *   Get slot and item quantity records.
     *
     C     slkey         chain     slot2                              79
     C     itkey         chain     piritem                            78
     *
     *   Format heading.
     *
     *R                   SELEC
     *R         *IN79     WHEQ *ON
     *R                   MOVE *BLANKS   SLITEM
     *R                   MOVE *BLANKS   W2HEAD
     *R                   MOVELDESC,2    W2HEAD
     *R         '-'       CAT  W2HEAD:1  W2HEAD
     *R         W1DISP    CAT  W2HEAD:1  W2HEAD
     *
     *R         *IN78     WHEQ *ON
     *R                   MOVE *BLANKS   W2HEAD
     *R                   MOVELDESC,3    W2HEAD
     *
     *R                   OTHER
     *R                   MOVE *BLANKS   W2HEAD
     *R         W2HEAD    CAT  SLITEM:1  W2HEAD
     *R         W2HEAD    CAT  '-':1     W2HEAD
     *R         W2HEAD    CAT  ITDESC:1  W2HEAD
     *
     *R                   ENDSL
650aA*   Check for open putaway
650aA /free
650aA   w2info = ' ';
650aA   chain (w1whse: 'P': ' ': w1Whdp: w1Disp) label12;
650aA   if %found(label12);
650aA     if e$lng = 'SP';
650aA       w2info = infosp(1);
650aA     else;
650aA       w2info = info(1);
650aA     endif;
650aA   endif;
650aA /end-free
     *
     *   Get short descriptions for units of measure.
     *
     C                   eval      w2um1 = *blanks
     C                   eval      w2um2 = *blanks
     C                   eval      w2um3 = *blanks
     *
     C                   if        itum1 <> *blanks
     C     itum1         chain     unmesr                             79
     C                   if        not *in79
     C                   eval      w2um1 = umshrt
     C                   else
     C                   movel     itum1         w2um1
     C                   endif
     C                   endif
     *
     *R         ITUM2     IFNE *BLANKS
     *R         ITUM2     CHAINUNMESR               79
     *R         *IN79     IFEQ *OFF
     *R                   MOVE UMSHRT    W2UM2
     *R                   ELSE
     C                   eval      w2um2 = itum2
     *R                   ENDIF
     *R                   ENDIF
     *
     *R         ITUM3     IFNE *BLANKS
     *R         ITUM3     CHAINUNMESR               79
     *R         *IN79     IFEQ *OFF
     *R                   MOVE UMSHRT    W2UM3
     *R                   ELSE
     C                   eval      w2um3 = itum3
     *R                   ENDIF
     *R                   ENDIF
     *
     C                   eval      w2avl1 = 0
     C                   eval      w2avl2 = 0
     C                   eval      w2avl3 = 0
     *
     *   Calculate available quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      w2avl1 = avail1
     *R                   Z-ADDAVAIL2    W2AVL2
     *R                   Z-ADDAVAIL3    W2AVL3
413 A*
413 A*   Get SSB item, if one exists
413 A*
413 AC                   eval      ssbflg = *off
413 AC                   eval      wossb = *blanks
413 AC                   if        ittype = ' '
413 AC                   call      'GETSSB'
413 AC                   parm      itwhse        $gwhse            3 0
413 AC                   parm      ititem        $gitem           15
413 AC                   parm      ' '           #bitem           15
413 AC                   parm                    #bdesc           30
413 AC                   parm                    #bpdsc           15
413 AC                   parm                    #bwhdp            5
413 AC                   parm                    #bstyp            1
413 AC                   parm                    #bum              2
413 AC                   parm                    #bum2             2
413 AC                   parm                    #bumq2            3 0
413 AC                   parm                    #bum3             2
413 AC                   parm                    #bumq3            3 0
413 AC                   parm                    #brtn             8
413 A*
413 AC                   if        #brtn = '*FOUND  '
413 AC                   eval      ssbflg = *on
413 AC                   eval      wossb = 'SSB'
413 AC                   endif
413 A*
413 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *
     *   Read slot and item quantity records in ZZFIL2.
     *
     C                   eval      w2avl2 = avail2
     C                   eval      w2avl3 = avail3
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for item file.
     *
     C     itkey         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     *
     *  Define key for slot file.
     *
     C     slkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1disp
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500cA*
500cA*   Get employee options.
500cA*
500cAC                   call      'GETUSER'
500cAC                   parm      #user         e$code           10
500cAC                   parm                    e$whse            3 0
500cAC                   parm                    e$emp#            5 0
500cAC                   parm                    e$fnam           15
500cAC                   parm                    e$init            1
500cAC                   parm                    e$lnam           20
500cAC                   parm                    e$whdp            5
500cAC                   parm                    e$styp            1
500cAC                   parm                    e$shft            6
500cAC                   parm                    e$crew            6
500cAC                   parm                    e$nhrs            3 1
500cAC                   parm                    e$rtn             8
500cAC                   parm                    e$bpu             1
500cAC                   parm                    e$lng             2
500cAC                   if        e$rtn <> '*OK'
500cAC                   eval      e$lng = 'EN'
500cAC                   endif
500cA*
     *
     *   Select first screen to display.
     *
     C                   select
     C                   when      $pdisp = *blanks
210 D*R         #USER     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *ON
210 D*R                   Z-ADD1         W1WHSE
210 D*R                   ELSE
210 D*R                   Z-ADDUSWHSE    W1WHSE
210 D*R                   ENDIF
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     w1whse        parm      0             #whse             3 0
210 A*
     C                   exsr      scr01i
     *
     C                   other
     C                   eval      w1whse = $pwhse
     C                   eval      w1whdp = $pwhdp
     C                   eval      w1disp = $pdisp
     C                   eval      w2avl1 = 0
     C                   eval      w2avl2 = 0
     C                   eval      w2avl3 = 0
     C                   exsr      scr02i
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     C                   exsr      scr02i
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      nxtscr = 'EOJ'
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      nxtscr = 'EOJ'
     C     endup3        endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**  INFO
Open Putaway
**  INFOSP
Abierto guardar
