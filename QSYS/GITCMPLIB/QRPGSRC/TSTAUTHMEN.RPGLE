      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTAUTHMEN  Test AUTHMENU
     *  10 July 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     D gmiid           s             20
     D pUser           s             10
     D authView        s              1p 0
     D authAdd         s              1p 0
     D authChg         s              1p 0
     D authDlt         s              1p 0

     D AUTHMENU        pr                  extpgm('AUTHMENU')
     D  pMenuItemId                  20
     D  pUser                        10
     D  pViewFlag                     1p 0
     D  pAddflag                      1p 0
     D  pChgFlag                      1p 0
     D  pDltFlag                      1p 0

      /free
        *inlr = *on;

        gmiid = 'GLOBALADMIN';
        pUser = 'DAVE4';
        AuthMenu(gmiid: pUser: authView: authAdd: authChg: authDlt);

        gmiid = 'GLOBALADMIN';
        pUser = 'DAVE';
        AuthMenu(gmiid: pUser: authView: authAdd: authChg: authDlt);

        return;
      /end-free
