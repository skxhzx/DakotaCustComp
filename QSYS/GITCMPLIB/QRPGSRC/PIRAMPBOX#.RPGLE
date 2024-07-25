      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PIRAMPBOX#  Get next AMP box number and Id
     *  23 December 2015
     *
     *  Revisions
     *
700 A*   12/23/15  DAS  7.00
     *     - Created
     *
700aA*    2/05/16  DAS  7.00a
     *     - Revised to ensure box id is not zero.
700bA*    6/15/16  NLK  7.00b
     *     - Revised AMPBOX# from 3.0 to 5.0-next#, $nxtnm
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File specs
     *----------------------------------------------------------------

     Fpirampbox#uf a e           k disk
     Fampbox    if   e           k disk
     Fampbox1   if   e           k disk
     F                                     rename(abxrec:abxrec1)
     Flabel     if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
700bDD*next#           s              3  0
700bAD next#           s              5  0
     D nextId          s              7  0
     D currDate        s               d
     D currStamp       s               z
     D cutoffStamp     s               z
     D cutoffTime      s               t   inz(t'05.00.00')

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehose.
     *
     *    Returned Parameters
     *      $NXTNM  Next work transfer order number
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
700bDC**                 parm                    $nxtnm            3 0
700bAC                   parm                    $nxtnm            5 0
     C                   parm                    $nxtid            7 0

      /free

         // Get record with next number.  Create it if necessary.

         chain ($pwhse) pirampbox#;

         if not %found;
           nxabwhse = $pwhse;
           clear nxabnum;
           clear nxabid;
           clear nxabchgts;
           write nxabrec;
           chain ($pwhse) pirampbox#;
         endif;

         next# = nxabnum;
         nextId = nxabid;

         // Get next box number

         exsr GetNextBox#;

         // Get next box Id

         exsr GetNextBoxId;

         // Update the file.

         if next# = 999;
           nxabnum = 1;
         else;
           nxabnum = next# + 1;
         endif;

         if nextId = 9999999;
           nxabId = 1;
         else;
           nxabId = nextId + 1;
         endif;

         nxabchgts = %timestamp();

         update nxabrec;

         // Return box number and Id.

         $nxtnm = next#;
         $nxtid = nextId;

         return;

      /end-free

     *----------------------------------------------------------------
     *  GetNextBox#    Get next box number
     *----------------------------------------------------------------

      /free
       begsr GetNextBox#;

         // See if we should start at 1 for the box number
         //   when we have passed the cutoff time
         //   or when next number is zero.

         currStamp = %timestamp();
         currDate = %date();
         cutoffStamp = currDate + cutoffTime;

         if (nxabchgts < cutoffStamp) and (currStamp >= cutoffStamp);
           next# = 1;
         endif;

         if next# <= 0;
           next# = 1;
         endif;

         // File contains the next sequence number to use.  If it
         // has already been used then keep adding 1 until we find one
         // that hasn't been used (we will take the chance that all
         // 999 have not been used).

         dow forever = forever;

           // If box record doesn't exist, okay to use.

           setgt ($pwhse: next#) ampbox1;
           readpe ($pwhse: next#) ampbox1;

           if %eof(ampbox1);
             leave;
           endif;

           // If no delivery info, okay to use.

           if abxdlbl# = 0;
             leave;
           endif;

           // Get delivery label

           chain (abxdlbl#) label;

           // If label is found and it isn't open, okay to use.

           if %found(label);
             if lbstat <> 'P';
               leave;
             endif;
           endif;

           // Otherwise, try next number

           if next# = 999;
             next# = 1;
           else;
             next# += 1;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetNextBoxId   Get next box Id
     *----------------------------------------------------------------

      /free
       begsr GetNextBoxId;

700aA    if nextId <= 0;
700aA      nextId = 1;
700aA    endif;

         // File contains the next Id to use.  If it
         // has already been used then keep adding 1 until we find one
         // that hasn't been used (we will take the chance that all
         // 9999999 have not been used).

         dow forever = forever;

           chain ($pwhse: nextId) ampbox;

           // Get out if Id doesn't exist.

           if not %found(ampbox);
             leave;
           endif;

           // Otherwise, try next number.

           if nextId = 9999999;
             nextId = 1;
           else;
             nextId += 1;
           endif;

         enddo;

       endsr;
      /end-free
