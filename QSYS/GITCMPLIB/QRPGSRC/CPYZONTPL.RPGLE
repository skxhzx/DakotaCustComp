      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CPYZONTPL   Copy zone template
     *  20 Feb 2015
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/20/15  DAS  6.50
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

      /COPY *libl/qcopysrc,C#ZONEH
     D saveVer#        s                   like($zhver#)

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
     *      pSessId     Session Id
     *      pUser       User
     *      pDPCombo    Dictionary/Program combo
     *      pWhse       Warehouse
     *      pFrmTruk    From truck
     *      pNewTruk    New truck
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
     C                   parm                    pFrmTruk         10
     C                   parm                    pNewTruk         10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

         // If from truck is blank, assume normal Add and get out

         if pFrmTruk = '';
           return;
         endif;

         // Trucks cannot be the same

         if pFrmTruk = pNewTruk;
           pErrMsg = 'From/New trucks cannot be the same';
           return;
         endif;

         // Copy zones
         // Truck header will be copied by MRC

         savever# = $zhver#;
         clear $zoneh;
         $zhver# = savever#;

         $zhWhseu = *on;
         $zhWhse = pWhse;
         $zhtruku = *on;
         $zhtruk  = %xlate(xlower: xupper: pNewTruk);
         $zhfrmtruku = *on;
         $zhfrmtruk  = %xlate(xlower: xupper: pFrmTruk);

         $dricommand = '*ZONEH';
         $drisubcmd = '%COPYTPL';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $zoneh;
         $drireturn = '*OK';

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata);

         $zoneh = $dridata;

         select;
           when %error;
             pErrMsg = 'Error occured calling DRIZONEH '
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
