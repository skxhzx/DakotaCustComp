      *===================================================================
      *
      *  Name .......... ORDHM4_KFS
      *  Description ... Order Header Misc. Field 4 - Kelly's Foods
      *  Created by .... Max Blacknik
      *
      *------------------------------------------------------------------*
      * Revisions
      *
640 A *   09/18/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm4_kfs      ds                  inz

     D  kfshm4_base                  40
     D*                                    text('Header Misc 4 Field')
     Dkfshm4_hmssqhdr                16    overlay(kfshm4_base:1)
     D*                                    text('System Sequence - Header')
