      *===================================================================
      *
      *  Name .......... ORDHM4_RTX
      *  Description ... Order Header Misc. Field 4 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   12/08/08  MLB  5.20
      *     - Created.
      *
710 A *   01/26/17  MLB  7.10
      *     - Enh: Revised format to add support for route departure
      *       date / time.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm4_rtx      ds

     D  rtxhm4_base                  40
     D*                                    text('Header Misc 4 Field')
710 AD  rtxhm4_hmrtdd                 8  0 overlay(rtxhm4_base:1)
710 AD*                                    text('RTX Route Departure Date YYYYMMDD')
710 AD  rtxhm4_hmrnrs                 4  0 overlay(rtxhm4_base:9)
710 AD*                                    text('RTX Route Departure Time HHMM')
