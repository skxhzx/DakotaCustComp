      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETEPMSTD   Get EPM standard goal time for transaction.
     *  14 June 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    06/14/04  DAS  4.17
     *      - Created.
     *      - Added custom mod ALNa.
417aA*    09/24/04  MLB  4.17a
     *      - Enh: Added two new fields, prior performance %
     *        and daily performance %.
417bA*    10/05/04  MLB  4.17b
     *      - Enh: Added new parm $pcmd to *entry plist and to
     *        called program to enable *inlr to be seton at exit.
     *
     *----------------------------------------------------------------

417 A*----------------------------------------------------------------
417 A*  Allen Custom Mods.
417 A*
417 A*  All Allen custom mods should be conditioned with ...
417 A*     'if client = allen'
417 A*  or 'client  cabne  allen   skipallen1'
417 A*  or 'select / when client = allen / other / endsl'
     *
ALNaA*    06/14/04  DAS  ALNa
     *      - Calls special program to retrieve time from Red Prairie
     *        using a socket interface.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

ALNaA /copy qcopysrc,id#allen
     D client          s             10

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
417bA*      $pcmd     Blank
417bA*                *CLOSE - Seton LR and end program.
     *      $puser       User id
     *      $pempl#      Employee number
     *      $ptran#      Transaction number
     *      $pstartdte   Transaction start date
     *      $pstarttim   Transaction start time
     *      $prcdtype    Record type - Red Prairie
     *      $ptask       Task code
     *
     *    Returned Parameters
     *      $ptime    Standard time for transaction (HHMMSS)
417aA*      $pppfr    Prior performance %
417aA*      $pdpfr    Daily performance %
     *      $preturn  *OK      - No problem encountered.
     *                *NOTUSED - Standard time not implemented.
     *                *ERROR   - Error getting standard time.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
417bAC                   parm                    $pcmd             8
     C                   parm                    $puser           10
     C                   parm                    $pempl#           5 0
     C                   parm                    $ptran#           7 0
     C                   parm                    $pstartdt         8 0
     C                   parm                    $pstarttm         6 0
     C                   parm                    $ptime            6 0
417aAC                   parm                    $pppfr            3 0
417aAC                   parm                    $pdpfr            3 0
     C                   parm                    $prcdtype        15
     C                   parm                    $ptask            6
     C                   parm                    $preturn          8

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Get time standard for transaction.

     C                   select
ALNaA
ALNaA*    Call special program to get time from Red Prairie.
ALNaA
ALNaAC                   when      client = allen
     C                   call      'GETEPMRP'
417bAC                   parm                    $pcmd
     C                   parm                    $puser
     C                   parm                    $pempl#
     C                   parm                    $ptran#
     C                   parm                    $pstartdt
     C                   parm                    $pstarttm
     C                   parm                    $ptime
417aAC                   parm                    $pppfr            3 0
417aAC                   parm                    $pdpfr            3 0
     C                   parm                    $prcdtype
     C                   parm                    $ptask
     C                   parm                    $preturn

     *    Otherwise, get Dakota standard time.

     C                   other
     C                   eval      $preturn = '*NOTUSED'

     C                   endsl

417bAC                   select
417bAC                   when      $pcmd = '*CLOSE  '
417baC                   eval      *inlr = *on
417bAC                   other
     C                   return
417bAC                   endsl

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

417nA *  Get client id

417nAC                   call      'GETCLIENT'
417nAC                   parm                    client

417nAC                   endsr
