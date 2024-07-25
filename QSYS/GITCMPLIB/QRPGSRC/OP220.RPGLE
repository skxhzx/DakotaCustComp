      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OP220     PIR options - Replenishment
     *  11 January 2000
     *  Max Blacknik
     *
     *  Revisions
     *
413 A*    01/11/00  MLB  4.13
     *      - Created.
     *
414aA*    07/17/00  MLB  4.14a
     *      - Added new field OPOQRP Order qty replenishment to *REPLEN
     *        options.
     *      - Added new routine ZM0125.
     *
416aA*    12/18/01  MLB  4.16a
     *      - Added 2 new fields to screen: W1RPEX, W1RPFI
     *
417 A*    04/14/03  MLB  4.17
     *      - Enh: Added 1 new field. OPLMTS - Limit number of overflow
     *        locations listed.
500 A*    04/13/06  RH   5.00
     *      - Enh: Added 1 new field. OPCQTY - Force user to check
     *        "To Slot" quantity in replenishment/letdown/transfers.
510aA*    07/12/06  RH   5.10a
     *      - Enh: Added 1 new field. OPBDRP - Check for bulk drops
640Aa*    03/01/12  LMC  6.40a
     *      - Enh: Added 1 new field. OPRSRT - Sort Repl Option
650aA*    10/30/14  RBD  6.50a
     *      - Enh: Added new field OPSKPR, Skip if pick slot physical
     *        quantity is greater than item replenishment level.
650bA*    03/02/15  RBD  6.50b
     *      - Enh: Added new field OPJITW. During specific slot repl
     *        if this option equals N don't bother checking for JIT's as
     *        the user does not want the JIT notification window.
700aA*    05/13/16  JCJ  7.00a
     *      - Enh: Added new field OPLQTY. This will display Specific
     *        Pick slots w/Qty less then OPLQTY.                      as
720 A*    02/23/18  KDE  7.20
     *      - Enh: Added option to specify whether customer could scan
     *        License as well as Pick Slot to initiate Specif Slot Replen
     *        Example is Marque's to do specific Slot replen on store slots
     *        which come from a staging area.  Therefore they receive a pallet
     *        where each item has a license and then prompted for pick slot
     *      - Added screen two because we have added a second option to
     *        specify a Slot Type for store replens when store and warehouse?
     *        both have a pick slot for given item
740 A*    08/18/20  KDE  7.40
     *      - Enh: Added option to specify whether operator is prompted to
     *        do outstanding Drop Pick Replenishments
750aA*    08/13/21  KDE  7.50a
     *      - Enh: Added option to specify Max items per Drop Pick Slot
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
640aD*OP220FM CF  E                    WORKSTN
650aDF*op22001   cf   e             workstn
650bDF*op22002   cf   e             workstn
700aDF*op22003   cf   e             workstn
720 DF*op22004   cf   e             workstn
740 DF*op22005   cf   e             workstn
750aDF*op22006   cf   e             workstn
750aMFop22007   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
720 AFslotdef   if   e           k disk
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416aD*                   DESC    1   9 30
417 D*                   DESC    1  11 50
500 D*                   DESC    1   5 50
510aD*                   DESC    1   6 50
640aD*                   DESC    1   7 50
650aDD*desc            s             50    dim(8) ctdata perrcd(1)
650bDD*desc            s             50    dim(9) ctdata perrcd(1)
700aDD*desc            s             50    dim(10) ctdata perrcd(1)
720 DD*desc            s             50    dim(11) ctdata perrcd(1)
740 DD*desc            s             50    dim(13) ctdata perrcd(1)
740 MD desc            s             50    dim(14) ctdata perrcd(1)
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
     *----------------------------------------------------------------
     *  *REPLEN  -  Replenishment options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY)
