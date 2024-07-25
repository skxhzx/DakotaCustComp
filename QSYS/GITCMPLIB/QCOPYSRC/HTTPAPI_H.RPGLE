     /*-
      * Copyright (c) 2001-2008 Scott C. Klement
      * All rights reserved.
      *
      * Redistribution and use in source and binary forms, with or without
      * modification, are permitted provided that the following conditions
      * are met:
      * 1. Redistributions of source code must retain the above copyright
      *    notice, this list of conditions and the following disclaimer.
      * 2. Redistributions in binary form must reproduce the above copyright
      *    notice, this list of conditions and the following disclaimer in the
      *    documentation and/or other materials provided with the distribution.
      *
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ''AS IS'' AND
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPO
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTI
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WA
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
      * SUCH DAMAGE.
      *
      */

      /if defined(HTTPAPI_H)
      /eof
      /endif

     D HTTPAPI_VERSION...
     D                 C                   CONST('1.23')
     D HTTPAPI_RELDATE...
     D                 C                   CONST('2008-04-24')

      /copy LIBHTTPBFC/qrpglesrc,config_h

      *********************************************************************
      **  procedure prototypes
      *********************************************************************

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_get(): Retrieve an HTTP document
      *  http_url_get(): Retrieve an HTTP document
      *
      *       peURL = url to grab  (i.e. http://www.blah.com/dir/file.txt)
      *  peFilename = filename in IFS to save response into
      *  peTimeout  = (optional) give up if no data is received for
      *          this many seconds.
      *  peModTime  = (optional) only get file if it was changed since
      *          this timestamp.
      *  peContentType = (optional) content type to supply (mainly
      *          useful when talking to CGI scripts.) To supply the
      *          default value for this parm, you can supply the
      *          HTTP_CONTTYPE constant.
      *  peUserAgent = (optional) This specifies the name & version
      *          of your HTTP client to the server.  The server uses
      *          it for statistics and sometimes to restrict pages
      *          so that they're "only for Internet Explorer."
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  -1 = internal error (check HTTP_ERROR)
      *            0 = timeout while receiving data or connecting
      *            1 = file retrieved successfully
      *          > 1 = HTTP response code indicating server's error reply
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_get        PR            10I 0 extproc('HTTP_URL_GET')
     D  peURL                     32767A   varying const options(*varsize)
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     D http_url_get    PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post(): Post data to CGI script and get document
      *
      *         peURL = url to post to (http://www.blah.com/cgi-bin/etc)
      *    pePostData = pointer to data to post to CGI script.
      * pePostDataLen = length of data to post to CGI script.
      *   peFileName  = Filename in IFS to save response into
      *    peTimeout  = (optional) give up if no data is received for
      *            this many seconds.
      * peUserAgent = (optional) User-Agent string passed to the
      *            server.  Pass the named constant HTTP_USERAGENT
      *            if you want to get the default value.
      * peContentType = (optional) content type to supply (mainly
      *            useful when talking to CGI scripts)
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  -1 = internal error (check HTTP_ERROR)
      *            0 = timeout while receiving data or connecting
      *            1 = file retrieved successfully
      *          > 1 = HTTP response code indicating server's error reply
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_post       PR            10I 0 EXTPROC('HTTP_URL_POST')
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     D http_url_post   PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_get_raw(): Retrieve an HTTP document (in raw mode)
      *
      *       peURL = url to grab  (i.e. http://www.blah.com/dir/file.txt)
      *       peFD  = FD to pass back to peProc
      *     peProc  = procedure to call each time data is received.
      *  peTimeout  = (optional) give up if no data is received for
      *          this many seconds.
      * peUserAgent = (optional) User-Agent string passed to the
      *            server.  Pass the named constant HTTP_USERAGENT
      *            if you want to get the default value.
      *  peModTime  = (optiona) only get file if it was changed since
      *          this timestamp.
      *  peContentType = (optional) content type to supply (mainly
      *          useful when talking to CGI scripts)
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  (same as http_url_get)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_get_raw...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_raw(): Post data to CGI script and get document
      *
      *         peURL = url to post to (http://www.blah.com/cgi-bin/etc)
      *    pePostData = pointer to data to post to CGI script.
      * pePostDataLen = length of data to post to CGI script.
      *         peFD  = FD to pass back to peProc
      *       peProc  = procedure to call each time data is received.
      *    peTimeout  = (optional) give up if no data is received for
      *            this many seconds.
      *  peUserAgent  = (optional) User-Agent string passed to the
      *            server.  Pass the named constant HTTP_USERAGENT
      *            if you want to get the default value.
      * peContentType = (optional) content type to supply (mainly
      *            useful when talking to CGI scripts)
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  (same as http_url_post)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_post_raw...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_ParseURL(): Parse URL into it's component parts
      *
      *  Breaks a uniform resource locator (URL) into it's component
      *  pieces for use with the http: or https: protocols.  (would also
      *  work for FTP with minor tweaks)
      *
      *  peURL = URL that needs to be parsed.
      *  peService = service name from URL (i.e. http or https)
      *  peUserName = user name given, or *blanks
      *  pePassword = password given, or *blanks
      *  peHost = hostname given in URL. (could be domain name or IP)
      *  pePort = port number to connect to, if specified, otherwise 0.
      *  pePath = remaining path/request for server.
      *
      *  returns -1 upon failure, or 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_ParseURL   PR            10I 0
     D  peURL                       256A   const
     D  peService                    32A
     D  peUserName                   32A
     D  pePassword                   32A
     D  peHost                      256A
     D  pePort                       10I 0
     D  pePath                      256A


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_build_sockaddr():  Build a socket address structure for a host
      *
      *        peHost = hostname to build sockaddr_in for
      *     peService = service name (or port) to build sockaddr_in for
      *   peForcePort = numeric port to force entry to, overrides peService
      *    peSockAddr = pointer to a location to place a sockaddr_in into.
      *             (if *NULL, memory will be allocated, otherwise it will
      *                be re-alloc'ed)
      *
      *   returns -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_build_sockaddr...
     D                 PR            10I 0
     D   peHost                     256A   const
     D   peService                   32A   const
     D   peForcePort                 10I 0 value
     D   peSockAddr                    *

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_close(): close HTTP connection
      *
      *         peSock = socket to close
      *         peComm = comm driver opened with http_select_commdriver()
      *
      *  returns -1 upon failure, or 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_close      PR            10I 0
     D  peSock                       10I 0 value
     D  peComm                         *   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_error():   Return the last error that occurred.
      *
      *     peErrorNo = (optional) error number that occurred.
      *
      *  Returns the human-readable error message.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_error      PR            80A
     D   peErrorNo                   10I 0 options(*nopass:*omit)

      /if defined(HAVE_SSLAPI)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_init():  Initialize https (HTTP over SSL/TLS) protocol
      *
      *     peAppID = application ID that you registered program as
      *        in the Digital Certificate Manager
      *         NOTE: You can pass *BLANKS for this parameter if you
      *               you do not wish to register your application
      *               with the digital certificate manager.
      *     peSSLv2 = (optional) Turn SSL version 2 *ON or *OFF
      *     peSSLv3 = (optional) Turn SSL version 3 *ON or *OFF
      *     peTLSv1 = (optional) Turn TLS version 1 *ON or *OFF
      *
      *   You must pass all of the SSL/TLS flags or none.  If you
      *   do not pass all three flags, they are ignored.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D https_init      PR            10I 0
     D  peAppID                     100A   const
     D  peSSLv2                       1N   const options(*nopass)
     D  peSSLv3                       1N   const options(*nopass)
     D  peTLSv1                       1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Register your application with the Digital Certificate Manager
      *
      *    peAppID = application ID.  IBM recommends that you do
      *         something like:  COMPANY_COMPONENT_NAME
      *         (example:  QIBM_DIRSRV_REPLICATION)
      *
      *  peLimitCA = set to *On if you want to only want to allow the
      *         certificate authorities registered in D.C.M., or set to
      *         *Off if you'll manage that yourself.
      *
      *   returns 0 for success, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D https_dcm_reg   PR            10I 0
     D  peAppID                     100A   const
     D  peLimitCA                     1N   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_cleanup():  Clean up & free storage used by the SSL
      *   environment.
      *
      *  returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D https_cleanup   PR            10I 0


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_idname(): Returns a string that describes an SSL certificate
      *                  data element id (for printing/debugging)
      *
      *       peID = (input) data ID to get name of
      *
      * Returns the human-readable name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D https_idname    PR            50A   varying
     D   peID                        10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_strict(): Force SSL to be strictly validated
      *
      *      peSetting = (input) *ON  = use full validation
      *                          *OFF = use passthru validation
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D https_strict    PR
     D   peSetting                    1n   const

      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_getauth():   Get HTTP Authentication Information
      *
      *   Call this proc after you receive a HTTP_NDAUTH error
      *   to determine the authentication credentials that are required
      *
      *  The following parms are returned to your program:
      *
      *     peBasic = *ON if BASIC auth is allowed
      *    peDigest = *ON if MD5 DIGEST auth is allowed
      *     peRealm = Auth realm.  Present this to the user to identify
      *               which password you're looking for.  For example
      *               if peRealm is "secureserver.com" you might say
      *               "enter password for secureserver.com" to user.
      *
      *   After getting the userid & password from the user (or database)
      *   you'll need to call http_setauth()
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_getauth    PR            10I 0
     D   peBasic                      1N
     D   peDigest                     1N
     D   peRealm                    124A


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_setauth():   Set HTTP Authentication Information
      *
      *     peAuthType = Authentication Type (HTTP_AUTH_BASIC or
      *                     HTTP_AUTH_MD5_DIGEST)
      *     peUsername = UserName to use
      *     pePasswd   = Password to use
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_setauth    PR            10I 0
     D   peAuthType                   1A   const
     D   peUsername                  80A   const
     D   pePasswd                  1024A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_setproxy():   Set HTTP Proxy Address
      *
      *     peHost = Proxy host name
      *     psPort = Proxy port
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_setproxy   PR            10I 0
     D   peHost                     256A   const
     D   pePort                      10I 0 const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_proxy_setauth():   Set HTTP Proxy Authentication Information
      *
      *     peAuthType = Authentication Type (HTTP_AUTH_NONE or
      *                     HTTP_AUTH_BASIC)
      *     peUsername = UserName to use
      *     pePasswd   = Password to use
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_proxy_setauth...
     D                 PR            10I 0
     D   peAuthType                   1A   const
     D   peUsername                  80A   const
     D   pePasswd                  1024A   const

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_proxy_getauth():   Get HTTP Proxy Authentication Information
      *
      *   Call this proc after you receive a HTTP_PXNDAUTH error
      *   to determine the authentication credentials that are required
      *
      *  The following parms are returned to your program:
      *
      *     peBasic = *ON if BASIC auth is allowed
      *     peRealm = Auth realm.  Present this to the user to identify
      *               which password you're looking for.  For example
      *               if peRealm is "secureproxy.com" you might say
      *               "enter password for secureproxy.com" to user.
      *
      *   After getting the userid & password from the user (or database)
      *   you'll need to call http_proxy_setauth()
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_proxy_getauth...
     D                 PR            10I 0
     D   peBasic                      1N
     D   peRealm                    124A


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_xproc():  Register a procedure to be called back at
      *                 a given exit point
      *
      *     peExitPoint = exit point.  Should be one of the constants
      *                HTTP_POINT_XXX defined in the HTTPAPI_H member
      *          peProc = address of procedure to call for this
      *                exit point. (pass *NULL to disable this point)
      *      peUserData = Pointer to user data. This will be passed
      *                to your call-back procedure. You can set it to
      *                *NULL if you don't need/want it.
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_xproc      PR            10I 0
     D  peExitPoint                  10I 0 value
     D  peProc                         *   procptr value
     D  peUserData                     *   value options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_redir_loc(): Retrieve location provided by a redirect
      *   request.
      *
      *  returns redirect location, or '' if no redirect was given
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_redir_loc  PR          1024A   varying

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_new():  Create a URL encoder.
      *
      *   returns an (opaque) pointer to the new encoder
      *           or *NULL upon error.
      *
      * WARNING: To free the memory used by this routine, you MUST
      *          call http_url_encoder_free() after the data is sent.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_URL_ENCODER...
     D                 s               *
     D http_url_encoder_new...
     D                 PR                  like(HTTP_URL_ENCODER)
      /if defined(WEBFORMS)
     D WEBFORM         s                   like(HTTP_URL_ENCODER)
     D WEBFORM_open    PR                  ExtProc('HTTP_URL_ENCODER_NEW')
     D                                     like(HTTP_URL_ENCODER)
      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_addvar():  Add a variable to what's stored
      *          a URL encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_url_encoder_new() routine
      *   peVariable = variable name to add
      *       peData = pointer to data to store in variable
      *   peDataSize = size of data to store in variable
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_encoder_addvar...
     D                 PR             1N
     D    peEncoder                        like(HTTP_URL_ENCODER) value
     D    peVariable                 50A   varying value
     D    peData                       *   value
     D    peDataSize                 10I 0 value
      /if defined(WEBFORMS)
     D WEBFORM_setPtr...
     D                 PR             1N   extproc('HTTP_URL_ENCODER_ADDVAR')
     D    peEncoder                        like(WEBFORM) value
     D    peVariable                 50A   varying value
     D    peData                       *   value
     D    peDataSize                 10I 0 value
      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_getptr(): Get a pointer to the encoded
      *        data stored in a URL encoder
      *
      *     peEncoder = (input) pointer to encoder
      *        peData = (output) pointer to encoded data
      *        peSize = (output) size of encoded data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_encoder_getptr...
     D                 PR
     D    peEncoder                        like(HTTP_URL_ENCODER) value
     D    peData                       *
     D    peSize                     10I 0
      /if defined(WEBFORMS)
     D WEBFORM_postData...
     D                 PR                  ExtProc('HTTP_URL_ENCODER_GETPTR')
     D    peEncoder                        like(WEBFORM) value
     D    peData                       *
     D    peSize                     10I 0
      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_getstr(): Get encoded data he encoded
      *        data stored in a URL encoder as a string
      *
      *     peEncoder = (input) pointer to encoder
      *
      * NOTE: This routine is much slower than http_url_encoder_getptr()
      *       and is limited to a 32k return value.  It's suitable for
      *       use with data that's added to a URL, such as when
      *       performing a GET request to a web server, but you should
      *       use http_url_encoder_getptr() for POST requests.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_encoder_getstr...
     D                 PR         32767A   varying
     D    peEncoder                        like(HTTP_URL_ENCODER) value
      /if defined(WEBFORMS)
     D WEBFORM_getData...
     D                 PR         32767A   varying
     D                                     ExtProc('HTTP_URL_ENCODER_GETSTR')
     D    peEncoder                        like(WEBFORM) value
      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_free(): free resources allocated by both
      *        http_url_encoder_new() and http_url_encoder_addvar()
      *
      *     peEncoder = pointer to encoder to free
      *
      * Returns *ON if successful, *OFF otherwise.
      *
      * WARNING: After calling this, do not use the encoder or
      *          data returned by http_url_encoder_getptr() again.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_encoder_free...
     D                 PR             1N
     D    peEncoder                        like(HTTP_URL_ENCODER) value
      /if defined(WEBFORMS)
     D WEBFORM_close...
     D                 PR             1N   ExtProc('HTTP_URL_ENCODER_FREE')
     D    peEncoder                        like(WEBFORM) value
      /endif

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_addvar_s():  Simplified (but limited)
      *       interface to http_url_encoder_addvar().
      *
      *    peEncoder = (input) HTTP_url_encoder object
      *   peVariable = (input) variable name to set
      *      peValue = (input) value to set variable to
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_encoder_addvar_s...
     D                 PR             1N
     D    peEncoder                        like(HTTP_URL_ENCODER) value
     D    peVariable                 50A   varying value
     D    peValue                   256A   varying value
      /if defined(WEBFORMS)
     D WEBFORM_setVar...
     D                 PR             1N   ExtProc('HTTP_URL_ENCODER_ADDVAR_S')
     D    peEncoder                        like(HTTP_URL_ENCODER) value
     D    peVariable                 50A   varying value
     D    peValue                   256A   varying value
      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_long_ParseURL(): Parse URL into it's component parts
      *
      *  Breaks a uniform resource locator (URL) into it's component
      *  pieces for use with the http: or https: protocols.  (would also
      *  work for FTP with minor tweaks)
      *
      *  peURL = URL that needs to be parsed.
      *  peService = service name from URL (i.e. http or https)
      *  peUserName = user name given, or *blanks
      *  pePassword = password given, or *blanks
      *  peHost = hostname given in URL. (could be domain name or IP)
      *  pePort = port number to connect to, if specified, otherwise 0.
      *  pePath = remaining path/request for server.
      *
      *  returns -1 upon failure, or 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     d http_long_ParseURL...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peService                    32A
     D  peUserName                   32A
     D  pePassword                   32A
     D  peHost                      256A
     D  pePort                       10I 0
     D  pePath                    32767A   varying

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_select_commdriver():  Select & initialize communications
      *    driver.
      *
      *      peCommType = (input) communications type (http/https)
      *
      * Returns pointer to comm driver, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_select_commdriver...
     D                 PR              *
     D   peCommType                  32A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_raw2(): Post data to CGI script and get document
      *
      *         peURL = url to post to (http://www.blah.com/cgi-bin/etc)
      *      pePostFD = descriptor number to pass to pePostProc
      *    pePostProc = procedure to call to get POST data.
      *     peDataLen = total length of data that will be sent.
      *      peSaveFD = FD to pass back to peSaveProc
      *    peSaveProc = procedure to call each time data is received.
      *    peTimeout  = (optional) give up if no data is received for
      *            this many seconds.
      * peUserAgent = (optional) User-Agent string passed to the
      *            server.  Pass the named constant HTTP_USERAGENT
      *            if you want to get the default value.
      * peContentType = (optional) content type to supply (mainly
      *            useful when talking to CGI scripts)
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  -1 upon failure, 0 upon timeout, or an HTTP response code
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_post_raw2...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFD                     10I 0 value
     D  pePostProc                     *   procptr value
     D  peDataLen                    10I 0 value
     D  peSaveFD                     10I 0 value
     D  peSaveProc                     *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_stmf(): Post data to CGI script from stream file
      *
      *         peURL = url to post to (http://www.blah.com/cgi-bin/etc)
      *    pePostFile = Filename (in IFS) of file to send to http server
      *    peRecvFile = Filename (in IFS) of stream file containing reply
      *    peTimeout  = (optional) give up if no data is received for
      *            this many seconds.
      * peUserAgent = (optional) User-Agent string passed to the
      *            server.  Pass the named constant HTTP_USERAGENT
      *            if you want to get the default value.
      * peContentType = (optional) content type to supply (mainly
      *            useful when talking to CGI scripts)
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  -1 upon failure, 0 upon timeout,
      *            1 for success, or an HTTP response code
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_url_post_stmf...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peRecvFile                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     D http_post_stmf  PR            10I 0 extproc('HTTP_URL_POST_STMF')
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peRecvFile                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_get_xml();
      * http_url_get_xml():  Send a GET request to an HTTP server and
      *     receive/parse an XML response.
      *
      *       peURL = (input) URL to perform GET request to
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed to the
      *                    call-back routine
      *
      * (other parms are identical to those in HTTP_url_get())
      *
      * peStartProc should point to a procedure with a procedure
      * interface that's compatable with the following:
      *
      *  D StartProc       PR
      *  D   userdata                      *   value
      *  D   depth                       10I 0 value
      *  D   name                      1024A   varying const
      *  D   path                     24576A   varying const
      *  D   attrs                         *   dim(32767)
      *  D                                     const options(*varsize)
      *
      * peEndProc should point to a procedure with a procedure
      * interface that's compatable with the following:
      *
      *  D EndProc         PR
      *  D   userdata                      *   value
      *  D   depth                       10I 0 value
      *  D   name                      1024A   varying const
      *  D   path                     24576A   varying const
      *  D   value                    32767A   varying const
      *  D   attrs                         *   dim(32767)
      *  D                                     const options(*varsize)
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_get_xml...
     D                 PR            10I 0 EXTPROC('HTTP_URL_GET_XML')
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     D http_url_get_xml...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_get_xmltf(): Request URL from server. Receive response
      *        to temporary file, then parse it.
      *
      *       peURL = (input) URL to perform GET request to
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed to the
      *                    call-back routine
      *
      * (other parms are identical to those in HTTP_url_get())
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_get_xmltf...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_post_xml();
      * http_url_post_xml():  Send a POST request to an HTTP server and
      *     receive/parse an XML response.
      *
      *          peURL = (input) URL to perform GET request to
      *     pePostData = (input) data to POST to the web server
      *  pePostDataLen = (input) length of pePostData
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *       peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      * (other parms are identical to those in HTTP_url_post())
      *
      * peStartProc should point to a procedure with a procedure
      * interface that's compatable with the following:
      *
      *  D StartProc       PR
      *  D   userdata                      *   value
      *  D   depth                       10I 0 value
      *  D   name                      1024A   varying const
      *  D   path                     24576A   varying const
      *  D   attrs                         *   dim(32767)
      *  D                                     const options(*varsize)
      *
      * peEndProc should point to a procedure with a procedure
      * interface that's compatable with the following:
      *
      *  D EndProc         PR
      *  D   userdata                      *   value
      *  D   depth                       10I 0 value
      *  D   name                      1024A   varying const
      *  D   path                     24576A   varying const
      *  D   value                    32767A   varying const
      *  D   attrs                         *   dim(32767)
      *  D                                     const options(*varsize)
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_post_xml...
     D                 PR            10I 0 EXTPROC('HTTP_URL_POST_XML')
1    D  peURL                     32767A   varying const options(*varsize)
2    D  pePostData                     *   value
3    D  pePostDataLen                10I 0 value
4    D  peStartProc                    *   value procptr
5    D  peEndProc                      *   value procptr
6    D  peUsrDta                       *   value
7    D  peTimeout                    10I 0 value options(*nopass)
8    D  peUserAgent                  64A   const options(*nopass:*omit)
9    D  peContentType                64A   const options(*nopass:*omit)
10   D  peSOAPAction                 64A   const options(*nopass:*omit)
     D http_url_post_xml...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_post_xmltf(): Post data from memory. Receive
      *        response to temporary file, then parse it.
      *
      *          peURL = (input) URL to perform GET request to
      *     pePostData = (input) data to POST to the web server
      *  pePostDataLen = (input) length of pePostData
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *       peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      * (other parms are identical to those in HTTP_url_post())
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_post_xmltf...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_post_stmf_xml();
      *  http_url_post_stmf_xml(): Post data to CGI script from stream file
      *        and receive/parse an XML response
      *
      *       peURL = (input) URL to post to
      *  pePostFile = (input) File of stream file (in IFS) to post
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *  peTimeout  = (optional) give up if no data is received for
      *                       this many seconds.
      * peUserAgent = (optional) User-Agent string passed to the
      *            server.  Pass the named constant HTTP_USERAGENT
      *            if you want to get the default value.
      * peContentType = (optional) content type to supply (mainly
      *                       useful when talking to CGI scripts)
      *  peSOAPAction = (optional) string used to specify the action
      *          taken by some SOAP applications.
      *
      *  Returns  -1 upon failure, 0 upon timeout,
      *            1 for success, or an HTTP response code
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_post_stmf_xml...
     D                 PR            10I 0 extproc('HTTP_URL_POST_STMF_XML')
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     D http_url_post_stmf_xml...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_post_stmf_xmltf(): Post data from stream file.  Receive
      *        response to temporary file, then parse it.
      *
      *       peURL = (input) URL to post to
      *  pePostFile = (input) File of stream file (in IFS) to post
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *  peTimeout  = (optional) give up if no data is received for
      *                       this many seconds.
      * peContentType = (optional) content type to supply (mainly
      *                       useful when talking to CGI scripts)
      *
      *  Returns  -1 upon failure, 0 upon timeout,
      *            1 for success, or an HTTP response code
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_post_stmf_xmltf...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_open(): Open a persistent HTTP session
      *
      *       peURL = url to connect to
      *  peTimeout  = (optional) give up if no data is received for
      *          this many seconds.
      *
      *  Returns *NULL upon failure, or
      *          pointer to HTTP communication session
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_persist_open...
     D                 PR              *
     D  peURL                     32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_get(): Get a file using a persistent HTTP session
      *
      *         peComm = (input) pointer to persistent HTTP comm session
      *          peURL = (input) URL to get from persistent HTTP
      *           peFD = (input) FD to pass back to peProc
      *         peProc = (input) procedure to call each time data is
      *                          received.
      *      peTimeout = (input/optional) time-out when no data is received
      *                          for this many seconds.
      *    peUserAgent = (optional) User-Agent string passed to the
      *                          server.  Pass the named constant called
      *                          HTTP_USERAGENT if you want to get the
      *                          default value.
      *      peModTime = (input/optional) only get file if it was changed
      *                          since this timestamp.
      *  peContentType = (input/optional) content type to supply (mainly
      *                          useful when talking to CGI scripts)
      *   peSOAPAction = (input/optional) string to send in the SOAPAction:
      *                          HTTP header when making a SOAP request.
      *
      *  Returns  1 if successful,
      *           0 if timed out
      *          -1 if an internal error occurs
      *          or an HTTP response code if an error comes from the server
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_persist_get...
     D                 PR            10I 0
     D  peComm                         *   value
     D  peURL                     32767A   varying const options(*varsize)
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_post(): Post data to CGI script and get document
      *                       using a persistent connection
      *
      *         peComm = (input) pointer to persistent HTTP comm session
      *          peURL = (input) URL to post to with persistent HTTP
      * --------
      *       pePostFD = (input) Opaque integer to pass to pePostProc
      *     pePostProc = (input) Pointer to call-back procedure for
      *                          posting data to server.  If you pass
      *                          *NULL for this, you should use pePostData
      *                          instead.
      * -- or --
      *     pePostData = (input) Pointer to data to post.  If you pass
      *                          *NULL for this, you should use pePostProc
      *                          instead.
      * --------
      *  pePostDataLen = (input) Total length, in bytes, of post data.
      *       peSaveFD = (input) Opaque integer passed to peSaveProc
      *     peSaveProc = (input) Pointer to call-back procedure that is
      *                          called when data is received from HTTP
      *                          server.
      *      peTimeout = (input/optional) time-out when no data is received
      *                          for this many seconds.
      *    peUserAgent = (optional) User-Agent string passed to the
      *                          server.  Pass the named constant called
      *                          HTTP_USERAGENT if you want to get the
      *                          default value.
      *  peContentType = (input/optional) content type to supply (mainly
      *                          useful when talking to CGI scripts)
      *   peSOAPAction = (input/optional) string to send in the SOAPAction:
      *                          HTTP header when making a SOAP request.
      *
      *  Returns  1 if successful,
      *           0 if timed out
      *          -1 if an internal error occurs
      *          or an HTTP response code if an error comes from the server
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_persist_post...
     D                 PR            10I 0
     D  peComm                         *   value
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFD                     10I 0 value
     D  pePostProc                     *   value procptr
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peSaveFD                     10I 0 value
     D  peSaveProc                     *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_close(): End a persistent HTTP session
      *
      *     peComm = (input) pointer to persistent HTTP comm session
      *
      *  returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_persist_close...
     D                 PR            10I 0
     D  peComm                         *   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_open(): Create a multipart/form-data encoder
      *
      * A multipart/form-data encoder will encode the variables
      * and or stream files that you pass to it and store the results
      * in a stream file.  You can later POST those results with the
      * http_url_post_stmf() API.
      *
      *   peStmFile = (input) pathname to stream file to store
      *               encoded results.
      *
      *   returns an (opaque) pointer to the new encoder
      *           or *NULL upon error.
      *
      * WARNING: To free the memory used by this routine and close
      *          the stream file, you MUST call http_mfd_encoder_close()
      *          after the data is sent.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_mfd_encoder_open...
     D                 PR              *
     D  peStmFile                      *   value options(*string)
     D  peContType                   64A


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_addvar():  Add a variable to what's stored
      *          a multipart/form-data encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_mfd_encoder_open() routine
      *   peVariable = variable name to add
      *       peData = pointer to data to store in variable
      *   peDataSize = size of data to store in variable
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_mfd_encoder_addvar...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peData                       *   value
     D    peDataSize                 10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_addvar_s():  Simplified (but limited)
      *       interface to http_mfd_encoder_addvar().
      *
      *    peEncoder = (input) HTTP_mfd_encoder object
      *   peVariable = (input) variable name to set
      *      peValue = (input) value to set variable to
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_mfd_encoder_addvar_s...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peValue                   256A   varying value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_addstmf(): Add a stream file to what's stored
      *       in a multipart/form-data encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_mfd_encoder_open() routine
      *   peVariable = variable name to add
      *   pePathName = Path name of stream file to add
      *   peContType = Content-type of stream file to add
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_mfd_encoder_addstmf...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    pePathName                   *   value options(*string)
     D    peContType                 64A   varying const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_close():  close an open multipart/form-data
      *                            encoder.
      *
      *     peEncoder = (input) encoder to close
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_mfd_encoder_close...
     D                 PR
     D  peEncoder                      *   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_debug():  Turn debugging info *ON or *OFF
      *
      *      peStatus = (input) status (either *ON or *OFF)
      *
      *    peFilename = (input/optional) filename that debug info will be
      *                    written to.  If not defined, the value from
      *                    CONFIG_H is used.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_debug      PR
     D   peStatus                     1N   const
     D   peFilename                 500A   varying const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_SetCCSIDs():  Set the CCSIDs used for ASCII/EBCDIC
      *                    translation
      *
      *     pePostRem = (input) Remote CCSID of POST data
      *     pePostLoc = (input) Local CCSID of POST data
      *     peProtRem = (input) Remote CCSID of Protocol data
      *     peProtLoc = (input) Local CCSID of Protocol data
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_SetCCSIDs  PR            10I 0
     D   pePostRem                   10I 0 value
     D   pePostLoc                   10I 0 value
     D   peProtRem                   10I 0 value options(*nopass)
     D   peProtLoc                   10I 0 value options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_SetTables():  Set the translation tables used for
      *                    ASCII/EBCDIC translation
      *
      *     peASCII  = (input) Table for converting to ASCII
      *     peEBCDIC = (input) Table for converting to EBCDIC
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_SetTables  PR            10I 0
     D   peASCII                     10A   const
     D   peEBCDIC                    10A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_SetFileCCSID(): Set the CCSID that downloaded stream
      *                      files get tagged with
      *
      *     peCCSID  = (input) New CCSID to assign
      *
      * NOTE: HTTPAPI does not do *any* translation of downloaded
      *       data. It only sets this number as part of the file's
      *       attributes.  You can change it with the CHGATR CL
      *       command.
      *
      * NOTE: The IFS did not support CCSIDs in V4R5 and earlier.
      *       On those releases, this API will be used to set the
      *       codepage rather than the CCSID.
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_SetfileCCSID...
     D                 PR
     D   peCCSID                     10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xlate():  Translate data from ASCII <--> EBCDIC
      *
      *       peSize = (input) Size of data to translate
      *       peData = (input) Data
      *  peDirection = (input) can be set to the TO_ASCII or
      *                         TO_EBCDIC constant.
      *
      * Returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_xlate      PR            10I 0
     D   peSize                      10I 0 value
     D   peData                   32766A   options(*varsize)
     D   peDirection                  1A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xlatep(): Translate data from ASCII <--> EBCDIC
      *                (using a pointer instead of a variable)
      *
      *       peSize = (input) Size of data to translate
      *       peData = (input) Data
      *  peDirection = (input) can be set to the TO_ASCII or
      *                         TO_EBCDIC constant.
      *
      * Returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_xlatep     PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xlatedyn: Translate data from ASCII <--> EBCDIC
      *                using a dynamically sized output buffer
      *
      *      peSize = (input) size of data to translate
      *      peData = (input) pointer to data to translate
      * peDirection = (input) TO_ASCII or TO_EBCDIC
      *    peOutput = (output) address of newly allocated memory
      *
      * returns the length of the translated data or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_xlatedyn   PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D   peOutput                      *


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_set_100_timeout(): Set value for 100-continue timeouts.
      *
      * This API lets you change the timeout value that HTTPAPI waits
      * for a "100 Continue" response from the server during a POST
      * request. Some servers send this response, others do not. By
      * default, HTTPAPI waits 0.5 seconds for a response, and if it's
      * not received, sends the POST.
      *
      *   Set this to a low value (0.1?) when working with a server
      *   that does not send a "100 continue" response. That way, you
      *   don't have to wait for the timeout.
      *
      *   Set it to a higher value (10.0?) when working with a server
      *   whose responses are slower, but will definitely send the
      *   "100".  That way, HTTPAPI won't give up on the response and
      *   get out of sync.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_set_100_timeout...
     D                 PR
     D   peTimeout                   10P 3 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xml_SetCCSIDs():  Set the CCSIDs used for ASCII/EBCDIC
      *                    translation for XML documents
      *
      *     peRemote = (input) remote CCSID
      *     peLocal  = (input) local CCSID (can be 0 if you want
      *                 to use the CCSID of the current job)
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HTTP_xml_SetCCSIDs...
     D                 PR            10I 0
     D   peRemote                    10I 0 value
     D   peLocal                     10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_parse_xml_stmf(): Parse XML data directly from a stream file
      *                         (instead of downloading it from a server)
      *
      *      peFile = (input) Stream file (in IFS) to read data from
      *     peCCSID = (input) CCSID of stream file,
      *                    or HTTP_XML_CALC to attempt to calculate it
      *                       from the XML encoding
      *                    or HTTP_STMF_CALC to use the stream file's
      *                       CCSID attribute.
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      *  Returns  -1 upon failure, 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_parse_xml_stmf...
     D                 PR            10I 0
     D  peFile                    32767A   varying const options(*varsize)
     D  peCCSID                      10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value

     D HTTP_XML_CALC   C                   -1
     D HTTP_STMF_CALC  C                   -2


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_header():  retrieve the value of an HTTP header
      *
      *      name = (input) name of header to look for
      *       pos = (input/optional) position of header if there's
      *                 more than one with the same name
      *
      * returns the value of the HTTP header, or '' if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_header     PR         32500A   varying
     D   name                       256A   varying const
     D   pos                         10I 0 value options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_use_cookies(): Turns on/off HTTPAPI's cookie parsing and
      *                     caching routines.
      *
      *    peSetting = (input) *ON = HTTPAPI will read and send cookies
      *                       *OFF = HTTPAPI will ignore cookies
      *                              (has no affect on cookies supplied
      *                               via an exit procedure)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_use_cookies...
     D                 PR
     D   peSetting                    1N   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_cookie_file():  Set the name of the file that HTTPAPI
      *          will use to store cookies.
      *
      *    peFilename = (input) Filename (IFS path) to store cookie
      *                  data into.
      *
      *  If the filename is set to '', or if you do not call this API,
      *  cookies will only be saved until the activation group is
      *  reclaimed.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_cookie_file...
     D                 PR
     D   peFilename                 256A   varying const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_conp(): Send a completion message
      *
      *      peMessage = message to send.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_comp       PR
     D   peMessage                  256A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_diag(): Send a diagnostic message
      *
      *      peMessage = message to send.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_diag       PR
     D   peMessage                  256A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_crash(): Send back an *ESCAPE message containing last
      *               error found in HTTPAPI.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_crash      PR


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_tempfile():  Generate a unique temporary IFS file name
      *
      * returns the file name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_tempfile   PR            40A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_xmlns():  Enable XML Namespace processing
      *
      *     peEnable = (input) *ON to enable parsing, *OFF to disable.
      *                        (it is disabled by default)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     D http_xmlns      PR
     D   peEnable                     1N   const


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_XmlReturnPtr(): XML End Element Handler should return a
      *                      pointer to the full element value instead of
      *                      returning a VARYING character string.
      *                      (VARYING is limited to 64k)
      *
      *     peEnable = (input) *ON to return a pointer, *OFF to return
      *                        a VARYING string (*OFF = default)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     D http_XmlReturnPtr...
     D                 PR
     D   peEnable                     1N   const


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_XmlStripCRLF(): Enable stripping of CRLF characters
      *
      *     peEnable = (input) *ON to strip, *OFF to leave them in.
      *                        (they are stripped by default)
      *
      * Note: To simplify your XML string manipulations, HTTPAPI
      *       strips CRLF characters from the response.  If you would
      *       prefer that they are left in the response, call this
      *       routine with a parameter of *OFF.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     D http_XmlStripCRLF...
     D                 PR
     D   peEnable                     1N   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_switch_cb(): delegates element processing to another
      *     set of start and end element callback procedures for the
      *     current element and its children.
      *
      *    peUsrDta = (input) user-defined data that will be passed to
      *                       the call-back routine. usuallay only that
      *                       portion of the curent user data is forwarded
      *                       to the new callback procedures that they are
      *                       responsible for.
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *
      *  Returns  -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_parser_switch_cb...
     D                 PR            10I 0
     D  peUsrDta                       *   value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_get_start_cb(): returns the procedure pointer of
      *     the currently active start callback procedure.
      *
      *  Returns procedure pointer of start callback procedure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_parser_get_start_cb...
     D                 PR              *   procptr

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_get_end_cb(): returns the procedure pointer of
      *     the currently active end callback procedure.
      *
      *  Returns procedure pointer of end callback procedure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_parser_get_end_cb...
     D                 PR              *   procptr

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_get_userdata(): returns the procedure pointer of
      *     the currently active user data.
      *
      *  Returns procedure pointer of user data.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_parser_get_userdata...
     D                 PR              *


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_parse_xml_string():  Parse XML from an input string.
      *                         (instead of downloading it from a server)
      *
      *    peString = (input) Pointer to string
      *       peLen = (input) Length of string to parse
      *     peCCSID = (input) CCSID of string to be parsed
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      *  Returns  -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D http_parse_xml_string...
     D                 PR            10i 0
     D  peString                       *   value
     D  peLen                        10I 0 value
     D  peCCSID                      10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value


      *********************************************************************
      **  Error codes that HTTP API can return
      *********************************************************************
      ** Invalid URL format
     D HTTP_BADURL     C                   CONST(1)
      ** Host not found (not a valid IP address, or DNS lookup failed)
     D HTTP_HOSTNF     C                   CONST(2)
      ** No memory available for a socket addess structure
     D HTTP_SAALLO     C                   CONST(3)
      ** Unable to create a new socket
     D HTTP_SOCERR     C                   CONST(4)
      ** Unable to place the socket in non-blocking mode
     D HTTP_NONBLK     C                   CONST(5)
      ** Error when connecting to server
     D HTTP_BADCNN     C                   CONST(6)
      ** Timeout when connecting to server
     D HTTP_CNNTIMO    C                   CONST(7)
      ** Unable to translate request to ASCII
     D HTTP_SRXLATE    C                   CONST(8)
      ** Error occurred calling select() in the sendreq() procedure
     D HTTP_SRSELE     C                   CONST(9)
      ** Error occurred calling send() in the sendreq() procedure
      **   (probably means you were disconnected from the server)
     D HTTP_SRXMIT     C                   CONST(10)
      ** Error occurred calling recv() in the recvresp() procedure
      **   (probably means you were disconnected from the server)
     D HTTP_RRRECV     C                   CONST(11)
      ** Error occurred calling select() in the recvresp() procedure
     D HTTP_RRSELE     C                   CONST(12)
      ** HTTP response code logged (not an error, per se)
     D HTTP_RESP       C                   CONST(13)
      ** Error calling recv() in the recvdoc() procedure
     D HTTP_RDRECV     C                   CONST(14)
      ** Error calling select() in the recvdoc() procedure
     D HTTP_RDSELE     C                   CONST(15)
      ** Error calling user-specified procedure in the
      **   recvdoc() procedure.  (user proc must return full count)
     D HTTP_RDWERR     C                   CONST(16)
      ** Error occurred while calling send() in the senddoc() procedure
     D HTTP_SDSEND     C                   CONST(17)
      ** When receiving a 'chunked' document, only a partial chunk recvd
     D HTTP_BADCHK     C                   CONST(18)
      ** When receiving a 'chunked' document, couldnt read a chunk size.
     D HTTP_CHKSIZ     C                   CONST(19)
      ** Unsupported transfer-encoding value
     D HTTP_XFRENC     C                   CONST(20)
      ** You dont have access to put a file there :)
     D HTTP_ACCES      C                   CONST(21)
      ** Error opening file to save data into.
     D HTTP_FDOPEN     C                   CONST(22)
      ** Problem with the Application ID for the DCM
     D HTTP_GSKAPPID   C                   CONST(23)
      ** Error setting auth type
     D HTTP_GSKATYP    C                   CONST(24)
      ** Error initializing GSKit environment
     D HTTP_GSKENVI    C                   CONST(25)
      ** Error opening GSKit environment
     D HTTP_GSKENVO    C                   CONST(26)
      ** Error setting session type (client | server | server_auth)
     D HTTP_GSKSTYP    C                   CONST(27)
      ** Error registering application w/DCM
     D HTTP_REGERR     C                   CONST(28)
      ** Error open secure socket
     D HTTP_SSOPEN     C                   CONST(29)
      ** Error setting SSL numeric file descriptor
     D HTTP_SSSNFD     C                   CONST(30)
      ** Error setting SSL numeric timeout value
     D HTTP_SSSNTO     C                   CONST(31)
      ** SSL handshake timed out
     D HTTP_SSTIMO     C                   CONST(32)
      ** Select() failure in SendDoc()
     D HTTP_SDSELE     C                   CONST(33)
      ** Select() failure in get_chunk_size()
     D HTTP_CSSELE     C                   CONST(34)
      ** This app is not registered with digital cert mgr
     D HTTP_NOTREG     C                   CONST(35)
      ** This URI needs authorization (user/pass)
     D HTTP_NDAUTH     C                   CONST(36)
      ** Invalid HTTP authentication type
     D HTTP_ATHTYP     C                   CONST(37)
      ** Error in value of an HTTP authentication string
     D HTTP_ATHVAL     C                   CONST(38)
      ** Server didn't ask for authorizatin
     D HTTP_NOAUTH     C                   CONST(39)
      ** HTTP server didn't send a "100 Continue" in response
      ** to our POST request.
     D HTTP_PST417     C                   CONST(40)
      ** recvresp() timed out waiting for a server response code
     D HTTP_RRTIME     C                   CONST(41)
      ** recvdoc() timed out waiting for more data
     D HTTP_RDTIME     C                   CONST(42)
      ** blockread() timed out waiting for more data
     D HTTP_BRTIME     C                   CONST(43)
      ** blockread() error during recv() call
     D HTTP_BRRECV     C                   CONST(44)
      ** blockread() error during select() call
     D HTTP_BRSELE     C                   CONST(45)
      ** recvchunk() did not get the trailing CRLF chars
     D HTTP_RDCRLF     C                   CONST(46)
      ** Invalid exit point registered with HTTP_Xproc()
     D HTTP_BADPNT     C                   CONST(47)
      ** Error retrieving SSL protocol
     D HTTP_SSPROT     C                   CONST(48)
      ** Unknown SSL protocol
     D HTTP_SSPUNK     C                   CONST(49)
      ** Error setting SSL protocol
     D HTTP_SSPSET     C                   CONST(50)
      ** Out of memory
     D HTTP_NOMEM      C                   CONST(51)
      ** Must give data in order to encode it
     D HTTP_NODATA     C                   CONST(52)
      ** Pointer is invalid or already freed
     D HTTP_INVPTR     C                   CONST(53)
      ** Not enough space to add encoded variable
     D HTTP_NOSPAC     C                   CONST(54)
      ** Error calling send() API in BlockWrite()
     D HTTP_BWSEND     C                   CONST(55)
      ** Error calling select() API in BlockWrite()
     D HTTP_BWSELE     C                   CONST(56)
      ** Timeout waiting to send in BlockWrite()
     D HTTP_BWTIME     C                   CONST(57)
      ** Lineread() had problem with recv() API
     D HTTP_LRRECV     C                   CONST(58)
      ** Lineread() had problem with select() API
     D HTTP_LRSELE     C                   CONST(59)
      ** Lineread() had timeout
     D HTTP_LRTIME     C                   CONST(60)
      ** Procedure is no longer supported
     D HTTP_NOTSUPP    C                   CONST(61)
      ** No communication driver defined
     D HTTP_NOCDRIV    C                   CONST(62)
      ** Timeout sending data in blockwrite
     D HTTP_BWTIMO     C                   CONST(63)
      ** Timeout sending data in blockwrite
     D HTTP_SWCERR     C                   CONST(64)
      ** Timeout sending data in blockwrite
     D HTTP_FDSTAT     C                   CONST(65)
      ** Error parsing XML data
     D HTTP_XMLERR     C                   CONST(66)
      ** Error opening IFS file
     D HTTP_IFOPEN     C                   CONST(67)
      ** Error with SSL keyring
     D HTTP_GSKKEYF    C                   CONST(68)
      ** Must Use Table / Must not Use Table
     D HTTP_MUTABLE    C                   CONST(69)
      ** Cookie file cant be written
     D HTTP_CKDUMP     C                   CONST(70)
      ** Cookie file cant be read
     D HTTP_CKOPEN     C                   CONST(71)
      ** Can't get stats on cookie file
     D HTTP_CKSTAT     C                   CONST(72)
      ** Error converting CCSIDs
     D HTTP_CONVERR    C                   CONST(73)
      ** Error setting stream file CCSID
     D HTTP_SETATTR    C                   CONST(74)
      ** This Proxy server needs authorization (user/pass)
     D HTTP_PXNDAUTH   C                   CONST(75)
      ** XML callback switched illegally
     D HTTP_ILLSWC     C                   CONST(76)
      ** Error getting certificate info
     D HTTP_SSLGCI     C                   CONST(77)
      ** Error from certificate validation callback
     D HTTP_SSLVAL     C                   CONST(78)


      *********************************************************************
      *  HTTP WWW-Authentication types
      *********************************************************************
     D HTTP_AUTH_NONE...
     D                 C                   '0'
     D HTTP_AUTH_BASIC...
     D                 C                   '1'
     D HTTP_AUTH_MD5_DIGEST...
     D                 C                   '2'


      *********************************************************************
      *  HTTPAPI Exit points
      *********************************************************************
      ** Debug exit point:  This is called when ASCII stream data is to be
      **                    to a log file.   Here's the prototype for a
      **                    debug exit procedure:
      **
      **  D debug_proto     PR
      **  D   DataToLog                     *   value
      **  D   Length                      10I 0 value
      **
     D HTTP_POINT_DEBUG...
     D                 C                   1

      ** Upload status exit point:  This is called periodically during an
      **                            upload (POST) to an HTTP(S) server.
      **                            Allows you to display progress to the
      **                            user.
      **
      **  D upload_proto    PR
      **  D   BytesSent                   10U 0 value
      **  D   BytesTotal                  10U 0 value
      **
     D HTTP_POINT_UPLOAD_STATUS...
     D                 C                   2

      ** Download status exit point:  This is called periodically during a
      **                              download (POST or GET) from an HTTP(S)
      **                              server.  Allows you to display the
      **                              progress to the user.
      **
      **  D download_proto  PR
      **  D   BytesRecv                   10U 0 value
      **  D   BytesTotal                  10U 0 value
      **
     D HTTP_POINT_DOWNLOAD_STATUS...
     D                 C                   3

      ** Additional Header fields exit point:
      **    Allows you to supply additional header data to be added
      **    to the HTTP request chain.  Data should be in EBCDIC with
      **    x'0d25' after each header record.
      **
      **  D addl_hdrs_prot  PR
      **  D   HeaderData                1024A   varying
      **
     D HTTP_POINT_ADDL_HEADER...
     D                 C                   4

      ** Header parse exit point:
      **    Allows you to examine the HTTP response chain received
      **    from the HTTP server.
      **
      **  D parse_hdr_prot  PR
      **  D   HeaderData                2048A   const
      **
     D HTTP_POINT_PARSE_HEADER...
     D                 C                   5

      ** Header parse exit point:
      **    Allows you to examine the HTTP response chain received
      **    from the HTTP server. (allows longer headers)
      **
      **  D parse_hdr_long  PR
      **  D   HeaderData               32767A   const varying
      **
     D HTTP_POINT_PARSE_HDR_LONG...
     D                 C                   6

      ** SSL Certificate validation:
      **    This will be called repeatedly for each field in each
      **    certificate when parsed by HTTPAPI.
      **
      **  D cert_valid      PR            10i 0
      **  D   usrdta                        *   value
      **  D   id                                like(CERT_DATA_ID) value
      **  D   data                     32767a   varying const
      **  D   errmsg                      80a
      **
      **     id = certificate data id (see CERT_DATA_ID_T in GSKSSL_H)
      **   data = certificate element data.  (For binary elements, this
      **          is binary data. For others, it'll be EBCDIC data.)
      ** errmsg = the callback can use this to return a reason why a
      **          certificate wasn't valid.  (retrievable w/HTTP_error)
      **
      **  Return 0 if okay, -1 if you want to reject it.
      **
     D HTTP_POINT_CERT_VAL...
     D                 C                   7

      ** SSL Certificate validation (GSkit)
      **    This sets the GSK_CERT_VALIDATION_CALLBACK callback proc
      **    within GSKit.  The GSKit (not HTTPAPI) will call back
      **    your procedure to validate a certificate.
      **
      **    See the gsk_attribute_set_callback() API documentation
      **    in the IBM Information Center for details.
      **
      **    Note: The UserData parameter to http_xproc() will be
      **          passed as the 3rd parameter to the
      **          gsk_attribute_set_callback() API -- the peProc
      **          parameter to http_xproc() is ignored for this
      **          exit point.
      **
     D HTTP_POINT_GSKIT_CERT_VAL...
     D                 C                   8


      *********************************************************************
      * Directions for HTTP_xlate() and HTTP_xlatep()
      *********************************************************************
     D TO_ASCII        C                   '1'
     D TO_EBCDIC       C                   '2'
