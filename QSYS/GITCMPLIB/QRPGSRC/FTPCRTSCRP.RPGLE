     F*----------------------------------------------------------------
     F*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     F*----------------------------------------------------------------
     F*
     F*  FTPCRTSCRP  Create FTP script
     F*  03 March 1999
     F*  Dave Sommerville
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
500 AF*  02/08/06  MLB  5.00
     F*    - Enh: Added support to program for type *ORD to build
     F*      export strings for two new files, EXPFORDB, EXPFORDE.
     F*
510 AF*  07/13/06  MLB  5.10
     F*    - Enh: Added client custom code support to program.
510aAF*  10/08/06  MLB  5.10a
     F*    - Enh: Added 6 new export parms to send back path
     F*      statements to calling program.
510bAF*  05/25/07  MLB  5.10b
     F*    - Enh: Added 1 new export parms to send back path
     F*      statements to calling program.
510cAF*  06/20/07  DAS  5.10c
     F*    - Enh: Added parms and logic for EXFORDP file.
520 AF*  02/19/08  RBD  5.20  P#00011
     F*    - Enh: Added parms and logic for EXPFORDASN file.
520aAF*  10/02/09  MLB  5.20a
     F*    - Enh: Updated documentation for new transfer type
     F*      code, *GOALTIM. Single file, EXPFCSAM will be sent.
640 AF*  08/09/12  LMC  6.40
     F*    - Enh: Added parms and logic for EXPFORDO file.
650aAF*  04/11/13  RTR  6.50
     F*    - Enh: Added logic for EXPFPOL file, *PO only, file L
650bAF*  04/21/13  RTR  6.50b
     F*    - Enh: Added logic for EXPFADJL file, file D
650cAF*  06/30/14  RTR  6.50c
     F*    - Enh: Added type *POSD for PO Smartdock export.
700aAF*  09/18/15  RTR  7.00a
     F*    - Enh: Changed 650b to be only for Greenleaf, if
     F*      EXPFADJL is needed it can be added for client to 700a.
     F*
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    07/07/06  MLB  PAK
     *      - Revised program to append '.idoc' onto end of
     *        &PRmtfileH variable when creating remote file name.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SGC A*    03/26/08  MLB  SGC
     *      - Revised program to write CHMOD 777 entries to FTP
     *        export script file to change authority to files on Host.
     *        This will be done for *PO and *ADJ commands.
SGCaA*    03/26/08  MLB  SGCa
     *      - Revised program to write out additional PUT cmd for
     *        export receiving exceptions file, EXPFPOE to send to Host.
     *        This will be done only for *PO command.
SGCbA*    09/26/13  MLB  SGCb
     *      - Revised program to write CHMOD 777 entries to FTP
     *        export script file to change authority to files on Host.
     *        This will be done for *ORD command.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett
     *
ELB A*    10/02/09  MLB  ELB
     *      - Revised program to not export EXPFORDASN, EXPFORDL
     *        to Host system. Per Don Kaufman.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Food Company
     *
FFC A*    04/08/10  MLB  FFC
     *      - Revised program to not export EXPFORDASN, EXPFORDL
     *        to Host system.
     *      - Added FFC to ELB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    07/29/11  MLB  CPC
     *      - Revised program when orders are being exported to re-
     *        direct them to folder, Inbox instead of INIB.
CPCaA*    10/28/11  MLB  CPCa
     *      - Revised program when item warehouse qty is exported to
     *        re-direct them to folder, INV instead of INIB.
CPCbA*    10/31/11  MLB  CPCb
     *      - Enhancement to CPCa mod. Revised pgm to write out "PUT"
     *        record for INIB folder as well as INV folder.
CPCcA*    11/09/11  RH   CPCc
     *      - Add *QTY2 item whse qty to export to folder INV.
CPCdA*    02/07/13  MLB  CPCd
     *      - Revised CPCb mod to add client code around mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    07/25/12  MLB  HMW
     *      - Revised program to not export EXPFORDASN to Host
     *        system.
     *      - Added HMW to ELB mod.
HMWb *    01/13/15  RTR  HMWb
     *      - Revised program to not export EXPFADJL to Host system.
HMWc *    08/12/15  RTR  HMWc
     *      - Revised program to not export EXPFORDO to Host system.
HMWdA*    09/21/18  MLB  HMWd
     *      - Revised program to not export EXPFPOL to Host system.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*  08/19/11  MLB  EI    P#01049
     *    - Enh: Updated documentation for export type *QTY.
     *      Item Warehouse Qty will now transmit 2 files:
     *      EXPFQTY and EXPFLCNS.
     *    - Note: Was 6.40 in EI's version. Changed to make client
     *            specific.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    01/31/13  MLB  GFS
     *      - Revised program to receive 2 parms from calling CL.
     *        These 2 parms will be used to complete export folder
     *        path. Client has 2 companies supported in one Dakota
     *        WMS warehouse. Items, purchase orders are prefixed with
     *        G=Get Fresh and F=Finale companies.
