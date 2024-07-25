510bA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  Note: This program uses message CPF9897 from message file
     *        QCPFMSG. Error routine ZMSMSG has been changed to use
     *        the CPF message file.
     *
     *----------------------------------------------------------------
     *
     *  LF131     Label format set maintenance: Types - Import
     *  06 April 2000
     *  Dave Sommerville
     *
     *  Revisions
     *
414 A*    04/06/00  DAS  4.14
     *      - Created.
     *
414aA*    04/19/00  DAS  4.14a
     *      - Revised to handle a special numeric code for the
     *        transaction number (1111111) and the label number
     *        (2222222). '1111111' will be converted to code
     *        '<10--->' and '2222222' will be converted to code
     *        '<52--->'.
414bA*    06/13/00  DAS  4.14b
     *      - '2222222' is now converted to <57--->.
     *
510aA*    05/17/07  DAS  5.10a
     *      - Revised to override IMPLFMT to file with format name.
     *
510bA*    07/14/07  DAS  5.10b
     *      - Converted to ILE.
     *      - Added library to file override.
     *      - Updated error messages.
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
     Fimplfmt   if   e           k disk    usropn
     FLblfmtd   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
414aAD a75             s              1    dim(75)
510aAD a80             s              1    dim(80)
     D msg             s             50    dim(3) ctdata perrcd(1)
510aAD ovrdbf          s             80    dim(1) ctdata perrcd(1)
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
     D  $pset                 19     24
     D  $pfmt                 25     32
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
     D #cpf            c                   const('QCPFMSG   ')
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
     *  Variables
     *
     D $msgf           s             10
     D error           s              1
     D forevr          s              1
     D p1              s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for import.
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
510aAC                   exsr      zzopen
     C                   exsr      zzdel
     C                   exsr      zzimp
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
     C                   eval      $msgf = #cpf
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
     *     CPF9897  Generic message.
     *
     C     zm9897        begsr
     C                   eval      #msgid = 'CPF9897'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
414aA*----------------------------------------------------------------
414aA*
414aA*  ZZCHK    Check for tran/label codes and replace.
414aA*
414aAC     zzchk         begsr
     *
     *   Scan for transaction code
     *
     C     '1111111'     scan      lfdstr        p1                       50
     C                   if        *in50
     C                   movea     lfdstr        a75
     C                   movea     '<10--->'     a75(p1)
     C                   movea     a75           lfdstr
     C                   endif
     *
     *   Scan for label code
     *
     C     '2222222'     scan      lfdstr        p1                       50
     C                   if        *in50
     C                   movea     lfdstr        a75
414bD**                   MOVEA'<52--->' A75,P1
414bMC                   movea     '<57--->'     a75(p1)
     C                   movea     a75           lfdstr
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL    Delete existing script records
     *
     C     zzdel         begsr
     C                   eval      error = *off
     *
     *   Delete detail records
     *
     C     fileky        setll     lblfmtd
     C                   dow       forevr = forevr
     C     fileky        reade     lblfmtd                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    lfdrec
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZIMP    Import script records
     *
     C     zzimp         begsr
     C                   eval      error = *off
     *
     C                   eval      lfdseq = 0
     C                   dow       forevr = forevr
     C                   read      implfmt                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      lfdset = $pset
     C                   eval      lfdfmt = $pfmt
     C                   add       1             lfdseq
     C                   eval      lfdstr = ilstr
414aAC                   exsr      zzchk
     C                   write     lfdrec
     C                   enddo
     *
     C                   if        lfdseq = 0
     C                   eval      error = *on
     C                   exsr      zznr
     C                   else
     C                   exsr      zzok
     C                   endif
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
     C                   kfld                    $pset
     C                   kfld                    $pfmt
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNR     Send back no record error message.
     *
     C     zznr          begsr
     C                   eval      $md = *blanks
510bDC**                 movea     msg(3)        $md(1)
510bAC                   eval      errmsg = 'ERROR: no records '
510bAC                                    + 'found in LBL'
510bAC                                    + %trim($pset)
510bAC                                    + '/'
510bAC                                    + %trim($pfmt)
     C                   exsr      zm9897
     C                   eval      $prtn = '*PGMQ   '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      errmsg = *blanks
510bDC**                 eval      errmsg = msg(1)
510bDC**   errmsg        cat       $pfmt:1       errmsg
510bDC**   errmsg        cat       msg(2):1      errmsg
510bAC                   eval      errmsg = 'Script for '
510bAC                                    + 'LBL'
510bAC                                    + %trim($pset)
510bAC                                    + '/'
510bAC                                    + %trim($pfmt)
510bAC                                    + ' imported successfully.'
     C                   movea     errmsg        $md(1)
     C                   exsr      zm9897
     C                   eval      $prtn = '*OK     '
     C                   endsr
510aA*----------------------------------------------------------------
510aA*
510aA*  ZZOPEN  Open database file.
510aA*
510aAC     zzopen        begsr
     *
     *      Override database file.
     *
510bM*          OVRDBF FILE(IMPLFMT) TOFILE(LBL$pset/$pfmt)
     *
510bDC**                 movea     ovrdbf(1)     a80
510bDC**                 movea     $pfmt         a80(29)
510bDC**                 movea     a80           qcmd

510bAC                   eval      qcmd = 'ovrdbf'
510bAC                                  + ' file(implfmt)'
510bAC                                  + ' tofile(LBL'
510bAC                                  + %trim($pset)
510bAC                                  + '/'
510bAC                                  + %trim($pfmt)
510bAC                                  + ')'

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open database file.
     *
     C                   open      implfmt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Script for
imported successfully
ERROR: No records found in import file IMPLFMT
**
OVRDBF FILE(IMPLFMT) TOFILE(xxxxxxxx)
