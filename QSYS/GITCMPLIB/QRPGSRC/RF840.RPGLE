510bA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   WARNING:  Y.HATA uses CMS RF820 Menu, hard coded.
     *   This program calls the CMS RF820 Menu, do not need to change
     *   this program.  Make chages in CMS RF820 menu.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RF840    RF 8 X 40 menu
     *  08 May, 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *  Created using RF820
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    8 X 40 Screens for vehicle mounted scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *    09/10/98  RH   4.10
     *      -  Add Option 10, Will Call Pick.
     *
412 A*    09/20/99  DAS  4.12
     *      - Removed option 7 - Replenishments.  No reason to do
     *        potential replenishments when using RF.
413 A*    12/22/99  RH   4.13
     *      - Added option 7 - RF Transfer.
413aA*    02/25/00  MLB  4.13a
     *      - Moved option 8 - Slot repl. to option 13. Renamed
     *        to 'Manual Repl'.
     *      - Added option 8 - Repl/Letdowns.
413bA*    03/22/00  RH   4.13b
     *      - Move option 90.
     *      - Added option 10-Task Entry & option 11-Inventory Entry.
     *
414 A*    07/10/00  DAS  4.14
     *      - Added option 14-Stage Putaway.
     *
414aA*    07/27/00  DAS  4.14a
     *      - Revised to use special message handling. See notes
     *        below. Changes marked with MSG instead of 414a.
     *      - Revised to call menu option program from within this
     *        program instead of returning to calling program.
     *      - Created new lookup table TABOPT/TABPGM to contain all
     *        of the options used by the menu along with the program
     *        that is to be called.
     *      - Merged individual MNU* tables into single MNU table.
     *      - Simplified method of changing menu. See notes below.
     *      - Removed menu option 13-Manual Replenishment.
     *
415 A*    02/27/01  HNK  4.15
     *      - Add option 13 for RF item data collection program.
415aA*    04/11/01  MLB  4.15a
     *      - Add option 15 for RF Change pick slot program.
     *
416 A*    05/10/02  DAS  4.16
     *      - Added logic to display user's default warehouse in
     *        message line.
     *
416aA*    05/07/02  MLB  4.16a
     *      - Add option 16 for RF Willcall Transfer program.
     *      - Add option 17 for RF Willcall Transfer Returns program.
     *
416bA*    05/31/02  DAS  4.16b
     *      - Add option 18 for Single Order Pick program
     *      - Added new set of menu lines.
416cA*    07/10/02  DAS  4.16c
     *      - Add option 88 for RF StuffIt.
416dA*    10/04/02  MLB  4.16d
     *      - Add option 19 for RF Bulk Pick Selection.
     *
417aA*    01/28/03  RH   4.17a
     *      - Add option 20 for RF Equipment check In/Out.
417bA*    11/24/03  RH   4.17b
     *      - Add option 21 for RF Check Digit.
417cA*    02/17/04  MLB  4.17c
     *      - Add option 22 for Yard Status.
417dA*    02/27/04  MLB  4.17d
     *      - Fix: Add test for blank TABPGM. If blank, treat
     *        option as invalid.
417eA*    06/10/04  MLB  4.17e
     *      - Enh: Add option 23 for Clear Flags. Calls pgm
     *        RU310CL.
500 A*    01/13/05  RLP  5.00
     *      - Enh: Remove option 14 - Stage Putaway, obsolete
500bA*    01/05/06  RH   5.00b
     *      - Enh: Add option 14 - Pallet license info.
500cA*    04/10/06  RH   5.00c
     *      - Enh: Add option 24 - RF Bulk Drop calls OR685CL
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
650aA*    06/10/14  RBD  6.50a
     *      - Enh: Added opt 27, Receive item without a PO.
700aA*    03/07/16  RH   7.00a
     *      - Enh: Added opt 87, Set Item/License for start up
700b *    03/10/16  GJA  7.00b
     *      - Enh: Added opt 28, Assign GS1 to item
