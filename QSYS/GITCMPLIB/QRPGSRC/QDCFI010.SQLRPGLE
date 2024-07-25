      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDCFI010     Create adj for pick from overflow
     *  17 May 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    05/17/18  RTR  7.20
     *      - Created.
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
     *----------------------------------------------------------------
     * File Specs
     Fslot      if   e           k disk
     Fimpspckq  uf a e           k disk

     *----------------------------------------------------------------
     *  Program info data structure
      /copy *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy *libl/qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Parameters
     *    Input Parameters
     *      none
     *    Returned Parameters
     *      none
     *----------------------------------------------------------------
     D main            pr                  extpgm('QDCFI010')

     D main            pi

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Working variables
     d batId           s             11    inz(' ')
     d ovrq1           s              7s 0 inz(0)
     d ovrq2           s              7s 0 inz(0)
     d ovrq3           s              7s 0 inz(0)
     d rtnCode         s             10
     d rtnMessage      s            200

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Read slot records
        dow forever = forever;
          read slrec;
          if %eof(slot);
            leave;
          endif;

          if slitem = *blanks;
            iter;
          endif;
          if slpick <> 'Y';
            iter;
          endif;

          // Get overflow count for item
          exec sql select sum(slstk1),sum(slstk2),sum(slstk3)
                     into :ovrq1,:ovrq2,:ovrq3
                     from slot
                    where slitem = :slitem
                      and slpick <> 'Y'
                      and slaisl <> 'RCV';
          if sqlstt <> sqlSuccess;
            iter;
          endif;

          ipqwhs = slwhse;
          ipqitm = slitem;
          ipqstatus = 'R';
          ipqtext = *blanks;
          ipqwhd = slwhdp;
          ipqdsp = sldisp;
          ipqqp1 = ovrq1;
          ipqqp2 = ovrq2;
          ipqqp3 = ovrq3;
          ipqadj = 'DK';
          ipqsof = 'N';
          ipqmem = 'Startup Overflow Deduct';

          if batid = *blanks;
            monitor;
              GetBatId(1: 'IMPPCKDEM': 'W':
                       batId: rtnCode: rtnMessage);
            on-error;
              clear batId;
              clear rtnCode;
              clear rtnMessage;
            endmon;
            ipqbatid = batid;
          endif;

          write ipqrec;

        enddo;

        if batid <> *blanks;
          exec sql
            update stgbatch
            set sbstatus = 'R',
                sbtext   = ' ',
                sbststs  = current_timestamp,
                sbstsuc  = current_timestamp - current_timezone
            where sbwhse = 1
              and sbbatid = :batId;
        endif;

        *inlr = *on;
      /end-free
