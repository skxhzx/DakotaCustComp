     *---------------------------------------------------------------*
     *    Application:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX             *
     *    Program Name:  GETDLTSV                                    *
     *    Source File:   QRPGLESRC                                   *
     *    Description:   Get Daylight Saving time change dates       *
     *                   parms                                       *
     *---------------------------------------------------------------*
     *    Author:   Chris Durbin                                     *
     *    Date:     10/29/2001                                       *
     *    TASK:                                                      *
     *---------------------------------------------------------------*
     *    R E V I S I O N S                                          *
     *                                                               *
     *  Date       Programmer          Comments                      *
     *  2001/10/30 Chris Durbin   Modified from code provided by John*
     *                            Buchanan, this program will calc   *
     *                            the daylight savings time spring   *
     *                            and fall dates and return them to  *
     *                            the calling CL in order to automate*
     *                            adjusting the clock.               *
     *---------------------------------------------------------------*
     d fdate           s              8
     d sdate           s              8
     d days1           s              7  2
     d days2           s              5  0
     d x               s              1  0
     d z               s              4  0
     d day#            s              1
     d dadiff          s              2  2
     d days            s              3  0 dim(12) CTDATA PERRCD(12)
     d                 ds
     ddate                     1      8  0
     dy                        1      4  0
     dm                        5      6  0
     dd                        7      8  0
     d                 ds
     dmdy                      1      8  0
     dmx                       1      2  0
     ddx                       3      4  0
     dyx                       5      8  0
     *---------------------------------------------------------------------
     C*
     C*    Calculate Spring Ahead date.
     c                   move      sdate         date
     c                   exsr      getday
     c                   if        x > 1
     c                   eval      date = date + 8-x
     c                   endif
     C*
     C*    Convert date to mm/dd/yyyy format.
     c                   eval      mx = m
     c                   eval      dx = d
     c                   eval      yx = y
     c                   move      mdy           sdate
     C*
     C*    Calculate Fall Back date.
     c                   move      fdate         date
     c                   exsr      getday
     c                   if        x > 1
     c                   eval      date = date -(x - 1)
     c                   endif
     C*
     C*    Convert date to mm/dd/yyyy format.
     c                   eval      mx = m
     c                   eval      dx = d
     c                   eval      yx = y
     c                   move      mdy           fdate
     C*
     c                   eval      *inlr = *on
     C*
     *---------------------------------------------------------------------
     c     getday        BEGSR
     *---------------------------------------------------------------------
     c                   eval      z = y-1900
     c                   eval      Days1 = z*365.25
     c                   move      days1         Dadiff
     c                   if        m<3 and dadiff = 0 and z <> 0
     c                   eval      days1 = days1 - 1
     c                   endif
     c                   eval      days2 = (days1 + days(M) + d)
     c                   div       7             days2
     c                   mvr                     x
     c                   eval      x = x + 1
     c                   eval      day# = %editw(x:' ')
     c                   endsr
     *---------------------------------------------------------------------
     c     *inzsr        BEGSR
     *---------------------------------------------------------------------
     c     *entry        plist
     c                   parm                    sdate
     c                   parm                    fdate
     c                   endsr
**
000031059090120151181212243273304334
