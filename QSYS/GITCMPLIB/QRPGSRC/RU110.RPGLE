     H copyright('(c) Copyright BFC Software, Inc - 2004')
     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU110     RF - Runner Flag Entry
     *  30 April 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *      16 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    04/30/04  MLB  4.17
     *      - Created.
     *
500 A*    11/16/04  MLB  5.00
     *      - Enh: Revised ZZCHK1 to not allow flags to be entered
     *        unless transaction is at 3=Ended status.
     *      - Added file PIRTRAN to program.
     *      - Added 2 entries to DESC table.
500aA*    03/14/05  RLP  5.00a
     *      - Enh: Added DRI interface support.
     *      - Enh: Added 'Client id' support.
500bA*    03/16/05  RLP  5.00b
     *      - Enh: Added check of SLOTOUT file to ZZCHK2.
     *        Attempt Priority Replenishment if not in SLOTOUT.
500cA*    05/27/05  MLB  5.00c
     *      - Enh: Revise ZZREPL to use *CRTRPFSQ1 instead of *CRTRPLSQ1.
     *        *CRTRPFSQ1 will force a Priority Replenishment to be created
     *        even if there is available qty in pick slot.
500dA*    07/09/05  MLB  5.00d
     *      - Enh: Revise program to set new field RUTYPE based on partly
     *        on LBTYPE and partly on whether item can be replenished.
     *        If item can be replenished, LBTYPE is 'O' or 'B' then
     *        RUTYPE is N=Normal. If no replenishment can be created, then
     *        RUTYPE is U=Out. If LBTYPE is 'M', then RUTYPE is M=Merge.
     *      - Added file OPTIONS. Retrieve *GENPICK options record.
500eA*    09/14/05  MLB  5.00e
     *      - Enh: Revised program to add *VOICE options to program to
     *        determine whether to create RUNNER entries for shorted
     *        product. Added file OPTIONS to pgm. Added msg to DESC
     *        array when manual entry not allowed.
500fA*    12/09/05  JCJ  5.00f
     *      - Enh: Revised program to add *RUNNER options to program
     *      - Enh: Added Call to program PT132PL
     *
530a *    05/14/10  GJA  5.30a
     *      - Enh: increase label entry to 10 positions
     *      - Fix: remove ENTER variable
     *
710aA*    06/05/17  TAB  7.10a
     *      - Enh: Added new runner type for Box Breaker / create
     *        runner record with type 'B' when breakdown qty is being
     *        shorted.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *    03/16/05  RLP  CBI
     *      - Enh: Added logic to not allow short/out qty more than 5.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/25/07  MLB  VIP
     *      - Enh: Added support for item# 9999999999 to retrieve
     *        item description from order detail misc. file.
     *      - Added ORDDM file.
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
530aDF*****ru110fm   cf   e             workstn
530aMFru11001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     FLabel     uf   e           k disk
     F                                     rename(lbrec:record)
500dAFoptions   if   e           k disk
VIP AForddm     if   e           k disk    usropn
     Fpiritem   if   e           k disk
500 AFpirtran   if   e           k disk
710aAFitemfld   if   e           k disk
     Frunner    uf a e           k disk
500bAFslotout   uf a e           k disk
500aA*----------------------------------------------------------------
500aA*  DRI parameters
500aA*----------------------------------------------------------------
500aA /COPY *libl/qcopysrc,C#DRIPARMS

500aA*----------------------------------------------------------------
500aA*  Data Formats
500aA*----------------------------------------------------------------
500aA /COPY *libl/qcopysrc,C#PRTYRPL
500aAD savever#        s                   like($prver#)

