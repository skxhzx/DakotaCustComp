      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETSTAMP    Get stamping unit for a transaction
     *  02 May, 2012
     *  Jeffrey Jahnke
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
520 A*   05/02/12  JCJ  6.40
     *     - Created.
     *
700 A*   05/17/16  MLB  7.00
     *     - Enh: Added client custom code support to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. TOTEHDR file had order id added
     *        to make file key unique.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftotehdr   if   e           k disk
     Fordp3     if   e           k disk
700 A*
700 A*----------------------------------------------------------------
700 A*  Customer id
700 A*
700 AD @getcl          c                   const('GETCLIENT')
700 A*
CWD A /copy qcopysrc,id#Cashwa

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $plbl#          s              7  0
     D $pwhse          s              3  0
     D $pstamp         s             16
     D $prtid          s              5

     *----------------------------------------------------------------
     *  Input parameters
     *
     *     $pwhse   - Warehouse
     *     $prtid   - Route id
     *     $plbl#   - Label number
     *
     *  Output parameters
     *
     *     $pstamp  - Stamping unit
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $plbl#
     C                   parm                    $pstamp

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c                   exsr      zzgetmergelbl
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  zzgetmergelbl  - get merge label number
     *----------------------------------------------------------------

      /free
       begsr zzgetmergelbl;

         // get the merge label number
         setll ($pwhse: $prtid) totehdr;
         dow forever = forever;
           reade ($pwhse: $prtid) totehdr;
           if %eof(totehdr);
             leave;
           endif;
           if $plbl# = tohlbl;
             chain ($pwhse: $prtid: tohml#) ordp3;
             if %found(ordp3);
               $pstamp = ($prtid) + %editc(orpup#:'X');
             endif;
           endif;
         enddo;
       endsr;
      /end-free
700 A*
700 A*----------------------------------------------------------------
700 A*
700 A*  *INZSR  Initialization subroutine
700 A*
700 AC     *inzsr        begsr
700 A*
700 A* Get client id.
700 A*
700 AC                   call      @getcl
700 AC                   parm                    client           10
700 AC                   parm                    clientloc        10
700 A*
700 AC                   endsr
