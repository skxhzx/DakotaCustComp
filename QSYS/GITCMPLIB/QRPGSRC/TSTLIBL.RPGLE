      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTLIBL     Test setting libl
     *  23 January 2009
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dspMsg          s             52
     D pJobd           s             10
     D pMessage        S             60
     D pReturn         S             10
     D pUser           S             10

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     D  #curruser            358    367

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  First set library list based on a jobd.

     c                   call      'SETJDLIBL'
     c                   parm      'DEMO600'     pJobd
     c                   parm      ' '           pReturn
     c                   parm      ' '           pMessage

     c                   if        pReturn <> '*OK'

     c                   eval      dspMsg = pMessage
     c     dspMsg        dsply

     c                   else

     c                   eval      qcmd = 'DSPLIBL OUTPUT(*PRINT)'
     c                   call      'QCMDEXC'                            78
     c                   parm                    qcmd             80
     c                   parm      22            qlen             15 5

     c                   endif

     *  Now set the library list back to the current user libl.

     c                   call      'SETUSRLIBL'
     c                   parm      #curruser     pUser
     c                   parm      ' '           pReturn
     c                   parm      ' '           pMessage

     c                   if        pReturn <> '*OK'

     c                   eval      dspMsg = pMessage
     c     dspMsg        dsply

     c                   else

     c                   eval      qcmd = 'DSPLIBL OUTPUT(*PRINT)'
     c                   call      'QCMDEXC'                            78
     c                   parm                    qcmd             80
     c                   parm      22            qlen             15 5

     c                   endif

     *  Bye, Bye

     C                   eval      *inlr = *on
