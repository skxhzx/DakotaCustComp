510 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNPT755   Clean up ORPHANS for PT755
     *             orphaned from the label file
     *  18 December 2012
     *  Lynn McMahon
     *
     fpirtran5  uf   e           k disk
     flicense1  uf   e           k disk
     flicinfo2  uf   e           k disk
     fpomfr     uf   e           k disk
     flabel90   if   e           k disk    rename(lbrec:lb)
     flabel     if   e           k disk
     fclnoldpf1 o  a e             disk    rename(clnoldpf:cln)

      /copy qcopysrc,p.cvtdte

     d ymd             s              6  0
     d clnwhse         s              3  0
     d clndate         s              8  0
     D forever         s              1
     d licinfocnt      s              9  0
     d licensecnt      s              9  0
     d pirtrancnt      s              9  0
     d pomfrcnt        s              9  0
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76


     c     *entry        plist
     c                   parm                    $pwhse            3
     c                   parm                    $pupdate          1

     c                   call      'CMPDTE'
     C                   parm      '*CSTRTN'     $pcmd             8
     C                   parm      'CLNPT755'    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8


      /free
        $cvcmd = '*CMDYMD ';
        $cvd8i = $pdate;
        cvtdte ($cvtdt);
        clndate = %int($pdate);
        clnwhse = %int($pwhse);
        // pirtran records customer returns orphaned from the label
        setll (clnwhse: *loval) pirtran5;
        dow not %eof(pirtran5);
          reade (clnwhse) pirtran5;
          if %eof(pirtran5);
            leave;
          endif;
          // past the purge date - get out of here
          if ptgdte > clndate;
            leave;
          endif;
          // only looking for returns
          if ptgrp1 <> 'R';
            iter;
          endif;
          // if the label record exist leave this transaction alone.
          chain (clnwhse: pttrn#) label90;
          if %found(label90);
            iter;
          endif;

              // we only get here if the label record is already gone

              // get license record
              chain (ptwhse: pttrn#) license1;
              if %found(license1);
                // check to make sure this isn't a new license record based
                chain (liwhse: lilcns) licinfo2;
                if %found(licinfo2);
                  // make sure the record is old
                  ymd = %dec(%date(LNADDTS):*ymd);
                  if ymd > $cvd6o;
                    iter;
                  else;
                    if $pupdate = 'Y';
                      delete lnrec;
                    endif;
                  endif;
                  licinfocnt = licinfocnt + 1;
                endif;
                if $pupdate = 'Y';
                  delete lirec;
                endif;
                licensecnt = licensecnt + 1;
              endif;
              if $pupdate = 'Y';
                delete ptrec;
              endif;
              pirtrancnt = pirtrancnt + 1;
        enddo;

        // now lets see if we have orphans in the following files
        //POMFR
        setll (clnwhse) pomfr;
        dow forever = forever;
          reade (clnwhse) pomfr;
          if %eof(pomfr);
            leave;
          endif;
          if pmpo = ' ' and pmseq = 0 or
             pmpo = '*NOSTOCK' and pmseq = 0;
            // if the label record is gone, this record needs to be removed
            chain (pmlbl#) label;
            if %found(label);
            else;
              if $pupdate = 'Y';
                delete pmrec;
              endif;
              eval pomfrcnt = pomfrcnt + 1;
            endif;
          endif;
        enddo;

        *inlr = *on;
        clnoldpf = 'CLNPT755 ' + 'Pirtran Count' + ' ' + %char(pirtrancnt);
        write cln;
        clnoldpf = 'CLNPT755 ' + 'Licinfo Count' + ' ' + %char(licinfocnt);
        write cln;
        clnoldpf = 'CLNPT755 ' + 'License Count' + ' ' + %char(licensecnt);
        write cln;
        clnoldpf = 'CLNPT755 ' + 'Pomfr Count' + ' ' + %char(pomfrcnt);
        write cln;
      /end-free
