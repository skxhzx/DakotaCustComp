510 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SCD100    RF Staged SLOT AND CHECK DIGIT ENTRY
     *  23 December, 2000
     *  Kenneth Elder
     *
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *       Created using RC300.
     *
     *  Revisions
     *
417 A*    12/17/03  DAS  4.17
     *      - Added APICVTSLT to ZZCHK2 routines.
     *      - Revised to display message when digit added.
     *      - Revised SC1/2 to allow F12.
500aA*    11/16/04  RH   500a
     *      - Added code to display error messages on screen.
500bA*    12/28/05  RH   500b
     *      - Fix: Increase TEMP2A to 3 to display 3 digit check digit in msg.
510 A*    07/05/07  RBD  5.10
     *      - Enh: Converted to ILE.  Using new check digit options,
     *        *CHKDGT, allow entry of multiple check digits.
     *        Will no longer need Screen2 for single check digit entry.
     *      - Pare down error messages so they will fit within
     *        the 20 char screen size.
520 A*    03/05/08  RBD  5.20
     *      - Revised logic for 'Verify' option.  Rather than requiring
     *        the user to enter the check digits for verification, the
     *        check digits will be displayed for viewing only.
640a *    06/21/12  LMC  6.40a
     *      - Enh:  Allow verification of client's with 5 numeric
     *        check digit.
     *
640b *    06/27/12  LMC  6.40b
     *      - Enh:  Allow verification for client with 9 digit barcode
640c *    07/10/12  LMC  6.40c
     *      - Fix:  Losing leading zeros on check digit
     *
740 A*    04/03/20  MLB  7.40
     *      - Fix:  Revised ZZFILL3 to correct record lock on SLOTDGT,
     *        SLOTDGTA. Issue from 5.20 mod.
740aA*    08/18/20  LMC  7.40a
     *      - Enh:  Allow for the entry of  UPCOVERRIDE in the slot
     *        field, to accomodate a supervisor approval on skipping
     *        the upc verification.
     *
     *----------------------------------------------------------------
     *  Client Custom changes - City Wholesale
     *----------------------------------------------------------------
CTWaA*    08/20/08  HNK  CTWa
     *      - Disable call to APICVTSLT
     *
     *----------------------------------------------------------------
     *  Client Custom changes - Presto
     *----------------------------------------------------------------
PFCa *    11/09/14  GJA  PFCa
     *      - Disable call to APICVTSLT
PFCb *    01/27/16  GJA  PFCb
     *      - Enable call to APICVTSLT
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *  This program allows a user to enter or verify check digits
     *  for slots.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
640bA*  92        Auto record advance on 9 pos check digit
640aA*  93        Auto record advance on 5 pos check digit
510 A*  94        Auto record advance on 2nd check digit
510 A*  95        Auto record advance on 1st check digit
510 A* N94N95     Auto record advance on 3rd check digit
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640aDF*scd100fm  cf   e             workstn
640bDF*scd10001  cf   e             workstn
640bMFscd10002  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslotdgt   uf a e           k disk
510 AFslotdgta  uf a e           k disk
     Fslot2     if   e           k disk
     Fpiruser   if   e           k disk
510 AFoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
510 DD*desc            s             20    dim(4) ctdata perrcd(1)
510 MD desc            s             20    dim(7) ctdata perrcd(1)

CTWaA*----------------------------------------------------------------
CTWaA*  Client id's for custom mods.
CTWaA*----------------------------------------------------------------

CTWaAD/copy qcopysrc,id#citywho
PFCaAD/copy qcopysrc,id#pfc

CTWaAD client          s             10

     *----------------------------------------------------------------
510 A*  *CHKDGT  -  Check digit options.
     *----------------------------------------------------------------
     *
510 A* Fields
     *
510 A*    OPCOD#  -  Number of check digit codes per slot (1,2,3)
510 A*    OPDGT#  -  Number of digits per code  (2,3)
510 A*    OPIDC1  -  Code 1 identifier
510 A*    OPIDC2  -  Code 2 identifier
510 A*    OPUNU2  -  Unused
510 A*    OPIDC3  -  Code 3 identifier
510 A*    OPUNU3  -  Unused
510 A*    OPIDD1  -  Digit 1 identifier
510 A*    OPIDD2  -  Digit 2 identifier
510 A*    OPIDD3  -  Digit 3 identifier
510 A*    OPRCOD  -  Current code to read (S=Single,R=Random)
510 A*    OPRCD1  -  Use code 1 for current reading (Y,N)
510 A*    OPRCD2  -  Use code 2 for current reading (Y,N)
510 A*    OPRCD3  -  Use code 3 for current reading (Y,N)
510 A*    OPRORD  -  Current read order (S=Single, R=Random)
510 A*    OPRLCR  -  Use read order Left/Center/Right (Y,N)
510 A*    OPRRCL  -  Use read order Right/Center/Left (Y,N)
510 A*    OPRLRC  -  Use read order Left/Right/Center (Y,N)
510 A*    OPRRLC  -  Use read order Right/Left/Center (Y,N)
510 A*    OPRCLR  -  Use read order Cener/Left/Right  (Y,N)
510 A*    OPRCRL  -  Use read order Cener/Right/Left  (Y,N)
640aA*    OPREAD  -  Number of digits user reads for codes
640aA*               less than 100.
640aA*    OP5NUM  -  Barcode Size - 2,3,5 or 9
510 A*
510 A* Data structure
510 A*
510 AD opdata          ds
510 AD  opcod#                 1      1  0
510 AD  opdgt#                 2      2  0
510 AD  opidc1                 3      8
510 AD  opidc2                 9     14
510 AD  opunu2                15     16
510 AD  opidc3                17     22
510 AD  opunu3                23     24
510 AD  opidd1                25     30
510 AD  opidd2                31     36
510 AD  opidd3                37     42
510 AD  oprcod                43     43
510 AD  oprcd1                44     44
510 AD  oprcd2                45     45
510 AD  oprcd3                46     46
510 AD  oprord                47     47
510 AD  oprlcr                48     48
510 AD  oprrcl                49     49
510 AD  oprlrc                50     50
510 AD  oprrlc                51     51
510 AD  oprclr                52     52
510 AD  oprcrl                53     53
640aAD  opread                54     54  0
640aAD  opreada               54     54
640aAD  op5num                55     55
510 AD  optend               117    117
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *----------------------------------------------------------------
     * Data structure
     *
