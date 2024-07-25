      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M27100U     Maintain TRUCKT/TRUCKC Files
     *  06 September 2018
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    09/06/18  LMC  7.20
     *      - Created.
     *      - Copied from M03700u
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
     *      pCol        Columns
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
     C                   parm                    pCol              1 0

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
         pErrMsg = ' ';

       pTruck = %xlate(xlower: xupper: pTruck);
         // If Trailer is blank -
         // and Columns is zero - do nothing
         if Ptrl = ' ' and Pcol = 0;
           return;
         endif;
         // Do what is requested
         Select;
           when Ptrl <> ' ';
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
         Endsl;
         Select;
           when Pcol <> 0;
             // process column data
             Select;
               When Pcmd = 'Add';
                 exec sql insert into truckc
                 values(:pWhse, :pTruck, :Pcol);
                 If sqlstt = sqlSuccess;
                 endif;

               When PCmd = 'Delete';
                 exec sql delete from truckc
                      where tcwhse  = :pwhse
                        and tctruk  = :ptruck;
                 If sqlstt = sqlNoData;
                 endif;
               When PCmd = 'Change';
                 exec sql update truckc
                      set tccols = :pcol
                      where tcwhse  = :pwhse
                        and tctruk  = :ptruck;
                 If sqlstt = sqlNoData;
                   // need to add the record
                   exec sql insert into truckc
                   values(:pWhse, :pTruck, :Pcol);
                   If sqlstt = sqlSuccess;
                   endif;
                 endif;
               other;
                 return;
             endsl;
         Endsl;
      /end-free
