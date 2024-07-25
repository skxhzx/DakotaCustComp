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
     *  Client Custom Revisions: Indianhead
     *----------------------------------------------------------------
IFDaA*   12/10/08  JCJ  IFDa
     *     - Changed to display keytype code.
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

     Fpltstp1   if   e           k disk    usropn
     Fworklbl5  if   e           k disk
     Forddm     if   e           k disk

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
IFDaA /copy qcopysrc,id#ifd

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d error           s               n
     d found           s               n
     d infoTipDesc     s             30
     d infoValue       s             30
     d infoTipOnly     s              1
     d tempPlid        s                   like($pPlid)
IFDaAd keytype         s              1
IFDaAd savtyp          s              1
500lA
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

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

         // Set if pallet is empty by seeing if a pltstp rec exists.
         //   If none exist, then return.

         //exsr getpltstp1;
         //if error or not found;
         //  return;
         //endif;

         // Get client

         getClient(client : clientloc);

         // Set info based on Client

         select;

           when client = pirdemo;
             exsr zzpirdemo;

           when client = cashwa;
             exsr zzcashwa;

IFDaA      when client = ifd;
IFDaA        exsr zzifd;

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

     *----------------------------------------------------------------
     *  getpltstp1  Get pltstp1 record
     *----------------------------------------------------------------

      /free
       begsr getpltstp1;

         error = *off;
         found = *off;

         // Open pltstp1 file

         if not %open(pltstp1);
           open(e) pltstp1;
           if %error;
             error = *on;
             infoTipDesc   = 'Err (GETPLTINFO):';
             infoValue     = 'Error opening PLTSTP1';
             infoTipOnly   = 'Y';
             exsr add2Info;
             leavesr;
           endif;
         endif;

         // See if a pltstp1 record exists.

         setll ($pwhse: $pRtid: $pPlid) pltstp1;

         if %equal(pltstp1);
           found = *on;
         endif;

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

         dsplid = $pplid;
         if dsplrw = 1 and dsplcl = 1;
           leavesr;
         endif;

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

IFDaA*----------------------------------------------------------------
IFDaA*  zzifd        Get client info for Indianhead
IFDaA*----------------------------------------------------------------
IFDaA
      /free
IFDaA  begsr zzifd;

         error = *off;
         keytype = *blanks;
         savtype = '.';

         setll ($pwhse: $pRtid: $pPlid ) worklbl5;

         dow forever = forever;

           reade ($pwhse: $pRtid: $pPlid) worklbl5;

           if %eof(worklbl5);
             leave;
           endif;

           chain(n) (lwwhse: lword: lwseq: lwitem) orddm;

           if %found(orddm);
             keytype = %subst(ommsc1:1:1);

             if savtype = '.';
               savtype = keytype;
             endif;

             if keytype <> savtype;
               keytype = 'M';
               leave;
             endif;

           endif;

         enddo;

           infoTipDesc   = 'KT:';
           infoValue     = keytype;
           infoTipOnly   = 'N';
           exsr add2Info;

       endsr;
      /end-free