510 DD*opdata          ds
510 MD opdat1          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
510 DD**optend               117    117
510 MD  optend_1             117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjtd          c                   const('ADJTSKDET')
     D @addtr          c                   const('ADDSTDTRN')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     D  $lmput                89     89
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $ltrn1                19     25  0
     *
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
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
417 A*----------------------------------------------------------------
417 A*  API programs
417 A*
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     *
     D  ertrn#                 1      4p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgfc          c                   const('QCPFMSG   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
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
     D hlddgt          s              3  0
510 AD hlddgt1         s              3  0
510 AD hlddgt2         s              3  0
510 AD hlddgt3         s              3  0
640aAD hlddgt5         s              5  0
640bAD hlddgt9         s              9  0
510 AD hlddgt1_ver     s              3  0
510 AD hlddgt2_ver     s              3  0
510 AD hlddgt3_ver     s              3  0
640aAD hlddgt5_ver     s              5  0
640bAD hlddgt9_ver     s              9  0
     D hlddsp          s             12
510 AD hlddsp_ver      s             12
520 AD lstscr          s              3
     D msgk            s              4  0
     D nxtscr          s              3
     D onedgt          s              3  0
     D onedsp          s             12
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D temp2a          s              3
     D today           s              8  0
     D warn            s              1
     D w1crew          s                   like(uscrew)
     D w1emp#          s                   like(usemp#)
     D w1shft          s                   like(usshft)
     D w1styp          s                   like(usstyp)
640aAD wk5a            s              3
640aAD wk5b            s              3
640aAD wk5c            s              5
640aAD wk51            s              3
640aAD wk52            s              3
640aAD wk53            s              3
640bAD wk9c            s              9
640bAD wk91            s              3
640bAD wk92            s              3
640bAD wk93            s              3
510 AD wXdsp           s             12
740aAD nowhdp          s              5
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
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
510 AC     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
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
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
510 AC                   if        nxtscr = '03 '
520 AC                   if        w1mode = '2'
520 AC                             and *inki = *off
520 AC                             and lstscr = '03 '
520 AC                   exsr      scr03i
520 AC                   endif
510 AC                   exfmt     screen3                              50
520 AC                   eval      lstscr = '03 '
510 AC                   endif
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
     *R                   SETOF                     333435
     C                   setoff                                       3334
     C                   setoff                                       363738
     C                   setoff                                       3940
     **                   SETOF                     98
640bdC*                  setoff                                       9298
640bMC                   setoff                                         98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
414 AC                   eval      redspl = *off
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
     C                   eval      *in03 = *on
     C                   eval      nxtscr = '01 '
     C                   eval      w1mode = *blanks
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in04 = *on
     C                   eval      w2dgt = *zeros
     C                   eval      w2dsp = *blanks
     C                   eval      w2err = *blanks
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
510 A*  Screen 03 initialization
510 A*
510 AC     scr03i        begsr
520 AC                   eval      lstscr = nxtscr
     C                   eval      nxtscr = '03 '
     C                   eval      *in11 = *on
520 AC                   if        lstscr = '01 '
     C                   eval      w3dsp = *blanks
520 AC                   endif
     C                   eval      w3dgt1 = 0
     C                   eval      w3dgt2 = 0
     C                   eval      w3dgt3 = 0
640aAC                   eval      w3dgt5 = 0
640bAC                   eval      w3dgt9 = 0
     C                   eval      w3err = *blanks
520 DC**                 exsr      zzfil2
520 MC                   exsr      zzfil3
     C                   endsr
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
     C                   if        *inkc  or
417 AC                             *inkl
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
     C                   exsr      zzchk1
     *
     C                   if        error = *off
     C                   exsr      zzupd1
510 DC**                 eval      nxtscr = '02 '
     C                   endif
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc  or
417 AC                             *inkl
     C                   eval      nxtscr = '01 '
     C                   eval      *in03 = *on
     C                   eval      w1mode = *blanks
     C                   goto      endsc2
     C                   endif
     C                   exsr      zzcmd2
     C                   exsr      zzchk2
     *
417 AC     redspl        cabeq     *on           endsc2
     C                   if        error = *off
     C                   exsr      zzupd2
     C                   endif
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
510 A*  SC3  -  Screen 3
     *
510 AC     sc3           begsr
     *
510 A*  Test for F3 - Exit
     *
