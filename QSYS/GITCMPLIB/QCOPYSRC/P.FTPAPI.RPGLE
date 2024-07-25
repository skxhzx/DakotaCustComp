
     *----------------------------------------------------------------
     * Begin P.FTPAPI - Prototypes for FTP API functions
     *
     *   07/20/04  DAS  4.17
     *     - Created
     *     - Revered Remote and Local parameters for ftp_put.
     *
     *----------------------------------------------------------------

     *-
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
      *    -- Added the FTP_ASC_CP and FTP_EBC_CP constants.
     *
     * This file contains constants and prototypes necessary for calling
     * routines in the FTPAPI service program.
     *

     **********************************************************************
     *  Exit Points for ftp_xproc()
     **********************************************************************
     D FTP_EXTLOG      C                   CONST(1)
     D FTP_EXTSTS      C                   CONST(2)

     * Default port for FTP control connections:
     D FTP_PORT        C                   CONST(21)

     **********************************************************************
     *  Code pages for FTP_codepg()
     **********************************************************************
     ** Default remote codepage of FTP command (ASCII codepage)
     D FTP_ASC_CP      C                   CONST(00819)
     ** Default local codepage  of FTP command (EBCDIC codepage)
     D FTP_EBC_CP      C                   CONST(-1)

     **********************************************************************
     *  These constants correspond to error messages that can be returned
     **********************************************************************
     * write procedure returned an error while doing a GET ASCII
     D FTP_GETAWR      C                   CONST(1)
     * write procedure returned an error while doing a GET BINARY
     D FTP_GETBWR      C                   CONST(2)
     * send procedure returned an error while doing a PUT
     D FTP_PUTBSD      C                   CONST(3)
     * Bad IP address / Host Not found
     D FTP_BADIP       C                   CONST(4)
     * Invalid Login Password (or name?)
     D FTP_BADPAS      C                   CONST(5)
     * Invalid response from FTP server
     D FTP_BADRES      C                   CONST(6)
     * Invalid response to FTP RETR (get) command
     D FTP_BADRTR      C                   CONST(7)
     * Invalid response to FTP STOR (put) command
     D FTP_BADSTO      C                   CONST(8)
     * Invalid user name
     D FTP_BADUSR      C                   CONST(9)
     * Connection dropped
     D FTP_DISCON      C                   CONST(10)
     * Error accepting data connection
     D FTP_DTAACC      C                   CONST(11)
     * Error binding data connection
     D FTP_ERRBND      C                   CONST(12)
     * Error connecting to host (can be control or data)
     D FTP_ERRCON      C                   CONST(13)
     * Error changing working directory
     D FTP_ERRCWD      C                   CONST(14)
     * Error creating a new socket
     D FTP_ERRSKT      C                   CONST(15)
     * Error setting file transfer type
     D FTP_ERRTYP      C                   CONST(16)
     * Error getting local port number
     D FTP_GETPRT      C                   CONST(17)
     * Error getting IP address for local interface
     D FTP_GETSNM      C                   CONST(18)
     * Unable to listen to port
     D FTP_LSTERR      C                   CONST(19)
     * Server does not properly understand passive mode
     D FTP_PASERR      C                   CONST(20)
     * Unable to find connection details in passive response
     D FTP_PASRPY      C                   CONST(21)
     * Invalid Setting (must be *ON or *OFF)
     D FTP_PESETT      C                   CONST(22)
     * Server didnt like the "PORT" command we sent
     D FTP_PRTERR      C                   CONST(23)
     * Unable to build the PORT string (probably an internal error)
     D FTP_PRTSTR      C                   CONST(24)
     * FTP server returned an invalid starting response
     D FTP_STRRES      C                   CONST(25)
     * File transfer did not complete normally.
     D FTP_XFRERR      C                   CONST(26)
     * Unable to open the local file...
     D FTP_OPNERR      C                   CONST(27)
     * Bad response to LIST command...
     D FTP_BADLST      C                   CONST(28)
     * No such file or directory....
     D FTP_NOFILE      C                   CONST(29)
     * Bad response to NLST command...
     D FTP_BADNLS      C                   CONST(30)
     * Invalid "rename-from" name or file not found
     D FTP_RNFERR      C                   const(31)
     * Invalid "rename-to" name or file exists
     D FTP_RNTERR      C                   const(32)
     * Unable to delete file
     D FTP_DELERR      C                   const(33)
     * Unable to remove directory
     D FTP_RMDERR      C                   const(34)
     * Unable to create directory
     D FTP_MKDERR      C                   const(35)
     * Unable to get current working dir
     D FTP_PWDERR      C                   const(36)
     * Unable to parse response to PWD command
     D FTP_DIRPRS      C                   const(37)
     * Unable to retrieve file size
     D FTP_SIZERR      C                   const(38)
     * Unable to parse file size response
     D FTP_SIZPRS      C                   const(39)
     * Unable to retroeve modification time
     D FTP_MODERR      C                   const(40)
     * Unable to parse modification time
     D FTP_MODPRS      C                   const(41)
     * Unable to add physical file member
     D FTP_ADMERR      C                   const(42)
     * Unable to add variable len PF member
     D FTP_ADVERR      C                   const(43)
     * Unable create library
     D FTP_CRLERR      C                   const(44)
     * Unable create physical file
     D FTP_CRPERR      C                   const(45)
     * Unable create source physical file
     D FTP_CRSERR      C                   const(46)
     * Unable delete file
     D FTP_DLFERR      C                   const(47)
     * Unable delete library
     D FTP_DLLERR      C                   const(48)
     * Remote Command has failed.
     D FTP_RCMERR      C                   const(49)
     * Unable to set new name format.
     D FTP_NMFERR      C                   const(50)
     * No command was supplied to be run
     D FTP_NOCMD       C                   const(51)
     * Text of QUOTE Reply Message
     D FTP_QTEMSG      C                   const(52)
     * SAVF must be transferred in BINARY mode
     D FTP_SAVBIN      C                   const(53)
     * Source members must be transferred in ASCII mode
     D FTP_SRCASC      C                   const(54)
     * You can't transfer files of that type!
     D FTP_INVFIL      C                   const(55)
     * User spaces need BINARY mode
     D FTP_USPBIN      C                   const(56)
     * Can't transfer an object of that type
     D FTP_INVOBJ      C                   const(57)
     * Unable to build a save file to receive data into
     D FTP_BLDSAV      C                   const(58)
     * Unable to build a physical file to receive data into
     D FTP_BLDPF       C                   const(59)
     * Unable to add a new member onto that file
     D FTP_ADPFER      C                   const(60)
     * ROPEN failed for that file (reading)
     D FTP_ROPENR      C                   const(61)
     * ROPEN failed for that file (writing)
     D FTP_ROPENW      C                   const(62)
     * UNKNOWN/programmer error
     D FTP_UNKNWN      C                   const(63)
     * Unable to read the object description
     D FTP_RTVOBJ      C                   const(64)
     * Unable to read the member description
     D FTP_RTVMBR      C                   const(65)
     * Error parsing IFS path
     D FTP_PRSERR      C                   const(66)
     * Error returned by lstat
     D FTP_LSTAT       C                   const(67)
     * Invalid Exit Point
     D FTP_BADPNT      C                   const(68)
     * Unable to clear existing save file
     D FTP_CLRSAV      C                   const(69)
     * Invalid response to FTP APPE (append) command
     D FTP_BADAPP      C                   CONST(70)
     * Time-out occurred
     D FTP_TIMOUT      C                   CONST(71)
     * Server did not like the account we sent to it
     D FTP_BADACT      C                   CONST(72)


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
     D FTP_Conn        PR            10I 0
     D   peHost                     256A   const
     D   peUser                      32A   const
     D   pePass                      64A   const
     D   pePort                      10I 0 value options(*nopass)
     D   peTimeout                   10I 0 value options(*nopass)
     D   peAcct                      32A   const options(*nopass)


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Change directory on remote FTP server
     *
     *       input:   peSock = descriptor returned by ftp_conn
     *              peNewDir = directory to change to.
     *
     *  returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_chdir       PR            10I 0
     D   peSock                      10I 0 value
     D   peNewDir                   256A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_binary:  Set file transfer mode to/from binary mode
     *
     *    peSetting = Setting of binary  *ON = Turn binary mode on
     *                                  *OFF = Turn binary mode off.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_binary      PR            10I 0
     D   peSetting                    1A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_LinMod:  Allows file transfer of a text file in line
     *                   at a time mode.
     *
     *    peSetting = Setting of line mode  *ON = Turn line mode on
     *                                     *OFF = Turn line mode off.
     *
     *  Line-At-A-Time mode is only allowed on text files.  When
     *  using line mode, each string returned will be one line of
     *  text from the file.  The text will automatically be converted
     *  from ASCII -> EBCDIC, and any CR or LF characters will be
     *  stripped from the record.
     *
     *  Line mode is MUCH slower than normal("block") mode, and should
     *  only be used if the contents are the file are to be examined
     *  line-by-line as the data is being downloaded.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_LinMod      PR            10I 0
     D   peSetting                    1A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_passiv:   Turn passive mode transfers on or off
     *
     *     peSetting = passive mode setting.   *ON = Turn passive on
     *                                        *OFF = Turn passive off
     *
     *     Returns -1 upon error, or 0 upon success.
     *
     * Note that this does not detect if the server supports
     *    passive mode.  That will be done when the file transfer
     *    commences...
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_passiv      PR            10I 0
     D   peSetting                    1A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_log:  Turn on/off logging of session to joblog
     *
     *    peSetting = Setting of logging *ON = Turn logging mode on
     *                                  *OFF = Turn logging mode off.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_Log         PR            10I 0
     D   peSetting                    1A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_rename:   Rename a file on an FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *    peOldName = Original File Name
     *    peNewName = New name to assign.
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_rename      PR            10I 0
     D   peSocket                    10I 0 value
     D   peOldName                  256A   const
     D   peNewName                  256A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_delete:   Delete a file on the FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *       peFile = File to delete
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_delete      PR            10I 0
     D   peSocket                    10I 0 value
     D   peFile                     256A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_rmdir:  Delete a directory from an FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *    peDirName = directory to delete
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_rmdir       PR            10I 0
     D   peSocket                    10I 0 value
     D   peDirName                  256A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_mkdir:  Create a directory on the FTP server
     *
     *     peSocket = socket number returned by FTP_conn
     *    peDirName = directory to create
     *
     *     Returns -1 upon error, or 0 upon success.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_mkdir       PR            10I 0
     D   peSocket                    10I 0 value
     D   peDirName                  256A   const


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  FTP_rtvcwd:  Retrieve the current working directory name
     *         from the server.
     *
     *     peSocket = socket number returned by FTP_conn
     *
     *     Returns the directory name, or *BLANKS upon failure
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_rtvcwd      PR           256A
     D   peSocket                    10I 0 value


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
     *  for this response will always be FTP_QUOTE
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_quote       PR            10I 0
     D   peSocket                    10I 0 value
     D   peCommand                  256A   const


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
     D FTP_size        PR            16P 0
     D   peSocket                    10I 0 value
     D   peFile                     256A   const


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
     D FTP_mtime       PR            16P 0
     D   peSocket                    10I 0 value
     D   peFile                     256A   const
     D   peModTime                     Z


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
     D FTP_AddPfm      PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_AddPvm      PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_CrtLib      PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_CrtPF       PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_CrtSrc      PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_DltF        PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_DltLib      PR            16P 0
     D   peSocket                    10I 0 value
     D   peParms                    256A   const


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
     D FTP_RmtCmd      PR            16P 0
     D   peSocket                    10I 0 value
     D   peCommand                 1000A   const


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
     D FTP_NamFmt      PR            16P 0
     D   peSocket                    10I 0 value
     D   peFormat                     5I 0 value


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
     D FTP_dir         PR            10I 0
     D   peSock                      10I 0 value
     D   pePathArg                  256A   const
     D   peMaxEntry                  10I 0 value
     D   peRtnList                     *   value
     D   peRtnSize                   10I 0


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
     D FTP_dirraw      PR            10I 0
     D   peSock                      10I 0 value
     D   pePathArg                  256A   const
     D   peDescr                     10I 0 value
     D   peFunction                    *   PROCPTR value


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
     D FTP_list        PR            10I 0
     D   peSock                      10I 0 value
     D   pePathArg                  256A   const
     D   peMaxEntry                  10I 0 value
     D   peRtnList                     *   value
     D   peRtnSize                   10I 0


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
     D FTP_lstraw      PR            10I 0
     D   peSock                      10I 0 value
     D   pePathArg                  256A   const
     D   peDescr                     10I 0 value
     D   peFunction                    *   PROCPTR value


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
     D FTP_get         PR            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peLocal                    256A   const options(*nopass)


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
     D FTP_getraw      PR            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peDescr                     10I 0 value
     D   peWrtProc                     *   PROCPTR value


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
     D FTP_put         PR            10I 0
     D   peSocket                    10I 0 value
