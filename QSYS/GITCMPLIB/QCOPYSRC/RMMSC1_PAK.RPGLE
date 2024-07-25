      *===================================================================
      *
      *  Name .......... RMMSC1_Pak
      *  Description ... Misc Customer returns file Misc Field1 - Packer's
      *  Created by .... Jeffrey Jahnke
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   10/16/06  JCJ  5.10
      *     - Created.
      *
      *===================================================================
      *
      * Client Custom Revisions: Packer's Provision
      *
PCK A *   08/27/07  MLB  PCK  ** Remove when live with SAP **
      *     - Revised program to vkorg SAP sales organization to misc 1
      *       field. This is a temporary mod to be used to send returns
      *       Packer's Alpha computer system.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D rmmsc1_pak      ds

     D  pakrm1_base                  40
     D*                                    text('Return Misc 1 Field')

     D  pakrm1_delv                   9    overlay(pakrm1_base:1)
     D*                                    text('Delivery Number')

     D  pakrm1_bdoc                  10    overlay(pakrm1_base:10)
     D*                                    text('Billing Document')
PCK A
PCK AD  pakrm1_vkorg                  4    overlay(pakrm1_base:20)
PCK AD*                                    text('SAP Sales Organization')
PCK AD*                                    text('2000=001 Packer's     ')
PCK AD*                                    text('2100=002 Le Grand     ')
PCKaA
PCKaAD  pakrm1_ordid                  7    overlay(pakrm1_base:24)
PCKaAD*                                    text('BFC Order Id
