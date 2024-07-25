      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDITEMUPC   Create item number UPCs
     *  04 April 2021
     *  Dave Sommerville
     *
750  *    04/04/21  DAS  7.50
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fpiritem   if   e           k disk
     Fupc2      if   e           k disk    rename(uprec:uprec2)
     Fupc       o  a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd    *UPDATE
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pcmd             8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // No accidents

        if %parms < 1 or $pcmd <> '*UPDATE';
          dsply 'Invalid Command';
          return;
        endif;

        // Loop through Items

        dow forever = forever;

          read piritem;
          if %eof(piritem);
            leave;
          endif;

          // Only work with Normal items

          if ittype <> ' ';
            iter;
          endif;

          // Try creating UPC record with Item number as UPC code

          upwhse = itwhse;
          upitem = ititem;
          evalr upupc = %trim(ititem);

          chain (upwhse: upitem: upupc) upc2;
          if not %found(upc2);
            upuom = itum1;
            uputyp = 'N';
            upctyp = '6';
            write(e) uprec;
          endif;

          // Try creating UPC record for breakdown

          if itflg1 <> 'Y' or itum2 = '';
            iter;
          endif;

          upwhse = itwhse;
          upitem = ititem;
          evalr upupc = %trim(ititem) + 'EA';

          chain (upwhse: upitem: upupc) upc2;
          if not %found(upc2);
            upuom = itum2;
            uputyp = '1';
            upctyp = '6';
            write(e) uprec;
          endif;

        enddo;

      /end-free