GFSaA*    09/26/13  MLB  GFSa
     *      - Revised program to not export EXPFORDASN
     *        to Host system.
     *      - Added GFSa to ELB mod. (partial)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*    03/01/13  MLB  GLP
     *    - Revised program to write CHMOD 666 entries to FTP
     *      export script file to change authority to files on Host.
     *      This will be done for all export cmds.
GLPbA*    04/21/13  RTR  GLPb
     *    - Revised program to write CHMOD 666 entries for License file
GLPcA*    09/25/13  RTR  GLPc
     *    - Revised program to write CHMOD 666 entries for all *ORD files
GLPdA*    02/09/15  MLB  GLPd
     *    - Revised program to make 6.50b mod client specific.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC Foodservice
     *
TPC A*    01/28/17  MLB  TPC
     *    - Revised program to not write rcds into FTP script file
     *      type export type = *ORD and remote file parm is blank for
     *      RmtFileB,E,L,P,A and F. TPC only exports H, D, C and T.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    09/18/15  RTR  SBRa
     *      - Revised program to not export EXPFORDASN.
     *        Added SBRa to GFSa mod.
     *      - Revised program to not export EXPFORDO.
SBRb *    11/11/15  RTR  SBRb
     *      - Added SBertram to EXPFADJL logic in 700a.
     *
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program creates the FTP script to send the export
     F*    file(s).  Before this program is called a new member must
     F*    be created in the FTPEXPSCRP file by copying the DEFAULT
     F*    member.
     F*
     F*    Within the DEFAULT script are variables which are enclosed
     F*    in '< >'.  There are five variables for 1) FTP server,
     F*    2) User id and password, 3) Local file name, 4) Remote path
     F*    and 5) Remote file name.  All of the variables are defined
     F*    below.  The variables in the DEFAULT member must match the
     F*    defined in this program.
     F*
     F*    The calling CL program is responsible for creating the
     F*    neccessary members and the local and remote file names.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FFTPEXPSCRPUF A E             DISK
411 AFOPTIONS   IF   E           K DISK
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
ELB A /COPY QCOPYSRC,ID#Ellenbe
SGC A /COPY QCOPYSRC,ID#SGC
PAK A /COPY QCOPYSRC,ID#packers
FFC A /COPY QCOPYSRC,ID#fischer
EI  A /COPY QCOPYSRC,ID#ei
CPC A /COPY QCOPYSRC,ID#cpc
HMW A /COPY QCOPYSRC,ID#HMWagne
GFS A /COPY QCOPYSRC,ID#gfs
GLP A /COPY QCOPYSRC,ID#glp
TPC A /COPY QCOPYSRC,ID#tpc
SBRaA /COPY qcopysrc,id#sbr
510 A*
     D*----------------------------------------------------------------
     D*  Variable/Constant definitions

     D A80             S              1A   Dim(80)
SGC A
SGC AD ChMod777var     C                   'QUO SITE CHMOD 777'
SGC AD ChMod777pos     S              3P 0
SGC AD ChMod777len     S              3P 0
SGC A
GLP AD ChMod666var     C                   'QUO SITE CHMOD 666'
GLP AD ChMod666pos     S              3P 0
GLP AD ChMod666len     S              3P 0
GLP A
     D Forever         S              1S 0
     D OrigSrc         S                   Like(SrcDta)
     D NewSeq          S                   Like(SrcSeq) Inz(.99)

     D LclVar          C                   '<LibraryName/FileName.MemberName>'
     D LclVarPos       S              3P 0
     D LclVarLen       S              3P 0

CPC AD pos             S              3s 0 inz(0)
     D PthVar          C                   '<RemotePathName>'
     D PthVarPos       S              3P 0
     D PthVarLen       S              3P 0

     D RmtVar          C                   '<RemoteFileName>'
     D RmtVarPos       S              3P 0
     D RmtVarLen       S              3P 0

     D SrvVar          C                   '<FTP Server>'
     D SrvVarPos       S              3P 0
     D SrvVarLen       S              3P 0

     D UsrPwd          S             30A
     D PathFile        S             45A

     D UsrVar          C                   '<UserName Password>'
     D UsrVarPos       S              3P 0
     D UsrVarLen       S              3P 0

411 AD*----------------------------------------------------------------
411 AD*  *FTP      -  FTP options
411 AD*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPFTP   -  Use FTP for exporting (Y,N)
     D*    OPSRVR  -  FTP Server name
     D*    OPUSER  -  FTP User id
     D*    OPPWD   -  FTP Password
     D*    OPPATH  -  Remote path name
     D*
     D* Data structure
     D*
     D OPDATA          DS
     D  OPFTP                  1      1
     D  OPSRVR                 2     33
     D  OPUSER                34     48
     D  OPPWD                 49     63
     D  OPPATH                64     95
     D  OPTEND               117    117

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PType  *ADJ      -  Adjustments
520aAC*              *GOALTIM  -  Goal time data
     C*              *INVCNT   -  Inventory counts
     C*              *ORD      -  Customer orders
     C*              *PO       -  Purchase orders
