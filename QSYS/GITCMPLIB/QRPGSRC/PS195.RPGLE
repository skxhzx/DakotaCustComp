     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PS195     View Pallet Information - Options RF
     *  10 October 2018
     *  Ginger Andrews
     *
     *  Revisions
     *
     *    10/10/18  GJA  7.20
     *      - Created.                                                d
     *
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
     *  File Specs
     *
     Fps195fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fpltsum15  if   e           k disk
     Fpiruser1  if   e           k disk
     Fpirtran   if   e           k disk
     Frtehed    if   e           k disk
     Fpiritem   if   e           k disk
     Flabel7    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
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
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
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
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
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
     *
     D $cmd            s              8
     D $msgf           s             10
     D $name           s             40
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D ChkLgth         s             12
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D first           s               n
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D Pos             s              2  0
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svitem          s             15
     D warn            s              1
     D rte#            s              5
     D plt#            s              7  0
     D client          s             10
     D clientloc       s             10
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
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
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr=*on
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
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '02 '
     C                   write     cmdrec
     C                   eval      *in01 = *on
     C                   z-add     1             recno
     C                   write     dspsfc
     C                   read      dspsfc
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
     C                   eval      redspl = *off
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
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  The after update redisplay screen. The only way out is F3.
     *
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   exsr      sflclr
     C                   exsr      scr01i
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
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       //Initialize special keys

       eval enter = 0;
       eval comand = 2;
       eval rollup = 01122;
       eval rolldn = 01123;
       eval clear = 01124;
       eval help = 01125;

       //Initialize message handling

       exsr zmimsg;

       // Call user added initialization routine.

       exsr zzinz;
       endsr;
      /end-free
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
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
     C                   endif
     C                   endif
     *
     *  PalletId can't be blank.
     *
     C                   if        w1plt = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0203
     C                   endif
     *  ErrTxt = 'Invalid pallet ID';
      /free
          //Verify Pallet Id Length
            If Error = *Off and W1plt <> *blanks;
              chklgth = W1Plt;
              pos = %scan(' ':chklgth);
              pos = pos - 1;
              Select;
                When Pos = 10;
                  rte# = %subst(W1Plt:1:5);
                  plt# = %dec(%subst(W1Plt:6:5):5:0);
                Other;
                  Error = *On;
              endsl;

              chain(n)(w1Whse: Rte#: plt#) pltsum15;
              if %found(pltsum15) and pstrn# <> 0;
                w1plid = %TrimL(%editc(psplid:'P'));
                W1Rtid = psrtid;
                w1Plno = %TrimL(%editc(pspal#:'P'));
                chain(n)(pstrn#) pirtran;
                if %found(pirtran);
                  chain(n)(ptemp#) piruser1;
                  if %found(piruser1);
                    $cmd = '*LFM    ';
                    $name = *blanks;
                    frmtnm($cmd: usfnam: usinit: uslnam: $name);
                    w1slt = $name;
                  else;
                    w1slt = *blanks;
                  endif;
                else;
                  w1slt = *blanks;
                endif;
              else;
                w1opcs = *zeros;
                w1spcs = *zeros;
                w1plid = *zeros;
                W1Rtid = *blanks;
                W1Plno = *zeros;
                Error = *On;
                *in22 = *on;
                *in02 = *on;
                errmsg = *blanks;
                errmsg = 'Pallet not found';
                exsr  zm0105;
              endif;

              chain(n)(w1Whse: Rte#) rtehed;
              if %found(rtehed);
                w1rte = %TrimL(rhrte);
              else;
                w1rte = *blanks;
              endif;

              endif;
      /end-free
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
     C                   eval      cmdtkn = *off
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     *
     *    - Get default warehouse department for user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     C                   Eval      *in02=*on
     C                   eval      w1rtid = ' '
     C                   eval      w1rte = ' '
     C                   eval      w1plid = ' '
     C                   eval      w1plno = ' '
     C                   eval      w1opcs = 0
     C                   eval      w1pcs = ' '
     C                   eval      w1spcs = 0
     C                   eval      w1slt = ' '
     C                   eval      w1plt = ' '
     C                   eval      w1qty = ' '
     C                   eval      w1pcs = ' '
     C                   eval      w1aqty = 0
     C                   eval      w1sqty = 0
     C                   eval      svitem = ' '
     C                   eval      recno = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
      /free
       begsr zzfil2;

       first = *on;
          //Check labels for shorts
       setll (pstrn#) label7;

       svitem = ' ';

       dow forevr = forevr;
         reade (pstrn#) label7;

         select;

         when %eof(label7) and svitem = ' ';
          //no shorts were found
           recno += 1;
           write dspsfl;
           w1item = 'No shorts';
           leave;

         when %eof(label7) and svitem <> ' ' and w1sqty <> 0;
           w1item = svitem;
           chain(n)(w1whse: svitem) piritem;
           if %found(piritem);
             w1desc = itdesc;
           endif;
           W1qty = %TrimL(%editc(w1sqty: 'Z')) + ' of ' +
                   %TrimL(%editc(w1aqty: 'Z'));
           recno += 1;
           write dspsfl;
           w1sqty = 0;
           w1aqty = 0;
           w1qty = ' ';
           leave;

         when %eof(label7) and svitem <> ' ' and w1sqty = 0
              and recno <> 0;
           leave;

         when %eof(label7) and recno = 0;
          //no shorts were found and only one label
           recno += 1;
           w1item = 'No shorts';
           write dspsfl;
           leave;

         endsl;

         if svitem <> lbitem and svitem <> ' ' and w1sqty = 0;
           w1aqty = 0;
         endif;

         if svitem <> lbitem and svitem <> ' ' and w1sqty > 0;
           w1item = svitem;
           chain(n)(w1whse: svitem) piritem;
           if %found(piritem);
             w1desc = itdesc;
           endif;
           W1qty = %TrimL(%editc(w1sqty: 'Z')) + ' of ' +
                   %TrimL(%editc(w1aqty: 'Z'));
           recno += 1;
           write dspsfl;
           w1sqty = 0;
           w1aqty = 0;
           w1qty = ' ';
         endif;

         if lbqpck < lbqalc;
           w1sqty +=(lbqalc-lbqpck);
         endif;

         w1aqty +=lbqalc;
         svitem = lbitem;
         w1opcs += lbqalc;
         w1spcs += lbqpck;

       enddo;

       W1pcs = %TrimL(%editc(w1opcs: 'Z')) + '/' +
               %TrimL(%editc(w1spcs: 'Z'));

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get employee options.
     *
     C                   call      'GETUSER'
     C                   parm      #user         e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        e$rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     C                   eval      worow = 0
     C                   eval      wocol = 0
     *
     *   Select first screen to display.
     *
     C                   eval      refrsh = *on
     **                   MOVE *ON       *IN02
     C                   eval      w1plt = *blanks
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     C                   exsr      scr02i
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   write     dspsfc
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
**
Pallet
Slot
