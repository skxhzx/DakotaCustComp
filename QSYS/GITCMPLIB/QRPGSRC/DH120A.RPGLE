     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')
     H   Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DH120A    Dock door maint by door/dept - Display
     *  05 November 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/05/01  DAS  4.16
     *      - Created.
     *
500 A*    09/19/05  MLB  5.00
     *      - Fix: Revised program to initialize pass # and dock door#.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Added Assignment Type to dock matrix file key to
     *        keep automatic assigned doors separate from manually
     *        assigned doors. This was done so that the next
     *        dock door to be assigned in the automatic sequence
     *        will always be correct even when a route is moved
     *        from one door to another.
     *      - Added position to field, PTINP5 for position to
     *        assign type field.
     *      - DSPF renamed to DH120A01 from DH120AFM.
     *
640aA*    04/27/12  JCJ  6.40a
     *      - Fix: Commented out read to OPTREC. Was not needed.      .
     *             Was causing a session error,                       .
     *
     *----------------------------------------------------------------
     *  Notes:
     *    - This program is not a standard subfile display program.
     *      Each subfile record has 5 option fields available. The
     *      FKEY,UKEY arrays only hold the route id for door(s) that
     *      the route is assigned to. Not the key values of  our
     *      standard subfile programs.
     *    - When the records are written into the work option file,
     *      there is one record written for each option selected in
     *      a subfile record. If opt1, opt3, opt4 each are filled with
     *      a valid option, one record would be written for each of the
     *      routes with the necessary key values needed to access the rcd.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  40        CONDITION IND - VIEW MODE 40=on - Pass/door seq.
     *                          - VIEW MODE 40=off- dept/pass seq.
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520 DF*dh120afm  cf   e             workstn
520 MFdh120a01  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fdocdoor   if   e           k disk
     Fdocdoor1  if   e           k disk
     F                                     rename(ddrec:ddrec1)
     Fdocmtrx   if   e           k disk
     F                                     rename(dmrec:record)
     Fdocmtrx1  if   e           k disk
     F                                     rename(dmrec:record1)
     Fdocmtrx3  if   e           k disk
     F                                     rename(dmrec:record3)
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(2) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Partial key redefinition
     *----------------------------------------------------------------

     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $khdte                 4     11  0
     D  $khtim                12     17  0
520 AD  $katyp                18     18    inz('A')

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *----------------------------------------------------------------

     D sflkey          ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  w1rtid1                1      5    inz(*blanks)
     D  w1rtid2                6     10    inz(*blanks)
     D  w1rtid3               11     15    inz(*blanks)
     D  w1rtid4               16     20    inz(*blanks)
     D  w1rtid5               21     25    inz(*blanks)
     D rtid                                dim(05) like(w1rtid1) overlay(sflkey)
520 AD  w1atyp                26     26    inz(*blanks)

     D wrkkey          ds
     D  d1whse                 1      3  0 inz(0)
     D  d1hdte                 4     11  0 inz(0)
     D  d1htim                12     17  0 inz(0)
     D  d1pass                18     20  0 inz(0)
     D  d1door                21     23  0 inz(0)
     D  d1whdp                24     28    inz(*blanks)
     D  d1rtid                29     33    inz(*blanks)
     D  d1rtec                34     38p 3 inz(0)
520 AD  d1atyp                39     39    inz(' ')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $lwhse                19     21  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $wkof           s                   like(WKOKYF)
     D $wkou           s                   like(WKOKYU)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D curmode         s             10    inz('*PASSDOOR ')
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D forevr          s              1    inz('1')
     D forceb          s              1
     D frdoor          s                   like(DDDOOR)
     D frstky          s                   like($PUKY)
     D goback          s              2  0
     D hd              s              3  0
     D hidoor          s                   like(DMDOOR)
     D                                     inz(*loval)
     D hiwhdp          s                   like(DMWHDP)
     D                                     inz(*loval)
     D help            s              5  0
     D k               s              5  0 inz(0)
520 AD kyatyp          s                   like(DMATYP)
     D kydoor          s                   like(DMDOOR)
     D kypass          s                   like(DMPASS)
     D kyrtid          s                   like(rhrtid)
     D kywhdp          s                   like(DMWHDP)
     D lodoor          s                   like(DMDOOR)
     D                                     inz(*hival)
     D lowhdp          s                   like(DMWHDP)
     D                                     inz(*hival)
     D msgk            s              4  0
     D nbrred          s              3  0 inz(0)
     D nomore          s              1
     D nxtscr          s              3
     D option          s              2
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
     D ststxt          s              9
     D svwhdp          s                   like(dmwhdp)
     D svpass          s                   like(dmpass)
     D                                     inz(*loval)
     D svpcmd          s              8
     D top             s              1
     D totcube         s              4  0 inz(0)
     D warn            s              1
     D x               s              3  0
     D y               s              3  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('DH122')
