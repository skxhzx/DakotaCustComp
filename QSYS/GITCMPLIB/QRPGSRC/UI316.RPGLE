     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*  UI316     UCI weight listing
     *  20 September  2006
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
510aA*    02/24/07  JCJ  5.10a
     *      - Enh: Replaced qsysprt with printer file
510bA *    04/26/07  JCJ  5.10b
      *      - Fix: Check for invalid date; program errors out
510cA*    05/01/07  TJ   5.10c
     *      - Add Export Date & Time, Seq# to entry parms
510dA*    05/01/07  TJ   5.10d
     *      - Add break line when UCI sequence changes/skips.
510eA*    06/06/07  TJ   5.10e
     *      - Add check for non-numeric characters in UCI for sorting.
     *
     *----------------------------------------------------------------
      *----------------------------------------------------------------
      *  Notes
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  21 - 30   Field input error (Reverse Display)
      *  90        View mode (Protect input fields)
      *  91        Change mode (Protect key)
      *  97        Always ON (Used for SFLEND Keyword)
      *  98        Error on screen (Sound buzzer)
      *  99        Universal record indicator (Very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Fucicw5    if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
510aAFui316pr   o    e             printer oflind(*in90)

      *----------------------------------------------------------------
      *  Constants
      *----------------------------------------------------------------
510eAD Numbers         C                   '0123456789'

      *----------------------------------------------------------------
      *  Variables
      *
     D totiwgt         s              9  2
     D toticnt         s              7  0
     D #itdesc         s             30
     D prtinb          s             10
     D $ppo            s              9
     D $pwhsea         s              3
510cAD $pexdt          s              8
510cAD $pexd           s              8  0
510cAD $pextm          s              6
510cAD $pext           s              6  0
510cAD $pdtsq          s              5
510cAD $psq            s              5  0
510dAD hlduci          s             10  0
510dAD cmpuci          s             10  0
510dAD diff            s             10  0
510dAD diff2           s              5
510dAD diff3           s              5  0
     D forever         s              1
     D ISODate         s               D   DatFmt(*ISO) Inz
     D USADate         s               D   DatFmt(*USA) Inz
510bAD DFTDate         s               D   DatFmt(*USA) Inz
     *----------------------------------------------------------------
     *  Program parameters
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

      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhsea
     C                   parm                    $ppo
510cAC                   parm                    $pexdt
510cAC                   parm                    $pextm
510cAC                   parm                    $pdtsq
      *----------------------------------------------------------------
      *  Main line

     C     key1          setll     ucicw5
     C                   dow       forever = forever
     C     key1          reade     ucicw5
     C                   if        %eof(ucicw5)
     C                   leave
     C                   endif

510eAC                   z-add     *zeros        cmpuci
510eAC*    UCI must be numeric, set 50 on if non-numeric found
510eAC     numbers       check     ucinbr                                 50
510eAC                   if        *in50 = *off
510dAC                   move      ucinbr        cmpuci
510eAC                   endif

510dAC                   select
510eAC                   when      *in50 = *on
510eAC                   eval      diff = 2
510dAC                   when      cmpuci > hlduci
510dAC                   eval      diff = cmpuci - hlduci
510dAC                   when      hlduci > cmpuci
510dAC                   eval      diff = hlduci - cmpuci
510dAC                   endsl
510dAC                   move      diff          diff2
510dAC                   move      diff2         diff3
510dAC                   if        diff3 > 1
510dAC                   write     break
510dAC                   endif

510eAC                   z-add     *zeros        hlduci
510eAC                   if        *in50 = *off
510eAC                   move      ucinbr        hlduci
510eAC                   endif

     C                   exsr      zzgetitm

510bAC                   move      dftdate       usadate
510bAC                   if        ucirdt <> *zeros
     C                   move      ucirdt        isodate
     C                   move      isodate       usadate
510bAC                   endif

     C                   eval      totiwgt = totiwgt + uciwgt
     C                   eval      toticnt = toticnt + 1

     C   90              write     head1
     C   90              write     head2
     C   90              write     columns
     C   90              eval      prtinb = uciinb
510bAC   90              eval      *in90 = *off
     C                   write     detail1

     C                   eval      prtinb = *blanks

     C                   enddo

     C                   write     totals
     C                   eval      *inlr = *on
      *----------------------------------------------------------------
      *
      *  zzgetitm

     C     zzgetitm      begsr

      *   Get item description.

     C                   eval      itdesc = *blanks
     C     itmkey        chain     piritem
     C                   if        %found(piritem)
     C                   eval      #itdesc = itdesc
     C                   endif

     C                   endsr

      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     key1          klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
510cAC                   kfld                    $pexd
510cAC                   kfld                    $pext
510cAC                   kfld                    $psq

      *  Define full key for detail file.

     C     itmkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    uciitm

      *   Get warehouse description.

     C                   move      $pwhsea       $pwhse

     C                   eval      whdesc = *blanks
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = 'Not Found'
     C                   endif

510cAC                   move      $pexdt        $pexd
510cAC                   move      $pextm        $pext
510cAC                   move      $pdtsq        $psq

     C                   write     head1
     C                   write     head2
     C                   write     columns
     C     key1          setll     ucicw5
     C     key1          reade     ucicw5
     C                   eval      prtinb = uciinb
510eAC*    UCI must be numeric, set 50 on if non-numeric found
510eAC     numbers       check     ucinbr                                 50
510eAC                   if        *in50 = *off
510dAC                   move      ucinbr        hlduci
510eAC                   endif

     C                   endsr

      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
      *
      *  Initialize message handling
      *
     C                   exsr      zzinz
     C                   endsr
      *----------------------------------------------------------------
