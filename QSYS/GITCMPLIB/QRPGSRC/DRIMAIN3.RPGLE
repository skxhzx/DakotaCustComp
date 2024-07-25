     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

      *****************************************************************
      ***                                                           ***
      ***   THIS PROGRAM SHOULD BE AN EXACT DUPLICATE OF DRIMAIN    ***
      ***                                                           ***
      *****************************************************************

      *----------------------------------------------------------------
      *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *----------------------------------------------------------------
      *
      *  DRIMAIN3    Dakota realtime interface program - Main pgm 3rd copy
      *  19 January 2009
      *  Dave Sommerville
      *
      *  Revisions
      *
416 A *    01/23/02  DAS  4.16b
      *      - Created this program DRIMAIN2, a duplicate of DRIMAIN.
      *        Re: Not able to do recursive calls at this time.
      *
416aA *    01/25/02  DAS  4.16c
      *      - Added debugging logic to write information to a log file.
      *
416dA *    02/13/02  DAS  4.16d
      *      - Revised logging to check number of parameters sent.
      *
416eA *    06/11/03  DAS  4.16e
      *      - Revised to identify multiple data parameters.
      *
500 A *    07/11/03  DAS  5/00
      *      - Added data area DRIDEBUG2 to determine whether to write
      *        the 'I', 'O' or both records.
      *
600 A *    01/19/09  DAS  6.00
      *      - Created this program DRIMAIN3, a duplicate of DRIMAIN.
      *        Re: Not able to do recursive calls at this time.
      *
600aA *    01/19/09  DAS  6.00a
      *      - In this program if $dricommand does not start with
      *        an '*', it is assumed to be the actual progam name to call.
      *
640a  *    02/08/11  GJA  6.40a
      *      - Fix:  If LOGDRI# is locked bypass log file write.
      *
      *
640b  *    03/11/11  GJA  6.40b
      *      - Fix:  Added unlock for LOGDRI#
      *
640c  *    04/19/11  DAS  6.40c
      *      - Revised logic for excluding certain subcommands from
      *        the log. See comments on DRIDEBUG3 data area.
      *
710aA *    04/18/17  LMC  7.10a
      *      - Revised to add $dridata3.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Notes
      *
      *    This program is called from all Dakota programs that use the
      *    Dakota Real-time Interface (DRI).
      *
      *    Data area DRIDEBUG has been created to control whether log
      *    records should be written to file LOGDRI. Records are
      *    written to the file with the data area contains a '1'. A
      *    record is written with the incoming information and another
      *    is written for the outgoing information. The latter is only
      *    written when a successful call is made to the DRI program.
      *
500 A *    Data area DRIDEBUG2 has been created to control which log
500 A *    records should be written. The options are 'I' for input only,
500 A *    'O' for Output only, or 'B' for both Input and Output. 'B' is
500 A *    the default.
      *
640cA *    Data area DRIDEBUG3 has been created to control subcommands
640cA *    to not write out to the log file. Only characters 2 - 4 are
640cA *    used. Each code to ignore must be preceded by a '.'.
640cA *    A string my look like the following:
640cA *
640cA *           .OPE.CLO.GET.VFY.VER.NXT.PRV.CHK
640cA *
640cA *    Note, the CHGDTAARA command defaults to only 32 characters
640cA *    for the entry field. Enter '&' and pressing Enter will
640cA *    extend it another 32 characters.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  File Specs
      *----------------------------------------------------------------

     Fdrifile   if   e           k disk
     Flogdri    o    e           k disk

      *----------------------------------------------------------------
      *  Variables
      *----------------------------------------------------------------

     D curdate         s              8  0
     D curtime         s              6  0
     D debugmode       s               n
500 AD debugrectype    s              1
640cAD debug3String    s            100
     D error           s               n
     D lasttime        s              6  0 inz(999999)
     D logtype         s              1
     D nextseq#        s              7  0
     D pgm2call        s                   like(dripg1)
640cAD xFound          s              3  0

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

