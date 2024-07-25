      *===================================================================
      *
      *  Name .......... OHMISC_SOF
      *  Description ... OHMISC field - Sofo Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      * Revisions
      *
700 A *   04/01/15  MLB  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_sof      ds

     D  sofmsc_base                  20
     D*                                    text('OHMISC Field')

     D  sofmsc_Cmpn                   3    overlay(sofmsc_base:1)
     D*                                    text('Host Company Nbr')

     D  sofmsc_Divn                   3    overlay(sofmsc_base:4)
     D*                                    text('Host Division Nbr')

     D  sofmsc_Dptn                   3    overlay(sofmsc_base:7)
     D*                                    text('Host Department Nbr')

     D  sofmsc_Whsn                   3    overlay(sofmsc_base:10)
     D*                                    text('Host Warehouse Nbr')

     D  sofmsc_Memo                   3    overlay(sofmsc_base:13)
     D*                                    text('Memo Code')

     D  sofmsc_Spp                    3    overlay(sofmsc_base:16)
     D*                                    text('BFC Single Pallet Pick *SP')

     D  sofmsc_sub                    1    overlay(sofmsc_base:20)
     D*                                    text('Host Customer Sub Flag Y/N')
