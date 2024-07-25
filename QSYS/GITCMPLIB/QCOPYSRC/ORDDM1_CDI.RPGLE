      *===================================================================
      *
      *  Name .......... ORDDM1_CDI
      *  Description ... Order Detail Misc. Field 1 - CDI
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
700 A *   09/12/15  MLB  7.00
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_cdi      ds

     D  cdidm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dcdidm1_ombchpck                 1    overlay(cdidm1_base:1)
     D*                                    text('Batch Pick Flag Y/N')
