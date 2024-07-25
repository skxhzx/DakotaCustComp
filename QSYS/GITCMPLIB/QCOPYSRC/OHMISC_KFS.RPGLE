      *===================================================================
      *
      *  Name .......... OHMISC_KFS
      *  Description ... ORDH - OHMISC Field - Kelly Foods
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   08/30/12  MLB  6.40
      *     - Created.
640aA *   09/18/12  MLB  6.40a
      *     - /copy mbr was named incorrectly. Correct extension is KFS.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_kfs      ds

     D  kfsmsc_base                  20
     D*                                    text('OHMISC Field')

     Dkfsmsc_ohdlvdte                 6    overlay(kfsmsc_base:1)
     D*                                    text('Delivery Date MMDDYY')
     Dkfsmsc_ohspp                    3    overlay(kfsmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dkfsmsc_ohsubs                   1    overlay(kfsmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dkfsmsc_ohfil1                   1    overlay(kfsmsc_base:11)
     D*                                    text('Host Filler "-"')
     Dkfsmsc_ohord                    9    overlay(kfsmsc_base:12)
     D*                                    text('Host Order Number')
