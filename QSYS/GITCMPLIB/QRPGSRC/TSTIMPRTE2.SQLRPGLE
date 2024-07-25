      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTIMPRTE2   Test DKTIMPORT
     *  12 February 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oihrec        E ds                  extname(impsordh) inz(*EXTDFT)
     D oidrec        E ds                  extname(impsordd) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  batId          s             11
     D  rtnCode        s             10
     D  rtnMessage     s            200
     D  uStatus        s              1
     D  uType          s             10
     D  whse3S         s              3s 0

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D dktimport       pr                  extpgm('DKTIMPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
     D   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     * Input parameters
     *----------------------------------------------------------------

     D $pWhse15        S             15p 5
     D $pWhse3         S              3p 0
     D $pType          S             10
     D $pBatId         S             11
     D $pRunType       S              1

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  pReturn        s             10
     D  pMessage       s            200

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         exsr GetBatchId;
         exsr WriteOrdH1;
         exsr WriteOrdD1;
         exsr DoImport;

         return;
      /end-free

     *----------------------------------------------------------------
     *  DoImport     Call DktImport
     *----------------------------------------------------------------

      /free
       begsr DoImport;

         DktImport(900: 'IMPROUTE': batId: 'I':
                   'TSTIMPRTE': rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetBatchId   Get batch id
     *----------------------------------------------------------------

      /free
       begsr GetBatchId;

         GetBatId(900: 'IMPROUTE': 'R':
                  batId: rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteOrdH    Write Order Header record
     *----------------------------------------------------------------

      /free
       begsr WriteOrdH;

         exec sql insert into impsordh
                  (oihwhs, oihbatid, oihrteid, oihordid,
                   oihstatus, oihststs, oihstsuc, oihtext,
                   oihord, oihtyp, oihcus, oihcpo, oihcnm,
                   oihca1, oihca2, oihcct, oihcst, oihczp,
                   oihrte, oihstp, oihtrk, oihmsc, ohmms1,
                   ohmms2, ohmms3, ohmms4, ohmms5,
                   oihaddts, oihadduc)
                  values(:oihwhs, :oihbatid, :oihrteid, :oihordid, :oihstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :oihtext, :oihord, :oihtyp, :oihcus, :oihcpo, :oihcnm,
                         :oihca1, :oihca2, :oihcct, :oihcst, :oihczp, :oihrte,
                         :oihstp, :oihtrk, :oihmsc, :ohmms1, :ohmms2, :ohmms3,
                         :ohmms4, :ohmms5,
                         current_timestamp,
                         current_timestamp - current_timezone);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'ORDH error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteOrdH1   Write ORDH record
     *----------------------------------------------------------------

      /free
       begsr WriteOrdH1;

         clear oihrec;

         oihwhs = 900;
         oihbatid = batId;
         oihstatus = 'R';
         oihcus = 1111111;
         oihord = 1234;
         oihtyp = 'S';
         oihrte = 'RTE1';
         oihstp = 1;
         oihtrk = 'TRUCK900';

         exsr WriteOrdH;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteOrdD    Write Order Detail record
     *----------------------------------------------------------------

      /free
       begsr WriteOrdD;

         exec sql insert into impsordd
                  (oidwhs, oidbatid, oidordid,
                   oidstatus, oidststs, oidstsuc, oidtext,
                   oidord, oidseq, oiditm, oidq1, oidq2, oidq3,
                   oidwh2, oidor2, oidoit, oidspc, oidpo,
                   oimdsc, oimpds, oimrds, oimbox, oimexp,
                   oimms1, oimms2, oimms3, oimms4, oimms5,
                   oidaddts, oidadduc)
                  values(:oidwhs, :oidbatid, :oidordid, :oidstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :oidtext, :oidord, :oidseq, :oiditm,
                         :oidq1, :oidq2, :oidq3,
                         :oidwh2, :oidor2, :oidoit, :oidspc, :oidpo, :oimdsc,
                         :oimpds, :oimrds, :oimbox, :oimexp, :oimms1, :oimms2,
                         :oimms3, :oimms4, :oimms5,
                         current_timestamp,
                         current_timestamp - current_timezone);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'ORDD error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteOrdD1   Write ORDD record
     *----------------------------------------------------------------

      /free
       begsr WriteOrdD1;

         clear oidrec;

         oidwhs = 900;
         oidbatid = batId;
         oidstatus = 'R';
         oidord = 1234;
         oidseq = 1;
         oiditm = 'DA102';
         oidq1 = 18;

         exsr WriteOrdD;

         oidseq = 2;
         oiditm = 'DA104';
         oidq1 = 38;
         exsr WriteOrdD;

       endsr;
      /end-free
