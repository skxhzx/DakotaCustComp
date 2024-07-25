      *===================================================================
      *
      *  Name .......... C#PROD
      *  Description ... Dakota realtime interface layout for  PROD
      *  Created by .... Kenneth Elder
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   04/28/14  KDE  6.50
      *     - Created.
700 A *   04/10/15  KDE  7.00
      *     - Added fields to support Box Breaker app
      *     - Changed version number to 1
710 A *   01/23/17  KDE  7.10
      *     - Added fields to support Primal and Subprimal Meat Production
      *     - Changed version number to 3
710aA *   02/13/17  KDE  7.10a
      *     - Changed version number to 4
      *     - Added field for RM UCI for Dry Age Production
720 A *   12/11/18  KDE  7.20
      *     - Changed version number to 5
      *     - Changed some field lengths, renamed old short fields and
      *       added new longer fields at bottom
730 A *   01/30/19  KDE  7.30
      *     - Added Breakdown fields for Component Work Orders
730aA *   02/25/19  KDE  7.30a
      *     - Added Breakdown Fields for Make Quantity Component Work Order
730bA *   03/01/19  KDE  7.30b
      *     - Added Breakdown Fields for Quantity overrides
730cA *   08/21/19  KDE  7.30c
      *     - Fixed $PPWIPA.  Should be 3 characters long
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *
      *===================================================================
     D $pprod          ds                  inz
720 DD* $ppver#                       2s 0 Inz(4)
730 DD* $ppver#                       2s 0 Inz(5)
730aAD* $ppver#                       2s 0 Inz(6)
730bAD* $ppver#                       2s 0 Inz(7)
730bAD* $ppver#                       2s 0 Inz(8)
730bAD  $ppver#                       2s 0 Inz(9)

     D  $ppwhse                       3s 0
     D   $ppwhsee                     1
     D   $ppwhseu                      n
     D  $ppwhdp                       5
     D   $ppwhdpe                     1
     D   $ppwhdpu                      n
     D  $ppitem                      15
     D   $ppiteme                     1
     D   $ppitemu                      n
     D  $pplneno                      3s 0
     D   $pplnenoe                    1
     D   $pplnenou                     n
     D  $ppscale                      2
     D   $ppscalee                    1
     D   $ppscaleu                     n
     D  $ppcust                      11s 0
     D   $ppcuste                     1
     D   $ppcustu                      n
     D  $ppqty1                       5s 0
     D   $ppqty1e                     1
     D   $ppqty1u                      n
     D  $ppqty2                       5s 0
     D   $ppqty2e                     1
     D   $ppqty2u                      n
     D  $ppqty3                       5s 0
     D   $ppqty3e                     1
     D   $ppqty3u                      n
     D  $ppwgt                        9s 2
     D   $ppwgte                      1
     D   $ppwgtu                       n
     D  $pptare                       5s 2
     D   $pptaree                     1
     D   $pptareu                      n
     D  $ppuom                        2
     D   $ppuome                      1
     D   $ppuomu                       n
650aAD  $ppprntr                     10
650aAD   $ppprntre                    1
650aAD   $ppprntru                     n
650aAD  $pptype                       1
650aAD   $pptypee                     1
650aAD   $pptypeu                      n
650aAD  $ppdest                       1
650aAD   $ppdeste                     1
650aAD   $ppdestu                      n
650aAD  $pplblc                       4s 0
650aAD   $pplblce                     1
650aAD   $pplblcu                      n
650aAD  $ppdesc                      40
650aAD   $ppdesce                     1
650aAD   $ppdescu                      n
650aAD  $pprcva                       3
650aAD   $pprcvae                     1
650aAD   $pprcvau                      n
650aAD  $ppshpa                       3
650aAD   $ppshpae                     1
650aAD   $ppshpau                      n
650aAD  $pppara                       3
650aAD   $ppparae                     1
650aAD   $ppparau                      n
730cAD  $ppwipaxx                     1
650aAD   $ppwipae                     1
650aAD   $ppwipau                      n
650aAD  $pprcvar                     12
650aAD   $pprcvare                    1
650aAD   $pprcvaru                     n
650aAD  $ppshpar                     12
650aAD   $ppshpare                    1
650aAD   $ppshparu                     n
650aAD  $ppparar                     12
650aAD   $ppparare                    1
650aAD   $pppararu                     n
650aAD  $ppwipar                     12
650aAD   $ppwipare                    1
650aAD   $ppwiparu                     n
650aAD  $ppuser                      10
650aAD   $ppusere                     1
650aAD   $ppuseru                      n
650aAD  $ppToLcns                    15
650aAD   $ppToLcnse                   1
650aAD   $ppToLcnsu                    n
     D  $ppadjcde                     2
     D   $ppadjcdee                   1
     D   $ppadjcdeu                    n
     D  $ppAction                     3
     D   $ppActione                   1
     D   $ppActionu                    n
     D  $ppGs1                       50
     D   $ppGs1e                      1
     D   $ppGs1u                       n
     D  $ppSer#                      20
     D   $ppSer#e                     1
     D   $ppSer#u                      n
     D  $ppWo#                       13
     D   $ppWo#e                      1
     D   $ppWo#u                       n
     D  $ppprio                       2s 0
     D   $ppprioe                     1
     D   $pppriou                      n
     D  $pporig                       1
     D   $pporige                     1
     D   $pporigu                      n
