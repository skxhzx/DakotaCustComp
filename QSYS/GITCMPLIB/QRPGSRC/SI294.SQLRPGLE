     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *   Compile Options: OPTIONS(*CVTDT)
     *
     *----------------------------------------------------------------
     *
     *  SI294   Clear all Slot fields for initial slot load.
     *  11 Autust 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    08/11/11  MLB  6.40
     *      - Created.
     *      - Clent custom code support included in program.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     D clientdft       s             10a   inz('BFCDFT')

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdsql

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
     C*    *entry        plist
     C*                  parm                    $pwhse           15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10

     *  Get current date and time.

     C                   time                    curtime
     C                   time                    currstamp
     C                   move      currstamp     currdts
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o

     *  Delete virtual slots.

     C/EXEC SQL
     C+   delete from vslot
     C+   where vswhse = 001
     C+         and vsaisl<>'RCV'
     C+         and vsaisl<>'STG'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Clear remaining physical slots.

     *  Delete all remaining slots.
     C/EXEC SQL
     C+   delete from slot
     C+   where slwhse = 001
     C+         and slaisl<>'RCV'
     C+         and slaisl<>'STG'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif


     *  Delete all Slot Check Digits.
     C                   if        client <> Clientdft
     C/EXEC SQL
     C+   delete from slotdgt
     C+   where scdwhs = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+   delete from slotdgta
     C+   where scdwhsa = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   endif


     *  Clear item quantity file.

     C/EXEC SQL
     C+   update itemqty
     C+   set iqstk1=0, iqstk2=0, iqstk3=0,
     C+       iqalc1=0, iqalc2=0, iqalc3=0,
     C+       iqhld1=0, iqhld2=0, iqhld3=0,
     C+       iqtri1=0, iqtri2=0, iqtri3=0,
     C+       iqtro1=0, iqtro2=0, iqtro3=0
     C+   where iqwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return
