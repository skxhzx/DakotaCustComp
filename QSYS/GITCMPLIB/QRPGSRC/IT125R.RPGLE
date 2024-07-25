500aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  IT125R    Item description lookup
     *  04 April, 2018
     *  Tom Forrest
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    04/04/18  TDF
     *      - Date Created.
     *
     *----------------------------------------------------------------     ****
     Fpiritem   if   e           k disk
     Fit125fm   cf   e             workstn
     F                                     sfile(scwin2s:rrn)
     *---------------------------------------------------------------------
     D nm              s              1    dim(35)
     D nx              s              1    dim(35)
     D rrn             s              5  0
     D maxx            s              5  0
     D xx              s              2  0
     D item15          s             15
     D count           s              2  0
     D topi            s             15
     D boti            s             15
     D blk             s              2  0
     D iors            s              1
     D sr1             s              1
     D sr2             s              2
     D sr3             s              3
     D sr4             s              4
     D sr5             s              5
     D sr6             s              6
     D sr7             s              7
     D sr8             s              8
     D sr9             s              9
     D sr10            s             10
     D sr11            s             11
     D sr12            s             12
     D sr13            s             13
     D sr14            s             14
     D sr15            s             15
     D sr16            s             16
     D sr17            s             17
     D sr18            s             18
     D sr19            s             19
     D sr20            s             20
     D sr21            s             21
     D sr22            s             22
     D sr23            s             23
     D sr24            s             24
     D sr25            s             25
     D sr26            s             26
     D sr27            s             27
     D sr28            s             28
     D sr29            s             29
     D sr30            s             30
     *---------------------------------------------------------------------
     C     *entry        plist
     C                   parm                    pitem            15
     C                   parm                    pfrom             1
     C                   parm                    search           30
     C                   parm                    pwhse             3
     C                   move      pwhse         pwhsen            3 0
     *---------------------------------------------------------------------
     c                   eval      pfrom = 'X'
     C     top           tag
     C                   exsr      load
     C     top1          tag
     C                   eval      *in(10) = *on
     C                   eval      *in(11) = *on
     C                   eval      *in(12) = *off
     C                   eval      *in(13) = *on
     c                   if        rrn = 0
     C                   eval      *in(10) = *off
     c                   endif
     c                   eval      scitem = *blanks
     c     pfrom         ifeq      ' '
     c                   exfmt     scwin2c
     c                   else
     c                   write     scwin2c
     c                   endif
     *--- PAGEDOWN ---
     c                   if        *in21
     c                   exsr      pgdown
     c                   goto      top1
     c                   endif
     *--- PAGEUP -----
     c                   if        *in22
     c                   exsr      pgUP
     c                   goto      top1
     c                   endif

AG01 *--- Position to item
AG01 C     scitem        cabne     *blanks       top

     *--- F3=SIGN OFF
     C     *inkc         cabeq     *on           fin
     *--- F12=EXIT
     C     *inkL         cabeq     *on           fin
     *--- F5=Scan
     c     *inke         ifeq      *on
     c     pfrom         orne      ' '
     c                   eval      pfrom = ' '
     c                   if        search <> *blanks
     c                              and *inke = *off
     c                   goto      can
     c                   endif
     c                   exfmt     scwin1
     C     *inkc         cabeq     *on           can
     C     *inkl         cabeq     *on           can
     c                   goto      top
     c     can           tag
     c                   goto      top1
     c                   endif
     *----------------------------------------------------------------
     c                   readc     scwin2s                                71
     c     *in71         doweq     *off
     c     option        ifeq      '1'
     c                   move      sitem         pitem
     c                   goto      fin
     c                   endif
     c                   readc     scwin2s                                71
     c                   enddo
     *----------------------------------------------------------------
     c                   goto      top
     C     fin           tag
     C                   move      *blanks       search
     C                   move      *on           *inlr
     *----------------------------------------------------------------
     * 'LOAD' LOADS SUBFILE
     *----------------------------------------------------------------
     Csr   load          begsr
AG01 C                   If        scitem = *blanks
     c     search        cabeq     svsrch        eload
     c     *like         define    search        svsrch
     c                   move      search        svsrch
