     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 West Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR331     Order Lookup by Item - Selection
     *  Ginger Andrews
     *
     *  Revisions
     *
     *    03/10/08  GJA  P#00023  5.20
     *      - Creation
710aA*    09/19/17  JCJ  7.10a
     *      - Renamed to OR331
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehedh   if   e           k disk    rename(rhrec:rhrech)
     Flabelh    if   e           k disk    rename(lbrec:lbrech)
     Fordhh     if   e           k disk    rename(ohrec:ohrech)
     Frtehed2   if   e           k disk
     Flabel14   if   e           k disk
     Fordh      if   e           k disk
     For330     o  a e           k disk
     *----------------------------------------------------------------
     *
     *  Program parameters
     *
     *
     *----VARIABLES---------------------------------------------------
     *Work fields
     D $whsea          s              3
     D $from           s              8
     D $to             s              8
     D $item           s             15
     D $prtn           s              8
     D whse            s              3  0
     D tdte            s              8  0
     D fdte            s              8  0
     D item            s             15
     D stop            s              1
     D first           s              1
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE  - Warehouse
     *      $ITEM  - Item
     *      $RTNCD - Return code
     *
     *    Returned Parameters
     *      None
     *
     C     *entry        plist
     C                   parm                    $whsea
     C                   parm                    $item
     C                   parm                    $from
     C                   parm                    $to
     C                   parm                    $prtn
     *----------------------------------------------------------------
     *  Main line
     *  Write entered item to work file
     *
     C                   move      $whsea        whse
     C                   move      $from         fdte
     C                   move      $to           tdte
     C                   move      $item         item
     *  Routine to get data from current files
     C                   exsr      @route
     C                   DoU       sqlstt = '02000'
     C                   exsr      @fetch
     C                   if        sqlstt = '02000'
     C                   Leave
     C                   endif
     C                   write     wkrec
     C                   enddo
     C                   exsr      @close
     *  Routine to get data from history files
     C                   exsr      @hroute
     C                   DoU       sqlstt = '02000'
     C                   exsr      @hfetch
     C                   if        sqlstt = '02000'
     C                   Leave
     C                   endif
     C                   write     wkrec
     C                   enddo
     C                   exsr      @hclose
     C                   eval      *inlr=*on
     C                   return
     *
     *****************************************************************
     *
     *
     C     @route        BEGSR
     C/EXEC SQL
     C+ Declare rteCursor cursor
     C+   for SELECT RHIMPD,OHORD,OHCORD,OHCUST,OHCNAM,LBQPCK,LBLBL#,
     C+              LBRTE,LBTRN#
     C+       from RTEHED2, LABEL14, ORDH
     C+            where RTEHED2.RHSTAT = '6'              and
     C+                  rhimpd BETWEEN :fdte AND :tdte    and
     C+                  rtehed2.RHWHSE = :whse            and
     C+                  RTEHED2.RHWHSE = LABEL14.LBWHSE   and
     C+                  RTEHED2.RHRTID = LABEL14.LBRTE    and
     C+                  LABEL14.LBITEM = :item            and
     C+                  ORDH.OHWHSE    = LABEL14.LBWHSE   and
     C+                  ORDH.OHORD     = LABEL14.LBORD
     C+       ORDER by OHCUST,RHIMPD,OHCORD
     C/END-EXEC
     C/Exec Sql
     C+ Open rteCursor
     C/END-EXEC
     C                   ENDSR
     *****************************************************************
     *
     *
     *
     C     @Close        BEGSR
     C/Exec Sql
     C+ Close rteCursor
     C/END-EXEC
     C                   ENDSR
     *****************************************************************
     *
     *
     C     @Fetch        BEGSR
     C/Exec Sql
     C+ FETCH NEXT
     C+   From rteCursor
     C+   into :WKIMPD,:WKORD,:WKCORD,:WKCUST,:WKCNAM,:WKQPCK,
     C+        :WKLBL#,:WKRTE,:WKTRN#
     C/END-EXEC
     C                   ENDSR
     *
     *****************************************************************
     *
     *
     C     @hroute       BEGSR
     C/EXEC SQL
     C+ Declare HrteCursor cursor
     C+   for SELECT RHIMPD,OHORD,OHCORD,OHCUST,OHCNAM,LBQPCK,LBLBL#,
     C+              LBRTE,LBTRN#
     C+       from RTEHEDH, LABELH, ORDHH
     C+            where RTEHEDH.RHSTAT = '6'              and
     C+                  rhimpd BETWEEN :fdte AND :tdte    and
     C+                  rtehedH.RHWHSE = :whse            and
     C+                  RTEHEDH.RHWHSE = LABELH.LBWHSE    and
     C+                  RTEHEDH.RHRTID = LABELH.LBRTE     and
     C+                  LABELH.LBITEM  = :item            and
     C+                  ORDHH.OHWHSE   = LABELH.LBWHSE    and
     C+                  ORDHH.OHORD    = LABELH.LBORD
     C+       ORDER by OHCUST,RHIMPD,OHCORD
     C/END-EXEC
     C/Exec Sql
     C+ Open HrteCursor
     C/END-EXEC
     C                   ENDSR
     *****************************************************************
     *
     *
     *
     C     @HClose       BEGSR
     C/Exec Sql
     C+ Close HrteCursor
     C/END-EXEC
     C                   ENDSR
     *****************************************************************
     *
     *
     C     @HFetch       BEGSR
     C/Exec Sql
     C+ FETCH NEXT
     C+   From HrteCursor
     C+   into :WKIMPD,:WKORD,:WKCORD,:WKCUST,:WKCNAM,:WKQPCK,
     C+        :WKLBL#,:WKRTE,:WKTRN#
     C/END-EXEC
     C                   ENDSR
     *
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   eval      first = *on
     C                   eval      stop = *off
     C                   endsr
     *----------------------------------------------------------------
     *****************************************************************
     *