VIP A*----------------------------------------------------------------
VIP A*  Order Detail Misc file - Misc fields 1 - 5.
VIP A*----------------------------------------------------------------
VIP A /copy *libl/qcopysrc,orddm1_vip
VIP A
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
500 DD*desc            s             50    dim(10) ctdata perrcd(1)
500bDD*desc            s             50    dim(12) ctdata perrcd(1)
500bAD*desc            s             50    dim(13) ctdata perrcd(1)
500fAD desc            s             50    dim(14) ctdata perrcd(1)
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
500aAD @getcl          c                   const('GETCLIENT')
500aAD*
500aA /COPY QCOPYSRC,ID#CHENEY
VIP A /COPY QCOPYSRC,ID#VIP
500dA*----------------------------------------------------------------
500dA*  *GENPICK -  General picking.
500dA*----------------------------------------------------------------
500dA*
500dA* Fields
500dA*
500dA*    OPERPT  -  Print exception (short) error report (Y,N).
500dA*    OPELBL  -  Print exception (short) labels (Y,N).
500dA*    OPRFWC  -  Using RF will call (Y,N).
500dA*    OPNRSC  -  Number of pallet sections (1-9).
500dA*    OPHPWC  -  Host pick Will Call (Y/N).
500dA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
500dA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
500dA*    OPEADJ  -  Close short labels without adjustment (Y,N).
500dA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500dA*    OPCLRF  -  Clear runner flags if qty still short/out? (Y/N)
500dA*
500dA* Data structure
500dA*
500dAD opdta1          DS
500dAD  OPERPT                 1      1
500dAD  OPELBL                 2      2
500dAD  OPRFWC                 3      3
500dAD  OPNRSC                 4      4  0
500dAD  OPHPWC                 5      5
500dAD  OPMRGA                 6      6
500dAD  OPPLSQ                 7      7
500dAD  OPEADJ                 8      8
500dAD  OPNOPK                 9      9
500d****OPCLRF                10     10
500fAD  OPCLRF2               10     10
500dAD  OPTEND               117    117
500eA*
500eA*----------------------------------------------------------------
500eA*  *VOICE  -  PIR Voice options.
500eA*----------------------------------------------------------------
500eA*
500eA* Fields
500eA*
500eA*    OPINCP  -  Include pack description (Y/N)
500eA*    OPCRTR  -  Create RUNNER entries for shorts (Y/N)
500eA*
500eA* Data structure
500eA*
500eA*----------------------------------------------------------------
500eA
500eAD opvdta          ds
500eAD  opincp                 1      1
500eAD  opcrtr                 2      2
500eAD  opvend               117    117
500eA
500fA*----------------------------------------------------------------
500fA*  *RUNNER  -  PIR Runner Flag Options
500fA*----------------------------------------------------------------
500fA*
500fA* Fields
500fA*
500fA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
500fA*    OPUPLR  -  Update Label with quantity shorted during manual
500fA*               flag entry (Y/N)
500fA*               NOTE: Any change to this field will cause OPUPLV
500fA*                     in the *VOICE options record to be updated.
500fA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
500fA*               & create Priority Replenishment if necessary.
500fA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
500fA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
500fA*    OPRNRM  -  Send break message to user when new Runner
500fA*               task has been assigned. (Y/N)
500fA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
500fA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500fA*
500fA* Data structure
500fA*
500fAD oprdta          ds
500fAD  opcrtm                 1      1
500fAD  opuplr                 2      2
500fAD  oprplf                 3      3
500fAD  opmrgf                 4      4
500fAD  opclrf                 5      5
500fAD  oprnrm                 6      6
500fAD  opclsf                 7      7
500fAD  opoutf                 8      8
500fAD  optendr              117    117

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#STDVAR

     *----------------------------------------------------------------
     *  Working variables
     *
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
     D CLEAR           s              5  0
     D CMDCHK          s              8
     D CMDTKN          s              1
     D COMAND          s              5  0
     D DONE            s              1
     D E               s              2  0
530aDD*ENTER           s              5  0
500aDD*ERROR           s              1
     D EXCPTN          s              1
     D FOREVR          s              1
     D HELP            s              5  0
     D MORE            s              1
     D MSGK            s              4  0
     D NXTSCR          s              3
     D REDSPL          s              1
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D SCLEAR          s              1
500aDD*WARN            s              1
500fAD svwhse          s              3  0
500fAD $pcmd           s              8
500fAD $plbl#          s              7  0
500fAD $pqty           s              5  0
530aAD w1lbl#          s              7  0
710aAD UCISelect       s               n
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
530aAD @cvtbarsel      c                   const('CVTBARSEL')
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
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lcode                22     27
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
     D currstamp       s               z
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
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
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
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
     *
     C                   exsr      zzinz2
     *
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   Eval      *inlr = *on
     *
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
     C                   select
     C                   when      nxtscr = '01 '
417bAC                   select
417bAC                   when      #lline =  '16'
     C                   exfmt     screen61                             50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     *
     C                   when      nxtscr = '02 '
