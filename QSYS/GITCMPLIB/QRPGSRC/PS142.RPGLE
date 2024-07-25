417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. PS142FM WILL BE REPALCED WITH PS14201
     *----------------------------------------------------------------
     *
     *  PS142     Truck build pallet detail (one whse) - Move
     *  17 June 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *
     *  Revisions
     *
     *    07/11/97  RH   4.01
     *      - Update 1st stop and last stop for 'move from' PLTSUM record.
     *
402 A*    07/27/97  DAS  4.02
     *      -  Added pallet id to files PLTSTP1.
     *
402 A*    07/29/97  DAS  4.02
     *      - Changed $PUKY.
     *      - Made neccesary changes throught program for key change.
     *
404 A*    08/07/97  DAS  4.04
     *      - Revised ZZUPD routine to include bulk picks.
     *      - Added routines ZZUPDB and ZZUPDT.
     *
404 A*    08/08/97  DAS  4.04
     *      - Initialized W1ROW and W1COL in ZZFILL routine.
404 A*    08/19/97  RH   4.04
     *      - Add warning if newcube will be greater than max cube.
404 A*    08/26/97  RH   4.04
     *      - Add error check, From and To row/col can't be the same.
     *
413aA*    12/01/99  MLB  4.13a
     *      - Revised ZZINZ2 to load WOROW, WOCOL with values from
     *        $PROW, $PCOL.
     *
414 A*    06/20/00  DAS  4.14
     *      - Revised ZZUPDT to force stop into 'from' stop range
     *        value if it is zero.
     *      - Revised ZZUPD1 to identify overflow pallets correctly.
     *
414aA*    09/29/00  DAS  4.14a
     *      - Added UNLCK for PLTSUM2 and PLTSTP1 before leaving pgm.
     *      - Revised ZZCHK1 to to move bulk pick checking logic after
     *        the check for the existance of the 'To' record.
     *
414bA*    09/30/00  DAS  4.14b
     *      - Revised ZZUPD1 to resequence the bulk picks on the
     *        'From' pallet.
     *
415 A*    02/20/01  DAS  4.15
     *      - Revised to update unload seq and pallet numbers of a
     *        bulk pick record when it is moved.
     *
415aA*    03/01/01  DAS  4.15a
     *      - Revised to update WORKLBL LWPALW when bulk picks are
     *        resequenced.
     *
416 A*    02/11/02  MLB  4.16
     *      - Revised to call correct program. Should call
     *        TM910 instead of TP900.
     *      - Revised to pass warehouse to TM910.
     *      - Added warehouse to key for TRKCOMP.
     *
     *
416aA*    12/17/02  DAS  4.16a
     *      - Added field $PZONE to $PARMS
     *      - Added subroutine ZM4204.
     *      - Added new error fields ERZON1/2.
     *      - Added gotos to ZZCHK1.
     *      - Revise ZZCHK1 to compare zones of "from" and "to" pallet
     *      - Revised ZZUPDT to update "To" truck and slot zones.
     *
417aA*    08/22/03  DAS  4.17a
     *      - Revised logic to update pallet range to take into
     *        account *SP pallets, which have PSSTP2 = 0.
     *
500 A*    05/03/06  DAS  5.00
     *      - Revised to allow a pallet with only Merge records to
     *        be moved to a different compartment and/or zone.
     *
500aA*    05/03/06  DAS  5.00a
     *      - Revised to allow a stop to be moved into a different
     *        compartment IF the To pallet position is empty.
     *
520aA*    04/28/08  DAS  5.20a  P#00046
     *      - Converted to ILE
     *      - Revised opening of PS142FM to user defined.
     *      - Added command *DROP to just perform drop without
     *        using any screens (To pallet is passed in).
     *
520bA*    04/28/08  JCJ  5.20b
     *      - added call PS162 for combining selection labels.
520cA*    06/26/08  MLB  5.20c
     *      - Fix: Revised program to use new key when doing setll to
     *        WORKLBL6 file that does not include SVSTP#. Using the
     *        existing key was preventing all records on pallet from
     *        being read and allowing a cross-compartment move which
     *        is not allowed when the compartment/pallet position is
     *        not empty.
     *
