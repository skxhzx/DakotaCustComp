      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  MF122     Manufacturer Code Decipher Maintenance - Change
     F*  18 Sept 2007
     F*  Lynn McMahon
     F*
     F*  Revisions
     F*
     F*    09/18/07  LMC  5.10
     F*      - Created
510aAF*    10/02/07  LMC  5.10a
     F*      - Fix: Correct manufacturer field size to 11 positions
510bAF*    10/05/07  LMC  5.10b
     F*      - Fix: Move chain for MFR file to zzinz2
510cAF*    11/06/07  LMC  5.10c
     F*      - Fix: changed week edits
640aAF*    02/03/12  RBD  6.40a
     F*      - Added text when viewing to guide user to press enter
     F*        to see all tables.
     F*      - Changed screen format name to MF12201.
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   Field position to
     F*  21 - 40   Field input error (reverse display)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (protect key)
     F*  97        Error message subfile indicator
     F*  98        Error on screen (sound buzzer)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
640aDf*mf122fm   cf   e             workstn
640aMfmf12201   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fmfrdate   uf a e           k disk
     f                                     rename(mdrec:record)
     fmfr       if   e           k disk
     fmfrtable  uf a e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d desc            s             20    dim(20) ctdata perrcd(1)
     d daycd           s              1    dim(31)
     d mthcd           s              4    dim(12)
     d yrcd            s              4    dim(36)
     D*
     d @getcl          c                   const('GETCLIENT')
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     D*
     D*   Redefine key
     D*
