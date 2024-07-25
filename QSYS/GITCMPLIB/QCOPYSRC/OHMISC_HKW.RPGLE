      *===================================================================
      *
      *  Name .......... OHMISC_HKW
      *  Description ... ORDH - OHMISC Field - Hearn Kirkwood
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   09/15/13  MLB  6.50
      *     - Created.
650aA *   12/12/13  MLB  6.50a
      *     - Enh: Added new field to flag customer orders to print OR695
      *       Audit report. Per phone call from Jeff J./ Carl W. Foodman.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_hkw      ds

     D  hkwmsc_base                  20
     D*                                    text('OHMISC Field')

     Dhkwmsc_ohdlvdte                 6    overlay(hkwmsc_base:1)
     D*                                    text('Delivery Date MMDDYY')
     Dhkwmsc_ohspp                    3    overlay(hkwmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dhkwmsc_ohsubs                   1    overlay(hkwmsc_base:10)
     D*                                    text('Sub Customer Y/N')
650aADhkwmsc_ohaudt                   1    overlay(hkwmsc_base:11)
650aAD*                                    text('Print Audit Report Y/N')
