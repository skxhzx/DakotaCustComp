500 A /copy *libl/qcopysrc,hspecs
     *
     *  Attention !  See pgm TB300 for soft coding of $plset and
     *               $plfmt rather than hard coded as below.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   call      'TB310'
     C                   parm      '*PALLET '    $pcmd             8
     C                   parm      'ZBRFDI'      $plset            6
     C                   parm      'PALLET  '    $plfmt            8
     C                   parm      001           $pwhse            3 0
     C                   parm      1234567       $pal#             7 0
     C                   parm      'Rte1 '       $prte             5
     C                   parm      7654321       $plid             7 0
     C                   parm      '00001'       $rtid             5
     C                   parm      'D'           $pcomp            1
     C                   parm      123           $ldoor            3 0
     C                   parm      'ZEBRAPRT1'   $pdev            10
     C                   parm      '*STD'        $pform           10
     *
     C                   call      'TB310'
     C                   parm      '*DONE'       $pcmd             8
     C                   parm      *blanks       $plset            6
     C                   parm      *blanks       $plfmt            8
     C                   parm      *zeros        $pwhse            3 0
     C                   parm      *zeros        $pal#             7 0
     C                   parm      *blanks       $prte             5
     C                   parm      *zeros        $plid             7 0
     C                   parm      *blanks       $rtid             5
     C                   parm      *blanks       $pcomp            1
     C                   parm      *zeros        $ldoor            3 0
     C                   parm      *blanks       $pdev            10
     C                   parm      *blanks       $pform           10
     *
     C                   eval      *inlr = *on
