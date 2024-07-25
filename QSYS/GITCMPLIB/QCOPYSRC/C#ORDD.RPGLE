      *===================================================================
      *
      *  Name .......... C#ORDD
      *  Description ... Dakota realtime interface layout for *ORD - Detail
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   05/16/02  DAS  4.16
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
416 A *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding indicator field.
      *       4) Create corresponding error indicator field.
      *
416 A *   - Each field should have a corresponding indicator field. This
416 A *     field is used to indicate if the field is being used (sent).
416 A *     The only exceptions are the warehouse and item fields, which
416 A *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
      *===================================================================

     D $ordd           ds

     D  $odVer#                       2s 0 Inz(1)
     D  $odwhse                       3s 0
     D   $odwhsee                     1
     D   $odwhseu                      n
     D  $odoid                        7s 0
     D   $odoide                      1
     D   $odoidu                       n
     D  $odseq                        5s 0
     D   $odseqe                      1
     D   $odsequ                       n
     D  $oditem                      15
     D   $oditeme                     1
     D   $oditemu                      n
     D  $odqor1                       5s 0
     D   $odqor1e                     1
     D   $odqor1u                      n
     D  $odqor2                       5s 0
     D   $odqor2e                     1
     D   $odqor2u                      n
     D  $odqor3                       5s 0
     D   $odqor3e                     1
     D   $odqor3u                      n
     D  $odwh2                        3  0
     D   $odwh2e                      1
     D   $odwh2u                       n
     D  $odor2                        7s 0
     D   $odor2e                      1
     D   $odor2u                       n
     D  $odoitm                      15
     D   $odoitme                     1
     D   $odoitmu                      n
     D  $odspcl                       2
     D   $odspcle                     1
     D   $odspclu                      n
     D  $odqpk1                       5s 0
     D   $odqpk1e                     1
     D   $odqpk1u                      n
     D  $odqpk2                       5s 0
     D   $odqpk2e                     1
     D   $odqpk2u                      n
     D  $odqpk3                       5s 0
     D   $odqpk3e                     1
     D   $odqpk3u                      n
     D  $odstat                       1
     D   $odstate                     1
     D   $odstatu                      n
