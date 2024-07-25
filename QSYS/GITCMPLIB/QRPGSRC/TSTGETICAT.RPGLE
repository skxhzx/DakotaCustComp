      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTGETICAT   Test GETICAT
     *  18 March 2004
     *  Dave Sommerville
     *----------------------------------------------------------------

CDIaAD $cwhsenum       s              3  0
CDIaAD $cwhse          s              3
CDIaAD $citem          s             15
CDIaAD $ccode          s             10
CDIaAD $chhdr          s              1
CDIaAD $chdtl          s              1
CDIaAD $chcat          s              1

CDIaAC                   eval      $cwhsenum = 2
CDIaAC                   move      $cwhsenum     $cwhse
CDIaAC                   eval      $citem = '50070013'

CDIaAC                   call      'GETICAT'
CDIaAC                   parm                    $cwhse
CDIaAC                   parm                    $citem
CDIaAC                   parm                    $ccode
CDIaAC                   parm                    $chhdr
CDIaAC                   parm                    $chdtl
CDIaAC                   parm                    $chcat

     C                   eval      *inlr = *on
