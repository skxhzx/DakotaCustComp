      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSTRAX  OPS *TRAX Upd - Pgm for SQL procedure of same name
     *  09 March 2018
     *  Retha Davis
     *
     *  Revisions:
     *
720 A*    03/09/18  RBD  7.20
     *      - Created.
     *
720aA*    04/03/18  RBD  7.20a
     *      - Don't overlay options in fillrec that aren't passed in.
     *
720bA*    04/04/18  KDE  7.20b
     *      - Update several *TRAX and *TRAX2 values
     *
730aA*    03/20/19  RBD  7.30a
     *      - Added new *TRAX, *TRAX2 and *TRAX3 options.
     *
740aA*    11/02/20  RBD  7.40a
     *      - Added *TRAX/optraxinv and *TRAX2/optsyg.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*TRAX')

720bAD oprec2        E ds                  extname(options) inz(*EXTDFT)
720bAD                                     prefix(t_)
720bAD  optionCode2    s             10    inz('*TRAX2')

730aAD oprec3        E ds                  extname(options) inz(*EXTDFT)
730aAD                                     prefix(t3_)
730aAD  optionCode3    s             10    inz('*TRAX3')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D  phst           s              3  0
     D  psli           s              1
     D  pcwr           s              1
     D  poft           s              1
     D  pdft           s              1
     D  prft           s              1
     D  pcap           s              1
     D  pdbl           s              1
     D  pekd           s              1
     D  pdar           s              1
     D  pidb           s              1
     D  pbda           s              1
     D  pgbd           s              1
     D  prtq           s              1
     D  potq           s              1
     D  pcce           s              1
     D  psig           s              1
     D  ppiv           s              1
     D  psda           s              1
     D  pwsp           s              5  0
     D  pwsi           s             15
     D  psvd           s              2  0
     D  pert           s              4
     D  pedv           s             10
     D  peos           s             10
     D  pesw           s              4  0
     D  pesh           s              4  0
     D  pare           s              1
     D  pidl           s              1
     D  pdci           s              1
     D  ppal           s              1
     D  pcra           s              1
     D  pdrv           s              1
     D  pbul           s              1
     D  peys           s              1
     D  psas           s              1
     D  psdl           s              2  0
     D  psdt           s              1
     D  plrk           s              1
     D  pgss           s              1
     D  pgsu           s              1
     D  psbv           s              1  0
     D  prag           s              1
     D  prd            s              1
     D  prdt           s              4  0
     D  prfp           s              1
     D  prfm           s              1
     D  pnsr           s              1
     D  pfbd           s              1
     D  pdsf           s              1
730aAD  psor           s              1
730aAD  pode           s              1
730aAD  podp           s              2  0
730aAD  pont           s              1
730aAD  potp           s              1
730aAD  pnsb           s              1
720bAD  pdir           s             20
720bAD  piu            s             10
730aAD  psvl           s              1
730aAD  pssp           s              1
730aAD  psss           s              1
730aAD  psst           s              1
730aAD  pmul           s              1
730aAD  pkpl           s              1
730aAD  pshl           s              1
730aAD  pprt           s              1
730aAD  pspk           s              1
730aAD  pgps           s              1
730aAD  pmin           s              3  0
730aAD  pmet           s              6  0
730aAD  ppwd           s             20
730aAD  poff           s              2  0
730aAD  paut           s              1
730aAD  pph1           s             10  0
730aAD  pph2           s             10  0
730aAD  pcam           s              1
730aAD  pdil           s              1
730aAD  pdip           s              1
730aAD  purl           s             60
740aAD  psyg           s              1
740aAD  ptrinv         s              1

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D logText         s            100

     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *    OPTIDL  -  Icon delivery
     *    OPTDCI  -  Double click icons
     *    OPTPAL  -  Pallets enabled
     *    OPTCRA  -  Cradle upload enabled
     *    OPTDRV  -  Driver assigned before download
     *    OPTBUL  -  Bulk items enabled
     *    OPTEYS  -  Display empty stops
     *    OPTSAS  -  Save after scan
     *    OPTSDL  -  Save delay
     *    OPTSDT  -  Sync date and time
     *    OPTLRK  -  Left/right keys enabled
     *    OPTGSS  -  GS1 scanning
     *    OPTGSU  -  GS1 unique
     *    OPTSBV  -  Scan beep volume
     *    OPTRAG  -  Restart after get route.
     *    OPTRD   -  Restart daily.
     *    OPTRDT  -  Restart daily time.
     *    OPTRFP  -  Reader focus position.
     *    OPTRFM  -  Reader focus mode.
     *    OPTNSR  -  Non scan reason prompt.
     *    OPTFBD  -  Filter by department.
     *    OPTDSF  -  Display stop flags before restart.
