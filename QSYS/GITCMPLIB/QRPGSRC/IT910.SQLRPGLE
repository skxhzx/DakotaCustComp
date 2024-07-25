     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

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
     *   (630) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  IT910     Item lookup
     *  27 August 2002
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Revisions
     *
416 A*    08/27/02  HNK  4.16
     *      - Created.
     *
416 A*    09/24/02  HNK  4.16a
     *      - Change join statement to include warehouse.
     *
416 A*    09/25/02  DAS  4.16b
     *      - Create routine SQLBLDSTMT.
     *      - Change calls to SQLBLDSTMT1 to SQLBLDSTMT.
     *      - Split SQLBLDSTMT1 routine into SQLBLDSTMT1/2/3 routines.
     *
417 A*    02/26/03  MLB  4.17
     *      - Enh: Revised getcriteria routine to loop if all
     *        input fields are blank.
417aA*    07/31/03  MLB  4.17a
     *      - Fix: Changed length of $upcind to 4 binary from 2 binary.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fit910fm   cf   e             workstn
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

415aAD $desc           s             30    inz(' ')
415aAD $idesc          s             30    inz(' ')
415aAD $idescind       s              2b 0 inz(0)
415aAD $item           s             15    inz(' ')
415aAD $itemind        s              2b 0 inz(0)
     D $pitem          s             15
     D $pwhse          s              3  0
     D $pwhsea         s              3
415aAD $upc            s             20    inz(' ')
417aDD*$upcind         s              2b 0 inz(0)
417aMD $upcind         s              4b 0 inz(0)
     D groupby         S             50a   inz(' ')
     D groupfields     S             50a   inz(' ')
     D lastrrn         s                   like(rrn1)
     D leftjoin        S             80a   inz(' ')
     D leftjoin2       S             80a   inz(' ')
415aAD newordpos       s              3  0 inz(0)
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt)
     D optiontaken     s             10    inz(' ')
     D orderby         S             50a   inz(' ')
415aAD orderfield      s             10    inz(' ')
415aAD orderposition   s              3  0 inz(0)
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
     D selectfields    s             50a   inz(' ')
415aAD sortorder1      s             10    inz(' ')
     D sqlStmt         s           1000a   inz(' ')
     D whereclause     S            200a   inz(' ')
415aAD x               s              5  0 inz(0)

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1item                 1     15
     D  h1desc                16     45
     D  h1upc                 46     60

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
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $pitem

     C                   eval      $pwhse = 900
     C                   move      $pwhse        $pwhsea

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

     C                   eval      $cvprg = 'IT910'
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt  - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt    BegSr

     * Build SQL statement based on selection criteria.

     C                   select
     C                   when      w1item > ' '
     C                   exsr      sqlbldstmt1
     C                   when      w1desc > ' '
     C                   exsr      sqlbldstmt2
     C                   when      w1upc > ' '
     C                   exsr      sqlbldstmt3
     C                   other
     C                   exsr      sqlbldstmt1
     C                   endsl

     * Create list heading

     C                   exsr      createhead1

     C                   endsr

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment for item lookup
     *----------------------------------------------------------------

     C     sqlbldstmt1   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'ITITEM, ITDESC, UPUPC '

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN UPC '
     C                                      + 'ON UPWHSE = ITWHSE AND '
     C                                      + 'UPITEM = ITITEM'

     * Create "where" clause.

     C                   Eval      WhereClause = 'WHERE ITWHSE = ' + $pwhsea
     C                                         + ' AND ITITEM >= '
     C                                         + quote
     C                                         + w1item
     C                                         + quote

     C                   eval      OrderBy = 'ORDER BY ITITEM'

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM PIRITEM '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + %trimr(OrderBy) + ' '
     C                                     + 'OPTIMIZE FOR 17 ROWS'

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment for description lookup
     *----------------------------------------------------------------

     C     sqlbldstmt2   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'ITITEM, ITDESC, UPUPC '

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN UPC '
     C                                      + 'ON UPWHSE = ITWHSE AND '
     C                                      + 'UPITEM = ITITEM'

     * Create "where" clause.

     C                   Eval      WhereClause = 'WHERE ITWHSE = ' + $pwhsea
     C                                         + ' AND ITDESC >= '
     C                                         + quote
     C                                         + w1desc
     C                                         + quote
     C                   eval      OrderBy = 'ORDER BY ITDESC'

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM PIRITEM '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + %trimr(OrderBy) + ' '
     C                                     + 'OPTIMIZE FOR 17 ROWS'

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt3 - Build SQL statment for upc lookup
     *----------------------------------------------------------------

     C     sqlbldstmt3   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'ITITEM, ITDESC, UPUPC '

     * Create "left outer join" clause

     C                   eval      LeftJoin = ' '
     C                   eval      LeftJoin = 'LEFT OUTER JOIN PIRITEM '
     C                                      + 'ON ITWHSE = UPWHSE AND '
     C                                      + 'ITITEM = UPITEM'

     * Create "where" clause.

     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      w1upc         $cstr            30
     C                   move      $cstr         w1upc

     C                   Eval      WhereClause = 'WHERE UPWHSE = ' + $pwhsea
     C                                         + ' AND UPUPC >= '
     C                                          + quote
     C                                          + w1upc
     C                                          + quote
     C                   eval      OrderBy = 'ORDER BY UPUPC'

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM UPC '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + %trimr(OrderBy) + ' '
     C                                     + 'OPTIMIZE FOR 17 ROWS'

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
     C                   eval      sqlstt=sqlstt
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   eval      sqlstt=sqlstt
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   eval      sqlstt=sqlstt
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

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :$item :$itemind,
     C+           :$idesc :$idescind,
     C+           :$upc :$upcind
     C/END-EXEC

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
     C                   when      %trim(option) = '1'
     C                   eval      $pitem = h1item
     C                   eval      optiontaken = 'Yes'
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

     C                   Eval      scrname = 'IT910.01'

     C                   eval      w1item = ' '
     C                   eval      w1upc = ' '
     C                   eval      w1desc = ' '

     C                   if        w1item > ' '
     C                   eval      schead  = w1item
     C                   endif

     C                   if        w1upc > ' '
     C                   eval      schead  = w1upc
     C                   endif

     C                   if        w1desc > ' '
     C                   eval      schead  = w1desc
     C                   endif

     C                   exsr      centerschead

     C                   eval      scopt = '1=Select'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt
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
     C                   if        optiontaken = 'Yes'
     C                   Leave
     C                   endif

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   eval      w1item = ' '
     C                   eval      w1upc = ' '
     C                   eval      w1desc = ' '
     C                   ExSr      getcriteria1
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt
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

     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Item           ' + @n
     C                                     + @hu + 'Description         '
     C                                     + '         ' + @n
     C                                     + @hu + 'UPC                 ' + @n

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

     C                   eval      h1item = $item
     C                   eval      h1desc = $idesc
     C                   eval      h1upc  = $upc
     C                   eval      sflline = '  '
     C                                     + $item + '  '
     C                                     + $idesc + '   '
     C                                     + $upc

     C                   endsr

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

     C     getcriteria1  BegSr

     * Display window.
417 AC     #WIN1         Tag

     C                   ExFmt     window1

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc1
     C                   endif

417 AC                   if        W1desc = ' ' and w1item = ' ' and
417 AC                             w1upc = ' '
417 AC                   goto      #win1
417 AC                   endif

     * Set selection criteria.

     *    Create screen heading.

     C                   eval      schead  = w1item
     C                   exsr      centerschead

     C     endgetc1      EndSr

