     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PT725     Export Route Info - Post
     *  20 April 2006
     *  Roxanne Harrison
     *
     *  NOTE:
     *     - Need to compile with TYPECONV = *DATETIME for datestamp
     *
     *----------------------------------------------------------------
     *  Revisions
500 A*    04/20/06  RH   5.00
     *      -  Created
500aA*    05/09/06  JJ   5.00a
     *      -  Enh: Revised to use subprogram GETPSLT to get pick slot.
500bA*    05/09/06  MLB  5.00b
     *      -  Fix: Revised program to only routine FILLFG and write
     *         rcd fmt FRREC when LR=On.
     *      -  Enh: Revised program to remove file RTEHED from program.
     *         Use route number passed from calling pgm.
500cA*    05/10/06  MLB  5.00c
     *      -  Enh: Added client custom code support to program.
510aA*    06/28/06  RH   5.10a
     *      -  Enh: Add REPAL# from PSPAL# field in PLTSUM4.
520aA*    07/28/09  GJA  5.20a
     *      -  Fix: Program was getting stuck in a loop.
     *
640 A*    06/13/11  MLB  6.40
     *      -  Fix: Revised program to set field REUWGT to 9,999.9 lbs
     *         if item unit weight greater than 9999.9.
     *      -  Fix: Revised program to set field REUCUB to 99.999
     *         if item unit cube greater than 99.999.
     *      -  Changes were done to both fields to prevent against
     *         MCH1210 Receiver value too small to hold result error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: I Supply
ISYaA*    05/10/06  MLB  ISYa
     *      -  Revised program to omit Merge records from export file.
     *         Note: This is a temp mod until Truck Builder fully active.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpt725     ip   e           k disk
     FPiritem   if   e           k disk
     Fpiruser1  if   e           k disk
     Fordh      if   e           k disk
510aAFpltsum4   if   e           k disk
500bDF*rtehed    if   e           k disk
     Fflgrti    o  a e           k disk
     Fexpfrti   o  a e           k disk
500cA*------------------------------------------------------------------
500cA*  Client id's for custom mods.
500cA*------------------------------------------------------------------
ISYaA /copy qcopysrc,id#isupply
500cAD client          s             10
500cAD clientloc       s             10

     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     D tsinz           c                   const('0001-01-01-00.00.00.000000')
     *----------------------------------------------------------------
     *  Variables
     D bslot           s                   like(lbdisp)
     D doflag          s              1
     D first           s              1  0
     D grtrn#          s              7  0
     D kydisp          s                   like(lbdisp)
     D today           s              8  0
     D x               s              2  0
     *
     D dftstamp        s               z
     D currstamp       s               z
     D datestamp       s               d
     D timestamp       s               t
500aAD $scmd           s              8
500aAD $swhse          s              3  0
500aAD $sitem          s             15
500aAD woslot          s             12
500aAD $saisl          s              3
500aAD $sloc           s              3  0
500aAD $srlvl          s              2  0
500aAD $shand          s              2
500aAD $srtn           s              8
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
     *  Parameters
     *
     *    Input Parameters
500bM*      $PRTE  - Route number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
500bAC     *entry        plist
500bAC                   parm                    $prte             5
ISYaA*
ISYaAC                   if        client = isupply
ISYaA*    Omit all Merge records from export.
ISYaAC                   if        lbtype = 'M'
ISYaAC                   goto      Bottom
ISYaAC                   endif
ISYaAC                   endif
     *
     *  Move transaction info to export fields
     C                   exsr      fillpe
     *
     *  Add record to export file.
     C                   write     rerec
     *
     *  Add record to history file FLGTRAN.
     *
520aMC     bottom        tag
500bMCLR                 exsr      fillfg
500bMCLR                 write     frrec
     *
520aDC*****bottom        tag
520aACLR                 return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

500cA*  Get client id

500cAC                   call      'GETCLIENT'
500cAC                   parm                    client
     *
     *   Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *   Define key for ORDH file.
     *
     C     keyod         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     *
     *   Define key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