730aA*    OPTSOR  -  Sort items by compartment Y/N.
730aA*    OPTODE  -  Customer on site delivery enable Y/N.
730aA*    OPTODP  -  Customer on site delivery verification period, 5-60.
730aA*    OPTONT  -  On truck picking Y/N.
730aA*    OPTOTP  -  Override truck picking Y/N.
730aA*    OPTNSB  -  No signee button on signature screen Y/N.
740aA*    OPTRAXINV - 1 = Print all invoices
740aA*                2 = Print pristine invoices only
740aA*                3 = Print non-pristine invoices only
740aA*                9 = Print no invoices
     *
     * Data structure
     *
     D optionRec       ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  optidl                77     77
     D  optdci                78     78
     D  optpal                79     79
     D  optcra                80     80
     D  optdrv                81     81
     D  optbul                82     82
     D  opteys                83     83
     D  optsas                84     84
     D  optsdl                85     86  0
     D  optsdt                87     87
     D  optlrk                88     88
     D  optgss                89     89
     D  optgsu                90     90
     D  optsbv                91     91  0
     D  optrag                92     92
     D  optrd                 93     93
     D  optrdt                94     97  0
     D  optrfp                98     98
     D  optrfm                99     99
     D  optnsr               100    100
     D  optfbd               101    101
     D  optdsf               102    102
730aAD  optsor               103    103
730aAD  optode               104    104
730aAD  optodp               105    106  0
730aAD  optont               107    107
730aAD  optotp               108    108
730aAD  optnsb               109    109
740aAD  optraxinv            110    110
     D  optend               117    117
     *----------------------------------------------------------------
     *  *TRAX2  -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
710bA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710bA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710cA*    OPTDIR  -  IFS main directory
710dA*    OPTIU   -  IFS user
730aA*    OPTOSIG -  Create Customer Order Signatures (Default = N)
730aA*               OPTOSG add for compatability with OPTIONSDS
730aA*    OPTSVL  -  Save login info Y/N.
730aA*    OPTSSP  -  Send stop pictures enable Y/N.
730aA*    OPTSSS  -  Send stop signatures enable Y/N.
730aA*    OPTSST  -  Send stop Trax log enable Y/N.
730aA*    OPTMUL  -  Multi route enable Y/N.
730aA*    OPTKPL  -  Keep log info Y/N.
730aA*    OPTSHL  -  Show log info Y/N.
730aA*    OPTPRT  -  Enable printer Y/N.
730aA*    OPTSPK  -  Enable speak Y/N.
730aA*    OPTGPS  -  Enable GPS Y/N.
730aA*    OPTMIN  -  GPS probe period minutes, greater than 0.
730aA*    OPTMET  -  GPS probe distance meters, greater than 0.
730aA*               Entered in yards, converted to meters.
730aA*    OPTPWD  -  Admin password.
730aA*    OPTOFF  -  Admin password encryption offset.
730aA*    OPTAUT  -  App auto update Y/N.
730aA*    OPTPH1  -  Company phone number.
730aA*    OPTPH2  -  Dispatch phone number for texting.
730aA*    OPTCAM  -  Camera barcode scanner Y/N.
730aA*    OPTDIL  -  Disable driver id login validation Y/N.
730aA*    OPTDIP  -  Disable driver password login validation Y/N.
740aA*    OPTSYG  -  Sygic Truck Integration Y/N.
     *
     * Data structure
     *
     D optionRec2      ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
710bAD  optv12                18     18
710bAD  optv20                19     19
710cAD  optdir                20     39
710dAD  optiu                 40     49
730aAD  optosg                50     50
730aAD  optosig               50     50
730aAD  optsvl                51     51
730aAD  optssp                52     52
730aAD  optsss                53     53
730aAD  optsst                54     54
730aAD  optmul                55     55
730aAD  optkpl                56     56
730aAD  optshl                57     57
730aAD  optprt                58     58
730aAD  optspk                59     59
730aAD  optgps                60     60
730aAD  optmin                61     63  0
730aAD  optmet                64     69  0
730aAD  optpwd                70     89
730aAD  optoff                90     91  0
730aAD  optaut                92     92
730aAD  optph1                93    102  0
730aAD  optph2               103    112  0
730aAD  optcam               113    113
730aAD  optdil               114    114
730aAD  optdip               115    115
740aAD  optsyg               116    116
     D  opten2               117    117
