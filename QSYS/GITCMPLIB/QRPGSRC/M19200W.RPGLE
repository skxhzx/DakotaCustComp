      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M19200W  Override Po CW total warnings
     *  13 January 2016
     *  Lynn McMahon
     *
     *  Revisions
     *
700  *    01/13/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
     Fpirhold   uf a e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D m19200u         pr                  extpgm('M19200U')
     D  message                      99
     D  session                      40
     D  user                         10
     D  pgm                          10
     D  whse                          3p 0
     D  PO                            9
     D  seq#                          5p 0
     D  item                         15
     D  entry                       100
     D  key                          50
     D  qty1                          5p 0
     D  qty2                          5p 0
     D  qty3                          5p 0
     D  ndcwtck                       1
     D  cwtckw                        1
     D  ndcweck                       1
     D  cweckw                        1
     D  ndtwtck                       1
     D  twtckw                        1
     D  twgt                          9p 2
     D  action                        1


     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  pirhold structures
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDCT

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
     D  pPo            s              9
     D  pPOSeq         s              5  0
     D  pPoItem        s             15
     D  pType          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D cCmd            s             10    inz(' ')
     D chrOutStr       s            512
     D pokey           s             50

     D message         s             99
     D session         s             40
     D user            s             10
     D pgm             s             10
     D whse            s              3p 0
     D PO              s              9
     D seq#            s              5p 0
     D item            s             15
     D entry           s            100
     D key             s             50
     D qty1            s              5p 0
     D qty2            s              5p 0
     D qty3            s              5p 0
     D ndcwtck         s              1
     D cwtckw          s              1
     D ndcweck         s              1
     D cweckw          s              1
     D ndtwtck         s              1
     D twtckw          s              1
     D twgt            s              9p 2
     D action          s              1
     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessid      Session id
     *      pWhse        Warehouse
     *      pPO          PO#
     *      pPOSeq       PO Seq#
     *      pPOItem      PO Item
     *      pType        Warning Type
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    pType
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // update the pirhold PODTLCT record
        hotype = 'PODTLCT';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        chain (psessid: hotype: pokey) pirhold;
        if %found(pirhold);
          pirhldctds = hodata;
          select;
            when pType = 'count';
              cntflag = '3';
              pOutStr = '{'
                     +  '"rtn":"' + '*OK' + '",'
                     +  '"msg":"' + 'Count warning overriden' + '"'
                     +  '}';
            when pType = 'variance';
              varflag = '3';
              pOutStr = '{'
                     +  '"rtn":"' + '*OK' + '",'
                     +  '"msg":"' + 'Total Weight Warning overriden' + '"'
                     +  '}';
            when pType = 'done';
              // No pending overrides can exist
              select;
                when cntflag = '1';
                  pOutStr = '{'
                         +  '"rtn":"' + '*NO' + '",'
                         +  '"msg":"' + 'Not eligible for completion' + '"'
                         +  '}';
                when cntflag = '2';
                  pOutStr = '{'
                         +  '"rtn":"' + '*NO' + '",'
                         +  '"msg":"' + 'Not eligible for completion' + '"'
                         +  '}';
                when varflag = '2';
                  pOutStr = '{'
                         +  '"rtn":"' + '*NO' + '",'
                         +  '"msg":"' + 'Not eligible for completion' + '"'
                         +  '}';
                other;
                  pOutStr = '{'
                         +  '"rtn":"' + '*OK' + '",'
                         +  '"GFN09201":"' + %char(svtcw) + '",'
                         +  '"msg":"' + 'Proceed with completion' + '"'
                         +  '}';
                  // call the update program to do the final processing
                  message = ' ';
                  session = pSessId;
                  user    = ' ';
                  pgm     = ' ';
                  whse    = pWhse;
                  PO      = pPO;
                  seq#    = pPOSeq;
                  item    = pPOItem;
                  entry   = ' ';
                  key     = ' ';
                  qty1    = 0;
                  qty2    = 0;
                  qty3    = 0;
                  ndcwtck = ' ';
                  cwtckw  = ' ';
                  ndcweck = ' ';
                  cweckw  = ' ';
                  ndtwtck = ' ';
                  twtckw  = ' ';
                  twgt    = 0;
                  action  = 'F';

         m19200u(message :
                 session :
                 user :
                 pgm :
                 whse :
                 PO :
                 seq# :
                 item :
                 entry :
                 key :
                 qty1 :
                 qty2 :
                 qty3 :
                 ndcwtck :
                 cwtckw :
                 ndcweck :
                 cweckw :
                 ndtwtck :
                 twtckw :
                 twgt   :
                 action );

              endsl;
            Other;
          endsl;
          hodata = pirhldctds;
          update horec;
        else;
        endif;


        return;
      /end-free
