      *===================================================================
      *
      *  Name .......... POHM2_NS
      *  Description ... P/O Header Misc. Field 2 - Net Suite
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
750 A *   11/23/21  MLB  7.50
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions:
      *
xxx A *   mm/dd/yy  iii  ccc
      *     - insert chg text here.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D pohm2_ns        ds

     D  nshp2_base                   40
     D*                                    text('Header Misc 2 Field')
     D  nshm2_hnpoid                  9    overlay(nshp2_base:1)
     D*                                    text('N/S Internal P/O ID')
