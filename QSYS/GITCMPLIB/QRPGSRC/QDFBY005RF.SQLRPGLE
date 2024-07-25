      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY005F  REF Load Startup Quantity
     *  14 April 2017
     *  Rod Roller
     *
     *  04/14/17  RTR  7.10
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fslotfix1  if   e           k disk    rename(slotfix1:slotrec)
     fimpfstuf3 o  a e           k disk    extmbr('GOLIVERFIX')
     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Variables
     d cntJ            s              3s 0 inz(0)
     d cntJloc         s              3s 0 inz(101)
     d currBase        s             12a
     d currCnt         s             10i 0
     d currRsrv        s              1a
     d currWhdp        s              5a
     d currDesc        s             30a
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        dou forever <> forever;
          read slotrec;

          if %eof(slotfix1);
            leave;
          endif;

          siitem = slitem;
          siqty1 = slstk1;

          // get pick slot
          exec sql select sldisp into :sidisp from slot
                    where slitem = :siitem
                      and slpick = 'Y';
          if sqlstt <> sqlsuccess;
            iter;
          endif;

          exsr WrtPickFound;
        enddo;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *  Subroutines
     *----------------------------------------------------------------
      /free

       begsr WrtPickFound;
         // use pick slot found
         siwhse = 1;
         siwhdp = '2';
         sipick = 'Y';
         sirsrv = 'Y';
         sistyp = 'F';
         siqty2 = 0;
         siqty3 = 0;
         write sirec;
       endsr;  // WrtPickFound;

      /end-free
