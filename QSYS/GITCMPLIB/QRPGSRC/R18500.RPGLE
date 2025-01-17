      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M19200H  Get Item Maintenance options for UOM weight
     *  28 March 2016
     *  Lynn McMahon
     *
     *  Revisions
     *
700  *    03/28/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------



     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  psessid        s             40
     D  pWhse          s              3p 0
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     D kilolbs         s              1
     D IMuom           s              3

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D*getimuom        pr                  extpgm('GETIMUOM')
      * Input
     D*  pwhse                        3  0
     D*  pkilolbs                     1
     D*  pIMUom                       3

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessid      Session id
     *      pWhse        Warehouse
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         getimuom(pwhse: kilolbs: IMUom);

         // Start JSON string

         pOutStr = '{';


         pOutStr = %trimr(pOutStr)
                 +  '"kilolbs":"' + kilolbs + '",'
                 +  '"IMUom":"' + %trimr(IMUom) + '"';

         // Close JSON string

         pOutStr = %trimr(pOutStr)
                 +  '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

