      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PT751S    Staging Export Closed Putaway/Replen/Transfer
     *  10 December 2013
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
650 A*    12/10/13  RTR  6.50
     *      - Created from PT741.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpt751     ip   e           k disk
     FLabel90   if   e           k disk
     F                                     infds(file1ds)
     Fliclog2   if   e           k disk
     Fpiruser1  if   e           k disk
     Fvslot1    if   e           k disk
     Fflgtran   o  a e           k disk
     Fexpstrn   o  a e           k disk
     *----------------------------------------------------------------
     *  Client ID
     *
      /COPY QCOPYSRC,ID#SGC
DRY A /COPY QCOPYSRC,ID#dairyla
     *----------------------------------------------------------------
     *  Constants
     *
     D forever         c                   const('1')
     *----------------------------------------------------------------
     *  Working variables
     *
     D batId           s             11
     D bslot           s                   like(lbdisp)
     D doflag          s              1
     D first           s              1  0
     D grtrn#          s              7  0
     D haveBatId       s               n
     D hrtn            s              8
     D kydisp          s                   like(lbdisp)
     D nwhse           s              3  0
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stampUC         s               z
     D today           s              8  0
     D x               s              2  0
     D zeroUploadDate  s              8s 0
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
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     d DryExportPgm    pr                  Extpgm('BFCELS01C')
     d* Input
     d   $hWhsen                      3  0
     d   $hbatid                     11
     d   $hflib                      10
     d* Output
     d   $hrtn                        8

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /COPY qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     D pt751s          pr                  extpgm('PT751S')
      * Input
     D   inWhse                       3    const

     D pt751s          pi
      * Input
     D   inWhse                       3    const
     *----------------------------------------------------------------
     *
     * Main line
     *
     *  Use first transaction as group transaction.
     C                   if        first = 0
     C                   eval      grtrn# = pttrn#
     C                   eval      first = 1
     C                   endif
     *  Move transaction info to export fields
     C                   exsr      fillpe
     *  Get user info.
     C     ptemp#        chain     piruser1                           79
     C                   if        not *in79
     C                   eval      peuser = uscode
     C                   endif
     C                   eval      doflag = *off
     *  Get label info.
     C     keylb         setll     label90
     C     1             do        10            x
     C     keylb         reade     label90                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *  Only process for putaway or transfer records.
     C                   if        lbtype <> 'P'  and
     C                             lbtype <> 'T'
     C                             and client <> SGC
     *
     *  Only process for putaway, replenishment or transfer records.
     C                             or client = SGC
     C                             and lbtype <> 'P'
     C                             and lbtype <> 'R'
     C                             and lbtype <> 'T'
     *
     C                   iter
     C                   endif
     *
     *  Get license plate info from license log file.
     C                   exsr      getlicloginf
     *
     *
     C                   eval      peltyp = lbtype
     C                   eval      doflag = *on
     *
     *  Reset counter back to 1 so that label info is loaded
     *  into first occurence.
     C                   if        pttask = 'TFRMOV'
     C                             and x = 2
     C                   eval      x = x - 1
     C                   endif
     *
     C                   select
     *
     C                   when      x = 1
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit1 = lbitem
     C                   eval      pefsl1 = lbdisp
     C                   eval      kydisp = pefsl1
     C                   exsr      zzslot
     C                   eval      pefsl1 = kydisp
     C                   eval      pefum1 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdisp
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   endif
     C                   eval      pelqp1 = lbqpck
     C                   eval      peuom1 = lbutyp
     C                   eval      petum1 = lbucod
     C                   eval      peolc1 = llolcns
     C                   eval      peflc1 = llflcns
     C                   eval      petlc1 = lllcns
     ***
     C                   when      x = 2
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit2 = lbitem
     C                   eval      pefsl2 = lbdisp
     C                   eval      kydisp = pefsl2
     C                   exsr      zzslot
     C                   eval      pefsl2 = kydisp
     C                   eval      pefum2 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit2 = lbitem
     C                   eval      petsl2 = lbdisp
     C                   eval      kydisp = petsl2
     C                   exsr      zzslot
     C                   eval      petsl2 = kydisp
     C                   endif
     C                   eval      pelqp2 = lbqpck
     C                   eval      peuom2 = lbutyp
     C                   eval      petum2 = lbucod
     C                   eval      peolc2 = llolcns
     C                   eval      peflc2 = llflcns
     C                   eval      petlc2 = lllcns
     ***
     C                   when      x = 3
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit3 = lbitem
     C                   eval      pefsl3 = lbdisp
     C                   eval      kydisp = pefsl3
     C                   exsr      zzslot
     C                   eval      pefsl3 = kydisp
     C                   eval      pefum3 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit3 = lbitem
     C                   eval      petsl3 = lbdisp
     C                   eval      kydisp = petsl3
     C                   exsr      zzslot
     C                   eval      petsl3 = kydisp
     C                   endif
     C                   eval      pelqp3 = lbqpck
     C                   eval      peuom3 = lbutyp
     C                   eval      petum3 = lbucod
     C                   eval      peolc3 = llolcns
     C                   eval      peflc3 = llflcns
     C                   eval      petlc3 = lllcns
     ***
     C                   when      x = 4
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit4 = lbitem
     C                   eval      pefsl4 = lbdisp
     C                   eval      kydisp = pefsl4
     C                   exsr      zzslot
     C                   eval      pefsl4 = kydisp
     C                   eval      pefum4 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit4 = lbitem
     C                   eval      petsl4 = lbdisp
     C                   eval      kydisp = petsl4
     C                   exsr      zzslot
     C                   eval      petsl4 = kydisp
     C                   endif
     C                   eval      pelqp4 = lbqpck
     C                   eval      peuom4 = lbutyp
     C                   eval      petum4 = lbucod
     C                   eval      peolc4 = llolcns
     C                   eval      peflc4 = llflcns
     C                   eval      petlc4 = lllcns
     ***
     C                   when      x = 5
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit5 = lbitem
     C                   eval      pefsl5 = lbdisp
     C                   eval      kydisp = pefsl5
     C                   exsr      zzslot
     C                   eval      pefsl5 = kydisp
     C                   eval      pefum5 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit5 = lbitem
     C                   eval      petsl5 = lbdisp
     C                   eval      kydisp = petsl5
     C                   exsr      zzslot
     C                   eval      petsl5 = kydisp
     C                   endif
     C                   eval      pelqp5 = lbqpck
     C                   eval      peuom5 = lbutyp
     C                   eval      petum5 = lbucod
     C                   eval      peolc5 = llolcns
     C                   eval      peflc5 = llflcns
     C                   eval      petlc5 = lllcns
     ***
     C                   when      x = 6
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit6 = lbitem
     C                   eval      pefsl6 = lbdisp
     C                   eval      kydisp = pefsl6
     C                   exsr      zzslot
     C                   eval      pefsl6 = kydisp
     C                   eval      pefum6 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit6 = lbitem
     C                   eval      petsl6 = lbdisp
     C                   eval      kydisp = petsl6
     C                   exsr      zzslot
     C                   eval      petsl6 = kydisp
     C                   endif
     C                   eval      pelqp6 = lbqpck
     C                   eval      peuom6 = lbutyp
     C                   eval      petum6 = lbucod
     C                   eval      peolc6 = llolcns
     C                   eval      peflc6 = llflcns
     C                   eval      petlc6 = lllcns
     ***
     C                   when      x = 7
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit7 = lbitem
     C                   eval      pefsl7 = lbdisp
     C                   eval      kydisp = pefsl7
     C                   exsr      zzslot
     C                   eval      pefsl7 = kydisp
     C                   eval      pefum7 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit7 = lbitem
     C                   eval      petsl7 = lbdisp
     C                   eval      kydisp = petsl7
     C                   exsr      zzslot
     C                   eval      petsl7 = kydisp
     C                   endif
     C                   eval      pelqp7 = lbqpck
     C                   eval      peuom7 = lbutyp
     C                   eval      petum7 = lbucod
     C                   eval      peolc7 = llolcns
     C                   eval      peflc7 = llflcns
     C                   eval      petlc7 = lllcns
     ***
     C                   when      x = 8
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit8 = lbitem
     C                   eval      pefsl8 = lbdisp
     C                   eval      kydisp = pefsl8
     C                   exsr      zzslot
     C                   eval      pefsl8 = kydisp
     C                   eval      pefum8 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit8 = lbitem
     C                   eval      petsl8 = lbdisp
     C                   eval      kydisp = petsl8
     C                   exsr      zzslot
     C                   eval      petsl8 = kydisp
     C                   endif
     C                   eval      pelqp8 = lbqpck
     C                   eval      peuom8 = lbutyp
     C                   eval      petum8 = lbucod
     C                   eval      peolc8 = llolcns
     C                   eval      peflc8 = llflcns
     C                   eval      petlc8 = lllcns
     ***
     C                   when      x = 9
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit9 = lbitem
     C                   eval      pefsl9 = lbdisp
     C                   eval      kydisp = pefsl9
     C                   exsr      zzslot
     C                   eval      pefsl9 = kydisp
     C                   eval      pefum9 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit9 = lbitem
     C                   eval      petsl9 = lbdisp
     C                   eval      kydisp = petsl9
     C                   exsr      zzslot
     C                   eval      petsl9 = kydisp
     C                   endif
     C                   eval      pelqp9 = lbqpck
     C                   eval      peuom9 = lbutyp
     C                   eval      petum9 = lbucod
     C                   eval      peolc9 = llolcns
     C                   eval      peflc9 = llflcns
     C                   eval      petlc9 = lllcns
     ***
     C                   when      x = 10
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit0 = lbitem
     C                   eval      pefsl0 = lbdisp
     C                   eval      kydisp = pefsl0
     C                   exsr      zzslot
     C                   eval      pefsl0 = kydisp
     C                   eval      pefum0 = lbucod
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit0 = lbitem
     C                   eval      petsl0 = lbdisp
     C                   eval      kydisp = petsl0
     C                   exsr      zzslot
     C                   eval      petsl0 = kydisp
     C                   endif
     C                   eval      pelqp0 = lbqpck
     C                   eval      peuom0 = lbutyp
     C                   eval      petum0 = lbucod
     C                   eval      peolc0 = llolcns
     C                   eval      peflc0 = llflcns
     C                   eval      petlc0 = lllcns
     ***
     C                   endsl
     C                   iter
     C                   enddo
     *
     C                   if        doflag = *on

     *    If first time, get batch id.
     *      If error, get out.

     C                   if        not haveBatId
     C                   exsr      zzzGetBatId
     C                   if        batId = ' '
     C                   goto      bottom
     C                   endif
     C                   eval      haveBatId = *on
     C                   endif

     *      Populate staging fields.
     C                   eval      pebatid = batId
     C                   eval      pestatus = 'R'
     C                   exsr      zzzGetStamps
     C                   eval      peststs = stamp
     C                   eval      pestsuc = stampuc
     C                   eval      peaddts = stamp
     C                   eval      peadduc = stampuc

     *  Add record to export file.
     C                   write     perec
     *
     *  Add record to history file FLGTRAN.
     *
     C                   exsr      fillfg
     C                   write     fgrec
     C                   else
     C                   clear                   perec
     C                   endif
     *
     C     bottom        tag
     *
     CLR                 if        haveBatId
     CLR                 exsr      zzzend
     *
     CLR                 if        client = Dairyland
     C                             and sqlstt = sqlSuccess
     CLR                 callp(e)  DryExportPgm(nwhse:batid:f1library:hrtn)
     CLR                 endif
     *
     CLR                 endif
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define partial key for LABEL file.
     *
     C     keylb         klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
     *
     *   Define partial key for LICLOG2 file.
     *
     C     keylc2        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbtrn#
     C                   kfld                    lblbl#
     *
     *   Define partial key for VSLOT1 file.
     *
     C     keyvs         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    kydisp
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert incoming alpha whse to numeric.
     C                   eval      nwhse = %dec(inwhse:3:0)
     *
     C                   eval      haveBatId = *off
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLPE   Fill export transaction fields.
     *
     C     fillpe        begsr
     *
     *  Initialize record
     *
     C                   clear                   perec
     *
     *  Move fields from transaction to export file.
     *
     C                   eval      petrn# = pttrn#
     C                   eval      petask = pttask
     C                   eval      pecat  = ptcat
     C                   eval      pesub  = ptsub
     C                   eval      pewhse = ptwhse
     C                   eval      pewhdp = ptwhdp
     C                   eval      pestyp = ptstyp
     C                   eval      peshft = ptshft
     C                   eval      pecrew = ptcrew
     C                   eval      peemp# = ptemp#
     C                   eval      pecube = ptcube
     C                   eval      peswgt = ptswgt
     C                   eval      pepcs  = ptpcs
     C                   eval      peqty1 = ptqty1
     C                   eval      peqty2 = ptqty2
     C                   eval      peqty3 = ptqty3
     C                   eval      pegdte = ptgdte
     C                   eval      pegtim = ptgtim
     C                   eval      pesdte = ptsdte
     C                   eval      pestim = ptstim
     C                   eval      peedte = ptedte
     C                   eval      peetim = ptetim
     C                   eval      peetyp = ptetyp
     C                   eval      pertpo = ptrtpo
     C                   eval      pegrp1 = ptgrp1
     C                   eval      pegrp2 = ptgrp2
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILLFG  Fill flag fields.
     *
     C     fillfg        begsr
     *
     *  Initialize record
     *
     C                   clear                   fgrec
     *
     *  Move fields from transaction to flag file.
     *
     C                   eval      fgwhse = ptwhse
     C                   eval      fgtrn# = pttrn#
     C                   eval      fgedte = today
     C                   time                    fgetim
     C                   eval      fggtrn = grtrn#
     C                   eval      fgrdte = 0
     C                   eval      fgrtim = 0
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETLICLOGINF   Get License Log info from file.
     *
     C     getlicloginf  begsr
     *
     C     keylc2        setgt     liclog2
     C     keylc2        readpe    liclog2
     C                   if        %eof(liclog2)
     C                   eval      lllcns  = ' '
     C                   eval      llolcns = ' '
     C                   eval      llflcns = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSLOT  Get Base slot for Virtual if host only has base slots.
     *
     C     zzslot        begsr
     *
     *
     C     keyvs         chain     vslot1                             79
     *
     *  Use base slot.
     *
     C                   if        not *in79
     C                   eval      kydisp = vspdis
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c     zzzEnd        begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :nwhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

      /end-free
     c                   endsr
     *
     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------

     c     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId(nwhse: 'EXPTRN': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr
