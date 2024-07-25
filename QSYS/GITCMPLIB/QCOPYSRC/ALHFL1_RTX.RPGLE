      *===================================================================
      *
      *  Name .......... ALHFL1_RTX
      *  Description ... Order Label File Misc. Field 1 - Retalix
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   01/18/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D alhfl1_rtx      ds

     D  rtxalh1_base                 40
     D*                                    text('Host Misc 1 Field')

     Drtxalh1_lbtype                  1    overlay(rtxalh1_base:1)
     D*                                    text('Host Label Type O=Ord,M=Merge')
     Drtxalh1_lbgen                   1    overlay(rtxalh1_base:2)
     D*                                    text('Generation: 1=Truck, 2=PIR)
     Drtxalh1_mrguow                  9    overlay(rtxalh1_base:2)
     D*                                    text('Host Merge Unit of Work#')
