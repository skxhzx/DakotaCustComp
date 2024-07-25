     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UC214    Delete Multiple UPC code Vendor 0 - Process
     *  03 November, 2009
     *  Roxanne Harrison
     *
     *  Revisions:
417  *  11/03/09  RH   5.30  Created
     *
700a *    11/02/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fupc       ip   e           k disk
     Fuc214     uf a e           k disk
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     D a22             s              1    dim(22)
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
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D                 ds
     D  t#date                 1      6  0
     D  month                  1      2  0
     D  day                    3      4  0
     D  year                   5      6  0
     *----------------------------------------------------------------
     *Variables
     D $pmcnt          s              3  0
     D $pwhse          s              3  0
     D first           s              1
     D svupc           s                   like(upupc)
     D upcnt           s              5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse #
     *      $PMCNT  Multiple count
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
417b C                   parm                    $pmct             3
     C                   move      $pwhs         $pwhse
417b C                   move      $pmct         $pmcnt
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *  If multiple UPC codes exist, write to work file.
     *
417b C                   if        upwhse = $pwhse
417b C                   if        svupc = *blanks
417b C                   eval      svupc = upupc
417b C                   eval      upcnt = 0
417b C                   endif
     C                   if        svupc <> *blanks
     C                   if        upupc = svupc
417b C                   add       1             upcnt
417b C                   else
     C                   exsr      zzupd
417b C                   eval      svupc = upupc
417b C                   eval      upcnt = 1
     C                   endif
     C                   endif
     *
417b C                   endif
     *
     C     skipex        tag
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C     wkkey1        klist
     C                   kfld                    $pwhse
417b C                   kfld                    svupc
417bD*
     C                   eval      first = *on
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD   Update work file.
     *
     C     zzupd         begsr
417b C*                  if        upcnt >= $pmcnt
417b C                   if        upcnt > $pmcnt
     C     wkkey1        chain     uc214                              77
     C                   if        *in77
417b C                   eval      wkswhs = $pwhse
417b C                   eval      wksupc = svupc
     C                   write     wkrec
     C                   endif
417b C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
