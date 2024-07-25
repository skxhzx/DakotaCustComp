      *===================================================================
      *
      *  Name .......... ORDDM2_CSP
      *  Description ... Order Detail Misc. Field 2 - CSP
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   02/18/13  MLB  6.50  P#01102
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: Coastal Sunbelt Produce
      *
CSP A *   02/18/13  MLB  CSP
      *     - Created to store up qty conversion flag, item and conversion
      *       qty multiplier and original order qty's.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_csp      ds

     D  cspdm2_base                  40
     D*                                    text('Detail Misc 2 Field')
     D  cspdm2_omupcv                 1A   overlay(cspdm2_base:1)
     D*                                    text('CSP Order Qty UpConverted -'
     D*                                    Flag Y/N')
     Dcspdm2_omorditm                15A   overlay(cspdm2_base:2)
     D*                                    text('CSP Ordered Item')
     D cspdm2_omcvqty                 3S 0 overlay(cspdm2_base:17)
     D*                                    text('Order Qty UpConversion factor')
     D cspdm2_omorgq1                 5S 0 overlay(cspdm2_base:20)
     D*                                    text('Original Order Qty 1')
     D cspdm2_omorgq2                 5S 0 overlay(cspdm2_base:25)
     D*                                    text('Original Order Qty 2')
     D cspdm2_omorgq3                 5S 0 overlay(cspdm2_base:30)
     D*                                    text('Original Order Qty 3')