414aA*    OPOQRP  -  Order qty replenishment (Y/N).
416aA*    OPRPEX  -  Allow replenishment on expired items.
416aA*               1=Allow, 2=Don't allow, 3=Warn
416aA*    OPRPFI  -  Allow replenishments out of FIFO order.
416aA*               1=Allow, 3=Warn
417 A*    OPLMTS  -  Limit Specific Slot replenishment program to
417 A*               to display only one overflow location at a
417 A*               time. (Y/N)
500 A*    OPCQTY  -  Force user to check "To Slot" quantity for
500 A*               replenishment/letdown/transfers.
510aA*    OPBDRP  -  Check for Bulk Drops
640aA*    OPRSRT  -  Sort Replenishments (*DEMAND, *TOSLOT)
650aA*    OPSKPR  -  Skip if pick slot physical qty is greater than
650aA*               item replenishment level.
650bA*    OPJITW  -  During specific slot repl if this option = N don't
650bA*               bother checking for JIT's as the user does not want
650bA*               the JIT notification window.
700aA*    OPLQTY  -  Replenish pick slots that display less than X    t
700aA*               cases.                                           nt
720 A*    OPSSLCN -  Initiate Specific Slot Replenishment from License
720 A*               scan vs. Pick Slot
720 A*    OPRZST  -  Stop Type for DRIPRTYRPL to use when Pick Slot exist
720 A*               for both Store/Remote Location and Primary Warehouse
740 A*    OPCKDD  -  Check for Drop Pick Replenishments
750aA*    OPDDMAX -  Max items for Drop Pick slots
     *
     * Data structure
     *
     D opdata          ds
     D  oprplb                 1      8
414aAD  opoqrp                 9      9
416aAD  oprpex                10     10
416aAD  oprpfi                11     11
417 AD  oplmts                12     12
500 AD  opcqty                13     13
510aAD  opbdrp                14     14
640aAD  oprsrt                15     24
650aAD  opskpr                25     25
650bAD  opjitw                26     26
700aAD  oplqty                27     28  0
700aAD  oplqtya               27     28
720 Ad  opsslcn               29     29
720 Ad  oprzst                30     31
740 Ad  opckdd                32     32
750aAd  opddmax               33     34  0
     D  optend               117    117
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
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
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
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
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
     D tmpflg          s              1
     D warn            s              1
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
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
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
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
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
     C                   exfmt     screen1                              50
     *
     C                   when      nxtscr = '02 '
720 Ac                   exfmt     screen2                              50
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
720 AC                   setoff                                       4142
720 AC                   setoff                                       4344
740 AC                   setoff                                       4546
     C                   setoff                                       98
     C                   setoff                                         63
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
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
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
     C     *loval        setll     record
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = '02'
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     '1'           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     '1'           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
     C                   eval      sclear = *on
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
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
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
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
414aA*----------------------------------------------------------------
414aA*   PIR0125  Replenishment basis must be *ORDQTY...
414aA*
414aAC     zm0125        begsr
414aAC                   eval      #msgid = 'PIR0125'
414aAC                   eval      #msgtp = '*DIAG  '
414aAC                   movea     errmsg        $md
414aAC                   exsr      zmpmsg
414aAC                   endsr
     *----------------------------------------------------------------
     *     PIR1001  Invalid code.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify replenishment basis.
     *
     C                   if        w1rplb <> '*AVGQTY'  and
     C                             w1rplb <> '*ORDQTY'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
