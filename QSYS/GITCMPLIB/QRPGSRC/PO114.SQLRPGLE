     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO114     PO header maintenance - Delete
     *  08 October, 1996
     *  Hemant Kapadia
     *
     *  SK114 - 1.00
     *
     *----------------------------------------------------------------
     *  Revisions
     *
401 A*    07/11/97  HNK  4.01
     *      - Error check added. (Cannot delete a PO, if ready for
     *        export.)
     *
414 A*    07/26/00  HNK  4.14
     *      - ZZOK routine corrected.
     *
416 A*    10/30/01  MLB  4.16
     *      - Added Super P/O cross ref file POSPO, POSPO1
     *        Revised program to remove entries from POSPO when
     *        deleting purchase orders.
     *      - Added new routine ZZSPO.
     *
417 A*    06/13/03  MLB  4.17
     *      - Enh: Revised program to check status of purchase order
     *        and if not at Open status, cancel delete.
417aA*    02/01/04  MLB  4.17a
     *      - Enh: Revised routine ZZSPO to loop when removing
     *        individual p/o from Super P/O. This change is
     *        being made since new option was added to allow single
     *        p/o to be attached to multiple p/o's.
     *
510A *   06/16/06  RMC  5.10
     *     - Delete record in POHDRM for Packers.
     *       Add logic to determine if Packers is accessing
     *       this program.
     *
640A *   03/04/12  MLB  6.40
     *     - Fix: Delete records in PODTLM.
     *     - Converted pgm to ILE.
     *     - Removed 5.10 mod done for Packer's only. All clients
     *       get POHDRM support.
     *
750 A*    10/28/21  MLB  7.50
     *      - DockVue: Added update of POSTATUS table when PO deleted.
     *      - Enh: Changed pgm to SQLRPGLE from RPGLE format.
     *
770aA*   07/19/22  TDC  770a
     *     - Add system option opdckv to control DockVue processing.
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
     Fpohdr     uf   e           k disk
     F                                     rename(phrec:record)
     Fpodtl     uf   e           k disk
416 AFpospo     uf   e           k disk
416 AFpospo1    uf   e           k disk
     F                                     rename(purec:purec1)
510A Fpohdrm    uf   e           k disk
640A Fpodtlm    uf   e           k disk
770aA*----------------------------------------------------------------
770aA*  System options
770aA*----------------------------------------------------------------
770aAD sysoptrec     E Ds                  Extname(options)
770aA*----------------------------------------------------------------
770aA*  *SYSTEM   -  System options.
770aA*----------------------------------------------------------------
770aA*
770aA* Data structure
770aA*
770aAD sysoptions      ds
770aAD  opepm                  1      1
770aAD  oprf                   2      2
770aAD  opcapc                 3      3
770aAD  opletd                 4      4
770aAD  opwrnc                 5      5
770aAD  oprg1c                 6      8  1
770aAD  oprg2c                 9     11  1
770aAD  opimpi                12     12
770aAD  opicw                 13     13
770aAD  opmpck                14     14
770aAD  oprcdy                15     15  0
770aAD  oppkdy                16     16  0
770aAD  oprths                17     19  0
770aAD  opcrhs                20     22  0
770aAD  oppohs                23     25  0
770aAD  opiahs                26     28  0
770aAD  opmshs                29     31  0
770aAD  optbjq                32     32
770aAD  opishs                33     35  0
770aAD  opishsa               33     35
770aAD  opuci                 36     36
770aAD  opwrncr               37     37
770aAD  opicwr                38     38
770aAD  optrax                39     39
770aAD  opdckv                50     50
770aAD  sysoptionsend        117    117
     *----------------------------------------------------------------
770aAD* Variables
770aAd dockvue         s               n   inz('0')
770aAD ocode           s              8
770aAD wkwhse          s              3  0
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
510A *
640 D */COPY QCOPYSRC,IL#PACKERS
     D @getcl          c                   const('GETCLIENT')
750 A*----------------------------------------------------------------
750 A*  Standard SQL variables and constants
750 A*----------------------------------------------------------------
750 A
750 A /copy qcopysrc,c#stdsql
750 A
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
     D  $pwhse                19     21  0
     D  $ppo                  22     30
     *----------------------------------------------------------------
     *  Working variables
     *
     D $msgf           s             10
     D ckfld           s              2
     D error           s              1
     D forevr          s              1
750 AD nostamp         s               z     inz
     D stop            s              1
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
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
401 AC     fileky        chain(n)  record                             79
417 AC                   select
417 A*
417 A*    Purchase order Marked for Export. Delete not allowed.
417 D*          *IN79     IFEQ *OFF
417 MC                   when      not *in79  and
401 AC                             phstat = '3'
401 AC                   exsr      zm1401
401 AC                   eval      $prtn = '*PGMQ   '
401 AC                   goto      out
417 A*
417 A*    Purchase order not at Open Status. Delete not allowed.
417 AC                   when      not *in79  and
417 AC                             phstat <> '0'
417 AC                   exsr      zm1402
417 AC                   eval      $prtn = '*PGMQ   '
417 AC                   goto      out
417 D*                    ENDIF
417 MC                   endsl
     *
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = *off
     C                   delete    record
     *
