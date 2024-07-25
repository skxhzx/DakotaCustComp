     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTTR810     Test TR810
     *  26 January 2011
     *----------------------------------------------------------------

     C                   call      'TRVFYEMP2'
     C                   parm      'DAVE'        pEmpNo            5
     C                   parm      'DAVE'        pPwd             10
     C                   parm      ' '           pRtnMessage      60
640aAC                   parm      ' '           pUserCode        10

     C                   call      'TRVFYEMP2'
     C                   parm      'DAVE'        pEmpNo            5
     C                   parm      'DAVEX'       pPwd             10
     C                   parm      ' '           pRtnMessage      60
640aAC                   parm      ' '           pUserCode        10

     C                   eval      *inlr = '1'
