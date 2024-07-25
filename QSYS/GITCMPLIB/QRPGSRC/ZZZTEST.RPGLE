417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  ZZZTEST     Test program
     *  09 June 2010
     *  Dave Sommerville
     *----------------------------------------------------------------

     D  pmessage       s             80
     D  pSessId        s             40
     D  pfdate         s              8  0
     D  ptdate         s              8  0
     D  pshift         s              6
     D  pcrew          s              6
     D  pemp#          s              5  0

     c                   call      'WORKFILE'
     c                   parm      ' '           pmessage
     c                   parm      '123456'      pSessId
     c                   parm      20090311      pfdate
     c                   parm      20100101      ptdate
     c                   parm      ' '           pshift
     c                   parm      ' '           pcrew
     c                   parm      0             pemp#

     c                   eval      *inlr = *on