AG01 C                   endif

     C                   eval      rrn = 0
     C                   eval      maxx = 0
     C                   eval      count = 0
     C                   eval      *in(10) = *off
     C                   eval      *in(11) = *off
     C                   eval      *in(12) = *on
     C                   eval      *in(13) = *off
     C                   write     scwin2c
     *----------------------------------------------------------------
     c     itkey         klist
     c                   kfld                    pwhsen
     c                   kfld                    ititem
     *----------------------------------------------------------------
     c                   MOVEL     scitem        ITITEM
     C     itkey         setll     itrec
     C                   read      itrec                                  01
     C     *in01         doweq     *off
     C     rrn           andlt     11
      *---
     C     search        ifne      *blanks
     C                   exsr      trim
     C     *in90         cabeq     *off          next
     C                   endif
     C                   eval      rrn = rrn + 1
     C                   eval      sitem = ititem
     C                   eval      sdesc = itdesc
     C                   eval      option = ' '
     C                   write     scwin2s
     C                   if        rrn = 1
     C                   eval      topi = sitem
     c                   endif
     c     next          tag
     C                   read      itrec                                  01
     c                   enddo
     C                   eval      boti = sitem
     C                   eval      maxx= rrn
     *----------------------------------------------------------------
     Csr   eload         endsr
     *----------------------------------------------------------------
     * 'PGDOWN' page down
     *----------------------------------------------------------------
     Csr   pgdown        begsr
      *---
     C     maxx          cablt     11            epgd
      *---
     C                   eval      rrn = 0
     C                   eval      maxx= 0
     C                   eval      count = 0
     C                   eval      *in(10) = *off
     C                   eval      *in(11) = *off
     C                   eval      *in(12) = *on
     C                   eval      *in(13) = *off
     C                   write     scwin2c
     *----------------------------------------------------------------
     c                   eval      scitem = boti
     c                   movel     scitem        ititem
     C     itkey         setll     itrec
     C                   read      itrec                                  01
     C                   read      itrec                                  01
     C     *in01         doweq     *off
     C     rrn           andlt     11
      *---
     C     search        ifne      *blanks
     C                   exsr      trim
      *---
     C     *in90         cabeq     *off          next2
     C                   endif
     C                   eval      rrn = rrn + 1
     C                   eval      sitem = ititem
     C                   eval      sdesc = itdesc
     C                   eval      option = ' '
     C                   write     scwin2s
     C                   if        rrn = 1
     C                   eval      topi = sitem
     c                   endif
     c     next2         tag
     C                   read      itrec                                  01
     c                   enddo
     C                   eval      boti = sitem
     C                   eval      maxx= rrn
     *----------------------------------------------------------------
     Csr   epgd          endsr
     *----------------------------------------------------------------
     * 'PGup' page up
     *----------------------------------------------------------------
     Csr   pgup          begsr
     C                   eval      rrn = 0
     C                   eval      maxx= 0
     C                   eval      count = 0
     C                   eval      *in(10) = *off
     C                   eval      *in(11) = *off
     C                   eval      *in(12) = *on
     C                   eval      *in(13) = *off
     C                   write     scwin2c
     *----------------------------------------------------------------
     c                   eval      ititem = topi
     C     itkey         setll     itrec
     C                   readp     itrec                                  01
     c     count         dowlt     11
     c     *in01         andeq     *off
      *---
     C     search        ifne      *blanks
     C                   exsr      trim
     C     *in90         cabeq     *off          next4
     C                   endif
     c                   eval      count = count + 1
     c     next4         tag
     C                   readp     itrec                                  01
     c                   enddo
      *---------------------------------------------------------------------
     c                   eval      item15 = ititem
      *---------------------------------------------------------------------
     c                   if        *in01
     c                   eval      item15 = *blanks
     c                   endif
      *---------------------------------------------------------------------
     c                   eval      ititem = item15
     C     itkey         setll     itrec
     C                   read      itrec                                  01
     C     *in01         doweq     *off
     C     rrn           andlt     11
      *---
     C     search        ifne      *blanks
     C                   exsr      trim
     C     *in90         cabeq     *off          next3
     C                   endif
     C                   eval      rrn = rrn + 1
     C                   eval      sitem = ititem
     C                   eval      sdesc = itdesc
     C                   eval      option = ' '
     C                   write     scwin2s
     C                   if        rrn = 1
     C                   eval      topi = sitem
     c                   endif
     c     next3         tag
     C                   read      itrec                                  01
     c                   enddo
     C                   eval      boti = sitem
     C                   eval      maxx= rrn
     *----------------------------------------------------------------
     Csr                 endsr
     *----------------------------------------------------------------
     * 'TRIM' puts the search word into the correct size field
     *----------------------------------------------------------------
     Csr   trim          begsr
     C                   MOVEA     search        NM
      *---
     c                   eval      xx = 35
     c     xx            dowgt     0
     c     nm(xx)        ifne      ' '
     c                   eval      blk = xx
     c                   eval      xx = 1
     c                   endif
     c                   eval      xx = xx - 1
     c                   enddo
      *---
     c                   if        blk <= 1
     c                   movel     search        sr1
     C     sr1           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 2
     c                   movel     search        sr2
     C     sr2           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 3
     c                   movel     search        sr3
     C     sr3           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 4
     c                   movel     search        sr4
     C     sr4           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 5
     c                   movel     search        sr5
     C     sr5           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 6
     c                   movel     search        sr6
     C     sr6           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 7
     c                   movel     search        sr7
     C     sr7           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 8
     c                   movel     search        sr8
     C     sr8           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 9
     c                   movel     search        sr9
     C     sr9           scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 10
     c                   movel     search        sr10
     C     sr10          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 11
     c                   movel     search        sr11
     C     sr11          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 12
     c                   movel     search        sr12
     C     sr12          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 13
     c                   movel     search        sr13
     C     sr13          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 14
     c                   movel     search        sr14
     C     sr14          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 15
     c                   movel     search        sr15
     C     sr15          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 16
     c                   movel     search        sr16
     C     sr16          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 17
     c                   movel     search        sr17
     C     sr17          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 18
     c                   movel     search        sr18
     C     sr18          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 19
     c                   movel     search        sr19
     C     sr19          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 20
     c                   movel     search        sr20
     C     sr20          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 21
     c                   movel     search        sr21
     C     sr21          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 22
     c                   movel     search        sr22
     C     sr22          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 23
     c                   movel     search        sr23
     C     sr23          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 24
     c                   movel     search        sr24
     C     sr24          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 25
     c                   movel     search        sr25
     C     sr25          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 26
     c                   movel     search        sr26
     C     sr26          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 27
     c                   movel     search        sr27
     C     sr27          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 28
     c                   movel     search        sr28
     C     sr28          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 29
     c                   movel     search        sr29
     C     sr29          scan      itdesc                                 90
     c                   endif
      *---
     c                   if        blk = 30
     c                   movel     search        sr30
     C     sr30          scan      itdesc                                 90
     c                   endif
      *---
     Csr   etrim         endsr
