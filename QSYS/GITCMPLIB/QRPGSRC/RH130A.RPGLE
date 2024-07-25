      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. RH130AFM WILL BE REPALCED WITH RH130A01
     *----------------------------------------------------------------
     *
     *  RH130A  Built routes (One whse) - Display
     *  17 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
223 A*    07/02/97   HNK  2.23
     *        $BMSG parameter added for OR605 called program.
     *
402 A*    07/15/97   HNK  4.02
     *        Add Option 10 to view order details.
404 A*    08/18/97   RH   4.04
     *        Add option 8 view breakdown.
404 A*    08/27/97   RH   4.04
     *        Add $PCMMD to pass to PS130.
413 A*    01/06/00   HNK  4.13
     *      - Use reports override for device and form to print
     *        the PS311 report.
414aA*    04/12/00   MLB  4.14a
     *      - Revised program to check status of route before allowing
     *        options 1,2,9 or 12 to proceed.
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
416 A*    09/12/01  DAS  4.16
     *      - Added option 4=Unallocate.
     *      - Revised call to @DELPG to send *UNDO instead of *DELETE.
416aA*    02/16/02  MLB  4.16a
     *      - Revised program to call RS120 for compartment summary
     *        when option 8=Summary is selected.
416bA*    04/16/02  MLB  4.16b
     *      - Revised routine ZZCMD to add function key F9
     *        to call dock matrix display.
     *      - Revised array CMDLN to add text for F9.
416cA*    04/18/02  MLB  4.16c
     *      - Revised array OPTLN to add text for opt 11 -
     *        Dock door details
     *      - Added opt 11 to OPTLST array.
     *      - Added call to DH130 - dock door details.
416dA*    04/26/02  MLB  4.16d
     *      - Revised routine ENT03 to ensure that all truck
     *        compartments have dock door(s) assigned prior to
     *        route being selected for pick and print processing.
     *      - Added new message routine ZM1054.
     *
417 A*    05/12/03  MLB  4.17
     *      - Enh: Added new option 0=No assignment. For those users
     *        not utilizing Dock Door Assignment.
417bA*    10/08/03  RH   4.17b
     *      - Enh:Revised program to call CHKIUSE to set inuse flag
     *        in route header when route is selected for pick/print,
     *        change truck, unallocate, rebuild or truck detail.
     *        Allow only 1 user to work with a route for these options
     *      - Revised routine ENT02, ENT03 ,OPTNS2 and ZZOPT to check
     *        inuse status of route before proceeding.
     *      - Created new message routine ZM9908.
417cA*    12/08/03  MLB  4.17c
     *      - Fix: Revised program to not allow multiple routes to be
     *        set inuse if a route is inuse and error message sent.
     *
500 A*    01/20/05  RH   5.00
     *      - Fix: Part of 4.17b code was missed in 417 update.
     *
500aA*    05/02/06  JCJ  5.00a
     *      - Enh: Allow multiple users to access option 12 but only
     *             the first will have maintenance authority, all
     *             others will view.
510 A*    06/15/06  RMC  5.10
     *      - Enh: Create new subfile (DSPPSF) to display
     *             Shipment number for Packers.
     *             Add logic to determine if Packers is accessing
     *             this program.
     *
510aA*    08/07/06  JCJ  5.10
     *      - Enh: Add option 13=Zone Detail
510bA*    12/01/06  RH   5.10b
     *      - Enh: Check Truck Builder Job Que option to run
     *        on Job Que.
510cA*    12/04/06  RH   5.10c
     *      - Enh: Add opt 1I=force interactive, 1J=force job que
510dA*    07/17/07  MLB  5.10d
     *      - Fix: Revised ENT03 to add check for manually assigned
     *        dock doors before allowing pick/print to proceed. If
     *        error occurs during Verify doors assigned, run ZZIUSE
     *        to clear Inuse flag.
     *
520aA*    03/12/08  MLB  5.20a
     *      - Fix: Revised program to add logic to retrieve dock door
     *        options anytime the warehouse number is changed.
     *
520bA*    04/28/08  DAS  5.20b  P#00046
     *      - Renamed format to RH130A01.
     *      - Added route id to view 1 & 2, and DSPSPF.
     *      - Added option 'CI' to ZZOPT.
     *
520cA*    04/28/08  DAS  5.20c  P#00046
     *      - Added second set of option lines.
     *      - Added F23=More Opts
     *      - Added DD=DragDrop to second set of options
     *
530aA*    06/02/10  RBD  5.30a
     *      - Converted to ILE.
     *      - Added *SYSTEM options.
     *      - Revised array OPTLN to add text for opt 14 -
     *        Assign driver.
     *      - Added opt 14 to OPLST array.
     *      - Added call to TR850 - Assign driver to route if
     *        system option 'Using TRAX' equals Y.
     *      - Added EM error message array.
     *
530bA*    09/02/10  RBD  5.30b
     *      - Replaced display of exported date and time with driver.
     *      - Changed name of dspf from RH130A01 to RH130A02.
     *
640aA*    05/12/11  DAS  6.40a
     *      - Option DD not allowed for TB Light.
     *
640bA*    05/23/11  DAS  6.40b
     *      - Can only View truck for TB Light.
     *
640cA*    07/01/11  RBD  6.40c
     *      - Added call to OR635D to delete TOTEHDR records when
     *        option 9=rebuild is selected.
     *
