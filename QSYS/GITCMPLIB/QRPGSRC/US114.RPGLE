650aA /copy *libl/qcopysrc,hspecs
500bA*----------------------------------------------------------------
500bA*  Multilingual Version
500bA*  Every screen and message has a corresponding Spanish version.
500bA*  Any changes must be made to both languages.
500bA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  US114     User Code Table Maintenance - Delete
     *  07 July, 1994
     *  Hemant KApadia
     *
     *  SK114 - 1.00
     *
     *  Revisions
     *
     *    01/10/96  DAS  2.10e
     *      - Revised to work with EPM version of PIRUSER file.
     *
     *    11/19/96  RH   2.17
     *      - Revised to work with PIRUSER file for EPM or not.
     *        If not EPM, fields are non-display and protected.
500 A*
     *    03/22/05  DAS  5.00
     *      - Added file PIRUSERA
500aA*
     *    05/14/06  DAS  5.00a
     *      - Recompiled because USALNG field added to PIRUSERA.
     *
500bA*    06/07/06  JCJ  5.00b
     *      - Added Multilingual logic.
     *
640aA*    02/06/12  RTR  6.40a
     *      - Converted to ILE.
     *      - Added delete of GLOUSR.
     *
650aA*    03/26/14  RBD  6.50a
     *      - Fix: The user should only be deleted from GLOUSR if
     *        gurel = EQ and guvalue = uswhse.  If gurel = LS, the
     *        uswhse should be removed from guvalue, and if that
     *        leaves only one whse in guvalue, gurel should be
     *        changed from LS to EQ.
     *      - Also added logic when searching guvalue to first determine
     *        whether the whse being added/updated is a length of 1,
     *        2 or 3.  For example, if whse=5, we must check to see if
     *        it's in pos 1 of guvalue by searching with '5 ', and if
     *        it's not in pos 1, then search with ' 5 '.  Without this
     *        logic, whse 5 would give a false positive if whse 25
     *        were the last whse listed in guvalue.
710aA*    06/14/17  LMC  7.10a
     *      - Fix: Program was getting error trying to delete, if the
     *        glousr record didn't exist. This only happened if it was
     *        not the first employee deleted in this job. The values
     *        from the previous employee that was deleted were being
     *        used to determine the logic for the delete.
710aA*    12/19/17  MR
     *      - Recompiled due to database change to PIRUSERA
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiruser   uf   e           k disk
     F                                     rename(usrec:record)
500 AFpirusera  uf   e           k disk
640aAFglousr    uf a e           k disk    usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
     D msgsp           s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pcode                19     28
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
650aA* GUVALUE data structure
650aAD                 ds
650aAD  guvalue                1     30
650aAD  guval1                 1      1
650aAD  guval2                 1      2
650aAD  guval3                 1      3
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $MSGF           s             10
     D ERROR           s              1
650aAD svwhse          s             30a
650aAD svwhse1         s             30a
650aAD svwhse2         s             30a
640aAD webupdate       s              1n
650aAD whsLength       S              3s 0
640aAD wkpos           s              3s 0
640aAD wkpos2          s              3s 0
640aAD wkpos3          s              3s 0
640aAD wkwhse          s              3a
650aAD wkwhs1B         s              2a
650aAD wkwhsB1B        s              3a
650aAD wkwhs2B         s              3a
650aAD wkwhsB2B        s              4a
650aAD wkwhs3B         s              4a
650aAD wkwhsB3B        s              5a
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = '0'
     C                   delete    record
     C                   exsr      zzok
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
     C                   return
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   move      #msgsp        $msgf
500bAC                   other
     C                   move      #msgf         $msgf
500bAC                   endsl
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
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL    Delete corresponding records.
     *
     C     zzdel         begsr
     C                   move      '0'           error
650aAC                   eval      svwhse = %char(uswhse)
500 AC     fileky        chain     pirusera                           78
500 AC                   if        not *in78
500 AC                   delete    usarec
500 AC                   endif
640aA*
640aA*   Delete GLOUSR file *IF OPEN*.
650aA*   AND gurel = EQ and guvalue = uswhse
640aA*
640aAC                   if        webupdate = *on
640aAC     uscode        chain     glousr                             78
650aDC**                 if        not *in78
650aDC**                 delete    gurec
650aDC**                 endif                                                  *** not *IN78

710aA /free
710aA   if not %found(glousr);
710aA     leavesr;
710aA   endif;
710aA /end-free
650aAC                   select

650aAC                   when      gurel = 'EQ'
650aAC                   if        guvalue = svwhse
650aAC                   delete    gurec
650aAC                   endif

650aAC                   when      gurel = 'LS'
650aAC                   eval      whsLength = %Len(%Trim(%char(uswhse)))

650aAC                   if        whsLength = 1
650aAC                   exsr      zzWhsLen1
650aAC                   endif

650aAC                   if        whsLength = 2
650aAC                   exsr      zzWhsLen2
650aAC                   endif

650aAC                   if        whsLength = 3
650aAC                   exsr      zzWhsLen3
650aAC                   endif

650aAC                   endsl

