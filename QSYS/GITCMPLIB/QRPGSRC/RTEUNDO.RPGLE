417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEUNDO     Undo Rte - Pgm for SQL procedure of same name
     *  13 May 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
     *    05/13/12  DAS  6.40
     *      - Created.
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

         // Call program to delete route

         $lcmd = '*DLTWEB';
         $lprg = #prog;
         $lrtn = ' ';
         $lerm = ' ';

      /end-free
     C                   call(e)   'RH134'
     C                   parm                    $lparm
      /free

         // Error on call

         if %error;
             error = *on;
             pMessage = 'Error calling program RH134';
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