700cA*    06/02/16  RBD  7.00c
     *      - Enh: Added opts 31 Load Equip and 32 Return Equip.
     *        Tidied up some things from the past where an option had
     *        been removed but tables were not updated properly.
710a *    02/09/17  GJA  7.10a
     *      - Enh: Remove reference to letdown.
710bA*    02/15/17  RBD  7.10b
     *      - Enh: Added opt 33 Ret Eq no Rt.
720aA*    11/19/18  LMC  7.20a
     *      - Enh: Added opt 35 Box Labeler
720b *    11/30/18  GJA  7.20b
     *      - Enh: Added opt 36 Pallet Info
730a *    05/30/19  LMC  7.30a
     *      - Enh: Added opt 37 RTC Count
     *
730b *    09/19/19  LMC  7.30b
     *      - Enh: Added opt 38 UCI Selection Changes
     *
740aA*    08/20/20  LMC  7.40a
     *      - Enh: Added opt 39 RF UCI lookup
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*   02/22/11  RH   DRYa
     *     - Check if user authorized for adjustments.
     *
     *----------------------------------------------------------------
     *
JSLa *   08/11/15  GJA  JSLa
     *     - Check if user authorized for adjustments.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Royal
     *
RYLaA*   06/11/07  DAS  RYLa
     *     - Add CHKLIST to verify user for adjustments.
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
     * Client Custom Revisions: Farm Boy
FBYa *   04/13/17  RH   FBYa
     *     - Check if user authorized for adjustments.
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
     *    The following needs to be done to add a new screen of       .
     *    menu options:
     *                                                                y
     *      1) Add 5 to the number of table entries for the MNU
     *         E-Spec.
     *      2) Add 5 lines to the actual table at the end of the
     *         program.
     *      3) Add 1 to the value being loaded into field MAXMNU
     *         in routine ZZINZ2.
     *
     *    The following needs to be done to utilize a new menu        .
     *    option:
     *                                                                y
     *      1) Increase the table entries for TABOPT/TABPGM for
     *         the number of option(s) being added.
     *      2) Add the option(s) and corresponding program name to
     *         the TABOPT/TABPGM table at the end of the program.
     *
     *    The following needs to be done to to remove an option       .
     *    from being used:
     *                                                                y
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
     Frf840fm   cf   e             workstn
     F                                     infds(infds)
MSG D*                                       MSGK  KSFILE MSGREC
     *----------------------------------------------------------------
     *  Table and array definitions
     *
