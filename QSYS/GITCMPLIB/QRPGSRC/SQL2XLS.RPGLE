     H dftactgrp(*no) actgrp('XLS') thread(*serialize) bnddir('QC2LE') debug
     H copyright('Giuseppe Costagliola - beppecosta@yahoo.it - 2004')
     H option(*srcstmt : *nodebugio)

      *********************************************************************
      * SQL2XLSR - Create Excel from SQL - v-2.0.b
      *********************************************************************

      *********************************************************************
      * "This product includes software developed by the
      *  Apache Software Foundation (http://www.apache.org/)."
      *--------------------------------------------------------------------
      * Special thanks to David Morris for sharing code to start the JVM
      * -------------------------------------------------------------------
      * THIS UTILITY IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED
      * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
      * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
      * DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OF THIS UTILITY OR
      * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
      * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
      * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
      * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
      * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
      * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
      * OF THE USE OF THIS UTILITY, EVEN IF ADVISED OF THE POSSIBILITY OF
      * SUCH DAMAGE.
      *********************************************************************

      **------------------------------------------------------------------
*s1*  * SQL2XLS CMD PARAMETERS
      **------------------------------------------------------------------
     D EntryParms      PR                  extpgm('SQL2XLS')
     D  pSQLSTMT                   5000
     D  pTOXLS                       63
     D  pFROMXLS                     63
     D  pSHEETNAME                   20
     D  pCOLHDRS                     10
     D  pTITLE                      120
     D  pTITLECOLS                    5I 0
     D  pTITLEALIGN                   7
     D  pLTRIM                        4
     D  pWRTZEROC                     4
     D  pENDJVM                       4
     D  pNAMING                       4
     D  pACTION                       9
     D  pLOGSQL                       4
     D  pSQLLOCVAL                    4
     D EntryParms      PI
     D  pSQLSTMT                   5000
     D  pTOXLS                       63
     D  pFROMXLS                     63
     D  pSHEETNAME                   20
     D  pCOLHDRS                     10
     D  pTITLE                      120
     D  pTITLECOLS                    5I 0
     D  pTITLEALIGN                   7
     D  pLTRIM                        4
     D  pWRTZEROC                     4
     D  pENDJVM                       4
     D  pNAMING                       4
     D  pACTION                       9
     D  pLOGSQL                       4
     D  pSQLLOCVAL                    4

      *----------------------------------------------------------------
*s2*  * sql communication area
      *----------------------------------------------------------------
     D SQLCA           DS
     D  SQLCAID                       8
     D  SQLCABC                       9B 0
     D  SQLCODE                       9B 0
     D  SQLERRML                      4B 0
     D  SQLERRMC                     70
     D  SQLERRP                       8
     D  SQLERRD                      24
     D   SQLER1                       9B 0 Overlay(SQLERRD:1)
     D   SQLER2                       9B 0 Overlay(SQLERRD:5)
     D   SQLER3                       9B 0 Overlay(SQLERRD:9)
     D   SQLER4                       9B 0 Overlay(SQLERRD:13)
     D   SQLER5                       9B 0 Overlay(SQLERRD:17)
     D   SQLER6                       4A   Overlay(SQLERRD:21)
     D  SQLWARN                      11
     D  SQLSTATE                      5

      *----------------------------------------------------------------
      * sql descriptor area
      *----------------------------------------------------------------
     D SQLDA           DS                  based(pSQLDA)
     D  SQLDAID                1      8A
     D  SQLDABC                9     12B 0
     D  SQLN                  13     14B 0
     D  SQLD                  15     16B 0
     D  SQL_VAR                      80A   DIM(1)

     D SQLVAR          DS                  based(pSQLVAR)
     D  SQLTYPE                1      2B 0
     D  SQLLEN                 3      4B 0
     D   Precis                3      3
     D   Scale                 4      4
     D  SQLRES                 5     16A
     D  SQLDATA               17     32*
     D  SQLIND                33     48*
     D  SQLNAMELEN            49     50B 0
     D  SQLNAME               51     80A

     D* SQLDA pointers
     D pSQLDA          s               *
     D pSQLVAR         s               *

     D* SQLDA sizes
     D nSQLDA          s              5I 0
     D szSQLDA         s             10I 0

     D* Column sizes
     D cSQLLEN         s              5I 0
     D pSQLLEN         ds                  inz
     D  pPrecis                1      4B 0
     D   aPrecis               4      4
     D  pScale                 5      8B 0
     D   aScale                8      8

     D* Record buffer
     D Record          s          32000

     D* Miscellaneous
     D psqlL           s              5I 0
     D NullFields      s              5I 0 dim(1000)
     D i               s              5I 0
     D j               s              5I 0
     D jo              s              5I 0
     D od              s              5I 0
     D on              s              5I 0

      *----------------------------------------------------------------
*s3*  * QSQPRCED - process extended dynamic sql
      *----------------------------------------------------------------
     D QSQPRCED        PR                  extpgm('QSQPRCED')
     D  SQLCA                       136
     D  SQLDA                     32000    options(*varsize)
     D  sqformat                      8    const
     D  sqlp0100                   5096    options(*varsize)
     D  apierror                    120    options(*varsize)
     D** Function Template
     D sqlp0100        ds
     D  function                      1    inz('0')
     D  pkgname                      10    inz('SQLPACK')
     D  pkglib                       10    inz('QTEMP')
     D  mainpgm                      10    inz('SQL2XLS')
     D  mainlib                      10    inz('*LIBL')
     D  stmname                      18    inz('EXCEL')
     D  curname                      18    inz('CURSOR')
     D  openopt                       1    inz(x'00')
     D  claudesc                      1    inz('A')
     D  commit                        1    inz('N')
     D  datefmt                       3    inz('DMY')
     D  datesep                       1    inz('/')
     D  timefmt                       3    inz('HMS')
     D  timesep                       1    inz(':')
     D  namingopt                     3    inz('SYS')
     D  decpos                        1    inz('.')
     D  block                         4B 0 inz(0)
     D  SqlStmtl                      4B 0 inz(0)
     D  SqlStmt                    5000

     D sqformat        ds
     D  format                       10    inz('SQLP0100')

      *----------------------------------------------------------------
      * QUSRJOBI - job informations
      *----------------------------------------------------------------
     D QUSRJOBI        PR                  extpgm('QUSRJOBI')
     D  jobi0100                     70
     D  jobi_bytes                    9B 0 const
     D  jobi_form                    10    const
     D  jobi_jobn                    26    const
     D  jobi_jobi                    16    const
     D  apierror                    120    options(*varsize)
     D** Job information
     D jobi0100        ds            70
     D  jobi_bytes                    9B 0 inz(61)
     D  jobi_avail                    9B 0
     D  jobi_jobn                    26    inz('*')
     D  jobi_jobi                    16    inz
     D  jobi_form                    10    inz('JOBI0100')
     D  jobi_type                     1

      *----------------------------------------------------------------
      * QUSROBJD - object description information
      *----------------------------------------------------------------
     D QUSROBJD        PR                  extpgm('QUSROBJD')
     D  objd0100                     48
     D  objd_bytes                    9B 0 const
     D  objd_form                     8    const
     D  obj_name                     20    const
     D  objd_type                    10    const
     D  apierror                    120    options(*varsize)
     D** Object description
     D objd0100        ds
     D  objd_bytes                    9B 0 inz(48)
     D  objd_avail                    9B 0
     D  objd_form                    10    inz('OBJD0100')
     D  objd_type                    10
     D                               10
     D  objd_rlib                    10
     D  objd_name      s             20

      *----------------------------------------------------------------
      * QWCRSVAL - retrieve system values
      *----------------------------------------------------------------
     D QWCRSVAL        PR                  extpgm('QWCRSVAL')
     D  qsva_rcv                    180
     D  qsva_rcvL                     9B 0 const
     D  qsva_sysL                     9B 0 const
     D  qsva_sysv                    40    const
     D  apierror                    120    options(*varsize)
     D** system values
     D qsva_rcvL       s              9B 0 inz(120)
     D qsva_sysL       s              9B 0 inz(4)
     D qsva_sysv       ds
     D  datfmt                       10    inz('QDATFMT')
     D  datsep                       10    inz('QDATSEP')
     D  timsep                       10    inz('QTIMSEP')
     D  decfmt                       10    inz('QDECFMT')

     D qsva_rcv        ds
     D  rtnval                        9B 0
     D  sysoff                        9B 0 dim(4)
     D  systable                    160
     D qsystable       ds
     D  sysvaltab                    24    dim(4)
     D  sysvalname                   10    Overlay(sysvaltab:1)
     D  sysvalue                      7    Overlay(sysvaltab:17)

      *----------------------------------------------------------------
      * QMHSNDPM/QMHRCVPM - send/receive program messages
      *----------------------------------------------------------------
     D QMHSNDPM        PR                  extpgm('QMHSNDPM')
     D  MessageId                     7    const
     D  MessageFile                  20    const
     D  MessageData                 512    const options(*varsize)
     D  MessageDataL                  9B 0 const
     D  MessageType                  10    const
     D  CallStkEntry                128    const options(*varsize)
     D  CallStkCount                  9B 0 const
     D  MessageKey                    4    const
     D  ApiError                    120    options(*varsize)
     D* send program message
     D sndpgmmsg       ds
     D  msgid                         7    inz('CPF9898')
     D  msgfile                      20    inz('QCPFMSG   QSYS      ')
     D  msgdataL                      9B 0 inz(512)
     D  msgtype                      10    inz('*COMP     ')
     D  msgmsgq                      11    inz('*       ')
     D  msgstack                      9B 0 inz(1)
     D  msgkey                        4
     D* receive program message
     D QMHRCVPM        PR                  extpgm('QMHRCVPM')
     D  rcv0100                    1024
     D  msgbytes                      9B 0 const
     D  msgformat                     8    const
     D  msgmsgq                      11    const
     D  msgstack                      9B 0 const
     D  msgtyper                     10    const
     D  msgkey                        4    const
     D  msgwait                       9B 0 const
     D  msgaction                    10    const
     D  ApiError                    120    options(*varsize)
     D rcvpgmmsg       ds
     D  msgbytes                      9B 0 inz(8)
     D  msgformat                     8    inz('RCVM0100')
     D  msgwait                       9B 0 inz(0)
     D  msgaction                    10    inz('*OLD      ')
     D  msgtyper                     10    inz('*ANY      ')
     D msgdata         s            512
     D rcv0100         s           1024

      *----------------------------------------------------------------
      * api error structure
      *----------------------------------------------------------------
     D ApiError        ds
     D  ApiErrLP                      9B 0 inz(%len(Apierror))
     D  ApiErrLA                      9B 0 inz(0)
     D  ApiErrMsg                     7
     D                                1
     D  ApiErrDta                   104

      *----------------------------------------------------------------
*s4*  * MI/C functions
      *----------------------------------------------------------------
     D* Copy Bytes left adjusted (MemCpy)
     D Cpybla          pr                  ExtProc('cpybla')
     D  Receiver                       *   value
     D  Source                         *   value
     D  Size                         10I 0 value
     D* Put environment variable
     D PutEnv          pr            10I 0 ExtProc('putenv')
     D  EnvVar                         *   value options(*string)
     D rc              s             10I 0
     D* Sleep
     D Sleep           pr            10I 0 ExtProc('sleep')
     D  Seconds                      10U 0 value

      *----------------------------------------------------------------
      * program status area
      *----------------------------------------------------------------
     D parms          sds
     D  parmsL           *parms
     D  pgmnam           *proc

      *********************************************************************
*s5*  * JAVA std Objects and Methods
      *********************************************************************
      * generic String object
     D string          S               O   Class(*JAVA:'java.lang.String')
      * generic trimmed String object
     D tstring         S               O   Class(*JAVA:'java.lang.String')
      * File Name object
     D fileName        S               O   Class(*JAVA:'java.lang.String')
      * trimmed Fine Name object
     D tfileName       S               O   Class(*JAVA:'java.lang.String')
      * Sheet Name object
     D sheetName       S               O   Class(*JAVA:'java.lang.String')
      * trimmed Sheet Name object
     D tsheetName      S               O   Class(*JAVA:'java.lang.String')
      * User Format object
     D usrformat       S               O   Class(*JAVA:'java.lang.String')
      * Cell Format object
     D cellformat      S               O   Class(*JAVA:'java.lang.String')
      * FileOutputStream.
     D outFile         S               O   Class(*JAVA
     D                                     :'java.io.FileOutputStream')
      * InputStream.
     D is              S               O   Class(*JAVA
     D                                     :'java.io.InputStream')
      * new String(byte[]) - String CONSTRUCTOR --------------------------
     D createString    PR              O   ExtProc(*JAVA:'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA:'java.lang.String')
     D string                     32000    const varying
      * new FileOutputStream(String file) - FileOutputStream CONSTRUCTOR --
     D createFile      PR              O   ExtProc(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'java.io.FileOutputStream')
     D file                            O   Class(*JAVA:'java.lang.String')
      * new FileInputStream(String file) - FileInputStream CONSTRUCTOR ----
     D FileInputStream...
     D                 PR              O   ExtProc(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'java.io.FileInputStream')
     D file                            O   Class(*JAVA:'java.lang.String')
      * closeFile(java.io.OutputStream) -----------------------------------
     D closeFile       PR                  EXTPROC(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :'close')
      * closeFile(java.io.InputStream) ------------------------------------
     D closeInput      PR                  EXTPROC(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     :'close')
      * java.lang.trim() --------------------------------------------------
     D trimString      PR              O   ExtProc(*JAVA:'java.lang.String'
     D                                     :'trim')
     D                                     Class(*JAVA:'java.lang.String')
      * java.lang.substring(i,k) ------------------------------------------
     d subString       PR              O   ExtProc(*JAVA:'java.lang.String'
     d                                     :'substring')
     d                                     Class(*JAVA:'java.lang.String')
     d start                         10I 0 value
     d lenght                        10I 0 value

      *********************************************************************
      * HSSF Objects
      *********************************************************************
      * FileStream --------------------------------------------------------
     D fs              S               O   Class(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem')
      * Workbook ----------------------------------------------------------
     D wb              S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
      * Sheet -------------------------------------------------------------
     D sheet           S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
      * Row ---------------------------------------------------------------
     D row             S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
      * Cell --------------------------------------------------------------
     D cell            S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
      * DataFormat --------------------------------------------------------
     D df              S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat')
      * Font --------------------------------------------------------------
     D font            S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      * Region ------------------------------------------------------------
     D region          S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region')
      * Style (2 dec + comma separators ) ---------------------------------
     D style2d         S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Bold) ------------------------------------------------------
     D styleBold       S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Align Center) ----------------------------------------------
     D styleAlignC     S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Hdr Bold) --------------------------------------------------
     D styleHdr        S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Stile (Hdr Align Center) ------------------------------------------
     D styleHdrC       S               O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * new POIFSFileSystem (InputStream) - FileSystem CONSTRUCTOR --------
     D createfs        PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem')
     D inpFile                         O   Class(*JAVA
     D                                     :'java.io.InputStream')
      * new HSSFWorkbook() - WorkBook CONSTRUCTOR -------------------------
     D createwb        PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
      * new HSSFWorkbook(POIFSFileSystem fs) - WorkBook CONSTRUCTOR -------
     D openwb          PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
     D parm                            O   Class(*JAVA
     D                                     :'org.apache.poi.poifs.filesystem-
     D                                     .POIFSFileSystem')
      * new Region( int rowFrom, short colFrom, int rowTo, short colTo ) --
     D createRegion    PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region'
     D                                     :*CONSTRUCTOR)
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region')
     D rowFrom                       10I 0 value
     D colFrom                        5I 0 value
     D rowTo                         10I 0 value
     D colTo                          5I 0 value

      *********************************************************************
      * HSSF Methods
      *********************************************************************
      * write(java.io.OutputStream) ---------------------------------------
     D writewb         PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'write')
     D workBook                        O   Class(*JAVA
     D                                     :'java.io.OutputStream')
      * WorkBook.createSheet() --------------------------------------------
     D createSheet     PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createSheet')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
      * WorkBook.createSheet(java.lang.String.sheetname) ------------------
     D createSheetN    PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createSheet')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
     D sheetname                       O   Class(*JAVA:'java.lang.String')
      * WorkBook.getSheetAt(index)-----------------------------------------
     D getSheetAt      PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'getSheetAt')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
     D index                         10I 0 value
      * WorkBook.getSheet(jala.lang.String.sheetname) ---------------------
     D getSheet        PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'getSheet')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
     D sheetname                       O   Class(*JAVA:'java.lang.String')
      * WorkBook.createCellStyle() ----------------------------------------
     D createCellStyle...
     D                 PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createCellStyle')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * WorkBook.createFont() ---------------------------------------------
     D createFont      PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createFont')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      * Sheet.createRow(rownum) -------------------------------------------
     D createRow       PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'createRow')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
     D rownum                        10I 0 value
      * Sheet.getLastRowNum() ---------------------------------------------
     D getLastRowNum   PR            10I 0 ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'getLastRowNum')
      * Sheet.setColumnWidth(column,width) --------------------------------
     D setColWidth     PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'setColumnWidth')
     D colnum                         5I 0 value
     D colwidth                       5I 0 value
      * Row.createCell() --------------------------------------------------
     D createCell      PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D                                     :'createCell')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
     D cellnum                        5I 0 value
      * Cell.setCellType(int) ---------------------------------------------
     D setCellType     PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellType')
     D celltype                      10I 0 value
      * Cell.setCellValue(Number) -----------------------------------------
     D setCellValNum   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D cellvalue                      8f   value
      * Cell.setCellValue(String) -----------------------------------------
     D setCellValStr   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D cellvalue                       O   Class(*JAVA
     D                                     :'java.lang.String')
      * sheet.addMergedRegion( region ) -----------------------------------
     D addMergedRegion...
     D                 PR            10I 0 ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'addMergedRegion')
     D region                          O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.util-
     D                                     .Region')
      * Style.SetDataFormat(Format) ---------------------------------------
     D setDataFormat   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setDataFormat')
     D dataformat                     5I 0 value
      * Create DataFormat -------------------------------------------------
     D createDataFormat...
     D                 PR              O   ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createDataFormat')
     D                                     Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat')
      * GetFormat ---------------------------------------------------------
     D getFormat       PR             5I 0 ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat'
     D                                     :'getFormat')
     D format                          O   Class(*JAVA
     D                                     :'java.lang.String')
      * Cell.setCellStyle(style) ------------------------------------------
     D setCellStyle    PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellStyle')
     D style                           O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
      * Font.setBoldweight(short boldweight) ------------------------------
     D setBoldweight   PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setBoldweight')
     D boldweight                     5I 0 value
      * Style.setFont(Font) -----------------------------------------------
     D setFont         PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setFont')
     D font                            O   Class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
      * Style.setAlignment(short align) -----------------------------------
     D setAlignment    PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setAlignment')
     D align                          5I 0 value
      * Style.setWrapText(boolean) ----------------------------------------
     D setWrapText     PR                  ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setWrapText')
     D wrap                            n   value

      *********************************************************************
