     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK101     Create dock door matrix
     *  06 November 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/06/01  DAS  4.16
     *      - Created.
416aA*    04/10/02  MLB  4.16a
     *      - Revised program to pass 2 new parms to DK105.
     *        $pltyp and $pwhdp.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Revised program to pass Assignment Type code
     *        to DK105 when setting up new matrix.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fwarehs    ip   e           k disk
     Fdochist   o    e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD curdate         s              8  0
415aAD curtime         s              6  0
416aDD* pass            s              3  0
416aMD $pass           s              3  0
416aAD $pltyp          s              1
416aAD $pwhdp          s              5
520 AD $patyp          s              1

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')
     D @clcdr          c                   CONST('CLCDUR')

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
     *      $pwhse  -  Warehouse number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse           15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Only create records for requested warehouse(s).

     C                   if        $pwhse <> 0 and
     C                             $pwhse <> whcode
     C                   goto      bottom
     C                   endif

     *  Create history record.

     C                   eval      dhwhse = whcode
     C                   eval      dhhdte = curdate
     C                   eval      dhhtim = curtime
     C                   write(e)  dhrec
     C                   if        %error
     C                   goto      bottom
     C                   endif

     *  Call program to create matrix records for first pass.

     C                   call      'DK105'
     C                   parm                    dhwhse
     C                   parm                    dhhdte
     C                   parm                    dhhtim
416aDC*                  parm      1             pass
416aMC                   parm      1             $pass
416aAC                   parm      '1'           $pltyp
416aAC                   parm      *blanks       $pwhdp
520 AC                   parm      'A'           $patyp

     C     bottom        tag

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *INZSR        BEGSR

     *  Get current date/time

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   time                    curtime

     C                   endsr
