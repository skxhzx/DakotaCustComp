      /copy qcopysrc,hspecs
740aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS785      Clean up UCIINFO  records
     *  22 October  2020
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    10/22/20  LMC   7.40
     *      - Created
     *
740aA*    11/19/20  LMC   7.40a
     *      - Added cleanup for uci's that were selected and the
     *      label/labelh records have been purged. This is to catch
     *      uciinfo records that were orphaned because I hadn't put
     *      a cleanup process in RT755/RT755H.
     *      - Added sql cleanup for uciinfoexa for uciinfo that have
     *      been removed.
     *      - Added cleanup for create by type 6&7 individual weights
     *      from receiving. orphaned becausee po755/po755h hadn't had
     *      these added.
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fuciinfo4  uf   e           k disk
     Fuciinfoexauf   e           k disk
     Flabel90   if   e           k disk
740aAFuciinfo3  uf   e           k disk    rename(uirec:uirec3) prefix(u3_)
740aAFlabelhw   if   e           k disk    rename(lbrec:lbrecw)

740aA*----------------------------------------------------------------
740aA*  File field data structure.
740aA*----------------------------------------------------------------

740aAD lnrec         e ds                  extname(licinfo) inz(*EXTDFT)
740aA*----------------------------------------------------------------
740aA*  Standard SQL variables and constants
740aA*----------------------------------------------------------------

740aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D dfttimestamp    s             26z
     D cdatets         s             26z
     D forevr          s              1
     D uicreatedby     s              1

     c     *entry        plist
     c                   parm                    $pprg            10
     c                   parm                    $pwhse            3
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c                   move      $pwhse        $kwhse            3 0
      /free
       // lets work with create by type 3 - selection
       uicreatedby = '3';
       setll ($kwhse: uicreatedby) uciinfo4;
       dow forevr = forevr;
         reade ($kwhse: uicreatedby) uciinfo4;
         if %eof(uciinfo4);
           leave;
         endif;
         if uiaddts > cdatets;
           leave;
         endif;
         if uiseltrn# = 0;
           iter;
         endif;
         if %subst(uiuci:1:6) <> '99TRAX';
           iter;
         endif;
         // is the transaction/label record gone?
         chain ($kwhse: uiseltrn#: uisellbl#) label90;
         if %found(label90);
           iter;
         endif;
         // need to delete uciinfoexa if it exist
         chain (uiaddts: uiucilcns: uilcns) uciinfoexa;
         if %found (uciinfoexa);
           delete uiarec;
         endif;
         // then delere uciinfo
         delete uirec;
       enddo;

740aA  // lets work with create by type 7 - weights at receiving
740aA  uicreatedby = '7';
740aA  setll ($kwhse: uicreatedby) uciinfo4;
740aA  dow forevr = forevr;
740aA    reade ($kwhse: uicreatedby) uciinfo4;
740aA    if %eof(uciinfo4);
740aA      leave;
740aA    endif;
740aA    if uiaddts > cdatets;
740aA      leave;
740aA    endif;
740aA    // is the license gone from licinfo?
740aA    exec sql select * into :lnrec
740aA     from licinfo
740aA     where lnlcns = :uilcns
740aA       and lnwhse = :uiwhse;
740aA    if sqlstt <> sqlSuccess;
740aA      delete uirec;
740aA    else;
740aA      iter;
740aA    endif;
740aA  enddo;

740aA  // lets work with create by type 6 - weights at receiving
740aA  uicreatedby = '6';
740aA  setll ($kwhse: uicreatedby) uciinfo4;
740aA  dow forevr = forevr;
740aA    reade ($kwhse: uicreatedby) uciinfo4;
740aA    if %eof(uciinfo4);
740aA      leave;
740aA    endif;
740aA    if uiaddts > cdatets;
740aA      leave;
740aA    endif;
740aA    // is the license gone from licinfo?
740aA    exec sql select * into :lnrec
740aA     from licinfo
740aA     where lnlcns = :uilcns
740aA       and lnwhse = :uiwhse;
740aA    if sqlstt <> sqlSuccess;
740aA      delete uirec;
740aA    else;
740aA      iter;
740aA    endif;
740aA  enddo;

740aA  // lets look for orphaned selection records
740aA  setll ($kwhse: 1) uciinfo3;
740aA  dow forevr = forevr;
740aA    reade ($kwhse) uciinfo3;
740aA    if %eof(uciinfo3);
740aA      leave;
740aA    endif;
740aA    // is the transaction/label record gone?
740aA    chain ($kwhse: u3_uiseltrn#: u3_uisellbl#) label90;
740aA    if %found(label90);
740aA      iter;
740aA    endif;
740aA    // is the label record gone?
740aA    chain ($kwhse: u3_uisellbl#) labelhw;
740aA    if %found(labelhw);
740aA      iter;
740aA    endif;
740aA    // need to delete uciinfoexa if it exist
740aA    chain (u3_uiaddts: u3_uiucilcns: u3_uilcns) uciinfoexa;
740aA    if %found (uciinfoexa);
740aA      delete uiarec;
740aA    endif;
740aA    // then delere uciinfo
740aA    delete uirec3;
740aA  enddo;

      /end-free

740aA*  Cleanup orphaned uciinfoexa
740aA /free
740aA   exec sql delete from uciinfoexa
740aA    where (select count(*) from uciinfo where
740aA    uiaddts=uiaaddts and uiucilcns=uiaucilcns and
740aA    uilcns=uialcns)=0;
740aA /end-free
     *  done
     c                   eval      *inlr = *On
     c                   return
     *--------------------------------------------------------------
     *  *INZSR
     c     *inzsr        begsr

      /free
       CDateTS = %timestamp();
       CDateTS = CDateTS - %days(365);
      /end-free

     C                   endsr
