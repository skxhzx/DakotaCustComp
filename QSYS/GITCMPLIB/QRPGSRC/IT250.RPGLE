      /copy *libl/qcopysrc,hspecs
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT250     RF Inventory transfer
     *  20 December, 1999
     *  Roxanne Harrison
     *  Created using IT150
     *
     *  Revisions
     *    02/11/98  RH   4.09
     *      - Major revision to use virtual slots.                    d
     *        Previous revision commemts were removed.
     *        Original IT150 was renamed IT150X
     *    02/10/00  RH   4.13a
     *      - Call VS810 VM instead of VS910 full screen vslot lookup d
     *
414 A*    06/22/99  DAS  4.14
     *      - Added APICVTSLT to ZZCHK1 routine.                      d
     *
415 A*    06/14/01  DAS  4.15
     *      - Revised to get default warehouse and position to slot.  d
     *
415aA*    07/11/01  DAS  4.15a
     *      - Revised to clear screen upon return from IT252.         d
     *
416 A*    12/04/02  MLB  4.16
     *      - Enh: Revised ZZCHK1 to not allow transfer from any slot
     *        not at active status.
     *
500 A*    05/26/06  JCJ  5.00
     *      - Added Multilingual logic.
510aA*    12/06/06  RH   5.10a
     *      - Enh: Remove BFCADR, no long used.
510bA*    12/07/07  RH   5.10b
     *      - Enh: Call with PARMS to verify replenishment item was
     *        transfered when called from replenishment program.
     *        TFRFLG=1 if replenishment item was transfered successfully
510cA*    12/10/07  LMC  5.10c
     *      - Enh: Use incoming parms for warehouse and department if
     *             $pparm is not blank
     *
600 A*    05/19/09  DAS  6.00
     *      - Converted to ILE.
     *
600bA*    05/22/09  DAS  6.00b
     *      - Revised to not allow the scanning of an RCV slot. These
     *        slots are tied to open receiving transaction sot they
     *        need to be handled through the putaway program.
     *
640aA*    03/04/11  JCJ  6.40a
     *      - Enh: Added License number to screen.
640bA*    07/28/11  RH   6.40b
     *      - Fix: Clear License number field added to screen.
640cA*    10/21/11  RH   6.40c
     *      - Fix: Clear License parm, only use license to get slot.
640dA*    12/30/11  RH   6.40d
     *      - Fix: Set dept to license dept if license scanned.
     *        Causing lic error if same slot existed in multiple dept
     *
640eA*    02/14/12  LMC  6.40e
     *      - Fix: Eliminate ITMEXCP bogus records being written.
     *        All error checking was not being processed.
640fA*    07/05/12  RH   6.40f
     *      - Enh: Do not allow transfer from USR slot, need to use
     *        item maintenance full screen transfer. DO NOT MAKE
     *        THIS CHANGE TO IT352.
640gA*    07/27/12  RH   6.40g
     *      - Fix: Use license slot, do not display virtual slot list
     *        and validate using license slot.
640h *    10/03/12  GJA  6.40h
     *      - Enh: Added IN25 to position to slot instead of license
     *        for clients using low tracking. IT25002
650a *    11/21/13  RH   6.50a
     *      - Enh: Add Client location parm to GETCLIENT
650b *    07/24/14  KDE  6.50b
     *      - Enh: Add ability to transfer PR status Production slots
650c *    10/05/14  GJA  6.50c
     *      - Fix: when using APICS the row should be 6
650d *    10/06/14  LMC/GJA 6.50d
     *      - Fix: Don't call convert slot if license was scanned
     *      use slot from license.
710a *    04/10/17  MR 7.10a
     *      - Fix: Added Lic# to spanish Screen.
710bA*    04/26/17  LMC  7.10b
     *      - Revised to not allow the scanning of an RTN slot. These
     *        slots are tied to open return transaction sot they
     *        need to be handled through the putaway program.
710cA*    05/10/17  LMC  7.10c
     *      - Revised to not allow the scanning of an STG slot. These
     *        slots are tied to open putawy transaction sot they
     *        need to be handled through the putaway program.
730aA*    09/24/19  LMC  7.30a
     *      - Revised to not allow the scanning of an RWO slot. These
     *        slots are tied to open receiving with no PO transactions
     *        so they need to be handled through the putaway program.
740aA*    10/15/20  RH   7.40a
     *      - Revised to allow XDK slot to be transfered.
750 A*    10/08/21  KDE  7.50
     *      - Revised to allow transfer for Drop Pick slot
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI - JAX
CDIaA*    11/21/13  RH   CDIa
     *      - Revised to ignore OS inactive slot status code edit.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
