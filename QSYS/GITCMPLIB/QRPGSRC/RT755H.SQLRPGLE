     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RT755H    Remove exported route history records - Post
     *  10 January, 2012
     *  Lynn McMahon
     *
     *  Notes:
     *      - Removes records from files
     *        RTEHEDH, LABELH, PIRTRANH, ORDHH,
     *
     *----------------------------------------------------------------
     *  Revisions
640A *    01/10/12  LMC
     *      - Copied from RT755 - for history file cleanup
640aA*    06/18/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
720a *    01/24/18  LMC  7.20a
     *      - Enh: Added cleanup for ORDDH.
720b *    01/25/18  LMC  7.20b
     *      - Enh: Added additional date logic to ensure we select the
     *        label records that go with the route id being purged.
     *        Because we allow duplicate route id's to be loaded into
     *        file RTEHEDH.
     *
730aA*    10/15/19  DAS  7.30a
     *      - Revised to use PIRTRANW, MULTRAN1W
740aA*    11/19/20  LMC  7.40a
     *      - Enh: Added cleanup for uciinfo.
750  *    11/22/21  KDE  7.50
     *      - Enh: Added files DDTASKH and DDDETAILH
770a *    07/21/23  KDE  7.70a
     *      - Fix: Remove RTEHEDH from DDTASJ+KH and DDDETAILH files
770b *    08/09/23  KDE  7.70b
     *      - Fix: Remove DDTASH and DDDETAILH and put in RT755
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for FILES
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Frtehedh   up   e           k disk
     FLabelh13  uf   e           k disk
730aDF*irtranh  uf   e           k disk
730aMFpirtranhw uf   e           k disk
     Fordhh3    uf   e           k disk
720aAForddh     uf   e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
740aA*----------------------------------------------------------------
740aA*  DRI parameters
740aA*----------------------------------------------------------------

740aA /COPY *libl/qcopysrc,C#DRIPARMP
740aA /COPY *libl/qcopysrc,C#DRIPARMS

740aA*----------------------------------------------------------------
740aA*  Data Formats
740aA*----------------------------------------------------------------
740aA /COPY *libl/qcopysrc,C#CWLOG
740aA /COPY *libl/qcopysrc,C#UCIINFO
740aAD savever#        s                   like($cwver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
740aA /copy qcopysrc,p.driuci
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
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
     D  opishs                33     35  0
     D  optend               117    117
     *----------------------------------------------------------------
     *  Working variables
     *
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D eflag           s              1
     D eflg2           s              1
     D eof             s              1
     D forevr          s              1
     d kycode          s                   like(opcode)
     d kywhse          s                   like(opwhse)
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
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
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     *  Although the following conditions are tested by open query
     c                   if        opishs = 0
     c                   eval      *inlr = *on
     c                   goto      bottom
     c                   endif

     C                   if        rhwhse <> $kwhse  or
     C                             rhexpd >= $kdate
     C                   goto      bottom
     C                   endif
     C                   eval      eflag = *off
     *  Delete PIRTRANH records.
     *  Delete LABELH records.
     C                   exsr      zzlbl
     *  Delete ORDHH order head records
     C                   exsr      zzordh
     *
     *  Delete exported route header record.
     *
     C                   if        eflag = *off
     C                   if        opishs <> 0
     C                   add       1             errecs
     C                   delete    rhrec                                79
     C                   endif
     C                   endif
     C     bottom        tag

     CLr                 exsr      zm0750
770bDc**                 exsr      dd2Purge
740aAclr                 exsr      zzclose
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
     *   Define partial key for ORDHH
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     *
     *   Define partial key for LABLEH file.
     *
     C     keylb         klist
     C                   kfld                    rhwhse
     *R                   KFLD           RHTYPE
     C                   kfld                    rhrtid
720aA*
720aA*   Define partial key for ORDD file.
720aA*
720aAC     keyod         klist
720aAC                   kfld                    ohwhse
720aAC                   kfld                    ohord
     *
     *    Define full key for file OPTIONS.
     *
     C                   eval      kywhse = *zeros
     C                   eval      kycode = '*SYSTEM '
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
730aA*
730aA*   Define key for pirtranhw
730aA*
730aAC     keypt         klist
730aAC                   kfld                    lbwhse
730aAC                   kfld                    lbtrn#
     *
     *    Retrieve System options.
     *
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      opishs = 0
     C                   endif
     C                   endsr
      *---------------------------------------------------------------
      *
      *  SUBROUTINE dd2Purge - Keep DDTASKH and DDDETAILH purged
      *
750 AC*    dd2Purge      begsr
      /free
           // Purge DDTASK History file where route id no longer
           // represented in RTEHEDH
           //exec sql
           //     delete from ddtaskh as d where d.ddtwhse=:$kwhse and
770aD      //   not exists (select * from rtehedh as r where r.rhwhse=d.ddtwhse
770aD      //   and r.rhrtid=d.ddtrtid) and
           //     not exists (select * from rtehed as rh where rh.rhwhse=d.ddtwhse
           //     and rh.rhrtid=d.ddtrtid);
           // Purge DDDETAIL History file where route id no longer
           // represented in RTEHEDH
           //exec sql
           //     delete from ddDETAILh as d where d.dddwhse=:$kwhse and
