      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY007  Clean out slots
     *  01 December 2016
     *  Rod Roller
     *
700  *  12/01/16  RTR  7.00
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

        // remove dock/user slots
        exec sql delete from slot
                  where slaisl = 'RCV'
                     or slaisl = 'USR';
        exec sql delete from vslot
                  where vsaisl = 'RCV'
                     or vsaisl = 'USR';

        // clear all slot dates and qtys
        exec sql update slot
                    set slsdte = 0,
                        slstim = 0,
                        slentd = 0,
                        slstk1 = 0,
                        slstk2 = 0,
                        slstk3 = 0;

        // remove items from overflow slots
        exec sql update slot
                    set slitem = '    ',
                        slstk1 = 0,
                        slstk2 = 0,
                        slstk3 = 0,
                        slstat = 'V'
                  where slpick = 'N';

        // set virtual overflow to status Z
        exec sql update slot
                    set slstat = 'Z'
                  where slrsrv='V'
                    and slpick='N';

        *inlr = *on;
      /end-free