740aMD tabopt          s              3    dim(40) ctdata perrcd(1)
740aMD tabpgm          s             10    dim(40) alt(tabopt)
740aDD*tabopt          s              3    dim(39) ctdata perrcd(1)
740aDD*tabpgm          s             10    dim(39) alt(tabopt)
730bDD*tabopt          s              3    dim(38) ctdata perrcd(1)
730bDD*tabpgm          s             10    dim(38) alt(tabopt)
730aDD*tabopt          s              3    dim(37) ctdata perrcd(1)
730aDD*tabpgm          s             10    dim(37) alt(tabopt)
720aDD*tabopt          s              3    dim(36) ctdata perrcd(1)
720aDD*tabpgm          s             10    dim(36) alt(tabopt)
720aDD*tabopt          s              3    dim(35) ctdata perrcd(1)
720aDD*tabpgm          s             10    dim(35) alt(tabopt)
710bDD*tabopt          s              3    dim(34) ctdata perrcd(1)
710bDD*tabpgm          s             10    dim(34) alt(tabopt)
700cDD*tabopt          s              3    dim(32) ctdata perrcd(1)
700cDD*tabpgm          s             10    dim(32) alt(tabopt)
700bDD*tabopt          s              3    dim(31) ctdata perrcd(1)
700bDD*tabpgm          s             10    dim(31) alt(tabopt)
700aDD*tabopt          s              3    dim(30) ctdata perrcd(1)
700aDD*tabpgm          s             10    dim(30) alt(tabopt)
530bMD*tabopt          s              3    dim(29) ctdata perrcd(1)
530bMD*tabpgm          s             10    dim(29) alt(tabopt)
530bDD*tabopt          s              3    dim(28) ctdata perrcd(1)
530bDD*tabpgm          s             10    dim(28) alt(tabopt)
530aDD*tabopt          s              3    dim(26) ctdata perrcd(1)
530aDD*tabpgm          s             10    dim(26) alt(tabopt)
500cD**                  TABOPT  1  25  3   TABPGM 10
500bD**                  TABOPT  1  24  3   TABPGM 10
500 D**                  TABOPT  1  25  3   TABPGM 10
417eD**                  TABOPT  1  24  3   TABPGM 10
417cD**                  TABOPT  1  23  3   TABPGM 10
417bD**                  TABOPT  1  22  3   TABPGM 10
417dD**                  TABOPT  1  21  3   TABPGM 10
416dD**                  TABOPT  1  20  3   TABPGM 10
416CD**                  TABOPT  1  19  3   TABPGM 10
416bD**                  TABOPT  1  16  3   TABPGM 10
415aD*                   TABOPT  1  15  3   TABPGM 10
416bD**                  MNU     1  10 40
417eD**                  MNU     1  15 40
700cDD*mnu             s             40    dim(20) ctdata perrcd(1)
720aMD*mnu             s             40    dim(25) ctdata perrcd(1)
720aMD*mnu             s             40    dim(27) ctdata perrcd(1)
730aDD*mnu             s             40    dim(28) ctdata perrcd(1)
730bDD*mnu             s             40    dim(29) ctdata perrcd(1)
740aDD*mnu             s             40    dim(30) ctdata perrcd(1)
740aMD mnu             s             40    dim(31) ctdata perrcd(1)
414aD*                   MNU1    1   5 40
414aD*                   MNU2    1   5 40
     *                   MNU3    1   5 40
RYLAAD mnur            s             40    dim(1) ctdata perrcd(1)
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
510bM /COPY QCOPYSRC,ID#ROYAL
530aA /COPY QCOPYSRC,ID#YHATA
DRYaA /copy qcopysrc,id#dairyla
JSLaA /copy qcopysrc,id#jsl
FRF A /copy qcopysrc,id#frf
EI  A /copy qcopysrc,id#ei
FBYaA /copy qcopysrc,id#fby
     *----------------------------------------------------------------
     *  Data structure for menu display
     *
     D dsmenu          ds
     D  wolin1                 1     40
     D  wolin2                41     80
     D  wolin3                81    120
     D  wolin4               121    160
     D  wolin5               161    200
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
414aAC                   if        menu < maxmnu
414aAC                   add       1             menu
414aAC                   add       5             mp
414aAC                   exsr      zzfil1
414aAC                   endif
416 AC                   exsr      zzwhse
     *
414aD**         MENU      IFEQ 1
414aD**                   MOVEAMNU2      DSMENU
414aD**                   Z-ADD2         MENU
414aD**                   ELSE
414aD**                   MOVEAMNU3      DSMENU
414aD**                   Z-ADD3         MENU
414aD**                   ENDIF
     *
     **         STATUS    WHEQ ROLLDN
     C                   when      *in82
414aAC                   if        menu > 1
414aAC                   eval      menu = menu - 1
414aAC                   eval      mp = mp - 5
414aAC                   exsr      zzfil1
414aAC                   endif
416 AC                   exsr      zzwhse
     *
