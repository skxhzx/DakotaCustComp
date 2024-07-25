     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SU155     Clear & reset files for start up - Clear
     *  19 August 1999
     *  Roxanne Harrison
     *    Created using PCK135
     *
     *  Revisions
     *
416 A*    10/16/01  MLB  4.16
    A*      - Field added to ORRTN. Re-compile only.
416aA*    11/08/01  RH   4.16a
    A*      - File ORRTN changed, Re-compile only.
416bA*    03/12/02  RH   4.16b
    A*      - File ORDSLCT changed, Re-compile only.
416cA*    05/24/02  RH   4.16c
    A*      - File LICENSE changed, Re-compile only.
417aA*    07/08/03  RH   4.17a
    A*      - ORDT file changed, Re-compile only.
510 A*    11/20/06  RAH   5.10
     *      - Enh: Add POHACCP and POHHACCP.
510bA*    01/08/07  RH    5.10b
     *      - Enh: Recompile POHHACCP file key changed.
640aA*    06/11/12  LMC   6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     fsu155fm   cf   e             workstn usropn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     d a10             s              1    dim(10)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     d $mdt            ds
     d  errmsg                 1     50
     *
     d  eritem                 1     15
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
     *----------------------------------------------------------------
     *  Program info data structure
     *
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
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
     *  Variables
     *----------------------------------------------------------------
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s              7  0
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s              5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $PWHSE  Warehouse
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     c     *entry        plist
     c                   parm                    $pjtyp            1
     c                   parm                    $whse            15 5
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse selected.
     *
     c                   z-add     $whse         kywhse            3 0
     *-------------------------------------------------------------------------
     *
411 A*  Clear file BATCTL.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'BATCTL  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   batctl
     c+  where  (btwhse = :kywhse)
     c/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file CROSSDK.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'CROSSDK '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   crossdk
