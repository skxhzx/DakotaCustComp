      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTTR812  Test TR812
     *  26 April 2017
     *  Dave Sommerville
     *
740aA*    11/19/20  RBD  7.40a
     *      - Fix: Command to process route should be looking
     *        for *ROUTE rather than ROUTE.
     *
     *----------------------------------------------------------------

     D pWhse           s              3  0
     D pRtid           s              5
     D pEmp            s              5
     D pFileSnd        s             30
     D pRtn            s              8
     D pErm            s             60
     D dsplyMsg        s             32

     D tr812           pr                  extpgm('TR812')
     D  pCmd                         10    const
     D  pWhse                         3  0
     D  pRtid                         5
     D  pEmp                          5
     D  pFileSnd                     30
     D  pRtn                          8
     D  pErm                         60

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pwhse           15 5
     C                   parm                    $prtid            5

      /free

       *inlr = *on;

       if $pCmd <> '*COMPANY'
         and $pCmd <> '*ROUTE';
           dsplyMsg = 'Command must be *COMPANY or *ROUTE';
           dsply dsplyMsg;
           return;
       endif;

       pWhse = $pwhse;
       pRtid = '';
       pEmp = '';
       pFileSnd = '';
       pRtn = '';
       pErm = '';

740aD  //if $pCmd = 'ROUTE';
740aM  if $pCmd = '*ROUTE';
           pRtid = $prtid;
       endif;

       tr812($pCmd: pWhse: pRtid: pEmp: pFileSnd: pRtn: pErm);

       if pRtn <> '*OK';
           dsplyMsg = 'Error: ' + %trim(pRtn) + '-' + pErm;
           dsply dsplyMsg;
       endif;

      /end-free

