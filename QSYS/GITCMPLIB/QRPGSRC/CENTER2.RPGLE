     *----------------------------------------------------------------
     *
     *  CENTER2   Center a string.
     *  27 February 2012
     *  Jeffrey Jahnke - copy of program center
     *
     *  Revisions
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D $pstr           s              1    dim(15)
     D cstr            s              1    dim(15)
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     D bp              s                   like($plen)
     D ep              s                   like($plen)
     D lftovr          s                   like($plen)
     D maxlen          s                   like($plen)
     D strlen          s                   like($plen)
     D x               s                   like($plen)
     *  Parameters
     *
     *    Input Parameters
     *      $PSTR   String to center.
     *      $PLEN   Length of centered output string.
     *
     *    Returned Parameters
     *      $PSTR   Centered string.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pstr
     C                   parm                    $plen             3 0
     *----------------------------------------------------------------
     * Main line
     *
     * Define variables and constants
     *
     C                   eval      maxlen = 15
     *
     *
     * Find beginning position of string.
     *
     C                   eval      x = 1
     C                   dow       x <= maxlen  and
     C                             $pstr(x) = *blank
     C                   add       1             x
     C                   enddo
     C     x             cabgt     maxlen        bottom
     C                   eval      bp = x
     *
     * Find end position of string.
     *
     C                   eval      x = maxlen
     C                   dow       x > 0  and
     C                             $pstr(x) = *blank
     C                   eval      x = x - 1
     C                   enddo
     C                   eval      ep = x
     *
     * Calculate string length.
     *
     C                   eval      strlen = ep - bp
     C                   add       1             strlen
     *
     * Center string within length specified.
     *
     C                   eval      cstr = *blanks
     C                   if        strlen >= $plen
     C                   movea     $pstr(bp)     cstr(1)
     C                   else
     C                   eval      lftovr = $plen - strlen
     C     lftovr        div       2             x
     C                   add       1             x
     C                   movea     $pstr(bp)     cstr(x)
     C                   endif
     C                   movea     cstr          $pstr
     C     bottom        tag
     C                   return
