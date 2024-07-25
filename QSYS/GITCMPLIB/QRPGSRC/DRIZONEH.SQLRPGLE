500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  DRIZONEH    Dakota realtime interface - Zone maintenance
     *  15 September 2011
     *  Dave Sommerville
     *
640  *    09/15/11  DAS  6.40
     *      - Created
     *
640a *    04/12/12  DAS  6.40a
     *      - Fix: Compartment verification missing 'not'.
     *      - Revised to only verify Picked Up By for merge zone.
     *      - Changed zonetype check to sql lookup in glo1codes file.
     *      - Changed mrgtype check to sql lookup in glo1codes file.
     *
640b *    04/13/12  DAS  6.40b
     *      - Added commands *ADDWEB and *DELETEWEB to be used for
     *        MRC maintenance programs.
     *
650a *    05/05/14  DAS  6.50a
     *      - MRC added new property to skip the MRC update, so
     *        now we will convert *ADDWEB and *DELETEWEB into the
     *        standard *ADD and *DELETE.
     *
650b *    05/06/14  DAS  6.50b
     *      - Added new *PICK option OPLBL
     *
650c *    02/19/15  DAS  6.50c
     *      - Added new *COPYTPL and *COPYZON commands
     *      - Added $zhfrmtruk and $zhfrmzone to ds.
     *
650d *    02/28/15  DAS  6.50d
     *      - Added new *DELTETPL commands
     *
700a *    05/29/15  LMC  7.00a
     *      - changed some commands from 11 positions to 10.
     *
700b *    06/03/15  LMC  7.00b
     *      - Added new *PICK options opdddo, opmcub, oppmtz
700c *    01/28/16  LMC  7.00c
     *      - Remove hard coding of BFCGLOBALF from sql.
700d *    02/08/16  LMC  7.00d
     *      - OPTIONZ records were not being deleted.
     *        chain in optiondel had chain(n), so record was not being
     *        deleted.
     *      - COPYZON was never being sent in. When user was copying
     *        a single zone, command was always add. This was not
     *        getting the scope records copied, or the *PICK** records
     *        from the OPTIONZ file.
     *        GUI M04208 was created to send the copy from zone.
710a *    06/05/17  LMC  7.10a
     *      - Added new Zone Number of Pallet Sections.
     *      - Added getclient
710b *    06/19/17  LMC  7.10b
     *      - Copy Zone from GUI needs to also update the fields
     *      changed from gui entry screen. This requires a new command
     *      So we don't break the way green screen does copy zones.
     *      *COPYZONW - copy zone from web programs.
720a *    06/03/18  DAS  7.20a
     *      - Added fields Max Weight, Pallet Code, Build Seq.
720b *    09/01/18  DAS  7.20b
     *      - Added fields Max Stops Section
720c *    10/14/18  DAS  7.20c
     *      - Recompiled because of new ZONED fields.
730a *    03/25/19  LMC  7.30a
     *      - Recompiled because field $optecb was changed to 5.2
     *        was orginally 5.0.
730b *    10/14/19  KDE  7.30b
     *      - Add Tote check when doing copy zone from MRC
740 A*    02/26/20  KDE  7.40
     *      - Revised to monitor opfwgt in case not initialized proper
     *        in zone setup.  Will force zero if fails
740a *    05/28/20  DAS  7.40a
     *      - Added field OZRFZP RF Zone Pickup
740b *    08/20/20  KDE  7.40b
     *      - Added opicub, oppisplt, opmscb, opmsvh, opmsvm,opmsvl,
     *        and opoacb, version 9 fields
     *      - Add second data structure to c#zoneh
     *      - Add message to force pallet position when *SP is merged
     *        with other stops
750  *    02/18/21  KDE  7.50
     *      - Added oppstuff
750a *    03/19/21  KDE  7.50a
     *      - Added oppmsp, oppmstp, oppmord
750b *    02/19/22  DAS  7.50b
     *      - Fixed IF stmt for merging stop fields
     *      - Changed INVLDPLTP to INVLDPLTP1 and INVLDPLTP2
     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
     *
USFaA*    06/05/17  LMC  USF
     *      - Client has a limit of 3 pallet sections.
USFbA*    10/28/20  KDE  USFb
     *      - Client requested mod above be removed
     *----------------------------------------------------------------
     *  Client Custom Revisions: PFG
     *
PFGaA*    05/14/19  KDE  PFG
     *      - Client cannot use Loader Merge.  Per Hemant it messes up
     *        labels in Food Star.
     *----------------------------------------------------------------
     * Notes
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADD              Add zone
      *
640bA *      *ADDWEB           Add zone - MRC version.
      *
      *      *CHANGE           Change zone
      *
650cA *      *COPYTPL          Copy zone template
      *
650cA *      *COPYZON          Copy zone
      *
710bA *      *COPYZONW         Copy zone  - mrc version
      *
      *      *DELETE           Delete zone
      *
650dA *      *DELETETPL        Delete zone template
      *
640bA *      *DELETEWEB        Delete zone - MRC version
      *
      *      *GET              Get zone information.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
700aD *      *VERIFYDELT       Do "*DELETETPL" verification without update.
700aM *      *VERFYDELT        Do "*DELETETPL" verification without update.
700aD *      *VERIFYCPYT       Do "*COPYTPL" verification without update.
700aM *      *VERFYCPYT        Do "*COPYTPL" verification without update.
700aD *      *VERIFYCPYZ       Do "*COPYZON" verification without update.
700aM *      *VERFYCPYZ        Do "*COPYZON" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fzoneh     uf a e           k disk    infds(file1ds)
     Fzoned1    uf a e           k disk    infds(file2ds)
     Foptionz   uf a e           k disk    infds(file3ds)
     Ftruckh    if   e           k disk
     Ftrkcomp   if   e           k disk
640aDF*rgtype   if   e           k disk
640aDF*onetype  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getFeat
      /copy qcopysrc,p.vfywhse
710aA /copy qcopysrc,p.getclien

710aA*----------------------------------------------------------------
710aA*  Customer id
710aA*----------------------------------------------------------------
710aA
USFaA /COPY QCOPYSRC,ID#USFCORP
PFGaA /COPY QCOPYSRC,ID#PFG

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ZONEH
     D saveVer#        s                   like($zhver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(zhwhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D vfyWhseCalled   s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

650cAD copyErr         s               n
     D error           s               n
     D forever         s               n   inz(*on)
     D lock            s               n
     D tbLight         s               n

     D $gfCmd          s              8
     D $gfFeature      s              1
     D $gfLight        s              1
     D $gfWhse         s              3p 0
     D blankPos        s              3  0
     D codeLen         s              3  0
650cAD kyzone          s                   like(zhzone)
640aMD tmp1            s              1

710aAD client          s             10
710aAD clientloc       s             10
     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $lwhse                19     21  0
     D  $ltruk                22     31
     D  $lzone                32     37
416bD
416bMD  $lcomp                22     22

     *----------------------------------------------------------------
     *  OPTIONZ data structure
     *----------------------------------------------------------------
     D opzdta          ds
     D  opzend               117    117

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = By descening stop, then slot location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
416aA*    OPNWPL  -  Start new pallet when aisle changes if build method
416aA*               is 2=Location.
500dA*    OPFORD  -  Maximun orders per pallet.
520dM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510dA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520dA*    OPGCDE  -  USF Group Code (0-9).
520cA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520cA*    OPSPAL  -  Merge pallet should only contain
520cA*               items for single truck pallet (Y=Yes, N=No).
520dA*    OPPITM  -  Maximum items per pallet.
650bA*    OPLBL   -  Label printing method.
650bA*                N = Normal
650bA*                S = Side by Side
650bA*                C = Custom
700bA*    OPPMTZ  -  Allow multi-truck assignments. (USF only)
700bA*    OPDDDO  -  Dock door drop off order. (USF only)
700bA*    OPMCUB  -  Minimum cube per fixed pallet.
710aA*    OPNBPS  -  Number of Pallet Sections.
720aA*    OPFWGT  -  Maximu weight per pallet.
720aA*    OPFPLT  -  Pallet code
720aA*    OPBSEQ  -  Build sequence number
720bA*    OPSSTP  -  Maximum stops per section
740aA*    OZRFZP  -  RF Zone Pickup
740bA*    OPICUB  -  Ideal Cube
740bA*    OPPISPLT-  Prevent Item Split
740bA*    OPMSCB  -  Allow merging w/other stops when cube < value
740bA*    OPMSVH  -    When merging above, stop can be highest pallet
740bA*    OPMSVM  -    When merging above, stop can be middle pallet
740bA*    OPMSVL  -    When merging above, stop can be low pallet
740bA*    OPOACB  -  Overflow pallet put on Truck when cube > value
740bA*    OPZPLT  -  Zone Pallet Type
740bA*    OPBPLT  -  Bulk Pallet Type
750 A*    OPPSTUFF-  Stuff pallet or split when max cube
750aA*    OPPMSP  -  Prevent manual merging of *SP pallets
750aA*    OPPMSTP -  Prevent manual exceeding of max Stops
750aA*    OPPMORD -  Prevent manual exceeding of max Orders
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opzdt1          ds                  inz
     D  opnxtp                 1      7  0 inz(0)
