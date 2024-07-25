     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETIRPL   Get Interleaving Replenishment
     *  27 April 2006
     *  Max Blacknik
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    04/27/06  MLB  5.00
     *      - Created.
500aA*    04/27/06  MLB  5.00a
     *      - Enh: Client custom code included.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FLabel7    if   e           k disk
     FLayouth   if   e           k disk
     Foptions   if   e           k disk
     Fpirtran3  if   e           k disk
     F                                     rename(ptrec:ptrec3)
     Fprplfil1  if   e           k disk
     Fslot1     if   e           k disk
     F                                     rename(slrec:slrec1)
     Fslot2     if   e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:slrec3)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  External data structure for Dakota Realtime Interface.
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $ptype                81     88
     *
     *   Last putaway location info.
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $paisl                27     29
     D  $ploc                 30     32  0
     D  $prlvl                33     34  0
     D  $phand                35     36
     D  $pdisp                37     48
     *
     *----------------------------------------------------------------
     *   From/To location info for replenishment.
     D $parm2          ds
     D  $2whse                 1      3  0
     D  $2whdp                 4      8
     D  $2fasl                 9     11
     D  $2floc                12     14  0
     D  $2flvl                15     16  0
     D  $2fhnd                17     18
     D  $2fdis                19     30
     D  $2tasl                31     33
     D  $2tloc                34     36  0
     D  $2tlvl                37     38  0
     D  $2thnd                39     40
     D  $2tdis                41     52
     D  $2titem               53     67
     D  $2qrpl                68     72  0
     D  $2rplt                73     74
     D  $2ucod                75     76
     D  $2trn#                77     83  0
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
     *----------------------------------------------------------------
     *
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
     *
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D done            s              1    inz('0')
     D error           s              1    inz('0')
     D forevr          s              1    inz('1')
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opcode)
     D kydisp          s                   like(sldisp)
     D kystat          s                   like(ptstat)
     D kytrn#          s                   like(pttrn#)
     D kywhdp          s                   like(lbwhdp)
     D kywhse          s                   like(opwhse)
     D wkgrp1          s                   like(ptgrp1)
     D wkgrp2          s                   like(ptgrp2)
     D maxreplenish    s              3  0
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *
     *----------------------------------------------------------------
     *  *INTERLV -  Interleaving Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPINTL  -  Allow interleaving (Y/N).
     *    OPMAXR  -  Maximum number of replenishments allowed.
     *
     *    OPFSAB  -  From slot - Aisles before current aisle.
     *    OPFSAA  -  From slot - Aisles after current aisle.
     *    OPFSBB  -  From slot - Bays before current location.
     *    OPFSBA  -  From slot - Bays after current location.
     *
     *    OPTSAB  -  To slot - Aisles before current aisle.
     *    OPTSAA  -  To slot - Aisles after current aisle.
     *    OPTSBB  -  To slot - Bays before current location.
     *    OPTSBA  -  To slot - Bays after current location.
     *
     * Data structure
     *
     Dopdtai           ds
     D  opintl                 1      1
     D  opmaxr                 2      3  0
     D  opfsab                 4      5  0
     D  opfsaa                 6      7  0
     D  opfsbb                 8     10  0
     D  opfsba                11     13  0
     D  optsab                14     15  0
     D  optsaa                16     17  0
     D  optsbb                18     20  0
     D  optsba                21     23  0
     D  optend               117    117
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
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *START   - Find first Letdown or Priority Replen.
     *              *NEXT    - Find next Letdown or Priority Replen.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *OFF     - Interleave replenishments not activated.
     *              *FOUND   - Replenishment found that matches
     *                         interleaving specs.
     *              *NOREPL  - No interleave replenishment found
     *                         that matches specs.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $parm2
     *----------------------------------------------------------------
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     *
     C                   select
     *
     *      Find next available interleaving replenishments.
     C                   when      opintl = 'Y'
     C                             and maxreplenish >= 1
     C                   exsr      zzfind
     *
     *      Maximum number of interleaving replenishments processed.
     C                   when      opintl = 'Y'
     C                             and maxreplenish <= 0
     C                   eval      $prtn = '*NOREPL '
     *
     *      Interleaving replenishments not activated.
     C                   when      opintl = 'N'
     C                   eval      $prtn = '*OFF    '
     *
     C                   other
     C                   eval      $prtn = '*ERROR  '
     *
     C                   endsl
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCVDT  Convert date to proper format.
     *
     C     zzcvdt        begsr
     *
     *    Convert date into proper format.
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C     endcvd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      forevr = *off
     *
     *    Define partial key for LABEL7 file.
     *
     C     lbkey7        klist
     C                   kfld                    pttrn#
     *
     *    Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     *
     *    Define partial key for PIRTRAN3 file.
     *
     C                   eval      wkgrp1 = 'L'
     C                   eval      wkgrp2 = ' '
     C     ptkey3        klist
     C                   kfld                    $pwhse
     C                   kfld                    wkgrp1
     C                   kfld                    wkgrp2
     *
     *    Define Partial key for PRPLFIL1 file.
     *
     C     keypr1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *    Retrieve interleaving replenishment options.
     C                   exsr      zzilev
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      done = *off
     *
     *      Reset Interleaving replenishments counter.
     C                   if        $pcmd = '*START  '
     C                   eval      maxreplenish = opmaxr
     *
     C                   else
     *
     *      Decrement interleaving replenishment counter.
     C                   eval      maxreplenish = maxreplenish - 1
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZILEV   Retrieve Interleaving options
     *
     C     zzilev        begsr
     *
     C                   eval      kywhse = $pwhse
     C                   eval      kycode = '*INTERLV'
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      opintl = 'N'
     C                   eval      opmaxr = *zeros
     C                   eval      opfsab = *zeros
     C                   eval      opfsaa = *zeros
     C                   eval      opfsbb = *zeros
     C                   eval      opfsba = *zeros
     C                   eval      optsab = *zeros
     C                   eval      optsaa = *zeros
     C                   eval      optsbb = *zeros
     C                   eval      optsba = *zeros
     *
     C                   else
     C                   eval      opdtai =opdata
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FINDLETDOWN  Find next available Letdown
     *
     C     findletdown   begsr
     *
     C                   eval      done = *off
     *    Get next Let-Down record.
     C     ptkey3        setll     pirtran3
     *    -Match not found
     C                   if        not %equal(pirtran3)
     C                   eval      done = *on
     C                   goto      endletdown
     C                   endif
     *
     *    -Match found - Read the records until we find the Let-Down.
     C     next          tag
     C     ptkey3        reade     pirtran3
     *    - EOF
     C                   if        %eof(pirtran3)
     C                   eval      done = *on
     C                   goto      endletdown
     C                   endif
     *
     *    - Found a record
     C                   if        pttask <> 'REPL    '  and
     C                             pttask <> 'REPLBK  '  or
     C                             ptrtpo = *blanks
     C                   goto      next
     C                   endif
     *
     *    - Transaction inuse.
     C                   if        ptstat >= '2'
     C                   goto      next
     C                   endif
     *    - Different department.
     C                   if        ptwhdp <> $pwhdp
     C                   goto      next
     C                   endif
     *    Found a Letdown record. Process it.
     *
     *    - Get label record. LetDowns have only one label record
     *      per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7
     *
     *    - Wrong transaction number.
     C                   if        lbtrn# <> pttrn#  or
     C                             %eof(label7)
     C                   goto      next
     C                   endif
     *
     *    - See if Letdown meets specifications for interleaving
     *      with putaways.
     ***                if        w7fas > *blanks  and
     ***                          spfcrp = '*NO '
     ***                goto      next
     ***                endif
     *
     *    Valid Letdown found. Send back info to calling pgm.
     C                   eval      $prtn  = '*FOUND  '
     C                   eval      $2rplt = 'LD'
     C                   eval      $2whse = $pwhse
     C                   eval      $2whdp = lbwhdp
     C                   eval      $2fasl = lbaisl
     C                   eval      $2floc = lbloc
     C                   eval      $2flvl = lbrlvl
     C                   eval      $2fhnd = lbhand
     C                   eval      $2fdis = lbdisp
     C                   eval      $2tasl = lbasl2
     C                   eval      $2tloc = lbloc2
     C                   eval      $2tlvl = lblvl2
     C                   eval      $2thnd = lbhnd2
     C                   eval      $2tdis = lbdsp2
     C                   eval      $2titem= lbitem
     C                   eval      $2qrpl = lbqpck
     C                   eval      $2trn# = lbtrn#
     *
     C     endletdown    endsr
     *
     *----------------------------------------------------------------
     *
     *  FINDPRTYRPL   Find next Priority Replenishment.
     *
     C     findprtyrpl   begsr
     C     keypr1        setll     prplfil1
     *
     C                   dow       forevr = forevr
     C     keypr1        reade     prplfil1
     C                   select
     C                   when      %eof(prplfil1)
     *
     C                   eval      done = *on
     C                   eval      $prtn  = '*NOREPL '
     C                   leave
     *
     C                   when      %eof(prplfil1) or
     C                             prflag <> 'S'  or
     ***                          w7fas > *blanks  and
     ***                          prtail < frmasl  or
     ***                          w7fas > *blanks  and
     ***                          prtail > toaisl  or
     *     Not a normal case replenishment.
     C                             prrplt <> ' '
     C                   iter
     *
     C                   other
     *
     *    Valid Priority Replenishment found.
     *    Send info back to calling pgm.
     C                   eval      done   = *off
     C                   eval      $prtn  = '*FOUND  '
     C                   eval      $2rplt = 'PR'
     C                   eval      $2whse = $pwhse
     C                   eval      $2whdp = prwhdp
     C                   eval      $2fasl = prfail
     C                   eval      $2floc = prfloc
     C                   eval      $2flvl = prflvl
     C                   eval      $2fhnd = prfhnd
     C                   eval      $2fdis = prfdis
     C                   eval      $2tasl = prtail
     C                   eval      $2tloc = prtloc
     C                   eval      $2tlvl = prtlvl
     C                   eval      $2thnd = prthnd
     C                   eval      $2tdis = prtdis
     C                   eval      $2titem= pritem
     C                   eval      $2qrpl = prqty
     C                   eval      $2trn# = prseq#
     C                   leave
     *
     C                   endsl
     C                   enddo
     *
     C     endprtyrpl    endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIND   Find next available interleaving replenishment.
     *
     C     zzfind        begsr
     *
     *    Start new transaction.
     *
     C                   exsr      findletdown
     *
     C                   select
     *
     *    No slot entered and no letdowns found - Check for priority
     *    replenishments to process.
     *
     C                   when      done = *on
     C                   exsr      findprtyrpl
     C                   endsl
     *
     *
     C                   if        done = *on
     C*                  eval      $prtn  = '*NOREPL '
     C                   endif
     *
     C     endfind       endsr
     *
     *----------------------------------------------------------------*********
     *
     *  Compile time tables
     *
