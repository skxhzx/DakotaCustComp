417sA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  BFCREVFIND
     *  15 February 2013
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
650 A*    02/15/13  LMC  6.50
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fqrpgsrc   if   e           k disk    rename(qrpgsrc:rpg)
     Fbfcrev    if a e           k disk
RNZaA*----------------------------------------------------------------
RNZaA*  Variables
RNZaA*
RNZaAD EndofMods       C                   const('--------------------')
     D Forever         s              1
RNZaAD FoundMod        s               n
RNZaAD ModMark         s              4
     D $rev            s              3
     D $mbr            s             10
     D $mbrtype        s             10
     D $mbrdesc        s             50
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $rev
     c                   parm                    $mbr
     c                   parm                    $mbrtype
     c                   parm                    $mbrdesc
      /free
        dow Forever = Forever;
          read qrpgsrc;
          if %eof(qrpgsrc);
            leave;
          endif;

          if %subst(srcdta:6:1) = 'H';
            iter;
          endif;

          if %subst(srcdta:7:1) = '/';
            iter;
          endif;

          // if at least one mod mark has been found check for end of mods
          if FoundMod = *on;
            if %subst(srcdta:15:20) = endofmods;
              leave;
            endif;
          endif;
          select;
            when %subst(srcdta:1:4) <> ' ' and FoundMod = *off;
              // looking for revisions for current level of software
              if %subst(srcdta:1:3) = $rev;
                ModMark = srcdta;
                FoundMod = *on;

                // does this revisions already exist in the file
                chain ($mbr: $mbrtype: ModMark: srcseq) bfcrev;
                if %found(bfcrev);
                else;
                  object = $mbr;
                  objdesc = $mbrdesc;
                  objtype = $mbrtype;
                  modid = modmark;
                  modidseq = srcseq;
                  modtext = srcdta;
                  write bfcrec;
                endif;
              endif;
            when %subst(srcdta:1:4) <> ' ' and %subst(srcdta:1:4) <> ModMark;
              // looking for revisions for current level of software
              if %subst(srcdta:1:3) = $rev;
                // new mod
                //ModMark = %subst(srcdta:1:4) <> ' ';
                ModMark = srcdta;
                // does this revisions already exist in the file
                chain ($mbr: $mbrtype: ModMark: srcseq) bfcrev;
                if %found(bfcrev);
                else;
                  object = $mbr;
                  objdesc = $mbrdesc;
                  objtype = $mbrtype;
                  modid = modmark;
                  modidseq = srcseq;
                  modtext = srcdta;
                  write bfcrec;
                endif;
              endif;
            other;
              // load additional comment lines for the mod
              if FoundMod = *on;
                //chain ($mbr: $mbrtype: ModMark) bfcrev;
                chain ($mbr: $mbrtype: ModMark: srcseq) bfcrev;
                if %found(bfcrev);
                else;
                  object = $mbr;
                  objdesc = $mbrdesc;
                  objtype = $mbrtype;
                  modid = modmark;
                  modidseq = srcseq;
                  modtext = srcdta;
                  write bfcrec;
                endif;
              endif;
          endsl;
        enddo;
        *inlr = *on;
      /end-free
