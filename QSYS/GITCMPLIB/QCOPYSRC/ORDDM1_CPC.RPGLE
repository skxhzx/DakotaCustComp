      *===================================================================
      *
      *  Name .......... ORDDM1_CPC
      *  Description ... Order Detail Misc. Field 1 - Crumbley Paper
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   02/28/11  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_cpc      ds

     D  cpcdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dcpcdm1_ombchpck                 1    overlay(cpcdm1_base:1)
     D*                                    text('Batch Pick Flag Y/N')
     Dcpcdm1_omchemcd                 3    overlay(cpcdm1_base:2)
     D*                                    text('CPC Chem Code Color')
