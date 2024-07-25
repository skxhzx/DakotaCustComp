      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETSLTITM  Get slot item
     *  23 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/23/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pItem          s             15
     D  pUser          s             10
     D  pSlotItm       s             15

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  pityp          s              1
     D  pdesc          s             30
     D  ppdsc          s             15
     D  prtn           s             10
     D  pmsg           s             60

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     D GetSlotItm      pr                  extpgm('GETSLOTITM')
650cMD  pWhse                         3  0
     D  pItem                        15
     D  pSlotItm                     15
     D  pityp                         1
     D  pdesc                        30
     D  ppdsc                        15
     D  prtn                         10
     D  pmsg                         60

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pItem        Item
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pSlotItm     Slot Item
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     C                   parm                    pItem
     c                   parm                    pUser
     c                   parm                    pSlotItm

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        GetSlotItm(pWhse:
                   pItem:
                   pSlotItm:
                   pityp:
                   pdesc:
                   ppdsc:
                   prtn:
                   pmsg);

        if pRtn <> '*OK';
          pSlotItm = pItem;
        endif;

        return;
      /end-free
