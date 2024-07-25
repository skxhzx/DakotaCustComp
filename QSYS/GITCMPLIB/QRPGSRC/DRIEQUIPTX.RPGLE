     H NoMain
      /copy bfccgilib/qcopysrc,hspecs
      *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  BTSTRANB  File routines for BTSTRANB
     *  04 November 2002
     *  Dave Sommerville
     *
416  *    11/04/02  DAS  1.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    When creating for the first time:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V4R4M0)
     *
     *      CRTSRVPGM SRVPGM(*) SRCFILE(*/QSRVSRC) TGTRLS(V4R4M0)
     *                ACTGRP(BTS) ALWUPD(*YES)
     *
     *      ADDBNDDIRE BNDDIR(*/BTSBND) OBJ((*))
     *
     *                    --- OR ---
     *    When updating:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V4R4M0)
     *
     *      UPDSRVPGM SRVPGM(*) MODULE(*) SRCFILE(*/QSRVSRC)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Sub-Command Notes
     *
     *      *OPEN             Open program and return.
     *
     *      *CLOSE            Close program with *INLR = *ON
     *
     *      *ADD              Add transaction record.
     *
     *      *CHANGE           Change transaction record.
     *
     *      *DELETE           Delete transaction record.
     *
     *      *END              End transaction for employee.
     *
     *      *EXCP             Write exception record for battery.
     *
     *      *LOCEXCP          Location exception.
     *
     *      *GET              Get transaction record.
     *      *GETACTBAT        Get active battery transaction.
     *      *GETACTFRK        Get active forklift transaction.
     *      *GETACTSLT        Get active slot transaction.
     *
     *      *PUT              Put battery into a location.
     *
     *      *REMOVE           Remove battery from a location.
     *
     *      *START            Start transaction for employee.
     *
     *      *VERIFYADD        Do "*ADD" verification without update.
     *      *VERIFYCHG        Do "*CHANGE" verification without update.
     *      *VERIFYDEL        Do "*DELETE" verification without update.
     *      *VERIFYMTR        Do meter verification
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BTSBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fbtstranb1 uf a e           k disk    usropn
     F                                     rename(btbrec:btbrec1)
     F                                     infds(file1ds)

     Fbtstranb2 uf   e           k disk    usropn
     F                                     rename(btbrec:btbrec2)
     F                                     infds(file2ds)

     Fbtstranb3 uf   e           k disk    usropn
     F                                     rename(btbrec:btbrec3)
     F                                     infds(file3ds)

     Fbtstranb4 uf   e           k disk    usropn
     F                                     rename(btbrec:btbrec4)
     F                                     infds(file4ds)

     Fnxtid     uf a e           k disk    usropn
     F                                     infds(file9ds)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.btstranb
      /copy qcopysrc,p.btslibl
      /copy qcopysrc,p.btsbat
      /copy qcopysrc,p.btsfork
      /copy qcopysrc,p.btsslot
      /copy qcopysrc,p.btswhse

     *----------------------------------------------------------------
     *  Standard parameters.
     *----------------------------------------------------------------

      /copy qcopysrc,c#btsparms

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

      /copy qcopysrc,f#btb0100
      /copy qcopysrc,f#bb0100
      /copy qcopysrc,f#bf0100
      /copy qcopysrc,f#bs0100
      /copy qcopysrc,f#bw0100

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#btsvar

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds
      /copy qcopysrc,c#file2ds
      /copy qcopysrc,c#file3ds
      /copy qcopysrc,c#file4ds
      /copy qcopysrc,c#file9ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Misc variables
     *----------------------------------------------------------------

     D saveaction      s                   like($btsaction)
     D savedata        s           2048

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamp       s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     *  Define key for file.

     C     *like         define    btbcc         kycc
     C     *like         define    btbtrnb       kytrnb
     C     *like         define    btbwhse       kywhse
     C     *like         define    btbactive     kyactive
     C     *like         define    btbbatid      kybatid
     C     *like         define    btbforkid     kyforkid
     C     *like         define    btbslot       kyslot

     C     keybtbp       klist
     C                   kfld                    kycc

     C     keybtb1       klist
     C                   kfld                    kycc
     C                   kfld                    kytrnb

     C     keybtb2       klist
     C                   kfld                    kycc
     C                   kfld                    kywhse
     C                   kfld                    kyactive
     C                   kfld                    kybatid

     C     keybtb3       klist
     C                   kfld                    kycc
     C                   kfld                    kywhse
     C                   kfld                    kyactive
     C                   kfld                    kyforkid

     C     keybtb4       klist
     C                   kfld                    kycc
     C                   kfld                    kywhse
     C                   kfld                    kyactive
     C                   kfld                    kyslot

     C     keyni         klist
     C                   kfld                    kycc
     C                   kfld                    kyfile           10

     *================================================================
     * Function: BTSTRANB
     *================================================================

     P fbtstranb       b                   Export

     D fbtstranb       pi
     D  $pparms                    1024    varying
     D  $pfrmt                       10    value
     D  $pdata                     2048    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $message        s                   like($btsmessage)
     D $return         s                   like($btsreturn)

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Move input parameters into data structures.

     C                   eval      $btsparms = *allx'00'
     C                   eval      $btsparms = %subst($pparms:
     C                                                1:%len($pparms))

     C                   eval      $btb0100 = *allx'00'
     C                   eval      $btb0100 = %subst($pdata:1:%len($pdata))

     C                   eval      $btschk     = $btsok
     C                   eval      $btsreturn  = '*OK'
     C                   eval      $btsmessage = ' '

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $btsaction = '*OPEN'
     C                   goto      bottom

     C                   when      $btsaction = '*CLOSE'
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off
     C                   eval      warn  = *off

     *  Do what user has requested.

     C                   select

     C                   when      $btsaction = '*ADD'
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      recadd
     C                   endif

     C                   when      $btsaction = '*CHANGE'
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      recchange
     C                   endif

     C                   when      $btsaction = '*DELETE'
     C                   exsr      verifydel
     C                   if        not error
     C                   exsr      recdelete
     C                   endif

     C                   when      $btsaction = '*EXCP'
     C                   exsr      verifyexcp
     C                   if        not error
     C                   exsr      recexcp
     C                   endif

     C                   when      $btsaction = '*GET'
     C                   eval      lock1 = *off
     C                   exsr      recget1
     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return  = 'TRN1NOTFND'
     C                   eval      $message = 'Transaction not found '
     C                                      + '('
     C                                      + %trim(%editc($btbtrnb:'P'))
     C                                      + ')'
     C                   else
     C                   exsr      file2ds
     C                   endif

     C                   when      $btsaction = '*GETACTBAT'
     C                   eval      lock2 = *off
     C                   exsr      recget2
     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = 'NOACTBAT'
     C                   eval      $message = 'No active record exists '
     C                                      + 'for battery ('
     C                                      + %trim(%editc($btbwhse:'P'))
     C                                      + '/'
     C                                      + %trim(%editc($btbbatid:'P'))
     C                                      + ')'
     C                   else
     C                   exsr      file2ds
     C                   endif

     C                   when      $btsaction = '*GETACTFRK'
     C                   eval      lock3 = *off
     C                   exsr      recget3
     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = 'NOACTFORK'
     C                   eval      $message = 'No active record exists '
     C                                      + 'for forklift ('
     C                                      + %trim(%editc($btbwhse:'P'))
     C                                      + '/'
     C                                      + %trim(%editc($btbforkid:'P'))
     C                                      + ')'
     C                   else
     C                   exsr      file2ds
     C                   endif

     C                   when      $btsaction = '*GETACTSLT'
     C                   eval      lock4 = *off
     C                   exsr      recget4
     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbslotchk = $btserror
     C                   eval      $return  = 'NOACTSLOT'
     C                   eval      $message = 'No active record exists '
     C                                      + 'for slot ('
     C                                      + %trim(%editc($btbwhse:'P'))
     C                                      + '/'
     C                                      + %trim($btbslot)
     C                                      + ')'
     C                   else
     C                   exsr      file2ds
     C                   endif

     C                   when      $btsaction = '*LOCEXCP'
     C                   exsr      verifylocexcp
     C                   if        not error
     C                   exsr      reclocexcp
     C                   endif

     C                   when      $btsaction = '*PUT'
     C                   exsr      verifyput
     C                   if        not error
     C                   exsr      recput
     C                   endif

     C                   when      $btsaction = '*REMOVE'
     C                   exsr      verifyremove
     C                   if        not error
     C                   exsr      recremove
     C                   endif

     C                   when      $btsaction = '*VERIFYADD'
     C                   exsr      verifyadd

     C                   when      $btsaction = '*VERIFYCHG'
     C                   exsr      verifychg

     C                   when      $btsaction = '*VERIFYDEL'
     C                   exsr      verifydel

     C                   when      $btsaction = '*VERIFYMTR'
     C                   exsr      verifymtr

     C                   other
     C                   eval      error = *on
     C                   eval      $return = 'INVLDACTN'
     C                   eval      $message = 'Invalid action '
     C                                      + '(' + %trim($btsaction) + ') '
     C                                      + 'sent to ' + %trim(#pgm)

     C                   endsl

     C     bottom        tag

     * Set return parameters.

     C                   select

     C                   when      warn
     C                   eval      $btschk     = $btswarning
     C                   eval      $btsreturn  = $return
     C                   eval      $btsmessage = $message

     C                   when      error
     C                   eval      $btschk     = $btserror
     C                   eval      $btsreturn  = $return
     C                   eval      $btsmessage = $message

     C                   endsl

     * Move data structures back into parameter fields.

     C                   eval      $pparms = $btsparms
     C                   eval      $pdata  = $btb0100

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $btschk     = $btserror
     C                   eval      $btsreturn  = 'U:' + #status
     C                   eval      $btsmessage = 'U:'
     C                                         + %trim(#pgm)
     C                                         + '('
     C                                         + %trim(%editc(#stmt:'Z'))
     C                                         + ')-'
     C                                         + #pgmmsg
     C                   eval      $pparms = $btsparms
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     aaaclose      begsr
     C                   eval      error = *off
     C                   exsr      fileclose
     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  calcdur   Calculate duration.
     *----------------------------------------------------------------

     C     calcdur       begsr

     C     tostamp       subdur    99999:*MN     oldeststamp

     C                   select
     C                   when      fromstamp >= tostamp
     C                   eval      duration = 0
     C                   when      fromstamp <= oldeststamp
     C                   eval      duration = 99999
     C                   other
     C     tostamp       subdur    fromstamp     ttlsec:*S
     C     tostamp       subdur    fromstamp     ttlmin:*MN
     C                   eval      ttlminsec = ttlmin * 60
     C                   eval      remSec = ttlSec - ttlminsec
     C                   if        remSec = 0
     C                   eval      duration = ttlMin
     C                   else
     C                   eval      duration = ttlMin + (remsec/60)
     C                   endif
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  callbtsbat      Call fbtsbat
     *----------------------------------------------------------------

     C     callbtsbat    begsr

     *  Move file data structure into variable length parameter.

     C                   eval      $btsfrmt = 'BB0100'
     C                   eval      $btsvrydata  = $bb0100

     *  Move standard parm data structure into variable length parameter.

     C                   eval      $btsvryparms = $btsparms

     *  Call file routine.

     C                   callp     fbtsbat($btsvryparms:
     C                                        $btsfrmt: $btsvrydata)

     *  Check for call error.

     C                   if        %error
     C                   eval      error = *on
     C                   endif

     *  Move parms back into data structures.

     C                   eval      $bb0100   = $btsvrydata
     C                   eval      $btsparms = $btsvryparms

     *  Check for returned error or warning.

     C                   select
     C                   when      $btschk = $btserror
     C                   eval      error = *on
     C                   when      $btschk = $btswarning
     C                   eval      error = *on
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  callbtsfork     Call fbtsfork
     *----------------------------------------------------------------

     C     callbtsfork   begsr

     *  Move file data structure into variable length parameter.

     C                   eval      $btsfrmt = 'BF0100'
     C                   eval      $btsvrydata  = $bf0100

     *  Move standard parm data structure into variable length parameter.

     C                   eval      $btsvryparms = $btsparms

     *  Call file routine.

     C                   callp     fbtsfork($btsvryparms:
     C                                        $btsfrmt: $btsvrydata)

     *  Check for call error.

     C                   if        %error
     C                   eval      error = *on
     C                   endif

     *  Move parms back into data structures.

     C                   eval      $bf0100   = $btsvrydata
     C                   eval      $btsparms = $btsvryparms

     *  Check for returned error or warning.

     C                   select
     C                   when      $btschk = $btserror
     C                   eval      error = *on
     C                   when      $btschk = $btswarning
     C                   eval      error = *on
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  callbtsslot     Call fbtsslot
     *----------------------------------------------------------------

     C     callbtsslot   begsr

     *  Move file data structure into variable length parameter.

     C                   eval      $btsfrmt = 'BS0100'
     C                   eval      $btsvrydata  = $bs0100

     *  Move standard parm data structure into variable length parameter.

     C                   eval      $btsvryparms = $btsparms

     *  Call file routine.

     C                   callp     fbtsslot($btsvryparms:
     C                                        $btsfrmt: $btsvrydata)

     *  Check for call error.

     C                   if        %error
     C                   eval      error = *on
     C                   endif

     *  Move parms back into data structures.

     C                   eval      $bs0100   = $btsvrydata
     C                   eval      $btsparms = $btsvryparms

     *  Check for returned error or warning.

     C                   select
     C                   when      $btschk = $btserror
     C                   eval      error = *on
     C                   when      $btschk = $btswarning
     C                   eval      error = *on
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  callbtswhse  Call fbtswhse.
     *----------------------------------------------------------------

     C     callbtswhse   begsr

     *  Move file data structure into variable length parameter.

     C                   eval      $btsfrmt = 'BW0100'
     C                   eval      $btsvrydata  = $bw0100

     *  Move standard parm data structure into variable length parameter.

     C                   eval      $btsvryparms = $btsparms

     *  Call file routine.

     C                   callp     fbtswhse($btsvryparms:
     C                                        $btsfrmt: $btsvrydata)

     *  Check for call error.

     C                   if        %error
     C                   eval      error = *on
     C                   eval      $btsmessage = 'Error calling fbtswhse - '
     C                                         + #pgmmsg
     C                   goto      endfbtswhse
     C                   endif

     *  Move parms back into data structures.

     C                   eval      $bw0100   = $btsvrydata
     C                   eval      $btsparms = $btsvryparms

     *  Check for returned error or warning.

     C                   select
     C                   when      $btschk = $btserror
     C                   eval      error = *on
     C                   when      $btschk = $btswarning
     C                   eval      error = *on
     C                   endsl

     C     endfbtswhse   endsr

     *----------------------------------------------------------------
     *  clrbb0100  Clear data structure $bb0100
     *----------------------------------------------------------------

     C     clrbb0100     begsr
     C                   eval      $bb0100 = *allx'00'
     C                   endsr

     *----------------------------------------------------------------
     *  clrbf0100  Clear data structure $bf0100
     *----------------------------------------------------------------

     C     clrbf0100     begsr
     C                   eval      $bf0100 = *allx'00'
     C                   endsr

     *----------------------------------------------------------------
     *  clrbs0100  Clear data structure $bs0100
     *----------------------------------------------------------------

     C     clrbs0100     begsr
     C                   eval      $bs0100 = *allx'00'
     C                   endsr

     *----------------------------------------------------------------
     *  clrbw0100  Clear data structure $bw0100
     *----------------------------------------------------------------

     C     clrbw0100     begsr
     C                   eval      $bw0100 = *allx'00'
     C                   endsr
416bA
416bA*----------------------------------------------------------------
416bA*  fileclose  Close file btswhse
416bA*----------------------------------------------------------------
416bA
416bAC     fileclose     begsr

     C                   if        %open(btstranb1)
     C                   close(e)  btstranb1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRCLSTRN1'
     C                   eval      $message = 'Error closing BTSTRANB1 file'
     C                   endif
     C                   callp     dltovr('BTSTRANB1')
     C                   endif

     C                   if        %open(btstranb2)
     C                   close(e)  btstranb2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRCLSTRN2'
     C                   eval      $message = 'Error closing BTSTRANB2 file'
     C                   endif
     C                   callp     dltovr('BTSTRANB2')
     C                   endif

     C                   if        %open(btstranb3)
     C                   close(e)  btstranb3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRCLSTRN3'
     C                   eval      $message = 'Error closing BTSTRANB3 file'
     C                   endif
     C                   callp     dltovr('BTSTRANB3')
     C                   endif

     C                   if        %open(btstranb4)
     C                   close(e)  btstranb4
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRCLSTRN4'
     C                   eval      $message = 'Error closing BTSTRANB4 file'
     C                   endif
     C                   callp     dltovr('BTSTRANB4')
     C                   endif

     C                   if        %open(nxtid)
     C                   close(e)  nxtid
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRCLSNXTI'
     C                   eval      $message = 'Error closing NXTID file'
     C                   endif
     C                   callp     dltovr('NXTID')
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopen1 Open file btstranb1
416bA*----------------------------------------------------------------
416bA
416bAC     fileopen1     begsr

     C                   if        not %open(btstranb1)
     C                   callp     ovrclidbf($btsclient : 'BTSTRANB1')
     C                   open(e)   btstranb1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return  = 'OPNERRTRN1'
     C                   eval      $message = 'Error occured trying to '
     C                                      + 'open file BTSTRANB1 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopen2 Open file btstranb2
416bA*----------------------------------------------------------------
416bA
416bAC     fileopen2     begsr

     C                   if        not %open(btstranb2)
     C                   callp     ovrclidbf($btsclient : 'BTSTRANB2')
     C                   open(e)   btstranb2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return  = 'OPNERRTRN2'
     C                   eval      $message = 'Error occured trying to '
     C                                      + 'open file BTSTRANB2 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopen3 Open file btstranb3
416bA*----------------------------------------------------------------
416bA
416bAC     fileopen3     begsr

     C                   if        not %open(btstranb3)
     C                   callp     ovrclidbf($btsclient : 'BTSTRANB3')
     C                   open(e)   btstranb3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return  = 'OPNERRTRN3'
     C                   eval      $message = 'Error occured trying to '
     C                                      + 'open file BTSTRANB3 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopen4 Open file btstranb4
416bA*----------------------------------------------------------------
416bA
416bAC     fileopen4     begsr

     C                   if        not %open(btstranb4)
     C                   callp     ovrclidbf($btsclient : 'BTSTRANB4')
     C                   open(e)   btstranb4
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return  = 'OPNERRTRN4'
     C                   eval      $message = 'Error occured trying to '
     C                                      + 'open file BTSTRANB4 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopennxtid  Open file nxtid
416bA*----------------------------------------------------------------
416bA
416bAC     fileopennxtid begsr

     C                   if        not %open(nxtid)
     C                   callp     ovrclidbf($btsclient : 'NXTID')
     C                   open(e)   nxtid
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return  = 'OPNERRNXTI'
     C                   eval      $message = 'Error occured trying to '
     C                                      + 'open file NXTID in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  file2ds  Move warehouse fields to data structure fields
     *----------------------------------------------------------------

     C     file2ds       begsr

     * Move information to data structure.

     C                   eval      $btbwhsechk = $btsok
416aAC                   eval      $btbwhse = btbwhse

     C                   eval      $btbtrnbchk = $btsok
416aAC                   eval      $btbtrnb = btbtrnb

     C                   eval      $btbtrnechk = $btsok
416aAC                   eval      $btbtrne = btbtrne

     C                   eval      $btbbatidchk = $btsok
416aAC                   eval      $btbbatid = btbbatid

     C                   eval      $btbtaskchk = $btsok
416aAC                   eval      $btbtask = btbtask

     C                   eval      $btbcatchk = $btsok
416aAC                   eval      $btbcat = btbcat

     C                   eval      $btbactvchk = $btsok
416aAC                   eval      $btbactive = btbactive

     C                   eval      $btbfromchk = $btsok
416aAC                   eval      $btbfrom = btbfrom

     C                   eval      $btbtochk = $btsok
416aAC                   eval      $btbto = btbto

     C                   eval      $btbwaterchk = $btsok
416aAC                   eval      $btbwater = btbwater

     C                   eval      $btbstartchk = $btsok
416aAC                   eval      $btbstart = btbstart

     C                   eval      $btbendchk = $btsok
416aAC                   eval      $btbend = btbend

     C                   eval      $btbminchk = $btsok
416aAC                   eval      $btbmin = btbmin

     C                   eval      $btbmtrpchk = $btsok
416aAC                   eval      $btbmtrprv = btbmtrprv

     C                   eval      $btbmtrschk = $btsok
416aAC                   eval      $btbmtrstr = btbmtrstr

     C                   eval      $btbmtrechk = $btsok
416aAC                   eval      $btbmtrend = btbmtrend

     C                   eval      $btbmtrdchk = $btsok
416aAC                   eval      $btbmtrdur = btbmtrdur

     C                   eval      $btbforkchk = $btsok
416aAC                   eval      $btbforkid = btbforkid

     C                   eval      $btbslotchk = $btsok
416aAC                   eval      $btbslot = btbslot

     C                   eval      $btbareachk = $btsok
416aAC                   eval      $btbarea = btbarea

     C                   eval      $btbexcpchk = $btsok
416aAC                   eval      $btbexcp = btbexcp

     C                   eval      $btbbatcdchk = $btsok
416aAC                   exsr      getbatcode

     C                   eval      $btbforkcchk = $btsok
416aAC                   exsr      getforkcode

     C                   eval      $btbfforkchk = $btsok
416aAC                   eval      $btbfforkid = btbfforkid

     C                   eval      $btbffrkcchk = $btsok
416aAC                   exsr      getfforkcode

     C                   eval      $btbfslotchk = $btsok
416aAC                   eval      $btbfslot = btbfslot

     C                   eval      $btbfareachk = $btsok
416aAC                   eval      $btbfarea = btbfarea

     C                   eval      $btbexcpochk = $btsok
416aAC                   eval      $btbexcpout = btbexcpout

     C                   eval      $btbtaskochk = $btsok
416aAC                   eval      $btbtaskout = btbtaskout

     C                   eval      $btbtrneochk = $btsok
416aAC                   eval      $btbtrneout = btbtrneout


     C                   endsr

     *----------------------------------------------------------------
     *  getbatcode     Get battery code.
     *----------------------------------------------------------------

     C     getbatcode    begsr

     C                   exsr      clrbb0100
     C                   eval      $bbwhse = $btbwhse
     C                   eval      $bbid   = $btbbatid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsbat
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      error = *off
     C                   eval      $btbbatcd = ' '
     C                   else
     C                   eval      $btbbatcd = $bbcode
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getforkcode    Get forklift code.
     *----------------------------------------------------------------

     C     getforkcode   begsr

     C                   if        $btbforkid > 0
     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfid   = $btbforkid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      error = *off
     C                   eval      $btbforkcd = ' '
     C                   else
     C                   eval      $btbforkcd = $bfcode
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getfforkcode    Get From forklift code.
     *----------------------------------------------------------------

     C     getfforkcode  begsr

     C                   if        $btbfforkid > 0
     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfid   = $btbfforkid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      error = *off
     C                   eval      $btbfforkcd = ' '
     C                   else
     C                   eval      $btbfforkcd = $bfcode
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getnewtrn#  Get new transaction number
     *----------------------------------------------------------------

     C     getnewtrn#    begsr

     C     *like         define    btbtrnb       maxid
     C                   eval      maxid = *hival
     C                   eval      filebeg = *off

     *  Open file

     C                   exsr      fileopennxtid
     C     error         cabeq     *on           endgetnew

     *  Get next number to be used.

     C                   eval      kycc   = $btsclient
     C                   eval      kyfile = 'BTSTRANB'

     C     1             do        2             i

     C     keyni         chain     nxtid
     C                   if        %found
     C                   leave
     C                   endif

     C                   if        i = 2
     C                   eval      error = *on
     C                   eval      $return = 'ERRGETNI'
     C                   eval      $message = 'Error getting NXTID record '
     C                                      + '('
     C                                      + %trim(nifile)
     C                                      + ')'
     C                   goto      endgetnew
     C                   endif

     C                   eval      nicc   = $btsclient
     C                   eval      nifile = 'BTSTRANB'
     C                   eval      ninbr  = 0
     C                   write(e)  nirec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRADDNI'
     C                   eval      $message = 'Error on "Write '
     C                                      + 'NXTID" command '
     C                                      + '('
     C                                      + %trim(nifile)
     C                                      + ')'
     C                                      + '-' + f9messageid
     C                   goto      endgetnew
     C                   endif

     C                   enddo

     C                   if        ninbr < 2 or ninbr > maxid
     C                   eval      ninbr = 1
     C                   eval      filebeg = *on
     C                   endif

     *  Loop until we find a number that doesn't exist.

     C                   dow       forever = forever

     *    See if number exists in file.

     C                   eval      $btbtrnb = ninbr
     C                   eval      lock1 = *off
     C                   exsr      recget1

     *    If record not found, leave.

     C                   if        not found
     C                   eval      error = *off
     C                   leave
     C                   endif

     *    Otherwise, increment number and try again.

     C                   if        ninbr = maxid
     C                   if        filebeg
     C                   eval      error = *on
     C                   leave
     C                   else
     C                   eval      filebeg = *on
     C                   eval      ninbr = 1
     C                   iter
     C                   endif
     C                   endif

     C                   eval      ninbr = ninbr + 1
     C                   iter

     C                   enddo

     *  Update dataarea with next number to be used.

     C                   eval      ninbr = ninbr + 1
     C                   update(e) nirec
     C                   if        %error
     C                   endif

     C     endgetnew     endsr

     *----------------------------------------------------------------
     *  inzchkflds  Initialize check fields.
     *----------------------------------------------------------------

     C     inzchkflds    begsr

     C                   eval      $btbwhsechk = $btsok
     C                   eval      $btbtrnbchk = $btsok
     C                   eval      $btbtrnechk = $btsok
     C                   eval      $btbbatidchk = $btsok
     C                   eval      $btbtaskchk = $btsok
     C                   eval      $btbcatchk = $btsok
     C                   eval      $btbactvchk = $btsok
     C                   eval      $btbfromchk = $btsok
     C                   eval      $btbtochk = $btsok
     C                   eval      $btbwaterchk = $btsok
     C                   eval      $btbstartchk = $btsok
     C                   eval      $btbendchk = $btsok
     C                   eval      $btbminchk = $btsok
     C                   eval      $btbmtrpchk = $btsok

     C                   If        $btbmtrschk <> $btswarnovr
     C                   eval      $btbmtrschk = $btsok
     C                   endif

     C                   if        $btbmtrechk <> $btswarnovr
     C                   eval      $btbmtrechk = $btsok
     C                   endif

     C                   eval      $btbmtrdchk = $btsok
     C                   eval      $btbforkchk = $btsok
     C                   eval      $btbslotchk = $btsok
     C                   eval      $btbareachk = $btsok
     C                   eval      $btbexcpchk = $btsok
     C                   eval      $btbfforkchk = $btsok
     C                   eval      $btbfslotchk = $btsok
     C                   eval      $btbfareachk = $btsok
     C                   eval      $btbexcpochk = $btsok
     C                   eval      $btbtaskochk = $btsok
     C                   eval      $btbtrneochk = $btsok

     C                   endsr

     *----------------------------------------------------------------
     *  recadd   Add record.
     *----------------------------------------------------------------

     C     recadd        begsr
     C                   time                    currstamp

     *  Clear record.

     C                   clear                   btbrec1

     *  Get transaction number to use if tran# sent is zero.

416aAC                   if        $btbtrnb = 0
416aAC                   exsr      getnewtrn#
     C                   if        error
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return  = 'NOAVLTRN#'
     C                   eval      $message = 'No availalbe Tran # found'
     C                   goto      endadd
     C                   endif
     C                   endif

     *  Move information into fields.

416aAC                   eval      btbcc   = $btsclient
416aAC                   eval      btbwhse = $btbwhse
416aAC                   eval      btbtrnb = $btbtrnb
416aAC                   eval      btbbatid = $btbbatid

416aAC                   if        $btbtrnesnt <> null
416aAC                   eval      btbtrne = $btbtrne
416aAC                   endif

416aAC                   if        $btbtasksnt <> null
416aAC                   eval      btbtask = $btbtask
416aAC                   endif

416aAC                   if        $btbcatsnt <> null
416aAC                   eval      btbcat = $btbcat
416aAC                   endif

416aAC                   if        $btbactvsnt <> null
416aAC                   eval      btbactive = $btbactive
416aAC                   else
416aAC                   eval      btbactive = '0'
416aAC                   endif

416aAC                   if        $btbfromsnt = null
416aAC                   eval      btbfrom = $btbfrom
416aAC                   endif

416aAC                   if        $btbtosnt <> null
416aAC                   eval      btbto = $btbto
416aAC                   endif

416aAC                   if        $btbwatersnt <> null
416aAC                   eval      btbwater = $btbwater
416aAC                   endif

416aAC                   if        $btbstartsnt <> null
416aAC                   eval      btbstart = $btbstart
416aAC                   else
416aAC                   eval      btbstart = *loval
416aAC                   endif

416aAC                   if        $btbendsnt <> null
416aAC                   eval      btbend = $btbend
416aAC                   else
416aAC                   eval      btbend = *loval
416aAC                   endif

416aAC                   eval      fromstamp = btbstart
416aAC                   eval      tostamp   = btbend
416aAC                   exsr      calcdur
416aAC                   eval      btbmin = duration

416aAC                   if        $btbmtrpsnt <> null
416aAC                   eval      btbmtrprv = $btbmtrprv
416aAC                   endif

416aAC                   if        $btbmtrssnt <> null
416aAC                   eval      btbmtrstr = $btbmtrstr
416aAC                   endif

416aAC                   if        $btbmtresnt <> null
416aAC                   eval      btbmtrend = $btbmtrend
416aAC                   endif

416aAC                   if        btbmtrstr < btbmtrend
416aAC                   eval      btbmtrdur = btbmtrend - btbmtrstr
416aAC                   endif

416aAC                   if        $btbforksnt <> null
416aAC                   eval      btbforkid = $btbforkid
416aAC                   endif

416aAC                   if        $btbslotsnt <> null
416aAC                   eval      btbslot = $btbslot
416aAC                   endif

416aAC                   if        $btbareasnt <> null
416aAC                   eval      btbarea = $btbarea
416aAC                   endif

416aAC                   if        $btbexcpsnt <> null
416aAC                   eval      btbexcp = $btbexcp
416aAC                   endif

416aAC                   if        $btbfforksnt <> null
416aAC                   eval      btbfforkid = $btbfforkid
416aAC                   endif

416aAC                   if        $btbfslotsnt <> null
416aAC                   eval      btbfslot = $btbfslot
416aAC                   endif

416aAC                   if        $btbfareasnt <> null
416aAC                   eval      btbfarea = $btbfarea
416aAC                   endif

416aAC                   eval      btbexcpout = ' '
416aAC                   eval      btbtaskout = ' '
416aAC                   eval      btbtrneout = 0

416aAC                   eval      btbaddts  = currstamp
     C                   eval      btbaddemp = $btsemp#
     C                   eval      btbaddusr = $btsuser
     C                   eval      btbaddjob = $btsjob
     C                   eval      btbaddnbr = $btsjobnbr

     *  Add record

     C                   write(e)  btbrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRADDREC'
     C                   eval      $message = 'Error on "Write '
     C                                      + 'TRNB1" command '
     C                                      + '('
     C                                      + %trim(%editc($btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid
     C                   goto      endadd
     C                   endif

     C     endadd        endsr

     *----------------------------------------------------------------
     *  recchange    Change record.
     *----------------------------------------------------------------

     C     recchange     begsr

     *  Move information into fields. Set flag if something changed.

     C                   if        $btbwhsesnt <> null
     C                             and $btbwhse <> btbwhse
416aAC                   eval      btbwhse = $btbwhse
     C                   eval      changed = *on
     C                   endif

     C                   if        $btbbatidsnt <> null
     C                             and $btbbatid <> btbbatid
416aAC                   eval      btbbatid = $btbbatid
     C                   eval      changed = *on
     C                   endif

416aAC                   if        $btbtrnesnt <> null
416aAC                             and $btbtrne <> btbtrne
416aAC                   eval      btbtrne = $btbtrne
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbtasksnt <> null
416aAC                             and $btbtask <> btbtask
416aAC                   eval      btbtask = $btbtask
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbcatsnt <> null
416aAC                             and $btbcat <> btbcat
416aAC                   eval      btbcat = $btbcat
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbactvsnt <> null
416aAC                             and $btbactive <> btbactive
416aAC                   eval      btbactive = $btbactive
     C                   eval      changed = *on
416aAC                   else
416aAC                   eval      btbactive = '1'
416aAC                   endif

416aAC                   if        $btbfromsnt <> null
416aAC                             and $btbfrom <> btbfrom
416aAC                   eval      btbfrom = $btbfrom
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbtosnt <> null
416aAC                             and $btbto <> btbto
416aAC                   eval      btbto = $btbto
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbwatersnt <> null
416aAC                             and $btbwater <> btbwater
416aAC                   eval      btbwater = $btbwater
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbstartsnt <> null
416aAC                             and $btbstart <> btbstart
416aAC                   eval      btbstart = $btbstart
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbendsnt <> null
416aAC                             and $btbend <> btbend
416aAC                   eval      btbend = $btbend
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbstartsnt <> null
416aAC                             or $btbendsnt <> null
416aAC                   eval      fromstamp = btbstart
416aAC                   eval      tostamp   = btbend
416aAC                   exsr      calcdur
416aAC                   eval      btbmin = duration
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbmtrpsnt <> null
416aAC                             and $btbmtrprv <> btbmtrprv
416aAC                   eval      btbmtrprv = $btbmtrprv
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbmtrssnt <> null
416aAC                             and $btbmtrstr <> btbmtrstr
416aAC                   eval      btbmtrstr = $btbmtrstr
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbmtresnt <> null
416aAC                             and $btbmtrend <> btbmtrend
416aAC                   eval      btbmtrend = $btbmtrend
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbmtrssnt <> null
416aAC                             or $btbmtresnt <> null
416aAC                   if        btbmtrstr < btbmtrend
416aAC                   eval      btbmtrdur = btbmtrend - btbmtrstr
416aAC                   else
416aAC                   eval      btbmtrdur = 0
416aAC                   endif
416aAC                   endif

416aAC                   if        $btbforksnt <> null
416aAC                             and $btbforkid <> btbforkid
416aAC                   eval      btbforkid = $btbforkid
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbslotsnt <> null
416aAC                             and $btbslot <> btbslot
416aAC                   eval      btbslot = $btbslot
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbareasnt <> null
416aAC                             and $btbarea <> btbarea
416aAC                   eval      btbarea = $btbarea
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbexcpsnt <> null
416aAC                             and btbexcp <> btbexcp
416aAC                   eval      btbexcp = $btbexcp
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbfforksnt <> null
416aAC                             and $btbfforkid <> btbfforkid
416aAC                   eval      btbfforkid = $btbfforkid
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbfslotsnt <> null
416aAC                             and $btbfslot <> btbfslot
416aAC                   eval      btbfslot = $btbfslot
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbfareasnt <> null
416aAC                             and $btbfarea <> btbfarea
416aAC                   eval      btbfarea = $btbfarea
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbexcposnt <> null
416aAC                             and btbexcpout <> btbexcpout
416aAC                   eval      btbexcpout = $btbexcpout
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbtaskosnt <> null
416aAC                             and btbtaskout <> btbtaskout
416aAC                   eval      btbtaskout = $btbtaskout
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $btbtrneosnt <> null
416aAC                             and btbtrneout <> btbtrneout
416aAC                   eval      btbtrneout = $btbtrneout
     C                   eval      changed = *on
416aAC                   endif

     *  If nothing changed, then unlock record and get out.

     C                   if        not changed
     C                   unlock    btstranb1
     C                   goto      endchange
     C                   endif

     *  Something change, update record.

     C                   time                    btbchgts
     C                   eval      btbchgemp = $btsemp#
     C                   eval      btbchgusr = $btsuser
     C                   eval      btbchgjob = $btsjob
     C                   eval      btbchgnbr = $btsjobnbr

     *  Update record

     C                   update(e) btbrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRUPDREC'
     C                   eval      $message = 'Error on "Update '
     C                                      + 'TRNB1" command '
     C                                      + '('
     C                                      + %trim(%editc($btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid

     C                   goto      endchange
     C                   endif

     C     endchange     endsr

     *----------------------------------------------------------------
     *  reccrtactive   Create active transaction record.
     *----------------------------------------------------------------

     C     reccrtactive  begsr

     *  Clear record.

     C                   clear                   btbrec1

     *  Get transaction number to use.

416aAC                   exsr      getnewtrn#
     C                   if        error
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return  = 'NOAVLTRN#'
     C                   eval      $message = 'No availalbe Tran # found'
     C                   goto      endcrtact
     C                   endif

     *  Move information into fields.

416aAC                   eval      btbcc   = $btsclient
416aAC                   eval      btbtrnb = $btbtrnb
416aAC                   eval      btbwhse = $btbwhse
416aAC                   eval      btbbatid = $btbbatid

416aAC                   if        $btbtrnesnt <> null
416aAC                   eval      btbtrne = $btbtrne
416aAC                   endif

416aAC                   if        $btbtasksnt <> null
416aAC                   eval      btbtask = $btbtask
416aAC                   endif

416aAC                   if        $btbcatsnt <> null
416aAC                   eval      btbcat = $btbcat
416aAC                   endif

416aAC                   eval      btbactive = '1'

416aAC                   if        $btbfromsnt = null
416aAC                   eval      btbfrom = '?'
416aAC                   else
416aAC                   eval      btbfrom = $btbfrom
416aAC                   endif

416aAC                   if        $btbtosnt <> null
416aAC                   eval      btbto = $btbto
416aAC                   endif

416aAC                   eval      btbstart = currstamp

416aAC                   eval      btbend = *loval

416aAC                   if        $btbmtrpsnt <> null
416aAC                   eval      btbmtrprv = $btbmtrprv
416aAC                   endif

416aAC                   if        $btbmtrssnt <> null
416aAC                   eval      btbmtrstr = $btbmtrstr
416aAC                   endif

416aAC                   if        $btbforksnt <> null
416aAC                   eval      btbforkid = $btbforkid
416aAC                   endif

416aAC                   if        $btbslotsnt <> null
416aAC                   eval      btbslot = $btbslot
416aAC                   endif

416aAC                   if        $btbareasnt <> null
416aAC                   eval      btbarea = $btbarea
416aAC                   endif

416aAC                   if        $btbexcpsnt <> null
416aAC                   eval      btbexcp = $btbexcp
416aAC                   endif

416aAC                   if        $btbfforksnt <> null
416aAC                   eval      btbfforkid = $btbfforkid
416aAC                   endif

416aAC                   if        $btbfslotsnt <> null
416aAC                   eval      btbfslot = $btbfslot
416aAC                   endif

416aAC                   if        $btbfareasnt <> null
416aAC                   eval      btbfarea = $btbfarea
416aAC                   endif

416aAC                   eval      btbexcpout = ' '
416aAC                   eval      btbtaskout = ' '
416aAC                   eval      btbtrneout = 0

416aAC                   eval      btbaddts  = currstamp
     C                   eval      btbaddemp = $btsemp#
     C                   eval      btbaddusr = $btsuser
     C                   eval      btbaddjob = $btsjob
     C                   eval      btbaddnbr = $btsjobnbr

     *  Add record

     C                   write(e)  btbrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRADDREC'
     C                   eval      $message = 'Error on "Write '
     C                                      + 'TRNB1" command '
     C                                      + '('
     C                                      + %trim(%editc($btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid
     C                   goto      endcrtact
     C                   endif

     C     endcrtact     endsr

     *----------------------------------------------------------------
     *  recdelete   Delete record.
     *----------------------------------------------------------------

     C     recdelete     begsr
     C                   eval      error = *off

     C                   delete(e) btbrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRDELREC'
     C                   eval      $message = 'Error on "Delete '
     C                                      + 'TRNB1" command '
     C                                      + '('
     C                                      + %trim(%editc($btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid

     C                   goto      enddel
     C                   endif

     C     enddel        endsr

     *----------------------------------------------------------------
     *  recexcp   Exception record.
     *----------------------------------------------------------------

     C     recexcp       begsr
     C                   time                    currstamp

     *  Clear record.

     C                   clear                   btbrec1

     *  Get transaction number to use.

416aAC                   exsr      getnewtrn#
     C                   if        error
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return  = 'NOAVLTRN#'
     C                   eval      $message = 'No available Tran # found'
     C                   goto      endexcp
     C                   endif

     *  Move information into fields.

416aAC                   eval      btbcc   = $btsclient
416aAC                   eval      btbwhse = $btbwhse
416aAC                   eval      btbtrnb = $btbtrnb
416aAC                   eval      btbbatid = $btbbatid

416aAC                   if        $btbtrnesnt <> null
416aAC                   eval      btbtrne = $btbtrne
416aAC                   endif

416aAC                   if        $btbtasksnt <> null
416aAC                   eval      btbtask = $btbtask
416aAC                   endif

416aAC                   if        $btbcatsnt <> null
416aAC                   eval      btbcat = $btbcat
416aAC                   endif

416aAC                   eval      btbactive = '0'

416aAC                   if        $btbfromsnt = null
416aAC                   eval      btbfrom = $btbfrom
416aAC                   endif

416aAC                   if        $btbtosnt <> null
416aAC                   eval      btbto = $btbto
416aAC                   endif

416aAC                   if        $btbforksnt <> null
416aAC                   eval      btbforkid = $btbforkid
416aAC                   endif

416aAC                   if        $btbslotsnt <> null
416aAC                   eval      btbslot = $btbslot
416aAC                   endif

416aAC                   if        $btbareasnt <> null
416aAC                   eval      btbarea = $btbarea
416aAC                   endif

416aAC                   eval      btbstart = currstamp
416aAC                   eval      btbend   = currstamp
416aAC                   eval      btbmin   = 0

416aAC                   if        $btbexcpsnt <> null
416aAC                   eval      btbexcp = $btbexcp
416aAC                   endif

416aAC                   if        $btbfforksnt <> null
416aAC                   eval      btbfforkid = $btbfforkid
416aAC                   endif

416aAC                   if        $btbfslotsnt <> null
416aAC                   eval      btbfslot = $btbfslot
416aAC                   endif

416aAC                   if        $btbfareasnt <> null
416aAC                   eval      btbfarea = $btbfarea
416aAC                   endif

416aAC                   eval      btbexcpout = ' '
416aAC                   eval      btbtaskout = ' '
416aAC                   eval      btbtrneout = 0


416aAC                   eval      btbaddts  = currstamp
     C                   eval      btbaddemp = $btsemp#
     C                   eval      btbaddusr = $btsuser
     C                   eval      btbaddjob = $btsjob
     C                   eval      btbaddnbr = $btsjobnbr

     *  Add record

     C                   write(e)  btbrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRADDREC'
     C                   eval      $message = 'Error on "Write '
     C                                      + 'TRNB1" command '
     C                                      + '('
     C                                      + %trim(%editc($btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid
     C                   goto      endexcp
     C                   endif

     C     endexcp       endsr

     *----------------------------------------------------------------
     *  recget1   Get BTSTRANB1 record.
     *----------------------------------------------------------------

     C     recget1       begsr

     *  Open file.

     C                   exsr      fileopen1
     C     error         cabeq     *on           endget1

     *  Get record.

     C                   eval      kycc    = $btsclient
     C                   eval      kytrnb  = $btbtrnb

     C                   if        lock1
     C     keybtb1       chain     btstranb1
     C                   else
     C     keybtb1       chain(n)  btstranb1
     C                   endif

     C                   if        %found
     C                   eval      found = *on
     C                   else
     C                   eval      found = *off
     C                   endif

     C     endget1       endsr

     *----------------------------------------------------------------
     *  recget2   Get BTSTRANB2 record.
     *----------------------------------------------------------------

     C     recget2       begsr

     *  Open file.

     C                   exsr      fileopen2
     C     error         cabeq     *on           endget2

     *  In theory, a battery should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kycc    = $btsclient
     C                   eval      kywhse  = $btbwhse
     C                   eval      kybatid = $btbbatid
     C                   eval      kyactive = '1'
     C     keybtb2       setgt     btstranb2

     C                   if        lock2
     C     keybtb2       readpe    btstranb2
     C                   else
     C     keybtb2       readpe(n) btstranb2
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C     endget2       endsr

     *----------------------------------------------------------------
     *  recget3   Get BTSTRANB3 record.
     *----------------------------------------------------------------

     C     recget3       begsr

     *  Open file.

     C                   exsr      fileopen3
     C     error         cabeq     *on           endget3

     *  In theory, a forklift should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kycc    = $btsclient
     C                   eval      kywhse  = $btbwhse
     C                   eval      kyforkid = $btbforkid
     C                   eval      kyactive = '1'
     C     keybtb3       setgt     btstranb3

     C                   if        lock3
     C     keybtb3       readpe    btstranb3
     C                   else
     C     keybtb3       readpe(n) btstranb3
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C     endget3       endsr

     *----------------------------------------------------------------
     *  recget3ia    Get inactive BTSTRANB3 record.
     *----------------------------------------------------------------

     C     recget3ia     begsr

     *  Open file.

     C                   exsr      fileopen3
     C     error         cabeq     *on           endget3ia

     *  Get last inactive record.

     C                   eval      kycc    = $btsclient
     C                   eval      kywhse  = $btbwhse
     C                   eval      kyforkid = $btbforkid
     C                   eval      kyactive = '0'
     C     keybtb3       setgt     btstranb3

     C                   if        lock3
     C     keybtb3       readpe    btstranb3
     C                   else
     C     keybtb3       readpe(n) btstranb3
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C     endget3ia     endsr

     *----------------------------------------------------------------
     *  recget4   Get BTSTRANB4 record.
     *----------------------------------------------------------------

     C     recget4       begsr

     *  Open file.

     C                   exsr      fileopen4
     C     error         cabeq     *on           endget4

     *  In theory, a slot should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kycc    = $btsclient
     C                   eval      kywhse  = $btbwhse
     C                   eval      kyslot = $btbslot
     C                   eval      kyactive = '1'
     C     keybtb4       setgt     btstranb4

     C                   if        lock4
     C     keybtb4       readpe    btstranb4
     C                   else
     C     keybtb4       readpe(n) btstranb4
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C     endget4       endsr

     *----------------------------------------------------------------
     *  reclocexcp   Location exception.
     *----------------------------------------------------------------

     C     reclocexcp    begsr
416aAC                   time                    currstamp
416aAC                   eval      lock1 = *off
416aAC                   eval      lock2 = *off
416aAC                   eval      lock3 = *off
416aAC                   eval      lock4 = *off

     *  See if there is an active record for battery.
     *    If so, unactivate the record.

416aAC                   eval      lock2 = *on
416aAC                   exsr      recget2
     C                   if        found
416aAC                   exsr      recunactivate
416aAC                   endif
416aAC                   eval      lock2 = *off

     *  See if there is an active record for location (slot & forklift only)
     *    If so, unactivate the record.

416aAC                   select

416aAC                   when      $btbto = 'F'
416aAC                   eval      lock3 = *on
416aAC                   exsr      recget3
     C                   if        found
416aAC                   exsr      recunactivate
416aAC     error         cabeq     *on           endlocexcp
416aAC                   endif
416aAC                   eval      lock3 = *off

416aAC                   when      $btbto = 'S'
416aAC                   eval      lock4 = *on
416aAC                   exsr      recget4
     C                   if        found
416aAC                   exsr      recunactivate
416aAC     error         cabeq     *on           endlocexcp
416aAC                   endif
416aAC                   eval      lock4 = *off

416aAC                   endsl

     *  Create active record for battery.

416aAC                   exsr      reccrtactive
416aAC     error         cabeq     *on           endlocexcp

     *  Initialize datastructure fields.

416aAC                   exsr      file2ds

     C     endlocexcp    endsr

     *----------------------------------------------------------------
     *  recput    Put battery into a location.
     *----------------------------------------------------------------

     C     recput        begsr
416aAC                   time                    currstamp

     *  See if there is an active record for location (slot & forklift only)
     *    If so, unactivate the record.

416aAC                   select

416aAC                   when      $btbto = 'F'
416aAC                   eval      lock3 = *on
416aAC                   exsr      recget3
     C                   if        found
416aAC                   exsr      recunactivate
416aAC     error         cabeq     *on           endput
416aAC                   endif
416aAC                   eval      lock3 = *off

416aAC                   when      $btbto = 'S'
416aAC                   eval      lock4 = *on
416aAC                   exsr      recget4
     C                   if        found
416aAC                   exsr      recunactivate
416aAC     error         cabeq     *on           endput
416aAC                   endif
416aAC                   eval      lock4 = *off

416aAC                   endsl

     *  Create active record for battery.

416aAC                   exsr      reccrtactive

     *  Initialize datastructure fields.

416aAC                   exsr      file2ds

     C     endput        endsr

     *----------------------------------------------------------------
     *  recremove    Remove by unactivating record.
     *----------------------------------------------------------------

     C     recremove     begsr
416aAC                   time                    currstamp

     *  Move information into fields. Set flag if something changed.

416aAC                   eval      btbactive = '0'

416aAC                   eval      btbend = currstamp
416aAC                   eval      fromstamp = btbstart
416aAC                   eval      tostamp   = btbend
416aAC                   exsr      calcdur
416aAC                   eval      btbmin = duration

416aAC                   if        btbto = 'F'
416aAC                   eval      btbmtrend = $btbmtrend
416aAC                   if        btbmtrstr < btbmtrend
416aAC                   eval      btbmtrdur = btbmtrend - btbmtrstr
416aAC                   else
416aAC                   eval      btbmtrdur = 0
416aAC                   endif
416aAC                   endif

416aAC                   if        $btbexcposnt <> null
416aAC                   eval      btbexcpout = $btbexcpout
416aAC                   endif

416aAC                   if        $btbtaskosnt <> null
416aAC                   eval      btbtaskout = $btbtaskout
416aAC                   endif

416aAC                   if        $btbtrneosnt <> null
416aAC                   eval      btbtrneout = $btbtrneout
416aAC                   endif

     *  Update record.

     C                   eval      btbchgts  = currstamp
     C                   eval      btbchgemp = $btsemp#
     C                   eval      btbchgusr = $btsuser
     C                   eval      btbchgjob = $btsjob
     C                   eval      btbchgnbr = $btsjobnbr

     C                   update(e) btbrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRUPDREC1'
     C                   eval      $message = 'Error on "Update '
     C                                      + 'TRNB1" command '
     C                                      + '('
     C                                      + %trim(%editc(btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid
     C                   goto      endremove
     C                   endif

     C     endremove     endsr

     *----------------------------------------------------------------
     *  recunactivate   Unactive record.
     *----------------------------------------------------------------

     C     recunactivate begsr

     *  Move information into fields. Set flag if something changed.

416aAC                   eval      btbactive = '0'

416aAC                   eval      btbend = currstamp
416aAC                   eval      fromstamp = btbstart
416aAC                   eval      tostamp   = btbend
416aAC                   exsr      calcdur
416aAC                   eval      btbmin = duration

416aAC*                  eval      btbmtrend = $btbmtrend
416aAC*                  if        btbmtrstr < btbmtrend
416aAC*                  eval      btbmtrdur = btbmtrend - btbmtrstr
416aAC*                  else
416aAC*                  eval      btbmtrdur = 0
416aAC*                  endif

416aAC                   eval      btbexcpout = 'LOCEXCP'

416aAC                   if        $btbtaskosnt <> null
416aAC                   eval      btbtaskout = $btbtaskout
416aAC                   endif

     *  Since we are unactivating a record, the out empl tran is
     *  set to the current empl tran.

416aAC                   if        $btbtrnesnt <> null
416aAC                   eval      btbtrneout = $btbtrne
416aAC                   endif

     *  Something change, update record.

     C                   eval      btbchgts  = currstamp
     C                   eval      btbchgemp = $btsemp#
     C                   eval      btbchgusr = $btsuser
     C                   eval      btbchgjob = $btsjob
     C                   eval      btbchgnbr = $btsjobnbr

     *  Update record

     C                   select

     C                   when      lock2
     C                   update(e) btbrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRUPDREC2'
     C                   eval      $message = 'Error on "Update '
     C                                      + 'TRNB2" command '
     C                                      + '('
     C                                      + %trim(%editc(btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f2messageid
     C                   goto      endunact
     C                   endif

     C                   when      lock3
     C                   update(e) btbrec3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRUPDREC3'
     C                   eval      $message = 'Error on "Update '
     C                                      + 'TRNB3" command '
     C                                      + '('
     C                                      + %trim(%editc(btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f3messageid
     C                   goto      endunact
     C                   endif

     C                   when      lock4
     C                   update(e) btbrec4
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $return = 'ERRUPDREC4'
     C                   eval      $message = 'Error on "Update '
     C                                      + 'TRNB4" command '
     C                                      + '('
     C                                      + %trim(%editc(btbtrnb:'P'))
     C                                      + ')'
     C                                      + '-' + f4messageid
     C                   goto      endunact
     C                   endif

     C                   endsl

     C     endunact      endsr

     *----------------------------------------------------------------
     *  verifyadd   Add verificaiton
     *----------------------------------------------------------------

     C     verifyadd     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfytrnbsent
     C     error         cabeq     *on           endvfyadd

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfyadd

     C                   exsr      vfybatidsent
     C     error         cabeq     *on           endvfyadd

     *  Validate warehouse.

     C                   if        $btbwhsesnt <> null
     C                   exsr      clrbw0100
     C                   eval      $bwwhse = $btbwhse
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtswhse
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  Validate battery id.

     C                   exsr      clrbb0100
     C                   eval      $bbwhse = $btbwhse
     C                   eval      $bbid   = $btbbatid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsbat
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyadd
     C                   endif

     *  Validate forklift id.

     C                   if        $btbforksnt <> null
     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfid   = $btbforkid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  Validate slot.

     C                   if        $btbslotsnt <> null
     C                   exsr      clrbs0100
     C                   eval      $bswhse = $btbwhse
     C                   eval      $bsslot = $btbslot
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtsslot
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbslotchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     *  Get record if transaction number sent.

     C                   if        $btbtrnb > 0
     C                   eval      lock1 = *off
     C                   exsr      recget1

     *  Error if record found.

     C                   if        found
     C                   eval      error = *on
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return = 'TRN1EXIST'
     C                   eval      $message = 'Transaction already exists '
     C                                       + '('
     C                                       + %trim(%editc($btbtrnb:'P'))
     C                                       + ')'
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     C     endvfyadd     endsr

     *----------------------------------------------------------------
     *  verifychg   Change verification.
     *----------------------------------------------------------------

     C     verifychg     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfytrnbsent
     C     error         cabeq     *on           endvfychg

     *  Valid warehouse must be sent.

     C                   if        $btbwhsesnt <> null
     C                   exsr      clrbw0100
     C                   eval      $bwwhse = $btbwhse
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtswhse
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Validate battery id.

     C                   if        $btbbatidsnt <> null
     C                   exsr      clrbb0100
     C                   eval      $bbwhse = $btbwhse
     C                   eval      $bbid   = $btbbatid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsbat
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Validate forklift id.

     C                   if        $btbforksnt <> null
     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfid   = $btbforkid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Validate slot.

     C                   if        $btbslotsnt <> null
     C                   exsr      clrbs0100
     C                   eval      $bswhse = $btbwhse
     C                   eval      $bsslot = $btbslot
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtsslot
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbslotchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Get & lock record.

     C                   if        $btsaction = '*CHANGE'
     C                   eval      lock1 = *on
     C                   else
     C                   eval      lock1 = *off
     C                   endif
     C                   exsr      recget1

     *  Error if record not found.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return = 'SLT1NOTFND'
     C                   eval      $message = 'Transaction # not found '
     C                                       + '('
     C                                       + %trim(%editc($btbtrnb:'P'))
     C                                       + ')'
     C                   goto      endvfychg
     C                   endif

     C     endvfychg     endsr

     *----------------------------------------------------------------
     *  verifydel   Delete verification.
     *----------------------------------------------------------------

     C     verifydel     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfytrnbsent
     C     error         cabeq     *on           endvfydel

     *  Get & lock record.

     C                   if        $btsaction = '*DELETE'
     C                   eval      lock1 = *on
     C                   else
     C                   eval      lock1 = *off
     C                   endif
     C                   exsr      recget1
     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return = 'TRN1NOTFND'
     C                   eval      $message = 'Transaction # not found '
     C                                       + '('
     C                                       + %trim(%editc($btbtrnb:'P'))
     C                                       + ')'
     C                   goto      endvfydel
     C                   endif

     C     endvfydel     endsr

     *----------------------------------------------------------------
     *  verifyexcp   Exception verification
     *----------------------------------------------------------------

     C     verifyexcp    begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfyexcp

     C                   exsr      vfybatidsent
     C     error         cabeq     *on           endvfyexcp

     C                   exsr      vfyexcpsent
     C     error         cabeq     *on           endvfyexcp

     *  Validate warehouse.

     C                   if        $btbwhsesnt <> null
     C                   exsr      clrbw0100
     C                   eval      $bwwhse = $btbwhse
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtswhse
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyexcp
     C                   endif
     C                   endif

     *  Validate battery id.

     C                   exsr      clrbb0100
     C                   eval      $bbwhse = $btbwhse
     C                   eval      $bbid   = $btbbatid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsbat
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyexcp
     C                   endif

     C     endvfyexcp    endsr

     *----------------------------------------------------------------
     *  verifylocexcp  Location exception verification
     *----------------------------------------------------------------

     C     verifylocexcp begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfylex

     C                   exsr      vfybatidsent
     C     error         cabeq     *on           endvfylex

     C                   exsr      vfytosent
     C     error         cabeq     *on           endvfylex

     *  Valid warehouse must be sent.

     C                   if        $btbwhsesnt <> null
     C                   exsr      clrbw0100
     C                   eval      $bwwhse = $btbwhse
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtswhse
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfylex
     C                   endif

     *  Validate battery id.

     C                   exsr      clrbb0100
     C                   eval      $bbwhse = $btbwhse
     C                   eval      $bbid   = $btbbatid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsbat
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfylex
     C                   endif
     C                   endif

     * Location type cannot be blank.

     C                   if        $btbto = ' '
     C                   eval      error = *on
     C                   eval      $return  = 'BLANKTO'
     C                   eval      $message = 'Location type cannot '
     C                                      + 'be blank'
     C                   goto      endvfylex
     C                   endif

     * Validate location type.

     C                   if        $btbto <> 'F'
     C                             and $btbto <> 'S'
     C                             and $btbto <> 'A'
     C                             and $btbto <> 'W'
     C                   eval      error = *on
     C                   eval      $return  = 'INVLDTO'
     C                   eval      $message = 'Invalid location type '
     C                                      + '(' + $btbto + ')'
     C                   goto      endvfylex
     C                   endif

     *  Extra checks when ...

     C                   select

     *    ... Location type is 'F'

     *      Validate forklift code.

     C                   when      $btbto = 'F'
     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfcode = $btbforkcd
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETCODE'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfylex
     C                   endif
     C                   eval      $btbforkid = $bfid

     *      Validate forklift meter reading.

     C                   if        $btbmtrstr <= 0
     C                   eval      error = *on
     C                   eval      $return  = 'INVLDMTR'
     C                   eval      $message = 'Meter reading must be '
     C                                      + 'greater than zero.'
     C                   goto      endvfylex
     C                   endif

     *    ... Location type is 'S'

     *      Validate slot code.

     C                   when      $btbto = 'S'
     C                   exsr      clrbs0100
     C                   eval      $bswhse = $btbwhse
     C                   eval      $bsslot = $btbslot
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETSLOT'
     C                   exsr      callbtsslot
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbslotchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfylex
     C                   endif

     *    ... All other codes

     *      Area code cannot be blank.

     C                   other
     C                   if        $btbarea = ' '
     C                   eval      error = *on
     C                   eval      $btbareachk = $btserror
     C                   eval      $return  = 'BLANKAREA'
     C                   eval      $message = 'Location cannot be blank '
     C                                      + 'for type ' + $btbto
     C                   goto      endvfylex
     C                   endif

     C                   endsl

     *  Check for warnings

     *    Forklift meter is not less than last recorded meter reading.

     C                   if        $btbto = 'F'
     C                             and $btbmtrschk <> $btswarnovr

     *      Try and get active record, then inactive record.

     C                   eval      lock3 = *off
     C                   exsr      recget3
     C                   if        not found
     C                   exsr      recget3ia
     C                   if        not found
     C                   eval      btbmtrstr = 0
     C                   eval      btbmtrend = 0
     C                   endif
     C                   endif

     *      Issue warning if ...
     *        End meter is > 0 and new start meter is < current end meter.
     *        or New start meter is < current start meter.

     C                   if        btbmtrend > 0 and $btbmtrstr < btbmtrend
     C                             or $btbmtrstr < btbmtrstr
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   eval      $btbmtrschk = $btswarning
     C                   eval      $return  = 'MTRWARNING'
     C                   eval      $message = 'Meter reading '
     C                                       + '('
     C                                       + %trim(%editc($btbmtrstr:'P'))
     C                                       + ') '
     C                                      + 'less than last recorded '
     C                                      + 'reading '
     C                   if        btbmtrend > 0
     C                   eval      $message = %trim($message) + ' '
     C                                       + '('
     C                                       + %trim(%editc(btbmtrend:'P'))
     C                                       + ')'
     C                   else
     C                   eval      $message = %trim($message) + ' '
     C                                       + '('
     C                                       + %trim(%editc(btbmtrstr:'P'))
     C                                       + ')'
     C                   endif
     C                   goto      endvfylex
     C                   endif
     C                   endif

     C     endvfylex     endsr

     *----------------------------------------------------------------
     *  verifymtr    Verify forklift meter reading
     *----------------------------------------------------------------

     C     verifymtr     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfymtr

     C                   exsr      vfyforkcdsent
     C     error         cabeq     *on           endvfymtr

     C                   exsr      vfymtrssent
     C     error         cabeq     *on           endvfymtr

     *  Valid warehouse must be sent.

     C                   if        $btbwhsesnt <> null
     C                   exsr      clrbw0100
     C                   eval      $bwwhse = $btbwhse
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtswhse
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfymtr
     C                   endif
     C                   endif

     *  Validate forklift code


     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfcode = $btbforkcd
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETCODE'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfymtr
     C                   endif
     C                   eval      $btbforkid = $bfid

     *  Validate forklift meter reading.

     C                   if        $btbmtrstr <= 0
     C                   eval      error = *on
     C                   eval      $return  = 'INVLDMTR'
     C                   eval      $message = 'Meter reading must be '
     C                                      + 'greater than zero.'
     C                   goto      endvfymtr
     C                   endif

     *  Check for warnings

     *    Forklift meter is not less than last recorded meter reading.

     C                   if        $btbmtrschk <> $btswarnovr

     *      Try and get active record, then inactive record.

     C                   eval      lock3 = *off
     C                   exsr      recget3
     C                   if        not found
     C                   exsr      recget3ia
     C                   if        not found
     C                   eval      btbmtrstr = 0
     C                   eval      btbmtrend = 0
     C                   endif
     C                   endif

     *      Issue warning if ...
     *        End meter is > 0 and new start meter is < current end meter.
     *        or New start meter is < current start meter.

     C                   if        btbmtrend > 0 and $btbmtrstr < btbmtrend
     C                             or $btbmtrstr < btbmtrstr
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   eval      $btbmtrschk = $btswarning
     C                   eval      $return  = 'MTRWARNING'
     C                   eval      $message = 'Meter reading '
     C                                       + '('
     C                                       + %trim(%editc($btbmtrstr:'P'))
     C                                       + ') '
     C                                      + 'less than last recorded '
     C                                      + 'reading '
     C                   if        btbmtrend > 0
     C                   eval      $message = %trim($message) + ' '
     C                                       + '('
     C                                       + %trim(%editc(btbmtrend:'P'))
     C                                       + ')'
     C                   else
     C                   eval      $message = %trim($message) + ' '
     C                                       + '('
     C                                       + %trim(%editc(btbmtrstr:'P'))
     C                                       + ')'
     C                   endif
     C                   goto      endvfymtr
     C                   endif
     C                   endif

     C     endvfymtr     endsr

     *----------------------------------------------------------------
     *  verifyput   Put verificaiton
     *----------------------------------------------------------------

     C     verifyput     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfyput

     C                   exsr      vfybatidsent
     C     error         cabeq     *on           endvfyput

     C                   exsr      vfytosent
     C     error         cabeq     *on           endvfyput

     *  Validate warehouse.

     C                   if        $btbwhsesnt <> null
     C                   exsr      clrbw0100
     C                   eval      $bwwhse = $btbwhse
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GET'
     C                   exsr      callbtswhse
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyput
     C                   endif
     C                   endif

     *  Validate battery id.

     C                   exsr      clrbb0100
     C                   eval      $bbwhse = $btbwhse
     C                   eval      $bbid   = $btbbatid
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETID'
     C                   exsr      callbtsbat
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyput
     C                   endif

     * Location type cannot be blank.

     C                   if        $btbto = ' '
     C                   eval      error = *on
     C                   eval      $return  = 'BLANKTO'
     C                   eval      $message = 'Location type cannot '
     C                                      + 'be blank'
     C                   goto      endvfyput
     C                   endif

     * Validate location type.

     C                   if        $btbto <> 'F'
     C                             and $btbto <> 'S'
     C                             and $btbto <> 'A'
     C                             and $btbto <> 'W'
     C                   eval      error = *on
     C                   eval      $return  = 'INVLDTO'
     C                   eval      $message = 'Invalid location type '
     C                                      + '(' + $btbto + ')'
     C                   goto      endvfyput
     C                   endif

     *  Extra checks when ...

     C                   select

     *    ... Location type is 'F'

     *      Validate forklift code.

     C                   when      $btbto = 'F'
     C                   exsr      clrbf0100
     C                   eval      $bfwhse = $btbwhse
     C                   eval      $bfcode = $btbforkcd
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETCODE'
     C                   exsr      callbtsfork
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyput
     C                   endif
     C                   eval      $btbforkid = $bfid

     *      Validate forklift meter reading.

     C                   if        $btbmtrstr <= 0
     C                   eval      error = *on
     C                   eval      $return  = 'INVLDMTR'
     C                   eval      $message = 'Meter reading must be '
     C                                      + 'greater than zero.'
     C                   goto      endvfyput
     C                   endif

     *    ... Location type is 'S'

     *      Validate slot code.

     C                   when      $btbto = 'S'
     C                   exsr      clrbs0100
     C                   eval      $bswhse = $btbwhse
     C                   eval      $bsslot = $btbslot
     C                   eval      saveaction = $btsaction
     C                   eval      $btsaction = '*GETSLOT'
     C                   exsr      callbtsslot
     C                   eval      $btsaction = saveaction
     C                   if        error
     C                   eval      $btbslotchk = $btserror
     C                   eval      $return  = $btsreturn
     C                   eval      $message = $btsmessage
     C                   goto      endvfyput
     C                   endif

     *    ... All other codes

     *      Area code cannot be blank.

     C                   other
     C                   if        $btbarea = ' '
     C                   eval      error = *on
     C                   eval      $btbareachk = $btserror
     C                   eval      $return  = 'BLANKAREA'
     C                   eval      $message = 'Location cannot be blank '
     C                                      + 'for type ' + $btbto
     C                   goto      endvfyput
     C                   endif

     C                   endsl

     *  Check for warnings

     *    Forklift meter is not less than last recorded meter reading.

     C                   if        $btbto = 'F'
     C                             and $btbmtrschk <> $btswarnovr

     *      Try and get active record, then inactive record.

     C                   eval      lock3 = *off
     C                   exsr      recget3
     C                   if        not found
     C                   exsr      recget3ia
     C                   if        not found
     C                   eval      btbmtrstr = 0
     C                   eval      btbmtrend = 0
     C                   endif
     C                   endif

     *      Issue warning if ...
     *        End meter is > 0 and new start meter is < current end meter.
     *        or New start meter is < current start meter.

     C                   if        btbmtrend > 0 and $btbmtrstr < btbmtrend
     C                             or $btbmtrstr < btbmtrstr
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   eval      $btbmtrschk = $btswarning
     C                   eval      $return  = 'MTRWARNING'
     C                   eval      $message = 'Meter reading '
     C                                       + '('
     C                                       + %trim(%editc($btbmtrstr:'P'))
     C                                       + ') '
     C                                      + 'less than last recorded '
     C                                      + 'reading '
     C                   if        btbmtrend > 0
     C                   eval      $message = %trim($message) + ' '
     C                                       + '('
     C                                       + %trim(%editc(btbmtrend:'P'))
     C                                       + ')'
     C                   else
     C                   eval      $message = %trim($message) + ' '
     C                                       + '('
     C                                       + %trim(%editc(btbmtrstr:'P'))
     C                                       + ')'
     C                   endif
     C                   goto      endvfyput
     C                   endif
     C                   endif

     C     endvfyput     endsr

     *----------------------------------------------------------------
     *  verifyremove   Remove verification
     *----------------------------------------------------------------

     C     verifyremove  begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfytrnbsent
     C     error         cabeq     *on           endvfyrmv

     *  Get & lock record.

     C                   eval      lock1 = *on
     C                   exsr      recget1

     *  Error if record not found.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return = 'SLT1NOTFND'
     C                   eval      $message = 'Transaction # not found '
     C                                       + '('
     C                                       + %trim(%editc($btbtrnb:'P'))
     C                                       + ')'
     C                   goto      endvfyrmv
     C                   endif

     *  Extra checks when ...

     C                   select

     *    ... Location type is 'F'

     C                   when      btbto = 'F'

     *      Validate forklift meter reading.

     C                   if        $btbmtrend <= 0
     C                   eval      error = *on
     C                   eval      $return  = 'INVLDMTR'
     C                   eval      $message = 'Meter reading must be '
     C                                      + 'greater than zero.'
     C                   unlock    btstranb1
     C                   goto      endvfyrmv
     C                   endif

     C                   endsl

     C     endvfyrmv     endsr

     *----------------------------------------------------------------
     *  vfybatidsent  Verify that battery id was sent.
     *----------------------------------------------------------------

     C     vfybatidsent  begsr

     C                   if        $btbbatidsnt = null
     C                   eval      error = *on
     C                   eval      $btbbatidchk = $btserror
     C                   eval      $return  = 'BATNOTSNT'
     C                   eval      $message = 'Battery id must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfyexcpsent  Verify that exception code was sent.
     *----------------------------------------------------------------

     C     vfyexcpsent   begsr

     C                   if        $btbexcpsnt = null
     C                   eval      error = *on
     C                   eval      $btbexcpchk = $btserror
     C                   eval      $return  = 'EXCPNOTSNT'
     C                   eval      $message = 'Exception code must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfyforkcdsent  Verify that fork code was sent.
     *----------------------------------------------------------------

     C     vfyforkcdsent begsr

     C                   if        $btbforkcsnt = null
     C                   eval      error = *on
     C                   eval      $btbforkcchk = $btserror
     C                   eval      $return  = 'FCDNOTSNT'
     C                   eval      $message = 'Fork code must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfymtrssent   Verify that meter start was sent.
     *----------------------------------------------------------------

     C     vfymtrssent   begsr

     C                   if        $btbmtrssnt = null
     C                   eval      error = *on
     C                   eval      $btbmtrschk = $btserror
     C                   eval      $return  = 'MTRSNOTSNT'
     C                   eval      $message = 'Start meter must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfytosent  Verify that 'to' fields were sent.
     *----------------------------------------------------------------

     C     vfytosent     begsr

     C                   if        $btbtosnt = null
     C                   eval      error = *on
     C                   eval      $btbtochk = $btserror
     C                   eval      $return  = 'TONOTSNT'
     C                   eval      $message = 'To code must be sent'
     C                   goto      endvfyto
     C                   endif

     C                   select

     C                   when      $btbto = 'F'
     C                   if        $btbforkcsnt = null
     C                   eval      error = *on
     C                   eval      $btbforkchk = $btserror
     C                   eval      $return  = 'FRKCNOTSNT'
     C                   eval      $message = 'Fork code must be sent'
     C                   goto      endvfyto
     C                   endif
     C                   if        $btbmtresnt = null
     C                   eval      error = *on
     C                   eval      $btbmtrechk = $btserror
     C                   eval      $return  = 'MTRENOTSNT'
     C                   eval      $message = 'End meter reading '
     C                                      + 'must be sent'
     C                   goto      endvfyto
     C                   endif

     C                   when      $btbto = 'S'
     C                   if        $btbslotsnt = null
     C                   eval      error = *on
     C                   eval      $btbslotchk = $btserror
     C                   eval      $return  = 'SLOTNOTSNT'
     C                   eval      $message = 'Slot id must be sent'
     C                   goto      endvfyto
     C                   endif

     C                   other
     C                   if        $btbareasnt = null
     C                   eval      error = *on
     C                   eval      $btbareachk = $btserror
     C                   eval      $return  = 'AREANOTSNT'
     C                   eval      $message = 'Area must be sent'
     C                   goto      endvfyto
     C                   endif

     C                   endsl

     C     endvfyto      endsr

     *----------------------------------------------------------------
     *  vfytrnbsent  Verify that transaction # was sent.
     *----------------------------------------------------------------

     C     vfytrnbsent   begsr

     C                   if        $btbtrnbsnt = null
     C                   eval      error = *on
     C                   eval      $btbtrnbchk = $btserror
     C                   eval      $return  = 'TRNBNOTSNT'
     C                   eval      $message = 'Transaction # must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfywhsesent  Verify that warehouse was sent
     *----------------------------------------------------------------

     C     vfywhsesent   begsr

     C                   if        $btbwhsesnt = null
     C                   eval      error = *on
     C                   eval      $btbwhsechk = $btserror
     C                   eval      $return  = 'WHSENOTSNT'
     C                   eval      $message = 'Warehouse must be sent'
     C                   endif

     C                   endsr

     P                 E