EFCaA*    04/20/11  RH   EFCa
     *      - Revised to ignore the inactive slot status code edit.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf
GLPaA*    09/20/13  RH   GLPa
     *      - Revised to ignore the inactive slot status code edit.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
PCKaA*    05/11/07  TJ   PCKa
     *      - Revised to ignore the inactive slot status code edit.
     *----------------------------------------------------------------
     *  Client Custom Revisions: WestSide
WSTa *    10/13/12  GJA  WSTa
     *      - Using IN25 to position to slot instead of license.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
     *
SGCaA*    05/19/09  DAS  SGCa
     *      - If a '1' is entered for the slot, use OSSKANSAS.
     *      - If a '2' is entered for the slot, use OSSWILLOW.
     *
SGCbA*    06/08/09  DAS  SGCb
     *      - Revised to call SGCBEANS at beginning of zzchk1.
     *        This is to handle the OSSKANSAS slot numbers that were
     *        incorrectly applied to 2 pallets during startup.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
HMWaA*    01/07/15  LMC  HMWa
     *      - Allow transfer from a slot with 'SR' status.
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
FPRaA*    03/16/15  RH   FPRa
     *      - Add to HMWa mod, Allow transfer from slot w/ 'SR' status
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
640aD *it250fm   cf   e             workstn
640aMF***it25001   cf   e             workstn
710aDF*it25002   cf   e             workstn
710aMFit25003   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fvslot2    if   e           k disk
     Fslot2     if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
PCKaA*----------------------------------------------------------------
PCKaA*  Customer id
PCKaA*
     D @getcl          c                   const('GETCLIENT')
PCKaA*
PCKaA /COPY QCOPYSRC,ID#PACKERS
SGCaA /copy qcopysrc,id#sgc
EFCaA /copy qcopysrc,id#eastlan
GLP A /copy qcopysrc,id#glp
WSTaA /copy qcopysrc,id#westsid
CDIaA /copy qcopysrc,id#cdi
HMWaA /COPY QCOPYSRC,id#hmwagne
FPR A /COPY QCOPYSRC,Id#fpr

600aA*----------------------------------------------------------------
600aA*  DRI parameters
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,C#DRIPARMS
600aA
600aA*----------------------------------------------------------------
600aA*  Data Formats
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,C#ITEM
600aA /COPY *libl/qcopysrc,C#LICENSE
600aAD saveVer#        s                   like($liver#)

     *----------------------------------------------------------------
     *  Called program parameters
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
640aAD  $plcns                54     68
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
     *
510b D $pparm          ds
510b D  $ppcmd                 1      8
510b D  $ppprg                 9     18
510b D  $ppuky                19     68
510b D  $pprtn                69     76
510b D  $pperm                77    136
510b D  $ppmsg                77     80
510b *
510b *   Redefine key
510b *
510b D  $ppwhs                19     21  0
510b D  $ppwhd                22     26
510b D  $ppitm                27     41
510b D  $pfdsp                42     53
510b D  $ptdsp                54     65
414 A*----------------------------------------------------------------
414 A*  API programs
414 A*
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
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
600aA /Copy qcopysrc,c#pgminfds
600aDD*               sds
600aDD* #prog            *proc
600aDD* #job                 244    253
600aDD* #user                254    263
600aDD* #jobn                264    269
600aDD* #jobdt               276    281  0
600aDD* #jobtm               282    287  0
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
640aAD chk4err         s               n
     D cancel          s              1
600aAD ck4err          s              1
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svitm           s             15
     D tfrflg          s              1
     D warn            s              1
600aAD zmflag          s               n
600aAD zmsflag         s               n
     *----------------------------------------------------------------
510X *  Let the show begin .....
510b *
510b C     *entry        plist
510b C                   parm                    $pparm
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     *
510aD*                    CALL 'BFCADR'
510aD*                    PARM           $RTN    8
510aD*          $RTN      IFEQ '*EXPIRED'
510aD*                    MOVE 'EOJ'     NXTSCR
510aD*                    ELSE
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
510aD*                    END
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn1sp                              50
500 AC                   other
     C                   exfmt     screen1                              50
500 AC                   endsl
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
     C                   eval      cancel = *off
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
     C                   eval      nxtscr = '01 '
     C                   exsr      zzfil1
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
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
409 AC     cancel        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
414 AC     redspl        cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     *
     *  The after update redisplay screen. The only way out is F3.
     *
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
510b C                   eval      tfrflg = *off
     *
