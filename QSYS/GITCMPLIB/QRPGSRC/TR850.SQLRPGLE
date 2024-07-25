      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR850   Tracker - Assign driver to route
     *  10 March 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
530 A*    03/10/10  RBD  5.30
     *      - Created.
     *
640 A*    09/29/11  RBD  6.40
     *      - Added new fields for route and truck.
     *
640aA*    03/05/12  RBD  6.40a
     *      - Recompiled, TTRTE file changed.
     *
650a *    02/01/13  GJA  6.50a
     *      - Fix:  Default warehouse
650b *    02/07/13  LMC  6.50b
     *      - Enh:  Allow the user name or number to be entered
     *
650cA*    08/26/13  RBD  6.50c
     *      - Recompiled, TTLOG file changed.
     *
650dA*    08/26/13  RBD  6.50d
     *      - Fix: Chg 650b to only look for numeric user if numbers
     *        were entered for user, else the %dec calc fails.
     *
700aA*    01/08/16  RBD  7.00a
     *      - Call TR811 to create Trax version 1.3.
     *
710aA*    01/24/17  RBD  7.10a
     *      - Enh: added Trax training routes file.  If Trax training
     *        route bypass download edit.
     *
710bA*    12/02/17  DAS  7.10b
     *      - Fix: Revised to not use keyWhsRtid. In zzchk1 the
     *             key fields did not get initialized.
     *
730aA*    01/28/19  RBD  7.30a
     *      - Fix: Don't turn override on if driver was blank.
     *
730bA*    10/22/19  RBD  7.30b
     *      - Allow driver change even if route already downloaded.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HALa *    10/10/17  GJA  HALa
     *      - Enh:  Send DRIVER to US900 for lookup on Crew.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
SFGa *    02/07/13  LMC  SFGa
     *      - Enh:  Send DRIVER to US900 for lookup on Crew.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly Foods
KFSa *    03/04/13  LMC  KFSa
     *      - Enh:  Send DRIVER to US900 for lookup on Crew.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Ftr850fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser   if   e           k disk
650bAFpiruser1  if   e           k disk    rename(usrec:usrec1)
640 DF*rtehed    if   e           k disk
     Fttlog     if   e           k disk
     Fttrte     uf a e           k disk
710aAFtttrain   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $uparm          ds
     D  $ucmd                  1      8
     D  $uprg                  9     18
     D  $uuky                 19     68
     D  $urtn                 69     76
     D  $uerm                 77    136
     D  $umsg                 77     80
     *
     *   Redefine key
     *
     D  $uusr                 19     28
SFGaAD  $ucrew                29     34
     *
     D $wparm          ds
     D  $wcmd                  1      8
     D  $wprg                  9     18
     D  $wuky                 19     68
     D  $wrtn                 69     76
     D  $werm                 77    136
     D  $wmsg                 77     80
     *
     *   Redefine key
     *
     D  $wwhse                19     21  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem#                1     15
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#citylin
SFGaA /COPY QCOPYSRC,Id#sgc
KFSaA /COPY QCOPYSRC,Id#kfs
HALaA /COPY QCOPYSRC,Id#halsey

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
     *  Key definitions
     *----------------------------------------------------------------

710bDD*keyWhsRtid      ds
710bDD* kyWhse                             like(w1whse)
710bDD* kyRtid                             like(w1rtid)

     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D @plcmd          S              8
     D @plset          S              6
     D cmdtkn          s              1
     D e               s              2  0
     D erm             s             60
     D error           s              1
     D logflag         s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D sclear          s              1
     D warn            s              1
     D wkprtf          s             10
     D wkstyp          s              1
     D wkwhdp          s              5
     D wkwhse          s              3  0
     D work1a          s              1
650bAD w1usr#          s              5  0
     D w1whse          s              3  0
     D forevr          s               n
     *----------------------------------------------------------------
     *  Global Variables

     D gEmp#           s              5  0
     D gUser           s             10
     D gWhse           s              3  0

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.getempl

     *----------------------------------------------------------------
640 A*  File data data structure

