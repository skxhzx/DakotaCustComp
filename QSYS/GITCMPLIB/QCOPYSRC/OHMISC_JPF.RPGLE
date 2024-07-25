      *===================================================================
      *
      *  Name .......... OHMISC_JPF
      *  Description ... OHMISC field - Palmer
      *  Created by .... Jeffrey Jahnke
      *
      * Revisions
      *
520 A *   03/19/09  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_jpf      ds

     D  jpfmsc_base                  20
     D*                                    text('OHMISC Field')

     D  jpfmsc_subflg                 1    overlay(jpfmsc_base:10)
     D*                                    text('Sub Flag')