213 D*I            0                         8   90OPBPCK
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     *I            0                        21  210OPFSTP
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 D*                                      31  31 OPPBRK
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 D*                                      37  37 OPBMRG
500 D*                                      38  38 OPNWPL
500 MD  opbmrg                37     37
500 MD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510dAD  opstop                61     61
520dA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520dAD**opgcde                62     62
520cAD  oppkup                62     62
520cAD  opspal                63     63
520dAD  oppitm                64     67  0 inz(0)
650bAD  oplbl                 68     68
700bAD  opdddo                69     69
700bAD  opmcub                70     74  2 inz(0)
700bAD  oppmtz                75     75
710aAD  opnbps                77     77  0 inz(0)
720aAD  opfwgt                78     81  0 inz(0)
720aAD  opfplt                82     87
720aAD  opbseq                88     89  0 inz(0)
720bAD  opsstp                90     91  0 inz(0)
740aAD  ozrfzp                92     92
740bAd  opicub                93     97  2
740bAd  oppisplt              98     98
740bAd  opmscb                99    100  0
740bAd  opmsvh               101    101
740bAd  opmsvm               102    102
740bAd  opmsvl               103    103
740bAd  opoacb               104    105  0
740bAd  opzplt               106    106
740bAd  opbplt               107    107
750 Ad  oppstuff             108    108
750aAd  oppmsp               109    109
750aAd  oppmstp              110    110
750aAd  oppmord              111    111
     D  opend1               117    117

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - Added field OPPDEV.
     *
520dA*     08/12/09  RBD
     *       - Added notation for option OPAISL which was previously
     *         added to ZH122.
     *       - Added options OPTAXR and OPCHKR to *PICKLBL.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
300 A*    OPPDEV  -  Printer device.
300 A*    OPPFRM  -  Printer form.
520aA*    OPAISL  -  Print aisle change label (Y/N).
520dA*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
520dA*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opzdt2          ds                  inz
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
300 AD  oppdev                65     74
300 AD  oppfrm                75     84
520aAD  opaisl                85     85
520dAD  optaxr                86     86
520dAD  opchkr                87     87
     D  opend2               117    117

     *----------------------------------------------------------------
520dA*  *PICKLBA -  Label printing options for the standard pick,
520dA*              retail, and tote labels.
     *
520dA*     08/12/09  RBD  5.20  P#00219
520dA*       - Added record type *PICKLBA which holds printing info
520dA*         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opzdt3          ds                  inz
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117

     *----------------------------------------------------------------
520dA*  *PICKLBB -  Label printing options for the pick list and
520dA*               ASN labels and pick list report.
     *
520dA*     08/12/09  RBD  5.20  P#00219
520dA*       - Added record type *PICKLBB which holds printing info
520dA*         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
530 A*
530 A*    OPLB7   -  Print PICK labels for ZONPKUP D/S- Pick labels
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opzdt4          ds                  inz
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
530 AD  oplb7                 97     97
     D  opend4               117    117

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

640aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /copy *libl/qcopysrc,c#file1ds
      /copy *libl/qcopysrc,c#file2ds
      /copy *libl/qcopysrc,c#file3ds
      /copy *libl/qcopysrc,c#file4ds

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata
740bAC                   parm                    $pdata2

     C                   eval      $zoneh = $pdata
740bAC                   if        %parms >= 6
740bAC                   eval      $zoneh2 = $pdata2
740bAc                   endif
740bAc                   monitor
740bAc                   eval      $opicub=$opicub
740bAc                   on-error
740bAc                   eval      $opicub=0
740bAc                   endmon
740bAc                   monitor
740bAc                   eval      $opoacb=$opoacb
740bAc                   on-error
740bAc                   eval      $opoacb=0
740bAc                   endmon
740bAc                   monitor
740bAc                   eval      $opmscb=$opmscb
740bAc                   on-error
740bAc                   eval      $opmscb=0
740bAc                   endmon
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
640bAC                             or $psubcmd = '*ADDWEB'
650aAC                   eval      $psubcmd = '*ADD'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
640bAC                   if        $psubcmd = '*ADDWEB'
640bAC                   exsr      DeleteZoneWeb
640bAC                   endif
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      addrec
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      changerec
     C                   endif
     C                   endif
     C                   endif

650cAC                   when      $psubcmd = '*COPYTPL'
650cAC                   if        DakotaCall
650cAC                   exsr      aaacallhost
650cAC                   if        not error
650cAC                   exsr      verifycpyt
650cAC                   if        not error
650cAC                   exsr      copyrec
650cAC                   endif
650cAC                   endif
650cAC                   endif

650cAC                   when      $psubcmd = '*COPYZON'
710bAC                             or $psubcmd = '*COPYZONW'
650cAC                   if        DakotaCall
650cAC                   exsr      aaacallhost
650cAC                   if        not error
650cAC                   exsr      verifycpyz
650cAC                   if        not error
650cAC                   exsr      copyrec
650cAC                   endif
650cAC                   endif
650cAC                   endif

     C                   when      $psubcmd = '*DELETE'
640bAC                             or $psubcmd = '*DELETEWEB'
650aAC                   eval      $psubcmd = '*DELETE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
650dAC                   exsr      verifydelz
650dAC                   if        not error
     C                   exsr      deleterec
650dAC                   endif
     C                   endif
     C                   endif

650dAC                   when      $psubcmd = '*DELETETPL'
650dAC                   if        DakotaCall
650dAC                   exsr      aaacallhost
650dAC                   if        not error
650dAC                   exsr      verifydelt
650dAC                   if        not error
650dAC                   exsr      deletetpl
650dAC                   endif
650dAC                   endif
650dAC                   endif

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      getzoneh
     C                   if        not error
     C                   exsr      zoneh2ds
     C                   endif

     C                   when      $psubcmd = '*VERIFYADD'
     C                   exsr      verifyadd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   exsr      verifychg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
650dDC**                 exsr      deleterec
650dAC                   exsr      verifydelz
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

700aDC*                  when      $psubcmd = '*VERIFYDELT'
700aMC                   when      $psubcmd = '*VERFYDELT'
650dAC                   exsr      verifydelt
650dAC                   if        DakotaCall and not error
650dAC                   exsr      aaacallhost
650dAC                   endif

700aDC*                  when      $psubcmd = '*VERIFYCPYT'
700aMC                   when      $psubcmd = '*VERFYCPYT'
650cAC                   exsr      verifycpyt
650cAC                   if        DakotaCall and not error
650cAC                   exsr      aaacallhost
650cAC                   endif

700aDC*                  when      $psubcmd = '*VERIFYCPYZ'
700aMC                   when      $psubcmd = '*VERFYCPYZ'
650cAC                   exsr      verifycpyz
730bAc                   exsr      verifygen2
650cAC                   if        DakotaCall and not error
650cAC                   exsr      aaacallhost
650cAC                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $zoneh
740bAC                   if        %parms >= 6
740bAC                   eval      $pdata2 = $zoneh2
740bAc                   endif
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
710aA /free
710aA   getclient(client: clientLoc);
710aA /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------

     C     aaacallhost   begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr
      /free

         if vfyWhseCalled;
           vfyWhse('*CLOSE': '*NONE': $vwhse: $vdesc:
                   $vreturn: $vmessage: $vmsgk);
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  addrec   Add record.
     *----------------------------------------------------------------

     C     addrec        begsr
      /free

         // Clear record.

         clear zhrec;

         // Move information into fields.

         zhwhse = $zhwhse;
         zhtruk = $zhtruk;
         zhzone = $zhzone;

         if $zhdescu;
           zhdesc = $zhdesc;
         endif;

         if $zhcompu;
           zhcomp = $zhcomp;
         endif;

         if $zhpzonu;
           zhpzon = $zhpzon;
         endif;

         // Add record

         write(e) zhrec;
         if %error;
           error = *on;
           $preturn = 'ERRADDREC';
           $pmessage = 'Error on "Write ZONEH" command '
                     + '('
                     + %Trim(%editc(zhwhse:'Z'))
                     + '/'
                     + %trim(zhtruk)
                     + '/'
                     + %trim(zhzone)
                     + ')'
                     + '-' + f1messageid;
           leavesr;
         endif;

         // Add Optionz records

         exsr optionupd;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  changerec   Change record.
     *----------------------------------------------------------------

     C     changerec     begsr
      /free

         // Move information into fields.

         if $zhdescu;
           zhdesc = $zhdesc;
         endif;

         if $zhcompu;
           zhcomp = $zhcomp;
         endif;

         if $zhpzonu;
           zhpzon = $zhpzon;
         endif;

         // Update record

         update(e) zhrec;
         if %error;
           error = *on;
           $preturn = 'ERRUPDREC';
           $pmessage = 'Error on "Update ZONEH" command '
                     + '('
                     + %Trim(%editc(zhwhse:'Z'))
                     + '/'
                     + %trim(zhtruk)
                     + '/'
                     + %trim(zhzone)
                     + ')'
                     + '-' + f1messageid;
           leavesr;
         endif;

         // Update Optionz records

         exsr optionupd;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr
      /free

         if $zhwhsee = '1';
           $zhwhsee = '0';
         endif;

         if $zhtruke = '1';
           $zhtruke = '0';
         endif;

         if $zhzonee = '1';
           $zhzonee = '0';
         endif;

         if $zhdesce = '1';
           $zhdesce = '0';
         endif;

         if $zhcompe = '1';
           $zhcompe = '0';
         endif;

         if $zhpzone = '1';
           $zhpzone = '0';
         endif;

         if $opfpale = '1';
           $opfpale = '0';
         endif;

         if $opfcube = '1';
           $opfcube = '0';
         endif;

         if $opfstpe = '1';
           $opfstpe = '0';
         endif;

720bA    if $opsstpe = '1';
720bA      $opsstpe = '0';
720bA    endif;

740aA    if $ozrfzpe = '1';
740aA      $ozrfzpe = '0';
740aA    endif;

740bA    if $opicube = '1';
740bA      $opicube = '0';
740bA    endif;

740bA    if $oppisplte = '1';
740bA      $oppisplte = '0';
740bA    endif;

740bA    if $opmscbe = '1';
740bA      $opmscbe = '0';
740bA    endif;

740bA    if $opmsvhe = '1';
740bA      $opmsvhe = '0';
740bA    endif;

740bA    if $opmsvme = '1';
740bA      $opmsvme = '0';
740bA    endif;

740bA    if $opmsvle = '1';
740bA      $opmsvle = '0';
740bA    endif;

740bA    if $opoacbe = '1';
740bA      $opoacbe = '0';
740bA    endif;

740bA    if $opzplte = '1';
740bA      $opzplte = '0';
740bA    endif;

