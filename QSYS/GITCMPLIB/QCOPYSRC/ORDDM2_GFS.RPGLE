      *===================================================================
      *
      *  Name .......... ORDDM2_GFS
      *  Description ... Order Detail Misc. Field 2 - Get Fresh Sales
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   06/12/13  MLB  6.50
      *     - Created.
      *
      *===================================================================
      * Client Custom Revisions: Get Fresh Sales
      *
GFS A *   08/03/13  MLB  GFS
      *     - Created to store up qty conversion flag, item and conversion
      *       qty multiplier and original order qty's.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_gfs      ds

     D  gfsdm2_base                  40
     D*                                    text('Detail Misc 2 Field')
GFS AD  gfsdm2_omupcv                 1A   overlay(gfsdm2_base:1)
GFS AD*                                    text('GFS Order Qty UpConverted -'
GFS AD*                                    Flag Y/N')
GFS ADgfsdm2_omorditm                15A   overlay(gfsdm2_base:2)
GFS AD*                                    text('GFS Ordered Item')
GFS AD gfsdm2_omcvqty                 3S 0 overlay(gfsdm2_base:17)
GFS AD*                                    text('Order Qty UpConversion factor')
GFS AD gfsdm2_omorgq1                 5S 0 overlay(gfsdm2_base:20)
GFS AD*                                    text('Original Order Qty 1')
GFS AD gfsdm2_omorgq2                 5S 0 overlay(gfsdm2_base:25)
GFS AD*                                    text('Original Order Qty 2')
GFS AD gfsdm2_omorgq3                 5S 0 overlay(gfsdm2_base:30)
GFS AD*                                    text('Original Order Qty 3')
