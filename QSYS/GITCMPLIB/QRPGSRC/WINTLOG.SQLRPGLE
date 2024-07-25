      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WINTLOG   Write Import Error information to INTLOG
     *  08 January 2023
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *
     *  To compile:  COMMIT = *NONE
     *               DLYPRP = *YES
     *
     *----------------------------------------------------------------
     *  Revisions
     *
760 A*    01/08/23  KDE  7.60
     *      - Created.
770aA*    02/26/23  KDE  7.70a
     *      - Modify to write detail file error messages
     *      - Also have it process through all detail lines since header
     *        not always marked in Error when detail lines are
770bA*    05/05/23  KDE  7.70b
     *      - Add ability to properly process status 9 batches.  Only
     *        add header impspoh data to error log
770cA*    06/29/23  KDE  7.70c
     *      - Add routines to process Export batches in error.  A new
     *        program called EMLEXPERRS will wake up and run every couple
     *        minutes to look for Exports batches in error since last runtime.
     *        That process will loop any batches and call this to write
     *        proper error information into INTLOG and then call MRC
     *        report R426xx to send email with that detail per the batch
780aA*    04/23/24  KDE  7.80a
     *      - Change what makes up email subject in intlog
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * File Specs
     *
     Fstgbatch  if   e           k disk
     Fimpsordh  if   e           k disk
     Fimpsordd  if   e           k disk
     frtehed    if   e           k disk
     fimpsitmn  if   e           k disk
     fimpspoh   if   e           k disk
     fimpspod   if   e           k disk
     fimpsrcvp  if   e           k disk
     fimpsrtn   if   e           k disk
     fimpspckq  if   e           k disk
     fexpspoh   if   e           k disk
     fexpspod   if   e           k disk
     fexpsrtn   if   e           k disk
     fexpsrtnlt if   e           k disk
     fexpsordh  if   e           k disk
     fexpsordd  if   e           k disk
     fexpsadj   if   e           k disk
     fexpsadjlt if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Constants
     *
     *
     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Working variables
     *
     d forever         s              1
770aAd headerfound     s               n
770bAd status9         s               n
     d wkText          S          64512a   varying
     d wkwhse          s              3p 0
     d wkbranch        s              5
     d wkinttype       s              1
     d wkgrpid         s              5i 0
     d wkgrpcode       s             20c
     d wkgrpsub        s             20c
     d wkrectyp        s              1c
     d wkfromts        s               z
     d wktots          s               z
     d wkdurms         s              5i 0
     d wkbatid         s             11c
     d wkpo            s             10c
     d wkordid         s             15s 0
     d wkseq           s              5s 0
     d wkitem          s             10c
     d wkrtid          s              5c
     d wkTrn#          s              7s 0
     d wkstgts         s               z
     d wkcurusr        s             10c
     d wkjobusr        s             10c
     d wkjobnbr        s              6c
     d wkjobname       s             10c
     d wkpgm           s             20c
     d wkaddts         s               z

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     * Function prototypes.

      /copy qcopysrc,p.bfcdteti

     *  Client Name Data Area
     dpirclient3       ds            10    DTAARA('PIRCLIENT3')

     *----------------------------------------------------------------
     *  Sub-procedure prototypes

750qAd WriteCLOB       pr
750qAd  logText                   64512a    varying

     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse   Warehouse
     *      $pBatid  Batch Id
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pBatid          11

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     * Main line
     *
     C                   eval      *inlr=*on
     *
     *  determine batch type and process accordingly
     *
       /free
                         select;
                           when sbtype = 'IMPROUTE';
                             // Write Error for route batch
                             exsr improute;
                           when sbtype = 'IMPPO';
                             // Write Error for Purchase Order Batch
                             exsr imppo;
                           when sbtype = 'IMPRCVPLT';
                             // Write Error for Purchase Order Pallet Receipts
                             exsr imprcvplt;
                           when sbtype = 'IMPCUSTRTN';
                             // Write Error for customer returns
                             exsr impcusttrn;
                           when sbtype = 'IMPPICKED';
                             // Write Error for Order Qty Picked
                             exsr imppicked;
                           when sbtype = 'IMPITEM';
                             // Write Error for item import
                             exsr impitem;
