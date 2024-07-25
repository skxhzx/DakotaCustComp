      *===================================================================
      *
      *  Name .......... OHMISC_HAR
      *  Description ... OHMISC field - Harbor
      *  Created by .... Dave Sommerville
      *
      * Revisions
      *
520 A *   02/11/08  DAS  5.20  P#00006
      *     - Created.
520aA *   06/11/09  RBD  5.20a P#00214
      *     - Added 'Create POD Files' flag.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_har      ds

     D  harmsc_base                  20
     D*                                    text('OHMISC Field')

     D  harmsc_Date                   6  0 overlay(harmsc_base:1)
     D*                                    text('Date MMDDYY')

     D  harmsc_jur                    2    overlay(harmsc_base:10)
     D*                                    text('Jurisdiction')

520aAD  harmsc_pod                    1    overlay(harmsc_base:19)
520aAD*                                    text('POD flag')

     D  harmsc_asn                    1    overlay(harmsc_base:20)
     D*                                    text('ASN flag')
