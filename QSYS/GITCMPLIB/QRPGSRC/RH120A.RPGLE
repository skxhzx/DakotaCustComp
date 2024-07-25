      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH120A  Open  routes (One whse) - Display
     *  04 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
223 A*    07/02/97   HNK  2.23
     *      - $BMSG parameter added for OR605 called program.
     *
401 A*    07/11/97   HNK  4.01
     *      - Add Option 9 to view order details.
     *
404 A*    08/18/97   RH   4.04
     *      - Change option 8 view truck details to option 12
     *      - Change option 12 view breakdown to option 8.
     *
405 A*    09/10/97   DAS  4.05
     *      - Added option 4=Delete.
     *
414aA*    04/12/00   MLB  4.14a
     *      - Revised program to check status of route before allowing
     *        options 1,2,4 or 12 to proceed.
     *      - Revised the following routines: ENT02, ENT03, OPTNS2,
     *        SAVOPT, ZZINZ, ZZOPT.
     *      - Added new routine ZZCKST to check route status.
     *      - Added new error msg routine: ZM9907.
     *
414bA*    06/30/00  DAS  4.14b
     *      - Revised display file to use ind 21 with SFLNXTCHG
     *        instead of ind 85 as stated in this program. The
     *        actual indicator used in the program was never changed
     *        from 21 to 85.
     *      - Only had to recompile the program.
     *
416aA*    10/05/01  MLB  4.16a
     *      - Revised program to ensure that the route(s) selected
     *        are available for processing and not locked by the
     *        Import Orders programs.
     *      - Added file RTEHED.
417aA*    09/17/03  RH   4.17a
     *      - ENH: Use F10 to confirm delete not ENTER.
417bA*    10/08/03  RH   4.17b
     *      - Enh:Revised program to call CHKIUSE to set inuse flag
     *        in route header when route is selected for alloc/build,
     *        change truck, delete, or truck detail. Allow only 1 user
     *        to work with a route.
     *      - Revised routine ENT02, ENT03, OPTNS2 and ZZOPT to check
     *        inuse status of route before proceeding.
     *      - Created new message routine ZM9908.
417cA*    12/08/03  MLB  4.17c
     *      - Fix: Revised program to not allow multiple routes to be
     *        set inuse if a route is inuse and error message sent.
510 A*    06/05/06  RMC  5.10
     *      - Enh: Create new subfile (DSPPSF) to display
     *             Shipment number for Packers.
     *             Add logic to determine if Packers is accessing
     *             this program.
510bA*    12/01/06  RH   5.10b
     *      - Enh: Check Truck Builder Job Que option to run
     *        on Job Que.
510cA*    12/04/06  RH   5.10c
     *      - Enh: Add opt 1I=force interactive, 1J=force job que
520aA*    04/28/08  DAS  5.20a  P#00046
     *      - Added option 'CI' to ZZOPT.
520bA*    10/21/09  RBD  5.20b  P#00126
     *      - Converted to ILE.
     *      - Changed name of dspf from RH120AFM to RH120A01.
     *      - Added display of crossdock PO#.
530 A*    12/04/09  RBD  5.30
     *      - Fix:  Was only reading 1st order on route to determine
     *        if a crossdock PO existed, must loop through all orders.
530aA*    05/27/10  RBD  5.30a
     *      - Added *SYSTEM options.
     *      - Revised array OPTLN to add text for opt 14 -
     *        Assign driver.
     *      - Added opt 14 to OPLST array.
     *      - Added call to TR850 - Assign driver to route if
     *        system option 'Using TRAX' equals Y.
     *      - Added EM error message array.
530bA*    09/02/10  RBD  5.30b
     *      - Replaced display of exported date and time with driver.
     *      - Changed name of dspf from RH120A01 to RH120A02.
620aA*    11/22/10  RBD  6.20a
     *      - Don't allow Aloc/Build if route contains Pre-Picked
     *        items where the Pre-Pick route is a status less
     *        than 4 Pick/Printed.
620bA*    07/28/11  RBD  6.20b
     *      - Recompiled, ORDH10 file changed.
     *
640 A*    10/06/11  MLB  6.40
     *      - Enh: Revised program to add new status for Inuse flag
     *        while route is being imported.
     *
640aA*    10/20/11  RBD  6.40a
     *      - Recompiled, TTRTE file changed.
     *
640bA*    04/03/12  JCJ  6.40b
     *      - Don't allow Aloc/Build if zone template has invalid
     *        printers or no printer defined for labels selected to
     *        print.
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
640cA*    04/26/12  JCJ  6.40c
     *      - Fix: Moved loading of key fields in SR Ent03.
     *
640dA*    02/29/12  RBD  6.40d
     *      - Recompiled, TTRTE file changed.
     *
650aA*    03/28/13  DAS  6.50a
     *      - Revised to have CI send *CLEARCI to CHKIUSE.
     *
650bA*    04/09/13  DAS  6.50b
     *      - Expanded *INUSE1 commands.
     *      - Requires corresponding change in CHKIUSE program.
     *      - Revised to call CHKIUSE with *GETIUSE to get status
     *        when RHSHPD <> 0.
     *
650c *    06/10/13  GJA  6.50c
     *      - Changed name of dspf from RH120A02 to RH120A03.
     *
650d *    11/29/13  DAS  6.50d
     *      - For CI, revised to move $puky into dsukey instead of $luky
     *
650e *    12/23/13  DAS  6.50e
     *      - Revised to use CHKIUSE2.
     *      - No longer uses rhshpd for inuse flag.
     *      - Requires new CHKIUSE2 progam and new RTEINUSE file.
700  *    09/24/15  NLK  7.00 (was 700b, dup)
     *      - Don't allow Aloc/Build if Merge or Tote
     *        Zone doesn't have a value
     *      - FIX AMPxRef8 w/ AMP not matching LOC
     *        removed part of JOIN -- no pgm chg here(only comments)
700aA*    08/19/15  NLK  7.00a
     *      - Don't allow Aloc/Build if ord# contains AMP
     *        items where the AMP ord# is a status less
     *        than 5 Closed.
700bA*    07/11/16  NLK  7.00b
     *      - Added Call to Print report if AMP item qty
     *        already picked is higher than Delv Rt qty
700cA*    09/23/16  NLK  7.00c
     *      - FIX: Only seton CallBX300 if DelvRt of an AMP
700dA*    11/29/16  NLK  7.00d
     *      - ENH: Don't allow on DelvRt of an AMP to have
     *        one customer to have two different STOP#s.
     *        An Error occured when 1 box had stop# 8 and 20
     *        and the result was a mess.
     *      - Redesign BX305, removed parm AMP rtid 12.05
     *
750aA*    03/02/21  DAS  7.50a
     *      - Revised to create RTEHEDEXA record if it doesn't exist
     *        or to update TBType if blank.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar Foods
     *
ASCaA*    04/17/12  RTR  ASCa
     *      - Changed to display trailer number in Crossdock PO field
     *
ASCbA*    10/25/12  RTR  ASCb
     *      - Changed to handle 8 character truck in Crossdock PO field
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Reinhart Food Service
     *
RFSaA*    02/20/13  RTR  RFSa
     *      - Changed to use 8 characters of truck in Crossdock PO field
RFSb *    06/20/13  GJA  RFSb
     *      - Enh:  Change Crossdock column to trailer.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    12/08/13  MLB  CSP
     *      - Revised pgm to chain to ORDHM2 to retrieve Driver Name and
     *        load into subfile.
CSPaA*    10/30/17  MLB  CSPa
     *      - Revised to NOT allow option '4' Delete.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jack Palmer Foodservice
     *
