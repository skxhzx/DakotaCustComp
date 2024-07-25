     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSGC020  Q&D SGC Fix ITEMFLD file.
     *  23 August 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    08/23/17  MLB  7.10
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

     Fitemfld   uf   e           k disk
     Fpiritem   if   e           k disk

     C     itkey         klist
     C                   kfld                    ifwhse
     C                   kfld                    ifitem
     C
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C                   read      itemfld
     C                   if        %eof(itemfld)
     C                   leave
     C                   endif
     C
     C     itkey         chain     piritem
     C                   if        not %found(piritem)
     C                   delete    ifrec
     C                   endif
     C*
     C                   enddo
     C
     C                   eval      *inlr = '1'