405 Ac+  where  (cdwhse = :kywhse)
405 Ac/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file EXPADJ.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'EXPADJ  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   expadj
     c+  where  (iewhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPORDD.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'EXPORDD '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   expordd
     c+  where  (oedwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPORDH.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'EXPORDH '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   expordh
     c+  where  (oehwhs = :kywhse)
     c/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file EXPPOD.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'EXPPOD  '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   exppod
405 Ac+  where  (pedwhs = :kywhse)
405 Ac/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file EXPPOH.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'EXPPOH  '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   exppoh
405 Ac+  where  (pehwhs = :kywhse)
405 Ac/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPORDD.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'IMPORDD '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   impordd
     c+  where  (oidwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file EXPRTN.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'EXPRTN  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   exprtn
     c+  where  (oewhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPORDH.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'IMPORDH '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   impordh
     c+  where  (oihwhs = :kywhse)
     c/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file IMPPOD.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'IMPPOD  '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   imppod
405 Ac+  where  (pidwhs = :kywhse)
405 Ac/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file IMPPOH.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'IMPPOH  '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   imppoh
405 Ac+  where  (pihwhs = :kywhse)
405 Ac/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file IMPRTN.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'IMPRTN  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   imprtn
     c+  where  (oirwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ITEMADJ.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ITEMADJ '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   itemadj
     c+  where  (iawhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ITEMEXP.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ITEMEXP '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   itemexp
     c+  where  (exwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Reset file ITEMQTY.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ITEMQTY '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+ update itemqty set iqstk1 = 0, iqstk2 = 0, iqstk3 = 0,
     c+ iqalc1 = 0, iqalc2 = 0, iqalc3 = 0, iqhld1 = 0, iqhld2 = 0,
     c+ iqhld3 = 0, iqtri1 = 0, iqtri2 = 0, iqtri3 = 0, iqtro1 = 0,
     c+ iqtro2 = 0, iqtro3 = 0, iqord1 = 0 where (iqwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file LABEL.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'LABEL   '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   label
     c+  where  (lbwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
412 A*  Clear file LICENSE.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'LICENSE '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   license
     c+  where  (liwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDC.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORDC    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   ordc
     c+  where  (ocwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDD.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORDD    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   ordd
     c+  where  (odwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDH.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORDH    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   ordh
     c+  where  (ohwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ORDRTN.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORDRTN  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   ordrtn
     c+  where  (orwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ORDSLCT.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORDSLCT '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   ordslct
     c+  where  (oswhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDT.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORDT    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   ordt
     c+  where  (otwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ORTNBAT
     *
     c     $pjtyp        ifeq      *on
     c                   move      'ORTNBAT '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   orrtnbat
     c+  where  (obrwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRBATCH.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRBATCH'    w1file
     c                   write     screen1
     c                   endif
     c     *dtaara       define    pirbatch      next1             7 0
     c     *lock         in        next1
     c                   z-add     1             next1
     c                   out       next1
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRLABEL.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRLABEL'    w1file
     c                   write     screen1
     c                   endif
     c     *dtaara       define    pirlabel      next2             7 0
     c     *lock         in        next2
     c                   z-add     1             next2
     c                   out       next2
     *-------------------------------------------------------------------------
     *
     *  Clear file PIRORD#.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRORD# '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pirord#
     c+  where  (nxowhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRPALET.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRPALET'    w1file
     c                   write     screen1
     c                   endif
     c     *dtaara       define    pirpalet      next3             7 0
     c     *lock         in        next3
     c                   z-add     1             next3
     c                   out       next3
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRPO#.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRPO#  '    w1file
     c                   write     screen1
     c                   endif
     c     *dtaara       define    pirpo#        next4             7 0
     c     *lock         in        next4
     c                   z-add     1             next4
     c                   out       next4
     *-------------------------------------------------------------------------
     *
     *  Clear file PIRRTE#.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRRTE# '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pirrte#
     c+  where  (nxrwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file PIRTRAN.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRTRAN '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pirtran
     c+  where  (ptwhse = :kywhse)
     c/end-exec
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA     wrtpcmd = '*CLEAR  ';
640aA     wrtpwait = 0;
640aA     wrtpwhse = kywhse;
640aA     wrtptran# = 0;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA /end-free
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRTRAN.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRTRAN '    w1file
     c                   write     screen1
     c                   endif
     c     *dtaara       define    pirtran       next5             7 0
     c     *lock         in        next5
     c                   z-add     1             next5
     c                   out       next5
     *-------------------------------------------------------------------------
     *
     *  Clear file PLTSTP.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PLTSTP  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pltstp
     c+  where  (psswhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file PLTSUM.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PLTSUM  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pltsum
     c+  where  (pswhse = :kywhse)
     c/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file PODTL.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'PODTL   '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   podtl
405 Ac+  where  (pdwhse = :kywhse)
405 Ac/end-exec
     *-------------------------------------------------------------------------
     *
411 A*  Clear file POMFR.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'POMFR   '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pomfr
     c+  where  (pmwhse = :kywhse)
     c/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file POHDR.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'POHDR   '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   pohdr
405 Ac+  where  (phwhse = :kywhse)
405 Ac/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file POHDTL.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'POHDTL  '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   pohdtl
405 Ac+  where  (phdwhs = :kywhse)
405 Ac/end-exec
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file POHHDR.
405 A*
405 Ac     $pjtyp        ifeq      *on
405 Ac                   move      'POHHDR  '    w1file
405 Ac                   write     screen1
405 Ac                   endif
405 Ac/exec sql
405 Ac+  delete
405 Ac+  from   pohhdr
405 Ac+  where  (phhwhs = :kywhse)
405 Ac/end-exec
     *-------------------------------------------------------------------------
     *
510 a*  Clear file POHACCP.
     *
510 ac                   if        $pjtyp = *on
510 ac                   eval      w1file = 'POHACCP '
510 ac                   write     screen1
510 ac                   endif
510 ac/exec sql
510 ac+  delete
510 ac+  from   pohaccp
510 ac+  where  (hawhse = :kywhse)
510 ac/end-exec
     *-------------------------------------------------------------------------
     *
510 a*  Clear file POHHACCP.
     *
510 ac                   if        $pjtyp = *on
510 ac                   eval      w1file = 'POHHACCP'
510 ac                   write     screen1
510 ac                   endif
510 ac/exec sql
510 ac+  delete
510 ac+  from   pohhaccp
510 ac+  where  (hahwhse = :kywhse)
510 ac/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file RTEHED.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'RTEHED  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   rtehed
     c+  where  (rhwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file RTESUM.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'RTESUM  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   rtesum
     c+  where  (rswhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
412 A*  Clear file SLOT of Virtual slots.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'SLOT    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+ delete from slot where (slwhse = :kywhse and slrsrv =
     c+ 'V')
     c/end-exec
     *-------------------------------------------------------------------------
     *
412 A*  Reset file SLOT quantities.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'SLOT    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+ update slot set slstk1 = 0, slstk2 = 0, slstk3 = 0,
     c+ slalc1 = 0, slalc2 = 0, slalc3 = 0, sltfr1 = 0, sltfr2 = 0,
     c+ sltfr3 = 0, slpck1 = 0, slpck2 = 0, slpck3 = 0, slrcv1 = 0,
     c+ slrcv2 = 0, slrcv3 = 0 where (slwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
412 A*  Reset file SLOT overflow slots.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'SLOT    '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+ update slot set slstat = 'V ', slitem = ' ', slsdte = 0,
     c+        slstim = 0, slentd = 0
     c+ where (slwhse = :kywhse and slpick = 'N')
     c/end-exec
     *-------------------------------------------------------------------------
     *
412 A*  Clear file UPC.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'UPC     '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   upc
     c+  where  (upwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
412 A*  Clear file VSLOT.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'VSLOT   '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   vslot
     c+  where  (vswhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file WORKLBL.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'WORKLBL '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   worklbl
     c+  where  (lwwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file WORKZON.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'WORKZON '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   workzon
     c+  where  (zwwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     c                   move      *on           *inlr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     c     *inzsr        begsr
     *
     *  Initialize variables
     *
     c                   move      *on           forevr            1
     c                   move      *off          error             1
     *
     *   Open display file if this program is being run interactively.
     *
     c     $pjtyp        ifeq      *on
     c                   open      su155fm
     c                   endif
     *
     *   Initialize message handling
     *
     c     $pjtyp        ifeq      *on
     c                   exsr      zmimsg
     c                   endif
     *
     *   Fool the compiler.
     *
     c                   move      *blanks       dummy             1
     c     dummy         ifne      *blanks
     c                   read      su155fm                                50
     c                   endif
     *
     c                   move      #prog         $pprg            10
     c                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   write     msgclr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     *
     *    ZMCPMQ  Clear program message queue.
     *
     c     zmcpmq        begsr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     c     zmcsbf        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     c     zmdmsg        begsr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *
     *    ZSCLR   Clear screen
     *
     c     zsclr         begsr
     c                   write     clrscr
     c                   move      *on           sclear            1
     c                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     c     zmqmsg        begsr
     c                   add       1             msgk
     c                   write     msgrec
     c                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   UT81201  Item recalculated successfully.
     *
     c     zm01          begsr
     c                   move      'UT81201'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg             4
     c                   endsr
     *----------------------------------------------------------------
     *   UT81221  Item not recalculated - No ITEMQTY record.
     *
     c     zm21          begsr
     c                   move      'UT81221'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     *----------------------------------------------------------------
     *   UT81222  Item not recalculated - Item does not exist.
     *
     c     zm22          begsr
     c                   move      'UT81222'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     *----------------------------------------------------------------
     *   UT81223  Item not recalculated - Error updating ITEMQTY.
     *
     c     zm23          begsr
     c                   move      'UT81223'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
