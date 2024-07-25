      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTCHGDRIV  -  Test CHGDRIVER
     *  05 December 2017
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
710aA*    12/05/17  RBD  7.10a
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pMessage        s             99
     D pSessid         s             40
     D pUser           s             10
     D pDict           s             10
     D pPgm            s             10
     D pWhse           s              3p 0 inz(900)
     D pRtid           s              5    inz('00076')
     D pRte            s              5    inz('RTE01')
     D pDriver         s             10    inz('EARNHARDT ')

     C                   call      'CHGDRIVER'
     C                   parm                    pMessage
     c                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pRte
     C                   parm                    pDriver

     c                   eval      *inlr = *on
