      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DRIAPT    Dakota realtime interface - APT
     *  September 30, 2011
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*    09/30/11  RTR  6.40
     *      - Created.
     *
650aA*    02/27/13  RTR  6.50a
     *      - FIX for KVI2 on full pallet slots
     *      - FIX for KVI5 on rotation return
     *
650bA*    07/28/13  RTR  6.50b
     *      - FIX in ZZAPTDEPT to check TRUCKH for proper ZONEH link
     *        for customers using newer zone templates.
650cA*    08/12/13  RTR  6.50c
     *      - FIX in ProcSelection for KVI6 when catchweight item,
     *        should be qty picked not constant 1.
650dA*    08/19/13  RTR  6.50d
     *      - FIX in in ZZAPTDEPT2 for indirect tasks.
650eA*    08/20/13  RTR  6.50e
     *      - Change to rotation pallets for floor slots.
     *      - Change for location number on route LOD records.
650fA*    08/21/13  RTR  6.50f
     *      - Change to quantity for rplend when catchweight items.
650gA*    08/27/13  RTR  6.50g
     *      - Remove spaces from #aopfline on route LOD records.
650hA*    09/19/13  RTR  6.50h
     *      - change procpicksum selections for FRF.
650iA*    10/31/13  RTR  6.50i
     *      - change to testtype/gettasktype to allow tfrbeg/tfrend
     *        to get task id from the task desc. previously this was
     *        only done for calls for *JOB0100, now can be done for
     *        others with exsr gettasktype.
650jA*    11/21/13  RTR  6.50j
     *      - change to not return deceptive DRI error text when record
     *        was actually created.
650kA*    04/17/14  RTR  6.50k
     *      - Changing mod 650f to convert KVI2 qtys always for FRF
     *        because they have no 'HS' slot type and if item is catch
     *        weight item it needs to be converted.
750eA*    09/17/21  DAS  7.50a
     *      - Added command *PREVLOC to set prevloc field. This was
     *        done initially for Putaway to set prevloc to the
     *        RCVDOCK slot. Otherwise, prevloc start out as blank then
     *        remembers last putaway location sent.
     *
740a *    10/18/20  RTR  7.40a
     *      - Changes for Presto Foods.
740b *    12/17/20  RTR  7.40b
     *      - Added PUTAWYBEG record.
750a *    02/25/21  RTR  7.50a
     *      - Fix for beginning location blank.
     *      - Fix for KVI3 on PUTAWYBEG.
     *      - Fix for KVI3 on PUTAWYBEG.
     *      - Added type of *RETURN.
750b *    05/02/21  RTR  7.50b
     *      - Fix for change to type in PLTSUM3 in upgrade.
750c *    05/10/21  RTR  7.50c
     *      - Fix for receiving tie in KVI2, high in KVI3. Was using
     *        from label record but not populated there.
750dA*    06/21/21  MLB  7.50d
     *      - Revised routines:bulkobtn,bulkend,pickplc,pickend,
     *        procbulkpick procmerge and procselection to change the
     *        transction number to strip leading zeros when loaded
     *        into field #aopfbtch.
750eA*    09/22/21  DAS  7.50e
     *      - Added subcmd *RPLEND3, which is sent from LT105/ZZUPD3
     *        when a Full replenishment is done. This is then used to
     *        set the KVI-1 Pallet value to 1.
750fA*    09/27/21  DAS  7.50f
     *      - Added OPTIONS file
     *      - Revised *INZSR to get *APTFTP option and set usingAPT flag
     *      - Revised beginning of pgm to get out if usingAPT is off.
750gA*    10/01/21  DAS  7.50g
     *      - Revised RPLEND to set KVI-8 to a zero if pick slot sdef
     *        is HS (was already doing that) or partial qty was
     *        replenished (was setting it to 1), otherwise set to 1.
     *      - Revised RPLPLC to set KVI-8 to a zero because RPLPLC
     *        is only sent for a partial replenishment, which is
     *        handstacking.
750hA*    10/06/21  DAS  7.50h
     *      - Revised RPLPLC to set KVI-2 to qty put into slot because
     *        RPLPLC is only sent for a paritial replenishment, which
     *        is handstacking.
750iA*    10/13/21  DAS  7.50i
     *      - Revised RPLEND/PLC to set KVI-8 to 0 if sdef=HS,
     *        otherwise, set it to 1.
750jA*    10/15/21  DAS  7.50j
     *      - Presto, only one using this at the time, for a
     *        replenishment, wants RPLEND to have a 1 if a full repln
     *        was done (*RPLEND3) or RPLPLC to have a 1 for a partial.
750kA*    10/19/21  MLB  7.50k
     *      - Pgm Chg: Per Fernando Avila disable *RETURN record data
     *        from being written into the APTDATA file. Email dated
     *        10.19.21.
     *      - Per Tom Butchko. Re-activate changes to send *RETURN rcd.
     *        on 11.08.21. Ph call w/Hemant.
750lA*    10/20/21  MLB  7.50l
     *      - Pgm Chg: Per Fernando Avila for Presto Foods. Revise
     *        routine ProcPickSum to assign Truck Compartments to APT
     *        summary codes: 1=Dry, 2=Cooler and 3=Freezer. Any com-
     *        partment codes not specified, will default to 1=Dry.
750mA*    10/22/21  MLB  7.50m
     *      - Presto changed mind and wanted HS Replen logic put back
     *      - Was previously 7.50l on Dev3.
750nA*    01/05/22  MLB  7.50n
     *      - Enh: Added support for Customer Returns information to
     *        be sent to APT.
     *      - Added file ORRTN1.
750pA*    01/26/22  MLB  7.50p
     *      - Enh: Revised 7.50n mod. Added test for lbtype = O or B.
     *        SQL was selecting M=Merge labels in error and returning
     *        wrong transaction number.
750qA*    02/22/22  KDE  7.50q
     *      - Enh: Revised write Route information for Y-Hata.  Call
     *        from APTRTESEL, which is called from RH155
     *
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

     *----------------------------------------------------------------
     *  Sub-Command Notes
     *
     *    Sub-Commands
     *
     *      *OPEN            Open program and return.
     *
     *      *CLOSE           Close program with *INLR = *ON
     *
     *      *BULKBEG         Begin bulk pick.
     *
     *      *BULKOBTN        Create new bulk pick "obtain" record.
     *
     *      *BULKEND         End bulk pick.
     *
750q *      *EXPTRN          Export Transaction data to APT end end time
     *
     *      *JOB0100         Create Indirect job code record.
     *
     *      *PICKBEG         Begin pick.
     *
     *      *PICKEND         End pick.
     *
     *      *PICKGEN         Pick generated (labels printed).
     *
     *      *PUTAWYBEG       Begin putaway.
     *
     *      *PUTAWYPLC       Create putaway "place" record.
     *      *PUTAWPLCE       Create putaway "actual/place" record. Last
     *                       record for assigment, but more license(s)
     *                       still to be put-away.
     *
     *      *PUTAWYEND       End putaway.
     *
     *      *PUTAWYGEN       Putaway generated (receiving)
     *
     *      *PUTRTNBEG       Begin return putaway.
     *
     *      *PUTRTNPLC       Create return putaway "place" record.
     *      *PUTRTPLCE       Create return putaway "actual/place" rcd.
     *                       Last record for assigment, but more
     *                       license(s) still to be put-away.
     *
     *      *PUTRTNEND       End return putaway.
     *
     *      *PUTRTNGEN       Putaway return generated (receiving)
     *
     *      *RCVBEG          Begin receive process. Create "obtain" rcd.
     *
750aA*      *RETURN          Return record.
750aA*
     *      *TFRBEG          Begin transfer.
     *
     *      *TFREND          End transfer.
     *
     *      *RPLBEG          Begin replenishment.
     *
     *      *RPLTRAVEL       Create Replenishment "Travel" record.
     *
     *      *RPLPLC          Create Replenishment "Place" record.
     *
     *      *RPLEND          End replenishment.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Faptdata   uf a e           k disk
     F                                     infds(file1ds)
     Flabel     if   e           k disk
     F                                     prefix(lb_)
     Flabel11   if   e           k disk    prefix(L11)
     F                                     rename(lbrec:lbrec11)
     Flabel32   if   e           k disk
     Flabel34   if   e           k disk
     F                                     prefix(L34)
     Fordh3     if   e           k disk
     F                                     prefix(oh3_)
750nAForrtn1    if   e           k disk
     Fpirtran   if   e           k disk
     Fpltsum3ap if   e           k disk
     F                                     rename(psrec:psrec3)
     F                                     prefix(PS3)
     Fpltsum4   if   e           k disk
     F                                     prefix(PS4)
     Frtehed    if   e           k disk
750fAFoptions   if   e           k disk
750qAfaptselwk1 if   e           k disk    usropn prefix(w_)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#allen
      /copy qcopysrc,id#usfcrp
      /copy qcopysrc,id#usfasys
      /copy qcopysrc,id#usfpsys
      /copy qcopysrc,id#ledyard
