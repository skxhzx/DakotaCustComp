      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DROPPCS   Drop pieces - Pgm for SQL procedure of same name
     *  31 January 2013
     *  Rod Roller
     *
     *  Revisions:
     *
     *    01/31/13  RTR  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
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

     C     *entry        plist
     C                   parm                    $iwhse            3 0
     C                   parm                    $irtid            5
     C                   parm                    $ifromplid        7 0
     C                   parm                    $ifromlbl#        7 0
     C                   parm                    $itoplid          7 0
     C                   parm                    $imovqty          5 0
     C                   parm                    $irtn             8
     C                   parm                    $inewlbl          7 0
     C                   parm                    $imessage        80

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Call program to do the move.

     C                   eval      $pcmd = '*DROP'
     C                   eval      $pwhse = $iwhse
     C                   eval      $prtid = $irtid
     C                   eval      $pplid = $ifromplid
     C                   eval      $plbl# = $ifromlbl#
     C                   eval      dsplid = $itoplid
     C                   eval      $prow  = dsplrw
     C                   eval      $pcol  = dsplcl
     C                   eval      $prte  = ' '
     C                   eval      $pcomp = ' '
     C                   eval      $puseq = 0
     C                   eval      $pbseq = 0
     C                   eval      $pstop = 0
     C                   eval      $pzone = ' '
     C                   eval      $pmovqty = $imovqty
     C                   eval      $pnewlbl = $inewlbl

     C                   Call(e)   'PS152'
     C                   Parm                    $parms
     C                   Parm                    $pmovqty
     C                   Parm                    $pnewlbl

     *  Reformat return message

     C                   if        %error
     C                   eval      $prtn = '*CALLERR'
     C                   eval      $perm = 'Error calling program '
     C                                   + 'PS152'
     C                   endif

     C                   eval      $irtn = $prtn
     C                   eval      $imovqty = $pmovqty
     C                   eval      $inewlbl = $pnewlbl

     C                   if        $prtn = '*OK'
     C                   eval      $imessage = $perm
     C                   else
     C                   eval      $imessage = 'Error ('
     C                                       + %trim($prtn)
     C                                       + '): '
     C                                       + %trim($perm)
     C                   endif

     C                   eval      *inlr = *on
