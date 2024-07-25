      *===================================================================
      *
      *  Name .......... ORDDM2_PAK
      *  Description ... Order Detail Misc. Field 2 - Packer's
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   09/07/06  MLB  5.10
      *     - Created.
      *
520 A *   04/27/09  MLB  5.20
      *     - Added two new fields: Host Days Out and BFC Special Pick.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_pak      ds

     D  pakdm2_base                  40
     D*                                    text('Detail Misc 2 Field')
520 A
520 AD  pakdm2_hdayo                  3s 0 overlay(pakdm2_base:1)
520 AD*                                    text('Host Days Out')
520 A
520 AD  pakdm2_bsppk                  1A   overlay(pakdm2_base:4)
520 AD*                                    text('BFC Special Pick Y/N')
520 AD*                                    text('BFC Internal flag')
