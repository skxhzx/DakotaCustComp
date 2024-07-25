     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
417bA*----------------------------------------------------------------
417bA*   Compile Options: OPTIONS(*CVTDT)
417bA*
417bA*----------------------------------------------------------------
     *
     *  INZTBS  Initialize files for Truck Builder Selection
     *  39 March 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    03/30/04  DAS  4.17
     *      - Created.
417aA*    08/10/04  MLB  4.17a
     *      - Enh: Revised pgm to set ORDH records to closed/exported.
417bA*    09/09/04  MLB  4.17b
     *      - Enh: Revised pgm to set RUNNER records to closed.
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

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D curdate         s              8  0
     D curtime         s              6  0
417bAD currstamp       s               z
417bAD currdts         s             26a

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
     C     *entry        plist
     C                   parm                    $pwhse           15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Get current date and time.

     C                   time                    curtime
417bAC                   time                    currstamp
417bAC                   move      currstamp     currdts
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o

     *  Delete virtual slots.

     C/EXEC SQL
     C+   delete from slot
     C+   where slwhse = :$pwhse and slrsrv = 'V'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+   delete from vslot
     C+   where vswhse = :$pwhse
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Clear remaining physical slots.

     C/EXEC SQL
     C+   update slot
     C+   set slitem=' ',
     C+       slstk1=0, slstk2=0, slstk3=0,
     C+       slalc1=0, slalc2=0, slalc3=0,
     C+       slpck1=0, slpck2=0, slpck3=0,
     C+       slrcv1=0, slrcv2=0, slrcv3=0,
     C+       sltfr1=0, sltfr2=0, sltfr3=0,
     C+       slentd=0, slexpd=0, slprty=0
     C+   where slwhse = :$pwhse
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete items

     C/EXEC SQL
     C+   delete from piritem
     C+   where itwhse = :$pwhse
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete item misc info.

     C/EXEC SQL
     C+   delete from itemmsc
     C+   where imwhse = :$pwhse
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete item links

     C/EXEC SQL
     C+   delete from itemlnk
     C+   where ilwhse = :$pwhse
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Delete item quantities

     C/EXEC SQL
     C+   delete from itemqty
     C+   where iqwhse = :$pwhse
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Set all routes to Exported status

     C/EXEC SQL
     C+   update rtehed
     C+   set rhstat='6',
     C+   rhstsd=:curdate, rhstst=:curtime,
     C+   rhexpd=:curdate, rhexpt=:curtime
     C+   where rhwhse = :$pwhse and rhstat < '6'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

417aA*  Set all orders on route to Closed/Exported status.

417aAC/EXEC SQL
417aAC+   update ordh
417aAC+   set ohstat='C',
417aAC+   ohsdte=:curdate, ohstim=:curtime,
417aAC+   ohudte=:curdate, ohutim=:curtime
417aAC+   where ohwhse = :$pwhse and ohstat = 'P'
417aAC/END-EXEC
417aAC                   if        sqlstt <> '00000'
417aAC                   endif

     *  Close label records.

     C/EXEC SQL
     C+   update label
     C+   set lbstat='C', lbsdte=:curdate, lbstim=:curtime
     C+   where lbwhse = :$pwhse and lbstat <> 'C'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Close transaction records.

     C/EXEC SQL
     C+   update pirtran
     C+   set ptstat='4',
     C+       ptedte=:curdate, ptetim=:curtime,
     C+       ptcdte=:curdate, ptctim=:curtime
     C+   where ptwhse = :$pwhse and ptstat < '4'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

417bA*  Set all RUNNER entries not processed to Closed status.

417bAC/EXEC SQL
417bAC+   update runner
417bAC+   set rustat='C',
417bAC+   rucdts=:currdts
417bAC+   where ruwhse = :$pwhse and rustat = 'O'
417bAC+      or ruwhse = :$pwhse and rustat = 'P'
417bAC/END-EXEC
417bAC                   if        sqlstt <> '00000'
417bAC                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return
