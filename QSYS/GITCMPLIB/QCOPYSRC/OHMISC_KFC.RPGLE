      *===================================================================
      *
      *  Name .......... OHMISC_KFC
      *  Description ... ORDH - OHMISC Field - Kelly Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   08/30/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_kfc      ds

     D  kfcmsc_base                  20
     D*                                    text('OHMISC Field')

     Dkfcmsc_ohdlvdte                 6    overlay(kfcmsc_base:1)
     D*                                    text('Delivery Date')
     Dkfcmsc_ohspp                    3    overlay(kfcmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dkfcmsc_ohsubs                   1    overlay(kfcmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dkfcmsc_ohfil1                   1    overlay(kfcmsc_base:11)
     D*                                    text('Host Filler "-"')
     Dkfcmsc_ohord                    9    overlay(kfcmsc_base:12)
     D*                                    text('Host Order Number')
