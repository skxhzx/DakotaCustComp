      *===================================================================
      *
      *  Name .......... ORDHM2_CSP
      *  Description ... Order Header Misc. Field 2 - Coastal Sunbelt
      *  Created by .... Max Blacknik
      *
      *------------------------------------------------------------------*
      * Revisions
      *
530 A *   09/15/10  MLB  5.30
      *     - Created.
      *
CSP A *   04/22/19  MLB  CSP  P#02062
      *     - Revised pgm to add new field, CSPHM2_rcvwh - Interwarehouse
      *       Transfer Rcv whse.
      *     - Revised pgm to add new field, CSPHM2_rcvpo - Interwarehouse
      *       Transfer Rcv p/o.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

530 AD ordhm2_csp      ds                  inz

     D  csphm2_base                  40
     D*                                    text('Header Misc 2 Field')
CSP A
CSP AD  csphm2_rcvwh                  3    overlay(csphm2_base:1)
CSP AD*                                    text('IWT Rcv Whse')
CSP A
CSP AD  csphm2_rcvpo                  9    overlay(csphm2_base:4)
CSP AD*                                    text('IWT Rcv P/O')
