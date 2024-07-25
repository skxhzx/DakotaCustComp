      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPD500DSA  Add/Update *LICENSE options
     *  18 November 2004
     *  Dave Sommerville
     *
     *  Revisions
500 A*    11/18/04  DAS  5.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fwarehs    ip   e           k disk
     Foptions   uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D kycode          s                   like(opcode)

417eA*----------------------------------------------------------------
417eA*  *LICENSE  -  License Plate Tracking options
417eA*----------------------------------------------------------------
500 A*
500 A* Tracking Levels
500 A*
500 A*   Low     -  User is not asked for any extra info.
500 A*              All tracking is done in the background.
500 A*
500 A*   Medium  -  User may be asked to apply new license plate to
500 A*              a split quantity.
500 A*              Applying new license plate is optional.
500 A*
500 A*   Medium  -  User may be asked to apply new license plate to
500 A*              a split quantity.
500 A*              Applying new license plate is manditory.
500 A*              User may be asked to confirm license plate being
500 A*              used for task.
500 A*
500 A*----------------------------------------------------------------
500 A*
500 A* Split LP Quantity Options
500 A*
500 A*   1  =  LP goes with first quantity put into a slot.
500 A*   2  =  LP goes with last quantity put into a slot.
500 A*   3  =  Ask user.
500 A*
500 A*----------------------------------------------------------------
417eA*
417eA* Fields
417eA*
500 M*    OPLPTR  -  Allow license plate tracking ** NOT USED **
500 M*    OPLPAL  -  Default for all other items (L,M,H).
500 M*    OPLPDS  -  Default for date sensitive items (L,M,H).
500 M*    OPLPLC  -  Default for lot code items (L,M,H).
500 M*    OPLPCW  -  Default for catchweight items (L,M,H).
500 D*    OPTKSP  -  Track push back slot positions *** REMOVED ***
500 A*    OPSPLT  -  Splitting LP quantity (see above)
417eA*
417eA* Data structure
417eA*
417eAD opdata          ds
417eAD  oplptr                 1      1
417eAD  oplpal                 2      2
417eAD  oplpds                 3      3
417eAD  oplplc                 4      4
417eAD  oplpcw                 5      5
500 D***                                     6   6 OPTKSP
500 MD  opsplt                 6      6
417eAD  optend               117    117

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     opkey         klist
     C                   kfld                    whcode
     C                   kfld                    kycode
     C                   eval      kycode = '*LICENSE'

     *  Try to get existing *LICENSE option for warehouse.

     C     opkey         chain     options

     C                   select

     *      If it does not exist, then create it.

     C                   when      not %found

     C                   eval      opwhse = whcode
     C                   eval      opcode = kycode
     C                   eval      oplptr = 'Y'
     C                   eval      oplpal = 'L'
     C                   eval      oplpds = 'L'
     C                   eval      oplplc = 'L'
     C                   eval      oplpcw = 'L'
     C                   eval      opsplt = '2'

     C                   write     oprec

     *      Otherwise, update it with new option values.

     C                   other

     C                   eval      oplptr = 'Y'

     C                   if        oplpal = 'Y'
     C                   eval      oplpal = 'M'
     C                   else
     C                   eval      oplpal = 'L'
     C                   endif

     C                   if        oplpds = 'Y'
     C                   eval      oplpds = 'M'
     C                   else
     C                   eval      oplpds = 'L'
     C                   endif

     C                   if        oplplc = 'Y'
     C                   eval      oplplc = 'M'
     C                   else
     C                   eval      oplplc = 'L'
     C                   endif

     C                   if        oplpcw = 'Y'
     C                   eval      oplpcw = 'M'
     C                   else
     C                   eval      oplpcw = 'L'
     C                   endif

     C                   eval      opsplt = '2'

     C                   update    oprec

     C                   endsl

     *  Now set item records to correct defaults.

     C                   exsr      zzupd

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ZZUPD    Update tracking field for all items.
     *----------------------------------------------------------------

     C     zzupd         begsr

     * Establish the connection to local machine.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *  Update all item records with general default.

     C                   exsr      zzupdall

     *  Update groups defined as "Low"

     C                   if        oplpds = 'L'
     C                   exsr      zzupddate
     C                   endif

     C                   if        oplplc = 'L'
     C                   exsr      zzupdlot
     C                   endif

     C                   if        oplpcw = 'L'
     C                   exsr      zzupdcwgt
     C                   endif

     *  Update groups defined as "Medium"

     C                   if        oplpds = 'M'
     C                   exsr      zzupddate
     C                   endif

     C                   if        oplplc = 'M'
     C                   exsr      zzupdlot
     C                   endif

     C                   if        oplpcw = 'M'
     C                   exsr      zzupdcwgt
     C                   endif

     *  Update groups defined as "High"

     C                   if        oplpds = 'H'
     C                   exsr      zzupddate
     C                   endif

     C                   if        oplplc = 'H'
     C                   exsr      zzupdlot
     C                   endif

     C                   if        oplpcw = 'H'
     C                   exsr      zzupdcwgt
     C                   endif

     * Disconnect the current connection.

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC


     C     endup2        endsr

     *----------------------------------------------------------------
     *  ZZUPDALL   Update all item records with general default
     *----------------------------------------------------------------

     C     zzupdall      begsr

     C/EXEC SQL
     C+  UPDATE ITEMMSC
     C+  SET IMLTRK = :oplpal
     C+  WHERE IMWHSE = :opwhse
     C/END-EXEC

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPDDATE  Update date sensitive items.
     *----------------------------------------------------------------

     C     zzupddate     begsr

     C/EXEC SQL
     C+  UPDATE ITEMMSC
     C+  SET IMLTRK = :oplpds
     C+  WHERE IMWHSE = :opwhse
     C+    AND EXISTS (SELECT ITFLGD FROM PIRITEM
     C+                WHERE ITWHSE = IMWHSE AND ITITEM = IMITEM
     C+                AND ITFLGD='Y')
     C/END-EXEC

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPDLOT  Update lot code items.
     *----------------------------------------------------------------

     C     zzupdlot      begsr

     C/EXEC SQL
     C+  UPDATE ITEMMSC
     C+  SET IMLTRK = :oplplc
     C+  WHERE IMWHSE = :opwhse  AND IMLOT = 'Y'
     C/END-EXEC

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPDCWGT  Update catchweight items.
     *----------------------------------------------------------------

     C     zzupdcwgt     begsr

     C/EXEC SQL
     C+  UPDATE ITEMMSC
     C+  SET IMLTRK = :oplpcw
     C+  WHERE IMWHSE = :opwhse
     C+    AND EXISTS (SELECT ITCWGT FROM PIRITEM
     C+                WHERE ITWHSE = IMWHSE AND ITITEM = IMITEM
     C+                AND ITCWGT='Y')
     C/END-EXEC

     C                   endsr
