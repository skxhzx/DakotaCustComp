417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TRVFYEMP2   Tracker - Verify emp# w/pwd
     *  12 December 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    12/11/09  DAS  6.10
     *      - Created.
     *
640aA*    01/19/11  RBD  6.40a
     *      - Added return parm for user code (user name).
     *
700aA*    06/08/16  RBD  7.00a
     *      - Added logic to stop program with DSPLY oper so you
     *        can intercept it to start a service job and debug when
     *        this program is being called from a handheld. When
     *        the pgm hits the DSPLY stmt it will stop and send a msg
     *        to qsysopr ... once you've started your service job and
     *        debug simply enter any kind of response and press enter
     *        and the program will resume.
     *        Of course this logic will be commented out except
     *        when needing to troubleshoot.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D reply           s              5
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pEmpNo      Employee number
     *      pPwd        Password
     *
     *    Returned Parameters
     *      pRtnMessage  Return message
640aA*      pUserCode    User code (name)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pEmpNo            5
     C                   parm                    pPwd             10
     C                   parm                    pRtnMessage      60
640aAC                   parm                    pUserCode        10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

700a  /free
700a     // Temp code. Comment out when not testing.
700a     // dsply 'stop' '' reply;
700a     //pRtnMessage = '*OK';
700a     //*inlr = *on;
700a     //return;
700a  /end-free

     C                   call      'TR710'
     C                   parm                    pEmpNo
     C                   parm                    pRtnMessage
640aAC                   parm                    pUserCode
     C                   parm                    pPwd
500sA
     C                   eval      *inlr = *on
