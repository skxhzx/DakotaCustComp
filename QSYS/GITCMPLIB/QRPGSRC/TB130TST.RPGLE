      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TB130TST  Test TB130
     *  07 April 2010
     *  Retha Davis
     *----------------------------------------------------------------
     D $whse           s              3  0
     D $rtid           s              5
     D $rte            s              5
     D $rtn            s              8

600bAC                   eval      $whse = 1
600bAC                   eval      $rtid = '02442'
600bAC                   eval      $rte  = '413'
600bAC                   call      'TB130'
600bAC                   parm                    $whse
600bAC                   parm                    $rtid
600bAC                   parm                    $rte
600bAC                   parm                    $rtn
600bA
600bAC                   eval      *inlr = *on
