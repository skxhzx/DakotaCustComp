417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTCBIPRO    Test CBIPROTO
     *  15 February 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

     D   pWhse         s              3p 0 inz(900)
     D   pType         s             10    inz('*ALL')
     D   pRuntype      s              1    inz('S')
     D   pReturn       s             10
     D   pMessage      s            200

     D CBIProto        pr                  extpgm('CBIPROTO')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

      /free

         *inlr = *on;

         monitor;
           CBIProto(pWhse: pType:
                    pRunType: pReturn: pMessage);
         on-error;
           pReturn = '*ERRCBIPRO';
           pMessage = 'Error calling CBIProto';
         endmon;

         return;
      /end-free
