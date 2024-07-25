     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDORDDM     Remove transactions from ORDDM
     *  26 November 2009
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    11/26/09  GJA  6.00
     *      - Created.
     *----------------------------------------------------------------
     * Indicators
     *
     *  49        - Error trying to delete a record.
     *  79        - Record not found or EOF.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Forddm     up   e             disk
     Fordh      if   e           k disk
     *----------------------------------------------------------------
     * Main line
     *
     * Check to see if we can delete this transaction.
     *
     C     keyordh       klist
     C                   kfld                    omwhse
     C                   kfld                    omord
     C     keyordh       chain     ordh
     *    If Transaction no longer on file, remove from file.
     C                   if        not %found(ordh)
     *
     C                   delete    omrec
     *
     C                   endif
     CLR                 return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
