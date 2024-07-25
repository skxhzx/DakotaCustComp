      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR299     RF single order select SOS Utility
     *  20 December 2005
     *  Roxanne Harrison
     *
     *  Revisions
     *
416 A*    12/20/05  RH   5.00
     *      - Created using OR200 to stage SOS hanging in WORKSOS file
     *
640aA*    07/05/11  DAS  6.40a
     *      - Updated using latest methods.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Vigo Importing
     *
CHT A*    01/12/05  CHT  Modified to include pallet labels (barcode)
     *        w/ permission of Max Blacknik of BFC.
     *        Changes flagged with "vgo-a" at end of record (col 96).
VGObA*    10/31/05  RH   VGOb
     *      - Add PIRPLCN for next pallet license #.
     *      - Default stage location to AA-001-1.
     *      - Default pallet license to stage.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     For299fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Frtehed    uf a e           k disk    infds(file1ds)
416cDF*abel     uf   e           k disk
416cMFlabel     uf a e           k disk
416cMFlabel90   if   e           k disk
417g F                                     rename(lbrec:lbrec9)
416cMFpirtran   if   e           k disk
     Fordc      uf a e           k disk
     Fordl      o  a e           k disk
     Fpltsum2   uf a e           k disk
CHT  F*llablhst if a e           k disk    usropn
CHT  F*llabldrv o  a e           k disk    usropn
500aAFworksos2  uf a e           k disk
500aAFworksos1  if   e           k disk
417g F                                     rename(wksrec:wksrec1)
500aAFslot2     if   e           k disk

500e *----------------------------------------------------------------
500e *  Client ID's for custom mods
500e *----------------------------------------------------------------
500eAD @getcl          c                   const('GETCLIENT')
500e  /copy *libl/qcopysrc,id#vigo
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#ORDH
      /COPY *libl/qcopysrc,C#ORDD
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
416gAD $iitem          s                   like(lbitem)
416gAD $idesc          s                   like($itdesc)
416gAD $ipdsc          s                   like($itpdsc)
CHT  D*$pvord          s                   like(plordn)
416gAD $istr           s             70
     D $pbat           s              7  0
     D $poid           s              7  0
     D $ptrn#          s              7  0
     D $pwhse          s              3  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
416jAD availqty        s              9  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curdate         s              8  0
     D curtime         s              6  0
     D e               s              2  0
     D enter           s              5  0
     D errcode         s             10
     D error           s               n
     D forevr          s               n   inz(*on)
     D help            s              5  0
     D i               s              5  0
416b D lastitem        s                   like(lbitem)
416b D lastseq         s                   like(lbord)
     D lasttime        s              6  0 inz(999999)
     D licpick         s               n
     D listorder       s              4
     D msgk            s              4  0
     D nxtscr          s              3
640aAD origLcns        s             15
     D ovrrid          s              1
416hAD picked          s              7  0
     D pickcount       s              5  0
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D totalcube       s                   like(pscube)
     D totalpcs        s                   like(pspcs)
     D totalswgt       s                   like(psswgt)
     D warn            s              1
500a D svswhd          s                   like(wkswhd)
500d D pliccount       s              3  0
500d D stagcount       s              3  0
500d D kyplic          s              7  0

640aA*----------------------------------------------------------------
640aA*  LT210 parameters
640aA*----------------------------------------------------------------

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
     D  wkType         s              3    INZ('TFR')

     *----------------------------------------------------------------
     *  Catchweight Multiple-Occurence Data Structure
     *----------------------------------------------------------------

     D #cwmax          s              5  0 inz(100)
     D #cwprev         s              5  0

     D #cwentries      ds                  occurs(100)
     D  #cwentry                     50
     D  #cwweight                     7  3 inz(0)

     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *----------------------------------------------------------------

     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

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
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $lord                 22     28  0
     D  $lseq                 29     33  0
     D  $litem                34     48
     D  $lrtid                49     53
     D  $lpbat                54     60  0
     D  $llbl#                61     67  0
     *
416aAD  $lwhs2                19     21  0
416aAD  $litm2                22     36
416aAD  $lwhd2                37     41
416aAD  $ldsp2                42     53

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
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D  err01          c                   'Order not found'

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '06 '         sc6
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
   x C                   write     clrscr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   exfmt     screen61                             50
 2X  C                   other
     C                   exfmt     screen1                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '02 '
 2B  C                   select
 2X  C                   when      #lline = '16'
     C**                 exfmt     screen62                             50
 2X  C                   other
     C**                 exfmt     screen2                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '03 '
 2B  C                   select
 2X  C                   when      #lline = '16'
     C**                 exfmt     screen63                             50
 2X  C                   other
     C**                 exfmt     screen3                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '04 '
 2B  C                   select
 2X  C                   when      #lline = '16'
     C**                 exfmt     screen64                             50
 2X  C                   other
     C**                 exfmt     screen4                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '05 '
 2B  C                   select
 2X  C                   when      #lline = '16'
     C**                 exfmt     screen65                             50
 2X  C                   other
     C**                 exfmt     screen5                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '06 '
VGOb c     Client        ifeq      vigo
CHT  c   41              exsr      zin41i
VGOb c                   endif
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   exfmt     screen66                             50
 2X  C                   other
     C                   exfmt     screen6                              50
 2E  C                   endsl
