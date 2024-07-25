      *===================================================================
      *
      *  Name .......... ORDDM1_KFS
      *  Description ... Order Detail Misc. Field 1 - Kelly's Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   09/18/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_kfs      ds

     D  kfsdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dkfsdm1_ombchpck                 1    overlay(kfsdm1_base:1)
     D*                                    text('Batch Pick Flag Y/N')
