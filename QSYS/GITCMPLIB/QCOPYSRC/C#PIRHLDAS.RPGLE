      *===================================================================
      *
      *  Name .......... C#PIRHLDAS
      *  Description ... PIRHOLD ASN Receiving info data structure
      *  Created by .... Kenneth Elder
      *===================================================================
      *
      * Revisions
      *
700aA *   06/19/20  KDE  7.40
      *     - Created.
      *
      *===================================================================
      *   Type will be PODTLASN
      *   key field will be PO/POSEQ/ITEM
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLDAS  - File information data structure - PIRHOLD ASN
     *----------------------------------------------------------------

     D pirhldasds      ds
     D  phlpn                  1     48
     D  phupc                 49     68
     D  phexpd                69     74  0
     D  phlot                 75     94
     D  phqtyr                95    104  0
     D  phwgt                105    114  3
     D  phmfgd               115    120  0
     D  phuom                121    122

     *** End C#PIRHLDAS ***