417bAC                   select
417bAC                   when      #lline =  '16'
     C                   exfmt     screen62                             50
     C                   other
     C                   exfmt     screen2                              50
     C                   endsl
     *
     C                   endsl
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
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *
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
     C                   move      'EOJ'         nxtscr
     *
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     *
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
500dA*
500dA*     Get *GENPICK picking options record.
500dA ****500fA          exsr      zzgetop
500dA*
500fA*     Get *RUNNER options record.
500fAC                   if        w1whse <> svwhse
500fAC                   exsr      zzgetruop
500fAC                   eval      svwhse = w1whse
500fAC                   endif
500fA*
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
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
     C                   if        *inkc
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500aA*
500aA* Get client id.
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client           10
500aA*
     *
     *  Initialize special keys
     *
530aDC*****              eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
VIP A*
VIP AC                   if        client = VIP
VIP A*
VIP AC                   if        not %open(orddm)
VIP AC                   open      orddm
VIP AC                   endif
VIP A*
VIP AC                   endif
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
500aA*----------------------------------------------------------------
500aA*                     DRI SUBROUTINES
500aA*----------------------------------------------------------------

500aA*----------------------------------------------------------------
500aA*  clr$prtyrpl  Clear $prtyrpl data structure fields
500aA*----------------------------------------------------------------

500aAC     clr$prtyrpl   begsr
500aAC                   eval      savever# = $prver#
500aAC                   clear                   $prtyrpl
500aAC                   eval      $prver# = savever#
500aAC                   endsr

500aA*----------------------------------------------------------------
500aA*  zzzdricop  Call DRICOP
500aA*----------------------------------------------------------------

500aAC     zzzdricop     begsr
500aAC                   eval      error = *off

500aAC                   select
500aAC                   when      $dricommand = '*PRTYRPL'
500aAC                   eval      $dridata = $prtyrpl
500aAC                   endsl

500aAC                   call(e)   'DRICOP'
500aAC                   parm                    $dricommand
500aAC                   parm                    $drisubcmd
500aAC                   parm                    $drisys2upd
500aAC                   parm      #prog         $driprogram
500aAC                   parm      ' '           $drireturn
500aAC                   parm      ' '           $drimessage
500aAC                   parm                    $dridata

500aAC                   select

500aAC                   when      %error
500aAC                   eval      error = *on
500aAC                   eval      errmsg    = 'Error occured on call to '
500aAC                                       + 'DRICOP'
500aAC                                       + '/' + %trim($drisubcmd)
500aAC                                       + ' from ' + #prog

500aAC                   when      $drireturn <> '*OK'
500aAC                   eval      error = *on

500aAC                   endsl

500aAC                   select
500aAC                   when      $dricommand = '*PRTYRPL'
500aAC                   eval      $prtyrpl = $dridata
500aAC                   endsl

500aAC     enddricop     endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     *
     C                   if        #lline = '16'
     C                   write     m16ctl
     *
     C                   else
     C                   write     msgctl
     C                   endif
     *
     C                   eval      msgk = *zeros
     *
     C                   if        #lline = '16'
     C                   write     m16clr
     *
     C                   else
     C                   write     msgclr
     C                   endif
     *
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     *
     C                   if        #lline = '16'
     C                   write     m16ctl
     *
     C                   else
     C                   write     msgctl
     C                   endif
     *
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
     *
     C                   if        #lline = '16'
     C                   write     m16rec
     *
     C                   else
     C                   write     msgrec
     C                   endif
     *
     C                   endif
     *
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
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
     *
     C                   if        #lline = '16'
     C                   write     m16rec
     *
     C                   else
     C                   write     msgrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR7872  Record not updated in file.
     *
     C     zm7872        begsr
     C                   move      'PIR7872'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
500eA*
500eA*   Verify if manual entry of RUNNER entries is allowed.
500eA*
500eA ****500fA          if        opcrtr <> 'Y'
500fAC                   if        opcrtm <> 'Y'
500eAC                   move      *on           error
500eAC                   eval      *in22 = *on
500eAC                   eval      *in02 = *on
500eAC                   movel     desc(13)      errmsg
500eAC                   exsr      zm0105
500eAC                   goto      endck1
500eAC                   endif
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify label number entered.
     *
530aDC*****              If        w1lbl# <= 0
530aMC                   If        w1lbl#b = *blanks
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(1)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
530aDC*****              If        w1lbl#b >= 0
530aMC                   If        w1lbl#b <> *blanks
     * grab label#
