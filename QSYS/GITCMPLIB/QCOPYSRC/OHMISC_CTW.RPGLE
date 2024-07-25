      *===================================================================
      *
      *  Name .......... OHMISC_CTW
      *  Description ... OHMISC field - City Wholesale
      *  Created by .... Jeffrey Jahnke
      *
      * Revisions
      *
520 A *   04/14/09  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_ctw      ds

     D  ctwmsc_base                  20
     D*                                    text('OHMISC Field')

     D  ctwmsc_sflag                  1    overlay(ctwmsc_base:7)
     D*                                    text('Special stamp flag')
