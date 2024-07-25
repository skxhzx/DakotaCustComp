      *===================================================================
      *
      *  Name .......... OHMISC_FDI
      *  Description ... OHMISC field - Finkle
      *  Created by .... Jeffrey Jahnke
      *
      * Revisions
      *
520 A *   02/10/09  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_fdi      ds

     D  fdimsc_base                  20
     D*                                    text('OHMISC Field')

     D  fdimsc_Memo                   3    overlay(fdimsc_base:13)
     D*                                    text('Memo Code')

     D  fdimsc_Date                   4P 0 overlay(fdimsc_base:16)
     D*                                    text('Date MMDDYY')
