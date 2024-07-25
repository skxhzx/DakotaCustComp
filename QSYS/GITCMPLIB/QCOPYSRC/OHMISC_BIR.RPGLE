      *===================================================================
      *
      *  Name .......... OHMISC_BIR
      *  Description ... OHMISC field - BiRite
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      * Revisions
      *
640 A *   06/20/12  JCJ  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_bir      ds

     D  birmsc_base                  20
     D*                                    text('OHMISC Field')

     D  birmsc_Cmpn                   3    overlay(gfcmsc_base:1)
     D*                                    text('Host Company Nbr')

     D  birmsc_Divn                   3    overlay(gfcmsc_base:4)
     D*                                    text('Host Division Nbr')

     D  birmsc_Dptn                   3    overlay(gfcmsc_base:7)
     D*                                    text('Host Department Nbr')

     D  birmsc_Whsn                   3    overlay(gfcmsc_base:10)
     D*                                    text('Host Warehouse Nbr')

     D  birmsc_Memo                   3    overlay(gfcmsc_base:13)
     D*                                    text('Memo Code')

     D  birmsc_Spp                    3    overlay(gfcmsc_base:16)
     D*                                    text('BFC Single Pallet Pick *SP')

     D  birmsc_sub                    1    overlay(gfcmsc_base:19)
     D*                                    text('Host Customer Sub Flag Y/N')
