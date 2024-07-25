     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PIREXP    Process Dakota Files to Export Info to Host
     *  11 April 2007
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    04/11/07  MLB  5.10
     *      - Created.
     *
520 A*    08/11/08  MLB  5.20
     *      - Fix: Revised program to set KYPHSTAT='3' for p/o's
     *        ready to export.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fitemadj2  if   e           k disk
     Foptions   if   e           k disk
     Forrtn4    if   e           k disk
     Fpohdr2    if   e           k disk
     Frtehed2   if   e           k disk

     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  *FTPEXP   -  FTP Export options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for importing (Y,N)
     *    OPSRVR  -  FTP Export Server name
     *    OPUSER  -  FTP Export User id
     *    OPPWD   -  FTP Export Password
     *    OPPATH  -  Path for remote file
     *
     * Data structure
     *
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  oppath                64     95
     D  optend               117    117
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D                 ds
     D errmsg                  1    512
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *
     D #msgf           c                   const('PIRMSGF   ')
     D $msgf           s             10
     D #msgid          s              7
     D #msgk           s              4
     D #msgkey         s              4  0
     D #msgtp          s              7
     D #pgmq           s             10
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D error           S              1A   inz('0')
     D forever         S              1A   inz('1')
     D exporttype      S              1A
     D kyphstat        S                   like(phstat)
     D kyrhstat        S                   like(rhstat)
     D kytype          S                   like(rhtype)
     D msg             S             52A
     D $pcmd           S              8A
     D $prtid          S                   like(rhrtid)
     D $prte           S                   like(rhrte)
     D $preturn        S              8A
     D stserr          S              1A   inz('0')
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse        Warehouse number
     *      $pruntimenv   Run-time environment
     *                    *PROD - Production libraries
     *                    *TEST - Test libraries
PAK A*                    *SAPPROD - SAP Production PIR200PRDF
PAK A*                    *SAPQA   - SAP QA PIR200TSTF
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pruntimenv      10

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------
     *
     *      Check for item adjustments to export
     C                   exsr      zzprocadj
     *
     *      Check for customer returns to export
     C                   exsr      zzprocrtn
     *
     *      Check for purchase orders to export
     C                   exsr      zzprocpo
     *
     *      Check for regular customer orders to export
     C                   exsr      zzprocreg
     *
     *      Check for will-call customer orders to export
     C                   exsr      zzprocwill

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Retrieve Export Options record.
     C                   exsr      zzgetop
     *
     *   Define partial key for ITEMADJ2 file
     *
     C     iakey         klist
     C                   kfld                    $pwhse
     *
     *   Define partial key for ORRTN4 file
     *
     C     orkey         klist
     C                   kfld                    $pwhse
     *
     *   Define partial key for POHDR2 file
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyphstat
     *
     *   Define partial key for RTEHED2 file
     *
     C     rhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyrhstat
     C                   kfld                    kytype
     *
     *   Define full key for OPTIONS file
     *
     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETOP  Get Import Options Record.
     *
     C     zzgetop       begsr
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*FTP    '
     *
     C     keyop         chain     options
     C                   select
     C                   when      not %found(options)
     C                   eval      opsrvr = ' '
     C                   eval      oppath = ' '
     C                   eval      opftp  = 'N'
     C                   eval      opuser = ' '
     C                   eval      oppwd  = ' '
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCADJ   Process Item Adjustments for export
     *
     C     zzprocadj     begsr
     *
     *      Check for item adjustments ready for export.
     C                   eval      $pcmd    = '*ADJUST '
     *
     C     iakey         setll     itemadj2
     *      Item adjustments ready for export.
     C                   if        %equal(itemadj2)
     C                   exsr      zzsbmexp
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCPO    Process Purchase Orders for export
     *
     C     zzprocpo      begsr
     *
     *      Check for purchase orders ready for export.
     C                   eval      $pcmd    = '*PO     '
520 AC                   eval      kyphstat = '3'
     *
     C     phkey         setll     pohdr2
     *      Purchase orders ready for export.
     C                   if        %equal(pohdr2)
     C                   exsr      zzsbmexp
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCRTN   Process Customer Returns or export
     *
     C     zzprocrtn     begsr
     *
     *      Check for customer returns ready for export.
     C                   eval      $pcmd    = '*RETURN '
     *
     C     orkey         setll     orrtn4
     *      Customer returns ready for export.
     C                   if        %equal(orrtn4)
     C                   exsr      zzsbmexp
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCREG   Process Regular Customer Orders for export
     *
     C     zzprocreg     begsr
     *
     *      Check for regular customer orders ready for export.
     C                   eval      $pcmd    = '*REGULAR'
     *
     C                   eval      kyrhstat = '5'
     C                   eval      kytype  = ' '
     C     rhkey         setll     rtehed2
     C                   dow       forever = forever
     C     rhkey         reade     rtehed2
     C                   select
     C                   when      %eof(rtehed2)
     C                   leave
     *
     C                   other
     C
     *
     *      Set route inuse so it can be exported.
     C                   exsr      zzsetinuse
     C                   if        stserr = *off
     C                   eval      $prtid = rhrtid
     C                   eval      $prte = rhrte
     *
     *      Customer orders ready for export.
     C                   exsr      zzsbmexp
     C                   endif
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCWILL  Process Will-Call Orders for export
     *
     C     zzprocwill    begsr
     *
     *      Check for Will-Call orders ready for export.
     C                   eval      $pcmd    = '*WILLCAL'
     *
     C                   eval      kyrhstat = '5'
     C                   eval      kytype   = 'W'
     C     rhkey         setll     rtehed2
     C                   dow       forever = forever
     C     rhkey         reade     rtehed2
     C                   select
     C                   when      %eof(rtehed2)
     C                   leave
     *
     C                   other
     *
     *      Set route inuse so it can be exported.
     C                   exsr      zzsetinuse
     C                   if        stserr = *off
     C                   eval      $prtid = rhrtid
     C                   eval      $prte  = rhrte
     *
     *      Will-Call Customer orders ready for export.
     C                   exsr      zzsbmexp
     C                   endif
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSETINUSE  Set Inuse Flag for Route being exported.
     *
     C     zzsetinuse    begsr
     *
     C                   eval      stserr = *off
     *
     C                   eval      $icmd = '*INUSE4 '
     C                   call      'CHKIUSE'
     C                   parm                    $icmd             8
     C                   parm      rhwhse        $iwhse            3 0
     C                   parm      rhrtid        $irtid            5
     C                   parm      *blanks       $irtn             8
     *
     C                   select
     *      Route not available for export.
     C                   when      $irtn = '*ERROR  '
     C                   eval      stserr = *on
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSBMEXP  Submit Export Job for Processing.
     *
     C     zzsbmexp      begsr
     *
     C                   call      'PIRSBMEXCL'
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $prte
     C                   parm                    $pruntimenv
     *
     C                   endsr
