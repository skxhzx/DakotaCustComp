      *===================================================================
      *
      *  Name .......... ORDDM1_MAT
      *  Description ... Order Detail Misc. Field 1 - Mattingly
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   08/11/09  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_mat      ds

     D  matdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dmatdm1_ombchpck                 1    overlay(matdm1_base:1)
     D*                                    text('Batch Pick Flag')
