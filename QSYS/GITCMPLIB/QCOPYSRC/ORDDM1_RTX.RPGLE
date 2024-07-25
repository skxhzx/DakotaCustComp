      *===================================================================
      *
      *  Name .......... ORDDM1_RTX
      *  Description ... Order Detail Misc. Field 1 - RTX  (Retalix Ifc)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   12/08/08  MLB  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_rtx      ds

     D  rtxdm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  rtxdm1_ompckm                 4  0 overlay(rtxdm1_base:1)
     D*                                    text('IDS Item Master Pack')
     D  rtxdm1_omwhdp                 5    overlay(rtxdm1_base:5)
     D*                                    text('BFC Item Department Code')
     D  rtxdm1_ompdsc                15    overlay(rtxdm1_base:10)
     D*                                    text('IDS Override Pack/Size')
     D  rtxdm1_omiaov                 1    overlay(rtxdm1_base:25)
     D*                                    text('IDS Item Alloc Override Y/N')
     D  rtxdm1_omsltn                 7    overlay(rtxdm1_base:26)
     D*                                    text('IDS Override Slot Location')
     D  rtxdm1_omcwcd                 1    overlay(rtxdm1_base:33)
     D*                                    text('IDS Catchweight Code Y/N')
     D*                                    text('For use w/ all 9's item# only')
     D  rtxdm1_omwtiw                 7P 2 overlay(rtxdm1_base:34)
     D*                                    text('IDS Item Weight')
     D*                                    text('For use w/ all 9's item# only')
     D  rtxdm1_omcbec                 5P 3 overlay(rtxdm1_base:38)
     D*                                    text('IDS Item Cube')
     D*                                    text('For use w/ all 9's item# only')
