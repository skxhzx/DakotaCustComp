500 A /copy *libl/qcopysrc,hspecs
500eA*----------------------------------------------------------------
500eA*  Multilingual Verision
500eA*  Every screen and message has a corresponding Spanish version.
500eA*  Any changes must be made to both languages.
500eA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UI330  UCI RF  Inventory entry
     *  30 August, 2006
     *  Roxanne Harrison
     *
     *  Notes:
     *       Created using IV330
     *       8 X 20 Screens for hand held scanners
     * FUTURE:
     *  Add display screen if started UCI or SLOTS are found.
     *  Reset started slot and send user to re-do slot or clear item
     *  UCI count.
     *
     * Revisions:
510bA*    10/31/06  RH   5.10b
     *      - Fix: Was not reading UIIUCI2 in ZZUALL.
510cAF*    12/06/06  RH   5.10c
     F*      - Enh: Remove BFCADR, no long used.
530aA*    12/07/09  RH   5.30a
     *      - Add Designation code to parms for CHKSTAT.
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
     Fui330fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Finvteam   if   e           k disk
     Finvlock   uf a e           k disk
     Fitemadj   o  a e           k disk
     Flabel     uf a e           k disk
     Fpirtran   if   e           k disk
     Fslot2     uf   e           k disk
     Fslot4     if   e           k disk
     F                                     rename(slrec:slrec4)
     Fuciadj    o  a e           k disk
     Fucicw     uf   e           k disk
     Fucicw2    if   e           k disk
     F                                     rename(ucirec:ucirc2)
     Fucicw3    if   e           k disk
     F                                     rename(ucirec:ucirc3)
     Fuiiexcp   uf a e           k disk
     Fuiiuci    uf a e           k disk
     Fuiiuci2   uf   e           k disk
     F                                     rename(uiurec:uiurc2)
     Fuiislot   uf a e           k disk
     Fuiislot2  uf   e           k disk
     F                                     rename(uisrec:uisrc2)
500bAFitemmsc   if   e           k disk
500b Foptions   if   e           k disk
    A*----------------------------------------------------------------
    A*  Customer id
    A*
    AD @getcl          c                   const('GETCLIENT')
    AD*
    A /COPY QCOPYSRC,ID#PACKERS
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
500bMD desc            s             20    dim(6) ctdata perrcd(1)
500bDD*desc            s             20    dim(5) ctdata perrcd(1)
500eMD descsp          s             20    dim(6) ctdata perrcd(1)

500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#ITEM
500 A /COPY *libl/qcopysrc,C#SLOT
500 AD saveVer#        s                   like($slver#)
500 AD save$slot       s                   like($slot)

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
     D  $puser                39     48
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
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $luser                19     28
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
     D  $lusr1                54     63
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *                                       1   8 $CVDOP
     *                                       9  140$CVDD6
     *                                      15  220$CVDD8

500 A*----------------------------------------------------------------
500 A*  LT210 parameters
500 A*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

416bA*----------------------------------------------------------------
416bA*  API programs
416bA*
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erdate                 1      6  0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500eAD #msgsp          c                   const('PIRMSGFSP ')
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
500cAD  #pgm             *proc
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
     *  variables
     *

500 AD #toititem       s                   like($ititem)
500 AD #toittype       s                   like($ittype)
500 AD #toitdesc       s                   like($itdesc)
500 AD #toitpdsc       s                   like($itpdsc)
500 AD #toithead       s             70
500 AD #toitwhdp       s                   like($itwhdp)
500 AD #toitstyp       s                   like($itstyp)
500 AD #toitdesg       s                   like($itdesg)
500 AD #toitum1        s                   like($itum1)
500 AD #toitflg1       s                   like($itflg1)
500 AD #toitum2        s                   like($itum2)
500 AD #toitumq2       s                   like($itumq2)
500 AD #toitflg2       s                   like($itflg2)
500 AD #toitum3        s                   like($itum3)
500 AD #toitumq3       s                   like($itumq3)
500 AD #toitnrpk       s                   like($imnrpk)
500 AD #toitflgd       s                   like($itflgd)
500 AD #toitcube       s                   like($itcube)
500 AD #toitswgt       s                   like($itswgt)
500 AD #toitcwgt       s                   like($itcwgt)
500 AD #toitmitem      s                   like($itmitem)
500 AD #toitsdef       s                   like($idsdef)
500 AD #toittie        s                   like($idtie)
500 AD #toithigh       s                   like($idhigh)