417 MD   peLocal                    256A   const
417 MD   peRemote                   256A   const options(*nopass)
417 DD** peRemote                   256A   const
417 DD** peLocal                    256A   const options(*nopass)


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
     D FTP_putraw      PR            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peDescr                     10I 0 value
     D   peReadProc                    *   PROCPTR value


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
     D FTP_append      PR            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peLocal                    256A   const options(*nopass)


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
     D FTP_appraw      PR            10I 0
     D   peSocket                    10I 0 value
     D   peRemote                   256A   const
     D   peDescr                     10I 0 value
     D   peReadProc                    *   PROCPTR value


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     * FTP_quit:
     *        parms:   peSocket = descriptor returned by ftp_conn
     *
     *  This procedure logs off of the FTP server and closes
     *  the network connection.
     *
     *  Returns:  nothing.  "Always succeeds"
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_quit        PR
     D   peSocket                    10I 0 value


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  returns the error message that occurred when one of the
     *  above routines return -1.
     *
     *  optionally also returns the error number, which will
     *  match one of the constants defined in FTPAPI_H.  This
     *  can be used by programs to anticipate/handle errors.
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_error       PR            60A
     D   peErrorNum                  10I 0 options(*nopass)


     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     *  Set file translation options for ASCII mode:
     *
     *     peASCII -- codepage to use when translating to/from ASCII
     *     peEBCDIC -- codepage to use when translating to/from EBCDIC
     *
     *  Return 0 for success, -1 upon error
     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D FTP_codepg      PR            10I 0
     D   peASCII                     10I 0 value
     D   peEBCDIC                    10I 0 value


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
     D FTP_xproc       PR            10I 0
     D   peExitPnt                   10I 0 value
     D   peProc                        *   procptr value


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
     D FTP_trim        PR            10I 0
     D   peSetting                    1A   const

     *** End P.FTPAPI ***
