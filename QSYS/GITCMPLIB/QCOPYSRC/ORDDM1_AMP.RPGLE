      *===================================================================
      *
      *  Name .......... ORDHM1_AMP
      *  Description ... Order Detail Misc. Field 1
      *  Created by .... Rod Roller             for Greenleaf Produce
      *
      *------------------------------------------------------------------*
      * Revisions
      *
700   *   07/06/16  RTR  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes -
      *
      *===================================================================

     D orddm1_amp      ds                  inz

     D  ampdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     D  ampdm4_ampfl                  1    overlay(ampdm1_base:1)
     D*                                    text('AMP short item flag')


