     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CK705   Remove Check Right Export Data - Post
     *  22 June 2009
     *  Jefrey Jahnke    Copied from TAX705
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *  06/22/09  JCJ  5.20
     *   - Created
     *----------------------------------------------------------------
     * File Specs
     *
     Fckrdata3  uf   e           k disk
     Fckftplog  uf   e           k disk
     Fckrstmp1  uf   e           k disk
     Fckrtest1  uf   e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D desc            s             50    dim(2) ctdata perrcd(1)
     D cmd             s             80    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D  today          s               d   datfmt(*iso)
     D  cuttax         s               d   datfmt(*iso)
     D  tstdate        s               d   datfmt(*iso)
     D  hldexpfile     s                   like(ckexpfile)
     D  mbrpfx         s              2

     D datds           ds
     D  hms                    1      6  0
     D  mdy                    7     12  0
     D  hmsmdy                 1     12  0

     D $mdt            ds
     D  errmsg                 1     50

     D  errecs                 1      4p 0
     D  erdesc                 5     50

     D decds           ds
     D  nbrrmv                 1      7  0
     D  nbrmbr                 8     14  0

     *----------------------------------------------------------------
     *  *Ckr  -  Check Right options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCKHS  -  Days to keep Check Right export data (1-999).
     *    OPCMD2  -  Command for Check Right file processing in OR605
     *
     * Data structure
     *
     Dopdat2           ds
     D opckhs                  1      3  0 inz
     D opcmd2                  4     11
     D optend                117    117

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D digits          c                   const('0123456789')
     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     dim(128)
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D qlen            s             15  5
     D $krphs          s              3  0
     D #pwhse          s              3  0
     D qcmd            s             80
     D $pprg           s             10
     D client          s             10
     D #pgmq2          s             10
     D $msgf           s             10
     D mbr             s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #msgk           s              4
     D $pwhse          s              3
     D $prphs          s              3
     D eof             s              1
     D kyexpfile       s                   like(ckexpfile)
     D kywhse          s                   like(opwhse)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      &PWHSE  - Warehouse
     *      &PRPHS  - Remove Tax Rite export data older than x days   .
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pprg
     C                   parm                    $pwhse
     C                   parm                    $prphs

     C                   move      $prphs        $krphs
     C                   move      $pwhse        #pwhse

     *  Define key for options file, Tax Rite options.

     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    opcode

     *  Define key for taxrdata file

     C     ckkey         klist
     C                   kfld                    #pwhse
     C                   kfld                    kyexpfile

     *  Define key for txftplog file

     C     ftkey         klist
     C                   kfld                    ckwhse
     C                   kfld                    ckrtid

     *  Define key for Check Right file


     *  Get default cutoff days.

     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*CKR    '
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      opckhs = 7
     C                   else
     C                   eval      opdat2 = opdata
     C                   endif

     *  Validate days history to keep. If not valid or zero use
     *  system default.

     C     digits        check     $prphs                                 10
     C                   if        *in10 = *on or
     C                             $prphs = '000'
     C                   eval      $krphs = opckhs
     C                   endif

     *   Compute cutoff date for Tax Rite export data

     C     today         subdur    $krphs:*days  cuttax

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Delete Check Right export data older than x days.

     C                   exsr      zzrmvt

     *  Send messages.

     C                   exsr      zm0751

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
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
     C     *mdy          move      mdy           today
     C                   eval      errecs = *zeros
     C                   eval      erdesc = desc(1)

     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr

     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif

     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2
     C                   parm                    #msgk

     C                   eval      #msgdt = *blanks
     C                   eval      $msgf  = *blanks

     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *
     *     PIR0751  Records removed.
     *
     C     zm0751        begsr

     *    Send message for number of receiving entries removed.

     C                   eval      #msgid = 'PIR0751'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errecs = nbrrmv
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg

     *    Send message for number of members removed.

     C                   eval      errecs = nbrmbr
     C                   movel     desc(2)       erdesc
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRMVMBR   Remove Tax Rite export member
     *
     C     zzrmvmbr      begsr
     *
     *      Build command string to remove export member.
     *        RMVM file(taxrexp) MBR(xxxxxxxx)

     *   Create member name to remove.

     C                   eval      mbr = %subst(ckexpfile:1:10)

     C                   eval      qcmd = cmd(1)
     C                   eval      qcmd = %replace(mbr:qcmd:23:10)

     C                   call(e)   'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen

     C                   if        not %error
     C                   add       1             nbrmbr
     C                   endif

     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRMVT   Remove Check Right export data older than x days
     *
     C     zzrmvt        begsr

     *      Only remove export data that has been sent to TaxRite.
     *      This is determined by txexpfile greater than blanks.
     *      txexpfile will have a value WMSYYYYMMDDHHMMSS.TXT

     C     ckkey         setgt     ckrdata3
     C                   eval      eof = *off
     C                   dow       not %eof(ckrdata3)
     C                   read      ckrdata3

     *    Extract date portion of timestamp. Ck if we're past cut-off.

     C                   move      ckexpts       tstdate
     C                   select
     C                   when      %eof(ckrdata3)
     C                             or tstdate > cuttax
     C                   leave

     *    Tax Rite data not exported.
     C                   when      ckexpfile = *blanks
     C                   iter

     C                   other

     C                   if        tstdate < cuttax
     C                   delete    ckrrec
     C                   eval      nbrrmv = nbrrmv + 1
     C                   exsr      zzckftp
     C                   exsr      zzstmp
     C                   exsr      zztest

     *   Remove export member everytime export file name changes.
     C                   if        ckexpfile <> hldexpfile
     C                   exsr      zzrmvmbr
     C                   eval      hldexpfile = ckexpfile
     C                   endif

     C                   endif

     C                   endsl
     C                   enddo

     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZCKFTP    Delete Check Right ftp log records
     *
     C     zzckftp       begsr

     C     ftkey         setll     ckftplog
     C                   dou       %eof(ckftplog)
     C     ftkey         reade     ckftplog
     C                   if        not %eof(ckftplog)
     C                   delete    ckftpr
     C                   endif
     C                   enddo

     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZstmp     Delete Tax Rite stamping unit records
     *
     C     zzstmp        begsr

     C     ftkey         setll     ckrstmp1
     C                   dou       %eof(ckrstmp1)
     C     ftkey         reade     ckrstmp1
     C                   if        not %eof(ckrstmp1)
     C                   delete    cstmp
     C                   endif
     C                   enddo

     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZtest     Delete Tax test file records
     *
     C     zztest        begsr

     C     ftkey         setll     ckrtest1
     C                   dou       %eof(ckrtest1)
     C     ftkey         reade     ckrtest1
     C                   if        not %eof(ckrtest1)
     C                   delete    crec
     C                   endif
     C                   enddo

     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Check Right Export Data
Check Right Export Members
**   RMVM  statment
RMVM FILE(CKREXP) MBR(          )
