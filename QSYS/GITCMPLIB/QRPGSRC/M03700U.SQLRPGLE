      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M03700U     Maintain TRUCKT file
     *  26 June 2015
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/26/15  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

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


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDPCombo    Dictionary/Program combo
     *      pCmd        Command
     *      pWhse       Warehouse
     *      pTruck      Truck
     *      pTrl        Trailer
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
     C                   parm                    pCmd             10
     C                   parm                    pWhse             3 0
     C                   parm                    pTruck           10
     C                   parm                    pTrl              8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

       pTruck = %xlate(xlower: xupper: pTruck);
         // If Trailer is blank - do nothing
         if Ptrl = ' ';
           return;
         endif;
         // Do what is requested
         Select;
           When Pcmd = 'Add';
             exec sql insert into truckt
             values(:pWhse, :pTruck, :Ptrl);
             If sqlstt = sqlSuccess;
             endif;

           When PCmd = 'Delete';
             exec sql delete from truckt
                      where ttwhse  = :pwhse
                        and tttruk  = :ptruck;
             If sqlstt = sqlNoData;
             endif;
           When PCmd = 'Change';
             exec sql update truckt
                      set tttrlr = :ptrl
                      where ttwhse  = :pwhse
                        and tttruk  = :ptruck;
             If sqlstt = sqlNoData;
               // need to add the record
               exec sql insert into truckt
               values(:pWhse, :pTruck, :Ptrl);
               If sqlstt = sqlSuccess;
               endif;
             endif;
           other;
             return;
         endsl;
      /end-free
