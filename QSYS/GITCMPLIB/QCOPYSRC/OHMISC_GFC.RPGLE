      *===================================================================
      *
      *  Name .......... OHMISC_GFC
      *  Description ... OHMISC field - Glazier Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      * Revisions
      *
640 A *   06/05/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_gfc      ds

     D  gfcmsc_base                  20
     D*                                    text('OHMISC Field')

     D  gfcmsc_Cmpn                   3    overlay(gfcmsc_base:1)
     D*                                    text('Host Company Nbr')

     D  gfcmsc_Divn                   3    overlay(gfcmsc_base:4)
     D*                                    text('Host Division Nbr')

     D  gfcmsc_Dptn                   3    overlay(gfcmsc_base:7)
     D*                                    text('Host Department Nbr')

     D  gfcmsc_Whsn                   3    overlay(gfcmsc_base:10)
     D*                                    text('Host Warehouse Nbr')

     D  gfcmsc_Memo                   3    overlay(gfcmsc_base:13)
     D*                                    text('Memo Code')

     D  gfcmsc_Spp                    3    overlay(gfcmsc_base:16)
     D*                                    text('BFC Single Pallet Pick *SP')

     D  gfcmsc_sub                    1    overlay(gfcmsc_base:19)
     D*                                    text('Host Customer Sub Flag Y/N')
