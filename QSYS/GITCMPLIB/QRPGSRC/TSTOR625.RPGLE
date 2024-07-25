      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTOR625   Test OR625
     *  22 June 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhs            15 5
     C                   parm                    $prtid            5

413aAC                   call      'OR625'
413aAC                   parm      0             $pbat             7 0
413aAC                   parm      $pwhs         $pwhse            3 0
413aAC                   parm      ''            $otype            1
413aAC                   parm                    $prtid
413aAC                   parm      ''            rhtruk           10

     C                   eval      *inlr = *on
