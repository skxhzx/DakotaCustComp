      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PUSHSEQ     Push Menu Item Sequence
     *  08 November 2012
     *  Rod Roller
     *
     *  Revisions:
     *
640 A*    11/08/12  RTR  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     Fglomenu   uf   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *      pReturn     Error message
     *      pAction     Action type
     *      pMenu       Menu
     *      pSeq        Sequence
     *
     *----------------------------------------------------------------

     D pushseq         pr                  extpgm('PUSHSEQ')
     D   pReturn                     99
     D   pAction                     10    const
     D   pMenu                       20    const
     D   pSeq                         2p 0 const

     D pushseq         pi
     D   pReturn                     99
     D   pAction                     10    const
     D   pMenu                       20    const
     D   pSeq                         2p 0 const

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     d prevseq         s              2s 0

      /free
         *inlr = *on;

         pReturn = *blank;
         prevseq = pSeq;

         if pAction = 'A';

           chain (pMenu:pSeq) glomenu;
           if %found(glomenu);

             // Find last consecutive sequence
             setll (pMenu:pSeq) glomenu;
             reade (pMenu) glomenu;
             dow not %eof(glomenu);
               if gmseq# > prevseq + 1;
                 leave;
               endif;
               prevseq = gmseq#;
               reade (pMenu) glomenu;
             enddo;

             // if last record is sequence 99, return error
             if prevseq = 99;
               pReturn = 'No room to insert option.';
               prevseq = 0;
             endif;

             // Read backwards and add 1 to sequence
             setll (pMenu:prevseq) glomenu;
             reade (pMenu) glomenu;
             dow prevseq >= pSeq;
               gmseq# = gmseq# + 1;
               update gmrec;
               prevseq = prevseq - 1;
               readp glomenu;
             enddo;

           endif;
         endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         pReturn = 'U:'
                 + %trim(#pgm)
                 + '('
                 + %trim(%editc(#stmt:'Z'))
                 + ')-'
                 + #pgmmsg;

         *inlr = *on;
         return;

       endsr;
      /end-free
