     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPD510RDB   Add REPORTS record RH182PR.
     *  23 Oct 2007
     *  Retha Davis
     *
510  *    10/23/07  RBD  5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Freports   uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D rpkey           s             10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      rpkey = 'RH182PR'

     C     rpkey         chain     reports
     C                   if        not %found
     C                   eval      rpprtf = 'RH182PR'
     C                   eval      rpdesc = 'Substitute Item label print'
     C                   eval      rptype = 'Label '
     C                   eval      rpdev  = '*JOB'
     C                   eval      rpform = 'LABEL'
     C                   eval      rpscrn = '2'
     C                   write     rprec                                79
     C                   endif

     C                   eval      *inlr = *on
     C                   return
