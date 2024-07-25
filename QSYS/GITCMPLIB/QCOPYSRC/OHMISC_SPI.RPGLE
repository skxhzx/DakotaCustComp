      *===================================================================
      *
      *  Name .......... OHMISC_SPI
      *  Description ... ORDH - OHMISC Field - Stern Produce
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

     D ohmisc_spi      ds

     D  spimsc_base                  20
     D*                                    text('OHMISC Field')

     Dspimsc_ohdlvdte                 6    overlay(spimsc_base:1)
     D*                                    text('Delivery Date')
     Dspimsc_ohspp                    3    overlay(spimsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dspimsc_ohsubs                   1    overlay(spimsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dspimsc_ohfil1                   1    overlay(spimsc_base:11)
     D*                                    text('Unknown      Y/N')
     Dspimsc_ohcins                   1    overlay(spimsc_base:12)
     D*                                    text('Customer Instructions Y/N')
     Dspimsc_ohsubstp                 3    overlay(spimsc_base:13)
     D*                                    text('Customer Sub-Stop Sequence')
