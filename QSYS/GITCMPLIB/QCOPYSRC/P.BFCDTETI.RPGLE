
     *----------------------------------------------------------------
     * Begin P.BTSDTETI - Prototypes for date/time functions
     *   01/24/04  DAS  1.00
     *     - Created
     *   09/22/08  DAS  5.20a
     *     - Added dayOfWeek, weekOfYear, endOfMonth, endOfQuarter,
     *       endOfYear.
740 A*   10/15/20  KDE  7.40
     *     - Added code to verify library in list to know if Timezone
     *       400 exist in environment
     *----------------------------------------------------------------

     *---------------------------------------------------------------
     * TZNAPI10  -  Timezone/400 External call to get time offset
     *
     *   Usage:
     *
     *      call p tznapi10(pUser:pOffset:pError)
     *
     *   Return Value:
     *      pOffset has + or - then hours and minutes as -07:00
     *       for 7 hours earlier and universal and +07:00 for
     *       for 7 hours later than universal
     *
     *   Parameters:
     *     $pUser     - User for work
     *
     *---------------------------------------------------------------

730gAD tznapi10        PR                  EXTPGM('TZNAPI10')
730gAD  $pUser                       10
730gAD  $pOffset                      6
730gAd  $pError                       7
     *---------------------------------------------------------------
     * getmicrotime  - Get microsecond time.
     *
     *   Usage:
     *
     *      callp   getmicrotime($uctime:$localtime)
     *
     *   Return Value:
     *      none
     *
     *   Parameters:
     *     $uctime    -  Universal Coordinate Time
     *     $localtime - Local time.
     *
     *---------------------------------------------------------------

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z

     *---------------------------------------------------------------
     * local2uc  - Convert local time to Universal Coordianate time
     *
     *   Usage:
     *
     *      callp   local2uc($local:$uc)
     *
     *   Return Value:
     *      none
     *
     *   Parameters:
     *     $plocal   -  Local time.
     *     $puc      -  Universal Coordinate Time
     *
     *---------------------------------------------------------------

     D local2uc        pr
     D  $plocal                        z
     D  $puc                           z

     *---------------------------------------------------------------
     * dursecymd - Calculate seconds between two YMD date/times
     *
     *   Usage:
     *
     *      eval   dursec = dursecymd(%len(dursec):$fdte:$ftim:$tdte:$ttim)
     *
     *   Return Value:
     *     duration in seconds
     *
     *   Parameters:
     *     %len  - Length of result field (0 decimal places assumed)
     *     $fdte - From date (YYYYMMDD)
     *     $ftim - From time (HHMMSS)
     *     $tdte - To date (YYYYMMDD)
     *     $ttim - To time (HHMMSS)
     *
     *---------------------------------------------------------------

     D dursecymd       pr             7  0
     D  $psize                        3  0 value
     D  $pfromdate                    8  0
     D  $pfromtime                    6  0
     D  $ptodate                      8  0
     D  $ptotime                      6  0

     *---------------------------------------------------------------
     * dursects  - Calculate seconds between two timestamps
     *
     *   Usage:
     *
     *      eval   dursec = dursecymd(%len(dursec):$fts:$tts)
     *
     *   Return Value:
     *     duration in seconds
     *
     *   Parameters:
     *     %len  - Length of result field (0 decimal places assumed)
     *     $fts  - From timestamp
     *     $tts  - To timestamp
     *
     *---------------------------------------------------------------

     D dursects        pr             7  0
     D  $psize                        3  0 value
     D  $pfromts                       z
     D  $ptots                         z

     *---------------------------------------------------------------
     * durminymd - Calculate minutes between two YMD date/times
     *
     *   Usage:
     *
     *      eval   durmin = durminymd(%len(durmin):$fdte:$ftim:$tdte:$ttim)
     *
     *   Return Value:
     *     duration in minutes
     *
     *   Parameters:
     *     %len  - Length of result field (2 decimal places assumed)
     *     $fdte - From date (YYYYMMDD)
     *     $ftim - From time (HHMMSS)
     *     $tdte - To date (YYYYMMDD)
     *     $ttim - To time (HHMMSS)
     *
     *---------------------------------------------------------------

     D durminymd       pr             9  2
     D  $psize                        3  0 value
     D  $pfromdate                    8  0
     D  $pfromtime                    6  0
     D  $ptodate                      8  0
     D  $ptotime                      6  0

     *---------------------------------------------------------------
     * durmints  - Calculate minutes between two timestamps
     *
     *   Usage:
     *
     *      eval   durmin = durminymd(%len(durmin):$fts:$tts)
     *
     *   Return Value:
     *     duration in minutes
     *
     *   Parameters:
     *     %len  - Length of result field (2 decimal places assumed)
     *     $fts  - From timestamp
     *     $tts  - To timestamp
     *
     *---------------------------------------------------------------

     D durmints        pr             9  2
     D  $psize                        3  0 value
     D  $pfromts                       z
     D  $ptots                         z

     *---------------------------------------------------------------
     * durhrsymd - Calculate hours between two YMD date/times
     *
     *   Usage:
     *
     *      eval   durhrs = durhrsymd(%len(durhrs):$fdte:$ftim:$tdte:$ttim)
     *
     *   Return Value:
     *     duration in hours
     *
     *   Parameters:
     *     %len  - Length of result field (2 decimal places assumed)
     *     $fdte - From date (YYYYMMDD)
     *     $ftim - From time (HHMMSS)
     *     $tdte - To date (YYYYMMDD)
     *     $ttim - To time (HHMMSS)
     *
     *---------------------------------------------------------------

     D durhrsymd       pr             9  2
     D  $psize                        3  0 value
     D  $pfromdate                    8  0
     D  $pfromtime                    6  0
     D  $ptodate                      8  0
     D  $ptotime                      6  0

     *---------------------------------------------------------------
     * durhrsts  - Calculate hours between two timestamps
     *
     *   Usage:
     *
     *      eval   durhrs = durhrsymd(%len(durhrs):$fts:$tts)
     *
     *   Return Value:
     *     duration in hours
     *
     *   Parameters:
     *     %len  - Length of result field (2 decimal places assumed)
     *     $fts  - From timestamp
     *     $tts  - To timestamp
     *
     *---------------------------------------------------------------

     D durhrsts        pr             9  2
     D  $psize                        3  0 value
     D  $pfromts                       z
     D  $ptots                         z

     *---------------------------------------------------------------
     * durdayymd - Calculate days between two YMD date/times
     *
     *   Usage:
     *
     *      eval   durday = durdayymd(%len(durday):$fdte:$ftim:$tdte:$ttim)
     *
     *   Return Value:
     *     duration in days
     *
     *   Parameters:
     *     %len  - Length of result field (2 decimal places assumed)
     *     $fdte - From date (YYYYMMDD)
     *     $ftim - From time (HHMMSS)
     *     $tdte - To date (YYYYMMDD)
     *     $ttim - To time (HHMMSS)
     *
     *---------------------------------------------------------------

     D durdayymd       pr             9  2
     D  $psize                        3  0 value
     D  $pfromdate                    8  0
     D  $pfromtime                    6  0
     D  $ptodate                      8  0
     D  $ptotime                      6  0

     *---------------------------------------------------------------
     * durdayts  - Calculate hours between two timestamps
     *
     *   Usage:
     *
     *      eval   durday = durdayymd(%len(durday):$fts:$tts)
     *
     *   Return Value:
     *     duration in days
     *
     *   Parameters:
     *     %len  - Length of result field (2 decimal places assumed)
     *     $fts  - From timestamp
     *     $tts  - To timestamp
     *
     *---------------------------------------------------------------

     D durdayts        pr             9  2
     D  $psize                        3  0 value
     D  $pfromts                       z
     D  $ptots                         z

