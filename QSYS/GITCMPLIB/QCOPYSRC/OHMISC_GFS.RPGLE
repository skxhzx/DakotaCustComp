      *===================================================================
      *
      *  Name .......... OHMISC_GFS
      *  Description ... ORDH - OHMISC Field - Get Fresh Sales
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   01/30/13  MLB  6.50
      *     - Created.
650aA *   03/17/14  MLB  6.50a
      *     - Enh: Changed name of gfsmsc_ohfil1 to gfsmsc_ohcins.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_gfs      ds

     D  gfsmsc_base                  20
     D*                                    text('OHMISC Field')

     Dgfsmsc_ohdlvdte                 6    overlay(gfsmsc_base:1)
     D*                                    text('Delivery Date')
     Dgfsmsc_ohspp                    3    overlay(gfsmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dgfsmsc_ohsubs                   1    overlay(gfsmsc_base:10)
     D*                                    text('Sub Customer Y/N')
650 MDgfsmsc_ohccar                   1    overlay(gfsmsc_base:11)
650 MD*                                    text('Critical Care Y/N')
     Dgfsmsc_ohcins                   1    overlay(gfsmsc_base:12)
     D*                                    text('Customer Instructions Y/N')
     Dgfsmsc_ohsubstp                 3    overlay(gfsmsc_base:13)
     D*                                    text('Customer Sub-Stop Sequence')