510 AC                   if        *inkc = *on or
510 AC                             *inkl = *on
510 AC                   eval      nxtscr = '01 '
510 AC                   eval      *in03 = *on
510 AC                   eval      w1mode = *blanks
510 AC                   goto      endsc3
510 AC                   endif
510 AC                   exsr      zzcmd3
510 AC     *inki         cabeq     *on           endsc3
510 AC                   exsr      zzchk3
     *
510 AC     redspl        cabeq     *on           endsc3
510 AC                   if        error = *off
510 AC                   exsr      zzupd3
510 AC                   endif
     *
510 AC     endsc3        endsr
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
CTWaA
CTWaAC                   call      'GETCLIENT'
CTWaAC                   parm                    client
CTWaA
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
     *--------------------------------------------------------------
     *
     *  SUBROUTINE ZZCMD2  Non Standard Command Key Requests
     *
     C     zzcmd2        begsr
     *
     *  Test for F9 - Last
     *
     C                   if        *inki
     *
     *  Move in last good Slot and Check Digit scanned
     *
     C                   if        hlddsp = *blanks
     C                   eval      w2dsp = onedsp
     C                   movel     onedgt        w2dgt
     C                   eval      w2err = *blanks
     C                   else
     C                   eval      w2dsp = hlddsp
     C                   movel     hlddgt        w2dgt
     C                   eval      w2err = *blanks
     C                   eval      nxtscr = '02 '
     C                   endif
     C                   endif
     *
     C                   endsr
     *---------------------------------------------------------------
     *
510 A*  SUBROUTINE ZZCMD3  Non Standard Command Key Requests
     *
510 AC     zzcmd3        begsr
     *
510 A*  Test for F9 - Last
     *
510 AC                   if        *inki = *on
510 AC                   eval      w3err = *blanks
510 AC                   eval      nxtscr = '03 '
510 A*  Move in last good Slot and Check Digit/s scanned

510 AC                   if        w1mode = '1'
510 AC                   eval      w3dsp = hlddsp
510 AC                   movel     hlddgt1       w3dgt1
510 AC                   movel     hlddgt2       w3dgt2
510 AC                   movel     hlddgt3       w3dgt3
640aAC                   movel     hlddgt5       w3dgt5
640bAC                   movel     hlddgt9       w3dgt9
510 AC                   else
510 AC                   eval      w3dsp = hlddsp_ver
510 AC                   movel     hlddgt1_ver   w3dgt1
510 AC                   movel     hlddgt2_ver   w3dgt2
510 AC                   movel     hlddgt3_ver   w3dgt3
640aAC                   movel     hlddgt5_ver   w3dgt5
640bAC                   movel     hlddgt9_ver   w3dgt9
510 AC                   endif

510 AC                   endif
     *
510 AC                   endsr
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
     *    ZMPCPF  Add CPF message record to subfile
     *
     C     zmpcpf        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgfc
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
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   CPF9898  Generic error message
     *
     C     zm9898        begsr
     C                   eval      #msgid = 'CPF9898'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpcpf
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
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   LP11022  Invalid license number.
     *
     C     zm1022        begsr
     C                   eval      #msgid = 'LP11022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20001  Invalid slot entered.(TO)
     *
     C     zm2001        begsr
     C                   eval      #msgid = 'RC20001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20002 Transaction is closed.
     *
     C     zm2002        begsr
     C                   eval      #msgid = 'RC20002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20003 Quantity must be > 0.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'RC20003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20004 Quantity can't be > quantity to put away.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'RC20004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500a *----------------------------------------------------------------
500aA*    PIR0203  Value cannot be blank.
500a *
500a C     zm0203        begsr
500a C                   eval      #msgid = 'PIR0203'
500a C                   eval      #msgtp = '*DIAG  '
500a C                   movea     errmsg        $md
500a C                   exsr      zmpmsg
500a C                   endsr
     *----------------------------------------------------------------
     *   PIR0204  Enter only one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm0205        begsr
     C                   eval      #msgid = 'PIR0205'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
500a *----------------------------------------------------------------
500aA*    PIR0206  Value cannot be ......
500a *
500a C     zm0206        begsr
500a C                   eval      #msgid = 'PIR0206'
500a C                   eval      #msgtp = '*DIAG  '
500a C                   movea     errmsg        $md
500a C                   exsr      zmpmsg
500a C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   eval      #msgid = 'IT15204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25201  Date sensitive item exists in to slot with dif dte
     *
     C     zm2521        begsr
     C                   eval      #msgid = 'IT25201'
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Warn of invalid mode selected
     *
     C                   if        w1mode <> '1'  and
     C                             w1mode <> '2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
