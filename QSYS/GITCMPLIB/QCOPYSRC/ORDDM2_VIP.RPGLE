      *===================================================================
      *
      *  Name .......... ORDDM2_VIP
      *  Description ... Order Detail Misc. Field 2 - VIP
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
      * Client Custom Revisions: MJ Kellner
      *
MJK A *   08/29/08  MLB  MJK
      *     - Added three new fields to OMMSC2 for contract order
      *       processing.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_vip      ds

     D  vipdm2_base                  40
     D*                                    text('Detail Misc 2 Field')
MJK AD  vipdm2_omocur                 3P 0 overlay(vipdm2_base:1)
MJK AD*                                    text('IDS Kellner Item Ocur Nbr')
MJK AD  vipdm2_omlnst                 5P 0 overlay(vipdm2_base:3)
MJK AD*                                    text('IDS Kellner State Line #')
MJK AD  vipdm2_omdted                 8S 0 overlay(vipdm2_base:6)
MJK AD*                                    text('IDS Kellner Delivery Date -'
MJK AD*                                    YYYYMMDD')
GLZ5AD  vipdm2_omupcv                 1A   overlay(vipdm2_base:14)
GLZ5AD*                                    text('GLZ Order Qty UpConverted -'
GLZ5AD*                                    Flag Y/N')
