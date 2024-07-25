      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY006  Compare Pick Slots
     *  01 December 2016
     *  Rod Roller
     *
     *  12/01/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fslot      if   e           k disk
     fvslot1    uf a e           k disk
     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Variables
     d currCnt         s             10i 0
     d currWhdp        s              5a
     d currDesc        s             30a
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        dou forever <> forever;
          read slot;

          if %eof(slot);
            leave;
          endif;

          if slwhdp <> '2';
            iter;
          endif;

          if slrsrv <> 'V';
            iter;
          endif;

          // check if vslot exists
          chain (slwhse:slwhdp:sldisp) vslot1;
          if %found();
            iter;
          else;
            VSWHSE = slwhse;
            VSWHDP = slwhdp;
            VSAISL = slaisl;
            VSLOC  = slloc;
            VSRLVL = slrlvl;
            VSHAND = slhand;
            VSDISP = sldisp;
            VSPDIS = %subst(sldisp:1:8);
          //VSCDTE = slwhse;
          //VSCTIM = slwhse;
            write vsrec;
          endif;

        enddo;

        *inlr = *on;
      /end-free
