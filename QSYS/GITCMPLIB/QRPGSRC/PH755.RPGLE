     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PH755     Remove PHRASELOG records - Post
     *  10 August 2009
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530  *    08/10/09  GJA  5.30
     *      - Created
640a *    05/14/12  LMC  6.40a
     *      - Fix - change to process a logical by date, program
     *              was setting on lr first date > remove date. With
     *              reuse deleted records, it was encountering new
     *              records before it gets to the old ones.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  78        - NRF for TASK
     *  79        - EOF for PIRTRAN
     *  79        - EOF for BATCTL3
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aDF*phraselog up   e             disk
640aMFphraselog2uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Data structure for convert date parameters
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      3p 0
     D  erdesc                 4     48
     D                 ds
     D  $ec                    1      2p 0
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *-----VARIABLES--------------------------------------------------
     D $msgf           s             10
     D chkdate         s              8  0
640aAD forever         s              1
640aAD keyuser         s             10
     D rmvdate         s              8  0
     D w@date          s               d
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Remove date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     *----------------------------------------------------------------
     * Main line
     *
     *    Delete records less than remove date
     *
     *
640aA /free
640aA   keyuser = ' ';
640aA   setll (keyuser) phraselog2;
640aA   dow forever = forever;
640aA     read phraselog2;
640aA     if %eof(phraselog2);
640aA       *inlr = *on;
640aA       return;
640aA     endif;
640aA     chkdate=%int(%char(%date(phladdts):*iso0));
640aA     if chkdate < rmvdate;
640aA       delete phlrec;
640aA     else;
640aA       setgt (phluser) phraselog2;
640aA     endif;
640aA   enddo;
640aA /end-free
640aDC*                  eval      chkdate=%int(%char(%date(phladdts):*iso0))
     *
640aDC*                  if        chkdate < rmvdate
640aDC*                  delete    phlrec
640aDC*                  add       1             errecs
640aDC*                  else
640aDC*                  exsr      zm0750
640aDC*                  eval      *inlr=*on
640aDC*                  return
640aDC*                  endif
     *
     *
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
     *
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     C                   move      $pdate        rmvdate
     *
     C                   if        rmvdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C     *YMD          move      $cvd8o        w@date
     C                   eval      w@date -= %Days(3)
     C     *ISO          move      w@date        rmvdate
     C                   endif
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     C     zm0750        begsr
     C                   eval      #msgid = 'PIR0750'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Misc phraselog records
