      *===================================================================
      *
      *  Name .......... IKMSC1_GFS
      *  Description ... Item Extension File Misc. Field 1 - Get Fresh Sales
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   08/05/13  MLB  6.50w1
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ikmsc1_gfs      ds

     D  gfsik1_base                  40
     D*                                    text('User Misc 1 Field')

     Dgfsik1_ikupcvt                  1    overlay(gfsik1_base:1)
     D*                                    text('Up-Convert Allowed Y/N')

