      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTDKTIMP   Test DKTIMPORT
     *  12 February 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D dktimport       pr                  extpgm('DKTIMPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
     D   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     * Input parameters
     *----------------------------------------------------------------

     D $pWhse15        S             15p 5
     D $pWhse3         S              3p 0
     D $pType          S             10
     D $pBatId         S             11
     D $pRunType       S              1

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  pReturn        s             10
     D  pMessage       s            200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse   Warehouse
     *      $pType   Import type
     *      $pBatId  Batch Id
     *      $pRunType  Run type (I=Interactive, J=Jobq)
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        Plist
     c                   Parm                    $pWhse15
     c                   Parm                    $pType
     c                   Parm                    $pBatId
     c                   Parm                    $pRunType

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         $pWhse3 = $pWhse15;

         DktImport($pWhse3: $pType: $pBatId: $pRunType:
                   'TSTDKTIMP': pReturn: pMessage);

         if pReturn <> '*OK';
           dsply pReturn;
           dsply %subst(pMessage:1:32);
         endif;

         return;
      /end-free