JPFaA*    02/10/09  RH   JPFa
     *      - Revised to NOT allow option '4' Delete.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program has been revised to work with option '1'
     *    selections similar to how it works with option '4' selections.
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
414aA*    * Important * Make sure that any new options added to this pro-
414aA*                  gram that allow changes to the route in any way
414aA*                  are preceeded with a call to subroutine ZZCKST
414aA*                  to verify that the route is still at 'open'
414aA*                  status.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
510  *  70        Chain Indicator (ORDHM2)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
414bD** 85        Manually set subfile change flag (SFLNXTCHG)
414bM*  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
520bDF*rh120afm  cf   e             workstn
530bDF*rh120a01  cf   e             workstn
650cDF*rh120a02  cf   e             workstn
650cMFrh120a03  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
222 D*                                       RECNO2KSFILE VW2SFL
222 D*                                       RECNO3KSFILE VW3SFL
     F                                     sfile(dsppsf:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
416aAFrtehed    uf   e           k disk
     Frtehed2   if   e           k disk
     F                                     rename(rhrec:record)
     Frtesum    if   e           k disk
510b Foptions   if   e           k disk
510  Fordhm2    if   e           k disk
520bAFcrossdk1  if   e           k disk
620aAFordh4     if   e           k disk    rename(ohrec:ohrec4)
620aAFordh10    if   e           k disk    prefix(oh_)
700aAFordhm4    if   e           k disk    prefix(hm_)
700aAFordhm5    if   e           k disk    prefix(ho_)
700 AFampxref8  if   e           k disk
520bAFordh3     if   e           k disk
530bAFttrte     if   e           k disk
640bAFoptionz   if   e           k disk
640bAFoptionz3  if   e           k disk    rename(opzrec:opz3) prefix(x)
640bAFtruckh    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
401 MD optln           s             75    dim(2) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
VW2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
640 DD*stat            s             10    dim(7) ctdata perrcd(1)
640 MD stat            s             10    dim(8) ctdata perrcd(1)
417bD*                   STAT    1   6 10
620aDD*em              s             50    dim(1) ctdata perrcd(1)
700aDD*em              s             50    dim(2) ctdata perrcd(1)
700dDD*em              s             50    dim(3) ctdata perrcd(1)
700dDD*em              s             50    dim(4) ctdata perrcd(1)
700 MD em              s             50    dim(5) ctdata perrcd(1)
510  *----------------------------------------------------------------
510  *  Customer id
510  *
510   /COPY QCOPYSRC,ID#PACKERS
JPFaA /COPY QCOPYSRC,ID#Palmer
ASCaA /COPY QCOPYSRC,ID#AGAR
RFSaA /COPY QCOPYSRC,ID#RFS
CSP A /COPY QCOPYSRC,ID#COASTAL
     D @getcl          c                   const('GETCLIENT')
CSPaAD @autpg          c                   const('CHKLIST')
640bA*----------------------------------------------------------------
640bA*  *PICKLBA -  Label printing options for the standard pick,
640bA*              retail, and tote labels.
640bA*
640bA*     08/12/09  RBD  5.20  P#00219
640bA*       - Added record type *PICKLBA which holds printing info
640bA*         for the standard pick, retail, and tote labels.
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
     * Data structure
     *
     D opdta3          ds
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
640bA*----------------------------------------------------------------
640bA*  *PICKLBB -  Label printing options for the pick list and
640bA*               ASN labels and pick list report.
640bA*
640bA*     08/12/09  RBD  5.20  P#00219
640bA*       - Added record type *PICKLBB which holds printing info
640bA*         for the pick list and ASN labels and pick list report.
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
     *
     *    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
     *
     * Data structure
     *
     D opdta4          ds
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
     D  oplb7                 97     97
     D  opend4               117    117
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kstat                 4      4
     D  $ktype                 5      5
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  rhwhse                 1      3  0 inz(0)
     D  rhrte                  4      8
     D  rhrtid                 9     13
     D  rhtruk                14     23
     D  rhstat                24     24
     D  rhtype                25     25
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('RH122')
405 D*             '*NONE'               C         @DELPG
     D @delpg          c                   const('RH124')
     D @prtpg          c                   const('NONE')
640bAD @chkpg          c                   const('ZH125')
     *----------------------------------------------------------------
     *  Constants
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
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
     D  $ltruk                22     31
     D  $ltrk2                32     41
640bA*
640bAD  $llb                  22     22
640bAD  $lcu                  23     23
640bAD  $llp                  24     33
640bAD  $ldv                  34     43
640bAD  $lfm                  44     53
640bAD  $llbltype             54     54
640bA*
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Variables
     *
530aAD $awhse          s              3
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
700bAD $xwhse          s              3  0
700bAD $xordLO         s              7  0
700bAD $xordHI         s              7  0
700dAD $xcord          s              7  0
700dAD $xacord         s              7
700dAD $xrtid          s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
700bAD callBX300       s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
750aDD*enter           s              5  0
750aDD*error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D kycode          s                   like(opcode)
     D kyrte           s                   like(rhrte)
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(rhstat)
     D kytype          s                   like(rhtype)
     D kywhse          s                   like(rhwhse)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
750aAD pmessage        s             80
     D posrec          s              4  0
     D p1              s              1  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D stserr          s              1
750aAd tbWhse          s              3  0
     D top             s              1
     D v               s              2  0
     D view            s              1  0
750aDD*warn            s              1
750aDD*x               s              3  0
750aDD*y               s              3  0
640bAD $ptmpl          s             10
640bAD kycod3          s                   like(opzcod)
640bAD kycod4          s                   like(opzcod)

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

750aA /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Other data structures
     *
CSP A /COPY QCOPYSRC,ORDHM1_CSP
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
510  *  Shipment number from Miscellaneous field
510  D                 ds
510  D  hmmsc1                 1     40
510  D  hmmshp                 4     14
ASCaA*  Trailer number from Miscellaneous field
ASCaAD                 ds
ASCaAD  hmmsc4                 1     40
ASCaAD  hmmtrlr               20     29
640 A*
750aDD**               ds
650eDD**rhiuse                 8      8  0
650eDD**rhshpd                 1      8  0
640 A*
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
414aA*
414aAD  eropt                  1     20
414aAD  erstat                21     40
414aAD  ertype                41     50
     D                 ds
     D  $ec                    1      2p 0
510bA*----------------------------------------------------------------
510bA*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
410 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPICW   -  Individual catch weight entry (Y,N).
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
413aA*    OPRCDY  -  Number of days to keep receiving logs.
413aA*    OPMPCK  -  Number of days to keep picking logs.
414bA*    OPRTHS  -  Number of weeks - exported routes to keep.
414bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
414bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
414bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
414bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
510c *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
530aA*    OPISHS  -  Number of weeks to keep history file
530aA*    OPUCI   -  Use UCI processing (Y,N)
530aA*    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
530aA*    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
530aA*    OPTRAX  -  Using TRAX module (Y,N).
     *
     * Data structure
     *
510b D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
412 AD  opmpck                14     14
413aAD  oprcdy                15     15  0
413aAD  oppkdy                16     16  0
414bAD  oprths                17     19  0
414bAD  opcrhs                20     22  0
414bAD  oppohs                23     25  0
414bAD  opiahs                26     28  0
414bAD  opmshs                29     31  0
510cAD  optbjq                32     32
530aAD  opishs                33     35  0
530aAD  opuci                 36     36
530aAD  opwrncr               37     37
530aAD  opicwr                38     38
530aAD  optrax                39     39
     D  optend               117    117
CSPaA* Error message(s)
CSPaAD err01           c                   const('You are not authorized -
CSPaAD                                     to use this option.')
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

750aA /copy qcopysrc,p.exrtehed
750aA /copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *
     *  Define keys
     *
700 A*
700 A*     STAGEAMP (Partial Slot Disply)
700 A*
700 AC     keyAMPzn      klist
700 AC                   kfld                    ohwhse
700 AC                   kfld                    ohcust
700 AC                   kfld                    ohcord
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
OP1 AC     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
OP1 AC                   if        nxtscr = '03 '
OP1 AC                   exsr      deldsp
OP1 AC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   read      dsppfc                                 50
510  C                   else
     C                   read      dspsfc                                 50
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   read      vw2sfc                                 50
VW2 AC                   when      view = 3
VW2 AC                   read      vw3sfc                                 50
VW2 AC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  Screen 03 initialization
OP1 A*
OP1 AC     scr03i        begsr
OP1 AC                   eval      nxtscr = '03 '
OP1 AC                   eval      *in90 = *on
OP1 AC                   move      *loval        $wkof
OP1 AC                   move      *loval        $wkou
OP1 AC                   write     clr0306
OP1 AC                   write     op1rec
OP1 AC                   eval      pagcmd = '*REFRESH'
OP1 AC                   exsr      pag03
OP1 AC                   write     cmdop1
OP1 AC                   endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  Screen 03 wrap-up
OP1 A*
OP1 AC     scr03e        begsr
OP1 AC                   eval      nxtscr = '01 '
OP1 AC                   eval      *in90 = *off
OP1 AC                   write     clr0306
OP1 A*
OP1 A*   If option 1 was not canceled (no errors)
OP1 A*     then reposition to record just before first deleted rec.
OP1 A*
OP1 AC                   if        cancel = *off
OP1 AC                   eval      $pocmd = '*POSTN2 '
OP1 AC                   eval      $pofky = frstky
OP1 AC                   exsr      fgtway
OP1 AC                   eval      $pocmd = '*GETPREV'
OP1 AC                   exsr      fgtway
OP1 AC                   if        $portn = '*NOMORE '
OP1 AC                   eval      $pocmd = '*TOP    '
OP1 AC                   else
OP1 A*
OP1 A*   Otherwise, position to last record read.
OP1 A*
OP1 AC                   eval      $pocmd = '*POSTN2 '
OP1 AC                   endif
OP1 AC                   exsr      fgtway
OP1 AC                   eval      pagcmd = '*REPOS  '
OP1 AC                   exsr      pag01
OP1 AC                   exsr      optns
OP1 AC                   else
OP1 AC                   eval      $pocmd = '*POSTN2U'
OP1 AC                   eval      $pouky = $puky
OP1 AC                   exsr      fgtway
OP1 AC                   eval      pagcmd = '*REPOS  '
OP1 AC                   exsr      pag01
OP1 AC                   endif
OP1 AC                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
417aD**                   CAS            ENT02
     C                   endcs
     C     endsc2        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  SC3  -  Screen 3
OP1 A*
OP1 AC     sc3           begsr
OP1 AC     status        caseq     rollup        roll03
OP1 AC     status        caseq     rolldn        roll03
OP1 AC     status        caseq     comand        cmd03
OP1 AC                   cas                     ent03
OP1 AC                   endcs
OP1 AC     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
750aDC**                 eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
RFSaA*
RFSaAC                   if        client = agar
RFSaAC                             or client = rfs
RFSbAC                   eval      *in22 = *on
RFSbAC                   endif
510 A*
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
510  C                   if        client = packer
510  C                   write     dsppsf                               79
510  C                   else
     C                   write     dspsfl                               79
510  C                   endif
222 D*                    Z-ADD1         RECNO2
VW2 AC                   write     vw2sfl                               79
222 D*                    Z-ADD1         RECNO3
VW2 AC                   write     vw3sfl                               79
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr

750aA*----------------------------------------------------------------
750aA*  ChkTBType   Check to make TruckBuilder type exists
750aA*----------------------------------------------------------------
750aA
750aA /free
750aA  begsr ChkTBType;

         // Get RTEHEDEX info. Get out if call error.

         monitor;
           exWhse = rhWhse;
           EXRTEHED('*GET': exRtnCode: exRtnMsg:
                    exWhse: rhRtid: rhatbtype);
         on-error;
           leavesr;
         endmon;

         // Get out if TBType defined

         if rhatbtype <> '';
           leavesr;
         endif;

         // Get default TB type

         monitor;
           tbWhse = rhWhse;
           GetTBType(tbWhse: rhRtid: rhatbtype);
           if rhatbtype = 'B' or %subst(rhrte:1:3)='#SR';
             rhaTbtype = 'E';
           endif;
         on-error;
           leavesr;
         endmon;

         // Update/Add TB Type

         monitor;
           if exRtnCode <> '*ERROR';
             EXRTEHED('*CHANGE': exRtnCode: exRtnMsg:
                      exWhse: rhRtid: rhatbtype);
           else;
             EXRTEHED('*ADD': exRtnCode: exRtnMsg:
                      exWhse: rhRtid: rhatbtype);
           endif;
         on-error;
           error = *on;
           pMessage = 'Error updating TB Processing Type (GetTBType)';
           leavesr;
         endmon;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
510  C                   if        client = packer
510  C     x             chain     dsppsf                             79
510  C                   else
     C     x             chain     dspsfl                             79
510  C                   endif
222 D*R         X         CHAINVW2SFL               79
222 D*R         X         CHAINVW3SFL               79
     C                   if        not *in79
     C                   eval      option = '  '
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
222 D*R                   UPDATVW2SFL
222 D*R                   UPDATVW3SFL
     C                   endif
222 AC     x             chain     vw2sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw2sfl
222 AC                   endif
222 AC     x             chain     vw3sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw3sfl
222 AC                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
VW2 D*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
VW2 M*  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
VW2 D*R         *INKJ     IFEQ '1'
VW2 MC                   if        *inku
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
VW2 A*
VW2 A*  TEST FOR CMD10 - Previous view
VW2 A*
VW2 AC                   if        *inkj
VW2 AC                   if        view = 1
VW2 AC                   eval      view = maxvw
VW2 AC                   else
VW2 AC                   eval      view = view - 1
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
VW2 A*
VW2 A*  TEST FOR CMD11 - Next view
VW2 A*
VW2 AC                   if        *inkk
VW2 AC                   if        view = maxvw
VW2 AC                   eval      view = 1
VW2 AC                   else
VW2 AC                   add       1             view
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
417a *  TEST FOR CMD10 - Confirm Delete
417a *
417a C                   if        *inkj
417a C                   exsr      ent02
417a C                   goto      cmd02e
417a C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  CMD03    Screen 3 command key routine
OP1 A*
OP1 AC     cmd03         begsr
OP1 A*
OP1 A*  TEST FOR CMD12 - PREVIOUS
OP1 A*
OP1 AC                   if        *inkl
OP1 AC                   eval      cancel = *on
OP1 AC                   exsr      scr03e
OP1 AC                   goto      cmd03e
OP1 AC                   endif
OP1 AC     cmd03e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
222 D*R                   ADD  1         RECNO2
222 D*R                   ADD  1         RECNO3
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
510  C                   if        client = packer
510  C                   write     dsppsf
510  C                   else
     C                   write     dspsfl
510  C                   endif
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = 1
222 A*R                   Z-ADD1         RECNO2
222 A*R                   Z-ADD1         RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
414aAC                   eval      *in21 = *off
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
414aA*
414aA*    Verify that route is still at "open" status.
414aA*
414aAC                   eval      dsukey = $puky
414aAC                   exsr      zzckst
414aAC                   if        stserr = *on
414aAC                   delete    wkorec
414aAC                   iter
414aAC                   endif
414aA*
417bA*    Check Inuse flag. If Inuse, then cancel delete.
417bA*
650bDC**                 eval      $icmd = '*INUSE1 '
650bMC                   eval      $icmd = '*INUSE11'
417bAC                   exsr      zziuse
417bAC                   if        stserr = *on
417bAC                   delete    wkorec
417bAC                   iter
417bAC                   endif
417bA*
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
417bA*    Reset Inuse flag.
417bA*
417bAC                   eval      $icmd = '*CLEAR  '
417bAC                   exsr      zziuse
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
414aA*
414aA*    If ERROR flag is on due to one or more routes no
414aA*    longer at 'open' status, set on CANCEL.
414aA*
414aAC                   if        error = *on
414aAC                   eval      cancel = error
414aAC                   endif
     C                   exsr      scr02e
     C     ent02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  ENT03    Screen 3 enter key routine
OP1 A*
OP1 AC     ent03         begsr
OP1 A*
OP1 A*  Save first option 1 key.
OP1 A*
OP1 AC                   eval      frstky = $puky
OP1 A*
OP1 A*  Perform option 1 on the records that have been selected
OP1 A*
OP1 AC     wkoprt        setll     workopt
OP1 AC                   eval      stop = *off
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        reade     workopt                                79
414aAC                   eval      *in21 = *off
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   else
640cA*
640cA*  Call option 1 program
640cA*
640cAC                   eval      $bprg = #prog
640cAC                   eval      $puky = wkokyu
640cAC                   eval      dsukey = $puky
OP1 A*
OP1 AC                   if        wkoopt = ' 1'  or
510cAC                             wkoopt = '1I'  or
510cAC                             wkoopt = '1J'
640cD*
640cD*  Call option 1 program
640cD*
640cD ***                eval      $bprg = #prog
640cD ***                eval      $puky = wkokyu
640cD ***                eval      dsukey = $puky
414aA*
414aA*    Verify that route is still at "open" status.
414aA*
414aAC                   exsr      zzckst
414aAC                   if        stserr = *on
414aAC                   delete    wkorec
414aAC                   iter
414aAC                   endif
     *
620aA*   Do not allow Aloc/Build if route contains Pre-Picked items
620aA*   where the Pre-Pick route is a status less than 4 Pick/Printed.
620aA
620aAC     keyordh4      setll     ordh4
620aAC                   dow       forevr = forevr
620aA
620aAC     keyordh4      reade     ordh4
620aAC                   if        %eof
620aAC                             or %subst(ohmisc:17:1) = 'Y'
620aAC                   leave
620aAC                   endif
620aA
620aAC     keyordh10     setll     ordh10
620aAC                   dow       forevr = forevr
620aA
620aAC     keyordh10     reade     ordh10
620aAC                   if        %eof
620aAC                   leave
620aAC                   endif
620aA
620aAC                   if        %subst(oh_ohmisc:17:1) <> 'Y'
620aAC                   iter
620aAC                   endif
620aA
620aAC                   if        rhrte = oh_rhrte
620aAC                             and oh_rhstat < '4'
620aAC                   eval      error  = *on
620aAC                   eval      *in21  = *on
620aAC                   eval      errmsg = rhrte
620aAC                                +  '/'
620aAC                                + rhrtid
620aAC                                + ' '
620aAC                                +  em(2)
620aAC                   exsr      zm0105
620aAC                   update    wkorec
620aAC                   leave
620aAC                   endif
620aA
620aAC                   enddo
620aA
620aAC                   if        error = *on
620aAC                   leave
620aAC                   endif
620aA
620aAC                   enddo
620aA
620aAC                   if        error = *on
620aAC                   iter
620aAC                   endif
700aA*   Do not allow Aloc/Build if route contains AMP items
700aA*   where the AMP order is a status less than equal to 4 Closed.
700aA*   1st check if current rte is an AMP or was previosly
700aA*       check if current order is related to a prev AMP (same cust order)
700bAC                   eval      callBX300 = *off
700aAC     keyordh4      setll     ordhm5
700aAC                   dow       forevr = forevr
700aA * if AMP no need to check
700aAC     keyordh4      reade     ordhm5
700aAC                   if        %eof
700aAC                             or %subst(ho_hmmsc4:13:1) = 'Y'
700aAC                   leave
700aAC                   endif
700aA
700aAC     keyordh10o    setll     ordhm4
700aAC                   dow       forevr = forevr
700aA
700aAC     keyordh10o    reade     ordhm4
700aAC                   if        %eof
700aAC                   leave
700aAC                   endif
700aA * if not Delv Rt w/ AMP CORD then no need to check
700aAC                   if        %subst(hm_hmmsc4:13:1) <> 'Y'
700aAC                   iter
700aAC                   endif
700aA
700dAC                   eval      $xrtid = hm_hmrtid
700dA
700cAC                   eval      callBX300 = *on
700aA
700aAC                   if        hm_rhstat < '5'
700dAC                   eval      callBX300 = *off
700aAC                   eval      error  = *on
700aAC                   eval      *in21  = *on
700aAC                   eval      errmsg = rhrte
700aAC                                +  '/'
700aAC                                + rhrtid
700aAC                                + ' '
700aAC                                +  em(3)
700aAC                   exsr      zm0105
700aAC                   update    wkorec
700aAC                   leave
700aAC                   endif
700aA
700bA*
700bA* At this point, hang onto ord#s to check (use ho_ fields/delv-rt)
700bA* if Delv Rt CORD has lower qty then AMP qty per CORD
700bA*                            sending Delv Rt ord info & check all
700bAC                   if        $xordLO = 0
700bAC                   eval      $xwhse = ho_ohwhse
700bAC                   eval      $xordLO = ho_ohord
700bAC                   else
700bAC                   if        ho_ohord < $xordLO
700bAC                   eval      $xordLO = ho_ohord
700bAC                   endif
700bAC                   endif

700bAC                   if        $xordHI = 0
700bAC                   eval      $xordHI = ho_ohord
700bAC                   else
700bAC                   if        ho_ohord > $xordHI
700bAC                   eval      $xordHI = ho_ohord
700bAC                   endif
700bAC                   endif
700aA
700aAC                   enddo
700bAC
700cD *                  eval      callBX300 = *on
700aAC                   enddo
700bAC
700 A*  skip Alloc if AMP order has no Zone specified
700 A*       join AMPxRef/StageAMP w/ CORD + Aisle
700 A*       Typ D is generic AMP w/no LOC-it is accumulated
700 A*       Typ A has LOC defined so can't JOIN on Aisle+Loc
700 A*    revisit if StageArea can be a normal AISLE, if so,
700 A*        this may give off a false security of valid ZONE
700 AC     keyAMPzn      setll     ampxref8
700 AC                   dow       forevr = forevr
700 A
700 AC     keyAMPzn      reade     ampxref8
700 AC                   if        %eof
700 AC                   leave
700 AC                   endif
700 A
700 AC                   if        ohcord = hm_ohcord
700 AC                             and ohcust = hm_ohcust
700 AC                             and sazonem = ' '
700 AC                             and sazonet = ' '
700 AC                   eval      error  = *on
700 AC                   eval      *in21  = *on
700 AC                   eval      errmsg = rhrte
700 AC                                +  '/'
700 AC                                + rhrtid
700 AC                                + ' '
700 AC                                +  em(5)
700 AC                   exsr      zm0105
700 AC                   update    wkorec
700 AC                   leave
700 AC                   endif
700 A
700 AC                   enddo
700 A

     *    callBX300 means this is a DelvRt with an AMP

700bAC                   if        callBX300 = *on
700dA*
700dA* DelvRt of an AMP now needs to make sure Box#s have 1 STOP#.
700dA*  Check this rtid's ampxref details / call once per route.
700dA*  RTE name used to check Delv Rt Stop#s.(rtid-AMP/rte-Delv)
700dAC                   eval      $xcord = 0
700dAC                   call      'BX305'
700dAC                   parm                    $xwhse
700dAC                   parm                    rhrtid
700dAC                   parm                    $xcord

700dAC                   if        $xcord > 0
700dAC                   eval      error  = *on
700dAC                   eval      *in21  = *on
700dAC                   eval      errmsg = rhrtid
700dAC                                +  '/'
700dAC                                + %editc($xcord:'X')
700dAC                                + ' '
700dAC                                +  em(4)
700dAC                   exsr      zm0105
700dAC                   update    wkorec
700dAC                   endif

     *    call after reading all ord#s, print report if qty diff

700bAC                   call      'BX300'
700bAC                   parm                    $xwhse
700bAC                   parm                    $xordLO
700bAC                   parm                    $xordHI
700bAC                   parm                    rhrte
700aAC                   endif
700aA
700aAC                   if        error = *on
700aAC                   iter
700aAC                   endif
700aA
640bA*
640bA*   Do not allow Aloc/Build if the zone template has any printers
640bA*   that are not valid or not entered.                           .
640bA*
640bA* Get Zone Template Code if Template type is T=Truck
640bA*
640bAC     trkey         chain     truckh
640bAC                   if        %found(truckh) and thtype = 'T'
640bAC                   eval      $ptmpl =  thztmp
640bAC                   else
640bAC                   eval      $ptmpl =  rhtruk
640bAC                   endif
     * Pick/Retail/Tote
640bAC                   eval      opdta3 = *blanks
640bAC                   eval      kycod3 = '*PICKLBA'
640bAC     opzkya        setll     optionz
640bAC                   dou       %eof(optionz)
640bAC     opzkya        reade     optionz
640bAC                   if        not %eof(optionz)
640bAC                   eval      opdta3 = opzdta
     * Pick Label Device
640bAC                   if        oplb1 = 'Y'
640bAC                   eval      $llp = oplp1
640bAC                   eval      $ldv = opdv1
640bAC                   eval      $llbltype = '1'
640bAC                   call      @chkpg
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      error = *on
640bAC                   eval      *in21  = *on
640bAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640bAC                                                   + ' '
640bAC                                                   + $ptmpl
640bAC                   exsr      zm0105
640bAC                   update    wkorec
640bAC                   leave
640bAC                   endif
640bAC                   endif
     * Retail Label Device
640bAC                   if        oplb2 = 'Y'
640bAC                   eval      $llp = oplp2
640bAC                   eval      $ldv = opdv2
640bAC                   eval      $llbltype = '2'
640bAC                   call      @chkpg
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      error = *on
640bAC                   eval      *in21  = *on
640bAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640bAC                                                   + ' '
640bAC                                                   + $ptmpl
640bAC                   exsr      zm0105
640bAC                   update    wkorec
640bAC                   leave
640bAC                   endif
640bAC                   endif
     * Tote Label Device
640bAC                   if        oplb3 = 'Y'
640bAC                   eval      $llp = oplp3
640bAC                   eval      $ldv = opdv3
640bAC                   eval      $llbltype = '3'
640bAC                   call      @chkpg
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      error = *on
640bAC                   eval      error = *on
640bAC                   eval      *in21  = *on
640bAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640bAC                                                   + ' '
640bAC                                                   + $ptmpl
640bAC                   exsr      zm0105
640bAC                   update    wkorec
640bAC                   leave
640bAC                   endif
640bAC                   endif
640bAC                   endif
640bAC                   enddo
     * ASN/Pick List Label & Report
640bAC                   if        error <> *on
640bAC                   eval      kycod4 = '*PICKLBB'
640bAC                   eval      opdta4 = *blanks
640bAC     opzkyb        setll     optionz
640bAC                   dou       %eof(optionz)
640bAC     opzkyb        reade     optionz
640bAC                   if        not %eof(optionz)
640bAC                   eval      opdta4 = opzdta
     * ASN Label Device
640bAC                   if        oplb4 = 'Y'
640bAC                   eval      $llp = oplp4
640bAC                   eval      $ldv = opdv4
640bAC                   eval      $llbltype = '4'
640bAC                   call      @chkpg
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      error = *on
640bAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640bAC                                                   + ' '
640bAC                                                   + $ptmpl
640bAC                   leave
640bAC                   endif
640bAC                   endif
     * Pick List Label Device
640bAC                   if        oplb5 = 'Y'
640bAC                   eval      $llp = oplp5
640bAC                   eval      $ldv = opdv5
640bAC                   eval      $llbltype = '5'
640bAC                   call      @chkpg
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      error = *on
640bAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640bAC                                                   + ' '
640bAC                                                   + $ptmpl
640bAC                   leave
640bAC                   endif
640bAC                   endif
     * Pick List Report Device
640bAC                   if        oplb6 = 'Y'
640bAC                   eval      $llp = oplp6
640bAC                   eval      $ldv = opdv6
640bAC                   eval      $llbltype = '6'
640bAC                   call      @chkpg
640bAC                   parm                    $lparm
640bAC                   if        $lrtn = '*ERROR  '
640bAC                   eval      error = *on
640bAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640bAC                                                   + ' '
640bAC                                                   + $ptmpl
640bAC                   leave
640bAC                   endif
640bAC                   endif
640bAC                   endif
640bAC                   enddo
640bAC                   endif
640bA
640bAC                   if        error = *on
640bAC                   iter
640bAC                   endif
750aA
750aA /free
750aA    // Make sure TruckBuilder Processing Type is defined
750aA
750aA    exsr chkTBType;
750aA    if error;
750aA      iter;
750aA    endif;
750aA /end-free
750aA
416 A*
416 A*    Set Inuse flag for alloc/build processing.
416 A*
416 AC                   eval      $icmd = '*INUSE1 '
416 AC                   exsr      zziuse
416 AC                   if        stserr = *on
416 AC                   delete    wkorec
416 AC                   iter
416 AC                   endif
414aA*
510bAC                   if        optbjq = 'Y'  and
510cAC                             wkoopt <> '1I'  or
510cAC                             wkoopt = '1J'
510bAC                   call      'OR605CL'
510bAC                   parm      '*PICK   '    $bcmd             8
510bAC                   parm      '*ALOCBLD'    $bcmd2            8
510bAC                   parm      '*PICK1  '    $btype            8
510bAC                   parm      '0'           $bjtyp            1
510bAC                   parm      rhwhse        $bwhs            15 5
510bAC                   parm      0             $bbat             7 0
510bAC                   parm      ' '           $bstat            1
510bAC                   parm      rhrtid        $brtid            5
510bAC                   parm      0             $bord             7 0
510bAC                   parm      0             $brwhs            3 0
510bAC                   parm      ' '           $btrte            5
510bAC                   parm      ' '           $brtn             8
510bAC                   parm      ' '           $bmsg             4
510bAC                   parm                    $bprg            10
510bA*
510bA*    Force route to have Ok return code.
510bAC                   eval      $brtn = '*OK     '
510bAC                   else
OP1 AC                   call      'OR605'
OP1 AC                   parm      '*PICK   '    $bcmd
OP1 AC                   parm      '*ALOCBLD'    $bcmd2
OP1 AC                   parm      '*PICK1  '    $btype
OP1 AC                   parm      '1'           $bjtyp
OP1 AC                   parm      rhwhse        $bwhs
OP1 AC                   parm      0             $bbat
OP1 AC                   parm      ' '           $bstat
OP1 AC                   parm      rhrtid        $brtid
OP1 AC                   parm      0             $bord
OP1 AC                   parm      0             $brwhs
OP1 AC                   parm      ' '           $btrte
OP1 AC                   parm      ' '           $brtn
223 AC                   parm      ' '           $bmsg
223 AC                   parm                    $bprg
510bAC                   endif
OP1 A*
OP1 A*     Error occured - Error message sent to program msgq
OP1 A*
223 MC                   if        $brtn = '*PGMQ   '
223 D***        $PRTN     IFEQ '*PGMQ   '
OP1 AC                   eval      error = *on
OP1 AC                   eval      cancel = *on
OP1 AC                   eval      stop = *on
223 MC                   eval      #msgk = $bmsg
223 D***                  MOVE $PMSG     #MSGK
OP1 AC                   exsr      zmqmsg
OP1 AC                   else
OP1 A*
OP1 A*     Option 1 was successful.
OP1 A*
223 MC                   if        $brtn = '*OK     '
510bAC                   if        optbjq <> 'Y'  and
510cAC                             wkoopt <> '1J'  or
510cAC                             wkoopt = '1I'
223 D***        $PRTN     IFEQ '*OK     '
223 MC                   eval      #msgk = $bmsg
223 D***                  MOVE $PMSG     #MSGK
OP1 AC                   exsr      zmqmsg
OP1 AC                   endif
510cAC                   endif
OP1 AC                   endif
OP1 AC                   if        cancel = '0'
OP1 AC                   delete    wkorec
OP1 AC                   else
OP1 AC                   eval      wkoerr = *on
OP1 AC                   update    wkorec
OP1 AC                   endif
OP1 AC                   endif
417bA*    Reset Inuse flag.
417bA*
510bA*    For Interactive only.
510bAC                   if        optbjq = 'N'  and
510cAC                             wkoopt <> '1J'  or
510cAC                             wkoopt = '1I'
417bAC                   eval      $icmd = '*CLEAR  '
417bAC                   exsr      zziuse
510bAC                   endif
OP1 A*
OP1 AC                   endif
OP1 AC                   enddo
414aA*
414aA*    If ERROR flag is on due to one or more routes no
414aA*    longer at 'open' status, set on CANCEL.
414aA*
414aAC                   if        error = *on
414aAC                   eval      cancel = error
414aAC                   endif
OP1 AC                   exsr      scr03e
OP1 AC     ent03e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
OP1 A*
OP1 A*     Do all option 1's together.
OP1 A*
OP1 AC     wkoprt        setll     workopt
OP1 AC                   eval      stop = *off
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   dow       not *in79  and
OP1 AC                             wkoopt <> ' 1'  and
510cAC                             wkoopt <> '1I'  and
510cAC                             wkoopt <> '1J'
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   enddo
OP1 AC                   if        not *in79
510cD***        WKOOPT    ANDEQ' 1'
510cMC                   if        wkoopt = ' 1'  or
510cAC                             wkoopt = '1I'  or
510cAC                             wkoopt = '1J'
OP1 AC                   eval      otaken = *on
OP1 AC                   eval      $puky = wkokyu
OP1 AC                   exsr      scr03i
OP1 AC                   goto      optnse
510cAC                   endif
OP1 AC                   endif
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
414aA*
414aA*    Verify that route is still at "open" status.
414aA*
414aAC                   eval      *in21 = *off
414aAC                   eval      dsukey = $puky
414aAC                   exsr      zzckst
414aAC                   if        stserr = *on
414aAC                   goto      opts2e
414aAC                   endif
414aA*
417bA*    Check Inuse flag. If Inuse, then cancel Change.
417bA*
650bDC**                 eval      $icmd = '*INUSE1 '
650bMC                   eval      $icmd = '*INUSE12'
417bAC                   exsr      zziuse
417bAC                   if        stserr = *on
417bAC                   goto      opts2e
417bAC                   endif
417bA*
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
417bA*    Reset Inuse flag.
417bA*
417bAC                   eval      $icmd = '*CLEAR  '
417bAC                   exsr      zziuse
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     C                   else
     *
530aA*   Assign driver to route
530aA*
530aAC                   if        wkoopt = '14'
530aAC                   if        optrax <> 'Y'
530aAC                   eval      error  = '1'
530aAC                   eval      wkoerr = '1'
530aAC                   update    wkorec
530aAC                   eval      otaken = '0'
530aAC                   eval      errmsg = em(1)
530aAC                   exsr      zm0105
530aAC                   goto      endop2
530aAC                   endif
530aAC                   eval      $awhse = %char($kwhse)
530aAC                   eval      $puky = wkokyu
530aAC                   eval      dsukey = $puky
530aAC                   call      'TR850'
530aAC                   parm                    $pprg
530aAC                   parm                    $awhse
530aAC                   parm                    rhrtid
530aAC                   parm      ' '           $brtn
530aAC                   else
     *
     C                   exsr      zzopt
530aAC                   endif
     C                   endif
     C                   endif
     C                   endif
     *
414aAC     opts2e        tag
414aA*
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
530aMC     endop2        endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG03    Screen 3 page routines
OP1 A*
OP1 AC     pag03         begsr
OP1 A*
OP1 A*  NEXT PAGE
OP1 A*
OP1 AC                   if        pagcmd = '*NEXT   '
OP1 AC                   exsr      pag3fw
OP1 AC                   else
OP1 A*
OP1 A*  PREVIOUS PAGE
OP1 A*
OP1 AC                   if        pagcmd = '*PREV   '
OP1 AC                   exsr      pag3bk
OP1 AC                   else
OP1 A*
OP1 A*  REFRESH SCREEN
OP1 A*
OP1 AC                   if        pagcmd = '*REFRESH'
OP1 AC     deltop        setll     workopt
OP1 AC                   eval      bot = *off
OP1 AC                   exsr      pag3fw
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   eval      pagcmd = *blanks
OP1 AC     pag03e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG3FW   Let's see that next page of delete records
OP1 A*
OP1 AC     pag3fw        begsr
OP1 A*
OP1 A*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
OP1 A*
OP1 AC     bot           cabeq     '1'           endf3
OP1 A*
OP1 A*  INITIALIZE VARIABLES FOR LOOKUP
OP1 A*
OP1 AC                   exsr      sflclr
OP1 AC                   move      *loval        $wkof
OP1 AC                   move      *loval        $wkou
OP1 AC                   eval      bot = *off
OP1 AC                   eval      top = *off
OP1 AC                   eval      stop = *off
OP1 AC                   eval      p = 0
OP1 A*
OP1 A*  GET 10 RECORDS TO DISPLAY
OP1 A*
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        reade     workopt                                79
OP1 A*
OP1 A*  OUT OF RECORDS - INFORM USER AND SET FLAG
OP1 A*
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   eval      bot = *on
OP1 AC                   eval      moreln = 'Bottom '
OP1 AC                   goto      endfw3
OP1 AC                   endif
OP1 A*
OP1 A*  RECORD READ - STOP AFTER 10 GOOD RECORDS
OP1 A*
OP1 AC                   if        wkoopt = ' 1'  or
510cAC                             wkoopt = '1I'  or
510cAC                             wkoopt = '1J'
OP1 AC                   add       1             p
OP1 AC                   exsr      deladd
OP1 AC                   if        p >= 10
OP1 AC                   eval      stop = *on
OP1 AC                   if        forceb = '1'
OP1 AC                   eval      bot = *on
OP1 AC                   eval      moreln = 'Bottom '
OP1 AC                   else
OP1 AC                   eval      moreln = 'More...'
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   endif
OP1 AC     endfw3        tag
OP1 AC                   enddo
OP1 A*
OP1 A*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
OP1 A*
OP1 AC                   eval      dsplyd = p
OP1 AC                   eval      forceb = *off
OP1 AC     endf3         endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG3BK   Let's see the previous page of delete records
OP1 A*
OP1 AC     pag3bk        begsr
OP1 A*
OP1 A*  IF WE ARE AT THE TOP THEN DO NOTHING
OP1 A*
OP1 AC     top           cabeq     '1'           endb3
OP1 AC                   eval      forceb = *off
OP1 A*
OP1 A*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
OP1 A*
OP1 AC     dsplyd        add       10            goback
OP1 AC                   if        bot = '1'
OP1 AC     wkoprt        setgt     workopt
OP1 AC                   add       1             goback
OP1 AC                   endif
OP1 A*
OP1 A*  INITIALIZE VARIABLES FOR LOOKUP
OP1 A*
OP1 AC                   eval      p = 0
OP1 AC                   eval      top = *off
OP1 AC                   eval      bot = *off
OP1 AC                   eval      stop = *off
OP1 A*
OP1 A*  READ SPECIFIED FLITCHES FILE
OP1 A*
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        readpe    workopt                                79
OP1 A*
OP1 A*  HIT TOP OF FILE
OP1 A*
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   eval      top = *on
OP1 AC                   goto      endbk3
OP1 AC                   endif
OP1 A*
OP1 A*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
OP1 A*
OP1 AC                   if        wkoopt = ' 1'  or
510cAC                             wkoopt = '1I'  or
510cAC                             wkoopt = '1J'
OP1 AC                   add       1             p
OP1 AC                   if        p >= goback
OP1 AC                   eval      stop = *on
OP1 AC                   endif
OP1 AC                   endif
OP1 AC     endbk3        tag
OP1 AC                   enddo
OP1 A*
OP1 A* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
OP1 A*
OP1 AC                   if        top = '1'
OP1 AC     wkoprt        setll     workopt
OP1 AC                   endif
OP1 AC                   exsr      pag3fw
OP1 AC     endb3         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  ROLL03   Screen 3 roll up/down routine
OP1 A*
OP1 AC     roll03        begsr
OP1 A*
OP1 A*  TEST FOR ROLLUP
OP1 A*
OP1 AC                   if        status = rollup
OP1 AC                   eval      pagcmd = '*NEXT   '
OP1 AC                   exsr      pag03
OP1 AC                   goto      rol03e
OP1 AC                   endif
OP1 A*
OP1 A*  TEST FOR ROLLDOWN
OP1 A*
OP1 AC                   if        status = rolldn
OP1 AC                   eval      pagcmd = '*PREV   '
OP1 AC                   exsr      pag03
OP1 AC                   goto      rol03e
OP1 AC                   endif
OP1 AC     rol03e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   readc     dsppsf                                 79
510  C                   else
     C                   readc     dspsfl                                 79
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   readc     vw2sfl                                 79
VW2 AC                   when      view = 3
VW2 AC                   readc     vw3sfl                                 79
VW2 AC                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
JPFaAC                   if        client = palmer
JPFaAC                             and option = ' 4'
JPFaAC                   eval      error = *on
JPFaAC                   eval      *in21 = *on
JPFaAC                   eval      errmsg = *blanks
JPFaAC                   exsr      ZM0108
JPFaACSR                 endif
CSPaA*
CSPaA*     Check if user is authorized to use this option.
CSPaAC                   if        client = Coastalsunbelt
CSPaAC                   if        option = ' 4'
CSPaAC                   call      @AUTPG
CSPaAC                   parm                    #prog
CSPaAC                   parm      '4'           pgmopt           20
CSPaAC                   parm                    #user
CSPaAC                   parm                    $artncd           8
CSPaAC                   if        $artncd = '*NO'
CSPaAC                   eval      error = '1'
CSPaAC                   eval      *in21 = '1'
CSPaAC                   eval      errmsg = err01
CSPaAC                   exsr      zm0105
CSPaAC                   endif
CSPaAC                   endif
CSPaAC                   endif
CSPaA*
     C                   endif
     *
     *  SAVE OPTION
     *
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   z-add     recno         y
VW2 AC                   when      view = 2
222 D*R                   Z-ADDRECNO2    Y       30
222 MC                   z-add     recno         y
VW2 AC                   when      view = 3
222 D*R                   Z-ADDRECNO3    Y       30
222 MC                   z-add     recno         y
VW2 AC                   endsl
414aA*
414aA*    Verify that route is still at "open" status.
414aA*
414aAC                   select
414aAC                   when      option = ' 1'  or
414aAC                             option = ' 2'  or
414aAC                             option = ' 4'  or
414aAC                             option = '12'
414aAC                   eval      dsukey = fkey(y)
414aAC                   exsr      zzckst
414aAC                   endsl
414aA*
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
222 D*R                   Z-ADDRECCNT    RECNO2
222 D*R                   Z-ADDRECCNT    RECNO3
     C                   z-add     reccnt        y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
510  C                   if        client = packer
510  C                   write     dsppsf
510  C                   else
     C                   write     dspsfl
510  C                   endif
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
VW2 AC                   write     vw2sfc
VW2 AC                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
222 D*R                   Z-ADD0         RECNO2  40
222 D*R                   Z-ADD0         RECNO3  40
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C     1             chain     dsppsf                             79
510  C                   else
     C     1             chain     dspsfl                             79
510  C                   endif
     C                   if        not *in79
     C                   eval      *in20 = *on
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
     C                   endif
VW2 AC                   when      view = 2
VW2 AC     1             chain     vw2sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw2sfl
VW2 AC                   endif
VW2 AC                   when      view = 3
VW2 AC     1             chain     vw3sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw3sfl
VW2 AC                   endif
VW2 AC                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
222 D*R         RECCNT    IFGT 0
     C                   eval      *in81 = *on
222 D*R                   ENDIF
     C                   eval      recno = posrec
222 D*R                   Z-ADDPOSREC    RECNO2
222 D*R                   Z-ADDPOSREC    RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C     x             chain     dsppsf                             79
510  C                   else
     C     x             chain     dspsfl                             79
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC     x             chain     vw2sfl                             79
VW2 AC                   when      view = 3
VW2 AC     x             chain     vw3sfl                             79
VW2 AC                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
VW2 AC                   when      view = 2
VW2 AC                   update    vw2sfl
VW2 AC                   when      view = 3
VW2 AC                   update    vw3sfl
VW2 AC                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
416aA*----------------------------------------------------------------
416aA*      PIR7978 Record already inuse.
416aA*
416aAC     zm7978        begsr
416aAC                   eval      #msgid = 'PIR7978'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
414aA*----------------------------------------------------------------
414aA*   PIR9907  &1 no longer at status of &2.
414aA*
414aAC     zm9907        begsr
414aAC                   eval      #msgid = 'PIR9907'
414aAC                   eval      #msgtp = '*DIAG  '
414aAC                   movea     errmsg        $md(1)
414aAC                   exsr      zmpmsg
414aAC                   endsr
417bA*----------------------------------------------------------------
417bA*   PIR9908  &1 currently inuse. &2 in progress.
417bA*
417bAC     zm9908        begsr
417bAC                   eval      #msgid = 'PIR9908'
417bAC                   eval      #msgtp = '*DIAG  '
417bAC                   movea     errmsg        $md(1)
417bAC                   exsr      zmpmsg
417bAC                   endsr
414aA*----------------------------------------------------------------
414aA*
414aA*  ZZCKST   Check status of route before proceeding.
414aA*
414aAC     zzckst        begsr
414aA*
414aAC                   eval      stserr = *off
414aAC                   eval      kywhse = rhwhse
414aAC                   eval      kystat = rhstat
414aAC                   eval      kytype = rhtype
414aAC                   eval      kyrte = rhrte
414aAC                   eval      kyrtid = rhrtid
414aA*
414aAC     ckstky        setll     rtehed2                                79
414aA*
414aA*    If *IN79 - off - Route is no longer at correct status. Halt user
414aA*    from proceeding.
414aA*
414aAC                   select
414aAC                   when      not *in79
414aAC                   eval      stserr = *on
414aAC                   eval      error = *on
414aAC                   eval      *in21 = *on
414aAC                   eval      eropt = kyrte
414aAC                   eval      erstat = stat(1)
414aAC                   eval      ertype = 'Routes  '
414aAC                   exsr      zm9907
416aA*
416aA*    Status ok - Ensure route record is available.
416aAC                   other
416aA*
416aA*    Make sure that route header is not locked by Import
416aA*    Order processing.
416aAC     rhkey         chain     rtehed                             7778
416aAC                   if        not *in77
416aAC                   unlock    rtehed
416aAC                   endif
416aA*    If *IN78 - On  - Route is possibly locked by Import Order
416aA*    processing. Halt user from proceeding.
416aAC                   select
416aAC                   when      *in78
416aAC                   eval      stserr = *on
416aAC                   eval      error = *on
416aAC                   eval      *in21 = *on
416aAC                   movel     kyrte         errmsg
416aAC                   exsr      zm7978
416aAC                   endsl
416aA*
414aAC                   endsl
414aA*
414aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
     C                   if        row# = 4  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *
     *  Test for F8 - Truck detail
     *
     C                   if        *inkh
     C                   eval      $pcmd = '*CHANGE '
     C                   call      'TM110A'
     C                   parm                    $prtky
     C                   parm                    $rtncd
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     fileky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe    record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Status description
     *
417bA*   Inuse status.
417bA*
650eAC                   eval      $icmd = '*GETIUSE'
650eAC                   exsr      zziuse
650eA*
417bAC                   select
650eA*
650eA*   Route is inuse
650eAC                   when      $irtn = '*ERROR'
650eAC                   eval      w1stat = $itext10
650eAC                   eval      w3stat = $itext10
650eA*
650eDC**                 when      rhshpd <> 0
650bD **
650bD **  Set route status to Importing.
650bDC**                 if        rhiuse = 5
650bDC**                 eval      w1stat = stat(8)
650bDC**                 eval      w3stat = stat(8)
650bDC**                 else
650bD **
650bD **  Set route status to Alloc/Build.
650bDC**                 eval      w1stat = stat(7)
650bDC**                 eval      w3stat = stat(7)
650bDC**                 endif
650eDC**                 eval      $icmd = '*GETIUSE'
650eDC**                 exsr      zziuse
650eDC**                 eval      w1stat = $itext10
650eDC**                 eval      w3stat = $itext10
417bA*
417bA*   Otherwise, Route Open.
417bAC                   other
417bA*
     C                   move      rhstat        p1
     C                   eval      w1stat = stat(p1)
     C                   eval      w3stat = stat(p1)
417bAC                   endsl
     *
     *   Summary totals
     *
     C                   eval      w1cube = 0
     C                   eval      w1swgt = 0
     C                   eval      w1pcs = 0
     C     keyrs         setll     rtesum
     C                   dow       forevr = forevr
     C     keyrs         reade     rtesum                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   add       rsordc        w1cube
     C                   add       rsordw        w1swgt
     C                   add       rsordp        w1pcs
     C                   enddo
     *
     *   Report date
     *
     C                   if        rhrptd = 0
     C                   eval      w2rptd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhrptd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2rptd = $cvd6o
     C                   endif
     *
     *   Imported date
     *
     C                   if        rhimpd = 0
     C                   eval      w2impd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhimpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2impd = $cvd6o
     C                   endif
     *
     *   Built date
     *
     C                   if        rhbldd = 0
     C                   eval      w2bldd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhbldd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2bldd = $cvd6o
     C                   endif
     *
     *   Printed date
     *
     C                   if        rhprtd = 0
     C                   eval      w2prtd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhprtd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2prtd = $cvd6o
     C                   endif
     *
     *   Exported date
     *
530bDC**                 if        rhexpd = 0
530bDC**                 eval      w3expd = 0
530bDC**                 else
530bDC**                 eval      $cvcmd = '*CMDMDY '
530bDC**                 move      rhexpd        $cvd8i
530bDC**                 call      @cvtdt
530bDC**                 parm                    $cvtdt
530bDC**                 eval      w3expd = $cvd6o
530bDC**                 endif
     *
     *   Driver
     *
530bAC     keyrs         chain     ttrte
530bAC                   if        not %found
530bAC                   eval      ttrusr = ' '
530bAC                   endif
     *
     *   Status date
     *
     C                   if        rhstsd = 0
     C                   eval      w3stsd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhstsd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3stsd = $cvd6o
     C                   endif
     *
520bA*   Crossdock PO#
520bA*
520bAC                   eval      w1xdpo = *blanks
530 AC     keyrs         setll     ordh3
530 AC                   dow       forevr = forevr
530 AC     keyrs         reade     ordh3
530 AC                   if        %eof(ordh3)
530 AC                   leave
530 AC                   endif
520bAC     xdk1ky        chain     crossdk1
520bAC                   if        %found
520bAC                   eval      w1xdpo = cdpo
530 AC                   leave
520bAC                   endif
530 AC                   enddo
     *
510  *   Shipment Number for Packers
510  *
510  C                   eval      w1ship = *blanks
510  C                   if        client = packer
510  C     keyrs         chain     ordhm2                             70
510  C                   if        not *in70
510  C                   eval      w1ship = hmmshp
510  C                   endif
510  C                   endif
CSP A*
CSP A*   Driver Name for Coastal Sunbelt Produce
CSP A*
CSP AC                   if        client = Coastalsunbelt
CSP AC     keyrs         chain     ordhm2
CSP AC                   if        not %found(ordhm2)
CSP AC                   eval      hmmsc1 = ' '
CSP AC                   endif
CSP AC                   eval      ordhm1_csp = hmmsc1
CSP AC                   eval      ttrusr     = %subst(csphm1_drvnm:1:10)
CSP AC                   endif
ASCaA*
ASCaA*   Trailer Number for Agar
ASCaA*
ASCaAC                   if        client = agar
RFSaAC                             or client = rfs
ASCaAC                   eval      w1xdpo = *blanks
ASCaAC     keyrs         chain     ordhm2                             70
ASCaAC                   if        not *in70
RFSaAC                             and hmmtrlr <> *blanks
ASCbDC**                 eval      w1xdpo = 'Tr ' + hmmtrlr
ASCbMC                   eval      w1xdpo = 'T' + %trim(hmmtrlr)
ASCaAC                   endif
RFSbAC                   eval      *in22 = *on
ASCaAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
414aAC                   eval      stserr = *off
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhstat
     C                   kfld                    rhtype
     C                   kfld                    rhrte
     C                   kfld                    rhrtid
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhstat
     C                   kfld                    rhtype
     C                   kfld                    rhrte
     C                   kfld                    rhrtid
414aA*
414aA*    Define full key for main file to check route status.
414aA*
414aAC     ckstky        klist
414aAC                   kfld                    kywhse
414aAC                   kfld                    kystat
414aAC                   kfld                    kytype
414aAC                   kfld                    kyrte
414aAC                   kfld                    kyrtid
416aAC     rhkey         klist
416aAC                   kfld                    kywhse
416aAC                   kfld                    kyrtid
     *
510bA*  Define partial key for OPTIONS file.
510bA*
510bAC     keyop         klist
510bA***                  KFLD           $KWHSE
510bAC                   kfld                    kywhse
510bAC                   kfld                    kycode
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kstat
     C                   kfld                    $ktype
     *
     *  Define partial key for file RTESUM.
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     *
620aA*  Define partial key for file ORDH4.
620aA*
620aAC     keyordh4      klist
620aAC                   kfld                    rhwhse
620aAC                   kfld                    rhrtid
     *
620aA*  Define key for file ORDH10.
620aA*
620aAC     keyordh10     klist
620aAC                   kfld                    ohwhse
620aAC                   kfld                    ohcord
     *
700aA*  Define key for file ORDH10.
700aA*
700aAC     keyordh10o    klist
 00aAC                   kfld                    ho_ohwhse
700aAC                   kfld                    ho_ohcord
     *
520bA*  Define partial key for file CROSSDK1.
     *
520bAC     xdk1ky        klist
520bAC                   kfld                    rhwhse
520bAC                   kfld                    ohord
640bA*
640bA*  Define key for TRUCKH file.
640bA*
640bAC     trkey         klist
640bAC                   kfld                    $kwhse
640bAC                   kfld                    rhtruk
640bA*
640bA*  Define key for OPTIONZ file.
640bA*
640bAC     opzkya        klist
640bAC                   kfld                    kycod3
640bAC                   kfld                    $kwhse
640bAC                   kfld                    $ptmpl
     *
640bAC     opzkyb        klist
640bAC                   kfld                    kycod4
640bAC                   kfld                    $kwhse
640bAC                   kfld                    $ptmpl
530 A*
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
401 AC                   eval      optln2 = optln(2)
     C                   eval      cmdln1 = cmdln(1)
VW2 AC                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
222 MC                   eval      $ktype = ' '
222 MC                   eval      $kstat = *on
     C                   eval      dsfkey = $prtky
222 DC                   eval      $ktype = ' '
222 DC                   eval      $kstat = *on
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     rhwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = rhwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = rhwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = rhwhse
     C                   eval      whcode = rhwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
510b *  Get Truck builder on Job Que option
510bA*
510bA*    Get general picking options from options file.
510bA*
510bAC                   eval      kycode = '*SYSTEM '
510bAC                   eval      kywhse = 0
510bAC     keyop         chain     options                            79
510bAC                   if        *in79  or
510bAC                             optbjq = ' '
510bAC                   eval      optbjq = 'N'
510bAC                   endif
530aAC                   if        *in79  or
530aAC                             optrax = ' '
530aAC                   eval      optrax = 'N'
530aAC                   endif
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
417bA*----------------------------------------------------------------
417bA*
417bA*  ZZIUSE   Set Inuse flag for route before proceeding.
417bA*
417bAC     zziuse        begsr
417cAC                   eval      stserr = *off
417bA*
650eDC**                 call      'CHKIUSE'
650eDC**                 parm                    $icmd             8
650eDC**                 parm      rhwhse        $iwhse            3 0
650eDC**                 parm      rhrtid        $irtid            5
650eDC**                 parm      *blanks       $irtn             8
650eDC**                 parm      0             $iflag            1 0
650eDC**                 parm      0             $isubflag         1 0
650eDC**                 parm      ' '           $itext10         10
650eDC**                 parm      ' '           $itext30         30

650eAC                   call      'CHKIUSE2'
650eAC                   parm                    $icmd             8
650eAC                   parm      rhwhse        $iwhse            3 0
650eAC                   parm      rhrtid        $irtid            5
650eAC                   parm      #prog         $ipgm            20
650eAC                   parm      ''            $iuser           10
650eAC                   parm      ''            $isessid         40
650eAC                   parm                    $irtn             8
650eAC                   parm                    $itext10         10
650eAC                   parm                    $itext30         30
650eAC                   parm                    $iucmd            8
650eAC                   parm                    $iupgm           20
650eAC                   parm                    $iuuser          10
650eAC                   parm                    $iuSessId        40
650eAC                   parm                    $iuJobName       10
650eAC                   parm                    $iuJobNbr         6
650eAC                   parm                    $iuJobUser       10
650eAC                   parm                    $iuStamp         26

650bAC                   if        $icmd = '*GETIUSE'
650bAC                   leavesr
650bAC                   endif

417bAC                   select
417bAC                   when      $irtn = '*ERROR  '
417bAC                   eval      stserr = *on
417cAC                   eval      cancel = *on
417bAC                   eval      error = *on
417bAC                   eval      *in21 = *on
417bAC                   eval      eropt = rhrte
417bAC                   eval      erstat = stat(7)
417bAC                   eval      ertype = 'Routes  '
417bAC                   exsr      zm9908
417bAC                   endsl
417bA*
417bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   select
     *
     *   Truck Detail
     *
404 D*R         WKOOPT    WHEQ ' 8'
404 MC                   when      wkoopt = '12'
414aA*
414aA*    Verify that route is still at "open" status.
414aA*
414aAC                   eval      *in21 = *off
414aAC                   eval      dsukey = $puky
414aAC                   exsr      zzckst
417bA*
417bA*    Check Inuse flag. If Inuse, then cancel Change.
417bA*
417bAC                   if        stserr = *off
650bDC**                 eval      $icmd = '*INUSE1 '
650bMC                   eval      $icmd = '*INUSE13'
417bAC                   exsr      zziuse
417bAC                   endif
417bA*
414aAC                   if        stserr = *off
     C                   eval      $luky = $puky
     C                   eval      $ltruk = $ltrk2
     C                   call      'TM130'
     C                   parm                    $luky
     C                   parm                    $lrtn
417bA*    Reset Inuse flag.
417bA*
417bAC                   eval      $icmd = '*CLEAR  '
417bAC                   exsr      zziuse
414aAC                   endif
401 A*
401 A*   Order Details
401 A*
401 AC                   when      wkoopt = ' 9'
401 AC                   eval      $luky = $puky
401 AC                   eval      $lrtn = *blanks
401 AC                   call      'RH170'
401 AC                   parm                    $luky
401 AC                   parm                    $lrtn
     *
     *   Department summary
     *
404 D*R         WKOOPT    WHEQ '12'
404 MC                   when      wkoopt = ' 8'
     C                   call      'RS110'
     C                   parm                    $puky
     C                   parm                    $prtn
520aA*
520aA*   Clear In-Use flag
520aA*
520aAC                   when      wkoopt = 'CI'
650dDC**                 eval      $luky = $puky
650dMC                   eval      dsukey = $puky
650aDC**                 eval      $icmd = '*CLEAR  '
650aMC                   eval      $icmd = '*CLEARCI'
520aAC                   exsr      zziuse
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      rhwhse = ptinp1
     C                   eval      $kwhse = rhwhse
222 MC                   eval      rhstat = $kstat
     C                   eval      rhrte = *blanks
     C                   eval      rhrtid = *blanks
     C                   eval      rhtruk = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp2 <> *blanks
     C                   eval      rhrte = ptinp2
     C                   eval      rhrtid = *blanks
     C                   eval      rhtruk = *blanks
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     C                   endif
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 2 4 8 912141I1JCI
**  OPTLN - Option display line
  1=Allocate & build  2=Change truck  4=Delete  8=View breakdown
  9=Order details    12=Truck detail    14=Assign driver
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**  STAT - Route status codes
Open
Allocated
Built
Printed
Closed
Exported
Aloc/build
Importing
**  EM - Error message
Opt 14 not allowed, must be a TRAX user.
Pre-Picked items not yet Pick/Printed.
AMP items not yet Closed.
AMP Box has 2 different Stops.
AMP Zone does not exist.