500a C                   eval      errmsg = *blanks
500a C                   movel     desc(1)       errmsg
510 DC**                 exsr      zm1001
510 MC                   exsr      zm0105
500aD**                   GOTO ENDCK1
     C                   endif
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
500aAC                   if        $lrtn = '*ERROR  '
500a C                   eval      error = *on
500a C                   eval      *in22 = *on
500a C                   eval      *in02 = *on
510 AC                   eval      errmsg = *blanks
510 DC**                 movel     $lerm         errmsg
510 MC                   movel     desc(6)       errmsg
500a C                   exsr      zm0105
500a C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
500a C                   eval      #msgk = $lmsg
500a C                   exsr      zmqmsg
500a C                   endif
500aD**                   GOTO ENDCK1
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   if        w1whdp <> '*ALL '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
500aAC                   if        $lrtn = '*ERROR  '
500a C                   eval      error = *on
500a C                   eval      *in23 = *on
500a C                   eval      *in03 = *on
510 AC                   eval      errmsg = *blanks
510 DC**                 movel     $lerm         errmsg
510 MC                   movel     desc(7)       errmsg
500a C                   exsr      zm0105
500a C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
500a C                   eval      #msgk = $lmsg
500a C                   exsr      zmqmsg
500a C                   endif
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
740aAc                   if        W2DSP <> 'UPCOVERRIDE'
417 A*
417 A*  Call API for slot.
417 A*
CTWaAC                   if        client <> citywho
PFCaAC***PFCb                      client <> presto
740
417 AC                   call      @apics
417 AC                   parm                    w2dsp
417 AC                   parm      4             worow
417 AC                   parm      9             wocol
417 AC                   parm                    @artn             8
417 AC                   if        @artn = '*REDSPLY'
417 AC                   eval      redspl = *on
500aD**                   GOTO ENDCK2
417 AC                   endif
CTWaAC                   endif
740aAC                   endif
     *
     *  Verify Slot entered on screen 2
     *
740AaC                   if        w2dsp <> 'UPCOVERRIDE'
510 AC                   eval      wXdsp = w2dsp
     C     sltky         chain     slot2                              99
     C                   if        *in99
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
500a C                   eval      errmsg = *blanks
500a C                   movel     desc(2)       errmsg
510 DC**                 exsr      zm0203
510 MC                   exsr      zm0105
500aD**                   GOTO ENDCK2
     C                   endif
740aAC                   endif
     *
     *  Check Digit cannot be Zero
     *
417  C                   if        w1mode = '1'  and
417 MC                             w2dgt = *zeros
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
500a C                   eval      errmsg = *blanks
500a C                   movel     desc(3)       errmsg
510 DC**                 exsr      zm0203
510 MC                   exsr      zm0105
     C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
510 A*  ZZCHK3   Screen 3 error checking.
     *
510 AC     zzchk3        begsr
510 AC                   eval      error = *off
740aAc                   if        W3DSP <> 'UPCOVERRIDE'
510 A*
510 A*  Call API for slot.
510 A*
PFCaAC*PFCb              if        client <> presto
510 AC                   call      @apics
510 AC                   parm                    w3dsp
510 AC                   parm      4             worow
510 AC                   parm      9             wocol
510 AC                   parm                    @artn             8
510 AC                   if        @artn = '*REDSPLY'
510 AC                   eval      redspl = *on
510 AC                   endif
PFCaAC**PFGb             endif
740aAC                   endif
     *
510 A*  Verify Slot entered on screen 3
     *
740AaC                   if        w3dsp <> 'UPCOVERRIDE'
510 AC                   eval      wXdsp = w3dsp
510 AC     sltky         chain     slot2                              99
510 AC                   if        *in99 = *on
510 AC                   eval      error = *on
510 AC                   eval      *in31 = *on
510 AC                   eval      *in11 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(2)       errmsg
510 AC                   exsr      zm0105
510 AC                   endif
740aAC                   endif
     *
510 A*  If OPCOD# = 2, check digits 1 and 2 must be greater than zero,
510 A*                 and check digit 3 must be zero.
510 A*  If OPCOD# = 3, check digits 1, 2 and 3 must be greater than zero.
510 A*  If OPDGT# = 2, check digits cannot be greater than 99.
     *
510 AC                   select

510 AC                   when      w1mode = '1' and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt1 = 0
510 AC                   eval      error = *on
510 AC                   eval      *in26 = *on
510 AC                   eval      *in06 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(3)       errmsg
510 AC                   exsr      zm0105

510 AC                   when      w1mode = '1' and
510 AC                             opdgt# = 2   and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt1 > 99
510 AC                   eval      error = *on
510 AC                   eval      *in26 = *on
510 AC                   eval      *in06 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(4)       errmsg
510 AC                   exsr      zm0105

510 AC                   when      w1mode = '1' and
510 AC                             opcod# > 1   and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt2 = 0
510 AC                   eval      error = *on
510 AC                   eval      *in27 = *on
510 AC                   eval      *in07 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(3)       errmsg
510 AC                   exsr      zm0105

510 AC                   when      w1mode = '1' and
510 AC                             opcod# > 1   and
510 AC                             opdgt# = 2   and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt2 > 99
510 AC                   eval      error = *on
510 AC                   eval      *in27 = *on
510 AC                   eval      *in07 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(4)       errmsg
510 AC                   exsr      zm0105

510 AC                   when      w1mode = '1' and
510 AC                             opcod# = 3   and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt3 = 0
510 AC                   eval      error = *on
510 AC                   eval      *in28 = *on
510 AC                   eval      *in08 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(3)       errmsg
510 AC                   exsr      zm0105

510 AC                   when      w1mode = '1' and
510 AC                             opcod# = 3   and
510 AC                             opdgt# = 2   and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt3 > 99
510 AC                   eval      error = *on
510 AC                   eval      *in28 = *on
510 AC                   eval      *in08 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(4)       errmsg
510 AC                   exsr      zm0105

510 AC                   when      w1mode = '1' and
510 AC                             opcod# = 2   and
640bDc*                            op5num <> 'Y' and
640bMc                             op5num <> '5' and op5num <> '9' and
510 AC                             w3dgt3 <> 0
510 AC                   eval      error = *on
510 AC                   eval      *in28 = *on
510 AC                   eval      *in08 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(5)       errmsg
510 AC                   exsr      zm0105

