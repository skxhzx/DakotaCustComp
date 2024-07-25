     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT736A    FTP Export item qty - Closed pick not exported
     *  08 November 2011
     *  Roxanne Harrison
     *
     *  This program will add records to EXPFLCNS file for orders picked
     *  and not yet exported to host.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*   01/05/11  MLB  6.40
     *      - Enh: Added 1 new field to file, EXPFLCNS. Pgm recompiled.
     *        No changes made to this program.
     *
750 A*   03/03/22  MLB  7.50  ZD# 6766
     *      - Enh: Revised pgm to include routes that are at Closed
     *        status as well as Printed status. EI is leaving routes
     *        at Closed status for more than a few hrs, causing descrep-
     *        ancies on the Host side.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  74        NRF on chain to VSLOT1
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehed3   if   e           k disk
     Fpirtran4  if   e           k disk
     Flabel90   if   e           k disk
     Fordh      if   e           k disk
     Fexpflcns  uf a e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
EI A  /COPY QCOPYSRC,ID#EI
     D                 ds
     D  client                 1     10
     D  clientloc             11     20
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D chk4err         s               n
     D error           s               n
     D forevr          s              1
     D kyrtpo          s                   like(ptrtpo)
     D kystat          s                   like(rhstat)
     D tryonce         s              1    inz('0')
     D wkdisp          s             12
     D wklcns          s             15
     D wkqty           s                   like(lbqpck)
     D zmsflag         s               n
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #pgm             *proc
     D  #prog            *proc
     D  #job                 244    253
     D  #jobn                244    253
     D  #user                254    263
     D  #curruser            254    263
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE   Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *  Set beginning limits on appropriate file.
     *
     C                   eval      kystat = '4'
     C     keyrth        setll     rtehed3
     *
     *  Loop through Printed routes.
     *
     C                   dou       forevr <> forevr
750 DC*    keyrth        reade     rtehed3
750 MC     $pwhse        reade     rtehed3
     *
     *    Get out if EOF or Status not '4'
750 A*    or '5' Closed status.
     *
     C                   if        %eof(rtehed3)
750 AC                             or rhstat > '5'
     C                   leave
     C                   endif
     *
     *    Only process Normal or Will Call Routes.
     *
     C                   if        rhtype <> ' ' and
     C                             rhtype <> 'W'
     C                   iter
     C                   endif
     *
     *    Process Closed transactions for route
     *
     C                   movel     rhrtid        kyrtpo
     C     keytrn        setll     pirtran4
     C                   dou       forevr <> forevr
     C     keytrn        reade     pirtran4
     *    Get out if EOF
     C                   if        %eof(pirtran4)
     C                   leave
     C                   endif
     *    Only process closed transactions
     C                   if        ptstat <> '4'
     C                   iter
     C                   endif
     *
     *    Get Label records for transaction
     C     keylbl        setll     label90
     C                   dou       forevr <> forevr
     C     keylbl        reade     label90
     *    Get out if EOF
     C                   if        %eof(label90)
     C                   leave
     C                   endif
     *    Only process Picking labels
     C                   if        lbtype <> 'O' and
     C                             lbtype <> 'B'
     C                   iter
     C                   endif
     *
     *    Get Customer Order #
     C     keyoh         chain     ordh
     C                   if        not %found(ordh)
     C                   iter
     C                   endif
     *
     *    Record ok for export
     C                   exsr      zzexpl
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     *  Get client id
     *
     C                   call      @getcl
     C                   parm                    client
     *
     *
     *  Define key for RTEHED3 file.
     *
     C     keyrth        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat
     *
     *  Define key for PIRTRAN4 file.
     *
     C     keytrn        klist
     C                   kfld                    $pwhse
     C                   kfld                    rhtype
     C                   kfld                    kyrtpo
     *
     *  Define key for LABEL90 file.
     *
     C     keylbl        klist
     C                   kfld                    $pwhse
     C                   kfld                    pttrn#
     *
     *  Define key for ORDH file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbord
     *
     *  Define key for EXPFLCNS file.
     *
     C     keyex         klist
     C                   kfld                    $pwhse
     C                   kfld                    lbwhdp
     C                   kfld                    wkdisp
     C                   kfld                    wklcns
     C                   kfld                    lbitem
     *
     *
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXPL     Write Export license info for closed picking.
     *
     C     zzexpl        begsr
     *  Build key for EXPFLCNS
     C                   eval      wkdisp = %editc(ohcord : 'X')
     C                                    + %editc(lbseq : 'X')
     C                   eval      wklcns = 'CLOSEDTRAN     '
     *
     C     keyex         chain     expflcns
     C                   if        %found(expflcns)
     C                   eval      wkqty = 0
     C                   select
     C                   when      lbutyp = 'N'
     C                   move      elaqt1        wkqty
     C     wkqty         add       lbqpck        wkqty
     C                   evalr     elaqt1 = %trimr(%editc(wkQty:'L'))
     C**   elaqt1        add       lbqpck        elaqt1
     C                   when      lbutyp = '1'
     C                   move      elaqt2        wkqty
     C     wkqty         add       lbqpck        wkqty
     C                   evalr     elaqt2 = %trimr(%editc(wkQty:'L'))
     C                   when      lbutyp = '2'
     C                   move      elaqt3        wkqty
     C     wkqty         add       lbqpck        wkqty
     C                   evalr     elaqt3 = %trimr(%editc(wkQty:'L'))
     C                   endsl
     C                   update    elarec
     C                   else
     *  Now process the information and load export file fields       .

     C                   clear                   elarec
     C                   eval      elawhs = lbwhse
     C                   eval      elawhd = lbwhdp
     C                   eval      elastp = lbstyp
     C                   eval      elaasl = lbaisl
     C                   eval      elaloc = lbloc
     C                   eval      elalvl = lbrlvl
     C                   eval      elahnd = lbhand
     C                   eval      eladsp = wkdisp
     C                   eval      elaitm = lbitem
     C*                  eval      elaqt1 = 0
     C*                  eval      elaqt2 = 0
     C*                  eval      elaqt3 = 0
     C                   select
     C                   when      lbutyp = 'N'
     C                   evalr     elaqt1 = %trimr(%editc(lbqpck:'L'))
     C**                 eval      elaqt1 = lbqpck
     C                   when      lbutyp = '1'
     C                   evalr     elaqt2 = %trimr(%editc(lbqpck:'L'))
     C                   when      lbutyp = '2'
     C                   evalr     elaqt3 = %trimr(%editc(lbqpck:'L'))
     C                   endsl
     *
     C                   eval      elalcn = wklcns
     C*                  eval      elaolc = laOLcns
     C*                  eval      elaent = laentd
     C*                  eval      elaexp = laexpd
     *     PO number
     C                   eval      elapo = ' '
     C                   eval      elapos = 0
     *     Lot Code
     C                   eval      elalot = ' '
     *
     C                   eval      eladsg = *blanks
     C                   eval      elapck = *blanks
     *
     C                   write (e) elarec
     C                   endif
     *
     C     endexpl       endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------