730aA*----------------------------------------------------------------
730aA*  *TRAX3    -  More TRAX options
730aA*----------------------------------------------------------------
730aA*
730aA* Fields
730aA*
730aA*    OPTURL  -  URL address where Trax app update is located. Must
730aA*               begin with http:// and server address.
730aA*
730aA* Data structure
730aA*
730aAD optionRec3      ds
730aAD  opturl                 1     60
730aAD  opten3               117    117

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      option fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *      pData      OPTIONS data field
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pData
     C                   parm                    pWhse
     c                   parm                    phst
     c                   parm                    psli
     c                   parm                    pcwr
     c                   parm                    poft
     c                   parm                    pdft
     c                   parm                    prft
     c                   parm                    pcap
     c                   parm                    pdbl
     c                   parm                    pekd
     c                   parm                    pdar
     c                   parm                    pidb
     c                   parm                    pbda
     c                   parm                    pgbd
     c                   parm                    prtq
     c                   parm                    potq
     c                   parm                    pcce
     c                   parm                    psig
     c                   parm                    ppiv
     c                   parm                    psda
     c                   parm                    pwsp
     c                   parm                    pwsi
     c                   parm                    psvd
     c                   parm                    pert
     c                   parm                    pedv
     c                   parm                    peos
     c                   parm                    pesw
     c                   parm                    pesh
     c                   parm                    pare
     c                   parm                    pidl
     c                   parm                    pdci
     c                   parm                    ppal
     c                   parm                    pcra
     c                   parm                    pdrv
     c                   parm                    pbul
     c                   parm                    peys
     c                   parm                    psas
     c                   parm                    psdl
     c                   parm                    psdt
     c                   parm                    plrk
     c                   parm                    pgss
     c                   parm                    pgsu
     c                   parm                    psbv
     c                   parm                    prag
     c                   parm                    prd
     c                   parm                    prdt
     c                   parm                    prfp
     c                   parm                    prfm
     c                   parm                    pnsr
     c                   parm                    pfbd
     c                   parm                    pdsf
720bAc                   parm                    pdir
720bAc                   parm                    piu
730aAc                   parm                    psor
730aAc                   parm                    pode
730aAc                   parm                    podp
730aAc                   parm                    pont
730aAc                   parm                    potp
730aAc                   parm                    pnsb
730aAc                   parm                    psvl
730aAc                   parm                    pssp
730aAc                   parm                    psss
730aAc                   parm                    psst
730aAc                   parm                    pmul
730aAc                   parm                    pkpl
730aAc                   parm                    pshl
730aAc                   parm                    pprt
730aAc                   parm                    pspk
730aAc                   parm                    pgps
730aAc                   parm                    pmin
730aAc                   parm                    pmet
730aAc                   parm                    ppwd
730aAc                   parm                    poff
730aAc                   parm                    paut
730aAc                   parm                    pph1
730aAc                   parm                    pph2
730aAc                   parm                    pcam
730aAc                   parm                    pdil
730aAc                   parm                    pdip
730aAc                   parm                    purl
740aAc                   parm                    psyg
740aAc                   parm                    ptrinv

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'AFTERACT';
720bA        exsr editFlds;
720bA        if pMessage = *blanks;
                exsr AfterAct;
720bA        endif;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;
         opdata = optionRec;
         t_opdata = optionRec2;
