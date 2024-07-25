      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CNTTRNPCS   Count Transaction CWgt/Non-Cwgt pieces
     *  01 Octoer 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*   10/01/09  MLB  5.20
     *     - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D sq              c                   Const('''')
     D sqlstmt         s           2000a   inz(' ')

     *----------------------------------------------------------------
     *  Parameter
     *
     *    Input Parameters
     *      $pwhse   Warehouse
     *      $prtid   Route id
     *      $ptrn#   Transaction number
     *
     *    Returned Parameters
     *      $pncwtpcs Number of non-catchweight pieces
     *      $pcwgtpcs Number of catchweight pieces
     *      $PReturn     *OK
     *                   *ERROR
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptrn#            7 0
     C                   parm                    $pncwtpcs         5 0
     C                   parm                    $pcwgtpcs         5 0
     C                   parm                    $preturn          8

     C                   eval      $pncwtpcs = 0
     C                   eval      $pcwgtpcs = 0
     C                   eval      $preturn  = '*OK'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Connect to local machine. The -842 return code indicates that the
     *  connection is already established.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Create SQL statement.

     C                   Eval      SqlStmt = 'select '
     C                                     + 'sum(case itcwgt when ''Y'' then  -
     C                                        1 else 0 end) as $pcwgtpcs,'
     C                                     + 'sum(case itcwgt when ''N'' then  -
     C                                        1 else 0 end) as $pncwtpcs,'
     C                                     + 'from label32'
     C                                     + 'where lbwhse='
     C                                     +   %trim(%editc($pwhse:'Z')) + ' '
     C                                     + 'and lbrte='
     C                                     +   sq + %trim($prtid) + sq + ' '
     C                                     + 'and lbtrn#='
     C                                     +   %trim(%editc($ptrn#:'Z'))

     *  Prepare the SQL statement for validation, since the program was
     *  compiled with DLYPRP (*YES), it will wait until it is used before
     *  it prepares the cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     *  Declare the SQL cursor to hold the data retrieved from the SELECT

     C/EXEC SQL
     C+ DECLARE MYCSR CURSOR FOR SEL
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     *  Open the SQL cursor

     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     *  Get unique item number count.

     C/EXEC SQL
     C+   FETCH mycsr INTO :$pncwtpcs, :$pcwgtpcs
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   eval      $preturn = '*ERROR'
     C                   endif

     * Close the SQL cursor after all processing is complete.

     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Return