770cA                      when %subst(sbtype:1:3)='EXP';
770cA                        select;
770cA                          when sbtype='EXPPO';
770cA                            exsr exppo;
770cA                          when sbtype='EXPROUTE';
770cA                            exsr exproute;
770cA                          when sbtype='EXPADJUST';
770cA                            exsr expadjust;
770cA                        other;
770cA                            exsr expother;
770cA                          // call routine that sends generic error message
770cA                        endsl;
                           other;
                             return;
                         endsl;
       /end-free
     *
     *  Good-bye
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     *   get stage batch record
      /free
780aA       in pirclient3;
            chain ($pWhse:$pBatid) stgbatch;
            if not %found(stgbatch);
              return;
            else;
              // remove any previous records for record type 7 or 8
              exec sql delete from intlog where ilwhse=:$pWhse and
                           ilbatid=:$pBatid and ilrectyp in('7','8');
            endif;
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  IMPROUTE - Write error for Customer Route Batch
     *
     C     IMPROUTE      begsr
     *
      /free
          // loop thru header and detail building message
          headerfound = *off;
          setll ($pWhse:$pBatid) impsordh;
          dow forever = forever;
            reade ($pWhse:$pBatid) impsordh;
            if %eof(impsordh);
              leave;
            endif;

            if oihstatus<>'E';
              iter;
            endif;

            headerfound=*on;
            chain ($pWhse:oihrteid) rtehed;
            wktext = '|Order Header info - ' +
                     ' Route(' + %trim(rhrte) + '/' +
                     %trim(rhrtid) + ')|Order Number(' + %editc(oihord:'X') +
                     '/' + %trim(%editc(oihordid:'X')) + ')  Customer(' +
                     %trim(oihcnm) + ')|' + '  Stop(' +
                     %trim(%editc(oihest:'X')) + ')' +
                     '  Error(' + %trim(OIHTEXT) + ')||';
          enddo;

          // look for any detail line issues for this order id
770aD     //setll ($pWhse:$pBatid:oihord) impsordd;
770aM     setll ($pWhse:$pBatid) impsordd;
          dow forever = forever;
770aD       //reade ($pWhse:$pBatid:oihord) impsordd;
770aM       reade ($pWhse:$pBatid) impsordd;
            if %eof(impsordd);
              leave;
            endif;

            if oidstatus<>'E';
              iter;
            endif;

770aA       // If no header errors then add message to that effect
770aA       // to body message
770aA       if not headerfound;
770aA         wkText = '|** Order Detail Messages ONLY for this Batch Id|';
770aA         headerfound = *on;
770aA       endif;
770aD       //wkText = %trim(wkText) + '** Order Detail line(s)' +
770aD       //         ' have errors as well **|||';
770aA       wkText =%trim(wkText) + '--  Ord(' + %char(oidord) + '), OrdSeq' +
770aA                '(' + %char(oidseq) + ', OrdItem(' + %trim(oiditm) +
770aA                '), OrdQty(' + %char(oidq1) + '-' + %char(oidq2) + '-' +
770aA                %char(oidq3) + '), ImpError(' + %trim(oidtext) + ')|';
770aD       //leave;
          enddo;

          // add message to end referencing user to Web Staging Report
770aD     //wkText = %trim(wktext) + '*** See web Staging Table report ' +
770aD     //        'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='IMPROUTE';
          wkgrpsub='IMPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=oihcpo;
          wkordid=oihordid;
          wkseq=oidseq;
          wkitem=oiditm;
          wktrn#=0;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  EXPROUTE - Write error for Customer Route Batch Export
     *
     C     EXPROUTE      begsr
     *
      /free
          // loop thru header and detail building message
          headerfound = *off;
          setll ($pWhse:$pBatid) expsordh;
          dow forever = forever;
            reade ($pWhse:$pBatid) expsordh;
            if %eof(expsordh);
              leave;
            endif;

            if oehstatus<>'E';
              iter;
            endif;

            headerfound=*on;
            chain ($pWhse:oehrteid) rtehed;
            wktext = '|Order Header info - ' +
                     ' Route(' + %trim(rhrte) + '/' +
                     %trim(rhrtid) + ')|Order Number(' + %editc(oehord:'X') +
                     '/' + %trim(%editc(oehordid:'X')) + ')  Customer(' +
                     %trim(oehcnm) + ')|' + '  Stop(' +
                     %trim(%editc(oehest:'X')) + ')' +
                     '  Error(' + %trim(oehTEXT) + ')||';
          enddo;

          // look for any detail line issues for this order id
          setll ($pWhse:$pBatid) expsordd;
          dow forever = forever;
            reade ($pWhse:$pBatid) expsordd;
            if %eof(expsordd);
              leave;
            endif;

            if oedstatus<>'E';
              iter;
            endif;

            // If no header errors then add message to that effect
            // to body message
            if not headerfound;
              wkText = '|** Order Detail Messages ONLY for this Batch Id|';
              headerfound = *on;
            endif;
            wkText =%trim(wkText) + '--  Ord(' + %char(oedord) + '), OrdSeq' +
                     '(' + %char(oedseq) + ', OrdItem(' + %trim(oeditm) +
                     '), OrdQty(' + %char(oedq1) + '-' + %char(oedq2) + '-' +
                     %char(oedq3) + '), ImpError(' + %trim(oedtext) + ')|';
          enddo;

          // add message to end referencing user to Web Staging Report
