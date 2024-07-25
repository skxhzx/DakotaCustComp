      *===================================================================
      *
      *  Name .......... C#ZONED
      *  Description ... Dakota realtime interface layout for *ZONED
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   05/03/12  DAS  6.40
      *     - Created.
      *
650aA *   05/05/14  DAS  6.50a
      *     - Changed zdcat/zocat from 6 to 10.
      *
720 A *   02/25/18  KDE  7.20
      *     - Add fields zdstgflg, zdstrpck, zdstrovf1,
      *     - Add fields zdstgflg, zdstrpck, zdstrovf1,
      *       zdstrovf2, zdstrovf3.  These fields are used
      *       to pass info per a pick slot during replen
      *       and when entering Store Orders or Orders
      *       being pulled from location other than primary
      *       Warehouse
      *
      *       ZDTSTZONE- This is passed in with Zone such as
      *                  !STORE.  It will check this zone for
      *                  the incoming Pick Slot if sent.  If
      *                  incoming Pick Slot is found in Zone
      *                  it returns "Y" in ZDSTGFLG.  If slot
      *                  is not sent but item is it will see
      *                  if item exist in Zone.  If item found
      *                  it will return the Pick Slot in zone
      *                  as well as 3 overflow slots
      *
      *       ZDSTGFLG - When a pick slotis sent in a routine
      *                  will be called to determine if this
      *                  slot belongs to the Zone Definition
      *                  being passed in.  If it is a "Y" will
      *                  be passed back to caller saying this
      *                  Pick Slot exists in Store
      *
720aA *   10/16/18  DAS  7.20a
      *     - Changed to version 3
      *     - Added $zd/$zo fields actv, aisl2, rlvl2, clcde
      *
720bA *   10/25/18  DAS  7.20b
      *     - Left at version 3
      *     - Added $zd/$zo fields pckovf, cstcod
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
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

     D $zoned          ds

720aMD  $zdver#                       2s 0 Inz(3)
     D  $zdwhse                       3  0
     D   $zdwhsee                     1
     D   $zdwhseu                      n
     D  $zdtruk                      10
     D   $zdtruke                     1
     D   $zdtruku                      n
     D  $zdzone                       6
     D   $zdzonee                     1
     D   $zdzoneu                      n
     D  $zdwhdp                       5
     D   $zdwhdpe                     1
     D   $zdwhdpu                      n
640aMD  $zdstyp                       1
     D   $zdstype                     1
     D   $zdstypu                      n
     D  $zdaisl                       3
     D   $zdaisle                     1
     D   $zdaislu                      n
     D  $zdrlvl                       2  0
     D   $zdrlvle                     1
     D   $zdrlvlu                      n
     D  $zdloc1                       3  0
     D   $zdloc1e                     1
     D   $zdloc1u                      n
     D  $zdloc2                       3  0
     D   $zdloc2e                     1
     D   $zdloc2u                      n
     D  $zddesg                       5
     D   $zddesge                     1
     D   $zddesgu                      n
650aMD  $zdcat                       10
     D   $zdcate                      1
     D   $zdcatu                       n
     D  $zdhnd1                       2
     D   $zdhnd1e                     1
     D   $zdhnd1u                      n
     D  $zdhnd2                       2
     D   $zdhnd2e                     1
     D   $zdhnd2u                      n
     D  $zdutyp                       1
     D   $zdutype                     1
     D   $zdutypu                      n
     D  $zdside                       1
     D   $zdsidee                     1
     D   $zdsideu                      n

     D* Original values

     D  $zowhdp                       5
     D   $zowhdpe                     1
     D   $zowhdpu                      n
640aMD  $zostyp                       1
     D   $zostype                     1
     D   $zostypu                      n
     D  $zoaisl                       3
     D   $zoaisle                     1
     D   $zoaislu                      n
     D  $zorlvl                       2  0
     D   $zorlvle                     1
     D   $zorlvlu                      n
     D  $zoloc1                       3  0
     D   $zoloc1e                     1
     D   $zoloc1u                      n
     D  $zoloc2                       3  0
     D   $zoloc2e                     1
     D   $zoloc2u                      n
     D  $zodesg                       5
     D   $zodesge                     1
     D   $zodesgu                      n
