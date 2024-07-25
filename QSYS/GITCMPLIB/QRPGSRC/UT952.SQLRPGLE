      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  UT952    Find files with records
     *  25 June 2014
     *  Rod Roller
     *
     *  Revisions
     *
650a *    06/25/14  RTR  6.50a
     *      - Created.
     *----------------------------------------------------------------
      /free

        exec sql delete from ut952f
                  where MLNRCD = 0;

        *inlr = *on;
      /end-free
