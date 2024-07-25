      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  ZH125     Zone maintenance - Edits
     *  17 April 2012
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720aA*    10/17/18  DAS  7.20a
     *      - Modified 'Invalid Label Set' message
     *
720bA*    12/04/18  7.20b RBD
     *      - Add PLST40CF to acceptable pick list print programs.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JOR A*    09/13/10  JCJ  JOR A
     *      -  Removed edit for Printer Device name (UT880CL) because
     *         Jordanos uses outq names instead of device names for
     *         their remote printers.  This causes UT880CL to return
     *         an error that the device is not valid.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Flblfmtt   if   e           k disk
     Flblfmth   if   e           k disk
     Fdevgrph   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
JOR A /copy qcopysrc,id#jordano

     *----------------------------------------------------------------
     *  Constants
     *
     D prefix          c                   const('<')
     D pstfix          c                   const('>')
     D valid           c                   const('@#$_ABCDEFGHIJKLMNOP-
     D                                     QRSTUVWXYZ0123456789-
     D                                      ')
     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $plb                  22     22
     D  $pcu                  23     23
     D  $plp                  24     33
     D  $pdv                  34     43
     D  $pfm                  44     53
     D  $plbltype             54     54
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D pos             s              3  0
     D pos2            s              3  0
     D lblfmttky       s              8
     D $lrtn           s              8
     D lblfmthky       s              6
     D error           s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
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
     C                   exsr      ZZChkPrtOpt

     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *  ZZChkPrtOpt  Print options error checking.
     *
     C     zzChkPrtOpt   begsr
     C                   eval      error = *off
     C                   eval      $perm = *blanks
     *
     *  If label type does not exist, skip edits and go to next label type.
     *
     C                   select
     C                   when      $plbltype = '1'
     C                   eval      lblfmttky = 'PICK'
     C                   when      $plbltype = '2'
     C                   eval      lblfmttky = 'MPICK'
     C                   when      $plbltype = '3'
     C                   eval      lblfmttky = 'XTOTE'
     C                   when      $plbltype = '4'
     C                   eval      lblfmttky = 'ASN'
     C                   when      $plbltype = '5'
     C                   eval      lblfmttky = 'PCKLST'
     C                   when      $plbltype = '6'
     C                   endsl

     C                   select
     C                   when      $plbltype <> '6'
     C     lblfmttky     chain     lblfmtt
     C                   if        not %found(lblfmtt)
     C                   eval      error = *on
     C                   eval      $perm = 'Invalid Label Printing Program '
     C                   endif
     *
     *  Verify label set & program name
     *
     C                   eval      lblfmthky = %subst($plp:5:6)
     C     lblfmthky     chain     lblfmth
     C                   if        not %found(lblfmth)
     C                             or %subst($plp:1:4) <> 'PFMT'
     C                   eval      error = *on
     C                   if        $perm = *blanks
     C                   eval      $perm = 'Invalid Label Set '
720aAC                                   + '(' + $plbltype + '/'
720aAC                                   + %trim($plp) + ')'
     C                   endif
     C                   endif

     C                   when      $plbltype = '6'
     C                   if        $plp <> 'PLST40WS'
720bAC                             and $plp <> 'PLST40CF'
     C                   eval      error = *on
     C                   if        $perm = *blanks
     C                   eval      $perm = 'Invalid Label Printing Program '
     C                   endif
     C                   endif
     C                   endsl
     *
     *  Verify device group codes if entered
     *
     C     prefix        scan      $pdv          pos
     C     pstfix        scan      $pdv          pos2
     *
     C                   select
     C                   when      pos >= 1
     C                             or pos2 >= 1
     C     devgky        chain     devgrph
     C                   if        not %found(devgrph)
     C                   eval      error = *on
     C                   if        $perm = *blanks
     C                   eval      $perm = 'Invalid Printer Group Code '
     C                   endif
     C                   endif
     *
     C                   other
     *
     *  Verify printer device
     *
     C                   select
     C                   when      $pdv = '*JOB'
     C                             or $pdv = '*SYSVAL'
     C                             or $pdv = 'QPRINT'
     C                   eval      error = *off
     *
     C                   when      client = jordanos
     C                   eval      error = *off
     *
     C                   other
     C                   call      'UT880CL'
     C                   parm                    $pdv
     C                   parm                    $lrtn
     C                   if        $lrtn = '*ERROR '
     C                             or $pdv = ' '
     C                   eval      error = *on
     C                   if        $perm = *blanks
     C                   eval      $perm = 'Invalid Printer '
     C                   endif
     c                   endif
     c                   endsl

     c                   endsl
     *
     C                   eval      $prtn = '*OK   '
     C                   if        error = *on
     C                   eval      $prtn = '*ERROR'
     C                   endif
     *
     C     endChkPrtOpt  endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientLoc        10
     *
     *  Define key for device group code.
     *
     C     devgky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pdv
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
