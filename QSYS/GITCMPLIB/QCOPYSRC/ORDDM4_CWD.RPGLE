      *===================================================================
      *
      *  Name .......... ORDDM4_CWD
      *  Description ... Order Detail Misc. Field 4 - Cash Wa
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/07/12  MLB  6.40
      *     - Created.
CWD A *   03/07/12  MLB  CWD
      *     - Added supporting Tax Right fields from ORDDM4_CTW
      *       to provide support for Tax Right.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm4_cwd      ds

     D  cwddm4_base                  40
     D*                                    text('Detail Misc 4 Field')
     D  cwddm4_rcapn1                15    overlay(cwddm4_base:1)
     D*                                    text('Recap jurisdiction name1')
     D  cwddm4_rcapn2                15    overlay(cwddm4_base:16)
     D*                                    text('Recap jurisdiction name2')
     D  cwddm4_rtaxam                 8    overlay(cwddm4_base:31)
     D*                                    text('Recap tax amount')
