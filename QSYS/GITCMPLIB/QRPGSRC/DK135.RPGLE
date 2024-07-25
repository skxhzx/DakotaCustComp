     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK135     Check for available dock doors.
     *  03 April 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    04/03/02  MLB  4.16
     *      - Created.
416aA*    07/17/02  MLB  4.16a
     *      - Revised ZZCKN1 to use CHAIN to retrieve current door.
     *        File pointer was being positioned past current pass.
     *      - Revised ZZCKN2 to use CHAIN to retrieve current door.
     *        File pointer was being positioned past current pass.
416bA*    07/30/02  MLB  4.16b
     *      - FIX: Revised ZZCHKP that if previous pass/door record
     *        wasn't found, treat current door/pass as available.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Added Assignment Type to dock matrix file key to
     *        keep automatic assigned doors separate from manually
     *        assigned doors. This was done so that the next
     *        dock door to be assigned in the automatic sequence
     *        will always be correct even when a route is moved
     *        from one door to another.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocmtrx   if   e           k disk
     Fdocmtrx1  if   e           k disk
     F                                     rename(dmrec:dmrec1)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D kypass          s                   like(dmpass)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------

     D $lparm          ds
     D    $lcmd                1      8
     D    $lprg                9     18
     D    $luky               19     68
     D    $lrtn               69     76
     D    $lerm               77    136
     D    $lmsg               77     80

     *   Redefine key

     D    $lwhse              19     21  0
     D    $lhdte              22     29  0
     D    $lhtim              30     35  0
     D    $lpass              36     38  0
     D    $ldoor              39     41  0
     D    $lrte               42     46
     D    $lrtid              47     51
     D    $lcube              52     56P 3
     D    $lwhdp              57     61
     D    $lltyp              62     62
520 AD    $latyp              63     63

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
     *      $LCMD   *CKPRVPS - Check previous pass if door is available.
     *              *CKNXTDR - Check if next dock door is available.
     *      $LPRG   Program to send messages back to.
     *      $LUKY   Contains key to be verified.
     *
     *    Returned Parameters
     *      $LUKY   Contains first key selected.
     *
     *        When $LCMD = *CKNXTDR and $LRTN = *DRAVAIL
     *          $LDOOR - Dock door number
     *          $LWHDP - Dock door department
     *      $LRTN   *DRAVAIL - Dock door is available.
     *              *DRUSED  - Dock door is NOT available.
     *      $PERM   Error message or pointer to message in pgmq.
     *              -or- Description of verified code.
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $lparm

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *
     C                   exsr      zzinz2
     *
     C                   select
     *
     *   Check previous pass to see if dock door was used.
     C                   when      $lcmd = '*CKPRVDR'
     *
     C                   exsr      zzchkp
     *
     *   Check next dock door to see if door is available.
     C     $lcmd         wheneq    '*CKNXTDR'
     *
     *   Route is assigned to single dock door.
     C                   if        $lltyp = '1'
     C                   exsr      zzckn1
     *
     *   Route is assigned by department / door.
     C                   else
     C                   exsr      zzckn2
     *
     C                   endif
     C                   endsl
     *
     C                   return
     *

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     *
     C     *INZSR        BEGSR
     *
     *   Call user added initialization routine.
     *
     C                   exsr      ZZINZ
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------
     *
     C     ZZINZ         BEGSR
     *
     *  Define key for DOCMTRX file - Full
     *
     C     dmkey         klist
     C                   kfld                    $lwhse
     C                   kfld                    $lhdte
     C                   kfld                    $lhtim
520 AC                   kfld                    $latyp
     C                   kfld                    kypass
     C                   kfld                    $ldoor
     C                   kfld                    $lwhdp
     *
     *  Define key for DOCMTRX file - Partial.
     *
     C     dmkey2        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lhdte
     C                   kfld                    $lhtim
