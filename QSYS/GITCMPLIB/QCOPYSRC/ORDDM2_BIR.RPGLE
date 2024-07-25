      *===================================================================
      *
      *  Name .......... ORDDM2_RTX
      *  Description ... Order Detail Misc. Field 2 - RTX (Retalix IFC)
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
      * Client Custom Revisions: MJ Kellner
      *
MJK A *   08/29/08  MLB  MJK
      *     - Added three new fields to OMMSC2 for contract order
      *       processing.
MJKaA *   10/15/08  MLB  MJKa
      *     - Enh: The 3 fields added in MJK have been removed from
      *       this copy mbr. The fields have been moved to file ORDDCTR.
      *
      *===================================================================
      *
      * Client Custom Revisions: BiRite Foodservice
      *
BIRbA *   11/19/10  MLB  BIRb
      *     - Added two new fields to OMMSC2 for fabricated meat
      *       item processing.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_rtx      ds

     D  rtxdm2_base                  40
     D*                                    text('Detail Misc 2 Field')
MJKaDD* rtxdm2_omocur                 3P 0 overlay(rtxdm2_base:1)
MJKaDD*                                    text('IDS Kellner Item Ocur Nbr')
MJKaDD* rtxdm2_omlnst                 5P 0 overlay(rtxdm2_base:3)
MJKaDD*                                    text('IDS Kellner State Line #')
MJKaDD* rtxdm2_omdted                 8S 0 overlay(rtxdm2_base:6)
MJKaDD*                                    text('IDS Kellner Delivery Date -'
MJKaDD*                                    YYYYMMDD')
BIRbAD  rtxdm2_omfbmt                 1A   overlay(rtxdm2_base:1)
BIRbAD*                                    text('IDS BiRite Fabricated Meat-'
BIRbAD*                                    Item Y/N')
BIRbAD  rtxdm2_omqysa                 7P 0 overlay(rtxdm2_base:2)
BIRbAD*                                    text('IDS BiRite Actual Qty Pick-'
BIRbAD*                                    ed - Only when omfbmt=Y')
