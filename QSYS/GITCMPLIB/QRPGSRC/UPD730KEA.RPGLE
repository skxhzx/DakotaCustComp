      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPD730KEA  Initialize Report Scheduling Options
     *  12 July 2019
     *  Kenneth Elder
     *
     *  Copied from UPD510MBa
     *
     *----------------------------------------------------------------
     *  Revisions
730 A*    07/12/19  KDE  7.30
     *      - Created. Program will create and initialize *MRCRPT
     *        options record for Report Scheduling
740 A*    04/24/20  KDE  7.40
     *      - Add monitor message to prevent duplicate key if exists
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     fwarehs    ip   e           k disk
     Foptions   uf a e           k disk

     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     * *MRCRPT Fields
     *
     *    OPIP    -  IP address for Tomcat Server
     *    OPPORT  -  IP Port for Tomcat Server
     *    OPDPRT  -  Default Printer (Used when one not supplied)
     *    OPGSDV  -  Ghostscript Device
     *    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
     *    OPDBSRC -  MRC Datasource for Report Calling to Use
     *    OPINCLDD-  Include Date in IFS filename
     *    OPINCLDT-  Include time in IFS filename
     *    OPRTDIR -  Include report name in IFS directory Structure
     *
     * Data structure
     *
     D opdata          ds
     D  opip                   1     15
     D  opport                16     20  0
     D  opdprt                21     30
     D  opgsdv                31     39
     D  opmusr                40     49
     d  opcpre                50     52
     d  opjobd                53     62
     d  opdbsrc               63     92
     d  opincldd              93     93
     d  opincldt              94     94
     d  oprptdir              95     95

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------


     *   Initialize and Create Report Sccheduling options

      /free
             opwhse=whcode;
             opcode='*MRCRPT';
             opip = *blanks;
             opport = *zero;
             opdprt = *blanks;
             opgsdv = 'ljet4';
             opmusr = 'BFCRPTS';
             opcpre = *blanks;
             opjobd =*blanks;
             opdbsrc =*blanks;
             opincldd ='Y';
             opincldt ='Y';
             oprptdir='N';
             monitor;
             write oprec;
             on-error;
             endmon;
      /end-free
