510bA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RF1620    RF 16 X 20 menu
     *  11 June 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    16 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
415 A*    06/11/01  DAS  4.15
     *      - Created.
     *
416 A*    05/10/02  DAS  4.16
     *      - Added logic to display user's default warehouse in
     *        message line.
416aA*    10/24/01  MLB  4.16a
     *      - Add option 15 for RF Change pick slot program.
416bA*    05/07/02  MLB  4.16b
     *      - Add option 16 for RF Willcall Transfer program.
     *      - Add option 17 for RF Willcall Transfer Returns program.
416cA*    05/31/02  DAS  4.16c
     *      - Add option 18 for RF Single Order Pick.
416dA*    10/04/02  MLB  4.16d
     *      - Add option 19 for RF Bulk Pick Selection.
     *
417aA*    11/24/03  RH   4.17a
     *      - Add option 21 for RF Check Digit.
417bA*    02/17/04  MLB  4.17b
     *      - Add option 22 for Upd Yard Status.
417cA*    02/27/04  MLB  4.17c
     *      - Fix: Add test for blank TABPGM. If blank, treat
     *        option as invalid.
417dA*    06/10/04  MLB  4.17d
     *      - Enh: Add option 23 for Clear Flags. Calls pgm
     *        RU310CL.
417eA*    08/19/04  MLB  4.17e
     *      - Enh: Add option 88 StuffIt to menu.
500 A*    01/13/05  RLP  5.00
     *      - Enh: Remove option 14 - Stage Putaway, obsolete
500bA*    01/05/06  RH   5.00b
     *      - Enh: Add option 14 - Pallet license info.
     *
510aA*    06/11/07  DAS  5.10a
     *      - Enh: Revised program to add support for Client id
     *
510bA*    09/21/07  DAS  5.10b
     *      - Converted to ILE
     *
510cA*    09/21/07  DAS  5.10c
     *      - Reserved (CMS Menu System)
530aA*    11/06/09  RH   5.30a
     *      - Enh: Add option 24 & 25 for loader module.
530bA*    06/29/10  RH   5.30b
     *      - Enh: Reverse display 24 & 25 for YHata only.
     *      - Enh: Add opt 26, RF selection.
640aA*    02/22/11  RH   6.40a
     *      - Enh: Add call to CHKLIST for authorization.
650aA*    01/29/15  RBD  6.50a
     *      - Enh: Added opt 27, Receive item without a PO.
700a *    03/01/16  GJA  7.00a
     *      - Enh: Added opt 28, Assign GS1 to item
700b *    03/07/16  RH   7.00b
     *      - Enh: Added opt 87, Set Item/License for start up
700cA*    06/02/16  RBD  7.00c
     *      - Enh: Added opts 31 Load Equip and 32 Return Equip.
     *        Tidied up some things from the past where an option had
     *        been removed but tables were not updated properly.
710a *    02/09/17  GJA  7.10a
     *      - Enh: Removed reference to letdown
710bA*    02/16/17  RH   7.10b
     *      - Enh: Add opt 20=Eq Check in/out
     *
710cA*    02/15/17  RBD  7.10c
     *      - Enh: Added opt 33 Ret Eq no RtId.
     *
720aA*    11/19/18  LMC  7.20a
     *      - Enh: Added opt 35 Box Labeler
     *
720b *    11/30/18  GJA  7.20b
     *      - Enh: Added opt 36 Pallet Info
     *
730aA*    05/30/19  LMC  7.30a
     *      - Enh: Added opt 37 RTC Count
     *
730bA*    09/19/19  LMC  7.30b
     *      - Enh: Added opt 38 RF UCI Selection changes
740aA*    08/20/20  LMC  7.40a
     *      - Enh: Added opt 39 RF UCI lookup
750aA*    01/20/22  RH   7.50a
     *      - Fix: Fix spelling of Replenishment, was Replishment
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
DRYaA*   02/22/11  RH   DRYa
     *     - Check if user authorized for adjustments.
     *----------------------------------------------------------------
     * Client Custom Revisions: Julius Silvert