640 AD rtehed        E ds
     *----------------------------------------------------------------
     *  Sub-procedure prototypes

     D VfyEmployee     pr
     D VfyRteId        pr
     D VfyDownLoad     pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRG    Program to send messages back to
     *      $WHSE   Warehouse
     *      $RTID   Route Id
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prg             10
     C                   parm                    $whse             3
     C                   parm                    $rtid             5
     C                   parm                    $rtncd            8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
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
     C                   eval      *inlr = *on
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
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010809
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
     *
     *  Get default values.
     *
     C                   exsr      zzdft1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get existing record.
     *
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
     C                   eval      $rtncd = '*EXIT   '
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
     C                   eval      $rtncd = '*CANCEL '
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
     *     Check input.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1

     C                   if        ovrrid = *off
     C                   exsr      zzupd1
     C                   else
     C                   exsr      scr02i
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
     C                   eval      $rtncd = '*EXIT   '
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $rtncd = '*CANCEL '
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        ovrrid = *on
     C                   exsr      zzupd1
     C                   exsr      scr01i
     C                   endif

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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   move      *on           forevr
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
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110 - Starting number
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
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
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
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
     *  Verify warehouse code.
     *
     C                   eval      $wcmd = '*VERIFY '
     C                   eval      $wprg = #prog
     C                   eval      $wwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $wparm
     C                   if        $wrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $werm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $wrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $wmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *

      /free

        // Verify route id

          erm = ' ';
        VfyRteId();
        if erm <> ' ';
          error = *on;
          *in28 = *on;
          *in08 = *on;
          errmsg = erm;
          exsr zm0105;
        endif;

        // Verify employee number

        VfyEmployee();
        if erm <> ' ';
          error = *on;
          *in29 = *on;
          *in09 = *on;
          errmsg = erm;
          exsr zm0105;
        endif;

710aA   // If not a Trax training route ...
730bD   // Verify download status, if already downloaded, do not allow driver change
730bM   // As of 730b allow driver change even if downloaded

710aA   chain (w1whse: w1rtid) tttrain;
710aA   if not %found;
          VfyDownload();
          if erm <> ' ';
            error = *on;
            *in29 = *on;
            *in09 = *on;
            errmsg = erm;
            exsr zm0105;
          endif;
710aA   endif;

        if error = *on;
          leavesr;
        endif;

         eval ovrrid = *off;
710bD     //chain %kds(keyWhsRtid) ttrte;
710bM     chain (w1whse: w1rtid) ttrte;
730aD    //if %found(ttrte) and w1usr <> ttrusr;
730aM    if %found(ttrte) and w1usr <> ttrusr and ttrusr <> *blanks;
          eval ovrrid = *on;
         endif;

      /end-free

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
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
     *     Warehouse
     *
     C                   when      row# = 07
     C                   eval      $wcmd = '*LOOKUP '
     C                   eval      $wprg = #prog
     C                   eval      $wwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $wparm
     C                   if        $wrtn = '*SELECT '
     C                   eval      w1whse = $wwhse
     C                   endif
     *
     *     User
     *
     C                   when      row# = 11
     C                   eval      $ucmd = '*LOOKUP '
     C                   eval      $uprg = #prog
     C                   eval      $uusr  = w1usr
SFGaAc                   eval      $ucrew = ' '
SFGaAC                   if        client = sgc
KFSaAc                             or client = Kellys
HALaAc                             or client = Halsey
SFGaAc                   eval      $ucrew = 'DRIVER'
SFGaAc                   endif
     C                   call      'US900'
     C                   parm                    $uparm
     C                   if        $urtn = '*SELECT '
     C                   eval      w1usr  = $uusr
     C                   endif
     C                   eval      *in09 = *on
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F10 - Override
     *
     C                   if        *inkj
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values.
     *
     C     zzdft1        begsr
     C                   eval      w1whse = %dec($whse:3:0)
     C                   eval      w1rtid = $rtid
     C                   eval      w1usr   = ' '

     *   If this pgm is called from one of the following pgms,
     *   pos curs at Driver, otherwise, pos curs at Route Id.
     C                   if           $prg = 'RH120A'
     C                             or $prg = 'RH130A'
     C                             or $prg = 'RH140A'
     C                             or $prg = 'RH150A'
     C                             or $prg = 'RH160A'
     C                             or $prg = 'RH220A'
     C                             or $prg = 'RH230A'
     C                             or $prg = 'RH240A'
     C                             or $prg = 'RH250A'
     C                             or $prg = 'RH260A'
     C                   eval      *in09 = *on
     C                   else
     C                   eval      *in08 = *on
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr

     C     ttrusr        chain     piruser
     C                   if        not %found(piruser)
     C                   eval      usfnam = ' '
     C                   eval      uslnam = ' '
     C                   endif

     C                   eval      wousr = 'Driver '
     C                                   + %trim(ttrusr)
     C                                   + ' '
     C                                   + %trim(usfnam)
     C                                   + ' '
     C                                   + %trim(uslnam)

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

     C                   eval      $rtncd = '*OK     '

     C                   eval      $pstr  = 'Trax - Assign Driver +
     C                                       to Route'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr

     *    TTRTE file

     C     keyttrte1     klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid

     *      Get warehouse for user if not passed in.

     C                   if        w1whse = 0
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     *
     *  Get current date & time
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     *  Update or write TTRTE record with driver assigned to route.
     *
     *  If updating TTRTE rec and the xml file has been written but
     *  not downloaded, call TR810 to rebuild the xml file since it
     *  has now been assigned a different driver.