640aAC                   endif
640aA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
500bA*
500bA*   Get employee options.
500bA*
500bAC                   call      'GETUSER'
500bAC                   parm      #user         e$code           10
500bAC                   parm                    e$whse            3 0
500bAC                   parm                    e$emp#            5 0
500bAC                   parm                    e$fnam           15
500bAC                   parm                    e$init            1
500bAC                   parm                    e$lnam           20
500bAC                   parm                    e$whdp            5
500bAC                   parm                    e$styp            1
500bAC                   parm                    e$shft            6
500bAC                   parm                    e$crew            6
500bAC                   parm                    e$nhrs            3 1
500bAC                   parm                    e$rtn             8
500bAC                   parm                    e$bpu             1
500bAC                   parm                    e$lng             2
500bAC                   if        e$rtn <> '*OK'
500bAC                   eval      e$lng = 'EN'
500bAC                   endif
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pcode
640aA*
640aA*  Try to open GLOUSR for Web Users.
640aA*
640aAC                   if        not %OPEN(GloUsr)
640aAC                   Open(e)   GloUsr
640aAC                   if        %Error()
640aAC                   eval      webupdate = *off
640aAC                   else
640aAC                   eval      webupdate = *on
640aAC                   endif
640aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     msgsp(1)      $md(1)
500 AC                   other
     C                   movea     msg(1)        $md(1)
500 AC                   endsl
     C                   movea     $pcode        $md(11)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
650aA*
650aA*  ZZRELATION   Chg gurel to 'EQ' if only 1 whse left in guvalue.
650aA*
650aAC     zzrelation    begsr

     C                   eval      wkpos = %scan(' ': guvalue)

     C                   if        wkpos > 0
     C                   if        %subst(guvalue:(wkpos+1)) = *blanks
     C                   eval      gurel = 'EQ'
     C                   endif
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
650aA*
650aA*  ZZWHSLEN1   Update global user fields when whse length = 1
650aA*
650aAC     zzWhsLen1     begsr

     C                   eval      wkwhs1B  = %trim(%char(uswhse))
     C                   eval      wkwhsB1B = ' ' + %trim(%char(uswhse)) + ' '
     C                   eval      wkpos = %scan(wkwhs1B: guvalue)
     C                   if        wkpos <> 1
     C                   eval      wkpos = %scan(wkwhsB1B: guvalue)
     C                   endif

     C                   select

     C                   when      wkpos = 1
     C                   eval      guval1 = ' '
     C                   eval      guvalue = %trim(guvalue)
     C                   exsr      zzrelation
     C                   update    gurec

     C                   when      wkpos > 1
     C                   eval      %subst(guvalue: (wkpos+1): 1) = ' '
     C                   if        %subst(guvalue:(wkpos+1)) <> *blanks
     C                   eval      svwhse1 = %subst(%trim(guvalue):1:wkpos)
     C                   eval      svwhse2 = %subst(%trim(guvalue):(wkpos+1))
     C                   eval      guvalue =
     C                             %trim(svwhse1) +
     C                             ' ' +
     C                             %trim(svwhse2)
     C                   endif

     C                   exsr      zzrelation
     C                   update    gurec

     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
650aA*
650aA*  ZZWHSLEN2   Update global user fields when whse length = 2
650aA*
650aAC     zzWhsLen2     begsr

     C                   eval      wkwhs2B  = %trim(%char(uswhse))
     C                   eval      wkwhsB2B = ' ' + %trim(%char(uswhse)) + ' '
     C                   eval      wkpos = %scan(wkwhs2B: guvalue)
     C                   if        wkpos <> 1
     C                   eval      wkpos = %scan(wkwhsB2B: guvalue)
     C                   endif

     C                   select

     C                   when      wkpos = 1
     C                   eval      guval2 = '  '
     C                   eval      guvalue = %trim(guvalue)
     C                   exsr      zzrelation
     C                   update    gurec

     C                   when      wkpos > 1
     C                   eval      %subst(guvalue: (wkpos+1): 2) = '  '
     C                   if        %subst(guvalue:(wkpos+1)) <> *blanks
     C                   eval      svwhse1 = %subst(%trim(guvalue):1:wkpos)
     C                   eval      svwhse2 = %subst(%trim(guvalue):(wkpos+1))
     C                   eval      guvalue =
     C                             %trim(svwhse1) +
     C                             ' ' +
     C                             %trim(svwhse2)
     C                   endif

     C                   exsr      zzrelation
     C                   update    gurec

     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
650aA*
650aA*  ZZWHSLEN3   Update global user fields when whse length = 3
650aA*
650aAC     zzWhsLen3     begsr

     C                   eval      wkwhs3B  = %trim(%char(uswhse))
     C                   eval      wkwhsB3B = ' ' + %trim(%char(uswhse)) + ' '
     C                   eval      wkpos = %scan(wkwhs3B: guvalue)
     C                   if        wkpos <> 1
     C                   eval      wkpos = %scan(wkwhsB3B: guvalue)
     C                   endif

     C                   select

     C                   when      wkpos = 1
     C                   eval      guval3 = '   '
     C                   eval      guvalue = %trim(guvalue)
     C                   exsr      zzrelation
     C                   update    gurec

     C                   when      wkpos > 1
     C                   eval      %subst(guvalue: (wkpos+1): 3) = '   '
     C                   if        %subst(guvalue:(wkpos+1)) <> *blanks
     C                   eval      svwhse1 = %subst(%trim(guvalue):1:wkpos)
     C                   eval      svwhse2 = %subst(%trim(guvalue):(wkpos+1))
     C                   eval      guvalue =
     C                             %trim(svwhse1) +
     C                             ' ' +
     C                             %trim(svwhse2)
     C                   endif

     C                   exsr      zzrelation
     C                   update    gurec

     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
User Code
** Descsp
Codigo de usuario
