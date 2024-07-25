417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETPLTINFO  Get client pallet info - Pgm for GETPLTINFO function
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
     *    The info string is a comma delimited string consisting of
     *    one or more values. This program (sql function) should
     *    only be called if the client has special info for
     *    item lines (labels). This is determined through program
     *    GETDDOPTS.
     *
     *    Each value consists of 3 fields. The first field is a
     *    description field to be use for the 'tip' box. The second
520 A*    field is the actual value. The third field identifies if
520 A*    the value should only be displayed in the 'tip' box.
     *
     *    Example: Let's say that it is determined that 2 values need
     *             to be displayed for an item, 'VAL1' and VAL2'. The
     *             'VAL1' field should only be displayed in the tip
     *             box, while 'VAL2' is to be displayed in the tree.
     *             Here is the info string that should be sent back:
     *
     *                  Value1:,VAL1,Y,Value2:,VAL2,N
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
     d infoTipDesc     s             30
     d infoValue       s             30
     d infoTipOnly     s              1
     d tempPlid        s                   like($pPlid)

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
     *      $pPlid       Pallet id
     *
     *    Returned Parameters
     *      $pInfo      -  Client pallet info (comma delimited string)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pPlid            7 0
     C                   parm                    $pInfo          100

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         $pInfo = ' ';

         // Get client

         getClient(client : clientloc);

         // Set info based on Client

         select;

           when client = pirdemo;
             exsr zzpirdemo;

           when client = cashwa;
             exsr zzcashwa;

         endsl;

         *inlr = *on;
         return;
      /end-free

500sA*----------------------------------------------------------------
500sA*  add2Info     Add value to info string
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr add2Info;

         if $pInfo <> ' ';
           $pInfo = %trimr($pInfo) + ',';
         endif;

         $pInfo = %trimr($pInfo)
               + %trimr(infoTipDesc) + ','
               + %trimr(infoValue) + ','
               + %trimr(infoTipOnly);

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  zzcashwa     Get client info for CASHWA
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr zzcashwa;

         error = *off;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  zzpirdemo    Get client info for PIRDEMO
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr zzpirdemo;

         error = *off;

         tempPlid = $pplid/10;
         if %rem(tempPlid : 2) = 0;

           infoTipDesc   = 'OddEven:';
           infoValue     = 'PE';
           infoTipOnly   = 'N';
           exsr add2Info;

           infoTipDesc   = 'Custom:';
           infoValue     = 'P' + %trim(%char($pplid));
           infoTipOnly   = 'Y';
           exsr add2Info;

         else;

           infoTipDesc   = 'OddEven:';
           infoValue     = 'PO';
           infoTipOnly   = 'N';
           exsr add2Info;

         endif;

       endsr;
      /end-free
