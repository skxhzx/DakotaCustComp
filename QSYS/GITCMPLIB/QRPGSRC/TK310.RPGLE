520aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TK310   Task overview - Display
     *  10 January 1996
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    02/01/96  DAS 1.01
     *      - Revised subfile positioning.
     *
     *    02/21/96  DAS 1.01
     *      - Revised to allow user to change end time.
     *      - Revised SAVOPT routine to call ZZUPD to update
     *        TASKDET with new end time.
216 A*    08/20/96  HNK 2.16
     *      - Revised to allow user to change employees needed.
     *      - Revised ZZFILL routine to ZZFIL1 routine.
     *      - ZZFIL2 routine added.
414 A*    09/19/00  HNK 4.14
     *      - Revised to indirect tasks and some other tasks that
     *        have no meaning in this program.
     *
520aA*    07/24/09  GJA 5.20a
     *      - Convert to RPGLE.  Recompile for Screen change.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program is very unique. A lot of code has been taken
     *    out of this program that you would normally find in a list
     *    display. The biggest difference are that there is no page
     *    up and down because we are loading all the records into the
     *    subfile.
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Ftk310fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno2)
     F                                     sfile(vw3sfl:recno3)
     F                                     sfile(msgrec:msgk)
     Ftask1     if   e           k disk
     Ftaskdet   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D $podsc          s             63    dim(3)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
VW2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dskey                  1     50
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
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *----------------------------------------------------------------
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
216 AD  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     D  dsmin                  7     10  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     D  @sfl                 378    379b 0
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
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
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D @sflsv          s                   like(@sfl)
     D cancel          s              1
     D chgflg          s              1
     D clear           s              5  0
     D comand          s              5  0
     D curmin          s              4  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D kywhse          s                   like(tdwhse)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nxtscr          s              3
     D otaken          s              1
     D pagcmd          s              8
     D posrec          s              4  0
     D reccnt          s              4  0
     D remhrs          s              4  2
     D remmin          s              4  0
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svstdp          s                   like(tdstdp)
     D tempc           s              7  2
     D tmphrs          s              2  0
     D tmpmin          s              2  0
     D tmppct          s              5  4
     D ttlmin          s              4  0
     D ttlpcs          s              5  0
     D updflg          s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D w1whse          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   seton                                        lr
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
101 AC                   z-add     @sfl          @sflsv
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   read      dspsfc                                 50
VW2 AC                   when      view = 2
VW2 AC                   read      vw2sfc                                 50
VW2 AC                   when      view = 3
VW2 AC                   read      vw3sfc                                 50
VW2 AC                   endsl
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
     C                   write     clr0306
     C                   exsr      zzload
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
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
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      zzload
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
VW2 A*
VW2 A*  TEST FOR CMD10 - Previous view
VW2 A*
VW2 AC                   if        *inkj
VW2 AC                   if        view = 1
VW2 AC                   eval      view = maxvw
VW2 AC                   else
VW2 AC                   eval      view = view - 1
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
VW2 A*
VW2 A*  TEST FOR CMD11 - Next view
VW2 A*
VW2 AC                   if        *inkk
VW2 AC                   if        view = maxvw
VW2 AC                   eval      view = 1
VW2 AC                   else
VW2 AC                   add       1             view
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      zzpos2
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      zzpos2
     C                   goto      cmd01e
     C                   endif
     *
VW2 M*  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
VW2 MC                   if        *inku
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      pagcmd = '*MOV2TOP'
     C                   exsr      zzpos2
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
101 AC                   exsr      zzupd
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
VW2 AC                   eval      recno2 = reccnt
VW2 AC                   eval      recno3 = reccnt
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
216 MC                   exsr      zzfil1
     C                   write     dspsfl
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
VW2 AC                   eval      recno2 = 0
VW2 AC                   eval      recno3 = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     dspsfc
VW2 AC                   write     vw2sfc
VW2 AC                   write     vw3sfc
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
101 D*          ERROR     IFNE '1'
101 D*                    SELEC
101 D*          VIEW      WHEQ 1
101 D*          1         CHAINDSPSFL               79
101 D*          *IN79     IFEQ '0'
101 D*                    MOVE '1'       *IN20
101 D*                    UPDATDSPSFL
101 D*                    END
101 D*          VIEW      WHEQ 2
101 D*          1         CHAINVW2SFL               79
101 D*          *IN79     IFEQ '0'
101 D*                    MOVE '1'       *IN20
101 D*                    UPDATVW2SFL
101 D*                    END
101 D*          VIEW      WHEQ 3
101 D*          1         CHAINVW3SFL               79
101 D*          *IN79     IFEQ '0'
101 D*                    MOVE '1'       *IN20
101 D*                    UPDATVW3SFL
101 D*                    END
101 D*                    ENDSL
101 D*                    END
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
101 D*                    Z-ADDPOSREC    RECNO
101 D*                    Z-ADDPOSREC    RECNO2
101 D*                    Z-ADDPOSREC    RECNO3
101 AC                   if        @sflsv = 0
101 AC                   z-add     1             @sflsv
101 AC                   endif
101 MC                   z-add     @sflsv        recno
101 MC                   z-add     @sflsv        recno2
101 MC                   z-add     @sflsv        recno3
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   write     dspsfc
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
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
     *R                   WRITECLRSCR
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
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
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
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
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
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
     C                   if        row# = 4  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZH2M    Convert hours (HHMMSS) to minutes (MMMM)
     *
     *    Input:   DSHMS  -  Time in HHMMSS.
     *    Output:  DSMIN  -  Time in minutes.
     *
     C     zzh2m         begsr
     *
     *   Round to minutes.
     *
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   Convert hours to minutes.
     *
     C                   eval      dsmin = dshh * 60
     *
     *   Add minutes.
     *
     C                   add       dsmm          dsmin
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLOAD   Load subfile with all records.
     *
     C     zzload        begsr
     C                   exsr      sflclr
     *
     *   Get current time in minutes.
     *
     C                   time                    dshms
     C                   exsr      zzh2m
     C                   eval      curmin = dsmin
     *
     *   Read through task file in category/subcategory order.
     *
     C     *loval        setll     task1
     C                   dow       forevr = forevr
     C                   read      task1                                  79
     C                   if        *in79
     C                   leave
     C                   endif
