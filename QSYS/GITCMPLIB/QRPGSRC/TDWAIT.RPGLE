      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TDWAIT   Send WAIT command to WRTTRAND
     *  17 February 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
100 A*    02/17/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D  dqdata         s             30
     D  dqlen          s              5  0
417aAD  dqlib          s             10
     D  dqname         s             10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwait            2 0

      /free

640pA   *inlr = *on;

        if $pwait <= 0;
          return;
        endif;

640pA   dqdata = 'WAIT' + %editc($pwait:'X');
640pA   dqlen  = %len(%trim(dqdata));

      /end-free

     C                   call      'QSNDDTAQ'
     C                   parm      'WRTTRAND'    dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
