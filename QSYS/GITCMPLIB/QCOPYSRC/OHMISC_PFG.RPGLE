      *===================================================================
      *
      *  Name .......... OHMISC_PFG
      *  Description ... OHMISC field - PFG Performance Food Group
      *  Created by .... Max Blacknik
      *
      *-------------------------------------------------------------------
      * Revisions
      *
720 A *   11/27/18  MLB  7.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_pfg      ds

     D  pfgmsc_base                  20
     D*                                    text('OHMISC Field')

     D  pfgmsc_Date                   6    overlay(pfgmsc_base:1)
     D*                                    text('Delivery Date')
     D  pfgmsc_ohspp                  3    overlay(pfgmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     D  pfgmsc_ohsubs                 1    overlay(pfgmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     D  pfgmsc_ohdkdr                 3    overlay(pfgmsc_base:11)
     D*                                    text('PFG Dock Door')
