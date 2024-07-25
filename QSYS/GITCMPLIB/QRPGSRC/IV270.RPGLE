500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV270     Inventory slot assignment - Aisle/slot
     *  10 June, 2007
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
510aA*    06/19/07  RH   5.10a
     *      - Add option side Odd/Even
510bA*    06/19/07  MLB  5.10b
     *      - Fix: Correct F4 prompt field mis-alignments.
520aA*    05/02/08  RH   5.20a
     *      - Enh: Get first slot found, don't verify slot is in scope.
     *        will allow from/to slot range even if slot entered is not
     *        found in scope.
520bA*    05/05/08  RH   5.20b
     *      - Fix: Do not display error when returning from F7 IV279.
520cA*    05/07/08  RH   5.20c
     *      - Enh: Write to IV270A work file, don't pass back parms.
     *        Will read file to asssign inventory slots in new program.
520cA*    05/08/08  RH   5.20d
     *      - Enh: add select Both pick and overflow slots. Create two
     *        records in work file, one for pick, one for overflow.
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
     Fiv270fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Finvslot4  if   e           k disk
     Finvsasn   if   e           k disk
     Finvteam   if   e           k disk
520c Fiv270a    uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(5) ctdata perrcd(1)
510a D*desc            s             60    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

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
     *  Called program parameters
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
     D  $pdisp                27     38
     D  $ppage                27     31  0 inz(0)
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
     D  $lpage                22     26  0
     D  $lwhdp                27     31
     D  $laisl                32     34
     *                                      54  58 $LDESG
     *                                      59  60 $LSTAT
     *                                      61  62 $LSDEF
     *                                      63  64 $LACTV
     *
510a D  $lwhde                22     26
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdate                 1      6  0
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
     D asle            s              3
     D cancel          s              1
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D fmpage          s              5  0
     D help            s              5  0
     D ikypag          s              5  0
     D ikywhd          s              5
     D ikywhs          s              3  0
     D msgk            s              4  0
     D nxtscr          s              3
     D pgctr           s                   like(ivgpag)
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s             12
     D topage          s              5  0
     D warn            s              1
     D wfpage          s              5  0
     D wodisp          s             12
     D woidte          s              8  0
     D wtpage          s              5  0
     *----------------------------------------------------------------
     *  Main line
     *
     c     *entry        plist
     c                   parm                    $whse             3
     c                   parm                    $rtn              8
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
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
510 AC                   eval      *inlr = *on
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
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtn = '*EXIT'
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtn = '*CANCEL'
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
     *  The after update redisplay screen. The only way out is F3
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
     *      0203  Value can not be blank
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
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
     *   PIR0203  Code must be entered.
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33001  No team defined for date.
     *
     C     zm3001        begsr
     C                   eval      #msgid = 'IV33001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33002  Slot not in inventory scope.
     *
     C     zm3002        begsr
     C                   eval      #msgid = 'IV33002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
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
     C**                 eval      *in02 = *on
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
     *  Date can not be blank
     *
     C                   if        w1idte = *zeros
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0203
     C                   endif
     *
     *  Verify Date.
     *
     C                   move      '*MDYEDT '    $cvcmd
     C                   move      w1idte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $cverm        #msgk
     C                   exsr      zm0105
     C                   move      w1idte        erdate
     C                   exsr      zm9906
     C                   else
     C                   move      $cvd6o        w1idte
     *  Convert date and save.
     C                   move      '*MDYCMD '    $cvcmd
     C                   move      w1idte        $cvd6i
     C*                  eval      $cvd6i = w1idte
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        woidte
     C                   endif
     C                   endif
     *
     *    Make sure Team was entered.
     *
     C                   if        w1team = *blanks
     C                   eval      error = *on
     C                   eval      *in07 = *on
     C                   eval      *in27 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm03
     C                   endif
     *
     *  Verify team.
     C                   if        not *in22
     C     vtkey         setll     invteam
     C     vtkey         reade     invteam                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm3001
     C                   endif
     C                   endif
     *
     *  Warehouse department can not be blank
     *
     C                   if        w1whdp = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0203
     C                   endif
     *
     *  Verify warehouse department.
     C                   if        w1whdp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhde = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
