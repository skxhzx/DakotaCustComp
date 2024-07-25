417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETLBLFLGS  Get label flags - Pgm for GETLBLLGS proc
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
     *    only be called if the client has special flags for order
     *    detail lines (labels). This is determined through program
     *    GETDDOPTS.
     *
     *    Each flag consists of 2 fields. The first field identifies
     *    if the flag should also be displayed at the pallet level.
520 A*    The second field is the actual flag that will be displayed.
     *
     *    Example: Let's say that it is determined that 2 flags need
     *             to be displayed for an item, 'FLG1' and FLG2', and
     *             'FLG1' should also be displayed at the pallet level.
     *             Here is the flag string that should be sent back:
     *
     *                          Y,FLG1,N,FLG2
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel     if   e           k disk    usropn
     Forddm     if   e           k disk    usropn

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
500lA /copy qcopysrc,id#cashwa
500lA /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyLB           ds                  likerec(lbrec:*key)
     D keyOM           ds                  likerec(omrec:*key)

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
     *      $pLbl#       Label number
     *      $pOrd        Order number
     *      $pSeq        Sequence number
     *      $pItem       Item
     *
     *    Returned Parameters
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
     C                   parm                    $pLbl#            7 0
     C                   parm                    $pOrd             7 0
     C                   parm                    $pSeq             5 0
     C                   parm                    $pItem           15
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

500sA    exsr getlabel;
500sA    if error;
500sA        leavesr;
500sA    endif;

500sA    exsr getorddm;
500sA    if error;
500sA        leavesr;
500sA    endif;

         if %rem($pord+$pseq : 2) = 0;
             $pFlags = 'Y,IE,N,SQ' + %trim(%char($pseq));
         else;
             $pFlags = 'N,IO';
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getlabel    Get label record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getlabel;

         error = *off;

500sA    // Open label file

         if not %open(label);
             open(e) label;
             if %error;
                 error = *on;
                 $preturn  = 'OPNERRLB';
                 $pmessage = 'Error occured trying to '
                           + 'open file LABEL in pgm '
                           + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get label record

         keyLB.lblbl# = $plbl#;

         chain %kds(keyLB) label;

         if not %found;
             error = *on;
             $preturn = 'NOTFNDLB';
             $pmessage = 'LABEL not found '
                       + '('
                       + %Trim(%editc($pLbl#:'Z'))
                       + ')';
             leavesr;
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  getorddm    Get orddm record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getorddm;

         error = *off;

500sA    // Open orddm file

         if not %open(orddm);
             open(e) orddm;
             if %error;
                 error = *on;
                 $preturn  = 'OPNERROM';
                 $pmessage = 'Error occured trying to '
                           + 'open file ORDDM in pgm '
                           + #pgm;
                 leavesr;
             endif;
         endif;

500sA    // Get orddm record

         keyOM.omwhse = $pwhse;
         keyOM.omord  = $pord;
         keyOM.omseq  = $pseq;
         keyOM.omitem = $pitem;

         chain %kds(keyOM) orddm;

         if not %found;
             error = *on;
             $preturn = 'NOTFNDOM';
             $pmessage = 'ORDDM not found '
                         + '('
                         + %Trim(%editc($pwhse:'Z'))
                         + '/'
                         + %Trim(%editc($pord:'Z'))
                         + '/'
                         + %Trim(%editc($pseq:'Z'))
                         + '/'
                         + %Trim($pitem)
                         + ')';
             leavesr;
         endif;

       endsr;
      /end-free
