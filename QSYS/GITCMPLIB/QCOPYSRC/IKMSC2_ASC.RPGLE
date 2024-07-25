      *===================================================================
      *
      *  Name .......... IKMSC2_ASC
      *  Description ... Item Extension File Misc. Field 2 - Agar Supply
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

     D ikmsc2_asc      ds

     D  ascik2_base                  40
     D*                                    text('User Misc 2 Field')
640 ADascik2_updchkfr                 4    overlay(ascik2_base:1)
640 AD*                                    text('SAP UPC Check Freq')
640 ADascik2_itempric                 7    overlay(ascik2_base:5)
640 AD*                                    text('SAP Item Price')
640 ADascik2_upc1                    20    overlay(ascik2_base:14)
640 AD*                                    text('SAP UPC 1')
640 ADascik2_pirpick                  1    overlay(ascik2_base:34)
640 AD*                                    text('SAP Pir Pick')
640 ADascik2_isflow                   1    overlay(ascik2_base:35)
640 AD*                                    text('SAP Isflow  ')

