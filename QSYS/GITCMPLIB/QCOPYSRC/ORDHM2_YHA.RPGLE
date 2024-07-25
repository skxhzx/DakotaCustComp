      *===================================================================
      *
      *  Name .......... ORDHM2_YHA
      *  Description ... Order Header Misc. Field 2 - YHA
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   10/11/08  JCJ  5.20
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: Y.Hata
      *
YHT A *   10/13/08  MLB  YHA
      *     - Added three new fields to HMMSC2.
YHTaA *   11/16/11  MLB  YHTa
      *     - Enh: Added Retalix Delivery Date (OOHDTEI)
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm2_yha      ds

     D  yhahm2_base                  40
     D*                                    text('Header Misc 2 Field')
YHT AD  yhahm2_hmtknb                 3    overlay(yhahm2_base:1)
YHT AD*                                    text('IDS Truck Number')
YHT AD  yhahm2_hmtran                15    overlay(yhahm2_base:4)
YHT AD*                                    text('IDS Trailer Number')
YHT AD  yhahm2_fdnavy                 1    overlay(yhahm2_base:19)
YHT AD*                                    text('Print Navy Label (P=Yes)')
YHTaAD  yhahm2_hmdtei                 8S 0 overlay(yhahm2_base:20)
YHTaAD*                                    text('IDS Delivery Date -       -'
YHTaAD*                                    YYYYMMDD')
