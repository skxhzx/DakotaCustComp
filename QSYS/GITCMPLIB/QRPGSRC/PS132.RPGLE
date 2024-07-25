417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PS132     Truck build full pallet move
     *  29 September 2000
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    09/29/00  DAS  4.14
     *      - Created
     *
415 A*    02/20/01  DAS  4.15
     *      - Revised to update unload seq and pallet numbers of a
     *        bulk pick record when it is moved.
     *
416 A*    02/11/02  MLB  4.16
     *      - Revised to call correct program. Should call
     *        TM910 instead of TP900.
     *      - Revised to pass warehouse to TM910.
     *      - Added warehouse to key for TRKCOMP.
     *
     *
416aA*    12/17/02  DAS  4.16a
     *      - Added $PZONE to $PARMS.
     *      - Added subroutine ZM4204.
     *      - Added new error fields ERZON1/2.
     *      - Added gotos to ZZCHK1.
     *      - Revise ZZCHK1 to compare zones of "from" and "to" pallet
     *      - Revised ZZUPD1 to update "to" truck and slot zones.
     *
417 A*    07/10/03  DAS  4.17
     *      - Revised to allow a pallet to be moved into a different
     *        compartment IF the To pallet position is empty.
     *
417aA*    08/22/03  DAS  4.17a
     *      - Revised logic to update pallet range to take into
     *        account *SP pallets, which have PSSTP2 = 0.
417bA*    09/02/03  DAS  4.17b
     *      - Added another condition to 417a.
     *
500 A*    05/03/06  DAS  5.00
     *      - Revised to allow a pallet with only Merge records to
     *        be moved to a different compartment and/or zone.
     *
510aA*    12/17/06  DAS  5.10a
     *      - Converted to ILE
     *
510cA*    11/14/07  JCJ  5.10c
     *      - Fix: There is an existing problem which a pallet move
     *        in rare cases combines pick zones with diferent
     *        attributes, ie Dry and Ref items on the same pallet.
     *        To fix this the ZZFIL1 routine is being changed to
     *        unconditionally update the compartment code, unload
     *        sequence number, and Truck zone.
     *
520aA*    04/28/08  DAS  5.20a  P#00046
     *      - Revised opening of PS132FM to user defined.
     *      - Added command *DROP to just perform drop without
     *        using any screens (To pallet is passed in).
     *
520bA*    04/28/08  JCJ  5.20b
     *      - added call PS162 for combining selection labels.
     *
520cA*    07/10/08  DAS  5.20c
     *      - Reversed 500 change until it becomes a user defnined opt.
     *
520eA*    07/24/09  JCJ  5.20e
     *      - Fix: When moving an empty pallet onto another pallet the
     *        stop ranges gets updated incorrectly.  If another non
     *        empty pallet move is performed the stop range on this
     *        pallet will correct itself.
     *        This fix keeps the stop range from getting updated
     *        incorrectly when an empty pallet move is done.
     *
650aA*    03/28/13  DAS  6.50a
     *      - Enh: Added DDLOGing. Needs program WRTDDLOG.
     *
