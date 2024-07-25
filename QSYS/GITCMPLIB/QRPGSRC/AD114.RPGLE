     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*----------------------------------------------------------------
     F*
     F*  AD114     Inventory adjustment code maintenance - Delete
     F*  21 June 1993
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*    07/26/93  DAS
     F*      - Sending back "successful" message with return code *OK.
     F*
416 AF*    10/29/01  DAS  4.15
     F*      - Added file ADJMISC.
     F*      - Added logic to delete corresponding record from ADJMISC
     F*
510 AF*    06/16/06  RMC  5.10
     F*      - Enh: Display Packers verion of SCREEN.
     F*             Add logic to determine if Packers is accessing
     F*             this program.
510aAF*    09/20/06  RAH  5.10a
     F*      - Enh: Convert to RPGLE.  Change client check.
520aAF*    11/12/08  RH   5.20a
     F*      - Enh: Can not delete Dakota special codes.
710aAF*    06/23/17  JCJ  7.10a
     F*      - Enh: Added Dakota special code 'X1' to 520a change.
730 AF*    11/04/19  MLB  7.30
     F*      - Enh: Added Dakota special code 'XS' to 520a change.
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Chain indicator
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fadjcode   uf   e           k disk
     f                                     rename(adrec:record)
416 Afadjmisc   uf   e           k disk
510  fsapmove1  uf   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d msg             s             50    dim(1) ctdata perrcd(1)
510  D*
510a  /COPY QCOPYSRC,ID#PACKERS
     d @getcl          c                   const('GETCLIENT')
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $pcode                19     20
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   Not used
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains unique key for delete.
     C*
     C*    Returned Parameters
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*              *OK      - Record deleted successfully.
     C*                         Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $parms
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   exsr      zzdel
     c     error         ifeq      *off
     c                   delete    record
     c                   exsr      zzok
     c                   end
     c                   else
     c                   exsr      zm75
     c                   move      '*PGMQ   '    $prtn
     c                   end
     c                   return
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
510 AC*
510 AC* Get client id.
510 AC*
510 Ac                   call      @getcl
510 Ac                   parm                    client           10
510 AC*
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
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
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     PIR7975  Error while deleting record.
     C*
     c     zm75          begsr
     c                   move      'PIR7975'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
520a C*----------------------------------------------------------------
520a C*     IT11220  Can not delete record.
520a C*
520a c     zm1220        begsr
520a c                   move      'IT11220'     #msgid
520a c                   move      '*DIAG  '     #msgtp
520a c                   movea     errmsg        $md(1)
520a c                   exsr      zmsmsg
520a c                   move      #msgk         $pmsg
520a c                   endsr
     C*----------------------------------------------------------------
     C*     PIR9803  Deleted record successfully.
     C*
     c     zm9803        begsr
     c                   move      'PIR9803'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDEL    Delete corresponding records.
     C*
     c     zzdel         begsr
     c                   move      *off          error             1
520a c                   if        $pcode = 'MO' or
520a c                             $pcode = 'MP' or
710aMc                             $pcode = 'MV' or
710aAc                             $pcode = 'X1'
730 Ac                             or $pcode = 'XS'
520a c                   move      *on           error
520a c                   exsr      zm1220
     CSR                 move      '*PGMQ   '    $prtn
520a c                   endif
520a c     error         cabeq     *on           enddel
416 Ac     fileky        chain     adjmisc                            78
510  C*416       *IN79     IFEQ *OFF
510 Ac     *in78         ifeq      *off
416 Ac                   delete    admrec
416 Ac                   endif
      *
510a c     client        ifeq      packers
510  c     fileky        chain     sapmove1                           78
510  c     *in78         ifeq      *off
510  c                   delete    spmrec
510  c                   endif
510  c                   endif
      *
520aMc     enddel        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pcode
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     c     zzok          begsr
     c                   move      *blanks       $md
     c                   movea     msg(1)        $md(1)
     c                   movea     $pcode        $md(17)
     c                   exsr      zm9803
     c                   move      '*OK     '    $prtn
     c                   endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Adjustment code