650cAC*              *POSD     -  PO Smartdock Appts
CPCc C*              *QTY      -  Quantity
EI  AC*              *QTY      -  Item warehouse quantity / Slot licenses
CPCc C*              *QTY2     -  Quantity-alpha
     C*              *RETURNS  -  Inventory counts
     C*      $PLclFileH  Local header file (All types)
EI  MC*      $PLclFileD  Local detail file (*ORD,*PO,*QTY)
     C*      $PLclFileC  Local catchweight file (*ORD)
     C*      $PLclFileT  Local transaction file (*ORD)
     C*      $PRmtFileH  Remote header file (All types)
EI  MC*      $PRmtFileD  Remote detail file (*ORD,*PO,*QTY)
     C*      $PRmtFileC  Remote catchweight file (*ORD)
     C*      $PRmtFileT  Remote transaction file (*ORD)
500 AC*      $PLclFileB  Local detail box code file (*ORD)
500 AC*      $PRmtFileB  Remote detail box code file (*ORD)
500 AC*      $PLclFileE  Local detail exp. date file (*ORD)
500 AC*      $PRmtFileE  Remote detail exp. date file (*ORD)
510bAC*      $PLclFileL  Local detail exp. label file (*ORD)
510bAC*      $PRmtFileL  Remote detail exp. label file (*ORD)
510dAC*      $PLclFileP  Local detail exp. piece file (*ORD)
510dAC*      $PRmtFileP  Remote detail exp. piece file (*ORD)
     C*
     C*      Note: Because this program must be compiled back to
     C*            V3R7M0, we must use the %SUBST command instead
     C*            of the V4R2M0 %REPLACE command.  Because of
     C*            this the file parameters must be the exact
     C*            size of the variable fields, including the
     C*            '< >' signs.
     C*
     C*    Returned Parameters
510aAC*      $PathH      Remote Header file path created by program.
510aAC*      $PathD      Remote Detail file path created by program.
510aAC*      $PathC      Remote C/Wgt file path created by program.
510aAC*      $PathT      Remote Tran file path created by program.
510aAC*      $PathB      Remote Box file path created by program.
510aAC*      $PathE      Remote Exp Date file path created by program.
510bAC*      $PathL      Remote Exp Label file path created by program.
510cAC*      $PathP      Remote Exp Piece file path created by program.
520 AC*      $PathA      Remote Exp ASN SSCC-18 file path created by program.
640 AC*      $PathF      Remote Exp Lot file path created by program.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PType            8
     C                   PARM                    $PLclFileH       33
     C                   PARM                    $PLclFileD       33
     C                   PARM                    $PLclFileC       33
     C                   PARM                    $PLclFileT       33
     C                   PARM                    $PRmtFileH       16
     C                   PARM                    $PRmtFileD       16
     C                   PARM                    $PRmtFileC       16
     C                   PARM                    $PRmtFileT       16
500 AC                   PARM                    $PLclFileB       33
500 AC                   PARM                    $PRmtFileB       16
500 AC                   PARM                    $PLclFileE       33
500 AC                   PARM                    $PRmtFileE       16
510 AC                   PARM                    $Ppathh          45
510 AC                   PARM                    $Ppathd          45
510 AC                   PARM                    $Ppathc          45
510 AC                   PARM                    $Ppatht          45
510 AC                   PARM                    $Ppathb          45
510 AC                   PARM                    $Ppathe          45
510bAC                   PARM                    $PLclFileL       33
510bAC                   PARM                    $PRmtFileL       16
510bAC                   PARM                    $PpathL          45
510cAC                   PARM                    $PLclFileP       33
510cAC                   PARM                    $PRmtFileP       16
510cAC                   PARM                    $PpathP          45
520 AC                   PARM                    $PLclFileA       33
520 AC                   PARM                    $PRmtFileA       16
520 AC                   PARM                    $PpathA          45
640 AC                   PARM                    $PLclFileF       33
640 AC                   PARM                    $PRmtFileF       16
640 AC                   PARM                    $PpathF          45
GFS AC                   PARM                    $Pcmpid           1
GFS AC                   PARM                    $Pcmpnbr          2
     C*----------------------------------------------------------------
     C* Main line
411 AC*
411 AC*   Get FTP options from options file.
411 AC*
     C                   eval      OpWhse = 0

650cAC                   select
650cAC                   when      $pType = '*POSD'
650cAC                   eval      OpCode = '*FTPPOSD'
650cAC                   other
     C                   eval      OpCode = '*FTP'
650cAC                   endsl

411 AC     KeyOp         chain     Options                            79
     C                   if        *IN79 = *ON
     C                   eval      OpPath = '\*NotDefined*\'
     C                   eval      OpUser = '*NotDefined*'
     C                   eval      OpPwd  = '*NotDefined*'
