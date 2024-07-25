      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT972S   Staging Item Quantity Compare Report - Print
     *  11 November 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
700  *    11/11/15  RTR  7.00
     *      - Created from IT971.
700a *    06/28/16  RTR  7.00a
     *      - Enh: Added conversion for host breakdown qty to roll up
     *        to higher UOM if necessary.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpscqty  uf a e           k disk
     Fitemqty   if   e           k disk
     fitemlnk   if   e           k disk
     fitemlnk1  if   e           k disk    usropn
     f                                     rename(ilrec:ilrec1)
     Fpiritem1  if   e           k disk
     Fpiritem   if   e           k disk
     f                                     prefix(i2)
     f                                     rename(itrec:itrec2)
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Fslot3     if   e           k disk
     Fpodtl     if   e           k disk
     Fit971pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Customer ids
      /copy qcopysrc,id#glazier
      /copy qcopysrc,id#icb
      /copy qcopysrc,id#gmm
      /copy qcopysrc,id#gmmvini
      /copy qcopysrc,ipqmem_gmm
      /copy qcopysrc,id#hkw
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     D desc            s             60    dim(2) ctdata perrcd(1)
     *
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
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------
     d prCvtBrkQty     pr
     d  gbrkpct                       7s 3 const
     d  gipqqp1                       7s 0
     d  gipqqp2                       7s 0
     d  gadjitm                      15a

     *----------------------------------------------------------------
     *  Working Variables
     *
     D addflg          s              1
     D chgflg          s              1
     d clen            s             15p 5
     d cmd             s           3000a
     d len             s              1p 0
     D count           s              3  0
     D first           s              1
     D grdord          s              5  0
     D k3pick          s              1
     D k3stat          s              2
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     d svUmq2          s                   like(itumq2)
     d svUmq3          s                   like(itumq3)
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
     *      $CMD    *EXCPTN - Print only exceptions
     *      $WHSE   Warehouse
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
     * Look for Alias or SSB items, and add qty to parent item.
     C                   exsr      zzrollupHost
700aA* Roll up extra breakdown 2 units to normal UOM
700aAC                   exsr      zzuomfix
     *
     * Whip through all the Itemqty records
     *
     C                   eval      first = *on
     C     whs#          setll     itemqty
     C                   dow       forever = forever
     *
     C     whs#          reade     itemqty
     C                   eval      error = *off
     C                   if        %eof(itemqty)
     C                   leave
     C                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *  Get matching import quantity record
     *
     C     keyiq         chain     impscqty
     C                   if        not %found(impscqty)
     C                   eval      ictqh1 = 0
     C                   eval      ictqh2 = 0
     C                   eval      ictqh3 = 0
     C                   endif
     *
     *  Calculate differences between host and Dakota qty's
     *  If no differences, don't print
     *
     C                   exsr      zzcalc
     C                   if        diff1 = 0 and diff2 = 0
     C                             and diff3 = 0
     C                   goto      skipiq
     C                   endif
     *
     *  Get item description
     *
     C     keyit1        chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = ' '
     C                   eval      itwhdp = ' '
     C                   endif
     *
     *  Omit items for non-active departments
     C                   if        client = Glazier
     *
     C                   call      'CHKLIVE'
     C                   parm      whs#          $cwhse            3 0
     C                   parm                    itwhdp
     C                   parm                    livestat          8

     *  If department is not live, then read next item.

     C                   if        livestat = '*NOTLIVE'
     C                   Iter
     C                   Endif
     *
     C                   endif
     *
     *  Get pick slot
     *
     C                   eval      k3pick = 'Y'
     C                   eval      k3stat = 'A '
     C     keysl         chain     slot3
     C                   if        not %found(slot3)
     C                   eval      sldisp = *blanks
     C                   endif
     *
     *  Write detail
     *
     C                   if        *in91 = '1'
     C                   write     head1                                91
     C                   endif
     C                   write     detail                               91
     *
     C     skipiq        tag
     C                   enddo
     *
     * Whip through the import item records and print those with no
     * match to itemqty
     *
     C                   eval      first = *on
     C     keyiq2        setll     impscqty
     C                   dow       forever = forever
     *
     C     keyiq2        reade     impscqty
     C                   eval      error = *off
     C                   if        %eof(impscqty)
     C                   leave
     C                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz3
     C                   eval      first = *off
     C                   endif
     *
     *  Look for matching itemqty record, if not found, print exception
     *
     C     keyit2        chain     itemqty
     C                   if        not %found(itemqty)
     C                   if        *in91 = '1'
     C                   write     head2                                91
     C                   endif
     C                   write     detail2                              91
     C                   endif
     *
     C                   enddo
     *
     *  Print grand totals
     *
     C                   if        *in91 = *on
     C                   write     head1                                91
     C                   endif
     C                   write     foot1                                91
      /free
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
          cmd = 'SNDMSG MSG('+ sq + 'ERROR: IT972S Comparison Report '
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
        endif;
      /end-free
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
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
     *  Variables and constants.
     *
     C                   eval      forever = *off
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     *
     C                   eval      $lprg = #prog
     C                   move      $whse         whs#
     C                   monitor
     C                   eval      whs# = %dec($whse: 3: 0)
     C                   on-error
     C                   eval      error = *on
     C                   eval      *in91 = *on
     C                   endmon
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
     C     keyit1        klist
     C                   kfld                    whs#
     C                   kfld                    iqitem
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
     C     keyiq         klist
     C                   kfld                    whs#
     C                   kfld                    $batch
     C                   kfld                    iqitem
     *
     C     keyiq2        klist
     C                   kfld                    whs#
     C                   kfld                    $batch
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
     C     keysl         klist
     C                   kfld                    whs#
     C                   kfld                    iqitem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'IT971PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = desc(1)
     C                   endif
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     whs#          chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      whs#          work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     *   Write headings
     *
     C                   write     head1
     *
     *   Get options.
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ3   Program initialization. Called from main line.
     *
     C     zzinz3        begsr
     *
     * Get report heading.
     *
     C                   eval      w2head = *blanks
     C                   eval      $pstr = desc(2)
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w2head
     *
     *   Write headings
     *
     C                   write     head2
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZROLLUPHOST   Roll-up Qty's sent for Alias or SSB items into Parent.
     *
     C     zzrollupHost  begsr
     *
     C     whs#          setll     impscqty
     C                   dow       forever = forever
     C     whs#          reade     impscqty
     C                   if        %eof(impscqty)
     C                   leave
     C                   endif