770aD     //wkText = %trim(wktext) + '*** See web Staging Table report ' +
770aD     //        'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='EXPROUTE';
          wkgrpsub='EXPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=oehcpo;
          wkordid=oehordid;
          wkseq=oedseq;
          wkitem=oeditm;
          wktrn#=0;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  IMPPO - Write error for Purchase Order Batch
     *
     C     IMPPO         begsr
     *
      /free
          // loop thru header and detail building message
770aA     headerfound = *off;
770bA     status9=*off;
          setll ($pWhse:$pBatid) impspoh;
          dow forever = forever;
            reade ($pWhse:$pBatid) impspoh;
            if %eof(impspoh);
              leave;
            endif;

770bD       //if pihstatus<>'E';
770bA       if pihstatus<>'E' and pihstatus<>'9';
              iter;
            endif;

770bA       if pihstatus='9';
770bA         status9=*on;
770bA       endif;

770aA     headerfound = *on;
          wktext = '|PO Header info - ' +
                   ' Purchase Order(' + %trim(pihpo) + '/' + 'Vendor: ' +
                   %trim(pihvna) + ')|Error(' + %trim(pihtext) + ')||';
770aM     enddo;

          // look for any detail line issues for this purchase order
770aD     //setll ($pWhse:$pBatid:pihpo) impspod;
770bA     if not status9;
770aM       setll ($pWhse:$pBatid) impspod;
            dow forever = forever;
770aD         //reade ($pWhse:$pBatid:pihpo) impspod;
770aM         reade ($pWhse:$pBatid) impspod;
              if %eof(impspod);
                leave;
              endif;

              if pidstatus<>'E';
                iter;
              endif;

770aA         // If no header errors then add message to that effect
770aA         // to body message
770aA         if not headerfound;
770aA           wkText = '|** PO Detail Messages ONLY for this Batch Id|';
770aA           headerfound = *on;
770aA         endif;

770aD         //wkText = %trim(wkText) + '** Purchase Order Detail line(s)' +
770aD         //         ' have errors as well **|||';
770aM         wkText =%trim(wkText) + '--  PO(' + %char(pidpo) + '), PoSeq' +
770aA                  '(' + %char(pidseq) + ', PoItem(' + %trim(piditm) +
770aA                  '), PoQty(' + %char(pidqo1) + '-' + %char(pidqo2) + '-' +
770aA                 %char(pidqo3) + '), ImpError(' + %trim(pidtext) + ')|';
770aD         //leave;
            enddo;
770bA     endif;

          // add message to end referencing user to Web Staging Report
770aD     //wkText = %trim(wktext) + '*** See web Staging Table report ' +
770aD     //         'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='IMPPO';
          wkgrpsub='IMPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=pihpo;
          wkordid=*loval;
          wkseq=*loval;
          wkitem=*loval;
          wktrn#=0;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
