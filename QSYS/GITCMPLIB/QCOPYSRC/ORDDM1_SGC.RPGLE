      *===================================================================
      *
      *  Name .......... ORDDM1_SGC
      *  Description ... Order Detail Misc. Field 1 - Springfield Grocery
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/25/07  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_sgc      ds

     D  sgcdm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  sgcdm1_omalco                 1    overlay(sgcdm1_base:1)
     D*                                    text('Allocation override Y/N')
     D  sgcdm1_ommpck                 1    overlay(sgcdm1_base:2)
     D*                                    text('Master pack item Y/N')
