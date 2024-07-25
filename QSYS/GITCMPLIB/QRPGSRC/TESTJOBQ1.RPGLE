      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTJOBQ1   Test submitting job to jobq  - Part 1
     *  11 March 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     C                   call      'TESTJOBQ2'
     C                   parm      #user         pUser            10
     C                   parm      900           pWhse             3 0
     C                   parm      #jobn         pJobNbr           5

     C                   eval      *inlr = *on
