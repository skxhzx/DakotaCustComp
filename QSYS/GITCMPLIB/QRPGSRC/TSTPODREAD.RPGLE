      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI') BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *  TSTPODREAD  Test readin POD return file.
     *  31 August 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    08/31/08  DAS  5.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,httpapi_h
     D/copy qcopysrc,ifsio_h
     D/copy qcopysrc,errno_h

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

     D parsePODrtn     PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D rc              s             10I 0
     D msg             s             52A
     D p_data          S               *
     D mystat          S                   like(statds)
     D stmfSend        S            256A
     D stmfRecv        S            256A
     D url             S            256A
     D userid          S             50A
     D pass            S             50A
     D sf              s             10I 0
     D pathLen         s              3  0
     D pmsg            s            100
510aAD iflags          S             10U 0
     D resultType      s             10A
     D errorCode       s             10A
     D errorMessage    s            100A

     *----------------------------------------------------------------
     *  Mainline
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         http_debug(*ON);

         stmfRecv = '/harbor/poddavertn.xml';

         rc = http_parse_xml_stmf( %trim(stmfRecv)
                                   : HTTP_XML_CALC
                                   : *null
                                   : %paddr(parsePODrtn)
                                   : *null );

         if RC < 0;
           eval pMsg = 'xml error: ' + http_error;
        endif;

         return;

      /end-free

     *================================================================
     * Procedure: parsePODrtn
     *================================================================
     *
     * This is called for each XML element that's received in the
     * phrase string. The string will look something like the
     * following:
     *
     *   <addOrderReply ...>
     *     <orderResult>
     *       <orderNumber>...</orderNumber>
     *       <result>
     *         <resultType>...</resultType>
     *         <errorCode>...</errorCode>
     *         <message>...</message>
     *       </result>
     *     </orderResult>
     *   </addOrderReply>
     *
     *  where <resultType> will either be 'success' or 'failure'.
     *
     *  The DEPTH parameter indicates the nesting depth of the
     *  element received.  In the above example, the <orderResult> tag
     *  would be depth 1 and <orderNumber> would be depth 2, etc.
     *
     *  The NAME parameter is the name of the XML element that
     *  has been received.  It might be something like "orderResult",
     *  "orderNumber" or "result".
     *
     *  The PATH indicates the elements that the current element
     *  is found inside. So, the path for "orderNumber" is "/orderResult".
     *
     *  The VALUE parameter gives us the text that's inside that
     *  element.
     *
     *================================================================

     P parsePODrtn     B
     D parsePODrtn     PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D PrintLine       s            100A   varying
      /free

             PrintLine = '(' + %trim(path) + '/' + %trim(name)
                       + ') ' + value;

            select;
            when name = 'addOrderReply';
            when name = 'orderResult';
            when name = 'orderNumber';
            when name = 'result';
            when name = 'resultType';
              eval resultType = value;
            when name = 'errorCode';
              eval errorCode = value;
            when name = 'message';
              eval errorMessage = value;
            endsl;

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               PrintLine = '(' + %trim(path) + '/' + %trim(name)
                         + ':' + %trim(attrname)
                         + ') ' + attrval;
               count = count + 1;
            enddo;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy qcopysrc,errno_h
