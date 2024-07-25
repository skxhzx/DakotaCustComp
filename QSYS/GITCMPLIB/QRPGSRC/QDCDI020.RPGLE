      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *   Date: March 20, 2013 / MLB
     *   Pgm: QDCDI020 - Delete BATCTL *REPLEN rcds w/o matching LABEL3 rcd.
     *
     *----------------------------------------------------------------
     Fbatctl3   uf   e           k disk
     Flabel3    if   e           k disk
     *
     *
     C     *like         define    btwhse        kywhse
     C     *like         define    bttype        kytype
     *
     *       batctl3 file key.
     C     btkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kytype
     *
     *       Label3 file key.
     C     lbkey         klist
     C                   kfld                    btbat#
     C                   kfld                    btwhse
     C                   eval      kywhse = 002
     C                   move      '1'           forever           1
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *
     C                   eval      kytype = '*REPLEN'
     C     btkey         setll     batctl3
     C                   dow       forever = forever
     C
     C     btkey         reade     batctl3
     C                   if        %eof(batctl3)
     C                   leave
     C                   endif
     *
     *           Check for level 2 slot.
     C     lbkey         setll     label3
     C                   if        not %equal(label3)
     C                   delete    btrec
     C                   endif
     *
     C                   enddo
     *
     C                   eval      *inlr = '1'
     *
     ***********************************************************
