      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TDFORCE   Send FORCE command to WRTTRAND data queue
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
     C                   parm                    $pconfirm         4
417ba
417ba*  Get out if user doesn't want to end.
417ba
417baC                   if        $pconfirm <> '*YES'
417baC                   return
417baC                   end

     *  Send command

     C                   call      'QSNDDTAQ'
     C                   parm      'WRTTRAND'    dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm      5             dqlen
     C                   parm      'FORCE'       dqdata

     C                   eval      *inlr = *on
