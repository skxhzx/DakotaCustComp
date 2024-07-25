     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EQ610     Equipment - Yard Status - Display
     *  10 February 2004
     *  Max Blacknik
     *
     *  SK110 - 1.01
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    02/10/04  MLB  4.17
     *      - Created.
417b *    04/29/04  RH   4.17b
     *      - Equip ID code increased from 6 to 8.
510a *    12/06/06  RH   5.10a
     *      - Enh: Remove BFCADR, no longer used.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Feq610fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fequip     if   e           k disk
     F                                     rename(eqrec:record)
     Fequip2    if   e           k disk
     F                                     rename(eqrec:record2)
     Fequipys   if   e           k disk
     Feq610a    if   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fworkopt   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a80             s              1    dim(80)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(3) ctdata perrcd(1)
     D ovr             s             80    dim(1) ctdata perrcd(1)
     D qry1            s             80    dim(6) ctdata perrcd(1)
     D cls1            s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $whsea                 1      3
417b D  $kcode                 4     11
417bDD* $kcode                 4      9
417b D* the following fields moved 2 postions because EQCODE increased
     D  $kdesc                12     41
     D  $ktype                42     47
     D  $kloc                 48     49
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  eqwhse                 1      3  0 inz(0)
417b D* eqcode                 4      9
417b D  eqcode                 4     11
417b D* the following fields moved 2 postions because EQCODE increased
     D  eqdesc                12     41
     D  eqtype                42     47
     D  esloc                 48     49
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *
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
     D  $lcode                22     27
     D  $ltype                28     33
     *
     *----------------------------------------------------------------
     * Data structure
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('EQ612')
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
     *----------------------------------------------------------------
     *  Equipment types
     *
     D type01          c                   const('TRACTR')
     D type02          c                   const('TRAILR')
     D type03          c                   const('TRUCKS')
     *----------------------------------------------------------------
     *  Status codes
     *
     D sts01           c                   const('Yard')
     D sts01t          c                   const('I')
     D sts02           c                   const('Dock')
     D sts02t          c                   const('D')
     D sts03           c                   const('Loaded')
     D sts03t          c                   const('L')
     D sts04           c                   const('Out')
     D sts04t          c                   const('O')
     D sts05           c                   const('Out of service')
     D sts05t          c                   const('N')
     D sts06           c                   const('Unknown')
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
     D  $pwhse                19     21  0
     D  $pcode                22     27
     D  $ptype                28     33
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *
     *----------------------------------------------------------------
     *  Working variables.
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              3  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D first           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              3  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
     D nr              s              3  0
     D nxtscr          s              3
     D open1           s              1
     D otaken          s              1
     D ovrtyp          s              8
     D p               s              3  0
     D pagcmd          s              8
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D view            s              8
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Error Message(s)
     *
     D err01           c                   const('1=Select can only be-
     D                                      used once.')
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
     *  Parameters
     *
     *    Input Parameters
     *      *None
     *
     *    Returned Parameters
     *      *None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
510aDC*                  call      'BFCADR'
510aDC*                  parm                    $rtn              8
     *
510aDC*                  if        $rtn = '*EXPIRED'
510aDC*                  eval      nxtscr = 'EOJ'
     *
510aDC*                  else
     C                   exsr      zzinz2
     *
510aDC*                  endif
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
     C                   exsr      clrsch
     *
     C                   eval      *inlr = *on
     *
     C                   return
     *
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       klki
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     *
     C                   select
     C                   when      view = '*CODE   '
     C                   read      postnrec                               50
     *
     C                   when      view = '*TYPDESC'
     C                   read      postnrc2                               50
     *
     C                   when      view = '*TYPSTAT'
     C                   read      postnrc3                               50
     *
     C                   endsl
     *
     C                   when      nxtscr = '02 '
     C                   exsr      deldsp
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       030405
     C                   setoff                                       131415
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
     C                   read      dspsfc                                 50
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
     *
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
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
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
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
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
     *  Test For Cmd3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
     *
     *  Test For Cmd09 - Change view.
     *
     C                   if        *inki
     *
     C                   select
     C                   when      view = '*CODE   '
     *
     C                   eval      ovrtyp = '*TYPDESC'
     C                   eval      view   = '*TYPDESC'
     C                   eval      $ktype = type01
     *
     C                   when      view = '*TYPDESC'
     *
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*TYPSTAT'
     C                   eval      view   = '*TYPSTAT'
     C                   eval      $ktype = type01
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     *
     C                   when      view = '*TYPSTAT'
     *
     *    Process file override for OPNQRYF
     C                   eval      ovrtyp = '*CODE   '
     C                   eval      view   = '*CODE   '
     C                   eval      $ktype = ' '
     *
     C                   endsl
     *
     C                   select
     C                   when      view   = '*CODE   '
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   when      view   = '*TYPDESC'
     C                   eval      cmdln1 = cmdln(2)
     *
     C                   when      view   = '*TYPSTAT'
     C                   eval      cmdln1 = cmdln(3)
     *
     C                   endsl
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   exsr      pag01
     *
     C                   endif
     *
     *  Test for Cmd12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
     *
     *  Execute command keys that don't need the options verified.
     *
     *     Test for Cmd5 - Refresh
     *
     C                   if        *inke
     C                   exsr      clrsch
     *
     C     1             do        dsplyd        x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C                   enddo
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Verify and save any options that were entered.
     *
     C                   exsr      savopt
     C     error         cabeq     *on           cmd01e
     *
     *  Execute command keys that did need the options verified.
     *
     *  Test for Cmd6 - Add Record
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
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
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd10 - Move record taht cursor is on to Top
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Make sure cursor is on one of the displayed records.
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     Reposition record taht cursor is on to the top.
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd17 - Reposition to top of display.
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd18 - Reposition to bottom of display.
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
     C                   eval      nr = 10
     C                   add       1             nr
     C                   if        recno < nr
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
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
     C                   write     dspsfl
     *
     C                   endif
     *
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
     C                   write     dspsfc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  Verify and Save Options
     *
     C                   exsr      savopt
     C     error         cabeq     *on           ent01e
     *
     *  See if user is trying to position to a certain spot.
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     error         cabeq     *on           ent01e
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  If not positioning Then execute the entered options
     *
     C                   exsr      optns
     *
     *  If option was not taken Then return like Cmd12 was entered.
     *
     *R         OTAKEN    IFEQ *OFF
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   ENDIF
     *
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
     C                   dou       stop = *on
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
     C                   call      @delpg
     C                   parm                    $parms
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
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = *off
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
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
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
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
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
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
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
     *
     C                   eval      dsfkey = $pofky
     *
     C                   select
     C                   when      view = '*CODE   '
     C     fileky        setll     record
     *
     C                   when      view = '*TYPDESC'
     C     filky2        setll     record2
     *
     C                   when      view = '*TYPSTAT'
     C     filky3        setll     oqreca
     *
     C                   endsl
     *
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
     C                   dou       stop = *on  or
     C                             cancel = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = *off
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = *on
     C                   eval      stop = *on
     C                   if        error = *on
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
     C                   if        refrsh = *on
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
     *   Change
     *
     C                   select
     C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     *
     C                   other
     *   Process non-standard options.
     C                   exsr      zzopt
     *
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
     *R         CLERR     CABEQ*ON       PAG01E
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
     *R         CLERR     CABEQ*ON       PAG01E
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
     C     bot           cabeq     *on           endf
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
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     *
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 10
     C                   if        bot = *on
     C                   if        goback = 10
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
     C                   dou       stop = *on
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
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     *
     C                   exsr      pag1fw
     *
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf2
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
     C                   dou       stop = *on
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
     *  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = *on
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
     C     top           cabeq     *on           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 10
     C                   if        bot = *on
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
     *  READ FILE
     *
     C                   dou       stop = *on
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
     C                   if        top = *on
     C     wkoprt        setll     workopt
     C                   endif
     *
     C                   exsr      pag2fw
     *
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
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
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
     *  Read only the Changed Options
     *
     C                   eval      nomore = *off
     C                   dou       nomore = *on
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid.
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up Option in profile - Error if not found.
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
     *  Save Option.
     *
     C                   eval      y = recno
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     *
     C                   if        recno < 11
test C                   if        recno = 1
test C                   eval      $ktype = eqtype
test C                   endif
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     *
     C                   write     dspsfl
     C                   endif
     *
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
     C                   write     dspsfc
     *
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile , Item seq - Single line description.
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   select
     C                   when      view = '*CODE   '
     C                   write     postnrec
     *
     C                   when      view = '*TYPDESC'
     C                   write     postnrc2
     *
     C                   when      view = '*TYPSTAT'
     C                   write     postnrc3
     *
     C                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        dsplyd        x
     C     x             chain     dspsfl                             79
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
     C                   update    dspsfl
     *
     C                   endif
     C                   enddo
     *
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
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
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
     *
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
     *   EQ52003  Equipment type not valid.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'EQ52003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   EQ52004  Equipment status not valid.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'EQ52004'
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd = *on
     C                   eval      row# = 0
     C                   move      rowin         row
     C                   eval      col# = 0
     C                   move      colin         col
     *
     *     Retrieve list of valid warehouses.
     *
     C                   if        row#  = 4 and
     C                             col# >= 38
414dMC                   eval      *in03 = *On
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
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     filuky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
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
     C                   select
     *
     *    Yard status in Code sequence.
     C                   when      view = '*CODE   '
     C     partky        reade     record                                 79
     C                   if        not *in79
     *
     C                   select
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03  and
     C                             eqtype >  type03
     C                   eval      *in79 = *on
     C                   goto      endgtn
     C
     *
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   goto      try1
     C                   endsl
     *
     C     eskey         chain     equipys                            77
     C                   if        *in77
     C                   exsr      zzcles
     C                   endif
     C                   endif
     *
     *    Yard status in Type/Description sequence
     C                   when      view = '*TYPDESC'
     C     partky        reade     record2                                79
     C                   if        not *in79
     *
     C                   select
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03  and
     C                             eqtype >  type03
     C                   eval      *in79 = *on
     C                   goto      endgtn
     C
     *
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   goto      try1
     C                   endsl
     *
     C     eskey         chain     equipys                            77
     C                   if        *in77
     C                   exsr      zzcles
     C                   endif
     C                   endif
     *
     *    Yard status in Type/Status sequence
     C                   when      view = '*TYPSTAT'
     C     partky        reade     oqreca                                 79
     C                   if        not *in79
     *
     C                   select
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03  and
     C                             eqtype >  type03
     C                   eval      *in79 = *on
     C                   goto      endgtn
     C
     *
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   goto      try1
     C                   endsl
     *
     C     eskey         chain     equipys                            77
     C                   if        *in77
     C                   exsr      zzcles
     C                   endif
     C                   endif
     *
     C                   endsl
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
     C                   select
     *    Yard status in Code sequence
     C                   when      view = '*CODE   '
     C     partky        readpe    record                                 79
     *
     C                   if        not *in79
     *
     C                   select
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03  and
     C                             eqtype <  type01
     C                   eval      *in79 = *on
     C                   goto      endgtp
     C
     *
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   goto      try2
     C                   endsl
     *
     C     eskey         chain     equipys                            77
     C                   if        *in77
     C                   exsr      zzcles
     C                   endif
     C                   endif
     *
     *    Yard status in Type/Description sequence
     C                   when      view = '*TYPDESC'
     C     partky        readpe    record2                                79
     C                   if        not *in79
     *
     C                   select
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03  and
     C                             eqtype <  type01
     C                   eval      *in79 = *on
     C                   goto      endgtp
     C
     *
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   goto      try2
     C                   endsl
     *
     C     eskey         chain     equipys                            77
     C                   if        *in77
     C                   exsr      zzcles
     C                   endif
     C                   endif
     *
     *    Yard status in Type/Status sequence
     C                   when      view = '*TYPSTAT'
     C     partky        readpe    oqreca                                 79
     C                   if        not *in79
     *
     C                   select
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03  and
     C                             eqtype <  type01
     C                   eval      *in79 = *on
     C                   goto      endgtp
     C
     *
     C                   when      eqtype <> type01  and
     C                             eqtype <> type02  and
     C                             eqtype <> type03
     C                   goto      try2
     C                   endsl
     *
     C     eskey         chain     equipys                            77
     C                   if        *in77
     C                   exsr      zzcles
     C                   endif
     C                   endif
     *
     C                   endsl
     *
     C     endgtp        endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   select
     C                   when      esloc = '01'
     C                   eval      w1stat = sts01
     *
     C                   when      esloc = '02'
     C                   eval      w1stat = sts02
     *
     C                   when      esloc = '03'
     C                   eval      w1stat = sts03
     *
     C                   when      esloc = '04'
     C                   eval      w1stat = sts04
     *
     C                   when      esloc = '05'
     C                   eval      w1stat = sts05
     *
     C                   other
     C                   eval      w1stat = sts06
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
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
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    eqwhse
     C                   kfld                    eqcode
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    eqwhse
     C                   kfld                    eqcode
     *
     C     filky2        klist
     C                   kfld                    eqwhse
     C                   kfld                    eqtype
     C                   kfld                    eqdesc
     *
     C     filky3        klist
     C                   kfld                    eqwhse
     C                   kfld                    eqtype
     C                   kfld                    esloc
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     *
     *  Define partial key for Equip2 file (if needed).
     *
     C     prtky2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $ktype
     *
     *  Define partial key for EQ610A file (if needed).
     C     prtky3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $ktype
     *
     *  Define partial key for EQUIPYS file
     C     eskey         klist
     C                   kfld                    eqwhse
     C                   kfld                    eqcode
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      view = '*CODE   '
     *
     C                   eval      forevr = *off
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Initialize working variables.
     *
     C                   eval      open1 = *off
     C                   eval      first = *off
     C                   eval      ovrtyp = *blanks
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   move      #whse         $kwhse
     *
     *
     *   Get warehouse description.
     *
     C     $kwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCLES   Clear Equip Yard Status fields when record not found
     *
     C     zzcles        begsr
     *
     C                   eval      esio = *blanks
     C                   eval      esloc = *blanks
     C                   eval      esstat = *blanks
     C                   eval      esdoor = *zeros
     C                   eval      esrte = *blanks
     C                   eval      esrtid = *blanks
     C                   eval      esemp# = *zeros
     C                   eval      esuser = *blanks
     C                   move      *loval        essdts
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     *
     C     endopt        endsr
     *----------------------------------------------------------------
     *
     *  ZZOPN    Process file OPEN.
     *
     C     zzopn         begsr
     *
     *   Process file Open for P/O by item view.
     C                   select
     C                   when      ovrtyp = '*TYPSTAT'
     *
     C                   open      eq610a
     C                   eval      open1 = *on
     *
     C                   endsl
     *
     C     endopn        endsr
     *----------------------------------------------------------------
     *
     *  ZZOVR    Process file overrides.
     *
     C     zzovr         begsr
     *
     *   Process file override for Equipment by type/status
     C                   select
     C                   when      ovrtyp = '*TYPSTAT'
     *
     *      If query file already open then close it.
     *
     C                   eval      qcmd = cls1(1)
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd            256
     C                   parm      80            qlen             15 5
     *
     C                   if        open1 = *on
     C                   close     eq610a                               78
     C                   endif
     *
     *      Override database file.
     *
     *          OVRDBF FILE(EQ610A) TOFILE(EQUIP) SHARE(*YES)
     *
     C                   eval      qcmd = ovr(1)
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     C                   endsl
     *
     C     endovr        endsr
     *  --------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *      Verify warehouse entry.
     *
     C                   if        ptinp1 <> 0
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      eqwhse = ptinp1
     C                   eval      $kwhse = eqwhse
     C                   eval      eqcode = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = *zeros
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     C                   select
     C                   when      view = '*CODE   '
     *
     *  Position to Equipment code.
417b C*                  if        ptinp2 <> *blanks
417b C*                  eval      eqcode = ptinp2
417b C*                  eval      $kcode = ptinp2
417b C*                  eval      ptinp2 = *blanks
417b C                   if        ptinp8 <> *blanks
417b C                   eval      eqcode = ptinp8
417b C                   eval      $kcode = ptinp8
417b C                   eval      ptinp8 = *blanks
     C                   eval      repos  = *on
     C                   endif
     *
     *    List in Type/Description sequence.
     C                   when      view = '*TYPDESC'
     *
     *    Validate Equipment type entered.
     C                   if        ptinp2 <> type01  and
     C                             ptinp2 <> type02  and
     C                             ptinp2 <> type03  and
     C                             ptinp2 >  *blanks
     C                   eval      *in04 = *on
     C                   eval      *in14 = *on
     C                   eval      error = *on
     C                   movel     ptinp2        errmsg
     C                   exsr      zm2003
     C                   goto      endzps
     C                   endif
     *
     *  Position to Equipment type.
     C                   if        ptinp2 <> *blanks
     C                   eval      eqtype = ptinp2
     C                   eval      $ktype = ptinp2
     C                   eval      ptinp2 = *blanks
     C                   eval      eqdesc = *blanks
     C                   eval      $kdesc = *blanks
     C                   eval      repos  = *on
     C                   endif
     *
     *  Position to Equipment description.
     C                   if        ptinp3 <> *blanks
     C                   eval      eqdesc = ptinp3
     C                   eval      $kdesc = ptinp3
     C                   eval      ptinp3 = *blanks
     C                   eval      repos  = *on
     C                   endif
     *
     *    List in Type/Status sequence.
     C                   when      view = '*TYPSTAT'
     *
     *    Validate Equipment type entered.
     C                   if        ptinp2 <> type01  and
     C                             ptinp2 <> type02  and
     C                             ptinp2 <> type03  and
     C                             ptinp2 >  *blanks
     C                   eval      *in04 = *on
     C                   eval      *in14 = *on
     C                   eval      error = *on
     C                   movel     ptinp2        errmsg
     C                   exsr      zm2003
     C                   goto      endzps
     C                   endif
     *
     *  Position to Equipment type.
     C                   if        ptinp2 <> *blanks
     C                   eval      eqtype = ptinp2
     C                   eval      $ktype = ptinp2
     C                   eval      esloc  = *blanks
     C                   eval      $kloc  = *blanks
     C                   eval      ptinp2 = *blanks
     C                   eval      repos  = *on
     C                   endif
     *
     *    Validate Equipment status entered.
     C                   if        ptinp4 <> sts01t  and
     C                             ptinp4 <> sts02t  and
     C                             ptinp4 <> sts03t  and
     C                             ptinp4 <> sts04t  and
     C                             ptinp4 <> sts05t  and
     C                             ptinp4 >  *blanks
     C                   eval      *in05 = *on
     C                   eval      *in15 = *on
     C                   eval      error = *on
     C                   movel     ptinp4        errmsg
     C                   exsr      zm2004
     C                   goto      endzps
     C                   endif
     *
     *  Position to Equipment status.
     C                   if        ptinp4 <> *blanks
     *
     C                   select
     C                   when      ptinp4 = sts01t
     C                   eval      esloc = '01'
     C                   eval      $kloc = '01'
     *
     C                   when      ptinp4 = sts02t
     C                   eval      esloc = '02'
     C                   eval      $kloc = '02'
     *
     C                   when      ptinp4 = sts03t
     C                   eval      esloc = '03'
     C                   eval      $kloc = '03'
     *
     C                   when      ptinp4 = sts04t
     C                   eval      esloc = '04'
     C                   eval      $kloc = '04'
     *
     C                   when      ptinp4 = sts05t
     C                   eval      esloc = '05'
     C                   eval      $kloc = '05'
     *
     C                   other
     C                   eval      esloc = '  '
     C                   eval      $kloc = '  '
     *
     C                   endsl
     *
     C                   eval      ptinp4 = *blanks
     C                   eval      repos  = *on
     C                   endif
     *
     *    Refresh Query when position to changes.
     C                   if        repos = *on
     C                   exsr      zzovr
     *
     *    Process OPNQRYF.
     C                   exsr      zzqry
     C                   exsr      zzopn
     *
     C                   endif
     *
     C                   endsl
     *
     C     endzps        endsr
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
     C                   select
     *
     *    List display in Code sequence.
     C                   when      view = '*CODE   '
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     *
     *    List display in Type/Description sequence.
     C                   when      view = '*TYPDESC'
     *
     C                   if        $pocmd = '*TOP'
     C     prtky2        setll     record2
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     prtky2        setgt     record2
     C                   endif
     C                   endif
     *
     *    List display in Type/Status sequence.
     C                   when      view = '*TYPSTAT'
     *
     C                   if        $pocmd = '*TOP'
     C     prtky3        setll     oqreca
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     prtky3        setgt     oqreca
     C                   endif
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZQRY    Process OPNQRYF.
     *
     C     zzqry         begsr
     *
     *    Run OPNQRYF to select records.
     C                   select
     C                   when      ovrtyp = '*TYPSTAT'
     *
     *    Load QRYSLT selection values.
     C                   movea     qry1(2)       a80
     C                   movea     $whsea        a80(10)
TEST C***                movea     $ktype        a80(30)
TEST C***                movea     $kloc         a80(54)
     C                   movea     a80           qry1(2)
     *
     *    Build command string for query.
     C                   eval      qcmd = qry1(1)
     C     qcmd          cat       qry1(2):0     qcmd
     C     qcmd          cat       qry1(3):1     qcmd
     C     qcmd          cat       qry1(4):1     qcmd
     C     qcmd          cat       qry1(5):1     qcmd
     *
     C                   endsl
     *
     *    Process OPNQRYF to select records.
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      256           qlen
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 5
**  OPTLN - Option display line
  2=Change  5=View
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F9=Type/desc  F12=Cancel
F3=Exit  F4=Prompt  F5=Refresh  F9=Type/status  F12=Cancel
F3=Exit  F4=Prompt  F5=Refresh  F9=Code seq  F12=Cancel
**   OVRDBF statements
OVRDBF FILE(EQ610A) TOFILE(EQUIP) SHARE(*YES) LVLCHK(*NO)
**   OPNQRYF statements for EQ610A - whse/type/status
OPNQRYF FILE((EQUIP) (EQUIPYS)) FORMAT(EQ610A) QRYSLT('
EQWHSE = 999 ')
KEYFLD((1/EQWHSE) (1/EQTYPE) (2/ESLOC ))
JFLD((1/EQWHSE 2/ESWHSE *EQ) (1/EQCODE 2/ESCODE *EQ))
OPTIMIZE(*FIRSTIO) JDFTVAL(*YES) SEQONLY(*NO)
EQWHSE = 999 *AND EQTYPE >= "123456" *and esloc  >= "xx" ')
**   CLOF statement.
CLOF EQUIP
