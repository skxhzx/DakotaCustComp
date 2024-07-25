      *===================================================================
      *
      *  Name .......... C#REDP
      *  Description ... Dakota realtime interface layout for *REPD
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
417 A *   07/15/04  DAS  4.16
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding indicator field.
      *       4) Create corresponding error indicator field.
      *
      *   - Each field should have a corresponding indicator field. This
      *     field is used to indicate if the field is being used (sent).
      *     The only exceptions are the warehouse and item fields, which
      *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
      *   - Most fields should have a corresponding error flag field. This
      *     field is used to indicate if the field caused an error or a
      *     warning. Values are 0 = No error/warning, 1 = Error and
      *     2 = Warning.
      *
      *===================================================================

     D $RedP           ds

     D  $rpVer#                       2s 0 Inz(1)
     D  $rpuser                      10
     D  $rpjob                       10
     D  $rpjobn                       6

     D  $rpwhse                       3  0
     D   $rpwhsee                     1
     D   $rpwhseu                      n
     D  $rplbl#                       7  0
     D   $rplbl#e                     1
     D   $rplbl#u                      n
     D  $rptrn#                       7  0
     D   $rptrn#e                     1
     D   $rptrn#u                      n
     D  $rprteid                      5
     D   $rprteide                    1
     D   $rprteidu                     n
     D  $rprte                        5
     D   $rprtee                      1
     D   $rprteu                       n
     D  $rpemp#                       5  0
     D   $rpemp#e                     1
     D   $rpemp#u                      n
     D  $rplocation                  20
     D  $loctype                      1    overlay($rplocation:13)
     D   $rplocatione                 1
     D   $rplocationu                  n
     D  $rpseq#                       4  0
     D   $rpseq#e                     1
     D   $rpseq#u                      n
