      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LL726S    Stage Export - LICLOG
     *  03 June 2011
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Export Status Codes
     *
     *    1 - Record exported
     *    2 - Skipped - TFR/RPL/PUT that was either for a USR slot
     *          or had a negative action quantity ('From' record).
     *    5-9 - Custom codes
     *
     *    Eastland custom codes
     *
     *    7 - Skipped because TFR/RPL/PUT missing the 'From' part.
     *          Note: the From part is always skipped with #2 above.
     *    8 - Skipped because TFR/RPL/PUT is within the same location
     *          (local, offsite) and the status code did not change.
     *    9 - Skipped due to logic in EastlandCheck routine.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    06/03/11  DAS
     *      - Created
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCaA*    06/03/11  DAS  EFCa
     *      - Revised to limit what is exported. They are only
     *        concerned with changes to offsite storage and inactive
     *        status codes.
     *
EFCbA*    06/29/11  RBD  EFCb
     *      - Added exception report to print license log record if
     *        the From/To portions cannot be matched.  This should
     *        rarely happen, if ever, but will be identified by
     *        export flag '7'.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fliclog3   uf   e           k disk
     Fliclog4   if   e           k disk    rename(llrec:llrec4) prefix(L4_)
     Fpirtran   if   e           k disk
EFCbAFwarehs    if   e           k disk
     Fexpsliclogo  a e           k disk    usropn
     Fexpsllcombo  a e           k disk    rename(lerec:lerecC) usropn
EFCbAFll726spr  o    e             printer oflind(*in90)
EFCbAF                                     usropn

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
EFCaA /COPY QCOPYSRC,ID#eastlan

     *----------------------------------------------------------------
640aA*  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     D $pWhse3A        s              3

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------

     D aisleType       s              7
     D batId           s             11
     D client          s             10
     D clientLoc       s             10
     D comboFile       s               n
     D comboPart       s              1  0
EFCbAD first           s               n
     D forever         s               n
     D fromAisleType   s              7
     D haveBatId       s               n
EFCbAD headLen         s              3  0 inz(0)
EFCbAD headPad         s              3  0 inz(0)
EFCbAD hmsmdy          s             12  0
     D okToExport      s               n
     D recAisle        s              3
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stampUC         s               z
     D toAisleType     s              7

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

EFCbAD blanks          s            100    inz(' ')
     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

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
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Loop through records that have not been exported yet.
     *  (the end of the loop is at the end of the mainline code)

      /free

         // Open appropriate export file.

         if client = eastland
            or client = 'BFC';
           comboFile = *on;
           open expsllcomb;
         else;
           comboFile = *off;
           open expsliclog;
         endif;

         // Loop through records that have not be exported.

         haveBatId = *off;
         setll ($pWhse: ' ') liclog3;

         dow forever = forever;

           reade ($pWhse: ' ') liclog3;

           if %eof(liclog3);
             leave;
           endif;

EFCaA      // When in 'combo' mode,
EFCaA      //   We only want to grab the 'To' portion of a TFR/RPL/PUT.
EFCaA
EFCaA      if comboFile;
             if (llAction='TFR' or llAction='RPL' or llAction='PUT');
                if llAisl = 'USR'
                   or llaqty1 < 0 or llaqty2 < 0 or llaqty3 < 0;
EFCaA                llexpflag = '2';
EFCaA                exsr UpdateLogRec;
EFCaA                iter;
EFCaA          endif;
EFCaA        endif;
EFCaA      endif;

EFCaA      // Limit what we export to Eastland.
EFCaA
EFCaA      if client = eastland;
EFCaA        exsr EastlandCheck;
EFCaA        if not okToExport;
EFCaA          llexpflag = '9';
EFCaA          exsr UpdateLogRec;
EFCaA          iter;
EFCaA        endif;
EFCaA      endif;

           // Get batch id if necessary.

           if not haveBatid;
             exsr zzzGetBatId;
             if batid = ' ';
               leave;
             endif;
             haveBatId = *on;
           endif;

           // Build export record

           // If working with combo file we call special routine
           //   for TFR/RPL/PUT to combine parts into single record.

           select;
             when comboFile
                  and (llAction='TFR' or llAction='RPL' or llAction='PUT');
                    exsr CombineRecs;
EFCaA               if not okToExport;
EFCaA                 iter;
EFCaA               endif;
             other;
               exsr FillExpRec;
           endsl;

           // Write export record.

           if comboFile;
             write lerecC;
           else;
             write lerec;
           endif;

           // Update LICLOG record.

           llexpflag = '1';
           exsr UpdateLogRec;

         enddo;

         if haveBatId;
           exsr zzzEnd;
         endif;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

         // Get client id

         getclient(client: clientLoc);

EFCbA    first = *on;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CombineRecs   Try to combine parts of TFR/RPL/PUT into one rec
     *----------------------------------------------------------------

      /free
       begsr CombineRecs;

         okToExport = *on;

EFCaA    fromAisleType = ' ';
EFCaA    toAisleType = ' ';

         // Initialize export record.

         exsr FillExpRec;

