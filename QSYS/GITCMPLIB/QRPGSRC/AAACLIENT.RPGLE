     *----------------------------------------------------------------
     *
     *  AAACLIENT   Template for using CLIENT data area
     *  03 December 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    12/03/04  DAS  5.00
     *      -  Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes:
     *
     *   Sections are identified by comments surrounded by "=======".
     *
     *----------------------------------------------------------------

     *================================================================
     * Example "Revisions" comment.
     *================================================================

500 A*    12/03/04  DAS  5.00
     *      - Enh: Revised program to add support for Client id

     *================================================================
     * Example Called program definition and /COPY statements.
     *   These should be put after 'E' specs.
     *   Only insert /COPY lines that are needed for custom mods.
     *================================================================

500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*----------------------------------------------------------------
500 A
500 A /copy qcopysrc,id#allen
500 A /copy qcopysrc,id#birite
500 A /copy qcopysrc,id#cheney
500 A /copy qcopysrc,id#citylin
500 A /copy qcopysrc,id#donsons
500 A /copy qcopysrc,id#jordano
500 A /copy qcopysrc,id#kwiktrp
500 A /copy qcopysrc,id#ledyard
500 A /copy qcopysrc,id#packers
500 A /copy qcopysrc,id#westsid
500 A
     *================================================================
     * Example code to get client id.
     *   This code only needs to be run once.
     *   Normally would go in the ZZINZ routine.
     *================================================================
500 A
500 A* Get client id.
500 A
500 AC                   call      'GETCLIENT'
500 AC                   parm                    client           10
500 A
     *================================================================
     * Example IF statements.
     * Note: If the changes are extensive, call a subroutine.
     *       Always try to keep the standard code readable.
     *================================================================

ALN AC                   if        client = allen
ALN AC                   endif

ALN AC                   if        client = birite
ALN AC                   endif

CBI AC                   if        client = cheney
CBI AC                   endif

CLD AC                   if        client = cityline
CLD AC                   endif

CLD AC                   if        client = donsons
CLD AC                   endif

KWT AC                   if        client = jordanos
KWT AC                   endif

KWT AC                   if        client = kwiktrip
KWT AC                   endif

PCK AC                   if        client = ledyard
PCK AC                   endif

PCK AC                   if        client = packers
PCK AC                   endif

WST AC                   if        client = westside
WST AC                   endif

     *================================================================
     * Example SELECT statements.
     * Note: If the changes are extensive, call a subroutine.
     *       Always try to keep the standard code readable.
     *================================================================

     C                   select

ALN AC                   when      client = allen

ALN AC                   when      client = birite

CBI AC                   when      client = cheney

CLD AC                   when      client = cityline

CLD AC                   when      client = donsons

KWT AC                   when      client = kwiktrip

KWT AC                   when      client = jordanos

KWT AC                   when      client = ledyard

PCK AC                   when      client = packers

WST AC                   when      client = westside

WST AC                   endsl
