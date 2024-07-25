     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT725C    Export Route Info - Update status
     *  27 April 2006
     *  Roxanne Harrison
     *
     *  NOTE:
     *     - Need to compile with TYPECONV = *DATETIME for datestamp
     *          ***No longer required with RPGLE***
     *----------------------------------------------------------------
     *  Revisions
500 A*  04/27/06  RH   5.00
     *    - Created.
500aA*  05/10/06  MLB  5.00a
     *    - Fix: Changed pgm to correct infinite loop in pgm.
530 A*  11/16/09  MLB  5.30
     *    - Fix: Changed program to receive $PWHSE as 3,0 instead
     *      of 15,5.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fflgrti    uf   e           k disk
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     D tsinz           c                   const('0001-01-01-00.00.00.000000')
     *----------------------------------------------------------------
     *  Variables
     D doflag          s              1
     D first           s              1  0
     D kywhse          s                   like(frwhse)
     D today           s              8  0
     D x               s              2  0
     *
     D dftstamp        s               z
     D currstamp       s               z
     D datestamp       s               d
     D timestamp       s               t
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
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *
     *    Returned Parameters
     *      None
     *
     *
     C     *entry        plist
     C                   parm                    $cmd              8
530 DC*                  parm                    $pwhse           15 5
530 MC                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     *----------------------------------------------------------------
     * Main line
     *
416aAC                   time                    currstamp
     C     KeyFr         setll     flgrti
500aDC*    KeyFr         reade     flgrti                                 79
500aDC*                  dow       not *in79
500aMC                   dow       not %eof(flgrti)
500aAC     KeyFr         reade     flgrti
500aAC                   if        %eof(flgrti)
500aAC                   leave
500aAC                   endif
     *  Fill fields
     C                   if        $CMD = '*SEND   '
500aAC                             and frstat <='0 '
417b C                   eval      frstat = '2 '
500eAC*     Convert date/time to datestamp.
500eAC                   call      'GETTS'
500eAC                   parm                    fredts
417b C*                  eval      fredts = currstamp
417b C                   eval      freby  = #user
500aAC                   update    frrec
     C                   else
500aAC                   if        frstat <='2 '
417b C                   eval      frstat = '3 '
500eAC*     Convert date/time to datestamp.
500eAC                   call      'GETTS'
500eAC                   parm                    frrdts
417b C*                  eval      frrdts = currstamp
417b C                   eval      freby  = #user
500aAC                   update    frrec
500aAC                   endif
     C                   endif
     *
     *  Update record
500aDC*                  update    frrec
     *
500aDC*                  iter
     C                   enddo
     *
     C     bottom        tag
500aDC*                  return
500aMC                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     C                   eval      kywhse = $pwhse
     *
     *   Define key for PIRITEM file.
     *
     C     keyFr         klist
     C                   kfld                    kywhse
     C                   kfld                    $prtid
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