640aAC                   when      w1mode = '1' and
640bDc*                            op5num = 'Y' and
640bMc                             op5num = '5' and
640aAC                             w3dgt5 = 0
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(3)       errmsg
640aAC                   exsr      zm0105

640bAC                   when      w1mode = '1' and
640bAc                             op5num = '9' and
640bAC                             w3dgt9 = 0
640bAC                   eval      error = *on
640bAC                   eval      *in30 = *on
640bAC                   eval      *in10 = *on
640bAC                   eval      errmsg = *blanks
640bAC                   movel     desc(3)       errmsg
640bAC                   exsr      zm0105

510 AC                   endsl
     *
510 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1mode = ' '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Set proper heading
     *
     C                   if        w1mode = '1'
     C                   eval      wmodsc = 'Entry '
510 AC                   eval      *in96 = *on
     C                   else
     C                   eval      wmodsc = 'Verify'
510 AC                   eval      *in96 = *off
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
520 A*  ZZFIL3   Fill screen 3 fields with info from files.
520 A*
520 AC     zzfil3        begsr
     *
     *   Set proper heading.
     *   If verify mode and slot has been entered, get check digits
     *   for display.
     *
     C                   if        w1mode = '1'
     C                   eval      wmodsc = 'Entry '
     C                   eval      *in96 = *on
     C                   else
     C                   eval      wmodsc = 'Verify'
     C                   eval      *in96 = *off
     C                   if        lstscr = '03 '
740 DC*    sltkey        chain     slotdgt
740 MC     sltkey        chain (n) slotdgt
     C                   if        %found(slotdgt)
     C                   eval      w3dgt1 = scddgt
     C                   endif
740 DC*    sltkey        chain     slotdgta
740 MC     sltkey        chain (n) slotdgta
     C                   if        %found(slotdgta)
     C                   eval      w3dgt2 = scddgt2
     C                   eval      w3dgt3 = scddgt3
     C                   endif
640bDC*                  if        %found(slotdgta) and op5num = 'Y'
640bMC                   if        %found(slotdgta) and op5num = '5'
640cDc*                  eval      wk5a = %char(scddgt)
640cDc*                  eval      wk5b = %char(scddgt3)
640cMc                   eval      wk5a =  %Trim(%EditC(scddgt:'X'))
640cMc                   eval      wk5b =  %Trim(%EditC(scddgt3:'X'))
640bAc                   eval      wk5c = wk5a + %subst(wk5b:2:2)
640aAc                   move      wk5c          w3dgt5
640aAC                   endif
640bAC                   if        %found(slotdgta) and op5num = '9'
640cDc*                  eval      wk9c = %char(scddgt) +
640cDc*                                   %char(scddgt2)+
640cDc*                                   %char(scddgt3)
640cMc                   eval      wk9c =  %Trim(%EditC(scddgt:'X')) +
640cMc                                     %Trim(%EditC(scddgt2:'X')) +
640cMc                                     %Trim(%EditC(scddgt3:'X'))
640bAc                   move      wk9c          w3dgt9
640bAC                   endif
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      $lwhse = #whse
     *
     *    - Get employee number, default dept and section.
     *
     C     uskey         klist
     C                   kfld                    #user
     *
     C     uskey         chain     piruser                            79
     C                   if        not *in79
     C                   eval      w1emp# = usemp#
     C                   eval      w1whdp = uswhdp
     C                   eval      w1styp = usstyp
     C                   eval      w1shft = usshft
     C                   eval      w1crew = uscrew
     C                   else
     C                   eval      w1emp# = 0
     C                   eval      w1whdp = *blanks
     C                   eval      w1styp = *blanks
     C                   eval      w1shft = *blanks
     C                   eval      w1crew = *blanks
     C                   endif
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      $lwhdp = w1whdp
     C                   eval      w1whse = #whse
     C                   eval      w1whdp = uswhdp
     *
510 A*  Define key for OPTIONS file with whse
     *
510 AC     opkey_whse    klist
510 AC                   kfld                    $lwhse
510 AC                   kfld                    opcode
     *
510 A*  Get check digit options.
     *
510 AC                   eval      opcode = '*CHKDGT '
510 AC     opkey_whse    chain     options
510 AC                   select

510 AC                   when      not %found(options)
510 AC                   eval      *in95 = *on
510 AC                   eval      opcod# = 1
510 AC                   eval      opdgt# = 0
510 AC                   eval      w3idc1 = 'Ck Dig'

640bDC*                  when      op5num = 'Y'
640bMC                   when      op5num = '5'
640aAC                   eval      *in93 = *on
640aAC                   eval      w3idc5 = 'Check5'

640bAC                   when      op5num = '9'
640bAC                   eval      *in92 = *on
640bAC                   eval      w3idc9 = 'Check9'

510 AC                   when      opcod# = 1
510 AC                   eval      *in95 = *on
510 AC                   eval      w3idc1 = 'Ck Dig'

510 AC                   when      opcod# = 2
510 AC                   eval      *in94 = *on
510 AC                   eval      w3idc1 = opidc1
510 AC                   eval      w3idc2 = opidc2

510 AC                   when      opcod# = 3
510 AC                   eval      w3idc1 = opidc1
510 AC                   eval      w3idc2 = opidc2
510 AC                   eval      w3idc3 = opidc3

