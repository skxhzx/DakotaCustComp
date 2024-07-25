      *===================================================================
      *
      *  Name .......... ORDHM1_HAR
      *  Description ... Order Header Misc. Field 1 - Harbor
      *  Created by .... Dave Sommerville
      *
      * Revisions
      *
520 A *   02/01/08  DAS  5.20  P#00006
      *     - Created.
      *
520aA *   03/13/08  RBD  5.20a P#00006
      *     - Fix: Revised starting position of some fields.
      *            Deleted Item Status Code field.
      *
520bA *   05/14/08  RBD  5.20b P#00006
      *     - Changed field size of DUNS# from 7 to 9.
      *
520cA *   09/04/08  DAS  5.20c P#00004
      *     - Added INZ to data structure
      *
710a  *   05/12/17  RTR  7.10a
      *     - Added HighJump order number.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

520cMD ordhm1_har      ds                  inz

     D  harhm1_base                  40
     D*                                    text('Header Misc 1 Field')

     D  harhm1_WlgV#                  6  0 overlay(harhm1_base:1)
     D*                                    text('Walgreens Ven#')

     D  harhm1_WlgS#                  5  0 overlay(harhm1_base:7)
     D*                                    text('Walgreens Store#')

     D  harhm1_ShpDt                  8  0 overlay(harhm1_base:12)
     D*                                    text('Ship Date (YYYYMMDD)')

520aDD**harhm1_PODte                  8  0 overlay(harhm1_base:8)
520aMD  harhm1_PODte                  8  0 overlay(harhm1_base:20)
     D*                                    text('Customer PO Date (yyyymmdd)'

520aDD**harhm1_DUNS#                  7  0 overlay(harhm1_base:1)
520bDD**harhm1_DUNS#                  7  0 overlay(harhm1_base:28)
520bMD  harhm1_DUNS#                  9  0 overlay(harhm1_base:28)
     D*                                    text('Bill-to DUNS#')

520aDD**harhm1_StsCd                  2    overlay(harhm1_base:16)
     D*                                    text('Item Status Code'

710aAD  harhm1_hmordr                30    overlay(harhm1_base:1)
710aAD*                                    text('HAR HighJump Order')

