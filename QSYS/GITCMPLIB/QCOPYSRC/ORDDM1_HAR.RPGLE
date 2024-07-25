      *===================================================================
      *
      *  Name .......... ORDDM1_HAR
      *  Description ... Order Detail Misc. Field 1 - Harbor
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
510 A *   09/10/07  MLB  5.10
      *     - Created.
520 A *   07/16/08  RBD  5.20   P#00003
      *     - Added promo item flag.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_har      ds

     D  hardm1_base                  40
     D*                                    text('Detail Misc 1 Field')
     D  hardm1_rtlprc                 7    overlay(hardm1_base:1)
     D*                                    text('Customer retail price')
     D  hardm1_margin                 7    overlay(hardm1_base:8)
     D*                                    text('Customer margin %')
     D  hardm1_mfgcd                  6    overlay(hardm1_base:15)
     D*                                    text('Customer margin %')
     D  hardm1_item                  10    overlay(hardm1_base:21)
     D*                                    text('Mfg item number')
     D  hardm1_taxc                   2    overlay(hardm1_base:31)
     D*                                    text('Tax jurisdiction code')
     D  hardm1_toten                  1    overlay(hardm1_base:33)
     D*                                    text('Tote item-case Y/N')
     D  hardm1_tote1                  1    overlay(hardm1_base:34)
     D*                                    text('Tote item-Brk 1')
     D  hardm1_tote2                  1    overlay(hardm1_base:35)
     D*                                    text('Tote item-Brk 2')
520 AD  hardm1_promo                  1    overlay(hardm1_base:36)
520 AD*                                    text('Promo Item Flag')