VGOb c     Client        ifeq      vigo
CHT  c   41              exsr      zin41o
VGOb c                   endif
 1E  C                   endif
 1B  C                   if        nxtscr = '07 '
     C**                 exfmt     screen7                              50
 1E  C                   endif
 1B  C                   if        nxtscr = '08 '
VGOb c     Client        ifeq      vigo
CHT  c   41              exsr      zin41i
VGOb c                   endif
 2B  C                   select
 2X  C                   when      #lline = '16'
     C**                 exfmt     screen68                             50
 2X  C                   other
     C**                 exfmt     screen8                              50
 2E  C                   endsl
VGOb c     Client        ifeq      vigo
CHT  c   41              exsr      zin41o
VGOb c                   endif
 1E  C                   endif
     *
     *   Initialize error indicators and fields
     *
VGOb c     Client        ifeq      vigo
CHT  c                   movea     z40           *in(01)
     *c                   setoff                                       010203
     *c                   setoff                                       040506
     *c                   setoff                                       070809
     *c                   setoff                                       10
     *c                   setoff                                       111213
     *c                   setoff                                       141516
     *c                   setoff                                       171819
     *c                   setoff                                       20
     *c                   setoff                                       212223
     *c                   setoff                                       242526
     *c                   setoff                                       272829
     *c                   setoff                                       30
     *c                   setoff                                       313233
     *c                   setoff                                       343536
     *c                   setoff                                       373839
     *c                   setoff                                       40
VGOb c                   else
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
VGOb c                   endif
     C                   setoff                                       9298
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
     C                   move      '01 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil1
 1E  C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
500a C                   eval      *in01 = *on
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil2
 1E  C                   endif
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil3
 1E  C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil4
 1E  C                   endif
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   move      '05 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil5
 1E  C                   endif
     C                   move      *off          refrsh
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   move      '06 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil6
 1E  C                   endif
     C                   move      *off          refrsh
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   move      '07 '         nxtscr
 1B  C                   if        refrsh = *on
 1E  C                   endif
     C                   exsr      zzfil7
     C                   move      *off          refrsh
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   move      '08 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil8
 1E  C                   endif
     C                   move      *off          refrsh
     C     end08i        endsr
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
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr01i
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
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
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
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
 1B  C                   if        *inkc
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
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
     C                   move      '*AFTER  '    cmdchk
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
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr03i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
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
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr04i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
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
     C                   move      '*AFTER  '    cmdchk
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
 1B  C                   if        *inkc
     C****               move      'EOJ'         nxtscr
goto Csr                 goto      endsc5
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr05i
goto Csr                 goto      endsc5
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C****               exsr      scr02i
goto Csr                 goto      endsc5
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
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
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C                   exsr      scr01i
goto Csr                 goto      endsc6
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr06i
goto Csr                 goto      endsc6
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr01i
goto Csr                 goto      endsc6
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
goto Csr                 goto      endsc7
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr07i
goto Csr                 goto      endsc7
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
     *
     *R         *INKL     IFEQ *ON
     *R                   MOVE *OFF      REFRSH
     *R                   EXSR SCR03I
     *R                   GOTO ENDSC7
     *R                   ENDIF
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
     *----------------------------------------------------------------
     *
     *  SC8  -  Screen 8
     *
     C     sc8           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
416dDC**                 move      'EOJ'         nxtscr
416eDC**                 exsr      scr05i
416eAC                   eval      refrsh = *on
416eMC                   exsr      scr01i
goto Csr                 goto      endsc8
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr08i
goto Csr                 goto      endsc8
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
416dDC**                 exsr      scr03i
416eDC**                 exsr      scr05i
416eAC                   eval      refrsh = *on
416eMC                   exsr      scr01i
goto Csr                 goto      endsc8
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     C     endsc8        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500e *
500e *  Get client ID
500e *
500e C                   call      @getcl
500e C                   parm                    client           10
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
VGOb c     Client        ifeq      vigo
     c                   move      *all'0'       z40              40
     c                   move      *on           *in41
VGOb c                   endif
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
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16ctl
 1X  C                   other
     C                   write     msgctl
 1E  C                   endsl
     C                   eval      msgk = *zeros
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16clr
 1X  C                   other
     C                   write     msgclr
 1E  C                   endsl
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16ctl
 2X  C                   other
     C                   write     msgctl
 2E  C                   endsl
     C                   eval      msgk = *zeros
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16rec
 2X  C                   other
     C                   write     msgrec
 2E  C                   endsl
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16rec
 1X  C                   other
     C                   write     msgrec
 1E  C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001/2  Error returned from DRICOP.
     *----------------------------------------------------------------

     C     zm0001        begsr
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

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify warehouse.

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      w1whse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm0105
     C                   goto      endck1

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      errmsg = $vmessage
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm0105
     C                   goto      endck1

     C                   endsl

     *  Verify transaction #
     C     w1trn#        chain     pirtran                              78
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      errcode = 'TRNNOTFND'
     C                   exsr      zzdsperr
     C                   goto      endck1
     C                   endif

     *  Retreive order


     *  Get customer order #
