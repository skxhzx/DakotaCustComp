      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LT325     View LICLOG file - View record
     *  02 November 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    11/02/10  DAS  6.10
     *      - Created
     *
610aA*    11/10/10  DAS  6.10a
     *      - Added route/po info to transaction line.
640aA*    03/24/11  RH   6.40a
     *      - Fix: Change to use LLADDTS date/time stamp in place
     *        of LLADDUC .
640bA*    06/02/11  DAS  6.40b
     *      - Recompiled because of change to LICLOG file.
700aA*    08/26/16  DAS  7.00a
     *      - For item change, displaying corresponding item within ().
710aA*    10/17/17  RH   7.10a
     *      - Enh: Add cust # and name for SEL action.                .
770aA*    02/23/23  RH   7.70a
     *      - Enh: Add host lot from LICINFO to screen.               .
     *
     *----------------------------------------------------------------
     *    Custom Modification
     *
CBIaA*    03/01/18  TDF  Work List 2017083
     *      - Replace "SAPUSR" with employee id
     *----------------------------------------------------------------
     *    Custom Modification - Southwest Traders
SWTaA*    06/05/19  NLK  SWTa
     *      - Enh: Use 8 digit order number from ORDHEXA              .
     *
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

710aMF*lt325fm   cf   e             workstn
710aAFlt32501   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fliclog    if   e           k disk
700aAFliclog4   if   e           k disk    rename(llrec:llrec4)
700aAF                                     prefix(l4_)
710aAFordh      if   e           k disk
SWTaAFordhexa   if   e           k disk
610aAFpirtran   if   e           k disk
610aAFrtehed    if   e           k disk
CBIaAFpiruser1  if   e           k disk
CBIaAFlicactive if   e           k disk
CBIaAFimpsrcvp2 if   e           k disk
770aAFlicinfo   if   e           k disk

CBIaA /COPY QCOPYSRC,ID#cheney
SWTaA /COPY QCOPYSRC,ID#swt
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

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
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1

     D kywhse          s                   like(llwhse)
     D kylcns          s                   like(lllcns)
     D kyrtid          s                   like(rhrtid)
     D kyadduc         s                   like(lladduc)
700aAD kyltrnseq       s                   like(llltrnseq)
710aAD kyord           s                   like(llord)
770aAD kyseq           s                   like(lnseq)

     D $ladduc         s             26
     D $lcmd           s              8
     D $llcns          s             15
     D $ltrn#          s              7
     D $lwhse          s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command: *CHANGE, *VIEW
     *      $PWHSE  Warehouse code.
     *      $PLCNS  License.
     *      $PDDUC  UC Timestamp.
     *
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $plcns           15
     C                   parm                    $padduc          26

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
     C                   exsr      zzinz2
     *
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
     C                   eval      nxtscr = 'EOJ'
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
     *
     C                   eval      nxtscr = 'EOJ'
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
CBIaA* Get client id.
CBIaA*
CBIaAC                   call      'GETCLIENT'
CBIaAC                   parm                    client           10
CBIaAC                   parm                    clientloc        10
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
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off
     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off

     *  Test for F7 - License log record detail

 2B  C                   if        *inkg
     C                   eval      cmdtkn = *on
     C                   call      'LL830'
     C                   parm      '*VIEW'       $lcmd
     C                   parm      $pwhse        $lwhse
     C                   parm      $plcns        $llcns
     C                   parm      $padduc       $ladduc
 1E  C                   endif

     *  Test for F8 - Transaction record detail

 2B  C                   if        *inkh
     C                   eval      cmdtkn = *on
 2B  C                   if        lltrn# > 0
     C                   eval      $ltrn# = %editc(lltrn#:'X')
     C                   call      'PT830'
     C                   parm      '*VIEW'       $lcmd
     C                   parm                    $ltrn#
 2B  C                   endif
 1E  C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   eval      *in90 = *on

     *   Get LICLOG Fields

     C     lclog         chain     liclog

     *  Log record not found, get out.

     C                   if        not %found(liclog)
     C                   eval      w1action = ' '
     C                   eval      w1lcns   = %trim($plcns) + ' / '
     C                                      + %trim($padduc) + ' - '
     C                                      + 'License Log Record Not Found'
     C                   eval      w1dtetim = ' '
     C                   eval      w1user   = ' '
     C                   eval      w1aqty   = ' '
     C                   eval      w1rqty   = ' '
     C                   eval      w1tran   = ' '
