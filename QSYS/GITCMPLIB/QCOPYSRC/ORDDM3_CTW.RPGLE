      *===================================================================
      *
      *  Name .......... ORDDM3_CTW
      *  Description ... Order Detail Misc. Field 3 - City Wholesale
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

     D orddm3_ctw      ds

     D  ctwdm3_base                  40
     D*                                    text('Detail Misc 3 Field')
     D  ctwdm3_cijurn                15    overlay(ctwdm3_base:1)
     D*                                    text('City jurisdiction name')
     D  ctwdm3_dtecde                 2    overlay(ctwdm3_base:16)
     D*                                    text('Date code')
     D  ctwdm3_dealcd                 5    overlay(ctwdm3_base:20)
     D*                                    text('Deal code')
     D  ctwdm3_recapf                 1    overlay(ctwdm3_base:25)
     D*                                    text('Recap flag')
     D  ctwdm3_Taxamt                 8    overlay(ctwdm3_base:26)
     D*                                    text('Tax amount')