500 AD #tossbititem    s                   like($ititem)
500 AD #tossbittype    s                   like($ittype)
500 AD #tossbitdesc    s                   like($itdesc)
500 AD #tossbitpdsc    s                   like($itpdsc)
500 AD #tossbitwhdp    s                   like($itwhdp)
500 AD #tossbitstyp    s                   like($itstyp)
500 AD #tossbitdesg    s                   like($itdesg)
500 AD #tossbitum1     s                   like($itum1)
500 AD #tossbitum2     s                   like($itum2)
500 AD #tossbitumq2    s                   like($itumq2)
500 AD #tossbitum3     s                   like($itum3)
500 AD #tossbitumq3    s                   like($itumq3)

500 AD $aprg           s                   like($pprg)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D ajqty1          s              5  0
     D ajqty2          s              5  0
     D ajqty3          s              5  0
500 AD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
500 MD error           s               n
     D excode          s              1
     D forever         s               n
     D help            s              5  0
500 AD kyitem          s                   like($ititem)
500 AD kystat          s              1
500 AD kytrn#          s                   like(lbtrn#)
500 AD kyuci           s                   like(ucinbr)
500 AD kywhdp          s                   like($itwhdp)
500 AD kywhse          s                   like($itwhse)
     D msgk            s              4  0
     D nsctr           s              1  0
     D nxtscr          s              3
     D ovrrid          s              1
     D pdisp           s                   like(uisdsp)
     D pwhdp           s                   like(uiswhd)
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D scode           s              2
500a D slchk           s              1
500 AD ssbflg          s               n
500a D svitem          s                   like(w2item)
500a D svdisp          s                   like(uisdsp)
500b D swgt2           s              7  2
500b D totqty          s              7  0
     D vflag           s              1
     D warn            s              1
500b D wkcode          s              8
500b D wkwhse          s                   like($lwhse)
     D woidte          s              8  0
     D woqt01          s              5  0
     D woqt02          s              3  0
     D woqt03          s              3  0
500b D wtchk           s              1
500 AD zmsflag         s               n
     *----------------------------------------------------------------
500b I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     *
     * Data structure
     *
500b D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
500b D  optend               117    117
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   eval      vflag = *off
     *
510cDC*                  call      'BFCADR'
510cDC*                  parm                    $rtn              8
510cDC*                  if        $rtn = '*EXPIRED'
510cDC*                  eval      nxtscr = 'EOJ'
510cDC*                  else
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
510cDC*                  endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      zzzdriclose
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn1sp                              50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn2sp                              50
     C                   other
     C                   exfmt     screen2                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '03 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn3sp                              50
     C                   other
     C                   exfmt     screen3                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '04 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn4sp                              50
     C                   other
     C                   exfmt     screen4                              50
     C                   endsl
     C                   endif
     C                   if        nxtscr = '05 '
     C                   select
     C                   when      e$lng = 'SP'
     C                   exfmt     scrn5sp                              50
     C                   other
     C                   exfmt     screen5                              50
     C                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       929398
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
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     C                   exsr      zzfil5
     C                   eval      refrsh = *off
     C     end05i        endsr
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
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      *in20 = *off
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
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
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      zzinz2
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
     C     redspl        cabeq     *on           endsc2
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
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr03i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C*                  goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  eval      refrsh = *off
     C*                  exsr      scr04i
     C*                  goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*    DRI0001  Local system caused error
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

500 A*----------------------------------------------------------------
500 A*    DRI0001s Local system caused error (send to different program)
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *      0105s
     *
     C     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *      0110
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   LP11022  Licnese not on file.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'LP11022'
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
     *   PIR0204  Enter only one value.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm05          begsr
     C                   eval      #msgid = 'PIR0205'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1008  Date can't be blank.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV21203  Pending quantity, can not count
     *
     C     zm1203        begsr
     C                   eval      #msgid = 'IV21203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV21305  Not catch weight item
     *
     C     zm1305        begsr
     C                   eval      #msgid = 'IV21305'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV21307  UCI already entered.
     *
     C     zm1307        begsr
     C                   eval      #msgid = 'IV21307'
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
     *   IV33003  Slot already entered.
     *
     C     zm3003        begsr
     C                   eval      #msgid = 'IV33003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *    Make sure WHSE was entered.
     *
     C                   if        w1whse = *zero
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(1)     errmsg
500eAC                   other
     C                   movel     desc(1)       errmsg
500eAC                   endsl
     C                   exsr      zm03
     C                   endif
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
     *    Make sure DATE was entered.
     *
     C                   if        w1idte = *zero
     C                   eval      error = *on
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(2)     errmsg
500eAC                   other
     C                   movel     desc(2)       errmsg