411 AC                   endif
CPC AC*
CPC AC                   if        client = cpc
CPC AC
CPCaAC                   select
CPCaMC                   when      $ptype = '*ORD'
CPC AC*      Re-direct export order files to different folder.
CPC AC                   eval      pos = %scan('/INIB/':oppath)
CPC AC                   eval      oppath = %replace('/Inbox/':oppath:pos:7)
CPC AC
CPCcMC                   when      $ptype = '*QTY2'
CPCcAC*      Re-direct export order files to different folder.
CPCcAC                   eval      pos = %scan('/INV/':oppath)
CPCcAC                   eval      oppath = %replace('/Inbox/':oppath:pos:7)
CPC AC
CPCaMC                   endsl
CPC AC
CPC AC                   endif
GFS AC*
GFS AC                   if        client = getfresh
GFS AC
GFS AC                   if        %parms >= 32
GFS AC                   eval      oppath = %trim(oppath)
GFS AC                                      + $Pcmpid
GFS AC                                      + $Pcmpnbr
GFS AC                                      + '/'
GFS AC                   endif
GFS AC                   endif
     C*
     C*  Loop through source records
     C*
     C     Forever       doweq     Forever
     C                   read      FtpExpScrp                             79
     C                   if        *IN79 = *ON or SrcSeq = 1.99
     C*                  if        %Eof          (%EOF started in V4R2)
     C                   leave
     C                   endif
     C*
     C*     Save original source data
     C*
     C                   eval      OrigSrc = SrcDta
     C*
     C*     Delete original line (sequential file)
     C*
     C                   delete    FtpExpScrp
     C*
     C*     Skip comment lines - Don't write back into member.
     C*
     C                   if        %Subst(OrigSrc:1:1) = '*'
     C                   iter
     C                   endif
     C*
     C*     Check for 'Server' line
     C*
     C                   eval      SrvVarPos = %Scan(SrvVar:OrigSrc)
     C                   if        SrvVarPos > 0
     C                   exsr      ServerLine
     C                   iter
     C                   endif
     C*
     C*     Check for 'User' line
     C*
     C                   eval      UsrVarPos = %Scan(UsrVar:OrigSrc)
     C                   if        UsrVarPos > 0
     C                   exsr      UserLine
     C                   iter
     C                   endif
     C*
     C*     Check for 'Put' line
     C*
     C                   eval      LclVarPos = %Scan(LclVar:OrigSrc)
     C                   if        LclVarPos > 0
     C                   exsr      PutLine
     C                   iter
     C                   endif
SGC AC*
SGC AC*     Check for 'CHMOD 777 line.
SGC AC*
SGC AC                   if        client = SGC
SGC AC
SGC AC                   if           $ptype = '*PO'
SGC AC                             or $ptype = '*ADJ'
SGC AC                             or $ptype = '*RETURNS'
SGCbAC                             or $ptype = '*ORD'
650cAC                             or $ptype = '*POSD'
SGC AC                   eval      ChMod777pos = %Scan(ChMod777var:OrigSrc)
SGC AC                   if        ChMod777pos > 0
SGC AC                   exsr      ChMod777
SGC AC                   iter
SGC AC                   endif
SGC AC                   endif
SGC AC
SGC AC                   endif
GLP AC*
GLP AC*     Check for 'CHMOD 666 line.
GLP AC*
GLP AC                   if        client = Greenleaf
GLP AC
GLP AC                   eval      ChMod666pos = %Scan(ChMod666var:OrigSrc)
GLP AC                   if        ChMod666pos > 0
GLP AC                   exsr      ChMod666
GLP AC                   iter
GLP AC                   endif
GLP AC
GLP AC                   endif
     C*
     C*     Otherwise, just write out record changing the seq#
     C*
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
     C*
     C                   enddo
     C*
     C*  We are finished so get out
     C*
     C                   eval      *INLR = *ON
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine.
     C*
     C     *INZSR        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
510 A*
411 AC*
411 AC*  Define key for options file.
411 AC*
411 AC     KEYOP         KLIST
411 AC                   KFLD                    OPWHSE
411 AC                   KFLD                    OPCODE
     C*
     C*   Calculate lengths of variable fields
     C*
     C                   eval      LclVarLen = %Len(LclVar)
     C                   eval      PthVarLen = %Len(PthVar)
     C                   eval      RmtVarLen = %Len(RmtVar)
     C                   eval      SrvVarLen = %Len(SrvVar)
     C                   eval      UsrVarLen = %Len(UsrVar)
     C*
     C                   endsr
