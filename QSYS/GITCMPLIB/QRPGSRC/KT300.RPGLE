     H option(*NODEBUGIO)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  KT300     Print Repack ODR Conversion Report
     *  27 March 2015
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  03/27/15  KDE  6.50
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fkitcomp   uf   e           k disk
     fkititem   uf   e           k disk
     fpiritem   if   e           k disk
     fslot11    uf   e           k disk
     fslot2     uf   e           k disk    rename(slrec:slrec2)
     f                                     prefix(o_)
     fitemdsc   if   e           k disk
     fkt300pr   o    e             printer oflind(*in90)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     d desc            s             40    dim(15) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d forever         s              1    inz('1')
     d #pwhse          s              3  0
     d updKit          s               n
     d active          s              3  0
     d rdate           s              6  0
     d rtime           s              6  0
     d hmsmdy          s             12  0
     d whse            s             30
     d wktote          s              5  0
     d wkrerr          s             70


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Warehouse
     *     -Department
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     *----------------------------------------------------------------     ****
     C     *entry        plist
     C                   parm                    $pwhse            3
      /free
         exsr init;
         // loop through Slot file looking for rows 40-43.  For conversion
         // purposes Max has loaded all slots in SLOT file with "RX" status
         // if stuffer item is a type "R"
         setll (#pwhse) slot11;
         reade (#pwhse) slot11;
         dow not %eof(slot11);
            updKit = *off;
            // only review knew slots from slot stuffer flagged as RX status
            if slstat='RX';
               wkrerr = *blanks;
              // The On Demand slots sent by Greenleaf have the actual
              // Repack item in the slot.  We need to read the kitcomp
              // record to retrieve the parent and place the parent in
              // the slot sent, update the status to "RP", update the
              // on demand slot in both KITCOMP and KITITEM and lastly
              // remove the case item from the old slot found in KITCOMP
              // as long as the status is "Z" and the quantity is zero.
              // if the status is not "Z" and the quantity is not zero
              // then leave associated and throw error so user knows to
              // correct.
              setll (slwhse:slitem) kitcomp;
              reade (slwhse:slitem) kitcomp;
              dow %equal(kitcomp) and not %eof(kitcomp);
                 // locate and update kititem record
                 chain (slwhse:kcitem) kititem;
                 if %found(kititem);
           //       if kidisp<>sldisp;
                      // parent item assigned to multiple slots.  Correct in Slo
           //          wkrerr = '** Parent assigned multiple slots ' +
           //             %trim(kccitm);
           //             updKit = *off;
           //             exsr detailline;
           //             unlock kititem;
           //       else;
                       // either remove parent item from old on demand slot
                       // or throw error because slot it not empty
                       if kidisp <> sldisp;
                          chain (slwhse:slwhdp:kidisp) slot2;
                          if %found(slot2);
                             if o_slstk1<>0 or o_slstk2<>0 or o_slstk3<>0;
                                wkrerr = '** Error ** Old on demand RP slot' +
                                ' ' + %trim(kidisp) + ' not empty';
                                exsr detailline;
                                unlock slot2;
                             else;
                                o_slitem = *blanks;
                                o_slstat = 'Z ';
                                update slrec2;
                             endif;
                          else;
                             wkrerr = '** Error ** ' +
                             'Old on demand RP slot not found ' +
                             %trim(kidisp) + ' Item, ' + %trim(kiitem);
                             exsr detailline;
                             unlock slot2;
                          endif;
                          updKit = *on;
                          kidisp = sldisp;
                          update kirec;
                       endif;
       //           endif;
                 else;
                    wkrerr = '** Error ** Kit Item record not found ' +
                          %trim(kcitem);
                    exsr detailline;
                 endif;
                 // if kititem updated then update kitcomp and slot files
                 if updKit;
                    kcdisp = sldisp;
                    update kcrec;
                    slstat = 'RY';
                    slitem = kccitm;
                    update slrec;
                    wkrerr = '** Info ** Kit parent ' + %trim(kccitm) +
                          ' updated to slot ' + %trim(sldisp);
                    exsr detailline;
                 endif;
                 reade (slwhse:slitem) kitcomp;
              enddo;
            endif;
            reade (#pwhse) slot11;
         enddo;

         // now lets read through item master looking for any active items
         // that DO NOT have a knew slot assigned.  We should warn user of
         // possible item missing
         setll (#pwhse) piritem;
         reade (#pwhse) piritem;
         dow not %eof(piritem);
            if ittype = 'R';
               chain (#pwhse:ititem) itemdsc;
               // We update description two in Dakota if Greenleaf sends
               // an inactive indicator in their normal item update process
               // If the item currently shows inactive we will not flag
               // as a possible error since it is not currently being used
               active = %scan('INACTIVE':ixdsc2);
               if active = 0;
                 kcwhse = itwhse;
                 slwhdp = itwhdp;
                 kcitem = ititem;
                 // if repack item shows as active then confirm
                 // that KITITEM ODR slot has new slot assigned
                 chain (itwhse:ititem) kititem;
                 if %found(kititem);
                    kcdisp = kidisp;
                    kcqty1 = kiqty1;
                    kcqty2 = kiqty2;
                    kcqty3 = kiqty3;
                    chain (itwhse:itwhdp:kidisp) slot2;
                    if %found(slot2);
                       if o_slstat <> 'RY';
                          wkrerr = '** Error ** No new Slot for Active' +
                             ' Repack ' + %trim(ititem);
                             exsr detailline;
                       else;
                          // update to status RP
                          o_slstat = 'RP';
                          update slrec2;
                       endif;
                    else;
                       wkrerr = '** Error ** New Slot not found in Slot' +
                           'File ' + %trim(kidisp) + ', item ' + %trim(ititem);
                           exsr detailline;
                    endif;
                 else;
                    kcdisp = *blanks;
                    kcqty1=0;
                    kcqty2=0;
                    kcqty3=0;
                    wkrerr = '** Error ** No Kit Item found for Repack' +
                        ' Item ' + %trim(ititem);
                        exsr detailline;
                 endif;
               endif;
            endif;
            reade (#pwhse) piritem;
         enddo;

         *inlr = '1';

      /end-free

     * -------------------------------------------------------------------
     **  Initialize everything
     *--------------------------------------------------------------------

     c     Init          begsr
     c                   eval      #pwhse = %DEC($pwhse:3:0)
     c                   eval      *in90 = *off
     c                   time                    hmsmdy
     c                   Move      hmsmdy        rdate
     c                   movel     hmsmdy        rtime
     c                   write     header
     c                   endsr

     * -------------------------------------------------------------------
     **  Print Error Detail line
     *--------------------------------------------------------------------

     c     detailline    begsr
      /free
          // if overflow on print headings
          if *in90 = *on;
             write header;
             *in90 = *off;
          endif;

          wktote =wktote + 1;

          write detail;

      /end-free
     c                   endsr
     *
     *  COMPILE TIME TABLES
     *
**
Item Not Found In Dakota.
ODR Slot not found for parent item
Warehouse Not Found, Not Adjusted.
Repack item has NO Kititem record
Parent itm pck slt NOT virtual of RP Slot
Parent item not found in item master
Slot not valid for Work Order Repack
RP slot not found for parent
ODR Slot required for On-Demand Item
