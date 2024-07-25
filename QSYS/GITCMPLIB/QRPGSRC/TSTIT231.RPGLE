      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTIT231  Test IT231
     *  31 January 2009
     *  Dave Sommerville
     *----------------------------------------------------------------

     D $prtky          ds
     D  $len50                 1    100
     D  $whse                  1      3  0
     D  $itemds                4     18
     D  $home                 19     30
     D  $disp                 31     42
     D  $lbl#                 43     49  0
     D  $trn#                 50     56  0
     D  $bat#                 57     63  0
500bAD  $lalwc                47     47
     D  $prg#                 64     73
417cAD  $pllp#                74     88
600uAD  $whdp                 89     93
600bA
600bAC                   eval      $whse = 900
600bAC                   eval      $itemds = 'DA101'
600bAC                   call      'IT231'
600bAC                   parm                    $prtky
600bAC                   parm      'LT105   '    $rtncd            8
600bA
600bAC                   call      'IT231'
600bAC                   parm                    $prtky
600bAC                   parm      ' '           $rtncd            8
600bA
600bAC                   eval      *inlr = *on