530aAC                   move      w1whse        $pwhseb
530aAC                   movel     w1lbl#b       $pbarcode
530aAC                   call      @cvtbarsel
530aAC                   parm                    $pwhseb           3
530aAC                   parm                    $pbarcode        15
530aAC                   parm                    $plbl#
530aAC                   parm                    $prtid            5
530aAC                   parm                    $punq#            5
530aAC                   parm                    $preturn          8
530aAC                   parm                    $perrmsg         60
530aAC                   if        $preturn = '*OK'
530aAC                   eval      w1lbl# = $plbl#
530aAC                   move      *blanks       w1lbl#b
530aAC                   move      $plbl#        w1lbl#b
530aAC                   else
530aAC                   eval      error = *on
530aAC                   eval      *in22 = *on
530aAC                   movel     desc(2)       errmsg
530aAC                   exsr      zm0110
530aAC                   endif
     C     W1lbl#        chain (n) Record
     C                   Select
     C                   When      not %found(Label)
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(2)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Label)
     *
     *    Label already flagged.
     C                   Select
     C                   When      Lbvrfy = 'F'
     C                             or Lbvrfy = 'I'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(3)       errmsg
     C                   exsr      zm0105
     *
     *    Label already closed.
     C                   When      Lbstat = 'C'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(4)       errmsg
     C                   exsr      zm0105
500fA*
500fA*    Label type not correct.
500fAC                   When      Lbtype = 'M'
500fAC                             and opmrgf = 'N'
500fAC                   move      *on           error
500fAC                   eval      *in22 = *on
500fAC                   eval      *in02 = *on
500fAC                   movel     DESC(14)      errmsg
500fAC                   exsr      zm0105
     *
     *    Label type not correct.
     C                   When      Lbtype <> 'O'
500dAC                             and Lbtype <> 'B'
500dAC                             and Lbtype <> 'M'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(5)       errmsg
     C                   exsr      zm0105
     *
     C                   Endsl
     *
     C                   Endsl
     C
500 A*
500 A*    Verify transaction is at 3=Ended status. If not Ended, flag
500 A*    cannot be entered since transaction is still being picked.
500 AC     lbtrn#        chain     pirtran
500 AC                   if        not %found(pirtran)
500 AC                             or %found(pirtran) and
500 AC                             ptstat <> '3'
500 AC                   eval      error = *on
500 AC                   eval      *in22 = *on
500 AC                   eval      *in02 = *on
500 AC                   if        not %found(pirtran)
500 AC                   eval      ptstat = ' '
500 AC                   endif
500 AC                   if        ptstat = '1'
500 AC                   movel     desc(12)      errmsg
500 AC                   else
500 AC                   movel     desc(11)      errmsg
500 AC                   endif
500 AC                   exsr      zm0105
500 AC                   endif
     C
     C                   Endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
     *
     C                   Exsr      Zzchk1
     *
     *    Qty short/out must be greater than zero.
     C                   If        w2qyso <= 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     DESC(6)       errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     *    Qty short/out can't be greater than original pick qty.
     C                   If        w2qyso >  lbqpck
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     DESC(7)       errmsg
     C                   exsr      zm0105
     C                   Endif
CBI A*
CBI A*    Qty short/out must be less than 5.
CBI AC                   If        client = cheney
CBI AC                   If        w2qyso > 5
CBI AC*                  eval      error = *on
CBI AC*                  eval      *in23 = *on
CBI AC*                  eval      *in03 = *on
CBI AC*                  movel     DESC(13)      errmsg
CBI AC*                  exsr      zm0105
CBI AC                   Endif
CBI AC                   Endif
710aAC                   exsr      zzitemfld
     *
     *    Check if record in Runner file. If status deleted, ok to add.
500dDC*    W1lbl#        chain (n) runner
500dA*
500dA*      Merge records will have only one entry.
500dAC                   select
500dAC                   when      lbtype = 'M'
500dAC                   eval      kytype = lbtype
500dAC                   exsr      zzgetru
500dA*
500dAC                   other
500dA*
500dA*      Order, Bulk records can have up to two entries.
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      kytype = 'B'
710aAC                   else
500dAC                   eval      kytype = 'N'
710aAC                   EndIf
500dAC                   exsr      zzgetru