740bA    if $opbplte = '1';
740bA      $opbplte = '0';
740bA    endif;

750 A    if $oppstuffe = '1';
750 A      $oppstuffe = '0';
750 A    endif;

750aA    if $oppmspe = '1';
750aA      $oppmspe = '0';
750aA    endif;

750aA    if $oppmstpe = '1';
750aA      $oppmstpe = '0';
750aA    endif;

750aA    if $oppmorde = '1';
750aA      $oppmorde = '0';
750aA    endif;

         if $opbpcke = '1';
           $opbpcke = '0';
         endif;

         if $oppblde = '1';
           $oppblde = '0';
         endif;

         if $opnwple = '1';
           $opnwple = '0';
         endif;

         if $opforde = '1';
           $opforde = '0';
         endif;

         if $opptype = '1';
           $opptype = '0';
         endif;

         if $optecbe = '1';
           $optecbe = '0';
         endif;

         if $opticbe = '1';
           $opticbe = '0';
         endif;

         if $optorde = '1';
           $optorde = '0';
         endif;

         if $optpcse = '1';
           $optpcse = '0';
         endif;

         if $opstope = '1';
           $opstope = '0';
         endif;

         if $oppkupe = '1';
           $oppkupe = '0';
         endif;

         if $opspale = '1';
           $opspale = '0';
         endif;

         if $oppitme = '1';
           $oppitme = '0';
         endif;

650bA    if $oplble = '1';
650bA      $oplble = '0';
650bA    endif;

700bA    if $opmcube = '1';
700bA      $opmcube = '0';
700bA    endif;

700bA    if $oppmtze = '1';
700bA      $oppmtze = '0';
700bA    endif;

700bA    if $opdddoe = '1';
700bA      $opdddoe = '0';
700bA    endif;

710aA    if $opnbpse = '1';
710aA      $opnbpse = '0';
710aA    endif;

720aA    if $opfwgte = '1';
720aA      $opfwgte = '0';
720aA    endif;

720aA    if $opfplte = '1';
720aA      $opfplte = '0';
720aA    endif;

720aA    if $opbseqe = '1';
720aA      $opbseqe = '0';
720aA    endif;

         if $opclvle = '1';
           $opclvle = '0';
         endif;

         if $opcwrae = '1';
           $opcwrae = '0';
         endif;

         if $opcwrbe = '1';
           $opcwrbe = '0';
         endif;

         if $opuwrae = '1';
           $opuwrae = '0';
         endif;

         if $opuwrbe = '1';
           $opuwrbe = '0';
         endif;

         if $operre = '1';
           $operre = '0';
         endif;

         if $opcwgte = '1';
           $opcwgte = '0';
         endif;

         if $opaisle = '1';
           $opaisle = '0';
         endif;

         if $optaxre = '1';
           $optaxre = '0';
         endif;

         if $opchkre = '1';
           $opchkre = '0';
         endif;

         if $oplb1e = '1';
           $oplb1e = '0';
         endif;

         if $opcu1e = '1';
           $opcu1e = '0';
         endif;

         if $oplp1e = '1';
           $oplp1e = '0';
         endif;

         if $opdv1e = '1';
           $opdv1e = '0';
         endif;

         if $opfm1e = '1';
           $opfm1e = '0';
         endif;

         if $oplb2e = '1';
           $oplb2e = '0';
         endif;

         if $opcu2e = '1';
           $opcu2e = '0';
         endif;

         if $oplp2e = '1';
           $oplp2e = '0';
         endif;

         if $opdv2e = '1';
           $opdv2e = '0';
         endif;

         if $opfm2e = '1';
           $opfm2e = '0';
         endif;

         if $oplb3e = '1';
           $oplb3e = '0';
         endif;

         if $opcu3e = '1';
           $opcu3e = '0';
         endif;

         if $oplp3e = '1';
           $oplp3e = '0';
         endif;

         if $opdv3e = '1';
           $opdv3e = '0';
         endif;

         if $opfm3e = '1';
           $opfm3e = '0';
         endif;

         if $oplb4e = '1';
           $oplb4e = '0';
         endif;

         if $opcu4e = '1';
           $opcu4e = '0';
         endif;

         if $oplp4e = '1';
           $oplp4e = '0';
         endif;

         if $opdv4e = '1';
           $opdv4e = '0';
         endif;

         if $opfm4e = '1';
           $opfm4e = '0';
         endif;

         if $oplb5e = '1';
           $oplb5e = '0';
         endif;

         if $opcu5e = '1';
           $opcu5e = '0';
         endif;

         if $oplp5e = '1';
           $oplp5e = '0';
         endif;

         if $opdv5e = '1';
           $opdv5e = '0';
         endif;

         if $opfm5e = '1';
           $opfm5e = '0';
         endif;

         if $oplb6e = '1';
           $oplb6e = '0';
         endif;

         if $opcu6e = '1';
           $opcu6e = '0';
         endif;

         if $oplp6e = '1';
           $oplp6e = '0';
         endif;

         if $opdv6e = '1';
           $opdv6e = '0';
         endif;

         if $opfm6e = '1';
           $opfm6e = '0';
         endif;

         if $oplb7e = '1';
           $oplb7e = '0';
         endif;

650cA    if $zhfrmtruke = '1';
650cA      $zhfrmtruke = '0';
650cA    endif;

650cA    if $zhfrmzonee = '1';
650cA      $zhfrmzonee = '0';
650cA    endif;

      /end-free
     C                   endsr

650cA*----------------------------------------------------------------
650cA*  copyrec     Copy record
650cA*----------------------------------------------------------------
650cA
650cAC     copyrec       begsr
      /free
         error = *off;

         select;
           when $psubcmd = '*COPYTPL';
             setll ($zhwhse: $zhfrmtruk) zoneh;
710bD      //when $psubcmd = '*COPYZON';
710bM      when $psubcmd = '*COPYZON'
710bA           or $psubcmd = '*COPYZONW';
             setll ($zhwhse: $zhfrmtruk: $zhfrmzone) zoneh;
           other;
             leavesr;
         endsl;

         dow forever = forever;

           select;
             when $psubcmd = '*COPYTPL';
               reade ($zhwhse: $zhfrmtruk) zoneh;
710bD        //when $psubcmd = '*COPYZON';
710bM        when $psubcmd = '*COPYZON'
710bA           or $psubcmd = '*COPYZONW';
               reade ($zhwhse: $zhfrmtruk: $zhfrmzone) zoneh;
           endsl;

           if %eof(zoneh);
             leave;
           endif;

           // Save zone

           kyzone = zhzone;

           // Copy header record.

700dA      select;
700dA        when $psubcmd = '*COPYTPL';
               zhtruk = $zhtruk;
               zhzone = kyzone;
700dA        when $psubcmd = '*COPYZON';
700dA          zhtruk = $zhtruk;
700dA          zhzone = $zhzone;
710bA        when $psubcmd = '*COPYZONW';
710bA          zhtruk = $zhtruk;
710bA          zhzone = $zhzone;
710bA          if $zhdescu;
710bA            zhdesc = $zhdesc;
710bA          endif;

710bA          if $zhcompu;
710bA            zhcomp = $zhcomp;
710bA          endif;

710bA          if $zhpzonu;
710bA            zhpzon = $zhpzon;
710bA          endif;
700dA      endsl;

           monitor;
             write zhrec;
           on-error;
             error = *on;
             $preturn = 'ERRCOPY';
             $pmessage = 'Copy err '
                       + %Trim(%editc(zhwhse:'Z'))
                       + '/'
                       + %trim(zhtruk)
                       + '/'
                       + %trim(zhzone)
                       + '/ZONEH-' + f1messageid;
             leavesr;
           endmon;

           // Copy detail records

           setll ($zhwhse: $zhfrmtruk: kyzone) zoned1;

           dow forever = forever;

             reade(n) ($zhwhse: $zhfrmtruk: kyzone) zoned1;
             if %eof(zoned1);
               leave;
             endif;

700dA      select;
700dA        when $psubcmd = '*COPYTPL';
               zdtruk = $zhtruk;
               zdzone = kyzone;
710bD        //when $psubcmd = '*COPYZON';
710bM        when $psubcmd = '*COPYZON'
710bA             or $psubcmd = '*COPYZONW';
700dA          zdtruk = $zhtruk;
700dA          zdzone = $zhzone;
700dA      endsl;

             monitor;
               write zdrec;
             on-error;
               if error;
                 $pmessage = %trimr($pmessage) + '/ZONED-' + f2messageid;
               else;
                 error = *on;
                 $preturn = 'ERRCOPY';
                 $pmessage = 'Copy err '
                           + %Trim(%editc(zdwhse:'Z'))
                           + '/'
                           + %trim(zdtruk)
                           + '/'
                           + %trim(zdzone)
                           + '/ZONED-' + f2messageid;
               endif;
             endmon;

           enddo;

           // Copy Optionz records

           exsr optioncpy;

         enddo;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  deleterec   Delete record.
     *----------------------------------------------------------------

     C     deleterec     begsr
      /free
         error = *off;

640bA    // Skip delete of ZONEH for *DELETEWEB (already done by MRC)

         // Get and lock record.

         if $psubcmd = '*DELETE';
           lock = *on;
         else;
           lock = *off;
         endif;

640bA    if $psubcmd <> '*DELETEWEB';
           exsr getzoneh;
640bA    endif;

         if error;
           leavesr;
         endif;

         // Skip actual delete for *VERIFY.

         if $psubcmd = '*VERIFYDEL';
           leavesr;
         endif;

         // Delete detail records

         setll ($zhwhse: $zhtruk: $zhzone) zoned1;

         dow forever = forever;

           reade ($zhwhse: $zhtruk: $zhzone) zoned1;
           if %eof(zoned1);
             leave;
           endif;

           delete zdrec;

         enddo;

         // Delete Optionz records

         exsr optiondel;

         // Delete record

