      *===================================================================
      *
      *  Name .......... IKMSC3_ASC
      *  Description ... Item Extension File Misc. Field 3 - Agar Supply
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

     D ikmsc3_asc      ds

     D  ascik3_base                  40
     D*                                    text('User Misc 3 Field')
640 ADascik3_upc2                    20    overlay(ascik3_base:1)
640 AD*                                    text('SAP UPC 2')
640 ADascik3_upc3                    20    overlay(ascik3_base:21)
640 AD*                                    text('SAP UPC 3')

