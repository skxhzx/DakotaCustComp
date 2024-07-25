      *===================================================================
      *
      *  Name .......... ORDDM4_CTW
      *  Description ... Order Detail Misc. Field 4 - City Wholesale
      *  Created by .... Max Blacknik
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

     D orddm4_ctw      ds

     D  ctwdm4_base                  40
     D*                                    text('Detail Misc 4 Field')
     D  ctwdm4_rcapn1                15    overlay(ctwdm4_base:1)
     D*                                    text('Recap jurisdiction name1')
     D  ctwdm4_rcapn2                15    overlay(ctwdm4_base:16)
     D*                                    text('Recap jurisdiction name2')
     D  ctwdm4_rtaxam                 8    overlay(ctwdm4_base:31)
     D*                                    text('Recap tax amount')