414aD**         MENU      IFEQ 3
414aD**                   MOVEAMNU2      DSMENU
414aD**                   Z-ADD2         MENU
414aD**                   ELSE
414aD**                   MOVEAMNU1      DSMENU
414aD**                   Z-ADD1         MENU
414aD**                   ENDIF
     *
     **         STATUS    WHEQ COMAND
     C                   when      *inkc
     C                   eval      $popt = 'F3'
     C                   eval      nxtscr = 'EOJ'
     *
     C                   when      *inkl
     C                   eval      $popt = 'F2'
     C                   eval      nxtscr = 'EOJ'
     **                   ELSE
     **                   EXSR ZZCMD1
     **                   ENDIF
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
414aD**         W1OPT     IFLT 1
414aD**         W1OPT     ORGT 9
414aD**         W1OPT     ORGT 10
414aD**         W1OPT     ORGT 13
414aD**         W1OPT     ORGT 14
414aD**         W1OPT     ANDNE90
     *
414aAC                   movel     w1opt         w1opta
414aAC     w1opta        lookup    tabopt        tabpgm                   50
414aAC                   if        not *in50  or
RYLbMC                             tabpgm = *blanks
RYLbD ***                          client = royal  and
RYLbD ***                          w1opt = 4
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   move      w1opt         eropt
410 D*R         W1OPT     IFLT 10
413bD*R         W1OPT     IFLT 11
414 D**         W1OPT     IFLT 13
414 D**                   MOVEL' '       EROPT
414 D**                   ENDIF
     C                   exsr      zm0108
     C                   endif
DRYaAC                   select
DRYaAC                   when      client = dairyland
FRF AC                             or client = frf
EI  AC                             or client = ei
JSLaAC                             or client = jsilvert
FBYaAC                             or client = farmboy
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
414aD**                   MOVEAMNU1      DSMENU
414aMC                   movea     mnu(mp)       dsmenu
     C                   eval      w1opt = 0
414aD**                   Z-ADD1         MENU    10
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
416bD**                   Z-ADD2         MAXMNU  30
417eD**                   Z-ADD3         MAXMNU  30
700cDC**                 eval      maxmnu = 4
730bDC*                  eval      maxmnu = 5
730bMC                   eval      maxmnu = 6
414aAC                   eval      menu = 1
414aAC                   eval      mp = 1
RYLaA*
RYLaA*  For Royal, remove adjustment option
RYLaA*
RYLbD ***                if        client = royal
RYLbD ***                eval      mnu(4) = mnur(1)
RYLbD ***                endif
530aA*
530aA*  For YHata, add loader option 24 & 25
530aA*
530bDC*                  if        client <> yhata
530bDC*                  eval      mnu(16) = mnur(1)
530bDC*                  eval      mnu(17) = mnur(1)
530bDC*                  endif
     *
414aAC                   exsr      zsclr
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
414aAC                   select
414aAC                   when      w1opt = 90
     C                   move      w1opt         $popt
     C                   eval      nxtscr = 'EOJ'
414aAC                   other
414aAC                   call      tabpgm                               49
414aAC                   if        not *in49
414aAC                   eval      w1opt = 0
414aAC                   endif
414aAC                   endsl
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
30 OR685CL
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
1. Slot Info           5. Item Lookup
 2. Verify Zero Slot    6. Putaway
 3. License Info        7. Transfer
 4. Inventory Adjust    8. Replenishment

9. P.O. Receiving     13. Item Data Collection
10. Task Entry         14. Pallet License Info
11. Inventory Entry    15. Chg pick slot
12. Willcall Pick      16. Willcall Tfr

17. Willcall Tfr Rtn  21. Check Digit
 18. Single Order Pick 22. Upd Yard Status
 19. Bulk Picks        23. Clear flags
 20. Eq Check In/Out   24. Pallet Loading

25. Flagged Item Load 30. Bulk Drop
 26. RF Pick           31. Load Equip
 27. Rcv Item no PO    32. Return Equip
 28. Asg GS1 to item   33. Ret Eq no Rt

35. Box Labeler       39. UCI Lookup
 36. Pallet Info
 37. RTC Count
 38. UCI Select Chgs

87. Set Item-Lcns
 88. Stuffit

                       90. Sign-off

**  MNU2
                        8. Repl/Letdowns
