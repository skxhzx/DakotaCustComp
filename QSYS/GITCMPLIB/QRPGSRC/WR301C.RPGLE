500 A /copy *libl/qcopysrc,hspecs
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   eval      $pdesc = 'Avocado, Classic Chunky Pulp 8/2#'
     *
     C                   call      'WR301'
     C                   parm      '*REPACK '    $pcmd             8
     C                   parm      'ZBRCCP'      $plset            6
     C                   parm      'REPACK  '    $plfmt            8
     C                   parm      00002         $pqty             5 0
     C                   parm      001           $pwhse            3 0
     C                   parm      'C5 - 4501'   $pdisp           12
     C                   parm                    $pdesc           30
     C                   parm      '1501'        $pitem           15
     C                   parm      '04/13/10'    $pdate            8
     C                   parm      '20100413A'   $plcn#           15
     C                   parm      '238932'      $po              15
     C                   parm      'CASE '       $pshrt            5
     C                   parm      'PRTZEBRA1'   $pdev            10
     C                   parm      '*STD'        $pform           10
     *
     C                   call      'WR301'
     C                   parm      '*DONE   '    $pcmd             8
     C                   parm      *blanks       $plset            6
     C                   parm      *blanks       $plfmt            8
     C                   parm      0             $pqty             5 0
     C                   parm      0             $pwhse            3 0
     C                   parm      *blanks       $pdisp           12
     C                   parm      *blanks       $pdesc           30
     C                   parm      *blanks       $pitem           15
     C                   parm      *blanks       $pdate            8
     C                   parm      *blanks       $plcn#           15
     C                   parm      *blanks       $po              15
     C                   parm      *blanks       $pshrt            5
     C                   parm      *blanks       $pdev            10
     C                   parm      *blanks       $pform           10
     *
     C                   eval      *inlr = *on
