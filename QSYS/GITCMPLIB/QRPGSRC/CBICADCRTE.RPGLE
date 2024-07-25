      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETCADECRT   Get Cadec Route Flag
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

     Fcadecrte  uf a e           k disk

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $pcmd    -  *DELETE
     *              -  *GET
     *              -  *POST
     *     $prteid  -  Route Id
     *     $pflag   -  Cadec Route flag
     *
     *  Output parameters
     *
     *     $pflag   -  Cadec Route flag
     *     $prtn    -  Status code
     *                 *OK    - Valid code
     *                 *ERROR - Invalid code
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $prteid           5
     C                   parm                    $pflag            1
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        select;
        when $pcmd = '*GET';
          chain ($prteid) cadecrte;
          if %found(cadecrte);
            $pflag = crfflg;
            $prtn = '*OK     ';
          else;
            $pflag = *blanks;
            $prtn = '*ERROR  ';
          endif;
        when $pcmd = '*POST';
          chain ($prteid) cadecrte;
          if %found(cadecrte);
            crfflg = $pflag;
            update crfrec;
            $prtn = '*OK     ';
          else;
            crfrte = $prteid;
            crfflg = $pflag;
            write crfrec;
            $prtn = '*OK     ';
          endif;
        endsl;

        *inlr = *on;
        return;

      /end-free