500eAC                   endsl
     C                   exsr      zm1008
     C                   endif
     *
     *
     *     Verify date
     *
     C                   eval      $cvcmd = '*MDYEDT '
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
     C                   eval      #msgk = $cvmsg
     C                   eval      erdate = w1idte
     C                   exsr      zm9906
     C                   else
     C                   eval      w1idte = $cvd6o
     *   Convert date and save.
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1idte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      woidte = $cvd8o
     C                   endif
     C                   endif
     *
     *    Make sure Team was entered.
     *
     C                   if        w1team = *blanks
     C                   eval      error = *on
     C                   eval      *in04 = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
     C                   movel     desc(3)       errmsg
500eAC                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify team.
     C                   if        not *in22
     C     vtkey         setll     invteam
     C     vtkey         reade     invteam                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(3)     errmsg
500eAC                   other
     C                   movel     desc(3)       errmsg
500eAC                   endsl
     C                   exsr      zm3001
     C                   endif
     C                   endif
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *    Make sure Item was entered.
     *
     C                   if        w2item = *blanks
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descSP(5)     errmsg
500eAC                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify item
    A
    A*  Use DRI interface to get item.
    A
    AC                   exsr      clr$item
    AC                   eval      $itwhse  = w1whse
    AC                   eval      $ititem  = w2item
    A
    AC                   eval      $dricommand = '*ITEM'
    AC                   eval      $drisubcmd  = '%GETMAIN'
    AC                   eval      $drisys2upd = 'D'
    AC                   eval      chk4err = *on
    AC                   eval      zmsflag = *off
    AC                   exsr      zzzdricop
    AC                   if        error
    AC                   eval      $itdesc = 'ITEM NOT FOUND'
500 AC                   endif
500 AC                   eval      #toititem = $ititem
500 AC                   eval      #toittype = $ittype
500 AC                   eval      #toitdesc = $itdesc
500 AC                   eval      #toitpdsc = $itpdsc
500 AC                   eval      #toitwhdp = $itwhdp
500 AC                   eval      #toitstyp = $itstyp
500 AC                   eval      #toitdesg = $itdesg
500 AC                   eval      #toitum1  = $itum1
500 AC                   eval      #toitflg1 = $itflg1
500 AC                   eval      #toitum2  = $itum2
500 AC                   eval      #toitumq2 = $itumq2
500 AC                   eval      #toitflg2 = $itflg2
500 AC                   eval      #toitum3  = $itum3
500 AC                   eval      #toitumq3 = $itumq3
500 AC                   eval      #toitnrpk = $imnrpk
500 AC                   eval      #toitflgd = $itflgd
500 AC                   eval      #toitcube = $itcube
500 AC                   eval      #toitswgt = $itswgt
500 AC                   eval      #toitcwgt = $itcwgt
500 AC                   eval      #toitmitem = $itmitem
500 AC                   eval      kywhse = $itwhse
500 AC                   eval      kywhdp = $itwhdp
500 AC                   eval      kyitem = $ititem
500 A
500 A*  Use DRI interface to get corresponding SSB item, if any.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = w1whse
500 AC                   eval      $ititem  = w2item
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETSSB'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      chk4err = *off
500 AC                   eval      zmsflag = *off
500 AC                   exsr      zzzdricop
500 AC                   if        $drireturn = 'SSBNOTFND'
500 AC                   eval      ssbflg  = *off
500 AC                   eval      #tossbititem = ' '
500 AC                   eval      #tossbittype = ' '
500 AC                   eval      #tossbitdesc = ' '
500 AC                   eval      #tossbitpdsc = ' '
500 AC                   eval      #tossbitwhdp = ' '
500 AC                   eval      #tossbitstyp = ' '
500 AC                   eval      #tossbitdesg = ' '
500 AC                   eval      #tossbitum1  = ' '
500 AC                   eval      #tossbitum2  = ' '
500 AC                   eval      #tossbitumq2 = 0
500 AC                   eval      #tossbitum3  = ' '
500 AC                   eval      #tossbitumq3 = 0
500 AC                   else
500 AC                   eval      ssbflg  = *on
500 AC                   eval      #tossbititem = $ititem
500 AC                   eval      #tossbittype = $ittype
500 AC                   eval      #tossbitdesc = $itdesc
500 AC                   eval      #tossbitpdsc = $itpdsc
500 AC                   eval      #tossbitwhdp = $itwhdp
500 AC                   eval      #tossbitstyp = $itstyp
500 AC                   eval      #tossbitdesg = $itdesg
500 AC                   eval      #tossbitum1  = $itum1
500 AC                   eval      #tossbitum2  = $itum2
500 AC                   eval      #tossbitumq2 = $itumq2
500 AC                   eval      #tossbitum3  = $itum3
500 AC                   eval      #tossbitumq3 = $itumq3
500 AC                   eval      kywhse = $itwhse
500 AC                   eval      kywhdp = $itwhdp
500 AC                   eval      kyitem = $ititem
500 AC                   endif
416bA*
500aA*   Item must be catch weight item.
     *
