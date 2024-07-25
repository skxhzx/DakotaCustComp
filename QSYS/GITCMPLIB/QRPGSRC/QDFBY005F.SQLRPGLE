      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY005F  FRZ Load Startup Quantity
     *  01 January 2018
     *  Rod Roller
     *
     *  01/30/18  RTR  7.20
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fimpfpqty  uf   e           k disk    extmbr('GOLIVEFRZ')
     fimpfstuf3 o  a e           k disk    extmbr('GOLIVEFRZ')
     fqdfbyxrf5fo  a e           k disk
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
          read impfpqty;

          if %eof(impfpqty);
            leave;
          endif;

          x5item = %subst(ijitem:1:5);
          x5olds = %subst(ijitem:6:8);
          x5disp = *blanks;
          x5qty1 = ijtqh1;
          x5qty2 = ijtqh2;

          // skip if no qty
          if x5qty1 = 0
           and x5qty2 = 0;
            x5act = 'SK1';
            x5text = 'Skipped - No qty.';
            write x5rec;
            iter;
          endif;

          // check if item exists
          exec sql select itwhdp,itdesc into :currWhdp,:currDesc from piritem
                    where ititem = :x5item;
          if sqlstt <> sqlsuccess;
            x5act = 'ER1';
            x5text = 'Item does not exist.';
            write x5rec;
            iter;
          endif;
          if currWhdp <> '1';
            x5act = 'SK2';
            x5text = 'Item not Freezer item.';
            write x5rec;
            iter;
          endif;

          // if Foodmart item, set to NSTK* and skip
          if x5olds = 'FMART';
            exec sql update piritem
                        set itdesg = 'NSTK*'
                      where ititem = :x5item;
            if sqlstt <> sqlsuccess;
              x5act = 'ER2';
              x5text = 'Unable to set as Foodmart item.';
              write x5rec;
              iter;
            else;
              x5act = 'SK3';
              x5text = 'Foodmart item.';
              write x5rec;
              iter;
            endif;
          endif;

          // check if item already has a pick slot
          x5Desc = currDesc;
          currCnt = 0;
          exec sql select count(*) into :currCnt from slot
                    where slitem = :x5item
                      and slpick = 'Y';

          if sqlstt <> sqlsuccess;
            x5act = 'ER*';
            x5text = 'SQL error: ' + sqlstt;
          endif;

          if currCnt>= 1;
            exec sql select sldisp,slrsrv into :x5disp, :currRsrv
                       from slot
                      where slitem = :x5item
                        and slpick = 'Y';
            exsr WrtPickFound;
          else;
            exsr WrtPickFloor;
          endif;
        enddo;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *  Subroutines
     *----------------------------------------------------------------
      /free

       begsr WrtPickFound;
         // get base slot if reserved
         if currRsrv = 'V';
           exec sql select vspdis into :currBase
                      from vslot
                     where vsdisp = :x5disp;
           if sqlstt <> sqlsuccess;
             x5disp = sqlstt;
           else;
             x5disp = currBase;
           endif;
         endif;
         // use pick slot found
         x5act = 'OK ';
         x5text = 'Pick slot ' + %trim(x5disp)
                + ' exists for item.';
         write x5rec;
         siwhse = 1;
         siwhdp = currWhdp;
         sidisp = x5Disp;
         siitem = x5Item;
         sipick = 'Y';
         sirsrv = 'Y';
         sistyp = 'F';
         siqty1 = ijtqh1;
         siqty2 = ijtqh2;
         siqty3 = 0;
         write sirec;
       endsr;  // WrtPickFound;

       begsr WrtPickFloor;
         // no pick slot found, use floor
         select;
           when %subst(x5olds:1:1) = 'P';
             x5disp = '61-PFLOOR';
           when %subst(x5olds:1:1) = 'Q';
             x5disp = '64-QFLOOR';
           when %subst(x5olds:1:1) = 'R';
             x5disp = '67-RFLOOR';
           when %subst(x5olds:1:1) = 'S';
             x5disp = '70-SFLOOR';
           when %subst(x5olds:1:1) = 'T';
             x5disp = '65-TFLOOR';
           when %subst(x5olds:1:1) = 'U';
             x5disp = '66-UFLOOR';
           other;
             x5disp = '61-FLOOR';
         endsl;

         x5act = 'OKF';
         x5text = 'No pick slot found, using ' + x5disp;
         write x5rec;
         siwhse = 1;
         siwhdp = currWhdp;
         sidisp = x5disp;
         siitem = x5Item;
         sipick = 'Y';
         sirsrv = 'Y';
         sistyp = 'F';
         siqty1 = ijtqh1;
         siqty2 = ijtqh2;
         siqty3 = 0;
         write sirec;
       endsr;  // WrtPickFloor;