640bA    if $psubcmd <> '*DELETEWEB';

           delete(e) zhrec;
           if %error;
             error = *on;
             $preturn = 'ERRDELREC';
             $pmessage = 'Error on "Delete ZONEH" command '
                       + '('
                       + %Trim(%editc(zhwhse:'Z'))
                       + '/'
                       + %trim(zhtruk)
                       + '/'
                       + %trim(zhzone)
                       + ')'
                       + '-' + f1messageid;
             leavesr;
           endif;

640bA    endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  deletetpl   Delete zones for template
     *----------------------------------------------------------------

     C     deletetpl     begsr
      /free
         error = *off;

         setll ($zhwhse: $zhtruk) zoneh;

         dow forever = forever;

           reade ($zhwhse: $zhtruk) zoneh;

           if %eof(zoneh);
             leave;
           endif;

           // Delete header record.

           monitor;
             delete zhrec;
           on-error;
             error = *on;
             $preturn = 'ERRDELETE';
             $pmessage = 'Delete err '
                       + %Trim(%editc(zhwhse:'Z'))
                       + '/'
                       + %trim(zhtruk)
                       + '/'
                       + %trim(zhzone)
                       + '/ZONEH-' + f1messageid;
             leavesr;
           endmon;

           // Delete detail records

           setll ($zhwhse: $zhtruk: zhzone) zoned1;

           dow forever = forever;

             reade(n) ($zhwhse: $zhtruk: zhzone) zoned1;
             if %eof(zoned1);
               leave;
             endif;

             monitor;
               delete zdrec;
             on-error;
               if error;
                 $pmessage = %trimr($pmessage) + '/ZONED-' + f2messageid;
               else;
                 error = *on;
                 $preturn = 'ERRDELZON';
                 $pmessage = 'Delete err '
                           + %Trim(%editc(zdwhse:'Z'))
                           + '/'
                           + %trim(zdtruk)
                           + '/'
                           + %trim(zdzone)
                           + '/ZONED-' + f2messageid;
               endif;
             endmon;

           enddo;

           // Delete Optionz records

           exsr optiondel;

         enddo;

      /end-free
     C                   endsr

640bA*----------------------------------------------------------------
640bA*  DeleteZoneWeb  Delete zone for *ADDWEB
640bA*----------------------------------------------------------------
640bA
640bAC     DeleteZoneWeb begsr
      /free

         error = *off;

         lock = *on;
         exsr getzoneh;

         if not error;
           delete(e) zhrec;
         endif;

         error = *off;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  zoneh2ds  Move fields to data structure fields
     *----------------------------------------------------------------

     C     zoneh2ds      begsr
      /free

         // Initialize data structure

         savever# = $zhver#;
         clear $zoneh;
         $zhver# = savever#;

         // Move information to data structure.

         $zhwhse = zhwhse;
         $zhtruk = zhtruk;
         $zhzone = zhzone;
         $zhdesc = zhdesc;
         $zhcomp = zhcomp;
         $zhpzon = zhpzon;
         $opfpal = opfpal;
         $opfcub = opfcub;
         $opfstp = opfstp;
720bA    $opsstp = opsstp;
740aA    $ozrfzp = ozrfzp;
740bA    $opicub = opicub;
740bA    $oppisplt = oppisplt;
740bA    $opmscb = opmscb;
740bA    $opmsvh = opmsvh;
740bA    $opmsvm = opmsvm;
740bA    $opmsvl = opmsvl;
740bA    $opoacb = opoacb;
740bA    $opzplt = opzplt;
740bA    $opbplt = opbplt;
750 A    $oppstuff =  oppstuff;
750aA    $oppmsp =  oppmsp;
750aA    $oppmstp =  oppmstp;
750aA    $oppmord =  oppmord;
         $opbpck = opbpck;
         $oppbld = oppbld;
         $opnwpl = opnwpl;
         $opford = opford;
         $opptyp = opptyp;
         $optecb = optecb;
         $opticb = opticb;
         $optord = optord;
         $optpcs = optpcs;
         $opstop = opstop;
         $oppkup = oppkup;
         $opspal = opspal;
         $oppitm = oppitm;
650bA    $oplbl  = oplbl;
700bA    $opmcub = opmcub;
700bA    $oppmtz = oppmtz;
700bA    $opdddo = opdddo;
710aA    $opnbps = opnbps;
740 A    monitor;
720aA      $opfwgt = opfwgt;
740 A    on-error;
740 A      $opfwgt = 0;
740 A    endmon;
720aA    $opfplt = opfplt;
720aA    $opbseq = opbseq;
         $opclvl = opclvl;
         $opcwra = opcwra;
         $opcwrb = opcwrb;
         $opuwra = opuwra;
         $opuwrb = opuwrb;
         $operr = operr;
         $opcwgt = opcwgt;
         $opaisl = opaisl;
         $optaxr = optaxr;
         $opchkr = opchkr;
         $oplb1 = oplb1;
         $opcu1 = opcu1;
         $oplp1 = oplp1;
         $opdv1 = opdv1;
         $opfm1 = opfm1;
         $oplb2 = oplb2;
         $opcu2 = opcu2;
         $oplp2 = oplp2;
         $opdv2 = opdv2;
         $opfm2 = opfm2;
         $oplb3 = oplb3;
         $opcu3 = opcu3;
         $oplp3 = oplp3;
         $opdv3 = opdv3;
         $opfm3 = opfm3;
         $oplb4 = oplb4;
         $opcu4 = opcu4;
         $oplp4 = oplp4;
         $opdv4 = opdv4;
         $opfm4 = opfm4;
         $oplb5 = oplb5;
         $opcu5 = opcu5;
         $oplp5 = oplp5;
         $opdv5 = opdv5;
         $opfm5 = opfm5;
         $oplb6 = oplb6;
         $opcu6 = opcu6;
         $oplp6 = oplp6;
         $opdv6 = opdv6;
         $opfm6 = opfm6;
         $oplb7 = oplb7;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getzoneh  Get zoneh info
     *----------------------------------------------------------------

     C     getzoneh      begsr
      /free

         if lock;
           chain ($zhwhse: $zhtruk: $zhzone) zoneh;
         else;
           chain(n) ($zhwhse: $zhtruk: $zhzone) zoneh;
         endif;

         if not %found;
           error = *on;
           $preturn = 'INVLDZONE';
           $pmessage = 'Invalid Zone'
                     + '('
                     + %Trim(%editc($zhwhse:'Z'))
                     + '/'
                     + %trim($zhtruk)
                     + '/'
                     + %trim($zhzone)
                     + ')';
           leavesr;
         endif;

         // Get optionz records

         exsr getopt;

      /end-free
     C                   endsr

