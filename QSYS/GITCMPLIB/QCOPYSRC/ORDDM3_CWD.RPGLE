      *===================================================================
      *
      *  Name .......... ORDDM3_CWD
      *  Description ... Order Detail Misc. Field 3 - Cash Wa
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/07/12  MLB  6.40
      *     - Created.
CWD A *   03/07/12  MLB  CWD
      *     - Added supporting Tax Right fields from ORDDM3_CTW
      *       to provide support for Tax Right.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm3_cwd      ds

     D  cwddm3_base                  40
     D*                                    text('Detail Misc 3 Field')
     D  cwddm3_cijurn                15    overlay(cwddm3_base:1)
     D*                                    text('City jurisdiction name')
     D  cwddm3_dtecde                 2    overlay(cwddm3_base:16)
     D*                                    text('Date code')
     D  cwddm3_dealcd                 5    overlay(cwddm3_base:20)
     D*                                    text('Deal code')
     D  cwddm3_recapf                 1    overlay(cwddm3_base:25)
     D*                                    text('Recap flag')
     D  cwddm3_Taxamt                 8    overlay(cwddm3_base:26)
     D*                                    text('Tax amount')
