     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1969
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDGLP030  Create Duplicate Rcds in ITEMSLS from 2nd Oldest
     *  02 October 2013
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  10/02/13  MLB  6.50
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Notes: This program was created to create duplicate ITEMSLS
     *         records using the 2nd oldest week on file. Records will
     *         be added to the ITEMSLS file to pad up to 12 weekly records.
     *         Then the weekly pgm will be run to recompute the item avg's.
     *
     *----------------------------------------------------------------

     fpiritem   if   e           k disk
     fitemsls1  if a e           k disk
     *
     D  DURDAT         S               D   DATFMT(*ISO)
     *
     C     keyih         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     C     keyih_chk     klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     C                   kfld                    ckdate
     C                   move      '1'           forever           1
     *
     *-------------------------------------------------------
     C                   dow       forever = forever
     C                   read      piritem
     C                   if        %eof(piritem)
     C                   leave
     C                   endif
     *
     *-------------------------------------------------------
     C                   move      *zeros        weekrcdcnt        5 0
     C                   move      *zeros        wkstoadd          5 0
     C                   move      *zeros        day               5 0
     C                   move      *zeros        ckdate            8 0
     C     keyih         setll     itemsls1
     C                   dow       forever = forever
     C     keyih         reade     itemsls1
     C                   if        %eof(itemsls1)
     C                             or weekrcdcnt >= 12
     C                   leave
     C                   endif
     *      Count nbr of weekly sales rcds on file.
     C                   eval      weekrcdcnt = weekrcdcnt + 1
     C                   enddo
     *-------------------------------------------------------
     *
     C                   if            weekrcdcnt >= 1
     C                             and weekrcdcnt <= 12
     C                   eval      wkstoadd = 13 - weekrcdcnt
     *
     C                   select
     *----------------------------
     C                   when      weekrcdcnt = 1
     C                   eval      day = 7
     C     keyih         setgt     itemsls1
     C     keyih         readpe    itemsls1
     *          Start at current week and build up to 12 wks.
     C                   eval      ihstrd = 20130929
     C     1             do        wkstoadd
     C                   exsr      calcwkdate
     C                   exsr      existrcdck
     C     *iso          move      durdat        ihstrd
     C                   write     ihrec
     C                   enddo     1
     C
     *
     *----------------------------
     C                   when      weekrcdcnt > 1
     *
     C                   eval      day = 7
     C     keyih         setgt     itemsls1
     C     keyih         readpe    itemsls1
     C     keyih         readpe    itemsls1
     C                   if        not %eof(itemsls1)
     *          Start at current week and build up to 12 wks.
     C                   eval      ihstrd = 20130929
     C     1             do        wkstoadd
     C                   exsr      calcwkdate
     C                   exsr      existrcdck
     C     *iso          move      durdat        ihstrd
     C                   write     ihrec
     C                   eval      day = 7
     C                   enddo     1
     C                   endif
     *
     C                   endsl                                                  Endsl - rcdcnt = 1
     *
     C                   endif                                                  Endif - weekrcdcnt
     *
     C                   enddo
     *
     C                   eval      *inlr = '1'
     *-------------------------------------------------------
     *
     C     calcwkdate    begsr
     *
     C     *iso          move      ihstrd        durdat
     C     durdat        subdur    day:*days     durdat
     *
     C                   endsr
     *-------------------------------------------------------
     *
     C     existrcdck    begsr
     *
     C     *iso          move      durdat        ckdate
     C     keyih_chk     setll     itemsls1
     C                   if        %equal(itemsls1)
     C                   dou       not %equal(itemsls1)
     C                   exsr      calcwkdate
     C     *iso          move      durdat        ckdate
     C     keyih_chk     setll     itemsls1
     C                   if        %equal(itemsls1)
     C                   eval      ihstrd = ckdate
     C                   endif
     C                   enddo
     *
     C                   endif
     *
     C                   endsr