GLP AC*
GLP AC*----------------------------------------------------------------
GLP AC*  ChMod666  -  Create 'ChMod 666' lines
GLP AC*
GLP AC     ChMod666      begsr
GLP AC*
GLP AC*     Create ChMod 666 cmd for Header file.
GLP AC                   eval      SrcDta = %trim(origsrc)
GLP AC                                      + ' '
GLP AC                                      + %trim(oppath)
GLP AC                                      + %trim($PRmtFileH)
GLP AC                   eval      NewSeq = NewSeq + 1
GLP AC                   eval      SrcSeq = NewSeq
GLP AC                   write     FtpExpScr
GLP AC*
GLP AC*     Create ChMod 666 cmd for Detail file.
GLP AC                   select
GLP AC                   when         $ptype = '*PO'
GLP AC                   eval      SrcDta = %trim(origsrc)
GLP AC                                      + ' '
GLP AC                                      + %trim(oppath)
GLP AC                                      + %trim($PRmtFileD)
GLP AC                   eval      NewSeq = NewSeq + 1
GLP AC                   eval      SrcSeq = NewSeq
GLP AC                   write     FtpExpScr
GLP AC*
GLP AC*     Create ChMod 666 cmd for Exception detail file.
GLPbAC                   if        $PRmtFileE <> *blanks
GLP AC                   eval      SrcDta = %trim(origsrc)
GLP AC                                      + ' '
GLP AC                                      + %trim(oppath)
GLP AC                                      + %trim($PRmtFileE)
GLP AC                   eval      NewSeq = NewSeq + 1
GLP AC                   eval      SrcSeq = NewSeq
GLP AC                   write     FtpExpScr
GLPbAC                   endif
GLP AC*
GLPbAC*     Create ChMod 666 cmd for License detail file.
GLPbAC                   if        $PRmtFileL <> *blanks
GLPbAC                   eval      SrcDta = %trim(origsrc)
GLPbAC                                      + ' '
GLPbAC                                      + %trim(oppath)
GLPbAC                                      + %trim($PRmtFileL)
GLPbAC                   eval      NewSeq = NewSeq + 1
GLPbAC                   eval      SrcSeq = NewSeq
GLPbAC                   write     FtpExpScr
GLPbAC                   endif
GLPbAC*
650bAC*     Create ChMod 666 cmd for Detail file - Adjustments
650bAC                   when         $ptype = '*ADJ'
GLPdAC                                and client = Greenleaf
650bAC                   eval      SrcDta = %trim(origsrc)
650bAC                                      + ' '
650bAC                                      + %trim(oppath)
650bAC                                      + %trim($PRmtFileD)
650bAC                   eval      NewSeq = NewSeq + 1
650bAC                   eval      SrcSeq = NewSeq
650bAC                   write     FtpExpScr
650bAC*
GLPcAC*     Create ChMod 666 cmd for Detail file.
GLPcAC                   when      $ptype = '*ORD'
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileD)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for Exception detail file.
GLPcAC                   if        $PRmtFileE <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileE)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for License detail file.
GLPcAC                   if        $PRmtFileL <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileL)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for C file.
GLPcAC                   if        $PRmtFileC <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileC)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for T file.
GLPcAC                   if        $PRmtFileT <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileT)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for B file.
GLPcAC                   if        $PRmtFileB <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileB)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for P file.
GLPcAC                   if        $PRmtFileP <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileP)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for A file.
GLPcAC                   if        $PRmtFileA <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileA)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLPcAC*     Create ChMod 666 cmd for F file.
GLPcAC                   if        $PRmtFileF <> *blanks
GLPcAC                   eval      SrcDta = %trim(origsrc)
GLPcAC                                      + ' '
GLPcAC                                      + %trim(oppath)
GLPcAC                                      + %trim($PRmtFileF)
GLPcAC                   eval      NewSeq = NewSeq + 1
GLPcAC                   eval      SrcSeq = NewSeq
GLPcAC                   write     FtpExpScr
GLPcAC                   endif
GLPcAC*
GLP AC                   endsl
GLP AC*
GLP AC                   endsr
SGC AC*
SGC AC*----------------------------------------------------------------
SGC AC*  ChMod777  -  Create 'ChMod 777' lines
SGC AC*
SGC AC     ChMod777      begsr
SGC AC*
SGC AC*     Create ChMod 777 cmd for Header file.
SGC AC                   If           $ptype = '*PO'
SGC AC                             or $ptype = '*ADJ'
SGC AC                             or $ptype = '*RETURNS'
SGCbAC                             or $ptype = '*ORD'
650cAC                             or $ptype = '*POSD'
SGC AC                   eval      SrcDta = %trim(origsrc)
SGC AC                                      + ' '
SGC AC                                      + %trim(oppath)
SGC AC                                      + %trim($PRmtFileH)
SGC AC                   eval      NewSeq = NewSeq + 1
SGC AC                   eval      SrcSeq = NewSeq
SGC AC                   write     FtpExpScr
SGC AC                   endif
SGC AC*
SGC AC*     Create ChMod 777 cmd for Detail file.
SGC AC                   If           $ptype = '*PO'
650bAC                             or $ptype = '*ADJ'
GLPdAC                                and client = Greenleaf
SGCbAC                             or $ptype = '*ORD'
SGC AC                   eval      SrcDta = %trim(origsrc)
SGC AC                                      + ' '
SGC AC                                      + %trim(oppath)
SGC AC                                      + %trim($PRmtFileD)
SGC AC                   eval      NewSeq = NewSeq + 1
SGC AC                   eval      SrcSeq = NewSeq
SGC AC                   write     FtpExpScr
SGC AC*
SGC AC                   endif
SGCaAC*
SGCaAC*     Create ChMod 777 cmd for Rcv Exception file.
SGCaAC                   If           $ptype = '*PO'
SGCbAC                             or $ptype = '*ORD'
SGCaAC                   eval      SrcDta = %trim(origsrc)
SGCaAC                                      + ' '
SGCaAC                                      + %trim(oppath)
SGCaAC                                      + %trim($PRmtFileE)
SGCaAC                   eval      NewSeq = NewSeq + 1
SGCaAC                   eval      SrcSeq = NewSeq
SGCaAC                   write     FtpExpScr
SGCaAC*
SGCaAC                   endif
SGCbAC*
SGCbAC*     Create ChMod 777 cmd for Customer Orders files.
SGCbAC                   If           $ptype = '*ORD'
SGCbAC*
SGCbAC                   eval      SrcDta = %trim(origsrc)
SGCbAC                                      + ' '
SGCbAC                                      + %trim(oppath)
SGCbAC                                      + %trim($PRmtFileC)
SGCbAC                   eval      NewSeq = NewSeq + 1
SGCbAC                   eval      SrcSeq = NewSeq
SGCbAC                   write     FtpExpScr
SGCbAC*
SGCbAC                   eval      SrcDta = %trim(origsrc)
SGCbAC                                      + ' '
SGCbAC                                      + %trim(oppath)
SGCbAC                                      + %trim($PRmtFileT)
SGCbAC                   eval      NewSeq = NewSeq + 1
SGCbAC                   eval      SrcSeq = NewSeq
SGCbAC                   write     FtpExpScr
SGCbAC*
SGCbAC                   eval      SrcDta = %trim(origsrc)
SGCbAC                                      + ' '
SGCbAC                                      + %trim(oppath)
SGCbAC                                      + %trim($PRmtFileB)
SGCbAC                   eval      NewSeq = NewSeq + 1
SGCbAC                   eval      SrcSeq = NewSeq
SGCbAC                   write     FtpExpScr
SGCbAC*
SGCbAC                   eval      SrcDta = %trim(origsrc)
SGCbAC                                      + ' '
SGCbAC                                      + %trim(oppath)
SGCbAC                                      + %trim($PRmtFileL)
SGCbAC                   eval      NewSeq = NewSeq + 1
SGCbAC                   eval      SrcSeq = NewSeq
SGCbAC                   write     FtpExpScr
SGCbAC*
SGCbAC                   eval      SrcDta = %trim(origsrc)
SGCbAC                                      + ' '
SGCbAC                                      + %trim(oppath)
SGCbAC                                      + %trim($PRmtFileP)
SGCbAC                   eval      NewSeq = NewSeq + 1
SGCbAC                   eval      SrcSeq = NewSeq
SGCbAC                   write     FtpExpScr
SGCbAC*
SGCbAC                   eval      SrcDta = %trim(origsrc)
SGCbAC                                      + ' '
SGCbAC                                      + %trim(oppath)
SGCbAC                                      + %trim($PRmtFileA)
SGCbAC                   eval      NewSeq = NewSeq + 1
SGCbAC                   eval      SrcSeq = NewSeq
SGCbAC                   write     FtpExpScr
SGCbAC*
SGCbAC                   endif
SGC AC*
SGC AC                   endsr
SGC AC*
     C*----------------------------------------------------------------
     C*  PutLine  -  Create 'Put' lines
     C*
     C*   Example of %REPLACE which wasn't introduced until V4R2M0.
     C*
     C*                  eval      SrcDta = %Replace($PLclFileH:SrcDta:
     C*                                               LclVarPos:LclVarLen)
     C*
     C     PutLine       begsr
     C*
     C*    Get position of remote path name or remote file name.
     C*
     C                   eval      PthVarPos = %Scan(PthVar:OrigSrc)
     C                   if        PthVarPos > 0
     C                   eval      RmtVarPos = PthVarPos
     C                   else
     C                   eval      RmtVarPos = %Scan(RmtVar:OrigSrc)
     C                   eval      OpPath = ' '
     C                   endif
     C*
     C*    Add source line with header file (All types)
     C*
     C                   eval      SrcDta = OrigSrc
     C                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileH
     C                   movea     SrcDta        A80
     C                   eval      PathFile = %TrimR(OpPath) + $PRmtFileH
