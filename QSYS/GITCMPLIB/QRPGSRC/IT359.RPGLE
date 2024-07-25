     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  #8-51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT359   Department Inventory Activity report.
     *  07 May 2007
     *  Retha Davis
     *
     *  Revisions:
     *
     *    05/07/07  RBD  5.10
     *      - Created
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Flabel     ip   e           k disk
     Fit357a    if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fit359pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D                 ds
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
     D  dsupc                  1     20
     *----------------------------------------------------------------
     *  Variables
     D whs#            s              3  0
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D datestamp       s               d
     D dftstamp        s               z
     D fmdt            s              6  0
     D genodt          s              8
     D hmsmdy          s             12  0
     D l               s              1  0
     D m               s                   like(l)
     D noon            s               t   inz(t'12.00.00')
     D timestamp       s               t
     D todt            s              6  0
     D wkprtf          s             10
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
     *----------------------------------------------------------------
     Ilbrec
     I                                          lbwhdp        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $from             8
     C                   parm                    $to               8
     *----------------------------------------------------------------
     *
     *  Init total levels
     *
     *  Level 1 break - Department
     *
     C                   if        *inl1
     C                   eval      rcvqty = 0
     C                   eval      pckqty = 0
     C                   eval      adjqty = 0
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Accumulate department totals
     *
     C                   select
     C                   when      lbtype = 'P'
     C                   eval      rcvqty = rcvqty + lbqpck
     C                   when      lbtype = 'A'
     C                   eval      adjqty = adjqty + lbqpck
     C                   endsl
     *
     *----------------------------------------------------------------
     *
     * Department totals
     *
     CL1   lbwhdp        chain     it357a
     CL1                 eval      pckqty = 0
     CL1                 if        %found
     CL1                 eval      pckqty = wbpck
     CL1                 eval      pckl9 = pckl9 + wbpck
     CL1                 endif

     CL1                 eval      rcvl9 = rcvl9 + rcvqty
     CL1                 eval      adjl9 = adjl9 + adjqty
     CL1                 if        *in90 = *on
     CL1                 exsr      zrhead
     CL1                 endif
     CL1                 write     total1
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLR                 if        *in90 = *on
     CLR                 exsr      zrhead
     CLR                 endif
     CLR                 write     total9
     CLR                 write     foot1
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
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     *   Get report title.
     *
     C                   movel     'IT359PR '    wkprtf
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
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $from
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      fmdt = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $to
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      todt = $cvd6o
     *
     *
     C                   eval      $cvprg = #prog
     *
     C                   exsr      zrhead
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   move      $whse         whs#
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     whs#          chain     warehs                             79
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
     C                   time                    time
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   exsr      zrfrmt
     *
     C                   write     head1
     C                   write     columns
     C                   endsr
     *----------------------------------------------------------------