414 A*  Skip MISC category task codes.
414 AC                   if        tkcat = 'MISC'
414 AC                   iter
414 AC                   endif
414 A*  Skip Transfer and Verify zero slot task.
414 AC                   if        tksub = 'TRNSFR'  or
414 AC                             tksub = 'VERIFY'
414 AC                   iter
414 AC                   endif
     *
     *     Get task detail records and write to subfiles.
     *
     C     partky        setll     taskdet
     C                   dow       forevr = forevr
     C     partky        reade(n)  taskdet                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      sfladd
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill display line with values that need
     *           to be converted.
     *
216 MC     zzfil1        begsr
     *
     *   Remaining hours
     *
     C                   if        tdetim = 0
     C                   eval      w1rem = 0
     C                   eval      remhrs = 0
     C                   else
     *
     *     Convert end time into minutes.
     *
     C                   eval      dshms = tdetim
     C                   exsr      zzh2m
     *
     *     Calculate difference.
     *
     C                   eval      remmin = dsmin - curmin
     *
     *     When difference is less than zero ....
     *       If greater than 12 hours then set to zero.
     *       Otherwise times are split across midnight.
     *
     C                   if        remmin < 0
     C                   if        remmin > 720
     C                   eval      remmin = 0
     C                   else
     C                   eval      remmin = 1440 - curmin
     C                   add       dsmin         remmin
     C                   endif
     C                   endif
     *
     *     Convert back to hours and hours/minutes
     *
     C     remmin        div(h)    60            remhrs
     C     remmin        div       60            tmphrs
     C                   mvr                     tmpmin
     C     tmphrs        mult      100           w1rem
     C                   add       tmpmin        w1rem
     *
     C                   endif
     *
     *   Percent of pieces completed
     *
     C     tdpndp        add       tdactp        ttlpcs
     C                   add       tdfinp        ttlpcs
     C                   if        ttlpcs = 0
     C                   eval      w1pct = 0
     C                   else
     C     tdfinp        div(h)    ttlpcs        tmppct
     C     tmppct        mult(h)   100           w1pct
     C                   endif
     *
     *   Employees needed to finish job (Based on pieces/hr)
     *
     *       Calculation:  A / B = C
     *                     C / D = E
     *
     *           where A = Pending pieces to pick
     *                 B = Std pieces per hour per employee
     *                 C = Hours needed for 1 employee
     *                      or Employees needed to finish within 1 hour
     *                 D = Hours remaining
     *                 E = Employees needed to finish withing hrs left
     *
     C                   if        tdstdp = 0
     C                   eval      w1need = 0
     C                   else
     C     tdpndp        div(h)    tdstdp        tempc
     C                   if        remhrs = 0
     C                   z-add     tempc         w1need
     C                   else
     C     tempc         div(h)    remhrs        w1need
     C                   endif
     C                   endif
     *
216 AC                   eval      svneed = w1need
     *
     *   End time
     *
     C     tdetim        div       100           w1etim
216 AC     tdetim        div       100           svetim
     *
     C                   endsr
