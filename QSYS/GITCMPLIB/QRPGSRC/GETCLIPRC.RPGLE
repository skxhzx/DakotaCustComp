417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETCLIPRC    Get client - Pgem for GETCLIENT proc
     *  27 January 2007
     *  Dave Sommerville
     *
     *  Revisions:
     *
510 A*    01/27/06  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

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
     *      none
     *
     *    Returned Parameters
     *      $pclientid    Client id
     *      $plocationid  Client location
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
417cAC                   parm                    $pclientid       10
500 AC                   parm                    $plocationid     10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   Call(e)   'GETCLIENT'
     C                   Parm      ' '           $pclientid
     C                   Parm      ' '           $plocationid

     C                   eval      *inlr = *on
