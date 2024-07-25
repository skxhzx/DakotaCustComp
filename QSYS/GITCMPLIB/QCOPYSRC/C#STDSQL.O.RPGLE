      *===================================================================
      *
      *  Name .......... C#STDSQL
      *  Description ... Imbedded SQL Statement SQLSTT Status Codes
      *  Created by .... Chuck Manny
      *
      *  Revisions
      *
      *    02/10/09  CWM  5.20
      *      - Constants containing the statement for checking the status
      *        of the completed statement.
      *
      *        Compliments of IBM Boulder and MC Press
      *
      *===================================================================
      *
      *  Notes:
      *
      *  When an SQL statement executes, an error status code is
      *  automatically generated. This code represents success, failure,
      *  warning, or no data found. This error status code is stored in a
      *  built-in variable called SQLSTATE.
      *
      *  Class and Subclass Codes
      *  The SQLSTATE status code is a five-character string that can
      *  contain only digits and uppercase letters.
      *
     d**********************************************************************
     d*
     d* Most Commonly Used SQLSTT (SQL State) Codes
     d*
     d**********************************************************************
     d*
     d*   SQLSuccess says the SQL operation went off without a hitch,
     d*   exactly as expected.
     d*
     dSQLSuccess       c                   '00000'
     d*
     d*   SQLNoData occurs when a SELECT statement does not find a
     d*   qualifying row and thus returns no data ("No record found" in
     d*   native IO).
     d*
     dSQLNoData        c                   '02000'
     d*
     d*   SQLNoMoreData occurs when FETCHing from a cursor and you have come
     d*   to the end of the results set ("End of file" in native IO).
     d*
     dSQLNoMoreData    c                   '02000'
     d*
     d*   SQLDupRecd occurs when you do an insert that fails a primary key
     d*   constraint. (In native parlance, you have a unique key on the file
     d*   and a record with this key already exists.)
     d*
     dSQLDupRecd       c                   '23505'
     d*
     d*   SQLRowLocked occurs when you try to update a record, but someone
     d*   else has it locked for update.
     d*
     dSQLRowLocked     c                   '57033'
     d*
