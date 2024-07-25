417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  REBUILDRTE  Rebuild Rte - Pgm for SQL procedure of same name
     *  24 November 2008
     *  Dave Sommerville
     *
     *  Revisions:
     *
520 A*    11/24/08  DAS  5.20
     *      - Created.
     *
640aA*    03/21/12  JCJ  6.40a
     *      - Added call to OR635D to delete TOTEHDR records on a user
     *        does a rebuild.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed    if   e           k disk    usropn

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyRH           ds                  likerec(rhrec:*key)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse       Warehouse
     *      $prtid       Route id
     *
     *    Returned Parameters
     *      $prtn   Return code
     *      $perm   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $preturn          8
     C                   parm                    $pmessage        80

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         $pReturn = '*OK';
         $pMessage = ' ';

         // Verify route is still at "built" status

         exsr getrtehed;
         if error;
             return;
         endif;

         if rhstat <> '3';
             error = *on;
             $preturn = 'NOTSTAT3';
             $pmessage = 'Route not at BUILT status '
                         + '('
                         + %Trim(rhstat)
                         + ')';
             return;
         endif;

         // Call program to rebuild route

      /end-free
640aAC                   call(e)   'OR635D'
640aAC                   parm      rhwhse        $whse             3 0
640aAC                   parm                    rhrtid

510bAC                   call(e)   'OR605'
510bAC                   parm      '*PICK   '    $bcmd             8
510bAC                   parm      '*REBUILD'    $bcmd2            8
510bAC                   parm      '*PICK1  '    $btype            8
510bAC                   parm      '0'           $bjtyp            1
510bAC                   parm      $pWhse        $bwhs            15 5
510bAC                   parm      0             $bbat             7 0
510bAC                   parm      ' '           $bstat            1
510bAC                   parm      $pRtid        $brtid            5
510bAC                   parm      0             $bord             7 0
510bAC                   parm      0             $brwhs            3 0
510bAC                   parm      ' '           $btrte            5
510bAC                   parm      ' '           $brtn             8
510bAC                   parm      ' '           $bmsg             4
510bAC                   parm      ' '           $bprg            10
      /free

         // Error on call

         if %error;
             error = *on;
             $preturn = 'CALLERR';
             $pmessage = 'Error calling program OR605';
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
                 $preturn  = 'OPNERRRH';
                 $pmessage = 'Error occured trying to '
                           + 'open file RTEHED in pgm '
                           + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get rtehed record

         keyRH.rhwhse = $pWhse;
         keyRH.rhrtid = $pRtid;

         chain %kds(keyRH) rtehed;

         if not %found;
             error = *on;
             $preturn = 'NOTFNDRH';
             $pmessage = 'RTEHED not found '
                         + '('
                         + %Trim(%editc($pwhse:'Z'))
                         + '/'
                         + %Trim($prtid)
                         + ')';
             leavesr;
         endif;

       endsr;
      /end-free
