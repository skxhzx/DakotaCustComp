     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PR341   Priority Replenishment report - TPC
     *  29 October, 2007
     *  Lynn McMahon
     *
     *  Revisions:
     *
510aA*    10/29/07  LMC  5.10a
     *      - Created
720aA*    09/10/18  RH   7.20a
     *      - Converted to ILE
     *      - Add client code
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Tiffin Paper Co.
TPC A*    09/10/18  RH   TPCa
     *      - Revised program when skip 'D' completed replenishments
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpr341     ip   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpr341pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D cls             s              5  0 dim(3)
720aA*----------------------------------------------------------------
720aA*  Customer id
720aA*
     D @getcl          c                   const('GETCLIENT')
500aA*
TPC A /COPY QCOPYSRC,ID#TPC
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *  Variables
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D gendte          s              6  0
     D l               s              1  0
     D m               s                   like(l)
     D wkprtf          s             10
     *                   DESC    1   9 50
     *----------------------------------------------------------------
     Ioqrec
     *                                             EXESTAL2
     I                                          prwhdp        l1
     I                                          prwhse        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $whdp             5
     C                   parm                    $faisl            4
     C                   parm                    $taisl            4
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     C                   if        *in90  or
     C                             *inl1
     C                   exsr      zrzero
     *
     *  Format Dept
     *
     C                   eval      p#desc = *blanks
     C     'Dept:'       cat       prwhdp:1      p#desc
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Dept/Section
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   endif
     *
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             *inl1
     C                   if        *in91
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
TPCaAC                   if        client = tpc and
TPCaAC                             prflag = 'D'
TPCaAC                   goto      jump1
TPCaAC                   endif
     *  Convert Generated date
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      pradte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      gendte = $cvd6o
     *
     *  Retrieve item description.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
     *
     *  Write detail line
     *
     C                   write     detail1
     *
     *  Accumulate totals
     *
     C                   add       1             cls(1)
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
720aAC     jump1         tag
     *----------------------------------------------------------------
     *
     * Slot type totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 write     skip1
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 3
     *
     CLr                 if        reck(l) > 0
     CLr                 write     skip1
     CLr                 write     foot1
     CLr                 endif
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
720aA*
720aA* Get client id.
720aA*
720aAC                   call      @getcl
720aAC                   parm                    client           10
720aAC                   parm                    cliloc           10
720aA*
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C     itkey         klist
     C                   kfld                    prwhse
     C                   kfld                    pritem
     *
     C                   eval      fais = $faisl
     C                   eval      tais = $taisl
     *
     *   Get report title.
     *
     C                   movel     'PR341PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     *
     *   Convert dates to MMDDYY format.
     *
     *R                   MOVE '*CMDMDY '$CVCMD
     *R                   MOVE $FROM     $CVD8I
     *R                   CALL @CVTDT
     *R                   PARM           $CVTDT
     *R                   Z-ADD$CVD6O    FMDT    60
     *
     *R                   MOVE '*CMDMDY '$CVCMD
     *R                   MOVE $TO       $CVD8I
     *R                   CALL @CVTDT
     *R                   PARM           $CVTDT
     *R                   Z-ADD$CVD6O    TODT    60
     *
     *
     C                   eval      $cvprg = #prog
     *
     C                   eval      l = 3
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     prwhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     *  Format Dept
     *
     C                   eval      p#desc = *blanks
     C     'Dept:'       cat       prwhdp:1      p#desc
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     C                   exsr      zrfrmt
     *
     C                   write     head1
     C                   write     head2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   add       cls(l)        cls(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#cls = cls(l)
     C                   if        l = 1
     C                   write     total1
     C                   endif
     *
     C                   if        l = 2
     C                   write     total2
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      cls(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
