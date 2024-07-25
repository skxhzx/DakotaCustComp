      *===================================================================
      *
      *  Name .......... C#LICINFO
      *  Description ... Dakota realtime interface layout for *LICINFO
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
417 A *   05/04/04  DAS  4.17
      *     - Created.
      *
640aA *   09/10/12  DAS  6.40a
      *     - LICINFO file changed to single record per license.
      *     - Added individual fields. Put into second data structure.
      *     - Left original fields for compatibility.
      *
      *===================================================================
      *
      * Notes
      *
      *   This data structure allows for up to 9 codes and corresponding
      *   values to be sent at once. This will help to reduce the number
      *   of times the interface must be called.
      *
      *   Also, one data value field is shared for both the character
      *   values and numeric values. This is done using the Overlay keyword.
      *   A one character field identifies the value type (A/N).
      *
      *===================================================================
      *
      * Notes
      *
416 A *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding indicator field.
      *       4) Create corresponding error indicator field.
      *
416 A *   - Each field should have a corresponding indicator field. This
416 A *     field is used to indicate if the field is being used (sent).
416 A *     The only exceptions are the warehouse and item fields, which
416 A *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
      *===================================================================

     D $licinfo        ds
640aMD  $lnver#                       2s 0 Inz(2)

      * The following fields must always be sent. No error checking is done.

     D  $lnemp#                       5  0
     D  $lnuser                      10
     D  $lnpgm                       10
     D  $lnjob                       10
     D  $lnjobnbr                     6

      * Manditory fields

     D  $lnwhse                       3  0
     D   $lnwhsee                     1
     D  $lntype                       1
     D   $lntypee                     1
     D  $lnlcns                      15
     D   $lnlcnse                     1

      * The following groups of fields are only sent/returned when needed.

     D  $lncode                       8    dim(7)
     D   $lncodee                     1    dim(7)
     D   $lncodeu                      n   dim(7)
     D  $lncseq                       5  0 dim(7)
     D  $lnvaltyp                     1    dim(7)
     D  $lnvalchr                    30    dim(7)
     D  $lnvalnum                    15  5 dim(7)
640aA
640aA * Version 2 fields
640aA
640aA * Individual fields for new LICINFO file single record format.
640aA

     D $licinfo2       ds

     D  $lnseq                        2s 0
     D  $lnseqqty                     5p 0
     D  $lnitem                      15
     D  $lnpo                        15
     D  $lnposeq                      5p 0
     D  $lnrcvtyp                     1
     D  $lnrcvtrn#                    7p 0
     D  $lnrcvlbl#                    7p 0
     D  $lnrcvqty                     5p 0
     D  $lnentdate                    8s 0
     D  $lnenttype                    8
     D  $lnmfgdate                    8s 0
     D  $lnmfgexp                     8s 0
     D  $lnfifodate                   8s 0
     D  $lnexpdate                    8s 0
     D  $lndateflag                   1
     D  $lnmfgflag                    1
     D  $lnmfgdays                    3p 0
     D  $lnusrdays                    3p 0
     D  $lndstdays                    3p 0
     D  $lnmfgcode                   15
     D  $lnttllbs                     9p 2
     D  $lnavglbs                     9p 2
     D  $lnlot                       30
     D  $lnlotpti2                    2
     D  $lnlotpti4                    4
     D  $lnhrvcert                   20
     D  $lnhrvdate                    8s 0
     D  $lnhrvloc                    20
     D  $lnbrand                     10
     D  $lnaddts                       z
