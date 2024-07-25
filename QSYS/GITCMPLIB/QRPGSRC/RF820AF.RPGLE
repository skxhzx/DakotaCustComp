510bA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RF820AF    RF 8 X 20 menu
     *  20 February 2008
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    02/20/08  MLB  5.20
     *      - Created.
     *      - Stripped down RF820 menu for Andrews Foodservice.
     *        Contains only RF Selection and signoff options.
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
     *      1) Add 5 to the number of table entries for the MNU
     *         E-Spec.
     *      2) Add 5 lines to the actual table at the end of the
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
     Frf820affm cf   e             workstn
     F                                     infds(infds)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D tabopt          s              3    dim(02) ctdata perrcd(1)
     D tabpgm          s             10    dim(02) alt(tabopt)
     D mnu             s             20    dim(05) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
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
     *----------------------------------------------------------------
     *  Variables
     *
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
     C                   exsr      zmcpmq
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
     C                   when      *in81
     C                   if        menu < maxmnu
     C                   add       1             menu
     C                   add       5             mp
     C                   exsr      zzfil1
     C                   endif
     C                   exsr      zzwhse
     *
     *
     C                   when      *in82
     C                   if        menu > 1
     C                   eval      menu = menu - 1
     C                   eval      mp = mp - 5
     C                   exsr      zzfil1
     C                   endif
     C                   exsr      zzwhse
     *
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
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
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
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR0105  Generic message.
     *
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
     *
     C                   movel     w1opt         w1opta
     C     w1opta        lookup    tabopt        tabpgm                   50
     C                   if        not *in50  or
     C                             tabpgm = *blanks  or
     C                             w1opt <> 90
     C                             and mnu(w1opt) = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   move      w1opt         eropt
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
     C                   eval      #pgmq = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      maxmnu = 1
     C                   eval      menu = 1
     C                   eval      mp = 1
     *
     C                   exsr      zsclr
     C                   exsr      scr01i
     C                   exsr      zzwhse
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
     *----------------------------------------------------------------
     *
     *  ZZWHSE   Display user's default warehouse in message line.
     *
     C     zzwhse        begsr
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
01 OR400CL
90 SIGNOFF
**  MNU
01. RF Pick
 90. Sign-off



