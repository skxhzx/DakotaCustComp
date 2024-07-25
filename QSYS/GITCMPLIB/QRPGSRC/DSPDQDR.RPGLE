     H DFTACTGRP(*NO) ACTGRP(*CALLER) EXPROPTS(*RESDECPOS)
     H DATFMT(*ISO)   TIMFMT(*ISO)    OPTION(*NODEBUGIO)
      *----------------------------------------------------------------
      * DSPDQDR - Display data queue description
      * Copyright (C) 10/08/1992  Craig Rutledge   <craig_rutledge@mohawkind.com>
      * This program is free software, you can redistribute it and/or modify it under the terms
      * of the GNU General Public License as published by the Free Software Foundation.
      *----------------------------------------------------------------
      * Program Summary:
      * Call API to retrieve data queue description
      * Extract entries and load to screen
      *----------------------------------------------------------------
      * API (application program interfaces) used:
      * QMHQRDQD  display data queue object description
      *----------------------------------------------------------------
     Fdspdqdd   cf   e             workstn infds(dsinf)
     D dsinf           ds
     D  fkey                          1    overlay(dsinf:369)
     D  f03            c                   const(X'33')
      *
     D ExitPgmFlg      s              1    inz(*off)
     D qrcvar          ds                  inz
     D  qMsgLength                   10i 0 overlay(qrcvar:9)
     D  qKeyLength                   10i 0 overlay(qrcvar:13)
     D  qSequence                     1    overlay(qrcvar:17)
     D  qSenderid                     1    overlay(qrcvar:18)
     D  vtext                              overlay(qrcvar:20)
     D  ddm_local                          overlay(qrcvar:70)
     D  qEntInQueue                  10i 0 overlay(qrcvar:73)
     D  qMaxOvrFlow                  10i 0 overlay(qrcvar:77)
     D  vqname                             overlay(qrcvar:81)
     D  vqlib                              overlay(qrcvar:91)
      *
      * Error return code parm for APIs.
     D vApiErrDs       ds
     D  abytpv                       10i 0 inz(%size(vApiErrDs))                bytes provided
     D  abytav                       10i 0 inz(0)                               bytes returned
     D  amsgid                        7                                         error msgid
     D  aresvd                        1                                         reserved
     D  aexdta                       50                                         replacement data
      *
      *    -------------------------------------------------------------
      * Create Prototypes for calls
     D qmhqrdqd        PR                  ExtPgm('QMHQRDQD')                   data q description
     Db                                    like(qrcvar)                         RECIEVER
     D                               10i 0 const                                LENGTH
     D                                8    const                                FORMAT
     Dd                              20                                         Q NAME & LIB
      *    -------------------------------------------------------------
     D qmhsndpm        PR                  ExtPgm('QMHSNDPM')                   SEND MESSAGES
     D                                7    const                                ID
     D                               20    const                                FILE
     D                               65    const                                TEXT
     D                               10i 0 const                                LENGTH
     D                               10    const                                TYPE
     D                               10    const                                QUEUE
     D                               10i 0 const                                STACK ENTRY
     D                                4    const                                KEY
     Db                                    like(vApiErrDS)
      *    -------------------------------------------------------------
     D main            PR                  extpgm('DSPDQDR ')                   Input Parms
     D  i_qnamlib                    20A                                        NAME LIB 20
     D  i_qobjtyp                    10A                                        OBJECT TYPE
      *    -------------------------------------------------------------
     D main            PI
     D  i_qnamlib                    20A
     D  i_qobjtyp                    10A                                        OBJECT TYPE
      *
      *---------------------------------------------------------------------------------------------
 1B  C                   dou       ExitPgmFlg=*on
      *
     C                   callp     QMHQRDQD(
     C                             qrcvar:                                      DATA STRUCT
     C                             %size(qrcvar):                               SIZE
     C                             'RDQD0100':                                  TYPE FORMAT
     C                             i_qnamlib)                                   NAME LIB
     C                   eval      qlen = qMsgLength
     C                   eval      qnenty = qEntInQueue
     C                   eval      qmaxen = qMaxOvrFlow
      *
     C                   eval      *in50=*off
 2B  C                   select
 2X  C                   when      qSequence='F'
     C                   eval      qSeque='*FIFO'
 2X  C                   when      qSequence='L'
     C                   eval      qSeque='*LIFO'
 2X  C                   when      qSequence='K'
     C                   eval      qSeque='*KEYED'
     C                   eval      *in50=*on
     C                   eval      qkey=qKeyLength
 2E  C                   endsl
      *
     C                   eval      qsndrn = '*NO '
 2B  C                   if        qSenderid = 'Y'
     C                   eval      qsndrn = '*YES'
 2E  C                   endif
      *
     C                   exfmt     screen
     C                   eval      ExitPgmFlg= (fkey=f03)                       F3 pressed
 1E  C                   enddo
      * Send completion message
     C                   callp     QMHSNDPM(
     C                             '       ':'                    ':
     C                             'Display data queue description for ' +
     C                             %trimr(%subst(i_qnamlib:11:10)) + '/' +
     C                             %trimr(%subst(i_qnamlib:1:10)) +
     C                             ' - completed':
     C                             65:'*INFO  ':'*CTLBDY ': 1:'    ':
     C                             vApiErrDS)
     C                   eval      *inlr = *on                                  PROGRAM END
     C                   return
