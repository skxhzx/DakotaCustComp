      *===================================================================
      *
      *  Name .......... OHMISC_CDI
      *  Description ... ORDH - OHMISC Field - CDI-LLC
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
700 A *   09/03/15  MLB  7.00
      *     - Created.
CDI A *   02/24/22  MLB  CDI
      *     - Added missing field for Single Pallet Pick. *SP.
      *     - Single pallet pick flag only set when importing PREPULL rtes.
CDIaA *   02/24/22  MLB  CDIa
      *     - Added field cdimsc_ohcncp Concept Code to be printed on pick
      *       labels in place of dock door. Current codes: POP, CHK and SUB.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_cdi      ds

     D  cdimsc_base                  20
     D*                                    text('OHMISC Field')

     Dcdimsc_ohdlvdte                 6    overlay(cdimsc_base:1)
     D*                                    text('Delivery Date')
CDI ADcdimsc_ohspp                    3    overlay(cdimsc_base:7)
CDI AD*                                    text('*SP Single Pallet Pick')
     Dcdimsc_ohprpk                   1    overlay(cdimsc_base:17)
     D*                                    text('Order Pre-Pick Flag Y/N')
CDIaADcdimsc_ohcncp                   3    overlay(cdimsc_base:18)
CDIaAD*                                    text('Customer Concept Code')