*s6*  * JVM/JNI section
      *********************************************************************
     D/Define OS400_JVM_12
     D/copy qsysinc/qrpglesrc,JNI

      * JNI environment ptr
     D env             s               *
     D g_jnienv        s               *   inz(*null)

      * get the JNI environment
     D getJniEnv       pr              *
     D   inputOpts                65535a   varying const options(*nopass)

      * start the JVM
     D startJvm        pr              *
     D   inputOpts                65535a   varying const options(*nopass)
     D attachJvm       pr              *
     D getClasspath    pr         65535a   varying
     D cvtToAscii      pr         65535a   varying
     D   ebcdic                   65535a   varying const

      * free single object
     D freeJavaObject  PR
     D  env                            *   const
     D  javaObject                     O   CLASS(*JAVA:'java.lang.Object')
     D                                     value
      * begin a group of object
     D beginObjGroup   PR
     D  env                            *   const
     D  capacity                     10I 0 value
      * end a group of object
     D endObjGroup     PR
     D  env                            *   const

      * destroy JVM
     D destroyJVM      PR            10I 0

      *********************************************************************
      * Miscellaneous variables x Excel
      *********************************************************************
     D* Excel File name
     D XLSfile         S             63
     D* Row/Col counter
     D r               S             10I 0 Inz(0)
     D c               S             10I 0 Inz(0)
     D* Column width
     D ColWidth        s             10I 0 dim(1000)
     D* Custom Styles
     D usrFmt2d        S             24    Inz('#,##0.00')
     D styleFmt2d      S              5I 0
     D boldWeight      S              5I 0 Inz(700)
     D alignCenter     S              5I 0 Inz(2)
     D idxREgion       S             10I 0
     D* Cells
     D Cell_Alfa       S           1024
     D Cell_Pack       S             30P 0
     D Cell_Zone       S             30S 0
     D Cell_Float      S              8F
     D Cell_Short      S              5I 0
     D Cell_Int        S             10I 0
     D Cell_BigInt     S             20I 0
     D pCell_Pack      S               *
     D pCell_Zone      S               *
     D wrt0cell        S               N

      *****************************************************************
      ** MAIN
      *****************************************************************

      /free

