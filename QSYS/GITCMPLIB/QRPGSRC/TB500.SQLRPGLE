     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TB500   Purge Truckbuilder Wave files
     *  12 February 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
510 A*    02/12/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D whse            s              3  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600fAD  #curruser            358    367

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     None
     *
     *  Output parameters
     *
     *     None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         // Purge TBWAVED of any records no longer in RTEHED
         exec sql delete from tbwaved as d
               where (select count(*) from rtehed as r where
                      r.rhwhse=d.twdwhs and r.rhrtid=d.twdrtid)=0;

         // Purge TBWAVEH of any records not found in TBWAVED
         exec sql delete from tbwaveh as h
               where (select count(*) from tbwaved as d where
                      d.twdwhs=h.twhwhs and d.twdid=h.twhid)=0;

         // Purge TBWERRLOG of any records not found in TBWAVEH
         exec sql delete from tbwerrlog as e
               where (select count(*) from tbwaveh as h where
                      e.tewhse=h.twhwhs and e.tewid=h.twhid)=0;

         // Purge TBFMTOIFS of any records not found in TBWAVEH
         exec sql delete from tbfmtoifs as i
               where (select count(*) from tbwaveh as h where
                      i.twfwhs=h.twhwhs and i.twfifn=h.twhifn)=0;

      /end-free

     *  Bye, Bye

     C                   eval      *inlr = *on
     C                   return
