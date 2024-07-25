      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT982S   Staging Item Quantity Comparison - Build file
     *  08 November 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
700  *    02/08/16  RTR  7.00
     *      - Created from IT972S.
     *
710a *    09/20/17  RTR  7.10a
     *      - Fix: Changed record counting logic because SQL at end of
     *        program wasn't reading buffered records, causing count to
     *        be wrong.
     *
720a *    07/26/18  RTR  7.20a
     *      - Enh: Adding check to skip non-stock items, designation NSTK*.
     *
750  *    08/17/21  KDE  7.50
     *      - Enh: Add call to NetSuite Interface for NetSuite Customers
750a *    09/13/21  KDE  7.50a
     *      - Enh: Removed most of mod 7.50.  I had a mis-understanding
     *        initially from Victor regarding what his process was doing
     *        after being called.  Since I was calling the URL within here
     *        and he was calling IT971SCL at the end of his process it was
     *        causing a recursive issue.  I removed that url call in here
     *        and create program IT982SSBM which simply calls the URL and ends.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    10/26/18  RTR  EOPa
     *      - Enh: Changed to skip repack items. Host qty in base item.
EOPb *    12/14/18  RTR  EOPb
     *      - Fix: Fixes for fractional UOM qtys from host.
EOPc *    12/24/18  RTR  EOPc
     *      - Fix: Check VAM stock level for DZ items, some are DZ and
     *        some are HD.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Global Imports
     *
GIG A*    09/12/21  MLB  GIG
     *      - Fix: Fixes for fractional UOM qtys from host.
GIGaA*    09/13/21  KDE  GIGa
     *      - Fix: Correction to mod GIG calcs.  Since Netsuite only
     *        sends qty 1 field as a decimal we must calculate the
     *        breakdown.  It was trying to use %int and this mod changed
     *        to breakdow full and decimal values with a data structure.
     *
750 A*----------------------------------------------------------------
750 A*  Binding Directories
750 A*----------------------------------------------------------------

750 AHbnddir('BFCBND') BNDDIR('BFCIFSBND')

     *----------------------------------------------------------------
     * File Specs
     *
     Fimpscqty2 uf a e           k disk    prefix(erp_)
     Fitemqty   if   e           k disk
     fitemlnk   if   e           k disk
     fitemlnk1  if   e           k disk    usropn
     f                                     rename(ilrec:ilrec1)
     F*iritem1  if   e           k disk
     Fpiritem   if   e           k disk
     f*                                    prefix(i2)
     f*                                    rename(itrec:itrec2)
     Fwarehs    if   e           k disk
     Fslot3     if   e           k disk
     Fpodtl     if   e           k disk
EOPcAFitemext1  if   e           k disk
750 AFoptions   if   e           k disk
     Fit981rpt  o  a e           k disk
     *----------------------------------------------------------------
     *  Customer ids
      /copy qcopysrc,id#hkw
EOPaA /copy qcopysrc,id#eop
GIG A /copy qcopysrc,id#gig
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Called Program Prototypes
      /copy qcopysrc,p.qcmdexc

750 A* Prototype for NetSuite API Call
750 A /copy qcopysrc,p.intapins
750 A /copy qcopysrc,p.getopint

     *----------------------------------------------------------------
     *  Working Variables
EOPbAd diva            s              9p 3
EOPbAd divb            s              9p 3 inz(2.5)
EOPbAd divc            s              9s 3
     D addflg          s              1
     D chgflg          s              1
     d clen            s             15p 5
     d cmd             s           3000a
     d len             s              1p 0
     D count           s              3  0
     D grdord          s              5  0
750 Ad hostopts        s             20a
750 Ad hostoptint      s             20a
750 Ad hostoptlot      s             20a
     D k3pick          s              1
     D k3stat          s              2
     D linppg          s              3  0