EFCaA    if client = eastland;
EFCaA      recAisle = llaisl;
EFCaA      exsr EastlandAisleType;
EFCaA      toAisleType = aisleType;
EFCaA    endif;

         // Get the corresponding From information.

         chain (llWhse: llFLTrn: llFLTrnSeq) liclog4;

         if %found(liclog4);
           exsr FillExpRecFrom;
ECFaA      if client = eastland;
EFCaA        recAisle = L4_llaisl;
ECFaA        exsr EastlandAisleType;
ECFaA        fromAisleType = aisleType;
ECFaA      endif;
         endif;

         // If Eastland, don't export if one of the following:
         //   1) We don't have both sides of the TFR/RPL/PUT
         //   2) The status and aisle type didn't change

EFCaA    if client = Eastland;
EFCaA      if (lefstat = ' ' or letstat = ' ');
EFCaA        llexpflag = '7';
EFCaA        exsr UpdateLogRec;
EFCbA        exsr printDetail;
             okToExport = *off;
EFCaA        leavesr;
           endif;
EFCaA      if lefstat = letstat and fromAisleType = toAisleType;
EFCaA        llexpflag = '8';
EFCaA        exsr UpdateLogRec;
             okToExport = *off;
EFCaA        leavesr;
           endif;
         endif;

       endsr;
      /end-free

EFCaA*----------------------------------------------------------------
EFCaA*  EastlandAisleType   Get aisle type for Eastland
EFCaA*----------------------------------------------------------------
EFCaA
EFCaA /free
EFCaA  begsr EastlandAisleType;

         aisleType = 'local';

         if recAisle = ' CB'
            or recAisle = ' CD'
            or recAisle = ' CF'
            or recAisle = ' CS';
              aisleType = 'offsite';
         endif;

       endsr;
      /end-free

