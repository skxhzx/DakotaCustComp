      *===================================================================
      *
      *  Name .......... OHMISC_ICB
      *  Description ... OHMISC field - Inter County Bakers
      *  Created by .... Max Blacknik
      *
      *===================================================================
      * Revisions
      *
700 A *   04/05/16  MLB  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_icb      ds

     D  icbmsc_base                  20
     D*                                    text('OHMISC Field')

     D  icbmsc_Date                   6    overlay(icbmsc_base:1)
     D*                                    text('Delivery Date')
     D  icbmsc_ohspp                  3    overlay(icbmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     D  icbmsc_ohsubs                 1    overlay(icbmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     D  icbmsc_ohcust                 5    overlay(icbmsc_base:11)
     D*                                    text('NDS Customer Nbr')
