      *===================================================================
      *
      *  Name .......... ORDDM3_VIP
      *  Description ... Order Detail Misc Field 3 - VIP
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   04/03/07  MLB  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: Y.Hata
      *
YHT A *   10/13/08  MLB  YHT
      *     - Added seven new fields to OMMSC3 for Navy label
      *       processing.
YHTaA *   11/12/08  MLB  YHTa
      *     - Added one new field to OMMSC3 for Navy label
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm3_vip      ds

     D  vipdm3_base                  40
     D*                                    text('Detail Misc 3 Field')
YHT AD  vipdm3_ojclin                 4    overlay(vipdm3_base:1)
YHT AD*                                    text('Navy Line Number')
YHT AD  vipdm3_ojdodi                13    overlay(vipdm3_base:5)
YHT AD*                                    text('DOD Item Number')
YHT AD  vipdm3_ojfodi                 3    overlay(vipdm3_base:18)
YHT AD*                                    text('DOD Food ID')
YHT AD  vipdm3_eiusiz                10    overlay(vipdm3_base:21)
YHT AD*                                    text('DOD Unit of Measure')
YHT AD  vipdm3_eiusec                 1    overlay(vipdm3_base:31)
YHT AD*                                    text('DOD Use Code (D/M)')
YHTaAD  vipdm3_eiusda                 1    overlay(vipdm3_base:32)
YHTaAD*                                    text('Print USDA message flag')
