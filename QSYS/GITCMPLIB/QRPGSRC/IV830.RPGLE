     *----------------------------------------------------------------
     *
     *  IV830  Update inventory file to slot item/quantity - Utility
     *  16 December 2009
     *  Roxanne Harrison
     *
     *  NOTE:
     *  Program will update un-entered INVSLOT inventory records
     *  as entered by 'UTIL' using the existing slot item/quantity
     *  To be used if a year end inventory count can not be finished
     *  and needs to be marked as complete to be posted.
     *
     *  Revisions
530 A*    12/16/09 RH   5.30
     *      - Created.
     *
700aA*    08/18/16 MR   7.00a
     *      - Converted to RPGLE
     *      - Update inventory log file when INVSLOT is updated.
700bA*  09/14/16  LMC  7.00b
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
710aA*  03/23/17  LMC  7.10a
     *    - Enh: Database change to INVHSTD. Recompile only.
710bA*  12/22/17  LMC  7.10b
     *    - Enh: Database change to INVHSTD. Recompile only.
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  78        Chain indicator
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Finvslot   uf   e           k disk
     Fslot2     if   e           k disk
700aAFinvinuse  if   e           k disk
700bDF*icdcntd   uf   e           k disk
700bAFinvhstd   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D  erwhse                 1      2p 0
     D  erwhdp                 3      7
     D  erstyp                 8     12
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D forevr          s              1
     D kywhse          s              3  0
     D today           s              8  0
700bAD savdpt          s              5
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
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PJOBQ  Running from JOBQ (Y,N)
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     *                    PARM           $PJOBQ  1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   move      $pwhse        kywhse
     *    Get todays date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
700bAC* this need to happen after we have the department
     * Get Inventory In Use #
700bDC*    ikey          chain     invinuse
700bDc*                  if        %found
700bDc*                  eval      icduid = inuuid
700bDc*                  endif
530aA*  Update un-entered INVSLOT Inventory slot records.
     C     keyivs        setll     invslot
     C                   dou       forevr <> forevr
     *
     C     keyivs        reade     invslot                                79
     C                   if        *in79
     C                   leave
     C                   endif
700bAC* need to get the invinuse when the department changes
700bA /free
700bA   if savdpt <> ivswhd;
700bA     chain (kywhse: ivswhd) invinuse;
700bA     if %found(invinuse);
700bA       icduid = inuuid;
700bA     endif;
700bA     savdpt = ivswhd;
700bA   endif;
700bA /end-free
     *
     C                   if        ivsedt = 0
     C     keysl2        chain     slot2                              78
     C                   if        not *in78
     C                   eval      ivsqt1 = slstk1
     C                   eval      ivsqt2 = slstk2
     C                   eval      ivsqt3 = slstk3
     C                   movel     'UTIL'        ivseby
     C                   eval      ivsedt = today
     C                   time                    ivsetm
     C                   update    ivsrec                               77
     C                   endif
     *
700bDC*    dkey          chain     icdcntd
700bMC     dkey          chain     invhstd
700aAC                   if        %found
700aAC                   eval      icdaqty1 = slstk1
700aAC                   eval      icdaqty2 = slstk2
700aAC                   eval      icdaqty3 = slstk3
700aAc                   eval      icdadj1 = icdaqty1 - icdbqty1
700aAc                   eval      icdadj2 = icdaqty2 - icdbqty2
700aAc                   eval      icdadj3 = icdaqty3 - icdbqty3
700aAC                   if        ivsedt > 0
700aAc                   eval      icdslcnt= 'Y'
700aAc                   eval      icdsltts= %timestamp
700aAc                   endif
700aAC                   update    icdrec
700aAc                   endif
     C                   endif
     *
     C                   enddo
     *
408 A*
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *on
     C                   move      #prog         #pgmq
     *
     *  Define keys.
     *
     *    INVSLOT file (Partial key)
     *
     C     keyivs        klist
     C                   kfld                    kywhse
     *
     *    SLOT2 file
     *
     C     keysl2        klist
     C                   kfld                    ivswhs
     C                   kfld                    ivswhd
     C                   kfld                    ivsdsp
700aA*    Cycle Count History Detail
700aAC     dkey          klist
700aAc                   kfld                    icduid
700bAc                   kfld                    ivswhs
700bAc                   kfld                    ivswhd
     c                   kfld                    ivsdsp
700aA*    Inventory In Use
700aAC     ikey          klist
700aAc                   kfld                    kywhse
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     *R         $PJOBQ    IFNE 'Y'
     *R                   MOVE '1'       *IN97
     *R                   WRITEMSGCTL
     *R                   ENDIF
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq             4
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *    IV51021  Updating slot records for whse/dept/section.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IV51021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
