      *===================================================================
      *
      *  Name .......... OHMISC_DRY
      *  Description ... ORDH - OHMISC Field - Dairyland
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
DRY A *   02/17/11  MLB  DRY
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_dry      ds

     D  drymsc_base                  20
     D*                                    text('OHMISC Field')

     D*                                    text('Pos 1 - 10 available')
     Ddrymsc_ohcust                   7    overlay(drymsc_base:11)
     D*                                    text('DRY Customer Number')
     D*                                    text('Pos 18 - 20 available')
