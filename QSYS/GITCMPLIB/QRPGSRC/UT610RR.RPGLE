      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UT610RR   Move PO from history back to open
     *  05 October 2015
     *  Rod Roller
     *
     *  10/05/15  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpohhdr    uf   e           k disk
     Fpohdr     uf a e           k disk
     Fpohdtl    uf   e           k disk
     Fpodtl     uf a e           k disk
     Fporcv     uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     D forever         s              1
     D pwhs            s              3p 0

     *----------------------------------------------------------------
     *  Program info data structure
      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Let the show begin .....
     C     *entry        plist
     C                   parm                    $pwhsea           3
     C                   parm                    $ppo              9
     *----------------------------------------------------------------
     *  Main line

      /free
        monitor;
          pwhs = %dec($pwhsea:3:0);
         on-error;
          pwhs = 0;
        endmon;

        // get header record
        chain (pwhs: $ppo) phhrec;
        if %found(pohhdr);

          // get detail records
          setll (pwhs: $ppo) phdrec;
          dou forever<>forever;
            reade (pwhs: $ppo) phdrec;
            if %eof(pohdtl);
              leave;
            endif;
            exsr addpd;
            delete phdrec;
          enddo;

          // get receiving records
          setll (pwhs: $ppo) porrec;
          dou forever<>forever;
            reade (pwhs: $ppo) porrec;
            if %eof(porcv);
              leave;
            endif;
            poredt = 0;
            poreti = 0;
            update porrec;
          enddo;

          exsr addph;
          delete phhrec;
        endif;    // found pohhdr

        *inlr = *on;
      /end-free

     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forever = *on
     C                   endsr

     *----------------------------------------------------------------
     *  Add back to detail
     *----------------------------------------------------------------
      /free
        begsr addpd;

          PDWHSE = PHDWHS;
          PDPO   = PHDPO;
          PDSEQ  = PHDSEQ;
          PDITEM = PHDITM;
          PDVITM = PHDVIT;
          PDSPCL = PHDSPC;
          PDQOR1 = PHDQO1;
          PDQOR2 = PHDQO2;
          PDQOR3 = PHDQO3;
          PDQRC1 = PHDQR1;
          PDQRC2 = PHDQR2;
          PDQRC3 = PHDQR3;
          PDDWGT = PHDWGT;
          write pdrec;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  Add back to header
     *----------------------------------------------------------------
      /free
        begsr addph;

          PHWHSE = PHHWHS;
          PHPO   = PHHPO ;
          PHVEN  = PHHVEN;
          PHVNAM = PHHVNA;
          PHVAD1 = PHHVA1;
          PHVAD2 = PHHVA2;
          PHVCTY = PHHVCT;
          PHVST  = PHHVST;
          PHVZP1 = PHHVZP;
          PHDATE = PHHDTE;
          PHTIME = PHHTIM;
          PHAMPM = PHHAMP;
          PHUDTE = PHHUDT;
          PHUTIM = PHHUTI;
          PHSTAT = '3';
          write phrec;

        endsr;
      /end-free