500 AC                   if        #toitcwgt <> 'Y'
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
500eAC                   select
500eAC                   when      e$lng = 'SP'
500eAC                   movel     descsp(5)     errmsg
500eAC                   other
     C                   movel     desc(5)       errmsg
500eAC                   endsl
     C                   exsr      zm1305
     C                   endif
     *
     *  Error if pending quantity found.
     C     slkey4        setll     slot4
     C                   dow       forever = forever
     C     slkey4        reade     slot4
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slalc1 <> 0 or
     C                             slalc2 <> 0 or
     C                             slalc3 <> 0 or
     C                             sltfr1 <> 0 or
     C                             sltfr2 <> 0 or
     C                             sltfr3 <> 0 or
     C                             slpck1 <> 0 or
     C                             slpck2 <> 0 or
     C                             slpck3 <> 0 or
     C                             slrcv1 <> 0 or
     C                             slrcv2 <> 0 or
     C                             slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(5)     errmsg
     C                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm1203
     C                   leave
     C                   endif
     C                   iter
     C                   enddo
     *
     C     error         cabeq     *on           endck2
500aA*
500aA*   Save screen fields.
500aAC                   move      w2item        svitem
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     *  Verify slot was selected to be checked for item
     *
     C     uiskey2       chain(n)  uiislot2                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C     '"'           cat       w3disp        errmsg
     C     errmsg        cat       '"':0         errmsg
     C                   exsr      zm3002
     C                   else
     *  Verify slot has not been entered.
     C                   if        uisedt <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(4)     errmsg
     C                   other
     C                   movel     desc(4)       errmsg
     C                   endsl
     C                   exsr      zm3003
     C                   endif
     C                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     *
     *  Enter only one, either UCI or license
     C                   if        w4uci <> *blanks and
     C                             w4lcn <> *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      *in28 = *on
     C                   exsr      zm04
     C                   endif
     *  Must enter one, either UCI or license
     C                   if        w4uci = *blanks and
     C                             w4lcn = *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      *in28 = *on
     C                   exsr      zm05
     C                   endif
     *  Verify license has UCI's.
     C                   if        w4lcn <> *blanks
     C     ucikey2       chain     ucicw2                             79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   exsr      zm022
     C                   endif
     C                   endif
     *  Check if UCI has already been scanned.
     C                   eval      kyuci = w4uci
     C     uiikey        chain(n)  uiiuci                             79
     C                   if        %found
     C                   if        uiuedt <> *zero
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   exsr      zm1307
     C                   endif
     C                   endif
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     *
     *
     *
     C     endck5        endsr
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
     *     Warehouse.
     *
     C                   when      row# = 3
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
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
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
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
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
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
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm4
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F8 - No more UCI in slot.
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     *  Update UIISLOT status and count.
     C     uiskey2       chain     uiislot2                           79
     C                   if        *in79 = *off
     C                   select
     C                   when      #toittype = ' '
     C                   eval      uisct1 = totqty
     C                   other
     C                   eval      uisct2 = totqty
     C                   endsl
     C                   eval      uissta = '3'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      uisedt = $cvd8o
     C                   time                    uisetm
     C                   eval      uiseby = ivttem
     C                   update    uisrc2                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endcm4
     C                   endif
     C                   endif
     *
     *  Get next slot item is in.
     C     uiskey        setll     uiislot
     C                   dow       forever = forever
     C     uiskey        reade(n)  uiislot

     C                   if        %eof
     C                   exsr      scr05i
     C                   leave
     C                   else
     C*                  if        %found
     C                   if        uissta = '3'
     C                   iter
     C                   endif
     C                   exsr      scr03i
     C                   leave
     C                   endif
     C                   enddo
     C                   endif
     *
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
500bA*----------------------------------------------------------------
     *
500bA*  ZZCMD5   User defined command keys for screen 5.
     *
