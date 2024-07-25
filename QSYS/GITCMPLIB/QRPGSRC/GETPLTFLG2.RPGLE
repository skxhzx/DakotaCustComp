417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETPLTFLGS  Get pallet flags - Pgm for GETPLFLGS function
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
     *    only be called if the client has special flags for a pallet.
     *    This is determined through program GETDDOPTS.
     *
     *    Since this is the pallet level, only the flags are sent,
     *    unlike GETSTPFLGS and GETLBLFLGS that also send a field
     *    indicating if the flag should be displayed at the pallet
     *    level.
     *
     *    Example: Let's say that it is determined that 2 flags need
     *             to be displayed for a pallet, 'FLG1' and FLG2'.
     *             Here is the flag string that should be sent back:
     *
     *                          FLG1,FLG2
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     F* See GETSTPFLGS for how to define and work with a file.

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
     *      $pPlid       Pallet id
     *
     *    Returned Parameters
     *      $pFlags     -  Pallet flags (comma delimited string)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd             5
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pPlid            7 0
     C                   parm                    $pFlags          20
     C                   parm                    $pReturn          8
     C                   parm                    $pmessage        80

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

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

         if %rem($pplid : 2) = 0;
             $pFlags = 'PE,P' + %trim(%char($pplid));
         else;
             $pFlags = 'PO';
         endif;

       endsr;
      /end-free
