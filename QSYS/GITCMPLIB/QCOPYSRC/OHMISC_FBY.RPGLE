      *===================================================================
      *
      *  Name .......... OHMISC_FBY
      *  Description ... OHMISC field - Farm Boy Foods
      *  Created by .... Jeff Jahnke
      *
      *-------------------------------------------------------------------
      * Revisions
      *
720 A *   06/29/18  JCJ  7.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_fby      ds

     D  fbymsc_base                  20
     D*                                    text('OHMISC Field')

     D  fbymsc_Date                   6    overlay(fbymsc_base:1)
     D*                                    text('Delivery Date')
     D  fbymsc_ohspp                  3    overlay(fbymsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     D  fbymsc_ohsubs                 1    overlay(fbymsc_base:10)
     D*                                    text('Sub Customer Y/N')
     D  fbymsc_ohcust                 5    overlay(fbymsc_base:11)
     D*                                    text('NDS Customer Nbr')