500dAC     lbkey1        setll     label90
500d C     lbkey1        reade     label90                                79
500d C                   if        *in79 = *on
500d C                   move      *on           error
500d C                   eval      *in21 = *on
500d C                   eval      *in01 = *on
500d C                   eval      errmsg = 'Trans # invalid'
500d C                   exsr      zm0105
500d C     error         cabeq     *on           endck1
500d C                   endif
     *  Now get order header information.
      *
     C*                  eval      savever# = $ohver#
     C*                  clear                   $ordh
     C*                  eval      $ohver# = savever#
      *
     C*                  eval      $ohwhseu = *on
     C*                  eval      $ohwhse = w1whse
      *
     C*                  eval      $ohcordu = *on
     C*                  eval      $ohcord = w1ord
      *
     C*                  eval      $dricommand = '*ORD'
     C*                  eval      $drisubcmd  = '%GETHDRWCO'
     C*                  eval      $drisys2upd = 'D'
     C*                  exsr      zzzdricop
     C*                  if        error
     C*                  goto      endck1
     C*                  endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
     C                   eval      error = *off


     C     endck2        endsr

     *----------------------------------------------------------------
     *  ZZCHK3   Screen 3 error checking.
     *----------------------------------------------------------------

     C     zzchk3        begsr
     C                   move      *off          error

     C     endck3        endsr

     *----------------------------------------------------------------
     *  ZZCHK4   Screen 4 error checking.
     *----------------------------------------------------------------

     C     zzchk4        begsr
     C                   eval      error = *off
     C     endck4        endsr

     *----------------------------------------------------------------
     *  ZZCHK5   Screen 5 error checking.
     *----------------------------------------------------------------

     C     zzchk5        begsr
     C                   eval      error = *off
     C     endck5        endsr

     *----------------------------------------------------------------
     *  ZZCHK6   Screen 6 error checking.
     *----------------------------------------------------------------

     C     zzchk6        begsr
     C                   move      *off          error
500dA
500d ** Verify pallet license entered is valid.
500d C                   if        w6lic <> 0
500d C                   eval      kyplic = w6lic
500d C                   eval      kyplic = w6lic
500dAC     wskey         setll     worksos2
500d C     wskey         reade     worksos2                               79
500d C                   if        *in79 = *on
500d C                   move      *on           error
500d C                   eval      *in21 = *on
500d C                   eval      *in01 = *on
500d C                   eval      errmsg = 'License invalid'
500d C                   exsr      zm0105
500d C     error         cabeq     *on           endck6
500d C                   endif
500d C                   endif
416dA
416dA*  Verify stage entered.
416dA
416dAC                   if        w6stag = ' '
416dAC                   eval      error = *on
416dAC                   eval      *in21 = *on
416dAC                   eval      *in01 = *on
416dAC                   eval      errmsg = 'Stage not entered'
416dAC                   exsr      zm0105
500d C     error         cabeq     *on           endck6
416dAC                   endif

500a *  Verify scanned slot exists for each staged item department.
500aAC                   exsr      zzwhdp
500aAC     error         ifeq      *on
500aAC                   eval      *in21 = *on
500aAC                   eval      *in01 = *on
500aAC                   eval      errmsg = 'Slot not in dept'
500aAC                   exsr      zm0105
500a C     error         cabeq     *on           endck6
500a C                   endif

500a *  Verify item/qty can be putaway in stage slot.
500aAC                   exsr      zzsput
500aAC     error         ifeq      *on
500aAC                   eval      *in21 = *on
500aAC                   eval      *in01 = *on
500aAC*                  eval      errmsg = 'Slot not in dept'
500aAC*                  exsr      zm0105
500a C     error         cabeq     *on           endck6
500a C                   endif
     C     endck6        endsr

     *----------------------------------------------------------------
     *  ZZCHK7   Screen 7 error checking.
     *----------------------------------------------------------------

     C     zzchk7        begsr
     C                   eval      error = *off
     C     endck7        endsr

     *----------------------------------------------------------------
     *  ZZCHK8   Screen 8 error checking.
     *----------------------------------------------------------------

     C     zzchk8        begsr
     C                   eval      error = *off
     C     endck8        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
416aA
416aA*  Test for F4 - Lookup
416aA
416aA
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZCMD3   User defined command keys for screen 3.
     *----------------------------------------------------------------

     C     zzcmd3        begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm3        endsr

     *----------------------------------------------------------------
     *  ZZCMD4   User defined command keys for screen 4.
     *----------------------------------------------------------------

     C     zzcmd4        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm4        endsr

     *----------------------------------------------------------------
     *  ZZCMD5   User defined command keys for screen 5.
     *----------------------------------------------------------------

     C     zzcmd5        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm5        endsr

     *----------------------------------------------------------------
     *  ZZCMD6   User defined command keys for screen 6.
     *----------------------------------------------------------------

     C     zzcmd6        begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm6        endsr

     *----------------------------------------------------------------
     *  ZZCMD7   User defined command keys for screen 7.
     *----------------------------------------------------------------

     C     zzcmd7        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm7        endsr

     *----------------------------------------------------------------
     *  ZZCMD8   User defined command keys for screen 8.
     *----------------------------------------------------------------

     C     zzcmd8        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm8        endsr

     *----------------------------------------------------------------
     *  ZZCWINZ   Initialize catchweight data structure
     *----------------------------------------------------------------

     C     zzcwinz       begsr

     C                   do        #cwmax        i
     C     i             occur     #cwentries
     C                   reset                   #cwentries
     C                   enddo

     C                   endsr

