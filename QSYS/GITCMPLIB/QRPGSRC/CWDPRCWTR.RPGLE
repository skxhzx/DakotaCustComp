     H option(*NODEBUGIO)
510aAH dftactgrp(*NO)
510aAH actgrp(*CALLER)
510aAH bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CWDPRCWTR  End/Start Remote Writers
     *  20 September 2013
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    09/20/13  MLB  6.50
     *      - Created.
650aA*    10/22/13  MLB  6.50a
     *      - Enh: Revised pgm to only stop/start Zebra label printers
     *        for Kearney whse. Printers starting with KER or KY and
     *        printer type of *IBM4212.
650bA*    10/22/13  MLB  6.50b
     *      - Enh: Added client custom code support to pgm.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fcwdwtr    if   e           k disk    infds(infds) rename(cwdwtr:cwd)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D cmdstring       s             50    dim(6) ctdata perrcd(1)
650bA*
650bA*----------------------------------------------------------------
650bA*  Customer id
650bA*
650bAD @getcl          c                   const('GETCLIENT')
650bA*
650aA /COPY QCOPYSRC,ID#cashwa
     *
     *----------------------------------------------------------------
     *  Other working variables.
     *
     D qlen            s             15  5
     D qcmd            s            200
     D forever         s              1    inz('1')
     D Warn1           c                   const('ATTENTION ALL USERS!!!!! The -
     D                                     System will be going down in 15 Minu-
     D                                     tes for Night Processing.')
     D seconds         s             10U 0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D sleep           PR            10U 0 extproc('sleep')
     D   seconds                     10U 0 value

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *     $RTN     -  Status code
     *                 *OK    - Valid userid
     *                 *ERROR - Invalid userid
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz2
     *
     C                   dow       forever = forever
     C                   read      cwdwtr
     *
     C                   if        %eof(cwdwtr)
     C                   leave
     C                   endif
     *
     *         Send user interactive session
     *
650aAC                   select
650aAC                   when      client = Cashwa
650aAC                             and clientloc = 'KEARNEY'
650aAC                             and (%subst(outq:1:3) = 'KER'
650aAC                               or %subst(outq:1:2) = 'KY')
650aAC                             and wscst = '*IBM4212'
650aA*
650aA*       Only end/start Kearney Zebra label printers.
650aA*
     C                   exsr      zzendwtr
     C                   eval      seconds = 10
     C                   callp     sleep(seconds)
     C**                 exsr      zzclroutq
     C**                 eval      seconds = 10
     C**                 callp     sleep(seconds)
     C                   exsr      zzstrrmtwtr
650aAC                   endsl
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
650bA*
650bA* Get client id.
650bA*
650bAC                   call      @getcl
650bAC                   parm                    client           10
650bAC                   parm                    clientloc        10
650bA*
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZENDWTR
     *
     C     zzendwtr      begsr
     *
     *    ENDWTR  WTR(writer) OPTION(*immed)
     *
     C                   eval      qcmd = %trim(cmdstring(1)) +
     C                                    %trim(OUTQ) +
     C                                    %trim(cmdstring(2))
     *
     C                   call (e)  'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      200           qlen
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCLROUTQ
     *
     C     zzclroutq     begsr
     *
     *    CLROUTQ  OUTQ(writer)
     *
     C                   eval      qcmd = %trim(cmdstring(3)) +
     C                                    %trim(OUTQ) +
     C                                    %trim(cmdstring(4))
     *
     C                   call (e)  'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      200           qlen
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSTRRMTWTR
     *
     C     zzstrrmtwtr   begsr
     *
     *    STRRMTWTR  OUTQ(writer)
     *
     C                   eval      qcmd = %trim(cmdstring(5)) +
     C                                    %trim(OUTQ) +
     C                                    %trim(cmdstring(6))
     *
     C                   call (e)  'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      200           qlen
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
** End/Start remote writers
ENDWTR WTR(
) OPTION(*IMMED)
CLROUTQ OUTQ(
)
STRRMTWTR  OUTQ(
)
