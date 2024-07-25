      *===================================================================
      *
      *  Name .......... ORDHM1_DRY
      *  Description ... Order Header Misc. Field 1 - Dairyland
      *  Created by .... Max Blacknik
      *
      *------------------------------------------------------------------*
      * Revisions
      *
530 A *   01/04/10  MLB  5.30
      *     - Created.
      *
650aA *   05/16/14  JCJ  6.50a
      *     - Added Voyage id.
      *     - Per Kelly R. email dated 05-09-2014 @ 9:23am for Qzina
      *       warhouses.
      *
650bA *   07/16/14  JCJ  6.50b
      *     - Changed Voyage id. by 1 position per Kelly R.
      *     - Per Kelly R. email dated 05-09-2014 @ 9:23am for Qzina
      *       warhouses.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

530 AD ordhm1_dry      ds                  inz

     D  dryhm1_base                  40
     D*                                    text('Header Misc 1 Field')

     D  dryhm1_trkid                  5    overlay(dryhm1_base:1)
     D*                                    text('Truck Id')

650aD***dryhm1_voyid                 35    overlay(dryhm1_base:6)
650bMD  dryhm1_voyid                 34    overlay(dryhm1_base:7)
650aAD*                                    text('Voyage Id')