500dAC                   if        not %found(runner)
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      kytype = 'B'
710aAC                   else
500dAC                   eval      kytype = 'U'
710aAC                   EndIf
500dAC                   exsr      zzgetru
500dA*
500dA*      If label not found, set type to N=Normal for add.
500dAC                   if        not %found(runner)
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      kytype = 'B'
710aAC                   else
500dAC                   eval      kytype = 'N'
710aAC                   EndIf
500dAC                   endif
500dA*
500dAC                   endif
500dAC                   endsl
     *
     C                   If        %found(Runner)
     C                             and rustat <> 'D'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     desc(8)       errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     C     endck2        endsr
     *
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
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
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
     *
     C                   endif
     *
     C     endcm1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1lbl# = *zeros
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2lbl# = w1lbl#
     *
     C                   eval      $iitem = lbitem
VIP AC                   select
VIP AC                   when      client = VIP
VIP A*
VIP AC                   if        lbitem = '9999999999'
VIP AC                   eval      $idesc = omodsc
VIP AC                   eval      $ipdsc = vipdm1_ompdsc
VIP AC                   else
VIP AC                   eval      $idesc = itdesc
VIP AC                   eval      $ipdsc = itpdsc
VIP AC                   endif
VIP A*
VIP AC                   other
VIP A*
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
VIP AC                   endsl
VIP A*
     C                   eval      $istr  = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     *
     C                   eval      w2disp = lbdisp
     C                   eval      w2qpck = lbqpck
     C                   eval      w2ucod = lbucod
     C                   eval      w2qyso = 0
     *
     C     endfl2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGet1   Get  Equipment master record.
     *
     C     zzget2        begsr
     *
     C     Itkey         chain     piritem
     C                   if        Not %found
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
VIP A*
VIP AC                   if        client = VIP
VIP A*      Retrieve item description for special order item#.
VIP AC                   if        lbitem = '9999999999'
VIP AC                   exsr      zzgetom
VIP AC                   endif
VIP A*
VIP AC                   endif
     *
     C     endgt2        Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   move      *off          forevr
500eA*
500eA* Get voice options.
500eA*
500eA ****500fA          Eval      WkCode = '*VOICE'
500eA ****500fA          Eval      WkSwhs = 0
500eA ****500fA OpKey         Chain     Options
500eA ****500fA          if        %found
500eA ****500fA          eval      opvdta = opdata
500eA ****500fA          else
500eA ****500fA          eval      opincp = 'Y'
500eA ****500fA          eval      opcrtr = 'N'
500eA ****500fA          endIf
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    w1lbl#
VIP A*
VIP A*   Full ORDDM key
VIP AC     omkey         klist
VIP AC                   kfld                    w1whse
VIP AC                   kfld                    lbord
VIP AC                   kfld                    lbseq
VIP AC                   kfld                    lbitem
500dA*
500dA*  Define key for OPTIONS file.
500dA*
500eAC     *like         define    opwhse        wkswhs
500eAC     *LIKE         define    opcode        wkcode
500dAC     opkey         klist
500eAC                   kfld                    wkswhs
500eAC                   kfld                    wkcode
500eDC*                  kfld                    w1whse
500eDC*                  kfld                    opcode
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    lbitem
500dA*
500dA*  Define full key for RUNNER file.
500dA*
500dAC     *like         define    rutype        kytype
500dAC     keyru         klist
500dAC                   kfld                    w1whse
500dAC                   kfld                    kytype
500dAC                   kfld                    w1lbl#
500bA*
500bA*  Define partial key for SLOTOUT file.
500bA*
500bAC     keyso         klist
500bAC                   kfld                    w1whse
500bAC                   kfld                    lbwhdp
500bAC                   kfld                    lbdisp
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get screen size being used.
     *
     C                   Call      'PIRRFSCR'
     C                   parm      '*GET'        #LCMD             8
     C                   parm                    #LLINE            2
     C                   parm                    #LCOL             3
     *
     C                   move      *on           refrsh
     C                   move      *off          more
     C                   move      *off          done
     C                   move      *off          excptn
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     C                   eval      w1whse = #whse
     *
     C                   exsr      scr01i
     *
     C                   endsr
