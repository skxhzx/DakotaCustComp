      *===================================================================
      *
      *  Name .......... ORDHM1_CWD
      *  Description ... Order Header Misc. Field 1 - CashWa
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      * Revisions
      *
530 A *   08/23/16  JCJ  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm1_cwd      ds                  inz

     D  cwdhm1_base                  40
     D*                                    text('Header Misc 1 Field')

     D  cwdhm1_RteDs                 40    overlay(cwdhm1_base:1)
     D*                                    text('Route Descriptione')
