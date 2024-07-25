     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UPD416DSB   Add Report record.
     *  03 October 2001
     *  Dave Sommerville
     *
416  *    10/03/01  DAS  4.16
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

     C                   eval      rpprtf = 'EX126PR'
     C                   eval      rpdesc = 'Receiving Exceptions Report'
     C                   eval      rptype = 'Report'
     C                   eval      rpdev  = '*JOB'
     C                   eval      rpform = '*STD'
     C                   eval      rpscrn = '1'

     C                   write     rprec                                79

     C                   eval      *inlr = *on
     C                   return