VIP A*
VIP A*----------------------------------------------------------------
VIP A*
VIP A*  ZZGETOM  Get Order Detail Misc. record.
VIP A*
VIP AC     zzgetom       begsr
VIP A*
VIP AC     omkey         chain     orddm
VIP AC                   if        not %found(orddm)
VIP AC                   eval      omodsc = ' '
VIP AC                   eval      omcbox = 'N'
VIP AC                   eval      omcexp = 'N'
VIP AC                   select
VIP AC                   when      client = VIP
VIP AC                   eval      vipdm1_base   = ' '
VIP AC                   eval      vipdm1_ompckm = 0
VIP AC                   eval      vipdm1_omwtiw = 0
VIP AC                   eval      vipdm1_omcbec = 0
VIP AC                   endsl
VIP A*
VIP AC                   else
VIP A*
VIP AC                   select
VIP AC                   when      client = VIP
VIP AC                   eval      vipdm1_base = ommsc1
VIP AC                   endsl
VIP AC                   endif
VIP A*
VIP AC                   endsr
500dA*
500dA*----------------------------------------------------------------
500dA*
500dA*  ZZGETOP  Get General Picking Options record.
500dA*
500dAC     zzgetop       begsr
500dA*
500eAC*                  MOVE      '*GENPICK'    opcode
500eAC                   Eval      WkCode = '*GENPICK'
500eAC                   Eval      WkSwhs = w1whse
500dA*
500dAC     opkey         chain     options
500dAC                   if        not %found(options)
500dAC                   eval      opclrf = 'Y'
500dAC                   else
500dAC                   movel     opdata        opdta1
500dAC                   endif
500dA*
500dAC                   endsr
500dA*
500fA*----------------------------------------------------------------
500fA*
500fA*  ZZGETRUOP  Get Runner Options record.
500fA*
500fAC     zzgetruop     begsr
500fA*
500fAC                   eval      WkCode = '*RUNNER '
500fAC                   eval      WkSwhs = w1whse
500fA*
500fAC     opkey         chain     options
500fAC                   if        not %found(options)
500fAC                   eval      opclrf = 'Y'
500fAC                   else
500fAC                   movel     opdata        oprdta
500fAC                   endif
500fA*
500fAC                   endsr
500fA*
500dA*----------------------------------------------------------------
500dA*  ZZgetru
500dA*----------------------------------------------------------------
500dAC     zzgetru       begsr
500dA
500dMC     keyru         chain (n) runner
500dA
500dAC                   endsr
     *
500bA*----------------------------------------------------------------
500bA*  ZZrepl
500bA*----------------------------------------------------------------
500bAC     zzrepl        begsr
500bAC                   exsr      clr$prtyrpl

500bAC                   eval      $prwhseu = *on
500bAC                   eval      $prwhse  = w1whse

500bAC                   eval      $pritemu = *on
500bAC                   eval      $pritem  = lbitem

500bAC                   eval      $prwhdpu = *on
500bAC                   eval      $prwhdp  = lbwhdp

500bAC                   eval      $prslotu = *on
500bAC                   eval      $prslot  = lbdisp

500bA*   Note, DRIPRTYRPL will determine qty needed.
500bAC                   eval      $prqtynu = *on
500bAC                   eval      $prqtyn  = w2qyso

500bA*   Note, DRIPRTYRPL will determine if slot is filled to needed qty.
500bAC**                 eval      $prfillu = *on
500bAC**                 eval      $prfill  = 'Y'

500bAC                   eval      $dricommand = '*PRTYRPL'
500cDC*                  eval      $drisubcmd  = '*CRTRPLSQ1'
500cMC                   eval      $drisubcmd  = '*CRTRPFSQ1'

500bAC                   eval      $drisys2upd = 'D'
500bAC                   exsr      zzzdricop
500bAC                   if        error = *on
500bA*   Note, following two lines for debugging purposes.
500bAC*                  eval      errmsg = $drimessage
500bAC*                  exsr      zm0105
500bAC                   eval      error = *off
500bAC                   endif
     *
500bAC     endrepl       endsr

500bA*----------------------------------------------------------------
500bA*  ZZslot  - write record to SLOTOUT file
500bA*----------------------------------------------------------------
500bAC     zzslot        begsr

500bAC                   clear                   sorec
500bAC                   eval      sowhse  = w1whse
500bAC                   eval      sowhdp  = lbwhdp
500bAC                   eval      sodisp  = lbdisp
500bAC                   eval      soitem  = lbitem
500bAC                   time                    currstamp
500bAC                   eval      soadts = currstamp
500bAC                   eval      soaby  = #user
     *
