      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKRTEIUS2  Check route in use flag - Pgm for CHKRTEINUSE2 proc
     *  28 December 2013
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    12/28/13  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

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
     *      $PCMD   Command.
     *      $PWHSE  Warehouse number.
     *      $PRTID  Route Id.
     *      $PPGM   Calling program
     *      $PUSER  User
     *      $PSESSID   Session id
     *
     *    Returned Parameters
     *      $PRTN     *OK      - No lock or set/clear successful.
     *                *ERROR   - Locked to different session or set/clear error
     *      $iuTEXT10  Inuse status short text
     *      $iuTEXT30  Inuse status long text
     *      $iuCmd     Inuse command
     *      $iuPgm     Inuse program
     *      $iuUSER    Inuse user
     *      $iuSESSID  Inuse session id
     *      $iuJOBNAME Inuse job name
     *      $iuJOBNBR  Inuse job number
     *      $iuJOBUSR  Inuse job user
     *      $iuSTAMP   Inuse timestamp
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $icmd             8
     C                   parm                    $iwhse            3 0
     C                   parm                    $irtid            5
     C                   parm                    $ipgm            20
     C                   parm                    $iuser           10
     C                   parm                    $isessid         40
     C                   parm                    $irtn             8
     C                   parm                    $iutext10        10
     C                   parm                    $iutext30        30
     C                   parm                    $iucmd            8
     C                   parm                    $iupgm           20
     C                   parm                    $iuuser          10
     C                   parm                    $iuSessId        40
     C                   parm                    $iuJobName       10
     C                   parm                    $iuJobNbr         6
     C                   parm                    $iuJobUser       10
     C                   parm                    $iuStamp         26

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Call program to see if route is in use.

     C                   Call(e)   'CHKIUSE2'
     C                   parm                    $icmd             8
     C                   parm                    $iwhse            3 0
     C                   parm                    $irtid            5
     C                   parm                    $ipgm            20
     C                   parm                    $iuser           10
     C                   parm                    $isessid         40
     C                   parm                    $irtn             8
     C                   parm                    $itext10         10
     C                   parm                    $itext30         30
     C                   parm                    $iucmd            8
     C                   parm                    $iupgm           20
     C                   parm                    $iuuser          10
     C                   parm                    $iuSessId        40
     C                   parm                    $iuJobName       10
     C                   parm                    $iuJobNbr         6
     C                   parm                    $iuJobUser       10
     C                   parm                    $iuStamp         26

     *  Set return code.

     C                   if        %error
     C                   eval      $irtn = '*ERROR'
     C                   eval      $iutext10 = 'CALLERR'
     C                   eval      $iutext30 = 'Error on call to '
     C                                       + 'CHKIUSE2'
     C                   endif

     C                   eval      *inlr = *on
