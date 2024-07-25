417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETSTPFLGS  Get stop flags - Pgm for GETSTPLGS proc
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
     *  Key definitions
     *----------------------------------------------------------------

     D keyOH9          ds                  likerec(ohrec:*key)
     D keyHM           ds                  likerec(hmrec:*key)

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
     *      $pWhse       Warehouse
     *      $pRtid       Route id
     *      $pStop       Stop
     *
     *    Returned Parameters
     *      $pStop5     -  Large stop number
     *      $pFlags     -  Label flags (comma delimited string)
     *      $pReturn    -  *OK or error code
     *      $pMessage   -  Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pStop            2 0
     C                   parm                    $pStop5           5 0
     C                   parm                    $pFlags          20
     C                   parm                    $pReturn          8
     C                   parm                    $pmessage        80

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         if $pReturn = '*TEST';
             testRun = *on;
         else;
             testRun = *off;
         endif;

         $pStop5 = 0;
         $pFlags = ' ';
         $pReturn = '*OK';
         $pMessage = ' ';

         // Get client

         getClient(client : clientloc);

         // Set flags based on Client

         select;

             when testRun;
                 exsr flagsTest;

             when client = cashwa;

             other;
                 $pReturn = 'NOFLAGS';

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
                 $preturn  = 'OPNERROH';
                 $pmessage = 'Error occured trying to '
                           + 'open file ORDH9 in pgm '
                           + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get ordhm record

         keyOH9.ohwhse = $pwhse;
         keyOH9.ohrte  = $prtid;
         keyOH9.ohstop = $pstop;

         setll %kds(keyOH9:3) ordh9;
         reade %kds(keyOH9:3) ordh9;

         if %eof(ordh9);
             error = *on;
             $preturn = 'NOTFNDOH';
             $pmessage = 'ORDH9 not found '
                         + '('
                         + %Trim(%editc($pwhse:'Z'))
                         + '/'
                         + %Trim($prtid)
                         + '/'
                         + %Trim(%editc($pstop:'Z'))
                         + ')';
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
                 $preturn  = 'OPNERRHM';
                 $pmessage = 'Error occured trying to '
                           + 'open file ORDHM in pgm '
                           + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get ordhm record

         keyHM.hmwhse = ohwhse;
         keyHM.hmord  = ohord;

         chain %kds(keyHM) ordhm;

         if not %found;
             error = *on;
             $preturn = 'NOTFNDHM';
             $pmessage = 'ORDHM not found '
                         + '('
                         + %Trim(%editc($pwhse:'Z'))
                         + '/'
                         + %Trim(%editc($pstop:'Z'))
                         + ')';
             leavesr;
         endif;

       endsr;
      /end-free