730aA    t3_opdata = optionRec3;

         exec sql insert into options values(:oprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
720bA       exec sql insert into options values(:oprec2);
730aA       exec sql insert into options values(:oprec3);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

         exsr GetRec;

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
720bA    else;
720bA       exec sql delete from options
720bA                where opcode = :optionCode2
720bA                  and opwhse = :pWhse;

730aA       exec sql delete from options
730aA                where opcode = :optionCode3
730aA                  and opwhse = :pWhse;
         endif;

       endsr;
      /end-free

720bA*----------------------------------------------------------------
720bA*  editFlds  Verify contents of data passed
720bA*----------------------------------------------------------------

      /free
       begsr editFlds;

          if pDir = *blanks;
             pMessage = 'IFS Directory cannot be blank';
             leavesr;
          endif;

          if pIu = *blanks;
             pMessage = 'IFS User cannot be blank';
             leavesr;
          endif;

730aA     if %parms > 60;

730aA       if pOdp < 5 or pOdp > 60;
730aA         pMessage = 'Cust on site delivery verification +
730aA                     period must be 5 - 60';
730aA         leavesr;
730aA       endif;

730aA       if pMin < 1 or pMin > 999;
730aA         pMessage = 'GPS probe period minutes must be 1 - 999';
730aA         leavesr;
730aA       endif;

730aA       if pMet < 1 or pMet > 999999;
730aA         pMessage = 'GPS probe distance meters must be 1 - 999999';
730aA         leavesr;
730aA       endif;

730aA       if pPwd = *blanks;
730aA         pMessage = 'Admin password cannot be blank';
730aA         leavesr;
730aA       endif;

730aA       if pPh1 < 1 or pPh1 > 9999999999;
730aA         pMessage = 'Please enter Company phone number';
730aA         leavesr;
730aA       endif;

730aA       if pPh2 < 1 or pPh2 > 9999999999;
730aA         pMessage = 'Please enter Dispatch phone number for texting';
730aA         leavesr;
730aA       endif;

730aA       if %subst(pUrl:1:7) <> 'http://';
730aA         pMessage = 'Trax app update URL must begin with http://';
730aA         leavesr;
730aA       endif;

740aA       if pTrinv <> '1' and pTrinv <> '2' and
740aA          pTrinv <> '3' and pTrinv <> '9';
740aA         pMessage = 'Please check Trax invoice print option';
740aA         leavesr;
740aA       endif;

730aA     endif;

720bA  endsr;
720bA /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opcode = optionCode;
         opwhse = pWhse;
720bA    t_opcode = optionCode2;
720bA    t_opwhse = pWhse;
730aA    t3_opcode = optionCode3;
730aA    t3_opwhse = pWhse;

720bA    opthst = pHst;
720bA    optwsp = pWsp;
720bA    optwsi = pWsi;
         optcwr = pcwr;
         optbda = pbda;
         optgbd = pgbd;
         optsig = psig;
         optpiv = ppiv;
         optare = pare;
         optpal = ppal;
         optbul = pbul;
         optgss = pgss;
         optgsu = pgsu;
720bA    optdir = pDir;
720bA    optiu = piu;

730aA    if %parms > 60;
730aA      optsor = psor;
730aA      optode = pode;
730aA      optodp = podp;
730aA      optont = pont;
730aA      optotp = potp;
730aA      optnsb = pnsb;

730aA      optsvl = psvl;
730aA      optssp = pssp;
730aA      optsss = psss;
730aA      optsst = psst;
730aA      optmul = pmul;
730aA      optkpl = pkpl;
730aA      optshl = pshl;
730aA      optprt = pprt;
730aA      optspk = pspk;
730aA      optgps = pgps;
730aA      optmin = pmin;
730aA      optmet = pmet;
730aA      optpwd = ppwd;
730aA      optoff = poff;
730aA      optaut = paut;
730aA      optph1 = pph1;
730aA      optph2 = pph2;
730aA      optcam = pcam;
730aA      optdil = pdil;
730aA      optdip = pdip;

730aA      opturl = purl;
740aA      optsyg = psyg;
740aA      optraxinv = ptrinv;
730aA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :oprec
                  from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt = sqlSuccess;
           found = *on;
           optionrec = opdata;
720bA      exec sql select * into :oprec2
720bA               from options
720bA               where opcode = :optionCode2
720bA                 and opwhse = :pWhse;
           if sqlstt = sqlSuccess;
             optionrec2 = t_opdata;
           endif;

730aA      exec sql select * into :oprec3
730aA               from options
730aA               where opcode = :optionCode3
730aA                 and opwhse = :pWhse;
730aA      if sqlstt = sqlSuccess;
730aA        optionrec3 = t3_opdata;
730aA      endif;

         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;
         opdata = optionRec;
720bA    t_opdata = optionRec2;
730aA    t3_opdata = optionRec3;

         exec sql update options
                  set opdata = :opdata
                  where opcode = :opcode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
720bA    else;
720bA      exec sql update options
720bA               set opdata = :t_opdata
720bA               where opcode = :t_opcode
720bA                 and opwhse = :pWhse;

730aA      exec sql update options
730aA               set opdata = :t3_opdata
730aA               where opcode = :t3_opcode
730aA                 and opwhse = :pWhse;

         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