PAK AC*
PAK AC                   if        client = packers
PAK AC                   eval      PathFile = %TrimR(Pathfile) + '.idoc'
510aAC                   eval      $ppathh  = pathfile
PAK AC                   endif
     C                   movea     PathFile      A80(RmtVarPos)
     C                   movea     A80           SrcDta
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
CPCbAC*
CPCdAC                   if        client = cpc
CPCbAC                   select
CPCbAC                   when      $ptype = '*QTY'
CPCbAC*      Send copy of export item qty files to different folder.
CPCbAC                   eval      pos = %scan('/INIB/':oppath)
CPCbAC                   eval      oppath = %replace('/INV/':oppath:pos:7)
CPCbAC                   movea     SrcDta        A80
CPCbAC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileH
CPCbAC                   movea     PathFile      A80(RmtVarPos)
CPCbAC                   movea     A80           SrcDta
CPCbAC                   eval      NewSeq = NewSeq + 1
CPCbAC                   eval      SrcSeq = NewSeq
CPCbAC                   write     FtpExpScr
CPCbAC                   endsl
CPCdAC                   endif
PAK AC*
PAK AC                   if        client = packers
PAK AC*      Packer's will only send one export file to SAP.
PAK AC                   goto      endputline
PAK AC                   endif
     C*
     C*    Add source line with detail file (*ORD & *PO only)
     C*
     C                   if        $ptype = '*ORD' or $ptype = '*PO'
