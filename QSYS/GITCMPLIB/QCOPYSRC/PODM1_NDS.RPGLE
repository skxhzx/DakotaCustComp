      *===================================================================
      *
      *  Name .......... PODM1_NDS
      *  Description ... P/O Detail Misc. Field 1 - NDS  (NDS Controls IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
700 A *   12/06/16  MLB  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D podm1_nds       ds

     D  ndsdm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  ndsdm1_dnpckm                 4  0 overlay(ndsdm1_base:1)
     D*                                    text('NDS Item Master Pack')
     D  ndsdm1_dnwhdp                 5    overlay(ndsdm1_base:5)
     D*                                    text('BFC Item Department Code')
     D  ndsdm1_dnpdsc                15    overlay(ndsdm1_base:10)
     D*                                    text('NDS Override Pack/Size')
     D  ndsdm1_dniaov                 1    overlay(ndsdm1_base:25)
     D*                                    text('NDS Item Alloc Override Y/N')
     D  ndsdm1_dnsltn                 7    overlay(ndsdm1_base:26)
     D*                                    text('NDS Override Slot Location')
     D  ndsdm1_dncwcd                 1    overlay(ndsdm1_base:33)
     D*                                    text('NDS Catchweight Code Y/N')
     D*                                    text('For use w/ items ending in ?')
     D**ndsdm1_dnwtiw                 7  2 overlay(ndsdm1_base:34)
     D*                                    text('NDS Item Weight - Not Supported
     D*                                    text('For use w/ items ending in ?')
     D**ndsdm1_dncbec                 5P 3 overlay(ndsdm1_base:38)
     D*                                    text('NDS Item Cube - Not Supported o
     D*                                    text('For use w/ items ending in ?')
