      *===================================================================
      *
      *  Name .......... OHMISC_YHA
      *  Description ... OHMISC field - Yhata
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      * Revisions
      *
520 A *   10/14/08  JCJ  5.20
      *     - Created.
      *
700 A *   02/24/16  MLB  7.00
      *     - Enh: Added additional fields to map data stored in field.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_yha      ds

     D  yhamsc_base                  20
     D*                                    text('OHMISC Field')
700 A
700 AD  yhamsc_Cmpn                   3    overlay(yhamsc_base:1)
700 AD*                                    text('Host Company')
700 A
700 AD  yhamsc_Divn                   3    overlay(yhamsc_base:4)
700 AD*                                    text('Host Division')
700 A
700 AD  yhamsc_Dptn                   3    overlay(yhamsc_base:7)
700 AD*                                    text('Host Department')
700 A
700 AD  yhamsc_Whsn                   3    overlay(yhamsc_base:10)
700 AD*                                    text('Host Warehouse')

     D  yhamsc_Memo                   3    overlay(yhamsc_base:13)
700 MD*                                    text('Host Memo Code')

700 DD* yhamsc_Date                   7P 0 overlay(yhamsc_base:16)
700 DD*                                    text('Date MMDDYY')