770cA*
770cA*----------------------------------------------------------------
770cA*
770cA*  EXPPO - Write error for Purchase Order Batch EXPORT
770cA*
770cAC     EXPPO         begsr
770cA*
770cA /free
770cA     // loop thru header and detail building message
770cA     headerfound = *off;
770cA     setll ($pWhse:$pBatid) expspoh;
770cA     dow forever = forever;
770cA       reade ($pWhse:$pBatid) expspoh;
770cA       if %eof(expspoh);
770cA         leave;
770cA       endif;
770cA
770cA       if pehstatus<>'E';
770cA         iter;
770cA       endif;
770cA
770cA       headerfound = *on;
770cA       wktext = '|PO Header info - ' +
770cA                ' Purchase Order(' + %trim(pehpo) + '/' + 'Vendor: ' +
770cA                %trim(pehvnm) + ')|Error(' + %trim(pehtext) + ')||';
770cA     enddo;
770cA
770cA     // look for any detail line issues for this purchase order
770cA     setll ($pWhse:$pBatid) expspod;
770cA     dow forever = forever;
770cA       reade ($pWhse:$pBatid) expspod;
770cA       if %eof(expspod);
770cA         leave;
770cA       endif;
770cA
770cA       if pedstatus<>'E';
770cA         iter;
770cA       endif;
770cA
770cA       // If no header errors then add message to that effect
770cA       // to body message
770cA       if not headerfound;
770cA         wkText = '|** PO Detail Messages ONLY for this Batch Id|';
770cA         headerfound = *on;
770cA       endif;
770cA
770cA       wkText =%trim(wkText) + '--  PO(' + %char(pedpo) + '), PoSeq' +
770cA                '(' + %char(pedseq) + ', PoItem(' + %trim(peditm) +
770cA                '), PoQty(' + %char(pedqr1) + '-' + %char(pedqr2) + '-' +
770cA               %char(pedqr3) + '), ExpError(' + %trim(pedtext) + ')|';
770cA     enddo;
770cA
770cA     // add message to end referencing user to Web Staging Report
770cA
770cA     // Create Email Body record in INTLOG
770cA     wkwhse=$pwhse;
770cA     wkbranch=*blanks;
770cA     wkinttype='E';
770cA     wkgrpid=0;
770cA     wkgrpcode='EXPPO';
770cA     wkgrpsub='EXPERRS';
770cA     wkrectyp='8';
770cA     wkfromts=%timestamp();
770cA     wktots=%timestamp();
770cA     wkdurms=0;
770cA     wkbatid=$pbatid;
770cA     wkpo=pehpo;
770cA     wkordid=*loval;
770cA     wkseq=*loval;
770cA     wkitem=*loval;
770cA     wktrn#=0;
770cA     wkstgts=sbaddts;
770cA     wkcurusr=#curruser;
770cA     wkjobusr=#user;
770cA     wkjobnbr=#jobnbr;
770cA     wkjobname=#jobn;
770cA     wkpgm=#pgm;
770cA     wkaddts=%timestamp();
770cA     writeClob(wkText);
770cA
770cA     // Create Email Subject record in INTLOG
770cA     wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
770cA              + 'Import Type (' + %trim(sbtype) + ')';
770cA     writeClob(wkText);
770cA /end-free
770cA*
770cAC                   endsr
770cA*
770cA*----------------------------------------------------------------
770cA*
770cA*  EXPOTHER - Defaults here if no specific Export routine defined
770cA*             for the specific export type
770cA*
770cAC     EXPOTHER      begsr
770cA*
770cA /free
770cA     wktext = '|Interface Error - ' +
770cA              ' Stage Batch(' + %trim(sbbatid) + ')' + 'Type: (' +
770cA              %trim(sbtype) + ')|Error(' + %trim(sbtext) + ')||';
770cA
770cA     // add message to end referencing user to Web Staging Report
770cA
770cA     // Create Email Body record in INTLOG
770cA     wkwhse=$pwhse;
770cA     wkbranch=*blanks;
770cA     wkinttype='E';
770cA     wkgrpid=0;
770cA     wkgrpcode='EXPOTHER';
770cA     wkgrpsub='EXPERRS';
770cA     wkrectyp='8';
770cA     wkfromts=%timestamp();
770cA     wktots=%timestamp();
770cA     wkdurms=0;
770cA     wkbatid=$pbatid;
770cA     wkpo=pehpo;
770cA     wkordid=*loval;
770cA     wkseq=*loval;
770cA     wkitem=*loval;
770cA     wktrn#=0;
770cA     wkstgts=sbaddts;
770cA     wkcurusr=#curruser;
770cA     wkjobusr=#user;
770cA     wkjobnbr=#jobnbr;
770cA     wkjobname=#jobn;
770cA     wkpgm=#pgm;
770cA     wkaddts=%timestamp();
770cA     writeClob(wkText);
770cA
770cA     // Create Email Subject record in INTLOG
770cA     wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
770cA              + 'Import Type (' + %trim(sbtype) + ')';
770cA     writeClob(wkText);
770cA /end-free
770cA*
770cAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  IMPITEM - Write error for Item Impoort
     *
     C     IMPITEM       begsr
     *
      /free
          // loop thru stage batch looking for errors to report
          setll ($pWhse:$pBatid) impsitmn;
          wktext = 'Item Import errors:|';
          dow forever = forever;
            reade ($pWhse:$pBatid) impsitmn;
            if %eof(impsitmn);
              leave;
            endif;

            if iustatus<>'E';
              iter;
            endif;

            wkText = '|Item(' + %trim(iuitem) + '/' +
                     %trim(iudesc) + ')  Error(' + %trim(iutext) + ')';

          enddo;

          // add message to end referencing user to Web Staging Report
          wkText = '||' + %trim(wktext) + '*** See web Staging Table report ' +
                   'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='IMPITEM';
          wkgrpsub='IMPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=*loval;
          wkordid=*loval;
          wkseq=*loval;
          wkitem=iuitem;
          wktrn#=*loval;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  EXPADJUST - Item Adjustment Export Errors
     *
     C     expadjust     begsr
     *
      /free
          // loop thru stage batch looking for errors to report
          setll ($pWhse:$pBatid) expsadjlt;
          wktext = 'Item Quantity Adjustment Import errors:|';
          dow forever = forever;
            reade ($pWhse:$pBatid) expsadjlt;
            if %eof(expsadjlt);
              leave;
            endif;

            if ieltstatus<>'E';
              iter;
            endif;

            wkText = '|Item(' + %trim(ieltitem) + ', ' +
                     'Original License(' + %trim(ieltolcns) +'), Quantity ' +
                     'Norm-' + %char(ieltqty1) + ', BD1-' + %char(ieltqty2) +
                     ', BD2-' + %char(ieltqty3) +
                     '  Error(' + %trim(ielttext) + ')';

          enddo;

          // add message to end referencing user to Web Staging Report
          wkText = '||' + %trim(wktext) + '*** See web Staging Table report ' +
                   'for more details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='A';
          wkgrpid=0;
          wkgrpcode='EXPADJUST';
          wkgrpsub='EXPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=*loval;
          wkordid=*loval;
          wkseq=*loval;
          wkitem=ieltitem;
          wktrn#=*loval;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  IMPRCVPLT - Write Error report for Pallet receipts
     *
     C     imprcvplt     begsr
     *
      /free
          // loop thru stage batch looking for errors to report
          setll ($pWhse:$pBatid) impsrcvp;
          wktext = 'Received pallet errors:|';
          dow forever = forever;
            reade ($pWhse:$pBatid) impsrcvp;
            if %eof(impsrcvp);
              leave;
            endif;

            if rcpstatus<>'E';
              iter;
            endif;

            wkText = '|Purchase Order(' + %trim(rcppo) + '/' +
                     %trim(rcpvnam) + ')  Error(' + %trim(rcptext) + ')';

          enddo;

          // add message to end referencing user to Web Staging Report
          wkText = '||' + %trim(wktext) + '*** See web Staging Table report ' +
                   'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='IMPRCVPLT';
          wkgrpsub='IMPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=rcppo;
          wkordid=*loval;
          wkseq=*loval;
          wkitem=*loval;
          wktrn#=*loval;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  impcusttrn - Write Error report for Customer Returns
     *
     C     impcusttrn    begsr
     *
      /free
          // loop thru stage batch looking for errors to report
          setll ($pWhse:$pBatid) impsrtn;
          wktext = 'Customer Return errors:|';
          dow forever = forever;
            reade ($pWhse:$pBatid) impsrtn;
            if %eof(impsrtn);
              leave;
            endif;

            if oirstatus<>'E';
              iter;
            endif;

            wkText = '|Order number(' + %char(oirord) + ')' +
                     '  Item(' + %trim(oiritm) + ')|' +
                     'Error(' + %trim(oirtext) + ')';

          enddo;

          // add message to end referencing user to Web Staging Report
          wkText = '||' + %trim(wktext) + '*** See web Staging Table report ' +
                   'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='IMPCUSTTRN';
          wkgrpsub='IMPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=*loval;
          wkordid=oirord;
          wkseq=*loval;
          wkitem=*loval;
          wktrn#=*loval;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  imppicked - Write Error report for Picked Quantity
     *
     C     imppicked     begsr
     *
      /free
          // loop thru stage batch looking for errors to report
          setll ($pWhse:$pBatid) impspckq;
          wktext = 'Host Item Picked Quantity errors:|';
          dow forever = forever;
            reade ($pWhse:$pBatid) impspckq;
            if %eof(impspckq);
              leave;
            endif;

            if ipqstatus<>'E';
              iter;
            endif;

            wkText = '|Item(' + %trim(ipqitm) + ')  ' +
                     'Slot(' + %trim(ipqdsp) + ')|' +
                     'Quantities(' + %char(ipqqp1) + '-' +
                     %char(ipqqp2) + '-' + %char(ipqqp3) + ')' +
                     '  Dept(' + %trim(ipqwhd) + '|' +
                     'License(' + %trim(ipqlcns) + ')  ' +
                     'Error(' + %trim(ipqtext) + ')';

          enddo;

          // add message to end referencing user to Web Staging Report
          wkText = '||' + %trim(wktext) + '*** See web Staging Table report ' +
                   'for details';

          // Create Email Body record in INTLOG
          wkwhse=$pwhse;
          wkbranch=*blanks;
          wkinttype='I';
          wkgrpid=0;
          wkgrpcode='IMPPICKED';
          wkgrpsub='IMPERRS';
          wkrectyp='8';
          wkfromts=%timestamp();
          wktots=%timestamp();
          wkdurms=0;
          wkbatid=$pbatid;
          wkpo=*loval;
          wkordid=*loval;
          wkseq=*loval;
          wkitem=ipqitm;
          wktrn#=*loval;
          wkstgts=sbaddts;
          wkcurusr=#curruser;
          wkjobusr=#user;
          wkjobnbr=#jobnbr;
          wkjobname=#jobn;
          wkpgm=#pgm;
          wkaddts=%timestamp();
          writeClob(wkText);

          // Create Email Subject record in INTLOG
          wkrectyp='7';
