     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TX705   Remove Tax Rite Export Data - Post
     *  22 March 2007
     *  Jefrey Jahnke    Copied from RED705
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *  03/22/07  JCJ  5.10
     *   - Created
     *----------------------------------------------------------------
      * File Specs
      *
     Ftaxrdata3 uf   e           k disk
     Ftxftplog  uf   e           k disk
     Ftaxrstmp1 uf   e           k disk
     Ftaxtest1  uf   e           k disk
     FOptions   if   e           k disk

      *----------------------------------------------------------------
      *  Table and array definitions
      *----------------------------------------------------------------

     D Desc            S             50    DIM(2) CTDATA PERRCD(1)
     D Cmd             S             80    DIM(1) CTDATA PERRCD(1)

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *----------------------------------------------------------------

     D  Today          S               D   DATFMT(*ISO)
     D  Cuttax         S               D   DATFMT(*ISO)
     D  Tstdate        S               D   DATFMT(*ISO)
     D  hldexpfile     S                   like(txexpfile)
     D  mbrpfx         S              2

     D Datds           DS
     D  Hms                    1      6  0
     D  Mdy                    7     12  0
     D  Hmsmdy                 1     12  0

     D $Mdt            DS
     D  Errmsg                 1     50

     D  Errecs                 1      4P 0
     D  Erdesc                 5     50

     D Decds           DS
     D  Nbrrmv                 1      7  0
     D  Nbrmbr                 8     14  0

      *----------------------------------------------------------------
      *  *Taxr  -  Tax Rite options.
      *----------------------------------------------------------------
      *
      * Fields
      *
      *    OPTXHS  -  Days to keep Tax-Right export data (1-999).
      *    OPCMD1  -  Command for Tax-Right file processing in OR605
      *
      * Data structure
      *
     Dopdat2           ds
     D optxhs                  1      3  0 Inz
     D opcmd1                  4     11
     D optend                117    117

      *----------------------------------------------------------------
      *  Message control
      *----------------------------------------------------------------

     D Digits          C                   const('0123456789')
     D #msgf           C                   const('PIRMSGF   ')

     D                 DS
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     dim(128)
      *----------------------------------------------------------------
      *  Variables
      *----------------------------------------------------------------

     d qlen            s             15  5
     d $krphs          s              3  0
     d #pwhse          s              3  0
     d qcmd            s             80
     d $pprg           s             10
     d client          s             10
     d #pgmq2          s             10
     d $msgf           s             10
     d mbr             s             10
     d #msgid          s              7
     d #msgtp          s              7
     d #msgk           s              4
     d $pwhse          s              3
     d $prphs          s              3
     d eof             s              1

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $PPRG   - Program to send message back to.
      *      &PWHSE  - Warehouse
      *      &PRPHS  - Remove Tax Rite export data older than x days   .
      *
      *    Returned Parameters
      *      None
      *
      *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pprg
     c                   parm                    $pwhse
     c                   parm                    $prphs

     c                   move      $prphs        $krphs
     c                   move      $pwhse        #pwhse

      *  Define key for options file, Tax Rite options.

     c     *like         define    opwhse        kywhse
     c     opkey         klist
     c                   kfld                    kywhse
     c                   kfld                    opcode

      *  Define key for taxrdata file

     c     txkey         klist
     c                   kfld                    #pwhse
     c                   kfld                    kyexpfile

      *  Define key for txftplog file

     c     ftkey         klist
     c                   kfld                    txwhse
     c                   kfld                    txrtid

      *  Define key for Tax Rite file

     C     *like         Define    txexpfile     kyexpfile

      *  Get default cutoff days.

     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*TAXR   '
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      optxhs = 7
     C                   else
     C                   movel     opdata        opdat2
     C                   endif

      *  Validate days history to keep. If not valid or zero use
      *  system default.

     C     digits        check     $prphs                                 10
     C                   if        *in10 = *on or
     C                             $prphs = '000'
     C                   eval      $krphs = optxhs
     C                   endif

      *   Compute cutoff date for Tax Rite export data

     C     today         subdur    $krphs:*DAYS  cuttax

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------

      *  Delete Tax Rite export data older than x days.

     C                   exsr      zzrmvt

      *  Send messages.

     C                   exsr      zm0751

     C                   eval      *inlr = *on

      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
