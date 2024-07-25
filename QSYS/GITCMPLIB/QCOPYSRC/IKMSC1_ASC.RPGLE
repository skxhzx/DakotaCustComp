      *===================================================================
      *
      *  Name .......... IKMSC1_ASC
      *  Description ... Item Extension File Misc. Field 1 - Agar Supply
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   05/08/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ikmsc1_asc      ds

     D  ascik1_base                  40
     D*                                    text('User Misc 1 Field')
640 ADascik1_enfcw                    1    overlay(ascik1_base:1)
640 AD*                                    text('SAP Enforce Catchweight')
640 ADascik1_pctabswt                 1    overlay(ascik1_base:2)
640 AD*                                    text('SAP Percent Absolute Weight')
640 ADascik1_minweigh                 6    overlay(ascik1_base:3)
640 AD*                                    text('SAP Min Catchweight')
640 ADascik1_maxweigh                 6    overlay(ascik1_base:9)
640 AD*                                    text('SAP Max Catchweight')
640 ADascik1_absminwt                 6    overlay(ascik1_base:15)
640 AD*                                    text('SAP Abs Min Catchweight')
640 ADascik1_absmaxwt                 6    overlay(ascik1_base:21)
640 AD*                                    text('SAP Abs Max Catchweight')
640 ADascik1_avgweigh                 6    overlay(ascik1_base:27)
640 AD*                                    text('SAP Average Weight')
640 ADascik1_expdatfl                 1    overlay(ascik1_base:33)
640 AD*                                    text('SAP Exp Date Flag')
640 ADascik1_enfexpdt                 1    overlay(ascik1_base:34)
640 AD*                                    text('SAP Enforce Exp Date Flag')
640 ADascik1_expdtfmt                 1    overlay(ascik1_base:35)
640 AD*                                    text('SAP Exp Date Format')
640 ADascik1_daystoex                 3    overlay(ascik1_base:36)
640 AD*                                    text('SAP Days to Expiration')
640 ADascik1_upcflag                  1    overlay(ascik1_base:39)
640 AD*                                    text('SAP UPC Flag')

