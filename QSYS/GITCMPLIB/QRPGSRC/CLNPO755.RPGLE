510 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNPO755   Clean up ORPHANS for po755
     *  17 December 2012
     *  Lynn McMahon
     *
     flabel10   uf   e           k disk
     fpirtran   uf   e           k disk
     flicense1  uf   e           k disk
     flicinfo2  uf   e           k disk
     fpohhdr    if   e           k disk
     fpohdr     if   e           k disk
     fpomfr     uf   e           k disk
     fporcv     uf   e           k disk
     flumper    uf   e           k disk
     fpohhaccp  uf   e           k disk
     fpohdtlm   uf   e           k disk
     fpohhdrm   uf   e           k disk
     flabel     if   e           k disk    prefix(vlbl_) rename(lbrec:lb)
     fclnoldpf1 o  a e             disk    rename(clnoldpf:cln)

      /copy qcopysrc,p.cvtdte

     d ymd             s              6  0
     d clnwhse         s              3  0
     d clndate         s              8  0
     D forever         s              1
     d licinfocnt      s              9  0
     d licensecnt      s              9  0
     d pirtrancnt      s              9  0
     d labelcnt        s              9  0
     d pomfrcnt        s              9  0
     d porcvcnt        s              9  0
     d lumpercnt       s              9  0
     d pohhaccpcnt     s              9  0
     d pohdtlmcnt      s              9  0
     d pohhdrmcnt      s              9  0
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
     c                   parm                    $pblankpo         9
     c                   parm                    $pupdate          1

     c                   call      'CMPDTE'
     C                   parm      '*PO'         $pcmd             8
     C                   parm      'CLNPO755'    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8


      /free
        $cvcmd = '*CMDYMD ';
        $cvd8i = $pdate;
        cvtdte ($cvtdt);
        clndate = %int($pdate);
        clnwhse = %int($pwhse);
        setgt (clnwhse: $pblankpo) label10;
        dow not %eof(label10);
          reade (clnwhse) label10;
          if %eof(label10);
            leave;
          endif;

          if lbpo = ' ';
            iter;
          endif;

          // returns
          if lbpo = '*NOSTOCK';
            iter;
          endif;

          if lbrdte > clndate;
            setgt (clnwhse: lbpo) label10;
            iter;
          endif;

          if lbgrp1 <> 'P';
            iter;
          endif;

          if lbtype <> 'P';
            iter;
          endif;

          // Now does the po exist in pohhdr
          chain (lbwhse: lbpo) pohhdr;
          if %found(pohhdr);
            setgt (clnwhse: lbpo) label10;
            iter;
          endif;

          // Now does the po exist in pohdr
          chain (lbwhse: lbpo) pohdr;
          if %found(pohdr);
            setgt (clnwhse: lbpo) label10;
            iter;
          endif;

          // get license record
          chain (lbwhse: lbtrn#) license1;
            if %found(license1);
              // get licinfo and delete
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
                  licinfocnt = licinfocnt + 1;
                endif;
              endif;
              if $pupdate = 'Y';
                delete lirec;
              endif;
              licensecnt = licensecnt + 1;
            endif;
            // if the licinfo record was found and the record was new we
            // would never get to this point.
            // now get and delete pirtran
            chain (lbtrn#) pirtran;
            if %found(pirtran);
              if $pupdate = 'Y';
                delete ptrec;
              endif;
              pirtrancnt = pirtrancnt + 1;
            endif;
            // last delete the label that started this whole cleanup
            if $pupdate = 'Y';
              delete lbrec;
            endif;
            labelcnt = labelcnt + 1;

        enddo;
        // now lets see if we have orphans in the following files
        //POMFR
        setll (clnwhse) pomfr;
        dow forever = forever;
          reade (clnwhse) pomfr;
          if %eof(pomfr);
            leave;
          endif;
          if pmpo <> ' ' and pmseq > 0;
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

        //PORCV
        setll (clnwhse) porcv;
        dow forever = forever;
          reade (clnwhse) porcv;
          if %eof(porcv);
            leave;
          endif;
          if porpo <> ' ';
            // if the PO header is gone, this record needs to be removed
            chain (porwhs: porpo) pohhdr;
            if %found(pohhdr);
              setgt (clnwhse: porpo) porcv;
              iter;
            endif;

            chain (porwhs: porpo) pohdr;
            if %found(pohdr);
              setgt (clnwhse: porpo) porcv;
              iter;
            endif;
            // not found in pohhdr or pohdr - orphan
            if $pupdate = 'Y';
              delete porrec;
            endif;
            eval porcvcnt = porcvcnt + 1;
          endif;
        enddo;

        //LUMPER
        setll (clnwhse) lumper;
        dow forever = forever;
          reade (clnwhse) lumper;
          if %eof(lumper);
            leave;
          endif;
          if lmpo  <> ' ';
            // if the PO header is gone, this record needs to be removed
            chain (lmwhse: lmpo) pohhdr;
            if %found(pohhdr);
              setgt (clnwhse: lmpo) lumper;
              iter;
            endif;

            chain (lmwhse: lmpo) pohdr;
            if %found(pohdr);
              setgt (clnwhse: lmpo) lumper;
              iter;
            endif;
            // not found in pohhdr or pohdr - orphan
            if $pupdate = 'Y';
              delete lmrec;
            endif;
            eval lumpercnt = lumpercnt + 1;
          endif;
        enddo;

        //pohhaccp
        setll (clnwhse) pohhaccp;
        dow forever = forever;
          reade (clnwhse) pohhaccp;
          if %eof(pohhaccp);
            leave;
          endif;
          if hahpo <> ' ';
            // if the PO header is gone, this record needs to be removed
            chain (hahwhse: hahpo) pohhdr;
            if %found(pohhdr);
              setgt (clnwhse: hahpo) pohhaccp;
              iter;
            endif;

            chain (hahwhse: hahpo) pohdr;
            if %found(pohdr);
              setgt (clnwhse: hahpo) pohhaccp;
              iter;
            endif;
            // not found in pohhdr or pohdr - orphan
            if $pupdate = 'Y';
              delete hahrec;
            endif;
            eval pohhaccpcnt = pohhaccpcnt + 1;
          endif;
        enddo;

        //pohdtlm
        setll (clnwhse) pohdtlm;
        dow forever = forever;
          reade (clnwhse) pohdtlm;
          if %eof(pohdtlm);
            leave;
          endif;
          if phdmpo <> ' ';
            // if the PO header is gone, this record needs to be removed
            chain (phdmwh: phdmpo) pohhdr;
            if %found(pohhdr);
              setgt (clnwhse: phdmpo) pohdtlm;
              iter;
            endif;

            chain (phdmwh: phdmpo) pohdr;
            if %found(pohdr);
              setgt (clnwhse: phdmpo) pohdtlm;
              iter;
            endif;
            // not found in pohhdr or pohdr - orphan
            if $pupdate = 'Y';
              delete phdmrc;
            endif;
            eval pohdtlmcnt = pohdtlmcnt + 1;
          endif;
        enddo;

        //pohhdrm
        setll (clnwhse) pohhdrm;
        dow forever = forever;
          reade (clnwhse) pohhdrm;
          if %eof(pohhdrm);
            leave;
          endif;
          if phhmpo <> ' ';
            // if the PO header is gone, this record needs to be removed
            chain (phhmwh: phhmpo) pohhdr;
            if %found(pohhdr);
              setgt (clnwhse: phhmpo) pohhdrm;
              iter;
            endif;

            chain (phhmwh: phhmpo) pohdr;
            if %found(pohdr);
              setgt (clnwhse: phhmpo) pohhdrm;
              iter;
            endif;
            // not found in pohhdr or pohdr - orphan
            if $pupdate = 'Y';
              delete phhmrc;
            endif;
            eval pohhdrmcnt = pohhdrmcnt + 1;
          endif;
        enddo;

        *inlr = *on;
        clnoldpf = 'CLNPO755 ' + 'Label Count' + ' ' + %char(labelcnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Pirtran Count' + ' ' + %char(pirtrancnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Licinfo Count' + ' ' + %char(licinfocnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'License Count' + ' ' + %char(licensecnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Pomfr Count' + ' ' + %char(pomfrcnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Porcv Count' + ' ' + %char(porcvcnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Lumper Count' + ' ' + %char(lumpercnt);
        write cln;
        clnoldpf = 'CLNPO755 ' +'Pohhaccp Count' + ' ' + %char(pohhaccpcnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Pohdtlm Count' + ' ' + %char(pohdtlmcnt);
        write cln;
        clnoldpf = 'CLNPO755 ' + 'Pohhdrm Count' + ' ' + %char(pohhdrmcnt);
        write cln;
      /end-free
