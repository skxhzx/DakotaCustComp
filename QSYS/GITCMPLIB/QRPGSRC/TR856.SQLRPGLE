     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  TR856     Trax - Stop Level Options - Delete.
     *
     *  22 March 2012
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    03/22/12  RBD  6.40
     *      - Created.
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
     *      $PSTOP  Stop
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
     C                   parm                    $pstop            2 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Clear Trax stop file stop level options.

     C/EXEC SQL
     C+   update ttstp
     C+   set ttpcce=' ',ttpsig=' ',ttppiv=' ',ttppal=' ',ttpbul=' '
     C+   where ttpwhs = :$pwhse
     C+     and ttprti = :$prtid
     C+     and ttpstp = :$pstop
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return
