     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RF820S   RF 8 X 20 menu  Stand Alone
     *  10 November, 2006
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    11/10/06  RH   5.10
     *      - Created using RF820 for Stand Alone only
     *
640 A*    09/13/12  MLB  6.40
     *      - Enh: Revised to add options #1 Slot Info/SL620CL
     *        and #5 Item Lookup/IT230CL to the menu.
     *
650 A*    08/15/13  MLB  6.50
     *      - Enh: Revised to add option #13 Item Data Collection/
     *        IT600CL to the menu.
650aA*    08/15/13  MLB  6.50a
     *      - Enh: Converted pgm to ILE.
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
     Frf820sfm  cf   e             workstn
     F                                     infds(infds)
MSG D*                                       MSGK  KSFILE MSGREC
     *----------------------------------------------------------------
     *  Table and array definitions
     *
417dMD tabopt          s              3    dim(24) ctdata perrcd(1)
417dMD tabpgm          s             10    dim(24) alt(tabopt)
417dMD mnu             s             20    dim(35) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     *  Data structure for menu display
     *
     D dsmenu          ds
     D  wolin1                 1     20
     D  wolin2                21     40
     D  wolin3                41     60
     D  wolin4                61     80
     D  wolin5                81    100
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
650aA*
650aA*----------------------------------------------------------------
650aA*  Variables
650aA*
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
650aA*
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
414aD**                   SELEC
414aD****       MENU      IFEQ 1
414aD**         MENU      WHEQ 1
414aD**                   MOVEAMNU2      DSMENU
414aD**                   Z-ADD2         MENU
414aD****                 ELSE
414aD**         MENU      WHEQ 2
414aD**                   MOVEAMNU3      DSMENU
414aD**                   Z-ADD3         MENU
414aD**         MENU      WHEQ 3
414aD**                   MOVEAMNU4      DSMENU
414aD**                   Z-ADD4         MENU
414aD**         MENU      WHEQ 4
414aD****         ***Remain on menu 4***
414aD****                 ENDIF
414aD**                   ENDSL
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
414aD**                   SELEC
414aD**         MENU      WHEQ 4
414aD**                   MOVEAMNU3      DSMENU
414aD**                   Z-ADD3         MENU
414aD****       MENU      IFEQ 3
414aD**         MENU      WHEQ 3
414aD**                   MOVEAMNU2      DSMENU
414aD**                   Z-ADD2         MENU
414aD****                 ELSE
414aD**         MENU      WHEQ 2
414aD**                   MOVEAMNU1      DSMENU
414aD**                   Z-ADD1         MENU
414aD**         MENU      WHEQ 1
414aD****         ***Remain on menu 1***
414aD****                 ENDIF
414aD**                   ENDSL
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
414aD**         W1OPT     ORGT 6
414aD**         W1OPT     ORGT 9
414aD**         W1OPT     ORGT 10
414aD**         W1OPT     ORGT 11
414aD**         W1OPT     ANDNE14
414aD**         W1OPT     ANDNE90
     *
414aAC                   movel     w1opt         w1opta
414aAC     w1opta        lookup    tabopt        tabpgm                   50
414aAC                   if        not *in50  or
417cAC                             tabpgm = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   move      w1opt         eropt
410 D*R         W1OPT     IFLT 10
413 D*R         W1OPT     IFLT 11
414 D**         W1OPT     IFLT 12
414 D**                   MOVEL' '       EROPT
414 D**                   ENDIF
     C                   exsr      zm0108
     C                   endif
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
416cD**                   Z-ADD4         MAXMNU  30
416eD**                   Z-ADD5         MAXMNU  30
417dD**                   Z-ADD6         MAXMNU  30
417dMC                   eval      maxmnu = 7
414aAC                   eval      menu = 1
414aAC                   eval      mp = 1
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
02
03
04
05 IT230CL
06
07
08
09
10
11
12
13 IT600CL
14
15
16
17
18
19
21 SCD100CL
22
23
88
90 SIGNOFF
**  MNU
1. Slot Info
 2.
 3.
 4.

5. Item Lookup
 6.
 7.
 8.

9.
10.
11.
12.

13. Item Data Collection
 14.
 15.
 16.

17.
 18.
 19.
 20.

21. Check Digit
 22.
 23.
 88.




 90. Sign-off