700aA*  Also call TR811 which creates Trax(c) version 1.3.
     *
     C     keyttrte1     chain(e)  ttrte
640 AC                   eval      ttrrte = rhrte
640 AC                   eval      ttrtru = rhtruk
     C                   if        not %found(ttrte)
     C                   eval      ttrwhs = w1whse
     C                   eval      ttrrti = w1rtid
     C                   eval      ttrusr = w1usr
     C                   eval      ttrstd = $cvd8o
     C                   time                    ttrstt
     C                   write     ttrrec
     C                   else
     C                   eval      ttrusr = w1usr
     C                   eval      ttrstd = $cvd8o
     C                   time                    ttrstt
     C                   update    ttrrec
     *  Rebuild xml file if built but not yet downloaded
     C                   if        logflag = *on
     C                   eval      $emp = %char(gemp#)
     C                   call      'TR810'
     C                   parm                    gwhse
     C                   parm                    w1rtid            5
     C                   parm                    $emp              5
     C                   parm      ' '           $filsn           30
     C                   parm      ' '           $rtn              8
     C                   parm      ' '           $erm             60
     *
700aAC                   call      'TR811'
700aAC                   parm                    gwhse
700aAC                   parm                    w1rtid            5
700aAC                   parm                    $emp              5
700aAC                   parm      ' '           $filsn           30
700aAC                   parm      ' '           $rtn              8
700aAC                   parm      ' '           $erm             60
     *
     C                   endif
     *
     C                   endif
     *
     C                   exsr      zzdft1
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *  VfyEmployee  Verify employee number
     *----------------------------------------------------------------

     p VfyEmployee     b
     d VfyEmployee     pi

     * Local variables

     d e$whse          s              3  0
     d e$user          s             10
     d e$fnam          s             15
     d e$init          s              1
     d e$lnam          s             20
     d e$whdp          s              5
     d e$styp          s              1
     d e$shft          s              6
     d e$crew          s              6
     d e$nhrs          s              3  1
     d e$rtn           s              8
     d e$bpu           s              1
     d e$lng           s              2

      /free

         // Get employee info

         eval usemp# = 0;
          chain (w1usr) piruser;
650bA     if %found(piruser);
            eval gemp# = usemp#;
650bA     else;
650dA       if w1usr >= '1' and w1usr <= '99999';
650bA         w1usr# = %dec(w1usr:5:0);
650bA         chain (w1usr#) piruser1;
650bA         if %found(piruser1);
650bA           gemp# = usemp#;
650bA           w1usr = uscode;
650bA         endif;
650dA       endif;
650bA     endif;

         monitor;
           getEmpl(gEmp#: gWhse: gUser: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                   e$bpu: e$lng);
         on-error;
           erm   = '(TR850) Error calling getEmpl';
           return;
         endmon;

         if e$rtn = '*ERROR';
           erm   = '(TR850) User not found for emp#';
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyRteId   Verify route id
     *----------------------------------------------------------------

     p VfyRteId        b
     d VfyRteId        pi

     * Local variables

     d  rteStatus      s              1

      /free

         // Verify route exists in RTEHED file

640 D  //exec sql select rhstat
640 D  //       into  :rteStatus
640 M    exec sql select * into :rtehed
                from rtehed
                where rhwhse = :w1whse and rhrtid = :w1rtid;
         If sqlstt <> sqlSuccess;
           erm   = '(TR850) Route not found ('
                    + %trim(w1rtid) + ')';
           return;
         endif;

       return;
      /end-free

     p VfyRteId        e

     *----------------------------------------------------------------
     *  VfyDownload   Verify download status
     *----------------------------------------------------------------

     p VfyDownload     b
     d VfyDownload     pi

     * Local variables

     d  forever        s               n   inz(*on)

      /free

         // Verify route has not been downloaded

         // Set logflag on if file built but not downloaded
         // Set logflag off if file already downloaded

710bD    //kyWhse = w1whse;
710bD    //kyRtid = w1rtid;
         ttlStatus = ' ';

710bD     //setll %kds(keyWhsRtid) ttlog;
710bM     setll (w1whse: w1rtid) ttlog;
          dow forever = forever;
710bD       //reade %kds(keyWhsRtid) ttlog;
710bM       reade (w1whse: w1rtid) ttlog;
            if %eof;
              leave;
            endif;
            if ttlStatus <> '3'
             and ttlStatus <> '4';
              logflag = *on;
              iter;
            endif;
            if ttlStatus = '3'
             or ttlStatus = '4';
              leave;
           endif;
         enddo;

         If ttlStatus = '3'
            or ttlStatus = '4';
             logflag = *off;
730bD    //erm   = '(TR850) Route already downloaded ('
730bD    //         + %trim(w1rtid) + ')';
           return;
         endif;

       return;
      /end-free

     p VfyDownload     e

     *----------------------------------------------------------------*********
