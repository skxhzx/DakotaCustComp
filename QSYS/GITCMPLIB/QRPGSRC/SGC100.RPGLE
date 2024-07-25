500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  SGC100     Total Item Sales ITEMSLS
     *  29 March 2011
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    03/29/11  RH   6.40
     *      - Created
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SGC A*    03/29/11  RH
     *      - Program custom for Springfield Grocery
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     fsgcamtsum ip   e           k disk
     fpiritem   if   e           k disk
     fsgctls    o  a e           k disk

520aA*----------------------------------------------------------------
520aA*  Client custom identifiers
520aA*----------------------------------------------------------------

520aA /COPY *libl/qcopysrc,id#sgc

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#SLOT
500dAD saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D pWhse#          s                   like(sgtwhs)
     D kyWhse          s                   like(sgtwhs)
     D kyWhdp          s                   like(sgtwhd)
     D kyDisp          s                   like(sgtdsp)
     D error           s               n
     D forever         s               n
     D drierr          s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    pWhse             3
     C                   parm                    pWhdp             5

     C                   move      pWhse         pWhse#

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Get item description and department.

     C     keyitm        chain     piritem
     C                   if        %found(piritem)
     C                   eval      sgtwhd = itwhdp
     C                   eval      sgtdsc = itdesc
     C                   else
     C                   eval      sgtwhd = *blanks
     C                   eval      sgtdsc = *blanks
     C                   endif

     *    Retrieve pick slot.
     C*                  eval      $scmd = '*FIRST  '
     C                   eval      $scmd = '*FRSTFRS'
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      pwhse#        $swhse            3 0
     C                   parm      ihitem        $sitem           15
     C                   parm      *blanks       woslot           12
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm      *blanks       $srtn             8
     *
     C                   if        $srtn = '*OKPICK '
     C                   eval      sgtdsp = woslot
     C                   eval      sgtasl = $saisl
     C                   else
     C                   eval      sgtdsp = '*NONE       '
     C                   eval      sgtasl = *blanks
     C                   endif
     C                   eval      sgtwhs = pwhse#
     C                   eval      sgtitm = ihitem
     C                   eval      sgtqsw = amtsum
     C                   write     sgtrec


     * Bye, Bye.

     C**                 eval      *inlr = *on

     *------------------------------------------------------------------
     * *INZSR
     *------------------------------------------------------------------

     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *
     C     keyitm        klist
     C                   kfld                    pwhse#
     C                   kfld                    ihitem
     *
     C                   endsr

     *------------------------------------------------------------------


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

