      *===================================================================
      *
      *  Name .......... OHMISC_KHL
      *  Description ... OHMISC field - Kohl Wholesale
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

     D ohmisc_khl      ds

     D  khlmsc_base                  20
     D*                                    text('OHMISC Field')

     D  khlmsc_Date                   6    overlay(khlmsc_base:1)
     D*                                    text('Delivery Date')
     D  khlmsc_ohspp                  3    overlay(khlmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     D  khlmsc_ohsubs                 1    overlay(khlmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     D  khlmsc_ohcust                 5    overlay(khlmsc_base:11)
     D*                                    text('NDS Customer Nbr')