650bAC                             or $ptype = '*ADJ'
GLPdAC                               and client = Greenleaf
EI  AC                             or $ptype = '*QTY'
EI  AC                               and client = EI
     C                   eval      SrcDta = OrigSrc
     C                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileD
     C                   movea     SrcDta        A80
     C                   eval      PathFile = %TrimR(OpPath) + $PRmtFileD
510aAC                   eval      $ppathd  = pathfile
     C                   movea     PathFile      A80(RmtVarPos)
     C                   movea     A80           SrcDta
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
     C                   endif
700aAC*
700aAC*    Add source line with detail file (*ADJ only - EXPFADJL)
700aAC*
700aAC                   if        $ptype = '*ADJ'
SBRbDC**                           and client = Greenleaf
SBRbMC                   if        client = Greenleaf
SBRbAC                             or client = SBertram
700aAC                   eval      SrcDta = OrigSrc
700aAC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileD
700aAC                   movea     SrcDta        A80
700aAC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileD
700aAC                   eval      $ppathd  = pathfile
700aAC                   movea     PathFile      A80(RmtVarPos)
700aAC                   movea     A80           SrcDta
700aAC                   eval      NewSeq = NewSeq + 1
700aAC                   eval      SrcSeq = NewSeq
700aAC                   write     FtpExpScr
SBRbAC                   endif
700aAC                   endif
     C*
     C*    Add source lines with catchweigt and transaction files (*ORD only)
     C*
     C                   if        $ptype = '*ORD'
     C                   eval      SrcDta = OrigSrc
     C                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileC
     C                   movea     SrcDta        A80
     C                   eval      PathFile = %TrimR(OpPath) + $PRmtFileC
510aAC                   eval      $ppathc  = pathfile
     C                   movea     PathFile      A80(RmtVarPos)
     C                   movea     A80           SrcDta
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
     C*
     C                   eval      SrcDta = OrigSrc
     C                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileT
     C                   movea     SrcDta        A80
     C                   eval      PathFile = %TrimR(OpPath) + $PRmtFileT
510aAC                   eval      $ppatht  = pathfile
     C                   movea     PathFile      A80(RmtVarPos)
     C                   movea     A80           SrcDta
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
500 AC*
500 AC*     Export detail box codes.
TPC AC                   if        client = TPC
TPC A*       Do not send file to Host
TPC AC                   else
TPC A*
500 AC                   eval      SrcDta = OrigSrc
500 AC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileB
500 AC                   movea     SrcDta        A80
500 AC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileB
510aAC                   eval      $ppathb  = pathfile
500 AC                   movea     PathFile      A80(RmtVarPos)
500 AC                   movea     A80           SrcDta
500 AC                   eval      NewSeq = NewSeq + 1
500 AC                   eval      SrcSeq = NewSeq
500 AC                   write     FtpExpScr
TPC AC                   endif
TPC A*
500 AC*
500 AC*     Export detail expiration dates.
TPC AC                   if        client = TPC
TPC A*       Do not send file to Host
TPC AC                   else
TPC A*
500 AC                   eval      SrcDta = OrigSrc
500 AC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileE
500 AC                   movea     SrcDta        A80
500 AC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileE
510aAC                   eval      $ppathe  = pathfile
500 AC                   movea     PathFile      A80(RmtVarPos)
500 AC                   movea     A80           SrcDta
500 AC                   eval      NewSeq = NewSeq + 1
500 AC                   eval      SrcSeq = NewSeq
500 AC                   write     FtpExpScr
TPC AC                   endif
TPC A*
500 AC*
510bAC*
510bAC*     Export detail label records.
ELB AC*
ELB AC                   if        client = Ellenbee
HMW AC                             or client = HMWagner
TPC AC                             or client = TPC
FFC AC                             or client = Fischerfoods
ELBbAC*       Do not export EXPFORDL file to Host.
ELB AC                   else
ELB AC*
510bAC                   eval      SrcDta = OrigSrc
510bAC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileL
510bAC                   movea     SrcDta        A80
510bAC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileL
510bAC                   eval      $ppathL  = pathfile
510bAC                   movea     PathFile      A80(RmtVarPos)
510bAC                   movea     A80           SrcDta
510bAC                   eval      NewSeq = NewSeq + 1
510bAC                   eval      SrcSeq = NewSeq
510bAC                   write     FtpExpScr
ELB AC*
ELB AC                   endif
510bAC*
510cAC*
510cAC*     Export detail piece records.
TPC AC                   if        client = TPC
TPC A*       Do not send file to Host
TPC AC                   else
TPC A*
510cAC                   eval      SrcDta = OrigSrc
510cAC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileP
510cAC                   movea     SrcDta        A80
510cAC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileP
510cAC                   eval      $ppathP  = pathfile
510cAC                   movea     PathFile      A80(RmtVarPos)
510cAC                   movea     A80           SrcDta
510cAC                   eval      NewSeq = NewSeq + 1
510cAC                   eval      SrcSeq = NewSeq
510cAC                   write     FtpExpScr
TPC AC                   endif
TPC A*
510cAC*
520 AC*
520 AC*     Export order detail ASN SSCC-18 records.
ELB AC*
ELB AC                   if        client = Ellenbee
FFC AC                             or client = Fischerfoods
GFSaAC                             or client = Getfresh
TPC AC                             or client = TPC
SBRaAC                             or client = SBertram
GFSaMC*       Do not export EXPFORDASN file to Host.
ELB AC                   else
ELB AC*
520 AC                   eval      SrcDta = OrigSrc
520 AC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileA
520 AC                   movea     SrcDta        A80
520 AC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileA
520 AC                   eval      $ppathA  = pathfile
520 AC                   movea     PathFile      A80(RmtVarPos)
520 AC                   movea     A80           SrcDta
520 AC                   eval      NewSeq = NewSeq + 1
520 AC                   eval      SrcSeq = NewSeq
520 AC                   write     FtpExpScr
ELB AC*
ELB AC                   endif
640 AC*
640 AC*     Export order detail lot records.
SBRaAC*
SBRaAC                   if        client = SBertram
HMWcAC                             or client = HMWagner
TPC AC                             or client = TPC
SBRaAC*       Do not export EXPFORDO file to Host.
SBRaAC*
SBRaAC                   else
SBRaAC*       Export EXPFORDO file to Host.
640 AC                   eval      SrcDta = OrigSrc
640 AC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileF
640 AC                   movea     SrcDta        A80
640 AC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileF
640 AC                   eval      $ppathF  = pathfile
640 AC                   movea     PathFile      A80(RmtVarPos)
640 AC                   movea     A80           SrcDta
640 AC                   eval      NewSeq = NewSeq + 1
640 AC                   eval      SrcSeq = NewSeq
640 AC                   write     FtpExpScr
SBRaAC                   endif
     C*
     C                   endif
