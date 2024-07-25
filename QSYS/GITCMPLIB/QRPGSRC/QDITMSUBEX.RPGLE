      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *
     *  QDITMSUBEX   Create missing ITEMSUBEX recs
     *  08 July 2021
     *  Retha Davis
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     fitemsub   if   e           k disk
     fitemsubexauf a e           k disk

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

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

        exsr getcurrstamp;

       if $pcmd <> '*CREATE';
         dsply 'Invalid command';
         return;
       endif;

       // Loop through all ITEMSUB records

       dow 1=1;

         read itemsub;
         if %eof(itemsub);
           leave;
         endif;

         // Skip if ITEMSUBEXA already exists

         chain(n) (isuwhse: isuitem: isucust: isuisub) itemsubexa;
         if %found(itemsubexa);
           iter;
         endif;

         // Add ITEMSUBEXA record

         clear isxrec;
         isxwhse = isuwhse;
         isxitem = isuitem;
         isxcust = isucust;
         isxisub = isuisub;
         isxas   = 'N';
         isxseq  = 0;
         isxaddts = CurrStampsys;
         isxaddusr = #curruser;
         write isxrec;

       enddo;

       return;

      /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
