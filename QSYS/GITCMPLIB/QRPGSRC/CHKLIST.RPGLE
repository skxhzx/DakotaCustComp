     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHKLIST  Check Authorized Users list
     *  December 9, 2004
     *  Jose Duque
     *
     *  Revisions
     *      - Created
     *
530aA*    01/14/10  DAS  5.30a
     *      - Added logic for global *ALL overrides.
530bA*    06/21/10  RH   5.30b
     *      - Added logic for global *ALL overrides for user.
720a *    06/26/18  GJA  7.20a
     *      - Added client code.
     *
     *----------------------------------------------------------------
     *  Client Custom Presto
     *
PFCa *    06/26/18  GJA  PFCa
     *      - Added logic to exclude *ALL *ALL from inventory adjust
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
     Fpgmusrid  if   e           k disk
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
530aA*----------------------------------------------------------------
530aA*  Variables
530aA*
530aAD kyopt           s             20
530aAD kypgmid         s             10
530bAD kyusri          s             10
510aAD client          s             10
720aA*----------------------------------------------------------------
720aA*  Customer id
720aA*----------------------------------------------------------------

PFCaA /copy qcopysrc,id#pfc
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PGMID  Program from which the update accion was selected
     *      $USRID  User executing the program
     *
     *    Returned Parameters
     *      $PRTN   *YES     - Authorized User
     *              *NO      - Non-Authorized User
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pgmid           10
     C                   parm                    $popt            20
     C                   parm                    $pusri           10
     C                   parm                    $prtn            10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $prtn = *blanks
     *
     * Execute appropriate routine.
     *
     C                   exsr      zzchk
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr
     *
510aA*
510aA* Get client id.
510aA*
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *
     *---------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *---------------------------------------------------------------
     C     zzinz         begsr
     *
     *  Define full key for PGMUSRID file.
     *
     C     usrkey        klist
530aDC**                 kfld                    $pgmid
530aDC**                 kfld                    $popt
530aMC                   kfld                    kypgmid
530aMC                   kfld                    kyopt
530aMC                   kfld                    kyusri
530aDC**                 kfld                    $pusri
     *
     C                   endsr
     *----------------------------------------------------------------
     *   Check if user is authorized to initiate the update action
     *----------------------------------------------------------------
     *
     C     zzchk         begsr
530aAC                   eval      $prtn = '*NO '
     *
PFCaA*  Presto - don't allow *all *all to have item adjustment
PFCaA
PFCaAC                   if        client = Presto
PFCaAC                   if        $pgmid = 'IT122CL' or
PFCaAC                             $pgmid = 'IT120CL' or
PFCaAC                             $pgmid = 'IT130'
PFCaAC                   eval      kypgmid = $pgmid
PFCaAC                   eval      kyopt   = '*ALL'
PFCaAC                   eval      kyusri  = $pusri
PFCaAC     usrkey        setll     pgmusrid
PFCaAC                   if        %equal(pgmusrid)
PFCaAC                   eval      $prtn = '*YES'
PFCaAC                   else
PFCaAC                   eval      $prtn = '*NO '
PFCaAC                   endif
PFCaAC                   leavesr
PFCaAC                   endif
PFCaAC                   endif
530aA*  First see if there is a specific override for pgm/opt/user
530aA
530aAC                   eval      kypgmid = $pgmid
530aAC                   eval      kyopt   = $popt
530aAC                   eval      kyusri  = $pusri
     C     usrkey        setll     pgmusrid
     C                   if        %equal(pgmusrid)
     C                   eval      $prtn = '*YES'
530aAC                   leavesr
530aDC**                 else
530aDC**                 eval      $prtn = '*NO '
     C                   endif
530aA
530aA*  Next, see if there is a global override for pgm/user
530aA
530aAC                   eval      kypgmid = $pgmid
530aAC                   eval      kyopt   = '*ALL'
530aAC     usrkey        setll     pgmusrid
530aAC                   if        %equal(pgmusrid)
530aAC                   eval      $prtn = '*YES'
530aAC                   leavesr
530aAC                   endif
     *
530aA
530bA*  Next, see if there is a global override for user
530aA
530aAC                   eval      kypgmid = '*ALL'
530aAC                   eval      kyopt   = '*ALL'
530aAC     usrkey        setll     pgmusrid
530aAC                   if        %equal(pgmusrid)
530aAC                   eval      $prtn = '*YES'
530aAC                   leavesr
530aAC                   endif
     *
530bA*  Next,see if there is a global ovrd for pgm to allow all users
530bA*  all options.
530bA
530bAC                   eval      kypgmid = $pgmid
530bAC                   eval      kyopt   = '*ALL'
530bAC                   eval      kyusri  = '*ALL'
530bAC     usrkey        setll     pgmusrid
530bAC                   if        %equal(pgmusrid)
530bAC                   eval      $prtn = '*YES'
530bAC                   leavesr
530bAC                   endif
530bA*  Last,see if there is a global ovrd for pgm to allow all users
530bA
530bAC                   eval      kypgmid = $pgmid
530bAC                   eval      kyopt   = $popt
530bAC                   eval      kyusri  = '*ALL'
530bAC     usrkey        setll     pgmusrid
530bAC                   if        %equal(pgmusrid)
530bAC                   eval      $prtn = '*YES'
530bAC                   leavesr
530bAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
