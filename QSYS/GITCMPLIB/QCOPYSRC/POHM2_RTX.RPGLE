      *===================================================================
      *
      *  Name .......... POHM2_RTX
      *  Description ... P/O Header Misc. Field 2 - RTX (Retalix IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
520 A *   02/25/09  MLB  5.20
      *     - Created.
      *
640 A *   10/23/12  MLB  6.40
      *     - Enh: Added 4 new fields to copy book: Host cmp/div/dpt/whs
      *       and vendor number. Needed to provide support for multi-whse
      *       integration with Dakota WMS.
      *
      *===================================================================
      *
      * Client Custom Revisions:
      *
xxx A *   mm/dd/yy  iii  ccc
      *     - insert chg text here.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D pohm2_rtx       ds

     D  rtxdp2_base                  40
     D*                                    text('Header Misc 2 Field')
     D rtxdp2_phmcmpn                 3    overlay(rtxdp2_base:1)
     D*                                    text('Retalix Company Number')
     D rtxdp2_phmdivn                 3    overlay(rtxdp2_base:4)
     D*                                    text('Retalix Division Number')
     D rtxdp2_phmdptn                 3    overlay(rtxdp2_base:7)
     D*                                    text('Retalix Department Number')
     D rtxdp2_phmwhsn                 3    overlay(rtxdp2_base:10)
     D*                                    text('Retalix Whse Number')
     D rtxdp2_phmvndn                10    overlay(rtxdp2_base:13)
     D*                                    text('Retalix Vendor Number')