414aA*
414aA*  Verify order qty replenishments flag.
414aA*
414aAC                   if        w1oqrp <> 'Y'  and
414aAC                             w1oqrp <> 'N'
414aAC                   eval      error = *on
414aAC                   eval      *in22 = *on
414aAC                   eval      *in02 = *on
414aAC                   eval      errmsg = *blanks
414aAC                   eval      errmsg = desc(2)
414aAC                   exsr      zm1005
414aAC                   endif
414aA*
414aA*  If order qty replenishment flag is "Y", then
414aA*  replenishment basis must be *ORDQTY.
414aA*
414aAC                   if        w1rplb <> '*ORDQTY '  and
414aAC                             w1oqrp = 'Y'
414aAC                   eval      error = *on
414aAC                   eval      *in22 = *on
414aAC                   eval      *in02 = *on
414aAC                   eval      errmsg = *blanks
414aAC                   exsr      zm0125
414aAC                   endif
640aA*
640aA*  Verify Sort Replenishment Option.
640aA*
640aAC                   if        w1rsrt <> '*DEMAND'  and
640aAC                             w1rsrt <> '*TOSLOT'
640aAC                   eval      error = *on
640aAC                   eval      *in28 = *on
640aAC                   eval      *in08 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   eval      errmsg = desc(8)
640aAC                   exsr      zm1001
640aAC                   endif
416aA*
416aA*  Replenishments on expired items must be range '1' to '3'.
416aA*
416aAC                   if        w1rpex < '1'  or
416aAC                             w1rpex > '3'
416aAC                   eval      error = *on
416aAC                   eval      *in23 = *on
416aAC                   eval      *in03 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   movel     desc(3)       erfld
416aAC                   movel     '1'           erfrom
416aAC                   movel     '3'           erto
416aAC                   exsr      zm0112
416aAC                   endif
416aA*
416aA*  Replenishments out of FIFO order must be '1' or '3'.
416aA*
416aAC                   if        w1rpfi < '1'  or
416aAC                             w1rpfi = '2'  or
416aAC                             w1rpfi > '3'
416aAC                   eval      error = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   eval      errmsg = desc(4)
416aAC                   exsr      zm1001
416aAC                   endif
417 A*
417 A*  Verify order qty replenishments flag.
417 A*
417 AC                   if        w1lmts <> 'Y'  and
417 AC                             w1lmts <> 'N'
417 AC                   eval      error = *on
417 AC                   eval      *in25 = *on
417 AC                   eval      *in05 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   eval      errmsg = desc(5)
417 AC                   exsr      zm1005
417 AC                   endif
500 A*
500 A*  Verify force check 'To Slot' quantity for repl/letdn/trnsfr
500 A*
500 AC                   if        w1cqty <> 'Y'  and
500 AC                             w1cqty <> 'N'
500 AC                   eval      error = *on
500 AC                   eval      *in26 = *on
500 AC                   eval      *in06 = *on
500 AC                   eval      errmsg = *blanks
500 AC                   eval      errmsg = desc(6)
500 AC                   exsr      zm1005
500 AC                   endif
510aA*
510aA*  Verify check for Bulk Drops.
510aA*
510aAC                   if        w1bdrp <> 'Y'  and
510aAC                             w1bdrp <> 'N'
510aAC                   eval      error = *on
510aAC                   eval      *in27 = *on
510aAC                   eval      *in07 = *on
510aAC                   eval      errmsg = *blanks
510aAC                   eval      errmsg = desc(7)
510aAC                   exsr      zm1005
510aAC                   endif
     *
650aA*  Verify check for Skip if pick slot physical quantity
650aA*  is greater than item replenishment level.
650aA*
650aAC                   if        w1skpr <> 'Y'  and
650aAC                             w1skpr <> 'N'
650aAC                   eval      error = *on
650aAC                   eval      *in29 = *on
650aAC                   eval      *in09 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      errmsg = desc(9)
650aAC                   exsr      zm1005
650aAC                   endif
     *
650bA*  Verify check for Show JIT win during spec slot repl.
650bA*
650bAC                   if        w1jitw <> 'Y'  and
650bAC                             w1jitw <> 'N'
650bAC                   eval      error = *on
650bAC                   eval      *in30 = *on
650bAC                   eval      *in10 = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(10)
650bAC                   exsr      zm1005
650bAC                   endif
     *