416lA*----------------------------------------------------------------
416lA*  ZZCVTDT    Convert Date to correct format.
416lA*----------------------------------------------------------------
416lA
416lAC     zzcvdt        BegSr
416lA *
416lAC                   Call      @cvtdt
416lAC                   parm                    $cvtdt
416lAC     EndCvd        ENDSR

     *----------------------------------------------------------------
     *  ZZDSPERR   Display full screen error message.
     *----------------------------------------------------------------

     C     zzdsperr      begsr

     * Clear message lines.

     C                   eval      woln01 = ' '
     C                   eval      woln02 = ' '
     C                   eval      woln03 = ' '
     C                   eval      woln04 = ' '
     C                   eval      woln05 = ' '
     C                   eval      woln06 = ' '
     C                   eval      woln07 = ' '
     C                   eval      woln08 = ' '
     C                   eval      woln09 = ' '
     C                   eval      woln10 = ' '

     * Create message

     C                   select

     C                   when      errcode = 'LBLNOTFND'
     C                   eval      woln01 = '  Label record was'
     C                   eval      woln02 = '   not found for'
     C                   eval      woln03 = '   selected item'
     C                   eval      woln06 = '   Press Enter to'
     C                   eval      woln07 = '      continue'

     C                   when      errcode = 'LBLLOCKED'
     C                   eval      woln01 = '  Label record is'
     C                   eval      woln02 = '     locked by'
     C                   eval      woln03 = '    another user'
     C                   eval      woln06 = '   Press Enter to'
     C                   eval      woln07 = '      continue'

     C                   when      errcode = 'ZEROREMAIN'
     C                   eval      woln01 = 'Entire qty for item'
     C                   eval      woln02 = ' has already been'
     C                   eval      woln03 = '      picked'
416eMC                   eval      woln05 = '   Press Enter to'
416eMC                   eval      woln06 = 'continue         '

416jAC                   when      errcode = 'PCKGTAVAIL'
416jA*    Activate F10=Accept error function key.
416jAC                   eval      *in45  = *on
416jAC                   eval      woln01 = 'Pick qty greater   '
416jAC                   eval      woln02 = 'than available slot'
416jAC                   eval      woln03 = 'qty. Press         '
416jAC                   eval      woln05 = 'F10=Accept error to'
416jAC                   eval      woln06 = 'continue.        '

     C                   other
     C                   eval      woln05 = errcode

     C                   endsl

     * Display message

416eAC                   select
416eAC                   when      #lline = '16'
     C                   exfmt     screen69                             50
416eAC                   other
     C                   exfmt     screen9                              50
416eAC                   endsl
416jAC                   eval      *in45  = *off

     C                   endsr

416lA*----------------------------------------------------------------
416lA*  ZZEXCP Write item exception record to file.
416lA*----------------------------------------------------------------
416lA*
416lAC     ZZEXCP        BEGSR
416lA*
416lA*
416lAC     endexc        EndSr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     * Get User information.


     C                   eval      w1whse = 0
     C                   eval      w1user = *blanks
     C                   eval      w1trn# = 0
     C                   eval      woinf1 = ' '
     C                   eval      woinf2 = ' '

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2        begsr


     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil3        begsr

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil4        begsr

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil5        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil6        begsr
VGOb c     client        ifeq      vigo
CHT  c*                  if        *in41
CHT  c                   exsr      zin41i
VGOb c                   else
416dAC                   eval      w6stag = ' '
VGOb C                   endif
500d C*                  eval      wolctr = pliccount
500d C                   if        pliccount = 1
500d C                   eval      w6lic = kyplic
500d C                   else
500d C                   eval      w6lic = 0
500d C                   endif
VGOb c     client        ifeq      vigo
VGOb C                   eval      w6lic = kyplic
VGOb C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil7        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL8   Fill screen 8 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil8        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog

     *  Define key for RTEHED file

     C     keyrh         klist
     C                   kfld                    $ohwhse
     C                   kfld                    $ohrid

     *  Define partial key for ORDC file

     C     keyoc         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     C                   kfld                    lblbl#

     *  Define partial key for PLTSUM2 file

     C     keyps2        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
416dA
416dA*  Define full key for PLTSUM2 file
416dA
416dAC     keyps2f       klist
416dAC                   kfld                    pswhse
416dAC                   kfld                    psrtid
416dAC                   kfld                    pstype
416dAC                   kfld                    psgen
416dAC                   kfld                    psrow
416dAC                   kfld                    pscol

500aAC     wskey         klist
500aAC                   kfld                    w1whse
500aAC                   kfld                    w1trn#
500aAC                   kfld                    w1user
500dAC                   kfld                    kyplic

500dAC     wskey1        klist
500dAC                   kfld                    w1whse
500dAC                   kfld                    w1user

500dAC     wskey2        klist
500dAC                   kfld                    w1whse
500aAC                   kfld                    w1trn#
500dAC                   kfld                    w1user

500aAC     slkey2        klist
500aAC                   kfld                    w1whse
500aAC                   kfld                    wkswhd
500aAC                   kfld                    w6stag

