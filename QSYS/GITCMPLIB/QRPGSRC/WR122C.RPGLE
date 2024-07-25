      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pritem               22     36
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $pcmd = '*CHANGE'
     C                   eval      $pwhse = 900
     C                   eval      $pritem = '1071'
     *
     C                   call      'WR122'
     C                   parm                    $parms
     *
     C                   eval      *inlr = *on
