      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TSTEXORDH   Test EXORDH program
     *  14 March 2019
     *  Dave Sommerville
     *
     *  Revisions
     *
730 A*    03/14/19  DAS  7.30
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   The EX files, like ORDHEXA, should not be touched directly.
     *   Instead, all IO should be done by calling the corresponding
     *   program, like EXORDH.
     *
     *   If a program need to work with the file directly, it should
     *   use SQL and list each field and not use '*' for SELECTs.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.exordh

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;

       // Add record
       // The ex fields are brought into the program through c#stdvar
       // The OHA fields are brought into the program through p.exordh
       // Always use monitor because client may not have EX program.

       clear oharec;
       exWhse = 900;
       ohaord = 12345;
       ohaorda = 'ORD9876';
       ohacusta = 'CST123ABC';
       monitor;
         exordh ('*ADD': exRtnCode: exRtnMsg: exWhse: ohaord:
                 ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                 ohaorda: ohacusta);

         if exRtnCode <> '*OK';
           dsply exRtnCode;
         endif;
       on-error;
       endmon;

       // Change record

         // First you must get all the current field values

         monitor;
           exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
                   ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                  ohaorda: ohacusta);

           if exRtnCode <> '*OK';
             dsply exRtnCode;
           endif;

           if exRtnCode = '*OK';

             // Then you can change the fields you are working with

             ohaaudts = %timestamp();

             monitor;
               exordh ('*CHANGE': exRtnCode: exRtnMsg: exWhse: ohaord:
                       ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                       ohaorda: ohacusta);

               if exRtnCode <> '*OK';
                 dsply exRtnCode;
               endif;
             on-error;
             endmon;

           endif;

         on-error;
         endmon;

       // Delete record

       exWhse = 900;
       ohaord = 12345;
       monitor;
         exordh ('*DELETE': exRtnCode: exRtnMsg: exWhse: ohaord);

         if exRtnCode <> '*OK';
           dsply exRtnCode;
         endif;
       on-error;
       endmon;

       // Close ExORDH program because it doesn't set off *INLR for other commands

       monitor;
         exordh ('*CLOSE': exRtnCode: exRtnMsg: exWhse: ohaord);
       on-error;
       endmon;

       return;

      /end-free

