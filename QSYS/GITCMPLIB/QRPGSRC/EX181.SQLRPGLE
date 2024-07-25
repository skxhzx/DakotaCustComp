     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  EX181   UPC Add exception report.
     *  31 August 2014
     *  Rod Roller
     *
     *  Revisions:
     *
650 A*    08/31/14  RTR  6.50
     *      - Created using EX166
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  90        Report Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fitmexcp   if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fex181pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *  File data data structure
     *
     D excprec       e ds                  extname(itmexcp) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Table and array
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D cls             s              5  0 dim(3)
     D desc            s             50    dim(1) ctdata perrcd(1)
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
     D pfmdt           s              8s 0
     D ptodt           s              8s 0
     D pwhse           s              3s 0
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
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $from             8
     C                   parm                    $to               8
     *----------------------------------------------------------------
     *
      /free
        exec Sql
          declare recs cursor for
            select * from itmexcp
             where exwhse = :pwhse
               and extask = 'UPCADD'
               and exgdte >= :pfmdt
               and exgdte <= :ptodt
            order by exgdte,exgtim,exitem;

        exec sql open recs;
        if sqlstt <> sqlSuccess;
        //leave;
        endif;

        dow forever = forever;
          exec sql fetch next from recs
                   into :excprec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

      /end-free
     *
     *  Retrieve item description.
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = desc(1)
     C                   endif
     *
     *  Build UPC Number
     C                   eval      upcdsp = exfdis + extdis
     *
     *  Convert datestamp to date/time output fields.
     C                   if        exgdte <> 0
     C                   move      exgdte        datestamp
     C                   move      exgtim        timestamp
     C     *mdy/         movel     datestamp     genodt
     C                   eval      genout = genodt
     C                   if        timestamp < noon
     C                   eval      gentim = %subst(%char(timestamp):1:5)
     C                                     + ' am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C                   eval      gentim = %subst(%char(timestamp):1:5)
     C                                     + ' pm'
     C                   endif
     C                   endif
     *
     *  Write detail line
     C                   write     detail1
     C                   add       1             reck(1)
     *
     *  Write header if end of page
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   endif
     *
     C                   enddo
     *
      /free
        exec sql close recs;
      /end-free
     *
     *  Report totals
     C                   write     skip1
     C                   write     foot1
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      dftstamp = *loval
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C     itkey         klist
     C                   kfld                    exwhse
     C                   kfld                    exitem
     *
     *   Get report title.
     *
     C                   movel     'EX181PR '    wkprtf
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
     *   Convert warehouse to numeric.
     *
     C                   monitor
     C                   eval      pwhse = %dec($whse:3:0)
     C                   on-error
     C                   eval      pwhse = 0
     C                   endmon
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     pwhse         chain     warehs                             79
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
     C                   eval      p#desc = *blanks
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     *   Convert dates to numeric.
     *
     C                   monitor
     C                   eval      pfmdt = %dec($from:8:0)
     C                   on-error
     C                   eval      pfmdt = 0
     C                   endmon
     C                   monitor
     C                   eval      ptodt = %dec($to:8:0)
     C                   on-error
     C                   eval      ptodt = 0
     C                   endmon
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
     C                   eval      $cvprg = #prog
     *
     C                   eval      l = 3
     C                   eval      *in90 = *on
     C                   exsr      zrhead
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *  Report Heading
     C                   eval      p#desc = *blanks
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     *  Output Headings
     *
     C                   write     rphead
     C                   write     head1
     C                   write     head2
     C                   write     columns
     C                   eval      *in90 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
** Descriptions
-- Item not found ---
