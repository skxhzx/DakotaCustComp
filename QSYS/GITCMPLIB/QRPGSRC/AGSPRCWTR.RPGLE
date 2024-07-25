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
     *  AGSPRCWTR  End/Start Remote Writers
     *  10 October 2012
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    10/10/12  MLB  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fagswtr    if   e           k disk    infds(infds) rename(agswtr:ags)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D cmdstring       s             50    dim(6) ctdata perrcd(1)
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
     C                   read      agswtr
     *
     C                   if        %eof(agswtr)
     C                   leave
     C                   endif
     *
     *         Send user interactive session
     *
     C                   exsr      zzendwtr
     C                   eval      seconds = 10
     C                   callp     sleep(seconds)
     C**                 exsr      zzclroutq
     C**                 eval      seconds = 10
     C**                 callp     sleep(seconds)
     C                   exsr      zzstrrmtwtr
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
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