510aDd* $pmfr#                19     28  0
510aDd* $pdef#                29     30  0
510aAd  $pmfr#                19     29  0
510aAd  $pdef#                30     31  0
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $cvtdt          ds
     d  $cvdop                 1      8
     d  $cvdd6                 9     14  0
     d  $cvdd8                15     22  0
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     D*
     d  erpo#                  1      5p 0
     d  eritem                 6     20
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Data structure for mdcode to breakdown for screen positions
     D*
     d mdcode          ds
     d  mdps01                 1      2
     d  mdps02                 3      4
     d  mdps03                 5      6
     d  mdps04                 7      8
     d  mdps05                 9     10
     d  mdps06                11     12
     d  mdps07                13     14
     d  mdps08                15     16
     d  mdps09                17     18
     d  mdps10                19     20
     d  mdps11                21     22
     d  mdps12                23     24
     d  mdps13                25     26
     d  mdps14                27     28
     d  mdps15                29     30
     D*----------------------------------------------------------------
     D*  Data structure to save definition information
     D*
     d def             ds
     d  mddef#                 1      2  0
     d  mddflt                 3      3
     d  mdday                  4      4
     d  mdmnth                 5      5
     d  mdmcst                 6      8  0
     d  mdyear                 9      9
     d  mdycst                10     12  0
     d  mdweek                13     13
     d  mdwbeg                14     14
     d  mdwcst                15     17  0
     d  mdtype                18     18
     d svdef           ds
     d  svdef#                 1      2  0
     d  svdflt                 3      3
     d  svday                  4      4
     d  svmnth                 5      5
     d  svmcst                 6      8  0
     d  svyear                 9      9
     d  svycst                10     12  0
     d  svweek                13     13
     d  svwbeg                14     14
     d  svwcst                15     17  0
     d  svtype                18     18
     d svcode          ds
     d  svps01                 1      2
     d  svps02                 3      4
     d  svps03                 5      6
     d  svps04                 7      8
     d  svps05                 9     10
     d  svps06                11     12
     d  svps07                13     14
     d  svps08                15     16
     d  svps09                17     18
     d  svps10                19     20
     d  svps11                21     22
     d  svps12                23     24
     d  svps13                25     26
     d  svps14                27     28
     d  svps15                29     30
     D*----------------------------------------------------------------
     D*  Data structure for mttbl to breakdown day table screen positions
     D*
     d mttbl           ds
     d  daytbl                 1     31
     d  mtps01                 1      1
     d  mtps02                 2      2
     d  mtps03                 3      3
     d  mtps04                 4      4
     d  mtps05                 5      5
     d  mtps06                 6      6
     d  mtps07                 7      7
     d  mtps08                 8      8
     d  mtps09                 9      9
     d  mtps10                10     10
     d  mtps11                11     11
     d  mtps12                12     12
     d  mtps13                13     13
     d  mtps14                14     14
     d  mtps15                15     15
     d  mtps16                16     16
     d  mtps17                17     17
     d  mtps18                18     18
     d  mtps19                19     19
     d  mtps20                20     20
     d  mtps21                21     21
     d  mtps22                22     22
     d  mtps23                23     23
     d  mtps24                24     24
     d  mtps25                25     25
     d  mtps26                26     26
     d  mtps27                27     27
     d  mtps28                28     28
     d  mtps29                29     29
     d  mtps30                30     30
     d  mtps31                31     31

     d  mthtbl                 1     48
     d  mtmp01                 1      1
     d  mtjan                  2      4
     d  mtmp02                 5      5
     d  mtfeb                  6      8
     d  mtmp03                 9      9
     d  mtmar                 10     12
     d  mtmp04                13     13
     d  mtapr                 14     16
     d  mtmp05                17     17
     d  mtmay                 18     20
     d  mtmp06                21     21
     d  mtjun                 22     24
     d  mtmp07                25     25
     d  mtjul                 26     28
     d  mtmp08                29     29
     d  mtaug                 30     32
     d  mtmp09                33     33
     d  mtsep                 34     36
     d  mtmp10                37     37
     d  mtoct                 38     40
     d  mtmp11                41     41
     d  mtnov                 42     44
     d  mtmp12                45     45
     d  mtdec                 46     48

     d  yrtbl                  1    144
     d  mtyra                  1      4  0
     d  mtyrb                  5      8  0
     d  mtyrc                  9     12  0
     d  mtyrd                 13     16  0
     d  mtyre                 17     20  0
     d  mtyrf                 21     24  0
     d  mtyrg                 25     28  0
     d  mtyrh                 29     32  0
     d  mtyri                 33     36  0
     d  mtyrj                 37     40  0
     d  mtyrk                 41     44  0
     d  mtyrl                 45     48  0
     d  mtyrm                 49     52  0
     d  mtyrn                 53     56  0
     d  mtyro                 57     60  0
     d  mtyrp                 61     64  0
     d  mtyrq                 65     68  0
     d  mtyrr                 69     72  0
     d  mtyrs                 73     76  0
     d  mtyrt                 77     80  0
     d  mtyru                 81     84  0
     d  mtyrv                 85     88  0
     d  mtyrw                 89     92  0
     d  mtyrx                 93     96  0
     d  mtyry                 97    100  0
     d  mtyrz                101    104  0
     d  mtyr0                105    108  0
     d  mtyr1                109    112  0
     d  mtyr2                113    116  0
     d  mtyr3                117    120  0
     d  mtyr4                121    124  0
     d  mtyr5                125    128  0
     d  mtyr6                129    132  0
     d  mtyr7                133    136  0
     d  mtyr8                137    140  0
     d  mtyr9                141    144  0
     D*----------------------------------------------------------------
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
     *----------------------------------------------------------------
     *  Variables
     D M               s              3  0
     D x               s              2  0
     D len             s              1  0
     D ln2             s              1  0
     D ln3             s              1  0
     D chr#            s              1  0
     D strpos          s              3  0
     D pattern         s              2
     D pattern2        s              1
     D pattern3        s              4
     D pos             s              3  0
     D ckpos           s              2  0
     D ckposr          s              3  0
     D lstpos          s              3  0
     D findcnt         s              2  0
     D forevr          s              1
     D dcmd            s              8
     D mcmd            s              8
     D ycmd            s              8
     D savedaytbl      s             31
     D savemthtbl      s             48
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   *ADD     - Create new batch.
     C*              *EDIT    - Edit batch.
     C*              *DELETE  - Delete batch.
     C*              *PRINT   - Print batch edit listing.
     C*              *POST    - Post batch.
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key for everything by *ADD.
     C*
     C*    Returned Parameters
     C*      $PUKY   Contains new batch number for *ADD.
     C*              Unchanged for everything else.
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $parms
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *off          *in90
     c                   move      *off          *in91
     c                   move      *off          error
     c                   move      *blanks       $prtn
     c                   move      *blanks       $perm
     c                   exsr      zzinz2
     c     error         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   end
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c     nxtscr        caseq     '02 '         sc2
     c     nxtscr        caseq     '03 '         sc3
     c     nxtscr        caseq     '04 '         sc4
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   return
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set ON alarm indicator if error occured
     C*
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*  Overlay screen with screen to be processed.
     C*
     c     nxtscr        ifeq      '01 '
     c                   exfmt     screen1                              50
     c                   end
     c     nxtscr        ifeq      '02 '
     c                   exfmt     screen2                              50
     c                   end
     c     nxtscr        ifeq      '03 '
     c                   exfmt     screen3                              50
     c                   end
     c     nxtscr        ifeq      '04 '
     c                   exfmt     screen4                              50
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
     c                   setoff                                       010203
     c                   setoff                                       040506
     c                   setoff                                       070809
     c                   setoff                                       101112
     c                   setoff                                       141516
     c                   setoff                                       212223
     c                   setoff                                       242526
     c                   setoff                                       272829
     c                   setoff                                       303132
     c                   setoff                                       343536
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cmdtkn            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcmsg
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft1
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
     c                   move      *on           *in91
     c                   exsr      zzget1
     c                   exsr      zzfil1
     c                   end
     c     end01i        endsr
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     c     scr02i        begsr

     c                   eval      mttype = 'D'
     c                   eval      mtmfr# = mdmfr#
     c                   eval      mtdef# = mddef#
     c                   move      '02 '         nxtscr            3
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft2
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
     c                   move      *on           *in91
     c                   exsr      zzget2
     c                   exsr      zzfil2
     c                   end
     c     end02i        endsr
     C*----------------------------------------------------------------
     C*
     C*  Screen 03 initialization
     C*
     c     scr03i        begsr

     c                   eval      mttype = 'M'
     c                   eval      mtmfr# = mdmfr#
     c                   eval      mtdef# = mddef#
     c                   move      '03 '         nxtscr            3
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft3
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
     c                   move      *on           *in91
     c                   exsr      zzget3
     c                   exsr      zzfil3
     c                   end
     c     end03i        endsr
     C*----------------------------------------------------------------
     C*
     C*  Screen 04 initialization
     C*
     c     scr04i        begsr

     c                   eval      mttype = 'Y'
     c                   eval      mtmfr# = mdmfr#
     c                   eval      mtdef# = mddef#
     c                   move      '04 '         nxtscr            3
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft4
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
     c                   move      *on           *in91
     c                   exsr      zzget4
     c                   exsr      zzfil4
     c                   end
     c     end04i        endsr
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr01i
     c                   end
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
      * This code is added to save updating until all screens that need
      * to have validation have been processed
     c                   eval      svdef  = def
     c                   eval      svcode = mdcode
     c                   select
     c                   when      mdday = 'T'
     c                   exsr      scr02i
     c                   goto      endsc1
     c                   when      mdmnth = 'T'
     c                   exsr      scr03i
     c                   goto      endsc1
     c                   when      mdyear = 'T'
     c                   exsr      scr04i
     c                   goto      endsc1
     c                   other
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc1
     c                   endsl
     c                   end
      * This code is added to view all tables
     C                   if        $pcmd = '*VIEW'
     c                   select
     c                   when      mdday = 'T'
     c                   exsr      scr02i
     c                   goto      endsc1
     c                   when      mdmnth = 'T'
     c                   exsr      scr03i
     c                   goto      endsc1
     c                   when      mdyear = 'T'
     c                   exsr      scr04i
     c                   goto      endsc1
     c                   endsl
     c                   endif
     c                   move      'EOJ'         nxtscr
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     c     sc2           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc2
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr02i
     c                   end
     c                   goto      endsc2
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
     c                   exsr      scr01i
     c                   goto      endsc2
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
     c                   exsr      zzchk2
     c     error         cabeq     *on           endsc2
      * This code is added to save updating until all screens that need
      * to have validation have been processed
     c                   select
     c                   when      mdmnth = 'T'
     c                   eval      savedaytbl = daytbl
     c                   exsr      scr03i
     c                   goto      endsc2
     c                   when      mdyear = 'T'
     c                   eval      savedaytbl = daytbl
     c                   exsr      scr04i
     c                   goto      endsc2
     c                   other
     c                   exsr      zzupd2
     c     error         cabeq     *on           endsc2
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc2
     c                   endsl
     c                   end
      * This code is added to view all tables
     C                   if        $pcmd = '*VIEW'
     c                   select
     c                   when      mdmnth = 'T'
     c                   exsr      scr03i
     c                   goto      endsc2
     c                   when      mdyear = 'T'
     c                   exsr      scr04i
     c                   goto      endsc2
     c                   endsl
     c                   endif
     c                   move      'EOJ'         nxtscr
     c     endsc2        endsr
     C*----------------------------------------------------------------
     C*
     C*  SC3  -  Screen 3
     C*
     c     sc3           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc3
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr03i
     c                   end
     c                   goto      endsc3
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
     c                   exsr      scr01i
     c                   goto      endsc3
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
     c                   exsr      zzchk3
     c     error         cabeq     *on           endsc3
      * This code is added to save updating until all screens that need
      * to have validation have been processed
     c                   select
     c                   when      mdyear = 'T'
     c                   eval      savemthtbl = mthtbl
     c                   exsr      scr04i
     c                   goto      endsc3
     c                   other
     c                   exsr      zzupd3
     c     error         cabeq     *on           endsc3
     c                   if        mdday = 'T'
     c                   exsr      zzupd2s
     c                   endif
     c     error         cabeq     *on           endsc3
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc3
     c                   endsl
     c                   end
      * This code is added to view all tables
     C                   if        $pcmd = '*VIEW'
     c                   select
     c                   when      mdyear = 'T'
     c                   exsr      scr04i
     c                   goto      endsc3
     c                   endsl
     c                   endif
     c                   move      'EOJ'         nxtscr
     c     endsc3        endsr
     C*----------------------------------------------------------------
     C*
     C*  SC4  -  Screen 4
     C*
     c     sc4           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc4
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr04i
     c                   end
     c                   goto      endsc4
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
     c                   exsr      scr01i
     c                   goto      endsc4
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc4
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
     c                   exsr      zzchk4
     c     error         cabeq     *on           endsc4
      * This code is added to save updating until all screens that need
      * to have validation have been processed
     c                   exsr      zzupd4
     c     error         cabeq     *on           endsc4
     c                   if        mdmnth = 'T'
     c                   exsr      zzupd3s
     c                   endif
     c                   if        mdday = 'T'
     c                   exsr      zzupd2s
     c                   endif
     c     error         cabeq     *on           endsc4
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc4
     c                   end
     c                   move      'EOJ'         nxtscr
     c     endsc4        endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
     C*
     C* Get client id.
     C*
     c                   call      @getcl
     c                   parm                    client           10
     C*
     C*
     C*  Initialize special keys
     C*
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C                   eval      len = 2
     C                   eval      ln2 = 1
     C                   eval      ln3 = 4
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   write     msgclr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     c                   write     clrscr
     c                   move      *on           sclear            1
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0201  Code must be entered for create.
     C*
     c     zm01          begsr
     c                   move      'PIR0201'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   eval      errmsg = ' '
     c                   movel     desc(m)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     c     zm02          begsr
     c                   move      'PIR0202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     c     zm02tp        begsr
     c                   move      'PIR0202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       errmsg
     c                   movel     pattern       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0203  Code must be entered
     C*
     c     zm03          begsr
     c                   move      'PIR0203'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     desc(M)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0203  Code must be entered
     C*
     c     zm03tp        begsr
     c                   move      'PIR0203'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       errmsg
     c                   movel     pattern       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR1015  Code must be blank
     C*
     c     zm05          begsr
     c                   move      'PIR1015'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       errmsg
     c                   movel     desc(M)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR1015  Code must be blank
     C*
     c     zm05tp        begsr
     c                   move      'PIR1015'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       errmsg
     c                   movel     pattern       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     c     zm71          begsr
     c                   move      'PIR7971'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     c     zm72          begsr
     c                   move      'PIR7972'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*     PIR7973  Slot record does not exist.
     C*
     c     zm73          begsr
     c                   move      'PIR7973'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0105  Generic message.
     C*
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR1001  Invalid value entered.
     C*
     c     zm1001        begsr
     c                   move      'PIR1001'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     desc(M)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*     PIR7974  Slot record is locked.
     C*
     c     zm74          begsr
     c                   move      'PIR7974'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
     C*
     C*  When adding ....
     C*
     c     $pcmd         ifeq      '*ADD    '
     C*
     C*    Make sure code was entered.
     C*
     c     mddef#        ifeq      0
     c                   move      *on           error
     c                   move      *on           *in21
     c                   eval      m = 1
     c                   exsr      zm01
     c                   goto      endck1
     c                   end
     C*
     C*    Make sure code doesn't already exist.
     C*
     c                   move      mddef#        $pdef#
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   exsr      zm02
     c                   goto      endck1
     c                   end
     c                   end
      * validate default definition
     c                   If        mddflt <> 'Y' and
     c                             mddflt <> 'N'
     c                   move      *on           error
     C                   eval      m = 2
     c                   eval      *in02 = *on
     c                   eval      *in22 = *on
     c                   exsr      zm1001
     c                   goto      endck1
     c                   endif
      * Validate date type
     c                   If        mdtype <> '1' and
     c                             mdtype <> '2'
     c                   move      *on           error
     C                   eval      m = 20
     c                   eval      *in16 = *on
     c                   eval      *in36 = *on
     c                   exsr      zm1001
     c                   goto      endck1
     c                   endif
      * validate Day entries
     c                   select
      * D1,D2 must exist, D3 must not exist
     c                   when      mdday = 'N'
     c                   eval      pattern = 'D1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'D2'
     c                   exsr      zzcktype
     c                   eval      pattern = 'D3'
     c                   exsr      zzcktypeno
      * D1,D2,D3 must exist
     c                   when      mdday = 'J'
     c                   eval      pattern = 'D1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'D2'
     c                   exsr      zzcktype
     c                   eval      pattern = 'D3'
     c                   exsr      zzcktype
      * D1 must exist, D3 must not exist, D2 is optional
     c                   when      mdday = 'T'
     c                   eval      pattern = 'D1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'D3'
     c                   exsr      zzcktypeno
      * D1,D2,D3 must not exist
     c                   when      mdday = 'X'
     c                   eval      pattern = 'D1'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'D2'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'D3'
     c                   exsr      zzcktypeno

      * invalid day code entered
     c                   when      mdday <> 'N' and
     c                             mdday <> 'J' and
     c                             mdday <> 'T' and
     c                             mdday <> 'X' and
     c                             mdday <> ' '
     c                   move      *on           error
     C                   eval      m = 3
     c                   eval      *in03 = *on
     c                   eval      *in23 = *on
     c                   exsr      zm1001
     c                   goto      endck1

     c                   other
      * Day must be entered
     c                   move      *on           error
     C                   eval      m = 3
     c                   eval      *in03 = *on
     c                   eval      *in23 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endsl

      * Validate Month entries
     c                   select
      * M1,M2 must exist, M3 must not exist
     c                   when      mdmnth = 'N'
     c                   eval      pattern = 'M1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'M2'
     c                   exsr      zzcktype
     c                   eval      pattern = 'M3'
     c                   exsr      zzcktypeno
      * M1,M2,M3 must exist
     c                   when      mdmnth = 'A'
     c                   eval      pattern = 'M1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'M2'
     c                   exsr      zzcktype
     c                   eval      pattern = 'M3'
     c                   exsr      zzcktype
      * M1 must exist, M2,M3 are optional
     c                   when      mdmnth = 'T'
     c                   eval      pattern = 'M1'
     c                   exsr      zzcktype
      * m3 requires m2
     c                   eval      pattern = 'M3'
     c                   exsr      zzcktypeop
     c                   if        pos > 0
     c                   eval      pattern = 'M2'
     c                   exsr      zzcktype
     c                   endif
      * must validate the table information before updating the def record
      * in case user cancels from table screen
      * M1,M2,M3 must not exist
     c                   when      mdmnth = 'X'
     c                   eval      pattern = 'M1'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'M2'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'M3'
     c                   exsr      zzcktypeno
      * M1 must exist, M2,M3 are optional
     c                   when      mdmnth = 'C'
     c                   eval      pattern = 'M1'
     c                   exsr      zzcktype
      * m3 requires m2
     c                   eval      pattern = 'M3'
     c                   exsr      zzcktypeop
     c                   if        pos > 0
     c                   eval      pattern = 'M2'
     c                   exsr      zzcktype
     c                   endif
      * invalid Month code was entered
     c                   when      mdmnth <> 'N' and
     c                             mdmnth <> 'A' and
     c                             mdmnth <> 'T' and
     c                             mdmnth <> 'X' and
     c                             mdmnth <> 'C' and
     c                             mdmnth <> ' '
     c                   move      *on           error
     C                   eval      m = 4
     c                   eval      *in04 = *on
     c                   eval      *in24 = *on
     c                   exsr      zm1001
     c                   goto      endck1
     c                   other
      * invalid month
     c                   move      *on           error
     C                   eval      m = 4
     c                   eval      *in04 = *on
     c                   eval      *in24 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endsl
      * invalid Month custom Code  - more validation later
     c                   if        mdmnth = 'C' and mdmcst = 0
     c                   move      *on           error
     C                   eval      m = 5
     c                   eval      *in05 = *on
     c                   eval      *in25 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endif
      * invalid Month custom Code  - if not custom field must be 0
     c                   if        mdmnth <> 'C' and mdmcst <> 0
     c                   move      *on           error
     C                   eval      m = 5
     c                   eval      *in05 = *on
     c                   eval      *in25 = *on
     c                   exsr      zm05
     c                   goto      endck1
     c                   endif
     c
      * Validate Year  entries
     c                   select
      * Y4 must exist, Y1,Y2,Y2 are optional
     c                   when      mdyear = 'N'
     c                   eval      pattern = 'Y4'
     c                   exsr      zzcktype
      * Y1 must exist  Y2,Y3,Y4 are not allowed
     c                   when      mdyear = 'T'
     c                   eval      pattern = 'Y1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'Y2'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'Y3'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'Y4'
     c                   exsr      zzcktypeno
      * Y1,Y2,Y3,Y4 are not allowed
     c                   when      mdyear = 'X'
     c                   eval      pattern = 'Y1'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'Y2'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'Y3'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'Y4'
     c                   exsr      zzcktypeno
      * Y1 must exist, Y2,Y3,Y4 are optional
     c                   when      mdyear = 'C'
     c                   eval      pattern = 'Y1'
     c                   exsr      zzcktype
      * invalid Year code was entered
     c                   when      mdyear <> 'N' and
     c                             mdyear <> 'T' and
     c                             mdyear <> 'X' and
     c                             mdyear <> 'C' and
     c                             mdyear <> ' '
     c                   move      *on           error
     C                   eval      m = 6
     c                   eval      *in06 = *on
     c                   eval      *in26 = *on
     c                   exsr      zm1001
     c                   goto      endck1
     c                   other
      * invalid year
     c                   move      *on           error
     C                   eval      m = 6
     c                   eval      *in06 = *on
     c                   eval      *in26 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endsl
      * invalid Year custom Code  - more validation later
     c                   if        mdyear = 'C' and mdycst = 0
     c                   move      *on           error
     C                   eval      m = 7
     c                   eval      *in07 = *on
     c                   eval      *in27 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endif
      * invalid Year custom Code  - if not custom field must be 0
     c                   if        mdyear <> 'C' and mdycst <> 0
     c                   move      *on           error
     C                   eval      m = 7
     c                   eval      *in07 = *on
     c                   eval      *in27 = *on
     c                   exsr      zm05
     c                   goto      endck1
     c                   endif
     c
      * Validate Week  entries
     c                   select
      * W1,W2 must exist, W3 is not allowed
     c                   when      mdweek = 'N'
     c                   eval      pattern = 'W1'
     c                   exsr      zzcktype
     c                   eval      pattern = 'W2'
     c                   exsr      zzcktype
     c                   eval      pattern = 'W3'
     c                   exsr      zzcktypeno
      * W1,W2,W3, are not allowed
     c                   when      mdweek = 'X'
     c                   eval      pattern = 'W1'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'W2'
     c                   exsr      zzcktypeno
     c                   eval      pattern = 'W3'
     c                   exsr      zzcktypeno
