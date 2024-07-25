      *===================================================================
      *
      *  Name .......... C#ORDH
      *  Description ... Dakota realtime interface layout for *ORD - Header
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

     D $ordh           ds

     D  $ohVer#                       2s 0 Inz(1)
     D  $ohwhse                       3s 0
     D   $ohwhsee                     1
     D   $ohwhseu                      n
     D  $ohoid                        7s 0
     D   $ohoide                      1
     D   $ohoidu                       n
     D  $ohrid                        5
     D   $ohride                      1
     D   $ohridu                       n
     D  $ohorig                       1
     D   $ohorige                     1
     D   $ohorigu                      n
     D  $ohtype                       1
     D   $ohtypee                     1
     D   $ohtypeu                      n
     D  $ohcust                      11s 0
     D   $ohcuste                     1
     D   $ohcustu                      n
     D  $ohcord                       7s 0
     D   $ohcorde                     1
     D   $ohcordu                      n
     D  $ohcpo                       15
     D   $ohcpoe                      1
     D   $ohcpou                       n
     D  $ohcnam                      40
     D   $ohcname                     1
     D   $ohcnamu                      n
     D  $ohcad1                      40
     D   $ohcad1e                     1
     D   $ohcad1u                      n
     D  $ohcad2                      40
     D   $ohcad2e                     1
     D   $ohcad2u                      n
     D  $ohccty                      20
     D   $ohcctye                     1
     D   $ohcctyu                      n
     D  $ohcst                        2
     D   $ohcste                      1
     D   $ohcstu                       n
     D  $ohczip                      10
     D   $ohczipe                     1
     D   $ohczipu                      n
     D  $ohrte                        5
     D   $ohrtee                      1
     D   $ohrteu                       n
     D  $ohstop                       2s 0
     D   $ohstope                     1
     D   $ohstopu                      n
     D  $ohtruk                      10
     D   $ohtruke                     1
     D   $ohtruku                      n
     D  $ohmisc                      20
     D   $ohmisce                     1
     D   $ohmiscu                      n
     D  $ohpbat                       7s 0
     D   $ohpbate                     1
     D   $ohpbatu                      n
     D  $ohstat                       1
     D   $ohstate                     1
     D   $ohstatu                      n
     D  $ohsdte                       8s 0
     D   $ohsdtee                     1
     D   $ohsdteu                      n
     D  $ohstim                       6s 0
     D   $ohstime                     1
     D   $ohstimu                      n
     D  $ohudte                       8s 0
     D   $ohudtee                     1
     D   $ohudteu                      n
     D  $ohutim                       6s 0
     D   $ohutime                     1
     D   $ohutimu                      n
