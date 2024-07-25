650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS756      Clean up PGMTRCK records
     *  09 September 2014
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    09/09/14  LMC   6.50a
     *      - Created
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpgmtrck   uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D curdate         s               d
     D $dtetme         s               z
     D dtetme          s             26
     D kywhse          s              3  0
     D chkwks          s              3  0
     D chkdays         s              4  0
     D chkymd          s              8  0
     D forevr          s              1
     *  Main line
     *----------------------------------------------------------------

     c     forevr        doweq     forevr
     C                   read      pgmtrck
     c                   if        %eof(pgmtrck)
     c                   leave
     c                   endif

     C                   if        pgtstrts > $dtetme
     c                   iter
     C                   endif

     C                   if        pgtstrts < $dtetme
     c                   delete    pgtrec
     C                   endif
     c                   enddo

     *  End of file
     C                   eval      *inlr = *On
     C                   return
     *--------------------------------------------------------------
     *  *INZSR
     C     *inzsr        begsr
     *
     C                   eval      forevr = *on

     C                   eval      curdate = %date()
     C                   eval      chkdays = chkwks * 7
     C                   eval      curdate = curdate - %days(7)
     c                   move      curdate       chkymd
     C                   eval      $dtetme= %timestamp(%char(curdate) +
     C                                     '-00.00.00.000000')
     C                   endsr
