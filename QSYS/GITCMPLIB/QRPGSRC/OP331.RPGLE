     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OP331  update *VOICE & *RUNNER option values
     *  05 December 2005
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/30/05  JCJ  5.00
     *      - Created.
     *
500aA*    12/05/05  JCJ  5.00a
     *      - Enh: add two new *runner options (OPRPCK,OPRLBL)
500bA*    01/13/06  MLB  5.00b
     *      - Enh: Added new parm to program to receive field name to
     *        to be updated by pgm.
     *      - Enh: Revised *VOICE options to remove field OPFRPL since
     *        it was not used. Renamed OPFRPL to OPFCLR - Clear RUNNER
     *        flag if quantity still short/out.
520 A*    04/01/09  CWM  5.20
     *      - Enh: Changed to sync 5 fields with 1 call from either
     *        voice or runner options pgms OP310 and OP330.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   uf   e           k disk    rename(oprec:record)

     *----------------------------------------------------------------
     *  *VOICE  -  PIR Voice options (Y/N)
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPINCP  -  Include pack description.
     *    OPCRTR  -  Create RUNNER entries for shorts/outs (Y/N)
     *    OPUPLV  -  Update Label with quantity picked during Voice
     *               selection (Y/N)
     *               NOTE: Any change to this field will cause OPUPLR
     *                     in the *RUNNER options record to be updated.
     *    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
     *    OPFOUT  -  Create Runner entry after slot marked out. (Y/N)
500bM*    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
500bM*               NOTE: Any change to this field will cause OPCLRF
500bA*                     in the *RUNNER options record to be updated.
     *
     * Data structure
     *
     D opdata1         ds
     D  opincp                 1      1
     D  opcrtr                 2      2
     D  opuplv                 3      3
     D  opvmrg                 4      4
     D  opoutf                 5      5
500bDD* opfrpl                 6      6
500bMD  opfclr                 6      6
     D  optend               117    117
     *
     *----------------------------------------------------------------
     *  *RUNNER  -  PIR Runner Flag Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
     *    OPUPLR  -  Update Label with quantity shorted during manual
     *               flag entry (Y/N)
     *               NOTE: Any change to this field will cause OPUPLV
     *                     in the *VOICE options record to be updated.
     *    OPRPLF  -  Replenish flagged items before print report? (Y/N)
     *               & create Priority Replenishment if necessary.
     *    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
     *    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
     *    OPRNRM  -  Send break message to user when new Runner
     *               task has been assigned. (Y/N)
     *    OPCLSF  -  Update Label quantity at flag close (Y/N).
     *    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500aA*    OPRPCK  -  Print Runner pick list. (Y/N)
500aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
500aA*               printer, 2=Belt printer
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata2         ds
     D  opcrtm                 1      1
     D  opuplr                 2      2
     D  oprplf                 3      3
     D  opmrgf                 4      4
     D  opclrf                 5      5
     D  oprnrm                 6      6
     D  opclsf                 7      7
     D  opoutf2                8      8
500aAD  oprpck                 9      9
500aAD  oprlbl                10     10
     D  optend2              117    117

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
     D  $pvoice               22     22
     D  $prunner              23     23
520 AD  $pflgpl               24     24
520 AD  $pflgrt               25     25
520 AD  $pflgmr               26     26
520 AD  $pflgtf               27     27
520 AD  $pflgcl               28     28
520 DD* $pflag                24     24
520 DD* $pupdfld              25     34

     *----------------------------------------------------------------
     *  Input parameters
     *
     *      $pcmd      -  not used
     *      $pprg      -  Calling program name
     *      $puky      -  Values
     *        $pwhse      -  Warehouse
     *        $pvoice     -  PIR Voice Flag options (Y/N)
     *        $prunner    -  PIR Runner Flag options
     *        $pflag      -  PIR update value
500bA*        $pupdfld    -  PIR field to be updated
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

     C                   select
     C                   when      $pvoice  = 'Y'
     C                   exsr      updvfields
     C                   when      $prunner = 'Y'
     C                   exsr      updrfields
     C                   endsl

     C                   eval      *inlr = *On

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode

     C                   endsr

     *----------------------------------------------------------------
     *  updvfields   update voice field options
     *----------------------------------------------------------------

     C     updvfields    begsr

     *  Get global voice options.

     C                   eval      opcode = '*VOICE  '
     C     keyop         chain     options
     C                   if        %found(options)
     C                   eval      opdata1 = opdata
520 AC                   eval      opuplv = $pflgpl
520 AC                   eval      opcrtr = $pflgrt
520 AC                   eval      opvmrg = $pflgmr
520 AC                   eval      opoutf = $pflgtf
520 AC                   eval      opfclr = $pflgcl
520 A*
520 DC*                  select
520 DC*                  when      $pupdfld = 'OPUPLR'
520 DC*                  eval      opuplv = $pflag
500bA*
520 DC*                  when      $pupdfld = 'OPCLRF'
520 DC*                  eval      opfclr   = $pflag
520 DC*                  endsl
500bA*
     C                   eval      opdata = opdata1
     C                   update    record
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  updrfields   update runner field options
     *----------------------------------------------------------------

     C     updrfields    begsr

     *  Get global runner options.

     C                   eval      opcode = '*RUNNER '
     C     keyop         chain     options
     C                   if        %found(options)
     C                   eval      opdata2 = opdata
520 AC                   eval      opuplr = $pflgpl
520 AC                   eval      opcrtm = $pflgrt
520 AC                   eval      opmrgf = $pflgmr
520 AC                   eval      opoutf2 = $pflgtf
520 AC                   eval      opclrf = $pflgcl
520 A*
520 DC*                  select
520 DC*                  when      $pupdfld = 'OPUPLV'
520 DC*                  eval      opuplr = $pflag
500bA*
520 DC*                  when      $pupdfld = 'OPFCLR'
520 DC*                  eval      opclrf   = $pflag
520 DC*                  endsl
500bA*
     C                   eval      opdata = opdata2
     C                   update    record
     C                   endif

     C                   endsr
