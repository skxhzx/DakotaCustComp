      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2022 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  APPDQCLR   Clear Android App data queue
     *  01 February 2022
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    02/01/22  DAS  7.50
     *      - Created
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
     C                   Parm                    $pdtaq            3
     C                   Parm                    $pconfirm         4

     *  Get out if user doesn't want to clear

     C                   if        $pconfirm <> '*YES'
     C                   return
     C                   end

     *  Clear data queue

     C                   select

     C                   when      $pdtaq = 'IN'
     C                   call      'QCLRDTAQ'
     C                   parm      'APPDQIN'     dqname
     C                   parm      '*LIBL'       dqlib

     C                   when      $pdtaq = 'OUT'
     C                   call      'QCLRDTAQ'
     C                   parm      'APPDQOUT'    dqname
     C                   parm      '*LIBL'       dqlib

     C                   endsl

     C                   eval      *inlr = *on