770aD      //   not exists (select * from rtehedh as r where
770aD      //   r.rhwhse=d.dddwhse and r.rhrtid=d.dddrtid) and
           //     not exists (select * from rtehed as rh where
           //   rh.rhwhse=d.dddwhse and rh.rhrtid=d.dddrtid);
      /end-free
750 AC*                  endsr
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
     *    ZZLBL   Delete LABELH/PIRTRANH records for route id.
     *
     C     zzlbl         begsr
     *
     *  Delete dependent LABELH and PIRTRANH records.
     *
     C     keylb         setll     labelh13
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     keylb         reade     labelh13                               79
     C                   move      *in79         eof
     C                   if        not *in79
720bAc* does this label record belong to this route id. Check dates
720bAc                   if        lbrdte > rhexpd
720bAc                   iter
720bAc                   endif
      * Only delete history if additional history is set in options
     C                   if        opishs <> 0
     C                   delete    lbrec                                77
     C                   if        *in77
     C                   move      *in77         eflag
     C                   endif
740aA /free
740aA   exsr zzuci;
740aA /end-free
     C                   endif
720bAc* need to change this to a read, since we allow duplicates in
720bAc* the pirtranh file. Also need to check dates.
730aDc**   lbtrn#        setll     pirtranh
730aMc     keypt         setll     pirtranhw
720bAC                   eval      eof = *off
720bAC                   dow       eof = *off
730aDC**   lbtrn#        reade     pirtranh                               77
730aMC     keypt         reade     pirtranhw                              77
720bAC                   move      *in77         eof
720bAC                   if        not *in77
720bDC*    lbtrn#        chain     pirtranh                           77
720bDC*                  if        not *in77
720bAc* does this transaction belong to the correct label- Check dates
720bAc                   if        ptgdte > rhexpd
720bAc                   iter
720bAc                   endif
      * Only write history if additional history is set in options
     C                   if        opishs <> 0
     C                   delete    ptrec                                77
     C                   if        *in77
     C                   move      *in77         eflag
     C                   endif
640aAc                   exsr      zzwrttrand
     C                   endif
     C                   endif
720bAc                   enddo
720bAc                   eval      eof = *off
     *
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDH  Delete exported ORDH Order head records for route id.
     *
     C     zzordh        begsr
     *
     *  Delete exported Order head records.
     *
     C     keyrs         setll     ordhh3
     C                   eval      forevr = *off
     C                   dow       forevr = *off
     C     keyrs         reade     ordhh3                                 79
     C                   move      *in79         forevr
     C                   if        not *in79
720bAc* need to make sure we have the right ordhh3 for the export date
720bAc* of the route id.
720bAc                   if        rhexpd <> ohudte
720bAc                   iter
720bAc                   endif
     C                   eval      eflg2 = *off
720aAC                   exsr      zzordd
     C                   if        eflg2 = *off
      * Only write history if additional history is set in options
     C                   if        opishs <> 0
     C                   delete    ohrec                                78
     C                   if        *in78
     C                   move      *in78         eflag
     C                   endif
     C                   endif
     C                   else
     *
     *    If any errors, seton error flag so next time cleanup
     *    is run the orders will be removed.
     *
     C                   if        eflg2 = *on
     C                   eval      eflag = eflg2
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *
720aA*---------------------------------------------------------------
720aA*
720aA*    ZZORDD  Delete exported ORDDH Order detail records for routeid.
     *
720aAC     zzordd        begsr
720aA*
720aA*  Delete exported customer order detail records.
720aA*
720aAC     keyod         setll     orddh
720aAC                   eval      eof = *off
720aAC                   dow       eof = *off
720aAC     keyod         reade     orddh                                  79
720aAC                   move      *in79         eof
720aAC                   if        not *in79
720aA * Only write history if additional history is set in options
720aAC                   if        opishs <> 0
720aAC                   delete    odrec                                78
720aAC                   if        *in78
720aA*R                   MOVE *IN78     EFLAG
720aMC                   move      *in78         eflg2
720aAC                   endif
720aAC                   endif
720aAC                   endif
720aAC                   enddo
720aA*
720aAC                   endsr
740aA*---------------------------------------------------------------
740aA*
740aA*    ZZUCI   Delete uci records for selection label/tran
740aA*
740aAC     zzuci         begsr
740aA*
740aA  /free
740aA        clear $uciinfo;
740aA        clear $uciinfo2;
740aA        $uiver# = savever#;

740aA        $uiwhse = lbwhse;
740aA        $uisellbl# = lblbl#;
740aA        $uiseltrn# = lbtrn#;

740aA        $dridata = $uciinfo;
740aA        $dridata2 = $uciinfo2;
740aA        driUCICalled = *on;
740aA        driuciinfo('%CLEANUP1': $pprogram: $drireturn:
740aA                 $drimessage: $dridata: $dridata2);
740aA  /end-free
740aAC                   endsr
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*CLEANUP';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
deleted route history records