650aMD  $zocat                       10
     D   $zocate                      1
     D   $zocatu                       n
     D  $zohnd1                       2
     D   $zohnd1e                     1
     D   $zohnd1u                      n
     D  $zohnd2                       2
     D   $zohnd2e                     1
     D   $zohnd2u                      n
     D  $zoutyp                       1
     D   $zoutype                     1
     D   $zoutypu                      n
     D  $zoside                       1
     D   $zosidee                     1
     D   $zosideu                      n

720 A *---------------------
720 A * Version 2 additions
720 A *---------------------

720 AD  $zdtsttruk                    6
720 AD   $zdtsttruke                  1
720 AD   $zdtsttruku                   n
720 AD  $zdstrbpck                   12
720 AD   $zdstrbpcke                  1
720 AD   $zdstrbpcku                   n
720 AD  $zdstrcpck                   12
720 AD   $zdstrcpcke                  1
720 AD   $zdstrcpcku                   n
720 AD  $zdstrbitm                   15
720 AD   $zdstrbitme                  1
720 AD   $zdstrbitmu                   n
720 AD  $zdstrcitm                   15
720 AD   $zdstrcitme                  1
720 AD   $zdstrcitmu                   n
720 AD  $zdstgflg                     1
720 AD   $zdstgflge                   1
720 AD   $zdstgflgu                    n
720 AD  $zdstrovf1                   12
720 AD   $zdstrovf1e                  1
720 AD   $zdstrovf1u                   n
720 AD  $zdstrovf2                   12
720 AD   $zdstrovf2e                  1
720 AD   $zdstrovf2u                   n
720 AD  $zdstrovf3                   12
720 AD   $zdstrovf3e                  1
720 AD   $zdstrovf3u                   n
720 AD  $zdwhcpck                     1
720 AD   $zdwhcpcke                   1
720 AD   $zdwhcpcku                    n
720 AD  $zdwhbpck                     1
720 AD   $zdwhbpcke                   1
720 AD   $zdwhbpcku                    n
720 AD  $zdstrepck                    1
720 AD   $zdstrepcke                  1
720 AD   $zdstrepcku                   n
     D  $zdCmd                        1
     D   $zdCmde                      1
     D   $zdCmdu                       n

720aA *---------------------
720aA * Version 3 additions
720aA *---------------------

720aAD  $zdactv                       2
720aAD   $zdactve                     1
720aAD   $zdactvu                      n
720aAD  $zoactv                       2
720aAD   $zoactve                     1
720aAD   $zoactvu                      n
720aAD  $zdaisl2                      3
720aAD   $zdaisl2e                    1
720aAD   $zdaisl2u                     n
720aAD  $zoaisl2                      3
720aAD   $zoaisl2e                    1
720aAD   $zoaisl2u                     n
720aAD  $zdrlvl2                      2  0
720aAD   $zdrlvl2e                    1
720aAD   $zdrlvl2u                     n
720aAD  $zorlvl2                      2  0
720aAD   $zorlvl2e                    1
720aAD   $zorlvl2u                     n
720aAD  $zdclcde                     10
720aAD   $zdclcdee                    1
720aAD   $zdclcdeu                     n
720aAD  $zoclcde                     10
720aAD   $zoclcdee                    1
720aAD   $zoclcdeu                     n
720bAD  $zdpckovf                    10
720bAD   $zdpckovfe                   1
720bAD   $zdpckovfu                    n
720bAD  $zopckovf                     1
720bAD   $zopckovfe                   1
720bAD   $zopckovfu                    n
720bAD  $zdcstcod                    20
720bAD   $zdcstcode                   1
720bAD   $zdcstcodu                    n
720bAD  $zocstcod                    20
720bAD   $zocstcode                   1
720bAD   $zocstcodu                    n
