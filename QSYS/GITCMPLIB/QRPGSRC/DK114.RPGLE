     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK114     Dock door maint - Delete
     *  05 November 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*    11/05/01  DAS  4.16
     *      - Created.
416aA*    04/12/02  MLB  4.16a
     *      - Removed %CHAR from msg build. Replaced with trim left
     *        and edit Z.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocdoor   uf   e           k disk
     F                                     rename(ddrec:record)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D msg             s             50    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdoor                27     29  0


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D enter           s              5  0
     D error           s               n
     D forevr          s               n

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     fileky        chain     record                             79
 1B  C                   if        not *in79
     C                   exsr      zzdel
 2B  C                   if        error = '0'
     C                   delete    record
     C                   exsr      zzok
 2E  C                   endif
 1X  C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
 1E  C                   endif
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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

     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *----------------------------------------------------------------

     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *----------------------------------------------------------------

     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *  ZZDEL    Delete corresponding records.
     *----------------------------------------------------------------

     C     zzdel         begsr
     C                   move      '0'           error
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for main file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pdoor
     C                   kfld                    $pwhdp

     C                   move      *off          forevr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZOK     Send back "successful" message.
     *----------------------------------------------------------------

     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   eval      #msgdt = %trim(msg(1))
     C                             + ' ' + %trim($pwhdp)
416aDC*                            + '/' + %char($pdoor)
416aMC                             + '/' + %triml(%editc($pdoor: 'Z'))
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr

     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
**
Dock door
