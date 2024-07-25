     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PT725B    RE-Export Route Info - Post
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
     *      -  Fix: Revised program to only routine FILLFG and update
     *         rcd fmt FRREC when LR=On.
     *      -  Enh: Revised program to remove file RTEHED from program.
     *         Use route number passed from calling pgm.
500cA*    05/10/06  MLB  5.00c
     *      -  Enh: Added client custom code support to program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: I Supply
ISY A*    05/10/06  MLB  ISY1
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
500bDF*rtehed    if   e           k disk
     Fflgrti    uf   e           k disk
     Fexpfrti   o  a e           k disk
500cA*------------------------------------------------------------------
500cA*  Client id's for custom mods.
500cA*------------------------------------------------------------------
ISY1A /copy qcopysrc,id#isupply
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
ISY1A*
ISY1AC                   if        client = isupply
ISY1A*    Omit all Merge records from export.
ISY1AC                   if        lbtype = 'M'
ISY1AC                   goto      Bottom
ISY1AC                   endif
ISY1AC                   endif
     *
     *  Move transaction info to export fields
     C                   exsr      fillpe
     *
     *  Add record to export file.
     C                   write     rerec
     *
     *  Add record to history file FLGTRAN.
     *
500bMCLR                 exsr      fillfg
500bMCLR                 if        not *in79
500bMCLR                 update    frrec
500bMCLR                 endif
     *
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
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
     *   Define key for FLGRTI file.
     *
     C     keyfg         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     *
     *   Define key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
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
     *  Convert report date to YYMMDD.
417fDC                   eval      reymd = 0
417fDC                   eval      $cvcmd = '*CMDYMD '
     C                   move      lbrdte        $cvd8i
417fDC                   call      @cvtdt
417fDC                   parm                    $cvtdt
417fDC                   eval      reymd = $cvd6o
     *
     *  Move fields from transaction to export file.
     *
500aDC*                  movel     lbrte         rerte
     C                   eval      restop = lbstop
     C**                 eval      reymd = lbrdte
     C                   eval      rewhdp = lbwhdp
     C*                  eval      reitem = lbitem
     C                   movel     lbitem        reitem
     C                   eval      redisp = lbdisp
     C                   eval      reqtys = lbqpck
     C                   eval      reuwgt = lbuwgt
     C                   eval      reucub = lbucub
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
     *
     *  Get FLGRTI record.
     C     keyfg         setll     flgrti
     C     keyfg         reade     flgrti                                 79
     C                   if        not *in79
500eAC*     Convert date/time to datestamp.
500eAC**                 call      'GETTS'
500eAC**                 parm                    frrdts
     C**                 eval      fgstat = '03'
     C                   endif
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
