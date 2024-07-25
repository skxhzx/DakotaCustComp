      *===================================================================
      *
      *  Name .......... OHMISC_FRF
      *  Description ... ORDH - OHMISC Field - PFG/Fox River Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   06/06/13  MLB  6.50
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_frf      ds

     D  frfmsc_base                  20
     D*                                    text('OHMISC Field')

     Dfrfmsc_ohspp                    3    overlay(frfmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dfrfmsc_ohload                   3    overlay(frfmsc_base:11)
     D*                                    text('Host Load Number')
