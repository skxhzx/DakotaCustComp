      *===================================================================
      *
      *  Name .......... OHMISC_GMM
      *  Description ... OHMISC field - Graves Menu Maker
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

     D ohmisc_gmm      ds

     D  gmmmsc_base                  20
     D*                                    text('OHMISC Field')

     D  gmmmsc_Date                   6    overlay(gmmmsc_base:1)
     D*                                    text('Delivery Date')
     D  gmmmsc_ohspp                  3    overlay(gmmmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     D  gmmmsc_ohsubs                 1    overlay(gmmmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     D  gmmmsc_ohcust                 5    overlay(gmmmsc_base:11)
     D*                                    text('NDS Customer Nbr')