520dA*    02/05/09  CWM/MLB 5.20d  01/26  01/28
     *      - Enh: Added support for new extended stop number.
     *        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
     *
520eA*    07/08/09  JCJ  5.20e
     *      - Changed PS142FM to PS14201.
     *
650aA*    03/28/13  DAS  6.50a
     *      - Enh: Added DDLOGing. Needs program WRTDDLOG.
     *
650bA*    03/28/13  DAS  6.50b
     *      - Enh: Added check to see if route has already been
     *        processed (pltsum rec has a tran#).
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
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
520eD ***ps142fm   cf   e             workstn
520eMFps14201   cf   e             workstn
520aAF                                     usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpltstp1   uf a e           k disk
     F                                     rename(pssrec:record)
     Fpltsum2   uf   e           k disk
     Fworklbl6  uf   e           k disk
730aDF*orklbl   uf   e           k disk
730aMFworklblw  uf   e           k disk
     F                                     rename(lwrec:lblrec)
     Fwarehs    if   e           k disk
     Ftrkcomp   if   e           k disk
650bAFpltsum1   if   e           k disk    prefix(ps1_) rename(psrec:psrec1)
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
402 MD  $pwhse                19     21  0
402 MD  $prte                 22     26
402 MD  $prtid                27     31
402 MD  $prow                 32     33  0
402 MD  $pcol                 34     34  0
402 MD  $pcomp                35     35
402 MD  $puseq                36     37  0
402 MD  $pplid                38     44  0
402 MD  $pbseq                45     45  0
402 MD  $pstop                46     47  0
416aAD  $pzone                48     53
     *
402 D*                                      19  210$PWHSE
402 D*                                      22  26 $PRTID
402 D*                                      27  280$PROW
402 D*                                      29  290$PCOL
402 D*                                      30  310$PSTOP
402 D*                                      32  320$PBSEQ
402 D*                                      33  33 $PCOM
402 D*                                      34  350$PUSEQ
402 D*                                      36  40 $PRTE
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
404 A*
404 AD  enewcb                 1      4p 3
404 AD  emaxcb                 5      7p 2
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
     *
520aAD useScreen       s               n

     D $msgf           s             10
     D $pprg1          s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bcnt            s              2  0
     D bkseq           s                   like(pssbsq)
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
     D nwcube          s                   like(svscub)
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
     D svplid          s                   like(psplid)
     D svsbsq          s                   like(pssbsq)
     D svscol          s                   like(psscol)
     D svscub          s                   like(psscub)
     D svspcs          s                   like(psspcs)
     D svspli          s                   like(psspli)
     D svsrid          s                   like(pssrid)
     D svsrow          s                   like(pssrow)
     D svsstp          s                   like(pssstp)
     D svsswt          s                   like(pssswt)
     D svswhs          s                   like(psswhs)
     D tbcnt           s              2  0
     D ukcol           s                   like($pcol)
     D ukrow           s                   like($prow)
     D ukwhse          s                   like($pwhse)
     D warn            s              1
     D w1com1          s              1
     D w1gen           s              1  0
     D w1type          s              1
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
414aAC                   unlock    pltsum2
414aAC                   unlock    pltstp1
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
     C*
520aAC                   if        useScreen
     C*
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
520dAC                   exsr      zzfgts
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
221 AC                   if        $pcmd = '*ADD    '
221 A*R                   ADD  1         UKROW
221 A*R                   ADD  1         WOROW
221 AC                   exsr      scr01i
221 AC                   else
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
520eD ***                open      ps142fm
520eMC                   open      ps14201
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
404 A*   PS14201  New cube for pallet is greater than max cube.
404 A*
404 AC     zm4201        begsr
404 AC                   eval      #msgid = 'PS14201'
404 AC                   eval      #msgtp = '*DIAG  '
404 AC                   eval      $md = *blanks
404 AC                   movea     errmsg        $md(1)
404 AC                   exsr      zmpmsg
404 AC                   endsr
     *----------------------------------------------------------------
404 A*   PS14202  Can't move product to same pallet.
404 A*
404 AC     zm4202        begsr
404 AC                   eval      #msgid = 'PS14202'
404 AC                   eval      #msgtp = '*DIAG  '
404 AC                   eval      $md = *blanks
404 AC                   movea     errmsg        $md(1)
404 AC                   exsr      zmpmsg
404 AC                   endsr
     *----------------------------------------------------------------
404 A*   PS14203  Can't move bulk picks, violates limit of 9 bulk picks
404 A*            per pallet.
404 A*
404 AC     zm4203        begsr
404 AC                   eval      #msgid = 'PS14203'
404 AC                   eval      #msgtp = '*DIAG  '
404 AC                   eval      $md = *blanks
404 AC                   movea     errmsg        $md(1)
404 AC                   exsr      zmpmsg
404 AC                   endsr
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
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     *
     *    Make sure code doesn't already exist.
     *
     *R                   MOVE W1HTRU    $PTRUK
     *R         FILEKY    CHAINRECORD              N79
     *R         *IN79     IFEQ *OFF
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN21
     *R                   EXSR ZM02
     *R                   END
     *R                   END
     *
     C                   endif
     *
     *    Make sure compartment was entered.
     *
     *R         W1COM1    IFEQ *BLANKS
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN22
     *R                   MOVE *ON       *IN02
     *R                   EXSR ZM03
     *R                   END
     *
     *  Verify Compartment code.
     *
     *R         W1COM1    IFNE *BLANKS
     *R         W1COM1    CHAINTRKCOMP              79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN22
     *R                   MOVE *ON       *IN02
     *R                   MOVE *BLANKS   ERRMSG
     *R                   MOVELDESC,1    ERRMSG
     *R                   EXSR ZM1001
     *R                   ENDIF
     *R                   ENDIF
     *
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
404 A*    From and To row/col can't be the same.
     *
404 AC                   if        w1row = $prow  and
404 AC                             w1col = $pcol
404 AC                   eval      error = *on
404 AC                   eval      *in22 = *on
404 AC                   eval      *in23 = *on
404 A*R                   MOVE *ON       *IN02
404 AC                   eval      errmsg = *blanks
404 AC                   exsr      zm4202
650aAC                   eval      ddrtn = '*SAMEPLT'
650aAC                   eval      dderm = 'Cannot drop on same pallet'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
404 AC                   endif
     *
     *    Make sure move to rec exists in PLTSUM2
     *
     C                   eval      w1type = 'O'
     C                   eval      w1gen = 1
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
500aD**                   ELSE
500aMC                   endif
500 A*
500 A*    See if stop only contains Merge records.
500 A*
500 AC                   eval      mrgoly = *on
500 AC                   eval      svspli = $pplid
520cDC*    lbl6ky        setll     worklbl6
520cMC     lb6key        setll     worklbl6
500 AC                   dow       forevr = forevr
520cDC*    lbl6ky        reade(n)  worklbl6                               79
520cMC     lb6key        reade(n)  worklbl6                               79
500 AC                   if        *in79
500 AC                   leave
500 AC                   endif
500 AC                   if        lwtype <> 'M'
500 AC                   eval      mrgoly = *off
500 AC                   leave
500 AC                   endif
500 AC                   enddo
500aA*
500aA*    Pallet cannot be moved into different compartment ...
500aA*      Unless the To pallet position is empty.
500 A*      Or pallet contains only Merge records.
416aA*
416aA*      Make sure compartments match.
416aA*
402 D*          PSCOMP    IFNE $PCOM
402 MC                   if        pscomp <> $pcomp  and
500aAC                             pspcs <> 0  and
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
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
416aAC                   endif
500aD**                   ENDIF
     *
404 A*  Loop through PLTSTP recs for stop being moved to check for bulk picks.
     *
404 AC                   eval      bcnt = 0
404 AC                   eval      tbcnt = 0
404 AC                   eval      ukrow = svsrow
404 AC                   eval      ukcol = svscol
404 AC     partk2        setll     pltstp1
404 AC                   dow       forevr = forevr
404 AC     partk3        reade     pltstp1                                79
404 AC                   if        *in79  or
404 AC                             pssrow <> svsrow  or
404 AC                             psscol <> svscol
404 AC                   leave
404 AC                   endif
404 AC                   if        pssstp <> $pstop
404 AC                   iter
404 AC                   endif
404 AC                   if        pssbsq = 0
404 AC                   iter
404 AC                   endif
404 AC                   add       1             bcnt
404 A*
404 AC                   enddo
     *
404 A*  If move stop has bulk picks, verify bulk picks after move will be < 10.
     *
404 AC                   if        bcnt > 0
414aD**                   Z-ADDPSSPLI    DSPLID
414aMC                   eval      dsplid = $pplid
404 AC                   eval      dsplrw = w1row
404 AC                   eval      dsplcl = w1col
404 A*
404 AC                   eval      ukrow = w1row
404 AC                   eval      ukcol = w1col
404 A*
404 AC     psumky        setll     pltsum2
404 AC                   dow       forevr = forevr
404 AC     psumky        reade     pltsum2                                78
404 AC                   if        *in78
404 AC                   leave
404 AC                   endif
404 AC                   if        psplid <> dsplid
404 AC                   iter
404 AC                   endif
404 A*
404 AC     psbcnt        add       bcnt          tbcnt
404 AC                   if        tbcnt > 9
404 AC                   eval      error = *on
404 AC                   eval      *in22 = *on
404 AC                   eval      *in23 = *on
404 A*R                   MOVE *ON       *IN02
404 AC                   eval      errmsg = *blanks
404 AC                   exsr      zm4203
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
404 AC                   endif
404 A*
404 AC                   leave
404 AC                   enddo
404 AC                   endif
     *
     *  Check if record was changed since we read.
     *
     *R                   Z-ADD1         W1COL
     C     fileky        chain(n)  record                             79
     *
     *    Record not found.
     *
     C                   if        *in79
     *R                   MOVE *BLANKS   TDCOMP
     *R                   Z-ADD0         TDCUBE
     *R                   Z-ADD0         TDPICK
     C                   endif
404 A*
404 A*  Warning:
404 A*
404 AC     svscub        add       pscube        nwcube
404 AC                   if        error = *off  and
510aMC                             ovrrid = *off and
510aAC                             $pcmd <> '*DROP'
404 AC                   if        nwcube > psmaxc
404 AC                   eval      warn = *on
404 AC                   eval      error = *on
404 AC                   eval      *in22 = *on
404 AC                   eval      *in23 = *on
404 A*R                   MOVE *ON       *IN01
404 AC                   eval      errmsg = *blanks
404 AC                   eval      enewcb = nwcube
404 AC                   eval      emaxcb = psmaxc
404 AC                   exsr      zm4201
650aAC                   eval      ddrtn = '*WARNCUB'
650aAC                   eval      dderm = 'Warning, cube overflow'
650aAC                   eval      ddRecType = '3'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
416aAC                   goto      endck1
404 AC                   endif
404 AC                   endif
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
     C                   eval      w1stop = pssstp
520dAC*
520dAC                   if        $sstp > 0
520dAC                   eval      w1hstp = $sstp
520dAC                   else
520dAC                   eval      w1hstp = pssstp
520dAC                   endif
520dAC*
     C                   eval      w1bseq = pssbsq
     C                   eval      w1pcs = psspcs
     C                   eval      w1cube = psscub
     C                   eval      w1wght = pssswt
520aAC                   if        $pcmd <> '*DROP'
404 AC                   eval      w1row = 0
404 AC                   eval      w1col = 0
520aAC                   endif
     *R  Move from row/col record to save fields.
     C                   eval      svswhs = psswhs
     C                   eval      svsrid = pssrid
     C                   eval      svsrow = pssrow
     C                   eval      svscol = psscol
     C                   eval      svsstp = pssstp
     C                   eval      svsbsq = pssbsq
     C                   eval      svspcs = psspcs
     C                   eval      svscub = psscub
     C                   eval      svsswt = pssswt
     C                   eval      svspli = psspli
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
520dAC*----------------------------------------------------------------
520dAC*
520dAC*  ZZFGTS   Get Host Stop Number
520dAC*
520dAC     ZZFGTS        BEGSR
520dAC*
520dAC*    Get Stop From RTESTP
520dAC*
520dAC                   Z-ADD     *ZEROS        $sOrd
520dMC                   Z-ADD     pssstp        $sDstp
520dAC*
520dAC*    Get Stop From RTESTP
520dAC*
520dAC                   CALL      'GETSTOP'
520dAC                   PARM      '*PLTSTP '    $scmd             8
520dAC                   PARM      $PWHSE        $swhse            3 0
520dAC                   PARM      $PRTID        $srtid            5
520dAC                   PARM                    $sord             7 0
520dAC                   PARM                    $sdstp            2 0
520dAC                   PARM      0             $sstp             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520dAC*
520dAC                   ENDSR
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
222 MC     fileky        chain(n)  record                             7978
222 D*R         FILEKY    CHAINRECORD               7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
650aAC                   eval      ddrtn = '*GET78'
650aAC                   eval      dderm = 'From stop record locked'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endgt1
     C                   endif
     *
     *  Rec rd not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
650aAC                   eval      ddrtn = '*GET79'
650aAC                   eval      dderm = 'From stop record not found'
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
404 AC                   eval      forevr = *on
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
402 AC                   kfld                    $pplid
221 D*R                   KFLD           $PROW
     C                   kfld                    ukrow
221 AC                   kfld                    ukcol
221 D*R                   KFLD           W1COL   10
222 AC                   kfld                    $pstop
222 AC                   kfld                    $pbseq
     *
402 AC     filek2        klist
402 AC                   kfld                    $pwhse
402 AC                   kfld                    $prtid
402 AC                   kfld                    nwpal#
402 AC                   kfld                    ukrow
402 AC                   kfld                    ukcol
402 AC                   kfld                    $pstop
402 AC                   kfld                    $pbseq
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
402 AC                   kfld                    $pplid
     C                   kfld                    ukrow
221 AC                   kfld                    ukcol
     *
404 AC     partk2        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    $pplid
     *
404 AC     partk3        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 A*
404 A*  Define key for main bulk picks
404 A*
404 AC     blkst1        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    dsplid
404 A*
404 AC     blkst2        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
     *
     *
     *  Define key for PLTSUM2 file.
     *
     C     psumky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    w1type
     C                   kfld                    w1gen
222 D*R                   KFLD           W1ROW
222 D*R                   KFLD           W1COL
     C                   kfld                    ukrow
     C                   kfld                    ukcol
404 A*
404 A*  Define bulk pick key for PLTSUM2 file.
404 A*
404 AC                   eval      bktype = 'B'
404 AC     blksm2        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    bktype
404 AC                   kfld                    w1gen
404 AC                   kfld                    pssrow
404 AC                   kfld                    psscol
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
     C                   kfld                    $pstop
520cAC     lb6key        klist
520cAC                   kfld                    $pwhse
520cAC                   kfld                    $prtid
520cAC                   kfld                    svspli
404 A*
404 A*  Define bulk pick key for WORKLBL file.
404 A*
404 AC     blklbl        klist
730aAC                   kfld                    $pwhse
404 AC                   kfld                    pslbl#
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
520aAC                   eval      $pbseq = dsplsq
520aAC                   eval      w1type = 'O'
520aAC                   eval      w1gen = 1
520aAC                   eval      ukrow = dsplrw
520aAC                   eval      ukcol = dsplcl
520aAC     psumky        chain(n)  pltsum2                            79
520aAC                   if        not *in79
520aAC                   eval      $pcomp = pscomp
520aAC                   eval      $puseq = psunld
520aAC                   eval      $pzone = pstzon
520aAC                   endif
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
413aAC                   eval      worow = $prow
413aAC                   eval      wocol = $pcol
     C                   eval      wocom = *blanks
402 D*          $PCOM     CHAINTRKCOMP              79
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
404 A*----------------------------------------------------------------
404 A*
404 A*  ZZUPDB   Move bulk pick pallet.
404 A*
     C     zzupdb        begsr
     *
404 A*   Decrement bulk pick count of from pallet.
     *
404 AC                   eval      dsplid = psspli
404 AC                   eval      dsplrw = $prow
404 AC                   eval      dsplcl = $pcol
404 AC                   eval      dsplsq = 0
404 A*
404 AC                   eval      ukrow = $prow
404 AC                   eval      ukcol = $pcol
404 A*
404 AC     psumky        setll     pltsum2
404 AC                   dow       forevr = forevr
404 AC     psumky        reade     pltsum2                                78
404 AC                   if        *in78
404 AC                   leave
404 AC                   endif
404 AC                   if        psplid <> dsplid
404 AC                   iter
404 AC                   endif
404 AC                   if        psbcnt > 0
404 AC                   eval      psbcnt = psbcnt - 1
404 AC                   endif
404 AC                   update    psrec
404 AC                   leave
404 AC                   enddo
     *
     *   Increment bulk pick count of new pallet.
     *
     C                   eval      dsplid = psspli
     C                   eval      dsplrw = w1row
     C                   eval      dsplcl = w1col
     C                   eval      dsplsq = 0
     *
     C                   eval      ukrow = w1row
     C                   eval      ukcol = w1col
     *
     C     psumky        setll     pltsum2
     C                   dow       forevr = forevr
     C     psumky        reade     pltsum2                                78
     C                   if        *in78
     C                   eval      psplid = 0
     C                   eval      psbcnt = 1
     C                   leave
     C                   endif
     C                   if        psplid <> dsplid
     C                   iter
     C                   endif
     C                   add       1             psbcnt
     C                   update    psrec
     C                   leave
     C                   enddo
     *
     *   Create new pallet id.
     *
     C                   eval      dsplid = psplid
     C                   eval      dsplsq = psbcnt
415 AC                   eval      nwunld = psunld
415 AC                   eval      nwpal2 = pspal#
     *
     *   Update corresponding PLTSUM bulk pick record.
     *
     C     blksm2        setll     pltsum2
     C                   dow       forevr = forevr
     C     blksm2        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        psplid <> psspli
     C                   iter
     C                   endif
     C                   eval      psrow = w1row
     C                   eval      pscol = w1col
500aAC                   eval      pscomp = $pcomp
     ***                  Z-ADDDSPLSQ    PSBCNT
     C                   eval      psplid = dsplid
415 AC                   eval      psunld = nwunld
415 AC                   eval      pspal# = nwpal2
     C                   update    psrec
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
     C                   update    record
     *
     C                   endsr
404 A*----------------------------------------------------------------
404 A*
404 A*  ZZUPDN   Delete PLTSUM if New (99) and cube for both col. + 0
404 A*
404 AC     zzupdn        begsr
404 A*
404 A*   Check if both col 1 and col 2 cubes = 0.
404 A*
404 AC                   eval      ukcol = 1
404 A*
404 AC     psumky        setll     pltsum2
404 AC                   dow       forevr = forevr
404 AC     psumky        reade     pltsum2                                78
404 AC                   if        *in78
404 AC                   leave
404 AC                   endif
404 AC                   if        pscube = 0  and
404 AC                             pspcs = 0
404 AC                   eval      ukcol = 2
404 AC     psumky        reade     pltsum2                                78
404 AC                   if        *in78
404 AC                   leave
404 AC                   endif
404 AC                   if        pscube = 0  and
404 AC                             pspcs = 0
404 AC                   delete    psrec
404 AC                   eval      ukcol = 1
404 AC     psumky        readpe    pltsum2                                78
404 AC                   if        not *in78
404 AC                   delete    psrec
404 AC                   leave
404 AC                   endif
404 AC                   else
404 AC                   leave
404 AC                   endif
404 A*
404 AC                   else
404 AC                   leave
404 AC                   endif
404 A*
404 A*
404 AC                   enddo
404 A*
404 A*
404 AC                   endsr
404 A*----------------------------------------------------------------
404 A*
404 A*  ZZUPDT   Move truck pallet.
404 A*
     C     zzupdt        begsr
     *
     *  Increase "To" row/col PLTSUM record.
     *
     *
     C                   eval      dsplid = psspli
     C                   eval      dsplrw = w1row
     C                   eval      dsplcl = w1col
     *
     C                   eval      ukrow = w1row
     C                   eval      ukcol = w1col
     *
     C     psumky        setll     pltsum2
     C                   dow       forevr = forevr
     C     psumky        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        psplid <> dsplid
     C                   iter
     C                   endif
500 A*
500 A*     Set "To" pallet zones to "From" pallet zones.
500 A*     Only if "To" pallet is empty.
500 A*
500 AC                   if        pspcs = 0
500aAC                   eval      pstzon = $pzone
500aAC                   eval      psszon = $pzone
500aAC                   eval      pscomp = $pcomp
500 AC                   endif
     *
     C                   eval      nwpal# = psplid
     C                   add       svspcs        pspcs
     C                   add       svscub        pscube
     C                   add       svsswt        psswgt
500aD**                   MOVE $PZONE    PSTZON
500aD**                   MOVE $PZONE    PSSZON
417aA*
417aA*     Special handling for *SP pallet (PSSTP2=0).
417aA*
417aA*     If the "from" pallet has a different stop on it,
417aA*      Then set PSSTP2 to PSSTP1 so the stop range logic
417aA*           will work correctly.
417aA*
417aAC                   if        psstp2 = 0  and
417aAC                             pssstp <> psstp1
417aAC                   eval      psstp2 = psstp1
417aAC                   endif
417aA*
417aA*     Update stop range if needed.
417aA*
     C                   if        pssstp < psstp1  or
414 AC                             psstp1 = 0
     C                   eval      psstp1 = pssstp
     C                   endif
     C                   if        pssstp > psstp2
     C                   eval      psstp2 = pssstp
     C                   endif
     C                   update    psrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
650aAC                   eval      ddrtn = '*UPDT1'
650aAC                   eval      dderm = 'Error updating stop range'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endupt
     C                   endif
     *
     C                   leave
     C                   enddo
     *
     *  Decrease "From" row/col PLTSUM record.
     *
     C                   eval      dsplrw = svsrow
     C                   eval      dsplcl = svscol
     *
     C                   eval      ukrow = svsrow
     C                   eval      ukcol = svscol
     *
     C     psumky        setll     pltsum2
     C                   dow       forevr = forevr
     C     psumky        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        psplid <> dsplid
     C                   iter
     C                   endif
     *
     C                   eval      pspcs = pspcs - svspcs
     C                   eval      pscube = pscube - svscub
     C                   eval      psswgt = psswgt - svsswt
     C                   update    psrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
650aAC                   eval      ddrtn = '*UPDT2'
650aAC                   eval      dderm = 'Error updating From PLTSUM record'
650aAC                   eval      ddRecType = '2'
650aAC                   exsr      zzWrtDDLOG
520aAC                   if        $pcmd = '*DROP'
650aMC                   eval      $prtn = ddrtn
650aMC                   eval      $perm = dderm
520aAC                   endif
     C                   goto      endupt
     C                   endif
     *
     C                   leave
     C                   enddo
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
650aAC                   eval      ddrtn = '*UPDT3'
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
     *     Increase "To" row/col PLTSTP record.
     *
     C                   eval      ukrow = w1row
     C                   eval      ukcol = w1col
     C     filek2        chain     record                             78
     C                   if        not *in78
     C                   add       svspcs        psspcs
     C                   add       svscub        psscub
     C                   add       svsswt        pssswt
     C                   update    record                               78
     C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm72
650aAC                   eval      ddrtn = '*UPDT4'
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
     C                   eval      psswhs = svswhs
     C                   eval      pssrid = svsrid
     C                   eval      pssrow = w1row
     C                   eval      psscol = w1col
     C                   eval      pssstp = svsstp
414bD**                   Z-ADDSVSBSQ    PSSBSQ
414bMC                   eval      pssbsq = 0
     C                   eval      psspcs = svspcs
     C                   eval      psscub = svscub
     C                   eval      pssswt = svsswt
     C                   eval      psspli = nwpal#
     C                   write     record                               78
     C                   if        *in78
     C                   eval      error = *on
     C                   exsr      zm71
650aAC                   eval      ddrtn = '*UPDT5'
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
     C                   eval      ukrow = svsrow
     C                   eval      ukcol = svscol
     C     fileky        chain     record                             78
     C                   if        not *in78
     C                   delete    record
     C                   endif
     *
520bAC                   eval      $lwhse = $pwhse
520bAC                   eval      $lrte  = $prtid
520bAC                   eval      $lpal# = nwpal#
520bAC                   call      'PS162'
520bAC                   parm                    $lparm
     *
     C     endupt        endsr
404 M*----------------------------------------------------------------
404 M*
404 M*  ZZUPD1   Update record.
404 M*
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Loop through PLTSTP records for stop being moved.
     *
     C                   eval      ukrow = svsrow
     C                   eval      ukcol = svscol
     C     partk2        setll     pltstp1
     C                   dow       forevr = forevr
     C     partk3        reade     pltstp1                                79
     C                   if        *in79  or
     C                             pssrow <> svsrow  or
     C                             psscol <> svscol
     C                   leave
     C                   endif
     C                   if        pssstp <> $pstop
     C                   iter
     C                   endif
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
     *   Recalculate first/last stop for "From" pallet.
     *
414bA*     Added Resequencing of bulk pick records.
     *
414bAC                   eval      bcnt = 0
     C                   eval      ukrow = svsrow
     C                   eval      ukcol = svscol
     C                   eval      stop1 = 0
     C                   eval      stop2 = 0
     C     partky        setll     pltstp1
     C                   dow       forevr = forevr
414 MC     partk3        reade     pltstp1                                79
414 D**         PARTKY    READEPLTSTP1             N    79
     C                   if        *in79  or
414bAC                             pssrow <> svsrow  or
414bAC                             psscol <> svscol
     C                   leave
     C                   endif
417aA*
417aA*     Special handling for *SP pallet (STOP2=0).
417aA*
417aA*     If the "from" pallet has a different stop on it,
417aA*      Then set STOP2 to STOP1 so the stop range logic
417aA*           will work correctly.
417aA*
417aAC                   if        stop2 = 0  and
417aAC                             pssstp <> stop1
417aAC                   eval      stop2 = stop1
417aAC                   endif
417aA*
417aA*     Update stop range if needed.
417aA*
     C                   if        pssstp < stop1  or
     C                             stop1 = 0
     C                   eval      stop1 = pssstp
     C                   endif
     C                   if        pssstp > stop2  or
     C                             stop2 = 0
     C                   eval      stop2 = pssstp
     C                   endif
414bA*
414bA*      If bulk pick, resequence PLTSTP record.
414bA*
414bAC                   if        pssbsq <> 0
414bAC                   add       1             bcnt
414bAC                   z-add     bcnt          pssbsq
414bAC                   eval      svplid = psspli
414bAC                   eval      dsplid = psspli
414bAC                   eval      dsplsq = pssbsq
414bAC                   eval      psspli = dsplid
414bAC                   update    record
414bA*
414bA*         Update corresponding PLTSUM record.
415aA*             and corresponding LABEL record.
414bA*
414bAC                   eval      w1type = 'B'
414bAC     psumky        setll     pltsum2
414bAC                   dow       forevr = forevr
414bAC     psumky        reade     pltsum2                                78
414bAC                   if        *in78
414bAC                   leave
414bAC                   endif
414bAC                   if        psplid <> svplid
414bAC                   iter
414bAC                   endif
414bAC                   eval      psplid = dsplid
414bAC                   update    psrec
730aMC     blklbl        chain     worklblw                           77
415aAC                   if        not *in77
415aAC                   eval      lwpal# = dsplid
415aAC                   update    lblrec
415aAC                   endif
414bAC                   leave
414bAC                   enddo
414bA*
414bAC                   endif
     *
     C                   enddo
     *
     *  Update "From" row/col PLTSUM record.
     *
414bAC                   eval      w1type = 'O'
     C                   eval      dsplid = $pplid
     C                   eval      dsplrw = svsrow
     C                   eval      dsplcl = svscol
     *
     C                   eval      ukrow = svsrow
     C                   eval      ukcol = svscol
     *
     C     psumky        setll     pltsum2
     C                   dow       forevr = forevr
     C     psumky        reade     pltsum2                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        psplid <> dsplid
     C                   iter
     C                   endif
     *
     C                   eval      psstp1 = stop1
     C                   eval      psstp2 = stop2
     C                   update    psrec                                79
     C                   leave
     *
     C                   enddo
404 A*
404 A*  Check to delete row/col "new" record from PLTSUM
404 A*
414 D**         PSUNLD    IFEQ 99
414 MC                   if        psflag = '1'
404 AC                   exsr      zzupdn
404 AC                   endif
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
     C                   parm      '2'           ddMovType         1
     C                   parm                    ddUsed            1
     C                   parm                    ddFromPltId       7 0
     C                   parm                    ddToPltId         7 0
     C                   parm      $pstop        ddStop            2 0
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