520 AC                   kfld                    $latyp
     C                   kfld                    kypass
     C                   kfld                    $ldoor
     *
     *  Define key for DOCMTRX file - Partial.
     *
     C     dmkey3        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lhdte
     C                   kfld                    $lhtim
520 AC                   kfld                    $latyp
     C                   kfld                    kypass
     *
     *  Define key for DOCMTRX1 file - Partial
     *
     C     dmkey1        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lhdte
     C                   kfld                    $lhtim
520 AC                   kfld                    $latyp
     C                   kfld                    $lwhdp
     C                   kfld                    kypass
416aA*
416aAC     dmkey1a       klist
416aAC                   kfld                    $lwhse
416aAC                   kfld                    $lhdte
416aAC                   kfld                    $lhtim
520 AC                   kfld                    $latyp
416aAC                   kfld                    $lwhdp
416aAC                   kfld                    kypass
416aAC                   kfld                    $ldoor
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *  ZZINZ2  Extra program initialization. Called from main line.
     *----------------------------------------------------------------

     C     ZZINZ2        BEGSR

     *
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKN1  Check to see if next dock door is available.(door seq)
     *----------------------------------------------------------------
     C     ZZCKN1        BEGSR
     *
     C                   eval      kypass = $lpass
416aDC*    dmkey2        setgt     docmtrx
416aMC     dmkey2        chain     docmtrx                            79
     C     dmkey3        reade     docmtrx
     *
     C                   select
     *    Dock matrix door record found. If open or skipped ok to use.
     C                   when      %eof(docmtrx) = *off
     *
     C                   select
     C                   when      dmwhdp = $lwhdp and
     C                             (dmstat = '1' or dmstat = '3')
     C                   eval      $lrtn = '*DRAVAIL'
     C                   eval      $ldoor= dmdoor
     C                   eval      $lwhdp= dmwhdp
     *
     *    Dock matrix door record found. Door not available.
     C                   other
     C                   eval      $lrtn = '*DRUSED '
     C                   endsl
     *
     *    Matrix record not found - Flag door not available.
     C                   when      %eof(docmtrx)
     C                   eval      $lrtn = '*DRUSED '
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKN2  Check to see if next dock door is available.(dept seq)
     *----------------------------------------------------------------
     C     ZZCKN2        BEGSR
     *
     C                   eval      kypass = $lpass
416aDC*    dmkey1        setgt     docmtrx1
416aMC     dmkey1a       chain     docmtrx1                           79
     C     dmkey1        reade     docmtrx1
     *
     C                   select
     *    Dock matrix door record found. If open or skipped ok to use.
     C                   when      %eof(docmtrx1) = *off
     *
     C                   select
     C                   when      dmstat = '1' or dmstat = '3'
     C                   eval      $lrtn = '*DRAVAIL'
     C                   eval      $ldoor= dmdoor
     *
     *    Dock matrix door record found. Door not available.
     C                   other
     C                   eval      $lrtn = '*DRUSED '
     C                   endsl
     *
     *    Matrix record not found - Flag door not available.
     C                   when      %eof(docmtrx1)
     C                   eval      $lrtn = '*DRUSED '
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCHKP  Check to see if previous pass dock door is available.
     *----------------------------------------------------------------
     C     ZZCHKP        BEGSR
     *
     C                   eval      kypass = $lpass - 1
     C     dmkey         chain     docmtrx
     *
     C                   select
     *    Dock matrix door record found. If open or skipped ok to use.
     C                   when      %found(docmtrx)
     C                   select
     C                   when      dmstat = '1' or dmstat = '3'
     C                   eval      $lrtn = '*DRAVAIL'
     *
     *    Dock matrix door record found. Door not available.
     C                   other
     C                   eval      $lrtn = '*DRUSED '
     *
     C                   endsl
     *
     *    Matrix record not found - Flag door not available.
     C                   when      not %found(docmtrx)
     C                   eval      $lrtn = '*DRUSED '
     *
     C                   endsl
     *
     C                   ENDSR