216 A*----------------------------------------------------------------
216 A*  ZZFIL2
216 A*
216 AC     zzfil2        begsr
216 A*
216 AC                   if        tdstdp <> 0
216 AC     tdpndp        div(h)    tdstdp        tempc
216 AC                   else
216 AC                   eval      tempc = 0
216 AC                   endif
216 A*
216 AC                   if        w1need <> 0
216 AC     tempc         div(h)    w1need        remhrs
216 AC                   else
216 AC                   eval      remhrs = 0
216 AC                   endif
216 A*
216 AC                   eval      remmin = remhrs * 60
216 AC     remmin        div       60            tmphrs
216 AC                   mvr                     tmpmin
216 AC     tmphrs        mult      100           w1rem
216 AC                   add       tmpmin        w1rem
216 A*
216 A*
216 A*   Get current time in minutes.
216 A*
216 AC                   time                    dshms
216 AC                   exsr      zzh2m
216 AC                   eval      curmin = dsmin
216 AC     remmin        add       curmin        ttlmin
216 A*
216 A*   Convert to hours and minutes.
216 A*
216 AC                   if        remmin > 0
216 AC                   if        ttlmin > 1440
216 AC                   eval      ttlmin = ttlmin - 1440
216 AC                   endif
216 AC     ttlmin        div       60            tmphrs
216 AC                   mvr                     tmpmin
216 AC     tmphrs        mult      100           w1etim
216 AC                   add       tmpmin        w1etim
216 AC                   else
216 AC                   eval      w1etim = 0
216 AC                   endif
216 A*
216 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    tkcode
     C                   kfld                    kywhse
     *
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
VW2 AC                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
101 AC                   z-add     1             @sfl
     C                   eval      zopt = zopt
     *
     *   Get warehouse for user.
     *
     C                   eval      w1whse = 0
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm                    w1whse
     C                   eval      kywhse = w1whse
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = kywhse
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
     C                   else
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      kywhse = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      kywhse = ptinp1
     C                   eval      w1whse = ptinp1
     C                   movel     $lerm         whdesc
     C                   exsr      zzload
     C                   eval      ptinp1 = 0
     C                   endif
     C                   endif
     C                   endif
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     C                   select
     C                   when      pagcmd = '*BOTTOM '
101 D*                    Z-ADDRECCNT    POSREC
101 MC                   z-add     reccnt        @sflsv
     *R         RECCNT    SUB  9         POSREC
     *R         POSREC    IFLT 1
     *R                   Z-ADD1         POSREC
     *R                   ENDIF
     C                   when      pagcmd = '*MOV2TOP'
     C     recno         add       row#          posrec
     C                   if        posrec > reccnt
     C                   eval      posrec = reccnt
     C                   endif
     C                   other
101 D*                    Z-ADD1         POSREC
101 MC                   z-add     1             @sflsv
     C                   endsl
     *
     *R         RECCNT    IFGT 0
     *R                   MOVE *ON       *IN81
     *R                   ENDIF
     *R                   Z-ADDPOSREC    RECNO
VW2 A*R                   Z-ADDPOSREC    RECNO2
VW2 A*R                   Z-ADDPOSREC    RECNO3
VW2 A*R                   SELEC
VW2 A*R         VIEW      WHEQ 1
     *R                   WRITEDSPSFC
VW2 A*R         VIEW      WHEQ 2
VW2 A*R                   WRITEVW2SFC
VW2 A*R         VIEW      WHEQ 3
VW2 A*R                   WRITEVW3SFC
VW2 A*R                   ENDSL
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update ITEMDET from subfile.
     *
     C     zzupd         begsr
     *
     C                   eval      updflg = *off
     C                   eval      chgflg = *off
     *
     *  Initialize key and fields.
     *
     C     keytd         klist
     C                   kfld                    tkcode
     C                   kfld                    kywhse
     C                   kfld                    tdwhdp
     C                   kfld                    tdstyp
     *
     *
     *  View 3
     *
     C                   if        view = 3
     C                   dou       forevr <> forevr
     C                   readc     vw3sfl                                 78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      chgflg = *on
     C                   eval      svstdp = tdstdp
     C     keytd         chain     taskdet                            77
     C                   if        not *in77
     C                   eval      tdstdp = svstdp
216 AC                   if        w1need <> svneed
216 AC                   exsr      zzfil2
216 AC                   endif
     C     w1etim        mult      100           tdetim
     C                   update    tdrec
     *R                   EXSR ZZFILL
     *R                   Z-ADDW1NEED    SVNEED
     *R                   UPDATVW3SFL
     *R         RECNO3    CHAINDSPSFL               77
     *R                   Z-ADDSVNEED    W1NEED
     *R                   UPDATDSPSFL
     *R         RECNO3    CHAINVW2SFL               77
     *R                   Z-ADDSVNEED    W1NEED
     *R                   UPDATVW2SFL
     C                   endif
     C                   enddo
     C                   if        chgflg = *on
     C                   exsr      zzload
     C                   eval      updflg = *on
     C                   endif
     C                   endif
     C                   if        status = enter  and
     C                             updflg = *off
     C                   exsr      zzload
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F3=Exit  F5=Refresh  F10=View 3  F11=View 2  F12=Cancel
F17=Top  F18=Bottom
F3=Exit  F5=Refresh  F10=View 1  F11=View 3  F12=Cancel
F17=Top  F18=Bottom
F3=Exit  F5=Refresh  F10=View 2  F11=View 1  F12=Cancel
F17=Top  F18=Bottom