500bAC     zzcmd5        begsr
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
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm5
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
500bAC     endcm5        endsr
500bA*----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Create Exception record.
     *
     C     zzexcp        begsr
     *
     C                   eval      uiewhs = uiswhs
     C                   eval      uiedsp = uisdsp
     C                   eval      uieuci = kyuci
     C                   eval      uiesta = '1'
     C                   eval      uieitm = uisitm
     C                   eval      uiewhd = uiswhd
     C                   eval      uieasl = uisasl
     C                   eval      uieloc = uisloc
     C                   eval      uielvl = uislvl
     C                   eval      uiehnd = uishnd
     C                   eval      uiestp = uisstp
     C                   eval      uieecd = '1'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      uieedt = $cvd8o
     C                   time                    uieetm
     C                   eval      uieeby = ivttem
     C                   write     uierec                               79
     C                   if        %error
     C*                  eval      error = *on
     C*                  exsr      zm71
     C                   goto      endexc
     C                   endif
     C     endexc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     C                   eval      w1team = *blanks
     C                   eval      w1idte = *zeros
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2item = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   eval      w3tosl = *blanks
     C                   eval      w3disp = *blanks
     *

     *  Initialize screen fields.
     *   Get item description.

     C                   movel     #toitdesc     w3itm1
     C                   move      #toitdesc     w3itm2
     C                   eval      w3itm3 = #toitpdsc

     *  Get next slot item is in.
     C                   eval      w3tosl = *blanks
     C     uiskey        setll     uiislot
     C                   dow       forever = forever
     C     uiskey        reade(n)  uiislot

     C                   if        %eof
     C                   leave
     C                   else
     C*                  if        %found
     C                   if        uissta > '1'
     C                   iter
     C                   endif
     C                   eval      w3tosl = uisdsp
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     *
     *   Initialize entry fields
     *
     C                   eval      w4uci = *blanks
     C                   eval      w4lcn = *blanks
     *
     C                   endsr
500b *----------------------------------------------------------------
     *
500bA*  ZZFIL5   Fill screen 5 fields with info from file.
     *
500bAC     zzfil5        begsr
     *
     *   Initialize entry fields
     *
     *
500bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *     INVLOCK file -
     C     lockey        klist
     C                   kfld                    uiswhs
     C                   kfld                    uisitm
     C                   kfld                    uisdsp
     *     SLOT2 file -
     C     slkey2        klist
     C                   kfld                    uiswhs
     C                   kfld                    uiswhd
     C                   kfld                    uisdsp
     *     SLOT4 file -
     C     slkey4        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kyitem
     *
     *     UCICW file -
     C     ucikey        klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem
     *     UCICW2 file -
     C     ucikey2       klist
     C                   kfld                    kywhse
     C                   kfld                    w4lcn
     *
     *     UIIEXCP file - partial key
     C     uiekey        klist
     C                   kfld                    kywhse
     C                   kfld                    kystat
     C                   kfld                    kyitem
     *     UIISLOT file - partial key
     C     uiskey        klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem
     C*                  kfld                    $itwhse
     C*                  kfld                    $ititem
     *
     *     UIISLOT2 file -
     C     uiskey2       klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    w3disp
     *
     *     UIIUCI file -
     C     uiikey        klist
     C                   kfld                    kywhse
     C                   kfld                    kyuci
     *
500b *     OPTIONS file
500b C     opkeys        klist
500b C                   kfld                    wkwhse
500b C                   kfld                    wkcode
     *
     *
     *  Define partial key for INVTEAM file.
     *
     C     vtkey         klist
     C                   kfld                    w1whse
     C                   kfld                    woidte
     C                   kfld                    w1team
     *
     C*  Convert today's date into century format.
     C*
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   z-add     $cvd8o        curdte            8 0
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500eA*
500eA*   Get employee options.
500eA*
500eAC                   call      'GETUSER'
500eAC                   parm      #user         e$code           10
500eAC                   parm                    e$whse            3 0
500eAC                   parm                    e$emp#            5 0
500eAC                   parm                    e$fnam           15
500eAC                   parm                    e$init            1
500eAC                   parm                    e$lnam           20
500eAC                   parm                    e$whdp            5
500eAC                   parm                    e$styp            1
500eAC                   parm                    e$shft            6
500eAC                   parm                    e$crew            6
500eAC                   parm                    e$nhrs            3 1
500eAC                   parm                    e$rtn             8
500eAC                   parm                    e$bpu             1
500eAC                   parm                    e$lng             2
500eAC                   if        e$rtn <> '*OK'
500eAC                   eval      e$lng = 'EN'
500eAC                   endif
500eA*
416bAC                   eval      worow = *zeros
416bAC                   eval      wocol = *zeros
500b *   Get options
500b C                   exsr      zzoptn
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
500bA*----------------------------------------------------------------
     *