500bAC                   write     sorec
500bAC     endslot       endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     C                   move      *off          error
     *
     *         On to screen 2...
     C                   exsr      scr02i
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     *
     C                   move      *off          error
500dA*
500dA*    Replenishment check isn't done for Merge records.
500dA*    and only when Runner Flag is cleared if qty not found.
500dAC                   if        lbtype <> 'M'
500dAC                             and opclrf = 'N'
500bA*
500bA*    Check for open letdown and/or priority replenishment. If found,
500bA*    don't create new priority replenishment.
500bAC                   call      'GETREPL'
500bAC                   parm      '*LTDWNPRTY'  $pcmd10          10
500bAC                   parm      lbwhse        $pwhse            3 0
500bAC                   parm      lbwhdp        $pwhdp            5
500bAC                   parm      lbdisp        $pdisp           12
500bAC                   parm      lbitem        $pitem           15
500bAC                   parm      0             $ptrn#            7 0
500bAC                   parm      0             $pseq#            5 0
500bAC                   parm      *blanks       $prtn             8
500bAC                   select
500bA*
500bA*    Open Letdown and/or Priority Replenishment found for item.
500bAC                   when      $prtn = '*OK'
500bAC                   eval      $drireturn = '*OK'
500bA*
500bA*    No open Letdown and/or Priority Replenishment found.
500bAC                   other
     *
500bA*
500bA*    Check if record in SLOTOUT file, if not found, attempt replenishment,
500bA*    if replenishment fails, write a SLOTOUT record and continue on.
500dM*    If record in SLOTOUT, create Runner entry with type U=Out.
500bAC                   eval      $drireturn = *blanks
500bAC     keyso         chain (n) slotout
500bAC                   If        not %found(Slotout)
500bAC                   exsr      zzrepl
500bAC                   if        $drireturn <> '*OK'
500bAC                   eval      error = *off
500bAC                   exsr      zzslot
500bAC                   endif
500bAC                   endif
500bA*
500bAC                   endsl
500bA*
500dAC                   endif
500fA*
500fA*      Update Label record with qty short and not Merge label.
500fAC                   if        opuplr = 'Y' and lbtype <> 'M'
500fAC                   eval      $pcmd = '*MANFLAG'
500fAC                   eval      $plbl# = w1lbl#
500fAC                   eval      $pqty  = w2qyso
500fAC                   call      'PT132PL'
500fAC                   parm                    $pcmd
500fAC                   parm                    $plbl#
500fAC                   parm                    $pqty
500fAC                   endif

     C     W1lbl#        chain     Record
     C                   If        Not %found(Label)
     C                   eval      error = *on
     C                   movel     desc(2)       errmsg
     C                   exsr      zm0105
     *
     C                   else
500dA*
500dA*    Merge records set to 'I'.
500dAC                   select
500dAC                   when      lbtype = 'M'
500dAC                   eval      lbvrfy = 'I'
500dA*
500dAC                   other
500dA*
500dAC                   if        $drireturn = '*OK'
500dAC                             or opclrf = 'Y'
     C                   move      'F'           lbvrfy
