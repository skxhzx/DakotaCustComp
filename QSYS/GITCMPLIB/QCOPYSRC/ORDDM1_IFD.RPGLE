      *===================================================================
      *
520 M *  Name .......... ORDDM1_IFD
520 M *  Description ... Order Detail Misc. Field 1 - Indianhead Foodsvc
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   07/25/07  MLB  5.10
      *     - Created.
520 A *   07/28/09  MLB  5.20
      *     - Enh: Corrected DS naming, field naming.
      *     - Enh: added 3 new fields. Key Type, Type Code, Fill All.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

520 MD orddm1_ifd      ds
520 MD  ifddm1_base                  40
     D*                                    text('Detail Misc 1 Field')
520 MDifddm1_omkytype                 1    overlay(ifddm1_base:1)
520 MD*                                    text('NDS Key Type')
520 MDifddm1_omtypcde                 2    overlay(ifddm1_base:2)
520 MD*                                    text('NDS Type Code')
520 ADifddm1_filall                   1    overlay(ifddm1_base:4)
520 AD*                                    text('NDS Fill All Y/N')
