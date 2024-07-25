      *===================================================================
      *
      *  Name .......... C#CVTPARMS
      *  Description ... CVTBAR parameters
      *  Created by .... Lynn McMahon
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   07/30/12  LMC  6.40
      *     - Created.
      *
640 A *   10/01/12  DAS  6.40a
      *     - Added $cb fields.
      *
700aA *   03/22/16  LMC  7.00a
      *     - Added $cbwhse field.
      *
740aA *   04/02/20  DAS  7.40a
      *     - Added fields $PkilolbsSent, $PItem
      *
      *===================================================================

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $cbcmd       Command
      *      $cbbar       Barcode
      *      $cbven       Vendor/Mfr number. Used for *CWGTLBS.
      *      $cbwhse      Whse used to get item options for weight uom
740aA *      $cbkilolbsSent  (optional)
740aA *      $cbItem      Item number, used with user-defined barcodes (optional)
      *
      *    Returned Parameters
      *      $cbcod       Application identifier
      *      $cbdec       Application identifier decimal positions
      *      $cbdsc       Application identifier description
      *      $cbpos       Application identifier code position
      *      $cbtyp       Value type
      *      $cbv1        Numeric 11.3
      *      $cbv2        Alpha 50
      *      $cbrtn       Return code
      *      $cberm       Error message
      *      $cvtdata     Individual extracted fields - Part 1
      *      $cvtdata2    Individual extracted fields - Part 2
      *
      *----------------------------------------------------------------

     D $cbcmd          s              8
     D $cbbar          s            100
     D $cbcod          s              3  0
     D $cbdec          s              1  0
     D $cbdsc          s             30
     D $cbpos          s              3  0
     D $cbtyp          s              1  0
     D $cbv1           s             11  3
     D $cbv2           s             50
     D $cbrtn          s              8
     D $cberm          s             60
     D $cbven          s             10  0
     D $cvtdata        s            256
     D $cvtdata2       s            256
     D $cbwhse         s              3  0
     D $cbkilolbsSent  s              1
     D $cbItem         s             15

