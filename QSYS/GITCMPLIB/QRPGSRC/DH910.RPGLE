     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DH910     Retrieve Last Dock Door History
     *  18 April 2002
     *  Max Blacknik
     *
     *  Revisions
     *
416 A*    04/18/02  MLB  4.16
     *      - Created.
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

     Fdochist   if   e           k disk
     F                                     rename(dhrec:record)

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
     D  $phdte                22     29  0
     D  $phtim                30     35  0

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
     *      $PUKY   Contains unique key for retrieve.
     *        $PWHSE - Warehouse number
     *
     *    Returned Parameters
     *      $PUKY   Contains unique key for retrieve.
     *        $PHDTE - Dock history date
     *        $PHTIM - Dock history time
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record retrieved successfully.
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

     C                   exsr      zzinz2
     *
     *    Get most current dock door history record.
     *
     C     keydh         setgt     dochist
     C     keydh         readpe    dochist
     *
     C                   select
     C                   when      %eof(dochist)
     C                   eval      $prtn = '*ERROR  '
     *
     C                   other
     *
     C                   eval      $prtn = '*OK     '
     C                   eval      $phdte  = dhhdte
     C                   eval      $phtim  = dhhtim
     *
     C                   endsl
     *
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        BEGSR

     *   Call user added initialization routine.

     C                   exsr      zzinz
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         BEGSR
     *
     *  Define key for DOCHIST - Partial
     *
     C     keydh         klist
     C                   kfld                    $pwhse
     *
     C                   eval      forevr = *off
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization. Called from Mainline.
     *----------------------------------------------------------------

     C     zzinz2        BEGSR
     *
     *  Clear return fields.
     *
     C                   eval      $phdte = *zeros
     C                   eval      $phtim = *zeros
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
**
Dock history
