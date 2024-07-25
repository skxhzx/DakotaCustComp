      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LT002       Set item license tracking flag
     *  01 March 2009
     *  Dave Sommerville
     *
600 A*    03/01/09  DAS  6.00   P#00045
     *      - Created
     *
720aA*    06/27/16  LMC  7.20a
     *      - UCI Tracking - New Item tracking level 'U'
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  *LICENSE  -  License Plate Tracking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLPTR  -  Allow license plate tracking.  (Y/N)
     *    OPLPAL  -  Track All items.  (Y/N)
     *    OPLPDS  -  Track All date sensitive items.
     *    OPLPLC  -  Track All lot code items.  (Y/N)
     *    OPLPCW  -  Track All catchweight items.  (Y/N)
417aA*    OPTKSP  -  Track push back slot positions. (Y/N)
     *
     * Data structure
     *
     D opdata          ds
     D  oplptr                 1      1
     D  oplpal                 2      2
     D  oplpds                 3      3
     D  oplplc                 4      4
     D  oplpcw                 5      5
417aAD  optksp                 6      6
     D  optend               117    117

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D e$whse          s              3  0

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pCmd    -  *ALL     -  Update all item records
     *                  *INVALID -  Fix rec with invalid code
     *      $pWhse   -  Warehouse
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd             8
     C                   parm                    $pWhse            3 0
     C                   parm                    $pDummy           1

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         // Ensure program was called from CL program, not from command.

         $pDummy = $pDummy;

         // Get license tracking options.

         chain ($pwhse: '*LICENSE') options;
         if not %found(options);
           return;
         endif;

         // Set license tracking flags

         select;

           // When setting flag for all items (overwriting existing flags),
           //   First set all items to 'Other' flag.
           //   Then set Medium Date/CWgt/Lot flags.
           //   Then set High Date/CWgt/Lot flags.

           when $pcmd = '*ALL';
             exsr setAllAll;
             if oplpds = 'M';
               exsr setDateAll;
             endif;
             if oplpcw = 'M';
               exsr setCwgtAll;
             endif;
             if oplplc = 'M';
               exsr setLotAll;
             endif;
             if oplpds = 'H';
               exsr setDateAll;
             endif;
             if oplpcw = 'H';
               exsr setCwgtAll;
             endif;
             if oplplc = 'H';
               exsr setLotAll;
             endif;

           // When setting invalid flags,
           //   First, set High Date/CWgt/Lot flags.
           //   Then set Medium Date/CWgt/Lot flags.
           //   Than set remaining invalid flags to 'Other' flag.

           when $pcmd = '*INVALID';
             if oplpds = 'H';
               exsr setDateInvld;
             endif;
             if oplpcw = 'H';
               exsr setCwgtInvld;
             endif;
             if oplplc = 'H';
               exsr setLotInvld;
             endif;
             if oplpds = 'M';
               exsr setDateInvld;
             endif;
             if oplpcw = 'M';
               exsr setCwgtInvld;
             endif;
             if oplplc = 'M';
               exsr setLotInvld;
             endif;
             exsr setAllInvld;

         endsl;

         *inlr = *on;
         return;

      /end-free

     *----------------------------------------------------------------
     *  setAllAll   Set tracking flag for all items
     *              overwriting any existing tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setAllAll;

         exec sql update itemmsc
                  set imltrk = :oplpal
                  where imwhse = :$pwhse;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setAllInvld   Set tracking flag for all items
     *                that currently have an invalid tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setAllInvld;

         exec sql update itemmsc
                  set imltrk = :oplpal
                  where imwhse = :$pwhse
720aD               //and imltrk not in ('L','M','H');
720aM               and imltrk not in ('L','M','H','U');

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setDateAll   Set tracking flag for all date sensitive items
     *               overwriting any existing tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setDateAll;

         exec sql update itemmsc
                  set imltrk = :oplpds
                  where imwhse = :$pwhse
                    and exists (select itflgd
                                from piritem
                                where itwhse = imwhse
                                  and ititem = imitem
                                  and itflgd = 'Y');

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setDateInvld   Set tracking flag for date sensitive items
     *                 that currently have an invalid tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setDateInvld;

         exec sql update itemmsc
                  set imltrk = :oplpds
                  where imwhse = :$pwhse
720aD               //and imltrk not in ('L','M','H')
720aM               and imltrk not in ('L','M','H','U')
                    and exists (select itflgd
                                from piritem
                                where itwhse = imwhse
                                  and ititem = imitem
                                  and itflgd = 'Y');

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setCwgtAll   Set tracking flag for all catchweight items
     *               overwriting any existing tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setCwgtAll;

         exec sql update itemmsc
                  set imltrk = :oplpcw
                  where imwhse = :$pwhse
                    and exists (select itcwgt
                                from piritem
                                where itwhse = imwhse
                                  and ititem = imitem
                                  and itcwgt = 'Y');

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setCwgtInvld   Set tracking flag for catchweight items
     *                 that currently have an invalid tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setCwgtInvld;

         exec sql update itemmsc
                  set imltrk = :oplpcw
                  where imwhse = :$pwhse
720aD               //and imltrk not in ('L','M','H')
720aM               and imltrk not in ('L','M','H','U')
                    and exists (select itcwgt
                                from piritem
                                where itwhse = imwhse
                                  and ititem = imitem
                                  and itcwgt = 'Y');

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setLotAll   Set tracking flag for all lot code items
     *              overwriting any existing tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setLotAll;

         exec sql update itemmsc
                  set imltrk = :oplplc
                  where imwhse = :$pwhse
                    and imlot = 'Y';

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setLotInvld   Set tracking flag for lot code items
     *                that currently have an invalid tracking flag.
     *----------------------------------------------------------------

      /free
       begsr setLotInvld;

         exec sql update itemmsc
                  set imltrk = :oplplc
                  where imwhse = :$pwhse
720aD               //and imltrk not in ('L','M','H')
720aM               and imltrk not in ('L','M','H','U')
                    and imlot = 'Y';

         sqlstt = sqlstt;

       endsr;
      /end-free
