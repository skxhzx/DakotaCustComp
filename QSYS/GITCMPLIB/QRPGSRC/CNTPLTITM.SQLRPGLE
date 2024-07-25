      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CNTPLTNUM   Count unique item numbers on pallet
     *  13 March 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*   03/13/07  DAS  5.10
     *     - Created.
510aA*   05/01/07  MLB  5.10a
     *     - Enh: Revised program to pass back pallet section id.
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
     *      $pplid   Pallet id
     *
     *    Returned Parameters
     *      $pitems  Unique item count
510aA*      $ppltsct Pallet section ID
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
     C                   parm                    $pplid            7 0
     C                   parm                    $pitems           5 0
510aAC                   parm                    $ppltsct          2
     C                   parm                    $preturn          8

     C                   eval      $pitems = 0
510aAC                   eval      $ppltsct = '  '
     C                   eval      $preturn = '*OK'

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
510aAC                                     + 'min(lbhnd2), '
     C                                     + 'count(distinct lbitem) '
     C                                     + 'from label '
     C                                     + 'where lbwhse='
     C                                     +   %trim(%editc($pwhse:'Z')) + ' '
     C                                     + 'and lbrte='
     C                                     +   sq + %trim($prtid) + sq + ' '
     C                                     + 'and lbpal#='
     C                                     +   %trim(%editc($pplid:'Z'))

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
510aDC**  FETCH mycsr INTO :$pitems
510aMC+   FETCH mycsr INTO :$ppltsct, :$pitems
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
