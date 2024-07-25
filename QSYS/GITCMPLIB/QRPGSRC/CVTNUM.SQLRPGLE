      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CVTNUM    Convert number
     *  14 May 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
     *   05/14/04  DAS  4.17
417 A*     - Created.
     *
500 A*   10/18/04  DAS  5.00
     *     - Added SQL CONNECT statment.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dec0            s             15p 0
     D dec1            s             15p 1
     D dec2            s             15p 2
     D dec3            s             15p 3
     D dec4            s             15p 4
     D dec5            s             15p 5

     *----------------------------------------------------------------
     *  Parameter
     *
     *    Input Parameters
     *      $pcmd   *NUM2STR  -  Convert number into character string.
     *              *STR2NUM  -  Convert character string into number.
     *      $pstr   String in for *STR2NUM.
     *      $pnum   Number in for *NUM2STR.
     *      $pdec   Decimal positions for *NUM2STR (0 - 5)
     *
     *    Returned Parameters
     *      $pstr   String out for *NUM2STR.
     *      $pnum   String out for *STR2NUM.
     *      $PReturn     *OK
     *                   *ERROR
     *                   *CMDERR
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *ENTRY        PLIST
     C                   PARM                    $pcmd             8
     C                   PARM                    $pstr            30
     C                   PARM                    $pnum            15 5
     C                   PARM                    $pdec             1 0
     C                   PARM                    $preturn          8

     C                   eval      $preturn = '*OK'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

500 A*  Connect to local machine. The -842 return code indicates that the
500 A*  connection is already established.
500 A
500 AC/EXEC SQL
500 AC+ CONNECT RESET
500 AC/END-EXEC
500 AC                   if        sqlstt <> '00000'
500 AC                   endif

     C                   select

     *  Number to String - 0 decimal places.

     C                   when      $pcmd = '*NUM2STR' and $pdec = 0
     C                   eval      dec0 = $pnum
     C/Exec SQL
     C+   Set :$pstr = char(:dec0)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Number to String - 1 decimal places.

     C                   when      $pcmd = '*NUM2STR' and $pdec = 1
     C                   eval      dec1 = $pnum
     C/Exec SQL
     C+   Set :$pstr = char(:dec1)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Number to String - 2 decimal places.

     C                   when      $pcmd = '*NUM2STR' and $pdec = 2
     C                   eval      dec2 = $pnum
     C/Exec SQL
     C+   Set :$pstr = char(:dec2)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Number to String - 3 decimal places.

     C                   when      $pcmd = '*NUM2STR' and $pdec = 3
     C                   eval      dec3 = $pnum
     C/Exec SQL
     C+   Set :$pstr = char(:dec3)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Number to String - 4 decimal places.

     C                   when      $pcmd = '*NUM2STR' and $pdec = 4
     C                   eval      dec4 = $pnum
     C/Exec SQL
     C+   Set :$pstr = char(:dec4)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Number to String - 5 decimal places.

     C                   when      $pcmd = '*NUM2STR' and $pdec = 5
     C                   eval      dec5 = $pnum
     C/Exec SQL
     C+   Set :$pstr = char(:dec5)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Number to String - Decimal place Error.

     C                   when      $pcmd = '*NUM2STR'
     C                   eval      $preturn = '*ERROR'

     *  String to Number.

     C                   when      $pcmd = '*STR2NUM'
     C/Exec SQL
     C+   Set :$pnum = decimal(:$pstr,15,5)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     *  Invalid command.

     C                   other
     C                   eval      $preturn = '*CMDERR'

     C                   endsl

     C                   Return