640dA*    10/20/11  RBD  6.40d
     *      - Recompiled, TTRTE file changed.
     *
640eA*    04/03/12  JCJ  6.40e
     *      - Don't allow Pick/Print if zone template has invalid
     *        printers or no printer defined for labels selected to
     *        print.
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
640fA*    04/25/12  JCJ  6.40f
     *      - Enh:  Don't allow Pick/Print if an undefined zone was
     *              created for a route. Must fix the undefined
     *              zone before printing. The undefined zone causes
     *              PFMT to loop.
     *
640gA*    02/29/12  RBD  6.40g
     *      - Recompiled, TTRTE file changed.
     *
640hA*    05/30/12  RBD  6.40h
     *      - Added call to TR858 to write Trax stop records if
     *        system option 'Using TRAX' equals Y.
640iA*    06/19/12  RBD  6.40i
     *      - Added route parm to call to TR858.
     *
650aA*    03/28/13  DAS  6.50a
     *      - Revised to have CI send *CLEARCI to CHKIUSE.
     *
650bA*    04/09/13  DAS  6.50b
     *      - Expanded *INUSE2 commands.
     *      - Requires corresponding change in CHKIUSE program.
     *      - Revised to call CHKIUSE with *GETIUSE to get status
     *        when RHSHPD <> 0.
     *
650c *    12/23/13  DAS  6.50c
     *      - Revised to use CHKIUSE2.
     *      - No longer uses rhshpd for inuse flag.
     *      - Requires new CHKIUSE2 progam and new RTEINUSE file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBIaA*    12/18/03  RH   CBIa
     *      - Enh: Add option 65 to re-print product pick list.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor Wholesale
     *
HARaA*    07/01/11  RBD  HARa
     *      - If user selects pick/print option, call XM150 to build
     *        tote conveyor text file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    12/08/13  MLB  CSP
     *      - Revised pgm to chain to ORDHM2 to retrieve Driver Name and
     *        load into subfile.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Vitco Foods
     *
VFIa *    01/30/20  KDE   VFIa
     *      - Enh:  Override Truck Summary to different printer based
     *              on first character of Truck code
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
414aA*    * Important * Make sure that any new options added to this pro-
414aA*                  gram that allow changes to the route in any way
414aA*                  are preceeded with a call to subroutine ZZCKST
414aA*                  to verify that the route is still at 'built'
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
520aD*H130AFMCF  E                    WORKSTN
530bDF*rh130a01  cf   e             workstn
530bMFrh130a02  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(dsppsf:recno)
222 D*                                       RECNO2KSFILE VW2SFL
222 D*                                       RECNO3KSFILE VW3SFL
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
416dAFoptions   if   e           k disk
     Frtehed2   if   e           k disk
     F                                     rename(rhrec:record)
     Frtesum    if   e           k disk
413 AFreports   if   e           k disk
510  Fordhm2    if   e           k disk
530bAFttrte     if   e           k disk
640eAFoptionz   if   e           k disk
640eAFoptionz3  if   e           k disk    rename(opzrec:opz3) prefix(x)
640eAFtruckh    if   e           k disk
640fAFpltsum1   if   e           k disk
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
520cD**                  OPTLN   1   2 75
520cMD optln           s             75    dim(4) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
VW2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
417bMD stat            s             10    dim(7) ctdata perrcd(1)
417bD*                   STAT    1   6 10
530aAD em              s             50    dim(1) ctdata perrcd(1)
510  *----------------------------------------------------------------
510  *  Customer id
510  *
510   /COPY QCOPYSRC,ID#PACKERS
HARaA /copy qcopysrc,id#harbor
CSP A /COPY QCOPYSRC,ID#COASTAL
VFIaA /COPY QCOPYSRC,ID#VFI
     D @getcl          c                   const('GETCLIENT')
640eA*----------------------------------------------------------------
640eA*  *PICKLBA -  Label printing options for the standard pick,
640eA*              retail, and tote labels.
640eA*
640eA*     08/12/09  RBD  5.20  P#00219
640eA*       - Added record type *PICKLBA which holds printing info
640eA*         for the standard pick, retail, and tote labels.
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
640eA*----------------------------------------------------------------
640eA*  *PICKLBB -  Label printing options for the pick list and
640eA*               ASN labels and pick list report.
640eA*
640eA*     08/12/09  RBD  5.20  P#00219
640eA*       - Added record type *PICKLBB which holds printing info
640eA*         for the pick list and ASN labels and pick list report.
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
510  *
416dA*----------------------------------------------------------------
416dA*  *DOCDOOR -  Dock Door options
416dA*----------------------------------------------------------------
416dA*
416dA* Fields
416dA*
417 M*    OPATYP  -  Dock door assignment. 0=No assigment,1=Auto,2=Manual.
416dA*    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
416dA*
416dA* Data structure
416dA*
416dAD opdata          ds
416dAD  opatyp                 1      1
416dAD  opltyp                 2      2
CBIa *----------------------------------------------------------------
CBIa *  *PICKLBL  -  Picking label options
CBIa *----------------------------------------------------------------
CBIa *
CBIa * Fields
CBIa *
CBIa *    OPCLVL  -  Qty level for combined labels.
CBIa *    OPCWRB  -  Print combined label warning before.
CBIa *    OPCWRA  -  Print combined label warning after.
CBIa *    OPUWRB  -  Print unit of measure warning before.
CBIa *    OPUWRA  -  Print unit of measure warning after.
CBIa *    OPTEXT  -  Text for last line of label.
CBIa *    OPERR   -  Error label ratio.
CBIa *    OPCWGT  -  Catch weight label ratio.
CBIa *    OPLPGM  -  Picking label program.
CBIa *    OPPDEV  -  Printer device.
CBIa *    OPPFRM  -  Printer form.
CBIa *
CBIa * Data structure
CBIa *
CBIa D opzdta          ds
CBIa D  opclvl                 1      3  0
CBIa D  opcwra                 4      4
CBIa D  opcwrb                 5      5
CBIa D  opuwra                 6      6
CBIa D  opuwrb                 7      7
CBIa D  optext                 8     50
CBIa D  operr                 51     52  0
CBIa D  opcwgt                53     54  0
CBIa D  oplpgm                55     64
CBIa D  oppdev                65     74
CBIa D  oppfrm                75     84
CBIa D  oppend               117    117
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
414aA*
414aA* Data structure
414aA*
414aAD opdta1          ds
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
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kstat                 4      4
     D  $ktype                 5      5
