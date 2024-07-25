      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPD710RDA   QD to close LABEL records whose transaction is
     *              status = '4' and task = 'PUTRTN' and generated
     *              date is < 20170101. And of course only do this
     *              for LABEL records not already closed.
     *
     *  10 July 2017
     *  Retha Davis
     *
710a *    07/10/17  RBD  7.10a
     *      - Created
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Flabel     uf   e           k disk
     fpirtran   if   e           k disk
     Fupd710rdapo    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     d forever         s               n
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        dow forever = forever;
          read label;
          if %eof(label);
            *inlr = *on;
            leave;
          endif;

          // bypass closed LABEL records
          if lbstat = 'C';
            iter;
          endif;

          // get transaction & update label if criteria met
          chain (lbtrn#) pirtran;
          if %found(pirtran) and ptgdte<20170101 and pttask='PUTRTN'
                             and ptstat='4' and ptwhse=lbwhse;
            lbstat = 'C';
            count = count + 1;
            update lbrec;
          endif;
        enddo;
        write head1;
        write total1;
      /end-free

