417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTRSET5   Test result sets 5
     *  07 June 2013
     *  Dave Sommerville
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         exec sql
           declare resultset1 cursor for
           select * from warehs;

         exec sql open resultset1;

         exec sql
           set result sets with return to client
               cursor resultset1;

         return;
      /end-free
