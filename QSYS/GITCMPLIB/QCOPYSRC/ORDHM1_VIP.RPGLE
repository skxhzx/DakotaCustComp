      *===================================================================
      *
      *  Name .......... ORDHM1_VIP
      *  Description ... Order Header Misc. Field 1 - VIP
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   04/03/07  MLB  5.10
      *     - Created.
      *
640aA *   03/02/12  MLB  6.40a
      *     - Enh: Added field to store H&S ship date in mmddyy format.
      *
      *===================================================================
      *
      * Client Custom Revisions: MJ Kellner
      *
MJK A *   08/29/08  MLB  MJK
      *     - Added three new fields to HMMSC1 for contract order
      *       processing.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm1_vip      ds

     D  viphm1_base                  40
     D*                                    text('Header Misc 1 Field')
MJK AD  viphm1_hmkctr                 6    overlay(viphm1_base:1)
MJK AD*                                    text('IDS Kellner Contract Number')
MJK AD  viphm1_hmpono                20    overlay(viphm1_base:7)
MJK AD*                                    text('IDS Customer purchase order')
MJK AD  viphm1_hmdted                 8S 0 overlay(viphm1_base:27)
MJK AD*                                    text('IDS Kellner Last Due Date -'
MJK AD*                                    YYYYMMDD')
640aAD  viphm1_hmdtes                 6S 0 overlay(viphm1_base:35)
640aAD*                                    text('IDS Ship Date - MMDDYY')

