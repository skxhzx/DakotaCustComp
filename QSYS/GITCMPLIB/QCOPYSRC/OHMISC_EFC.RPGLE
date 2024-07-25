      *===================================================================
      *
      *  Name .......... OHMISC_EFC
      *  Description ... ORDH - OHMISC Field - Eastland Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   09/11/11  MLB  6.40
      *     - Created.
640aA *   09/28/11  MLB  6.40a
      *     - Revised to add field for Host customer number.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_cpc      ds

     D  efcmsc_base                  20
     D*                                    text('OHMISC Field')

     Defcmsc_ohdlvdte                 6    overlay(efcmsc_base:1)
     D*                                    text('Delivery Date')
     Defcmsc_ohspp                    3    overlay(efcmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Defcmsc_ohsubs                   1    overlay(efcmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Defcmsc_ohcanx                   1    overlay(efcmsc_base:11)
     D*                                    text('Order Cancelled 1=Yes,0=No')
640aADefcmsc_ohhcst                   9    overlay(efcmsc_base:12)
640aAD*                                    text('Host Customer Number')