500dAC                   else
500dAC                   eval      lbvrfy = 'I'
500dAC                   endif
500dAC                   endsl
     *
     C                   Update    Record
     *
     C                   If        %Error
     C                   eval      error = *on
     C                   Eval      errmsg = desc(9) + ' ' +
     C                               %trim(%editc(w1lbl#: '4'))
     C                   exsr      zm7872
     C                   Else
     *
     *  Check if label in Runner file and Deleted status. If deleted,
     *  okay to re-add.
500dDC*    W1lbl#        chain     runner
500dMC     keyru         chain     runner
     C                   If        Not %found(Runner)
     C                   Clear                   Rurec
     C                   Eval      ruwhse = lbwhse
710aAC                   exsr      zzitemfld
500dA*
500dA*  Use item's dept. when adding Merge record. Dept in
500dA*  Merge record is actually item zone.
500dAC                   If        lbtype = 'M'
500dAC                   Eval      ruwhdp = itwhdp
500dAC                   Else
     C                   Eval      ruwhdp = lbwhdp
500dAC                   Endif
500dA*
     C                   Eval      rulbl# = lblbl#
     C                   Eval      rudisp = lbdisp
500dAC                   Eval      ruoqys = w2qyso
     C                   Eval      ruqyso = w2qyso
     C                   Eval      ruotrn = lbtrn#
500dA*
500dA*    When Merge label, set flag type M=Merge.
500dAC                   select
500dAC                   when      lbtype = 'M'
500dAC                   eval      rutype = lbtype
500dA*
500dA*    Item can be replenished, set type to N=Normal.
500dA*    or Flags are cleared even if entire qty isn't found.
500dAC                   when      $drireturn = '*OK'
500dAC                             or opclrf = 'Y'
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
500dAC                   eval      rutype = 'N'
710aAC                   EndIf
500dA*
500dA*    Item can't be replenished, set type to U=Out.
500dAC                   other
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
500dAC                   eval      rutype = 'U'
710aAC                   EndIf
500dAC                   endsl
500dA*
     C                   Eval      rustat = 'O'
     *
     C                   time                    currstamp
     C                   eval      ruodts = currstamp
     *
     C                   write     rurec
     *
     *  Update Runner file.
     C                   Else
     *
     C                   Eval      ruwhse = lbwhse
500dA*
500dA*  Use item's dept. when adding Merge record. Dept in
500dA*  Merge record is actually item zone.
500dAC                   If        lbtype = 'M'
500dAC                   Eval      ruwhdp = itwhdp
500dAC                   Else
     C                   Eval      ruwhdp = lbwhdp
500dAC                   Endif
500dA*
     C                   Eval      rulbl# = lblbl#
     C                   Eval      rudisp = lbdisp
500dAC                   Eval      ruoqys = w2qyso
     C                   Eval      ruqyso = w2qyso
     C                   Eval      ruqyfd = 0
     C                   Eval      ruotrn = lbtrn#
     C                   Eval      rutrn# = 0
500dA*
500dA*    When Merge label, set flag type M=Merge.
500dAC                   select
500dAC                   when      lbtype = 'M'
500dAC                   eval      rutype = lbtype
500dA*
500dA*    Item can be replenished, set type to N=Normal.
500dA*    or Flags are cleared even if entire qty isn't found.
500dAC                   when      $drireturn = '*OK'
500dAC                             or opclrf = 'Y'
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
500dAC                   eval      rutype = 'N'
710aAC                   EndIf
500dA*
500dA*    Item can't be replenished, set type to U=Out.
500dAC                   other
710aAC                   If        (lbutyp = '1' or
710aAC                             lbutyp = '2') and
710aAC                             UCISelect
710aAC                   eval      rutype = 'B'
710aAC                   else
500dAC                   eval      rutype = 'U'
710aAC                   EndIf
500dAC                   endsl
500dA*
     C                   Eval      rustat = 'O'
     *
     C                   time                    currstamp
     C                   eval      ruodts = currstamp
     C                   eval      rupdts = *loval
     C                   eval      rucdts = *loval
     C                   update    rurec
     *
     C                   if        %error
     C                   eval      error = *on
     C                   Eval      errmsg = desc(10) + ' ' +
     C                               %trim(%editc(w1lbl#: '4'))
     C                   exsr      zm7872
     C                   endif
     *
     C                   endif
     C                   endif
     *
     C                   if        error = *off
     C                   Eval      errmsg = 'Lbl' + ' ' +
     C                             %trim(%editc(w1lbl#: '4')) + ' flagged.'
     C                   exsr      zm0105
     C                   Endif
     *
     C                   Endif
     *
     *    Return to first screen. Scan next label number.
     C                   If        Error = *off
     C                   exsr      scr01i
     C                   Endif
     *
     C     endupd2       endsr
     *
710aA*----------------------------------------------------------------
710aA*
710aA*  ZZITEMFLD Get item field infotmation for Box Breaker runner
710aA*
710aA*    Input:  KYWHSE, KYITEM
710aA*
710aAC     zzitemfld     begsr
710aAC                   Eval      UCISelect = *Off
710aAC     itkey         chain     itemfld

710aAC                   If        %Found(itemfld)
710aAC                   Select

710aAC                   When      IFSLTMTH = '2'
710aAC                   Eval      UCISelect = *On

710aAC                   Other
710aAC                   EndSl
710aAC                   EndIf

710aAC                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Label number
Invalid Label#
Lbl already flagged.
Lbl already closed.
Wrong label type.
Short/out qty <= 0.
Qty > Pick qty.
Lbl already entered.
Lbl not updated.
Runner not updated.
Transaction not ended. Still being picked.
Transaction still open. Has not been picked.
Short/out qty > 5.
Merge label type not Allowed.
