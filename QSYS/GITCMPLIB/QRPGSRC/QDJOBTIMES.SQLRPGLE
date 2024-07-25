     *----------------------------------------------------------------
     *
     *  QDJOBTIMES  Calculate times between GC's in GLOGCHIST file
     *  12 April 2016
     *  Mike Roker
     *
     *  Revisions
     *
     *    4/12/16  DAS  700a
     *     - Removed library name from SQL statements
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

SVL Ad  time           s              8s 0
SVL Ad  dashes         s              1a
SVL Ad  dots           s              1a
SVL Ad  wdate          s             21a
SVL Ad  begdate        s             26a
SVL Ad  enddate        s             26a
SVL Ad $nextcycle      s              5s 0
SVL Ad $lastjobno      s              6a
SVL Ad $strdate        ds
     d  $mon                   1      2a
     d  $s1                    3      3a
     d  $day                   4      5a
     d  $s2                    6      6a
     d  $year                  7      8a
     d  $s3                    9      9a
     d  $hour                 10     11a
     d  $col1                 12     12a
     d  $min                  13     14a
     d  $col2                 15     15a
     d  $sec                  16     17a
     d  $col3                 18     18a
     d  $msec                 19     21a
SVL Ad $cvndate        ds
     d  $centc                 1      2a
     d  $yearc                 3      4a
     d  d1                     5      5a
     d  $monc                  6      7a
     d  d2                     8      8a
     d  $dayc                  9     10a
     d  d3                    11     11a
     d  $hourc                12     13a
     d  dt1                   14     14a
     d  $minc                 15     16a
     d  dt2                   17     17a
     d  $secc                 18     19a
     d  dt3                   20     20a
     d  $msecc                21     23a
     d  ms1                   24     26a

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
SVL Ad DataDS          ds
SVL Ad $gcycle                        5s 0
SVL Ad $gcend                        21a
SVL Ad $gclient                      10a
SVL Ad $gcjobuser                    10a
SVL Ad $gcjob                        10a
SVL Ad $gcjobnum                      6a

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free
       eval dashes = '-';
       eval d1 = dashes;
       eval d2 = dashes;
       eval d3 = dashes;
       eval dots   = '.';
       eval dt1 = dots;
       eval dt2 = dots;
       eval dt3 = dots;
       eval ms1 = '000';
       eval $centc = '20';
       //Declare the cursor
       exec sql
         Declare C1 cursor for
           Select gccycle, gcend, gcclient, gcjobuser, gcjob,
           gcjobnbr
           from glogchist
           order by gcclient, gcjobuser, gcjob, gcjobnbr, gccycle;

       //Open the cursor
       exec sql
         Open C1;
       //Fetch data in a loop
        Dou sqlcod <> 0;
        exec sql
          Fetch C1 INTO :DataDS;

          If (sqlcod <> 0);
            Leave;
          Endif;
          if $lastjobno <> $gcjobnum;
             exec sql
             Update glogchist set gcheapfre = 0 where
             gcclient = :$gclient and gcjobuser = :$gcjobuser and
             gcjob = :$gcjob and gcjobnbr = :$gcjobnum and
             gccycle = :$gcycle;
          endif;
            $nextcycle = $gcycle + 1;
         exec sql
          select gcstart into :wdate    from glogchist
          where gcclient = :$gclient and gcjobuser = :$gcjobuser
          and gcjob = :$gcjob and gcjobnbr = :$gcjobnum and
          gccycle = :$nextcycle;

          if sqlcode = 0;
          eval $strdate = wdate;
          eval $monc = $mon;
          eval $dayc = $day;
          eval $yearc = $year;
          eval $hourc = $hour;
          eval $minc = $min;
          eval $secc = $sec;
          eval $msecc = $msec;
          eval begdate = $cvndate;
          eval wdate = $gcend;
          eval $strdate = wdate;
          eval $monc = $mon;
          eval $dayc = $day;
          eval $yearc = $year;
          eval $hourc = $hour;
          eval $minc = $min;
          eval $secc = $sec;
          eval $msecc = $msec;
          eval enddate = $cvndate;
          time = %DIFF (%timestamp(begdate):%timestamp(enddate)
               : *mseconds) / 1000;

          if time >= 9999999;
              time = 9999999;
          endif;

        exec sql
           Update glogchist set gcheapfre = :time where
             gcclient = :$gclient and gcjobuser = :$gcjobuser and
             gcjob = :$gcjob and gcjobnbr = :$gcjobnum and
             gccycle = :$nextcycle;

          Endif;
          eval $lastjobno = $gcjobnum;
          eval sqlcod = 0;

        Enddo;
       //Close the cursor
        exec sql
          Close C1;

        *inlr = *on;

       /end-free
