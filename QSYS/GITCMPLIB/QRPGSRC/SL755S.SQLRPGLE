      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  SL755S    Stage Export - Slot Status
     *  November 10, 2020
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740  *    11/10/20  RTR  7.40
     *      - Created. Originally for Chef's Warehouse.
     *
     *----------------------------------------------------------------
     * File Specs
     fliclog3   uf   e           k disk
     fexpsssts  o  a e           k disk

     *----------------------------------------------------------------
     *  Data Formats
     d llrecx        e ds                  extname(liclog) inz(*EXTDFT)
     d                                     prefix(x)

     *----------------------------------------------------------------
     *  Customer id
     d client          s             10a
     d clientloc       s             10a
      /copy qcopysrc,id#dairyla

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
     *  Working variables
     d batId           s             11
     d clear           s              5  0
     d cnterr          s              9s 0
     d cntexp          s              9s 0
     d cntskp          s              9s 0
     d exportdte       s              8s 0
     d exporttim       s              6s 0
     d haveBatId       s               n
     d hrtn            s              8
     d iWhse           s              3  0
     d maxseq          s                   like(llltrnseq)
     d nostamp         s               z
     d logMessage      s           1024a
     d rtnMessage      s            200a
     d rtnCode         s             10a
     d stamp           s               z
     d stampUC         s               z
     d wrkqty1         s                   like(llrqty1)
     d wrkqty2         s                   like(llrqty2)
     d wrkqty3         s                   like(llrqty3)

     *----------------------------------------------------------------
     *  Called Program Prototypes
     d$CVTDT           DS
     d $cvcmd                  1      8
     d $cvprg                  9     18
     d $cvd6i                 19     24
     d $cvd8i                 25     32
     d $cvd6o                 33     38  0
     d $cvd8o                 39     46  0
     d $cvsto                 47     64
     d $cvrtn                 65     72
     d $cverm                 73    132
     d $cvmsg                 73     76
     *
     d CvtDte          pr                  extpgm('CVTDTE')
     d  $CVTDT                      132a

     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   pWhse                        3p 0 const
     d   pType                       10    const
     d   pStatus                      1    const
      * Output
     d   pBatId                      11
     d   pReturn                     10
     d   pMessage                   200

     d WrtLog          pr                  extpgm('WRTLOGRTE')
     d                               10    const
     d                               10    const
     d                             1024    const
     d                                3    const
     d                                5    const

     d GetClient       pr                  extpgm('GETCLIENT')
     d* Output
     d   Client                      10
     d   ClientLoc                   10
     *
     d DryExportPgm    pr                  extpgm('BFCSLI01C')
     d* Input
     d   $hWhsea                      3    const
     d   $hbatid                     11
     d   $hflib                      10
     d* Output
     d   $hrtn                        8

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------
      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('SL755S')
      * Input
     d   iWhsea                       3    const

     d main            pi
      * Input
     d   iWhsea                       3a   const

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        setll (iwhse: *blank: nostamp) liclog3;
        dou forever <> forever;
          reade (iwhse: *blank) liclog3;

          if %eof(liclog3);
            leave;
          endif;

          select;
            when llaction = 'STS';
              exsr zzWriteSTS;
            when llaction = 'TFR'
             or llaction = 'RPL';
              exsr zzWriteTFR;
            other;
              llexpflag = 'X';
              cntskp = cntskp + 1;
          endsl;

          exsr zzzGetStamps;
          llexpts = stamp;
          llexpuc = stampuc;
          llexpjusr = #user;
          llexpjob = #job;
          llexpnbr = #jobn;
          update llrec;

        enddo;

        logMessage = 'End of Slot Status Export. '
                   + %trimr(%char(cntexp)) + ' exported, '
                   + %trimr(%char(cntskp)) + ' skipped. ';
        WrtLog(#pgm: '*INFO': logMessage: iWhsea: ' ');
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

          iWhse = %dec(iWhsea: 3: 0);
          WrtLog(#pgm: '*INFO': 'Running Slot Status Export.': iWhsea: ' ');

          GetClient(Client: ClientLoc);

          exportdte = %int(%char(%date(): *iso0));
          exporttim = %int(%char(%time(): *hms0));
          haveBatId = *off;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------
      /free
        begsr *pssr;

          // Attempt to log, may not work.
          monitor;
            WrtLog(#pgm: '*ERROR': 'Abnormal end: *PSSR.': iWhsea: ' ');
          on-error;
          endmon;

          // Make sure we don't get caught in an infinite loop
          if pssrflag;
            *inlr = *on;
            return;
          endif;

          pssrflag = *on;
          *inlr = *on;
          return;

        endsr;   // *pssr
      /end-free

     *----------------------------------------------------------------
     *  zzWriteSTS   Write record for status change
     *----------------------------------------------------------------
      /free
        begsr zzWriteSTS;

          // do not write when from and to status are not A
          if llostat <> 'A' and lltstat <> 'A';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // do not write when from OR to status are RP
          if llostat = 'RP' or lltstat = 'RP';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // do not write when from OR to status are DP
          if llostat = 'DP' or lltstat = 'DP';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          if llltrnseq = 1;

            // get count total for all tran seq records
            exec sql select sum(llrqty1),sum(llrqty2),sum(llrqty3)
                       into :wrkqty1, :wrkqty2, :wrkqty3
                       from liclog
                      where llwhse = :llwhse
                        and llltrn = :llltrn
                        and llaction = :llaction
                        and llitem = :llitem
                        and lldisp = :lldisp;
            if sqlstt <> sqlsuccess;
              wrkqty1 = 0;
              wrkqty2 = 0;
              wrkqty3 = 0;
            endif;

            stswhse   = iwhse;
            stsstatus = 'R';
            exsr zzzGetStamps;
            stsststs  = stamp;
            stsstsuc  = stampuc;
            ststext   = *blanks;

            ststrn    = lltrn#;
            stslltrn  = llltrn;
            stsaction = llaction;
            stsitem   = llitem;
            stsfdisp  = lldisp;
            stsfsts   = llostat;
            ststdisp  = lldisp;
            stststs   = lltstat;
            stsfqty1  = wrkqty1;
            stsfqty2  = wrkqty2;
            stsfqty3  = wrkqty3;
            ststqty1  = wrkqty1;
            ststqty2  = wrkqty2;
            ststqty3  = wrkqty3;
            exsr zzzGetStamps;
            stsaddts  = stamp;
            stsadduc  = stampuc;

            // NOTE: This is intentionally getting NEW batchID for every
            //       record. Explicitly requested by Chef's Warehouse.
            exsr zzzGetBatId;

            stsbatid  = batid;
            write stsrec;
            llexpflag = 'S';
            cntexp = cntexp + 1;
            exsr zzzClose;

            // Only run Chef's call for Chef's, in case this is
            // ever used elsewhere.
            if client = Dairyland;
              callp(e) DryExportPgm(iwhsea:batid:f1library:hrtn);
            endif;

          else;       // when llltrnseq <> 1, skip record
            llexpflag = 'X';
            cntskp = cntskp + 1;
          endif;

        endsr; // zzWriteSTS
      /end-free

     *----------------------------------------------------------------
     *  zzWriteTFR   Write record for transfer
     *----------------------------------------------------------------
      /free
        begsr zzWriteTFR;

          // skip if first part of transfer, will write after test
          if (llfltrn = 0 and llfltrnseq = 0)
           or (llcode = 'U');
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // if here, we have 'put' part of transfer/replen
          // so check if last trans seq record, skip if not
          exec sql select max(llltrnseq) into :maxseq from liclog
                    where llwhse = :llwhse
                      and llltrn = :llltrn
                      and llaction = :llaction
                      and lladdnbr = :lladdnbr;
          if sqlstt = sqlsuccess
           and llltrnseq < maxseq;
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // if here, we have 'put' part of transfer/replen
          // so link back to first part of liclog trans
          exec sql select * into :llrecx from liclog
                    where llwhse = :llwhse
                      and llltrn = :llfltrn
                      and llltrnseq = :llfltrnseq
                      and llaction = :llaction
                      and lladdnbr = :lladdnbr;
          if sqlstt <> sqlsuccess;
            llexpflag = 'E';
            cnterr = cnterr + 1;
            leavesr;
          endif;

          stswhse   = iwhse;
          stsstatus = 'R';
          stsststs  = stamp;
          stsstsuc  = stampuc;
          ststext   = *blanks;

          ststrn    = lltrn#;
          stslltrn  = llltrn;
          stsaction = llaction;
          stsitem   = llitem;
          stsfdisp  = xlldisp;
          stsfsts   = xlltstat;
          ststdisp  = lldisp;
          stststs   = lltstat;
          stsfqty1  = llrqty1;
          stsfqty2  = llrqty2;
          stsfqty3  = llrqty3;
          ststqty1  = llrqty1;
          ststqty2  = llrqty2;
          ststqty3  = llrqty3;
          exsr zzzGetStamps;
          stsaddts  = stamp;
          stsadduc  = stampuc;

          // do not write when from/to status same
          if stsfsts = stststs
           and %subst(stsfdisp:1:3) <> 'OSS'
           and %subst(ststdisp:1:3) <> 'OSS';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // do not write any XDK slot movement
          if %subst(stsfdisp:1:3) = 'XDK'
           or %subst(ststdisp:1:3) = 'XDK';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // do not write when from and to status are not A
          if stsfsts <> 'A' and stststs <> 'A';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // do not write when from OR to status are RP
          if stsfsts = 'RP' or stststs = 'RP';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // do not write when from OR to status are DP
          if stsfsts = 'DP' or stststs = 'DP';
            llexpflag = 'X';
            cntskp = cntskp + 1;
            leavesr;
          endif;

          // NOTE: This is intentionally getting NEW batchID for every
          //       record. Explicitly requested by Chef's Warehouse.
          exsr zzzGetBatId;

          stsbatid  = batid;
          write stsrec;
          cntexp = cntexp + 1;
          llexpflag = 'S';
          exsr zzzClose;

          // Only run Chef's call for Chef's, in case this is
          // ever used elsewhere.
          if client = Dairyland;
            callp(e) DryExportPgm(iwhsea:batid:f1library:hrtn);
          endif;

        endsr; // zzWriteTFR
      /end-free

     *----------------------------------------------------------------
     *  zzzClose   End processing
     *----------------------------------------------------------------
      /free
       begsr zzzClose;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :iWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

       endsr; // zzzClose
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;
        monitor;
          GetBatId(iWhse: 'EXPSLTSTS': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

        exsr zzzGetStamps;

       endsr; // zzzGetBatId
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
       begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

       endsr; // zzzGetStamps
      /end-free
