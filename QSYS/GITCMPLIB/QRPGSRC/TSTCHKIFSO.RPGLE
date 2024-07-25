417cA /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *
     *  TSTCHKIFSO  Test CHKIFSOBJ
     *  31 August 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    08/31/08  DAS  5.20
     *      - Created
     *
     *----------------------------------------------------------------

     D $ppath          S            640A
     D $pauth          S             10A
     D filefound       S              4A   inz('*NO ')

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     *
     C                   eval      $ppath = '/harbor'
     C                   call (e)  'CHKIFSOBJ'
     C                   parm                    $ppath
     C                   parm      ' '           $pauth
     C                   if        %error
     C                   eval      filefound = '*NO '
     C                   else
     C                   eval      filefound = '*YES'
     C                   endif
     *
     C                   eval      $ppath = '/harbor/'
     C                   call (e)  'CHKIFSOBJ'
     C                   parm                    $ppath
     C                   parm      ' '           $pauth
     C                   if        %error
     C                   eval      filefound = '*NO '
     C                   else
     C                   eval      filefound = '*YES'
     C                   endif
     *
     C                   eval      $ppath = '/xyz'
     C                   call (e)  'CHKIFSOBJ'
     C                   parm                    $ppath
     C                   parm      ' '           $pauth
     C                   if        %error
     C                   eval      filefound = '*NO '
     C                   else
     C                   eval      filefound = '*YES'
     C                   endif

     C                   eval      *inlr = *on