416aA *----------------------------------------------------------------
416aA *  Program info data structure
416aA *----------------------------------------------------------------
416aA
416aAD                sds
416aAD  #prog            *proc
416aAD  #job                 244    253
416aAD  #user                254    263
416aAD  #jobn                264    269
416aAD  #jobdt               276    281  0
416aAD  #jobtm               282    287  0

     C     *entry        plist
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm                    $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C                   parm                    $dridata
416eAC                   parm                    $dridata2
710aAC                   parm                    $dridata3

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------

      * What should we do ...

     C                   select

      *   Open this program and return.

     C                   when      $dricommand = '*OPEN'
     C                   eval      logtype = 'I'
     C                   exsr      writelog

      *   Close the program and return.

     C                   when      $dricommand = '*CLOSE'
     C                   eval      logtype = 'I'
     C                   exsr      writelog
     C                   eval      *inlr = *on

      *   Call program associated with command.

     C                   other
     C                   exsr      $ValidCmd
     C                   eval      logtype = 'I'
     C                   exsr      writelog
     C                   if        not Error
     C                   exsr      $CallPgm
     C                   eval      logtype = 'O'
     C                   exsr      writelog
     C                   endif

     C                   endsl


      * Return to calling program.

     C                   Return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * See if we are in debugging mode.

     C     *dtaara       define    dridebug      debugmode
     C                   in        debugmode
500 A
500 A* Get record type to write out.
500 A
500 AC     *dtaara       define    dridebug2     debugrectype
500 AC                   in        debugrectype

500 AC                   if        debugrectype <> 'B'
500 AC                             and debugrectype <> 'I'
500 AC                             and debugrectype <> 'O'
500 AC                   eval      debugrectype = 'B'
500 AC                   endif
640cA
640cA* Get subcommand to not write to log.
640cA
640cAC     *dtaara       define    dridebug3     debug3String
640cAC                   in        debug3String

     C                   endsr

      *===============================================================
      *  $ValidCmd   Validate Command
      *===============================================================

     C     $ValidCmd     begsr
     C                   eval      Error = *off
600aA
600aA *  If first character of $dricommand is not '*' and not ' ',
600aA *    Then assume the actual program name to call was sent in.
600aA
600aAC                   if        %subst($dricommand:1:1) <> '*'
600aAC                             and %subst($dricommand:1:1) <> ' '
600aAC                   eval      pgm2call = $dricommand
600aAC                   leavesr
600aAC                   endif

      *  Get command record from file.

     C     $dricommand   chain     drifile
     C                   if        not %found
     C                   eval      Error = *on
     C                   eval      $drireturn = '*INVLDCMD'
     C                   goto      #validsubcmd
     C                   endif

      *  Get program to call.

     C                   select
     C                   when      $drisys2upd = 'D'
     C                   eval      pgm2call = dripg1
     C                   when      $drisys2upd = 'H'
     C                   eval      pgm2call = dripg2
     C                   other
     C                   eval      pgm2call = ' '
     C                   endsl

      *  See if there is a program defined.

     C                   if        pgm2call = ' '
     C                   eval      Error = *on
     C                   eval      $drireturn = '*NOPROGRAM'
     C                   endif

     C     #ValidSubCmd  endsr

      *===============================================================
      *  $CallPgm    Call Program
      *===============================================================

     C     $CallPgm      begsr

416eAC                   select
416eA
416eAC                   when      %parms <= 7
     C                   call(e)   pgm2call
     C                   parm                    $drisubcmd
     C                   parm                    $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C                   parm                    $dridata

416eAC                   when      %parms <= 8
416eAC                   call(e)   pgm2call
416eAC                   parm                    $drisubcmd
416eAC                   parm                    $driprogram
416eAC                   parm                    $drireturn
416eAC                   parm                    $drimessage
416eAC                   parm                    $dridata
416eAC                   parm                    $dridata2
416eA
710aAC                   when      %parms <= 9
710aAC                   call(e)   pgm2call
710aAC                   parm                    $drisubcmd
710aAC                   parm                    $driprogram
710aAC                   parm                    $drireturn
710aAC                   parm                    $drimessage
710aAC                   parm                    $dridata
710aAC                   parm                    $dridata2
710aAC                   parm                    $dridata3
710aA
416eAC                   endsl

     C                   if        %error
     C                   eval      $drireturn = '*CALLPGM'
416aAC                   eval      $drimessage = 'Error occured on call to '
416aAC                                         + %trim(pgm2call)
416aAC                                         + ' from ' + #prog
     C                   endif

     C     #CallPgm      endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  writelog    Write record to log file
     *----------------------------------------------------------------

     C     writelog      begsr

     * Only write a log record if in debug mode.

     C                   if        not debugmode
