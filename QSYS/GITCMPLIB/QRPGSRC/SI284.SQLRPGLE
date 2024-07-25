     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *   Compile Options: OPTIONS(*CVTDT)
     *
     *----------------------------------------------------------------
     *
     *  SI284   Clear all Slot fields for initial slot load.
     *  20 July 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    07/20/09  MLB  5.20
     *      - Created.
     *      - Clent custom code support included in program.
610aA*    07/22/09  DAS  6.10a
     *      - Enh: Revised to not delete special slots
     *        RCV/STG.
     *
650 A*    01/09/13  MLB  6.50
     *      - Enh: Revised to delete rcds from SLOTDGTA.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS1A*    01/09/13  MLB  GFS1
     *      - Revised program to not delete records from SLOTDGT
     *        and SLOTDGTA files.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI1A*    02/05/17  MLB  CBI1
     *      - Revised program to not delete records from SLOTDGT
     *        and SLOTDGTA files.
     *      - Added CBI1 to GFS1 mod.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     D clientdft       s             10a   inz('BFCDFT')
GFS1AD/copy qcopysrc,id#gfs
CBI1AD/copy qcopysrc,id#cheney

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
610aAC+         and vsaisl<>'RCV'
610aAC+         and vsaisl<>'STG'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Clear remaining physical slots.

     *  Delete all remaining slots.
     C/EXEC SQL
     C+   delete from slot
     C+   where slwhse = 001
610aAC+         and slaisl<>'RCV'
610aAC+         and slaisl<>'STG'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif


     *  Delete all Slot Check Digits.
     C                   if        client <> Clientdft
GFS1AC                             and client <> getfresh
CBI1AC                             and client <> cheney
     C/EXEC SQL
     C+   delete from slotdgt
     C+   where scdwhs = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif
650 AC/EXEC SQL
650 AC+   delete from slotdgta
650 AC+   where scdwhsa = 001
650 AC/END-EXEC
650 AC                   if        sqlstt <> '00000'
650 AC                   endif

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
