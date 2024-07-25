      *===================================================================
      *
      *  Name .......... IPQMEM_GMM
      *  Description ... IPQMEM field - Grave's Menu Maker
      *  Created by .... Max Blacknik
      *
      *===================================================================
      * Revisions
      *
650 A *   02/13/13  MLB  6.50
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ipqmem_gmm      ds

     D  gmmmsc_base                  30
     D*                                    text('IPQMEM Field')

     D  gmmmsc_Rte                    2    overlay(gmmmsc_base:1)
     D*                                    text('Host Route Nbr - TF Only')

     D  gmmmsc_bkflg                  1    overlay(gmmmsc_base:3)
     D*                                    text('Host Brkdwn Flag Y=Yes  -
     D*                                    Cvt IPQQP2 - TF Only')

     D  gmmmsc_ogitm                 15    overlay(gmmmsc_base:4)
     D*                                    text('Host Orginal item sent  -
     D*                                    for adj - TF Only. Set by HQ245')

