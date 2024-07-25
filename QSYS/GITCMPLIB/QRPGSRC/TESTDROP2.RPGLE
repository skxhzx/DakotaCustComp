      /copy *libl/qcopysrc,hspecs

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

     *  Call program to do the move.

     C                   Call(e)   'DROPPCS'
     C                   parm      1             $iwhse            3 0
     C                   parm      '07407'       $irtid            5
     C                   parm      10210         $ifromplid        7 0
     c                   parm      2320032       $ifromlbl#        7 0
     c                   parm      10410         $itoplid          7 0
     c                   parm      2             $imovqty          5 0
     c                   parm                    $irtn             8
     c                   parm      0             $inewlbl          7 0
     c                   parm                    $imessage        80

     C                   eval      *inlr = *on

