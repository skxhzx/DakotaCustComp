      *===================================================================
      *
      *  Name .......... ORDDM5_CTW
      *  Description ... Order Detail Misc. Field 5 - City Wholesale
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   10/11/08  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm5_ctw      ds

     D  ctwdm5_base                  40
     D*                                    text('Detail Misc 5 Field')
     D  ctwdm5_upc                   15    overlay(ctwdm5_base:6)
     D*                                    text('UPC number')
