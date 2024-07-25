      *===================================================================
      *
      *  Name .......... ORDHM2_DRY
      *  Description ... Order Header Misc. Field 2 - Dairyland
      *  Created by .... Max Blacknik
      *
      *------------------------------------------------------------------*
      * Revisions
      *
530 A *   01/04/10  MLB  5.30
      *     - Created.
      *
650aA *   05/16/14  JCJ  6.50
      *     - Added Method of Transportation Code.
      *     - Per Kelly R. email dated 05-09-2014 @ 9:23am for Qzina
      *       warhouses.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

530 AD ordhm2_dry      ds                  inz

     D  dryhm2_base                  40
     D*                                    text('Header Misc 2 Field')

     D  dryhm2_motcd                  3    overlay(dryhm2_base:1)
     D*                                    text('Method of Tranport code')