510cD * W1 must exist, W2,W3 are optional
510cM * W1 must exist, W2 is optional, W3 is not allowed
     c                   when      mdweek = 'C'
     c                   eval      pattern = 'W1'
     c                   exsr      zzcktype
510cAc                   eval      pattern = 'W3'
510cAc                   exsr      zzcktypeno
      * invalid Week code was entered
     c                   when      mdweek <> 'N' and
     c                             mdweek <> 'X' and
     c                             mdweek <> 'C' and
     c                             mdweek <> ' '
     c                   move      *on           error
     C                   eval      m = 8
     c                   eval      *in08 = *on
     c                   eval      *in28 = *on
     c                   exsr      zm1001
     c                   goto      endck1
     c                   other
      * invalid week
     c                   move      *on           error
     C                   eval      m = 8
     c                   eval      *in08 = *on
     c                   eval      *in28 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endsl
      * invalid Week custom Code  - more validation later
     c                   if        mdweek = 'C' and mdwcst = 0
     c                   move      *on           error
     C                   eval      m =10
     c                   eval      *in10 = *on
     c                   eval      *in30 = *on
     c                   exsr      zm03
     c                   goto      endck1
     c                   endif
      * invalid week custom Code  - if not custom field must be 0
     c                   if        mdweek <> 'C' and mdwcst <> 0
     c                   move      *on           error
     C                   eval      m = 10
     c                   eval      *in10 = *on
     c                   eval      *in30 = *on
     c                   exsr      zm05
     c                   goto      endck1
     c                   endif
      * invalid First Day Of Week
     c                   if        mdweek <> 'X'
     c                   If        mdwbeg <> '1' and
     c                             mdwbeg <> '2'
     c                   move      *on           error
     C                   eval      m = 9
     c                   eval      *in09 = *on
     c                   eval      *in29 = *on
     c                   exsr      zm1001
     c                   goto      endck1
     c                   endif
     c                   endif
     c
      *
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     c     zzchk2        begsr
      * all fields must be filled in
     c                   eval      pattern2 = ' '
     c                   eval      strpos = 1
     c     ' '           scan      daytbl:strpos pos
     c                   if        pos > 0
     c                   move      *on           error
     C                   eval      m =12
     c                   eval      *in12 = *on
     c                   eval      *in32 = *on
     c                   exsr      zm03
     c                   goto      endck2
     c                   endif
      * No duplicate codes can exist
     c                   movea     daytbl        daycd
     c                   do        31            x
     c                   eval      pattern2 = daycd(x)
     c                   eval      findcnt = 0
     c                   eval      strpos = 1
     c                   dow       forevr = forevr
     c     pattern2:ln2  scan      daytbl:strpos pos

     c                   if        pos > 0
     c                   eval      strpos = pos + 1
     c                   eval      findcnt = findcnt + 1
     c                   endif

     c                   if        pos = 0 and findcnt = 1
     c                   leave
     c                   endif

     c                   if        pos = 31 and findcnt = 1
     c                   leave
     c                   endif

     c                   if        findcnt >1
     c                   eval      error  = *on
     C                   eval      m =13
     c                   eval      *in12 = *on
     c                   eval      *in32 = *on
     c                   exsr      zm03
     c                   goto      endck2
     c                   leave
     c                   endif


     c                   enddo
     c                   enddo


     c     endck2        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK3   Screen 3 error checking.
     C*
     c     zzchk3        begsr
      * all fields must be filled in
     c                   eval      pattern3 = ' '
     c                   eval      strpos = 1
     c     '   '         scan      mthtbl:strpos pos
     c                   if        pos > 0
     c                   move      *on           error
     C                   eval      m =14
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif
      * No duplicate codes can exist
     c                   movea     mthtbl        mthcd
     c                   do        12            x
     c                   eval      pattern3 = mthcd(x)
     c                   eval      findcnt = 0
     c                   eval      strpos = 1
     c                   dow       forevr = forevr
     c     pattern3:ln3  scan      mthtbl:strpos pos

     c                   if        pos > 0
     c                   eval      strpos = pos + 4
     c                   eval      findcnt = findcnt + 1
     c                   endif

     c                   if        pos = 0 and findcnt = 1
     c                   leave
     c                   endif

     c                   if        pos = 45 and findcnt = 1
     c                   leave
     c                   endif

     c                   if        findcnt >1
     c                   eval      error  = *on
     C                   eval      m =15
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   leave
     c                   endif

     c                   enddo
     c                   enddo

      * determine the number of characters required
     c                   eval      chr# = 0
     c                   eval      pattern = 'M3'
     c                   exsr      zzckchr#
     c                   if        chr# = 0
     c                   eval      pattern = 'M2'
     c                   exsr      zzckchr#
     c                   endif
     c                   if        chr# = 0
     c                   eval      pattern = 'M1'
     c                   exsr      zzckchr#
     c                   endif
      * Number of characters in code must = the # of M definition codes
     c                   select
      * no spaces can exist
     c                   when      chr# = 3
     c                   eval      strpos = 1
     c     ' '           scan      mthtbl:strpos pos
     c                   if        pos > 0
     c                   move      *on           error
     C                   eval      m =16
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif

     c                   when      chr# = 2
     c                   eval      strpos = 1
     c                   eval      findcnt = 0
     c                   dow       forevr = forevr
     c     ' '           scan      mthtbl:strpos pos
     c                   If        pos = 0 and findcnt < 12
     c                   move      *on           error
     C                   eval      m =17
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif

     c                   if        pos > 0
     c     pos           div       4             ckpos
     c                   mvr                     ckposr
     c                   If        ckposr <> 0
     c                   move      *on           error
     C                   eval      m =17
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif
     c                   eval      findcnt = findcnt + 1
     c                   eval      strpos = pos + 1
     c                   endif
     c                   if        strpos > 48
     c                   if        findcnt = 12
     c                   leave
     c                   else
     c                   move      *on           error
     C                   eval      m =17
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif
     c                   endif
     c
     c                   enddo

     c                   when      chr# = 1
     c                   eval      strpos = 1
     c                   eval      findcnt = 0
     c                   eval      lstpos = 0
     c                   dow       forevr = forevr
     c     '  '          scan      mthtbl:strpos pos
     c                   If        pos = 0 and findcnt < 12
     c                   move      *on           error
     C                   eval      m =18
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif

     c                   if        pos > 0
     c                   If        lstpos = 0
     c     pos           div       3             ckpos
     c                   mvr                     ckposr
     c                   If        ckposr <> 0
     c                   move      *on           error
     C                   eval      m =18
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif
     c                   else
     c                   eval      ckpos = lstpos + 4
     c                   If        ckpos  <> pos
     c                   move      *on           error
     C                   eval      m =18
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif
     c                   endif
     c                   eval      lstpos = pos
     c                   eval      findcnt = findcnt + 1
     c                   eval      strpos = pos + 1
     c                   endif
     c                   if        strpos > 47
     c                   if        findcnt = 12
     c                   leave
     c                   else
     c                   move      *on           error
     C                   eval      m =18
     c                   eval      *in14 = *on
     c                   eval      *in34 = *on
     c                   exsr      zm03
     c                   goto      endck3
     c                   endif
     c                   endif
     c
     c                   enddo
     c                   endsl
     c     endck3        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK4   Screen 4 error checking.
     C*
     c     zzchk4        begsr
      * at least year must exist
     c                   movea     yrtbl         yrcd
     c                   eval      findcnt = 0
     c                   do        36            x
     c                   if        yrcd(x) = '0000'
     c                   eval      findcnt = findcnt + 1
     c                   endif
     c                   enddo
     c                   if        findcnt = 36
     c                   move      *on           error
     C                   eval      m =19
     c                   eval      *in15 = *on
     c                   eval      *in35 = *on
     c                   exsr      zm03
     c                   goto      endck4
     c                   endif
      * Duplicate Year can't exist
     c                   movea     yrtbl         yrcd
     c                   do        36            x
     c                   if        yrcd(x) = '0000'
     c                   iter
     c                   endif
     c                   eval      pattern3 = yrcd(x)
     c                   eval      findcnt = 0
     c                   eval      strpos = 1
     c                   dow       forevr = forevr
     c     pattern3:ln3  scan      yrtbl:strpos  pos

     c                   if        pos > 0 and yrcd(x) <> '0000'
     c     pos           div       4             ckpos
     c                   mvr                     ckposr
     c                   If        ckposr <> 0
     c                   eval      strpos  = pos + 4
     c                   eval      findcnt = findcnt + 1
     C                   else
     c                   eval      strpos = pos + 1
     c                   endif
     c                   endif

     c                   if        pos = 0 and findcnt = 1
     c                   leave
     c                   endif

     c                   if        pos = 141 and findcnt = 1
     c                   leave
     c                   endif

     c                   if        findcnt >1
     c                   eval      error  = *on
     C                   eval      m =19
     c                   eval      *in15 = *on
     c                   eval      *in35 = *on
     c                   exsr      zm03
     c                   goto      endck4
     c                   leave
     c                   endif

     c                   enddo
     c                   enddo

     c     endck4        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCKCHR# Determine the number of characters required
     C*
     c     zzckchr#      begsr
     c                   eval      strpos = 1
     c                   eval      findcnt = 0
     c                   dow       forevr = forevr
     c     pattern:len   scan      mdcode:strpos pos
     c                   if        pos = 0 and findcnt = 0
     c                   leave
     c                   endif

     c                   if        pos > 0
     c                   select
     c                   When      pattern = 'M3'
     c                   eval      chr# = 3
     c                   When      pattern = 'M2'
     c                   eval      chr# = 2
     c                   When      pattern = 'M1'
     c                   eval      chr# = 1
     c                   endsl
     c                   leave
     c                   endif

     c                   enddo
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCKTYPE Validate Type Fields  - must exist
     C*
     c     zzcktype      begsr
     c                   eval      strpos = 1
     c                   eval      findcnt = 0
     c                   dow       forevr = forevr
     c     pattern:len   scan      mdcode:strpos pos
     c                   if        pos = 0 and findcnt = 0
     c                   eval      error = *on
     c                   eval      *in11 = *on
     c                   eval      *in31 = *on
     c                   exsr      zm03tp
     c                   leave
     c                   endif

     c                   if        findcnt >1
     c                   eval      error = *on
     c                   eval      *in11 = *on
     c                   eval      *in31 = *on
     c                   exsr      zm02tp
     c                   leave
     c                   endif

     c                   if        pos > 0
     c                   eval      strpos = pos + 1
     c                   eval      findcnt = findcnt + 1
     c                   endif

     c                   if        pos = 0 and findcnt = 1
     c                   leave
     c                   endif

     c                   enddo
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCKTYPENO These types must not exist
     C*
     c     zzcktypeno    begsr
     c                   eval      strpos = 1
     c     pattern:len   scan      mdcode:strpos pos
     c                   if        pos > 0
     c                   eval      error = *on
     c                   eval      *in11 = *on
     c                   eval      *in31 = *on
     c                   exsr      zm05tp
     c                   endif

     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCKTYPEOP These types are optional with additional considerations
     C*
     c     zzcktypeop    begsr
     c                   eval      strpos = 1
     c     pattern:len   scan      mdcode:strpos pos
     c*                  if        pos > 0
     c*                  eval      error = *on
     c*                  eval      *in11 = *on
     c*                  eval      *in31 = *on
     c*                  exsr      zm05tp
     c*                  endif

     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     c     zzcmd1        begsr
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     c     zzdft1        begsr
      * if save fields exist use them
     c                   If        svdflt = ' '
     c                   eval      mddef# = 0
     c                   eval      mddflt = ' '
     c                   eval      mdcode = ' '
     c                   eval      mdday  = ' '
     c                   eval      mdmnth = ' '
     c                   eval      mdmcst = 0
     c                   eval      mdyear = ' '
     c                   eval      mdycst = 0
     c                   eval      mdweek = ' '
     c                   eval      mdwcst = 0
     c                   eval      mdwbeg = ' '
     c                   else
     c                   eval      def = svdef
     c                   eval      mdcode = svcode
     c                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT2   Get default values for add.
     C*
     c     zzdft2        begsr
     C                   if        savedaytbl = ' '
     c                   eval      mttbl = ' '
     c                   else
     c                   eval      mttbl = savedaytbl
     c                   endif
     c                   eval      dcmd  = '*ADD  '
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT3   Get default values for add.
     C*
     c     zzdft3        begsr
     C                   if        savemthtbl = ' '
     c                   eval      mttbl = ' '
     c                   else
     c                   eval      mttbl = savemthtbl
     c                   endif
     c                   eval      mcmd   = '*ADD  '
     c                   eval      mtmp01 = '*'
     c                   eval      mtmp02 = '*'
     c                   eval      mtmp03 = '*'
     c                   eval      mtmp04 = '*'
     c                   eval      mtmp05 = '*'
     c                   eval      mtmp06 = '*'
     c                   eval      mtmp07 = '*'
     c                   eval      mtmp08 = '*'
     c                   eval      mtmp09 = '*'
     c                   eval      mtmp10 = '*'
     c                   eval      mtmp11 = '*'
     c                   eval      mtmp12 = '*'
     c                   endsr
     C*
     C*  ZZDFT4   Get default values for add.
     C*
     c     zzdft4        begsr
     c                   eval      mtyra  = 0
     c                   eval      mtyrb  = 0
     c                   eval      mtyrc  = 0
     c                   eval      mtyrd  = 0
     c                   eval      mtyre  = 0
     c                   eval      mtyrf  = 0
     c                   eval      mtyrg  = 0
     c                   eval      mtyrh  = 0
     c                   eval      mtyri  = 0
     c                   eval      mtyrj  = 0
     c                   eval      mtyrk  = 0
     c                   eval      mtyrl  = 0
     c                   eval      mtyrm  = 0
     c                   eval      mtyrn  = 0
     c                   eval      mtyro  = 0
     c                   eval      mtyrp  = 0
     c                   eval      mtyrq  = 0
     c                   eval      mtyrr  = 0
     c                   eval      mtyrs  = 0
     c                   eval      mtyrt  = 0
     c                   eval      mtyru  = 0
     c                   eval      mtyrv  = 0
     c                   eval      mtyrw  = 0
     c                   eval      mtyrx  = 0
     c                   eval      mtyry  = 0
     c                   eval      mtyrz  = 0
     c                   eval      mtyr0  = 0
     c                   eval      mtyr1  = 0
     c                   eval      mtyr2  = 0
     c                   eval      mtyr3  = 0
     c                   eval      mtyr4  = 0
     c                   eval      mtyr5  = 0
     c                   eval      mtyr6  = 0
     c                   eval      mtyr7  = 0
     c                   eval      mtyr8  = 0
     c                   eval      mtyr9  = 0
     c                   eval      ycmd   = '*ADD  '
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
      * if save fields exist use them
     c                   if        svdflt <> ' '
     c                   eval      def = svdef
     c                   eval      mdcode = svcode
     c                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     c     zzfil2        begsr
      * if save fields exist use them
     c                   if        savedaytbl <> ' '
     c                   eval      mttbl = savedaytbl
     c                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL3   Fill screen 3 fields with info from file.
     C*
     c     zzfil3        begsr
      * if save fields exist use them
     c                   if        savemthtbl <> ' '
     c                   eval      mttbl = savemthtbl
     c                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL4   Fill screen 4 fields with info from file.
     C*
     c     zzfil4        begsr
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET1   Get record(s) for screen 1.
     C*
     c     zzget1        begsr
     C*
     C*   Get record from main file.
     C*
     c     fileky        chain     record                             7978
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt1
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm73
     c                   goto      endgt1
     c                   end
     C*
     C*   If viewing, release record.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c     *loval        setll     record
     c                   end

     c     endgt1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET2   Get record(s) for screen 2.
     C*
     c     zzget2        begsr
     C*
     C*   Get record from main file.
     C*
     c                   eval      dcmd = ' '
     c     filekyt       chain     mfrtable                           7978
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt2
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   exsr      zzdft2
     c                   eval      dcmd = '*ADD'
     c                   end
     C*
     C*   If viewing, release record.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c     *loval        setll     mfrtable
     c                   end
     c     endgt2        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET3   Get record(s) for screen 3.
     C*
     c     zzget3        begsr
     C*
     C*   Get record from main file.
     C*
     c                   eval      mcmd = ' '
     c     filekyt       chain     mfrtable                           7978
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt3
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   exsr      zzdft3
     c                   eval      mcmd = '*ADD'
     c                   end
     C*
     C*   If viewing, release record.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c     *loval        setll     mfrtable
     c                   end
     c     endgt3        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET4   Get record(s) for screen 4.
     C*
     c     zzget4        begsr
     C*
     C*   Get record from main file.
     C*
     c                   eval      ycmd = ' '
     c     filekyt       chain     mfrtable                           7978
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt4
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   exsr      zzdft4
     c                   eval      ycmd = '*ADD'
     c                   end
     C*
     C*   If viewing, release record.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c     *loval        setll     mfrtable
     c                   end
     c     endgt4        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr

