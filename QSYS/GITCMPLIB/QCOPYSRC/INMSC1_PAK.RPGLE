      *===================================================================
      *
      *  Name .......... INMSC1_Inv
      *  Description ... Inventory Adjustment Misc file Field 1
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   10/26/06  JCJ  5.10
      *     - Created.
      *
DRI A*    01/19/07  RAH  5.10a
     *      - Change cost and extended cost fields from 7,2 and 9,2
     *        to 9,4 and 11,4 respectively.
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D INmsc1_pak      ds

     D  invad1_base                  40
     D*                                    text('Invadjm Misc 1 Field')

510aMD  invad1_cost                   9s 4 overlay(invad1_base:1)
510aDD* invad1_cost                   7s 2 overlay(invad1_base:1)
     D*                                    text('Item Cost')

510aMD  invad1_extcst                11s 4 overlay(invad1_base:10)
510aDD* invad1_extcst                 9s 2 overlay(invad1_base:8)
     D*                                    text('Extended Item Cost')
