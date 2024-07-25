      /copy qcopysrc,hspecs
     h***tactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT981    FTP GUI Item Quantity Comparison - Build file
     *  04 December 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
700  *    12/04/16  RTR  7.00
     *      - Created from IT981S.
     *
730a *    01/30/19  RTR  7.30a
     *      - Enh: Added fields for item type and status.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    04/25/19  RTR  CFIa
     *      - Revised to ignore breakdown 2 differences per Paul B.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfcqty  uf a e           k disk
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
CFIaA /copy qcopysrc,id#cfi
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

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0


     *----------------------------------------------------------------
     *  Working Variables
     d $batch          s             11a
     d addflg          s              1
     d chgflg          s              1
     d clen            s             15p 5
     d cmd             s           3000a
     d len             s              1p 0
     d count           s              3  0
     d grdord          s              5  0
     d k3pick          s              1
     d k3stat          s              2
     d linppg          s              3  0
     d pflag           s              1
     d pos             s              1  0
     d recId           s             11p 0
     d reccnt          s              6s 0
     d txtcnt          s            200a
     d savts           s               z
     d svItem          s                   like(icitem)
     d svStk1          s                   like(iqstk1)
     d svStk2          s                   like(iqstk2)
     d svStk3          s                   like(iqstk3)
     d svTqh1          s                   like(ictqh1)
     d svTqh2          s                   like(ictqh2)
     d svTqh3          s                   like(ictqh3)
     d whs#            s              3  0
     d work3a          s              3
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $whse   Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
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

          // Get matching item quantity record
          chain (whs#: ititem) itemqty;
          if not %found(itemqty);
            iqstk1 = 0;
            iqstk2 = 0;
            iqstk3 = 0;
          endif;

          // Get matching import quantity record
          chain (whs#: ititem) impfcqty;
          if not %found(impfcqty);
            ictqh1 = 0;
            ictqh2 = 0;
            ictqh3 = 0;
          endif;

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
730aA       crtype = ittype;
            crwhdp = itwhdp;
            crdesc = itdesc;
            crdisp = sldisp;
            crbatch = $batch;
            craddts = savts;
            write wkrec;
            reccnt = reccnt + 1;
          endif;
        enddo;

        //Whip through the import item records and write ones with no itemqty
        setll (whs#) impfcqty;
        dow forever = forever;
          reade (whs#) impfcqty;
          error = *off;
          if %eof(impfcqty);
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
              reccnt = reccnt + 1;
            endif;
          endif;
        enddo;

        // All done, mark records as processed.
        txtcnt = %char(reccnt) + ' differences found.';
        exec sql
         update it981idx
            set cxtext = :txtcnt
          where cxbatch = :$batch;

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

      /free
        // Call program to get 11 digit batch id
        GetRecId(whs#: 'IT981IDX': recId);
        $batch = %trim(%char(recId));

        // Set batch status
        exec sql
          insert into it981idx
            values (:$whse,:$batch,:savts,'Processing...');
      /end-free

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC   Calculate differences between host and Dakota qty's
     *
     C     zzcalc        begsr
     *
CFIaAC*   Colony wants to ignore breakdown 2 differences
CFIaAC                   if        client = Colony
CFIaAC                   eval      ictqh3 = 0
CFIaAC                   eval      iqstk3 = 0
CFIaAC                   endif
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
     C                   kfld                    ilitm2
     *
     C     keyicreset    klist
     C                   kfld                    whs#
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

         setll (whs#) impfcqty;
         dow forever = forever;
           reade (whs#) impfcqty;
           if %eof(impfcqty);
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
     C     keyic         chain     impfcqty
     C                   if        %found(impfcqty)
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
     C                   endif                                                  Endif-Chain impfcqty
     *
     *      Re-position file pointer to next item, not parent.
     C     keyicreset    setgt     impfcqty
     *
     C                   endif                                                  Endif-Chain itemlnk
     *
     C                   enddo
     *
     C                   endsr
     *