710aAC                   eval      w1cnam   = ' '
     C                   eval      w1item   = ' '
     C                   eval      w1slot   = ' '
     C                   leavesr
     C                   endif

     *  Log record found, initialize screen fields.

     *    Action

     C                   eval      w1action = llaction

     *    License (including From and Original licenses)

     C                   eval      w1lcns = %trim(lllcns)

     C                   if        llflcns <> ' ' and llflcns <> lllcns
     C                   eval      w1lcns = %trim(w1lcns) + '  '
     C                                    + 'From: ' + %trim(llflcns)
     C                   endif

     C                   if        llolcns <> ' ' and llolcns <> lllcns
     C                   eval      w1lcns = %trim(w1lcns) + '  '
     C                                    + 'Orig: ' + %trim(llolcns)
     C                   endif

     *    Date/Time

640aDC*                  eval      w1dtetim = %char(%date(lladduc):*mdy/) + '  '
640aDC*                                     + %char(%time(lladduc):*hms:)
640aMC                   eval      w1dtetim = %char(%date(lladdts):*mdy/) + '  '
640aMC                                      + %char(%time(lladdts):*hms:)
770aA
770aA*    Host Lot Code
770aA
770aAC                   eval      kyseq = 1
770aAC     lcikey        chain(e)  licinfo
770aAC                   if        %found(licinfo)
770aAC                   eval      w1hlot = lnlot
770aAC                   endif


     *    User/Employee #

     C                   eval      w1user = %trim(lladdeusr) + ' - '
     C                                    + %trim(%editc(lladdemp:'P'))

CBIaAC                   if        client = Cheney
CBIaAC                                and w1action = 'RCV '
CBIaAC                   exsr      fndusr
CBIaAC                   endif
     *    Action qty

     C                   eval      w1aqty   = %trim(%editc(llaqty1:'P'))

     C                   if        llaqty2 > 0 or llaqty3 > 0
     C                   eval      w1aqty = %trim(w1aqty) + '.'
     C                                    + %trim(%editc(llaqty2:'P'))
     C                   endif

     C                   if        llaqty3 > 0
     C                   eval      w1aqty = %trim(w1aqty) + '.'
     C                                    + %trim(%editc(llaqty3:'P'))
     C                   endif

     *    Resulting qty

     C                   eval      w1rqty   = ' '
     C                   eval      w1rqty   = %trim(%editc(llrqty1:'P'))

     C                   if        llrqty2 > 0 or llrqty3 > 0
     C                   eval      w1rqty = %trim(w1rqty) + '.'
     C                                    + %trim(%editc(llrqty2:'P'))
     C                   endif

     C                   if        llrqty3 > 0
     C                   eval      w1rqty = %trim(w1rqty) + '.'
     C                                    + %trim(%editc(llrqty3:'P'))
     C                   endif

     *    Transaction

