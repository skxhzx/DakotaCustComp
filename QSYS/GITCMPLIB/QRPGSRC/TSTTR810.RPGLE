      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTTR810  Test TR810
     *  16 June 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     D pWhse           s              3  0
     D pRtid           s              5
     D pEmp            s              5
     D pFileSnd        s             30
     D pRtn            s              8
     D pErm            s             60
     D dsplyMsg        s             32

     D tr810           pr                  extpgm('TR810')
     D  pWhse                         3  0
     D  pRtid                         5
     D  pEmp                          5
     D  pFileSnd                     30
     D  pRtn                          8
     D  pErm                         60

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $prtid            5

      /free

       *inlr = *on;

       pWhse = $pwhse;
       pRtid = $prtid;
       pEmp = '';
       pFileSnd = '';
       pRtn = '';
       pErm = '';

       tr810(pWhse: pRtid: pEmp: pFileSnd: pRtn: pErm);

       if pRtn <> '*OK';
           dsplyMsg = 'Error: ' + %trim(pRtn) + '-' + pErm;
           dsply dsplyMsg;
       endif;

      /end-free