*sA*   // just terminate the jvm
       if pSQLSTMT = '*NONE' and pENDJVM = '*YES';
         rc = destroyJVM();
         *inlr = *on;
         return;
       endif;

*sA*   // reformat the SQL statement
       SqlStmt = pSQLSTMT;
       psqlL = %checkr(' ':SqlStmt);
       for j = 1 to psqlL;
         select;
           when %subst(SqlStmt:j:1) = '"';
             %subst(SqlStmt:j:1) = '''';
           when %subst(SqlStmt:j:1) = '[';
             %subst(SqlStmt:j:1) = '"';
           when %subst(SqlStmt:j:1) = ']';
             %subst(SqlStmt:j:1) = '"';
         endsl;
       endfor;

       // display/log SQL statement
       If pLOGSQL = '*YES';
         msgdata = 'sql=>' + SqlStmt;
         // If interactive display as status msg
         QUSRJOBI (jobi0100:jobi_bytes:jobi_form:
                   jobi_jobn:jobi_jobi:Apierror);
         If jobi_type = 'I';
           msgtype = '*STATUS';
           msgmsgq = '*EXT';
           QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                     msgstack:msgkey:apierror);
           reset sndpgmmsg;
         EndIf;

         // send to joblog
         msgstack = 0;
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
         // flag the message as received
         QMHRCVPM (rcv0100:msgbytes:msgformat:msgmsgq:msgstack:msgtyper:
                   msgkey:msgwait:msgaction:apierror);
       EndIf;


*sB*   // create the *sqlpkg If it does not exist
       ApiErrMsg = *blanks;
       objd_name = pgmnam + '*LIBL';
       objd_type = '*PGM';
       QUSROBJD (objd0100:objd_bytes:objd_form:objd_name:objd_type:apierror);
       mainlib = objd_rlib;
       ApiErrMsg = *blanks;
       pkgname = pgmnam;
       objd_name = pkgname + pkglib;
       objd_form = 'OBJD0100';
       objd_type = '*SQLPKG';
       QUSROBJD (objd0100:objd_bytes:objd_form:objd_name:objd_type:apierror);
       If ApiErrMsg = 'CPF9801';
         // prepare the sql template
         If pSQLLOCVAL = '*YES';
           exsr sq100setup;
         EndIf;
         namingopt = %subst(pNAMING:2:3);
         // create the package
         ApiErrMsg = ' ';
         function = '1';
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
         If ApiErrMsg <> ' ';
           If pACTION = '*ESCAPE';
             %subst(msgfile:1:10) = 'QSQLMSG';
             QMHSNDPM (ApiErrMsg:msgfile:ApiErrDta:ApiErrLA-15:
                       '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
           else;
             *inlr = *on;
             return;
           EndIf;
         EndIf;
       EndIf;

       // allocate 20 elements
       nSQLDA = 20;
       szSQLDA = (nSQLDA * 80) + 16;
       pSQLDA = %alloc(szSQLDA);
       clear SQLDA;
       SQLN = nSQLDA;

*sC*   // prepare the SQL statement
       function = '2';
       openopt = x'80';
       SqlStmtl = psqlL;
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       // If errors in prepare/describe do not continue
       If SQLCODE <> 0;
         exsr ckretcode;
         *inlr = *on;
         return;
       EndIf;

       // describe the SQL into SQLDA
       function = '7';
       select;
         when pCOLHDRS = '*FLDNAM';
           claudesc = 'N';
         when pCOLHDRS = '*SQLLABEL';
           claudesc = 'L';
         when pCOLHDRS = '*ANY';
           claudesc = 'A';
         other;
           claudesc = 'N';
       endsl;
       SqlStmtl = psqlL;
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       If SQLN <= SQLD;                  // reallocate If not enough
         nSQLDA = SQLD;
         szSQLDA = (nSQLDA * 80) + 16;
         pSQLDA = %realloc(pSQLDA:szSQLDA);
         SQLN = nSQLDA;
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       EndIf;
       // only select statements are allowed
       If sqld = 0;
         SQLCODE = 0084;
       EndIf;
       // If there are errors in prepare/describe do not continue
       If SQLCODE <> 0;
         exsr ckretcode;
         *inlr = *on;
         return;
       EndIf;

*sD*   // set CLASSPATH environment
       rc = putenv('CLASSPATH=/excel/POI-2.0.jar');

*sD*   // get the environment (or start the JVM)
       env = getJniEnv();

       // Create a new workbook
       Monitor;
       // If there is a .xls template
       If pFROMXLS <> '*NONE';
         // Dummy, just to initialize class
         wb = createwb();
         freeJavaObject(env:wb);
         // put backslash in IFS style
         XLSFile = %trim(pFROMXLS);
         If %scan('\':XLSFile) > 0;
           For i=1 to %len(%trimr(XLSFile));
             if %subst(XLSFile:i:1) = '\';
               %subst(XLSFile:i:1) = '/';
             endif;
           EndFor;
         EndIf;
         // open the template
         fileName = createString(XLSFile);
         tfileName = trimString(fileName);
         is = FileInputStream(tfileName);
         fs = createfs(is);
         // open Workbook
         wb = openwb(fs);
         // open Worksheet
         if pSHEETNAME = '*DFT';
           sheet = getSheetAt(wb:0);
           r = getLastRowNum(sheet) + 2;
         else;
           sheetName = createString(pSHEETNAME);
           tsheetName = trimString(sheetName);
           sheet = getSheet(wb:tsheetName);
           if sheet = *null;
             sheet = createSheetN(wb:tsheetName);
             r = 0;
           else;
             r = getLastRowNum(sheet) + 2;
           endif;
           freeJavaObject(env:sheetName);
           freeJavaObject(env:tsheetName);
         endif;
         freeJavaObject(env:fileName);
         freeJavaObject(env:tfileName);
       else;
       // If build .xls from scratch
         // create an empty Workbook
         wb = createwb();
         // create an empty Worksheet
         if pSHEETNAME = '*DFT';
           sheet = createSheet(wb);
         else;
           sheetName = createString(pSHEETNAME);
           tsheetName = trimString(sheetName);
           sheet = createSheetN(wb:tsheetName);
           freeJavaObject(env:sheetName);
           freeJavaObject(env:tsheetName);
         endif;
         r = 0;
       EndIf;
       // monitor Java errors
       On-error *PROGRAM;
         QMHRCVPM (rcv0100:%len(rcv0100):'RCVM0200':'*':0:'*ESCAPE':
                   ' ':0:'*SAME':ApiError);
         If pACTION = '*ESCAPE';
           msgfile   = %subst(rcv0100:26:20);
           ApiErrMsg = %subst(rcv0100:13:7);
           %subst(RcvPgmMsg:1:4) = %subst(rcv0100:153:4);
           rcv0100 = %subst(rcv0100:177:msgbytes);
           QMHSNDPM (ApiErrMsg:msgfile:rcv0100:msgbytes:
                  '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
         else;
           *inlr = *on;
           return;
         EndIf;
       Endmon;

       // Start a group of objects
       beginObjGroup (env:10000000);

*sE*   // create 2d Style
       style2d     = createCellStyle(wb);

       // create Font object e set it Bold
       font = createFont(wb);
       setBoldweight(font:boldweight);

       // create a DataFormatter, a User Format and set the Style
       df = createDataFormat(wb);
       usrformat = createString(usrFmt2d);
       usrformat = trimString(usrformat);
       stylefmt2d = getFormat(df:usrformat);
       setDataFormat(style2d:stylefmt2d);

       // If requested, write a new row for sheet header
       If pTITLE <> '*NONE';
         // create a style for sheet header
         styleHdr  = createCellStyle(wb);
         setFont(styleHdr:font);
         setWrapText(styleHdr:*off);
         styleHdrC = createCellStyle(wb);
         setFont(styleHdrC:font);
         setAlignment(styleHdrC:alignCenter);
         setWrapText(styleHdrC:*off);
         // create a header row
         row = createRow(sheet:r);
         // add first column
         cell = createCell(row:0);
         setCellType(cell:0);                 // type 1=Character
         string = createString(pTITLE);       // create java string
         tstring = trimString(String);        // trim string
         setCellValStr(cell:tstring);         // set cell value
         freeJavaObject(env:string);
         freeJavaObject(env:tstring);
         If pTITLEALIGN = '*NONE';
           setCellStyle(cell:styleHdr);      // align left
         else;
           setCellStyle(cell:styleHdrC);    // align center
         endif;
         If pTITLECOLS = -1;
          pTITLECOLS = SQLD;
         endif;
         If pTITLECOLS > 1;
           // add more columns
           for c = 2 to pTITLECOLS;
             cell = createCell(row:c-1);
           endfor;
           // create a region
           region = createRegion(r:0:r:pTITLECOLS-1);
           // merge columns
           idxRegion = addMergedRegion(sheet:region);
         endif;
         // increase row counter
         r = r + 1;
       EndIf;

       // If requested, write a new row for column headers
       If pCOLHDRS <> '*NONE';
         // create a style for column header
         styleBold   = createCellStyle(wb);
         setFont(styleBold:font);
         styleAlignC = createCellStyle(wb);
         setAlignment(styleAlignC:alignCenter);
         setFont(styleAlignC:font);
         row = createRow(sheet:r);
         r = r + 1;
       EndIf;

*sF*   // write column hdrs and set the record buffer addresses into SQLDA
       pSQLVAR = %addr(SQL_VAR);
       od = 0;
       on = 0;

       for c = 1 to SQLD;

         // write column header
         If pCOLHDRS <> '*NONE';
           cell = createCell(row:c-1);
           Cell_Alfa = %subst(SQLNAME:1:SQLNAMELEN);
           j = %scan('\':Cell_Alfa);
           If j > 0;
             %subst(Cell_Alfa:j:1) = x'25';
             setWrapText(styleBold:*on);
             setWrapText(styleAlignC:*on);
           endif;
           setCellType(cell:1);                       // type 1=String
           string = createString(Cell_Alfa);          // create Java string
           tstring = trimString(string);              // trim string
           setCellValStr(cell:tstring);               // put string in cell
           freeJavaObject(env:string);
           freeJavaObject(env:tstring);
           If SQLTYPE >= 484 and SQLTYPE <= 489;      // If col is numeric
             setCellStyle(cell:styleAlignC);          // .. align center
           else;                                      // If col is string
             setCellStyle(cell:styleBold);            // .. just bold
           EndIf;

           // save column width (headers)
           If j > 0;
             If j > SQLNAMELEN - j;
               ColWidth(c) = j/(1/256) + 500;
             else;
               ColWidth(c) = (SQLNAMELEN - j)/(1/256) + 500;
             endif;
           else;
           ColWidth(c) = SQLNAMELEN/(1/256) + 500;
           endif;
         EndIf;

         // set record buffer address into SQLDA
         select;                                     // field Type
           when  SQLTYPE = 484 or SQLTYPE = 485 or   // .. Packed
                 SQLTYPE = 488 or SQLTYPE = 489;     // .. Signed
             aPrecis = Precis;
             cSQLLEN = pPrecis;
           when  SQLTYPE = 384 or SQLTYPE = 385;     // .. Date
             cSQLLEN = 10;
           when  SQLTYPE = 388 or SQLTYPE = 389;     // .. Time
             cSQLLEN = 10;
           when  SQLTYPE = 392 or SQLTYPE = 393;     // .. Timestamp
             cSQLLEN = 18;
           when  SQLTYPE = 448 or SQLTYPE = 449;     // .. VarChar
             SQLLEN += 2;
             cSQLLEN = SQLLEN;
             SQLTYPE += 4;
           other;                                    // .. Char
             cSQLLEN = SQLLEN;
           endsl;

         SQLDATA = %addr(Record) + od;               // address for data
         SQLIND  = %addr(NullFields) + on;           // address for nullind

         // save column width (data)
         If cSQLLEN/(1/256) + 500 > ColWidth(c);
           ColWidth(c) = cSQLLEN/(1/256) + 500;
           If ColWidth(c) > 30000;
             ColWidth(c) = 30000;
           EndIf;
         EndIf;

         // point to next element
         od = od + cSQLLEN + 1;
         on = on + 2;
         pSQLVAR = pSQLVAR + 80;
       endfor;

*sG*   // open cursor
       function = '4';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // fetch records
       wrt0cell = (pWRTZEROC = '*YES');
       function = '5';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
       dow SQLCODE = 0;
         // create a new Row
         row = createRow(sheet:r);
         //.. point to first element
         pSQLVAR = %addr(SQL_VAR);
         for c = 1 to SQLD;
           // create a new Cell
           // cell = createCell(row:c-1);
           select;
             // null field
             when NullFields(c) = -1;
               if not wrt0cell;
                 // do nothing
               else;
                 setCellType(cell:1);                 // type 1=Character
                 Cell_Alfa = '<null>';
                 string = createString(Cell_Alfa);    // create java string
                 tstring = trimString(string);        // trim string
                 cell = createCell(row:c-1);
                 setCellValStr(cell:tstring);         // set cell value
                 freeJavaObject(env:string);
                 freeJavaObject(env:tstring);
               endif;
             // ... Packed
             when SQLTYPE = 484 or SQLTYPE = 485;
               Cell_Pack = 0;
               aPrecis = Precis;
               cSQLLEN = (pPrecis / 2) + 1;
               pCell_Pack = %addr(Cell_Pack) + 16 - cSQLLEN;
               Cpybla(pCell_Pack: SQLDATA: cSQLLEN);
               if Cell_Pack = 0 and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:0);                 // type 0=Numeric
                 If Scale <> x'00';
                   aScale = Scale;
                   setCellValNum(cell:Cell_Pack/10**pScale);
                   If pScale = 2;
                     setCellStyle(cell:style2d);      // edit figure
                   EndIf;
                 else;
                   setCellValNum(cell:Cell_Pack);
                 EndIf;
               Endif;
               cSQLLEN = pPrecis;
             // ... Signed
             when SQLTYPE = 488 or SQLTYPE = 489;
               Cell_Zone = 0;
               aPrecis = Precis;
               cSQLLEN = pPrecis;
               pCell_Zone = %addr(Cell_Zone) + 30 - cSQLLEN;
               Cpybla(pCell_Zone: SQLDATA: cSQLLEN);
               if Cell_Zone = 0 and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:0);                 // type 0=Numeric
                 If Scale <> x'00';
                   aScale = Scale;
                   setCellValNum(cell:Cell_Zone/10**pScale);
                 else;
                   setCellValNum(cell:Cell_Zone);
                 EndIf;
               Endif;
             // ... Short integer
             when SQLTYPE = 500 or SQLTYPE = 501;
               Cell_Short = 0;
               Cpybla(%addr(Cell_Short): SQLDATA: 2);
               if Cell_Short = 0 and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:0);                 // type 0=Numeric
                 setCellValNum(cell:Cell_Short);
               Endif;
             // ... Large integer
             when SQLTYPE = 496 or SQLTYPE = 497;
               Cell_Int = 0;
               Cpybla(%addr(Cell_Int): SQLDATA: 4);
               if Cell_Int = 0 and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:0);                 // type 0=Numeric
                 setCellValNum(cell:Cell_Int);
               Endif;
             // ... Big integer
             when SQLTYPE = 492 or SQLTYPE = 493;
               Cell_BigInt = 0;
               Cpybla(%addr(Cell_BigInt): SQLDATA: 8);
               if Cell_BigInt = 0 and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:0);                 // type 0=Numeric
                 setCellValNum(cell:Cell_BigInt);
               Endif;
             // ... Date/Time
             when  SQLTYPE = 384 or SQLTYPE = 385 or
                   SQLTYPE = 388 or SQLTYPE = 389;
               Cell_Alfa = *blanks;
               Cpybla(%addr(Cell_Alfa): SQLDATA: 10);
               if Cell_Alfa = *blanks and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:1);                 // type 1=Character
                 string = createString(Cell_Alfa);    // create java string
                 tstring = trimString(String);        // trim string
                 setCellValStr(cell:tstring);         // set cell value
                 freeJavaObject(env:string);
                 freeJavaObject(env:tstring);
               Endif;
             // ... Timestamp
             when  SQLTYPE = 392 or SQLTYPE = 393;
               Cell_Alfa = *blanks;
               Cpybla(%addr(Cell_Alfa): SQLDATA: 18);
               if Cell_Alfa = *blanks and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:1);                 // Type 1=character
                 string = createString(Cell_Alfa);    // create java string
                 tstring = trimString(String);        // trim string
                 setCellValStr(cell:tstring);         // set cell value
                 freeJavaObject(env:string);
                 freeJavaObject(env:tstring);
               Endif;
             // ... Characters and other
             other;
               Cell_Alfa = *blanks;
               cSQLLEN = SQLLEN;
               Cpybla(%addr(Cell_Alfa): SQLDATA: cSQLLEN);
               if Cell_Alfa = *blanks and not wrt0cell;
                 // do nothing
               else;
                 cell = createCell(row:c-1);
                 setCellType(cell:1);                 // Type 1=character
                 string = createString(Cell_Alfa);    // create java string
                 if pLTRIM = '*YES';
                   tstring = trimString(String);      // trim string
                 else;
                   tstring = subString(string:0:%len(%trimr(Cell_Alfa)));
                 endif;
                 setCellValStr(cell:tstring);         // set cell value
                 freeJavaObject(env:string);
                 freeJavaObject(env:tstring);
               Endif;
           endsl;

           //.. point to next element
           pSQLVAR = pSQLVAR + 80;
         endfor;
         QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);
         r = r + 1;
       enddo;

*sH*   // set the Column Width
       If r >= 1;
         for c = 1 to SQLD;
           setColWidth(sheet:c-1:ColWidth(c));
         endfor;
       EndIf;

       // close cursor
       function = '8';
       QSQPRCED (SQLCA:SQLDA:sqformat:sqlp0100:apierror);

       // create the .Xls
       Monitor;
       XLSFile = %trim(pTOXLS);
       // put backslash in IFS style
       If %scan('\':XLSFile) > 0;
         For i=1 to %len(%trimr(XLSFile));
           if %subst(XLSFile:i:1) = '\';
              %subst(XLSFile:i:1) = '/';
           endif;
         EndFor;
       EndIf;
       fileName = createString(XLSFile);
       tfileName = trimString(fileName);
       outFile = createFile(tfileName);

       // write Workbook into .xls
       writewb(wb:outFile);

       // close it
       closeFile(outFile);

       // close input if any
       If pFROMXLS <> '*NONE';
         closeInput(is);
       endif;

       // monitor Java errors
       On-error *PROGRAM;
         QMHRCVPM (rcv0100:%len(rcv0100):'RCVM0200':'*':0:'*ESCAPE':
                   ' ':0:'*SAME':ApiError);
         If pACTION = '*ESCAPE';
           msgfile   = %subst(rcv0100:26:20);
           ApiErrMsg = %subst(rcv0100:13:7);
           %subst(RcvPgmMsg:1:4) = %subst(rcv0100:153:4);
           rcv0100 = %subst(rcv0100:177:msgbytes);
           QMHSNDPM (ApiErrMsg:msgfile:rcv0100:msgbytes:
                  '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
         else;
           *inlr = *on;
           return;
         EndIf;
       Endmon;

       // end the group of Objects
       endObjGroup (env);

       // free Excel Java objects
       freeJavaObject(env:is);
       freeJavaObject(env:fs);
       freeJavaObject(env:wb);
       freeJavaObject(env:sheet);

       // terminate JVM
       if pENDJVM = '*YES';
         rc = destroyJVM();
       endif;

       // send a completion message and return
       exsr ckretcode;
       msgtype  = '*COMP';
       msgstack = 1;
       QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                 msgstack:msgkey:apierror);
       *inlr = *on;
       return;

       // ------------------------------------------------------------------
       // Check sql return codes
       // ------------------------------------------------------------------
       begsr ckretcode;

       select;
          // error condition
          when SQLCODE < 0;
            msgtype = '*DIAG';
            //... cpf message
            If SQLER1 > 0;
              msgid = %editw(%dec(SQLER1:7:0):'0      ');
              %subst(msgid:1:3) = 'CPF';
            else;
            //... cpd message
              If SQLER2 > 0;
                msgid = %editw(%dec(SQLER2:7:0):'0      ');
                %subst(msgid:1:3) = 'CPD';
              else;
                msgid = %editw(%dec(SQLCODE*-1:7:0):'0      ');
                %subst(msgid:1:3) = 'SQL';
                %subst(msgfile:1:10) = 'QSQLMSG';
              EndIf;
            EndIf;
          // successful with warnings
          when SQLCODE > 0;
            msgid = %editw(%dec(SQLCODE:7:0):'0      ');
            %subst(msgid:1:3) = 'SQL';
            %subst(msgfile:1:10) = 'QSQLMSG';
          // successful execution
          other;
            msgid = 'SQL' + SQLER6;
            %subst(msgfile:1:10) = 'QSQLMSG';
       endsl;

       // message text
       If SQLERrml > 0;
         msgdata = SQLERrmc;
         msgdataL = SQLERrml;
       EndIf;

       // If interactive send a status message
       If jobi_type = 'I';
         msgtype  = '*STATUS';
         msgmsgq  = '*EXT';
         msgstack = 0;
         If msgid = 'SQL7959';
           msgid = 'SQL7977';
           %subst(msgdata:1:20) = 'SQL2XLS';
           %subst(msgdata:21:80) = %subst(pSQLSTMT:1:80);
           msgdataL = 100;
         EndIf;
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
         rc = sleep(1);
         msgtype  = '*DIAG';
         msgmsgq  = '*';
       Endif;
       If SQLCODE <> 0 and pACTION = '*ESCAPE';
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:
                   '*ESCAPE':'*CTLBDY':1:msgkey:apierror);
       EndIf;

       EndSr;

       // ------------------------------------------------------------------
       // Set date/time/sep from system values into SQLP0100
       // ------------------------------------------------------------------
       begsr sq100setup;

       QWCRSVAL (qsva_rcv:qsva_rcvL:qsva_sysL:qsva_sysv:apierror);
       for j = 1 to 4;
         jo = sysoff(j) + 1;
         sysvaltab(j) = %subst(qsva_rcv:jo);
       endfor;

       datefmt = sysvalue(1);
       datesep = sysvalue(2);
       timesep = sysvalue(3);
       If %subst(sysvalue(4):1:1) <> ' ';
         decpos = ',';
       EndIf;

       EndSr;

      /end-free

      *----------------------------------------------------------------
      * getJniEnv - attach-to or start the JVM
      *
      * Parameters:
      * 1. inputOpts - string of options separated by whatever the
      *                last character in the string is.
      *                For example
      *                   -Djava.pool.size=800;-Dcompile=none;
      *              - ignored if the JVM is already started
      *              - classpath is taken from the CLASSPATH environment
      *                variable
      *    Sample calls:
      *    env = getJniEnv()                      // take the defaults
      *    env = getJniEnv('-Djava.poolsize=800;'
      *                  + '-Dcompile=none;')     // specify 2 options
      *    env = getJniEnv('-Djava.poolsize=800!'
      *                  + '-Dcompile=none!')     // use ! as separator
      *
      *----------------------------------------------------------------
     P getJniEnv       b                   export
     D getJniEnv       pi              *
     D   inputOpts                65535a   varying const options(*nopass)
     D env             s               *   inz(*null)
      /free
                 env = attachJvm();
                 if (env = *null);
                    if %parms() = 0
                    or %len(inputOpts) = 0;
                       env = startJvm();
                    else;
                       env = startJvm(inputOpts);
                    endif;
                 endif;
                 g_jnienv = env;
                 return env;
      /end-free
     P getJniEnv       e

      *****************************************************************
      * startJvm - try to start the JVM
      *
      * Parameters:
      * 1. inputOpts - string of options separated by whatever the
      *                first character in the string is
      *              - ignored if the JVM is already started
      *****************************************************************
     P startJvm        b
     D startJvm        pi              *
     D   inputOptsP               65535a   varying const options(*nopass)
     D initArgs        ds                  likeds(JavaVMInitArgs)
     D options         ds                  likeds(JavaVMOption) occurs(10)
     D jvm             s                   like(JavaVM_p)
     D env             s                   like(JNIENV_p) inz(*null)
     D rc              s             10I 0
     D len             s             10I 0
     D prefix          s            100a   varying
     D pOptions        s               *   inz(%addr(options))
     D i               s             10I 0
     D classpath       S          65535a   varying
      * For handling the input options
     D splitChar       s              1a
     D pos             s             10I 0
     D nextPos         s             10I 0
     D inputOpts       s          65535a   varying
     D inputOptsPtr    s               *
     D freeThisOccur   s               n   dim(%elem(options)) inz(*off)

     D sqlmsgdta       s                   like(msgdata)

      /free

       If pLOGSQL = '*YES' and jobi_type = 'I';
         sqlmsgdta = msgdata;
         msgdata = 'Starting JVM. Please be patient ....';
         msgtype = '*STATUS';
         msgmsgq = '*EXT';
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
       EndIf;

        monitor;
           initArgs = *allx'00';
           JNI_GetDefaultJavaVMInitArgs (%addr(initArgs));
           initArgs.version = JNI_VERSION_1_2;

           // add the classpath option, if necessary

           classpath = getClasspath();
           if (%len(classpath) > 0);
              initArgs.nOptions = initArgs.nOptions + 1;
              %occur(options) = initArgs.nOptions;
              freeThisOccur(initArgs.nOptions) = *on;
              options = *allx'00';

              prefix = '-Djava.class.path=:';
              len = %len(prefix) + %len(classpath) + 1;
              options.optionString = %alloc (len);
              %str(options.optionString : len) =
                                             cvtToAscii(prefix)
                                           + cvtToAscii(classpath);
           endif;

           // add any other options that were passed in

           if  %parms > 0
           and %len(inputOptsP) > 0;
              inputOpts = cvtToAscii(inputOptsP);
              inputOptsPtr = %addr(inputOpts) + 2;
              splitChar = %subst(inputOpts : %len(inputOpts) : 1);
              pos = 1;
              dow pos <= %len(inputOpts);
                 nextPos = %scan(splitChar : inputOpts : pos);
                 len = nextPos - pos;
                 %subst(inputOpts : nextPos : 1) = x'00';

                 initArgs.nOptions = initArgs.nOptions + 1;
                 %occur(options) = initArgs.nOptions;
                 options = *allx'00';

                 options.optionString = inputOptsPtr + pos - 1;

                 pos = nextPos + 1;
              enddo;
           endif;

           if initArgs.nOptions > 0;
              initArgs.options = pOptions;
           endif;

           rc = JNI_CreateJavaVM (jvm : env : %addr(initArgs));
           if (rc <> 0);
              env = *null;
           endif;

        on-error;
           env = *null;
        endmon;

        // free any storage allocated for the options
        for i = 1 to initArgs.nOptions;
           if (freeThisOccur(i));
              %occur(options) = i;
              dealloc(n) options.optionString;
           endif;
        endfor;

       If pLOGSQL = '*YES' and jobi_type = 'I';
         QMHSNDPM (msgid:msgfile:sqlmsgdta:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
         reset sndpgmmsg;
       EndIf;

        return env;

      /end-free
     P startJvm        e

      *****************************************************************
      * attachJvm - try to attach to the JVM
      *****************************************************************
     P attachJvm       b
     D attachJvm       pi              *
     D attachArgs      ds                  likeds(JavaVMAttachArgs)
     D jvm             s                   like(JavaVM_p) dim(1)
     D nVms            s                   like(jsize)
     D env             s               *   inz(*null)
     D rc              s             10I 0
      /free

        monitor;
           rc = JNI_GetCreatedJavaVMs(jvm : 1 : nVms);
           if (rc <> 0);
              return *null;
           endif;
           if (nVms = 0);
              return *null;
           endif;

           JavaVM_P = jvm(1);
           attachArgs = *allx'00';
           attachArgs.version = JNI_VERSION_1_2;
           rc = AttachCurrentThread (jvm(1) : env : %addr(attachArgs));
           if (rc <> 0);
              env = *null;
           endif;

        on-error;
           env = *null;
        endmon;

        g_jnienv = env;
        return env;

      /end-free
     P attachJvm       e

      *****************************************************************
      * getClasspath - retreive the CLASSPATH environment variable
      *****************************************************************
     P getClasspath    B
     D getClasspath    PI         65535A   varying

      * See QSYSINC/H,QP0Z1170
     D Qp0zGetEnvNoInit...
     D                 PR              *   extproc('Qp0zGetEnvNoInit')
     D   name                          *   value options(*string)
     D envVarP         S               *
      /free
            envvarP = Qp0zGetEnvNoInit('CLASSPATH');
            if (envvarP = *NULL);
              return '';
            else;
              return %str(envvarP : 65535);
            endif;
      /end-free
     P getClasspath    E

      *****************************************************************
      * cvtToAscii - convert from EBCDIC to ASCII
      *****************************************************************
     P cvtToAscii      B
     D cvtToAscii      PI         65535A   varying
     D   input                    65535A   const varying
     D QDCXLATE        PR                  extpgm('QDCXLATE')
     D   len                          5P 0 const
     D   cnvData                  65535A   options(*varsize)
     D   cnvTbl                      10A   const
     D   cnvLib                      10A   const

     D retval          S                   like(input)
     D retvalRef       S              1A   based(retvalPtr)

      /free
           retval = input;
           retvalPtr = %addr(retval) + 2;  // set ptr after the length part
           QDCXLATE(%len(retval): retvalRef : 'QASCII': 'QSYS');
           return retval;
      /end-free

     P cvtToAscii      E

      *****************************************************************
      * free Java Object
      *****************************************************************
     p freeJavaObject  B
     D freeJavaObject  PI
     D  env                            *   const
     D  javaObject                     O   CLASS(*JAVA:'java.lang.Object')
     D                                     value
      /free
       JNIENV_P = env;
       If javaObject = *null or JNIEnv_P = *null;
         return;
       endif;
       DeleteLocalRef (JNIEnv_P:javaObject);
      /end-free
     p freeJavaObject  E

      *****************************************************************
      * begin object group
      *****************************************************************
     P beginObjGroup   B
     D beginObjGroup   PI
     D  env                            *   const
     D  capacity                     10I 0 value
     D rc              s             10I 0

      /free
       JNIENV_P = env;
       rc = pushLocalFrame (JNIENV_P : capacity);
      /end-free
     p beginObjGroup   E

      *****************************************************************
      * end a group of object
      *****************************************************************
     p endObjGroup     B
     D endObjGroup     PI
     D  env                            *   const
     D rc              s             10I 0
     D refobject       s               O   CLASS(*JAVA:'java.lang.Object')
     D newobject       s               O   CLASS(*JAVA:'java.lang.Object')
      /free
       JNIENV_P = env;
       refObject = *null;
       newObject = popLocalFrame (JNIENV_P : refObject);
      /end-free
     p endObjGroup     E

      *****************************************************************
      * destroyJVM */
      *****************************************************************
     P destroyJVM      B
     D destroyJVM      PI            10I 0
     D rc              S                   LIKE(jint)
     D rpgRc           S               N
     D jvm             S               *   DIM(1)
     D env             S               *
     D bufLen          S                   LIKE(jsize) INZ(%elem(jvm))
     D nVMs            S                   LIKE(jsize)
      /free
       // See if theres a JVM started
       rc = JNI_GetCreatedJavaVMs (jvm : bufLen : nVMs);
       // If JVM is started, destroy it
       if (rc = 0 and nVMs > 0);
         JavaVM_P = jvm(1);
         rc = DestroyJavaVM (jvm(1));
       endif;
       reset sndpgmmsg;
       if rc = 0;
         msgdata = 'JVM ended';
       else;
         msgdata = 'JVM NOT ended';
       endif;
       If jobi_type = 'I';
         msgtype = '*STATUS';
         msgmsgq = '*EXT';
         QMHSNDPM (msgid:msgfile:msgdata:msgdataL:msgtype:msgmsgq:
                   msgstack:msgkey:apierror);
         reset sndpgmmsg;
         rc = sleep(1);
       endif;
       return rc;
      /end-free
     P destroyJVM      E
