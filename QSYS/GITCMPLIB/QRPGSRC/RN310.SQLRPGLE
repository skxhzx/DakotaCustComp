     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RN310     Return code history
     *  22 August 2002
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*    08/22/02  DAS  4.16
     *      - Created.
416aA*    09/23/02  MLB  4.16a
     *      - Enh: Added support to display total pieces returned
     *        to all displays.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frn310fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants for attention key indicator byte
     *----------------------------------------------------------------

     D F3              C                   const(X'33')
     D F4              C                   const(X'34')
     D F9              C                   const(X'39')
     D F12             C                   const(X'3C')

     D Enter           C                   const(X'F1')
     D PageDown        C                   const(X'F5')

     *----------------------------------------------------------------
     *  Constants for screen attributes
     *----------------------------------------------------------------

     D @n              C                   const(X'20')
     D @h              C                   const(X'22')
     D @u              C                   const(X'24')
     D @hu             C                   const(X'26')

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
     D forever         s               n
     D Quote           C                   Const('''')
     D SubfilePage     C                   Const(17)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD $code           s              2    inz(' ')
415aAD $count          s              8b 0 inz(0)
415aAD $date           s              8  0 inz(0)
415aAD $desc           s             30    inz(' ')
415aAD $emp#           s              5  0 inz(0)
415aAD $emp#ind        s              2b 0 inz(0)
415aAD $empfnam        s             15    inz(' ')
415aAD $empfnamind     s              2b 0 inz(0)
415aAD $emplnam        s             20    inz(' ')
415aAD $emplnamind     s              2b 0 inz(0)
415aAD $empname        s             37    inz(' ')
415aAD $idesc          s             30    inz(' ')
415aAD $item           s             15    inz(' ')
416aAD $rqty1          s              8b 0 inz(0)
416aAD $rqty2          s              8b 0 inz(0)
416aAD $rqty3          s              8b 0 inz(0)
415aAD begofmonth6     s              6  0 inz(0)
415aAD begofmonth8     s              8    inz(' ')
415aAD eorder1         s             20    inz(' ')
415aAD eorder2         s             20    inz(' ')
415aAD fromdate        s              8    inz(' ')
416aMD groupby         S            100a   inz(' ')
416aMD groupfields     S            100a   inz(' ')
415aAD iorder1         s             20    inz(' ')
415aAD iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
     D leftjoin        S             80a   inz(' ')
     D leftjoin2       S             80a   inz(' ')
415aAD newordpos       s              3  0 inz(0)
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt)
     D optiontaken     s             10    inz(' ')
415aAD order1          s             10    inz(' ')
415aAD order2          s             10    inz(' ')
416aMD orderby         S            100a   inz(' ')
415aAD orderfield      s             10    inz(' ')
415aAD orderposition   s              3  0 inz(0)
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
416aDD*selectfields    s             50a   inz(' ')
416aMD selectfields    s            200a   inz(' ')
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD sortorder3      s             10    inz(' ')
     D sqlStmt         s           1000a   inz(' ')
415aAD todate          s              8    inz(' ')
     D whereclause     S            200a   inz(' ')
415aAD x               s              5  0 inz(0)

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1type                 1      1
     D  h1daten                2      9  0
     D  h1datea                2      9
     D  h1code                10     15
     D  h1desc                16     45

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')

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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      *
      * Establish the connection to the remote machine. The -842 return
      * code indicates that the connection is already established. If
      * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *  Process main screen.

     C                   exsr      screen1

      *
      *  Disconnect the current connection.
      *
     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC
      *
     C                   Eval      *inlr = *on

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Get current date in YYMMDD format.

     C                   eval      $cvcmd = '*CURYMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt

     *  Set date to first of month and change to MMDDYY

     C                   move      $cvd6o        $cvd6i
     C                   move      '01'          $cvd6i
     C                   eval      $cvcmd = '*YMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      begofmonth6 = $cvd6o

     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      $cvd6o        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        begofmonth8

     C                   eval      $cvprg = 'RN310'
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt1   BegSr

     * Create list of select fields.

     C                   select

     C                   when      w1sum = 'N'
     C                   eval      SelectFields = 'ORRDTE, ORRCOD, RNDESC, '
416aMC                                          + 'COUNT(*) as RCOUNT,'
416aAC                                          + 'SUM(ORQTY1),'
416aAC                                          + 'SUM(ORQTY2),'
416aAC                                          + 'SUM(ORQTY3) '

     C                   other
     C                   if        sortorder1 = 'DATE'
     C                   eval      SelectFields = 'ORRDTE, '
416aMC                                          + 'COUNT(*) as RCOUNT,'
416aAC                                          + 'SUM(ORQTY1),'
416aAC                                          + 'SUM(ORQTY2),'
416aAC                                          + 'SUM(ORQTY3) '
     C                   else
     C                   eval      SelectFields = 'ORRCOD, RNDESC, '
416aMC                                          + 'COUNT(*) as RCOUNT,'
416aAC                                          + 'SUM(ORQTY1),'
416aAC                                          + 'SUM(ORQTY2),'
416aAC                                          + 'SUM(ORQTY3) '
     C                   endif

     C                   endsl

     * Create "left outer join" clause

     C                   if        w1sum = 'Y' and sortorder1 = 'DATE'
     C                   eval      LeftJoin = ' '
     C                   else
     C                   eval      LeftJoin = 'LEFT OUTER JOIN RTNCODE '
     C                                      + 'ON RNCODE = ORRCOD'
     C                   endif

     * Create "where" clause.

     C                   if        fromdate = '0' and todate = '99999999'
     C                   Clear                   WhereClause
     C                   else
     C                   Eval      WhereClause = 'WHERE ORRDTE >= '
     C                                           + %trim(fromdate)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim(todate)
     C                   EndIf

     C                   If        w1code <> '*ALL' and w1sum = 'N'

     C                   If        WhereClause = ' '
     C                   Eval      WhereClause = 'WHERE ORRCOD = '
     C                                         + quote
     C                                         + %trim(w1code)
     C                                         + quote
     C                   else
     C                   Eval      WhereClause = %TrimR(WhereClause)
     C                                         + ' AND ORRCOD = '
     C                                         + quote
     C                                         + %trim(w1code)
     C                                         + quote
     C                   EndIf

     C                   EndIf

     * Create "Group By" and "Order By" clauses.

     C                   select

     C                   when      w1sum = 'N' and sortorder1 = 'DATE'
     C                   eval      GroupFields = %trim(order1) + ', '
     C                                         + %trim(order2) + ', '
     C                                         + 'RNDESC'

     C                   when      w1sum = 'N' and sortorder1 = 'CODE'
     C                   eval      GroupFields = %trim(order1) + ', '
     C                                         + 'RNDESC, '
     C                                         + %trim(order2)

     C                   when      w1sum = 'Y' and sortorder1 = 'DATE'
     C                   eval      GroupFields = %trim(order1)

     C                   when      w1sum = 'Y' and sortorder1 = 'CODE'
     C                   eval      GroupFields = %trim(order1) + ', '
     C                                         + 'RNDESC'

     C                   endsl

     C                   eval      GroupBy = 'GROUP BY '
     C                                      + %trim(GroupFields)

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(GroupFields)

     * Create list heading

     C                   exsr      createhead1

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORRTN '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + %trimr(GroupBy) + ' '
     C                                     + OrderBy

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment for item detail
     *----------------------------------------------------------------

     C     sqlbldstmt2   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'ORITEM, ITDESC, '
416aMC                                          + 'COUNT(*) as RCOUNT,'
416aAC                                          + 'SUM(ORQTY1),'
416aAC                                          + 'SUM(ORQTY2),'
416aAC                                          + 'SUM(ORQTY3) '

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN PIRITEM '
     C                                      + 'ON ITWHSE = ORWHSE '
     C                                      + 'AND ITITEM = ORITEM'

     * Create "where" clause.

     C                   select

     C                   when      h1type = 'B'
     C                   Eval      WhereClause = 'WHERE ORRDTE = '
     C                                         + %trim(h1datea)
     C                                         + ' AND ORRCOD = '
     C                                         + quote
     C                                         + %trim(h1code)
     C                                         + quote

     C                   when      h1type = 'D'
     C                   Eval      WhereClause = 'WHERE ORRDTE = '
     C                                         + %trim(h1datea)

     C                   when      h1type = 'C'
     C                   if        fromdate = '0' and todate = '99999999'
     C                   Eval      WhereClause = 'WHERE ORRCOD = '
     C                                         + quote
     C                                         + %trim(h1code)
     C                                         + quote
     C                   else
     C                   Eval      WhereClause = 'WHERE ORRDTE >= '
     C                                         + %trim(fromdate)
     C                                         + ' AND ORRDTE <= '
     C                                         + %trim(todate)
     C                                         + ' AND ORRCOD = '
     C                                         + quote
     C                                         + %trim(h1code)
     C                                         + quote
     C                   EndIf


     C                   endsl

     * Create "Group By" and "Order By" clauses.

     C                   eval      GroupFields = %trim(iorder1) + ', '
     C                                         + %trim(iorder2) + ', '
     C                                         + 'ITDESC'

     C                   eval      GroupBy = 'GROUP BY '
     C                                      + 'ORITEM, ITDESC'

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(GroupFields)

     * Create list heading

     C                   exsr      createhead2

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORRTN '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + %trimr(GroupBy) + ' '
     C                                     + OrderBy

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt3 - Build SQL statment for employee detail
     *----------------------------------------------------------------

     C     sqlbldstmt3   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'PTEMP#, USFNAM, USLNAM, '
416aMC                                          + 'COUNT(*) as RCOUNT,'
416aAC                                          + 'SUM(ORQTY1),'
416aAC                                          + 'SUM(ORQTY2),'
416aAC                                          + 'SUM(ORQTY3) '

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN PIRTRAN '
     C                                      + 'ON PTTRN# = ORTRN#'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRUSER '
     C                                       + 'ON USEMP# = PTEMP#'

     * Create "where" clause.

     C                   select

     C                   when      h1type = 'B'
     C                   Eval      WhereClause = 'WHERE ORRDTE = '
     C                                         + %trim(h1datea)
     C                                         + ' AND ORRCOD = '
     C                                         + quote
     C                                         + %trim(h1code)
     C                                         + quote

     C                   when      h1type = 'D'
     C                   Eval      WhereClause = 'WHERE ORRDTE = '
     C                                         + %trim(h1datea)

     C                   when      h1type = 'C'
     C                   if        fromdate = '0' and todate = '99999999'
     C                   Eval      WhereClause = 'WHERE ORRCOD = '
     C                                         + quote
     C                                         + %trim(h1code)
     C                                         + quote
     C                   else
     C                   Eval      WhereClause = 'WHERE ORRDTE >= '
     C                                         + %trim(fromdate)
     C                                         + ' AND ORRDTE <= '
     C                                         + %trim(todate)
     C                                         + ' AND ORRCOD = '
     C                                         + quote
     C                                         + %trim(h1code)
     C                                         + quote
     C                   EndIf


     C                   endsl

     * Create "Group By" and "Order By" clauses.

     C                   eval      GroupFields = %trim(eorder1) + ', '
     C                                         + %trim(eorder2) + ', '
     C                                         + 'USFNAM, USLNAM'

     C                   eval      GroupBy = 'GROUP BY '
     C                                      + 'PTEMP#, USFNAM, USLNAM'

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(GroupFields)

     * Create list heading

     C                   exsr      createhead3

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORRTN '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(LeftJoin2) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + %trimr(GroupBy) + ' '
     C                                     + OrderBy

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

     C     sqlprep       BegSr

      * Prepare the SQL statement for validation, since the program was
      * compiled with DLYPRP (*YES), it will wait until it is used before
      * it prepares th cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR SCROLL CURSOR FOR SEL
     C/END-EXEC
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
      *
     C                   EndSr

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

     C     sqlclean      BegSr
      *
      *  Close the SQL cursor after all processing is complete.
      *
     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC
      *
     C                   Endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

     C     sflbld1       BegSr

     C                   Eval      rrn1 = Lastrrn

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C                   select

     C                   when      w1sum = 'N'
     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
416aDC*      INTO :$date, :$code, :$desc, :$count
416aMC+      INTO :$date, :$code, :$desc, :$count,
416aAC+           :$rqty1, :$rqty2, :$rqty3
     C/END-EXEC

     C                   when      sortorder1 = 'DATE'
     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
416aDC*      INTO :$date, :$count
416aMC+      INTO :$date, :$count,
416aAC+           :$rqty1, :$rqty2, :$rqty3
     C/END-EXEC
     C                   when      sortorder1='CODE'

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
416aMC+      INTO :$code, :$desc, :$count,
416aAC+           :$rqty1, :$rqty2, :$rqty3
     C/END-EXEC

     C                   endsl

     C                   If        sqlstt = '00000'
     C                   exsr      createline1
     C                   Eval      rrn1  = rrn1  + 1
     C                   Eval      option = ' '
     C                   Write     sfl1
     C                   Else
     C                   Leave
     C                   EndIf

     C                   EndDo

     C                   If        rrn1 = 0
     C                   Eval      *in32 = *on
     C                   Else
     C                   Eval      Lastrrn = rrn1
     C                   EndIf

      * A code of 2000 means end of file.

     C                   If        sqlstt = '02000'
     C                   Eval      *in90 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflbld2 - Build the subfile for item detail
     *----------------------------------------------------------------

     C     sflbld2       BegSr

     C                   Eval      rrn1 = Lastrrn

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
416aMC+      INTO :$item, :$idesc, :$count,
416aAC+           :$rqty1, :$rqty2, :$rqty3
     C/END-EXEC

     C                   If        sqlstt = '00000'
     C                   exsr      createline2
     C                   Eval      rrn1  = rrn1  + 1
     C                   Eval      option = ' '
     C                   Write     sfl1
     C                   Else
     C                   Leave
     C                   EndIf

     C                   EndDo

     C                   If        rrn1 = 0
     C                   Eval      *in32 = *on
     C                   Else
     C                   Eval      Lastrrn = rrn1
     C                   EndIf

      * A code of 2000 means end of file.

     C                   If        sqlstt = '02000'
     C                   Eval      *in90 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflbld3 - Build the subfile for employee detail
     *----------------------------------------------------------------

     C     sflbld3       BegSr

     C                   Eval      rrn1 = Lastrrn

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :$emp# :$emp#ind,
     C+           :$empfnam :$empfnamind,
     C+           :$emplnam :$emplnamind,
416aMC+           :$count,
416aAC+           :$rqty1, :$rqty2, :$rqty3
     C/END-EXEC

     * Check for null values being returned because of joins.

     C                   select

     C                   when      $emp#ind < 0
     C                   eval      $emp# = -1
     C                   eval      $empfnam = ' '
     C                   eval      $emplnam = '** No Tran Rec **'

     C                   when      $emp#ind >= 0 and $emplnamind < 0
     C                   eval      $empfnam = ' '
     C                   eval      $emplnam = '** No Empl Rec **'

     C                   endsl

     * If record was found, build line. Otherwise, get out.

     C                   If        sqlstt = '00000'
     C                   exsr      createline3
     C                   Eval      rrn1  = rrn1  + 1
     C                   Eval      option = ' '
     C                   Write     sfl1
     C                   Else
     C                   Leave
     C                   EndIf

     C                   EndDo

     C                   If        rrn1 = 0
     C                   Eval      *in32 = *on
     C                   Else
     C                   Eval      Lastrrn = rrn1
     C                   EndIf

      * A code of 2000 means end of file.

     C                   If        sqlstt = '02000'
     C                   Eval      *in90 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

     C     sflclr        BegSr

      * Clear the subfile

     C                   Eval      *in31 = *on
     C                   Write     sf1ctl
     C                   Eval      *in31 = *off
     C                   Eval      *in32 = *off
     C                   Eval      rrn1 = 0
     C                   Eval      Lastrrn = 0
     C                   Eval      *in90 = *off
     C                   EndSr

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

     C     sfloption1    BegSr

     C                   Eval      optiontaken = *off
     C                   Eval      *in21 = *off

     C                   dow       forever = forever

     C                   readc     sfl1
     C                   if        %eof
     C                   leave
     C                   endif

     C                   select
     C                   when      %trim(option) = 'I'
     C                   eval      optiontaken = 'Item'
     C                   leave
     C                   when      %trim(option) = 'E'
     C                   eval      optiontaken = 'Employee'
     C                   leave
     C                   endsl

     C                   enddo

     C                   EndSr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  screen1 - Process screen 1
     *----------------------------------------------------------------

     C     screen1       BegSr

     *  Initialize screen fields.

     C                   Eval      scrname = 'RN310.01'

     C                   Eval      w1from   = begofmonth6
     C                   Eval      w1to     = 999999
     C                   Eval      w1code   = '*ALL'
     C                   Eval      w1sort   = '1'
     C                   Eval      w1sum    = 'Y'

     C                   Eval      fromdate = begofmonth8
     C                   Eval      todate   = '99999999'

     C                   eval      sortorder1 = 'DATE'
     C                   Eval      order1   = 'ORRDTE'
     C                   Eval      order2   = 'ORRCOD'

     C                   eval      schead  = %editc(w1from:'Y')
     C                                     + ' thru '
     C                                     + %editc(w1to:'Y')
     C                   exsr      centerschead

     C                   eval      scopt = 'E=Employees  I=Items'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   ExFmt     sf1ctl
      *
     C                   Select

     *    Enter

     C                   When      cfkey = Enter
     C                   ExSr      sfloption1
     C                   select
     C                   when      optiontaken = 'Item'
     C                   ExSr      screen2
     C                   when      optiontaken = 'Employee'
     C                   ExSr      screen3
     C                   endsl
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   ExSr      getcriteria1
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   endif
     C                   eval      cfkey = Enter

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    PageDown = More records

     C                   When      cfkey = PageDown
     C                   ExSr      sflbld1
      *
     C                   EndSl
      *
     C                   EndDo

     C                   ExSr      sqlclean
     C                   endsr

     *----------------------------------------------------------------
     *  screen2 - Process screen 2
     *----------------------------------------------------------------

     C     screen2       BegSr

     *  Initialize screen fields.

     C                   Eval      oldname = scrname
     C                   Eval      oldhead = schead
     C                   Eval      oldopt  = scopt
     C                   Eval      scrname = 'RN310.02'

     C                   select

     C                   when      h1type = 'B'
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      h1datea       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      schead  = 'Date: '
     C                                     + %editc($cvd6o:'Y')
     C                                     + '  Code: '
     C                                     + quote
     C                                     + %trim(h1code)
     C                                     + quote

     C                   when      h1type = 'D'
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      h1datea       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      schead  = 'Date: '
     C                                     + %editc($cvd6o:'Y')

     C                   when      h1type = 'C'
     C                   eval      schead  = 'Code: '
     C                                     + quote
     C                                     + %trim(h1code)
     C                                     + quote
     C                                     + '  Date: '
     C                                     + %editc(w1from:'Y')
     C                                     + ' thru '
     C                                     + %editc(w1to:'Y')

     C                   endsl

     C                   exsr      centerschead

     C                   eval      scopt = ' '

     C                   eval      w2sort = '1'
     C                   eval      sortorder2 = 'COUNT'
     C                   Eval      iorder1   = 'RCOUNT DESC'
     C                   Eval      iorder2   = 'ORITEM'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt2
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld2

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   ExFmt     sf1ctl
      *
     C                   Select

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   ExSr      getcriteria2
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt2
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld2
     C                   endif
     C                   eval      cfkey = Enter

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    PageDown = More records

     C                   When      cfkey = PageDown
     C                   ExSr      sflbld2
      *
     C                   EndSl
      *
     C                   EndDo

     C                   eval      scrname = oldname
     C                   eval      schead  = oldhead
     C                   eval      scopt   = oldopt
     C                   eval      cfkey = Enter
     C                   endsr

     *----------------------------------------------------------------
     *  screen3 - Process screen 3
     *----------------------------------------------------------------

     C     screen3       BegSr

     *  Initialize screen fields.

     C                   Eval      oldname = scrname
     C                   Eval      oldhead = schead
     C                   Eval      oldopt  = scopt
     C                   Eval      scrname = 'RN310.03'

     C                   select

     C                   when      h1type = 'B'
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      h1datea       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      schead  = 'Date: '
     C                                     + %editc($cvd6o:'Y')
     C                                     + '  Code: '
     C                                     + quote
     C                                     + %trim(h1code)
     C                                     + quote

     C                   when      h1type = 'D'
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      h1datea       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      schead  = 'Date: '
     C                                     + %editc($cvd6o:'Y')

     C                   when      h1type = 'C'
     C                   eval      schead  = 'Code: '
     C                                     + quote
     C                                     + %trim(h1code)
     C                                     + quote
     C                                     + '  Date: '
     C                                     + %editc(w1from:'Y')
     C                                     + ' thru '
     C                                     + %editc(w1to:'Y')

     C                   endsl

     C                   exsr      centerschead

     C                   eval      scopt = ' '

     C                   eval      w3sort = '1'
     C                   eval      sortorder3 = 'COUNT'
     C                   eval      eorder1   = 'RCOUNT DESC'
     C                   eval      eorder2   = 'PTEMP#'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt3
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld3

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   ExFmt     sf1ctl
      *
     C                   Select

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   ExSr      getcriteria3
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt3
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld3
     C                   endif
     C                   eval      cfkey = Enter

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    PageDown = More records

     C                   When      cfkey = PageDown
     C                   ExSr      sflbld3
      *
     C                   EndSl
      *
     C                   EndDo

     C                   eval      scrname = oldname
     C                   eval      schead  = oldhead
     C                   eval      scopt   = oldopt
     C                   eval      cfkey = Enter
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  centerschead - Center characters in schead
     *----------------------------------------------------------------

     C     centerschead  BegSr

     C                   eval      scheadlen = %len(%trim(schead))
     C                   if        scheadlen > 0 and
     C                             scheadlen < %size(schead)
     C                   eval      scpad = %int((%size(schead)-scheadlen)/2)
     C                   eval      schead = %subst(blanks:1:scpad)
     C                                    + %trim(schead)
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  createhead1- Create subfile heading line
     *----------------------------------------------------------------

     C     createhead1   BegSr

     C                   select

     C                   when      sortorder1 = 'DATE' and w1sum = 'N'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + 'Code' + @n
     C                                     + @hu + 'Description'
     C                                     + '                   ' + @n
     C                                     + @hu + 'Count   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   when      sortorder1 = 'DATE' and w1sum = 'Y'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + 'Count   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   when      sortorder1 = 'CODE' and w1sum = 'N'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Code' + @n
     C                                     + @hu + 'Description'
     C                                     + '                   ' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + 'Count   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   when      sortorder1 = 'CODE' and w1sum = 'Y'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Code' + @n
     C                                     + @hu + 'Description'
     C                                     + '                   ' + @n
     C                                     + @hu + 'Count   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createhead2 - Create subfile heading line for item detail
     *----------------------------------------------------------------

     C     createhead2   BegSr


     C                   select

     C                   when      sortorder2 = 'ITEM'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Item           ' + @n
     C                                     + @hu + 'Description'
     C                                     + '                   ' + @n
     C                                     + @hu + 'Count   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   when      sortorder2 = 'COUNT'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Count   ' + @n
     C                                     + @hu + 'Item           ' + @n
     C                                     + @hu + 'Description'
     C                                     + '                   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createhead3 - Create subfile heading line for employee detail
     *----------------------------------------------------------------

     C     createhead3   BegSr


     C                   select

     C                   when      sortorder3 = 'EMP#'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Emp# ' + @n
     C                                     + @hu + 'Name'
     C                                     + %subst(blanks:1:33) + @n
     C                                     + @hu + 'Count   ' + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   when      sortorder3 = 'COUNT'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Count   ' + @n
     C                                     + @hu + 'Emp# ' + @n
     C                                     + @hu + 'Name'
     C                                     + %subst(blanks:1:33) + @n
416aAC                                     + @hu + 'Total Pcs   ' + @n

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      $date         $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt

     C                   select

     C                   when      sortorder1 = 'DATE' and w1sum = 'N'
     C                   eval      h1type = 'B'
     C                   eval      h1daten = $date
     C                   eval      h1code = $code
     C                   eval      h1desc = $desc
     C                   eval      sflline = '  '
     C                                     + %editc($cvd6o:'Y') + '  '
     C                                     + ' ' + $code + '   '
     C                                     + $desc + '  '
416aMC                                     + %editc($count:'Z') + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   when      sortorder1 = 'DATE' and w1sum = 'Y'
     C                   eval      h1type = 'D'
     C                   eval      h1daten = $date
     C                   eval      h1code = ' '
     C                   eval      h1desc = ' '
     C                   eval      sflline = '  '
     C                                     + %editc($cvd6o:'Y') + '  '
416aMC                                     + %editc($count:'Z') + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   when      sortorder1 = 'CODE' and w1sum = 'N'
     C                   eval      h1type = 'B'
     C                   eval      h1daten = $date
     C                   eval      h1code = $code
     C                   eval      h1desc = $desc
     C                   eval      sflline = '   '
     C                                     + $code + '   '
     C                                     + $desc + '  '
     C                                     + %editc($cvd6o:'Y') + '  '
416aMC                                     + %editc($count:'Z') + ' '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   when      sortorder1 = 'CODE' and w1sum = 'Y'
     C                   eval      h1type = 'C'
     C                   eval      h1daten = 0
     C                   eval      h1code = $code
     C                   eval      h1desc = $desc
     C                   eval      sflline = '   '
     C                                     + $code + '   '
     C                                     + $desc + '  '
416aMC                                     + %editc($count:'Z') + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createline2 - Create subfile display line for item detail
     *----------------------------------------------------------------

     C     createline2   BegSr

     C                   select

     C                   when      sortorder2 = 'ITEM'
     C                   eval      sflline = '  '
     C                                     + $item + '  '
     C                                     + $idesc + '  '
416aMC                                     + %editc($count:'Z') + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   when      sortorder2 = 'COUNT'
     C                   eval      sflline = '  '
     C                                     + %editc($count:'Z') + '  '
     C                                     + $item + '  '
416aMC                                     + $idesc + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createline3 - Create subfile display line for employee detail
     *----------------------------------------------------------------

     C     createline3   BegSr

     C                   eval      $empname = %trim($emplnam) + ', '
     C                                      + %trim($empfnam)

     C                   eval      scpad = %size($empfnam)
     C                                   + %size($emplnam)
     C                                   + 4
     C                                   - %len(%trim($empname))

     C                   select

     C                   when      sortorder3 = 'EMP#'
     C                   eval      sflline = '  '
     C                                     + %editc($emp#:'L') + ' '
     C                                     + %trim($empname)
     C                                     + %subst(blanks:1:scpad)
416aMC                                     + %editc($count:'Z') + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   when      sortorder3 = 'COUNT'
     C                   eval      sflline = '  '
     C                                     + %editc($count:'Z') + '  '
     C                                     + %editc($emp#:'L') + ' '
416aDC*                                    + %trim($empname) + '  '
416aMC                                     + ($empname) + '  '
416aAC                                     + %editc($rqty1:'Z') + '.'
416aAC                                     + %trim(%editc($rqty2:'3')) + '.'
416aAC                                     + %trim(%editc($rqty3:'3'))

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

     C     getcriteria1  BegSr

     * Display window.

     C                   ExFmt     window1

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc1
     C                   endif

     * Set selection criteria.

     *    Convert From date into CMD format.

     C                   if        w1from = 0
     C                   eval      fromdate = '0'
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1from        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        fromdate
     C                   endif

     *    Convert To date into CMD format.

     C                   if        w1to = 999999
     C                   eval      todate = '99999999'
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1to          $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        todate
     C                   endif

     *    Create screen heading.

     C                   eval      schead  = %editc(w1from:'Y')
     C                                     + ' thru '
     C                                     + %editc(w1to:'Y')
     C                   exsr      centerschead

     * Set sort order.

     C                   if        w1sort <> '1' and w1sort <> '2'
     C                   eval      w1sort = '1'
     C                   endif

     C                   select

     C                   when      w1sort = '1'
     C                   eval      sortorder1 = 'DATE'
     C                   eval      Order1 = 'ORRDTE'
     C                   eval      Order2 = 'ORRCOD'

     C                   other
     C                   eval      sortorder1 = 'CODE'
     C                   eval      Order1 = 'ORRCOD'
     C                   eval      Order2 = 'ORRDTE'

     C                   endsl

     * Set summary.

     C                   if        w1sum <> 'Y' and w1sum <> 'N'
     C                   eval      w1sum = 'Y'
     C                   endif

     C     endgetc1      EndSr

     *----------------------------------------------------------------
     *  getcriteria2 - Prompt user for sort criteria for item detail
     *----------------------------------------------------------------

     C     getcriteria2  BegSr

     * Display window.

     C                   ExFmt     window2

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc2
     C                   endif

     * Set sort order.

     C                   if        w2sort <> '1' and w2sort <> '2'
     C                   eval      w2sort = '1'
     C                   endif

     C                   select

     C                   when      w2sort = '1'
     C                   eval      sortorder2 = 'COUNT'
     C                   eval      iOrder1 = 'RCOUNT DESC'
     C                   eval      iOrder2 = 'ORITEM'

     C                   other
     C                   eval      sortorder2 = 'ITEM'
     C                   eval      iOrder1 = 'ORITEM'
     C                   eval      iOrder2 = 'RCOUNT DESC'

     C                   endsl

     C     endgetc2      EndSr

     *----------------------------------------------------------------
     *  getcriteria3 - Prompt user for sort criteria for employee detail
     *----------------------------------------------------------------

     C     getcriteria3  BegSr

     * Display window.

     C                   ExFmt     window3

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc3
     C                   endif

     * Set sort order.

     C                   if        w3sort <> '1' and w3sort <> '2'
     C                   eval      w3sort = '1'
     C                   endif

     C                   select

     C                   when      w3sort = '1'
     C                   eval      sortorder3 = 'COUNT'
     C                   eval      eOrder1 = 'RCOUNT DESC'
     C                   eval      eOrder2 = 'PTEMP#'

     C                   other
     C                   eval      sortorder3 = 'EMP#'
     C                   eval      eOrder1 = 'PTEMP#'
     C                   eval      eOrder2 = 'RCOUNT DESC'

     C                   endsl

     C     endgetc3      EndSr
