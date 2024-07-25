      *===================================================================
      *
      *  Name .......... ORDDM1_CWD
      *  Description ... Order Detail Misc. Field 1 - Cash Wa
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/07/12  MLB  6.40
      *     - Created.
640aA *   03/07/12  MLB  6.40a
      *     - Added 2 fields from ORDDM1_CTW to provide support for Tax
      *       Right.
      *     - Added 3 fields from ORDDM2_CWD to make room for Tax Right
      *       fields.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_cwd      ds

     D  cwddm1_base                  40
     D*                                    text('Detail Misc 1 Field')
640aAD  cwddm1_rtlprc                 7    overlay(cwddm1_base:1)
640aAD*                                    text('Customer retail price')
640aAD  cwddm1_qoh                    5  0 overlay(cwddm1_base:8)
640aAD*                                    text('Quantity on hand')

640aAD  cwddm1_eqoh                   5  0 overlay(cwddm1_base:13)
640aAD*                                    text('Each Quantity on hand')

640aAD  cwddm1_lblnbr                10    overlay(cwddm1_base:18)
640aAD*                                    text('Host Label Number')
640aAD  cwddm1_prccod                 5    overlay(cwddm1_base:36)
640aAD*                                    text('Price code')