700aA*  Verify repl. pick slot less then quantity.
700aA*
700aAC                   if        w1lqty < 1
700aAC                             or w1lqty > 99
700aAC                   eval      error = *on
700aAC                   eval      *in31 = *on
700aAC                   eval      *in11 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   eval      errmsg = desc(11)
700aAC                   exsr      zm1005
700aAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
720 A*
720 A*  Verify check for Scan License to begin Specific Slot
720 A*
720 AC                   if        w2sslcn <> 'Y'  and
720 AC                             w2sslcn <> 'N'
720 AC                   eval      error = *on
720 AC                   eval      *in41 = *on
720 AC                   eval      *in42 = *on
720 AC                   eval      errmsg = *blanks
720 AC                   eval      errmsg = desc(12)
720 AC                   exsr      zm1005
720 AC                   endif
720 A*
720 A*  Verify Slot Type for use when Pick Slot in both Store and Warehouse
720 A*
720 A /free
720 A                 if w2rzst<>*blanks;
720 A                 chain ($pwhse:w2rzst) slotdef;
720 A /end-free
720 AC                   if        not %found(slotdef)
720 AC                   eval      error = *on
720 AC                   eval      *in43 = *on
720 AC                   eval      *in44 = *on
720 AC                   eval      errmsg = *blanks
720 AC                   eval      errmsg = desc(13)
720 AC                   exsr      zm1001
720 AC                   endif
720 AC                   endif
740 A*
740 A*  Verify check for Drop Pick License entry
740 A*
740 AC                   if        w2chkdd <> 'Y'  and
740 AC                             w2chkdd <> 'N'
740 AC                   eval      error = *on
740 AC                   eval      *in45 = *on
740 AC                   eval      *in46 = *on
740 AC                   eval      errmsg = *blanks
740 AC                   eval      errmsg = desc(14)
740 AC                   exsr      zm1005
740 AC                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      oprplb = '*AVGQTY '
414aAC                   eval      opoqrp = 'N'
416aAC                   eval      oprpex = *on
416aAC                   eval      oprpfi = *on
417 AC                   eval      oplmts = 'N'
500 AC                   eval      opcqty = 'N'
510aAC                   eval      opbdrp = 'N'
640aAC                   move      '*DEMAND '    oprsrt
650aAC                   eval      opskpr = 'N'
650bAC                   eval      opjitw = 'Y'
700aAC                   eval      oplqty = 05
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
720 Ac                   eval      w2rzst = *blanks
720 Ac                   eval      w2sslcn = 'N'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1rplb = oprplb
414aAC                   eval      w1oqrp = opoqrp
416aAC                   eval      w1rpex = oprpex
416aAC                   eval      w1rpfi = oprpfi
417 AC                   eval      w1lmts = oplmts
500 AC                   eval      w1cqty = opcqty
510aAC                   eval      w1bdrp = opbdrp
640aAC                   eval      w1rsrt = oprsrt
650aAC                   eval      w1skpr = opskpr
650bAC                   eval      w1jitw = opjitw
700aAC                   if        oplqtya <> *blanks
700aAC                   eval      w1lqty = oplqty
700aAC                   else
700aAC                   eval      w1lqty = 5
700aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
720 Ac                   eval      w2sslcn = opsslcn
720 Ac                   eval      w2rzst = oprzst
740 Ac                   eval      w2chkdd = opckdd
750aAc                   monitor
750aAc                   eval      w2ddmax = opddmax
750aAc                   on-error
750aAc                   eval      w2ddmax = 0
750aAc                   endmon
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*REPLEN '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt1        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft1
     C                   write     record
     C                   goto      beggt1
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
720 Ac                   eval      w2sslcn = opsslcn
720 Ac                   eval      w2rzst = oprzst
740 Ac                   eval      w2chkdd = opckdd
750aAc                   monitor
750aAc                   eval      w2ddmax = opddmax
750aAc                   on-error
750aAc                   eval      w2ddmax = 0
750aAc                   endmon
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      oprplb = w1rplb
414aAC                   eval      opoqrp = w1oqrp
416aAC                   eval      oprpex = w1rpex
416aAC                   eval      oprpfi = w1rpfi
417 AC                   eval      oplmts = w1lmts
500 AC                   eval      opcqty = w1cqty
510aAC                   eval      opbdrp = w1bdrp
640aAC                   eval      oprsrt = w1rsrt
650aAC                   eval      opskpr = w1skpr
650bAC                   eval      opjitw = w1jitw
700aAC                   eval      oplqty = w1lqty
     *
     *   Update record (it was read and locked in ZZGET1)
     *
720 DC*                  update    record                               79
720 DC*                  if        *in79
720 DC*                  eval      error = *on
720 DC*                  exsr      zm72
720 DC*                  goto      endupd
720 DC*                  endif
720 Ac                   exsr      scr02i
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
720 Ac                   eval      opsslcn = w2sslcn
720 Ac                   eval      oprzst = w2rzst
740 Ac                   eval      opckdd = w2chkdd
750aAc                   eval      opddmax= w2ddmax
     *
     *   Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup2
     C                   endif
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Replenishment basis                                        1
Order qty replenishment                                    2
Replenishment on expired items                             3
Replenishment out of FIFO order                            4
Limit Specific Slot Replen overflow slots                  5
Check "To Slot" quantity                                   6
Check for Bulk Drops                                       7
Sort Replenishment                                         8
Skip if pick slot physical ...                             9
Show JIT win during spec slot repl                        10
Invalid Quantity must be between 1-99                     11
Scan License to initiate Specific Slot                    12
Slot Type                                                 13
Check for Drop Pick Replenishments                        14