650cA*----------------------------------------------------------------
650cA*  getfrmzoneh  Get from zoneh info
650cA*----------------------------------------------------------------

     C     getfrmzoneh   begsr
      /free

         chain(n) ($zhwhse: $zhfrmtruk: $zhfrmzone) zoneh;

         if not %found;
           error = *on;
           $preturn = 'INVLDFZONE';
           $pmessage = 'Invalid From Zone'
                     + '('
                     + %Trim(%editc($zhwhse:'Z'))
                     + '/'
                     + %trim($zhfrmtruk)
                     + '/'
                     + %trim($zhfrmzone)
                     + ')';
           leavesr;
         endif;

         // Get optionz records

         exsr getopt;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getopt    Get OptionD info.
     *----------------------------------------------------------------

     C     getopt        begsr
      /free

         chain(n) ('*PICK': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           opzdt1 = opzdta;
740bA      monitor;
740bA        opicub=opicub;
740bA      on-error;
740bA        opicub=0;
740bA      endmon;
740bA      monitor;
740bA        opoacb=opoacb;
740bA      on-error;
740bA        opoacb=0;
740bA      endmon;
740bA      monitor;
740bA        opmscb=opmscb;
740bA      on-error;
740bA        opmscb=0;
740bA      endmon;
         else;
           clear opzdt1;
         endif;

         chain(n) ('*PICKLBL': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           opzdt2 = opzdta;
         else;
           clear opzdt2;
         endif;

         chain(n) ('*PICKLBA': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           opzdt3 = opzdta;
         else;
           clear opzdt3;
         endif;

         chain(n) ('*PICKLBB': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           opzdt4 = opzdta;
         else;
           clear opzdt4;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr
      /free

         select;

           when $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#prog);

           other;
             $pmessage = %trim($preturn) + ': Unkown return code';

         endsl;

      /end-free
     C                   endsr

650cA*----------------------------------------------------------------
650cA*  optioncpy  Copy Optionz records
650cA*----------------------------------------------------------------
650cA
650cAC     optioncpy     begsr
      /free

         copyErr = *off;

         chain(n) ('*PICK': $zhwhse: $zhfrmtruk: kyzone) optionz;
         if %found(optionz);
700dA      select;
700dA        when $psubcmd = '*COPYTPL';
               opztrk = $zhtruk;
               opzzon = kyzone;
700dA        when $psubcmd = '*COPYZON';
700dA          opztrk = $zhtruk;
700dA          opzzon = $zhzone;
710bA        when $psubcmd = '*COPYZONW';
710bA          opztrk = $zhtruk;
710bA          opzzon = $zhzone;
710bA          // Set fields

710bA          if $opfpalu;
710bA            opfpal = $opfpal;
710bA          endif;

710bA          if $opfcubu;
710bA            opfcub = $opfcub;
710bA          endif;

710bA          if $opfstpu;
710bA            opfstp = $opfstp;
710bA          endif;

720bA          if $opsstpu;
720bA            opsstp = $opsstp;
720bA          endif;

740aA          if $ozrfzpu;
740aA            ozrfzp = $ozrfzp;
740aA          endif;

740bA          if $opicubu;
740bA            monitor;
740bA              opicub = $opicub;
740bA            on-error;
740bA              opicub=0;
740bA            endmon;
740bA          endif;

740bA          if $oppispltu;
740bA            oppisplt = $oppisplt;
740bA          endif;

750 A          if $oppstuffu;
750 A            oppstuff = $oppstuff;
750 A          endif;

750aA          if $oppmspu;
750aA            oppmsp = $oppmsp;
750aA          endif;

750aA          if $oppmstpu;
750aA            oppmstp = $oppmstp;
750aA          endif;

750aA          if $oppmordu;
750aA            oppmord = $oppmord;
750aA          endif;

740bA          if $opmscbu;
740bA            monitor;
740bA              opmscb = $opmscb;
740bA            on-error;
740bA              opmscb=0;
740bA            endmon;
740bA          endif;

740bA          if $opmsvhu;
740bA            opmsvh = $opmsvh;
740bA          endif;

740bA          if $opmsvmu;
740bA            opmsvm = $opmsvm;
740bA          endif;

740bA          if $opmsvlu;
740bA            opmsvl = $opmsvl;
740bA          endif;

740bA          if $opoacbu;
740bA            monitor;
740bA              opoacb = $opoacb;
740bA            on-error;
740bA              opoacb = 0;
740bA            endmon;
740bA          endif;

740bA          if $opzpltu;
740bA            opzplt = $opzplt;
740bA          endif;

740bA          if $opbpltu;
740bA            opbplt = $opbplt;
740bA          endif;

710bA          if $opbpcku;
710bA            opbpck = $opbpck;
710bA          endif;

710bA          if $oppbldu;
710bA            oppbld = $oppbld;
710bA          endif;

710bA          if $opnwplu;
710bA            opnwpl = $opnwpl;
710bA          endif;

710bA          if $opfordu;
710bA            opford = $opford;
710bA          endif;

710bA          if $opptypu;
710bA            opptyp = $opptyp;
710bA          endif;

710bA          if $optecbu;
710bA            optecb = $optecb;
710bA          endif;

710bA          if $opticbu;
710bA            opticb = $opticb;
710bA          endif;

710bA          if $optordu;
710bA            optord = $optord;
710bA          endif;

710bA          if $optpcsu;
710bA            optpcs = $optpcs;
710bA          endif;

710bA          if $opstopu;
710bA            opstop = $opstop;
710bA          endif;

710bA          if $oppkupu;
710bA            oppkup = $oppkup;
710bA          endif;

710bA          if $opspalu;
710bA            opspal = $opspal;
710bA          endif;

710bA          if $oppitmu;
710bA            oppitm = $oppitm;
710bA          endif;

710bA          if $oplblu;
710bA            oplbl = $oplbl;
710bA          endif;

710bA          if $opmcubu;
710bA            opmcub = $opmcub;
710bA          endif;

710bA          if $oppmtzu;
710bA            oppmtz = $oppmtz;
710bA          endif;

710bA          if $opdddou;
710bA            opdddo = $opdddo;
710bA          endif;

710bA          if $opnbpsu;
710bA            opnbps = $opnbps;
710bA          endif;

720bA          if $opfwgtu;
720bA            opfwgt = $opfwgt;
720bA          endif;

720bA          if $opfpltu;
720bA            opfplt = $opfplt;
720bA          endif;

720bA          if $opbsequ;
720bA            opbseq = $opbseq;
720bA          endif;

710bA          opzdta = opzdt1;
700dA      endsl;
           monitor;
             write opzrec;
           on-error;
             if copyErr;
               $pmessage = %trimr($pmessage) + '/*PICK-' + f3messageid;
             else;
               error = *on;
               copyErr = *on;
               $preturn = 'ERRCOPY';
               $pmessage = 'Copy err '
                         + %Trim(%editc(opzwhs:'Z'))
                         + '/'
                         + %trim(opztrk)
                         + '/'
                         + %trim(opzzon)
                         + '/*PICK-' + f3messageid;
             endif;
           endmon;
         endif;

         chain(n) ('*PICKLBL': $zhwhse: $zhfrmtruk: kyzone) optionz;
         if %found(optionz);
700dA      select;
700dA        when $psubcmd = '*COPYTPL';
               opztrk = $zhtruk;
               opzzon = kyzone;
700dA        when $psubcmd = '*COPYZON';
700dA          opztrk = $zhtruk;
700dA          opzzon = $zhzone;
710bA        when $psubcmd = '*COPYZONW';
710bA          opztrk = $zhtruk;
710bA          opzzon = $zhzone;
710bA          // Set fields

710bA          if $opclvlu;
710bA            opclvl = $opclvl;
710bA          endif;

710bA          if $opcwrau;
710bA            opcwra = $opcwra;
710bA          endif;

710bA          if $opcwrbu;
710bA            opcwrb = $opcwrb;
710bA          endif;

710bA          if $opuwrau;
710bA            opuwra = $opuwra;
710bA          endif;

710bA          if $opuwrbu;
710bA            opuwrb = $opuwrb;
710bA          endif;

710bA          if $operru;
710bA            operr = $operr;
710bA          endif;

710bA          if $opcwgtu;
710bA            opcwgt = $opcwgt;
710bA          endif;

710bA          if $opaislu;
710bA            opaisl = $opaisl;
710bA          endif;

710bA          if $optaxru;
710bA            optaxr = $optaxr;
710bA          endif;

710bA          if $opchkru;
710bA            opchkr = $opchkr;
710bA          endif;
710bA          opzdta = opzdt2;
700dA      endsl;
           monitor;
             write opzrec;
           on-error;
             if copyErr;
               $pmessage = %trimr($pmessage) + '/*PICKLBL-' + f3messageid;
             else;
               error = *on;
               copyErr = *on;
               $preturn = 'ERRCOPY';
               $pmessage = 'Copy err '
                         + %Trim(%editc(opzwhs:'Z'))
                         + '/'
                         + %trim(opztrk)
                         + '/'
                         + %trim(opzzon)
                         + '/*PICKLBL-' + f3messageid;
             endif;
           endmon;
         endif;

         chain(n) ('*PICKLBA': $zhwhse: $zhfrmtruk: kyzone) optionz;
         if %found(optionz);
700dA      select;
700dA        when $psubcmd = '*COPYTPL';
               opztrk = $zhtruk;
               opzzon = kyzone;
700dA        when $psubcmd = '*COPYZON';
700dA          opztrk = $zhtruk;
700dA          opzzon = $zhzone;
710bA        when $psubcmd = '*COPYZONW';
710bA          opztrk = $zhtruk;
710bA          opzzon = $zhzone;
710bA          // Set fields

710bA          if $oplb1u;
710bA            oplb1 = $oplb1;
710bA          endif;

710bA          if $opcu1u;
710bA            opcu1 = $opcu1;
710bA          endif;

710bA          if $oplp1u;
710bA            oplp1 = $oplp1;
710bA          endif;

710bA          if $opdv1u;
710bA            opdv1 = $opdv1;
710bA          endif;

710bA          if $opfm1u;
710bA            opfm1 = $opfm1;
710bA          endif;

710bA          if $oplb2u;
710bA            oplb2 = $oplb2;
710bA          endif;

710bA          if $opcu2u;
710bA            opcu2 = $opcu2;
710bA          endif;

710bA          if $oplp2u;
710bA            oplp2 = $oplp2;
710bA          endif;

710bA          if $opdv2u;
710bA            opdv2 = $opdv2;
710bA          endif;

710bA          if $opfm2u;
710bA            opfm2 = $opfm2;
710bA          endif;

710bA          if $oplb3u;
710bA            oplb3 = $oplb3;
710bA          endif;

710bA          if $opcu3u;
710bA            opcu3 = $opcu3;
710bA          endif;

710bA          if $oplp3u;
710bA            oplp3 = $oplp3;
710bA          endif;

710bA          if $opdv3u;
710bA            opdv3 = $opdv3;
710bA          endif;

710bA          if $opfm3u;
710bA            opfm3 = $opfm3;
710bA          endif;
710bA          opzdta = opzdt3;
700dA      endsl;
           monitor;
             write opzrec;
           on-error;
             if copyErr;
               $pmessage = %trimr($pmessage) + '/*PICKLBA-' + f3messageid;
             else;
               error = *on;
               copyErr = *on;
               $preturn = 'ERRCOPY';
               $pmessage = 'Copy err '
                         + %Trim(%editc(opzwhs:'Z'))
                         + '/'
                         + %trim(opztrk)
                         + '/'
                         + %trim(opzzon)
                         + '/*PICKLBA-' + f3messageid;
             endif;
           endmon;
         endif;

         chain(n) ('*PICKLBB': $zhwhse: $zhfrmtruk: kyzone) optionz;
         if %found(optionz);
700dA      select;
700dA        when $psubcmd = '*COPYTPL';
               opztrk = $zhtruk;
               opzzon = kyzone;
700dA        when $psubcmd = '*COPYZON';
700dA          opztrk = $zhtruk;
700dA          opzzon = $zhzone;
710bA        when $psubcmd = '*COPYZONW';
710bA          opztrk = $zhtruk;
710bA          opzzon = $zhzone;
710bA          // Set fields

710bA          if $oplb4u;
710bA            oplb4 = $oplb4;
710bA          endif;

710bA          if $opcu4u;
710bA            opcu4 = $opcu4;
710bA          endif;

710bA          if $oplp4u;
710bA            oplp4 = $oplp4;
710bA          endif;

710bA          if $opdv4u;
710bA            opdv4 = $opdv4;
710bA          endif;

710bA          if $opfm4u;
710bA            opfm4 = $opfm4;
710bA          endif;

710bA          if $oplb5u;
710bA            oplb5 = $oplb5;
710bA          endif;

710bA          if $opcu5u;
710bA            opcu5 = $opcu5;
710bA          endif;

710bA          if $oplp5u;
710bA            oplp5 = $oplp5;
710bA          endif;

710bA          if $opdv5u;
710bA            opdv5 = $opdv5;
710bA          endif;

710bA          if $opfm5u;
710bA            opfm5 = $opfm5;
710bA          endif;

710bA          if $oplb6u;
710bA            oplb6 = $oplb6;
710bA          endif;

710bA          if $opcu6u;
710bA            opcu6 = $opcu6;
710bA          endif;

710bA          if $oplp6u;
710bA            oplp6 = $oplp6;
710bA          endif;

710bA          if $opdv6u;
710bA            opdv6 = $opdv6;
710bA          endif;

710bA          if $opfm6u;
710bA            opfm6 = $opfm6;
710bA          endif;

710bA          if $oplb7u;
710bA            oplb7 = $oplb7;
710bA          endif;
710bA          opzdta = opzdt4;
700dA      endsl;
           monitor;
             write opzrec;
           on-error;
             if copyErr;
               $pmessage = %trimr($pmessage) + '/*PICKLBB-' + f3messageid;
             else;
               error = *on;
               copyErr = *on;
               $preturn = 'ERRCOPY';
               $pmessage = 'Copy err '
                         + %Trim(%editc(opzwhs:'Z'))
                         + '/'
                         + %trim(opztrk)
                         + '/'
                         + %trim(opzzon)
                         + '/*PICKLBB-' + f3messageid;
             endif;
           endmon;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  optiondel  Delete Optionz records
     *----------------------------------------------------------------

     C     optiondel     begsr
      /free

700dD    //chain(n) ('*PICK': zhwhse: zhtruk: zhzone) optionz;
700dM    chain ('*PICK': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           delete(e) opzrec;
           if %error;
           endif;
         endif;

700dD    //chain(n) ('*PICKLBL': zhwhse: zhtruk: zhzone) optionz;
700dM    chain ('*PICKLBL': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           delete(e) opzrec;
           if %error;
           endif;
         endif;

700dD    //chain(n) ('*PICKLBA': zhwhse: zhtruk: zhzone) optionz;
700dM    chain ('*PICKLBA': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           delete(e) opzrec;
           if %error;
           endif;
         endif;

700dD    //chain(n) ('*PICKLBB': zhwhse: zhtruk: zhzone) optionz;
700dM    chain ('*PICKLBB': zhwhse: zhtruk: zhzone) optionz;
         if %found(optionz);
           delete(e) opzrec;
           if %error;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  optionupd  Update OptionD record. Create if it doesn't exist.
     *----------------------------------------------------------------

     C     optionupd     begsr
      /free

         exsr opzPick;
         if error;
           leavesr;
         endif;

         exsr opzPickLbl;
         if error;
           leavesr;
         endif;

         exsr opzPickLbA;
         if error;
           leavesr;
         endif;

         exsr opzPickLbB;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  opzPick   Update Optionz *PICK record
     *----------------------------------------------------------------

     C     opzPick       begsr
      /free

         // Get record if it exists

         chain ('*PICK': $zhwhse: $zhtruk: $zhzone) optionz;

         if %found(optionz);
           opzdt1 = opzdta;
         else;
           opzcod = '*PICK';
           clear opzdt1;
           opzwhs = $zhwhse;
           opztrk = $zhtruk;
           opzzon = $zhzone;
         endif;

         // Set fields

         if $opfpalu;
           opfpal = $opfpal;
         endif;

         if $opfcubu;
           opfcub = $opfcub;
         endif;

         if $opfstpu;
           opfstp = $opfstp;
         endif;

720bA    if $opsstpu;
720bA      opsstp = $opsstp;
720bA    endif;

740aA    if $ozrfzpu;
740aA      ozrfzp = $ozrfzp;
740aA    endif;

740bA    if $opicubu;
740bA      opicub = $opicub;
740bA    endif;

740bA    if $oppispltu;
740bA      oppisplt = $oppisplt;
740bA    endif;

750 A    if $oppstuffu;
750 A      oppstuff = $oppstuff;
750 A    endif;

750aA    if $oppmspu;
750aA      oppmsp = $oppmsp;
750aA    endif;

750aA    if $oppmstpu;
750aA      oppmstp = $oppmstp;
750aA    endif;

750aA    if $oppmordu;
750aA      oppmord = $oppmord;
750aA    endif;

740bA    if $opmscbu;
740bA      opmscb = $opmscb;
740bA    endif;

740bA    if $opmsvhu;
740bA      opmsvh = $opmsvh;
740bA    endif;

740bA    if $opmsvmu;
740bA      opmsvm = $opmsvm;
740bA    endif;

740bA    if $opmsvlu;
740bA      opmsvl = $opmsvl;
740bA    endif;

740bA    if $opoacbu;
740bA      opoacb = $opoacb;
740bA    endif;

740bA    if $opzpltu;
740bA      opzplt = $opzplt;
740bA    endif;

740bA    if $opbpltu;
740bA      opbplt = $opbplt;
740bA    endif;

         if $opbpcku;
           opbpck = $opbpck;
         endif;

         if $oppbldu;
           oppbld = $oppbld;
         endif;

         if $opnwplu;
           opnwpl = $opnwpl;
         endif;

         if $opfordu;
           opford = $opford;
         endif;

         if $opptypu;
           opptyp = $opptyp;
         endif;

         if $optecbu;
           optecb = $optecb;
         endif;

         if $opticbu;
           opticb = $opticb;
         endif;

         if $optordu;
           optord = $optord;
         endif;

         if $optpcsu;
           optpcs = $optpcs;
         endif;

         if $opstopu;
           opstop = $opstop;
         endif;

         if $oppkupu;
           oppkup = $oppkup;
         endif;

         if $opspalu;
           opspal = $opspal;
         endif;

         if $oppitmu;
           oppitm = $oppitm;
         endif;

650bA    if $oplblu;
650bA      oplbl = $oplbl;
650bA    endif;

700bA    if $opmcubu;
700bA      opmcub = $opmcub;
700bA    endif;

700bA    if $oppmtzu;
700bA      oppmtz = $oppmtz;
700bA    endif;

700bA    if $opdddou;
700bA      opdddo = $opdddo;
700bA    endif;

710aA    if $opnbpsu;
710aA      opnbps = $opnbps;
710aA    endif;

720aA    if $opfwgtu;
720aA      opfwgt = $opfwgt;
720aA    endif;

720aA    if $opfpltu;
720aA      opfplt = $opfplt;
720aA    endif;

720aA    if $opbsequ;
720aA      opbseq = $opbseq;
720aA    endif;

         // Add/Update record

         opzdta = opzdt1;
         if %found(optionz);
           update(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRUPDOPZ';
             $pmessage = 'Error on "Update OPZ *PICK" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         else;
           write(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRADDOPZ';
             $pmessage = 'Error on "Write OPZ *PICK" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  opzPickLbl   Update Optionz *PICKLBL record
     *----------------------------------------------------------------

     C     opzPickLbl    begsr
      /free

         // Get record if it exists

         chain ('*PICKLBL': zhwhse: zhtruk: zhzone) optionz;

         if %found(optionz);
           opzdt2 = opzdta;
         else;
           opzcod = '*PICKLBL';
           clear opzdt2;
           opzwhs = $zhwhse;
           opztrk = $zhtruk;
           opzzon = $zhzone;
         endif;

         // Set fields

         if $opclvlu;
           opclvl = $opclvl;
         endif;

         if $opcwrau;
           opcwra = $opcwra;
         endif;

         if $opcwrbu;
           opcwrb = $opcwrb;
         endif;

         if $opuwrau;
           opuwra = $opuwra;
         endif;

         if $opuwrbu;
           opuwrb = $opuwrb;
         endif;

         if $operru;
           operr = $operr;
         endif;

         if $opcwgtu;
           opcwgt = $opcwgt;
         endif;

         if $opaislu;
           opaisl = $opaisl;
         endif;

         if $optaxru;
           optaxr = $optaxr;
         endif;

         if $opchkru;
           opchkr = $opchkr;
         endif;

         // Add/Update record

         opzdta = opzdt2;
         if %found(optionz);
           update(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRUPDOPZ';
             $pmessage = 'Error on "Update OPZ *PICKLBL" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         else;
           write(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRADDOPZ';
             $pmessage = 'Error on "Write OPZ *PICKLBL" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  opzPickLbA   Update Optionz *PICKLBA record
     *----------------------------------------------------------------

     C     opzPickLbA    begsr
      /free

         // Get record if it exists

         chain ('*PICKLBA': zhwhse: zhtruk: zhzone) optionz;

         if %found(optionz);
           opzdt3 = opzdta;
         else;
           opzcod = '*PICKLBA';
           clear opzdt3;
           opzwhs = $zhwhse;
           opztrk = $zhtruk;
           opzzon = $zhzone;
         endif;

         // Set fields

         if $oplb1u;
           oplb1 = $oplb1;
         endif;

         if $opcu1u;
           opcu1 = $opcu1;
         endif;

         if $oplp1u;
           oplp1 = $oplp1;
         endif;

         if $opdv1u;
           opdv1 = $opdv1;
         endif;

         if $opfm1u;
           opfm1 = $opfm1;
         endif;

         if $oplb2u;
           oplb2 = $oplb2;
         endif;

         if $opcu2u;
           opcu2 = $opcu2;
         endif;

         if $oplp2u;
           oplp2 = $oplp2;
         endif;

         if $opdv2u;
           opdv2 = $opdv2;
         endif;

         if $opfm2u;
           opfm2 = $opfm2;
         endif;

         if $oplb3u;
           oplb3 = $oplb3;
         endif;

         if $opcu3u;
           opcu3 = $opcu3;
         endif;

         if $oplp3u;
           oplp3 = $oplp3;
         endif;

         if $opdv3u;
           opdv3 = $opdv3;
         endif;

         if $opfm3u;
           opfm3 = $opfm3;
         endif;

         // Add/Update record

         opzdta = opzdt3;
         if %found(optionz);
           update(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRUPDOPZ';
             $pmessage = 'Error on "Update OPZ *PICKLBA" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         else;
           write(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRADDOPZ';
             $pmessage = 'Error on "Write OPZ *PICKLBA" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  opzPickLbB   Update Optionz *PICKLBB record
     *----------------------------------------------------------------

     C     opzPickLbB    begsr
      /free

         // Get record if it exists

         chain ('*PICKLBB': zhwhse: zhtruk: zhzone) optionz;

         if %found(optionz);
           opzdt4 = opzdta;
         else;
           opzcod = '*PICKLBB';
           clear opzdt4;
           opzwhs = $zhwhse;
           opztrk = $zhtruk;
           opzzon = $zhzone;
         endif;

         // Set fields

         if $oplb4u;
           oplb4 = $oplb4;
         endif;

         if $opcu4u;
           opcu4 = $opcu4;
         endif;

         if $oplp4u;
           oplp4 = $oplp4;
         endif;

         if $opdv4u;
           opdv4 = $opdv4;
         endif;

         if $opfm4u;
           opfm4 = $opfm4;
         endif;

         if $oplb5u;
           oplb5 = $oplb5;
         endif;

         if $opcu5u;
           opcu5 = $opcu5;
         endif;

         if $oplp5u;
           oplp5 = $oplp5;
         endif;

         if $opdv5u;
           opdv5 = $opdv5;
         endif;

         if $opfm5u;
           opfm5 = $opfm5;
         endif;

         if $oplb6u;
           oplb6 = $oplb6;
         endif;

         if $opcu6u;
           opcu6 = $opcu6;
         endif;

         if $oplp6u;
           oplp6 = $oplp6;
         endif;

         if $opdv6u;
           opdv6 = $opdv6;
         endif;

         if $opfm6u;
           opfm6 = $opfm6;
         endif;

         if $oplb7u;
           oplb7 = $oplb7;
         endif;

         // Add/Update record

         opzdta = opzdt4;
         if %found(optionz);
           update(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRUPDOPZ';
             $pmessage = 'Error on "Update OPZ *PICKLBB" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         else;
           write(e) opzrec;
           if %error;
             error = *on;
             $preturn = 'ERRADDOPZ';
             $pmessage = 'Error on "Write OPZ *PICKLBB" '
                       + '(' + %Trim(%editc(opzwhs:'Z'))
                       + '/' + %trim(opztrk) + '/' + %trim(opzzon) + ')'
                       + '-' + f3messageid;
             leavesr;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify dept information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr
      /free

         // Do general verification 1

         exsr verifygen1;
         if error;
           leavesr;
         endif;

         // Zone code cannot be blank

         if $zhzone = ' ';
           error = *on;
           $zhzonee = $drierror;
           $preturn = 'BLANKZONE';
           $pmessage = 'Zone code cannot be blank';
           leavesr;
         endif;

         // Zone code cannot have embedded blanks

         blankPos = %scan(' ': $zhzone);
         codeLen = %len(%trimr($zhzone));
         if (blankPos <> 0) and (blankPos-1 <> codeLen);
           error = *on;
           $zhzonee = $drierror;
           $preturn = 'EMBEDBLANK';
           $pmessage = 'Zone code cannot have embedded blank';
           leavesr;
         endif;

         // Zone cannot already exist.

         chain(n) ($zhwhse: $zhtruk: $zhzone) zoneh;
         if %found(zoneh);
           error = *on;
           $zhzonee = $drierror;
           $preturn  = 'ZONEEXIST';
           $pmessage = 'Zone not added - '
                     + 'Already exists ('
                     + %Trim(%editc($zhwhse:'Z'))
                     + '/'
                     + %trim($zhtruk)
                     + '/'
                     + %trim($zhzone)
                     + ')';
         endif;

         // Do general verification 2

         exsr verifygen2;
         if error;
           leavesr;
         endif;

      /end-free
     C     endvfyadd     endsr

     *----------------------------------------------------------------
     *  verifychg   Verfify slot information for change
     *----------------------------------------------------------------

     C     verifychg     begsr
      /free

         // Do general verification 1

         exsr verifygen1;
         if error;
           leavesr;
         endif;

         // Do general verification 2

         exsr verifygen2;
         if error;
           leavesr;
         endif;

         // Get & lock record

         if $psubcmd = '*CHANGE';
           lock = *on;
         else;
           lock = *off;
         endif;
         exsr getzoneh;
         if error;
           $zhzonee = $drierror;
           leavesr;
         endif;

      /end-free
     C                   endsr

650cA*----------------------------------------------------------------
650cA*  verifycpyt   Verify zone template copy
650cA*----------------------------------------------------------------
650cA
650cAC     verifycpyt    begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzhwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhtrukSent;
         if error;
           leavesr;
         endif;

      /end-free
     C     endvfycpyt    endsr

650cA*----------------------------------------------------------------
650cA*  verifycpyz    Verify zone copy
650cA*----------------------------------------------------------------
650cA
650cAC     verifycpyz    begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzhwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhtrukSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhzoneSent;
         if error;
           leavesr;
         endif;

         // Zone code cannot be blank

         if $zhzone = ' ';
           error = *on;
           $zhzonee = $drierror;
           $preturn = 'BLANKZONE';
           $pmessage = 'Zone code cannot be blank';
           leavesr;
         endif;

         // Zone code cannot have embedded blanks

         blankPos = %scan(' ': $zhzone);
         codeLen = %len(%trimr($zhzone));
         if (blankPos <> 0) and (blankPos-1 <> codeLen);
           error = *on;
           $zhzonee = $drierror;
           $preturn = 'EMBEDBLANK';
           $pmessage = 'Zone code cannot have embedded blank';
           leavesr;
         endif;

         // Zone cannot already exist.

         chain(n) ($zhwhse: $zhtruk: $zhzone) zoneh;
         if %found(zoneh);
           error = *on;
           $zhzonee = $drierror;
           $preturn  = 'ZONEEXIST';
           $pmessage = 'Zone not added - '
                     + 'Already exists ('
                     + %Trim(%editc($zhwhse:'Z'))
                     + '/'
                     + %trim($zhtruk)
                     + '/'
                     + %trim($zhzone)
                     + ')';
         endif;

      /end-free
     C     endvfycpyz    endsr

650dA*----------------------------------------------------------------
650dA*  verifydelt   Verify zone template delete
650dA*----------------------------------------------------------------
650dA
650dAC     verifydelt    begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzhwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhtrukSent;
         if error;
           leavesr;
         endif;

      /end-free
     C     endvfydelt    endsr

650dA*----------------------------------------------------------------
650dA*  verifydelz    Verify zone delete
650dA*----------------------------------------------------------------
650dA
650dAC     verifydelz    begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzhwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhtrukSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhzoneSent;
         if error;
           leavesr;
         endif;

      /end-free
     C     endvfydelz    endsr

     *----------------------------------------------------------------
     *  verifygen1   General verification 1
     *----------------------------------------------------------------

     C     verifygen1    begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzhwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhtrukSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhzoneSent;
         if error;
           leavesr;
         endif;

         exsr vfyopptypSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhcompSent;
         if error;
           leavesr;
         endif;

         exsr vfyzhpzonSent;
         if error;
           leavesr;
         endif;

         // Warehouse must exist

         exsr vfyzhwhse;
         if error;
           leavesr;
         endif;

         // Truck must exist

         exsr vfyzhtruk;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  verifygen2   General verification 2
     *----------------------------------------------------------------

     C     verifygen2    begsr
      /free

         // Get Truck Builder Light flag

         $gfCmd = '*GET';
         $gfWhse = $zhwhse;
         getFeat ($gfCmd: $gfwhse: $gfFeature: $gfLight);
         if $gfLight = 'Y';
           tbLight = *on;
         else;
           tbLight = *off;
         endif;

         // Truck Builder Light - Zone must be a 'P' or 'M' type

740bD    //if tbLight and $opptyp <> 'P' and $opptyp <> 'M';
         if tbLight and $opptyp <> 'P' and $opptyp <> 'M'
740bM               and $opptyp <> 'O';
           error = *on;
           $opptype = $drierror;
           $preturn  = 'INVLDTYPE1';
           $pmessage = 'Zone type must be ''P'' for TB Light version';
           leavesr;
         endif;

         // Verify zone type.

640aD    //chain ($opptyp) zonetype;
640aD    //if not %found(zonetype);

700cD    //exec sql select gc1code into :tmp1 from bfcglobalf/glo1codes
700cM    exec sql select gc1code into :tmp1 from glo1codes
640aM             where gc1type='ZONETYPE' and gc1code=:$opptyp;

640aM    If sqlstt <> sqlSuccess;
           error = *on;
           $opptype = $drierror;
           $preturn  = 'INVLDTYPE2';
           $pmessage = 'Invalid zone type';
           leavesr;
         endif;

         // If zone type is 'S', check to see if it is allowed

         if $opptyp = 'S';
           exsr vfyIsSZoneOk;
           if error;
             leavesr;
           endif;
         endif;

         // Parent zone cannot be entered when compartment is not blank

         if $zhcomp <> ' ' and $zhpzon <> ' ';
           error = *on;
           $zhcompe = $drierror;
           $preturn  = 'COMPPZON1';
           $pmessage = 'Compartment and Parent zone cannot be entered together';
           leavesr;
         endif;

         // Parent zone must be entered when compartment is blank

         if $zhcomp = ' ' and $zhpzon = ' ';
           error = *on;
           $zhcompe = $drierror;
           $preturn  = 'COMPPZON2';
           $pmessage = 'Compartment or Parent zone must be entered';
           leavesr;
         endif;

         // If zone type is 'T', then compartment must be blank

         if $opptyp = 'T' and $zhcomp <> ' ';
           error = *on;
           $zhcompe = $drierror;
           $preturn  = 'CMPNOTBLNK';
           $pmessage = 'Compartment not allowed for Tote zone';
           leavesr;
         endif;

         // If zone type is 'B' or 'S', then parent zone not allowed

         if ($opptyp = 'B' or $opptyp = 'S')
           and $zhpzon <> ' ';
             error = *on;
             $zhpzone = $drierror;
             $preturn  = 'PZNNOTBLNK';
             $pmessage = 'Parent zone not allowed for ''B'' and ''S'' zones';
             leavesr;
         endif;

         // Parent zone cannot be the same as current zone

         if $zhzone = $zhpzon;
           error = *on;
           $zhpzone = $drierror;
           $preturn  = 'SAMEZONE';
           $pmessage = 'Parent zone cannot be same as zone being edited';
           leavesr;
         endif;

         // Picked Up By cannot be entered with compartment

         if $oppkup <> ' ' and $zhcomp <> ' ';
           error = *on;
           $oppkupe = $drierror;
           $preturn  = 'PKUPNOTALW';
           $pmessage = 'Picked Up By not allowed with compartment';
           leavesr;
         endif;

         // Picked Up By must be entered with parent zone

         if $oppkup = ' ' and $zhpzon <> ' ';
           error = *on;
           $oppkupe = $drierror;
           $preturn  = 'PKUPNOTENT';
           $pmessage = 'Picked Up By must be entered with parent zone';
           leavesr;
         endif;

         // Verify compartment code

         if $zhcomp <> ' ';
           chain(n) ($zhwhse: $zhcomp) trkcomp;
640aD      //if %found(trkcomp);
640aM      if not %found(trkcomp);
             error = *on;
             $zhcompe = $drierror;
             $preturn  = 'INVLDCOMP';
             $pmessage = 'Invalid compartment code (' + $zhcomp + ')';
             leavesr;
           endif;
         endif;

         // Verify parent zone

         if $zhpzon <> ' ';
           chain(n) ($zhwhse: $zhtruk: $zhpzon) zoneh;
           if not %found(zoneh);
             error = *on;
             $zhpzone = $drierror;
             $preturn  = 'INVLDPZONE';
             $pmessage = 'Invalid Parent Zone '
                       + '('
                       + %Trim(%editc($zhwhse:'Z'))
                       + '/'
                       + %trim($zhtruk)
                       + '/'
                       + %trim($zhpzon)
                       + ')';
             leavesr;
           endif;
         endif;

         // Parent zone cannot be a Tote or Separate Pick zone.

         if $zhpzon <> ' ';
           exsr getopt;
           if opptyp = 'T' or opptyp = 'S';
             error = *on;
             $zhpzone = $drierror;
             $preturn  = 'INVLDPZON2';
             $pmessage = 'Parent zone cannot be an ''S'' or ''T'' zone';
             leavesr;
           endif;
         endif;

         // Verify Picked Up By

640aD    //chain ($oppkup) mrgtype;
640aD    //if not %found(mrgtype);

640aA    if $zhcomp = ' ';

700cD    //exec sql select gc1code into :tmp1 from bfcglobalf/glo1codes
700cM      exec sql select gc1code into :tmp1 from glo1codes
640aM               where gc1type='PICKUPBY' and gc1code=:$oppkup;

640aM      If sqlstt <> sqlSuccess;
             error = *on;
             $oppkupe = $drierror;
             $preturn  = 'INVLDPKUP1';
             $pmessage = 'Invalid value for Picked Up By';
             leavesr;
           endif;

640aA    endif;

         // Truck Builder Light - Only allow 'S' Picked Up By

         if tbLight and $oppkup <> 'S';
           error = *on;
           $oppkupe = $drierror;
           $preturn  = 'INVLDPKUP2';
           $pmessage = 'Invalid Prevent SP Picks option';
           $pmessage = 'Picked Up By must be ''S'' for TB Light version';
           leavesr;
         endif;

740bA    // Truck Builder *SP Less than Cube option
740bA
740bA    if $opmscb<>0 and $opmsvh=' ' and $opmsvm=' ' and $opmsvl=' ';
740bA      error = *on;
740bA      $oppkupe = $drierror;
750bM      $preturn  = 'INVLDPLTP1';
740bA      $pmessage = 'When *SP merged w/oth pallets, must specify' +
740bA                  ' pallet position';
740bA      leavesr;
         endif;
740bA
750bD**  if $opmscb=0 and $opmsvh<>' ' or $opmsvm<>' ' or $opmsvl<>' ';
750bM    if $opmscb=0
750bM    and ($opmsvh<>' ' or $opmsvm<>' ' or $opmsvl<>' ');
740bA      error = *on;
740bA      $oppkupe = $drierror;
750bM      $preturn  = 'INVLDPLTP2';
740bA      $pmessage = 'When *SP pallet position selected, must ' +
740bA                  ' specify cube';
740bA      leavesr;
         endif;

         // Verify SP option

         if $opstop <> 'Y' and $opstop <> 'N';
           error = *on;
           $opstope = $drierror;
           $preturn  = 'INVLDSTOP';
           $pmessage = 'Invalid Prevent SP Picks option';
           leavesr;
         endif;

PFGaA    // PFG - Loader Merge option not allow.  Causes issues
         //       Food Star

PFGaA    if client = pfg and $oppkup = 'L';
PFGaA      error = *on;
PFGaA      $opstope = $drierror;
PFGaA      $preturn  = 'INVLD#PU';
PFGaA      $pmessage = 'Picked up by Loader not allowed. Issues with Food Star';
PFGaA      leavesr;
PFGaA    endif;

USFaA    // USF - Number of Pallet Sections - Maximum 3

USFbD    //if client = usfcorp and $opnbps > 3;
USFbD    //  error = *on;
USFbD    //  $opstope = $drierror;
USFbD    //  $preturn  = 'INVLD#PS';
USFbD    //  $pmessage = 'Invalid Number of Pallet Sections';
USFbD    //  leavesr;
USFbD    //endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Field Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyIsSZoneOk   Check if S zone is allowed
     *----------------------------------------------------------------

     C     vfyIsSZoneOk  begsr

      /free

         // Only one 'S' zone is allowed.

         setll ($zhwhse: $zhtruk) zoneh;

         dow forever = forever;

           reade(n) ($zhwhse: $zhtruk) zoneh;

           if %eof(zoneh);
             leave;
           endif;

           // If zone is 'S', return error.

           chain(n) ('*PICK': zhwhse: zhtruk: zhzone) optionz;
           if %found(optionz);
             opzdt1 = opzdta;
             if opptyp = 'S';
               error = *on;
               $preturn  = 'SZONEEXIST';
               $pmessage = 'Cannot create S zone - Already defined';
               leavesr;
             endif;
           endif;

         enddo;

         // 'PRE' aisle cannot be used in another zone.

         setll ($zhwhse: $zhtruk) zoned1;

         dow forever = forever;

           reade(n) ($zhwhse: $zhtruk) zoned1;

           if %eof(zoned1);
             leave;
           endif;

           // If aisle is 'PRE', return error.

           if zdaisl = 'PRE';
             error = *on;
             $preturn  = 'SZONEEXIST';
             $pmessage = 'Cannot create S zone - '
                       + 'Aisle PRE used in zone def';
             leavesr;
           endif;

         enddo;

      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  vfyzhwhse      Verify warehouse
     *----------------------------------------------------------------

     C     vfyzhwhse     begsr
      /free

         vfyWhseCalled = *on;
         vfyWhse('*VERIFY': '*NONE': $zhwhse: $vdesc:
                 $vreturn: $vmessage: $vmsgk);

         select;

           when %error;
             error = *on;
             $zhwhsee = $drierror;
             $preturn  = 'CALLERROR';
             $pmessage = 'Error occured on call to VFYWHSE/'
                       + %trim($vcommand) + ' from ' + #pgm;

           when $vreturn <> '*OK';
             error = *on;
             $zhwhsee = $drierror;
             $preturn = $vreturn;
             $pmessage = $vmessage;

         endsl;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzhtruk      Verify truck
     *----------------------------------------------------------------

     C     vfyzhtruk     begsr
      /free

         chain(n) ($zhwhse: $zhtruk) truckh;
         if not %found(truckh);
           error = *on;
           $zhtruke = $drierror;
           $preturn  = 'TRUKNOTFND';
           $pmessage = 'Truck must exist '
                     + '('
                     + %Trim(%editc($zhwhse:'Z'))
                     + '/'
                     + %trim($zhtruk)
                     + ')';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Sent Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyzhcompSent  Verify comparment was sent
     *----------------------------------------------------------------

     C     vfyzhcompSent begsr
      /free

         if not $zhcompu;
           error = *on;
           $zhtruke = $drierror;
           $preturn  = 'COMPNOTSNT';
           $pmessage = 'Compartment must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyopptypSent  Verify zone type was sent
     *----------------------------------------------------------------

     C     vfyopptypSent begsr
      /free

         if not $opptypu;
           error = *on;
           $zhtruke = $drierror;
           $preturn  = 'PTYPNOTSNT';
           $pmessage = 'Zone type must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzhpzonSent  Verify parent zone was sent
     *----------------------------------------------------------------

     C     vfyzhpzonSent begsr
      /free

         if not $zhpzonu;
           error = *on;
           $zhtruke = $drierror;
           $preturn  = 'PZONNOTSNT';
           $pmessage = 'Parent zone must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzhtrukSent  Verify truck was sent
     *----------------------------------------------------------------

     C     vfyzhtrukSent begsr
      /free

         if not $zhtruku;
           error = *on;
           $zhtruke = $drierror;
           $preturn  = 'TRUKNOTSNT';
           $pmessage = 'Truck code must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzhwhseSent  Verify warehouse was sent
     *----------------------------------------------------------------

     C     vfyzhwhseSent begsr
      /free

         if not $zhwhseu;
           error = *on;
           $zhwhsee = $drierror;
           $preturn  = 'WHSNOTSNT';
           $pmessage = 'Warehouse must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzhzoneSent  Verify zone was sent
     *----------------------------------------------------------------

     C     vfyzhzoneSent begsr
      /free

         if not $zhzoneu;
           error = *on;
           $zhtruke = $drierror;
           $preturn  = 'ZONENOTSNT';
           $pmessage = 'Zone code must be sent';
         endif;

      /end-free
     C                   endsr
