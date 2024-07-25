      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  FIXSOS     Fix SOS wihout WORKSOS records
     *  05 July 2011
     *  Dave Sommerville / Max Blacknik
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslot1     if   e           k disk
     Fliclog5   if   e           k disk
     Flabel     if   e           k disk
     Fpltsum15  if   e           k disk
     Fworksos   o  a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  forever        s               n
     D  found          s               n

     D                sds
     D  #user                254    263

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pwhdp            5

     C                   move      $pwhs         $pwhse            3 0
      /free
        *inlr = *on;

        if        $pwhdp = '*ALL';
           setll ($pwhse) slot1;
        Else;
          setll ($pwhse: $pwhdp: 'USR') slot1;
        Endif;

        dow forever = forever;

        if        $pwhdp = '*ALL';
          reade ($pwhse) slot1;
        Else;
          reade ($pwhse: $pwhdp: 'USR') slot1;
        Endif;

          if %eof(slot1);
            leave;
          endif;

       If slaisl = 'USR';
          exsr getLicLog;
          if not found;
            iter;
          endif;

          exsr getLabel;
          if not found;
            iter;
          endif;

          exsr getPltSum;
          if not found;
            iter;
          endif;

          exsr crtWorkSOS;
        Endif;

        enddo;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  crtWorkSOS   Create WORKSOS record
     *----------------------------------------------------------------

      /free
       begsr crtWorkSOS;

        wkswhs = lbwhse;
        wksusr = #user;
        wkslbl = lblbl#;
        wkstyp = 'P';
        wkstrn = lbtrn#;
        wkswhd = slwhdp;
        wksasl = slaisl;
        wksloc = slloc;
        wkslvl = slrlvl;
        wkshnd = slhand;
        wksdsp = sldisp;
        wkspck = lbqpck;
        wkspli = pspal#;

        write wksrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getLabel    Get LABEL record for LICLOG record
     *----------------------------------------------------------------

      /free
       begsr getLabel;

        found = *off;

        chain (lllbl#) label;

        if not %found(label);
          leavesr;
        endif;

        if lbitem <> llitem;
          leavesr;
        endif;

        if lbtrn# <> lltrn#;
          leavesr;
        endif;

        if lbutyp='N' and llaqty1 <> slstk1
           or lbutyp='1' and llaqty2 <> slstk2
           or lbutyp='2' and llaqty3 <> slstk3;
             leavesr;
        endif;

        found = *on;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getPltSum    Get PLTSUM15 record for WORKSOS record
     *----------------------------------------------------------------

      /free
       begsr getPltSum;

        found = *off;

        chain (lbwhse: lbrte: lbpal#) pltsum15;

        if not %found(pltsum15);
          leavesr;
        endif;

        if lbtrn# <> pstrn#;
          leavesr;
        endif;

        found = *on;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getLicLog   Get LICLOG record for slot
     *----------------------------------------------------------------

      /free
       begsr getLicLog;

        found = *off;

        setgt (slwhse: slwhdp: sldisp) liclog5;

        dow forever = forever;

          readpe (slwhse: slwhdp: sldisp) liclog5;

          if %eof(liclog5);
            leavesr;
          endif;

          if llitem <> slitem;
            leavesr;
          endif;

          if llaqty1 <> slstk1
             or llaqty2 <> slstk2
             or llaqty3 <> slstk3;
            leavesr;
          endif;

          found = *on;
          leave;

        enddo;

       endsr;
      /end-free

