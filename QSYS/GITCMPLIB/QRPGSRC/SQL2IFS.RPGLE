     h dftactgrp(*no)  actgrp(*CALLER)  bnddir('QC2LE')
     H option(*srcstmt : *nodebugio)

      **********************************************************************
      ** SQL2IFS - Write a space into an IFS document
      **********************************************************************
     D EntryParms      PR                  extpgm('SQL2IFS')
     D  pSPCNAME                       *
     D  pSPCLNG                      10I 0
     D  pDOCUMENT                    63A
     D  pMODE                         8A
     D EntryParms      PI
     D  pSPCNAME                       *
     D  pSPCLNG                      10I 0
     D  pDOCUMENT                    63A
     D  pMODE                         8A

      **********************************************************************
      * /COPY - IFS prototypes
      **********************************************************************
      *---------------------------------------------------------------------
      * Open() - Open File API
      *---------------------------------------------------------------------
      * int open(const char *path, int oflag, . . .);
     D open            PR            10I 0 ExtProc('open')
     D  pathp                          *   Value options(*String)
     D  oflag                        10I 0 Value
     D  mode                         10U 0 Value Options(*nopass)
     D  codepage                     10U 0 Value Options(*nopass)

      *---------------------------------------------------------------------
      * read() -- Read from Descriptor
      *---------------------------------------------------------------------
      *  ssize_t read(int file_descriptor,
      *               void *buf, size_t nbyte);
     D read            PR            10I 0 Extproc('read')
     D  FileDescI                    10I 0 Value
     D  bufferIp                       *   Value
     D  nbyte                        10U 0 Value

      *---------------------------------------------------------------------
      * write() -- Write to Descriptor
      *---------------------------------------------------------------------
      *  ssize_t write
      *  (int file_descriptor, const void *buf, size_t nbyte);
     D write           PR            10I 0 Extproc('write')
     D  FileDescO                    10I 0 Value
     D  bufferOp                       *   Value
     D  nbyte                        10U 0 Value

      *---------------------------------------------------------------------
      * close() -- Close File or Socket Descriptor
      *---------------------------------------------------------------------
      *  int close(int fildes);
     D close           PR            10I 0 Extproc('close')
     D  FileDesc                     10I 0 Value

      *---------------------------------------------------------------------
      * lseek()--Set File Read/Write Offset
      *---------------------------------------------------------------------
      *  off_t lseek(int file_descriptor, off_t offset, int whence);
     D lseek           PR            10I 0 Extproc('lseek')
     D  filedesc                     10I 0 Value
     D  offset                       10I 0 Value
     D  whence                       10I 0 Value


      *---------------------------------------------------------------------
      *     File Access Modes                                             */
      *---------------------------------------------------------------------
      *#define O_RDONLY   00001        /* Open for reading only           */
     D O_RDONLY        S             10I 0 INZ(x'01')
      *#define O_WRONLY   00002        /* Open for writing only           */
     D O_WRONLY        S             10I 0 INZ(x'02')
      *#define O_RDWR     00004        /* Open for reading and writing    */
     D O_RDWR          S             10I 0 INZ(x'04')
      *#define O_CREAT      00010      /* Create file if it doesn't exist */
     D O_CREATE        S             10I 0 INZ(x'08')
      *#define O_EXCL       00020      /* Exclusive use flag              */
     D O_EXCL          S             10I 0 INZ(x'10')
      */*                   00040         reserved                        */
      *#define O_TRUNC      00100      /* Truncate flag                   */
     D O_TRUNC         S             10I 0 INZ(x'40')

      *---------------------------------------------------------------------
      *     File Status Flags                                             */
      *---------------------------------------------------------------------
      *#define O_CODEPAGE   040000000  /* code page flag                  */
     D O_CODEPAGE      S             10I 0 INZ(x'800000')
      *#define O_TEXTDATA  0100000000  /* text data flag                  */
     D O_TEXTDATA      S             10I 0 INZ(x'01000000')
      *#define O_APPEND     00400      /* Set append mode                 */
     D O_APPEND        S             10I 0 INZ(x'0100')
      *#define O_LARGEFILE  004000000000  /* Large file access            */
     D O_LARGEFILE     S             10I 0 INZ(x'20000000')
      *#define O_INHERITMODE 001000000000 /* inherit mode flag            */
     D O_INHERITMODE   S             10I 0 INZ(x'08000000')

      *---------------------------------------------------------------------
      *     Share Mode Values                                             */
      *---------------------------------------------------------------------
      *#define O_SHARE_RDONLY 000000200000 /* Share with readers only     */
     D O_SHARE_RDONLY  S             10I 0 INZ(x'010000')
      *#define O_SHARE_WRONLY 000000400000 /* Share with writers only     */
     D O_SHARE_WRONLY  S             10I 0 INZ(x'020000')
      *#define O_SHARE_RDWR   000001000000 /* Share with readers and
      *                                       writers                     */
     D O_SHARE_RDWR    S             10I 0 INZ(x'040000')
      *#define O_SHARE_NONE   000002000000 /* Share with neither readers
      *                                       nor writers                 */
     D O_SHARE_NONE    S             10I 0 INZ(x'080000')

      *---------------------------------------------------------------------*/
      *   Definitions of File Modes and File Types                          */
      *---------------------------------------------------------------------*/
      *   #define S_IRUSR 0000400    /* Read for owner                      */
     D S_IRUSR         S             10I 0 INZ(x'0100')
      *   #define S_IWUSR 0000200    /* Write for owner                     */
     D S_IWUSR         S             10I 0 INZ(x'80')
      *   #define S_IXUSR 0000100    /* Execute and Search for owner        */
     D S_IXUSR         S             10I 0 INZ(x'40')
      *   #define S_IRWXU (S_IRUSR|S_IWUSR|S_IXUSR)  /* Read, Write,
      *                                                 Execute for owner   */
     D S_IRWXU         S             10I 0 INZ(x'01C0')

      *   #define S_IRGRP 0000040         /* Read for group                 */
     D S_IRGRP         S             10I 0 INZ(x'20')
      *   #define S_IWGRP 0000020         /* Write for group                */
     D S_IWGRP         S             10I 0 INZ(x'10')
      *   #define S_IXGRP 0000010         /* Execute and Search for group   */
     D S_IXGRP         S             10I 0 INZ(x'08')
      *   #define S_IRWXG (S_IRGRP|S_IWGRP|S_IXGRP)  /* Read, Write,
      *                                                 Execute for group   */
     D S_IRWXG         S             10I 0 INZ(x'38')

      *   #define S_IROTH 0000004         /* Read for other                 */
     D S_IROTH         S             10I 0 INZ(x'04')
      *   #define S_IWOTH 0000002         /* Write for other                */
     D S_IWOTH         S             10I 0 INZ(x'02')
      *   #define S_IXOTH 0000001         /* Execute and Search for other   */
     D S_IXOTH         S             10I 0 INZ(x'01')
      *   #define S_IRWXO (S_IROTH|S_IWOTH|S_IXOTH)  /* Read, Write,
      *                                                 Execute for other   */
     D S_IRWXO         S             10I 0 INZ(x'07')

      *---------------------------------------------------------------------
      *     Constants for lseek()                                         */
      *---------------------------------------------------------------------
      *   #define SEEK_SET    0        /* Seek to given position          */
     D SEEK_SET        C                   0
      *   #define SEEK_CUR    1        /* Seek relative to current
      *                                   position                        */
     D SEEK_CUR        C                   1
      *   #define SEEK_END    2        /* Seek relative to end of file    */
     D SEEK_END        C                   2

      * /COPY - IFS prototypes - end ***************************************

      **********************************************************************
      * /COPY - iconv prototypes
      **********************************************************************
      *-- QTQICONV -- Codeset conversion ------------------------------
     D l_QtqCode       ds
     D   l_CCSID                      9b 0
     D   l_cnv_alter                  9b 0
     D  l_subs_alter                  9b 0
     D   l_sh_alter                   9b 0
     D   l_length_opt                 9b 0
     D   l_mx_err_opt                 9b 0
     D   l_reserved                   8a
     D r_QtqCode       ds
     D   r_CCSID                      9b 0
     D   r_cnv_alter                  9b 0
     D   r_subs_alter                 9b 0
     D   r_sh_alter                   9b 0
     D   r_length_opt                 9b 0
     D   r_mx_err_opt                 9b 0
     D   r_reserved                   8a

      *================================================================
      *   S u b p r o c e d u r e   p r o t o t y p e s
      *================================================================

      *-- QtqIconvOpen --- Open conversion ----------------------------
      *   iconv_t QtqIconvOpen(QtqCode_T *tocode,
      *                        QtqCode_T *fromcode);
     D QtqIconvOpen    Pr            52    Extproc('QtqIconvOpen')
     D                                 *   value
     D                                 *   value

      *-- iconv --- Code conversion API -------------------------------
      *   size_t  iconv(iconv_t cd,
      *                 char   **inbuf,
      *                 size_t *inbytesleft,
      *                 char   **outbuf,
      *                 size_t *outbytesleft);
     D Iconv           Pr            10u 0 Extproc('iconv')
     D                               52    Value
     D                                 *   Value
     D                                 *   Value
     D                                 *   Value
     D                                 *   Value

      *-- iconv_close --- close conversion ----------------------------
      *   int     iconv_close (iconv_t cd);
     D IconvClose      Pr            10i 0 Extproc('iconv_close')
     D                               52    value

      **--------------------------------------------------------------------
      ** CCSID structures
      **--------------------------------------------------------------------
      ** ... local ccsid
     D size_t          s             10u 0
     D l_QtqCodep      s               *   inz(%addr(l_QtqCode))
     D l2rcd           ds
     D  l2r_rc                       10i 0
     D  l2r_cd                       10i 0 dim(12)
     D l_bufferp       s               *
     D l_buffersz      s             10u 0
     D l_bufferszp     s               *   inz(%addr(l_buffersz))
      ** ... remote ccsid
     D r_QtqCodep      s               *   inz(%addr(r_QtqCode))
     D r2lcd           ds
     D  r2l_rc                       10i 0
     D  r2l_cd                       10i 0 dim(12)
     D r_bufferp       s               *
     D r_buffersz      s             10u 0
     D r_bufferszp     s               *   inz(%addr(r_buffersz))

      * /COPY - iconv prototypes - end *************************************

      **********************************************************************
      * Local variables
      **********************************************************************
     d output          S             64A
     d oflag           S             10I 0 Inz(0)
     d mode            S             10U 0 Inz(0)
     d codepage        S             10U 0 Inz(0)
     d Rc              S             10I 0 Inz(0)
     d FD              S             10I 0 Inz(0)
     D ccsid           s             10I 0 inz(819)
     D sSPCNAME        s               *

      **********************************************************************
      * Error Handler
      **********************************************************************
     D ErrorHdlr       Pr
     D  DumpText                     12A   Value

      /free

       // initialize conversion
       clear l_QtqCode;
       l_ccsid = 0;
       l_reserved = *allx'00';
       clear r_QtqCode;
       r_ccsid = ccsid;
       r_reserved = *allx'00';
       l2rcd = QtqIconvOpen(r_QtqCodep: l_QtqCodep);
       If l2r_rc < 0;
         ErrorHdlr('IconvOpen');
       endif;
       r2lcd = QtqIconvOpen(l_QtqCodep: r_QtqCodep);
       If r2l_rc < 0;
         ErrorHdlr('IconvOpen');
       endif;

       // convert to ascii
       sSPCNAME = pSPCNAME;
       l_bufferp = %addr(pSPCNAME);
       l_buffersz = pSPCLNG;
       r_bufferp = l_bufferp;
       r_buffersz = pSPCLNG;
       size_t = Iconv(l2rcd:
                      l_bufferp: l_bufferszp:
                      r_bufferp: r_bufferszp);
       If size_t <> 0;
         ErrorHdlr('Iconv');
       endif;
       pSPCNAME = sSPCNAME;

       // close conversion
       rc = IconvClose(r2lcd);
       If rc < 0;
         ErrorHdlr('IconvClose');
       endif;
       rc = IconvClose(l2rcd);
       If rc < 0;
         ErrorHdlr('IconvClose');
       endif;

       // set document name
       output = %trim(pDOCUMENT) + x'00';

       // set flags
       if pMODE = '*REPLACE';
         oflag = O_CREATE + O_WRONLY + O_TRUNC;
       else;
         oflag = O_CREATE + O_WRONLY;
       endif;

       mode  = S_IRWXU + S_IRWXG + S_IROTH + S_IXOTH;

       // open/create stream file
       FD = open(%trimr(output): oflag : mode : codepage);
       if FD = -1;
         ErrorHdlr('OpenOut');
         return;
       endif;

       if pMODE = '*ADD';
         rc = lseek(FD: 0: SEEK_END);
       endif;

       // write document
       rc = write(FD: pSPCNAME: pSPCLNG);

       // close stream file
       rc = close(FD);

       // close function
       *inlr = *on;

      /end-free

      **********************************************************************
      * /COPY - Error handler
      **********************************************************************
     pErrorHdlr        B
     d*   Error handling subprocedure prototype
     d ErrorHdlr       Pr
     d DumpText                      12    Value
     d*   Error handling subprocedure interface
     d ErrorHdlr       PI
     d DumpText                      12    Value

      **********************************************************************
      * /COPY - QMHSNDPM - send program messages
      **********************************************************************
     D QMHSNDPM        PR                  extpgm('QMHSNDPM')
     D  MessageId                     7    const
     D  MessageFile                  20    const
     D  MessageData                 512    const options(*varsize)
     D  MessageDataL                  9b 0 const
     D  MessageType                  10    const
     D  CallStkEntry                128    const options(*varsize)
     D  CallStkCount                  9b 0 const
     D  MessageKey                    4    const
     D  ApiError                    120    options(*varsize)
      * /COPY - QMHSNDPM - send program messages - end *********************

      **********************************************************************
      * /COPY - Api error structure
      **********************************************************************
     D ApiError        ds
     D  ApiErrLP                      9b 0 inz(%len(Apierror))
     D  ApiErrLA                      9b 0 inz(0)
     D  ApiErrMsg                     7
     D                                1
     D  ApiErrDta                   104
      * /COPY - Api error structure - end **********************************

      *-- GetErrNo ---- Get error number ------------------------------
      *   extern int * __errno(void);
     D GetErrNo        Pr              *   ExtProc('__errno')
      *-- StrError ---- Get error text --------------------------------
      *   char *strerror(int errnum);
     D StrError        Pr              *   ExtProc('strerror')
     D                               10I 0 Value
      *-- Error number information ------------------------------------
     d ErrNo           S             10I 0 Based(ErrNop)
     d ErrNop          S               *   Inz
     d ErrMsg          S             60A   Based(ErrMsgp)
     d ErrMsgp         S               *   Inz

      /free
       ErrNop = GetErrNo;
       ErrMsgp = StrError(ErrNo);
       ApiErrDta = %trimr(Dumptext) + '-' + %trim(%char(ErrNo)) + '-' +
                   %str(ErrMsgp);
       QMHSNDPM ('CPF9898':'QCPFMSG   QSYS      ':ApiErrDta:
                  %len(%trim(ApiErrDta)):'*ESCAPE':'*CTLBDY':1:'    ':
                  ApiError);
      /end-free

     pErrorHdlr        E

