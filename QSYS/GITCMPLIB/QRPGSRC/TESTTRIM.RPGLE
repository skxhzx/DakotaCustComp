      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  GETDDOPTS - Get Drag Drop Options
     *  09 January 2009
     *  Chuck Manny
     *----------------------------------------------------------------

     d crlf            c                   Const(x'0D25')

     c                   if        '=' = %trim('=')
     c     'Equal'       dsply
     c                   endif
     c                   if        crlf = %trim(crlf)
     c     'crlf'        dsply
     c                   endIf

     c                   eval      *inlr = *on
