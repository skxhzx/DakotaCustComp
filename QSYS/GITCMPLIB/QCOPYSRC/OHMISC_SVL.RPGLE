      *===================================================================
      *
      *  Name .......... OHMISC_SVL
      *  Description ... OHMISC field - Saval
      *  Created by .... Jeffrey Jahnke
      *
      *-------------------------------------------------------------------
      * Revisions
      *
520 A *   03/05/09  JCJ  5.20
      *     - Created.
      *
720 A *   04/18/18  MLB  7.20
      *     - Updated copy spec to add missing fields.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_svl      ds

     D  svlmsc_base                  20
     D*                                    text('OHMISC Field')

     D  svlmsc_Date                   6    overlay(svlmsc_base:1)
     D*                                    text('Delivery Date')
720 AD  svlmsc_ohspp                  3    overlay(svlmsc_base:7)
720 AD*                                    text('*SP Single Pallet Pick')
720 AD  svlmsc_ohsubs                 1    overlay(svlmsc_base:10)
720 AD*                                    text('Sub Customer Y/N')
720 AD  svlmsc_ohcust                 5    overlay(svlmsc_base:11)
720 AD*                                    text('NDS Customer Nbr')
