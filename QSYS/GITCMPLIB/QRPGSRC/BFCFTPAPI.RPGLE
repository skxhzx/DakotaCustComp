     H NOMAIN
      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   See main copyright below
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  BFCFTPAPI   FTP routines
     *  20 July 2004
     *  Dave Sommerville
     *
417 A*    07/20/04  DAS  4.17
     *      - Created
     *      - Changed name from FTPAPIR4 to BFCFTPAPI
     *      - Changed name of /copy members
     *      - Added binding directory code.
     *      - Reversed Remote and Local file parameters for ftp_put.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    When creating for the first time:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R1M0)
     *
     *      CRTSRVPGM SRVPGM(*) SRCFILE(*/QSRVSRC) TGTRLS(V5R1M0)
     *                ACTGRP(*CALLER) ALWUPD(*YES)
     *
     *      ADDBNDDIRE BNDDIR(*/BFCFTPBND) OBJ((*))
     *
     *                    --- OR ---
     *    When updating:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R1M0)
     *
     *      UPDSRVPGM SRVPGM(*) MODULE(*) SRCFILE(*/QSRVSRC)
     *
     *----------------------------------------------------------------

417 A*----------------------------------------------------------------
417 A*  Binding Directories
417 A*----------------------------------------------------------------

     H bnddir('QC2LE')

     *----------------------------------------------------------------
     * Original name: FTPAPIR4
     * Copyright (c) 2001,2002 Scott C. Klement
     * All rights reserved.
     *
     * Redistribution and use in source and binary forms, with or without
     * modification, are permitted provided that the following conditions
     * are met:
     * 1. Redistributions of source code must retain the above copyright
     *    notice, this list of conditions and the following disclaimer.
     * 2. Redistributions in binary form must reproduce the above copyright
     *    notice, this list of conditions and the following disclaimer in the
     *    documentation and/or other materials provided with the distribution.
     *
     * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
     * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
     * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPO
     * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
     * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTI
     * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
     * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
     * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
     * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WA
     * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
     * SUCH DAMAGE.
     *
     */

      * This code contains contributions from Thomas Raddatz:
      *
      *    -- Added STRPRPRC statements to allow easier object creation.
      *    -- Added peTotBytes parm to StatusProc() prototype, and
      *         changed the code to use it.
      *    -- Added rtvJobCp procedure & prototype
      *    -- Added lvlFileSiz procedure & prototype
      *    -- Added QUSRJOBI API prototype
      *    -- Changed FTP_Conn to accept 230 messages as well as the
      *          220 Welcome message.
      *    -- Added the FTP_ASC_CP and FTP_EBC_CP code pages to the
      *          FTP_codepg prototype, and the code to make them work.
      *    -- Fixed NumToChar to make it return 0 instead of *blanks

     *
     *   >>PRE-COMPILER<<
     *
     *     >>CRTCMD<<  CRTRPGMOD    MODULE(&LI/&OB) +
     *                              SRCFILE(&SL/&SF) +
     *                              SRCMBR(&SM);
     *
     *     >>COMPILE<<
     *       >>PARM<< DBGVIEW(*LIST);
     *       >>PARM<< TGTRLS(V3R2M0);
     *     >>END-COMPILE<<
     *
     *     >>EXECUTE<<
     *
     *   >>END-PRE-COMPILER<<
     *

     **  This is the File Transfer Protocol API service program.
     **                                              SCK (began) 09/13/00
     **  To build this:
     **        CRTRPGMOD FTPAPIR4 DBGVIEW(*LIST)
     **        CRTSRVPGM FTPAPIR4 SRCFILE(LIBSOR/QSRVSRC) BNDDIR(QC2LE) +
     **                  ACTGRP(*CALLER)
     **
     ** To bind it into your own programs:
     **        put a D/COPY LIBSOR/QRPGLESRC,FTPAPI_H  in your D-specs
     **        CRTRPGMOD yourprogram
     **        CRTPGM yourprogram BNDSRVPGM(FTPAPIR4)
     **
     ** TODO List:
     **
     **    Document the source code more, and more consistently.
     **
     **    Create "how to use" documentation.
     **
     **    Better prototypes for write_data & read_data.  Let them
     **        use parms that show the max size of the buffers, etc.
     **
     **    Set socket options for type of service, etc...
     **
     **    Store flags, etc in an array and use some sort of descriptors?
     **      (so we can run multiple transfers at once?)
     **
     **   Additional commands to implement:
     **    (from RFC959)
     **   ABORT (ABOR)
     **

     ** Default remote codepage
     D DFT_RMT_CP      C                   CONST(437)
     ** Default local codepage
     D DFT_LOC_CP      C                   CONST(37)
     ** Default local file mode
     D DFT_MODE        C                   CONST(511)

417 D *COPY FTPAPISRC,SOCKET_H                   
417 D *COPY FTPAPISRC,IFSIO_H                    
417 D *COPY FTPAPISRC,FTPAPI_H                   
417 D *COPY FTPAPISRC,RECIO_H                    