500bA*  ZZOPTN   Get options
     *
500b C     zzoptn        begsr
     *
500b *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   endif
     C*
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to parameter fields.
     *
     C                   eval      $pwhse = w1whse
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *   Convert date and save.
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1idte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      woidte = $cvd8o
     *
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     *
     *  Clear item records from lock, UIISlot, UIIExcp, UIIuci files
     C                   exsr      zzuall
     *  Write all item slots to file and lock file
     C                   exsr      zzuslt
     *
     *  Write all item UCI's to file.
     C                   exsr      zzuci
     *
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      totqty = 0
     *  Set UIISLOT status to started.
     C     uiskey2       chain     uiislot2                           79
     C                   if        *in79 = *off
     C                   eval      uissta = '2'
     C                   update    uisrc2                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   endif
     *
     C                   exsr      scr04i
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      scode = '  '
500 A
     C                   select
500 A*    Get all UCI for license.
     C                   when      w4lcn <> *blanks
     C     ucikey2       setll     ucicw2
     C                   dow       forever = forever
     C     ucikey2       reade     ucicw2                                 77

     C                   if        %eof
     C                   leave
     C                   else
     C*                  if        %found
     C                   eval      kyuci = ucinbr
     C     uiikey        chain     uiiuci                             79
     C                   if        %found
     C                   if        uiuitm = kyitem and
     C                             uiuedt = *zero
     C                   add       1             totqty
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      uiuedt = $cvd8o
     C                   time                    uiuetm
     C                   eval      uiueby = ivttem
     C                   eval      uiudsp = uisdsp
     C                   update    uiurec                               79
     C                   iter
     C                   else
     C                   iter
     C                   endif
     *
     C                   else
     * write exception
     C                   exsr      zzexcp
     C                   iter
     C                   endif
     C                   iter
     C                   endif
     C                   enddo
500  C*
     * One UCI entered.
     C                   when      w4uci <> *blanks
     C                   eval      kyuci = w4uci
     C     uiikey        chain     uiiuci                             79
     C                   if        %found
     C                   if        uiuitm = kyitem and
     C                             uiuedt = *zero
     C                   add       1             totqty
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      uiuedt = $cvd8o
     C                   time                    uiuetm
     C                   eval      uiueby = ivttem
     C                   eval      uiudsp = uisdsp
     C                   update    uiurec                               79
     C                   endif
     *
     C                   else
     * write exception
     C                   exsr      zzexcp
     C**                 add       1             totqty
     C                   endif
     C                   other
     C                   endsl
500bA*
     * re-display screen4 for next UCI or F8 Done
     C                   exsr      scr04i
500bA*
     C     endup4        endsr
500bA*----------------------------------------------------------------
500b *
500bA*  ZZUPD5   Update for screen 5.
500b *
500bAC     zzupd5        begsr
     C                   eval      error = *off
     C                   eval      ovrrid = *off
     C                   eval      refrsh = *on
500bA*  Create label and adjustment.
     C                   exsr      zzpost
500bA*  Post UCI as Deleted or still on dock
     C                   exsr      zzpuci
     C                   exsr      scr02i
500bA
500bAC     endup5        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOST   Write Label and ITEMADJ records, update slot and itemqty
     *
     C     zzpost        begsr
     C     uiskey        setll     uiislot
     C                   dow       forever = forever
     C     uiskey        reade     uiislot

     C                   if        %eof
     C                   leave
     C                   else
     C*                  if        %found
     C                   eval      ajqty1 = 0
     C                   eval      ajqty2 = 0
     C                   eval      ajqty3 = 0
     C                   eval      ajqty1 = uisct1 - uisqt1
     C                   eval      ajqty2 = uisct2 - uisqt2
     C                   eval      ajqty3 = uisct3 - uisqt3
     C     slkey2        chain     slot2                              78
     C                   if        *in78 = *off
     C                   eval      slstk1 = slstk1 + ajqty1
     *   Check if status needs to be changed
     *
     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
