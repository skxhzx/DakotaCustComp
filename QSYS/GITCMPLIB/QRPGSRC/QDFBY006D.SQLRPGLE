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
     fimpfpqty  if   e           k disk    extmbr('TEST1227A')
     fqdfbyxref2uf a e           k disk
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
          read impfpqty;

          if %eof(impfpqty);
            leave;
          endif;

          x2item = %subst(ijitem:1:5);
          x2olds = %subst(ijitem:6:8);
          x2disp = *blanks;
          x2qty1 = ijtqh1;
          x2qty2 = ijtqh2;

          // skip if no slot and no qty
          if x2olds = *blanks
           and x2qty1 = 0
           and x2qty2 = 0;
            x2act = 'SK1';
            x2text = 'Skipped - No NDS slot or qty.';
            write x2rec;
            iter;
          endif;

          // check if item exists
          exec sql select itwhdp,itdesc into :currWhdp,:currDesc from piritem
                    where ititem = :x2item;
          if sqlstt <> sqlsuccess;
            x2act = 'ER1';
            x2text = 'Item does not exist.';
            write x2rec;
            iter;
          endif;
          if currWhdp <> '3';
            x2act = 'SK2';
            x2text = 'Item not Dry item.';
            write x2rec;
            iter;
          endif;

          // check if item already has a pick slot
          x2Desc = currDesc;
          currCnt = 0;
          exec sql select count(*) into :currCnt from slot
                    where slitem = :x2item
                      and slpick = 'Y';

          if sqlstt <> sqlsuccess;
            x2act = 'ER2';
            x2text = 'SQL error: ' + sqlstt;
          endif;

          if currCnt>= 1;
            exec sql select sldisp into :x2disp from slot
                      where slitem = :x2item
                        and slpick = 'Y';
            x2act = 'SK3';
            x2text = 'Pick slot ' + %trim(x2disp)
                   + ' already exists for item.';
            write x2rec;
          else;
            x2act = 'ER3';
            x2text = 'No pick slot found';
            write x2rec;
          endif;
        enddo;

        *inlr = *on;
      /end-free