416bA*
416bAD  $khdte                 4     11  0
416bAD  $khtim                12     17  0
416bA*
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
416 D**            '*NONE'               C         @DELPG
     D @delpg          c                   const('RH134')
     D @prtpg          c                   const('PS310CL')
640eAD @chkpg          c                   const('ZH125')
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
     *
222 AD  $pwhse                19     21  0 inz(0)
222 AD  $prte                 22     26
222 AD  $prtid                27     31
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
416bA*
416bAD  $lhdte                22     29  0
416bAD  $lhtim                30     35  0
510aA*
510aAD  $krte                 32     36
510aAD  $krtid                37     41
640eA*
640eAD  $llb                  22     22
640eAD  $lcu                  23     23
640eAD  $llp                  24     33
640eAD  $ldv                  34     43
640eAD  $lfm                  44     53
640eAD  $llbltype             54     54
640eA*
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
     *----------------------------------------------------------------
     *  Message control
     *
     D opms01          c                   const('Option not available')
     D opms02          c                   const('Function not availab-
     D                                     le')
640fAD opms03          c                   const('ZZZZZZ error. Undo Route & fi-
     D                                     x zone before Pck/Prt.')
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
     *  Variables
     *
530aAD $awhse          s              3
     D $dev            s             10
     D $form           s             10
640aMD $gfCmd          s              1
640aMD $gfFeature      s              1
640aMD $gfLight        s              1
640aMD $gfWhse         s              3p 0
     D $msgf           s             10
     D $pcmmd          s              8
     D $rtn            s              8
CBIaAD $twhse          s              3  0
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
CBIaAD kycode          s                   like(opcode)
     D kyrte           s                   like(rhrte)
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(rhstat)
     D kytype          s                   like(rhtype)
     D kywhse          s                   like(rhwhse)
CBIaAD kyzone          s              6
     D maxvw           s              1  0
     D maxvwo          s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
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
640aMD tbLight         s               n
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D viewo           s              1  0
     D warn            s              1
     D wkprtf          s             10
     D x               s              3  0
     D y               s              3  0
640eAD $ptmpl          s             10
640eAD kycod3          s                   like(opzcod)
640eAD kycod4          s                   like(opzcod)
     *
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
CBIaA*
CBIaA*  Define partial key for OPTIONZ file.
CBIaA*
CBIaAC     keyopz        klist
CBIaAC                   kfld                    kycode
CBIaAC                   kfld                    $pwhse
CBIaAC                   kfld                    rhtruk
CBIaAC                   kfld                    kyzone
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
     C                   cas                     ent02
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
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
510 A*
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
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
416 D**                   MOVE '*DELETE '$PCMD
416 MC                   eval      $pcmd = '*UNDO   '
     C                   eval      $puky = wkokyu
414aA*
414aA*    Verify that route is still at "built" status.
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
650bDC**                 eval      $icmd = '*INUSE2 '
650bMC                   eval      $icmd = '*INUSE21'
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
414aA*    longer at 'built' status, set on CANCEL.
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
OP1 A*
OP1 AC                   if        wkoopt = ' 1'  or
510cAC                             wkoopt = '1I'  or
510cAC                             wkoopt = '1J'
OP1 A*
OP1 A*  Call option 1 program
OP1 A*
223 AC                   eval      $bprg = #prog
OP1 AC                   eval      $puky = wkokyu
OP1 AC                   eval      dsukey = $puky
414aA*
414aA*    Verify that route is still at "built" status.
414aA*
414aAC                   exsr      zzckst
414aAC                   if        stserr = *on
414aAC                   delete    wkorec
414aAC                   iter
414aAC                   endif
640eA*
640eA* Do not allow Aloc/Build if the zone template has any printers
640eA* that are not valid or not entered.                             .
640eA*
640eA* Get Zone Template Code if Template type is T=Truck
640eA*
640eAC     trkey         chain     truckh
640eAC                   if        %found(truckh) and thtype = 'T'
640eAC                   eval      $ptmpl =  thztmp
640eAC                   else
640eAC                   eval      $ptmpl =  rhtruk
640eAC                   endif
     * Pick/Retail/Tote
640eAC                   eval      opdta3 = *blanks
640eAC                   eval      kycod3 = '*PICKLBA'
640eAC     opzkya        setll     optionz
640eAC                   dou       %eof(optionz)
640eAC     opzkya        reade     optionz
640eAC                   if        not %eof(optionz)
640eAC                   eval      opdta3 = opzdta
     * Pick Label Device
640eAC                   if        oplb1 = 'Y'
640eAC                   eval      $llp = oplp1
640eAC                   eval      $ldv = opdv1
640eAC                   eval      $llbltype = '1'
640eAC                   call      @chkpg
640eAC                   parm                    $lparm
640eAC                   if        $lrtn = '*ERROR  '
640eAC                   eval      error = *on
640eAC                   eval      *in21  = *on
640eAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640eAC                                                   + ' '
640eAC                                                   + $ptmpl
640eAC                   exsr      zm0105
640eAC                   update    wkorec
640eAC                   leave
640eAC                   endif
640eAC                   endif
     * Retail Label Device
640eAC                   if        oplb2 = 'Y'
640eAC                   eval      $llp = oplp2
640eAC                   eval      $ldv = opdv2
640eAC                   eval      $llbltype = '2'
640eAC                   call      @chkpg
640eAC                   parm                    $lparm
640eAC                   if        $lrtn = '*ERROR  '
640eAC                   eval      error = *on
640eAC                   eval      *in21  = *on
640eAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640eAC                                                   + ' '
640eAC                                                   + $ptmpl
640eAC                   exsr      zm0105
640eAC                   update    wkorec
640eAC                   leave
640eAC                   endif
640eAC                   endif
     * Tote Label Device
640eAC                   if        oplb3 = 'Y'
640eAC                   eval      $llp = oplp3
640eAC                   eval      $ldv = opdv3
640eAC                   eval      $llbltype = '3'
640eAC                   call      @chkpg
640eAC                   parm                    $lparm
640eAC                   if        $lrtn = '*ERROR  '
640eAC                   eval      error = *on
640eAC                   eval      *in21  = *on
640eAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640eAC                                                   + ' '
640eAC                                                   + $ptmpl
640eAC                   exsr      zm0105
640eAC                   update    wkorec
640eAC                   leave
640eAC                   endif
640eAC                   endif
640eAC                   endif
640eAC                   enddo
     * ASN/Pick List Label & Report
640eAC                   if        error <> *on
640eAC                   eval      kycod4 = '*PICKLBB'
640eAC                   eval      opdta4 = *blanks
640eAC     opzkyb        setll     optionz
640eAC                   dou       %eof(optionz)
640eAC     opzkyb        reade     optionz
640eAC                   if        not %eof(optionz)
640eAC                   eval      opdta4 = opzdta
     * ASN Label Device
640eAC                   if        oplb4 = 'Y'
640eAC                   eval      $llp = oplp4
640eAC                   eval      $ldv = opdv4
640eAC                   eval      $llbltype = '4'
640eAC                   call      @chkpg
640eAC                   parm                    $lparm
640eAC                   if        $lrtn = '*ERROR  '
640eAC                   eval      error = *on
640eAC                   eval      *in21  = *on
640eAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640eAC                                                   + ' '
640eAC                                                   + $ptmpl
640eAC                   exsr      zm0105
640eAC                   update    wkorec
640eAC                   leave
640eAC                   endif
640eAC                   endif
     * Pick List Label Device
640eAC                   if        oplb5 = 'Y'
640eAC                   eval      $llp = oplp5
640eAC                   eval      $ldv = opdv5
640eAC                   eval      $llbltype = '5'
640eAC                   call      @chkpg
640eAC                   parm                    $lparm
640eAC                   if        $lrtn = '*ERROR  '
640eAC                   eval      error = *on
640eAC                   eval      *in21  = *on
640eAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640eAC                                                   + ' '
640eAC                                                   + $ptmpl
640eAC                   exsr      zm0105
640eAC                   update    wkorec
640eAC                   leave
640eAC                   endif
640eAC                   endif
     * Pick List Report Device
640eAC                   if        oplb6 = 'Y'
640eAC                   eval      $llp = oplp6
640eAC                   eval      $ldv = opdv6
640eAC                   eval      $llbltype = '6'
640eAC                   call      @chkpg
640eAC                   parm                    $lparm
640eAC                   if        $lrtn = '*ERROR  '
640eAC                   eval      error = *on
640eAC                   eval      *in21  = *on
640eAC                   eval      errmsg = %trim($lerm) + ' in zone template'
640eAC                                                   + ' '
640eAC                                                   + $ptmpl
640eAC                   exsr      zm0105
640eAC                   update    wkorec
640eAC                   leave
640eAC                   endif
640eAC                   endif
640eAC                   endif
640eAC                   enddo
640eAC                   endif
640eA
640eAC                   if        error = *on
640eAC                   iter
640eAC                   endif
640fA*
640fA*  Perform option 1 on the records that have been selected
640fA*
640fAC     keyrs         setll     pltsum1
640fAC                   dou       %eof(pltsum1)
640fAC     keyrs         reade     pltsum1                                79
640fAC                   if        not %eof(pltsum1)
640fAC                   if        pstzon = 'ZZZZZZ'
640fAC                             or pspzon = 'ZZZZZZ'
640fAC                             or psszon = 'ZZZZZZ'
640fAC                   eval      error = *on
640fAC                   eval      *in21  = *on
640fAC                   eval      errmsg = opms03
640fAC                   exsr      zm0105
640fAC                   update    wkorec
640fAC                   leave
640fAC                   endif
640fAC                   endif
640fAC                   enddo
640eA
640eAC                   if        error = *on
640eAC                   iter
640eAC                   endif
414bA*
417bA*    Set Inuse flag for pick/print processing.
417bA*
417bAC                   eval      $icmd = '*INUSE2 '
417bAC                   exsr      zziuse
417bAC                   if        stserr = *on
417bAC                   delete    wkorec
417bAC                   iter
417bAC                   endif
417bA*
416dA*    Dock doors assigned automatically. Verify that all
416dA*    compartments have a door assigned.
510dA*    Or if doors assigned manually, verify door assigned.
416dA*
416dAC                   if        opatyp = '1'  or
510dAC                             opatyp = '2'
416dAC                   eval      $pcmmd = '*VERIFY '
416dAC                   call      'DH130'
416dAC                   parm                    $pcmmd
416dAC                   parm                    $puky
416dAC                   parm      *blanks       $prtn
416dA*    Not all compartments have door assigned. Halt processing.
416dAC                   if        $prtn = '*ERROR  '
416dAC                   delete    wkorec                               78
416dAC                   eval      error = *on
416dAC                   movel     $prte         errmsg
416dAC                   exsr      zm1054
510dA*
510dA*    Reset Inuse flag.
510dAC                   eval      $icmd = '*CLEAR  '
510dA*    Clear Inuse flag when dock doors not assigned.
510dAC                   exsr      zziuse
510dA*
416dAC                   iter
416dAC                   endif
416dA*
416dA*    Re-acquire record lock after return from prevous pgm.
416dAC     wkounq        setll     workopt
416dAC     wkoprt        reade     workopt                                79
416dAC                   endif
416dA*
414aA*
510bAC                   if        optbjq = 'Y'  and
510cAC                             wkoopt <> '1I'  or
510cAC                             wkoopt = '1J'
510bAC                   call      'OR605CL'
510bAC                   parm      '*PICK   '    $bcmd             8
510bAC                   parm      '*PCKPRNT'    $bcmd2            8
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
OP1 AC                   parm      '*PCKPRNT'    $bcmd2
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
HARaA*     Build tote conveyor text file.
HARaAC                   select
HARaAC                   when      client = harbor
HARaAC                   call      'XM150'
HARaAC                   parm      rhwhse        $xwhs             3 0
HARaAC                   parm                    rhrtid
HARaAC                   parm      ' '           sfilesnd         30
HARaAC                   parm      ' '           $xrtn             8
HARaAC                   parm      ' '           $xerm            60
HARaAC                   endsl
HARaA*
640hA*     If Trax user, write Trax stop records.
640hA*
640hAC                   if        optrax = 'Y'
640hAC                   call      'TR858'
640hAC                   parm      rhwhse        $xwhs             3 0
640hAC                   parm                    rhrtid
640iAC                   parm                    rhrte
640hAC                   parm      ' '           $xrtn             8
640hAC                   parm      ' '           $xerm            60
640hAC                   endif
640hA*
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
414aA*    longer at 'built' status, set on CANCEL.
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
414aA*    Verify that route is still at "built" status.
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
650bDC**                 eval      $icmd = '*INUSE2 '
650bMC                   eval      $icmd = '*INUSE22'
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
222 AC                   eval      $rtn = *blanks
413 MC                   eval      $dev = *blanks
413 MC                   eval      $form = *blanks
413 AC                   movel     'PS311PR '    wkprtf
413 AC     rpkey         chain     reports                            79
413 AC                   if        not *in79
413 AC                   eval      $dev = rpdev
VFIaAc*  Force S to override parm.  PS310cl then forces PS311PRS to override
VFIaAc*  printer but forces PS311PR back on file so we do not have to create
VFIaAc*  additional printer file to simply override printer in same warehouse
VFIaAc                   if        client = vitco
VFIaAc                             and %subst(rhtruk:1:1)='S'
VFIaAC                   eval      $dev = 'S         '
VFIaAc                   endif
413 AC                   eval      $form = rpform
413 AC                   else
413 AC                   movel     '*JOB    '    $dev
413 AC                   movel     '*STD    '    $form
413 AC                   endif
     C                   call      @prtpg
222 AC                   parm                    $pwhse
222 AC                   parm                    $prtid
222 AC                   parm                    $rtn
222 AC                   parm                    $dev
222 AC                   parm                    $form
222 D**                   PARM           $PARMS
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
414aA*    Verify that route is still at "built" status.
414aA*
414aAC                   select
414aAC                   when      option = ' 1'  or
414aAC                             option = ' 2'  or
414aAC                             option = ' 9'  or
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
416dA*----------------------------------------------------------------
416dA*      1054  Not all dock door(s) assigned to route.
416dA*
416dAC     zm1054        begsr
416dAC                   eval      #msgid = 'PIR1054'
416dAC                   eval      #msgtp = '*DIAG  '
416dAC                   movea     errmsg        $md(1)
416dAC                   exsr      zmpmsg
416dAC                   endsr
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
414aAC                   eval      erstat = stat(3)
414aAC                   eval      ertype = 'Routes  '
414aAC                   exsr      zm9907
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
416bA*
416bA*  Test for F9 - Dock matrix
416bA*
416bAC                   if        *inki
417 A*
417 A*    Dock door assignment active, auto or manual.
417 AC                   if        opatyp >= '1'
416bA*
416bA*    Get last dock history record.
416bAC                   eval      $lprg = #prog
416bAC                   eval      $lwhse = $kwhse
416bAC                   call      'DH910'
416bAC                   parm                    $lparm
416bAC                   if        $lrtn = '*OK     '
416bAC                   eval      $lcmd = '*CHANGE '
416bAC                   call      'DH120A'
416bAC                   parm                    $lcmd
416bAC                   parm                    $luky
416bAC                   parm      *blanks       $lrtn
416bAC                   endif
417 A*
417 A*    Dock door assignment not active.
417 AC                   else
417 AC                   eval      error = *on
417 AC                   eval      errmsg = opms02
417 AC                   exsr      zm0105
417 AC                   endif
416bA*
416bAC                   endif
520cA*
520cA*  TEST FOR CMD23 - More options
520cA*
520cAC                   if        *inkx
520cAC                   if        viewo = maxvwo
520cAC                   eval      viewo = 1
520cAC                   else
520cAC                   add       1             viewo
520cAC                   endif
520cAC                   eval      v = viewo * 2
520cAC                   eval      optln2 = optln(v)
520cAC                   eval      v = v - 1
520cAC                   eval      optln1 = optln(v)
520cAC                   goto      endcm1
520cAC                   endif
     *
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
     *
500 A*   Inuse status.
500 A*
650cAC                   eval      $icmd = '*GETIUSE'
650cAC                   exsr      zziuse
650cA*
500 AC                   select
650cA*
650cA*   Route is inuse
650cAC                   when      $irtn = '*ERROR'
650cAC                   eval      w1stat = $itext10
650cAC                   eval      w3stat = $itext10
650cA*
650cDC**                 when      rhshpd <> 0
650bDC**                 eval      w1stat = stat(7)
650bDC**                 eval      w3stat = stat(7)
650cDC**                 eval      $icmd = '*GETIUSE'
650cDC**                 exsr      zziuse
650cDC**                 eval      w1stat = $itext10
650cDC**                 eval      w3stat = $itext10
500 A*
500 A*   Otherwise, Route Open.
500 AC                   other
500 A*
     C                   move      rhstat        p1
     C                   eval      w1stat = stat(p1)
     C                   eval      w3stat = stat(p1)
500 AC                   endsl
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
510  *
510  *   Shipment Number for Packers
510  *
510  C                   eval      w1ship = *blanks
510  C                   if        client = packer
510  C     keyrs         chain     ordhm2                             70
510  C                   if        not *in70
510  C                   eval      w1ship = hmmshp
510  C                   endif
510  C                   endif
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
413 A*
413 AC     rpkey         klist
413 AC                   kfld                    wkprtf
416dA*
416dA*  Define key for file OPTIONS - Full key.
416dA*
416dAC     keyop         klist
416dAC                   kfld                    opwhse
416dAC                   kfld                    opcode
520aA*
520aA*  Define key for file OPTIONS - Full key.
520aA*
520aAC     keyopd        klist
520aAC                   kfld                    $kwhse
520aAC                   kfld                    opcode
640eA*
640eA*  Define key for TRUCKH file.
640eA*
640eAC     trkey         klist
640eAC                   kfld                    $kwhse
640eAC                   kfld                    rhtruk
640eA*
640eA*  Define key for OPTIONZ file.
640eA*
640eAC     opzkya        klist
640eAC                   kfld                    kycod3
640eAC                   kfld                    $kwhse
640eAC                   kfld                    $ptmpl
     *
640eAC     opzkyb        klist
640eAC                   kfld                    kycod4
640eAC                   kfld                    $kwhse
640eAC                   kfld                    $ptmpl
     *
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
520cAC                   eval      viewo = 1
520cAC                   eval      maxvwo = 2
     C                   eval      optln1 = optln(1)
222 AC                   eval      optln2 = optln(2)
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
222 MC                   eval      $kstat = '3'
     C                   eval      dsfkey = $prtky
222 DC                   eval      $ktype = ' '
222 DC                   eval      $kstat = '3'
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
640aA
640aA*   Get feature info.
640aA
640aAC                   call      'GETFEAT'
640aAC                   parm      '*GET'        $gfCmd
640aAC                   parm      #whse         $gfWhse
640aAC                   parm                    $gfFeature
640aAC                   parm                    $gfLight
640aAC                   if        $gfLight = 'Y'
640aAC                   eval      tbLight = *on
640aAC                   else
640aAC                   eval      tbLight = *off
640aAC                   endif
     *
510b *  Get Truck builder on Job Que option
510bA*
510bA*    Get general picking options from options file.
510bA*
510bAC                   eval      opwhse = 0
510bAC                   eval      opcode = '*SYSTEM '
510bAC     keyop         chain     options                            79
510bAC                   eval      opdta1 = opdata
510bAC                   if        *in79  or
510bAC                             optbjq = ' '
510bAC                   eval      optbjq = 'N'
510bAC                   endif
530aAC                   if        *in79  or
530aAC                             optrax = ' '
530aAC                   eval      optrax = 'N'
530aAC                   endif
416dA*
416dA*    Retrieve Dock Door Options record.
416dA*
416dAC                   eval      opwhse = rhwhse
416dAC                   eval      opcode = '*DOCDOOR'
416dAC     keyop         chain     options                            79
416dAC                   if        *in79
417 D*R                   MOVE '1'       OPATYP
417 MC                   eval      opatyp = *off
416dAC                   eval      opltyp = *on
416dAC                   endif
     *
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
650cDC**                 call      'CHKIUSE'
650cDC**                 parm                    $icmd             8
650cDC**                 parm      rhwhse        $iwhse            3 0
650cDC**                 parm      rhrtid        $irtid            5
650cDC**                 parm      *blanks       $irtn             8
650cDC**                 parm      0             $iflag            1 0
650cDC**                 parm      0             $isubflag         1 0
650cDC**                 parm      ' '           $itext10         10
650cDC**                 parm      ' '           $itext30         30

650cAC                   call      'CHKIUSE2'
650cAC                   parm                    $icmd             8
650cAC                   parm      rhwhse        $iwhse            3 0
650cAC                   parm      rhrtid        $irtid            5
650cAC                   parm      #prog         $ipgm            20
650cAC                   parm      ''            $iuser           10
650cAC                   parm      ''            $isessid         40
650cAC                   parm                    $irtn             8
650cAC                   parm                    $itext10         10
650cAC                   parm                    $itext30         30
650cAC                   parm                    $iucmd            8
650cAC                   parm                    $iupgm           20
650cAC                   parm                    $iuuser          10
650cAC                   parm                    $iuSessId        40
650cAC                   parm                    $iuJobName       10
650cAC                   parm                    $iuJobNbr         6
650cAC                   parm                    $iuJobUser       10
650cAC                   parm                    $iuStamp         26

650bAC                   if        $icmd = '*GETIUSE'
650bAC                   leavesr
650bAC                   endif

417bAC                   select

500aAC                   when      $irtn = '*ERROR  '  and
500aAC                             wkoopt = '12'
500aAC                   eval      stserr = *on

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
640aA*
640aA*   Option DD not allowed in TB Light
640aA*
640aAC                   when      wkoopt = 'DD'
640aAC                   if        tbLight
640aAC                   eval      error = *on
640aAC                   eval      *in21 = *on
640aAC                   eval      errmsg = 'Option DD not allowed '
640aAC                                    + 'in TB Light version'
640aAC                   exsr      zm0105
640aAC                   endif
404 A*
404 A*   Department summary
404 A*
404 AC                   when      wkoopt = ' 8'
416aD*R                   CALL 'RS110'
416aMC                   call      'RS120'
404 AC                   parm                    $puky
404 AC                   parm                    $prtn
     *
     *
     *   Rebuild
     *
     C                   when      wkoopt = ' 9'
     C                   eval      dsukey = $puky
414aA*
414aA*    Verify that route is still at "built" status.
414aA*
414aAC                   eval      *in21 = *off
414aAC                   exsr      zzckst
417bA*
417bA*    Check Inuse flag. If Inuse, then cancel Change.
417bA*
417bAC                   if        stserr = *off
650bDC**                 eval      $icmd = '*INUSE2 '
650bMC                   eval      $icmd = '*INUSE25'
417bAC                   exsr      zziuse
417bAC                   endif
417bA*
640cA*    Delete TOTEHDR records for the route.
640cA*
640cAC                   if        stserr = *off
640cAC                   call      'OR635D'
640cAC                   parm      rhwhse        $whse             3 0
640cAC                   parm                    rhrtid
640cAC                   endif
640cA*
414aAC                   if        stserr = *off
     C                   call      'OR605'
     C                   parm      '*PICK   '    $bcmd
     C                   parm      '*REBUILD'    $bcmd2
     C                   parm      '*PICK1  '    $btype
     C                   parm      '1'           $bjtyp
     C                   parm      rhwhse        $bwhs
     C                   parm      0             $bbat
     C                   parm      ' '           $bstat
     C                   parm      rhrtid        $brtid
     C                   parm      0             $bord
     C                   parm      0             $brwhs
     C                   parm      ' '           $btrte
     C                   parm      ' '           $brtn
223 AC                   parm      ' '           $bmsg
417bA*    Reset Inuse flag.
417bA*
417bAC                   eval      $icmd = '*CLEAR  '
417bAC                   exsr      zziuse
414aAC                   endif
402 A*
402 A*   Order Details
402 A*
402 AC                   when      wkoopt = '10'
402 AC                   eval      $luky = $puky
402 AC                   eval      $lrtn = *blanks
402 AC                   call      'RH170'
402 AC                   parm                    $luky
402 AC                   parm                    $lrtn
416bA*
416bA*   Dock door details.
416bA*
416bAC                   when      wkoopt = '11'
417 A*
417 A*    Dock door assignment active, auto or manual.
417 AC                   if        opatyp >= '1'
416bAC                   eval      $pcmmd = '*CHANGE '
416bAC                   call      'DH130'
416bAC                   parm                    $pcmmd
416bAC                   parm                    $puky
416bAC                   parm      *blanks       $prtn
417 A*
417 A*    Dock door assignment not active.
417 AC                   else
417 AC                   eval      error = *on
417 AC                   eval      *in21 = *on
417 AC                   eval      errmsg = opms01
417 AC                   exsr      zm0105
417 AC                   endif
     *
     *   Truck Detail
     *
     C                   when      wkoopt = '12'
404 AC                   eval      $pcmmd = *blanks
414aA*
414aA*    Verify that route is still at "built" status.
414aA*
414aAC                   eval      *in21 = *off
414aAC                   eval      dsukey = $puky
414aAC                   exsr      zzckst
640bA*
640bA*    Set stserr = *on for TB Light to force using *VIEW.
640bA*
640bAC                   if        tbLight
640bAC                   eval      stserr = *on
640bAC                   endif
417bA*
417bA*    Check Inuse flag. If Inuse, then cancel Change.
417bA*
417bAC                   if        stserr = *off
650bDC**                 eval      $icmd = '*INUSE2 '
650bMC                   eval      $icmd = '*INUSE23'
417bAC                   exsr      zziuse
417bAC                   endif
417bA*
414aAC                   if        stserr = *off
     C                   call      'PS130'
404 AC                   parm                    $pcmmd
     C                   parm                    $puky
     C                   parm                    $prtn
417bA*    Reset Inuse flag.
417bA*
417bAC                   eval      $icmd = '*CLEAR  '
417bAC                   exsr      zziuse
414aAC                   endif
     *
500aAC                   if        stserr = *on
500aAC                   call      'PS130'
500aAC                   parm      '*VIEW   '    $pcmmd
500aAC                   parm                    $puky
500aAC                   parm                    $prtn
500aAC                   endif
500aA*
510aA*   Zone Detail
510aA*
510aAC                   when      wkoopt = '13'
510aAC                   eval      error = *off
510aAC                   eval      $lwhse = $pwhse
510aAC                   eval      $ltruk = rhtruk
510aAC                   eval      $krte = rhrte
510aAC                   eval      $krtid = rhrtid
510aAC                   call      'ZH140'
510aAC                   parm                    $luky
510aAC                   parm                    $lrtn
     *
     *   Reprint Product Pick List
     *
     C                   when      wkoopt = '65'
CBIaA*    Get PICKLBL options from OPTIONZ'file.
CBIaAC*******            open      optionz
CBIaA*
CBIaAC                   eval      kycode = '*PICKLBL'
CBIaAC                   movel     'PRD'         kyzone
CBIaAC     keyopz        chain     optionz                            79
CBIaAC                   if        *in79
CBIaAC                   eval      opclvl = 1
CBIaAC                   eval      opcwra = 'N'
CBIaAC                   eval      opcwrb = 'N'
CBIaAC                   eval      opuwra = 'N'
CBIaAC                   eval      opuwrb = 'N'
CBIaAC                   eval      optext = *blanks
CBIaAC                   eval      operr = 0
CBIaAC                   eval      opcwgt = 0
CBIaAC                   movel     'PLBL40'      oplpgm
CBIaAC                   eval      oppdev = *blanks
CBIaAC                   movel     'LP02'        oppdev
CBIaAC                   movel     '*STD'        oppfrm
CBIaAC                   endif
CBIaAC                   eval      oppdev = *blanks
CBIaAC                   movel     'LP02'        oppdev
CBIaAC                   eval      $twhse = $kwhse
CBIaAC                   call      'PLST40CB'
CBIaAC                   parm                    $pcmd
CBIaAC                   parm                    $twhse
CBIaAC                   parm                    $prtid
CBIaAC                   parm      'P'           comp              1
CBIaAC                   parm      'PRD   '      zone              6
CBIaAC                   parm      1             pgen              1 0
CBIaAC                   parm      'PRD   '      pszon             6
CBIaAC                   parm                    rhtruk
CBIaD**                   PARM           $OTYPE
CBIaAC                   parm                    $prte
CBIaAC                   parm                    opzdta
CBIaAC                   parm                    $trn              7 0
520bA*
520bA*   Clear In-Use flag
520bA*
520bAC                   when      wkoopt = 'CI'
520bAC                   eval      $luky = $puky
650aDC**                 eval      $icmd = '*CLEAR  '
650aMC                   eval      $icmd = '*CLEARCI'
520bAC                   exsr      zziuse
510aA*
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
520aA*
520aAC                   eval      opcode = '*DOCDOOR'
520aAC     keyopd        chain     options                            79
520aAC                   if        *in79
520aAC                   eval      opatyp = *off
520aAC                   eval      opltyp = *on
520aAC                   endif
520aA*
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
 1 2 4 6 8 91011121314651I1JCIDD
**  OPTLN - Option display line
  1=Pick & print  2=Change  4=UnAllocate  6=Print summary  8=View breakdown
9=Rebuild  10=Ord det  11=Dk door  12=Truck det  13=Zone det  14=Assign drv
  65=Print Pick List DD=DragDrop

**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F9=Dock matrix  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top  F23=More Opt
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F9=Dock matrix  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top  F23=More Opt
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F9=Dock matrix  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top  F23=More Opt
**  STAT - Route status codes
Open
Allocated
Built
Printed
Closed
Exported
Pick/print
**  EM - Error message
Opt 14 not allowed, must be a TRAX user.
