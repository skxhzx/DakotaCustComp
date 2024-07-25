      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETPCKSLT  Get pick slot
     *  22 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/22/14  DAS  6.50
     *      - Created.
     *
720aA*    10/12/18  DAS  7.20a
     *      - If $puser starts with '*', use it as the command
     *        to GETPSLT.
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
     D  pSlot          s             12

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  pcmd           s              8
     D  pAisl          s              3
     D  pLoc           s              2  0
     D  pRLvl          s              2  0
     D  pHand          s              2
     D  pRtn           s              8
     D  pPSeq          s              5  0

     D  pSlotItm       s             15
     D  pityp          s              1
     D  pdesc          s             30
     D  ppdsc          s             15
     D  prtn10         s             10
     D  pmsg           s             60

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     D GetPSlt         pr                  extpgm('GETPSLT')
     D  pcmd                          8    const
650cMD  pWhse                         3  0
     D  pItem                        15
     D  pDisp                        12
     D  pAisl                         3
     D  pLoc                          2  0
     D  pRLvl                         2  0
     D  pHand                         2
     D  pRtn                          8
     D  pPSeq                         5  0

     D GetSlotItm      pr                  extpgm('GETSLOTITM')
650cMD  pWhse                         3  0
     D  pItem                        15
     D  pSlotItm                     15
     D  pityp                         1
     D  pdesc                        30
     D  ppdsc                        15
     D  prtn10                       10
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
     *      pSlot        Pick slot
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     C                   parm                    pItem
     c                   parm                    pUser
     c                   parm                    pSlot

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
720aA
720aA   // If pUser starts with '*', use it for command
720aA   // Otherwise, use *FIRST
720aA
720aA   if %subst(pUser:1:1) = '*';
720aA     pCmd = pUser;
720aA   else;
720aA     pCmd = '*FIRST';
720aA   endif;

        // Try getting slot for sent item

720aD   //GetPSlt('*FIRST':
720aM   GetPSlt(pCmd:
650cM           pWhse:
                pItem:
                pSlot:
                pAisl:
                pLoc:
                pRLvl:
                pHand:
                pRtn:
                pPSeq);

        // If slot found, return

        if pRtn <> '*NONE';
          return;
        endif;

        // Otherwise, see if there is corresponding slot item

        GetSlotItm(pWhse:
                   pItem:
                   pSlotItm:
                   pityp:
                   pdesc:
                   ppdsc:
                   prtn10:
                   pmsg);

        // If slot item not found or slot item is same as sent item,
        // Then return with no pick slot.

        if pRtn10 <> '*OK'
          or pSlotItm = pItem;
          pSlot = '';
          return;
        endif;

        // Try getting pick slot for slot item

720aD   //GetPSlt('*FIRST':
720aM   GetPSlt(pCmd:
650cM           pWhse:
                pSlotItm:
                pSlot:
                pAisl:
                pLoc:
                pRLvl:
                pHand:
                pRtn:
                pPSeq);

        if pRtn = '*NONE';
          pSlot = '';
        endif;

        return;
      /end-free