650bA*    03/28/13  DAS  6.50b
     *      - Enh: Added check to see if route has already been
     *        processed (pltsum rec has a tran#).
     *
730aA*    10/15/19  DAS  7.30a
     *      - Revised to use WORKLBLW
     *
     *----------------------------------------------------------------
     *  Notes
     *
520aA*    For *DROP, $PROW/$PCOL will contain the "To" row/col. They
520aA*    will be set back to the "From" row/col in ZZFIL1.
     *
520bA*    When an order detail line is split between pallets, even if
520bA*    a user catches the split and puts both parts onto the same
520bA*    pallet, 2 label records still exist to pick the single
520bA*    detail line.  Therefore, PS162 was created to identify
520bA*    that situation and merge the split label records into a
520bA*    single label record.
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
     Fps132fm   cf   e             workstn
520aAF                                     usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpltsum2   uf   e           k disk
     F                                     rename(psrec:record)
     Fpltstp1   uf a e           k disk
     Fworklbl6  uf   e           k disk
730aDF*orklbl   uf   e           k disk
730aMFworklblw  uf   e           k disk
     F                                     rename(lwrec:lblrec)
     Fwarehs    if   e           k disk
     Ftrkcomp   if   e           k disk
650bAFpltsum1   if   e           k disk    prefix(ps1_)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(3) ctdata perrcd(1)
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
     D  $prte                 22     26
     D  $prtid                27     31
     D  $prow                 32     33  0
     D  $pcol                 34     34  0
     D  $pcomp                35     35
     D  $puseq                36     37  0
     D  $pplid                38     44  0
     D  $ptype                45     45
     D  $pgen                 46     46  0
416aAD  $pzone                47     52
     *
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *
416 D*                                      19  19 $LCOMP
416 MD  $lcomp                22     22
520bA*
520bAD  $lrte                 22     26
520bAD  $lpal#                27     33  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertruk                 1     10
     D  erdesc                11     30
     *
     D  enewcb                 1      4p 3
     D  emaxcb                 5      7p 2
416aA*
416aAD  erzon1                 1      6
416aAD  erzon2                 7     12
     *
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
     *----------------------------------------------------------------

520aAD useScreen       s               n

     D $msgf           s             10
     D $pprg1          s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bktype          s                   like(pstype)
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D mrgoly          s              1
     D msgk            s              4  0
     D nwcnt           s                   like(psbcnt)
     D nwcube          s                   like(pscube)
     D nwpal#          s                   like(psplid)
     D nwpal2          s                   like(pspal#)
     D nwunld          s                   like(psunld)
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D stop1           s                   like(psstp1)
     D stop2           s                   like(psstp2)
     D svbcnt          s                   like(psbcnt)
     D svcube          s                   like(pscube)
     D svpcs           s                   like(pspcs)
     D svplid          s                   like(psplid)
     D svsbsq          s                   like(pssbsq)
     D svscub          s                   like(psscub)
     D svspcs          s                   like(psspcs)
     D svspli          s                   like(psspli)
     D svsstp          s                   like(pssstp)
     D svsswt          s                   like(pssswt)
     D svstp1          s                   like(psstp1)
     D svstp2          s                   like(psstp2)
     D svswgt          s                   like(psswgt)
     D tbcnt           s              3  0
     D ukcol           s                   like($pcol)
     D ukrow           s                   like($prow)
     D ukwhse          s                   like($pwhse)
     D warn            s              1
     D w1com1          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *IBEFORE - Insert new row before row #.
     *              *IAFTER  - Insert new row after row #.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
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
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
520aA
520aA*      When "Dropping", get out and return.
520aA
520aAC                   if        $pcmd = '*DROP'
520aAC                   leave
520aAC                   endif
520aA
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   unlock    pltsum2
     C                   unlock    pltstp1
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
     C                   if        nxtscr = '01 '
520aAC                   if        useScreen
     C                   exfmt     screen1                              50
520aAC                   endif
     C                   endif
     *
     C                   if        nxtscr = '02 '
520aAC                   if        useScreen
     C                   exfmt     screen2                              50
520aAC                   endif
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
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
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
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzget2
     C                   exsr      zzfil2
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
520aMC                             $pcmd = '*CHANGE '  or
520aAC                             $pcmd = '*DROP   '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd1
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
     C                   if        $pcmd = '*ADD    '
     *R                   ADD  1         UKROW
     *R                   ADD  1         WOROW
     C                   exsr      scr01i
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
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
     C                   eval      $prtn = '*EXIT   '
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
     C                   exsr      zzchk2
     C     error         cabeq     '1'           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     '1'           endsc2
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
520aA*
520aA*  Determine if screen should be used.
520aA*
520aAC                   if        $pcmd = '*DROP'
520aAC                   eval      useScreen = *off
520aAC                   else
520aAC                   eval      useScreen = *on
520aAC                   open      ps132fm
520aAC                   endif
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     C                   eval      $pprg = #prog
     C                   eval      $pprg1 = #prog
     C                   eval      $lprg = #prog
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
520aAC                   if        useScreen
     C                   write     msgctl
520aAC                   endif
     C                   eval      msgk = *zeros
520aAC                   if        useScreen
     C                   write     msgclr
520aAC                   endif
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
520aAC                   if        useScreen
     C                   write     msgctl
520aAC                   endif
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
520aAC                   if        useScreen
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
520aAC                   endif
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
520aAC                   if        useScreen
     C                   write     msgrec
520aAC                   endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
520aAC                   if        useScreen
     C                   write     msgrec
520aAC                   endif
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
520aAC                   if        useScreen
     C                   write     clrscr
520aAC                   endif
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
520aAC                   if        useScreen
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
520aAC                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  TRUCK cannot be blank
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
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
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7982  Record changed by another user before update.
     *
     C     zm82          begsr
     C                   eval      #msgid = 'PIR7982'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PS14201  New cube for pallet is greater than max cube.
     *
     C     zm4201        begsr
     C                   eval      #msgid = 'PS14201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PS14202  Can't move product to same pallet.
     *
     C     zm4202        begsr
     C                   eval      #msgid = 'PS14202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PS14203  Can't move bulk picks, violates limit of 9 bulk picks
     *            per pallet.
     *
     C     zm4203        begsr
     C                   eval      #msgid = 'PS14203'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
416aA*----------------------------------------------------------------
416aA*   PS14204  Zone mismatch - Cannot mix items from different zones
416aA*
416aAC     zm4204        begsr
     C                   eval      #msgid = 'PS14204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
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
     C                   if        $pcmd = '*CHANGE '
520aAC                             or $pcmd = '*DROP   '

650bA*    Make sure route hasn't been processed.
650bA*    If a pltsum record has a tran# it means someone cleared
650bA*    the in-use flag allowing DD and Pick&Print to run at
650bA*    the same time.
650bA
650bA /free
650bA
650bA    setll ($pwhse: $prtid) pltsum1;
650bA
650bA    dow forevr = forevr;
650bA
650bA      reade ($pwhse: $prtid) pltsum1;
650bA      if %eof(pltsum1);
650bA        leave;
650bA      endif;
650bA
650bA      if ps1_pstrn# <> 0;
650bA        error = *on;
650bA        *in22 = *on;
650bA        *in23 = *on;
650bA        errmsg = 'Cannot move. Route already processed.';
650bA        exsr zm0105;
650bA        ddrtn = '*PRINTED';
650bA        dderm = errmsg;
650bA        if $pcmd = '*DROP';
650bA          $prtn = ddrtn;
650bA          $perm = dderm;
650bA        endif;
650aA        ddRecType = '2';
650aA        exsr zzWrtDDLOG;
650bA        leavesr;
650bA      endif;
650bA
650bA    enddo;
650bA
650bA /end-free

     *
     *    From and To row/col can't be the same.
     *
     C                   if        w1row = $prow  and
     C                             w1col = $pcol
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     *R                   MOVE *ON       *IN02
     C                   eval      errmsg = *blanks
     C                   exsr      zm4202
650aAC                   eval      ddrtn = '*SAMEPLT'
650aAC                   eval      dderm = 'Cannot drop on same pallet'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
     C                   endif
     *
     *    Make sure 'To' rec exists in PLTSUM2
     *
     C                   eval      ukrow = w1row
     C                   eval      ukcol = w1col
     C     psumky        chain(n)  pltsum2                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
650aAC                   eval      ddrtn = '*INVLDTO'
650aAC                   eval      dderm = 'Drop pallet not found '
650aAC                                   + 'for row/col '
650aAC                                   + %editc(ukrow:'P')
650aAC                                   + '/'
650aAC                                   + %editc(ukcol:'P')
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
417 D**                   ELSE
417 MC                   endif
500 A*
500 A*    See if pallet only contains Merge records.
500 A*
500 AC                   eval      mrgoly = *on
500 AC                   eval      svspli = $pplid
500 AC     lbl6ky        setll     worklbl6
500 AC                   dow       forevr = forevr
500 AC     lbl6ky        reade(n)  worklbl6                               79
500 AC                   if        *in79
500 AC                   leave
500 AC                   endif
500 AC                   if        lwtype <> 'M'
500 AC                   eval      mrgoly = *off
500 AC                   leave
500 AC                   endif
500 AC                   enddo
520cAC                   eval      mrgoly = *off
417 A*
417 A*    Pallet cannot be moved into different compartment ...
417 A*      Unless the To pallet position is empty.
500 A*      Or pallet contains only Merge records.
416aA*
416aA*      Make sure compartments match.
416aA*
     C                   if        pscomp <> $pcomp  and
417 AC                             pspcs <> 0  and
500 AC                             mrgoly = *off
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
650aAC                   eval      ddrtn = '*DIFCOMP'
650aAC                   eval      dderm = 'Cannot drop on diffent compartment '
650aAC                                   + '(' + $pcomp + '/' + pscomp + ')'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
     C                   endif
416aA*
416aA*      If "to" pallet has items, make sure zones match.
500 A*      And pallet contains non-Merge records.
416aA*
416aAC                   if        pspcs > 0  and
416aAC                             pstzon <> $pzone  and
500 AC                             mrgoly = *off
416aAC                   eval      error = *on
416aAC                   eval      *in22 = *on
416aAC                   eval      *in02 = *on
416aAC                   eval      *in23 = *on
416aAC                   eval      *in03 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   eval      erzon1 = $pzone
416aAC                   eval      erzon2 = pstzon
416aAC                   exsr      zm4204
650aAC                   eval      ddrtn = '*DIFZONE'
650aAC                   eval      dderm = 'Cannot drop on different zone '
650aAC                                   + '('
650aAC                                   + %trim($pzone) + '/' + %trim(pstzon)
650aAC                                   + ')'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
6f0aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
416aAC                   endif
417 D**                   ENDIF
     *
     *  Make sure bulk pick count of 'To' pallet won't go over 9.      be < 10.
     *
     C                   eval      tbcnt = psbcnt + svbcnt
     C                   if        tbcnt > 9
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     *R                   MOVE *ON       *IN02
     C                   eval      errmsg = *blanks
     C                   exsr      zm4203
650aAC                   eval      ddrtn = '*BULKOVF'
650aAC                   eval      dderm = 'Cannot drop. Pallet already '
650aAC                                   + 'has 9 bulk picks'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
     C                   endif
     *
     *  Warning if new cube greater than max cube allowed.
520aA*    Skip warning for *DROP.
     *
     C     svcube        add       pscube        nwcube
     C                   if        error = *off  and
520aMC                             ovrrid = *off and
520aAC                             $pcmd <> '*DROP'
     C                   if        nwcube > psmaxc
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     *R                   MOVE *ON       *IN01
     C                   eval      errmsg = *blanks
     C                   eval      enewcb = nwcube
     C                   eval      emaxcb = psmaxc
     C                   exsr      zm4201
650aAC                   eval      ddrtn = '*WARNCUB'
650aAC                   eval      dderm = 'Warning, cube overflow'
650aAC                   eval      ddRecType = '3'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
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
     *     Truck compartment 1
     *
     C                   when      row# = 10
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
416 AC                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1com1
416 D*R                   CALL 'TP900'
416 MC                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1com1 = $lcomp
     C                   endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   goto      endcm1
     C                   endsl
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
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
     C                   eval      w1row = 0
     C                   eval      w1col = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Initialize screen fields.
     *
     C                   eval      w1bcnt = psbcnt
     C                   eval      w1pcs = pspcs
     C                   eval      w1cube = pscube
     C                   eval      w1wght = psswgt
520aAC                   if        $pcmd <> '*DROP'
     C                   eval      w1row = 0
     C                   eval      w1col = 0
520aAC                   endif
     *
     *   Save 'From' PLTSUM values.
     *
     C                   eval      svstp1 = psstp1
     C                   eval      svstp2 = psstp2
     C                   eval      svbcnt = psbcnt
     C                   eval      svpcs = pspcs
     C                   eval      svcube = pscube
     C                   eval      svswgt = psswgt
     C                   eval      svplid = psplid
510aA*
510aA*   For *DROP, initialize unsent parms.
510aA*
510cD ***                if        $pcmd = '*DROP'
510aAC                   eval      $pcomp = pscomp
510aAC                   eval      $puseq = psunld
510aAC                   eval      $pzone = pstzon
510cD ***                endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain(n)  record                             7978
     *R         FILEKY    CHAINRECORD               7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
650aAC                   eval      ddrtn = '*GET78'
650aAC                   eval      dderm = 'From pallet record locked'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
650aAC                   eval      ddrtn = '*GET79'
650aAC                   eval      dderm = 'From pallet record not found'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endgt1
     C                   endif
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 1.
     *
     C     zzget2        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $ptype
     C                   kfld                    $pgen
     C                   kfld                    $prow
     C                   kfld                    $pcol
     *
     *  Define partial keys for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    ukrow
     C                   kfld                    ukcol
     *
     C     partk2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     *
     C     partk3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define 'From' key for PLTSTP1 file.
     *
     C     kystpf        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $pplid
     C                   kfld                    $prow
     C                   kfld                    $pcol
     C                   kfld                    svsstp
     C                   kfld                    svsbsq
     *
     *  Define 'To' key for PLTSTP1 file.
     *
     C     kystpt        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    nwpal#
     C                   kfld                    ukrow
     C                   kfld                    ukcol
     C                   kfld                    svsstp
     C                   kfld                    svsbsq
     *
     *  Define key for PLTSUM2 file.
     *
     C     psumky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $ptype
     C                   kfld                    $pgen
     C                   kfld                    ukrow
     C                   kfld                    ukcol
     *
     *  Define bulk pick key for PLTSUM2 file.
     *
     C                   eval      bktype = 'B'
     C     blksm2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    bktype
     C                   kfld                    $pgen
     C                   kfld                    $prow
     C                   kfld                    $pcol
416 A*
416 A*  Define key for TRKCOMP file.
416 A*
416 AC     tpkey         klist
416 AC                   kfld                    $pwhse
416 AC                   kfld                    $pcomp
     *
     *  Define key for WORKLBL6 file.
     *
     C     lbl6ky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    svspli
     *
     *  Define bulk pick key for WORKLBL file.
     *
     C     blklbl        klist
730aAC                   kfld                    $pwhse
     C                   kfld                    pslbl#
     *
     *  Define variables.
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
520aA*
520aA*   Special handling for *DROP.
520aA*
650aAC                   eval      ddUsed = ''
650aA
520aAC                   if        $pcmd = '*DROP'
520aAC                   eval      $prtn = '*OK'
520aAC                   eval      $perm = 'Drop was successful'
650aAC                   eval      ddrtn = ''
650aAC                   eval      dderm = ''
650aAC                   eval      ddUsed = 'Y'
650aA
650aAC                   eval      ddFromPltId = $pplid
650aAC                   eval      dsplid = $pplid
650aAC                   eval      dsplrw = $prow
650aAC                   eval      dsplcl = $pcol
650aAC                   eval      ddToPltId = dsplid
650aA
520aAC                   eval      w1row  = $prow
520aAC                   eval      w1col  = $pcol
520aAC                   eval      dsplid = $pplid
520aAC                   eval      $prow  = dsplrw
520aAC                   eval      $pcol  = dsplcl
520aAC                   eval      $ptype = 'O'
520aAC                   eval      $pgen  = 1
520aAC                   endif
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   eval      worte = $prte
     C                   eval      woseq = $puseq
     C                   eval      worow = $prow
     C                   eval      wocol = $pcol
     C                   eval      wocom = *blanks
     *          $PCOM     CHAINTRKCOMP              79
416 D*R         $PCOMP    CHAINTRKCOMP              79
416 MC     tpkey         chain     trkcomp                            79
     C                   if        not *in79
     C                   eval      wocom = tpdesc
     C                   endif
     *
     C                   eval      ukrow = $prow
     C                   eval      ukcol = $pcol
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDB   Move bulk pick pallet.
     *
     C     zzupdb        begsr
     *
     *   Create new pallet id.
     *
     C                   eval      dsplid = nwpal#
     C                   add       1             nwcnt
     C                   eval      dsplsq = nwcnt
     *
     *   Update corresponding PLTSUM bulk pick record.
     *
     C     blksm2        setll     pltsum2
     C                   dow       forevr = forevr
     C     blksm2        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        psplid <> svspli
     C                   iter
     C                   endif
     C                   eval      psrow = w1row
     C                   eval      pscol = w1col
417 AC                   eval      pscomp = $pcomp
     C                   eval      psplid = dsplid
415 AC                   eval      psunld = nwunld
415 AC                   eval      pspal# = nwpal2
     C                   update    record
     *
     *      Update corresponding LABEL bulk pick record.
     *
730aMC     blklbl        chain     worklblw                           78
     C                   if        not *in78
     C                   eval      lwpal# = dsplid
     C                   update    lblrec
     C                   endif
     *
     C                   leave
     C                   enddo
     *
     *   Update PLTSTP bulk pick record.
     *
     C                   eval      pssrow = w1row
     C                   eval      psscol = w1col
     C                   eval      pssbsq = dsplsq
     C                   eval      psspli = dsplid
     C                   update    pssrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDN   Delete PLTSUM if New (99) and cube for both col. + 0
     *
     C     zzupdn        begsr
     *
     *   Check if both col 1 and col 2 cubes = 0.
     *
     C                   eval      ukrow = $prow
     C                   eval      ukcol = 1
     *
     C     psumky        setll     pltsum2
     C                   dow       forevr = forevr
     C     psumky        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pscube = 0  and
     C                             pspcs = 0
     C                   eval      ukcol = 2
     C     psumky        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pscube = 0  and
     C                             pspcs = 0
     C                   delete    record
     C                   eval      ukcol = 1
     C     psumky        readpe    pltsum2                                78
     C                   if        not *in78
     C                   delete    record
     C                   leave
     C                   endif
     C                   else
     C                   leave
     C                   endif
     *
     C                   else
     C                   leave
     C                   endif
     *
     *
     C                   enddo
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDT   Move truck pallet.
     *
     C     zzupdt        begsr
     *
     *  Update WORKLBL6 with new pallet #.
     *
     C                   eval      stop = *off
     C     lbl6ky        setll     worklbl6
     C                   dow       forevr = forevr
     C     lbl6ky        reade     worklbl6                               79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      lwpal# = nwpal#
     C                   update    lwrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
650aAC                   eval      ddrtn = '*UPDT1'
650aAC                   eval      dderm = 'Error updating Label record'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endupt
     C                   endif
     *
     C                   enddo
     *
520bAC                   eval      $lwhse = $pwhse
520bAC                   eval      $lrte  = lwrte
520bAC                   eval      $lpal# = lwpal#
520bAC                   call      'PS162'
520bAC                   parm                    $lparm
     *
     *     Increase "To" row/col PLTSTP record.
     *
     C                   eval      ukrow = w1row
     C                   eval      ukcol = w1col
     C     kystpt        chain     pltstp1                            78
     C                   if        not *in78
     C                   add       svspcs        psspcs
     C                   add       svscub        psscub
     C                   add       svsswt        pssswt
     C                   update    pssrec                               78
     C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm72
650aAC                   eval      ddrtn = '*UPDT2'
650aAC                   eval      dderm = 'Error updating PLTSTP record'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endupt
     C                   endif
     C                   else
     C                   eval      psswhs = $pwhse
     C                   eval      pssrid = $prtid
     C                   eval      pssrow = w1row
     C                   eval      psscol = w1col
     C                   eval      pssstp = svsstp
     C                   eval      pssbsq = svsbsq
     C                   eval      psspcs = svspcs
     C                   eval      psscub = svscub
     C                   eval      pssswt = svsswt
     C                   eval      psspli = nwpal#
     C                   write     pssrec                               78
     C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm71
650aAC                   eval      ddrtn = '*UPDT3'
650aAC                   eval      dderm = 'Error creating PLTSTP record'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endupt
     C                   endif
     C                   endif
     *
     *     Delete "From" row/col PLTSTP record.
     *
     C     kystpf        chain     pltstp1                            78
     C                   if        not *in78
     C                   delete    pssrec
     C                   endif
     *
     C     endupt        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Update 'To' PLTSUM record with 'From' values.
     *
     C                   eval      ukrow = w1row
     C                   eval      ukcol = w1col
     C     psumky        chain     pltsum2                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     *R                   MOVE *ON       *IN02
     C                   eval      errmsg = *blanks
     C                   exsr      zm4202
650aAC                   eval      ddrtn = '*UPD1'
650aAC                   eval      dderm = 'To pallet record not found'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endup1
     C                   endif
     *
     *     Save info about new pallet
     *
     C                   eval      nwpal# = psplid
     C                   eval      nwcnt = psbcnt
415 AC                   eval      nwunld = psunld
415 AC                   eval      nwpal2 = pspal#
417aA*
417aA*     Special handling for *SP pallet (PSSTP2=0).
417aA*
417aA*     If the "from" pallet has a different stop on it,
417aA*      Then set PSSTP2 to PSSTP1 so the stop range logic
417aA*           will work correctly.
417aA*
417aAC                   if        psstp2 = 0
417aAC                   if        svstp1 <> psstp1  or
417aAC                             svstp2 <> psstp1  and
417aAC                             svstp2 <> 0
417aAC                   eval      psstp2 = psstp1
417aAC                   endif
417aAC                   endif
417bA*
417bAC                   if        svstp2 = 0
417bAC                   if        psstp1 <> svstp1  or
417bAC                             psstp2 <> svstp1  and
417bAC                             psstp2 <> 0
417bAC                   eval      svstp2 = svstp1
417bAC                   endif
417bAC                   endif
     *
     *     Update stop range if needed.
     *
520eD ***                if        svstp1 < psstp1  or
520eMC                   if        svstp1 < psstp1  and
520eMC                             svstp1 <> 0      or
     C                             psstp1 = 0
     C                   eval      psstp1 = svstp1
     C                   endif
     C                   if        svstp2 > psstp2  or
     C                             psstp2 = 0
     C                   eval      psstp2 = svstp2
     C                   endif
500 A*
500 A*     Set "To" pallet zones to "From" pallet zones.
500 A*     Only if "To" pallet is empty.
500 A*
500 AC                   if        pspcs = 0
500 AC                   eval      pstzon = $pzone
500 AC                   eval      psszon = $pzone
500 AC                   endif
     *
     *     Increase values.
     *
500 AC                   if        pspcs = 0
417 AC                   eval      pscomp = $pcomp
500 AC                   endif
     C                   add       svpcs         pspcs
     C                   add       svcube        pscube
     C                   add       svswgt        psswgt
     C                   add       svbcnt        psbcnt
500 D**
500 D**    Set "To" pallet zones to "From" pallet zones.
500 D**
500 D**                   MOVE $PZONE    PSTZON
500 D**                   MOVE $PZONE    PSSZON
     C                   update    record                               79
     *
     *  Zero 'From' PLTSUM record.
     *
     C                   eval      ukrow = $prow
     C                   eval      ukcol = $pcol
     C     psumky        chain     pltsum2                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in23 = *on
     *R                   MOVE *ON       *IN02
     C                   eval      errmsg = *blanks
     C                   exsr      zm4202
650aAC                   eval      ddrtn = '*UPD2'
650aAC                   eval      dderm = 'From pallet record not found'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endup1
     C                   endif
     C                   eval      psstp1 = 0
     C                   eval      psstp2 = 0
     C                   eval      pspcs = 0
     C                   eval      pscube = 0
     C                   eval      psswgt = 0
     C                   eval      psbcnt = 0
     C                   update    record                               79
     *
     *  If 'From' pallet was an add-on, then see if it should be del.
     *
     C                   if        psflag = '1'
     C                   exsr      zzupdn
     C                   endif
     *
     *  Move all PLTSTP records from 'From' pallet to 'To' pallet.
     *
     C                   eval      ukrow = $prow
     C                   eval      ukcol = $pcol
     C     partk2        setll     pltstp1
     C                   dow       forevr = forevr
     C     partk3        reade     pltstp1                                79
     C                   if        *in79  or
     C                             pssrow <> $prow  or
     C                             psscol <> $pcol
     C                   leave
     C                   endif
     *
     *     Save 'From' values.
     *
     C                   eval      svsstp = pssstp
     C                   eval      svsbsq = pssbsq
     C                   eval      svspcs = psspcs
     C                   eval      svscub = psscub
     C                   eval      svsswt = pssswt
     C                   eval      svspli = psspli
     *
     *     Execute appropriate routine for truck or bulk pick pallet.
     *
     C     pssbsq        caseq     0             zzupdt
     C                   cas                     zzupdb
     C                   endcs
     C     error         cabeq     *on           endup1
     *
     C                   enddo
     *
650aAC                   eval      ddRecType = '1'
650aAC                   exsr      zzWrtDDLOG
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C     endup2        endsr

650aA*----------------------------------------------------------------
650aA*  zzWrtDDLOG   Write DDLOG record
650aA*----------------------------------------------------------------
650aA
650aAC     zzWrtDDLOG    begsr

     C                   if        $pcmd = '*DROP'
      *                            ddFromPltId and ddToPltId set in zzinz2
     C                   else
     C                   eval      ddFromPltId = $pplid
     C                   eval      dsplid = $pplid
     C                   eval      dsplrw = w1row
     C                   eval      dsplcl = w1col
     C                   eval      ddToPltId = dsplid
     C                   endif

      *  ddrtn and dderm set when error occurs.

     C                   call      'WRTDDLOG'
     C                   parm      $pwhse        ddWhse            3 0
     C                   parm      $prtid        ddRtid            5
     C                   parm      0             ddGrpId           7 0
     C                   parm                    ddRecType         1
     C                   parm      '1'           ddMovType         1
     C                   parm                    ddUsed            1
     C                   parm                    ddFromPltId       7 0
     C                   parm                    ddToPltId         7 0
     C                   parm      0             ddStop            2 0
     C                   parm      0             ddLbl#            7 0
     C                   parm      0             ddNewLbl#         7 0
     C                   parm      0             ddPcs             5 0
     C                   parm      ' '           ddCurUser        10
     C                   parm      #prog         ddpgm            10
     C                   parm                    ddrtn            10
     C                   parm                    dderm            80

     C                   eval      ddrtn = ''
     C                   eval      dderm = ''
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Row and Column


