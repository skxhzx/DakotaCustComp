      *===================================================================
      *
      *  Name .......... OHMISC_SFP
      *  Description ... ORDH - OHMISC Field - Seashore Fruit & Produce
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
SFP A *   11/17/22  MLB  SFP
      *     - Created.
      *
      *===================================================================
      *
      * Notes: This OHMISC layout is for use with SFP's Thyme ERP.
      *
      *===================================================================

     D ohmisc_sfp      ds

     D  sfpmsc_base                  20
     D*                                    text('OHMISC Field')

     Dsfpmsc_ohdlvdte                 6    overlay(sfpmsc_base:1)
     D*                                    text('Delivery Date')
     Dsfpmsc_ohspp                    3    overlay(sfpmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dsfpmsc_ohsubs                   1    overlay(sfpmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dsfpmsc_ohccar                   1    overlay(sfpmsc_base:11)
     D*                                    text('Critical Care Y/N')
     Dsfpmsc_ohcins                   1    overlay(sfpmsc_base:12)
     D*                                    text('Customer Instructions Y/N')
