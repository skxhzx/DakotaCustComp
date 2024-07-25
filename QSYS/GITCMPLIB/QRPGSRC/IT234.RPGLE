      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*CAller)
500aA*----------------------------------------------------------------
500aA*  Multilingual Verision
500aA*  Every screen and message has a corresponding Spanish version.
500aA*  Any changes must be made to both languages.
500aA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT234     RF Item and Linked item pick slots - Display
     *  21 April, 1997
     *  Roxanne Harrison
     *
     *  Notes
650 A*    07/24/13  RH   6.50
     *       Created using IT231
     *       8 X 20 Screens for hand held scanners
     *       Screen uses only Optrec & Sfl, no room for other records.
     *
     *  Revisions
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  60        F10=Specific active. Called from LT105.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fit234fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(d16sflsp:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fworkopt   uf a e           k disk
     Fit234     if   e           k disk
     F                                     rename(wkrec:record)
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     *
     Fslot2     if   e           k disk
     F                                     rename(slrec:recordu)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(14)
     D ukey            s             50    dim(14)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(2) ctdata perrcd(1)
     D bmsg            s             20    dim(1) ctdata perrcd(1)
     D bmsgsp          s             20    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $whse                  1      3  0
     D  $item                  4     18
     D  $lalwc                47     47
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  itwhse                 1      3  0 inz(0)
     D  ititem                 4     18
     D  ilitem                19     33
     D  slstat                34     35
     D  slpick                36     36
     D  slprty                37     37  0 inz(0)
     D  slexpd                38     45  0 inz(0)
     D  slentd                46     53  0 inz(0)
     D  slwhdp                54     58
     D  slstyp                59     59
     D  slaisl                60     62
     D  slpseq                63     67  0 inz(0)
     D  slrlvl                68     69  0 inz(0)
     D  slhand                70     71
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     D  ukitem                21     35
     *----------------------------------------------------------------
     *  Redefinition data structure
     *
     D                 ds
     D  option                 1      2
     D  opt1                   2      2
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
     D @chgpg          c                   const('NONE')
     D @vewpg          c                   const('NONE')
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
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
     D  $pitem                39     53
     D  $palwc                54     54
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0 inz(0)
     D  $cvd8o                39     46  0 inz(0)
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
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
     D #msgsp          c                   const('PIRMSGFSP ')
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
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #otype          s              1
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D cmdln1          s             79
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D maxval          s              3  0
     D moreln          s              7
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D warn            s              1
     D wobase          s             20
     D wowhse          s             35
     D w1item          s             15
     D x               s              3  0
     D y               s              3  0
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
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   exsr      zzinz2
     C                   eval      $rtncd = *blanks
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
     C                   exsr      clrsch
     c                   eval      *inlr = *on
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     titlesp
     C                   other
     C                   write     title
     C                   endsl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
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
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   read      d16sfcsp                               50
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   read      d16sfc                                 50
     *
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   read      dspsfcsp                               50
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   read      dspsfc                                 50
     C                   endsl
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     C                   if        cancel = *off
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = frstky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
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
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
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
     *  Initialize subfile (DSPSFL) record
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR F5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C                   select
     C                   when      #lline = '16'
     C                   eval      maxval = 12
     C                   other
     C                   eval      maxval = 4
     C                   endsl
     *R
     C     1             do        maxval        x
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
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
     *  TEST FOR F6 - ADD RECORD
     *
     C                   if        *inkf
     C                   eval      $pprg = #prog
     C                   eval      ukwhse = itwhse
     C                   eval      ukwhdp = itwhdp
     C                   eval      ukdisp = *blanks
     C                   eval      ukitem = ititem
     C                   eval      $puky = dsukey
     C                   eval      $pcmd = '*ADD    '
     C                   if        @chgpg <> 'NONE'
     C                   call      @chgpg
     C                   parm                    $parms
     C                   endif
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*EXIT   '  and
     C                             $prtn <> '*CANCEL '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F10 - User chose to continue to Specific slot replen.
     *
     C                   if        *inkj
     *
     C                   eval      $rtncd = '*SSR    '
     C                   eval      nxtscr = 'EOJ'
     *
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     dspsflsp
     C                   other
     C                   write     dspsfl
     C                   endsl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      e$lng = 'SP'
     C                   write     dspsfcsp
     C                   other
     C                   write     dspsfc
     C                   endsl
     C                   endsr
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
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   if        @delpg <> 'NONE'
     C                   call      @delpg
     C                   parm                    $parms
     C                   endif
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     C                   select
     *
     *   Change
     *
     C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   if        @chgpg <> 'NONE'
     C                   call      @chgpg
     C                   parm                    $parms
     C                   endif
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   eval      $palwc = $lalwc
     C                   if        @vewpg <> 'NONE'
     C                   call      @vewpg
     C                   parm                    $parms
     C                   endif
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   if        @prtpg <> 'NONE'
     C                   call      @prtpg
     C                   parm                    $parms
     C                   endif
     *
     *   View slot quantities.
     *
     C                   when      wkoopt = ' 9'
     C                   call      'SL810'
     C                   parm                    itwhse
     C                   parm                    itwhdp
     C                   parm                    $pdisp
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 4  and
     C                             #lline <> '16'  or
     *
     C                             p >= 12  and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfwd        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   select
     C                   when      #lline <> '16'
     C     dsplyd        add       4             goback
     C                   other
     C     dsplyd        add       12            goback
     C                   endsl
     C                   if        bot = '1'
     C                   if        goback = 4  and
     C                             #lline <> '16'  or
     C                             goback = 12  and
     C                             #lline = '16'
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     **         P         IFGE 10
     C                   if        p >= 5
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     *R         DSPLYD    ADD  10        GOBACK  20
     C     dsplyd        add       5             goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   readc     d16sflsp                               79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   readc     d16sfl                                 79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   readc     dspsflsp                               79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   readc     dspsfl                                 79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        recno < 7  and
     C                             #lline <> '16'  or
     C                             recno < 15  and
     C                             #lline = '16'
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfl
     C                   endsl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl
     C                   eval      recno = 0
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
     C                   select
     C                   when      #lline = '16'
     C                   write     c16rec
     C                   other
     C                   write     cmdrec
     C                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     1             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     1             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     1             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     1             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   write     d16sfcsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   write     dspsfcsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C                   if        #lline = '16'
     C                   eval      maxval = 12
     C                   else
     C                   eval      maxval = 4
     C                   endif
     **
     C     1             do        maxval        x
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C     x             chain     d16sflsp                           79
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C     x             chain     dspsflsp                           79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'SP'
     C                   update    d16sflsp
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'SP'
     C                   update    dspsflsp
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   select
     C                   when      #lline = '16'
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   select
     C                   when      #lline = '16'
     *                    WRITECLRSCR
     C                   other
     *R                   WRITECLRSCR
     C                   endsl
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *R         FILUKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain     recordu                            79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'
     C     partky        reade     record                                 79
     C                   else
     C     partkb        reade     record                                 79
     C                   endif
     C     *in79         cabeq     *on           endgtn
     C                   if        slpick <> 'Y '
     C                   goto      try1
     C                   endif
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'
     C     partky        readpe    record                                 79
     C                   else
     C     partkb        readpe    record                                 79
     C                   endif
     C     *in79         cabeq     *on           endgtp
     C                   if        slstat = 'Z '  and
     C                             slrsrv = 'N'
     C                   goto      try2
     C                   endif
     *
     C     endgtp        endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     c                   eval      w1item = ilitem
     C     itkey         chain     piritem                            79
     c                   if        %found(piritem)
     C                   eval      w1ityp = ittype
     c                   else
     C                   eval      w1ityp = ' '
     c                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukwhdp
     C                   kfld                    ukdisp
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     C                   kfld                    ilitem
     C                   kfld                    slstat
     C                   kfld                    slpick
     C                   kfld                    slprty
     C                   kfld                    slexpd
     C                   kfld                    slentd
     C                   kfld                    slwhdp
     C                   kfld                    slstyp
     C                   kfld                    slaisl
     C                   kfld                    slpseq
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $whse
     C                   kfld                    $item
     *
     *  Define partial key for main file (if needed) using Base item.
     *
     C     partkb        klist
     C                   kfld                    $whse
     C                   kfld                    #sitem
     *
     *  Define key for item file.
     *
     C     itkey         klist
     C                   kfld                    $whse
     C                   kfld                    ilitem
     *
     *  Define key for warehouse department.
     *
     C     wdkey         klist
     C                   kfld                    $whse
     C                   kfld                    itwhdp
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
    A*
    A*   Get employee options.
    A*
    AC                   call      'GETUSER'
    AC                   parm      #user         e$code           10
     C                   parm                    e$whse            3 0
    AC                   parm                    e$emp#            5 0
    AC                   parm                    e$fnam           15
    AC                   parm                    e$init            1
    AC                   parm                    e$lnam           20
    AC                   parm                    e$whdp            5
    AC                   parm                    e$styp            1
    AC                   parm                    e$shft            6
    AC                   parm                    e$crew            6
    AC                   parm                    e$nhrs            3 1
    AC                   parm                    e$rtn             8
    AC                   parm                    e$bpu             1
    AC                   parm                    e$lng             2
    AC                   if        e$rtn <> '*OK'
    AC                   eval      e$lng = 'EN'
    AC                   endif
    A*
    A*   Get screen size being used.
    A*
    AC                   call      'PIRRFSCR'
    AC                   parm      '*GET'        #lcmd             8
    AC                   parm                    #lline            2
    AC                   parm                    #lcol             3
    A*
    A*  Initialize subfile (DSPSFL) record
    A*
    AC                   eval      recno = 1
    AC                   select
    AC                   when      #lline = '16'  and
    AC                             e$lng = 'SP'
    AC                   write     d16sflsp                             79
    AC                   when      #lline = '16'  and
    AC                             e$lng = 'EN'
    AC                   write     d16sfl                               79
    AC                   when      #lline <> '16'  and
    AC                             e$lng = 'SP'
    AC                   write     dspsflsp                             79
    AC                   when      #lline <> '16'  and
    AC                             e$lng = 'EN'
    AC                   write     dspsfl                               79
    AC                   endsl
500 A*
500 A*  Initialize subfile (DSPSFL) record
500 A*
    AC                   if        $rtncd = 'LT105   '
    AC                   eval      *in60 = *on
    AC                   eval      $rtncd = *blanks
    AC                   eval      cmdln1 = cmdln(2)
    AC                   else
    AC                   eval      *in60 = *off
    AC                   endif
     *
    D**                   MOVE *BLANKS   WOBASE
    AC                   eval      wobase = *blanks
     *
     *   Get item description.
     *
     C*                  eval      w1item = *blanks
     C*                  eval      w1ityp = *blanks
     C*                  eval      w1item = $item
     C**   $item         cat       '-':1         w1item
     C     itkey         chain     piritem                            79
     C                   select
     C                   when      not *in79
     C**   w1item        cat       itdesc:1      w1item
     C                   eval      w1ityp = ittype
     C                   if        ittype = ' '
     C                   eval      w1ityp = 'N'
     C                   endif
     *
     C                   eval      wowhse = *blanks
     C     $whse         chain     warehs                             79
     C                   if        not *in79
     C                   eval      $cstr = *blanks
     C                   move      whcode        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     C     wowhse        cat       '-':1         wowhse
     C     wowhse        cat       whdesc:1      wowhse
     C                   endif
     *
    A*
    A*     Save information about selected item (Item that was sent in)
    A*
    AC                   eval      #otype = ittype
    AC                   eval      #oitem = ititem
    AC                   eval      #odesc = itdesc
    AC                   eval      #opdsc = itpdsc
    A*
    A*      Initialize base information.
    A*
    AC                   eval      #bitem = ititem
    AC                   eval      #sitem = ititem
    AC                   eval      #bityp = ittype
    AC                   eval      #bdesc = itdesc
    AC                   eval      #bpdsc = itpdsc
    A*
    A*     If selected item is a Contract, Alias or SSB . . .
    A*       Then get corresponding Base item.
    A*
    AC                   if        ittype = 'C'  or
    AC                             ittype = 'A'  or
    AC                             ittype = 'S'
    AC                   select
    AC                   when      e$lng = 'SP'
    AC                   eval      wobase = bmsgsp(1)
    AC                   other
    AC                   eval      wobase = bmsg(1)
    AC                   endsl
    AC                   call      'GETBASE'
    AC                   parm      itwhse        $gwhse            3 0
    AC                   parm      ititem        $gitem           15
    AC                   parm      ' '           #bitem           15
    AC                   parm                    #bityp            1
    AC                   parm                    #bdesc           30
    AC                   parm                    #bpdsc           15
    AC                   parm                    #bwhdp            5
    AC                   parm                    #bstyp            1
    AC                   parm                    #bum1             2
    AC                   parm                    #bum2             2
    AC                   parm                    #bumq2            3 0
    AC                   parm                    #bum3             2
    AC                   parm                    #bumq3            3 0
    AC                   parm      ' '           #bcitm           15
    AC                   parm                    #bctyp            1
    AC                   parm                    #bcdsc           30
    AC                   parm                    #bcpds           15
    AC                   parm                    #bcwdp            5
    AC                   parm                    #bcstp            1
    AC                   parm                    #bcum1            2
    AC                   parm                    #bcum2            2
    AC                   parm                    #bcuq2            3 0
    AC                   parm                    #bcum3            2
    AC                   parm                    #bcuq3            3 0
    AC                   parm                    #brtn             8
    AC                   endif
    A*   Get slot item.
    AC                   call      @getsi
    AC                   parm      itwhse        $gwhse
    AC                   parm      ititem        $gitem
    AC                   parm      ' '           #sitem           15
    AC                   parm                    #sityp            1
    AC                   parm                    #sdesc           30
    AC                   parm                    #spdsc           15
    AC                   parm                    #srtn            10
    AC                   parm                    #smsg            60
     *
     C                   endsl
     *
     **                   MOVE $PRTKY    DSKEY
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
     C                   clear                   slwhse
     C                   clear                   slitem
     C                   clear                   slstat
     C                   clear                   slpick
     C                   clear                   slprty
     C                   clear                   slexpd
     C                   clear                   slentd
     C                   clear                   slwhdp
     C                   clear                   slstyp
     C                   clear                   slaisl
     C                   clear                   slpseq
     C                   clear                   slrlvl
     C                   clear                   slhand
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhdp
     C                   clear                   ukdisp
     C                   clear                   ukitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = slwhse
     C                   eval      ukwhdp = slwhdp
     C                   eval      ukdisp = sldisp
     C                   eval      ukitem = slitem
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     *R         PTINP1    IFNE 0
     *R                   Z-ADDPTINP1    ODDLIN
     *R                   Z-ADD0         PTINP1
     *R                   MOVE *ON       REPOS
     *R                   END
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
    AC                   if        #otype = ' '  or
    AC                             #otype = 'B'
     C     partky        setll     record
    AC                   else
    AC     partkb        setll     record
    AC                   endif
     C                   else
     C                   if        $pocmd = '*BOTTOM'
    AC                   if        #otype = ' '  or
    AC                             #otype = 'B'
     C     partky        setgt     record
    AC                   else
    AC     partkb        setgt     record
    AC                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F3=Exit  F12=Cancel
F3=Exit F10=Specific F12=Cancel
**
* Base Item Slots *
** BMSGSP
* Slots de producto de base *
