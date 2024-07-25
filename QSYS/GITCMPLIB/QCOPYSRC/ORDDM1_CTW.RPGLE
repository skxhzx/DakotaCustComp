      *===================================================================
      *
      *  Name .......... ORDDM1_CTW
      *  Description ... Order Detail Misc. Field 1 - City Wholesale
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   10/10/08  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_ctw      ds

     D  ctwdm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  ctwdm1_rtlprc                 7    overlay(ctwdm1_base:1)
     D*                                    text('Customer retail price')
     D  ctwdm1_margin                 7    overlay(ctwdm1_base:8)
     D*                                    text('Customer margin %')
     D  ctwdm1_mfgcd                  6    overlay(ctwdm1_base:15)
     D*                                    text('Customer margin %')
     D  ctwdm1_item                  10    overlay(ctwdm1_base:21)
     D*                                    text('Mfg item number')
     D  ctwdm1_t1                     1    overlay(ctwdm1_base:33)
     D*                                    text('T1')
     D  ctwdm1_t2                     1    overlay(ctwdm1_base:34)
     D*                                    text('T2')
     D  ctwdm1_t3                     1    overlay(ctwdm1_base:35)
     D*                                    text('T3')
     D  ctwdm1_prccod                 5    overlay(ctwdm1_base:36)
     D*                                    text('Price code')
