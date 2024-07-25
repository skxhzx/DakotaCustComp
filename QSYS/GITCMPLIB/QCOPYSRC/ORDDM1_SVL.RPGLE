      *===================================================================
      *
      *  Name .......... ORDDM1_SVL
      *  Description ... Order Detail Misc. Field 1 - Saval Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   07/28/09  MLB  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_svl      ds

     D  svldm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dsvldm1_omkytype                 1    overlay(svldm1_base:1)
     D*                                    text('NDS Key Type')
     Dsvldm1_omtypcde                 2    overlay(svldm1_base:2)
     D*                                    text('NDS Type Code')
     Dsvldm1_filall                   1    overlay(svldm1_base:4)
     D*                                    text('NDS Fill All Y/N')
