     H DFTACTGRP(*NO) ACTGRP(*CALLER) EXPROPTS(*RESDECPOS)
     H DATFMT(*ISO)   TIMFMT(*ISO)    OPTION(*NODEBUGIO)
      *----------------------------------------------------------------
      * OBJCHKRV- Validity checking program
      * Copyright (C) 04/13/1986  Craig Rutledge   <craig_rutledge@mohawkind.com
      * This program is free software, you can redistribute it and/or modify it
      * of the GNU General Public License as published by the Free Software Foun
      * 09/07/2001 - converted from CL to use APIs
      *----------------------------------------------------------------
      * program summary:
      * execute api to retrieve object description.
      * if error returned by api,
      *    retrieve message with replacement values
      *    send message back to command.
      *----------------------------------------------------------------
      * api (application program interfaces) used:
      * qusrobjd  get object description
      * qmhrtvm   retrieve messages
      * qmhsndpm  send messages
      *----------------------------------------------------------------
     D mMsgRtv         ds                  inz
     D mMsgRtvLen              9     12i 0
     D mMsgMessage            25    256
     D mMsgLen         s             10i 0 inz(%len(mMsgRtv))
     D qm_msgid        s              7
     D qm_msgtxt       s            128
     D qm_msgtyp       s             10
     D alpha8          s              8
      *
      *--------------------------------------------------------------------
      * create parm prototypes
      *--------------------------------------------------------------------
     D qusrobjd        PR                  ExtPgm('QUSROBJD')
     Db                               8
     D                               10i 0 const
     D                                8    const
     D                               20    const
     D                               10    const
     Db                                    like(vApiErrDS)
      *    -------------------------------------------------------------
     D qmhrtvm         PR                  ExtPgm('QMHRTVM')
     D                              256
     D                               10i 0
     D                                8    const
     D                                7
     D                               20    const
     D                              128
     D                               10i 0 const
     D                               10    const
     D                               10    const
     Db                                    like(vApiErrDs)
      *
      *--------------------------------------------------------------------
     D qmhsndpm        PR                  ExtPgm('QMHSNDPM')
     D                                7
     D                               20    const
     Db                                    like(qm_msgtxt)
     D                               10i 0 const
     D                               10    const
     D                               10    const
     D                               10i 0 const
     D                                4    const
     Db                                    like(vApiErrDS)
      *    -------------------------------------------------------------
      * Error return code parm for APIs.
     D vApiErrDs       ds
     D  vbytpv                       10i 0 inz(%size(vApiErrDs))
     D  vbytav                       10i 0 inz(0)
     D  vmsgid                        7a
     D  vresvd                        1a
     D  vrpldta                     128a
      *    -------------------------------------------------------------
     D  main           PR                  extpgm('OBJCHKRV ')
     D  i_obj_lib                    20A   const
     D  i_otyp                       10A   const
      *    -------------------------------------------------------------
     D  main           PI
     D  i_obj_olib                   20A   const
     D  i_otyp                       10A   const
      *
      *-------------------------------------------------------------------------
      * check to see if object exists.
     C                   callp     QUSROBJD(
     C                             alpha8:
     C                             8:
     C                             'OBJD0100':
     C                             i_obj_olib:
     C                             i_otyp:
     C                             vapierrds)
 1B  C                   if        vbytav>0
      *
      * call retrieve message API to pull in the subsitution variables
     C                   callp     QMHRTVM(
     C                             mMsgRtv :
     C                             mMsgLen :
     C                             'RTVM0100':
     C                             vmsgid:
     C                             'QCPFMSG   *LIBL':
     C                             vrpldta:
     C                             %size(vrpldta):
     C                             '*YES      ':
     C                             '*NO       ':
     C                             vApiErrDs)
      *
      * set values to send messages, make message size not too big
 2B  C                   if        mMsgRtvLen > %size(mMsgMessage)
     C                   eval      mMsgRtvLen = %size(mMsgMessage)
 2E  C                   endif
     C                   eval      QM_msgtxt =
     C                             '0000 ' + %trimr(vmsgid) +': ' +
     C                                       %subst(mMsgMessage:1:mMsgRtvLen)
     C                   eval      QM_msgid = 'CPD0006'
     C                   eval      QM_msgtyp = '*DIAG'
     C                   exsr      srSndErrMsg
      *
     C                   eval      qm_msgtxt  = *blanks
     C                   eval      qm_msgid   = 'CPF0002'
     C                   eval      qm_msgtyp  = '*ESCAPE'
     C                   exsr      srSndErrMsg
 1E  C                   endif
     C                   eval      *inlr=*on
     C                   return
      *
      * call send program message api
     C     srSndErrMsg   begsr
     C                   callp     qmHSNDPM(
     C                             qm_msgid:
     C                             'QCPFMSG   *LIBL     ':
     C                             qm_msgtxt:
     C                             %size(qm_msgtxt):
     C                             qm_msgtyp:
     C                             '*CTLBDY':
     C                             1:
     C                             '    ':
     C                             vApiErrDS)
     C                   endsr