500 A
500 A* Get client id.
500 A
500 AC                   call      'GETCLIENT'
500 AC                   parm                    client
500 A
     C                   eval      decds = *zeros
     C                   eval      datds = *zeros
     C                   time                    hmsmdy
     C     *MDY          move      mdy           today
     C                   eval      errecs = *zeros
     C                   eval      erdesc = desc(1)

     C                   endsr
      *---------------------------------------------------------------
      *
      *  SUBROUTINE ZMxxxx  Control message display subfile
      *
      *    ZMSMSG  Send program message to a different program msgq
      *
     C     ZMSMSG        BEGSR

     C                   if        $msgf = *blanks
     C                   MOVE      #MSGF         $MSGF
     C                   endif

     C                   CALL      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2
     C                   parm                    #msgk

     C                   eval      #msgdt = *blanks
     C                   eval      $msgf  = *blanks

     C                   endsr
      *----------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *----------------------------------------------------------------
      *
      *     PIR0751  Records removed.
      *
     C     ZM0751        BEGSR

      *    Send message for number of receiving entries removed.

     C                   MOVE      'PIR0751'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   Z-ADD     NBRRMV        ERRECS
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG

      *    Send message for number of members removed.

     C                   Z-ADD     NBRMBR        ERRECS
     C                   MOVEL     DESC(2)       ERDESC
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   ENDSR
      *---------------------------------------------------------------
      *
      *    ZZRMVMBR   Remove Tax Rite export member
      *
     C     zzrmvmbr      begsr
      *
      *      Build command string to remove export member.
      *        RMVM file(taxrexp) MBR(xxxxxxxx)

     *   Create member name to remove.

     C                   eval      mbr = %subst(txexpfile:1:10)

     C                   eval      qcmd = cmd(1)
     C                   eval      qcmd = %replace(mbr:qcmd:24:10)

     C                   Call(e)   'QCMDEXC'
     C                   Parm                    Qcmd
     C                   parm      80            Qlen

     C                   If        Not %error
     C                   add       1             Nbrmbr
     C                   endif

     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZZRMVT   Remove Tax Rite export data older than x days
      *
     C     zzrmvt        begsr

      *      Only remove export data that has been sent to TaxRite.
      *      This is determined by txexpfile greater than blanks.
      *      txexpfile will have a value WMSYYYYMMDDHHMMSS.TXT

     C     txkey         setgt     taxrdata3
     C                   eval      eof = *off
     C                   dow       not %Eof(taxrdata3)
     C                   read      taxrdata3

      *    Extract date portion of timestamp. Ck if we're past cut-off.

     C                   Move      txexpts       tstdate
     C                   Select
     C                   When      %eof(taxrdata3)
     C                             or tstdate > cuttax
     C                   Leave

      *    Tax Rite data not exported.
     C                   When      txexpfile = *blanks
     C                   Iter

     C                   Other

     C                   if        tstdate < cuttax
     C                   delete    taxrec
     C                   eval      nbrrmv = nbrrmv + 1
     C                   exsr      zztxftp
     C                   exsr      zzstmp
     C                   exsr      zztest

      *   Remove export member everytime export file name changes.
     C                   If        txexpfile <> hldexpfile
     C                   exsr      zzrmvmbr
     C                   eval      hldexpfile = txexpfile
     C                   endif

     C                   endif

     C                   endsl
     C                   enddo

     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZZTXFTP    Delete Tax Rite ftp log records
      *
     C     zztxftp       begsr

     C     ftkey         setll     txftplog
     C                   dou       %eof(txftplog)
     C     ftkey         reade     txftplog
     C                   if        not %eof(txftplog)
     C                   delete    txftpr
     C                   endif
     C                   enddo

     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZZstmp     Delete Tax Rite stamping unit records
      *
     C     zzstmp        begsr

     C     ftkey         setll     taxrstmp1
     C                   dou       %eof(taxrstmp1)
     C     ftkey         reade     taxrstmp1
     C                   if        not %eof(taxrstmp1)
     C                   delete    tstmp
     C                   endif
     C                   enddo

     C                   endsr
      *---------------------------------------------------------------
      *
      *    ZZtest     Delete Tax test file records
      *
     C     zztest        begsr

     C     ftkey         setll     taxtest1
     C                   dou       %eof(taxtest1)
     C     ftkey         reade     taxtest1
     C                   if        not %eof(taxtest1)
     C                   delete    trec
     C                   endif
     C                   enddo

     C                   endsr
      *
      *----------------------------------------------------------------
      *
      *  Compile time tables
      *
**
Tax Rite Export Data
Tax Rite Export Members
**   RMVM  statment
RMVM FILE(TAXREXP) MBR(          )