417 M /copy qcopysrc,p.ftpsockt
417 M /copy qcopysrc,p.ftpifsio
417 M /copy qcopysrc,p.ftpapi
417 M /copy qcopysrc,p.ftprecio

     *  Operation would have caused the process to block
     D EAGAIN          C                   3406
     *  A connection has already been establish
     D EISCONN         C                   3431
     *  Operation in progress.
     D EINPROGR        C                   3430
     * invalid argument (also used for "connection refused")
     D EINVAL          C                   3021

     D Reply           PR            10I 0
     D   peSocket                    10I 0 value
     D   peRespMsg                  256A   options(*nopass)

     D RecvLine        PR            10I 0
     D   peSocket                    10I 0
     D   peLine                     512A

     D BufLine         PR            10I 0
     D   peSock                      10I 0 value
     D   peLine                        *   value
     D   peLength                    10I 0 value
     D   peCrLf                       2A   const

     D SendLine        PR            10I 0
     D   peSock                      10I 0 value
     D   peData                     261A   const

     D SendLine2       PR            10I 0
     D   peSock                      10I 0 value
     D   peData                    1005A   const

     D get_block       PR            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value

     D get_byline      PR            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value

     D get_byrec       PR            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value
     D   peRecLen                    10I 0 value

     D put_block       PR            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value

     D ResolveIP       PR            10I 0
     D   peHost                     256A   Const
     D   peIP                        10U 0

     D TCP_Conn        PR            10I 0
     D   peHost                     256A   Const
     D   pePort                       5U 0 Value
     D   peTimeout                    5U 0 value options(*nopass)

     D portcmd         PR            10I 0
     D   peCtrlSock                  10I 0 value

     D pasvcmd         PR            10I 0
     D   peCtrlSock                  10I 0 value

     D SetType         PR            10I 0
     D   peSock                      10I 0 value

     D geterror        PR            10I 0
     D   peErrMsg                   256A   options(*nopass)

     D SetError        PR
     D   peErrNum                    10I 0 value
     D   peErrMsg                    60A   const

     D List2Array      PR            10I 0
     D   peDescr                     10I 0 value
     D   peEntry                   8192A   options(*varsize)
     D   peLength                    10I 0 value

     D NumToChar       PR            17A
     D   pePacked                    15S 5 VALUE

     D DiagLog         PR
     D   peMsgTxt                   256A   Const

     D DiagMsg         PR
     D   peMsgTxt                   256A   Const

     D wkLogProc       S               *   procptr inz(*NULL)
     D LogProc         PR                  ExtProc(wkLogProc)
     D   peMsgTxt                   256A   Const

     D wkStsProc       S               *   procptr inz(*NULL)
     D StatusProc      PR                  ExtProc(wkStsProc)
     D   peBytes                     16P 0 value
     D   peTotBytes                  16P 0 value

     D OpnFile         PR            10I 0
     D   pePath                     256A   const
     D   peRWFlag                     1A   const
     D   peRdWrProc                    *   procptr
     D   peClosProc                    *   procptr

     D ParsePath       PR            10I 0
     D   pePath                     256A   const
     D   peFileSys                   64A
     D   peLibrary                   10A
     D   peObject                    10A
     D   peMember                    10A
     D   peType                      10A

     D fixpath         PR           256A
     D   pePath                     256A   const
     D   peObjType                   10A
     D   peCodePg                    10I 0

     D GetFileAtr      PR            10I 0
     D   peFileName                  10A   const
     D   peFileLib                   10A   const
     D   peFileMbr                   10A   const
     D   peMakeFile                   1A   const
     D   peRtnMbr                    10A
     D   peAttrib                    10A
     D   peSrcFile                    1A

     D getdir          PR           256A

     D S_ISNATIVE      PR             1A
     D    peMode                     10U 0 value

     D S_ISLNK         PR             1A
     D    peMode                     10U 0 value

     D Cmd             PR            10I 0
     D  Command                     200A   const

     D iconv_open      PR            52A   ExtProc('QtqIconvOpen')
     D   ToCode                        *   value
     D   FromCode                      *   value

     D iconv           PR            10I 0 ExtProc('iconv')
     D   Descriptor                  52A   value
     D   p_p_inbuf                     *   value
     D   in_left                     10U 0
     D   p_p_outbuf                    *   value
     D   out_left                    10U 0

     D iconv_clos      PR            10I 0 ExtProc('iconv_close')
     D   descrip                     52A   value

     D InitIConv       PR            10I 0
     D    peFile                      1A   const

     D ToASCII         PR            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value

     D ToEBCDIC        PR            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value

     D ToASCIIF        PR            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value

     D ToEBCDICF       PR            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value

     D rf_read         PR            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D rf_write        PR            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D src_read        PR            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D src_write       PR            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D rf_close        PR            10I 0
     D   peFilDes                    10I 0 value

     D if_read         PR            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D if_write        PR            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D if_close        PR            10I 0
     D   peFilDes                    10I 0 value

     D FD_ZERO         PR
     D   FDSet                       28A

     D FD_SET          PR
     D   FD                          10I 0
     D   FDSet                       28A

     D FD_CLR          PR
     D   FD                          10I 0
     D   FDSet                       28A

     D FD_ISSET        PR             1A
     D   FD                          10I 0
     D   FDSet                       28A

     D CalcBitPos      PR
     D    peDescr                    10I 0
     D    peByteNo                    5I 0
     D    peBitMask                   1A

     D tsend           PR            10I 0
     D   peFD                        10I 0 value
     D   peData                        *   value
     D   peLen                       10I 0 value
     D   peFlags                     10I 0 value

     D rtvJobCp        PR            10I 0

     D lclFileSiz      PR            16P 0
     D   pePath                     256A   const

     D GetTrimLen      PR            16P 0
     D   peBuffer                 32766A   options(*varsize)
     D   peRecEnd                    10I 0 value

     D qusrjobi        PR                         extpgm('QUSRJOBI')
     D   peRcvVar                 32767A          options(*varsize)
     D   peRcvVarLen                 10I 0 const
     D   peFormat                     8A   const
     D   peQJob                      26A   const
     D   peIntJobID                  16A   const
     D   peErrCode                32767A          options(*varsize :
     D                                                    *nopass  )

     D OffsetPtr       PR              *
     D   pePointer                     *   Value
     D   peOffset                    10I 0 Value

     D wkErrMsg        S             60A
     D wkErrNum        S             10I 0
     D wkBinary        S              1A   INZ(*ON)
     D wkPassive       S              1A   INZ(*OFF)
     D wkLineMode      S              1A   INZ(*OFF)
     D wkDebug         S              1A   INZ(*ON)
     D wkUsrXLate      S              1A   INZ(*OFF)
     D wkTrim          S              1A   INZ(*OFF)
     D wkRtnSize       S             10I 0
     D wkMaxEntry      S             10I 0
     D wkRF            S                   like(RFILE)
     D p_RtnList       S               *
     D p_RtnPos        S               *
     D wkRecLen        S              5I 0
     D wkXLInit        S              1A   INZ(*OFF)
     D wkXLFInit       S              1A   INZ(*OFF)
     D wkXlatHack      S              1A   INZ(*OFF)
     D wkIBuf          S          32766A
     D wkIBLen         S              5I 0
     D wkTimeout       S             10I 0
     D wkTotBytes      S             16P 0

     D dsEntry         DS                  based(p_RtnPos)
     D   dsDirLine                  256A
     D   dsNext                       1A

     D dsSrcRec        DS
     D   dsSrcLin                     6S 2
     D   dsSrcDat                     6S 0
     D   dsSrcDta                   250A

     D dsToASC         DS
     D   ICORV_A                     10I 0
     D   ICOC_A                      10I 0 dim(12)

     D dsToEBC         DS
     D   ICORV_E                     10I 0
     D   ICOC_E                      10I 0 dim(12)

     D dsFileASC       DS
     D   ICORV_AF                    10I 0 inz(-1)
     D   ICOC_AF                     10I 0 dim(12)

     D dsFileEBC       DS
     D   ICORV_EF                    10I 0 inz(-1)
     D   ICOC_EF                     10I 0 dim(12)

     D dsASCII         DS
     D   ascii_cp                    10I 0  INZ(DFT_RMT_CP)
     D   ascii_ca                    10I 0  INZ(0)
     D   ascii_sa                    10I 0  INZ(0)
     D   ascii_ss                    10I 0  INZ(1)
     D   ascii_il                    10I 0  INZ(0)
     D   ascii_eo                    10I 0  INZ(1)
     D   ascii_r                      8A    INZ(*allx'00')

     D dsEBCDIC        DS
     D   ebcdic_cp                   10I 0  INZ(37)
     D   ebcdic_ca                   10I 0  INZ(0)
     D   ebcdic_sa                   10I 0  INZ(0)
     D   ebcdic_ss                   10I 0  INZ(1)
     D   ebcdic_il                   10I 0  INZ(0)
     D   ebcdic_eo                   10I 0  INZ(1)
     D   ebcdic_r                     8A    INZ(*allx'00')

     D dsASCIIF        DS
     D   asciif_cp                   10I 0  INZ(DFT_RMT_CP)
     D   asciif_ca                   10I 0  INZ(0)
     D   asciif_sa                   10I 0  INZ(0)
     D   asciif_ss                   10I 0  INZ(1)
     D   asciif_il                   10I 0  INZ(0)
     D   asciif_eo                   10I 0  INZ(1)
     D   asciif_r                     8A    INZ(*allx'00')

     D dsEBCDICF       DS
     D   ebcdicf_cp                  10I 0  INZ(37)
     D   ebcdicf_ca                  10I 0  INZ(0)
     D   ebcdicf_sa                  10I 0  INZ(0)
     D   ebcdicf_ss                  10I 0  INZ(1)
     D   ebcdicf_il                  10I 0  INZ(0)
     D   ebcdicf_eo                  10I 0  INZ(1)
     D   ebcdicf_r                    8A    INZ(*allx'00')


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_Conn:  Connect and log-in to an FTP server.
     *
     *     peHost = Host name of FTP server
     *     peUser = user name of FTP server (or "anonymous")
     *     pePass = Password to use on FTP server (or "user@host")
     *     pePort = (optional) port to connect to.  If not supplied
     *              the value of the constant FTP_PORT will be used.
      *  peTimeout = (optional) number of seconds to wait for data before
      *              assuming the connection is dead and giving up.
      *              if not given, or set to 0, we wait indefinitely.
      *     peAcct = (optional) account (if required by server)
      *              if not given, a blank account name will be tried
      *              if the server requests an account.
     *
     * Returns the socket descriptor of the connection upon
     *            success, or -1 upon error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_Conn        B                   EXPORT
     D FTP_Conn        PI            10I 0
     D   peHost                     256A   const
     D   peUser                      32A   const
     D   pePass                      64A   const
     D   pePort                      10I 0 value options(*nopass)
     D   peTimeout                   10I 0 value options(*nopass)
     D   peAcct                      32A   const options(*nopass)

     D wwPort          S              5u 0 inz(FTP_PORT)
     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwSaveDbg       S              1A
     D wwReply         S             10I 0
     D wwAcct          S             32A

     * User supplied port?
 B01 c                   if        %parms > 3
     c                   eval      wwPort = pePort
 E01 c                   endif

     * Set a timeout value?
 B01 c                   if        %parms > 4
     c                   eval      wkTimeout = peTimeout
 X01 c                   else
     c                   eval      wkTimeout = 0
 E01 c                   endif

      * Set an account name
     c                   if        %parms > 5
     c                   eval      wwAcct = peAcct
     c                   else
     c                   eval      wwAcct = *blanks
     c                   endif

      *************************************************
     * Connect to server:
      *************************************************
     c                   eval      wwSock = TCP_Conn(peHost: wwPort:
     c                                               wkTimeout)
 B01 C                   if        wwSock < 0
     c                   return    -1
 E01 c                   endif

     * 220 myserver.mydomain.com FTP server ready!
     c                   eval      wwReply = Reply(wwSock)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 220
     c                   callp     SetError(FTP_STRRES: 'FTP Server ' +
     c                               ' didn''t give a starting response ' +
     c                               ' of 220!')
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

      *************************************************
     * Send userid:
      *************************************************
 B01 c                   if        SendLine(wwSock: 'USER ' + peUser) < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * 230 User logged in
     * 331 Password required for user
      * 332 Account required for user
     c                   eval      wwReply = Reply(wwSock: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        (wwReply <> 230)  and
     c                             (wwReply <> 331)  and
     c                             (wwReply <> 332)
     c                   callp     SetError(FTP_BADUSR: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

      *************************************************
     * Send password, if required ...
      *************************************************
 B01 c                   if        wwReply = 331

     * ... Hide password from logging:
     c                   eval      wwSaveDbg = wkDebug
     c                   eval      wkDebug = *Off
 B02 c                   if        wwSaveDbg = *On
     c                   callp     DiagLog('> PASS **********')
 E02 c                   endif

     * ... Send password:
 B02 c                   if        SendLine(wwSock: 'PASS ' + pePass) < 0
     c                   callp     close(wwSock)
     c                   eval      wkDebug = wwSaveDbg
     c                   return    -1
 E02 c                   endif

     c                   eval      wkDebug = wwSaveDbg

     * ... 230 User logged in
     * ... 202 command not implemented/superfluous
      * ... 332 Account required for user
     c                   eval      wwReply = Reply(wwSock: wwMsg)
 B02 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif
 B02 c                   if        wwReply <> 230
     c                              and wwReply<> 202
     c                              and wwReply<> 332
     c                   callp     SetError(FTP_BADPAS: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif

 E01 c                   endif

      *************************************************
      * Send account information (believe it or not,
      *  some systems still use this!)
      *************************************************
 B01 c                   if        wwReply = 332

     * ... Hide password from logging:
     c                   eval      wwSaveDbg = wkDebug
     c                   eval      wkDebug = *Off
 B02 c                   if        wwSaveDbg = *On
     c                   callp     DiagLog('> ACCT **********')
 E02 c                   endif

 B01 c                   if        SendLine(wwSock: 'ACCT ' + wwAcct) < 0
     c                   eval      wkDebug = wwSaveDbg
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     c                   eval      wkDebug = wwSaveDbg

     c                   eval      wwReply = Reply(wwSock: wwMsg)
 B02 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif
 B02 c                   if        wwReply <> 230
     c                              and wwReply<> 202
     c                   callp     SetError(FTP_BADACT: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif

     c                   endif

     c                   return    wwSock
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Change directory on remote FTP server
     *
     *       input:   peSock = descriptor returned by ftp_conn
     *              peNewDir = directory to change to.
     *
     *  returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_chdir       B                   EXPORT
     D FTP_chdir       PI            10I 0
     D   peSock                      10I 0 value
     D   peNewDir                   256A   const

     D wwReply         S              5I 0
     D wwRepMsg        S            256A

     c                   if        peNewDir = '..'
     c                   if        SendLine(peSock: 'CDUP') < 0
     c                   return    -1
     c                   endif
     c                   else
417 Dc                   if        SendLine(peSock: 'CWD ' + peNewDir) < 0
     c                   return    -1
 E01 c                   endif
 E01 c                   endif

     c                   eval      wwReply = Reply(peSock: wwRepMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply < 200
     c                               or wwReply > 299
     c                   callp     SetError(FTP_ERRCWD: wwRepMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_binary:  Set file transfer mode to/from binary
     *
     *       peSock = descriptor returned by the ftp_conn proc
     *    peSetting = Setting of binary  *ON = Turn binary mode on
     *                                  *OFF = Turn binary mode off.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_Binary      B                   EXPORT
     D FTP_Binary      PI            10I 0
     D   peSetting                    1A   const

 B01 c                   if        peSetting <> *ON
     c                               and peSetting<>*OFF
     c                   callp     SetError(FTP_PESETT: 'Binary mode ' +
     c                               ' setting must be *ON or *OFF')
     c                   return    -1
 E01 c                   endif

     c                   eval      wkBinary = peSetting
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_LinMod:  Set/Unset line-at-a-time file transfer mode
     *
     *    peSetting = Setting of line mode  *ON = Turn line mode on
     *                                     *OFF = Turn line mode off.
     *                                        R = Use "record mode"
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_LinMod      B                   EXPORT
     D FTP_LinMod      PI            10I 0
     D   peSetting                    1A   const

 B01 c                   if        peSetting <> *ON
     c                               and peSetting<>*OFF
     C                               and peSetting<>'R'
     c                   callp     SetError(FTP_PESETT: 'Line mode ' +
     c                               ' setting must be *ON,*OFF or ''R''!')
     c                   return    -1
 E01 c                   endif

     c                   eval      wkLineMode = peSetting
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_passiv:   Turn passive mode transfers on or off
     *
     *     peSetting = passive mode setting.   *ON = Turn passive on
     *                                        *OFF = Turn passive off
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_passiv      B                   EXPORT
     D FTP_passiv      PI            10I 0
     D   peSetting                    1A   const

 B01 c                   if        peSetting <> *ON
     c                               and peSetting <> *OFF
     c                   callp     SetError(FTP_PESETT: 'Passive mode' +
     c                               ' must be *ON or *OFF!')
     c                   return    -1
 E01 c                   endif

     c                   eval      wkPassive = peSetting
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_log:  Turn on/off logging of session to joblog
     *
     *    peSetting = Setting of logging *ON = Turn logging mode on
     *                                  *OFF = Turn logging mode off.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_Log         B                   EXPORT
     D FTP_Log         PI            10I 0
     D   peSetting                    1A   const

 B01 c                   if        peSetting <> *ON
     c                               and peSetting<>*OFF
     c                   callp     SetError(FTP_PESETT: 'Logging mode ' +
     c                               ' setting must be *ON or *OFF')
     c                   return    -1
 E01 c                   endif

     c                   eval      wkDebug = peSetting
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_rename:   Rename a file on an FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *    peOldName = Original File Name
     *    peNewName = New name to assign.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_rename      B                   EXPORT
     D FTP_rename      PI            10I 0
     D   peSocket                    10I 0 value
     D   peOldName                  256A   const
     D   peNewName                  256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * Here's the name we want to RENAME FROM (RNFR)
 B01 c                   if        SendLine(peSocket: 'RNFR ' + peOldName)<0
     c                   return    -1
 E01 c                   endif

     * 350 File exists, ready for destination name
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 350
     c                   callp     SetError(FTP_RNFERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     * Here's the name we want to RENAME TO (RNTO)
 B01 c                   if        SendLine(peSocket: 'RNTO ' + peNewName)<0
     c                   return    -1
 E01 c                   endif

     * 250 Rename successful.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_RNTERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_delete:   Delete a file on the FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *       peFile = File to delete
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_delete      B                   EXPORT
     D FTP_delete      PI            10I 0
     D   peSocket                    10I 0 value
     D   peFile                     256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * Send delete command to server:
 B01 c                   if        SendLine(peSocket: 'DELE ' + peFile)<0
     c                   return    -1
 E01 c                   endif

     * 250 DELE command succesful.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_DELERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_rmdir:  Delete a directory from an FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *    peDirName = directory to delete
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_rmdir       B                   EXPORT
     D FTP_rmdir       PI            10I 0
     D   peSocket                    10I 0 value
     D   peDirName                  256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send remove directory command:
 B01 c                   if        SendLine(peSocket: 'RMD ' + peDirName)<0
     c                   return    -1
 E01 c                   endif

     * 250 RMD command succesful.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_RMDERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_mkdir:  Create a directory on the FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *    peDirName = directory to create
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_mkdir       B                   EXPORT
     D FTP_mkdir       PI            10I 0
     D   peSocket                    10I 0 value
     D   peDirName                  256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send make directory command:
 B01 c                   if        SendLine(peSocket: 'MKD ' + peDirName)<0
     c                   return    -1
 E01 c                   endif

     * 257 MKD command succesful.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 257
     c                   callp     SetError(FTP_MKDERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_rtvcwd:  Retrieve the current working directory name
     *         from the server.
     *
     *     peSocket = socket number returned by FTP_conn
     *
     *     Returns the directory name, or *BLANKS upon failure
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_rtvcwd      B                   EXPORT
     D FTP_rtvcwd      PI           256A
     D   peSocket                    10I 0 value

     D wwMsg           S            256A
     D wwDir           S            256A
     D wwMsgLen        S              5I 0
     D wwLen           S              5I 0
     D wwPos           S              5I 0
     D wwState         S              5I 0
     D wwCh            S              1A
     D wwReply         S             10I 0

     * send print working directory command:
 B01 c                   if        SendLine(peSocket: 'PWD')<0
     c                   return    *blanks
 E01 c                   endif

     * 257 "/directory/on/server" is current directory.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    *blanks
 E01 c                   endif
 B01 c                   if        wwReply <> 257
     c                   callp     SetError(FTP_PWDERR: wwMsg)
     c                   return    *blanks
 E01 c                   endif

     * This state-machine parses the reply to PWD, extracting
     *  the actual directory name.
     c                   eval      wwDir = *blanks
     c                   eval      wwLen = 0
     c                   eval      wwState = 0
     C     ' '           checkr    wwMsg         wwMsgLen

 B01 c                   do        wwMsgLen      wwPos
     c                   eval      wwCh = %subst(wwMsg:wwPos:1)
 B02 c                   select
     c                   when      wwState = 0
 B03 c                   if        wwCh = '"'
     c                   eval      wwState = 1
 E03 c                   endif
     c                   when      wwState = 1
 B03 c                   if        wwCh = '"'
     c                   eval      wwState = 2
 X03 c                   else
     c                   eval      wwLen = wwLen + 1
     c                   eval      %subst(wwDir:wwLen:1) = wwCh
 E03 c                   endif
     c                   when      wwState = 2
 B03 c                   if        wwCh = '"'
     c                   eval      wwLen = wwLen + 1
     c                   eval      %subst(wwDir:wwLen:1) = '"'
     c                   eval      wwState = 1
 X03 c                   else
     c                   leave
 E03 c                   endif
 E02 c                   endsl
 E01 c                   enddo

     * If we got something, return it... otherwise error.
 B01 c                   if        wwLen < 1
     c                   callp     SetError(FTP_DIRPRS: 'Unable to parse -
     c                             directory name from PWD response')
     c                   return    *blanks
 E01 c                   endif

     c                   return    wwDir
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_quote:  Send a raw, unadulterated, command to the
     *         FTP server, and receive the reply.
     *
     *     peSocket = socket number returned by FTP_conn
     *    peCommand = command to send to server.
     *
     *     Returns the FTP server's reply code,
     *             or -1 upon a socket/network error.
     *
     *  This procedure will not attempt to determine if the quoted
     *  command was successful.  You'll need to check the FTP
     *  server's reply code to see if you get what you expect to.
     *
     *  The message text accompanying the reply code will be available
     *  by calling the FTP_ERROR routine.  The error number returned
     *  for the reply code will always be FTP_QTEMSG
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_quote       B                   EXPORT
     D FTP_quote       PI            10I 0
     D   peSocket                    10I 0 value
     D   peCommand                  256A   const

     D wwReply         S             10I 0
     D wwMsg           S            256A

     * Make sure we've got something to send.
 B01 c                   if        peCommand = *blanks
     c                   callp     SetError(FTP_NOCMD: 'You must supply ' +
     c                              'a command.')
     c                   return    -1
 E01 c                   endif

     * send whatever command was given to us:
 B01 c                   if        SendLine(peSocket: peCommand) < 0
     c                   return    -1
 E01 c                   endif

     * We don't know what responses are valid...
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
     c                   callp     SetError(FTP_QTEMSG: wwMsg)

     c                   return    wwReply
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_size:  Get the size of a file on an FTP server.
     *
     * NOTE: This is not part of the official FTP standard, and
     *       is not supported by many FTP servers, INCLUDING THE
     *       AS/400 FTP SERVER.
     *
     *     peSocket = socket number returned by FTP_conn
     *       peFile = file to look up the size of
     *
     *     Returns -1 upon error, or the size of the file upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_size        B                   EXPORT
     D FTP_size        PI            16P 0
     D   peSocket                    10I 0 value
     D   peFile                     256A   const

     D wwMsg           S            256A
     D wwLen           S             10I 0
     D wwSize16        S             16A
     D wwRtnSize       S             16P 0
     D wwReply         S             10I 0

     * send size command:
 B01 c                   if        SendLine(peSocket: 'SIZE ' + peFile)<0
     c                   return    -1
 E01 c                   endif

     * 213 <byte size>
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 213
     c                   callp     SetError(FTP_SIZERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     * Get the size from the returned message
     c                   eval      wwMsg = %trim(wwMsg)
     c     ' '           checkr    wwMsg         wwLen
 B01 c                   if        wwLen < 16
     c                   eval      wwMsg = %subst('0000000000000000':
     c                                   1:16-wwLen) + wwMsg
 E01 c                   endif
 B01 c                   if        wwLen > 16
     c                   eval      wwMsg = %subst(wwMsg:wwLen-15: 16)
 E01 c                   endif
     c                   movel     wwMsg         wwSize16
     c                   testn                   wwSize16             10
 B01 c                   if        *in10 = *off
     c                   callp     SetError(FTP_SIZPRS: 'Unable to parse '+
     c                               ' reply to SIZE command.')
     c                   return    -1
 E01 c                   endif

     * return size
     c                   move      wwSize16      wwRtnSize
     c                   return    wwRtnSize
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_mtime: Get modification time of a file on an FTP server
     *
     * NOTE: This is not part of the official FTP standard, and
     *       is not supported by many FTP servers, INCLUDING THE
     *       AS/400 FTP SERVER.
     *
     *     peSocket = socket number returned by FTP_conn
     *       peFile = file to look up the size of
     *    peModTime = Modification time returned by server
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_mtime       B                   EXPORT
     D FTP_mtime       PI            16P 0
     D   peSocket                    10I 0 value
     D   peFile                     256A   const
     D   peModTime                     Z

     D wwMsg           S            256A
     D wwLen           S             10I 0
     D wwTemp14        S             14A
     D wwISO           S              8  0
     D wwHMS           S              6  0
     D wwDateFld       S               D
     D wwTimeFld       S               T
     D wwReply         S             10I 0

     * send mod time command:
 B01 c                   if        SendLine(peSocket: 'MDTM ' + peFile)<0
     c                   return    -1
 E01 c                   endif

     * 213 YYYYMMDDHHMMSS
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 213
     c                   callp     SetError(FTP_MODERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     * This extracts the date & time from the returned value:
     c                   eval      wwMsg = %trim(wwMsg)
     c     ' '           checkr    wwMsg         wwLen
 B01 c                   if        wwLen <> 14
     c                   callp     SetError(FTP_MODPRS: 'Mod time format '+
     c                               'not recognized!')
     c                   return    -1
 E01 c                   endif

     c                   eval      wwTemp14 = wwMsg
     c                   testn                   wwTemp14             10
 B01 c                   if        *in10 = *off
     c                   callp     SetError(FTP_MODPRS: 'Mod time format '+
     c                               'not recognized!')
     c                   return    -1
 E01 c                   endif

     * This tests the date for validity
     c                   movel     wwTemp14      wwISO
     c     *ISO          test(D)                 wwISO                  10
 B01 c                   if        *in10 = *on
     c                   callp     SetError(FTP_MODPRS: 'Mod time format '+
     c                               'not recognized!')
     c                   return    -1
 E01 c                   endif

     * This tests the time for validity
     c                   move      wwTemp14      wwHMS
     c     *HMS          test(T)                 wwHMS                  10
 B01 c                   if        *in10 = *on
     c                   callp     SetError(FTP_MODPRS: 'Mod time format '+
     c                               'not recognized!')
     c                   return    -1
 E01 c                   endif

     * return timestamp
     c                   eval      peModTime = z'0001-01-01-00.00.00.000000'
     c     *ISO          move      wwISO         wwDateFld
     c                   move      wwDateFld     peModTime
     c     *HMS          move      wwHMS         wwTimeFld
     c                   move      wwTimeFld     peModTime

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_AddPfm:  Add member to a physical file (ADDPFM)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the ADDPFM command on
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_AddPfm      B                   EXPORT
     D FTP_AddPfm      PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send add member command:
 B01 c                   if        SendLine(peSocket: 'ADDM ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Member Added.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_ADMERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_AddPvm:  Add variable length file member (ADDPVLM)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the ADDPVLM command
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_AddPvm      B                   EXPORT
     D FTP_AddPvm      PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send add variable length member command:
 B01 c                   if        SendLine(peSocket: 'ADDV ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Member Added.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_ADVERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_CrtLib:  Create Library (CRTLIB)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the CRTLIB command
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_CrtLib      B                   EXPORT
     D FTP_CrtLib      PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send create library command:
 B01 c                   if        SendLine(peSocket: 'CRTL ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Member Added.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_CRLERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_CrtPf:  Create Physical File (CRTPF)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the CRTPF command
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_CrtPF       B                   EXPORT
     D FTP_CrtPF       PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send create PF command:
 B01 c                   if        SendLine(peSocket: 'CRTP ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Success.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_CRPERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_CrtSrc:  Create Source Physical File (CRTSRCPF)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the CRTSRCPF command
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_CrtSrc      B                   EXPORT
     D FTP_CrtSrc      PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send create src pf command:
 B01 c                   if        SendLine(peSocket: 'CRTS ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Success.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_CRSERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_DltF:  Delete File (DLTF)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the DLTF command
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_DltF        B                   EXPORT
     D FTP_DltF        PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send delete file command:
 B01 c                   if        SendLine(peSocket: 'DLTF ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Success.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_DLFERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_DltLib:  Delete Library (DLTLIB)
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *      peParms = String of parms to the DLTF command
     *                 on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_DltLib      B                   EXPORT
     D FTP_DltLib      PI            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send delete lib command:
 B01 c                   if        SendLine(peSocket: 'DLTL ' + peParms)<0
     c                   return    -1
 E01 c                   endif

     * 250 Success.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_DLLERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_RmtCmd:  Run a command on the AS/400
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     * NOTE: Commands executed this way may be run in batch as
     *       a seperate job, and may not complete immediately.
     *
     *     peSocket = socket number returned by FTP_conn
     *    peCommand = Command to run on the AS/400.
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_RmtCmd      B                   EXPORT
     D FTP_RmtCmd      PI            16P 0
     D   peSocket                    10I 0 value
     D   peCommand                 1000A   const

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send remote command:
 B01 c                   if        SendLine2(peSocket: 'RCMD '+peCommand)<0
     c                   return    -1
 E01 c                   endif

     * 250 Success.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_RCMERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_NamFmt:  Set the AS/400's Name Format (NAMEFMT) parm
     *
     * NOTE: This command is specific to the AS/400 FTP server
     *       and may not work on other systems.
     *
     *     peSocket = socket number returned by FTP_conn
     *     peFormat = Name Fmt  0=MYLIB/MYFILE.MYMBR
     *                          1=/Filesys/MYLIB.LIB/MYFILE.FILE/MYMBR.MBR
     *
     *     Returns -1 upon error, or 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_NamFmt      B                   EXPORT
     D FTP_NamFmt      PI            16P 0
     D   peSocket                    10I 0 value
     D   peFormat                     5I 0 value

     D wwMsg           S            256A
     D wwReply         S             10I 0

     * send namefmt command:
 B01 c                   if        SendLine(peSocket: 'SITE NAMEFMT ' +
     c                                  %trim(NumToChar(peFormat))) < 0
     c                   return    -1
 E01 c                   endif

     * 250 Success.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 250
     c                   callp     SetError(FTP_NMFERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_dir   Gets a listing of files in a directory on the
     *               FTP server.
     *
     *         peSock = descriptor returned by ftp_conn proc.
     *      pePathArg = Argument to pass to the LIST command on
     *              the FTP server.  for example, it might be
     *              something like '*.txt' or '/windows/*.exe'
     *     peMaxEntry = max number of directory entries to return
     *      peRtnList = pointer to an array.  Each line of the directory
     *                    returned by the server will be placed into this
     *                    array, up to the max number of entries (above)
     *      peRtnSize = Actual number of array elements that could be
     *                    returned.  (can be larger than peMaxEntry if
     *                    your array wasnt large enough)
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_dir         B                   EXPORT
     D FTP_dir         PI            10I 0
     D   peSock                      10I 0 value
     D   pePathArg                  256A   const
     D   peMaxEntry                  10I 0 value
     D   peRtnList                     *   value
     D   peRtnSize                   10I 0

     D wwRC            S             10I 0

     c                   eval      wkRtnSize = 0
     c                   eval      wkMaxEntry = peMaxEntry
     c                   eval      p_RtnList = peRtnList
     c                   eval      p_RtnPos = p_RtnList

     c                   eval      wwRC = FTP_dirraw(peSock: pePathArg:
     c                                      -1: %paddr('LIST2ARRAY'))
 B01 c                   if        wwRC < 0
     c                   return    -1
 E01 c                   endif

     c                   eval      peRtnSize = wkRtnSize
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_dirraw:  Gets a listing of files in a directory on the
     *               FTP server.
     *
     *         peSock = descriptor returned by ftp_conn proc.
     *      pePathArg = Argument to pass to the LIST command on
     *              the FTP server.  for example, it might be
     *              something like '*.txt' or '/windows/*.exe'
     *        peDescr = descriptor to pass to peFunction below
     *     peFunction = procedure to call for each directory entry
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_dirraw      B                   EXPORT
     D FTP_dirraw      PI            10I 0
     D   peSocket                    10I 0 value
     D   pePathArg                  256A   const
     D   peDescr                     10I 0 value
     D   peFunction                    *   PROCPTR value

     D wwSock          S             10I 0
     D wwMsg           S            256A
     D wwReply         S             10I 0
     D wwBinary        S              1A

     c                   eval      wwBinary = wkBinary
     c                   eval      wkBinary = *OFF
 B01 c                   if        SetType(peSocket) < 0
     c                   return    -1
 E01 c                   endif
     c                   eval      wkBinary = wwBinary

 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = pasvcmd(peSocket)
 X01 c                   else
     c                   eval      wwSock = portcmd(peSocket)
 E01 c                   endif
 B01 c                   if        wwSock < 0
     c                   return    -1
 E01 c                   endif

     * Tell server to do a directory list
 B01 c                   if        SendLine(peSocket: 'LIST ' + pePathArg)<0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * 550 No Such File or Directory...
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply = 550
     c                   callp     SetError(FTP_NOFILE: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
     * 150 Starting transfer now
 B01 c                   if        wwReply <> 150
     c                               and wwReply <> 125
     c                   callp     SetError(FTP_BADLST: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * Do the actual file transfer
     c                   eval      wkXlatHack = *on
     c                   eval      wkBinary = *OFF
 B01 c                   if        get_byline(wwSock: peDescr: peFunction)<0
     c                   eval      wkXlatHack = *off
     c                   eval      wkBinary = wwBinary
     c                   return    -1
 E01 c                   endif
     c                   eval      wkXlatHack = *off
     c                   eval      wkBinary = wwBinary

     * 226 Transfer Complete.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply<>226 and wwReply<>250
     c                   callp     SetError(FTP_XFRERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_list: Gets a listing of files in a directory on the
     *               FTP server. (filenames only)
     *
     *         peSock = descriptor returned by ftp_conn proc.
     *      pePathArg = Argument to pass to the NLST command on
     *              the FTP server.  for example, it might be
     *              something like '*.txt' or '/windows/*.exe'
     *     peMaxEntry = max number of directory entries to return
     *      peRtnList = pointer to an array.  Each filename in the dir
     *                    returned by the server will be placed into this
     *                    array, up to the max number of entries (above)
     *      peRtnSize = Actual number of array elements that could be
     *                    returned.  (can be larger than peMaxEntry if
     *                    your array wasnt large enough)
     *
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_list        B                   EXPORT
     D FTP_list        PI            10I 0
     D   peSock                      10I 0 value
     D   pePathArg                  256A   const
     D   peMaxEntry                  10I 0 value
     D   peRtnList                     *   value
     D   peRtnSize                   10I 0

     D wwRC            S             10I 0

     c                   eval      wkRtnSize = 0
     c                   eval      wkMaxEntry = peMaxEntry
     c                   eval      p_RtnList = peRtnList
     c                   eval      p_RtnPos = p_RtnList

     c                   eval      wwRC = FTP_lstraw(peSock: pePathArg:
     c                                      -1: %paddr('LIST2ARRAY'))
 B01 c                   if        wwRC < 0
     c                   return    -1
 E01 c                   endif

     c                   eval      peRtnSize = wkRtnSize
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_lstraw: Gets a listing of files in a directory on the
     *               FTP server. (filenames only)
     *
     *         peSock = descriptor returned by ftp_conn proc.
     *      pePathArg = Argument to pass to the LIST command on
     *              the FTP server.  for example, it might be
     *              something like '*.txt' or '/windows/*.exe'
     *        peDescr = descriptor to pass to peFunction below
     *     peFunction = Procedure to send each line of the resulting
     *              listing to.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_lstraw      B                   EXPORT
     D FTP_lstraw      PI            10I 0
     D   peSocket                    10I 0 value
     D   pePathArg                  256A   const
     D   peDescr                     10I 0 value
     D   peFunction                    *   PROCPTR value

     D wwSock          S             10I 0
     D wwMsg           S            256A
     D wwReply         S             10I 0
     D wwBinary        S              1A

     c                   eval      wwBinary = wkBinary
     c                   eval      wkBinary = *OFF
 B01 c                   if        SetType(peSocket) < 0
     c                   return    -1
 E01 c                   endif
     c                   eval      wkBinary = wwBinary

 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = pasvcmd(peSocket)
 X01 c                   else
     c                   eval      wwSock = portcmd(peSocket)
 E01 c                   endif
 B01 c                   if        wwSock < 0
     c                   return    -1
 E01 c                   endif

     * Tell server to do a directory list
 B01 c                   if        SendLine(peSocket: 'NLST ' + pePathArg)<0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * 550 No Such File or Directory...
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply = 550
     c                   callp     SetError(FTP_NOFILE: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
     * 150 Starting transfer now
 B01 c                   if        wwReply <> 150
     c                               and wwReply <> 125
     c                   callp     SetError(FTP_BADNLS: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * Do the actual file transfer
     c                   eval      wkXlatHack = *on
     c                   eval      wkBinary = *OFF
 B01 c                   if        get_byline(wwSock: peDescr: peFunction)<0
     c                   eval      wkXlatHack = *off
     c                   eval      wkBinary = wwBinary
     c                   return    -1
 E01 c                   endif
     c                   eval      wkBinary = wwBinary
     c                   eval      wkXlatHack = *off

     * 226 Transfer Complete.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply<>226 and wwReply<>250
     c                   callp     SetError(FTP_XFRERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Retrieve a file from FTP server:
     *
     *    parms:    peSocket = descriptor returned by ftp_conn
     *              peRemote = filename of file on remote server
     *               peLocal = filename on this server (optional)
     *                     if not given, we'll assume that its the
     *                     same as the local server's filename.
     *
     *   returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_get         B                   EXPORT
     D FTP_get         PI            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peLocal                    256A   const options(*nopass)

     d p_close         S               *   procptr
     D CloseMe         PR            10I 0 ExtProc(p_close)
     D   descriptor                  10I 0 value

     D wwLocal         S            257A
     D wwErrMsg        S            256A
     D wwFD            S             10I 0
     D wwRC            S             10I 0
     D p_write         S               *   procptr

     * figure out pathname
 B01 c                   if        %parms > 2
     c                   eval      wwLocal = peLocal
 X01 c                   else
     c                   eval      wwLocal = peRemote
 E01 c                   endif

     * get total number of bytes to receive
     c                   eval      wkTotBytes = FTP_size(peSocket :
     c                                                   peRemote )

     * open the file to retrieve
     c                   eval      wwFD = OpnFile(wwLocal: 'W': p_write:
     c                                         p_close)
 B01 c                   if        wwFD < 0
     c                   return    -1
 E01 c                   endif

     * download into the file...
     c                   eval      wwRC = FTP_getraw(peSocket: peRemote:
     c                                     wwFD: p_write)
 B01 c                   if        wwRC < 0
     c                   callp     CloseMe(wwFD)
     c                   return    -1
 E01 c                   endif

     * we're done... woohoo!
     c                   callp     CloseMe(wwFD)
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Send a file to FTP server:
     *
     *    parms:    peSocket = descriptor returned by ftp_conn
     *              peRemote = filename of file on remote server
     *               peLocal = filename on this server (optional)
     *                     if not given, we'll assume that its the
     *                     same as the local server's filename.
     *
     *   returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_put         B                   EXPORT
     D FTP_put         PI            10I 0
     D   peSocket                    10I 0 value
417 MD   peLocal                    256A   const
417 MD   peRemote                   256A   const options(*nopass)
417 DD** peRemote                   256A   const
417 DD** peLocal                    256A   const options(*nopass)

     D p_close         S               *   procptr
     D CloseMe         PR            10I 0 ExtProc(p_close)
     D   descriptor                  10I 0 value

     D wwLocal         S            257A
417 AD wwRemote        S            257A
     D wwErrMsg        S            256A
     D wwFD            S             10I 0
     D wwRC            S             10I 0
     D p_read          S               *   procptr

     * figure out pathname
417 Dc**                 if        %parms > 2
     c                   eval      wwLocal = peLocal
417 Dc**                 else
417 Dc**                 eval      wwLocal = peRemote
417 Dc**                 endif

     * Set remote name to local name if not sent in
417 Ac                   if        %parms < 2
417 Ac                   eval      wwRemote = peLocal
417 Ac                   else
417 Ac                   eval      wwRemote = peRemote
417 Ac                   endif

     * get total number of bytes to send
     c                   eval      wkTotBytes = lclFileSiz(wwLocal)

     * open the file to send
     c                   eval      wwFD = OpnFile(wwLocal: 'R': p_read:
     c                                         p_close)
 B01 c                   if        wwFD < 0
     c                   return    -1
 E01 c                   endif

     * upload data from the file...
417 Dc**                 if        FTP_putraw(peSocket: peRemote: wwFD:
417 Mc                   if        FTP_putraw(peSocket: wwRemote: wwFD:
     c                                     p_read) < 0
     c                   callp     CloseMe(wwFD)
     c                   return    -1
 E01 c                   endif

     * we're done... woohoo!
     c                   callp     CloseMe(wwFD)
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_getraw:   Get a file *from* the FTP server.
     *
     *       peSocket = descriptor returned by ftp_conn proc.
     *      peRemote = Remote filename to request.
     *       peDescr = descriptor to pass to the peRetProc procedure
     *     peWrtProc = Procedure to send the received data to.
     *         int writeproc(int fd, void *buf, int nbytes);
     *
     * Note that the format for the writeproc very deliberately
     *    matches that of the write() API, allowing us to write
     *    directly to the IFS or a socket just by passing that
     *    procedure.
     *
     *  returns 0 upon success, or -1 upon error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_getraw      B                   EXPORT
     D FTP_getraw      PI            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peDescr                     10I 0 value
     D   peWrtProc                     *   PROCPTR value

     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwReply         S             10I 0

 B01 c                   if        SetType(peSocket) < 0
     c                   return    -1
 E01 c                   endif

 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = pasvcmd(peSocket)
 X01 c                   else
     c                   eval      wwSock = portcmd(peSocket)
 E01 c                   endif
 B01 c                   if        wwSock < 0
     c                   return    -1
 E01 c                   endif

 B01 c                   if        SendLine(peSocket: 'RETR ' + peRemote)<0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * 150 Opening transfer now...
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 150
     c                               and wwReply <> 125
     c                   callp     SetError(FTP_BADRTR: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * Do the actual file transfer
 B01 c                   select
     c                   when      wkLineMode = 'R'
 B02 c                   if        get_byrec(wwSock: peDescr: peWrtProc:
     c                                    wkRecLen) < 0
     c                   return    -1
 E02 c                   endif
     c                   when      wkLineMode = *Off
 B02 c                   if        get_block(wwSock: peDescr: peWrtProc)<0
     c                   return    -1
 E02 c                   endif
 X01 c                   other
 B02 c                   if        get_byline(wwSock: peDescr: peWrtProc)<0
     c                   return    -1
 E02 c                   endif
 E01 c                   endsl

     * 226 Transfer Complete.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply<>226 and wwReply<>250
     c                   callp     SetError(FTP_XFRERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_putraw:   Put a file *to* the FTP server.
     *
     *       peSocket = descriptor returned by ftp_conn proc.
     *      peRemote = Remote filename to request.
     *       peDescr = descriptor to pass to the peReadProc procedure
     *    peReadProc = Procedure to call to read more data from
     *         int readproc(int fd, void *buf, int nbytes);
     *
     * Note that the format for the readproc very deliberately
     *    matches that of the write() API, allowing us to write
     *    directly to the IFS or a socket just by passing that
     *    procedure.
     *
     *  returns 0 upon success, or -1 upon error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_putraw      B                   EXPORT
     D FTP_putraw      PI            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peDescr                     10I 0 value
     D   peReadProc                    *   PROCPTR value

     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwReply         S             10I 0

 B01 c                   if        SetType(peSocket) < 0
     c                   return    -1
 E01 c                   endif

 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = pasvcmd(peSocket)
 X01 c                   else
     c                   eval      wwSock = portcmd(peSocket)
 E01 c                   endif
 B01 c                   if        wwSock < 0
     c                   return    -1
 E01 c                   endif

 B01 c                   if        SendLine(peSocket: 'STOR ' + peRemote)<0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * 150 Opening transfer now...
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 150
     c                               and wwReply <> 125
     c                   callp     SetError(FTP_BADSTO: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * note that we don't do "line mode" for a put.
     *   it'd be kinda pointless, since we're not reading
     *   the results...  plus, all it would be is a custom read proc...
 B01 c                   if        put_block(wwSock: peDescr: peReadProc)<0
     c                   return    -1
 E01 c                   endif

     * 226 Transfer Complete.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply<>226 and wwReply<>250
     c                   callp     SetError(FTP_XFRERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_quit:
     *        parms:   peSocket = descriptor returned by ftp_conn
     *
     *  This procedure logs off of the FTP server and closes
     *  the network connection.
     *
     *  Returns:  nothing.  "Always succeeds"
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_quit        B                   EXPORT
     D FTP_quit        PI
     D   peSocket                    10I 0 value

 B01 c                   if        SendLine(peSocket: 'QUIT') >= 0
     c                   callp     Reply(peSocket)
 E01 c                   endif

     C                   callp     close(peSocket)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  returns the error message that occurred when one of the
     *  above routines return -1.
     *
     *  optionally also returns the error number, which will
     *  match one of the constants defined in FTPAPI_H.  This
     *  can be used by programs to anticipate/handle errors.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_error       B                   EXPORT
     D FTP_error       PI            60A
     D   peErrorNum                  10I 0 options(*nopass)
 B01 c                   if        %parms >= 1
     c                   eval      peErrorNum = wkErrNum
 E01 c                   endif
     c                   return    wkErrMsg
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This is used by FTP_dir and FTP_list to make an array of the
     *  returned directory entries.
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P List2Array      B                   EXPORT
     D List2Array      PI            10I 0
     D   peDescr                     10I 0 value
     D   peEntry                   8192A   options(*varsize)
     D   peLength                    10I 0 value

     * skip blank lines
 B01 c                   if        peLength < 1
     c                   return    0
 E01 c                   endif

     * skip anything past max size
     c                   eval      wkRtnSize = wkRtnSize + 1
 B01 c                   if        wkRtnSize > wkMaxEntry
     c                   return    0
 E01 c                   endif

     * add this entry to array
     c                   eval      dsDirLine = %subst(peEntry:1:peLength)

     * move to next array position
 B01 c                   if        wkRtnSize < wkMaxEntry
     c                   eval      p_RtnPos = %addr(dsNext)
 E01 c                   endif

     c                   return    peLength
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Set file translation options for ASCII mode:
     *
     *     peASCII -- codepage to use when translating to/from ASCII
     *     peEBCDIC -- codepage to use when translating to/from EBCDIC
     *
     *  Return 0 for success, -1 upon error
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_codepg      B                   EXPORT
     D FTP_codepg      PI            10I 0
     D   peASCII                     10I 0 value
     D   peEBCDIC                    10I 0 value
     c                   eval      wkXLFinit = *Off
     c                   eval      asciif_cp = peASCII
 B01 c                   if        peEBCDIC = FTP_EBC_CP
     c                   eval      ebcdicf_cp = rtvJobCp
 X01 c                   else
     c                   eval      ebcdicf_cp = peEBCDIC
 E01 c                   endif
     c                   eval      wkUsrXlate = *On
     c                   return    InitIConv(*ON)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_xproc:  Register a procedure to be called at a given
     *        exit point:
     *
     *     peExitPnt = Exit point to register a procedure for
     *           FTP_EXTLOG = Procedure to call when logging control
     *                   session commands.
     *           FTP_EXTSTS = Procedure to call when showing the
     *                   current status of a file transfer.
     *     peProc    = Procedure to register (pass *NULL to disable)
     *
     *  Returns -1 upon error, 0 upon success
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_xproc       B                   EXPORT
     D FTP_xproc       PI            10I 0
     D   peExitPnt                   10I 0 value
     D   peProc                        *   procptr value
 B01 c                   select
     c                   when      peExitPnt = FTP_EXTLOG
     c                   eval      wkLogProc = peProc
     c                   when      peExitPnt = FTP_EXTSTS
     c                   eval      wkStsProc = peProc
 X01 c                   other
     c                   callp     SetError(FTP_BADPNT: 'Invalid exit ' +
     c                                'point!')
     c                   return    -1
 E01 c                   endsl
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to read from a record-based file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P rf_read         B                   export
     D rf_read         PI            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     ** Read a record:
     c                   eval      p_RIOFB_t = Rreadn(wkRF: %addr(peBuffer):
     c                                peBufLen: DFT)

     ** Add CRLF and convert to ASCII if desired:
 B01 c                   if        wkBinary=*Off and RI_nbytes>0
     c                   if        wkTrim = *On
     c                   eval      RI_nbytes= GetTrimLen(peBuffer:RI_Nbytes)
     c                   endif
 B02 c                   if        RI_nbytes >= peBufLen
     c                   eval      RI_nbytes = peBufLen -2
 E02 c                   endif
     c                   eval      %subst(peBuffer:RI_nbytes+1:2) = x'0D25'
     c                   eval      RI_nbytes = RI_nbytes + 2
     c                   callp     ToASCIIF(peBuffer: RI_nbytes)
 E01 c                   endif

     * Return number of bytes read:
     c                   return    RI_nbytes
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  write a record to a record-based file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P rf_write        B                   export
     D rf_write        PI            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

 B01 c                   if        wkBinary = *Off
     c                   callp     ToEBCDICF(peBuffer: peBufLen)
 E01 c                   endif

     c                   eval      p_RIOFB_t = Rwrite(wkRF: %addr(peBuffer):
     c                                      wkRecLen)

     * Return bytes written
 B01 c                   if        RI_nbytes < 1
     c                   return    -1
 X01 c                   else
     c                   return    RI_nbytes
 E01 c                   endif
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to read from a record-based source file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P src_read        B                   export
     D src_read        PI            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

     D wwBuf           S            256A

     ** Read a record:
     c                   eval      p_RIOFB_t = Rreadn(wkRF: %addr(wwBuf):
     c                                %size(wwBuf): DFT)

 B01 c                   if        RI_NBytes < 13
     c                   return    0
 E01 c                   endif

     ** Add CRLF and convert to ASCII if desired:
 B01 c                   if        wkBinary=*Off
     c     ' '           checkr    wwBuf         RI_NBytes
 B02 c                   if        RI_NBytes<12
     c                   eval      RI_NBytes=0
 X02 c                   else
     c                   eval      RI_NBytes = RI_NBytes - 12
 E02 c                   endif
     c                   eval      %subst(peBuffer:1:peBufLen) =
     c                               %trimr(%subst(wwBuf:13:RI_NBytes))
     c                               + x'0D25'
     c                   eval      RI_NBytes = RI_NBytes + 2
     c                   callp     ToASCIIF(peBuffer: RI_nbytes)
 X01 c                   else
     c                   eval      RI_NBytes = RI_NBytes - 12
     c                   eval      %subst(peBuffer: 1: peBufLen) =
     c                                        %subst(wwBuf:13:RI_NBytes)
 E01 c                   endif

     * Return number of bytes read:
     c                   return    RI_nbytes
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to write to a record-based source file...  note that
     *  data comes is raw chunks, we need to convert it back to
     *  records.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P src_write       B                   export
     D src_write       PI            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

 B01 c                   if        wkBinary = *Off
     c                   callp     ToEBCDICF(peBuffer: peBufLen)
 E01 c                   endif

     c                   eval      dsSrcLin = dsSrcLin + 0.01
     c                   eval      dsSrcDta = %subst(peBuffer:1:peBufLen)

     c                   eval      p_RIOFB_t = Rwrite(wkRF: %addr(dsSrcRec):
     c                                      wkRecLen)

     * Return bytes written
 B01 c                   if        RI_nbytes < 1
     c                   return    -1
 X01 c                   else
     c                   return    RI_nbytes
 E01 c                   endif

    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to close a record-based file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P rf_close        B                   export
     D rf_close        PI            10I 0
     D   peFilDes                    10I 0 value
     c                   return    Rclose(wkRF)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to read from a stream file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P if_read         B                   export
     D if_read         PI            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value
     D wwRC            S             10I 0

     C                   eval      wwRC = read(peFilDes: %addr(peBuffer):
     c                                       peBufLen)

 B01 c                   if        wwRC>0 and wkBinary=*Off
     c                   callp     ToASCIIF(peBuffer: wwRC)
 E01 c                   endif

     c                   return    wwRC
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to write to a stream file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P if_write        B                   export
     D if_write        PI            10I 0
     D   peFilDes                    10I 0 value
     D   peBuffer                 32766A   options(*varsize)
     D   peBufLen                    10I 0 value

 B01 c                   if        peBufLen>0 and wkBinary=*Off
     c                   callp     ToEBCDICF(peBuffer: peBufLen)
 E01 c                   endif

     C                   return    write(peFilDes: %addr(peBuffer):
     c                                       peBufLen)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Procedure to close a stream file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P if_close        B                   export
     D if_close        PI            10I 0
     D   peFilDes                    10I 0 value
     c                   return    closef(peFilDes)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Add a file to the end of one that is on an FTP server:
     *
     *    parms:    peSocket = descriptor returned by ftp_conn
     *              peRemote = filename of file on remote server
     *               peLocal = filename on this server (optional)
     *                     if not given, we'll assume that its the
     *                     same as the local server's filename.
     *
     *   returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_append      B                   EXPORT
     D FTP_append      PI            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peLocal                    256A   const options(*nopass)

     D p_close         S               *   procptr
     D CloseMe         PR            10I 0 ExtProc(p_close)
     D   descriptor                  10I 0 value

     D wwLocal         S            257A
     D wwErrMsg        S            256A
     D wwFD            S             10I 0
     D wwRC            S             10I 0
     D p_read          S               *   procptr

     * figure out pathname
 B01 c                   if        %parms > 2
     c                   eval      wwLocal = peLocal
 X01 c                   else
     c                   eval      wwLocal = peRemote
 E01 c                   endif

     * get total number of bytes to send
     c                   eval      wkTotBytes = lclFileSiz(wwLocal)

     * open the file to send
     c                   eval      wwFD = OpnFile(wwLocal: 'R': p_read:
     c                                         p_close)
 B01 c                   if        wwFD < 0
     c                   return    -1
 E01 c                   endif

     * upload data from the file...
 B01 c                   if        FTP_appraw(peSocket: peRemote: wwFD:
     c                                     p_read) < 0
     c                   callp     CloseMe(wwFD)
     c                   return    -1
 E01 c                   endif

     * we're done... woohoo!
     c                   callp     CloseMe(wwFD)
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_appraw:  Append a file *to* the FTP server.
     *
     *       peSocket = descriptor returned by ftp_conn proc.
     *      peRemote = Remote filename to request.
     *       peDescr = descriptor to pass to the peReadProc procedure
     *    peReadProc = Procedure to call to read more data from
     *         int readproc(int fd, void *buf, int nbytes);
     *
     * Note that the format for the readproc very deliberately
     *    matches that of the write() API, allowing us to write
     *    directly to the IFS or a socket just by passing that
     *    procedure.
     *
     *  returns 0 upon success, or -1 upon error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_appraw      B                   EXPORT
     D FTP_appraw      PI            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peDescr                     10I 0 value
     D   peReadProc                    *   PROCPTR value

     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwReply         S             10I 0

 B01 c                   if        SetType(peSocket) < 0
     c                   return    -1
 E01 c                   endif

 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = pasvcmd(peSocket)
 X01 c                   else
     c                   eval      wwSock = portcmd(peSocket)
 E01 c                   endif
 B01 c                   if        wwSock < 0
     c                   return    -1
 E01 c                   endif

 B01 c                   if        SendLine(peSocket: 'APPE ' + peRemote)<0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * 150 Opening transfer now...
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 150
     c                               and wwReply <> 125
     c                   callp     SetError(FTP_BADAPP: wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E01 c                   endif

     * note that we don't do "line mode" for a put.
     *   it'd be kinda pointless, since we're not reading
     *   the results...  plus, all it would be is a custom read proc...
 B01 c                   if        put_block(wwSock: peDescr: peReadProc)<0
     c                   return    -1
 E01 c                   endif

     * 226 Transfer Complete.
     c                   eval      wwReply = Reply(peSocket: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply<>226 and wwReply<>250
     c                   callp     SetError(FTP_XFRERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_trim:  Set the "trim mode" for record-based files that
     *            you PUT in ASCII (non-binary) mode.
     *
     *  Note that this has no affect on GETs, binary-mode transfers,
     *       stream files, or source members.
     *
     *     peSetting = Should be *ON if you want trailing blanks
     *           to be trimmed, or *OFF otherwise.  *OFF is used
     *           by default
     *
     *  returns 0 upon success, or -1 upon error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FTP_trim        B                   EXPORT
     D FTP_trim        PI            10I 0
     D   peSetting                    1A   const

 B01 c                   if        peSetting <> *ON
     c                               and peSetting<>*OFF
     c                   callp     SetError(FTP_PESETT: 'Trim mode ' +
     c                               ' setting must be *ON or *OFF')
     c                   return    -1
 E01 c                   endif

     c                   eval      wkTrim = peSetting
     c                   return    0
     P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This gets a reply to an FTP command.   Here are some examples
     *  of the format of the reply that the FTP servers give:
     *
     * Single line format:
     *      200 Successful completion!
     *
     * Multi-Line format:
     *      201-This is my FTP server
     *      201-Its really neat
     *        Other stuff can be here
     *      201 Done with message.
     *
     * (For more info see RFC959 "File Transfer Protocol" which
     *  is the internet standards document on FTP)
     *
     *  This routine will return the message number, as well as
     *  (optionally) the text of the message.  If there is a multi
     *  line message, the text will be for just the first line.
     *
     *  Returns:
     *        Returns the message number upon success.
     *        -1 upon error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P Reply           B
     D Reply           PI            10I 0
     D   peSocket                    10I 0 value
     D   peRespMsg                  256A   options(*nopass)

     D wwLine          S            512A
     D wwReply         S              3  0
     D wwNum           S              3  0
     D wwChar3         S              3A

     * Get a of text
 B01 c                   if        RecvLine(peSocket: wwLine) < 0
     c                   return    -1
 E01 c                   endif

     * Grab 3-digit reply code
     c                   movel     wwLine        wwChar3
     c                   testn                   wwChar3              99
 B01 c                   if        *in99 = *off
     c                   callp     SetError(FTP_BADRES: 'Not a valid FTP ' +
     c                                ' reply line!')
     c                   return    -1
 E01 c                   endif

     c                   move      wwChar3       wwReply
 B01 c                   if        %parms > 1
     c                   eval      peRespMsg = %subst(wwLine:5)
 E01 c                   endif

     * If this is a single line reply, we're done.
 B01 c                   if        %subst(wwLine:4:1) <> '-'
     c                   return    wwReply
 E01 c                   endif

     * If not, get all lines of reply
 B01 c                   dou       wwNum = wwReply
     c                                and %subst(wwLine:4:1) <> '-'
 B02 c                   if        RecvLine(peSocket: wwLine) < 0
     c                   return    -1
 E02 c                   endif
     c                   movel     wwLine        wwChar3
     c                   testn                   wwChar3              99
     c   99              move      wwChar3       wwNum
     c  N99              eval      wwNum = 0
 E01 c                   enddo

     c                   return    wwReply
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *   Sub-procedure to read one line of text from a socket.
     *
     * Automatically converts to EBCDIC, strips the CR/LF
     * and converts to a fixed-length (blank padded) variable.
     *
     * NOTE: This method reads one byte at a time from the server,
     *       which is very inefficient.  For big transfers, use
     *       BufLine() instead.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P RecvLine        B
     D RecvLine        PI            10I 0
     D  peSocket                     10I 0
     D  peLine                      512A

     D wwLen           S              5  0
     D wwChar          S              1A
     D p_Char          S               *
     D rc              S             10I 0
     D wwErrmsg        S            256A
     D wwTO            S              8A
     D wwSet           S             28A

     c                   eval      wwLen = 0
     c                   eval      peLine = *blanks
     c                   eval      p_char = %addr(wwChar)

     * Keep going til
     * we get a newline
     * character (x'0A')
 B01 c                   dou       wwChar = x'0A' or wwLen = 512

     * Make sure theeres data to receive:
 B02 c                   if        wkTimeout < 1
     c                   eval      p_timeval = *NULL
 X02 c                   else
     c                   eval      p_timeval = %addr(wwTO)
     c                   eval      tv_sec = wkTimeout
     c                   eval      tv_usec = 0
 E02 c                   endif

     c                   callp     FD_ZERO(wwSet)
     c                   callp     FD_SET(peSocket: wwSet)

     c                   callp     select(peSocket+1: %addr(wwSet): *NULL:
     c                                *NULL: p_timeval)

 B02 c                   if        FD_ISSET(peSocket: wwSet) = *OFF
     c                   callp     SetError(FTP_TIMOUT: 'Timed out while '+
     c                             'waiting for data from socket')
     c                   return    -1
 E02 c                   endif

     * Get 1 byte.
     c                   eval      rc = recv(peSocket: p_char: 1: 0)
 B02 c                   if        rc < 1
     c                   callp     SetError(FTP_DISCON: 'Connection ' +
     c                                'dropped while receiving data')
 B03 c                   if        rc < 0
     c                   callp     geterror(wwErrmsg)
     c                   callp     SetError(FTP_DISCON: wwErrmsg)
 E03 c                   endif
     c                   Return    -1
 E02 c                   endif

     * ignore CR/LF
 B02 c                   if        wwChar<>x'0A' and wwChar<>x'0D'
     c                   eval      wwLen = wwLen + 1
     c                   eval      %subst(peLine:wwLen:1) = wwChar
 E02 c                   endif

 E01 c                   enddo


     * translate line to EBCDIC
 B01 c                   if        wwLen > 0
     c                   callp     ToEBCDIC(peLine: wwLen)
 E01 c                   endif

 B01 c                   if        wkDebug = *On
     c                               and wwLen > 0
     c                   callp     DiagLog(peLine)
 E01 c                   endif

     c                   return    wwLen
    p                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * This reads one "line" of text data from a socket, and does
     *  input buffering (for performance purposes)
     *
     * Because of the way the buffering works, you should not use
     * any other input methods in conjunction with this one unless
     * you know what you're doing. :)
     *
     * BufLine() is optimized for "large packets".  In other words
     * it works best when data is being sent in large chunks, such
     * as when the remote end is a program that is sending data
     * at full speed across the comm link.
     *
     *   peSock = socket to read from
     *   peLine = a pointer to a variable to put the line of text into
     *   peLength = max possible length of data to stuff into peLine
     *   peCrLf = Carriage return & line feed chars to use
     *
     *  returns length of data read, or -1 for no data available.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P BufLine         B
     D BufLine         PI            10I 0
     D   peSock                      10I 0 value
     D   peLine                        *   value
     D   peLength                    10I 0 value
     D   peCrLf                       2A   const

     D wwBuf           S          32766A   based(peLine)
     D wwDta           S            512A
     D wwLen           S             10I 0
     D RC              S             10I 0
     D wwXLate         S              1A
     D wwLF            S              1A
     D wwCR            S              1A
     D wwpos           S             10I 0
     D wwTO            S              8A
     D wwSet           S             28A

     ** These are just used to optimize calls to the SCAN
     **  opcode.
     D p_IBuf          S               *   inz(%addr(wkIBuf))
     D wwScan1         S            128A   based(p_IBuf)
     D wwScan2         S            256A   based(p_IBuf)
     D wwScan3         S            512A   based(p_IBuf)
     D wwScan4         S           1024A   based(p_IBuf)
     D wwScan5         S           2048A   based(p_IBuf)
     D wwScan6         S           4096A   based(p_IBuf)
     D wwScan7         S           8192A   based(p_IBuf)
     D wwScan8         S          16384A   based(p_IBuf)

     c                   eval      wwCR = %subst(peCrLf:1:1)
     c                   eval      wwLF = %subst(peCrLf:2:1)

     * make sure our buffer is bigger than caller's
 B01 c                   if        peLength > 32200
     c                   return    -1
 E01 c                   endif

     c                   eval      %subst(wwBuf:1:peLength) = *blanks

 B01 c                   dow       1 = 1

     *************************************************
     ** Try to fulfill request completely from the
     **  input buffer:
     *************************************************
 B02 c                   if        wkIBLen > 0

     **  This whole select group is just optimizing the
     **   scan by scanning a smaller string when the input
     **   buffer is smaller.   All the wwScanX fields are
     **   based in the same area of memory as wkIBuf
 B03 c                   select
     c                   when      wkIBLen <= %size(wwScan1)
     c     wwLF          scan      wwScan1       wwPos
     c                   when      wkIBLen <= %size(wwScan2)
     c     wwLF          scan      wwScan2       wwPos
     c                   when      wkIBLen <= %size(wwScan3)
     c     wwLF          scan      wwScan3       wwPos
     c                   when      wkIBLen <= %size(wwScan4)
     c     wwLF          scan      wwScan4       wwPos
     c                   when      wkIBLen <= %size(wwScan5)
     c     wwLF          scan      wwScan5       wwPos
     c                   when      wkIBLen <= %size(wwScan6)
     c     wwLF          scan      wwScan6       wwPos
     c                   when      wkIBLen <= %size(wwScan7)
     c     wwLF          scan      wwScan7       wwPos
     c                   when      wkIBLen <= %size(wwScan8)
     c     wwLF          scan      wwScan8       wwPos
 X03 c                   other
     c     wwLF          scan      wkIBuf        wwPos
 E03 c                   endsl

 B03 c                   if        wwPos > wkIBLen
     c                   eval      wwPos = 0
 E03 c                   endif

     ** we've got too much data for the var to store
 B03 c                   select
     c                   when      wwPos > peLength
     c                                or (wwPos=0 and wkIBLen>peLength)
     c                   eval      %subst(wwBuf:1:peLength) =
     c                                    %subst(wkIBuf:1:peLength)
     c                   eval      wkIBuf = %subst(wkIBuf:peLength+1)
     c                   eval      wkIBLen = wkIBLen - peLength
     c                   eval      wwLen = peLength
     c                   leave

     ** data starts with an LF:
     c                   when      wwPos = 1
     c                   eval      %subst(wwBuf:1:peLength) = *blanks
     c                   eval      wkIBuf = %subst(wkIBuf:2)
     c                   eval      wkIBLen = wkIBLen - 1
     c                   eval      wwLen = 0
     c                   leave

     ** LF embedded in string:
     c                   when      wwPos > 1
     c                   eval      %subst(wwBuf: 1: wwPos-1) =
     c                                %subst(wkIBuf:1:wwPos-1)
     c                   eval      wkIBuf = %subst(wkIBuf:wwPos+1)
     c                   eval      wkIBLen = wkIBLen - wwPos
     c                   eval      wwLen = wwLen + (wwPos - 1)
     c                   leave
 E03 c                   endsl

 E02 c                   endif

     *************************************************
     ** Couldnt do it from the buffer, so load more
     **  data from the network:
     *************************************************
     * Make sure theres data to receive:
 B02 c                   if        wkTimeout < 1
     c                   eval      p_timeval = *NULL
 X02 c                   else
     c                   eval      p_timeval = %addr(wwTO)
     c                   eval      tv_sec = wkTimeout
     c                   eval      tv_usec = 0
 E02 c                   endif

     c                   callp     FD_ZERO(wwSet)
     c                   callp     FD_SET(peSock: wwSet)

     c                   callp     select(peSock+1: %addr(wwSet): *NULL:
     c                                *NULL: p_timeval)

 B02 c                   if        FD_ISSET(peSock: wwSet) = *OFF
     c                   callp     SetError(FTP_TIMOUT: 'Timed out while '+
     c                             'waiting for data from socket')
     c                   return    -1
 E02 c                   endif

     * read the data
     c                   eval      rc = recv(peSock: %addr(wwDta): 512: 0)
 B02 c                   if        rc < 1
 B03 c                   if        wkIBLen > 0
     c                   eval      %subst(wwBuf: 1: wkIBLen) = wkIBuf
     c                   eval      wwLen = wkIBLen
     c                   eval      wkIBLen = 0
     c                   eval      wkIBuf = *blanks
     c                   leave
 X03 c                   else
     c                   return    -1
 E03 c                   endif
 E02 c                   endif

     c                   eval      %subst(wkIBuf: wkIBLen+1: rc) =
     c                                      %subst(wwDta:1:rc)
     c                   eval      wkIBLen = wkIBLen + rc

 E01 c                   enddo

     *************************************************
     ** Strip CR if found
     *************************************************
 B01 c                   if        wwLen>0 and %subst(wwBuf:wwLen:1) = wwCR
     c                   eval      %subst(wwBuf:wwLen:1) = ' '
     c                   eval      wwLen = wwLen - 1
 E01 c                   endif

     c                   return    wwLen
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * quick wrapper of send() to send to a socket.
     *
     * Automatically converts the data to ASCII, strips extra blanks
     *  from the end, calculates the length and adds a CR/LF.
     *
     * returns the length of the data sent.   A short count
     *   indicates an error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P SendLine        B
     D SendLine        PI            10I 0
     D   peSock                      10I 0 value
     D   peData                     261A   const
     D wwLen           S             10I 0
     D p_Data          S               *
     D wwBigger        S            263A

     c                   eval      wwBigger = peData
     c     ' '           checkr    wwBigger      wwLen

 B01 c                   if        wkDebug = *On
     c                               and wwLen > 0
     c                   callp     DiagLog('> ' + peData)
 E01 c                   endif

 B01 c                   if        wwLen > 0
     c                   callp     ToASCII(wwBigger: wwLen)
 E01 c                   endif

     c                   eval      %subst(wwBigger:wwLen+1:2) = x'0D0A'
     c                   eval      p_Data = %addr(wwBigger)

     c                   return    tsend(peSock:p_Data:wwLen+2:0)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * quick wrapper of send() to send to a socket.
     *
     * Automatically converts the data to ASCII, strips extra blanks
     *  from the end, calculates the length and adds a CR/LF.
     *
     * returns the length of the data sent.   A short count
     *   indicates an error.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P SendLine2       B
     D SendLine2       PI            10I 0
     D   peSock                      10I 0 value
     D   peData                    1005A   const

     D wwLen           S             10I 0
     D p_Data          S               *
     D wwBigger        S           1007A

     c                   eval      wwBigger = peData
     c     ' '           checkr    wwBigger      wwLen

 B01 c                   if        wkDebug = *On
     c                               and wwLen > 0
     c                   callp     DiagLog('> ' + peData)
 E01 c                   endif

 B01 c                   if        wwLen > 0
     c                   callp     ToASCII(wwBigger: wwLen)
 E01 c                   endif

     c                   eval      %subst(wwBigger:wwLen+1:2) = x'0D0A'
     c                   eval      p_Data = %addr(wwBigger)

     c                   return    tsend(peSock:p_Data:wwLen+2:0)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  get_block:
     *      This downloads a file from an FTP server in block mode.
     *      Meaning that data is returned in arbitrary size chunks,
     *      (as opposed to the line by line mode used in get_byline)
     *      Unlike the line mode, this does not convert the data
     *      from ASCII to EBCDIC.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P get_block       B
     D get_block       PI            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value

     D write_data      PR            10I 0 ExtProc(peFunction)
     D   filedes                     10I 0 value
     D   data                          *   value
     D   length                      10U 0 value

     D wwBuffer        S           8192A
     D wwRC            S             10I 0
     D wwAddrBuf       S             16A
     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwSize          S             10I 0
     D wwBytes         S             16P 0
     D wwTO            S              8A
     D wwSet           S             28A

     * get data connection:
     c                   eval      p_sockaddr = %addr(wwAddrBuf)
 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = peSocket
 X01 c                   else
     c                   eval      wwSize = %size(wwAddrBuf)
     c                   eval      wwSock = accept(peSocket: p_sockaddr:
     c                                %addr(wwSize))
     c                   callp     close(peSocket)
 B02 c                   if        wwSock < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_DTAACC: wwMsg)
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     c                   eval      wwBytes = 0

     * download file:
 B01 C                   dou       1 = 0

     * Make sure theres data to receive:
 B02 c                   if        wkTimeout < 1
     c                   eval      p_timeval = *NULL
 X02 c                   else
     c                   eval      p_timeval = %addr(wwTO)
     c                   eval      tv_sec = wkTimeout
     c                   eval      tv_usec = 0
 E02 c                   endif

     c                   callp     FD_ZERO(wwSet)
     c                   callp     FD_SET(wwSock: wwSet)

     c                   callp     select(wwSock+1: %addr(wwSet): *NULL:
     c                                *NULL: p_timeval)

 B02 c                   if        FD_ISSET(wwSock: wwSet) = *OFF
     c                   callp     SetError(FTP_TIMOUT: 'Timed out while '+
     c                             'waiting for data from socket')
     c                   return    -1
 E02 c                   endif

     * receive the data:
     c                   eval      wwRC = recv(wwSock: %addr(wwBuffer):
     c                                       %size(wwBuffer): 0)
 B02 c                   if        wwRC < 1
     c                   callp     close(wwSock)
     c                   return    0
 E02 c                   endif

     c                   add       wwRC          wwBytes

     c                   eval      wwRC = write_data(peFiledes:
     c                                      %addr(wwBuffer): wwRC)
 B02 c                   if        wwRC < 0
     c                   callp     SetError(FTP_GETBWR: 'Binary Recv: ' +
     c                                ' Write proc returned an error.')
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif

 B02 c                   if        wkStsProc <> *NULL
     c                   callp     StatusProc(wwBytes: wkTotBytes)
 E02 c                   endif

 E01 c                   enddo
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  get_byrec:
     *      This downloads a file from an FTP server, by fixed length
     *      records.  This is as opposed to get_block which uses an
     *      arbitrary buffer size, or get_byline which writes data
     *      in delimited lines.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P get_byrec       B
     D get_byrec       PI            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value
     D   peRecLen                    10I 0 value

     D write_data      PR            10I 0 ExtProc(peFunction)
     D   filedes                     10I 0 value
     D   data                          *   value
     D   length                      10U 0 value

     D wwBuffer        S              1A   dim(32766)
     D wwRC            S             10I 0
     D wwAddrBuf       S             16A
     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwSize          S             10I 0
     D wwBufPos        S              5U 0
     D wwNeeded        S              5U 0
     D wwBytes         S             16P 0
     D wwTO            S              8A
     D wwSet           S             28A

     * get data connection:
     c                   eval      p_sockaddr = %addr(wwAddrBuf)
 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = peSocket
 X01 c                   else
     c                   eval      wwSize = %size(wwAddrBuf)
     c                   eval      wwSock = accept(peSocket: p_sockaddr:
     c                                %addr(wwSize))
     c                   callp     close(peSocket)
 B02 c                   if        wwSock < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_DTAACC: wwMsg)
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     c                   eval      wwBytes = 0

     * download file:
 B01 C                   dou       1 = 0

     c                   eval      wwNeeded = peRecLen
     c                   eval      wwBufPos = 1

 B02 c                   dou       wwNeeded = 0

     * Make sure theres data to receive:
 B03 c                   if        wkTimeout < 1
     c                   eval      p_timeval = *NULL
 X03 c                   else
     c                   eval      p_timeval = %addr(wwTO)
     c                   eval      tv_sec = wkTimeout
     c                   eval      tv_usec = 0
 E03 c                   endif

     c                   callp     FD_ZERO(wwSet)
     c                   callp     FD_SET(wwSock: wwSet)

     c                   callp     select(wwSock+1: %addr(wwSet): *NULL:
     c                                *NULL: p_timeval)

 B03 c                   if        FD_ISSET(wwSock: wwSet) = *OFF
     c                   callp     SetError(FTP_TIMOUT: 'Timed out while '+
     c                             'waiting for data from socket')
     c                   return    -1
 E03 c                   endif

     * receive the data
     c                   eval      wwRC = recv(wwSock:
     c                                         %addr(wwBuffer(wwBufPos)):
     c                                         wwNeeded: 0)
 B03 c                   if        wwRC < 1
     c                   callp     close(wwSock)
     c                   return    0
 E03 c                   endif
     c                   eval      wwBufPos = wwBufPos + wwRC
     c                   eval      wwNeeded = wwNeeded - wwRC
 E02 c                   enddo

     c                   add       peRecLen      wwBytes

     c                   eval      wwRC = write_data(peFiledes:
     c                                      %addr(wwBuffer): peRecLen)
 B02 c                   if        wwRC < 0
     c                   callp     SetError(FTP_GETBWR: 'Record Recv: ' +
     c                                ' Write proc returned an error.')
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif

 B02 c                   if        wkStsProc <> *NULL
     c                   callp     StatusProc(wwBytes: wkTotBytes)
 E02 c                   endif

 E01 c                   enddo
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  get_byline:
     *      This downloads data (using FTP's ASCII mode) from the
     *      FTP server.
     *
     *      Data is returned to the write procedure one line at
     *      a time, which makes this easy to use for things like
     *      reading a text file, or directory.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P get_byline      B
     D get_byline      PI            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value

     D write_data      PR            10I 0 ExtProc(peFunction)
     D   filedes                     10I 0 value
     D   data                          *   value
     D   length                      10U 0 value

     D wwBuffer        S          32200A
     D wwRC            S             10I 0
     D wwAddrBuf       S             16A
     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwSize          S             10I 0
     D wwBytes         S             16P 0
     D wwCrLf          S              2A

     * get data connection:
     c                   eval      p_sockaddr = %addr(wwAddrBuf)
 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = peSocket
 X01 c                   else
     c                   eval      wwSize = %size(wwAddrBuf)
     c                   eval      wwSock = accept(peSocket: p_sockaddr:
     c                                   %addr(wwSize))
     c                   callp     close(peSocket)
 B02 c                   if        wwSock < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_DTAACC: wwMsg)
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     c                   eval      wwBytes = 0

     * CR/LF in EBCDIC is 0D and 25.  IF we're translating the
     *   data however, what we're reading may be in another codepage...
     c                   eval      wwCrLf = x'0D25'
 B01 c                   if        wkBinary = *Off
     c                   callp     ToASCIIF(wwCrLf:2)
 E01 c                   endif

     * download file:
 B01 C                   dou       1 = 0
     * select()?
     c                   eval      wwRC = BufLine(wwSock: %addr(wwBuffer):
     c                                      %size(wwBuffer): wwCrLf)
 B02 c                   if        wwRC < 0
     c                   callp     close(wwSock)
     c                   return    0
 E02 c                   endif

     * Older versions of FTPAPI called RecvLine for directories and
     *   that translated ASCII to EBCDIC.  This hack is to avoid
     *   breaking that backward compatability:
 B02 c                   if        wkXlatHack = *On
     c                   callp     ToEBCDIC(wwBuffer: wwRC)
 E02 c                   endif

     c                   add       wwRC          wwBytes

     c                   eval      wwRC = write_data(peFiledes:
     c                                      %addr(wwBuffer): wwRC)
 B02 c                   if        wwRC < 0
     c                   callp     close(wwSock)
     c                   callp     SetError(FTP_GETAWR: 'ByLine Recv: ' +
     c                                ' Write proc returned an error.')
     c                   return    -1
 E02 c                   endif

 B02 c                   if        wkStsProc <> *NULL
     c                   callp     StatusProc(wwBytes: wkTotBytes)
 E02 c                   endif

 E01 c                   enddo
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  put_block:
     *      Upload a file to a FTP server
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P put_block       B
     D put_block       PI            10I 0
     D   peSocket                    10I 0
     D   peFiledes                   10I 0 value
     D   peFunction                    *   PROCPTR value

     D read_data       PR            10I 0 ExtProc(peFunction)
     D   filedes                     10I 0 value
     D   data                          *   value
     D   length                      10U 0 value

     D wwBuffer        S          32766A
     D wwRC            S             10I 0
     D wwAddrBuf       S             16A
     D wwMsg           S            256A
     D wwSock          S             10I 0
     D wwSize          S             10I 0
     D wwBytes         S             16P 0

     * get data connection:
     c                   eval      p_sockaddr = %addr(wwAddrBuf)
 B01 c                   if        wkPassive = *On
     c                   eval      wwSock = peSocket
 X01 c                   else
     c                   eval      wwSize = %size(wwAddrBuf)
     c                   eval      wwSock = accept(peSocket: p_sockaddr:
     c                                          %addr(wwSize))
     c                   callp     close(peSocket)
 B02 c                   if        wwSock < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_DTAACC: '1 '+wwMsg)
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     c                   eval      wwBytes = 0

     * upload file:
 B01 c                   dou       0 = 1

     C                   eval      wwRC = read_data(peFiledes:
     c                                 %addr(wwBuffer): %size(wwBuffer))
 B02 c                   if        wwRC < 1
     c                   leave
 E02 c                   endif

     c                   add       wwRC          wwBytes

     * select()?
     c                   eval      wwRC = tsend(wwSock: %addr(wwBuffer):
     c                                       wwRC: 0)
 B02 c                   if        wwRC < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_PUTBSD: '2 '+wwMsg)
     c                   callp     close(wwSock)
     c                   return    -1
 E02 c                   endif

 B02 c                   if        wkStsProc <> *NULL
     c                   callp     StatusProc(wwBytes: wkTotBytes)
 E02 c                   endif

 E01 c                   enddo

     c                   callp     close(wwSock)
     c                   return    0
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     **  Resolve to IP Address...
     **    Converts a host name from either dotted decimal format or
     **    from a domain name and gets the proper IP address for it.
     **
     **  Input:      peHost -- host name in DNS or dotted-decimal format
     **  Output:     peIP -- IP address (unsigned integer)
     **  Returns:    0 = success, negative value upon failure.
     **
     **  DNS (Domain name service) format is like: "mycomputer.myhost.com"
     **  Dotted-Decimal is like: 192.168.5.124
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P ResolveIP       B
     D ResolveIP       PI            10I 0
     D   peHost                     256A   Const
     D   peIP                        10U 0

     D wwDotted        S             16A
     D wwHostName      S            257A
     D INADDR_NON      C                   CONST(4294967295)
     D wwIP            S             10U 0
     D wwParmNo        S             10I 0
     D wwDataType      S             10I 0
     D wwCurrLen       S             10I 0
     D wwMaxLen        S             10I 0

     c                   eval      wwHostName = %trimr(peHost) + x'00'
     c                   eval      wwDotted =%trim(%subst(wwHostName:1:15))+
     c                             x'00'

     * first try to convert from dotted decimal format:
     c                   eval      wwIP = inet_addr(wwDotted)

     * if that fails, try to do a DNS lookup
 B01 c                   if        wwIP = INADDR_NON

     c                   eval      p_hostent = gethostnam(wwHostName)

     * if DNS lookup failed, its not a valid host.
 B02 c                   if        p_hostent = *NULL
     c                   callp     SetError(FTP_BADIP: 'Host not found.')
     c                   return    -1
 E02 c                   endif

     c                   eval      wwIP = h_addr

 E01 c                   endif

     c                   eval      peIP = wwIP
     c                   return    0
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  TCP Connect
     *    General interface for creating & connecting a TCP socket
     *    to a remote port.
     *
     *  Input:      peHost -- Domain name or dotted-decimal format of
     *                        the host to connect to.
     *              pePort -- port number to connect to.
     *           peTimeout -- (optional) if given, sockets will be
     *                        put in non-blocking mode, and the
     *                        connection will time out after this
     *                        many seconds if no data is received.
     *
     *  Returns:    socket descriptor upon success
     *               or -1 upon failure
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P TCP_Conn        B
     D TCP_Conn        PI            10I 0
     D   peHost                     256A   Const
     D   pePort                       5U 0 Value
     D   peTimeout                    5U 0 value options(*nopass)

     D wwIP            S             10U 0
     D wwSocket        S             10I 0
     D wwAddrBuf       S             16A
     D wwErrMsg        S            256A
     D wwSet           S             28A
     D wwTO            S              8A
     D wwErr           S             10I 0
     D wwTimeout       S              5I 0
     D wwRC            S             10I 0
     D wwFlags         S             10I 0

     * Handle optional args
 B01 c                   if        %parms > 2
     c                   eval      wwTimeout = peTimeout
 X01 c                   else
     c                   eval      wwTimeout = 0
 E01 c                   endif

     * look up host
 B01 c                   if        ResolveIP(peHost: wwIP) < 0
     c                   return    -1
 E01 c                   endif

     * build a socket.  A TCP
     * socket is a "stream" socket (SOCK_STR)
     * using Internet Protocol (AF_INET)
     C                   eval      wwSocket = socket(AF_INET: SOCK_STR:
     C                                                IPPRO_IP)
 B01 c                   if        wwSocket < 0
     c                   callp     SetError(FTP_ERRSKT: 'Unable to create '+
     c                                'socket!')
     c                   return    -1
 E01 c                   endif

     * Put socket in non-blocking mode:
 B01 c                   if        wwTimeout > 0
     c                   eval      wwFlags = fcntl(wwSocket: F_GETFL: 0)
     c                   eval      wwFlags = wwFlags + O_NONBLOCK
     c                   callp     fcntl(wwSocket: F_SETFL: wwFlags)
 E01 c                   endif

     * fill in sockaddr structure,
     * (tells who to connect to)
     c                   eval      p_sockaddr = %addr(wwAddrBuf)
     c                   eval      sin_family = AF_INET
     c                   eval      sin_port = pePort
     c                   eval      sin_addr = wwIP
     c                   eval      sin_zero   = x'0000000000000000'

     * connect to remote site
 B01 c                   if        connect(wwSocket: p_sockaddr: 16) >= 0
     c                   return    wwSocket
 E01 c                   endif

     * An error occurred?
     c                   eval      wwErr = geterror(wwErrMsg)
 B01 c                   if        wwErr = EINVAL
     c                   eval      wwErrMsg = 'Connection refused'
 E01 c                   endif
 B01 c                   if        wwErr <> EINPROGR
     c                   callp     SetError(FTP_ERRCON: wwErrMsg)
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     * No error, but not (yet) connected:
     c                   eval      p_timeval = %addr(wwTO)
     c                   eval      tv_sec = wwTimeout
     c                   eval      tv_usec = 0

     c                   callp     FD_ZERO(wwSet)
     c                   callp     FD_SET(wwSocket: wwSet)

     c                   eval      wwRC = select(wwSocket+1: *NULL:
     c                                  %addr(wwSet): *NULL: %addr(wwTO))

 B01 c                   if        FD_ISSET(wwSocket: wwSet) = *OFF
     c                   callp     SetError(FTP_TIMOUT: 'Connect operation'+
     c                              ' timed out')
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     * this call to connect() should always end in error,
     * since you can't re-use the same socket:
 B01 c                   if        connect(wwSocket: p_sockaddr: 16) >= 0
     c                   callp     SetError(FTP_ERRCON: 'Second connect '+
     c                             'is returning an invalid response')
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     * make sure that the socket did in fact connect,
     *  by making the system return an "is already connected" error:
     c                   eval      wwErr = geterror(wwErrMsg)
 B01 c                   if        wwErr = EINVAL
     c                   eval      wwErrMsg = 'Connection refused'
 E01 c                   endif
 B01 c                   if        wwErr <> EISCONN
     c                   callp     SetError(FTP_ERRCON: wwErrMsg)
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     * return socket desc
     c                   return    wwSocket
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This creates a TCP port thats listening for a connection.
     *  and sends details of that connection to the server using the
     *  FTP PORT subcommand.
     *
     *  This is used for normal (non-passive) file transfers
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P portcmd         B
     D portcmd         PI            10I 0
     D   peCtrlSock                  10I 0 value

     D wwIP            S             10U 0
     D wwLocalIP       S             10U 0
     D wwSocket        S             10I 0
     D wwAddrBuf       S             16A
     D wwCtlAddr       S             16A
     D p_dotted        S               *
     D wwDotted        S             16A   based(p_dotted)
     D wwErrMsg        S            256A
     D wwMsg           S            256A
     D wwPort          S             10U 0
     D wwPortStr       S             80A
     D wwLen           S             10I 0
     D wwMSB           S             10I 0
     D wwLSB           S             10I 0
     D wwReply         S             10I 0


     *******************************************
     * Get the IP addr of the network interface
     * that the control connection is using.
     * we'll listen for the file transfer on
     * the same network interface...
     *******************************************
     c                   eval      wwLen = %size(wwCtlAddr)
 B01 C                   if        getsocknam(peCtrlSock: %addr(wwCtlAddr):
     c                                 %addr(wwLen)) < 0
     c                   callp     geterror(wwErrMsg)
     c                   callp     SetError(FTP_GETSNM: wwErrMsg)
     c                   return    -1
 E01 c                   endif
     c                   eval      p_sockaddr = %addr(wwCtlAddr)
     c                   eval      wwLocalIP = sin_addr

     *******************************************
     * build a socket to send file with
     *******************************************
     C                   eval      wwSocket = Socket(AF_INET: SOCK_STR:
     C                                                IPPRO_IP)
 B01 c                   if        wwSocket < 0
     c                   callp     SetError(FTP_ERRSKT: 'Unable to create '+
     c                                'socket!')
     c                   return    -1
 E01 c                   endif

     *******************************************
     * Lock on to an IP and port.  (we let the
     *  system decide which port)
     *******************************************
     c                   eval      p_sockaddr = %addr(wwAddrBuf)
     c                   eval      sin_family = AF_INET
     c                   eval      sin_port = 0
     c                   eval      sin_addr = wwLocalIP
     c                   eval      sin_zero   = x'0000000000000000'

 B01 c                   if        bind(wwSocket:p_sockaddr:16) < 0
     c                   callp     geterror(wwErrMsg)
     c                   callp     SetError(FTP_ERRBND: wwErrMsg)
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     *******************************************
     * Which port did it use?
     *******************************************
     c                   eval      wwLen = %size(wwAddrBuf)
 B01 C                   if        getsocknam(wwSocket: p_sockaddr:
     c                                   %addr(wwLen)) < 0
     c                   callp     SetError(FTP_GETPRT: 'Unable to get ' +
     c                               ' local port!')
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif
     c                   eval      wwPort = sin_port


     *******************************************
     * Listen for a connection...
     *******************************************
 B01 c                   if        listen(wwSocket: 1) < 0
     c                   callp     SetError(FTP_LSTERR: 'Unable to listen' +
     c                               ' for a file transfer.')
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     *******************************************
     * Build port string.  Should be like this:
     *  a,b,c,d,e,f
     *   where a-d = octets of IP address
     *           e = most significant octet of port #
     *           f = least significant octet of port #
     * example:
     *  127,0,0,1,39,2 would be:
     *    IP 127.0.0.1 and port 9986.
     *******************************************
     c                   eval      p_dotted = inet_ntoa(wwLocalIP)
 B01 c                   if        p_dotted = *NULL
     c                   callp     SetError(FTP_PRTSTR: 'Cant build PORT ' +
     c                               'string.  (shouldnt happen!)')
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif
     c     x'00'         scan      wwDotted      wwLen
 B01 c                   if        wwLen < 2
     c                   callp     SetError(FTP_PRTSTR: 'Cant build PORT ' +
     c                               'string.  (shouldnt happen!)')
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif
     c                   eval      wwLen = wwLen - 1
     c                   eval      wwPortStr = %subst(wwDotted:1:wwLen)
     c     '.':','       xlate     wwPortStr     wwPortStr
     c     wwPort        div       256           wwMSB
     c                   mvr                     wwLSB
     c                   eval      wwPortStr = %trimr(wwPortStr) + ',' +
     c                                   %trimr(NumToChar(wwMSB)) + ',' +
     c                                   %trimr(NumToChar(wwLSB))

     *******************************************
     * Send the PORT string to the server.
     *******************************************
 B01 c                   if        SendLine(peCtrlSock: 'PORT '+wwPortStr)<0
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     * 200 PORT command successful.
     c                   eval      wwReply = Reply(peCtrlSock: wwMsg)
 B01 c                   if        wwReply < 0
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 200
     c                   callp     SetError(FTP_PRTERR: wwMsg)
     c                   callp     close(wwSocket)
     c                   return    -1
 E01 c                   endif

     *******************************************
     * wow.  it appears to have worked?
     *******************************************
     c                   return    wwSocket
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This is used to send the PASV (passive-mode FTP) command to
     *  the server, interpret the results, and connect...
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P pasvcmd         B
     D pasvcmd         PI            10I 0
     D   peCtrlSock                  10I 0 value

     D sscanf          PR                  ExtProc('sscanf')
     D  src_str                   32766A   options(*varsize)
     D  format_str                32766A   options(*varsize)
     D  I1                           10U 0
     D  I2                           10U 0
     D  I3                           10U 0
     D  I4                           10U 0
     D  P1                           10U 0
     D  P2                           10U 0
     D I1              s             10U 0
     D I2              s             10U 0
     D I3              s             10U 0
     D I4              s             10U 0
     D P1              s             10U 0
     D P2              s             10U 0
     D wwEnd           S              5I 0
     D wwStart         S              5I 0
     D wwLen           S              5I 0
     D wwFormat        S             17A
     D wwHost          S             16A
     D wwLSB           S              5I 0
     D wwMSB           S              5I 0
     D wwPasStr        S             80A
     D wwMsg           S            256A
     D wwPort          s              5U 0
     D wwReply         S             10I 0

     *******************************************
     * Send the PASV string to the server.
     *******************************************
 B01 c                   if        SendLine(peCtrlSock: 'PASV') < 0
     c                   return    -1
 E01 c                   endif

     * 227 Entering Passive Mode (Port string)
     c                   eval      wwReply = Reply(peCtrlSock: wwMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply <> 227
     c                   callp     SetError(FTP_PASERR: wwMsg)
     c                   return    -1
 E01 c                   endif

     *******************************************
     * Extract the PORT & IP string from the
     *   reply to the PASV command
     *******************************************
     c     '('           scan      wwMsg         wwStart
 B01 c                   if        wwStart = 0
     c                   callp     SetError(FTP_PASRPY: 'Unable to find ' +
     c                               'conn details in PASV reply.')
     c                   return    -1
 E01 c                   endif
     c     ')'           scan      wwMsg         wwEnd
 B01 c                   if        wwEnd < (wwStart + 8)
     c                   callp     SetError(FTP_PASRPY: 'Unable to find ' +
     c                               'conn details in PASV reply.')
     c                   return    -1
 E01 c                   endif
     c                   eval      wwStart = wwStart + 1
     c                   eval      wwLen = wwEnd - wwStart
     c                   eval      wwPasStr = %subst(wwMsg: wwStart: wwLen)
     c                                  + x'00'

     *******************************************
     * Build actual port and IP values from
     *   the data in the PASV string
     *******************************************
     c                   eval      wwFormat = '%u,%u,%u,%u,%u,%u' + x'00'
     c                   callp     sscanf(wwPasStr: wwFormat:
     c                               i1: i2: i3: i4: p1: p2)
     c                   eval      wwPort = (p1*256) + p2
     c                   eval      wwHost = %trimr(NumToChar(i1)) + '.' +
     c                                      %trimr(NumToChar(i2)) + '.' +
     c                                      %trimr(NumToChar(i3)) + '.' +
     c                                      %trimr(NumToChar(i4))

     *******************************************
     * and connect to it...
     *******************************************
     c                   return    tcp_conn(wwHost: wwPort)

    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  SetType: Set file transfer type (ASCII/BINARY)
     *
     *     peSock = descriptor returned by the ftp_conn proc
     *
     *     This sets the file transfer type to ASCII or BINARY
     *     depending on what was set with the FTP_Binary proc.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P SetType         B
     D SetType         PI            10I 0
     D   peSock                      10I 0 value

     D wwLine          S             20A
     D wwReply         S             10I 0
     D wwRepMsg        S            256A

     * Which mode did we want?
 B01 c                   if        wkBinary = *ON
     c                   eval      wwLine = 'TYPE I'
 X01 c                   else
     c                   eval      wwLine = 'TYPE A'
 E01 c                   endif

     * Tell server about it (and make sure
     *   server understands it)
 B01 c                   if        SendLine(peSock: wwLine) < 0
     c                   return    -1
 E01 c                   endif

     * What? How could an FTP server not implement this?!
     c                   eval      wwReply = Reply(peSock: wwRepMsg)
 B01 c                   if        wwReply < 0
     c                   return    -1
 E01 c                   endif
 B01 c                   if        wwReply < 200
     c                               or wwReply > 299
     c                   callp     SetError(FTP_ERRTYP: wwRepMsg)
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Sets the error number and message that occurs in this service
     *  program.   The FTP_ERROR proc can be used to retrieve it.
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P SetError        B
     D SetError        PI
     D   peErrNum                    10I 0 value
     D   peErrMsg                    60A   const
     c                   eval      wkErrNum = peErrNum
     c                   eval      wkErrMsg = peErrMsg
    P                 E


     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  geterror, gets the error message number "errno" as well as
     *     (optionally) the text of the error message.
     *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P geterror        B
     D geterror        PI            10I 0
     D   peErrMsg                   256A   options(*nopass)

     D geterrno        PR              *   extproc('__errno')
     D strerror        PR              *   extproc('strerror')
     D   errno                       10I 0 value

     D p_error         S               *   INZ(*NULL)
     D wwError         S             10I 0 based(p_Error)
     D p_errmsg        S               *
     D wwErrMsg        S            256A   based(p_errmsg)
     D wwLen           S             10I 0

     C                   eval      p_error = geterrno

 B01 c                   if        %parms >= 1
     c                   eval      p_errmsg = strerror(wwError)
     c     x'00'         scan      wwErrMsg      wwLen
     c                   eval      peErrMsg = %subst(wwErrMsg:1:wwLen)
 E01 c                   endif

     c                   return    wwError
    p                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Sub procedure to format a numeric field into a character
     *   field, so that its easy to read.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P NumToChar       B
     D NumToChar       PI            17A
     D  pePacked                     15S 5 VALUE

     D wkReturn        S             17A
     D wkWhole         S             10A
     D wkDec           S              5A
     D wkPos           S              5I 0

     c                   eval      wkReturn = *blanks

     * handle neg sign
 B01 c                   if        pePacked < 0
     c                   eval      wkReturn = '-'
     c                   eval      pePacked = 0 - pePacked
 E01 c                   endif

     * Handle numbers before
     * decimal place
     c                   movel     pePacked      wkWhole
     c     '0'           check     wkWhole       wkPos
 B01 c                   if        wkPos > 0
     c                   eval      wkReturn = %trim(wkReturn) +
     c                                          %subst(wkWhole:wkPos)
 E01 c                   endif

     * Handle numbers after
     * decimal place
     c                   move      pePacked      wkDec
     c     '0'           checkr    wkDec         wkPos
 B01 c                   if        wkPos > 0
     c                   eval      wkReturn = %trim(wkReturn) + '.' +
     c                                          %subst(wkDec:1:wkPos)
 E01 c                   endif

     * Return 0 instead of *BLANKS
 B01 c                   if        wkReturn = *BLANKS
     c                   eval      wkReturn = '0'
 E01 c                   endif


     c                   Return    wkReturn
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This logs a diagnostic message
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P DiagLog         B
     D DiagLog         PI
     D   peMsgTxt                   256A   Const
 B01 c                   if        wkLogProc = *NULL
     c                   callp     DiagMsg(peMsgTxt)
 X01 c                   else
     c                   callp     LogProc(peMsgTxt)
 E01 c                   endif
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This puts a diagnostic message into the job log
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P DiagMsg         B
     D DiagMsg         PI
     D   peMsgTxt                   256A   Const

     D dsEC            DS
     *                                    Bytes Provided (size of struct)
     D  dsECBytesP             1      4B 0 INZ(256)
     *                                    Bytes Available (returned by API)
     D  dsECBytesA             5      8B 0 INZ(0)
     *                                    Msg ID of Error Msg Returned
     D  dsECMsgID              9     15
     *                                    Reserved
     D  dsECReserv            16     16
     *                                    Msg Data of Error Msg Returned
     D  dsECMsgDta            17    256

     D SndTheMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                    1A

     D wwMsgLen        S             10I 0
     D wwTheKey        S              4A

     c     ' '           checkr    peMsgTxt      wwMsgLen
     c                   callp     SndTheMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsgTxt: wwMsgLen: '*DIAG':
     c                               '*': 0: wwTheKey: dsEC)

    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Open a file & decide which read/write procs are appropriate:
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P OpnFile         B
     D OpnFile         PI            10I 0
     D   pePath                     256A   const
     D   peRWFlag                     1A   const
     D   peRdWrProc                    *   procptr
     D   peClosProc                    *   procptr

     D wwPath          S            257A
     D wwType          S             10A
     D wwTmpType       S             10A
     D wwCP            S             10I 0
     D wwNewCP         S             10I 0
     D wwTmpMbr        S             10A
     D wwMbr           S             10A
     D wwLib           S             10A
     D wwObj           S             10A
     D wwAttr          S             10A
     D wwFS            S             64A
     D wwExists        S              1A
     D wwFD            S             10I 0
     D wwRFFlags       S             10U 0
     D wwWFFlags       S             10U 0
     D wwRRFlags       S             60A
     D wwWRFlags       S             60A
     D wwRFile         S             35A
     D wwSrc           S              1A
     D wwTS            S             12  0
     D wwDate6         S              6  0
     D wwDateFld       S               D
     D wwMsg           S            256A
     D wwNew           S              1A   inz(*on)

     *************************************************
     * Resolve any symlink's into their real pathnames,
     *  and retrieve the object type and codepage.
     *************************************************
     c                   eval      wwExists = *On
     c                   eval      wwPath = fixpath(pePath: wwType: wwCP)
 B01 c                   if        wwType=*blanks
     c                   eval      wwExists = *Off
 E01 c                   endif

     c                   eval      wwNew = *On
 B01 c                   if        peRWFlag = 'R'
     c                   eval      wwNew = *Off
 E01 c                   endif

 B01 c                   if        wwExists = *Off and peRWflag = 'R'
     c                   return    -1
 E01 c                   endif

     *************************************************
     * Parse the pathname that was given to us, so
     *  we know the library/filename when in QSYS.LIB
     *************************************************
 B01 c                   if        wwType='*FILE' or wwType='*MBR'
     c                                or wwExists = *Off
 B02 c                   if        ParsePath(wwPath: wwFS: wwLib: wwObj:
     c                                wwTmpMbr: wwTmpType) < 0
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     *************************************************
     * Determine file attributes for PF/LF/SAVF/etc
     *************************************************
 B01 c                   if        wwExists = *Off
     c                   eval      wwMbr = wwTmpMbr
     c                   eval      wwType = wwTmpType
     c                   eval      wwAttr = 'PF'
     c                   eval      wwSrc=*Off
 B02 c                   if        wwTmpType=*blanks
     c                   eval      wwType = '*STMF'
 E02 c                   endif
 B02 c                   if        wwTmpType='*SAVF'
     c                   eval      wwType='*FILE'
     c                   eval      wwAttr='SAVF'
 E02 c                   endif
 E01 c                   endif

 B01 c                   if        wwType='*FILE' or wwType='*MBR'
 B02 c                   if        GetFileAtr(wwObj: wwLib: wwTmpMbr:
     c                                wwNew: wwMbr: wwAttr: wwSrc) < 0
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     *************************************************
     * Now we've collected all the info, let's do
     *   some validity checking:
     *************************************************
 B01 c                   select
     c                   when      (wwType='*FILE' and wwAttr='SAVF')
     c                               or wwType='*SAVF'
 B02 c                   if        wkBinary = *Off
     C                   callp     SetError(FTP_SAVBIN: 'Save Files must ' +
     c                               'use binary mode!')
     c                   return    -1
 E02 c                   endif

     C                   when      (wwType='*FILE' or wwType='*MBR')
     C                                and wwSrc=*on
     * XXX: Do we really want to do this?!
 B02 c                   if        wkBinary = *On
     C                   callp     SetError(FTP_SRCASC: 'Source files ' +
     c                               'should be transferred in ASCII mode!')
     c                   return    -1
 E02 c                   endif

     c                   when      (wwType='*FILE' or wwType='*MBR')
     c                               and (wwAttr='PF' or wwAttr='LF')

     c                   when      wwType='*FILE' or wwType='*MBR'
     C                   callp     SetError(FTP_INVFIL:'Invalid file type '+
     c                              'for FTP transfer!')
     c                   return    -1

     c                   when      wwType='*STMF'
     c                   when      wwType='*DOC'
     c                   when      wwType='*USRSPC'
 B02 c                   if        wkBinary = *Off
     c                   callp     SetError(FTP_USPBIN: 'User spaces ' +
     c                               'require BINARY mode!')
     c                   return    -1
 E02 c                   endif

 X01 c                   other
     c                   callp     SetError(FTP_INVOBJ: 'Invalid object' +
     c                               ' type.  (Make a savefile!)')
     c                   return    -1
 E01 c                   endsl

     *************************************************
     *  If file didn't exist, we need to make one
     *  to receive data into.
     *************************************************
 B01 c                   if        wwExists = *Off
     c                              and wwType='*FILE' and wwAttr='SAVF'

 B02 c                   if        Cmd('CRTSAVF FILE('+%trim(wwLib)+'/'+
     c                               %trim(wwObj)+')') < 0
     c                   callp     SetError(FTP_BLDSAV: 'Unable to make'+
     c                               ' a savefile to receive data into!')
     c                   return    -1
 E02 c                   endif

 E01 c                   endif

     *************************************************
     * (This is a bit of a hack.) The open flag of
     *  'wr' should automatically clear any data
     *  from the file, but this doesn't appear to
     *  work for save files, so we do it manually...
     *************************************************
 B01 c                   if        wwExists=*On and peRWFlag='W'
     c                               and wwType='*FILE' and wwAttr='SAVF'
 B02 c                   if        Cmd('CLRSAVF FILE(' +%trim(wwLib)+'/'+
     c                                 %trim(wwObj)+')') < 0
     c                   callp     SetError(FTP_CLRSAV:'Unable to clear '+
     c                                'existing save file!')
     c                   return    -1
 E02 c                   endif
 E01 c                   endif

     *************************************************
     * These flags tell how the open will work:
     *************************************************
     c                   eval      wwWFFlags = O_TRUNC+O_CREAT+O_CODEPAGE+
     c                               O_WRONLY
     c                   eval      wwRFFlags = O_RDONLY
     c                   eval      wwWRFlags ='wr, arrseq=Y, secure=Y'+x'00'
     c                   eval      wwRRFlags ='rr, arrseq=Y, secure=Y'+x'00'

 B01 c                   if        wwMbr = *blanks
     c                   eval      wwRFile=%trim(wwLib)+'/'+%trim(wwObj)+
     c                                 x'00'
 X01 c                   else
     c                   eval      wwRFile = %trim(wwLib)+'/'+%trim(wwObj)
     c                                 + '(' + %trim(wwMbr) + ')'+x'00'
 E01 c                   endif

     c                   eval      wwPath = %trim(wwPath) + x'00'

     *************************************************
     * If the user hasn't specifically set ASCII
     *  to EBCDIC translation codepages, we'll
     *  set them now.
     *************************************************
 B01 c                   if        wkBinary = *Off
 B02 c                   if        wwExists = *Off
     c                              or wwCP < 1
     c                   eval      wwCP = DFT_LOC_CP
 E02 c                   endif
 B02 c                   if        wkUsrXLate = *Off
     c                   callp     ftp_codepg(DFT_RMT_CP: wwCP)
     c                   eval      wkUsrXlate = *Off
 E02 c                   endif
 E01 c                   endif

     * codepage of new stream files:
 B01 c                   if        wkBinary = *On
     c                   eval      wwNewCP = asciif_cp
 X01 c                   else
     c                   eval      wwNewCP = wwCP
 E01 c                   endif

     *************************************************
     *  Geez... open the damned file already!
     *************************************************
 B01 c                   select
     c                   when      peRWFlag='R'
     c                               and (wwType='*FILE' or wwType='*MBR')
     c                   eval      wkRF = Ropen(%addr(wwRfile):
     c                                          %addr(wwRRflags))
 B02 c                   if        wkRF = *NULL
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_ROPENR:wwMsg)
     c                   return    -1
 E02 c                   endif
     c                   eval      p_xxopfb = Ropnfbk(wkRF)
     c                   eval      wkRecLen = pgm_reclen
     c                   eval      wwFD = 1
 B02 c                   if        wwSrc = *On
     c                   eval      peRdWrProc = %paddr('SRC_READ')
 X02 c                   else
     c                   eval      peRdWrProc = %paddr('RF_READ')
 E02 c                   endif
     c                   eval      peClosProc = %paddr('RF_CLOSE')
 B02 c                   if        wkBinary = *On
     c                   callp     ftp_linmod('R')
 X02 c                   else
     c                   callp     ftp_linmod(*on)
 E02 c                   endif

     c                   when      peRWFlag='W'
     c                               and (wwType='*FILE' or wwType='*MBR')
     c                   eval      wkRF = Ropen(%addr(wwRfile):
     c                                          %addr(wwWRflags))
 B02 c                   if        wkRF = *NULL
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_ROPENW:wwMsg)
     c                   return    -1
 E02 c                   endif
     c                   eval      p_xxopfb = Ropnfbk(wkRF)
     c                   eval      wkRecLen = pgm_reclen
     c                   eval      wwFD = 1
 B02 c                   if        wwSrc = *On
     c                   eval      peRdWrProc = %paddr('SRC_WRITE')
 X02 c                   else
     c                   eval      peRdWrProc = %paddr('RF_WRITE')
 E02 c                   endif
     c                   eval      peClosProc = %paddr('RF_CLOSE')
 B02 c                   if        wkBinary = *On
     c                   callp     ftp_linmod('R')
 X02 c                   else
     c                   callp     ftp_linmod(*on)
 E02 c                   endif

     c                   when      peRWflag='R'
     c                   eval      wwFD = open(%addr(wwPath): wwRFflags)
 B02 c                   if        wwFD < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_OPNERR:wwMsg)
     c                   return    -1
 E02 c                   endif
     c                   eval      peRdWrProc = %paddr('IF_READ')
     c                   eval      peClosProc = %paddr('IF_CLOSE')

     c                   when      peRWflag='W'
     c                   eval      wwFD = open(%addr(wwPath): wwWFflags:
     c                                      DFT_MODE: wwNewCP)
 B02 c                   if        wwFD < 0
     c                   callp     geterror(wwMsg)
     c                   callp     SetError(FTP_OPNERR:wwMsg)
     c                   return    -1
 E02 c                   endif
     c                   eval      peRdWrProc = %paddr('IF_WRITE')
     c                   eval      peClosProc = %paddr('IF_CLOSE')

 X01 c                   other
     c                   callp     SetError(FTP_UNKNWN:'Unknown error: ' +
     c                              'This shouldn''t happen!')
     c                   return    -1
     c                   eval      peRdWrProc = *NULL
     c                   eval      peClosProc = *NULL
 E01 c                   endsl

 B01 c                   if        wwSrc = *on
     c                   time                    wwTS
     c                   move      wwTS          wwDate6
     c     *JOBRUN       move      wwDate6       wwDateFld
     c     *YMD          move      wwDateFld     dsSrcDat
     c                   eval      dsSrcLin = 0
 E01 c                   endif

     c                   return    wwFD
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This fixes the pathname to a file so that it'll contain the
     *   full, true pathname (not a symlink or relative pathname)
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P GetFileAtr      B
     D GetFileAtr      PI            10I 0
     D   peFileName                  10A   const
     D   peFileLib                   10A   const
     D   peFileMbr                   10A   const
     D   peMakeFile                   1A   const
     D   peRtnMbr                    10A
     D   peAttrib                    10A
     D   peSrcFile                    1A

     D RtvObjd         PR                  ExtPgm('QUSROBJD')
     D   RcvVar                   32766A   options(*varsize)
     D   LenRcvVar                   10I 0 const
     D   Format                       8A   const
     D   QualObj                     20A   const
     D   ObjType                     10A   const
     D   ErrorCode                32766A   options(*varsize)

     D RtvMbrd         PR                  ExtPgm('QUSRMBRD')
     D   RcvVar                   32766A   options(*varsize)
     D   LenRcvVar                   10I 0 const
     D   Format                       8A   const
     D   QualDBF                     20A   const
     D   Member                      10A   const
     D   Overrides                    1A   const
     D   errorcode                32766A   options(*varsize)

     D dsMBRD0100      DS
     D   dsMBytRtn                   10I 0
     D   dsMBytAvl                   10I 0
     D   dsMFileNam                  10A
     D   dsMFileLib                  10A
     D   dsMMbrName                  10A
     D   dsMAttrib                   10A
     D   dsMSrcTyp                   10A
     D   dsMCrtTS                    13A
     D   dsMChgTS                    13A
     D   dsMMbrTxt                   50A
     D   dsMSrcFile                   1A

     D dsObjD0200      DS
     D   dsOBytRtn                   10I 0
     D   dsOBytAvl                   10I 0
     D   dsOObjName                  10A
     D   dsOObjLib                   10A
     D   dsOObjType                  10A
     D   dsORtnLib                   10A
     D   dsOASP                      10I 0
     D   dsOOwner                    10A
     D   dsODomain                    2A
     D   dsOCrtTS                    13A
     D   dsOChgTS                    13A
     D   dsOExtAtr                   10A
     D   dsOText                     50A
     D   dsOSrcFile                  10A
     D   dsOSrcLib                   10A
     D   dsOSrcMbr                   10A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(256)
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwFileMbr       S             10A
     D wwNewMbr        S             10A
     D wwRetry         S              1A   inz(*off)

     c                   eval      peSrcFile = *Off
     c                   eval      peAttrib = *blanks
     c                   eval      peRtnMbr = *blanks

     *************************************************
     * Get object attr.  If not found, make one,
     *  and retrieve again...
     *************************************************
 B01 c                   dou       wwRetry = *Off

     c                   eval      wwRetry = *Off
     c                   eval      dsECBytesA = 0

     c                   callp     RtvObjD(dsOBJD0200: %size(dsOBJD0200):
     c                              'OBJD0200': peFileName+peFileLib:
     c                              '*FILE': dsEC)

 B02 c                   if        dsECBytesA>0 and peMakeFile=*on
     c                              and (dsECMsgID = 'CPF9812'
     c                                or dsECMsgID = 'CPF9801')
 B03 c                   if        Cmd('CRTPF FILE('+%trim(peFileLib)+'/'+
     c                               %trim(peFileName)+') RCDLEN(1024) ' +
     c                               'FILETYPE(*DATA) MBR(*NONE)') < 0
     c                   callp     SetError(FTP_BLDPF: 'Unable to build ' +
     c                              'a physical file to receive data into!')
     c                   return    -1
 E03 c                   endif
     c                   eval      wwRetry = *On
 E02 c                   endif

 E01 c                   enddo

 B01 c                   if        dsECBytesA>0
     c                   callp     diagmsg('QUSROBJD API failed with ' +
     c                                 dsECMsgID)
     c                   callp     SetError(FTP_RTVOBJ:'Unable to retrieve'+
     c                               ' an object description!')
     c                   return    -1
 E01 c                   endif

     c                   eval      peAttrib = dsOExtAtr

 B01 c                   if        dsOExtAtr<>'PF' and dsOExtAtr<>'LF'
     c                   return    0
 E01 c                   endif

     c                   eval      wwFileMbr = peFileMbr
     c                   eval      wwNewMbr = peFileMbr
 B01 c                   if        wwFileMbr = *blanks
     c                   eval      wwFileMbr = '*FIRST'
     c                   eval      wwNewMbr = peFileName
 E01 c                   endif

     *************************************************
     * Get member attributes.  Create one if needed!
     *************************************************
 B01 c                   dou       wwRetry=*off
     c                   eval      wwRetry=*off
     c                   callp     RtvMbrd(dsMBRD0100: %size(dsMbrD0100):
     c                                'MBRD0100':peFileName+peFileLib:
     c                                 wwFileMbr: *OFF: dsEC)
 B02 c                   if        dsECBytesA>0 and peMakeFile=*On
     c                               and (dsECMsgID='CPF3C27'
     c                                 or dsECMsgID='CPF3C26'
     c                                 or dsECMsgID='CPF9815')
 B03 c                   if        Cmd('ADDPFM FILE('+%trim(peFileLib)+'/'+
     c                               %trim(peFileName)+') MBR('+
     c                               %trim(wwNewMbr)+')') < 0
     c                   callp     SetError(FTP_ADPFER: 'Unable to add a '+
     c                               'new member to receive data into!')
     c                   return    -1
 E03 c                   endif
     c                   eval      wwRetry=*on
 E02 c                   endif
 E01 c                   enddo

 B01 c                   if        dsECBytesA > 0
     c                   callp     diagmsg('QUSRMBRD API failed with ' +
     c                                 dsECMsgID)
     c                   callp     SetError(FTP_RTVMBR:'Unable to retrieve'+
     c                               ' a member description!')
     c                   return    -1
 E01 c                   endif

     c                   eval      peRtnMbr = dsMMbrName
     c                   eval      peSrcFile = dsMSrcFile
     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This fixes the pathname to a file so that it'll contain the
     *   full, true pathname (not a symlink or relative pathname)
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P ParsePath       B
     D ParsePath       PI            10I 0
     D   pePath                     256A   const
     D   peFileSys                   64A
     D   peLibrary                   10A
     D   peObject                    10A
     D   peMember                    10A
     D   peType                      10A

     D wwExt           S             10A
     D wwObj           S             10A
     D wwPart          S             64A
     D wwPartLen       S              5I 0
     D wwPath          S            257A
     D wwPos           S              5I 0
     D X               S              5I 0

     D lower           C                   'abcdefghijklmnopqrstuvwxyz'
     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     c                   eval      wwPath = %trim(pePath)
 B01 c                   if        %subst(wwPath:1:1) = '/'
     c                   eval      wwPath = %subst(wwPath:2)
 E01 c                   endif

 B01 c                   dow       1 = 1

     *************************************************
     * Get the next "part" of the path.
     *************************************************
     c     '/'           scan      wwPath        wwPos
 B02 c                   if        wwPos < 2 or wwPos >= %size(wwPath)
     c                   eval      wwPart = wwPath
     c                   eval      wwPath = *blanks
 X02 c                   else
     c                   eval      wwPart = %subst(wwPath:1:wwPos-1)
     c                   eval      wwPath = %subst(wwPath:wwPos+1)
 E02 c                   endif

 B02 c                   if        wwPart = *blanks
     c                   leave
 E02 c                   endif

     *************************************************
     * Split this part of the path into Obj & Extn.
     *  i.e. QRPGLESRC.FILE becomes QRPGLESRC and FILE
     *************************************************
     c                   eval      wwPos = 0
     c     ' '           checkr    wwPart        wwPartLen
 B02 c                   do        wwPartLen     X
 B03 c                   if        %subst(wwPart:X:1) = '.'
     c                   eval      wwPos = X
 E03 c                   endif
 E02 c                   enddo

 B02 c                   if        wwPos > 0 and wwPos < wwPartLen
     c                   eval      wwObj = %subst(wwPart:1:wwPos-1)
     c                   eval      wwExt = %subst(wwPart:wwPos+1)
 X02 c                   else
     c                   eval      wwObj = wwPart
     c                   eval      wwExt = *blanks
 E02 c                   endif

     *************************************************
     * Save appropriate pieces of the path
     *  if we're working with the QSYS.LIB filesystem
     *************************************************
 B02 c                   if        peFileSys = *blanks
     c                   eval      peFileSys = wwPart
     c     lower:upper   xlate     peFileSys     peFileSys
 E02 c                   endif

 B02 c                   if        peFileSys = 'QSYS.LIB'

     c     lower:upper   xlate     wwExt         wwExt
     c     lower:upper   xlate     wwObj         wwObj

 B03 c                   select
     c                   when      wwExt = 'LIB'
     c                   eval      peLibrary = wwObj
     c                   when      wwExt = 'MBR'
     c                   eval      peType = '*MBR'
     c                   eval      peMember = wwObj
     c                   when      wwExt = 'SAVF'
     c                   eval      peObject = wwObj
     c                   eval      peType = '*SAVF'
 X03 c                   other
     c                   eval      peObject = wwObj
     c                   eval      peType = '*' + wwExt
 E03 c                   endsl

 E02 c                   endif

 E01 c                   enddo

 B01 c                   if        peFileSys = 'QSYS.LIB'
     c                               and ( peLibrary=*blanks
     c                                  or peObject = *blanks)
     c                   callp     SetError(FTP_PRSERR:'Unable to parse ' +
     c                               'the lib/obj from QSYS.LIB pathname!')
     c                   return    -1
 E01 c                   endif

     c                   return    0
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This fixes the pathname to a file so that it'll contain the
     *   full, true pathname (not a symlink or relative pathname)
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P fixpath         B
     D fixpath         PI           256A
     D   pePath                     256A   const
     D   peObjType                   10A
     D   peCodePg                    10I 0

     D wwPath          S            257A
     D wwReal          S            256A
     D wwBuf           S           1024A
     D wwSymlink       S              1A   inz(*off)
     D wwPos           S              5I 0
     D wwErrMsg        S            256A
     D rc              S             10I 0

     c                   eval      wwPath = %trim(pePath)+x'00'
     c                   eval      p_statds = %addr(wwBuf)
     c                   eval      st_codepag = 37
     c                   eval      st_objtype = *blanks

     *************************************************
     * Resolve wwPath to a real link (not a symlink)
     *  and get the statds for it
     *************************************************
 B01 c                   dou       wwSymlink = *Off

     c                   eval      wwSymLink = *Off
 B02 c                   if        lstat(%addr(wwPath): p_statds) < 0
     c                   callp     geterror(wwErrMsg)
     c                   callp     SetError(FTP_LSTAT: wwErrMsg)
     c                   leave
 E02 c                   endif

 B02 c                   if        s_isLnk(st_mode) = *on
     c                   eval      rc = readlink(%addr(wwPath):
     c                                   %addr(wwReal): %size(wwReal))
 B03 c                   if        rc > 0
     c                   eval      wwSymLink = *On
     c                   eval      wwPath = %subst(wwReal:1:rc)+x'00'
 E03 c                   endif
 E02 c                   endif

 E01 c                   enddo

     *************************************************
     *  Is wwPath a relative path?  If so, add the
     *    current directory into it...
     *************************************************
 B01 c                   if        %subst(wwPath:1:1) <> '/'
     c                   eval      wwPath = %trimr(getdir) + wwPath
 E01 c                   endif

     *************************************************
     * Remove null terminator from pathname
     *************************************************
     c     x'00'         scan      wwPath        wwPos
 B01 c                   if        wwPos > 1
     c                   eval      wwPath = %subst(wwPath:1:wwPos-1)
 E01 c                   endif

     c                   eval      peObjType = st_objtype
     c                   eval      peCodePg = st_codepag

     c                   return    wwPath
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Get current working directory  (wrapper for getcwd)
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P getdir          B
     D getdir          PI           256A

     D wwRetVal        S            256A
     D wwPos           S              5I 0

 B01 c                   if        getcwd(%addr(wwRetVal): 256) = *NULL
     c                   return    './'
 E01 c                   endif

     c     x'00'         scan      wwRetVal      wwPos
 B01 c                   if        wwPos < 2
     c                   return    './'
 E01 c                   endif

     c                   eval      wwRetVal = %subst(wwRetVal:1:wwPos-1)
 B01 c                   if        %subst(wwRetVal:wwPos-1:1) <> '/'
     c                   eval      %subst(wwRetVal:wwPos:1) = '/'
 E01 c                   endif

     c                   return    wwRetVal
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  S_ISNATIVE -- this (comparatively inefficiently) emulates the
     *      C macro to determine if an object is a "native" object.
     *
     *     #define _S_IFNATIVE 0200000     /* AS/400 native object */
     *     #ifndef S_ISNATIVE
     *        #define S_ISNATIVE(m)  (((m) & 0370000) == _S_IFNATIVE)
     *     #endif
     *
     * Note that when IBM refers to a "native object" they seem to mean
     *   that the object won't work on any other operating system :)
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P S_ISNATIVE      B
     D S_ISNATIVE      PI             1A
     D    peMode                     10U 0 value

     D                 ds
     D  dsmode                 1      4U 0
     D  dsbyte1                1      1A
     D  dsbyte2                2      2A
     D  dsbyte3                3      3A
     D  dsbyte4                4      4A

     c                   move      peMode        dsMode
     c                   bitoff    x'FF'         dsbyte1
     c                   bitoff    x'FE'         dsbyte2
     c                   bitoff    x'0F'         dsbyte3
     c                   bitoff    x'FF'         dsbyte4

 B01 c                   if        dsmode = 65536
     c                   return    *on
 X01 c                   else
     c                   return    *off
 E01 c                   endif
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  S_ISLNK -- Is this a symbolic link?
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P S_ISLNK         B
     D S_ISLNK         PI             1A
     D    peMode                     10U 0 value

     D                 ds
     D  dsmode                 1      4U 0
     D  dsbyte1                1      1A
     D  dsbyte2                2      2A
     D  dsbyte3                3      3A
     D  dsbyte4                4      4A

     c                   move      peMode        dsMode
     c                   bitoff    x'FF'         dsbyte1
     c                   bitoff    x'FE'         dsbyte2
     c                   bitoff    x'0F'         dsbyte3
     c                   bitoff    x'FF'         dsbyte4

 B01 c                   if        dsmode = 40960
     c                   return    *on
 X01 c                   else
     c                   return    *off
 E01 c                   endif
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *   Execute OS/400 command
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P Cmd             B
     D Cmd             PI            10I 0
     D  peCommand                   200A   const
     D system          PR            10I 0 ExtProc('system')
     D   cmdptr                        *   value
     D wwCmd           S            201A
     D wwRC            S             10I 0
     c                   eval      wwCmd = %trim(peCommand)+x'00'
     c                   eval      wwRC = system(%addr(wwCmd))
 B01 c                   if        wwRC=1 or wwRC=-1
     c                   return    -1
 X01 c                   else
     c                   return    0
 E01 c                   endif
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This initializes the iconv() API for character conversion
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P InitIConv       B
     D InitIConv       PI            10I 0
     D    peFile                      1A   const

     ******************************************************
     * Initialize trans tables used to talk to server
     *    on the "control connection"
     ******************************************************
 B01 c                   if        peFile = *Off

     * Don't initialize more than once:
 B02 c                   if        wkXLInit = *ON
     c                   return    0
 E02 c                   endif

     * Initialize ASCII conv table:
     c                   eval      dsToASC = iconv_open(%addr(dsASCII):
     c                                                  %addr(dsEBCDIC))
 B02 c                   if        ICORV_A < 0
     c                   return    -1
 E02 c                   endif

     * Initialize EBCDIC conv table:
     c                   eval      dsToEBC = iconv_open(%addr(dsEBCDIC):
     c                                                  %addr(dsASCII))
 B02 c                   if        ICORV_E < 0
     c                   return    -1
 E02 c                   endif

     c                   eval      wkXLInit = *ON
     c                   return    0
 E01 c                   endif

     ******************************************************
     *  Initialize trans tables used to translate files
     ******************************************************
     * Don't initialize more than once:
 B01 c                   if        wkXLFInit = *ON
     c                   return    0
 E01 c                   endif

 B01 c                   if        ICORV_AF > -1
     c                   callp     iconv_clos(dsFileASC)
     c                   eval      ICORV_AF = -1
 E01 c                   endif
 B01 c                   if        ICORV_EF > -1
     c                   callp     iconv_clos(dsFileASC)
     c                   eval      ICORV_EF = -1
 E01 c                   endif

     * Initialize ASCII conv table:
     c                   eval      dsFileASC = iconv_open(%addr(dsASCIIF):
     c                                                  %addr(dsEBCDICF))
 B01 c                   if        ICORV_AF < 0
     c                   return    -1
 E01 c                   endif

     * Initialize EBCDIC conv table:
     c                   eval      dsFileEBC = iconv_open(%addr(dsEBCDICF):
     c                                                  %addr(dsASCIIF))
 B01 c                   if        ICORV_EF < 0
     c                   return    -1
 E01 c                   endif

     c                   eval      wkXLFInit = *ON
     c                   return    0
     c
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Translate a buffer from EBCDIC codepage 37 to ASCII 437
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P ToASCII         B
     D ToASCII         PI            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value
     D p_Buffer        S               *
 B01 c                   if        initiconv(*OFF) < 0
     c                   return     -1
 E01 c                   endif
     c                   eval      p_buffer = %addr(peBuffer)
     c                   return    iconv(dsToASC: %addr(p_buffer):peBufSize:
     c                                   %addr(p_buffer): peBufSize)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Translate a buffer from ASCII codepage 437 to EBCDIC 37
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P ToEBCDIC        B
     D ToEBCDIC        PI            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value
     D p_Buffer        S               *
 B01 c                   if        initiconv(*OFF) < 0
     c                   return     -1
 E01 c                   endif
     c                   eval      p_buffer = %addr(peBuffer)
     c                   return    iconv(dsToEBC: %addr(p_buffer):peBufSize:
     c                                   %addr(p_buffer): peBufSize)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Translate a buffer to ascii using options set by ftp_codepg
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P ToASCIIF        B
     D ToASCIIF        PI            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value
     D p_Buffer        S               *
 B01 c                   if        initiconv(*ON) < 0
     c                   return     -1
 E01 c                   endif
     c                   eval      p_buffer = %addr(peBuffer)
     c                   return    iconv(dsFileASC: %addr(p_buffer):
     c                               peBufSize:%addr(p_buffer): peBufSize)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Translate a buffer to ebcdic using options set by ftp_codepg
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P ToEBCDICF       B
     D ToEBCDICF       PI            10I 0
     D   peBuffer                 32766A   options(*varsize)
     D   peBufSize                   10U 0 value
     D p_Buffer        S               *
 B01 c                   if        initiconv(*ON) < 0
     c                   return     -1
 E01 c                   endif
     c                   eval      p_buffer = %addr(peBuffer)
     c                   return    iconv(dsFileEBC: %addr(p_buffer):
     c                              peBufSize: %addr(p_buffer): peBufSize)
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Set a File Descriptor in a set ON...  for use w/Select()
     *
     *      peFD = descriptor to set on
     *      peFDSet = descriptor set
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FD_SET          B                   EXPORT
     D FD_SET          PI
     D   peFD                        10I 0
     D   peFDSet                     28A
     D wkByteNo        S              5I 0
     D wkMask          S              1A
     D wkByte          S              1A
     C                   callp     CalcBitPos(peFD:wkByteNo:wkMask)
     c                   eval      wkByte = %subst(peFDSet:wkByteNo:1)
     c                   biton     wkMask        wkByte
     c                   eval      %subst(peFDSet:wkByteNo:1) = wkByte
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Set a File Descriptor in a set OFF...  for use w/Select()
     *
     *      peFD = descriptor to set off
     *      peFDSet = descriptor set
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FD_CLR          B                   EXPORT
     D FD_CLR          PI
     D   peFD                        10I 0
     D   peFDSet                     28A
     D wkByteNo        S              5I 0
     D wkMask          S              1A
     D wkByte          S              1A
     C                   callp     CalcBitPos(peFD:wkByteNo:wkMask)
     c                   eval      wkByte = %subst(peFDSet:wkByteNo:1)
     c                   bitoff    wkMask        wkByte
     c                   eval      %subst(peFDSet:wkByteNo:1) = wkByte
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Determine if a file desriptor is on or off...
     *
     *      peFD = descriptor to set off
     *      peFDSet = descriptor set
     *
     *   Returns *ON if its on, or *OFF if its off.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FD_ISSET        B                   EXPORT
     D FD_ISSET        PI             1A
     D   peFD                        10I 0
     D   peFDSet                     28A
     D wkByteNo        S              5I 0
     D wkMask          S              1A
     D wkByte          S              1A
     C                   callp     CalcBitPos(peFD:wkByteNo:wkMask)
     c                   eval      wkByte = %subst(peFDSet:wkByteNo:1)
     c                   testb     wkMask        wkByte                   88
     c                   return    *IN88
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Clear All descriptors in a set.  (also initializes at start)
     *
     *      peFDSet = descriptor set
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P FD_ZERO         B                   EXPORT
     D FD_ZERO         PI
     D   peFDSet                     28A
     C                   eval      peFDSet = *ALLx'00'
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  This is used by the FD_SET/FD_CLR/FD_ISSET procedures to
     *  determine which byte in the 28-char string to check,
     *  and a bitmask to check the individual bit...
     *
     *  peDescr = descriptor to check in the set.
     *  peByteNo = byte number (returned)
     *  peBitMask = bitmask to set on/off or test
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P CalcBitPos      B
     D CalcBitPos      PI
     D    peDescr                    10I 0
     D    peByteNo                    5I 0
     D    peBitMask                   1A
     D dsMakeMask      DS
     D   dsZeroByte            1      1A
     D   dsMask                2      2A
     D   dsBitMult             1      2U 0 INZ(0)
     C     peDescr       div       32            wkGroup           5 0
     C                   mvr                     wkByteNo          2 0
     C                   div       8             wkByteNo          2 0
     C                   mvr                     wkBitNo           2 0
     C                   eval      wkByteNo = 4 - wkByteNo
     c                   eval      peByteNo = (wkGroup * 4) + wkByteNo
     c                   eval      dsBitMult = 2 ** wkBitNo
     c                   eval      dsZeroByte = x'00'
     c                   eval      peBitMask = dsMask
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  tsend:  send data with timeout (wrapper around send() API)
     *
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P tsend           B
     D tsend           PI            10I 0
     D   peFD                        10I 0 value
     D   peData                        *   value
     D   peLen                       10I 0 value
     D   peFlags                     10I 0 value

     D wwSent          S             10I 0
     D wwTO            S              8A
     D wwSet           S             28A
     D p_data          S               *
     D wwRC            S             10I 0

     c                   eval      wwSent = 0

 B01 c                   dow       wwSent < peLen

     c                   eval      p_data = OffsetPtr(peData: wwSent)

 B02 c                   if        wkTimeout > 0
     c                   eval      p_timeval = %addr(wwTO)
     c                   eval      tv_sec = wkTimeout
     c                   eval      tv_usec = 0
 X02 c                   else
     c                   eval      p_timeval = *NULL
 E02 c                   endif

     c                   callp     FD_ZERO(wwSet)
     c                   callp     FD_SET(peFD: wwSet)
     c                   callp     select(peFD+1: *NULL: %addr(wwSet):
     c                                     *NULL: p_timeval)

 B02 c                   if        FD_ISSET(peFD: wwSet) = *OFF
     c                   callp     SetError(FTP_TIMOUT: 'Connection timed '+
     c                              'out while sending data')
     c                   return    -1
 E02 c                   endif

     c                   eval      wwRC = send(peFD:p_data:peLen:peFlags)
 B02 c                   if        wwRC < 1
     c                   return    -1
 E02 c                   endif

     c                   eval      peLen = peLen - wwRC
     c                   eval      wwSent = wwSent + wwRC

 E01 c                   enddo

     c                   return    wwSent
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  rtvJobCp  retrieve job codepage
     *
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P rtvJobCp        B
     D rtvJobCp        PI            10I 0

     D wwIntJobID      S             16A   inz
     D dsQJob          DS
     D   dsQ_Job                     10A   inz('*')
     D   dsQ_User                    10A   inz
     D   dsQ_Nbr                      6A   inz
     D dsJobi0400      DS
     D   dsBytRet              1      4I 0 inz
     D   dsBytAvl              5      8I 0 inz
     D   dsJob                 9     18A   inz
     D   dsName               19     28A   inz
     D   dsNbr                29     34A   inz
     D   dsCcsid             373    376I 0 inz

     c                   Callp     qusrjobi(dsJobi0400        :
     c                                      %size(dsJobi0400) :
     c                                      'JOBI0400'        :
     c                                      dsQJob            :
     c                                      wwIntJobID        )

     c                   return    dsCcsid
    P                 E

     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  lclFileSiz  determine the local file size
     *
     *  pePath  = path to local file
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P lclFileSiz      B
     D lclFileSiz      PI            16P 0
     D   pePath                     256A   const

     D wwPath          S            256A
     D wwBuf           S           1024A
     D wwType          S             10A
     D wwCP            S             10I 0

     c                   eval      wwPath = fixpath(pePath: wwType: wwCP)
     c                   eval      wwPath = %trimr(wwPath) + x'00'

     c                   eval      p_statds = %addr(wwBuf)

 B01 c                   if        lstat(%addr(wwPath): p_statds) < 0
     c                   return    0
 E01 c                   endif

     c                   return    st_size
    P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  GetTrimLen  determine the length of a record if trimmed
     *
      *     peBuffer = record to calc trimmed len of
      *     peRecEnd = ending position of record
      *
      *  Returns the record length.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P GetTrimLen      B
     D GetTrimLen      PI            16P 0
     D   peBuffer                 32766A   options(*varsize)
     D   peRecEnd                    10I 0 value

     D X               S             10I 0

     c                   eval      X = peRecEnd

     c                   dow       %subst(peBuffer:x:1)=' ' and X>1
     c                   eval      X = X -1
     c                   enddo

     c                   return    X
     P                 E


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * Return a pointer at a specified offset value from another ptr
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P OffsetPtr       B
     D OffsetPtr       PI              *
     D   pePointer                     *   Value
     D   peOffset                    10I 0 Value

     D p_NewPtr        S               *
     D wkMove          S              1A   DIM(4097) BASED(p_NewPtr)

     c                   eval      p_NewPtr = pePointer

 B01 c                   if        peOffset > 0

 B02 C                   dow       peOffset > 4096
     C                   eval      p_NewPtr = %addr(wkMove(4097))
     c                   eval      peOffset = peOffset - 4096
 E02 c                   enddo

     C                   eval      p_NewPtr = %addr(wkMove(peOffset+1))

 E01 c                   endif

     c                   return    p_NewPtr
    P                 E
