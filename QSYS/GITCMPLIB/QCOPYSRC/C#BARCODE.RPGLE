      *===================================================================
      *
      *  Name .......... C#BARCODE
      *  Description ... Dakota realtime interface layout for *BARCODE
      *  Created by .... Lynn McMahon
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   07/30/12  LMC  6.40
      *     - Created.
      *
740aA *   04/04/20  DAS  7.40a
      *     - Added cbdef#
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Always add new fields to the end of the layout.
      *       2) Create corresponding Sent field.
      *       3) Create corresponding error indicator field.
      *
      *===================================================================

     D $barcode        ds                  inz

      * Barcode SSCC

     D  $bcSscc                      18
     D   $bcSsccSent                   n

      * Barcode GTIN

     D  $bcGtin                      14
     D   $bcGtinSent                   n

      * Barcode Batch/Lot Number - variable up to 20

     D  $bcLot                       20
     D   $bcLotSent                    n

      * Barcode Production date

     D  $bcProdD                      6S 0
     D   $bcProdDSent                  n

      * Barcode Packaging date

     D  $bcPackD                      6S 0
     D   $bcPackDSent                  n

      * Barcode Sell By date

     D  $bcSlByD                      6S 0
     D   $bcSlByDSent                  n

      * Barcode Expiration date

     D  $bcExpD                       6S 0
     D   $bcExpDSent                   n

      * Barcode Serial - variable up to 20

     D  $bcSer#                      20
     D   $bcSer#Sent                   n

      * Barcode Product Net Lbs

     D  $bcPNtLb                     11S 3
     D   $bcPNtLbSent                  n

      * Barcode Product Net KG

     D  $bcPNtKg                     11S 3
     D   $bcPNtKgSent                  n

      * Barcode Internal Company Code 91 - variable up to 30

     D  $bcAi91                      30
     D   $bcAi91Sent                   n

      * Barcode Internal Company Code 92 - variable up to 30

     D  $bcAi92                      30
     D   $bcAi92Sent                   n

      * Barcode Internal Company Code 93 - variable up to 30

     D  $bcAi93                      30
     D   $bcAi93Sent                   n

      * Barcode Internal Company Code 94 - variable up to 30

     D  $bcAi94                      30
     D   $bcAi94Sent                   n

     D $barcode2       ds                  inz
      * Barcode Internal Company Code 95 - variable up to 30

     D  $bcAi95                      30
     D   $bcAi95Sent                   n

      * Barcode Internal Company Code 96 - variable up to 30

     D  $bcAi96                      30
     D   $bcAi96Sent                   n

      * Barcode Internal Company Code 97 - variable up to 30

     D  $bcAi97                      30
     D   $bcAi97Sent                   n

      * Barcode Internal Company Code 98 - variable up to 30

     D  $bcAi98                      30
     D   $bcAi98Sent                   n

      * Barcode Internal Company Code 99 - variable up to 30

     D  $bcAi99                      30
     D   $bcAi99Sent                   n

740aA * User Defined barcode definition used
740aA
740aAD  $bcdef#                      30
740aAD   $bcdef#Sent                   n