JSLa *   08/11/15  GJA  JSLa
     *     - Check if user authorized for adjustments.
     *----------------------------------------------------------------
     * Client Custom Revisions: Royal
     *
RYLaA*   06/11/07  DAS  RYLa
     *     - Remove Adjustments (IT220CL) from menu.
     *
RYLbA*   02/27/17  JCJ  RYLb
     *     - Reverse RYLa replaced by - Program Option Limit User
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Fox River Foods
FRF A*   07/14/14  MLB  FRF  #01232
     *     - Check if user authorized for adjustments.
     *     - Added FRF to DRYa mod.
FRFaA*   07/14/14  MLB  FRFa  #01232
     *     - Check if user authorized for slot transfers.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: European Imports
EI  A*   01/28/15  MLB  EI  #01308
     *     - Check if user authorized for adjustments.
     *     - Added EI to DRYa mod.
EIa A*   01/28/15  MLB  EIa  #01308
     *     - Check if user authorized for slot transfers.
     *     - Added EIa to FRFa mod.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program uses a revised method to display error messages.
     *    Instead of the program writting each message to the subfile
     *    using the message key the subfile has been revised to display
     *    all messages from the program message queue automatically.
     *
     *    All changes have been marked with MSG in position 1.
     *
     *----------------------------------------------------------------
     *  Menu Notes
     *
     *    The following needs to be done to add a new screen of
     *    menu options:
     *
     *      1) Add 13 to the number of table entries for the MNU
     *         E-Spec.
     *      2) Add 13 lines to the actual table at the end of the
     *         program.
     *      3) Add 1 to the value being loaded into field MAXMNU
     *         in routine ZZINZ2.
     *
     *    The following needs to be done to utilize a new menu
     *    option:
     *
     *      1) Increase the table entries for TABOPT/TABPGM for
     *         the number of option(s) being added.
     *      2) Add the option(s) and corresponding program name to
     *         the TABOPT/TABPGM table at the end of the program.
     *
     *    The following needs to be done to to remove an option
     *    from being used:
     *
     *      1) Decrease the table entries for TABOPT/TABPGM for
     *         the number of option(s) being removed.
     *      2) Remove the option(s) and corresponding program name
     *         in the TABOPT/TABPGM table at the end of the program.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  81        Rollup
     *  82        Rolldown
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frf1620fm  cf   e             workstn
     F                                     infds(infds)
MSG D*                                       MSGK  KSFILE MSGREC
     *----------------------------------------------------------------
     *  Table and array definitions
     *
