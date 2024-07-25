      *===================================================================
      *
      *  Name .......... OHMISC_CSP
      *  Description ... ORDH - OHMISC Field - Coastal Sunbelt Produce
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
530 A *   09/22/10  MLB  5.30
      *     - Created.
      *
640 A *   11/01/11  JCJ  6.40
      *     - Enh: Added Print UPC code flag.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_csp      ds

     D  cspmsc_base                  20
     D*                                    text('OHMISC Field')

     Dcspmsc_ohdlvdte                 6    overlay(cspmsc_base:1)
     D*                                    text('Delivery Date')
     Dcspmsc_ohspp                    3    overlay(cspmsc_base:7)
     D*                                    text('*SP Single Pallet Pick')
     Dcspmsc_ohsubs                   1    overlay(cspmsc_base:10)
     D*                                    text('Sub Customer Y/N')
     Dcspmsc_ohcust                   6    overlay(cspmsc_base:11)
     D*                                    text('CSP Customer Number')
     Dcspmsc_ohprpk                   1    overlay(cspmsc_base:17)
     D*                                    text('Order Pre-Pick Flag Y/N')
640 ADcspmsc_ohprtupc                 1    overlay(cspmsc_base:18)
640 AD*                                    text('Print UPC Code Flag Y/N')
