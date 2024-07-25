      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTDESIGSP   Test CHKDESIGSP
     *  12 March 2007
     *  Dave Sommerville
     *----------------------------------------------------------------

     d msg             s             52

     C     *entry        plist
     C                   parm                    $pdesig           5
     C                   parm                    $pitem           15

     c                   call      'CHKDESIGSP'
     c                   parm                    $pdesig           5
     C                   parm                    $pitem           15
     c                   parm                    $pwhdp            5
     c                   parm                    $pdisp           12
     c                   parm                    $pchkdgt          3 0
     c                   parm                    $prtn             8

     c                   eval      msg = %trim($prtn) + ': '
     c                                 + %trim($pdesig) + '/'
     c                                 + %trim($pitem) + '/'
     c                                 + %trim($pwhdp) + '/'
     c                                 + %trim($pdisp) + '/'
     c                                 + %trim(%char($pchkdgt))
     c     msg           dsply

     c                   eval      *inlr = *on
