      *===================================================================
      *
      *  Name .......... ORDDM4_YHA
      *  Description ... Order Detail Misc. Field 4 - Yhata
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   08/14/12  JCJ  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm4_yha      ds

     D  yhadm4_base                  40
     D*                                    text('Detail Misc 4 Field')
YHA AD  yhadm4_ohpo                  14    overlay(yhadm4_base:1)
YHA AD*                                    text('Navy P/O Number')