PCKaA*
PCKaA* Get client id.
PCKaA*
PCKaAC                   call      @getcl
PCKaAC                   parm                    client           10
650aAC                   parm                    clientloc        10
PCKaA*
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
640aA*----------------------------------------------------------------
640aA*    LP11022  License not on file.
640aA*
640aAC     zm022         begsr
640aAC                   eval      #msgid = 'LP11022'
640aAC                   eval      #msgtp = '*DIAG  '
640aAC                   eval      $md = *blanks
640aAC                   exsr      zmpmsg
640aAC                   endsr
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
416 A*----------------------------------------------------------------
416 A*   PIR2007  Invalid slot, slot inactive.
416 A*
416 AC     zm2007        begsr
416 AC                   eval      #msgid = 'PIR2007'
416 AC                   eval      #msgtp = '*DIAG  '
416 AC                   eval      $md = *blanks
416 AC                   exsr      zmpmsg
416 AC                   endsr
416 A*----------------------------------------------------------------
416 A*     IT12215  Slot does not contian item.
416 A*
416 AC     zm2215        begsr
416 AC                   eval      #msgid = 'IT12215'
416 AC                   eval      #msgtp = '*DIAG  '
416 AC                   eval      $md = *blanks
416 AC                   exsr      zmpmsg
416 AC                   eval      $pmsg = #msgk
416 AC                   endsr
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
640aA*
640aA*  Verify License if entered.
640aA*
640aAC                   if        w1lcns <> ' '
640aAC                   exsr      clr$license
640aAC                   eval      $liToLcnsU = *on
640aAC                   eval      $liToLcns = w1lcns
640aAC                   eval      $dricommand = '*LICENSE'
640aMC                   eval      $drisubcmd  = '%GETINFO'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      chk4err = *on
640aAC                   eval      zmflag  = *off
640aAC                   exsr      zzzdricop

640aAC                   if        error
640aAC                   eval      *in24 = *on
640aAC                   eval      *in04 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   exsr      zm022
640aAC                   else
640aAC                   eval      w1disp = $litodisp
640eAc                   if        $litowhdp <> ' '
640dAC                   eval      w1whdp = $litowhdp
640eAc                   endif
640aAC                   endif
640eDC*                  leavesr
640aAC                   endif
SGCbA*
SGCbA*  Call special program to work with OSS slot errors
SGCbA*
SGCbAC                   call      'SGCBEANS'
SGCbAC                   parm                    w1disp
SGCbAC                   parm                    $xopt             1
SGCbAC                   if        $xopt = ' '
SGCbAC                   eval      cancel = *on
SGCbAC                   leavesr
SGCbAC                   endif
600bA*
600bA*  Do not allow the transfer from a RCV file.
600bA*
600bAC                   if        %subst(w1disp:1:3) = 'RCV'
710bAC                              or %subst(w1disp:1:3) = 'RTN'
730aAC                              or %subst(w1disp:1:3) = 'RWO'
710cAC                              or %subst(w1disp:1:3) = 'STG'
600bAC                   eval      error = *on
600bAC                   eval      *in23 = *on
600bAC                   eval      *in03 = *on
710bDC*                  eval      errmsg = 'RCV slot not allowed '
710bDC*                                   + '- use Putaway'
710cDC*                  eval      errmsg = 'RCV/RTN slot not allowed '
710cDC*                                   + '- use Putaway'
730aDC*                  eval      errmsg = 'RCV/RTN/STG slot not allowed '
730aDC*                                   + '- use Putaway'
730aMC                   eval      errmsg = 'RCV/RTN/RWO/STG slot not allowed '
730aMC                                    + '- use Putaway'
600bAC                   exsr      zm0105
600bAC                   leavesr
600bAC                   endif
640fA*
640fA*  Do not allow the transfer from a USR slot.
640fA*
640fAC                   if        %subst(w1disp:1:3) = 'USR'
640fAC                   eval      error = *on
640fAC                   eval      *in23 = *on
640fAC                   eval      *in03 = *on
640fAC                   eval      errmsg = 'USR slot not allowed '
640fAC                                    + '- use Item Maint'
640fAC                   exsr      zm0105
640fAC                   leavesr
640fAC                   endif

