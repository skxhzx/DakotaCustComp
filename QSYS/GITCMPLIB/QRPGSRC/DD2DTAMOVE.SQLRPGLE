      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DD2DTAMOVE - Move data in DDTASK and DDDETAIL to History files
     *               and reply with route id location when requested
     *  22 July 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
     *    07/22/20  KDE  7.40
     *      - Created.
     *
     *=================================================================*

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

412 AFrtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *  iCmd      - *MTODDDH, *MTODDTH, *DTALOCDDD, *DTALOCDDT
     *  iRtnCode
     *  iRtnMsg
     *  iddwhse  - Warehouse
     *  iddrtid  - Route Id
     *
     *----------------------------------------------------------------

     d dd2dtamove      pr                  extpgm('DD2DTAMOVE')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iddwhse                       3p 0 const
     d  iddrtid                       5    const

     d dd2dtamove      pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iddwhse                       3p 0 const
     d  iddrtid                       5    const

     D Num             S              5P 0 inz(0)
     D lastRtid        S              5    inz('     ')

     *-----------------------------------------------------------------*
     * Mainline                                                        *
     *-----------------------------------------------------------------*
     c*                  eval      *inlr=*on
      /free
            if lastRtid <> iddrtid;
              chain (iddwhse:iddrtid) rtehed;
              if not %found(rtehed);
                rhstat = ' ';
              endif;
              lastRtid = iddrtid;
            endif;

            iRtnCode=*blanks;
            select;
              when iCmd = '*MTODDDH';        // Move DDDETAIL to DDDETAILH
                exec sql insert into dddetailh
                     select * from dddetail
                       where dddwhse=:iddwhse and dddrtid=:iddrtid;
                if sqlstt = '00000';
                  // if insert was successful then purge from live
                  exec sql delete from dddetail
                       where dddwhse=:iddwhse and dddrtid=:iddrtid;
                endif;
                return;
              when iCmd = '*MTODDTH';        // Move DDTASK to DDTASKH
                exec sql insert into ddtaskh
                     select * from ddtask
                       where ddtwhse=:iddwhse and ddtrtid=:iddrtid;
                if sqlstt = '00000';
                  // if insert was successful then purge from live
                  exec sql delete from ddtask
                       where ddtwhse=:iddwhse and ddtrtid=:iddrtid;
                endif;
                return;
              when iCmd = '*DTALOCDDD';      // Return current Data Location DDDETAIL
                if rhstat < '4';
                  iRtnCode='LIVE';
                else;
                  iRtnCode='HISTORY';
                endif;
                return;
              when iCmd = '*DTALOCDDT';      // Return current Data Location DDTASK
                if rhstat < '4';
                  iRtnCode='LIVE';
                else;
                  iRtnCode='HISTORY';
                endif;
                return;
            endsl;
      /end-free
