      *===================================================================
      *
      *  Name .......... ORDDM4_KFS
      *  Description ... Order Detail Misc. Field 4 - Kelly's Foods
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

     D orddm4_kfs      ds

     D  kfsdm4_base                  40
     D*                                    text('Detail Misc 4 Field')
     Dkfsdm4_omssqdtl                16    overlay(kfsdm4_base:1)
     D*                                    text('System Sequence - Detail')