650dA /copy qcopysrc,id#frf
740aA /copy qcopysrc,id#pfc

     *----------------------------------------------------------------
     *  Program Prototype and Entry Parms
     *----------------------------------------------------------------
     d Main            pr                  extpgm('DRIAPT')
     d                               10
     d                               10
     d                               10
     d                               60
     d                              512
     d                              512
     d Main            pi
      /COPY *libl/qcopysrc,C#DRIPARME

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     D savesubcmd      s                   like($psubcmd)
     D savesubcmd2     s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#APT
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($apver#)
     D driitem         s               n   inz(*off)
     D drislot         s               n   inz(*off)
740bAd prvtrn        e ds                  extname(PIRTRAN) prefix(prv_)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D editw2          c                   '0  '
     D editw3          c                   '0   '
     D editw3nz        c                   '   0'
     D editw4          c                   '0    '
     D editw4nz        c                   '   0'
     D editw5          c                   '0     '
     D editw5nz        c                   '     0'
     D editw6          c                   '0      '
     D editw6nz        c                   '     0'
     D editw7          c                   '0       '
     D editu8          c                   '0        '
     D editw8          c                   '0   .   '
     D editw82         c                   '0    .  '
740aMD editw9z         c                   '       0 '
740aMD editw92         c                   '    0 .  '
740aMD editw93         c                   '   0 .   '
     D editu10         c                   ' 0         '
     D editw10nz       c                   '         0'
740aMD editw10z        c                   '        0 '
740aMD editw102        c                   '     0 .  '
740aMD editw103        c                   '    0 .   '
     D editw11         c                   '0           '
     D editw15         c                   '0               '

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D check4err       s               n
     D curdate         s               d   datfmt(*ISO)
     D mdydate         s              6  0
     D curtrn#         s                   like(lbtrn#)
     D custnbr6        s              6s 0
     D custnbr7        s              7s 0
     D custnbr8        s              8s 0
     D DakotaCall      s               n
     D shortpal#       s              2s 0
     D HostCall        s               n

     D kyitem          s                   like(lbitem)
     D kylbl#          s                   like(lblbl#)
750aAD kyord#          s                   like(lblbl#)
     D kylbtype        s                   like(lbtype)
     D kylbtrn#        s                   like(lbtrn#)
     D kypstype        s                   like(pstype)
     D kytrn#          s                   like(lbtrn#)
     D kytype          s                   like(pstype)
     D kywhse          s                   like(lbwhse)
     D kywhdp          s                   like(lbwhdp)
     D kydisp          s                   like(lbdisp)
     D kyrte           s                   like(lbrte)
     D lastpstrn#      s                   like(ps3pstrn#)
     D linseq6         s              6s 0
     D lstlbl#         s                   like(lblbl#)
     D lstpzon         s                   like(pspzon)
     D lstszon         s                   like(psszon)
     D lsttrn#         s                   like(pttrn#)
     D lsttype         s                   like(lbtype)
     D today           s                   like(ptgdte)
     D todaymdy        s              6s 0
     D tempdate        s              6s 0
     D rtvplandte      s              4a   inz('*NO ')
     D wrktrn#         s             15s 0
     D tt9998          s              4    inz('9998')
     D tf9999          s              4    inz('9999')
     D col             s              2  0
     D pos             s             10i 0
     D sectionid       s              1
     D client          s             10a
     D clientloc       s             10a
     D prevloc         s             10a
     D aislecount      s              6s 0
     D mergecount      s              6s 0
     D mergeind        s              2b 0
     D palletcount     s              6s 0
750lADpalletcount_oth  s              6s 0
     D palletrefer     s              6s 0
     D palletprod      s              6s 0
     D palletequip     s              6s 0
     D stopscount      s              6s 0
     D aptdeptcd       s              2a
     D apttempcd       s              1a
     D recswrote       s              1a
     d loadpick        s              5  0
     d loadcube        s              9  3
     d loadweight      s              9  2
750lAd loadpick_oth    s              5  0
750lAd loadcube_oth    s              9  3
750lAd loadweight_oth  s              9  2
     d zonedesc        s             30a
     d taskdesc        s             30a
     d tasktype        s              6a
     D prvtran         s                   like(lbtrn#)
     D prvtrnsdt       s                   like(ptedte)
     D prvtrnstm       s                   like(ptetim)
     D prvtrnedt       s                   like(ptedte)
     D prvtrnetm       s                   like(ptetim)
     D rcvitem         s                   like(lbitem)
     D rotatepals      s             10  0
650fAD wgtrem          s              5  0
750qAd editStr         s             20
750qAd wkTrnm          s              8  0

     d #whse           s              3  0
     d #emp#           s              5  0
     d #fnam           s             15a
     d #init           s              1a
     d #lnam           s             20a
     d #whdp           s              5a
     d #styp           s              1a
     d #shft           s              6a
     d #crew           s              6a
     d #nhrs           s              3  1
     d #rtn            s              8a

750fAd usingAPT        s               n

     *----------------------------------------------------------------
     *  Data Queue Variables
     *----------------------------------------------------------------

     D  dqdata         s            128
     D  dqlen          s              5  0
     D  dqlib          s             10    inz('*LIBL')
     D  dqname         s             10    inz('APTDTAQ')
     D  dqwaitsec      s              5  0 inz(600)

     D $qdata          ds
     D  $qcmd                  1      8
     D  $qwaitsec              9     13
     D  $qfilename             9     38
     D  $qend                128    128

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------

     d DriCop          pr                  extpgm('DRICOP')
     d  dcopcommand                  10a
     d  dcopsubcmd                   10a
     d  dcopsys2upd                   1a
     d  dcopprogram                  10a
     d  dcopreturn                   10a
     d  dcopmessage                  60a
     d  dcopdata                    512a

     d DriMain2        pr                  extpgm('DRIMAIN2')
     d  dparcommand                  10a
     d  dparsubcmd                   10a
     d  dparsys2upd                   1a
     d  dparprogram                  10a
     d  dparreturn                   10a
     d  dparmessage                  60a
     d  dpardata                    512a

     d DriItemPgm      pr                  extpgm('DRIITEM')
     d  dparsubcmd                   10a
     d  dparprogram                  10a
     d  dparreturn                   10a
     d  dparmessage                  60a
     d  dpardata                    512a

     d DriSlotPgm      pr                  extpgm('DRISLOT')
     d  dparsubcmd                   10a
     d  dparprogram                  10a
     d  dparreturn                   10a
     d  dparmessage                  60a
     d  dpardata                    512a

     d GetUserPgm      pr                  extpgm('GETUSER')
     d  p#user                       10a
     d  p#whse                        3  0
     d  p#emp#                        5  0
     d  p#fnam                       15a
     d  p#init                        1a
     d  p#lnam                       20a
     d  p#whdp                        5a
     d  p#styp                        1a
     d  p#shft                        6a
     d  p#crew                        6a
     d  p#nhrs                        3  1
     d  p#rtn                         8a

     d GetClientPgm    pr                  extpgm('GETCLIENT')
     d  pclient                      10a
     d  pClientloc                   10a

     d GetDocDorPgm    pr                  extpgm('DH900')
     d  pdoorparm                   136a

     d CalcDur         pr                  extpgm('CLCDUR')
     d  parmdur                     184a

     d CvtDate         pr                  extpgm('CVTDTE')
     d  parmcvtdate                 132a

     d SendFile        pr                  extpgm('QSNDDTAQ')
     d  parmdqname                   10a
     d  parmdqlib                    10a
     d  parmdqlen                     5  0
     d  parmdqdata                  128a

     *----------------------------------------------------------------
     *  Date Conversion Variables
     *----------------------------------------------------------------

     D $cvtdt          ds
     D   $cvcmd                1      8
     D   $cvprg                9     18
     D   $cvd6i               19     24
     D   $cvd8i               25     32
     D   $cvd6o               33     38  0
     D   $cvd8o               39     46  0
     D   $cvsto               47     64
     D   $cvrtn               65     72
     D   $cverm               73    132
     D   $cvmsg               73     76

     D $clcdur         ds
     D   $clcmd                1      8
     D   $clprg                9     18
     D   $cld6i               19     24
     D   $cld6t               19     24  0
     D   $cld8i               25     32
     D   $cld8d               25     32  0
     D   $cld6o               33     38  0
     D   $cld8o               39     46  0
     D   $clsto               47     64
     D   $clrtn               65     72
     D   $clerm               73    132
     D   $clmsg               73     76
     D   $cldr1              133    140
     D   $clvl1              141    145  0
     D   $cldr2              146    153
     D   $clvl2              154    158  0
     D   $cldr3              159    166
     D   $clvl3              167    171  0
     D   $cldr4              172    179
     D   $clvl4              180    184  0

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
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lrtid                22     26
     D  $ltrn#                27     33  0
     D  $lwhdp                34     38
     D  $ldoor                39     41  0
     *
     *----------------------------------------------------------------
     *  Re-definition data structures
     *----------------------------------------------------------------

     D                 ds
     D  roassignment                 15
     *
     D                 ds
     D  rouserdef1                   10  0
     *    Fields used by both A-Sys and P-Sys.
     D   rounused                     1  0 overlay(rouserdef1:1)
     D   roinvnbr                     6  0 overlay(rouserdef1:2)
     *    Field used by P-Sys only.
     D   roordseq                     3  0 overlay(rouserdef1:8)
     *
     D                 ds
     D  rouserdef2                   10  0
     *    Fields used by both A-Sys and P-Sys.
     D   rochkdgt                     3  0 overlay(rouserdef2:1)
     D   robfclbl                     7  0 overlay(rouserdef2:4)

     D                 ds
     DL34rouserdef1                  10  0
     D   L34rounused                  1  0 overlay(L34rouserdef1:1)
     D   L34roinvnbr                  6  0 overlay(L34rouserdef1:2)
     D   L34roordseq                  3  0 overlay(L34rouserdef1:8)
     *
     D                 ds
     DL34rouserdef2                  10  0
     D   L34rochkdgt                  3  0 overlay(L34rouserdef2:1)
     D   L34robfclbl                  7  0 overlay(L34rouserdef2:4)
     *
     D                 ds
     D  rouserdef4                   25
     *    Field used by both A-Sys, P-Sys.
     D   ropirslt                     9    overlay(rouserdef4:1)
     *    Fields used by A-Sys only.
     D   rocstnbr                     8    overlay(rouserdef4:10)
     D   rolinseq#                    6    overlay(rouserdef4:18)
     *    Fields used by P-Sys only.
     D   rocstnbrp                    7    overlay(rouserdef4:06)
     *    ropirslt used by both A-Sys, P-Sys.
     D   ropltnbr                     2    overlay(rouserdef4:24)
     *
     D                 ds
     DL34rouserdef4                  25
     *    L34ropirslt used by A-Sys only.
     D   L34ropirslt                  9    overlay(L34rouserdef4:1)
     *    Fields used by A-Sys only.
     D   L34rocstnbr                  8    overlay(L34rouserdef4:10)
     D   L34rolinseq#                 6    overlay(L34rouserdef4:18)
     *    Fields used by P-Sys only.
     D   L34ropirsltp                 5    overlay(L34rouserdef4:1)
     D   L34rocstnbrp                 7    overlay(L34rouserdef4:06)
     *    L34ropltnbr used by both A-Sys, P-Sys.
     D   L34ropltnbr                  2    overlay(L34rouserdef4:24)
     *
     *----------------------------------------------------------------
     *  APT Record Format
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#aptout

     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *      $pdata2    Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *      $pdata2    Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------
      /free

        $aptds = $pdata;

        $preturn = '*OK';
        $pmessage = ' ';

       //---------------------------------------------------------------
       // Main line
       //---------------------------------------------------------------

       // See which system is calling the program.

        if %subst($psubcmd:1:1) = '%';
          DakotaCall = *on;
          HostCall = *off;
          %subst($psubcmd:1:1) = '*';
        else;
          HostCall = *on;
          DakotaCall = *off;
        endif;

       // See if we are just opening or closing program.

        select;

          when $psubcmd = '*OPEN';
            $pdata = $aptds;
            return;

          when $psubcmd = '*CLOSE';
            *inlr = *on;
            exsr aaaclose;
            $pdata = $aptds;
            return;

750eA     // Return if just setting previous location value
750eA     when $psubcmd = '*PREVLOC';
750eA       prevloc = $aplocation;
750eA       return;

750fA     // Return if not using APT
750fA     when not usingAPT;
750fA       return;

        endsl;

       // Otherwise, do some initialization and move on.

        error = *off;

       // Do what user has requested.

        select;

          when $psubcmd = '*BULKOBTN';
            if not error;
              exsr bulkobtn;
            endif;

          when $psubcmd = '*BULKEND';
            if not error;
              exsr bulkend;
            endif;

          when $psubcmd = '*EXPTRN';
            if not error;
              exsr exptrn;
            endif;

          when $psubcmd = '*JOB0100';
            exsr testtype;

          when $psubcmd = '*PICKEND';
            if not error;
              exsr pickend;
            endif;

          when $psubcmd = '*PICKGEN';
            if not error;
              exsr pickgen;
            endif;

740bA     when $psubcmd = '*PUTAWYBEG';
740bA       if not error;
740bA         exsr putawybeg;
740bA       endif;

          when $psubcmd = '*PUTAWYPLC'
              or $psubcmd = '*PUTRTNPLC'
              or $psubcmd = '*PUTAWPLCE'
              or $psubcmd = '*PUTRTPLCE';
            if not error;
              exsr putawyplc;
            endif;

          when $psubcmd = '*RCVBEG';
            if not error;
              exsr rcvbeg;
            endif;

750aA     when $psubcmd = '*RETURN';
750kM       exsr rtnrec;

          when $psubcmd = '*TFRBEG';
            if not error;
              exsr tfrbeg;
            endif;

          when $psubcmd = '*TFREND';
            if not error;
              exsr tfrend;
            endif;

          when $psubcmd = '*RPLBEG';
            if not error;
              exsr rplbeg;
            endif;

          when $psubcmd = '*RPLEND'
750eA       or $psubcmd = '*RPLEND3';
            if not error;
              exsr rplend;
            endif;

          when $psubcmd = '*RPLPLC';
            if not error;
              exsr rplplc;
            endif;

          other;
            error = *on;
            $preturn = 'INVLDSBCMD';
            exsr getmsg;

        endsl;

       // We are finished so get out

        $pdata = $aptds;
        return;

      /end-free

     *----------------------------------------------------------------
     *          Subroutines In Alphabetical Order
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

          // Get client id.
          callp GetClientPgm (client: clientloc);

          $lprg  = #pgm;
          $cvprg = #pgm;
          $clprg = #pgm;

          // Get default values for the user.
          exsr getuser;

          // Ensure commitment control is off
          exec sql
            set option commit=*none;


750fA     // Check for APT logging option
750fA
750fA     chain (1: '*APTFTP') options;
750fA     if %found(options) and %subst(opdata:1:1) = 'Y';
750fA       usingAPT = *on;
750fA     else;
750fA       usingAPT = *off;
750fA     endif;
750fA       usingAPT = *on;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------
      /free
        begsr *pssr;

          // Make sure we don't get caught in an infinite loop
          if pssrflag;
            *inlr = *on;
            exsr aaaclose;
            return;
          endif;

          pssrflag = *on;

          // Send message back to calling program.
          $preturn = 'U:' + #status;
          $pmessage = 'U:'
                      + %trim(#pgm)
                      + '('
                      + %trim(%editc(#stmt:'Z'))
                      + ')-'
                      + #pgmmsg;
          *inlr = *on;
          exsr aaaclose;
          return;

        endsr; // *pssr

      /end-free

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------
      /free
        begsr aaacallhost;

          $dricommand = '*ITEM';
          $drisubcmd = $psubcmd;
          $drisys2upd = 'H';
          $driprogram = $pprogram;
          $drireturn = *blanks;
          $drimessage = *blanks;
          $dridata = $item;
          callp(e) DriMain2 ($dricommand: $drisubcmd: $drisys2upd:
                   $driprogram: $drireturn: $drimessage: $dridata);

          select;

            when %error;
              error = *on;
              $preturn  = '*CALLERROR';
              $pmessage = 'Error occured on call to '
                        + 'DRIMAIN2'
                        + '/' + %trim($dricommand)
                        + '/' + %trim($drisubcmd)
                        + ' from ' + #pgm;

            when $drireturn <> '*OK' and
                 $drireturn <> '*NOPROGRAM';
              error = *on;
              $preturn  = $drireturn;
              $pmessage = 'H:' + $drimessage;

          endsl;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  aaaclose   Close any open files or programs.
     *----------------------------------------------------------------
      /free
        begsr aaaclose;

          // Close interfaces

          if driitem;
            $drisubcmd = '*CLOSE    ';
            $driprogram = $pprogram;
            $drireturn = *blanks;
            $drimessage = *blanks;
            $dridata = *blanks;
            callp(e) DriItemPgm ($drisubcmd: $driprogram: $drireturn:
                                 $drimessage: $dridata);
            driitem = *off;
          endif;

          if drislot;
            $drisubcmd = '*CLOSE    ';
            $driprogram = $pprogram;
            $drireturn = *blanks;
            $drimessage = *blanks;
            $dridata = *blanks;
            callp(e) DriSlotPgm ($drisubcmd: $driprogram: $drireturn:
                                 $drimessage: $dridata);
            drislot = *off;
          endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  bulkobtn    Create bulk pick "obtain" record.
     *----------------------------------------------------------------
      /free
        begsr bulkobtn;

          // Clear data structure format.
          exsr inzaptout;

          // Get dock door assigned to this transaction.
          $lwhse = lbwhse;
          $lrtid = $aprteid;
          $ltrn# = lsttrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          // If no slot assigned for item, set default.
          if $aplocation = *blanks;
            exsr zznoslot;
          endif;

          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte2 = rhrte;
          #aopfrte = $aprteid;

750dD     //#aopfbtch = %trim(%editw(lsttrn#:editw7));
750dM     #aopfbtch = %trimr(%editc(lsttrn#:'4'));

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));
          #aopfline = %trim(%editw(lbseq:editw6));

          #aopfvi1 = '0';
          #aopfvi2 = '0';
          #aopfvi3 = '0';
          #aopfvi4 = '0';
          #aopfvi5 = '0';
          #aopfvi6 = '0';
          #aopfvi7 = '0';
          #aopfvi8 = %trim(%editw(lbswgt:editw102));
          #aopfvi9 = %trim(%editw(lbcube:editw103));
          #aopfvi10 = %char(palletcount);

          exsr zzaptdept;
          #aopfjob = '05' + aptdeptcd;
          if $apseq# = 0;
            #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
          else;
            #aopfrom = prevloc;
          endif;
          #aopto = $aplocation;
          prevloc = $aplocation;

          #aopfill6 = 'Slot  ';
          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt;

        endsr;  // bulkobtn
      /end-free

     *----------------------------------------------------------------
     *  bulkend   End bulk pick
     *----------------------------------------------------------------
      /free
        begsr bulkend;

          // Clear data structure format.
          exsr inzaptout;

          // Get dock door assigned to this transaction.
          $lwhse = lbwhse;
          $lrtid = $aprteid;
          $ltrn# = lsttrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          // If no slot assigned for item, set default.
          if $aplocation = *blanks;
            exsr zznoslot;
          endif;

          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte2 = rhrte;
          #aopfrte = $aprteid;

750dD     //#aopfbtch = %trim(%editw(lsttrn#:editw7));
750dM     #aopfbtch = %trimr(%editc(lsttrn#:'4'));

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));
          #aopfline = %trim(%editw(lbseq:editw6));

          #aopfvi1 = '0';
          #aopfvi2 = '0';
          #aopfvi3 = '0';
          #aopfvi4 = '0';
          #aopfvi5 = '0';
          #aopfvi6 = '0';
          #aopfvi7 = '0';
          #aopfvi8 = %trim(%editw(lbswgt:editw102));
          #aopfvi9 = %trim(%editw(lbcube:editw103));
          #aopfvi10 = %char(palletcount);

          exsr zzaptdept;
          #aopfjob = '05' + aptdeptcd;
          if $apseq# = 0;
            #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
          else;
            #aopfrom = prevloc;
          endif;
          #aopto = $aplocation;
          prevloc = $aplocation;

          #aopfill6 = 'Slot  ';
          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt;

        endsr;  // bulkend
      /end-free

750qA*----------------------------------------------------------------
750qA*  exptrn  Export Transaction data at End time
750qA*----------------------------------------------------------------
      /free
        begsr exptrn;

          // Ensure input file is open and available
          if not %open(aptselwk1);
            open(e) aptselwk1;
          endif;

          // Clear data structure format.
          exsr inzaptout4;

          // Get customer route
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;

          // loop through passed route id and write to aptdata
          wktrnm = %dec(%char($aptrn#) + '0':8:0);
          setll ($apwhse:wktrnm) aptselwk1;

          dow forever = forever;

            reade ($apWhse:wktrnm) aptselwk1;
            if %eof(aptselwk1);
              leave;
            endif;

            // SEL for selection, IND for Indirect Activity in middle of labels
            #aoDtaId = w_aptype;

            // Actual timestamp of selection activity
            monitor;
              #aoactts  = %subst(%char(w_apactts):1:10) + ' ' +
                          %subst(%char(w_apactts):12:12);
            on-error;
              #aoactts = %char(w_apactts);
            endmon;

            // Dakota Transaction Number
            #aoBatchId = %char(w_aptrn#);

            // Line sequence (001-999) for transaction
            #aolineseq = w_apline#;

            // Customer Route being processed
            #aorte = rhrte;

            // Termid not being used
            #aotermid=*blanks;

            // Job Code (List of codes to identify warehouse and operation)
            #aozoned = w_apzoned;

            // Account Main and Sub not used
            #aoactmn=*blanks;
            #aoactsb=*blanks;

            // From and to slot locations
            #aofrmloc=w_apfrml;
            #aotoloc =w_aptol;

            // Employee Number
            #aoEmpNum = w_apempid;

            // KVI 01 - Units selected
            #aokvi01 = w_apkvi01;

            // KVI 02 - Cube selected
            if w_apkvi02 <= 999.999;
              editStr = %editw(w_apkvi02:'0    .   ');
              #aokvi02 = %subst(%trim(editStr):2:7);
            else;
              #aokvi02 = '999.99';
            endif;

            // KVI 03 - Weight
            if w_apkvi03 <= 9999.99;
              editStr = %editw(w_apkvi03:'0     .  ');
              #aokvi03 = %subst(%trim(editStr):2:7);
            else;
              #aokvi03 = '9999.99';
            endif;

            // KVI 04 - Location or Transaction Count
            #aokvi04 = w_apkvi04;

            // KVI 05 - Unique Stop Count - First row only
            #aokvi05 = w_apkvi05;

            // KVI 06 - # labels.  Zero if PIR merge since pir selector applied label
            #aokvi06 = w_apkvi06;

            // KVI 07 - PIR-0, FIX-1, Pallet Count when KoaPaka on first row only
            #aokvi07 = w_apkvi07;

            // KVI 08 - # catch weights entered
            #aokvi08 = w_apkvi08;

            // KVI 09 - not used
            #aokvi09 = w_apkvi09;

            // KVI 10 - not used
            #aokvi10 = w_apkvi10;

            // Write APT record.
            exsr writeapt4;

          enddo;

          // Ensure input file is closed
          if %open(aptselwk1);
            close(e) aptselwk1;
          endif;

          // Send ATP Batch for Transaction
          qcmd = 'APTFTPCMD CMD(*SENDT) PARMS(' + %char($aptrn#) + ')';
          qlen = %len(%trim(qcmd));
750q  /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd            512
     C                   parm                    qlen             15 5

     c                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr
     C     endclrerrflgs endsr

     *----------------------------------------------------------------
     *  getdockdoor  Get item info.
     *----------------------------------------------------------------
      /free
        begsr getdockdoor;

          $ldoor = 0;
          callp GetDocDorPgm ($lparm);

        endsr;  // getdockdoor
      /end-free

     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = kywhse
     C                   eval      $ititem = kyitem

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm      '*GETMAIN  '  $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  getlabel     Get label record.
     *----------------------------------------------------------------

     C     getlabel      begsr

     C                   eval      error  = *off

     C     kylbl#        chain     label
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $aplbl#e = '1'
     C                   eval      $preturn = 'INVLDLBL#'
     C                   exsr      getmsg
     C                   endif

     C     endgetlabel   endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------
      /free
        begsr getmsg;

          select;

            when $preturn = 'EMP#NOTSNT';
              $pmessage= 'employee number must be sent';

            when $preturn = 'INVLDLBL#';
              $pmessage = 'Invalid label number '
                        + '('
                        + %Trim(%editc($aplbl#:'L'))
                        + ')';

            when $preturn = 'INVLDRTEID';
              $pmessage = 'Invalid route id '
                        + '('
                        + $aprteid
                        + ')';

            when $preturn = 'INVLDTRN#';
              $pmessage = 'Invalid transaction number '
                        + '('
                        + %Trim(%editc($aptrn#:'L'))
                        + ')';

            when $preturn = 'LBL#NOTSNT';
              $pmessage= 'label number must be sent';

            when $preturn = 'LOCNOTSNT';
              $pmessage= 'location must be sent';

            when $preturn = 'RTENOTSNT';
              $pmessage= 'route id must be sent';

            when $preturn = 'SEQ#NOTSNT';
              $pmessage= 'Sequence must be sent';

            when $preturn = 'TRN#NOTSNT';
              $pmessage= 'Transaction must be sent';

            other;
              $pmessage = 'Error occured - '
                        + %Trim($preturn) + ' '
                        + '(Description not available)';

          endsl;

        endsr;  // getmsg
      /end-free

     *----------------------------------------------------------------
     *  getrtehed    Get route header record.
     *----------------------------------------------------------------
      /free
        begsr getrtehed;
          error = *off;

          chain (kywhse: kyrte) rtehed;
          if not %found;
            clear rhrec;
            error = *on;
            $preturn = 'INVLDRTEID';
            exsr getmsg;
          endif;

        endsr;  // getrtehed
      /end-free

     *----------------------------------------------------------------
     *  getslot  Get slot info.
     *----------------------------------------------------------------
      /free
        begsr getslot;

          savever# = $slver#;
          clear $slot;
          $slver# = savever#;

          $slwhse = kywhse;
          $slwhdp = kywhdp;
          $sldisp = kydisp;

          drislot = *on;
          $drisubcmd = '*GET      ';
          $driprogram = $pprogram;
          $drireturn = *blanks;
          $drimessage = *blanks;
          $dridata = $slot;
          callp(e) DriSlotPgm ($drisubcmd: $driprogram: $drireturn:
                               $drimessage: $dridata);

          select;

            when %error;
              error = *on;
              $preturn  = 'CALLERROR';
              $pmessage = 'Error occured on call to '
                                             + 'DRISLOT'
                                             + '/' + %trim($drisubcmd)
                                             + ' from ' + #pgm;

            when $drireturn <> '*OK' and check4err = *on;
              error = *on;
              $sldispe = '1';
              $preturn  = $drireturn;
              $pmessage = $drimessage;
              leavesr;

            other;
              $slot = $dridata;

              // Fix Ledyard Slot numbers with single char aisle
              if client = ledyrd;
                if %len(%trim($slaisl)) = 1
                  and $slwhdp = 'DRY';
                    $sacdsp = '1' + $sacdsp;
                endif;
              endif;

          endsl;

        endsr;  //getslot
      /end-free

     *----------------------------------------------------------------
     *  gettasktype  Get task type.
     *----------------------------------------------------------------
      /free
        begsr gettasktype;

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          // Get tran/task type
          Exec Sql Select TKDESC, TKTYPE
                     into :taskdesc, :tasktype
                     From TASK
                    Where TKCODE = :pttask;
          If SQLCOD <> 0;
            taskdesc = *blanks;
            tasktype = *blanks;
          endif;

        endsr;  //gettasktype
      /end-free

     *----------------------------------------------------------------
     *  gettran      Get transaction record.
     *----------------------------------------------------------------
      /free
        begsr gettran;
          error = *off;

          chain (kytrn#) pirtran;
          if not %found;
            error = *on;
            $aptrn#e = '1';
            $preturn = 'INVLDTRN#';
            exsr getmsg;
          endif;

        endsr;  // gettran
      /end-free

     *----------------------------------------------------------------
     *  gettranprv   Get previous transaction record end date/time
     *----------------------------------------------------------------
      /free
        begsr gettranprv;

          exec sql declare ptcsr cursor for
            select * from pirtran
             where ptedte <= :ptsdte
               and ptetim <= :ptstim
               and ptemp# = :ptemp#
               and ptsub <> 'IDLE'
             order by ptedte desc, ptetim desc;

          exec sql open ptcsr;

          exec sql fetch next from ptcsr into :prvtrn;
          if sqlstt <> sqlSuccess;
            clear prvtrn;
            clear prv_ptedte;
            clear prv_ptetim;
          endif;

          exec sql close ptcsr;

        endsr;  // gettranprv
      /end-free

     *----------------------------------------------------------------
     *  getuser      Get user information.
     *----------------------------------------------------------------
      /free
        begsr getuser;

        // Get default values for the user.

          callp GetUserPgm (#user: #whse: #emp#: #fnam:
                            #init: #lnam: #whdp: #styp:
                            #shft: #crew: #nhrs: #rtn);

        endsr;  // getuser
      /end-free

     *----------------------------------------------------------------
     *  indirect  Create Indirect job code record.
     *----------------------------------------------------------------
      /free
        begsr indirect;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrte = 'indirect';

          // Retrieve label info
650jD   //kylbl# = $aplbl#;
650jD   //exsr getlabel;

          // Retrieve transaction info
          kytrn# = $aptrn#;
          //exsr gettran;
          #aodtrun = %char($aptrn#);
          if ptsdte > 0;
            #aodtsdate = %char(%date(ptsdte:*iso):*iso-);
            #aodtstime = %trim(%editw(ptstim:editw6));
          endif;
          if ptedte > 0;
            #aodtedate = %char(%date(ptedte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptetim:editw6));
          else;
            #aodtedate = %char(%date(ptsdte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptstim:editw6));
          endif;

          #aodtvi1 = %trim(%editw(0:editu10));
          #aodtvi2 = %trim(%editw(0:editu10));
          #aodtvi3 = %trim(%editw(0:editu10));
          #aodtvi4 = %trim(%editw(0:editu10));
          #aodtvi5 = %trim(%editw(0:editu10));
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));
          #aodtvi8 = %trim(%editw(0:editu10));
          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

740aD  // #aodtjob = %subst(taskdesc:27:4);
740aD  // if #aodtjob = *blanks;
740aD  //   #aodtjob = '9999';
740aD  // endif;
740aA     select;
740aA       when pttask = 'BEGDAY';
740aA         #aodtjob  = 'S    ';
740aA       when pttask = 'BREAK ';
740aA         #aodtjob  = 'B    ';
740aA       when pttask = 'ENDDAY';
740aA         #aodtjob  = 'E    ';
740aA       when pttask = 'IDLE  ';
740aA         #aodtjob  = 'I    ';
740aA       when pttask = 'LUNCH ';
740aA         #aodtjob  = 'L    ';
740aA       when pttask = 'BATCHG';
740aA         #aodtjob  = 'X    ';
740aA       when pttask = 'CLEAN ';
740aA         #aodtjob  = 'C    ';
740aA       when pttask = 'DROP  ';
740aA         #aodtjob  = 'D    ';
740aA       when pttask = 'LOAD  ';
740aA         #aodtjob  = 'O    ';
740aA       when pttask = 'MTG   ';
740aA         #aodtjob  = 'M    ';
740aA       when pttask = 'MISC  ';
740aA         #aodtjob  = 'Z    ';
740aA       other;
740aA         #aodtjob  = ' '+ pttask;
740aA     endsl;

          #aodtfill6 = 'Slot  ';
          #aodtto = prevloc;
          #aodtfrom = '1111111111';  // always for indirect
740aM     #aodtarea = 'I';         // always for indirect
          prevloc = #aodtto;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;
        //if #aodtjob = 'S'
        // or #aodtjob = ' S';
        //  exsr writeapt2;
        //endif;

        endsr;  // indirect
      /end-free

     *----------------------------------------------------------------
     *  inzaptout   Initialize fields in APT output record
     *----------------------------------------------------------------
      /free
        begsr inzaptout;

          clear #aopfseq;
          clear #aopfbtch;
          clear #aopfdate;
          clear #aopftime;
          clear #aofill7;
          clear #aopfline;
          clear #aopfrte;
          clear #aopfvi1;
          clear #aopfvi2;
          clear #aopfvi3;
          clear #aopfvi4;
          clear #aopfvi5;
          clear #aopfvi6;
          clear #aopfvi7;
          clear #aopfvi8;
          clear #aopfvi9;
          clear #aopfvi10;
          clear #aopfill1;
          clear #aopfjob;
          clear #aopfill6;
          clear #aopfrom;
          clear #aopto;
          clear #aopfill1a;
          clear #aopfrte2;

        endsr;  // inzaptout
      /end-free

     *----------------------------------------------------------------
     *  inzaptout2  Initialize fields in APT output record
     *----------------------------------------------------------------
      /free
        begsr inzaptout2;

          clear #aodtseq;
          clear #aodtpkr;
          clear #aodtsdate;
          clear #aodtstime;
          clear #aodtedate;
          clear #aodtetime;
          clear #aodtrun;
          clear #aodtline;
          clear #aodtrte;
          clear #aodtvi1;
          clear #aodtvi2;
          clear #aodtvi3;
          clear #aodtvi4;
          clear #aodtvi5;
          clear #aodtvi6;
          clear #aodtvi7;
          clear #aodtvi8;
          clear #aodtvi9;
          clear #aodtvi10;
          clear #aodtfill1;
          clear #aodtjob;
          clear #aodtfill6;
          clear #aodtfrom;
          clear #aodtto;
          clear #aodtfill1a;
          clear #aodtfill4a;
          clear #aodtfill1b;
          clear #aodtarea;

        endsr;  // inzaptout2
      /end-free

750aA*----------------------------------------------------------------
750aA*  inzaptout3  Initialize fields in APT output record
750aA*----------------------------------------------------------------
750aA /free
750aA   begsr inzaptout3;
750aA
750aA     clear #aortbldg;
750aA     clear #aortpckr;
750aA     clear #aortdelv;
750aA     clear #aortbatch;
750aA     clear #aortseq;
750aA     clear #aortresn;
750aA     clear #aortexcl;
750aA     clear #aortcinv;
750aA     clear #aortinvd;
750aA     clear #aortrrte;
750aA     clear #aortppe;
750aA     clear #aortcust;
750aA     clear #aortitem;
750aA     clear #aortwhse;
750aA     clear #aortwhsa;
750aA     clear #aortbcf;
750aA     clear #aortcqty;
750aA     clear #aortoqty;
750aA     clear #aortcitm;
750aA     clear #aortfil1;
750aA     clear #aortadte;
750aA
750aA   endsr;  // inzaptout3
750aA /end-free
750aA

750qA*----------------------------------------------------------------
750qA*  inzaptout4  Initialize fields in APT output record
750qA*----------------------------------------------------------------
750qA /free
750qA   begsr inzaptout4;
750qA
750qA     clear #aodtaid;
750qA     clear #aoactts;
750qA     clear #aobatchid;
750qA     clear #aolineseq;
750qA     clear #aorte;
750qA     clear #aotermid;
750qA     clear #aozoned;
750qA     clear #aoactmn;
750qA     clear #aoactsb;
750qA     clear #aofrmloc;
750qA     clear #aotoloc;
750qA     clear #aoempnum;
750qA     clear #aokvi01;
750qA     clear #aokvi02;
750qA     clear #aokvi03;
750qA     clear #aokvi04;
750qA     clear #aokvi05;
750qA     clear #aokvi06;
750qA     clear #aokvi07;
750qA     clear #aokvi08;
750qA     clear #aokvi09;
750qA     clear #aokvi10;
750qA
750qA   endsr;  // inzaptout4
750qA /end-free

     *----------------------------------------------------------------
     *  pickplc   End pick - Write Batch and Reset records
     *----------------------------------------------------------------
      /free
        begsr pickplc;

          // Populate Batch Total record

          // Clear data structure format.
          exsr inzaptout;

          // Get dock door assigned to this transaction.
          $lwhse = lbwhse;
          $lrtid = $aprteid;
          $ltrn# = lastpstrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          // Count aisles on transaction.
          aislecount = 0;
          Exec sql Select count(distinct LBAISL)
                     into :aislecount
                     from LABEL
                    where LBTRN# = :$ltrn#
                      and LBTYPE = 'O';
          if SQLSTT <> '00000';
            aislecount = 0;
          endif;

          // Count pallets on transaction.
          palletcount = 0;
          Exec sql Select count(distinct LBPAL#)
                     into :palletcount
                     from LABEL
                    where LBTRN# = :$ltrn#;
          if SQLSTT <> '00000';
            palletcount = 0;
          endif;

          // Count stops on transaction.
          stopscount = 0;
          Exec sql Select count(distinct LBSTOP)
                     into :stopscount
                     from LABEL
                    where LBTRN# = :$ltrn#;
          if SQLSTT <> '00000';
            stopscount = 0;
          endif;

          // If no slot assigned for item, set default.
          if $aplocation = *blanks;
            exsr zznoslot;
          endif;

          lstlbl# = lblbl#;

          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte2 = rhrte;
          #aopfrte = $aprteid;
750dD     //#aopfbtch = %trim(%editw($ltrn#:editw7));
750dM     #aopfbtch = %trimr(%editc(lsttrn#:'4'));

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));
          #aopfline = %trim(%editw(lbseq:editw6));

          #aopfvi1 = %editw(0:editw9z);
          #aopfvi2 = %editw(0:editw9z);
          #aopfvi3 = %editw(aislecount:editw9z);
          #aopfvi4 = %editw(0:editw9z);
          #aopfvi5 = %editw(stopscount:editw9z);
          #aopfvi6 = %editw(0:editw9z);
          #aopfvi7 = %editw(0:editw9z);
          #aopfvi8 = %editw(0:editw92);
          #aopfvi9 = %editw(0:editw93);
          #aopfvi10 = %editw(palletcount:editw9z);

          exsr zzaptdept;
          #aopfjob = '05' + aptdeptcd;
          #aopfrom = prevloc;
          #aopto = 'TDDR' + %char($ldoor) + 'D';
          prevloc = #aopto;
          // remove dashes from slot
          pos = %scan('-': #aopfrom);
          dow pos > 0;
             #aopfrom = %replace('': #aopfrom: pos: 1);
             pos = %scan('-': #aopfrom);
          enddo;
          pos = %scan('-': #aopto);
          dow pos > 0;
             #aopto = %replace('': #aopto: pos: 1);
             pos = %scan('-': #aopto);
          enddo;

          #aopfill6 = 'Batch ';
          $apseq# = $apseq# + 1;

          // Write BATCH TOTAL APT record.
          exsr writeapt;

          // Populate Distance Reset record.
          #aopfvi1 = %editw(0:editw9z);
          #aopfvi2 = %editw(0:editw9z);
          #aopfvi3 = %editw(0:editw9z);
          #aopfvi4 = %editw(0:editw9z);
          #aopfvi5 = %editw(0:editw9z);
          #aopfvi6 = %editw(0:editw9z);
          #aopfvi7 = %editw(0:editw9z);
          #aopfvi8 = %editw(0:editw92);
          #aopfvi9 = %editw(0:editw93);
          #aopfvi10 = %editw(0:editw9z);

          #aopfrom = prevloc;
          #aopto = 'T' + aptdeptcd + 'START';
          prevloc = *blanks;

          #aopfill6 = 'Reset ';
          $apseq# = $apseq# + 1;

          // Write DISTANCE RESET APT record.
          exsr writeapt;

          // Clear work fields
          prevloc = *blanks;
          recswrote = 'N';

        endsr;  // pickplc
      /end-free

     *----------------------------------------------------------------
     *  pickend   End pick
     *----------------------------------------------------------------
      /free
        begsr pickend;

          // Clear data structure format.
          exsr inzaptout;

          // Get dock door assigned to this transaction.
          $lwhse = lbwhse;
          $lrtid = $aprteid;
          $ltrn# = lsttrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          // If no slot assigned for item, set default.
          if $aplocation = *blanks;
            exsr zznoslot;
          endif;

          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte2 = rhrte;
          #aopfrte = $aprteid;

750dD     //#aopfbtch = %trim(%editw(lsttrn#:editw7));
750dM     #aopfbtch = %trimr(%editc(lsttrn#:'4'));

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));
          #aopfline = %trim(%editw(lbseq:editw6));

          #aopfvi1 = 'TEST';
          #aopfvi2 = '0';
          #aopfvi3 = '0';
          #aopfvi4 = '0';
          #aopfvi5 = '0';
          #aopfvi6 = '0';
          #aopfvi7 = '0';
          #aopfvi8 = %trim(%editw(lbswgt:editw102));
          #aopfvi9 = %trim(%editw(lbcube:editw103));
          #aopfvi10 = '0';

          exsr zzaptdept;
          #aopfjob = '05' + aptdeptcd;
          if $apseq# = 0;
            #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
          else;
            #aopfrom = prevloc;
          endif;
          #aopto = $aplocation;
          prevloc = $aplocation;

          #aopfill6 = 'Slot  ';
          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt;

        endsr;  // pickend
      /end-free

     *----------------------------------------------------------------
     *  pickgen   Pick generated (i.e., labels printed)
     *----------------------------------------------------------------
      /free
        begsr pickgen;

        // Create "Obtain" record for PIR/Fixed selection
          kylbtype = 'O';
          exsr procselection;
          exsr procpicksum;
          exsr writedtaq;

        endsr;  // pickgen;
      /end-free

     *----------------------------------------------------------------
     *  Process Bulk Pick labels for zone
     *----------------------------------------------------------------
      /free
        begsr procbulkpick;

          // Clear data structure format.
          exsr inzaptout;

          // Get dock door assigned to this transaction.
          $lwhse = lbwhse;
          $lrtid = $aprteid;
          $ltrn# = lsttrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          // If no slot assigned for item, set default.
          if $aplocation = *blanks;
            exsr zznoslot;
          endif;

          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte2 = rhrte;
          #aopfrte = $aprteid;

750dD     //#aopfbtch = %trim(%editw(lsttrn#:editw7));
750dM     #aopfbtch = %trimr(%editc(lsttrn#:'4'));

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));
          #aopfline = %trim(%editw(lbseq:editw6));

          #aopfvi1 = '0';
          #aopfvi2 = '0';
          #aopfvi3 = '0';
          #aopfvi4 = '0';
          #aopfvi5 = '0';
          #aopfvi6 = '0';
          #aopfvi7 = '0';
          #aopfvi8 = %trim(%editw(lbswgt:editw102));
          #aopfvi9 = %trim(%editw(lbcube:editw103));
          #aopfvi10 = '0';

          exsr zzaptdept;
          #aopfjob = '05' + aptdeptcd;
          if $apseq# = 0;
            #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
          else;
            #aopfrom = prevloc;
          endif;
          #aopto = $aplocation;
          prevloc = $aplocation;

          #aopfill6 = 'Slot  ';
          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt;

        endsr;  // procbulkpick
      /end-free

     *----------------------------------------------------------------
     *  Process Merge labels for single transaction number.
     *----------------------------------------------------------------
      /free
        begsr procmerge;

          // This routine will only process ONE transaction at a time.
          kylbtrn#= lsttrn#;

          // Clear data structure format.
          exsr inzaptout;

          // Count merge cases on transaction.
          mergecount = 0;
          Exec sql Select sum(LBQPCK)
                     into :mergecount :mergeind
                     from LABEL
                    where LBTRN# = :lsttrn#
                      and LBTYPE = 'M';
          if SQLSTT <> '00000';
            mergecount = 0;
          endif;

          if mergecount > 0;
750dD     //#aopfbtch = %trim(%editw(lsttrn#:editw7));
750dM       #aopfbtch = %trimr(%editc(lsttrn#:'4'));

            // If date is missing, use current date
            if ptgdte <= 0;
              ptgdte = %dec(%char(%date():*iso0):8:0);
            endif;
            #aopfdate = %char(%date(ptgdte:*iso):*iso-);
            #aopftime = %trim(%editw(ptstim:editw6));
            #aopfline = %trim(%editw(lbseq:editw6));

            // Get customer route ID
            kywhse = $apwhse;
            kyrte = $aprteid;
            exsr getrtehed;
            #aopfrte2 = rhrte;
            #aopfrte = $aprteid;

            #aopfvi1 = %trim(%editw(0:editu10));
            #aopfvi2 = %trim(%editw(mergecount:editu10));
            #aopfvi3 = %trim(%editw(0:editu10));
            #aopfvi4 = %trim(%editw(0:editu10));
            #aopfvi5 = %trim(%editw(0:editu10));
            #aopfvi6 = %trim(%editw(0:editu10));
            #aopfvi7 = %trim(%editw(0:editu10));
            #aopfvi8 = %trim(%editw(0:editw102));
            #aopfvi9 = %trim(%editw(0:editw103));
            #aopfvi10 = %trim(%editw(0:editu10));

            exsr zzaptdept;
            #aopfjob = '05' + aptdeptcd;
            if $apseq# = 0
              or prevloc = *blank;
                #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
            else;
              #aopfrom = prevloc;
            endif;
            #aopto = 'T' + %trim(aptdeptcd) + 'MERGE';
            // remove dashes from slot
            pos = %scan('-': #aopfrom);
            dow pos > 0;
               #aopfrom = %replace('': #aopfrom: pos: 1);
               pos = %scan('-': #aopfrom);
            enddo;
            pos = %scan('-': #aopto);
            dow pos > 0;
               #aopto = %replace('': #aopto: pos: 1);
               pos = %scan('-': #aopto);
            enddo;
            prevloc = #aopto;

            #aopfill6 = 'Merge ';
            $apseq# = $apseq# + 1;
            recswrote = 'Y';

            // Write APT record.
            exsr writeapt;
          endif;

        endsr;  //procmerge
      /end-free

     *----------------------------------------------------------------
     *  procpicksum   Write Load Summary records
     *----------------------------------------------------------------
      /free
        begsr procpicksum;

          kypstype   = 'O';
          lastpstrn# = *loval;

          exsr inzaptout;
650eA     select;
650eA      when client = ledyrd;
            #aopfbldg = '680LOD';
650eA      when client = frf;
650eA       #aopfbldg = '785LOD';
740aA      when client = presto;
740aA       #aopfbldg = '795LOD';
650eA      other;
650eA       #aopfbldg = '000LOD';
650eA     endsl;
          #aopfbtch = *blanks;
          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte = $aprteid;
          #aopfrte2 = rhrte;

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));

          #aopfvi1 = %editw(0:editw9z);
          #aopfvi2 = %editw(0:editw9z);
          #aopfvi3 = %editw(0:editw9z);
          #aopfvi4 = %editw(0:editw9z);
          #aopfvi5 = %editw(0:editw9z);
          #aopfvi6 = %editw(0:editw9z);
          #aopfvi7 = %editw(0:editw9z);
          #aopfvi8 = %editw(0:editw9z);
          #aopfvi9 = %editw(0:editw9z);
          #aopfvi10 = %editw(0:editw9z);

          #aopfrom = *blanks;
          #aopto = *blanks;
          #aopfill6 = *blanks;

          // Build Dry Load record --------------------------
          palletcount = 0;
750lA     palletcount_oth = 0;
          // Get pallet count
650hA     select;
650hA      when client = ledyrd;
             Exec Sql
               Select count(distinct PSPAL#)
                 into :palletcount
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'D';
650hA      when client = frf;
650hA        Exec Sql
650hA          Select count(distinct PSPAL#)
650hA            into :palletcount
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN('D','Y');
750lA      when client = prestofoods;
750lA        Exec Sql
750lA          Select count(distinct PSPAL#)
750lA            into :palletcount
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP IN('D','E', 'H', 'L', 'S', 'U', 'V', 'W', 'X');
750lA
750lA     // Total pallets NOT in compartments listed below.
750lA        Exec Sql
750lA          Select count(distinct PSPAL#)
750lA            into :palletcount_oth
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP NOT IN('B','C', 'D', 'E', 'F', 'G', 'H', 'I', 'L',
750lA                               'M','O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
750lA                               'W','X', 'Y', 'Z');
750lA             palletcount = palletcount + palletcount_oth;
650hA      other;
             exec sql
               Select count(distinct PSPAL#)
                 into :palletcount
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'D';
650hA     endsl;
          if sqlstt <> '00000';
            palletcount = 0;
          endif;

          #aopfvi1 = %editw(palletcount:editw9z);
650gD   //#aopfline = %trim(rhrte + '1'
650gD   //          + %char((%date(ptgdte:*iso) + %days(1)):*mdy0));
650gM     #aopfline = %trim(rhrte) + '1'
650gM               + %char((%date(ptgdte:*iso) + %days(1)):*mdy0);
          #aopfjob = '0601';

          // Get cases, cube & weight
750lA     loadpick_oth   = 0;
750lA     loadcube_oth   = 0;
750lA     loadweight_oth = 0;
650hA     select;
650hA      when client = ledyrd;
             Exec Sql
               Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
                 into :loadpick, :loadcube, :loadweight
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'D';
650hA      when client = frf;
650hA        Exec Sql
650hA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
650hA            into :loadpick, :loadcube, :loadweight
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN('D','Y');
750lA      when client = prestofoods;
750lA        Exec Sql
750lA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
750lA            into :loadpick, :loadcube, :loadweight
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP IN('D','E', 'H', 'L', 'S', 'U', 'V', 'W', 'X');
750lA
750lA     // Total cases, cube & weight NOT in compartments listed below.
750lA        Exec Sql
750lA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
750lA            into :loadpick_oth, :loadcube_oth, :loadweight_oth
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP NOT IN('B','C', 'D', 'E', 'F', 'G', 'H', 'I', 'L',
750lA                               'M','O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
750lA                               'W','X', 'Y', 'Z');
750lA             loadpick   = loadpick + loadpick_oth;
750lA             loadcube   = loadcube + loadcube_oth;
750lA             loadweight = loadweight + loadweight_oth;
650hA      other;
             Exec Sql
               Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
                 into :loadpick, :loadcube, :loadweight
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'D';
650hA     endsl;
          if sqlstt <> '00000';
            loadpick = 0;
            loadcube = 0;
            loadweight = 0;
          endif;
          #aopfvi5 = %editw(loadpick:editw9z);
          #aopfvi6 = %editw(loadcube:editw103);
          #aopfvi7 = %editw(loadweight:editw102);

          // Write APT record.
          $apseq# = $apseq# + 1;
          exsr writeapt;

          // Build Cooler Load record -----------------------------
          palletcount = 0;
          // Get cooler pallet count
650hA     select;
650hA      when client = ledyrd;
             Exec Sql
               Select count(distinct PSPAL#)
                 into :palletcount
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
650hA             and PSCOMP IN('R','P','E');
650hA      when client = frf;
650hA        Exec Sql
650hA          Select count(distinct PSPAL#)
650hA            into :palletcount
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN('C','M');
750lA      when client = prestofoods;
750lA        Exec Sql
750lA          Select count(distinct PSPAL#)
750lA            into :palletcount
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP IN('C','O', 'P', 'R', 'Y');
650hA      other;
             Exec Sql
               Select count(distinct PSPAL#)
                 into :palletcount
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
650hA             and PSCOMP IN('R');
650hA     endsl;
          if sqlstt <> '00000';
            palletrefer = 0;
          endif;

          #aopfvi1 = %editw(palletcount:editw9z);
650gD   //#aopfline = %trim(rhrte + '2'
650gD   //          + %char((%date(ptgdte:*iso) + %days(1)):*mdy0));
650gM     #aopfline = %trim(rhrte) + '2'
650gM               + %char((%date(ptgdte:*iso) + %days(1)):*mdy0);
          #aopfjob = '0602';

          // Get cases, cube & weight
650hA     select;
650hA      when client = ledyrd;
             Exec Sql
               Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
                 into :loadpick, :loadcube, :loadweight
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP IN('R','P','E');
650hA      when client = frf;
650hA        Exec Sql
650hA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
650hA            into :loadpick, :loadcube, :loadweight
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN('C','M');
750lA      when client = prestofoods;
750lA        Exec Sql
750lA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
750lA            into :loadpick, :loadcube, :loadweight
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP IN('C','O', 'P', 'R', 'Y');
650hA      other;
             Exec Sql
               Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
                 into :loadpick, :loadcube, :loadweight
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP IN('R');
650hA     endsl;
          if sqlstt <> '00000';
            loadpick = 0;
            loadcube = 0;
            loadweight = 0;
          endif;
          #aopfvi5 = %editw(loadpick:editw9z);
          #aopfvi6 = %editw(loadcube:editw103);
          #aopfvi7 = %editw(loadweight:editw102);

          // Write APT record.
          $apseq# = $apseq# + 1;
          exsr writeapt;

          // Build Freezer Load record ---------------------------
          // Get pallet count
          palletcount = 0;
650hA     select;
650hA      when client = ledyrd;
             Exec Sql
               Select count(distinct PSPAL#)
                 into :palletcount
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'F';
650hA      when client = frf;
650hA        Exec Sql
650hA          Select count(distinct PSPAL#)
650hA            into :palletcount
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN ('F','I','Z');
750lA      when client = prestofoods;
750lA        Exec Sql
750lA          Select count(distinct PSPAL#)
750lA            into :palletcount
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP IN('B','F', 'G', 'I', 'M', 'Q', 'T', 'Z');
650hA      other;
             Exec Sql
               Select count(distinct PSPAL#)
                 into :palletcount
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'F';
650hA     endsl;
          if sqlstt <> '00000';
            palletcount = 0;
          endif;
          #aopfvi1 = %editw(palletcount:editw9z);
650gD   //#aopfline = %trim(rhrte + '3'
650gD   //          + %char((%date(ptgdte:*iso) + %days(1)):*mdy0));
650gM     #aopfline = %trim(rhrte) + '3'
650gM               + %char((%date(ptgdte:*iso) + %days(1)):*mdy0);
          #aopfjob = '0603';

          // Get cases, cube & weight
650hA     select;
650hA      when client = ledyrd;
             Exec Sql
               Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
                 into :loadpick, :loadcube, :loadweight
                 from PLTSUM3
                where PSWHSE = :$apwhse
                  and PSRTID = :$aprteid
                  and PSTRN# <> 0
                  and PSGEN = 1
                  and PSCOMP = 'F';
650hA      when client = frf;
650hA        Exec Sql
650hA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
650hA            into :loadpick, :loadcube, :loadweight
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN ('F','I','Z');
750lA      when client = prestofoods;
750lA        Exec Sql
750lA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
750lA            into :loadpick, :loadcube, :loadweight
750lA            from PLTSUM3
750lA           where PSWHSE = :$apwhse
750lA             and PSRTID = :$aprteid
750lA             and PSTRN# <> 0
750lA             and PSGEN = 1
750lA             and PSCOMP IN('B','F', 'G', 'I', 'M', 'Q', 'T', 'Z');
650hA      other;
650hA        Exec Sql
650hA          Select sum(PSPCS), sum(PSCUBE), sum(PSSWGT)
650hA            into :loadpick, :loadcube, :loadweight
650hA            from PLTSUM3
650hA           where PSWHSE = :$apwhse
650hA             and PSRTID = :$aprteid
650hA             and PSTRN# <> 0
650hA             and PSGEN = 1
650hA             and PSCOMP IN ('F');
650hA     endsl;
          if sqlstt <> '00000';
            loadpick = 0;
            loadcube = 0;
            loadweight = 0;
          endif;
          #aopfvi5 = %editw(loadpick:editw9z);
          #aopfvi6 = %editw(loadcube:editw103);
          #aopfvi7 = %editw(loadweight:editw102);

          // Write APT record.
          $apseq# = $apseq# + 1;
          exsr writeapt;

        endsr;  // procpicksum
      /end-free

     *----------------------------------------------------------------
     *  Process Replenishment labels for zone
     *----------------------------------------------------------------
      /free
        begsr procreplenish;

          // Clear data structure format.
          exsr inzaptout;

          // Get dock door assigned to this transaction.
          $lwhse = lbwhse;
          $lrtid = $aprteid;
          $ltrn# = lsttrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          // If no slot assigned for item, set default.
          if $aplocation = *blanks;
            exsr zznoslot;
          endif;

          // Get customer route ID
          kywhse = $apwhse;
          kyrte = $aprteid;
          exsr getrtehed;
          #aopfrte2 = rhrte;
          #aopfrte = $aprteid;

          #aopfbtch = %trim(%editw(lsttrn#:editw7));

          // If date is missing, use current date
          if ptgdte <= 0;
            ptgdte = %dec(%char(%date():*iso0):8:0);
          endif;
          #aopfdate = %char(%date(ptgdte:*iso):*iso-);
          #aopftime = %trim(%editw(ptstim:editw6));
          #aopfline = %trim(%editw(lbseq:editw6));

          #aopfvi1 = '0';
          #aopfvi2 = '0';
          #aopfvi3 = '0';
          #aopfvi4 = '0';
          #aopfvi5 = '0';
          #aopfvi6 = '0';
          #aopfvi7 = '0';
          #aopfvi8 = %trim(%editw(lbswgt:editw102));
          #aopfvi9 = %trim(%editw(lbcube:editw103));
          #aopfvi10 = '0';

          exsr zzaptdept;
          #aopfjob = '05' + aptdeptcd;
          if $apseq# = 0;
            #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
          else;
            #aopfrom = prevloc;
          endif;
          #aopto = $aplocation;
          prevloc = $aplocation;

          #aopfill6 = 'Slot  ';
          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt;

        endsr;  // procreplenish
      /end-free

     *----------------------------------------------------------------
     *  Process Fixed/PIR selection labels for zone
     *----------------------------------------------------------------
      /free
       begsr procselection;

         recswrote = 'N';
         $apseq# = 0;
         kypstype   = 'O';
         lastpstrn# = *loval;
         setll ($apwhse: $aprteid: kypstype) pltsum3ap;
         dow forever = forever;
750bD    //reade ($apwhse: $aprteid: kypstype) pltsum3ap;
750bM      reade ($apwhse: $aprteid) pltsum3ap;
           select;
             when %eof(pltsum3ap);
               leave;

             // Skip all empty pallet locations.
             when ps3pstrn# <= 0
               // Skip transaction already processed.
               or ps3pstrn# = lastpstrn#;
               iter;

             // Process Transaction labels.

             other;

               lastpstrn# = ps3pstrn#;
               lsttrn# = -(1);
               lstlbl# = -(1);
               lsttype = *loval;
               lstpzon = *loval;
               lstszon = *loval;

               setll ($apwhse: $aprteid: kylbtype: ps3pstrn#) label32;
               dou forever <> forever;
                 reade ($apwhse: $aprteid: kylbtype: ps3pstrn#) label32;
                 select;

                   when %eof(label32);  // last label record

                     // No LBTYPE=O records on transaction. Set to pallet tran#.
                     if lsttrn# <= 0;
                       lsttrn# = PS3pstrn#;
                       roassignment = ' ';
                     endif;

                     // Create "Obtain" record for Merge records for last transa
                     kylbtype = 'M';
                     exsr procmerge;
                     kylbtype = 'O';

                     if recswrote = 'Y';
                       exsr pickplc;
                     endif;

                     leave;

                   // Skip label if already closed.

                // when lbstat = 'C';
                //   iter;

                   // Skip label if nothing was picked.

                   when lbqpck = 0;
                     iter;

                   // Skip label if cross dock.

                   when lbstyp = 'X';
                     iter;

                   other;

                     // Get transaction record each time transaction chg's.

                     if lbtrn# <> lsttrn#;

                       // Record is written out when transaction# changes
                       // so that we can set the "Last Move" flag.

                       // This test is done so that first read doesn't
                       // write out a "place" record.
                       if $apseq# > 0;

                         // Create "Obtain" record for Merge records for last tr
                         kylbtype = 'M';
                         exsr procmerge;
                         kylbtype = 'O';

                         if recswrote = 'Y';
                           exsr pickplc;
                         endif;
                       endif;

                       kytrn# = lbtrn#;
                       exsr gettran;
                       if error = *on;
                         pttrn# = 0;
                       endif;

                       lsttrn# = lbtrn#;
                       lsttype = lbtype;
                       lstpzon = pspzon;
                       lstszon = psszon;

                     endif;

                     // extract row and column from pallet number
                     dsplid = lbpal#;
                     col = dsplcl;

                     // Clear data structure format.
                     exsr inzaptout;

                     // Retrieve "base" slot for floor pick.
                     kywhse = lbwhse;
                     kywhdp = lbwhdp;
                     kydisp = lbdisp;
                     exsr getslot;

                     if error;
                       $aplocation = *blanks;
                     else;
                       $aplocation = $sacdsp;
                     endif;

                     // If no slot assigned for item, set default.
                     if $aplocation = *blanks;
                       exsr zznoslot;
                     endif;

                     lstlbl# = lblbl#;

                     // Get customer route ID
                     kywhse = $apwhse;
                     kyrte = $aprteid;
                     exsr getrtehed;
                     #aopfrte2 = rhrte;
                     #aopfrte = $aprteid;

                     #aopfbldg = '001';
750dD                //#aopfbtch = %trim(%editw(lsttrn#:editw7));
750dM                #aopfbtch = %trimr(%editc(lsttrn#:'4'));

                     // If date is missing, use current date
                     if ptgdte <= 0;
                       ptgdte = %dec(%char(%date():*iso0):8:0);
                     endif;
                     #aopfdate = %char(%date(ptgdte:*iso):*iso-);
                     #aopftime = %trim(%editw(ptstim:editw6));
                     #aopfline = %trim(%editw(lbseq:editw6));

                     #aopfvi1 = %editw(lbqpck:editw9z);
                     #aopfvi2 = %editw(0:editw9z);
                     #aopfvi3 = %editw(0:editw9z);
                     #aopfvi4 = %editw(1:editw9z);
                     #aopfvi5 = %editw(0:editw9z);

                     kywhse = lbwhse;
                     kyitem = lbitem;
                     exsr getitem;
                     if $itcwgt = 'Y';
650cD             //   #aopfvi6 = %trim(%editw(1:editu10));
650cM                  #aopfvi6 = %editw(lbqpck:editw9z);
                     else;
                       #aopfvi6 = %editw(0:editw9z);
                     endif;

                     #aopfvi7 = %editw(0:editw9z);
                     #aopfvi8 = %trim(%editw(lbswgt:editw102));
                     #aopfvi9 = %trim(%editw(lbcube:editw103));
                     #aopfvi10 = %editw(0:editw9z);

                     exsr zzaptdept;
                     #aopfjob = '05' + aptdeptcd;
                     if $apseq# = 0
                       or prevloc = *blank;
                         #aopfrom = 'T' + %trim(aptdeptcd) + 'START';
                     else;
                       #aopfrom = prevloc;
                     endif;
                     #aopto = $aplocation;
                     // remove dashes from slot
                     pos = %scan('-': #aopfrom);
                     dow pos > 0;
                        #aopfrom = %replace('': #aopfrom: pos: 1);
                        pos = %scan('-': #aopfrom);
                     enddo;
                     pos = %scan('-': #aopto);
                     dow pos > 0;
                        #aopto = %replace('': #aopto: pos: 1);
                        pos = %scan('-': #aopto);
                     enddo;

                     prevloc = $aplocation;

                     #aopfill6 = 'Slot  ';
                     $apseq# = $apseq# + 1;
                     recswrote = 'Y';

                     // Write APT record.
                     exsr writeapt;

                 endsl;
               enddo;
           endsl;
         enddo;

        endsr;   // procselection
      /end-free

740bA*----------------------------------------------------------------
740bA*  putawybeg    Putaway - Create "begin" record.
740bA*----------------------------------------------------------------
740bA /free
740bA   begsr putawybeg;
740bA
740bA     // Clear data structure format.
740bA     exsr inzaptout2;
740bA
740bA     #aodtseq = %trimr(%editw($apseq#:editw6nz));
740bA     #aodtpkr = %trim(%editw($apemp#:editw5));
740bA     #aodtrun = %char($aptrn#);
740bA     #aodtline = ' '+ %char($aplbl#);
740bA     #aodtrte = 'putawybeg';
740bA
740bA     // Retrieve label info
740bA     kylbl# = $aplbl#;
740bA     exsr getlabel;
740bA
740bA     // Retrieve transaction info
740bA     kytrn# = $aptrn#;
740bA     exsr gettran;
740bA
740bA     // Retrieve previous transaction info
740bA     kytrn# = $aptrn#;
740bA     exsr gettranprv;
740bA
740bA     if prv_ptedte = 0;
740bA       prv_ptedte = ptsdte;
740bA     endif;
740bA     #aodtsdate = %char(%date(prv_ptedte:*iso):*iso-);
740bA     #aodtstime = %trim(%editw(prv_ptetim:editw6));
740bA     if ptsdte > 0;
740bA       #aodtedate = %char(%date(ptsdte:*iso):*iso-);
740bA     else;
740bA       #aodtedate = '0000-00-00';
740bA     endif;
740bA     if ptstim > 0;
740bA       #aodtetime = %trim(%editw(ptstim:editw6));
740bA     else;
740bA       #aodtetime = '000000';
740bA     endif;
740bA
740bA     // Retrieve slot info
740bA     kywhse = lb_lbwhse;
740bA     kywhdp = lb_lbwhdp;
740bA     kydisp = lb_lbdisp;
740bA     exsr getslot;
740bA
740bA     #aodtvi1 = %trim(%editw(0:editu10));
740bA
740bA       if ptpcs < lb_lbqalc;
740bA         if client = frf;
740bA           #aodtrte = 'putawyplX';
740bA           exsr zzfrfconv;
740bA         endif;
740bA         #aodtvi2 = %trim(%editw(ptpcs:editu10));
740bA       else;
740bA         #aodtvi2 = %trim(%editw(0:editu10));
740bA       endif;
740bA
740bA     // Get count of active virtual slots
740bA     Exec sql Select count(*)
740bA                into :rotatepals
740bA                from SLOT
740bA               where SLAISL = :$slaisl
740bA                 and SLLOC = :$slloc
740bA                 and SLRLVL = :$slrlvl
740bA                 and SLSTAT <> 'Z'
740bA                 and SLSTAT <> 'V';
740bA     if SQLSTT <> sqlSuccess
740bA       or $slsdef = 'FS';
740bA       rotatepals = 1;
740bA     endif;
750aD   //#aodtvi3 = %trim(%editw((rotatepals-1):editu10));
750aM     #aodtvi3 = %trim(%editw(0:editu10));
740bA
740bA     #aodtvi4 = %trim(%editw(0:editu10));
740bA     #aodtvi5 = %trim(%editw(0:editu10));
740bA     #aodtvi6 = %trim(%editw(0:editu10));
740bA     #aodtvi7 = %trim(%editw(0:editu10));
740bA     #aodtvi8 = %trim(%editw(0:editu10));
740bA     #aodtvi9 = %trim(%editw(0:editu10));
740bA     #aodtvi10 = %trim(%editw(0:editu10));
740bA
740bA     #aodtjob = '0300';
740bA     #aodtfill6 = 'Slot  ';
740bA     #aodtfrom = prevloc;
740bA     #aodtto = 'RCVDOCK';
740bA     // remove dashes from slot
740bA     pos = %scan('-': #aodtfrom);
740bA     dow pos > 0;
740bA        #aodtfrom = %replace('': #aodtfrom: pos: 1);
740bA        pos = %scan('-': #aodtfrom);
740bA     enddo;
740bA     pos = %scan('-': #aodtto);
740bA     dow pos > 0;
740bA        #aodtto = %replace('': #aodtto: pos: 1);
740bA        pos = %scan('-': #aodtto);
740bA     enddo;
740bA     exsr zzaptdept2;
740bA     #aodtarea = aptdeptcd;
740bA     prevloc = #aodtto;
750aA     if #aodtfrom = *blanks;
750aA       #aodtfrom = '1111111111';
750aA     endif;
740bA
740bA     $apseq# = $apseq# + 1;
740bA
740bA     // Write APT record.
740bA
740bA     exsr writeapt2;
740bA
740bA   endsr;  // putawyplc
740bA /end-free
740bA
     *----------------------------------------------------------------
     *  putawyplc    Putaway - Create "place" record.
     *----------------------------------------------------------------
      /free
        begsr putawyplc;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'putawyplc';

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          #aodtsdate = %char(%date(ptsdte:*iso):*iso-);
          #aodtstime = %trim(%editw(ptstim:editw6));
          if ptedte > 0;
            #aodtedate = %char(%date(ptedte:*iso):*iso-);
          else;
            #aodtedate = '0000-00-00';
          endif;
          if ptetim > 0;
            #aodtetime = %trim(%editw(ptetim:editw6));
          else;
            #aodtetime = '000000';
          endif;

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdisp;
          exsr getslot;

          #aodtvi1 = %trim(%editw(ptqty1:editu10));

          // If slot is handstack type, put pieces in KVI2
650kD   //if $slsdef = 'HS';
650kM   //if $slsdef = 'FS' or $slsdef = '01';
650kD       if ptpcs < lb_lbqalc;
650fA         if client = frf;
650lA           #aodtrte = 'putawyplX';
650fA           exsr zzfrfconv;
650fA         endif;
650aA         #aodtvi2 = %trim(%editw(ptpcs:editu10));
650lM       else;
650lM         #aodtvi2 = %trim(%editw(0:editu10));
650aD       endif;
650kD   //else;
650kD   //  #aodtvi2 = %trim(%editw(0:editu10));
650kD   //endif;

          // Get count of active virtual slots
          Exec sql Select count(*)
                     into :rotatepals
                     from SLOT
                    where SLAISL = :$slaisl
                      and SLLOC = :$slloc
                      and SLRLVL = :$slrlvl
                      and SLSTAT <> 'V'
740bA                 and SLSTAT <> 'Z';
650eM     if SQLSTT <> sqlSuccess
650eA       or $slsdef = 'FS';
            rotatepals = 1;
          endif;
          #aodtvi3 = %trim(%editw((rotatepals-1):editu10));

          #aodtvi4 = %trim(%editw(0:editu10));
          #aodtvi5 = %trim(%editw(0:editu10));
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));

          if $slpick = 'Y';
             #aodtvi8 = %trim(%editw(1:editu10));
          else;
             #aodtvi8 = %trim(%editw(0:editu10));
          endif;

          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          #aodtjob = '0300';
          #aodtfill6 = 'Slot  ';
          #aodtfrom = prevloc;
          #aodtto = lb_lbdisp;
          // remove dashes from slot
          pos = %scan('-': #aodtfrom);
          dow pos > 0;
             #aodtfrom = %replace('': #aodtfrom: pos: 1);
             pos = %scan('-': #aodtfrom);
          enddo;
          pos = %scan('-': #aodtto);
          dow pos > 0;
             #aodtto = %replace('': #aodtto: pos: 1);
             pos = %scan('-': #aodtto);
          enddo;
          exsr zzaptdept2;
          #aodtarea = aptdeptcd;
          prevloc = #aodtto;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;

        endsr;  // putawyplc
      /end-free

     *----------------------------------------------------------------
     *  rcvbeg       Begin receiving
     *----------------------------------------------------------------
      /free
        begsr rcvbeg;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'rcvbeg';

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          // Get dock door assigned to this transaction.
          $lwhse = lb_lbwhse;
          $lrtid = $aprteid;
          $ltrn# = $aptrn#;
          $lwhdp = *blanks;
          exsr getdockdoor;

          #aodtsdate = %char(%date(ptgdte:*iso):*iso-);
          #aodtstime = %trim(%editw(ptgtim:editw6));
          #aodtedate = %char(%date(ptgdte:*iso):*iso-);
          #aodtetime = %trim(%editw(ptgtim:editw6));

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdisp;
          exsr getslot;

          kywhse = lb_lbwhse;
          kyitem = lb_lbitem;
          exsr getitem;

          #aodtvi1 = %trim(%editw(ptpcs:editu10));
750cM     #aodtvi2 = %trim(%editw($imtie:editu10));
750cM     #aodtvi3 = %trim(%editw($imhigh:editu10));
          #aodtvi5 = %trim(%editw(0:editu10));
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));
          #aodtvi9 = %trim(%editw(1:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          if $itflgd = 'Y';
            #aodtvi4 = %trim(%editw(1:editu10));
          else;
            #aodtvi4 = %trim(%editw(0:editu10));
          endif;

          if rcvitem <> lb_lbitem;
            #aodtvi8 = %trim(%editw(1:editu10));
            rcvitem = lb_lbitem;
          else;
            #aodtvi8 = %trim(%editw(0:editu10));
          endif;

          #aodtjob = '0100';
          #aodtfill6 = 'Slot  ';
          #aodtfrom = 'TDDR' + %char($ldoor) + 'D';
          #aodtto = 'TDDR' + %char($ldoor) + 'D';
750aA     if #aodtfrom = *blanks;
750aA       #aodtfrom = '1111111111';
750aA     endif;

          exsr zzaptdept2;
          #aodtarea = aptdeptcd;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;

        endsr;  // rcvbeg
      /end-free

750aA*----------------------------------------------------------------
750aA*  rtnrec    Create Return record.
750aA*----------------------------------------------------------------
750aA /free
750aA   begsr rtnrec;
750aA
750aA     // Clear data structure format.
750aA     exsr inzaptout3;
750nA
750nA    setll ($apwhse: $appbat: $apitem: $aprdte) orrtn1;
750nA    reade ($apwhse: $appbat: $apitem: $aprdte) orrtn1;
750nA    select;
750nA    when %eof(orrtn1);
750nA      leavesr;
750aA   endsl;
750nA
750aA     // Get BFC order number from Customer order number
750nA     kyord# = 0;
750aA     exec sql select ohord into :kyord#
750aA                from ordh
750aA               where ohwhse = :$apwhse
750aA                 and ohcord = :$apord;
750aA
750aA     // Get transaction number from order number
750pA     $aptrn# = 0;
750aA     exec sql select lbtrn# into :$aptrn#
750aA                from label
750aA               where lbwhse = :$apwhse
750aA                 and lbord = :kyord#
750nM                 and lbitem = :$apitem
750pA                 and (lbtype = 'B'
750pA                   or lbtype = 'O')
750aA               fetch first row only;
750aA
750nA     aplbl#    = orolb#;
750aA     #aortbldg = '795QCF';
750aA     #aortbatch = $aptrn#;
750nA     if %subst($aprcod:1:1) <> '0';
750nA       #aortresn = %subst($aprcod:1:1);
750nA       #aortexcl = %subst($aprcod:2:1);
750nA     else;
750nM     #aortresn = %subst($aprcod:2:1);
750nA     endif;
750aA     #aortadte = %char(%date():*iso-);
750aA
750nA     if orqty1 > 0;
750nA       #aortcqty = orqty1;
750nA       // Write APT record.
750nA       exsr writeapt3;
750nA     endif;
750aA
750nA     if orqty2 > 0;
750nA       #aortcqty = orqty2;
750nA       // Write APT record.
750nA       exsr writeapt3;
750nA     endif;
750aA
750nA     if orqty3 > 0;
750nA       #aortcqty = orqty3;
750nA       // Write APT record.
750nA       exsr writeapt3;
750nA     endif;
750aA
750aA   endsr;  // rtnrec
750aA /end-free
750aA
     *----------------------------------------------------------------
     *  rplbeg   Begin replenishment
     *----------------------------------------------------------------
      /free
        begsr rplbeg;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'rplbeg';

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          // Retrieve previous transaction info
          kytrn# = $aptrn#;
          exsr gettranprv;

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          if prv_ptedte > 0;
740bA       #aodtsdate = %char(%date(prv_ptedte:*iso):*iso-);
740bA       #aodtstime = %trim(%editw(prv_ptetim:editw6));
          else;
740bA       #aodtsdate = '0000-00-00';
740bA       #aodtstime = '000000';
          endif;
          if ptedte > 0;
            #aodtedate = %char(%date(ptedte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptetim:editw6));
          else;
            #aodtedate = %char(%date(ptgdte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptstim:editw6));
          endif;

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdisp;
          exsr getslot;

          #aodtvi1 = %trim(%editw(0:editu10));

          // If slot is handstack type, put pieces in KVI2
          if $slsdef = 'HS';
            #aodtvi2 = %trim(%editw(ptpcs:editu10));
          else;
            #aodtvi2 = %trim(%editw(0:editu10));
          endif;

          #aodtvi3 = %trim(%editw(0:editu10));

          // Get count of active virtual slots
          Exec sql Select count(*)
                     into :rotatepals
                     from SLOT
                    where SLAISL = :$slaisl
                      and SLLOC = :$slloc
                      and SLRLVL = :$slrlvl
                      and SLSTAT <> 'V'
                      and SLSTAT <> 'Z';
650eD   //if SQLSTT <> sqlSuccess;
650eM     if SQLSTT <> sqlSuccess
650eA       or $slsdef = 'FS';
            rotatepals = 1;
          endif;
          #aodtvi4 = %trim(%editw((rotatepals-1):editu10));

          #aodtvi5 = %trim(%editw(0:editu10));
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));

        //if $slsdef = 'HS';
             #aodtvi8 = %trim(%editw(0:editu10));
        //else;
        //   #aodtvi8 = %trim(%editw(1:editu10));
        //endif;

          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          #aodtjob = '0400';
          #aodtfill6 = 'Slot  ';

          #aodtfrom = prevloc;
          #aodtto = lb_lbdisp;
740bD   //if #aodtfrom = *blanks;
740bD   //  #aodtfrom = lb_lbdisp;
740bD   //endif;
          // remove dashes from slot
          pos = %scan('-': #aodtfrom);
          dow pos > 0;
             #aodtfrom = %replace('': #aodtfrom: pos: 1);
             pos = %scan('-': #aodtfrom);
          enddo;
          pos = %scan('-': #aodtto);
          dow pos > 0;
             #aodtto = %replace('': #aodtto: pos: 1);
             pos = %scan('-': #aodtto);
          enddo;
          prevloc = #aodtto;
750aA     if #aodtfrom = *blanks;
750aA       #aodtfrom = '1111111111';
750aA     endif;

          exsr zzaptdept2;
          #aodtarea = aptdeptcd;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;

        endsr;  // rplbeg
      /end-free

     *----------------------------------------------------------------
     *  rplend   End replenishment
     *----------------------------------------------------------------
      /free
        begsr rplend;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'rplend';

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          if ptsdte > 0;
            #aodtsdate = %char(%date(ptsdte:*iso):*iso-);
            #aodtstime = %trim(%editw(ptstim:editw6));
          else;
            #aodtsdate = %char(%date(ptgdte:*iso):*iso-);
            #aodtstime = %trim(%editw(ptstim:editw6));
          endif;
          if ptedte > 0;
            #aodtedate = %char(%date(ptedte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptetim:editw6));
          else;
            #aodtedate = %char(%date(ptgdte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptstim:editw6));
          endif;

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdsp2;
          exsr getslot;

750eD     //if ptpcs < lb_lbqalc;
750eM     if ptpcs < lb_lbqalc or $psubcmd = '*RPLEND3';
            #aodtvi1 = %trim(%editw(1:editu10));
750xA     else;
750xA       #aodtvi1 = %trim(%editw(0:editu10));
750xA     endif;

          // If slot is handstack type, put pieces in KVI2
650kD   //if $slsdef = 'HS';
650kM   //if $slsdef = 'FS' or $slsdef = '01';

750mA   // Presto wanted HS logic reimplemented

750mD       //if ptpcs < lb_lbqalc;
750mM       if ptpcs < lb_lbqalc or $slsdef = 'HS';
650fA         if client = frf;
650lA           #aodtrte = 'rplendX  ';
650fA           exsr zzfrfconv;
650fA         endif;
650aA         #aodtvi2 = %trim(%editw(ptpcs:editu10));
650lM       else;
650lM         #aodtvi2 = %trim(%editw(0:editu10));
650aD       endif;
650kM   //else;
650kM   //  #aodtvi2 = %trim(%editw(0:editu10));
650kM   //endif;

          #aodtvi3 = %trim(%editw(0:editu10));
          #aodtvi4 = %trim(%editw(0:editu10));

          // Get count of active virtual slots
          Exec sql Select count(*)
                     into :rotatepals
                     from SLOT
                    where SLAISL = :$slaisl
                      and SLLOC = :$slloc
                      and SLRLVL = :$slrlvl
                      and SLSTAT <> 'V'
                      and SLSTAT <> 'Z';
650eM     if SQLSTT <> sqlSuccess
650eA       or $slsdef = 'FS';
            rotatepals = 1;
          endif;
650aA     #aodtvi5 = %trim(%editw((rotatepals-1):editu10));

          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));

750gA     // Spreadsheet says:
750gA     // "Send a "1" if the Pick slot is NOT a handstack slot."
750gA     // Therefore,
750gA     //    Set to zero if slot def is 'HS'
750gA     //    Set to 1 if full pallet replenished (*RPLEND3)
750gA     //    Otherwise, set to zero
750gA     // For a partial replen, the RPLEND record is for putting
750gA     // qty back into overflow slot, thus we set this value to
750gA     // because spreadsheet specifically says Pick slot.

750iA     // Misunderstood Excel comment,
750iA     // Set to zero if slot def is 'HS'
750iA     // Otherwise, set to 1

750jD     //if $slsdef = 'HS';
750jD     //   #aodtvi8 = %trim(%editw(0:editu10));
750jD     //else;
750gD       //if ptpcs < lb_lbqalc;
750iD       //if $psubcmd = '*RPLEND3';
750jD        //#aodtvi8 = %trim(%editw(1:editu10));
750iD       //else;
750iD       // #aodtvi8 = %trim(%editw(0:editu10));
750iD       //endif;
750jD     //endif;

750jA     // All Presto wants (only one using this at the time)
750jA     // it to set to 1 if entire qty replen (RPLEND3)
750jA     // Otherwise, set to 0

750mA     // Presto wanted HS to be reimplemented

750mD     // if $psubcmd = '*RPLEND3';
750mM     if $psubcmd = '*RPLEND3' and $slsdef <> 'HS';
750jA        #aodtvi8 = %trim(%editw(1:editu10));
750jA     else;
750jA        #aodtvi8 = %trim(%editw(0:editu10));
750jA     endif;

          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          #aodtjob = '0400';
          #aodtfill6 = 'Slot  ';

          #aodtfrom = prevloc;
          #aodtto = lb_lbdsp2;
          if #aodtfrom = *blanks;
            #aodtfrom = lb_lbdsp2;
          endif;
          // remove dashes from slot
          pos = %scan('-': #aodtfrom);
          dow pos > 0;
             #aodtfrom = %replace('': #aodtfrom: pos: 1);
             pos = %scan('-': #aodtfrom);
          enddo;
          pos = %scan('-': #aodtto);
          dow pos > 0;
             #aodtto = %replace('': #aodtto: pos: 1);
             pos = %scan('-': #aodtto);
          enddo;
          prevloc = #aodtto;

          exsr zzaptdept2;
          #aodtarea = aptdeptcd;

          $apseq# = $apseq# + 1;

750eA     // Convert *RPLEND3 back to *RPLEND
750eA
750eA     if $psubcmd = '*RPLEND3';
750eA       $psubcmd = '*RPLEND';
750eA     endif;

          // Write APT record.

          exsr writeapt2;

        endsr;  // rplend
      /end-free

     *----------------------------------------------------------------
     *  rplplc   Replenishment place record
     *----------------------------------------------------------------
      /free
        begsr rplplc;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'rplplc';

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          if ptsdte > 0;
            #aodtsdate = %char(%date(ptsdte:*iso):*iso-);
            #aodtstime = %trim(%editw(ptstim:editw6));
          else;
            #aodtsdate = %char(%date(ptgdte:*iso):*iso-);
            #aodtstime = %trim(%editw(ptstim:editw6));
          endif;
          if ptedte > 0;
            #aodtedate = %char(%date(ptedte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptetim:editw6));
          else;
            #aodtedate = %char(%date(ptgdte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptstim:editw6));
          endif;

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdsp2;
          exsr getslot;

          #aodtvi1 = %trim(%editw(1:editu10));

          // If slot is handstack type, put pieces in KVI2
650kD   //if $slsdef = 'HS';
650kM   //if $slsdef = 'FS' or $slsdef = '01';
750hD   //    if ptpcs < lb_lbqalc;
750hD   //      if client = frf;
750hD   //        #aodtrte = 'rplendX  ';
750hD   //        exsr zzfrfconv;
750hD   //      endif;
650aA         #aodtvi2 = %trim(%editw(ptpcs:editu10));
750hD   //    else;
750hD   //      #aodtvi2 = %trim(%editw(0:editu10));
750hD   //    endif;
650kM   //else;
650kM   //  #aodtvi2 = %trim(%editw(0:editu10));
650kM   //endif;

          #aodtvi3 = %trim(%editw(0:editu10));

          // Get count of active virtual slots
          Exec sql Select count(*)
                     into :rotatepals
                     from SLOT
                    where SLAISL = :$slaisl
                      and SLLOC = :$slloc
                      and SLRLVL = :$slrlvl
                      and SLSTAT <> 'V'
                      and SLSTAT <> 'Z';
          if SQLSTT <> sqlSuccess
            or $slsdef = 'FS';
            rotatepals = 1;
          endif;
          #aodtvi4 = %trim(%editw(0:editu10));

          if ptpcs < lb_lbqalc;
            #aodtvi5 = %trim(%editw((rotatepals-1):editu10));
          else;
            #aodtvi5 = %trim(%editw(0:editu10));
          endif;
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));

750gA     // Spreadsheet says:
750gA     // "Send a "1" if the Pick slot is NOT a handstack slot."
750gA     // Therefore, since 'place' is only called when a partial
750gA     // quantity is replenished, set KVI-8 to 0, not 1.

750hA     // Misunderstood Excel comment,
750hA     // Set to zero if slot def is 'HS'
750hA     // Otherwise, set to 1

750jA     // All Presto wants (only one using this at the time)
750jA     // it to set to 1 when putting into Pick slot

750mA     // Presto wanted HS to be reimplemented

750gD     //#aodtvi8 = %trim(%editw(1:editu10));
750mM     if $slsdef = 'HS';
750mM       #aodtvi8 = %trim(%editw(0:editu10));
750mM     else;
750iA       #aodtvi8 = %trim(%editw(1:editu10));
750mM     endif;

          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          #aodtjob = '0400';
          #aodtfill6 = 'Slot  ';

          #aodtfrom = prevloc;
          #aodtto = lb_lbdsp2;
          if #aodtfrom = *blanks;
            #aodtfrom = lb_lbdsp2;
          endif;
          // remove dashes from slot
          pos = %scan('-': #aodtfrom);
          dow pos > 0;
             #aodtfrom = %replace('': #aodtfrom: pos: 1);
             pos = %scan('-': #aodtfrom);
          enddo;
          pos = %scan('-': #aodtto);
          dow pos > 0;
             #aodtto = %replace('': #aodtto: pos: 1);
             pos = %scan('-': #aodtto);
          enddo;
          prevloc = #aodtto;

          exsr zzaptdept2;
          #aodtarea = aptdeptcd;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;

        endsr;  // rplplc
      /end-free

     *----------------------------------------------------------------
     *  testtype   Determine type of manual task and process
     *----------------------------------------------------------------
      /free
        begsr testtype;

          // Get Task Record
          exsr gettasktype;

          // Proceed based on type of trans we are writing
          Select;

            when pttask = 'BEGDAY';
              exsr indirect;
            when pttask = 'ENDDAY';
              exsr indirect;
            when tasktype = 'I';
              exsr indirect;
            when pttask = 'PUTEMP';
              exsr putawyplc;
          endsl;

        endsr;  // testtype
      /end-free

     *----------------------------------------------------------------
     *  tfrbeg   Begin transfer
     *----------------------------------------------------------------
      /free
        begsr tfrbeg;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'tfrbeg';

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          // Retrieve previous transaction info
          kytrn# = $aptrn#;
          exsr gettranprv;

          if prv_ptedte > 0;
            #aodtsdate = %char(%date(prv_ptedte:*iso):*iso-);
            #aodtstime = %trim(%editw(prvtrnetm:editw6));
          else;
740bA       #aodtsdate = '0000-00-00';
740bA       #aodtstime = '000000';
          endif;
          if ptsdte > 0;
            #aodtedate = %char(%date(ptsdte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptstim:editw6));
          endif;

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdisp;
          exsr getslot;

          #aodtvi1 = %trim(%editw(0:editu10));
          #aodtvi2 = %trim(%editw(0:editu10));
          #aodtvi3 = %trim(%editw(0:editu10));
          #aodtvi4 = %trim(%editw(1:editu10));
          #aodtvi5 = %trim(%editw(0:editu10));
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));
          #aodtvi8 = %trim(%editw(0:editu10));
          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          exsr gettasktype;
          #aodtjob = %subst(taskdesc:27:4);
          if #aodtjob = *blanks;
            #aodtjob = '0400';
          endif;
          #aodtfill6 = 'Slot  ';

          #aodtfrom = prevloc;
          #aodtto = lb_lbdisp;
          // remove dashes from slot
          pos = %scan('-': #aodtfrom);
          dow pos > 0;
             #aodtfrom = %replace('': #aodtfrom: pos: 1);
             pos = %scan('-': #aodtfrom);
          enddo;
          pos = %scan('-': #aodtto);
          dow pos > 0;
             #aodtto = %replace('': #aodtto: pos: 1);
             pos = %scan('-': #aodtto);
          enddo;
          prevloc = #aodtto;
750aA     if #aodtfrom = *blanks;
750aA       #aodtfrom = '1111111111';
750aA     endif;

          exsr zzaptdept2;
          #aodtarea = aptdeptcd;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;

        endsr;  // tfrbeg
      /end-free

     *----------------------------------------------------------------
     *  tfrend   End transfer
     *----------------------------------------------------------------
      /free
        begsr tfrend;

          // Clear data structure format.
          exsr inzaptout2;

          #aodtseq = %trimr(%editw($apseq#:editw6nz));
          #aodtpkr = %trim(%editw($apemp#:editw5));
          #aodtrun = %char($aptrn#);
          #aodtline = ' '+ %char($aplbl#);
          #aodtrte = 'tfrend';

          // Retrieve label info
          kylbl# = $aplbl#;
          exsr getlabel;

          // Retrieve transaction info
          kytrn# = $aptrn#;
          exsr gettran;

          if ptsdte > 0;
            #aodtsdate = %char(%date(ptsdte:*iso):*iso-);
            #aodtstime = %trim(%editw(ptstim:editw6));
          endif;
          if ptedte > 0;
            #aodtedate = %char(%date(ptedte:*iso):*iso-);
            #aodtetime = %trim(%editw(ptetim:editw6));
          endif;

          // Retrieve slot info
          kywhse = lb_lbwhse;
          kywhdp = lb_lbwhdp;
          kydisp = lb_lbdisp;
          exsr getslot;

          #aodtvi1 = %trim(%editw(0:editu10));
          #aodtvi2 = %trim(%editw(0:editu10));
          #aodtvi3 = %trim(%editw(0:editu10));
          #aodtvi4 = %trim(%editw(0:editu10));
          #aodtvi5 = %trim(%editw(1:editu10));
          #aodtvi6 = %trim(%editw(0:editu10));
          #aodtvi7 = %trim(%editw(0:editu10));

          if $slpick = 'Y';
             #aodtvi8 = %trim(%editw(1:editu10));
          else;
             #aodtvi8 = %trim(%editw(0:editu10));
          endif;

          #aodtvi9 = %trim(%editw(0:editu10));
          #aodtvi10 = %trim(%editw(0:editu10));

          exsr gettasktype;
          #aodtjob = %subst(taskdesc:27:4);
          if #aodtjob = *blanks;
            #aodtjob = '0400';
          endif;
          #aodtfill6 = 'Slot  ';

          #aodtfrom = prevloc;
          #aodtto = lb_lbdisp;
          // remove dashes from slot
          pos = %scan('-': #aodtfrom);
          dow pos > 0;
             #aodtfrom = %replace('': #aodtfrom: pos: 1);
             pos = %scan('-': #aodtfrom);
          enddo;
          pos = %scan('-': #aodtto);
          dow pos > 0;
             #aodtto = %replace('': #aodtto: pos: 1);
             pos = %scan('-': #aodtto);
          enddo;
          prevloc = #aodtto;

          exsr zzaptdept2;
          #aodtarea = aptdeptcd;

          $apseq# = $apseq# + 1;

          // Write APT record.

          exsr writeapt2;


        endsr;  // tfrend
      /end-free

     *----------------------------------------------------------------
     *  writeapt     Write APT record.
     *----------------------------------------------------------------
      /free
        begsr writeapt;

650jA     $preturn = '*OK';
650jA     $pmessage = ' ';
          #aopfseq = %trimr(%editw($apseq#:editw6nz));
          clear aptrec;
          apwhse= lbwhse;
          aprte = lbrte;
          aptype = %trimr(%editw($apseq#:editw10nz));
          appgm = $pprogram;
          clear aplbl#;
          clear aptrn#;
          apuser = $apuser;
          apjob  = $apjob;
          apjobn = $apjobn;
          apaddts = %timestamp();
          clear apexpts;
          clear apexpfile;

          // Use hold fields because we're behind one record when we
          // write out record.
          if $psubcmd = '*PICKGEN';
            aplbl# = lstlbl#;
            aptrn# = lsttrn#;
          else;
            aplbl# = lblbl#;
            aptrn# = pttrn#;
          endif;
          apexpdata = #aptout;

          // write record to data file
          exec sql
            insert into aptdata
              values(:APWHSE, :APRTE, :APPGM, :APTYPE,
                     :APLBL#, :APTRN#, :APUSER, :APJOB,
                     :APJOBN, :APADDTS, :APEXPTS,
                     :APEXPFILE, :APEXPDATA);

          if sqlcod <> 0;
            error = *on;
            $preturn = 'ERRADDREC';
            $pmessage = 'Error on "SQL Insert'
                      + 'APT" command '
                      + '('
                      + '/'
                      + ')'
                      + '-' + %char(sqlcod);
            leavesr;
          endif;

        endsr;  // writeapt
      /end-free

     *----------------------------------------------------------------
     *  writeapt2    Write APT record.
     *----------------------------------------------------------------
      /free
        begsr writeapt2;

650jA     $preturn = '*OK';
650jA     $pmessage = ' ';
          #aopfseq = %char($apseq#);
          clear aptrec;
          apwhse= $apwhse;
          clear aprte;
          appgm = $pprogram;
          aptype = $psubcmd;
          aplbl# = $aplbl#;
          aptrn# = $aptrn#;
          apuser = $apuser;
          apjob  = $apjob;
          apjobn = $apjobn;
          apaddts = %timestamp();
          clear apexpts;
          clear apexpfile;

          apexpdata = #aptout2;

          // write record to data file
          exec sql
            insert into aptdata
              values(:APWHSE, :APRTE, :APPGM, :APTYPE,
                     :APLBL#, :APTRN#, :APUSER, :APJOB,
                     :APJOBN, :APADDTS, :APEXPTS,
                     :APEXPFILE, :APEXPDATA);

          if sqlcod <> 0;
            error = *on;
            $preturn = 'ERRADDREC';
            $pmessage = 'Error on "SQL Insert'
                      + 'APT" command '
                      + '('
                      + '/'
                      + ')'
                      + '-' + %char(sqlcod);
            leavesr;
          endif;

        endsr;  // writeapt2
      /end-free

750aA*----------------------------------------------------------------
750aA*  writeapt3    Write APT record.
750aA*----------------------------------------------------------------
750aA /free
750aA   begsr writeapt3;
750aA
750aA     $preturn = '*OK';
750aA     $pmessage = ' ';
750aA     clear aptrec;
750aA     apwhse= $apwhse;
750aA     clear aprte;
750aA     appgm = $pprogram;
750aA     aptype = $psubcmd;
750aA     aplbl# = $aplbl#;
750aA     aptrn# = $aptrn#;
750aA     apuser = $apuser;
750aA     apjob  = $apjob;
750aA     apjobn = $apjobn;
750aA     apaddts = %timestamp();
750aA     clear apexpts;
750aA     clear apexpfile;
750aA
750aA     apexpdata = #aptout3;
750aA
750aA     // write record to data file
750aA     exec sql
750aA       insert into aptdata
750aA         values(:APWHSE, :APRTE, :APPGM, :APTYPE,
750aA                :APLBL#, :APTRN#, :APUSER, :APJOB,
750aA                :APJOBN, :APADDTS, :APEXPTS,
750aA                :APEXPFILE, :APEXPDATA);
750aA
750aA     if sqlcod <> 0;
750aA       error = *on;
750aA       $preturn = 'ERRADDREC';
750aA       $pmessage = 'Error on "SQL Insert'
750aA                 + 'APT3" command '
750aA                 + '('
750aA                 + '/'
750aA                 + ')'
750aA                 + '-' + %char(sqlcod);
750aA       leavesr;
750aA     endif;
750aA
750aA   endsr;  // writeapt3
750aA /end-free

750qA*----------------------------------------------------------------
750qA*  writeapt4    Write APT record for format 4
750qA*----------------------------------------------------------------
750qA /free
750qA   begsr writeapt4;
750qA
750aA     $preturn = '*OK';
750qA     $pmessage = ' ';
750qA     clear aptrec;
750qA     apwhse= $apwhse;
750qA     clear aprte;
          aprte = w_aprtid;
750qA     appgm = $pprogram;
750qA     aptype = $psubcmd;
750qA     aplbl# = w_aplbl#;
          aptrn# = $aptrn#;
750qA     apuser = $apuser;
750qA     apjob  = $apjob;
750qA     apjobn = $apjobn;
750qA     apaddts = %timestamp();
750qA     clear apexpts;
750qA     clear apexpfile;
750qA
750qA     apexpdata = #aptout4;
750qA
750qA     // write record to data file
750aA     exec sql
750qA       insert into aptdata
750qA         values(:APWHSE, :APRTE, :APPGM, :APTYPE,
750qA                :APLBL#, :APTRN#, :APUSER, :APJOB,
750qA                :APJOBN, :APADDTS, :APEXPTS,
750qA                :APEXPFILE, :APEXPDATA);
750qA
750qA     if sqlcod <> 0;
750qA       error = *on;
750qA       $preturn = 'ERRADDREC';
750qA       $pmessage = 'Error on "SQL Insert'
750qA                 + 'APT4" command '
750qA                 + '('
750aA                 + '/'
750qA                 + ')'
750qA                 + '-' + %char(sqlcod);
750qA       leavesr;
750qA     endif;
750qA
750qA   endsr;  // writeapt4
750qA /end-free

     *----------------------------------------------------------------
     *  writedtaq    Write data queue record.
     *----------------------------------------------------------------
      /free
        begsr writedtaq;

          clear $qdata;
          $qcmd = '*SEND';
          $qfilename = $aprteid;
          dqdata = $qdata;
          dqlen = %len(%trimr(dqdata));
          sendfile( dqname : dqlib : dqlen : dqdata );

        endsr;  // writedtaq
      /end-free

     *----------------------------------------------------------------
     *  zzaptdept    Determine APT department code
     *----------------------------------------------------------------
      /free
        begsr zzaptdept;

          Exec Sql Select zhdesc into :zonedesc
                     from truckh left join zoneh
                       on thwhse = zhwhse
                      and THZTMP = zhtruk
                    where thwhse = :ps3pswhse
                      and thtruk = :ps3pstruk
                      and zhzone = :ps3psszon;

          if sqlstt = sqlSuccess;
            aptdeptcd = %subst(zonedesc : 29 : 2);
          else;

            Exec sql select ZHDESC into :zonedesc from ZONEH
                      where ZHWHSE = :ps3pswhse
                        and ZHTRUK = :ps3pstruk
                        and ZHZONE = :ps3psszon;

            if SQLSTT = sqlSuccess;
              aptdeptcd = %subst(zonedesc : 29 : 2);
            else;
              aptdeptcd = 'ZZ';
            endif;

          endif;

740aA     if client = presto;
740aA     //aptdeptcd = ps3pscomp;
740aA       select;
740aA         when lbwhdp = 'DRY  ';
740aA           aptdeptcd = 'D ';
740aA         when lbwhdp = 'FRZ  ';
740aA           aptdeptcd = 'F ';
740aA         when lbwhdp = 'CLR  ';
740aA           aptdeptcd = 'C ';
740aA         when lbwhdp = 'COKE ';
740aA           aptdeptcd = 'CK';
740aA         other;
740aA           aptdeptcd = 'ZZ';
740aA       endsl;
740aA     endif;

        endsr;  // zzaptdept
      /end-free

     *----------------------------------------------------------------
     *  zzaptdept2   Determine APT department code if no truck
     *----------------------------------------------------------------
      /free
        begsr zzaptdept2;

650dA   Select;
650dA    when client = frf;
650dA     aptdeptcd = %subst(lb_lbwhdp: 1 : 1);
650dA
740aA    when client = presto;
740aA      select;
740aA        when lb_lbwhdp = 'DRY  ';
740aA          aptdeptcd = 'D ';
740aA        when lb_lbwhdp = 'FRZ  ';
740aA          aptdeptcd = 'F ';
740aA        when lb_lbwhdp = 'CLR  ';
740aA          aptdeptcd = 'C ';
740aA        when lb_lbwhdp = 'COKE ';
740aA          aptdeptcd = 'CK';
740aA        other;
740aA          aptdeptcd = '  ';
740aA      endsl;
650dA    other;
          Exec sql select max(ZHDESC) into :zonedesc from ZONEH
                    where ZHWHSE = :lb_lbwhse
                      and ZHZONE = :lb_lbwhdp;

          if SQLSTT = '00000';
            aptdeptcd = %subst(zonedesc : 29 : 2);
          else;
            aptdeptcd = '  ';
          endif;
650dA   endsl;

        endsr;  // zzaptdept2
      /end-free

     *----------------------------------------------------------------
     *  zzapttemp    Determine APT temp zone code
     *----------------------------------------------------------------
      /free
        begsr zzapttemp;

          apttempcd = ' ';

          select;

            when %subst(psszon:1:3) = 'FRZ'
              or %subst(psszon:1:3) = 'ICE';
                apttempcd = '3';

            when %subst(psszon:1:3) = 'REF'
              or %subst(psszon:1:3) = 'CLR';
                apttempcd = '2';

            other;
              apttempcd = '1';
          endsl;

        endsr;  // zzapttemp
      /end-free

650fA*----------------------------------------------------------------
650fA*  zzfrfconv    Convert pounds for Fox River
650fA*----------------------------------------------------------------
650fAC
650fA /free
650fA    begsr zzfrfconv;
650lM      kywhse = lb_lbwhse;
650lM      kyitem = lb_lbitem;
650fA      exsr getitem;
650fA      if $itcwgt = 'Y'
650fA        and $itswgt > 1;
650fA /end-free
650fA
650fA *  Convert Eaches ordered "pounds" into ordered "quantity".
650fAC                   if        ptpcs > 0
650fA *
650lMC     ptpcs         div       $itswgt       ptpcs
650fAC                   mvr                     wgtrem
650fAC                   if        ptpcs = 0
650fAC                             or wgtrem > 0
650fAC                   eval      ptpcs = ptpcs + 1
650fAC                   endif
650fA *
650fAC                   endif
650fAC                   endif
650fA *
650fAC                   endsr
650fA *
     *----------------------------------------------------------------
     *  zznoslot     Initialize location when no slot for item.
     *----------------------------------------------------------------
      /free
        begsr zznoslot;

          select;

            when lbwhdp = 'DRY  ';
              $aplocation = 'DOPEN';

            when lbwhdp = 'FRZ  ' or lbwhdp = 'ICE  ';
              $aplocation = 'FOPEN';

            when lbwhdp = 'REF  ';
              $aplocation = 'ROPEN';

            when lbwhdp = 'CLR  ';
              $aplocation = 'COPEN';

            when lbwhdp = *blanks;
              $aplocation = 'DOPEN';

            other;
              $aplocation = %subst(lbwhdp:1:1) + 'OPEN';

          endsl;

        endsr;  // zznoslot
      /end-free

     *----------------------------------------------------------------
     *  zzclcdur    Calculate date/time duration.
     *----------------------------------------------------------------
      /free
        begsr zzclcdur;

          callp CalcDur ($clcdur);

        endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------
      /free
        begsr clr$item;

          savever# = $itver#;
          clear $item;
          $itver# = savever#;

        endsr;  // clr$item
      /end-free

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------
      /free
        begsr clr$slot;

          savever# = $slver#;
          clear $slot;
          $slver# = savever#;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzcvtdate   Convert date to proper format.
     *----------------------------------------------------------------
      /free
        begsr zzcvtdate;

          callp CvtDate ($cvtdt);

        endsr;  // zzcvtdate
      /end-free

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------
      /free
        begsr zzzdricop;

          error = *off;

          select;

            when $dricommand = '*SLOT';
              drislot = *on;
              $dridata = $slot;

            when $dricommand = '*ITEM';
              driitem = *on;
              $dridata = $item;

          endsl;

          $driprogram = #pgm;
          $drireturn = *blanks;

          callp(e) DriCop ($dricommand: $drisubcmd: $drisys2upd:
                           $driprogram: $drireturn: $drimessage: $dridata);

          select;

            when %error;
              error = *on;
              $drimessage = 'Error occured on call to '
                          + 'DRICOP'
                          + '/' + %trim($drisubcmd)
                          + ' from ' + #pgm;

            when $drireturn <> '*OK';
              error = *on;

          endsl;

          select;

            when $dricommand = '*SLOT';
              $slot = $dridata;

            when $dricommand = '*ITEM';
              $item = $dridata;

          endsl;

        endsr;  // zzzdricop
      /end-free
