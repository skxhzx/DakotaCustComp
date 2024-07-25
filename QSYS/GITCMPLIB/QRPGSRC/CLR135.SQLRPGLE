     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CLR135    Clear files for warehouse 1 - Clear
     *  07 Febuary 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    02/07/01  DAS  4.15
     *      - Created.
     *        Based on PCK135.
     *
416 A*    10/16/01  MLB  4.16
    A*      - Field added to ORRTN. Re-compile only.
416aA*    11/08/01  RH   4.16a
    A*      - File ORRTN changed, Re-compile only.
    A*      - File ORDSLCT changed, Re-compile only.
416bA*    05/23/02  RH   4.16b
    A*      - LICENSE and PORCV files changed, Re-compile only.
417aA*    07/08/03  RH   4.17a
    A*      - ORDT file changed, Re-compile only.
510 A*    11/20/06  RAH   5.10
     *      - Enh: Add POHACCP and POHHACCP.
510bA*    01/08/07  RH    5.10b
     *      - Enh: Recompile POHHACCP file key changed.
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
     fclr135fm  cf   e             workstn usropn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fpirtran   if   e           k disk
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     c     *entry        plist
     c                   parm                    $pjtyp            1
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 1.
     *
     c                   z-add     1             kywhse            3 0
     *-------------------------------------------------------------------------
     *
     *  Clear file BATCTL.
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
     *-------------------------------------------------------------------------
     *
     *  Clear file CROSSDK.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'CROSSDK '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   crossdk
     c+  where  (cdwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPADJ.
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
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPPOD.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'EXPPOD  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   exppod
     c+  where  (pedwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPPOH.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'EXPPOH  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   exppoh
     c+  where  (pehwhs = :kywhse)
     c/end-exec
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
     *  Clear file EXPRTN.
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
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPPOD.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'IMPPOD  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   imppod
     c+  where  (pidwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPPOH.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'IMPPOH  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   imppoh
     c+  where  (pihwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPRTN.
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
     *  Clear file ITEMADJ.
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
     *  Clear file ITEMEXP.
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
     *  Clear file LICENSE.
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
     *  Clear file ORDRTN.
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
     *  Clear file ORDSLCT.
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
     *  Clear file ORTNBAT
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
     *  Clear DataArea PIRBATCH.
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
     *  Clear DataArea PIRLABEL.
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
     *  Clear DataArea PIRPALET.
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
     *  Clear DataArea PIRPO#.
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
     *-------------------------------------------------------------------------
     *
     *  Clear DataArea PIRTRAN.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PIRTRAN '    w1file
     c                   write     screen1
     c                   endif
     c     *hival        setgt     pirtran
     c                   readp     pirtran                                79
     c     *in79         ifeq      *on
     c                   z-add     1             pttrn#
     c                   else
     c                   add       1             pttrn#
     c                   endif
     c     *dtaara       define    pirtran       next5             7 0
     c     *lock         in        next5
     **                   Z-ADD1         NEXT5
     c                   z-add     pttrn#        next5
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
     *-------------------------------------------------------------------------
     *
     *  Clear file PODTL.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PODTL   '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   podtl
     c+  where  (pdwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file POMFR.
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
     *-------------------------------------------------------------------------
     *
     *  Clear file POHDR.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'POHDR   '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pohdr
     c+  where  (phwhse = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file POHDTL.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'POHDTL  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pohdtl
     c+  where  (phdwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file POHHDR.
     *
     c     $pjtyp        ifeq      *on
     c                   move      'POHHDR  '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   pohhdr
     c+  where  (phhwhs = :kywhse)
     c/end-exec
     *-------------------------------------------------------------------------
     *
510 a*  Clear file POHACCP.
     *
510 ac     $pjtyp        ifeq      *on
510 ac                   move      'POHACCP '    w1file
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
510 ac     $pjtyp        ifeq      *on
510 ac                   move      'POHHACCP'    w1file
510 ac                   write     screen1
510 ac                   endif
510 ac/exec sql
510 ac+  delete
510 ac+  from   pohhaccp
510 ac+  where  (hahwhse = :kywhse)
510 ac/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file PORCV
     *
     c     $pjtyp        ifeq      *on
     c                   move      'PORCV   '    w1file
     c                   write     screen1
     c                   endif
     c/exec sql
     c+  delete
     c+  from   porcv
     c+  where  (porwhs = :kywhse)
     c/end-exec
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
     *  Clear file VSLOT.
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
     c                   open      clr135fm
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
     c                   read      clr135fm                               50
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
