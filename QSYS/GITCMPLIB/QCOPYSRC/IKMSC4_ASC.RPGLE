      *===================================================================
      *
      *  Name .......... IKMSC4_ASC
      *  Description ... Item Extension File Misc. Field 4 - Agar Supply
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   05/08/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ikmsc4_asc      ds

     D  ascik4_base                  40
     D*                                    text('User Misc 4 Field')
640 ADascik4_vendorco                20    overlay(ascik4_base:1)
640 AD*                                    text('SAP Vendor Code')
640 ADascik4_prodh                   10    overlay(ascik4_base:21)
640 AD*                                    text('SAP Product Hierachy')

