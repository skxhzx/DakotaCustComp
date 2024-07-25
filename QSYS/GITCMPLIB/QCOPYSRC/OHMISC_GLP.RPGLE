      *===================================================================
      *
      *  Name .......... OHMISC_GLP
      *  Description ... ORDH - OHMISC Field - Greenleaf Produce
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   08/23/13  MLB  6.50
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_glp      ds

     D  glpmsc_base                  20
     D*                                    text('OHMISC Field')

     Dglpmsc_ohdlvdte                 6    overlay(glpmsc_base:1)
     D*                                    text('Delivery Date MMDDYY')
     Dglpmsc_ohspp                    3    overlay(glpmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dglpmsc_ohsubs                   1    overlay(glpmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dglpmsc_ohcust                  10    overlay(glpmsc_base:11)
     D*                                    text('Customer Number')
