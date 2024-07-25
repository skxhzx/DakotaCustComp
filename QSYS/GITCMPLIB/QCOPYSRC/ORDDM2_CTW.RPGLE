      *===================================================================
      *
      *  Name .......... ORDDM2_CTW
      *  Description ... Order Detail Misc. Field 2 - City Wholesale
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   10/10/08  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_ctw      ds

     D  ctwdm2_base                  40
     D*                                    text('Detail Misc 2 Field')
     D  ctwdm2_stjurc                 3    overlay(ctwdm2_base:1)
     D*                                    text('State jurisdiction code')
     D  ctwdm2_stjurn                15    overlay(ctwdm2_base:4)
     D*                                    text('State jurisdiction name')
     D  ctwdm2_cojurc                 3    overlay(ctwdm2_base:19)
     D*                                    text('County jurisdiction code')
     D  ctwdm2_cojurn                15    overlay(ctwdm2_base:22)
     D*                                    text('County jurisdiction name')
     D  ctwdm2_cijurc                 3    overlay(ctwdm2_base:37)
     D*                                    text('City jurisdiction code')
