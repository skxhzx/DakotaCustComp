      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
     D  $prte                 22     26
     D  $prtid                27     31
     D  $prow                 32     33  0
     D  $pcol                 34     34  0
     D  $pcomp                35     35
     D  $puseq                36     37  0
     D  $pplid                38     44  0
     D  $pbseq                45     45  0
     D  $pstop                46     47  0
     D  $pzone                48     53
     D  $plbl#                54     60  0

     D $pmovqty        s              5  0
     D $pnewlbl        s              7  0

     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $iwhse       Warehouse
     *      $irtid       Route id
     *      $ifromplid   From pallet id
     *      $ifromlbl#   From label #
     *      $itoplid     To pallet id
     *      $imovqty     Piece qty to move
     *
     *    Returned Parameters
     *      $irtn        Return code
     *      $inewlbl     New label created if partial move
     *      $imessage    Error message or pointer to message in pgmq
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     *  Call program to do the move.

     C                   eval      $pcmd = '*DROP'
     C                   eval      $pwhse = 1
     C                   eval      $prtid = '07407'
     C                   eval      $pplid = 10210
     C                   eval      $plbl# = 2320032
     C                   eval      dsplid = 10310
     C                   eval      $prow  = dsplrw
     C                   eval      $pcol  = dsplcl
     C                   eval      $prte  = ' '
     C                   eval      $pcomp = ' '
     C                   eval      $puseq = 0
     C                   eval      $pbseq = 0
     C                   eval      $pstop = 0
     C                   eval      $pzone = ' '
     C                   eval      $pmovqty = 2
     C                   eval      $pnewlbl = 0

     C                   Call(e)   'PS152'
     C                   Parm                    $parms
     C                   Parm                    $pmovqty
     C                   Parm                    $pnewlbl

     C                   eval      *inlr = *on

