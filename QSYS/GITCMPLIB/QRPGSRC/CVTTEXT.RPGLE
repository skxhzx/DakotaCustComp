      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CVTTEXT     Translate special characters into XML values.
     *              Used pgm VOXLATE as basis for this pgm.
     *
     *  19 Aug 2008
     *  Retha Davis
     *
     *  Revisions
     *
520  *    08/19/08  RBD  5.20   P#00004
     *      - Created.
     *
750  *    06/09/21  KDE  7.50
     *      - Add specaial characters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *  XML Character Translation
     *     FROM:    TO:
     *
     *       <      &lt;
     *       >      &gt;
     *       &      &amp;
     *       '      &apos;
     *       "      &quot;
750 A*       \      &amp;#92;
750 A*       Tab    &amp;#09;
750 A*       newlin &amp;#10;
750 A*       return &amp#13;
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Input Parameters
     *----------------------------------------------------------------

     D $pcmd           s             10
     D $pin            s            500
     D $pout           s            500

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D  pos            s              5  0

     D   okchar        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ+
     D                                      abcdefghijklmnopqrstuvwxyz+
     D                                      0123456789+
     D                                      .%/- '

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     D   xspcl         C                   ',''"!()*/'
     D   xspace        C                   '        '

     D   xup2          C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ,''"!()*/'
     D   xlow2         C                   'abcdefghijklmnopqrstuvwxyz        '

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *UP2LOW    = Translate uppercase to lowercase
     *              *LOW2UP    = Translate lowercase to uppercase
     *              *SPCL2SPC  = Translate special characters to spaces
     *              *SPCL2LOW  = Translate special characters to spaces
     *                           and uppercase to lowercase
     *              *XML       = Translate special characters into
     *                           XML values.
     *      $PIN    Input string
     *
     *    Returned Parameters
     *      $POUT   Output string
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd
     C                   parm                    $pin
     C                   parm                    $pout

     *  Translate string

     C                   select

     C                   when      $pcmd = '*UP2LOW'
     C     xupper:xlower xlate(p)  $pin          $pout

     C                   when      $pcmd = '*LOW2UP'
     C     xlower:xupper xlate(p)  $pin          $pout

     C                   when      $pcmd = '*SPCL2SPC'
     C                   eval      $pout = $pin
     C                   exsr      spcl2spc

     C                   when      $pcmd = '*SPCL2LOW'
     C     xupper:xlower xlate(p)  $pin          $pout
     C                   exsr      spcl2spc

     C                   when      $pcmd = '*XML     '
     C                   eval      $pout = $pin
     C                   exsr      xml

     C                   endsl

     C                   return

     *----------------------------------------------------------------
     *  spcl2spc  Remove unallowed characters.
     *----------------------------------------------------------------

     C     spcl2spc      begsr

     C                   eval      pos = 0

     C                   dou       pos = 0
     C                   eval      pos = %check(okchar:$pout:pos+1)
     C                   if        pos > 0
     C                   eval      %subst($pout:pos:1) = ' '
     C                   endif
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  XML       Translate special chars into XML values.
     *----------------------------------------------------------------

     C     xml           begsr

750 AC                   eval      pos = 0
750 AC                   dou       pos = 0
750 AC                   eval      pos = %scan('\':$pout)
750 AC                   if        pos > 0
750 AC                   eval      $pout = %replace(' ':$pout:pos:1)
750 AC                   endif
750 AC                   enddo
750 A
750 AC*  tab
750 AC                   eval      pos = 0
750 AC                   dou       pos = 0
750 AC                   eval      pos = %scan(x'05':$pout)
750 AC                   if        pos > 0
750 AC                   eval      $pout = %replace(' ':$pout:pos:1)
750 AC                   endif
750 AC                   enddo
750 A
750 AC*  new line
750 AC                   eval      pos = 0
750 AC                   dou       pos = 0
750 AC                   eval      pos = %scan(x'25':$pout)
750 AC                   if        pos > 0
750 AC                   eval      $pout = %replace(' ':$pout:pos:1)
750 AC                   endif
750 AC                   enddo
750 A
750 AC*  return
750 AC                   eval      pos = 0
750 AC                   dou       pos = 0
750 AC                   eval      pos = %scan(x'0D':$pout)
750 AC                   if        pos > 0
750 AC                   eval      $pout = %replace(' ':$pout:pos:1)
750 AC                   endif
750 AC                   enddo

     C                   eval      pos = 0
     C                   dou       pos = 0
     C                   eval      pos = %scan('<':$pout)
     C                   if        pos > 0
     C                   eval      $pout = %replace('&lt;':$pout:pos:1)
     C                   endif
     C                   enddo

     C                   eval      pos = 0
     C                   dou       pos = 0
     C                   eval      pos = %scan('>':$pout)
     C                   if        pos > 0
     C                   eval      $pout = %replace('&gt;':$pout:pos:1)
     C                   endif
     C                   enddo

     *  When scanning for and replacing &, must begin scan which follows a
     *  match at the position FOLLOWING where the & was found.  Otherwise, if
     *  you start in the position where the & was last found and replaced,
     *  you'll be in an endless loop, because it will forever find the & in
     *  that same position.
     C                   eval      pos = 0
     C                   dou       pos = 0
     C                   eval      pos = %scan('&':$pout:(pos + 1))
     C                   if        pos > 0
     C                   eval      $pout = %replace('&amp;':$pout:pos:1)
     C                   endif
     C                   enddo

     C                   eval      pos = 0
     C                   dou       pos = 0
     C                   eval      pos = %scan('''':$pout)
     C                   if        pos > 0
     C                   eval      $pout = %replace('&apos;':$pout:pos:1)
     C                   endif
     C                   enddo

     C                   eval      pos = 0
     C                   dou       pos = 0
     C                   eval      pos = %scan('"':$pout)
     C                   if        pos > 0
     C                   eval      $pout = %replace('&quot;':$pout:pos:1)
     C                   endif
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
