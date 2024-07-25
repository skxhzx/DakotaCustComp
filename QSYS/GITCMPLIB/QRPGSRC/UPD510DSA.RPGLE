     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPD510DSA   Add Report record.
     *  25 May 2007
     *  Dave Sommerville
     *
510  *    05/25/07  DAS  5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Freports   o    e           k disk

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      rpprtf = 'EX176PR'
     C                   eval      rpdesc = 'Runner Exceptions Report'
     C                   eval      rptype = 'Report'
     C                   eval      rpdev  = '*JOB'
     C                   eval      rpform = '*STD'
     C                   eval      rpscrn = '1'

     C                   write     rprec                                79

     C                   eval      *inlr = *on
     C                   return
