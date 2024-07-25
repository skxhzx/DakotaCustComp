      *===================================================================
      *
      *  Name .......... C#LICHIST
      *  Description ... Dakota realtime interface layout for *LICHIST
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
417 A *   04/06/04  DAS  4.17
      *     - Created.
      *
500 A *   10/17/04  DAS  5.00
      *     - Changed length of $lrnode to 50 characters from 20.
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

     D $lichist        ds
     D  $lrver#                       2s 0 Inz(1)
     D*
     D* The following fields must always be sent. No error checking is done.
     D*
     D  $lremp#                       5  0
     D  $lruser                      10
     D  $lrpgm                       10
     D  $lrjob                       10
     D  $lrjobn                       6
     D*
     D* The following fields are only sent when needed by the subcommand.
     D*
     D  $lrwhse                       3  0
     D   $lrwhsee                     1
     D   $lrwhseu                      n
     D  $lrltrn                       7  0
     D   $lrltrne                     1
     D   $lrltrnu                      n
     D  $lracfl                       2
     D   $lracfle                     1
     D   $lracflu                      n
500 DD**$lrnode                      20
500 MD  $lrnode                      50
     D   $lrnodee                     1
     D   $lrnodeu                      n
     D  $lrtrn#                       7  0
     D   $lrtrn#e                     1
     D   $lrtrn#u                      n
     D  $lrlbl#                       7  0
     D   $lrlbl#e                     1
     D   $lrlbl#u                      n
     D  $lrlcns                      15
     D   $lrlcnse                     1
     D   $lrlcnsu                      n
     D  $lrflic                      15
     D   $lrflice                     1
     D   $lrflicu                      n
     D  $lrolic                      15
     D   $lrolice                     1
     D   $lrolicu                      n
     D  $lrlqy1                       7  0
     D   $lrlqy1e                     1
     D   $lrlqy1u                      n
     D  $lrlqy2                       7  0
     D   $lrlqy2e                     1
     D   $lrlqy2u                      n
     D  $lrlqy3                       7  0
     D   $lrlqy3e                     1
     D   $lrlqy3u                      n
     D  $lraqy1                       7  0
     D   $lraqy1e                     1
     D   $lraqy1u                      n
     D  $lraqy2                       7  0
     D   $lraqy2e                     1
     D   $lraqy2u                      n
     D  $lraqy3                       7  0
     D   $lraqy3e                     1
     D   $lraqy3u                      n
     D*
     D  $lrfcod                       1
     D   $lrfcode                     1
     D   $lrfcodu                      n
     D  $lrfara                      15
     D   $lrfarae                     1
     D   $lrfarau                      n
     D  $lrfwhd                       5
     D   $lrfwhde                     1
     D   $lrfwhdu                      n
     D  $lrfdsp                      12
     D   $lrfdspe                     1
     D   $lrfdspu                      n
     D  $lrfasl                       3
     D   $lrfasle                     1
     D   $lrfaslu                      n
     D  $lrfloc                       3  0
     D   $lrfloce                     1
     D   $lrflocu                      n
     D  $lrflvl                       2  0
     D   $lrflvle                     1
     D   $lrflvlu                      n
     D  $lrfhnd                       2
     D   $lrfhnde                     1
     D   $lrfhndu                      n
     D  $lrfslp                       3  0
     D   $lrfslpe                     1
     D   $lrfslpu                      n
     D  $lrfitm                      15
     D   $lrfitme                     1
     D   $lrfitmu                      n
     D*
     D  $lrtcod                       1
     D   $lrtcode                     1
     D   $lrtcodu                      n
     D  $lrtara                      15
     D   $lrtarae                     1
     D   $lrtarau                      n
     D  $lrtwhd                       5
     D   $lrtwhde                     1
     D   $lrtwhdu                      n
     D  $lrtdsp                      12
     D   $lrtdspe                     1
     D   $lrtdspu                      n
     D  $lrtasl                       3
     D   $lrtasle                     1
     D   $lrtaslu                      n
     D  $lrtloc                       3  0
     D   $lrtloce                     1
     D   $lrtlocu                      n
     D  $lrtlvl                       2  0
     D   $lrtlvle                     1
     D   $lrtlvlu                      n
     D  $lrthnd                       2
     D   $lrthnde                     1
     D   $lrthndu                      n
     D  $lrtslp                       3  0
     D   $lrtslpe                     1
     D   $lrtslpu                      n
     D  $lrtitm                      15
     D   $lrtitme                     1
     D   $lrtitmu                      n
     D  $lrtord                       7  0
     D   $lrtorde                     1
     D   $lrtordu                      n
     D  $lrtseq                       5  0
     D   $lrtseqe                     1
     D   $lrtsequ                      n
     D  $lrexcd                       8
     D   $lrexcde                     1
     D   $lrexcdu                      n
