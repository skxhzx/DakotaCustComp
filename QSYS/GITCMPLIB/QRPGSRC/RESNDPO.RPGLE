     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2008')

     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  RESNDPO   Update EXPFPOH/EXPFPOD with p/o from History files.
     *  20 August 2008
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
AFS A*    08/01/06  MLB  AFS
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpohhdr    if   e           k disk
     Fpohdtl1   if   e           k disk
     Fexpfpoh   o    e             disk
     Fexpfpod   o    e             disk

     *----------------------------------------------------------------
     *  Program Constants
     *----------------------------------------------------------------

     D letter          c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D number          c                   '1234567890'

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pos1            s              1
     D pos2            s              1

     D $msgf           s             10
     D $prtn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D count           s              9  0
     D dummy           s              3  0
     D enter           s              5  0
     D error           s               n
     D firstloc        s              3  0
     D forever         s               n
     D help            s              5  0
     D lastloc         s              3  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1

     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76

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
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $ppo              9
     C                   parm                    $pexpdate         8 0
     C                   parm                    $pexptime         6 0

     C     pohdr         chain     pohhdr
     C                   if        %found(pohhdr)
     C                   exsr      filpeh
     C                   write     pehrec
     *
     *
     C     pohdr         setll     pohdtl1
     C     forever       doweq     forever
     C     pohdr         reade     pohdtl1
     C                   select
     C                   when      %eof(pohdtl1)
     C                   leave
     *
     C                   other
     *
     C                   exsr      filped
     C                   write     pedrec
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   endif

     *
     *  We are finished so get out
     *
     C                   MOVE      *ON           *INLR
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
     C     pohdr         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    $ppo
     C                   KFLD                    $pexpdate
     C                   KFLD                    $pexptime
     *
     C                   endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  FILPEH   Fill p/o export header fields.
     C*
     CSR   filpeh        begsr
     C*
     C*  Initialize record
     C*
     CSR                 clear                   pehrec
     C*
     C*  Move fields from order file to export file.
     C*
     CSR                 z-add     phhwhs        pehwhs
     CSR                 move      PHHPO         PEHPO
     CSR                 z-add     PhHVEN        PEHVEN
     CSR                 move      PhHVNA        PEHVNM
     CSR                 move      PhHVA1        PEHAD1
     CSR                 move      PhHVA2        PEHAD2
     CSR                 move      PhHVCT        PEHCTY
     CSR                 move      PhHVST        PEHST
     CSR                 move      PhHVZP        PEHZP1
     CSR                 z-add     PhHDte        PEHDTE
     CSR                 z-add     phHTIM        PEHTIM
     CSR                 move      PhHAMP        PEHAMP
     C*
     CSR                 endsr
     C*----------------------------------------------------------------
     C*
     C*  FILPED  Fill export detail fields.
     C*
     CSR   filped        begsr
     C*
     C*  Initialize record
     C*
     CSR                 clear                   pedrec
     C*
     C*  Move fields from History p/o detail file to export file.
     C*
     CSR                 Z-ADD     phdwhs        pedwhs
     CSR                 MOVE      PhDPO         PEDPO
     CSR                 Z-ADD     PhDSEQ        PEDSEQ
     CSR                 MOVE      PhDITM        PEDITM
     CSR                 MOVE      PhDVIT        PEDVIT
     CSR                 MOVE      PhDSPC        PEDSPC
     CSR                 Z-ADD     PhDQO1        PEDQ1
     CSR                 Z-ADD     PhDQO2        PEDQ2
     CSR                 Z-ADD     PhDQO3        PEDQ3
     CSR                 Z-ADD     PhDQR1        PEDQR1
     CSR                 Z-ADD     PhDQR2        PEDQR2
     CSR                 Z-ADD     PhDQR3        PEDQR3
     CSR                 Z-ADD     PhDwgt        PEDWGT
     C*
     CSR                 endsr
