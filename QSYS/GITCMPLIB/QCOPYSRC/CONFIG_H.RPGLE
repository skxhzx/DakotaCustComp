     ***  If you do not want SSL support, comment out the line below.
     ***   (You _must_ do this if you're running V4R4 or earlier)

     D/define HAVE_SSLAPI

     ***  define this if your RPG compiler supports 64-bit integers
     ***  (they were introduced in V4R4)
     ***

     D/define HAVE_INT64

     ***  define this if your RPG compiler supports
     ***  options(*SRCSTMT: *NODEBUGIO: *NOSHOWCPY)
     ***  (they were introduced in V4R4, but can be enabled as far
     ***   back as V3R2 using PTFs)

     D/define HAVE_SRCSTMT_NODEBUGIO

     ***  In V4R5 it's possible to enable GSKit for SSL via
     ***    PTFs. However, some functionality wasn't yet available
     ***    in that release. Define this if you need SSL to be limited
     ***    to what's available on a V4R5 system. (This is ignored
     ***    when SSL is disabled.)

     D/undefine V4R5_GSKIT

     ***  This is the default timeout value (in seconds) that HTTPAPI
     ***  uses if a timeout value isn't specified by the calling
     ***  program:

     D HTTP_TIMEOUT    C                   CONST(60)

     ***  This is the 'User-Agent' name that is reported by this API
     ***  to the web servers if you don't specify it explcitly when
     ***  calling the routines.

     D HTTP_USERAGENT  C                   CONST('http-api/1.23')

     ***  This is the 'Content-Type' that is reported by this API
     ***  to the web servers if you don't specify it explcitly when
     ***  calling the POST routines.   (the GET routines, by default,
     ***  do not specify a content-type.)

     D HTTP_CONTTYPE   C                   CONST('text/xml')

     ***  The original implementation of HTTPAPI used tables
     ***  (*TBL objects) to translate from ASCII to EBCDIC. These can
     ***  be enabled/set by defining the HTTP_USE_TABLES condition,
     ***  and then setting the table names.  They can be overridden
     ***  at runtime by calling HTTP_setTables().
     ***
     ***  In the current implementation, we prefer that you use CCSIDs
     ***  instead of tables. When HTTP_USE_TABLES is not defined,
     ***  the HTTP_EBCDIC and HTTP_ASCII constants represent the
     ***  default CCSIDs for ASCII<-->EBCDIC translation.  They can be
     ***  overridden at runtime by calling HTTP_setCCSIDs()
     ***

      /undefine HTTP_USE_TABLES
      /if defined(HTTP_USE_TABLES)
     D HTTP_TOEBC      C                   CONST('QTCPEBC')
     D HTTP_TOASC      C                   CONST('QTCPASC')
      /else
     D HTTP_EBCDIC     C                   CONST(0)
     D HTTP_ASCII      C                   CONST(819)
      /endif

     ***  This is the codepage or CCSID assigned to downloaded stream
     ***  files by default. (Note: HTTPAPI does not convert the file
     ***  to this CCSID, it just assigns this number to the file's
     ***  attributes.)
     ***
     ***  Whether this is treated as a CCSID or a codepage depends on
     ***  the value of the HTTP USE CCSID condition, below.
     ***
     ***  Can be overridden at runtime by calling HTTP_SetFileCCSID()

     D HTTP_CCSID      C                   CONST(819)

     ***  Starting in V5R1, a full CCSID is available in the IFS
     ***  instead of a codepage. When this is defined, CCSID support
     ***  will be used instead of codepages

     D/define HTTP_USE_CCSID

     ***  This is the file mode used when creating files in the IFS.
     ***  (Caution: This mode is given in DECIMAL, not octal!)
     ***  Octal 666 = Decimal 438  (RW-RW-RW-)
     ***  Octal 644 = Decimal 420  (RW-R--R--)
     ***  Octal 777 = Decimal 511  (RWXRWXRWX)
     ***  Octal 755 = Decimal 493  (RWXR-XR-X)

     D HTTP_IFSMODE    C                   CONST(511)

     ***  HTTPAPI normally uses non-blocking sockets to ensure that
     ***  the session never "hangs".  However, during the connection
     ***  progress, this can mean that information gets lost.
     ***
     ***  Define this to wait until after the connection is established
     ***  before switching the socket to non-blocking.
     D/define HTTP_BLOCK_ON_CONNECT

     ***
     *** This determines whether Cookies are turned *ON or *OFF
     *** by default.
     ***
     DHTTP_COOKIE_DEFAULT...
     D                 C                   CONST(*ON)

     ***  This changes whether debugging is on or off by default.
     ***  You can override this at runtime by calling the http_debug()
     ***  procedure.
     D/undefine DEBUG
     DHTTP_DEBUG_FILE  s            500A   varying
     D                                     inz('/tmp/httpapi_debug.txt')

     ***  This changes how memory is allocated.  If defined, HTTPAPI
     ***  will allocate memory in TERASPACE, thus allowing for very
     ***  large allocations.
     D/undefine USE_TS_MALLOC64
     D/undefine USE_TS_MALLOC64
     ***  With both turned off (default) up to 16 MB per allocation.
     ***  WARNING: This is currently experimental!!  If you have
     ***           problems, make sure TERASPACE is undefined.
     D/undefine TERASPACE
     D/undefine USE_TS_MALLOC64

     ***  This allows access to V5R3 (or higher) functions in the
     ***  SSL environment.  Only define this if HTTPAPI will be used
     ***  on V5R3 or later.
     D/define V5R3_GSKIT
