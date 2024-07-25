      *===================================================================
      *
      *  Name .......... ORDDM1_GFS
      *  Description ... Order Detail Misc. Field 1 - Get Fresh Sales
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   06/12/13  MLB  6.50
      *     - Created.
      *
GFS A *   02/27/18  MLB  GFS
      *     - Added new field, CPARTNO (Stratten-Warren) part number.
      *       per Andrew M. phone call 02.27.18.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_gfs      ds

     D  gfsdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dgfsdm1_ombchpck                 1    overlay(gfsdm1_base:1)
     D*                                    text('Batch Pick Flag Y/N')
     Dgfsdm1_omcmbflg                 1    overlay(gfsdm1_base:2)
     D*                                    text('GFS Print Combo Lbl Y/N')
GFS ADgfsdm1_omcprtno                15    overlay(gfsdm1_base:3)
GFS AD*                                    text('GFS Cust Part Nbr')
GFS AD*                                    text('Stratten-Warren Part Nbr')
