     H/copy qcopysrc,hspecs
720aAH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO755H    Remove exported purchase orders history - Post
     *  11 January, 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640  *    01/11/12  LMC  6.40
     *      - Copied from PO755, process history files in place of
     *        original data files, delete from history
640a *    01/20/12  LMC  6.40a
     *      - Fix: added logic to check to make sure liclog records
     *        don't exist before removing licinfo records
640b *    03/30/12  RBD  6.40b
     *      - Fix: only delete PUTSTG recs if group type 1 = P.
     *        Selection recs were getting deleted when a PO
     *        happened to match a route id.
640c *    06/13/12  LMC  6.40c
     *      - Fix: Added additional logic check to ensure we cleanup
     *        records asociated with the current export of the po.
     *        Problem existed that all data was being deleted for the
     *        PO, even if mutiple exported dates existed for the PO.
640d *    10/16/12  LMC  6.40d
     *      - NOTE: THIS MOD SHOULD ONLY BE APPLIED IF THE CLIENT HAS
     *        THE NEW LICINFOH FILE. Key for licinfoh1 has changed.
     *        LICINFOH1 had lncode as a key field, and the field does
     *        not exist in the new file.
640eA*    06/15/12  LMC  6.40e
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650a *    05/20/13  LMC  6.50a
     *      - Enh: Added cleanup for RCVPO transactions. No label will
     *        exist, so we will clean these up based on the PO#.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
720a *    02/06/18  LMC  7.20a
     *      - Enh: Added logic to check dates, we will now be allowing
     *        duplicates in file pohhdrh, so we need to make sure we
     *        are processing the correct data from the other files.
     *      - Most of subr zzlabl was rewritten with free, so it is
     *        easier to follow.
740a *    12/03/20  LMC  7.40a
     *      - Enh: Added UCIINFO to cleanup.
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for POH
     *  79        - EOF for POHHDRH
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fpohhdrh   up   e           k disk
     flabelh10  uf   e           k disk
     fpirtranh  uf   e           k disk
     flicenseh1 uf   e           k disk
     FPIRTRANH4 UF   E           K DISK    rename(ptrec:ptrec4)
     Foptions   if   e           k disk
     flicinfoh2 uf   e           k disk
     flicinfoh1 if   e           k disk    rename(lnhrec:lnrec1) prefix(a_)
640aAfliclogh   if   e           k disk
640aAfliclogh1  if   e           k disk    rename(llhrec:llrec1)
740aA*----------------------------------------------------------------
740aA*  DRI parameters
740aA*----------------------------------------------------------------

740aA /COPY *libl/qcopysrc,C#DRIPARMP
740aA /COPY *libl/qcopysrc,C#DRIPARMS

