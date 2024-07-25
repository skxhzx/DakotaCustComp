     H option(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU300   Retrieve Runner Flag status
     *  30 June 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/30/05  MLB  5.00
     *      - Created.
     *      - Client custom code support included.
500aA*    10/26/05  MLB  5.00a
     *      - Fix - Revised program to return correct flag
     *        status for flag that was created as type N=Normal
     *        then moved to U=Out.
500bA*    06/01/06  MLB  5.00b
     *      - Fix - Revised program to return *NOTFND when
     *        record is found, but with status = 'D'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *            No indicators used in this program.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frunner    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     *
     *----------------------------------------------------------------
     *  Other working variables.
     *
     *
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
     *      $PCMD   *STATUS  - Retrieve runner flag status
     *      $Pwhse  warehouse number
     *      $Plbl#  Label number
     *
     *    Returned Parameters
     *      $Pflgtype - Flag type   (from file)
     *      $Pflgstat - Flag status (from file)
     *      $Prtn     - *OK - when Runner Flag record found
     *                - *NOTFND - Runner Flag record not found
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C     *entry        plist
     C                   parm      '*STATUS '    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $plbl#            7 0
     C                   parm                    $pflgtype         1
     C                   parm                    $pflgstat         1
     C                   parm                    $prtn             8
500aA*
500aAC                   clear                   rutype
500aAC                   clear                   rustat
     *
     *    Retrieve status for Normal label record.
     C                   eval      kytype = 'N'
     C                   exsr      zzgetru
     C                   If        not %found(runner)
500aA*
500aA*    If flag is closed, see if converted to type Out.
500aAC                             or %found(runner)
500aAC                             and rustat = 'C'
500aA*
     *    Retrieve status for Out label record.
     C                   eval      kytype = 'U'
     C                   exsr      zzgetru
     C                   If        not %found(runner)
     *    Retrieve status for Merge label record.
     C                   eval      kytype = 'M'
     C                   exsr      zzgetru
     C                   endif
     C                   endif
     *
     C                   select
500bA*
500bAC                   when      %found(runner)
500bAC                             and rustat = 'D'
500bAC                   eval      $prtn = '*NOTFND '
     C                   when      %found(runner)
     C                   eval      $prtn = '*OK     '
     *
     C                   when      not %found(runner)
     C                   eval      $prtn = '*NOTFND '
     *
     C                   endsl
     *
     C                   eval      $pflgtype = rutype
     C                   eval      $pflgstat = rustat
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     *
     *  Define full key for RUNNER file.
     *
     C     *like         define    rutype        kytype
     C     keyru         klist
     C                   kfld                    $pwhse
     C                   kfld                    kytype
     C                   kfld                    $plbl#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  ZZgetru
     *----------------------------------------------------------------
     C     zzgetru       begsr

     C     keyru         chain     runner
     C                   if        not %found(runner)
     C                   eval      $prtn  = '*ERROR'
     C                   eval      rutype = ' '
     C                   eval      rustat = ' '
     C                   endif

     C                   endsr
     *
