      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY002  Convert Old Slots
     *  09 September 2016
     *  Rod Roller
     *
700  *  09/09/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fimpfstuf3 uf   e           k disk    extmbr('OLDSLOTS')

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line

      /free

        // read record
        dou forever <> forever;
          read impfstuf3;

          if %eof(impfstuf3);
            leave;
          endif;

          select;
            when %subst(sidisp:1:1) = 'C';
              exsr AisleC;
            when %subst(sidisp:1:1) = 'D';
              exsr AisleD;
            when %subst(sidisp:1:1) = 'E';
              exsr AisleE;
            when %subst(sidisp:1:1) = 'F';
              exsr AisleF;
            other;
          endsl;

        enddo;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   endsr
     *
     *  ------ Aisle C ----------------------------------
      /free
        begsr AisleC;

          // determine aisle
          select;
            when sidisp = 'C01 ';
              siitem = '20-101';
            when %dec(%subst(sidisp:2:2):2:0) <= 35;
              siitem = '20-'
                     + %char(%dec(%subst(sidisp:2:2):2:0) + 102);
            when %dec(%subst(sidisp:2:2):2:0) >  35;
              siitem = '21-'
                     + %char(%dec(%subst(sidisp:2:2):2:0) + 64);
          endsl;

          // determine level
          select;
           when %subst(sidisp:4:1) = 'A'
             or %subst(sidisp:4:1) = ' ';
            siitem = %trim(siitem) + '-1';
           when %subst(sidisp:4:1) = 'B';
            siitem = %trim(siitem) + '-2';
          endsl;

          update sirec;

        endsr; // AisleC
      /end-free
     *  ------ Aisle D ----------------------------------
      /free
        begsr AisleD;
        endsr; // AisleD
      /end-free
     *  ------ Aisle E ----------------------------------
      /free
        begsr AisleE;
        endsr; // AisleE
      /end-free
     *  ------ Aisle F ----------------------------------
      /free
        begsr AisleF;
        endsr; // AisleF
      /end-free
