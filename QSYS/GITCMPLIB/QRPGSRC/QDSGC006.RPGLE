     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSGC006  Q&D SGC Fix LBLOC, LBRVL from SLOT2 file.
     *  07 February 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    02/07/11  MLB  6.40
     *      - Created
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     FRTEHED2   if   e           k disk
     FSLOT2     if   e           k disk
     Flabel94   uf   e           k disk

     C     rhkey         klist
     C                   kfld                    kywhse            3 0
     C                   kfld                    kystat            1
     C                   kfld                    kytype            1
     C
     C     lbkey         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     C
     C     slkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdisp
     C
     C*    Process Printed Regular Routes.
     C                   z-add     001           kywhse
     C                   move      '4'           kystat
     C                   move      ' '           kytype
     C
     C                   move      '1'           forever           1
     C*
     C     rhkey         setll     rtehed2
     C                   dow       forever = forever
     C     rhkey         reade     rtehed2
     C                   if        %eof(rtehed2)
     C                   leave
     C                   endif
     C*
     C*
     C     lbkey         setll     label94
     C                   dow       forever = forever
     C     lbkey         reade     label94
     C                   if        %eof(label94)
     C                   leave
     C                   endif
     C*
     C*      Update only FRZ labels for type O(rder) and B(ulk).
     C                   if        lbwhdp = 'FRZ'
     C                             and (lbtype = 'B' or
     C                                  lbtype = 'O')
     C*
     C     slkey         chain     slot2
     C                   if        %found(slot2)
     C                   eval      lbloc = slloc
     C*
     C                   eval      lbrlvl = slrlvl
     C*
     C                   update    lbrec
     C                   endif
     C*
     C                   endif
     C*
     C                   enddo
     C
     C                   enddo
     C
     C*    Process Printed Will Call Routes.
     C                   z-add     001           kywhse
     C                   move      '4'           kystat
     C                   move      'W'           kytype
     C
     C                   move      '1'           forever           1
     C*
     C     rhkey         setll     rtehed2
     C                   dow       forever = forever
     C     rhkey         reade     rtehed2
     C                   if        %eof(rtehed2)
     C                   leave
     C                   endif
     C*
     C*
     C     lbkey         setll     label94
     C                   dow       forever = forever
     C     lbkey         reade     label94
     C                   if        %eof(label94)
     C                   leave
     C                   endif
     C*
     C*      Update only FRZ labels for type O(rder) and B(ulk).
     C                   if        lbwhdp = 'FRZ'
     C                             and (lbtype = 'B' or
     C                                  lbtype = 'O')
     C*
     C     slkey         chain     slot2
     C                   if        %found(slot2)
     C                   eval      lbloc = slloc
     C*
     C                   eval      lbrlvl = slrlvl
     C*
     C                   update    lbrec
     C                   endif
     C*
     C                   endif
     C*
     C                   enddo
     C
     C                   enddo
     C
     C                   eval      *inlr = '1'