510bMc*    $pmfr#        chain     mfr
510bMc*                  If        not %found
510bMc*                  eval      mfname = *blanks
510bMc*                  endif
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pmfr#
     c                   kfld                    $pdef#
     c     filekyt       klist
     c                   kfld                    mtmfr#
     c                   kfld                    mtdef#
     c                   kfld                    mttype
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Select first screen to display.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   end
      * clear save definition fields
     c                   clear                   svdef
     c                   clear                   svcode
     C*
      * clear save data tables
     c                   clear                   savedaytbl
     c                   clear                   savemthtbl

     c                   move      $pmfr#        mdmfr#
510bAc     $pmfr#        chain     mfr
510bAc                   If        not %found
510bAc                   eval      mfname = *blanks
510bAc                   endif
     C*
640aAc                   eval      *in37 = *off
640aAc                   if        $pcmd = '*VIEW   '
640aAc                   eval      *in37 = *on
640aAc                   endif
     C*
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     c                   move      *off          error
     C*
     C*  Move screen fields to record fields
     C*
     C*
     C*
     C*   Add record
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   write     record                               79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET2)
     C*
     c                   update    record                               79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd
     c                   end
     c                   end
     C*
      * clear save fields
     c                   clear                   svdef
     c                   clear                   svcode
     C*
     C*   Move key values to parameters
     C*
     c*                  move      mfmfr#        $pcode
     c     endupd        endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2   Update Day table record
     C*
     c     zzupd2        begsr
     c                   move      *off          error
     C*
     C*   Add record
     C*
     c     dcmd          ifeq      '*ADD    '
     c                   write     mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd2
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET2)
     C*
     c                   update    mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd2
     c                   end
     c                   end
     C*
      * clear save data
     c                   clear                   savedaytbl
     C*
     C*   Move key values to parameters
     C*
     c     endupd2       endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2S  Update Day table saved rercord
     C*
     c     zzupd2s       begsr
     c                   move      *off          error
     c                   eval      mttype = 'D'
     C*
     C*   Add record
     C*
     c     dcmd          ifeq      '*ADD    '
     c                   eval      mttbl  = savedaytbl
     c                   write     mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd2s
     c                   end
     c                   else
     C*
     C*   -OR- Update record no longer locked
     C*
     c     filekyt       chain     mfrtable                           7978
     c                   eval      mttbl  = savedaytbl
     c                   update    mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd2s
     c                   end
     c                   end
     C*
      * clear save data
     c                   clear                   savedaytbl
     C*
     C*   Move key values to parameters
     C*
     c     endupd2s      endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3   Update Month table record
     C*
     c     zzupd3        begsr
     c                   move      *off          error
     C*
     C*   Add record
     C*
     c     mcmd          ifeq      '*ADD    '
     c                   write     mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd3
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET2)
     C*
     c                   update    mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd3
     c                   end
     c                   end
     C*
     C*
      * clear save data
     c                   clear                   savemthtbl
     C*
     C*   Move key values to parameters
     C*
     c     endupd3       endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD3S  Update Month table saved rercord
     C*
     c     zzupd3s       begsr
     c                   move      *off          error
     c                   eval      mttype = 'M'
     C*
     C*   Add record
     C*
     c     mcmd          ifeq      '*ADD    '
     c                   eval      mttbl  = savemthtbl
     c                   write     mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd3s
     c                   end
     c                   else
     C*
     C*   -OR- Update record no longer locked
     C*
     c     filekyt       chain     mfrtable                           7978
     c                   eval      mttbl  = savemthtbl
     c                   update    mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd3s
     c                   end
     c                   end
     C*
     C*
      * clear save data
     c                   clear                   savemthtbl
     C*
     C*   Move key values to parameters
     C*
     c     endupd3s      endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD4   Update Year table record
     C*
     c     zzupd4        begsr
     c                   move      *off          error
     C*
     C*   Add record
     C*
     c     ycmd          ifeq      '*ADD    '
     c                   write     mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd4
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET4)
     C*
     c                   update    mtrec                                79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd4
     c                   end
     c                   end
     C*
     C*
     C*   Move key values to parameters
     C*
     c     endupd4       endsr
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Definition Number
Default Definition
Day
Month
Month Custom Code
Year
Year Custom Code
Week
First Day of Week
Week Custom Code
Type
Day Table Codes
Unique Day Codes
Month Table Codes
Unique Month Codes
M3=Code Pos 1,2&3
M2=Code Pos 1&2 only
M1=Code Pos 1 only
Unique Years
Type of Date