520 DD*@delpg          c                   const('DH124')
520 MD @delpg          c                   const('NONE')
     D @prtpg          c                   const('@NONE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
500 AD  $ppass                36     38  0
500 AD  $pdoor                39     41  0
500 AD  $pwhdp                42     46
     D  $prtid                47     51
500 AD  $prtec                52     56P 3
520 AD  $patyp                57     57
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
520 A*
520 A*  Data structure for assign type - actual values.
520 AD atypds          ds
520 AD  w1at1                  1      1
520 AD  w1at2                  2      2
520 AD  w1at3                  3      3
520 AD  w1at4                  4      4
520 AD  w1at5                  5      5
520 AD atyp                                dim(05) like(w1at1) overlay(atypds)
     *
     *  Data structure for dock door#'s - actual values.
     D dkdrds          ds
     D  w1dr1                  1      3  0
     D  w1dr2                  4      6  0
     D  w1dr3                  7      9  0
     D  w1dr4                 10     12  0
     D  w1dr5                 13     15  0
     D dkdr                                dim(05) like(w1dr1) overlay(dkdrds)
     *
     *  Data structure for dock door dept.'s - actual values.
     D dkdpds          ds
     D  w1dp1                  1      5
     D  w1dp2                  6     10
     D  w1dp3                 11     15
     D  w1dp4                 16     20
     D  w1dp5                 21     25
     D dkdp                                dim(05) like(w1dp1) overlay(dkdpds)
     *
     *  Data structure for dock door text string on col. headings.
     D chdords         ds
     D  wodor1                 1     10
     D  wodor2                11     20
     D  wodor3                21     30
     D  wodor4                31     40
     D  wodor5                41     50
     D chdor                               dim(05) like(wodor1) overlay(chdords)
     *
     *  Data structure for max. cube text string on col. headings.
     D chmaxds         ds
     D  womax1                 1     10
     D  womax2                11     20
     D  womax3                21     30
     D  womax4                31     40
     D  womax5                41     50
     D chmax                               dim(05) like(womax1) overlay(chmaxds)

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     D  eropt1                 1     10
     D  erdkdr                11     12P 0
     D  eropt2                13     22
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

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
     *      $PCMD2  *CHANGE  - Change mode.
     *              *VIEW    - View mode.
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd2            8
     C     $prtky        parm                    $pprtky          50
     C                   parm                    $rtncd            8
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   eval      svpcmd = $pcmd2
     C                   exsr      zzinz2
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
     C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
     C                   eval      *inlr = *on
     C                   endif
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        BEGSR
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     *
     *    Position to dock door is on option rcd fmt.
640aD ***                if        curmode = '*PASSDEPT '
640aD ***                read      postnrec                               50
640aD ***                read      optrec                                 50
640aD ***                endif
     *
     C                   when      nxtscr = '02 '
     C                   exsr      deldsp
     C                   endsl
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
     C                   read      dspsfc                                 50
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        BEGSR
     C                   move      '01 '         nxtscr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        BEGSR
     C                   move      '02 '         nxtscr
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag02
     C                   write     cmddel
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        BEGSR
     C                   move      '01 '         nxtscr
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
 1B  C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   move      frstky        $pofky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
 2B  C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
 2X  C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
 2E  C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
 1X  C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           BEGSR
 1B  C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
 1E  C                   endcs
     C     endsc1        ENDSR

     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           BEGSR
 1B  C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
 1E  C                   endcs
     C     endsc2        ENDSR

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        BEGSR
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
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        BEGSR
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
 1B  C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
 1E  C                   enddo
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         BEGSR
     *
     *  TEST FOR CMD3 - EXIT
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $rtncd = '*EXIT   '
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $rtncd = '*CANCEL '
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
 1B  C                   if        *inke
     C                   exsr      clrsch
 2B  C     1             do        10            x
     C     x             chain     dspsfl                             79
 3B  C                   if        not *in79
     C                   eval      option = '  '
     C                   eval      opt1   = '  '
     C                   eval      opt2   = '  '
     C                   eval      opt3   = '  '
     C                   eval      opt4   = '  '
     C                   eval      opt5   = '  '
     C                   update    dspsfl
 3E  C                   endif
 2E  C                   enddo
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
 1B  C                   if        *inkf
     C                   exsr      inzpar
500 AC                   eval      $ppass = 1
500 AC                   eval      $pdoor = 0
500 AC                   eval      $pwhdp = ' '
500 AC                   eval      $prtec = 0
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
 2B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           error
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 2X  C                   else
 3B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 3X  C                   else
 4B  C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
 1B  C                   if        *inkj
     C                   eval      row# = 0
     C                   eval      row  = rowin
     C                   eval      col# = 0
     C                   eval      col  = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
 2B  C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   move      '1'           error
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
goto Csr                 goto      cmd01e
 2E  C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
 1B  C                   if        *inkr
     C                   move      '*TOP    '    pagcmd
     C                   exsr      pag01
goto C                   goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
 1B  C                   if        *inks
     C                   move      '*BOTTOM '    pagcmd
     C                   exsr      pag01
goto C                   goto      cmd01e
 1E  C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        ENDSR

     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         BEGSR
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
 1B  C                   if        *inkl
     C                   move      '1'           cancel
     C                   exsr      scr02e
goto Csr                 goto      cmd02e
 1E  C                   endif
     C     cmd02e        ENDSR

     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        BEGSR
 1B  C                   if        recno < 11
     C                   add       1             recno
     C                   eval      y = recno
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
 2B  C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
 2E  C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
 1E  C                   endif
     C     delade        ENDSR

     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        BEGSR
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
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         BEGSR
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
     C     error         cabeq     '1'           ent01e
 1B  C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
goto Csr                 goto      ent01e
 1E  C                   endif
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
     C     ent01e        ENDSR

     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         BEGSR
     *
     *  Save first delete key.
     *
     C                   move      $puky         frstky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           stop
 1B  C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
 2B  C                   if        *in79
     C                   move      '1'           stop
 2X  C                   else
     *
 3B  C                   if        wkoopt = ' 4'
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
 4B  C                   if        $prtn = '*ERROR  '
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   eval      stop   = *on
     C                   eval      errmsg = $perm
     C                   exsr      zm0105
 4X  C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
 5B  C                   if        $lrtn = '*PGMQ   '
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   eval      stop   = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 5X  C                   else
     *
     *     Delete canceled
     *
 6B  C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop   = *on
 6X  C                   else
     *
     *     Delete was successful.
     *
 7B  C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 7E  C                   endif
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 4B  C                   if        cancel = *off
     C                   delete    wkorec
 4X  C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
 4E  C                   endif
 3E  C                   endif
     *
 2E  C                   endif
 1E  C                   enddo
     C                   exsr      scr02e
     C     ent02e        ENDSR

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
     C     fgtway        BEGSR
     C                   eval      $portn = *blanks
 1B  C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
 1E  C                   endcs
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          BEGSR
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
 1B  C                   if        not %found
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         BEGSR
     C                   exsr      zzfgtn
 1B  C                   if        %eof
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         BEGSR
     C                   exsr      zzfgtp
 1B  C                   if        %eof
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         BEGSR
     *
     C                   eval      dsfkey = $pofky
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     fileky        setll     record
     *
     C                   when      curmode = '*PASSDEPT '
     C     filky3        setll     record3
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        BEGSR
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        BEGSR
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         BEGSR
     C                   move      '0'           otaken
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           stop
     C     wkoprt        reade     workopt                                79
 1B  C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
 1E  C                   enddo
 1B  C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   move      '1'           otaken
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
goto Csr                 goto      optnse
 1E  C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           cancel
     C                   move      '0'           stop
 1B  C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
 2B  C                   if        *in79
     C                   move      '1'           stop
 2X  C                   else
 3B  C                   if        wkoopt <> '  '
     C                   move      '1'           otaken
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   move      '1'           refrsh
 4B  C                   if        error = '0'
     C                   delete    wkorec
 4E  C                   endif
 4B  C                   if        cancel = '1'
     C                   move      '1'           stop
 5B  C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
 5E  C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
     C                   move      '0'           refrsh
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   enddo
 1B  C                   if        refrsh = '1'
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
     C                   move      '0'           refrsh
 1E  C                   endif
     C     optnse        ENDSR

     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        BEGSR
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
 1B  C                   if        wkoopt = ' 2' and svpcmd = '*CHANGE ' and
     C                             $prtid > *blanks
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
 1X  C                   else
     *
     *   View
     *
 2B  C                   if        wkoopt = ' 5' and $prtid > *blanks
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
 2X  C                   else
     *
     *   Print
     *
 3B  C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
 3X  C                   else
     C                   exsr      zzopt
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     *
 1B  C                   if        $prtn = '*CANCEL '
     C                   move      '1'           cancel
 1X  C                   else
 2B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           cancel
     C                   move      '1'           error
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 2X  C                   else
 3B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           cancel
     C                   move      '1'           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         BEGSR
     *
     *  NEXT PAGE
     *
 1B  C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
 1X  C                   else
     *
     *  PREVIOUS PAGE
     *
 2B  C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
 2X  C                   else
     *
     *  TOP
     *
 3B  C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           forceb
     C                   exsr      pag1fw
 3X  C                   else
     *
     *  BOTTOM
     *
 4B  C                   if        pagcmd = '*BOTTOM '
     C                   move      '1'           bot
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
 4X  C                   else
     *
     *  REFRESH SCREEN
     *
 5B  C                   if        pagcmd = '*REFRESH'
 6B  C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
 6X  C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
 6E  C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   move      '0'           bot
     C                   exsr      pag1fw
 5X  C                   else
     *
     *  REPOSITIONING
     *
 6B  C                   if        pagcmd = '*REPOS  '
     C                   move      '0'           bot
     C                   move      '0'           forceb
     C                   exsr      pag1fw
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        ENDSR

     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         BEGSR
     *
     *  NEXT PAGE
     *
 1B  C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
 1X  C                   else
     *
     *  PREVIOUS PAGE
     *
 2B  C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
 2X  C                   else
     *
     *  REFRESH SCREEN
     *
 3B  C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   move      '0'           bot
     C                   exsr      pag2fw
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        ENDSR

     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        BEGSR
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   eval      fkey = *loval
     C                   eval      ukey = *loval
     C                   eval      dsfkey = *loval
     C                   eval      bot = '0'
     C                   eval      top = '0'
     C                   eval      stop = '0'
     C                   eval      p = 0
     C                   eval      nbrred = 0
     C                   eval      svpass = *loval
     *
     *  Clear dock door heading fields.
     *
     C                   eval      chdords = *blanks
     C                   eval      chmaxds = *blanks
520 AC                   eval      atypds  = *blanks
     C                   eval      dkdrds  = *zeros
     C                   eval      dkdpds  = *blanks
     *
     C                   select
     *------------------------------------------------------------------------
     *
     *  Load Dock Door Headings.
     C                   when      curmode = '*PASSDOOR '
     *
     C                   eval      Hd = 0
     C     Keydd1        setll     docdoor
     C                   eval      lodoor = *hival
     C                   eval      hidoor = *loval
1B   C                   dow       forevr = *ON
     C     Keydd         reade     Docdoor
     C                   select
2B   C                   when      %eof(docdoor)
     C                   leave
     *
2X   C                   other
     *
     C                   eval      hd = hd + 1
     *
     *    Save smallest dock door listed.
3B   C                   if        dddoor < lodoor and hd <= 5
     C                   eval      lodoor = dddoor
3E   C                   endif
     *
     *    Save largest dock door listed.
3B   C                   if        dddoor > hidoor and hd <= 5
     C                   eval      hidoor = dddoor
3E   C                   endif
     *
     *    Build column headings for display.
     C                   exsr      zzblhdr
     *
2E   C                   endsl
     *
1E   C                   enddo
     *
     *------------------------------------------------------------------------
     *
     C                   when      curmode = '*PASSDEPT '
     *
     C                   eval      Hd = 0
     C     Keydd2        setll     docdoor1
     C                   eval      lodoor = *hival
     C                   eval      lowhdp = *hival
     C                   eval      hidoor = *loval
     C                   eval      hiwhdp = *loval
1B   C                   dow       forevr = *ON
     C     Keydd         reade     Docdoor1
     C                   select
2B   C                   when      %eof(docdoor1)
     C                   leave
     *
2X   C                   other
     *
     C                   eval      hd = hd + 1
     *
     *    Save smallest door dept listed.
     C                   if        ddwhdp < lowhdp and hd <= 5
     C                   eval      lowhdp = ddwhdp
     C                   endif
     *
     *    Save smallest dock door listed.
     C                   if        ddwhdp = lowhdp and hd <= 5
     C                   if        dddoor < lodoor
     C                   eval      lodoor = dddoor
     C                   endif
     C                   endif
     *
     *    Save largest door dept listed.
     c                   if        ddwhdp > hiwhdp and hd <= 5
     C                   eval      hiwhdp = ddwhdp
     *    Door dept changed. Force door dept to change too.
     C                   eval      hidoor = *loval
     C                   endif
     *
     *    Save largest door dept listed.
     c                   if        ddwhdp = hiwhdp and hd <= 5
     c                   if        dddoor > hidoor
     C                   eval      hidoor = dddoor
     C                   endif
     C                   endif
     *
     *    Build column headings for display.
     C                   exsr      zzblhdr
     *
     C                   endsl
     *
1E   C                   enddo
     *
     C                   endsl
     *
     *------------------------------------------------------------------------
     *
     *  Get 10 Records to Display.
     *
 1B  C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  Out of Records - Inform User and Set Flag.
     *
 2B  C                   if        $portn = '*NOMORE '
     *
     *    Write out last record to subfile.
     *
 3B  C                   if        nbrred > 0
     *    Write last filled record to subfile.
     C                   exsr      zzsflad
     *
 3E  C                   endif
     *
     C                   move      '1'           stop
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
goto C                   goto      endfac
 2E  C                   endif
     *
     *    Display is in Pass / Door sequence. Skip doors not in range.
     *
     C                   select
     C                   when      curmode = '*PASSDOOR ' and
     C                             ((dmdoor > hidoor) or
     C                             (dmdoor < lodoor))
     C                   iter
     *
     C                   when      curmode = '*PASSDEPT ' and
     C                               dmwhdp >= hiwhdp     and
     C                               dmdoor > hidoor      or
     C                             curmode = '*PASSDEPT ' and
     C                               dmwhdp <= lowhdp     and
     C                               dmdoor < lodoor      or
     C                             curmode = '*PASSDEPT ' and
     C                               dmwhdp > hiwhdp      or
     C                             curmode = '*PASSDEPT ' and
     C                               dmwhdp < lowhdp
     C                   iter
     *
     C                   endsl
     *
     *    Pass changed - write record to subfile.
     *
 4B  C                   if        dmpass <> svpass and nbrred > 0
     *
     *    Write filled record to subfile.
     C                   exsr      zzsflad
     *
     *    Check if subfile is full.
     C                   exsr      zzsflen
     C                   if        stop = *on
     *
     *    Pass changed. Reposition pointer to record just read.
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     filuky        setll     record
     C                   when      curmode = '*PASSDEPT '
     C     filuky3       setll     record3
     C                   endsl
     C                   iter
     C                   endif
 4E  C                   endif
     *
     *  Record Read - Stop After 10 Good Records Written to Subfile.
     *
     C                   exsr      sfladd
     *
     *    Subfile record filled with data - write to subfile.
     *
 4B  C                   if        nbrred = 5
     *
     *    Write filled record to subfile.
     C                   exsr      zzsflad
     *
     *    Check if subfile is full.
     C                   exsr      zzsflen
     C                   if        stop = *on
     C                   iter
     C                   endif
     *
     C                   eval      svpass = dmpass
 4E  C                   endif
     *
     C*****              exsr      zzsflen
     C                   if        stop = *on
     C****               iter
     C                   endif
     C*
     C     endfac        tag
 1E  C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   move      '0'           forceb
     C     endf          ENDSR

     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        BEGSR
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 10
 1B  C                   if        bot = '1'
 2B  C                   if        goback = 10
     C                   move      '1'           forceb
 2E  C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
 1E  C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ SPECIFIED FLITCHES FILE
     *
 1B  C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   move      '1'           stop
     C                   move      '1'           top
goto Csr                 goto      endbk
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
 2B  C                   if        p >= goback
     C                   move      '1'           stop
 2E  C                   endif
     C     endbk         tag
 1E  C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
 1B  C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
 1E  C                   endif
     C                   exsr      pag1fw
     C     endb          ENDSR

     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        BEGSR
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
     C                   move      '0'           bot
     C                   move      '0'           top
     C                   move      '0'           stop
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
 1B  C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
 2B  C                   if        *in79
     C                   move      '1'           stop
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
goto Csr                 goto      endfw2
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
 2B  C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
 3B  C                   if        p >= 10
     C                   move      '1'           stop
 4B  C                   if        forceb = '1'
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
 4X  C                   else
     C                   eval      moreln = 'More...'
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
     C     endfw2        tag
 1E  C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   move      '0'           forceb
     C     endf2         ENDSR

     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        BEGSR
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 10
 1B  C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
 1E  C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ FILE
     *
 1B  C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
 2B  C                   if        *in79
     C                   move      '1'           stop
     C                   move      '1'           top
goto Csr                 goto      endbk2
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
 2B  C                   if        wkoopt = ' 4'
     C                   add       1             p
 3B  C                   if        p >= goback
     C                   move      '1'           stop
 3E  C                   endif
 2E  C                   endif
     C     endbk2        tag
 1E  C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
 1B  C                   if        top = '1'
     C     wkoprt        setll     workopt
 1E  C                   endif
     C                   exsr      pag2fw
     C     endb2         ENDSR

     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        BEGSR
     *
     *  TEST FOR ROLLUP
     *
 1B  C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   move      '*NEXT   '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      rol01e
 1E  C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
 1B  C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   move      '*PREV   '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      rol01e
 1E  C                   endif
     C     rol01e        ENDSR

     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        BEGSR
     *
     *  TEST FOR ROLLUP
     *
 1B  C                   if        status = rollup
     C                   move      '*NEXT   '    pagcmd
     C                   exsr      pag02
goto Csr                 goto      rol02e
 1E  C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
 1B  C                   if        status = rolldn
     C                   move      '*PREV   '    pagcmd
     C                   exsr      pag02
goto C                   goto      rol02e
 1E  C                   endif
     C     rol02e        ENDSR

     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        BEGSR
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   move      '0'           nomore
     C                   dou       nomore = *on
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     C                   eval      y = recno
     *
     *    Load work key for subfile record just read.
     C                   eval      dsfkey = fkey(y)
     *
     *    Loop through all five option fields. Write out record to
     *    work option file for each option encountered.
     *
     C     1             do        5             k
     C                   exsr      zzgtopt
     C                   select
     C                   when      option = *blanks
     C                   iter
     C                   endsl
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found.
     *
     C     option        lookup    zopt                                   50
     *
     *    Display error if option is not valid.
     C                   if        not *in50
     C                   exsr      zzstind
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  Retrieve Customer Route Number
     *
     C                   eval      kyrtid = rtid(k)
     C     keyrh         chain     rtehed                             79
1B   C     *in79         ifeq      *On
     C                   eval      rhstat = *blanks
1E   C                   endif
     C                   select
     *
     *    Change/view option not available for doors with no route assigned.
     C                   when      rtid(k) = *blanks and option = ' 2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      eropt1 = '2=Change'
     C                   eval      erdkdr = dkdr(k)
     C                   exsr      zm1055
     *
     *    Change option not available for doors when program called in:
     *    View Only mode -or-
     *    Route no longer at Built status.
     C                   when      svpcmd = '*VIEW   ' and option = ' 2' or
     C                             rhstat <> '3'  and option = ' 2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      eropt1 = '2=Change  '
     C                   eval      erdkdr = dkdr(k)
     C                   eval      eropt2 = '5=View    '
     C                   exsr      zm1056
     *
     C                   endsl
     *
     *  SAVE OPTION
     *
     *    Build unique key for each option selected.
     C                   eval      wrkkey = $prtky
     C                   eval      d1pass = w1pass
520 AC                   eval      d1atyp = atyp(k)
     C                   eval      d1door = dkdr(k)
     C                   eval      d1whdp = dkdp(k)
     C                   eval      d1rtid = rtid(k)
     C                   eval      d1rtec = *zeros
     *
     C                   eval      wkokyf = wrkkey
     C                   eval      wkokyu = wrkkey
     C     wkounq        chain     workopt
     C                   if        %found(workopt)
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   eval      wkoerr = *in21
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = wrkkey
     C                   eval      wkokyu = wrkkey
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   enddo
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        BEGSR
     C                   if        recno < 11
     C                   add       1             nbrred
     *
     *    Initialize save field on first record read so that next pass
     *    a subfile record isn't written prematurely.
     C                   if        nbrred = 1
     C                   eval      svpass = dmpass
     C                   eval      w1inf1 = *blanks
     C                   eval      w1inf2 = *blanks
     C                   eval      w1inf3 = *blanks
     C                   eval      w1inf4 = *blanks
     C                   eval      w1inf5 = *blanks
     C                   eval      dsfkey = *blanks
     C                   endif
     *
     *  Retrieve Customer Route Number
     *
     C                   eval      kyrtid = dmrtid
     C     keyrh         chain     rtehed                             79
1B   C     *in79         ifeq      *On
     C                   eval      rhrte = *blanks
1E   C                   endif
     *
     *  Save file and unique keys
     *
     C**                 eval      fkey(y) = $pofky
     C**                 eval      ukey(y) = $pouky
     *
     *  Fill subfile fields with data.
     *
     C                   exsr      zzfill
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        BEGSR
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   write     dspsfc
     C                   eval      recno = 0
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        BEGSR
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
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
     C     1             chain     dspsfl
     C                   if        %found
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
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        BEGSR
 1B  C     1             do        10            x
     C     x             chain     dspsfl                             79
 2B  C                   if        not *in79
     C                   eval      dsfkey = fkey(x)
     *
     C     1             do        5             k
     *
     *    No route loaded - Check next column.
     C                   if        rtid(k) = *blanks
     C                   exsr      zzclind
     C*******            iter
     C                   endif
     *
     *    Build unique key for each option selected.
     C                   eval      wrkkey = $prtky
     C                   eval      d1pass = w1pass
     C                   eval      d1door = dkdr(k)
     C                   eval      d1whdp = dkdp(k)
     C                   eval      d1rtid = rtid(k)
     C                   eval      d1rtec = *zeros
     C                   eval      wkokyf = wrkkey
     C                   eval      wkokyu = wrkkey
     C     wkounq        chain     workopt
 3B  C                   if        %found
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   select
     *    Re-Load option into subfile and reset error ind.
     C                   when      k = 1
     C                   eval      opt1   = wkoopt
     C                   eval      *in22  = wkoerr
     C                   when      k = 2
     C                   eval      opt2   = wkoopt
     C                   eval      *in23  = wkoerr
     C                   when      k = 3
     C                   eval      opt3   = wkoopt
     C                   eval      *in24  = wkoerr
     C                   when      k = 4
     C                   eval      opt4   = wkoopt
     C                   eval      *in25  = wkoerr
     C                   when      k = 5
     C                   eval      opt5   = wkoopt
     C                   eval      *in26  = wkoerr
     C                   endsl
 3X  C                   else
     *    Re-Load option into subfile and reset error ind.
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   exsr      zzclind
 3E  C                   endif
     C                   enddo
     *
     C                   update    dspsfl
 2E  C                   endif
 1E  C                   enddo
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        BEGSR
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   ENDSR
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        BEGSR
     C                   write     msgclr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     C                   ENDSR
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        BEGSR
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   ENDSR
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        BEGSR
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   ENDSR
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        BEGSR
     C                   add       1             msgk
     C                   write     msgrec
     C                   ENDSR
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         BEGSR
     *R                   WRITECLRSCR
     C                   move      *on           sclear
     C                   ENDSR
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        BEGSR
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   ENDSR
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        BEGSR
     C                   move      'PIR0101'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        BEGSR
     C                   move      'PIR0102'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        BEGSR
     C                   move      'PIR0103'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        BEGSR
     C                   move      'PIR0104'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        BEGSR
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        BEGSR
     C                   move      'PIR0106'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        BEGSR
     C                   move      'PIR0107'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        BEGSR
     C                   move      'PIR0108'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      1055  Option not allowed on dock door. No route assigned to door.
     *
     C     zm1055        BEGSR
     C                   move      'PIR1055'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *      1056  Option not allowed on dock door. Option x available.
     *
     C     zm1056        BEGSR
     C                   move      'PIR1056'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        BEGSR
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         BEGSR
     *
     *  Test for F4 - Lookup
     *
 1B  C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
 2B  C                   if        row# = 3  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
 3E  C                   endif
 2X  C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      '1'           error
     C                   exsr      zm9905
 2E  C                   endif
goto Csr                 goto      endcm1
 1E  C                   endif
     *
     *  Test for F9 - Display by dept/door
     *
 1B  C                   if        *inki
520 AC                   eval      kyatyp  = ' '
     C                   eval      kywhdp  = *blanks
     C                   eval      kypass  = *zeros
     C                   eval      kydoor  = *zeros
     *
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C                   eval      curmode = '*PASSDEPT '
     C                   eval      *in40  = *off
     C                   eval      cmdln1 = cmdln(2)
     *
     C                   when      curmode = '*PASSDEPT '
     C                   eval      curmode = '*PASSDOOR '
     C                   eval      *in40  = *on
     C                   eval      cmdln1 = cmdln(1)
     C                   endsl
     *
     *    Reload subfile in new display sequence
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
goto C                   goto      endcm1
 1E  C                   endif
     *
     *  Test for F11 - Display More doors
     *
 1B  C                   if        *inkk
     *
     *    If any heading fields are blank, then we're at end of doors.
     *    Re-display starting at Door 1.
 1B  C                   if        wodor1 = *blanks or
     C                             wodor2 = *blanks or
     C                             wodor3 = *blanks or
     C                             wodor4 = *blanks or
     C                             wodor5 = *blanks
     C                   eval      kydoor = 1
     *
     C                   if        curmode = '*PASSDEPT'
     C                   eval      kywhdp = *blanks
     C                   endif
     *
 1E  C                   else
     *
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C                   eval      kydoor = dkdr(5) + 1
     *
     C                   when      curmode = '*PASSDEPT '
     C                   eval      kywhdp = dkdp(5)
     C                   eval      kydoor = dkdr(5) + 1
     c                   endsl
     *
 1E  C                   endif
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
goto C                   goto      endcm1
 1E  C                   endif
     C     endcm1        ENDSR

     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        BEGSR
     *
     *    Code to use when file key and unique key are the same.
     *
     C     filuky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        BEGSR
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     partky        reade     record
     *
     C                   when      curmode = '*PASSDEPT '
     C     partky        reade     record3
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        BEGSR
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     partky        readpe    record
     *
     C                   when      curmode = '*PASSDEPT '
     *
     C     partky        readpe    record3
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        BEGSR
     *
     *  Fill subfile matrix fields
     *
     C                   eval      w1pass = dmpass
     *
     C                   select
     C     dmdoor        wheneq    w1dr1
     C     dmwhdp        andeq     w1dp1
520 AC                   eval      w1at1 = dmatyp
     C                   if        dmstat = '2'
     C                   if        dmovrf = 'Y'
     C                   eval      w1inf1 = 'Ovrflow  '
     C                   else
     *
     C                   eval      w1rtid1 = dmrtid
     C                   eval (h)  totcube = dmrtec
     C                   eval      svwhdp  = dmwhdp
     C                   exsr      zznxtdr
     *
     C                   if        dmovrf = 'Y' and dmwhdp = svwhdp
     C                   eval (h)  totcube = totcube + dmrtec
     C                   endif
     C                   exsr      zzprvdr
     C                   eval      w1inf1 = rhrte  + ' ' +
     C                             %triml(%editc(totcube: 'Z'))
     C                   endif
     *
     C                   else
     *
     C                   exsr      zzstat
     C                   eval      w1inf1 = ststxt
     C                   eval      w1rtid1 = *blanks
     C                   endif
     *
     C     dmdoor        wheneq    w1dr2
     C     dmwhdp        andeq     w1dp2
520 AC                   eval      w1at2 = dmatyp
     C                   if        dmstat = '2'
     C                   if        dmovrf = 'Y'
     C                   eval      w1inf2 = 'Ovrflow  '
     C                   else
     *
     C                   eval      w1rtid2 = dmrtid
     C                   eval (h)  totcube = dmrtec
     C                   eval      svwhdp  = dmwhdp
     *
     C                   exsr      zznxtdr
     C                   if        dmovrf = 'Y' and dmwhdp = svwhdp
     C                   eval (h)  totcube = totcube + dmrtec
     C                   endif
     C                   exsr      zzprvdr
     C                   eval      w1inf2 = rhrte + ' ' +
     C                             %triml(%editc(totcube: 'Z'))
     C                   endif
     *
     C                   else
     *
     C                   exsr      zzstat
     C                   eval      w1inf2 = ststxt
     C                   eval      w1rtid2 = *blanks
     C                   endif
     *
     C     dmdoor        wheneq    w1dr3
     C     dmwhdp        andeq     w1dp3
520 AC                   eval      w1at3 = dmatyp
     C                   if        dmstat = '2'
     C                   if        dmovrf = 'Y'
     C                   eval      w1inf3 = 'Ovrflow  '
     C                   else
     *
     C                   eval      w1rtid3 = dmrtid
     C                   eval (h)  totcube = dmrtec
     C                   eval      svwhdp  = dmwhdp
     *
     C                   exsr      zznxtdr
     C                   if        dmovrf = 'Y' and dmwhdp = svwhdp
     C                   eval (h)  totcube = totcube + dmrtec
     C                   endif
     C                   exsr      zzprvdr
     C                   eval      w1inf3 = rhrte + ' ' +
     C                             %triml(%editc(totcube: 'Z'))
     C                   endif
     *
     C                   else
     *
     C                   exsr      zzstat
     C                   eval      w1inf3 = ststxt
     C                   eval      w1rtid3 = *blanks
     C                   endif
     *
     C     dmdoor        wheneq    w1dr4
     C     dmwhdp        andeq     w1dp4
520 AC                   eval      w1at4 = dmatyp
     C                   if        dmstat = '2'
     C                   if        dmovrf = 'Y'
     C                   eval      w1inf4 = 'Ovrflow  '
     *
     C                   else
     *
     C                   eval      w1rtid4 = dmrtid
     C                   eval (h)  totcube = dmrtec
     C                   eval      svwhdp  = dmwhdp
     *
     C                   exsr      zznxtdr
     *
     C                   if        dmovrf = 'Y' and dmwhdp = svwhdp
     C                   eval (h)  totcube = totcube + dmrtec
     C                   endif
     C                   exsr      zzprvdr
     C                   eval      w1inf4 = rhrte + ' ' +
     C                             %triml(%editc(totcube: 'Z'))
     C                   endif
     *
     C                   else
     *
     C                   exsr      zzstat
     C                   eval      w1inf4 = ststxt
     C                   eval      w1rtid4 = *blanks
     C                   endif
     *
     C     dmdoor        wheneq    w1dr5
     C     dmwhdp        andeq     w1dp5
520 AC                   eval      w1at5 = dmatyp
     C                   if        dmstat = '2'
     C                   if        dmovrf = 'Y'
     C                   eval      w1inf5 = 'Ovrflow  '
     *
     C                   else
     *
     C                   eval      w1rtid5 = dmrtid
     C                   eval (h)  totcube = dmrtec
     C                   eval      svwhdp  = dmwhdp
     *
     C                   exsr      zznxtdr
     C                   if        dmovrf = 'Y' and dmwhdp = svwhdp
     C                   eval (h)  totcube = totcube + dmrtec
     C                   endif
     C                   exsr      zzprvdr
     C                   eval      w1inf5 = rhrte + ' ' +
     C                             %triml(%editc(totcube: 'Z'))
     C                   endif
     *
     C                   else
     *
     C                   exsr      zzstat
     C                   eval      w1inf5 = ststxt
     C                   eval      w1rtid5 = *blanks
     C                   endif
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         BEGSR
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
     *     USERCODE
     *
     C     uskey         klist
     C                   kfld                    #user
     *
     *  Define unique file key. - DOCMTRX
     *
     C     filuky        klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmpass
     C                   kfld                    dmdoor
     C                   kfld                    dmwhdp
     C     filuky3       klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmpass
     C                   kfld                    dmwhdp
     C                   kfld                    dmdoor
     *
     *  Define full key for main file. DOCMTRX
     *
     C     fileky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $khdte
     C                   kfld                    $khtim
520 AC                   kfld                    kyatyp
     C                   kfld                    kypass
     C                   kfld                    kydoor
     *
     *  Define full key for main file. DOCMTRX3
     *
     C     filky3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $khdte
     C                   kfld                    $khtim
520 AC                   kfld                    kyatyp
     C                   kfld                    kypass
     C                   kfld                    kywhdp
     C                   kfld                    kydoor
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $khdte
     C                   kfld                    $khtim
     C     prtky1        klist
     C                   kfld                    $kwhse
     C                   kfld                    $khdte
     C                   kfld                    $khtim
520 AC                   kfld                    kyatyp
     C                   kfld                    kypass
     C                   kfld                    kydoor
     *
     *  Define partial key for main file (if needed).
     *
     C     prtky2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $khdte
     C                   kfld                    $khtim
520 AC                   kfld                    kyatyp
     C                   kfld                    kypass
     C                   kfld                    kywhdp
     C                   kfld                    kydoor
     *
     C     nextky        klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmpass
     *
     C     nxt1ky        klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmwhdp
     C                   kfld                    dmpass
     *
     *  Define partial key for DOCDOOR.
     *
     C     keydd         klist
     C                   kfld                    ddwhse
     C     keydd1        klist
     C                   kfld                    ddwhse
     C                   kfld                    kydoor
     *
     *  Define partial key for DOCDOOR1.
     *
     C     keydd2        klist
     C                   kfld                    ddwhse
     C                   kfld                    kywhdp
     C                   kfld                    kydoor
     *
     *  Define partial key for RTEHED.
     *
     C     keyrh         klist
     C                   kfld                    dmwhse
     C                   kfld                    kyrtid
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        BEGSR
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     ddwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = ddwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ddwhse
     C                   call      'WH900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 2X  C                   else
     C                   eval      $kwhse = ddwhse
     C                   eval      whcode = ddwhse
     C                   movel     $lerm         whdesc
 2E  C                   endif
 1E  C                   endif
     *
520 AC                   eval      $katyp = 'A'
520 AC                   eval      kyatyp = 'A'
     C                   eval      *in40  = *on
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZBLHDR  Build column headings for display.
     *
     C     ZZBLHDR       BEGSR
     *
     *    Build display headings.
     *
     C                   if        hd >= 1 and hd<= 5
     *
     C                   eval      chdor(hd) = %TRIML(%EDITC(DDDOOR:'Z')) + ':'
     C                                         + ddwhdp
     C                   eval      chmax(hd) = 'Max  ' +
     C                                         %TRIML(%EDITC(DDMAXC: 'Z'))
     C                   eval      dkdr(hd)  = dddoor
     C                   eval      dkdp(hd)  = ddwhdp
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZCLIND  Clear error indicator/ option field for subfile rcd.
     *
     C     ZZCLIND       BEGSR
     *
     *    Activate subfile error indicatiors.
     C                   select
     C                   when      k = 1
     C                   eval      opt1  = *blanks
     C                   eval      *in22 = *off
     *                                      f
     C                   when      k = 2
     C                   eval      opt2  = *blanks
     C                   eval      *in23 = *off
     *
     C                   when      k = 3
     C                   eval      opt3  = *blanks
     C                   eval      *in24 = *off
     *
     C                   when      k = 4
     C                   eval      opt4  = *blanks
     C                   eval      *in25 = *off
     *
     C                   when      k = 5
     C                   eval      opt5  = *blanks
     C                   eval      *in26 = *off
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZGTOPT  Load option from subfile record into std option field.
     *
     C     ZZGTOPT       BEGSR
     *
     C                   eval      option = *blanks
     *    Load option from subfile record for processing.
     C                   select
     C                   when      opt1 > *blanks and k = 1
     C                   eval      option = opt1
     *
     C                   when      opt2 > *blanks and k = 2
     C                   eval      option = opt2
     *
     C                   when      opt3 > *blanks and k = 3
     C                   eval      option = opt3
     *
     C                   when      opt4 > *blanks and k = 4
     C                   eval      option = opt4
     *
     C                   when      opt5 > *blanks and k = 5
     C                   eval      option = opt5
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        BEGSR
     C                   eval      $pofky = dsfkey
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        BEGSR
     C                   eval      $pouky = dsukey
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZNXTDR  Find next door. Looking for overflow for current door.
     *
     C     ZZNXTDR       BEGSR
     *
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     nextky        reade     record
     C                   if        %eof(docmtrx)
     C     nextky        setgt     docmtrx
     C                   endif
     *
     C                   when      curmode = '*PASSDEPT '
     C     nxt1ky        reade     record1
     C                   if        %eof(docmtrx1)
     C     nxt1ky        setgt     docmtrx1
     C                   endif
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         BEGSR
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         BEGSR
     *
     *  See if user is trying to change warehouse.
     *
 1B  C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
 2B  C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
goto Csr                 goto      endzps
 2X  C                   else
 3B  C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
goto Csr                 goto      endzps
 3X  C                   else
     C                   eval      ddwhse = ptinp1
     C                   eval      $kwhse = ddwhse
520 AC                   if        ptinp6 = ' '
520 AC                   eval      kyatyp = 'A'
520 AC                   endif
     C                   eval      ddwhdp = *blanks
     C                   eval      dddoor = 0
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   move      *on           repos
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
520 A*
520 A*  See if user is trying to position to Assign Type A=Auto/M=Manual
520 AC                   if        ptinp6 > ' '
520 AC                   eval      kyatyp = ptinp6
520 AC                   eval      ptinp6 = ' '
520 AC                   else
520 AC                   eval      kyatyp = 'A'
520 AC                   endif
     *
     *  See if user is trying to position to pass
     C                   if        ptinp2 <> *zeros
     C                   eval      kypass  = ptinp2
     C                   eval      ptinp2  = 0
     C                   move      *on           repos
     C                   endif
     *
     *  See if user is trying to position to dock door.
     C                   if        curmode = '*PASSDOOR'  and ptinp3 > *zeros
     C                   eval      kydoor  = ptinp3
     C                   eval      ptinp3  = *zeros
     C                   move      *on           repos
     *
 1E  C                   endif
     *
     *  See if user is trying to position to department.
     *
     C                   if        curmode = '*PASSDEPT'  and ptinp4 > *blanks
     C                   eval      kywhdp = ptinp4
     C                   eval      ptinp4 = *blanks
     C                   move      *on           repos
 3E  C                   endif
     *
     *  See if user is trying to position to dock door.
     *
     C                   if        curmode = '*PASSDEPT'  and ptinp5 > *zeros
     C                   eval      kydoor = ptinp5
     C                   eval      ptinp5 = *zeros
     C                   move      *on           repos
 3E  C                   endif
     *
     C     endzps        ENDSR

     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        BEGSR
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
 1B  C                   if        $pocmd = '*TOP'
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     prtky1        setll     record
     *
     C                   when      curmode = '*PASSDEPT '
     C     prtky2        setll     record3
     *
     C                   endsl
 1X  C                   else
 2B  C                   if        $pocmd = '*BOTTOM'
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     prtky1        setgt     record
     *
     C                   when      curmode = '*PASSDEPT '
     C     prtky2        setgt     record3
     *
     C                   endsl
 2E  C                   endif
 1E  C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZPRVDR  Read backward to previously read door.
     *
     C     ZZPRVDR       BEGSR
     *
     C                   select
     C                   when      curmode = '*PASSDOOR '
     C     nextky        readpe    record                                 79
     *
     C                   when      curmode = '*PASSDEPT '
     *
     C     nxt1ky        readpe    record1                                79
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZSFLAD  Write filled record to subfile.
     *
     C     ZZSFLAD       BEGSR
     *
     C                   eval      nbrred = 0
     C                   eval      p = p + 1
     C                   eval      recno = recno + 1
     C                   eval      y = recno
     *
     *    Save file and unique keys
     C                   eval      fkey(y) = dsfkey
     C                   eval      ukey(y) = dsfkey
     *
     C                   write     dspsfl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZSFLEN  Check if subfile is full. Set flags if full.
     *
     C     ZZSFLEN       BEGSR
     *
 2B  C                   if        p >= 10
     C                   move      '1'           stop
 3B  C                   if        forceb = '1'
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
 3X  C                   else
     C                   eval      moreln = 'More...'
 3E  C                   endif
 2E  C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZSTAT   Position to record
     *
     C     ZZSTAT        BEGSR
     *
     C                   select
     C                   when      dmstat = '1'
     C                   eval      ststxt = 'Open '
     *
     C                   when      dmstat = '2'
     C                   eval      ststxt = 'Inuse'
     *
     C                   when      dmstat = '3'
     C                   eval      ststxt = 'Skip ' + ' - ' + dmskpr
     *
     C                   when      dmstat = '4'
     C                   eval      ststxt = 'Inact'
     *
     C                   other
     C                   eval      ststxt = '     '
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZSTIND  Set error indicators for subfile record.
     *
     C     ZZSTIND       BEGSR
     *
     C                   eval      *in22 = *off
     C                   eval      *in23 = *off
     C                   eval      *in24 = *off
     C                   eval      *in25 = *off
     C                   eval      *in26 = *off
     *    Activate subfile error indicatiors.
     C                   select
     C                   when      k = 1
     C                   eval      *in22 = *on
     *
     C                   when      k = 2
     C                   eval      *in23 = *on
     *
     C                   when      k = 3
     C                   eval      *in24 = *on
     *
     C                   when      k = 4
     C                   eval      *in25 = *on
     *
     C                   when      k = 5
     C                   eval      *in26 = *on
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 5
**  OPTLN - Option display line
  2=Change  5=View
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F6=Create  F9=By dept F11=More doors F12=Cancel
F3=Exit  F4=Prompt  F5=Refresh  F6=Create  F9=By door F11=More doors F12=Cancel
