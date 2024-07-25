417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEDELETE   Delete Rte - Pgm for SQL procedure of same name
     *  12 May 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
     *    05/12/12  DAS  6.40
     *      - Created.
700a *    06/19/15  LMC  7.00a
     *      - Loaded fields for call to RH124
750  *    04/28/21  KDE  7.50
     *      - Prevent Super Route deletes if remaining Merge routes
     *        associated
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed    uf   e           k disk    usropn

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
750 Ad rtecnt          s              3  0

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lrte                 22     26
     D  $lrtid                27     31

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pRte        Route
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage         80
     C                   parm                    pWhse             3 0
     C                   parm                    pRtid             5
     C                   parm                    pRte              5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Verify route is still at "open" status

         exsr getrtehed;
         if error;
             return;
         endif;

         if rhstat <> '1';
             error = *on;
             pMessage = 'Route not at OPEN status '
                      + '('
                      + %Trim(rhstat)
                      + ')';
             return;
         endif;

         // Set in-use flag

      /end-free
510bAC                   call(e)   'CHKIUSE'
510bAC                   parm      '*INUSE1'     $icmd             8
510bAC                   parm      pWhse         $iwhse            3 0
510bAC                   parm      pRtid         $irtid            5
510bAC                   parm      ' '           $irtn             8
      /free

         // Error on call

         if %error;
             error = *on;
             pMessage = 'Error calling program CHKIUSE';
             return;
         endif;

         if $irtn = '*ERROR';
             error = *on;
             pMessage = 'Route already in use '
                      + '('
                      + %Trim(%editc(pWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             return;
         endif;

750 A    // Ensure no Merge routes associated to delete Super Route
750 A    if %subst(rhrte:1:3)='#SR';
750 A       rtecnt=0;
750 A       exec sql select count(*) into :rtecnt
750 A                 from srrte
750 A            where srwhse=:pWhse and srsrtid=:pRtid;
750 A       if rtecnt <> 0;
750 A         error = *on;
750 A         pMessage = 'Super Route cannot be deleted when' +
750 A                    ' associated to Merge routes';
750 A
750 A /end-free
750 AC                   call(e)   'CHKIUSE'
750 AC                   parm      '*CLEAR '     $icmd             8
750 AC                   parm      pWhse         $iwhse            3 0
750 AC                   parm      pRtid         $irtid            5
750 AC                   parm      ' '           $irtn             8
750 A /free
750 A         return;
750 A       endif;
750 A    endif;

         // Call program to delete route

         $lcmd = '*DLTWEB';
         $lprg = #prog;
         $lrtn = ' ';
         $lerm = ' ';
700aA    $lwhse = pWhse;
700aA    $lrte  = pRte;
700aA    $lrtid = pRtid;

      /end-free
     C                   call(e)   'RH124'
     C                   parm                    $lparm
      /free

         // Error on call

         if %error;
             error = *on;
             pMessage = 'Error calling program RH124';
             return;
         endif;

         if $lrtn <> ' ' and $lrtn <> '*OK';
             error = *on;
             pMessage = $lerm;
             return;
         endif;

         return;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getrtehed   Get RTEHED record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getrtehed;

         error = *off;

500sA    // Open rtehed file

         if not %open(rtehed);
             open(e) rtehed;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file RTEHED in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get rtehed record

         chain(e) (pWhse: pRtid) rtehed;

         if %status = 01218; //locked
             error = *on;
             pMessage = 'Route locked by another user '
                      + '('
                      + %Trim(%editc(pWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

         if not %found;
             error = *on;
             pMessage = 'Route not found '
                      + '('
                      + %Trim(%editc(pWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

         unlock rtehed;

       endsr;
      /end-free