610aAC     lltrn#        chain(e)  pirtran
610aAC                   if        not %found(pirtran)
610aAC                   eval      ptrtpo = ' '
610aAC                   eval      ptcat  = ' '
610aAC                   endif

     C                   if        lltrn# = 0
     C                   eval      w1tran = ' '
     C                   else
     C                   eval      w1tran = %trim(%editc(lltrn#:'P'))
     C                   endif
610aA
610aA*    Route
610aA
610aAC                   if        ptcat = 'SELECT'
610aAC                   eval      kywhse = ptwhse
610aAC                   eval      kyrtid = ptrtpo
610aAC     keyrh         chain(e)  rtehed
610aAC                   if        %found(rtehed)
610aAC                   eval      w1tran = %trim(w1tran) + '  '
610aAC                                    + 'Rte: '
610aAC                                    + %trim(rhrte) + ' / ' + %trim(ptrtpo)
610aAC                   endif
710aAC                   eval      kyord = llord
SWTa  * SWT has 8 digit CORD, check ordhexa first then use ordh
SWTaAC                   eval      ohaorda = *blanks
SWTaAC                   if        client = swt
SWTaAC     keyoh         chain(e)  ordhexa
SWTaAC                   if        %found(ordhexa)
SWTaAC                             and ohaorda > *blanks
SWTaAC                   eval      w1tran = %trim(w1tran) + '  '
SWTaAC                                    + 'Cust Ord: '
SWTaAC                                    + %trim(ohaorda)
SWTaAC                   endif
SWTaAC                   endif

710aAC     keyoh         chain(e)  ordh
710aAC                   if        %found(ordh)
SWTaAC                   if        ohaorda = *blanks
710aAC                   eval      w1tran = %trim(w1tran) + '  '
710aAC                                    + 'Cust Ord: '
710aAC                                    + %trim(%editc(ohcord:'P'))
SWTaAC                   endif

710aAC                   eval      w1cnam = ohcnam
710aAC                   endif
610aAC                   endif
610aA
610aA*    PO
610aA
610aAC                   if        ptcat = 'RECV'
610aAC                   eval      w1tran = %trim(w1tran) + '  '
610aAC                                    + 'PO: '
610aAC                                    + %trim(ptrtpo)
610aAC                   endif

     *    Item

     C                   eval      w1item = llitem

     *    Slot

     C                   eval      w1slot = %trim(llwhdp) + ' / '
     C                                    + %trim(lldisp)

700aA*    Corresponding CHG item
700aA
700aAC                   if        llaction = 'CHG' and llichg = 'Y'
700aAC                   select
700aAC                   when      llltrnseq = 1
700aAC                   eval      kyltrnseq = 2
700aAC                   when      llltrnseq = 2
700aAC                   eval      kyltrnseq = 1
700aAC                   other
700aAC                   eval      kyltrnseq = 0
700aAC                   endsl
700aAC                   if        kyltrnseq > 0
700aAC     ll4key        chain     liclog4
700aAC                   if        %found(liclog4)
700aAC                   eval      w1item = %trim(w1item) + ' '
700aAC                                    + '(' + %trim(l4_llitem) + ')'
700aAC                   endif
700aAC                   endif
700aAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for License Log File

     C     lclog         klist
     C                   kfld                    kywhse
     C                   kfld                    kylcns
     C                   kfld                    kyadduc
700aA
700aA*  Define key for License Log 4 file
700aA
700aAC     ll4key        klist
700aAC                   kfld                    llwhse
700aAC                   kfld                    llltrn
700aAC                   kfld                    kyltrnseq
770aA*  Define key for LICINFO File

770aAC     lcikey        klist
770aAC                   kfld                    kywhse
770aAC                   kfld                    kylcns
770aAC                   kfld                    kyseq
610aA
610aA*  Define key for RTEHED File
610aA
610aAC     keyrh         klist
610aAC                   kfld                    kywhse
610aAC                   kfld                    kyrtid
710aAC     keyoh         klist
710aAC                   kfld                    kywhse
710aAC                   kfld                    kyord

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *   Select first screen to display.

     C                   eval      kywhse = $pwhse
     C                   eval      kylcns = $plcns
     C                   eval      kyadduc = %timestamp($padduc)
     C                   exsr      scr01i

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   eval      error = *off
     C     endupd        endsr

CBIaA*----------------------------------------------------------------
CBIaA*  FNDUSR   Find last changed user
CBIaA*----------------------------------------------------------------
CBIaA
CBIaAC     fndusr        begsr
CBIaAc     lladdemp      chain     usrec                              38
CBIaAc                   move      *blanks       addname          10
CBIaAc                   if        *in38 = *off
CBIaAc                   movel     uscode        addname
CBIaAc                   endif
CBIaAc                   move      *blanks       chgname          10
CBIaAc                   move      *blanks       chgout            8
CBIaAc                   move      *blanks       colonout          3
CBIaAc                   move      'RECEIVER'    chgout
CBIaAc                   eval      colonout = ':  '
CBIaAc*---- Get receiver from IMPSRCVP2
CBIaAc     impkey        klist
CBIaAc                   kfld                    rcpwhse
CBIaAc                   kfld                    rcpstatus
CBIaAc                   kfld                    rcplcns
CBIaAc                   eval      rcpwhse   = llwhse
CBIaAc                   eval      rcpstatus = 'S'
CBIaAc                   eval      rcplcns   = lllcns
CBIaAc     impkey        chain     rcprec                             38
CBIaAc                   if        *in38 = *off
CBIaAc                   movel     RCPUSR        chgname
CBIaAc                   endif
CBIaAC*---
CBIaAc*--------------------------------
CBIaAC******             eval      w1user = %trim(addname) + ' - '
CBIaAC*******                             + %trim(%editc(lladdemp:'P'))
CBIaAC*******                             + '   '
CBIaAC                   eval      w1user = chgout
CBIaAC                                    + colonout
CBIaAC                                    + %trim(chgname)
CBIaAC****                                + ' - '
CBIaAC****                                + %trim(%editc(chgemp:'Z'))
CBIaAC                   endsr
