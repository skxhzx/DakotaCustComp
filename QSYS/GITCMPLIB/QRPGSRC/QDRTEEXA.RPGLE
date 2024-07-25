      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDRTEEXA     Create missing RTEHEDEXA rec
     *  21 February 2021
     *  Dave Sommerville
     *
     *  This was created to be run at S. Bertram. Normally, this
     *  is not necessary because the GETTBTYPE program has been
     *  revised to properly handle missing RTEHEDEXA records.
     *  However, for an unknown reason, the version in SBRPIRMODS
     *  was not being called. The guess is that the Tomcat server
     *  needs to be restarted, but not able to do so a this time.
     *  Therefore, created this program so the older routes will
     *  be identified as DD1 routes.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     frtehed    if   e           k disk
     frtehedexa uf a e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    $pcmd   - *CREATE
     *
     *   Output
     *
     *    none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       if $pcmd <> '*CREATE';
         dsply 'Invalid command';
         return;
       endif;

       // Loop through all RTEHED records

       dow 1=1;

         read rtehed;
         if %eof(rtehed);
           leave;
         endif;

         // Skip Open routes

         if RHSTAT = '1';
           iter;
         endif;

         // Skip if RTEHEDEXA exist for route

         chain(n) (rhwhse: rhrtid) rtehedexa;
         if %found(rtehedexa);
           iter;
         endif;

         // Add RTEHEDEXA record with rhatype = 'S'

         clear rharec;
         rhawhse = rhwhse;
         rhartid = rhrtid;
         rhatbtype = 'S';
         write rharec;

       enddo;

       return;

      /end-free