500 AC                             or  debugrectype='I' and logtype<>'I'
500 AC                             or  debugrectype='O' and logtype<>'O'
     C                   goto      endwritelog
     C                   endif
640cA
640cA* Do not write out specific codes                        .
640cA
640cAC                   eval      xFound = %scan('.'+%subst($drisubcmd:2:3):
640cAC                                            debug3String)
640cAC                   if        xFound > 0
640cAC                   goto      endwritelog
640cAC                   endif
640cDC**
640cDC**Only write open/close records when recording both types.
640cDC**
640cDC**                 if        debugrectype <> 'B'
640cDC**                 if        $drisubcmd = '%OPEN'
640cDC**                           or  $drisubcmd = '*OPEN'
640cDC**                           or  $drisubcmd = '%CLOSE'
640cDC**                           or  $drisubcmd = '*CLOSE'
640cDC**                 goto      endwritelog
640cDC**                 endif
640cDC**                 endif
640cDC**
640cDC**Only write 'get' output records that have errors.
640cDC**  Note, since license history is new, we will continue to write
640cDC**        all of its 'get' records.
640cDC**
640cDC**                 if        debugrectype = 'O'
640cDC**                 if        %subst($drisubcmd:2:3) = 'GET'
640cDC**                           and $drireturn = '*OK'
640cDC**                           and $dricommand <> '*LICHIST'
640cDC**                 goto      endwritelog
640cDC**                 endif
640cDC**                 endif

     * Initialize log fields.

     C     *dtaara       define    logdri#       nextseq#
640aDC**** *lock         in        nextseq#
640aMC     *lock         in(e)     nextseq#
640aAC                   if        %error
640bAC                   unlock    nextseq#
640aAC                   leavesr
640aAC                   endif
     C                   eval      lgdriseq# = nextseq#
     C                   if        nextseq# = 9999999
     C                   eval      nextseq# = 1
     C                   else
     C                   eval      nextseq# = nextseq# + 1
     C                   endif
     C                   out       nextseq#
640bAC                   unlock    nextseq#

     C                   exsr      getdatetime

     C                   eval      lgdritype = logtype
     C                   eval      lgdridate = curdate
     C                   eval      lgdritime = curtime
     C                   eval      lgdridpgm = pgm2call
     C                   eval      lgdricmd  = $dricommand
416dAC                   eval      lgdriscmd = ' '
416dAC                   eval      lgdris2u  = ' '
416dAC                   eval      lgdripgm  = ' '
416dAC                   eval      lgdrirtn  = ' '
416dAC                   eval      lgdrimsg  = ' '
416dAC                   eval      lgdridata = ' '
416dAC                   if        %parms >= 2
     C                   eval      lgdriscmd = $drisubcmd
416dAC                   endif
416dAC                   if        %parms >= 3
     C                   eval      lgdris2u  = $drisys2upd
416dAC                   endif
416dAC                   if        %parms >= 4
     C                   eval      lgdripgm  = $driprogram
416dAC                   endif
416dAC                   if        %parms >= 5
     C                   eval      lgdrirtn  = $drireturn
416dAC                   endif
416dAC                   if        %parms >= 6
     C                   eval      lgdrimsg  = $drimessage
416dAC                   endif
416dAC                   if        %parms >= 7
     C                   eval      lgdridata = $dridata
416dAC                   endif
     C                   eval      lgdrilpgm = #prog
     C                   eval      lgdrijob  = #job
     C                   eval      lgdriuser = #user
     C                   eval      lgdrinbr  = #jobn

     * Write log record.

     C                   write(e)  lgdrirec
     C                   if        %error
     C                   endif
416eA
416eA* Write second log record if second data field was sent.
416eA
416eAC                   if        %parms >= 8
416eAC                   eval      lgdridata = $dridata2
416eAC                   write(e)  lgdrirec
416eAC                   if        %error
416eAC                   endif
416eAC                   endif

710aA
710aA* Write third log record if second data field was sent.
710aA
710aAC                   if        %parms >= 9
710aAC                   eval      lgdridata = $dridata3
710aAC                   write(e)  lgdrirec
710aAC                   if        %error
710aAC                   endif
710aAC                   endif

     C     endwritelog   endsr