EFCaA*----------------------------------------------------------------
EFCaA*  EastlandCheck   Select records to export for Eastland
EFCaA*----------------------------------------------------------------
EFCaA
EFCaA /free
EFCaA  begsr EastlandCheck;

         okToExport = *off;

         // Export status change record.

         if llAction = 'STS';
           okToExport = *on;
           leavesr;
         endif;

         // Export RCV records with non-Active status

         if llAction = 'RCV' and lltstat <> 'A';
           okToExport = *on;
           leavesr;
         endif;


         // Export transfer if item number wasn't changed.
         // When item is changed, it will be picked up in adjustment export.

         if llAction = 'TFR' and llIChg <> 'Y';
           okToExport = *on;
           leavesr;
         endif;

         // Export Putaway going into offsite storage slot.

         if llAction = 'PUT';
           recAisle = llaisl;
           exsr EastlandAisleType;
           if aisleType = 'offsite';
             okToExport = *on;
             leavesr;
           endif;
         endif;

         // Note, we don't export RPL because it won't involve different
         // status codes and it won't be in offsite storage.

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  EastlandRCV    Extra stuff to do for RCV for Eastland
     *----------------------------------------------------------------

      /free
       begsr EastlandRCV;

         lefdisp = 'C';

         chain (lltrn#) pirtran;
         if %found(pirtran);
           lecstm1 = ptrtpo;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillExpRec   Fill export record
     *----------------------------------------------------------------

      /free
       begsr FillExpRec;

         clear lerec;

         lewhse = llwhse;
         leltrn = llltrn;
         leaction = llaction;
         letrn# = lltrn#;
         leetrn# = lletrn#;
         lelbl# = lllbl#;
         lelcns = lllcns;
         levrfy = llvrfy;
         leflcns = llflcns;
         leaqty1 = llaqty1;
         leaqty2 = llaqty2;
         leaqty3 = llaqty3;
         lerqty1 = llrqty1;
         lerqty2 = llrqty2;
         lerqty3 = llrqty3;
         lesqty1 = llsqty1;
         lesqty2 = llsqty2;
         lesqty3 = llsqty3;
         learea = llarea;
         lecode = llcode;
         lewhdp = llwhdp;
         ledisp = lldisp;
         leaisl = llaisl;
         leloc  = llloc;
         lerlvl = llrlvl;
         lehand = llhand;
         letstat = lltstat;
         leostat = llostat;
         lebase = llbase;
         lepos  = llpos;
         leitem = llitem;
         leitype = llitype;
         leichg = llichg;
         lesitem = llsitem;
         lesitype = llsitype;
         leprty = llprty;
         leentd = llentd;
         leexpd = llexpd;
         leord  = llord;
         leseq = llseq;
         leexcd = llexcd;

         letaddts = lladdts;
         letadduc = lladduc;

         lecstm1 = ' ';
         lecstm2 = ' ';
         lecstm3 = ' ';

         lebatid = batId;
         lestatus = 'R';

         exsr zzzGetStamps;
         leststs = stamp;
         lestsuc = stampuc;
         leaddts = stamp;
         leadduc = stampuc;

         if llaction = 'STS';
           exsr FillExpRecSTS;
         endif;

         if client = eastland and llaction = 'RCV';
           exsr EastlandRCV;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillExpRecFrom   Fill export record From fields
     *----------------------------------------------------------------

      /free
       begsr FillExpRecFrom;

         lefwhdp = L4_llwhdp;
         lefdisp = L4_lldisp;
         lefaisl = L4_llaisl;
         lefloc  = L4_llloc;
         lefrlvl = L4_llrlvl;
         lefhand = L4_llhand;
         lefstat = L4_lltstat;
         lefbase = L4_llbase;
         lefitem = L4_llitem;
         lefitype = L4_llitype;
         lefsitem = L4_llsitem;
         lefsitype = L4_llsitype;
         lefaddts = L4_lladdts;
         lefadduc = L4_lladduc;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillExpRecSTS    Fill export record From fields for STS action
     *----------------------------------------------------------------

      /free
       begsr FillExpRecSTS;

         lefwhdp = llwhdp;
         lefdisp = lldisp;
         lefaisl = llaisl;
         lefloc  = llloc;
         lefrlvl = llrlvl;
         lefhand = llhand;
         lefstat = llostat;
         lefbase = llbase;
         lefitem = llitem;
         lefitype = llitype;
         lefsitem = llsitem;
         lefsitype = llsitype;
         lefaddts = lladdts;
         lefadduc = lladduc;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdateLogRec  Update LICLOG record
     *----------------------------------------------------------------

      /free
       begsr UpdateLogRec;

           exsr zzzGetStamps;

           llexpts = stamp;
           llexpuc = stampuc;
           llexpjusr = #user;
           llexpjob = #job;
           llexpnbr = #jobnbr;
           update llrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------

      /free
       begsr zzzGetBatId;

        monitor;
          if comboFile;
            GetBatId($pWhse: 'EXPLLCOMBO': 'W':
                     batId: rtnCode: rtnMessage);
          else;
            GetBatId($pWhse: 'EXPLICLOG': 'W':
                     batId: rtnCode: rtnMessage);
          endif;
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr;
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

       endsr;
      /end-free

EFCbA*----------------------------------------------------------------
EFCbA*  centerHead - Center characters in heading
EFCbA*----------------------------------------------------------------
EFCbA
      /free
       begsr centerHead;

         headLen = %len(%trim($desc));
         if headLen > 0
            and headLen < %size($desc);
              headPad = %int((%size($desc)-headLen)/2);
              rptttl = %subst(blanks:1:headPad)
                     + %trim($desc);
         endif;

       endsr;
      /end-free

EFCbA*----------------------------------------------------------------
EFCbA*  printhead - Print heading line
EFCbA*----------------------------------------------------------------
EFCbA
      /free

       begsr printhead;

        // Print report heading
         write head1;

        // Print columns
         write columns;

       endsr;

      /end-free

EFCbA*----------------------------------------------------------------
EFCbA*  printDetail - Print detail line
EFCbA*----------------------------------------------------------------
EFCbA
      /free

       begsr printDetail;

         // See if heading needs to be printed.

             if first;
               exsr setupPrint;
               exsr printHead;
               first = *off;
             endif;

             if *in90;
               exsr printHead;
             endif;


        // Print detail line

         write detail1;

       endsr;

      /end-free

EFCbA*----------------------------------------------------------------
EFCbA*  setupPrint - Setup Report
EFCbA*----------------------------------------------------------------
EFCbA
     C     setupPrint    begsr
      /free

         //  Get warehouse description.

         chain ($pWhse) warehs;
           if %found(warehs);
         headLen = %len(%trim(whdesc));
         if headLen > 0
            and headLen < %size(whdesc);
              headPad = %int((%size(whdesc)-headLen)/2);
                whse = %subst(blanks:1:headPad)
                     + %trim(whdesc);
         endif;
           endif;
      /end-free

         // Get device and form type.

     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'LL726SPR'    $lrpt            10
     C                   parm      $pwhse        $whse             3 0
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10

         // Get time.

     C                   time                    hmsmdy
     C                   movel     hmsmdy        rtime
     C                   move      hmsmdy        rdate

      /free

         // Load desc, device and form.

         if $desc = ' ';
           $desc = 'Stage Export License Log Exception Report';
         endif;

           exsr centerHead;

         if $dev = ' ';
           $dev = '*JOB';
         endif;

         if $form = ' ';
           $form = '*STD';
         endif;

           qcmd = 'OVRPRTF '
                + 'FILE(LL726SPR) '
                + 'OUTQ(*DEV) '
                + 'DEV(' + %trim($dev) + ') '
                + 'FORMTYPE(' + %trim($form) + ') ';

      /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
      /free

         // Open printer file.

            open(e) ll726spr;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

      /free
       begsr zzzEnd;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

EFCbA    // Close printer file if open.
EFCbA
EFCbA    if client = eastland;
EFCbA     write foot1;
EFCbA    close(e)   ll726spr;
EFCbA    if %error;
EFCbA    endif;
EFCbA    endif;

       endsr;
      /end-free
