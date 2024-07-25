      *===================================================================
      *
      *  Name .......... ORDDM3_YHA
      *  Description ... Order Detail Misc Field 3 - YHA
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   11/10/08  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: Y.Hata
      *
MJK A *   10/13/08  MLB  YHA
      *     - Added seven new fields to OMMSC3 for Navy label
      *       processing.
      *
YHAaA *   11/12/08  MLB  YHTa
      *     - Added one new field to OMMSC3 for Navy label
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm3_yha      ds

     D  yhadm3_base                  40
     D*                                    text('Detail Misc 3 Field')
YHA AD  yhadm3_ojclin                 4    overlay(yhadm3_base:1)
YHA AD*                                    text('Navy Line Number')
YHA AD  yhadm3_ojdodi                13    overlay(yhadm3_base:5)
YHA AD*                                    text('DOD Item Number')
YHA AD  yhadm3_ojfodi                 3    overlay(yhadm3_base:18)
YHA AD*                                    text('DOD Food ID')
YHA AD  yhadm3_eiusiz                10    overlay(yhadm3_base:21)
YHA AD*                                    text('DOD Unit of Measure')
YHA AD  yhadm3_eiusec                 1    overlay(yhadm3_base:31)
YHA AD*                                    text('DOD Use Code (D/M)')
YHAaAD  yhadm3_eiusda                 1    overlay(yhadm3_base:32)
YHAaAD*                                    text('Print USDA message flag')