750 A /free
750 A   // Set status for DockVue
770aA   // Check system option for DockVue
770aA   if dockvue;
750 A     exec sql insert into postatus
750 A              values (:phwhse, :phpo, 'D',
750 A                      current_timestamp, :nostamp);
750  *
770aM   // if sqlstate <> '00000';
770aA   if sqlstate <> sqlSuccess;
750 A     exec sql update postatus
750 A                 set posstat = 'D',
750 A                     posupdts = current_timestamp
750 A               where poswhs = :phwhse
750 A                 and pospo = :phpo;
770aA     endif;
750 A   endif;
750 A /end-free
     C                   exsr      zzok
416 AC                   exsr      zzspo
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
401 AC     out           tag
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
510A *
510A * Get client id.
510A *
510A C                   call      @getcl
510A C                   parm                    client           10
510A *
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
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
401 A*----------------------------------------------------------------
401 A*     PO11401  cannot delete a PO that is ready for export.
401 A*
401 AC     zm1401        begsr
401 AC                   eval      #msgid = 'PO11401'
401 AC                   eval      #msgtp = '*DIAG  '
401 AC                   movea     errmsg        $md(1)
401 AC                   exsr      zmsmsg
401 AC                   eval      $pmsg = #msgk
401 AC                   endsr
417 A*----------------------------------------------------------------
417 A*     PO11402  cannot delete a PO that is not at Open status.
417 A*
417 AC     zm1402        begsr
417 AC                   eval      #msgid = 'PO11402'
417 AC                   eval      #msgtp = '*DIAG  '
417 AC                   movea     errmsg        $md(1)
417 AC                   exsr      zmsmsg
417 AC                   eval      $pmsg = #msgk
417 AC                   endsr
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
     C                   eval      error = *off
     C     fileky        setll     podtl
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     fileky        reade     podtl                                  79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   delete    podtl
     C                   endif
     C                   enddo
640 AC*
640 AC     fileky        setll     podtlm
640 AC                   eval      stop = *off
640 AC                   dou       stop = *on
640 AC     fileky        reade     podtlm
640 AC                   if        %eof(podtlm)
640 AC                   eval      stop = *on
640 AC                   else
640 AC                   delete    pdmrec
640 AC                   endif
640 AC                   enddo
640 AC*
640 DC*                  if        client = packer
510A C     fileky        chain     pohdrm                             78
510A C                   if        not *in78
510A C                   delete    phmrec
510A C                   endif
640 DC*                  endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
770aA
770aA*  Get System option.
770aA /free
770aA   ocode = '*SYSTEM ';
770aA   exec sql select * into :sysoptrec
770aA        from options
770aA        where opwhse = 0
770aA          and opcode = :ocode;
770aA
770aA   If sqlstt = sqlSuccess;
770aA     sysoptions = opdata;
770aA   else;
770aA     opdckv = 'N';
770aA   endif;
770aA
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
414 D**                   MOVE $PPO      WORK7A  7
414 D**                   MOVEAWORK7A    $MD,7
414 AC                   movea     $ppo          $md(4)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZPO     Delete corresponding Super P/O records.
416 A*
416 AC     zzspo         begsr
416 A*
416 AC                   eval      forevr = *on
416 AC                   movel     $ppo          ckfld
416 A*
416 AC                   select
416 A*
416 A*    User selected a Super P/O for deletion. Remove all entries.
416 AC                   when      ckfld = 'SP'
416 AC     fileky        setll     pospo
416 AC                   dow       forevr = forevr
416 AC     fileky        reade     pospo                                  77
416 AC                   select
416 AC                   when      *in77
416 AC                   leave
416 A*
416 AC                   other
416 AC                   delete    purec
416 AC                   endsl
416 AC                   enddo
416 A*
416 A*    User selected a Regular P/O for deletion.
416 AC                   when      ckfld <> 'SP'
416 A*
417aD*R         FILEKY    CHAINPOSPO1               77
417aAC     fileky        setll     pospo1
417aAC                   dow       forevr = forevr
417aAC     fileky        reade     pospo1                                 77
417aAC                   select
417aAC                   when      *in77
417aAC                   leave
417aA*
417aAC                   other
417aD*R         *IN77     IFEQ *OFF
416 AC                   delete    purec1
417aD*R                   ENDIF
416 AC                   endsl
416 AC                   enddo
416 AC                   endsl
416 A*
416 AC                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
PO