750 Ad NetSuite        c                   const('NETSUITE')
     D pflag           s              1
     D pos             s              1  0
     d reccnt          s              6s 0
     d txtcnt          s            200a
     d savts           s               z
     d*svUmq2          s                   like(itumq2)
     d*svUmq3          s                   like(itumq3)
     d svItem          s                   like(erp_icitem)
     d svStk1          s                   like(iqstk1)
     d svStk2          s                   like(iqstk2)
     d svStk3          s                   like(iqstk3)
     d svTqh1          s                   like(erp_ictqh1)
     d svTqh2          s                   like(erp_ictqh2)
     d svTqh3          s                   like(erp_ictqh3)
     D whs#            s              3  0
     D work3a          s              3
750 Ad RtvData         s         131068a
750 AD O_TEXTDATA      C                   16777216
750 AD O_RDONLY        C                   1
750 AD O_CCSID         C                   32
750 AD ccsid           s             10I 0 inz(819)
750 Ad iFd             s             10U 0
750 Ad iMode           s             10U 0
750 Ad iFlags          s             10I 0
750 AD iBuf            s               *
730 AD currStr         s           4000    varying
750 AD PathFile        S            256
750 Ad rlen            s              5p 0
GIGaAd wkQty2          s              5  0

GIGaAd                 ds
GIGaAd  wkQty1                        9  3
GIGaAd   fullQty                      6  0 overlay(wkQty1)
GIGaAd   decQty                       3  0 overlay(wkQty1:*next)

750 AD OpenInput       PR            10i 0
750 AD   fileName                  2048    const varying

750 AD ReadFile        PR            10I 0 extproc('read')
750 AD                               10I 0 value
750 AD                                 *   value
750 AD                               10U 0 value

750 AD open            PR            10I 0 extproc('open')
750 AD   path                          *   value options(*string)
750 AD   oflag                       10I 0 value
750 AD   mode                        10U 0 value options(*nopass)
750 AD   codepage                    10U 0 value options(*nopass)

750 A /if not defined(CLOSE_PROTOTYPE)
750 AD close           PR            10I 0 extproc('close')
750 AD   fildes                      10I 0 value
750 A /define CLOSE_PROTOTYPE
750 A /endif
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $whse   Warehouse
     *      $batch  Batch ID
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $batch           11
     *
     * Main line
     *
      /free