510 AC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
417 AC                   eval      worow = 0
417 AC                   eval      wocol = 0
     *    Slot Check Digit Key List
     C     sltkey        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
510 MC**                 kfld                    w2dsp
510 AC                   kfld                    wXdsp

740aAC     sltkeyu       klist
740aAC                   kfld                    $lwhse
740aAC                   kfld                    nowhdp
740aAC                   kfld                    wXdsp

     *    Slot logical to verify entered slot
     C     sltky         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
510 MC**                 kfld                    w2dsp
510 AC                   kfld                    wXdsp
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
510 DC**                 exsr      scr02i
510 MC                   exsr      scr03i
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *   Update or Write record to Check Digit File
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
510 AC                   eval      wXdsp = w2dsp
     C     sltkey        chain     slotdgt                            55
     *
     *  Write/Update for entry mode
     *
     C                   if        w1mode = '1'
     C                   eval      hlddsp = w2dsp
     C                   movel     w2dgt         hlddgt
     C                   eval      scdaby = uscode
     C                   eval      scdadt = today
     C                   time                    scdatm
510 AC                   eval      scdvby = *blanks
510 AC                   eval      scdvdt = 0
510 AC                   eval      scdvtm = 0
     C                   if        *in55
     C                   eval      scdwhs = $lwhse
     C                   eval      scdwhd = $lwhdp
     C                   eval      scddsp = w2dsp
     C                   eval      scddgt = w2dgt
     C                   write     scdrec
     C                   else
     C                   eval      scddgt = w2dgt
     C                   update    scdrec
     C                   endif
500bD*                    MOVE W2DGT     TEMP2A  2
500bMC                   move      w2dgt         temp2a
417 AC                   eval      errmsg = *blanks
417 AC     w2dsp         cat       '/':0         errmsg
417 AC     errmsg        cat       temp2a:0      errmsg
417 AC     errmsg        cat       'Creat':1     errmsg
417 AC     errmsg        cat       'ed':0        errmsg
417 AC                   exsr      zm0105
     C                   endif
     *
     *  Verify entry mode
     *
     C                   if        w1mode = '2'
     C                   eval      scdvby = uscode
     C                   eval      scdvdt = today
     C                   time                    scdvtm
417  C**510 D            eval      w2dgt = scddgt
     C                   if        *in55  or
     C                             w2dgt <> scddgt
510 AC                   eval      *in25 = *on
510 AC                   eval      *in05 = *on
     C                   eval      w2err = 'INVALID'
     C                   else
     C                   eval      w2err = 'OK     '
     C                   update    scdrec
     C                   endif
     C                   endif
     *
     **  GOTO Update/Write Check Digit record
     *
     C                   eval      hlddsp = onedsp
     C                   eval      hlddgt = onedgt
     C                   eval      onedsp = w2dsp
     C                   movel     w2dgt         onedgt
     *
417  C                   if        w1mode = '1'
417  C                   eval      w2dsp = *blanks
417  C                   eval      w2dgt = 0
417  C                   endif
     *
     C     endup2        endsr
     *
     *-------------------------------------------------------------------------
     *
510 A*  ZZUPD3   Update for screen 3.
510 A*
510 AC     zzupd3        begsr
     C                   eval      error = *off
     *
     *   Update or Write record to Check Digit File/s
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  SLOTDGT, Check Digit 1, Write/Update for entry mode
     *
640bDc*                  if        op5num = 'Y'
640bMc                   if        op5num = '5'
640aAC                   movel     w3dgt5        hlddgt5
640cDC*                  eval      wk5c = %char(w3dgt5)
640cMC                   eval      wk5c =  %Trim(%EditC(w3dgt5:'X'))
640aAc                   eval      wk51 = %subst(wk5c:1:3)
640aAc                   eval      wk52 = %subst(wk5c:2:3)
640aAc                   eval      wk53 = %subst(wk5c:3:3)
640aAc                   endif
640bAc                   if        op5num = '9'
640bAC                   movel     w3dgt9        hlddgt9
640cDC*                  eval      wk9c = %char(w3dgt9)
640cMC                   eval      wk9c =  %Trim(%EditC(w3dgt9:'X'))
640bAc                   eval      wk91 = %subst(wk9c:1:3)
640bAc                   eval      wk92 = %subst(wk9c:4:3)
640bAc                   eval      wk93 = %subst(wk9c:7:3)
640bAc                   endif

     C                   eval      wXdsp = w3dsp
740aAC                   if        w3dsp = 'UPCOVERRIDE'
740aAc                   eval      nowhdp = ' '
740aAC     sltkeyu       chain     slotdgt                            55
740aAC                   else
     C     sltkey        chain     slotdgt                            55
740aAC                   endif
     C                   if        w1mode = '1'
     C                   eval      hlddsp = w3dsp
640bAc                   select
640bDc*                  if        op5num = 'Y'
640bMc                   when      op5num = '5'
640aAC                   movel     wk51          scddgt
640bAc                   when      op5num = '9'
640aAC                   movel     wk91          scddgt
640bDc*                  else
640bMc                   other
     C                   movel     w3dgt1        hlddgt1
     C                   eval      scddgt = w3dgt1
640bDc*                  endif
640bMc                   endsl
     C                   eval      scdaby = uscode
     C                   eval      scdadt = today
     C                   time                    scdatm
     C                   eval      scdvby = *blanks
     C                   eval      scdvdt = 0
     C                   eval      scdvtm = 0
     C                   if        *in55  = *on
     C                   eval      scdwhs = $lwhse
