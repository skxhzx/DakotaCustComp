      /COPY *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *
     *  QDHAR010   Q&D to remove stranded records from TOTEHDR file.
     *  27 October 2010
     *  Max Blacknik
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Ftotehdr   uf   e           k disk
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhsea           3
     *
     *----------------------------------------------------------------
     *
     C     tohkey        klist
     C                   kfld                    tohwhs
     *
     C     rhkey         klist
     C                   kfld                    tohwhs
     C                   kfld                    tohrid

     C                   move      $pwhsea       tohwhs
     C                   move      *off          forever           1
     C     tohkey        setll     totehdr
     C                   dow       forever = forever
     C     tohkey        reade     totehdr
     C                   if        %eof(totehdr)
     C                   leave
     C                   endif

     C     rhkey         setll     rtehed
     C                   if        not %equal(rtehed)
     C                   delete    tohrec
     C                   endif
     C*
     C                   enddo

     C*
     C                   move      *on           *inlr
     C*