700aAC                   if        icbatid <> $batch
700aAC                   iter
700aAC                   endif
     *
     C     keyit2        chain     piritem
     C                   select
     C                   when      %found(piritem)
     C                             and client = Hearnkirkwood
     C                             and i2ittype = ' '
     *      Wrong item type, read next record.
     *      Allow type A, B or S items to be processed.
     C                   iter
     *
     C                   when      %found(piritem)
     C                             and client = Hearnkirkwood
     C                             and (i2ittype = 'A'
     C                               or i2ittype = 'B'
     C                               or i2ittype = 'S')
     *      Allow type A, B or S items to be processed.
     *
     *      Wrong item type, read next record.
     C                   when      %found(piritem)
     C                             and i2ittype <> 'A'
     C                             and i2ittype <> 'S'
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
     C                   when         i2ittype = 'S'
     C                             or i2ittype = 'B'
     C                   eval      ictqh2 = ictqh2 + svtqh1
     C                   other
     C                   eval      ictqh1 = ictqh1 + svtqh1
     C                   eval      ictqh2 = ictqh2 + svtqh2
     C                   eval      ictqh3 = ictqh3 + svtqh3
     C                   eval      ictext = 'Breakdown rollup from IT972S'
     C                   endsl
     C                   update    icrec
     *
     C                   else
     *
     *      Parent/base item not in import file. Add record.
     C                   eval      icwhse = whs#
     C                   eval      icitem = ilitm2
     C                   select
     C                   when         i2ittype = 'S'
     C                             or i2ittype = 'B'
     C                   eval      ictqh1 = 0
     C                   eval      ictqh2 = svtqh1
     C                   eval      ictqh3 = 0
     C                   other
     C                   eval      ictqh1 = svtqh1
     C                   eval      ictqh2 = svtqh2
     C                   eval      ictqh3 = svtqh3
     C                   endsl
     C                   eval      ictext = 'Missing Parent created by IT972S'
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
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZUOMFIX       Roll-up Breakdown qtys if greater than UOM breakdown.
700aA*
700aAC     zzuomfix      begsr
700aA*
700aAC     whs#          setll     impscqty
700aAC                   dow       forever = forever
700aAC     whs#          reade     impscqty
700aAC                   if        %eof(impscqty)
700aAC                   leave
700aAC                   endif
700aAC                   if        icbatid <> $batch
700aAC                   iter
700aAC                   endif
700aA*
700aAC                   if        ictqh2 <> 0
700aA
700aAC     keyit2        chain     piritem
700aAC                   if        %found(piritem)
700aAC                             and i2ittype <> ' '
700aAC                   iter
700aAC                   endif
700aA*
700aAC                   dow       ictqh2 >= i2itumq2
700aAC                             and i2itumq2 > 0
700aAC                   eval      ictqh1 = ictqh1 + 1
700aAC                   eval      ictqh2 = ictqh2 - i2itumq2
700aAC                   enddo
700aA*
700aAC                   eval      ictext = 'UOM fix from IT972S'
700aAC                   update    icrec
700aA*
700aAC                   endif
700aAC                   enddo
700aA*
700aAC                   endsr
700aA*
     *----------------------------------------------------------------*********
     *
     *  Compile Time Tables
     *
**
Item Quantity Compare Report
Item Quantity Compare Report: Host Items Not Found On Dakota
