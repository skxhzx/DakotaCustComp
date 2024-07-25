417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTGETDBLL   Test GETDBLIBL
     *  03 April 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     D pDb             S             10
     D pReturn         S             10
     D pMessage        S            500

     D GetDbLibl       pr                  extpgm('GETDBLIBL')
      * Input
     D   pDb                         10    const
      * Output
     D   pReturn                     10
     D   pMessage                   500

      /free

         *inlr = *on;

         monitor;
           GetDbLibl('DSENH650': pReturn: pMessage);
         on-error;
           pReturn = '*ERRGETDBL';
           pMessage = 'Error calling GETDBLIBL';
         endmon;

         return;
      /end-free
