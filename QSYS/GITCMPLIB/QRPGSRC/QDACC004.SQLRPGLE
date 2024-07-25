      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDACC004     Create adj for pick from overflow
     *  November 12, 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
ACC  *    11/12/18  RTR  ACC
     *      - Created.
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
     *----------------------------------------------------------------
     * File Specs
     fslot2     if   e           k disk
     fimpspckq  uf a e           k disk
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
     *----------------------------------------------------------------
     d main            pr                  extpgm('QDACC004')
     d main            pi
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   pWhse                        3p 0 const
     d   pType                       10    const
     d   pStatus                      1    const
      * Output
     d   pBatId                      11
     d   pReturn                     10
     d   pMessage                   200

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
          if %eof(slot2);
            leave;
          endif;

          if slitem = *blanks;
            iter;
          endif;
          if slpick = 'Y';
            iter;
          endif;
          if slaisl = 'RCV';
            iter;
          endif;

          ipqwhs = slwhse;
          ipqitm = slitem;
          ipqstatus = 'R';
          ipqtext = *blanks;
          ipqwhd = *blanks;
          ipqdsp = *blanks;
          ipqqp1 = slstk1;
          ipqqp2 = slstk2;
          ipqqp3 = slstk3;
          ipqadj = 'DK';
          ipqsof = 'N';
          ipqmem = 'Startup Overflow - ' + sldisp;

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
