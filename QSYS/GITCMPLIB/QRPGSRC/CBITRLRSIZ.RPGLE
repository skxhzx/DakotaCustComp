      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRLRSIZ   Get Trailer Size
     *  07 March 2017
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
650aA*    03/07/17  JCJ  7.10a
     *      - Date Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftrlrsize  uf a e           k disk

     D                 DS
     D Dtime                         20  0
     D  Wdate                         8  0 Overlay(Dtime)
     D  Wtime                         6  0 Overlay(Dtime:*Next)

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $tcmd    -  *DELETE
     *              -  *GET
     *              -  *POST
     *     $twhse   -  Warehouse
     *     $trte    -  Route Number
     *     $trteid  -  Route Id
     *
     *  Output parameters
     *
     *     $tsize   -  Trailer size
     *     $trtn    -  Status code
     *                 *OK    - Valid code
     *                 *ERROR - Invalid code
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $tcmd             8
     C                   parm                    $twhse            3 0
     C                   parm                    $trte             5
     C                   parm                    $trteid           5
     C                   parm                    $tsize           10
     C                   parm                    $trtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        select;
        when $tcmd = '*GET';
        chain ($twhse:$trte:$trteid) trlrsize;
          if %found(trlrsize);
            $tsize = tsize;
            $trtn = '*OK     ';
          else;
            $tsize = *blanks;
            $trtn = '*ERROR  ';
          endif;
        when $tcmd = '*POST';
        chain ($twhse:$trte:$trteid) trlrsize;
          if %found(trlrsize);
            tsize = $tsize;
            dtime = %Dec(%Timestamp());
            tdate = wdate;
            ttime = wtime;
            update trec;
          else;
            twhse = $twhse;
            trte# = $trte;
            trteid = $trteid;
            tsize = $tsize;
            dtime = %Dec(%Timestamp());
            tdate = wdate;
            ttime = wtime;
            write trec;
          endif;
        endsl;

        *inlr = *on;
        return;

      /end-free
