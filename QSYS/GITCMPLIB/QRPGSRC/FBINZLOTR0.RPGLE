      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     * Copyright (C) 2022 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FBINZLOTR  FreshByte Initialize Host Lots
     *  30 November 2022
     *  Dave Sommerville
     *
     *  Revisions
     *
760 A*    11/30/22  DAS  7.60
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *  This is hardcode to read CSV file ...
     *
     *      /BFC/FreshByte/fb_host_lots.csv
     *
     *  The data will be extracted and put into IMPSHSTLOT.
     *  Then we will do the actual import to update the Host Lots.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CSV Assumptions:
     *
     *   - Line feed ends a line.
     *   - Carriage return character will be ignored.
     *   - Alpha fields with an embedded comma must be surrounded
     *     by single quotes.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     fimpshstlotuf a e           k disk
     flicactive2if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#LICINFO
     D saveVer#        s                   like($liver#)
     D drilicense      s               n   inz(*off)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /Copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Comma Separated Variables
     *----------------------------------------------------------------

     d dsplyMsg        s             52
     d fieldsExpected  s              3  0

     *----------------------------------------------------------------
     *  IFS Variables
     *----------------------------------------------------------------

     d gDir            s           1024    varying
     d gOrigFile       s            100    varying
     d gOrigPath       s           1024    varying
     d gRenamedFile    s            100    varying
     d gRenamedPath    s           1024    varying
     d ifd             S             10I 0
     d iflags          S             10U 0
     d rddata          S           3072
     d chkIFSPath      s            640
     d chkIFSAuth      s             10

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     d gBatId          s             11
     d gBatIdType      s             10
     d gLine           s              5  0
     d gWhse           s              3  0
     d gCount          s              5  0

     d chk4err         s               n
     d zmflag          s               n
     d zmsflag         s               n
     d doAddLicInfo    s               n

     *----------------------------------------------------------------
     *  GETFLDS parameters
     *----------------------------------------------------------------

     d gfString        s          65535A   varying
     d gfDelimiter     s              1A
     d gfStartFld      s              3  0
     d gfRtnCode       s             10
     d gfFldsReturned  s              3  0
     d gfFld1          s          65535A   varying
     d gfFld2          s          65535A   varying
     d gfFld3          s          65535A   varying
     d gfFld4          s          65535A   varying
     d gfFld5          s          65535A   varying
     d gfFld6          s          65535A   varying
     d gfFld7          s          65535A   varying
     d gfFld8          s          65535A   varying
     d gfFld9          s          65535A   varying
     d gfFld10         s          65535A   varying
     d gfFld11         s          65535A   varying
     d gfFld12         s          65535A   varying
     d gfFld13         s          65535A   varying
     d gfFld14         s          65535A   varying
     d gfFld15         s          65535A   varying
     d gfFld16         s          65535A   varying
     d gfFld17         s          65535A   varying
     d gfFld18         s          65535A   varying
     d gfFld19         s          65535A   varying
     d gfFld20         s          65535A   varying

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,c#ifsio_h
      /copy qcopysrc,errno_h

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.chkifsob
      /copy qcopysrc,p.getbatid
      /copy qcopysrc,p.getflds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ProcessFile     pr

     d ProcessRec      pr

     d CSVSplit        pr

     d UpdActiveLcns   pr

     d zzzDriCop       pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *  Input
     *
     *    $pcmd  - Must be *UPDATE
     *
     *  Output
     *
     *    none
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             7

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

       *inlr = *on;

       // No accidents

       if %parms < 1 or $pcmd <> '*UPDATE';
         dsply 'Invalid Command';
         return;
       endif;

       // Initialization

       exsr zzinz2;
       gWhse = e$whse;

       gDir = '/BFC/FreshByte/';

       gOrigFile = 'fb_host_lots.csv';
       gOrigPath = gDir + gOrigFile;

       gRenamedFile = gOrigFile + '_' + %char(%timestamp(*sys));
       gRenamedPath = gDir + gRenamedFile;

       // Make sure file exists

       monitor;
         chkIFSPath = gOrigPath;
         chkifsobj (chkIFSPath: chkIFSAuth);
       on-error;
         dsplyMsg = 'File Not Found';
         dsply dsplyMsg;
         dsplyMsg = gDir;
         dsply dsplyMsg;
         dsplyMsg = gOrigFile;
         dsply dsplyMsg;
         return;
       endmon;

       // Rename file so we don't accidentally reprocess it

       if rename(gOrigPath: gRenamedPath) < 0;
         dsplyMsg = 'Error renaming IFS file';
         dsply dsplyMsg;
         dsplyMsg = gDir;
         dsply dsplyMsg;
         dsplyMsg = gRenamedFile;
         dsply dsplyMsg;
         return;
       endif;

       // Open renamed file

       iflags = o_rdonly + o_textdata;
       ifd = open(gRenamedPath:iflags);
       if ifd < 0;
         dsplyMsg = 'Error opening file';
         dsply dsplyMsg;
         dsplyMsg = gDir;
         dsply dsplyMsg;
         dsplyMsg = gRenamedFile;
         dsply dsplyMsg;
         return;
       endif;

       // Apply Host Lot codes to items

       gBatIdType = 'IMPHSTLOT';
       processFile();

       // Close CSV file

       callp close(ifd);

       // Bye, Bye

       return;

     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     C     ZZINZ2        BEGSR

     *   Get employee options.

     C                   call      'GETUSER'
     C                   parm      #curruser     e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2

     C                   ENDSR

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Subprocedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ProcessFile    Process file
     *----------------------------------------------------------------

     p ProcessFile     b
     d ProcessFile     pi

     * Local Variables

     D rtnCode         s             10
     D rtnMessage      s            200

       // Get Staging batch id to use

       if gBatIdType <> '';
         monitor;
           GetBatId(gWhse: gBatIdType: 'S':  gBatId: rtnCode: rtnMessage);
         on-error;
           dsplyMsg = 'Error calling GetBatId';
           dsply dsplyMsg;
           return;
         endmon;
         if rtnCode <> '*OK';
           dsplyMsg = 'BatIdErr ' + %trim(rtnCode) + ' ' + %trim(rtnMessage);
           dsply dsplyMsg;
           return;
         endif;
       endif;

       // Read through file line by line

       gLine = 0;

       dow readline(ifd: %addr(rddata):%size(rddata))>=0;

         gLine += 1;

         // Skip heading lines

         if gLine < 6;
           iter;
         endif;

         ProcessRec();

       enddo;

     p                 e

     *----------------------------------------------------------------
     *  ProcessRec  Process CSV record
     *----------------------------------------------------------------

     p ProcessRec      b
     d ProcessRec      pi

       // We only need fields 1 and 8, even though there are more in the file

       fieldsExpected = 8;

       clear ihlrec;
       ihlwhse = gWhse;
       ihlbatid = gBatId;
       ihlstatus = 'R';
       ihlststs = %timestamp(*sys);
       ihlstsuc = ihlststs;
       ihltext = '';
       ihlline = gLine;

       gfString = %trim(rddata);
       gfDelimiter = ',';
       gfStartFld = 1;

       CSVSplit();

       if gfFldsReturned = 0;
         If %subst(gfRtnCode: 1: 4) = '*ERR';
           ihltext = 'Error getting field: ' + %trim(gfRtnCode);
         else;
           ihltext = 'No fields found: ' + %trim(gfRtnCode);
         endif;
         ihlstatus = 'E';
         ihladdts = %timestamp(*sys);
         ihladduc = ihlststs;
         write ihlrec;
         return;
       endif;

       // Move extracted field values into import file fields

       If gfFldsReturned >= 1;    // Item number
         ihlitem = gfFld1;
       endif;

       if gfFldsReturned >= 8;    // Host Lot code
         ihlhostlot = gfFld8;
       endif;

       // Capture extraction error if we didn't extract needed fields
       // We do this at the end in order to extract as much as we can

       if gfFldsReturned < fieldsExpected;
         ihltext = 'Error (' +  %trim(gfRtnCode) + '):'
                 + 'Extracted ' + %char(gfFldsReturned) + ' fields, '
                 + 'expected ' + %char(fieldsExpected) + ' fields';
         ihlstatus = 'E';
         ihladdts = %timestamp(*sys);
         ihladduc = ihlststs;
         write ihlrec;
         return;
       endif;

       // Error if item is blank

       if ihlitem = '';
         ihltext = 'Item was blank';
         ihlstatus = 'E';
         ihladdts = %timestamp(*sys);
         ihladduc = ihlststs;
         write ihlrec;
         return;
       endif;

       // Error if host lot is blank

       if ihlhostlot = '';
         ihltext = 'Host Lot was blank';
         ihlstatus = 'E';
         ihladdts = %timestamp(*sys);
         ihladduc = ihlststs;
         write ihlrec;
         return;
       endif;

       // Update Active licenses for item

       UpdActiveLcns();

     p                 e

     *----------------------------------------------------------------
     *  CSVSplit   Split CSV record into fields.
     *----------------------------------------------------------------

     p CSVSplit        b
     d CSVSplit        pi

       // This will return 20 fields at a time.
       // If record contains more than 20 fields, you will need to
       // call this routine a second time with gfStartFld = 21.

       GetFlds(gfString: gfDelimiter: gfStartFld: gfRtnCode: gfFldsReturned:
               gfFld1: gfFld2: gfFld3: gfFld4: gfFld5:
               gfFld6: gfFld7: gfFld8: gfFld9: gfFld10:
               gfFld11: gfFld12: gfFld13: gfFld14: gfFld15:
               gfFld16: gfFld17: gfFld18: gfFld19: gfFld20);

     p                 e

     *----------------------------------------------------------------
     *  UpdActiveLcns  Update Active licenses for item
     *----------------------------------------------------------------

     p UpdActiveLcns   b
     d UpdActiveLcns   pi

     * Local Variables

     D count           s              5  0

       error = *off;
       count = 0;

       // Loop through LICACTIVE for item

       setll (gWhse: ihlitem) licactive2;

       dow forever = forever;

         reade (gWhse: ihlitem) licactive2;
         if %eof(licactive2);
           leave;
         endif;

         count += 1;
         ihllcns = lalcns;
         ihlolcns = laolcns;

         // Skip *NG licenses

         if %subst(lalcns: 1: 3) = '*NG';
           ihlstatus = 'I';
           ihltext = 'Negative license skipped';
           ihlststs = %timestamp(*sys);
           ihlstsuc = ihlststs;
           ihladdts = %timestamp(*sys);
           ihladduc = ihlststs;
           write ihlrec;
           iter;
         endif;

         // Get LICINFO record

         savever# = $lnver#;
         clear $licinfo;
         clear $licinfo2;
         $lnver# = savever#;

         $lnuser = #user;
         $lnemp# = e$emp#;
         $lnpgm  = #prog;
         $lnjob  = #job;
         $lnjobnbr = #jobn;

         $lnwhse  = lawhse;
         $lnlcns  = laolcns;
         $lnseq   = 1;
         $dricommand = '*LICINFO';
         $drisubcmd  = '%GET';
         $drisys2upd = 'D';
         chk4err = *off;
         zzzdricop();
         if $drireturn = '*OK';
           doAddLicinfo = *off;
           ihllicinfo = 'U';
         else;
           doAddLicinfo = *on;
           ihllicinfo = 'A';
         endif;

         // Log lot update

         $liActionU = *on;
         $liAction  = 'LOT';
         $liToItemU = *on;
         $litoItem  = ihlitem;
         $liToCodeu = *on;
         $litoCode  = lacode;
         $liToAreaU = *on;
         $litoArea  = laarea;
         $liToWhdpU = *on;
         $litoWhdp  = lawhdp;
         $liOLcnsU = *on;
         $liOlcns = laolcns;
         $liToSItemU = *on;
         $litosItem = lasitem;
         $liToWhseU = *on;
         $litoWhse  = gwhse;

         $liAQty1U = *on;
         $liaQty1  = laqty1;
         $liaQty2  = laqty2;
         $liaQty3  = laqty3;
         $liToRQty1U = *on;
         $liToRQty1  = laQty1;
         $liToRQty2  = laQty2;
         $liToRQty3  = laQty3;
         $liToLcnsU = *on;
         $litoLcns = lalcns;

         $dricommand = '*LICENSE';
         $drisubcmd  = '%SETLCNS';
         $drisys2upd = 'D';
         chk4err = *off;
         // I took this out because it creates 2 recs
         // and doesn't provide much information
         //zzzdricop();

         // Add/Update LICINFO
         // $ln fields initialized in %GET above

         $dricommand = '*LICINFO';
         if doAddLicinfo;
           $drisubcmd  = '%ADDS';
           $lnseq = 1;
           $lnitem = ihlitem;
           $lnrcvtyp = '6';
           $lnlot = ihlhostlot;
         else;
           $drisubcmd  = '%CHANGES';
           $lnlot = ihlhostlot;
         endif;
         $drisys2upd = 'D';
         chk4err = *on;
         zzzdricop();
         if error;
           ihlstatus = 'E';
           if doAddLicinfo;
             ihltext = 'Error adding orig license '
                     + '(' + %trim(ihlolcns) + ') in LICINFO: '
                     + %trim($drireturn) + ' - ' + $drimessage;
           else;
             ihltext = 'Error updating orig license '
                     + '(' + %trim(ihlolcns) + ') in LICINFO: '
                     + %trim($drireturn) + ' - ' + $drimessage;
           endif;
         else;
           ihlstatus = 'S';
           ihltext = '';
         endif;

         ihlststs = %timestamp(*sys);
         ihlstsuc = ihlststs;
         ihladdts = %timestamp(*sys);
         ihladduc = ihlststs;
         write ihlrec;

       enddo;

       // Need to write rec if no Active license found

       if count = 0;
         ihlstatus = 'E';
         ihltext = 'No Active licenses found for item ' + ihlitem;
         ihlststs = %timestamp(*sys);
         ihlstsuc = ihlststs;
         ihladdts = %timestamp(*sys);
         ihladduc = ihlststs;
         write ihlrec;
       endif;

     p                 e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     p zzzDriCop       b
     d zzzDriCop       pi

       error = *off;

       select;
       when $dricommand = '*LICENSE';
         $dridata = $license;
         $dridata2 = $license2;
       when $dricommand = '*LICINFO';
         $dridata = $licinfo;
         $dridata2 = $licinfo2;
       endsl;

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

       select;

       when chk4err and %error;
         error = *on;
         $drireturn = '';
         $drimessage = 'Error occured on call to '
             + 'DRICOP'
             + '/' + %trim($drisubcmd)
             + ' from ' + #prog;

       when chk4err and $drireturn <> '*OK';
         error = *on;

       endsl;

       select;
       when $dricommand = '*LICENSE';
         $license = $dridata;
         $license2 = $dridata2;
       when $dricommand = '*LICINFO';
         $licinfo = $dridata;
         $licinfo2 = $dridata2;
       endsl;

       zmflag = *off;
       zmsflag = *off;
       chk4err = *off;

     p                 e

