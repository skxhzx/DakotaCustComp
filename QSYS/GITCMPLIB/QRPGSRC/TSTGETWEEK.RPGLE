      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *  TSTGETWEEK   Test GETWEEK
     *  06 June 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $gwStamp        s               z
     D $gwWeek         s              2  0
     D $gwDOW          s              1  0
     D $gwSunday       s              6  0

     C                   eval      $gwStamp = %timestamp()

     C                   call      'GETWEEK'
     C                   parm                    $gwStamp
     C                   parm                    $gwWeek
     C                   parm                    $gwDOW
     C                   parm                    $gwSunday

     C                   eval      *inlr = *on
