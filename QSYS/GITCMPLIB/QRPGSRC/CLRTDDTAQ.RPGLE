      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CLRTDDTAQ    Clear WRTTRAND data queue
     *  16 February 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
640  *    02/16/12  DAS  6.40
     *      - Created
     *
640a *    08/30/12  DAS  6.40a
     *      - Added data queue parameter
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D  dqlib          s             10
     D  dqname         s             10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C     *Entry        PList
640aAC                   Parm                    $pdtaq            1
     C                   Parm                    $pconfirm         4

     *  Get out if user doesn't want to clear

     C                   if        $pconfirm <> '*YES'
     C                   return
     C                   end

     *  Clear data queue

640aAC                   select
640aA
640aAC                   when      $pdtaq = '1'
     C                   call      'QCLRDTAQ'
     C                   parm      'WRTTRAND'    dqname
     C                   parm      '*LIBL'       dqlib
640aA
640aAC                   when      $pdtaq = '2'
640aAC                   call      'QCLRDTAQ'
640aAC                   parm      'WRTTRAND2'   dqname
640aAC                   parm      '*LIBL'       dqlib
640aA
640aAC                   when      $pdtaq = '3'
640aAC                   call      'QCLRDTAQ'
640aAC                   parm      'WRTTRAND3'   dqname
640aAC                   parm      '*LIBL'       dqlib
640aA
640aAC                   endsl

     C                   eval      *inlr = *on
