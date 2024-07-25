      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TM114     Truck maintenance - Delete
     *  22 May, 1997
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520aA*    02/28/09  DAS  5.20a  P#00150
     *      - Recompiled because of change to ZONED
     *
530 A*    11/10/09  JCJ  5.10
     *      - Enh: Converted to ILE.
     *      - Enh: Recomplied for database change to TRUCKH
     *
530 A*    11/10/09  JCJ  5.10a
     *      - Enh: add an edit to not allow a delete if Template is
     *             assigned to a truck.
     *
530 A*    02/13/08  JCJ  5.20  P00013
     *      - Fix: When deleting a truck, do not delete the zone template
     *             detail.
     *
530 A*    09/04/09  JCJ  5.20a
     *      - Enh: add an edit to not allow a delete if a default     ate
     *             truck exists in file TRUCKDFT.
     *
720aA*    10/14/18  DAS  7.20a
     *      -  Recompiled because of new ZONED fields
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
     Ftruckh    uf   e           k disk
     F                                     rename(threc:record)
530 AFtruckh2   if   e           k disk    prefix(x)
     Ftruckd    uf   e           k disk
     Fzoneh     uf   e           k disk
     Fzoned1    uf   e           k disk
     Foptionz   uf   e           k disk
530 AFtruckdft1 if   e           k disk    rename(TDREC:TDDFT) prefix(y)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
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
     D  $ptruk                22     31
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  ertnum                 1      4p 0
     D  erdesc                 5     24
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D error           s              1
     D forevr          s              1
     D ptruk           s             10
     D w1zcod          s              8
530 AD $ptmpl          s             10
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
     C                   eval      forevr = *off
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
530 A*----------------------------------------------------------------
530 A*   PIR9913  Defualt truck exists
530 A*
530 AC     zm9913        begsr
530 AC                   eval      #msgid = 'PIR9913'
530 AC                   eval      #msgtp = '*DIAG  '
530 AC                   movea     errmsg        $md(1)
530 AC                   exsr      zmsmsg
530 AC                   eval      $pmsg = #msgk
530 AC                   endsr
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
530 A*
530 A*   Delete not allowed if default truck exists.
530 A*
530 AC     tdkey         setll     truckdft1
530 AC                   if        %equal(truckdft1)
530 AC                   exsr      zm9913
530 AC                   eval      $prtn = '*PGMQ   '
530 AC                   eval      error = *on
530 AC                   goto      enddel
530 AC                   endif
530 A*
530 A*   Delete Zone detail records first.
530 A*
530 AC     tkkey         setll     truckh2
530 AC                   dow       forevr = forevr
530 AC     tkkey         reade     truckh2
530 AC                   if        %eof(truckh2)
530 AC                   leave
530 AC                   endif
530 A*
530 AC                   if        xthztmp = $ptruk
530 AC                   exsr      zm75
530 AC                   eval      $prtn = '*PGMQ   '
530 AC                   eval      error = *on
530 AC                   goto      enddel
530 AC                   iter
530 AC                   endif
530 A*
530 AC                   enddo
     *
     *   Truck detail records first.
     *
     C     tdkey         setll     truckd
     C                   dou       *in79
     C     fileky        reade     truckd                               7879
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   if        not *in79
     C                   delete    tdrec                                75
     C                   endif
     C                   enddo
     *
     *   ZONEH and ZONED records next.
     *
530 AC                   if        thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   goto      enddel
530 AC                   else
530 AC                   eval      $ptmpl =  $ptruk
530 AC                   endif
     *
     C     zhkey         setll     zoneh
     C                   dou       forevr <> forevr
     C     zhkey         reade     zhrec                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *   Delete Zone detail records first.
     C     zdkey         setll     zoned1
     C                   dou       *in77
     C     zdkey         delete    zdrec                              77
     C                   enddo
     *
     C                   delete    zhrec
     C                   enddo
     *
     *   Delete OPTIONZ records LAST.
     *
     C                   eval      *in77 = *off
     C                   eval      w1zcod = '*PICK   '
     C     opkey         setll     optionz
     C                   dou       *in77
     C     opkey         delete    opzrec                             77
     C                   enddo
     *
     C                   eval      *in77 = *off
     C                   eval      w1zcod = '*PICKLBL'
     C     opkey         setll     optionz
     C                   dou       *in77
     C     opkey         delete    opzrec                             77
     C                   enddo
     *
     C     enddel        endsr
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
     C                   kfld                    $ptruk
     *
     *  Define partial key for TRUCKD file.
     *
     C     tdkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     *
     *  Define partial key for ZONEH file.
     *
     C     zhkey         klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     *
     *  Define partial key for ZONED1 file.
     *
     C     zdkey         klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     *
     *  Define partial key for OPTIONZ file.
     *
     C     opkey         klist
     C                   kfld                    w1zcod
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
530 A*
530 A*  Define partial key for TRUCKD file.
530 A*
530 AC     tkkey         klist
530 AC                   kfld                    $pwhse
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   eval      ptruk = $ptruk
     C                   movea     ptruk         $md(7)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Truck
