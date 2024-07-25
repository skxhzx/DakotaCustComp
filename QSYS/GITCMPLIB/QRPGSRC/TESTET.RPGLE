      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TESTET    Test DRIEQUIPT
     *  26 December 2002
     *  Dave Sommerville
     *
     *  Revisions
     *
100 A*    12/26/02  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#EQUIPT
     D saveVer#        s                   like($etver#)
     D savetrn#        s                   like($ettrn#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Misc variables
     *----------------------------------------------------------------

     D dftemp#         s              5  0 inz(1)
     D dfttranin       s              7  0 inz(1235)
     D dfttranout      s              7  0 inz(1234)
     D dftwhse         s              3  0 inz(900)

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *--------------------------------------------------------------------
     * Check Out forklift F901
     *--------------------------------------------------------------------

     * Start 'Out' transaction.

     *    Add necessary code.


     * Create equipment 'Out' transaction'

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $etcodeu = '1'
     C                   eval      $etcode  = 'F901'
     C                   eval      $etemp#u = '1'
     C                   eval      $etemp#  = dftemp#
     C                   eval      $etotrnu = '1'
     C                   eval      $etotrn  = dfttranout
     C                   eval      $etousru = '1'
     C                   eval      $etousr  = #user
     C                   eval      $etojobu = '1'
     C                   eval      $etojob  = #job
     C                   eval      $etonbru = '1'
     C                   eval      $etonbr  = #jobnbr
     C                   eval      $drisubcmd = '*CHKOUT'
     C                   exsr      callequipt
     C                   eval      savetrn# = $ettrn#

     * Get responses to questions.

     *    Add necessary code.


     * Update equipment 'Out' transaction with question flags.
     *   Set $etoqfl to '1' if questions were asked.
     *   Set $etoxfl to '1' if an exception answer was recorded.

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $ettrn#u = '1'
     C                   eval      $ettrn#  = savetrn#
     C                   eval      $etoqflu = '1'
     C                   eval      $etoqfl  = '1'
     C                   eval      $etoxflu = '1'
     C                   eval      $etoxfl  = '1'
     C                   eval      $drisubcmd = '*CHANGE'
     C                   exsr      callequipt

     *--------------------------------------------------------------------
     * Time lapse
     *--------------------------------------------------------------------

     * Pause for 90 seconds.

     C                   call(e)   'DLYJOBCL'
     C                   parm      90            seconds           5 0

     *--------------------------------------------------------------------
     * Check In forklift 901
     *--------------------------------------------------------------------

     * Start 'In' transaction.

     *    Add necessary code.


     * Create equipment 'In' transaction'

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $etcodeu = '1'
     C                   eval      $etcode  = 'F901'
     C                   eval      $etemp#u = '1'
     C                   eval      $etemp#  = dftemp#
     C                   eval      $etitrnu = '1'
     C                   eval      $etitrn  = dfttranin
     C                   eval      $etiusru = '1'
     C                   eval      $etiusr  = #user
     C                   eval      $etijobu = '1'
     C                   eval      $etijob  = #job
     C                   eval      $etinbru = '1'
     C                   eval      $etinbr  = #jobnbr
     C                   eval      $drisubcmd = '*CHKIN'
     C                   exsr      callequipt
     C                   eval      savetrn# = $ettrn#

     * Get responses to questions.

     *    Add necessary code.


     * Update equipment 'In' transaction with question flags.
     *   Set $etiqfl to '1' if questions were asked.
     *   Set $etixfl to '1' if an exception answer was recorded.

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $ettrn#u = '1'
     C                   eval      $ettrn#  = savetrn#
     C                   eval      $etiqflu = '1'
     C                   eval      $etiqfl  = '1'
     C                   eval      $etixflu = '1'
     C                   eval      $etixfl  = '1'
     C                   eval      $drisubcmd = '*CHANGE'
     C                   exsr      callequipt

     *--------------------------------------------------------------------
     * Check In forklift F902 (Note, F902 was never checked out.
     *--------------------------------------------------------------------

     * Start 'In' transaction.

     *    Add necessary code.


     * Create equipment 'In' transaction'

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $etcodeu = '1'
     C                   eval      $etcode  = 'F902'
     C                   eval      $etemp#u = '1'
     C                   eval      $etemp#  = dftemp#
     C                   eval      $etitrnu = '1'
     C                   eval      $etitrn  = dfttranin
     C                   eval      $etiusru = '1'
     C                   eval      $etiusr  = #user
     C                   eval      $etijobu = '1'
     C                   eval      $etijob  = #job
     C                   eval      $etinbru = '1'
     C                   eval      $etinbr  = #jobnbr
     C                   eval      $drisubcmd = '*CHKIN'
     C                   exsr      callequipt
     C                   eval      savetrn# = $ettrn#

     * Get responses to questions.

     *    Add necessary code.


     * Update equipment 'In' transaction with question flags.
     *   Set $etiqfl to '1' if questions were asked.
     *   Set $etixfl to '1' if an exception answer was recorded.

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $ettrn#u = '1'
     C                   eval      $ettrn#  = savetrn#
     C                   eval      $etiqflu = '1'
     C                   eval      $etiqfl  = '1'
     C                   eval      $etixflu = '1'
     C                   eval      $etixfl  = '1'
     C                   eval      $drisubcmd = '*CHANGE'
     C                   exsr      callequipt

     *--------------------------------------------------------------------
     * Check Out forklift F901 (This time it is left checked out)
     *--------------------------------------------------------------------

     * Start 'Out' transaction.

     *    Add necessary code.


     * Create equipment 'Out' transaction'

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $etcodeu = '1'
     C                   eval      $etcode  = 'F901'
     C                   eval      $etemp#u = '1'
     C                   eval      $etemp#  = dftemp#
     C                   eval      $etotrnu = '1'
     C                   eval      $etotrn  = dfttranout
     C                   eval      $etousru = '1'
     C                   eval      $etousr  = #user
     C                   eval      $etojobu = '1'
     C                   eval      $etojob  = #job
     C                   eval      $etonbru = '1'
     C                   eval      $etonbr  = #jobnbr
     C                   eval      $drisubcmd = '*CHKOUT'
     C                   exsr      callequipt
     C                   eval      savetrn# = $ettrn#

     * Get responses to questions.

     *    Add necessary code.


     * Update equipment 'Out' transaction with question flags.
     *   Set $etoqfl to '1' if questions were asked.
     *   Set $etoxfl to '1' if an exception answer was recorded.

     C                   exsr      clrequipt
     C                   eval      $etwhseu = '1'
     C                   eval      $etwhse  = dftwhse
     C                   eval      $ettrn#u = '1'
     C                   eval      $ettrn#  = savetrn#
     C                   eval      $etoqflu = '1'
     C                   eval      $etoqfl  = '1'
     C                   eval      $etoxflu = '1'
     C                   eval      $etoxfl  = '1'
     C                   eval      $drisubcmd = '*CHANGE'
     C                   exsr      callequipt

     *--------------------------------------------------------------------
     * Bye, Bye
     *--------------------------------------------------------------------

     * Close file program.

     C                   eval      $drisubcmd = '*CLOSE'
     C                   exsr      callequipt

     * Bye, Bye.

     C     bottom        tag
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  callequipt      Call driequipt
     *----------------------------------------------------------------

     C     callequipt    begsr
     C                   eval      error = *off

     C                   call(e)   'DRIEQUIPT'
     C                   parm                    $drisubcmd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $equipt       parm      $equipt       $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  clrequipt  Clear data structure $equipt
     *----------------------------------------------------------------

     C     clrequipt     begsr
     C                   eval      savever# = $etver#
     C                   clear                   $equipt
     C                   eval      $etver# = savever#
     C                   endsr