500aAC     lbkey1        klist
500aAC                   kfld                    w1whse
500aAC                   kfld                    w1trn#

     C                   eval      #pgmq = #prog

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr
640aA*
640aA*   Get employee options.
640aA*
640aAC                   call      'GETUSER'
640aAC                   parm      #USER         E$CODE           10
640aAC                   parm                    E$WHSE            3 0
640aAC                   parm                    E$EMP#            5 0
640aAC                   parm                    E$FNAM           15
640aAC                   parm                    E$INIT            1
640aAC                   parm                    E$LNAM           20
640aAC                   parm                    E$WHDP            5
640aAC                   parm                    E$STYP            1
640aAC                   parm                    E$SHFT            6
640aAC                   parm                    E$CREW            6
640aAC                   parm                    E$NHRS            3 1
640aAC                   parm                    E$RTN             8
640aAC                   parm                    E$BPU             1
640aAC                   parm                    E$LNG             2
640aAC                   if        E$RTN <> '*OK'
640aAC                   eval      E$LNG = 'EN'
640aAC                   endif
640aA
     C                   setoff                                       kckl
     C                   move      *on           refrsh

     * Get screen size being used.

     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3

     * Force screen size to 16 lines.

416eDC**                 eval      #lline = '16'

     * Define item list to initially display by line #.

     C                   eval      listorder = 'LINE'

     * Display the first screen.

416bAC                   eval      lastitem = ' '
416bAC                   eval      lastseq  = 0
     C                   exsr      scr01i

     C                   endsr

     *----------------------------------------------------------------
     *  ZZLBL#   Get label record.
     *----------------------------------------------------------------

     C     zzlbl#        begsr
     C                   eval      error = *off

     *  Get label record.

     C     $llbl#        chain     label                                78
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      errcode = 'LBLNOTFND'
     C                   exsr      zzdsperr
     C                   goto      endlbl#
     C                   endif

     C                   if        *in78 = *on
     C                   eval      error = *on
     C                   eval      errcode = 'LBLLOCKED'
     C                   exsr      zzdsperr
     C                   goto      endlbl#
     C                   endif

