      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDAISLE  Fix aisle in slot, vslot and licactive
     *  16 Nov 2018
     *  Retha Davis
     *
     *  11/16/18  RBD  7.20
     *    - Created.  Ran at City Line per Steve Di Zinno.
     *
     *----------------------------------------------------------------
     *  File Specs
     flicactive uf   e           k disk
     fslot      uf   e           k disk
     fvslot     uf   e           k disk
     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Variables
     d cntJ            s              3s 0 inz(0)
     d currBase        s             12a
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        // Fix licactive records

        dou forever <> forever;
          read licactive;

          if %eof(licactive);
            leave;
          endif;

          if laaisl <> '  S';
            iter;
          endif;

          select;

            when %subst(ladisp:1:3) = 'SA-';
              laaisl = ' SA';
              update larec;

            when %subst(ladisp:1:3) = 'SB-';
              laaisl = ' SB';
              update larec;

            when %subst(ladisp:1:3) = 'SC-';
              laaisl = ' SC';
              update larec;

          endsl;
        enddo;


        // Fix slot records

        dou forever <> forever;
          read slot;

          if %eof(slot);
            leave;
          endif;

          if slaisl <> '  S';
            iter;
          endif;

          select;

            when %subst(sldisp:1:3) = 'SA-';
              slaisl = ' SA';
              update slrec;

            when %subst(sldisp:1:3) = 'SB-';
              slaisl = ' SB';
              update slrec;

            when %subst(sldisp:1:3) = 'SC-';
              slaisl = ' SC';
              update slrec;

          endsl;
        enddo;


        // Fix vslot records

        dou forever <> forever;
          read vslot;

          if %eof(vslot);
            leave;
          endif;

          if vsaisl <> '  S';
            iter;
          endif;

          select;

            when %subst(vsdisp:1:3) = 'SA-';
              vsaisl = ' SA';
              update vsrec;

            when %subst(vsdisp:1:3) = 'SB-';
              vsaisl = ' SB';
              update vsrec;

            when %subst(vsdisp:1:3) = 'SC-';
              vsaisl = ' SC';
              update vsrec;

          endsl;
        enddo;


        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