740aAc                   if        w3dsp = 'UPCOVERRIDE'
740aAc                   eval      scdwhd = nowhdp
740aAc                   else
     C                   eval      scdwhd = $lwhdp
740aAc                   endif
     C                   eval      scddsp = w3dsp
     C                   write     scdrec
     C                   else
     C                   update    scdrec
     C                   endif
640bAc                   select
640bDc*                  if        op5num = 'Y'
640bMc                   when      op5num = '5'
640aAC                   movel     wk51          temp2a
640bAc                   when      op5num = '9'
640bAC                   movel     wk91          temp2a
640bDc*                  else
640bMc                   other
     C                   move      w3dgt1        temp2a
640bDc*                  endif
640bMc                   endsl
     C                   eval      errmsg = *blanks
     C     w3dsp         cat       '/':0         errmsg
     C     errmsg        cat       temp2a:0      errmsg
     C     errmsg        cat       'Creat':1     errmsg
     C     errmsg        cat       'ed':0        errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *  SLOTDGTA, Check Digits 2 and 3, Write/Update for entry mode
     *
     C                   eval      wXdsp = w3dsp
740aAC                   if        w3dsp = 'UPCOVERRIDE'
740aAc                   eval      nowhdp = ' '
740aAC     sltkeyu       chain     slotdgta                           55
740aAC                   else
     C     sltkey        chain     slotdgta                           55
740aAC                   endif
     C                   if        w1mode = '1' and opcod# > 1
     C                   eval      hlddsp = w3dsp
640bAc                   select
640bDC*                  if        op5num = 'Y'
640bMC                   when      op5num = '5'
640aAc                   movel     wk52          scddgt2
640bAC                   when      op5num = '9'
640bAc                   movel     wk92          scddgt2
640bDc*                  else
640bMc                   other
     C                   eval      hlddgt2 = w3dgt2
     C                   eval      scddgt2 = w3dgt2
640bDc*                  endif
640bMc                   endsl
     C                   eval      scdaby2 = uscode
     C                   eval      scdadt2 = today
     C                   time                    scdatm2
     C                   eval      scdvby2 = *blanks
     C                   eval      scdvdt2 = 0
     C                   eval      scdvtm2 = 0
640bAc                   select
640bDc*                  if        op5num = 'Y'
640bMc                   when      op5num = '5'
640aAc                   movel     wk53          scddgt3
640bAc                   when      op5num = '9'
640bAc                   movel     wk93          scddgt3
640bDc*                  else
640bMc                   other
     C                   eval      hlddgt3 = w3dgt3
     C                   eval      scddgt3 = w3dgt3
640bDc*                  endif
640bMc                   endsl
     C                   eval      scdaby3 = uscode
     C                   eval      scdadt3 = today
     C                   time                    scdatm3
     C                   eval      scdvby3 = *blanks
     C                   eval      scdvdt3 = 0
     C                   eval      scdvtm3 = 0
640bDc*                  if        op5num <> 'Y'
640bMc                   if        op5num <> '5' and op5num <> '9'
     C                   if        w3dgt3 = 0
     C                   eval      scdaby3 = *blanks
     C                   eval      scdadt3 = 0
     C                   eval      scdatm3 = 0
     C                   eval      scddgt3 = 0
     C                   endif
640aAC                   endif
     C                   if        *in55   = *on
     C                   eval      scdwhsa = $lwhse
740aAc                   if        w3dsp = 'UPCOVERRIDE'
740aAc                   eval      scdwhda = nowhdp
740aAc                   else
     C                   eval      scdwhda = $lwhdp
740aAC                   endif
     C                   eval      scddspa = w3dsp
640bAc                   select
640bDc*                  if        op5num  = 'Y'
640bMc                   when      op5num  = '5'
640aAc                   move      wk52          scddgt2
640bAc                   when      op5num  = '9'
640bAc                   move      wk92          scddgt2
640bDc*                  else
640bMc                   other
     C                   eval      scddgt2 = w3dgt2
640bDc*                  endif
640bMc                   endsl
     C                   write     scdreca
     C                   else
     C                   update    scdreca
     C                   endif

640bAc                   select
640bDc*                  if        op5num = 'Y'
640bMc                   when      op5num = '5'
640bAc                   movel     wk52          temp2a
640bAc                   when      op5num = '9'
640bAc                   movel     wk92          temp2a
640bDc*                  else
640bMc                   other
     C                   move      w3dgt2        temp2a
640bDc*                  endif
640bMc                   endsl
     C                   eval      errmsg = *blanks
     C     w3dsp         cat       '/':0         errmsg
     C     errmsg        cat       temp2a:0      errmsg
     C     errmsg        cat       'Creat':1     errmsg
     C     errmsg        cat       'ed':0        errmsg
     C                   exsr      zm0105

     C                   if        opcod# = 3
640bAc                   select
640bDc*                  if        op5num  = 'Y'
640bMc                   when      op5num  = '5'
640aAc                   move      wk53          temp2a
640bAc                   when      op5num  = '9'
640bAc                   move      wk93          temp2a
640bDc*                  else
640bMc                   other
     C                   move      w3dgt3        temp2a
