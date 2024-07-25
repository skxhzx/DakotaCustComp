     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDFLGTRAN   Remove transactions from FLGTRAN
     *  22 November 2009
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    11/22/09  GJA  6.00
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
     Fflgtran   up   e             disk
     Fpirtran   if   e           k disk
     *----------------------------------------------------------------
     * Main line
     *
     * Check to see if we can delete this transaction.
     *
     C     fgtrn#        chain     pirtran
     *    If Transaction no longer on file, remove from file.
     C                   if        not %found(PIRTRAN)
     *
     C                   delete    fgrec
     *
     C                   endif
     CLR                 return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