740aA*----------------------------------------------------------------
740aA*  Data Formats
740aA*----------------------------------------------------------------
740aA /COPY *libl/qcopysrc,C#UCIINFO
740aAD savever#        s                   like($uiver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     d desc            s             50    dim(1) ctdata perrcd(1)
640eA*----------------------------------------------------------------
640eA*  Prototypes
640eA*----------------------------------------------------------------
640eA
740aA /copy qcopysrc,p.driuci
640eAD wrttran1        pr                  extpgm('WRTTRAN1')
640eA * Input
640eAD   ppcmd                        8
640eAD   ppwait                       2  0
640eAD   ppwhse                       3  0
640eAD   pptran#                      7  0
640eAD   ppfromdate                   8  0
640eAD   pptodate                     8  0
640eAD   ppemp#                       5  0
720aA*----------------------------------------------------------------
720aA*  Sub-procedure prototypes
720aA*----------------------------------------------------------------
720aAd CreateTS        pr              z
720aAd  date                          8p 0 const
720aAd  time                          6p 0 const

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import Item fields (Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
     *    OPISHS  -  Number of weeks - extra history files to keep.
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  optend               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     d $mdt            ds
     d  errmsg                 1     50
     *
     d  errecs                 1      3p 0
     d  erdesc                 4     48
     d                 ds
     d  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     d #msgf           c                   const('PIRMSGF   ')
     *
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     d kycode          s                   like(opcode)
     d kywhse          s                   like(opwhse)
640dDd*kylicinfo1      s                   like(lncode)
640dDd*kylicinfotrn#   s                   like(lnvalue)
     d keylcns         s                   like(lilcns)
640eAD wrtpcmd         s             10
640eAD wrtpwait        s              2  0
640eAD wrtpwhse        s              3  0
640eAD wrtptran#       s                   like(pttrn#)
640eAD wrtpfrmdate     s              8  0
640eAD wrtptodate      s              8  0
640eAd wrtpemp#        s                   like(ptemp#)
720aAd purgedate       s               z
720aAd foundlicense    s               n
740aA*----------------------------------------------------------------
740aA*  Called program flags
740aA*----------------------------------------------------------------

740aAD driUciCalled    s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      &PWHSE  - Warehouse
     *      &PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     c     *entry        plist
     c                   parm                    $pprg            10
     c                   parm                    $pwhse            3
     c                   parm                    $pdate            8
     c                   move      $pwhse        $kwhse            3 0
     c                   move      $pdate        $kdate            8 0
     *----------------------------------------------------------------
     * Main line
     *
     * history is not used, don't execute the program.
     c                   if        opishs = 0
     c                   eval      *inlr = *on
     c                   goto      bottom
     c                   endif
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     *          PHWHSE    IFNE $KWHSE
     c     phhwhs        ifne      $kwhse
     *          PHUDTE    ORGE $KDATE
     c     phhedt        orge      $kdate
     c                   goto      bottom
     c                   endif
720aA /free
720aA   purgedate = CreateTS(phhedt: phheti);
720aA /end-free
     *
     *  Delete exported label records and transactions.
     c                   exsr      zzlabl
     c     eflag         cabeq     *on           bottom
      *  Delete PUTSTG transactions.
     C                   exsr      ZZSTAG
     C     EFLAG         CABEQ     *ON           BOTTOM
650aA *  Delete RCVPO transactions.
650aAc     phhpo         ifne      ' '
650aAC                   exsr      ZZRCVPO
650aAc                   endif
650aAC     EFLAG         CABEQ     *ON           BOTTOM
     *
     *  Delete exported purchase order header record.
     *
     c                   add       1             errecs
      * Only delete history if additional history is set in options
     C                   if        opishs <> 0
     C                   delete    phhrech
     C                   endif
     *
     *
     c     bottom        tag
     *
     clr                 exsr      zm0750
740aAclr                 exsr      zzclose
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     c                   z-add     0             errecs
     c                   movel     desc(1)       erdesc
     c                   move      *off          eflag             1
     c                   move      *off          forevr            1
     *
     *   Define partial key for POHDTL file.
     *
     c     keyod         klist
     c                   kfld                    phhwhs
     c                   kfld                    phhpo
     *
     *
     *   Define key for LICENSE file.
     *
     c     keylcn        klist
     c                   kfld                    lbwhse
     c                   kfld                    lbtrn#
     *
     *   Define key for LICENSE file.
     *
     c     keystgl       klist
     c                   kfld                    ptwhse
     c                   kfld                    pttrn#
     *
     *   Define key for LICINFO file.
     *
     c     keyln         klist
     c                   kfld                    liwhse
     c                   kfld                    lilcns
     *   Define key for LICINFO file orphaned in licinfo not license
     *
     c     keylnorphan   klist
     c                   kfld                    a_lnwhse
     c                   kfld                    a_lnlcns
     *
     *   Define key for LICINFOH1 file.
     *
     c     keylcninfo1   klist
     c                   kfld                    lbwhse
640dDc*                  kfld                    kylicinfo1
640dDc*                  kfld                    kylicinfotrn#
640dAc                   kfld                    lbtrn#
     *   Define key for LICACTIVE file.
     *
     c     keylicactive  klist
     c                   kfld                    lbwhse
     c                   kfld                    keylcns
     *
     C*   Define key for PIRTRANH4 file.
     CSR   KEYSTG        KLIST
     CSR                 KFLD                    PHHWHS
     CSR                 KFLD                    KYGRP2
     CSR                 KFLD                    PHHPO
     *
     *
     *    Define full key for file OPTIONS.
     *
     C                   eval      kywhse = *zeros
     C                   eval      kycode = '*SYSTEM '
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     *
     *    Retrieve System options.
     *
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      opishs = 0
     C                   endif
     c                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid            7
     c                   parm                    #msgtp            7
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     c     zm0750        begsr
     c                   move      'PIR0750'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   endsr
740aA*---------------------------------------------------------------
740aA*
740aA*    ZZCLOSE close dri programs called
740aA*
740aAC     zzclose       begsr
740aA /free
740aA    if driUCICalled;
740aA      driuciinfo('%CLOSE': $pprogram: $drireturn: $drimessage:
740aA               $dridata: $dridata2);
740aA    endif;
740aA
740aA /end-free
740aAC                   endsr
     *---------------------------------------------------------------
     *
     *    ZZLABL  Delete exported Label records for PO.
     *            Delete dependent PIRTRAN and LICENSE records for label.
     *
     c     zzlabl        begsr
     *
     c                   move      *off          eflag
     c     keyod         setll     labelh10
     c                   move      *off          eof
     c     eof           doweq     *off
     c     keyod         reade     labelh10                               79
     c                   move      *in79         eof
     c     *in79         ifeq      *off
640cA * check the report date, make sure it is <= the PO export date
640cAc                   if        lbrdte > phhedt
640cAc                   iter
640cAc                   endif
720aA /free
720aA   // need to read instead of chain, we now allow duplicates
720aA   foundlicense = *off;
720aA   setll (lbwhse: lbtrn#) licenseh1;
720aA   dow not %eof(licenseh1);
720aA     reade (lbwhse: lbtrn#) licenseh1;
720aA     if %eof(licenseh1);
720aA       leave;
720aA     endif;
720aA     // we need to see when the license entered the system
720aA     // if the lnaddts date is after the export date, we will skip
720aA     // this license record. If no licinfo record exist, we will
720aA     // let processing continue, and the license record will be
720aA     // delete.
720aA     chain (liwhse: lilcns) licinfoh2;
720aA     if %found(licinfoh2);
720aA       if purgedate < lnaddts;
720aA         iter;
720aA       endif;
720aA     endif;
720aA     foundlicense = *on;
720aA     if foundlicense;
720aA       keylcns = lilcns;
720aA       // if records exist in liclob, for either original or
720aA       // current license, don't remove licinfo at this time.
720aA       // licinfo will be cleaned up when liclog file is ready
720aA       // to be removed
720aA       chain (lbwhse: keylcns) liclogh;
720aA       chain (lbwhse: keylcns) liclogh1;
720aA       if not %found(liclogh) and
720aA          not %found(liclogh1);
720aA         setll (liwhse: lilcns) licinfoh2;
720aA         dow forevr = forevr;
720aA           reade (liwhse: lilcns) licinfoh2;
720aA           if %eof(licinfoh2);
720aA             leave;
720aA           endif;
720aA           // make sure this licinfo record was created prior
720aA           // to the export date of the po.
720aA           if purgedate > lnaddts;
720aA             iter;
720aA           endif;
720aA           // only attempt delete is extended history is used.
720aA           if opishs <> 0;
720aA             delete lnhrec;
720aA             if %error;
720aA               eflag = *on;
720aA             endif;
720aA           endif;
740aA           if opishs = 0;
740aA             exsr zzuci;
740aA           endif;
720aA         enddo;
720aA       endif;
720aA       // Now working on deleting the license record
720aA       // only attempt delete if extended history is used
720aA       if opishs <> 0;
720aA         delete lirec;
720aA         if %error;
720aA           eflag = *on;
720aA         endif;
720aA       endif;
720aA     endif;
720aA   enddo;
720aA   // now lets check for licinfo that we didn't have a license
720aA   // record for.
720aA   if foundlicense = *off;
720aA     // need to read instead of chain, we now allow duplicates
720aA     setll (lbwhse: lbtrn#) licinfoh1;
720aA     dow not %eof(licinfoh1);
720aA       reade (lbwhse: lbtrn#) licinfoh1;
720aA       if %eof(licinfoh1);
720aA         leave;
720aA       endif;
720aA       if purgedate < lnaddts;
720aA         iter;
720aA       endif;
720aA       *in76 = *off;
720aA       keylcns = lnlcns;
720aA       chain (lbwhse: keylcns) liclogh;
720aA       chain (lbwhse: keylcns) liclogh1;
720aA       if not %found(liclogh)  and
720aA          not %found(liclogh1);
720aA         setll (a_lnwhse: a_lnlcns) licinfoh2;
720aA         dow forevr = forevr;
720aA           reade (a_lnwhse: a_lnlcns) licinfoh2;
720aA           if %eof(licinfoh2);
720aA             leave;
720aA           endif;
720aA           if opishs <> 0;
720aA             delete lnhrec;
720aA             if %error;
720aA               eflag = *on;
720aA             endif;
720aA           endif;
740aA           if opishs = 0;
740aA             exsr zzuci;
740aA           endif;
720aA         enddo;
720aA       endif;
720aA     enddo;
720aA   endif;
720aA   if eflag = *off;
720aA     setll (lbtrn#) pirtranh;
720aA     dow forevr = forevr;
720aA       reade (lbtrn#) pirtranh;
720aA       if %eof (pirtranh);
720aA         leave;
720aA       endif;
720aA       if ptgdte > phhedt;
720aA         iter;
720aA       endif;
720aA       if opishs <> 0;
720aA         delete ptrec;
720aA         if %error;
720aA           eflag = *on;
720aA         endif;
720aA         exsr zzwrttrand;
720aA       endif;
720aA     enddo;
720aA   endif;
720aA   // finally delete the label record
720aA   if eflag = *off;
720aA     if opishs <> 0;
720aA       delete lbrec;
720aA       if %error;
720aA         eflag = *on;
720aA       endif;
720aA     endif;
720aA   endif;
720aA /end-free
720aDc*    keylcn        chain     licenseH1                          77
720aDc*    foundlicense  ifeq      *on
720aDc*                  eval      keylcns = lilcns
720aD * if records exist in liclog, for either original or current license
720aD * don't remove licinfo at this time.
720aD * licinfo will be cleaned up when liclog file is ready to be removed.
720aDc*    keylicactive  chain     liclogh
720aDc*    keylicactive  chain     liclogh1
720aDc*                  if        not %found(liclogh) and
720aDc*                            not %found(liclogh1)
720aDc*    keyln         setll     licinfoh2
720aDc*    forevr        doweq     forevr
720aDc*    keyln         reade     licinfoh2                              78
720aDc*    *in78         ifeq      *off
720aDc* make sure this licinfo record was created prior to the export time
720aDc*                  if        purgedate > lnaddts
720aDc*                  iter
720aDc*                  endif
720aD * Only write history if additional history is set in options
720aDC*                  if        opishs <> 0
720aDc*                  delete    lnhrec                               77
720aDC*                  endif
720aDc*    *in77         ifeq      *on
720aDc*                  move      *in77         eflag
720aDc*                  endif
720aDc*                  else
720aDc*                  leave
720aDc*                  endif
720aDc*                  enddo
720aDc*                  endif
720aD * Only write history if additional history is set in options
720aDC*                  if        opishs <> 0
720aDc*                  delete    lirec                                77
720aDC*                  endif
720aDc*    *in77         ifeq      *on
720aDc*                  move      *in77         eflag
720aDc*                  endif
720aDc*                  else
720aDc*                  endif
720aDc*                  enddo
720aD * if no license record is found check the licinfoh1 file for
720aD * license info code *RCVTRN# move to history if license is no
720aD * longer active
720aDc*    foundlicense  ifeq      *off
720aDc*                  eval      kylicinfo1 = '*RCVTRN#'
720aDC*                  eval      kylicinfotrn# =   %char(lbtrn#)
720aDc* need to read instead of chain, we now allow duplicates
720aDc*    keylcninfo1   chain     licinfoh1
720aDc*                  if        %found(licinfoh1)
720aDc*                  eval      *in76 = *off
720aDC*    keylicactive  chain     liclogh
720aDC*    keylicactive  chain     liclogh1
720aDc*                  if        not %found(liclogh)  and
720aDc*                            not %found(liclogh1)
720aDc*    keylnorphan   setll     licinfoh2
720aDc*    forevr        doweq     forevr
720aDc*    keylnorphan   reade     licinfoh2                              76
720aDc*    *in76         ifeq      *on
720aDc*                  leave
720aDc*                  endif
720aDc*    *in76         ifeq      *off
720aD * Only write history if additional history is set in options
720aDC*                  if        opishs <> 0
720aDc*                  delete    lnhrec                               77
720aDC*                  endif
720aDc*    *in77         ifeq      *on
720aDc*                  move      *in77         eflag
720aDc*                  endif
720aDc*                  endif
720aDc*                  enddo
720aDc*                  endif
720aDc*                  else
720aDc*                  eval      eflag = *on
720aDc*                  endif
720aDc*                  endif
720aDc*                  enddo
720aDc*    eflag         cabeq     *on           endlb
720aDc*    lbtrn#        setll     pirtranh
720aDc*    forevr        doweq     forevr
720aDc*    lbtrn#        reade     pirtranh                               77
720aDc*    *in77         ifeq      *off
720aD * Only write history if additional history is set in options
720aDC*                  if        opishs <> 0
720aDc*                  delete    ptrec                                77
720aDc*                  exsr      zzwrttrand
720aDC*                  endif
720aDc*    *in77         ifeq      *on
720aDc*                  move      *in77         eflag
720aDc*                  endif
720aDc*                  else
720aDc*                  leave
720aDc*                  endif
720aDc*                  enddo
720aDc*    eflag         cabeq     *on           endlb
720aD * Only write history if additional history is set in options
720aDC*                  if        opishs <> 0
720aDc*                  delete    lbrec                                78
720aDC*                  endif
720aDc*    *in78         ifeq      *on
720aDc*                  move      *in78         eflag
720aDc*                  endif
     c                   endif
     c                   enddo
     c     endlb         endsr
     *
650aAC*---------------------------------------------------------------
650aAC*
650aAC*    ZZRCVPO Delete RCVPO transactions for PO.
650aAC*
650aA /free
650aA    begsr zzrcvpo;
650aA      kygrp2 = ' ';
650aA      eflag = *off;
650aA      setll (phhwhs: kygrp2: phhpo) pirtranh4;
650aA      dow not %eof(pirtranh4);
650aA        reade (phhwhs: kygrp2: phhpo) pirtranh4;
650aA        if %eof(pirtranh4);
650aA          leave;
650aA        endif;
650aA        if ptgrp1 <> 'P';
650aA          leave;
650aA        endif;
650aA        if ptgdte > phhedt;
650aA          iter;
650aA        endif;
650aA        if pttask <> 'RCVPO';
650aA          iter;
650aA        endif;
650aA        delete PTREC4;
650aA        if %error;
650aA          eflag = *on;
650aA          leave;
650aA        endif;
650aA      enddo;
650aA    endsr;
650aA /end-free
650aA
     C*---------------------------------------------------------------
     C*
     C*    ZZSTAG  Delete PUTSTG transactions for PO.
     C*
     CSR   ZZSTAG        BEGSR
     C*
     C                   MOVE      *BLANKS       KYGRP2            1
     C                   MOVE      *OFF          eof               1
     CSR   KEYSTG        SETLL     PIRTRANH4
     CSR                 MOVE      *OFF          EFLAG
     C     eof           DOWEQ     *OFF
     C     KEYSTG        READE     PIRTRANH4                              77
     C                   MOVE      *IN77         eof
     C     *IN77         IFEQ      *OFF
640bAC     PTGRP1        ANDEQ     'P'
640cA * check the dates to see if generated date <= po export date
640cAc                   if        ptgdte > phhedt
640cAc                   iter
640cAc                   endif
720aA * need to read to get the license that entered the system prior
720aA * to the exported date of the po.
720aA /free
720aA   setll (ptwhse: pttrn#) licenseh1;
720aA   dow not %eof(licenseh1);
720aA     reade (ptwhse: pttrn#) licenseh1;
720aA     if %eof(licenseh1);
720aA       leave;
720aA     endif;
720aA     // we need to see when the license entered the system
720aA     // if the lnaddts date is after the export date, we will skip
720aA     // this license record. If no licinfo record exist, we will
720aA     // let processing continue, and the license record will be
720aA     // deleted.
720aA     chain (liwhse: lilcns) licinfoh2;
720aA     if %found(licinfoh2);
720aA       if purgedate < lnaddts;
720aA         iter;
720aA       endif;
720aA     endif;
720aA /end-free
720aDC*    KEYSTGL       CHAIN     LICENSEH1                          78
720aDC*    *IN78         IFEQ      *OFF
     C                   if        opishs <> 0
     C                   delete    lirec                                77
     C                   endif
720aDC*                  endif
720aDc                   enddo
     C                   if        opishs <> 0
     C                   delete    PTREC4                               77
640eAc                   exsr      zzwrttrand
     C                   endif
     CSR   *IN77         IFEQ      *ON
     C                   MOVE      *IN77         EFLAG
     CSR                 ENDIF
     CSR                 ELSE
     CSR                 LEAVE
     C                   ENDIF
     C                   ENDDO
     CSR                 ENDSR

740aA*---------------------------------------------------------------
740aA*
740aA*    ZZUCI   Delete uci records for license received.
740aA*
740aAC     zzuci         begsr
740aA*
740aA  /free
740aA        clear $uciinfo;
740aA        clear $uciinfo2;
740aA        $uiver# = savever#;

740aA        $uiwhse = lnwhse;
740aA        $uilcns = lnlcns;
740aA        $uicrtby = '7';

740aA        $dridata = $uciinfo;
740aA        $dridata2 = $uciinfo2;
740aA        driUCICalled = *on;
740aA        driuciinfo('%CLEANUP2': $pprogram: $drireturn:
740aA                 $drimessage: $dridata: $dridata2);
740aA  /end-free
740aAC                   endsr
640eA*----------------------------------------------------------------*********
640eA*
640eA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640eA*
640eA /free
640eA   begsr zzwrttrand;
640eA     wrtpcmd = '*CLEANUP';
640eA     wrtpwait = 0;
640eA     wrtpwhse = ptwhse;
640eA     wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
640eA     wrtptodate = 0;
640eA     wrtpemp# = 0;
640eA
640eA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640eA               wrtpfrmdate: wrtptodate: wrtpemp#);
640eA   endsr;
640eA /end-free
720aA*----------------------------------------------------------------
720aA*  CreateTS   Create timestamp from Date/Time
720aA*----------------------------------------------------------------

720aAp CreateTS        b
720aAd CreateTS        pi              z
720aAd  date                          8p 0 const
720aAd  time                          6p 0 const

720aA*  Local Variables

720aAD stamp           s               z
720aAD temp26          s             26

720aAD                 ds
720aAD  yyyymmdd               1      8s 0
720aAD    yyyy                 1      4
720aAD    mm                   5      6
720aAD    dd                   7      8

720aAD                 ds
720aAD  hhmiss                 1      6s 0
720aAD    hh                   1      2
720aAD    mi                   3      4
720aAD    ss                   5      6


720aA /free

720aA   clear stamp;

720aA   if date = 0;
720aA     return stamp;
720aA   endif;

720aA   yyyymmdd = date;
720aA   hhmiss = time;
720aA   temp26 = yyyy + '-' + mm + '-' + dd + '-'
720aA          + hh + '.' + mi + '.' + ss + '.000000';

720aA   monitor;
720aA     stamp = %timestamp(temp26);
720aA   on-error;
720aA     clear stamp;
720aA   endmon;

720aA   return stamp;

720aA /end-free

720aAp CreateTS        e

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
exported history purchase orders