780aD     //wktext = 'Stage Batch Id (' + $pBatid + ')   ' +
780aM     wktext = %trim(pirclient3) + ' - Stage Batch Id (' + $pBatid + ')   '
                   + 'Import Type (' + %trim(sbtype) + ')';
          writeClob(wkText);
      /end-free
     *
     C                   endsr

     *----------------------------------------------------------------
     *  WriteCLOB        Write record to INTLOG
     *----------------------------------------------------------------

     p WriteCLOB       b
     d WriteCLOB       pi
     d  logText                   64512a    varying

     d* These definitions will create corresponding fields _data, _len
     d*    http://itpscan.ca/blog/iSeries/clobs.php

     d wkTextClob      s                   sqltype(CLOB:64512)

      /free

       wkTextClob_data = logText;
       wkTextClob_len = %len(logText);

       Exec SQL
          INSERT INTO INTLOG (ilwhse, ilbranch, ilinttype, ilgrpid, ilgrpcode,
                              ilgrpsub, ilrectyp,
                              ilfromts, iltots, ildurms, ilbatid, ilpo, ilordid,
                             ilseq, ilitem, ilrtid, iltrn#, ilstgts, ilcurusr,
                              iljobusr, iljobnbr, iljobname, ilpgm, iladdts,
                              iltext)
          VALUES (:wkwhse, :wkbranch, :wkinttype, :wkgrpid, :wkgrpcode,
                  :wkgrpsub, :wkrectyp,
                  :wkfromts, :wktots, :wkdurms, :wkbatid, :wkpo, :wkordid,
                  :wkseq, :wkitem, :wkrtid, :wktrn#, :wkstgts, :wkcurusr,
                  :wkjobusr, :wkjobnbr, :wkjobname, :wkpgm, :wkaddts,
                  :wkTextClob);

      /end-free

     p                 e
