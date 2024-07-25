
     *----------------------------------------------------------------
     * Begin C#STDSQL - Standard SQL variable and constants
     *
     *   12/20/02  DAS  4.16
     *     - Created
     *
520aA*   02/10/09  CWM  5.20a
     *     - Constants containing the statement for checking the status
     *       of the completed statement.
     *
610aA*   10/01/10  DAS  6.10a
     *     - Added 42703.
     *
640aA*   09/13/11  DAS  6.40b
     *     - Added 42704.
     *
640bA*   03/09/12  DAS  6.40b
     *     - Added 01003.
     *
640bA*   05/12/16  NLK  7.00b
     *     - Added sqljoin3 for BX311
     *
740aA*   02/28/20  DAS  7.40a
     *     - Added 42710.
     *
     *----------------------------------------------------------------

     D sqlfetchcount   s              5s 0
     D sqlfrom         s             50a   inz(' ')
     D sqllastrrn      s              5s 0
     D sqlorder        s            100a   inz(' ')
     D sqlrelpos       s              5s 0
     D sqlrrn          s              5s 0
     D sqlstmt         s           2000a   inz(' ')
     D sqljoin         s            200a   inz(' ')
     D sqljoin2        s            200a   inz(' ')
     D sqljoin3        s            200a   inz(' ')
     D sqlwhere        S            500a   inz(' ')
520aA **********************************************************************
520aA *
520aA * Most Commonly Used SQLSTT (SQL State) Codes
520aA *
520aA **********************************************************************
520aA *
520aA *  Notes:
520aA *
520aA *  When an SQL statement executes, an error status code is
520aA *  automatically generated. This code represents success, failure,
520aA *  warning, or no data found. This error status code is stored in a
520aA *  built-in variable called SQLSTATE.
520aA *
520aA *  Class and Subclass Codes
520aA *  The SQLSTATE status code is a five-character string that can
520aA *  contain only digits and uppercase letters.
520aA *
520aAd**********************************************************************
520aA
520aAd*   SQLSuccess says the SQL operation went off without a hitch,
520aAd*   exactly as expected.
520aA
520aAd sqlSuccess      c                   '00000'
640bA
640bAd*   SQLNullValElim occurs when a Left Outer Join isn't made.
640aA
640aAd sqlNullValElim  c                   '01003'
520aA
520aAd*   SQLNoData occurs when a SELECT statement does not find a
520aAd*   qualifying row and thus returns no data ("No record found" in
520aAd*   native IO).
520aA
520aAd sqlNoData       c                   '02000'
520aA
520aAd*   SQLNoMoreData occurs when FETCHing from a cursor and you have come
520aAd*   to the end of the results set ("End of file" in native IO).
520aA
520aAd sqlNoMoreData   c                   '02000'
520aA
520aAd*   SQLDupRecd occurs when you do an insert that fails a primary key
520aAd*   constraint. (In native parlance, you have a unique key on the file
520aAd*   and a record with this key already exists.)
520aA
520aAd sqlDupRecd      c                   '23505'
610aA
610aAd*   SQLUndefColumn occurs when a field does not exist in the file.
610aA
610aAd sqlUndefColumn  c                   '42703'
640aA
640aAd*   SQLUndefObject occurs when a file does not exist.
640aA
640aAd sqlUndefObject  c                   '42704'
740aA
740aAd*   SQLDupObj occurs when a view/index exists
740aA
740aAd sqlDupObj       c                   '42710'
520aA
520aAd*   SQLRowLocked occurs when you try to update a record, but someone
520aAd*   else has it locked for update.
520aA
520aAd sqlRowLocked    c                   '57033'
520aA
     *** End C#STDSQL ***
