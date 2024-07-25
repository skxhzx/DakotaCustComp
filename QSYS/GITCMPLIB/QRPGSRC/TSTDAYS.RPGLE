510cA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTDAYS     Test day calculation
     *  24 January 2008
     *  Dave Sommerville
     *----------------------------------------------------------------
414 A
520 AD laststamp       s               z   inz(z'2008-01-22-24.00.00')
520 AD currentstamp    s               z   inz(z'2008-01-23-01.00.00')
520 AD samedaystamp    s               z   inz(z'2008-01-23-02.00.00')
520 AD d               s              5  0

520 AC                   if        %diff(currentstamp : laststamp : *Days)
520 AC                             >= 1
520 AC     'Days>=1'     dsply
520 AC                   endif

520 AC                   if        %date(currentstamp) <> %date(laststamp)
520 AC     'Cur<>Last'   dsply
520 AC                   endif

520 AC                   if        %date(currentstamp) <> %date(samedaystamp)
520 AC     'Cur<>Same'   dsply
520 AC                   endif

     C                   eval      *inlr=*on