640bDc*                  endif
640bMc                   endsl
     C                   eval      errmsg = *blanks
     C     w3dsp         cat       '/':0         errmsg
     C     errmsg        cat       temp2a:0      errmsg
     C     errmsg        cat       'Creat':1     errmsg
     C     errmsg        cat       'ed':0        errmsg
     C                   exsr      zm0105
     C                   endif

     C                   endif
     *
     *  Verify entry mode
     *
     C                   if        w1mode = '2'
520 DC**                 call      'GETCHKDGT'
520 DC**                 parm                    $pCmd             8
520 DC**                 parm      w1whse        $pWhse            3 0
520 DC**                 parm      w1whdp        $pWhdp            5
520 DC**                 parm      w3dsp         $pSlot           12
520 DC**                 parm                    $pCodes           1 0
520 DC**                 parm                    $pDigits          1 0
520 DC**                 parm                    $pOrderType       1
520 DC**                 parm                    $pOrder1          6
520 DC**                 parm                    $pOrder2          6
520 DC**                 parm                    $pOrder3          6
520 DC**                 parm                    $pCodeType        1
520 DC**                 parm                    $pCode            6
520 DC**                 parm                    $pChkDigit        3 0
520 DC**                 parm                    $pReturn         10
520 DC**                 if        $pReturn = '*OK' or
520 DC**                           $pReturn = '*OPTNOTFND'

     **  Determine which check digit is returned, scddgt, scddgt2, or scddgt3
     **  and update it's verified fields, else, hilite check digit in error.
520 DC**                 select

520 DC**                 when      $pCode = w3idc1 or
520 DC**                           opcod# = 1 or
520 DC**                           $pReturn = '*OPTNOTFND'
520 DC**                 if        %found(slotdgt) and
520 DC**                           $pChkDigit = w3dgt1
520 DC**                 eval      scdvby = uscode
520 DC**                 eval      scdvdt = today
520 DC**                 time                    scdvtm
520 DC**                 update    scdrec
520 DC**                 eval      w3err = 'OK     '
520 DC**                 else
520 DC**                 eval      *in06 = *on
520 DC**                 eval      *in26 = *on
520 DC**                 eval      w3err = 'INVALID'
520 DC**                 endif

520 DC**                 when      $pCode = w3idc2
520 DC**                 if        %found(slotdgta) and
520 DC**                           $pChkDigit = w3dgt2
520 DC**                 eval      scdvby2 = uscode
520 DC**                 eval      scdvdt2 = today
520 DC**                 time                    scdvtm2
520 DC**                 update    scdreca
520 DC**                 eval      w3err = 'OK     '
520 DC**                 else
520 DC**                 eval      *in07 = *on
520 DC**                 eval      *in27 = *on
520 DC**                 eval      w3err = 'INVALID'
520 DC**                 endif

520 DC**                 when      $pCode = w3idc3
520 DC**                 if        %found(slotdgta) and
520 DC**                           $pChkDigit = w3dgt3
520 DC**                 eval      scdvby3 = uscode
520 DC**                 eval      scdvdt3 = today
520 DC**                 time                    scdvtm3
520 DC**                 update    scdreca
520 DC**                 eval      w3err = 'OK     '
520 DC**                 else
520 DC**                 eval      *in08 = *on
520 DC**                 eval      *in28 = *on
520 DC**                 eval      w3err = 'INVALID'
520 DC**                 endif

520 DC**                 other
520 DC**                 eval      *in06 = *on
520 DC**                 eval      *in26 = *on
520 DC**                 eval      *in27 = *on
520 DC**                 eval      *in28 = *on
520 DC**                 eval      w3err = 'INVALID'

520 DC**                 endsl

520 DC**                 else
520 DC**                 eval      w3err = 'INVALID'
520 DC**                 endif
     *
520 A*  Update slotdgt verify fields
     *
520 AC                   if        %found(slotdgt)
520 AC                   eval      scdvby = uscode
520 AC                   eval      scdvdt = today
520 AC                   time                    scdvtm
520 AC                   update    scdrec
520 AC                   endif
     *
520 A*  Update slotdgta verify fields
     *
520 AC                   if        %found(slotdgta)
520 AC                   eval      scdvby2 = uscode
520 AC                   eval      scdvdt2 = today
520 AC                   time                    scdvtm2
520 AC                   eval      scdvby3 = uscode
520 AC                   eval      scdvdt3 = today
520 AC                   time                    scdvtm3
520 AC                   update    scdreca
520 AC                   endif
     *
520 AC                   eval      hlddsp_ver = onedsp
520 AC                   eval      onedsp = w3dsp
     C                   eval      hlddgt1_ver = w3dgt1
     C                   eval      hlddgt2_ver = w3dgt2
     C                   eval      hlddgt3_ver = w3dgt3
640aAC                   eval      hlddgt5_ver = w3dgt5
640bAC                   eval      hlddgt9_ver = w3dgt9
     *
     C                   endif
     *
     *  Clear slot and check digits for next 'Entry'
     *
     C                   if        w1mode = '1'
     C                   eval      w3dsp = *blanks
     C                   eval      w3dgt1 = 0
     C                   eval      w3dgt2 = 0
     C                   eval      w3dgt3 = 0
640aAC                   eval      w3dgt5 = 0
640bAC                   eval      w3dgt9 = 0
     C                   endif
     *
     C                   endsr
     *-------------------------------------------------------------------------
**
Invalid mode                01
Invalid slot                02
Enter check digit           03
Valid range 1 - 99          04
Value must be 0             05
Invalid warehouse           06
Invalid department          07