520aA*---------------------------------------------------------------
520aA* dayOfWeek - Calculate day of week
520aA*
520aA*   Usage:
520aA*
520aA*      eval   dow = dayOfWeek(timestamp)
520aA*
520aA*   Return Value:
520aA*     day of week (1=Sunday)
520aA*
520aA*   Parameters:
520aA*     pStamp  -  timestamp
520aA*
520aA*---------------------------------------------------------------

     D dayOfWeek       pr             1  0
     D  pStamp                         z

520aA*---------------------------------------------------------------
520aA* weekOfYear  -  Calculate week number for year
520aA*
520aA*   Usage:
520aA*
520aA*      eval   woy = weekOfYear(timestamp)
520aA*
520aA*   Return Value:
520aA*     week of year
520aA*
520aA*   Parameters:
520aA*     pStamp  -  timestamp
520aA*
520aA*---------------------------------------------------------------

     D weekOfYear      pr             2  0
     D  pStamp                         z

520aA*---------------------------------------------------------------
520aA* endOfMonth  -  Determine if date is end of month
520aA*
520aA*   Usage:
520aA*
520aA*      eval   eom = endOfMonth(date)
520aA*
520aA*   Return Value:
520aA*     flag (*on = end of month)
520aA*
520aA*   Parameters:
520aA*     pDate   -  date
520aA*
520aA*---------------------------------------------------------------

     D endOfMonth      pr              n
     D  pDate                          d

520aA*---------------------------------------------------------------
520aA* endOfQuarter -  Determine if date is end of quarter
520aA*
520aA*   Usage:
520aA*
520aA*      eval   eoq = endOfQuarter(date)
520aA*
520aA*   Return Value:
520aA*     flag (*on = end of quarter)
520aA*
520aA*   Parameters:
520aA*     pDate   -  date
520aA*
520aA*---------------------------------------------------------------

     D endOfQuarter    pr              n
     D  pDate                          d

520aA*---------------------------------------------------------------
520aA* endOfYear -  Determine if date is end of year
520aA*
520aA*   Usage:
520aA*
520aA*      eval   eoy = endOfYear(date)
520aA*
520aA*   Return Value:
520aA*     flag (*on = end of year)
520aA*
520aA*   Parameters:
520aA*     pDate   -  date
520aA*
520aA*---------------------------------------------------------------

     D endOfYear       pr              n
     D  pDate                          d

     *** End P.BTSDTETI ***

740 A*---------------------------------------------------------------
740 A* #verLib   -  Verify whether library exist in library list
740 A*
740 A*   Usage:
740 A*
740 A*      if #verLib(Library:LibraryType)  as strings
740 A*
740 A*   Return Value:
740 A*     on or off value
740 A*
740 A*   Parameters:
740 A*     pLib    -  Library searched for in list
740 A*     pLibType-  List type
740 A*                *SYSTEM, *PRODUCT, *CURRENT, or *USER
740 A*
740 A*---------------------------------------------------------------
740 Ad #verLib         pr              n
740 Ad  sLib                         10    const
740 Ad  sLibType                     10    const

740 A*---------------------------------------------------------------
740 A* #rtvLibl  -  Retrieve specific library list based on type requested
740 A*
740 A*   Usage:
740 A*
740 A*      if #verLib(LibraryType)  as strings
740 A*
740 A*   Return Value:
740 A*     Array with library list entries
740 A*
740 A*   Parameters:
740 A*     pLibType-  List type
740 A*                *SYSTEM, *PRODUCT, *CURRENT, or *USER
740 A*
740 A*---------------------------------------------------------------
740 Ad #rtvLibl        pr              *
740 Ad  sLibType                     10    const
