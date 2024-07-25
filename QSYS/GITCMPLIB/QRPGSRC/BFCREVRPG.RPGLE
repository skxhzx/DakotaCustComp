      /COPY *libl/qcopysrc,hspecs
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
650aA*    08/09/13  LMC  6.50a
     *      - Enh - Added source change date to bfcrev file.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fqrpgsrc   if   e           k disk    rename(qrpgsrc:rpg)
     Fbfcrev    if a e           k disk
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

650dA /copy qcopysrc,p.cvtdte
650dA*----------------------------------------------------------------
650dA*  CVTDTE constant and parameter data structure.
650dA*----------------------------------------------------------------

650dAD $cvtdt          ds
650dAD  $cvcmd                 1      8
650dAD  $cvprg                 9     18
650dAD  $cvd6i                19     24
650dAD  $cvd8i                25     32
650dAD  $cvd6o                33     38  0
650dAD  $cvd8o                39     46  0
650dAD  $cvsto                47     64
650dAD  $cvrtn                65     72
650dAD  $cverm                73    132
650dAD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Variables
     *
     D EndofMods       C                   const('--------------------')
     D Forever         s              1
     D FoundMod        s               n
     D ModMark         s              4
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
650dA   // get todays date
650dA      $cvcmd = '*CURCMD ';
650dA      cvtdte ($cvtdt);
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
                  moddate = $cvd8o;
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
                  moddate = $cvd8o;
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
                  moddate = $cvd8o;
                  write bfcrec;
                endif;
              endif;
          endsl;
        enddo;
        *inlr = *on;
      /end-free
