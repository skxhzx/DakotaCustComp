     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
500 M*  SL405B    Clear Slot Replenishment Exception / Slot Out files
     *  Max Blacknik
     *  19 September 2002
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*  03/17/05  RLP  5.00
     *    - Added file SLOTOUT to be cleared
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     D w1whse          s              3  0
     D sq1rec        e ds                  occurs(1) extname(sltrpex)
500 AD sq2rec        e ds                  occurs(1) extname(slotout)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   move      $pwhs         w1whse
     *
     *  Delete records - Entire warehouse.
     *
     C/EXEC SQL
     C+  delete
     C+  from   sltrpex
     C+  where  (sewhse = :w1whse)
     C/END-EXEC
500 A*
500 A*  Delete records - SLOTOUT file.
500 A*
500 AC/EXEC SQL
500 AC+  delete
500 AC+  from   slotout
500 AC+  where  (sowhse = :w1whse)
500 AC/END-EXEC
     *
     C                   return
