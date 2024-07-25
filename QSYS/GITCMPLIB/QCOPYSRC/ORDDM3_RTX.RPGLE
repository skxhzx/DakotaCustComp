      *===================================================================
      *
      *  Name .......... ORDDM3_RTX
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
520aA *   04/15/09  MLB  FDI
      *     - Enh: Added 1 new field for Case UPC to be used with
      *       TaxRight tobacco processing.
BIR A *   03/20/14  MLB  BIR
      *     - Enh: Added support for A&B Produce Company 2 item number,
      *       pick slot and pick code.
      *     - OMPCOD = A&B or blanks will be valid codes at this time.
      *
750 A *   03/03/22  MLB  7.50
      *     - Enh: Added support for S/O Line Label# to record. Needed for
      *       multiple bulk picks on a pallet. Added at Jake's Foods.
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
520 AD  rtxdm3_omupcn                25a   overlay(rtxdm3_base:10)
520 AD*                                    text('IDS UPC Number - Case')
BIR AD  rtxdm3_ompcod                 3A   overlay(rtxdm3_base:9)
BIR AD*                                    text('Item Pick Code. A&B,blanks')
BIR AD  rtxdm3_omitmn                10A   overlay(rtxdm3_base:12)
BIR AD*                                    text('A&B Produce Item Nbr')
BIR AD  rtxdm3_omsltn                12A   overlay(rtxdm3_base:22)
BIR AD*                                    text('A&B Produce Pick Slot')
750 AD  rtxdm3_omslbl                 3S 0 overlay(rtxdm3_base:34)
750 AD*                                    text('P/W S/O Line Label#')
