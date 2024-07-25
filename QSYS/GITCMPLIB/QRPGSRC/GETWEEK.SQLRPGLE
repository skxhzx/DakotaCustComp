      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  GETWEEK   Get week information
     *  06 June 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pStamp         s               z
     D $pWeek          s              2  0
     D $pDOW           s              1  0
     D $pSunday        s              6  0

     D string10        s             10
     D sunday          s               d
     D yymmdd          s              6

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pStamp  Date stamp
     *
     *    Returned Parameters
     *      $pWeek    Week number for stamp
     *      $pDOW     Day of week (1=Sunday)
     *      $pSunday  Sunday's date for week (YYMMDD)
     *                (Note, we only use YY because we don't beleive
     *                 the program will be around in 92 years)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pStamp
     C                   parm                    $pWeek
     C                   parm                    $pDOW
     C                   parm                    $pSunday

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

500 A*  Connect to local machine. The -842 return code indicates that the
500 A*  connection is already established.
500 A
500 A*  This was commented out because it was generating a long job log
500 A*  message saying that the connection already existed.
500 A
500 AC*EXEC SQL
500 AC* CONNECT RESET
500 AC*END-EXEC
500 AC*                  if        sqlstt <> '00000'
500 AC*                  endif

     *  Get current week
     *  Get current day of week

     C/Exec SQL
     C+   Set :$pWeek = week(:$pStamp),
     C+       :$pDOW  = dayofweek(:$pStamp)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Calculate Sunday's date of current week.

     C                   eval      sunday = %date($pStamp-%days($pDOW-1))
     C                   eval      string10 = %char(sunday)
     C                   eval      yymmdd   = %subst(string10:3:2)
     C                                      + %subst(string10:6:2)
     C                                      + %subst(string10:9:2)
     C                   eval      $pSunday = %dec(yymmdd:6:0)

     C                   Return
