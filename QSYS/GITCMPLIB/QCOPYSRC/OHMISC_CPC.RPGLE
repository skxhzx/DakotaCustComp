      *===================================================================
      *
      *  Name .......... OHMISC_CPC
      *  Description ... ORDH - OHMISC Field - Crumbley Paper & Foodservice
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   02/28/11  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_cpc      ds

     D  cpcmsc_base                  20
     D*                                    text('OHMISC Field')

     Dcpcmsc_ohdlvdte                 6    overlay(cpcmsc_base:1)
     D*                                    text('Delivery Date')
     Dcpcmsc_ohspp                    3    overlay(cpcmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dcpcmsc_ohsubs                   1    overlay(cpcmsc_base:10)
     D*                                    text('Sub Customer Y/N')