650dA*  don't conver slot if license was entered - GJA
650dAC                   if        w1lcns =  ' '
414 A*
414 A*  Call API for slot.
414 A*
414 AC                   call      @apics
414 AC                   parm                    w1disp
650cDC***                parm      5             worow
650cMC                   parm      6             worow
414 AC                   parm      7             wocol
414 AC                   parm                    @artn             8
414 AC                   if        @artn = '*REDSPLY'
414 AC                   eval      redspl = *on
414 AC                   goto      endck1
414 AC                   endif
650dAC                   endif
SGCaA
SGCaA*  For Springfield, do pre-verification of slot
SGCaA
SGCaAC                   if        client = sgc
SGCaA
SGCaAC                   eval      $lcmd = '*VERIFY '
SGCaAC                   eval      $lwhse = w1whse
SGCaAC                   eval      $lwhdp = w1whdp
SGCaAC                   eval      $litem = *blanks
SGCaAC                   eval      $ldisp = w1disp
SGCaAC                   call      'SL900'
SGCaAC                   parm                    $lparm
SGCaA
SGCaA*    If error, see if they entered an item number.
SGCaA
SGCaAC                   if        $lrtn = '*PGMQ   '
SGCaA
SGCaAC                   exsr      clr$item
SGCaAC                   eval      $itwhse  = w1whse
SGCaAC                   eval      $ititem  = w1disp
SGCaAC                   eval      $dricommand = '*ITEM'
SGCaAC                   eval      $drisubcmd  = '%GETBASE'
SGCaAC                   eval      $drisys2upd = 'D'
SGCaAC                   exsr      zzzdricop
SGCaAC                   if        error
SGCaAC                   eval      error = *off
SGCaAC                   else
SGCaAC                   exsr      clr$license
SGCaAC                   eval      $liTowhseu = *on
SGCaAC                   eval      $liTowhse = w1whse
SGCaAC                   eval      $liToSItemu = *on
SGCaAC                   eval      $liTosItem = $ititem
SGCaAC                   eval      $dricommand = '*LICENSE'
SGCaAC                   eval      $drisubcmd  = '%GETSFGOSS'
SGCaAC                   eval      $drisys2upd = 'D'
SGCaAC                   exsr      zzzdricop
SGCaAC                   if        $drireturn = '*OK'
SGCaAC                   eval      w1disp = $liToDisp
SGCaAC                   endif
SGCaAC                   endif
SGCaAC                   endif
SGCaA
SGCaAC                   endif
     *
409 A*  Check if slot has V-slots.
     *
640gA*  Do not display slot listing if valid license was entered.
640gAC                   if        w1lcns = ' '
     C     vskey         setll     vslot2
     C     vskey         reade     vslot2                                 79
     *     DISPLAY VSLOT LISTING
     C                   if        not *in79
     C                   eval      $pcmd = '*LOOKUP '
     C                   eval      $pwhse = w1whse
     C                   eval      $pwhdp = w1whdp
     C                   eval      $pdisp = w1disp
413 D*R                   CALL 'VS910'
413 MC                   call      'VS810'
     C                   parm                    $parms
     C                   eval      w1disp = $pdisp
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
409 AC                   goto      endck1
     C                   endif
     C                   endif
640gAC                   endif
     *
     *  Verify slot.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1disp
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
416 A*
416 AC                   else
416 AC                   select
416 A*    Check status of slot. Tell user slot is empty.
416 AC                   when      $lstat = 'V '
416 AC                   eval      error = *on
416 AC                   eval      *in23 = *on
416 AC                   eval      *in03 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   exsr      zm2215
416 A*
416 A*    Check status of slot. Slot must be active to be eligible
416 A*    for transfer.
PCKaA*    Do not perform this edit for Packers.
416 AC                   when      $lstat <> 'A '
650bAc                              and $lstat <> 'PR'
750 Ac                              and $lstat <> 'DP'
CDIaAC                   if        client = cdi and
CDIaAC                             clientloc = 'CDIJAX'
CDIaAC                   if        $lstat <> 'OS'
CDIaAC                   eval      error = *on
CDIaAC                   eval      *in23 = *on
CDIaAC                   eval      *in03 = *on
CDIaAC                   eval      errmsg = *blanks
CDIaAC                   exsr      zm2007
CDIaAC                   endif
CDIaAC                   else
CDIaAC*
HMWaA * changed to select statement
HMWaDC*
HMWaDC*                  if        client <> 'PACKERS' and
HMWaDC*                            client <> 'GREENLEAF' and
HMWaDC*                            client <> 'EASTLAND'
HMWaAc                   Select
HMWaMc                   When      client = 'PACKERS'
HMWaMc                   When      client = 'GREENLEAF'
HMWaMc                   When      client = 'EASTLAND'
HMWaAC                   When      client = hmwagner and $lstat = 'SR'
FPRaAC                   When      client = FoodPro and $lstat = 'SR'
750 Ac                   when      $lstat='DP'
740aA*    Allow XD status (XDK) slot to be eligible for transfer
740aAC                   When      $lstat= 'XD'
HMWaAc                   other
416 AC                   eval      error = *on
416 AC                   eval      *in23 = *on
416 AC                   eval      *in03 = *on
416 AC                   eval      errmsg = *blanks
416 AC                   exsr      zm2007
HMWaAc                   endsl
HMWaDC*                  endif
CDIaAC                   endif
416 A*
416 AC                   endsl
     C                   endif
     C                   endif
