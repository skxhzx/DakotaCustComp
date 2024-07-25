      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TDEND2  Send QUIT command to WRTTRAND3 data queue
     *  30 August 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
100 A*    08/30/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D  dqdata         s             10
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

     *  First, send QUIT command to WRTTRAND3

     C                   call      'QSNDDTAQ'
     C                   parm      'WRTTRAND3'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm      4             dqlen
     C                   parm      'QUIT'        dqdata

     *  Second, send command to WRTTRAND2
     *    Re: WRTTRAND3 is only read after an entry from WRTTRAND2 is read and processed.
     *        Therefore, in the case of no activity taking place with WRTTRAND2, this
     *        will prevent us from waiting for the WRTTRAND2 read to time out.

     C                   call      'QSNDDTAQ'
     C                   parm      'WRTTRAND2'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm      6             dqlen
     C                   parm      'READQ3'      dqdata

     C                   eval      *inlr = *on
