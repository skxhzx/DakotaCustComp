417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTRSET2   Test result sets 2
     *  02 February 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
     D sqlstmt1        s           2000a   varying
     D sqlstmt2        s           2000a   varying

      /free

         *inlr = *on;

         // This doesn't work. Receive SQLSTT=26501.

         SqlStmt1= 'select sldisp '
                 + 'from slot '
                 + 'fetch first 15 rows only';

         //exec sql declare resultset1 dynamic scroll cursor for sbUpdSel;
         exec sql declare resultset1 cursor for sqlStmt1;
         if sqlstt <> sqlSuccess;
           dump(a);
         endif;

         exec sql open resultset1;
         if sqlstt <> sqlSuccess;
           dump(a);
         endif;

         SqlStmt2= 'select ititem '
                 + 'from piritem '
                 + 'fetch first 5 rows only';

         exec sql declare resultset2 cursor for sqlStmt2;
         if sqlstt <> sqlSuccess;
           dump(a);
         endif;

         exec sql open resultset2;
         if sqlstt <> sqlSuccess;
           dump(a);
         endif;

         exec sql
           set result sets with return to client
               cursor resultset1,
               cursor resultset2;

         return;
      /end-free
