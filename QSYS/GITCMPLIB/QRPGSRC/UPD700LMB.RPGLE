      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPD700LMB   QD to set new UPC field defaults to normal UOM
     *  17 November 2016
     *  Lynn McMahon
     *
700a *    11/17/16  LMC  7.00a
     *      - Created
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Fupc       uf   e           k disk
     fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#CVTPARMS
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtbar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     d forever         s               n
     D sq              c                   Const('''')
     D Ntype           s              7
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free
        dow forever = forever;
          read upc;
          if %eof(upc);
            *inlr = *on;
            leave;
          endif;

          // bypass records that have already been updated with new fields
          if upuom <> ' ';
            iter;
          endif;
          if upwhse = 0;
            iter;
          endif;
          // let send into cvtbar to set upctyp field
          cvtbar('*UPC': upupc:
                $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
                $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
          if $cbrtn = '*OK';
            ntype = %trimr($cbdsc);
          else;
            ntype = ' ';
          endif;
          // get the normal uom for the item
          if upuom = ' ';
            chain (upwhse: upitem) piritem;
            if %found(piritem);
              upuom = itum1;
            endif;
          endif;
          // set uom type to normal if it is blank
          if uputyp = ' ';
            uputyp = 'N';
          endif;
          if upctyp = ' ';
            Select;
              when ntype = 'UPC-12';
                upctyp = '1';
              when ntype = 'EAN-13';
                upctyp = '2';
              when ntype = 'GTIN';
                upctyp = '3';
              when ntype = 'SCC-14';
                upctyp = '4';
              when ntype = 'SSCC-18';
                upctyp = '5';
              other;
                upctyp = '6';
            endsl;
          endif;
          update uprec;
        enddo;
      /end-free