416 D**                  TABOPT  1  15  3   TABPGM 10
416dD**                  TABOPT  1  19  3   TABPGM 10
417aD**                  TABOPT  1  20  3   TABPGM 10
417bD**                  TABOPT  1  21  3   TABPGM 10
417dD**                  TABOPT  1  22  3   TABPGM 10
417eD**                  TABOPT  1  26  3   TABPGM 10
500 D**                  TABOPT  1  27  3   TABPGM 10
500bD**                  TABOPT  1  26  3   TABPGM 10
530aDD*tabopt          s              3    dim(27) ctdata perrcd(1)
530aDD*tabpgm          s             10    dim(27) alt(tabopt)
530bDD*tabopt          s              3    dim(29) ctdata perrcd(1)
530bDD*tabpgm          s             10    dim(29) alt(tabopt)
650aDD*tabopt          s              3    dim(30) ctdata perrcd(1)
650aDD*tabpgm          s             10    dim(30) alt(tabopt)
650aDD*tabopt          s              3    dim(31) ctdata perrcd(1)
650aDD*tabpgm          s             10    dim(31) alt(tabopt)
700bDD*tabopt          s              3    dim(32) ctdata perrcd(1)
700bDD*tabpgm          s             10    dim(32) alt(tabopt)
700cDD*tabopt          s              3    dim(33) ctdata perrcd(1)
700cDD*tabpgm          s             10    dim(33) alt(tabopt)
710bDD*tabopt          s              3    dim(32) ctdata perrcd(1)
710bDD*tabpgm          s             10    dim(32) alt(tabopt)
710cDD*tabopt          s              3    dim(33) ctdata perrcd(1)
710cDD*tabpgm          s             10    dim(33) alt(tabopt)
720aDD*tabopt          s              3    dim(34) ctdata perrcd(1)
720aDD*tabpgm          s             10    dim(34) alt(tabopt)
720aDD*tabopt          s              3    dim(35) ctdata perrcd(1)
720aDD*tabpgm          s             10    dim(35) alt(tabopt)
730aDD*tabopt          s              3    dim(36) ctdata perrcd(1)
730aDD*tabpgm          s             10    dim(36) alt(tabopt)
730bDD*tabopt          s              3    dim(37) ctdata perrcd(1)
730bDD*tabpgm          s             10    dim(37) alt(tabopt)
740aDD*tabopt          s              3    dim(38) ctdata perrcd(1)
740aDD*tabpgm          s             10    dim(38) alt(tabopt)
740aMD tabopt          s              3    dim(39) ctdata perrcd(1)
740aMD tabpgm          s             10    dim(39) alt(tabopt)
417dD**                  MNU     1  26 20
650aDD*mnu             s             20    dim(39) ctdata perrcd(1)
650aDD*mnu             s             20    dim(40) ctdata perrcd(1)
700bDD*mnu             s             20    dim(41) ctdata perrcd(1)
700cDD*mnu             s             20    dim(42) ctdata perrcd(1)
710bDD*mnu             s             20    dim(39) ctdata perrcd(1)
720aDD*mnu             s             20    dim(40) ctdata perrcd(1)
720aDD*mnu             s             20    dim(41) ctdata perrcd(1)
730aDD*mnu             s             20    dim(42) ctdata perrcd(1)
730bDD*mnu             s             20    dim(43) ctdata perrcd(1)
740aDD*mnu             s             20    dim(52) ctdata perrcd(1)
740aMD mnu             s             20    dim(53) ctdata perrcd(1)
640aA*----------------------------------------------------------------
640aA* Error message(s)
640aAD err01           c                   const('You are not authorized -
640aAD                                     to use this option.')
510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*
     D @getcl          c                   const('GETCLIENT')
640aAD @autpg          c                   const('CHKLIST')
510aA*
510bA /COPY QCOPYSRC,ID#ROYAL
530aA /COPY QCOPYSRC,ID#YHATA
DRYaA /copy qcopysrc,id#dairyla
FRF A /copy qcopysrc,id#frf
EI  A /copy qcopysrc,id#ei
JSLaA /copy qcopysrc,id#jsl
     *----------------------------------------------------------------
     *  Data structure for menu display
     *
     D dsmenu          ds
     D  wolin1                 1     20
     D  wolin2                21     40
     D  wolin3                41     60
     D  wolin4                61     80
     D  wolin5                81    100
     D  wolin6               101    120
     D  wolin7               121    140
     D  wolin8               141    160
     D  wolin9               161    180
     D  woli10               181    200
     D  woli11               201    220
     D  woli12               221    240
     D  woli13               241    260
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eropt                  1      2
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
640aAD $rtncd          s              8
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D maxmnu          s              3  0
     D menu            s              3  0
     D mp              s              3  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D w1opta          s              3
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *
     *      $POPT     Selected option (0 = Exit)
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $popt             2
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $popt = *blanks
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
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
MSG D**                   EXSR ZMCMSG
MSG MC                   exsr      zmcpmq
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
     C                   select
     **         STATUS    WHEQ ROLLUP
     C                   when      *in81
     C                   if        menu < maxmnu
     C                   add       1             menu
     C                   add       13            mp
     C                   exsr      zzfil1
     C                   endif
416 AC                   exsr      zzwhse
     *
     C                   when      *in82
     C                   if        menu > 1
     C                   eval      menu = menu - 1
     C                   eval      mp = mp - 13
     C                   exsr      zzfil1
     C                   endif
416 AC                   exsr      zzwhse
     *
     **         STATUS    WHEQ COMAND
     C                   when      *inkc
     C                   eval      $popt = 'F3'
     C                   eval      nxtscr = 'EOJ'
     *
     C                   when      *inkl
     C                   eval      $popt = 'F2'
     C                   eval      nxtscr = 'EOJ'
     *
     C                   other
     C                   exsr      zzchk1
     C                   if        error = *off
     C                   exsr      zzupd1
     C                   endif
     C                   endsl
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
510aA*
510aA* Get client id.
510aA*
510aAC                   call      @getcl
510aAC                   parm                    client           10
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
MSG D**                   EXSR ZMIMSG
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
MSG D*
MSG D*    ZMCMSG  Clear message record subfile
MSG D*
MSG D**         ZMCMSG    BEGSR
MSG D**                   MOVE *OFF      *IN97
MSG D**                   WRITEMSGCTL
MSG D**                   Z-ADD*ZERO     MSGK    40
MSG D**                   WRITEMSGCLR
MSG D**                   MOVE '*CLEAR ' #MSGID  7
MSG D**                   MOVE '*NULL  ' #MSGTP  7
MSG D**                   EXSR ZMPMSG
MSG D**                   ENDSR
MSG A*
MSG A*    ZMCPMQ  Clear program message queue.
MSG A*
MSG AC     zmcpmq        begsr
MSG AC                   eval      #msgid = '*CLEAR '
MSG AC                   eval      #msgtp = '*NULL  '
MSG AC                   exsr      zmpmsg
MSG AC                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
MSG D**         MSGK      IFGT 0
     C                   write     msgctl
MSG D**                   Z-ADD*ZERO     MSGK
MSG D**                   END
     C                   endsr
MSG D*
MSG D*    ZMIMSG  Initialization necessary for message subfile
MSG D*
MSG D**         ZMIMSG    BEGSR
MSG D**                   MOVE #PROG     #PGMQ  10
MSG D**                   EXSR ZMCMSG
MSG D**                   ENDSR
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
MSG D**         #MSGID    IFNE '*CLEAR '
MSG D**                   ADD  1         MSGK
MSG D**                   WRITEMSGREC
MSG D**                   END
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
MSG D*
MSG D*    ZMQMSG  Add message record to subfile from program queue
MSG D*
MSG D**         ZMQMSG    BEGSR
MSG D**                   ADD  1         MSGK
MSG D**                   WRITEMSGREC
MSG D**                   ENDSR
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
416 A*----------------------------------------------------------------
416 A*   PIR0105  Generic message.
416 A*
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0108  Invalid option entered.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
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
     *  Verify option.
     *
     C                   movel     w1opt         w1opta
     C     w1opta        lookup    tabopt        tabpgm                   50
     C                   if        not *in50  or
417cAC                             tabpgm = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   move      w1opt         eropt
     C                   exsr      zm0108
     C                   endif
     *   Check authorization.
DRYaAC                   select
DRYaAC                   when      client = dairyland
FRF AC                             or client = frf
EI  AC                             or client = ei
JSLaAC                             or client = jsilvert
RYLbAC                             or client = royal
DRYaAC                   if        w1opt =  4
DRYaAC                   call      @autpg
DRYaAC                   parm                    #prog
DRYaAC                   parm      ' 4'          pgmopt           20
DRYaAC                   parm                    #user
DRYaAC                   parm                    $rtncd
DRYaAC                   if        $rtncd = '*NO'
DRYaAC                   eval      error = '1'
DRYaAC                   eval      *in21 = *on
DRYaAC                   eval      *in01 = *on
DRYaAC                   eval      errmsg = err01
DRYaAC                   exsr      ZM0105
DRYaAC                   endif
DRYaAC                   endif
DRYaAC                   endsl
FRFaA*
FRFaAC                   select
FRFaAC                   when         client = frf
EIa AC                             or client = ei
FRFaA*      RF Slot Transfers.
FRFaAC                   if        w1opt =  7
FRFaAC                   call      @autpg
FRFaAC                   parm                    #prog
FRFaAC                   parm      ' 7'          pgmopt
FRFaAC                   parm                    #user
FRFaAC                   parm      ' '           $rtncd
FRFaA*
FRFaA*      Not authorized to one of above options.
FRFaAC                   if        $rtncd = '*NO'
FRFaAC                   eval      error = '1'
FRFaAC                   eval      *in21 = *on
FRFaAC                   eval      *in01 = *on
FRFaAC                   eval      errmsg = err01
FRFaAC                   exsr      ZM0105
FRFaAC                   endif
FRFaA*
FRFaAC                   endif
FRFaA*
FRFaAC                   endsl
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   movea     mnu(mp)       dsmenu
     C                   eval      w1opt = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
MSG AC                   eval      #pgmq = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
417dD*R                   Z-ADD2         MAXMNU  30
730bDC*                  eval      maxmnu = 3
730bMC                   eval      maxmnu = 4
     C                   eval      menu = 1
     C                   eval      mp = 1
RYLaA*
RYLaA*  For Royal, remove adjustment option
RYLaA*
RYLbA ***                if        client = royal
RYLbA ***                eval      mnu(4) = *blanks
RYLbA ***                endif
530aA*
530aA*  For YHata, add loader option 24 & 25
530aA*
530bAC*                  if        client <> yhata
530bAC*                  eval      mnu(24) = *blanks
530bAC*                  eval      mnu(25) = *blanks
530bAC*                  endif
     *
     C                   exsr      zsclr
     C                   exsr      scr01i
416 AC                   exsr      zzwhse
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     *
     C                   select
     C                   when      w1opt = 90
     C                   move      w1opt         $popt
     C                   eval      nxtscr = 'EOJ'
     C                   other
     C                   call      tabpgm                               49
     C                   if        not *in49
     C                   eval      w1opt = 0
     C                   endif
     C                   endsl
     *
     C     endup1        endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZWHSE   Display user's default warehouse in message line.
416 A*
416 AC     zzwhse        begsr
     *
     C                   call      'GETWHSE2'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      ' '           #desc            30
     C                   parm      ' '           #frmt            40
     C                   eval      errmsg = #frmt
     C                   exsr      zm0105
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
**  TABOPT/TABPGM
01 SL620CL
02 SL160CL
03 LP120CL
04 IT220CL
05 IT230CL
06 RC200CL
07 IT250CL
08 LT105CL
09 PO200CL
10 TE152CL
11 IV330CL
12 OR650CL
13 IT600CL
14 PS430CL
15 SL120CL
16 IT262CL
17 IT263CL
18 OR200CL
19 OR680CL
20 EQ410CL
21 SCD100CL
22 EQ613CL
23 RU310CL
24 LOADRFCL1A
25 LOADRFCL2A
26 OR400CL
27 RC180CL
28 LB411RCL
31 EQ480CL
32 EQ485CL
33 EQ490CL
35 PO250CL
36 PS195CL
37 RTC330CL
38 OR402CL
39 UI620
87 SU240CL
88 SU140CL
90 SIGNOFF
**  MNU
1. Slot Info
 2. Verify Zero Slots
 3. License Info
 4. Inventory Adjust.
 5. Item Lookup
 6. Putaway
 7. Transfer
 8. Replenishment
 9. P.O. Receiving
10. Task Entry
11. Inventory Entry
12. Willcall Pick

13. Item Data Collection
 14. Pallet License Info
 15. Chg pick slot
 16. Willcall Tfr
 17. Willcall Tfr Rtn
 18. Single Ord Pick
 19. Bulk Picks
 20. Eq Check In/Out
 21. Check Digit
 22. Upd Yard Status
 23. Clear flags
 24. Pallet Loading

25  Flagged item Loading
 26. RF Pick
 27. Rcv item no PO
 28. Asg GS1 to item
 31. Load Equip
 32. Return Equip
 33. Ret Eq no RtId
 35. Box Labeler
 36. Pallet Info
 37. RTC Count
 38. UCI Select Chgs
 39. UCI Lookup

87. Set Item-License
 88. StuffIt









 90. Sign-off

