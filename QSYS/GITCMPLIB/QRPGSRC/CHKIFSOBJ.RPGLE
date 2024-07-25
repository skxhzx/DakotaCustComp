     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     *----------------------------------------------------------------
     *  Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHKIFSOBJ    Check for IFS Object
     *  11 October 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    10/11/06  MLB  5.10
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h

     D Path            S            640A
     D Authority       S             10A
     D AMode           S             10I 0

     ** Warning:  call this program from the command.  If you call
     **       it directly, because "Path" is larger than 32 bytes.
     **       See http://faq.midrange.com/data/cache/70.html
     **

     C     *entry        plist
     c                   parm                    Path
     c                   parm                    Authority

     C* First, just check if the file exists:
     c                   if        Access(%trimr(Path): F_OK) < 0
     c                   callp     EscErrno(errno)
     c                   endif

     C* Next, check if the current user has authority:
     c                   if        Authority <> '*NONE'

     c                   eval      amode = 0

     c                   if        %scan('R':Authority) > 0
     c                   eval      amode = amode + R_OK
     c                   endif
     c                   if        %scan('W':Authority) > 0
     c                   eval      amode = amode + W_OK
     c                   endif
     c                   if        %scan('X':Authority) > 0
     c                   eval      amode = amode + X_OK
     c                   endif

     c                   if        access(%trimr(Path): amode) < 0
     c                   callp     EscErrno(errno)
     c                   endif

     c                   endif

     c                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     C                   endsr

      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
