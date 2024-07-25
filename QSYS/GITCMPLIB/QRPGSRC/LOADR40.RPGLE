730aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  LOADR40  Move Routes left out in LDRHDR to LDRHHDR.
     *
     *  April 16, 2008
     *  Jose Duque
     *
730aA*  NOTE: This program is called from LOADCCL as a job schedule
730aA*        entry once daily.  It moves unclosed loader routes from
730aA*        the live loader files to the history files.
     *
     *  Revisions
     *
730aA*    02/08/19  RBD  7.30a
     *      - Converted to ILE.
     *      - Added logic to carry over all loader header and detail
     *        fields to the history files.  Prior to this rev no detail
     *        recs were carried over to history and only partial header
     *        data was carried over for unclosed loader routes.
     *
740aA*    12/29/19  RBD  7.40a
     *      - Update any associated runner records that are at status 'S'
     *        to status 'C'.
     *
750aA*    03/02/21  RBD  7.50a
     *      - Loader routes are auto closed by this pgm and when all
     *        pallets aren't loaded ended and closed dates and times
     *        were left unpopulated going into the history files. And
     *        all routes auto closed had status set to '7'.  One or
     *        both of these factors was preventing the data making it
     *        into Cheney's payroll. We don't touch their payroll so
     *        we'll handle it by populating date/time fields with
     *        current date/time and by setting status to '4' instead
     *        of '7'. Am making this the standard as I see no reason
     *        not to.
     *
     *----------------------------------------------------------------
      *  File Specs
     *
     FLdrhdr    if   e           k disk
     *
     FLdrhhdr   uf a e           k disk
730aAFLdrdetl   if   e           k disk
730aAFLdrhdetl  uf a e           k disk
740aAFrunner6   uf   e           k disk
740aAFLabel13   if   e           k disk
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *----------------------------------------------------------------
730aA*  Variables
     *----------------------------------------------------------------

730aAD forever         s               n
     *----------------------------------------------------------------
     *
     C     hhdrky        klist
     C                   kfld                    lhwhse
     C                   kfld                    lhrte
     C                   kfld                    lhrtid
     *
     *----------------------------------------------------------------
     C                   read      ldrhdr                                 lr
     *
     C                   dow       not *inlr
     C     hhdrky        chain     ldrhhdr                            79
     *
     C                   if        *in79
     C                   clear                   lhhrec
     C                   eval      lhhwhs = lhwhse
     C                   eval      lhhrte = lhrte
     C                   eval      lhhrti = lhrtid
     C                   time                    lhhstt
     C                   eval      lhhsta = '7'
     *
     * Get current date in century format
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      lhhstd = $cvd8o
730aAC                   eval      lhhtrl = lhtrlr
730aAC                   eval      lhhemp = lhemp#
730aAC                   eval      lhhend = lhendd
730aAC                   eval      lhhent = lhendt
730aAC                   eval      lhhcld = lhclsd
730aAC                   eval      lhhclt = lhclst
730aAC                   eval      lhhsup = lhsup#
730aAC                   eval      lhhdor = lhdor#
     *
750aA /free

750aA     if lhhend = 0;
750aA       lhhend = %dec(%char(%date():*iso0):8:0);
750aA       lhhent = %dec(%time(): *iso);
750aA     endif;

750aA     if lhhcld = 0;
750aA       lhhcld = %dec(%char(%date():*iso0):8:0);
750aA       lhhclt = %dec(%time(): *iso);
750aA     endif;

750aA /end-free
     *
     C                   write     lhhrec

730aAC                   exsr      zzhist

     C                   endif
     *
     C                   read      ldrhdr                                 lr
     C                   enddo
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZHIST   Update loader detail history file
730aA*
730aA*----------------------------------------------------------------
730aAC     zzhist        begsr
     *
     *
     C     hhdrky        setll     lddrec
     C                   dow       forever = forever
     C     hhdrky        reade     lddrec
     C                   if        %eof
     C                   leave
     C                   endif
     *
     C                   eval      ldhwhs = ldwhse
     C                   eval      ldhrte = ldrte
     C                   eval      ldhpli = ldplid
     C                   eval      ldhtrk = ldtrkz
     C                   eval      ldhrti = ldrtid
     C                   eval      ldhlds = ldldsq
     C                   eval      ldhcub = ldcube
     C                   eval      ldhpcs = ldpcs
     C                   eval      ldhst1 = ldstp1
     C                   eval      ldhst2 = ldstp2
     C                   eval      ldhemp = ldemp#
     C                   eval      ldhstd = ldstrd
     C                   eval      ldhstt = ldstrt
     C                   eval      ldhend = ldendd
     C                   eval      ldhent = ldendt
     *
     C                   write     ldhrec                               77
     *
     C                   enddo
     *
740aA*  When route is closed to Loader look for runner records with
740aA*  status 'S' and change them to status 'C'.
740aA
740aA /free

740aA  setll (lhwhse: lhrtid) label13;

740aA  dou forever <> forever;

740aA    reade (lhwhse: lhrtid) label13;
740aA    if %eof(label13);
740aA      leave;
740aA    endif;

740aA    chain (lbwhse: lblbl#) runner6;

740aA    if %found(runner6) and rustat = 'S';
740aA      rustat = 'C';
740aA      update rurec;
740aA    endif;

740aA  enddo;

740aA  unlock runner6;

740aA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
