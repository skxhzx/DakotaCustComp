      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETSHORTS   Get total quantity shorted for transaction
     *  21 November 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    11/21/06  MLB  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frunner5   if   e           k disk
     Foptions   if   e           k disk
     *
     *----------------------------------------------------------------
     *  *VOICE  -  PIR Voice options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPINCP  -  Include pack description (Y/N)
     *    OPCRTR  -  Create RUNNER entries for shorts (Y/N)
     *    OPUPLV  -  Update Label with quantity picked during Voice
     *               selection (Y/N)
     *               NOTE: Any change to this field will cause OPUPLR
     *                     in the *RUNNER options record to be updated.
     *    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
     *    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
     *    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
     *               NOTE: Any change to this field will cause OPCLRF
     *                     in the *RUNNER options record to be updated.
     *    OPVMLT  -  Allow multiple transaction (Y/N)
     *    OPVSPN  -  Speak pallet number (Y/N)
     *    OPVSPZ  -  Speak pallet zone (Y/N)
     *    OPVSLW  -  Speak large quantity warning (Y/N)
     *    OPVSUW  -  Speak unit of measure change warning (Y/N)
     *
     * Data structure
     *
     *----------------------------------------------------------------

     D opvdta          ds
     D  opincp                 1      1
     D  opcrtr                 2      2
     D  opuplv                 3      3
     D  opvmrg                 4      4
     D  opoutf                 5      5
     D  opfclr                 6      6
     D  opvmlt                 7      7
     D  opvspn                 8      8
     D  opvspz                 9      9
     D  opvslw                10     10
     D  opvcep                11     11
     D  opvssn                12     12
     D  opvcpz                13     13
     D  optend               117    117

     *----------------------------------------------------------------
     *  Working variables
     *
     D Forever         s              1    inz('1')
     D Hold_warehouse  s              3  0 inz(-999)

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PCMD    -  *TOTSHRT - Accumulate total short qty
     *     $PWHSE   -  Warehouse number
     *     $PTRN#   -  Transaction number
     *
     *  Output parameters
     *
     *     $PSHORTQ -  Total quantity shorted on transaction
     *     $PRETURN -  Return code
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptrn#            7 0
     C                   parm                    $pshortq          7 0
     C                   parm                    $preturn          8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   if        $pwhse = Hold_warehouse
     C                   exsr      zzgetop
     C                   eval      Hold_warehouse = $pwhse
     C                   endif

     C                   eval      $pshortq = 0
     C                   select
     C                   when      $pcmd = '*TOTSHRT'
     C                   exsr      CalcTotShort
     C                   endsl

     C                   return
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
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
     *   Define full key for OPTIONS file
     *
     C     *like         define    opcode        kycode
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    kycode
     *
     *   Define full key for RUNNER5 file
     *
     C     keyru         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  CALCTOTSHORT   Calculate total quantity shorted on transaction
     *
     C     CalcTotShort  begsr
     *
     C     keyru         setll     runner5
     C                   dow       forever = forever
     C     keyru         reade     runner5
     C                   select
     C                   when      %eof(runner5)
     C                   leave

     *      Omit Out Runner types.
     C                   when      rutype = 'U'
     *      or deleted Runner flags.
     C                             or rustat = 'D'
     C                   iter

     *      Process Runner flag...

     *      When Voice option set to update Label record &
     *      Runner flag entry is closed, add short qty to total.
     C                   when      opuplv = 'Y'
     C                             and rustat = 'C'
     *      When Voice option set to NOT update Label record &
     *      Runner flag entry is NOT closed, add short qty to total.
     C                             or opuplv = 'N'
     C                             and rustat <> 'C'
     *      In either case, we want the total qty shorted, to subtract
     *      from total quantity picked by selector.
     C                   eval      $pshortq = $pshortq + ruqyso
     C                   endsl
     *
     C                   enddo
     *
     C                   Endsr

     *----------------------------------------------------------------
     *
     *  ZZGETOP   Get *VOICE Options record.
     *
     C     zzgetop       begsr
     *
     C                   Eval      kycode = '*VOICE  '
     C     keyop         Chain     Options
     C                   if        %found
     C                   eval      opvdta = opdata
     C                   else
     C                   eval      opincp = 'Y'
     C                   eval      opcrtr = 'N'
     C                   eval      opuplv = 'N'
     C                   eval      opvmrg = 'N'
     C                   eval      opoutf = 'N'
     C                   eval      opfclr = 'N'
     C                   eval      opvmlt = 'N'
     C                   eval      opvspn = 'N'
     C                   eval      opvspz = 'N'
     C                   eval      opvslw = 'N'
     C                   eval      opvcep = 'N'
     C                   eval      opvssn = 'N'
     C                   eval      opvcpz = 'N'
     C                   endif
     *
     C                   Endsr
