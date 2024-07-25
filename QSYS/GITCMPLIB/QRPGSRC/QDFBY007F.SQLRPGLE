      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY007F  FRZ Clean out slots
     *  14 April 2017
     *  Rod Roller
     *
710  *  04/14/17  RTR  7.10
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Variables
     d holddisp        s             12a
     d recdisp         s             12a

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        // remove dept dock/user slots
        exec sql delete from slot where slaisl = 'RCV' and slwhdp = '1';
        exec sql delete from slot where slaisl = 'USR' and slwhdp = '1';
        exec sql delete from vslot where vsaisl = 'RCV' and vswhdp = '1';
        exec sql delete from vslot where vsaisl = 'USR' and vswhdp = '1';

        // clear dept dates and qtys
        exec sql update slot
                    set slsdte = 0,
                        slstim = 0,
                        slentd = 0,
                        slstk1 = 0,
                        slstk2 = 0,
                        slstk3 = 0
                  where slwhdp = '1';

        // set virtual overflow to status Z
        exec sql update slot
                    set slstat = 'Z'
                  where slwhdp = '1'
                    and slrsrv = 'V'
                    and slpick = 'N';

        *inlr = *on;
      /end-free
