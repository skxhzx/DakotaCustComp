      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  COPYUSERS    Copy PIRUSER info to GLOUSR
     *  February 6, 2012
     *  Rod Roller
     *
     *  Revisions:
     *
640 A*    02/06/12  RTR  6.40
     *      - Created.
640aA*    01/02/13  RTR  6.40a
     *      - Hard code BFCGLOBALF.
650aA*    03/26/13  DAS  6.50a
     *      - Rewrote to handle existing records in file for clients
     *        with multiple warehouses.
     *      - BFCGLOBALF must be on library list before running.
     *      - Must be run against each files library.
650bA*    04/11/14  RBD  6.50b
     *      - Fix: added logic when searching guvalue to first determine
     *        whether the whse being added/updated is a length of 1,
     *        2 or 3.  For example, if whse=5, we must check to see if
     *        it's in pos 1 of guvalue by searching with '5 ', and if
     *        it's not in pos 1, then search with ' 5 '.  Without this
     *        logic, whse 5 would give a false positive if whse 25
     *        were the last whse listed in guvalue.
650bA*    12/19/17  MR
     *      - Recompiled due to database changes to PIRUSERA
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpiruser   ip   e           k disk
     Fpirusera  uf   e           k disk
     Fglousr    uf a e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d wkwhse          s              4a
     d svwhse          s              4a
     d wkpos           s              5s 0
650bAD whsLength       S              3s 0
650bAD wkwhs1B         s              2a
650bAD wkwhsB1B        s              3a
650bAD wkwhs2B         s              3a
650bAD wkwhsB2B        s              4a
650bAD wkwhs3B         s              4a
650bAD wkwhsB3B        s              5a

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       // Get PIRUSERA record

       chain (uscode) pirusera;
       if not %found(pirusera);
         usalng = 'EN';
       endif;

       // Get GLOUSR record

       chain (uscode) glousr;

       // Initializ fields

       if not %found(glousr);
         clear gurec;
         guuser = uscode;
       endif;

       guemp# = usemp#;
       gufnam = usfnam;
       guinit = usinit;
       gulnam = uslnam;
       gulang = usalng;

       // Add warehouse to authority list

       select;

         when guvalue = ' ';
           gurel = 'EQ';
           guvalue = %char(uswhse);

         when gurel = 'EQ' and guvalue <> %char(uswhse);
           gurel = 'LS';
           guvalue = %trimr(guvalue) + ' ' + %char(uswhse);

         when gurel = 'LS';
           wkwhse = %char(uswhse);
650bD    //wkpos = %scan(wkwhse: guvalue);
650bA      whsLength = %Len(%Trim(%char(uswhse)));

650bA      if whsLength = 1;
650bA        wkwhs1B = %trim(wkwhse);
650bA        wkwhsB1B = ' ' + %trim(wkwhse) + ' ';
650bA        wkpos = %scan(wkwhs1B: guvalue);
650bA        if wkpos <> 1;
650bA          wkpos = %scan(wkwhsB1B: guvalue);
650bA        endif;
650bA      endif;

650bA      if whsLength = 2;
650bA        wkwhs2B = %trim(wkwhse);
650bA        wkwhsB2B = ' ' + %trim(wkwhse) + ' ';
650bA        wkpos = %scan(wkwhs2B: guvalue);
650bA        if wkpos <> 1;
650bA          wkpos = %scan(wkwhsB2B: guvalue);
650bA        endif;
650bA      endif;

650bA      if whsLength = 3;
650bA        wkwhs3B  = %trim(wkwhse);
650bA        wkwhsB3B = ' ' + %trim(wkwhse) + ' ';
650bA        wkpos = %scan(wkwhs3B: guvalue);
650bA        if wkpos <> 1;
650bA          wkpos = %scan(wkwhsB3B: guvalue);
650bA        endif;
650bA      endif;

           if wkpos = 0;
             guvalue = %trimr(guvalue) + ' ' + %char(uswhse);
           endif;
       endsl;

       // Add/Update record

       if not %found(glousr);
         write gurec;
       else;
         update gurec;
       endif;

      /end-free