SGCaA
SGCaA*  For Springfield,
SGCaA*    If a '1' is entered, change slot to OSSKANSAS.
SGCaA*    If a '2' is entered, change slot to OSSKANSAS.
SGCaA
SGCaAC                   eval      $lcmd = '*VERIFY '
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
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 7
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Warehouse department.
     *
     C                   when      row# = 4
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
     *     SLOT.
     *
     C                   when      row# = 5
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*GENERAL'
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1disp
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
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1whdp = *blanks
     C                   eval      w1disp = *blanks
640bAC                   eval      w1lcns = *blanks
     *
415 AC                   call      'GETUSER'
415 AC                   parm      #user         $code            10
415 AC                   parm      0             $whse             3 0
415 AC                   parm      0             $emp#             5 0
415 AC                   parm      ' '           $fnam            15
415 AC                   parm      ' '           $init             1
415 AC                   parm      ' '           $lnam            20
415 AC                   parm      ' '           $whdp             5
415 AC                   parm      ' '           $styp             1
415 AC                   parm      ' '           $shft             6
415 AC                   parm      ' '           $crew             6
415 AC                   parm      0             $nhrs             3 1
415 AC                   parm      ' '           $rtn              8
510cA* Use parms passed in
510cAC                   if        $ppitm <> ' '
510cAC                   if        $ppwhs <> 0
510cAC                   eval      $whse = $ppwhs
510cAC                   endif
510cAC                   if        $ppwhd <> ' '
510cAC                   eval      $whdp = $ppwhd
510cAC                   endif
510cAC                   endif
415 AC                   eval      w1whdp = $whdp
     *
WSTaAC                   if        client = WestSide
WSTaAC                   eval      *in25 = *on
WSTaAC                   else
415 AC                   eval      *in20 = *on
WSTaAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define partial key for VSLOT2 file.
     *
     C     vskey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1disp
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     *
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
500cAC                   parm                    e$emp#            5
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
510cA* Use parms passed in
510cAC                   if        $ppitm <> ' '
510cAC                   if        $ppwhs <> 0
510cAC                   eval      e$whse = $ppwhs
510cAC                   endif
510cAC                   if        $ppwhd <> ' '
510cAC                   eval      e$whdp = $ppwhd
510cAC                   endif
510cAC                   endif
500cAC                   if        e$rtn <> '*OK'
500cAC                   eval      e$lng = 'EN'
500cAC                   endif
     *
414 AC                   eval      worow = 0
414 AC                   eval      wocol = 0
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
510b *
510b *  Get item from slot.
510b C                   eval      svitm = *blanks
510b C     vskey         chain     slot2                              78
510b C                   if        not *in78
510b C                   eval      svitm = slitem
510b C                   endif
510b *
     *
     *  Move screen fields to parameter fields.
     *
     C                   eval      $pwhse = w1whse
     C                   eval      $pwhdp = w1whdp
     C                   eval      $pdisp = w1disp
640cDC**                 eval      $plcns = w1lcns
     *
     *  Call program to do the transfer.
     *
     C                   eval      $pcmd = '*CHANGE '
     C                   call      'IT252'
     C                   parm                    $parms
415aAC                   exsr      zsclr
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn = '*OK     '
510b C                   if        svitm = $ppitm
510b C                   eval      tfrflg = *on
510b C                   eval      $pprtn = '*OKTFR  '
510b C                   else
510b C                   eval      $pprtn = $prtn
510b C                   endif
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   exsr      scr01i
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C     endupd        endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$license  Clear $license data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C**                 eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
640aAC                   eval      $liTowhse = w1whse
640aAC                   eval      $liTowhseu = *on
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $dridata = $license
600aAC                   eval      $dridata2 = $license2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600aAC                             or $dricommand = '*LICENSE'
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

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C*                  exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C*                  exsr      zm0001
     C***                exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $license = $dridata
600aAC                   eval      $license2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C*                  eval      chk4err = *off
     C     enddricop     endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
