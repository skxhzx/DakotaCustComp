     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  II266  Initialize item files for Stand-Alone Truck Builder
     *  14 June 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/14/05  MLB  5.00
     *      - Created.
500aA*    06/14/05  MLB  5.00a
     *      - Enh: Added client custom code support.
500bA*    08/29/05  MLB  5.00b
     *      - Enh: Added ACTIVITY, BLDCODE to program.
     *
     *    09/14/05  RLP  6.00a
     *      - Replace /COPY statements for WebSmart project.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

600aD */copy qcopysrc,c#stdvar
600aAD activerec       c                   'A'
600aAD deletedrec      c                   'D'
600aAD inactiverec     c                   'I'

600aAD null            c                   x'00'
600aAD quote           c                   Const('''')
600aAD sq              c                   Const('''')
600aAD dq              c                   Const('"')

600aAD changed         s               n
600aAD error           s               n
600aAD found           s               n
600aAD forever         s               n   inz(*ON)
600aAD leavepgm        s               n
600aAD lock            s               n
600aAD lock1           s               n
600aAD lock2           s               n
600aAD lock3           s               n
600aAD lock4           s               n
600aAD lock5           s               n
600aAD filebeg         s               n
600aAD fileend         s               n
600aAD warn            s               n

600aAD i               s              7  0
600aAD j               s              7  0
600aAD x               s              7  0
600aAD y               s              7  0
600aAD loopmax         s              7  0

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

600aD */copy qcopysrc,c#pgminfds
600aAD pssrflag        s               n

600aAD                sds
600aAD  #pgm                   1     10
600aAD  #status               11     15
600aAD  #stmt                 21     28  0
600aAD  #routine              29     36
600aAD  #pgmmsg               91    170
600aAD  #job                 244    253
600aAD  #user                254    263
600aAD  #jobnbr              264    269
600aAD  #jobdate             276    281  0
600aAD  #jobtime             282    287  0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

600aD */copy qcopysrc,c#stdsql
600aAD sqlfetchcount   s              5s 0
600aAD sqlfrom         s             50a   inz(' ')
600aAD sqllastrrn      s              5s 0
600aAD sqlorder        s            100a   inz(' ')
600aAD sqlrelpos       s              5s 0
600aAD sqlrrn          s              5s 0
600aAD sqlstmt         s           2000a   inz(' ')
600aAD sqljoin         s            200a   inz(' ')
600aAD sqljoin2        s            200a   inz(' ')
600aAD sqlwhere        S            500a   inz(' ')

500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*----------------------------------------------------------------
500aA
500aA
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D curdate         s              8  0
     D curtime         s              6  0
     D currstamp       s               z
     D currdts         s             26a

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

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
     *  Parameters
     *
     *    Input Parameters
     *
     *      $PWHSE  Warehouse
     *
     *    Returned Parameters
     *
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C**   *entry        plist
     C**                 parm                    $pwhse           15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Get current date and time.

     C                   time                    curtime
     C                   time                    currstamp
     C                   move      currstamp     currdts
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o

     *  Delete items

     C/EXEC SQL
     C+   delete from piritem
     C+   where itwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete item misc info.

     C/EXEC SQL
     C+   delete from itemmsc
     C+   where imwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete extended item description file

     C/EXEC SQL
     C+   delete from itemdsc
     C+   where ixwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete item links

     C/EXEC SQL
     C+   delete from itemlnk
     C+   where ilwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete item quantities

     C/EXEC SQL
     C+   delete from itemqty
     C+   where iqwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

500b *  Delete Activity zone records.

500b C/EXEC SQL
500b C+   delete from activity
500b C/END-EXEC
500b C                   if        sqlstt <> '00000'
500b C                   endif

500b *  Delete Build Code records.

500b C/EXEC SQL
500b C+   delete from bldcode
500b C/END-EXEC
500b C                   if        sqlstt <> '00000'
500b C                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return

500aA*----------------------------------------------------------------
500aA*
500aA*  *INZSR  Initialization subroutine
500aA*
500aAC     *INZSR        begsr
500aA*
500aA* Get client id.
500aA*
500aAC                   call      'GETCLIENT'
500aAC                   parm                    client           10
500aA*
500aAC                   endsr
