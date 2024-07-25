     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OPNSQTY   Calculate open label quantities
     *  24 April 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
415 A*    04/24/01  DAS  4.15
     *      - Created.
     *
415 A*    03/22/04  DAS  4.17
     *      - Rewrote to use SQL instead of OPNQRYF from CL program.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Label record fields
     *----------------------------------------------------------------

     D lbflds        E ds                  extname(label12)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *      $PCMD   Command: *CHANGE, *VIEW
     *      $PWHSE  Warehouse
     *      $PWHDP  Warehouse department
     *      $PDISP  Slot
     *
     *    Returned Parameters
     *
     *      $PALC_  Quantity selected for picking but not yet
     *              printed on labels.
     *
     *      $PTFR_  Quantity printed on labels for transfer to
     *              another slot.
     *
     *      $PPCK_  Quantity printed on labels for picking.
     *
     *      $PRCV_  Quantity printed on labels to be received into
     *              this slot.
     *
     *      $PUNK_  Unkown quantity.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     *
     C                   parm                    $palc1            5 0
     C                   parm                    $palc2            3 0
     C                   parm                    $palc3            3 0
     *
     C                   parm                    $ptfr1            5 0
     C                   parm                    $ptfr2            3 0
     C                   parm                    $ptfr3            3 0
     *
     C                   parm                    $ppck1            5 0
     C                   parm                    $ppck2            3 0
     C                   parm                    $ppck3            3 0
     *
     C                   parm                    $prcv1            5 0
     C                   parm                    $prcv2            3 0
     C                   parm                    $prcv3            3 0
     *
     C                   parm                    $punk1            5 0
     C                   parm                    $punk2            3 0
     C                   parm                    $punk3            3 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Initialize quantities.

     C                   eval      $palc1 = 0
     C                   eval      $palc2 = 0
     C                   eval      $palc3 = 0

     C                   eval      $ptfr1 = 0
     C                   eval      $ptfr2 = 0
     C                   eval      $ptfr3 = 0

     C                   eval      $ppck1 = 0
     C                   eval      $ppck2 = 0
     C                   eval      $ppck3 = 0

     C                   eval      $prcv1 = 0
     C                   eval      $prcv2 = 0
     C                   eval      $prcv3 = 0

     C                   eval      $punk1 = 0
     C                   eval      $punk2 = 0
     C                   eval      $punk3 = 0

     *  Establish SQL connection.

     C                   exsr      sqlconnect

     *  Prepare SQL statment.

     C                   exsr      sqlclean
     C                   exsr      sqlbldstmt
     C                   exsr      sqlprep

     *  Loop through records and update quantities.

     C                   exsr      sqlfetch

     *  Cleanup and leave printing

     C                   exsr      sqlclean

     *  Disconnect SQL connection.

     C                   exsr      sqldisconnect

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *              Subroutines in Alphabetical Order
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  updqtys - Update quantities
     *----------------------------------------------------------------

     C     updqtys       BegSr

     C                   select

     *     Ignore the following:
     *
     *       Adjustments, Inventory counts, Merge

     C                   when      lbtype = 'A'  or
     C                             lbtype = 'I'  or
     C                             lbtype = 'M'

     *     Bulk pick - Allocated.

     C                   when      lbtype = 'B'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'A'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqalc        $palc1
     C                   when      lbutyp = '1'
     C                   add       lbqalc        $palc2
     C                   when      lbutyp = '2'
     C                   add       lbqalc        $palc3
     C                   endsl

     *     Bulk pick - Picked.

     C                   when      lbtype = 'B'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $ppck1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $ppck2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $ppck3
     C                   endsl

     *     Normal pick- Allocated.

     C                   when      lbtype = 'O'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'A'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqalc        $palc1
     C                   when      lbutyp = '1'
     C                   add       lbqalc        $palc2
     C                   when      lbutyp = '2'
     C                   add       lbqalc        $palc3
     C                   endsl

     *     Normal Pick - Picked.

     C                   when      lbtype = 'O'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $ppck1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $ppck2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $ppck3
     C                   endsl

     *     Putaway - Picked.

     C                   when      lbtype = 'P'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $prcv1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $prcv2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $prcv3
     C                   endsl

     *     Replenishment - Slot 1

     C                   when      lbtype = 'R'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $ptfr1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $ptfr2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $ptfr3
     C                   endsl

     *     Replenishment - Slot 2

     C                   when      lbtype = 'R'  and
     C                             lbwhs2 = $pwhse  and
     C                             lbwhd2 = $pwhdp  and
     C                             lbdsp2 = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $prcv1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $prcv2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $prcv3
     C                   endsl

     *     Transfer - Record 1

     C                   when      lbtype = 'T'  and
     C                             lbgrp2 = 'A'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $ptfr1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $ptfr2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $ptfr3
     C                   endsl

     *     Transfer - Record 2

     C                   when      lbtype = 'T'  and
     C                             lbgrp2 = 'B'  and
     C                             lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  and
     C                             lbstat = 'P'
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $prcv1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $prcv2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $prcv3
     C                   endsl

     *     Catch all

     C                   when      lbwhse = $pwhse  and
     C                             lbwhdp = $pwhdp  and
     C                             lbdisp = $pdisp  or
     C                             lbwhs2 = $pwhse  and
     C                             lbwhd2 = $pwhdp  and
     C                             lbdsp2 = $pdisp
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       lbqpck        $punk1
     C                   when      lbutyp = '1'
     C                   add       lbqpck        $punk2
     C                   when      lbutyp = '2'
     C                   add       lbqpck        $punk3
     C                   endsl

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt    BegSr

     * Create select statement for 'Out' exceptions.

     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM LABEL12 '

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
     C                               + '('
     C                               + 'LBWHSE=' +%trim(%editc($pwhse:'P'))
     C                               + ' AND LBWHDP='
     C                               +    sq + %trim($pwhdp) + sq
     C                               + ' AND LBDISP='
     C                               +    sq + %trim($pdisp) + sq
     C                               + ')'
     C                               + ' OR '
     C                               + '('
     C                               + 'LBWHS2=' +%trim(%editc($pwhse:'P'))
     C                               + ' AND LBWHD2='
     C                               +    sq + %trim($pwhdp) + sq
     C                               + ' AND LBDSP2='
     C                               +    sq + %trim($pdisp) + sq
     C                               + ')'

     *   Create SQL statement for 'Out' exceptions.

     C                   Eval      SqlStmt = 'SELECT * '
     C                                     + %trimr(sqlfrom) + ' '
     C                                     + %trimr(sqlwhere) + ' '

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlconnect - Establish SQL connection.
     *----------------------------------------------------------------

     C     sqlconnect    BegSr

     * Establish the connection to the remote machine. The -842 return
     * code indicates that the connection is already established. If
     * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

     C     sqlprep       BegSr

     * Prepare the SQL statement for validation, since the program was
     * compiled with DLYPRP (*YES), it will wait until it is used before
     * it prepares the cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR DYNAMIC SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
     C                   EndSr

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

     C     sqlclean      BegSr

     * Close the SQL cursor after all processing is complete.

     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Endsr

     *----------------------------------------------------------------
     *  sqldisconnect - Disconnect SQL connection
     *----------------------------------------------------------------

     C     sqldisconnect BegSr

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Endsr

     *----------------------------------------------------------------
     *  sqlfetch - Fetch selected records
     *----------------------------------------------------------------

     C     sqlfetch      BegSr

     C                   dow       forever = forever

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :lbflds
     C/END-EXEC

     C                   if        sqlstt = '00000'
     C                   exsr      updqtys
     C                   else
     C                   leave
     C                   endif

     C                   enddo

     C                   Endsr
