417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETSTPFLGS  Get stop flags - Pgm for GETSTPLGS function
     *  23 November 2008
     *  Dave Sommerville
     *
     *  Revisions:
     *
520 A*    11/23/08  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    The flag string is a comma delimited string consisting of
     *    one or more flags. This program (stored procedure) should
     *    only be called if the client has special flags for a Stop.
     *    This is determined through program GETDDOPTS. It is assumed
     *    that all orders for a Stop will be assigned the same flag(s).
     *
     *    Each flag consists of 2 fields. The first field identifies
     *    if the flag should also be displayed at the pallet level.
520 A*    The second field is the actual flag that will be displayed.
     *
     *    Example: Let's say that it is determined that 2 flags need
     *             to be displayed for a stop, 'FLG1' and FLG2', and
     *             'FLG1' should also be displayed at the pallet level.
     *             Here is the flag string that should be sent back:
     *
     *                          Y,FLG1,N,FLG2
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordh9     if   e           k disk    usropn
     Fordhm     if   e           k disk    usropn

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D getClient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientloc                    10

500lA*----------------------------------------------------------------
500lA*  Customer id
500lA*----------------------------------------------------------------
500lA
     d client          s             10
     d clientloc       s             10
500lA
500lA /copy qcopysrc,id#pirdemo
500lA /copy qcopysrc,id#cheney
500lA /copy qcopysrc,id#cashwa

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d error           s               n
     d testRun         s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pCmd        *GET, *TEST
     *      $pWhse       Warehouse
     *      $pRtid       Route id
     *      $pStop       Stop
     *
     *    Returned Parameters
     *      $pFlags     -  Label flags (comma delimited string)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd             5
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pStop            2 0
     C                   parm                    $pFlags          20

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         if $pCmd = '*TEST';
             testRun = *on;
         else;
             testRun = *off;
         endif;

         $pFlags = ' ';

         // Get client

         getClient(client : clientloc);

         // Set flags based on Client

         select;

             when testRun;
                 exsr flagsTest;

             when client = cashwa;

         endsl;

         *inlr = *on;
         return;
      /end-free

500sA*----------------------------------------------------------------
500sA*  flagsTest    Get flags for *TEST
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr flagsTest;

         error = *off;

500sA    exsr getordh9;
500sA    if error;
500sA        leavesr;
500sA    endif;

500sA    exsr getordhm;
500sA    if error;
500sA        leavesr;
500sA    endif;

         if %rem(ohord : 2) = 0;
             $pFlags = 'Y,SE,N,S' + %trim(%char(ohord));
         else;
             $pFlags = 'N,SO';
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getordh9    Get ORDH9 record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getordh9;

         error = *off;

500sA    // Open ordh9 file

         if not %open(ordh9);
             open(e) ordh9;
             if %error;
                 error = *on;
                 $pFlags  = 'OPNERROH';
                 leavesr;
             endif;
         endif;

500sA    // Get ordhm record

         setll ($pwhse: $prtid: $pstop) ordh9;
         reade ($pwhse: $prtid: $pstop) ordh9;

         if %eof(ordh9);
             error = *on;
             $pFlags = 'NOTFNDOH';
             leavesr;
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getordhm    Get ordhm record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getordhm;

         error = *off;

500sA    // Open ordhm file

         if not %open(ordhm);
             open(e) ordhm;
             if %error;
                 error = *on;
                 $pFlags  = 'OPNERRHM';
                 leavesr;
             endif;
         endif;

500sA    // Get ordhm record

         chain (ohwhse: ohord) ordhm;

         if not %found;
             error = *on;
             $pFlags = 'NOTFNDORDHM';
             leavesr;
         endif;

       endsr;
      /end-free
