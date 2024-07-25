      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CPYTRUCK    Copy truck
     *  01 May 2014
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    05/01/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#TRUCKD
     D saveVer#        s                   like($tdver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650bA*      pSessId     Session Id
650bA*      pUser       User
650bA*      pDPCombo    Dictionary/Program combo
     *      pWhse       Warehouse
     *      pFromTrk    From truck
     *      pNewTrk     New truck
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg          99
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pDPCombo         20
     C                   parm                    pWhse             3 0
     C                   parm                    pFromTrk         10
     C                   parm                    pNewTrk          10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

         // If from truck is blank, assume normal Add and get out

         if pFromTrk = '';
           return;
         endif;

         // Trucks cannot be the same

         if pFromTrk = pNewTrk;
           pErrMsg = 'From/New trucks cannot be the same';
           return;
         endif;

         // Copy truck detail
         // Truck header will be copied by MRC

         savever# = $tdver#;
         clear $truckd;
         $tdver# = savever#;

         $tdWhseu = *on;
         $tdWhse = pWhse;
         $tdtruku = *on;
         $tdtruk  = %xlate(xlower: xupper: pNewTrk);
         $tdfrmtrku = *on;
         $tdfrmtrk  = %xlate(xlower: xupper: pFromTrk);

         $dricommand = '*TRUCKD';
         $drisubcmd = '%COPYTRK';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $truckd;
         $drireturn = '*OK';

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata);

         $truckd = $dridata;

         select;
           when %error;
             pErrMsg = 'Error occured calling DRITRUCKD '
                     + '('
                     + %trimr(#Job) + '/'
                     + %trimr(#JobNbr) + '/'
                     + %trimr(#user)
                     + ')';
           when $drireturn <> '*OK';
             pErrMsg = 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
         endsl;

         return;
      /end-free