750 A   exsr zzinz2;

        // Look for Alias or SSB items, and add qty to parent item.
        exsr zzrollupHost;

        // Whip through all the Item records
        setll (whs#: ' ') piritem;
        dow forever = forever;
          reade (whs#) piritem;
          error = *off;
          if %eof(piritem);
            leave;
          endif;

720aA     // If non-stock item, skip.
720aA     if itdesg = 'NSTK*';
720aA       iter;
720aA     endif;

EOPaA     // For Earl's skip repack items.
EOPaA     if client = EarlsOrganic
EOPaA       and ittype = 'R';
EOPaA         iter;
EOPaA     endif;

EOPcA     // Get matching item extension record
EOPcA     chain (whs#: ititem) itemext1;
EOPcA     if not %found(itemext1);
EOPcA       ikmsc1 = ' ';
EOPcA       ikmsc2 = ' ';
EOPcA       ikmsc3 = ' ';
EOPcA     endif;

          // Get matching item quantity record
          chain (whs#: ititem) itemqty;
          if not %found(itemqty);
            iqstk1 = 0;
            iqstk2 = 0;
            iqstk3 = 0;
          endif;

          // Get matching import quantity record
          chain (whs#: $batch: ititem) impscqty2;
          if not %found(impscqty2);
            erp_ictqh1 = 0;
            erp_ictqh2 = 0;
            erp_ictqh3 = 0;
          endif;

EOPaA     // For Earl's check qty level.
EOPaA     if client = EarlsOrganic;
EOPaA       select;
EOPaA         when itum1 = 'D2';
EOPbA           diva = erp_ictqh1;
EOPbA           divb = 2.5;
EOPbA           divc = %div(%int(diva*100): %int(divb*100));
EOPbA           erp_ictqh1 = divc;
EOPbA           divc = %rem(%int(diva*100): %int(divb*100))/100;
EOPbA           erp_ictqh2 = divc;
EOPbA         when itum2 = 'DZ';
EOPbA           erp_ictqh2 = erp_ictqh1;
EOPbA           erp_ictqh3 = erp_ictqh2 * 2;
EOPbA           erp_ictqh1 = %div(%int(erp_ictqh2*100): %int(itumq2*100));
EOPbA           erp_ictqh2 = %int(erp_ictqh2 - (erp_ictqh1 * itumq2));
EOPbA           erp_ictqh3 = erp_ictqh3 - (erp_ictqh1 * itumq2 * itumq3)
EOPbA                      - (erp_ictqh2 * itumq2);
EOPcA         when itum1 = 'DZ' and ikmsc3 = '1.0000';
EOPcA           erp_ictqh2 = (erp_ictqh1 * itumq2)
EOPcA                      - (%int(erp_ictqh1) * itumq2);
EOPaA         when itum2 <> *blanks;
EOPbA           diva = erp_ictqh1;
EOPbA           divb = itumq2;
EOPbA           divc = %div(%int(diva*100): %int(divb*100));
EOPbA           erp_ictqh1 = divc;
EOPbA           divc = %rem(%int(diva*100): %int(divb*100))/100;
EOPbA           erp_ictqh2 = divc;
EOPcA         other;
EOPcA           erp_ictqh2 = (erp_ictqh1 * itumq2)
EOPcA                      - (%int(erp_ictqh1) * itumq2);
EOPaA       endsl;
EOPaA     endif;

GIG A     // For Global Imports - check qty level.
GIG A     if client = GlobalImport;
GIG A       select;
GIG A         when itum2 <> *blanks;
GIGaD          // diva = erp_ictqh1;
GIGaM          wkQty1 = erp_ictqh1;
GIGaD          // divb = itumq2;
GIGaD          // divc = %div(%int(diva*100): %int(divb*100));
GIGaD          // erp_ictqh1 = divc;
GIGaM          erp_ictqh1 = fullQty;
GIGaD          // divc = %rem(%int(diva*100): %int(divb*100))/100;
GIGaD          // erp_ictqh2 = divc;
GIGaM          eval(h) wkQty2 = itumq2 * (decQty)/1000;
GIGaM          erp_ictqh2 = wkQty2;
GIGaD         //other;
GIGaD           //erp_ictqh2 = (erp_ictqh1 * itumq2)
GIGaD           //           - (%int(erp_ictqh1) * itumq2);
GIG A       endsl;
GIG A     endif;

          // Calculate differences between host and Dakota qty's
          exsr zzcalc;

          // Get pick slot
          setll (whs#: iqitem: 'A': 'Y') slot3;
          reade (whs#: iqitem: 'A': 'Y') slot3;
          if %eof(slot3);
            sldisp = *blanks;
          endif;

          // Write detail
          if difsrt <> 0;
            crwhse = itwhse;
            critem = ititem;
            crwhdp = itwhdp;
            crdesc = itdesc;
            crdisp = sldisp;
            crbatch = $batch;
            craddts = savts;
            ictqh1 = erp_ictqh1;
            ictqh2 = erp_ictqh2;
            ictqh3 = erp_ictqh3;
            write wkrec;
710aA       reccnt = reccnt + 1;
          endif;
        enddo;

        //Whip through the import item records and write ones with no itemqty
        setll (whs#: $batch) impscqty2;
        dow forever = forever;
          reade (whs#: $batch) impscqty2;
          error = *off;
          if %eof(impscqty2);
            leave;
          endif;

          // Look for matching itemqty record, if not found, write
          chain (whs#: erp_icitem) itemqty;
          if not %found(itemqty);
            iqstk1 = 0;
            iqstk2 = 0;
            iqstk3 = 0;
            exsr zzcalc;
            if difsrt <> 0;
              crwhse = erp_icwhse;
              critem = erp_icitem;
              crwhdp = *blanks;
              crdesc = *blanks;
              crdisp = *blanks;
              ictqh1 = erp_ictqh1;
              ictqh2 = erp_ictqh2;
              ictqh3 = erp_ictqh3;
              craddts = savts;
              write wkrec;
710aA         reccnt = reccnt + 1;
            endif;
          endif;
        enddo;

        // All done, mark records as processed.
        exec sql
          update stgbatch
          set sbstatus = 'S',
              sbtext   = 'Comparison report has been generated.',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$whse
            and sbbatid = :$batch;

        if sqlstt <> sqlSuccess;   // send error message
          cmd = 'SNDMSG MSG('+ sq + 'ERROR: IT981S Comparison Report '
              + sqlstt + ' in staging batch ID ' + $batch
              + sq + ') TOUSR(*SYSOPR)';
          clen = %len(cmd);
          qcmdexc(cmd: clen);
        else;
         exec sql
          update impscqty2
          set icstatus = 'S',
              ictext   = ' ',
              icststs  = current_timestamp,
              icstsuc  = current_timestamp - current_timezone
          where icwhse = :$whse
            and icbatid = :$batch;
710aD  //exec sql
710aD  // select count(*) into :reccnt
710aD  //   from it981rpt
710aD  //  where crbatch = :$batch;
         txtcnt = %char(reccnt) + ' differences found.';
         exec sql
          update it981idx
             set cxtext = :txtcnt
           where cxbatch = :$batch;
        endif;

        *inlr = *on;

      /end-free
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
750 Ac                   parm                    clientinit        3
750 Ac                   parm                    clienthost       10
     *
     C                   if        not %open(itemlnk1)
     C                   open      itemlnk1
     C                   endif
     *
     C                   monitor
     C                   eval      whs# = %dec($whse: 3: 0)
     C                   on-error
     C                   eval      error = *on
     C                   endmon
     *
     C                   eval      savts = %timestamp()
     *
      /free
        exec sql
          insert into it981idx
            values (:$whse,:$batch,:savts,'Processing...');
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC   Calculate differences between host and Dakota qty's
     *
     C     zzcalc        begsr
     *
     C                   eval      diff1 = erp_ictqh1 - iqstk1
     C                   eval      diff2 = erp_ictqh2 - iqstk2
     C                   eval      diff3 = erp_ictqh3 - iqstk3
     *
     C                   if        diff1 < 0
     C                   eval      difsrt = (diff1 * -1)
     C                   else
     C                   eval      difsrt = diff1
     C                   endif
     C                   if        diff2 < 0
     C                   eval      difsrt = difsrt + (diff2 * -1)
     C                   else
     C                   eval      difsrt = difsrt + diff2
     C                   endif
     C                   if        diff3 < 0
     C                   eval      difsrt = difsrt + (diff3 * -1)
     C                   else
     C                   eval      difsrt = difsrt + diff3
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
750 A*
750 A*  Define partial key for OPTIONS file.
750 A*
750 AC     keyop         klist
750 AC                   kfld                    whs#
750 AC                   kfld                    opcode
     *
     *  Define keys for piritem.
     *
     C     keyit2        klist
     C                   kfld                    whs#
     C                   kfld                    erp_icitem
     *
     * ITEMLINK1 Partial file key
     *
     c     keyil1        klist
     c                   kfld                    whs#
     c                   kfld                    erp_icitem
     c     keyil1a       klist
     c                   kfld                    whs#
     c                   kfld                    ilitem
     *
     *  Define keys for import qty.
     *
     C     keyic         klist
     C                   kfld                    whs#
     C                   kfld                    $batch
     C                   kfld                    ilitm2
     *
     C     keyicreset    klist
     C                   kfld                    whs#
     C                   kfld                    $batch
     C                   kfld                    svitem
750aA*
750aA*  Get option interface settings
750aA*
750aDc*                  eval      opwhse = 1
750aDc*                  eval      opcode = '*HOST   '
750aDc*    keyop         chain     options
750aDc*                  if        not %found(options)
750aDc*                  eval      hostopts = '*NONE'
750aDc*                  else
750aDc*                  movel     opdata        hostopts
750aDc*                  endif
750aD**  Get Host ERP from OPTIONINT
750aD /free
750aD   // Get debug flag
750aD   //optint.type = 'Interface   ';
750aD   //optint.cat  = 'General Options     ';
750aD   //optint.name = 'Host ERP System     ';
750aD   //GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
750aD   //          optint.valn: optint.vala: optint.return);
750aD   //if optint.return = '*OK';
750aD   //  hostoptint = optint.vala;
750aD   //else;
750aD   //  hostoptint = '*NONE';
750aD   //endif;
750aD   //if (hostopts = NetSuite
750aD   // or hostoptint = NetSuite
750aD   // or clienthost = NetSuite);
750aD
750aD   //  ApiNS.Whse = %editc(whs#:'X');
750aD   //  ApiNS.Batch = *blanks;
750aD   //  ApiNS.Type = 'IMPICOMP';
750aD   //  IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
750aD   //           ApiNS.Ret: ApiNS.Msg);
750aD   //  if ApiNS.Ret <> '*OK';
750aD   //  else;
750aD       // read the data returned from the URL and get the
750aD       // staging batch id to continue
750aD    //   exsr getBatchId;
750aD    // endif;
750aD   //endif;
750 AC                   endsr

750 A*----------------------------------------------------------------
750 A*  getBatchId - Reads IFS file returned from Netsuite URL call
750 A*               that Victor returns for BFC interface after Netsuite
750 A*----------------------------------------------------------------

750aD /free
750aD    begsr getBatchId;
750aD     //
750aD     // / Get Interface IFS log directory
750aD     // ptint.type = 'Interface   ';
750aD     // ptint.cat  = 'NetSuite API        ';
750aD     // ptint.name = 'Log File Path       ';
750aD     // etOptInt(optint.type: optint.cat: optint.name: optint.valt:
750aD     //          optint.valn: optint.vala: optint.return);
750aD     // f optint.return = '*OK';
750aD     //  Pathfile = optint.vala;
750aD     // lse;
750aD     //  // since no path is defined we end without running
750aD     //  return;
750aD     // ndif;
750aD     //
750aD     // /Set file path
750aD     // athfile = %trim(PathFile) + 'NSInt-' + %editc(whs#:'X') +
750aD     //           '.txt';
750aD     //
750aD     // /Open IFS HTML file
750aD     // fd = openInput(PathFile);
750aD     //
750aD     // f ifd < 0;
750aD     //   //If no file was returned we exit without running report
750aD     //   return;
750aD     // ndif ;
750aD     // rlen = readFile(iFD: %addr(rtvData):%size(rtvData));
750aD     // if rlen < 1;
750aD     //    return;
750aD     // endif;
750aD     //
750aD     // //Remove any formatting characters to end of line returned
750aD     // RtvData = %xlate(x'00':' ':RtvData) ;  //End of record null
750aD     // RtvData = %xlate(x'25':' ':RtvData) ;  //Line feed (LF)
750aD     // RtvData = %xlate(x'0D':' ':RtvData) ;  //Carriage return (CR)
750aD     //
750aD     // //Confirm all is good and get staging batch id
750aD     // if %scan('"status":200':RtvData)>0;
750aD     //   //good to go
750aD     //   monitor;
750aD     //     if %scan('batch: ':RtvData) > 0;
750aD     //       $batch = %subst(RtvData:%scan('batch: ':RtvData)+7:11);
750aD     //     else;
750aD     //       // no batch then return
750aD     //       return;
750aD     //     endif;
750aD     //   on-error;
750aD     //     // cannot get batch so we exist
750aD     //     return;
750aD     //   endmon;
750aD     // else;
750aD     //     // cannot get batch so we exist
750aD     //   // Interface failed
750aD     //   return;
750aD     // endif;
750aD     //
750aD     // //Close IFS File
750aD     // callp close(ifd);
750aD     //
750aD        Endsr;
750 A /end-free
     *
     *----------------------------------------------------------------
     *
     *  ZZROLLUPHOST   Roll-up Qty's sent for Alias or SSB items into Parent.
     *
      /free
       begsr zzrollupHost;

         setll (whs#: $batch) impscqty2;
         dow forever = forever;
           reade (whs#: $batch) impscqty2;
           if %eof(impscqty2);
             leave;
           endif;
      /end-free

     C     keyit2        chain     piritem
     C                   select
     C                   when      %found(piritem)
     C                             and client = Hearnkirkwood
     C                             and ittype = ' '
     *      Wrong item type, read next record.
     *      Allow type A, B or S items to be processed.
     C                   iter
     *
     C                   when      %found(piritem)
     C                             and client = Hearnkirkwood
     C                             and (ittype = 'A'
     C                               or ittype = 'B'
     C                               or ittype = 'S')
     *      Allow type A, B or S items to be processed.
     *
     *      Wrong item type, read next record.
     C                   when      %found(piritem)
     C                             and ittype <> 'A'
     C                             and ittype <> 'S'
     *      Wrong item type, read next record.
     C                   iter
     C                   endsl
     *
     *      Retrieve parent/base item number.
     C     keyil1        chain     itemlnk
     C                   if        %found(itemlnk)
     *
     *      Found Alias or SSB item, proceed to roll-up qty.
     C                   eval      svitem = erp_icitem
     C                   eval      svtqh1 = erp_ictqh1
     C                   eval      svtqh2 = erp_ictqh2
     C                   eval      svtqh3 = erp_ictqh3
     *
     C                   delete    icrec
     *
     *      Find parent/base item and update saved qty's.
     C     keyic         chain     impscqty2
     C                   if        %found(impscqty2)
     C                   select
     C                   when         ittype = 'S'
     C                             or ittype = 'B'
     C                   eval      erp_ictqh2 = erp_ictqh2 + svtqh1
     C                   other
     C                   eval      erp_ictqh1 = erp_ictqh1 + svtqh1
     C                   eval      erp_ictqh2 = erp_ictqh2 + svtqh2
     C                   eval      erp_ictqh3 = erp_ictqh3 + svtqh3
     C                   endsl
     C                   update    icrec
     *
     C                   else
     *
     *      Parent/base item not in import file. Add record.
     C                   eval      erp_icwhse = whs#
     C                   eval      erp_icbatid = $batch
     C                   eval      erp_icitem = ilitm2
     C                   select
     C                   when         ittype = 'S'
     C                             or ittype = 'B'
     C                   eval      erp_ictqh1 = 0
     C                   eval      erp_ictqh2 = svtqh1
     C                   eval      erp_ictqh3 = 0
     C                   other
     C                   eval      erp_ictqh1 = svtqh1
     C                   eval      erp_ictqh2 = svtqh2
     C                   eval      erp_ictqh3 = svtqh3
     C                   endsl
     *
     C                   write     icrec
     C                   endif                                                  Endif-Chain impscqty
     *
     *      Re-position file pointer to next item, not parent.
     C     keyicreset    setgt     impscqty2
     *
     C                   endif                                                  Endif-Chain itemlnk
     *
     C                   enddo
     *
     C                   endsr
     *

750 A*----------------------------------------------------------------
750 A*  OpenInput    Open input file for read only
750 A*----------------------------------------------------------------
750 A
750 Ap OpenInput       b
750 Ad OpenInput       pi            10I 0
750 Ad  fileName                   2048A   const varying
750 A
750 A*  Local Variables
750 A
750 Ad error           S               n
750 Ad fd              s             10I 0
750 Ad errorStr        s            100A   varying
750 A
750 A /free
750 A
750 A   // Open directory
750 A
750 A    iflags = O_RDONLY + O_TEXTDATA + O_CCSID;
750 A    fd = open(%trimr(fileName): iflags: 0: 0);
750 A
750 A    if fd < 0;
750 A      //errorStr = %str(strerror(errno));
750 A      dsply 'Error opening file';
750 A      return fd;
750 A    endif;
750 A
750 A   return fd;
750 A
750 A /end-free
750 A
750 Ap OpenInput       e
