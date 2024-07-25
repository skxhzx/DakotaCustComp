417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TRVFYEMP    Tracker - Verify emp#
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
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pEmpNo      Employee number
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
     C                   parm                    pRtnMessage      60
640aAC                   parm                    pUserCode        10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   call      'TR710'
     C                   parm                    pEmpNo
     C                   parm                    pRtnMessage
640aAC                   parm                    pUserCode
500sA
     C                   eval      *inlr = *on
