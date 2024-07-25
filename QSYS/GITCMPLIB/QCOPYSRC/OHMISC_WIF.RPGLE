      *===================================================================
      *
      *  Name .......... OHMISC_WIF
      *  Description ... OHMISC field - Williams Institutional Foods
      *  Created by .... Max Blacknik
      *
      *-------------------------------------------------------------------
      * Revisions
      *
720 A *   04/18/18  MLB  7.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_wif      ds

     D  wifmsc_base                  20
     D*                                    text('OHMISC Field')

     D  wifmsc_Date                   6    overlay(wifmsc_base:1)
     D*                                    text('Delivery Date')
     D  wifmsc_ohspp                  3    overlay(wifmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     D  wifmsc_ohsubs                 1    overlay(wifmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     D  wifmsc_ohcust                 5    overlay(wifmsc_base:11)
     D*                                    text('NDS Customer Nbr')
