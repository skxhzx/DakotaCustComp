     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR254    Clear Repack Item Demand file.
     *  Max Blacknik
     *  17 September 2010
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    09/17/10  MLB  5.30
     *      - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     D sq1rec        e ds                  occurs(1) extname(rpkdemd)
     *----------------------------------------------------------------
     *  Working variable(s)
     *
     D w1whse          s              3  0
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     *
     C                   move      $pwhse        w1whse
     *
     *  Delete records - Entire warehouse.
     *
     C/EXEC SQL
     C+  delete
     C+  from   rpkdemd
     C+  where  (drwhse = :w1whse)
     C/END-EXEC
     *
     C                   return