720 DD  $ppdmdqold                    4s 0
     D   $ppdmdqe                     1
     D   $ppdmdqu                      n
720 MD  $ppavlqold                    4s 0
     D   $ppavlqe                     1
     D   $ppavlqu                      n
720 MD  $ppneedold                    4s 0
     D   $ppneede                     1
     D   $ppneedu                      n
720 MD  $ppmakeold                    4s 0
     D   $ppmakee                     1
     D   $ppmakeu                      n
720 MD  $ppqtypold                    4s 0
     D   $ppqtype                     1
     D   $ppqtypu                      n
     D  $pprmavl                      1
     D   $pprmavle                    1
     D   $pprmavlu                     n
     D  $ppstat                       1
     D   $ppstate                     1
     D   $ppstatu                      n
     D  $ppSessId                    40
     D   $ppSessIde                   1
     D   $ppSessIdu                    n
     D  $ppCustWo                    15
     D   $ppCustWoe                   1
     D   $ppCustWou                    n
     D  $ppCord                       7s 0
     D   $ppCorde                     1
     D   $ppCordu                      n

      *---------------------
      * Version 2 additions
      *---------------------

     D $pprod2         ds

      * Box Breaker Case UCI
     D  $ppuci                      100
     D   $ppUCIe                      1
     D   $ppUCIu                       n
      * Box Breaker Case Pick Slot
     D  $ppdspbb                     12
     D   $ppdspbbe                    1
     D   $ppdspbbu                     n
      * Labor Transaction Number
     D  $pptrn#                       7  0
     D   $pptrn#e                     1
     D   $pptrn#u                      n

      *---------------------
710 A * Version 3 additions
710 A *---------------------
710 A
710 A * Primal Code
710 AD  $ppPrim                      20
710 AD   $ppPrime                     1
710 AD   $ppPrimu                      n
710 A * SubPrimal Code
710 AD  $ppSubPrim                   20
710 AD   $ppSubPrime                  1
710 AD   $ppSubPrimu                   n
710 A * Primary/Sequence Code
710 AD  $ppPrimary                    3
710 AD   $ppPrimarye                  1
710 AD   $ppPrimaryu                   n

      *---------------------
710bA * Version 4 addition
710bA *---------------------
710bA
710bA * Raw MAterial UCi for Dry Age Production
710bAD  $ppRmUci                    100
710bAD   $ppRmUciE                    1
710bAD   $ppRmUciU                     n
710bA * Expiration Date for Production
710bAD  $ppExpDt                      8  0
710bAD   $ppExpDtE                    1
710bAD   $ppExpDtU                     n
710bA * MultiDay Production Line
710bAD  $ppMultiDy                    1
710bAD   $ppMultiDye                  1
710bAD   $ppMultiDyu                   n

720 A *---------------------
720 A * Version 5 addition
720 A *   Actually changing length of fields below from 4 to 5
720 A *---------------------
720 Ad  $ppavlq                       5s 0
720 Ad  $ppdmdq                       5s 0
720 Ad  $ppneed                       5s 0
730aMd  $ppmakeold2                   5s 0
720 Ad  $ppqtyp                       5s 0

730 A *---------------------
730 A * Version 6 addition
730 A *   Add new fields to track multi level BOMS
730 Ad  $ppcbd1                      10s 0
     d  $ppcbd1e                      1
     d  $ppcbd1u                       n
730 Ad  $ppcbd2                      10s 0
     d  $ppcbd2e                      1
     d  $ppcbd2u                       n
730 Ad  $ppovrd                      10s 0
     d  $ppovrde                      1
     d  $ppovrdu                       n
730 Ad  $ppdel                        1
     d  $ppdele                       1
     d  $ppdelu                        n
730aA *---------------------
730aA * Version 7 addition
730aA *   Add new fields to track make quantity for breakdowns
730aA *    case quantity for work order only demand
730aAd  $ppcnrm                      10s 0
     d  $ppcnrme                      1
     d  $ppcnrmu                       n
730aAd  $ppmake1                      6s 0
     d  $ppmake1e                     1
     d  $ppmake1u                      n
730aAd  $ppmake2                      6s 0
     d  $ppmake2e                     1
     d  $ppmake2u                      n
730aAd  $ppmake                       6s 0
730bA *---------------------
730bA * Version 8 addition
730bA *   Add new fields to track make override quantities
730bA *    at breakdown level
730bAd  $ppovr1                      10s 0
730bAd  $ppovr1e                      1
730bAd  $ppovr1u                       n
730bAd  $ppovr2                      10s 0
730bAd  $ppovr2e                      1
730bAd  $ppovr2u                       n
730cA *---------------------
730cA * Version 9 addition
730cA *   Add new fields to track make override quantities
730cA *    at breakdown level
730cAD  $ppwipa                       3
