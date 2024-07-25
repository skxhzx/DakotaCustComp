      *===================================================================
      *
      *  Name .......... ORDHM1_CSP
      *  Description ... Order Header Misc. Field 1 - Coastal Sunbelt
      *  Created by .... Max Blacknik
      *
      *------------------------------------------------------------------*
      * Revisions
      *
530 A *   09/15/10  MLB  5.30
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

530 AD ordhm1_csp      ds                  inz

     D  csphm1_base                  40
     D*                                    text('Header Misc 1 Field')

     D  csphm1_trkid                 10    overlay(csphm1_base:1)
     D*                                    text('Truck Id')

     D  csphm1_drvnm                 20    overlay(csphm1_base:11)
     D*                                    text('Driver Name')