510aA*
510aA*   Define key for PLTSUM4 file.
510aA*
510aAC     keyps         klist
510aAC                   kfld                    lbtrn#
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
     *
     *  FILLPE   Fill export route info fields.
     *
     C     fillpe        begsr
     *
     *  Initialize record
     *
     C                   clear                   rerec
     *  Get needed info from ORDH and PIRITEM files
     C     keyod         chain     ordh                               79
     C                   if        not *in79
     C                   eval      recust= ohcust
     C                   eval      record = ohcord
     C                   endif
     *
     C     keyit         chain     piritem                            79
     C                   if        not *in79
     C                   movel     itdesc        redesc
     C                   endif
500bDC*    keyrh         chain     rtehed                             77
500bDC*                  if        not *in77
500bMC                   movel     $prte         rerte
500bDC*                  endif
     *
     *  Convert report date to YYMMDD.
     C                   eval      reymd = 0
     C                   eval      $cvcmd = '*CMDYMD '
     C                   move      lbrdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      reymd = $cvd6o
510aA*
510aA*  Get needed info from PLTSUM file.
510aAC     keyps         setll     pltsum4
510aAC     nxt1          tag
510aAC     keyps         reade     pltsum4                                78
510aAC                   if        *in78 = *off
510aAC                   if        lbpal# = psplid
510aAC                   eval      repal# = pspal#
510aAC                   else
510aAC                   goto      nxt1
510aAC                   endif
510aAC                   endif
     *
     *
     *  Move fields from transaction to export file.
     *
     C*                  movel     lbrte         rerte
     C                   eval      restop = lbstop
     C**                 eval      reymd = lbrdte
     C                   eval      rewhdp = lbwhdp
     C*                  eval      reitem = lbitem
     C                   movel     lbitem        reitem
     C                   eval      redisp = lbdisp
     C                   eval      reqtys = lbqpck
640 A*
640 AC                   if           lbuwgt < -9999.9
640 AC                             or lbuwgt >  9999.9
640 AC                   eval      reuwgt = 9999.9
640 AC                   else
640 A*
     C                   eval      reuwgt = lbuwgt
640 AC                   endif
640 A*
640 AC                   if           lbucub < -99.999
640 AC                             or lbucub >  99.999
640 AC                   eval      reucub = 99.999
640 AC                   else
640 A*
     C                   eval      reucub = lbucub
640 AC                   endif
     *
500aAC                   if            lbasl2 = 'OUT'
500aAC                             and lbdisp = ' '
500aAC                   eval      $scmd = '*FIRST  '
500aAC                   call      'GETPSLT'
500aAC                   parm                    $scmd
500aAC                   parm      lbwhse        $swhse
500aAC                   parm      lbitem        $sitem
500aAC                   parm      *blanks       woslot
500aAC                   parm      *blanks       $saisl
500aAC                   parm      *zeros        $sloc
500aAC                   parm      *zeros        $srlvl
500aAC                   parm      *blanks       $shand
500aAC                   parm      *blanks       $srtn
500aAC                   if        $srtn <> '*NONE   '
500aAC                   eval      redisp = woslot
500aAC                   endif
500aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLFG  Fill flag fields.
     *
     C     fillfg        begsr
     *
     *  Initialize record
     *
     C                   clear                   frrec
     *  Get needed info from RTEHED files
     C*    keyrh         chain     rtehed                             79
500bDC*                  if        not *in77
500bMC                   eval      frrte = $prte
500bDC*                  endif
     C*     Convert date/time to datestamp.
     C                   call      'GETTS'
     C                   parm                    frgdts
     *
     *  Move fields from label to flag file.
     *
     C                   eval      frwhse = lbwhse
     C                   eval      frrtid = lbrte
     C                   eval      frstat = ' 0'
     C                   eval      fredts = tsinz
     C                   eval      frrdts = tsinz
     C                   eval      freby = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
