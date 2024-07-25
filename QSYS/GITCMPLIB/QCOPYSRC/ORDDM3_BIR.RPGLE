      *===================================================================
      *
      *  Name .......... ORDDM3_BIR
      *  Description ... Order Detail Misc Field 3 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   12/08/08  MLB  5.20
      *     - Created.
520aA *   02/10/09  MLB  5.20a
      *     - Enh: Added support for Retail SRP and SRP Pack.
BIR A *   03/20/14  MLB  BIR
      *     - Enh: Added support for A&B Produce Company 2 item number,
      *       pick slot and pick code.
      *     - OMPCOD = A&B or blanks will be valid codes at this time.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm3_rtx      ds

     D  rtxdm3_base                  40
     D*                                    text('Detail Misc 3 Field')
520 AD  rtxdm3_omprcs                 7P 2 overlay(rtxdm3_base:1)
520 AD*                                    text('IDS Item Price - SRP')
520 AD  rtxdm3_omspkn                 4S 0 overlay(rtxdm3_base:5)
520 AD*                                    text('IDS Item Pack - SRP')
BIR AD  rtxdm3_ompcod                 3A   overlay(rtxdm3_base:9)
BIR AD*                                    text('Item Pick Code.A&B,blanks')
BIR AD  rtxdm3_omitmn                10A   overlay(rtxdm3_base:12)
BIR AD*                                    text('A&B Produce Item Nbr')
BIR AD  rtxdm3_omsltn                12A   overlay(rtxdm3_base:22)
BIR AD*                                    text('A&B Produce Pick Slot')
