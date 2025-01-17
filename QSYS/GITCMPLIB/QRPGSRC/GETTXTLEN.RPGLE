      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  GETTXTLEN    Get BFC Dakota client id from data area PIRCLIENT
     *  October 7, 2020
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740  *    10/07/20  RTR  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *    $ptext      - Text String
     *
     *   Output
     *    $plen       - Length
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $ptext          500
     c                   parm                    $plen            15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        $plen = %len(%trim($ptext));

        *inlr = *on;
        return;

      /end-free
