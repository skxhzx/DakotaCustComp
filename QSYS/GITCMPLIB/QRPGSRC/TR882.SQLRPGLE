     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  TR882     Trax - reset downloaded or uploaded status.
     *
     *  09 February 2012
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    02/09/12  RBD  6.40
     *      - Created.
     *
650 A*    08/26/13  RBD  6.50
     *      - Recompiled, TTLOG file changed.
     *
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *
     *    Returned Parameters
     *
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Update Trax log file status.

     C/EXEC SQL
     C+   update ttlog
     C+   set ttlstatus='8'
     C+   where ttlwhse = :$pwhse
     C+     and ttlrtid = :$prtid
     C+     and ttlstatus >= '3'
     C+     and ttlstatus <= '4'
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return
