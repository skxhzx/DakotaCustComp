     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSGC002  Q&D SGC Fix ITEMDEF file.
     *  19 May 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/27/05  MLB  5.00
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

     Fitemdef   uf   e           k disk

     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      itemdef
     C                   if        %eof(itemdef)
     C                   leave
     C                   endif
     C
     C                   if        idsdef = ' '
     C                   eval      idsdef = 'XX'
     C                   update    idrec                                79
     C                   if        *in79 = '1'
     C                   delete    idrec
     C                   endif
     C*
     C                   endif
     C*
     C                   enddo
     C
     C                   eval      *inlr = '1'
