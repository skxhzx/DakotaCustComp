      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*----------------------------------------------------------------
     F*
     F*  MF124     Manufacturer code decifer maintenance - Delete
     F*  24 Sept 2007
     F*  Lynn McMahon
     F*
     F*  Revisions
     F*
     F*    09/24/07  LMC  5.10
     F*      - Created
510aAF*    10/02/07  LMC  5.10a
     F*      - Fix: Correct manufacturer field size to 11 positions
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Chain indicator
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fmfrdate   uf   e           k disk
     f                                     rename(mdrec:record)
     fmfrtable  uf   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d msg             s             50    dim(1) ctdata perrcd(1)
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
510aDd* $pmfr#                19     28  0
510aDd* $pdef#                29     30  0
510aAd  $pmfr#                19     29  0
510aAd  $pdef#                30     31  0
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

     *----------------------------------------------------------------
     *  Variables
     D $pcodea         s             10
     D forevr          s              1
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
     C*
     C* Get client id.
     C*
     c                   call      @getcl
     c                   parm                    client           10
     C*
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
     c     fileky        setll     mfrtable
     c                   dow       forevr = forevr
     c     fileky        reade     mfrtable
     c                   If        %eof
     c                   leave
     c                   endif
     c                   delete    mtrec
     c                   enddo
      *
      *
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pmfr#
     c                   kfld                    $pdef#
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     c     zzok          begsr
     c                   move      *blanks       $md
     c                   movea     msg(1)        $md(1)
     c                   Eval      $pcodea = %Trim(%EditC($pdef#:'Z'))
     c                   movea     $pcodea       $md(19)
     c                   exsr      zm9803
     c                   move      '*OK     '    $prtn
     c                   endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Mfr Code Def#
