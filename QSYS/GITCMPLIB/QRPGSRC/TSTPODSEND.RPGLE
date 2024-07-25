      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  TSTPODSEND   Test PODSEND
     *  02 September 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pCmd            s              8
     D pPgm            s             10
     D pWhse           s              3  0
     D pRtid           s              5
     D pRte            s              5
     D pStop           s              2  0
     D pOrd            s              7  0
     D pCord           s              7  0
     D pFileSend       s             30
     D pFileRecv       s             30
     D pFileTry        s             33
     D pReturn         s             10
     D pMsg            s             60

     *----------------------------------------------------------------
     *  Mainline
     *----------------------------------------------------------------

     C                   eval      pcmd = '*RESEND'
     C                   eval      pPgm = 'TSTPODSEND'
     C                   eval      pWhse = 900
     C                   eval      pRtid = '00001'
     C                   eval      pRte  = 'RTE1'
     C                   eval      pStop = 1
     C                   eval      pOrd = 3232386
     C                   eval      pCord = 123
     C                   eval      pFileSend = 'poddave.xml'
     C                   eval      pFileRecv = 'poddavertn.xml'
     C                   eval      pFileTry  = ''

     C                   call      'PODSEND'
     C                   parm                    pcmd
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pRte
     C                   parm                    pStop
     C                   parm                    pOrd
     C                   parm                    pCord
     C                   parm                    pFileSend
     C                   parm                    pFileRecv
     C                   parm                    pFileTry
     C                   parm      ' '           pReturn
     C                   parm      ' '           pMsg

     C                   eval      *inlr = *on
