      *===================================================================
      *
      *  Name .......... ORDDM1_KHL
      *  Description ... Order Detail Misc. Field 1 - Kohl Wholesale
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
KHL A *   07/17/18  MLB  KHL
      *     - Created.
      *     - Enh: Enh: Add field for Batch Pick Y/N.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_khl      ds
     D  khldm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     Difddm1_ombatpck                 1    overlay(khldm1_base:1)
     D*                                    text('NDS Batch Pick Y/N')
     Dkhldm1_filall                   1    overlay(khldm1_base:4)
     D*                                    text('NDS Fill All Y/N')
