      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  YTD100    Populate ITEMYTD file
     *  04 July 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*    07/04/18  DAS  7.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpohhdr1   if   e           k disk
     Fpohdtl1   if   e           k disk
     Frtehed7   if   e           k disk
     Fordh3     if   e           k disk
     Fordd      if   e           k disk
     Fwarehs    if   e           k disk
     Fitemytd1  if   e           k disk    rename(iyrec: iyrec1)
     Fitemytd2  if   e           k disk    rename(iyrec: iyrec2)
     Fitemytd3  if   e           k disk    rename(iyrec: iyrec3)
     Fitemytd   uf a e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  Working variables
     *
     D error           s               n
     D forever         s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetItem         pr
     d  item                               like(iyitem)

     d ReceivedYTD     pr

     d ReturnedYTD     pr

     d SelectedYTD     pr

     d ZZDriCop        pr

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.dricop

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       dow forever = forever;

         read warehs;
         if %eof(warehs);
           leave;
         endif;

         ReceivedYTD();

         SelectedYTD();

         ReturnedYTD();
       enddo;

      /end-free

     *----------------------------------------------------------------
     *  GetItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi
     d  item                               like(iyitem)

      /free

       savever# = $itver#;
       clear $item;
       clear $item2;
       $itver# = savever#;

       $itwhse   = whcode;
       $ititem   = item;

       $dricommand = '*ITEM';
       $drisubcmd  = '%GETPARENT';
       $drisys2upd = 'D';

       ZZDricop();

       if error = *on or $itmitem = '';
         $itmitem = $ititem;
       endif;

      /end-free

     p GetItem         e

     *----------------------------------------------------------------
     *  ReceivedYTD  Update Received YTD
     *----------------------------------------------------------------

     p ReceivedYTD     b
     d ReceivedYTD     pi

     * Local Variables

     d year            s              4  0
     d startDate       s              8  0
     d startTime       s              6  0

      /free

       // Get last export date processed

       setll (whcode: 999999) itemytd1;
       readpe (whcode) itemytd1;
       if %eof(itemytd1);
         startDate = 0;
         startTime = 0;
       else;
         startDate = iyrcvexpdl;
         startTime = iyrcvexptl;
       endif;

       // First time, start with current year

       if startDate = 0;
         startDate = %subdt(%timestamp():*YEARS) * 10000;
       endif;

       // Loop through PO's exported after last date/time processed.

       setgt (whcode: startDate: startTime) pohhdr1;

       dow forever = forever;

         reade (whcode) pohhdr1;
         if %eof(pohhdr1);
           leave;
         endif;

         // Everything shoudl have an expiration date, but check anyway

         if phhedt = 0;
           iter;
         endif;

         year = %div(phhedt: 10000);

         // Loop through detail lines for exported PO

         setll (phhwhs: phhpo: phhedt: phheti) pohdtl1;

         dow forever = forever;

           reade (phhwhs: phhpo: phhedt: phheti) pohdtl1;
           if %eof(pohdtl1);
             leave;
           endif;

           // Create/Update YTD record for item

           chain (phdwhs: phditm: year) itemytd;

           if not %found(itemytd);
             clear iyrec;
             iywhse = phdwhs;
             iyitem = phditm;
             iyyear = year;
             GetItem(phditm);
             iybaseitm = $itmitem;
           endif;

           if iyrcvqr1 = 0 and iyrcvqr2 = 0 and iyrcvqr3 = 0;
             iyrcvexpdf = phdedt;
             iyrcvexptf = phdeti;
           endif;

           iyrcvqo1 += phdqo1;
           iyrcvqo2 += phdqo2;
           iyrcvqo3 += phdqo3;

           iyrcvqr1 += phdqr1;
           iyrcvqr2 += phdqr2;
           iyrcvqr3 += phdqr3;

           iyrcvlines += 1;

           iyrcvexpdl = phdedt;
           iyrcvexptl = phdeti;

           iystamp = %timestamp();

           if not %found(itemytd);
             write iyrec;
           else;
             update iyrec;
           endif;

         enddo;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ReturnedYTD  Update Returned YTD
     *----------------------------------------------------------------

     p ReturnedYTD     b
     d ReturnedYTD     pi

      /free

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  SelectedYTD  Update Selected YTD
     *----------------------------------------------------------------

     p SelectedYTD     b
     d SelectedYTD     pi

     * Local Variables


     d year            s              4  0
     d startDate       s              8  0
     d startTime       s              6  0
     d stat            s              1

      /free

       // Get last export date processed

       setll (whcode: 999999) itemytd2;
       readpe (whcode) itemytd2;
       if %eof(itemytd2);
         startDate = 0;
         startTime = 0;
       else;
         startDate = iyselexpdl;
         startTime = iyselexptl;
       endif;

       // First time, start with current year

       if startDate = 0;
         startDate = %subdt(%timestamp():*YEARS) * 10000;
       endif;

       // Loop through Route's exported after last date/time processed.

       stat = '6';
       setgt (whcode: stat: startDate: startTime) rtehed7;

       dow forever = forever;

         reade (whcode: stat) rtehed7;
         if %eof(rtehed7);
           leave;
         endif;

         // Everything should have an expiration date, but check anyway

         if rhexpd = 0;
           iter;
         endif;

         year = %div(rhexpd: 10000);

         // Loop through orders for exported Route

         setll (rhwhse: rhrtid) ordh3;

         dow forever = forever;

           reade (rhwhse: rhrtid) ordh3;
           if %eof(ordh3);
             leave;
           endif;

           // Loop through order detail lines for exported Route order

           setll (ohwhse: ohord) ordd;

           dow forever = forever;

             reade (ohwhse: ohord) ordd;
             if %eof(ordd);
               leave;
             endif;

             // Create/Update YTD record for item

             chain (odwhse: oditem: year) itemytd;

             if not %found(itemytd);
               clear iyrec;
               iywhse = odwhse;
               iyitem = oditem;
               iyyear = year;
               GetItem(oditem);
               iybaseitm = $itmitem;
             endif;

             if iyselqp1 = 0 and iyselqp2 = 0 and iyselqp3 = 0;
               iyselexpdf = rhexpd;
               iyselexptf = rhexpt;
             endif;

             iyselqo1 += odqor1;
             iyselqo2 += odqor2;
             iyselqo3 += odqor3;

             iyselqp1 += odqpk1;
             iyselqp2 += odqpk2;
             iyselqp3 += odqpk3;

             iysellines += 1;
             iyselexpdl = rhexpd;
             iyselexptl = rhexpt;

             iystamp = %timestamp();

             if not %found(itemytd);
               write iyrec;
             else;
               update iyrec;
             endif;

           enddo;

         enddo;

       enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ZZDriCop   Get item info.
     *----------------------------------------------------------------

     p ZZDriCop        b
     d ZZDriCop        pi

      /free

       error = *off;

       select;
         when $dricommand = '*ITEM';
           $dridata = $item;
           $dridata2 = $item2;
       endsl;

       driCop($dricommand: $drisubcmd: $drisys2upd: #prog:
                $drireturn: $drimessage: $dridata: $dridata2);

       select;
         when %error;
           error = *on;
         when $drireturn <> '*OK';
           error = *on;
       endsl;

       select;
         when $dricommand = '*ITEM';
           $item = $dridata;
           $item2 = $dridata2;
       endsl;

      /end-free

     p ZZDriCop        e

