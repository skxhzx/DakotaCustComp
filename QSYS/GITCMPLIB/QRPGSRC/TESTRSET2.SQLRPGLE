417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTRSET2   Test result sets 2
     *  02 February 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

     D itrec         E ds                  extname(piritem) inz(*EXTDFT)

      /free

         *inlr = *on;

         exec sql
           declare resultset1 cursor for
           select sldisp
             from slot
             fetch first 15 rows only;

         exec sql open resultset1;

         exec sql
           declare resultset2 cursor for
           select ititem
             from piritem
             fetch first 5 rows only;

         exec sql open resultset2;

         dump(a);

         exec sql fetch next from resultset2
                  into :ititem;

         exec sql
           set result sets with return to client
               cursor resultset1,
               cursor resultset2;

         // Splitting doesn't work.
         // Only sent back last one.

         //exec sql
         //  set result sets with return to client
         //      cursor resultset1;

         //exec sql
         //  set result sets with return to client
         //      cursor resultset2;

         return;
      /end-free