530aAC                   parm                    sldesg
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnews            2
     C                   parm                    $crtn             8
     *
     C                   if        $crtn = '*CHANGED'
     C                   eval      slstat = $cnews
     C                   time                    slstim
     C                   eval      slsdte = curdte
     C                   endif
     C                   update    slrec                                78
     C                   endif
     *
     C                   eval      iawhse = uiswhs
     C                   eval      iaitem = uisitm
     C                   eval      iadate = curdte
     C                   time                    iatime
     C                   eval      iaby = ivttem
     C                   eval      iawhdp = uiswhd
     C                   eval      iadisp = uisdsp
     C                   eval      iaqty1 = ajqty1
     C                   eval      iaqty2 = ajqty2
     C                   eval      iaqty3 = ajqty3
     C                   eval      iacode = 'UC'
     C                   write     iarec
412 AC*    Create label rec for inventoried item.
     C                   eval      lbwhse = slwhse
     C                   eval      lbitem = slitem
     C                   eval      lbwhdp = slwhdp
     C                   eval      lbdisp = sldisp
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbseq = 0
     C                   eval      lbpbat = 0
     C                   eval      lbpo = *blanks
     C                   eval      lbord = 0
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = *blanks
     C                   eval      lbqalc = 0
     C                   eval      lbucub = 0
     C                   eval      lbcube = 0
     C                   eval      lbuwgt = 0
     C                   eval      lbswgt = 0
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     C                   eval      lbtrn# = 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbtype = 'A'
     C                   eval      lbqpck = ajqty1
     C                   eval      lbgrp1 = *blanks
     C                   eval      lbgrp2 = *blanks
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = curdte
     C                   time                    lbstim
     C                   eval      lbrdte = curdte
     C                   write     lbrec
     * Update general quantities for item.
     C                   eval      $acmd = '*STOCK  '
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     C                   eval      $aqty1 = ajqty1
     C                   eval      $aqty2 = ajqty2
     C                   eval      $aqty3 = ajqty3
     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
     C                   parm                    $apgm            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm            60
     *  Update UIISLOT status and posted date/time
     C                   eval      uissta = '3'
     C                   time                    uisptm
     C                   eval      uispdt = curdte
     C                   update    uisrec                               79
     *  Remove record from lock file
     C     lockey        chain     invlock                            79
     C                   if        %found
     C                   delete    ilkrec
     C                   if        %error
     C                   iter
     C                   endif
     C                   endif
     C                   iter
     C                   endif
     C                   enddo
500bAC     endpst        endsr
     *----------------------------------------------------------------
      *
     *  ZZPUCI   Post UCI as Deleted or still on dock
     *
     C     zzpuci        begsr
     C     ucikey        setll     uiiuci2
     C                   dow       forever = forever
     C     ucikey        reade     uiiuci2

     C                   if        %eof(uiiuci2)
     C                   leave
     C                   else
     C                   if        uiuedt = 0
     C                   eval      kywhse = uiuwhs
     C                   eval      kyuci = uiuuci
     C     uiikey        chain     ucicw                              78
     C                   if        *in78
     C                   iter
     C                   endif
     C                   if        ucirts = 'Y'
     C                   eval      kytrn# = ucirtt
     C                   else
     C                   eval      kytrn# = ucirct
     C                   endif
     C     kytrn#        chain     pirtran                            77
     C                   if        *in77
     C                   eval      uiuedt = curdte
     C                   time                    uiuetm
     C                   eval      uiudsp = 'ERROR       '
     C                   eval      uiueby = ivttem
     C                   update    uiurc2                               79
     C                   unlock    ucicw
     C                   iter
     C                   endif
     C                   if        ptstat = '1' or
     C                             ptstat = '2'
     C                   eval      uiuedt = curdte
     C                   time                    uiuetm
     C                   eval      uiudsp = 'DOCK        '
     C                   eval      uiueby = ivttem
     C                   update    uiurc2                               79
     C                   unlock    ucicw
     C                   iter
     C                   else
     C*                  unlock    uiiuci2
     C                   eval      uiuedt = curdte
     C                   time                    uiuetm
     C                   eval      uiudsp = 'DELETE      '
     C                   eval      uiueby = ivttem
     C                   update    uiurc2                               79
     C                   eval      ucists = 'D'
     C                   update    ucirec                               79
     C                   eval      uawhse = uciwhs
     C                   eval      uainbr = ucinbr
     C                   eval      uacode = 'D'
     C                   eval      uarscd = 'UC'
     C                   eval      uaapgm = #prog
     C                   eval      uatype = 'I'
     C                   eval      uaoitm = uciitm
     C                   eval      uanitm = uciitm
     C                   eval      uaowgt = uciwgt
     C                   eval      uanwgt = uciwgt
     C                   eval      uadate = curdte
     C                   time                    uatime
     C                   write     uacrec
     C                   iter
     C                   endif
     C                   endif
     C                   endif
     C                   iter
     C                   enddo
