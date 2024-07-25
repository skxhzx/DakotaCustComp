      *===================================================================
      *
      *  Name .......... ORDDM2_DRY
      *  Description ... Order Detail Misc. Field 2 - Dairyland
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   04/10/14  MLB  6.50
      *     - Created.
      *
      *===================================================================
      * Client Custom Revisions: Dairyland
      *
DRY A *   04/10/14  MLB  DRY
      *     - Created to store up qty conversion flag, item and conversion
      *       qty multiplier and original order qty's.
      *     - For Dairyland, the quantity will remain in it's up-converted
      *       status when the order(s) are exported back to JDE. In
      *       RH155S, the qty would normally need to be down-converted to
      *       the original order qty format for both ordered/picked.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_dry      ds

     D  drydm2_base                  40
     D*                                    text('Detail Misc 2 Field')
DRY AD  drydm2_omupcv                 1A   overlay(drydm2_base:1)
DRY AD*                                    text('DRY Order Qty UpConverted -'
DRY AD*                                    Flag Y/N')
DRY ADdrydm2_omorditm                15A   overlay(drydm2_base:2)
DRY AD*                                    text('DRY Ordered Item')
DRY AD drydm2_omcvqty                 3S 0 overlay(drydm2_base:17)
DRY AD*                                    text('Order Qty UpConversion factor')
DRY AD drydm2_omorgq1                 5S 0 overlay(drydm2_base:20)
DRY AD*                                    text('Original Order Qty 1')
DRY AD drydm2_omorgq2                 5S 0 overlay(drydm2_base:25)
DRY AD*                                    text('Original Order Qty 2')
DRY AD drydm2_omorgq3                 5S 0 overlay(drydm2_base:30)
DRY AD*                                    text('Original Order Qty 3')
