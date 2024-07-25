      *===================================================================
      *
      *  Name .......... OHMISC_CCP
      *  Description ... ORDH - OHMISC Field - Capitol City Produce
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   01/30/13  MLB  6.50
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_ccp      ds

     D  ccpmsc_base                  20
     D*                                    text('OHMISC Field')

     Dccpmsc_ohdlvdte                 6    overlay(ccpmsc_base:1)
     D*                                    text('Delivery Date')
     Dccpmsc_ohspp                    3    overlay(ccpmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dccpmsc_ohsubs                   1    overlay(ccpmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dccpmsc_ohfil1                   1    overlay(ccpmsc_base:11)
     D*                                    text('Unknown      Y/N')
     Dccpmsc_ohcins                   1    overlay(ccpmsc_base:12)
     D*                                    text('Customer Instructions Y/N')