416hAC                   eval      picked = 0
416hAC*
416hAC/EXEC SQL
416hAC+  SELECT SUM(LBQPCK), MIN(LBLBL#)
416hAC+         INTO :PICKED, :$LLBL#
416hAC+  FROM   LABEL
416hAC+  WHERE  LBWHSE = :$LWHSE AND LBRTE = :$LRTID AND
416hAC+         LBORD  = :$LORD  AND LBSEQ = :$LSEQ
416hAC/END-EXEC
     C*
416hDC*                  if        lbqpck >= lbqalc
416hMC                   if        picked >= lbqalc
416iAC                   unlock    label
     C                   eval      error = *on
     C                   eval      errcode = 'ZEROREMAIN'
     C                   exsr      zzdsperr
     C                   goto      endlbl#
     C                   endif

     C     endlbl#       endsr


     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Get screen to stage.

 1B  C                   eval      refrsh = *on
     C                   exsr      scr06i

     C     endup1        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update for screen 2.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   eval      error = *off


     C     endup2        endsr

     *----------------------------------------------------------------
     *  ZZUPD3   Update for screen 3.
     *----------------------------------------------------------------

     C     zzupd3        begsr
     C                   eval      error = *off

     C     endup3        endsr

     *----------------------------------------------------------------
     *  ZZUPD4   Update for screen 4.
     *----------------------------------------------------------------

     C     zzupd4        begsr
     C                   eval      error = *off


     C     endup4        endsr

     *----------------------------------------------------------------
     *  ZZUPD5   Update for screen 5.
     *----------------------------------------------------------------

     C     zzupd5        begsr
     C                   eval      error = *off

     C     endup5        endsr

     *----------------------------------------------------------------
     *  ZZUPD6   Update for screen 6.
     *----------------------------------------------------------------

     C     zzupd6        begsr
     C                   eval      error = *off
416dD **

500a *  Update slot and label for staged product.
500a C     w6stag        ifne      *blanks
VGOb c     client        ifeq      vigo
VGOb c     w6lic         oreq      0
vgobAC     wskey2        setll     worksos2
VGOb c                   else
500aAC     wskey         setll     worksos2
VGOb c                   endif
500aAC                   dow       forevr = forevr
VGOb c     client        ifeq      vigo
VGOb c     w6lic         oreq      0
vgobAC     wskey2        reade     worksos2                               79
VGOb c                   else
500aAC     wskey         reade     worksos2                               79
VGOb c                   endif
500aAC                   select
500aAC                   when      *in79
500aAC                   leave
416dAC                   other
500a C     wkslbl        chain     label                                78
500a *  Remove qty from pick and stock of original slot.
500a *  pick qty was created using actual pick qty, not ordered qty.
640aDC**                 eval      savever# = $slver#
640aDC**                 clear                   $slot
640aDC**                 eval      $slver# = savever#
640aDC**                 eval      $dricommand = '*SLOT'
640aDC**                 eval      $drisubcmd  = '%CLSPICK'
640aDC**
640aDC**                 eval      $slwhseu = *on
640aDC**                 eval      $slwhse = lbwhse
640aDC**                 eval      $slwhdpu = *on
640aDC**                 eval      $slwhdp = lbwhdp
640aDC**                 eval      $sldispu = *on
640aDC**                 eval      $sldisp = lbdisp
640aDC**                 eval      $saitemu = *on
640aDC**                 eval      $saitem = lbitem
640aDC**                 eval      $saqtyu = *on
640aDC**                 select
640aDC**                 when      lbutyp = 'N'
640aDC**                 eval      $saqty1 = wkspck
640aDC**                 eval      $saorg1 = wkspck
640aDC**                 when      lbutyp = '1'
640aDC**                 eval      $saqty2 = wkspck
640aDC**                 eval      $saorg2 = wkspck
640aDC**                 when      lbutyp = '2'
640aDC**                 eval      $saqty3 = wkspck
640aDC**                 eval      $saorg3 = wkspck
640aDC**                 endsl
640aDC**                 eval      $drisys2upd = 'D'
640aDC**                 exsr      zzzdricop
640aA
640aA*  Get USR slot info
640aA
640aAC                   exsr      clr$slot
640aA
640aAC                   eval      $dricommand = '*SLOT'
640aAC                   eval      $drisubcmd  = '%GET'
640aA
640aAC                   eval      $slwhseu = *on
640aAC                   eval      $slwhse = lbwhse
640aAC                   eval      $slwhdpu = *on
640aAC                   eval      $slwhdp = lbwhdp
640aAC                   eval      $sldispu = *on
640aAC                   eval      $sldisp = lbdisp
640aAC                   eval      $drisys2upd = 'D'
640aAC                   exsr      zzzdricop
640aAC                   eval      $tinlic# = $saToLcns
640aAC                   eval      $toutlic# = $saToLcns
640aAC                   eval      $tslotpos = $saToPos
640aAC                   eval      origLcns = $saOLcns
500a
500a *  Update holding slot with stock quantity.
640aA
640aA*    Note: We are not calling LT210 for the putaway because we do not
640aA*    want to ask the user for a new license plate.
640aA
640aAC                   exsr      clr$slot
500a C                   eval      $dricommand = '*SLOT'
640bMC                   eval      $drisubcmd  = '%USR2PUT'
640aDC**                 eval      $drisubcmd  = '%STAGEPUT'
500cDC*                  eval      $drisubcmd  = '%PUTAWAY'
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = lbwhse
500a C                   eval      $slwhdpu = *on
500a C                   eval      $slwhdp = lbwhdp
500a C                   eval      $sldispu = *on
500a C                   eval      $sldisp = w6stag
500a C                   eval      $saitemu = *on
500a C                   eval      $saitem = lbitem
500a C                   eval      $saqtyu = *on
500a C                   select
500a C                   when      lbutyp = 'N'
500a C                   eval      $saqty1 = lbqpck
500a C                   eval      $saorg1 = 0
500a C                   when      lbutyp = '1'
500a C                   eval      $saqty2 = lbqpck
500a C                   eval      $saorg2 = 0
500a C                   when      lbutyp = '2'
500a C                   eval      $saqty3 = lbqpck
500a C                   eval      $saorg3 = 0
500a C                   endsl

640aAC*                  eval      $slentdu  = *on
640aAC*                  eval      $slentd   = #fromslentd
640aAC*                  eval      $slexpdu  = *on
640aAC*                  eval      $slexpd   = #fromslexpd
640aAC*                  eval      $sacitemu = *on
640aAC*                  eval      $sacitem  = #fromslitem
640aAC                   eval      $sacwhdu = *on
640aAC                   eval      $sacwhd  = lbwhdp
640aAC                   eval      $sacdspu  = *on
640aAC                   eval      $sacdsp   = lbdisp
640aA
640aAC                   eval      $saActionU = *on
640aAC                   eval      $saAction = 'SOS'
640aAC                   eval      $saTrn#U = *on
640aAC                   eval      $saTrn# = lbtrn#
640aAC                   eval      $saETrn#U = *on
640aAC                   eval      $saETrn# = 0
640aAC                   eval      $saLbl#U = *on
640aAC                   eval      $saLbl# = lblbl#
640aAC                   eval      $saToLcnsU = *on
640aAC                   eval      $saToLcns = $tinlic#
640aAC                   eval      $saToPosU = *on
640aAC                   eval      $saToPos = 0
640aAC                   eval      $saToPos = $tslotpos
640aAC                   eval      $saToVrfyU = *on
640aAC                   eval      $saToVrfy = 'N'
640aAC                   eval      $saToCodeu = *on
640aAC                   eval      $saToCode = 'S'
640aAC                   eval      $saToAreaU = *on
640aAC                   eval      $saToArea = 'Slot'
640aAC                   eval      $saFrmLcnsU = *on
640aAC                   eval      $saFrmLcns = $toutlic#
640aAC                   eval      $saOLcnsU = *on
640aAC                   eval      $saOLcns = origLcns
640aA
640aAC*                  eval      $sapullwhdpu = *on
640aAC*                  eval      $sapullwhdp  = wuPulWhdp
640aAC*                  eval      $sapulldispu = *on
640aAC*                  eval      $sapulldisp  = wuPulDisp
640aAC*                  eval      $sapullbaseu = *on
640aAC*                  eval      $sapullbase  = wuPulBase
640aAC*                  eval      $sapulllcnsu = *on
640aAC*                  eval      $sapulllcns  = wuPulLcns

640aAC                   eval      $drisys2upd = 'D'
500a C                   exsr      zzzdricop

640aAC                   if        error = *on
640aAC                   leavesr
640aAC                   endif

640aDC**                 eval      $dricommand = '*SLOT'
640aDC**                 eval      $drisubcmd  = '%CLSSTGPUT'
640aDC**
640aDC**                 eval      $slwhseu = *on
640aDC**                 eval      $slwhse = lbwhse
640aDC**                 eval      $slwhdpu = *on
640aDC**                 eval      $slwhdp = lbwhdp
640aDC**                 eval      $sldispu = *on
640aDC**                 eval      $saitemu = *on
640aDC**                 eval      $saitem = lbitem
640aDC**                 eval      $saqtyu = *on
640aDC**                 select
640aDC**                 when      lbutyp = 'N'
640aDC**                 eval      $saqty1 = lbqpck
640aDC**                 eval      $saorg1 = lbqpck
640aDC**                 when      lbutyp = '1'
640aDC**                 eval      $saqty2 = lbqpck
640aDC**                 eval      $saorg2 = lbqpck
640aDC**                 when      lbutyp = '2'
640aDC**                 eval      $saqty3 = lbqpck
640aDC**                 eval      $saorg3 = lbqpck
640aDC**                 endsl
640aDC**                 exsr      zzzdricop
500a
500a *  Update holding slot with pick quantity.
640aAC***********        exsr      clr$slot
500a C                   eval      $dricommand = '*SLOT'
500a C                   eval      $drisubcmd  = '%PICK'
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = lbwhse
500a C                   eval      $slwhdpu = *on
500a C                   eval      $slwhdp = lbwhdp
500a C                   eval      $sldispu = *on
500a C                   eval      $saitemu = *on
500a C                   eval      $saitem = lbitem
500a C                   eval      $saqtyu = *on
500a C                   select
500a C                   when      lbutyp = 'N'
500a C                   eval      $saqty1 = lbqpck
500a C                   eval      $saorg1 = 0
500a C                   when      lbutyp = '1'
500a C                   eval      $saqty2 = lbqpck
500a C                   eval      $saorg2 = 0
500a C                   when      lbutyp = '2'
500a C                   eval      $saqty3 = lbqpck
500a C                   eval      $saorg3 = 0
500a C                   endsl
640aAC                   eval      $drisys2upd = 'D'
500a C                   exsr      zzzdricop
500a
500a *  Update label record with holding slot.
500aAC                   eval      lbdisp = $sldisp
500aAC                   eval      lbaisl = $slaisl
500aAC                   eval      lbloc  = $slloc
500aAC                   eval      lbrlvl = $slrlvl
500aAC                   eval      lbhand = $slhand
500aA
500aA*    Update status date/time to reflect qty update.
500aAC                   time                    lbstim
500aA*
500a C                   update    lbrec
     *  Remove work record from WORKSOS.
500a C                   delete    wksrec
500aAC                   endsl
500aAC                   enddo
500a
500d C                   eval      stagcount = stagcount + 1
500a C                   endif


     *  Start all over at the beginning.
     *  Re-dsiplay screen 6 if staging until all pallet license are staged

500aAC     wskey2        setll     worksos2
vgobAC     wskey2        reade     worksos2                               79
500aAC                   select
500aAC                   when      *in79 = *on
 1B  C                   eval      refrsh = *on
     C                   exsr      scr01i
500aAC                   other
500d C                   eval      refrsh = *on
500d C                   exsr      scr06i
500aAC                   endsl
     C     endup6        endsr

     *----------------------------------------------------------------
     *  ZZUPD7   Update for screen 7.
     *----------------------------------------------------------------

     C     zzupd7        begsr
     C                   eval      error = *off
     C     endup7        endsr

     *----------------------------------------------------------------
     *  ZZUPD8   Update for screen 8.
     *----------------------------------------------------------------

     C     zzupd8        begsr
     C                   eval      error = *off
500d C***                eval      pliccount = pliccount + 1

     C     endup8        endsr

500a *----------------------------------------------------------------
500a *  ZZSPUT   Verify putaway for stage product
500a *----------------------------------------------------------------
500a
500a C     zzsput        begsr
500a C                   eval      error = *off
VGOb c     client        ifeq      vigo
VGOb c     w6lic         oreq      0
500aAC     wskey2        setll     worksos2
VGOb c                   else
500aAC     wskey         setll     worksos2
VGOb c                   endif
500aAC                   dow       forevr = forevr
VGOb c     client        ifeq      vigo
VGOb c     w6lic         oreq      0
vgobAC     wskey2        reade     worksos2                               79
VGOb c                   else
500aAC     wskey         reade     worksos2                               79
VGOb c                   endif
500aAC                   select
500aAC                   when      *in79 = *on
500aAC                   leave
500aAC                   other
500a C     wkslbl        chain     label                                78
500aAC     *in78         ifeq      *on
500aAC                   leave
500aAC                   endif
500a *  Verify item/qty can be put into stage slot.
500fAC                   eval      savever# = $slver#
500fAC                   clear                   $slot
500fAC                   eval      $slver# = savever#
500a C                   eval      $dricommand = '*SLOT'
500cMC                   eval      $drisubcmd  = '%VFYSTGPUT'
500cDC*                  eval      $drisubcmd  = '%VERIFYPUT'
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = wkswhs
500a C                   eval      $slwhdpu = *on
500a C                   eval      $slwhdp = wkswhd
500a C                   eval      $sldispu = *on
500a C                   eval      $sldisp = w6stag
500a C                   eval      $saitemu = *on
500a C                   eval      $saitem = lbitem
500a C                   eval      $saqtyu = *on
500a C                   eval      $slpicke= '3'
500a C                   select
500a C                   when      lbutyp = 'N'
500a C                   eval      $saqty1 = wkspck
500a C                   eval      $saorg1 = 0
500a C                   when      lbutyp = '1'
500a C                   eval      $saqty2 = wkspck
500a C                   eval      $saorg2 = 0
500a C                   when      lbutyp = '2'
500a C                   eval      $saqty3 = wkspck
500a C                   eval      $saorg3 = 0
500a C                   endsl
500a C                   exsr      zzzdricop
500a C     error         ifeq      *on
500aAC                   leave
500aAC                   endif
500a
500aAC                   iter
500aAC                   endsl
500aAC                   enddo
500a C     endspt        endsr
500a
500a *----------------------------------------------------------------
500a *  ZZWHDP   Verify slot for each staged item department
500a *----------------------------------------------------------------
500a
500a C     zzwhdp        begsr
500a C                   eval      error = *off
500a C                   eval      svswhd = *blanks
500dMC     wskey1        setll     worksos1
500aAC                   dow       forevr = forevr
500aAC     wskey1        reade     worksos1                               79
500aAC                   select
500aAC                   when      *in79 = *on
500aAC                   leave
500aAC                   other
500aAC     svswhd        ifne      wkswhd
500aAC     slkey2        chain     slot2                              79
500aAC                   if        *in79 = *on
500a C                   eval      error = *on
500aAC                   leave
500aAC                   endif
500a C                   eval      svswhd = wkswhd
500aAC                   endif
500aAC                   iter
500aAC                   endsl
500aAC                   enddo
500a C     endwhd        endsr

640aA*----------------------------------------------------------------
640aA*                     DRI SUBROUTINES
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------
640aA
640aA*----------------------------------------------------------------
640aA*  clr$slot  Clear $slot data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   when      $dricommand = '*ORD'
     C                   eval      $dridata = $ordh
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
640aAC                   eval      $dridata2 = $slot2
     C                   endsl

640aAC                   if        $dricommand = '*SLOT'
640aAC                   call(e)   'DRICOP'
640aAC                   parm                    $dricommand
640aAC                   parm                    $drisubcmd
640aAC                   parm                    $drisys2upd
640aAC                   parm      #prog         $driprogram
640aAC                   parm      ' '           $drireturn
640aAC                   parm      ' '           $drimessage
640aAC                   parm                    $dridata
640aAC                   parm                    $dridata2
640aAC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
640aAC                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

416rAC                   when      $drireturn = 'EOF' and
416rAC                             $drisubcmd = '*NXTPICKAV'

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C                   exsr      zzzerrind

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   when      $dricommand = '*ORD'
     C                   eval      $ordh = $dridata
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
640aAC                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzzerrind     begsr

     C                   select

     *  Screen 1

     C                   when      nxtscr = '01'

     C                   if        $ohcorde = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr
CHT  *----------------------------------------------------------------
CHT  *  zin41i   Extra program initialization. set up for pallet labels
CHT  *----------------------------------------------------------------
CHT  C     zin41i        begsr
CHT  C**                 eval      $pvord = w1ord
CHT  C**                 eval      woord  = w1ord
CHT  c                   move      '00'          w6palt
CHT  c                   move      '1'           w6side
CHT  C                   if        nxtscr = '06 '
vgobDC*                  movel(p)  w1ord         w6stag
vgobMC                   eval      w6stag = 'AA-001-1'
CHT  c                   else
vgob C*    Retrieve next Single order pallet license
vgob C                   call      'PIRPLCN#'
vgob C                   parm                    plcn#             7 0
vgobMC***                eval      w8lic  = plcn#
vgobDC*                  eval      w8lic  = w1ord
CHT  c                   endif
CHT  c****               open      pllablhst
CHT  c**** $pvord        chain     pallblfm                           42
CHT  c                   if        %found
CHT  c****               move      plcont        w6palt
CHT  c****               move      plside        w6side
CHT  C                   endif
CHT  c                   move      *off          *in42
CHT  c****               close     pllablhst
CHT  c                   endsr
CHT
CHT  *----------------------------------------------------------------
CHT  *  zin41o   Extra program. write records for pallet label program.
CHT  *----------------------------------------------------------------
CHT  C     zin41o        begsr
CHT  c                   if        *in43
CHT  c****               open      pllabldrv
CHT  c****               movel     $pvord        palord
CHT  c****               movel     w6palt        palcnt
CHT  c****               movel     w6side        palsid
CHT  c****               MOVEL     w1user        palusr
CHT  c****               write     palbldfm
CHT  c                   move      *off          *in43
CHT  c****               close     pllabldrv
CHT  C                   endif
CHT  C                   endsr
