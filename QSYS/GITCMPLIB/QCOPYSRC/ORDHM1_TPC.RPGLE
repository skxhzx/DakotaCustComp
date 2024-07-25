      *===================================================================
      *
      *  Name .......... ORDHM1_TPC
      *  Description ... Order Header Misc. Field 1 - TPC
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   09/18/07  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm1_tpc      ds

     D  tpchm1_base                  40
     D*                                    text('Header Misc 1 Field')
     D  tpchm1_prtlbl                 1    overlay(tpchm1_base:1)
     D*                                    text('Print Pick Label Y/N')

