      *===================================================================
      *
      *  Name .......... ORDHM4_AMP
      *  Description ... Order Header Misc. Field 4
      *  Created by .... Nancy Koelz            for Greenleaf Produce
      *
      *------------------------------------------------------------------*
      * Revisions
      *
530 A *   09/22/15  NLK  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes - AMP needs Y in M4 col 13 to start the process
      *         AMP optional staging location - default or enter code
      *
      *===================================================================

530 AD ordhm4_amp      ds                  inz

     D  amphm4_base                  40
     D*                                    text('Header Misc 4 Field')

     D  amphm4_ampfl                  1    overlay(amphm4_base:13)
     D*                                    text('AMP Y flag')

     D  amphm4_ampst                  3    overlay(amphm4_base:14)
     D*                                    text('AMP StageAmp')