415a *  Verify P=pick or O=overflow
415a C                   if        w1pick <> 'P'  and
415a C                             w1pick <> 'O'  and
520d C                             w1pick <> 'B'
415a C                   eval      error = *on
415a C                   eval      *in23 = *on
415a C                   eval      *in03 = *on
415a C                   eval      errmsg = *blanks
415a C                   movel     desc(4)       errmsg
415a C                   exsr      zm1001
415a C                   endif
416b *
510a *  Verify E=even or O=odd
510a C                   if        w1even <> 'E'  and
510a C                             w1even <> 'O'
510a C                   eval      error = *on
510a C                   eval      *in27 = *on
510a C                   eval      *in07 = *on
510a C                   eval      errmsg = *blanks
510a C                   movel     desc(5)       errmsg
510a C                   exsr      zm1001
510a C                   endif
510a *
     *
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     *
510a *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F7 - Un assigned inv assignment slots.
     *
     C                   if        *inkg
520b C                   eval      cmdtkn = *on
     C                   eval      $lwhse = w1whse
     C                   call      'IV279'
     C                   parm                    $lparm
520b C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
520b C                   endif
     *
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
     *     Warehouse.
     *
510cDC*                  when      row# = 7
510cMC                   when      rcdfmt = 'SCREEN1'
510cAC                             and rcdfld = 'W1WHSE'
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
510a *     Department
     *
510cDC*                  when      row# = 13
510cMC                   when      rcdfmt = 'SCREEN1'
510cAC                             and rcdfld = 'W1WHDP'
510a C                   eval      *in04 = *on
510a C                   eval      $lcmd = '*LOOKUP '
510a C                   eval      $lwhse = w1whse
510a C                   eval      $lwhde = w1whdp
510a C                   call      'WD900'
510a C                   parm                    $lparm
510a C                   if        $lrtn = '*SELECT '
510a C                   eval      w1whdp = $lwhde
510a C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1whdp =  *blanks
     C*                  eval      w1asle =  *blanks
     C                   eval      w1fdsp =  *blanks
     C                   eval      w1tdsp =  *blanks
510a C                   eval      w1pick =  *blanks
510a C                   eval      w1even =  *blanks
     C*                  eval      w1team =  *blanks
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     *
     *
     *  Define key for INVPAGE file.
     *
     C     ipkey         klist
     C                   kfld                    ikywhs
     C                   kfld                    ikypag
     *
     *  Define key for INVPASN2 file.
     *
     C     pgkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    pgctr
510a *
510a *  Define key for INVSLOT4 file.
510a *
510a C     slkey         klist
510a C                   kfld                    w1whse
510a C                   kfld                    w1whdp
510a C                   kfld                    wodisp
     *
     *  Define partial key for INVTEAM file.
     *
     C     vtkey         klist
     C                   kfld                    w1whse
     C                   kfld                    woidte
     C                   kfld                    w1team
     *
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *   Initialize inventory date/team one time only
     C                   eval      w1idte =  *zeros
     C                   eval      w1team =  *blanks
     *
     *   Select first screen to display.
     *
     C                   eval      *in01 = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
520d C                   if        w1pick = 'B'
520dACSR                 eval      ivvpck = 'P'
520dACSR                 else
520dACSR                 eval      ivvpck = w1pick
520dACSR                 endif
417a CSR                 move      w1whse        ivvwhs
417a CSR                 move      $cvd8o        ivvidt
417aAC**                 eval      $ctdt = $cvd8O
417aACSR                 eval      ivvtem = w1team
417aACSR                 eval      ivvwhd = w1whdp
520dDC***                eval      ivvpck = w1pick
510a C                   if        w1even = 'E'
510aACSR                 eval      ivvevn = 0
510aACSR                 else
510aACSR                 eval      ivvevn =  1
510aACSR                 endif
417aACSR                 eval      ivvfsl = w1fdsp
417aACSR                 eval      ivvtsl = w1tdsp
     CSR                 eval      ivvsts = '1'
     C                   write     ivvrec
520dAC                   if        w1pick = 'B'
520dACSR                 eval      ivvpck = 'O'
520dAC                   write     ivvrec
520dACSR                 endif
     C                   eval      error = *off
     C                   exsr      scr01i
520 DC*                  eval      nxtscr = 'EOJ'
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Sheet number
Dept / Slot
Team
Pick/Overflow
Side Odd/Even
