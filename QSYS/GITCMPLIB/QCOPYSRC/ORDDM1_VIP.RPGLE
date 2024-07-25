      *===================================================================
      *
      *  Name .......... ORDDM1_VIP
      *  Description ... Order Detail Misc. Field 1 - VIP
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   04/03/07  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_vip      ds

     D  vipdm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  vipdm1_ompckm                 4  0 overlay(vipdm1_base:1)
     D*                                    text('IDS Item Master Pack')
     D  vipdm1_omwhdp                 5    overlay(vipdm1_base:5)
     D*                                    text('BFC Item Department Code')
     D  vipdm1_ompdsc                15    overlay(vipdm1_base:10)
     D*                                    text('IDS Override Pack/Size')
     D  vipdm1_omiaov                 1    overlay(vipdm1_base:25)
     D*                                    text('IDS Item Alloc Override Y/N')
     D  vipdm1_omsltn                 7    overlay(vipdm1_base:26)
     D*                                    text('IDS Override Slot Location')
     D  vipdm1_omcwcd                 1    overlay(vipdm1_base:33)
     D*                                    text('IDS Catchweight Code Y/N')
     D*                                    text('For use w/ all 9's item# only')
     D  vipdm1_omwtiw                 7P 2 overlay(vipdm1_base:34)
     D*                                    text('IDS Item Weight')
     D*                                    text('For use w/ all 9's item# only')
     D  vipdm1_omcbec                 5P 3 overlay(vipdm1_base:38)
     D*                                    text('IDS Item Cube')
     D*                                    text('For use w/ all 9's item# only')