500bAC     endpuc        endsr
     *
     *  ZZUALL   Clear records for item from files.
     *
     C     zzuall        begsr
     C     ucikey        setll     uiislot
     C                   dow       forever = forever
     C     ucikey        reade     uiislot

     C                   if        %eof
     C                   leave
     C                   else
     C*                  if        %found
     C                   delete    uisrec
     C                   iter
     C                   endif
     C                   enddo
     *  delete item from lock file.
     C     ucikey        setll     invlock
     C                   dow       forever = forever
     C     ucikey        reade     invlock

     C                   if        %eof
     C                   leave
     C                   else
     C                   delete    ilkrec
     C                   iter
     C                   endif
     C                   enddo
     *  delete item from uiiuci file
     C     ucikey        setll     uiiuci2
     C                   dow       forever = forever
510bMC     ucikey        reade     uiiuci2
510bDC*    ucikey        reade     uiurc2

     C                   if        %eof
     C                   leave
     C                   else
     C                   delete    uiurc2
     C                   iter
     C                   endif
     C                   enddo
     C*
     *  delete item from uiiexcp file
     C                   eval      kystat = '2'
     C     uiekey        setll     uiiexcp
     C                   dow       forever = forever
     C     uiekey        reade     uiiexcp

     C                   if        %eof
     C                   leave
     C                   else
     C                   delete    uierec
     C                   iter
     C                   endif
     C                   enddo
     C*

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUCI    Write UCI to UIIUCI file
     *
     C     zzuci         begsr
     C     ucikey        setll     ucicw3
     C                   dow       forever = forever
     C     ucikey        reade     ucicw3

     C                   if        %eof
     C                   leave
     C                   else
     C*                  if        %found
     C                   eval      uiuwhs = uciwhs
     C                   eval      uiuuci = ucinbr
     C                   eval      uiuitm = uciitm
     C                   eval      uiucdt = $cvd8o
     C                   time                    uiuctm
     C                   write     uiurec                               79
     C                   if        %error
     C                   leave
     C                   endif
     C                   iter
     C                   endif
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZUPDI   Update INVSLOT with entered date & time
     *
     C     zzupdi        begsr
     C*                  if        scode <> *blanks
     C*                  eval      ivssta = scode
     C*                  endif
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupi
     C                   endif
     C     endupi        endsr
     *
500 A*----------------------------------------------------------------
     *
     *  ZZUSLT   Write Slots to UCISLOT file
     *
     C     zzuslt        begsr
     C     slkey4        setll     slot4
     C                   dow       forever = forever
     C     slkey4        reade     slot4

     C                   if        %eof
     C                   leave
     C                   else
     C*                  if        %found
     C                   eval      uiswhs = slwhse
     C                   eval      uisdsp = sldisp
     C                   eval      uissta = '1'
     C                   eval      uiswhd = slwhdp
     C                   eval      uisasl = slaisl
     C                   eval      uisloc = slloc
     C                   eval      uislvl = slrlvl
     C                   eval      uishnd = slhand
     C                   eval      uisstp = slstyp
     C                   eval      uisitm = slitem
     C                   eval      uisqt1 = slstk1
     C                   eval      uisqt2 = slstk2
     C                   eval      uisqt3 = slstk3
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      uiscdt = $cvd8o
     C                   time                    uisctm
     C                   write     uisrec                               79
     C                   if        %error
     C                   leave
     C                   endif
     *  write item to lock file.
     C                   eval      ilkwhs= w1whse
     C                   eval      ilkwhd = slwhdp
     C                   eval      ilkitm = slitem
     C                   eval      ilkdsp = sldisp
     C                   eval      ilkasl = slaisl
     C                   eval      ilkloc = slloc
     C                   eval      ilklvl = slrlvl
     C                   eval      ilkhnd = slhand
     C                   eval      ilkstp = slstyp
     C                   eval      ilkpgm = #pgm
     C                   eval      ilkdte = $cvd8o
     C                   time                    ilktim
     C                   write     ilkrec                               79
     C                   if        %error
     C                   leave
     C                   endif

     C                   iter
     C                   endif
     C                   enddo

     C                   endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slot  Clear $slot data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdriclose   Close any open files or programs.
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*  License Plate Tracking Routines
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  ZZZCLR$LT210  -  Clear LT210 parameters.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

417c *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Warehouse
Date
Team
Slot
Item
Weight
** DESCSP
Almacen
Fecha
Equipo
Slot
Prdc.
Weight
