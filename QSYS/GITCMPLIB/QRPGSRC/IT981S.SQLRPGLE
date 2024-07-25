      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT981S   Staging Item Quantity Comparison - Build file
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
730a *    03/13/19  RTR  7.30a
     *      - Enh: Adding check for live department. Skip if not live.
     *
730b *    11/01/19  RTR  7.30b
     *      - Enh: Added softcode branching for program version.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    10/26/18  RTR  EOPa
     *      - Enh: Changed to skip repack items. Host qty in base item.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpscqty  uf a e           k disk
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
     Fit981rpt  o  a e           k disk
     *----------------------------------------------------------------
     *  Customer ids
      /copy qcopysrc,id#hkw
EOPaA /copy qcopysrc,id#eop
730aA /copy qcopysrc,id#adf
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

730aAd chklive         pr                  extpgm('CHKLIVE')
730aAd  lvwhse                        3  0 const
730aAd  lvdept                        5    const
730aAd  lvrtn                         8    const

730bAd it983s          pr                  extpgm('IT983S')
730bAd  p983whs                       3    const
730bAd  p983bat                      10    const

     *----------------------------------------------------------------
     *  Working Variables
EOPaAd diva            s              9p 2
EOPaAd divb            s              9p 2 inz(2.5)
EOPaAd divc            s              7s 0
     D addflg          s              1
     D chgflg          s              1
     d clen            s             15p 5
     d cmd             s           3000a
     d len             s              1p 0
730aAd chkrtn          s              8a
     D count           s              3  0
     D grdord          s              5  0
     D k3pick          s              1
     D k3stat          s              2
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     d reccnt          s              6s 0
     d txtcnt          s            200a
     d savts           s               z
     d*svUmq2          s                   like(itumq2)
     d*svUmq3          s                   like(itumq3)
     d svItem          s                   like(icitem)
     d svStk1          s                   like(iqstk1)
     d svStk2          s                   like(iqstk2)
     d svStk3          s                   like(iqstk3)
     d svTqh1          s                   like(ictqh1)
     d svTqh2          s                   like(ictqh2)
     d svTqh3          s                   like(ictqh3)
     D whs#            s              3  0
     D work3a          s              3
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

730aA     // Check if department is active.
730aA     chklive(itwhse: itwhdp: chkrtn);
730aA     if chkrtn <> '*LIVE';
730aA       iter;
730aA     endif;

720aA     // If non-stock item, skip.
720aA     if itdesg = 'NSTK*';
720aA       iter;
720aA     endif;

EOPaA     // For Earl's skip repack items.
EOPaA     if client = EarlsOrganic
EOPaA       and ittype = 'R';
EOPaA         iter;
EOPaA     endif;

          // Get matching item quantity record
          chain (whs#: ititem) itemqty;
          if not %found(itemqty);
            iqstk1 = 0;
            iqstk2 = 0;
            iqstk3 = 0;
          endif;

          // Get matching import quantity record
          chain (whs#: $batch: ititem) impscqty;
          if not %found(impscqty);
            ictqh1 = 0;
            ictqh2 = 0;
            ictqh3 = 0;
          endif;
EOPA
EOPaA     // For Earl's check qty level.
EOPaA     if client = EarlsOrganic;
EOPaA       select;
EOPaA         when itum1 = 'D2';
EOPaA           diva = ictqh1;
EOPaA           divb = 2.5;
EOPaA           divc = %div(%int(diva*100): %int(divb*100));
EOPaA           ictqh1 = divc;
EOPaA           divc = %rem(%int(diva*100): %int(divb*100))/100;
EOPaA           ictqh2 = divc;
EOPaA         when itum2 <> *blanks;
EOPaA           diva = ictqh1;
EOPaA           divb = itumq2;
EOPaA           divc = %div(%int(diva*100): %int(divb*100));
EOPaA           ictqh1 = divc;
EOPaA           divc = %rem(%int(diva*100): %int(divb*100))/100;
EOPaA           ictqh2 = divc;
EOPaA       endsl;
EOPaA     endif;
EOPaA
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
            write wkrec;
710aA       reccnt = reccnt + 1;
          endif;
        enddo;

        //Whip through the import item records and write ones with no itemqty
        setll (whs#: $batch) impscqty;
        dow forever = forever;
          reade (whs#: $batch) impscqty;
          error = *off;
          if %eof(impscqty);
            leave;
          endif;

          // Look for matching itemqty record, if not found, write
          chain (whs#: icitem) itemqty;
          if not %found(itemqty);
            iqstk1 = 0;
            iqstk2 = 0;
            iqstk3 = 0;
            exsr zzcalc;
            if difsrt <> 0;
              crwhse = icwhse;
              critem = icitem;
              crwhdp = *blanks;
              crdesc = *blanks;
              crdisp = *blanks;
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
          update impscqty
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

730bA /free
730bA    if client = AandDFoods;
730bA      callp it983s($whse: $batch);
730bA      return;
730bA    endif;
730bA /end-free
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
     C                   eval      diff1 = ictqh1 - iqstk1
     C                   eval      diff2 = ictqh2 - iqstk2
     C                   eval      diff3 = ictqh3 - iqstk3
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
     *
     *  Define keys for piritem.
     *
     C     keyit2        klist
     C                   kfld                    whs#
     C                   kfld                    icitem
     *
     * ITEMLINK1 Partial file key
     *
     c     keyil1        klist
     c                   kfld                    whs#
     c                   kfld                    icitem
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
     *
     *  Define key for slot file.
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZROLLUPHOST   Roll-up Qty's sent for Alias or SSB items into Parent.
     *
      /free
       begsr zzrollupHost;

         setll (whs#: $batch) impscqty;
         dow forever = forever;
           reade (whs#: $batch) impscqty;
           if %eof(impscqty);
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
     C                   eval      svitem = icitem
     C                   eval      svtqh1 = ictqh1
     C                   eval      svtqh2 = ictqh2
     C                   eval      svtqh3 = ictqh3
     *
     C                   delete    icrec
     *
     *      Find parent/base item and update saved qty's.
     C     keyic         chain     impscqty
     C                   if        %found(impscqty)
     C                   select
     C                   when         ittype = 'S'
     C                             or ittype = 'B'
     C                   eval      ictqh2 = ictqh2 + svtqh1
     C                   other
     C                   eval      ictqh1 = ictqh1 + svtqh1
     C                   eval      ictqh2 = ictqh2 + svtqh2
     C                   eval      ictqh3 = ictqh3 + svtqh3
     C                   endsl
     C                   update    icrec
     *
     C                   else
     *
     *      Parent/base item not in import file. Add record.
     C                   eval      icwhse = whs#
     C                   eval      icbatid = $batch
     C                   eval      icitem = ilitm2
     C                   select
     C                   when         ittype = 'S'
     C                             or ittype = 'B'
     C                   eval      ictqh1 = 0
     C                   eval      ictqh2 = svtqh1
     C                   eval      ictqh3 = 0
     C                   other
     C                   eval      ictqh1 = svtqh1
     C                   eval      ictqh2 = svtqh2
     C                   eval      ictqh3 = svtqh3
     C                   endsl
     *
     C                   write     icrec
     C                   endif                                                  Endif-Chain impscqty
     *
     *      Re-position file pointer to next item, not parent.
     C     keyicreset    setgt     impscqty
     *
     C                   endif                                                  Endif-Chain itemlnk
     *
     C                   enddo
     *
     C                   endsr
     *