SGCaAC*
SGCaAC*    Add source line with P/O Rcv Exception file (*PO only)
SGCaAC*
SGCaAC                   if        client = SGC
SGCaAC*
SGCaAC                   if        $ptype = '*PO'
SGCaAC                   eval      SrcDta = OrigSrc
SGCaAC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileE
SGCaAC                   movea     SrcDta        A80
SGCaAC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileE
SGCaAC                   movea     PathFile      A80(RmtVarPos)
SGCaAC                   movea     A80           SrcDta
SGCaAC                   eval      NewSeq = NewSeq + 1
SGCaAC                   eval      SrcSeq = NewSeq
SGCaAC                   write     FtpExpScr
SGCaAC                   endif
SGCaAC*
SGCaAC                   endif
     C*
650aAC*    Add source line with P/O Rcv License file (*PO only)
650aAC*
650aAC                   if        $ptype = '*PO'
SBRaAC*
HMWdAC                   if        client = HMWagner
HMWdAC*       Do not export EXPFPOL file to Host.
HMWdAC*
HMWdAC                   else
HMWdAC*       Export EXPFPOL file to Host.
650aAC                   eval      SrcDta = OrigSrc
650aAC                   eval      %Subst(SrcDta:LclVarPos:LclVarLen)=$PLclFileL
650aAC                   movea     SrcDta        A80
650aAC                   eval      PathFile = %TrimR(OpPath) + $PRmtFileL
650aAC                   movea     PathFile      A80(RmtVarPos)
650aAC                   movea     A80           SrcDta
650aAC                   eval      NewSeq = NewSeq + 1
650aAC                   eval      SrcSeq = NewSeq
650aAC                   write     FtpExpScr
HMWdAC                   endif
HMWdAC*
650aAC                   endif
     C*
PAK AC     Endputline    tag
     C                   endsr
     C*----------------------------------------------------------------
     C*  ServerLine  -  Replace server variable with FTP Server name
     C*
     C     ServerLine    begsr
     C                   movea     SrcDta        A80
     C                   movea     OpSrvr        A80(SrvVarPos)
     C                   movea     A80           SrcDta
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
     C                   endsr
     C*----------------------------------------------------------------
     C*  UserLine  -  Replace user variable with user id and password
     C*
     C     UserLine      begsr
     C                   movea     SrcDta        A80
     C                   eval      UsrPwd = %TrimR(OpUser) + ' ' + OpPwd
     C                   movea     UsrPwd        A80(UsrVarPos)
     C                   movea     A80           SrcDta
     C                   eval      NewSeq = NewSeq + 1
     C                   eval      SrcSeq = NewSeq
     C                   write     FtpExpScr
     C                   endsr
