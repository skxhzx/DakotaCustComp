      *===================================================================
      *
      *  Name .......... ORDDM2_CWD
      *  Description ... Order Detail Misc. Field 2 - Cash-Wa
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   03/06/09  JCJ  5.20
      *     - Created.
      *
510 A *   03/09/09  JCJ  5.20a
      *     - added quantity on hand for eaches in positions 6-10.
CWD A *   03/30/09  MLB  CWD
      *     - Added Host label number in positions 11-20.
      *       Host label number moved from ODIITM in file ORDD.
CWDaA *   03/07/12  MLB  CWDa
      *     - Moved 3 fields added in mod CWD to ORDDM1_CWD to
      *       make room for Tax Right fields.
CWDbA *   03/07/12  MLB  CWDb
      *     - Added supporting Tax Right fields from ORDDM2_CTW
      *       to provide support for Tax Right.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm2_cwd      ds

     D  cwddm2_base                  40
     D*                                    text('Detail Misc 2 Field')

CWDaDD* cwddm2_qoh                    5  0 overlay(cwddm2_base:1)
CWDaDD*                                    text('Quantity on hand')

CWDaDD* cwddm2_eqoh                   5  0 overlay(cwddm2_base:6)
CWDaDD*                                    text('Each Quantity on hand')
CWDaD
CWDaDD* cwddm2_lblnbr                10    overlay(cwddm2_base:11)
CWDaDD*                                    text('Host Label Number')
CWDbAD*
CWDbAD  cwddm2_stjurc                 3    overlay(cwddm2_base:1)
CWDbAD*                                    text('State jurisdiction code')
CWDbAD  cwddm2_stjurn                15    overlay(cwddm2_base:4)
CWDbAD*                                    text('State jurisdiction name')
CWDbAD  cwddm2_cojurc                 3    overlay(cwddm2_base:19)
CWDbAD*                                    text('County jurisdiction code')
CWDbAD  cwddm2_cojurn                15    overlay(cwddm2_base:22)
CWDbAD*                                    text('County jurisdiction name')
CWDbAD  cwddm2_cijurc                 3    overlay(cwddm2_base:37)
CWDbAD*                                    text('City jurisdiction code')
